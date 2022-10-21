import random
import copy
from game.window import CLEAR, TIME


# ゲーム処理
class MineSweeper(object):
    def __init__(self) -> None:
        self.first: bool = True
        self.explainment: str = ''

    # ゲーム初期設定
    def setting(self, blc_num) -> None:
        self.blc_num = blc_num

        # 状態作成
        self._set_flag()
        # 爆弾配置
        self._set_bomb()

    # 状態作成
    def _set_flag(self) -> None:
        self.main_flag: list[int] = []
        for _ in range(self.blc_num):
            sub_list_1: list[int] = []
            for _ in range(self.blc_num):
                sub_list_1.append(None)
            self.main_flag.append(sub_list_1)

    # 爆弾配置    
    def _set_bomb(self) -> None:
        self.main_bomb = copy.deepcopy(self.main_flag)

        if self.blc_num < 8: i = 2
        elif self.blc_num < 10: i = 3
        elif self.blc_num < 12: i = 4
        elif self.blc_num < 14: i = 5
        elif self.blc_num < 16: i = 6
        elif self.blc_num < 18: i = 7
        elif self.blc_num <= 20: i = 8

        for num in range(self.blc_num):
            print(f"{num}列目")
            bombs = random.randint(1, i)
            print(f"爆弾数: {bombs}")

            count = 0
            while(count < bombs):
                exc = []
                bomb_pos = random.randint(0, self.blc_num)

                for n in exc:
                    if bomb_pos == n:
                        continue
                exc.append(bomb_pos)

                print(f"爆弾位置: {bomb_pos}")
                self.main_bomb[num][bomb_pos-1] = 'B'

                count += 1

    # ゲームスタート
    def start(self, Window:object) -> None:
        # 画面表示
        Window.show_window(self)

        # 旗を立てる
        if self.mode == 1:
            self._post_flag()
        # マス解放
        elif self.mode == 2:
            self._release_block()

        
        print(self.mode)
        print(self.mtr_row)
        print(self.mtr_column)
        print(' ')
        print(Window.main_window)
        print(' ')
        print(self.main_flag)
        print(' ')
        print(self.main_bomb)

    # 座標情報セット
    def set_matrix(self, row, column):
        # 行
        self.mtr_row = row
        # 列
        self.mtr_column = column
        
    # 旗を立てる
    def _post_flag(self):
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = True

    # マスを開放する
    def _release_block(self):
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