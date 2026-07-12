object DovizDlg: TDovizDlg
  Left = 229
  Top = 186
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'G'#252'nl'#252'k D'#246'viz Kurlar'#305
  ClientHeight = 509
  ClientWidth = 773
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 16
  object Panel2: TPanel
    Left = 0
    Top = 35
    Width = 773
    Height = 474
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    Caption = 'Panel2'
    TabOrder = 0
    ExplicitTop = 32
    ExplicitHeight = 477
    object DBGrid1: TcxGrid
      Left = 6
      Top = 33
      Width = 761
      Height = 435
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      object DBGrid1DBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsDoviz
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.AlwaysShowEditor = True
        OptionsBehavior.FocusCellOnTab = True
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsSelection.HideSelection = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object DBGrid1DBTableView1TARIH1: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
          DataBinding.IsNullValueType = True
          Styles.Header = cxStyle1
          Width = 148
        end
        object DBGrid1DBTableView1CINSI1: TcxGridDBColumn
          Caption = 'Cinsi'
          DataBinding.FieldName = 'CINSI'
          DataBinding.IsNullValueType = True
          Styles.Header = cxStyle2
          Width = 84
        end
        object DBGrid1DBTableView1ALIS1: TcxGridDBColumn
          Caption = 'Al'#305#351
          DataBinding.FieldName = 'ALIS'
          DataBinding.IsNullValueType = True
          Styles.Header = cxStyle3
          Width = 116
        end
        object DBGrid1DBTableView1SATIS1: TcxGridDBColumn
          Caption = 'Sat'#305#351
          DataBinding.FieldName = 'SATIS'
          DataBinding.IsNullValueType = True
          Styles.Header = cxStyle4
          Width = 107
        end
        object DBGrid1DBTableView1EFALIS1: TcxGridDBColumn
          Caption = 'Ef. Al'#305#351
          DataBinding.FieldName = 'EFALIS'
          DataBinding.IsNullValueType = True
          Styles.Header = cxStyle5
          Width = 108
        end
        object DBGrid1DBTableView1EFSATIS1: TcxGridDBColumn
          Caption = 'Ef. Sat'#305#351
          DataBinding.FieldName = 'EFSATIS'
          DataBinding.IsNullValueType = True
          Styles.Header = cxStyle6
          Width = 117
        end
      end
      object DBGrid1Level1: TcxGridLevel
        GridView = DBGrid1DBTableView1
      end
    end
    object Panel1: TPanel
      Left = 6
      Top = 6
      Width = 761
      Height = 27
      Align = alTop
      TabOrder = 1
      object Label2: TcxLabel
        Left = 342
        Top = 5
        Caption = 'Tarih'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label1: TcxLabel
        Left = 10
        Top = 5
        Caption = 'D'#246'viz'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object DateDovizTarihi: TcxDateEdit
        Left = 376
        Top = 1
        Properties.OnChange = DateDovizTarihiPropertiesChange
        Properties.OnCloseUp = DateDovizTarihiPropertiesCloseUp
        TabOrder = 0
        Width = 209
      end
      object ComboKur: TcxComboBox
        Left = 50
        Top = 2
        Properties.DropDownListStyle = lsFixedList
        Properties.OnChange = ComboKurPropertiesChange
        TabOrder = 1
        Width = 143
      end
    end
  end
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 767
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 86
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
    Images = Tablo.PNGImageList1
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
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 86
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 172
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 258
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton1: TToolButton
      Left = 344
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 352
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      ImageName = 'PngImage0'
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 360
      Top = 0
      Caption = 'Aksiyonlar'
      DropdownMenu = PopupMenu1
      ImageIndex = 19
      ImageName = 'PngImage19'
    end
    object btnKapat: TToolButton
      Left = 446
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      ImageName = 'PngImage17'
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object DtsDoviz: TDataSource
    DataSet = TabDoviz
    OnStateChange = DtSDovizStateChange
    Left = 152
    Top = 137
  end
  object TabDoviz: TFDQuery
    BeforeEdit = TabDovizBeforeEdit
    BeforePost = TabDovizBeforePost
    AfterPost = TabDovizAfterPost
    OnNewRecord = TabDovizNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from DOVIZ')
    Left = 88
    Top = 153
  end
  object IdHTTP1: TIdHTTP
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 256
    Top = 176
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 96
    Top = 248
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 272
    Top = 99
    object KurGetirMenu: TMenuItem
      Caption = 'Kurlar'#305' getir       '
      OnClick = KurGetirMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MBGuncelleMenu: TMenuItem
      Caption = 'MB'#39'dan G'#252'ncelle'
      OnClick = MBGuncelleMenuClick
    end
  end
  object XMLDocument1: TXMLDocument
    Left = 404
    Top = 160
    DOMVendorDesc = 'MSXML'
  end
  object ADOQuery1: TFDQuery
    Connection = Tablo.FDCnn
    Left = 196
    Top = 245
  end
  object ADOQuery2: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select  * from DOVIZCINSLERI  where DIL=-1')
    Left = 264
    Top = 246
  end
end
