#ifndef DEVICE_HPP
#define DEVICE_HPP

#include <string> 
#include <iostream>

// XRT includes
#include <xrt/xrt_device.h>
#include "experimental/xrt_kernel.h"
#include "experimental/xrt_bo.h"

namespace device {
    struct vitis {

        // XRT
        xrt::device fpga; // Use xrt::device as a member
        xrt::kernel kernel;
        
        // SGRT (sgutil)
        int device_index;
        std::string bdf;
        std::string device_name;
        std::string serial_number;
        std::string binaryFile;
        std::string uuid;
        std::string IP0;
        std::string IP1;
        std::string MAC0;
        std::string MAC1;
        std::string platform;

        std::string get_uuid() {
            auto current_uuid = fpga.get_xclbin_uuid();
            std::string current_uuid_str = current_uuid.to_string();
            return current_uuid_str;
        }

        // struct to represent an input or output
        struct Port {
            xrt::bo bo;
            std::string name;
            std::string type;
        };

        // inputs is an array ports
        std::vector<Port> inputs;

        // output is an array ports
        std::vector<Port> outputs;

        // Function to add an input port
        void add_input(xrt::device& device, size_t buffer_size, uint32_t kernel_argument_index, const std::string& name, const std::string& type) {
            inputs.push_back({xrt::bo(device, buffer_size, kernel_argument_index), name, type});
        }

        // Function to add an output port
        void add_output(xrt::device& device, size_t buffer_size, uint32_t kernel_argument_index, const std::string& name, const std::string& type) {
            outputs.push_back({xrt::bo(device, buffer_size, kernel_argument_index), name, type});
        }

        void print() {
            //std::cout << "Device Index: " << device_index << std::endl;
            std::cout << "BDF: " << bdf << std::endl;
            std::cout << "Device Name: " << device_name << std::endl;
            std::cout << "Serial Number: " << serial_number << std::endl;
            std::cout << "Binary File: " << binaryFile << std::endl;
            std::cout << "UUID: " << get_uuid() << std::endl;
            std::cout << "IP0: " << IP0 << std::endl;
            std::cout << "IP1: " << IP1 << std::endl;
            std::cout << "MAC0: " << MAC0 << std::endl;
            std::cout << "MAC1: " << MAC1 << std::endl;
            std::cout << "Platform: " << platform << std::endl;

            // inputs
            std::cout << "\nDeclared Inputs:" << std::endl;
            for (size_t i = 0; i < inputs.size(); ++i) {
                std::cout << i + 1 << ": " << inputs[i].name << " (Type: " << inputs[i].type << ")" << std::endl;
            }

            // outputs
            std::cout << "\nDeclared Outputs:" << std::endl;
            for (size_t i = 0; i < outputs.size(); ++i) {
                std::cout << i + 1 << ": " << outputs[i].name << " (Type: " << outputs[i].type << ")" << std::endl;
            }

        }

        // Constructor (optional)
        //device() : deviceID(0) {} // Initialize members as needed
    };
}

#endif