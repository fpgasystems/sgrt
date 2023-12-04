<div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">
<p align="right">
<a href="https://github.com/fpgasystems/sgrt/blob/main/cli/manual/sgutil-program.md#sgutil-program">Back to sgutil program</a>
</p>

## sgutil program driver

<code>sgutil program driver [flags] [--help]</code>
<p>
  &nbsp; &nbsp; Inserts a driver or module into the Linux kernel.
</p>

### Flags
<code>-m, --module <string></code>
<p>
  &nbsp; &nbsp; Full path to the .ko module to be inserted.
</p>

<code>-p, --params <string></code>
<p>
  &nbsp; &nbsp; A comma separated list of module parameters.
</p>

<code>-h, --help <string></code>
<p>
  &nbsp; &nbsp; Help to use this command.
</p>

### Examples
```
$ sgutil program driver -m my_driver.ko
$ sgutil program driver -m my_driver.ko -p ip_addr_q0=0AFD4A7A,mac_addr_q0=000A350F5D28
```