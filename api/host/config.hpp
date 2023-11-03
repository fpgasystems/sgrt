//#ifndef DEVICE_HPP
//#define DEVICE_HPP

#include <string> 
#include <iostream>

namespace host {
    struct config {
        
        std::string project_path;
        std::string XCL_EMULATION_MODE;

        // constructor
        //config(const std::string& projectPath, const std::string& emulationMode)
        //    : project_path(projectPath), XCL_EMULATION_MODE(emulationMode) {
        //}

        void print() {
            //std::cout << "Device Index: " << device_index << std::endl;
            std::cout << "project_path: " << project_path << std::endl;
            std::cout << "XCL_EMULATION_MODE: " << XCL_EMULATION_MODE << std::endl;
            
        }

        // Constructor (optional)
        //device() : deviceID(0) {} // Initialize members as needed
    };
}

//#endif