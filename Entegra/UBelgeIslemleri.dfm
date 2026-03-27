object BelgeIslemleriDlg: TBelgeIslemleriDlg
  Left = 0
  Top = 0
  Caption = 'Belge G'#246'r'#252'nt'#252'leme ve De'#287'i'#351'iklik Ekran'#305
  ClientHeight = 493
  ClientWidth = 792
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 786
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 76
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
    TabOrder = 0
    Transparent = True
    object BelgeEkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Belge Ekle'
      ImageIndex = 4
      Style = tbsTextButton
      OnClick = BelgeEkleTusClick
    end
    object BelgeSilTus: TToolButton
      Left = 76
      Top = 0
      Caption = 'Belge Sil'
      ImageIndex = 5
      Style = tbsTextButton
      OnClick = BelgeSilTusClick
    end
    object BelgeGorTus: TToolButton
      Left = 152
      Top = 0
      Caption = 'Belge G'#246'r'
      ImageIndex = 6
      Style = tbsTextButton
      OnClick = BelgeGorTusClick
    end
    object ToolButton2: TToolButton
      Left = 228
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object KaydetTus: TToolButton
      Left = 236
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Visible = False
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 312
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      Visible = False
      OnClick = IptalTusClick
    end
  end
  object GridBelge: TcxGrid
    Left = 0
    Top = 27
    Width = 792
    Height = 466
    Align = alClient
    TabOrder = 1
    object GridBelgeDBTableViewImaj: TcxGridDBTableView
      OnDblClick = GridBelgeDBTableViewImajDblClick
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsImaj
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      object GridBelgeDBTableViewImajBELGEADI: TcxGridDBColumn
        DataBinding.FieldName = 'BELGEADI'
        Width = 95
      end
      object GridBelgeDBTableViewImajTUR: TcxGridDBColumn
        DataBinding.FieldName = 'TUR'
        Width = 79
      end
      object GridBelgeDBTableViewImajACIKLAMA: TcxGridDBColumn
        DataBinding.FieldName = 'ACIKLAMA'
        Width = 363
      end
      object GridBelgeDBTableViewImajBELGE: TcxGridDBColumn
        DataBinding.FieldName = 'BELGE'
        Width = 38
      end
    end
    object GridBelgeLevel1: TcxGridLevel
      GridView = GridBelgeDBTableViewImaj
    end
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT  *  FROM  [IMAJ]'
      'WHERE'
      'YERI = :PYeri AND'
      'YER_ID=:PYer_ID')
    Left = 382
    Top = 79
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    OnStateChange = DtsImajStateChange
    Left = 331
    Top = 79
  end
  object OpenDialog1: TOpenDialog
    Left = 439
    Top = 79
  end
  object SaveDialog1: TSaveDialog
    Left = 440
    Top = 127
  end
end

