# -----------------------------------------------------------------------------
# File:        Makefile
# Description: Genreic GCC based Makefile for compiling C/C++ programs
# -----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Pull in the project makefile which expects the following to be set:
# EXECUTABLE  - final output file name
# BUILD_DIR   - directory you want to build in
# SRC_DIRS    - any source directories to compile wholesale
# CC_SOURCES  - any additional one-off C files
# CXX_SOURCES - any additional one-off C++ files
# INC_DIRS    - any additional directories to include
# LIB_DIRS    - list of library search paths
# LIBS        - list of libraries to include (e.g. usb, mylib, etc...)
# CFLAGS      - any flags to set for C compilation only
# CXXFLAGS    - any flags to set for C++ compilation only
# CPPFLAGS    - any flags to set for preprocessor (.c, .cpp, .S)
# LDFLAGS     - any linker flags to set
# ------------------------------------------------------------------------------
include project.mk

# ------------------------------------------------------------------------------
# Get all the files from the source directories
# ------------------------------------------------------------------------------
CC_SOURCES  += $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))		# Do Not Edit
CXX_SOURCES += $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.cpp))	# Do Not Edit

# ------------------------------------------------------------------------------
# Add the libraries to the linker flags
# ------------------------------------------------------------------------------
LDFLAGS += $(addprefix -L,$(LIB_DIRS))
LDFLAGS += $(addprefix -l,$(LIBS))

# ------------------------------------------------------------------------------
# Inclusion Lists
# ------------------------------------------------------------------------------
INC_DIRS := $(basename $(INC_DIRS))
INC_DIRS := $(addprefix -I,$(INC_DIRS))
INC_DIRS += $(addprefix -I,$(SRC_DIRS))
CPPFLAGS += $(INC_DIRS)

# ------------------------------------------------------------------------------
# Clean up, get absolute paths, prefix sources
# ------------------------------------------------------------------------------
CC_SOURCES  := $(strip $(abspath $(CC_SOURCES)))
CXX_SOURCES := $(strip $(abspath $(CXX_SOURCES)))

# ------------------------------------------------------------------------------
# Gather info about OS
# ------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
	TARGET = win
    CPPFLAGS += -D WINDOWS
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
		TARGET = linux
        CPPFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
		TARGET = macos
        CPPFLAGS += -D OSX
    endif
endif

# ------------------------------------------------------------------------------
# Object Lists
# ------------------------------------------------------------------------------
OBJS_DIR := $(BUILD_DIR)/$(TARGET)/obj
CC_OBJS  := $(addprefix $(OBJS_DIR), $(CC_SOURCES:.c=.o))
CXX_OBJS := $(addprefix $(OBJS_DIR), $(CXX_SOURCES:.cpp=.o))

# ------------------------------------------------------------------------------
# Build Tasks
# ------------------------------------------------------------------------------
all: $(BUILD_DIR)/$(TARGET)/$(EXECUTABLE)

$(BUILD_DIR)/$(TARGET)/$(EXECUTABLE): $(CC_OBJS) $(CXX_OBJS)
	@echo Linking "  ($(CXX))": $@
	@$(CXX) $(LDFLAGS) -static $^ -o $@

$(CC_OBJS): $(OBJS_DIR)/%.o : $(CC_SOURCES)
	@echo Compiling "($(CC))": $< --\> $@
	@mkdir -p $(@D)
	@$(CC) -MMD -MP $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(CXX_OBJS): $(OBJS_DIR)/%.o : $(CXX_SOURCES)
	@echo Compiling "($(CXX))": $< --\> $@
	@mkdir -p $(@D)
	@$(CXX) -MMD -MP $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

-include $(CC_OBJS:.o=.d)
-include $(CXX_OBJS:.o=.d)

clean:
	@echo Deleting contents of $(BUILD_DIR)/$(TARGET)
	@RM -rf $(BUILD_DIR)/$(TARGET)/*
