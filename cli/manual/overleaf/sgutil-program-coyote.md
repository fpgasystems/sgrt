Back to sgutil program


## sgutil program coyote

sgutil program coyote [flags] [--help]

  &nbsp; &nbsp; Programs Coyote to a given FPGA.


### Flags
-d, --device 

  &nbsp; &nbsp; FPGA Device Index (see sgutil examine).


-p, --project 

  &nbsp; &nbsp; Specifies your Vitis project name.


-r, --remote 

  &nbsp; &nbsp; Local or remote deployment.


-h, --help 

  &nbsp; &nbsp; Help to use this command.


### Examples
* **$ sgutil program coyote**
* **$ sgutil program coyote -d 1 -p hello_world --remote 0**
* **$ sgutil program coyote --regions 3**
