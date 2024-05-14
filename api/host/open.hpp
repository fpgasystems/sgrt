//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
//#include "../api.hpp" // Include the device.hpp header

namespace host {
    device::vitis open(const std::string& device_index, const std::string& xclbin_name, const std::string& config_id, const std::string& target);
}

//#endif // HOST_HPP