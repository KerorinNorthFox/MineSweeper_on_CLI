##########################
# current version = v1.0.0
##########################


from game.minesweeper import MineSweeper
from game.window import Window, CLEAR, TIME

# ゲーム作成
Game = MineSweeper()
GW = Window()

GW.explainment(Game)

# ゲーム初期設定
blc_num: iter = GW.setting()
Game.setting(next(blc_num))
next(blc_num)

# ゲーム開始
Game.start(GW)

