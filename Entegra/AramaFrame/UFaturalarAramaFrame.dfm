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
  object LabelPNO: TcxLabel
    Left = 0
    Top = 25
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
    Top = 49
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
    Top = 126
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
    Top = 210
  end
  object Panel1: TPanel
    Left = 2
    Top = 179
    Width = 198
    Height = 111
    TabOrder = 6
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
    Top = 153
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
    TabOrder = 7
    Transparent = True
  end
  object AraFaturaNo: TcxTextEdit
    Left = 83
    Top = 25
    TabOrder = 0
    Width = 115
  end
  object AraAciklama: TcxTextEdit
    Left = 83
    Top = 126
    TabOrder = 4
    Width = 115
  end
  object cxLabel1: TcxLabel
    Left = 0
    Top = 100
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
    Top = 100
    TabOrder = 3
    Width = 115
  end
  object AraKod: TcxButtonEdit
    Left = 83
    Top = 49
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
    Top = 74
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
    Top = 74
    TabOrder = 2
    Width = 115
  end
  object CheckEkAlanlarListelensin: TcxCheckBox
    Left = 3
    Top = 155
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
    TabOrder = 15
    Transparent = True
  end
end
