#include <stdio.h>
#include <stdlib.h>
#include "onic.h"

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <onic_name> <remote_server_name> <index>\n", argv[0]);
        return 1;
    }

    const char *onic_name = argv[1];
    const char *remote_server_name = argv[2];
    int index = atoi(argv[3]);

    int num_pings = read_parameter(index, "NUM_PINGS");
    if (num_pings == -1) {
        return 1;
    }

    ping(onic_name, remote_server_name, num_pings);
    return 0;
}