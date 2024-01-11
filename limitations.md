<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/tree/main#--systems-group-runtime">Back to top</a>
</p>

# Limitations

* SGRT has only been tested on **Ubuntu 20.04.6 LTS.**
* For deployment servers with reconfigurable devices, **it's imperative to maintain a single version of the Xilinx toolset** (comprising XRT, Vivado, and Vitis_HLS) on the system. Multiple versions of these tools should not coexist to ensure proper operation.
* For deployment servers with GPUs, **only one version of HIP/ROCm should be installed.**