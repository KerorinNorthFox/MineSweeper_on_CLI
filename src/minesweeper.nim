import
  illwill,
  ./blocks

type MineSweeper* = ref object
  blcNum: int

proc inputSetting(self:MineSweeper, tb:TerminalBuffer): void =
  discard

proc init*(_:type MineSweeper, tb:TerminalBuffer): MineSweeper =
  var game = MineSweeper()
  game.inputSetting(tb)
  