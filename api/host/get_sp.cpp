//#include <fstream>
#include <string>
#include <vector>
//#include <sstream>
#include "../api.hpp"

std::vector<std::string> host::get_sp() {

    // get project_path
    //std::string project_path = host::get_project_path();

    std::cout << "\e[1m" << "Hi there" << "\e[0m\n" << std::endl;

    // Create a vector of strings for devices and xclbin_names
    std::vector<std::string> devices;
    std::vector<std::string> xclbin_names;

    // Add project_path to the vector (modify as needed to add more paths)
    devices.push_back("1");
    devices.push_back("2");


    xclbin_names.push_back("vadd");
    xclbin_names.push_back("vsub");

    
    return devices;
    
}