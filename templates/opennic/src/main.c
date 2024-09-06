#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    //char *onic_name = NULL;
    char *device_index = NULL;
    char *remote_server_name = NULL;
    int config_index = 0;

    // Check and process command-line flags
    flags_check(argc, argv, &device_index, &remote_server_name, &config_index);

    // read from device_config (index is set to zero)
    int num_cmac_port = atoi(read_parameter(0, "num_cmac_port"));
    
    // read from configuration
    int num_pings = atoi(read_parameter(config_index, "NUM_PINGS"));
    
    // Iterate over each CMAC port
    for (int i = 1; i <= num_cmac_port; i++) {
        // Get IP for device and port
        char *device_ip = get_network(atoi(device_index), i);
        
        // Now get the interface name associated with this IP
        char *interface_name = get_interface_name(device_ip);
        
        // Perform ping operation
        ping(interface_name, remote_server_name, num_pings);
    }
    
    return 0;
}