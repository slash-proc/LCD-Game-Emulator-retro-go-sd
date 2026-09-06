/*
 * Soft stubs for firmware ABI codecs the GW ROM loader expects.
 * Device builds route these through gw_core_bridge redefine-syms.
 */

#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <stdio.h>

#include "hw_jpeg_decoder.h"
#include "lzma.h"

void GW_SetUnixTM(struct tm *tm)
{
    (void)tm;
    /* Host preview does not write the system clock. */
}

uint32_t JPEG_DecodeToFrameInit(uint32_t JPEG_Buffer, uint32_t JPEG_Buffer_Size)
{
    (void)JPEG_Buffer;
    (void)JPEG_Buffer_Size;
    return 1;
}

uint32_t JPEG_DecodeToFrame(uint32_t SrcAddress, uint32_t DestAddress,
                            uint16_t x, uint16_t y, uint8_t luma_alpha)
{
    (void)SrcAddress;
    (void)DestAddress;
    (void)x;
    (void)y;
    (void)luma_alpha;
    return 1;
}

uint32_t JPEG_DecodeGetSize(uint32_t SrcAddress, uint32_t *width, uint32_t *height)
{
    (void)SrcAddress;
    if (width)
        *width = 0;
    if (height)
        *height = 0;
    return 1;
}

uint32_t JPEG_DecodeDeInit(void)
{
    return 0;
}

uint32_t JPEG_DecodeToBufferInit(uint32_t JPEG_Buffer, uint32_t JPEG_Buffer_Size)
{
    (void)JPEG_Buffer;
    (void)JPEG_Buffer_Size;
    return 1;
}

uint32_t JPEG_DecodeToBuffer(uint32_t SrcAddress, uint32_t DestAddress,
                             uint32_t *width, uint32_t *height, uint8_t luma_alpha)
{
    (void)SrcAddress;
    (void)DestAddress;
    (void)width;
    (void)height;
    (void)luma_alpha;
    return 1;
}

const uint8_t lzma_prop_data[5] = {0};

void lzma_init_allocs(ISzAlloc *allocs, uint8_t *heap)
{
    (void)allocs;
    (void)heap;
}

size_t lzma_inflate(uint8_t *dst, size_t dst_size, const uint8_t *src, size_t src_size)
{
    (void)dst;
    (void)dst_size;
    (void)src;
    (void)src_size;
    fprintf(stderr, "host: lzma_inflate not implemented — use uncompressed or LZ4 .gw\n");
    return 0;
}
