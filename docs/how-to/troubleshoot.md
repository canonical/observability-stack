# Troubleshoot

## High resource usage

### Attempting to scrape too many logs?

Inspect the list of files opened by otelcol and their size.

```bash
juju ssh ubuntu/0 "sudo lsof -nP -p $(pgrep otelcol)"
```

You should see entries such as:

```
COMMAND   PID USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
otelcol 45246 root   46r      REG                8,1  11980753    3206003 /var/log/syslog
otelcol 45246 root   12r      REG                8,1    292292    3205748 /var/log/lastlog
otelcol 45246 root   30r      REG                8,1    157412    3161673 /var/log/auth.log
otelcol 45246 root   16r      REG                8,1     96678    3195546 /var/log/juju/machine-lock.log
otelcol 45246 root   45r      REG                8,1     77200    3205894 /var/log/cloud-init.log
otelcol 45246 root   35r      REG                8,1     61211    3205745 /var/log/dpkg.log
otelcol 45246 root   25r      REG                8,1     29037    3205893 /var/log/cloud-init-output.log
otelcol 45246 root   18r      REG                8,1      6121    3205741 /var/log/apt/history.log
otelcol 45246 root   15r      REG                8,1      1941    3206035 /var/log/unattended-upgrades/unattended-upgrades.log
otelcol 45246 root   17r      REG                8,1       474    3183206 /var/log/alternatives.log
```

Compare the total size of logs to the available memory.