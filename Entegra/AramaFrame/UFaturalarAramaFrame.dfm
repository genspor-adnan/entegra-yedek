object FaturalarAramaFrame: TFaturalarAramaFrame
  Left = 0
  Top = 0
  Width = 312
  Height = 434
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBarAranan: TToolBar
    Left = 0
    Top = 0
    Width = 312
    Height = 28
    AutoSize = True
    ButtonHeight = 24
    ButtonWidth = 62
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
    List = True
    ParentColor = False
    ShowCaptions = True
    ParentFont = False
    TabOrder = 9
    Transparent = True
    object LabelTumKayitlar: TToolButton
      Left = 0
      Top = 0
      Caption = 'T'#252'm'
      ImageIndex = 32
      ImageName = 'PngImageListe'
    end
    object LabelSonArananlar: TToolButton
      Tag = 5
      Left = 62
      Top = 0
      Caption = 'Son'
      ImageIndex = 21
      ImageName = 'PngImage21'
    end
    object LabelSikArananlar: TToolButton
      Tag = 3
      Left = 124
      Top = 0
      Caption = 'S'#305'k'
      ImageIndex = 31
      ImageName = 'PngImageYildiz'
    end
  end
  object LabelPNO: TcxLabel
    Left = 0
    Top = 40
    Caption = '&Belge No'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label4: TcxLabel
    Left = 0
    Top = 64
    Caption = 'Cari &Kod/'#220'nvan'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label6: TcxLabel
    Left = 0
    Top = 141
    Caption = '&Notlar'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditCARIID: TcxLabel
    Left = 119
    Top = 225
  end
  object Panel1: TPanel
    Left = 2
    Top = 194
    Width = 198
    Height = 111
    TabOrder = 5
    object Label2: TcxLabel
      Left = 0
      Top = 3
      Caption = 'Ba'#351'lama'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label3: TcxLabel
      Left = 0
      Top = 29
      Caption = 'Biti'#351
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Calendar2: TcxDateEdit
      Left = 81
      Top = 29
      Properties.ImmediatePost = True
      TabOrder = 3
      Width = 115
    end
    object Calendar1: TcxDateEdit
      Left = 81
      Top = 2
      Properties.ImmediatePost = True
      TabOrder = 2
      Width = 115
    end
    object RbGunluk: TcxRadioButton
      Left = 77
      Top = 54
      Width = 92
      Height = 17
      Caption = 'Bug'#252'n'
      TabOrder = 4
      Transparent = True
    end
    object RbAylik: TcxRadioButton
      Left = 77
      Top = 94
      Width = 106
      Height = 17
      Caption = 'Bu Ay'
      TabOrder = 5
      Transparent = True
    end
    object RbHaftalik: TcxRadioButton
      Left = 77
      Top = 74
      Width = 115
      Height = 17
      Caption = 'Bu Hafta'
      TabOrder = 6
      Transparent = True
    end
  end
  object CheckTarihAralik: TcxCheckBox
    Left = 118
    Top = 168
    Caption = 'Tarih Aral'#305#287#305
    ParentFont = False
    State = cbsChecked
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clNavy
    Style.IsFontAssigned = True
    TabOrder = 6
    Transparent = True
  end
  object AraFaturaNo: TcxTextEdit
    Left = 83
    Top = 40
    TabOrder = 0
    Width = 115
  end
  object AraAciklama: TcxTextEdit
    Left = 83
    Top = 141
    TabOrder = 4
    Width = 115
  end
  object cxLabel1: TcxLabel
    Left = 0
    Top = 115
    Caption = #220'r'#252'n Kod/Ad'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraStok: TcxTextEdit
    Left = 83
    Top = 115
    TabOrder = 3
    Width = 115
  end
  object AraKod: TcxButtonEdit
    Left = 83
    Top = 64
    ParentShowHint = False
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end
      item
        Caption = '-'
        Hint = 'Temizle'
        Kind = bkText
      end>
    Properties.ReadOnly = False
    Properties.OnButtonClick = AraKodPropertiesButtonClick
    ShowHint = True
    TabOrder = 1
    OnKeyDown = AraKodKeyDown
    Width = 115
  end
  object cxLabel2: TcxLabel
    Left = 0
    Top = 89
    Caption = '&Ba'#351'l'#305'k'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraBaslik: TcxTextEdit
    Left = 83
    Top = 89
    TabOrder = 2
    Width = 115
  end
  object CheckEkAlanlarListelensin: TcxCheckBox
    Left = 3
    Top = 170
    Caption = 'Ek Alanlar Listele'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clNavy
    Style.TransparentBorder = False
    Style.IsFontAssigned = True
    TabOrder = 14
    Transparent = True
  end
end
