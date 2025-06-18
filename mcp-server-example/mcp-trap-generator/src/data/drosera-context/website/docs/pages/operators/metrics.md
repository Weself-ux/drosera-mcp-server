---
sidebar_position: 5
title: Monitoring
---

# Monitoring 📊

The Operator Node can be configured to send Opentelemetry metrics, logs and traces to an OpenTelemetry Collector. The OpenTelemetry Collector can then be configured to send the metrics to a variety of backends such as Prometheus, Grafana, or other monitoring tools.

To configure the Operator Node to send metrics to an OpenTelemetry Collector, you can use the following CLI arguments:

```bash
drosera-operator node --otel-export-endpoint <endpoint> --otel-export-metadata <metadata> --otel-resource-attributes <attributes>
```

Description of the CLI arguments can be found on the configuration section of the [Run the Node](/operators/run-operator#configuration) page.

## Logging

If running the Operator Node as a systemd service, all logs will be persisted on the machine and will consume storage space. To avoid this, you can configure the otel export endpoint to send logs to a remote logging service and send the stdout logs to `/dev/null` when starting the the Operator Node. This will prevent logs from being stored on the machine.

```
drosera-operator node --otel-export-endpoint <endpoint> --log-output stdout > /dev/null
```

## Metrics

The Operator Node collects the following metrics:

- `drosera_process_cpu_usage`: The CPU usage of the Operator Node process
- `drosera_process_disk_space_usage`: The disk space usage of the Operator Node process
- `drosera_process_memory_usage`: The memory usage by the Operator Node process
- `total_memory`: The total memory available on the system
- `execute_trap_duration`: The duration of time it takes to execute a Trap
- `attestation_consensus_duration`: The duration of time it takes to reach consensus on an attestation of a Trap result
- `connected_peer_count`: The number of peers sending messages to the Operator Node
- `expected_peer_count`: The number of peers the Operator Node should be receiving messages from
- `eth_balance`: The balance of the Operator Node's Ethereum account

## Resource Attributes

Attributes can be added to all collected OpenTelemetry metrics, traces and logs. For example, to add the operator address and name to all metrics, traces and logs, you can use the `--otel-resource-attributes` CLI argument:

```bash
drosera-operator node --otel-resource-attributes "operator_address=0x530719E8fe572C909945Deb045e491865FF2bab0,operator_name=cobra"
```

# Monitoring Stack

To visualize the metrics, logs, and traces exported by the Operator Node, you can use the following monitoring stack: https://github.com/drosera-network/operator-monitoring-stack

It is a docker-compose stack that includes Grafana, Prometheus, Loki, and Tempo.
