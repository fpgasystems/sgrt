#ifndef ONIC_H
#define ONIC_H

void ping(const char *onic_name, const char *remote_server_name, int num_pings);
int read_parameter(int index, const char *parameter_name);

#endif /* ONIC_H */

