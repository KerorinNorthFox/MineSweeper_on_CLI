import
  illwill,
  std/os,
  std/strutils,
  std/strformat,
  std/sequtils,
  std/random,
  ./blocks

const
  MIN_BLOCK: int = 5 # 最大ブロック数
  MAX_BLOCK: int = 20 # 最小ブロック数
  BLC_LIM_ARRAY: array[7,int] = [7, 9, 11, 13, 15, 17, 20]
  BOMB_LIM_ARRAY: array[7,int] = [2, 3, 4, 5, 6, 7, 8]

type MineSweeper* = ref object
  blocksSeq: seq[Blocks]
  totalFlag: int # 現在立っている旗の総数
  totalBomb: int # 現在の残り爆弾数
  blcNum: int # マス目横/縦の数
  doubleBlcNum: int

type MainWindow = ref object
  xPos: int
  yPos: int
  cursorXPos: int
  cursorYPos: int
  oldCursorXPos: int
  oldCursorYPos: int

proc init(_:type MainWindow, xPos, yPos: int): MainWindow =
  result = MainWindow()
  result.xPos = xPos
  result.yPos = yPos
  result.cursorXPos = 0
  result.cursorYPos = 0
  result.oldCursorXPos = 0
  result.oldCursorYPos = 0

type MenuWindow = ref object
  xPos: int
  yPos: int
  xPosE: int
  yPosE: int
  mode: int

type InstructionsWindow = ref object
  xPos: int
  yPos: int
  xPosE: int
  yPosE: int

var
  tb: TerminalBuffer
  game: MineSweeper
  mainWindow: MainWindow = MainWindow.init(xPos=0, yPos=0)
  menuWindow: MenuWindow = MenuWindow(xPos:5, yPos:1, xPosE:45, yPosE:6)
  instructionsWindow: InstructionsWindow = InstructionsWindow(xPos:5, yPos:7, xPosE:45, yPosE:20)

# stringのseqの内容を繋げる
proc concatSeq(stringSeq:seq[string]): string =
  var text: string = ""
  for elem in stringSeq:
    text = text & elem
  return $text

# 画面をクリア
proc clearTerminal(): void =
  tb.clear()
  tb.display()

# 最初のマスを設定する画面
proc inputSetting(self:MineSweeper): void =
  clearTerminal()
  tb.drawRect(0, 0, 50, 5)
  tb.write(2, 1, "<-Initial Setting->")
  tb.write(2, 2, "Enter the number of cells(5 =< number =< 20)")
  tb.drawHorizLine(2, 48, 3, doubleStyle=true)
  tb.write(2, 4, ": ")

  var num: string = ""
  while(true):
    tb.display()
    sleep(20)

    let key = getKey()
    case key
    of Key.None: continue

    of Key.Backspace:
      if num == "": continue
      if num.len == 1:
        num = ""
      else:
        num = num[0 .. ^2]

    of Key.Enter:
      if num == "": continue
      var number: int
      try:
        number = num.parseInt
        if number >= MIN_BLOCK and number <= MAX_BLOCK:
          self.blcNum = number
          self.doubleBlcNum = number*2
          return
      except ValueError: continue

    else:
      var number: int
      try:
        number = parseInt($($key.char))
        num = num & $number
      except ValueError: continue

    tb.write(3, 4, " ".repeat(45))
    tb.write(3, 4, num)

# blocksSeqにマスを入れていく
proc makeBlockSeq(self:MineSweeper): void =
  self.blocksSeq = @[]
  var count: int = 1
  for i in 0..<self.blcNum:
    for j in 0..<self.blcNum:
      var tmp = Blocks()
      tmp.number = count
      tmp.x = j
      tmp.y = i
      tmp.status = "o"
      count.inc()

      self.blocksSeq.add(tmp)
  self.totalFlag = 0

