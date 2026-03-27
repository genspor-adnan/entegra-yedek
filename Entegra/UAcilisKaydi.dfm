object AcilisKaydiDlg: TAcilisKaydiDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'A'#231#305'l'#305#351' Kayd'#305' Ekran'#305
  ClientHeight = 329
  ClientWidth = 445
  Color = 11776947
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 18
  object Label8: TcxLabel
    Left = 221
    Top = 84
    AutoSize = False
    Caption = 'Tarih'
    Transparent = True
    Height = 22
    Width = 157
  end
  object Label10: TcxLabel
    Left = 30
    Top = 177
    AutoSize = False
    Caption = 'A'#231#305'klama'
    Transparent = True
    Height = 22
    Width = 157
  end
  object Label11: TcxLabel
    Left = 221
    Top = 130
    AutoSize = False
    Caption = 'Bor'#231
    Transparent = True
    Height = 22
    Width = 157
  end
  object Label1: TcxLabel
    Left = 221
    Top = 177
    AutoSize = False
    Caption = 'Alacak'
    Transparent = True
    Height = 22
    Width = 157
  end
  object LabelId: TcxLabel
    Left = 30
    Top = 56
    Caption = '---'
    Transparent = True
  end
  object LabelKod: TcxLabel
    Left = 118
    Top = 56
    Caption = '---'
    Transparent = True
  end
  object LabelAd: TcxLabel
    Left = 221
    Top = 56
    Caption = '---'
    Transparent = True
  end
  object Label2: TcxLabel
    Left = 30
    Top = 130
    AutoSize = False
    Caption = 'Para Birimi'
    Transparent = True
    Height = 22
    Width = 157
  end
  object EditAcik: TcxTextEdit
    Left = 30
    Top = 198
    TabOrder = 14
    Width = 157
  end
  object EditBorc: TcxCurrencyEdit
    Tag = 2
    Left = 221
    Top = 151
    Properties.DisplayFormat = ',0.00;-,0.00'
    Properties.OnChange = ComboKurPropertiesEditValueChanged
    TabOrder = 10
    Width = 157
  end
  object EditAlacak: TcxCurrencyEdit
    Tag = 2
    Left = 221
    Top = 198
    Properties.DisplayFormat = ',0.00;-,0.00'
    Properties.OnChange = ComboKurPropertiesEditValueChanged
    TabOrder = 12
    Width = 157
  end
  object ComboKur: TcxComboBox
    Left = 30
    Top = 150
    RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
    Properties.DropDownListStyle = lsFixedList
    Properties.OnEditValueChanged = ComboKurPropertiesEditValueChanged
    StyleDisabled.Color = clWhite
    StyleDisabled.TextColor = clBtnText
    TabOrder = 6
    Width = 158
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 439
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 69
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    ExplicitWidth = 435
    object btnYeni: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      Visible = False
      OnClick = btnYeniClick
    end
    object btnKaydet: TToolButton
      Left = 69
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsTextButton
      OnClick = btnKaydetClick
    end
    object ToolButton1: TToolButton
      Left = 138
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 146
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      ImageName = 'PngImage17'
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object DateTimePickerOdemeBasl: TcxDateEdit
    Left = 221
    Top = 105
    Properties.Kind = ckDateTime
    TabOrder = 8
    Width = 157
  end
  object cxLabel1: TcxLabel
    Left = 30
    Top = 84
    AutoSize = False
    Caption = 'T'#252'r'#252
    Transparent = True
    Height = 22
    Width = 158
  end
  object ComboTur: TcxImageComboBox
    Left = 30
    Top = 104
    Enabled = False
    Properties.Items = <
      item
        Description = 'Mutabakat Kayd'#305
        ImageIndex = 0
        Value = 0
      end
      item
        Description = 'A'#231#305'l'#305#351' Fi'#351'i'
        ImageIndex = 0
        Value = 1
      end
      item
        Description = 'Devir Fi'#351'i'
        Value = 2
      end>
    TabOrder = 5
    Width = 158
  end
  object Panel1: TPanel
    Left = 0
    Top = 240
    Width = 445
    Height = 89
    Align = alBottom
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 16
    ExplicitTop = 239
    ExplicitWidth = 441
    object cxLabel4: TcxLabel
      Left = 30
      Top = 5
      Caption = 'Yerel Para Kar'#351#305'l'#305#287#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel6: TcxLabel
      Left = 221
      Top = 5
      Caption = 'Kullan'#305'lacak Kur'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditKulKur: TcxCurrencyEdit
      Left = 221
      Top = 31
      TabStop = False
      RepositoryItem = Tablo.RepCurrencyDovizKuru
      EditValue = 1.000000000000000000
      ParentFont = False
      Properties.DisplayFormat = ',0.0000;(,0.0000)'
      TabOrder = 2
      OnKeyUp = EditKulKurKeyUp
      Width = 81
    end
    object EditYerelPara: TcxCurrencyEdit
      Tag = 2
      Left = 31
      Top = 29
      Properties.DisplayFormat = ',0.00;-,0.00'
      TabOrder = 3
      OnKeyUp = EditYerelParaKeyUp
      Width = 157
    end
  end
  object TabAcilis: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 8
    Top = 337
  end
end


