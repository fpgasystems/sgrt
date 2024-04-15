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
    //std::cout << "\nconfig_id = " << config_id << std::endl;

    // get config_parameters
    int N = host::get_config_parameter<int>(project_path, config_id, "N");
    //std::cout << "Value of parameter 'N': " << N << std::endl;

    // get target
    std::string target = host::get_target();

    std::cout << "\nDEVICE 1\n" << std::endl;

    // device 1
    device::vitis alveo_1 = host::open("1", "vadd", config_id, target);
    alveo_1.print();

    std::vector<int> bufReference = host::write(alveo_1, config_id);

    // Synchronize buffer content with device side
    std::cout << "synchronize input buffer data to device global memory\n";

    //alveo_1.inputs[0].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    //alveo_1.inputs[1].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    std::cout << "Execution of the kernel\n";
    auto run = alveo_1.kernel(alveo_1.inputs[0].bo, alveo_1.inputs[1].bo, alveo_1.outputs[0].bo, N); // DATA_SIZE
    run.wait();

    // Get the output;
    std::cout << "Get the output data from the device" << std::endl;
    alveo_1.outputs[0].bo.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    // Validate our results
    if (std::memcmp(alveo_1.outputs[0].bo.map<int*>(), bufReference.data(), N * sizeof(int)) != 0) { // DATA_SIZE
        throw std::runtime_error("Value read back does not match reference");
    }

    std::cout << "TEST PASSED 1\n";
    //return 0;

    // device 2 ------------------------------------------------------------------------------------------------
    std::cout << "\nDEVICE 2\n" << std::endl;
    
    device::vitis alveo_2 = host::open("2", "vsub", config_id, target);
    alveo_2.print();

    host::write(alveo_2, config_id);

    // Synchronize buffer content with device side
    std::cout << "synchronize input buffer data to device global memory\n";

    //alveo_2.inputs[0].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    //alveo_2.inputs[1].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    std::cout << "Execution of the kernel\n";
    auto run_2 = alveo_2.kernel(alveo_2.inputs[0].bo, alveo_2.inputs[1].bo, alveo_2.outputs[0].bo, N); // DATA_SIZE
    run_2.wait();

    // Get the output;
    std::cout << "Get the output data from the device" << std::endl;
    alveo_2.outputs[0].bo.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    // Validate our results
    //if (std::memcmp(bo_out_map_2, bufReference, N)) // DATA_SIZE
    //    throw std::runtime_error("Value read back does not match reference");

    if (std::memcmp(alveo_2.outputs[0].bo.map<int*>(), bufReference.data(), N * sizeof(int)) != 0) { // DATA_SIZE
        throw std::runtime_error("Value read back does not match reference");
    }    

    std::cout << "TEST PASSED 2\n";
    return 0;

}
