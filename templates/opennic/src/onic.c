#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "onic.h"

// Define valid flags
const char *valid_flags[] = {"-d", "--device", "-h", "--host", "-c", "--config"};
#define NUM_FLAGS (sizeof(valid_flags) / sizeof(valid_flags[0]))

void flags_check(int argc, char *argv[], char **onic_name, char **remote_server_name, int *index) {
    if (argc != 7) {  // 6 args + program name
        fprintf(stderr, "Error: Incorrect number of arguments.\n");
        fprintf(stderr, "Usage: %s --device <onic_name> --host <remote_server_name> --config <index>\n", argv[0]);
        exit(1);
    }

    for (int i = 1; i < argc; i += 2) {
        int valid = 0;
        for (int j = 0; j < NUM_FLAGS; j++) {
            if (strcmp(argv[i], valid_flags[j]) == 0) {
                valid = 1;
                break;
            }
        }

        if (!valid) {
            fprintf(stderr, "Error: Invalid flag %s\n", argv[i]);
            exit(1);
        }

        if (i + 1 >= argc) {
            fprintf(stderr, "Error: Flag %s must be followed by a value.\n", argv[i]);
            exit(1);
        }

        if (strcmp(argv[i], "-d") == 0 || strcmp(argv[i], "--device") == 0) {
            *onic_name = argv[i + 1];
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--host") == 0) {
            *remote_server_name = argv[i + 1];
        } else if (strcmp(argv[i], "-c") == 0 || strcmp(argv[i], "--config") == 0) {
            *index = atoi(argv[i + 1]);
            if (*index <= 0) {
                fprintf(stderr, "Error: Invalid config index %s\n", argv[i + 1]);
                exit(1);
            }
        }
    }

    // Ensure all necessary parameters were provided
    if (*onic_name == NULL || *remote_server_name == NULL || *index == 0) {
        fprintf(stderr, "Error: Missing required parameters.\n");
        fprintf(stderr, "Usage: %s --device <onic_name> --host <remote_server_name> --config <index>\n", argv[0]);
        exit(1);
    }
}

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