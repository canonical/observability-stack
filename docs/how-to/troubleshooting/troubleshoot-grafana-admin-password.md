# Troubleshoot grafana admin password

Compare the output of:

- Charm action: `juju run graf/0 get-admin-password`
- Pebble plan: `juju ssh --container grafana graf/0 /charm/bin/pebble plan | grep GF_SECURITY_ADMIN_PASSWORD`
- Secret content: Obtain secret id from `juju secrets` and then `juju show-secret d6buvufmp25c7am9qqtg --reveal`

All 3 should be identical. If they are not identical,

1. Manually [reset the admin password](https://grafana.com/docs/grafana/latest/administration/cli/#reset-admin-password),
   `juju ssh --container grafana graf/0 grafana cli --config /etc/grafana/grafana-config.ini admin reset-admin-password pa55w0rd`
2. Update the secret with the same: `juju update-secret d6buvufmp25c7am9qqtg password=pa55w0rd`
3. Run the action so the charm updates pebble env: `juju run graf/0 get-admin-password`
