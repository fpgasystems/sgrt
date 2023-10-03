#ifndef HOST_HPP
#define HOST_HPP

#include <string>
//#include <xrt/xrt_device.h> // Include the appropriate header for xrt::device
#include "../device.hpp" // Include the device.hpp header

namespace host {
    device::vitis open(const std::string& device_bdf);
}

#endif // HOST_HPP