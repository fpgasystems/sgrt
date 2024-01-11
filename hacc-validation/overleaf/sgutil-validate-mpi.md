

## Message passing interface validation with mpich
In this experiment, we are using CLI’s **`sgutil validate mpi`** command to verify MPI message-passing standard on the ETHZ-HACC network. In order to run this experiment, **you should be sure to have the capability to SSH into the remote server from your local server.** Assuming that alveo-u55c-01 is your local server and alveo-u55c-02 is one of your remote servers, you should be able to run the following command:

* **alveo-u55c-01:~$ ssh alveo-u55c-02**

### Experiment
1. Use the **booking system** to reserve the servers you wish to validate,
2. Login to the server you want to set as the MPI server—all others will be the clients for the experiment,
3. Run **sgutil validate mpi** and wait for the results.

![Message passing interface validation with mpich.](./sgutil-validate-mpi.png "Message passing interface validation with mpich.")

### Results
In this experiment, we have reserved five servers (alveo-u55c-01 to alveo-u55c-05) where alveo-u55c-01 is the local instance connecting to the remotes. **Please, remember that** **sgutil validate mpi** **sets -n (the number of processes to use) to two.** This means that each remote server will execute two copies of the compiled *hello_world.c* MPI program—so the local server receives results from a total of eight processors:

![CLI command (left), hosts file and MPI call (middle), and results (right).](./sgutil-validate-mpi-results.png "CLI command (left), hosts file and MPI call (middle), and results (right).")

### Background materials

The following is the source code of the MPI program *hello_world.c* which is compiled on the local server: 

```c
#include 
#include 

int main(int argc, char** argv) {
	MPI_Init(NULL, NULL);      // initialize MPI environment
	int world_size; // number of processes
	MPI_Comm_size(MPI_COMM_WORLD, &world_size);

	int world_rank; // the rank of the process
	MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

	char processor_name[MPI_MAX_PROCESSOR_NAME]; // gets the name of the processor
	int name_len;
	MPI_Get_processor_name(processor_name, &name_len);

	printf("Hello world from processor %s, rank %d out of %d processors\n", processor_name, world_rank, world_size);

	MPI_Finalize(); // finish MPI environment
}
* ****
* **Such a program is executed on the remote servers specified on the *hosts file:***
* ****
alveo-u55c-02-mellanox-0:2
alveo-u55c-03-mellanox-0:2
alveo-u55c-04-mellanox-0:2
alveo-u55c-05-mellanox-0:2
