#include "open.hpp" // Include the header file
#include "../device.hpp"
#include "../common/sgutil_get.hpp"

device::vitis host::open(const std::string& device_bdf) {

    // sgutil_get constants 
    int BDF = 1;
    int DEVICE_NAME = 5;
    int SERIAL_NUMBER = 6;
    
    // XRT and SGRT objects
    xrt::device xrt_device;
    device::vitis device;

    // sgutil_get
    device.device_index = 2;
    device.bdf = sgutil_get(device.device_index, BDF);
    device.device_name = sgutil_get(device.device_index, DEVICE_NAME);
    device.serial_number = sgutil_get(device.device_index, SERIAL_NUMBER);
    device.IP0 = "";
    device.IP1 = "";
    device.MAC0 = "";
    device.MAC1 = "";
    device.platform = "";
    
    // XRT instance
    if (device_bdf.empty()) {
        xrt_device = xrt::device(0);
    } else {
        std::cout << "\nOpening the device: " << device_bdf << "\n" << std::endl;
        xrt_device = xrt::device(device_bdf);
    }

    device.xrtDevice = xrt_device;
    
    return device;

}