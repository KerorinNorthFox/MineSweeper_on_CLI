import
  illwill,
  std/os,
  std/strutils,
  std/strformat,
  std/sequtils,
  std/random,
  ./utils

#================================================================
#
#                   Decralation
#
#================================================================

#----------------------------------------------------------------
#                   Consts
#----------------------------------------------------------------
const
  BLC_LIM_ARRAY: array[7,int] = [7, 9, 11, 13, 15, 17, 20]
  BOMB_LIM_ARRAY: array[7,int] = [2, 3, 4, 5, 6, 7, 8]
  REMAINING_CONTINUE: int = 3 # 残りコンティニュー数
  WINDOW_WIDTH: int = 40 # ウィンドウの横幅
  GET_KEY_SLEEP_MS: int = 20 # キー入力のスリープタイム

#----------------------------------------------------------------
#                   Types
#----------------------------------------------------------------
type
  WindowLines = ref object
    firstLine: string
    secondLine: string
    otherLines: seq[string]

type
  MainWindow = ref object
    pos: Position
    cursor: Cursor
    width: int
    height: int

  MenuWindow = ref object
    pos: Position
    cursor: Cursor
    width: int
    height: int
    texts: seq[string] # メニューテキスト
    defaultChoices: seq[string] # 選択肢1
    continueChoices: seq[string] # 選択肢2
    mode: int # 選択肢のどれか

  InstructionsWindow = ref object
    pos: Position
    width: int
    height: int
    texts: seq[string]

  MessageWindow = ref object
    pos: Position
    width: int
    height: int

type MineSweeper* = ref object
  blocks: seq[Blocks]
  blc: int # マス目縦/横の数
  doubleBlc: int
  placedTotalFlags: int # 現在立っている旗の総数
  remainingContinue: int # 残りコンティニュー数
  remainingBombs: int # 現在の残り爆弾総数

  mainWindow: MainWindow
  menuWindow: MenuWindow
  instructionsWindow: InstructionsWindow
  messageWindow: MessageWindow

#----------------------------------------------------------------
#                 Public vars
#----------------------------------------------------------------
var
  tb: TerminalBuffer
  game: MineSweeper
  isNoColor: bool

#----------------------------------------------------------------
#                 Public proc
#----------------------------------------------------------------
# string型のseqの中身を結合
proc concatSeq(stringSeq:seq[string]): string =
  var text: string = ""
  for elem in stringSeq:
    text = text & elem
  return $text

# 画面をクリアして描画更新
proc clearTerminal(): void =
  tb.clear()
  tb.display()

# 文字色を任意で設定
proc setAttribute(self:var TerminalBuffer, fg:ForegroundColor, bg:BackgroundColor, isBright:bool=true): void =
  tb.resetAttributes()
  if isNoColor: return
  tb.setForegroundColor(fg, isBright)
  tb.setBackgroundColor(bg)

proc showCursorPosDebug(): void {.used.}  =
  tb.write(1, 30, " ".repeat(100))
  tb.write(1, 30, "cursorXPos:", $game.mainWindow.cursor.x, ", cursorYPos:", $game.mainWindow.cursor.y, ", oldCursorXPos:", $game.mainWindow.cursor.preX, ", oldCursorYPos:", $game.mainWindow.cursor.preY)

#----------------------------------------------------------------
#               Main Window Dec
#----------------------------------------------------------------
proc init(_:type MainWindow, ms:MineSweeper): MainWindow

proc draw(self:MainWindow): void

proc moveCursor(self:MainWindow): void

proc drawCursor(self:MainWindow): void

proc drawGameOverAnimation(self:MainWindow): void

proc drawBomb(self:MainWindow, i:int): void

#----------------------------------------------------------------
#               Menu Window Dec
#----------------------------------------------------------------
proc init(_:type MenuWindow, dpdWin:MainWindow): MenuWindow

proc draw(self:MenuWindow): void

proc drawChoices(self:MenuWindow, choices:seq[string]): void

proc updateMenu(self:MenuWindow): void

proc drawRemainingFlags(self:MenuWindow): void

proc drawRemainingContinues(self:MenuWindow): void

proc drawCursorPosition(self:MenuWindow): void

proc selectChoices(self:MenuWindow): bool

