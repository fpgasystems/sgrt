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
#include "cmdlineparser.h"
#include <iostream>
#include <cstring>

// XRT includes
#include "experimental/xrt_bo.h"
#include "experimental/xrt_device.h"
#include "experimental/xrt_kernel.h"

// SGRT includes
#include "/opt/sgrt/api/host.hpp"
#include "/opt/sgrt/api/device.hpp"

// project includes
#include "../global_params.hpp"
#include "../configs/config_000.hpp" // config_000.hpp is overwritten with the configuration you select

int main(int argc, char** argv) {

    if (argc < 3) {
        std::cout << "\n" << argv[0] << " requires at least the bitstream!\n" << std::endl;
        return 1;
    }

    // host objects
    sda::utils::CmdLineParser parser;

    // XRT objects
    xrt::device device;

    // SGRT objects
    // ...

    // read parameters
    parser.addSwitch("--xclbin_file", "-x", "<xclbin_file>", "");
    parser.addSwitch("--device_index", "-d", "<device_index>", "");
    parser.parse(argc, argv);

    
    const char* xclEmulationModeChar = std::getenv("XCL_EMULATION_MODE");
    std::string XCL_EMULATION_MODE = "";
    if (xclEmulationModeChar != nullptr) {
        XCL_EMULATION_MODE = xclEmulationModeChar;

        // ...
    }

    std::string binaryFile = parser.value("xclbin_file");
    std::string device_index = parser.value("device_index");

    // check on xclbin_file =========> if not(isempty()) we need to verify if it is valid!!!!!!!!!!!!
    if (binaryFile.empty()) {
        std::cerr << "\n<xclbin_file> is empty.\n" << std::endl;
        return 1;
    }

    // forbiden combinations
    if (!XCL_EMULATION_MODE.empty() && !device_index.empty()) {
        std::cerr << "\n<device_index> is not required for emulation modes.\n" << std::endl;
        return 1;
    } else if (XCL_EMULATION_MODE.empty() && device_index.empty()) {
        std::cerr << "\n<device_index> is required for hw targets.\n" << std::endl;
        return 1;
    }

    // open device
    device::vitis fpga = host::open(device_index, binaryFile);
    fpga.get_info();
    
    // funciona amb hw i falla sw_emu
    //device::vitis fpga_aux = host::open("2", binaryFile); 
    //fpga_aux.get_info();

    xrt::uuid uuid = fpga.xrtDevice.load_xclbin(fpga.binaryFile); 
    
    xrt::kernel krnl = xrt::kernel(fpga.xrtDevice, uuid, "vadd"); // fpga.uuid

    size_t vector_size_bytes = sizeof(int) * N; //DATA_SIZE

    std::cout << "Allocate Buffer in Global Memory\n";
    auto bo0 = xrt::bo(fpga.xrtDevice, vector_size_bytes, krnl.group_id(0));
    auto bo1 = xrt::bo(fpga.xrtDevice, vector_size_bytes, krnl.group_id(1));
    auto bo_out = xrt::bo(fpga.xrtDevice, vector_size_bytes, krnl.group_id(2));

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
    auto run = krnl(bo0, bo1, bo_out, N); // DATA_SIZE
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
