PROJECT_NAME = spirit_forest
VERSION      = 0
GAMEID       = SPRF
TITLE        = SPIRIFOREST
LICENSEE     = HB # Homebrew
OLD_LICENSEE = 0x33 # Required for SGB compatibility
CART_TYPE    = MBC3+RAM+BATTERY
RGBDS_HOME   =
RUNNER       = mgba

OBJDIR   = obj/
SRCDIR   = src/
RESDIR   = res/
INCLUDES = $(SRCDIR) $(OBJDIR)

ASM    = $(RGBDS_HOME)rgbasm
GFX    = $(RGBDS_HOME)rgbgfx
LINK   = $(RGBDS_HOME)rgblink
FIX    = $(RGBDS_HOME)rgbfix
RM     = rm -f
MKDIR  = mkdir -p

BIN  = $(PROJECT_NAME).gb
SYM  = $(PROJECT_NAME).sym
SRCS = $(notdir $(wildcard $(SRCDIR)*.asm))
OBJS = $(SRCS:%.asm=$(OBJDIR)%.o)
PNG1 = $(notdir $(wildcard $(RESDIR)*.1bpp.png))
PNG2 = $(notdir $(wildcard $(RESDIR)*.2bpp.png))
IMGS = $(PNG1:%.png=$(OBJDIR)%) $(PNG2:%.png=$(OBJDIR)%)

ASM_FLAGS += $(addprefix -I,$(INCLUDES))

GFX_FLAGS +=
GFX_1BPP_FLAGS += -d 1
GFX_2BPP_FLAGS += -d 2 -c embedded

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
	$(RUNNER) $(BIN)

images: $(IMGS)

$(BIN): $(OBJDIR) $(IMGS) $(OBJS)
	$(LINK) $(LINK_FLAGS) -o $(BIN) -n $(SYM) $(OBJS)
	$(FIX) $(FIX_FLAGS) $(BIN)

$(OBJDIR)%.o: $(SRCDIR)%.asm
	$(ASM) $(ASM_FLAGS) -o $@ $<

$(OBJDIR)%.1bpp: $(RESDIR)%.1bpp.png
	$(GFX) $(GFX_FLAGS) $(GFX_1BPP_FLAGS) -o $@ $< @$(RESDIR)$*.flags

$(OBJDIR)%.2bpp: $(RESDIR)%.2bpp.png
	$(GFX) $(GFX_FLAGS) $(GFX_2BPP_FLAGS) -o $@ $< @$(RESDIR)$*.flags

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(BIN) $(SYM) $(OBJS) $(IMGS)

