#ifndef GET_DEVICE_HPP
#define GET_DEVICE_HPP

#include <string>
#include <xrt/xrt_device.h> // Include the appropriate header for xrt::device

namespace host {
    xrt::device get_device(const std::string& device_bdf);
}

#endif // GET_DEVICE_HPP