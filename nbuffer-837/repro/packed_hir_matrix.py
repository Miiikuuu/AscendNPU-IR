"""Compile the same explicit HIVM input with baseline/candidate, then check on A3."""
import argparse
import os
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time
from packed_hir_runtime import load_kernel, make_inputs, check

p = argparse.ArgumentParser()
p.add_argument('--smoke', action='store_true')
p.add_argument('--event-pressure', action='store_true')
a = p.parse_args()
root = Path(os.environ.get("NBUFFER_ROOT", ".")).resolve()
output = root/'results'/('packed-hir-event-pressure' if a.event_pressure else 'packed-hir-loop-smoke' if a.smoke else 'packed-hir-matrix')
output.mkdir(exist_ok=True)
variants = ('candidate',) if a.smoke else ('baseline', 'candidate')
modes = [(3, 4)] if a.smoke else [(1, 1), (2, 2), (3, 4), (4, 3), (5, 5), (8, 4)]
if a.event_pressure:
    modes = [(9, 9), (16, 16)]
syncs = (True,) if a.smoke else (False, True)
rows = []
for loop in (('for',) if a.event_pressure else ('for', 'while', 'nested')):
    inp = output/f'{loop}.mlir'
    subprocess.run([sys.executable, str(root/'tools/make_packed_hir.py'), '--dynamic',
                    '--loop', loop, '--size', '16', '--output', str(inp)], check=True)
    for variant in variants:
        compiler = root/('baseline-bin' if variant == 'baseline' else 'build/bin')/'bishengir-compile'
        for l1, l0c in modes:
            for sync in syncs:
                name = f'{loop}-{variant}-{l1}-{l0c}-{int(sync)}'
                d = output/name
                d.mkdir(exist_ok=True)
                cmd = [str(compiler), str(inp), '--target=Ascend910_9382',
                    f'--multibuffer-mode=[(gm,1),(l1,{l1}),(l0c,{l0c}),(ub,1)]',
                    '--enable-auto-multi-buffer=true', '--enable-optimized-metaop=false',
                    f'--enable-hivm-graph-sync-solver={str(sync).lower()}',
                    f'--enable-hivm-cross-core-gss={str(sync).lower()}',
                    '--enable-tuning-mode=true', '--enable-hfusion-compile=true',
                    '--enable-triton-kernel-compile=true', '--enable-auto-blockify-loop',
                    '--mlir-disable-threading',
                    '--mlir-print-ir-after=hivm-mark-multi-buffer,hivm-plan-memory,hivm-graph-sync-solver,hivm-enable-multi-buffer',
                    '-o', str(d/'kernel')]
                record = {'case': name, 'args': cmd,
                    'input_sha256': hashlib.sha256(inp.read_bytes()).hexdigest(),
                    'compiler_sha256': hashlib.sha256(compiler.read_bytes()).hexdigest()}
                r = subprocess.run(cmd, capture_output=True, timeout=60)
                (d/'passes.mlir').write_bytes(r.stderr)
                (d/'stdout').write_bytes(r.stdout)
                (d/'command.json').write_text(json.dumps(record, indent=2)+'\n')
                record['compile_rc'] = r.returncode
                if r.returncode == 0:
                    try:
                        launch, identity = load_kernel(d/'kernel.o')
                        record.update(identity)
                        record['tiles_passed'] = []
                        for tiles in ((0, 1, 8, 9, 15, 16, 17, 33) if a.event_pressure else (0, 1, 2, 3, 4, 5, 7, 9)):
                            x, y, out, ref = make_inputs(8, tiles, 16, loop == 'nested')
                            launch(x, y, out, tiles, 8)
                            check(out, ref)
                            record['tiles_passed'].append(tiles)
                    except Exception as error:
                        record['error'] = repr(error)
                rows.append(record)
                (output/'results.json').write_text(json.dumps(rows, indent=2)+'\n')
                print(name, record['compile_rc'], record.get('tiles_passed'), record.get('error', ''), flush=True)
failures = [r for r in rows if r['compile_rc'] or r.get('error')]
print(f'{len(rows)-len(failures)}/{len(rows)} compiled and checked', flush=True)
sys.exit(bool(failures))
