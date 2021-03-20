# Template_MakeProject
Template Makefile project for C/C++ on GCC hosts
Features
- Two file structure, Makefile is generic, projcet.mk are project specifics
- Automated dependency creation
- All paths flattened in build directory to avoid same file name clashes
- Flexible source inclusion, full directories via SRC_DIRS and single files via CC_SOURCES/CXX_SOURCES
- Basic OS detection to build in different subdirectories (win/macos/linux)
