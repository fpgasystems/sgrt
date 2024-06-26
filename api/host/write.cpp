
#include <vector>
#include "../api.hpp"

void host::write(device::vitis device, const std::vector<std::vector<int>>& host_inputs) {
    // derive N
    int N = host_inputs[0].size();

    // Map the contents of the buffer object into host memory and reset
    // Inputs
    auto bo0_map = device.inputs[0].bo.map<int*>();
    auto bo1_map = device.inputs[1].bo.map<int*>();
    std::fill(bo0_map, bo0_map + N, 0);
    std::fill(bo1_map, bo1_map + N, 0);

    // Outputs
    auto bo_out_map = device.outputs[0].bo.map<int*>();
    std::fill(bo_out_map, bo_out_map + N, 0);

    // Set input vectors
    for (int i = 0; i < N; ++i) {
        bo0_map[i] = host_inputs[0][i];
        bo1_map[i] = host_inputs[1][i];
    }

    // Sync inputs to the device
    device.inputs[0].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    device.inputs[1].bo.sync(XCL_BO_SYNC_BO_TO_DEVICE);
}