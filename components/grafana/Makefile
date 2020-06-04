# Use some sensible default shell settings
SHELL := /bin/bash -o pipefail
.SILENT:
.DEFAULT_GOAL := help

# Load common variables
include ../../common.mk

# Load component variables
APP_NAME 			:= grafana
APP_VERSION 	:= v${GRAFANA_VERSION}
CHART_VERSION := ${GRAFANA_CHART_VERSION}

# Update helm chart templates
.PHONY: fetch
fetch: ## Update helm chart templates
	$(call fetch,$(strip ${APP_NAME}),${APP_VERSION},${CHART_VERSION})

# Build deployment manifest
.PHONY: build
build: ## Build deployment manifest
	$(call build,$(strip ${APP_NAME}),${APP_VERSION},${O11Y_NAMESPACE})

# Deploy to kubernetes cluster
.PHONY: deploy
deploy: cluster.check ## Deploy to kubernetes cluster
	$(call deploy,$(strip ${APP_NAME}),${APP_VERSION},${O11Y_NAMESPACE})

# Uninstall
.PHONY: uninstall
uninstall: cluster.check ## Uninstall from kubernetes cluster
	$(call uninstall,$(strip ${APP_NAME}),${APP_VERSION},${O11Y_NAMESPACE})

# Clean
.PHONY: clean
clean: ## Clean workspace
	$(call user_confirm,Do you want to remove "charts" and "resources")
	rm -r charts resources
