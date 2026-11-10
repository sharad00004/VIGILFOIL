# Combined IoT security architecture: compact live study

**The combined architecture was implemented and tested in closed loop in Cooja.** The gateway consumes actual authenticated Z1 observations, runs host detection and network evidence/repair decisions, and sends authenticated UDP queries and repair grants that execute on the motes. This report covers 42 accepted final runs and 4 source/calibration runs; bring-up attempts are excluded.

The combined system detected 4/4 configured host-misuse episodes. Its two complete benign scenarios produced 322/2074 alarmed scored observations. Sparse-burst coverage was 7/10. An episode-level hit must not be interpreted as coverage of every burst. Pre-attack warnings are separately recorded; an already-active warning is not evidence of a new onset detection.

## Comparison and ablation table

Each row aggregates the same six deployment/context cells. PDR is unique delivered genuine application work divided by all offered work, including blocked/unreachable offers. Worst-source PDR is calculated per run then averaged. Communication is actual attempted application payload, including mandatory host/resource reports, periodic source-work reports, queries/replies, authorization and repair copies. It is not PHY airtime, energy or a cap on adversarial traffic.

| Policy | Runs | Mean delivery % | Mean worst-source % | Mean defense payload B | Host episodes hit | Benign alarms/scored | Sparse bursts covered |
|---|---:|---:|---:|---:|---:|---:|---:|
| Combined | 6 | 98.37 | 94.19 | 133901 | 4/4 | 322/2074 | 7/10 |
| Network controller | 6 | 98.03 | 91.92 | 132095 | N/A | N/A | N/A |
| CIPHER-style AE | 6 | 98.01 | 92.43 | 132137 | 0/4 | 58/1936 | 0/10 |
| CONTRAST-style AE | 6 | 97.93 | 92.35 | 132261 | 0/4 | 40/1636 | 0/10 |
| Without work context | 6 | 97.63 | 90.31 | 135553 | 4/4 | 380/2090 | 10/10 |
| Without action accounting | 6 | 98.42 | 94.99 | 134725 | 4/4 | 326/2083 | 7/10 |
| Without slow evidence | 6 | 98.24 | 92.94 | 132802 | 1/4 | 195/2068 | 3/10 |

Pooled host-observation metrics at the frozen operating points follow. These samples are correlated; sparse-episode quiet periods and recovery tails retain the declared labels. Network-only has no operational host detector.

| Policy | Precision % | Recall % | F1 | Observation FPR % |
|---|---:|---:|---:|---:|
| Combined | 21.61 | 78.21 | 0.339 | 11.03 |
| CIPHER-style AE | 0.00 | 0.00 | 0.000 | 1.85 |
| CONTRAST-style AE | 0.00 | 0.00 | 0.000 | 1.80 |
| Without work context | 22.77 | 100.00 | 0.371 | 13.17 |
| Without action accounting | 20.72 | 78.21 | 0.328 | 11.62 |
| Without slow evidence | 8.52 | 12.88 | 0.103 | 5.35 |

“Without slow evidence” removes the residual accumulator; the GRU remains. All ablations retain the combined model’s frozen preprocessing, weights and thresholds; they are component removals, not separately optimized replacement systems. Network-controller runs retain equal telemetry instrumentation (the HMA output is recorded in shadow mode and does not control actions; its shadow alarms are not operational detector results) to isolate use of host evidence; this does not estimate the minimum-cost earlier controller with its host channel removed.

## Paired effects

These are descriptive paired changes over six cells, clustered in only two deployment blocks. No narrow confidence interval or general statistical superiority is claimed.

| Comparator | Combined delivery difference (pp), mean [min,max] | Combined payload saving %, mean [min,max] |
|---|---:|---:|
| Network controller | +0.336 [-0.600,+1.263] | -1.38 [-3.11,+0.83] |
| CIPHER-style AE | +0.356 [-0.659,+1.263] | -1.35 [-3.11,+0.83] |
| CONTRAST-style AE | +0.436 [-0.480,+1.263] | -1.26 [-3.11,+0.83] |
| Without work context | +0.734 [-0.480,+3.597] | +1.23 [-1.31,+3.37] |
| Without action accounting | -0.048 [-0.168,+0.000] | +0.61 [-0.23,+2.26] |
| Without slow evidence | +0.127 [-0.600,+1.263] | -0.86 [-3.11,+0.83] |

Negative payload saving means the combined system used more communication. Delivery improvements or losses must be read with their per-case values in paper-runs.csv; averages cannot establish benign-service preservation.

## Combined system by condition

| Seed/layout | Context | Delivery % | Worst-source % | Defense B | Host onset delay s | Non-recovery benign alarms | Sparse bursts covered | Actual malicious drops |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| 1151/bypass | benign | 97.90 | 95.97 | 137628 | N/A | 161 | N/A | 0 |
| 1151/bypass | mixed | 98.65 | 89.39 | 129268 | 41.09 | 0 | N/A | 12 |
| 1151/bypass | sparse_loss | 97.66 | 95.43 | 137920 | 36.19 | 69 | 4/5 | 3 |
| 1152/grid | benign | 98.32 | 93.06 | 135880 | N/A | 161 | N/A | 0 |
| 1152/grid | mixed | 99.41 | 95.45 | 126084 | 18.17 | 0 | N/A | 0 |
| 1152/grid | sparse_loss | 98.26 | 95.83 | 136624 | 129.14 | 174 | 3/5 | 0 |

