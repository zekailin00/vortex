#pragma once

#include <cstdint>

uint64_t aligned_size(uint64_t size, uint64_t alignment);

bool is_aligned(uint64_t addr, uint64_t alignment);

#define CACHE_BLOCK_SIZE    64
#define ALLOC_BASE_ADDR     0xc0000000ULL
#define LOCAL_MEM_SIZE      1073741824ULL     // 1 GB
#define ALLOC_MAX_ADDR      0x100000000ULL
