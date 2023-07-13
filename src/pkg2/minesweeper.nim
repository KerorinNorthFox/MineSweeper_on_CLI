import
  illwill,
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
type WindowLines = ref object
  firstLine: string
  secondLine: string
  otherLines: seq[string]

type
  MainWindow = ref object
    xPos: int
    yPos: int
    cursorXPos: int
    cursorYPos: int
    previousCursorXPos: int
    previousCursorYPos: int

  MenuWindow = ref object
    xPos: int
    yPos: int
    xPosEnd: int
    yPosEnd: int
    totalFlagText: string
    cursorPositionText: string
    remainingContinueText: string
    separatorYPos: int
    firstChoiceText: string
    firstChoiceYPos: int
    secondChoiceText: string
    secondChoiceYPos: int
    cursorPositionYPos: int
    totalFlagYPos: int
    remainingContinueYPos: int
    mode: int

  InstructionsWindow = ref object
    xPos: int
    yPos: int
    xPosEnd: int
    yPosEnd: int

  MessageWindow = ref object
    xPos: int
    yPos: int
    xPosEnd: int
    yPosEnd: int
    msgXPos: int
    msgYPos: int

type MineSweeper* = ref object
  blocks: seq[Blocks]
  totalFlags: int # 現在立っている旗の総数
  remainingBombs: int # 現在の残り爆弾総数
  blc: int # マス目縦/横の数
  doubleBlc: int
  remainingContinue: int # 残りコンティニュー数

  mainWindow: MainWindow
  menuWindow: MenuWindow
  instructionsWindow: InstructionsWindow
  messageWindow: MessageWindow

#----------------------------------------------------------------
#               Main Window Dec
#----------------------------------------------------------------
proc init(_:type MainWindow): MainWindow

#----------------------------------------------------------------
#               Menu Window Dec
#----------------------------------------------------------------
proc init(_:type MenuWindow): MenuWindow

#----------------------------------------------------------------
#               Instructions Window Dec
#----------------------------------------------------------------
proc init(_:type InstructionsWindow, m:MenuWindow): InstructionsWindow

#----------------------------------------------------------------
#               Message Window Dec
#----------------------------------------------------------------
proc init(_:type MessageWindow, i:InstructionsWindow): MessageWindow

#----------------------------------------------------------------
#               MineSweeper Dec
#----------------------------------------------------------------
proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer, blc:int): MineSweeper

# プロパティに値をセットしたり
proc setting(self:MineSweeper, blc:int): void

# ステージを作成
proc makeBlocks(self:MineSweeper): void

# 爆弾を配置
proc setBombs(self:MineSweeper): void

#================================================================
#
#                   implementation
#
#================================================================

#----------------------------------------------------------------
#               Main Window Impl
#----------------------------------------------------------------
proc init(_:type MainWindow): MainWindow =
  result = MainWindow()
  result.xPos = 0
  result.yPos = 0
  result.cursorXPos = 0
  result.cursorYPos = 0
  result.previousCursorXPos = 0
  result.previousCursorYPos = 0

#----------------------------------------------------------------
#               Menu Window Impl
#----------------------------------------------------------------
proc init(_:type MenuWindow): MenuWindow =
  result = MenuWindow()
  result.xPos = 5
  result.yPos = 1
  result.xPosEnd = 45
  result.yPosEnd = 8
  result.totalFlagText = "Remaining flags :"
  result.cursorPositionText = "Cursor position :"
  result.remainingContinueText = "Remaining continue :"
  result.separatorYPos = 4
  result.firstChoiceText = "Set/Remove the flag"
  result.firstChoiceYPos = 5
  result.secondChoiceText = "Set/Remove the flag"
  result.secondChoiceYPos = 6
  result.cursorPositionYPos = 1
  result.totalFlagYPos = 2
  result.remainingContinueYPos = 3

#----------------------------------------------------------------
#               Instructions Window Impl
#----------------------------------------------------------------
proc init(_:type InstructionsWindow, m:MenuWindow): InstructionsWindow =
  result = InstructionsWindow()
  result.xPos = m.xPos
  result.yPos = m.yPosEnd+1
  result.xPosEnd = m.xPosEnd
  result.yPosEnd = result.yPos+14

#----------------------------------------------------------------
#               Message Window Impl
#----------------------------------------------------------------
proc init(_:type MessageWindow, i:InstructionsWindow): MessageWindow =
  result = MessageWindow()
  result.xPos = 1

#----------------------------------------------------------------
#               MineSweeper Impl
#----------------------------------------------------------------
proc setting(self:MineSweeper, blc:int): void =
  self.blc = blc
  self.doubleBlc = blc*2
  self.makeBlocks()
  self.setBombs()
  self.totalFlags = 0
  self.remainingContinue = REMAINING_CONTINUE
  self.mainWindow = MainWindow.init()
  self.menuWindow = MenuWindow.init()
  self.instructionsWindow = InstructionsWindow.init(self.menuWindow)
  self.messageWindow = MessageWindow.init(self.instructionsWindow)

proc makeBlocks(self:MineSweeper): void =
  discard

proc setBombs(self:MineSweeper): void =
  discard


#================================================================
#
#                      Utilization
#
#================================================================
var
  tb: TerminalBuffer
  game: MineSweeper

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

proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer, blc:int): MineSweeper =
  tb = terminalbuffer
  var ms = MineSweeper()
  ms.setting(blc)
  game = ms
  return ms

proc start*(self:MineSweeper): void =
  discard

proc update*(self:MineSweeper): void =
  discard
