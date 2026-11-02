"""Paired timings for a real GM->L1 Load path; prepacking is identical/offline."""
import os
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import torch
from packed_hir_runtime import load_kernel, make_inputs, check

root = Path(os.environ.get("NBUFFER_ROOT", ".")).resolve()
output = root/'results/perf-packed-hir'
output.mkdir(exist_ok=True)
size, tiles, groups = 64, 256, 24
warmup, samples, inner = 100, 30, 50
input_path = output/'input.mlir'
subprocess.run([sys.executable, str(root/'tools/make_packed_hir.py'), '--dynamic',
                '--size', str(size), '--output', str(input_path)], check=True)
x, y, _, reference = make_inputs(groups, tiles, size)
launches, outputs, identities = {}, {}, []
modes = [('off', 1, 1), ('double', 2, 2), ('nbuf', 3, 4)]
for variant in ('baseline', 'candidate'):
    compiler = root/('baseline-bin' if variant == 'baseline' else 'build/bin')/'bishengir-compile'
    for mode, l1, l0c in modes:
        d = output/f'{variant}-{mode}'
        d.mkdir(exist_ok=True)
        cmd = [str(compiler), str(input_path), '--target=Ascend910_9382',
            f'--multibuffer-mode=[(gm,1),(l1,{l1}),(l0c,{l0c}),(ub,1)]',
            '--enable-auto-multi-buffer=true', '--enable-optimized-metaop=false',
            '--enable-hivm-graph-sync-solver=true', '--enable-hivm-cross-core-gss=true',
            '--enable-tuning-mode=true', '--enable-hfusion-compile=true',
            '--enable-triton-kernel-compile=true', '--enable-auto-blockify-loop',
            '--mlir-disable-threading',
            '--mlir-print-ir-after=hivm-mark-multi-buffer,hivm-plan-memory,hivm-graph-sync-solver,hivm-enable-multi-buffer',
            '-o', str(d/'kernel')]
        r = subprocess.run(cmd, capture_output=True, timeout=60)
        (d/'passes.mlir').write_bytes(r.stderr)
        (d/'stdout').write_bytes(r.stdout)
        record = {'variant': variant, 'mode': mode, 'args': cmd,
            'compiler_sha256': hashlib.sha256(compiler.read_bytes()).hexdigest(),
            'input_sha256': hashlib.sha256(input_path.read_bytes()).hexdigest(),
            'compile_rc': r.returncode}
        (d/'command.json').write_text(json.dumps(record, indent=2)+'\n')
        r.check_returncode()
        launch_kernel, identity = load_kernel(d/'kernel.o')
        record.update(identity)
        identities.append(record)
        out = torch.full_like(reference, float('nan'), device='npu')
        def launch(fn=launch_kernel, out=out):
            fn(x, y, out, tiles, groups)
        launch()
        check(out, reference)
        launches[variant, mode] = launch
        outputs[variant, mode] = out
        print('compiled and correct', variant, mode, flush=True)
for launch in launches.values():
    for _ in range(warmup):
        launch()
torch.npu.synchronize()
rows = []
for sample in range(samples):
    ordered_modes = modes if sample % 2 == 0 else list(reversed(modes))
    variants = ('baseline', 'candidate') if sample % 2 == 0 else ('candidate', 'baseline')
    for mode, _, _ in ordered_modes:
        for variant in variants:
            begin, end = torch.npu.Event(enable_timing=True), torch.npu.Event(enable_timing=True)
            begin.record()
            for _ in range(inner):
                launches[variant, mode]()
            end.record()
            end.synchronize()
            rows.append({'sample': sample, 'variant': variant, 'mode': mode,
                         'us': begin.elapsed_time(end) * 1000 / inner})
for out in outputs.values():
    check(out, reference)
result = {'shape': [groups, tiles, size, size, size],
    'input_format': 'physical zN A/B, ND C; offline prepacking shared by both variants',
    'method': 'same process; sample-wise AB/BA and reversed mode order; NPU events',
    'warmup_per_kernel': warmup, 'samples_per_mode_variant': samples,
    'inner': inner, 'correct_before_after': True, 'rtol': 1e-3, 'atol': 1e-3,
    'identities': identities, 'rows': rows}
(output/'results.json').write_text(json.dumps(result, indent=2)+'\n')
print('packed HIR paired timing complete', flush=True)
