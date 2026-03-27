object POS: TPOS
  Left = 0
  Top = 0
  Width = 730
  Height = 559
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object Bevel3: TBevel
    Left = 0
    Top = 221
    Width = 879
    Height = 97
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 724
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
    ExplicitWidth = 445
    ExplicitHeight = 29
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 69
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton5: TToolButton
      Left = 138
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 19
      ImageName = 'PngImage19'
      Style = tbsSeparator
    end
    object KaydetTus: TToolButton
      Left = 146
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 215
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton2: TToolButton
      Left = 284
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object KapatTus: TToolButton
      Left = 292
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      ImageName = 'PngImage17'
      Style = tbsTextButton
      OnClick = KapatTusClick
    end
  end
  object Label2: TcxLabel
    Left = 1
    Top = 49
    Caption = 'Kodu'
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
    Left = 1
    Top = 75
    Caption = 'Ad'#305
    FocusControl = EditAdi
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
    Left = 1
    Top = 98
    Caption = 'T'#252'r'#252
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label5: TcxLabel
    Left = 192
    Top = 98
    Caption = 'Stat'#252's'#252
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
    Left = 1
    Top = 121
    Caption = 'Nosu'
    FocusControl = EditNosu
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label13: TcxLabel
    Left = 386
    Top = 234
    Caption = 'Hesap Kesim Vadesi'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label14: TcxLabel
    Left = 386
    Top = 258
    Caption = #214'deme G'#252'n Say'#305's'#305
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label15: TcxLabel
    Left = 386
    Top = 282
    Caption = 'Y'#305'll'#305'k '#220'creti'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label16: TcxLabel
    Left = 386
    Top = 98
    Caption = 'Al'#305'n'#305#351' Tarihi'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label17: TcxLabel
    Left = 386
    Top = 121
    Caption = 'Kapan'#305#351' Tarihi'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label18: TcxLabel
    Left = 1
    Top = 146
    Caption = #214'zel Kod'
    FocusControl = DBEdit18
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label19: TcxLabel
    Left = 190
    Top = 146
    Caption = 'Yetki Kodu'
    FocusControl = DBEdit19
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditAdi: TcxDBTextEdit
    Left = 93
    Top = 75
    DataBinding.DataField = 'ADI'
    DataBinding.DataSource = DtsPos
    TabOrder = 8
    Width = 230
  end
  object EditNosu: TcxDBTextEdit
    Left = 93
    Top = 121
    DataBinding.DataField = 'NOSU'
    DataBinding.DataSource = DtsPos
    TabOrder = 22
    Width = 230
  end
  object DBEdit18: TcxDBTextEdit
    Left = 93
    Top = 146
    DataBinding.DataField = 'OZELKOD'
    DataBinding.DataSource = DtsPos
    TabOrder = 30
    Width = 96
  end
  object DBEdit19: TcxDBTextEdit
    Left = 252
    Top = 146
    DataBinding.DataField = 'YETKIKODU'
    DataBinding.DataSource = DtsPos
    TabOrder = 33
    Width = 71
  end
  object cxDBLabel1: TcxDBLabel
    Left = 219
    Top = 50
    DataBinding.DataField = 'ID'
    DataBinding.DataSource = DtsPos
    Height = 19
    Width = 56
  end
  object BEditKod: TcxDBTextEdit
    Left = 93
    Top = 49
    DataBinding.DataField = 'KODU'
    DataBinding.DataSource = DtsPos
    TabOrder = 4
    Width = 96
  end
  object CBTuru: TcxDBImageComboBox
    Left = 93
    Top = 97
    RepositoryItem = Tablo.RepPOSTuru
    DataBinding.DataField = 'TURU'
    DataBinding.DataSource = DtsPos
    Properties.Items = <>
    TabOrder = 14
    Width = 96
  end
  object CBStatusu: TcxDBImageComboBox
    Left = 252
    Top = 97
    RepositoryItem = Tablo.RepPOSStatusu
    DataBinding.DataField = 'STATUSU'
    DataBinding.DataSource = DtsPos
    Properties.Items = <>
    TabOrder = 16
    Width = 71
  end
  object Label38: TcxLabel
    Left = 386
    Top = 146
    Caption = 'Banka'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EdiBANKATICARIHESAPKODU: TcxButtonEdit
    Left = 528
    Top = 146
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.ReadOnly = True
    Properties.OnButtonClick = EdiBANKATICARIHESAPKODUPropertiesButtonClick
    TabOrder = 24
    Width = 84
  end
  object EditTicariHsId: TcxDBTextEdit
    Left = 768
    Top = 146
    TabStop = False
    DataBinding.DataField = 'BANKAHESAPID'
    DataBinding.DataSource = DtsPos
    Enabled = False
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 26
    Visible = False
    Width = 34
  end
  object EditHesapAdiTicari: TcxTextEdit
    Left = 528
    Top = 195
    TabStop = False
    Enabled = False
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 36
    Width = 239
  end
  object ComboKur: TcxDBComboBox
    Left = 705
    Top = 169
    DataBinding.DataField = 'KUR'
    DataBinding.DataSource = DtsPos
    Enabled = False
    Properties.DropDownListStyle = lsFixedList
    Properties.MaxLength = 0
    TabOrder = 27
    Width = 60
  end
  object EditBanka: TcxTextEdit
    Left = 612
    Top = 146
    TabStop = False
    Enabled = False
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 25
    Width = 153
  end
  object cxLabel8: TcxLabel
    Left = 386
    Top = 170
    Caption = #350'ube/Hesap'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditHesap: TcxTextEdit
    Left = 588
    Top = 170
    TabStop = False
    Enabled = False
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 29
    Width = 114
  end
  object cxLabel9: TcxLabel
    Left = 386
    Top = 195
    Caption = 'A'#231#305'klama'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditSube: TcxTextEdit
    Left = 528
    Top = 170
    TabStop = False
    Enabled = False
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 28
    Width = 59
  end
  object cxDBDateEdit1: TcxDBDateEdit
    Left = 528
    Top = 98
    DataBinding.DataField = 'ALINISTARIHI'
    DataBinding.DataSource = DtsPos
    TabOrder = 10
    Width = 111
  end
  object cxDBDateEdit2: TcxDBDateEdit
    Left = 528
    Top = 121
    DataBinding.DataField = 'KAPANISTARIHI'
    DataBinding.DataSource = DtsPos
    TabOrder = 18
    Width = 111
  end
  object cxDBDateEdit3: TcxDBDateEdit
    Left = 679
    Top = 121
    DataBinding.DataField = 'SKT'
    DataBinding.DataSource = DtsPos
    TabOrder = 20
    Width = 86
  end
  object Label12: TcxLabel
    Left = 640
    Top = 121
    Caption = 'SKT'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label8: TcxLabel
    Left = 1
    Top = 234
    Caption = 'Genel Limit'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label9: TcxLabel
    Left = 1
    Top = 257
    Caption = 'Dahili Limit'
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
    Left = 1
    Top = 282
    Caption = 'Dahili Limit Vadesi'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBDateEdit4: TcxDBDateEdit
    Left = 170
    Top = 282
    DataBinding.DataField = 'DAHILI_LIMIT_VADESI'
    DataBinding.DataSource = DtsPos
    TabOrder = 47
    Width = 153
  end
  object cxDBCurrencyEdit1: TcxDBCurrencyEdit
    Left = 170
    Top = 235
    DataBinding.DataField = 'GENELLIMIT'
    DataBinding.DataSource = DtsPos
    Properties.DisplayFormat = ',0.00;-,0.00'
    TabOrder = 41
    Width = 153
  end
  object cxDBCurrencyEdit2: TcxDBCurrencyEdit
    Left = 170
    Top = 258
    DataBinding.DataField = 'DAHILILIMIT'
    DataBinding.DataSource = DtsPos
    Properties.DisplayFormat = ',0.00;-,0.00'
    TabOrder = 45
    Width = 153
  end
  object cxDBCurrencyEdit3: TcxDBCurrencyEdit
    Left = 528
    Top = 282
    DataBinding.DataField = 'YILLIK_UCRETI'
    DataBinding.DataSource = DtsPos
    Properties.DisplayFormat = ',0.00;-,0.00'
    TabOrder = 53
    Width = 153
  end
  object cxLabel2: TcxLabel
    Left = 640
    Top = 98
    Caption = 'Durum'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBImageComboBox1: TcxDBImageComboBox
    Left = 686
    Top = 97
    RepositoryItem = Tablo.RepAktifPasif
    DataBinding.DataField = 'DURUM'
    DataBinding.DataSource = DtsPos
    Properties.Items = <>
    TabOrder = 12
    Width = 79
  end
  object cxDBSpinEdit1: TcxDBSpinEdit
    Left = 528
    Top = 257
    DataBinding.DataField = 'ODEME_GUN_SAYISI'
    DataBinding.DataSource = DtsPos
    Properties.MaxValue = 365.000000000000000000
    TabOrder = 46
    Width = 123
  end
  object cxDBSpinEdit2: TcxDBSpinEdit
    Left = 528
    Top = 234
    DataBinding.DataField = 'HESAP_KESIM_TARIHI'
    DataBinding.DataSource = DtsPos
    Properties.MaxValue = 30.000000000000000000
    TabOrder = 43
    Width = 123
  end
  object cxLabel3: TcxLabel
    Left = 657
    Top = 234
    Caption = 'g'#252'n.'
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
    Left = 657
    Top = 258
    Caption = 'g'#252'n.'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object LblSube: TcxLabel
    Left = 386
    Top = 76
    Caption = #350'ube'
  end
  object ComboSube: TcxDBImageComboBox
    Left = 528
    Top = 74
    RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
    DataBinding.DataField = 'SUBEID'
    DataBinding.DataSource = DtsPos
    Properties.Alignment.Horz = taLeftJustify
    Properties.Items = <>
    StyleDisabled.Color = clWhite
    StyleDisabled.TextColor = clBlack
    TabOrder = 2
    Width = 237
  end
  object BEditKMM: TcxButtonEdit
    Left = 180
    Top = 170
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.OnButtonClick = BEditKMMPropertiesButtonClick
    TabOrder = 38
    Width = 143
  end
  object cxLabel5: TcxLabel
    Left = 1
    Top = 170
    Caption = 'Komisyon Masraf Merkezi'
    FocusControl = DBEdit18
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxDBImage1: TcxDBImage
    Left = 770
    Top = 37
    DataBinding.DataField = 'RESIM'
    DataBinding.DataSource = DtsPos
    Properties.GraphicClassName = 'TdxSmartImage'
    TabOrder = 1
    Height = 62
    Width = 124
  end
  object cxLabel6: TcxLabel
    Left = 0
    Top = 195
    Caption = 'Masraf '#304#351'leme T'#252'r'#252
    FocusControl = DBEdit18
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object ComboMasrafIsleme: TcxDBImageComboBox
    Left = 179
    Top = 194
    DataBinding.DataField = 'MASRAFCIKIS'
    DataBinding.DataSource = DtsPos
    Properties.Items = <
      item
        Description = #214'nce banka hesab'#305'na girsin sonra d'#252#351's'#252'n'
        ImageIndex = 0
        Value = 1
      end
      item
        Description = 'Banka hesab'#305'na girmeden d'#252#351'sn'
        Value = 2
      end>
    TabOrder = 39
    Width = 144
  end
  object TabPOS: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterOpen = TabPOSAfterOpen
    BeforeEdit = TabPOSBeforeEdit
    BeforePost = TabPOSBeforePost
    AfterPost = TabPOSAfterPost
    AfterScroll = TabPOSAfterScroll
    OnNewRecord = TabPOSNewRecord
    ParamData = <>
    SQL.Strings = (
      'select *  from POS P where P.ID= :Par')
    Left = 36
    Top = 317
  end
  object DtsPos: TDataSource
    DataSet = TabPOS
    OnStateChange = DtsPosStateChange
    Left = 65531
    Top = 324
  end
end