proc drawCursor(self:MenuWindow, reset:bool=false): void

proc selectContinue(self:MenuWindow): bool

#----------------------------------------------------------------
#               Instructions Window Dec
#----------------------------------------------------------------
proc init(_:type InstructionsWindow, dpdWin:MenuWindow): InstructionsWindow

proc draw(self:InstructionsWindow): void

proc drawActions(self:InstructionsWindow, actions:seq[string]): void

proc resetActions(self:InstructionsWindow): void

#----------------------------------------------------------------
#               Message Window Dec
#----------------------------------------------------------------
proc init(_:type MessageWindow, dpdWin:InstructionsWindow, mainWinWidth:int): MessageWindow

proc draw(self:MessageWindow): void

proc drawMessage(self:MessageWindow, text:string, fg:ForegroundColor=fgYellow): void

proc resetMessage(self:MessageWindow): void

#----------------------------------------------------------------
#               MineSweeper Dec
#----------------------------------------------------------------
proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer, blc:int, noColorFlag:bool): MineSweeper

proc setting(self:MineSweeper, blc:int): void

proc makeBlocks(self:MineSweeper): void

proc placeBombs(self:MineSweeper): void

proc drawWindow(self:MineSweeper): void

proc makeWindowLines(self:MineSweeper): WindowLines

proc checkIfGamePassed(self:MineSweeper): bool

proc endGame(self:MineSweeper): void

proc placeFlag(self:MineSweeper, pos:int): void

proc removeFlag(self:MineSweeper, pos:int): void

proc releaseCell(self:MineSweeper, pos:int): void

proc countBombAroundCell(self:MineSweeper, pos:int): void

#================================================================
#
#                   implementation
#
#================================================================

#----------------------------------------------------------------
#               Main Window Impl
#----------------------------------------------------------------
proc init(_:type MainWindow, ms:MineSweeper): MainWindow =
  result = MainWindow()
  result.pos = Position(x:0, y:0)
  result.cursor = Cursor(x:0, y:0, preX:0, preY:0)
  result.width = ms.doubleBlc + 3
  result.height = ms.blc + 3

# メイン画面描画
proc draw(self:MainWindow): void =
  tb.setAttribute(fgWhite, bgNone)
  let
    lines: WindowLines = game.makeWindowLines()
    xOffset = 0
    yOffset = 0
    xPos = self.pos.x + xOffset
    yPos = self.pos.y + yOffset
  tb.write(xPos, yPos, lines.firstLine)
  tb.write(xPos, yPos+1, lines.secondLine)
  for i, line in lines.otherLines:
    tb.write(xPos, yPos+2+i, line)

# カーソルを移動
proc moveCursor(self:MainWindow): void =
  # 指示ウィンドウに指示を描画
  let actions: seq[string] = @[
    "Arrow key : Move cursor",
    "HJKL key: Move cursor",
    "Enter key: Select the cell",
    "Ctrl+c : Quit the game"
  ]
  game.instructionsWindow.drawActions(actions)

  while(true):
    self.drawCursor() # メイン画面とメニュー画面にカーソル描画
    sleep(GET_KEY_SLEEP_MS)

    let key = getKey()
    case key
    # ---決定---
    of Key.Enter:
      return
    # ---上移動---
    of Key.Up, Key.K:
      if self.cursor.y == 0: # yが-1になるため処理しない
        continue
      self.cursor.moveUp()
    # ---下移動---
    of Key.Down, Key.J:
      if self.cursor.y == game.blc-1: # yが上限を超えるため処理しない
        continue
      self.cursor.moveDown()
    # ---右移動---
    of Key.Right, Key.L:
      if self.cursor.x == game.blc-1: # xが上限を超えるため処理しない
        continue
      self.cursor.moveRight()
    # ---左移動---
    of Key.Left, Key.H:
      if self.cursor.x == 0: # xが-1になるため処理しない
        continue
      self.cursor.moveLeft()
    # ---それ以外---
    else: continue

