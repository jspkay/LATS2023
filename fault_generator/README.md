# Fangy
Fangy is a fault list generator. It generates a list of commands compatible with modelsim/questasim starting from a text file with a specific file format. The format is explained below.

## Input format
The input format is a simple text file. A fault is specified using the full hierarchy of the signal/object in which to inject the fault, at least one space (or tab character `'\t'`) and a literal (VHDL or Verilog syntax).

Each line contains a new signal/object with its faults.
Sometimes multiple faults might share a part of hierarchy. To address this point it is possible to write the shared hierarachy and the use culry brackets `{}` to specify the different signals/objects subjeccted to the fault. 

> **Example**
> 
> Suppose I want to inject a high fault to the signals `/my_test_bench/sig1` and `/my_test_bench/sig2`.
> Then, one can write the following specification:
> ```
> /my_test_bench/{
>   sig1 1;
>   sig2 1;
> }
> ```

Fangy supports nested hierarchies and both Verilog and VHDL syntax.

Run Fangy with the given example file to understand better. Should be pretty simple to understand.

## Compilation
Compiling Fangy is really simple, since its written only using the C standard libraries. You can simply use plain gcc. Otherwise, both CMake and make can be used out of the box simply running `cmake CMakeLists.txt` or `make`.  

