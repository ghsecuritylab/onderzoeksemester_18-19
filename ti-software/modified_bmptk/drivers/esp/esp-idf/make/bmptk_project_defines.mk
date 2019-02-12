# This file contains functions used by bmptk.mk



# Include any Makefile.projbuild file letting components add
# configuration at the project level
define includeProjBuildMakefile
$(if $(V),$$(info including $(1)/Makefile.projbuild...))
COMPONENT_PATH := $(1)
include $(1)/Makefile.projbuild
endef




# Macro for the recursive sub-make for each component
# $(1) - component directory
# $(2) - component name only
#
# Is recursively expanded by the GenerateComponentTargets macro
define ComponentMake
+$(MAKE) -C $(BUILD_DIR_BASE)/$(2) -f $(IDF_PATH)/make/bmptk_component_wrapper.mk COMPONENT_MAKEFILE=$(1)/component.mk COMPONENT_NAME=$(2)
endef


# Generate top-level component-specific targets for each component
# $(1) - path to component dir
# $(2) - name of component
#
define GenerateComponentTargets

.PHONY: component-$(2)-build component-$(2)-clean


component-$(2)-build: check-submodules $(call prereq_if_explicit, component-$(2)-clean) | $(BUILD_DIR_BASE)/$(2)
	$(call ComponentMake,$(1),$(2)) build


component-$(2)-clean: | $(BUILD_DIR_BASE)/$(2) $(BUILD_DIR_BASE)/$(2)/component_project_vars.mk
	$(call ComponentMake,$(1),$(2)) clean


$(BUILD_DIR_BASE)/$(2):
	@mkdir -p $(BUILD_DIR_BASE)/$(2)


# tell make it can build any component's library by invoking the -build target
# (this target exists for all components even ones which don't build libraries, but it's
# only invoked for the targets whose libraries appear in COMPONENT_LIBRARIES and hence the
# APP_ELF dependencies.)
$(BUILD_DIR_BASE)/$(2)/lib$(2).a: component-$(2)-build
	$(details) "Target '$$^' responsible for '$$@'" # echo which build target built this file


# add a target to generate the component_project_vars.mk files that
# are used to inject variables into project make pass (see matching
# component_project_vars.mk target in component_wrapper.mk).
#
# If any component_project_vars.mk file is out of date, the make
# process will call this target to rebuild it and then restart.
#

$(BUILD_DIR_BASE)/$(2)/component_project_vars.mk: $(1)/component.mk $(COMMON_MAKEFILES) $(SDKCONFIG_MAKEFILE) | $(BUILD_DIR_BASE)/$(2)
	$(call ComponentMake,$(1),$(2)) component_project_vars.mk

endef





# Generate a target to check this submodule
# $(1) - submodule directory, relative to IDF_PATH
define GenerateSubmoduleCheckTarget
check-submodules: $(IDF_PATH)/$(1)/.git
$(IDF_PATH)/$(1)/.git:
	@echo "WARNING: Missing submodule $(1)..."
	[ -e ${IDF_PATH}/.git ] || ( echo "ERROR: esp-idf must be cloned from git to work."; exit 1)
	[ -x "$(shell which git)" ] || ( echo "ERROR: Need to run 'git submodule init $(1)' in esp-idf root directory."; exit 1)
	@echo "Attempting 'git submodule update --init $(1)' in esp-idf root directory..."
	cd ${IDF_PATH} && git submodule update --init $(1)

# Parse 'git status' output to check if the submodule commit is different to expected
ifneq ("$(filter $(1),$(GIT_STATUS))","")
$$(info WARNING: esp-idf git submodule $(1) may be out of date. Run 'git submodule update' in IDF_PATH dir to update.)
endif
endef



















