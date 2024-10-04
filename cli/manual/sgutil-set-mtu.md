<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-set.md#sgutil-set">Back to sgutil set</a>
</p>

## sgutil set mtu

<code>sgutil set mtu [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Sets a valid MTU value to a device.
</p>

### Flags
<code>-i, --interface <string></code>
<p>
  &nbsp; &nbsp; Interface name (according to ifconfig).
</p>

<code>-v, --value <string></code>
<p>
  &nbsp; &nbsp; Maximum Transmission Unit (MTU) value (in bytes).
</p>

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to use this command.
</p>

### Examples
```
$ sgutil set mtu -v 4200
```