#include "get_device.hpp" // Include the header file

xrt::device get_device(const std::string& device_bdf) {
    
    xrt::device device;

    if (device_bdf.empty()) {
        device = xrt::device(0);
    } else {
        std::cout << "\nOpening the device: " << device_bdf << "\n" << std::endl;
        device = xrt::device(device_bdf);
    }
    
    return device;

}