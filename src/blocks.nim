type Blocks* = object
  number*: int
  x*: int # 横何マス目か
  y*: int # 縦何マス目か
  isFlag*: bool # 旗が立っているか
  isBomb*: bool # 爆弾のマスか(固定)
  isEmpty*: bool # 解放されているかどうか
  numAround*: int # 周りにいくつ爆弾があるか
  status*: string
