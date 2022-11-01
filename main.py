##########################
# current version = v1.0.0
##########################


from game.minesweeper import MineSweeper
from game.window import Window


# ゲーム作成
Game = MineSweeper()
GW = Window()

# ゲーム説明
GW.explainment(Game.explainment)

# ゲーム初期設定
blc_num: iter = GW.setting()
Game.setting(next(blc_num))
next(blc_num)

# ゲーム開始
Game.start(GW)

