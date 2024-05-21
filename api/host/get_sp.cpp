#include <string>
#include <vector>
#include <tuple>  // Include the tuple header
#include "../api.hpp"

std::tuple<std::vector<std::string>, std::vector<std::string>> host::get_sp() {

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

    
    // Return both vectors as a tuple
    return std::make_tuple(devices, xclbin_names);
    
}