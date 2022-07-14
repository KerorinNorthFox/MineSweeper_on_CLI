import os


CLEAR = 'cls' if os.name == 'nt' else 'clear' # 実行os判別


class MineSweeper(object):
    def __init__(self) -> None:
        pass

    # ゲーム初期設定
    def setting(self):
        while(True):
            os.system(CLEAR)
            select = input(">>マス目の数を入力してください: ")
            try:
                select = int(select)
                break
            except:
                print(">>入力が間違っています。")
                continue
        # ゲーム画面作成
        self._set_window(select)

    # ゲーム画面作成
    def _set_window(self, select):
        self.main_window = []
        sub_list_1 = [' '] # 1行目
        sub_list_2 = [' '] # 2行目
        for num in range(select):
            sub_list_1.append(' ')
            sub_list_1.append(str(num+1))
            sub_list_2.append('')
            sub_list_2.append('_')
        self.main_window.append(sub_list_1)
        self.main_window.append(sub_list_2)
        # 3行目以降
        for num in range(select):
            sub_list_3 = []
            sub_list_3.append(str(num+1))
            sub_list_3.append('|')
            for _ in range(select):
                sub_list_3.append('o')
            self.main_window.append(sub_list_3)

    # ゲームスタート
    def start(self):
        os.system(CLEAR)
        # 画面表示
        self._show_window

    # 画面表示
    def _show_window(self):
        while(True):
            os.system(CLEAR)
            print(self.main_window)
            # 座標入力メニュー
            flag = self._matrix_input_menu()
            
    
    # 座標入力メニュー
    def _matrix_input_menu(self):
        while(True):
            print("\n~メニュー~\n1: 旗を立てる\n2: マスを開放する")
            select = input(":")
            if select.lower() == '1':
                pass
            elif select. lower() == '2':
                pass
            else:
                print("\n入力が間違っています")
                return False
            mtr = input("\n>>行→列の順で座標を入力してください(間にはコンマを打つ): ")
            mtr = mtr.replace(' ', '')
            try:
                mtr_list = mtr.split(',')
                self.mtr_row = int(mtr_list[0])
                self.mtr_column = int(mtr_list[1])
                break
            except:
                print(">>入力が間違っています。")
                continue

    # ゲーム説明
    def explainment(self):
        os.system(CLEAR)
        pass


def main():
    Game = MineSweeper()
    while(True):
        os.system(CLEAR)
        select = input(">>ゲーム説明を見ますか?[y/n]: ")
        if select.lower() == 'y':
            # ゲーム説明
            Game.explainment()
        elif select.lower() != 'n':
            print(">>入力が間違っています。")
            continue
        break
    # ゲーム初期設定
    Game.setting()
    # ゲーム開始
    Game.start()


if __name__ == '__main__':
    Game = MineSweeper()
    Game.setting()

#  1 2 3 4 5
#  _ _ _ _ _
#1|o o o o o
#2|o o o o o
#3|o o o 1 o
#4|o o 1 1 1  
#5|o o o 1 F