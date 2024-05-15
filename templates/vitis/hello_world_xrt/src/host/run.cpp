
#include <string>
#include <vector>
#include "api.hpp"
#include "../host.hpp"

std::vector<int> host::run(const std::string& mode, device::vitis device, const std::string& config_id) {
    // Check if mode is "spec" or "des"
        if (mode != "spec" && mode != "des") {
            // Handle error for invalid mode
            throw std::runtime_error("Invalid mode. Mode must be 'spec' or 'des'");
        }

        // get project_path
        std::string project_path = host::get_project_path();
        
        // get parameters
        int N = host::get_config_parameter<int>(project_path, config_id, "N");

        // Declare output vector
        std::vector<int> out(N);

        // get device info
        std::string device_index = device.get_device_index();
        std::string xclbin_name = device.get_xclbin_name();

        // Perform specific operation based on mode
        if (mode == "spec") {

            std::cout << "\e[1m" << "Running device " << device_index << " (" << xclbin_name << ") specification:" << "\e[0m\n" << std::endl;

            // Read inputs from the device
            auto v_1 = device.inputs[0].bo.map<int*>();
            auto v_2 = device.inputs[1].bo.map<int*>();    

            // Switch statement based on xclbin_name
            if (xclbin_name == "vadd") {
                // vadd specification
                for (int i = 0; i < N; ++i) {
                    out[i] = v_1[i] + v_2[i];
                }
            } else if (xclbin_name == "vsub") {
                // vsub specification
                for (int i = 0; i < N; ++i) {
                    out[i] = v_1[i] - v_2[i];
                }
            }

            std::cout << "Done!\n" << std::endl;
        } else if (mode == "des") {

            std::cout << "\e[1m" << "Running device " << device_index << " (" << xclbin_name << ") design:" << "\e[0m\n" << std::endl;

            auto run = device.kernel(device.inputs[0].bo, device.inputs[1].bo, device.outputs[0].bo, N);
            run.wait();

            // Get the output;
            device.outputs[0].bo.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

            // Map the output buffer
            int* out_map = device.outputs[0].bo.map<int*>();

            // Construct a vector from the mapped data
            out.assign(out_map, out_map + N);

            std::cout << "Done!\n" << std::endl;
        }

        return out;
}