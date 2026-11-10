# Cooja simulation support

`scripts/run_cooja.sh` launches headless Cooja using `../env.sh`. It uses a local JDK and places caches under `testing/cache/`, without changing the system Java installation.

## Required local runtime layout

Paths below are relative to `testing/`:

| Path | Runtime |
| --- | --- |
| `tools/contiki-ng/` | Contiki-NG release/v5.2, commit in `runtime-versions.json` |
| `tools/contiki-ng/tools/cooja/` | Cooja at the recorded commit, including built `build/libs/cooja.jar` |
| `tools/jdk/` | JDK 25.0.5+8 directory or local symlink |
| `tools/msp430-gcc-9.3.1.11_linux64/` | MSP430 GCC compiler, required for rebuilding |
| `tools/msp430/` | Legacy MSP430 linker-script support used by firmware Makefiles |

These third-party distributions are excluded from Git. The local workstation already has them. A fresh clone must obtain the recorded releases and build Cooja using its Gradle wrapper. The exact Contiki-NG and Cooja commits are in `../runtime-versions.json`. Host-only saved-result analysis requires none of these simulation runtimes.

From the repository root, after provisioning the runtime:

```bash
source testing/env.sh
cd testing/tools/contiki-ng/tools/cooja
./gradlew jar
```

New runs are driven through `combined_system/scripts/runner.py`, which connects the radio root to the Python gateway. Launching an accepted scenario directly does not provide the live gateway socket it expects. Use `run_sources.py` and `run_study.py` in a separate working copy as described in the root README.

## Firmware

Accepted root/leaf `.z1` images are included for simulation execution. Rebuilding requires MSP430 tools and the local Contiki-NG checkout. From the repository root, a dry-run of the leaf build is:

```bash
export PATH="$PWD/testing/tools/msp430-gcc-9.3.1.11_linux64/bin:$PATH"
make -n -C testing/combined_system/firmware/leaf TARGET=z1 \
  CC=msp430-elf-gcc LD=msp430-elf-gcc AR=msp430-elf-ar \
  OBJCOPY=msp430-elf-objcopy STRIP=msp430-elf-strip
```

A rebuild can change accepted binary hashes. Preserve the supplied images when validating the recorded experiments. The Makefiles and third-party toolchains are retained; a fresh firmware rebuild is separate from the saved-record replay check.
