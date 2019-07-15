# oms-agent-for-linux BOSH release

This release provides an [OMS Agent](https://github.com/Microsoft/OMS-Agent-for-Linux) job for sending VM operational data (Syslog, Performance, Alerts, Inventory) to [Azure OMS Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-overview).

## Prerequisites

### Create an OMS Workspace in Azure

* [Get started with Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-get-started)

## Get started

To deploy the OMS agent, you will need to install BOSH CLI on your Ops Manager Director and target it. For how to setup it, please follow the document [here](https://docs.pivotal.io/pivotalcf/2-0/customizing/trouble-advanced.html).

### 1. Upload release

To use this bosh release, first upload it to your BOSH Director:

```
# BOSH CLI v1
bosh upload release https://github.com/Azure/oms-agent-for-linux-boshrelease/releases/download/v1.9.0-0/oms-agent-for-linux-boshrelease-1.9.0-0.tar.gz

# BOSH CLI v2
bosh2 upload-release https://github.com/Azure/oms-agent-for-linux-boshrelease/releases/download/v1.9.0-0/oms-agent-for-linux-boshrelease-1.9.0-0.tar.gz
```

### 2. Deploy as a BOSH addon

To deploy OMS Agent on all instances in your CloudFoundry deployment, specify the job as an addon in [runtime config](https://bosh.io/docs/runtime-config.html).

First, create a new file `runtime.yml` and paste all the following content into it.

```
# runtime.yml
---
releases:
- name: oms-agent-for-linux
  version: 1.9.0-0
addons:
- name: omsagent
  jobs:
  - name: omsagent
    release: oms-agent-for-linux
  exclude:
    stemcell:
    - os: windows2012R2
    - os: windows2016
    - os: windows2019
    - os: windows1803
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

After replace placeholders in the file with id and key of your OMS workspace, deploy the runtime config with the following commands.

```
# BOSH CLI v1
bosh update runtime-config runtime.yml
bosh deploy

# BOSH CLI v2
bosh update-runtime-config runtime.yml
bosh deploy
```

### Tips

* Recreate VMs when deploy then runtime-config will help to avoid potential problems.
* DO NOT specify the job as part of your deployment manifest if you are using the runtime config.
* If no `rsyslog` config is specified, the [default rsyslog config](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/installer/conf/rsyslog.conf) of OMS Agent will be used.
* Try delete leading spaces and input them by yourself if error `Incorrect YAML structure` occurs when updating `runtime-config` with `runtime.yml` copied from above.

## View in OMS Portal

### Import OMS View

Operators can use OMS portal to visualize the logs and metrics collected by OMS Agent. From the main OMS Overview page, go to **View Designer** -> **Import** -> **Browse**, select the [Syslog and Perf.omsview](./docs/omsview/Syslog%20and%20Perf.omsview) file, and save the view. Now a **Tile** will be displayed on the main OMS Overview page. Click the **Tile**, it shows visualized metrics.

Operators can customize the view or create new views through **View Designer**.

## Additional reference

To collect metrics and logs from the [Loggregator](https://docs.cloudfoundry.org/loggregator/architecture.html) Firehose to [OMS Log Analytics](https://docs.microsoft.com/en-us/azure/log-analytics/), please refer to [oms-log-analytics-firehose-nozzle](https://github.com/Azure/oms-log-analytics-firehose-nozzle).
