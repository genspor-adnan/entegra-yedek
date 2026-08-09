object RehberAraDlg: TRehberAraDlg
  Left = 0
  Top = 0
  Width = 1044
  Height = 552
  Align = alClient
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object CariGrid: TcxGrid
    Left = 0
    Top = 35
    Width = 1044
    Height = 250
    Align = alClient
    PopupMenu = PopupMenuREHBER
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    ExplicitTop = 32
    ExplicitHeight = 253
    object CariGridView: TcxGridDBTableView
      OnDblClick = CariGridDBTableView1DblClick
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = CariGridViewCanFocusRecord
      OnFocusedRecordChanged = CariGridViewFocusedRecordChanged
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsRehber
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          Column = CariGridViewALACAK
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          Column = CariGridViewBORC
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Position = spFooter
          Column = CariGridViewBAKIYE
          VisibleForCustomization = False
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = CariGridViewBORC
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = CariGridViewALACAK
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          Column = CariGridViewBAKIYE
        end
        item
          Format = 'Say'#305' :  ######'
          Kind = skCount
          Column = CariGridViewFIRMA1
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.CellHints = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Editing = False
      OptionsView.Footer = True
      OptionsView.GridLines = glNone
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      Styles.Content = cxStyle1
      Styles.OnGetContentStyle = CariGridViewStylesGetContentStyle
      Styles.Header = cxStyle2
      Styles.Indicator = cxStyle2
      object CariGridViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
      end
      object CariGridViewSEC: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.ValueType = 'Boolean'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
      end
      object CariGridViewSINIF: TcxGridDBColumn
        Caption = 'S'#305'n'#305'f'
        DataBinding.FieldName = 'SINIF'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepCariSinif
        Width = 76
      end
      object CariGridViewGRUP: TcxGridDBColumn
        Caption = 'Grup'
        DataBinding.FieldName = 'GRUP'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepCariGrup
        Width = 76
      end
      object CariGridViewKATEGORI: TcxGridDBColumn
        Caption = 'Kategori'
        DataBinding.FieldName = 'KATEGORI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        RepositoryItem = Tablo.RepCariKategori
        Width = 79
      end
      object CariGridViewSEKTOR: TcxGridDBColumn
        Caption = 'Sekt'#246'r'
        DataBinding.FieldName = 'SEKTOR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepCariSektor
      end
      object CariGridViewKOD1: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taLeftJustify
        Properties.ReadOnly = True
        Styles.Header = cxStyle3
        Width = 68
      end
      object CariGridViewFIRMA1: TcxGridDBColumn
        Caption = #220'nvan'
        DataBinding.FieldName = 'FIRMA'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taLeftJustify
        Properties.ReadOnly = True
        Styles.Header = cxStyle4
        Width = 145
      end
      object CariGridViewFATBASLIK: TcxGridDBColumn
        Caption = 'Resmi Ad'
        DataBinding.FieldName = 'FATBASLIK'
        DataBinding.IsNullValueType = True
      end
      object CariGridViewADSOYAD: TcxGridDBColumn
        Caption = #304'lgili'
        DataBinding.FieldName = 'ADSOYAD'
        DataBinding.IsNullValueType = True
        Width = 120
      end
      object CariGridViewBOLGE: TcxGridDBColumn
        Caption = 'B'#246'lge'
        DataBinding.FieldName = 'BOLGE'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCariBolge
        Visible = False
        VisibleForCustomization = False
        Width = 119
      end
      object CariGridViewALTBOLGE: TcxGridDBColumn
        Caption = 'Alt B'#246'lge'
        DataBinding.FieldName = 'ALTBOLGE'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewADRES: TcxGridDBColumn
        Caption = 'Adres'
        DataBinding.FieldName = 'ADRES'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewILLER: TcxGridDBColumn
        Caption = #304'l'
        DataBinding.FieldName = 'ILLER'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Width = 69
      end
      object CariGridViewILCE: TcxGridDBColumn
        Caption = #304'l'#231'e'
        DataBinding.FieldName = 'ILCE'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewColumn1: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
      end
      object CariGridViewYASLANDIRMA: TcxGridDBColumn
        Caption = 'G'#252'n'
        DataBinding.FieldName = 'GUN'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DecimalPlaces = 0
        Properties.DisplayFormat = ',0;-,0'
        Properties.ReadOnly = True
        Visible = False
        BestFitMaxWidth = 50
        Options.SortByDisplayText = isbtOff
        VisibleForCustomization = False
      end
      object CariGridViewVADE: TcxGridDBColumn
        Caption = 'Vade'
        DataBinding.FieldName = 'VADE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DecimalPlaces = 0
        Properties.DisplayFormat = ',0;-,0'
        Properties.ReadOnly = True
        Visible = False
        BestFitMaxWidth = 50
        Options.SortByDisplayText = isbtOff
        VisibleForCustomization = False
        Width = 40
      end
      object CariGridViewFARK: TcxGridDBColumn
        Caption = 'Fark'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DecimalPlaces = 0
        Properties.DisplayFormat = ',0;-,0'
        Properties.ReadOnly = True
        Visible = False
        OnGetDataText = CariGridViewFARKGetDataText
        BestFitMaxWidth = 50
        Options.SortByDisplayText = isbtOn
        VisibleForCustomization = False
        Width = 40
      end
      object CariGridViewBORC: TcxGridDBColumn
        Caption = 'Bor'#231
        DataBinding.FieldName = 'TOPLAM_BORC'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Visible = False
        VisibleForCustomization = False
        Width = 80
      end
      object CariGridViewALACAK: TcxGridDBColumn
        Caption = 'Alacak'
        DataBinding.FieldName = 'TOPLAM_ALACAK'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Visible = False
        VisibleForCustomization = False
        Width = 80
      end
      object CariGridViewBAKIYE: TcxGridDBColumn
        Caption = 'Bakiye'
        DataBinding.FieldName = 'BAKIYE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
        Visible = False
        VisibleForCustomization = False
        Width = 80
      end
      object CariGridViewTAKIPTE: TcxGridDBColumn
        Caption = 'Takipte'
        DataBinding.FieldName = 'TAKIPTE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
      end
      object CariGridViewIRSALIYE: TcxGridDBColumn
        Caption = #304'rsaliye'
        DataBinding.FieldName = 'IRSALIYE'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;-,0.00'
      end
      object CariGridViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepCariDurum
        Width = 47
      end
      object CariGridViewKUR: TcxGridDBColumn
        Caption = 'Para Birimi'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Width = 27
      end
      object CariGridViewSONAKTIVITETARIHI: TcxGridDBColumn
        Caption = 'Son '#304#351' Tarihi'
        DataBinding.FieldName = 'SONAKTIVITETARIHI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.SaveTime = False
        Visible = False
        Options.Editing = False
        VisibleForCustomization = False
        Width = 104
      end
      object CariGridViewSONSATBELGETARIHI: TcxGridDBColumn
        Caption = 'Son Sat. Belge'
        DataBinding.FieldName = 'SONSATBELGETARIHI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.ShowTime = False
        Visible = False
        VisibleForCustomization = False
        Width = 81
      end
      object CariGridViewSONSATTUTARI: TcxGridDBColumn
        Caption = 'Son Sat. Tutar'#305
        DataBinding.FieldName = 'SONSATTUTARI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;'
        Visible = False
        VisibleForCustomization = False
        Width = 100
      end
      object CariGridViewSONAKTIVITEKONUSU: TcxGridDBColumn
        Caption = 'Son '#304#351' Konusu'
        DataBinding.FieldName = 'SONAKTIVITEKONUSU'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
        Width = 130
      end
      object CariGridViewTEMSILCIAD: TcxGridDBColumn
        Caption = 'Temsilci'
        DataBinding.FieldName = 'TEMSILCIAD'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewNOTLAR: TcxGridDBColumn
        Caption = 'Notlar'
        DataBinding.FieldName = 'NOTLAR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxLabelProperties'
        Properties.ShadowedColor = clDefault
        Visible = False
        BestFitMaxWidth = 80
        VisibleForCustomization = False
      end
      object CariGridViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewYETKIKODU: TcxGridDBColumn
        Caption = 'Yetki Kodu'
        DataBinding.FieldName = 'YETKIKODU'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewMUHKODU: TcxGridDBColumn
        Caption = 'Muh.Kodu'
        DataBinding.FieldName = 'MUHKODU'
        DataBinding.IsNullValueType = True
        Visible = False
        VisibleForCustomization = False
      end
      object CariGridViewALTSEKTOR: TcxGridDBColumn
        Caption = 'Alt Sekt'#246'r'
        DataBinding.FieldName = 'ALTSEKTOR'
        DataBinding.IsNullValueType = True
        Visible = False
      end
    end
    object CariGridLevel1: TcxGridLevel
      GridView = CariGridView
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1038
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 126
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
    Wrapable = False
    ExplicitHeight = 29
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      AutoSize = True
      Caption = 'Yeni       '
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object ToolButton13: TToolButton
      Left = 81
      Top = 0
      Width = 8
      Caption = 'ToolButton13'
      ImageIndex = 3
      ImageName = 'PngImage18'
      Style = tbsSeparator
    end
    object SilTus: TToolButton
      Left = 89
      Top = 0
      AutoSize = True
      Caption = 'Sil         '
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton9: TToolButton
      Left = 165
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
    object DegisTus: TToolButton
      Left = 173
      Top = 0
      AutoSize = True
      Caption = 'D'#252'zenle       '
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsTextButton
      OnClick = DegisTusClick
    end
    object ToolButton2: TToolButton
      Left = 272
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 280
      Top = 0
      AutoSize = True
      Caption = 'Yazd'#305'r       '
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
      Style = tbsTextButton
    end
    object ToolButton3: TToolButton
      Left = 372
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      ImageName = 'PngImage3'
      Style = tbsSeparator
    end
    object BtnCRM: TToolButton
      Left = 380
      Top = 0
      AutoSize = True
      Caption = 'CRM              '
      ImageIndex = 40
      ImageName = 'PngImage40'
      OnClick = BtnCRMClick
    end
    object ToolButton4: TToolButton
      Left = 482
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 3
      ImageName = 'PngImage18'
      Style = tbsSeparator
    end
    object AksiyonEkleTus: TToolButton
      Left = 490
      Top = 0
      AutoSize = True
      Caption = 'Aksiyon      '
      DropdownMenu = PopupMenuYeni
      ImageIndex = 1
      ImageName = 'PngImage0'
      PopupMenu = GorevlerMenu
      Style = tbsTextButton
    end
    object ToolButton11: TToolButton
      Left = 585
      Top = 0
      Width = 8
      Caption = 'ToolButton11'
      ImageIndex = 3
      ImageName = 'PngImage18'
      Style = tbsSeparator
    end
    object buttonSocialMedya: TToolButton
      Left = 593
      Top = 0
      AutoSize = True
      Caption = 'Potansiyel M'#252#351'teri'
      ImageIndex = 44
      ImageName = 'PngImage44'
    end
  end
  object SQLMemo: TcxMemo
    Left = 185
    Top = 131
    Lines.Strings = (
      'DECLARE @ILGILIARAMA INT'
      ''
      'SET @ILGILIARAMA = :P1'
      ''
      'select <Param> from '
      '    REHBER R '
      '          left outer join REHBER P on R.ID = P.BAGID and  '
      '          1 = CASE WHEN  @ILGILIARAMA = 1 THEN 1'
      #9#9#9#9'   WHEN  @ILGILIARAMA = 0 AND isnull (P.STATU,1) = 1 THEN 1 '
      #9#9'       ELSE 0 END '
      '')
    Properties.WordWrap = False
    TabOrder = 2
    Visible = False
    Height = 59
    Width = 556
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 285
    Width = 1044
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = PageControlSekme
  end
  object PageControlSekme: TcxPageControl
    Left = 0
    Top = 293
    Width = 1044
    Height = 259
    Align = alBottom
    TabOrder = 4
    Properties.ActivePage = TabSheetIlet
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlSekmeChange
    ClientRectBottom = 255
    ClientRectLeft = 4
    ClientRectRight = 1040
    ClientRectTop = 27
    object TabSheetIlet: TcxTabSheet
      Caption = #304'leti'#351'im'
      ImageIndex = 7
      object ToolBar10: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1030
        Height = 41
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 39
        ButtonWidth = 46
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
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object iletisimEkle: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = iletisimEkleClick
        end
        object iletisimSil: TToolButton
          Left = 46
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = iletisimSilClick
        end
        object ToolButton14: TToolButton
          Left = 92
          Top = 0
          Width = 8
          Caption = 'ToolButton14'
          ImageIndex = 10
          ImageName = 'PngImage10'
          Style = tbsSeparator
        end
        object iletisimDuzenle: TToolButton
          Left = 100
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = iletisimDuzenleClick
        end
      end
      object cxGrid7: TcxGrid
        Left = 160
        Top = 44
        Width = 691
        Height = 184
        Align = alClient
        BevelEdges = []
        BevelInner = bvNone
        BevelOuter = bvNone
        TabOrder = 2
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView5: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsFirIletisim
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Header = False
          Styles.Background = cxStyle2
          Styles.Content = cxStyle2
          Styles.Header = cxStyle2
          Styles.Inactive = cxStyle2
          object cxGridDBColumn10: TcxGridDBColumn
            Caption = 'T'#252'r'#252
            DataBinding.FieldName = 'ETIKET'
            DataBinding.IsNullValueType = True
            MinWidth = 100
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Options.ShowCaption = False
            Options.Sorting = False
            Width = 100
          end
          object cxGridDBColumn11: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            MinWidth = 470
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Options.ShowCaption = False
            Options.Sorting = False
            Width = 470
          end
        end
        object cxGridLevel12: TcxGridLevel
          GridView = cxGridDBTableView5
        end
      end
      object GridRehberIletisim: TcxGrid
        Left = 0
        Top = 44
        Width = 160
        Height = 184
        Align = alLeft
        PopupMenu = PopupIletisim
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridRehberIletisimView: TcxGridDBTableView
          OnDblClick = iletisimDuzenleClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnSelectionChanged = GridRehberIletisimViewSelectionChanged
          DataController.DataSource = DtsRehberIletisim
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.GroupByBox = False
          Styles.Background = cxStyle2
          Styles.Content = cxStyle2
          Styles.Inactive = cxStyle2
          object cxGridDBColumn1: TcxGridDBColumn
            Caption = 'Var.'
            DataBinding.FieldName = 'VARSAYILAN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ReadOnly = True
            Visible = False
            Options.Editing = False
            Width = 30
          end
          object cxGridDBColumn2: TcxGridDBColumn
            Caption = 'Ad'#305
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 119
          end
          object cxGridDBColumn12: TcxGridDBColumn
            DataBinding.FieldName = 'AKTIF'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Kurumda'
                Value = '1'
              end
              item
                Description = 'Ta'#351#305'nd'#305
                ImageIndex = 12
                Value = '2'
              end
              item
                Description = 'Ayr'#305'ld'#305
                ImageIndex = 10
                Value = '3'
              end>
            Properties.ShowDescriptions = False
            Width = 32
            IsCaptionAssigned = True
          end
        end
        object cxGridLevel13: TcxGridLevel
          GridView = GridRehberIletisimView
        end
      end
      object PanelFiyatAltSag: TPanel
        Left = 851
        Top = 44
        Width = 185
        Height = 184
        Align = alRight
        Caption = 'PanelFiyatAltSag'
        TabOrder = 3
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 177
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 75
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
          object ResimYapistirTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yap'#305#351't'#305'r'
            ImageIndex = 10
            ImageName = 'PngImage10'
            OnClick = ResimYapistirTusClick
          end
          object ToolButton8: TToolButton
            Left = 75
            Top = 0
            Width = 8
            Caption = 'ToolButton6'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object ResimDosyadanTus: TToolButton
            Left = 83
            Top = 0
            Caption = 'Dosyadan'
            ImageIndex = 4
            ImageName = 'PngImage4'
            OnClick = ResimDosyadanTusClick
          end
        end
        object LogoResim: TcxDBImage
          Left = 1
          Top = 28
          HelpType = htKeyword
          Align = alClient
          DataBinding.DataField = 'RESIM'
          DataBinding.DataSource = DtsResim
          Properties.Caption = 'Resim s'#252'r'#252'kleyip buraya b'#305'rak'#305'n'
          Properties.GraphicClassName = 'TdxSmartImage'
          Style.BorderColor = clBtnFace
          Style.Color = clBtnFace
          Style.Edges = []
          StyleDisabled.BorderStyle = ebsNone
          StyleFocused.BorderStyle = ebsNone
          TabOrder = 1
          OnClick = LogoResimClick
          Height = 155
          Width = 183
        end
      end
    end
    object TabSheetIlgili: TcxTabSheet
      Caption = #304'lgililer'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ImageIndex = 6
      ParentFont = False
      PopupMenu = PopupIlgililer
      object cxGrid2: TcxGrid
        Left = 0
        Top = 41
        Width = 459
        Height = 187
        Align = alLeft
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridPersoneller: TcxGridDBTableView
          OnDblClick = IlgiliDuzenleTusClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnSelectionChanged = cxGridPersonellerSelectionChanged
          DataController.DataSource = DtsRehberIlgili
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.ScrollBars = ssVertical
          OptionsView.ColumnAutoWidth = True
          OptionsView.GridLines = glHorizontal
          OptionsView.GroupByBox = False
          Styles.Background = cxStyle2
          Styles.Content = cxStyle2
          Styles.Inactive = cxStyle2
          object PersonelVARSAYILAN: TcxGridDBColumn
            Caption = 'Var.'
            DataBinding.FieldName = 'STATU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ReadOnly = True
            Visible = False
            Options.Editing = False
            Width = 30
          end
          object PersonelAdi: TcxGridDBColumn
            Caption = 'Ad'#305' Soyad'#305
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 150
          end
          object cxGridPersonellerColumn1: TcxGridDBColumn
            Caption = 'G'#246'revi'
            DataBinding.FieldName = 'GOREVI'
            DataBinding.IsNullValueType = True
            Width = 100
          end
          object PersonelLOKASYON: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'ILETISIMI'
            DataBinding.IsNullValueType = True
            Width = 100
          end
          object PersonelNEREDE: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.PNGImageList2
            Properties.Items = <
              item
                Description = 'Kurumda'
                Value = 1
              end
              item
                Description = 'Ta'#351#305'nd'#305
                ImageIndex = 26
                Value = 2
              end
              item
                Description = 'Ayr'#305'ld'#305
                ImageIndex = 24
                Value = 3
              end
              item
                Description = #350'ifresi Var'
                ImageIndex = 29
                Value = 99
              end>
            Properties.ShowDescriptions = False
            Width = 32
            IsCaptionAssigned = True
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGridPersoneller
        end
      end
      object Panel2: TPanel
        Left = 459
        Top = 41
        Width = 577
        Height = 187
        Align = alClient
        TabOrder = 1
        object GridPerIlet: TcxGrid
          Left = 1
          Top = 25
          Width = 352
          Height = 161
          Align = alLeft
          BevelEdges = []
          BevelInner = bvNone
          BevelOuter = bvNone
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridPerIletView: TcxGridDBTableView
            OnDblClick = IlgiliDuzenleTusClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsPerIletisim
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsView.GridLines = glNone
            OptionsView.GroupByBox = False
            OptionsView.Header = False
            Styles.Background = cxStyle2
            Styles.Content = cxStyle2
            Styles.Header = cxStyle2
            Styles.Inactive = cxStyle2
            object GridPerIletViewTUR: TcxGridDBColumn
              Caption = 'T'#252'r'#252
              DataBinding.FieldName = 'ETIKET'
              DataBinding.IsNullValueType = True
              MinWidth = 150
              Options.Editing = False
              Options.Filtering = False
              Options.Focusing = False
              Options.IgnoreTimeForFiltering = False
              Options.IncSearch = False
              Options.FilteringFilteredItemsList = False
              Options.FilteringMRUItemsList = False
              Options.FilteringPopup = False
              Options.FilteringPopupMultiSelect = False
              Options.GroupFooters = False
              Options.Grouping = False
              Options.HorzSizing = False
              Options.Moving = False
              Options.ShowCaption = False
              Options.Sorting = False
              Width = 150
            end
            object GridPerIletViewBILGI: TcxGridDBColumn
              Caption = 'Bilgisi'
              DataBinding.FieldName = 'BILGI'
              DataBinding.IsNullValueType = True
              MinWidth = 200
              Options.Editing = False
              Options.Filtering = False
              Options.Focusing = False
              Options.IgnoreTimeForFiltering = False
              Options.IncSearch = False
              Options.FilteringFilteredItemsList = False
              Options.FilteringMRUItemsList = False
              Options.FilteringPopup = False
              Options.FilteringPopupMultiSelect = False
              Options.GroupFooters = False
              Options.Grouping = False
              Options.HorzSizing = False
              Options.Moving = False
              Options.ShowCaption = False
              Options.Sorting = False
              Width = 200
            end
          end
          object cxGridLevel3: TcxGridLevel
            GridView = GridPerIletView
          end
        end
        object Panel3: TPanel
          Left = 1
          Top = 1
          Width = 575
          Height = 24
          Align = alTop
          TabOrder = 0
          object cxLabel5: TcxLabel
            Left = 3
            Top = 1
            Caption = #304'leti'#351'im Bilgileri'
            Transparent = True
          end
          object cxLabel1: TcxLabel
            Left = 350
            Top = 1
            Caption = 'Resimleri'
            Transparent = True
          end
          object ResimDuzenleTus: TcxButton
            Left = 410
            Top = 0
            Width = 75
            Height = 22
            Caption = 'D'#252'zenle'
            TabOrder = 0
            OnClick = ResimDuzenleTusClick
          end
        end
        object Resim: TcxImage
          Left = 353
          Top = 25
          Align = alClient
          Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
          Properties.Center = False
          Properties.ReadOnly = True
          Style.Color = clBtnFace
          Style.Edges = []
          TabOrder = 2
          Height = 161
          Width = 223
        end
      end
      object Panel9: TPanel
        Left = 0
        Top = 0
        Width = 1036
        Height = 41
        Align = alTop
        Caption = 'Panel9'
        TabOrder = 2
        object ToolBar2: TToolBar
          Left = 1
          Top = 1
          Width = 146
          Height = 39
          Margins.Bottom = 0
          Align = alLeft
          AutoSize = True
          ButtonHeight = 39
          ButtonWidth = 46
          Caption = 'AletCubugu'
          Color = clTeal
          Ctl3D = False
          DockSite = True
          DrawingStyle = dsGradient
          EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
          EdgeInner = esNone
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
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object IlgiliEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = IlgiliEkleTusClick
          end
          object IlgiliSilTus: TToolButton
            Left = 46
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = IlgiliSilTusClick
          end
          object ToolButton6: TToolButton
            Left = 92
            Top = 0
            Width = 8
            Caption = 'ToolButton6'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object IlgiliDuzenleTus: TToolButton
            Left = 100
            Top = 0
            Caption = 'D'#252'zenle'
            ImageIndex = 7
            ImageName = 'PngImage7'
            OnClick = IlgiliDuzenleTusClick
          end
        end
        object JvNavPanelHeader5: TJvNavPanelHeader
          Left = 147
          Top = 1
          Width = 888
          Height = 39
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
          object IlgiliAraEdit: TcxTextEdit
            Left = 80
            Top = 8
            ParentFont = False
            Properties.OnChange = IlgiliAraEditPropertiesChange
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -16
            Style.Font.Name = 'Arial'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            TabOrder = 0
            Width = 143
          end
          object cxLabel3: TcxLabel
            Left = 21
            Top = 9
            Caption = 'Ara'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
        end
      end
    end
    object TabSheetTicari: TcxTabSheet
      Caption = 'Ticari Bilgiler'
      ImageIndex = 9
      object cxPageControl1: TcxPageControl
        Left = 0
        Top = 0
        Width = 1036
        Height = 228
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = cxTabSheet1
        Properties.CustomButtons.Buttons = <>
        Properties.Style = 8
        ClientRectBottom = 228
        ClientRectRight = 1036
        ClientRectTop = 22
        object cxTabSheet1: TcxTabSheet
          Caption = 'Temel Bilgiler'
          ImageIndex = 0
          object ToolBar7: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1030
            Height = 41
            Margins.Bottom = 0
            AutoSize = True
            ButtonHeight = 39
            ButtonWidth = 79
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
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            Transparent = True
            object TicariDuzenleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni / D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsTextButton
              OnClick = TicariDuzenleTusClick
            end
            object ToolButton5: TToolButton
              Left = 79
              Top = 0
              Width = 8
              Caption = 'ToolButton5'
              ImageIndex = 8
              ImageName = 'PngImage15'
              Style = tbsSeparator
            end
            object IskontoTus: TToolButton
              Left = 87
              Top = 0
              Caption = #304'skonto'
              ImageIndex = 20
              ImageName = 'PngImage20'
              OnClick = IskontoTusClick
            end
            object BtnKota: TToolButton
              Left = 166
              Top = 0
              Caption = 'Risk Limiti'
              ImageIndex = 29
              ImageName = 'PngImage29'
              OnClick = BtnKotaClick
            end
          end
          object GridTicari: TcxGrid
            Left = 0
            Top = 44
            Width = 1036
            Height = 162
            Align = alClient
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridTicariView: TcxGridDBTableView
              OnDblClick = TicariDuzenleTusClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsTicari
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GridLines = glNone
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              Styles.Background = cxStyle2
              Styles.Content = cxStyle2
              Styles.Header = cxStyle2
              Styles.Inactive = cxStyle2
              object cxGridDBColumn3: TcxGridDBColumn
                Caption = 'T'#252'r'#252
                DataBinding.FieldName = 'ETIKET'
                DataBinding.IsNullValueType = True
                MinWidth = 150
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Options.Sorting = False
                Width = 150
              end
              object cxGridDBColumn4: TcxGridDBColumn
                Caption = 'Bilgisi'
                DataBinding.FieldName = 'BILGI'
                DataBinding.IsNullValueType = True
                MinWidth = 250
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Options.Sorting = False
                Width = 250
              end
            end
            object cxGridLevel5: TcxGridLevel
              GridView = GridTicariView
            end
          end
        end
        object TabSheetEBelge: TcxTabSheet
          Caption = 'E-Belge Bilgileri'
          ImageIndex = 2
          object ToolBar13: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1030
            Height = 41
            Margins.Bottom = 0
            AutoSize = True
            ButtonHeight = 39
            ButtonWidth = 46
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
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            Transparent = True
            object ToolButton17: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = BankaEkleTusClick
            end
            object ToolButton19: TToolButton
              Left = 46
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = BankaSilTusClick
            end
            object ToolButton20: TToolButton
              Left = 92
              Top = 0
              Width = 8
              Caption = 'ToolButton10'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsSeparator
            end
            object ToolButton21: TToolButton
              Left = 100
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsTextButton
              OnClick = BankaDuzenleTusClick
            end
            object ToolButton22: TToolButton
              Left = 146
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = BtnKaydetBHClick
            end
            object ToolButton23: TToolButton
              Left = 192
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = BtnIptalBHClick
            end
            object cxLabel7: TcxLabel
              Left = 238
              Top = 0
              Align = alClient
              Caption = '        Kurum Alias Bilgisi '
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -16
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.LookAndFeel.Kind = lfFlat
              Style.LookAndFeel.NativeStyle = True
              Style.TransparentBorder = False
              Style.IsFontAssigned = True
              StyleDisabled.LookAndFeel.Kind = lfFlat
              StyleDisabled.LookAndFeel.NativeStyle = True
              StyleFocused.LookAndFeel.Kind = lfFlat
              StyleFocused.LookAndFeel.NativeStyle = True
              StyleHot.LookAndFeel.Kind = lfFlat
              StyleHot.LookAndFeel.NativeStyle = True
              Transparent = True
            end
          end
          object GridAlias: TcxGrid
            Left = 0
            Top = 44
            Width = 1036
            Height = 121
            Align = alClient
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridAliasView: TcxGridDBTableView
              OnDblClick = BankaDuzenleTusClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridBankaDBTableView1CanFocusRecord
              DataController.DataSource = DtsAlias
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              Styles.Content = cxStyle1
              Styles.Header = cxStyle2
              Styles.Indicator = cxStyle2
              object GridAliasViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                PropertiesClassName = 'TcxTextEditProperties'
              end
              object GridAliasViewREHBERID: TcxGridDBColumn
                DataBinding.FieldName = 'REHBERID'
                Visible = False
              end
              object GridAliasViewBELGETURU: TcxGridDBColumn
                Caption = 'Belge'
                DataBinding.FieldName = 'BELGETURU'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'E-'#304'rsaliye G'#304'B'
                    ImageIndex = 0
                    Value = 140
                  end
                  item
                    Description = 'E-'#304'rsaliye Kendi'
                    Value = 141
                  end
                  item
                    Description = 'E-Ar'#351'iv Fatura'
                    Value = 150
                  end
                  item
                    Description = 'E-Fatura'
                    Value = 151
                  end>
              end
              object GridAliasViewALIAS: TcxGridDBColumn
                Caption = 'Alias'
                DataBinding.FieldName = 'ALIAS'
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 250
              end
              object GridAliasViewVARSAYILAN: TcxGridDBColumn
                Caption = 'Varsay'#305'lan'
                DataBinding.FieldName = 'VARSAYILAN'
              end
              object GridAliasViewAKTIF: TcxGridDBColumn
                Caption = 'Aktif'
                DataBinding.FieldName = 'AKTIF'
              end
              object GridAliasViewILKKAYITTARIHI: TcxGridDBColumn
                Caption = #304'lk Kay'#305't'
                DataBinding.FieldName = 'ILKKAYITTARIHI'
                PropertiesClassName = 'TcxDateEditProperties'
                Properties.ReadOnly = True
                Width = 125
              end
              object GridAliasViewSONKONTROLTARIHI: TcxGridDBColumn
                Caption = 'Son Kontrol'
                DataBinding.FieldName = 'SONKONTROLTARIHI'
                PropertiesClassName = 'TcxDateEditProperties'
                Properties.ReadOnly = True
                Width = 121
              end
              object GridAliasViewPASIFTARIHI: TcxGridDBColumn
                Caption = 'Pasif'
                DataBinding.FieldName = 'PASIFTARIHI'
                PropertiesClassName = 'TcxDateEditProperties'
                Properties.ReadOnly = True
                Width = 128
              end
            end
            object cxGridLevel4: TcxGridLevel
              GridView = GridAliasView
            end
          end
          object Panel10: TPanel
            Left = 0
            Top = 165
            Width = 1036
            Height = 41
            Align = alBottom
            TabOrder = 2
            object cxLabel2: TcxLabel
              Left = 16
              Top = 8
              Caption = 'E-Fatura XSLT'
            end
            object EditEFaturaXSLT: TcxButtonEdit
              Left = 92
              Top = 6
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Hint = 'Temizle'
                  Kind = bkText
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = EditEFaturaXSLTPropertiesButtonClick
              TabOrder = 1
              Width = 121
            end
            object EditEArsivXSLT: TcxButtonEdit
              Left = 290
              Top = 6
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Hint = 'Temizle'
                  Kind = bkText
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = EditEArsivXSLTPropertiesButtonClick
              TabOrder = 2
              Width = 121
            end
            object cxLabel4: TcxLabel
              Left = 216
              Top = 8
              Caption = 'E-Ar'#351'iv XSLT'
            end
            object EditEIrsaliyeXSLT: TcxButtonEdit
              Left = 499
              Top = 6
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Hint = 'Temizle'
                  Kind = bkText
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = EditEIrsaliyeXSLTPropertiesButtonClick
              TabOrder = 4
              Width = 121
            end
            object cxLabel6: TcxLabel
              Left = 416
              Top = 8
              Caption = 'E-'#304'rsaliye XSLT'
            end
            object ButtonFaturaDipNotu: TcxButton
              Left = 678
              Top = 6
              Width = 147
              Height = 25
              Caption = 'Fatura Dip Notu'
              TabOrder = 6
              OnClick = ButtonFaturaDipNotuClick
            end
          end
        end
        object cxTabSheet3: TcxTabSheet
          Caption = 'Banka Bilgileri'
          ImageIndex = 1
          object ToolBar3: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1030
            Height = 41
            Margins.Bottom = 0
            AutoSize = True
            ButtonHeight = 39
            ButtonWidth = 46
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
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            Transparent = True
            object BankaEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = BankaEkleTusClick
            end
            object BankaSilTus: TToolButton
              Left = 46
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = BankaSilTusClick
            end
            object ToolButton10: TToolButton
              Left = 92
              Top = 0
              Width = 8
              Caption = 'ToolButton10'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsSeparator
            end
            object BankaDuzenleTus: TToolButton
              Left = 100
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsTextButton
              OnClick = BankaDuzenleTusClick
            end
            object BtnKaydetBH: TToolButton
              Left = 146
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = BtnKaydetBHClick
            end
            object BtnIptalBH: TToolButton
              Left = 192
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = BtnIptalBHClick
            end
          end
          object GridBanka: TcxGrid
            Left = 0
            Top = 44
            Width = 1036
            Height = 162
            Align = alClient
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridBankaDBTableView1: TcxGridDBTableView
              OnDblClick = BankaDuzenleTusClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridBankaDBTableView1CanFocusRecord
              DataController.DataSource = DtsBankaHesaplar
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              Styles.Content = cxStyle1
              Styles.Header = cxStyle2
              Styles.Indicator = cxStyle2
              object GridBankaDBTableView1VARSAYILAN: TcxGridDBColumn
                Caption = 'Var.'
                DataBinding.FieldName = 'VARSAYILAN'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
                Width = 29
              end
              object GridBankaDBTableView1BANKAADI: TcxGridDBColumn
                Caption = 'Banka'
                DataBinding.FieldName = 'BANKAADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 80
              end
              object GridBankaDBTableView1SUBEKODU: TcxGridDBColumn
                Caption = #350'ube No'
                DataBinding.FieldName = 'SUBEKODU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 54
              end
              object GridBankaDBTableView1SUBEADI: TcxGridDBColumn
                Caption = #350'ube'
                DataBinding.FieldName = 'SUBEADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 71
              end
              object GridBankaDBTableView1HESAPNO1: TcxGridDBColumn
                Caption = 'Hesap No'
                DataBinding.FieldName = 'HESAPNO'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Width = 72
              end
              object GridBankaDBTableView1KUR: TcxGridDBColumn
                Caption = 'P.Birimi'
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxComboBoxProperties'
                Properties.DropDownListStyle = lsFixedList
                Properties.ReadOnly = True
                Width = 41
              end
              object GridBankaDBTableView1HESAPTIPI1: TcxGridDBColumn
                Caption = 'Hesap Tipi'
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
                Properties.ReadOnly = True
                Width = 67
              end
              object GridBankaDBTableView1IBAN1: TcxGridDBColumn
                DataBinding.FieldName = 'IBAN'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Width = 132
              end
              object GridBankaDBTableView1ACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Width = 86
              end
            end
            object GridBankaLevel1: TcxGridLevel
              GridView = GridBankaDBTableView1
            end
          end
        end
      end
    end
    object TabSheetCRM: TcxTabSheet
      Caption = 'CRM'
      ImageIndex = 10
      object PageControlCRM: TcxPageControl
        Left = 0
        Top = 0
        Width = 1036
        Height = 228
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = TabSheetGorev
        Properties.CustomButtons.Buttons = <>
        Properties.Style = 8
        OnChange = PageControlCRMChange
        ClientRectBottom = 228
        ClientRectRight = 1036
        ClientRectTop = 27
        object TabSheetGorev: TcxTabSheet
          Caption = #304#351' Listesi'
          ImageIndex = 10
          object TreeListGorev: TcxDBTreeList
            Left = 0
            Top = 41
            Width = 1036
            Height = 187
            Align = alClient
            Bands = <
              item
              end>
            DataController.DataSource = DtsGorevler
            DataController.ParentField = 'BAGIDUST'
            DataController.KeyField = 'ID'
            DragMode = dmAutomatic
            Images = Tablo.KlasorResimleri
            LookAndFeel.ScrollbarMode = sbmClassic
            Navigator.Buttons.CustomButtons = <>
            OptionsCustomizing.ColumnsQuickCustomization = True
            OptionsData.Editing = False
            OptionsData.Deleting = False
            OptionsSelection.MultiSelect = True
            OptionsView.GridLines = tlglBoth
            OptionsView.Indicator = True
            OptionsView.TreeLineStyle = tllsNone
            PopupMenu = GorevlerMenu
            RootValue = -1
            ScrollbarAnnotations.CustomAnnotations = <>
            TabOrder = 0
            OnClick = TreeListGorevClick
            OnDblClick = TreeListGorevDblClick
            object cxDBTreeListColumn1: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'ID'
              Width = 100
              Position.ColIndex = 7
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListACKAPA: TcxDBTreeListColumn
              Tag = 1
              PropertiesClassName = 'TcxCheckBoxProperties'
              Caption.Glyph.SourceDPI = 96
              Caption.Glyph.Data = {
                424D360400000000000036000000280000001000000010000000010020000000
                000000000000C40E0000C40E0000000000000000000000000000000000000000
                000000000002000000070000000C0000001000000012000000110000000E0000
                0008000000020000000000000000000000000000000000000000000000010000
                0004000101120D2A1D79184E36C6216B4BFF216B4BFF216C4BFF1A533AD20F2F
                218400010115000000050000000100000000000000000000000000000005050F
                0A351C5B40DC24805CFF29AC7EFF2CC592FF2DC894FF2DC693FF2AAE80FF2585
                60FF1A563DD405110C3D00000007000000010000000000000003040E0A312065
                48ED299D74FF2FC896FF2EC996FF56D4ACFF68DAB5FF3BCD9DFF30C996FF32CA
                99FF2BA479FF227050F805110C3D00000005000000000000000A1A573DD02EA5
                7CFF33CA99FF2EC896FF4CD2A8FF20835CFF00673BFF45BE96FF31CB99FF31CB
                98FF34CC9CFF31AD83FF1B5C41D300010113000000020B23185E2E8A66FF3BCD
                9EFF30CA97FF4BD3A9FF349571FF87AF9DFFB1CFC1FF238A60FF45D3A8FF36CF
                9FFF33CD9BFF3ED0A3FF319470FF0F32237F00000007184D37B63DB38CFF39CD
                9FFF4BD5A9FF43A382FF699782FFF8F1EEFFF9F3EEFF357F5DFF56C4A1FF43D5
                A8FF3ED3A4FF3CD1A4FF41BC95FF1B5C43CD0000000B1C6446DF4BCAA4FF44D2
                A8FF4FB392FF4E826AFFF0E9E6FFC0C3B5FFEFE3DDFFCEDDD4FF1B754FFF60DC
                B8FF48D8ACFF47D6AAFF51D4ACFF247A58F80000000E217050F266D9B8FF46D3
                A8FF0B6741FFD2D2CBFF6A8F77FF116B43FF73967EFFF1E8E3FF72A28BFF46A6
                85FF5EDFBAFF4CD9AFFF6BE2C2FF278460FF020604191E684ADC78D9BEFF52DA
                B1FF3DBA92FF096941FF2F9C76FF57DEB8FF2D9973FF73967EFFF0EAE7FF4F88
                6CFF5ABB9AFF5BDEB9FF7FE2C7FF27835FF80000000C19523BAB77C8B0FF62E0
                BCFF56DDB7FF59DFBAFF5CE1BDFF5EE2BEFF5FE4C1FF288C67FF698E76FFE6E1
                DCFF176B47FF5FD8B4FF83D5BDFF1E674CC60000000909201747439C7BFF95EC
                D6FF5ADFBAFF5EE2BDFF61E4BFFF64E6C1FF67E6C5FF67E8C7FF39A17EFF1F6D
                4AFF288B64FF98EFD9FF4DAC8CFF1036286D00000004000000041C5F46B578C6
                ADFF9AEED9FF65E5C0FF64E7C3FF69E7C6FF6BE8C8FF6CE9C9FF6BEAC9FF5ED6
                B6FF97EDD7FF86D3BBFF237759D20102010C0000000100000001030A0718247B
                5BDA70C1A8FFB5F2E3FF98F0DAFF85EDD4FF75EBCEFF88EFD6FF9CF2DDFFBAF4
                E7FF78CDB3FF2A906DEA0615102E00000002000000000000000000000001030A
                07171E694FB844AB87FF85D2BBFFA8E6D6FFC5F4EBFFABE9D8FF89D8C1FF4BB6
                92FF237F60CB05130E2700000003000000000000000000000000000000000000
                0001000000030A241B411B60489D258464CF2C9D77EE258867CF1F7156B00E32
                26560000000600000002000000000000000000000000}
              Caption.ShowEndEllipsis = False
              Caption.Text = '*'
              DataBinding.FieldName = 'ACKAPA'
              Options.Editing = False
              Width = 61
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListLISTEADI: TcxDBTreeListColumn
              Caption.Text = 'L'#304'STE'
              DataBinding.FieldName = 'LISTEADI'
              Options.Editing = False
              Width = 62
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListKONUSU: TcxDBTreeListColumn
              DataBinding.FieldName = 'KONUSU'
              Options.Editing = False
              Width = 139
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListTURU: TcxDBTreeListColumn
              Caption.Text = 'T'#220'R'#220
              DataBinding.FieldName = 'TURU'
              Options.Editing = False
              Width = 65
              Position.ColIndex = 3
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListATANAN1: TcxDBTreeListColumn
              Caption.Text = 'ATANAN'
              DataBinding.FieldName = 'ATANAN1'
              Options.Editing = False
              Width = 100
              Position.ColIndex = 4
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListTARIH: TcxDBTreeListColumn
              PropertiesClassName = 'TcxDateEditProperties'
              Caption.Text = 'TAR'#304'H'
              DataBinding.FieldName = 'BITISTARIHI'
              Options.Editing = False
              Width = 100
              Position.ColIndex = 5
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListNOTLAR_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 27
                  Value = True
                end>
              Caption.Glyph.SourceDPI = 96
              Caption.Glyph.Data = {
                424D360400000000000036000000280000001000000010000000010020000000
                000000000000C40E0000C40E0000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000200000
                002100000023000000240000002600000027000000290000002A0000002C0000
                002D0000002F0000003100000032000000340000000000000000000000140000
                00150000001600000017000000190000001A0000001B0000001D0000001E0000
                0020000000210000002300000024000000260000000000000000000000090000
                000A0000000B0000000C0000000E0000000F0000001000000011000000120000
                0014000000150000001600000017000000190000000000000000000000000000
                000000000000000000040000000F000000110000000B00000004000000010000
                0000000000000000000000000000000000000000000000000000402A1FFF402A
                1FFF3E291FFF0000000E421C11FF31140CE1190A0698030407420000000C0000
                0002000000000000000000000000000000000000000000000000422B20FF0000
                0000000000000000000D663C2BDCB9C7D2FF7889A2FF244182FF051033960000
                000F000000020000000000000000000000000000000000000000442D22FF0000
                0000000000000000000841261B91879AB2FFC8E3F5FF1F66B6FF2B6BA8FF0512
                36950000000E0000000200000000000000000000000000000000452E23FF0000
                000000000000000000031113163E488BC3FFDEFEFDFF51B4E3FF1F68B7FF3173
                AEFF061538940000000D00000002000000000000000000000000483022FF0000
                00000000000000000001000000081D44618D479FD2FFDEFEFDFF59BFE9FF216B
                B9FF367BB3FF07173A920000000C000000020000000000000000493224FF0000
                0000000000000000000000000001000000091D44618C4BA5D5FFDEFEFDFF61CA
                EFFF246FBCFF3B83B9FF08193D900000000A00000002000000004A3225FF0000
                000000000000000000000000000000000001000000081D44618A4EAAD7FFDEFE
                FDFF68D4F4FF2875BEFF3F8BBEFF091B3F8E00000006000000004C3426FF4B33
                26FF4B3225FF4A3225FF493225FF483124FF483124FF000000071C44618951AE
                DAFFDEFEFDFF6EDDF8FF2C7BC2FF18448BFF0000000800000000000000000000
                0000000000000000000000000000000000000000000000000001000000061D44
                618754B1DCFFDEFEFDFF4FA6D4FF112B4E880000000400000000000000000000
                0000000000000000000000000000000000000000000000000000000000010000
                00051D456185357FBCFF173A5986000000050000000100000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00010000000200000004000000030000000100000000}
              Caption.Text = 'N'
              DataBinding.FieldName = 'NOTLAR_BIT'
              Width = 22
              Position.ColIndex = 6
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListYORUM_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 26
                  Value = True
                end>
              Caption.Text = 'Y'
              DataBinding.FieldName = 'YORUM_BIT'
              Width = 22
              Position.ColIndex = 8
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListTEKRAR_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 20
                  Value = True
                end>
              Caption.Text = 'T'
              DataBinding.FieldName = 'TEKRAR_BIT'
              Width = 22
              Position.ColIndex = 9
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListANIMSAT_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 23
                  Value = True
                end>
              Caption.Text = 'A'
              DataBinding.FieldName = 'ANIMSAT_BIT'
              Width = 22
              Position.ColIndex = 10
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListBAYRAK: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 21
                  Value = True
                end>
              Caption.Text = 'B'
              DataBinding.FieldName = 'BAYRAK'
              Width = 22
              Position.ColIndex = 11
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListDURUM: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepGorevDurum
              DataBinding.FieldName = 'DURUM'
              Width = 100
              Position.ColIndex = 12
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListPROJEKODU: TcxDBTreeListColumn
              DataBinding.FieldName = 'PROJEKODU'
              Width = 100
              Position.ColIndex = 13
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListEKLEYENAD: TcxDBTreeListColumn
              DataBinding.FieldName = 'EKLEYENAD'
              Width = 100
              Position.ColIndex = 14
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListEKLEMETARIHI: TcxDBTreeListColumn
              PropertiesClassName = 'TcxDateEditProperties'
              DataBinding.FieldName = 'EKLEMETARIHI'
              Width = 100
              Position.ColIndex = 15
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListGorevcxDBTreeListEKLEYEN: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'EKLEYEN'
              Position.ColIndex = 16
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListGorevcxDBTreeListLISTEID: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'LISTEID'
              Position.ColIndex = 17
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 1036
            Height = 41
            Align = alTop
            Caption = 'Panel9'
            TabOrder = 1
            object ToolBar6: TToolBar
              Left = 1
              Top = 1
              Width = 146
              Height = 39
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 46
              Caption = 'AletCubugu'
              Color = clTeal
              Ctl3D = False
              DockSite = True
              DrawingStyle = dsGradient
              EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
              EdgeInner = esNone
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
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object GorevEkleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = GorevEkleTusClick
              end
              object GorevSilTus: TToolButton
                Left = 46
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = GorevSilTusClick
              end
              object ToolButton15: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton6'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Style = tbsSeparator
              end
              object GorevDuzenleTus: TToolButton
                Left = 100
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = TreeListGorevDblClick
              end
            end
            object JvNavPanelHeader1: TJvNavPanelHeader
              Left = 147
              Top = 1
              Width = 888
              Height = 39
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
              object CheckTamamlanan: TcxCheckBox
                Left = 0
                Top = 0
                Align = alLeft
                Caption = 'Tamamlananlar'#305' da g'#246'ster'
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 0
                Transparent = True
                OnClick = CheckTamamlananClick
              end
              object ComboTamamlanan: TcxImageComboBox
                Left = 213
                Top = 7
                RepositoryItem = Tablo.RepGorevSonKac
                Properties.Items = <>
                Properties.OnEditValueChanged = CheckTamamlananClick
                Style.Color = clSilver
                TabOrder = 1
                Visible = False
                Width = 141
              end
            end
          end
        end
        object TabSheetFirsat: TcxTabSheet
          Caption = 'Sat'#305#351' F'#305'rsatlar'#305
          ImageIndex = 10
          object Panel7: TPanel
            Left = 0
            Top = 0
            Width = 1036
            Height = 41
            Align = alTop
            Caption = 'Panel6'
            TabOrder = 0
            object ToolBar9: TToolBar
              Left = 1
              Top = 1
              Width = 146
              Height = 39
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 46
              Caption = 'AletCubugu'
              Color = clTeal
              Ctl3D = False
              DockSite = True
              DrawingStyle = dsGradient
              EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
              EdgeInner = esNone
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
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object FirsatEkleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = FirsatEkleTusClick
              end
              object FirsatSilTus: TToolButton
                Left = 46
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = FirsatSilTusClick
              end
              object ToolButton16: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton7'
                ImageIndex = 8
                ImageName = 'PngImage15'
                Style = tbsSeparator
              end
              object FirsatDuzenleTus: TToolButton
                Left = 100
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = FirsatDuzenleTusClick
              end
            end
            object JvNavPanelHeader3: TJvNavPanelHeader
              Left = 147
              Top = 1
              Width = 888
              Height = 39
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
              object checkKapaliFirsatGoster: TcxCheckBox
                Left = 0
                Top = 0
                Align = alLeft
                Caption = 'Kapal'#305' F'#305'rsatlar'#305' da g'#246'ster'
                ParentFont = False
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
                Properties.OnEditValueChanged = checkKapaliGosterPropertiesEditValueChanged
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 0
                Transparent = True
              end
            end
          end
          object GridFirsat: TcxGrid
            Left = 0
            Top = 41
            Width = 1036
            Height = 187
            Align = alClient
            PopupMenu = PmProjeAktKopyala
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridFirsatView: TcxGridDBTableView
              OnDblClick = ProjeDuzenleClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridCariProjelerViewCanFocusRecord
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsFirsat
              DataController.DetailKeyFieldNames = 'ID'
              DataController.KeyFieldNames = 'ID'
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
              OptionsView.ExpandButtonsForEmptyDetails = False
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              Styles.OnGetContentStyle = GridCariProjelerViewStylesGetContentStyle
              object cxGridDBColumn5: TcxGridDBColumn
                Caption = 'Ba'#351'lama'
                DataBinding.FieldName = 'BASLAMATARIHI'
                DataBinding.IsNullValueType = True
                Width = 89
              end
              object cxGridDBColumn6: TcxGridDBColumn
                Caption = 'Biti'#351
                DataBinding.FieldName = 'BITISTARIHI'
                DataBinding.IsNullValueType = True
              end
              object cxGridDBColumn8: TcxGridDBColumn
                Caption = 'F'#305'rsat Kodu'
                DataBinding.FieldName = 'PROJEKODU'
                DataBinding.IsNullValueType = True
                Width = 107
              end
              object cxGridDBColumn13: TcxGridDBColumn
                Caption = 'F'#305'rsat Ad'#305
                DataBinding.FieldName = 'PROJEADI'
                DataBinding.IsNullValueType = True
                Width = 85
              end
              object cxGridDBColumn14: TcxGridDBColumn
                Caption = 'Konusu'
                DataBinding.FieldName = 'KONUSU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 86
              end
              object cxGridDBColumn15: TcxGridDBColumn
                Caption = 'T'#252'r'#252
                DataBinding.FieldName = 'PROJETURU'
                DataBinding.IsNullValueType = True
                Width = 79
              end
              object cxGridDBColumn16: TcxGridDBColumn
                Caption = 'Durum'
                DataBinding.FieldName = 'PROJEDURUM'
                DataBinding.IsNullValueType = True
              end
              object cxGridDBColumn17: TcxGridDBColumn
                Caption = 'A'#351'ama'
                DataBinding.FieldName = 'PROJEASAMA'
                DataBinding.IsNullValueType = True
              end
              object cxGridDBColumn20: TcxGridDBColumn
                Caption = 'F'#305'rsat De'#287'eri'
                DataBinding.FieldName = 'SATISFIYATI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;(,0.00)'
                Width = 77
              end
              object cxGridDBColumn21: TcxGridDBColumn
                Caption = 'P.Birimi'
                DataBinding.FieldName = 'SATISKUR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxComboBoxProperties'
              end
              object cxGridDBColumn22: TcxGridDBColumn
                Caption = 'Notlar'
                DataBinding.FieldName = 'NOTLAR'
                DataBinding.IsNullValueType = True
              end
            end
            object cxGridDBTableView2: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataModeController.GridMode = True
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsPerIletisim
              DataController.DetailKeyFieldNames = 'SOZID'
              DataController.MasterKeyFieldNames = 'ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              object cxGridDBColumn23: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
              end
              object cxGridDBColumn24: TcxGridDBColumn
                Caption = 'Belge Ad'#305
                DataBinding.FieldName = 'BELGEADI'
                DataBinding.IsNullValueType = True
              end
            end
            object cxGridLevel2: TcxGridLevel
              GridView = GridFirsatView
            end
          end
          object MemoFirsat: TMemo
            Left = 21
            Top = 85
            Width = 638
            Height = 89
            Color = clSilver
            Lines.Strings = (
          
                'select P.ID,P.REHBERID,P.PROJEKODU,Firma.FIRMA, BASLAMATARIHI,TU' +
                'RU,KONUSU,ASAMA,LISTEFIYATI,LISTEKUR,SATISFIYATI,SATISKUR, '
          
                'RehberIlgili.ADSOYAD, P.DURUM,P.NOTLAR , BITISTARIHI ,P.PROJEADI' +
                ',P.OLASILIK,P.APLIKASYON,'
          
                'ProjeTuru.ANAHTAR PROJETURU, ProjeAsama.ANAHTAR PROJEASAMA, Proj' +
                'eDurum.ANAHTAR PROJEDURUM'
              'from PROJELER P '
              #9'INNER JOIN REHBER Firma on Firma.ID = P.REHBERID'
          
                #9'LEFT OUTER JOIN REHBERPERSONEL RehberIlgili on RehberIlgili.ID=' +
                'P.ILGILI'
          
                #9'LEFT OUTER JOIN GENINI ProjeTuru ON ProjeTuru.DEGER = P.TURU AN' +
                'D ProjeTuru.BOLUM =-2112'
          
                #9'LEFT OUTER JOIN GENINI ProjeAsama ON ProjeAsama.DEGER = P.ASAMA' +
                ' AND ProjeAsama.BOLUM =-2113'
          
                #9'LEFT OUTER JOIN GENINI ProjeDurum ON ProjeDurum.DEGER = P.DURUM' +
                ' AND ProjeDurum.BOLUM =-2114'
              'WHERE '
              'P.REHBERID = :PID '
              'and P.MODUL=1')
            TabOrder = 2
            Visible = False
            WordWrap = False
          end
        end
        object TabSheetProje: TcxTabSheet
          Caption = 'Projeler'
          ImageIndex = 5
          object GridCariProjeler: TcxGrid
            Left = 0
            Top = 41
            Width = 1036
            Height = 187
            Align = alClient
            PopupMenu = PmProjeAktKopyala
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridCariProjelerView: TcxGridDBTableView
              OnDblClick = ProjeDuzenleClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridCariProjelerViewCanFocusRecord
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsProjeler
              DataController.DetailKeyFieldNames = 'ID'
              DataController.KeyFieldNames = 'ID'
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
              OptionsView.ExpandButtonsForEmptyDetails = False
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              Styles.OnGetContentStyle = GridCariProjelerViewStylesGetContentStyle
              object GridCariProjelerViewBASTARIHI: TcxGridDBColumn
                Caption = 'Ba'#351'lama'
                DataBinding.FieldName = 'BASLAMATARIHI'
                DataBinding.IsNullValueType = True
                Width = 89
              end
              object GridCariProjelerViewBITTARIHI: TcxGridDBColumn
                Caption = 'Biti'#351' Tarihi'
                DataBinding.FieldName = 'BITISTARIHI'
                DataBinding.IsNullValueType = True
              end
              object GridCariProjelerViewPROJEKODU: TcxGridDBColumn
                Caption = 'Proje Kodu'
                DataBinding.FieldName = 'PROJEKODU'
                DataBinding.IsNullValueType = True
                Width = 107
              end
              object GridCariProjelerViewPROJEADI: TcxGridDBColumn
                Caption = 'Proje Ad'#305
                DataBinding.FieldName = 'PROJEADI'
                DataBinding.IsNullValueType = True
                Width = 85
              end
              object GridCariProjelerViewKONUSU: TcxGridDBColumn
                Caption = 'Konusu'
                DataBinding.FieldName = 'KONUSU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 86
              end
              object GridCariProjelerViewTURU: TcxGridDBColumn
                Caption = 'T'#252'r'#252
                DataBinding.FieldName = 'PROJETURU'
                DataBinding.IsNullValueType = True
                Width = 79
              end
              object GridCariProjelerViewDURUM: TcxGridDBColumn
                Caption = 'Durum'
                DataBinding.FieldName = 'PROJEDURUM'
                DataBinding.IsNullValueType = True
              end
              object GridCariProjelerViewASAMA: TcxGridDBColumn
                Caption = 'A'#351'ama'
                DataBinding.FieldName = 'PROJEASAMA'
                DataBinding.IsNullValueType = True
              end
              object GridCariProjelerViewLISTEFIYATI: TcxGridDBColumn
                Caption = 'Liste Fiyat'#305
                DataBinding.FieldName = 'LISTEFIYATI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;(,0.00)'
              end
              object GridCariProjelerViewLISTEKUR: TcxGridDBColumn
                Caption = 'Liste P.Birimi'
                DataBinding.FieldName = 'LISTEKUR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxComboBoxProperties'
              end
              object GridCariProjelerViewSATISFIYATI: TcxGridDBColumn
                Caption = 'Sat'#305#351' Fiyat'#305
                DataBinding.FieldName = 'SATISFIYATI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;(,0.00)'
                Width = 77
              end
              object GridCariProjelerViewSATISKUR: TcxGridDBColumn
                Caption = 'Sat'#305#351' P.Birimi'
                DataBinding.FieldName = 'SATISKUR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxComboBoxProperties'
              end
              object GridCariProjelerViewNOTLAR: TcxGridDBColumn
                Caption = 'Notlar'
                DataBinding.FieldName = 'NOTLAR'
                DataBinding.IsNullValueType = True
              end
            end
            object GridCariProjelerDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataModeController.GridMode = True
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsPerIletisim
              DataController.DetailKeyFieldNames = 'SOZID'
              DataController.MasterKeyFieldNames = 'ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              object GridCariProjelerDBTableView1TUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
              end
              object GridCariProjelerDBTableView1BELGEADI: TcxGridDBColumn
                Caption = 'Belge Ad'#305
                DataBinding.FieldName = 'BELGEADI'
                DataBinding.IsNullValueType = True
              end
            end
            object GridCariProjelerLevel1: TcxGridLevel
              GridView = GridCariProjelerView
            end
          end
          object MemoProjeler: TMemo
            Left = 15
            Top = 72
            Width = 638
            Height = 89
            Color = clSilver
            Lines.Strings = (
          
                'select P.ID,P.REHBERID,P.PROJEKODU,Firma.FIRMA, BASLAMATARIHI,TU' +
                'RU,KONUSU,ASAMA,LISTEFIYATI,LISTEKUR,SATISFIYATI,SATISKUR, '
          
                'RehberIlgili.ADSOYAD, P.DURUM,P.NOTLAR , BITISTARIHI ,P.PROJEADI' +
                ',P.OLASILIK,P.APLIKASYON,'
          
                'ProjeTuru.ANAHTAR PROJETURU, ProjeAsama.ANAHTAR PROJEASAMA, Proj' +
                'eDurum.ANAHTAR PROJEDURUM'
              'from PROJELER P '
              #9'INNER JOIN REHBER Firma on Firma.ID = P.REHBERID'
          
                #9'LEFT OUTER JOIN REHBERPERSONEL RehberIlgili on RehberIlgili.ID=' +
                'P.ILGILI'
          
                #9'LEFT OUTER JOIN GENINI ProjeTuru ON ProjeTuru.DEGER = P.TURU AN' +
                'D ProjeTuru.BOLUM =-2132'
          
                #9'LEFT OUTER JOIN GENINI ProjeAsama ON ProjeAsama.DEGER = P.ASAMA' +
                ' AND ProjeAsama.BOLUM =-2133'
          
                #9'LEFT OUTER JOIN GENINI ProjeDurum ON ProjeDurum.DEGER = P.DURUM' +
                ' AND ProjeDurum.BOLUM =-2134'
              'WHERE '
              'P.REHBERID = :PID '
              'and P.MODUL=11'
              '')
            TabOrder = 1
            Visible = False
            WordWrap = False
          end
          object Panel6: TPanel
            Left = 0
            Top = 0
            Width = 1036
            Height = 41
            Align = alTop
            Caption = 'Panel6'
            TabOrder = 2
            object ToolBar4: TToolBar
              Left = 1
              Top = 1
              Width = 146
              Height = 39
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 46
              Caption = 'AletCubugu'
              Color = clTeal
              Ctl3D = False
              DockSite = True
              DrawingStyle = dsGradient
              EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
              EdgeInner = esNone
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
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object ProjeEkleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = ProjeEkleTusClick
              end
              object ProjeSilTus: TToolButton
                Left = 46
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = ProjeSilTusClick
              end
              object ToolButton7: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton7'
                ImageIndex = 8
                ImageName = 'PngImage15'
                Style = tbsSeparator
              end
              object ProjeDuzenle: TToolButton
                Left = 100
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = ProjeDuzenleClick
              end
            end
            object JvNavPanelHeader2: TJvNavPanelHeader
              Left = 147
              Top = 1
              Width = 888
              Height = 39
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
              object checkKapaliProjeGoster: TcxCheckBox
                Left = 0
                Top = 0
                Align = alLeft
                Caption = 'Kapal'#305' Projeleri de g'#246'ster'
                ParentFont = False
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
                Properties.OnEditValueChanged = checkKapaliGosterPropertiesEditValueChanged
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 0
                Transparent = True
              end
            end
          end
        end
      end
    end
    object TabSheetTeklifler: TcxTabSheet
      Caption = 'Teklif'
      ImageIndex = 6
      object ToolBar12: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1030
        Height = 41
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 39
        ButtonWidth = 46
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
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object TeklifEkle: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = TeklifEkleClick
        end
        object TeklifSil: TToolButton
          Left = 46
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = TeklifSilClick
        end
        object ToolButton12: TToolButton
          Left = 92
          Top = 0
          Width = 8
          Caption = 'ToolButton7'
          ImageIndex = 8
          ImageName = 'PngImage15'
          Style = tbsSeparator
        end
        object TeklifDuzenle: TToolButton
          Left = 100
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = TeklifDuzenleClick
        end
      end
      object GridTeklif: TcxGrid
        Left = 0
        Top = 44
        Width = 1036
        Height = 184
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridTeklifView: TcxGridDBTableView
          OnDblClick = GridTeklifViewDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsTeklifler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'FATURA_MATRAHI'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'KDV_TUTARI'
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'FATURA_TUTARI'
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridTeklifViewStylesGetContentStyle
          object GridTeklifViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Width = 42
          end
          object GridTeklifViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            Width = 63
          end
          object GridTeklifViewTEKLIFNO: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'TEKLIFNO'
            DataBinding.IsNullValueType = True
            Width = 76
          end
          object GridTeklifViewTURU: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TURU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repTeklifTuru
          end
          object GridTeklifViewKONUSU: TcxGridDBColumn
            Caption = 'Konu'
            DataBinding.FieldName = 'KONUSU'
            DataBinding.IsNullValueType = True
            Width = 153
          end
          object GridTeklifViewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repTeklifDurumu
          end
          object GridTeklifViewOLASILIK: TcxGridDBColumn
            Caption = 'Olas'#305'l'#305'k'
            DataBinding.FieldName = 'OLASILIK'
            DataBinding.IsNullValueType = True
          end
          object GridTeklifViewTEKLIF_TUTARI: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TEKLIF_TUTARI'
            DataBinding.IsNullValueType = True
          end
          object GridTeklifViewKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
          object GridTeklifViewONAYLAYACAK: TcxGridDBColumn
            Caption = 'Onaylayacak'
            DataBinding.FieldName = 'ONAYLAYACAK'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesi
          end
          object GridTeklifViewONAYLAYAN: TcxGridDBColumn
            Caption = 'Onaylayan'
            DataBinding.FieldName = 'ONAYLAYAN'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesi
          end
          object GridTeklifViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 193
          end
        end
        object GridTeklifLevel1: TcxGridLevel
          GridView = GridTeklifView
        end
      end
    end
    object TabSheetYaslandirma: TcxTabSheet
      Caption = 'Ya'#351'land'#305'rma'
      ImageIndex = 7
      object GridYaslandir: TcxGrid
        Left = 0
        Top = 33
        Width = 1036
        Height = 195
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridYaslandirView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridYaslandirViewCanFocusRecord
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsYaslandirma
          DataController.Options = [dcoGroupsAlwaysExpanded]
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
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object GridYaslandirViewColumnISLEMTARIHI: TcxGridDBColumn
            Caption = #304#351'lem Tarihi'
            DataBinding.FieldName = 'ISLEMTARIHI'
            DataBinding.IsNullValueType = True
          end
          object GridYaslandirViewColumnVADESONU: TcxGridDBColumn
            Caption = 'Vade'
            DataBinding.FieldName = 'VADESONU'
            DataBinding.IsNullValueType = True
          end
          object GridYaslandirViewColumnODEMETARIHI: TcxGridDBColumn
            Caption = #214'deme Tarihi'
            DataBinding.FieldName = 'ODEMETARIHI'
            DataBinding.IsNullValueType = True
          end
          object GridYaslandirViewColumnGECIKENGUNSAYISI: TcxGridDBColumn
            Caption = 'Gecikme(G'#252'n)'
            DataBinding.FieldName = 'GECIKENGUNSAYISI'
            DataBinding.IsNullValueType = True
            Width = 97
          end
          object GridYaslandirViewColumnISLEMTURU: TcxGridDBColumn
            Caption = #304#351'lem T'#252'r'#252
            DataBinding.FieldName = 'ISLEMTURU'
            DataBinding.IsNullValueType = True
            Width = 78
          end
          object GridYaslandirViewColumnODEMETURU: TcxGridDBColumn
            Caption = #214'deme T'#252'r'#252
            DataBinding.FieldName = 'ODEMETURU'
            DataBinding.IsNullValueType = True
            Width = 87
          end
          object GridYaslandirViewColumnBORCTUTARI: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.FieldName = 'BORCTUTARI'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
          end
          object GridYaslandirViewColumnODEMETUTARI: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.FieldName = 'ODEMETUTARI'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
          end
          object GridYaslandirViewColumnODENENTUTAR: TcxGridDBColumn
            Caption = 'E'#351'le'#351'en Tutar'
            DataBinding.FieldName = 'ODENENTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 84
          end
          object GridYaslandirViewColumnGECIKENTUTAR: TcxGridDBColumn
            Caption = 'Geciken Tutar'
            DataBinding.FieldName = 'GECIKENTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
          end
          object GridYaslandirViewColumnISLEMACIKLAMA: TcxGridDBColumn
            Caption = 'Bor'#231' A'#231#305'klamas'#305
            DataBinding.FieldName = 'ISLEMACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 103
          end
          object GridYaslandirViewColumnODEMEACIKLAMA: TcxGridDBColumn
            Caption = 'Alacak A'#231#305'klamas'#305
            DataBinding.FieldName = 'ODEMEACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 109
          end
        end
        object cxGridDBTableView3: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DetailKeyFieldNames = 'CEKID'
          DataController.MasterKeyFieldNames = 'CEKID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGridDBColumn28: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object cxGridDBColumn29: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 130
          end
          object cxGridDBColumn30: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object cxGridDBColumn31: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 354
          end
          object cxGridDBColumn32: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGridLevel10: TcxGridLevel
          GridView = GridYaslandirView
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 1036
        Height = 33
        Align = alTop
        TabOrder = 0
      end
    end
    object TabSheetEkipman: TcxTabSheet
      Caption = 'Ekipman'
      ImageIndex = 9
      object PageControlEkipman: TcxPageControl
        Left = 0
        Top = 0
        Width = 1036
        Height = 228
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = SheetBizimEkipman
        Properties.CustomButtons.Buttons = <>
        Properties.Style = 8
        ClientRectBottom = 228
        ClientRectRight = 1036
        ClientRectTop = 27
        object SheetBizimEkipman: TcxTabSheet
          Caption = 'Ekipmanlar'
          ImageIndex = 0
          object ToolBarEkipmanDetay: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1030
            Height = 24
            Margins.Bottom = 0
            AutoSize = True
            ButtonWidth = 66
            Caption = 'AletCubugu'
            Color = clBtnFace
            DockSite = True
            DrawingStyle = dsGradient
            EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
            EdgeInner = esLowered
            EdgeOuter = esNone
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
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
            Wrapable = False
            object BtnEkipmanDetayYeni: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = BtnEkipmanDetayYeniClick
            end
            object btnEkipmanDetaySil: TToolButton
              Left = 66
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = btnEkipmanDetaySilClick
            end
            object ToolButton24: TToolButton
              Left = 132
              Top = 0
              Width = 8
              Caption = 'ToolButton4'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsSeparator
            end
            object BtnEkipmanDetayKaydet: TToolButton
              Left = 140
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = BtnEkipmanDetayKaydetClick
            end
            object BtnEkipmanDetayIptal: TToolButton
              Left = 206
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = BtnEkipmanDetayIptalClick
            end
            object BtnEkipmanDuzenle: TToolButton
              Left = 272
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              OnClick = BtnEkipmanDuzenleClick
            end
          end
          object TreeListEkipman: TcxDBTreeList
            Left = 0
            Top = 27
            Width = 712
            Height = 174
            Align = alClient
            Bands = <
              item
              end>
            DataController.DataSource = DtsEkipmanlar
            DataController.ParentField = 'USTID'
            DataController.KeyField = 'ID'
            DragMode = dmAutomatic
            LookAndFeel.ScrollbarMode = sbmClassic
            Navigator.Buttons.CustomButtons = <>
            PopupMenu = PopupMenuEkipman
            RootValue = -1
            ScrollbarAnnotations.CustomAnnotations = <>
            Styles.OnGetNodeIndentStyle = TreeListEkipmanStylesGetNodeIndentStyle
            TabOrder = 1
            OnDragOver = TreeListEkipmanDragOver
            OnMoveTo = TreeListEkipmanMoveTo
            OnSelectionChanged = TreeListEkipmanSelectionChanged
            object TreeListEkipmancxDBTreeListID: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'ID'
              Position.ColIndex = 12
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxDBTreeList1cxDBTreeListColumn11: TcxDBTreeListColumn
              Caption.Text = 'Kod'
              DataBinding.FieldName = 'KOD'
              Options.Editing = False
              Width = 76
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxDBTreeList1cxDBTreeListColumn12: TcxDBTreeListColumn
              Caption.Text = 'Ad'
              DataBinding.FieldName = 'AD'
              Options.Editing = False
              Width = 111
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxDBTreeList1cxDBTreeListSERINO: TcxDBTreeListColumn
              Caption.Text = 'Seri No'
              DataBinding.FieldName = 'SERINO'
              Width = 76
              Position.ColIndex = 6
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = cxDBTreeList1cxDBTreeListColumn6PropertiesButtonClick
              Caption.Text = #304#231' Lokasyon'
              DataBinding.FieldName = 'LOKASYON'
              Width = 73
              Position.ColIndex = 11
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = cxDBTreeList1cxDBTreeListColumn2PropertiesButtonClick
              Caption.Text = #304'lgili'
              DataBinding.FieldName = 'ILGILI'
              Width = 100
              Position.ColIndex = 3
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListColumn1: TcxDBTreeListColumn
              PropertiesClassName = 'TcxDateEditProperties'
              Caption.Text = 'Sat'#305#351' Tarihi'
              DataBinding.FieldName = 'SATISTARIHI'
              Width = 100
              Position.ColIndex = 7
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListColumn2: TcxDBTreeListColumn
              PropertiesClassName = 'TcxTextEditProperties'
              Caption.Text = 'Sat'#305#351' No'
              DataBinding.FieldName = 'SATISNO'
              Width = 100
              Position.ColIndex = 8
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListGARANTIBITTAR: TcxDBTreeListColumn
              PropertiesClassName = 'TcxDateEditProperties'
              Caption.Text = 'Garanti Biti'#351
              DataBinding.FieldName = 'GARANTIBITTAR'
              Width = 100
              Position.ColIndex = 9
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListColumnSURE: TcxDBTreeListColumn
              Caption.Text = 'S'#252're'
              DataBinding.FieldName = 'SURE'
              Width = 83
              Position.ColIndex = 10
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListSAHIP: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList2
              Properties.Items = <
                item
                  ImageIndex = 27
                  Value = False
                end
                item
                  ImageIndex = 28
                  Value = True
                end>
              Caption.Text = 'Sahibi'
              DataBinding.FieldName = 'SAHIP'
              Width = 51
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListMARKA: TcxDBTreeListColumn
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = TreeListEkipmancxDBTreeListMARKAPropertiesButtonClick
              Caption.Text = 'Marka'
              DataBinding.FieldName = 'MARKAAD'
              Width = 100
              Position.ColIndex = 4
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListMODEL: TcxDBTreeListColumn
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = TreeListEkipmancxDBTreeListMODELPropertiesButtonClick
              Caption.Text = 'Model'
              DataBinding.FieldName = 'MODELAD'
              Width = 100
              Position.ColIndex = 5
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object cxDBTreeList1cxDBTreeListColumn13: TcxDBTreeListColumn
              PropertiesClassName = 'TcxTextEditProperties'
              Caption.Text = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              Width = 112
              Position.ColIndex = 14
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListColumn3: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              Caption.Text = 'D'#305#351' Lokasyon'
              DataBinding.FieldName = 'DISLOKASYONID'
              Width = 87
              Position.ColIndex = 13
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
          object cxSplitter2: TcxSplitter
            Left = 712
            Top = 27
            Width = 8
            Height = 174
            HotZoneClassName = 'TcxMediaPlayer8Style'
            AlignSplitter = salRight
            Control = GridEkEkipman
          end
          object GridEkEkipman: TcxGrid
            Left = 720
            Top = 27
            Width = 316
            Height = 174
            Align = alRight
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            PopupMenu = PopupMenuEkipman
            TabOrder = 3
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridEkEkipmanView: TcxGridDBTableView
              OnDblClick = BtnEkipmanDuzenleClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsEkipmanEkBilgi
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GridLines = glNone
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              Styles.Background = cxStyle2
              Styles.Content = cxStyle2
              Styles.Header = cxStyle2
              Styles.Inactive = cxStyle2
              object cxGridDBColumn7: TcxGridDBColumn
                Caption = 'T'#252'r'#252
                DataBinding.FieldName = 'ETIKET'
                DataBinding.IsNullValueType = True
                MinWidth = 125
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Options.Sorting = False
                Width = 125
              end
              object cxGridDBColumn9: TcxGridDBColumn
                Caption = 'Bilgisi'
                DataBinding.FieldName = 'BILGI'
                DataBinding.IsNullValueType = True
                MinWidth = 250
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Options.Sorting = False
                Width = 250
              end
            end
            object cxGridLevel11: TcxGridLevel
              GridView = GridEkEkipmanView
            end
          end
          object MemoEkipmanEkleListe: TMemo
            Left = -33
            Top = 92
            Width = 889
            Height = 31
            Lines.Strings = (
              'WITH PagesList (EkipmanID,TreeID,ADET) AS'
              
                '('#9'SELECT E.ID,TreeID=convert(nvarchar(254),E.ID),ADET=CONVERT(nv' +
                'archar(20),1)'
              #9'FROM EKIPMANLAR E'
              #9'WHERE ID= :PEkipmanID'
              #9'UNION ALL'
              
                #9'SELECT ED.EKIPMANID,TreeID=convert(nvarchar(254),TreeID+N'#39'.'#39'+co' +
                'nvert(nvarchar(200),ED.EKIPMANID)),ADET=CONVERT(nvarchar(20),ED.' +
                'ADET)'
              
                #9'From EKIPMANDETAY as ED INNER JOIN PagesList as p ON ED.USTEKIP' +
                'MANID = p.EkipmanID'
              ')'
              'SELECT ALTID=TreeID,'
              'USTID=case when CHARINDEX('#39'.'#39',TreeID,1)=0 then '#39'0'#39' else'
              
                'REVERSE(SUBSTRING(REVERSE(TreeID),CHARINDEX('#39'.'#39',REVERSE(TreeID),' +
                '1)+1,LEN(TreeID)-(CHARINDEX('#39'.'#39',REVERSE(TreeID),1)-1)))'
              'end ,ADET,E2.*,'
              
                'MARKAAD = (case when E2.SAHIP=0 then (select top 1 ANAHTAR from ' +
                'GENINI where BOLUM=-2727 and DEGER=E2.MARKA and DIL=-1)'
              
                #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and ' +
                'DEGER=E2.MARKA and DIL=-1) end) ,'
              
                'MODELAD = (case when E2.SAHIP=0 then (select top 1 ANAHTAR from ' +
                'GENINI where BOLUM=convert(int,'#39'-2727'#39'+convert(varchar(10),E2.MA' +
                'RKA)) and DEGER=E2.MODEL and DIL=-1) '
              
                #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=convert(in' +
                't,'#39'-2701'#39'+convert(varchar(10),E2.MARKA)) and DEGER=E2.MODEL and ' +
                'DIL=-1) end)'
              'FROM PagesList p inner join EKIPMANLAR E2 on E2.ID = p.EkipmanID'
              'order by 2'
              '')
            TabOrder = 4
            Visible = False
            WordWrap = False
          end
        end
        object SheetRakipEkipman: TcxTabSheet
          Caption = 'Rakip Ekipmanlar'
          ImageIndex = 1
          object ToolBar8: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1030
            Height = 24
            Margins.Bottom = 0
            AutoSize = True
            ButtonWidth = 62
            Caption = 'AletCubugu'
            Color = clBtnFace
            DockSite = True
            DrawingStyle = dsGradient
            EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
            EdgeInner = esLowered
            EdgeOuter = esNone
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
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
            Wrapable = False
            object btnRakipEkipmanYeni: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = btnRakipEkipmanYeniClick
            end
            object btnRakipEkipmanSil: TToolButton
              Left = 62
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = btnRakipEkipmanSilClick
            end
            object ToolButton18: TToolButton
              Left = 124
              Top = 0
              Width = 8
              Caption = 'ToolButton4'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsSeparator
            end
            object btnRakipEkipmanKaydet: TToolButton
              Left = 132
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = btnRakipEkipmanKaydetClick
            end
            object btnRakipEkipmanIptal: TToolButton
              Left = 194
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = btnRakipEkipmanIptalClick
            end
          end
          object GridEkipmanRakip: TcxGrid
            Left = 0
            Top = 27
            Width = 1036
            Height = 174
            Align = alClient
            TabOrder = 1
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridEkipmanRakipDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsEkipmanRakip
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              object GridEkipmanRakipDBTableView1ID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridEkipmanRakipDBTableView1REHBERID: TcxGridDBColumn
                DataBinding.FieldName = 'REHBERID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridEkipmanRakipDBTableView1MARKA: TcxGridDBColumn
                Caption = 'Marka'
                DataBinding.FieldName = 'MARKA'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 158
              end
              object GridEkipmanRakipDBTableView1MODEL: TcxGridDBColumn
                Caption = 'Model'
                DataBinding.FieldName = 'MODEL'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 171
              end
              object GridEkipmanRakipDBTableView1TIP: TcxGridDBColumn
                Caption = 'Tip'
                DataBinding.FieldName = 'TIP'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 154
              end
              object GridEkipmanRakipDBTableView1YIL: TcxGridDBColumn
                Caption = 'Y'#305'l'
                DataBinding.FieldName = 'YIL'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxSpinEditProperties'
              end
              object GridEkipmanRakipDBTableView1FIYAT: TcxGridDBColumn
                Caption = 'Fiyat'
                DataBinding.FieldName = 'FIYAT'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyBF
              end
              object GridEkipmanRakipDBTableView1KUR: TcxGridDBColumn
                Caption = 'Kur'
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              end
            end
            object GridEkipmanRakipLevel1: TcxGridLevel
              GridView = GridEkipmanRakipDBTableView1
            end
          end
        end
      end
    end
    object TabSheetEkstre: TcxTabSheet
      Caption = 'Ekstre'
      ImageIndex = 7
      object GridCariEkstre: TcxGrid
        Left = 0
        Top = 41
        Width = 1036
        Height = 187
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        PopupMenu = PMAksiyonlarMenu
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridCariEkstreView: TcxGridDBTableView
          OnDblClick = AksiyonBilgisiniGorMenuClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridCariEkstreViewCanFocusRecord
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsCariListe
          DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = GridCariEkstreViewBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              Position = spFooter
              Column = GridCariEkstreViewALACAK
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'BORC'
              Column = GridCariEkstreViewBORC
            end
            item
              Format = ',0.00;(,0.00)'
              Kind = skSum
              FieldName = 'ALACAK'
              Column = GridCariEkstreViewALACAK
            end
            item
              Format = ',0.00;(,0.00)'
              Column = GridCariEkstreViewBORCBAKIYE
            end
            item
              Format = ',0.00;(,0.00)'
              Column = GridCariEkstreViewALACAKBAKIYE
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
          OptionsView.GroupByBox = False
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridCariEkstreViewStylesGetContentStyle
          object GridCariEkstreViewTARIH: TcxGridDBColumn
            Caption = 'Kay'#305't'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.InputKind = ikRegExpr
            Properties.Kind = ckDateTime
            Width = 68
          end
          object GridCariEkstreViewAKSIYONTARIH: TcxGridDBColumn
            Caption = 'Aksiyon/Vade'
            DataBinding.FieldName = 'AKSIYONTARIH'
            DataBinding.IsNullValueType = True
            Width = 79
          end
          object GridCariEkstreViewNO: TcxGridDBColumn
            Caption = 'No'
            DataBinding.FieldName = 'NO'
            DataBinding.IsNullValueType = True
            Width = 49
          end
          object GridCariEkstreViewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepKasaTurleri
            Width = 53
          end
          object GridCariEkstreViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 77
          end
          object GridCariEkstreViewBASLIK: TcxGridDBColumn
            Caption = 'Ba'#351'l'#305'k'
            DataBinding.FieldName = 'BASLIK'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 90
          end
          object GridCariEkstreViewAD: TcxGridDBColumn
            Caption = #220'nvan'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 90
          end
          object GridCariEkstreViewACIKLAMA: TcxGridDBColumn
            Caption = 'Notlar'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 80
            Width = 128
          end
          object GridCariEkstreViewHESAPKODU: TcxGridDBColumn
            Caption = 'Hesap Kodu'
            DataBinding.FieldName = 'HESAPKODU'
            DataBinding.IsNullValueType = True
            Width = 64
          end
          object GridCariEkstreViewHESAPADI: TcxGridDBColumn
            Caption = 'Hesap Ad'#305
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 82
          end
          object GridCariEkstreViewADET: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 32
          end
          object GridCariEkstreViewBIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 47
          end
          object GridCariEkstreViewBIRIMFIYAT: TcxGridDBColumn
            Caption = 'Birim Fiyat'
            DataBinding.FieldName = 'BIRIMFIYAT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Visible = False
            Width = 63
          end
          object GridCariEkstreViewBORC: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.FieldName = 'BORC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 56
          end
          object GridCariEkstreViewALACAK: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.FieldName = 'ALACAK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 67
          end
          object GridCariEkstreViewBORCBAKIYE: TcxGridDBColumn
            Caption = 'B.Bakiye'
            DataBinding.FieldName = 'BORCBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 54
          end
          object GridCariEkstreViewALACAKBAKIYE: TcxGridDBColumn
            Caption = 'A.Bakiye'
            DataBinding.FieldName = 'ALACAKBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 56
          end
          object GridCariEkstreViewKUR: TcxGridDBColumn
            Caption = 'Para Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            GroupIndex = 0
            Width = 76
          end
          object GridCariEkstreViewYERELKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'YERELKUR'
            DataBinding.IsNullValueType = True
          end
          object GridCariEkstreViewYERELTUTAR: TcxGridDBColumn
            Caption = 'Y.Tutar'
            DataBinding.FieldName = 'YERELTUTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object GridCariEkstreViewYERELBAKIYE: TcxGridDBColumn
            Caption = 'Y.Bakiye'
            DataBinding.FieldName = 'YERELBAKIYE'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
          end
          object GridCariEkstreViewMASRAFKOD: TcxGridDBColumn
            Caption = 'Masraf Kod'
            DataBinding.FieldName = 'MASRAFKOD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 83
          end
          object GridCariEkstreViewMASRAFAD: TcxGridDBColumn
            Caption = 'Masraf Ad'
            DataBinding.FieldName = 'MASRAFAD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 120
          end
          object GridCariEkstreViewColumn1: TcxGridDBColumn
            Caption = #350'ube'
            DataBinding.FieldName = 'SUBEID'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
            Visible = False
          end
          object GridCariEkstreViewColumn2: TcxGridDBColumn
            Caption = 'Vade Tarihi'
            DataBinding.FieldName = 'VADETARIHI'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 67
          end
          object GridCariEkstreViewCEKID: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object GridCariEkstreDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DetailKeyFieldNames = 'CEKID'
          DataController.MasterKeyFieldNames = 'CEKID'
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object GridCariEkstreDBTableView1DURUM: TcxGridDBColumn
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 74
          end
          object GridCariEkstreDBTableView1VADE: TcxGridDBColumn
            DataBinding.FieldName = 'VADE'
            DataBinding.IsNullValueType = True
            Width = 130
          end
          object GridCariEkstreDBTableView1SERINO: TcxGridDBColumn
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            FooterAlignmentHorz = taRightJustify
            GroupSummaryAlignment = taRightJustify
            Width = 109
          end
          object GridCariEkstreDBTableView1HESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            Width = 354
          end
          object GridCariEkstreDBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'CEKID'
            DataBinding.IsNullValueType = True
          end
        end
        object GridCariEkstreLevel1: TcxGridLevel
          GridView = GridCariEkstreView
        end
      end
      object Panel8: TPanel
        Left = 0
        Top = 0
        Width = 1036
        Height = 41
        Align = alTop
        Caption = 'Panel8'
        TabOrder = 1
        object ToolBar11: TToolBar
          Left = 1
          Top = 1
          Width = 100
          Height = 39
          Margins.Bottom = 0
          Align = alLeft
          AutoSize = True
          ButtonHeight = 39
          ButtonWidth = 46
          Caption = 'AletCubugu'
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
          Images = Tablo.PNGImageList2
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          object EkstreSilTus: TToolButton
            Left = 0
            Top = 0
            Hint = 'Aksiyon Sil'
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            ParentShowHint = False
            ShowHint = True
            OnClick = Sil1Click
          end
          object EkstreDegisTus: TToolButton
            Left = 46
            Top = 0
            Hint = 'Aksiyon D'#252'zenle'
            Caption = 'D'#252'zenle'
            ImageIndex = 7
            ImageName = 'PngImage7'
            ParentShowHint = False
            ShowHint = True
            OnClick = AksiyonBilgisiniGorMenuClick
          end
          object ToolButton1: TToolButton
            Left = 92
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 17
            ImageName = 'PngImage17'
            Style = tbsSeparator
          end
        end
        object JvNavPanelHeader4: TJvNavPanelHeader
          Left = 101
          Top = 1
          Width = 934
          Height = 39
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
          object Label1: TcxLabel
            Left = 3
            Top = 8
            Caption = 'Ba'#351'lama'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = Label1Click
          end
          object CalendarEkstreBas: TcxDateEdit
            Left = 60
            Top = 6
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 1
            Width = 121
          end
          object Label2: TcxLabel
            Left = 187
            Top = 8
            Caption = 'Biti'#351
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object CalendarEkstreBit: TcxDateEdit
            Left = 223
            Top = 8
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 3
            Width = 121
          end
          object CheckDetayli: TcxCheckBox
            Left = 350
            Top = -1
            Caption = 'Detayl'#305' Ekstre G'#246'ster'
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CheckDetayliPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.Shadow = False
            Style.TransparentBorder = True
            Style.IsFontAssigned = True
            TabOrder = 4
            Transparent = True
          end
          object CheckPlan: TcxCheckBox
            Left = 350
            Top = 16
            Caption = 'Planlar'#305' G'#246'ster'
            ParentFont = False
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CheckDetayliPropertiesEditValueChanged
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -13
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.Shadow = False
            Style.TransparentBorder = True
            Style.IsFontAssigned = True
            TabOrder = 5
            Transparent = True
          end
        end
      end
    end
    object TabYorumMedya: TcxTabSheet
      Caption = 'Yorum/Medya'
      ImageIndex = 10
      object Panel4: TPanel
        Left = 0
        Top = 167
        Width = 1036
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
          Width = 888
        end
        object BtnMesajGonder: TcxButton
          Left = 889
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
          Left = 974
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
        Top = 208
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
        AnchorX = 1036
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 0
        Width = 1036
        Height = 167
        Align = alClient
        TabOrder = 2
        LevelTabs.CaptionAlignment = taLeftJustify
        LevelTabs.Style = 8
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        LookAndFeel.SkinName = 'LondonLiquidSky'
        RootLevelOptions.DetailTabsPosition = dtpTop
        object GridYorumDBCardView1: TcxGridDBCardView
          PopupMenu = PopupYorumlar
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
        object GridYorumDBTableView1: TcxGridDBTableView
          PopupMenu = PopupYorumlar
          OnDblClick = GridYorumDBTableView1DblClick
          Navigator.Buttons.CustomButtons = <>
          Navigator.Buttons.First.Visible = True
          Navigator.Buttons.PriorPage.Visible = True
          Navigator.Buttons.Prior.Visible = True
          Navigator.Buttons.Next.Visible = True
          Navigator.Buttons.NextPage.Visible = True
          Navigator.Buttons.Last.Visible = True
          Navigator.Buttons.Insert.Visible = True
          Navigator.Buttons.Append.Visible = False
          Navigator.Buttons.Delete.Visible = True
          Navigator.Buttons.Edit.Visible = True
          Navigator.Buttons.Post.Visible = True
          Navigator.Buttons.Cancel.Visible = True
          Navigator.Buttons.Refresh.Visible = True
          Navigator.Buttons.SaveBookmark.Visible = True
          Navigator.Buttons.GotoBookmark.Visible = True
          Navigator.Buttons.Filter.Visible = True
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsYorum2
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
          OptionsView.CellAutoHeight = True
          OptionsView.FooterAutoHeight = True
          OptionsView.FooterMultiSummaries = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridYorumDBTableView1Modul: TcxGridDBColumn
            DataBinding.FieldName = 'Mod'#252'l'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
          end
          object GridYorumDBTableView1Column1: TcxGridDBColumn
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object GridYorumDBTableView1Column2: TcxGridDBColumn
            DataBinding.FieldName = 'YORUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxRichEditProperties'
            Width = 350
          end
          object GridYorumDBTableView1Column3: TcxGridDBColumn
            DataBinding.FieldName = 'DOKUMANAD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxHyperLinkEditProperties'
            Properties.LinkColor = clBlack
            Properties.Prefix = ''
            Width = 177
          end
          object GridYorumDBTableView1Column4: TcxGridDBColumn
            DataBinding.FieldName = 'ATAC'
            DataBinding.IsNullValueType = True
            Width = 50
          end
        end
        object GridYorumLevel1: TcxGridLevel
          Caption = 'Cari  Mod'#252'l'#252
          GridView = GridYorumDBCardView1
          Options.DetailTabsPosition = dtpTop
        end
        object GridYorumLevel2: TcxGridLevel
          Caption = 'Di'#287'er Mod'#252'ller'
          GridView = GridYorumDBTableView1
          Options.DetailTabsPosition = dtpTop
          Styles.Tab = Tablo.cxstTamIade
        end
      end
    end
  end
  object SQLMemoBA: TcxMemo
    Left = 98
    Top = 226
    Lines.Strings = (
      'DECLARE '
      #9'@BASTARIH datetime,'
      #9'@ILGILIARAMA INT'
      ''
      ''
      'SET @ILGILIARAMA = :P1'
      
        'SET @BASTARIH =convert(varchar(4),Year(Getdate()))+'#39'-01-01 00:00' +
        ':00'#39
      ''
      ''
      'SELECT   <Param>'
      ''
      'FROM('
      '    select'
      
        #9#9'REHBERID,TOPLAM_BORC= SUM(isnull(BORC,0)), TOPLAM_ALACAK= SUM(' +
        'isnull(ALACAK,0)),TAKIPTE = ABS(SUM(ISNULL(TAKIPTE,0))),IRSALIYE' +
        ' = ABS(SUM(ISNULL(IRSALIYE,0))),KUR=isnull(KUR,'#39'TL'#39')'
      #9'from ('
      #9'SELECT'
      #9'REHBERID,'
      
        #9'SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA_' +
        'TUTARI END) AS BORC,'
      #9'0 AS ALACAK,'
      
        #9'CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KUR' +
        ','
      '    TAKIPTE = 0,'
      #9'IRSALIYE = 0'
      #9'FROM FATBASLIK F'
      
        #9'WHERE  isnull(F.DURUM,0)<>6 and (F.TUR in (15,16,17)) AND FATUR' +
        'ATARIH >= @BASTARIH'
      
        #9'GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI' +
        ' else KUR end'
      ''
      #9'UNION ALL'
      ''
      #9'SELECT'
      #9#9'FB.REHBERID,'
      #9#9'0 AS BORC,'
      #9#9'0 AS ALACAK,'
      
        #9#9'CASE WHEN FB.EKSTREDEKULLAN = 1 THEN FB.DOVIZ_CINSI ELSE FB.KU' +
        'R END AS KUR,'
      #9#9'0 AS TAKIPTE,'
      
        #9#9'CAST(SUM(CASE WHEN FB.EKSTREDEKULLAN = 1 THEN CASE WHEN F.DOVI' +
        'Z_KURU <> '#39'TL'#39' THEN F.DOVIZ_BIRIMFIYAT * (1 - ISKONTO / 100.0) *' +
        ' (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * (1 + ISNULL(F.KDV, 10) /' +
        ' 100.0) ELSE ((F.ISKONTOLUBRMFIYAT * (F.ADET - ISNULL(F1.FATURA_' +
        'ADET, 0)) * (1 + ISNULL(F.KDV, 10) / 100.0)))/FB.DOVIZKUR END EL' +
        'SE F.ISKONTOLUBRMFIYAT * (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * ' +
        '(1 + ISNULL(F.KDV, 10) / 100.0) END) AS DECIMAL(18,2)) AS IRSALI' +
        'YE'
      #9'FROM'
      #9#9'FATBASLIK FB'
      #9#9'INNER JOIN FATURA F ON F.FATBASID = FB.ID'
      
        #9#9'LEFT JOIN (SELECT YERID, SUM(ADET) AS FATURA_ADET FROM FATURA ' +
        'WHERE YERI IN (411,424) GROUP BY YERID ) F1 ON F1.YERID = F.ID'
      #9'WHERE'
      #9#9'ISNULL(FB.DURUM, 0) <> 6'
      #9#9'AND FB.TUR = 14'
      #9'GROUP BY'
      #9#9'FB.REHBERID, FB.EKSTREDEKULLAN,FB.DOVIZ_CINSI,FB.KUR'
      ''
      #9'UNION ALL'
      ''
      #9#9'SELECT REHBERID,'
      #9#9'0 AS BORC,'
      
        #9#9'SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA' +
        '_TUTARI END) AS FATURA_ALACAK, -- al'#305'nan fatura BORCA YAZ'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KU' +
        'R,'
      #9#9'TAKIPTE = 0,'
      #9#9'IRSALIYE = 0'
      #9#9'FROM FATBASLIK F'
      
        #9#9'WHERE  isnull(F.DURUM,0)<>6 and (F.TUR in (8,11,12,13)) AND FA' +
        'TURATARIH >= @BASTARIH'
      
        #9#9'GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINS' +
        'I else KUR end'
      ''
      #9'UNION ALL'
      ''
      #9#9'SELECT REHBERID,'
      
        #9#9'SUM(case when ISNULL(K.BORC,0)>0 and EKSTREDEKULLAN=1 then K.D' +
        'OVIZ_TUTARI else K.BORC end) AS  BORC,'
      
        #9#9'SUM(case when ISNULL(K.ALACAK,0)>0 and EKSTREDEKULLAN=1 then K' +
        '.DOVIZ_TUTARI else K.ALACAK end) AS ALACAK,'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1  THEN DOVIZ_KURU else KUR end as KU' +
        'R,'
      #9#9'TAKIPTE = 0,'
      #9#9'IRSALIYE = 0'
      #9#9'FROM KASA K'
      #9#9'WHERE TUR not between 60 and 79  AND ISLEMTARIHI >= @BASTARIH'
      
        #9#9'GROUP BY K.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU' +
        ' else KUR end'
      ''
      #9'UNION ALL'
      #9#9'SELECT CH.REHBERID,'
      
        #9#9' BORC  = sum(Case when CH.ISLEM in(140,131,132,133,134,137) th' +
        'en (case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TU' +
        'TAR,0)end) else 0 end),'
      
        #9#9'ALACAK= sum(Case when CH.ISLEM in(130,141) then (case when CH.' +
        'EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TUTAR,0)end) else 0' +
        ' end),'
      
        #9#9' KUR   = case when CH.EKSTREDEKULLAN=1 then CH.KUR else isnull' +
        '(C.KUR,'#39'TL'#39')end,'
      '        TAKIPTE = 0,'
      #9#9'IRSALIYE = 0'
      
        #9#9'FROM CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERI' +
        'D'
      
        #9#9'WHERE CH.ISLEM in(130,131,132,134,137,140,141) and CH.TARIH >=' +
        ' @BASTARIH'
      
        #9#9'GROUP BY CH.REHBERID,CH.ISLEM,CH.EKSTREDEKULLAN,case when CH.E' +
        'KSTREDEKULLAN=1 then CH.KUR else isnull(C.KUR,'#39'TL'#39')end'
      '       --A'#231#305'k '#231'ek ve senetler'
      '       UNION ALL'
      '             SELECT C.REHBERID,'
      '             BORC  = 0,'
      '             ALACAK= 0,'
      
        '              KUR   = case when C.EKSTREDEKULLAN=1 then C.DOVIZ_' +
        'KURU else isnull(C.KUR,'#39'TL'#39') end,'
      
        '             TAKIPTE = SUM(Case when C.TUR in(131,132,133,134,13' +
        '7) then (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else i' +
        'snull(C.TUTAR,0)end) else 0 end)-sum(Case when C.TUR in(130) the' +
        'n (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(' +
        'C.TUTAR,0)end) else 0 end),'
      #9#9#9' IRSALIYE = 0'
      '             FROM CEKLER C'
      '             WHERE'
      #9#9#9#9'C.CEKSENET IN (101,121)'
      #9#9#9#9'AND C.TUR IN (130,131,132,133,134,135,138)'
      
        #9#9#9#9'AND EXISTS(SELECT * FROM CEKHAREKET CH WHERE CH.CEKSENETLERI' +
        'D = C.ID)'
      
        '             GROUP BY C.REHBERID,C.EKSTREDEKULLAN,C.DOVIZ_KURU,i' +
        'snull(C.KUR,'#39'TL'#39')'
      #9'UNION ALL'
      ''
      #9#9'SELECT REHBERID,'
      #9#9'0 AS BORC,'
      
        #9#9'SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TUTARI ELSE TUTAR ' +
        'END) AS ALACAK,'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as K' +
        'UR,'
      #9#9'TAKIPTE = 0,'
      #9#9'IRSALIYE = 0'
      #9#9'FROM SENETLER S'
      #9#9'WHERE TUR = 24   AND TARIH >= @BASTARIH'
      
        #9#9'GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KU' +
        'RU else KUR END'
      ''
      #9'UNION ALL'
      ''
      
        #9#9'SELECT REHBERID,SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TU' +
        'TARI ELSE TUTAR END) AS'
      #9#9'BORC,0 AS ALACAK,'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as K' +
        'UR,'
      #9#9'TAKIPTE = 0,'
      #9#9'IRSALIYE = 0'
      #9#9'FROM SENETLER S'
      #9#9'WHERE TUR = 34  AND TARIH >= @BASTARIH'
      
        #9#9'GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KU' +
        'RU else KUR end'
      ''
      #9') as asd'
      #9'group by REHBERID,KUR'
      ') AS DSA'
      #9'INNER JOIN REHBER R ON '#9'DSA.REHBERID=R.ID'
      ''
      ''
      '')
    Properties.WordWrap = False
    TabOrder = 5
    Visible = False
    Height = 20
    Width = 743
  end
  object cxMemo1: TcxMemo
    Left = 201
    Top = 220
    Lines.Strings = (
      'DECLARE @ILGILIARAMA INT'
      ''
      'SET @ILGILIARAMA = :P1'
      ''
      'select <Param> from '
      '    REHBER R '
      '          left outer join REHBER P on R.ID = P.BAGID and  '
      '          1 = CASE WHEN  @ILGILIARAMA = 1 THEN 1'
      #9#9#9#9'   WHEN  @ILGILIARAMA = 0 AND isnull (P.STATU,1) = 1 THEN 1 '
      #9#9'       ELSE 0 END '
      '')
    Properties.WordWrap = False
    TabOrder = 6
    Visible = False
    Height = 59
    Width = 556
  end
  object cxMemo2: TcxMemo
    Left = 98
    Top = 164
    Lines.Strings = (
      '--orj'
      'declare @BASTARIH datetime;'
      'DECLARE @ILGILIARAMA INT'
      'SET @ILGILIARAMA =:P1'
      
        'SET @BASTARIH =convert(varchar(4),Year(Getdate()))+'#39'-01-01 00:00' +
        ':00'#39
      'select <Param>'
      ' FROM('
      '    select'
      
        #9#9'REHBERID,TOPLAM_BORC= SUM(isnull(BORC,0)), TOPLAM_ALACAK= SUM(' +
        'isnull(ALACAK,0)),TAKIPTE = SUM(ISNULL(TAKIPTE,0)),KUR=isnull(KU' +
        'R,'#39'TL'#39')'
      #9'from ('
      #9'   SELECT'
      #9#9'REHBERID,'
      
        #9#9'SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA' +
        '_TUTARI END) AS BORC,'
      #9#9'0 AS ALACAK,'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KU' +
        'R,'
      '        TAKIPTE = 0'
      
        #9#9'--KUR = case when EKSTREDEKULLAN=1 then DOVIZ_CINSI else KUR e' +
        'nd,'
      #9#9'FROM FATBASLIK F'
      
        #9#9'WHERE  isnull(F.DURUM,0)<>6 and (F.TUR in (15,16,17)) AND FATU' +
        'RATARIH >= @BASTARIH'
      
        #9#9'GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINS' +
        'I else KUR end'
      ''
      #9'UNION ALL'
      ''
      #9#9'SELECT REHBERID,'
      #9#9'0 AS BORC,'
      
        #9#9'SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA' +
        '_TUTARI END) AS FATURA_ALACAK, -- al'#305'nan fatura BORCA YAZ'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KU' +
        'R,'
      #9#9'TAKIPTE = 0'
      #9#9'FROM FATBASLIK F'
      
        #9#9'WHERE  isnull(F.DURUM,0)<>6 and (F.TUR in (8,11,12,13)) AND FA' +
        'TURATARIH >= @BASTARIH'
      
        #9#9'GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINS' +
        'I else KUR end'
      ''
      #9'UNION ALL'
      ''
      #9#9'SELECT REHBERID,'
      
        #9#9'SUM(case when ISNULL(K.BORC,0)>0 and EKSTREDEKULLAN=1 then K.D' +
        'OVIZ_TUTARI else K.BORC end) AS  BORC,'
      
        #9#9'SUM(case when ISNULL(K.ALACAK,0)>0 and EKSTREDEKULLAN=1 then K' +
        '.DOVIZ_TUTARI else K.ALACAK end) AS ALACAK,'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1  THEN DOVIZ_KURU else KUR end as KU' +
        'R,'
      #9#9'TAKIPTE = 0'
      #9#9'FROM KASA K'
      #9#9'WHERE TUR not between 60 and 79  AND ISLEMTARIHI >= @BASTARIH'
      
        #9#9'GROUP BY K.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU' +
        ' else KUR end'
      ''
      #9'UNION ALL'
      #9#9'SELECT CH.REHBERID,'
      
        #9#9' BORC  = sum(Case when CH.ISLEM in(140,131,132,133,134,137) th' +
        'en (case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TU' +
        'TAR,0)end) else 0 end),'
      
        #9#9'ALACAK= sum(Case when CH.ISLEM in(130,141) then (case when CH.' +
        'EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TUTAR,0)end) else 0' +
        ' end),'
      
        #9#9' KUR   = case when CH.EKSTREDEKULLAN=1 then CH.KUR else isnull' +
        '(C.KUR,'#39'TL'#39')end,'
      '        TAKIPTE = 0'
      
        #9#9'FROM CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERI' +
        'D'
      
        #9#9'WHERE CH.ISLEM in(130,131,132,134,137,140,141) and CH.TARIH >=' +
        ' @BASTARIH'
      
        #9#9'GROUP BY CH.REHBERID,CH.ISLEM,CH.EKSTREDEKULLAN,case when CH.E' +
        'KSTREDEKULLAN=1 then CH.KUR else isnull(C.KUR,'#39'TL'#39')end'
      '       --A'#231#305'k '#231'ek ve senetler'
      '       UNION ALL'
      '             SELECT C.REHBERID,'
      '             BORC  = 0,'
      '             ALACAK= 0,         '
      
        '              KUR   = case when C.EKSTREDEKULLAN=1 then C.DOVIZ_' +
        'KURU else isnull(C.KUR,'#39'TL'#39') end,'
      
        '             TAKIPTE = SUM(Case when C.TUR in(131,132,133,134,13' +
        '7) then (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else i' +
        'snull(C.TUTAR,0)end) else 0 end)-sum(Case when C.TUR in(130) the' +
        'n (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(' +
        'C.TUTAR,0)end) else 0 end)'
      '             FROM CEKLER C'
      '             WHERE '
      #9#9#9#9'C.CEKSENET IN (101,121) '
      #9#9#9#9'AND C.TUR IN (130,131,132,133,134,135,138)'
      
        #9#9#9#9'AND EXISTS(SELECT * FROM CEKHAREKET CH WHERE CH.CEKSENETLERI' +
        'D = C.ID)'
      
        '             GROUP BY C.REHBERID,C.EKSTREDEKULLAN,C.DOVIZ_KURU,i' +
        'snull(C.KUR,'#39'TL'#39')'
      #9'UNION ALL'
      ''
      #9#9'SELECT REHBERID,'
      #9#9'0 AS BORC,'
      
        #9#9'SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TUTARI ELSE TUTAR ' +
        'END) AS ALACAK,'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as K' +
        'UR,'
      #9#9'TAKIPTE = 0'
      #9#9'FROM SENETLER S'
      #9#9'WHERE TUR = 24   AND TARIH >= @BASTARIH'
      
        #9#9'GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KU' +
        'RU else KUR END'
      ''
      #9'UNION ALL'
      ''
      
        #9#9'SELECT REHBERID,SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TU' +
        'TARI ELSE TUTAR END) AS'
      #9#9'BORC,0 AS ALACAK,'
      
        #9#9'CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as K' +
        'UR,'
      #9#9'TAKIPTE = 0'
      #9#9'FROM SENETLER S'
      #9#9'WHERE TUR = 34  AND TARIH >= @BASTARIH'
      
        #9#9'GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KU' +
        'RU else KUR end'
      ''
      #9#9') as asd'
      #9'group by REHBERID,KUR) AS DSA'
      ' INNER JOIN REHBER R ON '#9'DSA.REHBERID=R.ID'
      'LEFT OUTER JOIN '#9'REHBER P on R.ID = P.BAGID and'
      #9#9'( 1 = CASE WHEN  @ILGILIARAMA = 1 THEN 1'
      
        #9#9#9#9'   WHEN  @ILGILIARAMA = 0 AND isnull (P.STATU,1) = 1 THEN 1 ' +
        'ELSE 0'
      #9#9#9#9'   END  )'
      '')
    Properties.WordWrap = False
    TabOrder = 7
    Visible = False
    Height = 26
    Width = 743
  end
  object REHBER: TFDQuery
    BeforeOpen = REHBERBeforeOpen
    AfterOpen = REHBERAfterOpen
    Connection = Tablo.FDCnn
    Left = 26
    Top = 121
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 114
    Top = 117
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWindow
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
  end
  object TabTicari: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SIRA,ETIKET,BILGI from REHBERBILGI'
      'where YERI=2 and YER_ID= :RehberId   '
      'order by 1   ')
    Left = 236
    Top = 87
    ParamData = <
      item
        Name = 'RehberId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsTicari: TDataSource
    DataSet = TabTicari
    Left = 239
    Top = 183
  end
  object TabFirIletisim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SIRA,ETIKET,BILGI from REHBERBILGI'
      'where YERI= 1  and YER_ID= :UstId   '
      'order by 1   ')
    Left = 424
    Top = 133
    ParamData = <
      item
        Name = 'UstId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabRehberIlgili: TFDQuery
    AfterOpen = TabRehberIlgiliAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @RehID int, @String nvarchar(50)'
      'set @RehID= :REHBERID '
      'set @String= :PADSOYAD'
      'SELECT '
      'top 200 '
      'ID,BAGID,FIRMA,'
      'GOREVI=(select top 1  RB.BILGI from REHBERBILGI RB'
      
        'INNER JOIN REHBERAYAR RA (nolock) ON RA.ETIKET=RB.ETIKET AND RA.' +
        'YERI=RB.YERI '
      
        'WHERE RA.YERI=1 and RA.VARSAYILAN=175 and RB.YER_ID=(select top ' +
        '1 ID from REHBERILETISIM where REHBERID = RP.ID)),'
      ''
      'ILETISIMI=(select top 1  RB.BILGI from REHBERBILGI RB'
      
        'INNER JOIN REHBERAYAR RA (nolock) ON RA.ETIKET=RB.ETIKET AND RA.' +
        'YERI=RB.YERI '
      
        'WHERE RA.YERI=1 and RA.VARSAYILAN=88 and RB.YER_ID=(select top 1' +
        ' ID from REHBERILETISIM where REHBERID = RP.ID)),'
      ''
      
        'STATU,NOTLAR,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI,DU' +
        'RUM,SUBEID'
      ''
      #9
      'FROM '
      #9'REHBER RP'
      'WHERE  '
      'GRUP=334'
      'and  BAGID = @RehID'
      ' and (FIRMA like @String)'
      ' Order by STATU  desc'
      ''
      ''
      '')
    Left = 268
    Top = 212
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1077
      end
      item
        Name = 'PADSOYAD'
        DataType = ftWideString
        Size = 4
        Value = '%%'
      end>
  end
  object TabRehberOdeme: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from REHBERODEME where REHBERID = :REHBERID')
    Left = 588
    Top = 96
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabPerIletisim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select SIRA,ETIKET,BILGI from REHBERBILGI'
      
        'where YERI= 1  and YER_ID=(select top 1 ID from REHBERILETISIM w' +
        'here REHBERID =  :UstId)   '
      'order by 1   ')
    Left = 251
    Top = 243
    ParamData = <
      item
        Name = 'UstId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabProjeler: TFDQuery
    BeforeOpen = TabProjelerBeforeOpen
    AfterOpen = TabProjelerAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select P.ID,P.REHBERID,P.PROJEKODU,P.PROJEADI,Firma.FIRMA, BASLA' +
        'MATARIHI,TURU,KONUSU,ASAMA,LISTEFIYATI,LISTEKUR,SATISFIYATI,SATI' +
        'SKUR,'
      
        'PRJ_SORUMLUSU_ID,PRJ_ASAMA_SORUMLUSU_ID,ProjeSorumlu.FIRMA as PR' +
        'J_SORUMLUAD, AsamaSorumlu.FIRMA as PRJ_ASAMASORUMLUAD, '
      'RehberIlgili.ADSOYAD, P.DURUM,P.NOTLAR , BITISTARIHI ,'
      
        'ProjeTuru.ANAHTAR PROJETURU, ProjeAsama.ANAHTAR PROJEASAMA, Proj' +
        'eDurum.ANAHTAR PROJEDURUM'
      'from PROJELER P '
      #9'INNER JOIN REHBER Firma on Firma.ID = P.REHBERID'
      
        #9'INNER JOIN REHBER ProjeSorumlu on ProjeSorumlu.ID = P.PRJ_SORUM' +
        'LUSU_ID'
      
        #9'LEFT OUTER JOIN REHBER AsamaSorumlu on AsamaSorumlu.ID=P.PRJ_AS' +
        'AMA_SORUMLUSU_ID'
      
        #9'LEFT OUTER JOIN REHBERPERSONEL RehberIlgili on RehberIlgili.ID=' +
        'P.ILGILI'
      
        #9'LEFT OUTER JOIN REHBERINI ProjeTuru ON ProjeTuru.DEGER = P.TURU' +
        ' AND ProjeTuru.BOLUM ='#39'Proje_T'#252'r'#252#39
      
        #9'LEFT OUTER JOIN REHBERINI ProjeAsama ON ProjeAsama.DEGER = P.AS' +
        'AMA AND ProjeAsama.BOLUM ='#39'Proje_A'#351'ama'#39
      
        #9'LEFT OUTER JOIN REHBERINI ProjeDurum ON ProjeDurum.DEGER = P.DU' +
        'RUM AND ProjeDurum.BOLUM ='#39'Proje_Durum'#39
      'WHERE '
      'P.REHBERID = :PID'
      'AND MODUL = 11'
      'AND P.DURUM = 1'#9
      'ORDER BY BITISTARIHI DESC')
    Left = 561
    Top = 194
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabBankaHesaplar: TFDQuery
    AfterOpen = TabBankaHesaplarAfterOpen
    AfterPost = TabBankaHesaplarAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      
        '   BH.ID,VARSAYILAN, BS.BANKAKODU, BANKAADI,SUBEKODU,SUBEADI,LOG' +
        'O,HESAPNO,HESAPADI,IBAN,KUR,TIPI,HESAPACIKLAMA,DURUM'
      'FROM '
      #9'BANKAHESAPLAR BH '
      #9'left join BANKASUBELER BS on BS.ID = BH.BANKASUBELERID'
      #9'left join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'WHERE '
      #9'REHBERID  = :REHBERID'
      '')
    Left = 760
    Top = 84
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 4702
      end>
  end
  object DtsRehberIlgili: TDataSource
    DataSet = TabRehberIlgili
    Left = 503
    Top = 172
  end
  object DtsBankaHesaplar: TDataSource
    DataSet = TabBankaHesaplar
    OnStateChange = DtsBankaHesaplarStateChange
    Left = 712
    Top = 115
  end
  object DtsPerIletisim: TDataSource
    DataSet = TabPerIletisim
    Left = 287
    Top = 192
  end
  object DtsRehberOdeme: TDataSource
    DataSet = TabRehberOdeme
    Left = 787
    Top = 20
  end
  object DtsProjeler: TDataSource
    DataSet = TabProjeler
    Left = 585
    Top = 244
  end
  object DtsRehber: TDataSource
    DataSet = REHBER
    Left = 195
    Top = 91
  end
  object frxSozlesme: TfrxDBDataset
    UserName = 'SOZLESME'
    CloseDataSource = False
    DataSet = TabProjeler
    BCDToCurrency = False
    DataSetOptions = []
    Left = 666
    Top = 14
  end
  object frxGorusme: TfrxDBDataset
    UserName = 'GORUSME'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 608
    Top = 14
  end
  object frxIlgili: TfrxDBDataset
    UserName = 'ILGILI'
    CloseDataSource = False
    DataSet = TabRehberIlgili
    BCDToCurrency = False
    DataSetOptions = []
    Left = 563
    Top = 14
  end
  object frxREHBER: TfrxDBDataset
    UserName = 'REHBER'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 514
    Top = 22
  end
  object frxBanka: TfrxDBDataset
    UserName = 'BANKA'
    CloseDataSource = False
    DataSet = TabBankaHesaplar
    BCDToCurrency = False
    DataSetOptions = []
    Left = 415
    Top = 41
  end
  object frxSozBelge: TfrxDBDataset
    UserName = 'SOZBELGE'
    CloseDataSource = False
    DataSet = TabPerIletisim
    BCDToCurrency = False
    DataSetOptions = []
    Left = 416
    Top = 79
  end
  object TabUcret: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select ETIKET,TUTAR,KUR, SIRA  from PLANMAAS where '
      'YER=0 and YERID=:REHID  order by SIRA')
    Left = 341
    Top = 132
    ParamData = <
      item
        Name = 'REHID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsUcret: TDataSource
    DataSet = TabUcret
    Left = 343
    Top = 186
  end
  object DtsFirIletisim: TDataSource
    DataSet = TabFirIletisim
    Left = 424
    Top = 174
  end
  object PopupMenuYaz: TPopupMenu
    Left = 13
    Top = 189
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
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = TabCariListe
    BCDToCurrency = False
    DataSetOptions = []
    Left = 372
    Top = 194
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = CariGrid
    PopupMenus = <>
    Left = 741
    Top = 172
  end
  object TabCariListe: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from dbo.fn_Cari_Detayli_Ekstre(1,getdate()-100.0,getda' +
        'te())')
    Left = 628
    Top = 199
  end
  object DtsCariListe: TDataSource
    DataSet = TabCariListe
    Left = 621
    Top = 254
  end
  object PopupMenuREHBER: TPopupMenu
    OwnerDraw = True
    OnPopup = PopupMenuREHBERPopup
    Left = 65
    Top = 58
    object info1: TMenuItem
      Caption = 'info'
      OnClick = info1Click
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object EkleMenu: TMenuItem
      Caption = 'Yeni'
      OnClick = YeniTusClick
    end
    object SilMenu: TMenuItem
      Caption = 'Sil'
      OnClick = SilTusClick
    end
    object GorMenu: TMenuItem
      Caption = 'D'#252'zenle'
      OnClick = DegisTusClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object BorcAlacakKapamaMenu: TMenuItem
      Caption = 'Bor'#231'/Alacak Kapama'
      OnClick = FaturaKapatma1Click
    end
    object N18: TMenuItem
      Caption = '-'
    end
    object AcilisiFisiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      OnClick = AcilisiFisiMenuClick
    end
    object DevirFisiMenu: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir'
      OnClick = AcilisiFisiMenuClick
    end
    object N21: TMenuItem
      Caption = '-'
    end
    object PotansiyelListesineGnderMenu: TMenuItem
      Caption = 'Potansiyel Listesine G'#246'nder'
      OnClick = PotansiyelListesineGonderMenuClick
    end
    object MusteriListesineGonderMenu: TMenuItem
      Caption = 'M'#252#351'teri Listesine G'#246'nder'
      OnClick = MusteriListesineEkleMenuClick
    end
    object N19: TMenuItem
      Caption = '-'
    end
    object ExceldenVeriAlMenu: TMenuItem
      Caption = 'Excelden Veri Al'
      OnClick = ExceldenVeriAlMenuClick
    end
    object ExcelKolonAyarlar1: TMenuItem
      Caption = 'Excel Kolon Ayarlar'#305
      Visible = False
      OnClick = ExcelKolonAyarlar1Click
    end
  end
  object PopupMenuYeni: TPopupMenu
    OwnerDraw = True
    OnPopup = PopupMenuYeniPopup
    Left = 107
    Top = 190
    object MusteriListesineEkleMenu: TMenuItem
      Caption = 'Cari Listesine G'#246'nder'
      OnClick = MusteriListesineEkleMenuClick
    end
    object AlisBelgesiMenu: TMenuItem
      Caption = 'Al'#305#351' Belgesi'
      object Fatura1: TMenuItem
        Tag = 11
        Caption = 'Fatura'
        object FaturaAlisMenu: TMenuItem
          Tag = 111
          Caption = 'Al'#305#351' '
          OnClick = Fatura1Click
        end
        object ade1: TMenuItem
          Tag = 112
          Caption = #304'ade'
          OnClick = Fatura1Click
        end
        object FiyatFark1: TMenuItem
          Tag = 113
          Caption = 'Fiyat Fark'#305
          OnClick = Fatura1Click
        end
        object SerbestMeslekMekabuzu1: TMenuItem
          Tag = 114
          Caption = 'Stopaj'
          object SerbestMeslekMakbuzuMenu: TMenuItem
            Tag = 4
            Caption = 'Serbest Meslek Makbuzu'
            OnClick = Fatura1Click
          end
          object KiraMenu: TMenuItem
            Tag = 7
            Caption = 'Kira'
            OnClick = Fatura1Click
          end
          object GiderPusulasiMenu: TMenuItem
            Tag = 8
            Caption = 'Gider Pusulas'#305
            OnClick = Fatura1Click
          end
        end
        object KurFark1: TMenuItem
          Tag = 115
          Caption = 'Kur Fark'#305
          OnClick = Fatura1Click
        end
        object AlisCizgiMenu: TMenuItem
          Caption = '-'
        end
        object AlisEFaturaMenu: TMenuItem
          Tag = -111
          Caption = 'E-Fatura'
          OnClick = Fatura1Click
        end
      end
      object Fi1: TMenuItem
        Tag = 12
        Caption = 'Fi'#351
        OnClick = Fatura1Click
      end
      object rsaliye1: TMenuItem
        Tag = 10
        Caption = #304'rsaliye'
        OnClick = Fatura1Click
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object ahakkuk1: TMenuItem
        Tag = 13
        Caption = 'Tahakkuk'
        OnClick = Fatura1Click
      end
      object Sipari2: TMenuItem
        Tag = 9
        Caption = 'Sipari'#351
        OnClick = Fatura1Click
      end
    end
    object SatisBelgesiMenu: TMenuItem
      Caption = 'Sat'#305#351' belgesi'
      object Fatura2: TMenuItem
        Tag = 15
        Caption = 'Fatura'
        object FaturaSatisMenu: TMenuItem
          Tag = 151
          Caption = 'Sat'#305#351
          OnClick = Fatura1Click
        end
        object ade2: TMenuItem
          Tag = 152
          Caption = #304'ade'
          OnClick = Fatura1Click
        end
        object FiyatFark2: TMenuItem
          Tag = 153
          Caption = 'Fiyat Fark'#305
          OnClick = Fatura1Click
        end
        object KurFark2: TMenuItem
          Tag = 155
          Caption = 'Kur Fark'#305
          OnClick = Fatura1Click
        end
        object SatisCizgiMenu: TMenuItem
          Caption = '-'
        end
        object SatisEFaturaMenu: TMenuItem
          Tag = -151
          Caption = 'E-Fatura'
          OnClick = Fatura1Click
        end
      end
      object Fi2: TMenuItem
        Tag = 16
        Caption = 'Fi'#351
        OnClick = Fatura1Click
      end
      object rsaliye2: TMenuItem
        Tag = 14
        Caption = #304'rsaliye'
        OnClick = Fatura1Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object ahakkuk2: TMenuItem
        Tag = 17
        Caption = 'Tahakkuk'
        OnClick = Fatura1Click
      end
      object Sipari1: TMenuItem
        Tag = 19
        Caption = 'Sipari'#351
        OnClick = Fatura1Click
      end
    end
    object AcilisFisiGirMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      OnClick = AcilisiFisiMenuClick
    end
    object MutabakatKaydiEkleMenu: TMenuItem
      Caption = 'Mutabakat Kayd'#305' Ekle'
      OnClick = MutabakatKaydiEkleMenuClick
    end
    object MenuItem4: TMenuItem
      Caption = '-'
    end
    object CariTahsilatMenu: TMenuItem
      Caption = 'Cari Tahsilat'
      object Nakit1: TMenuItem
        Tag = 21
        Caption = 'Nakit'
        OnClick = Fatura1Click
      end
      object HavaleEFT1: TMenuItem
        Tag = 22
        Caption = 'Havale / EFT'
        OnClick = Fatura1Click
      end
      object POSTahsilMenu: TMenuItem
        Tag = 25
        Caption = 'POS'
        OnClick = Fatura1Click
      end
      object KrediKartndanade1: TMenuItem
        Tag = 350
        Caption = 'Kredi Kart'#305'na '#304'ade'
        OnClick = Fatura1Click
      end
      object CekTahsilMenu: TMenuItem
        Tag = 101
        Caption = #199'ek'
        OnClick = Fatura1Click
      end
      object SenetTahsilMenu: TMenuItem
        Tag = 121
        Caption = 'Senet'
        object SenetCokluPlanlamaMenu: TMenuItem
          Tag = 161
          Caption = #199'oklu Planlama'
          OnClick = Fatura1Click
        end
        object TekSenetEkranMenu: TMenuItem
          Tag = 121
          Caption = 'Tek Senet Ekran'#305
          OnClick = Fatura1Click
        end
      end
      object Dier1: TMenuItem
        Caption = 'Di'#287'er'
        object Hediyeeki1: TMenuItem
          Tag = 28
          Caption = 'Hediye '#199'eki'
          OnClick = Fatura1Click
        end
        object adeeki1: TMenuItem
          Tag = 29
          Caption = #304'ade '#199'eki'
          OnClick = Fatura1Click
        end
        object Kupon1: TMenuItem
          Tag = 26
          Caption = 'Kupon'
          OnClick = Fatura1Click
        end
      end
    end
    object CariOdemeMenu: TMenuItem
      Caption = 'Cari '#214'deme'
      object Nakit2: TMenuItem
        Tag = 31
        Caption = 'Nakit'
        OnClick = Fatura1Click
      end
      object HavaleEFT2: TMenuItem
        Tag = 32
        Caption = 'Havale / EFT'
        OnClick = Fatura1Click
      end
      object KrediKartiOdeMenu: TMenuItem
        Tag = 35
        Caption = 'Kredi Kart'#305
        OnClick = Fatura1Click
      end
      object POSOdeMenu: TMenuItem
        Tag = 125
        Caption = 'POS'
        OnClick = Fatura1Click
      end
      object CekOdeMenu: TMenuItem
        Tag = 103
        Caption = #199'ek'
        OnClick = Fatura1Click
      end
      object SenetOdeMenu: TMenuItem
        Tag = 321
        Caption = 'Senet'
        OnClick = Fatura1Click
      end
      object Dier2: TMenuItem
        Caption = 'Di'#287'er'
        object Hediyeeki2: TMenuItem
          Tag = 38
          Caption = 'Hediye '#199'eki'
          OnClick = Fatura1Click
        end
        object adeeki2: TMenuItem
          Tag = 39
          Caption = #304'ade '#199'eki'
          OnClick = Fatura1Click
        end
        object Kupon2: TMenuItem
          Tag = 36
          Caption = 'Kupon'
          OnClick = Fatura1Click
        end
      end
    end
    object CarilerArasTransfer1: TMenuItem
      Tag = 49
      Caption = 'Cariler Aras'#305' Transfer'
      OnClick = Fatura1Click
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object MasrafOdemeMenu: TMenuItem
      Caption = 'Masraf '#214'deme'
      object MasrafNakitMenu: TMenuItem
        Tag = 31
        Caption = 'Nakit'
        OnClick = MasrafNakitMenuClick
      end
      object HavaleEFT4: TMenuItem
        Tag = 32
        Caption = 'Havale / EFT'
        OnClick = MasrafNakitMenuClick
      end
      object KrediKart1: TMenuItem
        Tag = 35
        Caption = 'Kredi Kart'#305
        OnClick = MasrafNakitMenuClick
      end
    end
    object GelirTahsilatMenu: TMenuItem
      Caption = 'Gelir Tahsilat'
      object Nakit5: TMenuItem
        Tag = 21
        Break = mbBarBreak
        Caption = 'Nakit'
        OnClick = MasrafNakitMenuClick
      end
      object HavaleEFT5: TMenuItem
        Tag = 22
        Caption = 'Havale / EFT'
        OnClick = MasrafNakitMenuClick
      end
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object TahsilatPlanMenu: TMenuItem
      Tag = 61
      Caption = 'Tahsilat Plan'#305
      OnClick = Fatura1Click
    end
    object OdemePlanMenu: TMenuItem
      Tag = 71
      Caption = #214'deme Plan'#305
      OnClick = Fatura1Click
    end
    object N20: TMenuItem
      Caption = '-'
    end
    object PotansiyelListesineGonderMenu: TMenuItem
      Caption = 'Potansiyel Listesine G'#246'nder'
      OnClick = PotansiyelListesineGonderMenuClick
    end
  end
  object TabDemirbasBilgi: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT    D.*, S.STOKADI, L.ACIKLAMA  As LOKASYONADI, R.FIRMA AS' +
        ' PERSONEL,DD.ANAHTAR AS DURUMADI, DU.STOKADI AS KATEGORIADI, SM.' +
        'ANAHTAR AS MARKAADI'
      'FROM         DEMIRBAS AS D LEFT OUTER JOIN'
      
        '                      STOKLAR AS S ON D.STOKID = S.ID LEFT OUTER' +
        ' JOIN '
      
        '                                             (SELECT     ANAHTAR' +
        ', DEGER'
      '                            FROM          REHBERINI'
      
        '                            WHERE      (BOLUM = '#39'Demirbas_Durum'#39 +
        ')) AS DD ON D.DURUM = DD.DEGER  LEFT OUTER JOIN'
      
        '                             DEMIRBAS_URUN AS DU ON DU.ID=D.KATE' +
        'GORIID  LEFT OUTER JOIN'
      
        '                             LOKASYON AS L ON L.ID=D.LOKASYONID ' +
        'LEFT OUTER JOIN'
      
        '                                              (SELECT     ANAHTA' +
        'R, DEGER'
      '                            FROM          REHBERINI'
      
        '                            WHERE      (BOLUM = '#39'StokKart_Marka'#39 +
        ')) AS SM ON D.MARKA = SM.DEGER LEFT OUTER JOIN'
      
        '                      REHBER AS R ON R.ID = D.ZIMMETLIPERSONELID' +
        ' '
      'where D.ZIMMETLIPERSONELID=:P1')
    Left = 437
    Top = 283
    ParamData = <
      item
        Name = 'P1'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsDemirbasBilgi: TDataSource
    DataSet = TabDemirbasBilgi
    Left = 623
    Top = 323
  end
  object PMAksiyonlarMenu: TPopupMenu
    OnPopup = PMAksiyonlarMenuPopup
    Left = 331
    Top = 372
    object Sil1: TMenuItem
      Caption = 'Aksiyon Sil'
      OnClick = Sil1Click
    end
    object AksiyonBilgisiniGorMenu: TMenuItem
      Caption = 'Aksiyon Bilgisini G'#246'r'
      OnClick = AksiyonBilgisiniGorMenuClick
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object OdemeTahsilatYapMenu: TMenuItem
      Caption = #214'deme / Tahsilat Yap'
      OnClick = OdemeTahsilatYapMenuClick
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object ExceldenAksiyonAktar1: TMenuItem
      Caption = 'Excelden Tahakkuk '#304#231'eri Al'
      OnClick = ExceldenAksiyonAktar1Click
    end
    object N4: TMenuItem
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
    object N9: TMenuItem
      Caption = '-'
    end
    object Kopyala2: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala2Click
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object iadeAl: TMenuItem
      Caption = #304'ade Al'
      object Faturaile1: TMenuItem
        Tag = 2
        Caption = 'Fatura ile'
        OnClick = Faturaile1Click
      end
      object GiderPusulasile1: TMenuItem
        Tag = 5
        Caption = 'Gider Pusulas'#305' ile'
        OnClick = Faturaile1Click
      end
    end
  end
  object TabYaslandirma: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'Sp_Prg_CariYaslandirma :PRehberID,:PBittar,:PKur')
    Left = 577
    Top = 434
    ParamData = <
      item
        Name = 'PRehberID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PBittar'
        Size = -1
        Value = Null
      end
      item
        Name = 'PKur'
        Size = -1
        Value = Null
      end>
  end
  object DtsYaslandirma: TDataSource
    DataSet = TabYaslandirma
    Left = 581
    Top = 378
  end
  object PopupIlgililer: TPopupMenu
    Left = 79
    Top = 252
    object lgiliKurumdanAyrld1: TMenuItem
      Tag = 3
      Caption = #304'lgilinin durumunu '#39'Ayr'#305'ld'#305#39' olarak i'#351'aretle'
      ImageIndex = 10
      OnClick = lgiliKurumdanAyrld1Click
    end
    object DurumuSfrla1: TMenuItem
      Tag = 1
      Caption = #304'lgilinin durumunu bo'#351' olarak i'#351'aretle '
      OnClick = lgiliKurumdanAyrld1Click
    end
    object Varsaylan1: TMenuItem
      Caption = 'Varsay'#305'lan Yap'
      OnClick = Varsaylan1Click
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object lgiliyiKopyala1: TMenuItem
      Caption = #304'lgiliyi Kopyala'
      OnClick = lgiliyiKopyala1Click
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object ifreOlutur1: TMenuItem
      Caption = #350'ifre Olu'#351'tur'
      OnClick = ifreOlutur1Click
    end
    object SifreyiEpostaAt: TMenuItem
      Caption = #350'ifreyi EPosta ile g'#246'nder'
      OnClick = SifreyiEpostaAtClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
  end
  object PmProjeAktKopyala: TPopupMenu
    Left = 143
    Top = 240
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala1Click
    end
  end
  object TabTeklifler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select T.*'
      'from TEKLIF T'
      ''
      'where T.REHBERID=:PID')
    Left = 661
    Top = 233
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 216
      end>
  end
  object DtsTeklifler: TDataSource
    DataSet = TabTeklifler
    Left = 663
    Top = 182
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT  ID, YERI, YER_ID,DURUM,ICDIS, BELGENO, BELGEADI, TUR, AC' +
        'IKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'REHBERID=:PRehberID')
    Left = 636
    Top = 410
    ParamData = <
      item
        Name = 'PRehberID'
        Size = -1
        Value = Null
      end>
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 704
    Top = 337
  end
  object OpenDialog1: TOpenDialog
    Left = 647
    Top = 128
  end
  object TabEkipmanlar: TFDQuery
    AfterPost = TabEkipmanlarAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select *,'
      'KOD=(Select KOD FROM EKIPMANLAR E where E.ID=ER.EKIPMANID), '
      'AD=(Select AD FROM EKIPMANLAR E where E.ID=ER.EKIPMANID), '
      
        'SURE=[dbo].[fn_TarihFarkiGunAyYilTextOlarak](GETDATE(),ER.GARANT' +
        'IBITTAR), '
      
        'DETAYBOLUMU=(Select DETAYBOLUMU FROM EKIPMANLAR E where E.ID=ER.' +
        'EKIPMANID)  ,'
      
        'ILGILI=(select RP.FIRMA from REHBER RP where RP.ID=ER.MUS_ILGILI' +
        ' ),'
      
        'LOKASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=ER.LOKASY' +
        'ONID),'
      
        'MARKAAD = (case when ER.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=-2727 and DEGER=ER.MARKA and DIL=-1)'
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=-2701 and ' +
        'DEGER=ER.MARKA and DIL=-1) end) ,'
      
        'MODELAD = (case when ER.SAHIP=0 then (select top 1 ANAHTAR from ' +
        'GENINI where BOLUM=convert(int,'#39'-2727'#39'+convert(varchar(10),ER.MA' +
        'RKA)) and DEGER=ER.MODEL and DIL=-1) '
      
        #9#9#9'else (select top 1 ANAHTAR from GENINI where BOLUM=convert(in' +
        't,'#39'-2701'#39'+convert(varchar(10),ER.MARKA)) and DEGER=ER.MODEL and ' +
        'DIL=-1) end)'
      'from EKIPMANREHBER ER '
      ''
      'Where REHBERID=:PRehId')
    Left = 990
    Top = 99
    ParamData = <
      item
        Name = 'PRehId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object DtsEkipmanlar: TDataSource
    DataSet = TabEkipmanlar
    OnStateChange = DtsEkipmanlarStateChange
    Left = 993
    Top = 142
  end
  object DtsEkipmanEkBilgi: TDataSource
    DataSet = TabEkipmanEkBilgi
    Left = 918
    Top = 154
  end
  object TabEkipmanEkBilgi: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SIRA,ETIKET,BILGI,ID from REHBERBILGI'
      'where YERI=:Yeri_1  and YER_ID= :YerID_2 '
      'order by 1   ')
    Left = 916
    Top = 111
    ParamData = <
      item
        Name = 'Yeri_1'
        Size = -1
        Value = Null
      end
      item
        Name = 'YerID_2'
        Size = -1
        Value = Null
      end>
  end
  object REHBERILETISIM: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9' *'
      'FROM '
      #9'REHBERILETISIM'
      'WHERE  '
      #9'REHBERID = :REHBERID '
      ' Order by VARSAYILAN  desc')
    Left = 577
    Top = 144
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsRehberIletisim: TDataSource
    DataSet = REHBERILETISIM
    Left = 642
    Top = 277
  end
  object PopupIletisim: TPopupMenu
    Left = 243
    Top = 360
    object letiimaddeitir1: TMenuItem
      Caption = #304'leti'#351'im ad'#305' de'#287'i'#351'tir'
      OnClick = letiimaddeitir1Click
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object VarsaylanYap1: TMenuItem
      Caption = 'Varsay'#305'lan Yap'
      OnClick = VarsaylanYap1Click
    end
  end
  object DtsSmsEPosta: TDataSource
    DataSet = TabSmsEPosta
    Left = 936
    Top = 408
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
    Left = 880
    Top = 408
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 464
    Top = 152
  end
  object frxPersonelIzin: TfrxDBDataset
    UserName = 'IZIN'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 412
    Top = 234
  end
  object PopupMenuEkipman: TPopupMenu
    Left = 957
    Top = 281
    object EkimanKopyalaMenu: TMenuItem
      Caption = 'Kopyala'
      OnClick = EkimanKopyalaMenuClick
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object BaskacariyekopyalaMenu: TMenuItem
      Caption = 'Ba'#351'ka cariye kopyala'
      OnClick = EkimanKopyalaMenuClick
    end
  end
  object DtsHareketler: TDataSource
    DataSet = TabHareketler
    Left = 864
    Top = 272
  end
  object TabHareketler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT *  FROM PERS_HAREKET WHERE REHBERID= :REHBERID ORDER BY T' +
        'ARIH DESC')
    Left = 864
    Top = 328
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabKesinti: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'ID,'
      #9'ETIKET,'
      #9'TUTAR,'
      #9'KUR, '
      '                SIRA,'
      #9'TARIH,'
      #9'ACIKLAMA,'
      
        #9'TUR = CASE PM.TUR WHEN '#39'B'#39' THEN '#39'Banka'#39' WHEN '#39'K'#39' THEN '#39'Kasa'#39' EN' +
        'D'
      'FROM'
      #9'PLANMAAS PM'
      'WHERE'
      #9'YER=1 AND PM.YERID=:YERID AND CONVERT(DATETIME,TARIH) >'
      
        ' CONVERT(VARCHAR,DATEPART(YEAR,GETDATE()))+'#39'-'#39'+CONVERT(VARCHAR,D' +
        'ATEPART(MONTH,dateadd(month,-1,GETDATE())))+'#39'-01'#39
      'ORDER BY '
      #9'TARIH')
    Left = 1005
    Top = 204
    ParamData = <
      item
        Name = 'YERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsKesinti: TDataSource
    DataSet = TabKesinti
    Left = 1007
    Top = 250
  end
  object TabGorevler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'exec [dbo].[sp_Prg_IsListesiCariye]  :RehberId, :AcKapa , :GunSa' +
        'y')
    Left = 341
    Top = 245
    ParamData = <
      item
        Name = 'RehberId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 4322
      end
      item
        Name = 'AcKapa'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end
      item
        Name = 'GunSay'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 9999
      end>
  end
  object DtsGorevler: TDataSource
    DataSet = TabGorevler
    Left = 291
    Top = 104
  end
  object GorevlerMenu: TOfficePopupMenu
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 248
    Top = 264
    object DuzenleMenu: TMenuItem
      Caption = 'D'#252'zenle'
      OnClick = DuzenleMenuClick
    end
    object TamamlandiIsaretleMenu: TMenuItem
      Caption = #304#351'aretliler Tamamland'#305' / Tamamlanmad'#305
      OnClick = TamamlandiIsaretleMenuClick
    end
    object Bayraklaretle1: TMenuItem
      Caption = #304#351'aretliler  Bayrakl'#305' / Bayraks'#305'z'
      OnClick = Bayraklaretle1Click
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object TarihBugunMenu: TMenuItem
      Caption = #304#351'aretlilerin Tarihi Bug'#252'n'
    end
    object arihYarn1: TMenuItem
      Tag = 1
      Caption = #304#351'aretlilerin Tarihi Yar'#305'n'
    end
    object TarihiKaldirMenu: TMenuItem
      Tag = -1
      Caption = #304#351'aretlilerin Tarihini Kald'#305'r'
    end
    object MenuItem5: TMenuItem
      Caption = '-'
    end
    object Atamayap1: TMenuItem
      Caption = #304#351'aretlilere Atama yap'
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object BuiiEPostaGnder1: TMenuItem
      Caption = 'Bu i'#351'i E-Posta G'#246'nder'
    end
    object BuiYazdr1: TMenuItem
      Caption = 'Bu '#304#351'i Yazd'#305'r'
    end
    object MenuItem9: TMenuItem
      Caption = '-'
    end
    object IsiKopyalaMenu: TMenuItem
      Caption = #304#351'i Kopyala'
      OnClick = IsiKopyalaMenuClick
    end
    object IsiSilMenu: TMenuItem
      Caption = #304#351'i Sil'
      OnClick = IsiSilMenuClick
    end
  end
  object TabEkipmanRakip: TFDQuery
    OnNewRecord = TabEkipmanRakipNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select * from EKIPMANRAKIP'
      ''
      'where REHBERID=:PRehberID')
    Left = 846
    Top = 83
    ParamData = <
      item
        Name = 'PRehberID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object DtsEkipmanRakip: TDataSource
    DataSet = TabEkipmanRakip
    OnStateChange = DtsEkipmanRakipStateChange
    Left = 841
    Top = 142
  end
  object frxYaslandirma: TfrxDBDataset
    UserName = 'Yaslandirma'
    CloseDataSource = False
    DataSet = TabYaslandirma
    BCDToCurrency = False
    DataSetOptions = []
    Left = 476
    Top = 218
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 419
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 768
    Top = 448
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object MenuItem7: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      OnClick = DkmanSil1Click
    end
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
    Left = 331
    Top = 433
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
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 383
    Top = 308
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      ImageName = 'PngImage0'
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      ImageName = 'PngImage16'
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object TabYorum2: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @YER int'
      'declare @RID int'
      ''
      'set @YER=:YerID'
      'set @RID= :PRID'
      ''
      'select '
      'GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      
        'Mod'#252'l = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-11110 AND DEGER' +
        ' = GY.TUR), '
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
      
        '   (GY.TUR in (28,29,104,105,106,107,209,214,219) and GOREVID in' +
        ' (select ID from FATBASLIK where REHBERID=@RID)) '
      
        'or (GY.TUR=97 and GOREVID in (select ID from TEKLIF where REHBER' +
        'ID=@RID)) '
      
        'or (GY.TUR=47 and GOREVID in (select ID from KREDILER where REHB' +
        'ERID=@RID)) '
      
        'or (GY.TUR in (15,315,316) and GOREVID in (select ID from CEKLER' +
        ' where REHBERID=@RID)) '
      
        'or (GY.TUR=33 and GOREVID in (select ID from GOREVLER where REHB' +
        'ERID=@RID)) '
      
        'or (GY.TUR=70 and GOREVID in (select ID from PROJELER where REHB' +
        'ERID=@RID)) '
      
        'or (GY.TUR=83 and GOREVID in (select ID from SERVIS where REHBER' +
        'ID=@RID)) '
      
        'or (GY.TUR in (91,92) and GOREVID in (select ID from SIPARIS whe' +
        're REHBERID=@RID)) '
      
        'or (GY.TUR=70 and GOREVID in (select ID from PROJELER where REHB' +
        'ERID=@RID)) '
      'order by 2 DESC')
    Left = 507
    Top = 313
    ParamData = <
      item
        Name = 'YerID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PRID'
        Size = -1
        Value = Null
      end>
  end
  object DtsYorum2: TDataSource
    DataSet = TabYorum2
    Left = 483
    Top = 428
  end
  object TabResim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  TOP 1 ID, RESIM'
      'FROM         REHBER'
      'WHERE ID=:PRID')
    Left = 811
    Top = 335
    ParamData = <
      item
        Name = 'PRID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsResim: TDataSource
    DataSet = TabResim
    Left = 889
    Top = 246
  end
  object TabFirsat: TFDQuery
    AfterOpen = TabFirsatAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select P.ID,P.REHBERID,P.PROJEKODU,P.PROJEADI,Firma.FIRMA, BASLA' +
        'MATARIHI,TURU,KONUSU,ASAMA,LISTEFIYATI,LISTEKUR,SATISFIYATI,SATI' +
        'SKUR,'
      
        'PRJ_SORUMLUSU_ID,PRJ_ASAMA_SORUMLUSU_ID,ProjeSorumlu.FIRMA as PR' +
        'J_SORUMLUAD, AsamaSorumlu.FIRMA as PRJ_ASAMASORUMLUAD, '
      'RehberIlgili.ADSOYAD, P.DURUM,P.NOTLAR , BITISTARIHI ,'
      
        'ProjeTuru.ANAHTAR PROJETURU, ProjeAsama.ANAHTAR PROJEASAMA, Proj' +
        'eDurum.ANAHTAR PROJEDURUM'
      'from PROJELER P '
      #9'INNER JOIN REHBER Firma on Firma.ID = P.REHBERID'
      
        #9'INNER JOIN REHBER ProjeSorumlu on ProjeSorumlu.ID = P.PRJ_SORUM' +
        'LUSU_ID'
      
        #9'LEFT OUTER JOIN REHBER AsamaSorumlu on AsamaSorumlu.ID=P.PRJ_AS' +
        'AMA_SORUMLUSU_ID'
      
        #9'LEFT OUTER JOIN REHBERPERSONEL RehberIlgili on RehberIlgili.ID=' +
        'P.ILGILI'
      
        #9'LEFT OUTER JOIN REHBERINI ProjeTuru ON ProjeTuru.DEGER = P.TURU' +
        ' AND ProjeTuru.BOLUM ='#39'Proje_T'#252'r'#252#39
      
        #9'LEFT OUTER JOIN REHBERINI ProjeAsama ON ProjeAsama.DEGER = P.AS' +
        'AMA AND ProjeAsama.BOLUM ='#39'Proje_A'#351'ama'#39
      
        #9'LEFT OUTER JOIN REHBERINI ProjeDurum ON ProjeDurum.DEGER = P.DU' +
        'RUM AND ProjeDurum.BOLUM ='#39'Proje_Durum'#39
      'WHERE '
      'P.REHBERID = :PID'
      'AND MODUL = 1'
      'AND P.DURUM = 1'#9
      'ORDER BY BITISTARIHI DESC')
    Left = 793
    Top = 234
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsFirsat: TDataSource
    DataSet = TabFirsat
    Left = 777
    Top = 284
  end
  object TabAlias: TFDQuery
    Active = True
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM REHBERALIAS')
    Left = 180
    Top = 415
  end
  object DtsAlias: TDataSource
    DataSet = TabAlias
    Left = 173
    Top = 470
  end
end
