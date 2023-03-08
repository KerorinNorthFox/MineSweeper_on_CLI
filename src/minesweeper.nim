import
  illwill,
  std/os,
  std/strutils,
  ./blocks

type MineSweeper* = ref object
  blcNum*: int

proc inputSetting(self:MineSweeper, tb:var TerminalBuffer): void =
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
          tb.clear()
          tb.display()
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

proc init*(_:type MineSweeper, tb:var TerminalBuffer): MineSweeper =
  var game = MineSweeper(blcNum:0)
  game.inputSetting(tb)

  