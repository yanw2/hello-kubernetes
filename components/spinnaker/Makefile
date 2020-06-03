# Use some sensible default shell settings
SHELL := /bin/bash -o pipefail
.SILENT:
.DEFAULT_GOAL := help

# GCP variables
PROJECT_NAME ?= <GCP_PROJECT> 
CLUSTER_NAME ?= <CLUSTER_NAME> 
REGION ?= australia-southeast1
ZONE ?= australia-southeast1-a
SPINNAKER_SERVICE_ACCOUNT_KEY ?= ~/.gcp/spinnaker-sa-$(CLUSTER_NAME).json

# Spinnaker variables
SPINNAKER_VERSION ?= 1.19.2
SPINNAKER_NAMESPACE ?= spinnaker
SPINNAKER_SERVICE_ACCOUNT ?= spinnaker
SPINNAKER_CONTEXT ?= <GKE_CLUSTER_CONTEXT> 
BUCKET_LOCATION ?= $(REGION) 

# Hipstershop app variables
HIPSTERSHOP_HOME ?= hipstershop

# Multiple targets for "lazy" engineers like me ^o^ 
.PHONY: create.all
create.all: gcp.sa.create spinnaker.create

.PHONY: delete.all
delete.all: spinnaker.delete gcp.sa.delete	

# GKE authentication
.PHONY: gke.auth
gke.auth: ## Authenticate to the GKE cluster
	gcloud container clusters get-credentials $(CLUSTER_NAME) --zone $(ZONE) 

# GCP service account and policy
.PHONY: gcp.sa.create
gcp.sa.create: ## Create spinnaker service account
	printf '🌀 Creating spinnaker service account...\n'
	gcloud iam service-accounts create $(SPINNAKER_SERVICE_ACCOUNT) --display-name $(SPINNAKER_SERVICE_ACCOUNT) 
	printf '✅ Completed!\n\n' 
	printf '🌀 Granting spinnaker service account permission...\n'
	$(eval SPINNAKER_SA_EMAIL := \
		"$(strip $(SPINNAKER_SERVICE_ACCOUNT))@$(strip $(PROJECT_NAME)).iam.gserviceaccount.com")
	gcloud projects add-iam-policy-binding $(PROJECT_NAME) \
		--role roles/storage.admin \
		--member serviceAccount:$(SPINNAKER_SA_EMAIL)
	gcloud projects add-iam-policy-binding $(PROJECT_NAME) \
		--role roles/container.clusterAdmin \
		--member serviceAccount:$(SPINNAKER_SA_EMAIL)
	printf '✅ Completed!\n\n' 
	printf '🌀 Creating spinnaker service account key...\n'
	mkdir -p $(shell dirname $(SPINNAKER_SERVICE_ACCOUNT_KEY))
	gcloud iam service-accounts keys create $(SPINNAKER_SERVICE_ACCOUNT_KEY) --iam-account $(SPINNAKER_SA_EMAIL)
	printf '✅ Completed!\n\n' 

.PHONY: gcp.sa.delete
gcp.sa.delete: ## Delete spinnaker service account
	$(eval SPINNAKER_SA_EMAIL := \
		"$(strip $(SPINNAKER_SERVICE_ACCOUNT))@$(strip $(PROJECT_NAME)).iam.gserviceaccount.com")
	printf '🌀 Deleting spinnaker policy binding...\n'
	gcloud projects remove-iam-policy-binding $(PROJECT_NAME) \
		--role roles/storage.admin \
		--member "serviceAccount:$(SPINNAKER_SA_EMAIL)"
	gcloud projects remove-iam-policy-binding $(PROJECT_NAME) \
		--role roles/container.clusterAdmin \
		--member "serviceAccount:$(SPINNAKER_SA_EMAIL)"
	printf '✅ Completed!\n\n' 
	printf '🌀 Deleting spinnaker service account...\n'
	gcloud iam service-accounts delete $(SPINNAKER_SA_EMAIL) 
	printf '✅ Completed!\n\n' 

