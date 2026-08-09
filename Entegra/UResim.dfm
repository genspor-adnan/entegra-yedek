object ResimDlg: TResimDlg
  Left = 0
  Top = 0
  BorderIcons = [biMaximize]
  Caption = 'Resimler'
  ClientHeight = 496
  ClientWidth = 863
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 857
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 83
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
    HotTrackColor = clNone
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    OnDblClick = ToolBar1DblClick
    object YapistirTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yap'#305#351't'#305'r'
      ImageIndex = 7
      OnClick = YapistirTusClick
    end
    object DosyadanTus: TToolButton
      Left = 83
      Top = 0
      Caption = 'Dosyadan'
      ImageIndex = 7
      Style = tbsTextButton
      OnClick = DosyadanTusClick
    end
    object ToolButton1: TToolButton
      Left = 166
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object SilTus: TToolButton
      Left = 174
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton4: TToolButton
      Left = 257
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 265
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object GridResim: TcxGrid
    Left = 0
    Top = 35
    Width = 228
    Height = 461
    Align = alLeft
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    ExplicitHeight = 429
    object GridResimView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsResim
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Appending = True
      OptionsData.DeletingConfirmation = False
      OptionsSelection.CellSelect = False
      OptionsView.ScrollBars = ssVertical
      OptionsView.DataRowHeight = 100
      OptionsView.GridLines = glNone
      OptionsView.GroupByBox = False
      OptionsView.Header = False
      object cxGridDBColumn1: TcxGridDBColumn
        Caption = 'T'#252'r'#252
        DataBinding.FieldName = 'BELGE'
        PropertiesClassName = 'TcxImageProperties'
        Properties.FitMode = ifmStretch
        Properties.GraphicClassName = 'TJPEGImage'
        MinWidth = 75
        Options.Filtering = False
        Options.FilteringFilteredItemsList = False
        Options.FilteringMRUItemsList = False
        Options.FilteringPopup = False
        Options.FilteringPopupMultiSelect = False
        Options.IgnoreTimeForFiltering = False
        Options.IncSearch = False
        Options.ShowEditButtons = isebAlways
        Options.GroupFooters = False
        Options.Grouping = False
        Options.ShowCaption = False
        Options.Sorting = False
        Width = 150
      end
      object GridResimViewColumn1: TcxGridDBColumn
        Caption = 'Var.'
        DataBinding.FieldName = 'VARSAYILAN'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
      end
    end
    object GridFirIlet: TcxGridLevel
      GridView = GridResimView
    end
  end
  object LogoResim: TcxImage
    Left = 228
    Top = 35
    Align = alClient
    Properties.GraphicClassName = 'TJPEGImage'
    Style.Color = 11776947
    TabOrder = 2
    OnClick = LogoResimClick
    ExplicitLeft = 234
    ExplicitTop = 38
    Height = 461
    Width = 635
  end
  object TabResim: TFDQuery
    Connection = Tablo.FDCnn
    BeforeOpen = TabResimBeforeOpen
    AfterOpen = TabResimAfterOpen
    AfterScroll = TabResimAfterScroll
    OnNewRecord = TabResimNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from IMAJ '
      'where YERI=:YER and YER_ID=:YID order by 2')
    Left = 191
    Top = 65
  end
  object DtsResim: TDataSource
    DataSet = TabResim
    Left = 264
    Top = 64
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 299
    Top = 132
    object Varsaylanyap1: TMenuItem
      Caption = 'Varsay'#305'lan yap'
      ImageIndex = 23
      OnClick = Varsaylanyap1Click
    end
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 253
    Top = 260
  end
end

