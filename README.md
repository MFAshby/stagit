# stagit

This repository contains Zig build system files for compiling [stagit](https://codemadness.org/stagit.html).

## Usage

You need Zig version 0.13.0

To compile:
```shell
zig build -Doptimize=ReleaseSafe
```

Files to be installed are output into zig-out directory.