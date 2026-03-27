object CekRiskPayiDlg: TCekRiskPayiDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'De'#287'i'#351'ik tarihlerdeki risk paylar'#305
  ClientHeight = 384
  ClientWidth = 887
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object cxGrid3: TcxGrid
    Left = 0
    Top = 27
    Width = 887
    Height = 357
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    object cxGridDBTableView2: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsCekRiskPayi
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsView.GroupByBox = False
      object cxGridDBTableView2ID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        Visible = False
      end
      object cxGridDBTableView2BASTARIH: TcxGridDBColumn
        Caption = 'Ba'#351'lama Tarihi'
        DataBinding.FieldName = 'BASTARIH'
        Width = 124
      end
      object cxGridDBTableView2BITTARIH: TcxGridDBColumn
        Caption = 'Biti'#351' Tarihi'
        DataBinding.FieldName = 'BITTARIH'
        Width = 121
      end
      object cxGridDBTableView2TUTAR: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTAR'
        Width = 80
      end
    end
    object cxGridLevel3: TcxGridLevel
      GridView = cxGridDBTableView2
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 881
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 62
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
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Ekle'
      ImageIndex = 0
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 62
      Top = 0
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 124
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Style = tbsTextButton
      Visible = False
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 186
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Style = tbsTextButton
      Visible = False
      OnClick = IptalTusClick
    end
    object btnKapat: TToolButton
      Left = 248
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 5
      OnClick = btnKapatClick
    end
  end
  object DtsCekRiskPayi: TDataSource
    DataSet = TabCekRiskPayi
    OnStateChange = DtsCekRiskPayiStateChange
    Left = 238
    Top = 292
  end
  object TabCekRiskPayi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from CEKRISKPAYI')
    Left = 200
    Top = 289
  end
end

