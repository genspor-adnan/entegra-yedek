object ServisIslemDetaylariDlg: TServisIslemDetaylariDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'ServisIslemDetaylariDlg'
  ClientHeight = 394
  ClientWidth = 818
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 62
    Width = 234
    Height = 332
    Align = alLeft
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsServisIslemDetayBasliklar
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1KOD: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        Width = 72
      end
      object cxGrid1DBTableView1AD: TcxGridDBColumn
        Caption = 'Ad'
        DataBinding.FieldName = 'AD'
        Width = 159
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object ToolBarProblem: TToolBar
    Left = 0
    Top = 38
    Width = 818
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 80
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
    Images = Tablo.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object BtnYeni: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni Ba'#351'l'#305'k'
      ImageIndex = 0
      OnClick = BtnYeniClick
    end
    object ToolButton1: TToolButton
      Left = 80
      Top = 0
      Width = 153
      Caption = 'ToolButton1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object BtnYeniSatir: TToolButton
      Left = 233
      Top = 0
      Caption = 'YeniSat'#305'r'
      ImageIndex = 4
      OnClick = BtnYeniSatirClick
    end
    object BtnDuzenle: TToolButton
      Left = 313
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 7
      OnClick = BtnDuzenleClick
    end
    object BtnSil: TToolButton
      Left = 393
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = BtnSilClick
    end
    object ToolButton25: TToolButton
      Left = 473
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object BtnKaydet: TToolButton
      Left = 481
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = BtnKaydetClick
    end
    object BtnIptal: TToolButton
      Left = 561
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
      OnClick = BtnIptalClick
    end
  end
  object cxGrid2: TcxGrid
    Left = 234
    Top = 62
    Width = 584
    Height = 332
    Align = alClient
    TabOrder = 2
    object cxGridDBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      OnCellDblClick = cxGridDBTableView1CellDblClick
      DataController.DataSource = DtsServisIslemDetay
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      object cxGridDBTableView1KOD: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        Width = 97
      end
      object cxGridDBTableView1AD: TcxGridDBColumn
        Caption = 'Ad'
        DataBinding.FieldName = 'AD'
        Width = 132
      end
      object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        Width = 152
      end
      object cxGridDBTableView1PUAN: TcxGridDBColumn
        Caption = 'Puan'
        DataBinding.FieldName = 'PUAN'
      end
      object cxGridDBTableView1SURE: TcxGridDBColumn
        Caption = 'S'#252're'
        DataBinding.FieldName = 'SURE'
      end
      object cxGridDBTableView1SUREBIRIMI: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'SUREBIRIMI'
        RepositoryItem = Tablo.repZamanBirimleri
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = cxGridDBTableView1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 818
    Height = 38
    Align = alTop
    TabOrder = 3
  end
  object TabServisIslemDetayBasliklar: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabServisIslemDetayBasliklarAfterOpen
    BeforeClose = TabServisIslemDetayBasliklarBeforeClose
    AfterScroll = TabServisIslemDetayBasliklarAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select'
      
        'AD =  CASE WHEN SD.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKL' +
        'AR WHERE ID = SD.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHER' +
        'E ID = SD.URUNID)  END,'
      
        'KOD =  CASE WHEN SD.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR ' +
        'WHERE ID = SD.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ' +
        'ID= SD.URUNID )  END,'
      '* from'
      '('
      'select distinct TUR,URUNID from SERVISDETAYPERSONEL'
      'where isnull(SERVISID,0)<=0'
      ')as SD')
    Left = 319
    Top = 80
  end
  object TabServisIslemDetay: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabServisIslemDetayBeforePost
    OnNewRecord = TabServisIslemDetayNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from'
      ' SERVISDETAYPERSONEL SD'
      ''
      'where isnull(SERVISID,0)<=0 and TUR=:PTur and URUNID=:PUrunID')
    Left = 405
    Top = 61
  end
  object DtsServisIslemDetayBasliklar: TDataSource
    DataSet = TabServisIslemDetayBasliklar
    Left = 319
    Top = 122
  end
  object DtsServisIslemDetay: TDataSource
    DataSet = TabServisIslemDetay
    Left = 404
    Top = 104
  end
end
