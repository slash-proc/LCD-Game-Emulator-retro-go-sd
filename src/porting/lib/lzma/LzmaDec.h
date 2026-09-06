/* Minimal stub — lzma_inflate is provided by the firmware ABI / host stub. */
#pragma once

#include <stddef.h>
#include <stdint.h>

typedef struct ISzAlloc {
    void *(*Alloc)(struct ISzAlloc *p, size_t size);
    void (*Free)(struct ISzAlloc *p, void *address);
} ISzAlloc;
