//#include <fstream>
#include <string>
#include <vector>
//#include <sstream>
#include "../api.hpp"

std::vector<std::string> host::get_sp(const std::string& item) {

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

    // Compare the string parameter to determine which vector to return
    if (item == "devices") {
        return devices;
    } else if (item == "xclbin_names") {
        return xclbin_names;
    } else {
        // Return an empty vector if the input string is neither "devices" nor "xclbin_names"
        std::cerr << "Invalid input: " << item << std::endl;
        return {};
    }
}