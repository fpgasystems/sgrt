#ifndef DEVICE_HPP
#define DEVICE_HPP

#include <string> // Include <string> for std::string

// XRT includes
//#include "experimental/xrt_bo.h"
//#include "experimental/xrt_device.h"
#include <xrt/xrt_device.h> // Include the appropriate header for xrt::device

namespace device {
    struct vitis {
        // sgutil
        int device_index; // Example member
        std::string bdf;
        std::string device_name;
        std::string serial_number;
        std::string IP0;
        std::string IP1;
        std::string MAC0;
        std::string MAC1;
        std::string platform;
        // Add more members as needed

        // xrt
        xrt::device xrtDevice; // Use xrt::device as a member

        //xrt::device& getXrtDevice() { // podem fer el mateix per al xclbin
        //    return xrt_device;
        //}

        // Constructor (optional)
        //device() : deviceID(0) {} // Initialize members as needed
    };
}

#endif