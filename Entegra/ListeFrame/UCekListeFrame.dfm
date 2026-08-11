object CekListeFrame: TCekListeFrame
  Left = 0
  Top = 0
  Width = 1081
  Height = 567
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
    Left = 0
    Top = 0
    Width = 1081
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
      Left = 96
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      Visible = False
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 192
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object DegisTus: TToolButton
      Left = 200
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      Visible = False
      OnClick = DegisTusClick
    end
    object AksiyonEkleTus: TToolButton
      Left = 296
      Top = 0
      Caption = 'Aksiyon Ekle'
      EnableDropdown = True
      ImageIndex = 1
      ImageName = 'PngImage0'
      Indeterminate = True
      Style = tbsTextButton
    end
    object ToolButton2: TToolButton
      Left = 392
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 10
      ImageName = 'PngImage9'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 400
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 277
    Width = 1081
    Height = 7
    AlignSplitter = salBottom
    Control = PageControlHarEkstre
  end
  object PageControlHarEkstre: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 284
    Width = 1081
    Height = 283
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = SheetHareketler
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlHarEkstreChange
    ClientRectBottom = 279
    ClientRectLeft = 4
    ClientRectRight = 1077
    ClientRectTop = 27
    object SheetHareketler: TcxTabSheet
      Caption = 'Hareketler'
      ImageIndex = 32
      object cxGridTarihce: TcxGrid
        Left = 0
        Top = 0
        Width = 1073
        Height = 252
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridTarihceDBTableView1: TcxGridDBTableView
          PopupMenu = PopupCekHareket
          OnDblClick = cxGridTarihceDBTableView1DblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = cxGridTarihceDBTableView1CanFocusRecord
          DataController.DataSource = DtsCekHareketler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsView.CellAutoHeight = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object cxGridTarihceDBTableView1TARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.Kind = ckDateTime
            MinWidth = 150
            Width = 230
          end
          object cxGridTarihceDBTableView1BELGENO: TcxGridDBColumn
            Caption = 'Makbuz No'
            DataBinding.FieldName = 'BELGENO'
            DataBinding.IsNullValueType = True
            Width = 114
          end
          object cxGridTarihceDBTableView1ISLEM: TcxGridDBColumn
            Caption = #304#351'lem'
            DataBinding.FieldName = 'ISLEM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleriReadOnly
            Width = 146
          end
          object cxGridTarihceDBTableView1ISLEMYERI: TcxGridDBColumn
            Caption = #304#351'lem Yeri'
            DataBinding.FieldName = 'ISLEMYERI'
            DataBinding.IsNullValueType = True
            Width = 158
          end
          object cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 266
          end
          object cxGridTarihceDBTableView1DOVIZ_TUTARI: TcxGridDBColumn
            Caption = 'Yerel Tutar'
            DataBinding.FieldName = 'DOVIZ_TUTARI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 176
          end
        end
        object cxGridTarihceLevel1: TcxGridLevel
          GridView = cxGridTarihceDBTableView1
        end
      end
    end
    object TabYorumMedya: TcxTabSheet
      Caption = 'Yorum / Medya'
      ImageIndex = 38
      object Panel4: TPanel
        Left = 0
        Top = 191
        Width = 1073
        Height = 41
        Align = alBottom
        TabOrder = 0
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 1
          Height = 39
          Width = 925
        end
        object BtnMesajGonder: TcxButton
          Left = 926
          Top = 1
          Width = 85
          Height = 39
          Align = alRight
          OptionsImage.ImageIndex = 39
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 0
          OnClick = BtnMesajGonderClick
        end
        object BtnDosyaGonder: TcxButton
          Left = 1011
          Top = 1
          Width = 61
          Height = 39
          Align = alRight
          DropDownMenu = YorumAtacMenu
          Kind = cxbkDropDown
          OptionsImage.ImageIndex = 38
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 2
        end
      end
      object labelFileName: TcxLabel
        Left = 0
        Top = 232
        ParentCustomHint = False
        Align = alBottom
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        Style.Edges = [bLeft, bRight]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.Shadow = False
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taRightJustify
        Transparent = True
        Visible = False
        AnchorX = 1073
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 1073
        Height = 191
        Align = alClient
        TabOrder = 2
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridYorumDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellDblClick = GridYorumDBCardView1CellDblClick
          DataController.DataSource = DtsYorum
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 2
          OptionsView.CardWidth = 900
          OptionsView.CategoryIndent = 1
          OptionsView.CategorySeparatorWidth = 1
          OptionsView.CellAutoHeight = True
          OptionsView.CellTextMaxLineCount = 5
          Styles.Content = Tablo.cxStyle6
          Styles.CardBorder = Tablo.cxStyle19
          object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 120
          end
          object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YAZAN'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
          end
          object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
            DataBinding.FieldName = 'ATAC'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repFileExtensionList
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 25
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
            DataBinding.FieldName = 'DOKUMANAD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 300
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YORUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxRichEditProperties'
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Styles.Content = Tablo.cxStyle12
            Styles.CategoryRow = Tablo.cxStyle4
          end
        end
        object GridYorumLevel1: TcxGridLevel
          GridView = GridYorumDBCardView1
        end
      end
    end
    object SheetEkstre: TcxTabSheet
      Caption = 'Ekstre'
      ImageIndex = 32
      object JvNavPanelHeader2: TJvNavPanelHeader
        Left = 0
        Top = 0
        Width = 1073
        Height = 41
        Align = alTop
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
        end
        object CalendarEkstreBit: TcxDateEdit
          Left = 254
          Top = 8
          EditValue = 42735d
          ParentFont = False
          Properties.ImmediatePost = True
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
          EditValue = 42370d
          ParentFont = False
          Properties.ImmediatePost = True
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
      object cxGrid1: TcxGrid
        Left = 0
        Top = 41
        Width = 1073
        Height = 211
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        PopupMenu = AksiyonlarMenu
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridHareketler: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = cxGridHareketlerCanFocusRecord
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsCekHesapEkstre
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = cxGridHareketlerBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = cxGridHareketlerALACAK
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
              Column = cxGridHareketlerBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
              Column = cxGridHareketlerALACAK
            end
            item
              Format = ',0.00;(,0.00)'
              Column = cxGridHareketlerBORCBAKIYE
            end
            item
              Format = ',0.00;(,0.00)'
              Column = cxGridHareketlerALACAKBAKIYE
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
          object cxGridHareketlerTARIH: TcxGridDBColumn
            Caption = 'Kay'#305't'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Width = 68
          end
          object cxGridHareketlerAKSIYONTARIH: TcxGridDBColumn
            Caption = 'Aksiyon/Vade'
            DataBinding.FieldName = 'AKSIYONTARIH'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object cxGridHareketlerNO: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'NO'
            DataBinding.IsNullValueType = True
            Width = 75
          end
          object cxGridHareketlerTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleri
          end
          object cxGridHareketlerKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 77
          end
          object cxGridHareketlerAD: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 90
          end
          object cxGridHareketlerACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 128
          end
          object cxGridHareketlerHESAPKODU: TcxGridDBColumn
            Caption = 'Hesap Kodu'
            DataBinding.FieldName = 'HESAPKODU'
            DataBinding.IsNullValueType = True
            Width = 91
          end
          object cxGridHareketlerHESAPADI: TcxGridDBColumn
            Caption = 'Hesap Ad'#305
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 82
          end
          object cxGridHareketlerBORC: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.FieldName = 'BORC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 56
          end
          object cxGridHareketlerALACAK: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.FieldName = 'ALACAK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 67
          end
          object cxGridHareketlerBORCBAKIYE: TcxGridDBColumn
            Caption = 'B.Bakiye'
            DataBinding.FieldName = 'BORCBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 54
          end
          object cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn
            Caption = 'A.Bakiye'
            DataBinding.FieldName = 'ALACAKBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Width = 56
          end
          object cxGridHareketlerKUR: TcxGridDBColumn
            Caption = 'Para Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
            Width = 76
          end
          object cxGridHareketlerYERELKUR: TcxGridDBColumn
            Caption = 'Y.Kur'
            DataBinding.FieldName = 'YERELKUR'
            DataBinding.IsNullValueType = True
          end
          object cxGridHareketlerYERELTUTAR: TcxGridDBColumn
            Caption = 'Y.Tutar'
            DataBinding.FieldName = 'YERELTUTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object cxGridHareketlerYERELBAKIYE: TcxGridDBColumn
            Caption = 'Y.Bakiye'
            DataBinding.FieldName = 'YERELBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
        end
        object cxGrid1DBTableView1: TcxGridDBTableView
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
          object cxGrid1DBTableView1DURUM: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object cxGrid1DBTableView1VADE: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 130
          end
          object cxGrid1DBTableView1SERINO: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object cxGrid1DBTableView1HESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 354
          end
          object cxGrid1DBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGridHareketler
        end
      end
    end
  end
  object PageControlCek: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 32
    Width = 1081
    Height = 245
    Align = alClient
    TabOrder = 3
    Properties.ActivePage = SheetCekListe
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlCekChange
    ClientRectBottom = 241
    ClientRectLeft = 4
    ClientRectRight = 1077
    ClientRectTop = 27
    object SheetCekListe: TcxTabSheet
      Caption = 'Liste'
      ImageIndex = 32
      object cxGrid: TcxGrid
        Left = 0
        Top = 0
        Width = 1073
        Height = 214
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridTview: TcxGridDBTableView
          OnDblClick = DegisTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridTviewCanFocusRecord
          DataController.DataSource = DtsCekler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Kind = skCount
              Position = spFooter
              FieldName = 'CARIUNVAN'
              Column = GridTviewCARIUNVAN
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              FieldName = 'TUTAR'
              Column = GridTviewTUTAR
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skCount
              FieldName = 'CARIUNVAN'
              Column = GridTviewCARIUNVAN
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'TUTAR'
              Column = GridTviewTUTAR
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
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.Footer = True
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object GridTviewCEKSENETID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridTviewSeriNo: TcxGridDBColumn
            Caption = 'Seri No'
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            Width = 77
          end
          object GridTviewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
            Width = 61
          end
          object GridTviewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'ISLEMTARIH'
            DataBinding.IsNullValueType = True
            Width = 64
          end
          object GridTviewMAKBUZNO: TcxGridDBColumn
            Caption = 'Makbuz No'
            DataBinding.FieldName = 'BELGENO'
            DataBinding.IsNullValueType = True
          end
          object GridTviewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Width = 56
          end
          object GridTviewVADE: TcxGridDBColumn
            Caption = 'Vade'
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 71
          end
          object GridTviewBASKASININ: TcxGridDBColumn
            Caption = 'Ba'#351'kas'#305'n'#305'n'
            DataBinding.FieldName = 'BASKASININ'
            DataBinding.IsNullValueType = True
            Width = 57
          end
          object GridTviewBORCLU: TcxGridDBColumn
            Caption = 'Bor'#231'lu'
            DataBinding.FieldName = 'BORCLU'
            DataBinding.IsNullValueType = True
          end
          object GridTviewCARIKOD: TcxGridDBColumn
            Caption = 'Cari Kodu'
            DataBinding.FieldName = 'CARIKOD'
            DataBinding.IsNullValueType = True
            Width = 69
          end
          object GridTviewCARIUNVAN: TcxGridDBColumn
            Caption = 'Cari '#220'nvan'#305
            DataBinding.FieldName = 'CARIUNVAN'
            DataBinding.IsNullValueType = True
            Width = 151
          end
          object GridTviewTUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;'
            Width = 78
          end
          object GridTviewKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 54
          end
          object GridTviewBANKAADI: TcxGridDBColumn
            Caption = 'Banka Ad'#305
            DataBinding.FieldName = 'BANKAADI'
            DataBinding.IsNullValueType = True
            Width = 88
          end
          object GridTviewODEMEYERI: TcxGridDBColumn
            Caption = #214'deme Yeri'
            DataBinding.FieldName = 'ODEMEYERI'
            DataBinding.IsNullValueType = True
            Width = 110
          end
          object GridTviewREHBERID: TcxGridDBColumn
            DataBinding.FieldName = 'REHBERID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridTviewSUBEID: TcxGridDBColumn
            Caption = #350'ube'
            DataBinding.FieldName = 'SUBEID'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepSubelerKendiSubesi
          end
          object GridTviewSONISLEM: TcxGridDBColumn
            Caption = 'Son '#304#351'lem'
            DataBinding.FieldName = 'SONISLEM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleriReadOnly
          end
          object GridTviewSONISLEMYERI: TcxGridDBColumn
            Caption = 'Son '#304#351'lem Yeri'
            DataBinding.FieldName = 'SONISLEMYERI'
            DataBinding.IsNullValueType = True
            Width = 99
          end
          object GridTviewBANKAHESAPKODU: TcxGridDBColumn
            Caption = 'Banka Hs.Kodu'
            DataBinding.FieldName = 'BANKAHESAPKODU'
            DataBinding.IsNullValueType = True
          end
          object GridTviewBANKAHESAPNO: TcxGridDBColumn
            Caption = 'Banka Hs.No'
            DataBinding.FieldName = 'BANKAHESAPNO'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridTview
        end
      end
    end
    object SheetHesapListe: TcxTabSheet
      Caption = #199'ek Hesaplar'#305
      ImageIndex = 34
      object cxGrid2: TcxGrid
        Left = 0
        Top = 0
        Width = 1073
        Height = 214
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView1: TcxGridDBTableView
          OnDblClick = DegisTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridTviewCanFocusRecord
          DataController.DataSource = DtsCekHesaplari
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
          OptionsSelection.HideFocusRectOnExit = False
          OptionsView.Indicator = True
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
          object cxGridDBColumn1: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 70
          end
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 114
          end
          object GridTviewSUBEKODU: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 91
          end
          object GridTviewBAKIYE: TcxGridDBColumn
            Caption = 'Bakiye'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Visible = False
          end
          object GridTviewSUBEADI: TcxGridDBColumn
            Caption = 'Yerel Kur'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 96
          end
          object GridTviewIBAN: TcxGridDBColumn
            Caption = 'Yerel Tutar'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 125
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Yerel Bakiye'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
            Visible = False
            Width = 104
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 87
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
  end
  object DtsCekler: TDataSource
    DataSet = TabCekler
    Left = 82
    Top = 198
  end
  object TabCekler: TFDQuery
    AfterOpen = TabCeklerAfterOpen
    AfterScroll = TabCeklerAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT C.ID,C.KOD,C.TUTAR,C.KUR, C.TUR,C.DURUM,MAKBUZNO=CH.BELGE' +
        'NO,C.CIROLU,C.ODEMEYERI,C.HESAPNO,C.SERINO,'
      
        'C.DOVIZ_TUTARI,C.DOVIZ_KURU,C.BORCLU,C.IBAN,C.VKNO,C.BASKASININ,' +
        'C.BORCLU, C.VADE, '
      'CARIKOD = R1.KOD, CARIUNVAN=R1.FIRMA,C.HESAPID,C.REHBERID,'
      'C.HESAPNO, B.BANKAADI, BS.SUBEADI,SONISLEM=CH.ISLEM, C.CEKSENET,'
      
        'SONISLEMYERI=case when isnull(R2.FIRMA,'#39'-'#39')<>'#39'-'#39' then R2.FIRMA e' +
        'lse BHSON.HESAPADI end,'
      
        'CH.BELGENO,ISLEMTARIH=CH.TARIH, BANKAHESAPKODU = BH2.HESAPKODU, ' +
        'BANKAHESAPNO = BH2.HESAPNO, BH2.BANKASUBELERID,C.MASRAFID'
      ''
      'FROM CEKLER C'
      
        '  inner join CEKHAREKET CH on CH.ID=(select top 1 CH1.ID from CE' +
        'KHAREKET CH1 where CH1.CEKSENETLERID=C.ID order by CH1.TARIH des' +
        'c)'
      '  left outer join REHBER R1 ON C.REHBERID=R1.ID'
      '  left outer join BANKASUBELER BS ON BS.ID = C.BANKASUBELERID'
      '  left outer join BANKALAR B ON B.BANKAKODU = BS.BANKAKODU'
      '  left outer join REHBER R2 on CH.REHBERID=R2.ID'
      
        '  left outer join BANKAHESAPLAR BHSON on CH.BANKAHESAPLARID=BHSO' +
        'N.ID'
      '  left outer join BANKAHESAPLAR BH2 on C.HESAPID=BH2.ID')
    Left = 81
    Top = 152
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 24
    Top = 152
  end
  object TabCekHareketler: TFDQuery
    AfterScroll = TabCekHareketlerAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select CH.*,'
      'ISLEMYERI=case when isnull(R.FIRMA,'#39'-'#39') <>'#39'-'#39' then R.FIRMA '
      
        #9#9#9'when isnull(K.KASAADI,'#39'-'#39') <>'#39'-'#39' then K.KASAADI else BH.HESAP' +
        'ADI end,'
      'R.FIRMA,BH.HESAPADI '
      'from CEKHAREKET CH'
      'left outer join REHBER R on CH.REHBERID=R.ID'
      'left outer join BANKAHESAPLAR BH on CH.BANKAHESAPLARID=BH.ID'
      'left outer join KASALAR K on CH.BANKAHESAPLARID=K.ID'
      'where CH.CEKSENETLERID=:PCSID'
      'order by CH.TARIH')
    Left = 174
    Top = 144
    ParamData = <
      item
        Name = 'PCSID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 931
      end>
  end
  object DtsCekHareketler: TDataSource
    DataSet = TabCekHareketler
    Left = 185
    Top = 193
  end
  object PopupAlinanCekler: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupAlinanCeklerPopup
    Left = 480
    Top = 128
    object CekInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = CekInfoMenuClick
    end
    object NInfoA: TMenuItem
      Caption = '-'
    end
    object Portfyde2: TMenuItem
      Tag = 130
      Caption = 'Portf'#246'ye Al'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object Cirola2: TMenuItem
      Tag = 131
      Caption = 'Cirola'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object TeminataVer2: TMenuItem
      Tag = 132
      Caption = 'Teminata Ver'
      ImageIndex = 15
      object Bankaya1: TMenuItem
        Tag = 138
        Caption = 'Bankaya'
        ImageIndex = 15
        OnClick = CekIslemleriClick
      end
      object Cariye1: TMenuItem
        Tag = 132
        Caption = 'Cariye'
        ImageIndex = 35
        OnClick = CekIslemleriClick
      end
    end
    object TakasaVer2: TMenuItem
      Tag = 133
      Caption = 'Takasa Ver'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object IcrayaVer2: TMenuItem
      Tag = 134
      Caption = #304'craya Ver'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object Karsiliksiz2: TMenuItem
      Tag = 135
      Caption = 'Kar'#351#305'l'#305'ks'#305'z '#304#351'aretle'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object TahsilEt2: TMenuItem
      Tag = 136
      Caption = 'Tahsil Et'
      ImageIndex = 34
      OnClick = CekIslemleriClick
    end
    object IadeEt2: TMenuItem
      Tag = 137
      Caption = #304'ade Et'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object CekiKopyalaMenu: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = CekiKopyalaMenuClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object ExceldenAlinanCekImport: TMenuItem
      Tag = 130
      Caption = 'Excelden Veri Al'
      ImageIndex = 32
      OnClick = ExceldenAlinanCekImportClick
    end
  end
  object PopupVerilenCekler: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 480
    Top = 184
    object CekInfoMenuV: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = CekInfoMenuClick
    end
    object NInfoV: TMenuItem
      Caption = '-'
    end
    object SatcyaVer3: TMenuItem
      Tag = 140
      Caption = 'Sat'#305'c'#305'ya Ver'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object IadeAl3: TMenuItem
      Tag = 141
      Caption = #304'ade Al'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object IptalEt3: TMenuItem
      Tag = 142
      Caption = #304'ptal Et'
      ImageIndex = 15
      OnClick = CekIslemleriClick
    end
    object OdesiniYap3: TMenuItem
      Tag = 143
      Caption = #214'demesini Yap'
      ImageIndex = 34
      OnClick = CekIslemleriClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object CekiKopyalaVerilen: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = CekiKopyalaMenuClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object ExceldenVerilenCekImport: TMenuItem
      Tag = 140
      Caption = 'Excelden Veri al'
      ImageIndex = 32
      OnClick = ExceldenAlinanCekImportClick
    end
  end
  object PopupCekHareket: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 304
    Top = 256
    object arihDeitir1: TMenuItem
      Caption = 'Tarih/Makbuz No/A'#231#305'klama'
      ImageIndex = 21
      OnClick = arihDeitir1Click
    end
    object lemYeriSe1: TMenuItem
      Caption = #304#351'lem Yeri'
      ImageIndex = 15
      OnClick = lemYeriSe1Click
    end
    object HareketiSil1: TMenuItem
      Caption = 'Hareketi Sil'
      ImageIndex = 1
      OnClick = HareketiSil1Click
    end
  end
  object DtsCekHesaplari: TDataSource
    DataSet = TabCekHesaplari
    Left = 265
    Top = 185
  end
  object TabCekHesaplari: TFDQuery
    AfterScroll = TabCekHesaplariAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * '
      'from HESAPPLANI '
      'where HESAPKODU like :prm1 or HESAPKODU like :prm2'
      'order by HESAPKODU')
    Left = 270
    Top = 136
    ParamData = <
      item
        Name = 'prm1'
        DataType = ftWideString
        Precision = 255
        NumericScale = 255
        Size = 20
        Value = Null
      end
      item
        Name = 'prm2'
        DataType = ftWideString
        Precision = 255
        NumericScale = 255
        Size = 20
        Value = Null
      end>
  end
  object TabCekHesapEkstre: TFDQuery
    AfterScroll = TabCekHesapEkstreAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'EXEC Sp_Prg_CekEkstre @Kod=:PKod, @BasTar=:PBasTar, @BitTar=:PBi' +
        'tTar')
    Left = 342
    Top = 152
    ParamData = <
      item
        Name = 'PKod'
        Size = -1
        Value = Null
      end
      item
        Name = 'PBasTar'
        Size = -1
        Value = Null
      end
      item
        Name = 'PBitTar'
        Size = -1
        Value = Null
      end>
  end
  object DtsCekHesapEkstre: TDataSource
    DataSet = TabCekHesapEkstre
    Left = 337
    Top = 201
  end
  object AksiyonlarMenu: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 483
    Top = 245
    object KurFarkGeliri1: TMenuItem
      Tag = 88
      Caption = 'Kur Fark'#305' Geliri'
      ImageIndex = 34
      OnClick = KurFarkGeliri1Click
    end
    object KurFarkGideri1: TMenuItem
      Tag = 98
      Caption = 'Kur Fark'#305' Gideri'
      ImageIndex = 34
      OnClick = KurFarkGeliri1Click
    end
    object KurFarkiSil: TMenuItem
      Caption = 'Hareketi Sil'
      ImageIndex = 1
      OnClick = KurFarkiSilClick
    end
  end
  object TabSmsEPosta: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE @REHID int'
      'SET @REHID= :PRehID'
      ''
      
        'SELECT TIP='#39'E-Posta'#39',EXT=1,GONDERIMTARIHI,BELGENO='#39#39',DURUM='#39#39' ,Y' +
        'ON='#39'Giden'#39',MODUL= CASE WHEN YER='#39'12'#39' THEN '#39'Aktivite'#39' WHEN YER='#39'8' +
        '3'#39' THEN '#39'Servis'#39' END,KATEGORI='#39#39',DOKUMANADI=GIDENADRES,SURUM='#39#39',' +
        'KONUSU=MESAJKONUSU,TUR='#39#39',BOLUM='#39#39',KURUM='#39#39',ILGILI='#39#39',SORUMLU='#39#39 +
        ',BOYUT='#39#39',LOKASYON='#39#39',GECERLILIK_TARIHI='#39#39',KLASOR='#39#39',KAYNAK=EPOS' +
        'TA,ANAHTAR,YER  FROM EPOSTALAR'
      'WHERE'
      'REHID=@REHID'
      'UNION ALL'
      
        'SELECT TIP='#39'Sms'#39',EXT=2,GONDERIMTARIHI,BELGENO='#39#39',DURUM='#39#39' ,YON='#39 +
        'Giden'#39',MODUL= CASE WHEN YER='#39'12'#39' THEN '#39'Aktivite'#39' WHEN YER='#39'83'#39' T' +
        'HEN '#39'Servis'#39' END,KATEGORI='#39#39',DOKUMANADI=GSMNO,SURUM='#39#39',KONUSU=ME' +
        'SAJMETNI,TUR='#39#39',BOLUM='#39#39',KURUM='#39#39',ILGILI='#39#39',SORUMLU='#39#39',BOYUT='#39#39',' +
        'LOKASYON='#39#39',GECERLILIK_TARIHI='#39#39',KLASOR='#39#39',KAYNAK='#39#39' ,ANAHTAR,YE' +
        'R  FROM SMSLER'
      'WHERE'
      'REHID=@REHID')
    Left = 568
    Top = 440
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
  end
  object DtsSmsEPosta: TDataSource
    DataSet = TabSmsEPosta
    Left = 568
    Top = 392
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 575
    Top = 136
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
    object MenuItem1: TMenuItem
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
      object MenuItem2: TMenuItem
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
  object frxCekHesapEkstre: TfrxDBDataset
    UserName = 'HesapEkstre'
    CloseDataSource = False
    DataSet = TabCekHesapEkstre
    BCDToCurrency = False
    DataSetOptions = []
    Left = 344
    Top = 112
  end
  object frxCekHesaplari: TfrxDBDataset
    UserName = 'Hesaplar'
    CloseDataSource = False
    DataSet = TabCekHesaplari
    BCDToCurrency = False
    DataSetOptions = []
    Left = 272
    Top = 96
  end
  object frxCekHareketler: TfrxDBDataset
    UserName = 'Hareketler'
    CloseDataSource = False
    DataSet = TabCekHareketler
    BCDToCurrency = False
    DataSetOptions = []
    Left = 176
    Top = 104
  end
  object frxCekler: TfrxDBDataset
    UserName = 'Cekler'
    CloseDataSource = False
    DataSet = TabCekler
    BCDToCurrency = False
    DataSetOptions = []
    Left = 80
    Top = 104
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 579
    Top = 297
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 596
    Top = 356
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      ImageIndex = 7
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      ImageIndex = 1
      OnClick = PopupYorumuSilClick
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      ImageIndex = 37
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 43
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      ImageIndex = 1
      OnClick = DkmanSil1Click
    end
  end
  object cxGridPopupYorumlar: TcxGridPopupMenu
    Grid = GridYorum
    PopupMenus = <
      item
        GridView = GridYorumDBCardView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 768
    Top = 400
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    appearance.Gradient1Start = 15722724
    appearance.Gradient1End = 14599608
    appearance.Gradient2Start = 14203563
    appearance.Gradient2End = 15722724
    appearance.MarginX = 4
    appearance.MarginY = 2
    appearance.SeparatorLeading = 6
    appearance.GutterWidth = 26
    appearance.SeparatorBackgroundColor = 15656925
    appearance.SeparatorLineColor = 12961221
    appearance.GutterColor = 15658729
    appearance.ItemBackgroundColor = 16448250
    appearance.ItemSelectedColor = 15128011
    appearance.FontColor = 7214336
    appearance.FontDisabledColor = 14599640
    style = msDefault
    Left = 440
    Top = 364
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      OnClick = MenuTarayacidanEkleClick
    end
  end
end
