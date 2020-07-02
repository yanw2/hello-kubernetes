# Cluster variables
CLUSTER_NAME ?= poc

# Create a kind cluster
.PHONY: kind.create 
kind.create: ## Create a kind cluster 
ifneq ($(shell command -v kind),)
	kind create cluster --name $(CLUSTER_NAME) -v 1
else
	$(error ❌ ${RED}You do not have 'kind' in your PATH. Please install it and try agian.${RESET})
endif

# Delete a kind cluster
.PHONY: kind.delete
kind.delete: ## Delete a kind cluster
ifneq ($(shell command -v kind),)
	kind delete cluster --name $(CLUSTER_NAME)
else
	$(error ❌ ${RED}You do not have 'kind' in your PATH. Please install it and try agian.${RESET})
endif
