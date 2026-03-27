object MalAlimDlg: TMalAlimDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Mal Al'#305'm G'#246'nderimleri'
  ClientHeight = 434
  ClientWidth = 764
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 758
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 75
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
    TabOrder = 0
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
      Left = 83
      Top = 0
      Caption = 'Bildir'
      ImageIndex = 12
      OnClick = BtnSatisBildirClick
    end
    object BtnPaketAl: TToolButton
      Left = 158
      Top = 0
      Caption = 'Paket Al'
      ImageIndex = 29
      OnClick = BtnPaketAlClick
    end
  end
  object pnlBelgeBilgiler: TPanel
    Left = 0
    Top = 35
    Width = 764
    Height = 54
    Align = alTop
    TabOrder = 1
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
      Left = 301
      Top = 2
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatinAlmaListesi
      Transparent = True
      Height = 21
      Width = 121
    end
    object cxLabel1: TcxLabel
      Left = 260
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
      DataBinding.DataField = 'BELGEBASID'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatinAlmaListesi
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
      DataBinding.DataSource = ITSBildirimDlg.DtsSatinAlmaListesi
      Transparent = True
      Height = 21
      Width = 190
    end
    object cxDBLabel4: TcxDBLabel
      Left = 298
      Top = 26
      DataBinding.DataField = 'STOKADI'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatinAlmaListesi
      Transparent = True
      Height = 21
      Width = 190
    end
    object cxLabel10: TcxLabel
      Left = 260
      Top = 26
      Caption = #220'r'#252'n :'
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
  object Panel2: TPanel
    Left = 0
    Top = 89
    Width = 764
    Height = 182
    Align = alClient
    TabOrder = 2
    object GridAlim: TcxGrid
      Left = 1
      Top = 1
      Width = 762
      Height = 180
      Align = alClient
      TabOrder = 0
      OnContextPopup = GridAlimContextPopup
      object TvAlim: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        OnCellClick = TvAlimCellClick
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = Tablo.DtsMalAlim
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        Styles.OnGetContentStyle = TvAlimStylesGetContentStyle
        object ColSatisSec: TcxGridDBColumn
          Caption = 'Se'#231
          DataBinding.ValueType = 'Boolean'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Visible = False
          Width = 34
        end
        object TvAlimURUNBARKOD: TcxGridDBColumn
          Caption = 'Barkod'
          DataBinding.FieldName = 'URUNBARKOD'
          Options.Editing = False
          Width = 159
        end
        object TvAlimSIRANO: TcxGridDBColumn
          Caption = 'S'#305'ra No'
          DataBinding.FieldName = 'SIRANO'
          Options.Editing = False
          Width = 159
        end
        object TvAlimLOTNO: TcxGridDBColumn
          Caption = 'Lotno'
          DataBinding.FieldName = 'LOTNO'
          Options.Editing = False
          Width = 159
        end
        object TvAlimSONKULLANIM: TcxGridDBColumn
          Caption = 'Son Kullan'#305'm Tarihi'
          DataBinding.FieldName = 'SONKULLANIM'
          Options.Editing = False
          Width = 143
        end
        object vAlimColumn1: TcxGridDBColumn
          Caption = 'Bildirim'
          DataBinding.FieldName = 'DURUM'
        end
      end
      object GlAlim: TcxGridLevel
        GridView = TvAlim
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 271
    Width = 764
    Height = 163
    Align = alBottom
    TabOrder = 3
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 762
      Height = 24
      Align = alTop
      Caption = 'Bildirim Durumlar'#305
      TabOrder = 0
    end
    object GridGecmis: TcxGrid
      Left = 1
      Top = 25
      Width = 762
      Height = 137
      Align = alClient
      TabOrder = 1
      object TvGecmis: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
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
  object PopupMenu1: TPopupMenu
    Left = 418
    Top = 130
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
  end
  object DtsGecmis: TDataSource
    DataSet = TabGecmis
    Left = 596
    Top = 98
  end
  object TabGecmis: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'ID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT * FROM KAREKOD WHERE ID=:ID')
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
  object DtsGecmis2: TDataSource
    DataSet = TabGecmis2
    Left = 588
    Top = 178
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
    Left = 637
    Top = 147
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
end
