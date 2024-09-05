#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    char *onic_name = NULL;
    char *remote_server_name = NULL;
    int index = 0;

    // Example: Get IP for device 1 and port 1
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

    // Example: Get IP for device 1 and port 2
    char *device_ip2 = get_network(1, 2);
    if (device_ip2 != NULL) {
        printf("Device IP (port 2): %s\n", device_ip2);
        
        // Now get the interface name associated with this IP
        char *interface_name2 = get_interface_name(device_ip2);
        if (interface_name2 != NULL) {
            printf("Interface for IP %s: %s\n", device_ip2, interface_name2);
        } else {
            printf("Failed to retrieve interface for IP %s\n", device_ip2);
        }
    } else {
        printf("Failed to retrieve device IP for port 2.\n");
    }

    // Check flags and assign values
    flags_check(argc, argv, &onic_name, &remote_server_name, &index);

    // Continue with the rest of your program logic using onic_name, remote_server_name, and index
    int num_pings = read_parameter(index, "NUM_PINGS");
    if (num_pings == -1) {
        return 1;
    }

    ping(onic_name, remote_server_name, num_pings);

    return 0;
}