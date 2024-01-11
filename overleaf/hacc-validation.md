# HACC validation

The following are guided experiments (utilizing *sgutil validate commands*) designed to assist you in **validating both ETHZ-HACC infrastructure and platform.** These experiments serve a dual purpose: firstly, they establish a performance baseline that should consistently be achieved when utilizing ETHZ-HACC (if not, please inform us). Secondly, they function as a reference for using SGRT on your own cluster, enabling you to accurately reproduce the same behavior observed in the HACC.

![ETHZ-HACC infrastructure and platform.](./hacc-validation.png "ETHZ-HACC infrastructure and platform.")

## HACC Platform validation

* [RDMA stack validation](./hacc-validation/sgutil-validate-coyote-perf_rdma_host.md)

## Infrastructure validation

* **Networking validation with iperf**
* **Message passing interface validation with mpich**
