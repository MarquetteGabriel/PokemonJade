#==============================================================================
# ■ Window_Gold
#------------------------------------------------------------------------------
# 　ゴールドを表示するウィンドウです。
#==============================================================================

class Window_Gold < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 160, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    cx = contents.text_size($data_system.words.gold).width
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 120-cx-2, 32, $pokemon_party.money.to_s, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(124-cx, 0, cx, 32, $data_system.words.gold, 2)
  end
end
