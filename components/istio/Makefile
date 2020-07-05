# Istio global variable
ISTIO_HOME ?= ./components/istio

# Fetch core istio resources 
.PHONY: istio.fetch
istio.fetch: ## Fetch core istio resources
ifeq (,$(wildcard ${ISTIO_HOME}/deploy/istio-${ISTIO_VERSION}))
	$(call user_confirm,Istio folder [version: ${ISTIO_VERSION}] not found. Install now)
	mkdir -p ${ISTIO_HOME}/deploy
	cd ${ISTIO_HOME}/deploy; curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
else
	echo "✅ Istio-${ISTIO_VERSION} is already installed."
endif
