#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    char *onic_name = NULL;
    char *remote_server_name = NULL;
    int config_index = 0;

    // Check and process command-line flags
    flags_check(argc, argv, &onic_name, &remote_server_name, &config_index);

    // Print the captured --device value
    if (onic_name != NULL) {
        printf("Captured --device value: %s\n", onic_name);
    } else {
        printf("No value provided for --device.\n");
    }

    // Get IP for device 1 and port 1
    char *device_ip1 = get_network(1, 1);
    if (device_ip1 != NULL) {
        printf("Device IP (port 1): %s\n", device_ip1);
        
        // Now get the interface name associated with this IP
        char *interface_name1 = get_interface_name(device_ip1);
        if (interface_name1 != NULL) {
            printf("Interface for IP %s: %s\n", device_ip1, interface_name1);
        } else {
            printf("Failed to retrieve interface for IP %s\n", device_ip1);
        }
    } else {
        printf("Failed to retrieve device IP for port 1.\n");
    }

    // Retrieve number of pings from the configuration
    int num_pings = read_parameter(config_index, "NUM_PINGS");
    if (num_pings == -1) {
        return 1;
    }

    // Perform ping operation
    ping(onic_name, remote_server_name, num_pings);

    return 0;
}