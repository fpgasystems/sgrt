//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
//#include "../host.hpp" // Include the device.hpp header

namespace host {
    std::vector<int> write(device::vitis device, const std::string& config_id);
}

//#endif // HOST_HPP