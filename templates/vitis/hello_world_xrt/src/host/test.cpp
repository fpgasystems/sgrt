
#include <string>
#include <vector>
#include "api.hpp"
#include "../host.hpp"

void host::test(const std::vector<int>& out_spec, device::vitis device, std::string config_id) {
    // get project_path
    std::string project_path = host::get_project_path();
    
    // get parameters
    int N = host::get_config_parameter<int>(project_path, config_id, "N");

    // Declare output vector
    std::vector<int> out_des(N);
    
    // get device info
    std::string device_index = device.get_device_index();
    std::string xclbin_name = device.get_xclbin_name();

    // Get the output;
    device.outputs[0].bo.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    // Map the output buffer
    int* out_map = device.outputs[0].bo.map<int*>();

    // Construct a vector from the mapped data
    out_des.assign(out_map, out_map + N);

    std::cout << "\e[1m" << "Testing device " << device_index << " (" << xclbin_name << "):" << "\e[0m\n" << std::endl;

    if (out_spec.size() != out_des.size()) {
        std::cout << "TEST FAILED (vector sizes are different)\n" << std::endl;;
    } else {
        // Compare the contents of the vectors element-wise
        bool passed = true; // Use a bool instead of int
        for (size_t i = 0; i < out_spec.size(); ++i) {
            if (out_des[i] != out_spec[i]) {
                // If a mismatch is found, set passed to false and break out of the loop
                passed = false;
                break;
            }
        }

        // print based on the value of passed
        if (!passed)
            std::cout << "TEST FAILED (vector contents are different)\n" << std::endl;
        else
            std::cout << "TEST PASSED\n" << std::endl;
    }
}