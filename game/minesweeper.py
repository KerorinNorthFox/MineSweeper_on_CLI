import random
import copy


# ゲーム処理クラス
class MineSweeper(object):
    def __init__(self) -> None:
        self.explaining: str = '' # ゲーム説明文
        # self.first: bool = True
        self.continue_num: int = 3
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
        blc_lim_list: list[int] = [7, 9, 11, 13, 15, 17, 20]
        bomb_num_list: list[int] = [2, 3, 4, 5, 6, 7, 8]
        for c, lim in enumerate(blc_lim_list):
            if self.blc_num <= lim:
                i: int = bomb_num_list[c]
                break

        for num in range(self.blc_num):
            bomb_num = random.randint(1, i)
            self.bomb_num += bomb_num

            count: int = 0
            # 爆弾の位置を一時的に保存
            exc: list[int] = []
            while(count < bomb_num):
                bomb_pos: int = random.randint(1, self.blc_num)

                is_bomb_same_pos: bool = False
                for n in exc:
                    # 爆弾の位置が被ってたらやり直し
                    if bomb_pos == n:
                        is_bomb_same_pos: bool = True
                        break
                if is_bomb_same_pos:
                    continue

                exc.append(bomb_pos)

                self.main_bomb[num][bomb_pos-1] = True

                count += 1

    # ゲーム更新
    def update(self, Window:object) -> None:
        is_passed: bool = self._check_game_is_passed()
        if is_passed: # ゲームクリアしたかチェック
            Window.game_passed_animation(self)
            Window.game_passed()

        # 画面表示
        Window.show_window(self)

        # 旗を立てるor除ける時
        if self.mode == 1:
            flag_state: bool = self.main_flag[self.mtr_row-1][self.mtr_column-1]
            if flag_state is None or type(flag_state) is int: # 既にマスが解放されているとき
                Window.print("\n>>マスは既に解放されています。")
                return
            elif not flag_state: # 旗が立っていない時
                if self.bomb_num-self.flag_num == 0:
                    Window.print("\n>>旗は全て立っています。間違えているところがありませんか?")
                    return
                self._post_flag()
                Window.print("\n>>旗を立てました。")
            elif flag_state: # 旗が既に立っているとき
                self._remove_flag()
                Window.print("\n>>旗を除けました。")
            
        # マス解放の時
        elif self.mode == 2:
            flag_state: bool = self.main_flag[self.mtr_row-1][self.mtr_column-1]
            if flag_state: # 既に旗が立っているとき
                Window.print("\n>>既に旗が立っています")
                return

            if self.main_bomb[self.mtr_row-1][self.mtr_column-1] is True: # 爆弾に当たったか
                if self.continue_num == 0:
                    Window.game_over_animation(self)
                    Window.game_over() # ゲームオーバー
                
                Window.print(f"\n>>爆弾が爆発!!")
                Window.sleep(t=1)
                while(True):
                    Window.print(f"\n>>残りコンティニュー回数は{self.continue_num}回です")
                    is_continue = input(">>コンティニューしますか?\ny :はい\nn :いいえ\n:")
                    
                    if is_continue == 'y':
                        self.continue_num -= 1
                        return False
                    elif is_continue == 'n':
                        Window.game_over_animation(self)
                        Window.game_over()
                    else:
                        Window.print("\n>>入力が間違っています")
                        Window.window_clear()
                        Window.sleep()
            
            self._release_block() # マス解放
            Window.print("\n>>マスを解放しました")
            self._check_around_blc() # マスの周りの爆弾を数える

            # if self.first:
            #     print("\n最初") ##################
            #     self._check_around_if_first() # 最初の時マス周りの空白を空ける
            #     self.first = False

        
        Window.refresh_window(self) # 画面再構築

        return False

    # 座標情報をセットする: DONE
    def set_matrix(self, row:int, column:int) -> None:
        self.mtr_row: int = row # 行
        self.mtr_column: int = column # 列
        
    # 旗を立てる: DONE
    def _post_flag(self) -> None:
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = True
        self.flag_num += 1

    # 旗を除ける: DONE
    def _remove_flag(self) -> None:
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = False
        self.flag_num -= 1

    # マスを開放する: DONE
    def _release_block(self) -> None:
        self.main_flag[self.mtr_row-1][self.mtr_column-1] = None    

    # 解放されたマスの周りを調べる: DONE
    def _check_around_blc(self) -> None:
        arr: list[int] = [-2, -1, 0]
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

    # ゲームクリアしたかチェック: DONE
    def _check_game_is_passed(self) -> bool:
        count: int = 0
        for flag_row_list, bomb_row_list in zip(self.main_flag, self.main_bomb):
            for flag_column, bomb_column in zip(flag_row_list, bomb_row_list):
                if flag_column is True and bomb_column is True:
                    count += 1
        
        if count == self.bomb_num:
            return True

        return False

    # 最初の時マス周りの空白を空ける
    def _check_around_if_first(self) -> None:
        no_bomb_list_around_mtr: list[tuple[int]] = []
        arr: list[int] = [-2, 1, 0]
        for row in arr:
            if self.mtr_row+row < 0: # 行が-1のとき弾く
                continue

            for column in arr:
                if self.mtr_column+column < 0: # 列が-1のとき弾く
                    continue
                f: bool = (row == -2 or row == 0) and (column == -2 or column == 0)
                if f:
                    continue

                try:
                    if self.main_bomb[self.mtr_row+row][self.mtr_column+column] is False:
                        no_bomb_list_around_mtr.append((self.mtr_row+row, self.mtr_column+column))
                except IndexError:
                    continue
        
        self._next_no_bomb_mtr(no_bomb_list_around_mtr)

    def _next_no_bomb_mtr(self, no_bomb_list_old:list[tuple[int]]):
        # if no_bomb_list_old is None:
        #     return None

        no_bomb_around_mtr: list[tuple[int]] = []
        arr: list[int] = [-2, 1, 0]
        count: int = 0
        for yet in no_bomb_list_old:
            for row in arr:
                if yet[0]+row < 0: # 行が-1のとき弾く
                    continue

                for column in arr:
                    if yet[1]+column < 0: # 列が-1のとき弾く
                        continue
                    f: bool = (row == -2 or row == 0) and (column == -2 or column == 0)
                    if f:
                        continue

                    try:
                        if self.main_bomb[yet[0]+row][yet[1]+column] is None:
                            no_bomb_around_mtr.append((yet[0]+row, yet[1]+column))
                            count += 1
                    except IndexError:
                        continue
        
        if count == 0:
            return

        return self._next_no_bomb_mtr(no_bomb_around_mtr)


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