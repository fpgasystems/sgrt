<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-validate.md#sg-validate">Back to sgutil validate</a>
</p>

## sgutil validate opennic

<code>sgutil validate opennic [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Validates OpenNIC on the selected FPGA.
</p>

### Flags
<code>-c, --commit <string></code>
<p>
  &nbsp; &nbsp; GitHub commit IDs for shell and driver
</p>

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
$ sgutil validate opennic
$ sgutil validate opennic -d 1
```