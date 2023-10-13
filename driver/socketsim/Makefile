CXXFLAGS += -std=c++11 -Wall -Wextra -Wfatal-errors

CXXFLAGS += -fPIC -Wno-maybe-uninitialized -g
CXXFLAGS += -I../include -I../common -I../../hw -I../../sim/common -I../../third_party/socket-lib
CXXFLAGS += $(CONFIGS)
CXXFLAGS += -DDUMP_PERF_STATS

LDFLAGS += -shared -pthread
LDFLAGS += -L../../third_party/socket-lib -lsocketlib

SRCS = vortex.cpp ../common/vx_utils.cpp

# Debugigng
ifdef DEBUG
	CXXFLAGS += -g -O0
else    
	CXXFLAGS += -O2 -DNDEBUG
endif

PROJECT = libvortex.so

all: $(PROJECT) libsocketlib.so

$(PROJECT): $(SRCS)
	$(CXX) $(CXXFLAGS) $^ $(LDFLAGS) -o $@

libsocketlib.so: ../../third_party/socket-lib/libsocketlib.so
	cp $^ $@

clean:
	rm -rf $(PROJECT) *.o
