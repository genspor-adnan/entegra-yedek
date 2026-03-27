object ParaDegisiklikDlg: TParaDegisiklikDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Tutar De'#287'i'#351'ikli'#287'i'
  ClientHeight = 224
  ClientWidth = 449
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object AltPanel: TJvPanel
    Left = 0
    Top = 183
    Width = 449
    Height = 41
    FlatBorder = True
    Align = alBottom
    BorderWidth = 1
    TabOrder = 2
    DesignSize = (
      449
      41)
    object iptalButton: TButton
      Left = 365
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 1
    end
    object tamamButton: TButton
      Left = 284
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Tamam'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = tamamButtonClick
    end
  end
  object UstPanel: TJvPanel
    Left = 0
    Top = 0
    Width = 449
    Height = 57
    FlatBorder = True
    Align = alTop
    BorderWidth = 1
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Label1: TLabel
      Left = 9
      Top = 37
      Width = 314
      Height = 13
      Caption = #304#351'lem tutar'#305'nda yapmak istedi'#287'iniz de'#287'i'#351'iklikleri giriniz.'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object BaslikLabel: TLabel
      Left = 9
      Top = 8
      Width = 185
      Height = 25
      Caption = 'Tutar De'#287'i'#351'ikli'#287'i'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object JvPanel1: TJvPanel
    Left = 0
    Top = 57
    Width = 449
    Height = 126
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object cxRadioGroup1: TcxRadioGroup
      Left = 233
      Top = 16
      Caption = 'Kur Se'#231'imi'
      Properties.Columns = 2
      Properties.Items = <
        item
        end
        item
        end
        item
        end
        item
        end>
      Properties.OnChange = cxRadioGroup1PropertiesChange
      TabOrder = 0
      Visible = False
      Height = 57
      Width = 207
    end
    object EditKulKur: TcxCurrencyEdit
      Left = 321
      Top = 78
      TabStop = False
      ParentFont = False
      Properties.DecimalPlaces = 4
      Properties.DisplayFormat = ',0.0000;(,0.0000)'
      Properties.OnChange = EditKulKurPropertiesChange
      TabOrder = 1
      Visible = False
      Width = 119
    end
    object cxLabel2: TcxLabel
      Left = 233
      Top = 79
      Caption = 'Kullan'#305'lacak Kur: '
      Properties.WordWrap = True
      Transparent = True
      Visible = False
      Width = 88
    end
    object PanelTutar: TPanel
      Left = 1
      Top = 1
      Width = 220
      Height = 124
      Align = alLeft
      TabOrder = 3
      object LabelKur: TcxLabel
        Left = 5
        Top = 16
        Caption = 'Yeni Kur: '
        Transparent = True
      end
      object LabelTutar: TcxLabel
        Left = 84
        Top = 16
        Caption = 'Yeni Tutar: '
        Transparent = True
      end
      object EditTutar: TcxCurrencyEdit
        Left = 81
        Top = 33
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        TabOrder = 2
        Width = 121
      end
      object ComboKur: TcxComboBox
        Left = 5
        Top = 33
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        Properties.DropDownListStyle = lsFixedList
        Properties.ReadOnly = False
        Properties.OnEditValueChanged = ComboKurPropertiesEditValueChanged
        TabOrder = 3
        Width = 52
      end
      object EditDovTutar: TcxCurrencyEdit
        Left = 81
        Top = 80
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        TabOrder = 4
        Visible = False
        Width = 121
      end
      object ComboDovKur: TcxComboBox
        Left = 6
        Top = 80
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        Properties.DropDownListStyle = lsFixedList
        Properties.ReadOnly = False
        Properties.OnCloseUp = ComboDovKurPropertiesCloseUp
        Properties.OnEditValueChanged = ComboDovKurPropertiesEditValueChanged
        TabOrder = 5
        Visible = False
        Width = 52
      end
      object cxLabel1: TcxLabel
        Left = 84
        Top = 62
        Caption = 'D'#246'viz Kar'#351#305'l'#305#287#305' Tutar: '
        Transparent = True
        Visible = False
      end
      object LabelDovizTuru: TcxLabel
        Left = 5
        Top = 63
        Cursor = crHandPoint
        Caption = 'D'#246'viz T'#252'r'#252'...'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clNavy
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.HotTrack = False
        Style.TextColor = clNavy
        Style.TextStyle = [fsUnderline]
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelDovizTuruClick
      end
    end
  end
end
