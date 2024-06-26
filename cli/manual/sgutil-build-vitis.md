<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-build.md#sgutil-build">Back to sgutil build</a>
</p>

## sgutil build vitis

<code>sgutil build vitis [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Uses acap_fpga_xclbin to generate XCLBIN binaries for Vitis workflow.
</p>

### Flags
<code>    --project</code>
<p>
  &nbsp; &nbsp; Specifies your Vitis project name.
</p>

<code>-t, --target</code>
<p>
  &nbsp; &nbsp; Binary compilation target (host, sw_emu, hw_emu, hw).
</p>

<!-- <code>-x, --xclbin</code>
<p>
  &nbsp; &nbsp; The name of the XCLBIN to be compiled.
</p> -->

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to build a binary.
</p>

### Examples
```
$ sgutil build vitis
$ sgutil build vitis --project hello_world -t sw_emu
```