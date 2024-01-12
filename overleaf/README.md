 -->

fpgasystems HACC HACC Platform







  Systems Group RunTime
 

While initially developed for ETHZ-**HACC,** the **Systems Group RunTime (SGRT)** is a versatile RunTime software ready to be used on any AMD-compatible heterogeneous cluster. 

<!-- SGRT comprises a command-line interpreter (CLI) and an API. Whereas the **CLI** streamlines the development of accelerated applications, allowing you to concentrate on your primary objectives.
SGRT comprises a command-line interpreter (CLI) and an API, both leveraging an intuitive device index to enhance user workflow. The CLI simplifies infrastructure setup and validation and device configuration, while the API streamlines the development of accelerated applications, enabling users to focus on their primary objectives. -->

SGRT includes a command-line interpreter (CLI) and an API, both utilizing an intuitive device index to improve user workflow. The **CLI**PI streamlines accelerated application development, allowing users to focus on their primary objectives.

## Sections
* **API**
* **CLI**
* **Citation**
* **Developers guide**
* **Disclaimer**
* **Features**
* **HACC validation**
* **Installation**
* **License**
* **Known limitations**
* **Programming model**

# Releases



  
    SGRT
    Xilinx Tools Release
    HIP Release
  
  
    2022.1
    2022.2
    5.4.1
    5.4.3
  


  
    2022.1_5.4.3
    &#9679;
    
    
    &#9679;
  
  
    2022.2_5.4.3
    
    &#9679;
    
    &#9679;
  

&#9675; Existing release.
&#9679; Existing release installed on the cluster.


<!-- # Limitations
* SGRT has only been tested on **Ubuntu 20.04.6 LTS.**
* For deployment servers with reconfigurable devices, it's imperative to maintain a single version of the Xilinx toolset (comprising XRT, Vivado, and Vitis_HLS) on the system. Multiple versions of these tools should not coexist to ensure proper operation.
* For deployment servers with GPUs, only one version of HIP/ROCm should be installed. -->

# Disclaimer

* The Systems Group RunTime (SGRT) software is provided "as is" and without warranty of any kind, express or implied. The authors and maintainers of this repository make no claims regarding the fitness of this software for specific purposes or its compatibility with any particular hardware or software environment.
* SGRT users are responsible for assessing its suitability for their intended use, including compatibility with their high-performance computing clusters and heterogeneous environments. The authors and maintainers of SGRT assume no liability for any issues, damages, or losses arising from the use of this software.
* It is recommended to thoroughly test SGRT in a controlled environment before deploying it in a production setting. Any issues or feedback should be reported to the repository's issue tracker.
* By using SGRT, you acknowledge and accept the terms and conditions outlined in this disclaimer.

# Citation

**![DOI**](https://doi.org/10.5281/zenodo.8346565)

If you use this repository in your work, we kindly request that you cite it as follows:

* **@misc{moya2023sgrt,**
* **  author       = {Javier Moya and Gustavo Alonso},**
* **  title        = {fpgasystems/sgrt: ETHZ-SGRT 2022.2.5.4.3},**
* **  howpublished = {Zenodo},**
* **  year         = {2023},**
* **  month        = sep,**
* **  note         = {\url{https://doi.org/10.5281/zenodo.10075311}},**
* **  doi          = {10.5281/zenodo.8346565}**
* **}**

# License

**![License: MIT**](https://opensource.org/licenses/MIT)

Copyright (c) 2023 FPGA @ Systems Group, ETH Zurich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
