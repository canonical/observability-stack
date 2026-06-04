---
myst:
  html_meta:
    description: "Configure the Alertmanager charm to send COS Lite alerts to external receivers such as email, Telegram, Pushover, and PagerDuty."
---

# How to integrate Alertmanager with external receivers

This guide shows how to configure the Alertmanager charm to send COS Lite alerts to external notification services. The examples cover email, Telegram, Pushover, and PagerDuty, but the configuration pattern is similar for other [Alertmanager receiver integrations](https://prometheus.io/docs/alerting/latest/configuration/#receiver-integration-settings).

## Prerequisites

- A COS Lite deployment with the `alertmanager` charm. If you have not deployed COS Lite yet, follow one of the {ref}`COS Lite tutorials <tutorial>`.
- Credentials and receiver details for each external notification service you want to configure.

## Step 1: Gather email receiver details

To send alerts by email, gather:

1. SMTP server address and port.
2. SMTP authentication username and password.
3. One or more recipient email addresses for the `to` field.
4. One sender email address for the `from` field.

## Step 2: Gather Telegram receiver details

To send alerts to Telegram, you need a Telegram bot API token and a chat ID. Alertmanager uses these values in a [`telegram_config`](https://prometheus.io/docs/alerting/latest/configuration/#telegram_config).

### Create a Telegram bot

1. Open Telegram and find **BotFather**.
2. Send `/newbot` and follow the prompts.
3. Save the API token returned by BotFather.

### Get the Telegram chat ID

1. Add your bot to a group chat.
2. Send a test message in the group chat that starts with `/`.
3. Request updates from the bot API:

   ```bash
   curl "https://api.telegram.org/bot<bot-api-token>/getUpdates"
   ```

4. Find the chat ID in the JSON response.
5. If the response is empty, remove and re-add the bot to the group chat, send another test message, and retry the request.

## Step 3: Gather Pushover receiver details

To send alerts to Pushover, you need a Pushover user key and application token. Alertmanager uses these values in a [`pushover_config`](https://prometheus.io/docs/alerting/latest/configuration/#pushover_config).

1. Sign up for a Pushover account, if you do not already have one.
2. Log in to your Pushover dashboard.
3. Create an application and save the generated API token.
4. Save your user key from the Pushover dashboard.

## Step 4: Gather PagerDuty receiver details

Alertmanager can send alerts to PagerDuty through a service integration or through Event Orchestration.

Use a **PagerDuty service integration** when you want Alertmanager to route alerts directly to a PagerDuty service. Use **Event Orchestration** when you want PagerDuty to apply additional routing logic before alerts reach services.

### Use a PagerDuty service integration

1. In PagerDuty, go to **Services** > **Service Directory**.
2. To use an existing service, select it, open the **Integrations** tab, and add an integration. To use a new service, create the service first.
3. Choose **Events API v2** or **Prometheus** as the integration type.
4. Save the integration and copy the integration key.

### Use PagerDuty Event Orchestration

1. Create the PagerDuty services that should receive alerts.
2. In PagerDuty, go to **Automation** > **Event Orchestration** and select or create an orchestration.
3. Create service routes for your target services.
4. Go to **Integrations** and copy the default integration key.

## Step 5: Create the Alertmanager configuration

Create a file named `alertmanager.yml` and replace the placeholder values with the receiver details from the previous steps:

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: telegram
  group_by:
    - juju_model_uuid
    - juju_application
    - juju_model
  continue: false
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  routes:
    - receiver: email
      group_wait: 10s
      matchers:
        - severity=~"critical|warning|none"
      continue: true
    - receiver: telegram
      group_wait: 10s
      matchers:
        - severity=~"critical|warning|none"
      continue: true
    - receiver: pushover
      group_wait: 10s
      matchers:
        - severity=~"critical|warning|none"
      continue: true
    - receiver: pagerduty_service
      group_wait: 10s
      matchers:
        - severity=~"critical|warning|none"
      continue: true
    - receiver: pagerduty_orchestration
      group_wait: 10s
      matchers:
        - severity=~"critical|warning|none"
      continue: true

receivers:
  - name: email
    email_configs:
      - to: "noble.numbat@ubuntu.com, jammy.jellyfish@ubuntu.com"
        from: hardy.heron@ubuntu.com
        smarthost: this-is-a-smtp-server.ubuntu.com:25
        auth_username: warty.warthog
        auth_password: SuperSecretPassword
        send_resolved: true
  - name: telegram
    telegram_configs:
      - bot_token: YOUR_TELEGRAM_BOT_TOKEN
        chat_id: YOUR_TELEGRAM_CHAT_ID
  - name: pushover
    pushover_configs:
      - user_key: YOUR_PUSHOVER_USER_KEY
        token: YOUR_PUSHOVER_TOKEN
  - name: pagerduty_service
    pagerduty_configs:
      - routing_key: YOUR_PAGERDUTY_SERVICE_INTEGRATION_KEY
  - name: pagerduty_orchestration
    pagerduty_configs:
      - routing_key: YOUR_PAGERDUTY_ORCHESTRATION_INTEGRATION_KEY
```

This example sends alerts with the `critical`, `warning`, or `none` severities to every configured receiver. Adjust the `routes` section if you want different alerts to go to different receivers.

Alertmanager supports more settings for email, Telegram, Pushover, and PagerDuty. For example, you can customize whether to send resolved alerts, select a Pushover device, or tune repeat intervals. For the complete list of options, see the [Alertmanager configuration documentation](https://prometheus.io/docs/alerting/latest/configuration/#receiver-integration-settings).

## Step 6: Create notification templates

Create a file named `templates.tmpl` to customize the notification text for Telegram and Pushover:

```text
{{ define "telegram.default.message" }}
{{ range .Alerts }}
*Alert:* {{ .Annotations.summary }}

*Description:* {{ .Annotations.description }}

*Severity:* {{ .Labels.severity }}
{{ end }}
{{ end }}

{{ define "pushover.default.message" }}
{{ range .Alerts }}
Alert: {{ .Annotations.summary }}
Description: {{ .Annotations.description }}
Severity: {{ .Labels.severity }}
{{ end }}
{{ end }}
```

These templates are intentionally simple so you can use them as a starting point. PagerDuty notifications are not customized through Alertmanager templates, but you can customize fields directly in the [`pagerduty_config`](https://prometheus.io/docs/alerting/latest/configuration/#pagerduty_config).

## Step 7: Apply the configuration

Apply the configuration files to the Alertmanager charm:

```bash
juju config alertmanager \
  config_file=@alertmanager.yml \
  templates_file=@templates.tmpl
```

Verify that Alertmanager returns to `active` status:

```bash
juju status alertmanager
```

If the charm reports a configuration error, check the Alertmanager unit logs for YAML or template validation errors:

```bash
juju debug-log --include alertmanager --replay
```

## Step 8: Test the receivers

COS Lite includes a watchdog alert that periodically fires and can be used to verify receiver delivery.

After applying the configuration:

1. Check the Pushover app for a watchdog notification.
2. Check the Telegram chat for a watchdog notification.
3. Check PagerDuty for incidents created by the configured service integration and orchestration integration.

If you configured Event Orchestration routes in PagerDuty, only services that match your orchestration rules receive incidents.
