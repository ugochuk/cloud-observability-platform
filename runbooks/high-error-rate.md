# High Error Rate Runbook

## Trigger

Use this runbook when the checkout API error ratio exceeds its alert threshold or an error-budget burn alert fires.

## Immediate assessment

1. Confirm the alert is current and identify its firing duration, service, environment, and affected route.
2. Compare request rate, HTTP 5xx ratio, p95 latency, pod restarts, CPU, memory, and dependency failures over the same time window.
3. Check recent deployments, configuration changes, feature flags, and infrastructure events.
4. Determine whether impact is isolated to one pod, availability zone, route, dependency, or client cohort.

## Evidence collection

- Capture the alert start time and dashboard time range.
- Save representative trace IDs and correlated log queries.
- Record the deployed version and Kubernetes rollout status.
- Note dependency latency and failure rates.
- Distinguish confirmed findings from hypotheses.

## Mitigation options

- Roll back the latest release when timing and telemetry support a regression.
- Remove an unhealthy pod only after confirming replicas and disruption budgets can absorb the action.
- Scale the deployment when saturation is demonstrated and dependencies can handle added load.
- Apply a documented feature flag or traffic-control mechanism when the affected path is isolated.
- Escalate to the dependency owner when trace evidence shows an upstream or downstream failure.

## Validation

1. Verify the error ratio and latency have returned to their normal ranges.
2. Confirm new requests succeed across multiple replicas.
3. Ensure the alert resolves and no secondary alert remains active.
4. Monitor through at least one full evaluation window before declaring recovery.

## Follow-up

- Document the timeline, customer impact, supporting evidence, root cause if proven, and corrective actions.
- Add or tune telemetry only when the incident exposed a specific blind spot.
- Update the SLO or alert threshold through review rather than during active response.
