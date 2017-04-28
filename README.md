# oms-agent-for-linux BOSH release

This release provides an [OMS Agent](https://github.com/Microsoft/OMS-Agent-for-Linux) job for sending VM operational data (Syslog, Performance, Alerts, Inventory) to [Azure OMS Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-overview).

## Get started

### Create an OMS Workspace in Azure

* [Get started with Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-get-started)

### Upload release

To use this bosh release, first upload it to your bosh director:
```
bosh upload release https://github.com/Azure/oms-agent-for-linux-boshrelease/releases/download/v1/oms-agent-for-linux.tgz
```

### Deploy as a BOSH addon

To deploy OMS Agent on all instances in your CloudFoundry deployment, specify the job as an addon in [runtime config](https://bosh.io/docs/runtime-config.html). Do not specify the job as part of your deployment manifest if you are using the runtime config.

If no rsyslog config is specified, the [default rsyslog config](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/installer/conf/rsyslog.conf) of omsagent will be used.
```
# runtime.yml
---
releases:
- name: oms-agent-for-linux
  version: 1
addons:
- name: omsagent
  jobs:
  - name: omsagent
    release: oms-agent-for-linux
  properties:
    # Get the OMS workspace ID and key from OMS Portal
    oms:
      workspace_id: CHANGE_ME
      workspace_key: CHANGE_ME
    # Set the rsyslog config as needed, optional
    rsyslog:
      selector_list:
      - user.*      
      - syslog.*
      port: 25224
      protocol_type: udp
```

Deploy the runtime config:
```
bosh update runtime-config runtime.yml
bosh deploy
```
