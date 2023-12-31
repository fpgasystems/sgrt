#ifndef DEVICE_HPP
#define DEVICE_HPP

#include <string> 
#include <iostream>

// XRT includes
#include <xrt/xrt_device.h>
#include "experimental/xrt_kernel.h"

namespace device {
    struct vitis {
        
        // sgutil
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

        // xrt
        xrt::device fpga; // Use xrt::device as a member
        xrt::kernel kernel;

        std::string get_uuid() {
            auto current_uuid = fpga.get_xclbin_uuid();
            std::string current_uuid_str = current_uuid.to_string();
            return current_uuid_str;
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
        }

        // Constructor (optional)
        //device() : deviceID(0) {} // Initialize members as needed
    };
}

#endif