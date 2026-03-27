object TakvimAksiyonFrame: TTakvimAksiyonFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 440
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  ExplicitHeight = 304
  object DateTakvimBitTar: TcxDateEdit
    Left = 96
    Top = 28
    Properties.ImmediatePost = True
    TabOrder = 2
    Width = 81
  end
  object DateTakvimBasTar: TcxDateEdit
    Left = 0
    Top = 28
    Properties.ImmediatePost = True
    TabOrder = 0
    Width = 81
  end
  object CheckGroupSecim: TcxRadioGroup
    Left = 0
    Top = 49
    Caption = 'T'#252'r'
    ParentFont = False
    Properties.ImmediatePost = True
    Properties.Items = <
      item
        Caption = 'Planlar'
        Value = '0'
      end
      item
        Caption = 'Faturalar'
        Value = '1'
      end
      item
        Caption = #214'demeler'
        Value = '2'
      end>
    Properties.WordWrap = True
    ItemIndex = 0
    Style.BorderStyle = ebsUltraFlat
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 4
    Transparent = True
    Height = 74
    Width = 177
  end
  object GiderFiltreCheck: TcxCheckGroup
    Left = 0
    Top = 129
    Caption = 'Gider Filtre '
    EditValue = ';0,1,2,3,4,5,6'
    ParentBackground = False
    ParentFont = False
    Properties.Items = <
      item
        Caption = #214'deme Plan'#305
      end
      item
        Caption = 'Kredi Kart'#305
        Tag = 1
      end
      item
        Caption = #199'ekimiz'
        Tag = 2
      end
      item
        Caption = 'Senetimiz'
        Tag = 3
      end
      item
        Caption = 'Gider Kalem (B'#252't'#231'e)'
        Tag = 7
      end
      item
        Caption = 'Kredi/Leasing'
        Tag = 5
      end
      item
        Caption = 'Maa'#351
      end>
    Properties.ReadOnly = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clRed
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 5
    Height = 158
    Width = 177
  end
  object DateGrafikBitTar: TcxDateEdit
    Left = 90
    Top = 28
    Properties.ImmediatePost = True
    TabOrder = 3
    Width = 87
  end
  object DateGrafikBasTar: TcxDateEdit
    Left = 0
    Top = 28
    Properties.ImmediatePost = True
    TabOrder = 1
    Width = 81
  end
  object GelirFiltreCheck: TcxCheckGroup
    Left = 0
    Top = 292
    Caption = 'Gelir Filtre'
    EditValue = ';0,1,2,3,4'
    ParentBackground = False
    ParentFont = False
    Properties.Items = <
      item
        Caption = 'Tahsilat Plan'#305
      end
      item
        Caption = 'POS'
      end
      item
        Caption = 'M'#252#351'teri '#199'eki'
      end
      item
        Caption = 'M'#252#351'teri Seneti'
      end
      item
        Caption = 'Gelir Kalem (B'#252't'#231'e)'
        Tag = 6
      end>
    Properties.ReadOnly = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clGreen
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 6
    Height = 124
    Width = 177
  end
  object YenileTus: TcxButton
    Left = 0
    Top = 1
    Width = 90
    Height = 25
    Caption = 'Yenile'
    OptionsImage.ImageIndex = 8
    OptionsImage.Images = Tablo.imgScheduler
    TabOrder = 7
  end
end
