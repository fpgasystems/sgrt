# Programming model

SGRT allows you to effectively manage and program ACAPs, FPGAs, multi-core CPUs, and GPUs, all through a unified device index. To get to know which devices are available on your server, please use **sgutil examine**:

![sgutil examine for alveo-u55c-01 (left) and hacc-box-01 (right).](./programming-model-sgutil-examine.png "sgutil examine for alveo-u55c-01 (left) and hacc-box-01 (right).")

Assuming an heterogeneous server with multiple reconfigurable devices like *hacc-box-01* on ETHZ-HACC: 

![HACC boxes architecture.](./programming-model-hacc-boxes.png "HACC boxes architecture.")

**the following programming model applies:**

![Programming model.](./programming-model.png "Programming model.")
