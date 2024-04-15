
#include <vector>
#include "../host.hpp"
#include "../device.hpp"
#include "../common/sgutil_get.hpp"

std::vector<int> host::write(device::vitis device, const std::string& config_id) {

    // get project_path
    std::string project_path = host::get_project_path();
    
    // get parameters
    int N = host::get_config_parameter<int>(project_path, config_id, "N");

    // Map the contents of the buffer object into host memory
    auto bo0_map = device.inputs[0].bo.map<int*>();
    auto bo1_map = device.inputs[1].bo.map<int*>();
    auto bo_out_map = device.outputs[0].bo.map<int*>();

    std::fill(bo0_map, bo0_map + N, 0); // DATA_SIZE
    std::fill(bo1_map, bo1_map + N, 0); // DATA_SIZE
    std::fill(bo_out_map, bo_out_map + N, 0); // DATA_SIZE

    // Create the test data
    std::vector<int> bufReference(N); // DATA_SIZE
    for (int i = 0; i < N; ++i) { // DATA_SIZE
        bo0_map[i] = i;
        bo1_map[i] = i;
        bufReference[i] = bo0_map[i] + bo1_map[i];
    }

    // write
    device.inputs[0].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    device.inputs[1].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    return bufReference;

}