#include <fstream>
#include <string>
#include <sstream>

//#include "get_config.hpp" // Include the header file
#include "../api.hpp"

std::string host::get_project_path() {

    char currentPath[FILENAME_MAX];
    if (getcwd(currentPath, sizeof(currentPath)) != NULL) {
        return std::string(currentPath);
    } else {
        return std::string(); // Return an empty string to indicate an error
    }

}