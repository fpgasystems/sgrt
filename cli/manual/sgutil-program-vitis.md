<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-program.md#sgutil-program">Back to sgutil program</a>
</p>

## sgutil program vitis

<code>sgutil program vitis [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Programs a Vitis binary to a given FPGA.
</p>

### Flags
<code>-d, --device <string></code>
<p>
  &nbsp; &nbsp; Device Index (according to sgutil examine).
</p>

<code>-p, --project <string></code>
<p>
  &nbsp; &nbsp; Specifies your Vitis project name.
</p>

<code>-r, --remote <string></code>
<p>
  &nbsp; &nbsp; Local or remote deployment.
</p>

<code>-x, --xclbin <string></code>
<p>
  &nbsp; &nbsp; Vitis binary name to be programmed on the device.
</p>

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to program a binary.
</p>

### Examples
```
$ sgutil program vitis
```