import os
import time


CLEAR: str = 'cls' if os.name == 'nt' else 'clear' # 実行os判別
TIME: int = 2


class MineSweeper(object):
    def __init__(self) -> None:
        self.first = True

    # ゲーム初期設定
    def setting(self) -> None:
        while(True):
            os.system(CLEAR)
            print("<-初期設定->")
            select: str = input("\n>>マス目の数を入力してください: ")
            try:
                select: int = int(select)
                break
            except:
                print("\n>>入力が間違っています。")
                time.sleep(TIME)
                continue

        # ゲーム画面作成
        self._set_window(select)
        # 状態作成
        self._set_flag(select)

        print("\n>>ゲームを作成しました。\n")
        for i in range(3, 0, -1):
            print("\r開始まで... {}".format(i), end='', flush=True)
            time.sleep(1)
        
    # ゲーム画面作成
    def _set_window(self, select:int) -> None:
        self.main_window: list[str] = []
        sub_list_1: list[str] = [' '] # 1行目
        sub_list_2: list[str] = [' '] # 2行目

        for num in range(select):
            sub_list_1.append(' ')
            sub_list_1.append(str(num+1))
            sub_list_2.append('__')
        
        self.main_window.append(sub_list_1)
        self.main_window.append(sub_list_2)

        # 3行目以降
        for num in range(select):
            sub_list_3: list[str] = []
            sub_list_3.append(str(num+1))
            sub_list_3.append('|')
            for _ in range(select):
                sub_list_3.append('o')
                sub_list_3.append(' ')
            self.main_window.append(sub_list_3)

    # 状態作成
    def _set_flag(self, select:int) -> None:
        self.main_flag: list[int] = []
        for _ in range(select):
            sub_list_1: list[int] = []
            for _ in range(select):
                sub_list_1.append(0)
            self.main_flag.append(sub_list_1)

    # ゲームスタート
    def start(self) -> None:
        os.system(CLEAR)
        # 画面表示
        self._show_window()

        # 旗を立てる
        if self.mode == 1:
            self._post_flag()
            
        # マス解放
        elif self.mode == 2:
            self._release_block()
        print(self.mode)
        print(self.mtr_row)
        print(self.mtr_column)

    # 画面表示
    def _show_window(self) -> None:
        while(True):
            os.system(CLEAR)
            # TO DO: リスト内要素を結合して出力
            for num in self.main_window:
                print(''.join(num))
            # 座標入力メニュー
            flag: bool = self._matrix_input_menu()
            if flag:
                break
    
    # 座標入力メニュー
    def _matrix_input_menu(self) -> bool:
        print("\n～メニュー～\n1: 旗を立てる\n2: マスを開放する")
        select: str = input(":")
        if select.lower() == '1':
            self.mode: int = 1
        elif select. lower() == '2':
            self.mode: int = 2
        else:
            print("\n>>入力が間違っています")
            time.sleep(TIME)
            return False
        mtr: str = input("\n>>行→列の順で数字の座標を入力してください(数字の間にはコンマを打つ): ")
        mtr: str = mtr.replace(' ', '')
        try:
            mtr_list: list[str] = mtr.split(',')
            self.mtr_row: int = int(mtr_list[0])
            self.mtr_column: int = int(mtr_list[1])
        except:
            print("\n>>入力が間違っています。")
            time.sleep(TIME)
            return False
        return True

    # 旗を立てる
    def _post_flag(self):
        pass

    # マスを開放する
    def _release_block(self):
        pass

    # ゲーム説明
    def explainment(self) -> None:
        os.system(CLEAR)
        pass


def main():
    Game = MineSweeper()
    while(True):
        os.system(CLEAR)
        select: str = input(">>ゲーム説明を見ますか?[y/n]: ")
        if select.lower() == 'y':
            # ゲーム説明
            Game.explainment()
        elif select.lower() != 'n':
            print("\n>>入力が間違っています。")
            time.sleep(TIME)
            continue
        break
    # ゲーム初期設定
    Game.setting()
    # ゲーム開始
    Game.start()


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