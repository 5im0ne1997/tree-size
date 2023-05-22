# Treesize for Linux

This tool allows you to generate a report listing all directories in order of size.

# Usage

It is necessary (but not mandatory) to run the script as an administrator.

./treesize.sh [OPTION] [DIRECTORY]

| **Options** | **Description** |
| ----------- | --------------- |
| -i | Include directory, default /|
| -d | Depth |

# Example

./treesize.sh -i /data /var/log /tmp -d 2


