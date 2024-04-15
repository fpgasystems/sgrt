
#include <string>
#include <vector>
#include "../host.hpp"
//#include "../device.hpp"
//#include "../common/sgutil_get.hpp"

std::vector<int> host::create_data(const std::string& config_id) {

    // get project_path
    std::string project_path = host::get_project_path();
    
    // get parameters
    int N = host::get_config_parameter<int>(project_path, config_id, "N");

    // Create the test data
    std::vector<int> data_in(N); // DATA_SIZE
    for (int i = 0; i < N; ++i) { // DATA_SIZE
        //bo0_map[i] = i;
        //bo1_map[i] = i;
        data_in[i] = i;
    }
    
    return data_in;

}