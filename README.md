<!-- <div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text"> -->
<p align="right">
<a href="https://github.com/fpgasystems">fpgasystems</a> <a href="https://github.com/fpgasystems/hacc">HACC</a>
</p>

<p align="center">
<img src="https://github.com/fpgasystems/sgrt/blob/main/sgrt-removebg.png" align="center" width="350">
</p>

<h1 align="center">
  Systems Group RunTime
</h1> 

**SGRT (Systems Group RunTime)** is a RunTime software developed specifically for ETHZ-[HACC](https://github.com/fpgasystems/hacc) servers. It consists of a command-line interpreter (CLI) and an API. The [CLI](./cli/manual.md#cli) enables you to easily set up your infrastructure and configure devices using a straightforward device index. Meanwhile, the [API](./api/manual.md) streamlines the development process of your accelerated applications, allowing you to concentrate on what truly matters.

## Sections
* [API](./api/manual.md#api)
* [CLI](./cli/manual.md#cli)
* [Examples](./examples.md#examples)
* [Features](./features.md#features)
* [Installation](https://github.com/fpgasystems/sgrt_install#--systems-group-runtime-installation)
* [Disclaimer](#disclaimer)
* [License](#license)

# Releases

<table class="tg">
<thead>
  <tr style="text-align:center">
    <th class="tg-0pky" rowspan="2"><div align="center">SGRT</div></th>
    <th class="tg-0pky" colspan="2" style="text-align:center"><div align="center">Xilinx Tools Release</div></th>
    <th class="tg-0pky" colspan="2" style="text-align:center"><div align="center">HIP Release</div></th>
  </tr>
  <tr>
    <th class="tg-0pky" style="text-align:center">2022.1</th>
    <th class="tg-0pky" style="text-align:center">2022.2</th>
    <th class="tg-0pky" style="text-align:center">5.4.1</th>
    <th class="tg-0pky" style="text-align:center">5.4.3</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td class="tg-0pky"><div align="center">2022.2_5.4.3</div></td>
    <td class="tg-0pky" align="center"></td>
    <td class="tg-0pky" align="center">&#9679;</td>
    <td class="tg-0pky" align="center"></td>
    <td class="tg-0pky" align="center">&#9679;</td>
  </tr>
</tbody>
<tfoot><tr><td colspan="5">&#9675; Existing release.</td></tr></tfoot>
<tfoot><tr><td colspan="5">&#9679; Existing release installed on the cluster.</td></tr></tfoot>
</table>

# Disclaimer
SGRT might be used in other HACCs or other heterogeneous clusters compatible with AMD accelerator devices.

# License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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