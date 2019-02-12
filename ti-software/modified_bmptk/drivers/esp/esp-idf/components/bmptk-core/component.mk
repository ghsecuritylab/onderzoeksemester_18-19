#
# Component Makefile
#
# ESP32 component source dirs 
COMPONENT_SRCDIRS := . src include
COMPONENT_ADD_INCLUDEDIRS := . include include/hwcrypto
COMPONENT_SOURCES := cpu_start.c \
					clk.c \
					task_wdt.c \
					panic.c \
					brownout.c \
					esp_timer.c \
					dbg_stubs.c \
					intr_alloc.c \
					int_wdt.c \
					cache_err_int.c \
					crosscore_int.c \
					dport_access.c \
					esp_timer_esp32.c \
					esp_err_to_name.c \
					system_api.c \
					pm_esp32.c

# Driver component sources
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += include/driver
COMPONENT_SOURCES += rtc_module.c uart.c periph_ctrl.c timer.c




# ESP_RINGBUF component sources
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += 
COMPONENT_SOURCES += ringbuf.c

# HEAP
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += 
COMPONENT_SOURCES += heap_caps.c multi_heap.c heap_trace.c heap_caps_init.c 

# FREERTOS
COMPONENT_SRCDIRS         += asm
COMPONENT_ADD_INCLUDEDIRS += include/freertos asm
COMPONENT_SOURCES +=  tasks.c event_groups.c timers.c queue.c  xtensa_intr.c list.c freertos_hooks.c port.c xtensa_init.c ipc.c
COMPONENT_SOURCES += xtensa_vector_defaults.S xtensa_intr_asm.S portasm.S xtensa_context.S xtensa_vectors.S


# NEWLIB
COMPONENT_SRCDIRS         += src/newlib include/newlib include/newlib/platform_include
COMPONENT_ADD_INCLUDEDIRS += include/newlib/platform_include include/newlib
COMPONENT_SOURCES += syscalls.c syscall_table.c reent_init.c time.c

# LOG
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += 
COMPONENT_SOURCES += log.c


# PTHREAD
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += 
COMPONENT_SOURCES += pthread.c pthread_local_storage.c


# SOC
COMPONENT_SRCDIRS         += include/esp32 
COMPONENT_ADD_INCLUDEDIRS += include/esp32 include/esp32/include
COMPONENT_SOURCES += rtc_wdt.c rtc_clk.c rtc_init.c cpu_util.c rtc_time.c memory_layout_utils.c soc_memory_layout.c rtc_periph.c
esp32/rtc_clk.o: CFLAGS += -fno-jump-tables -fno-tree-switch-conversion



# SPI_FLASH
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += 
COMPONENT_SRCDIRS += include/sim
COMPONENT_SOURCES += flash_ops.c spi_flash_rom_patch.c partition.c cache_utils.c flash_mmap.c esp_ota_eps.c

# VFS
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += 
COMPONENT_SOURCES += vfs_uart.c vfs.c


# XTENSA-DEBUG-MODULE
COMPONENT_SRCDIRS         += 
COMPONENT_ADD_INCLUDEDIRS += 
COMPONENT_SOURCES         += eri.c

# LWIP
COMPONENT_ADD_INCLUDEDIRS += \
	include/apps \
	include/lwip/src/include \
	include/lwip/src/include/lwip \
	include/port/esp32/include \
	include/port/esp32/include/arch \
	include/include_compat

COMPONENT_SRCDIRS +=	include/apps/dhcpserver \
	include/apps/ping \
	include/lwip/src/api \
	include/lwip/src/apps/sntp \
	include/lwip/src/core \
	include/lwip/src/core/ipv4 \
	include/lwip/src/core/ipv6 \
	include/lwip/src/netif \
	include/port/esp32 \
	include/port/esp32/freertos \
	include/port/esp32/netif \
	include/port/esp32/debug

				
# COMPONENT_SOURCES := cache_sram_mmu.c \
#        coexist.c \
#        core_dump.c \
#        esp_himem.c \
#        ets_timer_legacy.c \
#        event_default_handlers.c \
#        event_loop.c \
#        fast_crypto_ops.c \
#        freertos_hooks.c \
#        gdbstub.c \
#        hw_random.c \
#        ipc.c \
#        lib_printf.c \
#        phy_init.c \
#        pm_locks.c \
#        pm_trace.c \
#        reset_reason.c \
#        restore.c \
#        sleep_modes.c \
#        spiram.c \
#        spiram_psram.c \
#        stack_check.c \
#        wifi_init.c \
#        wifi_os_adapter.c 


COMPONENT_EXTRA_CLEAN := esp32_out.ld


