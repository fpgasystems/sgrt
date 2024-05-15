//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
#include <vector>
#include "api.hpp"

namespace host {
    std::vector<int> run(const std::string& mode, device::vitis device, const std::string& config_id);
}

//#endif // HOST_HPP