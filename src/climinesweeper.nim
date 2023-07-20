import
  illwill,
  std/os,
  std/strutils,
  ./pkg2/minesweeper

const
  HELP: string = """description:
  Play Minesweeper on CLI.
usage:
  ./CLIMineSweeper [--version] [--help] <number>
options:
  -h, --help             display the help
  -v, --version          display the version
  5 <= number <= 20      Set the number of cells and start the game
  None                   Set the min number(5) of cells and start the game
"""
  VERSION: string = "MineSweeper on CLI Version v1.1.1"
  MIN_BLOCK: int = 5 # 最大ブロック数
  MAX_BLOCK: int = 20 # 最小ブロック数

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc main(blc:int): void =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()
  # illwillの画面作成
  var tb: TerminalBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())
  # minesweeper初期化
  var game: MineSweeper = MineSweeper.init(tb, blc)

  game.start()
  while(true):
    let isEnd: bool = game.update()
    if isEnd:
      exitProc()

# TODO: UIの色なしをオプションで指定できるようにする
when isMainModule:
  let args = commandLineParams()
  try:
    if args.len == 0:
      main(5) # オプションなしのとき5マスでスタート

    elif args.len == 1:
      let opt: string = args[0] # TODO: argsはforで回す
      case opt
      of "-h", "--help":
        echo HELP # ヘルプを表示
      of "-v", "--version":
        echo VERSION # バージョンを表示
      else:
        let blc: int = opt.parseInt
        if blc >= MIN_BLOCK and blc <= MAX_BLOCK:
          main(blc)
        else: raise
    else: raise
    
  except:
    echo "[Error]: Invalid command args."
    quit(1)
