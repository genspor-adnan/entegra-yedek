object KasalarListeFrame: TKasalarListeFrame
  Left = 0
  Top = 0
  Width = 1013
  Height = 644
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1007
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 89
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
    TabOrder = 0
    Transparent = True
    ExplicitHeight = 29
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 86
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      Visible = False
      OnClick = SilTusClick
    end
    object ToolButton3: TToolButton
      Left = 172
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object DegisTus: TToolButton
      Left = 180
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      Visible = False
      OnClick = DegisTusClick
    end
    object AksiyonTus: TToolButton
      Left = 266
      Top = 0
      Caption = 'Aksiyonlar'
      ImageIndex = 1
      ImageName = 'PngImage0'
      OnClick = AksiyonTusClick
    end
    object ToolButton1: TToolButton
      Left = 352
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
  end
  object cxGrid: TcxGrid
    Left = 0
    Top = 35
    Width = 1013
    Height = 334
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    PopupMenu = KasaListeMenu
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridTview: TcxGridDBTableView
      OnDblClick = DegisTusClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridTviewCanFocusRecord
      OnSelectionChanged = GridTviewSelectionChanged
      DataController.DataSource = DtsKasalar
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = GridTviewStylesGetContentStyle
      object GridTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewKASAKODU: TcxGridDBColumn
        Caption = 'Kasa Kodu'
        DataBinding.FieldName = 'KASAKODU'
        DataBinding.IsNullValueType = True
      end
      object GridTviewKASAADI: TcxGridDBColumn
        Caption = 'Kasa Ad'#305
        DataBinding.FieldName = 'KASAADI'
        DataBinding.IsNullValueType = True
        Width = 233
      end
      object GridTviewKALAN: TcxGridDBColumn
        Caption = 'Bakiye'
        DataBinding.FieldName = 'BAKIYE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Width = 86
      end
      object GridTviewKUR: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        Width = 48
      end
      object GridTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        Width = 57
      end
      object GridTviewGIREN: TcxGridDBColumn
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewCIKAN: TcxGridDBColumn
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridTviewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = GridTview
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 369
    Width = 1013
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = PageControlSekme
  end
  object PageControlSekme: TcxPageControl
    Left = 0
    Top = 377
    Width = 1013
    Height = 267
    Align = alBottom
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlSekmeChange
    ClientRectBottom = 263
    ClientRectLeft = 4
    ClientRectRight = 1009
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Toplamlar'
      ImageIndex = 1
      PopupMenu = PopupMenuBakiye
      object cxLabel1: TcxLabel
        Left = 48
        Top = 23
        Caption = 'Devir'
        Transparent = True
      end
      object cxDBCurrencyEdit1: TcxDBCurrencyEdit
        Left = 146
        Top = 23
        DataBinding.DataField = 'DEVIR'
        DataBinding.DataSource = DtsTOPLAMLAR
        Properties.DisplayFormat = ',0.00;-,0.00'
        Style.Color = clScrollBar
        TabOrder = 1
        Width = 121
      end
      object cxDBCurrencyEdit2: TcxDBCurrencyEdit
        Left = 146
        Top = 53
        DataBinding.DataField = 'BORC'
        DataBinding.DataSource = DtsTOPLAMLAR
        Properties.DisplayFormat = ',0.00;-,0.00'
        Style.Color = clMoneyGreen
        TabOrder = 2
        Width = 121
      end
      object cxLabel4: TcxLabel
        Left = 48
        Top = 53
        Caption = 'Toplam Bor'#231
        Transparent = True
      end
      object cxDBCurrencyEdit3: TcxDBCurrencyEdit
        Left = 146
        Top = 83
        DataBinding.DataField = 'ALACAK'
        DataBinding.DataSource = DtsTOPLAMLAR
        Properties.DisplayFormat = ',0.00;-,0.00'
        Style.Color = 11184895
        TabOrder = 4
        Width = 121
      end
      object cxLabel6: TcxLabel
        Left = 48
        Top = 83
        Caption = 'Toplam Alacak'
        Transparent = True
      end
      object cxDBCurrencyEdit4: TcxDBCurrencyEdit
        Left = 146
        Top = 113
        DataBinding.DataField = 'BAKIYE'
        DataBinding.DataSource = DtsTOPLAMLAR
        Properties.DisplayFormat = ',0.00;-,0.00'
        Style.Color = clSkyBlue
        TabOrder = 6
        Width = 121
      end
      object cxLabel8: TcxLabel
        Left = 48
        Top = 113
        Caption = 'Bakiye'
        Transparent = True
      end
    end
    object TabSheetEkstre: TcxTabSheet
      Caption = 'Ekstre'
      ImageIndex = 6
      OnShow = TabSheetEkstreShow
      object GridKasaEkstre: TcxGrid
        Left = 0
        Top = 44
        Width = 1005
        Height = 192
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        PopupMenu = AksiyonlarMenu
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridKasaEkstreView: TcxGridDBTableView
          OnDblClick = AksiyonBilgisiniGorMenuClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridKasaEkstreViewCanFocusRecord
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsCariListe
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = GridKasaEkstreViewBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = GridKasaEkstreViewALACAK
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
              Column = GridKasaEkstreViewBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
              Column = GridKasaEkstreViewALACAK
            end
            item
              Format = ',0.00;(,0.00)'
              Column = GridKasaEkstreViewBORCBAKIYE
            end
            item
              Format = ',0.00;(,0.00)'
              Column = GridKasaEkstreViewALACAKBAKIYE
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
          Styles.OnGetContentStyle = GridKasaEkstreViewStylesGetContentStyle
          Styles.GroupByBox = AnaForm.cxStyle1
          Styles.Header = AnaForm.cxStyle1
          object GridKasaEkstreViewTARIH: TcxGridDBColumn
            Caption = 'Kay'#305't'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Width = 68
          end
          object GridKasaEkstreViewAKSIYONTARIH: TcxGridDBColumn
            Caption = 'Aksiyon/Vade'
            DataBinding.FieldName = 'AKSIYONTARIH'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object GridKasaEkstreViewNO: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'NO'
            DataBinding.IsNullValueType = True
            Width = 75
          end
          object GridKasaEkstreViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleri
          end
          object GridKasaEkstreViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 77
          end
          object GridKasaEkstreViewAD: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 90
          end
          object GridKasaEkstreViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 128
          end
          object GridKasaEkstreViewHESAPKODU: TcxGridDBColumn
            Caption = 'Hesap Kodu'
            DataBinding.FieldName = 'HESAPKODU'
            DataBinding.IsNullValueType = True
            Width = 91
          end
          object GridKasaEkstreViewHESAPADI: TcxGridDBColumn
            Caption = 'Hesap Ad'#305
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 82
          end
          object GridKasaEkstreViewBORC: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.FieldName = 'BORC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 56
          end
          object GridKasaEkstreViewALACAK: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.FieldName = 'ALACAK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 67
          end
          object GridKasaEkstreViewBORCBAKIYE: TcxGridDBColumn
            Caption = 'B.Bakiye'
            DataBinding.FieldName = 'BORCBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 54
          end
          object GridKasaEkstreViewALACAKBAKIYE: TcxGridDBColumn
            Caption = 'A.Bakiye'
            DataBinding.FieldName = 'ALACAKBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 56
          end
          object GridKasaEkstreViewKUR: TcxGridDBColumn
            Caption = 'Para Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
            Width = 76
          end
          object GridKasaEkstreViewYERELKUR: TcxGridDBColumn
            Caption = 'Y.Kur'
            DataBinding.FieldName = 'YERELKUR'
            DataBinding.IsNullValueType = True
          end
          object GridKasaEkstreViewYERELTUTAR: TcxGridDBColumn
            Caption = 'Y.Tutar'
            DataBinding.FieldName = 'YERELTUTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object GridKasaEkstreViewYERELBAKIYE: TcxGridDBColumn
            Caption = 'Y.Bakiye'
            DataBinding.FieldName = 'YERELBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
        end
        object GridKasaEkstreDBTableView1: TcxGridDBTableView
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
          object GridKasaEkstreDBTableView1DURUM: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object GridKasaEkstreDBTableView1VADE: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 130
          end
          object GridKasaEkstreDBTableView1SERINO: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object GridKasaEkstreDBTableView1HESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 354
          end
          object GridKasaEkstreDBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
          end
        end
        object GridKasaEkstreLevel1: TcxGridLevel
          GridView = GridKasaEkstreView
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 1005
        Height = 44
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 1
        object ToolBar11: TToolBar
          Left = 1
          Top = 1
          Width = 82
          Height = 42
          Margins.Bottom = 0
          Align = alLeft
          ButtonHeight = 47
          ButtonWidth = 54
          Caption = 'AletCubugu'
          Ctl3D = False
          DockSite = True
          DrawingStyle = dsGradient
          EdgeInner = esNone
          EdgeOuter = esNone
          GradientEndColor = 11776947
          GradientStartColor = 14540253
          Images = Tablo.PNGImageList1
          ShowCaptions = True
          TabOrder = 0
          Wrapable = False
          object YaziciYaz: TToolButton
            Left = 0
            Top = 0
            Caption = '  Yazd'#305'r   '
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
        end
        object JvNavPanelHeader2: TJvNavPanelHeader
          Left = 83
          Top = 1
          Width = 921
          Height = 42
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -16
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
          ColorFrom = 14540253
          ColorTo = 11776947
          ImageIndex = 0
          object Label2: TLabel
            Left = 216
            Top = 11
            Width = 26
            Height = 18
            Caption = 'Biti'#351
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
          end
          object Label1: TLabel
            Left = 4
            Top = 11
            Width = 48
            Height = 18
            Caption = 'Ba'#351'lama'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            OnClick = Label1Click
          end
          object Label3: TLabel
            Left = 420
            Top = 11
            Width = 58
            Height = 18
            Caption = 'Varl'#305'k Tipi'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            WordWrap = True
          end
          object CalendarEkstreBit: TcxDateEdit
            Left = 254
            Top = 8
            EditValue = 40941d
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.TextColor = clBlack
            Style.IsFontAssigned = True
            TabOrder = 0
            Width = 121
          end
          object CalendarEkstreBas: TcxDateEdit
            Left = 62
            Top = 8
            EditValue = 40909d
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.TextColor = clBlack
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 121
          end
          object CbNakitVarlikTipi: TcxImageComboBox
            Left = 492
            Top = 8
            RepositoryItem = Tablo.repKasaVarlikTipi
            EditValue = 0
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <
              item
                ImageIndex = 0
                Value = -99
              end
              item
                Description = 'Nakit'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = 'Havale/EFT'
                Value = 1
              end>
            Style.Color = clBtnFace
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Arial'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 2
            Width = 121
          end
        end
      end
    end
  end
  object SqlMemo: TMemo
    Left = 232
    Top = 143
    Width = 611
    Height = 26
    Lines.Strings = (
      'select * from KASALAR'
      'Where 1=1')
    TabOrder = 4
    Visible = False
  end
  object DtsKasalar: TDataSource
    DataSet = KASALAR
    Left = 233
    Top = 80
  end
  object KASALAR: TFDQuery
    AfterOpen = KASALARAfterOpen
    BeforeDelete = KASALARBeforeDelete
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from KASALAR order by KASAKODU')
    Left = 103
    Top = 137
  end
  object PopupMenuYaz: TPopupMenu
    Left = 60
    Top = 243
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object TabCariListe1: TFDQuery
    Connection = Tablo.FDCnn
    Left = 387
    Top = 245
    object DateTimeField1: TDateTimeField
      FieldName = 'TARIH'
    end
    object StringField1: TStringField
      FieldName = 'KOD'
      FixedChar = True
      Size = 30
    end
    object StringField2: TStringField
      FieldName = 'AD'
      FixedChar = True
      Size = 50
    end
    object StringField3: TStringField
      FieldName = 'ACIKLAMA'
      FixedChar = True
      Size = 30
    end
    object StringField4: TStringField
      FieldName = 'HESAPKODU'
      FixedChar = True
    end
    object StringField5: TStringField
      FieldName = 'HESAPADI'
      FixedChar = True
      Size = 50
    end
    object StringField6: TStringField
      FieldName = 'KUR'
      FixedChar = True
      Size = 6
    end
    object BCDField1: TBCDField
      FieldName = 'BORC'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object BCDField2: TBCDField
      FieldName = 'ALACAK'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object TabCariListe1DURUM: TSmallintField
      FieldName = 'DURUM'
    end
  end
  object EKSTRE: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select CEKID=ID,TARIH,TUR, REHBERID,  CARIKOD AS KOD, CARIUNVAN ' +
        'AS AD, ACIKLAMA=NOTLAR, HESAPID, HESAPKODU, HESAPADI,DURUM, '
      
        '   BORC = case when TUR in(33,34) then cast(TUTAR as money) else' +
        ' 0 end, '
      
        '    ALACAK= case when TUR in(23,24) then cast(TUTAR as money) el' +
        'se 0 end,KUR From CEKLER (NOLOCK) ')
    Left = 492
    Top = 252
  end
  object DtsCariListe: TDataSource
    DataSet = EKSTRE
    Left = 669
    Top = 240
  end
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = EKSTRE
    BCDToCurrency = False
    DataSetOptions = []
    Left = 369
    Top = 94
  end
  object KasaListeMenu: TPopupMenu
    Left = 81
    Top = 73
    object KasaInfoMenu: TMenuItem
      Caption = 'info'
      OnClick = KasaInfoMenuClick
    end
    object AksMenu: TMenuItem
      Caption = 'Aksiyonlar'
      OnClick = AksiyonTusClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object AcilisKaydiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir/De'#287'i'#351'tir'
      OnClick = AcilisKaydiMenuClick
    end
    object DevirFiiGir1: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir/De'#287'i'#351'tir'
      Visible = False
      OnClick = AcilisKaydiMenuClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
  end
  object AksiyonlarMenu: TPopupMenu
    OnPopup = AksiyonlarMenuPopup
    Left = 163
    Top = 245
    object ExceleAktar1: TMenuItem
      Caption = 'Excel'#39'e Aktar'
      ImageIndex = 3
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object Ekle1: TMenuItem
      Caption = 'Aksiyon Ekle'
      OnClick = Ekle1Click
    end
    object Sil1: TMenuItem
      Caption = 'Aksiyon Sil'
      OnClick = Sil1Click
    end
    object AksiyonBilgisiniGorMenu: TMenuItem
      Caption = 'Aksiyon Bilgisini G'#246'r'
      OnClick = AksiyonBilgisiniGorMenuClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object KurFarkGeliri1: TMenuItem
      Tag = 88
      Caption = 'Kur Fark'#305' Geliri'
      OnClick = KurFarkGeliri1Click
    end
    object KurFarkGideri1: TMenuItem
      Tag = 98
      Caption = 'Kur Fark'#305' Gideri'
      OnClick = KurFarkGeliri1Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object KopyalaMenu: TMenuItem
      Caption = 'Kopyala'
      OnClick = KopyalaMenuClick
    end
  end
  object frxKasa: TfrxDBDataset
    UserName = 'KASALAR'
    CloseDataSource = False
    DataSet = KASALAR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 426
    Top = 169
  end
  object TOPLAMLAR: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT SUM(DEVIR) AS DEVIR,SUM(ALACAK) AS BORC,SUM(BORC) AS ALAC' +
        'AK, BAKIYE=SUM(ALACAK)-SUM(BORC)  FROM ('
      'SELECT'
      'DEVIR = 0,'
      'BORC=SUM(K.BORC),ALACAK=SUM(K.ALACAK)'
      'FROM KASA K'
      'WHERE HESAPID=:Prm1 AND year(ISLEMTARIHI)=year(getdate())'
      'and HESAPTURU='#39'K'#39
      'UNION ALL'
      'SELECT'
      'DEVIR = SUM(BORC-ALACAK),'
      'BORC=0,ALACAK=0'
      'FROM KASA K'
      
        'WHERE HESAPID=:Prm2 AND year(ISLEMTARIHI)>=year(getdate()) AND T' +
        'UR<=2'
      'and HESAPTURU='#39'K'#39
      ') AS X'
      ''
      '')
    Left = 551
    Top = 321
  end
  object DtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 457
    Top = 392
  end
  object PopupMenuBakiye: TPopupMenu
    Left = 361
    Top = 289
    object MenuItem1: TMenuItem
      Caption = 'Bakiyeyi '#252'st tarafa kaydet'
      OnClick = MenuItem1Click
    end
  end
end
