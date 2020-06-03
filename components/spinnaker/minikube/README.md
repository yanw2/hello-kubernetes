# hello-minikube

This project is my Minikube playground, including the following features:

* Install Minio (persistent storage for Spinnaker)
* Install Spinnaker cluster

## Prerequisite

* [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
* [hal](https://www.spinnaker.io/setup/install/halyard)

*Note: Spinnaker is installed via Hal*

## Execution

You can run `make` to review the usage. Minio is the persistent storage used by Spinnaker to store its data. Hence, please ensure Minio is up and running before start to build Spinnaker.

```
Usage:
  make <target>
    build-minio    	 Build minio server on minikube
    remove-minio   	 Remove minio server from minikube
    build-spinnaker	 Build spinnaker cluster on minikube
    remove-spinnaker	 Remove spinnaker cluster from minikube
    start-minikube 	 Start a minikube cluster with 12 GB RAM and 6 CPUs
    clean-minikube 	 Remove the minikube cluster and its VM

Misc
    help           	 Display help
```

## Connect to Spinnaker

Once you see all pods are running. Please run `hal deploy connect` to start port forwarding and then you can access Spinnaker via `http://localhost:9000`.

## Performance

Please *DO NOT* enable too many Minikube addons otherwise you might have 100% CPU issue. I just use the default ones, and also `metrics-server` if you want to monitor on the pods' CPU and memory usage.