Actual forwarding attack exposure depends on whether the configured relay carries transit traffic. A case with zero malicious drops is not evidence of forwarding-attack protection; it remains a valid host-misuse test. No such case is excluded from the tables.

Onset delay is root alarm global time minus the first actual ORACLE_HOST execution time. Oracle events are used only by this independent evaluation, never by the gateway. Sparse alarm coverage counts an alarm during execution or within 15 source-seconds of a burst’s last execution; an existing alarm counts as coverage, not a new detection. Source-clock nominal delays, pre-attack target warnings, warnings within 15 seconds before actual execution, and post-attack tails are also retained in runs.json. A near-zero delay for a policy already warning before the attack must not be interpreted as fast discrimination of that attack.

## What was integrated

- All ten simulated nodes use actual instruction-emulated Z1 firmware, including the radio root. Arithmetic workloads, RPL traffic, packet dropping, resource counters, signatures, queries, grants, source redirection and helper forwarding execute.
- A host gateway ports the earlier source-work/receipt/lease controller and runs the pretrained host-derived host predictor, GRU and classifier. Host warnings raise query priority and exclude suspected helpers. Host evidence alone does not disconnect a device.
- Root verifies HMAC/session/sequence on host reports; authenticates network messages; gateway validates network report freshness, nonce, count and action scope. Source-work reports retain original/repair/redirect counts and lease identities.
- Decisions reserve at most480 B per 10-second decision, with mandatory reporting counted separately. Actual command sequence, authenticated payload, helper forwarding and offer/receipt conservation are independently audited.
- Root commands are queued and transmitted at 125 ms polling intervals. Inference/bridge wall time is outside simulation time; this is not a real-time deployment qualification.

## Models, supervision and protocol

Source 1111/1112 uses complete benign runs for resource prediction and AE fitting; 1113/1114 is benign-only calibration. Final 1151/bypass/target 2 and 1152/grid/target 3 were excluded until freezing. Each has benign authorized mixed activity/loss; 250-round hidden CPU plus selective forwarding; and 1,000-round 4 s/60 s CPU bursts plus legitimate mixed traffic, selective forwarding and 0.85 nominal reception. Each run lasts 900 s, application offers 180–840 s, configured attacks 400–700 s and root-authorized work 300–780 s.

The combined model retains pretrained host supervised GRU/classifier weights; its resource predictor and benign thresholds are recalibrated on this rig. CIPHER-style uses correlation-grouped LSTMs(width2), reconstruction over 18 available fields, window 16, 250 epochs, Adam 0.05, batch 32. CONTRAST-style uses CPU/TX LSTM(width8), window 32, 200 epochs, Adam 0.001, batch 256. Both fit benign-only new sources and use three-of-five thresholds above complete benign calibration maxima. The original CIPHER/CONTRAST distributed frameworks, original full feature schemas and original long-duration conditions are not reproduced by this compact panel. Their adaptations are inserted into exactly the same gateway controller. Prior reproduction provenance: ../baselines/README.md.

The comparison therefore measures these implemented adaptations at the declared settings. Different supervision and feature access prevent a claim that an original benign-only published framework is generally inferior. Source-only minmax/benign predictor fitting, development-only calibration, fixed final settings and whole deployment splits avoid row/window leakage.

Gateway source provenance: the model hash/timestamp was recorded before final runs. Firmware source/binary hashes are checked per run. The gateway source hash was recorded after completion; independent saved-model replay reproduced recorded actions. A pre-run gateway-source hash was not recorded by the accepted training process.

## Paper claim boundaries

The implemented research direction is joint accounting for authorized workload and authorized defensive actions before spending evidence/repair resources. Whether it improves the complete trade-off is determined by the paired table, including any cost increase or service loss. A successful integration is a deliverable; it does not by itself establish a new algorithm or literature-wide novelty.

- Only two deployment blocks and one seed per topology are used. Seed and topology are confounded. This is a compact varied study, not a robustness or significance certificate.
- Honest isolated resource measurement and benign startup calibration remain assumptions. No TEE/attestation, compromised-root tolerance or full-host-forgery protection is implemented.
- Host alarms do not stop unauthorized CPU execution. The implemented response investigates evidence and repairs delivery; it is not host-process containment.
- Optional optional task-integrity task-integrity/fallback is not included in this study. FIT hardware testing remains deferred.
- Mandatory host-telemetry cost is charged to every policy. Separate deployment ablation would be needed to measure removal of that instrumentation itself.
- The protocol bounds admitted defense payload, not physical energy, retransmissions or all network load. Keys are laboratory fixtures, not a deployed key-management system.
- Original network-priority weights were fitted on the earlier native rig and remain frozen. Transfer limits are part of the test.

## Reproducible outputs

- results/paper-summary.csv and paper-runs.csv: full comparison and case-level tables.
- results/comparison-table.tex: LaTeX table.
- results/paired-differences.json: all matched differences.
- results/runs.json: detection, recovery, service, costs, genuine-work accounting, helper and command counts.
- results/figures/: exportable PNG/PDF figures.
- results/training-freeze.json and models/combined.pkl: frozen artifact and source/calibration settings.
- configs/final.json, scenarios/, logs/: exact fresh runs and raw evidence.
- results/validation.json and manifest.json: final verification and hashes.
