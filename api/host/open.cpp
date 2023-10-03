#include "open.hpp" // Include the header file
#include "../device.hpp"

xrt::device host::open(const std::string& device_bdf) {
    
    xrt::device xrt_device;
    device::vitis device;

    if (device_bdf.empty()) {
        xrt_device = xrt::device(0);
    } else {
        std::cout << "\nOpening the device: " << device_bdf << "\n" << std::endl;
        xrt_device = xrt::device(device_bdf);
    }

    device.device_index = 1;
    device.serial_number = "12345";
    device.vitis = xrt_device;
    
    return xrt_device;

}