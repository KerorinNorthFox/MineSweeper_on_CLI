import
  illwill,
  std/os,
  std/strutils,
  std/strformat,
  ./pkg/minesweeper

const
  HELP: string = """description:
  Play Minesweeper on CLI.
usage:
  ./CLIMineSweeper [--version] [--help] [--noColor] <number>
options:
  -h, --help             display the help.
  -v, --version          display the version.
  --noColor              play without colors.
  --continue [number]    play with a set number of continue.
  --infinite             play without Boom!!.
  [5 <= number <= 20]    Set the number of vert and hor cells and start the game.
  None                   Set the min number (5) of vert and hor cells and start the game.

"""
  GAME_VERSION: string = &"MineSweeper on CLI Version {VERSION}\n"
  MIN_BLOCK: int = 5 # 最大ブロック数
  MAX_BLOCK: int = 20 # 最小ブロック数

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc main(blc:int, defaultContinue: int, isInfinity:bool, isNoColor:bool): void =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()
  # illwillの画面作成
  var tb: TerminalBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())
  # minesweeper初期化
  var game: MineSweeper = MineSweeper.init(tb, blc, defaultContinue, isInfinity, isNoColor)

  game.start()
  while(true):
    let isEnd: bool = game.update()
    if isEnd:
      exitProc()

when isMainModule:
  let args = commandLineParams()

  var
    isSkip: bool = false
    isQuit: bool = false
    isNoColor: bool = false
    defaultContinue: int = 3
    isInfinity: bool = false
    defaultBlc: int = 5
  for i, arg in args:
    if isSkip:
      isSkip = false
      continue
    try:
      case arg
      of "-h", "--help": echo HELP; isQuit = true
      of "-v", "--version": echo GAME_VERSION; isQuit = true
      of "--noColor": isNoColor = true
      of "--continue": defaultContinue = args[i+1].parseInt; isSkip = true
      of "--infinite": isInfinity = true
      else:
        let blc: int = arg.parseInt
        if blc>=MIN_BLOCK and blc<=MAX_BLOCK:
          defaultBlc = blc
        else: raise

    except:
      echo "[Error]: Invalid command args."
      quit(1)

  if isQuit: quit(0)
  main(defaultBlc, defaultContinue, isInfinity, isNoColor)