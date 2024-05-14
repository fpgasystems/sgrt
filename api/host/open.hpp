//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>

namespace host {
    device::vitis open(const std::string& device_index, const std::string& xclbin_name, const std::string& config_id, const std::string& target);
}

//#endif // HOST_HPP