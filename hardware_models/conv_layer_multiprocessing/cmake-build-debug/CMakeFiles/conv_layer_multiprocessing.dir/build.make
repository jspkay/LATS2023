# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.24

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/cmake-build-debug

# Include any dependencies generated for this target.
include CMakeFiles/conv_layer_multiprocessing.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/conv_layer_multiprocessing.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/conv_layer_multiprocessing.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/conv_layer_multiprocessing.dir/flags.make

CMakeFiles/conv_layer_multiprocessing.dir/main.c.o: CMakeFiles/conv_layer_multiprocessing.dir/flags.make
CMakeFiles/conv_layer_multiprocessing.dir/main.c.o: /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/main.c
CMakeFiles/conv_layer_multiprocessing.dir/main.c.o: CMakeFiles/conv_layer_multiprocessing.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/conv_layer_multiprocessing.dir/main.c.o"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT CMakeFiles/conv_layer_multiprocessing.dir/main.c.o -MF CMakeFiles/conv_layer_multiprocessing.dir/main.c.o.d -o CMakeFiles/conv_layer_multiprocessing.dir/main.c.o -c /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/main.c

CMakeFiles/conv_layer_multiprocessing.dir/main.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/conv_layer_multiprocessing.dir/main.c.i"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/main.c > CMakeFiles/conv_layer_multiprocessing.dir/main.c.i

CMakeFiles/conv_layer_multiprocessing.dir/main.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/conv_layer_multiprocessing.dir/main.c.s"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/main.c -o CMakeFiles/conv_layer_multiprocessing.dir/main.c.s

# Object files for target conv_layer_multiprocessing
conv_layer_multiprocessing_OBJECTS = \
"CMakeFiles/conv_layer_multiprocessing.dir/main.c.o"

# External object files for target conv_layer_multiprocessing
conv_layer_multiprocessing_EXTERNAL_OBJECTS =

conv_layer_multiprocessing: CMakeFiles/conv_layer_multiprocessing.dir/main.c.o
conv_layer_multiprocessing: CMakeFiles/conv_layer_multiprocessing.dir/build.make
conv_layer_multiprocessing: CMakeFiles/conv_layer_multiprocessing.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable conv_layer_multiprocessing"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/conv_layer_multiprocessing.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/conv_layer_multiprocessing.dir/build: conv_layer_multiprocessing
.PHONY : CMakeFiles/conv_layer_multiprocessing.dir/build

CMakeFiles/conv_layer_multiprocessing.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/conv_layer_multiprocessing.dir/cmake_clean.cmake
.PHONY : CMakeFiles/conv_layer_multiprocessing.dir/clean

CMakeFiles/conv_layer_multiprocessing.dir/depend:
	cd /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/cmake-build-debug && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/cmake-build-debug /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/cmake-build-debug /home/salvo/Documenti/Tesi/hardware_models/conv_layer_multiprocessing/cmake-build-debug/CMakeFiles/conv_layer_multiprocessing.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/conv_layer_multiprocessing.dir/depend

