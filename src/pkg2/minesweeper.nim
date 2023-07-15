import
  illwill,
  std/strutils,
  std/strformat,
  std/sequtils,
  std/tables,
  std/random,
  ./blocks

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
  REMAINING_CONTINUE: int = 3

#----------------------------------------------------------------
#                   Types
#----------------------------------------------------------------
type
  WindowLines = ref object
    firstLine: string
    secondLine: string
    otherLines: seq[string]

  Position = object
    x: int
    y: int

  TextTable = ref object
    text: Table[string,string]
    position: Table[string,int]

type
  MainWindow = ref object
    winPos: Position
    cursor: Position
    width: int
    height: int

  MenuWindow = ref object
    winPos: Position
    texts: TextTable

  InstructionsWindow = ref object

  MessageWindow = ref object

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

#----------------------------------------------------------------
#               Main Window Dec
#----------------------------------------------------------------
proc init(_:type MainWindow, ms:MineSweeper): MainWindow

proc draw(self:MainWindow): void

proc drawGameOverAnimation(self:MainWindow): void

proc drawBomb(self:MainWindow, i:int): void

proc updateOldCursorPos(self:MainWindow): void

proc drawCursor(self:MainWindow): void

proc moveCursor(self:MainWindow): void

#----------------------------------------------------------------
#               Menu Window Dec
#----------------------------------------------------------------
proc init(_:type MenuWindow, dpdWin:MainWindow): MenuWindow

proc draw(self:MenuWindow): void

proc drawChoices(self:MenuWindow, xPos, yPos:int, firstText, secondText:string): void

proc drawRemainingFlags(self:MenuWindow): void

proc drawRemainingContinues(self:MenuWindow): void

proc drawMenuCursor(self:MenuWindow): void

proc drawCursor(self:MenuWindow, reset:bool=false): void

proc selectChoices(self:MenuWindow): void

proc selectContinue(self:MenuWindow): void

#----------------------------------------------------------------
#               Instructions Window Dec
#----------------------------------------------------------------
proc init(_:type InstructionsWindow, m:MenuWindow): InstructionsWindow

proc draw(self:InstructionsWindow): void

proc drawActions(self:InstructionsWindow, actions:seq[string]): void

proc resetActions(self:InstructionsWindow): void

#----------------------------------------------------------------
#               Message Window Dec
#----------------------------------------------------------------
proc init(_:type MessageWindow, i:InstructionsWindow): MessageWindow

proc draw(self:MessageWindow): void

proc drawMsg(self:MessageWindow, text:string): void

proc resetMsg(self:MessageWindow): void

#----------------------------------------------------------------
#               MineSweeper Dec
#----------------------------------------------------------------
proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer, blc:int): MineSweeper

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
  result.winPos = Position(x:0, y:0)
  result.cursor = Position(x:0, y:0) # TODO:
  result.width = ms.doubleBlc+3
  result.height = ms.blc+3

# メイン画面描画
proc draw(self:MainWindow): void =
  tb.resetAttributes()
  let lines: WindowLines = game.makeWindowLines()
  tb.write(self.winPos.x, self.winPos.y, lines.firstLine)
  tb.write(self.winPos.x, self.winPos.y+1, lines.secondLine)
  for i, line in lines.otherLines:
    tb.write(self.winPos.x, self.winPos.y+2+i, line)

# ゲームオーバー時のアニメーションを表示
proc drawGameOverAnimation(self:MainWindow): void =
  discard

# 爆弾を描画
proc drawBomb(self:MainWindow, i:int): void =
  discard

# ひとつ前のカーソル位置を更新
proc updateOldCursorPos(self:MainWindow): void =
  discard

# カーソルを描画
proc drawCursor(self:MainWindow): void =
  discard

# カーソルを移動
proc moveCursor(self:MainWindow): void =
  discard

#----------------------------------------------------------------
#               Menu Window Impl
#----------------------------------------------------------------
proc init(_:type MenuWindow, dpdWin: MainWindow): MenuWindow =
  result = MenuWindow()
  result.winPos = Position(x:dpdWin.width+2, y:1)
  result.texts = TextTable()
  result.texts.text = initTable[string,string]()
  # Template: result.texts.text[""] = ""
  result.texts.text["CursorPosition"] = "Cursor position :"
  result.texts.text["RemainingFlags"] = "Remaining flags :"
  result.texts.text["RemainingContinue"] = "Remaining continue :"
  result.texts.position = initTable[string,int]()
  # Template: result.texts.position[""] = 0

# 画面描画
proc draw(self:MenuWindow): void =
  tb.resetAttributes()
  # tb.drawRect(self.winPos.x, self.winPos.y)
  # tb.write(self.winPos.x, self.winPos.y)

# 選択肢を描画
proc drawChoices(self:MenuWindow, xPos, yPos:int, firstText, secondText:string): void =
  discard

# 残り旗数を描画
proc drawRemainingFlags(self:MenuWindow): void =
  discard

# 残りコンティニュー数を描画
proc drawRemainingContinues(self:MenuWindow): void =
  discard

# カーソル座標をメニューに描画
proc drawMenuCursor(self:MenuWindow): void =
  discard

# メニュー選択カーソルを描画
proc drawCursor(self:MenuWindow, reset:bool=false): void =
  discard

# メニュー選択
proc selectChoices(self:MenuWindow): void =
  discard

# コンティニューするかの選択
proc selectContinue(self:MenuWindow): void =
  discard

#----------------------------------------------------------------
#               Instructions Window Impl
#----------------------------------------------------------------
proc init(_:type InstructionsWindow, m:MenuWindow): InstructionsWindow =
  result = InstructionsWindow()

# 画面描画
proc draw(self:InstructionsWindow): void =
  discard

# 可能な操作を描画
proc drawActions(self:InstructionsWindow, actions:seq[string]): void =
  discard

# 可能な操作を消す
proc resetActions(self:InstructionsWindow): void =
  discard

#----------------------------------------------------------------
#               Message Window Impl
#----------------------------------------------------------------
proc init(_:type MessageWindow, i:InstructionsWindow): MessageWindow =
  result = MessageWindow()

# 画面描画
proc draw(self:MessageWindow): void =
  discard

# メッセージを描画
proc drawMsg(self:MessageWindow, text:string): void =
  discard

# メッセージを消す
proc resetMsg(self:MessageWindow): void =
  discard

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
  self.messageWindow = MessageWindow.init(self.instructionsWindow)

# まっさらなステージを作成
proc makeBlocks(self:MineSweeper): void =
  self.blocks = @[]
  var count: int = 1
  for i in 0..<self.blc:
    for j in 0..<self.blc:
      let cell = Blocks(id:count, x:j, y:i, isEmpty:false, status:"o")
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
    line.add(fmt"{$(i):>2}")
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
  discard

# ゲーム終了処理
proc endGame(self:MineSweeper): void =
  discard

# 旗を置く
proc placeFlag(self:MineSweeper, pos:int): void =
  discard

# 旗を除ける
proc removeFlag(self:MineSweeper, pos:int): void =
  discard

# マスを解放
proc releaseCell(self:MineSweeper, pos:int): void =
  discard

# マス周囲の爆弾の数を数える
proc countBombAroundCell(self:MineSweeper, pos:int): void =
  discard

#================================================================
#
#                      Utilization
#
#================================================================

proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer, blc:int): MineSweeper =
  tb = terminalbuffer
  var ms = MineSweeper()
  ms.setting(blc)
  game = ms
  return ms

proc start*(self:MineSweeper): void =
  self.drawWindow()
  # TODO: ここにゲームの更新を表示する処理

proc update*(self:MineSweeper): void =
  discard
