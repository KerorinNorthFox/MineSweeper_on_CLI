##########################
# current version = v1.0.2
##########################


from game.minesweeper import MineSweeper
from game.window import Window


# ゲーム作成
Game = MineSweeper()
GameWindow = Window()

# ゲーム説明
# GameWindow.explaining(Game.explaining)

# ゲーム開始:初期設定など
Game.start(GameWindow)

# ゲーム更新
while(True):
    f = Game.update(GameWindow)
    GameWindow.sleep()
    if f:
        break

