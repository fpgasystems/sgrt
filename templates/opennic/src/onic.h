#ifndef ONIC_H
#define ONIC_H

void flags_check(int argc, char *argv[], char **onic_name, char **remote_server_name, int *index);
char* get_interface_name(char *device_ip);
char* get_network(int device_index, int port_number);
void ping(const char *onic_name, const char *remote_server_name, int num_pings);
char* read_parameter(int index, const char *parameter_name);

#endif