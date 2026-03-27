object RehberAramaEkrani: TRehberAramaEkrani
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Arama Ekran'#305
  ClientHeight = 387
  ClientWidth = 728
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 722
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
    Images = AnaForm.PNGImageList2
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
      Style = tbsTextButton
      OnClick = YeniTusClick
    end
    object ToolButton2: TToolButton
      Left = 56
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object SecTus: TToolButton
      Left = 64
      Top = 0
      Caption = 'Se'#231
      ImageIndex = 6
      Visible = False
      OnClick = SecTusClick
    end
    object ToolButton1: TToolButton
      Left = 120
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object KapatTus: TToolButton
      Left = 128
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 5
      OnClick = KapatTusClick
    end
    object ToolButton3: TToolButton
      Left = 184
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 4
      Style = tbsSeparator
    end
  end
  object GridCariArama: TcxGrid
    Left = 0
    Top = 87
    Width = 728
    Height = 300
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    object GridCariAramaDBTableView1: TcxGridDBTableView
      OnDblClick = SecTusClick
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = dsAra
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnTab = True
      OptionsData.CancelOnExit = False
      OptionsData.Editing = False
      OptionsSelection.CellSelect = False
      OptionsView.GridLines = glNone
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object GridCariAramaDBTableView1ID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        Visible = False
      end
      object GridCariAramaDBTableView1GRUP: TcxGridDBColumn
        Caption = 'Grup'
        DataBinding.FieldName = 'GRUP'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        Width = 76
      end
      object GridCariAramaDBTableView1KOD1: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        Width = 81
      end
      object GridCariAramaDBTableView1FIRMA1: TcxGridDBColumn
        Caption = #220'nvan'
        DataBinding.FieldName = 'FIRMA'
        Width = 135
      end
      object GridCariAramaDBTableView1ADSOYAD1: TcxGridDBColumn
        Caption = #304'lgili'
        DataBinding.FieldName = 'ADSOYAD'
        Width = 188
      end
    end
    object GridCariAramaLevel1: TcxGridLevel
      GridView = GridCariAramaDBTableView1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 27
    Width = 728
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
    TabOrder = 2
    object LabelPNO: TLabel
      Left = 172
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
      Left = 309
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
      Left = 94
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
      Left = 9
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
    object rbIcindeGecen: TRadioButton
      Left = 442
      Top = 27
      Width = 81
      Height = 17
      Caption = #304#231'inde Ge'#231'en'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = rbIcindeGecenClick
    end
    object rbBaslayan: TRadioButton
      Left = 442
      Top = 13
      Width = 65
      Height = 17
      Caption = 'Ba'#351'layan'
      Checked = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      TabStop = True
      OnClick = rbBaslayanClick
    end
    object AraFirma: TcxTextEdit
      Left = 172
      Top = 22
      Properties.OnChange = AraTusClick
      TabOrder = 3
      Width = 130
    end
    object AraYetkili: TcxTextEdit
      Left = 308
      Top = 22
      Properties.OnChange = AraTusClick
      TabOrder = 4
      Width = 130
    end
    object AraKod: TcxTextEdit
      Left = 94
      Top = 22
      Properties.OnChange = AraTusClick
      TabOrder = 2
      Width = 72
    end
    object ComboGrup: TcxImageComboBox
      Left = 5
      Top = 22
      Properties.Items = <>
      Properties.OnChange = AraTusClick
      TabOrder = 1
      Width = 87
    end
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 10233
      Top = 9670
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
      Images = AnaForm.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 6
      Transparent = True
      ExplicitLeft = 10227
      ExplicitTop = 9664
    end
    object LabelSon: TcxLabel
      Tag = 1
      Left = 559
      Top = 9
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
      Left = 559
      Top = 29
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
  end
  object AraQuery1: TADOQuery
    Connection = Tablo.cnn
    LockType = ltReadOnly
    AfterOpen = AraQuery1AfterOpen
    Parameters = <>
    Left = 374
    Top = 18
  end
  object dsAra: TDataSource
    AutoEdit = False
    DataSet = AraQuery1
    Left = 377
    Top = 55
  end
end
