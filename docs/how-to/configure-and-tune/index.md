(configure-and-tune)=

# Configure and tune

Fine-tune telemetry collection, alerting rules, and data handling.

## Alert management

Control which alert rules are active and keep them in sync with your Git
repository.

```{toctree}
:maxdepth: 1

Sync alert rules from Git <sync-alert-rules-from-git>
Disable built-in charm alert rules <disable-charmed-rules>
```

## Telemetry volume & filtering

Right-size the data flowing through COS by measuring and filtering at
collection time.

```{toctree}
:maxdepth: 1

Evaluate telemetry volume <evaluate-telemetry-volume>
Selectively drop telemetry using scrape config <selectively-drop-telemetry-scrape-config>
Selectively drop telemetry using opentelemetry-collector <selectively-drop-telemetry-otelcol>
```

## Data privacy

Strip personally identifiable or sensitive information before it reaches
storage.

```{toctree}
:maxdepth: 1

Redact sensitive data <redact-sensitive-data>
customize-storage-options
reference-k8s-cloud-for-cos
```
