object BankaKredileriAramaFrame: TBankaKredileriAramaFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object btnSil: TcxButton
    Left = 117
    Top = 26
    Width = 21
    Height = 19
    Caption = #209
    TabOrder = 0
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Wingdings 2'
    Font.Style = []
    ParentFont = False
    OnClick = btnSilClick
  end
  object AraKod: TcxTextEdit
    Left = 0
    Top = 25
    TabOrder = 1
    Width = 115
  end
  object cxLabel1: TcxLabel
    Left = 0
    Top = 3
    Caption = 'Kod/Ad'#305':'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object ToolBarAranan: TToolBar
    Left = 0
    Top = 52
    Width = 451
    Height = 43
    AutoSize = True
    ButtonHeight = 39
    ButtonWidth = 61
    Caption = 'AletCubugu'
    Color = clTeal
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList2
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 2
    Transparent = True
    object LabelTumKayitlar: TToolButton
      Left = 0
      Top = 0
      Caption = 'T'#252'm Liste'
      ImageIndex = 20
      ImageName = 'PngImage20'
    end
    object LabelSonArananlar: TToolButton
      Tag = 5
      Left = 61
      Top = 0
      Caption = 'Son Aranan'
      ImageIndex = 21
      ImageName = 'PngImage21'
    end
    object LabelSikArananlar: TToolButton
      Tag = 3
      Left = 122
      Top = 0
      Caption = 'S'#305'k Aranan'
      ImageIndex = 6
      ImageName = 'PngImage6'
    end
  end
end
