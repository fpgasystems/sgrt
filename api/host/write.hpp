//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
#include <vector>
#include "../device.hpp" // Include the device.hpp header

namespace host {
    std::vector<int> write(device::vitis device, const std::vector<std::vector<int>>& host_inputs);
}

//#endif // HOST_HPP