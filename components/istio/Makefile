# Istio global variable
ISTIO_HOME 					?= ./components/istio
ISTIO_CTL						?= $(ISTIO_HOME)/deploy/istio-$(ISTIO_VERSION)/bin/istioctl
BOOKINFO_NAMESPACE 	?= bookinfo

##@ Istio Management
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

# Install istio with default profile and observability stack
.PHONY: istio.install.default
istio.install.default: ## Install istio with default profile and observability stack
	$(ISTIO_CTL) install \
		--set addonComponents.grafana.enabled=true \
		--set addonComponents.kiali.enabled=true \
		--set addonComponents.prometheus.enabled=true \
		--set addonComponents.tracing.enabled=true \
		--set values.global.controlPlaneSecurityEnabled=true

# Install istio with demo profile
.PHONY: istio.install.demo
istio.install.demo: ## Install istio with demo profile
	$(ISTIO_CTL) install --set profile=demo

# Deploy istio sample bookinfo app
.PHONY: istio.deploy.bookinfo
istio.deploy.bookinfo: ## Deploy istio sample bookinfo app
	kubectl create namespace $(BOOKINFO_NAMESPACE)
	kubectl label namespace $(BOOKINFO_NAMESPACE) istio-injection=enabled
	cd $(ISTIO_HOME)/deploy/istio-$(ISTIO_VERSION); \
	kubectl -n bookinfo apply -f samples/bookinfo/platform/kube/bookinfo.yaml; \
	kubectl -n bookinfo apply -f samples/bookinfo/networking/bookinfo-gateway.yaml; \
	bin/istioctl analyze -n bookinfo

##@ Observability
# Open prometheus dashboard
.PHONY: o11y.prometheus
o11y.prometheus: ## Open prometheus dashboard
	$(ISTIO_CTL) dashboard prometheus

# Open grafana dashboard
.PHONY: o11y.grafana
o11y.grafana: ## Open grafana dashboard
	$(ISTIO_CTL) dashboard grafana

# Open kiali dashboard
.PHONY: o11y.kiali
o11y.kiali: ## Open kiali dashboard
	$(ISTIO_CTL) dashboard kiali

# Open jaeger dashboard
.PHONY: o11y.jaeger
o11y.jaeger: ## Open jaeger dashboard
	$(ISTIO_CTL) dashboard jaeger
