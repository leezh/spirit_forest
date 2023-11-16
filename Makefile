PROJECT_NAME = spirit_forest
VERSION      = 0
GAMEID       = SPRF
TITLE        = SPIRIFOREST
LICENSEE     = HB
OLD_LICENSEE = 0x33
CART_TYPE    = MBC3+RAM+BATTERY

OBJDIR   = obj/
SRCDIR   = src/
INCLUDES = $(SRCDIR)

ASM    = rgbasm
GFX    = rgbgfx
LINK   = rgblink
FIX    = rgbfix
RM     = rm -f
MKDIR  = mkdir -p
RUNNER = flatpak run io.mgba.mGBA

BIN  = $(PROJECT_NAME).gb
SYM  = $(OBJDIR)$(PROJECT_NAME).sym
SRCS = $(notdir $(wildcard $(SRCDIR)*.asm))
OBJS = $(SRCS:%.asm=$(OBJDIR)%.o)

ASM_FLAGS += -l $(addprefix -I,$(INCLUDES))

GFX_FLAGS +=

LINK_FLAGS +=

FIX_FLAGS += -v
FIX_FLAGS += -p 0xFF
FIX_FLAGS += -i $(GAMEID)
FIX_FLAGS += -k $(LICENSEE)
FIX_FLAGS += -l $(OLD_LICENSEE)
FIX_FLAGS += -n $(VERSION)
FIX_FLAGS += -t $(TITLE)
FIX_FLAGS += -m $(CART_TYPE)


all: $(BIN)

rebuild: clean all

run: $(BIN)
	$(RUNNER) $(BIN) &> /dev/null

$(BIN): $(OBJDIR) $(OBJS)
	$(LINK) $(LINK_FLAGS) -o $(BIN) -n $(SYM) $(OBJS)
	$(FIX) $(FIX_FLAGS) $(BIN)

$(OBJDIR)%.o: $(SRCDIR)%.asm
	$(ASM) $(ASM_FLAGS) -o $@ $<

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(BIN) $(SYM) $(OBJS)
