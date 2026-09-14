# AWS EKS Signal Loss Runbook

## Trigger

Use this runbook when CloudWatch, Amazon Managed Prometheus, or AWS X-Ray stops receiving expected telemetry from EKS.

## Triage

1. Establish the exact time each signal stopped and determine whether metrics, logs, and traces failed together.
2. Check the OpenTelemetry or ADOT Collector pod status, restarts, resource limits, and recent configuration changes.
3. Confirm IRSA role association and inspect authorization errors for CloudWatch, X-Ray, and AMP endpoints.
4. Check DNS resolution, security groups, network policies, NAT or VPC endpoints, and regional AWS service health.
5. Compare application health with telemetry health so an observability failure is not misclassified as an application outage.

## Validation

- Generate one controlled request containing a known correlation identifier.
- Verify the corresponding metric, log event, and X-Ray trace arrive.
- Confirm dashboards and alarms return to their expected state.
- Monitor through one complete collection and alarm-evaluation window.

## Evidence record

Document completed checks, supported conclusions, unvalidated hypotheses, mitigation actions, and any gap that requires a follow-up engineering change.
