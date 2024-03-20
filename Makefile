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
1BPP_DIR = data/tilesets-1bpp/
2BPP_DIR = data/tilesets/
IMAGEDIR = data/images/
BLOCKDIR = data/blocksets/
LEVELDIR = data/levels/

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
SRCS = $(notdir $(wildcard $(SRCDIR)*.asm))
OBJS = $(SRCS:%.asm=$(OBJDIR)%.o)

IMG_1BPP = $(notdir $(wildcard $(1BPP_DIR)*.png))
IMG_2BPP = $(notdir $(wildcard $(2BPP_DIR)*.png))
IMG_BLIT = $(notdir $(wildcard $(IMAGEDIR)*.png))
IMGS = $(IMG_1BPP:%.png=$(OBJDIR)%.1bpp) \
	   $(IMG_2BPP:%.png=$(OBJDIR)%.2bpp) \
	   $(IMG_BLIT:%.png=$(OBJDIR)%.tilemap) \
	   $(IMG_BLIT:%.png=$(OBJDIR)%.2bpp)

BLOCKSET = $(notdir $(wildcard $(BLOCKDIR)*.tmx))
LEVELSET = $(notdir $(wildcard $(LEVELDIR)*.tmx))
LEVELS = $(BLOCKSET:%.tmx=$(OBJDIR)%.blk) \
	     $(LEVELSET:%.tmx=$(OBJDIR)%.lvl) \

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

.PHONY: all rebuild run clean images

all: $(BIN)

rebuild: clean all

run: $(BIN)
	$(RUNNER) $(BIN)

images: $(IMGS)

$(BIN): $(OBJDIR) $(IMGS) $(LEVELS) $(OBJS)
	$(LINK) $(LINK_FLAGS) -o $(BIN) -n $(SYM) $(OBJS)
	$(FIX) $(FIX_FLAGS) $(BIN)

$(OBJDIR)%.o: $(SRCDIR)%.asm
	$(ASM) $(ASM_FLAGS) -o $@ $<

$(OBJDIR)%.1bpp: $(1BPP_DIR)%.png
	$(GFX) $(GFX_FLAGS) $(GFX_1BPP_FLAGS) -o $@ $<

$(OBJDIR)%.2bpp: $(2BPP_DIR)%.png
	$(GFX) $(GFX_FLAGS) $(GFX_2BPP_FLAGS) -o $@ $<

$(OBJDIR)%.tilemap $(OBJDIR)%.2bpp: $(IMAGEDIR)%.png
	$(GFX) $(GFX_FLAGS) $(GFX_2BPP_FLAGS) -o $(OBJDIR)$*.2bpp -t $(OBJDIR)$*.tilemap -u $<

$(OBJDIR)%.blk: $(BLOCKDIR)%.tmx
	$(TMX2BLK) $< $@

$(OBJDIR)%.lvl: $(LEVELDIR)%.tmx
	$(TMX2LVL) $< $@

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(BIN) $(SYM) $(OBJS) $(LEVELS) $(IMGS)