# カーソルを描画
proc drawCursor(self:MainWindow): void =
  let
    xOffset: int = 4
    yOffset: int = 2
    preXPos: int = self.cursor.preX*2 + xOffset
    preYPos: int = self.cursor.preY + yOffset
    xPos: int = self.cursor.x*2 + xOffset
    yPos: int = self.cursor.y + yOffset
    preCursorPos: int = self.cursor.preY*game.blc + self.cursor.preX # ひとつ前のカーソル位置
    cursorPos: int = self.cursor.y*game.blc + self.cursor.x # カーソル位置
  tb.setAttribute(game.blocks[preCursorPos].fg, bgNone)
  tb.write(preXPos, preYPos, game.blocks[preCursorPos].status)

  tb.setAttribute(fgBlack, bgWhite)
  tb.write(xPos, yPos, game.blocks[cursorPos].status)
  
  game.menuWindow.drawCursorPosition() # メニュー画面にカーソルの座標を表示
  tb.display()

# ゲームオーバー時のアニメーションを表示
proc drawGameOverAnimation(self:MainWindow): void =
  let
    xOffset: int = 4
    yOffset: int = 2
    xPos: int = self.cursor.x*2 + xOffset
    yPos: int = self.cursor.y + yOffset
  var flag: bool = true
  # 爆弾の位置を点滅させるアニメーション
  for _ in 1..6:
    if flag:
      tb.setAttribute(fgRed, bgWhite)
    else:
      tb.setAttribute(fgRed, bgNone)
    tb.write(xPos, yPos, "B")
    tb.display()
    flag = not flag
    sleep(800)

# 爆弾を描画
proc drawBomb(self:MainWindow, i:int): void =
  if i >= game.blc*game.blc:
    return
  tb.resetAttributes()
  let
    xOffset: int = 4
    yOffset: int = 2
    xPos: int = (i mod game.blc) * 2
    xPosHalf: int = xPos div 2
    yPos: int = i div game.blc
  tb.write(xPos+xOffset, yPos+yOffset, " ")
  if game.blocks[yPos*game.blc+xPosHalf].isBomb:
    tb.setAttribute(fgRed, bgNone)
    tb.write(xPos+xOffset, yPos+yOffset, "B")
  tb.display()

#----------------------------------------------------------------
#               Menu Window Impl
#----------------------------------------------------------------
proc init(_:type MenuWindow, dpdWin:MainWindow): MenuWindow =
  result = MenuWindow()
  result.pos = Position(x:dpdWin.width+2, y:1)
  result.cursor = Cursor(x:0, y:1, preX:0, preY:0)
  result.texts = @[]
  result.texts.add("Cursor position :")
  result.texts.add("Remaining flags :")
  result.texts.add("Remaining continue :")
  result.texts.add("_separator")
  result.defaultChoices = @[]
  result.defaultChoices.add("Place/Remove the flag")
  result.defaultChoices.add("Open the cell")
  result.continueChoices = @[]
  result.continueChoices.add("Yes")
  result.continueChoices.add("No")
  result.width = WINDOW_WIDTH
  if result.defaultChoices.len < result.continueChoices.len:
    result.height = result.texts.len+result.continueChoices.len+1
  else:
    result.height = result.texts.len+result.defaultChoices.len+1

# 画面描画
proc draw(self:MenuWindow): void =
  tb.setAttribute(fgCyan, bgNone)
  tb.drawRect(self.pos.x, self.pos.y, self.pos.x+self.width, self.pos.y+self.height)
  let
    xOffset: int = 2
    yOffset: int = 0
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y  + yOffset
  for i in 1..self.texts.len:
    if self.texts[i-1] == "_separator":
      tb.drawHorizLine(xPos, self.pos.x+self.width-2, yPos+i, doubleStyle=true)
    elif self.texts[i-1] == "_space":
      discard
    else:
      tb.write(xPos, yPos+i, self.texts[i-1])
  self.drawChoices(self.defaultChoices)

# 選択肢を描画
proc drawChoices(self:MenuWindow, choices:seq[string]): void =
  tb.setAttribute(fgYellow, bgNone)
  let
    xOffset: int = 4
    yOffset: int = self.texts.len
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  for i in 1..choices.len:
    tb.write(xPos, yPos+i, " ".repeat(self.width-4))
    tb.write(xPos, yPos+i, choices[i-1])

# メニュー画面をアップデート
proc updateMenu(self:MenuWindow): void =
  self.draw()
  self.drawRemainingFlags()
  self.drawRemainingContinues()
  tb.display()

