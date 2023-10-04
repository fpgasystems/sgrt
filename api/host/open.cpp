#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

#include "open.hpp" // Include the header file
#include "../device.hpp"

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

device::vitis host::open(const std::string& device_bdf) {

    // sgutil_get 
    int SERIAL_NUMBER = 6;
    
    xrt::device xrt_device;
    device::vitis device;

    if (device_bdf.empty()) {
        xrt_device = xrt::device(0);
    } else {
        std::cout << "\nOpening the device: " << device_bdf << "\n" << std::endl;
        xrt_device = xrt::device(device_bdf);
    }

    device.device_index = 1;
    //device.serial_number = "12345";
    device.xrtDevice = xrt_device;

    int device_index = 2; // Example device index
    std::string serial_number = sgutil_get(device_index, SERIAL_NUMBER);

    device.serial_number = serial_number;
    
    return device;

}