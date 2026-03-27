object SatisDlg: TSatisDlg
  Left = 0
  Top = 0
  Anchors = [akLeft]
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #220'r'#252'n Satis '#304#351'lemleri'
  ClientHeight = 467
  ClientWidth = 834
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBelgeBilgiler: TPanel
    Left = 0
    Top = 35
    Width = 834
    Height = 54
    Align = alTop
    TabOrder = 0
    ExplicitTop = 32
    object lblHataMesaj: TcxLabel
      Left = 4
      Top = 39
      AutoSize = False
      Style.TextColor = clRed
      Properties.WordWrap = True
      Transparent = True
      Height = 38
      Width = 375
    end
    object cxDBLabel1: TcxDBLabel
      Left = 342
      Top = 3
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatisListesi
      Transparent = True
      Height = 21
      Width = 121
    end
    object cxLabel1: TcxLabel
      Left = 301
      Top = 3
      Caption = 'Tarih :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 11
      Top = 3
      Caption = 'Id :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LblPaketId: TcxDBLabel
      Left = 38
      Top = 3
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatisListesi
      Transparent = True
      Height = 21
      Width = 35
    end
    object cxLabel9: TcxLabel
      Left = 11
      Top = 26
      Caption = 'Firma :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel3: TcxDBLabel
      Left = 54
      Top = 26
      DataBinding.DataField = 'FIRMA'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatisListesi
      Transparent = True
      Height = 21
      Width = 190
    end
    object ChkHepsi: TcxCheckBox
      Left = 469
      Top = 3
      Caption = 'Hepsini G'#246'nder'
      State = cbsChecked
      TabOrder = 7
      Width = 121
    end
    object cmbSubeler: TcxImageComboBox
      Left = 342
      Top = 29
      RepositoryItem = Tablo.RepSubeler
      Properties.Items = <>
      TabOrder = 8
      Width = 353
    end
    object cxLabel6: TcxLabel
      Left = 303
      Top = 30
      Caption = #350'ube :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 89
    Width = 834
    Height = 54
    Align = alTop
    TabOrder = 1
    Visible = False
    ExplicitTop = 86
    object cxLabel5: TcxLabel
      Left = 4
      Top = 11
      Caption = 'S'#305'ra Numaras'#305
    end
    object EdtEkleSıraNo: TcxTextEdit
      Left = 4
      Top = 29
      TabOrder = 1
      Width = 150
    end
    object EdtGerekli: TcxDBTextEdit
      Left = 171
      Top = 29
      DataBinding.DataField = 'ADET'
      Enabled = False
      TabOrder = 2
      Width = 59
    end
    object cxLabel3: TcxLabel
      Left = 171
      Top = 11
      Caption = 'Gerekli Adet'
    end
    object EdtToplamAdet: TcxDBTextEdit
      Left = 251
      Top = 29
      DataBinding.DataField = 'URETIMADET'
      Enabled = False
      TabOrder = 4
      Width = 59
    end
    object cxLabel4: TcxLabel
      Left = 251
      Top = 11
      Caption = 'Toplam Adet'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 143
    Width = 834
    Height = 161
    Align = alClient
    TabOrder = 2
    ExplicitTop = 140
    ExplicitHeight = 164
    object GridSatis: TcxGrid
      Left = 1
      Top = 1
      Width = 832
      Height = 159
      Align = alClient
      PopupMenu = PopupMenu1
      TabOrder = 0
      OnContextPopup = GridSatisContextPopup
      ExplicitHeight = 162
      object TvSatis: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        OnCellClick = TvSatisCellClick
        OnCellDblClick = TvSatisCellDblClick
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = Tablo.DtsSatis
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        Styles.OnGetContentStyle = TvSatisStylesGetContentStyle
        object ColSatisSec: TcxGridDBColumn
          Caption = 'Se'#231
          DataBinding.ValueType = 'Boolean'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Width = 34
        end
        object TvSatisURUNBARKOD: TcxGridDBColumn
          Caption = 'Barkod'
          DataBinding.FieldName = 'URUNBARKOD'
          Options.Editing = False
          Width = 159
        end
        object TvSatisSIRANO: TcxGridDBColumn
          Caption = 'S'#305'ra No'
          DataBinding.FieldName = 'SIRANO'
          Options.Editing = False
          Width = 159
        end
        object TvSatisLOTNO: TcxGridDBColumn
          Caption = 'Lotno'
          DataBinding.FieldName = 'LOTNO'
          Options.Editing = False
          Width = 159
        end
        object TvSatisSONKULLANIM: TcxGridDBColumn
          Caption = 'Son Kullan'#305'm Tarihi'
          DataBinding.FieldName = 'SONKULLANIM'
          Options.Editing = False
          Width = 143
        end
        object vSatisColumn1: TcxGridDBColumn
          Caption = 'Bildirim'
          DataBinding.FieldName = 'DURUM'
        end
      end
      object GlSatis: TcxGridLevel
        GridView = TvSatis
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 304
    Width = 834
    Height = 163
    Align = alBottom
    TabOrder = 3
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 832
      Height = 24
      Align = alTop
      Caption = 'Bildirim Durumlar'#305
      TabOrder = 0
    end
    object GridGecmis: TcxGrid
      Left = 1
      Top = 25
      Width = 832
      Height = 137
      Align = alClient
      TabOrder = 1
      object TvGecmis: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsGecmis
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object TvGecmisID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
        end
        object TvGecmisALIM_DURUM: TcxGridDBColumn
          Caption = 'Al'#305'm Durumu'
          DataBinding.FieldName = 'ALIM_DURUM'
          Width = 200
        end
        object TvGecmisALIM_BILDIRIM_TARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'ALIM_BILDIRIM_TARIH'
        end
        object TvGecmisSATIS_DURUM: TcxGridDBColumn
          Caption = 'Sat'#305#351' Durumu'
          DataBinding.FieldName = 'SATIS_DURUM'
          Width = 200
        end
        object TvGecmisSATIS_BILDIRIM_TARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'SATIS_BILDIRIM_TARIH'
        end
        object TvGecmisURETIM_DURUM: TcxGridDBColumn
          Caption = #220'retim Durumu'
          DataBinding.FieldName = 'URETIM_DURUM'
          Width = 200
        end
        object TvGecmisURETIM_BILDIRIM_TARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'URETIM_BILDIRIM_TARIH'
        end
        object TvGecmisMALALINANGLN: TcxGridDBColumn
          Caption = 'Mal'#305'nan Firma'
          DataBinding.FieldName = 'MALALINANGLN'
        end
        object TvGecmisMALSATILANGLN: TcxGridDBColumn
          Caption = 'Sat'#305'lan Firma'
          DataBinding.FieldName = 'MALSATILANGLN'
        end
      end
      object GlGecmis: TcxGridLevel
        GridView = TvGecmis
      end
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 828
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 118
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
    HotImages = Tablo.PNGImageList1
    HotTrackColor = 65408
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 4
    Transparent = True
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 10
      Style = tbsSeparator
    end
    object BtnSatisYazdir: TToolButton
      Left = 8
      Top = 0
      Caption = 'Yazd'#305'r'
      ImageIndex = 16
    end
    object BtnSatisBildir: TToolButton
      Left = 126
      Top = 0
      Caption = 'ITS Bildir'
      ImageIndex = 12
      OnClick = BtnSatisBildirClick
    end
    object BtnPaketGonder: TToolButton
      Left = 244
      Top = 0
      Caption = 'PTS Bildir'
      ImageIndex = 29
      OnClick = BtnPaketGonderClick
    end
    object BtnSubeyeBildir: TToolButton
      Left = 362
      Top = 0
      Caption = 'PTS '#350'ubeye Bildir'
      ImageIndex = 29
      OnClick = BtnSubeyeBildirClick
    end
  end
  object TabGecmis: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'STOKIDID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT * FROM KAREKOD WHERE STOKIDID =:STOKIDID')
    Left = 661
    Top = 99
    object TabGecmisID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGecmisSTOKID: TIntegerField
      FieldName = 'STOKID'
    end
    object TabGecmisSTOKIDID: TIntegerField
      FieldName = 'STOKIDID'
    end
    object TabGecmisDOGRULAMA_DURUM: TStringField
      FieldName = 'DOGRULAMA_DURUM'
      Size = 250
    end
    object TabGecmisDOGRULAMA_TARIH: TDateTimeField
      FieldName = 'DOGRULAMA_TARIH'
    end
    object TabGecmisALIM_DURUM: TStringField
      FieldName = 'ALIM_DURUM'
      Size = 250
    end
    object TabGecmisALIM_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'ALIM_BILDIRIM_TARIH'
    end
    object TabGecmisSATIS_DURUM: TStringField
      FieldName = 'SATIS_DURUM'
      Size = 250
    end
    object TabGecmisSATIS_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'SATIS_BILDIRIM_TARIH'
    end
    object TabGecmisALIM_IADE_DURUM: TStringField
      FieldName = 'ALIM_IADE_DURUM'
      Size = 250
    end
    object TabGecmisALIM_IADE_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'ALIM_IADE_BILDIRIM_TARIH'
    end
    object TabGecmisSATIS_IPTAL_DURUM: TStringField
      FieldName = 'SATIS_IPTAL_DURUM'
      Size = 250
    end
    object TabGecmisSATIS_IPTAL_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'SATIS_IPTAL_BILDIRIM_TARIH'
    end
    object TabGecmisDEAKTIVASYON_DURUM: TStringField
      FieldName = 'DEAKTIVASYON_DURUM'
      Size = 250
    end
    object TabGecmisDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'DEAKTIVASYON_BILDIRIM_TARIH'
    end
    object TabGecmisMALALINANGLN: TStringField
      FieldName = 'MALALINANGLN'
    end
    object TabGecmisMALSATILANGLN: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabGecmisTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabGecmisURETIM_DURUM: TStringField
      FieldName = 'URETIM_DURUM'
      Size = 150
    end
    object TabGecmisURETIM_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'URETIM_BILDIRIM_TARIH'
    end
  end
  object DtsGecmis: TDataSource
    DataSet = TabGecmis
    Left = 596
    Top = 98
  end
  object PopupMenu1: TPopupMenu
    Left = 378
    Top = 106
    object pmHepsiSec: TMenuItem
      Tag = 1
      Caption = 'Hepsini Se'#231
      OnClick = pmHepsiSecClick
    end
    object pmTumunuKaldir: TMenuItem
      Tag = 2
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      OnClick = pmHepsiSecClick
    end
    object pmSecimiTersCevir: TMenuItem
      Tag = 3
      Caption = 'Se'#231'imi Ters '#199'evir'
      OnClick = pmHepsiSecClick
    end
    object DoruBildirimeevir1: TMenuItem
      Caption = 'Do'#287'ru Bildirime '#199'evir'
      OnClick = DoruBildirimeevir1Click
    end
  end
  object HTTPRIO1: THTTPRIO
    URL = 'http://pts.saglik.gov.tr/PTS/PackageSenderWebService'
    HTTPWebNode.UserName = 'ATABAY'
    HTTPWebNode.Password = '34TL5900'
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 544
    Top = 16
  end
  object TabGecmis2: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'STOKID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT * FROM KAREKOD WHERE STOKIDID =:STOKID')
    Left = 661
    Top = 179
    object AutoIncField1: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object IntegerField1: TIntegerField
      FieldName = 'STOKID'
    end
    object IntegerField2: TIntegerField
      FieldName = 'STOKIDID'
    end
    object StringField1: TStringField
      FieldName = 'DOGRULAMA_DURUM'
      Size = 250
    end
    object DateTimeField1: TDateTimeField
      FieldName = 'DOGRULAMA_TARIH'
    end
    object StringField2: TStringField
      FieldName = 'ALIM_DURUM'
      Size = 250
    end
    object DateTimeField2: TDateTimeField
      FieldName = 'ALIM_BILDIRIM_TARIH'
    end
    object StringField3: TStringField
      FieldName = 'SATIS_DURUM'
      Size = 250
    end
    object DateTimeField3: TDateTimeField
      FieldName = 'SATIS_BILDIRIM_TARIH'
    end
    object StringField4: TStringField
      FieldName = 'ALIM_IADE_DURUM'
      Size = 250
    end
    object DateTimeField4: TDateTimeField
      FieldName = 'ALIM_IADE_BILDIRIM_TARIH'
    end
    object StringField5: TStringField
      FieldName = 'SATIS_IPTAL_DURUM'
      Size = 250
    end
    object DateTimeField5: TDateTimeField
      FieldName = 'SATIS_IPTAL_BILDIRIM_TARIH'
    end
    object StringField6: TStringField
      FieldName = 'DEAKTIVASYON_DURUM'
      Size = 250
    end
    object DateTimeField6: TDateTimeField
      FieldName = 'DEAKTIVASYON_BILDIRIM_TARIH'
    end
    object StringField7: TStringField
      FieldName = 'MALALINANGLN'
    end
    object StringField8: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object StringField9: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object StringField10: TStringField
      FieldName = 'URETIM_DURUM'
      Size = 150
    end
    object DateTimeField7: TDateTimeField
      FieldName = 'URETIM_BILDIRIM_TARIH'
    end
  end
  object DtsGecmis2: TDataSource
    DataSet = TabGecmis2
    Left = 612
    Top = 202
  end
end
