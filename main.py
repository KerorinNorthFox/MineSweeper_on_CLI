##########################
# current version = v1.0.0
##########################


from game.minesweeper import MineSweeper
from game.window import Window, CLEAR, TIME

# ゲーム作成
Game = MineSweeper()
GWindow = Window()

GWindow.explainment(Game)

# ゲーム初期設定
blc_num: iter = GWindow.setting()
Game.setting(next(blc_num))
next(blc_num)
# ゲーム開始
GWindow.start(Game)

