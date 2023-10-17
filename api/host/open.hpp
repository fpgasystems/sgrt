#ifndef HOST_HPP
#define HOST_HPP

#include <string>
#include "../device.hpp" // Include the device.hpp header

namespace host {
    device::vitis open(const std::string& device_index, const std::string& project_path, const std::string& binary_file, const std::string& emulationMode);
}

#endif // HOST_HPP