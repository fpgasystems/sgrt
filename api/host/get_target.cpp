#include <fstream>
#include <string>
#include <sstream>

//#include "get_config.hpp" // Include the header file
#include "../host.hpp"

std::string host::get_target() {


    //host::config config;

    //config.project_path = project_path;
    //config.XCL_EMULATION_MODE = xcl_emulation_mode;
    
    //std::cout << "project_path is:" << config.project_path << std::endl;


    const char* xclEmulationModeChar = std::getenv("XCL_EMULATION_MODE");
    std::string XCL_EMULATION_MODE = "";
    if (xclEmulationModeChar != nullptr) {
        XCL_EMULATION_MODE = xclEmulationModeChar;

        // ...
    }



    return XCL_EMULATION_MODE;

    //return config;
    

}