#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    //char *onic_name = NULL;
    char *device_index = NULL;
    char *remote_server_name = NULL;
    int config_index = 0;

    // Define and initialize device_index as a string
    //char *device_index_str = "1"; // or use NULL and set it dynamically

    // Convert device_index_str to an integer
    //int device_index = atoi(device_index_str); // A

    // Check and process command-line flags
    flags_check(argc, argv, &device_index, &remote_server_name, &config_index);

    // Convert device_index_str to an integer
    //int device_index = atoi(device_index); // A

    // Print the captured --device value
    //if (onic_name != NULL) {
    //    printf("Captured --device value: %s\n", onic_name);
    //} else {
    //    printf("No value provided for --device.\n");
    //}

    // Get IP for device 1 and port 1
    char *device_ip1 = get_network(atoi(device_index), 1);
    //if (device_ip1 != NULL) {
    //    printf("Device IP (port 1): %s\n", device_ip1);
        
    //    // Now get the interface name associated with this IP
        char *interface_name1 = get_interface_name(device_ip1);
    //    if (interface_name1 != NULL) {
    //        printf("Interface for IP %s: %s\n", device_ip1, interface_name1);
    //    } else {
    //        printf("Failed to retrieve interface for IP %s\n", device_ip1);
    //    }
    //} else {
    //    printf("Failed to retrieve device IP for port 1.\n");
    //}

    // Retrieve number of pings from the configuration
    int num_pings = read_parameter(config_index, "NUM_PINGS");
    if (num_pings == -1) {
        return 1;
    }

    // Perform ping operation
    ping(interface_name1, remote_server_name, num_pings);

    return 0;
}