# Spinnaker deployment
.PHONY: spinnaker.create
spinnaker.create: ## Deploy spinnaker cluster
	printf '🌀 Setting up spinnaker namespace...\n'
	kubectl create namespace $(SPINNAKER_NAMESPACE) 
	kubectl config set-context --current --namespace=$(SPINNAKER_NAMESPACE)
	kubectl apply -f ./build/spinnaker-service-account.yaml
	printf '✅ Completed!\n\n' 
	printf '🌀 Setting up spinnaker version: $(SPINNAKER_VERSION)...\n'
	hal config version edit --version $(SPINNAKER_VERSION)
	printf '✅ Completed!\n\n' 
	printf '🌀 Configuring spinnaker provider...\n'
	hal config provider kubernetes enable
	hal config provider kubernetes account add $(SPINNAKER_SERVICE_ACCOUNT) \
		--provider-version v2 \
		--context $(SPINNAKER_CONTEXT)
	#hal config provider kubernetes account edit $(SPINNAKER_SERVICE_ACCOUNT) --omit-kinds controllerRevision
	hal config features edit --artifacts true
	hal config artifact gcs account add $(SPINNAKER_SERVICE_ACCOUNT) --json-path $(SPINNAKER_SERVICE_ACCOUNT_KEY)
	hal config artifact gcs enable
	hal config deploy edit --type distributed --account-name $(SPINNAKER_SERVICE_ACCOUNT) 
	printf '✅ Completed!\n\n' 
	printf '🌀 Configuring spinnaker storage...\n'
	hal config storage gcs edit --project $(PROJECT_NAME) \
		--bucket-location $(BUCKET_LOCATION) \
		--json-path $(SPINNAKER_SERVICE_ACCOUNT_KEY)
	hal config storage edit --type gcs 
	printf '✅ Completed!\n\n' 
	printf '🌀 Deploying spinnaker cluster to GKE...\n'
	hal deploy apply
	printf '✅ Completed!\n' 

# Spinnaker port forwarding
.PHONY: spinnaker.connect
spinnaker.connect: ## Create port forwarding to connect to spinnaker cluster 
	$(eval DECK_POD := \
		$(shell kubectl -n ${SPINNAKER_NAMESPACE} \
			get pod -l cluster=spin-deck -ojsonpath='{.items[0].metadata.name}'))
	$(eval GATE_POD := \
		$(shell kubectl -n ${SPINNAKER_NAMESPACE} \
			get pod -l cluster=spin-gate -ojsonpath='{.items[0].metadata.name}'))
	kubectl -n ${SPINNAKER_NAMESPACE} port-forward ${DECK_POD} 9000 &
	kubectl -n ${SPINNAKER_NAMESPACE} port-forward ${GATE_POD} 8084 & 

.PHONY: spinnaker.delete 
spinnaker.delete: ## Delete spinnaker cluster
	printf '🌀 Deleting spinnaker namespace...\n'
	kubectl delete -f ./build/spinnaker-service-account.yaml --namespace=$(SPINNAKER_NAMESPACE)
	kubectl delete namespace $(SPINNAKER_NAMESPACE)
	printf '✅ Completed!\n\n'
	printf '🌀 Deleting HAL deployment...\n'
	hal deploy clean 
	hal config provider kubernetes account delete $(SPINNAKER_SERVICE_ACCOUNT)
	hal config artifact gcs account delete $(SPINNAKER_SERVICE_ACCOUNT)
	printf '✅ Completed!\n\n' 

# Hipstershop app deployment
.PHONY: hipstershop.create
hipstershop.create: ## Create manifest artifact for hipstershop app deployment
	printf '🌀 Building manifest artifact... '
	kustomize build $(HIPSTERSHOP_HOME) > $(HIPSTERSHOP_HOME)/outputs/hipstershop-deployment.yaml
	printf '✅ Completed!\n\n'
	printf '🌀 Uploading manifest artifact...\n'
	gsutil cp $(HIPSTERSHOP_HOME)/outputs/*.yaml gs://hipstershop
	printf '✅ Completed!\n\n'
	printf '🌀 Creating namespace... '
	kubectl create namespace hipstershop
	printf '✅ Completed!\n\n'

.PHONY: hipstershop.delete
hipstershop.delete: ## Delete manifest artifact
	printf '🌀 Deleting local manifest artifact... '
	rm $(HIPSTERSHOP_HOME)/outputs/hipstershop-deployment.yaml 
	printf '✅ Completed!\n\n'
	printf '🌀 Deleting uploaded manifest artifact...\n'
	gsutil rm gs://hipstershop/hipstershop* 
	printf '✅ Completed!\n\n'
	printf '🌀 Deleting namespace... '
	kubectl delete namespace hipstershop
	printf '✅ Completed!\n\n'

##@ Misc
.PHONY: help
help: ## Display help
	@awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n" \
	  } /^[a-zA-Z_.]+:.*?##/ { \
	    printf "    \033[36m%-15s\033[0m	%s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  }' $(MAKEFILE_LIST)
