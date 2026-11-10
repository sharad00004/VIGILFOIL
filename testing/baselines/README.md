# Detector baselines

`models/paper_detectors.py` contains the neural building blocks used by the matched CIPHER and CONTRAST adaptations. Fitting is in `../combined_system/scripts/train_combined.py`; the gateway's detector adapter runs the resulting models from the combined artifact.

| Adaptation | Available inputs and fitting |
| --- | --- |
| CIPHER | Correlation-grouped LSTM reconstruction, 18 fields, width 2, window 16, 250 epochs, Adam learning rate 0.05, batch size 32 |
| CONTRAST | CPU/TX LSTM reconstruction, width 8, window 32, 200 epochs, Adam learning rate 0.001, batch size 256 |

Both fit benign integration sources and calibrate three-of-five warnings above complete benign calibration maxima. They share the full system's network transport, instrumentation, controller and discretionary budget.

These are architectural implementations adapted to the integrated feature schema and gateway. The original distributed frameworks, complete original features and long-duration deployments are not reproduced here. VIGILFOIL retains a supervised GRU/classifier head, while these autoencoders fit benign-only data. Results compare the declared implementations under different supervision; they do not rank the original published systems generally. Bibliographic details are in `../../paper-overleaf/references.bib`.