# 爆弾設置
proc setBombs(self:MineSweeper): void =
  var howManyBombPerLine: int
  for i, lim in BLC_LIM_ARRAY: # 配列の長さによって爆弾の数を調整
    if self.blcNum <= lim:
      howManyBombPerLine = BOMB_LIM_ARRAY[i] # 一行当たりの爆弾の数を設定
      break
  
  var lineNum: int = 0
  for i in 0..<self.blcNum: # 行数分回す
    let bombNumPerLine: int  = rand(1..howManyBombPerLine)
    self.totalBomb += bombNumPerLine

    var count: int = 0
    var exc: seq[int] = @[] # 被った値を一時的に置いておく
    while(count < bombNumPerLine): # 一行当たりの爆弾数分回す
      let bombPos: int = rand(0..<self.blcNum)

      var isBombSamePos: bool = false
      for n in exc:
        if bombPos == n:
          isBombSamePos = true
          break
      if isBombSamePos:
        continue

      exc.add(bombPos)
      self.blocksSeq[lineNum*self.blcNum+bombPos].isBomb = true
      count.inc()

    lineNum.inc()

# ゲームの初期設定
proc setting(self:MineSweeper): void =
  self.makeBlockSeq()
  self.setBombs()


proc showDebug(): void =
  clearTerminal()
  echo "totalBomb :", game.totalBomb
  for a in game.blocksSeq:
    echo "y:", a.y, ", x:", a.x, ", isBomb:", a.isBomb, ", isFlag:", a.isFlag, ", satus:", a.status
  echo "blocksSeq.len:", game.blocksSeq.len

proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer): MineSweeper =
  tb = terminalbuffer
  var ms = MineSweeper()
  ms.inputSetting()
  ms.setting()
  game = ms
  return ms

type WindowLines = ref object
  firstLine: string
  secondLine: string
  otherLines: seq[string]

proc makeWindow(self:MineSweeper): WindowLines =
  result = WindowLines()
  var
    firstLineSeq: seq[string] = @["   "]
    secondLineSeq: seq[string] = @["  _"]
    line2DSeq: seq[seq[string]] = newSeqWith(1, newSeq[string](1))
    count: int = 0

  for i in 1..self.blcNum:
    var tmpSeq: seq[string] = newSeq[string](1)
    firstLineSeq.add(fmt" {chr(64+i):>2}")
    secondLineSeq.add("__")

    tmpSeq.add(fmt"{$(i):>2}|")

    for _ in 1..self.blcNum:
      tmpSeq.add(fmt" {self.blocksSeq[count].status}")
      count.inc()
    line2DSeq.add(tmpSeq)

  result.firstLine = concatSeq(firstLineSeq)
  result.secondLine = concatSeq(secondLineSeq)

  var isSkipElem: bool = true
  for elem in line2DSeq:
    if isSkipElem:
      isSkipElem = false
      continue
    result.otherLines.add(concatSeq(elem))

# メイン画面を描画
proc draw(self:MainWindow): void =
  tb.resetAttributes()
  let lines: WindowLines = game.makeWindow()
  tb.write(self.xPos, self.yPos, lines.firstLine)
  tb.write(self.xPos, self.yPos+1, lines.secondLine)
  for i, line in lines.otherLines:
    tb.write(self.xPos, self.yPos+2+i, line)

# メニュー画面を描画
proc draw(self:MenuWindow): void =
  tb.resetAttributes()
  let d: int = game.doubleBlcNum
  tb.drawRect(d+self.xPos, self.yPos, d+self.xPosE, self.yPosE)
  tb.drawHorizLine(d+self.xPos+2, d+self.xPosE-1, self.yPos+2, doubleStyle=true)
  tb.write(d+self.xPos+4, self.yPos+3, "Set/Remove a flag")
  tb.write(d+self.xPos+4, self.yPos+4, "Open the cell")

# 指示画面を描画
proc draw(self:InstructionsWindow): void =
  tb.resetAttributes()
  let d: int = game.doubleBlcNum
  tb.drawRect(d+self.xPos, self.yPos, d+self.xPosE, self.yPosE)
  tb.write(d+self.xPos+2, self.yPos+1, "Instructions")
  tb.drawHorizLine(d+self.xPos+2, d+self.xPosE-1, self.yPos+2, doubleStyle=true)

# 画面表示
proc showWindow(self:MineSweeper): void =
  clearTerminal()
  mainWindow.draw()
  menuWindow.draw()
  instructionsWindow.draw()
  tb.display()

