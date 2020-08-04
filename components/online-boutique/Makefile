# Online boutique demo app global variables
DEMO_HOME 				?= ./components/online-boutique
DEMO_NAMESPACE    ?= online-boutique
DEMO_GITHUB_REPO	?= https://github.com/GoogleCloudPlatform/microservices-demo.git

##@ Online Boutique Demo App
# Deploy online boutique demo app
.PHONY: demo.deploy
demo.deploy: ## Deploy microservices demo app
ifeq (,$(wildcard $(DEMO_HOME)/deploy/microservices-demo))
	$(call user_confirm,microservices demo folder not found. Install now)
	mkdir -p $(DEMO_HOME)/deploy
	cd $(DEMO_HOME)/deploy; git clone $(DEMO_GITHUB_REPO)
else
	echo "✅ Microservices Demo Applications is already checked out."
endif
	echo "⚠️  Using pre-built container images to deploy the apps faster."
	kubectl create namespace $(DEMO_NAMESPACE)
	kubectl label namespace $(DEMO_NAMESPACE) istio-injection=enabled
	kubectl apply -f $(DEMO_HOME)/deploy/microservices-demo/release/kubernetes-manifests.yaml \
		-n $(DEMO_NAMESPACE)

# Delete online boutique demo app
.PHONY: demo.delete
demo.delete: ## Delete online boutique demo app
	kubectl delete namespace $(DEMO_NAMESPACE)

# Run a port-forwarding process to access frontend at http://localhost:8080
.PHONY: demo.forward
demo.forward: ## Run a port-forwarding process to access frontend at http://localhost:8080
	echo "✅ Please access the frontend at http://localhost:8080"
	kubectl port-forward deployment/frontend 8080:8080
