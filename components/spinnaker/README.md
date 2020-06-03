# Spinnaker Dpeloyment 

This project is to deploy Spinnaker to GKE cluster via the recommended [Halyard](https://www.spinnaker.io/setup/install/halyard/) 

## Prerequisite

* [hal](https://www.spinnaker.io/setup/install/halyard)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)

Note: Spinnaker can be installed in various way but it is recommended to use `hal`*

## Execution

You can run `make` to review the usage. Please be aware of the following prerequisites before you deploy spinnaker:
* Your local `hal` version. You must use the same version as the installation to operate spinnaker cluster.
* Your current active project
* Your current active kubernetes context

```
Usage:
  make <target>
    gke.auth       	      Authenticate to the GKE cluster
    gcp.sa.create  	      Create spinnaker service account
    gcp.sa.delete  	      Delete spinnaker service account
    spinnaker.create	    Deploy spinnaker cluster
    spinnaker.connect	    Create port forwarding to connect to spinnaker cluster
    spinnaker.delete	    Delete spinnaker cluster
    hipstershop.create	  Create manifest artifact for hipstershop app deployment
    hipstershop.delete	  Delete manifest artifact

Misc
    help           	      Display help
```

* `gke.auth` - to retrieve the authentication token to connect to the cluster
* `gcp.sa.create` - to create spinnaker service account and bind the `role/storage.admin` role to this service account
* `gcp.sa.delete` - to delete the spinnaker service account and its associated policy
* `spinnaker.create` - to deploy the spinnaker cluster to GKE cluster (namespace: spinnaker)
* `spinnaker.connect` - to create port forwarding (UI port 9000, API port 8084)
* `spinnaker.delete` - to delete the spinnaker cluster from GKE cluster
* `hipstershop.create` - to create kubernetes deployment manifests and namespace
* `hipstershop.delete` - to delete kubernetes deployment manifests and namespace 

In addition, there are two multiple targets defined for "lazy" engineers like me:

* `create.all` - run `gcp.sa.create` and `spinnaker.create` 
* `delete.all` - run `gcp.sa.delete` and `spinnaker.delete` 

## Connect to Spinnaker

Once you see all pods are running. Please run `hal deploy connect` to start port forwarding and then you can access Spinnaker via `http://localhost:9000`.

If you don't have `hal` installed, you can run `make spinnaker.connect` to run the port forwarding. It is recommended to run in a seperated terminal window as the port forwardings are running as daemon processes.

## Hipstershop Deployment

### Spinnaker 

To follow Spinnaker deployment pattern, `kustomise` is used to combine all YAML files into a single file (a.k.a. artifact). The genereated artifact is then uploaded to `hipstershop` bucket. The following path must be configured in spinnaker pipeline. Please also ensure you tick `Use Default Atifact` and add this URL too. Otherwise you will run into `unexpected artifact` error.

```
gs://hipstershop/hipstershop-deployment.yaml
```

Please note that Cloud Pub/Sub is not setup so you have to manual run the pipeline once you build the latest artifact to GCS bucket.

### Manual

Alternatively, you can still manually deploy Hipstershop app by running the following command:

```
kubectl apply -f $<YOUR_REPO_HOME>/spinnaker/hipstershop/outputs/hipstershop-deployment.yaml
```

## Troubleshooting

### GCS bucket

The `hal` tool will create a regional GCS bucket starting with `spin-`. Please manually delete it after you run `hal deploy clean`. For example, `spin-bb8f0444-56ba-4f93-b413-2d20db810b46`.

### Stuck pods

You might sometimes get stuck in terminating `spin-deck` and `spin-redis` pods. In this case, you just need to ssh to the pod and kill the stucked processes.

### `spin-deck` - Kill all `apache2` processes.

```
www-data@spin-deck-6c8bd7bcb9-cj2vk:/opt/deck$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
www-data       1  0.0  0.0   2388   764 ?        Ss   00:48   0:00 /bin/sh -c docker/run-apache2.sh
www-data       7  0.0  0.0   2388  1564 ?        S    00:48   0:00 /bin/sh docker/run-apache2.sh
www-data      39  0.0  0.0   2388  1644 ?        S    00:48   0:00 /bin/sh /usr/sbin/apache2ctl -D FOREGROUND
www-data      47  0.0  0.1  45660  8796 ?        S    00:48   0:00 /usr/sbin/apache2 -D FOREGROUND
www-data      48  0.0  0.0 1250496 6652 ?        Sl   00:48   0:00 /usr/sbin/apache2 -D FOREGROUND
www-data      49  0.0  0.0 1250496 5996 ?        Sl   00:48   0:00 /usr/sbin/apache2 -D FOREGROUND
```

### `spin-redis` - Kill `redis-server` process.

```
bash-4.4# ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 {run.sh} /bin/bash /run.sh
    8 root      4:58 redis-server /redis-master/redis.conf --protected-mode no
   51 root      0:00 bash
   56 root      0:00 ps aux
```

### `hal` version cleanup 

You can safely remove `~/.hal` to have a clean start of `hal` if you mess up hal versions.

## Appendix

Please refer to this blog for more details: [Installing Spinnaker in GKE](https://docs.armory.io/spinnaker-install-admin-guides/install-on-gke)
