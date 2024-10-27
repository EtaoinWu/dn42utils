# Babeld Docker Container

This repository provides a container setup for running a `babeld` server. Babeld is a loop-avoiding distance-vector routing protocol for IPv6 and IPv4 networks.

## Usage

By default the container fetches the configuration file from `/data/babeld.conf` and puts its state in `/data/babel-state`. We recommend mounting `/data` to a volume on the host.

```bash
docker run -d -v /path/to/babeld_data:/data --network host --cap-add=NET_ADMIN etaoinwu/babeld
# OR, if you want to run it in an existing network namespace
podman run -d -v /path/to/babeld_data/:/data/ --network ns:/var/run/netns/ns42 etaoinwu/babeld
```

You will need to either use `--privileged`, or have `skip-kernel-setup true` in your configuration file; if you do so you also need to manually set these `sysctl` entries on the host:

```
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv6.conf.all.accept_redirects = 0
```

### Environment Variables

The following environment variables are supported.

| Environment Variable                            | Default Value                                            | Flag | Description                                                                   |
| ----------------------------------------------- | -------------------------------------------------------- | ---- | ----------------------------------------------------------------------------- |
| `BABELD_INTERFACES`                             | `eth0`                                                   |      | Interfaces on which Babeld operates. Can be a space-separated array           |
| `BABELD_CONFIG_FILE`                            | `/data/babeld.conf`                                      | `-c` | Path to the Babeld configuration file                                         |
| `BABELD_MULTICAST_ADDRESS`                      | `ff02:0:0:0:0:0:1:6`                                     | `-m` | Link-local multicast address for the protocol                                 |
| `BABELD_PORT`                                   | `6696`                                                   | `-p` | UDP port number used by the protocol                                          |
| `BABELD_STATIC_FILE`                            | `/data/babel-state`                                      | `-S` | File for preserving long-term state                                           |
| `BABELD_HELLO_INTERVAL_WIRELESS`                | `4`                                                      | `-h` | Interval (seconds) for hello packets on wireless interfaces                   |
| `BABELD_HELLO_INTERVAL_WIRED`                   | `4`                                                      | `-H` | Interval (seconds) for hello packets on wired interfaces                      |
| `BABELD_HALF_TIME`                              | `4`                                                      | `-M` | Half-time for metric smoothing in route selection                             |
| `BABELD_KERNEL_ROUTE_PRIORITY`                  | `0`                                                      | `-k` | Priority for kernel-installed routes                                          |
| `BABELD_EXTERNAL_PRIORITY_THRESHOLD`            | Not specified                                            | `-A` | Threshold for duplicating external routes based on kernel priority            |
| `BABELD_IFF_RUNNING`                            | Unset                                                    | `-l` | Use IFF_RUNNING (carrier sense) for interface availability                    |
| `BABELD_ASSUME_ALL_WIRELESS`                    | Unset                                                    | `-w` | Assume all interfaces are wireless                                            |
| `BABELD_DISABLE_SPLIT_HORIZON_PROCESSING_WIRED` | Unset                                                    | `-s` | Disable split-horizon processing on wired interfaces                          |
| `BABELD_RANDOMIZE_ROUTER_ID`                    | Unset                                                    | `-r` | Use a random router ID                                                        |
| `BABELD_NO_FLUSH_UNFEASIBLE_ROUTE`              | Unset                                                    | `-u` | Do not flush unfeasible (useless) routes                                      |
| `BABELD_DEBUG_LEVEL`                            | `0`                                                      | `-d` | Debug level: 1 for routing table dumps, 2 for message tracing, 3 for all      |
| `BABELD_LOCAL_CONFIG_SERVER_RO`                 | Not specified                                            | `-g` | Port or path for local configuration server in read-only mode                 |
| `BABELD_LOCAL_CONFIG_SERVER_RW`                 | Not specified                                            | `-G` | Port or path for local configuration server in read-write mode                |
| `BABELD_INSERT_TO_TABLE`                        | Not specified                                            | `-t` | Kernel routing table to insert routes                                         |
| `BABELD_EXPORT_FROM_TABLES`                     | Not specified                                            | `-T` | Kernel routing table(s) from which Babeld exports routes. Can be a JSON array |
| `BABELD_CONFIG_VERBATIM`                        | Not specified                                            | `-C` | Configuration statement(s) directly on the command line. Can be a JSON array  |
| `BABELD_DEMONISE`                               | Unset                                                    | `-D` | Run as a daemon                                                               |
| `BABELD_LOGFILE`                                | `/var/log/babeld.log` if `-D` is set, `stderr` otherwise | `-L` | Log file path                                                                 |
| `BABELD_PID_FILE`                               | `/var/run/babeld.pid`                                    | `-I` | File to store Babeld process ID                                               |

Refer to babeld's [documentation](https://www.irif.fr/~jch/software/babel/babeld.html) for more information on these options.

## Notes

1. **Binary Options**: These options are set if the environment variable is defined and not equal to `false` or `0`.
2. **List Options**: For `BABELD_EXPORT_FROM_TABLES` and `BABELD_CONFIG_VERBATIM`, you can set it to either be a single entry (e.g. `table1`) or a JSON array (e.g. `[ "table1", "table2" ]`). JSON arrays must start with `[` and end with `]`.
