# -----------------------------------------------------------------------------
# File:        project.mk
# Description: Configuration makefile that sets up the generic Makefile
# -----------------------------------------------------------------------------
EXECUTABLE   := helloWorld
BUILD_DIR    := ./bin
SRC_DIRS     := ./src
INC_DIRS     := ./inc
LIB_DIRS     := 
LIBS         := 
ADDL_SOURCES :=
CFLAGS       :=
CXXFLAGS     :=
CPPFLAGS     := -g -Wall -O0
LDFLAGS      := -static

# ------------------------------------------------------------------------------
# Gather info about OS
# ------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
    TARGET = win
	CPPFLAGS += -DWINDOWS
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
		TARGET = linux
        CPPFLAGS += -DLINUX
    endif
    ifeq ($(UNAME_S),Darwin)
		TARGET = macos
        CPPFLAGS += -DMACOS		
		LDFLAGS := $(filter-out -static,$(LDFLAGS))
    endif
endif