<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-get.md#sgutil-get">Back to sgutil get</a>
</p>

## sgutil get serial

<code>sgutil get serial [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Retreives FPGA/ACAP serial numbers.
</p>

### Flags
<code>-d, --device <string></code>
<p>
  &nbsp; &nbsp; FPGA/ACAP Device Index (according to sgutil examine).
</p>

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to use this command.
</p>

### Examples
```
$ sgutil get serial -d 1
```