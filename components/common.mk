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
