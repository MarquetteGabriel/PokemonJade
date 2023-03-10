#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :map_bgm                  # マップ画面 BGM (バトル時記憶用)
  attr_accessor :message_text             # メッセージ 文章
  attr_accessor :message_proc             # メッセージ コールバック (Proc)
  attr_accessor :choice_start             # 選択肢 開始行
  attr_accessor :choice_max               # 選択肢 項目数
  attr_accessor :choice_cancel_type       # 選択肢 キャンセルの場合
  attr_accessor :choice_proc              # 選択肢 コールバック (Proc)
  attr_accessor :num_input_start          # 数値入力 開始行
  attr_accessor :num_input_variable_id    # 数値入力 変数 ID
  attr_accessor :num_input_digits_max     # 数値入力 桁数
  attr_accessor :message_window_showing   # メッセージウィンドウ表示中
  attr_accessor :common_event_id          # コモンイベント ID
  attr_accessor :in_battle                # 戦闘中フラグ
  attr_accessor :battle_calling           # バトル 呼び出しフラグ
  attr_accessor :battle_troop_id          # バトル トループ ID
  attr_accessor :battle_can_escape        # バトル 逃走可能フラグ
  attr_accessor :battle_can_lose          # バトル 敗北可能フラグ
  attr_accessor :battle_proc              # バトル コールバック (Proc)
  attr_accessor :battle_turn              # バトル ターン数
  attr_accessor :battle_event_flags       # バトル イベント実行済みフラグ
  attr_accessor :battle_abort             # バトル 中断フラグ
  attr_accessor :battle_main_phase        # バトル メインフェーズフラグ
  attr_accessor :battleback_name          # バトルバック ファイル名
  attr_accessor :forcing_battler          # アクション強制対象のバトラー
  attr_accessor :shop_calling             # ショップ 呼び出しフラグ
  attr_accessor :shop_goods               # ショップ 商品リスト
  attr_accessor :name_calling             # 名前入力 呼び出しフラグ
  attr_accessor :name_actor_id            # 名前入力 アクター ID
  attr_accessor :name_max_char            # 名前入力 最大文字数
  attr_accessor :menu_calling             # メニュー 呼び出しフラグ
  attr_accessor :menu_beep                # メニュー SE 演奏フラグ
  attr_accessor :save_calling             # セーブ 呼び出しフラグ
  attr_accessor :debug_calling            # デバッグ 呼び出しフラグ
  attr_accessor :player_transferring      # プレイヤー場所移動フラグ
  attr_accessor :player_new_map_id        # プレイヤー移動先 マップ ID
  attr_accessor :player_new_x             # プレイヤー移動先 X 座標
  attr_accessor :player_new_y             # プレイヤー移動先 Y 座標
  attr_accessor :player_new_direction     # プレイヤー移動先 向き
  attr_accessor :transition_processing    # トランジション処理中フラグ
  attr_accessor :transition_name          # トランジション ファイル名
  attr_accessor :gameover                 # ゲームオーバーフラグ
  attr_accessor :to_title                 # タイトル画面に戻すフラグ
  attr_accessor :last_file_index          # 最後にセーブしたファイルの番号
  attr_accessor :debug_top_row            # デバッグ画面 状態保存用
  attr_accessor :debug_index              # デバッグ画面 状態保存用
  attr_accessor :god_mode
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @map_bgm = nil
    @message_text = nil
    @message_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_start = 99
    @num_input_variable_id = 0
    @num_input_digits_max = 0
    @message_window_showing = false
    @common_event_id = 0
    @in_battle = false
    @battle_calling = false
    @battle_troop_id = 0
    @battle_can_escape = false
    @battle_can_lose = false
    @battle_proc = nil
    @battle_turn = 0
    @battle_event_flags = {}
    @battle_abort = false
    @battle_main_phase = false
    @battleback_name = ''
    @forcing_battler = nil
    @shop_calling = false
    @shop_id = 0
    @name_calling = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_calling = false
    @menu_beep = false
    @save_calling = false
    @debug_calling = false
    @player_transferring = false
    @player_new_map_id = 0
    @player_new_x = 0
    @player_new_y = 0
    @player_new_direction = 0
    @transition_processing = false
    @transition_name = ""
    @gameover = false
    @to_title = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
    @god_mode = false
  end
end
