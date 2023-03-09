import
  illwill,
  std/os,
  std/strutils,
  std/strformat,
  std/sequtils,
  std/random,
  ./blocks

const
  MIN_BLOCK: int = 5
  MAX_BLOCK: int = 20
  BLC_LIM_ARRAY: array[7,int] = [7, 9, 11, 13, 15, 17, 20]
  BOMB_LIM_ARRAY: array[7,int] = [2, 3, 4, 5, 6, 7, 8]

type CursorPos = ref object
  cursorXPos: int
  cursorYPos: int
  oldCursorXPos: int
  oldCursorYPos: int

proc init(_:type CursorPos): CursorPos =
  result = CursorPos()
  result.cursorXPos = 0
  result.cursorYPos = 0
  result.oldCursorXPos = 0
  result.oldCursorYPos = 0

var
  tb: TerminalBuffer
  cursor: CursorPos = CursorPos.init()

proc concatSeq(stringSeq:seq[string]): string =
  var text: string = ""
  for elem in stringSeq:
    text = text & elem
  return $text

type MineSweeper* = ref object
  blocksSeq*: seq[Blocks]
  totalFlag*: int
  totalBomb*: int
  blcNum*: int

# 画面をクリア
proc clearTerminal(): void =
  tb.clear()
  tb.display()

# 最初のマスを設定する画面
proc inputSetting(self:MineSweeper): void =
  clearTerminal()
  tb.setForegroundColor(fgWhite, true)
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
  echo "howManyBombPerLine :", howManyBombPerLine
  
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

# ゲームスタート画面
proc start(self:MineSweeper): void =
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

proc showDebug(self:MineSweeper): void =
  clearTerminal()
  echo "totalBomb :", self.totalBomb
  for a in self.blocksSeq:
    echo "y:", a.y, ", x:", a.x, ", isBomb:", a.isBomb, ", isFlag:", a.isFlag, ", satus:", a.status
  echo "blocksSeq.len:", self.blocksSeq.len

proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer): MineSweeper =
  tb = terminalbuffer
  var game = MineSweeper(blcNum:0)
  game.inputSetting()
  game.setting()
  game.start()
  return game

type WindowLines = ref object
  firstLine: string
  secondLine: string
  otherLines: seq[string]

# 画面作成
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

# 画面表示
proc showWindow(self:MineSweeper): void =
  clearTerminal()
  let lines: WindowLines = self.makeWindow()
  tb.write(0, 0, lines.firstLine)
  tb.write(0, 1, lines.secondLine)
  for i, line in lines.otherLines:
    tb.write(0, 2+i, line)

  tb.drawRect((self.blcNum*2)+5, 1, (self.blcNum*2)+45, 5)
  tb.write((self.blcNum*2)+7, 3, "Write the explaination here")

  tb.display()

proc updateCursorPos(): void =
  cursor.oldCursorYPos = cursor.cursorYPos
  cursor.oldCursorXPos = cursor.cursorXPos

proc moveCursor(self:MineSweeper): void =
  while(true):
    tb.write(1, 25, " ".repeat(100))
    tb.write(1, 25, "cursorXPos:", $cursor.cursorXPos, ", cursorYPos:", $cursor.cursorYPos, ", oldCursorXPos:", $cursor.oldCursorXPos, ", oldCursorYPos:", $cursor.oldCursorYPos)

    tb.write(4+(cursor.oldCursorXPos*2), 2+cursor.oldCursorYPos, self.blocksSeq[cursor.oldCursorYPos*self.blcNum+cursor.oldCursorXPos].status)
    tb.setBackgroundColor(bgWhite)
    tb.setForegroundColor(fgBlack)
    tb.write(4+(cursor.cursorXPos*2), 2+cursor.cursorYPos, self.blocksSeq[cursor.cursorYPos*self.blcNum+cursor.cursorXPos].status)
    tb.resetAttributes()
    tb.display()
    sleep(20)


    let key = getKey()
    case key
    of Key.Up:
      if cursor.cursorYPos == 0:
        continue
      updateCursorPos()
      cursor.cursorYPos.dec()
    of Key.Down:
      if cursor.cursorYPos == self.blcNum-1:
        continue
      updateCursorPos()
      cursor.cursorYPos.inc()
    of Key.Right:
      if cursor.cursorXPos == self.blcNum-1:
        continue
      updateCursorPos()
      cursor.cursorXPos.inc()
    of Key.Left:
      if cursor.cursorXPos == 0:
        continue
      updateCursorPos()
      cursor.cursorXPos.dec()
    else:
      discard

proc operate(self:MineSweeper): void =
  self.moveCursor()

proc update*(self:MineSweeper): void =
  self.showWindow()
  self.operate()
