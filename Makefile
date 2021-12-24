
CC				= g++
COMMON_CFLAGS	= -fno-exceptions
CFLAGS			= $(COMMON_CFLAGS) -O0 -g -Wall -Wno-unused
PROD_CFLAGS		= $(COMMON_CFLAGS) -O3
DEBUG_DEFINES	= -DDEBUG=1
PROD_DEFINES	= -DDEBUG=0

OUT_DIR	= build
LIB_DIR	= $(OUT_DIR)/lib
OBJ_DIR	= $(LIB_DIR)/obj

SRC 			= main.cpp $(shell find ./src/ -name "*.cpp")
BIN_NAME		= main
INCLUDE_PATH	= -I$(PWD)/libs/add -I$(PWD)/libs/sub

LIB1_SRC	= $(shell find ./libs/add/ -name "*.cpp")
LIB1_NAME	= add.o
LIB2_SRC	= $(shell find ./libs/sub/ -name "*.cpp")
LIB2_NAME	= sub.o
LIB_ARCH	= badmath
LIB_PATH	= -L$(LIB_DIR)

.PHONY: help
help:
	@echo Supported targets:
	@cat $(MAKEFILE_LIST) | grep -e "^[\.a-zA-Z0-9_-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-35s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# NOTE: The gcc -c option means compile and assemble, but do NOT link.
# NOTE: The gcc -o option sets the output file.
# NOTE: The ar command squashes groups of object files to a single archive file.
#			The -c option creates an archive and inserts the objects in it.
#			The -r option replaces old files where needed.
# NOTE: The ranlib command is used whenever files are added to a library and the library needs to be indexed.
# 			A large library may have thousands of symbols, meaning an index can significantly speed up finding references.
.PHONY: static_lib
static_lib: clean ## Clean output directory and create a static lib file.
	mkdir -p $(OBJ_DIR) && \
	$(CC) $(CFLAGS) -c $(LIB1_SRC) -o $(OBJ_DIR)/$(LIB1_NAME) && \
	$(CC) $(CFLAGS) -c $(LIB2_SRC) -o $(OBJ_DIR)/$(LIB2_NAME) && \
	ar -rc $(LIB_DIR)/lib$(LIB_ARCH).a $(OBJ_DIR)/*.o

# NOTE: The gcc -L option adds the path to the library search path. Can alternatively use the env variable LD_LIBRARY_PATH.
# NOTE: The gcc -l options provides a name of a library to search for in the LD_LIBRARY_PATH.
#			Provided names should ommit the lib prefix and the file extenson (.a in this case).
# NOTE: The gcc -I option specifies the header search path. Can alternatively use the env variables CPATH (c or c++),
#			or C_INCLUDE_PATH, or CPLUS_INCLUDE_PATH.
.PHONY: build
build: clean static_lib ## Builds the final executable as a DYNAMIC executable.
	$(CC) $(INCLUDE_PATH) $(LIB_PATH) $(CFLAGS) $(SRC) \
	-o $(OUT_DIR)/$(BIN_NAME) \
	-l $(LIB_ARCH)

# NOTE: This traget creates a truly static executable by puting the stdlib inside the final executable.
# NOTE: Static linking the c std library is probably a bad idea. Especially on distros that have different std libs.
.PHONY: build_static
build_static: clean static_lib ## Builds the final executable as a STATIC executable.
	$(CC) -static $(INCLUDE_PATH) $(LIB_PATH) $(CFLAGS) $(SRC) \
	-o $(OUT_DIR)/$(BIN_NAME) \
	-l $(LIB_ARCH)

.PHONY: ldd_build
ldd_build: ## Lists the dependencies that the final executable links to dynamically. (should be only the standard c lib)
	ldd $(OUT_DIR)/$(BIN_NAME)

.PHONY: list_symbols
list_symbols: ## Prints each symbol value, symbol type and symbol name in the final executable.
	nm $(OUT_DIR)/$(BIN_NAME)

.PHONY: generate_asm
generate_asm: ## Uses objdump -S to generate asm from the binary. Expects the output binaries to be generated first by other make targets.
	objdump -M intel -S $(OUT_DIR)/$(BIN_NAME) > $(OUT_DIR)/$(BIN_NAME).S

.PHONY: clean
clean: ## Deletes the build folder.
	rm -rf $(OUT_DIR)