CXXFLAGS += -std=c++11 -Wall -Wextra -Wfatal-errors

CXXFLAGS += -fPIC -Wno-maybe-uninitialized -g
CXXFLAGS += -I../include -I../common -I../../hw -I../../sim/common -I../../third_party/socketlib
CXXFLAGS += $(CONFIGS)
CXXFLAGS += -DDUMP_PERF_STATS

LDFLAGS += -shared -pthread
LDFLAGS += -L../../third_party/socketlib -lsocketlib

SRCS = vortex.cpp ../common/vx_utils.cpp

# Debugigng
ifdef DEBUG
	CXXFLAGS += -g -O0
else    
	CXXFLAGS += -O2 -DNDEBUG
endif

PROJECT = libvortex.so
PROJ_STATIC = libvortex.a

all: $(PROJECT) $(PROJ_STATIC) libsocketlib.so

$(PROJECT): $(SRCS)
	$(CXX) $(CXXFLAGS) $^ $(LDFLAGS) -o $@

libsocketlib.so: ../../third_party/socketlib/libsocketlib.so
	cp $^ $@

clean:
	rm -rf $(PROJECT) *.o
	rm -f *.so
	rm -f *.a

# RISCV cross compilation
CXX_RISCV = riscv64-unknown-linux-gnu-g++
AR_RISCV = riscv64-unknown-linux-gnu-ar

# remove the comment for running CPU sim only
# ROCKET_CPU_SIM = -D ROCKET_CPU_SIM

vortex.o: vortex.cpp
	$(CXX_RISCV) $(ROCKET_CPU_SIM) -c $(CXXFLAGS) $^ -o $@

vx_utils.o: ../common/vx_utils.cpp
	$(CXX_RISCV) -c $(CXXFLAGS) $^ -o $@

socketlib.o: ../../third_party/socketlib/socketlib.cc
	$(CXX_RISCV) -D RISCV_COMPILATION -c $(CXXFLAGS) $^ -o $@

$(PROJ_STATIC): vortex.o vx_utils.o socketlib.o
	$(AR_RISCV) rcs $@ $^