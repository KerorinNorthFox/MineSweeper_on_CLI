import illwill

type Blocks* = object
  id*: int # ブロックの識別番号
  x*: int # 横何マス目か
  y*: int # 縦何マス目か
  isFlag*: bool # 旗が立っているか
  isBomb*: bool # 爆弾のマスか
  isEmpty*: bool # 解放されているか
  bombsAround*: int # 周りにある爆弾の数
  status*: string
  fg*: ForegroundColor
  bg*: BackgroundColor

proc resetColor*(self:var Blocks): void =
  self.fg = fgWhite
  self.bg = bgNone

proc setColor*(self:var Blocks, fg:ForegroundColor, bg:BackgroundColor): void =
  self.fg = fg
  self.bg = bg

type Position* = object
  x*: int
  y*: int

type Cursor* = object
  x*: int
  y*: int
  preX*: int
  preY*: int

# ひとつ前のカーソル位置を更新
proc update(self:var Cursor): void =
  self.preX = self.x
  self.preY = self.y

proc moveRight*(self:var Cursor): void =
  self.update()
  self.x.inc()

proc moveLeft*(self:var Cursor): void =
  self.update()
  self.x.dec()

proc moveUp*(self:var Cursor): void =
  self.update()
  self.y.dec()

proc moveDown*(self:var Cursor): void =
  self.update()
  self.y.inc()

type Args* = ref object
  blockNum*: int
  defaultContinue*: int
  isInfinity*: bool
  isNoColor*: bool
  isNew*: bool