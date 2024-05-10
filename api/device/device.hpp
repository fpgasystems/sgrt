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

        std::string get_device_index() {
            // Convert device_index integer to string
            std::string index_str = std::to_string(device_index);

            return index_str;
        }
        
        std::string get_xclbin_name() {
            size_t lastSlashPos = binaryFile.find_last_of('/');
            size_t xclbinPos = binaryFile.find(".xclbin", lastSlashPos);
            std::string xclbin_name = binaryFile.substr(lastSlashPos + 1, xclbinPos - lastSlashPos - 1);

            return xclbin_name;
        }

        void print() {
            // get xclbin_name
            //size_t lastSlashPos = binaryFile.find_last_of('/');
            //size_t xclbinPos = binaryFile.find(".xclbin", lastSlashPos);
            //std::string xclbin_name = binaryFile.substr(lastSlashPos + 1, xclbinPos - lastSlashPos - 1);
            
            // get xclbin_name using the get_xclbin_name() function
            std::string xclbin_name = get_xclbin_name();

            std::cout << "\e[1m" << "Printing device " << device_index << " (" << xclbin_name << ") information:" << "\e[0m\n" << std::endl;
            
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
            std::cout << "\nInput ports:" << std::endl;
            for (size_t i = 0; i < inputs.size(); ++i) {
                std::cout << i << ": " << inputs[i].name << " (Type: " << inputs[i].type << ")" << std::endl;
            }

            // outputs
            std::cout << "\nOutput ports:" << std::endl;
            for (size_t i = 0; i < outputs.size(); ++i) {
                std::cout << i << ": " << outputs[i].name << " (Type: " << outputs[i].type << ")" << std::endl;
            }
            std::cout << std::endl; // Remove \n or std::endl here

        }

        // Constructor (optional)
        //device() : deviceID(0) {} // Initialize members as needed
    };
}

#endif