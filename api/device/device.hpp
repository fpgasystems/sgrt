#ifndef DEVICE_HPP
#define DEVICE_HPP

#include <string> // Include <string> for std::string

// XRT includes
//#include "experimental/xrt_bo.h"
//#include "experimental/xrt_device.h"
#include <xrt/xrt_device.h> // Include the appropriate header for xrt::device

namespace device {
    struct vitis {
        xrt::device xrt_device; // Use xrt::device as a member
        int device_index; // Example member
        std::string serial_number;
        // Add more members as needed


        //xrt::device& getXrtDevice() { // podem fer el mateix per al xclbin
        //    return xrt_device;
        //}

        // Constructor (optional)
        //device() : deviceID(0) {} // Initialize members as needed
    };
}

#endif