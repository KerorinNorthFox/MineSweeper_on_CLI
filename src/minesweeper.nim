import
  illwill,
  std/os,
  std/strutils,
  ./blocks

var tb: TerminalBuffer

type MineSweeper* = ref object
  blocksSeq: seq[Blocks]
  blcNum*: int

proc clearTerminal(): void =
  tb.clear()
  tb.display()

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
        if number >= 5 and number <= 20:
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

proc setting(self:MineSweeper): void =
  discard

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

proc init*(_:type MineSweeper, terminalbuffer:var TerminalBuffer): MineSweeper =
  tb = terminalbuffer
  var game = MineSweeper(blcNum:0)
  game.inputSetting()
  game.setting()
  game.start()
