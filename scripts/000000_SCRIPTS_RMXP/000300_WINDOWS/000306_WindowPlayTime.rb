#==============================================================================
# ■ Window_PlayTime
#------------------------------------------------------------------------------
# 　メニュー画面でプレイ時間を表示するウィンドウです。
#==============================================================================

class Window_PlayTime < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 160, 96)
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
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 120, 32, "Temps")
    @total_sec = Graphics.frame_count / Graphics.frame_rate
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    text = sprintf("%02d:%02d:%02d", hour, min, sec)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 32, 120, 32, text, 2)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if Graphics.frame_count / Graphics.frame_rate != @total_sec
      refresh
    end
  end
end
