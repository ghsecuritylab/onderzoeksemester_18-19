# Makefile for building the esp-idf

.PHONY: help
$(info $$ File: bmptk/bmptk.mk)
USED_VARIABLES := APP_BIN APP_ELF APP_MAP AR ARFLAGS BUILD_DIR_BASE CC CFLAGS COMMON_FLAGS COMMON_MAKEFILES COMMON_WARNING_FLAGS COMPILER_VERSION_NUM COMPILER_VERSION_STR COMPONENTS COMPONENT_DIRS COMPONENT_INCLUDES COMPONENT_INCLUDES COMPONENT_LDFLAGS COMPONENT_LIBRARIES COMPONENT_PATHS COMPONENT_PROJECT_VARS COMPONENT_SUBMODULES CPPFLAGS CPPFLAGS CPPFLAGS CXX CXXFLAGS DEBUG_FLAGS EXTRA_CPPFLAGS EXTRA_LDFLAGS HOSTAR HOSTCC HOSTLD HOSTOBJCOPY IDF_VER LD LDFLAGS LINKER_SCRIPTS MAKECMDGOALS NON_INTERACTIVE_TARGET OBJCOPY OPTIMIZATION_FLAGS OS PROJECT_PATH PYTHON SANITISED_IDF_PATH SIZE SIZE TESTS_ALL TEST_COMPONENTS TEST_EXCLUDE_COMPONENTS TOOLCHAIN_GCC_VER TOOLCHAIN_HEADER TOOLCHAIN_PATH
DEFINED_VARIABLES :=

MAKECMDGOALS ?= all see-defined-variables
DEFINED_VARIABLES += MAKECMDGOALS


see-defined-variables:
	$(info $$ "=======================================================================")
	$(info $$ "     Defined variables in the makefiles:                               ")
	$(info $$ "     (To see the values, add v as argument.)                           ")
	$(info $$ "=======================================================================")
	$(foreach item, $(USED_VARIABLES), $(info $$    - $(item) )) 

see-defined-variables-all:
	$(info $$ "=======================================================================")
	$(info $$ "     Defined variables in the makefiles:                               ")
	$(info $$ "     (To see the values, add v as argument.)                           ")
	$(info $$ "=======================================================================")
	$(foreach item, $(USED_VARIABLES), $(info $$     - $(item): $($(item)) )) 

see-var:
	$(eval par=$(filter-out $@,$(MAKECMDGOALS)))
	$(info $$ $(par) = $($(par)))


	
	
help:
	@echo "======================================================================="
	@echo "     Welcome to Espressif IDF build system. Some useful make targets:"
	@echo "======================================================================="
	@echo "    - make menuconfig                - Configure IDF project"
	@echo "    - make defconfig                 - Set defaults for all new configuration options"
	@echo "-----"
	@echo "    - make all                       - Build app, bootloader, partition table"
	@echo "    - make flash                     - Flash app, bootloader, partition table to a chip"
	@echo "    - make clean                     - Remove all build output"
	@echo "    - make size                      - Display the static memory footprint of the app"
	@echo "    - make size-files                - Finer-grained memory footprints"
	@echo "    - make size-components           - Finer-grained memory footprints"
	@echo "    - make size-symbols              - Per symbol memory footprint. Requires COMPONENT=<component>"
	@echo "    - make erase_flash               - Erase entire flash contents"
	@echo "    - make erase_ota                 - Erase ota_data partition. After that will boot first bootable partition (factory or OTAx)."
	@echo "    - make monitor                   - Run idf_monitor tool to monitor serial output from app"
	@echo "    - make simple_monitor            - Monitor serial output on terminal console"
	@echo "    - make list-components           - List all components in the project"
	@echo "-----"
	@echo "    - make app                       - Build just the app"
	@echo "    - make app-flash                 - Flash just the app"
	@echo "    - make app-clean                 - Clean just the app"
	@echo "    - make print_flash_cmd           - Print the arguments for esptool when flash"
	@echo "    - make check_python_dependencies - Check that the required python packages are installed"
	@echo "    - make see-defined-variables     - See list of variables that are used in this makefile"
	@echo "    - make see-defined-variables-all - See list of variables (with their values) that are used in this makefile"
	@echo "    - make see-var <variable>        - See value of given parameter"
	@echo "====="