# 残り旗数を描画
proc drawRemainingFlags(self:MenuWindow): void =
  tb.setAttribute(fgCyan, bgNone)
  let
    xOffset: int = 2 + self.texts[1].len
    yOffset: int = 2
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  tb.write(xPos, yPos, " ".repeat(3))
  tb.write(xPos, yPos, $(game.remainingBombs-game.placedTotalFlags))

# 残りコンティニュー数を描画
proc drawRemainingContinues(self:MenuWindow): void =
  tb.setAttribute(fgCyan, bgNone)
  let
    xOffset: int = 2 + self.texts[2].len
    yOffset: int = 3
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  tb.write(xPos, yPos, " ".repeat(3))
  tb.write(xPos, yPos, game.remainingContinue.`$`)

# カーソル座標をメニュー画面に描画
proc drawCursorPosition(self:MenuWindow): void =
  tb.setAttribute(fgCyan, bgNone)
  let
    xOffset: int = 2 + self.texts[0].len
    yOffset: int = self.cursor.y
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  tb.write(xPos, yPos, " ".repeat(4))
  tb.write(xPos, yPos, chr(64+game.mainWindow.cursor.x+1).`$`, $(game.mainWindow.cursor.y+1))

# メニュー選択
proc selectChoices(self:MenuWindow): bool =
  # 指示ウィンドウに指示を描画
  let actions: seq[string] = @[
    "Arrow key[Up, Down] : Select choices",
    "JK key : Select choices",
    "Enter key : Decide a choice",
    "Escape key : Back to previous",
    "Ctrl+c : Quit the game"
  ]
  game.instructionsWindow.drawActions(actions)
  game.messageWindow.drawMessage("Select choices.")
  self.mode = 0

  while(true):
    self.drawCursor()
    sleep(GET_KEY_SLEEP_MS)

    let key = getKey()
    case key
    # ---決定---
    of Key.Enter:
      break
    # ---エスケープキー---
    of Key.Escape:
      self.drawCursor(reset=true)
      return true
    # ---上下キー---
    of Key.Up, Key.Down, Key.K, Key.J:
      if self.mode == 0:
        self.mode = 1
      elif self.mode == 1:
        self.mode = 0
    else: discard

  self.drawCursor(reset=true)
  return false

# メニュー選択カーソルを描画
proc drawCursor(self:MenuWindow, reset:bool=false): void =
  tb.resetAttributes()
  let
    xOffset: int = 2
    yOffset: int = self.texts.len + 1
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  var choices: seq[string] = self.defaultChoices
  if self.defaultChoices.len < self.continueChoices.len:
    choices = self.continueChoices
  for i in 0..<choices.len:
    tb.write(xPos, yPos+i, " ")
  if not reset:
    tb.setAttribute(fgYellow, bgNone)
    tb.write(xPos, yPos+self.mode, ">")
  tb.display()

# コンティニューするかの選択
proc selectContinue(self:MenuWindow): bool =
  let actions: seq[string] = @[
    "Arrow key[Up, Down] : Select choices",
    "JK key : Select choices"
  ]
  game.instructionsWindow.drawActions(actions)
  self.drawChoices(@["Yes","No"])
  game.messageWindow.drawMessage("Do you want to continue?")
  self.mode = 0

  while(true):
    self.drawCursor()
    sleep(GET_KEY_SLEEP_MS)

    let key = getKey()
    case key
    of Key.Enter:
      break
    of Key.Up, Key.Down, Key.K, Key.J:
      if self.mode == 0:
        self.mode = 1
      elif self.mode == 1:
        self.mode = 0
    else: discard

  self.drawCursor(reset=true)
  if self.mode == 0: # Yes
    return true
  return false # No

#----------------------------------------------------------------
#               Instructions Window Impl
#----------------------------------------------------------------
proc init(_:type InstructionsWindow, dpdWin:MenuWindow): InstructionsWindow =
  result = InstructionsWindow()
  result.pos = Position(x:dpdWin.pos.x, y:dpdWin.pos.y+dpdWin.height+1)
  result.texts = @[]
  result.texts.add("Available actions")
  result.texts.add("_separator")
  result.width = WINDOW_WIDTH
  result.height = result.texts.len + 12 # 12=最低保証

