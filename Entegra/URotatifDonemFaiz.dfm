object RotatifDonemFaizDlg: TRotatifDonemFaizDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Rotatif Kredi D'#246'nemleri ve Faiz Oranlar'#305
  ClientHeight = 417
  ClientWidth = 887
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel6: TPanel
    Left = 469
    Top = 0
    Width = 418
    Height = 417
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object SpeedButton3: TSpeedButton
      Left = 457
      Top = 0
      Width = 138
      Height = 19
      Caption = 'T'#252'm kredilere uygula'
      Flat = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
        333333333337F33333333333333033333333333333373F333333333333090333
        33333333337F7F33333333333309033333333333337373F33333333330999033
        3333333337F337F33333333330999033333333333733373F3333333309999903
        333333337F33337F33333333099999033333333373333373F333333099999990
        33333337FFFF3FF7F33333300009000033333337777F77773333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333300033333333333337773333333}
      NumGlyphs = 2
    end
    object Label44: TcxLabel
      Left = 601
      Top = 0
      Caption = 'Faiz '#214'deme D'#246'nemleri'
      ParentFont = False
    end
    object GridFaiz: TcxGrid
      Left = 0
      Top = 27
      Width = 418
      Height = 390
      Align = alClient
      TabOrder = 2
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridFaizView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsRotatifFaiz
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        object GridFaizViewID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
        object GridFaizViewKREDIID: TcxGridDBColumn
          DataBinding.FieldName = 'KREDIID'
          Visible = False
        end
        object GridFaizViewBASTARIH: TcxGridDBColumn
          Caption = 'Ba'#351'lama Tarihi'
          DataBinding.FieldName = 'BASTARIH'
          Width = 124
        end
        object GridFaizViewBITTARIH: TcxGridDBColumn
          Caption = 'Biti'#351' Tarihi'
          DataBinding.FieldName = 'BITTARIH'
          Width = 121
        end
        object GridFaizViewORAN: TcxGridDBColumn
          Caption = 'Y'#305'll'#305'k %'
          DataBinding.FieldName = 'ORAN'
        end
      end
      object cxGridLevel3: TcxGridLevel
        GridView = GridFaizView
      end
    end
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 412
      Height = 24
      Margins.Bottom = 0
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
      object Label45: TcxLabel
        Left = 0
        Top = 2
        Caption = 'Faiz Oranlar'#305
        ParentFont = False
        Transparent = True
      end
      object FaizEkleTus: TToolButton
        Left = 64
        Top = 0
        Caption = 'Ekle'
        ImageIndex = 0
        OnClick = FaizEkleTusClick
      end
      object FaizSilTus: TToolButton
        Left = 125
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = FaizSilTusClick
      end
      object FaizKaydetTus: TToolButton
        Left = 186
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Style = tbsTextButton
        Visible = False
        OnClick = FaizKaydetTusClick
      end
      object FaizIptalTus: TToolButton
        Left = 247
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Style = tbsTextButton
        Visible = False
        OnClick = FaizIptalTusClick
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 469
    Height = 417
    Align = alLeft
    TabOrder = 1
    Visible = False
    object ToolBar4: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 461
      Height = 24
      Margins.Bottom = 0
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
      TabOrder = 0
      Transparent = True
      object cxLabel2: TcxLabel
        Left = 0
        Top = 2
        Caption = 'D'#246'nemler '
        ParentFont = False
        Transparent = True
      end
      object DonemEkleTus: TToolButton
        Left = 52
        Top = 0
        Caption = 'D'#246'nem'
        ImageIndex = 0
        OnClick = DonemEkleTusClick
      end
      object SatirEkleTus: TToolButton
        Left = 113
        Top = 0
        Caption = 'Sat'#305'r'
        ImageIndex = 0
        OnClick = SatirEkleTusClick
      end
      object DonemSilTus: TToolButton
        Left = 174
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = DonemSilTusClick
      end
      object DonemKaydetTus: TToolButton
        Left = 235
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Style = tbsTextButton
        Visible = False
        OnClick = DonemKaydetTusClick
      end
      object DonemIptalTus: TToolButton
        Left = 296
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Style = tbsTextButton
        Visible = False
        OnClick = DonemIptalTusClick
      end
    end
    object GridDonem: TcxGrid
      Left = 1
      Top = 28
      Width = 467
      Height = 388
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridDonemView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsRotatifDonem
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        object GridDonemViewBASTARIH: TcxGridDBColumn
          Caption = 'Ba'#351'lama Tarihi'
          DataBinding.FieldName = 'BASTARIH'
        end
        object GridDonemViewBITTARIH: TcxGridDBColumn
          Caption = 'Biti'#351' Tarihi'
          DataBinding.FieldName = 'BITTARIH'
        end
        object GridDonemViewUYGULANDI: TcxGridDBColumn
          Caption = 'Uyguland'#305
          DataBinding.FieldName = 'UYGULANDI'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Width = 68
        end
      end
      object cxGridLevel4: TcxGridLevel
        GridView = GridDonemView
      end
    end
  end
  object KREDIROTATIFDONEM: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = KREDIROTATIFDONEMBeforePost
    OnNewRecord = KREDIROTATIFDONEMNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KREDIROTATIFDONEM where KREDIID=:ID')
    Left = 361
    Top = 211
  end
  object DtsRotatifFaiz: TDataSource
    DataSet = KREDIROTATIFFAIZ
    OnStateChange = DtsRotatifFaizStateChange
    Left = 743
    Top = 248
  end
  object KREDIROTATIFFAIZ: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = KREDIROTATIFFAIZBeforePost
    OnNewRecord = KREDIROTATIFFAIZNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KREDIROTATIFFAIZ where KREDIID=:ID')
    Left = 773
    Top = 174
  end
  object DtsRotatifDonem: TDataSource
    DataSet = KREDIROTATIFDONEM
    OnStateChange = DtsRotatifDonemStateChange
    Left = 441
    Top = 244
  end
end
