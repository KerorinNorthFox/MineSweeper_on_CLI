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
  continueNum: int # コンティニューできる回数

type MainWindow = ref object
  xPos: int
  yPos: int
  cursorXPos: int
  cursorYPos: int
  oldCursorXPos: int
  oldCursorYPos: int

proc init(_:type MainWindow): MainWindow =
  result = MainWindow()
  result.xPos = 0
  result.yPos = 0
  result.cursorXPos = 0
  result.cursorYPos = 0
  result.oldCursorXPos = 0
  result.oldCursorYPos = 0

type MenuWindow = ref object
  xPos: int
  yPos: int
  xPosE: int
  yPosE: int
  totalFlagText: string
  cursorPositionText: string
  separatorYPos: int
  firstChoiceYPos: int
  firstChoiceText: string
  secondChoiceText: string
  secondChoiceYPos: int
  cursorPositionYPos: int
  totalFlagYPos: int
  mode: int

proc init(_:type MenuWindow): MenuWindow =
  result = MenuWindow()
  result.xPos = 5
  result.yPos = 1
  result.xPosE = 45
  result.yPosE = 7
  result.totalFlagText = "Total flags :"
  result.cursorPositionText = "Cursor position :"
  result.separatorYPos = 3
  result.firstChoiceYPos = 4
  result.firstChoiceText = "Set/Remove a flag"
  result.secondChoiceYPos=5
  result.secondChoiceText = "Open the cell"
  result.cursorPositionYPos = 1
  result.totalFlagYPos = 2

type InstructionsWindow = ref object
  xPos: int
  yPos: int
  xPosE: int
  yPosE: int

proc init(_:type InstructionsWindow, m: MenuWindow): InstructionsWindow =
  result = InstructionsWindow()
  result.xPos = m.xPos
  result.yPos = m.yPosE+1
  result.xPosE = m.xPosE
  result.yPosE = result.yPos+14

type MessageWindow = ref object
  xPos: int
  yPos: int
  xPosE: int
  yPosE: int
  msgXPos: int
  msgYPos: int

proc init(_: type MessageWindow, i: InstructionsWindow): MessageWindow =
  result = MessageWindow()
  result.xPos = 1
  result.yPos = i.yPosE+1
  result.xPosE = i.xPosE
  result.yPosE = result.yPos+2
  result.msgXPos = result.xPos+2
  result.msgYPos = result.yPos+1

var
  tb: TerminalBuffer
  game: MineSweeper
  mainWindow: MainWindow = MainWindow.init()
  menuWindow: MenuWindow = MenuWindow.init()
  instructionsWindow: InstructionsWindow = InstructionsWindow.init(menuWindow)
  msgWindow: MessageWindow = MessageWindow.init(instructionsWindow)

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
      var tmp = Blocks(number:count, x:j, y:i, isEmpty:false, status:"o")
      self.blocksSeq.add(tmp)
      count.inc()

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
  self.totalFlag = 0
  self.continueNum = 3

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

###########################################################
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
  let xPos: int = d+self.xPos
  let yPos: int = self.yPos
  tb.drawRect(xPos, yPos, d+self.xPosE, self.yPosE)
  tb.write(xPos+2, yPos+self.totalFlagYPos, self.totalFlagText)
  tb.write(xPos+2, yPos+self.cursorPositionYPos, self.cursorPositionText)
  tb.drawHorizLine(xPos+2, d+self.xPosE-1, yPos+self.separatorYPos, doubleStyle=true)
  tb.write(xPos+4, yPos+self.firstChoiceYPos, self.firstChoiceText)
  tb.write(xPos+4, yPos+self.secondChoiceYPos, self.secondChoiceText)

# 指示画面を描画
proc draw(self:InstructionsWindow): void =
  tb.resetAttributes()
  let d: int = game.doubleBlcNum
  let xPos: int = d+self.xPos
  let yPos: int = self.yPos
  tb.drawRect(xPos, yPos, d+self.xPosE, self.yPosE)
  tb.write(xPos+2, yPos+1, "Available actions")
  tb.drawHorizLine(xPos+2, d+self.xPosE-1, yPos+2, doubleStyle=true)

# メッセージ画面を描画
proc draw(self:MessageWindow): void =
  tb.resetAttributes()
  tb.drawRect(self.xPos, self.yPos, game.doubleBlcNum+self.xPosE, self.yPosE)

# 画面表示
proc drawWindow(self:MineSweeper): void =
  clearTerminal()
  mainWindow.draw()
  menuWindow.draw()
  instructionsWindow.draw()
  msgWindow.draw()
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

  self.drawWindow()

proc checkGamePassed(self:MineSweeper): bool =
  for cell in self.blocksSeq:
    if cell.isBomb:
      if not cell.isFlag:
        return false
    if not cell.isEmpty:
      return false
  return true

proc resetMsg(self:MessageWindow): void =
  tb.resetAttributes()
  tb.write(self.msgXPos, self.msgYPos, " ".repeat(self.xPosE-1-self.msgXPos))
  tb.display()

proc drawMsg(self:MessageWindow, text:string): void =
  tb.write(self.msgXPos, self.msgYPos, text)
  tb.display()

proc drawRemainingFlag(self:MenuWindow): void =
  let
    xPos: int = game.doubleBlcNum+self.xPos+2+len(self.totalFlagText)
    yPos: int = self.yPos+self.totalFlagYPos
  tb.resetAttributes()
  tb.write(xPos, yPos, " ".repeat(3))
  tb.write(xPos, yPos, $(game.totalBomb-game.totalFlag))
  tb.display()

