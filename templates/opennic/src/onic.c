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

char* get_interface_name(char *device_ip) {
    char command[256];
    snprintf(command, sizeof(command), "ifconfig");

    FILE *fp = popen(command, "r");
    if (fp == NULL) {
        fprintf(stderr, "Error: Failed to run ifconfig command\n");
        return NULL;
    }

    static char interface_name[256];
    char line[256];
    char current_interface[256] = "";  // Store the current interface name
    int ip_found = 0;  // Flag to track if the IP is found

    // Read through the ifconfig output line by line
    while (fgets(line, sizeof(line), fp) != NULL) {
        // Look for lines that define the interface name (these start without leading spaces)
        if (line[0] != ' ') {
            // Capture the interface name and remove any trailing colon
            sscanf(line, "%s", current_interface);
            char *colon_ptr = strchr(current_interface, ':');
            if (colon_ptr != NULL) {
                *colon_ptr = '\0';  // Remove the colon
            }
        }

        // Look for the device_ip in subsequent lines
        if (strstr(line, device_ip) != NULL) {
            // If we find the IP, set the flag and break out of the loop
            ip_found = 1;
            strncpy(interface_name, current_interface, sizeof(interface_name) - 1);
            interface_name[sizeof(interface_name) - 1] = '\0';  // Ensure null-termination
            break;
        }
    }

    pclose(fp);

    // If the IP wasn't found, report an error
    if (!ip_found) {
        fprintf(stderr, "Error: No interface found for IP %s.\n", device_ip);
        return NULL;
    }

    return interface_name;
}

char* get_network(int device_index, int port_number) {
    char command[256];
    snprintf(command, sizeof(command), "sgutil get network --device %d --port %d", device_index, port_number);

    // Open a pipe to the command and read the output
    FILE *fp = popen(command, "r");
    if (fp == NULL) {
        fprintf(stderr, "Error: Failed to run command '%s'\n", command);
        return NULL;
    }

    static char result[256];
    result[0] = '\0'; // Initialize the result as an empty string

    char line[256];
    while (fgets(line, sizeof(line), fp) != NULL) {
        // Look for lines that contain an IP address
        char *ip_start = strstr(line, " ");
        if (ip_start != NULL) {
            ip_start += 1; // Skip the space character
            char *ip_end = strchr(ip_start, ' ');
            if (ip_end != NULL) {
                *ip_end = '\0'; // Null-terminate the IP address
                strncpy(result, ip_start, sizeof(result) - 1);
                result[sizeof(result) - 1] = '\0'; // Ensure null-termination
                break; // Exit after finding the first IP address
            }
        }
    }

    // Close the pipe
    pclose(fp);

    // Check if result is still empty (no IP found)
    if (result[0] == '\0') {
        fprintf(stderr, "Error: No valid IP address found in command output.\n");
        return NULL;
    }

    return result;
}

void ping(const char *onic_name, const char *remote_server_name, int num_pings) {
    char command[256];
    snprintf(command, sizeof(command), "ping -I %s -c %d %s", onic_name, num_pings, remote_server_name);
    printf("%s\n", command);
    printf("\n");
    int result = system(command);
    if (result != 0) {
        printf("Ping command failed with exit code %d\n", result);
    }
}

char* read_parameter(int index, const char *parameter_name) {
    char config_file_path[256];
    
    if (index == 0) {
        snprintf(config_file_path, sizeof(config_file_path), "./.device_config");
    } else {
        snprintf(config_file_path, sizeof(config_file_path), "./configs/host_config_%03d", index);
    }

    FILE *file = fopen(config_file_path, "r");
    if (file == NULL) {
        fprintf(stderr, "Error: Could not open config file %s\n", config_file_path);
        return NULL;
    }

    static char value[256]; // static to persist after function returns
    char line[256];

    while (fgets(line, sizeof(line), file)) {
        char key[256];
        char temp_value[256];

        // Use sscanf to parse lines in the form of "KEY = VALUE;"
        if (sscanf(line, "%255[^=] = %255[^;];", key, temp_value) == 2) {
            // Trim leading and trailing whitespace from key
            char *trimmed_key = key;
            while (*trimmed_key == ' ' || *trimmed_key == '\t') {
                trimmed_key++;
            }
            char *end = trimmed_key + strlen(trimmed_key) - 1;
            while (end > trimmed_key && (*end == ' ' || *end == '\t')) {
                *end = '\0';
                end--;
            }

            // Check if key matches the requested parameter
            if (strcmp(trimmed_key, parameter_name) == 0) {
                // Copy the value found to the result
                strncpy(value, temp_value, sizeof(value) - 1);
                value[sizeof(value) - 1] = '\0';  // Ensure null-termination
                fclose(file);
                return value;
            }
        }
    }

    fclose(file);
    fprintf(stderr, "Error: Parameter %s not found in config file %s\n", parameter_name, config_file_path);
    return NULL;
}

/* int read_parameter(int index, const char *parameter_name) {
    char config_file_path[256];

    if (index == 0) {
        snprintf(config_file_path, sizeof(config_file_path), "./.device_config");
    } else {
        snprintf(config_file_path, sizeof(config_file_path), "./configs/host_config_%03d", index);
    }

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
} */