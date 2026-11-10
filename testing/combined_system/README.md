# Combined system

This module implements the closed-loop VIGILFOIL gateway, root/leaf firmware and compact paired evaluation. The gateway connects workload-aware host detection to response-aware packet accounting and budgeted query/repair decisions.

## Entry points

| File | Responsibility |
| --- | --- |
| `scripts/gateway.py` | Per-source evidence, warning integration, helper selection and command admission |
| `scripts/runner.py` | Causal socket bridge and Cooja scenario generation |
| `scripts/run_sources.py` | Four benign resource-fitting/calibration deployments |
| `scripts/train_combined.py` | Resource refit, baseline training, calibration and artifact freezing |
| `scripts/run_study.py` | Seven-policy, three-condition, two-block final matrix |
| `scripts/analyze.py` | Independent raw-event accounting and result tables |
| `scripts/write_paper_results.py` | Paired comparison exports and report |
| `scripts/validate.py` | Artifact/raw-data checks and gateway action replay |
| `scripts/timeline.py` | Host/network evidence timeline figure |
| `scripts/profile.py` | Host replay timing and serialized component sizes |

The accepted recordings comprise four source/calibration deployments and 42 final deployments. `configs/source.json` and `configs/final.json` define the matrices. `configs/cooja-template.csc` is a scenario-generation template; `runner.py` replaces its firmware references with the integrated root/leaf images.

`models/combined.pkl` is the frozen artifact. `results/training-freeze.json` records its hash and source/calibration provenance. `results/paper-summary.csv` and `paper-runs.csv` contain policy and per-run measurements. See [METHOD.md](METHOD.md), [PROTOCOL.md](PROTOCOL.md) and [REPORT.md](REPORT.md) for mechanism, design and evidence.

From this directory, use `../venv/bin/python scripts/validate.py` to check saved results. The root README gives environment setup and the complete analysis pipeline. Collection/training commands overwrite configured artifacts; run them in a separate working copy.

All ten simulated nodes are instruction-emulated Z1 motes. The gateway executes on the host, pausing simulated time during inference. Firmware images, raw logs and accepted scenario identifiers are preserved for provenance. The slow-evidence ablation retains the GRU. Host alarms support investigation and helper selection, not host-process containment.
