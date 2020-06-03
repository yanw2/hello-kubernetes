# Use some sensible default shell settings
SHELL := /bin/bash -o pipefail
.SILENT:
.DEFAULT_GOAL := help

# Project variables
PROJECT_NAME ?= hello-minikube 

# Minio variables
MINIO_NAMESPACE ?= minio
MINIO_KEY ?= minioadmin

# Spinnaker variables
SPINNAKER_VERSION ?= 1.17.6
SPINNAKER_NAMESPACE ?= spinnaker
SPINNAKER_SERVICE_ACCOUNT ?= spinnaker-user
HAL_DEFAULT_PROFILE ?= ~/.hal/default/profiles

.PHONY: build-minio
build-minio: ## Build minio server on minikube
	printf '🌀 Setting up minio server on minikube...\n'
	kubectl create namespace $(MINIO_NAMESPACE) 
	kubectl create -f yaml/minio-deployment.yaml --namespace=$(MINIO_NAMESPACE)
	printf '✅ Completed!\n' 

.PHONY: remove-minio
remove-minio: ## Remove minio server from minikube
	printf '🌀 Removing minio server...\n'
	kubectl delete -f yaml/minio-deployment.yaml --namespace=$(MINIO_NAMESPACE) 
	kubectl delete namespace $(MINIO_NAMESPACE)
	printf '✅ Completed!\n' 

.PHONY: build-spinnaker
build-spinnaker: ## Build spinnaker cluster on minikube
	printf '🌀 Setting up spinnaker namespace on minikube...\n'
	kubectl create namespace $(SPINNAKER_NAMESPACE) 
	kubectl config set-context --current --namespace=$(SPINNAKER_NAMESPACE)
	kubectl apply -f yaml/spinnaker-service-account.yaml
	printf '✅ Completed!\n\n' 
	printf '🌀 Setting up spinnaker version: $(SPINNAKER_VERSION)...\n'
	hal config version edit --version $(SPINNAKER_VERSION)
	printf '✅ Completed!\n\n' 
	printf '🌀 Configuring spinnaker provider...\n'
	hal config provider kubernetes enable
	hal config provider kubernetes account add $(SPINNAKER_SERVICE_ACCOUNT) \
		--provider-version v2 \
		--context $(shell kubectl config current-context)
	hal config features edit --artifacts true
	hal config deploy edit --type distributed --account-name $(SPINNAKER_SERVICE_ACCOUNT) 
	mkdir -p $(HAL_DEFAULT_PROFILE)
	echo 'spinnaker.s3.versioning: false' > $(HAL_DEFAULT_PROFILE)/front50-local.yml
	printf '✅ Completed!\n\n' 
	printf '🌀 Configuring spinnaker storage with minio...\n'
	hal config storage s3 edit --access-key-id $(MINIO_KEY) --secret-access-key $(MINIO_KEY) \
		--endpoint http://$(shell kubectl get pods -n minio -o jsonpath='{.items[0].status.podIP}'):9000
	hal config storage edit --type s3
	printf '✅ Completed!\n\n' 
	printf '🌀 Deploying spinnaker cluster to minikube...\n'
	hal deploy apply
	printf '✅ Completed!\n' 

.PHONY: remove-spinnaker
remove-spinnaker: ## Remove spinnaker cluster from minikube
	printf '🌀 Removing spinnaker deployment...\n'
	hal deploy clean
	hal config provider kubernetes account delete $(SPINNAKER_SERVICE_ACCOUNT)
	printf '✅ Completed!\n\n' 
	printf '🌀 Removing spinnaker namespace...\n'
	kubectl delete -f yaml/spinnaker-service-account.yaml --namespace=$(SPINNAKER_NAMESPACE)
	kubectl delete namespace $(SPINNAKER_NAMESPACE)
	printf '✅ Completed!\n\n'
	printf '🌀 Removing front50 local file...\n'
	rm $(HAL_DEFAULT_PROFILE)/front50-local.yml
	printf '✅ Completed!\n' 

.PHONY: start-minikube
start-minikube: ## Start a minikube cluster with 12 GB RAM and 6 CPUs
	minikube start --memory=12288mb --cpus=6 --kubernetes-version=1.17.2 

.PHONY: clean-minikube
clean-minikube: ## Remove the minikube cluster and its VM 
	minikube stop 
	minikube delete

##@ Misc
.PHONY: help
help: ## Display help
	@awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n" \
	  } /^[a-zA-Z_-]+:.*?##/ { \
	    printf "    \033[36m%-15s\033[0m	%s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  }' $(MAKEFILE_LIST)
