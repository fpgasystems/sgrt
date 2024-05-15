/**
* Copyright (C) 2019-2021 Xilinx, Inc
*
* Licensed under the Apache License, Version 2.0 (the "License"). You may
* not use this file except in compliance with the License. A copy of the
* License is located at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations
* under the License.
*/

// host includes
//#include "cmdlineparser.h"
#include <iostream>
#include <unistd.h>
#include <cstring>

// XRT includes
#include "experimental/xrt_bo.h"
#include "experimental/xrt_device.h"
#include "experimental/xrt_kernel.h"

// SGRT includes
#include "api.hpp"

// project includes
#include "../sgrt_parameters.hpp"
#include "./host.hpp"

//namespace host {
    /* std::vector<int> run(const std::string& mode, device::vitis device, const std::string& config_id) {    
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
    } */

    /* void test(const std::vector<int>& out_spec, device::vitis device, std::string config_id) { //, const std::vector<int>& out_des
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
    } */
//}

int main(int argc, char** argv) {

    if (argc > 2) {
        std::cout << "\n" << argv[0] << ": too many input parameters.\n" << std::endl;
        return 1;
    }

    // get project_path
    std::string project_path = host::get_project_path();

    // get config_id
    std::string config_id = host::get_config(argv);

    // get target
    std::string target = host::get_target();

    // create data
    std::vector<int> v_1 = host::create_data(config_id);
    std::vector<int> v_2 = host::create_data(config_id);

    // Initialize inputs vector with v_1 and v_2
    std::vector<std::vector<int>> inputs;
    inputs.push_back(v_1);
    inputs.push_back(v_2);

    // open devices
    device::vitis alveo_1 = host::open("1", "vadd", config_id, target);
    alveo_1.print();

    device::vitis alveo_2 = host::open("2", "vsub", config_id, target);
    alveo_2.print();

    // copy data to global memory
    host::write(alveo_1, inputs);
    host::write(alveo_2, inputs);

    // specification
    std::vector<int> alveo_1_spec = host::run("spec", alveo_1, config_id);
    std::vector<int> alveo_2_spec = host::run("spec", alveo_2, config_id);

    // design
    host::run("des", alveo_1, config_id);
    host::run("des", alveo_2, config_id);

    // test
    host::test(alveo_1_spec, alveo_1, config_id);
    host::test(alveo_2_spec, alveo_2, config_id);

    return 0;
}
