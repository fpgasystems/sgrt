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
#include "../global_params.hpp"
#include "../configs/config_000.hpp" // config_000.hpp is overwritten with the configuration you select

std::string get_current_path() {
    char currentPath[FILENAME_MAX];
    if (getcwd(currentPath, sizeof(currentPath)) != NULL) {
        return std::string(currentPath);
    } else {
        return std::string(); // Return an empty string to indicate an error
    }
}

int main(int argc, char** argv) {

    if (argc > 2) {
        //std::cout << "\n" << argv[0] << " does not accept any additional parameters.\n" << std::endl;
        std::cout << "\n" << argv[0] << ": too many input parameters.\n" << std::endl;
        return 1;
    }

    //std::string config_id = argv[1];
    //std::cout << "\nconfig_id = " << config_id << std::endl;

    std::string config_id = host::get_config(argv);
    std::cout << "\nconfig_id = " << config_id << std::endl;
    
    //const char* xclEmulationModeChar = std::getenv("XCL_EMULATION_MODE");
    //std::string XCL_EMULATION_MODE = "";
    //if (xclEmulationModeChar != nullptr) {
    //    XCL_EMULATION_MODE = xclEmulationModeChar;

        // ...
    //}

    std::string XCL_EMULATION_MODE = host::get_target();

    std::cout << "\nTARGET is = " << XCL_EMULATION_MODE << std::endl;

    // get project_path
    std::string project_path = get_current_path();
    std::cout << "\nOLD project_path is = " << project_path << std::endl;

    std::string new_project_path = host::get_project_path();
    std::cout << "\nNEW project_path is = " << new_project_path << std::endl;

    //                            host::config config = host::get_config(project_path, XCL_EMULATION_MODE);
    //                            config.print();

    // Create a host::config object using the constructor
    //host::config myConfig(project_path, XCL_EMULATION_MODE);
    //myConfig.print;

    // device 1
    device::vitis alveo_1 = host::open("1", project_path, XCL_EMULATION_MODE);
    //xrt::uuid uuid = alveo_1.fpga.load_xclbin(alveo_1.binaryFile);
    //xrt::kernel krnl = xrt::kernel(alveo_1.fpga, uuid, "vadd");
    //xrt::kernel krnl = alveo_1.kernel; //xrt::kernel(alveo_1.fpga, uuid, "vadd");
    alveo_1.print();

    size_t vector_size_bytes = sizeof(int) * N; //DATA_SIZE

    std::cout << "Allocate Buffer in Global Memory\n";
    auto bo0 = xrt::bo(alveo_1.fpga, vector_size_bytes, alveo_1.kernel.group_id(0));
    auto bo1 = xrt::bo(alveo_1.fpga, vector_size_bytes, alveo_1.kernel.group_id(1));
    auto bo_out = xrt::bo(alveo_1.fpga, vector_size_bytes, alveo_1.kernel.group_id(2));

    // Map the contents of the buffer object into host memory
    auto bo0_map = bo0.map<int*>();
    auto bo1_map = bo1.map<int*>();
    auto bo_out_map = bo_out.map<int*>();
    std::fill(bo0_map, bo0_map + N, 0); // DATA_SIZE
    std::fill(bo1_map, bo1_map + N, 0); // DATA_SIZE
    std::fill(bo_out_map, bo_out_map + N, 0); // DATA_SIZE

    // Create the test data
    int bufReference[N]; // DATA_SIZE
    for (int i = 0; i < N; ++i) { // DATA_SIZE
        bo0_map[i] = i;
        bo1_map[i] = i;
        bufReference[i] = bo0_map[i] + bo1_map[i];
    }

    // Synchronize buffer content with device side
    std::cout << "synchronize input buffer data to device global memory\n";

    bo0.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    bo1.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    std::cout << "Execution of the kernel\n";
    auto run = alveo_1.kernel(bo0, bo1, bo_out, N); // DATA_SIZE
    run.wait();

    // Get the output;
    std::cout << "Get the output data from the device" << std::endl;
    bo_out.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    // Validate our results
    if (std::memcmp(bo_out_map, bufReference, N)) // DATA_SIZE
        throw std::runtime_error("Value read back does not match reference");

    std::cout << "TEST PASSED\n";
    return 0;
}
