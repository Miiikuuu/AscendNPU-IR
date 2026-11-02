"""Task-only pytest adapter: select and audit the real compiler executable."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time


def pytest_sessionstart(session):
    from triton.backends.ascend import compiler, utils

    executable = str(Path(os.environ["NBUFFER_COMPILER"]).resolve())
    opt = str(Path(executable).with_name("bishengir-opt"))
    log = Path(os.environ["NBUFFER_COMPILER_AUDIT"])
    hashes = {p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
              for p in (executable, opt)}

    def record(value):
        with log.open("a") as stream:
            stream.write(json.dumps(value) + "\n")

    record({"event": "selected", "binaries": hashes})

    def compile_path():
        return executable, os.environ.copy()

    def opt_path():
        return opt, os.environ.copy()

    for module in (compiler, utils):
        module._get_npucompiler_path = compile_path
        module._get_bishengir_opt_path = opt_path

    original_run = subprocess.run

    def audited_run(args, *positional, **keywords):
        selected = isinstance(args, (list, tuple)) and args and str(args[0]) in hashes
        started = time.monotonic()
        if selected and len(args) > 1 and str(args[1]).endswith(".mlir") and Path(args[1]).is_file():
            content = Path(args[1]).read_bytes()
            digest = hashlib.sha256(content).hexdigest()
            saved = log.parent / "compiler-inputs" / (digest + ".mlir")
            saved.parent.mkdir(exist_ok=True)
            saved.write_bytes(content)
            record({"event": "input", "args": list(map(str, args)),
                    "input_sha256": digest, "saved_input": str(saved)})
        try:
            result = original_run(args, *positional, **keywords)
        except subprocess.CalledProcessError as error:
            if selected:
                record({"event": "executed", "args": list(map(str, args)),
                        "sha256": hashes[str(args[0])], "returncode": error.returncode,
                        "elapsed_s": time.monotonic() - started})
            raise
        if selected:
            record({"event": "executed", "args": list(map(str, args)),
                    "sha256": hashes[str(args[0])], "returncode": result.returncode,
                    "elapsed_s": time.monotonic() - started})
        return result

    subprocess.run = audited_run
