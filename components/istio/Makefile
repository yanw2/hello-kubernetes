# Istio global variable
ISTIO_HOME 					?= ./components/istio
ISTIO_CTL						?= $(ISTIO_HOME)/deploy/istio-$(ISTIO_VERSION)/bin/istioctl
ISTIO_LEGACY_CTL		?= $(ISTIO_HOME)/deploy/istio-$(ISTIO_LEGACY_VERSION)/bin/istioctl
KIALI_USERNAME 			?= admin
KIALI_PASSWORD 			?= admin
ISTIO_NAMESPACE			?= istio-system
BOOKINFO_NAMESPACE 	?= bookinfo

##@ Istio Management
# Fetch core istio resources
.PHONY: istio.fetch.core
istio.fetch.core: ## Fetch core istio resources
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
		--set values.kiali.enabled=true \
    --set "values.kiali.dashboard.jaegerURL=http://jaeger-query:16686" \
    --set "values.kiali.dashboard.grafanaURL=http://grafana:3000" \
		--set values.global.controlPlaneSecurityEnabled=true
	kubectl apply -f $(ISTIO_HOME)/custom/kiali/kiali-default-secret.yaml

# Install istio with the legacy version at work
.PHONY: istio.install.legacy
istio.install.legacy: ## Install istio with the legacy version at work 
	$(ISTIO_LEGACY_CTL) manifest apply \
		--set values.global.mtls.enabled=true \
		--set values.global.controlPlaneSecurityEnabled=true
	kubectl label namespace default istio-injection=enabled

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
.PHONY: o11y.view.prometheus
o11y.view.prometheus: ## Open prometheus dashboard
	$(ISTIO_CTL) dashboard prometheus

# Open grafana dashboard
.PHONY: o11y.view.grafana
o11y.view.grafana: ## Open grafana dashboard
	$(ISTIO_CTL) dashboard grafana

# Open kiali dashboard
.PHONY: o11y.view.kiali
o11y.view.kiali: ## Open kiali dashboard
	$(ISTIO_CTL) dashboard kiali

# Open jaeger dashboard
.PHONY: o11y.view.jaeger
o11y.view.jaeger: ## Open jaeger dashboard
	$(ISTIO_CTL) dashboard jaeger
