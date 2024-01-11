<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/tree/main#--systems-group-runtime">Back to top</a>
</p>

# HACC validation

The following are guided experiments (utilizing *sgutil validate commands*) designed to assist you in **validating the infrastructure for ETHZ-HACC.** These experiments serve a dual purpose: firstly, they establish a performance baseline that should consistently be achieved when utilizing ETHZ-HACC (if not, please inform us). Secondly, they function as a reference for using SGRT on your own cluster, enabling you to accurately reproduce the same behavior observed in the HACC.

## Coyote validation

* [RDMA stack validation](./hacc-validation/sgutil-validate-coyote-perf_rdma_host.md)

## Infrastructure validation

* [Networking validation with iperf](./hacc-validation/sgutil-validate-iperf.md#networking-validation-with-iperf)
* [Message passing interface validation with mpich](./hacc-validation/sgutil-validate-mpi.md#message-passing-interface-validation-with-mpich)