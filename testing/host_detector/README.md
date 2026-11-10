# Host detector

`models/engine.py` implements benign resource prediction, causal residual features and the GRU/classifier warning engine. `models/evidence.py` implements persistent residual evidence; `models/stream.py` transforms received telemetry into per-device causal observations.

`models/hma_guard_v3.pkl` supplies the pretrained supervised head used during integration fitting. The combined artifact is in `../combined_system/models/combined.pkl`. The integration fitting code preserves the supervised head and refits resource expectations and calibration thresholds on separate benign deployments.

The `models` Python import namespace is retained because the serialized artifacts reference it. Earlier host-head training data and development campaigns are outside this repository. The supplied code/artifacts support inference, replay and integration refitting; they do not constitute complete supervised head training from scratch.
