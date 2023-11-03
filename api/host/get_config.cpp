#include <fstream>
#include <string>
#include <sstream>

//#include "get_config.hpp" // Include the header file
#include "../host.hpp"

host::config host::get_config(const std::string& project_path) {


    host::config config;

    config.project_path = project_path;
    
    std::cout << "project_path is:" << config.project_path << std::endl;
    

}