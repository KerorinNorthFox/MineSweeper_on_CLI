type Blocks* = object
  id*: int # ブロックの識別番号
  x*: int # 横何マス目か
  y*: int # 縦何マス目か
  isFlag: bool # 旗が立っているか
  isBomb*: bool # 爆弾のマスか
  isEmpty*: bool # 解放されているか
  bombsAround: int # 周りにある爆弾の数
  status*: string
