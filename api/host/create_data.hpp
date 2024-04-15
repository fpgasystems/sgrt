//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
#include <vector>
//#include "../host.hpp" // Include the device.hpp header

namespace host {
    std::vector<int> create_data(const std::string& config_id);
}

//#endif // HOST_HPP