# Non-interactive targets. Mostly, those for which you do not need to build a binary
NON_INTERACTIVE_TARGET += defconfig clean% %clean help list-components print_flash_cmd check_python_dependencies
DEFINED_VARIABLES += NON_INTERACTIVE_TARGET

# dependency checks
ifndef MAKE_RESTARTS
ifeq ("$(filter 4.% 3.81 3.82,$(MAKE_VERSION))","")
$(warning esp-idf build system only supports GNU Make versions 3.81 or newer. You may see unexpected results with other Makes.)
endif

ifdef MSYSTEM
ifneq ("$(MSYSTEM)","MINGW32")
$(warning esp-idf build system only supports MSYS2 in "MINGW32" mode. Consult the ESP-IDF documentation for details.)
endif
endif  # MSYSTEM

endif  # MAKE_RESTARTS

# can't run 'clean' along with any non-clean targets
ifneq ("$(filter clean% %clean,$(MAKECMDGOALS))" ,"")
ifneq ("$(filter-out clean% %clean,$(MAKECMDGOALS))", "")
$(error esp-idf build system doesn't support running 'clean' targets along with any others. Run 'make clean' and then run other targets separately.)
endif
endif


OS ?=
DEFINED_VARIABLES += OS

# make IDF_PATH a "real" absolute path
# * works around the case where a shell character is embedded in the environment variable value.
# * changes Windows-style C:/blah/ paths to MSYS style /c/blah
ifeq ("$(OS)","Windows_NT")
# On Windows MSYS2, make wildcard function returns empty string for paths of form /xyz
# where /xyz is a directory inside the MSYS root - so we don't use it.
SANITISED_IDF_PATH:=$(subst $(DRIVE):,/$(DRIVE),$(subst \,/,$(IDF_PATH)))
else
SANITISED_IDF_PATH:=$(realpath $(wildcard $(subst $(DRIVE):,/$(DRIVE),$(subst \,/,$(IDF_PATH)))))
endif
DEFINED_VARIABLES += SANITISED_IDF_PATH

# export the new sanitised IDF_PATH
# export IDF_PATH := $(SANITISED_IDF_PATH)

ifndef IDF_PATH
$(error IDF_PATH variable is not set to a valid directory.)
endif


# disable built-in make rules, makes debugging saner
MAKEFLAGS_OLD := $(MAKEFLAGS)
MAKEFLAGS +=-rR



# Default path to the project: we assume the Makefile including this file
# is in the project directory
ifndef PROJECT_PATH
PROJECT_PATH := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
export PROJECT_PATH
endif
DEFINED_VARIABLES +=PROJECT_PATH

# A list of the "common" makefiles, to use as a target dependency
COMMON_MAKEFILES := $(IDF_PATH)/make/bmptk.mk \
					$(IDF_PATH)/make/bmptk_common.mk \
					$(IDF_PATH)/make/bmptk_component_wrapper.mk \
					$(firstword $(MAKEFILE_LIST))
export COMMON_MAKEFILES
DEFINED_VARIABLES +=COMMON_MAKEFILES


# The directory where we put all objects/libraries/binaries. The project Makefile can
# configure this if needed.
ifndef BUILD_DIR_BASE
BUILD_DIR_BASE := $(PROJECT_PATH)/build
endif
export BUILD_DIR_BASE
DEFINED_VARIABLES +=BUILD_DIR_BASE




# Component directories. These directories are searched for components (either the directory is a component,
# or the directory contains subdirectories which are components.)
# The project Makefile can override these component dirs, or add extras via EXTRA_COMPONENT_DIRS
ifndef COMPONENT_DIRS
EXTRA_COMPONENT_DIRS ?=
COMPONENT_DIRS := $(PROJECT_PATH)/components $(EXTRA_COMPONENT_DIRS) $(IDF_PATH)/components $(PROJECT_PATH)/main
endif
export COMPONENT_DIRS
DEFINED_VARIABLES +=COMPONENT_DIRS

ifdef SRCDIRS
$(warning SRCDIRS variable is deprecated. These paths can be added to EXTRA_COMPONENT_DIRS or COMPONENT_DIRS instead.)
COMPONENT_DIRS += $(abspath $(SRCDIRS))
endif







# The project Makefile can define a list of components, but if it does not do this we just take all available components
# in the component dirs. A component is COMPONENT_DIRS directory, or immediate subdirectory,
# which contains a component.mk file.
#
# Use the "make list-components" target to debug this step.
ifndef COMPONENTS
# Find all component names. The component names are the same as the
# directories they're in, so /bla/components/mycomponent/component.mk -> mycomponent.
COMPONENTS := $(dir $(foreach cd,$(COMPONENT_DIRS),                           \
					$(wildcard $(cd)/*/component.mk) $(wildcard $(cd)/component.mk) \
				))
COMPONENTS := $(sort $(foreach comp,$(COMPONENTS),$(lastword $(subst /, ,$(comp)))))
endif
# After a full manifest of component names is determined, subtract the ones explicitly omitted by the project Makefile.
ifdef EXCLUDE_COMPONENTS
COMPONENTS := $(filter-out $(subst ",,$(EXCLUDE_COMPONENTS)), $(COMPONENTS)) 
# to keep syntax highlighters happy: "))
endif
export COMPONENTS
DEFINED_VARIABLES +=COMPONENTS


# Resolve all of COMPONENTS into absolute paths in COMPONENT_PATHS.
#
# If a component name exists in multiple COMPONENT_DIRS, we take the first match.
#
# NOTE: These paths must be generated WITHOUT a trailing / so we
# can use $(notdir x) to get the component name.
COMPONENT_PATHS := $(foreach comp,$(COMPONENTS),$(firstword $(foreach cd,$(COMPONENT_DIRS),$(wildcard $(dir $(cd))$(comp) $(cd)/$(comp)))))
export COMPONENT_PATHS
DEFINED_VARIABLES +=COMPONENT_PATHS


# testing variables
TEST_COMPONENTS ?=
TEST_EXCLUDE_COMPONENTS ?=
TESTS_ALL ?=
DEFINED_VARIABLES +=TEST_COMPONENTS TEST_EXCLUDE_COMPONENTS TESTS_ALL

# If TESTS_ALL set to 1, set TEST_COMPONENTS_LIST to all components.
# Otherwise, use the list supplied in TEST_COMPONENTS.
ifeq ($(TESTS_ALL),1)
TEST_COMPONENTS_LIST := $(filter-out $(TEST_EXCLUDE_COMPONENTS), $(COMPONENTS))
else
TEST_COMPONENTS_LIST := $(TEST_COMPONENTS)
endif

TEST_COMPONENT_PATHS := $(foreach comp,$(TEST_COMPONENTS_LIST),$(firstword $(foreach dir,$(COMPONENT_DIRS),$(wildcard $(dir)/$(comp)/test))))
TEST_COMPONENT_NAMES := $(foreach comp,$(TEST_COMPONENT_PATHS),$(lastword $(subst /, ,$(dir $(comp))))_test)

# Initialise project-wide variables which can be added to by
# each component.
#
# These variables are built up via the component_project_vars.mk
# generated makefiles (one per component).
#
# See docs/build-system.rst for more details.
COMPONENT_INCLUDES :=
COMPONENT_LDFLAGS :=
COMPONENT_SUBMODULES :=
COMPONENT_LIBRARIES :=
DEFINED_VARIABLES +=COMPONENT_INCLUDES COMPONENT_LDFLAGS COMPONENT_SUBMODULES COMPONENT_LIBRARIES


# COMPONENT_PROJECT_VARS is the list of component_project_vars.mk generated makefiles
# for each component.
#
# Including $(COMPONENT_PROJECT_VARS) builds the COMPONENT_INCLUDES,
# COMPONENT_LDFLAGS variables and also targets for any inter-component
# dependencies.
#
# See the component_project_vars.mk target in component_wrapper.mk
COMPONENT_PROJECT_VARS := $(addsuffix /component_project_vars.mk,$(notdir $(COMPONENT_PATHS) ) $(TEST_COMPONENT_NAMES))
COMPONENT_PROJECT_VARS := $(addprefix $(BUILD_DIR_BASE)/,$(COMPONENT_PROJECT_VARS))
# this line is -include instead of include to prevent a spurious error message on make 3.81
-include $(COMPONENT_PROJECT_VARS)


# Also add top-level project include path, for top-level includes
COMPONENT_INCLUDES += $(abspath $(BUILD_DIR_BASE)/include/)
export COMPONENT_INCLUDES
DEFINED_VARIABLES +=COMPONENT_PROJECT_VARS COMPONENT_INCLUDES

# Set variables common to both project & component
include $(IDF_PATH)/make/bmptk_common.mk




all:
ifdef CONFIG_SECURE_BOOT_ENABLED
	@echo "(Secure boot enabled, so bootloader not flashed automatically. See 'make bootloader' output)"
ifndef CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES
	@echo "App built but not signed. Sign app & partition data before flashing, via espsecure.py:"
	@echo "espsecure.py sign_data --keyfile KEYFILE $(APP_BIN)"
	@echo "espsecure.py sign_data --keyfile KEYFILE $(PARTITION_TABLE_BIN)"
endif
	@echo "To flash app & partition table, run 'make flash' or:"
else
	@echo "To flash all build output, run 'make flash' or:"
endif
	@echo $(ESPTOOLPY_WRITE_FLASH) $(ESPTOOL_ALL_FLASH_ARGS)



IDF_VER := `cat ${IDF_PATH}/version.txt`
DEFINED_VARIABLES +=IDF_VER



# Set default LDFLAGS
EXTRA_LDFLAGS ?=
LDFLAGS ?= -nostdlib \
	-u call_user_start_cpu0	\
	$(EXTRA_LDFLAGS) \
	-Wl,--gc-sections	\
	-Wl,-static	\
	-Wl,--start-group	\
	$(COMPONENT_LDFLAGS) \
	-lgcc \
	-lstdc++ \
	-lgcov \
	-Wl,--end-group \
	-Wl,-EL

	
	
# Set default CPPFLAGS, CFLAGS, CXXFLAGS
# These are exported so that components can use them when compiling.
# If you need your component to add CFLAGS/etc for it's own source compilation only, set CFLAGS += in your component's Makefile.
# If you need your component to add CFLAGS/etc globally for all source
#  files, set CFLAGS += in your component's Makefile.projbuild
# If you need to set CFLAGS/CPPFLAGS/CXXFLAGS at project level, set them in application Makefile
#  before including project.mk. Default flags will be added before the ones provided in application Makefile.

# CPPFLAGS used by C preprocessor
# If any flags are defined in application Makefile, add them at the end. 
CPPFLAGS ?=
EXTRA_CPPFLAGS ?=
CPPFLAGS := -DESP_PLATFORM -D IDF_VER=\"$(IDF_VER)\" -MMD -MP $(CPPFLAGS) $(EXTRA_CPPFLAGS)


# Warnings-related flags relevant both for C and C++
COMMON_WARNING_FLAGS = -Wall -Werror=all \
	-Wno-error=unused-function \
	-Wno-error=unused-but-set-variable \
	-Wno-error=unused-variable \
	-Wno-error=deprecated-declarations \
	-Wextra \
	-Wno-unused-parameter -Wno-sign-compare

ifdef CONFIG_DISABLE_GCC8_WARNINGS
COMMON_WARNING_FLAGS += -Wno-parentheses \
	-Wno-sizeof-pointer-memaccess \
	-Wno-clobbered \
	-Wno-format-overflow \
	-Wno-stringop-truncation \
	-Wno-misleading-indentation \
	-Wno-cast-function-type \
	-Wno-implicit-fallthrough \
	-Wno-unused-const-variable \
	-Wno-switch-unreachable \
	-Wno-format-truncation \
	-Wno-memset-elt-size \
	-Wno-int-in-bool-context
endif

ifdef CONFIG_WARN_WRITE_STRINGS
COMMON_WARNING_FLAGS += -Wwrite-strings
endif #CONFIG_WARN_WRITE_STRINGS

# Flags which control code generation and dependency generation, both for C and C++
COMMON_FLAGS = \
	-ffunction-sections -fdata-sections \
	-fstrict-volatile-bitfields \
	-mlongcalls \
	-nostdlib


DEFINED_VARIABLES += EXTRA_LDFLAGS LDFLAGS CPPFLAGS EXTRA_CPPFLAGS CPPFLAGS COMMON_FLAGS COMMON_WARNING_FLAGS


ifndef IS_BOOTLOADER_BUILD
# stack protection (only one option can be selected in menuconfig)
ifdef CONFIG_STACK_CHECK_NORM
COMMON_FLAGS += -fstack-protector
endif
ifdef CONFIG_STACK_CHECK_STRONG
COMMON_FLAGS += -fstack-protector-strong
endif
ifdef CONFIG_STACK_CHECK_ALL
COMMON_FLAGS += -fstack-protector-all
endif
endif


# Optimization flags are set based on menuconfig choice
ifdef CONFIG_OPTIMIZATION_LEVEL_RELEASE
OPTIMIZATION_FLAGS = -Os
else
OPTIMIZATION_FLAGS = -Og
endif

ifdef CONFIG_OPTIMIZATION_ASSERTIONS_DISABLED
CPPFLAGS += -DNDEBUG
endif


# Enable generation of debugging symbols
# (we generate even in Release mode, as this has no impact on final binary size.)
DEBUG_FLAGS ?= -ggdb

DEFINED_VARIABLES +=OPTIMIZATION_FLAGS DEBUG_FLAGS




# List of flags to pass to C compiler
# If any flags are defined in application Makefile, add them at the end.
CFLAGS ?=
EXTRA_CFLAGS ?=
CFLAGS := $(strip \
	-std=gnu99 \
	$(OPTIMIZATION_FLAGS) $(DEBUG_FLAGS) \
	$(COMMON_FLAGS) \
	$(COMMON_WARNING_FLAGS) -Wno-old-style-declaration \
	$(CFLAGS) \
	$(EXTRA_CFLAGS))

# List of flags to pass to C++ compiler
# If any flags are defined in application Makefile, add them at the end.
CXXFLAGS ?=
EXTRA_CXXFLAGS ?=
CXXFLAGS := $(strip \
	-std=gnu++11 \
	-fno-rtti \
	$(OPTIMIZATION_FLAGS) $(DEBUG_FLAGS) \
	$(COMMON_FLAGS) \
	$(COMMON_WARNING_FLAGS) \
	$(CXXFLAGS) \
	$(EXTRA_CXXFLAGS))

ifdef CONFIG_CXX_EXCEPTIONS
CXXFLAGS += -fexceptions
else
CXXFLAGS += -fno-exceptions
endif

ARFLAGS := cru

export CFLAGS CPPFLAGS CXXFLAGS ARFLAGS
DEFINED_VARIABLES +=CFLAGS CPPFLAGS CXXFLAGS ARFLAGS


# Set default values that were not previously defined
CC ?= gcc
LD ?= ld
AR ?= ar
OBJCOPY ?= objcopy
SIZE ?= size

# Set host compiler and binutils
HOSTCC := $(CC)
HOSTLD := $(LD)
HOSTAR := $(AR)
HOSTOBJCOPY := $(OBJCOPY)
HOSTSIZE := $(SIZE)
export HOSTCC HOSTLD HOSTAR HOSTOBJCOPY SIZE
DEFINED_VARIABLES +=HOSTCC HOSTLD HOSTAR HOSTOBJCOPY SIZE


CONFIG_TOOLPREFIX := $(ESP_EABI)-
# Set target compiler. Defaults to whatever the user has
# configured as prefix + ye olde gcc commands
CC := $(CONFIG_TOOLPREFIX)gcc
CXX := $(CONFIG_TOOLPREFIX)c++
LD := $(CONFIG_TOOLPREFIX)ld
AR := $(CONFIG_TOOLPREFIX)ar
OBJCOPY := $(call dequote,$(CONFIG_TOOLPREFIX))objcopy
SIZE := $(call dequote,$(CONFIG_TOOLPREFIX))size
export CC CXX LD AR OBJCOPY SIZE
DEFINED_VARIABLES +=CC CXX LD AR OBJCOPY SIZE


# COMPILER_VERSION_STR := $(shell $(CC) -dumpversion)
COMPILER_VERSION_NUM := $(subst .,,$(COMPILER_VERSION_STR))
# GCC_NOT_5_2_0 := $(eval $(shell expr $(COMPILER_VERSION_STR) != "5.2.0"))
export COMPILER_VERSION_STR COMPILER_VERSION_NUM GCC_NOT_5_2_0
DEFINED_VARIABLES += COMPILER_VERSION_STR COMPILER_VERSION_NUM # GCC_NOT_5_2_0



CPPFLAGS += -DGCC_NOT_5_2_0=$(GCC_NOT_5_2_0)
export CPPFLAGS


# PYTHON=$(call dequote,$(CONFIG_PYTHON))


# the app is the main executable built by the project
APP_ELF:=$(BUILD_DIR_BASE)/$(PROJECT_NAME).elf
APP_MAP:=$(APP_ELF:.elf=.map)
APP_BIN:=$(APP_ELF:.elf=.bin)

DEFINED_VARIABLES +=PYTHON APP_ELF APP_MAP APP_BIN

# Include any Makefile.projbuild file letting components add
# configuration at the project level
define includeProjBuildMakefile
$(if $(V),$$(info including $(1)/Makefile.projbuild...))
COMPONENT_PATH := $(1)
include $(1)/Makefile.projbuild
endef
$(foreach componentpath,$(COMPONENT_PATHS), \
	$(if $(wildcard $(componentpath)/Makefile.projbuild), \
		$(eval $(call includeProjBuildMakefile,$(componentpath)))))


# once we know component paths, we can include the config generation targets
#
# (bootloader build doesn't need this, config is exported from top-level)
ifndef IS_BOOTLOADER_BUILD
include $(IDF_PATH)/make/bmptk_config.mk
endif

# ELF depends on the library archive files for COMPONENT_LIBRARIES
# the rules to build these are emitted as part of GenerateComponentTarget below
#
# also depends on additional dependencies (linker scripts & binary libraries)
# stored in COMPONENT_LINKER_DEPS, built via component.mk files' COMPONENT_ADD_LINKER_DEPS variable
COMPONENT_LINKER_DEPS ?=
$(APP_ELF): $(foreach libcomp,$(COMPONENT_LIBRARIES),$(BUILD_DIR_BASE)/$(libcomp)/lib$(libcomp).a) $(COMPONENT_LINKER_DEPS) $(COMPONENT_PROJECT_VARS)
	$(summary) LD $(patsubst $(PWD)/%,%,$@)
	$(CC) $(LDFLAGS) -o $@ -Wl,-Map=$(APP_MAP)


app: $(APP_BIN) partition_table_get_info
ifeq ("$(CONFIG_SECURE_BOOT_ENABLED)$(CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES)","y") # secure boot enabled, but remote sign app image
	@echo "App built but not signed. Signing step via espsecure.py:"
	@echo "espsecure.py sign_data --keyfile KEYFILE $(APP_BIN)"
	@echo "Then flash app command is:"
	@echo $(ESPTOOLPY_WRITE_FLASH) $(APP_OFFSET) $(APP_BIN)
else
	@echo "App built. Default flash app command is:"
	@echo $(ESPTOOLPY_WRITE_FLASH) $(APP_OFFSET) $(APP_BIN)
endif



.PHONY: check_python_dependencies

# Notify users when some of the required python packages are not installed
check_python_dependencies:
ifndef IS_BOOTLOADER_BUILD
	$(PYTHON) $(IDF_PATH)/tools/check_python_dependencies.py
endif


all_binaries: $(APP_BIN)


$(BUILD_DIR_BASE):
	mkdir -p $(BUILD_DIR_BASE)


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
	call ComponentMake,$(1),$(2)) clean


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
 

# $(foreach item,$(COMPONENT_PATHS), $(info $$ path: $(item)))


# $(eval generateSDK, $(BUILD_DIR_BASE), $(PROJECT_PATH))
# $(PYTHON_LOCATION)/python.exe $(IDF_PATH)/make/create_sdkconfig.py $(BUILD_DIR_BASE) $(PROJECT_PATH)

build: generateSDK generateComponents

generateSDK:
	$(PYTHON_LOCATION)/python.exe $(IDF_PATH)/make/create_sdkconfig.py $(BUILD_DIR_BASE) $(PROJECT_PATH)

generateComponents:
	@echo # Automatically generated build file. DO NOT EDIT! > $(PROJECT_PATH)/build/component_project_vars.mk
	@echo COMPONENT_INCLUDES += $(COMPONENT_INCLUDES) >> $(PROJECT_PATH)/build/component_project_vars.mk
	@echo COMPONENT_LDFLAGS += $(COMPONENT_LDFLAGS) >> $(PROJECT_PATH)/build/component_project_vars.mk
	@echo COMPONENT_LINKER_DEPS += $(COMPONENT_LINKER_DEPS) >> $(PROJECT_PATH)/build/component_project_vars.mk
	@echo COMPONENT_SUBMODULES += $(COMPONENT_SUBMODULES) >> $(PROJECT_PATH)/build/component_project_vars.mk
	@echo COMPONENT_LIBRARIES += $(COMPONENT_LIBRARIES) >> $(PROJECT_PATH)/build/component_project_vars.mk
	
define x:
include $(1)
endef

$(foreach component,$(COMPONENT_PATHS), \
	$(call x, $(component)/component.mk) )

# $(foreach component,$(TEST_COMPONENT_PATHS), $(eval $(call GenerateComponentTargets,$(component),$(lastword $(subst /, ,$(dir $(component))))_test) ) )

app-clean: $(addprefix component-,$(addsuffix -clean,$(notdir $(COMPONENT_PATHS))))
	$(summary) RM $(APP_ELF)
	rm -f $(APP_ELF) $(APP_BIN) $(APP_MAP)

size: $(APP_ELF) | check_python_dependencies
	$(PYTHON) $(IDF_PATH)/tools/idf_size.py $(APP_MAP)

size-files: $(APP_ELF) | check_python_dependencies
	$(PYTHON) $(IDF_PATH)/tools/idf_size.py --files $(APP_MAP)

size-components: $(APP_ELF) | check_python_dependencies
	$(PYTHON) $(IDF_PATH)/tools/idf_size.py --archives $(APP_MAP)

size-symbols: $(APP_ELF) | check_python_dependencies
ifndef COMPONENT
	$(error "ERROR: Please enter the component to look symbols for, e.g. COMPONENT=heap")
else
	$(PYTHON) $(IDF_PATH)/tools/idf_size.py --archive_details lib$(COMPONENT).a $(APP_MAP)
endif


# NB: this ordering is deliberate (app-clean & bootloader-clean before
# _config-clean), so config remains valid during all component clean
# targets
config-clean: app-clean bootloader-clean
clean: app-clean bootloader-clean config-clean













# PHONY target to list components in the build and their paths
list-components:
	$(info $(call dequote,$(SEPARATOR)))
	$(info COMPONENT_DIRS (components searched for here))
	$(foreach cd,$(COMPONENT_DIRS),$(info $(cd)))
	$(info $(call dequote,$(SEPARATOR)))
	$(info TEST_COMPONENTS (list of test component names))
	$(info $(TEST_COMPONENTS_LIST))
	$(info $(call dequote,$(SEPARATOR)))
	$(info TEST_EXCLUDE_COMPONENTS (list of test excluded names))
	$(info $(if $(EXCLUDE_COMPONENTS) || $(TEST_EXCLUDE_COMPONENTS),$(EXCLUDE_COMPONENTS) $(TEST_EXCLUDE_COMPONENTS),(none provided)))	
	$(info $(call dequote,$(SEPARATOR)))
	$(info COMPONENT_PATHS (paths to all components):)
	$(foreach cp,$(COMPONENT_PATHS),$(info $(cp)))

# print flash command, so users can dump this to config files and download somewhere without idf
print_flash_cmd: partition_table_get_info blank_ota_data
	echo $(ESPTOOL_WRITE_FLASH_OPTIONS) $(ESPTOOL_ALL_FLASH_ARGS) | sed -e 's:'$(PWD)/build/'::g'





TOOLCHAIN_PATH := $(GCC_LX6)
TOOLCHAIN_HEADER := $(shell $(TOOLCHAIN_PATH)/$(CC) --version )

TOOLCHAIN_GCC_VER := $(COMPILER_VERSION_STR)

DEFINED_VARIABLES+= TOOLCHAIN_HEADER TOOLCHAIN_PATH  TOOLCHAIN_GCC_VER


# Officially supported version(s)
include $(IDF_PATH)/tools/toolchain_versions.mk








include $(BMPTK)/drivers/esp/esp-idf/make/bmptk_config.mk
$(info $$ Exit File: bmptk/bmptk.mk)
