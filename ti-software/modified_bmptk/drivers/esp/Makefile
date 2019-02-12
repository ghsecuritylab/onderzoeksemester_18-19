

.PHONY: all
IDF_PATH := C:/ti-software/bmptk/drivers/esp/esp-idf
BUILD_DIR_BASE := C:/ti-software/workspace/hello_world_test
KCONFIG_TOOL_DIR=$(IDF_PATH)/tools/kconfig
MKDIR_P = mkdir -p



export IDF_CMAKE=n 

all:
	python generate_config.py $(IDF_PATH) $(BUILD_DIR_BASE) $(KCONFIG_TOOL_DIR) conf-idf --olddefconfig


	
