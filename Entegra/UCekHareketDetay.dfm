object CekHareketDetayDlg: TCekHareketDetayDlg
  Left = 0
  Top = 0
  Caption = #199'ek Hareket Bilgileri'
  ClientHeight = 267
  ClientWidth = 522
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxLabel1: TcxLabel
    Left = 310
    Top = 19
    Caption = 'Tarih:'
    Transparent = True
  end
  object DateTarih: TcxDateEdit
    Left = 348
    Top = 18
    Properties.OnEditValueChanged = DateTarihPropertiesEditValueChanged
    TabOrder = 1
    OnKeyUp = DateTarihKeyUp
    Width = 127
  end
  object EdDovizTutari: TcxCurrencyEdit
    Left = 100
    Top = 46
    RepositoryItem = Tablo.RepCurrencyGenel
    Properties.OnEditValueChanged = EdDovizTutariPropertiesEditValueChanged
    TabOrder = 2
    OnKeyUp = EdDovizTutariKeyUp
    Width = 127
  end
  object ServisHarPanelAlt: TPanel
    Left = 0
    Top = 229
    Width = 522
    Height = 38
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      522
      38)
    object KaydetTus: TBitBtn
      Left = 374
      Top = 6
      Width = 72
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Uygula'
      Default = True
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000D30E0000D30E00000001000000010000008C00000094
        0000009C000000A5000000940800009C100000AD100000AD180000AD210000B5
        210000BD210018B5290000C62900319C310000CE310029AD390031B5420018C6
        420000D6420052A54A0029AD4A0029CE5A006BB5630000FF63008CBD7B00A5C6
        94005AE7A500FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF001B1B1B1B1B13
        04161B1B1B1B1B1B1B1B1B1B1B1B1B0B0A01181B1B1B1B1B1B1B1B1B1B1B160A
        0C030D1B1B1B1B1B1B1B1B1B1B1B050E0C0601191B1B1B1B1B1B1B1B1B130E0C
        170E02001B1B1B1B1B1B1B1B1B0B1517170A0C01181B1B1B1B1B1B1B1B111717
        13130C030D1B1B1B1B1B1B1B1B1B08081B1B070C01191B1B1B1B1B1B1B1B1B1B
        1B1B100C02001B1B1B1B1B1B1B1B1B1B1B1B1B090C01181B1B1B1B1B1B1B1B1B
        1B1B1B130C0F101B1B1B1B1B1B1B1B1B1B1B1B1B141A0F181B1B1B1B1B1B1B1B
        1B1B1B1B1012181B1B1B1B1B1B1B1B1B1B1B1B1B1B191B1B1B1B1B1B1B1B1B1B
        1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B}
      TabOrder = 0
      OnClick = KaydetTusClick
    end
    object IptalTus: TBitBtn
      Left = 452
      Top = 6
      Width = 62
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Kapa&t'
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000220B0000220B000000010000000100000031DE000031
        E7000031EF000031F700FF00FF000031FF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00040404040404
        0404040404040404000004000004040404040404040404000004040000000404
        0404040404040000040404000000000404040404040000040404040402000000
        0404040400000404040404040404000000040000000404040404040404040400
        0101010004040404040404040404040401010204040404040404040404040400
        0201020304040404040404040404030201040403030404040404040404050203
        0404040405030404040404040303050404040404040303040404040303030404
        0404040404040403040403030304040404040404040404040404030304040404
        0404040404040404040404040404040404040404040404040404}
      ModalResult = 2
      TabOrder = 1
      OnClick = IptalTusClick
    end
  end
  object LabelDovizTuru: TcxLabel
    Left = 51
    Top = 73
    Cursor = crHandPoint
    Caption = 'Kar'#351#305'l'#305#287#305':'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clNavy
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.HotTrack = False
    Style.TextColor = clBlack
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
    OnClick = LabelDovizTuruClick
  end
  object cxLabel3: TcxLabel
    Left = 0
    Top = 44
    Caption = 'Yerel '#304#351'lem Tutar'#305':'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object PanelKarsilik: TPanel
    Left = 98
    Top = 73
    Width = 383
    Height = 21
    Align = alCustom
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 6
    object EditKulKur: TcxCurrencyEdit
      Left = 198
      Top = 0
      TabStop = False
      RepositoryItem = Tablo.RepCurrencyDovizKuru
      EditValue = 1.000000000000000000
      ParentFont = False
      Properties.DisplayFormat = ',0.0000;(,0.0000)'
      Properties.EditFormat = ',0.0000;(,0.0000)'
      Properties.Nullable = False
      Properties.UseDisplayFormatWhenEditing = True
      Properties.OnEditValueChanged = EditKulKurPropertiesEditValueChanged
      Style.Color = clInactiveCaption
      TabOrder = 0
      OnKeyUp = EditKulKurKeyUp
      Width = 62
    end
    object cbKur: TcxComboBox
      Left = 135
      Top = 0
      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
      Properties.OnEditValueChanged = cbKurPropertiesEditValueChanged
      TabOrder = 1
      OnKeyUp = cbKurKeyUp
      Width = 57
    end
    object EdTutar: TcxCurrencyEdit
      Left = 2
      Top = 0
      RepositoryItem = Tablo.RepCurrencyGenel
      Properties.OnEditValueChanged = EdTutarPropertiesEditValueChanged
      TabOrder = 2
      Width = 127
    end
    object CheckExtredeKullan: TcxCheckBox
      Left = 258
      Top = 2
      Caption = 'Ekstrede Bunu Kullan'
      TabOrder = 3
      Width = 121
    end
  end
  object CbDovizKuru: TcxComboBox
    Left = 233
    Top = 46
    RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
    Enabled = False
    TabOrder = 7
    Width = 57
  end
  object memoAciklama: TcxMemo
    Left = 100
    Top = 100
    TabOrder = 8
    Height = 61
    Width = 375
  end
  object cxLabel2: TcxLabel
    Left = 43
    Top = 100
    Caption = 'A'#231#305'klama:'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLabel4: TcxLabel
    Left = 34
    Top = 18
    Caption = #199'ek Tutar'#305':'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object edCekTutar: TcxCurrencyEdit
    Left = 100
    Top = 18
    RepositoryItem = Tablo.RepCurrencyGenel
    Enabled = False
    TabOrder = 11
    Width = 127
  end
  object cbCekKur: TcxComboBox
    Left = 233
    Top = 18
    RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
    Enabled = False
    TabOrder = 12
    Width = 57
  end
  object edIsKur: TcxCurrencyEdit
    Left = 296
    Top = 46
    TabStop = False
    RepositoryItem = Tablo.RepCurrencyDovizKuru
    EditValue = 1.000000000000000000
    ParentFont = False
    Properties.DisplayFormat = ',0.0000;(,0.0000)'
    Properties.EditFormat = ',0.0000;(,0.0000)'
    Properties.Nullable = False
    Properties.UseDisplayFormatWhenEditing = True
    Properties.OnEditValueChanged = edIsKurPropertiesEditValueChanged
    Style.Color = clInactiveCaption
    TabOrder = 13
    OnKeyUp = edIsKurKeyUp
    Width = 62
  end
  object BeditProje: TcxButtonEdit
    Left = 100
    Top = 191
    ParentShowHint = False
    Properties.Buttons = <
      item
        Caption = '++'
        Default = True
        Hint = 'Ekle'
        Kind = bkText
      end
      item
        Caption = '+'
        Hint = 'Sil'
        Kind = bkText
      end
      item
        Caption = '-'
        Kind = bkText
      end>
    Properties.ReadOnly = True
    Properties.OnButtonClick = BeditProjePropertiesButtonClick
    ShowHint = True
    Style.BorderStyle = ebsOffice11
    Style.LookAndFeel.Kind = lfStandard
    Style.LookAndFeel.NativeStyle = False
    StyleDisabled.LookAndFeel.Kind = lfStandard
    StyleDisabled.LookAndFeel.NativeStyle = False
    StyleFocused.LookAndFeel.Kind = lfStandard
    StyleFocused.LookAndFeel.NativeStyle = False
    StyleHot.LookAndFeel.Kind = lfStandard
    StyleHot.LookAndFeel.NativeStyle = False
    TabOrder = 14
    Width = 375
  end
  object cxLabel5: TcxLabel
    Left = 60
    Top = 191
    Caption = 'Proje:'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditMM: TcxButtonEdit
    Left = 100
    Top = 167
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
    Properties.OnButtonClick = EditMMPropertiesButtonClick
    TabOrder = 16
    Width = 375
  end
  object cxLabel6: TcxLabel
    Left = 22
    Top = 167
    Caption = 'Masraf Kalemi'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
end
