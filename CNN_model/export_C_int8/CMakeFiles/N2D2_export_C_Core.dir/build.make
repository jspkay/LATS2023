# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.23

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
CMAKE_COMMAND = /home/salvo/.local/jetbrains/clion-2020.3.3/bin/cmake/linux/bin/cmake

# The command to remove a file.
RM = /home/salvo/.local/jetbrains/clion-2020.3.3/bin/cmake/linux/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/salvo/Documenti/Tesi/CNN_model/export_C_int8

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/salvo/Documenti/Tesi/CNN_model/export_C_int8

# Include any dependencies generated for this target.
include CMakeFiles/N2D2_export_C_Core.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/N2D2_export_C_Core.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/N2D2_export_C_Core.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/N2D2_export_C_Core.dir/flags.make

CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o: CMakeFiles/N2D2_export_C_Core.dir/flags.make
CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o: src/getline.c
CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o: CMakeFiles/N2D2_export_C_Core.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/salvo/Documenti/Tesi/CNN_model/export_C_int8/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o -MF CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o.d -o CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o -c /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/getline.c

CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.i"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/getline.c > CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.i

CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.s"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/getline.c -o CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.s

CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o: CMakeFiles/N2D2_export_C_Core.dir/flags.make
CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o: src/n2d2.c
CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o: CMakeFiles/N2D2_export_C_Core.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/salvo/Documenti/Tesi/CNN_model/export_C_int8/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building C object CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o -MF CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o.d -o CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o -c /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/n2d2.c

CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.i"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/n2d2.c > CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.i

CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.s"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/n2d2.c -o CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.s

CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o: CMakeFiles/N2D2_export_C_Core.dir/flags.make
CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o: src/network.c
CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o: CMakeFiles/N2D2_export_C_Core.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/salvo/Documenti/Tesi/CNN_model/export_C_int8/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building C object CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o -MF CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o.d -o CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o -c /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/network.c

CMakeFiles/N2D2_export_C_Core.dir/src/network.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/N2D2_export_C_Core.dir/src/network.c.i"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/network.c > CMakeFiles/N2D2_export_C_Core.dir/src/network.c.i

CMakeFiles/N2D2_export_C_Core.dir/src/network.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/N2D2_export_C_Core.dir/src/network.c.s"
	/usr/bin/clang $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/src/network.c -o CMakeFiles/N2D2_export_C_Core.dir/src/network.c.s

# Object files for target N2D2_export_C_Core
N2D2_export_C_Core_OBJECTS = \
"CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o" \
"CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o" \
"CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o"

# External object files for target N2D2_export_C_Core
N2D2_export_C_Core_EXTERNAL_OBJECTS =

libN2D2_export_C_Core.a: CMakeFiles/N2D2_export_C_Core.dir/src/getline.c.o
libN2D2_export_C_Core.a: CMakeFiles/N2D2_export_C_Core.dir/src/n2d2.c.o
libN2D2_export_C_Core.a: CMakeFiles/N2D2_export_C_Core.dir/src/network.c.o
libN2D2_export_C_Core.a: CMakeFiles/N2D2_export_C_Core.dir/build.make
libN2D2_export_C_Core.a: CMakeFiles/N2D2_export_C_Core.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/salvo/Documenti/Tesi/CNN_model/export_C_int8/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Linking C static library libN2D2_export_C_Core.a"
	$(CMAKE_COMMAND) -P CMakeFiles/N2D2_export_C_Core.dir/cmake_clean_target.cmake
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/N2D2_export_C_Core.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/N2D2_export_C_Core.dir/build: libN2D2_export_C_Core.a
.PHONY : CMakeFiles/N2D2_export_C_Core.dir/build

CMakeFiles/N2D2_export_C_Core.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/N2D2_export_C_Core.dir/cmake_clean.cmake
.PHONY : CMakeFiles/N2D2_export_C_Core.dir/clean

CMakeFiles/N2D2_export_C_Core.dir/depend:
	cd /home/salvo/Documenti/Tesi/CNN_model/export_C_int8 && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/salvo/Documenti/Tesi/CNN_model/export_C_int8 /home/salvo/Documenti/Tesi/CNN_model/export_C_int8 /home/salvo/Documenti/Tesi/CNN_model/export_C_int8 /home/salvo/Documenti/Tesi/CNN_model/export_C_int8 /home/salvo/Documenti/Tesi/CNN_model/export_C_int8/CMakeFiles/N2D2_export_C_Core.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/N2D2_export_C_Core.dir/depend

