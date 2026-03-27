object MasrafAnalizDlg: TMasrafAnalizDlg
  Left = 0
  Top = 0
  Caption = 'Analiz'
  ClientHeight = 544
  ClientWidth = 1250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 354
    Width = 1250
    Height = 6
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    Color = clSkyBlue
    ParentColor = False
    ResizeStyle = rsUpdate
    ExplicitTop = 356
    ExplicitWidth = 1109
  end
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1244
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 64
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
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 32
    Width = 1250
    Height = 41
    Align = alTop
    TabOrder = 1
    object LabelDijit: TcxLabel
      Left = 19
      Top = 7
      Caption = 'Y'#305'l'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditYIL: TcxSpinEdit
      Left = 47
      Top = 3
      ParentFont = False
      Properties.LargeIncrement = 1.000000000000000000
      Properties.MaxValue = 2020.000000000000000000
      Properties.MinValue = 2010.000000000000000000
      Properties.OnChange = EditYILPropertiesChange
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 1
      Value = 2010
      Width = 73
    end
  end
  object pivot: TcxDBPivotGrid
    AlignWithMargins = True
    Left = 3
    Top = 76
    Width = 1244
    Height = 275
    Customization.FormStyle = cfsAdvanced
    Align = alClient
    DataSource = DtsPivot
    Groups = <>
    OptionsDataField.IsCaptionAssigned = True
    OptionsDataField.Caption = 'Veri'
    OptionsSelection.MultiSelect = True
    OptionsView.ColumnGrandTotalText = 'Genel Toplam'
    OptionsView.RowGrandTotalText = 'Genel Toplam'
    TabOrder = 2
    object pivotGRUP: TcxDBPivotGridField
      AreaIndex = 0
      IsCaptionAssigned = True
      Caption = 'Grup'
      DataBinding.FieldName = 'GRUP'
      Visible = True
      UniqueName = 'Grup'
    end
    object pivotTUR: TcxDBPivotGridField
      Area = faRow
      AreaIndex = 0
      IsCaptionAssigned = True
      Caption = 'T'#252'r'
      DataBinding.FieldName = 'TUR'
      Visible = True
      Width = 250
      UniqueName = 'T'#252'r'
    end
    object pivotYIL: TcxDBPivotGridField
      AreaIndex = 1
      IsCaptionAssigned = True
      Caption = 'Y'#305'l'
      DataBinding.FieldName = 'YIL'
      Visible = True
      UniqueName = 'Y'#305'l'
    end
    object pivotTARIH: TcxDBPivotGridField
      AreaIndex = 2
      IsCaptionAssigned = True
      Caption = 'Tarih'
      DataBinding.FieldName = 'TARIH'
      Visible = True
      UniqueName = 'Tarih'
    end
    object pivotTARIHYAZI: TcxDBPivotGridField
      Area = faColumn
      AreaIndex = 0
      IsCaptionAssigned = True
      Caption = 'Ay'
      DataBinding.FieldName = 'TARIHYAZI'
      Visible = True
      UniqueName = 'Ay'
    end
    object pivotPLANLANAN: TcxDBPivotGridField
      Area = faData
      AreaIndex = 0
      IsCaptionAssigned = True
      Caption = 'Plan'
      DataBinding.FieldName = 'PLANLANAN'
      PropertiesClassName = 'TcxCurrencyEditProperties'
      Properties.DisplayFormat = ',0.00;-,0.00'
      Visible = True
      Width = 70
      UniqueName = 'Plan'
    end
    object pivotGERCEKLESEN: TcxDBPivotGridField
      Area = faData
      AreaIndex = 1
      IsCaptionAssigned = True
      Caption = 'Ger'#231'ek'
      DataBinding.FieldName = 'GERCEKLESEN'
      PropertiesClassName = 'TcxCurrencyEditProperties'
      Properties.DisplayFormat = ',0.00;-,0.00'
      Visible = True
      Width = 70
      UniqueName = 'Ger'#231'ek'
    end
  end
  object FGrid: TcxGrid
    AlignWithMargins = True
    Left = 1036
    Top = 949
    Width = 443
    Height = 128
    Align = alCustom
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    object FGridTableView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsPivot
      DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          Position = spFooter
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          Position = spFooter
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'BORC'
        end
        item
          Format = ',0.00;(,0.00)'
          Kind = skSum
          FieldName = 'ALACAK'
        end
        item
          Format = ',0.00;(,0.00)'
        end
        item
          Format = ',0.00;(,0.00)'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnCycle = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      Styles.ContentEven = AnaForm.cxStyle1
      Styles.GroupByBox = AnaForm.cxStyle1
      Styles.Header = AnaForm.cxStyle1
      object FGridTableViewGRUP: TcxGridDBColumn
        DataBinding.FieldName = 'GRUP'
      end
      object FGridTableViewTUR: TcxGridDBColumn
        DataBinding.FieldName = 'TUR'
      end
      object FGridTableViewTARIH: TcxGridDBColumn
        DataBinding.FieldName = 'TARIH'
      end
      object FGridTableViewTUTAR: TcxGridDBColumn
        DataBinding.FieldName = 'TUTAR'
        DataBinding.IsNullValueType = True
      end
    end
    object FGridDBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataModeController.SmartRefresh = True
      DataController.DetailKeyFieldNames = 'CEKID'
      DataController.MasterKeyFieldNames = 'CEKID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      Styles.ContentOdd = AnaForm.cxStyle1
      Styles.GroupByBox = AnaForm.cxStyle1
      Styles.Header = AnaForm.cxStyle1
      object FGridDBTableView1DURUM: TcxGridDBColumn
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        FooterAlignmentHorz = taRightJustify
        GroupSummaryAlignment = taRightJustify
        Width = 74
      end
      object FGridDBTableView1VADE: TcxGridDBColumn
        DataBinding.FieldName = 'VADE'
        DataBinding.IsNullValueType = True
        Width = 130
      end
      object FGridDBTableView1SERINO: TcxGridDBColumn
        DataBinding.FieldName = 'SERINO'
        DataBinding.IsNullValueType = True
        FooterAlignmentHorz = taRightJustify
        GroupSummaryAlignment = taRightJustify
        Width = 109
      end
      object FGridDBTableView1HESAPADI: TcxGridDBColumn
        DataBinding.FieldName = 'HESAPADI'
        DataBinding.IsNullValueType = True
        Width = 354
      end
      object FGridDBTableView1Column1: TcxGridDBColumn
        DataBinding.FieldName = 'CEKID'
        DataBinding.IsNullValueType = True
      end
    end
    object FGridLevel1: TcxGridLevel
      GridView = FGridTableView
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 360
    Width = 1250
    Height = 184
    Align = alBottom
    TabOrder = 4
    object cxGrid1ChartView1: TcxGridChartView
      DiagramColumn.Active = True
      ToolBox.Border = tbNone
      ToolBox.CustomizeButton = True
      ToolBox.DiagramSelector = True
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1ChartView1
    end
  end
  object TabPivot: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'SELECT * FROM  fn_ButcePivot_Aylik (:PYil,:PGider)')
    Left = 576
    Top = 157
    object TabPivotGRUP: TWideStringField
      FieldName = 'GRUP'
      Size = 50
    end
    object TabPivotTUR: TWideStringField
      FieldName = 'TUR'
      Size = 50
    end
    object TabPivotYIL: TFloatField
      FieldName = 'YIL'
    end
    object TabPivotTARIH: TFloatField
      FieldName = 'TARIH'
    end
    object TabPivotTARIHYAZI: TStringField
      FieldName = 'TARIHYAZI'
    end
    object TabPivotPLANLANAN: TCurrencyField
      FieldName = 'PLANLANAN'
    end
    object TabPivotGERCEKLESEN: TCurrencyField
      FieldName = 'GERCEKLESEN'
    end
  end
  object DtsPivot: TDataSource
    DataSet = TabPivot
    Left = 683
    Top = 156
  end
  object cxPivotGridChartConnection1: TcxPivotGridChartConnection
    GridChartView = cxGrid1ChartView1
    PivotGrid = pivot
    SourceData = sdSelected
    Left = 132
    Top = 239
  end
end
