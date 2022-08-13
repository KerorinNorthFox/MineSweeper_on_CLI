import os
import time
from game.window import CLEAR, TIME


# ゲーム処理
class MineSweeper(object):
    def __init__(self) -> None:
        self.first: bool = True
        self.explainment: str = ''

    # ゲーム初期設定
    def setting(self, blc_num) -> None:
        self.blc_num = blc_num

        # ゲーム画面作成
        self._set_window(self.blc_num)
        # 状態作成
        self._set_flag(self.blc_num)

    # ゲーム画面作成
    def _set_window(self, select:int) -> None:
        self.main_window: list[str] = []
        sub_list_1: list[str] = ['  '] # 1行目
        sub_list_2: list[str] = ['  '] # 2行目

        for num in range(select):
            sub_list_1.append(' ')
            sub_list_1.append("%2s" % str(num+1))
            sub_list_2.append('___')
        
        self.main_window.append(sub_list_1)
        self.main_window.append(sub_list_2)

        # 3行目以降
        for num in range(select):
            sub_list_3: list[str] = []
            sub_list_3.append("%2s" % str(num+1))
            sub_list_3.append('|')
            for _ in range(select):
                sub_list_3.append(' o ')
            self.main_window.append(sub_list_3)

    # 状態作成
    def _set_flag(self, select:int) -> None:
        self.main_flag: list[int] = []
        for _ in range(select):
            sub_list_1: list[int] = []
            for _ in range(select):
                sub_list_1.append(None)
            self.main_flag.append(sub_list_1)
    
    # 座標情報セット
    def set_matrix(self, row, column):
        # 行
        self.mtr_row = row
        # 列
        self.mtr_column = column
        
    # 旗を立てる
    def post_flag(self):
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = True

    # マスを開放する
    def release_block(self):
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = False

    # 画面再構築
    def remake_window(self):
        pass


# テスト用
if __name__ == '__main__':
    Game = MineSweeper()
    Game.setting()
    for num in Game.main_window:
        print(''.join(num))
    print(Game.main_flag)

#  1 2 3 4 5
#  _ _ _ _ _
#1|o o o o o
#2|o o o o o
#3|o o o 1 o
#4|o o 1 1 1  
#5|o o o 1 F