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

# ゲーム開始:初期設定など
Game.start(GW)

# ゲーム更新
Game.update(GW)

