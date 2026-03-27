object SatisIptalDlg: TSatisIptalDlg
  Left = 0
  Top = 0
  Caption = 'Satis Iptal'
  ClientHeight = 488
  ClientWidth = 753
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 747
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 113
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
      Left = 121
      Top = 0
      Caption = 'Sat'#305#351' '#304'ptal Bildir'
      ImageIndex = 12
      OnClick = BtnSatisBildirClick
    end
  end
  object pnlBelgeBilgiler: TPanel
    Left = 0
    Top = 35
    Width = 753
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
      Left = 558
      Top = 3
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatisIptalListesi
      Transparent = True
      Height = 21
      Width = 121
    end
    object cxLabel1: TcxLabel
      Left = 517
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
      DataBinding.DataSource = ITSBildirimDlg.DtsSatisIptalListesi
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
      DataBinding.DataSource = ITSBildirimDlg.DtsSatisIptalListesi
      Transparent = True
      Height = 21
      Width = 190
    end
    object cxDBLabel4: TcxDBLabel
      Left = 298
      Top = 26
      DataBinding.DataField = 'STOKADI'
      DataBinding.DataSource = ITSBildirimDlg.DtsSatisIptalListesi
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
    Width = 753
    Height = 236
    Align = alClient
    TabOrder = 2
    object GridAlim: TcxGrid
      Left = 1
      Top = 1
      Width = 751
      Height = 234
      Align = alClient
      TabOrder = 0
      object TvSatisIptal: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        OnCellClick = TvSatisIptalCellClick
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = Tablo.DtsSatisIptal
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        Styles.OnGetContentStyle = TvSatisIptalStylesGetContentStyle
        object TvSatisIptalURUNBARKOD: TcxGridDBColumn
          Caption = 'Barkod'
          DataBinding.FieldName = 'URUNBARKOD'
          Options.Editing = False
          Width = 159
        end
        object TvSatisIptalSIRANO: TcxGridDBColumn
          Caption = 'S'#305'ra No'
          DataBinding.FieldName = 'SIRANO'
          Options.Editing = False
          Width = 159
        end
        object TvSatisIptalLOTNO: TcxGridDBColumn
          Caption = 'Lotno'
          DataBinding.FieldName = 'LOTNO'
          Options.Editing = False
          Width = 159
        end
        object TvSatisIptalSONKULLANIM: TcxGridDBColumn
          Caption = 'Son Kullan'#305'm Tarihi'
          DataBinding.FieldName = 'SONKULLANIM'
          Options.Editing = False
          Width = 143
        end
        object DURUM: TcxGridDBColumn
          Caption = 'Bildirim Durumu'
          DataBinding.FieldName = 'DURUM'
          Width = 70
        end
      end
      object GlSatis: TcxGridLevel
        GridView = TvSatisIptal
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 325
    Width = 753
    Height = 163
    Align = alBottom
    TabOrder = 3
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 751
      Height = 24
      Align = alTop
      Caption = 'Bildirim Durumlar'#305
      TabOrder = 0
    end
    object GridGecmis: TcxGrid
      Left = 1
      Top = 25
      Width = 751
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
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object TvGecmisID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
        end
        object TvGecmisALIM_DURUM: TcxGridDBColumn
          Caption = 'Sat'#305#351' Iptal Durumu'
          DataBinding.FieldName = 'SATIS_IPTAL_DURUM'
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
    Left = 677
    Top = 147
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
    Left = 604
    Top = 154
  end
end
