/*
 * LCD-Game-Emulator core — RAM_EMU + ITCM (hot code only).
 *
 * Hot CPU/gfx translation units run from ITCM (zero-wait I-fetch). All
 * .data / .bss / .rodata stay in RAM_EMU — do not park ROM buffers or CPU
 * RAM in ITCM (AHB is also tight on SD firmware; large buffers belong here
 * or in the DTCM bump via dtc_* at runtime).
 *
 * main.o + gw_romloader.o + i18n + the ABI bridge stay in RAM_EMU.
 */

INCLUDE gnw_ram_emu.ld
INCLUDE gnw_itcm_core.ld

MEMORY
{
  RAM_EMU (xrw) : ORIGIN = __RAM_EMU_START__, LENGTH = __RAM_EMU_LENGTH__
  ITCM    (xrw) : ORIGIN = __ITCM_CORE_START__, LENGTH = __ITCM_CORE_LENGTH__
}

PHDRS
{
  text PT_LOAD FLAGS(5); /* PF_R | PF_X */
  data PT_LOAD FLAGS(6); /* PF_R | PF_W */
  itcm PT_LOAD FLAGS(5); /* PF_R | PF_X — loadaddr in RAM_EMU for pack */
}

/* Exact BUILD_DIR object paths (see Makefile BUILD_DIR=build/$(PROJECT_KIND)).
 * Do not use *sm510op.o-style globs: they can accidentally match other .o. */
SECTIONS
{
  .core_entry __RAM_EMU_START__ :
  {
    KEEP(*(.core_entry))
    KEEP(*(.gw_core_bridge_probe))
    . = ALIGN(4);
    EXCLUDE_FILE(
      build/core/sm500op.o
      build/core/sm510op.o
      build/core/sm500core.o
      build/core/sm5acore.o
      build/core/sm510core.o
      build/core/sm511core.o
      build/core/sm510base.o
      build/core/gw_graphic.o
      build/core/gw_system.o
    ) *(.text*)
    *(.rodata*)
    *(.glue_7)
    *(.glue_7t)

    . = ALIGN(4);
    __CORE_INIT_ARRAY_START__ = .;
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array*))
    __CORE_INIT_ARRAY_END__ = .;
  } >RAM_EMU :text

  .data :
  {
    *(.data*)
  } >RAM_EMU :data

  __CORE_CODE_END__ = .;

  .bss (NOLOAD) :
  {
    . = ALIGN(8);
    *(.bss*)
    *(COMMON)
    . = ALIGN(8);
  } >RAM_EMU :data

  __CORE_BSS_END__ = .;

  ASSERT(__CORE_BSS_END__ <= __RAM_EMU_END__,
         "Error: GW core RAM_EMU segment overflows RAM_EMU")

  /* ITCM: hot code only — AT>RAM_EMU so pack_core can extract load bytes. */
  .core_itcm __ITCM_CORE_START__ :
  {
    __CORE_ITCM_CODE_START__ = .;
    build/core/sm500op.o(.text*)
    build/core/sm510op.o(.text*)
    build/core/sm500core.o(.text*)
    build/core/sm5acore.o(.text*)
    build/core/sm510core.o(.text*)
    build/core/sm511core.o(.text*)
    build/core/sm510base.o(.text*)
    build/core/gw_graphic.o(.text*)
    build/core/gw_system.o(.text*)
    . = ALIGN(4);
    __CORE_ITCM_CODE_END__ = .;
  } >ITCM AT>RAM_EMU :itcm

  __CORE_ITCM_BSS_END__ = __CORE_ITCM_CODE_END__;

  ASSERT(__CORE_ITCM_BSS_END__ <= __ITCM_CORE_START__ + __ITCM_CORE_LENGTH__,
         "Error: GW core ITCM segment overflows the 64K ITCM region")

  __exidx_start = .;
  __exidx_end = .;

  /DISCARD/ :
  {
    *(.fini_array*)
    *(.preinit_array*)
    *(.ARM.exidx*)
    *(.ARM.extab*)
    *(.comment)
    *(.ARM.attributes)
  }
}
