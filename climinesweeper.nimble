# Package

version       = "1.2.1"
author        = "kerorinnf"
description   = "Play MineSweeper on CLI"
license       = "MIT"
srcDir        = "src"
bin           = @["climinesweeper"]


# Dependencies

requires "nim >= 1.6.8"
requires "illwill >= 0.3.0"
requires "jsony >= 1.1.5"

import os, strformat

task dist, "Create zip for release":
  let
    app = "climinesweeper"
    zip = &"{app}_for_{buildOS}"
    dir = zip
    bin = dir / "bin"
    srcApp = "src" / app

  mkdir(bin)
  cpFile("LICENSE", dir/"LICENSE")
  cpFile("README.md", dir/"README.md")
  exec &"nim c -d:release --opt:size {srcApp}.nim"
  when buildOS == "windows":
    discard
  else:
    exec &"mv {srcApp} {bin}"
    exec &"tar czf {zip}.tar.gz {dir}"
    rmDir(dir)