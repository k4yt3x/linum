# Linum

Linum is yet another Linux enumeration script written in shell script.

## Description

Linum invokes Linux built-in commands and queries configuration files and log files to collect all kinds of information about the system.

## Usages

It's the best to run this script with root access since certain information can only be collected as root (e.g., `/etc/shadow` file content).

```shell
usage: linum.sh
    -h, --help	show this help message and exit
    -v, --verbose	include verbose information (extra iptables tables, full packages list)
```

### Example

```shell
curl -sSL https://raw.githubusercontent.com/k4yt3x/linum/master/src/linum.sh | bash
```

## Screenshots

![image](https://user-images.githubusercontent.com/21986859/93413112-0d46a700-f88e-11ea-8c6f-48f2dbddf59d.png)

## License

Licensed under the GNU General Public License Version 3 (GNU GPL v3)
https://www.gnu.org/licenses/gpl-3.0.txt

![GPLv3 Icon](https://www.gnu.org/graphics/gplv3-127x51.png)

(C) 2020 K4YT3X
