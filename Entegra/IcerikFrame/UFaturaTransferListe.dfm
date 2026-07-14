object FatTransferListeDlg: TFatTransferListeDlg
  Left = 0
  Top = 0
  Width = 866
  Height = 584
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 860
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 74
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
    TabOrder = 0
    Transparent = True
    ExplicitHeight = 29
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object DegisTus: TToolButton
      Left = 148
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = GridFatListeTviewDblClick
    end
    object ToolButton2: TToolButton
      Left = 222
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 230
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 238
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
    object ToolButtonSSAyrac: TToolButton
      Left = 312
      Top = 0
      Width = 8
      Caption = 'ToolButtonSSAyrac'
      Style = tbsSeparator
    end
    object LabelTumKayitlar: TToolButton
      Left = 320
      Top = 0
      Caption = 'T'#252'm'
      Style = tbsTextButton
      OnClick = LabelTumKayitlarClick
    end
    object LabelSonArananlar: TToolButton
      Tag = 5
      Left = 394
      Top = 0
      Caption = 'Son Aranan'
      Style = tbsTextButton
      OnClick = LabelSonArananlarClick
    end
    object LabelSikArananlar: TToolButton
      Tag = 3
      Left = 468
      Top = 0
      Caption = 'S'#305'k Aranan'
      Style = tbsTextButton
      OnClick = LabelSikArananlarClick
    end
  end
  object GridFatListe: TcxGrid
    Left = 0
    Top = 35
    Width = 866
    Height = 349
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    PopupMenu = PopupMenuTransfer
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridFatListeTview: TcxGridDBTableView
      OnDblClick = GridFatListeTviewDblClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridFatListeTviewCanFocusRecord
      OnSelectionChanged = GridFatListeTviewSelectionChanged
      DataController.DataSource = DtsFatBaslik
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = 'Say'#305' :  ######'
          Kind = skCount
          FieldName = 'FATURATARIH'
          Column = GridFatListeTviewFATURATARIH
          DisplayText = 'Kay'#305't Say'#305's'#305
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = GridFatListeTviewStylesGetContentStyle
      object GridFatListeTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridFatListeTviewFATURATARIH: TcxGridDBColumn
        Caption = 'T.Tarihi'
        DataBinding.FieldName = 'FATURATARIH'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 95
      end
      object GridFatListeTviewFATURANO: TcxGridDBColumn
        Caption = 'Transfer No'
        DataBinding.FieldName = 'FATURANO'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 72
      end
      object GridFatListeTviewEMIRNO: TcxGridDBColumn
        Caption = #220'rt.Emir No'
        DataBinding.FieldName = 'DETAYBOLUMU'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewSUBEID: TcxGridDBColumn
        Caption = #199#305'k'#305#351' '#350'ubesi'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubeler
        HeaderAlignmentHorz = taCenter
        Width = 93
      end
      object GridFatListeTviewCIKISDEPO: TcxGridDBColumn
        Caption = #199#305'k'#305#351' Depo'
        DataBinding.FieldName = 'CIKISDEPOSU'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 91
      end
      object GridFatListeTviewGIRISSUBE: TcxGridDBColumn
        Caption = 'Giri'#351' '#350'ubesi'
        DataBinding.FieldName = 'GIRISSUBE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubeler
        Width = 88
      end
      object GridFatListeTviewGIRISDEPO: TcxGridDBColumn
        Caption = 'Giri'#351' Depo'
        DataBinding.FieldName = 'GIRISDEPOSU'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 102
      end
      object GridFatListeTviewTESLIMEDEN: TcxGridDBColumn
        Caption = 'Teslim Eden'
        DataBinding.FieldName = 'TESLIMEDEN'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 97
      end
      object GridFatListeTviewTESLIMALAN: TcxGridDBColumn
        Caption = 'Teslim Alan'
        DataBinding.FieldName = 'TESLIMALAN'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 113
      end
      object GridFatListeTviewKAYNAK: TcxGridDBColumn
        Caption = 'Kaynak'
        DataBinding.FieldName = 'KAYNAK'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewONAY: TcxGridDBColumn
        Caption = 'Onay'
        DataBinding.FieldName = 'ONAY'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCheckBoxProperties'
      end
      object GridFatListeTviewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewYETKIKODU: TcxGridDBColumn
        Caption = 'Yetki Kodu'
        DataBinding.FieldName = 'YETKIKODU'
        DataBinding.IsNullValueType = True
      end
      object GridFatListeTviewACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
      end
    end
    object GridFatListeLevel1: TcxGridLevel
      GridView = GridFatListeTview
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 391
    Width = 866
    Height = 193
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControl1Change
    ClientRectBottom = 189
    ClientRectLeft = 4
    ClientRectRight = 862
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Detay'
      ImageIndex = 0
      object Panel4: TPanel
        Left = 0
        Top = 106
        Width = 858
        Height = 56
        Align = alBottom
        Color = 11776947
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        DesignSize = (
          858
          56)
        object Label8: TcxLabel
          Left = 13
          Top = 5
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
        object GridFaturaToplam: TStringGrid
          Left = 23063
          Top = -31
          Width = 260
          Height = 118
          Anchors = []
          Color = clBtnFace
          ColCount = 3
          DefaultColWidth = 128
          DefaultRowHeight = 19
          FixedCols = 2
          RowCount = 6
          FixedRows = 0
          Font.Charset = TURKISH_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          GridLineWidth = 0
          ParentFont = False
          ScrollBars = ssNone
          TabOrder = 0
        end
        object DBComboBox2: TcxDBLabel
          Left = 79
          Top = 5
          DataBinding.DataField = 'ACIKLAMA'
          DataBinding.DataSource = DtsFatBaslik
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
          Height = 21
          Width = 231
        end
      end
      object GridFat: TcxGrid
        Left = 0
        Top = 0
        Width = 858
        Height = 106
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        LookAndFeel.SkinName = 'LondonLiquidSky'
        object GridFatDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridFatDBTableView1CanFocusRecord
          DataController.DataSource = DtsFatura
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridFatDBTableView1StylesGetContentStyle
          Styles.Header = AnaForm.cxStyle1
          Styles.Indicator = AnaForm.cxStyle1
          object GridFatDBTableView1TUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepFatDetayTur
            HeaderAlignmentHorz = taCenter
          end
          object GridFatDBTableView1KOD1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = False
            HeaderAlignmentHorz = taCenter
            Width = 53
          end
          object GridFatDBTableView1AD: TcxGridDBColumn
            Caption = 'Stok Ad'#305
            DataBinding.FieldName = 'AD'
            Width = 154
          end
          object GridFatDBTableView1ADET1: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = False
            HeaderAlignmentHorz = taCenter
            Width = 46
          end
          object GridFatDBTableView1BIRIM1: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            HeaderAlignmentHorz = taCenter
            Width = 68
          end
          object GridFatDBTableView1PROJEKODU: TcxGridDBColumn
            Caption = 'Proje Kodu'
            DataBinding.FieldName = 'PROJEKODU'
            Width = 123
          end
          object GridFatDBTableView1BASTAR: TcxGridDBColumn
            Caption = 'Teslim Tarihi'
            DataBinding.FieldName = 'BASTAR'
            Width = 83
          end
          object GridFatDBTableView1ACIKLAMA1: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            HeaderAlignmentHorz = taCenter
            Width = 228
          end
        end
        object GridFatLevel1: TcxGridLevel
          GridView = GridFatDBTableView1
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 384
    Width = 866
    Height = 7
    AlignSplitter = salBottom
    Control = cxPageControl1
  end
  object SQLMemo: TcxMemo
    Left = 152
    Top = 72
    Lines.Strings = (
      
        'select FB.ID,FATURATARIH,FATURANO,FB.TUR,FB.SUBEID,FB.DETAYBOLUM' +
        'U,CIKISDEPO,GIRISDEPO,GIRISSUBE,Giris.DEPOADI GIRISDEPOSU, Cikis' +
        '.DEPOADI CIKISDEPOSU,'
      
        'TESLIMALAN=R1.FIRMA,TESLIMEDEN=R2.FIRMA,FB.OZELKOD,FB.YETKIKODU,' +
        'FB.ACIKLAMA,'
      
        'KAYNAK=  case  when exists(select F2.ID from SIPARISDETAY F2 whe' +
        're F2.ID in (select F1.YERID from FATURA F1 where F1.YERI =435 a' +
        'nd F1.FATBASID=FB.ID)) then '#39'Talepten'#39' end'
      'from FATBASLIK FB (NOLOCK)'
      
        'inner join DEPOLAR Giris on Giris.ID = GIRISDEPO  inner join DEP' +
        'OLAR Cikis on Cikis.ID = CIKISDEPO'
      'left Outer Join REHBER R1 on FB.REHBERID =R1.ID'
      'left outer join REHBER R2 on FB.SATICIKODU=R2.ID')
    Properties.WordWrap = False
    TabOrder = 4
    Visible = False
    Height = 81
    Width = 588
  end
  object TabFatBaslik: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    Left = 193
    Top = 117
  end
  object DtsFatBaslik: TDataSource
    DataSet = TabFatBaslik
    Left = 264
    Top = 119
  end
  object TabFatura: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select *,'
      
        '               AD =  CASE WHEN F.TUR =1 THEN (SELECT STOKADI FRO' +
        'M STOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELI' +
        'R WHERE ID = F.URUNID)  END,'
      
        '               KOD =  CASE WHEN F.TUR =1 THEN (SELECT KOD FROM S' +
        'TOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR ' +
        'WHERE ID= F.URUNID )  END,'
      
        'PROJEKODU=(select P.PROJEKODU  from PROJELER P where P.ID=F.PROJ' +
        'EID)'
      ' from FATURA F'
      'Where '
      'FATBASID = :Par'
      ' order by ID')
    Left = 277
    Top = 292
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    object TabFaturaID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabFaturaFATBASID: TIntegerField
      FieldName = 'FATBASID'
    end
    object TabFaturaREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabFaturaSEC: TWideStringField
      FieldName = 'SEC'
      Size = 1
    end
    object TabFaturaURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabFaturaTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabFaturaKOD: TWideStringField
      FieldName = 'KOD'
      Size = 15
    end
    object TabFaturaADET: TFMTBCDField
      FieldName = 'ADET'
    end
    object TabFaturaMIKTAR: TFMTBCDField
      FieldName = 'MIKTAR'
    end
    object TabFaturaBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      currency = True
      Precision = 19
    end
    object TabFaturaTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      currency = True
      Precision = 19
    end
    object TabFaturaISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object TabFaturaKDV: TSmallintField
      FieldName = 'KDV'
    end
    object TabFaturaMASRAFID: TIntegerField
      FieldName = 'MASRAFID'
    end
    object TabFaturaOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Size = 10
    end
    object TabFaturaMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 10
    end
    object TabFaturaKASA: TSmallintField
      FieldName = 'KASA'
    end
    object TabFaturaONAY: TWideStringField
      FieldName = 'ONAY'
      Size = 1
    end
    object TabFaturaEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabFaturaEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabFaturaDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabFaturaDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabFaturaBIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object TabFaturaKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabFaturaIZLEMEKODU: TWideStringField
      FieldName = 'IZLEMEKODU'
      Size = 15
    end
    object TabFaturaAD: TWideStringField
      FieldName = 'AD'
      Size = 100
    end
    object TabFaturaDOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 19
    end
    object TabFaturaDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object TabFaturaISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object TabFaturaACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
    end
    object TabFaturaMF: TFMTBCDField
      FieldName = 'MF'
    end
    object TabFaturaPROJEKODU: TWideStringField
      FieldName = 'PROJEKODU'
      ReadOnly = True
      Size = 100
    end
    object TabFaturaIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object TabFaturaBASTAR: TSQLTimeStampField
      FieldName = 'BASTAR'
    end
  end
  object DtsFatura: TDataSource
    DataSet = TabFatura
    Left = 349
    Top = 287
  end
  object PopupMenuYaz: TPopupMenu
    Left = 342
    Top = 109
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
  object frxFATURA: TfrxDBDataset
    UserName = 'FATURA'
    CloseDataSource = False
    DataSet = TabFatura
    BCDToCurrency = False
    DataSetOptions = []
    Left = 208
    Top = 288
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'FATBASLIK'
    CloseDataSource = False
    FieldAliases.Strings = (
      'ID=ID'
      'TARIH=TARIH'
      'TUR=TUR'
      'TIPI=TIPI'
      'REHBERID=REHBERID'
      'PROJEID=PROJEID'
      'AKTIVITEID=AKTIVITEID'
      'ANAKAYITID=ANAKAYITID'
      'FATURATARIH=FATURATARIH'
      'KOCANNO=KOCANNO'
      'FATURANO=FATURANO'
      'GIRISDEPO=GIRISDEPO'
      'CIKISDEPO=CIKISDEPO'
      'BASLIK=BASLIK'
      'ADRES=ADRES'
      'ILCE=ILCE'
      'IL=IL'
      'VD=VD'
      'VNO=VNO'
      'KDVDURUM=KDVDURUM'
      'LOTNO=LOTNO'
      'ACIK_KAPALI=ACIK_KAPALI'
      'FATURA_GON_TARIHI=FATURA_GON_TARIHI'
      'FATURA_MATRAHI=FATURA_MATRAHI'
      'KDV_TUTARI=KDV_TUTARI'
      'FATURA_TUTARI=FATURA_TUTARI'
      'KUR=KUR'
      'DOVIZ_TUTARI=DOVIZ_TUTARI'
      'DOVIZ_KURU=DOVIZ_KURU'
      'KASA=KASA'
      'ONAY=ONAY'
      'SAYFA=SAYFA'
      'MASRAFID=MASRAFID'
      'ACIKLAMA=ACIKLAMA'
      'ISYERI=ISYERI'
      'BOLUM=BOLUM'
      'AMBAR=AMBAR'
      'SATICIKODU=SATICIKODU'
      'DURUM=DURUM'
      'IRSALIYE_TIPI=IRSALIYE_TIPI'
      'IRSALIYE_NO=IRSALIYE_NO'
      'ODEMEPLANI=ODEMEPLANI'
      'OZELKOD=OZELKOD'
      'YETKIKODU=YETKIKODU'
      'R=R'
      'EKLEYEN=EKLEYEN'
      'EKLEMETARIHI=EKLEMETARIHI'
      'DEGISTIREN=DEGISTIREN'
      'DEGISTIRMETARIHI=DEGISTIRMETARIHI'
      'EKVERGI=EKVERGI'
      'FATURASERI=FATURASERI'
      'IRSALIYENO=IRSALIYENO'
      'IRSALIYETARIH=IRSALIYETARIH'
      'PLANID=PLANID'
      'FIYAT_LISTESI=FIYAT_LISTESI'
      'STOKISK=STOKISK'
      'HIZMETISK=HIZMETISK'
      'VADE=VADE'
      'KASATAKIPID=KASATAKIPID'
      'DETAYBOLUMU=DETAYBOLUMU'
      'YAZIYLATOPLAM=YAZIYLATOPLAM')
    DataSet = TabFatBaslik
    BCDToCurrency = False
    DataSetOptions = []
    Left = 246
    Top = 168
  end
  object FatBaslik: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT *,YAZIYLATOPLAM=( dbo.fn_MoneyToText(FATURA_TUTARI,'#39'TL'#39','#39 +
        'Kr'#39',0)) '
      'FROM FATBASLIK WHERE ID = :Par')
    Left = 336
    Top = 209
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 583
    Top = 156
  end
  object PopupMenuTransfer: TPopupMenu
    Left = 446
    Top = 109
    object TransferInfoMenu: TMenuItem
      Caption = 'info'
      OnClick = TransferInfoMenuClick
    end
    object MenuUretim: TMenuItem
      Caption = #220'retim Fi'#351'i Olu'#351'tur'
      ImageIndex = 0
      OnClick = MenuUretimClick
    end
  end
end
