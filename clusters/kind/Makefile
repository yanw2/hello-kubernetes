# Create a kind cluster
.PHONY: kind.create 
kind.create: ## Create a kind cluster 
ifneq ($(shell command -v kind),)
	echo 'Unsetting HTTP_PROXY and HTTPS_PROXY ...'
	unset HTTP_PROXY HTTPS_PROXY && kind create cluster -v 1
else
	$(error ❌ ${RED}You do not have 'kind' in your PATH. Please install it and try agian.${RESET})
endif

# Delete a kind cluster
.PHONY: kind.delete
kind.delete: ## Delete a kind cluster
ifneq ($(shell command -v kind),)
	kind delete cluster
else
	$(error ❌ ${RED}You do not have 'kind' in your PATH. Please install it and try agian.${RESET})
endif
