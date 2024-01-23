#include <fstream>
#include <string>
#include <sstream>

//#include "get_config.hpp" // Include the header file
#include "../host.hpp"

//host::config host::get_config(const std::string& project_path, const std::string& xcl_emulation_mode) {
std::string host::get_config(char** argv) {

    //host::config config;

    //config.project_path = project_path;
    //config.XCL_EMULATION_MODE = xcl_emulation_mode;
    
    //std::cout << "project_path is:" << config.project_path << std::endl;

    std::string config_id = argv[1];

    return config_id;
    
}