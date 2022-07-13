import os


CLEAR = 'cls' if os.name == 'nt' else 'clear' # 実行os判別


class MineSweeper(object):
    def __init__(self) -> None:
        pass

    # ゲーム初期設定
    def setting(self):
        while(True):
            select = input(">>マス目の数を入力してください: ")
            try:
                select = int(select)
                break
            except:
                print(">>入力が間違っています。")
                continue
        # ゲーム画面作成
        self._set_window(select)
        print(self.ms_list)

    # ゲーム画面作成
    def _set_window(self, select):
        self.ms_list = []
        sub_list_1 = [' '] # 1行目
        sub_list_2 = [' '] # 2行目
        for num in range(select):
            sub_list_1.append(' ')
            sub_list_1.append(str(num+1))
            sub_list_2.append('')
            sub_list_2.append('_')
        self.ms_list.append(sub_list_1)
        self.ms_list.append(sub_list_2)
        # 3行目以降
        for num in range(select):
            sub_list_3 = []
            sub_list_3.append(str(num+1))
            sub_list_3.append('|')
            for _ in range(select):
                sub_list_3.append('o')
            self.ms_list.append(sub_list_3)

    # ゲームスタート
    def start(self):
        pass

    # ゲーム説明
    def explainment(self):
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
    os.system(CLEAR)
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