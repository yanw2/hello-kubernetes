##@ Istio Management

# Istio global variable
ISTIO_HOME 					?= ./components/istio
BOOKINFO_NAMESPACE 	?= bookinfo

# Fetch core istio resources 
.PHONY: istio.fetch
istio.fetch: ## Fetch core istio resources
ifeq (,$(wildcard $(ISTIO_HOME)/deploy/istio-$(ISTIO_VERSION)))
	$(call user_confirm,Istio folder [version: $(ISTIO_VERSION)] not found. Install now)
	mkdir -p $(ISTIO_HOME)/deploy
	cd $(ISTIO_HOME)/deploy; curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$(ISTIO_VERSION) sh -
else
	echo "✅ Istio-$(ISTIO_VERSION) is already installed."
endif

# Install istio with demo profile
.PHONY: istio.install.demo
istio.install.demo: ## Install istio with demo profile
	$(ISTIO_HOME)/deploy/istio-$(ISTIO_VERSION)/bin/istioctl install --set profile=demo

# Deploy istio sample bookinfo app
.PHONY: istio.deploy.bookinfo
istio.deploy.sample: ## Deploy istio sample bookinfo app
	kubectl create namespace $(BOOKINFO_NAMESPACE) 
	kubectl label namespace bookinfo istio-injection=enabled
	cd $(ISTIO_HOME)/deploy/istio-$(ISTIO_VERSION); \
	kubectl -n bookinfo apply -f samples/bookinfo/platform/kube/bookinfo.yaml; \
	kubectl -n bookinfo apply -f samples/bookinfo/networking/bookinfo-gateway.yaml; \
	bin/istioctl analyze -n bookinfo
