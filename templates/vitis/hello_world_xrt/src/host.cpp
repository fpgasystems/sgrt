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

int main(int argc, char** argv) {

    if (argc > 2) {
        std::cout << "\n" << argv[0] << ": too many input parameters.\n" << std::endl;
        return 1;
    }

    // get project_path
    //std::string project_path = host::get_project_path();

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

    // get sp (Synthesis and Implementation Process) file
    std::vector<std::string> devices = host::get_sp("devices");
    std::vector<std::string> xclbin_names = host::get_sp("xclbin_names");
    for (const std::string& device : devices) {
        std::cout << device << std::endl;
    }

    for (const std::string& xclbin_name : xclbin_names) {
        std::cout << xclbin_name << std::endl;
    }

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
