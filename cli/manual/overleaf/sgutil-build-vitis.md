Back to sgutil build


## sgutil build vitis

sgutil build vitis [flags] [--help]

  &nbsp; &nbsp; Generates .xo kernels and .xclbin binaries for Vitis workflow.


### Flags
    --platform 

  &nbsp; &nbsp; Xilinx platform (according to sgutil get platform).


    --project

  &nbsp; &nbsp; Specifies your Vitis project name.


-t, --target

  &nbsp; &nbsp; Binary compilation target (sw_emu, hw_emu, hw).


-h, --help 

  &nbsp; &nbsp; Help to build a binary.


### Examples
* **$ sgutil build vitis**
* **$ sgutil build vitis --platform xilinx_u55c_gen3x16_xdma_3_202210_1 -p hello_world -t sw_emu**
