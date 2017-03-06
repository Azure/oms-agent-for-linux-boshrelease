# oms-agent-for-linux BOSH release

This release provides an [OMS Agent](https://github.com/Microsoft/OMS-Agent-for-Linux) job for sending VM operational data (Syslog, Performance, Alerts, Inventory) to [Azure OMS Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-overview).

## Get started

### Create an OMS Workspace in Azure

* [Get started with Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-get-started)

### Upload release

To use this bosh release, first upload it to your bosh director:
```
bosh target BOSH_HOST
git clone https://github.com/Azure/oms-agent-for-linux-boshrelease.git
cd oms-agent-for-linux-boshrelease
bosh upload release releases/oms-agent-for-linux/oms-agent-for-linux-1.yml
```

### Deploy as a BOSH addon

To deploy OMS Agent on all instances in your CloudFoundry deployment, specify the job as an addon in [runtime config](https://bosh.io/docs/runtime-config.html). Do not specify the job as part of your deployment manifest if you are using the runtime config.
```
# runtime.yml
---
releases:
- name: oms-agent-for-linux
  version: latest
addons:
- name: omsagent
  jobs:
  - name: omsagent
    release: oms-agent-for-linux
  properties:
    oms: # Get the OMS workspace ID and key from OMS Portal
      workspace_id: CHANGE_ME
      workspace_key: CHANGE_ME
    rsyslog: # Modify the config as needed, if no rsyslog.config is specifed, the default rsyslog config of omsagent will be used
      config:
      - user.*      
      - syslog.*
```

Deploy the runtime config:
```
bosh update runtime-config runtime.yml
bosh deploy
```
