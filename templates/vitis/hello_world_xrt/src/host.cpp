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
#include "host.hpp" // /opt/sgrt/api/host.hpp
#include "device.hpp" // /opt/sgrt/api/device.hpp

// project includes
#include "../sgrt_parameters.hpp"
//#include "../configs/config_000.hpp" // config_000.hpp is overwritten with the configuration you select

//std::string get_current_path() {
//    char currentPath[FILENAME_MAX];
//    if (getcwd(currentPath, sizeof(currentPath)) != NULL) {
//        return std::string(currentPath);
//    } else {
//        return std::string(); // Return an empty string to indicate an error
//    }
//}

namespace host {
    std::vector<int> run(const std::string& mode, device::vitis device) {    
        // Check if mode is "spec" or "des"
        if (mode != "spec" && mode != "des") {
            // Handle error for invalid mode
            throw std::runtime_error("Invalid mode. Mode must be 'spec' or 'des'");
        }
        
        // Derive N as the length of the first input vector
        //int N = device.inputs[0].size();

        // Ensure all input vectors have the same size
        //for (int i = 1; i < device.inputs.size(); ++i) {
        //    if (device.inputs[i].size() != N) {
        //        throw std::runtime_error("Input vectors must have the same size");
        //    }
        //}

        // Perform specific operation based on mode
        if (mode == "spec") {
            // Read inputs from the device
            auto v_1 = device.inputs[0].bo.map<int*>();
            auto v_2 = device.inputs[1].bo.map<int*>();    

            // Derive N as the length of the first input vector
            int N = 32; //v_1.size();

            // Declare output vector
            std::vector<int> out(N);    

            // Perform specific operation for "spec" mode
            for (int i = 0; i < N; ++i) {
                out[i] = v_1[i] + v_2[i];
            }

            return out;

        } else if (mode == "des") {
            // Read inputs from the device
            auto v_1 = device.inputs[0].bo.map<int*>();
            auto v_2 = device.inputs[1].bo.map<int*>();

            // Derive N as the length of the first input vector
            int N = 32; //v_1.size();

            // Declare output vector
            std::vector<int> out(N);    

            // Perform specific operation for "des" mode
            for (int i = 0; i < N; ++i) {
                out[i] = v_1[i] - v_2[i];
            }

            return out;
        }

        //return out;
    }
}

int main(int argc, char** argv) {

    if (argc > 2) {
        //std::cout << "\n" << argv[0] << " does not accept any additional parameters.\n" << std::endl;
        std::cout << "\n" << argv[0] << ": too many input parameters.\n" << std::endl;
        return 1;
    }

    // get project_path
    std::string project_path = host::get_project_path();

    // get config_id
    std::string config_id = host::get_config(argv);

    // get config_parameters
    int N = host::get_config_parameter<int>(project_path, config_id, "N");

    // get target
    std::string target = host::get_target();

    // create data
    std::vector<int> v_1 = host::create_data(config_id);
    std::vector<int> v_2 = host::create_data(config_id);

    // specification
    //std::vector<int> out_spec = host::run("spec", v_1, v_2);

    // design

    // Initialize inputs vector with v_1 and v_2
    std::vector<std::vector<int>> inputs;
    inputs.push_back(v_1);
    inputs.push_back(v_2);

    // device 1
    device::vitis alveo_1 = host::open("1", "vadd", config_id, target);
    alveo_1.print();

    host::write(alveo_1, inputs);

    // specification
    std::vector<int> out_spec = host::run("spec", alveo_1);

    std::cout << "Execution of the kernel\n";
    auto run = alveo_1.kernel(alveo_1.inputs[0].bo, alveo_1.inputs[1].bo, alveo_1.outputs[0].bo, N); // DATA_SIZE
    run.wait();

    // Get the output;
    std::cout << "Get the output data from the device" << std::endl;
    alveo_1.outputs[0].bo.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    // test 1
    if (std::memcmp(alveo_1.outputs[0].bo.map<int*>(), out_spec.data(), N * sizeof(int)) != 0) { // DATA_SIZE
        throw std::runtime_error("Value read back does not match reference");
    }

    std::cout << "TEST PASSED 1\n";
    //return 0;

    // device 2 ------------------------------------------------------------------------------------------------
    std::cout << "\nDEVICE 2\n" << std::endl;
    
    device::vitis alveo_2 = host::open("2", "vsub", config_id, target);
    alveo_2.print();

    host::write(alveo_2, inputs);

    std::cout << "Execution of the kernel\n";
    auto run_2 = alveo_2.kernel(alveo_2.inputs[0].bo, alveo_2.inputs[1].bo, alveo_2.outputs[0].bo, N); // DATA_SIZE
    run_2.wait();

    // Get the output;
    std::cout << "Get the output data from the device" << std::endl;
    alveo_2.outputs[0].bo.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    // test 2
    if (std::memcmp(alveo_2.outputs[0].bo.map<int*>(), out_spec.data(), N * sizeof(int)) != 0) { // DATA_SIZE
        throw std::runtime_error("Value read back does not match reference");
    }    

    std::cout << "TEST PASSED 2\n";
    return 0;

}
