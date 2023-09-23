import
  illwill,
  std/[os, strutils, strformat],
  ./pkg/[minesweeper, utils]

const
  HELP: string = """description:
  Play Minesweeper on CLI.
usage:
  ./CLIMineSweeper [--version] [--help] [--noColor] <number>
options:
  -h, --help             display the help.
  -v, --version          display the version.
  --noColor              Play without colors.
  --continue [number]    Play with a set number of continue.
  --infinite             Play without Boom!!.
  --new                  Discard save file and play a new game
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

proc main(args:Args): void =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()
  # illwillの画面作成
  var tb: TerminalBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())
  # minesweeper初期化
  var game: MineSweeper = MineSweeper.init(tb, args)

  game.start()
  while(true):
    let isEnd: bool = game.update()
    if isEnd:
      exitProc()

when isMainModule:
  let cmdArgs = commandLineParams()

  var
    isSkip: bool = false
    isQuit: bool = false
    args: Args = Args()
  args.blockNum = 5
  args.defaultContinue = 3
  args.isInfinity = false
  args.isNoColor = false
  args.isNew = true
  for i, arg in cmdArgs:
    if isSkip:
      isSkip = false
      continue
    try:
      case arg
      of "-h", "--help": echo HELP; isQuit = true
      of "-v", "--version": echo GAME_VERSION; isQuit = true
      of "--noColor": args.isNoColor = true
      of "--continue": args.defaultContinue = cmdArgs[i+1].parseInt; isSkip = true
      of "--infinite": args.isInfinity = true
      of "--new": discard
      else:
        args.isNew = false
        let blc: int = arg.parseInt
        if blc>=MIN_BLOCK and blc<=MAX_BLOCK:
          args.blockNum = blc
        else: raise

    except:
      echo "[Error]: Invalid command args."
      quit(1)

  if isQuit: quit(0)
  main(args)