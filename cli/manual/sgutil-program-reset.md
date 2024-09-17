<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-program.md#sgutil-program">Back to sgutil program</a>
</p>

## sgutil program reset

<code>sgutil program reset [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Performs a 'HOT Reset' on a Vitis device.
</p>

### Flags
<code>-d, --device <string></code>
<p>
  &nbsp; &nbsp; FPGA Device Index (see sgutil examine).
</p>

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to use this command.
</p>

### Examples
```
$ sgutil program reset -d 1
```