proc drawMenuCursorPos(self:MenuWindow): void =
  let
    xPos: int = game.doubleBlcNum+self.xPos+2+len(self.cursorPositionText)
    yPos: int = self.yPos+self.cursorPositionYPos
  tb.resetAttributes()
  tb.write(xPos, yPos, " ".repeat(4))
  tb.write(xPos, yPos, chr(64+mainWindow.cursorXPos+1).`$`,$(mainWindow.cursorYPos+1))
  tb.display()

proc updateOldCursorPos(self:MainWindow): void =
  self.oldCursorYPos = self.cursorYPos
  self.oldCursorXPos = self.cursorXPos

proc showCursorPosDebug(): void =
  tb.write(1, 30, " ".repeat(100))
  tb.write(1, 30, "cursorXPos:", $mainWindow.cursorXPos, ", cursorYPos:", $mainWindow.cursorYPos, ", oldCursorXPos:", $mainWindow.oldCursorXPos, ", oldCursorYPos:", $mainWindow.oldCursorYPos)

# メイン画面にカーソル描画
proc drawCursor(self:MainWindow): void =
  tb.write(4+(self.oldCursorXPos*2), 2+self.oldCursorYPos, game.blocksSeq[self.oldCursorYPos*game.blcNum+self.oldCursorXPos].status)
  tb.setBackgroundColor(bgWhite)
  tb.setForegroundColor(fgBlack)
  tb.write(4+(self.cursorXPos*2), 2+self.cursorYPos, game.blocksSeq[self.cursorYPos*game.blcNum+self.cursorXPos].status)
  menuWindow.drawMenuCursorPos()
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
  let xPos: int = game.doubleBlcNum+self.xPos+2
  tb.resetAttributes()
  tb.write(xPos, self.yPos+self.firstChoiceYPos, " ")
  tb.write(xPos, self.yPos+self.secondChoiceYPos, " ")
  if not reset:
    tb.write(xPos, self.yPos+self.firstChoiceYPos+self.mode, ">")
  tb.display()

# メニュー画面でカーソル移動
proc selectChoices(self:MenuWindow): bool =
  msgWindow.resetMsg()
  msgWindow.drawMsg("Select choices.")
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

proc setFlag(self:MineSweeper, pos:int): void =
  self.blocksSeq[pos].isFlag = true
  self.blocksSeq[pos].isEmpty = true
  self.blocksSeq[pos].status = "F"
  self.totalFlag.inc()

proc removeFlag(self:MineSweeper, pos:int): void =
  self.blocksSeq[pos].isFlag = false
  self.blocksSeq[pos].isEmpty = false
  self.blocksSeq[pos].status = "o"
  self.totalFlag.dec()

proc releaseCell(self:MineSweeper, pos:int): void =
  self.blocksSeq[pos].isEmpty = true
  let numAround: int = self.blocksSeq[pos].numAround
  if numAround != 0:
    self.blocksSeq[pos].status = $numAround
  else:
    self.blocksSeq[pos].status = " "

proc checkAroundBomb(self:MineSweeper, pos:int): void =
  let around: array[3,int] = [-1, 0, 1]
  var bombCounter: int = 0
  for row in around:
    if mainWindow.cursorXPos+row < 0:
      continue
    for column in around:
      if mainWindow.cursorYPos+column < 0:
        continue
      try:
        if self.blocksSeq[pos+row+(column*self.blcNum)].isBomb:
          bombCounter.inc()
      except IndexDefect:
        continue
  
  if bombCounter != 0:
    self.blocksSeq[pos].numAround = bombCounter
  else:
    self.blocksSeq[pos].numAround = 0

proc update*(self:MineSweeper): bool =
  let isPassed: bool = self.checkGamePassed()
  if isPassed:
    return true # TODO: ゲーム終了処理

  menuWindow.drawRemainingFlag()
  mainWindow.moveCursor()
  let isAbort: bool = menuWindow.selectChoices()
  msgWindow.resetMsg()
  if isAbort: # ESCでの中止
    return false

  let blocksSeqPos: int = mainWindow.cursorYPos*self.blcNum+mainWindow.cursorXPos
  # マスが既に解放されているとき
  if self.blocksSeq[blocksSeqPos].isEmpty:
      msgWindow.drawMsg("The cell has been already opened.")
      return false

  # 旗を立てる/除ける
  if menuWindow.mode == 0:  
    # 旗が立っているとき
    if self.blocksSeq[blocksSeqPos].isFlag:
      self.removeFlag(blocksSeqPos)
      msgWindow.drawMsg("Removed the flag.")
    # 旗が立っていない時
    elif not self.blocksSeq[blocksSeqPos].isFlag:
      if self.totalBomb-self.totalFlag == 0:
        msgWindow.drawMsg("All flag has been set.")
        return false
      self.setFlag(blocksSeqPos)
      msgWindow.drawMsg("Set the flag.")

  # マス目解放
  elif menuWindow.mode == 1:
    # 既に旗が立っているとき
    if self.blocksSeq[blocksSeqPos].isFlag:
      msgWindow.drawMsg("The flag has been already set.")
      return false
    # 爆弾に当たった時
    elif self.blocksSeq[blocksSeqPos].isBomb: # TODO:
      tb.setForegroundColor(fgRed)
      msgWindow.drawMsg("Boom!!")
      sleep(2000)
      tb.resetAttributes()
      return true

    self.checkAroundBomb(blocksSeqPos)
    self.releaseCell(blocksSeqPos)
    msgWindow.drawMsg("Released the cell.")

  tb.write(4+(mainWindow.cursorXPos*2), 2+mainWindow.cursorYPos, self.blocksSeq[blocksSeqPos].status)
  tb.display()

  return false
