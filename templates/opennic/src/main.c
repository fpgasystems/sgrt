#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    char *onic_name = NULL;
    char *remote_server_name = NULL;
    int index = 0;

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