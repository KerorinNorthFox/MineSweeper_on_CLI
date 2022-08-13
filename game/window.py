from inspect import _void
import os
import time


CLEAR: str = 'cls' if os.name == 'nt' else 'clear' # 実行os判別
TIME: int = 2


# ゲーム画面
class Window(object):
    # 説明
    def  explainment(self, Game) -> None:
        while(True):
            os.system(CLEAR)
            select: str = input(">>ゲーム説明を見ますか?[y/n]: ")
            if select.lower() == 'y':
                # ゲーム説明
                print(Game.explainment)
            elif select.lower() != 'n':
                print("\n>>入力が間違っています。")
                time.sleep(TIME)
                continue
            break

    def setting(self) -> int:
        os.system(CLEAR)
        print("<-初期設定->")
        blc_num: str = input("\n>>マス目の数を入力してください(5以上20以下): ")
        while(True):
            try:
                blc_num: int = int(blc_num)
                if blc_num < 5 or blc_num > 20:
                    raise
                break
            except:
                print("\n>>入力が間違っています。")
                time.sleep(TIME)
                continue

        yield blc_num

        print("\n>>ゲームを作成しました。\n")
        for i in range(3, 0, -1):
            print("\r開始まで... {}".format(i), end='', flush=True)
            time.sleep(1)
            
        yield None

    # ゲームスタート
    def start(self, Game) -> None:
        os.system(CLEAR)
        # 画面表示
        self._show_window()

        # 旗を立てる
        if self.mode == 1:
            Game.post_flag()
        # マス解放
        elif self.mode == 2:
            Game.release_block()

        
        print(self.mode)
        print(Game.mtr_row)
        print(Game.mtr_column)

    # 画面表示
    def _show_window(self, Game) -> None:
        while(True):
            os.system(CLEAR)
            # リスト内要素を結合して出力
            for num in Game.main_window:
                print(''.join(num))
            
            # 座標入力メニュー
            flag: bool = self._matrix_input_menu(Game)
            
            if not flag:
                print("\n>>入力が間違っています")
                time.sleep(TIME)
            else:
                break

    # 座標入力メニュー
    def _matrix_input_menu(self, Game) -> bool:
        print("\n～メニュー～\n1: 旗を立てる\n2: マスを開放する")
        select: str = input(":")
        
        if select.lower() == '1':
            self.mode: int = 1
        elif select. lower() == '2':
            self.mode: int = 2
        else:
            return False

        mtr: str = input("\n>>行→列の順で数字の座標を入力してください(数字の間にはコンマを打つ): ")
        mtr: str = mtr.replace(' ', '')
        
        try:
            mtr_list: list[str] = mtr.split(',')
            row: int = int(mtr_list[0]) # 行
            column: int = int(mtr_list[1]) # 列
            if row > Game.blc_num or column > Game.blc_num:
                raise
        except:
            return False
            # 座標情報セット
        Game.set_matrix(row, column)
        return True

        