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
#include "../global_params.hpp"
#include "../configs/config_000.hpp" // config_000.hpp is overwritten with the configuration you select

//#define DATA_SIZE 4096

int main(int argc, char** argv) {

    if (argc < 3) {
        //parser.printHelp();
        //return EXIT_FAILURE;
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
    parser.addSwitch("--device_bdf", "-b", "<device_bdf>", "");
    parser.parse(argc, argv);

    
    // std::string XCL_EMULATION_MODE = sgrt::getenv("XCL_EMULATION_MODE");
    const char* xclEmulationModeChar = std::getenv("XCL_EMULATION_MODE");
    std::string XCL_EMULATION_MODE = "";
    if (xclEmulationModeChar != nullptr) {
        XCL_EMULATION_MODE = xclEmulationModeChar;

        // ...
    }

    std::string binaryFile = parser.value("xclbin_file");
    std::string device_bdf = parser.value("device_bdf");

    std::cout << "\nXCL_EMULATION_MODE is: " << XCL_EMULATION_MODE << std::endl;
    std::cout << "binaryFile is: " << binaryFile << std::endl;
    std::cout << "device_bdf is: " << device_bdf << std::endl;

    // check on xclbin_file =========> if not(isempty()) we need to verify if it is valid!!!!!!!!!!!!
    if (binaryFile.empty()) {
        std::cerr << "\n<xclbin_file> is empty.\n" << std::endl;
        return 1;
    }

    // check on device_bdf (XCL_EMULATION_MODE means target = hw)
    if (XCL_EMULATION_MODE.empty() && device_bdf.empty()) {
        std::cerr << "\n<device_bdf> is empty.\n" << std::endl;
        return 1;
    }


/*     // Switches
    parser.addSwitch("--xclbin_file", "-x", "Specifies your XCLBIN.", "");
    parser.addSwitch("--device_bdf", "-b", "device index", "");
    parser.parse(argc, argv);

    // Read settings
    std::string binaryFile = parser.value("xclbin_file");
    std::string device_bdf = parser.value("device_bdf"); */

    if (argc < 3) {
        parser.printHelp();
        return EXIT_FAILURE;
    }

    // print config values as a test
    std::cout << "\nN: ";
    std::cout << std::to_string(N);

    //define defaults
    //std::string XCL_EMULATION_MODE="sw_emu";
    std::string current_uuid_str="00000000-0000-0000-0000-000000000000";
    std::string new_uuid_str="00000000-0000-0000-0000-000000000000";
    
    //check on number arguments/target
    //if (argc >= 4 && argv[3] != nullptr && argv[3][0] != '\0') { // per aci!!!!!!! Evalue si XCL_EMULATION_MODE es sw_emu o hw_emu y si no seria hw :-)
    //    //target is hw
    //    //std::string device_bdf = argv[3]; 
    //    std::cout << "Opening the device: " << device_bdf << std::endl;
    //    device = xrt::device(device_bdf);
    //    //XCL_EMULATION_MODE="hw";
    //} else {
    //    //target is sw_emu or hw_emu
    //    device = xrt::device(0);
    //}

    // open device
    if (!XCL_EMULATION_MODE.empty()) {
        //target is sw_emu or hw_emu
        device = xrt::device(0);
    } else {
        std::cout << "\nOpening the device: " << device_bdf << "\n" << std::endl;
        device = xrt::device(device_bdf);
    }

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

    auto krnl = xrt::kernel(device, uuid, "vadd");

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
