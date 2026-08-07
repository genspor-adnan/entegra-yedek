object StokTalepWizard: TStokTalepWizard
  Left = 0
  Top = 0
  ActiveControl = GridFaturaToplam
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Belge Sihirbaz'#305
  ClientHeight = 659
  ClientWidth = 1118
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 659
    Align = alLeft
    TabOrder = 0
    object TalepTus: TcxButton
      Left = 3
      Top = 80
      Width = 80
      Height = 29
      Caption = 'Talep'
      Enabled = False
      TabOrder = 0
      OnClick = TalepTusClick
    end
    object DokumanTus: TcxButton
      Tag = 1
      Left = 3
      Top = 111
      Width = 80
      Height = 29
      Caption = 'Yorum/Medya'
      Enabled = False
      TabOrder = 1
      OnClick = DokumanTusClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 1032
    Height = 659
    ActivePage = SiparisEkr
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
      1032
      659)
    object SiparisEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Stoktan talep bilgileri'
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
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      OnPage = SiparisEkrPage
      OnNextButtonClick = SiparisEkrNextButtonClick
      object PanelAlt2: TPanel
        Left = 0
        Top = 477
        Width = 1032
        Height = 140
        Align = alBottom
        Color = 11776947
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        DesignSize = (
          1032
          140)
        object GridFaturaToplam: TStringGrid
          Left = 27384
          Top = 11
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
          TabOrder = 1
        end
        object MemoNOTLAR: TcxDBMemo
          Left = 331
          Top = 55
          DataBinding.DataField = 'ACIKLAMA'
          DataBinding.DataSource = DtsSIPARIS
          Properties.ScrollBars = ssVertical
          TabOrder = 8
          Height = 63
          Width = 326
        end
        object cxLabel17: TcxLabel
          Left = 282
          Top = 57
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
        object LabelAktivite: TcxLabel
          Left = 1
          Top = 28
          Caption = 'Ba'#287'l'#305' Akt.'
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
          Left = 2
          Top = 6
          Caption = 'Ba'#287'l'#305' Proje'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object BeditBagliGorev: TcxButtonEdit
          Left = 68
          Top = 27
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
          TabOrder = 4
          OnDblClick = BeditBagliGorevDblClick
          Width = 208
        end
        object cxDBLabel3: TcxDBLabel
          Left = 447
          Top = 5
          DataBinding.DataField = 'KUR'
          DataBinding.DataSource = DtsSIPARIS
          Transparent = True
          Visible = False
          Height = 21
          Width = 29
        end
        object cbDovizCinsi: TcxDBComboBox
          Left = 331
          Top = 3
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          DataBinding.DataField = 'DOVIZ_CINSI'
          DataBinding.DataSource = DtsSIPARIS
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.OnCloseUp = cbDovizCinsiPropertiesCloseUp
          TabOrder = 2
          Visible = False
          Width = 65
        end
        object lbDoviz: TcxLabel
          Left = 282
          Top = 7
          Caption = 'D'#246'viz'
          Transparent = True
          Visible = False
        end
        object gridFatToplam: TcxGrid
          Left = 722
          Top = 1
          Width = 309
          Height = 138
          Align = alRight
          BorderStyle = cxcbsNone
          Enabled = False
          TabOrder = 0
          Visible = False
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
        object BeditProje: TcxButtonEdit
          Left = 68
          Top = 4
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
          Properties.ReadOnly = False
          Properties.OnButtonClick = BeditProjePropertiesButtonClick
          ShowHint = True
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
          TabOrder = 3
          OnDblClick = BeditProjeDblClick
          Width = 208
        end
        object EditOnaylayan: TcxButtonEdit
          Left = 68
          Top = 98
          Properties.Buttons = <
            item
              Default = True
              Glyph.SourceDPI = 96
              Glyph.Data = {
                424D360400000000000036000000280000001000000010000000010020000000
                000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00EFF7EFFF4AA54AFF189418FFA5D6A5FFFFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00EFF7EFFF39A539FF10AD29FF18B529FF089410FFA5D6A5FFFFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FF
                F7FF39AD39FF18AD31FF18B531FF10AD29FF10B529FF089410FFADDEADFFFFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FFF7FF42B5
                42FF18B531FF18B539FF18B531FF31BD4AFF18AD31FF10AD29FF089410FFADDE
                ADFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0052BD5AFF21B5
                42FF21BD42FF21B542FF10A521FF189418FF63C673FF18B531FF10B529FF0894
                10FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0039BD4AFF42C6
                63FF21BD4AFF18B529FF63C663FFEFF7EFFF39AD39FF63C673FF18B531FF10B5
                29FF109410FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF009CE7A5FF42C6
                5AFF39BD4AFF63CE6BFFFFFFFF00FFFFFF00EFF7EFFF31A531FF63CE73FF18B5
                31FF10B529FF109410FFB5E7B5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00D6F7
                D6FFB5EFBDFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00EFF7EFFF31A531FF63CE
                73FF18B531FF10B529FF109410FFBDDEBDFFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7E7FF29A5
                29FF63CE73FF18B531FF18B531FF189418FFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7
                E7FF29A529FF63CE7BFF29BD4AFF299C31FFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00E7F7E7FF31AD31FF31A531FFCEE7CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
              Kind = bkGlyph
            end
            item
              Glyph.SourceDPI = 96
              Glyph.Data = {
                424D360400000000000036000000280000001000000010000000010020000000
                000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFEFF7FF3939
                BDFF2129B5FF8484D6FFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007B7B
                CEFF7373C6FFD6D6EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007373CEFF1842
                F7FF184AF7FF1031D6FF3131BDFFDEDEF7FFFFFFFF00FFFFFF006B6BD6FF0829
                D6FF0831D6FF0010B5FF7373CEFFFFFFFF00FFFFFF00FFFFFF003131BDFF2152
                F7FF2152FFFF2152FFFF1842E7FF1821B5FFC6C6EFFF6B6BCEFF1031DEFF1042
                F7FF1039F7FF0839EFFF0018BDFFA5A5DEFFFFFFFF00FFFFFF00BDBDE7FF1831
                DEFF295AFFFF2152FFFF2152FFFF184AEFFF0810B5FF1031DEFF184AFFFF1042
                F7FF1042F7FF1042F7FF0839EFFF4242B5FFFFFFFF00FFFFFF00ADADE7FF2139
                DEFF396BFFFF295AFFFF295AFFFF295AFFFF2152FFFF1852FFFF184AFFFF184A
                F7FF1042F7FF1039EFFF1821B5FFBDBDE7FFFFFFFF00FFFFFF00FFFFFF009C9C
                E7FF2129CEFF396BFFFF316BFFFF295AFFFF295AFFFF2152FFFF214AFFFF184A
                FFFF1039EFFF3139BDFFE7E7F7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00E7E7F7FF4242CEFF314AE7FF396BFFFF315AFFFF295AFFFF2152FFFF1839
                E7FF4242BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00B5B5EFFF2142DEFF396BFFFF3163FFFF315AFFFF295AFFFF184A
                E7FF3131BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF004242D6FF4A7BFFFF4273FFFF396BFFFF396BFFFF295AFFFF215A
                FFFF1039D6FF6B6BD6FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00D6D6F7FF2939DEFF5284FFFF4273FFFF3963F7FF1018C6FF396BFFFF295A
                FFFF2152FFFF1021C6FFB5B5EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF007373E7FF527BF7FF5284FFFF4A7BFFFF2129CEFFBDBDEFFF2129CEFF396B
                FFFF2152FFFF184AEFFF2121BDFFEFEFFFFFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF003139DEFF6B9CFFFF5A8CFFFF294AE7FFA5A5EFFFFFFFFF00CECEF7FF1829
                CEFF3163FFFF2152FFFF1039DEFF6363CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF006B6BEFFF3952E7FF5A84FFFF4242DEFFFFFFFF00FFFFFF00FFFFFF00B5B5
                EFFF1829D6FF295AFFFF1031E7FF3131C6FFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00C6C6F7FF5A5AD6FFCECEF7FFFFFFFF00FFFFFF00FFFFFF00FFFF
                FF009C9CE7FF4242CEFFB5B5E7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
              Kind = bkGlyph
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditBirimOnaylayanPropertiesButtonClick
          TabOrder = 11
          Width = 208
        end
        object cxLabel6: TcxLabel
          Left = 1
          Top = 101
          Caption = 'Onaylayan'
          Transparent = True
        end
        object editDovizKuru: TcxDBCurrencyEdit
          Left = 395
          Top = 3
          DataBinding.DataField = 'DOVIZKUR'
          DataBinding.DataSource = DtsSIPARIS
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
          TabOrder = 13
          Visible = False
          Width = 51
        end
        object cxLabel7: TcxLabel
          Left = 1
          Top = 76
          Caption = 'Onaylayacak'
          Transparent = True
        end
        object cbOnaylayacak: TcxDBImageComboBox
          Left = 68
          Top = 74
          DataBinding.DataField = 'ONAYLAYACAK'
          DataBinding.DataSource = DtsSIPARIS
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 15
          Width = 208
        end
        object BeditServis: TcxButtonEdit
          Left = 68
          Top = 50
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
          TabOrder = 16
          OnDblClick = BeditServisDblClick
          Width = 208
        end
        object cxLabel8: TcxLabel
          Left = 1
          Top = 51
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
        object EditOZELKOD: TcxDBTextEdit
          Left = 331
          Top = 29
          DataBinding.DataField = 'OZELKOD'
          DataBinding.DataSource = DtsSIPARIS
          TabOrder = 18
          Width = 115
        end
        object cxLabel14: TcxLabel
          Left = 282
          Top = 30
          Hint = 'Teklif_'#214'deme'
          HelpType = htKeyword
          HelpKeyword = 'TEKLIF.ODEME'
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
          Left = 508
          Top = 6
          Caption = 'Ana Kaynak'
          Transparent = True
        end
        object LabelAnaKaynak: TcxLabel
          Left = 508
          Top = 29
          Caption = '---'
          Transparent = True
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 70
        Width = 1032
        Height = 407
        Align = alClient
        Caption = 'Panel3'
        TabOrder = 1
        object Panel2: TPanel
          Left = 1
          Top = 218
          Width = 1030
          Height = 188
          Align = alClient
          TabOrder = 0
          ExplicitTop = 215
          ExplicitHeight = 191
          object GridFatura: TcxGrid
            AlignWithMargins = True
            Left = 4
            Top = 31
            Width = 1022
            Height = 153
            Align = alClient
            PopupMenu = PopupMenuFatura
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            LookAndFeel.SkinName = 'LondonLiquidSky'
            ExplicitHeight = 156
            object GridFaturaView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridFaturaViewCanFocusRecord
              OnCellDblClick = GridFaturaViewCellDblClick
              DataController.DataSource = DtsSIPARISDETAY
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <
                item
                  Kind = skSum
                  FieldName = 'ISKTUTAR'
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
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.AlwaysShowEditor = True
              OptionsBehavior.FocusCellOnTab = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsSelection.HideSelection = True
              OptionsView.Footer = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object GridFaturaViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Options.Editing = False
              end
              object GridFaturaViewTUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepFatDetayTur
                Options.Editing = False
                Width = 76
              end
              object GridFaturaViewKOD1: TcxGridDBColumn
                Caption = 'Kod'
                DataBinding.FieldName = 'KOD'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Alignment.Horz = taLeftJustify
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 53
              end
              object GridFaturaViewAD: TcxGridDBColumn
                Caption = 'Ad'
                DataBinding.FieldName = 'AD'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 87
              end
              object GridFaturaViewHUCRE: TcxGridDBColumn
                Caption = 'Raf'
                DataBinding.FieldName = 'HUCRE'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 70
              end
              object GridFaturaViewADET1: TcxGridDBColumn
                Caption = 'Adet'
                DataBinding.FieldName = 'ADET'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.Alignment.Horz = taRightJustify
                Properties.ReadOnly = False
                Options.Editing = False
                Width = 29
              end
              object GridFaturaViewBIRIM1: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                Options.Editing = False
                Width = 42
              end
              object GridFaturaViewACIKLAMA1: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridFaturaViewACIKLAMA1PropertiesButtonClick
                Options.Editing = False
                Width = 158
              end
              object GridFaturaViewTESLIMTARIHI: TcxGridDBColumn
                Caption = 'Teslim Tarihi'
                DataBinding.FieldName = 'TESLIMTARIHI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 78
              end
              object GridFaturaViewPROJEKODU: TcxGridDBColumn
                Caption = 'Proje Kodu'
                DataBinding.FieldName = 'PROJEKODU'
                DataBinding.IsNullValueType = True
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
                Options.Editing = False
                Width = 210
              end
              object GridFaturaViewSATICIADI: TcxGridDBColumn
                Caption = 'Personel'
                DataBinding.FieldName = 'SATICIADI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 143
              end
              object GridFaturaViewMASRAFKOD: TcxGridDBColumn
                Caption = 'Masraf Kodu'
                DataBinding.FieldName = 'MASRAFKOD'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Visible = False
                Options.Editing = False
                Width = 77
              end
              object GridFaturaViewMASRAFAD: TcxGridDBColumn
                Caption = 'Masraf Ad'#305
                DataBinding.FieldName = 'MASRAFID'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridFaturaViewMASRAFADPropertiesButtonClick
                Visible = False
                OnGetDisplayText = GridFaturaViewMASRAFADGetDisplayText
                Options.Editing = False
                Width = 130
              end
              object GridFaturaViewIZLEME: TcxGridDBColumn
                Caption = #304'zleme'
                DataBinding.FieldName = 'IZLEME'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepStokIzleme
                Visible = False
                Options.Editing = False
                Width = 59
              end
              object GridFaturaViewOZELKOD: TcxGridDBColumn
                Caption = #214'zel Kod'
                DataBinding.FieldName = 'OZELKOD'
                DataBinding.IsNullValueType = True
                Visible = False
                Options.Editing = False
              end
              object GridFaturaViewSTOKDURUM: TcxGridDBColumn
                Caption = 'Stok Durum'
                DataBinding.FieldName = 'STOKDURUM'
                DataBinding.IsNullValueType = True
                Visible = False
                Options.Editing = False
              end
              object GridFaturaViewEKIPMAN: TcxGridDBColumn
                Caption = 'Ekipman'
                DataBinding.FieldName = 'EKIPMAN'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridFaturaViewEKIPMANIDPropertiesButtonClick
                Visible = False
                Options.Editing = False
                Width = 300
              end
              object GridFaturaViewSERINO: TcxGridDBColumn
                Caption = 'Serino'
                DataBinding.FieldName = 'SERINO'
                DataBinding.IsNullValueType = True
                Visible = False
                Options.Editing = False
              end
              object GridFaturaViewMIKTAR: TcxGridDBColumn
                Caption = 'Miktar'
                DataBinding.FieldName = 'MIKTAR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
                Visible = False
                Options.Editing = False
                Width = 48
              end
              object GridFaturaViewBIRIM2MIKTAR: TcxGridDBColumn
                Caption = 'Birim2 Miktar'
                DataBinding.FieldName = 'BIRIM2MIKTAR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
                Visible = False
                Options.Editing = False
                Width = 73
              end
              object GridFaturaViewBIRIM2AD: TcxGridDBColumn
                Caption = 'Birim2 Ad'
                DataBinding.FieldName = 'BIRIM2AD'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxLabelProperties'
                Visible = False
                Options.Editing = False
                Width = 58
              end
            end
            object GridFaturaLevel1: TcxGridLevel
              GridView = GridFaturaView
            end
          end
          object ToolBar5: TToolBar
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 1022
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
            ShowCaptions = True
            TabOrder = 1
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
            object ToolButton1: TToolButton
              Left = 162
              Top = 0
              Width = 8
              Caption = 'ToolButton4'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsSeparator
            end
            object ToolButton9: TToolButton
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
            object TamEkranTus: TToolButton
              Left = 332
              Top = 0
              Caption = 'Tam Ekran'
              ImageIndex = 6
              ImageName = 'PngImage6'
              OnClick = TamEkranTusClick
            end
            object ToolButton4: TToolButton
              Left = 413
              Top = 0
              Width = 8
              Caption = 'ToolButton4'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsSeparator
            end
            object BtnDovizKuru: TToolButton
              Left = 421
              Top = 0
              Caption = 'D'#246'viz Kuru'
              ImageIndex = 9
              ImageName = 'PngImage9'
              Visible = False
              OnClick = BtnDovizKuruClick
            end
            object ToolButton3: TToolButton
              Left = 502
              Top = 0
              Width = 8
              Caption = 'ToolButton3'
              ImageIndex = 8
              ImageName = 'PngImage15'
              Style = tbsSeparator
            end
          end
        end
        object PageControlUst: TcxPageControl
          Left = 1
          Top = 36
          Width = 1030
          Height = 182
          Align = alTop
          TabOrder = 1
          Properties.ActivePage = TabSheetGenelBilgiler
          Properties.CustomButtons.Buttons = <>
          ExplicitTop = 33
          ClientRectBottom = 178
          ClientRectLeft = 4
          ClientRectRight = 1026
          ClientRectTop = 27
          object TabSheetGenelBilgiler: TcxTabSheet
            Caption = 'Genel Bilgiler'
            ImageIndex = 0
            PopupMenu = PopupMenuFatura
            object PanelUst2: TPanel
              Left = 0
              Top = 0
              Width = 1022
              Height = 151
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
              object Bevel2: TBevel
                Left = 11
                Top = 5
                Width = 400
                Height = 143
              end
              object Bevel1: TBevel
                Left = 412
                Top = 5
                Width = 388
                Height = 143
              end
              object Label11: TcxLabel
                Left = 436
                Top = 19
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
              object LabelFaturaTarihi: TcxLabel
                Left = 436
                Top = 89
                Caption = 'Talep Tarihi'
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
                Left = 436
                Top = 115
                Caption = 'Talep No'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label6: TcxLabel
                Left = 24
                Top = 16
                Caption = 'ID'
                ParentFont = False
                Transparent = True
              end
              object ComboSiparisDURUM: TcxDBImageComboBox
                Left = 543
                Top = 13
                RepositoryItem = Tablo.RepSatinalmaAsama
                DataBinding.DataField = 'DURUM'
                DataBinding.DataSource = DtsSIPARIS
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
                TabOrder = 4
                Width = 147
              end
              object EditFatTarih: TcxDBDateEdit
                Left = 543
                Top = 86
                DataBinding.DataField = 'SIPARISTARIH'
                DataBinding.DataSource = DtsSIPARIS
                Properties.ShowTime = False
                TabOrder = 5
                Width = 147
              end
              object EditFatNo: TcxDBTextEdit
                Left = 543
                Top = 110
                DataBinding.DataField = 'SIPARISNO'
                DataBinding.DataSource = DtsSIPARIS
                TabOrder = 6
                Width = 99
              end
              object EditFaturaSaat: TcxDBTimeEdit
                Left = 641
                Top = 110
                DataBinding.DataField = 'SIPARISTARIH'
                DataBinding.DataSource = DtsSIPARIS
                TabOrder = 10
                Width = 67
              end
              object cxDBLabel1: TcxDBLabel
                Left = 120
                Top = 15
                DataBinding.DataField = 'ID'
                DataBinding.DataSource = DtsSIPARIS
                Height = 21
                Width = 74
              end
              object ComboSube: TcxDBImageComboBox
                Left = 877
                Top = 13
                RepositoryItem = Tablo.RepSubelerKendiSubesi
                DataBinding.DataField = 'SUBEID'
                DataBinding.DataSource = DtsSIPARIS
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
                TabOrder = 3
                Width = 132
              end
              object LblSube: TcxLabel
                Left = 806
                Top = 14
                Caption = #350'ube'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object lbSatici: TcxLabel
                Left = 22
                Top = 40
                Caption = 'Talep Eden'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cbSatici: TcxButtonEdit
                Left = 120
                Top = 38
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
                TabOrder = 1
                Width = 208
              end
              object cxLabel1: TcxLabel
                Left = 23
                Top = 64
                Caption = 'Birim'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object EditDepartman: TcxButtonEdit
                Left = 120
                Top = 62
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
                Properties.OnButtonClick = EditDepartmanPropertiesButtonClick
                ShowHint = True
                TabOrder = 2
                Width = 208
              end
              object EditBirimOnaylayan: TcxButtonEdit
                Left = 120
                Top = 110
                Properties.Buttons = <
                  item
                    Default = True
                    Glyph.SourceDPI = 96
                    Glyph.Data = {
                      424D360400000000000036000000280000001000000010000000010020000000
                      000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00EFF7EFFF4AA54AFF189418FFA5D6A5FFFFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00EFF7EFFF39A539FF10AD29FF18B529FF089410FFA5D6A5FFFFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FF
                      F7FF39AD39FF18AD31FF18B531FF10AD29FF10B529FF089410FFADDEADFFFFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FFF7FF42B5
                      42FF18B531FF18B539FF18B531FF31BD4AFF18AD31FF10AD29FF089410FFADDE
                      ADFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0052BD5AFF21B5
                      42FF21BD42FF21B542FF10A521FF189418FF63C673FF18B531FF10B529FF0894
                      10FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0039BD4AFF42C6
                      63FF21BD4AFF18B529FF63C663FFEFF7EFFF39AD39FF63C673FF18B531FF10B5
                      29FF109410FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF009CE7A5FF42C6
                      5AFF39BD4AFF63CE6BFFFFFFFF00FFFFFF00EFF7EFFF31A531FF63CE73FF18B5
                      31FF10B529FF109410FFB5E7B5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00D6F7
                      D6FFB5EFBDFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00EFF7EFFF31A531FF63CE
                      73FF18B531FF10B529FF109410FFBDDEBDFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7E7FF29A5
                      29FF63CE73FF18B531FF18B531FF189418FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7
                      E7FF29A529FF63CE7BFF29BD4AFF299C31FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00E7F7E7FF31AD31FF31A531FFCEE7CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                    Kind = bkGlyph
                  end
                  item
                    Glyph.SourceDPI = 96
                    Glyph.Data = {
                      424D360400000000000036000000280000001000000010000000010020000000
                      000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFEFF7FF3939
                      BDFF2129B5FF8484D6FFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007B7B
                      CEFF7373C6FFD6D6EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007373CEFF1842
                      F7FF184AF7FF1031D6FF3131BDFFDEDEF7FFFFFFFF00FFFFFF006B6BD6FF0829
                      D6FF0831D6FF0010B5FF7373CEFFFFFFFF00FFFFFF00FFFFFF003131BDFF2152
                      F7FF2152FFFF2152FFFF1842E7FF1821B5FFC6C6EFFF6B6BCEFF1031DEFF1042
                      F7FF1039F7FF0839EFFF0018BDFFA5A5DEFFFFFFFF00FFFFFF00BDBDE7FF1831
                      DEFF295AFFFF2152FFFF2152FFFF184AEFFF0810B5FF1031DEFF184AFFFF1042
                      F7FF1042F7FF1042F7FF0839EFFF4242B5FFFFFFFF00FFFFFF00ADADE7FF2139
                      DEFF396BFFFF295AFFFF295AFFFF295AFFFF2152FFFF1852FFFF184AFFFF184A
                      F7FF1042F7FF1039EFFF1821B5FFBDBDE7FFFFFFFF00FFFFFF00FFFFFF009C9C
                      E7FF2129CEFF396BFFFF316BFFFF295AFFFF295AFFFF2152FFFF214AFFFF184A
                      FFFF1039EFFF3139BDFFE7E7F7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00E7E7F7FF4242CEFF314AE7FF396BFFFF315AFFFF295AFFFF2152FFFF1839
                      E7FF4242BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00B5B5EFFF2142DEFF396BFFFF3163FFFF315AFFFF295AFFFF184A
                      E7FF3131BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF004242D6FF4A7BFFFF4273FFFF396BFFFF396BFFFF295AFFFF215A
                      FFFF1039D6FF6B6BD6FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00D6D6F7FF2939DEFF5284FFFF4273FFFF3963F7FF1018C6FF396BFFFF295A
                      FFFF2152FFFF1021C6FFB5B5EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF007373E7FF527BF7FF5284FFFF4A7BFFFF2129CEFFBDBDEFFF2129CEFF396B
                      FFFF2152FFFF184AEFFF2121BDFFEFEFFFFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF003139DEFF6B9CFFFF5A8CFFFF294AE7FFA5A5EFFFFFFFFF00CECEF7FF1829
                      CEFF3163FFFF2152FFFF1039DEFF6363CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF006B6BEFFF3952E7FF5A84FFFF4242DEFFFFFFFF00FFFFFF00FFFFFF00B5B5
                      EFFF1829D6FF295AFFFF1031E7FF3131C6FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00C6C6F7FF5A5AD6FFCECEF7FFFFFFFF00FFFFFF00FFFFFF00FFFF
                      FF009C9CE7FF4242CEFFB5B5E7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                    Kind = bkGlyph
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = EditBirimOnaylayanPropertiesButtonClick
                TabOrder = 15
                Width = 208
              end
              object cxLabel2: TcxLabel
                Left = 21
                Top = 113
                Caption = 'Birim Onaylayan'
                Transparent = True
              end
              object cxLabel3: TcxLabel
                Left = 21
                Top = 88
                Caption = 'Birim Onaylayacak'
                Transparent = True
              end
              object cbBirimOnaylayacak: TcxDBImageComboBox
                Left = 120
                Top = 86
                DataBinding.DataField = 'BIRIMONAYLAYACAK'
                DataBinding.DataSource = DtsSIPARIS
                Properties.ImmediatePost = True
                Properties.ImmediateUpdateText = True
                Properties.Items = <>
                TabOrder = 18
                Width = 208
              end
              object cbStokDepo: TcxDBImageComboBox
                Left = 543
                Top = 62
                RepositoryItem = Tablo.RepStokDepolarAktif
                DataBinding.DataField = 'GIRISDEPO'
                DataBinding.DataSource = DtsSIPARIS
                Properties.ImageAlign = iaRight
                Properties.Items = <>
                TabOrder = 19
                Width = 146
              end
              object cxLabel4: TcxLabel
                Left = 438
                Top = 64
                Caption = 'Giri'#351' Deposu'
                Transparent = True
              end
              object cxLabel5: TcxLabel
                Left = 438
                Top = 40
                Caption = #199#305'k'#305#351' Deposu'
                Transparent = True
              end
              object cbCikDepo: TcxDBImageComboBox
                Left = 543
                Top = 38
                RepositoryItem = Tablo.RepStokDepolarAktif
                DataBinding.DataField = 'CIKISDEPO'
                DataBinding.DataSource = DtsSIPARIS
                Properties.ImageAlign = iaRight
                Properties.Items = <>
                TabOrder = 22
                Width = 146
              end
              object EditDETAYBOLUMU: TcxDBTextEdit
                Left = 877
                Top = 43
                DataBinding.DataField = 'DETAYBOLUMU'
                DataBinding.DataSource = DtsSIPARIS
                Enabled = False
                Style.ReadOnly = True
                TabOrder = 23
                Width = 132
              end
              object cxLabel11: TcxLabel
                Left = 806
                Top = 45
                Caption = #220'rt.Emir No'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
              end
            end
          end
          object TabSheetEkAlanlar: TcxTabSheet
            Caption = 'Ek Alanlar'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object PanelAlt: TPanel
              Left = 0
              Top = -92
              Width = 1022
              Height = 243
              Align = alBottom
              BevelOuter = bvNone
              TabOrder = 0
            end
            object PanelUst: TPanel
              Left = 0
              Top = 0
              Width = 1022
              Height = 117
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 1
            end
          end
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 1024
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 70
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
          TabOrder = 2
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
            Left = 70
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Style = tbsTextButton
          end
          object ToolButton8: TToolButton
            Left = 140
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 9
            ImageName = 'PngImage8'
            Style = tbsSeparator
          end
          object YaziciYaz: TToolButton
            Left = 148
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
          object ToolButton2: TToolButton
            Left = 218
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Style = tbsSeparator
          end
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
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel4: TPanel
        Left = 0
        Top = 576
        Width = 1032
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
          Width = 884
        end
        object BtnMesajGonder: TcxButton
          Left = 885
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
          Left = 970
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
        Top = 556
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
        ExplicitTop = 555
        AnchorX = 1032
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 1032
        Height = 486
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
  object dsAra: TDataSource
    AutoEdit = False
    Left = 337
    Top = 25
  end
  object OpenDialog1: TOpenDialog
    Left = 906
    Top = 342
  end
  object PopupMenuFatura: TPopupMenu
    Left = 34
    Top = 284
    object utarDvzHesapla1: TMenuItem
      Caption = 'Tutar / D'#246'viz Hesapla'
      OnClick = TutarDvzHesapla1Click
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
          Caption = #214'zel'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
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
          Tag = -1
          Caption = #214'zel'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
      end
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object FaturaIptalIsaretle: TMenuItem
      Caption = 'Bu Sipari'#351'i '#304'ptal et'
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object SipariKoanAyarlar1: TMenuItem
      Caption = 'Sipari'#351' Ko'#231'an Ayarlar'#305
      OnClick = SipariKoanAyarlar1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object retimPlanndaGsterme1: TMenuItem
      Caption = #220'retim Planlan'#305'nda'
      object GsterSeiliSatr1: TMenuItem
        Tag = 1
        Caption = 'G'#246'ster (Se'#231'ili Sat'#305'r)'
        OnClick = GsterSeiliSatr1Click
      end
      object GsterTm1: TMenuItem
        Tag = 2
        Caption = 'G'#246'ster (T'#252'm'#252')'
        OnClick = GsterSeiliSatr1Click
      end
      object GstermeSeiliSatr1: TMenuItem
        Tag = 3
        Caption = 'G'#246'sterme (Se'#231'ili Sat'#305'r)'
        OnClick = GsterSeiliSatr1Click
      end
      object GstermeTm1: TMenuItem
        Tag = 4
        Caption = 'G'#246'sterme (T'#252'm'#252')'
        OnClick = GsterSeiliSatr1Click
      end
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Dei1: TMenuItem
      Caption = 'De'#287'i'#351
      object MenuDegisTeslimTarihi: TMenuItem
        Caption = 'Teslim Tarihi'
        OnClick = MenuDegisTeslimTarihiClick
      end
    end
  end
  object DtsSIPARISDETAY: TDataSource
    DataSet = SIPARISDETAY
    OnStateChange = DtsSIPARISDETAYStateChange
    Left = 943
    Top = 220
  end
  object DtsSIPARIS: TDataSource
    DataSet = SIPARIS
    OnStateChange = DtsSIPARISStateChange
    Left = 840
    Top = 205
  end
  object PopupMenuYaz: TPopupMenu
    Left = 293
    Top = 113
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
  object TabRehber: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select ID,KOD,FIRMA'
      '   from REHBER'
      'where ID = :PID')
    Left = 435
    Top = 227
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
    Left = 491
    Top = 232
  end
  object SIPARISDETAY: TFDQuery
    AutoCalcFields = False
    BeforeOpen = SIPARISDETAYBeforeOpen
    BeforePost = SIPARISDETAYBeforePost
    AfterPost = SIPARISDETAYAfterPost
    AfterDelete = SIPARISDETAYAfterDelete
    OnCalcFields = SIPARISDETAYCalcFields
    OnNewRecord = SIPARISDETAYNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select F.* ,'
      
        'AD = CASE WHEN F.TUR =0 THEN  (select MG.AD from MASRAFGELIR MG ' +
        'where MG.ID=F.URUNID) '
      
        #9' ELSE (select S.STOKADI from STOKLAR S where S.ID=F.URUNID) END' +
        ','
      
        'KOD= CASE WHEN F.TUR =0 THEN  (select MG.KOD from MASRAFGELIR MG' +
        ' where MG.ID=F.URUNID) '
      #9' ELSE (select S.KOD from STOKLAR S where S.ID=F.URUNID) END,'
      
        'HUCRE= CASE WHEN F.TUR =0 THEN '#39#39' ELSE (select S.HUCRE from STOK' +
        'LAR S where S.ID=F.URUNID) END,'
      
        'BIRIMAD = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-2702 and DIL=' +
        '-1 and DEGER = F.BIRIM),'
      
        'BIRIM2MIKTAR=CASE WHEN F.TUR=0 THEN F.MIKTAR ELSE F.MIKTAR/(sele' +
        'ct S.BIRIM2MIKTAR from STOKLAR S where S.ID=F.URUNID) END,'
      
        'BIRIM2AD= CASE WHEN F.TUR =0 THEN  (SELECT TOP 1 ANAHTAR FROM GE' +
        'NINI WHERE BOLUM =-2702 and DEGER = convert(varchar(10),F.BIRIM)' +
        ' )  ELSE (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM =-2702 an' +
        'd DEGER = convert(varchar(10),(select S.BIRIM2 from STOKLAR S wh' +
        'ere S.ID=F.URUNID)) ) END,'
      
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=F.PROJE' +
        'ID),'
      
        'SATICIADI=(select R.FIRMA from REHBER R where R.ID=F.SATICIKODU)' +
        ','
      
        'DONUSENMIKTAR=isnull((select top 1 F.MIKTAR*(SC.ADET2/SC.ADET1) ' +
        'from STOKCEVRIM SC where SC.STOKID=F.URUNID and F.TUR=1 and F.BI' +
        'RIM=SC.BIRIM1 and SC.BIRIM2=(select S.DONUSUMTURU from SIPARIS S' +
        ' where S.ID=F.SIPARISID) ),0.0),'
      
        'URETIMPLANINDAGOSTER=case when isnull(URETIMPLANDETAYID,0)<0 the' +
        'n 0 when isnull(URETIMPLANDETAYID,0)=0 then 1 else null end,'
      
        'EKIPMAN=(select E1.AD from EKIPMANLAR E1 inner join EKIPMANREHBE' +
        'R ER1 on E1.ID=ER1.EKIPMANID where ER1.ID=F.EKIPMANID),'
      
        'SERINO=(select ER2.SERINO from EKIPMANREHBER ER2  where ER2.ID=F' +
        '.EKIPMANID)'
      ''
      'from SIPARISDETAY F '
      'Where SIPARISID = :Par order by F.ID')
    Left = 810
    Top = 168
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1168
      end>
  end
  object SIPARIS: TFDQuery
    AutoCalcFields = False
    AfterOpen = SIPARISAfterOpen
    BeforeEdit = SIPARISBeforeEdit
    BeforePost = SIPARISBeforePost
    AfterPost = SIPARISAfterPost
    AfterScroll = SIPARISAfterScroll
    OnNewRecord = SIPARISNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT *,'
      'YAZIYLATOPLAM=( dbo.fn_MoneyToText(SIPARIS_TUTARI,KUR,0)),'
      
        'YAZIYLATOPLAM_DOVIZ=( dbo.fn_MoneyToText(DOVIZ_TUTARI, DOVIZ_CIN' +
        'SI,0)),'
      
        'ILGILIADI=(select FIRMA from REHBER RP where RP.ID=S.MUS_ILGILI)' +
        ','
      
        'PERSONELADI=(select R.FIRMA from REHBER R where R.ID=S.SATICIKOD' +
        'U) ,'
      
        'SEVKADRES=(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 2 Order by 1 )' +
        ','
      
        'SEVKILCE =(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 6 Order by 1),'
      
        'SEVKIL = (SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBE' +
        'RBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID' +
        '=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 8 Order by 1 ),'
      
        'ONAYLAYANADI=(select FIRMA from REHBER where ID=(select I.EKLEYE' +
        'N from ISEMRI I where I.YERI=S.TUR and I.YERID=S.ID)),'
      
        'KAYNAKBELGENO=dbo.fn_KaynakBelgeNolariStrOlarakGetir(S.TUR,S.ID)' +
        ','
      
        'TESLIMAD=(select ANAHTAR from GENINI where BOLUM=-2903 and DEGER' +
        '=S.TESLIM_SEKLI),'
      
        'ODEMEAD=(select ANAHTAR from GENINI where BOLUM=-2904 and DEGER=' +
        'S.ODEME)'
      ''
      'FROM SIPARIS S WHERE ID = :Par')
    Left = 851
    Top = 154
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object frxSIPARISDETAY: TfrxDBDataset
    UserName = 'SIPARISDETAY'
    CloseDataSource = False
    DataSet = SIPARISDETAY
    BCDToCurrency = False
    DataSetOptions = []
    Left = 597
    Top = 379
  end
  object frxSIPARIS: TfrxDBDataset
    UserName = 'SIPARIS'
    CloseDataSource = False
    DataSet = SIPARIS
    BCDToCurrency = False
    DataSetOptions = []
    Left = 526
    Top = 369
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 35
    Top = 177
  end
  object dtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 1029
    Top = 358
  end
  object TOPLAMLAR: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'EXEC SP_PRG_Siparis_DipToplami @SIPARISID=:SIPARISID')
    Left = 1024
    Top = 296
    ParamData = <
      item
        Name = 'SIPARISID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 111
      end>
  end
  object frxTOPLAMLAR: TfrxDBDataset
    UserName = 'TOPLAMLAR'
    CloseDataSource = False
    DataSet = TOPLAMLAR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 697
    Top = 379
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
        FieldName = 'KUR'
        FieldAlias = 'KUR'
      end
      item
        FieldName = 'DOVIZTUTARI'
        FieldAlias = 'DOVIZTUTARI'
      end
      item
        FieldName = 'DOVIZ_KURU'
        FieldAlias = 'DOVIZ_KURU'
      end>
  end
  object DtsHesapOzeti: TDataSource
    DataSet = TabHesapOzeti
    Left = 351
    Top = 212
  end
  object TabHesapOzeti: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT * from [dbo].[fn_CARIHESAPOZETI] (:PRehID,:PBirim,:FatTut' +
        'ari) ')
    Left = 272
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
  object frxHesapOzeti: TfrxDBDataset
    UserName = 'Hesap '#214'zeti'
    CloseDataSource = False
    DataSet = TabHesapOzeti
    BCDToCurrency = False
    DataSetOptions = []
    Left = 257
    Top = 376
  end
  object DtsStokDetay: TDataSource
    DataSet = tabStokDetay
    OnStateChange = DtsSIPARISStateChange
    Left = 792
    Top = 277
  end
  object tabStokDetay: TFDQuery
    AutoCalcFields = False
    BeforeEdit = SIPARISBeforeEdit
    BeforePost = SIPARISBeforePost
    AfterPost = SIPARISAfterPost
    AfterScroll = SIPARISAfterScroll
    OnNewRecord = SIPARISNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select SD.* , ST.*,'
      
        'BIRIMAD = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-2702 and DIL=' +
        '-1 and DEGER = SD.BIRIM),'
      
        'BIRIM2AD=  (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM =-2702 ' +
        'and DEGER = ST.BIRIM2 ),'
      
        'KATEGORIADI=(select K.AD from KATEGORI K where K.ID=ST.KATEGORI)' +
        ','
      'MARKAADI=StokMarka.ANAHTAR,'
      'MODELADI=StokModel.ANAHTAR,'
      
        'GRUBUADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2704 and' +
        ' DEGER = ST.GRUBU and DIL=-1),'
      
        'OZELLIKADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2705 a' +
        'nd DEGER = ST.GRUBU and DIL=-1),'
      
        'ICERIKADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2718 an' +
        'd DEGER = ST.GRUBU and DIL=-1)'
      ''
      ''
      'FROM '
      #9'SIPARISDETAY SD   left outer join '
      #9'STOKLAR ST on SD.TUR=1 and SD.URUNID=ST.ID left outer join'
      
        #9'GENINI StokMarka ON StokMarka.DEGER = ST.MARKA AND StokMarka.BO' +
        'LUM=-2701 and StokMarka.DIL=-1 left outer join'
      
        #9'GENINI StokModel ON StokModel.DEGER = ST.MODEL and StokModel.DI' +
        'L=-1 AND StokModel.BOLUM=convert(int,'#39'-2701'#39'+convert(varchar(10)' +
        ',ST.MARKA))'
      ''
      'WHERE SD.SIPARISID = :Par')
    Left = 787
    Top = 330
    ParamData = <
      item
        Name = 'Par'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object frxStokDetay: TfrxDBDataset
    UserName = 'STOKDETAY'
    CloseDataSource = False
    DataSet = tabStokDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 790
    Top = 377
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
    Left = 465
    Top = 233
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
    Left = 416
    Top = 32
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
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
    Left = 768
    Top = 400
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
    Left = 440
    Top = 364
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
