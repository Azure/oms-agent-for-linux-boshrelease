# oms-agent-for-linux BOSH release

This release provides an [OMS Agent](https://github.com/Microsoft/OMS-Agent-for-Linux) job for sending VM operational data (Syslog, Performance, Alerts, Inventory) to [Azure OMS Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-overview).
> This is currently a preview release. 

## Prerequisites

### Create an OMS Workspace in Azure

* [Get started with Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-get-started)

## Get started

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

## View in OMS Portal

### Import OMS View

Operators can use OMS portal to visualize the logs and metrics collected by OMS Agent. From the main OMS Overview page, go to **View Designer** -> **Import** -> **Browse**, select the [Syslog and Perf.omsview](./docs/omsview/Syslog%20and%20Perf.omsview) file, and save the view. Now a **Tile** will be displayed on the main OMS Overview page. Click the **Tile**, it shows visualized metrics.

Operators can customize the view or create new views through **View Designer**.

## Additional reference

To collect metrics and logs from the [Loggregator](https://docs.cloudfoundry.org/loggregator/architecture.html) Firehose to [OMS Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/), please refer to [oms-log-analytics-firehose-nozzle](https://github.com/Azure/oms-log-analytics-firehose-nozzle).
