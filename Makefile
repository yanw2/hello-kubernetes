# Use some sensible default shell settings
SHELL := /bin/bash -o pipefail
.SILENT:
.DEFAULT_GOAL := help

# Load environment parameters (default to local)
include ./env/local.env

# Load clusters
include ./clusters/kind/Makefile
include ./clusters/minikube/Makefile
include ./clusters/gke/Makefile

# Load components
include ./components/common.mk
include ./components/istio/Makefile

##@ Miscellaneous
.PHONY: help
help: ## Display help
	awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n  make \033[36m[TARGET] [CLUSTER]\033[0m\n" \
	  } /^[a-zA-Z_.]+:.*?##/ { \
	    printf "  \033[36m%-15s\033[0m	%s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  }' $(MAKEFILE_LIST)
