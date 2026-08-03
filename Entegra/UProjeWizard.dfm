object ProjeWizardDlg: TProjeWizardDlg
  Left = 0
  Top = 0
  ActiveControl = DateBASLAMATARIHI
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Proje Sihirbaz'#305
  ClientHeight = 485
  ClientWidth = 1004
  Color = clBtnFace
  DragMode = dmAutomatic
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 485
    Align = alLeft
    TabOrder = 0
    object btnProje: TcxButton
      Left = 0
      Top = 79
      Width = 84
      Height = 29
      Caption = 'Proje'
      TabOrder = 0
      OnClick = btnProjeClick
    end
    object btnDetay: TcxButton
      Tag = 2
      Left = 0
      Top = 143
      Width = 84
      Height = 29
      Caption = 'Detay'
      TabOrder = 2
      OnClick = btnProjeClick
    end
    object btnTarihce: TcxButton
      Tag = 4
      Left = 0
      Top = 316
      Width = 84
      Height = 29
      Caption = 'Tarih'#231'e'
      TabOrder = 4
      OnClick = btnProjeClick
    end
    object btnAsama: TcxButton
      Tag = 1
      Left = 0
      Top = 111
      Width = 84
      Height = 29
      Caption = 'A'#351'ama'
      TabOrder = 1
      OnClick = btnProjeClick
    end
    object MaliyetTus: TcxButton
      Tag = 3
      Left = 0
      Top = 286
      Width = 84
      Height = 29
      Caption = 'B'#252't'#231'e/Maliyet'
      TabOrder = 3
      OnClick = btnProjeClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 918
    Height = 485
    ActivePage = ProjeEkr
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
      918
      485)
    object ProjeEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Proje Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      EnabledButtons = [bkBack, bkNext, bkFinish, bkCancel]
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      OnNextButtonClick = ProjeEkrNextButtonClick
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxDBLabel2: TcxDBLabel
        Left = 141
        Top = 6
        DataBinding.DataField = 'REHBERID'
        DataBinding.DataSource = DtsProjeler
        Transparent = True
        Visible = False
        Height = 19
        Width = 36
      end
      object LabelKod: TcxLabel
        Left = 215
        Top = 3
        Cursor = crHandPoint
        Hint = 'Buray'#305' t'#305'klayarak firma de'#287'i'#351'tirin'
        Caption = 'Kodu'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
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
        Left = 353
        Top = 2
        Cursor = crHandPoint
        Hint = 'Buray'#305' t'#305'klayarak firma bilgilerini g'#246'r'#252'n'
        Caption = 'Ad'#305
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -19
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelAdClick
      end
      object lblMusteriAdres: TcxLabel
        Left = 216
        Top = 33
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
        Width = 389
      end
      object lblMusteriTel: TcxLabel
        Left = 611
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
        Left = 612
        Top = 48
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
      object Panel2: TPanel
        Left = 0
        Top = 70
        Width = 918
        Height = 373
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 6
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 918
          Height = 167
          Align = alTop
          Color = clSkyBlue
          ParentBackground = False
          TabOrder = 0
          object ComboPRJ_TURU: TcxDBImageComboBox
            Left = 107
            Top = 84
            RepositoryItem = Tablo.repProjeTuru
            DataBinding.DataField = 'TURU'
            DataBinding.DataSource = DtsProjeler
            Properties.Items = <>
            Properties.OnEditValueChanged = ComboPRJ_TURUPropertiesEditValueChanged
            TabOrder = 3
            Width = 121
          end
          object DateBASLAMATARIHI: TcxDBDateEdit
            Left = 107
            Top = 58
            DataBinding.DataField = 'BASLAMATARIHI'
            DataBinding.DataSource = DtsProjeler
            Properties.ImmediatePost = True
            Properties.SaveTime = False
            Properties.ShowTime = False
            Properties.OnCloseUp = cxDBDateEdit1PropertiesCloseUp
            TabOrder = 0
            Width = 121
          end
          object ComboPRJ_KONUSU: TcxDBComboBox
            Left = 105
            Top = 32
            RepositoryItem = Tablo.repProjeKonu
            DataBinding.DataField = 'KONUSU'
            DataBinding.DataSource = DtsProjeler
            TabOrder = 6
            Width = 315
          end
          object ComboPRJ_ASAMA: TcxDBImageComboBox
            Left = 511
            Top = 60
            RepositoryItem = Tablo.repProjeAsama
            DataBinding.DataField = 'ASAMA'
            DataBinding.DataSource = DtsProjeler
            Properties.Items = <>
            TabOrder = 1
            Width = 121
          end
          object DateBITISTARIHI: TcxDBDateEdit
            Left = 300
            Top = 57
            DataBinding.DataField = 'BITISTARIHI'
            DataBinding.DataSource = DtsProjeler
            Properties.ImmediatePost = True
            Properties.SaveTime = False
            Properties.ShowTime = False
            TabOrder = 2
            Width = 121
          end
          object cxLabel11: TcxLabel
            Left = 5
            Top = 60
            Caption = 'Ba'#351'lama Tarihi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel20: TcxLabel
            Left = 231
            Top = 59
            Caption = 'Biti'#351' Tarihi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel22: TcxLabel
            Left = 5
            Top = 35
            Cursor = crHandPoint
            Hint = 'Proje_Konusu'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.KONUSU'
            Caption = 'Konusu'
            FocusControl = ComboPRJ_KONUSU
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelTURUClick
          end
          object cxLabel26: TcxLabel
            Tag = -2133
            Left = 438
            Top = 62
            Cursor = crHandPoint
            Hint = 'Proje_A'#351'ama'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.ASAMA'
            Caption = 'A'#351'ama*'
            FocusControl = ComboPRJ_ASAMA
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelTURUClick
          end
          object LabelTURU: TcxLabel
            Tag = -2132
            Left = 7
            Top = 86
            Cursor = crHandPoint
            Hint = 'Proje_T'#252'r'#252
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.TURU'
            Caption = 'T'#252'r'#252
            FocusControl = ComboPRJ_TURU
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelTURUClick
          end
          object cxLabel23: TcxLabel
            Left = 438
            Top = 87
            Caption = 'B'#252't'#231'esi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object CurrencySATISFIYATI: TcxDBCurrencyEdit
            Left = 512
            Top = 86
            DataBinding.DataField = 'SATISFIYATI'
            DataBinding.DataSource = DtsProjeler
            Properties.DisplayFormat = ',0.00;(,0.00)'
            TabOrder = 8
            Width = 79
          end
          object ComboSATISKUR: TcxDBComboBox
            Left = 590
            Top = 86
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            DataBinding.DataField = 'SATISKUR'
            DataBinding.DataSource = DtsProjeler
            Properties.DropDownListStyle = lsFixedList
            TabOrder = 9
            Width = 44
          end
          object ComboIlgili: TcxButtonEdit
            Left = 107
            Top = 110
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
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = ComboIlgiliPropertiesButtonClick
            ShowHint = True
            TabOrder = 7
            TextHint = 'ILGILI'
            Width = 122
          end
          object cxDBLabel8: TcxDBLabel
            Left = 80
            Top = 114
            DataBinding.DataField = 'ILGILI'
            DataBinding.DataSource = DtsProjeler
            ParentFont = False
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            Visible = False
            Height = 21
            Width = 56
          end
          object cxLabel1: TcxLabel
            Left = 4
            Top = 136
            Cursor = crHandPoint
            Caption = 'Proje Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditProjeKodu: TcxDBButtonEdit
            Left = 690
            Top = 11
            DataBinding.DataField = 'PROJEKODU'
            DataBinding.DataSource = DtsProjeler
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
            Properties.MaxLength = 0
            ShowHint = True
            TabOrder = 5
            Visible = False
            Width = 315
          end
          object lbProjeTipi: TcxLabel
            Left = 232
            Top = 85
            Cursor = crHandPoint
            Hint = 'Proje_Tipi'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.TIPI'
            Caption = 'Tipi'
            FocusControl = comboPRJ_TIPI
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = lbProjeTipiClick
          end
          object comboPRJ_TIPI: TcxDBImageComboBox
            Left = 300
            Top = 83
            DataBinding.DataField = 'TIPI'
            DataBinding.DataSource = DtsProjeler
            Properties.Alignment.Horz = taLeftJustify
            Properties.Items = <>
            Properties.OnCloseUp = comboPRJ_TIPIPropertiesCloseUp
            TabOrder = 4
            Width = 121
          end
          object cxLabel9: TcxLabel
            Left = 3
            Top = 8
            Cursor = crHandPoint
            Caption = 'Proje Ad'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object LabelIlgili: TcxLabel
            Left = 5
            Top = 111
            Cursor = crHandPoint
            Caption = 'M'#252#351'teri '#304'lgili*'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Properties.WordWrap = True
            Transparent = True
            Width = 69
          end
          object cxLabel10: TcxLabel
            Left = 232
            Top = 113
            Caption = 'Sorumlu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object ComboSube: TcxDBImageComboBox
            Left = 511
            Top = 34
            DataBinding.DataField = 'SUBEID'
            DataBinding.DataSource = DtsProjeler
            Properties.ImmediatePost = True
            Properties.Items = <>
            TabOrder = 10
            Width = 121
          end
          object LblSube: TcxLabel
            Left = 439
            Top = 36
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
          object LabelCari: TcxLabel
            Left = 829
            Top = 59
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
            Width = 130
          end
          object EditProjeAdi: TcxDBTextEdit
            Left = 105
            Top = 6
            DataBinding.DataField = 'PROJEADI'
            DataBinding.DataSource = DtsProjeler
            ParentShowHint = False
            Properties.MaxLength = 0
            ShowHint = True
            TabOrder = 25
            Width = 315
          end
          object EditSORUMLU: TcxButtonEdit
            Left = 300
            Top = 109
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ClearKey = 46
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = EditTEMSILCIPropertiesButtonClick
            ShowHint = True
            Style.LookAndFeel.NativeStyle = False
            StyleDisabled.LookAndFeel.NativeStyle = False
            StyleFocused.LookAndFeel.NativeStyle = False
            StyleHot.LookAndFeel.NativeStyle = False
            StyleReadOnly.LookAndFeel.NativeStyle = False
            TabOrder = 26
            Width = 121
          end
          object CheckTamam: TcxDBCheckBox
            Left = 509
            Top = 5
            Caption = 'Kapand'#305
            DataBinding.DataField = 'DURUM'
            DataBinding.DataSource = DtsProjeler
            ParentFont = False
            Properties.DisplayChecked = '2'
            Properties.DisplayUnchecked = '1'
            Properties.ValueChecked = '2'
            Properties.ValueUnchecked = '1'
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -16
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.TextColor = clRed
            Style.TextStyle = [fsBold]
            Style.IsFontAssigned = True
            TabOrder = 27
            Transparent = True
          end
          object LabelPROJEKODU: TcxDBTextEdit
            Left = 106
            Top = 136
            DataBinding.DataField = 'PROJEKODU'
            DataBinding.DataSource = DtsProjeler
            ParentFont = False
            Style.Color = clSkyBlue
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 28
            Width = 315
          end
        end
        object CariPageControl: TcxPageControl
          Left = 0
          Top = 167
          Width = 918
          Height = 206
          Align = alClient
          TabOrder = 1
          Properties.ActivePage = cxTabSheet1
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 202
          ClientRectLeft = 4
          ClientRectRight = 914
          ClientRectTop = 27
          object cxTabSheet1: TcxTabSheet
            Caption = 'Yorum/Medya'
            ImageIndex = 0
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object Panel4: TPanel
              Left = 0
              Top = 114
              Width = 910
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
                Width = 762
              end
              object BtnMesajGonder: TcxButton
                Left = 763
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
                Left = 848
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
              Top = 155
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
              ExplicitTop = 154
              AnchorX = 910
            end
            object GridYorum: TcxGrid
              Left = 0
              Top = 0
              Width = 910
              Height = 114
              Align = alClient
              TabOrder = 2
              object GridYorumDBCardView1: TcxGridDBCardView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
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
        end
      end
      object cxLabel13: TcxLabel
        Left = 5
        Top = 46
        Caption = 'ID'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxDBLabel1: TcxDBLabel
        Left = 26
        Top = 47
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsProjeler
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 17
        Width = 31
      end
    end
    object ProjeAsamaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Proje A'#351'amalar'#305
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
      Caption = 'ProjeAsamaEkr'
      OnExitPage = ProjeAsamaEkrExitPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar5: TToolBar
        Left = 0
        Top = 70
        Width = 918
        Height = 24
        Margins.Bottom = 0
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
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object BtnAsamaEkle: TToolButton
          Left = 0
          Top = 0
          Caption = 'Ekle'
          ImageIndex = 0
          ImageName = 'PngImage0'
          Style = tbsTextButton
          Visible = False
          OnClick = BtnAsamaEkleClick
        end
        object BtnAsamaSil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          Style = tbsTextButton
          Visible = False
          OnClick = BtnAsamaSilClick
        end
        object BtnAsamaKaydet: TToolButton
          Left = 124
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = BtnAsamaKaydetClick
        end
        object BtnAsamaIptal: TToolButton
          Left = 186
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = BtnAsamaIptalClick
        end
      end
      object cxGridProjeAsama: TcxGrid
        Left = 0
        Top = 94
        Width = 918
        Height = 349
        Align = alClient
        PopupMenu = PmSagClick
        TabOrder = 1
        object cxGridProjeAsamaDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = cxGridProjeAsamaDBTableView1CanFocusRecord
          DataController.DataSource = DtsProjeAsama
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.GroupByBox = False
          object cxGridProjeAsamaDBTableView1ASAMA: TcxGridDBColumn
            Caption = 'A'#351'ama'
            DataBinding.FieldName = 'ASAMA'
            RepositoryItem = Tablo.repProjeAsama
            Width = 76
          end
          object cxGridProjeAsamaDBTableView1ASAMASORUMLUSU: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'ASAMASORUMLUSU'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = cxGridProjeAsamaDBTableView1ASAMASORUMLUSUPropertiesButtonClick
            Width = 120
          end
          object cxGridProjeAsamaDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Width = 264
          end
          object cxGridProjeAsamaDBTableView1BASTAR: TcxGridDBColumn
            Caption = 'Ba'#351'lama'
            DataBinding.FieldName = 'BASTAR'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.DateButtons = [btnClear, btnNow, btnToday]
            Width = 126
          end
          object cxGridProjeAsamaDBTableView1BITTAR: TcxGridDBColumn
            Caption = 'Biti'#351
            DataBinding.FieldName = 'BITTAR'
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.DateButtons = [btnClear, btnNow, btnToday]
            Properties.Kind = ckDateTime
            Properties.OnCloseUp = cxGridProjeAsamaDBTableView1BITTARPropertiesCloseUp
            Width = 110
          end
          object cxGridProjeAsamaDBTableView1SURE: TcxGridDBColumn
            Caption = 'S'#252're'
            DataBinding.FieldName = 'SURE'
            PropertiesClassName = 'TcxTextEditProperties'
          end
          object cxGridProjeAsamaDBTableView1ONAY: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'AKTIF'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 34
          end
        end
        object cxGridProjeAsamaLevel1: TcxGridLevel
          GridView = cxGridProjeAsamaDBTableView1
        end
      end
    end
    object ProjeEkDetayEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Di'#287'er Ek Detaylar'
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
      Caption = 'Ek Detay Bilgiler'
      OnPage = ProjeEkDetayEkrPage
      OnExitPage = ProjeEkDetayEkrExitPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 912
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
      object GridProjeDetay: TcxGrid
        Left = 0
        Top = 97
        Width = 918
        Height = 346
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
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
            Styles.Content = Tablo.cxStyle1
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
      object SQLDetay: TcxMemo
        Left = 196
        Top = 129
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
          'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU  '
          'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
          'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
          'where RB.YERI= @yeri and YER_ID= @yerid '
          'and isnull(RA.BOLUM,'#39#39')=@bolum '
          ''
          'union all'
          ''
          
            'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
            '  '
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
        Height = 344
        Width = 387
      end
      object ComboBolum: TcxDBComboBox
        Left = 83
        Top = 37
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsProjeler
        Properties.ImmediatePost = True
        Properties.MaxLength = 0
        Properties.OnEditValueChanged = ComboBolumPropertiesEditValueChanged
        Properties.OnInitPopup = ComboBolumPropertiesInitPopup
        TabOrder = 0
        Width = 153
      end
      object LabelSablon: TcxLabel
        Left = 6
        Top = 38
        Cursor = crHandPoint
        Caption = #350'ablon Se'#231'iniz.'
        Style.TextColor = clMaroon
        Transparent = True
        OnClick = LabelSablonClick
      end
    end
    object MaliyetEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'B'#252't'#231'e / Maliyet'
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
      Caption = 'MaliyetEkr'
      OnEnterPage = MaliyetEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxPageControl1: TcxPageControl
        Left = 0
        Top = 70
        Width = 918
        Height = 373
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = TabSheetButce
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 369
        ClientRectLeft = 4
        ClientRectRight = 914
        ClientRectTop = 27
        object TabSheetButce: TcxTabSheet
          Caption = '   B'#252't'#231'e   '
          ImageIndex = 0
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object TreeProjeButce: TcxDBTreeList
            Left = 0
            Top = 24
            Width = 910
            Height = 318
            Align = alClient
            Bands = <
              item
                Caption.Text = 'Hesap Plan'#305
              end>
            DataController.DataSource = DtsProjeButce
            DataController.ParentField = 'ROOTKOD'
            DataController.KeyField = 'KOD'
            DefaultRowHeight = 20
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            LookAndFeel.SkinName = 'LondonLiquidSky'
            Navigator.Buttons.CustomButtons = <>
            OptionsBehavior.AlwaysShowEditor = True
            OptionsBehavior.IncSearch = True
            OptionsData.Appending = True
            OptionsData.Inserting = True
            OptionsData.CheckHasChildren = False
            OptionsData.SmartRefresh = True
            OptionsView.Footer = True
            OptionsView.GroupFooters = tlgfVisibleWhenExpanded
            PopupMenu = PMButce
            RootValue = -1
            ScrollbarAnnotations.CustomAnnotations = <>
            TabOrder = 0
            OnCanFocusNode = TreeProjeButceCanFocusNode
            object TreeListID: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'ID'
              Options.Editing = False
              Width = 100
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListKOD: TcxDBTreeListColumn
              Caption.Text = 'Kod'
              DataBinding.FieldName = 'KOD'
              Options.Editing = False
              Width = 101
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListKOD2: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'KOD'
              Options.Editing = False
              Width = 100
              Position.ColIndex = 3
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListAD: TcxDBTreeListColumn
              Caption.Text = 'Ad'
              DataBinding.FieldName = 'AD'
              Options.Editing = False
              Width = 184
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeBIRIMI: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.repStokAnaBirim
              Caption.Text = 'Birimi'
              DataBinding.FieldName = 'BIRIMI'
              Width = 60
              Position.ColIndex = 4
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeMIKTAR: TcxDBTreeListColumn
              Caption.Text = 'Miktar'
              DataBinding.FieldName = 'MIKTAR'
              Width = 68
              Position.ColIndex = 5
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeBIRIMFIYAT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00 ;-,0.00 '
              Caption.Text = 'Birim Fiyat'
              DataBinding.FieldName = 'BIRIMFIYAT'
              Width = 91
              Position.ColIndex = 6
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeTUTAR: TcxDBTreeListColumn
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00 ;-,0.00'
              Caption.Text = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              Options.Editing = False
              Width = 87
              Position.ColIndex = 7
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <
                item
                  AlignHorz = taRightJustify
                  Format = ',0.00 ;-,0.00 '
                  Kind = skSum
                  AlignHorzAssigned = True
                end>
              Summary.GroupFooterSummaryItems = <
                item
                  AlignHorz = taRightJustify
                  Format = ',0.00 ;-,0.00 '
                  Kind = skSum
                  AlignHorzAssigned = True
                end>
            end
            object TreeKUR: TcxDBTreeListColumn
              PropertiesClassName = 'TcxComboBoxProperties'
              RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              Caption.Text = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              Width = 49
              Position.ColIndex = 8
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeGERCEKTAH: TcxDBTreeListColumn
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00 ;-,0.00'
              Caption.Text = 'Ger'#231'ekle'#351'en Tahakkuk'
              DataBinding.FieldName = 'GERCEKTAH'
              Width = 100
              Position.ColIndex = 9
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <
                item
                  AlignHorz = taRightJustify
                  Format = ',0.00 ;-,0.00'
                  Kind = skSum
                  AlignHorzAssigned = True
                end>
              Summary.GroupFooterSummaryItems = <
                item
                  AlignHorz = taRightJustify
                  Format = ',0.00 ;-,0.00'
                  Kind = skSum
                  AlignHorzAssigned = True
                end>
            end
            object TreeGERCEKODE: TcxDBTreeListColumn
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00 ;-,0.00'
              Caption.Text = 'Ger'#231'ekle'#351'en '#214'deme'
              DataBinding.FieldName = 'GERCEKODE'
              Width = 100
              Position.ColIndex = 10
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <
                item
                  AlignHorz = taRightJustify
                  Format = ',0.00 ;-,0.00'
                  Kind = skSum
                  AlignHorzAssigned = True
                end>
              Summary.GroupFooterSummaryItems = <
                item
                  AlignHorz = taRightJustify
                  Format = ',0.00 ;-,0.00'
                  Kind = skSum
                  AlignHorzAssigned = True
                end>
            end
            object TreeFARK: TcxDBTreeListColumn
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;-,0.00'
              Caption.Text = 'Fark'
              DataBinding.FieldName = 'FARK'
              Width = 67
              Position.ColIndex = 11
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
          object ToolBar7: TToolBar
            Left = 0
            Top = 0
            Width = 910
            Height = 24
            Margins.Bottom = 0
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
            ShowCaptions = True
            TabOrder = 1
            Transparent = True
            object BtnButceEkle: TToolButton
              Left = 0
              Top = 0
              Caption = 'Ekle'
              ImageIndex = 0
              ImageName = 'PngImage0'
              Style = tbsTextButton
              OnClick = BtnButceEkleClick
            end
            object BtnButceSil: TToolButton
              Left = 62
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              Style = tbsTextButton
              OnClick = BtnButceSilClick
            end
            object BtnButceKaydet: TToolButton
              Left = 124
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = BtnButceKaydetClick
            end
            object BtnButceIptal: TToolButton
              Left = 186
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = BtnButceIptalClick
            end
            object YaziciYaz: TToolButton
              Left = 248
              Top = 0
              Caption = 'Yazdir'
              DropdownMenu = PopupMenuYaz
              ImageIndex = 8
              ImageName = 'PngImage15'
            end
          end
          object MemoProjeButceEFlow: TMemo
            Left = 40
            Top = 158
            Width = 529
            Height = 89
            Lines.Strings = (
              ''
              'select '
              
                '       ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '#39','#39#39'),CH' +
                'ARINDEX('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39'))-(CHARINDE' +
                'X('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
              
                '       MG.KOD,PB.ID, PROJEID,MASRAFID, MG.AD,PB.MIKTAR,PB.BIRIMI' +
                ',PB.BIRIMFIYAT, PB.TUTAR,PB.KUR,'
              
                '       GERCEKTAH=(select YERELTUTAR = sum(case when FA.KUR = '#39'TL' +
                #39' AND F.TUR IN (8,11,12) then (FA.TUTAR*(FA.KDV+100)/100)  '
              
                #9#9#9#9#9#9' when FA.DOVIZ_KURU ='#39'TL'#39' AND F.TUR IN (8,11,12) then (FA.' +
                'DOVIZ_TUTARI*(FA.KDV+100)/100)'
              '                          else 0.0 end)'
              #9#9#9#9#9'from FATBASLIK F inner join FATURA FA on F.ID=FA.FATBASID'
              #9#9#9#9#9'where MG.ID=FA.MASRAFID and FA.PROJEID=PB.PROJEID),'
              '       GERCEKODE=('#9'select sum(YERELTUTAR)'
              #9#9#9#9#9'from ('
              
                #9#9#9#9#9#9'select YERELTUTAR = (case when FA.KUR = '#39'TL'#39' AND F.TUR IN ' +
                '(8,11,12) then (FA.TUTAR*(FA.KDV+100)/100)  '
              
                #9#9#9#9#9#9#9#9#9#9#9#9' when FA.DOVIZ_KURU ='#39'TL'#39' AND F.TUR IN (8,11,12) the' +
                'n (FA.DOVIZ_TUTARI*(FA.KDV+100)/100)'
              #9#9#9#9#9#9#9#9#9#9#9#9' else 0.0 end)*(sum(B.TUTAR)/F.FATURA_TUTARI)'
              
                #9#9#9#9#9#9'from FATBASLIK F inner join FATURA FA on F.ID=FA.FATBASID ' +
                'inner join'
              #9#9#9#9#9#9'BORCKAPATMA B on B.ALACAKTUR=F.TUR and B.ALACAKID=F.ID'
              #9#9#9#9#9#9'where MG.ID=FA.MASRAFID and FA.PROJEID=PB.PROJEID'
              
                #9#9#9#9#9#9'group by FA.ID,F.ID, FA.KUR,FA.DOVIZ_KURU,F.TUR,FA.TUTAR,F' +
                'A.DOVIZ_TUTARI,FA.KDV,F.FATURA_TUTARI'
              #9#9#9#9#9#9')as ZXC'
              #9#9#9#9#9')'
              
                'from PROJEBUTCE PB inner join MASRAFGELIR MG on MG.ID = PB.MASRA' +
                'FID '
              ''
              'Where PB.PROJEID=:prm')
            TabOrder = 2
            Visible = False
            WordWrap = False
          end
          object MemoProjeButce: TMemo
            Left = 160
            Top = 114
            Width = 505
            Height = 89
            Lines.Strings = (
              'select '
              
                '       ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '#39','#39#39'),CH' +
                'ARINDEX('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39'))-(CHARINDE' +
                'X('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
              
                '       MG.KOD,PB.ID, PROJEID,MASRAFID, MG.AD,PB.MIKTAR,PB.BIRIMI' +
                ',PB.BIRIMFIYAT, PB.TUTAR,PB.KUR,'
              
                '       GERCEKTAH=(select top 1 YERELBAKIYE from [dbo].[fn_Proje_' +
                'Ekstre](PB.PROJEID,'#39'2000-01-01 00:00'#39', getdate(), 1,MG.ID,'#39#39') Ex' +
                ' order by Ex.TARIH desc),'
              
                '       GERCEKODE=(select top 1 YERELBAKIYE from [dbo].[fn_Proje_' +
                'Ekstre](PB.PROJEID,'#39'2000-01-01 00:00'#39', getdate(), 2,MG.ID,'#39#39') Ex' +
                ' order by Ex.TARIH desc)'
              
                'from PROJEBUTCE PB inner join MASRAFGELIR MG on MG.ID = PB.MASRA' +
                'FID '
              'Where PB.PROJEID=:prm')
            TabOrder = 3
            Visible = False
            WordWrap = False
          end
        end
        object TabSheetMaliyet: TcxTabSheet
          Caption = '  Maliyet  '
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object ToolBar6: TToolBar
            Left = 0
            Top = 0
            Width = 910
            Height = 24
            Margins.Bottom = 0
            ButtonWidth = 47
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
          end
          object MaliyetGrid: TcxGrid
            Left = 0
            Top = 24
            Width = 910
            Height = 318
            Align = alClient
            PopupMenu = PmSagClick
            TabOrder = 1
            object MaliyetGridView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = MaliyetGridViewCanFocusRecord
              DataController.DataSource = DtsMaliyet
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <
                item
                  Kind = skSum
                  Column = MaliyetGridViewTutar
                end
                item
                  Kind = skSum
                  Column = MaliyetGridViewKDV
                end
                item
                  Kind = skSum
                  Column = MaliyetGridViewToplam
                end
                item
                  Kind = skCount
                  Column = MaliyetGridViewBelgeTipi
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsView.Footer = True
              OptionsView.GroupByBox = False
              object MaliyetGridViewKAYNAK: TcxGridDBColumn
                Caption = 'Kaynak'
                DataBinding.FieldName = 'KAYNAK'
                DataBinding.IsNullValueType = True
              end
              object MaliyetGridViewBelgeTipi: TcxGridDBColumn
                DataBinding.FieldName = 'BelgeTipi'
                DataBinding.IsNullValueType = True
              end
              object MaliyetGridViewSatici: TcxGridDBColumn
                Caption = 'Sat'#305'c'#305
                DataBinding.FieldName = 'Satici'
                DataBinding.IsNullValueType = True
                Width = 133
              end
              object MaliyetGridViewBelgeTarihi: TcxGridDBColumn
                DataBinding.FieldName = 'BelgeTarihi'
                DataBinding.IsNullValueType = True
              end
              object MaliyetGridViewBelgeNo: TcxGridDBColumn
                DataBinding.FieldName = 'BelgeNo'
                DataBinding.IsNullValueType = True
                Width = 129
              end
              object MaliyetGridViewAciklama: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'Aciklama'
                DataBinding.IsNullValueType = True
                Width = 120
              end
              object MaliyetGridViewTutar: TcxGridDBColumn
                DataBinding.FieldName = 'Tutar'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
              end
              object MaliyetGridViewKDV: TcxGridDBColumn
                DataBinding.FieldName = 'KDV'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
              end
              object MaliyetGridViewToplam: TcxGridDBColumn
                DataBinding.FieldName = 'Toplam'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
              end
              object MaliyetGridViewKUR: TcxGridDBColumn
                Caption = 'P.Birimi'
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
              end
              object MaliyetGridViewPersonel: TcxGridDBColumn
                DataBinding.FieldName = 'Personel'
                DataBinding.IsNullValueType = True
              end
            end
            object cxGridLevel2: TcxGridLevel
              GridView = MaliyetGridView
            end
          end
        end
        object TabSheetEkstre: TcxTabSheet
          Caption = 'Ekstre'
          ImageIndex = 2
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 910
            Height = 30
            Align = alTop
            Caption = 'Panel4'
            TabOrder = 0
            object ToolBar11: TToolBar
              Left = 1
              Top = 1
              Width = 96
              Height = 28
              Margins.Bottom = 0
              Align = alLeft
              ButtonHeight = 30
              ButtonWidth = 79
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
              Images = Tablo.PNGImageList1
              List = True
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
            end
            object JvNavPanelHeader1: TJvNavPanelHeader
              Left = 97
              Top = 1
              Width = 812
              Height = 28
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
              object cxLabel6: TcxLabel
                Left = 3
                Top = 3
                Caption = 'Ba'#351'lama'
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object CalendarEkstreBas: TcxDateEdit
                Left = 58
                Top = 2
                ParentFont = False
                Properties.OnChange = CalendarEkstreBasPropertiesChange
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -16
                Style.Font.Name = 'Arial'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
                TabOrder = 1
                Width = 121
              end
              object CalendarEkstreBit: TcxDateEdit
                Left = 219
                Top = 2
                ParentFont = False
                Properties.OnChange = CalendarEkstreBasPropertiesChange
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -16
                Style.Font.Name = 'Arial'
                Style.Font.Style = [fsBold]
                Style.IsFontAssigned = True
                TabOrder = 2
                Width = 121
              end
              object cxLabel14: TcxLabel
                Left = 185
                Top = 5
                Caption = 'Biti'#351'   '
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cxRadioButton1: TcxRadioButton
                Tag = 1
                Left = 376
                Top = 5
                Width = 81
                Height = 17
                Caption = 'Tahakkuk'
                Checked = True
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -13
                Font.Name = 'Trebuchet MS'
                Font.Style = []
                ParentFont = False
                TabOrder = 4
                TabStop = True
                OnClick = CalendarEkstreBasPropertiesChange
              end
              object cxRadioButton2: TcxRadioButton
                Tag = 2
                Left = 463
                Top = 5
                Width = 82
                Height = 17
                Caption = #214'deme'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -13
                Font.Name = 'Trebuchet MS'
                Font.Style = []
                ParentFont = False
                TabOrder = 5
                OnClick = CalendarEkstreBasPropertiesChange
              end
              object cxRadioButton3: TcxRadioButton
                Tag = 3
                Left = 551
                Top = 5
                Width = 82
                Height = 17
                Caption = 'T'#252'm'#252
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -13
                Font.Name = 'Trebuchet MS'
                Font.Style = []
                ParentFont = False
                TabOrder = 6
                OnClick = CalendarEkstreBasPropertiesChange
              end
            end
          end
          object GridMasrafEkstre: TcxGrid
            Left = 0
            Top = 30
            Width = 910
            Height = 312
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
            object GridMasrafEkstreView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsCariListe
              DataController.Options = [dcoGroupsAlwaysExpanded]
              DataController.Summary.DefaultGroupSummaryItems = <
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Position = spFooter
                  Column = GridMasrafEkstreViewBORC
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Position = spFooter
                  Column = GridMasrafEkstreViewALACAK
                end>
              DataController.Summary.FooterSummaryItems = <
                item
                  Format = ',0.00;(,0.00)'
                  Column = GridMasrafEkstreViewBORCBAKIYE
                end
                item
                  Format = ',0.00;(,0.00)'
                  Column = GridMasrafEkstreViewALACAKBAKIYE
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
              OptionsView.Footer = True
              OptionsView.GroupFooters = gfAlwaysVisible
              OptionsView.Indicator = True
              object GridMasrafEkstreViewTARIH: TcxGridDBColumn
                Caption = 'Kay'#305't'
                DataBinding.FieldName = 'TARIH'
                DataBinding.IsNullValueType = True
                Width = 68
              end
              object GridMasrafEkstreViewAKSIYONTARIH: TcxGridDBColumn
                Caption = 'Aksiyon/Vade'
                DataBinding.FieldName = 'AKSIYONTARIH'
                DataBinding.IsNullValueType = True
                Width = 79
              end
              object GridMasrafEkstreViewNO: TcxGridDBColumn
                Caption = 'No'
                DataBinding.FieldName = 'NO'
                DataBinding.IsNullValueType = True
                Width = 75
              end
              object GridMasrafEkstreViewTUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'A'#231#305'l'#305#351' Fi'#351'i'
                    ImageIndex = 0
                    Value = 1
                  end
                  item
                    Description = 'Devir'
                    Value = 2
                  end
                  item
                    Description = 'Al'#305#351' Faturas'#305
                    ImageIndex = 0
                    Value = 11
                  end
                  item
                    Description = 'Al'#305#351' Fi'#351'i'
                    Value = 12
                  end
                  item
                    Description = 'Sat'#305#351' Faturas'#305
                    Value = 15
                  end
                  item
                    Description = 'Sat'#305#351' Fi'#351'i'
                    Value = 16
                  end
                  item
                    Description = 'Kasa Tahsilat'
                    Value = 21
                  end
                  item
                    Description = 'Banka Tahsilat'
                    Value = 22
                  end
                  item
                    Description = #199'ekle Tahsilat'
                    Value = 23
                  end
                  item
                    Description = 'Senetle Tahsilat'
                    Value = 24
                  end
                  item
                    Description = 'Kredi Kart'#305'yla Tahsilat'
                    Value = 25
                  end
                  item
                    Description = 'Kasa '#214'deme'
                    Value = 31
                  end
                  item
                    Description = 'Banka '#214'deme'
                    Value = 32
                  end
                  item
                    Description = #199'ekle '#214'deme'
                    Value = 33
                  end
                  item
                    Description = 'Senetle '#214'deme'
                    Value = 34
                  end
                  item
                    Description = 'Kredi Kart'#305'yla '#214'deme'
                    Value = 35
                  end
                  item
                    Description = 'Bankaya Yatan'
                    Value = 41
                  end
                  item
                    Description = 'Bankadan '#199'ekilen'
                    Value = 42
                  end
                  item
                    Description = 'Virman'
                    Value = 43
                  end
                  item
                    Description = 'D'#246'viz Al'#305#351
                    Value = 45
                  end
                  item
                    Description = 'D'#246'viz Sat'#305#351
                    Value = 46
                  end
                  item
                    Description = 'D'#246'viz Al'#305#351
                    Value = 47
                  end
                  item
                    Description = 'D'#246'viz Sat'#305#351
                    Value = 48
                  end
                  item
                    Description = #199'ek Bozduruldu'
                    Value = 51
                  end
                  item
                    Description = 'Senet Bozduruldu'
                    Value = 52
                  end
                  item
                    Description = #199'ek Bozduruldu'
                    Value = 53
                  end
                  item
                    Description = 'Senet Bozduruldu'
                    Value = 54
                  end
                  item
                    Description = 'Tahsilat Plan'#305
                    Value = 61
                  end
                  item
                    Description = 'D'#252'zenli Gelir'
                    Value = 62
                  end
                  item
                    Description = 'Avans Tahsilat Plan'#305
                    Value = 63
                  end
                  item
                    Description = #214'deme Plan'#305
                    Value = 71
                  end
                  item
                    Description = 'D'#252'zenli '#214'deme'
                    Value = 72
                  end
                  item
                    Description = 'Kredi '#214'deme'
                    Value = 75
                  end
                  item
                    Description = 'Tahakkuk'
                    Value = 81
                  end
                  item
                    Description = 'POS Giri'#351'i'
                    Value = 121
                  end
                  item
                    Description = 'Nakit Giri'#351'i'
                    Value = 122
                  end>
                RepositoryItem = Tablo.RepKasaTurleri
              end
              object GridMasrafEkstreViewKOD: TcxGridDBColumn
                Caption = 'Kod'
                DataBinding.FieldName = 'KOD'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 77
              end
              object GridMasrafEkstreViewAD: TcxGridDBColumn
                Caption = #220'nvan'
                DataBinding.FieldName = 'AD'
                DataBinding.IsNullValueType = True
                Width = 90
              end
              object GridMasrafEkstreViewACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Width = 128
              end
              object GridMasrafEkstreViewHESAPKODU: TcxGridDBColumn
                Caption = 'Hesap Kodu'
                DataBinding.FieldName = 'HESAPKODU'
                DataBinding.IsNullValueType = True
                Width = 91
              end
              object GridMasrafEkstreViewHESAPADI: TcxGridDBColumn
                Caption = 'Hesap Ad'#305
                DataBinding.FieldName = 'HESAPADI'
                DataBinding.IsNullValueType = True
                Width = 82
              end
              object GridMasrafEkstreViewBORC: TcxGridDBColumn
                Caption = 'Bor'#231
                DataBinding.FieldName = 'BORC'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;(,0.00)'
                Width = 56
              end
              object GridMasrafEkstreViewALACAK: TcxGridDBColumn
                Caption = 'Alacak'
                DataBinding.FieldName = 'ALACAK'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;(,0.00)'
                Width = 67
              end
              object GridMasrafEkstreViewKUR: TcxGridDBColumn
                Caption = 'P.Birimi'
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
                Width = 59
              end
              object GridMasrafEkstreViewBORCBAKIYE: TcxGridDBColumn
                Caption = 'B.Bakiye'
                DataBinding.FieldName = 'BORCBAKIYE'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;(,0.00)'
                Width = 54
              end
              object GridMasrafEkstreViewALACAKBAKIYE: TcxGridDBColumn
                Caption = 'A.Bakiye'
                DataBinding.FieldName = 'ALACAKBAKIYE'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;(,0.00)'
                Width = 56
              end
              object GridMasrafEkstreViewYERELKUR: TcxGridDBColumn
                Caption = 'Y.Kur'
                DataBinding.FieldName = 'YERELKUR'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridMasrafEkstreViewYERELTUTAR: TcxGridDBColumn
                Caption = 'Y.Tutar'
                DataBinding.FieldName = 'YERELTUTAR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
                Visible = False
              end
              object GridMasrafEkstreViewYERELBAKIYE: TcxGridDBColumn
                Caption = 'Y.Bakiye'
                DataBinding.FieldName = 'YERELBAKIYE'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
                Visible = False
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
              GridView = GridMasrafEkstreView
            end
          end
        end
      end
    end
    object ProjeTarihceEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Proje Tarih'#231'esi.'
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
      Caption = 'ProjeTarihceEkr'
      OnPage = ProjeTarihceEkrPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gridAktiviteTarihce: TcxGrid
        Left = 0
        Top = 70
        Width = 918
        Height = 373
        Align = alClient
        TabOrder = 0
        LookAndFeel.NativeStyle = True
        object tvAktiviteTarihce: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsProjeGecmis
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object tvAktiviteTarihceEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxLabelProperties'
            Width = 132
          end
          object tvAktiviteTarihceTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Sorumlu'
                ImageIndex = 0
                Value = 51
              end
              item
                Description = 'A'#351'ama'
                Value = 52
              end
              item
                Description = 'A'#351'ama Sorumlusu'
                Value = 53
              end
              item
                Description = 'Durum'
                Value = 54
              end
              item
                Description = 'Sonu'#231
                Value = 55
              end
              item
                Description = #304'lgili'
                Value = 56
              end>
            Properties.ReadOnly = True
            Width = 110
          end
          object tvAktiviteTarihceONCEKI: TcxGridDBColumn
            Caption = #214'nceki'
            DataBinding.FieldName = 'ONCEKI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxLabelProperties'
            Width = 183
          end
          object tvAktiviteTarihceSONRAKI: TcxGridDBColumn
            Caption = 'Sonraki'
            DataBinding.FieldName = 'SONRAKI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxLabelProperties'
            Width = 186
          end
          object tvAktiviteTarihcePERSONEL: TcxGridDBColumn
            Caption = 'De'#287'i'#351'tiren Personel'
            DataBinding.FieldName = 'PERSONEL'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxLabelProperties'
            Width = 212
          end
        end
        object gridAktiviteTarihceLevel1: TcxGridLevel
          GridView = tvAktiviteTarihce
        end
      end
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 10
      Width = 121
    end
    object cxDBLabel5: TcxDBLabel
      Left = 88
      Top = 20
      DataBinding.DataField = 'BITISTARIHI'
      DataBinding.DataSource = dtsSonAktivite
      Transparent = True
      Height = 21
      Width = 135
    end
    object cxLabel4: TcxLabel
      Left = 13
      Top = 18
      Caption = 'Tarih'
      Transparent = True
    end
  end
  object DtsProjeler: TDataSource
    DataSet = TabProjeler
    Left = 56
    Top = 354
  end
  object TabProjeler: TFDQuery
    BeforeEdit = TabProjelerBeforeEdit
    BeforePost = TabProjelerBeforePost
    AfterPost = TabProjelerAfterPost
    AfterScroll = TabProjelerAfterScroll
    OnNewRecord = TabProjelerNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'*'
      'FROM '
      #9'PROJELER'
      'WHERE '
      #9'ID = :PID'
      'ORDER BY ID')
    Left = 189
    Top = 16
  end
  object DtsImaj: TDataSource
    Left = 646
    Top = 285
  end
  object OpenDialog1: TOpenDialog
    Left = 727
    Top = 239
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 951
    Top = 178
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU,' +
        'RA.BOLUM '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id '
      'and RA.BOLUM=:Bolum  '
      'order by  1')
    Left = 688
    Top = 283
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 759
    Top = 317
  end
  object TabSonAktivite: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT TOP 1 ID, BITISTARIHI , KONUSU, NOTLAR'
      'FROM AKTIVITELER A '
      'WHERE PROJEID = :PID AND'
      'A.DURUM  in (8,9)'
      'ORDER BY BITISTARIHI DESC')
    Left = 369
    Top = 294
  end
  object dtsSonAktivite: TDataSource
    DataSet = TabSonAktivite
    Left = 433
    Top = 346
  end
  object DtsProjeGecmis: TDataSource
    DataSet = TabProjeGecmis
    Left = 121
    Top = 333
  end
  object TabProjeGecmis: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      'P.*,PERSONEL=R1.FIRMA'
      'from '
      #9'PROJEGECMIS P'
      
        #9'LEFT OUTER JOIN REHBER R1 ON convert(varchar(10),R1.ID) = P.EKL' +
        'EYEN'#9
      'where P.PROJEID= :PPROJEID'
      'order by P.EKLEMETARIHI')
    Left = 162
    Top = 236
  end
  object PmKopyala: TPopupMenu
    Left = 552
    Top = 336
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
    end
  end
  object TabProjeAsama: TFDQuery
    BeforeEdit = TabProjeAsamaBeforeEdit
    BeforePost = TabProjeAsamaBeforePost
    AfterPost = TabProjeAsamaAfterPost
    BeforeDelete = TabProjeAsamaBeforeDelete
    OnCalcFields = TabProjeAsamaCalcFields
    OnNewRecord = TabProjeAsamaNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      '*'
      'from '
      'PROJEASAMA PA'
      'where '
      'PROJEID=:PProejID')
    Left = 498
    Top = 28
    object TabProjeAsamaID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabProjeAsamaPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabProjeAsamaREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabProjeAsamaTUR: TIntegerField
      FieldName = 'TUR'
    end
    object TabProjeAsamaASAMA: TIntegerField
      FieldName = 'ASAMA'
    end
    object TabProjeAsamaONAY: TBooleanField
      FieldName = 'ONAY'
    end
    object TabProjeAsamaACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 150
    end
    object TabProjeAsamaBASTAR: TSQLTimeStampField
      FieldName = 'BASTAR'
    end
    object TabProjeAsamaBITTAR: TSQLTimeStampField
      FieldName = 'BITTAR'
    end
    object TabProjeAsamaDURUM: TBooleanField
      FieldName = 'DURUM'
    end
    object TabProjeAsamaAKTIF: TBooleanField
      FieldName = 'AKTIF'
    end
    object TabProjeAsamaEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabProjeAsamaEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabProjeAsamaDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabProjeAsamaDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabProjeAsamaSUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabProjeAsamaASAMASORUMLUSU: TStringField
      FieldKind = fkCalculated
      FieldName = 'ASAMASORUMLUSU'
      Size = 50
      Calculated = True
    end
    object TabProjeAsamaSURE: TStringField
      FieldKind = fkCalculated
      FieldName = 'SURE'
      Calculated = True
    end
  end
  object DtsProjeAsama: TDataSource
    DataSet = TabProjeAsama
    OnStateChange = DtsProjeAsamaStateChange
    Left = 523
    Top = 230
  end
  object PmSagClick: TPopupMenu
    Left = 632
    Top = 328
    object AsamalariEkle: TMenuItem
      Caption = 'T'#252'm A'#351'amalar'#305' Ekle'
      OnClick = AsamalariEkleClick
    end
  end
  object TabMaliyet: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT F.ID,KAYNAK='#39'B'#252't'#252'n'#39',BelgeTipi=case when FB.TUR=11 then '#39'F' +
        'atura'#39' when FB.TUR=12 then '#39'Fi'#351#39' else '#39#220'retim'#39' end,'
      'Satici=(select FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BelgeTarihi=FB.FATURATARIH, BelgeNo=FB.FATURANO,'
      
        'Aciklama=case when F.TUR=0 then (select AD from MASRAFGELIR MG w' +
        'here MG.ID=F.URUNID)'
      
        'else (select STOKADI from STOKLAR S where S.ID=F.URUNID) end +'#39' ' +
        #39'+isnull(F.ACIKLAMA,'#39#39'),'
      
        'Tutar=TUTAR/((100.0+KDV)/100.0),KDV=TUTAR-TUTAR/((100.0+KDV)/100' +
        '.0), Toplam=TUTAR,F.KUR,'
      
        'Personel = (select R.FIRMA from REHBER R where R.ID=FB.SATICIKOD' +
        'U)'
      'FROM FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID'
      'where FB.TUR in (6,11,12) and F.MIKTAR>0'
      'and FB.PROJEID=:PrjID1'
      ''
      'union all '
      ''
      
        ' SELECT F.ID,KAYNAK='#39'Sat'#305'r'#39', BelgeTipi=case when FB.TUR=11 then ' +
        #39'Fatura'#39' else '#39'Fi'#351#39' end,'
      'Satici=(select FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BelgeTarihi=FB.FATURATARIH, BelgeNo=FB.FATURANO,'
      
        'Aciklama=case when F.TUR=0 then (select AD from MASRAFGELIR MG w' +
        'here MG.ID=F.URUNID)'
      
        'else (select STOKADI from STOKLAR S where S.ID=F.URUNID) end +'#39' ' +
        #39'+isnull(F.ACIKLAMA,'#39#39'),'
      
        'Tutar=TUTAR/((100.0+KDV)/100.0),KDV=TUTAR-TUTAR/((100.0+KDV)/100' +
        '.0), Toplam=TUTAR,F.KUR,'
      
        'Personel = (select R.FIRMA from REHBER R where R.ID=F.SATICIKODU' +
        ')'
      'FROM FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID'
      'where FB.TUR in (11,12)'
      'and F.PROJEID=:PrjID2'
      ''
      'union all '
      ''
      'SELECT ID,KAYNAK='#39'Sat'#305'r'#39',BelgeTipi='#39'Tahakkuk'#39','
      'Satici=(select FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BelgeTarihi=FB.FATURATARIH, BelgeNo=FB.FATURANO,'
      'Aciklama=ACIKLAMA,'
      'Tutar=FATURA_TUTARI,KDV=0, Toplam=FATURA_TUTARI,FB.KUR,'
      
        'Personel = (select R.FIRMA from REHBER R where R.ID=FB.SATICIKOD' +
        'U)'
      'FROM FATBASLIK FB'
      'where FB.TUR= 13'
      'and PROJEID=:PrjID3'
      ''
      'order by 3')
    Left = 848
    Top = 243
  end
  object DtsMaliyet: TDataSource
    DataSet = TabMaliyet
    Left = 791
    Top = 237
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
      'order by 3 DESC')
    Left = 625
    Top = 193
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 627
    Top = 252
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 752
    Top = 200
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
    PopupMenus = <
      item
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 752
    Top = 112
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
    Left = 472
    Top = 332
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
  object DtsProjeButce: TDataSource
    DataSet = TabProjeButce
    OnStateChange = DtsProjeButceStateChange
    Left = 869
    Top = 29
  end
  object TabProjeButce: TFDQuery
    BeforePost = TabProjeButceBeforePost
    OnCalcFields = TabProjeButceCalcFields
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      
        '       ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '#39','#39#39'),CH' +
        'ARINDEX('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39'))-(CHARINDE' +
        'X('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
      
        '       MG.KOD,PB.ID, PROJEID,MASRAFID, MG.AD,PB.MIKTAR,PB.BIRIMI' +
        ',PB.BIRIMFIYAT, PB.TUTAR,PB.KUR,'
      
        '       GERCEKTAH=(select top 1 YERELBAKIYE from [dbo].[fn_Proje_' +
        'Ekstre](PB.PROJEID,'#39'2000-01-01 00:00'#39', getdate(), 1,MG.ID) Ex or' +
        'der by Ex.TARIH desc),'
      
        '       GERCEKODE=(select top 1 YERELBAKIYE from [dbo].[fn_Proje_' +
        'Ekstre](PB.PROJEID,'#39'2000-01-01 00:00'#39', getdate(), 2,MG.ID) Ex or' +
        'der by Ex.TARIH desc)'
      
        'from PROJEBUTCE PB inner join MASRAFGELIR MG on MG.ID = PB.MASRA' +
        'FID '
      'Where PB.PROJEID=:prm')
    Left = 773
    Top = 143
    object TabProjeButceROOTKOD: TWideStringField
      FieldName = 'ROOTKOD'
      ReadOnly = True
      Size = 4000
    end
    object TabProjeButceKOD: TWideStringField
      FieldName = 'KOD'
    end
    object TabProjeButceID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabProjeButcePROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabProjeButceMASRAFID: TIntegerField
      FieldName = 'MASRAFID'
    end
    object TabProjeButceAD: TWideStringField
      FieldName = 'AD'
      Size = 200
    end
    object TabProjeButceMIKTAR: TFMTBCDField
      FieldName = 'MIKTAR'
      Precision = 24
      Size = 6
    end
    object TabProjeButceBIRIMI: TSmallintField
      FieldName = 'BIRIMI'
    end
    object TabProjeButceBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object TabProjeButceTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 24
      Size = 2
    end
    object TabProjeButceKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabProjeButceGERCEKTAH: TCurrencyField
      FieldName = 'GERCEKTAH'
      ReadOnly = True
    end
    object TabProjeButceGERCEKODE: TCurrencyField
      FieldName = 'GERCEKODE'
      ReadOnly = True
    end
    object TabProjeButceFARK: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'FARK'
      Calculated = True
    end
  end
  object PMButce: TPopupMenu
    Left = 848
    Top = 152
    object ExceldenVeriAlMenu: TMenuItem
      Caption = 'Excelden Veri Al'
      OnClick = ExceldenVeriAlMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExceleGonderMenu: TMenuItem
      Caption = 'Excele G'#246'nder'
      OnClick = ExceleGonderMenuClick
    end
  end
  object DtsCariListe: TDataSource
    DataSet = TabCariListe
    Left = 837
    Top = 369
  end
  object TabCariListe: TFDQuery
    Connection = Tablo.FDCnn
    Left = 772
    Top = 369
  end
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = TabCariListe
    BCDToCurrency = False
    DataSetOptions = []
    Left = 574
    Top = 309
  end
  object frxProjeButce: TfrxDBDataset
    UserName = 'ProjeButce'
    CloseDataSource = False
    DataSet = TabProjeButce
    BCDToCurrency = False
    DataSetOptions = []
    Left = 291
    Top = 282
  end
  object frxProjeler: TfrxDBDataset
    UserName = 'Projeler'
    CloseDataSource = False
    DataSet = TabProjeler
    BCDToCurrency = False
    DataSetOptions = []
    Left = 227
    Top = 370
  end
  object PopupMenuYaz: TPopupMenu
    Left = 853
    Top = 194
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
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
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
    Top = 432
  end
end