proc start*(self:MineSweeper): void =
  clearTerminal()
  var
    halfWidth: int = tb.width div 2
    halfHeight: int = tb.height div 2
    text: string = "To the start of the game..."
  tb.drawRect(halfWidth-20, halfHeight-3, halfWidth+20, halfHeight+1)
  for count in countdown(3, 1):
    tb.write(halfWidth-13, halfHeight-1, text, $count)
    tb.display()
    sleep(1000)

  self.showWindow()

# メイン画面の古いカーソル位置を更新
proc updateOldCursorPos(self:MainWindow): void =
  self.oldCursorYPos = self.cursorYPos
  self.oldCursorXPos = self.cursorXPos

# メニュー画面にカーソル座標を描画更新
proc updateMenuCursorPos(self:MainWindow): void =
  tb.write(game.doubleBlcNum+7, 2, " ".repeat(36))
  tb.write(game.doubleBlcNum+7, 2, "Cursor position :", chr(64+self.cursorXPos+1).`$`,$(self.cursorYPos+1))

proc showCursorPosDebug(): void =
  tb.write(1, 25, " ".repeat(100))
  tb.write(1, 25, "cursorXPos:", $mainWindow.cursorXPos, ", cursorYPos:", $mainWindow.cursorYPos, ", oldCursorXPos:", $mainWindow.oldCursorXPos, ", oldCursorYPos:", $mainWindow.oldCursorYPos)

# メイン画面にカーソル描画
proc drawCursor(self:MainWindow): void =
  tb.write(4+(self.oldCursorXPos*2), 2+self.oldCursorYPos, game.blocksSeq[self.oldCursorYPos*game.blcNum+self.oldCursorXPos].status)
  tb.setBackgroundColor(bgWhite)
  tb.setForegroundColor(fgBlack)
  tb.write(4+(self.cursorXPos*2), 2+self.cursorYPos, game.blocksSeq[self.cursorYPos*game.blcNum+self.cursorXPos].status)
  tb.resetAttributes()
  self.updateMenuCursorPos()
  tb.display()

# メイン画面のカーソル移動
proc moveCursor(self:MainWindow): void =
  while(true):
    showCursorPosDebug()

    self.drawCursor()
    sleep(20)

    let key = getKey()
    case key
    of Key.Enter:
      return
    of Key.Up:
      if self.cursorYPos == 0:
        continue
      self.updateOldCursorPos()
      self.cursorYPos.dec()
    of Key.Down:
      if self.cursorYPos == game.blcNum-1:
        continue
      self.updateOldCursorPos()
      self.cursorYPos.inc()
    of Key.Right:
      if self.cursorXPos == game.blcNum-1:
        continue
      self.updateOldCursorPos()
      self.cursorXPos.inc()
    of Key.Left:
      if self.cursorXPos == 0:
        continue
      self.updateOldCursorPos()
      self.cursorXPos.dec()
    else: continue

# メニュー画面にカーソル描画
proc drawCursor(self:MenuWindow, reset:bool=false): void =
  let d: int = game.doubleBlcNum
  tb.write(d+self.xPos+2, self.yPos+3, " ")
  tb.write(d+self.xPos+2, self.yPos+4, " ")
  if not reset:
    tb.write(d+self.xPos+2, self.yPos+3+self.mode, ">")
  tb.display()

# メニュー画面でカーソル移動
proc selectChoices(self:MenuWindow): bool =
  self.mode = 0
  while(true):
    self.drawCursor()
    sleep(20)

    let key = getKey()
    case key
    of Key.Enter:
      break
    of Key.Escape:
      self.drawCursor(reset=true)
      return true
    of Key.Up, Key.Down:
      if self.mode == 0:
        self.mode = 1
      elif self.mode == 1:
        self.mode = 0
    else: discard
  
  self.drawCursor(reset=true)
  return false

proc update*(self:MineSweeper): void =
  mainWindow.moveCursor()
  let isAbort: bool = menuWindow.selectChoices()
  if isAbort:
    return

  if menuWindow.mode == 0:
    discard
  elif menuWindow.mode == 1:
    discard
