object FaturaWizardDlg: TFaturaWizardDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Belge Sihirbaz'#305
  ClientHeight = 658
  ClientWidth = 1196
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object PanelSol: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 658
    Align = alLeft
    TabOrder = 0
    object FaturaTus: TcxButton
      Left = 3
      Top = 80
      Width = 80
      Height = 29
      Caption = 'Belge'
      Enabled = False
      TabOrder = 0
      OnClick = FaturaTusClick
    end
    object DetayTus: TcxButton
      Tag = 1
      Left = 3
      Top = 109
      Width = 80
      Height = 29
      Caption = 'Detay'
      Enabled = False
      TabOrder = 1
      OnClick = FaturaTusClick
    end
    object PlanlaTus: TcxButton
      Tag = 2
      Left = 3
      Top = 138
      Width = 80
      Height = 40
      Caption = 'Plan/'#214'deme'
      Enabled = False
      TabOrder = 2
      WordWrap = True
      OnClick = FaturaTusClick
    end
    object DokumanTus: TcxButton
      Tag = 3
      Left = 3
      Top = 178
      Width = 80
      Height = 29
      Caption = 'Yorum/Medya'
      Enabled = False
      TabOrder = 3
      OnClick = FaturaTusClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 1110
    Height = 658
    ActivePage = FaturaEkr
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
    ButtonFinish.Caption = '&Kapat'
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
      1110
      658)
    object FaturaEkr: TJvWizardInteriorPage
      Tag = 1
      AlignWithMargins = True
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'FATURA bilgileri'
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
      EnabledButtons = [bkLast, bkNext, bkFinish, bkCancel, bkHelp]
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      PopupMenu = PopupMenuEBelge
      OnExitPage = FaturaEkrExitPage
      OnNextButtonClick = FaturaEkrNextButtonClick
      object Panel3: TPanel
        Left = 0
        Top = 277
        Width = 1104
        Height = 333
        Align = alClient
        Caption = 'Panel3'
        TabOrder = 3
        ExplicitTop = 274
        ExplicitHeight = 336
        object PanelAlt: TPanel
          Left = 1
          Top = 167
          Width = 1102
          Height = 165
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
          ExplicitTop = 170
          DesignSize = (
            1102
            165)
          object GridFaturaToplam: TStringGrid
            Left = 26372
            Top = 25
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
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            GridLineWidth = 0
            ParentFont = False
            ScrollBars = ssNone
            TabOrder = 0
          end
          object gridFatToplam: TcxGrid
            Left = 758
            Top = 1
            Width = 343
            Height = 163
            Align = alRight
            BorderStyle = cxcbsNone
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
              OptionsView.GridLineColor = 11776947
              OptionsView.GridLines = glNone
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              OptionsView.RowSeparatorColor = 11776947
              object tvFatToplamlarColumn1: TcxGridDBColumn
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                MinWidth = 120
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.ShowEditButtons = isebNever
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.SortByDisplayText = isbtOff
                Options.Sorting = False
                Width = 120
                IsCaptionAssigned = True
              end
              object tvFatToplamlarColumn2: TcxGridDBColumn
                DataBinding.FieldName = 'DEGER'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                MinWidth = 65
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.ShowEditButtons = isebNever
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.SortByDisplayText = isbtOff
                Options.Sorting = False
                Width = 65
                IsCaptionAssigned = True
              end
              object tvFatToplamlarColumn3: TcxGridDBColumn
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
                MinWidth = 24
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.ShowEditButtons = isebNever
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.SortByDisplayText = isbtOff
                Options.Sorting = False
                Width = 24
              end
              object tvFatToplamlarColumn5: TcxGridDBColumn
                Caption = 'D'#246'viz Tutar'#305
                DataBinding.FieldName = 'DOVIZTUTARI'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                MinWidth = 65
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.ShowEditButtons = isebNever
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.SortByDisplayText = isbtOff
                Options.Sorting = False
                Width = 65
              end
              object tvFatToplamlarColumn6: TcxGridDBColumn
                Caption = 'D'#246'viz Kuru'
                DataBinding.FieldName = 'DOVIZ_KURU'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.ShowEditButtons = isebNever
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.SortByDisplayText = isbtOff
                Options.Sorting = False
                Width = 20
              end
            end
            object gridFatToplamLevel1: TcxGridLevel
              GridView = tvFatToplamlar
              Options.DetailFrameColor = 11776947
            end
          end
          object DovizPaneli: TPanel
            Left = 407
            Top = 6
            Width = 300
            Height = 139
            BevelEdges = []
            BevelOuter = bvNone
            TabOrder = 2
            DesignSize = (
              300
              139)
            object cxDBLabel5: TcxDBLabel
              Left = -411
              Top = 82
              Anchors = [akTop, akRight]
              DataBinding.DataField = 'KOCANNO'
              DataBinding.DataSource = DtsFatBaslik
              Style.TextColor = clGrayText
              Height = 21
              Width = 24
            end
            object LabelRaporDovizi: TcxLabel
              Left = 6
              Top = 10
              Caption = 'Rapor D'#246'vizi'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object ComboRaporDovizi: TcxDBComboBox
              Left = 100
              Top = 9
              RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              DataBinding.DataField = 'RAPORDOVIZ'
              DataBinding.DataSource = DtsFatBaslik
              Properties.ImmediatePost = True
              Properties.ImmediateUpdateText = True
              Properties.OnEditValueChanged = ComboRaporDoviziPropertiesEditValueChanged
              TabOrder = 2
              Width = 60
            end
            object EditKulKur: TcxDBCurrencyEdit
              Left = 160
              Top = 9
              TabStop = False
              RepositoryItem = Tablo.RepCurrencyDovizKuru
              DataBinding.DataField = 'DOVIZKUR'
              DataBinding.DataSource = DtsFatBaslik
              Enabled = False
              ParentFont = False
              Properties.DisplayFormat = ',0.0000;(,0.0000)'
              Properties.ReadOnly = True
              Style.Color = 11776947
              StyleDisabled.BorderColor = 11776947
              StyleDisabled.Color = 11776947
              StyleDisabled.TextColor = clBlack
              TabOrder = 3
              Width = 49
            end
            object cbDovizCinsi: TcxDBComboBox
              Left = 100
              Top = 34
              DataBinding.DataField = 'DOVIZ_CINSI'
              DataBinding.DataSource = DtsFatBaslik
              Properties.ImmediatePost = True
              Properties.ImmediateUpdateText = True
              Properties.OnEditValueChanged = cbDovizCinsiPropertiesEditValueChanged
              Properties.OnInitPopup = cbDovizCinsiPropertiesInitPopup
              TabOrder = 4
              Width = 60
            end
            object lbDoviz: TcxLabel
              Left = 7
              Top = 35
              Caption = 'Ekstre D'#246'vizi'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object LabelEkVergi: TcxLabel
              Left = 7
              Top = 61
              Caption = 'Ek Vergi'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object EditEkVergi: TcxDBCurrencyEdit
              Left = 100
              Top = 59
              DataBinding.DataField = 'EKVERGI'
              DataBinding.DataSource = DtsFatBaslik
              ParentFont = False
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Properties.ReadOnly = True
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clRed
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
              TabOrder = 7
              OnClick = EditEkVergiClick
              Width = 60
            end
            object cxDBLabel3: TcxDBLabel
              Left = 162
              Top = 59
              DataBinding.DataField = 'KUR'
              DataBinding.DataSource = DtsFatBaslik
              Height = 21
              Width = 29
            end
            object cxLabel7: TcxLabel
              Left = 7
              Top = 87
              Caption = 'Dil'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object cxDBImageComboBox2: TcxDBImageComboBox
              Left = 100
              Top = 83
              RepositoryItem = Tablo.RepDiller
              DataBinding.DataField = 'DIL'
              DataBinding.DataSource = DtsFatBaslik
              Properties.ImmediatePost = True
              Properties.ImmediateUpdateText = True
              Properties.Items = <
                item
                  Description = 'Tr'
                  ImageIndex = 0
                  Value = -1
                end
                item
                  Description = 'En'
                  Value = -2
                end>
              Properties.OnEditValueChanged = cbDovizCinsiPropertiesEditValueChanged
              TabOrder = 10
              Width = 60
            end
            object ComboFaturaDovizi: TcxDBComboBox
              Left = 100
              Top = 108
              DataBinding.DataField = 'FATURADOVIZI'
              DataBinding.DataSource = DtsFatBaslik
              Properties.ImmediatePost = True
              Properties.ImmediateUpdateText = True
              Properties.OnInitPopup = cxDBComboBox1PropertiesInitPopup
              TabOrder = 11
              Width = 60
            end
            object LabelFaturaDovizi: TcxLabel
              Left = 7
              Top = 109
              Caption = 'FATURA D'#246'vizi'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object DOVIZ_TUTARI: TcxDBCurrencyEdit
              Left = 222
              Top = 99
              Anchors = [akLeft, akBottom]
              DataBinding.DataField = 'DOVIZ_TUTARI'
              DataBinding.DataSource = DtsFatBaslik
              ParentFont = False
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Properties.ReadOnly = True
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 13
              Visible = False
              Width = 78
            end
          end
          object ProjePanel: TPanel
            Left = 1
            Top = 4
            Width = 405
            Height = 157
            BevelOuter = bvNone
            TabOrder = 3
            DesignSize = (
              405
              157)
            object MemoNOTLAR: TcxDBMemo
              Left = 87
              Top = 90
              Anchors = [akLeft, akTop, akBottom]
              DataBinding.DataField = 'ACIKLAMA'
              DataBinding.DataSource = DtsFatBaslik
              Properties.ScrollBars = ssVertical
              TabOrder = 0
              Height = 48
              Width = 281
            end
            object cxLabel17: TcxLabel
              Left = 4
              Top = 89
              Caption = 'Not 1'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object LabelAktivite: TcxLabel
              Left = 4
              Top = 46
              Caption = 'Ba'#287'l'#305' Aktivite '
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object LabelProje: TcxLabel
              Left = 4
              Top = 1
              Caption = 'Proje Kodu'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object BeditProje: TcxButtonEdit
              Left = 87
              Top = -3
              ParentShowHint = False
              Properties.Buttons = <
                item
                  Caption = '++'
                  Default = True
                  Hint = 'Ekle'
                  Kind = bkText
                end
                item
                  Caption = '+'
                  Hint = 'Sil'
                  Kind = bkText
                end
                item
                  Caption = '-'
                  Kind = bkText
                end>
              Properties.ReadOnly = True
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
              TabOrder = 4
              OnDblClick = BeditProjeDblClick
              Width = 281
            end
            object BeditBagliGorev: TcxButtonEdit
              Left = 87
              Top = 42
              ParentShowHint = False
              Properties.Buttons = <
                item
                  Default = True
                  Hint = 'Ekle'
                  Kind = bkEllipsis
                end
                item
                  Caption = '-'
                  Hint = 'Sil'
                  Kind = bkText
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = BeditBagliGorevPropertiesButtonClick
              ShowHint = True
              TabOrder = 5
              OnDblClick = BeditBagliGorevDblClick
              Width = 281
            end
            object cxLabel3: TcxLabel
              Left = 4
              Top = 68
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
            object BeditServis: TcxButtonEdit
              Left = 87
              Top = 66
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
              TabOrder = 7
              OnDblClick = BeditServisDblClick
              Width = 281
            end
            object cxDBTextEdit2: TcxDBTextEdit
              Left = 87
              Top = 138
              DataBinding.DataField = 'ACIKLAMA2'
              DataBinding.DataSource = DtsFatBaslik
              TabOrder = 8
              Width = 281
            end
            object cxLabel4: TcxLabel
              Left = 5
              Top = 135
              Caption = 'Not 2 '
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object comboTevkifat: TcxDBImageComboBox
              Left = 87
              Top = 138
              DataBinding.DataField = 'PLANID'
              DataBinding.DataSource = DtsFatBaslik
              ParentFont = False
              Properties.Items = <>
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 11
              Visible = False
              Width = 281
            end
            object LabelTevkifat: TcxLabel
              Left = 5
              Top = 135
              Caption = 'Tevkifat Nedeni'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Visible = False
            end
            object comboIstisna: TcxDBImageComboBox
              Left = 87
              Top = 138
              DataBinding.DataField = 'PLANID'
              DataBinding.DataSource = DtsFatBaslik
              ParentFont = False
              Properties.Items = <>
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              TabOrder = 12
              Visible = False
              Width = 281
            end
            object LabelIstisna: TcxLabel
              Left = 5
              Top = 135
              Caption = 'KDV '#304'stisna Nedeni'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
              Visible = False
            end
            object BeditDemirbas: TcxButtonEdit
              Left = 87
              Top = 19
              ParentShowHint = False
              Properties.Buttons = <
                item
                  Caption = '+'
                  Hint = 'Sil'
                  Kind = bkText
                end
                item
                  Caption = '-'
                  Kind = bkText
                end>
              Properties.ReadOnly = True
              Properties.OnButtonClick = BeditDemirbasPropertiesButtonClick
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
              TabOrder = 10
              Width = 281
            end
            object lblDemirbas: TcxLabel
              Left = 4
              Top = 24
              Caption = 'Demirba'#351
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
        end
        object GridFatura: TcxGrid
          Left = 1
          Top = 25
          Width = 1102
          Height = 142
          Align = alClient
          PopupMenu = PopupMenuFatura
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          LookAndFeel.SkinName = 'LondonLiquidSky'
          ExplicitHeight = 145
          object GridFaturaView: TcxGridDBTableView
            OnDblClick = GridFaturaViewDblClick
            OnKeyUp = GridFaturaViewKeyUp
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridFaturaViewCanFocusRecord
            OnCellClick = GridFaturaViewCellClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsFatura
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skSum
                FieldName = 'ISKTUTAR'
                Column = ColumnIskTutari
                VisibleForCustomization = False
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skCount
                Column = GridFaturaViewAD
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridFaturaViewADET1
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridFaturaViewTUTAR1
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridFaturaViewDOVIZ_TUTARI
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'EKMALIYET'
                Column = GridFaturaViewEKMALIYET
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'ORTKAR'
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'SONKAR'
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'MALIYET'
                Column = GridFaturaViewMALIYET
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridFaturaViewKDVTUTAR
              end>
            DataController.Summary.SummaryGroups = <>
            DateTimeHandling.IgnoreTimeForFiltering = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Appending = True
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Inserting = False
            OptionsSelection.HideFocusRectOnExit = False
            OptionsSelection.InvertSelect = False
            OptionsSelection.UnselectFocusedRecordOnExit = False
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridFaturaViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              Visible = False
              Options.Editing = False
            end
            object GridFaturaViewPOZNO: TcxGridDBColumn
              Caption = 'Poz No'
              DataBinding.FieldName = 'POZNO'
            end
            object GridFaturaViewTUR: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TUR'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.ImmediatePost = True
              Properties.Items = <>
              RepositoryItem = Tablo.RepFatDetayTur
              Options.Editing = False
              Width = 54
            end
            object GridFaturaViewKOD1: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = GridFaturaViewKOD1PropertiesButtonClick
              Options.Editing = False
              Width = 53
            end
            object GridFaturaViewURUNNO: TcxGridDBColumn
              Caption = #220'r'#252'n No'
              DataBinding.FieldName = 'URUNNO'
              Width = 80
            end
            object GridFaturaViewAD: TcxGridDBColumn
              Caption = 'Ad'
              DataBinding.FieldName = 'AD'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.ReadOnly = True
              Options.Editing = False
              Width = 87
            end
            object GridFaturaViewACIKLAMA1: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Options.Editing = False
              Width = 91
            end
            object GridFaturaViewADET1: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              Options.Editing = False
              Width = 46
            end
            object GridFaturaViewMF: TcxGridDBColumn
              DataBinding.FieldName = 'MF'
              Options.Editing = False
              Width = 34
            end
            object GridFaturaViewBIRIM1: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.repStokAnaBirim
              Options.Editing = False
              Width = 42
            end
            object GridFaturaViewBIRIMFIYAT1: TcxGridDBColumn
              Caption = 'Birim Fiyat'
              DataBinding.FieldName = 'BIRIMFIYAT'
              RepositoryItem = Tablo.RepCurrencyBF
              Options.Editing = False
              Width = 84
            end
            object GridFaturaViewISKONTO1: TcxGridDBColumn
              Caption = #304'sk1%'
              DataBinding.FieldName = 'ISKONTO'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Properties.MaxValue = 100.000000000000000000
              Properties.Nullable = False
              Properties.Nullstring = '0'
              Options.Editing = False
              Width = 34
            end
            object GridFaturaViewISKONTO2: TcxGridDBColumn
              Caption = #304'sk2%'
              DataBinding.FieldName = 'ISKONTO2'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Properties.MaxValue = 100.000000000000000000
              Properties.Nullable = False
              Properties.Nullstring = '0'
              Options.Editing = False
              Width = 35
            end
            object GridFaturaViewKDV1: TcxGridDBColumn
              DataBinding.FieldName = 'KDV'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.Alignment.Horz = taRightJustify
              Properties.ReadOnly = False
              Options.Editing = False
              Width = 41
            end
            object GridFaturaViewOTVMIKTAR: TcxGridDBColumn
              Caption = #214'TV'
              DataBinding.FieldName = 'OTVMIKTAR'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Properties.ReadOnly = False
              RepositoryItem = Tablo.RepCurrencyGenel
              Width = 38
            end
            object GridFaturaViewTUTAR1: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              RepositoryItem = Tablo.RepCurrencyGenel
              HeaderAlignmentHorz = taCenter
              Options.Editing = False
              Width = 58
            end
            object ColumnIskTutari: TcxGridDBColumn
              Caption = #304'sk Tutar'
              DataBinding.FieldName = 'ISKTUTAR'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
            end
            object GridFaturaViewMALIYET: TcxGridDBColumn
              Caption = 'Ort.Maliyet'
              DataBinding.FieldName = 'MALIYET'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
              Styles.Content = Tablo.cxStFaturaKontrol
              Width = 69
            end
            object GridFaturaViewEKMALIYET: TcxGridDBColumn
              Caption = 'Ek Maliyet'
              DataBinding.FieldName = 'EKMALIYET'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
              Styles.Content = Tablo.cxStFaturaKontrol
              Width = 69
            end
            object GridFaturaViewKUR: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              PropertiesClassName = 'TcxComboBoxProperties'
              Properties.ReadOnly = True
              Options.Editing = False
              Width = 47
            end
            object GridFaturaViewEKIPMAN: TcxGridDBColumn
              Caption = 'Ekipman'
              DataBinding.FieldName = 'EKIPMAN'
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = GridFaturaViewEKIPMANPropertiesButtonClick
              Visible = False
              Width = 300
            end
            object GridFaturaViewSERINO: TcxGridDBColumn
              Caption = 'Ekipman Serino'
              DataBinding.FieldName = 'SERINO'
            end
            object GridFaturaViewMERKEZID: TcxGridDBColumn
              Caption = 'Masraf Merkezi'
              DataBinding.FieldName = 'MERKEZID'
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Visible = False
              OnGetDisplayText = GridFaturaViewMERKEZIDGetDisplayText
              Options.Editing = False
              Width = 77
            end
            object GridFaturaViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn
              Caption = 'D'#246'viz Birim Fiyat'
              DataBinding.FieldName = 'DOVIZ_BIRIMFIYAT'
              RepositoryItem = Tablo.RepCurrencyBF
              Options.Editing = False
              Width = 91
            end
            object GridFaturaViewDOVIZ_KURU: TcxGridDBColumn
              Caption = 'D'#246'viz Cinsi'
              DataBinding.FieldName = 'DOVIZ_KURU'
              RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              Options.Editing = False
              Width = 61
            end
            object GridFaturaViewDOVIZ_TUTARI: TcxGridDBColumn
              Caption = 'D'#246'viz Tutar'#305
              DataBinding.FieldName = 'DOVIZ_TUTARI'
              RepositoryItem = Tablo.RepCurrencyGenel
              Options.Editing = False
              Width = 68
            end
            object GridFaturaViewDOVIZKURDEGERI: TcxGridDBColumn
              Caption = 'D'#246'viz Kuru'
              DataBinding.FieldName = 'DOVIZKURDEGERI'
              RepositoryItem = Tablo.RepCurrencyDovizKuru
              Options.Editing = False
              Width = 64
            end
            object GridFaturaViewIADEDURUM: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'IADEDURUM'
              DataBinding.IsNullValueType = True
              Visible = False
              Options.Editing = False
              Width = 57
            end
            object GridFaturaViewOZELKOD: TcxGridDBColumn
              Caption = #214'zel Kod'
              DataBinding.FieldName = 'OZELKOD'
              Visible = False
              Options.Editing = False
              Width = 53
            end
            object GridFaturaViewOZELKOD2: TcxGridDBColumn
              Caption = #214'zel Kod 2'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridFaturaViewPROJEKODU: TcxGridDBColumn
              Caption = 'Proje Kodu'
              DataBinding.FieldName = 'PROJEKODU'
              PropertiesClassName = 'TcxButtonEditProperties'
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
              Properties.ClearKey = 46
              Visible = False
              Options.Editing = False
              Width = 162
            end
            object GridFaturaViewVADE: TcxGridDBColumn
              Caption = 'Vade'
              DataBinding.FieldName = 'VADE'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = '0;-0'
              Properties.MaxValue = 255.000000000000000000
              Visible = False
              Options.Editing = False
              Width = 44
            end
            object GridFaturaViewKAMPANYAADI: TcxGridDBColumn
              Caption = 'Kampanya'
              DataBinding.FieldName = 'KAMPANYAADI'
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.ReadOnly = True
              Visible = False
              Options.Editing = False
              Width = 123
            end
            object GridFaturaViewKDVMUHAFIYETI: TcxGridDBColumn
              Caption = 'KDV Tevkifat'#305'(%)'
              DataBinding.FieldName = 'KDVMUHAFIYETI'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepTevkifatOrani
              Visible = False
              Options.Editing = False
              Width = 92
            end
            object GridFaturaViewSTOKDURUMDEGIS: TcxGridDBColumn
              Caption = 'Stok Durum De'#287'i'#351'tir'
              DataBinding.FieldName = 'STOKDURUMDEGIS'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Visible = False
              Options.Editing = False
            end
            object GridFaturaViewIZLEME: TcxGridDBColumn
              Caption = #304'zleme'
              DataBinding.FieldName = 'IZLEME'
              RepositoryItem = Tablo.RepStokIzleme
              Visible = False
              Options.Editing = False
            end
            object GridFaturaViewISKONTOLUBRMFIYAT: TcxGridDBColumn
              Caption = #304'skontolu Birim Fiyat'
              DataBinding.FieldName = 'ISKONTOLUBRMFIYAT'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
              Width = 103
            end
            object GridFaturaViewKDVDAHILFIYAT: TcxGridDBColumn
              Caption = 'KDV Dahil Birim Fiyat'
              DataBinding.FieldName = 'KDVDAHILFIYAT'
              RepositoryItem = Tablo.RepCurrencyGenel
              Visible = False
              Options.Editing = False
              Width = 127
            end
            object GridFaturaViewDEPO: TcxGridDBColumn
              Caption = 'Depo'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepStokTumDepolar
              Options.Editing = False
            end
            object GridFaturaViewKDVTUTAR: TcxGridDBColumn
              Caption = 'KDV Tutar'#305
              DataBinding.FieldName = 'KDVTUTAR'
              RepositoryItem = Tablo.RepCurrencyGenel
              Options.Editing = False
              Width = 56
            end
            object GridFaturaViewMIKTAR: TcxGridDBColumn
              Caption = 'Miktar'
              DataBinding.FieldName = 'MIKTAR'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Visible = False
            end
            object GridFaturaViewBIRIM2MIKTAR: TcxGridDBColumn
              Caption = 'Birim2 Miktar'
              DataBinding.FieldName = 'BIRIM2MIKTAR'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Visible = False
            end
            object GridFaturaViewBIRIM2AD: TcxGridDBColumn
              Caption = 'Birim2 Ad'
              DataBinding.FieldName = 'BIRIM2AD'
              Visible = False
            end
            object GridFaturaViewSATICIKODU: TcxGridDBColumn
              Caption = 'Personel'
              DataBinding.FieldName = 'SATICIADI'
            end
            object GridFaturaViewEN: TcxGridDBColumn
              Caption = 'En'
              DataBinding.FieldName = 'EN'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 0
              Properties.DisplayFormat = ',0;-,0'
            end
            object GridFaturaViewBOY: TcxGridDBColumn
              Caption = 'Boy'
              DataBinding.FieldName = 'BOY'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 0
              Properties.DisplayFormat = ',0;-,0'
            end
            object GridFaturaViewYUZEY: TcxGridDBColumn
              Caption = 'Yuzey'
              DataBinding.FieldName = 'YUZEY'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Options.Editing = False
            end
            object GridFaturaViewSAYI: TcxGridDBColumn
              Caption = 'Sayi'
              DataBinding.FieldName = 'SAYI'
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DecimalPlaces = 0
              Properties.DisplayFormat = ',0;-,0'
            end
          end
          object GridFaturaLevel1: TcxGridLevel
            GridView = GridFaturaView
          end
        end
        object ToolBarAlet: TToolBar
          Left = 1
          Top = 1
          Width = 1102
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 93
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
            Left = 93
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = SatirSilClick
          end
          object ToolButton10: TToolButton
            Left = 186
            Top = 0
            Width = 8
            Caption = 'ToolButton3'
            ImageIndex = 4
            ImageName = 'PngImage4'
            Style = tbsSeparator
          end
          object btnDonustur: TToolButton
            Left = 194
            Top = 0
            Caption = 'D'#246'n'#252#351't'#252'r'
            ImageIndex = 7
            ImageName = 'PngImage7'
            OnClick = btnDonusturClick
          end
          object ToolButton1: TToolButton
            Left = 287
            Top = 0
            Width = 8
            Caption = 'ToolButton4'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object ToolButton9: TToolButton
            Left = 295
            Top = 0
            Caption = 'Alta'
            ImageIndex = 3
            ImageName = 'PngImage3'
          end
          object ToolButton13: TToolButton
            Left = 388
            Top = 0
            Caption = #220'ste'
            ImageIndex = 3
            ImageName = 'PngImage3'
          end
          object TamEkranTus: TToolButton
            Left = 481
            Top = 0
            Caption = 'Tam Ekran'
            ImageIndex = 6
            ImageName = 'PngImage6'
            OnClick = TamEkranTusClick
          end
          object ToolButton4: TToolButton
            Left = 574
            Top = 0
            Width = 8
            Caption = 'ToolButton4'
            ImageIndex = 7
            ImageName = 'PngImage7'
            Style = tbsSeparator
          end
          object BtnDoviz: TToolButton
            Left = 582
            Top = 0
            Caption = 'D'#246'viz Kuru'
            ImageIndex = 9
            ImageName = 'PngImage9'
            OnClick = BtnDovizClick
          end
          object BtnBagliFatura: TToolButton
            Left = 675
            Top = 0
            Caption = 'Ba'#287'l'#305' Belgeler'
            DropdownMenu = PopupBagliBelgeler
            EnableDropdown = True
            ImageIndex = 10
            ImageName = 'PngImage10'
            Visible = False
          end
          object BtnBelgeZarfi: TToolButton
            Left = 768
            Top = 0
            Caption = 'Belge Zarflar'#305
            DropdownMenu = PopupBelgeZarfi
            EnableDropdown = True
            ImageIndex = 17
            ImageName = 'PngImage17'
            Visible = False
          end
        end
        object MemoFIFO: TMemo
          Left = 27
          Top = 59
          Width = 577
          Height = 25
          Color = clLime
          Lines.Strings = (
            'declare @StokID int, @CikisFaturaID int'
            'set @StokID = :PStokID'
            'set @CikisFaturaID=:PFaturaID'
            'select MALIYET=sum(ADET*GBIRIMTUTAR)'
            'from('
            #9#9'select '
            #9#9#9'GG.TUR,GG.URUNID,'
            #9#9#9'GG.GFATNO,CC.CFATNO,'
            #9#9#9'CFATID,CFATBASID,GFATID,GFATBASID,'
            #9#9#9'--GMIKTAR,'
            #9#9#9'--GKUMBASMIKTAR,'
            #9#9#9'--GKUMBITMIKTAR=GKUMBASMIKTAR+GMIKTAR,'#9
            #9#9#9'--CMIKTAR,'
            #9#9#9'--CKUMBASMIKTAR,'#9
            #9#9#9'--CKUMBITMIKTAR=CKUMBASMIKTAR+CMIKTAR,'
            #9#9#9'CBIRIMTUTAR,CTARIH,'
            #9#9#9'GBIRIMTUTAR,GTARIH,'
            #9#9#9'--GIRIS=(CKUMBASMIKTAR+CMIKTAR-GKUMBASMIKTAR),'
            #9#9#9'--CIKIS=(GKUMBASMIKTAR+GMIKTAR-CKUMBASMIKTAR),'
            
              #9#9#9'--YARIM=(case when GKUMBASMIKTAR>CKUMBASMIKTAR then GMIKTAR e' +
              'lse CMIKTAR end),'
            #9#9#9'ADET=case '
            
              #9#9#9#9'when ((CKUMBASMIKTAR+CMIKTAR-GKUMBASMIKTAR)<=(GKUMBASMIKTAR+' +
              'GMIKTAR-CKUMBASMIKTAR))and((CKUMBASMIKTAR+CMIKTAR-GKUMBASMIKTAR)' +
              '<=(case when GKUMBASMIKTAR>CKUMBASMIKTAR then GMIKTAR else CMIKT' +
              'AR end)) then (CKUMBASMIKTAR+CMIKTAR-GKUMBASMIKTAR)'
            
              #9#9#9#9'when ((GKUMBASMIKTAR+GMIKTAR-CKUMBASMIKTAR)<=(CKUMBASMIKTAR+' +
              'CMIKTAR-GKUMBASMIKTAR))and((GKUMBASMIKTAR+GMIKTAR-CKUMBASMIKTAR)' +
              '<=(case when GKUMBASMIKTAR>CKUMBASMIKTAR then GMIKTAR else CMIKT' +
              'AR end)) then (GKUMBASMIKTAR+GMIKTAR-CKUMBASMIKTAR)'
            
              #9#9#9#9'when ((case when GKUMBASMIKTAR>CKUMBASMIKTAR then GMIKTAR el' +
              'se CMIKTAR end)<=(CKUMBASMIKTAR+CMIKTAR-GKUMBASMIKTAR))and((case' +
              ' when GKUMBASMIKTAR>CKUMBASMIKTAR then GMIKTAR else CMIKTAR end)' +
              '<=(GKUMBASMIKTAR+GMIKTAR-CKUMBASMIKTAR)) then (case when GKUMBAS' +
              'MIKTAR>CKUMBASMIKTAR then GMIKTAR else CMIKTAR end)'
            #9#9#9#9'else 0 end'
            #9#9'from'
            #9#9#9#9'(select '
            #9#9#9#9#9'GFATID=FG.ID,'
            #9#9#9#9#9'GFATBASID=FBG.ID, '
            #9#9#9#9#9'TUR=FG.TUR,'
            #9#9#9#9#9'GFATNO=FBG.FATURANO,'
            #9#9#9#9#9'URUNID=FG.URUNID,'
            #9#9#9#9#9'GMIKTAR=FG.MIKTAR,'
            
              #9#9#9#9#9'GKUMBASMIKTAR=isnull((select sum(MIKTAR) from FATURA FK inn' +
              'er join FATBASLIK FBK on FK.FATBASID=FBK.ID where FBK.TUR<>20 an' +
              'd FK.TUR=1 and FK.URUNID=@StokID and ((isnull(FBK.GIRISDEPO,0) <' +
              '> 0 and FK.MIKTAR>0.0)or(isnull(FBK.CIKISDEPO,0) <> 0 and FK.MIK' +
              'TAR<0.0)) and FK.STOKDURUMDEGIS = 1 and dateadd(MILLISECOND,FK.I' +
              'D,FBK.FATURATARIH)<dateadd(MILLISECOND,FG.ID,FBG.FATURATARIH)),0' +
              '.0),'
            #9#9#9#9#9'GBIRIMTUTAR=FG.TUTAR/FG.MIKTAR,'
            #9#9#9#9#9'GTARIH=dateadd(MILLISECOND,FG.ID,FBG.FATURATARIH)'
            #9#9#9#9'from '
            #9#9#9#9#9'FATURA FG inner join FATBASLIK FBG on FG.FATBASID=FBG.ID'
            #9#9#9#9'where'
            #9#9#9#9#9'FBG.TUR<>20 and '
            #9#9#9#9#9'FG.TUR=1 and '
            #9#9#9#9#9'FG.URUNID=@StokID and '
            
              #9#9#9#9#9'((isnull(FBG.GIRISDEPO,0) <> 0 and FG.MIKTAR>0.0)or(isnull(' +
              'FBG.CIKISDEPO,0) <> 0 and FG.MIKTAR<0.0)) and '
            #9#9#9#9#9'FG.STOKDURUMDEGIS = 1'
            #9#9#9#9') as GG'
            #9#9#9'join'
            #9#9#9#9'(select'
            #9#9#9#9#9'CFATID=FC.ID,'
            #9#9#9#9#9'CFATBASID=FBC.ID,'
            #9#9#9#9#9'TUR=FC.TUR,'
            #9#9#9#9#9'CFATNO=FBC.FATURANO,'
            #9#9#9#9#9'URUNID=FC.URUNID,'
            #9#9#9#9#9'CMIKTAR=FC.MIKTAR,'
            
              #9#9#9#9#9'CKUMBASMIKTAR=isnull((select sum(MIKTAR) from FATURA FK inn' +
              'er join FATBASLIK FBK on FK.FATBASID=FBK.ID where FBK.TUR<>20 an' +
              'd FK.TUR=1 and FK.URUNID=@StokID and ((isnull(FBK.CIKISDEPO,0) <' +
              '> 0 and FK.MIKTAR>0.0)or(isnull(FBK.GIRISDEPO,0) <> 0 and FK.MIK' +
              'TAR<0.0)) and FK.STOKDURUMDEGIS = 1 and dateadd(MILLISECOND,FK.I' +
              'D,FBK.FATURATARIH)<dateadd(MILLISECOND,FC.ID,FBC.FATURATARIH)),0' +
              '.0),'
            #9#9#9#9#9'CBIRIMTUTAR=FC.TUTAR/FC.MIKTAR,'
            #9#9#9#9#9'CTARIH=dateadd(MILLISECOND,FC.ID,FBC.FATURATARIH)'
            #9#9#9#9'from '
            #9#9#9#9#9'FATURA FC inner join FATBASLIK FBC on FC.FATBASID=FBC.ID'
            #9#9#9#9'where'
            #9#9#9#9#9'FBC.TUR<>20 and '
            #9#9#9#9#9'FC.TUR=1 and '
            #9#9#9#9#9'FC.URUNID=@StokID and '
            
              #9#9#9#9#9'((isnull(FBC.CIKISDEPO,0) <> 0 and FC.MIKTAR>0.0)or(isnull(' +
              'FBC.GIRISDEPO,0) <> 0 and FC.MIKTAR<0.0)) and '
            #9#9#9#9#9'FC.STOKDURUMDEGIS = 1'
            #9#9#9#9') as CC'
            #9#9#9'on '
            #9#9#9#9'GG.TUR=CC.TUR and'
            #9#9#9#9'GG.URUNID=CC.URUNID and '
            #9#9#9#9'GKUMBASMIKTAR<CKUMBASMIKTAR+CMIKTAR and'
            #9#9#9#9'CKUMBASMIKTAR<GKUMBASMIKTAR+GMIKTAR'
            ')as FIFO'
            'where CFATID=@CikisFaturaID'
            ''
            ''
            '')
          TabOrder = 3
          Visible = False
          WordWrap = False
        end
        object MemoBirlestir: TMemo
          Left = 390
          Top = 75
          Width = 577
          Height = 25
          Color = clTeal
          Lines.Strings = (
            '--select * from FATURA where FATBASID=18'
            'declare @FatbasID int, @Sira int'
            'select @Sira = convert(int,rand()*100000)'
            'set @FatbasID = :FATBASID'
            'INSERT INTO FATURA'
            '       (FATBASID,REHBERID,TUR,URUNID'
            '       ,ADET,MF,BIRIM,MIKTAR,KDV,KDVMUHAFIYETI,EKMALIYET'
            
              '       ,BIRIMFIYAT,TUTAR,KUR,DOVIZ_BIRIMFIYAT,DOVIZ_TUTARI,DOVIZ' +
              '_KURU,ISKONTO,ISKONTO2'
            '       ,MASRAFID,OZELKOD,MUHKODU,KASA,IZLEME,DOVIZKURDEGERI'
            
              '       ,PROJEID,STOKDURUMDEGIS,GIRDEPO,CIKDEPO,OTVYUZDE,OTVMIKTA' +
              'R,SATICIKODU,SIRA)'
            'select '
            '       FATBASID,REHBERID,TUR,URUNID'
            
              '       ,ADET=SUM(ADET),MF=SUM(MF),BIRIM,MIKTAR=SUM(MIKTAR),KDV,K' +
              'DVMUHAFIYETI,EKMALIYET=SUM(EKMALIYET)'
            
              '       ,BIRIMFIYAT,TUTAR=SUM(TUTAR),KUR,DOVIZ_BIRIMFIYAT,DOVIZ_T' +
              'UTARI=SUM(DOVIZ_TUTARI),DOVIZ_KURU,ISKONTO,ISKONTO2'
            '       ,MASRAFID,OZELKOD,MUHKODU,KASA,IZLEME,DOVIZKURDEGERI'
            
              '       ,PROJEID,STOKDURUMDEGIS,GIRDEPO,CIKDEPO,OTVYUZDE,OTVMIKTA' +
              'R=SUM(OTVMIKTAR),SATICIKODU,SIRA=@Sira'
            'from '
            '       FATURA'
            'where  '
            '       FATBASID=@FatbasID'
            'group by '
            '       FATBASID,REHBERID,TUR,URUNID'
            '       ,BIRIM,KDV,KDVMUHAFIYETI'
            
              '       ,BIRIMFIYAT,KUR,DOVIZ_BIRIMFIYAT,DOVIZ_KURU,ISKONTO,ISKON' +
              'TO2'
            '       ,MASRAFID,OZELKOD,MUHKODU,KASA,IZLEME,DOVIZKURDEGERI'
            
              '       ,PROJEID,STOKDURUMDEGIS,GIRDEPO,CIKDEPO,OTVYUZDE,SATICIKO' +
              'DU;'
            
              'delete from FATURA where FATBASID= :FATBASID and  isnull(SIRA,0)' +
              '<>@Sira'
            '')
          TabOrder = 4
          Visible = False
          WordWrap = False
        end
      end
      object LabelKod: TcxLabel
        Left = 152
        Top = 5
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'Kodu'
        DragCursor = crDefault
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -15
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
        Height = 28
        Width = 130
      end
      object Label6: TcxLabel
        Left = 6
        Top = 45
        Caption = 'ID'
        ParentFont = False
        Transparent = True
      end
      object cxDBLabel1: TcxDBLabel
        Left = 19
        Top = 45
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsFatBaslik
        Transparent = True
        Height = 21
        Width = 58
      end
      object LabelAd: TcxLabel
        Left = 288
        Top = 3
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'Ad'
        DragCursor = crDefault
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelAdClick
        Height = 60
        Width = 485
      end
      object LabelSorgu: TcxLabel
        Left = 940
        Top = 2
        Caption = 'Sorgulama'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.TextColor = clBlack
        Style.IsFontAssigned = True
        Transparent = True
        Visible = False
      end
      object PageUst: TcxPageControl
        Left = 0
        Top = 105
        Width = 1104
        Height = 172
        Align = alTop
        TabOrder = 7
        Properties.ActivePage = SheetFatBaslik
        Properties.CustomButtons.Buttons = <>
        OnChange = PageUstChange
        ExplicitTop = 102
        ClientRectBottom = 168
        ClientRectLeft = 4
        ClientRectRight = 1100
        ClientRectTop = 27
        object SheetFatBaslik: TcxTabSheet
          Caption = 'Genel Bilgiler'
          ImageIndex = 0
          object PanelUst: TPanel
            Left = 0
            Top = 0
            Width = 1096
            Height = 141
            Align = alClient
            BevelOuter = bvNone
            Color = 11776947
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentBackground = False
            ParentFont = False
            TabOrder = 0
            DesignSize = (
              1096
              141)
            object LabelSRMMerkezi: TcxLabel
              Left = 505
              Top = 58
              Caption = 'Srm. Merkezi'
              Transparent = True
            end
            object cbFaturaTur: TcxDBImageComboBox
              Left = 404
              Top = 3
              RepositoryItem = Tablo.RepBelge_Turu
              DataBinding.DataField = 'TUR'
              DataBinding.DataSource = DtsFatBaslik
              Enabled = False
              Properties.ImageAlign = iaRight
              Properties.ImmediatePost = True
              Properties.Items = <
                item
                  Description = 'Al'#305#351' '#304'rsaliyesi'
                  ImageIndex = 0
                  Value = 10
                end
                item
                  Description = 'Al'#305#351' Faturas'#305
                  Value = 11
                end
                item
                  Description = 'Al'#305#351' Fi'#351'i'
                  Value = 12
                end
                item
                  Description = 'Sat'#305#351' '#304'rsaliyesi'
                  Value = 14
                end
                item
                  Description = 'Sat'#305#351' Faturas'#305
                  Value = 15
                end
                item
                  Description = 'Sat'#305#351' Fi'#351'i'
                  Value = 16
                end>
              Style.Color = clWhite
              TabOrder = 1
              Width = 100
            end
            object BaslikPaneli: TPanel
              Left = 3
              Top = 3
              Width = 310
              Height = 139
              TabOrder = 0
              object Label22: TcxLabel
                Left = 2
                Top = 3
                Caption = 'Ba'#351'l'#305'k'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label24: TcxLabel
                Left = 2
                Top = 28
                Caption = 'Adres'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label2: TcxLabel
                Left = 3
                Top = 68
                Caption = #304'l'#231'e'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label25: TcxLabel
                Left = 2
                Top = 92
                Caption = 'VD'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label3: TcxLabel
                Left = 167
                Top = 68
                Caption = #304'l'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label26: TcxLabel
                Left = 165
                Top = 92
                Caption = 'VNo'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object EditBASLIK: TcxDBTextEdit
                Left = 63
                Top = 2
                DataBinding.DataField = 'BASLIK'
                DataBinding.DataSource = DtsFatBaslik
                TabOrder = 0
                Width = 241
              end
              object MemoFatAdres: TcxDBMemo
                Left = 63
                Top = 26
                DataBinding.DataField = 'ADRES'
                DataBinding.DataSource = DtsFatBaslik
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 2
                OnKeyUp = MemoFatAdresKeyUp
                Height = 40
                Width = 241
              end
              object EditILCE: TcxDBTextEdit
                Left = 63
                Top = 67
                DataBinding.DataField = 'ILCE'
                DataBinding.DataSource = DtsFatBaslik
                TabOrder = 4
                OnKeyUp = MemoFatAdresKeyUp
                Width = 100
              end
              object EditVD: TcxDBTextEdit
                Left = 63
                Top = 91
                DataBinding.DataField = 'VD'
                DataBinding.DataSource = DtsFatBaslik
                TabOrder = 8
                OnKeyUp = MemoFatAdresKeyUp
                Width = 100
              end
              object EditVNo: TcxDBTextEdit
                Left = 191
                Top = 91
                DataBinding.DataField = 'VNO'
                DataBinding.DataSource = DtsFatBaslik
                TabOrder = 9
                OnKeyUp = MemoFatAdresKeyUp
                Width = 113
              end
              object EditIL: TcxDBComboBox
                Left = 191
                Top = 67
                DataBinding.DataField = 'IL'
                DataBinding.DataSource = DtsFatBaslik
                Properties.Alignment.Horz = taLeftJustify
                Properties.OnInitPopup = EditILPropertiesInitPopup
                TabOrder = 5
                OnKeyUp = MemoFatAdresKeyUp
                Width = 113
              end
              object EditButtonSevkAdresi: TcxButtonEdit
                Left = 108
                Top = 116
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
                Properties.OnButtonClick = EditButtonSevkAdresiPropertiesButtonClick
                ShowHint = True
                TabOrder = 12
                TextHint = 'REHBERILETID'
                Width = 196
              end
              object lblSevkAdresi: TcxLabel
                Left = 3
                Top = 116
                Cursor = crHandPoint
                Hint = 'Sevk bilgilerini (plaka, s'#252'r'#252'c'#252', ta'#351#305'y'#305'c'#305') girmek i'#231'in t'#305'klay'#305'n'
                Caption = 'Sevk Adresi'
                ParentFont = False
                ParentShowHint = False
                ShowHint = True
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clHotLight
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = [fsUnderline]
                Style.IsFontAssigned = True
                Transparent = True
                OnClick = lblSevkAdresiClick
              end
            end
            object EditSRMMerkezi: TcxButtonEdit
              Left = 583
              Top = 55
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
              Properties.OnButtonClick = EditSRMMerkeziPropertiesButtonClick
              ShowHint = True
              TabOrder = 4
              Width = 110
            end
            object LabelFIYAT_LISTESI: TcxLabel
              Left = 312
              Top = 81
              Caption = 'Fiyat'
              Transparent = True
            end
            object ComboFIYAT_LISTESI: TcxDBImageComboBox
              Left = 404
              Top = 80
              RepositoryItem = Tablo.RepFiyatAdlari
              DataBinding.DataField = 'FIYAT_LISTESI'
              DataBinding.DataSource = DtsFatBaslik
              Properties.ImmediatePost = True
              Properties.Items = <
                item
                  Description = 'Yap'#305'lmad'#305
                  ImageIndex = 0
                  Value = 0
                end
                item
                  Description = 'K'#305'smi'
                  Value = 1
                end
                item
                  Description = #304'ptal'
                  Value = 6
                end
                item
                  Description = 'Tamamland'#305
                  Value = 9
                end>
              Properties.OnCloseUp = ComboFIYAT_LISTESIPropertiesCloseUp
              TabOrder = 6
              Width = 100
            end
            object LabelVade: TcxLabel
              Left = 312
              Top = 106
              Caption = 'Vade'
              Transparent = True
            end
            object lbBelgeTuru: TcxLabel
              Left = 312
              Top = 6
              Caption = 'Belge T'#252'r'#252
              Transparent = True
            end
            object lbDepo: TcxLabel
              Left = 312
              Top = 31
              Caption = 'Depo'
              Transparent = True
            end
            object EditVade: TcxDBCurrencyEdit
              Left = 404
              Top = 105
              DataBinding.DataField = 'VADE'
              DataBinding.DataSource = DtsFatBaslik
              Properties.DisplayFormat = '0;-0'
              Properties.MaxValue = 255.000000000000000000
              TabOrder = 10
              Width = 100
            end
            object cxLabel6: TcxLabel
              Left = 505
              Top = 5
              Caption = 'Tipi'
              PopupMenu = PopupMenuTipDegis
              Transparent = True
            end
            object LabelFATURA_GON_TARIHI: TcxLabel
              Left = 505
              Top = 82
              Caption = #214'zel Kod'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object cxLabel9: TcxLabel
              Left = 505
              Top = 106
              Caption = #214'zel Kod 2'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object EditOZELKOD: TcxDBTextEdit
              Left = 584
              Top = 80
              DataBinding.DataField = 'OZELKOD'
              DataBinding.DataSource = DtsFatBaslik
              TabOrder = 14
              Width = 110
            end
            object ComboSENARYO: TcxDBImageComboBox
              Left = 583
              Top = 29
              DataBinding.DataField = 'SENARYO'
              DataBinding.DataSource = DtsFatBaslik
              Properties.Alignment.Horz = taLeftJustify
              Properties.ImageAlign = iaRight
              Properties.ImmediatePost = True
              Properties.Items = <>
              Properties.OnCloseUp = cbBelgeTipiPropertiesCloseUp
              Style.Color = clWhite
              TabOrder = 16
              Visible = False
              Width = 111
            end
            object LabelSenaryo: TcxLabel
              Left = 507
              Top = 29
              Caption = 'Senaryo'
              FocusControl = ComboSENARYO
              Transparent = True
              Visible = False
            end
            object cbStokDepo2: TcxDBImageComboBox
              Left = 584
              Top = 29
              DataBinding.DataSource = DtsFatBaslik
              Properties.ImageAlign = iaRight
              Properties.ImmediatePost = True
              Properties.Items = <>
              TabOrder = 18
              Visible = False
              Width = 109
            end
            object LabelKonsinyeDepo: TcxLabel
              Left = 507
              Top = 30
              Caption = 'Konsinye Depo'
              Transparent = True
              Visible = False
            end
            object cbStokDepo: TcxDBImageComboBox
              Left = 404
              Top = 29
              DataBinding.DataSource = DtsFatBaslik
              Enabled = False
              Properties.ImageAlign = iaRight
              Properties.ImmediatePost = True
              Properties.Items = <>
              TabOrder = 3
              Width = 289
            end
            object ComboFatTipi: TcxDBImageComboBox
              Left = 584
              Top = 3
              RepositoryItem = Tablo.RepFatTipi
              DataBinding.DataField = 'TIPI'
              DataBinding.DataSource = DtsFatBaslik
              Enabled = False
              PopupMenu = PopupMenuTipDegis
              Properties.ImmediatePost = True
              Properties.Items = <>
              TabOrder = 20
              Width = 109
            end
            object cbSatici: TcxButtonEdit
              Left = 404
              Top = 55
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
              Properties.OnButtonClick = cbSaticiPropertiesButtonClick
              ShowHint = True
              TabOrder = 21
              Width = 100
            end
            object lbSatici: TcxLabel
              Left = 313
              Top = 54
              Anchors = [akLeft, akBottom]
              Caption = 'Sat'#305'c'#305
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.IsFontAssigned = True
              Transparent = True
            end
            object EditOZELKOD2: TcxDBTextEdit
              Left = 584
              Top = 105
              DataBinding.DataField = 'OZELKOD2'
              DataBinding.DataSource = DtsFatBaslik
              TabOrder = 15
              Width = 110
            end
            object DurumPaneli: TPanel
              Left = 697
              Top = 2
              Width = 360
              Height = 139
              TabOrder = 23
              DesignSize = (
                360
                139)
              object Label11: TcxLabel
                Left = 10
                Top = 7
                Caption = 'Durum'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object LblSube: TcxLabel
                Left = 50
                Top = 7
                Caption = '/ '#350'ube'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object ComboFaturaDURUM: TcxDBImageComboBox
                Left = 130
                Top = 4
                DataBinding.DataField = 'DURUM'
                DataBinding.DataSource = DtsFatBaslik
                Properties.ImmediatePost = True
                Properties.Items = <>
                TabOrder = 2
                Width = 109
              end
              object ComboSube: TcxDBImageComboBox
                Left = 241
                Top = 4
                RepositoryItem = Tablo.RepSubeler
                DataBinding.DataField = 'SUBEID'
                DataBinding.DataSource = DtsFatBaslik
                Properties.ImmediatePost = True
                Properties.ImmediateUpdateText = True
                Properties.Items = <>
                Properties.ReadOnly = True
                StyleDisabled.Color = clWhite
                StyleDisabled.TextColor = clBackground
                TabOrder = 3
                Width = 93
              end
              object ComboACIK_KAPALI: TcxDBImageComboBox
                Left = 241
                Top = 29
                DataBinding.DataField = 'ACIK_KAPALI'
                DataBinding.DataSource = DtsFatBaslik
                Properties.ImmediatePost = True
                Properties.Items = <
                  item
                    Description = 'A'#231#305'k'
                    ImageIndex = 0
                    Value = False
                  end
                  item
                    Description = 'Kapal'#305
                    Value = True
                  end>
                TabOrder = 4
                Width = 93
              end
              object cbKdvDurum: TcxDBComboBox
                Left = 131
                Top = 29
                DataBinding.DataField = 'KDVDURUM'
                DataBinding.DataSource = DtsFatBaslik
                Properties.DropDownListStyle = lsFixedList
                Properties.ImmediatePost = True
                Properties.Items.Strings = (
                  'Hari'#231
                  'Dahil'
                  'Muaf')
                Properties.MaxLength = 0
                Properties.OnCloseUp = cbKdvDurumPropertiesCloseUp
                Properties.OnInitPopup = cbKdvDurumPropertiesInitPopup
                Style.LookAndFeel.NativeStyle = False
                Style.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleDisabled.LookAndFeel.NativeStyle = False
                StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleFocused.LookAndFeel.NativeStyle = False
                StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleHot.LookAndFeel.NativeStyle = False
                StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleReadOnly.LookAndFeel.NativeStyle = False
                StyleReadOnly.LookAndFeel.SkinName = 'LondonLiquidSky'
                TabOrder = 5
                Width = 109
              end
              object Label5: TcxLabel
                Left = 9
                Top = 31
                Caption = 'KDV/  A'#231#305'k/Kapal'#305
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object LabelFaturaTarihi: TcxLabel
                Left = 10
                Top = 55
                Caption = 'Belge Tarihi'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object LabelFatNo: TcxLabel
                Left = 10
                Top = 80
                Caption = 'Belge Seri/No'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cbIrsaliyeli: TcxDBCheckBox
                Left = 8
                Top = 105
                Caption = #304'rsaliyeli'
                DataBinding.DataField = 'IRSALIYELI'
                DataBinding.DataSource = DtsFatBaslik
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
                Properties.OnEditValueChanged = cbIrsaliyeliPropertiesEditValueChanged
                TabOrder = 9
              end
              object cxLabel1: TcxLabel
                Left = 89
                Top = 106
                Caption = 'Kaynak:'
                Transparent = True
              end
              object lbKaynakSeriNo: TcxDBLabel
                Left = 139
                Top = 105
                DataBinding.DataField = 'KAYNAKBELGENO'
                DataBinding.DataSource = DtsFatBaslik
                OnClick = LbIrsaliyeBilgileriClick
                Height = 21
                Width = 135
              end
              object cxDBLabel2: TcxDBLabel
                Left = -351
                Top = 82
                Anchors = [akTop, akRight]
                DataBinding.DataField = 'KOCANNO'
                DataBinding.DataSource = DtsFatBaslik
                Style.TextColor = clGrayText
                Height = 21
                Width = 24
              end
              object EditFatTarih: TcxDBDateEdit
                Left = 131
                Top = 54
                DataBinding.DataField = 'FATURATARIH'
                DataBinding.DataSource = DtsFatBaslik
                Properties.DisplayFormat = 'dd/mm/yyyy'
                Properties.ImmediatePost = True
                Properties.Kind = ckDateTime
                Properties.ShowTime = False
                TabOrder = 13
                Width = 109
              end
              object EditFaturaSaat: TcxDBTimeEdit
                Left = 241
                Top = 53
                DataBinding.DataField = 'FATURATARIH'
                DataBinding.DataSource = DtsFatBaslik
                TabOrder = 14
                Width = 91
              end
              object cxDBSpinEdit1: TcxDBSpinEdit
                Left = 286
                Top = 78
                DataBinding.DataField = 'SAYFASAY'
                DataBinding.DataSource = DtsFatBaslik
                Properties.MinValue = 1.000000000000000000
                TabOrder = 15
                Width = 47
              end
              object EditFatNo: TcxDBTextEdit
                Left = 171
                Top = 78
                DataBinding.DataField = 'FATURANO'
                DataBinding.DataSource = DtsFatBaslik
                Style.Color = clWindow
                TabOrder = 16
                Width = 114
              end
              object EditFATURASERI: TcxDBTextEdit
                Left = 131
                Top = 78
                DataBinding.DataField = 'FATURASERI'
                DataBinding.DataSource = DtsFatBaslik
                TabOrder = 17
                Width = 39
              end
            end
            object ComboOZELKOD: TcxDBComboBox
              Left = 583
              Top = 80
              DataBinding.DataField = 'OZELKOD'
              DataBinding.DataSource = DtsFatBaslik
              Properties.DropDownListStyle = lsFixedList
              Properties.ImmediatePost = True
              Properties.Items.Strings = (
                'Hari'#231
                'Dahil'
                'Muaf')
              Properties.MaxLength = 0
              Properties.OnCloseUp = cbKdvDurumPropertiesCloseUp
              Properties.OnInitPopup = cbKdvDurumPropertiesInitPopup
              Style.LookAndFeel.NativeStyle = False
              Style.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleDisabled.LookAndFeel.NativeStyle = False
              StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleFocused.LookAndFeel.NativeStyle = False
              StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleHot.LookAndFeel.NativeStyle = False
              StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleReadOnly.LookAndFeel.NativeStyle = False
              StyleReadOnly.LookAndFeel.SkinName = 'LondonLiquidSky'
              TabOrder = 24
              Width = 111
            end
            object ComboOZELKOD2: TcxDBComboBox
              Left = 583
              Top = 104
              DataBinding.DataField = 'OZELKOD2'
              DataBinding.DataSource = DtsFatBaslik
              Properties.DropDownListStyle = lsFixedList
              Properties.ImmediatePost = True
              Properties.Items.Strings = (
                'Hari'#231
                'Dahil'
                'Muaf')
              Properties.MaxLength = 0
              Properties.OnCloseUp = cbKdvDurumPropertiesCloseUp
              Properties.OnInitPopup = cbKdvDurumPropertiesInitPopup
              Style.LookAndFeel.NativeStyle = False
              Style.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleDisabled.LookAndFeel.NativeStyle = False
              StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleFocused.LookAndFeel.NativeStyle = False
              StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleHot.LookAndFeel.NativeStyle = False
              StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
              StyleReadOnly.LookAndFeel.NativeStyle = False
              StyleReadOnly.LookAndFeel.SkinName = 'LondonLiquidSky'
              TabOrder = 25
              Width = 110
            end
          end
        end
        object SheetGenotip: TcxTabSheet
          Caption = 'Hasta Bilgileri'
          ImageIndex = 2
          object cxGroupBox1: TcxGroupBox
            Left = 15
            Top = 0
            Caption = 'Hasta Bilgisi'
            TabOrder = 0
            Height = 142
            Width = 388
            object cxLabel2: TcxLabel
              Left = 16
              Top = 24
              Caption = 'Ad'#305' Soyad'#305' '
              Transparent = True
            end
            object EditAd: TcxTextEdit
              Left = 95
              Top = 22
              TabOrder = 1
              Width = 249
            end
            object cxLabel5: TcxLabel
              Left = 16
              Top = 50
              Caption = 'TCKN'
              Transparent = True
            end
            object EditTCKN: TcxTextEdit
              Left = 95
              Top = 48
              TabOrder = 3
              Width = 249
            end
            object cxLabel8: TcxLabel
              Left = 16
              Top = 76
              Caption = 'Kimlik ID'
              Transparent = True
            end
            object EditKimlikId: TcxTextEdit
              Left = 95
              Top = 74
              TabOrder = 5
              Width = 249
            end
            object cxLabel10: TcxLabel
              Left = 16
              Top = 102
              Caption = 'Sorumlu'
              Transparent = True
            end
            object EditSorumlu: TcxTextEdit
              Left = 95
              Top = 100
              TabOrder = 7
              Width = 249
            end
          end
          object cxGroupBox2: TcxGroupBox
            Left = 431
            Top = 0
            Caption = 'Geli'#351' Bilgisi'
            TabOrder = 1
            Height = 142
            Width = 388
            object cxLabel11: TcxLabel
              Left = 16
              Top = 17
              Caption = 'Kurumu'
              Transparent = True
            end
            object EditKurumu: TcxTextEdit
              Left = 95
              Top = 15
              TabOrder = 1
              Width = 249
            end
            object LabelPoliklinik: TcxLabel
              Left = 16
              Top = 42
              Cursor = crHandPoint
              Caption = 'Poliklinik'
              Transparent = True
              OnClick = LabelPoliklinikClick
            end
            object EditPoliklinik: TcxTextEdit
              Left = 95
              Top = 40
              TabOrder = 3
              Width = 249
            end
            object cxLabel13: TcxLabel
              Left = 16
              Top = 67
              Caption = 'Doktor'
              Transparent = True
            end
            object EditDoktor: TcxTextEdit
              Left = 95
              Top = 65
              TabOrder = 5
              Width = 249
            end
            object LabelReferans: TcxLabel
              Left = 16
              Top = 92
              Cursor = crHandPoint
              Caption = 'Referans'
              Transparent = True
              OnClick = LabelReferansClick
            end
            object EditReferans: TcxTextEdit
              Left = 95
              Top = 90
              TabOrder = 7
              Width = 249
            end
            object cxLabel15: TcxLabel
              Left = 17
              Top = 117
              Caption = 'G'#246'nderen'
              Transparent = True
            end
            object EditGonderen: TcxTextEdit
              Left = 96
              Top = 115
              TabOrder = 9
              Width = 249
            end
          end
        end
        object SheetEkAlanlar: TcxTabSheet
          Caption = 'Ek Alanlar'
          ImageIndex = 1
          object PanelEkAlanlar: TPanel
            Left = 0
            Top = 0
            Width = 1096
            Height = 141
            Align = alClient
            TabOrder = 0
          end
        end
      end
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 1098
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 90
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
        TabOrder = 8
        Transparent = True
        ExplicitHeight = 29
        object KaydetTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 10
          ImageName = 'PngImage9'
          Style = tbsTextButton
          OnClick = KaydetTusClick
        end
        object IptalTus: TToolButton
          Left = 90
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 17
          ImageName = 'PngImage16'
          Style = tbsTextButton
          OnClick = IptalTusClick
        end
        object ToolButton8: TToolButton
          Left = 180
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 9
          ImageName = 'PngImage8'
          Style = tbsSeparator
        end
        object YaziciYaz: TToolButton
          Left = 188
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          ImageName = 'PngImage15'
          Style = tbsTextButton
        end
        object BtnEfatura: TToolButton
          Left = 278
          Top = 0
          Caption = 'e-'#214'nizleme'
          ImageIndex = 46
          ImageName = 'PngImage47'
          Visible = False
          OnClick = BtnEfaturaClick
        end
      end
      object GrpBoxEFatura: TcxGroupBox
        Left = 764
        Top = 18
        Caption = 'EBelge Durum '
        Enabled = False
        PopupMenu = PopupMenuEBelge
        TabOrder = 6
        Height = 81
        Width = 157
        object ComboEFATURADURUM: TcxDBImageComboBox
          Left = 2
          Top = 23
          RepositoryItem = Tablo.repEFaturaDurum
          DataBinding.DataField = 'EFATURADURUM'
          DataBinding.DataSource = DtsFatBaslik
          PopupMenu = PopupMenuEBelge
          Properties.ImmediatePost = True
          Properties.Items = <>
          Properties.OnEditValueChanged = ComboEFATURADURUMPropertiesEditValueChanged
          TabOrder = 0
          Width = 150
        end
        object ComboEFATURASONUC: TcxDBImageComboBox
          Left = 2
          Top = 48
          RepositoryItem = Tablo.repEFaturaSonuc
          DataBinding.DataField = 'EFATURASONUC'
          DataBinding.DataSource = DtsFatBaslik
          Properties.ImmediatePost = True
          Properties.Items = <
            item
              Description = 'Yap'#305'lmad'#305
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'K'#305'smi'
              Value = 1
            end
            item
              Description = #304'ptal'
              Value = 6
            end
            item
              Description = 'Tamamland'#305
              Value = 9
            end
            item
              Description = 'Haz'#305'rlan'#305'yor'
              Value = 20
            end>
          TabOrder = 1
          Width = 150
        end
      end
    end
    object DetayEkr: TJvWizardInteriorPage
      Tag = 2
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Detay bilgiler'
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
      OnPage = DetayEkrPage
      OnExitPage = DetayEkrExitPage
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 1104
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
        TabOrder = 1
        Transparent = True
      end
      object GridKurIlet: TcxGrid
        Left = 0
        Top = 97
        Width = 1110
        Height = 519
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridDetayViewCellClick
          OnEditChanged = GridDetayViewEditChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.GroupByBox = False
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Etiketi'
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
            Width = 150
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
            MinWidth = 400
            Options.Filtering = False
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
            Width = 400
          end
          object GridDetayViewColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINAL'
            DataBinding.IsNullValueType = True
            Visible = False
            MinWidth = 64
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
          end
          object GridDetayViewColumnsec: TcxGridDBColumn
            Caption = 'Zorunlu'
            DataBinding.FieldName = 'ZORUNLU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Visible = False
          end
        end
        object cxGridDetay: TcxGridLevel
          GridView = GridDetayView
        end
      end
      object ComboBolum: TcxDBComboBox
        Left = 83
        Top = 37
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsFatBaslik
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.OnCloseUp = ComboBolumPropertiesCloseUp
        Properties.OnInitPopup = ComboBolumPropertiesInitPopup
        TabOrder = 0
        Width = 153
      end
      object lbDetaySablon: TcxLabel
        Left = 6
        Top = 38
        Caption = #350'ablon Se'#231'iniz.'
        Style.TextColor = clMaroon
        Transparent = True
        OnClick = lbDetaySablonClick
      end
      object SQLDetay: TcxMemo
        Left = 23
        Top = 133
        Lines.Strings = (
          'declare @yeri int'
          'declare @yerid int'
          'declare @bolum nvarchar(20)'
          'set @yeri = :Yeri'
          'set @yerid = :Yerid'
          'set @bolum = :Bolum'
          ''
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE '
          'name LIKE '
          #39'#DETAY_:SPID_%'#39')'
          'DROP TABLE #DETAY_:SPID_'
          ''
          'CREATE TABLE #DETAY_:SPID_('
          #9'[SIRA] [smallint] NULL,'
          #9'[ETIKET] [nvarchar](100) NULL,'
          #9'[BILGI] [nvarchar](1000) NULL,'
          #9'[ORJINAL] [nvarchar](1000) NULL,'
          #9'[GIRIS] [nvarchar](50) NULL,'
          #9'[KAYNAK] [nvarchar](255) NULL,'
          '                [ZORUNLU] [bit] NULL'
          ')'
          'INSERT INTO #DETAY_:SPID_'
          'select '
          'RB.SIRA,RB.ETIKET,NULLIF(RB.BILGI,'#39#39'),ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU  '
          'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
          'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
          'where RB.YERI= @yeri and YER_ID= @yerid '
          'and isnull(RA.BOLUM,'#39#39')=@bolum '
          ''
          'union all'
          ''
          
            'select  SIRA, ETIKET, BILGI=cast(null as nvarchar(1000)), ORJINA' +
            'L='#39#39' '
          ',GIRIS,KAYNAK,ZORUNLU  '
          ' from REHBERAYAR  '
          'where  YERI=@yeri '
          'and isnull(BOLUM,'#39#39')=@Bolum  '
          'and ETIKET not in (select ETIKET from REHBERBILGI where  '
          'YERI=@yeri  and YER_ID= @yerid )'
          ''
          'order by 1'
          ''
          'select * from #DETAY_:SPID_'
          'order by SIRA')
        TabOrder = 4
        Visible = False
        Height = 264
        Width = 387
      end
    end
    object PlanlamaEkr: TJvWizardInteriorPage
      Tag = 3
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Plan/'#214'deme'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Bu faturaya ba'#287'l'#305' '#246'demeler ve '#246'deme planlar'#305'.'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnPage = PlanlamaEkrPage
      object ToolBar4: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 1104
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
        object BtnYeniPlan: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = BtnYeniPlanClick
        end
        object BtnSilPlan: TToolButton
          Left = 48
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = BtnSilPlanClick
        end
      end
      object cxGrid1: TcxGrid
        Left = 0
        Top = 97
        Width = 1110
        Height = 519
        Align = alClient
        TabOrder = 1
        object cxGrid1DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsPlan
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Kind = skSum
              Position = spFooter
              FieldName = 'BORC'
              Column = cxGrid1DBTableView1BORC
            end
            item
              Kind = skSum
              Position = spFooter
              FieldName = 'ALACAK'
              Column = cxGrid1DBTableView1ALACAK
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = '0.00;'
              Kind = skSum
              FieldName = 'ALACAK'
              Column = cxGrid1DBTableView1ALACAK
            end
            item
              Format = '0.00;'
              Kind = skSum
              FieldName = 'BORC'
              Column = cxGrid1DBTableView1BORC
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.MultiSelect = True
          OptionsSelection.InvertSelect = False
          OptionsView.Footer = True
          OptionsView.GroupFooterMultiSummaries = True
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          object cxGrid1DBTableView1TUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 85
          end
          object cxGrid1DBTableView1PLANTARIHI: TcxGridDBColumn
            Caption = 'Plan Tarihi'
            DataBinding.FieldName = 'PLANTARIHI'
            DataBinding.IsNullValueType = True
            Width = 68
          end
          object cxGrid1DBTableView1ISLEMTARIHI: TcxGridDBColumn
            Caption = #304#351'lem Tarihi'
            DataBinding.FieldName = 'ISLEMTARIHI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 67
          end
          object cxGrid1DBTableView1BORC: TcxGridDBColumn
            Caption = 'Bor'#231
            DataBinding.FieldName = 'BORC'
            DataBinding.IsNullValueType = True
            Width = 73
          end
          object cxGrid1DBTableView1ALACAK: TcxGridDBColumn
            Caption = 'Alacak'
            DataBinding.FieldName = 'ALACAK'
            DataBinding.IsNullValueType = True
            Width = 76
          end
          object cxGrid1DBTableView1KUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Visible = False
            GroupIndex = 0
            Options.Editing = False
          end
          object cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 336
          end
          object cxGrid1DBTableView1MASRAFID: TcxGridDBColumn
            Caption = 'MasrafID'
            DataBinding.FieldName = 'MASRAFID'
            DataBinding.IsNullValueType = True
            OnGetDisplayText = cxGrid1DBTableView1MASRAFIDGetDisplayText
            Options.Editing = False
          end
          object cxGrid1DBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGrid1DBTableView1
        end
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
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'DokumanEkr'
      OnEnterPage = DokumanEkrEnterPage
      OnPage = DokumanEkrPage
      object Panel4: TPanel
        Left = 0
        Top = 575
        Width = 1110
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
          Width = 962
        end
        object BtnMesajGonder: TcxButton
          Left = 963
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
          Left = 1048
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
        Top = 555
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
        AnchorX = 1110
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 1110
        Height = 485
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
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 8
      Width = 121
    end
  end
  object CheckSanal: TcxDBCheckBox
    Left = 1028
    Top = 47
    Caption = 'Sanal'
    DataBinding.DataField = 'SANAL'
    DataBinding.DataSource = DtsFatBaslik
    Properties.NullStyle = nssUnchecked
    Style.TransparentBorder = False
    TabOrder = 2
  end
  object dsAra: TDataSource
    AutoEdit = False
    Left = 270
    Top = 411
  end
  object OpenDialog1: TOpenDialog
    Left = 802
    Top = 24
  end
  object PopupMenuFatura: TPopupMenu
    OnPopup = PopupMenuFaturaPopup
    Left = 458
    Top = 214
    object info1: TMenuItem
      Caption = 'info'
      OnClick = info1Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object SatirDuzenleMenu: TMenuItem
      Caption = 'Sat'#305'r D'#252'zenle'
      OnClick = GridFaturaViewDblClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Miktarskontosu1: TMenuItem
      Caption = 'Miktar '#304'skontosu Gir'
      object KDVHaricTutargir1: TMenuItem
        Caption = 'KDV Hari'#231' Tutar'#305' Gir'
        OnClick = KDVHaricTutargir1Click
      end
      object KDVDahilTutargir1: TMenuItem
        Tag = 1
        Caption = 'KDV Dahil Tutar'#305' Gir'
        OnClick = KDVHaricTutargir1Click
      end
    end
    object Yzdeskontosu1: TMenuItem
      Caption = 'Y'#252'zde '#304'skontosu Gir'
      object skonto11: TMenuItem
        Caption = #304'skonto1'
        object N52: TMenuItem
          Caption = '% 0'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N53: TMenuItem
          Tag = 5
          Caption = '% 5'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N102: TMenuItem
          Tag = 10
          Caption = '% 10'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N152: TMenuItem
          Tag = 15
          Caption = '% 15'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N202: TMenuItem
          Tag = 20
          Caption = '% 20'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N252: TMenuItem
          Tag = 25
          Caption = '% 25'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N302: TMenuItem
          Tag = 30
          Caption = '% 30'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N402: TMenuItem
          Tag = 40
          Caption = '% 40'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N502: TMenuItem
          Tag = 50
          Caption = '% 50'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N1001: TMenuItem
          Tag = 100
          Caption = '% 100'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object zel3: TMenuItem
          Tag = -1
          Caption = 'Di'#287'er'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object zel2: TMenuItem
          Tag = 1
          Caption = #214'zel'
          OnClick = SatiraOzelIskontoClick
        end
      end
      object Cariskonto1: TMenuItem
        Caption = 'Cari '#304'skonto'
        OnClick = Cariskonto1Click
      end
      object skonto21: TMenuItem
        Caption = #304'skonto2'
        object N01: TMenuItem
          Caption = '% 0'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N51: TMenuItem
          Tag = 5
          Caption = '% 5'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N101: TMenuItem
          Tag = 10
          Caption = '% 10'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N151: TMenuItem
          Tag = 15
          Caption = '% 15'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N201: TMenuItem
          Tag = 20
          Caption = '% 20'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N251: TMenuItem
          Tag = 25
          Caption = '% 25'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N301: TMenuItem
          Tag = 30
          Caption = '% 30'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N401: TMenuItem
          Tag = 40
          Caption = '% 40'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N501: TMenuItem
          Tag = 50
          Caption = '% 50'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N1002: TMenuItem
          Tag = 100
          Caption = '% 100'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object zel1: TMenuItem
          Tag = -2
          Caption = 'Di'#287'er'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object zel4: TMenuItem
          Tag = 2
          Caption = #214'zel'
          OnClick = SatiraOzelIskontoClick
        end
      end
      object Stokskontosu1: TMenuItem
        Caption = 'Stok '#304'skontosu'
        OnClick = Stokskontosu1Click
      end
    end
    object utarDvzHesapla1: TMenuItem
      Caption = 'Tutar / D'#246'viz Hesapla'
    end
    object KDVOranGir1: TMenuItem
      Caption = 'KDV Oran'#305' Gir'
      object SeciliSatira: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'ra'
      end
      object Tumune1: TMenuItem
        Caption = 'T'#252'm'#252'ne'
      end
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object FaturaKoanAyarlar1: TMenuItem
      Caption = 'FATURA Ko'#231'an'#305' Ayarlar'#305
      OnClick = FaturaKoanAyarlar1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object MalFazlasDzenle1: TMenuItem
      Caption = 'Mal Fazlas'#305' D'#252'zenle'
      OnClick = MalFazlasDzenle1Click
    end
    object KampanyaDzenle1: TMenuItem
      Caption = 'Kampanya D'#252'zenle'
      OnClick = KampanyaDzenle1Click
    end
    object IzlemBilgileriniDzenleMenu: TMenuItem
      Caption = #304'zlem Bilgilerini D'#252'zenle'
      OnClick = IzlemBilgileriniDzenleMenuClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object BirSatrAdetiKadarSatrlaraBolMenu: TMenuItem
      Caption = 'Bir Sat'#305'r'#305' Adeti Kadar Sat'#305'rlara B'#246'l'
      OnClick = BirSatrAdetiKadarSatrlaraBolMenuClick
    end
    object AyniUrunKodluSatrlarBirlestirMenu: TMenuItem
      Caption = 'Ayn'#305' '#220'r'#252'n Kodlu Sat'#305'rlar'#305' Birle'#351'tir'
      OnClick = AyniUrunKodluSatrlarBirlestirMenuClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object UTSdenAdetleriKontrolEtMenu: TMenuItem
      Caption = #220'TS'#39'den Adetleri Kontrol Et'
      OnClick = UTSdenAdetleriKontrolEtMenuClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object ExceldenVeriAl1: TMenuItem
      Caption = 'Excelden Veri Al'
      object MenuExcelDosyaSec: TMenuItem
        Caption = 'Dosya Se'#231
        OnClick = MenuExcelDosyaSecClick
      end
      object MenuKolonEslestir: TMenuItem
        Caption = 'Kolon E'#351'le'#351'tir'
        OnClick = MenuKolonEslestirClick
      end
    end
  end
  object DtsFatura: TDataSource
    DataSet = TabFatura
    OnStateChange = DtsFaturaStateChange
    Left = 101
    Top = 324
  end
  object DtsFatBaslik: TDataSource
    DataSet = TabFatbaslik
    OnStateChange = DtsFatBaslikStateChange
    Left = 160
    Top = 329
  end
  object PopupMenuYaz: TPopupMenu
    Left = 421
    Top = 42
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YaziciyaYazdirMenu: TMenuItem
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
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object TabRehber: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select KOD,FIRMA'
      '   from REHBER'
      'where ID = :PID')
    Left = 162
    Top = 426
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 100
      end>
  end
  object DtsRehber: TDataSource
    DataSet = TabRehber
    Left = 41
    Top = 490
  end
  object TabFatura: TFDQuery
    BeforeOpen = FATURABeforeOpen
    AfterOpen = FATURAAfterOpen
    BeforeClose = FATURABeforeClose
    AfterInsert = FATURAAfterInsert
    BeforeEdit = FATURABeforeEdit
    BeforePost = FATURABeforePost
    AfterPost = FATURAAfterPost
    BeforeDelete = FATURABeforeDelete
    AfterDelete = FATURAAfterDelete
    AfterScroll = FATURAAfterScroll
    OnCalcFields = TabFaturaCalcFields
    OnNewRecord = FATURANewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT F.*'
      'FROM FATURA F'
      'WHERE F.FATBASID = :Par'
      'ORDER BY F.ID')
    Left = 29
    Top = 20
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        ParamType = ptInput
        Size = 4
        Value = 1625003
      end>
    object TabFaturaID: TFDAutoIncField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object TabFaturaFATBASID: TIntegerField
      FieldName = 'FATBASID'
      Origin = 'FATBASID'
      Required = True
    end
    object TabFaturaREHBERID: TIntegerField
      FieldName = 'REHBERID'
      Origin = 'REHBERID'
      Required = True
    end
    object TabFaturaSEC: TWideStringField
      FieldName = 'SEC'
      Origin = 'SEC'
      Size = 1
    end
    object TabFaturaTUR: TSmallintField
      FieldName = 'TUR'
      Origin = 'TUR'
    end
    object TabFaturaURUNID: TIntegerField
      FieldName = 'URUNID'
      Origin = 'URUNID'
    end
    object TabFaturaACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      Origin = 'ACIKLAMA'
      BlobType = ftWideMemo
      Size = 2147483647
    end
    object TabFaturaADET: TFMTBCDField
      FieldName = 'ADET'
      Origin = 'ADET'
      Precision = 24
      Size = 6
    end
    object TabFaturaEN: TFMTBCDField
      FieldName = 'EN'
      OnChange = TabFaturaENChange
      Precision = 12
      Size = 6
    end
    object TabFaturaBOY: TFMTBCDField
      FieldName = 'BOY'
      OnChange = TabFaturaENChange
      Precision = 12
      Size = 6
    end
    object TabFaturaYUZEY: TFMTBCDField
      FieldName = 'YUZEY'
      Precision = 24
      Size = 6
    end
    object TabFaturaSAYI: TFMTBCDField
      FieldName = 'SAYI'
      OnChange = TabFaturaENChange
      Precision = 12
      Size = 6
    end
    object TabFaturaMF: TFMTBCDField
      FieldName = 'MF'
      Origin = 'MF'
      Precision = 24
      Size = 6
    end
    object TabFaturaBIRIM: TSmallintField
      FieldName = 'BIRIM'
      Origin = 'BIRIM'
    end
    object TabFaturaMIKTAR: TFMTBCDField
      FieldName = 'MIKTAR'
      Origin = 'MIKTAR'
      Precision = 24
      Size = 6
    end
    object TabFaturaBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Origin = 'BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object TabFaturaTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Origin = 'TUTAR'
      Precision = 24
      Size = 2
    end
    object TabFaturaKUR: TWideStringField
      FieldName = 'KUR'
      Origin = 'KUR'
      Size = 5
    end
    object TabFaturaISKONTO: TFloatField
      FieldName = 'ISKONTO'
      Origin = 'ISKONTO'
    end
    object TabFaturaKDV: TSmallintField
      FieldName = 'KDV'
      Origin = 'KDV'
    end
    object TabFaturaMASRAFID: TIntegerField
      FieldName = 'MASRAFID'
      Origin = 'MASRAFID'
    end
    object TabFaturaIZLEMEKODU: TWideStringField
      FieldName = 'IZLEMEKODU'
      Origin = 'IZLEMEKODU'
      Size = 15
    end
    object TabFaturaOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Origin = 'OZELKOD'
    end
    object TabFaturaMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Origin = 'MUHKODU'
      Size = 25
    end
    object TabFaturaKASA: TSmallintField
      FieldName = 'KASA'
      Origin = 'KASA'
    end
    object TabFaturaONAY: TWideStringField
      FieldName = 'ONAY'
      Origin = 'ONAY'
      Size = 1
    end
    object TabFaturaDOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Origin = 'DOVIZ_TUTARI'
      Precision = 24
      Size = 2
    end
    object TabFaturaDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Origin = 'DOVIZ_KURU'
      Size = 5
    end
    object TabFaturaISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
      Origin = 'ISKONTO2'
    end
    object TabFaturaIZLEME: TSmallintField
      FieldName = 'IZLEME'
      Origin = 'IZLEME'
    end
    object TabFaturaIADEADET: TFloatField
      FieldName = 'IADEADET'
      Origin = 'IADEADET'
    end
    object TabFaturaIADEFATURAID: TIntegerField
      FieldName = 'IADEFATURAID'
      Origin = 'IADEFATURAID'
    end
    object TabFaturaYERI: TIntegerField
      FieldName = 'YERI'
      Origin = 'YERI'
    end
    object TabFaturaYERID: TIntegerField
      FieldName = 'YERID'
      Origin = 'YERID'
    end
    object TabFaturaEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
      Origin = 'EKLEYEN'
    end
    object TabFaturaEKLEMETARIHI: TSQLTimeStampField
      AutoGenerateValue = arDefault
      FieldName = 'EKLEMETARIHI'
      Origin = 'EKLEMETARIHI'
    end
    object TabFaturaDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
      Origin = 'DEGISTIREN'
    end
    object TabFaturaDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
      Origin = 'DEGISTIRMETARIHI'
    end
    object TabFaturaDOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Origin = 'DOVIZ_BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object TabFaturaDOVIZKURDEGERI: TCurrencyField
      FieldName = 'DOVIZKURDEGERI'
      Origin = 'DOVIZKURDEGERI'
    end
    object TabFaturaPROJEID: TIntegerField
      FieldName = 'PROJEID'
      Origin = 'PROJEID'
    end
    object TabFaturaKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
      Origin = 'KAMPANYAID'
    end
    object TabFaturaVADE: TByteField
      FieldName = 'VADE'
      Origin = 'VADE'
    end
    object TabFaturaSTOKDURUMDEGIS: TBooleanField
      FieldName = 'STOKDURUMDEGIS'
      Origin = 'STOKDURUMDEGIS'
      Required = True
    end
    object TabFaturaSUBEID: TSmallintField
      FieldName = 'SUBEID'
      Origin = 'SUBEID'
    end
    object TabFaturaKDVMUHAFIYETI: TSmallintField
      FieldName = 'KDVMUHAFIYETI'
      Origin = 'KDVMUHAFIYETI'
    end
    object TabFaturaEKMALIYET: TCurrencyField
      FieldName = 'EKMALIYET'
      Origin = 'EKMALIYET'
    end
    object TabFaturaBASTAR: TSQLTimeStampField
      FieldName = 'BASTAR'
      Origin = 'BASTAR'
    end
    object TabFaturaBITTAR: TSQLTimeStampField
      FieldName = 'BITTAR'
      Origin = 'BITTAR'
    end
    object TabFaturaURETIMPLANID: TIntegerField
      FieldName = 'URETIMPLANID'
      Origin = 'URETIMPLANID'
    end
    object TabFaturaURETIMPLANDETAYID: TIntegerField
      FieldName = 'URETIMPLANDETAYID'
      Origin = 'URETIMPLANDETAYID'
    end
    object TabFaturaMERKEZID: TIntegerField
      FieldName = 'MERKEZID'
      Origin = 'MERKEZID'
    end
    object TabFaturaGIRISKAYNAK: TByteField
      FieldName = 'GIRISKAYNAK'
      Origin = 'GIRISKAYNAK'
    end
    object TabFaturaEKIPMANID: TIntegerField
      FieldName = 'EKIPMANID'
      Origin = 'EKIPMANID'
    end
    object TabFaturaGIRDEPO: TSmallintField
      FieldName = 'GIRDEPO'
      Origin = 'GIRDEPO'
    end
    object TabFaturaCIKDEPO: TSmallintField
      FieldName = 'CIKDEPO'
      Origin = 'CIKDEPO'
    end
    object TabFaturaOTVYUZDE: TBooleanField
      FieldName = 'OTVYUZDE'
      Origin = 'OTVYUZDE'
    end
    object TabFaturaOTVMIKTAR: TBCDField
      FieldName = 'OTVMIKTAR'
      Origin = 'OTVMIKTAR'
      Precision = 6
      Size = 2
    end
    object TabFaturaSIRA: TIntegerField
      FieldName = 'SIRA'
      Origin = 'SIRA'
    end
    object TabFaturaSATICIKODU: TIntegerField
      FieldName = 'SATICIKODU'
      Origin = 'SATICIKODU'
    end
    object TabFaturaISKONTOLUBRMFIYAT: TFloatField
      FieldName = 'ISKONTOLUBRMFIYAT'
      Origin = 'ISKONTOLUBRMFIYAT'
      ProviderFlags = []
      ReadOnly = True
    end
    object TabFaturaKDVDAHILBRMFIYAT: TFMTBCDField
      FieldName = 'KDVDAHILBRMFIYAT'
      Origin = 'KDVDAHILBRMFIYAT'
      ProviderFlags = []
      ReadOnly = True
      Precision = 38
      Size = 9
    end
    object TabFaturaKDVDAHILFIYAT: TFloatField
      FieldName = 'KDVDAHILFIYAT'
      Origin = 'KDVDAHILFIYAT'
      ProviderFlags = []
      ReadOnly = True
    end
    object TabFaturaDEMIRBASID: TIntegerField
      FieldName = 'DEMIRBASID'
      Origin = 'DEMIRBASID'
    end
    object TabFaturaOZELKOD2: TWideStringField
      FieldName = 'OZELKOD2'
      Origin = 'OZELKOD2'
    end
    object TabFaturaPOZNO: TIntegerField
      FieldName = 'POZNO'
      Origin = 'POZNO'
    end
    object TabFaturaAD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'AD'
      Size = 255
      Calculated = True
    end
    object TabFaturaKOD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'KOD'
      Size = 100
      Calculated = True
    end
    object TabFaturaURUNNO: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'URUNNO'
      Size = 100
      Calculated = True
    end
    object TabFaturaMALIYET: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'MALIYET'
      Calculated = True
    end
    object TabFaturaBIRIM2MIKTAR: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'BIRIM2MIKTAR'
      Calculated = True
    end
    object TabFaturaBIRIM2AD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'BIRIM2AD'
      Size = 100
      Calculated = True
    end
    object TabFaturaPROJEKODU: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'PROJEKODU'
      Size = 100
      Calculated = True
    end
    object TabFaturaKAMPANYAADI: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'KAMPANYAADI'
      Size = 255
      Calculated = True
    end
    object TabFaturaSATICIADI: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'SATICIADI'
      Size = 255
      Calculated = True
    end
    object TabFaturaECZANEBIRIMFIYAT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'ECZANEBIRIMFIYAT'
      Calculated = True
    end
    object TabFaturaIMALATCIBIRIMFIYAT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'IMALATCIBIRIMFIYAT'
      Calculated = True
    end
    object TabFaturaDEPOCUBIRIMFIYAT: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'DEPOCUBIRIMFIYAT'
      Calculated = True
    end
    object TabFaturaKDVTUTAR: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'KDVTUTAR'
      Calculated = True
    end
    object TabFaturaBIRIMAD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'BIRIMAD'
      Size = 100
      Calculated = True
    end
    object TabFaturaISKYAZI: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'ISKYAZI'
      Size = 255
      Calculated = True
    end
    object TabFaturaBARKOD: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'BARKOD'
      Size = 100
      Calculated = True
    end
    object TabFaturaEKIPMAN: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'EKIPMAN'
      Size = 255
      Calculated = True
    end
    object TabFaturaSERINO: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'SERINO'
      Size = 100
      Calculated = True
    end
  end
  object TabFatbaslik: TFDQuery
    AutoCalcFields = False
    BeforeOpen = FATBASLIKBeforeOpen
    BeforeEdit = FATBASLIKBeforeEdit
    BeforePost = FATBASLIKBeforePost
    AfterPost = FATBASLIKAfterPost
    AfterScroll = FATBASLIKAfterScroll
    OnNewRecord = FATBASLIKNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT F.*'
      'FROM FATBASLIK F Left outer join DOVIZCINSLERI D on  '
      'F.DIL=D.DIL and F.DOVIZ_CINSI=D.DOVIZ'
      'WHERE F.ID = :Par')
    Left = 40
    Top = 186
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        ParamType = ptInput
        Size = 4
        Value = 0
      end>
  end
  object frxFATURA: TfrxDBDataset
    UserName = 'FATURA'
    CloseDataSource = False
    DataSet = TabFatura
    BCDToCurrency = False
    DataSetOptions = []
    Left = 107
    Top = 378
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'FATBASLIK'
    CloseDataSource = False
    DataSet = TabFatbaslik
    BCDToCurrency = False
    DataSetOptions = []
    Left = 162
    Top = 377
  end
  object DETAY: TFDQuery
    Connection = Tablo.FDCnn
    UpdateOptions.UpdateTableName = 'REHBERBILGI'
    SQL.Strings = (
      ''
      'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 272
    Top = 257
    ParamData = <
      item
        Name = 'Yeri'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'Yeri_Id'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsDetay: TDataSource
    DataSet = DETAY
    Left = 271
    Top = 324
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 222
    Top = 6
  end
  object TabPlan: TFDQuery
    AfterOpen = TabPlanAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select * from KASA where FATURAID=:FaturaID')
    Left = 220
    Top = 243
    ParamData = <
      item
        Name = 'FaturaID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 407
      end>
  end
  object DtsPlan: TDataSource
    DataSet = TabPlan
    Left = 221
    Top = 329
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 665
    Top = 391
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT   ID, YERI, YER_ID,DURUM, ICDIS,BELGENO, BELGEADI, TUR, A' +
        'CIKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'YERI = :PYeri AND'
      'YER_ID=:PYer_ID')
    Left = 662
    Top = 342
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
  object TOPLAMLAR: TFDQuery
    OnCalcFields = TOPLAMLARCalcFields
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'EXEC SP_PRG_FaturaDipToplami :PRM1')
    Left = 801
    Top = 313
    ParamData = <
      item
        Name = 'Prm1'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object dtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 774
    Top = 372
  end
  object frxTOPLAMLAR: TfrxDBDataset
    UserName = 'TOPLAMLAR'
    CloseDataSource = False
    DataSet = TOPLAMLAR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 777
    Top = 419
    FieldDefs = <
      item
        FieldName = 'TUR'
        FieldAlias = 'TUR'
      end
      item
        FieldName = 'ACIKLAMA'
        FieldAlias = 'ACIKLAMA'
      end
      item
        FieldName = 'DEGER'
        FieldAlias = 'DEGER'
      end
      item
        FieldName = 'DOVIZTUTARI'
        FieldAlias = 'DOVIZTUTARI'
      end
      item
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end
      item
        FieldName = 'DOVIZ_KURU'
        FieldAlias = 'DOVIZ_KURU'
      end
      item
        FieldName = 'KDVMUHAFIYETI'
        FieldAlias = 'KDVMUHAFIYETI'
      end>
  end
  object frxDETAY: TfrxDBDataset
    UserName = 'DETAY'
    CloseDataSource = False
    DataSet = DETAY
    BCDToCurrency = False
    DataSetOptions = []
    Left = 273
    Top = 368
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 867
    Top = 307
  end
  object PopupBagliBelgeler: TPopupMenu
    Left = 392
    Top = 312
    object BelgeEkle1: TMenuItem
      Caption = 'Belge Ekle'
      ImageIndex = 4
      OnClick = BelgeEkle1Click
    end
    object BelgeKaldr1: TMenuItem
      Caption = 'Belge G'#246'r/Kald'#305'r'
      ImageIndex = 5
    end
    object Hesapla1: TMenuItem
      Caption = 'Hesapla'
      ImageIndex = 9
      OnClick = Hesapla1Click
    end
  end
  object PopupBelgeZarfi: TPopupMenu
    Left = 480
    Top = 344
    object MenuItem1: TMenuItem
      Caption = 'Zarfa Ekle'
      ImageIndex = 4
      OnClick = MenuItem1Click
    end
    object MenuItem2: TMenuItem
      Caption = 'Zarftan '#199#305'kar'
      ImageIndex = 5
      OnClick = MenuItem2Click
    end
    object MenuItem3: TMenuItem
      Caption = 'Zarflar'#305' G'#246'r/D'#252'zenle'
      ImageIndex = 9
      OnClick = MenuItem3Click
    end
  end
  object TabKaynaklar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select distinct    '
      '   KAYNAKTUR = case   '
      '   '#9#9#9#9'when YERI in (406,407) then 9   '
      '   '#9#9#9#9'when YERI = 408 then 10         '
      '   '#9#9#9#9'when YERI in (409,410) then 19  '
      '   '#9#9#9#9'when YERI = 411 then 14         '
      '   '#9#9#9#9'when YERI in (412,413) then -99 '
      #9#9#9'   end, '
      '   KAYNAKBELGENO=case '
      
        '   '#9#9#9#9#9'when YERI in (406,407,409,410) then (select SIPARISNO fr' +
        'om SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID' +
        '=F.YERID)) '
      
        '   '#9#9#9#9#9'when YERI in (408,411) then (select FATURANO from FATBAS' +
        'LIK where ID=(select FATBASID from FATURA where ID=F.YERID))    ' +
        '           '
      
        '   '#9#9#9#9#9'when YERI in (412,413) then (select TEKLIFNO from TEKLIF' +
        ' where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))  ' +
        '           '
      #9#9#9#9'   end, '
      '   KAYNAKID=case      '
      
        #9#9#9'when YERI in (406,407,409,410) then (select SIPARISID from SI' +
        'PARISDETAY where ID=F.YERID ) '
      
        #9#9#9'when YERI in (408,411) then (select FATBASID from FATURA wher' +
        'e ID=F.YERID )                '
      
        #9#9#9'when YERI in (412,413) then (SELECT TEKLIFID FROM TEKLIFDETAY' +
        ' where ID=F.YERID )           '
      #9#9#9'end, '
      '   KAYNAKTARIH=case      '
      
        '   '#9#9#9#9'when YERI in (406,407,409,410) then (select SIPARISTARIH ' +
        'from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ' +
        'ID=F.YERID)) '
      
        '   '#9#9#9#9'when YERI in (408,411) then (select FATURATARIH from FATB' +
        'ASLIK where ID=(select FATBASID from FATURA where ID=F.YERID))  ' +
        '             '
      
        '   '#9#9#9#9'when YERI in (412,413) then (select TARIH from TEKLIF whe' +
        're ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))      ' +
        '     '
      #9#9#9'   end  '
      'from FATURA F  '
      'where FATBASID=:PID and YERI between 406 and 414 ')
    Left = 262
    Top = 374
    ParamData = <
      item
        Name = 'PID'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
  end
  object DtsKaynaklar: TDataSource
    DataSet = TabKaynaklar
    Left = 729
    Top = 407
  end
  object frxKaynaklar: TfrxDBDataset
    UserName = 'Kaynaklar'
    CloseDataSource = False
    DataSet = TabKaynaklar
    BCDToCurrency = False
    DataSetOptions = []
    Left = 593
    Top = 395
  end
  object TabHesapOzeti: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT * from [dbo].[fn_CARIHESAPOZETI] (:PRehID,:PBirim,:FatTut' +
        'ari) ')
    Left = 336
    Top = 233
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
  object DtsHesapOzeti: TDataSource
    DataSet = TabHesapOzeti
    Left = 335
    Top = 324
  end
  object frxHesapOzeti: TfrxDBDataset
    UserName = 'Hesap '#214'zeti'
    CloseDataSource = False
    DataSet = TabHesapOzeti
    BCDToCurrency = False
    DataSetOptions = []
    Left = 329
    Top = 376
  end
  object tabIzleme: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      
        'AD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = F.URUNID )'
      ' ELSE  (SELECT AD FROM MASRAFGELIR WHERE ID = F.URUNID)  END,'
      
        'KOD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR W' +
        'HERE ID = F.URUNID ) '
      'ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID= F.URUNID )  END,'
      
        'F.* ,PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=F.' +
        'PROJEID),KAMPANYAADI=(select K.ADI from KAMPANYA K where K.ID=F.' +
        'KAMPANYAID ),ECZANEBIRIMFIYAT=convert(decimal(18,2),0),IMALATCIB' +
        'IRIMFIYAT=convert(decimal(18,2),0),DEPOCUBIRIMFIYAT=convert(deci' +
        'mal(18,2),0),BIRIMAD= (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BO' +
        'LUM =-2702 and DEGER = convert(varchar(10),F.BIRIM) ),SSL.SERINO' +
        ',LOT=SSL.LOTNO, SSL.SKT,  IZLEMMIKTAR=isnull(SI.ADET,F.MIKTAR), ' +
        'URUNNO from '#9'FATURA F '#9'inner join STOKLAR S on S.ID=F.URUNID '#9'le' +
        'ft outer join STOKIZLEME SI on '#9#9'F.FATBASID=SI.BASLIKID and '#9#9'F.' +
        'ID=SI.SATIRID INNER JOIN [STOKSERILOT] SSL ON SI.SERILOTID=SSL.I' +
        'D '
      'where '
      #9'F.FATBASID= :PFatBasID '
      ''
      ''
      ''
      ''
      ''
      #9#9
      #9#9
      #9#9' ')
    Left = 21
    Top = 276
    ParamData = <
      item
        Name = 'PFatBasID'
        Size = -1
        Value = Null
      end>
  end
  object tsIzleme: TDataSource
    DataSet = tabIzleme
    Left = 21
    Top = 324
  end
  object frxIzleme: TfrxDBDataset
    UserName = 'Izleme'
    CloseDataSource = False
    DataSet = tabIzleme
    BCDToCurrency = False
    DataSetOptions = []
    Left = 27
    Top = 378
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
    Left = 585
    Top = 369
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
    Left = 515
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 864
    Top = 144
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object MenuItem4: TMenuItem
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
    Left = 920
    Top = 384
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
    Left = 424
    Top = 372
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
  object TabRecete: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select URD.ID,FATURAID=F.ID,S.STOKADI,MIKTAR=-URD.MIKTAR,BIRIM=G' +
        '.ANAHTAR'
      'from '
      #9'URETIMRECETE UR inner join '
      #9'URETIMRECETEDETAY URD on UR.ID=URD.URETIMRECETEID inner join '
      #9'STOKLAR S on S.ID=URD.URUNID inner join '
      
        #9'GENINI G on S.ANABIRIM=G.DEGER and G.DIL=-1 and G.BOLUM=-2702 i' +
        'nner join '
      #9'FATURA F on F.TUR>0 and F.URUNID=UR.STOKID '
      'where URD.MIKTAR<0.0 and F.FATBASID=:PFatbasID'
      ''
      ''
      ''
      #9#9
      #9#9
      #9#9' ')
    Left = 1013
    Top = 260
    ParamData = <
      item
        Name = 'PFatBasID'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
  end
  object DtsRecete: TDataSource
    DataSet = TabRecete
    Left = 1013
    Top = 308
  end
  object frxRecete: TfrxDBDataset
    UserName = 'Recete'
    CloseDataSource = False
    DataSet = TabRecete
    BCDToCurrency = False
    DataSetOptions = []
    Left = 1017
    Top = 352
  end
  object TabStokDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE '
      #9'@SQL '#9#9#9'NVARCHAR(4000),'
      #9'@KOLONBASLIK'#9'VARCHAR(100),'
      #9'@URUNADI'#9#9'VARCHAR(100),'
      #9'@URUNFIYATI'#9#9'VARCHAR(100),'
      #9'@URUNID'#9#9#9'INT,'
      #9'@FATBASID'#9#9'INT,'
      #9'@ETIKET'#9#9#9'VARCHAR(100),'
      #9'@BILGI'#9#9#9'VARCHAR(1000),'
      #9'@SIRA'#9#9#9'VARCHAR(10),'
      #9'@RESIM'#9#9#9'varbinary(max),'
      #9'@DETAYBOLMU'#9#9'VARCHAR(20),'
      #9'@KOLONSAYISI'#9'int,'
      #9'@MinKolonSayisi'#9'int'#9
      #9
      'SET @FATBASID = :PFBID'
      'SET @MinKolonSayisi = :PKolonSayisi'
      'SET @SQL = '#39'Create Table ##RehberBilgiView( '
      'ID'#9#9'INT IDENTITY(1,1),'
      'SIRA '#9'INT NULL,'
      'ETIKET'#9'VARCHAR(100) NULL,'
      'KONU'#9'VARCHAR(50) NULL,'
      'GIRIS'#9#9'INT NULL,'#39
      ''
      'select top 1 @KOLONSAYISI=count(*)'
      
        'FROM STOKLAR S inner join FATURA TD on S.ID=TD.URUNID and TD.TUR' +
        '=1 '
      'where '
      #9'TD.FATBASID=@FATBASID and'
      
        #9'S.DETAYBOLUMU in(select distinct DETAYBOLUMU from STOKLAR S whe' +
        're isnull(DETAYBOLUMU,'#39#39')<>'#39#39'and S.ID in(select URUNID from FATU' +
        'RA T where T.TUR=1 and T.FATBASID=@FATBASID))'
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
        'D from FATURA T where T.TUR=1 and T.FATBASID=@FATBASID))'
      'order by BOLUM '
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      
        'select distinct -1,'#39#220'r'#252'n Ad'#305#39',DETAYBOLUMU,-1 from STOKLAR S wher' +
        'e isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select URUNID from FAT' +
        'URA T where T.TUR=1 and T.FATBASID=@FATBASID)'
      'INSERT INTO ##RehberBilgiView (SIRA,ETIKET,KONU,GIRIS)'
      
        'select distinct 2147483640,'#39'Fiyat'#305#39',DETAYBOLUMU,2147483640 from ' +
        'STOKLAR S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and S.ID in (select U' +
        'RUNID from FATURA T where T.TUR=1 and T.FATBASID=@FATBASID)'
      ''
      ''
      'DECLARE cur_Konular Cursor For '
      'select DETAYBOLUMU'
      'FROM STOKLAR S '
      
        'where S.DETAYBOLUMU in(select distinct DETAYBOLUMU from STOKLAR ' +
        'S where isnull(DETAYBOLUMU,'#39#39')<>'#39#39' and  S.ID in (select URUNID f' +
        'rom FATURA T where T.TUR=1 and T.FATBASID=@FATBASID) )'
      'group by DETAYBOLUMU'
      'order by count(*) desc'
      'OPEN cur_Konular'
      'FETCH NEXT FROM cur_Konular INTO @DETAYBOLMU'
      'WHILE @@FETCH_STATUS = 0'
      #9'BEGIN '
      #9#9#9#9#9#9
      #9#9#9#9'DECLARE cur_Urunler cursor for '
      #9#9#9#9'select '
      #9#9#9#9#9'T.URUNID,'
      
        #9#9#9#9#9'KOLONADI='#39#220'r'#252'n'#39'+convert(varchar(5),ROW_NUMBER()OVER(order b' +
        'y T.URUNID)),'
      #9#9#9#9#9'S.STOKADI,'
      #9#9#9#9#9'URUNFIYAT=convert(varchar(50),T.TUTAR)+KUR'
      
        #9#9#9#9'from STOKLAR S inner join FATURA T on T.TUR=1 and T.URUNID=S' +
        '.ID'
      #9#9#9#9'where T.FATBASID=@FATBASID and S.DETAYBOLUMU=@DETAYBOLMU'
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
    Left = 657
    Top = 25
    ParamData = <
      item
        Name = 'PFBID'
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
    Left = 596
    Top = 31
  end
  object PopupMenuEBelge: TPopupMenu
    OnPopup = PopupMenuEBelgePopup
    Left = 744
    Top = 80
    object MenuKagitIrsaliyeyeCevir: TMenuItem
      Tag = 51
      Caption = 'Ka'#287#305't '#304'rsaliyeye '#199'evir'
      ImageIndex = 4
      OnClick = MenuKagitIrsaliyeyeCevirClick
    end
  end
  object PopupMenuTipDegis: TPopupMenu
    OnPopup = PopupMenuTipDegisPopup
    Left = 621
    Top = 98
    object MenuTipiIade: TMenuItem
      Caption = 'Tipini '#304'ade Yap'
      ImageIndex = 0
      OnClick = MenuTipiIadeClick
    end
  end
  object FATURA: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'SELECT F.*,'
      
        'AD = CASE WHEN F.TUR = 0 THEN (SELECT MG.AD FROM MASRAFGELIR MG ' +
        'WHERE MG.ID = F.URUNID)'
      
        '          ELSE (SELECT S.STOKADI FROM STOKLAR S WHERE S.ID = F.U' +
        'RUNID) END,'
      
        'KOD = CASE WHEN F.TUR = 0 THEN (SELECT MG.KOD FROM MASRAFGELIR M' +
        'G WHERE MG.ID = F.URUNID)'
      
        '           ELSE (SELECT S.KOD FROM STOKLAR S WHERE S.ID = F.URUN' +
        'ID) END,'
      
        'URUNNO = CASE WHEN F.TUR = 0 THEN '#39#39' ELSE (SELECT S.URUNNO FROM ' +
        'STOKLAR S WHERE S.ID = F.URUNID) END,'
      
        'MALIYET = F.MIKTAR * (SELECT TOP 1 SOM.BIRIMMALIYET FROM STOK_OR' +
        'T_MALIYET SOM WHERE F.ID = SOM.FATURAID),'
      
        'BIRIM2MIKTAR = CASE WHEN F.TUR = 0 THEN F.MIKTAR ELSE F.MIKTAR /' +
        ' (SELECT S.BIRIM2MIKTAR FROM STOKLAR S WHERE S.ID = F.URUNID) EN' +
        'D,'
      
        'BIRIM2AD = CASE WHEN F.TUR = 0 THEN (SELECT TOP 1 ANAHTAR FROM G' +
        'ENINI WHERE BOLUM = -2702 AND DEGER = CONVERT(VARCHAR(10), F.BIR' +
        'IM))'
      
        '               ELSE (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLU' +
        'M = -2702 AND DEGER = CONVERT(VARCHAR(10), (SELECT S.BIRIM2 FROM' +
        ' STOKLAR S WHERE S.ID = F.URUNID))) END,'
      
        'PROJEKODU = (SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID' +
        ' = F.PROJEID),'
      
        'KAMPANYAADI = (SELECT TOP 1 K.ADI FROM KAMPANYA K WHERE K.ID = F' +
        '.KAMPANYAID),'
      
        'SATICIADI = (SELECT R.FIRMA FROM REHBER R WHERE R.ID = F.SATICIK' +
        'ODU),'
      'ECZANEBIRIMFIYAT = CONVERT(DECIMAL(18,2), 0),'
      'IMALATCIBIRIMFIYAT = CONVERT(DECIMAL(18,2), 0),'
      'DEPOCUBIRIMFIYAT = CONVERT(DECIMAL(18,2), 0),'
      'KDVTUTAR = CONVERT(DECIMAL(18,2), F.TUTAR * F.KDV / 100.0),'
      
        'BIRIMAD = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2702 ' +
        'AND DEGER = CONVERT(VARCHAR(10), F.BIRIM)),'
      
        'ISKYAZI = dbo.fn_IskontolarStrOlarak((SELECT TOP 1 FB.TUR FROM F' +
        'ATBASLIK FB WHERE FB.ID = F.FATBASID), F.ID),'
      
        'BARKOD = (SELECT TOP 1 BARKOD FROM STOKBARKOD SB WHERE SB.STOKID' +
        ' = F.URUNID AND SB.VARSAYILAN = 1),'
      
        'EKIPMAN = (SELECT E1.AD FROM EKIPMANLAR E1 INNER JOIN EKIPMANREH' +
        'BER ER1 ON E1.ID = ER1.EKIPMANID WHERE ER1.ID = F.EKIPMANID),'
      
        'SERINO = (SELECT ER2.SERINO FROM EKIPMANREHBER ER2 WHERE ER2.ID ' +
        '= F.EKIPMANID)'
      'FROM FATURA F'
      'WHERE F.FATBASID = :Par'
      'ORDER BY F.ID')
    Left = 365
    Top = 156
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1625003
      end>
  end
  object FATBASLIK: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'SELECT F.*, '
      
        'YAZIYLATOPLAM=( dbo.fn_ParaTextOlarakTumDiller(F.FATURA_TUTARI,'#39 +
        'TL'#39','#39'Kuru'#351#39',0,F.DIL)),'
      
        'YAZIYLATOPLAMDOVIZ=( dbo.fn_ParaTextOlarakTumDiller(F.DOVIZ_TUTA' +
        'RI,D.BUYUKBIRIMADI,D.KUCUKBIRIMADI,0,F.DIL)),'
      
        'SEVKYERI=(select RI.AD from REHBERILETISIM RI where RI.ID=F.REHB' +
        'ERILETID),'
      
        'SEVKADRES=(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=F.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 2 Order by 1 )' +
        ','
      
        'SEVKILCE =(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=F.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 6 Order by 1),'
      
        'SEVKIL = (SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBE' +
        'RBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID' +
        '=F.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 8 Order by 1 ),'
      
        'KAYNAKBELGENO=dbo.fn_KaynakBelgeNolariStrOlarakGetir(F.TUR,F.ID)' +
        ','
      'SATICIADI=(select R.FIRMA from REHBER R where R.ID=F.SATICIKODU)'
      'FROM FATBASLIK F Left outer join DOVIZCINSLERI D on  '
      'F.DIL=D.DIL and F.DOVIZ_CINSI=D.DOVIZ'
      'WHERE F.ID = :Par')
    Left = 288
    Top = 162
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
end
