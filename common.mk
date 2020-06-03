.PHONY: bootstrap build cluster-create cluster-delete

# ❌ ⚠️  ✅

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RED    := $(shell tput -Txterm setaf 1)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

# Global variables
MANIFEST_DIR 			:= resources/${CLUSTER}
KIND            	:= deployment
SINGLE_NAMESPACE 	:= true

# Load common variables
ifneq (${CLUSTER},)
	include ../../env/${CLUSTER}.env
else
$(error Please provide CLUSTER ***)
endif

# Require user input
CONFIRM := true

# Check cluster to ensure that you are in the correct context when deploying
# Usage: Makefile target, call directly
CURRENT_CONTEXT := $(shell kubectl config view --minify | yq r - current-context)
cluster.check:
ifeq (,$(findstring ${CLUSTER},${CURRENT_CONTEXT}))
	printf "❌ Project is not the right context (Cluster: $(or ${CLUSTER},${PROJECT_ID})). Aborting ...\n";
	exit 1
else
	printf "✅ Project is with the correct context: ${CURRENT_CONTEXT} \n"
endif

# Prompt for user confirmation
# Usage: $(call user_confirm,$message_string)
define user_confirm
	if [ "${CONFIRM}" = "true" ]; then \
		read -p "⚠️  $(1), Continue (Y/N): " confirm && printf $$confirm | grep -iq "^[yY]" || exit 1; \
	fi
endef

# Fetch helm chart templates
# Usage: $(call fetch,$app_name,$app_version,$chart_version)
define fetch
	if [ -d charts ]; then \
		printf '⚠️  $(1) helm charts already exist!\n'; \
	else \
		printf '🌀 Fetching $(1) (version: $(2)) helm charts ... '; \
		helm fetch --untar --untardir charts stable/$(1) --version $(3); \
		printf '✅ completed!\n'; \
		printf '⚠️  Please review your values file with the new helm charts.\n'; \
	fi
endef

# Build the manifest from helm chart templates with custom values 
# Usage: $(call build,$app_name,$app_version,$app_namespace)
define build
	if [ ! -d charts ]; then \
		printf '⚠️  Please fetch $(1) helm charts first by running `make fetch CLUSTER=<YOUR_CLUSTER>`\n'; \
		exit 1; \
	fi
	mkdir -p ${MANIFEST_DIR}/$(2); \
	printf '🌀 Building $(1) (version: $(2)) deployment manifest ... '; \
	helm template charts/$(1) --name $(1) --namespace $(3) \
		-f values/$(2)/values.${CLUSTER}.yaml > ${MANIFEST_DIR}/$(2)/output.yaml; \
	printf '✅ completed!\n'
endef

# Deploy application to the cluster
# Usage: $(call deploy,$app_name,$app_version,$app_namespace)
define deploy
	$(call user_confirm,Install $(1) to ${CLUSTER} with manifests at ${MANIFEST_DIR}/$(2))

	if [ ! -f ${MANIFEST_DIR}/$(2)/output.yaml ]; then \
		printf '⚠️  Please generate the deployment manifest first by running `make build CLUSTER=<YOUR_CLUSTER>`\n'; \
		exit 1; \
	fi; \

	if [ ${SINGLE_NAMESPACE} == "true" ]; then \
		kubectl apply -n $(3) -f ${MANIFEST_DIR}/$(2); \
	else \
		kubectl apply -f ${MANIFEST_DIR}/$(2); \
	fi; \
	
	if [ ${KIND} == "daemonset" ]; then \
		kubectl rollout status --timeout=600s ${KIND}/$(1) -n $(3); \
		printf "✅ $(1) has been successfully deployed to ${CLUSTER}"; \
	else \
		kubectl wait --for=condition=Available --timeout=600s ${KIND}/$(1) -n $(3); \
		printf "✅ $(1) has been successfully deployed to ${CLUSTER}"; \
	fi;
endef

# Uninstall application from the cluster
# Usage: $(call uninstall,$app_name,$app_version,$app_namespace)
define uninstall
	$(call user_confirm,Uninstall $(1) (version: $(2)) from ${CLUSTER})
	kubectl delete -f ${MANIFEST_DIR}/$(2) -n $(3); \
	kubectl wait --for=delete --timeout=600s ${KIND}/$(1); \
	printf "✅ $(1) has been successfully uninstalled from ${CLUSTER}";
endef

# Rollback to previous version
# Usage: $(call rollback,$version,$namespace,$rollback_version)
define rollback
	$(call uninstall, $(1),$(2))
	$(call deploy, $(3),$(2))
endef

# Add resources to kustomize
# Usage: $(call add_resources,$directory)
define add_resources
	cd $(1); kustomize edit add resource [^k]*.yaml
endef

# Add kustomize base to kustomize overlays
# Usage: $(call add_base,$directory)
define add_base
	if [ -z $(shell grep base ${OVERLAY_DIR}/kustomization.yaml | sed 's/.*\/\(.*\)/\1/g') ]; then \
		cd ${OVERLAY_DIR}; kustomize edit add base ../base; \
	fi;
endef

## @ Misc
.PHONY: help
help: ## Display help
	awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n  make \033[36m[TARGET] [CLUSTER]\033[0m\n" \
	  } /^[a-zA-Z_.]+:.*?##/ { \
	    printf "    \033[36m%-15s\033[0m	%s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  }' $(MAKEFILE_LIST)
