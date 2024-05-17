#include <fstream>
#include <string>
#include <sstream>
#include "../api.hpp"

std::string host::get_sp() {

    // get project_path
    std::string project_path = host::get_project_path();

    std::cout << "\e[1m" << "Hi there" << "\e[0m\n" << std::endl;

    

    return project_path;
    
}