//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
//#include "../host.hpp" // Include the device.hpp header

namespace host {
    host::config get_config(const std::string& project_path, const std::string& xcl_emulation_mode);
}

//#endif // HOST_HPP