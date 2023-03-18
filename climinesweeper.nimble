# Package

version       = "1.1.0"
author        = "kerorinnf"
description   = "Play MineSweeper on CLI"
license       = "MIT"
srcDir        = "src"
bin           = @["climinesweeper"]
binDir        = "bin"
skipDir       = "src/pkg/"


# Dependencies

requires "nim >= 1.6.8"
requires "illwill >= 0.3.0"
