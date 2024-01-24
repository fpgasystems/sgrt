#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <unordered_map>

#include "../host.hpp"

template <typename T>
T host::get_config_parameter(const std::string& project_path, const std::string& config_id, const std::string& param) {

    // Construct the file path
    std::string file_path = project_path + "/configs/" + config_id + ".hpp";

    // Open the configuration file
    std::ifstream config_file(file_path);
    if (!config_file.is_open()) {
        std::cerr << "Error: Unable to open configuration file " << file_path << std::endl;
        // You may choose to handle this error differently (throw an exception, return a default value, etc.)
        exit(EXIT_FAILURE);
    }

    // Create a map to store parameter-value pairs
    std::unordered_map<std::string, T> parameter_map;

    // Read the configuration file line by line
    std::string line;
    while (std::getline(config_file, line)) {
        std::cout << "Read line: " << line << std::endl; // Debugging output

        std::istringstream iss(line);
        std::string name;
        char equal_sign;
        T value;

        // Try to extract the name, equal sign, and value
        if (iss >> name >> equal_sign >> value) {
            // Remove any trailing semicolon from the name
            name.erase(std::remove(name.begin(), name.end(), ';'), name.end());

            // Store the parameter-value pair in the map
            parameter_map[name] = value;
        }
    }

    // Close the configuration file
    config_file.close();

    // Check if the requested parameter exists in the map
    auto it = parameter_map.find(param);
    if (it != parameter_map.end()) {
        // Return the value associated with the parameter
        return it->second;
    } else {
        std::cerr << "Error: Parameter '" << param << "' not found in configuration file " << file_path << std::endl;
        // You may choose to handle this error differently (throw an exception, return a default value, etc.)
        exit(EXIT_FAILURE);
    }

}

// Explicit instantiations for the types you intend to use
template int host::get_config_parameter<int>(const std::string& project_path, const std::string& config_id, const std::string& param);
template double host::get_config_parameter<double>(const std::string& project_path, const std::string& config_id, const std::string& param);
// Add more explicit instantiations if needed