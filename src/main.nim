import
  illwill,
  ./minesweeper

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc main(): void =
  illwillInit(fullscreen=true)
  setControlCHook(exitProc)
  hideCursor()

  # illwillの画面作成
  var tb: TerminalBuffer = newTerminalBuffer(terminalWidth(), terminalHeight())
  # minesweeper初期化
  var game = MineSweeper.init(tb)

when isMainModule:
  main()