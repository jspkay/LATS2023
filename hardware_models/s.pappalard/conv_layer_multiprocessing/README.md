# Introduction

This project aims at simulating a systolic array for AI processing. It is able to correctly process the MNIST digit dataset, also supporting different array size (exploiting the same array for process different areas of the input. See customization for see what parameters to change.

The new version of the project implements a multithreading program which minimize the total simulation time, processing more the one simulation at a time. Each simulation is implemented in two steps: `simulate` and `propagate`.

1. `simulate` calls vsim and perform the actual simulation, but in order to do that some files have to be put in the right place. At the end of the simulation, the results are put in a folder called `queue` which will be accessed by `propagate`.
2. `propagate` wait for the queue corresponding folder to exists (the filesystem can take a few seconds to setup the folder) and the performs the activation, compare the results with a golden run and finally propagate the output on the actual network, storing the results.

# Building

The program start_fault_campaign.c can be built with `make` (NOTE: YOU NEED `clang`*) and the ran with `./sfc`.
The program accepts arguments. execute `./sfc --help` for more. The option `resume` has no effect yet. It might be removed in the future.

---
 
*`clang` is needed because compiling with gcc results on a `SIGSEV` during execution. The program could be actually used anywas (the `SIGSEV` only happens while waiting for the threads to finish) but it is not as reliable as the `clang` version.

# Customization

These customizations can be used for processing elements with different-sized arrays or different input images (e.g. 8/16/32 bits)

You need to make some adjustment to the files for correctly setup the environment. Here's a list.

- start_fault_campaign.c - Here you can change the `DEFINE`s. Briefly explained:
	- STIMULI_PER_CLASS - defines how many stimuli to simulate per each class per each fault
	- STIMULI_CLASSES - defines how many classes of stimuli exist. With the MNIST digits dataset, it is obviously 10 (one per digit).
	- SIMULATION_PROCESSES - defines how many parallel instances of vsim to run (check out `prepareEnvironment.sh`)
	- PROPAGATION_PROCESSES - defines how many parallel instances of `propagation to run
	- SIMULATION_PROGRAM - defines which program to call for simulating.
	- PROPAGATION_PROGRAM - defines which program to call for propagating.
- `sfc.startSimulation` - this is the standard simulation script. Here you can modify:
	- arrSize - defining the physical size of the systolic array. It needs to be in accordance with other instances of the same meaning (like in `conv_layer_reduced_tb.vhd.template`)
	- nZ - describes the number of zeros to insert between to sequences (check out `generateInpuSequences.py` for more information)
	- names - Have to be in accordance with `prepareEnironment.sh` (only used for illustration purposes, not important)
- `sfc.propagate - in theory everything is correct here.
- `conv_layer_reduced_tb.vhd.template - This is the heart of the project. It implements the systolic array architecture which is used in modelsim for the simulations. The parameter to be changed here are multiple.
	- `rows`, `cols` - define the physical systolic array size. Have to be in accordance with `arrSize` in `sfc.startSimulation`
	- `completeRows`, `completeCols` - define the size of complete image 	**after** the convolution to be processed (e.g. for MNIST digits dataset is 28, 32 input length and 5 kernel length)
	- `kerC`, `kerH` - define the kernel width and height respectively. It has to be in accordance with `completeRows` and `completeCols` as said before.
	- `depth` describe the depth (bit-width) of each pixel value. 

If the environment is correctly setup, everything should just work. 

# Preparation

After the customization have been setup, it is necessary to execute `prepareEnvironment.sh`. It will create the work directories for the different modelsim simulation.

# Other stuff
The complete project is made up using different scripts and program. Check out the root for a preview.

