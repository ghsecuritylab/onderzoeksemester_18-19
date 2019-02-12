
# This makefile will fill the required flags for the ESP build


# ======================================
# ==            CORE FLAGS            ==   
# ======================================    

COREFLAGS       += -nostdlib





# ======================================
# ==            LD FLAGS              ==   
# ======================================    

# Default LD flags
# --------- 
LDFLAGS += -nostdlib 
LDFLAGS += -u call_user_start_cpu0   
LDFLAGS += $(EXTRA_LDFLAGS) 
LDFLAGS += -Wl,--gc-sections   
LDFLAGS += -Wl,-static   
LDFLAGS += -Wl,--start-group   
LDFLAGS += $(COMPONENT_LDFLAGS) 
LDFLAGS += -lgcc 
LDFLAGS += -lstdc++ 
LDFLAGS += -lgcov 
LDFLAGS += -Wl,-EL
LDFLAGS += -nostartfiles -lm -lc 


# Enable bootloader build
# --------- 
LDFLAGS	+= -D BOOTLOADER_BUILD=1

# LD files
# --------- 
LDFLAGS	  += -T $(ESP_TARGET)/bootloader/subproject/main/esp32.bootloader.ld
LDFLAGS   += -T $(ESP_CORE)/ld/esp32.peripherals.ld
LDFLAGS   += -T $(ESP_CORE)/ld/esp32.rom.spiram_incompatible_fns.ld
LDFLAGS   += -T $(ESP_CORE)/ld/esp32.rom.ld 
LDFLAGS	  += -T $(ESP_TARGET)/bootloader/subproject/main/esp32.bootloader.rom.ld
LDFLAGS   += -T$(PROJECT_PATH)/esp32_out.ld  
LDFLAGS   += -T $(ESP_CORE)/ld/esp32.extram.bss.ld
LDFLAGS   += -T $(ESP_CORE)/ld/esp32.common.ld
# LDFLAGS   += -T $(ESP_CORE)/ld/esp32.rom.libgcc.ld
LDFLAGS   += -T $(ESP_CORE)/ld/esp32.rom.redefined.ld
# LDFLAGS   += -T $(ESP_CORE)/ld/esp32.spiram.rom-functions-iram.ld
# LDFLAGS   += -T $(ESP_CORE)/ld/esp32.rom.nanofmt.ld
# LDFLAGS   += -T $(ESP_CORE)/ld/esp32.rom.spiflash.ld
# LDFLAGS   += -T $(ESP_CORE)/ld/esp32.spiram.rom-functions-dram.ld

# Libraries
# --------- 
# LDFLAGS		+= $(ESP_CORE)/libhal.a
LDFLAGS		+= -L$(ESP_CORE)/lib
LDFLAGS		+= -L $(ESP_CORE)/ld
LDFLAGS     += -L$(IDF_PATH)/components/pthread
LDFLAGS     += -L$(IDF_PATH)/components/pthread/include
# LDFLAGS   += -T $(LN_TEMPLATE)






IDF_VER = v3.1
export IDF_VER





# ======================================
# ==            Library FLAGS         ==   
# ====================================== 

LIBS += $(ESP_CORE)/lib/libcore.a 
LIBS += $(ESP_CORE)/lib/librtc.a 
LIBS += $(ESP_CORE)/lib/libnet80211.a 
LIBS += $(ESP_CORE)/lib/libpp.a 
LIBS += $(ESP_CORE)/lib/libwpa.a 
LIBS += $(ESP_CORE)/lib/libsmartconfig.a 
LIBS += $(ESP_CORE)/lib/libcoexist.a 
LIBS += $(ESP_CORE)/lib/libwps.a 
LIBS += $(ESP_CORE)/lib/libwpa2.a 
LIBS += $(ESP_CORE)/lib/libespnow.a 
LIBS += $(ESP_CORE)/lib/libphy.a 
LIBS += $(ESP_CORE)/lib/libmesh.a




# ======================================
# ==        Create Objects            ==   
# ====================================== 

PTHREAD_SEARCH := $(IDF_PATH)/components/pthread $(IDF_PATH)/components/pthread/include


