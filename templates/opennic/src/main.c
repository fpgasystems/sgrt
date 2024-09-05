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

    // Get IP for device 1 and port 1
    char *device_ip = get_network(atoi(device_index), 1);
    
    // Now get the interface name associated with this IP
    char *interface_name = get_interface_name(device_ip);
    
    // Retrieve number of pings from the configuration
    int num_pings = read_parameter(config_index, "NUM_PINGS");

    // Perform ping operation
    ping(interface_name, remote_server_name, num_pings);

    return 0;
}