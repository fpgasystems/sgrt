#include "sgutil_get.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

std::string sgutil_get(int device_index, int columnNumber) {
    std::string filename = "/opt/sgrt/cli/devices_acap_fpga";
    
    std::ifstream inputFile(filename);

    if (!inputFile) {
        std::cerr << "Error opening file." << std::endl;
        return ""; // Return an empty string to indicate an error
    }

    std::string line;
    while (std::getline(inputFile, line)) {
        // Split the line into columns based on whitespace
        std::istringstream iss(line);
        int column1;
        std::string value;

        if (iss >> column1) {
            if (column1 == device_index) {
                for (int i = 1; i <= columnNumber; ++i) {
                    if (!(iss >> value)) {
                        break; // Return an empty string if there are fewer than columnNumber columns
                    }
                }
                inputFile.close();
                return value; // Return the value in the specified column
            }
        }
    }

    inputFile.close();
    return ""; // Return an empty string if no matching value is found
}
