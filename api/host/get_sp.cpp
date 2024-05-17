#include <fstream>
#include <string>
#include <sstream>
#include "../api.hpp"

std::string host::get_sp(char** argv) {

    // get project_path
    std::string project_path = host::get_project_path();

    std::string config_id = argv[1];

    return config_id;
    
}