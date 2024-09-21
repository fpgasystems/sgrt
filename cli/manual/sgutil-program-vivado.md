<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-program.md#sgutil-program">Back to sgutil program</a>
</p>

## sgutil program vivado

<code>sgutil program vivado [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Programs a Vivado bitstream to a given device.
</p>

### Flags
<code>-b, --bitstream <string></code>
<p>
  &nbsp; &nbsp; Full path to the .bit bitstream to be programmed.
</p>

<code>-d, --device <string></code>
<p>
  &nbsp; &nbsp; Device Index (according to sgutil examine).
</p>

<!-- <code>    --driver <string></code>
<p>
  &nbsp; &nbsp; Driver (.ko) file path.
</p> -->

<!-- <code>-l, --ltx <string></code>
<p>
  &nbsp; &nbsp; Specifies a .ltx debug probes file.
</p>

<code>-n, --name <string></code>
<p>
  &nbsp; &nbsp; FPGA's device name. See <a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-get-device.md">sgutil get device</a>.
</p>

<code>-s, --serial <string></code>
<p>
  &nbsp; &nbsp; FPGA's serial number. See <a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-get-serial.md">sgutil get serial</a>.
</p> -->

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to program a bitstream.
</p>

### Examples
```
$ sgutil program vivado --bitstream my_bitstream.bit 
$ sgutil program vivado --bitstream my_bitstream.bit --device 1 
```