#pragma once
#include <stdint.h>

namespace vortex {

class ArchDef;
class RAM;

class Processor {
public:
  Processor(const ArchDef& arch);
  ~Processor();

  void attach_ram(RAM* mem);

  int run();

private:
  class Impl;
  Impl* impl_;
};

struct read_req {
  uint32_t addr;
  uint32_t size;
};

struct write_req {
  uint32_t addr;
  uint32_t size;
};

}
