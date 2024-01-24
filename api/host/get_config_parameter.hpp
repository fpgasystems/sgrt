//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>
//#include "../host.hpp" // Include the device.hpp header

namespace host {
    //std::string get_config_parameter(const std::string& project_path, const std::string& config_id, const std::string& parameter);
    template <typename T>
    T get_config_parameter(const std::string& project_path, const std::string& config_id, const std::string& param);
}

//#endif // HOST_HPP