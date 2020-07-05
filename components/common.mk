# ❌ ⚠️  ✅ 🌀

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RED    := $(shell tput -Txterm setaf 1)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

# Prompt for user confirmation
# Usage: $(call user_confirm,$message_string)
define user_confirm
	read -p "⚠️  $(1)? Continue (Y/N): " confirm && printf $$confirm | grep -iq "^[yY]" || exit 1
endef

# Check cluster to ensure that you are in the correct context when deploying
# Usage: Makefile target, call directly
#CURRENT_CONTEXT := $(shell kubectl config view --minify | yq r - current-context)
#cluster.check:
#ifeq (,$(findstring ${CLUSTER},${CURRENT_CONTEXT}))
#	printf "❌ Project is not the right context (Cluster: $(or ${CLUSTER},${PROJECT_ID})). Aborting ...\n";
#	exit 1
#else
#	printf "✅ Project is with the correct context: ${CURRENT_CONTEXT} \n"
#endif
