# Cluster variables
CPU 		?= 4
MEMORY 	?= 8192

# Create a minkube cluster
.PHONY: minikube.create 
minikube.create: ## Create a minikube cluster 
ifneq ($(shell command -v minikube),) 
	minikube start --cpus=$(CPU) --memory=$(MEMORY) --addons=metrics-server
else 
	$(error ❌ ${RED}You do not have 'minikube' in your PATH. Please install it and try agian.${RESET})
endif

# Delete a minkube cluster
.PHONY: minikube.delete
minikube.delete: ## Delete a minikube cluster
ifneq ($(shell command -v minikube),)
	minikube delete
else
	$(error ❌ ${RED}You do not have 'minikube' in your PATH. Please install it and try agian.${RESET})
endif
