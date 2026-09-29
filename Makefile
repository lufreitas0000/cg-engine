.PHONY: all test clean check-fonts test-lua test-fonts test-miniguide test-images test-qr init-dirs doc

TEX = lualatex
FLAGS = --interaction=batchmode --halt-on-error

export TEXINPUTS := .:$(CURDIR)/src//:$(CURDIR)/doc//:
export LUAINPUTS := .:$(CURDIR)/src//:
export LUA_PATH := $(CURDIR)/src/?.lua;;

BUILD_DIR := build
EXPORT_DIR := $(BUILD_DIR)/export
QR_DIR := $(BUILD_DIR)/qrcodes

export CG_EXPORT_DIR := $(EXPORT_DIR)
export CG_QR_DIR := $(QR_DIR)

PYTHON_BIN := $(shell if [ -f ./env/bin/python ]; then echo "./env/bin/python"; elif [ -f ./scripts/python/.venv/bin/python ]; then echo "./scripts/python/.venv/bin/python"; else echo "python3"; fi)

all: test doc

init-dirs:
	@mkdir -p $(BUILD_DIR) $(EXPORT_DIR) $(QR_DIR)

check-fonts:
	@echo "Auditing system fonts..."
	@./scripts/check_fonts.sh $(BUILD_DIR)/system_fonts.log

test-lua:
	@echo "Executing Lua mathematical logic..."
	@lua tests/test_lua.lua
	@lua tests/test_sanitizer.lua

test-fonts: init-dirs check-fonts
	@echo "Compiling test_fonts.tex..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_fonts.tex

test-miniguide: init-dirs check-fonts
	@echo "Compiling test_miniguide.tex..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_miniguide.tex
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_miniguide.tex

test-images: init-dirs check-fonts
	@echo "Compiling test_images.tex..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_images.tex
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_images.tex

test-qr: init-dirs check-fonts test-lua
	@echo "Compiling test_qr.tex (Pass 1 - Manifest Generation)..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_qr.tex
	@echo "Generating QR Codes (Test)..."
	@$(PYTHON_BIN) scripts/python/generate_qrcodes.py --manifest $(EXPORT_DIR)/qrcodes_manifest.json --outdir $(QR_DIR)
	@echo "Compiling test_qr.tex (Pass 2 - PNG Injection)..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_qr.tex
	@echo "Compiling test_qr.tex (Pass 3 - TikZ Positioning)..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_qr.tex

test-suite: init-dirs check-fonts
	@echo "Compiling test_suite.tex..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_suite.tex
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) tests/test_suite.tex

test: test-lua test-fonts test-miniguide test-images test-qr test-suite

clean:
	@echo "Cleaning auxiliary build artifacts..."
	@rm -rf $(BUILD_DIR)/* *.cgstats

doc: init-dirs check-fonts
	@echo "Compiling doc/cg-documentation.tex..."
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) doc/cg-documentation.tex
	@$(TEX) $(FLAGS) --output-directory=$(BUILD_DIR) doc/cg-documentation.tex
