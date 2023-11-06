<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/api/manual.md#api">Back to API</a>
</p>

## host::open_vitis

Creates a `device::vitis` instance to operate with.

### Constructor

<code>device::vitis open(const std::string& device_index, const std::string& project_path, const std::string& emulationMode)</code>

* `device_index`: ACAP/FPGA device index.
* `project_path`: Project path.

### Methods

* `getDeviceIndex`: gets the device index of the Vitis object. 

### Example

```cpp
#include "device.hpp"

int main() {
    device::vitis alveo_1(1, "bdf_value", "device_name_value", "serial_value", "bin_file_value", "uuid_value", "ip0_value", "ip1_value", "mac0_value", "mac1_value", "platform_value");

    int index = myDevice.getDeviceIndex();
    myDevice.print();

    return 0;
}