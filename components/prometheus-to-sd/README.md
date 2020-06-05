# Prometheus To StackDriver Deployment Notes 

This document is to provide speacial instruction for prometheus-to-sd deployment for Open Banking SRE team.

## Build images from local

Please follow the below steps if you want to trigger cloudbuild from your local.

1. Login to your GCP build project where host your CloudBuild
2. Use this worker pool `anz-cx-cloudbuild-dev-5ef683/custom-workers-dev-pool` which has the connectivity to ANZ artifactory.

Here is an example run.

```
gcloud builds submit --config images/cloudbuild.yaml --no-source --substitutions _VERSION=v0.9.2,_PLATFORM_REGISTRY=asia.gcr.io/anz-cx-ob-build-np-de5569,_WORKER=anz-cx-cloudbuild-dev-5ef683/custom-workers-dev-pool
```