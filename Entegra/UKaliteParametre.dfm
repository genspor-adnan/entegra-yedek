object KaliteParametreDlg: TKaliteParametreDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Fiyat Listeleme ve D'#252'zenleme Ekran'#305
  ClientHeight = 619
  ClientWidth = 1476
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
    Width = 513
    Height = 585
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 511
      Height = 32
      Align = alTop
      TabOrder = 0
      object cxLabel10: TcxLabel
        Left = 8
        Top = 3
        Caption = 'Stok Ara'
        Transparent = True
      end
      object EditStokAra: TcxTextEdit
        Left = 67
        Top = 3
        TabOrder = 1
        OnKeyUp = EditStokAraKeyUp
        Width = 143
      end
    end
    object GridStokHizmetListesi: TcxGrid
      Left = 1
      Top = 33
      Width = 511
      Height = 551
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
        OptionsView.Indicator = True
        object StokHizmetListesiViewID: TcxGridDBColumn
          Caption = 'Id'
          DataBinding.FieldName = 'ID'
          Visible = False
          Width = 33
        end
        object StokHizmetListesiViewSTOKID: TcxGridDBColumn
          DataBinding.FieldName = 'STOKID'
          Visible = False
        end
        object StokHizmetListesiViewKOD: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'KOD'
          Width = 94
        end
        object StokHizmetListesiViewAD: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'STOKADI'
          Width = 154
        end
        object StokHizmetListesiViewKATEGORI: TcxGridDBColumn
          Caption = 'Kategori'
          DataBinding.FieldName = 'KATEGORI'
          Width = 99
        end
        object StokHizmetListesiViewSABLON: TcxGridDBColumn
          Caption = #350'ablon'
          DataBinding.FieldName = 'SABLON'
          Width = 111
        end
      end
      object GridStokHizmetListesiLevel1: TcxGridLevel
        GridView = StokHizmetListesiView
      end
    end
    object SQLStok: TMemo
      Left = 109
      Top = 231
      Width = 262
      Height = 57
      Lines.Strings = (
        'select * from ('
        'select ID, KOD, STOKADI,'
        'KATEGORI=(select K.AD from KATEGORI K where '
        'S.KATEGORI=K.ID),'
        'SABLON=(select ADI from KALITESABLON KS where '
        'S.KALITESABLONID=KS.ID)'
        'from STOKLAR S'
        ')as List'
        'where '
        'KOD like :PRM1 or STOKADI like :PRM1 or '
        'KATEGORI like :PRM1 or SABLON like :PRM1'
        'order by 3')
      TabOrder = 2
      Visible = False
    end
    object SQLSablon: TMemo
      Left = 248
      Top = 343
      Width = 262
      Height = 57
      Lines.Strings = (
        'select * from KALITESABLON'
        'where ADI like :PRM1')
      TabOrder = 3
      Visible = False
    end
    object CheckStok: TcxCheckBox
      Left = 217
      Top = 3
      Caption = #350'ablon Getir'
      TabOrder = 4
    end
  end
  object ToolBar5: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1470
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
    object cxLabel1: TcxLabel
      Left = 0
      Top = 1
      Caption = '     '
      ParentColor = False
      Style.BorderColor = clActiveBorder
      Style.Color = clActiveBorder
      Transparent = True
    end
    object Kaydet: TToolButton
      Left = 19
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
    end
    object ToolButton3: TToolButton
      Left = 81
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 14
    end
  end
  object Panel3: TPanel
    Left = 513
    Top = 27
    Width = 963
    Height = 585
    Align = alClient
    TabOrder = 3
    object cxGroupBox1: TcxGroupBox
      Left = 1
      Top = 209
      Align = alClient
      Alignment = alTopCenter
      Caption = #350'ablon '#304#231'eri'#287'i'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 1
      Height = 375
      Width = 961
      object GridFiyatAlis: TcxGrid
        Left = 2
        Top = 46
        Width = 957
        Height = 327
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object FiyatAlisView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsSablonDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.GroupByBox = False
          object FiyatAlisViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object FiyatAlisViewKALITESABLONID: TcxGridDBColumn
            DataBinding.FieldName = 'KALITESABLONID'
            Visible = False
            Width = 99
          end
          object FiyatAlisViewADI: TcxGridDBColumn
            Caption = 'Test'
            DataBinding.FieldName = 'ADI'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = FiyatAlisViewADIPropertiesButtonClick
            Width = 143
          end
          object FiyatAlisViewTESTID: TcxGridDBColumn
            DataBinding.FieldName = 'TESTID'
            Visible = False
          end
          object FiyatAlisViewLIMITYAZI: TcxGridDBColumn
            Caption = 'Bilgi'
            DataBinding.FieldName = 'LIMITYAZI'
            Width = 138
          end
          object FiyatAlisViewLIMITALT: TcxGridDBColumn
            Caption = 'Alt Limit'
            DataBinding.FieldName = 'LIMITALT'
          end
          object FiyatAlisViewLIMITUST: TcxGridDBColumn
            Caption = #220'st Limit'
            DataBinding.FieldName = 'LIMITUST'
          end
          object FiyatAlisViewBIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repStokAnaBirim
          end
          object FiyatAlisViewTOLERANSTIPI: TcxGridDBColumn
            Caption = 'Tip'
            DataBinding.FieldName = 'TOLERANSTIPI'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = '+-'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = '+'
                Value = 2
              end
              item
                Description = '-'
                Value = 3
              end
              item
                Description = '%'
                Value = 4
              end
              item
                Description = 'Binde'
                Value = 5
              end>
          end
          object FiyatAlisViewTOLERANSDEGERI: TcxGridDBColumn
            Caption = 'Tolerans'
            DataBinding.FieldName = 'TOLERANSDEGERI'
          end
          object FiyatAlisViewMIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
          end
          object FiyatAlisViewOLCUALETI: TcxGridDBColumn
            Caption = #214'l'#231#252' Aleti'
            DataBinding.FieldName = 'OLCUALETI'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepKaliteOlcuAleti
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = FiyatAlisView
        end
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 5
        Top = 22
        Width = 951
        Height = 24
        Margins.Bottom = 0
        Anchors = [akLeft]
        AutoSize = True
        ButtonWidth = 61
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
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
        object YeniSablonDetayTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = YeniSablonDetayTusClick
        end
        object KaydetSablonDetayTus: TToolButton
          Left = 61
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = KaydetSablonDetayTusClick
        end
        object SilSablonDetayTus: TToolButton
          Left = 122
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SilSablonDetayTusClick
        end
        object IptalSablonDetayTus: TToolButton
          Left = 183
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = IptalSablonDetayTusClick
        end
      end
    end
    object cxGroupBox2: TcxGroupBox
      Left = 1
      Top = 1
      Align = alTop
      Alignment = alTopCenter
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -12
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 0
      Height = 208
      Width = 961
      object GridFiyatSatis: TcxGrid
        Left = 2
        Top = 78
        Width = 957
        Height = 128
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object FiyatSatisView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          OnCanFocusRecord = FiyatSatisViewCanFocusRecord
          OnSelectionChanged = FiyatSatisViewSelectionChanged
          DataController.DataSource = DtsSablon
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.MultiSelect = True
          OptionsView.GroupByBox = False
          object FiyatSatisViewADI: TcxGridDBColumn
            Caption = 'Ad'#305
            DataBinding.FieldName = 'ADI'
            Width = 300
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = FiyatSatisView
        end
      end
      object ToolBar12: TToolBar
        AlignWithMargins = True
        Left = 5
        Top = 54
        Width = 951
        Height = 24
        Margins.Bottom = 0
        Anchors = [akLeft]
        AutoSize = True
        ButtonWidth = 73
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
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
        object YeniSablonTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = YeniSablonTusClick
        end
        object KaydetSablonTus: TToolButton
          Left = 73
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = KaydetSablonTusClick
        end
        object SilSablonTus: TToolButton
          Left = 146
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SilSablonTusClick
        end
        object IptalSablonTus: TToolButton
          Left = 219
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = IptalSablonTusClick
        end
        object ToolButton2: TToolButton
          Left = 292
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 5
          Style = tbsSeparator
        end
        object BtnStokaAta: TToolButton
          Left = 300
          Top = 0
          Caption = 'Stoka Ata'
          ImageIndex = 23
          OnClick = BtnStokaAtaClick
        end
        object ToolButton4: TToolButton
          Left = 373
          Top = 0
          Width = 8
          Caption = 'ToolButton4'
          ImageIndex = 5
          Style = tbsSeparator
        end
      end
      object Panel4: TPanel
        Left = 2
        Top = 19
        Width = 957
        Height = 32
        Align = alTop
        TabOrder = 2
        object cxLabel2: TcxLabel
          Left = 6
          Top = 8
          Caption = #350'ablon Ara'
          Transparent = True
        end
        object EditSablonAra: TcxTextEdit
          Left = 91
          Top = 5
          TabOrder = 1
          OnKeyUp = EditSablonAraKeyUp
          Width = 214
        end
        object CheckSablon: TcxCheckBox
          Left = 311
          Top = 4
          Caption = 'Stok Getir'
          TabOrder = 2
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 612
    Width = 1476
    Height = 7
    AlignSplitter = salBottom
    Control = Panel3
  end
  object TabStokListesi: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabStokListesiAfterOpen
    ParamData = <>
    Left = 104
    Top = 137
    object TabStokListesiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabStokListesiKOD: TWideStringField
      FieldName = 'KOD'
      Size = 25
    end
    object TabStokListesiSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabStokListesiKATEGORI: TWideStringField
      FieldName = 'KATEGORI'
      ReadOnly = True
      Size = 50
    end
    object TabStokListesiSABLON: TWideStringField
      FieldName = 'SABLON'
      ReadOnly = True
      Size = 100
    end
  end
  object DsStokHizmetListesi: TDataSource
    DataSet = TabStokListesi
    Left = 102
    Top = 181
  end
  object TabSablonDetay: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabSablonDetayBeforePost
    OnCalcFields = TabSablonDetayCalcFields
    OnNewRecord = TabSablonDetayNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from KALITESABLONDETAY KSD '
      'where '
      'YER=10'
      'and KSD.YERID=:PRM1 '
      ' order by SIRA, KSD.ID'
      ''
      '')
    Left = 693
    Top = 425
    object TabSablonDetayID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabSablonDetayADI: TStringField
      FieldKind = fkCalculated
      FieldName = 'ADI'
      Calculated = True
    end
    object TabSablonDetayTESTID: TIntegerField
      FieldName = 'TESTID'
    end
    object TabSablonDetayBILGI: TStringField
      FieldKind = fkCalculated
      FieldName = 'BILGI'
      Calculated = True
    end
    object TabSablonDetayLIMITYAZI: TWideStringField
      FieldName = 'LIMITYAZI'
      Size = 50
    end
    object TabSablonDetayLIMITALT: TBCDField
      FieldName = 'LIMITALT'
      Precision = 12
      Size = 2
    end
    object TabSablonDetayLIMITUST: TBCDField
      FieldName = 'LIMITUST'
      Precision = 12
      Size = 2
    end
    object TabSablonDetayTOLERANSTIPI: TWordField
      FieldName = 'TOLERANSTIPI'
    end
    object TabSablonDetayTOLERANSDEGERI: TBCDField
      FieldName = 'TOLERANSDEGERI'
      Precision = 12
      Size = 2
    end
    object TabSablonDetayEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabSablonDetayEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabSablonDetayDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabSablonDetayDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabSablonDetayMIKTAR: TBCDField
      FieldName = 'MIKTAR'
      Precision = 12
      Size = 2
    end
    object TabSablonDetayBIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object TabSablonDetayOLCUALETI: TSmallintField
      FieldName = 'OLCUALETI'
    end
    object TabSablonDetayYER: TIntegerField
      FieldName = 'YER'
    end
    object TabSablonDetayYERID: TIntegerField
      FieldName = 'YERID'
    end
  end
  object DtsSablonDetay: TDataSource
    DataSet = TabSablonDetay
    OnStateChange = DtsSablonDetayStateChange
    Left = 718
    Top = 501
  end
  object TabSablon: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabSablonBeforePost
    AfterScroll = TabSablonAfterScroll
    ParamData = <>
    Left = 581
    Top = 137
    object TabSablonID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabSablonADI: TWideStringField
      FieldName = 'ADI'
      Size = 100
    end
    object TabSablonEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabSablonEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabSablonDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabSablonDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
  end
  object DtsSablon: TDataSource
    DataSet = TabSablon
    OnStateChange = DtsSablonStateChange
    Left = 678
    Top = 157
  end
end
