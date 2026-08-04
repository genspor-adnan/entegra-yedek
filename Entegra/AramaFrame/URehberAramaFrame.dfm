object RehberAramaFrame: TRehberAramaFrame
  Left = 0
  Top = 0
  Width = 510
  Height = 443
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object Label2: TcxLabel
    Left = -1
    Top = 92
    Caption = #304'lgili'
    FocusControl = AraYetkili
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object LabelPNO: TcxLabel
    Left = -1
    Top = 67
    Caption = #220'nvan'
    FocusControl = AraFirma
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
    Left = -1
    Top = 117
    Caption = '&Kod'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object LabelGrup: TcxLabel
    Left = -1
    Top = 143
    Caption = '&Grup'
    FocusControl = AraKod
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
    Left = -1
    Top = 169
    Caption = 'Kategori'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label7: TcxLabel
    Left = -1
    Top = 194
    Caption = 'S'#305'n'#305'f'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraYetkili: TcxTextEdit
    Left = 76
    Top = 90
    TabOrder = 2
    Width = 115
  end
  object AraFirma: TcxTextEdit
    Left = 76
    Top = 65
    TabOrder = 0
    Width = 115
  end
  object AraKod: TcxTextEdit
    Left = 76
    Top = 115
    TabOrder = 4
    Width = 115
  end
  object CheckPasifler: TcxCheckBox
    Left = 65
    Top = 367
    Caption = 'Pasifleri de g'#246'ster'
    TabOrder = 9
    Transparent = True
  end
  object ComboGrup: TcxImageComboBox
    Left = 76
    Top = 140
    RepositoryItem = Tablo.RepCariGrup
    Properties.Items = <>
    TabOrder = 5
    Width = 115
  end
  object ComboKategori: TcxImageComboBox
    Left = 76
    Top = 166
    RepositoryItem = Tablo.RepCariKategori
    Properties.Items = <>
    TabOrder = 6
    Width = 115
  end
  object ComboSinif: TcxImageComboBox
    Left = 76
    Top = 191
    RepositoryItem = Tablo.RepCariSinif
    Properties.Items = <>
    TabOrder = 7
    Width = 115
  end
  object PanelCRM: TPanel
    Left = -1
    Top = 217
    Width = 209
    Height = 79
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 18
    Visible = False
    object cxLabel28: TcxLabel
      Left = 0
      Top = 3
      Caption = #304'l'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Arailler: TcxImageComboBox
      Left = 77
      Top = 0
      RepositoryItem = Tablo.Repiller
      Properties.Items = <>
      TabOrder = 1
      Width = 115
    end
    object comboTemsilci: TcxButtonEdit
      Left = 77
      Top = 26
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
      Properties.ClearKey = 46
      Properties.ReadOnly = False
      Properties.OnButtonClick = comboTemsilciPropertiesButtonClick
      ShowHint = True
      TabOrder = 2
      OnKeyDown = comboTemsilciKeyDown
      Width = 115
    end
    object lbl6: TcxLabel
      Left = 0
      Top = 28
      Caption = 'Temsilci'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel1: TcxLabel
      Left = 0
      Top = 55
      Caption = 'Bolge'
      FocusControl = AraKod
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ComboBolge: TcxImageComboBox
      Left = 77
      Top = 52
      RepositoryItem = Tablo.RepCariBolge
      Properties.Items = <>
      TabOrder = 5
      Width = 115
    end
  end
  object ComboCariAnaliz: TcxComboBox
    Left = 74
    Top = 321
    Properties.DropDownListStyle = lsFixedList
    Properties.ImmediatePost = True
    Properties.Items.Strings = (
      ''
      'Bor'#231'lular'
      'Alacakl'#305'lar'
      'Bor'#231'lular(Ya'#351'land'#305'r'#305'lm'#305#351')'
      'Alacakl'#305'lar(Ya'#351'land'#305'r'#305'lm'#305#351')'
      'Bor'#231'lular+Alacakl'#305'lar'
      'Ekipman'#305' Olanlar')
    TabOrder = 19
    Width = 115
  end
  object LabelAnaliz: TcxLabel
    Left = -3
    Top = 324
    Caption = 'Analiz'
    FocusControl = AraFirma
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object CheckDetay: TcxCheckBox
    Left = 65
    Top = 347
    Caption = 'Detay g'#246'ster'
    TabOrder = 21
    Transparent = True
  end
  object LabelOzelKod: TcxLabel
    Left = -2
    Top = 297
    Caption = #214'zel Kod'
    FocusControl = AraOzelKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraOzelKod: TcxTextEdit
    Left = 75
    Top = 295
    TabOrder = 23
    Width = 115
  end
  object CheckPotansiyel: TcxCheckBox
    Left = 65
    Top = 386
    Caption = 'Potansiyelde de Ara'
    TabOrder = 24
    Transparent = True
  end
  object ToolBar6: TToolBar
    Left = 0
    Top = 0
    Width = 191
    Height = 38
    Margins.Bottom = 0
    Align = alCustom
    AutoSize = True
    ButtonHeight = 39
    ButtonWidth = 61
    Caption = 'AletCubugu'
    Color = clTeal
    Ctl3D = False
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esNone
    EdgeOuter = esNone
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
    TabOrder = 25
    Transparent = True
    object LabelTumKayitlar: TToolButton
      Tag = 3
      Left = 0
      Top = 0
      HelpType = htKeyword
      HelpKeyword = 'K.SAY'
      Caption = 'T'#252'm Liste'
      ImageIndex = 20
      ImageName = 'PngImage20'
    end
    object LabelSonArananlar: TToolButton
      Tag = 4
      Left = 61
      Top = 0
      HelpType = htKeyword
      HelpKeyword = 'K.DEGISTIRMETARIHI'
      Caption = 'Son Aranan'
      ImageIndex = 21
      ImageName = 'PngImage21'
    end
    object LabelSIKArananlar: TToolButton
      Tag = 3
      Left = 122
      Top = 0
      HelpType = htKeyword
      HelpKeyword = 'K.SAY'
      Caption = 'S'#305'k Aranan'
      ImageIndex = 6
      ImageName = 'PngImage6'
    end
  end
  object TabSK: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        ' select top 15 R.ID,R.FIRMA from KULLANICI_REHBER K inner join R' +
        'EHBER R on K.REHBERID=R.ID where KULID=5'
      ' order by K.DEGISTIRMETARIHI desc')
    Left = 119
    Top = 140
  end
  object DtsSK: TDataSource
    DataSet = TabSK
    Left = 126
    Top = 96
  end
end

