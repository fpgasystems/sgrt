//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
#include <vector>

namespace host {
    void test(const std::vector<int>& out_spec, device::vitis device, std::string config_id);
}

//#endif // HOST_HPP