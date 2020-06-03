# Prometheus Deployment Notes 

This document is to provide speacial instruction for prometheus deployment for Open Banking SRE team.

## Build images from local

Please follow the below steps if you want to trigger cloudbuild from your local.

1. Login to your GCP build project where host your CloudBuild
2. Use this worker pool `anz-cx-cloudbuild-dev-5ef683/custom-workers-dev-pool` which has the connectivity to ANZ artifactory.

Here is an example run.

```
gcloud builds submit --config images/cloudbuild.yaml --no-source --substitutions _PROMETHEUS_VERSION=v2.11.1,_PROMETHEUS_ALERT_VERSION=v0.20.0,_STACKDRIVER_SIDECAR_VERSION=0.6.2,_PLATFORM_REGISTRY=asia.gcr.io/anz-cx-ob-build-np-de5569,_WORKER=anz-cx-cloudbuild-dev-5ef683/custom-workers-dev-pool
```


## Stackdriver Prometheus Sidecar

`stackdriver-prometheus-sidecar` is injected to `prometheus` pod to push prometheus data to stackdriver. A configure file is also created at `customs/prometheus-label-mapping.yaml` to rename the prometheus labels to stackdriver recognised naming convention. Thoese configurations are required to store in Kubernetes ConfigMap and mounted at `/mapping` volume to consume. The `Makefile` is already taking care of this task.

Here is an example.

```
metric_renames:
  - from: instance:node_cpu:ratio
    to: instance_node_cpu_ratio
```

## Custom Persistent Volumes

In order to keep the data even after the pods deletion, custom persistent volume claims are used for both prometheus and prometheus-alertmanager. The configuration is defined at `customs/prometheus-pvc.yaml`.

Here is an example for `ob-stg` cluster.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-alertmanager
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```
