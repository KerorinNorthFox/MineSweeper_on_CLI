import random
import copy


# ゲーム処理
""" このクラスに属する変数一覧
self.first :
self.explainment :ゲーム説明文
self.blc_num :縦横の配列の長さ
self.main_flag :状態の二次元配列(解放されてないところはFalse、旗はTrue、解放されたところはNone)
self.main_bomb :爆弾の配置の二次元配列(爆弾のあるところはTrue、ないところはFalse)
"""
class MineSweeper(object):
    def __init__(self) -> None:
        self.first: bool = True
        self.explainment: str = ''

    # ゲームスタート:初期設定など
    def start(self, Window:object) -> None:
        blc_num: iter = Window.setting()
        self._setting(next(blc_num))
        next(blc_num)

    # ゲーム初期設定
    def _setting(self, blc_num:int) -> None:
        self.blc_num: int = blc_num

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
                sub_list_1.append(False)
            self.main_flag.append(sub_list_1)

    # 爆弾配置    
    def _set_bomb(self) -> None:
        # main_flagからNoneの入った配列をコピー
        self.main_bomb: list[None] = copy.deepcopy(self.main_flag)

        # 配列の長さによって爆弾の数を調整
        blc_lim: list[int] = [7, 9, 11, 13, 15, 17, 20]
        bomb_num: list[int] = [2, 3, 4, 5, 6, 7, 8]
        for c, lim in enumerate(blc_lim):
            if self.blc_num <= lim:
                i: int = bomb_num[c]
                break

        for num in range(self.blc_num):
            print(f"{num}列目") ########################################
            bombs = random.randint(1, i) ########################################
            print(f"爆弾数: {bombs}") ########################################

            count: int = 0
            while(count < bombs):
                # 爆弾の位置を一時的に保存
                exc: list[int] = []
                bomb_pos: int = random.randint(0, self.blc_num)

                for n in exc:
                    # 爆弾の位置が被ってたらやり直し
                    if bomb_pos == n:
                        continue
                exc.append(bomb_pos)

                print(f"爆弾位置: {bomb_pos}") ########################################
                self.main_bomb[num][bomb_pos-1] = True

                count += 1

    # ゲーム更新
    def update(self, Window:object) -> None:
        # 画面表示
        Window.show_window(self)

        # 旗を立てる
        if self.mode == 1:
            self._post_flag()
        # マス解放
        elif self.mode == 2:
            self._release_block()
            # 爆弾に当たったか
            if self.main_bomb[self.mtr_row-1][self.mtr_column-1]:
                Window.game_over()

        
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
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = None    


# テスト用
if __name__ == '__main__':
    Game = MineSweeper()
    Game._setting()
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