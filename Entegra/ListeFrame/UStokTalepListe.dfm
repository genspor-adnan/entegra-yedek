object StokTalepListeDlg: TStokTalepListeDlg
  Left = 0
  Top = 0
  Width = 850
  Height = 579
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
    Width = 844
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 81
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
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 81
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object DegisTus: TToolButton
      Left = 162
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = GridStokTalepTviewDblClick
    end
    object ToolButton2: TToolButton
      Left = 243
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 251
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 259
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
    object BtnDonustur: TToolButton
      Left = 340
      Top = 0
      Caption = 'D'#246'n'#252#351't'#252'r'
      ImageIndex = 17
      ImageName = 'PngImage16'
      OnClick = BtnDonusturClick
    end
  end
  object GridStokTalep: TcxGrid
    Left = 0
    Top = 32
    Width = 850
    Height = 347
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    PopupMenu = PopupMenuTransfer
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    ExplicitTop = 35
    ExplicitHeight = 344
    object GridStokTalepTview: TcxGridDBTableView
      OnDblClick = GridStokTalepTviewDblClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridStokTalepTviewCanFocusRecord
      OnSelectionChanged = GridStokTalepTviewSelectionChanged
      DataController.DataSource = DtsStokTalep
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
          Column = GridStokTalepTviewFATURATARIH
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
      object GridStokTalepTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridStokTalepTviewFATURATARIH: TcxGridDBColumn
        Caption = 'Talep Tarihi'
        DataBinding.FieldName = 'TALEPTARIH'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 95
      end
      object GridStokTalepTviewFATURANO: TcxGridDBColumn
        Caption = 'Talep No'
        DataBinding.FieldName = 'TALEPNO'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.ReadOnly = True
        HeaderAlignmentHorz = taCenter
        Width = 72
      end
      object GridStokTalepTviewEMIRNO: TcxGridDBColumn
        Caption = #220'rt.Emir No'
        DataBinding.FieldName = 'DETAYBOLUMU'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.ReadOnly = True
        Width = 69
      end
      object GridStokTalepTviewTALEPEDENAD: TcxGridDBColumn
        Caption = 'Talep Eden Ki'#351'i'
        DataBinding.FieldName = 'TALEPEDENAD'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 97
      end
      object GridStokTalepTviewTALEPEDENBIRIM: TcxGridDBColumn
        Caption = 'Talep Eden Birim'
        DataBinding.FieldName = 'TALEPEDENBIRIM'
        DataBinding.IsNullValueType = True
        HeaderAlignmentHorz = taCenter
        Width = 113
      end
      object GridStokTalepTviewGIRISDEPOSU: TcxGridDBColumn
        Caption = 'Giri'#351' Depo'
        DataBinding.FieldName = 'GIRISDEPOSU'
        DataBinding.IsNullValueType = True
      end
      object GridStokTalepTviewBIRIMONAYLAYACAKAD: TcxGridDBColumn
        Caption = 'Birim Onaylayacak'
        DataBinding.FieldName = 'BIRIMONAYLAYACAKAD'
        DataBinding.IsNullValueType = True
        Width = 100
      end
      object GridStokTalepTviewBIRIMONAYLAYANAD: TcxGridDBColumn
        Caption = 'Birim Onaylayan'
        DataBinding.FieldName = 'BIRIMONAYLAYANAD'
        DataBinding.IsNullValueType = True
        Width = 100
      end
      object GridStokTalepTviewPROJEKOD: TcxGridDBColumn
        Caption = 'Proje Kodu'
        DataBinding.FieldName = 'PROJEKOD'
        DataBinding.IsNullValueType = True
        Width = 150
      end
      object GridStokTalepTviewTALEPONAYLAYACAKAD: TcxGridDBColumn
        Caption = 'Talep Onaylayacak'
        DataBinding.FieldName = 'TALEPONAYLAYACAKAD'
        DataBinding.IsNullValueType = True
        Width = 120
      end
      object GridStokTalepTviewTALEPONAYLAYANAD: TcxGridDBColumn
        Caption = 'Talep Onaylayan'
        DataBinding.FieldName = 'TALEPONAYLAYANAD'
        DataBinding.IsNullValueType = True
        Width = 120
      end
      object GridStokTalepTviewKAYNAK: TcxGridDBColumn
        Caption = 'Kaynak'
        DataBinding.FieldName = 'KAYNAK'
        DataBinding.IsNullValueType = True
      end
      object GridStokTalepTviewHEDEF: TcxGridDBColumn
        Caption = 'Hedef'
        DataBinding.FieldName = 'HEDEF'
        DataBinding.IsNullValueType = True
      end
      object GridStokTalepTviewACIKLAMA: TcxGridDBColumn
        Caption = 'Notlar'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        Width = 120
      end
      object GridStokTalepTviewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
        Width = 100
      end
      object GridStokTalepTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepSatinalmaAsama
      end
    end
    object GridStokTalepLevel1: TcxGridLevel
      GridView = GridStokTalepTview
    end
  end
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 386
    Width = 850
    Height = 193
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControl1Change
    ClientRectBottom = 189
    ClientRectLeft = 4
    ClientRectRight = 846
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Detay'
      ImageIndex = 22
      object Panel4: TPanel
        Left = 0
        Top = 106
        Width = 842
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
          842
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
          Left = 20017
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
          DataBinding.DataSource = DtsStokTalep
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
      object GridDetay: TcxGrid
        Left = 0
        Top = 0
        Width = 842
        Height = 106
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        LookAndFeel.SkinName = 'LondonLiquidSky'
        object GridDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridDetayViewCanFocusRecord
          DataController.DataSource = DtsTalepDetay
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
          Styles.Header = AnaForm.cxStyle1
          Styles.Indicator = AnaForm.cxStyle1
          object GridDetayViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepFatDetayTur
            HeaderAlignmentHorz = taCenter
          end
          object GridDetayViewKOD1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
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
          object GridDetayViewSTOKADI: TcxGridDBColumn
            Caption = 'Stok Ad'#305
            DataBinding.FieldName = 'STOKADI'
            DataBinding.IsNullValueType = True
            Width = 155
          end
          object GridDetayViewADET1: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taRightJustify
            Properties.ReadOnly = False
            HeaderAlignmentHorz = taCenter
            Width = 46
          end
          object GridDetayViewBIRIM1: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            HeaderAlignmentHorz = taCenter
            Width = 68
          end
          object GridDetayViewColumn1: TcxGridDBColumn
            Caption = 'Proje Kodu'
            DataBinding.FieldName = 'PROJEKODU'
            DataBinding.IsNullValueType = True
            Width = 92
          end
          object GridDetayViewTESLIMTARIHI: TcxGridDBColumn
            Caption = 'Teslim Tarihi'
            DataBinding.FieldName = 'TESLIMTARIHI'
            DataBinding.IsNullValueType = True
            Width = 83
          end
          object GridDetayViewACIKLAMA1: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 228
          end
        end
        object GridDetayLevel1: TcxGridLevel
          GridView = GridDetayView
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 379
    Width = 850
    Height = 7
    AlignSplitter = salBottom
    Control = cxPageControl1
  end
  object SQLMemo: TcxMemo
    Left = 630
    Top = 144
    Lines.Strings = (
      'SELECT '
      'distinct S.ID,S.DURUM,'
      'TALEPTARIH=SIPARISTARIH, TALEPNO=SIPARISNO,'
      'DETAYBOLUMU,'
      
        'TALEPEDENAD=(SELECT FIRMA FROM REHBER R WHERE S.SATICIKODU = R.I' +
        'D),'
      
        'TALEPEDENBIRIM=(select DEPARTMAN=(SELECT TOP 1 ANAHTAR FROM GENI' +
        'NI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 ) from' +
        ' ROLLER ROL where ROL.ID=S.BOLUM),'
      
        'BIRIMONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAY' +
        'LAYACAK = R.ID),'
      
        'BIRIMONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLA' +
        'YAN = R.ID),'
      
        'TALEPONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYAC' +
        'AK = R.ID),'
      
        'TALEPONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYAN =' +
        ' R.ID),'
      
        'PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.I' +
        'D),'
      
        'PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.I' +
        'D),'
      
        'PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.I' +
        'D),'
      'S.ACIKLAMA,S.OZELKOD,'
      
        'GIRISDEPOSU=(select DEPOADI from DEPOLAR D where D.ID=S.GIRISDEP' +
        'O),'
      'S.TIPI,S.REHBERID,S.TUR,S.SUBEID,'
      'S.ONAYLAYACAK,S.ONAYLAYAN,'
      
        'KAYNAK= case when (S.TUR=105)and(467 in (select YERI from SIPARI' +
        'SDETAY where YERID in (select ID from URETIMEMRIDETAY UED where ' +
        'SD.YERID=UED.ID))) then '#39#220'retimden'#39' else '#39#39' end,'
      
        'HEDEF=  case when (S.TUR=105)and(435 in (select YERI from FATURA' +
        ' where YERID in (select ID from SIPARISDETAY where SIPARISID=S.I' +
        'D))) then '#39'Transfer'#39' end'
      
        'from SIPARIS S (NOLOCK) inner join REHBER R on R.ID = S.REHBERID' +
        ' '
      'LEFT OUTER JOIN SIPARISDETAY SD ON S.ID = SD.SIPARISID'
      'where S.TUR=105')
    Properties.WordWrap = False
    TabOrder = 4
    Visible = False
    Height = 129
    Width = 588
  end
  object TabStokTalep: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      'distinct S.ID,S.DURUM,'
      'TALEPTARIH=SIPARISTARIH, TALEPNO=SIPARISNO,'
      'DETAYBOLUMU,'
      
        'TALEPEDENAD=(SELECT FIRMA FROM REHBER R WHERE S.SATICIKODU = R.I' +
        'D),'
      
        'TALEPEDENBIRIM=(select DEPARTMAN=(SELECT TOP 1 ANAHTAR FROM GENI' +
        'NI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 ) from' +
        ' ROLLER ROL where ROL.ID=S.BOLUM),'
      
        'BIRIMONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAY' +
        'LAYACAK = R.ID),'
      
        'BIRIMONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLA' +
        'YAN = R.ID),'
      
        'TALEPONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYAC' +
        'AK = R.ID),'
      
        'TALEPONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYAN =' +
        ' R.ID),'
      
        'PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.I' +
        'D),'
      
        'PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.I' +
        'D),'
      
        'PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.I' +
        'D),'
      'S.ACIKLAMA,S.OZELKOD,'
      'S.TIPI,S.REHBERID,S.TUR,S.SUBEID,'
      'S.ONAYLAYACAK,S.ONAYLAYAN'
      
        'from SIPARIS S (NOLOCK) inner join REHBER R on R.ID = S.REHBERID' +
        ' '
      'LEFT OUTER JOIN SIPARISDETAY SD ON S.ID = SD.SIPARISID'
      'where S.TUR=105')
    Left = 193
    Top = 117
  end
  object DtsStokTalep: TDataSource
    DataSet = TabStokTalep
    Left = 264
    Top = 119
  end
  object TabTalepDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select SD.* , ST.*,'
      
        'BIRIMAD = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-2702 and DIL=' +
        '-1 and DEGER = SD.BIRIM),'
      
        'BIRIM2AD=  (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM =-2702 ' +
        'and DEGER = ST.BIRIM2 ),'
      
        'KATEGORIADI=(select K.AD from KATEGORI K where K.ID=ST.KATEGORI)' +
        ','
      
        'PROJEKODU=(select P.PROJEKODU  from PROJELER P where P.ID=SD.PRO' +
        'JEID),'
      'MARKAADI=StokMarka.ANAHTAR,'
      'MODELADI=StokModel.ANAHTAR,'
      
        'GRUBUADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2704 and' +
        ' DEGER = ST.GRUBU and DIL=-1),'
      
        'OZELLIKADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2705 a' +
        'nd DEGER = ST.GRUBU and DIL=-1),'
      
        'ICERIKADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2718 an' +
        'd DEGER = ST.GRUBU and DIL=-1)'
      ''
      ''
      'FROM '
      #9'SIPARISDETAY SD   left outer join '
      #9'STOKLAR ST on SD.TUR=1 and SD.URUNID=ST.ID left outer join'
      
        #9'GENINI StokMarka ON StokMarka.DEGER = ST.MARKA AND StokMarka.BO' +
        'LUM=-2701 and StokMarka.DIL=-1 left outer join'
      
        #9'GENINI StokModel ON StokModel.DEGER = ST.MODEL and StokModel.DI' +
        'L=-1 AND StokModel.BOLUM=convert(int,'#39'-2701'#39'+convert(varchar(10)' +
        ',ST.MARKA))'
      ''
      'WHERE SD.SIPARISID = :Par')
    Left = 277
    Top = 268
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsTalepDetay: TDataSource
    DataSet = TabTalepDetay
    Left = 437
    Top = 207
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
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
    DataSet = TabTalepDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 200
    Top = 240
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'STOKTALEP'
    CloseDataSource = False
    DataSet = TabStokTalep
    BCDToCurrency = False
    DataSetOptions = []
    Left = 246
    Top = 168
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'TARIH'
        FieldAlias = 'TARIH'
      end
      item
        FieldName = 'TUR'
        FieldAlias = 'TUR'
      end
      item
        FieldName = 'TIPI'
        FieldAlias = 'TIPI'
      end
      item
        FieldName = 'REHBERID'
        FieldAlias = 'REHBERID'
      end
      item
        FieldName = 'PROJEID'
        FieldAlias = 'PROJEID'
      end
      item
        FieldName = 'AKTIVITEID'
        FieldAlias = 'AKTIVITEID'
      end
      item
        FieldName = 'ANAKAYITID'
        FieldAlias = 'ANAKAYITID'
      end
      item
        FieldName = 'FATURATARIH'
        FieldAlias = 'FATURATARIH'
      end
      item
        FieldName = 'KOCANNO'
        FieldAlias = 'KOCANNO'
      end
      item
        FieldName = 'FATURANO'
        FieldAlias = 'FATURANO'
      end
      item
        FieldName = 'GIRISDEPO'
        FieldAlias = 'GIRISDEPO'
      end
      item
        FieldName = 'CIKISDEPO'
        FieldAlias = 'CIKISDEPO'
      end
      item
        FieldName = 'BASLIK'
        FieldAlias = 'BASLIK'
      end
      item
        FieldName = 'ADRES'
        FieldAlias = 'ADRES'
      end
      item
        FieldName = 'ILCE'
        FieldAlias = 'ILCE'
      end
      item
        FieldName = 'IL'
        FieldAlias = 'IL'
      end
      item
        FieldName = 'VD'
        FieldAlias = 'VD'
      end
      item
        FieldName = 'VNO'
        FieldAlias = 'VNO'
      end
      item
        FieldName = 'KDVDURUM'
        FieldAlias = 'KDVDURUM'
      end
      item
        FieldName = 'LOTNO'
        FieldAlias = 'LOTNO'
      end
      item
        FieldName = 'ACIK_KAPALI'
        FieldAlias = 'ACIK_KAPALI'
      end
      item
        FieldName = 'FATURA_GON_TARIHI'
        FieldAlias = 'FATURA_GON_TARIHI'
      end
      item
        FieldName = 'FATURA_MATRAHI'
        FieldAlias = 'FATURA_MATRAHI'
      end
      item
        FieldName = 'KDV_TUTARI'
        FieldAlias = 'KDV_TUTARI'
      end
      item
        FieldName = 'FATURA_TUTARI'
        FieldAlias = 'FATURA_TUTARI'
      end
      item
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end
      item
        FieldName = 'DOVIZ_TUTARI'
        FieldAlias = 'DOVIZ_TUTARI'
      end
      item
        FieldName = 'DOVIZ_KURU'
        FieldAlias = 'DOVIZ_KURU'
      end
      item
        FieldName = 'KASA'
        FieldAlias = 'KASA'
      end
      item
        FieldName = 'ONAY'
        FieldAlias = 'ONAY'
      end
      item
        FieldName = 'SAYFA'
        FieldAlias = 'SAYFA'
      end
      item
        FieldName = 'MASRAFID'
        FieldAlias = 'MASRAFID'
      end
      item
        FieldName = 'ACIKLAMA'
        FieldAlias = 'ACIKLAMA'
      end
      item
        FieldName = 'ISYERI'
        FieldAlias = 'ISYERI'
      end
      item
        FieldName = 'BOLUM'
        FieldAlias = 'BOLUM'
      end
      item
        FieldName = 'AMBAR'
        FieldAlias = 'AMBAR'
      end
      item
        FieldName = 'SATICIKODU'
        FieldAlias = 'SATICIKODU'
      end
      item
        FieldName = 'DURUM'
        FieldAlias = 'DURUM'
      end
      item
        FieldName = 'IRSALIYE_TIPI'
        FieldAlias = 'IRSALIYE_TIPI'
      end
      item
        FieldName = 'IRSALIYE_NO'
        FieldAlias = 'IRSALIYE_NO'
      end
      item
        FieldName = 'ODEMEPLANI'
        FieldAlias = 'ODEMEPLANI'
      end
      item
        FieldName = 'OZELKOD'
        FieldAlias = 'OZELKOD'
      end
      item
        FieldName = 'YETKIKODU'
        FieldAlias = 'YETKIKODU'
      end
      item
        FieldName = 'R'
        FieldAlias = 'R'
      end
      item
        FieldName = 'EKLEYEN'
        FieldAlias = 'EKLEYEN'
      end
      item
        FieldName = 'EKLEMETARIHI'
        FieldAlias = 'EKLEMETARIHI'
      end
      item
        FieldName = 'DEGISTIREN'
        FieldAlias = 'DEGISTIREN'
      end
      item
        FieldName = 'DEGISTIRMETARIHI'
        FieldAlias = 'DEGISTIRMETARIHI'
      end
      item
        FieldName = 'EKVERGI'
        FieldAlias = 'EKVERGI'
      end
      item
        FieldName = 'FATURASERI'
        FieldAlias = 'FATURASERI'
      end
      item
        FieldName = 'IRSALIYENO'
        FieldAlias = 'IRSALIYENO'
      end
      item
        FieldName = 'IRSALIYETARIH'
        FieldAlias = 'IRSALIYETARIH'
      end
      item
        FieldName = 'PLANID'
        FieldAlias = 'PLANID'
      end
      item
        FieldName = 'FIYAT_LISTESI'
        FieldAlias = 'FIYAT_LISTESI'
      end
      item
        FieldName = 'STOKISK'
        FieldAlias = 'STOKISK'
      end
      item
        FieldName = 'HIZMETISK'
        FieldAlias = 'HIZMETISK'
      end
      item
        FieldName = 'VADE'
        FieldAlias = 'VADE'
      end
      item
        FieldName = 'KASATAKIPID'
        FieldAlias = 'KASATAKIPID'
      end
      item
        FieldName = 'DETAYBOLUMU'
        FieldAlias = 'DETAYBOLUMU'
      end
      item
        FieldName = 'YAZIYLATOPLAM'
        FieldAlias = 'YAZIYLATOPLAM'
      end>
  end
  object StokTalep: TFDQuery
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
        ParamType = ptInput
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
    Images = Tablo.PNGImageList2
    Left = 446
    Top = 109
    object TalepInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = TalepInfoMenuClick
    end
    object MenuTansfereDonustur: TMenuItem
      Caption = 'Transfere D'#246'n'#252#351't'#252'r'
      ImageIndex = 0
      OnClick = MenuTansfereDonusturClick
    end
    object MenuHedefBelgeAc: TMenuItem
      Caption = 'Hedef Belgeyi A'#231
      ImageIndex = 19
      OnClick = MenuHedefBelgeAcClick
    end
  end
end
