object TeklifWizardDlg: TTeklifWizardDlg
  Left = 0
  Top = 0
  ActiveControl = PageControlUst
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Teklif Sihirbaz'#305
  ClientHeight = 682
  ClientWidth = 1362
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object PanelSol: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 682
    Align = alLeft
    TabOrder = 0
    object TreeListGecmisTeklifler: TcxDBTreeList
      Left = 1
      Top = 153
      Width = 215
      Height = 528
      Align = alClient
      Bands = <
        item
        end>
      DataController.DataSource = DtsGecmisTeklifler
      DataController.ParentField = 'USTID'
      DataController.KeyField = 'ALTID'
      Navigator.Buttons.CustomButtons = <>
      OptionsBehavior.CopyCaptionsToClipboard = False
      OptionsSelection.CellSelect = False
      OptionsView.ScrollBars = ssVertical
      OptionsView.Headers = False
      RootValue = -1
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 0
      OnClick = TreeListGecmisTekliflerClick
      object TreeTARIH: TcxDBTreeListColumn
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.ShowTime = False
        BestFitMaxWidth = 10
        Caption.Text = ' '
        DataBinding.FieldName = 'TARIH'
        Width = 105
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeDURUM: TcxDBTreeListColumn
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repTeklifDurumu
        Caption.Text = ' '
        DataBinding.FieldName = 'DURUM'
        Width = 58
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
    object PanelSolUst: TPanel
      Left = 1
      Top = 1
      Width = 215
      Height = 152
      Align = alTop
      TabOrder = 1
      object Label2: TLabel
        Left = 128
        Top = 126
        Width = 20
        Height = 18
        Caption = 'Son'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object btnAktiviteler: TcxButton
        Tag = 2
        Left = 55
        Top = 85
        Width = 96
        Height = 29
        Caption = 'Ge'#231'mi'#351
        TabOrder = 0
        OnClick = btnAktivitelerClick
      end
      object btnDokuman: TcxButton
        Tag = 1
        Left = 55
        Top = 48
        Width = 96
        Height = 29
        Caption = 'Yorum/Medya'
        TabOrder = 1
        OnClick = btnDokumanClick
      end
      object btnTeklif: TcxButton
        Left = 55
        Top = 12
        Width = 96
        Height = 29
        Caption = 'Teklif'
        TabOrder = 2
        OnClick = btnTeklifClick
      end
      object cxLabel15: TcxLabel
        Left = 9
        Top = 126
        Caption = #214'nceki Teklifler'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboSay: TcxComboBox
        Left = 156
        Top = 122
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          '10'
          '20'
          '30'
          '40+')
        Properties.OnCloseUp = ComboSayPropertiesCloseUp
        TabOrder = 4
        Text = '10'
        Width = 54
      end
    end
  end
  object WizardKontrol: TJvWizard
    Left = 217
    Top = 0
    Width = 1145
    Height = 682
    ActivePage = TeklifEkr
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Geri'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&'#304'leri >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Son'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = #304'ptal'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Help'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    OnCancelButtonClick = WizardKontrolCancelButtonClick
    DesignSize = (
      1145
      682)
    object TeklifEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Teklif bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      OnNextButtonClick = TeklifEkrNextButtonClick
      object Label1: TLabel
        Left = 12
        Top = 44
        Width = 11
        Height = 18
        Caption = 'ID'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
      object PageControlUst: TcxPageControl
        Left = 0
        Top = 70
        Width = 1138
        Height = 570
        Align = alClient
        TabOrder = 7
        Properties.ActivePage = TabSheetDetay
        Properties.CustomButtons.Buttons = <>
        OnChange = PageControlUstChange
        ClientRectBottom = 566
        ClientRectLeft = 4
        ClientRectRight = 1134
        ClientRectTop = 27
        object TabSheetDetay: TcxTabSheet
          Tag = 1
          Caption = 'Detay'
          object PanelDetay: TPanel
            Left = 0
            Top = 187
            Width = 1130
            Height = 352
            Align = alClient
            Caption = 'PanelDetay'
            TabOrder = 0
            object GridTeklif: TcxGrid
              Left = 1
              Top = 28
              Width = 1128
              Height = 170
              Align = alClient
              PopupMenu = PopupMenuFatura
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              LookAndFeel.ScrollbarMode = sbmClassic
              LookAndFeel.SkinName = 'LondonLiquidSky'
              object GridTeklifWizardDetayView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCanFocusRecord = GridTeklifWizardDetayViewCanFocusRecord
                OnCellDblClick = GridTeklifWizardDetayViewCellDblClick
                DataController.DataSource = DtsTeklifDetay
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    FieldName = 'DOVIZ_TUTARI'
                    Column = GridTeklifWizardDetayViewDOVIZ_TUTARI
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skCount
                    Column = GridTeklifWizardDetayViewAD
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    Column = GridTeklifWizardDetayViewADET1
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    Column = GridTeklifWizardDetayViewTUTAR1
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.AlwaysShowEditor = True
                OptionsBehavior.CellHints = True
                OptionsBehavior.FocusCellOnTab = True
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsSelection.HideSelection = True
                OptionsView.Footer = True
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridTeklifWizardDetayViewSIRALAMA: TcxGridDBColumn
                  Caption = 'Poz No'
                  DataBinding.FieldName = 'POZNO'
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 57
                end
                object GridTeklifWizardDetayViewTUR: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  RepositoryItem = Tablo.repStokTipi
                  HeaderAlignmentHorz = taCenter
                  Options.Editing = False
                  Styles.Header = cxStyle6
                  Width = 64
                end
                object GridTeklifWizardDetayViewRESIMGOSTER: TcxGridDBColumn
                  Caption = 'Resim G'#246'ster'
                  DataBinding.FieldName = 'RESIMGOSTER'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ImmediatePost = True
                  Options.Editing = False
                  Styles.Header = cxStyle6
                  Width = 42
                end
                object GridTeklifWizardDetayViewMEDYAVAR: TcxGridDBColumn
                  Caption = 'Medya'
                  DataBinding.FieldName = 'MEDYAVAR'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ImmediatePost = True
                  Styles.Header = cxStyle6
                end
                object GridTeklifWizardDetayViewKOD1: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Options.Editing = False
                  Styles.Header = cxStyle6
                  Width = 53
                end
                object GridTeklifWizardDetayViewAD: TcxGridDBColumn
                  Caption = 'Ad'
                  DataBinding.FieldName = 'AD'
                  Options.Editing = False
                  Styles.Header = cxStyle8
                  Width = 87
                end
                object GridTeklifWizardDetayViewACIKLAMA1: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Options.Editing = False
                  Options.ShowEditButtons = isebAlways
                  Styles.Header = cxStyle8
                  Width = 195
                end
                object GridTeklifWizardDetayViewADET1: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.Alignment.Horz = taRightJustify
                  Properties.ReadOnly = False
                  Options.Editing = False
                  Styles.Header = cxStyle9
                  Width = 49
                end
                object GridTeklifWizardDetayViewBIRIM1: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  RepositoryItem = Tablo.repStokAnaBirim
                  Options.Editing = False
                  Styles.Header = cxStyle10
                  Width = 42
                end
                object GridTeklifWizardDetayViewBIRIMFIYAT1: TcxGridDBColumn
                  Caption = 'Birim Fiyat'
                  DataBinding.FieldName = 'BIRIMFIYAT'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00000;'
                  Options.Editing = False
                  Styles.Header = cxStyle11
                  Width = 109
                end
                object GridTeklifWizardDetayViewISKONTO1: TcxGridDBColumn
                  Caption = #304'sk%'
                  DataBinding.FieldName = 'ISKONTO'
                  PropertiesClassName = 'TcxSpinEditProperties'
                  Properties.DisplayFormat = ',0.00;'
                  Properties.EditFormat = ',0.00;'
                  Properties.MaxValue = 100.000000000000000000
                  Properties.ValueType = vtFloat
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 39
                end
                object GridTeklifWizardDetayViewISKONTO2: TcxGridDBColumn
                  Caption = #304'sk2%'
                  DataBinding.FieldName = 'ISKONTO2'
                  PropertiesClassName = 'TcxSpinEditProperties'
                  Properties.DisplayFormat = ',0.00;'
                  Properties.EditFormat = ',0.00;'
                  Properties.MaxValue = 100.000000000000000000
                  Properties.ValueType = vtFloat
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 38
                end
                object GridTeklifWizardDetayViewKDV1: TcxGridDBColumn
                  DataBinding.FieldName = 'KDV'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.Alignment.Horz = taRightJustify
                  Properties.ReadOnly = False
                  Options.Editing = False
                  Styles.Header = cxStyle13
                  Width = 34
                end
                object GridTeklifWizardDetayViewTUTAR1: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'TUTAR'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;'
                  HeaderAlignmentHorz = taCenter
                  Options.Editing = False
                  Styles.Content = cxStyle14
                  Styles.Header = cxStyle15
                  Width = 83
                end
                object GridTeklifWizardDetayViewKUR: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                  Options.Editing = False
                  Styles.Header = cxStyle13
                end
                object GridTeklifWizardDetayViewDOVIZ_TUTARI: TcxGridDBColumn
                  Caption = 'D'#246'viz Tutar'#305
                  DataBinding.FieldName = 'DOVIZ_TUTARI'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;'
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 72
                end
                object GridTeklifWizardDetayViewDOVIZ_KURU: TcxGridDBColumn
                  Caption = 'D'#246'viz Birimi'
                  DataBinding.FieldName = 'DOVIZ_KURU'
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 109
                end
                object GridTeklifWizardDetayViewDOVIZKURDEGERI: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'DOVIZKURDEGERI'
                  Visible = False
                end
                object GridTeklifWizardDetayViewPROJEKODU: TcxGridDBColumn
                  Caption = 'Proje Kodu'
                  DataBinding.FieldName = 'PROJEKODU'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 162
                end
                object GridTeklifWizardDetayViewTESLIMTARIHI: TcxGridDBColumn
                  Caption = 'Teslim Tarihi'
                  DataBinding.FieldName = 'TESLIMTARIHI'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.ShowTime = False
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 84
                end
                object GridTeklifWizardDetayViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn
                  Caption = 'D'#246'viz B.Fiyat'
                  DataBinding.FieldName = 'DOVIZ_BIRIMFIYAT'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00000;'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 103
                end
                object GridTeklifWizardDetayViewOZELKOD: TcxGridDBColumn
                  Caption = #214'zel Kod'
                  DataBinding.FieldName = 'OZELKOD'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                end
                object GridTeklifWizardDetayViewMUHKODU: TcxGridDBColumn
                  Caption = 'Muh Kodu'
                  DataBinding.FieldName = 'MUHKODU'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                end
                object GridTeklifWizardDetayViewSTOKDURUM: TcxGridDBColumn
                  Caption = 'Stok Durumu'
                  DataBinding.FieldName = 'STOKDURUM'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.ReadOnly = True
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                end
                object GridTeklifWizardDetayViewEKIPMAN: TcxGridDBColumn
                  Caption = 'Ekipman'
                  DataBinding.FieldName = 'EKIPMAN'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 116
                end
                object GridTeklifWizardDetayViewSERINO: TcxGridDBColumn
                  Caption = 'Seri No'
                  DataBinding.FieldName = 'SERINO'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.ReadOnly = True
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                  Width = 102
                end
                object GridTeklifWizardDetayViewISKONTOLUBRMFIYAT: TcxGridDBColumn
                  Caption = #304'skontolo Birim Fiyat'
                  DataBinding.FieldName = 'ISKONTOLUBRMFIYAT'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                end
                object GridTeklifWizardDetayViewKDVDAHILFIYAT: TcxGridDBColumn
                  Caption = 'KDV Dahil Birim Fiyat'
                  DataBinding.FieldName = 'KDVDAHILFIYAT'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                end
                object GridTeklifWizardDetayViewSTOKMALIYET: TcxGridDBColumn
                  Caption = 'Maliyet'
                  DataBinding.FieldName = 'STOKMALIYET'
                  Visible = False
                  Options.Editing = False
                  Styles.Header = cxStyle12
                end
                object GridTeklifWizardDetayViewEN: TcxGridDBColumn
                  DataBinding.FieldName = 'EN'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DecimalPlaces = 0
                  Properties.DisplayFormat = ',0;-,0'
                end
                object GridTeklifWizardDetayViewBOY: TcxGridDBColumn
                  DataBinding.FieldName = 'BOY'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DecimalPlaces = 0
                  Properties.DisplayFormat = ',0;-,0'
                end
                object GridTeklifWizardDetayViewYUZEY: TcxGridDBColumn
                  DataBinding.FieldName = 'YUZEY'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;-,0.00'
                end
                object GridTeklifWizardDetayViewSAYI: TcxGridDBColumn
                  DataBinding.FieldName = 'SAYI'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DecimalPlaces = 0
                  Properties.DisplayFormat = ',0;-,0'
                end
              end
              object GridTeklifLevel1: TcxGridLevel
                GridView = GridTeklifWizardDetayView
              end
            end
            object ToolBar5: TToolBar
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 1122
              Height = 24
              Margins.Bottom = 0
              AutoSize = True
              ButtonWidth = 81
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
              PopupMenu = PopupMenuFatura
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object SatirEkle: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = SatirEkleClick
              end
              object SatirSil: TToolButton
                Left = 81
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = SatirSilClick
              end
              object ToolButton4: TToolButton
                Left = 162
                Top = 0
                Width = 8
                Caption = 'ToolButton4'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Style = tbsSeparator
              end
              object ToolButton7: TToolButton
                Left = 170
                Top = 0
                Caption = 'Alta'
                ImageIndex = 3
                ImageName = 'PngImage3'
              end
              object ToolButton13: TToolButton
                Left = 251
                Top = 0
                Caption = #220'ste'
                ImageIndex = 3
                ImageName = 'PngImage3'
              end
              object AlternatifTus: TToolButton
                Left = 332
                Top = 0
                Caption = 'Alternatif'
                ImageIndex = 4
                ImageName = 'PngImage4'
                OnClick = AlternatifTusClick
              end
              object ToolButton3: TToolButton
                Left = 413
                Top = 0
                Width = 8
                Caption = 'ToolButton3'
                ImageIndex = 4
                ImageName = 'PngImage4'
                Style = tbsSeparator
              end
              object TamEkranTus: TToolButton
                Left = 421
                Top = 0
                Caption = 'Tam Ekran'
                ImageIndex = 6
                ImageName = 'PngImage6'
                OnClick = TamEkranTusClick
              end
              object BtnYenile: TToolButton
                Left = 502
                Top = 0
                Caption = 'Yenile'
                ImageIndex = 9
                ImageName = 'PngImage9'
                OnClick = BtnYenileClick
              end
              object BtnDoviz: TToolButton
                Left = 583
                Top = 0
                Caption = 'D'#246'viz Kuru'
                ImageIndex = 10
                ImageName = 'PngImage10'
                OnClick = BtnDovizClick
              end
            end
            object PanelAlt: TPanel
              Left = 1
              Top = 198
              Width = 1128
              Height = 153
              Align = alBottom
              Color = 11776947
              Font.Charset = TURKISH_CHARSET
              Font.Color = clBlack
              Font.Height = -11
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentBackground = False
              ParentFont = False
              TabOrder = 2
              DesignSize = (
                1128
                153)
              object GridFaturaToplam: TStringGrid
                Left = 28285
                Top = 16
                Width = 260
                Height = 118
                Anchors = []
                Color = clBtnFace
                ColCount = 3
                DefaultColWidth = 128
                DefaultRowHeight = 19
                FixedCols = 2
                RowCount = 6
                FixedRows = 0
                Font.Charset = TURKISH_CHARSET
                Font.Color = clRed
                Font.Height = -13
                Font.Name = 'Tahoma'
                Font.Style = [fsBold]
                GridLineWidth = 0
                ParentFont = False
                ScrollBars = ssNone
                TabOrder = 0
              end
              object gridFatToplam: TcxGrid
                Left = 777
                Top = 1
                Width = 328
                Height = 151
                Align = alLeft
                BorderStyle = cxcbsNone
                Enabled = False
                TabOrder = 1
                LookAndFeel.Kind = lfOffice11
                LookAndFeel.NativeStyle = False
                object tvFatToplamlar: TcxGridDBTableView
                  Navigator.Buttons.CustomButtons = <>
                  ScrollbarAnnotations.CustomAnnotations = <>
                  DataController.DataSource = dtsTOPLAMLAR
                  DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <>
                  DataController.Summary.SummaryGroups = <>
                  OptionsCustomize.ColumnsQuickCustomization = True
                  OptionsData.Deleting = False
                  OptionsData.Editing = False
                  OptionsData.Inserting = False
                  OptionsSelection.CellSelect = False
                  OptionsSelection.HideSelection = True
                  OptionsView.ScrollBars = ssVertical
                  OptionsView.GridLineColor = 11776947
                  OptionsView.GridLines = glNone
                  OptionsView.GroupByBox = False
                  OptionsView.Header = False
                  OptionsView.RowSeparatorColor = 11776947
                  Styles.Background = Tablo.cxStyle19
                  Styles.Content = Tablo.cxStyle19
                  object tvFatToplamlarTUR: TcxGridDBColumn
                    DataBinding.FieldName = 'TUR'
                    DataBinding.IsNullValueType = True
                    Visible = False
                  end
                  object tvFatToplamlarACIKLAMA: TcxGridDBColumn
                    DataBinding.FieldName = 'ACIKLAMA'
                    DataBinding.IsNullValueType = True
                    Width = 130
                  end
                  object tvFatToplamlarDEGER: TcxGridDBColumn
                    DataBinding.FieldName = 'DEGER'
                    DataBinding.IsNullValueType = True
                    RepositoryItem = Tablo.RepCurrencyGenel
                    Width = 60
                  end
                  object tvFatToplamlarKUR: TcxGridDBColumn
                    DataBinding.FieldName = 'KUR'
                    DataBinding.IsNullValueType = True
                    Width = 25
                  end
                  object tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn
                    DataBinding.FieldName = 'DOVIZTUTARI'
                    DataBinding.IsNullValueType = True
                    RepositoryItem = Tablo.RepCurrencyGenel
                    Width = 60
                  end
                  object tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn
                    DataBinding.FieldName = 'DOVIZ_KURU'
                    DataBinding.IsNullValueType = True
                    Width = 25
                  end
                end
                object gridFatToplamLevel1: TcxGridLevel
                  GridView = tvFatToplamlar
                  Options.DetailFrameColor = 11776947
                end
              end
              object PanelAltSol: TPanel
                Left = 1
                Top = 1
                Width = 776
                Height = 151
                Align = alLeft
                TabOrder = 2
                object OnaylanmadiNotu: TcxLabel
                  Left = 404
                  Top = 105
                  Visible = False
                end
                object PanelAltNotlar: TPanel
                  Left = 1
                  Top = 1
                  Width = 332
                  Height = 149
                  Align = alLeft
                  TabOrder = 1
                  object MemoNOTLAR: TcxDBMemo
                    Left = 68
                    Top = 79
                    DataBinding.DataField = 'ACIKLAMA'
                    DataBinding.DataSource = DtsTeklif
                    Properties.ScrollBars = ssVertical
                    TabOrder = 0
                    Height = 47
                    Width = 261
                  end
                  object BeditProjeKod: TcxButtonEdit
                    Left = 68
                    Top = 10
                    ParentShowHint = False
                    Properties.Buttons = <
                      item
                        Caption = '++'
                        Default = True
                        Kind = bkText
                      end
                      item
                        Caption = '+'
                        Hint = 'Temizle'
                        Kind = bkText
                      end
                      item
                        Caption = '-'
                        Kind = bkText
                      end>
                    Properties.ReadOnly = False
                    Properties.OnButtonClick = BeditProjePropertiesButtonClick
                    ShowHint = True
                    Style.BorderStyle = ebsOffice11
                    Style.LookAndFeel.Kind = lfStandard
                    Style.LookAndFeel.NativeStyle = False
                    StyleDisabled.LookAndFeel.Kind = lfStandard
                    StyleDisabled.LookAndFeel.NativeStyle = False
                    StyleFocused.LookAndFeel.Kind = lfStandard
                    StyleFocused.LookAndFeel.NativeStyle = False
                    StyleHot.LookAndFeel.Kind = lfStandard
                    StyleHot.LookAndFeel.NativeStyle = False
                    StyleReadOnly.LookAndFeel.Kind = lfStandard
                    StyleReadOnly.LookAndFeel.NativeStyle = False
                    TabOrder = 1
                    OnDblClick = BeditProjeKodDblClick
                    Width = 261
                  end
                  object LabelProje: TcxLabel
                    Left = 3
                    Top = 13
                    Caption = 'F'#305'rsat Kodu'
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clBlack
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = []
                    Style.IsFontAssigned = True
                    Transparent = True
                  end
                  object btnSevkAdresi: TcxButtonEdit
                    Left = 68
                    Top = 56
                    ParentShowHint = False
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
                    Properties.OnButtonClick = btnSevkAdresiPropertiesButtonClick
                    ShowHint = True
                    TabOrder = 3
                    TextHint = 'REHBERILETID'
                    Width = 261
                  end
                  object cxLabel19: TcxLabel
                    Left = 3
                    Top = 58
                    Caption = 'Sevk Adresi'
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clBlack
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = []
                    Style.IsFontAssigned = True
                    Transparent = True
                  end
                  object BeditServis: TcxButtonEdit
                    Left = 68
                    Top = 33
                    Properties.Buttons = <
                      item
                        Caption = '++'
                        Default = True
                        Kind = bkText
                      end
                      item
                        Caption = '+'
                        Kind = bkText
                      end
                      item
                        Caption = '-'
                        Kind = bkText
                      end>
                    Properties.ReadOnly = True
                    Properties.OnButtonClick = BeditServisPropertiesButtonClick
                    TabOrder = 5
                    OnDblClick = BeditServisDblClick
                    Width = 261
                  end
                  object EditOZELKOD: TcxDBTextEdit
                    Left = 68
                    Top = 125
                    DataBinding.DataField = 'OZELKOD'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 6
                    Width = 261
                  end
                  object cxLabel26: TcxLabel
                    Left = 3
                    Top = 127
                    Caption = #214'zel Kod'
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clBlack
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = []
                    Style.IsFontAssigned = True
                    Transparent = True
                  end
                  object cxLabel17: TcxLabel
                    Left = 3
                    Top = 80
                    Caption = 'Notlar'
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clBlack
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = []
                    Style.IsFontAssigned = True
                    Transparent = True
                  end
                  object cxLabel7: TcxLabel
                    Left = 3
                    Top = 37
                    Caption = 'Servis'
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clBlack
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = []
                    Style.IsFontAssigned = True
                    Transparent = True
                  end
                end
                object PanelAltOnay: TPanel
                  Left = 333
                  Top = 1
                  Width = 235
                  Height = 149
                  Align = alClient
                  TabOrder = 2
                  object cxGroupBoxIcOnay: TcxGroupBox
                    Left = 3
                    Top = 9
                    Caption = #304#231' Onay'
                    TabOrder = 0
                    Height = 77
                    Width = 234
                    object EditOnaylayan: TcxButtonEdit
                      Left = 69
                      Top = 44
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
                      Properties.OnButtonClick = EditOnaylayanPropertiesButtonClick
                      TabOrder = 0
                      Width = 159
                    end
                    object cxLabel4: TcxLabel
                      Left = 3
                      Top = 45
                      Caption = 'Onaylayan'
                      ParentColor = False
                      Style.Color = clWhite
                      Transparent = True
                    end
                    object cxLabel18: TcxLabel
                      Left = 3
                      Top = 20
                      Caption = 'Onaylayacak'
                      ParentColor = False
                      Style.Color = clWhite
                      Transparent = True
                    end
                    object cbOnaylayacak: TcxDBImageComboBox
                      Left = 69
                      Top = 18
                      DataBinding.DataField = 'ONAYLAYACAK'
                      DataBinding.DataSource = DtsTeklif
                      Properties.ImmediatePost = True
                      Properties.ImmediateUpdateText = True
                      Properties.Items = <>
                      TabOrder = 3
                      Width = 159
                    end
                  end
                  object cxGroupBoxDisOnay: TcxGroupBox
                    Left = 3
                    Top = 86
                    Caption = 'D'#305#351' Onay'
                    TabOrder = 1
                    Height = 53
                    Width = 234
                    object cxLabel22: TcxLabel
                      Left = 3
                      Top = 21
                      Caption = 'Onaylayan'
                      ParentColor = False
                      Style.Color = clWhite
                      Transparent = True
                    end
                    object cxButtonEditDisOnay: TcxButtonEdit
                      Tag = 1
                      Left = 69
                      Top = 20
                      ParentShowHint = False
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
                      Properties.OnButtonClick = ComboIlgiliPropertiesButtonClick
                      ShowHint = True
                      TabOrder = 1
                      TextHint = 'DISONAY'
                      Width = 159
                    end
                  end
                end
                object PanelAltFiyat: TPanel
                  Left = 568
                  Top = 1
                  Width = 207
                  Height = 149
                  Align = alRight
                  TabOrder = 3
                  object cxLabel6: TcxLabel
                    Left = 9
                    Top = 8
                    Caption = 'Fiyat'
                    Transparent = True
                  end
                  object FiyatListesi: TcxDBImageComboBox
                    Left = 104
                    Top = 7
                    RepositoryItem = Tablo.RepFiyatAdlari
                    DataBinding.DataField = 'FIYAT_LISTESI'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    TabOrder = 1
                    Width = 100
                  end
                  object cxLabel8: TcxLabel
                    Left = 9
                    Top = 33
                    Caption = 'Vade (g'#252'n)'
                    Transparent = True
                  end
                  object cxDBTextEdit2: TcxDBTextEdit
                    Left = 104
                    Top = 31
                    DataBinding.DataField = 'VADE'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 3
                    Width = 53
                  end
                  object ComboKur: TcxDBComboBox
                    Left = 104
                    Top = 63
                    RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
                    DataBinding.DataField = 'DOVIZ_KURU'
                    DataBinding.DataSource = DtsTeklif
                    Properties.OnCloseUp = ComboKurPropertiesCloseUp
                    Properties.OnEditValueChanged = ComboKurPropertiesEditValueChanged
                    TabOrder = 4
                    Width = 54
                  end
                  object LabelKur: TcxLabel
                    Left = 9
                    Top = 65
                    Caption = 'Raporlama D'#246'vizi'
                    Transparent = True
                  end
                  object cxLabel21: TcxLabel
                    Left = 9
                    Top = 115
                    Caption = 'D'#246'n'#252#351#252'm T'#252'r'#252
                    Transparent = True
                  end
                  object cxDBImageComboBox1: TcxDBImageComboBox
                    Left = 104
                    Top = 113
                    RepositoryItem = Tablo.repStokAnaBirim
                    DataBinding.DataField = 'DONUSUMTURU'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    TabOrder = 7
                    Width = 54
                  end
                  object editDovizKuru: TcxDBCurrencyEdit
                    Left = 157
                    Top = 63
                    DataBinding.DataField = 'DOVIZKUR'
                    DataBinding.DataSource = DtsTeklif
                    Enabled = False
                    ParentFont = False
                    Properties.DecimalPlaces = 4
                    Properties.DisplayFormat = ',0.0000;(,0.0000)'
                    Properties.EditFormat = ',0.0000;(,0.0000)'
                    Properties.ReadOnly = False
                    Properties.UseDisplayFormatWhenEditing = True
                    Style.Color = 11776947
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clRed
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsBold]
                    Style.IsFontAssigned = True
                    TabOrder = 8
                    Width = 48
                  end
                  object ComboTEKLIF_DOVIZI: TcxDBComboBox
                    Left = 104
                    Top = 88
                    DataBinding.DataField = 'TEKLIF_DOVIZI'
                    DataBinding.DataSource = DtsTeklif
                    Properties.DropDownListStyle = lsEditFixedList
                    Properties.ImmediatePost = True
                    Properties.ImmediateUpdateText = True
                    Properties.OnInitPopup = ComboTEKLIF_DOVIZIPropertiesInitPopup
                    TabOrder = 9
                    Width = 54
                  end
                  object cxLabel27: TcxLabel
                    Left = 10
                    Top = 91
                    Caption = 'Teklif D'#246'vizi'
                    Transparent = True
                  end
                end
              end
            end
          end
          object PageControlAlt: TcxPageControl
            Left = 0
            Top = 35
            Width = 1130
            Height = 152
            Align = alTop
            TabOrder = 1
            Properties.ActivePage = cxTabSheet1
            Properties.CustomButtons.Buttons = <>
            ClientRectBottom = 148
            ClientRectLeft = 4
            ClientRectRight = 1126
            ClientRectTop = 27
            object cxTabSheet1: TcxTabSheet
              Caption = 'Genel Bilgiler'
              ImageIndex = 0
              object PanelUst: TPanel
                Left = 0
                Top = 0
                Width = 1122
                Height = 121
                Align = alClient
                BevelOuter = bvNone
                Caption = '"'
                Color = 11776947
                Font.Charset = TURKISH_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'Trebuchet MS'
                Font.Style = []
                ParentBackground = False
                ParentFont = False
                TabOrder = 0
                object cxDBLabel7: TcxDBLabel
                  Left = 263
                  Top = 106
                  DataBinding.DataField = 'HAZIRLAYAN'
                  DataBinding.DataSource = DtsTeklif
                  Visible = False
                  Height = 21
                  Width = 23
                end
                object cxGroupBox1: TcxGroupBox
                  Left = 1
                  Top = 5
                  Style.LookAndFeel.Kind = lfOffice11
                  Style.LookAndFeel.NativeStyle = True
                  Style.Shadow = False
                  StyleDisabled.LookAndFeel.Kind = lfOffice11
                  StyleDisabled.LookAndFeel.NativeStyle = True
                  TabOrder = 0
                  Height = 114
                  Width = 309
                  object cxLabel1: TcxLabel
                    Left = 4
                    Top = 89
                    Caption = 'M'#252#351'teri '#304'lgili'
                  end
                  object ComboIlgili: TcxButtonEdit
                    Tag = 1
                    Left = 114
                    Top = 89
                    ParentShowHint = False
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
                    Properties.OnButtonClick = ComboIlgiliPropertiesButtonClick
                    ShowHint = True
                    TabOrder = 6
                    TextHint = 'MUS_ILGILI'
                    Width = 190
                  end
                  object ComboHazirlayan: TcxButtonEdit
                    Left = 114
                    Top = 64
                    ParentShowHint = False
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
                    Properties.OnButtonClick = ComboHazirlayanPropertiesButtonClick
                    ShowHint = True
                    TabOrder = 3
                    Width = 190
                  end
                  object cxLabel2: TcxLabel
                    Left = 4
                    Top = 62
                    Caption = 'Haz'#305'rlayan*'
                  end
                  object LabelKonusu: TcxLabel
                    Left = 4
                    Top = 38
                    Cursor = crHandPoint
                    Hint = 'Teklif_Konusu'
                    HelpType = htKeyword
                    HelpKeyword = 'TEKLIF.KONUSU'
                    Caption = 'Konusu*'
                    FocusControl = ComboKONU
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsUnderline]
                    Style.IsFontAssigned = True
                    OnClick = LabelTURUClick
                  end
                  object ComboKONU: TcxDBComboBox
                    Left = 114
                    Top = 39
                    RepositoryItem = Tablo.repTeklifKonusu
                    DataBinding.DataField = 'KONUSU'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 2
                    Width = 190
                  end
                  object ComboTURU: TcxDBImageComboBox
                    Left = 113
                    Top = 13
                    RepositoryItem = Tablo.repTeklifTuru
                    DataBinding.DataField = 'TURU'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    TabOrder = 0
                    Width = 190
                  end
                  object LabelTURU: TcxLabel
                    Left = 4
                    Top = 14
                    Cursor = crHandPoint
                    Hint = 'Teklif_T'#252'r'#252
                    HelpType = htKeyword
                    HelpKeyword = 'TEKLIF.TURU'
                    Caption = 'T'#252'r'#252'*'
                    FocusControl = ComboTURU
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsUnderline]
                    Style.IsFontAssigned = True
                    OnClick = LabelTURUClick
                  end
                end
                object cxGroupBox2: TcxGroupBox
                  Left = 316
                  Top = 5
                  Style.LookAndFeel.Kind = lfOffice11
                  Style.LookAndFeel.NativeStyle = True
                  Style.Shadow = False
                  StyleDisabled.LookAndFeel.Kind = lfOffice11
                  StyleDisabled.LookAndFeel.NativeStyle = True
                  TabOrder = 1
                  Height = 114
                  Width = 280
                  object cxLabel9: TcxLabel
                    Left = 5
                    Top = 38
                    Caption = 'Teslim S'#252'resi (g'#252'n)'
                  end
                  object cxLabel10: TcxLabel
                    Left = 182
                    Top = 14
                    Caption = 'Olas'#305'l'#305'k %'
                  end
                  object cxLabel11: TcxLabel
                    Left = 5
                    Top = 16
                    Caption = 'Ge'#231'erlik S'#252'resi (g'#252'n)'
                  end
                  object cxLabel12: TcxLabel
                    Left = 5
                    Top = 62
                    Cursor = crHandPoint
                    Hint = 'Teklif_Teslim_Sekli'
                    HelpType = htKeyword
                    HelpKeyword = 'TEKLIF.TESLIM_SEKLI'
                    Caption = 'Teslim '#350'ekli'
                    FocusControl = ComboTeslimSekli
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsUnderline]
                    Style.IsFontAssigned = True
                    OnClick = LabelTURUClick
                  end
                  object cxLabel13: TcxLabel
                    Left = 182
                    Top = 39
                    Caption = 'g'#252'n'
                    ParentFont = False
                    Visible = False
                  end
                  object cxLabel14: TcxLabel
                    Left = 5
                    Top = 89
                    Cursor = crHandPoint
                    Hint = 'Teklif_'#214'deme'
                    HelpType = htKeyword
                    HelpKeyword = 'TEKLIF.ODEME'
                    Caption = #214'deme '#350'ekli'
                    FocusControl = ComboODEME
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsUnderline]
                    Style.IsFontAssigned = True
                    OnClick = LabelTURUClick
                  end
                  object SpinTESLIM_SURESI: TcxDBSpinEdit
                    Left = 134
                    Top = 39
                    DataBinding.DataField = 'TESLIM_SURESI'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 4
                    Width = 46
                  end
                  object SpinGECERLILIK_SURESI: TcxDBSpinEdit
                    Left = 134
                    Top = 13
                    DataBinding.DataField = 'GECERLILIK_SURESI'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 0
                    Width = 45
                  end
                  object ComboTeslimSekli: TcxDBImageComboBox
                    Left = 134
                    Top = 64
                    RepositoryItem = Tablo.repTeklifTeslimSekli
                    DataBinding.DataField = 'TESLIM_SEKLI'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <
                      item
                      end>
                    TabOrder = 7
                    Width = 140
                  end
                  object ComboODEME: TcxDBImageComboBox
                    Left = 134
                    Top = 88
                    RepositoryItem = Tablo.repTeklifOdeme
                    DataBinding.DataField = 'ODEME'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    TabOrder = 9
                    Width = 140
                  end
                  object SpinOLASILIK: TcxDBSpinEdit
                    Left = 233
                    Top = 13
                    DataBinding.DataField = 'OLASILIK'
                    DataBinding.DataSource = DtsTeklif
                    Properties.AssignedValues.MinValue = True
                    Properties.Increment = 10.000000000000000000
                    Properties.MaxValue = 100.000000000000000000
                    TabOrder = 1
                    Width = 41
                  end
                end
                object cxGroupBox3: TcxGroupBox
                  Left = 600
                  Top = 5
                  Style.LookAndFeel.Kind = lfOffice11
                  Style.LookAndFeel.NativeStyle = True
                  Style.Shadow = False
                  StyleDisabled.LookAndFeel.Kind = lfOffice11
                  StyleDisabled.LookAndFeel.NativeStyle = True
                  TabOrder = 2
                  Height = 114
                  Width = 273
                  object LabelFatNo: TcxLabel
                    Left = 2
                    Top = 65
                    Caption = 'Tarih*'
                  end
                  object EditTeklifNo: TcxDBTextEdit
                    Left = 134
                    Top = 88
                    DataBinding.DataField = 'TEKLIFNO'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 4
                    Width = 89
                  end
                  object cxLabel3: TcxLabel
                    Left = 2
                    Top = 89
                    Caption = 'Teklif/Revize'
                  end
                  object DateTEKLIFTARIHI: TcxDBDateEdit
                    Left = 88
                    Top = 61
                    DataBinding.DataField = 'TARIH'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Kind = ckDateTime
                    TabOrder = 2
                    Width = 180
                  end
                  object ComboSube: TcxDBImageComboBox
                    Left = 88
                    Top = 12
                    Hint = 'Teklif_Durum'
                    RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
                    DataBinding.DataField = 'SUBEID'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    Properties.OnEditValueChanged = ComboDURUMPropertiesEditValueChanged
                    TabOrder = 0
                    Width = 180
                  end
                  object LblSube: TcxLabel
                    Left = 2
                    Top = 15
                    Caption = #350'ube'
                    ParentFont = False
                    Visible = False
                  end
                  object cxLabel16: TcxLabel
                    Left = 127
                    Top = 89
                    Caption = '-'
                  end
                  object EditTeklifSeri: TcxDBTextEdit
                    Left = 88
                    Top = 88
                    DataBinding.DataField = 'TEKLIFSERI'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 7
                    Width = 40
                  end
                  object cxLabel20: TcxLabel
                    Left = 222
                    Top = 89
                    Caption = '/'
                  end
                  object cxDBTextEdit1: TcxDBTextEdit
                    Left = 229
                    Top = 88
                    DataBinding.DataField = 'REVIZEID'
                    DataBinding.DataSource = DtsTeklif
                    TabOrder = 9
                    Width = 39
                  end
                  object cxLabel5: TcxLabel
                    Left = 2
                    Top = 38
                    Cursor = crHandPoint
                    Hint = 'Teklif_Bilgi'
                    HelpType = htKeyword
                    HelpKeyword = 'TEKLIF.BILGI'
                    Caption = 'Bilgi'
                    FocusControl = ComboBILGI
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsUnderline]
                    Style.IsFontAssigned = True
                    OnClick = LabelTURUClick
                  end
                  object ComboBILGI: TcxDBImageComboBox
                    Left = 88
                    Top = 36
                    Hint = 'Teklif_Bilgi'
                    RepositoryItem = Tablo.repTeklifBilgi
                    DataBinding.DataField = 'BILGI'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    TabOrder = 11
                    Width = 121
                  end
                end
                object cxGroupBox4: TcxGroupBox
                  Left = 877
                  Top = 5
                  Style.LookAndFeel.Kind = lfOffice11
                  Style.LookAndFeel.NativeStyle = True
                  Style.Shadow = False
                  StyleDisabled.LookAndFeel.Kind = lfOffice11
                  StyleDisabled.LookAndFeel.NativeStyle = True
                  TabOrder = 4
                  Height = 114
                  Width = 232
                  object cxLabel23: TcxLabel
                    Tag = -2115
                    Left = 4
                    Top = 38
                    Cursor = crHandPoint
                    Hint = 'Proje_Sonu'#231
                    HelpType = htKeyword
                    HelpKeyword = 'PROJELER.SONUC'
                    Caption = 'Sonu'#231
                    FocusControl = comboTeklifSonuc
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsUnderline]
                    Style.IsFontAssigned = True
                    Transparent = True
                    OnClick = LabelTURUClick
                  end
                  object comboTeklifSonuc: TcxDBImageComboBox
                    Left = 105
                    Top = 36
                    RepositoryItem = Tablo.repTeklifSonuc
                    DataBinding.DataField = 'SONUC'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    Properties.OnCloseUp = comboProjeSonucPropertiesCloseUp
                    TabOrder = 1
                    Width = 121
                  end
                  object ComboSEBEBI: TcxDBImageComboBox
                    Left = 105
                    Top = 60
                    RepositoryItem = Tablo.repTeklifSebebi
                    DataBinding.DataField = 'SEBEBI'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    TabOrder = 2
                    Width = 121
                  end
                  object cxLabel24: TcxLabel
                    Tag = -2115
                    Left = 4
                    Top = 62
                    Cursor = crHandPoint
                    Hint = 'Proje_Sebebi'
                    HelpType = htKeyword
                    HelpKeyword = 'PROJELER.SEBEBI'
                    Caption = 'Sebebi'
                    FocusControl = ComboSEBEBI
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = [fsUnderline]
                    Style.IsFontAssigned = True
                    Transparent = True
                    OnClick = LabelTURUClick
                  end
                  object cxLabel25: TcxLabel
                    Left = 4
                    Top = 89
                    Caption = 'Rakip Fiyat'#305
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = []
                    Style.IsFontAssigned = True
                    Transparent = True
                  end
                  object cxDBCurrencyEdit1: TcxDBCurrencyEdit
                    Left = 106
                    Top = 88
                    DataBinding.DataField = 'KAYIPFIYATI'
                    DataBinding.DataSource = DtsTeklif
                    Properties.DisplayFormat = ',0.00;(,0.00)'
                    TabOrder = 5
                    Width = 74
                  end
                  object ComboKAYIPKUR: TcxDBComboBox
                    Left = 180
                    Top = 87
                    RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
                    DataBinding.DataField = 'KAYIPKUR'
                    DataBinding.DataSource = DtsTeklif
                    Properties.DropDownListStyle = lsFixedList
                    TabOrder = 6
                    Width = 46
                  end
                  object ComboDURUM: TcxDBImageComboBox
                    Left = 105
                    Top = 12
                    Hint = 'Teklif_Durum'
                    RepositoryItem = Tablo.repTeklifDurumu
                    DataBinding.DataField = 'DURUM'
                    DataBinding.DataSource = DtsTeklif
                    Properties.Items = <>
                    Properties.OnEditValueChanged = ComboDURUMPropertiesEditValueChanged
                    TabOrder = 7
                    Width = 121
                  end
                  object Label11: TcxLabel
                    Left = 4
                    Top = 14
                    Cursor = crHandPoint
                    Hint = 'Teklif_Durum'
                    HelpType = htKeyword
                    HelpKeyword = 'TEKLIF.DURUM'
                    Caption = 'Durum'
                    FocusControl = ComboDURUM
                    ParentFont = False
                    Style.Font.Charset = TURKISH_CHARSET
                    Style.Font.Color = clWindowText
                    Style.Font.Height = -11
                    Style.Font.Name = 'Trebuchet MS'
                    Style.Font.Style = []
                    Style.IsFontAssigned = True
                    OnClick = LabelTURUClick
                  end
                end
                object LabelCari: TcxLabel
                  Left = 1109
                  Top = 39
                  AutoSize = False
                  Caption = '---'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clRed
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Properties.WordWrap = True
                  Transparent = True
                  Height = 68
                  Width = 36
                end
              end
            end
            object TabSheetEkAlanlar: TcxTabSheet
              Caption = 'Ek Alanlar'
              ImageIndex = 1
            end
            object TabSheetFinans: TcxTabSheet
              Caption = 'Finansal Kurumlar'
              ImageIndex = 2
              object ToolBar6: TToolBar
                AlignWithMargins = True
                Left = 3
                Top = 3
                Width = 1116
                Height = 24
                Margins.Bottom = 0
                AutoSize = True
                ButtonWidth = 62
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
                PopupMenu = PopupMenuFatura
                ShowCaptions = True
                TabOrder = 0
                Transparent = True
                object FinYeniTus: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'Yeni'
                  ImageIndex = 0
                  ImageName = 'PngImage0'
                  OnClick = FinYeniTusClick
                end
                object FinSilTus: TToolButton
                  Left = 62
                  Top = 0
                  Caption = 'Sil'
                  ImageIndex = 1
                  ImageName = 'PngImage1'
                  OnClick = FinSilTusClick
                end
                object ToolButton15: TToolButton
                  Left = 124
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton4'
                  ImageIndex = 2
                  ImageName = 'PngImage2'
                  Style = tbsSeparator
                end
                object FinKaydetTus: TToolButton
                  Left = 132
                  Top = 0
                  Caption = 'Kaydet'
                  ImageIndex = 2
                  ImageName = 'PngImage2'
                  Visible = False
                  OnClick = FinKaydetTusClick
                end
                object FinIptalTus: TToolButton
                  Left = 194
                  Top = 0
                  Caption = 'Iptal'
                  ImageIndex = 3
                  ImageName = 'PngImage3'
                  Visible = False
                  OnClick = FinIptalTusClick
                end
                object ToolButton19: TToolButton
                  Left = 256
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton3'
                  ImageIndex = 4
                  ImageName = 'PngImage4'
                  Style = tbsSeparator
                end
              end
              object GridFinansal: TcxGrid
                Left = 0
                Top = 27
                Width = 1122
                Height = 94
                Align = alClient
                TabOrder = 1
                LookAndFeel.Kind = lfOffice11
                LookAndFeel.NativeStyle = False
                LookAndFeel.SkinName = 'LondonLiquidSky'
                object GridFinansalView: TcxGridDBTableView
                  Navigator.Buttons.CustomButtons = <>
                  ScrollbarAnnotations.CustomAnnotations = <>
                  OnCanFocusRecord = GridTeklifWizardDetayViewCanFocusRecord
                  DataController.DataSource = DtsFinansal
                  DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <
                    item
                      Format = ',0.00;(,0.00)'
                      Kind = skSum
                      FieldName = 'DOVIZ_TUTARI'
                    end
                    item
                      Format = ',0.00;(,0.00)'
                      Kind = skCount
                    end
                    item
                      Format = ',0.00;(,0.00)'
                      Kind = skSum
                    end
                    item
                      Format = ',0.00;(,0.00)'
                      Kind = skSum
                    end>
                  DataController.Summary.SummaryGroups = <>
                  OptionsBehavior.AlwaysShowEditor = True
                  OptionsBehavior.CellHints = True
                  OptionsBehavior.FocusCellOnTab = True
                  OptionsCustomize.ColumnsQuickCustomization = True
                  OptionsData.Appending = True
                  OptionsSelection.HideSelection = True
                  OptionsView.GroupByBox = False
                  OptionsView.Indicator = True
                  object GridFinansalViewSEC: TcxGridDBColumn
                    Caption = 'Se'#231
                    DataBinding.FieldName = 'SEC'
                    PropertiesClassName = 'TcxCheckBoxProperties'
                  end
                  object GridFinansalViewTARIH: TcxGridDBColumn
                    Caption = 'Tarih'
                    DataBinding.FieldName = 'TARIH'
                    PropertiesClassName = 'TcxDateEditProperties'
                  end
                  object GridFinansalViewKURUMAD: TcxGridDBColumn
                    Caption = 'Kurum'
                    DataBinding.FieldName = 'KURUMAD'
                    PropertiesClassName = 'TcxButtonEditProperties'
                    Properties.Buttons = <
                      item
                        Default = True
                        Kind = bkEllipsis
                      end>
                    Properties.OnButtonClick = GridFinansalViewKURUMADPropertiesButtonClick
                    Width = 189
                  end
                  object GridFinansalViewILGILIAD: TcxGridDBColumn
                    Caption = #304'lgili'
                    DataBinding.FieldName = 'ILGILIAD'
                    PropertiesClassName = 'TcxButtonEditProperties'
                    Properties.Buttons = <
                      item
                        Default = True
                        Kind = bkEllipsis
                      end>
                    Properties.OnButtonClick = GridFinansalViewILGILIADPropertiesButtonClick
                    Width = 194
                  end
                  object GridFinansalViewACIKLAMA: TcxGridDBColumn
                    Caption = 'A'#231#305'klama'
                    DataBinding.FieldName = 'ACIKLAMA'
                    Width = 400
                  end
                end
                object cxGridLevel2: TcxGridLevel
                  GridView = GridFinansalView
                end
              end
            end
          end
          object ToolBar3: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1124
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
            Images = Tablo.PNGImageList1
            List = True
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 2
            Transparent = True
            object btnKaydetTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 10
              ImageName = 'PngImage9'
              Visible = False
              OnClick = btnKaydetTusClick
            end
            object ToolButton9: TToolButton
              Left = 74
              Top = 0
              Width = 8
              Caption = 'ToolButton9'
              ImageIndex = 17
              ImageName = 'PngImage16'
              Style = tbsSeparator
            end
            object YaziciYaz: TToolButton
              Left = 82
              Top = 0
              Caption = 'Yazd'#305'r'
              DropdownMenu = PopupMenuYaz
              ImageIndex = 16
              ImageName = 'PngImage15'
              Style = tbsTextButton
            end
            object btnEPosta: TToolButton
              Left = 156
              Top = 0
              Caption = 'E-Posta'
              ImageIndex = 41
              ImageName = 'PngImage41'
              OnClick = BaskiOnizlemeMenuClick
            end
            object ToolButton8: TToolButton
              Left = 230
              Top = 0
              Width = 8
              Caption = 'ToolButton1'
              ImageIndex = 9
              ImageName = 'PngImage8'
              Style = tbsSeparator
            end
            object KopyalaTus: TToolButton
              Left = 238
              Top = 0
              Caption = 'Kopyala'
              DropdownMenu = PopupMenuKopya
              Enabled = False
              ImageIndex = 20
              ImageName = 'PngImage20'
            end
            object ToolButton12: TToolButton
              Left = 312
              Top = 0
              Width = 8
              Caption = 'ToolButton12'
              ImageIndex = 15
              ImageName = 'PngImage14'
              Style = tbsSeparator
            end
            object RevizeTus: TToolButton
              Left = 320
              Top = 0
              Caption = 'Revize'
              ImageIndex = 19
              ImageName = 'PngImage19'
              Visible = False
              OnClick = BuMusteriyeKopyalaClick
            end
            object ToolButton10: TToolButton
              Left = 394
              Top = 0
              Width = 8
              Caption = 'ToolButton10'
              ImageIndex = 20
              ImageName = 'PngImage20'
              Style = tbsSeparator
            end
            object Oncetus: TToolButton
              Left = 402
              Top = 0
              Caption = #214'nceki'
              ImageIndex = 13
              ImageName = 'PngImage12'
              Visible = False
              OnClick = OncetusClick
            end
            object SonraTus: TToolButton
              Left = 476
              Top = 0
              Caption = 'Sonraki'
              ImageIndex = 14
              ImageName = 'PngImage13'
              Visible = False
              OnClick = SonraTusClick
            end
            object ToolButton5: TToolButton
              Left = 550
              Top = 0
              Width = 8
              Caption = 'ToolButton5'
              ImageIndex = 15
              ImageName = 'PngImage14'
              Style = tbsSeparator
            end
          end
        end
        object TabSheetMetinler: TcxTabSheet
          Tag = 1
          Caption = 'Metinler'
          ImageIndex = 2
          object Panel4: TPanel
            Left = 0
            Top = 0
            Width = 1130
            Height = 265
            Align = alTop
            TabOrder = 0
            object Panel10: TPanel
              Left = 1
              Top = 1
              Width = 499
              Height = 263
              Align = alLeft
              Caption = 'Panel10'
              TabOrder = 0
              object Panel5: TPanel
                Left = 1
                Top = 1
                Width = 497
                Height = 20
                Align = alTop
                Caption = #220'st bilgi 1'
                TabOrder = 0
              end
              object MemoUstbilgi1: TcxDBRichEdit
                Left = 1
                Top = 21
                Align = alClient
                DataBinding.DataField = 'USTBILGI'
                DataBinding.DataSource = DtsTeklif
                PopupMenu = PMMetinler
                Properties.Alignment = taLeftJustify
                Properties.ScrollBars = ssVertical
                TabOrder = 1
                Height = 241
                Width = 497
              end
            end
            object Panel11: TPanel
              Left = 500
              Top = 1
              Width = 629
              Height = 263
              Align = alClient
              Caption = 'Panel10'
              TabOrder = 1
              object Panel12: TPanel
                Left = 1
                Top = 1
                Width = 627
                Height = 20
                Align = alTop
                Caption = #220'st bilgi 2'
                TabOrder = 0
              end
              object MemoUstBilgi2: TcxDBRichEdit
                Left = 1
                Top = 21
                Align = alClient
                DataBinding.DataField = 'USTBILGI2'
                DataBinding.DataSource = DtsTeklif
                PopupMenu = PMMetinler
                Properties.ScrollBars = ssVertical
                TabOrder = 1
                Height = 241
                Width = 627
              end
            end
          end
          object Panel2: TPanel
            Left = 0
            Top = 265
            Width = 1130
            Height = 274
            Align = alClient
            Caption = 'Panel2'
            TabOrder = 1
            object Panel7: TPanel
              Left = 501
              Top = 1
              Width = 500
              Height = 272
              Align = alLeft
              TabOrder = 1
              object Panel8: TPanel
                Left = 1
                Top = 1
                Width = 498
                Height = 21
                Align = alTop
                Caption = 'Alt Bilgi 2'
                TabOrder = 0
              end
              object MemoAltBilgi2: TcxDBRichEdit
                Left = 1
                Top = 22
                Align = alClient
                DataBinding.DataField = 'ALTBILGI2'
                DataBinding.DataSource = DtsTeklif
                PopupMenu = PMMetinler
                Properties.ScrollBars = ssVertical
                TabOrder = 1
                Height = 249
                Width = 498
              end
            end
            object Panel6: TPanel
              Left = 1
              Top = 1
              Width = 500
              Height = 272
              Align = alLeft
              TabOrder = 0
              object Panel9: TPanel
                Left = 1
                Top = 1
                Width = 498
                Height = 21
                Align = alTop
                Caption = 'Alt Bilgi 1'
                TabOrder = 0
              end
              object MemoAltBilgi1: TcxDBRichEdit
                Left = 1
                Top = 22
                Align = alClient
                DataBinding.DataField = 'ALTBILGI'
                DataBinding.DataSource = DtsTeklif
                PopupMenu = PMMetinler
                Properties.ScrollBars = ssVertical
                TabOrder = 1
                Height = 249
                Width = 498
              end
            end
          end
        end
        object SheetOnaylar: TcxTabSheet
          Caption = 'Onaylar'
          ImageIndex = 2
          TabVisible = False
          object cxGrid1: TcxGrid
            Left = 0
            Top = 27
            Width = 1130
            Height = 512
            Align = alClient
            PopupMenu = PopupMenuFatura
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            LookAndFeel.SkinName = 'LondonLiquidSky'
            object cxGridDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsTeklifOnay
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <
                item
                  Format = '.0.00;'
                  Kind = skSum
                  FieldName = 'DOVIZ_TUTARI'
                end
                item
                  Format = '.0.00;'
                  Kind = skSum
                  FieldName = 'BIRIMFIYAT'
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.AlwaysShowEditor = True
              OptionsBehavior.FocusCellOnTab = True
              OptionsSelection.HideSelection = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object cxGridDBTableView1ROL: TcxGridDBColumn
                Caption = 'Rol'
                DataBinding.FieldName = 'ROL'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle12
                Width = 80
              end
              object cxGridDBTableView1KULLANICI: TcxGridDBColumn
                Caption = 'Kullan'#305'c'#305
                DataBinding.FieldName = 'KULLANICI'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle12
                Width = 77
              end
              object cxGridDBTableView1ONAY: TcxGridDBColumn
                Caption = 'Onay'
                DataBinding.FieldName = 'ONAY'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle12
              end
              object cxGridDBTableView1ONAYTARIHI: TcxGridDBColumn
                Caption = 'Onay Tarihi'
                DataBinding.FieldName = 'ONAYTARIHI'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle12
                Width = 100
              end
              object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle12
                Width = 546
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = cxGridDBTableView1
            end
          end
          object ToolBar4: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 1124
            Height = 24
            Margins.Bottom = 0
            AutoSize = True
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
            List = True
            ParentColor = False
            ParentFont = False
            PopupMenu = PopupMenuFatura
            ShowCaptions = True
            TabOrder = 1
            Transparent = True
            object ToolButton1: TToolButton
              Left = 0
              Top = 0
              Caption = 'Onayla'
              ImageIndex = 23
            end
            object ToolButton6: TToolButton
              Left = 46
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 24
            end
          end
        end
      end
      object LabelKod: TcxLabel
        Left = 159
        Top = 3
        Cursor = crHandPoint
        Caption = 'Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -19
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
      end
      object LabelAd: TcxLabel
        Left = 297
        Top = 2
        Cursor = crHandPoint
        Caption = 'Ad'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -19
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelAdClick
      end
      object cxDBLabel5: TcxDBLabel
        Left = 160
        Top = 32
        DataBinding.DataField = 'REHBERID'
        DataBinding.DataSource = DtsTeklif
        Transparent = True
        Height = 21
        Width = 50
      end
      object cxDBLabel2: TcxDBLabel
        Left = 27
        Top = 42
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsTeklif
        Transparent = True
        Height = 21
        Width = 42
      end
      object lblMusteriTel: TcxLabel
        Left = 684
        Top = 32
        Caption = 'Tel'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lblMusteriEposta: TcxLabel
        Left = 685
        Top = 46
        Caption = 'Eposta'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lblMusteriAdres: TcxLabel
        Left = 300
        Top = 34
        AutoSize = False
        Caption = 'Adres'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 30
        Width = 372
      end
    end
    object DokumanEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Yorum / Medya'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnEnterPage = DokumanEkrEnterPage
      object Panel1: TPanel
        Left = 0
        Top = 599
        Width = 1138
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
          Width = 990
        end
        object BtnMesajGonder: TcxButton
          Left = 991
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
          Left = 1076
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
        Top = 579
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
        AnchorX = 1138
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 1138
        Height = 509
        Align = alClient
        TabOrder = 2
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
            PropertiesClassName = 'TcxMemoProperties'
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.ScrollBars = ssVertical
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
    object TarihceEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Tarih'#231'e'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      OnEnterPage = TarihceEkrEnterPage
      object Panel3: TPanel
        Left = 0
        Top = 70
        Width = 1138
        Height = 570
        Align = alClient
        BevelOuter = bvNone
        Color = 14540253
        ParentBackground = False
        TabOrder = 0
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1132
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 48
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
          TabOrder = 0
          Transparent = True
        end
        object SQLTemel: TcxMemo
          Left = 100
          Top = 81
          Lines.Strings = (
            'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE '
            'name LIKE '
            #39'#OZLUK_:SPID_%'#39')'
            'DROP TABLE #OZLUK_:SPID_'
            ''
            'CREATE TABLE #OZLUK_:SPID_('
            #9'[SIRA] [smallint] NULL,'
            #9'[ETIKET] [nvarchar](50) NULL,'
            #9'[BILGI] [nvarchar](100) NULL,'
            #9'[ORJINAL] [nvarchar](100) NULL,'
            #9'[GIRIS] [nvarchar](50) NULL,'
            #9'[KAYNAK] [nvarchar](255) NULL,'
            '                [ZORUNLU] [bit] NULL'
            ')'
            'INSERT INTO #OZLUK_:SPID_'
            'select '
            'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,'
            'RA.GIRIS'
            ',RA.KAYNAK,RA.ZORUNLU '
            'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
            'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
            'where RB.YERI= :Yeri  and YER_ID= :Yeri_Id1   '
            ''
            'union all'
            ''
            'select  SIRA, ETIKET, '
            'BILGI='#39#39', ORJINAL='#39#39'  ,GIRIS,KAYNAK,ZORUNLU from'
            'REHBERAYAR  where  YERI=3  '
            'and ETIKET not in (select ETIKET from REHBERBILGI '
            'where  YERI=3 and YER_ID= :Yeri_Id2)'
            'order by 1'
            ''
            'select * from #OZLUK_:SPID_')
          TabOrder = 2
          Visible = False
          Height = 91
          Width = 303
        end
        object cxGridTarihce: TcxGrid
          Left = 0
          Top = 27
          Width = 1138
          Height = 543
          Align = alClient
          TabOrder = 1
          LookAndFeel.NativeStyle = False
          object cxGridTarihceDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsTeklifHareket
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsSelection.CellSelect = False
            OptionsView.CellAutoHeight = True
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridTarihceDBTableView1FIRMA: TcxGridDBColumn
              Caption = 'Kullan'#305'c'#305
              DataBinding.FieldName = 'FIRMA'
              DataBinding.IsNullValueType = True
              Width = 126
            end
            object cxGridTarihceDBTableView1EKLEMETARIHI: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Width = 113
            end
            object cxGridTarihceDBTableView1ESKIDURUM: TcxGridDBColumn
              Caption = #214'nceki'
              DataBinding.FieldName = 'ESKIDURUM'
              DataBinding.IsNullValueType = True
              Width = 92
            end
            object cxGridTarihceDBTableView1YENIDURUM: TcxGridDBColumn
              Caption = 'Sonraki'
              DataBinding.FieldName = 'YENIDURUM'
              DataBinding.IsNullValueType = True
              Width = 94
            end
            object cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 474
            end
          end
          object cxGridTarihceLevel1: TcxGridLevel
            GridView = cxGridTarihceDBTableView1
          end
        end
      end
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 7
      Width = 121
    end
    object cxSplitter1: TcxSplitter
      Left = 0
      Top = 0
      Width = 7
      Height = 640
      NativeBackground = False
      Control = PanelSol
      Color = clSkyBlue
      ParentColor = False
    end
  end
  object SQLMemoTeklifTarihce: TcxMemo
    Left = 909
    Top = 312
    Lines.Strings = (
      'declare @pRehID integer'
      'Set @pRehID = :pRehID'
      ''
      'BEGIN TRY'
      'select'
      '--TOP10'
      'USTID=ID,'
      'ALTID=ID,'
      '*'
      'into #tmpTeklif'
      'from TEKLIF T1'
      ''
      'where DURUM <> 5 and REHBERID=@pRehID'
      'order by TARIH desc;'
      ''
      'select * from #tmpTeklif'
      'union all'
      'select'
      
        'USTID=(select T3.ID from TEKLIF T3 where DURUM<>5 and T3.REHBERI' +
        'D=@pRehID and T2.TEKLIFNO=T3.TEKLIFNO),'
      'ALTID=T2.ID,'
      '* from'
      'TEKLIF T2'
      ''
      'where T2.DURUM=5 and T2.REHBERID=@pRehID'
      ''
      
        'and exists (select USTID from #tmpTeklif Tmp where Tmp.TEKLIFNO ' +
        '= T2.TEKLIFNO)'
      ''
      'ORDER BY TARIH desc'
      ''
      'DROP TABLE #tmpTeklif'
      'END TRY'
      'BEGIN CATCH'
      '--print('#39'tmpYok'#39')'
      'END CATCH')
    Style.Color = clHighlight
    TabOrder = 2
    Visible = False
    Height = 41
    Width = 806
  end
  object TabImaj: TFDQuery
    SQL.Strings = (
      
        'SELECT ID, YERI, YER_ID,DURUM, ICDIS, BELGENO, BELGEADI, TUR, AC' +
        'IKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'YERI = :PYeri AND'
      'YER_ID=:PYer_ID')
    Left = 838
    Top = 4
    ParamData = <
      item
        Name = 'PYeri'
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end
      item
        Name = 'PYer_ID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 885
    Top = 12
  end
  object OpenDialog1: TOpenDialog
    Left = 673
    Top = 18
  end
  object PopupMenuFatura: TPopupMenu
    Left = 169
    Top = 179
    object MiktarskontosuGir1: TMenuItem
      Caption = 'Tutar '#304'skontosu Gir'
      object KDVHariTutarGir1: TMenuItem
        Caption = 'KDV Hari'#231' Tutar'#305' Gir'
        OnClick = KDVHariTutarGir1Click
      end
      object KDVHariTutarGir2: TMenuItem
        Tag = 1
        Caption = 'KDV Dahil Tutar'#305' Gir'
        OnClick = KDVHariTutarGir1Click
      end
    end
    object e1: TMenuItem
      Caption = 'Y'#252'zde '#304'skontosu Gir'
      object skonto1: TMenuItem
        Caption = #304'skonto1'
        object N51: TMenuItem
          Caption = '% 0'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N52: TMenuItem
          Tag = 5
          Caption = '% 5'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N101: TMenuItem
          Tag = 10
          Caption = '% 10'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N151: TMenuItem
          Tag = 15
          Caption = '% 15'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N201: TMenuItem
          Tag = 20
          Caption = '% 20'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N251: TMenuItem
          Tag = 25
          Caption = '% 25'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N301: TMenuItem
          Tag = 30
          Caption = '% 30'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N401: TMenuItem
          Tag = 40
          Caption = '% 40'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N501: TMenuItem
          Tag = 50
          Caption = '% 50'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object N1001: TMenuItem
          Tag = 100
          Caption = '% 100'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
        object zel1: TMenuItem
          Tag = -1
          Caption = #214'zel'
          Hint = #304'skonto1'
          OnClick = N51Click
        end
      end
      object skonto21: TMenuItem
        Caption = #304'skonto2'
        object N01: TMenuItem
          Caption = '% 0'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N53: TMenuItem
          Tag = 5
          Caption = '% 5'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N102: TMenuItem
          Tag = 10
          Caption = '% 10'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N152: TMenuItem
          Tag = 15
          Caption = '% 15'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N202: TMenuItem
          Tag = 20
          Caption = '% 20'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N252: TMenuItem
          Tag = 25
          Caption = '% 25'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N302: TMenuItem
          Tag = 30
          Caption = '% 30'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N402: TMenuItem
          Tag = 40
          Caption = '% 40'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N502: TMenuItem
          Tag = 50
          Caption = '% 50'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object N1002: TMenuItem
          Tag = 100
          Caption = '% 100'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
        object zel2: TMenuItem
          Tag = -1
          Caption = #214'zel'
          Hint = #304'skonto2'
          OnClick = N51Click
        end
      end
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object MenuUsteTasi: TMenuItem
      Caption = '^ Sat'#305'r'#305' '#220'ste Ta'#351#305
      OnClick = MenuUsteTasiClick
    end
    object MenuAltaTasi: TMenuItem
      Caption = 'v  Sat'#305'r'#305' Alta Ta'#351#305
      OnClick = MenuUsteTasiClick
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 152
    Top = 258
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11796479
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle11: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle12: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle13: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle14: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clSilver
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle15: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle16: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
  end
  object TabTeklifDetay: TFDQuery
    AutoCalcFields = False
    BeforePost = TabTeklifDetayBeforePost
    AfterPost = TabTeklifDetayAfterPost
    AfterDelete = TabTeklifDetayAfterDelete
    OnCalcFields = TabTeklifDetayCalcFields
    OnNewRecord = TabTeklifDetayNewRecord
    SQL.Strings = (
      ' '
      'Select T.* ,'
      
        'AD =  CASE WHEN T.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = T.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ' +
        'ID = T.URUNID)  END,'
      
        'KOD =  CASE WHEN T.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR W' +
        'HERE ID = T.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID' +
        '= T.URUNID )  END,'
      
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=T.PROJE' +
        'ID)  ,'
      
        'STOKMALIYET= isnull((select TOP 1 MALIYET from STOKMALIYET where' +
        ' TUR=2 and STOKID=T.URUNID and T.TUR=1 ),0.0),'
      
        'DONUSENMIKTAR=isnull((select top 1 T.MIKTAR*(SC.ADET2/SC.ADET1) ' +
        'from STOKCEVRIM SC where SC.STOKID=T.URUNID and T.TUR=1 and T.BI' +
        'RIM=SC.BIRIM1 and SC.BIRIM2=(select DONUSUMTURU from TEKLIF TK w' +
        'here TK.ID=T.TEKLIFID) ),0.0),'
      
        'EKIPMAN=(Select E.AD+'#39'('#39'+ER.SERINO+'#39')'#39' from EKIPMANREHBER ER inn' +
        'er join EKIPMANLAR E on E.ID=ER.EKIPMANID  Where ER.ID=T.EKIPMAN' +
        'ID)'
      'from TEKLIFDETAY T '
      'Where '
      'TEKLIFID = :Par1'
      'and ALTERNATIFNO = :Par2'
      ''
      ' '
      ' order by POZNO,KUR,ID')
    Left = 24
    Top = 389
    ParamData = <
      item
        Name = 'Par1'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'Par2'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end>
    object TabTeklifDetayID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabTeklifDetayTEKLIFID: TIntegerField
      FieldName = 'TEKLIFID'
    end
    object TabTeklifDetayALTERNATIFNO: TWordField
      FieldName = 'ALTERNATIFNO'
    end
    object TabTeklifDetayREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabTeklifDetaySEC: TBooleanField
      FieldName = 'SEC'
    end
    object TabTeklifDetayURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabTeklifDetayTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabTeklifDetayACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
    end
    object TabTeklifDetayADET: TFMTBCDField
      FieldName = 'ADET'
      Precision = 24
      Size = 6
    end
    object TabTeklifDetayBIRIM: TWideStringField
      FieldName = 'BIRIM'
      Size = 8
    end
    object TabTeklifDetayMIKTAR: TFMTBCDField
      FieldName = 'MIKTAR'
      Precision = 24
      Size = 6
    end
    object TabTeklifDetayBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object TabTeklifDetayISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object TabTeklifDetayKDV: TSmallintField
      FieldName = 'KDV'
    end
    object TabTeklifDetayTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 24
      Size = 2
    end
    object TabTeklifDetayMALIYET: TCurrencyField
      FieldName = 'MALIYET'
    end
    object TabTeklifDetayKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabTeklifDetayKAR_YUZDE: TFloatField
      FieldName = 'KAR_YUZDE'
    end
    object TabTeklifDetayOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
    end
    object TabTeklifDetayMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 25
    end
    object TabTeklifDetayKASA: TSmallintField
      FieldName = 'KASA'
    end
    object TabTeklifDetayONAY: TBooleanField
      FieldName = 'ONAY'
    end
    object TabTeklifDetayEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabTeklifDetayEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabTeklifDetayDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabTeklifDetayDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabTeklifDetayDOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 24
      Size = 2
    end
    object TabTeklifDetayDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object TabTeklifDetayISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object TabTeklifDetayYERI: TIntegerField
      FieldName = 'YERI'
    end
    object TabTeklifDetayYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabTeklifDetayTESLIMTARIHI: TSQLTimeStampField
      FieldName = 'TESLIMTARIHI'
    end
    object TabTeklifDetayDOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object TabTeklifDetayKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object TabTeklifDetayVADE: TWordField
      FieldName = 'VADE'
    end
    object TabTeklifDetaySUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabTeklifDetaySIPBIRIMFIYAT: TCurrencyField
      FieldName = 'SIPBIRIMFIYAT'
    end
    object TabTeklifDetaySIPTUTAR: TCurrencyField
      FieldName = 'SIPTUTAR'
    end
    object TabTeklifDetayMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object TabTeklifDetayPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabTeklifDetayDOVIZKURDEGERI: TCurrencyField
      FieldName = 'DOVIZKURDEGERI'
    end
    object TabTeklifDetayRESIMGOSTER: TBooleanField
      FieldName = 'RESIMGOSTER'
    end
    object TabTeklifDetayTEKLIFONAY: TWordField
      FieldName = 'TEKLIFONAY'
    end
    object TabTeklifDetayIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object TabTeklifDetayMERKEZID: TIntegerField
      FieldName = 'MERKEZID'
    end
    object TabTeklifDetaySTOKDURUM: TFloatField
      FieldName = 'STOKDURUM'
    end
    object TabTeklifDetayEKIPMANID: TIntegerField
      FieldName = 'EKIPMANID'
    end
    object TabTeklifDetayMF: TFMTBCDField
      FieldName = 'MF'
      Precision = 24
      Size = 6
    end
    object TabTeklifDetayISKONTOLUBRMFIYAT: TFloatField
      FieldName = 'ISKONTOLUBRMFIYAT'
      ReadOnly = True
    end
    object TabTeklifDetayKDVDAHILBRMFIYAT: TFMTBCDField
      FieldName = 'KDVDAHILBRMFIYAT'
      ReadOnly = True
      Precision = 38
      Size = 9
    end
    object TabTeklifDetayKDVDAHILFIYAT: TFloatField
      FieldName = 'KDVDAHILFIYAT'
      ReadOnly = True
    end
    object TabTeklifDetaySATICIKODU: TIntegerField
      FieldName = 'SATICIKODU'
    end
    object TabTeklifDetayGIRISKAYNAK: TWordField
      FieldName = 'GIRISKAYNAK'
    end
    object TabTeklifDetayOZELKOD2: TWideStringField
      FieldName = 'OZELKOD2'
    end
    object TabTeklifDetayMEDYAVAR: TBooleanField
      FieldName = 'MEDYAVAR'
    end
    object TabTeklifDetayEN: TFMTBCDField
      FieldName = 'EN'
      OnChange = TabTeklifDetayENChange
      Precision = 12
      Size = 6
    end
    object TabTeklifDetayBOY: TFMTBCDField
      FieldName = 'BOY'
      OnChange = TabTeklifDetayENChange
      Precision = 12
      Size = 6
    end
    object TabTeklifDetayYUZEY: TFMTBCDField
      FieldName = 'YUZEY'
      Precision = 24
      Size = 6
    end
    object TabTeklifDetaySAYI: TFMTBCDField
      FieldName = 'SAYI'
      OnChange = TabTeklifDetayENChange
      Precision = 12
      Size = 6
    end
    object TabTeklifDetayAD: TWideStringField
      FieldName = 'AD'
      ReadOnly = True
      Size = 200
    end
    object TabTeklifDetayKOD: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
      Size = 25
    end
    object TabTeklifDetayPROJEKODU: TWideStringField
      FieldName = 'PROJEKODU'
      ReadOnly = True
      Size = 100
    end
    object TabTeklifDetaySTOKMALIYET: TCurrencyField
      FieldName = 'STOKMALIYET'
      ReadOnly = True
    end
    object TabTeklifDetayDONUSENMIKTAR: TFMTBCDField
      FieldName = 'DONUSENMIKTAR'
      ReadOnly = True
      Precision = 38
      Size = 6
    end
    object TabTeklifDetayEKIPMAN: TWideStringField
      FieldName = 'EKIPMAN'
      ReadOnly = True
      Size = 152
    end
    object TabTeklifDetayPOZNO: TIntegerField
      FieldName = 'POZNO'
    end
  end
  object DtsTeklifDetay: TDataSource
    DataSet = TabTeklifDetay
    OnStateChange = DtsTeklifDetayStateChange
    Left = 88
    Top = 381
  end
  object TabTeklif: TFDQuery
    AutoCalcFields = False
    AfterOpen = TabTeklifAfterOpen
    BeforeEdit = TabTeklifBeforeEdit
    BeforePost = TabTeklifBeforePost
    AfterPost = TabTeklifAfterPost
    AfterScroll = TabTeklifAfterScroll
    OnNewRecord = TabTeklifNewRecord
    SQL.Strings = (
      'SELECT * FROM TEKLIF WHERE ID=:PID')
    Left = 35
    Top = 318
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsTeklif: TDataSource
    DataSet = TabTeklif
    OnStateChange = DtsTeklifStateChange
    Left = 87
    Top = 243
  end
  object PopupMenuYaz: TPopupMenu
    Left = 79
    Top = 116
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
        OnClick = EMail1Click
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object PopupMenuKopya: TPopupMenu
    Left = 531
    Top = 168
    object BuMusteriyeKopyala: TMenuItem
      Caption = 'Bu M'#252#351'teriye'
      ImageIndex = 0
      OnClick = BuMusteriyeKopyalaClick
    end
    object BaskaMusteriyeKopyala: TMenuItem
      Tag = 1
      Caption = 'Ba'#351'ka M'#252#351'teriye'
      ImageIndex = 1
      OnClick = BuMusteriyeKopyalaClick
    end
  end
  object TabTeklifDetayYaz: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      'declare @CariDoviz varchar(5)'
      'set  @CariDoviz = :PCariDoviz'
      ''
      'SELECT * FROM'
      '('
      'Select TD.*,'
      
        'SECILEN_BIRIMFIYAT = (case when T.TEKLIF_DOVIZI<> @CariDoviz the' +
        'n (case when TD.DOVIZ_KURU=T.DOVIZ_KURU then TD.DOVIZ_BIRIMFIYAT' +
        ' else TD.BIRIMFIYAT/T.DOVIZKUR end) else TD.BIRIMFIYAT end),'
      
        'SECILEN_TUTAR =      (case when T.TEKLIF_DOVIZI<> @CariDoviz the' +
        'n (case when TD.DOVIZ_KURU=T.DOVIZ_KURU then TD.DOVIZ_TUTARI    ' +
        ' else TD.TUTAR/T.DOVIZKUR end) else TD.TUTAR end),'
      'KOD = CASE WHEN TD.TUR IN (1,11) THEN S.KOD ELSE M.KOD END,'
      'AD = CASE WHEN TD.TUR IN (1,11) THEN S.STOKADI ELSE M.AD END,'
      'URUNNO = CASE WHEN TD.TUR IN (1,11) THEN S.URUNNO ELSE '#39#39' END,'
      
        'BIRIMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2702 and ' +
        'DEGER=convert(varchar(10), TD.BIRIM) and DIL=-1),'
      
        'MARKA_AD = (select top 1 ANAHTAR from GENINI where BOLUM=-2701 a' +
        'nd DEGER=convert(varchar(10), S.MARKA) and DIL=-1), '
      
        'MODEL_AD = (select top 1 ANAHTAR from GENINI where BOLUM=convert' +
        '(int,'#39'-2701'#39'+convert(varchar(10),S.MARKA)) and DEGER=convert(var' +
        'char(10), S.MODEL) and DIL=-1),'
      
        'KATEGORI_AD = (select top 1 K.AD from KATEGORI K where S.KATEGOR' +
        'I=K.ID), '
      
        'GRUBU=(select top 1 ANAHTAR from GENINI where BOLUM=-2704 and DE' +
        'GER = convert(varchar(10), S.GRUBU) and DIL=-1),'
      
        'ALTERNATIF=CASE WHEN TD.ALTERNATIFNO = 1 THEN '#39'Teklif'#39' ELSE '#39'Alt' +
        'ernatif '#39'+convert(varchar(2), TD.ALTERNATIFNO) END,'
      
        'EKIPMANSERINO=(select ER.SERINO  from EKIPMANREHBER ER where ER.' +
        'ID=TD.EKIPMANID),'
      
        'EKIPMANAD=(select E.AD  from EKIPMANREHBER ER inner join EKIPMAN' +
        'LAR E on E.ID=ER.EKIPMANID where ER.ID=TD.EKIPMANID),'
      'S.BOYUT_EN,S.BOYUT_BOY,S.BOYUT_YUKSEKLIK,S.BOYUT_ALAN,'
      'STOK_NOTLAR = S.NOTLAR,'
      
        'RESIM = (select top 1 BELGE from IMAJ where REHBERID=S.ID and YE' +
        'RI=71 and YER_ID=S.ID and VARSAYILAN = 1) ,'
      
        'BARKOD=(select top 1 BARKOD from STOKBARKOD SB where SB.STOKID=S' +
        '.ID order by VARSAYILAN desc),'
      
        'DONUSENMIKTAR=isnull((select top 1 TD.MIKTAR*(SC.ADET2/SC.ADET1)' +
        ' from STOKCEVRIM SC where SC.STOKID=TD.URUNID and TD.TUR=1 and T' +
        'D.BIRIM=SC.BIRIM1 and SC.BIRIM2=T.DONUSUMTURU ),0.0)'
      ''
      
        '    from TEKLIFDETAY TD left outer join STOKLAR S on TD.URUNID=S' +
        '.ID'
      
        '                                        left outer join MASRAFGE' +
        'LIR M ON TD.URUNID = M.ID'
      
        '                                        left outer join TEKLIF T' +
        ' ON TD.TEKLIFID = T.ID'
      ''
      ''
      'Where '
      'TEKLIFID = :Par'
      ') AS X'
      ' order by SIRALAMA,ALTERNATIFNO,ID')
    Left = 532
    Top = 383
    ParamData = <
      item
        Name = 'PCariDoviz'
        DataType = ftWideString
        Size = 2
        Value = 'US'
      end
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
    object TabTeklifDetayYazID: TIntegerField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabTeklifDetayYazALTERNATIFNO: TWordField
      FieldName = 'ALTERNATIFNO'
    end
    object TabTeklifDetayYazREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabTeklifDetayYazSIRALAMA: TSmallintField
      FieldName = 'SIRALAMA'
    end
    object TabTeklifDetayYazURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabTeklifDetayYazTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabTeklifDetayYazADET: TFMTBCDField
      FieldName = 'ADET'
    end
    object TabTeklifDetayYazBIRIM: TWideStringField
      FieldName = 'BIRIM'
      Size = 8
    end
    object TabTeklifDetayYazMIKTAR: TFMTBCDField
      FieldName = 'MIKTAR'
    end
    object TabTeklifDetayYazBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 18
      Size = 6
    end
    object TabTeklifDetayYazISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object TabTeklifDetayYazKDV: TSmallintField
      FieldName = 'KDV'
    end
    object TabTeklifDetayYazTEKLIFID: TIntegerField
      FieldName = 'TEKLIFID'
    end
    object TabTeklifDetayYazTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 19
    end
    object TabTeklifDetayYazMALIYET: TCurrencyField
      FieldName = 'MALIYET'
    end
    object TabTeklifDetayYazKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabTeklifDetayYazKAR_YUZDE: TFloatField
      FieldName = 'KAR_YUZDE'
    end
    object TabTeklifDetayYazOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Size = 10
    end
    object TabTeklifDetayYazMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 10
    end
    object TabTeklifDetayYazKASA: TSmallintField
      FieldName = 'KASA'
    end
    object TabTeklifDetayYazEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabTeklifDetayYazEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabTeklifDetayYazDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabTeklifDetayYazDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabTeklifDetayYazDOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 19
    end
    object TabTeklifDetayYazDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object TabTeklifDetayYazISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object TabTeklifDetayYazYERI: TIntegerField
      FieldName = 'YERI'
    end
    object TabTeklifDetayYazYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabTeklifDetayYazTESLIMTARIHI: TSQLTimeStampField
      FieldName = 'TESLIMTARIHI'
    end
    object TabTeklifDetayYazDOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 19
    end
    object TabTeklifDetayYazKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object TabTeklifDetayYazVADE: TWordField
      FieldName = 'VADE'
    end
    object TabTeklifDetayYazSUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabTeklifDetayYazSIPBIRIMFIYAT: TCurrencyField
      FieldName = 'SIPBIRIMFIYAT'
    end
    object TabTeklifDetayYazSIPTUTAR: TCurrencyField
      FieldName = 'SIPTUTAR'
    end
    object TabTeklifDetayYazMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object TabTeklifDetayYazPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabTeklifDetayYazDOVIZKURDEGERI: TCurrencyField
      FieldName = 'DOVIZKURDEGERI'
    end
    object TabTeklifDetayYazKOD: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
      Size = 25
    end
    object TabTeklifDetayYazAD: TWideStringField
      FieldName = 'AD'
      ReadOnly = True
      Size = 100
    end
    object TabTeklifDetayYazBIRIMAD: TWideStringField
      FieldName = 'BIRIMAD'
      ReadOnly = True
      Size = 50
    end
    object TabTeklifDetayYazMARKA_AD: TWideStringField
      FieldName = 'MARKA_AD'
      ReadOnly = True
      Size = 50
    end
    object TabTeklifDetayYazMODEL_AD: TWideStringField
      FieldName = 'MODEL_AD'
      ReadOnly = True
      Size = 50
    end
    object TabTeklifDetayYazSTOK_NOTLAR: TWideStringField
      FieldName = 'STOK_NOTLAR'
      Size = 500
    end
    object TabTeklifDetayYazRESIM: TBlobField
      FieldName = 'RESIM'
      ReadOnly = True
    end
    object TabTeklifDetayYazGRUBU: TStringField
      FieldName = 'GRUBU'
      Size = 50
    end
    object TabTeklifDetayYazALTERNATIF: TStringField
      FieldName = 'ALTERNATIF'
      ReadOnly = True
      Size = 12
    end
    object TabTeklifDetayYazEKIPMANID: TIntegerField
      FieldName = 'EKIPMANID'
    end
    object TabTeklifDetayYazEKIPMANSERINO: TWideStringField
      FieldName = 'EKIPMANSERINO'
      ReadOnly = True
      Size = 50
    end
    object TabTeklifDetayYazEKIPMANAD: TWideStringField
      FieldName = 'EKIPMANAD'
      ReadOnly = True
      Size = 100
    end
    object TabTeklifDetayYazSTOKDURUM: TFMTBCDField
      FieldName = 'STOKDURUM'
    end
    object TabTeklifDetayYazDONUSENMIKTAR: TFMTBCDField
      FieldName = 'DONUSENMIKTAR'
      ReadOnly = True
    end
    object TabTeklifDetayYazSEC: TBooleanField
      FieldName = 'SEC'
    end
    object TabTeklifDetayYazONAY: TBooleanField
      FieldName = 'ONAY'
    end
    object TabTeklifDetayYazRESIMGOSTER: TBooleanField
      FieldName = 'RESIMGOSTER'
    end
    object TabTeklifDetayYazTEKLIFONAY: TWordField
      FieldName = 'TEKLIFONAY'
    end
    object TabTeklifDetayYazIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object TabTeklifDetayYazMERKEZID: TIntegerField
      FieldName = 'MERKEZID'
    end
    object TabTeklifDetayYazISKONTOLUBRMFIYAT: TFMTBCDField
      FieldName = 'ISKONTOLUBRMFIYAT'
      ReadOnly = True
    end
    object TabTeklifDetayYazKDVDAHILFIYAT: TFMTBCDField
      FieldName = 'KDVDAHILFIYAT'
      ReadOnly = True
      Precision = 33
      Size = 10
    end
    object TabTeklifDetayYazMF: TFMTBCDField
      FieldName = 'MF'
    end
    object TabTeklifDetayYazACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
    end
    object TabTeklifDetayYazBARKOD: TWideStringField
      FieldName = 'BARKOD'
      ReadOnly = True
      Size = 50
    end
    object TabTeklifDetayYazKATEGORI_AD: TWideStringField
      FieldName = 'KATEGORI_AD'
      ReadOnly = True
      Size = 50
    end
    object TabTeklifDetayYazKDVDAHILBRMFIYAT: TFMTBCDField
      FieldName = 'KDVDAHILBRMFIYAT'
      ReadOnly = True
      Precision = 38
      Size = 9
    end
    object TabTeklifDetayYazGIRISKAYNAK: TWordField
      FieldName = 'GIRISKAYNAK'
    end
    object TabTeklifDetayYazSATICIKODU: TIntegerField
      FieldName = 'SATICIKODU'
    end
    object TabTeklifDetayYazSECILEN_BIRIMFIYAT: TFMTBCDField
      FieldName = 'SECILEN_BIRIMFIYAT'
      ReadOnly = True
      Precision = 24
      Size = 6
    end
    object TabTeklifDetayYazSECILEN_TUTAR: TFMTBCDField
      FieldName = 'SECILEN_TUTAR'
      ReadOnly = True
      Precision = 24
      Size = 2
    end
    object TabTeklifDetayYazOZELKOD2: TWideStringField
      FieldName = 'OZELKOD2'
    end
    object TabTeklifDetayYazURUNNO: TWideStringField
      FieldName = 'URUNNO'
      ReadOnly = True
    end
    object TabTeklifDetayYazBOYUT_EN: TFMTBCDField
      FieldName = 'BOYUT_EN'
    end
    object TabTeklifDetayYazBOYUT_BOY: TFMTBCDField
      FieldName = 'BOYUT_BOY'
    end
    object TabTeklifDetayYazBOYUT_YUKSEKLIK: TFMTBCDField
      FieldName = 'BOYUT_YUKSEKLIK'
    end
    object TabTeklifDetayYazBOYUT_ALAN: TFMTBCDField
      FieldName = 'BOYUT_ALAN'
    end
  end
  object TabTeklifYaz: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      ''
      ''
      ''
      'declare @CariDoviz varchar(5)'
      'set  @CariDoviz = :PCariDoviz'
      ''
      'SELECT '
      #9'T.*,'
      
        '  ONAYLAYACAKAD=(select FIRMA from REHBER where ID=T.ONAYLAYACAK' +
        '),'
      
        '  ONAYLAYACAKISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolo' +
        'ck) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=R' +
        'B.SIRA AND RA.YERI=RB.YERI '
      
        #9#9'WHERE RB.YER_ID=(select RI.ID from REHBERILETISIM RI where RI.' +
        'REHBERID=T.ONAYLAYACAK and RI.VARSAYILAN=1)AND RA.VARSAYILAN=40)' +
        ','
      
        '  ONAYLAYACAKMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (noloc' +
        'k) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB' +
        '.SIRA AND RA.YERI=RB.YERI '
      
        #9#9'WHERE RB.YER_ID=(select RI.ID from REHBERILETISIM RI where RI.' +
        'REHBERID=T.ONAYLAYACAK and RI.VARSAYILAN=1) AND RA.VARSAYILAN=46' +
        '),'
      
        '  ONAYLAYACAKCEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock' +
        ') INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.' +
        'SIRA AND RA.YERI=RB.YERI '
      
        #9#9'WHERE RB.YER_ID=(select RI.ID from REHBERILETISIM RI where RI.' +
        'REHBERID=T.ONAYLAYACAK and RI.VARSAYILAN=1)AND RA.VARSAYILAN=42)' +
        ','
      '  '
      '  ONAYLAYANAD=(select FIRMA from REHBER where ID=T.ONAYLAYAN),  '
      
        '  ONAYLAYANISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock' +
        ') INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.' +
        'SIRA AND RA.YERI=RB.YERI '
      
        #9#9'WHERE RB.YER_ID=(select RI.ID from REHBERILETISIM RI where RI.' +
        'REHBERID=T.ONAYLAYAN and RI.VARSAYILAN=1) AND RA.VARSAYILAN=40),'
      
        '  ONAYLAYANMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock)' +
        ' INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.S' +
        'IRA AND RA.YERI=RB.YERI '
      
        #9#9'WHERE RB.YER_ID=(select RI.ID from REHBERILETISIM RI where RI.' +
        'REHBERID=T.ONAYLAYAN and RI.VARSAYILAN=1) AND RA.VARSAYILAN=46),'
      
        '  ONAYLAYANCEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) ' +
        'INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SI' +
        'RA AND RA.YERI=RB.YERI '
      
        #9#9'WHERE RB.YER_ID=(select RI.ID from REHBERILETISIM RI where RI.' +
        'REHBERID=T.ONAYLAYAN and RI.VARSAYILAN=1) AND RA.VARSAYILAN=42),'
      '  '
      
        '  SEVKCEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYIL' +
        'AN=42),'
      
        #9'SECILEN_TEKLIF_MATRAHI = (case when T.TEKLIF_DOVIZI<>@CariDoviz' +
        ' then T.DOVIZ_MATRAHI else T.TEKLIF_MATRAHI end),'
      
        #9'SECILEN_TEKLIF_ISKONTO = (case when T.TEKLIF_DOVIZI<>@CariDoviz' +
        ' then T.DOVIZ_ISKONTO_TUTARI else T.ISKONTO_TUTARI end),'
      
        #9'SECILEN_TEKLIF_KDV = (case when T.TEKLIF_DOVIZI<>@CariDoviz the' +
        'n T.DOVIZ_KDV_TUTARI else T.KDV_TUTARI end),'
      
        #9'SECILEN_TEKLIF_TUTAR = (case when TEKLIF_DOVIZI<>@CariDoviz the' +
        'n T.DOVIZ_TUTARI else T.TEKLIF_TUTARI end),'
      'R1.FIRMA as HAZIRLAYAN,ADSOYAD=RP.FIRMA,'
      
        '  ILGILIISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=40' +
        '),'
      
        '  ILGILIMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=46)' +
        ','
      
        '  ILGILIFAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=43),'
      
        '  ILGILICEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=42),'
      
        '  ILGILIADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=2)' +
        ','
      
        '  ILGILIPK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=4),'
      
        '  ILGILIILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=6),'
      
        '  ILGILIIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=RP.ID AND RA.VARSAYILAN=8),'
      
        #9'TUR_AD = (select top 1 ANAHTAR  from GENINI where BOLUM=-2901 a' +
        'nd DEGER=T.TURU and DIL=-1),'
      
        #9'TESLIM_SEKLI_AD = (select top 1 ANAHTAR  from GENINI where BOLU' +
        'M=-2903 and DEGER=T.TESLIM_SEKLI and DIL=-1),'
      
        #9'ODEME_AD = (select top 1 ANAHTAR  from GENINI where BOLUM=-2904' +
        ' and DEGER=T.ODEME and DIL=-1),'
      
        '                REVIZE_TEKLIFNO = Case When  T.DURUM = 5 then '#39'R' +
        'evize No'#39' else '#39'Teklif No'#39' end ,'
      #9'PROJEADI=(select PROJEADI from PROJELER where ID=T.PROJEID),'
      #9'PROJEKODU=(select PROJEKODU from PROJELER where ID=T.PROJEID),'
      ''
      
        ' SEVKISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYI' +
        'LAN=40),'
      
        ' SEVKMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYIL' +
        'AN=46),'
      
        ' SEVKFAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYILA' +
        'N=43),'
      
        ' SEVKCEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYILA' +
        'N=42),'
      
        ' SEVKADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYI' +
        'LAN=2),'
      
        ' SEVKPK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYILAN' +
        '=4),'
      
        ' SEVKILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYIL' +
        'AN=6),'
      
        ' SEVKIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=T.REHBERILETID AND RA.VARSAYILAN' +
        '=8),'
      ''
      ''
      #9'SERVISEKIPMANADI=case '
      
        #9#9'when S.DEMIRBAS=1 then (select DEMIRBASADI from DEMIRBAS D whe' +
        're D.ID=S.EKIPMANID)'
      
        #9#9'else (select E.AD from EKIPMANLAR E where E.ID=S.EKIPMANID)end' +
        ','
      #9'SERVISEKIPMANSERINO=S.SERINO,'
      #9'SERVISKONUSU=S.KONUSU,'
      #9'SERVISNO=S.SERVISNO'
      'FROM'
      #9'TEKLIF T '
      '    left outer join REHBER R1 on R1.ID = T.HAZIRLAYAN '
      
        '    left outer join REHBER RP on RP.ID = T.MUS_ILGILI AND RP.GRU' +
        'P=334 '
      '    left outer join SERVIS S on T.SERVISID=S.ID'
      'where T.ID=:PTid')
    Left = 535
    Top = 329
    ParamData = <
      item
        Name = 'PCariDoviz'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTid'
        DataType = ftWideString
        Size = 1
        Value = '5'
      end>
  end
  object DtsTeklifHareket: TDataSource
    DataSet = TabTeklifHareket
    OnStateChange = DtsTeklifStateChange
    Left = 173
    Top = 381
  end
  object TabTeklifHareket: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      'select * ,'
      'FIRMA=(select FIRMA from REHBER R where R.ID=TH.EKLEYEN)'
      'from TEKLIFHAREKET TH'
      'WHERE TEKLIFID=:PTeklifID'
      'order by EKLEMETARIHI')
    Left = 174
    Top = 330
    ParamData = <
      item
        Name = 'PTeklifID'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
  end
  object TabGecmisTeklifler: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      '')
    Left = 38
    Top = 175
  end
  object DtsGecmisTeklifler: TDataSource
    DataSet = TabGecmisTeklifler
    OnStateChange = DtsTeklifStateChange
    Left = 39
    Top = 259
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 489
    Top = 32
  end
  object TabStokDetay: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      'DECLARE '
      #9'@SQL '#9#9#9'NVARCHAR(4000),'
      #9'@KOLONBASLIK'#9'VARCHAR(100),'
      #9'@URUNADI'#9#9'VARCHAR(100),'
      #9'@URUNFIYATI'#9#9'VARCHAR(100),'
      #9'@URUNID'#9#9#9'INT,'
      #9'@TEKLIFID'#9#9'INT,'
      #9'@ETIKET'#9#9#9'VARCHAR(100),'
      #9'@BILGI'#9#9#9'VARCHAR(1000),'
      #9'@SIRA'#9#9#9'VARCHAR(10),'
      #9'@RESIM'#9#9#9'varbinary(max),'
      #9'@DETAYBOLMU'#9#9'VARCHAR(20),'
      #9'@KOLONSAYISI'#9'int,'
      #9'@MinKolonSayisi'#9'int'#9
      #9
      'SET @TEKLIFID = :PTeklifID'
      'SET @MinKolonSayisi = :PKolonSayisi'
      'SET @SQL = '#39'Create Table ##RehberBilgiView( '
      'ID'#9#9'INT IDENTITY(1,1),'
      'SIRA '#9'INT NULL,'
      'ETIKET'#9'VARCHAR(100) NULL,'
      'KONU'#9'VARCHAR(50) NULL,'
      'GIRIS'#9#9'INT NULL,'#39
      ''
      'select top 1 @KOLONSAYISI=count(*)'
      
        'FROM STOKLAR S inner join TEKLIFDETAY TD on S.ID=TD.URUNID and T' +
        'D.TUR=1 '
      'where '
      #9'TD.TEKLIFID=@TEKLIFID and'
      
        #9'S.DETAYBOLUMU in(select distinct DETAYBOLUMU from STOKLAR S whe' +
        're isnull(DETAYBOLUMU,'#39#39')<>'#39#39'and S.ID in(select URUNID from TEKL' +
        'IFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID))'
      'group by DETAYBOLUMU'
      'order by 1 desc'
      ''
      'if @KOLONSAYISI<@MinKolonSayisi'
      'SET @KOLONSAYISI=@MinKolonSayisi'
      ''
      'DECLARE @count INT '
      'SET @count = 0 '
      'WHILE (@count < @KOLONSAYISI) '
      'BEGIN '
      
        '   SET @SQL = @SQL +'#39' ['#220'r'#252'n'#39'+CONVERT(varchar(5),@count+1)+'#39'] nva' +
        'rchar(1000) NULL ,'#39' '
      
        '   SET @SQL = @SQL +'#39' [Resim'#39'+CONVERT(varchar(5),@count+1)+'#39'] va' +
        'rbinary(MAX) NULL ,'#39' '
      '   SET @count = (@count + 1) '
      'END '
      'SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1 )+'#39')'#39
      'EXEC (@SQL)'
      ''
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      'SELECT RA.SIRA,RA.ETIKET,RA.BOLUM,RA.GIRIS'
      'FROM REHBERAYAR RA '
      
        'where YERI=88 and BOLUM in(select distinct DETAYBOLUMU from STOK' +
        'LAR S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select URUNI' +
        'D from TEKLIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID))'
      'order by BOLUM '
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      
        'select distinct -1,'#39#220'r'#252'n Ad'#305#39',DETAYBOLUMU,-1 from STOKLAR S wher' +
        'e isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select URUNID from TEK' +
        'LIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID)'
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      
        'select distinct 2147483640,'#39'Fiyat'#305#39',DETAYBOLUMU,2147483640 from ' +
        'STOKLAR S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select U' +
        'RUNID from TEKLIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID)'
      ''
      ''
      'DECLARE cur_Konular Cursor For '
      'select DETAYBOLUMU'
      'FROM STOKLAR S '
      
        'where S.DETAYBOLUMU in(select distinct DETAYBOLUMU from STOKLAR ' +
        'S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and  S.ID in (select URUNID f' +
        'rom TEKLIFDETAY T where T.TUR=1 and T.TEKLIFID=@TEKLIFID) )'
      'group by DETAYBOLUMU'
      'order by count(*) desc'
      'OPEN cur_Konular'
      'FETCH NEXT FROM cur_Konular INTO @DETAYBOLMU'
      'WHILE @@FETCH_STATUS = 0'
      #9'BEGIN '
      #9#9#9#9#9#9
      #9#9#9#9'DECLARE cur_Urunler cursor for '
      #9#9#9#9'select '
      #9#9#9#9#9'T.URUNID,--select * from TEKLIFDETAY'
      
        #9#9#9#9#9'KOLONADI='#39#220'r'#252'n'#39'+convert(varchar(5),ROW_NUMBER()OVER(order b' +
        'y T.URUNID)),'
      #9#9#9#9#9'S.STOKADI,'
      #9#9#9#9#9'URUNFIYAT=convert(varchar(50),T.TUTAR)+KUR'
      
        #9#9#9#9'from STOKLAR S inner join TEKLIFDETAY T on T.TUR=1 and T.URU' +
        'NID=S.ID'
      #9#9#9#9'where T.TEKLIFID=@TEKLIFID and S.DETAYBOLUMU=@DETAYBOLMU'
      #9#9#9#9'OPEN cur_Urunler'
      
        #9#9#9#9'FETCH NEXT FROM cur_Urunler INTO @URUNID,@KOLONBASLIK,@URUNA' +
        'DI,@URUNFIYATI'#9
      #9#9#9#9'WHILE @@FETCH_STATUS = 0'
      #9#9#9#9#9'BEGIN '
      ''
      
        #9#9#9#9#9#9'SET @SQL= '#39' UPDATE ##RehberBilgiView SET ['#39'+@KOLONBASLIK+'#39 +
        '] = '#39#39#39'+@URUNADI+'#39#39#39' WHERE KONU='#39#39#39'+@DETAYBOLMU+'#39#39#39' and SIRA=-1 ' +
        'and ETIKET = '#39#39#220'r'#252'n Ad'#305#39#39' '#39
      #9#9#9#9#9#9'exec(@SQL)'
      
        #9#9#9#9#9#9'SET @SQL= '#39' UPDATE ##RehberBilgiView SET ['#39'+@KOLONBASLIK+'#39 +
        '] = '#39#39#39'+@URUNFIYATI+'#39#39#39' WHERE KONU='#39#39#39'+@DETAYBOLMU+'#39#39#39' and SIRA=' +
        '2147483640 and ETIKET = '#39#39'Fiyat'#305#39#39' '#39
      #9#9#9#9#9#9'exec(@SQL)'#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9'DECLARE cur_Etiketler cursor for '
      #9#9#9#9#9#9#9#9'select RB2.ETIKET,RB2.BILGI,RB2.SIRA '
      #9#9#9#9#9#9#9#9'from --select * from REHBERBILGI'
      #9#9#9#9#9#9#9#9#9'REHBERBILGI RB2 inner join '
      
        #9#9#9#9#9#9#9#9#9'REHBERAYAR RA2 on RB2.SIRA=RA2.SIRA and RB2.ETIKET=RA2.' +
        'ETIKET'
      
        #9#9#9#9#9#9#9#9'where RA2.BOLUM=@DETAYBOLMU and RB2.YERI=88 and YER_ID=@' +
        'URUNID'
      #9#9#9#9#9#9#9#9'OPEN cur_Etiketler'
      #9#9#9#9#9#9#9#9'FETCH NEXT FROM cur_Etiketler INTO @ETIKET,@BILGI,@SIRA'#9
      #9#9#9#9#9#9#9#9'WHILE @@FETCH_STATUS = 0'
      #9#9#9#9#9#9#9#9#9'BEGIN '
      
        #9#9#9#9#9#9#9#9#9#9'SET @SQL= '#39' UPDATE ##RehberBilgiView SET ['#39'+@KOLONBASL' +
        'IK+'#39'] = '#39#39#39'+@BILGI+'#39#39#39' WHERE KONU='#39#39#39'+@DETAYBOLMU+'#39#39#39' and SIRA='#39 +
        '+@SIRA+'#39' and ETIKET = '#39#39#39'+@ETIKET+'#39#39#39' '#39
      #9#9#9#9#9#9#9#9#9#9'exec(@SQL)'#9#9#9#9#9#9#9#9#9#9#9#9#9#9#9#9
      
        #9#9#9#9#9#9#9#9#9#9'FETCH NEXT FROM cur_Etiketler INTO @ETIKET,@BILGI,@SIR' +
        'A'#9#9#9#9
      #9#9#9#9#9#9#9#9#9'END'#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9'CLOSE cur_Etiketler'
      #9#9#9#9#9#9#9#9'DEALLOCATE cur_Etiketler'
      ''
      ''
      #9#9#9#9#9#9#9#9'DECLARE cur_Resimler cursor for '
      #9#9#9#9#9#9#9#9'select RB2.ETIKET,RB2.BILGI,RB2.SIRA,RR.RESIM '
      #9#9#9#9#9#9#9#9'from --select * from REHBERBILGI'
      #9#9#9#9#9#9#9#9#9'REHBERBILGI RB2 inner join '
      
        #9#9#9#9#9#9#9#9#9'REHBERAYAR RA2 on RB2.SIRA=RA2.SIRA and RB2.ETIKET=RA2.' +
        'ETIKET left outer join'
      #9#9#9#9#9#9#9#9#9'REHBERBILGIRESIM RR on RB2.ID=RR.REHBERBILGIID'
      
        #9#9#9#9#9#9#9#9'where RA2.BOLUM=@DETAYBOLMU and RB2.YERI=88 and YER_ID=@' +
        'URUNID'
      #9#9#9#9#9#9#9#9'OPEN cur_Resimler'
      
        #9#9#9#9#9#9#9#9'FETCH NEXT FROM cur_Resimler INTO @ETIKET,@BILGI,@SIRA,@' +
        'RESIM'#9
      #9#9#9#9#9#9#9#9'WHILE @@FETCH_STATUS = 0'
      #9#9#9#9#9#9#9#9#9'BEGIN '
      
        #9#9#9#9#9#9#9#9#9#9'SET @SQL= '#39' UPDATE ##RehberBilgiView SET ['#39'+Replace(@K' +
        'OLONBASLIK,'#39#220'r'#252'n'#39','#39'Resim'#39')+'#39'] = @imageAlan WHERE KONU='#39#39#39'+@DETAY' +
        'BOLMU+'#39#39#39' and SIRA='#39'+@SIRA+'#39' and ETIKET = '#39#39#39'+@ETIKET+'#39#39#39' '#39
      
        #9#9#9#9#9#9#9#9#9#9'exec sp_executesql @SQL, N'#39'@imageAlan varbinary(max)'#39',' +
        '@imageAlan = @RESIM'#9#9#9#9#9#9#9#9#9#9#9#9#9#9#9
      
        #9#9#9#9#9#9#9#9#9#9'FETCH NEXT FROM cur_Resimler INTO @ETIKET,@BILGI,@SIRA' +
        ',@RESIM'#9#9#9#9
      #9#9#9#9#9#9#9#9#9'END'#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9'CLOSE cur_Resimler'
      #9#9#9#9#9#9#9#9'DEALLOCATE cur_Resimler'
      #9#9#9#9#9#9#9#9#9#9#9#9#9#9
      
        #9#9#9#9#9#9'FETCH NEXT FROM cur_Urunler INTO @URUNID,@KOLONBASLIK,@URU' +
        'NADI,@URUNFIYATI'#9#9#9#9
      #9#9#9#9#9'END'
      #9#9#9#9'CLOSE cur_Urunler'
      #9#9#9#9'DEALLOCATE cur_Urunler'#9#9
      ''
      #9#9'FETCH NEXT FROM cur_Konular INTO @DETAYBOLMU'#9#9
      #9'END '
      'CLOSE cur_Konular'
      'DEALLOCATE cur_Konular'#9
      ''
      'select * from ##RehberBilgiView order by KONU,SIRA'#9#9#9
      'drop table ##RehberBilgiView'#9
      '')
    Left = 817
    Top = 81
    ParamData = <
      item
        Name = 'PTeklifID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PKolonSayisi'
        Size = -1
        Value = Null
      end>
  end
  object frxStokDetay: TfrxDBDataset
    UserName = 'StokDetay1'
    CloseDataSource = False
    DataSet = TabStokDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 748
    Top = 103
  end
  object TabTeklifDetayResimli: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      'SELECT * FROM'
      '('
      'Select TD.*,'
      'KOD = CASE WHEN TD.TUR IN (1,11) THEN S.KOD ELSE M.KOD END,'
      'AD = CASE WHEN TD.TUR IN (1,11) THEN S.STOKADI ELSE M.AD END,'
      'URUNNO = CASE WHEN TD.TUR IN (1,11) THEN S.URUNNO ELSE '#39#39' END,'
      
        'BIRIMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2702 and ' +
        'DEGER=convert(varchar(10), TD.BIRIM) AND DIL=-1),'
      
        'MARKA_AD = (select top 1  ANAHTAR from GENINI where BOLUM=-2701 ' +
        'and DEGER=convert(varchar(10), S.MARKA) AND DIL=-1), '
      
        'MODEL_AD = (select top 1  ANAHTAR from GENINI where BOLUM=conver' +
        't(int,'#39'-2701'#39'+convert(varchar(10),S.MARKA)) and DEGER=convert(va' +
        'rchar(10), S.MODEL) AND DIL=-1),'
      'STOK_NOTLAR = S.NOTLAR,'
      
        'BARKOD=(select top 1 BARKOD from STOKBARKOD SB where SB.STOKID=S' +
        '.ID order by VARSAYILAN desc),'
      
        'RESIM = (select top 1 BELGE from IMAJ where REHBERID=S.ID and YE' +
        'RI=88 and YER_ID=S.ID and VARSAYILAN = 1)    '
      
        '    from TEKLIFDETAY TD left outer join STOKLAR S on TD.URUNID=S' +
        '.ID'
      
        '                                        left outer join MASRAFGE' +
        'LIR M ON TD.URUNID = M.ID'
      'Where '
      'TEKLIFID = :Par'
      'and RESIMGOSTER=1'
      ') AS X'
      ' order by ID')
    Left = 936
    Top = 118
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object frxTeklifDetayResimli: TfrxDBDataset
    UserName = 'TEKLIFDETAYRESIMLI'
    CloseDataSource = False
    DataSet = TabTeklifDetayResimli
    BCDToCurrency = False
    DataSetOptions = []
    Left = 810
    Top = 357
  end
  object TOPLAMLAR: TFDQuery
    SQL.Strings = (
      'EXEC SP_PRG_TeklifDipToplami :PRM1, :PRM2')
    Left = 719
    Top = 345
    ParamData = <
      item
        Name = 'PRM1'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end
      item
        Name = 'PRM2'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
  end
  object dtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 782
    Top = 388
  end
  object frxTOPLAMLAR: TfrxDBDataset
    UserName = 'TOPLAMLAR'
    CloseDataSource = False
    FieldAliases.Strings = (
      'TUR=TUR'
      'ACIKLAMA=ACIKLAMA'
      'DEGER=DEGER'
      'KUR=KUR'
      'DOVIZTUTARI=DOVIZTUTARI'
      'DOVIZ_KURU=DOVIZ_KURU'
      'SECILENTUTAR=SECILENTUTAR'
      'SECILENKUR=SECILENKUR')
    DataSet = TOPLAMLAR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 817
    Top = 427
  end
  object frxTEKLIFDETAY: TfrxDBDataset
    UserName = 'TEKLIFDETAY'
    CloseDataSource = False
    DataSet = TabTeklifDetayYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 610
    Top = 332
  end
  object frxTEKLIF: TfrxDBDataset
    UserName = 'TEKLIF'
    CloseDataSource = False
    DataSet = TabTeklifYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 83
    Top = 434
  end
  object TabHazirlayanDetay: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      'Declare @IletisimID integer, @RehberID integer'
      'set @RehberID = :PRehID'
      
        'select top 1 @IletisimID = ID from REHBERILETISIM where REHBERID' +
        '=@RehberID  order by VARSAYILAN desc'
      '    select'
      '    '#9'KOD,FIRMA,GRUP,KATEGORI,DURUM,OZELKOD,NOTLAR,YETKIKODU,'
      
        '    '#9'KATEGORIADI=(select top 1 ANAHTAR from GENINI where BOLUM=-' +
        '2205 and DEGER=KATEGORI and DIL=-1),'
      
        '    '#9'GOREVADI=(select top 1 ANAHTAR from GENINI where BOLUM=-220' +
        '5 and DEGER=KATEGORI and DIL=-1),'
      
        '    '#9'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=40),'
      
        '    '#9'CEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '2),'
      
        '    '#9'FAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '3),'
      
        '    '#9'ADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=2),'
      
        '    '#9'ILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=' +
        '6),'
      
        '    '#9'IL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=8)' +
        ','
      
        '    '#9'PK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4)' +
        ','
      
        '    '#9'VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILA' +
        'N=20),'
      
        '    '#9'VERGINO=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN' +
        '=22),'
      
        '    '#9'WEB=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '8),'
      
        '    '#9'EMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=46),'
      
        '    '#9'FATURABASLIK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (noloc' +
        'k) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB' +
        '.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSA' +
        'YILAN=10),'
      
        '    '#9'LOGO= (SELECT  TOP 1 BELGE FROM IMAJ I WHERE VARSAYILAN=1 A' +
        'ND YERI=11 AND YER_ID=@RehberID ),'
      
        '    '#9'VERGIDAI_KODU=(select TOP 1  VDKODU FROM VDLISTE VD WHERE V' +
        'D.VD =(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA' +
        '.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=20)),'
      
        '      VERGI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=' +
        '20)+'#39' / '#39'+(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=22' +
        ')'
      '      from'
      '      '#9'REHBER R'
      '      WHERE ID = @RehberID')
    Left = 346
    Top = 329
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
  end
  object frxHazirlayanDetay: TfrxDBDataset
    UserName = 'HazirlayanDetay'
    CloseDataSource = False
    DataSet = TabHazirlayanDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 277
    Top = 383
  end
  object PMMetinler: TPopupMenu
    Left = 288
    Top = 331
    object PmSablon: TMenuItem
      Caption = #350'ablon'
    end
  end
  object TabTeklifOnay: TFDQuery
    AutoCalcFields = False
    SQL.Strings = (
      'select '
      #9'* '
      'from '
      #9'ONAYLAR '
      'where '
      #9'DURUM=1 and '
      #9'YERI=99 and '
      #9'YER_ID=:PTekID '
      'order by '
      #9'SIRA')
    Left = 480
    Top = 357
    ParamData = <
      item
        Name = 'PTekID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
  end
  object DtsTeklifOnay: TDataSource
    DataSet = TabTeklifOnay
    Left = 480
    Top = 405
  end
  object TabFinansal: TFDQuery
    AfterPost = TabFinansalAfterPost
    OnCalcFields = TabFinansalCalcFields
    OnNewRecord = TabFinansalNewRecord
    SQL.Strings = (
      'select * from TEKLIFFINANSAL '
      'where TEKLIFID=:PTEKLIFID'
      'order by TARIH desc;')
    Left = 626
    Top = 220
    ParamData = <
      item
        Name = 'PTEKLIFID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
    object TabFinansalID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabFinansalTEKLIFID: TIntegerField
      FieldName = 'TEKLIFID'
    end
    object TabFinansalSEC: TBooleanField
      FieldName = 'SEC'
    end
    object TabFinansalTARIH: TSQLTimeStampField
      FieldName = 'TARIH'
    end
    object TabFinansalKURUMID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabFinansalILGILIID: TIntegerField
      FieldName = 'ILGILIID'
    end
    object TabFinansalACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 150
    end
    object TabFinansalKURUMAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'KURUMAD'
      Size = 150
      Calculated = True
    end
    object TabFinansalILGILIAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'ILGILIAD'
      Size = 100
      Calculated = True
    end
  end
  object DtsFinansal: TDataSource
    DataSet = TabFinansal
    OnStateChange = DtsFinansalStateChange
    Left = 689
    Top = 203
  end
  object frxFINANSMAN: TfrxDBDataset
    UserName = 'FINANSMAN'
    CloseDataSource = False
    DataSet = TabFinansalYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 381
    Top = 383
  end
  object TabFinansalYaz: TFDQuery
    AfterPost = TabFinansalAfterPost
    OnCalcFields = TabFinansalCalcFields
    OnNewRecord = TabFinansalNewRecord
    SQL.Strings = (
      'select'
      'KURUMKODU=R.KOD,KURUMADI=R.FIRMA,'
      
        'ADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=2),'
      
        'ILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN' +
        ' REHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=6),'
      
        'IL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN R' +
        'EHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=8),'
      
        'VD=(SELECT BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERA' +
        'YAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI=RB.' +
        'YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20),'
      
        'VNO=(SELECT RB.BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REH' +
        'BERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI' +
        '=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22),'
      
        'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=1'
      
        'and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AN' +
        'D RA.VARSAYILAN=40)'
      ''
      'from TEKLIFFINANSAL TF '
      'inner join REHBER R on R.ID=TF.REHBERID and TF.SEC=1'
      
        'left outer join REHBERILETISIM RI on RI.REHBERID=R.ID and VARSAY' +
        'ILAN=1'
      'where TF.TEKLIFID=:PTeklifId')
    Left = 618
    Top = 260
    ParamData = <
      item
        Name = 'PTEKLIFID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
  end
  object DtsHesapOzeti: TDataSource
    DataSet = TabHesapOzeti
    Left = 927
    Top = 380
  end
  object TabHesapOzeti: TFDQuery
    SQL.Strings = (
      
        'SELECT * from [dbo].[fn_CARIHESAPOZETI] (:PRehID,:PBirim,:FatTut' +
        'ari) ')
    Left = 928
    Top = 329
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PBirim'
        Size = -1
        Value = Null
      end
      item
        Name = 'FatTutari'
        Size = -1
        Value = Null
      end>
  end
  object frxHesapOzeti: TfrxDBDataset
    UserName = 'Hesap '#214'zeti'
    CloseDataSource = False
    DataSet = TabHesapOzeti
    BCDToCurrency = False
    DataSetOptions = []
    Left = 921
    Top = 432
  end
  object TabYorum: TFDQuery
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
    Left = 609
    Top = 385
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
    Left = 587
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 336
    Top = 40
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object N4: TMenuItem
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
    Left = 656
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
    Left = 432
    Top = 348
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
end
