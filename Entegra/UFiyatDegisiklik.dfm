object FiyatDegisiklikDlg: TFiyatDegisiklikDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Fiyat Listeleme ve D'#252'zenleme Ekran'#305
  ClientHeight = 619
  ClientWidth = 1208
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 27
    Width = 1208
    Height = 326
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 1206
      Height = 63
      Align = alTop
      TabOrder = 0
      object GroupBox1: TcxGroupBox
        Left = 2
        Top = 2
        BiDiMode = bdLeftToRight
        Caption = 'T'#252'r'
        ParentBiDiMode = False
        Style.LookAndFeel.NativeStyle = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 0
        Height = 56
        Width = 119
        object RbStoklar: TcxRadioButton
          Left = 5
          Top = 13
          Width = 52
          Height = 21
          Caption = 'Stoklar'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RbStoklarClick
          Transparent = True
        end
        object RbHizmetler: TcxRadioButton
          Left = 5
          Top = 34
          Width = 63
          Height = 19
          Caption = 'Hizmetler'
          TabOrder = 1
          OnClick = RbStoklarClick
          Transparent = True
        end
      end
      object cxLabel3: TcxLabel
        Left = 577
        Top = 6
        Cursor = crHandPoint
        Caption = 'T'#252'm'#252'n'#252' Se'#231
        ParentColor = False
        Style.Color = clBtnFace
        Style.TextColor = clNavy
        Transparent = True
        OnClick = HepsiniSe1Click
      end
      object cxLabel4: TcxLabel
        Left = 577
        Top = 23
        Cursor = crHandPoint
        Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
        ParentColor = False
        Style.Color = clBtnFace
        Style.TextColor = clNavy
        Transparent = True
        OnClick = Kaldr1Click
      end
      object cxLabel5: TcxLabel
        Left = 577
        Top = 41
        Cursor = crHandPoint
        Caption = 'Se'#231'imi Ters '#199'evir'
        ParentColor = False
        Style.Color = clBtnFace
        Style.TextColor = clNavy
        Transparent = True
        OnClick = SeimiTersevir1Click
      end
      object GroupBox3: TcxGroupBox
        Left = 140
        Top = 2
        Alignment = alTopCenter
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Style.LookAndFeel.NativeStyle = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 1
        Height = 56
        Width = 205
        object EditAra: TcxTextEdit
          Left = 59
          Top = 21
          TabOrder = 1
          OnKeyUp = EditAraKeyUp
          Width = 143
        end
        object cxLabel10: TcxLabel
          Left = 3
          Top = 21
          Caption = 'Ara'
          Transparent = True
        end
      end
      object GroupBox2: TcxGroupBox
        Left = 368
        Top = 2
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Style.LookAndFeel.NativeStyle = True
        StyleDisabled.LookAndFeel.NativeStyle = True
        StyleFocused.LookAndFeel.NativeStyle = True
        StyleHot.LookAndFeel.NativeStyle = True
        TabOrder = 2
        Height = 56
        Width = 176
        object ComboAlis: TcxImageComboBox
          Left = 49
          Top = 32
          Properties.Items = <>
          Properties.OnCloseUp = ComboAlisPropertiesCloseUp
          TabOrder = 0
          Width = 121
        end
        object cxLabel7: TcxLabel
          Left = 3
          Top = 14
          Caption = 'T'#252'r'
          Transparent = True
        end
        object cxLabel8: TcxLabel
          Left = 3
          Top = 34
          Caption = 'Fiyat'
          Transparent = True
        end
        object ComboSatis: TcxImageComboBox
          Left = 51
          Top = 32
          Properties.Items = <>
          Properties.OnCloseUp = ComboAlisPropertiesCloseUp
          TabOrder = 2
          Width = 121
        end
        object cxRadioButton1: TcxRadioButton
          Left = 44
          Top = 10
          Width = 47
          Height = 21
          Caption = 'Al'#305#351
          TabOrder = 4
          OnClick = cxRadioButton1Click
          GroupIndex = 1
          Transparent = True
        end
        object RadioSatis: TcxRadioButton
          Left = 95
          Top = 11
          Width = 63
          Height = 19
          Caption = 'Sat'#305#351
          Checked = True
          TabOrder = 5
          TabStop = True
          OnClick = RadioSatisClick
          GroupIndex = 1
          Transparent = True
        end
      end
      object ComboBirim: TcxImageComboBox
        Left = 858
        Top = 11
        Properties.Items = <>
        Properties.OnCloseUp = ComboBirimPropertiesCloseUp
        TabOrder = 6
        Visible = False
        Width = 143
      end
      object LblBirimler: TcxLabel
        Left = 810
        Top = 13
        Caption = 'Birimler'
        Transparent = True
        Visible = False
      end
    end
    object GridStokHizmetListesi: TcxGrid
      Left = 1
      Top = 64
      Width = 1206
      Height = 261
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      object StokHizmetListesiView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        OnCanFocusRecord = StokHizmetListesiViewCanFocusRecord
        OnSelectionChanged = StokHizmetListesiViewSelectionChanged
        DataController.DataSource = DsStokHizmetListesi
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsSelection.MultiSelect = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object StokHizmetListesiViewID: TcxGridDBColumn
          Caption = 'Id'
          DataBinding.FieldName = 'ID'
          Visible = False
          Styles.Content = Tablo.cxStyle22
          Width = 33
        end
        object StokHizmetListesiViewSTOKID: TcxGridDBColumn
          DataBinding.FieldName = 'STOKID'
          Visible = False
          Styles.Content = Tablo.cxStyle22
        end
        object StokHizmetListesiViewKOD: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KOD'
          Styles.Content = Tablo.cxStyle22
          Width = 125
        end
        object StokHizmetListesiViewAD: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'AD'
          Styles.Content = Tablo.cxStyle22
          Width = 269
        end
        object StokHizmetListesiViewGRUBU: TcxGridDBColumn
          Caption = 'Kategori'
          DataBinding.FieldName = 'KATEGORI'
          Styles.Content = Tablo.cxStyle22
          Width = 127
        end
        object StokHizmetListesiViewKDV: TcxGridDBColumn
          DataBinding.FieldName = 'KDV'
          Styles.Content = Tablo.cxStyle22
          Width = 54
        end
        object StokHizmetListesiViewBIRIM: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'BIRIM'
          RepositoryItem = Tablo.repStokAnaBirim
          Width = 52
        end
        object StokHizmetListesiViewFIYATALIS: TcxGridDBColumn
          Caption = 'Fiyat'
          DataBinding.FieldName = 'FIYAT'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;'
          RepositoryItem = Tablo.RepCurrencyBF
          Width = 69
        end
        object StokHizmetListesiViewALISKUR: TcxGridDBColumn
          Caption = 'P.Birimi'
          DataBinding.FieldName = 'KUR'
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        end
        object StokHizmetListesiViewKDVDURUM: TcxGridDBColumn
          Caption = 'KDV Durum'
          DataBinding.FieldName = 'KDVDURUM'
          RepositoryItem = Tablo.RepKDVDurum
          Width = 87
        end
      end
      object GridStokHizmetListesiLevel1: TcxGridLevel
        GridView = StokHizmetListesiView
      end
    end
    object SQLStok: TMemo
      Left = 141
      Top = 96
      Width = 492
      Height = 57
      Lines.Strings = (
        'select * from ('
        'select ID,STOKID,'
        'KOD=(select KOD from STOKLAR S where S.ID=SF.STOKID),'
        'AD=(select STOKADI from STOKLAR S where S.ID=SF.STOKID ),'
        'KATEGORI=(select K.AD from STOKLAR S inner join KATEGORI K'
        'on S.KATEGORI=K.ID where   S.ID=SF.STOKID),'
        'KDV=(select KDV from STOKLAR S where S.ID=SF.STOKID),'
        'FIYATADI,BIRIM,FIYAT,KUR,KDVDURUM,SATIS from STOKFIYAT SF) as TT'
        'where SATIS=:PRM1 and'
        'FIYATADI=:PRM2'
        'and (KOD like :PRM3 or AD like :PRM4 or KATEGORI like :PRM5)'
        'order by 3'
        ''
        ''
        '')
      TabOrder = 2
      Visible = False
    end
    object SQLHizmet: TMemo
      Left = 141
      Top = 191
      Width = 492
      Height = 50
      Lines.Strings = (
        'select ID, STOKID=SF.HIZMETID,KOD=(select KOD from'
        'MASRAFGELIR S where S.ID=SF.HIZMETID),'
        'AD=(select AD from MASRAFGELIR S where S.ID=SF.HIZMETID),'
        'KATEGORI=NULL,'
        'KDV=(select KDV from MASRAFGELIR S where'
        'S.ID=SF.HIZMETID),'
        'FIYATADI,BIRIM=NULL,FIYAT,KUR,'
        'KDVDURUM '
        ' from FIYATLAR SF'
        'where SATIS=:PRM1 and '
        'FIYATADI=:PRM2'
        ' order by 3')
      TabOrder = 3
      Visible = False
    end
  end
  object ToolBar5: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1202
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 62
    Caption = 'AletCubugu'
    Color = clScrollBar
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
    Images = Tablo.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object YaziciYaz: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 8
    end
    object cxLabel1: TcxLabel
      Left = 62
      Top = 1
      Caption = '     '
      ParentColor = False
      Style.BorderColor = clActiveBorder
      Style.Color = clActiveBorder
      Transparent = True
    end
    object Kaydet: TToolButton
      Left = 81
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
    end
    object ToolButton3: TToolButton
      Left = 143
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 14
      OnClick = ToolButton3Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 360
    Width = 1208
    Height = 259
    Align = alBottom
    TabOrder = 3
    object cxGroupBox1: TcxGroupBox
      Left = 489
      Top = 1
      Align = alLeft
      Alignment = alTopCenter
      Caption = 'Al'#305#351
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 1
      ExplicitLeft = 417
      Height = 257
      Width = 496
      object GridFiyatAlis: TcxGrid
        Left = 2
        Top = 19
        Width = 492
        Height = 236
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        PopupMenu = PMSagClick
        TabOrder = 0
        OnContextPopup = GridFiyatAlisContextPopup
        OnExit = GridFiyatAlisExit
        ExplicitWidth = 415
        object FiyatAlisView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DsFiyatAlis
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.GroupByBox = False
          object FiyatAlisViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
            Width = 40
          end
          object FiyatAlisViewFIYATADI: TcxGridDBColumn
            Caption = 'Fiyat Ad'#305
            DataBinding.FieldName = 'FIYATAD'
            Options.Editing = False
            Width = 145
          end
          object FiyatAlisViewFIYAT: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'FIYAT'
            RepositoryItem = Tablo.RepCurrencyBF
            Width = 95
          end
          object FiyatAlisViewKUR: TcxGridDBColumn
            Caption = 'P. Birimi'
            DataBinding.FieldName = 'KUR'
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            Width = 56
          end
          object FiyatAlisViewKDVDURUM: TcxGridDBColumn
            Caption = 'KDV Durum'
            DataBinding.FieldName = 'KDVDURUM'
            RepositoryItem = Tablo.RepKDVDurum
            Width = 73
          end
          object FiyatAlisViewDEGISTIRMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'DEGISTIRMETARIHI'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ReadOnly = True
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = FiyatAlisView
        end
      end
    end
    object cxGroupBox2: TcxGroupBox
      Left = 1
      Top = 1
      Align = alLeft
      Alignment = alTopCenter
      Caption = 'Sat'#305#351
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 0
      Height = 257
      Width = 488
      object GridFiyatSatis: TcxGrid
        Left = 2
        Top = 19
        Width = 484
        Height = 236
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        PopupMenu = PMSagClick
        TabOrder = 0
        OnContextPopup = GridFiyatSatisContextPopup
        OnExit = GridFiyatSatisExit
        ExplicitWidth = 412
        object FiyatSatisView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DsFiyatSatis
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.GroupByBox = False
          object FiyatSatisViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
            Width = 40
          end
          object FiyatSatisViewFIYATADI: TcxGridDBColumn
            Caption = 'Fiyat Ad'#305
            DataBinding.FieldName = 'FIYATADI'
            RepositoryItem = Tablo.RepFiyatAdlari
            Options.Editing = False
            Width = 146
          end
          object FiyatSatisViewFIYAT: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'FIYAT'
            RepositoryItem = Tablo.RepCurrencyBF
            Width = 95
          end
          object FiyatSatisViewKUR: TcxGridDBColumn
            Caption = 'P. Birimi'
            DataBinding.FieldName = 'KUR'
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            Width = 61
          end
          object FiyatSatisViewKDVDURUM: TcxGridDBColumn
            Caption = 'KDV Durum'
            DataBinding.FieldName = 'KDVDURUM'
            RepositoryItem = Tablo.RepKDVDurum
            Width = 73
          end
          object FiyatSatisViewDEGISTIRMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'DEGISTIRMETARIHI'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ReadOnly = True
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = FiyatSatisView
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 353
    Width = 1208
    Height = 7
    AlignSplitter = salBottom
    Control = Panel3
  end
  object DtsFiyatDegisiklik: TDataSource
    DataSet = TabFiyatDegisiklik
    Left = 542
    Top = 213
  end
  object TabFiyatDegisiklik: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        ' /* IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ' +
        #39'##FIYATLAR_SPID%'#39')'
      ' DROP TABLE ##FIYATLAR_SPID_ '
      ' CREATE TABLE ##FIYATLAR_SPID_( '
      
        'ID int,KOD nvarchar(50),AD nvarchar(100),TUTAR Money,KUR nvarcha' +
        'r(5) )'
      ' INSERT INTO ##FIYATLAR_SPID_ '
      ''
      ''
      'Select MS.ID,MS.KOD,AD=MS.STOKADI,F.FIYAT,F.KUR from STOKLAR MS '
      ' left outer join STOKFIYAT F on MS.ID=F.STOKID and F.FIYATADI=2'
      ''
      ' order by 2 */'
      ' '
      ' select * from ##FIYATLAR_SPID_ ')
    Left = 544
    Top = 149
  end
  object PMSagClick: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 393
    Top = 136
    object Yeni1: TMenuItem
      Caption = 'Yeni Fiyat Listesi Olu'#351'tur'
      ImageIndex = 32
      OnClick = Yeni1Click
    end
    object Kopyala1: TMenuItem
      Tag = 1
      Caption = 'Fiyat Listesini Kopyala'
      ImageIndex = 10
      OnClick = SubMenuClick
    end
    object AdDegistir1: TMenuItem
      Tag = 2
      Caption = 'Fiyat Listesinin Ad'#305'n'#305' De'#287'i'#351'tir'
      ImageIndex = 32
      OnClick = SubMenuClick
    end
    object Sil1: TMenuItem
      Tag = 3
      Caption = 'Fiyat Listesini Sil'
      ImageIndex = 1
      OnClick = SubMenuClick
    end
    object Tasi1: TMenuItem
      Tag = 4
      Caption = 'Fiyat Listesini Ta'#351#305
      ImageIndex = 32
      OnClick = SubMenuClick
    end
    object EksikFiyatlarVarsaOlusturMenu: TMenuItem
      Tag = 9
      Caption = 'Eksik Fiyatlar Varsa Olu'#351'tur'
      ImageIndex = 34
      OnClick = SubMenuClick
    end
    object FiyatGuncelle1: TMenuItem
      Caption = 'Fiyat Listesinin Tutar'#305'n'#305' G'#252'ncelle'
      ImageIndex = 32
      object FiyatGir1: TMenuItem
        Tag = 1
        Caption = 'Tutar Gir'
        ImageIndex = 34
        OnClick = SubMenuFiyatGirClick
      end
      object OranGir1: TMenuItem
        Tag = 2
        Caption = '% Oran Gir'
        ImageIndex = 34
        OnClick = SubMenuFiyatGirClick
      end
      object utarKDVOranKadarArtr1: TMenuItem
        Tag = 3
        Caption = 'Tutar'#305' KDV Oran'#305' Kadar Art'#305'r'
        ImageIndex = 34
        OnClick = SubMenuFiyatGirClick
      end
      object utarKDVOranKadarArtr2: TMenuItem
        Tag = 4
        Caption = 'Tutar'#305' KDV Oran'#305' Kadar Azalt'
        ImageIndex = 34
        OnClick = SubMenuFiyatGirClick
      end
      object cizgi2: TMenuItem
        Caption = '-'
      end
    end
    object KDVGuncelle: TMenuItem
      Caption = 'Fiyat Listesinin KDV Durumunu G'#252'ncelle'
      ImageIndex = 32
      object KDVHaric: TMenuItem
        Caption = '+KDV'
        ImageIndex = 34
        OnClick = KDVDurumGuncelle
      end
      object KdvDahil: TMenuItem
        Tag = 1
        Caption = 'Dahil'
        ImageIndex = 15
        OnClick = KDVDurumGuncelle
      end
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 686
    Top = 180
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
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxStokHizmetListesi: TfrxDBDataset
    UserName = 'TabStokHizmetListesi'
    CloseDataSource = False
    DataSet = TabStokHizmetListesi
    BCDToCurrency = False
    Left = 544
    Top = 280
  end
  object frxReport1: TfrxReport
    Version = '4.13.1'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 40843.734807476850000000
    ReportOptions.LastChange = 40889.556221712960000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 656
    Top = 120
    Datasets = <
      item
        DataSet = frxStokHizmetListesi
        DataSetName = 'TabStokHizmetListesi'
      end>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
      object MasterData1: TfrxMasterData
        Height = 22.677180000000000000
        Top = 18.897650000000000000
        Width = 718.110700000000000000
        DataSet = frxStokHizmetListesi
        DataSetName = 'TabStokHizmetListesi'
        RowCount = 0
      end
    end
  end
  object pmSecKaldir: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 392
    Top = 192
    object HepsiniSe1: TMenuItem
      Caption = 'Hepsini Se'#231
      ImageIndex = 23
      OnClick = HepsiniSe1Click
    end
    object Kaldr1: TMenuItem
      Caption = 'Hepsini Kald'#305'r'
      ImageIndex = 24
      OnClick = Kaldr1Click
    end
    object SeimiTersevir1: TMenuItem
      Caption = 'Se'#231'imi Ters '#199'evir'
      ImageIndex = 9
      OnClick = SeimiTersevir1Click
    end
  end
  object TabStokHizmetListesi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 104
    Top = 137
  end
  object DsStokHizmetListesi: TDataSource
    DataSet = TabStokHizmetListesi
    Left = 102
    Top = 181
  end
  object TabFiyatAlis: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 213
    Top = 233
  end
  object DsFiyatAlis: TDataSource
    DataSet = TabFiyatAlis
    Left = 214
    Top = 277
  end
  object TabFiyatSatis: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 205
    Top = 121
  end
  object DsFiyatSatis: TDataSource
    DataSet = TabFiyatSatis
    Left = 206
    Top = 165
  end
end
