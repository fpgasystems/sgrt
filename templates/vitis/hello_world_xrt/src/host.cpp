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

    // print config values as a test
    //std::cout << "\nN: ";
    //std::cout << std::to_string(N);

    //define defaults
    std::string current_uuid_str="00000000-0000-0000-0000-000000000000";
    std::string new_uuid_str="00000000-0000-0000-0000-000000000000";

    // open device
    device::vitis fpga = host::open(device_index, binaryFile);
    device = fpga.xrtDevice;

    // Calling the get_uuid() member function


    std::cout << "BDF: " << fpga.bdf << std::endl;
    std::cout << "Device name: " << fpga.device_name << std::endl;
    std::cout << "Serial number: " << fpga.serial_number << std::endl;
    std::cout << "UUID: " << fpga.get_uuid() << std::endl; // Calling the get_uuid() member function
    std::cout << "IP0: " << fpga.IP0 << std::endl;
    std::cout << "IP1: " << fpga.IP1 << std::endl;
    std::cout << "MAC0: " << fpga.MAC0 << std::endl;
    std::cout << "MAC1: " << fpga.MAC1 << std::endl;
    std::cout << "Platform: " << fpga.platform << std::endl;

    //get new_uuid_str
    xrt::xclbin new_xclbin = xrt::xclbin(binaryFile);
    auto new_uuid = new_xclbin.get_uuid();
    new_uuid_str = new_uuid.to_string();
    
    //print xclbin to be loaded
    std::cout << "\nFetching xclbin: " << new_uuid_str << std::endl;

    //check on existing xclbin
    if (XCL_EMULATION_MODE.empty()) { //if (XCL_EMULATION_MODE == "hw") {
        //read the xclbin loaded on the device
        auto current_uuid = device.get_xclbin_uuid();
        
        //get UUID 
        //std::string current_uuid_str = current_uuid.to_string();
        current_uuid_str = current_uuid.to_string();

        //check if UUID is still empty (xclbin was not loaded) or not matching
        if (current_uuid_str == "00000000-0000-0000-0000-000000000000" || current_uuid_str != new_uuid_str){
            // UUID is equal to zero, so terminate the program
            std::cout << "\nPlease, load the xclbin first using sgutil program vitis" << std::endl;
            exit(EXIT_FAILURE);
        }
    }

    //load xclbin after verification
    std::cout << "Loading xclbin: " << binaryFile << " (" << new_uuid_str << ")" << std::endl;
    auto uuid = device.load_xclbin(binaryFile);

    size_t vector_size_bytes = sizeof(int) * N; //DATA_SIZE

    xrt::kernel krnl = xrt::kernel(device, uuid, "vadd"); // fpga.uuid

    std::cout << "Allocate Buffer in Global Memory\n";
    auto bo0 = xrt::bo(device, vector_size_bytes, krnl.group_id(0));
    auto bo1 = xrt::bo(device, vector_size_bytes, krnl.group_id(1));
    auto bo_out = xrt::bo(device, vector_size_bytes, krnl.group_id(2));

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
