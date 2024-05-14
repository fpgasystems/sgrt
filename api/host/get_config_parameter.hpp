//#ifndef HOST_HPP
//#define HOST_HPP

#include <string>

namespace host {
    //std::string get_config_parameter(const std::string& project_path, const std::string& config_id, const std::string& parameter);
    template <typename T>
    T get_config_parameter(const std::string& project_path, const std::string& config_id, const std::string& param);
}

//#endif // HOST_HPP