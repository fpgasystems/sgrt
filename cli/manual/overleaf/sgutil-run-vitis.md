Back to sgutil run


## sgutil run vitis

sgutil run vitis [flags] [--help]

  &nbsp; &nbsp; Runs a Vitis FPGA-binary on a given FPGA/ACAP.


### Flags
-d, --device 

  &nbsp; &nbsp; FPGA Device Index (see sgutil examine).


    --platform

  &nbsp; &nbsp; Xilinx platform (according to sgutil get platform).


    --project

  &nbsp; &nbsp; Specifies your Vitis project name.


-t, --target

  &nbsp; &nbsp; Binary compilation target (sw_emu, hw_emu, hw).


-h, --help

  &nbsp; &nbsp; Help to use this command.


### Examples
* **$ sgutil run vitis -p hello_world -d 1 -t sw_emu**
