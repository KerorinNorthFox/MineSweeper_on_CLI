import os
import time
import sys


CLEAR: str = 'cls' if os.name == 'nt' else 'clear' # 実行os判別
TIME: int = 2


# ゲーム画面クラス
class Window(object):
    def __init__(self):
        self.main_window: list[str] = [] # 画面を表示するための二次元配列(解放されてないマス目は'o'で表示)

    # ゲーム説明
    def explainment(self, exp:str) -> None:
        while(True):
            self.window_clear()
            is_see_exp: str = input(">>ゲーム説明を見ますか?[y/n]: ")

            if is_see_exp.lower() == 'y':
                self.print(exp)
                break
            elif is_see_exp.lower() == 'n':
                break

            self.print("\n>>入力が間違っています。")
            self.sleep()

    # 初期設定の入力
    def setting(self) -> int:
        while(True):
            self.window_clear()
            self.print("<-初期設定->")
            blc_num: str = input("\n>>マス目の数を入力してください(5以上20以下): ")
            
            try:
                blc_num: int = int(blc_num)
                if blc_num < 5 or blc_num > 20:
                    raise OutOfPredefinedNum()
                break
            except ValueError:
                self.print("\n>>数字を入力してください。")
            except OutOfPredefinedNum:
                self.print("\n>>数字が既定の範囲外です。")
            
            self.sleep()
        # ゲーム画面作成
        self._set_window(blc_num)

        yield blc_num

        self.print("\n>>ゲームを作成しました。\n")
        for i in range(3, 0, -1):
            print("\r開始まで... {}".format(i), end='', flush=True)
            self.sleep(t=1)
            
        yield 0

    # ゲーム画面作成
    def _set_window(self, blc_num:int) -> None:
        sub_list_1: list[str] = ['  '] # 1行目
        sub_list_2: list[str] = ['  '] # 2行目

        for num in range(blc_num):
            sub_list_1.append(' ')
            sub_list_1.append("%2s" % str(num+1))
            sub_list_2.append('___')
        
        self.main_window.append(sub_list_1)
        self.main_window.append(sub_list_2)

        # 3行目以降
        for num in range(blc_num):
            sub_list_3: list[str] = []
            sub_list_3.append("%2s" % str(num+1))
            sub_list_3.append('|')
            for _ in range(blc_num):
                sub_list_3.append(' o ')
            self.main_window.append(sub_list_3)

    # 画面表示
    def show_window(self, Game:object) -> None:
        while(True):
            self.window_clear()
            self.print(f"残り爆弾数 :{Game.bomb_num-Game.flag_num}\n")
            # リスト内要素を結合して出力
            for con in self.main_window:
                self.print(''.join(con))
            
            # 座標入力メニュー
            f: bool = self._matrix_input_menu(Game)
            
            if f: break

            self.print("\n>>入力が間違っています")
            self.sleep()

    # 座標入力メニュー
    def _matrix_input_menu(self, Game:object) -> bool:
        self.print("\n～メニュー～\n1: 旗を立てる/除ける\n2: マスを開放する")
        which_menu: str = input(":")
        
        if which_menu.lower() == '1':
            Game.mode: int = 1
        elif which_menu. lower() == '2':
            Game.mode: int = 2
        else:
            return False

        mtr: str = input("\n>>行→列の順で数字の座標を入力してください(数字の間にはコンマを打つ): ")
        mtr: str = mtr.replace(' ', '')
        
        try:
            mtr_list: list[str] = mtr.split(',')
            row: int = int(mtr_list[0]) # 行
            column: int = int(mtr_list[1]) # 列
            is_safe: bool = 0 < row or row <= Game.blc_num or 0 < column or column <= Game.blc_num
            if not is_safe:
                raise
        except:
            return False
        # 座標情報セット
        Game.set_matrix(row, column)
        return True

    # 画面再構築
    def remake_window(self, Game:object) -> None:
        add_row: int = 2
        add_column: int = 2
        for i, row_list in enumerate(Game.main_flag):
            for j, column in enumerate(row_list):
                print(f"{i} row, {j} column type :{type(column)}") ##################
                if column is True:
                    self.main_window[i+add_row][j+add_column] = "  F"
                elif column is False:
                    self.main_window[i+add_row][j+add_column] = "  o"
                elif column is None:
                    self.main_window[i+add_row][j+add_column] = "   "
                elif type(column) is int:
                    self.main_window[i+add_row][j+add_column] = f"  {column}"
                    
    # ゲームオーバー
    def game_over(self) -> None:
        self.print("\n>>ゲームオーバー\n>>終了します")
        sys.exit()

    # 画面クリア
    def window_clear(self) -> None:
        os.system(CLEAR)

    # スリープ
    def sleep(self, t:int=TIME) -> None:
        time.sleep(t)

    # 表示
    def print(self, text:str, end:str='\n') -> None:
        print(text, end=end)
        

class OutOfPredefinedNum(Exception):
    pass     