# 画面描画
proc draw(self:InstructionsWindow): void =
  tb.setAttribute(fgCyan, bgNone)
  tb.drawRect(self.pos.x, self.pos.y, self.pos.x+self.width, self.pos.y+self.height)
  let
    xOffset: int = 2
    yOffset: int = 0
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  for i in 1..self.texts.len:
    if self.texts[i-1] == "_separator":
      tb.drawHorizLine(xPos, self.pos.x+self.width-2, yPos+i, doubleStyle=true)
    elif self.texts[i-1] == "_space":
      discard
    else:
      tb.write(xPos, yPos+i, self.texts[i-1])

# 可能な操作を描画
proc drawActions(self:InstructionsWindow, actions:seq[string]): void =
  self.resetActions()
  tb.setAttribute(fgYellow, bgNone)
  let
    xOffset: int = 2
    yOffset: int = self.texts.len + 1
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  for i, action in actions:
    tb.write(xPos, yPos+i, action)
  tb.display()

# 可能な操作を消す
proc resetActions(self:InstructionsWindow): void =
  tb.resetAttributes()
  let
    xOffset: int = 2
    yOffset: int = self.texts.len + 1
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  for i in 0..<self.height - yOffset:
    tb.write(xPos, yPos+i, " ".repeat(self.width-3))
  tb.display()

#----------------------------------------------------------------
#               Message Window Impl
#----------------------------------------------------------------
proc init(_:type MessageWindow, dpdWin:InstructionsWindow, mainWinWidth:int): MessageWindow =
  result = MessageWindow()
  result.pos = Position(x:1, y:dpdWin.pos.y+dpdWin.height+1)
  result.width = mainWinWidth+1+dpdWin.width
  result.height = 2

# 画面描画
proc draw(self:MessageWindow): void =
  tb.setAttribute(fgCyan, bgNone)
  tb.drawRect(self.pos.x, self.pos.y, self.pos.x+self.width, self.pos.y+self.height)

# メッセージを描画
proc drawMessage(self:MessageWindow, text:string, fg:ForegroundColor=fgYellow): void =
  self.resetMessage()
  tb.setAttribute(fg, bgNone)
  let
    xOffset: int = 1
    yOffset: int = 1
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  tb.write(xPos, yPos, text)
  tb.display()

# メッセージを消す
proc resetMessage(self:MessageWindow): void =
  tb.resetAttributes()
  let
    xOffset: int = 1
    yOffset: int = 1
    xPos: int = self.pos.x + xOffset
    yPos: int = self.pos.y + yOffset
  tb.write(xPos, yPos, " ".repeat(self.pos.x+self.width-2))

#----------------------------------------------------------------
#               MineSweeper Impl
#----------------------------------------------------------------
# プロパティに値をセットしたり
proc setting(self:MineSweeper, blc:int): void =
  self.blc = blc
  self.doubleBlc = blc*2
  self.makeBlocks()
  self.placeBombs()
  self.placedTotalFlags = 0
  self.remainingContinue = REMAINING_CONTINUE
  self.mainWindow = MainWindow.init(self)
  self.menuWindow = MenuWindow.init(self.mainWindow)
  self.instructionsWindow = InstructionsWindow.init(self.menuWindow)
  self.messageWindow = MessageWindow.init(self.instructionsWindow, self.mainWindow.width)

# まっさらなステージを作成
proc makeBlocks(self:MineSweeper): void =
  self.blocks = @[]
  var count: int = 1
  for i in 0..<self.blc:
    for j in 0..<self.blc:
      let cell = Blocks(id:count, x:j, y:i, isEmpty:false, status:"o", fg:fgWhite, bg:bgNone)
      self.blocks.add(cell)
      count.inc()

# 爆弾をランダムに配置
proc placeBombs(self:MineSweeper): void =
  var bombLimPerLine: int
  for i, lim in BLC_LIM_ARRAY: # 配列の長さによって爆弾の数を調整
    if self.blc <= lim:
      bombLimPerLine = BOMB_LIM_ARRAY[i]
      break
  
  randomize()
  var lines: int = 0
  for i in 0..<self.blc: # 行数分回す
    let bombsPerLine: int = rand(1..bombLimPerLine)
    self.remainingBombs += bombsPerLine

    var count: int = 0
    var overlap: seq[int] = @[] # 被った値を一時的に保存
    while(count < bombsPerLine): # 一行当たりの爆弾の数だけ回す
      let bombPos: int = rand(0..<self.blc)

      var isBombSamePos: bool = false
      for n in overlap:
        if bombPos == n: # 爆弾の位置が被ってたら
          isBombSamePos = true
          break
        if isBombSamePos:
          continue

      overlap.add(bombPos)
      self.blocks[lines*self.blc + bombPos].isBomb = true # (ラインの数*縦のブロック数)+爆弾の位置
      count.inc()

    lines.inc()

