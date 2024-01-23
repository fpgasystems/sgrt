#include <fstream>
#include <string>
#include <sstream>

//#include "get_config.hpp" // Include the header file
#include "../host.hpp"

std::string host::get_target() {

    const char* xclEmulationModeChar = std::getenv("XCL_EMULATION_MODE");
    std::string XCL_EMULATION_MODE = "";
    if (xclEmulationModeChar != nullptr) {
        XCL_EMULATION_MODE = xclEmulationModeChar;
        // ...
    } else if (XCL_EMULATION_MODE.empty()) {
        XCL_EMULATION_MODE = "hw";
    }

    return XCL_EMULATION_MODE;

}