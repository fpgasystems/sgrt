#ifndef HOST_HPP
#define HOST_HPP

#include <string>
#include "../device.hpp" // Include the device.hpp header

namespace host {
    device::vitis open(const std::string& device_index, const std::string& binary_file);
}

#endif // HOST_HPP