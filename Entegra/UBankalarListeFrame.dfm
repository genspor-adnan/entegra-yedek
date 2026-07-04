object BankalarListeFrame: TBankalarListeFrame
  Left = 0
  Top = 0
  Width = 1106
  Height = 538
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1100
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 96
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
      Left = 115
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      Visible = False
      OnClick = SilTusClick
    end
    object ToolButton2: TToolButton
      Left = 230
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 5
      ImageName = 'PngImage5'
      Style = tbsSeparator
    end
    object DegisTus: TToolButton
      Left = 238
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      Visible = False
      OnClick = DegisTusClick
    end
    object ToolButton1: TToolButton
      Left = 353
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object ExceldenAlTus: TToolButton
      Left = 361
      Top = 0
      Caption = 'Veri Aktar'#305'm'
      ImageIndex = 17
      ImageName = 'PngImage16'
      Visible = False
      OnClick = ExceldenAlTusClick
    end
    object AksiyonTus: TToolButton
      Left = 476
      Top = 0
      Caption = 'Aksiyonlar'
      ImageIndex = 1
      ImageName = 'PngImage0'
      OnClick = AksiyonTusClick
    end
    object ToolButton3: TToolButton
      Left = 591
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
    object BankaHizliGirisTus: TToolButton
      Left = 599
      Top = 0
      Caption = 'Banka H'#305'zl'#305' Giri'#351
      ImageIndex = 1
      Style = tbsTextButton
      OnClick = BankaHizliGirisTusClick
    end
  end
  object cxGrid: TcxGrid
    Left = 0
    Top = 35
    Width = 1106
    Height = 187
    Align = alClient
    PopupMenu = BankaListeMenu1
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
      DataController.DataSource = DtsBankalar
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skCount
          FieldName = 'HESAPADI'
          Column = GridTviewHESAPADI
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.HideFocusRectOnExit = False
      OptionsView.Footer = True
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = GridTviewStylesGetContentStyle
      object GridTviewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
      end
      object GridTviewHESAPKODU: TcxGridDBColumn
        Caption = 'Hesap Kodu'
        DataBinding.FieldName = 'HESAPKODU'
        DataBinding.IsNullValueType = True
        Width = 67
      end
      object GridTviewHESAPADI: TcxGridDBColumn
        Caption = 'Hesap Ad'#305
        DataBinding.FieldName = 'HESAPADI'
        DataBinding.IsNullValueType = True
        Width = 113
      end
      object GridTviewHESAPNO: TcxGridDBColumn
        Caption = 'Hesap No'
        DataBinding.FieldName = 'HESAPNO'
        DataBinding.IsNullValueType = True
        Width = 59
      end
      object GridTviewKUR: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        Width = 41
      end
      object GridTviewTIPI: TcxGridDBColumn
        Caption = 'Tipi'
        DataBinding.FieldName = 'TIPI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Kurumsal'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Bireysel'
            Value = 1
          end>
        Width = 52
      end
      object GridTviewBANKAADI: TcxGridDBColumn
        Caption = 'Banka'
        DataBinding.FieldName = 'BANKAADI'
        DataBinding.IsNullValueType = True
        Width = 107
      end
      object GridTviewSUBEKODU: TcxGridDBColumn
        Caption = #350'ube Kodu'
        DataBinding.FieldName = 'SUBEKODU'
        DataBinding.IsNullValueType = True
        Width = 91
      end
      object GridTviewSUBEADI: TcxGridDBColumn
        Caption = 'Banka '#350'ube'
        DataBinding.FieldName = 'SUBEADI'
        DataBinding.IsNullValueType = True
        Width = 96
      end
      object GridTviewIBAN: TcxGridDBColumn
        DataBinding.FieldName = 'IBAN'
        DataBinding.IsNullValueType = True
        Width = 125
      end
      object GridTviewBAKIYE: TcxGridDBColumn
        Caption = 'Bakiye'
        DataBinding.FieldName = 'BAKIYE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
      end
      object GridTviewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        Width = 40
      end
      object GridTviewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = GridTview
    end
  end
  object PageControlSekme: TcxPageControl
    Left = 0
    Top = 230
    Width = 1106
    Height = 308
    Align = alBottom
    TabOrder = 4
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlSekmeChange
    ClientRectBottom = 304
    ClientRectLeft = 4
    ClientRectRight = 1102
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Toplamlar'
      ImageIndex = 1
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
      object GridBankaEkstre: TcxGrid
        Left = 0
        Top = 44
        Width = 1098
        Height = 233
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        PopupMenu = AksiyonlarMenu
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridBankaEkstreView: TcxGridDBTableView
          OnDblClick = AksiyonBilgisiniGorMenuClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridBankaEkstreViewCanFocusRecord
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsCariListe
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = GridBankaEkstreViewBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = GridBankaEkstreViewALACAK
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
              Column = GridBankaEkstreViewBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
              Column = GridBankaEkstreViewALACAK
            end
            item
              Format = ',0.00;(,0.00)'
              Column = GridBankaEkstreViewBORCBAKIYE
            end
            item
              Format = ',0.00;(,0.00)'
              Column = GridBankaEkstreViewALACAKBAKIYE
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
          Styles.OnGetContentStyle = GridBankaEkstreViewStylesGetContentStyle
          Styles.GroupByBox = AnaForm.cxStyle1
          Styles.Header = AnaForm.cxStyle1
          object GridBankaEkstreViewID: TcxGridDBColumn
            Caption = 'ID'
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
            Width = 38
          end
          object GridBankaEkstreViewTARIH: TcxGridDBColumn
            Caption = 'Kay'#305't'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            Width = 68
          end
          object GridBankaEkstreViewAKSIYONTARIH: TcxGridDBColumn
            Caption = 'Aksiyon/Vade'
            DataBinding.FieldName = 'AKSIYONTARIH'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object GridBankaEkstreViewNO: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'NO'
            DataBinding.IsNullValueType = True
            Width = 75
          end
          object GridBankaEkstreViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleriReadOnly
          end
          object GridBankaEkstreViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 77
          end
          object GridBankaEkstreViewAD: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 90
          end
          object GridBankaEkstreViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 128
          end
          object GridBankaEkstreViewHESAPKODU: TcxGridDBColumn
            Caption = 'Hesap Kodu'
            DataBinding.FieldName = 'HESAPKODU'
            DataBinding.IsNullValueType = True
            Width = 91
          end
          object GridBankaEkstreViewHESAPADI: TcxGridDBColumn
            Caption = 'Hesap Ad'#305
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 82
          end
          object GridBankaEkstreViewBORC: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.FieldName = 'BORC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 56
          end
          object GridBankaEkstreViewALACAK: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.FieldName = 'ALACAK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 67
          end
          object GridBankaEkstreViewBORCBAKIYE: TcxGridDBColumn
            Caption = 'B.Bakiye'
            DataBinding.FieldName = 'BORCBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 54
          end
          object GridBankaEkstreViewALACAKBAKIYE: TcxGridDBColumn
            Caption = 'A.Bakiye'
            DataBinding.FieldName = 'ALACAKBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 56
          end
          object GridBankaEkstreViewKUR: TcxGridDBColumn
            Caption = 'Para Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
            Width = 76
          end
          object GridBankaEkstreViewYERELKUR: TcxGridDBColumn
            Caption = 'Y.Kur'
            DataBinding.FieldName = 'YERELKUR'
            DataBinding.IsNullValueType = True
          end
          object GridBankaEkstreViewYERELTUTAR: TcxGridDBColumn
            Caption = 'Y.Tutar'
            DataBinding.FieldName = 'YERELTUTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object GridBankaEkstreViewYERELBAKIYE: TcxGridDBColumn
            Caption = 'Y.Bakiye'
            DataBinding.FieldName = 'YERELBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
        end
        object GridBankaEkstreDBTableView1: TcxGridDBTableView
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
          object GridBankaEkstreDBTableView1DURUM: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object GridBankaEkstreDBTableView1VADE: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 130
          end
          object GridBankaEkstreDBTableView1SERINO: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object GridBankaEkstreDBTableView1HESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 354
          end
          object GridBankaEkstreDBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
          end
        end
        object GridBankaEkstreLevel1: TcxGridLevel
          GridView = GridBankaEkstreView
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 1098
        Height = 44
        Align = alTop
        Caption = 'Panel1'
        TabOrder = 1
        object ToolBar11: TToolBar
          Left = 1
          Top = 1
          Width = 200
          Height = 42
          Margins.Bottom = 0
          Align = alLeft
          ButtonHeight = 47
          ButtonWidth = 61
          Caption = 'AletCubugu'
          Ctl3D = False
          DockSite = True
          DrawingStyle = dsGradient
          EdgeInner = esNone
          EdgeOuter = esNone
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          GradientEndColor = 11776947
          GradientStartColor = 14540253
          Images = Tablo.PNGImageList1
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          object YaziciYaz: TToolButton
            Left = 0
            Top = 0
            Caption = '   Yazd'#305'r   '
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
          object ExceldenAlTus2: TToolButton
            Left = 61
            Top = 0
            Caption = 'Excelden Al'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Visible = False
          end
        end
        object JvNavPanelHeader2: TJvNavPanelHeader
          Left = 201
          Top = 1
          Width = 896
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
          object Label1: TLabel
            Left = 10
            Top = 11
            Width = 48
            Height = 18
            Caption = 'Ba'#351'lama'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            Transparent = True
            OnClick = Label1Click
          end
          object Label2: TLabel
            Left = 237
            Top = 11
            Width = 26
            Height = 18
            Caption = 'Biti'#351
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object CalendarEkstreBas: TcxDateEdit
            Left = 68
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
            TabOrder = 0
            Width = 121
          end
          object CalendarEkstreBit: TcxDateEdit
            Left = 268
            Top = 8
            EditValue = 40940d
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
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 222
    Width = 1106
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = PageControlSekme
  end
  object SqlMemo: TMemo
    Left = 137
    Top = 125
    Width = 650
    Height = 65
    Lines.Strings = (
      'select BH.ID AS '
      
        'ID,DURUM,KUR,TIPI,B.BANKAKODU,BANKAADI,SUBEKODU,SUBEADI,HESAPNO,' +
        'BAKIYE,'
      'IBAN,HESAPADI,HESAPKODU,BH.ONLINEHESAPHAREKETI,BH.SUBEID '
      '   from BANKAHESAPLAR BH '
      '        inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID'
      '        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU')
    TabOrder = 2
    Visible = False
  end
  object DtsBankalar: TDataSource
    DataSet = BANKALAR
    Left = 169
    Top = 72
  end
  object BANKALAR: TFDQuery
    AfterOpen = BANKALARAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select BH.ID AS ID,DURUM,KUR,TIPI,BANKAADI,SUBEKODU,BAKIYE,SUBEA' +
        'DI,HESAPNO,HESAPADI,HESAPKODU,BH.ONLINEHESAPHAREKETI,BH.SUBEID ,' +
        'BH.BAKIYE ,B.BANKAKODU'
      '   from BANKAHESAPLAR BH '
      '        inner join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID'
      '        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where REHBERID=-1'
      'and'
      
        '(BH.HESAPNO like  :PHNO or B.BANKAADI like :PBA) and (SUBEID=0 o' +
        'r SUBEID=:SubeId) '
      'ORDER BY 5,1')
    Left = 71
    Top = 136
  end
  object TabCariListe1: TFDQuery
    Connection = Tablo.FDCnn
    Left = 399
    Top = 198
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
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = EKSTRE
    BCDToCurrency = False
    DataSetOptions = []
    Left = 574
    Top = 206
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
    Left = 651
    Top = 250
  end
  object DtsCariListe: TDataSource
    DataSet = EKSTRE
    Left = 596
    Top = 267
  end
  object PopupMenuYaz: TPopupMenu
    Left = 79
    Top = 192
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
  object BankaListeMenu1: TPopupMenu
    Left = 254
    Top = 129
    object BankaInfoMenu: TMenuItem
      Caption = 'info'
      OnClick = BankaInfoMenuClick
    end
    object HesaplararasTransferYap1: TMenuItem
      Caption = 'Aksiyonlar'
      OnClick = AksiyonTusClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object YeniBanka1: TMenuItem
      Caption = 'Yeni Banka Hesab'#305
      OnClick = YeniTusClick
    end
    object HesabDzenle1: TMenuItem
      Caption = 'Hesab'#305' D'#252'zenle'
      OnClick = DegisTusClick
    end
    object HesabSil1: TMenuItem
      Caption = 'Hesab'#305' Sil'
      OnClick = SilTusClick
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object HesapBakiyesiniGuncelleMenu: TMenuItem
      Caption = 'Hesap Bakiyesini G'#252'ncelle'
      OnClick = HesapBakiyesiniGuncelleMenuClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object AcilisKaydiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      OnClick = AcilisKaydiMenuClick
    end
    object DevirFiiGir1: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir'
      Visible = False
      OnClick = AcilisKaydiMenuClick
    end
  end
  object AksiyonlarMenu: TPopupMenu
    OnPopup = AksiyonlarMenuPopup
    Left = 555
    Top = 325
    object ExceleAktar1: TMenuItem
      Caption = 'Excel'#39'e Ver'
      ImageIndex = 3
      OnClick = ExceleAktar1Click
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
    object N7: TMenuItem
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
    object N6: TMenuItem
      Caption = '-'
    end
    object KopyalaMenu: TMenuItem
      Caption = 'Kopyala'
      OnClick = KopyalaMenuClick
    end
  end
  object frxBANKA: TfrxDBDataset
    UserName = 'BANKALAR'
    CloseDataSource = False
    DataSet = BANKALAR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 634
    Top = 144
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
      
        'WHERE HESAPID=:Prm1 AND ISLEMTARIHI BETWEEN cast(year(getdate())' +
        ' as varchar(4))+'#39'-01-01 00:00'#39
      'AND cast(year(getdate()) as varchar(4))+'#39'-12-31 23:59'#39
      'and HESAPTURU='#39'B'#39
      'UNION ALL'
      'SELECT'
      'DEVIR = SUM(BORC-ALACAK),'
      'BORC=0,ALACAK=0'
      'FROM KASA K'
      
        'WHERE HESAPID=:Prm2 AND ISLEMTARIHI >=cast(year(getdate()) as va' +
        'rchar(4))+'#39'-01-01 00:00'#39' AND TUR<=2'
      'and HESAPTURU='#39'B'#39
      ') AS X'
      '')
    Left = 423
    Top = 276
  end
  object DtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 511
    Top = 276
  end
end
