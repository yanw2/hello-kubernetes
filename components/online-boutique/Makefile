# Microservices-demo global variable
MICRO_HOME 				?= ./components/online-boutique
MICRO_GITHUB_REPO	?= https://github.com/GoogleCloudPlatform/microservices-demo.git

##@ Microservices Demo Applications 
# Deploy microservices-demo app
.PHONY: demo.deploy.micro
demo.deploy.micro: ## Deploy microservices demo app
ifeq (,$(wildcard $(MICRO_HOME)/deploy/microservices-demo))
	$(call user_confirm,microservices demo folder not found. Install now)
	mkdir -p $(MICRO_HOME)/deploy
	cd $(MICRO_HOME)/deploy; git clone $(MICRO_GITHUB_REPO)
else
	echo "✅ Microservices Demo Applications is already checked out."
endif
	echo "⚠️  Using pre-built container images to deploy the apps faster."
	kubectl apply -f $(MICRO_HOME)/deploy/microservices-demo/release/kubernetes-manifests.yaml
