object SorumlulukMerkezListeDlg: TSorumlulukMerkezListeDlg
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 74
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
    Images = AnaForm.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 74
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 148
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object DuzenleTus: TToolButton
      Left = 156
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      OnClick = DuzenleTusClick
    end
  end
  object GridSRMMerkez: TcxGrid
    Left = 0
    Top = 35
    Width = 451
    Height = 269
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    object GridSRMMerkezDBTableView1: TcxGridDBTableView
      OnDblClick = GridSRMMerkezDBTableView1DblClick
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsTabSRMMerkezListe
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.HideSelection = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object GridSRMMerkezDBTVMERKEZKODU: TcxGridDBColumn
        Caption = 'Merkez Kodu'
        DataBinding.FieldName = 'MERKEZKODU'
        Width = 133
      end
      object GridSRMMerkezDBTVMERKEZADI: TcxGridDBColumn
        Caption = 'Merkez Ad'#305
        DataBinding.FieldName = 'MERKEZADI'
        Width = 215
      end
    end
    object GridSRMMerkezLevel1: TcxGridLevel
      GridView = GridSRMMerkezDBTableView1
    end
  end
  object DtsTabSRMMerkezListe: TDataSource
    DataSet = TabSRMMerkezListe
    Left = 259
    Top = 130
  end
  object TabSRMMerkezListe: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabSRMMerkezListeNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from SRMMERKEZI Where GELIRMI =:Par1')
    Left = 165
    Top = 126
  end
end
