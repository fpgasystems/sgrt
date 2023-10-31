//#ifndef DEVICE_HPP
//#define DEVICE_HPP

#include <string> 
#include <iostream>

// XRT includes
//#include <xrt/xrt_device.h>
//#include "experimental/xrt_kernel.h"

namespace host {
    struct config {
        
        std::string project_path;

        void get_config() {
            //std::cout << "Device Index: " << device_index << std::endl;
            std::cout << "BDF: " << project_path << std::endl;
            
        }

        // Constructor (optional)
        //device() : deviceID(0) {} // Initialize members as needed
    };
}

//#endif