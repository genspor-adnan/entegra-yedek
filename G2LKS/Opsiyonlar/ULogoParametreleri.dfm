object logoParametreleriForm: TlogoParametreleriForm
  Left = 0
  Top = 0
  Width = 266
  Height = 291
  TabOrder = 0
  object Label1: TLabel
    Left = 6
    Top = 10
    Width = 111
    Height = 13
    Caption = 'Sunucu Ad'#305' (veya IP) : '
  end
  object Label2: TLabel
    Left = 6
    Top = 60
    Width = 50
    Height = 13
    Caption = #350'irket No :'
  end
  object Label3: TLabel
    Left = 6
    Top = 82
    Width = 81
    Height = 13
    Caption = 'Logo '#214'zel Kodu :'
  end
  object Label4: TLabel
    Left = 6
    Top = 34
    Width = 48
    Height = 13
    Caption = 'Veritaban'#305
  end
  object Label6: TLabel
    Left = 6
    Top = 131
    Width = 77
    Height = 13
    Caption = 'Sat'#305#351' Fatura Tipi'
  end
  object Label7: TLabel
    Left = 6
    Top = 155
    Width = 84
    Height = 13
    Caption = 'Fatura Kalemi Tipi'
  end
  object sunucuAdiEdit: TEdit
    Left = 120
    Top = 6
    Width = 133
    Height = 21
    TabOrder = 0
  end
  object sirketNoSpinEdit: TcxSpinEdit
    Left = 120
    Top = 54
    Properties.DisplayFormat = '000'
    Properties.EditFormat = '000'
    Properties.MaxValue = 99.000000000000000000
    Properties.MinValue = 1.000000000000000000
    Style.LookAndFeel.Kind = lfStandard
    StyleDisabled.LookAndFeel.Kind = lfStandard
    StyleFocused.LookAndFeel.Kind = lfStandard
    StyleHot.LookAndFeel.Kind = lfStandard
    TabOrder = 2
    Value = 1
    Width = 43
  end
  object logoOzelKoduEdit: TEdit
    Left = 120
    Top = 78
    Width = 133
    Height = 21
    TabOrder = 3
  end
  object veritabaniEdit: TEdit
    Left = 120
    Top = 30
    Width = 133
    Height = 21
    TabOrder = 1
  end
  object kasaIslemTipiComboBox: TComboBox
    Left = 120
    Top = 104
    Width = 135
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    Items.Strings = (
      'Perakende Sat'#305#351' Faturas'#305
      'Toptan Sat'#305#351' Faturas'#305
      'Verilen Hizmet Faturas'#305)
  end
  object satisFaturaTipiComboBox: TComboBox
    Left = 120
    Top = 128
    Width = 135
    Height = 21
    Style = csDropDownList
    TabOrder = 5
    Items.Strings = (
      'Perakende Sat'#305#351' Faturas'#305
      'Toptan Sat'#305#351' Faturas'#305
      'Verilen Hizmet Faturas'#305)
  end
  object faturaKalemiTipiComboBox: TComboBox
    Left = 120
    Top = 152
    Width = 135
    Height = 21
    Style = csDropDownList
    TabOrder = 6
    Items.Strings = (
      'Malzeme'
      'Hizmet')
  end
  object nakitIcinKasaIslemiEkleCheckBox: TCheckBox
    Left = 5
    Top = 106
    Width = 108
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Kasa '#304#351'lem Tipi'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object kasaIslemiCariKullanCheckBox: TCheckBox
    Left = 5
    Top = 185
    Width = 244
    Height = 17
    Caption = 'Kasa '#304#351'lemlerinde Cari Kullan'#305'ls'#305'n'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object faturaNoIcinBelgeNoKullan: TCheckBox
    Left = 5
    Top = 209
    Width = 244
    Height = 17
    Caption = 'FaturaNo i'#231'in Belge No kullan'
    Checked = True
    State = cbChecked
    TabOrder = 9
  end
end
