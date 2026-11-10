# Combined method for the compact paper study

The system couples host-resource evidence with an existing network evidence/repair controller. It is not a single jointly trained neural network. A host gateway performs learning/inference and policy decisions; ten emulated Z1 motes perform actual application work, resource measurement, authenticated communication and delivery repair.

For each device, the monitor reports cumulative CPU/TX/RX ticks, RPL activity, own/transit packet counters, sequence and source time. The root authenticates the 84-byte message and rejects a wrong session or non-increasing sequence. The gateway computes causal differences only from received messages. A source permission is root-signed and bounded in work/expiry; permissions and observations are separate facts. Source IDs index state and attribution, not numerical classifier predictors.

The benign resource predictor separates authorized work from network-related processing:

    expected CPU = benign_network_predictor(context) + alpha * authorized_work
    residual = measured CPU - expected CPU

The coefficient and network predictor fit only benign source deployments. Expected TX/RX are also predicted. The source-trained discriminator receives nine fields: observation timing/gaps, signed CPU/TX/RX residuals, and relative residuals. A 16-unit GRU uses eight received observations; its score is averaged with a histogram-gradient-boosting classifier. The original pretrained host supervised head is retained; only benign resource prediction and calibration adapt to this integrated rig.

A second lane accumulates standardized CPU evidence. Its noise scale depends on forwarding-rate bins with a relative expected-CPU floor. After eight-observation warm-up, the first 20 residuals establish a bounded initial reference. With source interval dt, time constant tau=120 s and allowance k=1:

    z = clip(residual / sigma - initial_reference, -3, 5)
    S = max(0, exp(-dt/tau) * S + (z-k) * clipped_dt/5)
    S = min(S, 2 * threshold)

The neural lane triggers when at least three of five scores exceed its threshold. Either lane can issue a 30-second persistent warning. Thresholds exceed the maximum complete benign-calibration three-of-five/neural or residual score, with fixed margins. The cold-start reference assumes benign initial operation; it is not proof against poisoned startup. Missing/stale/untrusted observations cannot certify a host as safe.

At each 10-second gateway decision, the network controller uses signed source-work reports and actual deduplicated application receipts. For a recently closed source epoch it retains offered O, submitted U, blocked B, original attempts P, repair R, redirected D and a lease identifier. It validates O=U+B and representable copy/union constraints. A response-adjusted expected original count P is usable only when root-issued lease history supports the reported redirection; otherwise the expectation stays U. Unknown provenance cannot justify reducing an expectation. Successful repaired delivery does not establish that the original path is safe.

Per-source priority is:

    10 * unexplained_original_delivery_deficit
    + 20 * current_host_warning
    + 1  * (network_priority_alarm AND missing_current_work_evidence)

Host warnings can prioritize a query even without a delivery deficit. Repair requires a delivery deficit plus source-work evidence. A helper must be an advertised neighbor with a recent, acyclic path to the root that avoids the source; observed forwarding must not show a large deficit; a current host warning also disqualifies a helper. Selection relies on advertised/observed evidence, not independent localization or hardware-protected truth.

Each decision admits at most 480 bytes of discretionary payload reservations. Query/reply reserves 136 bytes; a two-copy repair lease reserves 248 bytes (120 control + 72 source-copy + 56 helper-copy). Mandatory periodic source-work/host reports and one workload permission are charged separately in measured communication. The cap is not a PHY-airtime or adversarial-ingress bound. Full source-work reports are 108 bytes; application originals 28 bytes, source repair copies 36 bytes and helper forwards 28 bytes. Root/source/helper enforce existing authentication, nonces, scopes and quotas.

Commands are cryptographically generated at the gateway, queued at the Z1 root and transmitted over UDP. The simulation bridge synchronously passes root records and command bytes and does not inspect attacker oracle logs. Actual command polling/radio delays are included; inference wall time pauses simulated time. CPU misuse continues after a warning: this implementation investigates and repairs network delivery rather than killing processes or claiming host containment.

Ablations retain frozen settings: without work context, root permissions are not passed to the resource predictor; without action accounting, original-path expectations are not reduced for valid redirection; without slow evidence, the residual accumulator cannot trigger (the GRU stays). The network-only control ignores shadow host warnings in all actions. CIPHER/CONTRAST architecture adaptations replace the host warning generator while keeping the controller and instrumentation fixed. Detailed exact parameters and distinct supervision are in PROTOCOL.md and training-freeze.json.
