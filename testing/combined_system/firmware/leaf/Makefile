CONTIKI_PROJECT=pilot
LDLIBS += -lm
CONTIKI=../../../tools/contiki-ng
CFLAGS += -DLEAF_BUILD
LDFLAGS += -L../../../tools/msp430/msp430/lib/ldscripts/msp430f2617
all: $(CONTIKI_PROJECT)
include $(CONTIKI)/Makefile.include
