# Network controller

`weights.json` contains the frozen network-priority model used by the integrated gateway. The executable receipt/work/lease accounting and action-admission logic is in `../combined_system/scripts/gateway.py`.

The controller checks source-work counts against deduplicated application receipts and root-authorized redirection. Unknown provenance does not justify lowering the expected original packet count. A 480-byte reservation per 10-second decision bounds admitted discretionary query/repair payload. Mandatory telemetry and physical radio overhead are outside that reservation.

The weights transfer from the earlier network rig without fitting on the final deployment blocks. Transfer limits are part of the reported experiment.
