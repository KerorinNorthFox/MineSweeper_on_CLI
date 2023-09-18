# CLI MineSweeper
Play Minesweeper on CLI.

# Installation
```bash
$ nimble install climinesweeper
```

# Usage
```bash
$ climinesweeper [Options]
```
```
Options:
  -h, --help             display the help.
  -v, --version          display the version.
  --noColor              play without colors.
  --continue [number]    play with a set number of continue.
  --infinite             play without Boom!!.
  [5 <= number <= 20]    Set the number of vert and hor cells and start the game.
  None                   Set the min number (5) of vert and hor cells and start the game.
```

# Requirement
- nim >= 1.6.8
- illwill >= 0.3.0
- jsony >= 1.1.5