# 画面を描画
proc drawWindow(self:MineSweeper): void =
  clearTerminal()
  self.mainWindow.draw()
  self.menuWindow.draw()
  self.instructionsWindow.draw()
  self.messageWindow.draw()
  tb.display()

# メイン画面を作成
proc makeWindowLines(self:MineSweeper): WindowLines =
  result = WindowLines()
  var
    firstLine: seq[string] = @["   "]
    secondLine: seq[string] = @["  _"]
    line2D: seq[seq[string]] = newSeqWith(1, newSeq[string](1))
    count: int = 0

  for i in 1..self.blc: # 横の数だけ回す
    var line: seq[string] = newSeq[string](1)
    firstLine.add(fmt" {chr(64+i):>2}") # 一行目はA,B,C...という感じ
    secondLine.add("__") # 二行目はアンダーライン
    line.add(fmt"{$(i):>2}|")
    for _ in 1..self.blc: # 縦の数だけ回す
      line.add(fmt" {self.blocks[count].status}")
      count.inc()
    line2D.add(line)

  result.firstLine = concatSeq(firstLine)
  result.secondLine = concatSeq(secondLine)

  var isSkipElem: bool = true
  for elem in line2D:
    if isSkipElem:
      isSkipElem = false
      continue
    result.otherLines.add(concatSeq(elem))

# ゲームクリアしたかの判定
proc checkIfGamePassed(self:MineSweeper): bool =
  for cell in self.blocks:
    if not cell.isFlag:
      if cell.isBomb or not cell.isEmpty: # 旗が立っていない and (爆弾がある or 解放されていない) => クリアしてない
        return false
  return true

# ゲーム終了処理
proc endGame(self:MineSweeper): void =
  let actions: seq[string] = @[
    "Enter key : Exit the game",
    "Ctrl+c : Exit the game"
  ]
  self.instructionsWindow.drawActions(actions)

  var count: int = 0
  while(true):
    self.mainWindow.drawBomb(count)
    count.inc()
    sleep(90 - (self.blc*4))
    let key = getKey()
    case key
    of Key.Enter:
      break
    else: discard

# 旗を置く
proc placeFlag(self:MineSweeper, pos:int): void =
  tb.setAttribute(fgRed, bgNone)
  self.blocks[pos].setColor(fgRed, bgNone)
  self.blocks[pos].isFlag = true
  self.blocks[pos].status = "F"
  self.placedTotalFlags.inc()

# 旗を除ける
proc removeFlag(self:MineSweeper, pos:int): void =
  tb.resetAttributes()
  self.blocks[pos].resetColor()
  self.blocks[pos].isFlag = false
  self.blocks[pos].status = "o"
  self.placedTotalFlags.dec()

# マスを解放
proc releaseCell(self:MineSweeper, pos:int): void =
  self.blocks[pos].resetColor()
  self.blocks[pos].isEmpty = true
  let bombsAround: int = self.blocks[pos].bombsAround
  if bombsAround != 0:
    if bombsAround == 1:
      self.blocks[pos].setColor(fgCyan, bgNone)
    elif bombsAround == 2:
      self.blocks[pos].setColor(fgBlue, bgNone)
    elif bombsAround == 3:
      self.blocks[pos].setColor(fgGreen, bgNone)
    elif bombsAround == 4:
      self.blocks[pos].setColor(fgYellow, bgNone)
    else:
      self.blocks[pos].setColor(fgMagenta, bgNone)
    self.blocks[pos].status = $bombsAround
  else:
    self.blocks[pos].status = " "

