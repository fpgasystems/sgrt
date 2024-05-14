//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
#include <vector>

namespace host {
    void write(device::vitis device, const std::vector<std::vector<int>>& host_inputs);
}

//#endif // HOST_HPP