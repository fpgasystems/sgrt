#include <fstream>
#include <string>
#include <sstream>
#include "../api.hpp"

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

//std::string get_xclbin_name(int device_index, const std::string& file_path) {
//    // Open the file for reading
//    std::ifstream file(file_path);
//
//    if (!file.is_open()) {
//        // Handle the case where the file couldn't be opened
//        // You might want to return a default XCLBIN name or an error message.
//       return ""; // Change this as needed
//    }
//
//    std::string line;
//    while (std::getline(file, line)) {
//        std::istringstream iss(line);
//        int index;
//        std::string xclbinName;
//
//        // Read the first column (device_index)
//        if (iss >> index) {
//            // Read the second column (XCLBIN name)
//            if (iss >> xclbinName) {
//                if (index == device_index) {
//                    // Close the file and return the XCLBIN name
//                    file.close();
//                    return xclbinName;
//                }
//            }
//        }
//    }
//
//    // Close the file
//    file.close();
//
//    // return empty to indicate an error
//    return ""; // Change this as needed
//}

//std::string get_target(const std::string& emulationMode) {
//    std::string target = "hw";
//    if (emulationMode == "sw_emu" || emulationMode == "hw_emu") {
//        target = emulationMode;
//    }
//
//   return target;
//
//}

device::vitis host::open(const std::string& device_index, const std::string& xclbin_name, const std::string& config_id, const std::string& target) {

    // sgutil_get constants 
    int UPSTREAM_PORT = 1;
    int DEVICE_NAME = 5;
    int SERIAL_NUMBER = 6;
    int IP = 7;
    int MAC = 8;
    int PLATFORM = 9;

    // XRT objects
    xrt::device xrt_device;
    xrt::uuid uuid;
    xrt::kernel kernel;
    
    // SGRT objects
    device::vitis device;
    
    // constants
    std::string current_uuid_str="00000000-0000-0000-0000-000000000000";
    //std::string bdf = "0000:00:00.0";
    //int MAX_DEVICES = 4;

    // get project_path
    std::string project_path = host::get_project_path();

    // get device index
    device.device_index = std::stoi(device_index);

    // get acap_fpga_xclbin file
    //std::string acap_fpga_xclbin = project_path + "/acap_fpga_xclbin";

    // get xclbin name
    //std::string xclbin_name = get_xclbin_name(device.device_index, acap_fpga_xclbin);

    // get BDF
    device.bdf = replace_string(sgutil_get(device.device_index, UPSTREAM_PORT), ".0", ".1");

    // get platform
    device.platform = sgutil_get(device.device_index, PLATFORM);

    // get parameters
    int N = host::get_config_parameter<int>(project_path, config_id, "N");
    
    // set binaryFile
    //std::string binaryFile = project_path + "/build_dir." + xclbin_name + "." + target + "." + device.platform + "/" + xclbin_name + ".xclbin"; // get_target(emulationMode)
    std::string binaryFile = project_path + "/" + xclbin_name + "." + target + "." + device.platform + "/" + xclbin_name + ".xclbin"; // get_target(emulationMode)
    device.binaryFile = replace_string(binaryFile, project_path, ".");

    // print
    std::cout << "\e[1m" << "Openning device " << device_index << " (" << xclbin_name << "):" << "\e[0m\n" << std::endl;

    if (target == "sw_emu" || target == "hw_emu") {

        // create XRT device
        xrt_device = xrt::device(device.device_index - 1);

    } else {
        
        // constants
        std::string new_uuid_str="00000000-0000-0000-0000-000000000000";

        // fill device struct members
        //device.bdf = bdf;
        device.device_name = sgutil_get(device.device_index, DEVICE_NAME);
        device.serial_number = sgutil_get(device.device_index, SERIAL_NUMBER);
        device.IP0 = get_string(sgutil_get(device.device_index, IP), 0);
        device.IP1 = get_string(sgutil_get(device.device_index, IP), 1);
        device.MAC0 = get_string(sgutil_get(device.device_index, MAC), 0);
        device.MAC1 = get_string(sgutil_get(device.device_index, MAC), 1);

        // create XRT device
        xrt_device = xrt::device(device.bdf);

        // load xclbin
        xrt::xclbin new_xclbin = xrt::xclbin(device.binaryFile);
        xrt::uuid new_uuid = new_xclbin.get_uuid();
        xrt::uuid current_uuid = xrt_device.get_xclbin_uuid();
        
        // compare and load
        current_uuid_str = current_uuid.to_string();
        new_uuid_str = new_uuid.to_string();
        std::cout << "Loading xclbin: "<< new_uuid_str << std::endl;
        if (current_uuid_str == "00000000-0000-0000-0000-000000000000" || current_uuid_str != new_uuid_str){
            // load new xclbin
            xrt_device.load_xclbin(device.binaryFile);
            device.uuid = new_uuid_str;
        } else {
            // requested xclbin was already loaded
            device.uuid = current_uuid_str;
        }
        // std::cout << "Done!\n" << std::endl;

    }

    // assign XRT device
    device.fpga = xrt_device;

    // create kernel
    uuid = device.fpga.load_xclbin(device.binaryFile);
    kernel = xrt::kernel(device.fpga, uuid, xclbin_name); // xclbin_name "vadd"

    // assign XRT kernel
    device.kernel = kernel;

    // ------------------------------------------------------------

    // add input ports (this adds to the device, which links to the device.fpga)
    size_t vector_size_bytes = sizeof(int) * N; //DATA_SIZE
    auto bank_grp_arg0 = device.kernel.group_id(0);
    auto bank_grp_arg1 = device.kernel.group_id(1);

    device.add_input(device.fpga, vector_size_bytes, bank_grp_arg0, "v_1", "INTEGER");
    device.add_input(device.fpga, vector_size_bytes, bank_grp_arg1, "v_2", "INTEGER");
    
    // add input ports (this adds to the device, which links to the device.fpga)
    auto bank_grp_arg2 = device.kernel.group_id(2);
    device.add_output(device.fpga, vector_size_bytes, bank_grp_arg2, "v_add", "INTEGER");

    // ------------------------------------------------------------
    
    // print
    std::cout << "\nDone!\n" << std::endl;

    return device;

}