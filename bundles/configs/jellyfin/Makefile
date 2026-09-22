NAME	:= jellyfin
REGISTRY	:= zot.innokentii-kozlov.com
REGISTRY_PATH	:= $(REGISTRY)/bundles/configs/$(NAME)

PLUGINS_YAML	:= plugins.yaml
PLUGINS		:= $(shell yq eval '.[].name' $(PLUGINS_YAML))

PRE_BUILD	:= fetch-plugins

include ../../common.mk

.PHONY: fetch-plugins

define fetch-plugin
curl -fsSL --retry 3 -o $(TARGET)/$(1).zip \
	https://github.com/$(2)/releases/download/$(3)/$(4) && \
echo "$(5)  $(TARGET)/$(1).zip" | sha256sum -c - && \
mkdir -p $(6) && \
unzip -q -o $(TARGET)/$(1).zip -d $(6)
endef

plugin-field = $(strip $(shell yq eval '.[] | select(.name == "$(1)") | .$(2) // ""' $(PLUGINS_YAML)))

fetch-plugins: _prepare
	@$(foreach plugin,$(PLUGINS),$(call fetch-plugin,$(plugin),$(call plugin-field,$(plugin),repo),$(call plugin-field,$(plugin),version),$(call plugin-field,$(plugin),zip),$(call plugin-field,$(plugin),sha256),$(if $(call plugin-field,$(plugin),layout),$(TARGET)/bundle/config/plugins,$(TARGET)/bundle/config/plugins/$(plugin))) && )true
