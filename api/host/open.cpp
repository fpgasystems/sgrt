#include "open.hpp" // Include the header file
#include "../device.hpp"
#include "../common/sgutil_get.hpp"

device::vitis host::open(const std::string& device_bdf) {

    // sgutil_get constants 
    int SERIAL_NUMBER = 6;
    
    // XRT and SGRT objects
    xrt::device xrt_device;
    device::vitis device;

    // sgutil_get
    device.device_index = 2;
    device.bdf = "";
    device.device_name = "";
    device.serial_number = sgutil_get(device.device_index, SERIAL_NUMBER);
    device.IP0 = "";
    device.IP1 = "";
    device.MAC0 = "";
    device.MAC1 = "";
    device.platform = "";
    
    if (device_bdf.empty()) {
        xrt_device = xrt::device(0);
    } else {
        std::cout << "\nOpening the device: " << device_bdf << "\n" << std::endl;
        xrt_device = xrt::device(device_bdf);
    }

    
    //device.serial_number = "12345";
    device.xrtDevice = xrt_device;

    //int device_index = 2; // Example device index
    //std::string serial_number = sgutil_get(device_index, SERIAL_NUMBER);

    //device.serial_number = serial_number;
    
    return device;

}