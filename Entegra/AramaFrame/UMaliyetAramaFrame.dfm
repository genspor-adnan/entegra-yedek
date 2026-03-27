object MaliyetAramaFrame: TMaliyetAramaFrame
  Left = 0
  Top = 0
  Width = 233
  Height = 262
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  ExplicitWidth = 451
  ExplicitHeight = 304
  object cbHesaplamaYontemi: TcxImageComboBox
    Left = 77
    Top = 37
    RepositoryItem = Tablo.repStokMaliyetTipi
    EditValue = '1'
    Properties.Items = <
      item
        Description = 'Fifo'
        ImageIndex = 0
        Tag = 1
        Value = 1
      end>
    Properties.OnCloseUp = cbHesaplamaYontemiPropertiesCloseUp
    TabOrder = 0
    Width = 115
  end
  object cxLabel1: TcxLabel
    Left = 0
    Top = 39
    Caption = 'Hesaplama'
  end
  object Label4: TcxLabel
    Left = 0
    Top = 66
    Caption = '&Stok'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraKod: TcxButtonEdit
    Left = 77
    Top = 66
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
    Properties.ReadOnly = True
    Properties.OnButtonClick = AraKodPropertiesButtonClick
    ShowHint = True
    TabOrder = 2
    Width = 115
  end
  object EditCARIID: TcxLabel
    Left = 0
    Top = 149
  end
  object AraBitis: TcxDateEdit
    Left = 77
    Top = 117
    Properties.OnCloseUp = AraBitisPropertiesCloseUp
    TabOrder = 3
    Width = 115
  end
  object Label3: TcxLabel
    Left = 0
    Top = 117
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
  object cxLabel2: TcxLabel
    Left = 0
    Top = 91
    Caption = 'Depo'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cbDepo: TcxImageComboBox
    Left = 77
    Top = 90
    RepositoryItem = Tablo.RepStokDepolarAktif
    EditValue = '1'
    Properties.Items = <
      item
        Description = 'Fifo'
        ImageIndex = 0
        Tag = 1
        Value = 1
      end>
    Properties.OnCloseUp = cbHesaplamaYontemiPropertiesCloseUp
    TabOrder = 8
    Width = 115
  end
end
