# Microservices-demo global variable
MICRO_HOME 				?= ./components/microservices-demo
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
ifneq ($(shell command -v skaffold),)
	echo "⚠️  First time will be slow, it can take ~20 minutes."
	cd $(MICRO_HOME)/deploy/microservices-demo && skaffold run	
else
	$(error ❌ ${RED}You do not have 'skaffold' in your PATH. Please install it and try agian.${RESET})
endif
endif
