object RehberAramaEkrani: TRehberAramaEkrani
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Arama Ekran'#305
  ClientHeight = 389
  ClientWidth = 897
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 891
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 56
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
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 0
      ImageName = 'PngImage0'
      Style = tbsTextButton
      OnClick = YeniTusClick
    end
    object ToolButton2: TToolButton
      Left = 56
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 7
      ImageName = 'PngImage7'
      Style = tbsSeparator
    end
    object SecTus: TToolButton
      Left = 64
      Top = 0
      Caption = 'Se'#231
      ImageIndex = 6
      ImageName = 'PngImage6'
      Visible = False
      OnClick = SecTusClick
    end
    object ToolButton1: TToolButton
      Left = 120
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 4
      ImageName = 'PngImage4'
      Style = tbsSeparator
    end
    object KapatTus: TToolButton
      Left = 128
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 5
      ImageName = 'PngImage5'
      OnClick = KapatTusClick
    end
    object ToolButton3: TToolButton
      Left = 184
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 4
      ImageName = 'PngImage4'
      Style = tbsSeparator
    end
  end
  object GridCariArama: TcxGrid
    Left = 0
    Top = 87
    Width = 897
    Height = 302
    Align = alClient
    TabOrder = 2
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridCariAramaDBTableView1: TcxGridDBTableView
      PopupMenu = PopupMenu1
      OnDblClick = SecTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = dsAra
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnTab = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Editing = False
      OptionsSelection.CellSelect = False
      OptionsView.GridLines = glNone
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object GridCariAramaDBTableView1ID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridCariAramaDBTableView1GRUP: TcxGridDBColumn
        Caption = 'Grup'
        DataBinding.FieldName = 'GRUP'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCariGrup
        Width = 76
      end
      object GridCariAramaDBTableView1Column1: TcxGridDBColumn
        Caption = 'S'#305'n'#305'f'
        DataBinding.FieldName = 'SINIF'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepCariSinif
        Width = 94
      end
      object GridCariAramaDBTableView1KOD1: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        DataBinding.IsNullValueType = True
        Width = 81
      end
      object GridCariAramaDBTableView1FIRMA1: TcxGridDBColumn
        Caption = #220'nvan'
        DataBinding.FieldName = 'FIRMA'
        DataBinding.IsNullValueType = True
        Width = 135
      end
      object GridCariAramaDBTableView1FATBASLIK: TcxGridDBColumn
        Caption = 'Resmi Ad'
        DataBinding.FieldName = 'FATBASLIK'
        DataBinding.IsNullValueType = True
        Width = 114
      end
      object GridCariAramaDBTableView1ADSOYAD1: TcxGridDBColumn
        Caption = #304'lgili'
        DataBinding.FieldName = 'ADSOYAD'
        DataBinding.IsNullValueType = True
        Width = 188
      end
      object GridCariAramaDBTableView1DURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
      end
    end
    object GridCariAramaLevel1: TcxGridLevel
      GridView = GridCariAramaDBTableView1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 27
    Width = 897
    Height = 60
    Align = alTop
    Color = 16757683
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    DesignSize = (
      897
      60)
    object LabelPNO: TLabel
      Left = 322
      Top = 5
      Width = 36
      Height = 18
      Caption = #220'nvan'
      FocusControl = AraFirma
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 435
      Top = 4
      Width = 25
      Height = 18
      Caption = #304'lgili'
      FocusControl = AraYetkili
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 249
      Top = 4
      Width = 21
      Height = 18
      Caption = '&Kod'
      FocusControl = AraKod
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
    end
    object Label12: TLabel
      Left = 4
      Top = 4
      Width = 28
      Height = 18
      Caption = '&Grup'
      FocusControl = ComboGrup
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
    end
    object JvNavPanelButton1: TJvNavPanelButton
      Left = 841
      Top = 14
      Width = 37
      Height = 40
      Anchors = [akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 16757683
      Colors.ButtonColorTo = 16757683
      Colors.ButtonHotColorFrom = clSilver
      Colors.ButtonHotColorTo = clSilver
      Colors.ButtonSelectedColorFrom = clSilver
      Colors.ButtonSelectedColorTo = clSilver
      Colors.SplitterColorFrom = clSilver
      Colors.SplitterColorTo = clSilver
      Colors.DividerColorFrom = clSilver
      Colors.DividerColorTo = clSilver
      Colors.HeaderColorFrom = clSilver
      Colors.HeaderColorTo = clSilver
      Colors.FrameColor = clSilver
      Colors.ToolPanelHeaderColorTo = clSilver
      ImageIndex = 36
      OnClick = JvNavPanelButton1Click
      ExplicitLeft = 857
    end
    object Label1: TLabel
      Left = 179
      Top = 3
      Width = 40
      Height = 18
      Caption = '&Barkod'
      FocusControl = AraBarkod
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 92
      Top = 4
      Width = 27
      Height = 18
      Caption = '&S'#305'n'#305'f'
      FocusControl = ComboSinif
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
    end
    object AraFirma: TcxTextEdit
      Left = 323
      Top = 22
      Properties.OnChange = AraTusClick
      TabOrder = 4
      OnKeyUp = FormKeyUp
      Width = 110
    end
    object AraYetkili: TcxTextEdit
      Left = 435
      Top = 22
      Properties.OnChange = AraTusClick
      TabOrder = 5
      OnKeyUp = FormKeyUp
      Width = 130
    end
    object AraKod: TcxTextEdit
      Left = 249
      Top = 22
      Properties.OnChange = AraTusClick
      TabOrder = 3
      OnKeyUp = FormKeyUp
      Width = 72
    end
    object ComboGrup: TcxImageComboBox
      Left = 2
      Top = 22
      RepositoryItem = Tablo.RepCariGrup
      Properties.Items = <>
      Properties.OnChange = AraTusClick
      TabOrder = 0
      Width = 87
    end
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 19947
      Top = 19384
      Width = 60
      Height = 33
      Margins.Bottom = 0
      Align = alCustom
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 59
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
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 8
      Transparent = True
      ExplicitLeft = 19941
      ExplicitTop = 19378
    end
    object LabelSon: TcxLabel
      Tag = 1
      Left = 703
      Top = 8
      Cursor = crHandPoint
      Caption = 'Son Arananlar'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      OnClick = LabelSonClick
    end
    object LabelSIK: TcxLabel
      Left = 703
      Top = 34
      Cursor = crHandPoint
      Caption = 'S'#305'k Arananlar'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      OnClick = LabelSonClick
    end
    object AraBarkod: TcxTextEdit
      Left = 179
      Top = 22
      Properties.OnChange = AraTusClick
      TabOrder = 2
      OnKeyUp = FormKeyUp
      Width = 68
    end
    object ComboSinif: TcxImageComboBox
      Left = 90
      Top = 22
      RepositoryItem = Tablo.RepCariSinif
      Properties.Items = <>
      Properties.OnChange = AraTusClick
      TabOrder = 1
      Width = 87
    end
    object CheckPasifler: TcxCheckBox
      Left = 574
      Top = 22
      Caption = 'Pasifler de gelsin'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 9
      OnClick = AraTusClick
    end
  end
  object AraQuery1: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = AraQuery1AfterOpen
    ParamData = <>
    Left = 160
    Top = 205
  end
  object dsAra: TDataSource
    AutoEdit = False
    DataSet = AraQuery1
    Left = 203
    Top = 200
  end
  object JvTimer1: TJvTimer
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 583
    Top = 156
  end
  object PopupMenu1: TPopupMenu
    Left = 688
    Top = 160
    object GrupIceriginiGosterMenu: TMenuItem
      Caption = 'Grup '#304#231'eri'#287'ini G'#246'ster'
      OnClick = GrupIceriginiGosterMenuClick
    end
  end
end

