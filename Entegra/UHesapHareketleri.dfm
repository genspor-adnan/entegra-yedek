object HesapHareketleriDlg: THesapHareketleriDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Hesap Hareketleri Aktar'#305'm'#305
  ClientHeight = 578
  ClientWidth = 979
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object ToolBar2: TToolBar
    Left = 0
    Top = 0
    Width = 979
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 117
    Caption = 'AletCubugu'
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList2
    List = True
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    Wrapable = False
    object BtnYenile: TToolButton
      Left = 0
      Top = 0
      AutoSize = True
      Caption = 'Hareketleri Yenile'
      ImageIndex = 9
      OnClick = BtnYenileClick
    end
    object BtnEslestir: TToolButton
      Left = 121
      Top = 0
      Caption = 'Se'#231'ilileri E'#351'le'#351'tir'
      ImageIndex = 12
      OnClick = BtnEslestirClick
    end
    object BtnAktar: TToolButton
      Left = 238
      Top = 0
      AutoSize = True
      Caption = 'Se'#231'ilileri Aktar'
      ImageIndex = 10
      OnClick = BtnAktarClick
    end
    object BtnTanimlamalar: TToolButton
      Left = 341
      Top = 0
      AutoSize = True
      Caption = 'Tan'#305'mlamalar'
      ImageIndex = 7
      OnClick = BtnTanimlamalarClick
    end
    object BtnKapat: TToolButton
      Left = 436
      Top = 0
      AutoSize = True
      Caption = 'Kapat'
      ImageIndex = 14
      OnClick = BtnKapatClick
    end
  end
  object PanelTarih: TPanel
    Left = 0
    Top = 24
    Width = 979
    Height = 54
    Align = alTop
    TabOrder = 1
    object DateBaslangic: TcxDateEdit
      Left = 56
      Top = 2
      EditValue = 40544d
      Properties.OnEditValueChanged = DateBaslangicPropertiesEditValueChanged
      TabOrder = 0
      Width = 93
    end
    object DateBitis: TcxDateEdit
      Left = 198
      Top = 2
      EditValue = 40909d
      Properties.OnEditValueChanged = DateBaslangicPropertiesEditValueChanged
      TabOrder = 1
      Width = 92
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 4
      Caption = 'Ba'#351'lang'#305#231
    end
    object cxLabel2: TcxLabel
      Left = 163
      Top = 4
      Caption = 'Biti'#351
    end
    object Label38: TcxLabel
      Left = 315
      Top = 3
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
      Left = 388
      Top = 2
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EdiBANKATICARIHESAPKODUPropertiesButtonClick
      TabOrder = 5
      Width = 87
    end
    object EditTicariHsId: TcxDBTextEdit
      Left = 623
      Top = 2
      TabStop = False
      DataBinding.DataField = 'BANKATICARIHESAPID'
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 6
      Visible = False
      Width = 34
    end
    object EditHesapAdiTicari: TcxTextEdit
      Left = 56
      Top = 28
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 7
      Width = 234
    end
    object ComboKur: TcxDBComboBox
      Left = 561
      Top = 27
      DataBinding.DataField = 'KUR'
      Enabled = False
      Properties.DropDownListStyle = lsFixedList
      Properties.MaxLength = 0
      TabOrder = 8
      Width = 61
    end
    object EditBanka: TcxTextEdit
      Left = 476
      Top = 2
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 9
      Width = 146
    end
    object cxLabel8: TcxLabel
      Left = 315
      Top = 28
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
      Left = 448
      Top = 27
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 11
      Width = 112
    end
    object cxLabel9: TcxLabel
      Left = 5
      Top = 28
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
      Left = 388
      Top = 27
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 13
      Width = 59
    end
  end
  object GridHesapHareketleri: TcxGrid
    Left = 0
    Top = 78
    Width = 979
    Height = 500
    Align = alClient
    TabOrder = 2
    object TableViewHesapHareketleri: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsHesapHareketleri
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsSelection.InvertSelect = False
      OptionsSelection.UnselectFocusedRecordOnExit = False
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      OptionsView.IndicatorWidth = 10
      object TableViewHesapHareketleriSEC: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.FieldName = 'SEC'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ClearKey = 46
        Properties.ImmediatePost = True
        Properties.ValueGrayed = 'False'
        Width = 24
      end
      object ableViewHesapHareketleriDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        Options.Editing = False
        Width = 77
      end
      object TableViewHesapHareketleriTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.DateOnError = deNull
        Properties.InputKind = ikRegExpr
        Properties.ReadOnly = True
        DateTimeGrouping = dtgByDateAndTime
        Options.Editing = False
        Width = 117
      end
      object TableViewHesapHareketleriVALOR: TcxGridDBColumn
        Caption = 'Valor'
        DataBinding.FieldName = 'VALOR'
        PropertiesClassName = 'TcxLabelProperties'
        Options.Editing = False
        Width = 68
      end
      object TableViewHesapHareketleriTUTAR: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTAR'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.ReadOnly = True
        Options.Editing = False
        Width = 55
      end
      object TableViewHesapHareketleriBAKIYE: TcxGridDBColumn
        Caption = 'Bakiye'
        DataBinding.FieldName = 'BAKIYE'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.00;-,0.00'
        Properties.ReadOnly = True
        Options.Editing = False
        Width = 52
      end
      object TableViewHesapHareketleriACIKLAMA1: TcxGridDBColumn
        Caption = 'A'#231#305'klama1'
        DataBinding.FieldName = 'ACIKLAMA1'
        PropertiesClassName = 'TcxLabelProperties'
        Options.Editing = False
        Width = 123
      end
      object TableViewHesapHareketleriACIKLAMA2: TcxGridDBColumn
        Caption = 'A'#231#305'klama2'
        DataBinding.FieldName = 'ACIKLAMA2'
        PropertiesClassName = 'TcxLabelProperties'
        Options.Editing = False
        Width = 120
      end
      object ableViewHesapHareketleriPROGRAMKOD: TcxGridDBColumn
        Caption = #304#351'lem Kodu'
        DataBinding.FieldName = 'PROGRAMKOD'
        Options.Editing = False
      end
      object TableViewHesapHareketleriKASATUR: TcxGridDBColumn
        Caption = 'Kasa T'#252'r'#252
        DataBinding.FieldName = 'KASATUR'
        Width = 76
      end
      object TableViewHesapHareketleriREHBERID: TcxGridDBColumn
        Caption = 'Cari'
        DataBinding.FieldName = 'REHBERID'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cxGrid1DBTableView1REHBERIDPropertiesButtonClick
        OnGetDisplayText = TableViewHesapHareketleriREHBERIDGetDisplayText
        Width = 97
      end
      object TableViewHesapHareketleriMUSTERIHESAPID: TcxGridDBColumn
        DataBinding.FieldName = 'MUSTERIHESAPID'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = TableViewHesapHareketleriMUSTERIHESAPIDPropertiesButtonClick
        OnGetDisplayText = TableViewHesapHareketleriMUSTERIHESAPIDGetDisplayText
        Width = 91
      end
    end
    object GridLevelHesapHareketleri: TcxGridLevel
      GridView = TableViewHesapHareketleri
    end
  end
  object TabHesapHareketleri: TFDQuery
    AfterOpen = TabHesapHareketleriAfterOpen
    AfterPost = TabHesapHareketleriAfterPost
    ParamData = <>
    SQL.Strings = (
      'select * from BANKAHESAPHAREKETLER'
      'where '
      'BANKAHESAPID=:PBankaHesapID and'
      'TARIH between :PBasTar and :PBitTar'
      '')
    Left = 43
    Top = 144
    Connection = Tablo.FDCnn
  end
  object DtsHesapHareketleri: TDataSource
    DataSet = TabHesapHareketleri
    Left = 40
    Top = 201
  end
  object HTTPRIOINGBank: THTTPRIO
    OnAfterExecute = HTTPRIOINGBankAfterExecute
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 464
    Top = 150
  end
  object HTTPSRIOTEB: THTTPRIO
    OnAfterExecute = HTTPSRIOTEBAfterExecute
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 465
    Top = 196
  end
  object TabHesapHareketAyarlari: TFDQuery
    ParamData = <>
    SQL.Strings = (
      'select * from BANKAHAREKETESLESTIRME'
      'where '
      'BANKAKODU=:PBankaKodu'
      ''
      'order by PROGRAMKOD')
    Left = 142
    Top = 189
    Connection = Tablo.FDCnn
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = GridHesapHareketleri
    PopupMenus = <
      item
        GridView = TableViewHesapHareketleri
        HitTypes = [gvhtGridNone, gvhtGridTab, gvhtNone, gvhtTab, gvhtCell, gvhtExpandButton, gvhtRecord, gvhtNavigator, gvhtPreview, gvhtColumnHeader, gvhtColumnHeaderFilterButton, gvhtFilter, gvhtFooter, gvhtFooterCell, gvhtGroupFooter, gvhtGroupFooterCell, gvhtGroupByBox, gvhtRowLevelIndent, gvhtBand, gvhtBandHeader, gvhtRowCaption, gvhtSeparator, gvhtGroupSummary]
        Index = 0
        PopupMenu = PopupMenu1
      end>
    Left = 302
    Top = 105
  end
  object PopupMenu1: TPopupMenu
    Left = 302
    Top = 152
    object HareketleriYenile1: TMenuItem
      Caption = 'Hareketleri Yenile'
      OnClick = BtnYenileClick
    end
    object mnSe1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      OnClick = mnSe1Click
    end
    object SeilenleriEletir1: TMenuItem
      Caption = 'Se'#231'ilenleri E'#351'le'#351'tir'
    end
    object SeilenleriAktar1: TMenuItem
      Caption = 'Se'#231'ilenleri Aktar'
      OnClick = BtnAktarClick
    end
    object anmlamalar1: TMenuItem
      Caption = 'Tan'#305'mlamalar'
      OnClick = BtnTanimlamalarClick
    end
  end
  object TabAktarimEslestirme: TFDQuery
    ParamData = <>
    SQL.Strings = (
      'select * from BANKAHAREKETESLESTIRME'
      'where '
      'BANKAKODU=:PBankaKodu'
      ''
      'order by PROGRAMKOD')
    Left = 280
    Top = 256
    Connection = Tablo.FDCnn
  end
end
