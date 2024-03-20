PROJECT_NAME = spirit_forest
VERSION      = 0
GAMEID       = SPRF
TITLE        = SPIRIFOREST
LICENSEE     = HB # Homebrew
OLD_LICENSEE = 0x33 # Required for SGB compatibility
CART_TYPE    = MBC3+RAM+BATTERY
RGBDS_HOME   =
RUNNER       = mgba-qt

OBJDIR   = obj/
SRCDIR   = src/
INCLUDES = $(SRCDIR) $(OBJDIR)
IMGDIR   = data/images/
TSXDIR   = data/tilesets/
LVLDIR   = data/levels/

ASM     = $(RGBDS_HOME)rgbasm
GFX     = $(RGBDS_HOME)rgbgfx
LINK    = $(RGBDS_HOME)rgblink
FIX     = $(RGBDS_HOME)rgbfix
RM      = rm -f
MKDIR   = mkdir -p
TMX2BLK = tools/tmx2blk
TMX2LVL = tools/tmx2lvl

BIN  = $(PROJECT_NAME).gb
SYM  = $(PROJECT_NAME).sym
SRCS = $(wildcard $(SRCDIR)*.asm)
OBJS = $(SRCS:%.asm=$(OBJDIR)%.o)

IMG_1BPP = $(wildcard $(IMGDIR)*.1bpp.png)
IMG_2BPP = $(wildcard $(IMGDIR)*.2bpp.png)
IMG_TMAP = $(wildcard $(IMGDIR)*.tmap.png)
BLOCKSET = $(wildcard $(TSXDIR)*.blk.tmx)
LEVELSET = $(wildcard $(LVLDIR)*.lvl.tmx)

DATA = $(IMG_1BPP:%.png=$(OBJDIR)%) \
		$(IMG_2BPP:%.png=$(OBJDIR)%) \
		$(BLOCKSET:%.tmx=$(OBJDIR)%) \
		$(LEVELSET:%.tmx=$(OBJDIR)%) \
		$(IMG_TMAP:%.png=$(OBJDIR)%) \
		$(IMG_TMAP:%.tmap.png=$(OBJDIR)%.2bpp)

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

.PHONY: all rebuild run clean

all: $(BIN)

rebuild: clean all

run: $(BIN)
	$(RUNNER) $(BIN)

$(BIN): $(DATA) $(LEVELS) $(OBJS)
	$(LINK) $(LINK_FLAGS) -o $(BIN) -n $(SYM) $(OBJS)
	$(FIX) $(FIX_FLAGS) $(BIN)

$(OBJDIR)%.o: %.asm
	@$(MKDIR) $(dir $@)
	$(ASM) $(ASM_FLAGS) -o $@ $<

$(OBJDIR)%.1bpp: %.1bpp.png
	@$(MKDIR) $(dir $@)
	$(GFX) $(GFX_FLAGS) $(GFX_1BPP_FLAGS) -o $@ $<

$(OBJDIR)%.2bpp: %.2bpp.png
	@$(MKDIR) $(dir $@)
	$(GFX) $(GFX_FLAGS) $(GFX_2BPP_FLAGS) -o $@ $<

$(OBJDIR)%.tmap $(OBJDIR)%.2bpp: %.tmap.png
	@$(MKDIR) $(dir $@)
	$(GFX) $(GFX_FLAGS) $(GFX_2BPP_FLAGS) -o $(OBJDIR)$*.2bpp -t $(OBJDIR)$*.tmap -u $<

$(OBJDIR)%.blk: %.blk.tmx
	@$(MKDIR) $(dir $@)
	$(TMX2BLK) $< $@

$(OBJDIR)%.lvl: %.lvl.tmx
	@$(MKDIR) $(dir $@)
	$(TMX2LVL) $< $@

clean:
	$(RM) $(BIN) $(SYM) $(OBJS) $(DATA)

