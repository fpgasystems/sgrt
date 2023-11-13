Back to sgutil program


## sgutil program vivado

sgutil program vivado [flags] [--help]

  &nbsp; &nbsp; Programs a Vivado bitstream to a given FPGA.


### Flags
-b, --bitstream 

  &nbsp; &nbsp; Bitstream (.bit) file path.


    --device 

  &nbsp; &nbsp; FPGA Device Index (see sgutil examine).


    --driver 

  &nbsp; &nbsp; Driver (.ko) file path.


-l, --ltx 

  &nbsp; &nbsp; Specifies a .ltx debug probes file.


-n, --name 

  &nbsp; &nbsp; FPGA's device name. See sgutil get device.


-s, --serial 

  &nbsp; &nbsp; FPGA's serial number. See sgutil get serial.
 -->

-h, --help 

  &nbsp; &nbsp; Help to program a bitstream.


### Examples
* **$ sgutil program vivado --bitstream my_bitstream.bit --driver my_driver.ko --device 1**
* **$ sgutil program vivado --bitstream my_bitstream.bit --device 1**
* **$ sgutil program vivado --driver my_driver.ko**
