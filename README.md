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

While initially developed for ETHZ-[HACC,](https://github.com/fpgasystems/hacc) the **Systems Group RunTime (SGRT)** is a versatile RunTime software ready to be used on any AMD-compatible heterogeneous cluster. 

SGRT comprises a command-line interpreter (CLI) and an API. Whereas the [CLI](./cli/manual.md#cli) simplifies infrastructure setup and device configuration through an intuitive device index, the [API](./api/manual.md) streamlines the development of accelerated applications, allowing you to concentrate on your primary objectives.

## Sections
* [API](./api/manual.md#api)
* [CLI](./cli/manual.md#cli)
* [Citation](#citation)
* [Disclaimer](#disclaimer)
* [Examples](./examples.md#examples)
* [Features](./features.md#features)
* [Installation](https://github.com/fpgasystems/sgrt_install#--systems-group-runtime-installation)
* [License](#license)
* [Programming model](./programming-model.md#programming-model)

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
    <td class="tg-0pky"><div align="center">2022.1_5.4.3</div></td>
    <td class="tg-0pky" align="center">&#9679;</td>
    <td class="tg-0pky" align="center"></td>
    <td class="tg-0pky" align="center"></td>
    <td class="tg-0pky" align="center">&#9679;</td>
  </tr>
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

* The Systems Group RunTime (SGRT) software is provided "as is" and without warranty of any kind, express or implied. The authors and maintainers of this repository make no claims regarding the fitness of this software for specific purposes or its compatibility with any particular hardware or software environment.
* SGRT users are responsible for assessing its suitability for their intended use, including compatibility with their high-performance computing clusters and heterogeneous environments. The authors and maintainers of SGRT assume no liability for any issues, damages, or losses arising from the use of this software.
* It is recommended to thoroughly test SGRT in a controlled environment before deploying it in a production setting. Any issues or feedback should be reported to the repository's issue tracker.
* By using SGRT, you acknowledge and accept the terms and conditions outlined in this disclaimer.

# Citation

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10075311.svg)](https://doi.org/10.5281/zenodo.10075311)

If you use this repository in your work, we kindly request that you cite it as follows:

```
@misc{moya2023sgrt,
  author       = {Javier Moya and Gustavo Alonso},
  title        = {fpgasystems/sgrt: ETHZ-SGRT 2022.2.5.4.3},
  howpublished = {Zenodo},
  year         = {2023},
  month        = sep,
  note         = {\url{https://doi.org/10.5281/zenodo.10075311}},
  doi          = {10.5281/zenodo.10075311}
}
```

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