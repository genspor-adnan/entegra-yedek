object NakitDlg: TNakitDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Nakit Ekran'#305
  ClientHeight = 443
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object UstPanel: TJvPanel
    Left = 0
    Top = 0
    Width = 580
    Height = 80
    FlatBorder = True
    Align = alTop
    BorderWidth = 1
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object LblSube: TcxLabel
      Left = 419
      Top = 20
      Caption = #350'ube'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ComboSube: TcxDBImageComboBox
      Left = 448
      Top = 19
      RepositoryItem = Tablo.RepSubeler
      DataBinding.DataField = 'SUBEID'
      DataBinding.DataSource = DtsKasa
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <
        item
          Description = 'Yap'#305'lmad'#305
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'K'#305'smi'
          Value = 1
        end
        item
          Description = #304'ptal'
          Value = 6
        end
        item
          Description = 'Tamamland'#305
          Value = 9
        end>
      Properties.ReadOnly = True
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 0
      Width = 126
    end
    object LabelKod: TcxLabel
      Left = 2
      Top = 0
      Cursor = crHandPoint
      Caption = 'Kodu'
      DragCursor = crDefault
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = LabelKodClick
    end
    object LabelAd: TcxLabel
      Left = 2
      Top = 14
      Cursor = crHandPoint
      ParentCustomHint = False
      AutoSize = False
      Caption = 'Ad'#305
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.Shadow = False
      Style.IsFontAssigned = True
      Properties.LabelEffect = cxleCool
      Properties.LabelStyle = cxlsRaised
      Properties.WordWrap = True
      Transparent = True
      OnClick = LabelAdClick
      Height = 40
      Width = 411
    end
    object BaslikLabel: TcxLabel
      Left = 5
      Top = 59
      Caption = '---'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clGray
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel5: TcxLabel
      Left = 170
      Top = 55
      Caption = 'Makbuz No'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditBELGENO: TcxDBTextEdit
      Left = 230
      Top = 54
      DataBinding.DataField = 'BELGENO'
      DataBinding.DataSource = DtsKasa
      TabOrder = 4
      Width = 85
    end
    object LabelTarih: TcxLabel
      Left = 417
      Top = 54
      Caption = 'Tarih'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditTarih: TcxDBDateEdit
      Left = 448
      Top = 54
      DataBinding.DataField = 'PLANTARIHI'
      DataBinding.DataSource = DtsKasa
      Properties.Kind = ckDateTime
      TabOrder = 9
      Visible = False
      Width = 127
    end
    object EditKayitTarih: TcxDBDateEdit
      Left = 448
      Top = 54
      DataBinding.DataField = 'ISLEMTARIHI'
      DataBinding.DataSource = DtsKasa
      Properties.ImmediatePost = True
      Properties.Kind = ckDateTime
      TabOrder = 7
      Width = 126
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 112
    Width = 580
    Height = 290
    Align = alClient
    TabOrder = 1
    ExplicitTop = 109
    ExplicitHeight = 293
    object Label15: TcxLabel
      Left = 3
      Top = 68
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
    object LabelKasa: TcxLabel
      Left = 4
      Top = 190
      Caption = 'Kasa'
      Transparent = True
    end
    object LabelTaksit: TcxLabel
      Left = 4
      Top = 160
      Caption = 'Taksit Say'#305's'#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelMasrafMerkezi: TcxLabel
      Left = 4
      Top = 111
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
    object LabelTutar: TcxLabel
      Left = 4
      Top = 5
      Caption = 'Tutar'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditTutar: TcxDBCurrencyEdit
      Left = 86
      Top = 5
      DataBinding.DataSource = DtsKasa
      Properties.DecimalPlaces = 4
      Properties.DisplayFormat = ',0.00 ;-,0.00 '
      Properties.EditFormat = ',0.0000 ;-,0.0000 '
      TabOrder = 5
      OnKeyUp = EditTutarKeyUp
      Width = 68
    end
    object ComboKur: TcxDBComboBox
      Left = 157
      Top = 5
      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsKasa
      Properties.DropDownListStyle = lsFixedList
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.ReadOnly = False
      Properties.OnCloseUp = ComboKurPropertiesCloseUp
      TabOrder = 6
      Width = 52
    end
    object ComboKasa: TcxDBImageComboBox
      Left = 86
      Top = 189
      DataBinding.DataField = 'HESAPID'
      DataBinding.DataSource = DtsKasa
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboKasaPropertiesEditValueChanged
      TabOrder = 11
      Width = 448
    end
    object TaksitSay: TcxSpinEdit
      Left = 86
      Top = 160
      Properties.MaxValue = 100.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Properties.OnEditValueChanged = TaksitSayPropertiesEditValueChanged
      TabOrder = 12
      Value = 1
      Width = 52
    end
    object EditMM: TcxButtonEdit
      Left = 86
      Top = 111
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
      TabOrder = 9
      Width = 248
    end
    object EditBakiye: TcxCurrencyEdit
      Left = 435
      Top = 212
      Enabled = False
      TabOrder = 13
      Width = 99
    end
    object LabelBakiye: TcxLabel
      Left = 395
      Top = 212
      Caption = 'Bakiye'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object BankaMasrafTutari: TcxCurrencyEdit
      Left = 86
      Top = 211
      Properties.DisplayFormat = ',0.00;-,0.00'
      TabOrder = 15
      Visible = False
      Width = 68
    end
    object lblbankaMasrafMerkezi: TcxLabel
      Left = 4
      Top = 231
      Caption = 'Masraf Kalemi'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object BankaMasrafMerkezi: TcxButtonEdit
      Left = 86
      Top = 233
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = BankaMasrafMerkeziPropertiesButtonClick
      TabOrder = 18
      Visible = False
      Width = 191
    end
    object lblMasrafTutar: TcxLabel
      Left = 4
      Top = 210
      Caption = 'Masraf Tutar'#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object LabelSRM: TcxLabel
      Left = 4
      Top = 132
      Caption = 'Srm. Mrk'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditSRMMerkezi: TcxButtonEdit
      Left = 86
      Top = 132
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
      Properties.OnButtonClick = EditSRMMerkeziPropertiesButtonClick
      TabOrder = 10
      Width = 248
    end
    object LabelKarsilik: TcxLabel
      Left = 5
      Top = 33
      Cursor = crHandPoint
      Caption = 'Kar'#351#305'l'#305#287#305
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
      OnClick = LabelKarsilikClick
    end
    object EditAciklama: TcxDBTextEdit
      Left = 86
      Top = 69
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = DtsKasa
      TabOrder = 7
      Width = 248
    end
    object CbKuponTipi: TcxDBImageComboBox
      Left = 248
      Top = 159
      DataBinding.DataField = 'CEKSENETID'
      DataBinding.DataSource = DtsKasa
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboKasaPropertiesEditValueChanged
      TabOrder = 22
      Visible = False
      Width = 86
    end
    object LbKuponTipi: TcxLabel
      Left = 192
      Top = 160
      Caption = 'Kupon Tipi'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object cbIrsaliyeli: TcxDBCheckBox
      Left = 334
      Top = 69
      DataBinding.DataField = 'R'
      DataBinding.DataSource = DtsKasa
      Properties.ImmediatePost = True
      Properties.NullStyle = nssUnchecked
      TabOrder = 23
      Transparent = True
    end
    object ComboOdemeTipi: TcxImageComboBox
      Left = 248
      Top = 165
      Properties.Items = <
        item
          Description = 'Maa'#351
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Prim'
          Value = 11
        end
        item
          Description = 'Yemek Paras'#305
          Value = 5
        end
        item
          Description = 'Yol Paras'#305
          Value = 7
        end
        item
          Description = #304'zin Paras'#305
          Value = 9
        end
        item
          Description = 'Maa'#351' Avans'#305
          Value = 196
        end
        item
          Description = #304#351' Avans'#305
          Value = 195
        end
        item
          Description = 'Avsns Geri '#214'demesi'
          Value = 231
        end>
      Properties.OnChange = ComboOdemeTipiPropertiesChange
      TabOrder = 25
      Visible = False
      Width = 86
    end
    object LabelOdemeTipi: TcxLabel
      Left = 192
      Top = 166
      Caption = #214'deme Tipi'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object PanelMaas: TPanel
      Left = 435
      Top = 96
      Width = 132
      Height = 80
      BevelOuter = bvNone
      TabOrder = 26
      Visible = False
      object cxLabel1: TcxLabel
        Left = 0
        Top = 39
        Caption = 'Maa'#351'tan d'#252#351#252'lecek tutar'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxLabel2: TcxLabel
        Left = 0
        Top = -6
        Caption = 'Al'#305'nm'#305#351' avans toplam'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGreen
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditAvans: TcxCurrencyEdit
        Left = 1
        Top = 13
        Properties.ReadOnly = True
        Style.LookAndFeel.NativeStyle = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        StyleReadOnly.LookAndFeel.NativeStyle = True
        TabOrder = 2
        Width = 98
      end
      object EditMaastan: TcxCurrencyEdit
        Left = 1
        Top = 62
        Properties.OnChange = EditMaastanPropertiesChange
        TabOrder = 3
        OnDblClick = EditMaastanDblClick
        Width = 98
      end
    end
    object PanelKarsilik: TPanel
      Left = 86
      Top = 32
      Width = 409
      Height = 27
      Align = alCustom
      BevelEdges = []
      BevelOuter = bvNone
      TabOrder = 28
      Visible = False
      object EditDovTutar: TcxDBCurrencyEdit
        Left = 0
        Top = 0
        DataBinding.DataField = 'DOVIZ_TUTARI'
        DataBinding.DataSource = DtsKasa
        Properties.DecimalPlaces = 4
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        TabOrder = 0
        OnKeyUp = EditDovTutarKeyUp
        Width = 68
      end
      object ComboDovKur: TcxDBComboBox
        Left = 72
        Top = 0
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        DataBinding.DataField = 'DOVIZ_KURU'
        DataBinding.DataSource = DtsKasa
        Properties.DropDownListStyle = lsFixedList
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.ReadOnly = False
        Properties.OnCloseUp = ComboDovKurPropertiesCloseUp
        TabOrder = 1
        Width = 52
      end
      object EditKulKur: TcxCurrencyEdit
        Left = 129
        Top = 0
        TabStop = False
        RepositoryItem = Tablo.RepCurrencyDovizKuru
        EditValue = 1.000000000000000000
        ParentFont = False
        Properties.DecimalPlaces = 4
        Properties.DisplayFormat = ',0.0000;(,0.0000)'
        Properties.EditFormat = ',0.0000;(,0.0000)'
        Style.Color = clInactiveCaption
        TabOrder = 2
        OnKeyUp = EditKulKurKeyUp
        Width = 49
      end
      object cxDBCheckBox1: TcxDBCheckBox
        Left = 187
        Top = 1
        Caption = 'Ekstrede bunu kullan'
        DataBinding.DataField = 'EKSTREDEKULLAN'
        DataBinding.DataSource = DtsKasa
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        TabOrder = 3
        Transparent = True
      end
    end
    object lblMasrafKod: TcxLabel
      Left = 335
      Top = 94
      Transparent = True
    end
    object lblBankaMasrafKod: TcxLabel
      Left = 277
      Top = 234
      Transparent = True
    end
    object LabelProjeKodu: TcxLabel
      Left = 4
      Top = 90
      Caption = 'Proje Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditProje: TcxButtonEdit
      Left = 86
      Top = 90
      Properties.Buttons = <
        item
          Caption = '++'
          Default = True
          Kind = bkText
        end
        item
          Caption = '+'
          Kind = bkText
        end
        item
          Caption = '-'
          Kind = bkText
        end>
      Properties.OnButtonClick = EditProjeKoduPropertiesButtonClick
      TabOrder = 8
      Width = 248
    end
    object SqlMemoMasrafKalemi: TMemo
      Left = 81
      Top = 260
      Width = 436
      Height = 30
      Lines.Strings = (
        
          '  select ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '#39','#39#39'),' +
          'CHARINDEX'
        '('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39')'
        '    )-(CHARINDEX('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
        
          ' M.ID,  M.KOD, M.AD,PROJEID,MASRAFID,SUBEID=-1,DURUM=1, GELIRMI=' +
          '0, '
        'BARKOD=0'
        
          ' from PROJEBUTCE PB inner join MASRAFGELIR M on M.ID = PB.MASRAF' +
          'ID ')
      TabOrder = 32
      Visible = False
    end
    object LabelCoklu: TcxLabel
      Left = 334
      Top = 114
      Cursor = crHandPoint
      Caption = #199'oklu Proje/Masraf'
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
      OnClick = LabelCokluClick
    end
  end
  object AltPanel: TPanel
    Left = 0
    Top = 402
    Width = 580
    Height = 41
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      580
      41)
    object tamamButton: TButton
      Left = 407
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Tamam'
      Default = True
      TabOrder = 0
      OnClick = tamamButtonClick
    end
    object iptalButton: TButton
      Left = 488
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 1
      OnClick = iptalButtonClick
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 0
    Top = 80
    Width = 580
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 86
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
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 3
    Transparent = True
    ExplicitHeight = 29
    object YaziciYaz: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
      Style = tbsTextButton
    end
    object ToolButton3: TToolButton
      Left = 86
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsSeparator
    end
    object AksiyonlarTus: TToolButton
      Left = 94
      Top = 0
      Caption = 'Aksiyonlar'
      ImageIndex = 1
      ImageName = 'PngImage0'
      Visible = False
    end
  end
  object TabKasa: TFDQuery
    AfterOpen = TabKasaAfterOpen
    BeforeEdit = TabKasaBeforeEdit
    BeforePost = TabKasaBeforePost
    AfterPost = TabKasaAfterPost
    OnNewRecord = TabKasaNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM KASA'
      'WHERE ID = :PID ')
    Left = 35
    Top = 252
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    Left = 83
    Top = 277
  end
  object PopupMenuYaz: TPopupMenu
    Left = 437
    Top = 130
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxMakbuz: TfrxDBDataset
    UserName = 'Makbuz'
    CloseDataSource = False
    DataSet = TabKasaYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 501
    Top = 121
  end
  object TabKasaYaz: TFDQuery
    AfterOpen = TabKasaAfterOpen
    BeforeEdit = TabKasaBeforeEdit
    BeforePost = TabKasaBeforePost
    AfterPost = TabKasaAfterPost
    OnNewRecord = TabKasaNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT K.*, '
      'YAZIYLATOPLAM=( dbo.fn_MoneyToText(ABS(BORC-ALACAK),KUR,0)),'
      
        'YAZIYLATOPLAM_DOVIZ=( dbo.fn_MoneyToText(DOVIZ_TUTARI, DOVIZ_KUR' +
        'U,0)),'
      
        'TURADI=(select ANAHTAR from GENINI where DEGER=K.TUR and DIL=-1 ' +
        'and BOLUM=-1005)'
      'FROM KASA K'
      'WHERE K.ID = :PID ')
    Left = 219
    Top = 268
  end
end
