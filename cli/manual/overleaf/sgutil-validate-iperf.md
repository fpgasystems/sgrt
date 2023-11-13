Back to sgutil validate


## sgutil validate iperf

sgutil validate iperf [flags] [--help]

  &nbsp; &nbsp; Measures HACC network performance. 



### Flags
-b, --bandwidth 

  &nbsp; &nbsp; Bandwidth to send at in bits/sec or packets per second.

-p, --parallel 

  &nbsp; &nbsp; Number of parallel client threads to run.

-t, --time 

  &nbsp; &nbsp; Time in seconds to transmit for.

-u, --udp 

  &nbsp; &nbsp; Use UDP rather than TCP.


-h, --help 

  &nbsp; &nbsp; Help to use iperf validation.


### Examples
* **$ sgutil validate iperf**
* **$ sgutil validate iperf -p 6**
* **$ sgutil validate iperf -b 900M -u**
