import random
import copy


# ゲーム処理クラス
class MineSweeper(object):
    def __init__(self) -> None:
        self.explainment: str = '' # ゲーム説明文
        self.blc_num: int = 0 # 縦横の配列の長さ
        self.main_flag: list[bool,int] = [] # 状態の二次元配列(解放されてないところはFalse、旗はTrue、解放されたところはNone)
        self.main_bomb: list[bool] = [] # 爆弾の配置の二次元配列(爆弾のあるところはTrue、ないところはFalse)
        self.mode: int = 0 # 操作(1は旗立て、2はマス解放)
        self.bomb_num: int = 0 # 爆弾総数
        self.flag_num: int = 0 # 旗総数

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
        for _ in range(self.blc_num):
            sub_list_1: list[int] = []
            for _ in range(self.blc_num):
                sub_list_1.append(False)
            self.main_flag.append(sub_list_1)

    # 爆弾配置    
    def _set_bomb(self) -> None:
        # main_flagからNoneの入った配列をコピー
        self.main_bomb: list[bool] = copy.deepcopy(self.main_flag)

        # 配列の長さによって爆弾の数を調整
        blc_lim: list[int] = [7, 9, 11, 13, 15, 17, 20]
        bomb_num: list[int] = [2, 3, 4, 5, 6, 7, 8]
        for c, lim in enumerate(blc_lim):
            if self.blc_num <= lim:
                i: int = bomb_num[c]
                break

        for num in range(self.blc_num):
            print(f"{num+1}列目") ########################################
            bombs = random.randint(1, i)
            self.bomb_num += bombs
            print(f"爆弾数: {bombs}") ########################################

            count: int = 0
            while(count < bombs):
                # 爆弾の位置を一時的に保存
                exc: list[int] = []
                bomb_pos: int = random.randint(1, self.blc_num)

                f: bool = False
                for n in exc:
                    # 爆弾の位置が被ってたらやり直し
                    if bomb_pos == n:
                        f: bool = True
                        break
                if f:
                    continue

                exc.append(bomb_pos)

                print(f"爆弾位置: {bomb_pos}") ########################################
                self.main_bomb[num][bomb_pos-1] = True

                count += 1

    # ゲーム更新
    def update(self, Window:object) -> None:
        # 画面表示
        Window.show_window(self)

        # 旗を立てるor除ける
        if self.mode == 1:
            f: bool = self.main_flag[self.mtr_row-1][self.mtr_column-1]
            if f is None: # 既にマスが解放されているとき
                Window.print("\n>>マスは既に解放されています。")
                return
                
            if not f: # 旗が立っていない時
                self._post_flag()
                Window.print("\n>>旗を立てました。")
            elif f: # 旗が既に立っているとき
                self._remove_flag()
                Window.print("\n>>旗を除けました。")
            
        # マス解放
        elif self.mode == 2:
            f: bool = self.main_flag[self.mtr_row-1][self.mtr_column-1]
            if f: # 既に旗が立っているとき
                Window.print("\n>>既に旗が立っています")
                return

            # 爆弾に当たったか
            if self.main_bomb[self.mtr_row-1][self.mtr_column-1] is True:
                Window.game_over()

            self._release_block()

        self._check_arround()

        Window.remake_window(self)
        
        print(f"Mode :{self.mode}")
        print(f"Selected row :{self.mtr_row}")
        print(f"Selected column :{self.mtr_column}")
        print(f"\n{Window.main_window}")
        print(f"\n{self.main_flag}")
        print(f"\n{self.main_bomb}")

        return False

    # 座標情報セット
    def set_matrix(self, row:int, column:int) -> None:
        self.mtr_row: int = row # 行
        self.mtr_column: int = column # 列
        
    # 旗を立てる
    def _post_flag(self) -> None:
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = True
        self.flag_num += 1

    def _remove_flag(self) -> None:
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = False
        self.flag_num -= 1

    # マスを開放する
    def _release_block(self) -> None:
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = None    

    # 解放されたマスの周りを調べる
    def _check_arround(self) -> None:
        arr: int = [-2, -1, 0]
        bomb_counter: int = 0
        for row in arr:
            if self.mtr_row+row < 0: # 行が-1のとき弾く
                continue
            for column in arr:
                if self.mtr_column+column < 0: # 列が-1のとき弾く
                    continue
                try:
                    if self.main_bomb[self.mtr_row+row][self.mtr_column+column] is True:
                        bomb_counter += 1
                except IndexError:
                    continue
        if bomb_counter != 0: # 周りに爆弾があるとき
            self.main_flag[self.mtr_row-1][self.mtr_column-1] = bomb_counter


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