# マス周囲の爆弾の数を数える
proc countBombAroundCell(self:MineSweeper, pos:int): void =
  let around: array[3, int] = [-1, 0, 1]
  var bombCount: int = 0
  for row in around:
    # xがメイン画面の左端の外 or xがメイン画面の右端の外だったらcontinue
    if self.mainWindow.cursor.x+row < 0 or self.mainWindow.cursor.x+row >= self.blc:
      continue
    for column in around:
      # yがメイン画面の上端の外 or yがメイン画面の下端の外だったらcontinue
      if self.mainWindow.cursor.y+column < 0 or self.mainWindow.cursor.y+column >= self.blc:
        continue
      if row == 0 and column == 0: # 自身のマスだったらcontinue
        continue

      try:
        if self.blocks[pos+row+(column*self.blc)].isBomb:
          bombCount.inc()
      except IndexDefect:
        continue

  self.blocks[pos].bombsAround = bombCount

#================================================================
#
#                      Utilization
#
#================================================================
# ゲーム初期化処理
proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer, blc:int, noColorFlag:bool): MineSweeper =
  tb = terminalbuffer
  isNoColor = noColorFlag
  let ms = MineSweeper()
  ms.setting(blc)
  game = ms
  return ms

# 一回だけ呼ばれる処理
proc start*(self:MineSweeper): void =
  self.drawWindow()
  # TODO: ここにゲームの更新を表示する処理

# ループ処理
proc update*(self:MineSweeper): bool =
  self.menuWindow.updateMenu() # メニュー画面更新

  let isPassed: bool = self.checkIfGamePassed() # ゲームクリア判定
  if isPassed:
    self.messageWindow.drawMessage("FINISH!!")
    self.endGame()
    return true

  self.mainWindow.moveCursor() # カーソル移動操作受付

  let isAbort: bool = self.menuWindow.selectChoices() # マスに対する操作選択受付
  if isAbort: # ESCでの中止
    self.messageWindow.resetMessage()
    return false

  let
    cellPos: int = self.mainWindow.cursor.y*self.blc + self.mainWindow.cursor.x # 二次元を一次元に調整
    cellBlock: Blocks = self.blocks[cellPos]
  
  if cellBlock.isEmpty: # マスが既に解放されているとき
    self.messageWindow.drawMessage("The cell has been already opened.")
    return false

  if self.menuWindow.mode == 0: # 旗を立てる/除ける
    if cellBlock.isFlag: # 旗が立っているとき
      self.removeFlag(cellPos)
      self.messageWindow.drawMessage("Removed the flag.")
    
    elif not cellBlock.isFlag: # 旗が立っていないとき
      if self.remainingBombs-self.placedTotalFlags == 0: # 全ての旗を立てたとき
        self.messageWindow.drawMessage("All flags has been placed.")
        return false
      self.placeFlag(cellPos)
      self.messageWindow.drawMessage("Placed the flag.")

  elif self.menuWindow.mode == 1: # マス目解放
    if cellBlock.isFlag: # 旗が立っているとき
      self.messageWindow.drawMessage("The flag has been already placed")
      return false
    
    elif cellBlock.isBomb: # 爆弾に当たった時
      self.messageWindow.drawMessage("Boom!!", fg=fgRed)
      tb.display()
      sleep(2000)

      var isContinue: bool = false
      if self.remainingContinue != 0:
        isContinue = self.menuWindow.selectContinue()
      if isContinue: # コンティニュー処理
        self.messageWindow.resetMessage()
        self.remainingContinue.dec()
        return false

      tb.setAttribute(fgRed, bgNone)
      self.messageWindow.drawMessage("Boom!!", fg=fgRed)
      tb.display()
      self.instructionsWindow.resetActions()
      self.mainWindow.drawGameOverAnimation()
      tb.setAttribute(fgRed, bgNone)
      self.messageWindow.drawMessage("GAME OVER", fg=fgRed)
      tb.display()
      self.endGame()
      return true

    self.countBombAroundCell(cellPos)
    self.releaseCell(cellPos)
    self.messageWindow.drawMessage("Released the cell.")

  let
    xOffset: int = 4
    yOffset: int = 2
    xPos: int = self.mainWindow.cursor.x*2 + xOffset
    yPos: int = self.mainWindow.cursor.y + yOffset
  tb.setAttribute(cellBlock.fg, cellBlock.bg)
  tb.write(xPos, yPos, cellBlock.status)
  tb.display()
  
  return false
