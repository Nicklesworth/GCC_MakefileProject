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
# Gather up all the source files into SOURCES
# ------------------------------------------------------------------------------
SOURCES += $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))
SOURCES += $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.cpp))
SOURCES += $(ADDL_SOURCES)
SOURCES := $(abspath $(SOURCES))

# ------------------------------------------------------------------------------
# Create a list of INCLUDES
# ------------------------------------------------------------------------------
INC_DIRS := $(abspath $(INC_DIRS))
INC_DIRS += $(dir $(abspath $(SOURCES)))
INC_DIRS := $(strip $(sort $(INC_DIRS)))
CPPFLAGS += $(addprefix -I,$(INC_DIRS))

# ------------------------------------------------------------------------------
# Add the libraries to the linker flags
# ------------------------------------------------------------------------------
LDFLAGS += $(addprefix -L,$(LIB_DIRS))
LDLIBS  := $(addprefix -l,$(LIBS))

# ------------------------------------------------------------------------------
# Object Lists
# ------------------------------------------------------------------------------
OBJECTS  := $(SOURCES:.c=.o)
OBJECTS  := $(OBJECTS:.cpp=.o)
OBJS_DIR := $(BUILD_DIR)/$(TARGET)/obj
OBJECTS  := $(addprefix $(OBJS_DIR),$(OBJECTS))

# ------------------------------------------------------------------------------
# Build Tasks
# ------------------------------------------------------------------------------
all: $(BUILD_DIR)/$(TARGET)/$(EXECUTABLE)

$(BUILD_DIR)/$(TARGET)/$(EXECUTABLE): $(OBJECTS)
	@echo Linking "  ($(CXX))": $(abspath $@)
	@$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJS_DIR)/%.o : $(dir $*)/%.cpp
	@echo Compiling "($(CXX))": $< --\> $@
	@mkdir -p $(@D)
	@$(CXX) -MMD -MP $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJS_DIR)/%.o : $(dir $*)/%.c
	@echo Compiling "($(CC))": $< --\> $@
	@mkdir -p $(@D)
	@$(CC) -MMD -MP $(CFLAGS) $(CPPFLAGS) -c $< -o $@

# Auto-generated dependency files incsluded as rules
-include $(OBJECTS:.o=.d)

clean:
	@echo Deleting contents of $(BUILD_DIR)/$(TARGET)
	@RM -rf $(BUILD_DIR)/$(TARGET)/*
