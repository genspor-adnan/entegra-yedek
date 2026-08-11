object DemirbasWizardDlg: TDemirbasWizardDlg
  Left = 0
  Top = 0
  ActiveControl = cxPageControl1
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Demirba'#351' Sihirbaz'#305
  ClientHeight = 585
  ClientWidth = 901
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 585
    Align = alLeft
    TabOrder = 0
    object DemirbasTus: TcxButton
      Left = 0
      Top = 80
      Width = 84
      Height = 29
      Caption = 'Demirbas'
      TabOrder = 0
      OnClick = DemirbasTusClick
    end
    object DokumanTus: TcxButton
      Tag = 1
      Left = 0
      Top = 115
      Width = 84
      Height = 29
      Caption = 'Yorum/Medya'
      TabOrder = 1
      OnClick = DemirbasTusClick
    end
    object TarihceTus: TcxButton
      Tag = 2
      Left = 0
      Top = 151
      Width = 84
      Height = 29
      Caption = 'Ge'#231'mi'#351
      TabOrder = 2
      OnClick = DemirbasTusClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 815
    Height = 585
    ActivePage = DemirbasEkr
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
      815
      585)
    object DemirbasEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Demirbas bilgileri'
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
      OnPage = DemirbasEkrPage
      OnExitPage = DemirbasEkrExitPage
      object cxPageControl1: TcxPageControl
        Properties.Images = Tablo.PNGImageList2
        Left = 0
        Top = 217
        Width = 815
        Height = 326
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = cxTabSheet1
        Properties.CustomButtons.Buttons = <>
        LookAndFeel.Kind = lfStandard
        OnChange = cxPageControl1Change
        ClientRectBottom = 322
        ClientRectLeft = 4
        ClientRectRight = 811
        ClientRectTop = 27
        object cxTabSheet1: TcxTabSheet
          Caption = 'Genel '#214'zellikler'
          ImageIndex = 11
          object Label1: TcxLabel
            Tag = 21
            Left = 323
            Top = 64
            Caption = 'Not'
            ParentColor = False
            Style.Color = cl3DLight
            Transparent = True
          end
          object MemoNOTLAR: TcxDBMemo
            Tag = 20
            Left = 466
            Top = 63
            DataBinding.DataField = 'NOTLAR'
            DataBinding.DataSource = DtsDemirbas
            TabOrder = 12
            Height = 70
            Width = 242
          end
          object cxLabel3: TcxLabel
            Left = 323
            Top = 39
            Caption = 'Kategori'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsUnderline]
            Style.TextStyle = []
            Style.IsFontAssigned = True
          end
          object cbDemirbasKategori: TcxButtonEdit
            Left = 465
            Top = 37
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
            Properties.OnButtonClick = cbDemirbasKategoribtnPropertiesButtonClick
            ShowHint = True
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBackground
            TabOrder = 11
            Width = 243
          end
          object DateSKT: TcxDBDateEdit
            Left = 74
            Top = 135
            DataBinding.DataField = 'SKT'
            DataBinding.DataSource = DtsDemirbas
            Enabled = False
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 5
            Visible = False
            Width = 171
          end
          object lblSKT: TcxLabel
            Left = 5
            Top = 137
            Caption = 'SKT'
            Transparent = True
            Visible = False
          end
          object cxLabel6: TcxLabel
            Left = 5
            Top = 110
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = 'Barkod'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditBarkod: TcxDBTextEdit
            Left = 74
            Top = 108
            DataBinding.DataField = 'BARKOD'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 4
            Width = 171
          end
          object EditRFID: TcxDBTextEdit
            Left = 74
            Top = 81
            DataBinding.DataField = 'RFID'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 3
            Width = 171
          end
          object EditSERINO: TcxDBTextEdit
            Left = 74
            Top = 54
            DataBinding.DataField = 'SERINO'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 2
            Width = 171
          end
          object cxLabel19: TcxLabel
            Left = 5
            Top = 56
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = 'Serino'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel5: TcxLabel
            Left = 5
            Top = 83
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = 'RFID/IMEI'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel2: TcxLabel
            Left = 324
            Top = 164
            Caption = 'Ekleyen *'
          end
          object ComboEkleyen: TcxButtonEdit
            Left = 466
            Top = 162
            ParentShowHint = False
            Properties.Alignment.Horz = taLeftJustify
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
            Properties.OnButtonClick = ComboKabuledenPropertiesButtonClick
            ShowHint = True
            TabOrder = 15
            Width = 242
          end
          object LabelMarka: TcxLabel
            Left = 5
            Top = 4
            Cursor = crHandPoint
            Hint = 'Demirbas_Marka'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.MARKA'
            Caption = 'Marka'
            FocusControl = ComboMARKA
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelMarkaClick
          end
          object ComboMARKA: TcxDBImageComboBox
            Left = 74
            Top = 0
            Cursor = crHandPoint
            RepositoryItem = Tablo.Demirbas_Marka
            DataBinding.DataField = 'MARKA'
            DataBinding.DataSource = DtsDemirbas
            Properties.Items = <>
            Properties.OnEditValueChanged = ComboMARKAPropertiesEditValueChanged
            TabOrder = 0
            Width = 171
          end
          object LabelModel: TcxLabel
            Left = 5
            Top = 30
            Cursor = crHandPoint
            Caption = 'Model'
            FocusControl = ComboMODEL
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelModelClick
          end
          object ComboMODEL: TcxDBImageComboBox
            Left = 74
            Top = 27
            DataBinding.DataField = 'MODEL'
            DataBinding.DataSource = DtsDemirbas
            Properties.Items = <>
            TabOrder = 1
            Width = 171
          end
          object CheckGARANTI: TcxDBCheckBox
            Left = 632
            Top = 193
            Caption = 'Takip /Uyar'#305' var'
            DataBinding.DataField = 'TAKIP'
            DataBinding.DataSource = DtsDemirbas
            TabOrder = 25
          end
          object CheckKALIBRASYON: TcxDBCheckBox
            Left = 632
            Top = 214
            Caption = 'Kalibrasyon '#246'l'#231#252'm'#252' var'
            DataBinding.DataField = 'KALIBRASYON'
            DataBinding.DataSource = DtsDemirbas
            TabOrder = 26
          end
          object ComboTeknikKabul: TcxButtonEdit
            Tag = 337
            Left = 588
            Top = 135
            HelpType = htKeyword
            HelpKeyword = 'TEKNIKBILGI'
            ParentShowHint = False
            Properties.Alignment.Horz = taLeftJustify
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
            Properties.OnButtonClick = ComboTeknikSorumluPropertiesButtonClick
            ShowHint = True
            TabOrder = 14
            Visible = False
            Width = 120
          end
          object LabelTeknikServis: TcxLabel
            Left = 324
            Top = 137
            Caption = 'Teknik Servis Sorumlu/Bilgi'
            Visible = False
          end
          object ComboTeknikSorumlu: TcxButtonEdit
            Tag = 335
            Left = 466
            Top = 135
            HelpType = htKeyword
            HelpKeyword = 'TEKNIKSORUMLU'
            ParentShowHint = False
            Properties.Alignment.Horz = taLeftJustify
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
            Properties.OnButtonClick = ComboTeknikSorumluPropertiesButtonClick
            ShowHint = True
            TabOrder = 13
            Visible = False
            Width = 120
          end
          object CheckMASRAF: TcxDBCheckBox
            Left = 467
            Top = 193
            Caption = 'Masraf Kalemi var'
            DataBinding.DataField = 'MASRAF'
            DataBinding.DataSource = DtsDemirbas
            TabOrder = 28
            OnClick = CheckMASRAFClick
          end
          object CheckAMORTISMAN: TcxDBCheckBox
            Left = 467
            Top = 214
            Caption = 'Amortisman var'
            DataBinding.DataField = 'AMORTISMAN'
            DataBinding.DataSource = DtsDemirbas
            TabOrder = 29
            OnClick = CheckAMORTISMANClick
          end
          object CheckTeknikServisvar: TcxDBCheckBox
            Left = 632
            Top = 236
            Caption = 'Teknik Servis var'
            DataBinding.DataField = 'SERVIS'
            DataBinding.DataSource = DtsDemirbas
            Properties.OnChange = CheckTeknikServisvarPropertiesChange
            TabOrder = 30
          end
          object cxLabel1: TcxLabel
            Left = 5
            Top = 163
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = #214'zellik 1'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditOZELLIK1: TcxDBTextEdit
            Left = 73
            Top = 162
            DataBinding.DataField = 'OZELLIK1'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 6
            Width = 171
          end
          object cxLabel8: TcxLabel
            Left = 5
            Top = 190
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = #214'zellik 2'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditOZELLIK2: TcxDBTextEdit
            Left = 73
            Top = 189
            DataBinding.DataField = 'OZELLIK2'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 7
            Width = 171
          end
          object cxLabel10: TcxLabel
            Left = 5
            Top = 217
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = #214'zellik 3'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditOZELLIK3: TcxDBTextEdit
            Left = 73
            Top = 216
            DataBinding.DataField = 'OZELLIK3'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 8
            Width = 171
          end
          object cxLabel11: TcxLabel
            Left = 5
            Top = 244
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = #214'zellik 4'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditOZELLIK4: TcxDBTextEdit
            Left = 73
            Top = 243
            DataBinding.DataField = 'OZELLIK4'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 9
            Width = 171
          end
          object EditOZELLIK5: TcxDBTextEdit
            Left = 73
            Top = 270
            DataBinding.DataField = 'OZELLIK5'
            DataBinding.DataSource = DtsDemirbas
            Properties.Alignment.Horz = taLeftJustify
            StyleDisabled.Color = clWhite
            StyleDisabled.TextColor = clBtnText
            TabOrder = 10
            Width = 171
          end
          object cxLabel12: TcxLabel
            Left = 5
            Top = 271
            Hint = 'Demirbas_Teslim '#350'ekli'
            Caption = #214'zellik 5'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
        end
        object TabSheetMasraf: TcxTabSheet
          Caption = 'Masraf Kalemi'
          ImageIndex = 19
          ExplicitHeight = 298
          object ToolBar4: TToolBar
            Left = 0
            Top = 0
            Width = 807
            Height = 24
            Margins.Bottom = 0
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
            object MasrafEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = MasrafEkleTusClick
            end
            object MasrafSilTus: TToolButton
              Left = 48
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = MasrafSilTusClick
            end
          end
          object gridMasraf: TcxGrid
            Left = 0
            Top = 24
            Width = 807
            Height = 271
            Align = alClient
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            LookAndFeel.SkinName = 'LondonLiquidSky'
            object gridMasrafView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dtsDemirbasMasraf
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object gridMasrafViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Visible = False
              end
              object gridMasrafViewKOD: TcxGridDBColumn
                DataBinding.FieldName = 'KOD'
                Width = 196
              end
              object gridMasrafViewAD: TcxGridDBColumn
                DataBinding.FieldName = 'AD'
                Width = 441
              end
            end
            object gridMasrafLevel1: TcxGridLevel
              GridView = gridMasrafView
            end
          end
        end
        object TabSheetAmortisman: TcxTabSheet
          Caption = 'Amortisman'
          ImageIndex = 19
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object cxLabel21: TcxLabel
            Left = 3
            Top = 83
            Caption = 'Biti'#351' Y'#305'l'#305':'
            Properties.Alignment.Horz = taRightJustify
            Transparent = True
            AnchorX = 51
          end
          object ButtonEditAmortisman: TcxButtonEdit
            Left = 2
            Top = 4
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end
              item
                Caption = '-'
                Kind = bkText
              end>
            Properties.OnButtonClick = ButtonEditAmortismanPropertiesButtonClick
            TabOrder = 1
            Width = 228
          end
          object cxLabel20: TcxLabel
            Left = 3
            Top = 58
            Caption = 'Oran %:'
            Properties.Alignment.Horz = taRightJustify
            Transparent = True
            AnchorX = 46
          end
          object cxLabel18: TcxLabel
            Left = 3
            Top = 34
            Caption = 'Y'#305'l:'
            Properties.Alignment.Horz = taRightJustify
            Transparent = True
            AnchorX = 23
          end
          object lblOran2: TcxLabel
            Left = 143
            Top = 58
            AutoSize = False
            Caption = 'Oran 2 %:'
            Properties.Alignment.Horz = taRightJustify
            Transparent = True
            Height = 20
            Width = 51
            AnchorX = 194
          end
          object lblBitisYili: TcxLabel
            Left = 73
            Top = 83
            AutoSize = False
            Properties.Alignment.Horz = taLeftJustify
            Transparent = True
            Height = 20
            Width = 51
          end
          object lblAmortismanOran: TcxDBLabel
            Left = 73
            Top = 58
            DataBinding.DataField = 'ORAN'
            DataBinding.DataSource = DtsAmortisman
            Properties.Alignment.Horz = taLeftJustify
            Properties.Orientation = cxoLeft
            Transparent = True
            Height = 22
            Width = 72
          end
          object lblAmortismanYil: TcxDBLabel
            Left = 73
            Top = 33
            DataBinding.DataField = 'YIL'
            DataBinding.DataSource = DtsAmortisman
            Properties.Alignment.Horz = taLeftJustify
            Properties.Orientation = cxoLeft
            Transparent = True
            Height = 21
            Width = 106
          end
          object lblAmortismanOran2: TcxDBLabel
            Left = 196
            Top = 58
            DataBinding.DataField = 'ORAN2'
            DataBinding.DataSource = DtsAmortisman
            Properties.Alignment.Horz = taLeftJustify
            Properties.Orientation = cxoLeft
            Transparent = True
            Height = 22
            Width = 100
          end
          object cxLabel24: TcxLabel
            Left = 3
            Top = 112
            Caption = 'A'#231#305'klama:'
            Properties.Alignment.Horz = taRightJustify
            Transparent = True
            AnchorX = 54
          end
          object cxDBMemo1: TcxDBMemo
            Left = 60
            Top = 111
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsAmortisman
            TabOrder = 10
            Height = 146
            Width = 348
          end
        end
      end
      object cxDBLabel2: TcxDBLabel
        Left = 139
        Top = 5
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsDemirbas
        Transparent = True
        Height = 21
        Width = 65
      end
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 809
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 66
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
        object YaziciYaz: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          ImageName = 'PngImage15'
          PopupMenu = AnaForm.PopupMDI
          Style = tbsTextButton
        end
      end
      object PageControl1: TcxPageControl
        Properties.Images = Tablo.PNGImageList2
        Left = 0
        Top = 105
        Width = 815
        Height = 112
        Align = alTop
        TabOrder = 3
        Properties.ActivePage = TabSheetGenel
        Properties.CustomButtons.Buttons = <>
        OnChange = PageControl1Change
        ClientRectBottom = 108
        ClientRectLeft = 4
        ClientRectRight = 811
        ClientRectTop = 27
        object TabSheetGenel: TcxTabSheet
          Caption = 'Genel'
          Color = 11776947
          ImageIndex = 11
          ParentColor = False
          object PanelUst: TPanel
            Left = 0
            Top = 0
            Width = 807
            Height = 81
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
              807
              81)
            object btnKapat: TSpeedButton
              Left = 1050
              Top = 7
              Width = 64
              Height = 23
              Caption = 'Kapat'
              Flat = True
              Glyph.Data = {
                66010000424D6601000000000000760000002800000013000000140000000100
                040000000000F000000000000000000000001000000010000000000000000000
                80000080000000808000800000008000800080800000C0C0C000808080000000
                FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
                7777777600007777777777777777777000007777777777777777777000007777
                777777777777777000007777777777777770F77C0000777770F7777777777776
                00007777000F7777770F777000007777000F777770F77770000077777000F777
                00F7777E0000777777000F700F7777700000777777700000F777777F00007777
                7777000F777777760000777777700000F77777700000777777000F70F7777770
                000077770000F77700F7777000007770000F7777700F7770000077700F777777
                7700F77400007777777777777777777600007777777777777777777000007777
                77777777777777700000}
            end
            object LabelStokKodu: TcxLabel
              Left = 12
              Top = 56
              Hint = 'Demirbas_Teslim '#350'ekli'
              Caption = #220'r'#252'n Kodu'
            end
            object ComboStokKodu: TcxDBButtonEdit
              Left = 88
              Top = 55
              DataBinding.DataField = 'STOKKODU'
              DataBinding.DataSource = DtsDemirbas
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
              Properties.OnButtonClick = ComboStokKoduPropertiesButtonClick
              ShowHint = True
              TabOrder = 0
              Width = 242
            end
            object cxLabel7: TcxLabel
              Left = 12
              Top = 31
              Hint = 'Demirbas_Teslim '#350'ekli'
              Caption = 'Demirba'#351' Ad'#305'*'
            end
            object cxDBLabel1: TcxDBLabel
              Left = 332
              Top = 52
              DataBinding.DataField = 'STOKID'
              DataBinding.DataSource = DtsDemirbas
              Transparent = True
              Height = 21
              Width = 49
            end
            object LblSube: TcxLabel
              Left = 478
              Top = 4
              Anchors = [akTop, akRight]
              Caption = #350'ube'
            end
            object ComboSube: TcxDBImageComboBox
              Left = 555
              Top = 2
              RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
              Anchors = [akTop, akRight]
              DataBinding.DataField = 'SUBEID'
              DataBinding.DataSource = DtsDemirbas
              Properties.Alignment.Horz = taLeftJustify
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 0
                  Value = 4
                end
                item
                  Description = 'Zimmet'
                  Value = 1
                end
                item
                  Description = 'Kay'#305'p'
                  Value = 2
                end
                item
                  Description = 'Hurda'
                  Value = 3
                end
                item
                  Description = 'Transfer'
                  Value = 5
                end
                item
                  Description = 'Bo'#351
                  Value = 9
                end
                item
                  Description = 'Serviste'
                  Value = 6
                end
                item
                  Description = 'Servis '#304'ade'
                  Value = 7
                end>
              StyleDisabled.Color = clWhite
              StyleDisabled.TextColor = clBlack
              TabOrder = 3
              Width = 151
            end
            object cxLabel9: TcxLabel
              Left = 12
              Top = 8
              Hint = 'Demirbas_Teslim '#350'ekli'
              Caption = 'Demirba'#351' No*'
            end
            object EditDEMIRBASNO: TcxDBTextEdit
              Left = 88
              Top = 4
              DataBinding.DataField = 'DEMIRBASNO'
              DataBinding.DataSource = DtsDemirbas
              Enabled = False
              Properties.Alignment.Horz = taLeftJustify
              Properties.ReadOnly = False
              StyleDisabled.Color = clWhite
              StyleDisabled.TextColor = clBtnText
              TabOrder = 1
              Width = 219
            end
            object EditDEMIRBASADI: TcxDBTextEdit
              Left = 88
              Top = 30
              DataBinding.DataField = 'DEMIRBASADI'
              DataBinding.DataSource = DtsDemirbas
              Properties.Alignment.Horz = taLeftJustify
              Properties.ReadOnly = False
              StyleDisabled.Color = clWhite
              StyleDisabled.TextColor = clBtnText
              TabOrder = 2
              Width = 242
            end
            object KodAgaciTus: TcxButton
              Left = 305
              Top = 5
              Width = 25
              Height = 23
              OptionsImage.Glyph.SourceDPI = 96
              OptionsImage.Glyph.Data = {
                424DC60700000000000036000000280000001600000016000000010020000000
                000000000000C40E0000C40E00000000000000000000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000000000FF000000FF000000FF000000FFC0C0C0000000
                00FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000000000FF000000FF0000
                00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
                00FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000000000FF000000FF000000FF000000FFC0C0C000000000FFC0C0C0000000
                00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
                C000C0C0C000C0C0C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000000000FFC0C0C000C0C0C000C0C0
                C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000000000FF000000FF000000FF000000FFC0C0C0000000
                00FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000000000FFC0C0C000C0C0C000C0C0C000C0C0C000000000FF000000FF0000
                00FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000000000FF000000FF000000FFC0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000000000FFC0C0C000000000FFC0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
                00FF000000FF000000FFC0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
                C000C0C0C000}
              TabOrder = 9
              OnClick = KodAgaciTusClick
            end
            object cxDBImageComboBox1: TcxDBImageComboBox
              Left = 555
              Top = 54
              RepositoryItem = Tablo.repGenelPersonelListesiHerkes
              Anchors = [akTop, akRight]
              DataBinding.DataField = 'ZIMMETLIPERSONELID'
              DataBinding.DataSource = DtsDemirbas
              Properties.Items = <>
              Properties.ReadOnly = True
              TabOrder = 10
              Visible = False
              Width = 151
            end
            object cxLabel4: TcxLabel
              Left = 478
              Top = 56
              Anchors = [akTop, akRight]
              Caption = 'Personel'
              Visible = False
            end
            object LabelHesapAciklama: TcxLabel
              Left = 336
              Top = 8
              Anchors = [akTop, akRight]
              Caption = '...'
            end
            object ComboDURUM: TcxDBImageComboBox
              Left = 555
              Top = 28
              Hint = 'Demirbas_Durum'
              RepositoryItem = Tablo.RepDemirbas_Durum
              Anchors = [akTop, akRight]
              DataBinding.DataField = 'DURUM'
              DataBinding.DataSource = DtsDemirbas
              Enabled = False
              Properties.Alignment.Horz = taLeftJustify
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 0
                  Value = 4
                end
                item
                  Description = 'Zimmet'
                  Value = 1
                end
                item
                  Description = 'Kay'#305'p'
                  Value = 2
                end
                item
                  Description = 'Hurda'
                  Value = 3
                end
                item
                  Description = 'Transfer'
                  Value = 5
                end
                item
                  Description = 'Bo'#351
                  Value = 9
                end
                item
                  Description = 'Serviste'
                  Value = 6
                end
                item
                  Description = 'Servis '#304'ade'
                  Value = 7
                end>
              StyleDisabled.Color = clWhite
              StyleDisabled.TextColor = clBlack
              TabOrder = 13
              Width = 151
            end
            object LabelDURUM: TcxLabel
              Left = 478
              Top = 30
              Anchors = [akTop, akRight]
              Caption = 'Durum'
            end
          end
        end
        object EkAlanlarEkr: TcxTabSheet
          Caption = 'Ek Alan'
          ImageIndex = 19
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
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
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnEnterPage = DokumanEkrEnterPage
      OnPage = DokumanEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel4: TPanel
        Left = 0
        Top = 502
        Width = 815
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
          Width = 667
        end
        object BtnMesajGonder: TcxButton
          Left = 668
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
          Left = 753
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
        Top = 482
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
        ExplicitTop = 481
        AnchorX = 815
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 815
        Height = 412
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
      OnPage = TarihceEkrPage
      object GridTarihce: TcxGrid
        Left = 0
        Top = 97
        Width = 815
        Height = 446
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.SkinName = 'MoneyTwins'
        object GridTarihceView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridTarihceViewCanFocusRecord
          DataController.DataSource = DtsDemirbasTarihce
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Editing = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.OnGetContentStyle = GridTarihceViewStylesGetContentStyle
          object GridTarihceViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 161
          end
          object GridTarihceViewTUTANAK: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'TUTANAK'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 97
          end
          object GridTarihceViewZIMMETALAN: TcxGridDBColumn
            Caption = 'Alan'
            DataBinding.FieldName = 'ZIMMETALAN'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 154
          end
          object GridTarihceViewZIMMETVEREN: TcxGridDBColumn
            Caption = 'Veren'
            DataBinding.FieldName = 'ZIMMETVEREN'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 138
          end
          object GridTarihceViewLOKASYON: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'LOKASYON'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Width = 195
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridTarihceView
        end
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 809
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 43
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
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 569
    Top = 74
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 493
    Top = 200
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
  object frxDemirbas: TfrxDBDataset
    UserName = 'Demirbas'
    CloseDataSource = False
    DataSet = TabDemirbasfrx
    BCDToCurrency = False
    DataSetOptions = []
    Left = 24
    Top = 520
  end
  object PopupMenuKopya: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 513
    Top = 101
    object MenuButunDemirbasKopyala: TMenuItem
      Caption = 'B'#252't'#252'n Demirbasi kopyala'
      ImageIndex = 10
    end
    object MenuSadeceDetay: TMenuItem
      Tag = 1
      Caption = 'Sadece detay sat'#305'rlar'#305' kopyala'
      ImageIndex = 10
    end
  end
  object tabDemirbasTarihce: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @DID int'
      'set @DID=:p1'
      ''
      
        'SELECT     DT.ID, DT.TARIH, DT.TIP, DI.ANAHTAR AS TUTANAK, DT.LO' +
        'KASYONID, L.ACIKLAMA AS LOKASYON, '
      
        '                      R1.FIRMA AS ZIMMETALAN, DT.ALANID, R2.FIRM' +
        'A AS ZIMMETVEREN, DT.VERENID, DTD.DEMIRBASID'
      'FROM         DEMIRBAS_TUTANAK_DETAY AS DTD LEFT OUTER JOIN'
      
        '                      DEMIRBAS_TUTANAK AS DT ON DT.ID = DTD.TUTA' +
        'NAKID '
      'LEFT OUTER JOIN  REHBER AS R1 ON DT.ALANID = R1.ID '
      'LEFT OUTER JOIN  REHBER AS R2 ON DT.VERENID = R2.ID '
      
        'LEFT OUTER JOIN   (SELECT     BOLUM, ANAHTAR, DEGER       FROM  ' +
        '       GENINI       WHERE      (BOLUM =-2801 and DIL=-1)) AS DI ' +
        'ON DI.DEGER = DT.TIP'
      'LEFT OUTER JOIN      LOKASYON as L on L.ID=DT.LOKASYONID'
      'Where DTD.DEMIRBASID=@DID'
      ''
      'order by 2 desc,3 desc ')
    Left = 58
    Top = 220
    ParamData = <
      item
        Name = 'p1'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsDemirbasTarihce: TDataSource
    DataSet = tabDemirbasTarihce
    Left = 48
    Top = 284
  end
  object frxDemirbasTarihce: TfrxDBDataset
    UserName = 'DemirbasTarihce'
    CloseDataSource = False
    DataSet = tabDemirbasTarihce
    BCDToCurrency = False
    DataSetOptions = []
    Left = 23
    Top = 324
    FieldDefs = <
      item
        FieldName = 'ID'
        FieldAlias = 'ID'
      end
      item
        FieldName = 'TARIH'
        FieldAlias = 'TARIH'
      end
      item
        FieldName = 'TIP'
        FieldAlias = 'TIP'
      end
      item
        FieldName = 'TUTANAK'
        FieldAlias = 'TUTANAK'
      end
      item
        FieldName = 'LOKASYONID'
        FieldAlias = 'LOKASYONID'
      end
      item
        FieldName = 'LOKASYON'
        FieldAlias = 'LOKASYON'
      end
      item
        FieldName = 'ZIMMETALAN'
        FieldAlias = 'ZIMMETALAN'
      end
      item
        FieldName = 'ALANID'
        FieldAlias = 'ALANID'
      end
      item
        FieldName = 'ZIMMETVEREN'
        FieldAlias = 'ZIMMETVEREN'
      end
      item
        FieldName = 'VERENID'
        FieldAlias = 'VERENID'
      end
      item
        FieldName = 'DEMIRBASID'
        FieldAlias = 'DEMIRBASID'
      end>
  end
  object TabDemirbasfrx: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT    D.*, S.STOKADI, L.ACIKLAMA  As LOKASYONADI, R.FIRMA AS' +
        ' PERSONEL,'
      
        'DURUMADI=(SELECT top 1    ANAHTAR  FROM  GENINI AS DD  WHERE BOL' +
        'UM =-2801 and D.DURUM = DD.DEGER),'
      ' DU.STOKADI AS KATEGORIADI, '
      
        ' MARKAADI = (SELECT  top 1    ANAHTAR FROM   GENINI AS SM  WHERE' +
        '  BOLUM =-2701 and D.MARKA = SM.DEGER) '
      ' ,R2.FIRMA as SUBEADI,'
      
        'MODELADI=(SELECT top 1 ANAHTAR FROM GENINI WHERE BOLUM=convert(i' +
        'nt,'#39'-2701'#39'+convert(varchar(10),D.MARKA)) AND DEGER=D.MODEL ) '
      'FROM DEMIRBAS AS D '
      'LEFT OUTER JOIN STOKLAR AS S ON D.STOKID = S.ID '
      'LEFT OUTER JOIN DEMIRBAS_URUN AS DU ON DU.ID=D.KATEGORIID  '
      'LEFT OUTER JOIN LOKASYON AS L ON L.ID=D.ZIMMETLOKASYONID '
      'LEFT OUTER JOIN REHBER AS R ON R.ID = D.ZIMMETLIPERSONELID'
      'LEFT OUTER JOIN REHBER AS R2 ON R.ID = D.SUBEID'
      'where D.ID=:Prm0'
      ''
      '')
    Left = 29
    Top = 369
    ParamData = <
      item
        Name = 'Prm0'
        Size = -1
        Value = Null
      end>
  end
  object TabDemirbas: TFDQuery
    AutoCalcFields = False
    AfterOpen = TabDemirbasAfterOpen
    BeforeEdit = TabDemirbasBeforeEdit
    BeforePost = TabDemirbasBeforePost
    AfterPost = TabDemirbasAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  *'
      'FROM         DEMIRBAS'
      'WHERE ID=:PID')
    Left = 25
    Top = 422
    ParamData = <
      item
        Name = 'PID'
        Size = -1
        Value = Null
      end>
  end
  object DtsDemirbas: TDataSource
    DataSet = TabDemirbas
    Left = 24
    Top = 474
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 430
    Top = 73
  end
  object TabAmortisman: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM AMORTISMAN_ORAN WHERE ID=:ID')
    Left = 352
    Top = 420
    ParamData = <
      item
        Name = 'ID'
        DataType = ftWideString
        Size = 2
        Value = Null
      end>
  end
  object DtsAmortisman: TDataSource
    DataSet = TabAmortisman
    Left = 346
    Top = 478
  end
  object dtsDemirbasMasraf: TDataSource
    DataSet = tabDemirbasMasraf
    Left = 176
    Top = 484
  end
  object tabDemirbasMasraf: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select ID, KOD, AD FROM MASRAFGELIR WHERE KOD in'
      
        '(select KOD=REVERSE(SUBSTRING(REVERSE(KOD),CHARINDEX('#39'.'#39',KOD)+1,' +
        '500))'
      'from MASRAFGELIR'
      'where YER=18 and YER_ID=:Prm1'
      ')'
      'order by 2 ')
    Left = 178
    Top = 436
    ParamData = <
      item
        Name = 'Prm1'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    object tabDemirbasMasrafID: TSmallintField
      FieldName = 'ID'
      ReadOnly = True
    end
    object tabDemirbasMasrafKOD: TWideStringField
      FieldName = 'KOD'
    end
    object tabDemirbasMasrafAD: TWideStringField
      FieldName = 'AD'
      Size = 200
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
    Left = 587
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 232
    Top = 352
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
    object N4: TMenuItem
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
    Left = 832
    Top = 368
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
    Left = 488
    Top = 292
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
