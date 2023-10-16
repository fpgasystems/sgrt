#include "open.hpp" // Include the header file
#include "../device.hpp"
#include "../common/sgutil_get.hpp"

std::string replace_string(const std::string& input, const std::string& target, const std::string& replacement) {
    std::string result = input;
    size_t pos = result.find(target);
    while (pos != std::string::npos) {
        result.replace(pos, target.length(), replacement);
        pos = result.find(target, pos + replacement.length());
    }
    return result;
}

std::string get_string(const std::string& input, int position) {
    size_t slashPos = input.find('/');
    if (slashPos != std::string::npos) {
        if (position == 0) {
            // Extract the substring before the slash
            return input.substr(0, slashPos);
        } else if (position == 1) {
            // Extract the substring after the slash
            return input.substr(slashPos + 1);
        } else {
            // Invalid position, return an empty string
            return "";
        }
    } else {
        // Slash not found, return the original input
        return input;
    }
}

device::vitis host::open(const std::string& device_index, const std::string& binaryFile, const std::string& emulationMode) {

    // sgutil_get constants 
    int UPSTREAM_PORT = 1;
    int DEVICE_NAME = 5;
    int SERIAL_NUMBER = 6;
    int IP = 7;
    int MAC = 8;
    int PLATFORM = 9;

    // XRT and SGRT objects
    xrt::device xrt_device;
    device::vitis device;
    
    // constants
    std::string current_uuid_str="00000000-0000-0000-0000-000000000000";
    std::string bdf = "0000:00:00.0";

    if (emulationMode == "sw_emu" || emulationMode == "hw_emu") { //if (device_index.empty()) {
        
        // create XRT device
        xrt_device = xrt::device(0);

        //xrt::uuid current_uuid = xrt_device.get_xclbin_uuid();
        //device.uuid = current_uuid;

        // fill minimum device struct members
        device.bdf = bdf;
        device.binaryFile = binaryFile;

    } else {
        
        // constants
        //std::string current_uuid_str="00000000-0000-0000-0000-000000000000";
        std::string new_uuid_str="00000000-0000-0000-0000-000000000000";

        // get device index
        device.device_index = std::stoi(device_index);

        // get BDF
        bdf = replace_string(sgutil_get(device.device_index, UPSTREAM_PORT), ".0", ".1");

        // fill device struct members
        device.bdf = bdf;
        device.device_name = sgutil_get(device.device_index, DEVICE_NAME);
        device.serial_number = sgutil_get(device.device_index, SERIAL_NUMBER);
        device.binaryFile = binaryFile;
        device.IP0 = get_string(sgutil_get(device.device_index, IP), 0);
        device.IP1 = get_string(sgutil_get(device.device_index, IP), 1);
        device.MAC0 = get_string(sgutil_get(device.device_index, MAC), 0);
        device.MAC1 = get_string(sgutil_get(device.device_index, MAC), 1);
        device.platform = sgutil_get(device.device_index, PLATFORM);

        // create XRT device
        xrt_device = xrt::device(bdf);

        // load xclbin
        xrt::xclbin new_xclbin = xrt::xclbin(binaryFile);
        xrt::uuid new_uuid = new_xclbin.get_uuid();
        xrt::uuid current_uuid = xrt_device.get_xclbin_uuid();
        
        // compare and load
        current_uuid_str = current_uuid.to_string();
        new_uuid_str = new_uuid.to_string();
        std::cout << "Device " << device_index << " - Loading xclbin: "<< new_uuid_str << std::endl;
        if (current_uuid_str == "00000000-0000-0000-0000-000000000000" || current_uuid_str != new_uuid_str){
            // load new xclbin
            xrt_device.load_xclbin(binaryFile);
            device.uuid = new_uuid_str; //device.get_uuid(); //uuid;
        } else {
            // requested xclbin was already loaded
            device.uuid = current_uuid_str; //current_uuid;
        }
        std::cout << "Done!\n" << std::endl;

    }

    // assign XRT device
    device.fpga = xrt_device;
    
    return device;

}