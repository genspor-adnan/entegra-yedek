object odemeSekliEslemeForm: TodemeSekliEslemeForm
  Left = 0
  Top = 0
  Width = 452
  Height = 348
  AutoScroll = False
  TabOrder = 0
  object Label1: TLabel
    Left = 6
    Top = 6
    Width = 71
    Height = 13
    Caption = 'E'#351'le'#351'me Listesi'
  end
  object Bevel1: TBevel
    Left = 6
    Top = 216
    Width = 439
    Height = 19
    Shape = bsBottomLine
  end
  object GroupBox1: TGroupBox
    Left = 6
    Top = 246
    Width = 439
    Height = 97
    Caption = 'Kay'#305't Ekle/D'#252'zenle'
    TabOrder = 4
    object Label2: TLabel
      Left = 12
      Top = 18
      Width = 100
      Height = 13
      Caption = 'GenoTIP '#214'deme Tipi'
    end
    object Label3: TLabel
      Left = 162
      Top = 18
      Width = 81
      Height = 13
      Caption = 'Logo '#214'deme Tipi'
    end
    object Label4: TLabel
      Left = 282
      Top = 18
      Width = 86
      Height = 13
      Caption = 'Logo Hesap Kodu'
    end
    object genotipOdemeTipiComboBox: TComboBox
      Left = 12
      Top = 36
      Width = 139
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        'Nakit'
        #199'ek'
        'Senet'
        'Kredi Kart'#305)
    end
    object logoOdemeTipiComboBox: TComboBox
      Left = 162
      Top = 36
      Width = 109
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        '(E'#351'leme)'
        'Nakit'
        #199'ek'
        'Senet'
        'Kredi Kart'#305)
    end
    object logoHesapKoduEdit: TEdit
      Left = 282
      Top = 36
      Width = 121
      Height = 21
      TabOrder = 2
    end
    object kaydetButton: TButton
      Left = 252
      Top = 66
      Width = 75
      Height = 25
      Caption = 'Kaydet'
      TabOrder = 3
      OnClick = kaydetButtonClick
    end
    object iptalButton: TButton
      Left = 330
      Top = 66
      Width = 75
      Height = 25
      Caption = #304'ptal'
      TabOrder = 4
      OnClick = iptalButtonClick
    end
  end
  object eslemeListView: TListView
    Left = 6
    Top = 24
    Width = 439
    Height = 157
    Columns = <
      item
        Caption = 'GenoTIP '#214'deme Tipi'
        Width = 120
      end
      item
        Caption = 'Logo '#214'deme Tipi'
        Width = 120
      end
      item
        Caption = 'Logo Hesap Kodu'
        Width = 100
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = eslemeListViewDblClick
    OnSelectItem = eslemeListViewSelectItem
  end
  object ekleButton: TButton
    Left = 6
    Top = 186
    Width = 75
    Height = 25
    Caption = 'Ekle...'
    TabOrder = 1
    OnClick = ekleButtonClick
  end
  object silButton: TButton
    Left = 162
    Top = 186
    Width = 75
    Height = 25
    Caption = 'Sil...'
    Enabled = False
    TabOrder = 3
    OnClick = silButtonClick
  end
  object degistirButton: TButton
    Left = 84
    Top = 186
    Width = 75
    Height = 25
    Caption = 'De'#287'i'#351'tir...'
    Enabled = False
    TabOrder = 2
    OnClick = degistirButtonClick
  end
end
