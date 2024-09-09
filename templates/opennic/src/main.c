#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    int flags_error = 0;
    int config_index = 0;
    int device_index = 0;

    // Check and process command-line flags
    flags_error = flags_check(argc, argv, &config_index, &device_index);

    if (flags_error == 0) {  // Correct comparison
        // read from device_config (index is set to zero)
        int num_cmac_port = atoi(read_parameter(0, "num_cmac_port"));
        if (num_cmac_port <= 0) {
            fprintf(stderr, "Error: Invalid num_cmac_port value.\n");
            return 1;
        }
        
        // read from configuration
        char *remote_server = read_parameter(config_index, "remote_server");
        if (remote_server == NULL) {
            fprintf(stderr, "Error: Could not read 'remote_server' from configuration.\n");
            return 1;
        }
        
        int num_pings = atoi(read_parameter(config_index, "NUM_PINGS"));
        if (num_pings <= 0) {
            fprintf(stderr, "Error: Invalid num_pings value.\n");
            return 1;
        }
        
        // Iterate over each CMAC port
        for (int i = 1; i <= num_cmac_port; i++) {
            // Get IP for device and port
            char *device_ip = get_network(device_index, i);
            if (device_ip == NULL) {
                fprintf(stderr, "Error: Could not get IP for device %d port %d.\n", device_index, i);
                return 1;
            }
            
            // Now get the interface name associated with this IP
            char *interface_name = get_interface_name(device_ip);
            if (interface_name == NULL) {
                fprintf(stderr, "Error: Could not get interface name for IP %s.\n", device_ip);
                return 1;
            }
            
            // Perform ping operation
            ping(interface_name, remote_server, num_pings);
        }
        
        return 0;  // Success
    } else {
        print_help(); //fprintf(stderr, "Error: flags_check failed.\n");
        return 1;  // Indicate an error occurred
    }
}