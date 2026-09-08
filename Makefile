# LCD-Game-Emulator — Nintendo Game & Watch / LCD handhelds core for Retro-Go SD.
#
#   make                  — build + pack → LCD-Game-Emulator.bin
#   make host             — Linux/macOS SDL preview (pass a .gw ROM)
#   make docker           — ARM build inside the firmware builder image
#
# Drop LCD-Game-Emulator.bin on the SD card under /cores/. ROMs under /roms/gw/.
# Hot CPU/gfx code links into ITCM; large ROM/JPEG buffers stay in RAM_EMU.
# Verbose: make V=

#######################################
# Project identity
#######################################
PROJECT_KIND ?= core

CORE_NAME  := gw
CORE_ENTRY := app_main_gw
ROM_DIRNAME := gw

CORE_C_SOURCES := \
src/cpus/sm500op.c \
src/cpus/sm510op.c \
src/cpus/sm500core.c \
src/cpus/sm5acore.c \
src/cpus/sm510core.c \
src/cpus/sm511core.c \
src/cpus/sm510base.c \
src/gw_sys/gw_romloader.c \
src/gw_sys/gw_graphic.c \
src/gw_sys/gw_system.c \
src/main.c \
src/gw_i18n.c

CORE_C_INCLUDES := \
-Isrc \
-Isrc/cpus \
-Isrc/gw_sys \
-Isrc/porting/lib \
-Isrc/porting/lib/lzma

# Relative path so Docker bind-mounts work (do NOT use $(abspath)).
GNW_CORE_SDK ?= sdk
BUILD_DIR ?= build/$(PROJECT_KIND)

#######################################
# Kind-specific compile defs + packing
#######################################
ifeq ($(PROJECT_KIND),core)
CORE_C_DEFS := \
-DTARGET_GNW \
-DPROJECT_KIND_CORE=1 \
-DCOVERFLOW=1 \
-DCHEAT_CODES=1 \
-DMAX_CHEAT_CODES=13

PACKED_BIN  := LCD-Game-Emulator.bin
PAD_LOGO    := src/assets/pad.bmp
HEADER_LOGO := src/assets/header.bmp
# icons/c_gw.bmp + h_gw.bmp are light-on-dark; --logo-invert restores lit glyphs.

else
$(error LCD-Game-Emulator is a dynamic core only (PROJECT_KIND=core); got '$(PROJECT_KIND)')
endif

CORE_LDSCRIPT := ld/gw_core.ld
CORE_EXTRA_SEGMENTS := itcm:core_itcm

include $(GNW_CORE_SDK)/Makefile

# LCD-Game-Emulator uses C99-style `inline` without static/extern in sm5xx
# cores. Without gnu89 semantics the linker loses sm510_div_timer / …
CFLAGS += -fgnu89-inline

PACK_CORE := $(GNW_CORE_SDK)/tools/pack_core.py

#######################################
# Packed header version
#######################################
CORE_VERSION ?= $(shell git describe --tags --dirty 2>/dev/null || echo NOTAG)

#######################################
# Pack
#######################################
.PHONY: pack

pack: $(TARGET_BIN) $(BUILD_DIR)/$(CORE_NAME)_core_itcm.bin $(PAD_LOGO) $(HEADER_LOGO)
	$(V)$(ECHO) [ PACK CORE ] $(PACKED_BIN) version=$(CORE_VERSION)
	$(V)python3 $(PACK_CORE) \
		--elf $(TARGET_ELF) --bin $(TARGET_BIN) \
		--system-name "Game & Watch" --dirname $(ROM_DIRNAME) \
		--extensions "gw" \
		--core-name "LCD-Game-Emulator" \
		--version "$(CORE_VERSION)" \
		--pad-logo $(PAD_LOGO) \
		--header-logo $(HEADER_LOGO) \
		--logo-invert \
		--out $(PACKED_BIN)

all: pack

.PHONY: print-PROJECT_KIND print-PACKED_BIN print-SIDECARS print-RO_BIN print-CORE_NAME print-ROM_DIRNAME print-DOCKER_IMAGE \
	print-TARGET_ELF print-TARGET_MAP print-CORE_VERSION
print-PROJECT_KIND:
	@echo $(PROJECT_KIND)
print-PACKED_BIN:
	@echo $(PACKED_BIN)
# Extra device files installed beside PACKED_BIN, space separated.
print-SIDECARS:
	@echo $(SIDECARS)
print-RO_BIN:
	@echo $(RO_BIN)
print-CORE_NAME:
	@echo $(CORE_NAME)
print-ROM_DIRNAME:
	@echo $(ROM_DIRNAME)
print-DOCKER_IMAGE:
	@echo $(DOCKER_IMAGE)
print-TARGET_ELF:
	@echo $(TARGET_ELF)
print-TARGET_MAP:
	@echo $(BUILD_DIR)/$(CORE_NAME)_core.map
print-CORE_VERSION:
	@echo $(CORE_VERSION)

clean::
	$(V)rm -f $(PACKED_BIN)

#######################################
# Docker
#######################################
.PHONY: docker docker_pull docker_shell

RELEASE_VERSION ?= v1.5
DOCKER_REPOSITORY ?= sylverb/retro-go-sd-builder
DOCKER_IMAGE ?= $(DOCKER_REPOSITORY):$(RELEASE_VERSION)

DOCKER_TTY_FLAG := $(shell if [ -t 0 ]; then echo -it; else echo; fi)
DOCKER_USER := $(shell id -u):$(shell id -g)
DOCKER_RUN := docker run --rm $(DOCKER_TTY_FLAG) \
	--user $(DOCKER_USER) \
	-v "$(CURDIR):/opt/workdir" \
	-w /opt/workdir \
	$(DOCKER_IMAGE)

docker:
	$(V)$(ECHO) "[ DOCKER ]" $(DOCKER_IMAGE) "PROJECT_KIND=$(PROJECT_KIND)"
	$(V)$(DOCKER_RUN) make --no-print-directory -j$$(nproc) PROJECT_KIND=$(PROJECT_KIND)

docker_pull:
	$(V)$(ECHO) "[ PULL ]" $(DOCKER_IMAGE)
	$(V)docker pull $(DOCKER_IMAGE)

docker_shell:
	$(DOCKER_RUN) bash

#######################################
# Host SDL (Linux / macOS)
#######################################
include host/Makefile.host
