#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "onic.h"

void ping(const char *onic_name, const char *remote_server_name, int num_pings) {
    char command[256];
    snprintf(command, sizeof(command), "ping -I %s -c %d %s", onic_name, num_pings, remote_server_name);
    printf("Executing command: %s\n", command);
    int result = system(command);
    if (result != 0) {
        printf("Ping command failed with exit code %d\n", result);
    }
}

int read_parameter(int index, const char *parameter_name) {
    char config_file_path[256];
    snprintf(config_file_path, sizeof(config_file_path), "./configs/host_config_%03d", index);

    FILE *file = fopen(config_file_path, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: Could not open config file %s\n", config_file_path);
        return -1;
    }

    char line[256];
    int value = -1;

    while (fgets(line, sizeof(line), file)) {
        char key[256];
        int temp_value;

        // Use sscanf to parse lines in the form of "KEY = VALUE"
        if (sscanf(line, "%255[^=] = %d", key, &temp_value) == 2) {
            // Trim any leading or trailing whitespace from key
            char *trimmed_key = key;
            while (*trimmed_key == ' ' || *trimmed_key == '\t') {
                trimmed_key++;
            }
            char *end = trimmed_key + strlen(trimmed_key) - 1;
            while (end > trimmed_key && (*end == ' ' || *end == '\t')) {
                *end = '\0';
                end--;
            }

            if (strcmp(trimmed_key, parameter_name) == 0) {
                value = temp_value;
                break;
            }
        }
    }

    fclose(file);

    if (value == -1) {
        fprintf(stderr, "Error: Parameter %s not found in config file %s\n", parameter_name, config_file_path);
    }

    return value;
}
