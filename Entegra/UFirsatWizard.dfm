object FirsatWizardDlg: TFirsatWizardDlg
  Left = 0
  Top = 0
  ActiveControl = DateBASLAMATARIHI
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Sat'#305#351' Firsat'#305' Sihirbaz'#305
  ClientHeight = 497
  ClientWidth = 1073
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
    Height = 497
    Align = alLeft
    TabOrder = 0
    object btnProje: TcxButton
      Left = 0
      Top = 79
      Width = 84
      Height = 29
      Caption = 'F'#305'rsat'
      TabOrder = 0
      OnClick = btnProjeClick
    end
    object btnDetay: TcxButton
      Tag = 1
      Left = 0
      Top = 115
      Width = 84
      Height = 29
      Caption = 'Detay'
      TabOrder = 1
      OnClick = btnProjeClick
    end
    object btnTarihce: TcxButton
      Tag = 3
      Left = 0
      Top = 316
      Width = 84
      Height = 29
      Caption = 'Tarih'#231'e'
      TabOrder = 3
      OnClick = btnProjeClick
    end
    object cxButton1: TcxButton
      Tag = 2
      Left = 0
      Top = 150
      Width = 84
      Height = 29
      Caption = 'Teklifler'
      TabOrder = 2
      OnClick = btnProjeClick
    end
    object LabelSonTeklif: TcxLabel
      Left = 2
      Top = 185
      Cursor = crHandPoint
      Caption = 'Min.Teklif'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = LabelSonTeklifClick
    end
    object SonTeklifTutari: TcxCurrencyEdit
      Left = 9
      Top = 203
      EditValue = 0.000000000000000000
      ParentColor = True
      Properties.DisplayFormat = ',0.00;(,0.00)'
      Properties.ReadOnly = True
      Style.BorderStyle = ebsNone
      Style.Edges = []
      Style.TextColor = clRed
      TabOrder = 5
      Width = 75
    end
    object LabelTeklifTarihi: TcxLabel
      Left = 9
      Top = 245
      Caption = '--'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel6: TcxLabel
      Left = 2
      Top = 222
      Cursor = crHandPoint
      Caption = 'Tarihi'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = LabelSonTeklifClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 987
    Height = 497
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
      987
      497)
    object ProjeEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Sat'#305#351' F'#305'rsat'#305' Bilgileri'
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
      object cxDBLabel2: TcxDBLabel
        Left = 161
        Top = 8
        DataBinding.DataField = 'REHBERID'
        DataBinding.DataSource = DtsFirsatlar
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
      object PanelZemin: TPanel
        Left = 0
        Top = 70
        Width = 987
        Height = 385
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 6
        object PanelUst: TPanel
          Left = 0
          Top = 0
          Width = 987
          Height = 170
          Align = alTop
          Color = clSkyBlue
          ParentBackground = False
          TabOrder = 0
          object ComboPRJ_TURU: TcxDBImageComboBox
            Left = 100
            Top = 57
            RepositoryItem = Tablo.repFirsatTuru
            DataBinding.DataField = 'TURU'
            DataBinding.DataSource = DtsFirsatlar
            Properties.Items = <>
            Properties.OnEditValueChanged = ComboPRJ_TURUPropertiesEditValueChanged
            TabOrder = 3
            Width = 121
          end
          object DateBASLAMATARIHI: TcxDBDateEdit
            Left = 100
            Top = 32
            DataBinding.DataField = 'BASLAMATARIHI'
            DataBinding.DataSource = DtsFirsatlar
            Properties.ImmediatePost = True
            Properties.SaveTime = False
            Properties.ShowTime = False
            Properties.OnCloseUp = cxDBDateEdit1PropertiesCloseUp
            TabOrder = 0
            Width = 121
          end
          object ComboPRJ_KONUSU: TcxDBComboBox
            Left = 100
            Top = 7
            RepositoryItem = Tablo.repFirsatKonu
            DataBinding.DataField = 'KONUSU'
            DataBinding.DataSource = DtsFirsatlar
            TabOrder = 6
            Width = 320
          end
          object ComboPRJ_DURUM: TcxDBImageComboBox
            Left = 510
            Top = 8
            RepositoryItem = Tablo.repFirsatDurum
            DataBinding.DataField = 'ASAMA'
            DataBinding.DataSource = DtsFirsatlar
            Properties.Items = <>
            TabOrder = 1
            Width = 125
          end
          object DateBITISTARIHI: TcxDBDateEdit
            Left = 296
            Top = 33
            DataBinding.DataField = 'BITISTARIHI'
            DataBinding.DataSource = DtsFirsatlar
            Properties.ImmediatePost = True
            Properties.SaveTime = False
            Properties.ShowTime = False
            TabOrder = 2
            Width = 125
          end
          object cxLabel11: TcxLabel
            Left = 4
            Top = 34
            Caption = 'Ba'#351'lama'
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
            Left = 241
            Top = 34
            Caption = 'Biti'#351' '
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
            Left = 4
            Top = 8
            Cursor = crHandPoint
            Hint = 'Proje_Konusu'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.KONUSU'
            Caption = 'F'#305'rsat Ad'#305'/Konu'
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
            Tag = -2113
            Left = 436
            Top = 9
            Cursor = crHandPoint
            Hint = 'Proje_A'#351'ama'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.ASAMA'
            Caption = 'Durum *'
            FocusControl = ComboPRJ_DURUM
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
            Tag = -2112
            Left = 4
            Top = 59
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
            Left = 4
            Top = 84
            Caption = 'F'#305'rsat De'#287'eri'
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
            Left = 100
            Top = 82
            DataBinding.DataField = 'SATISFIYATI'
            DataBinding.DataSource = DtsFirsatlar
            Properties.DisplayFormat = ',0.00;(,0.00)'
            TabOrder = 8
            Width = 78
          end
          object ComboSATISKUR: TcxDBComboBox
            Left = 177
            Top = 82
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            DataBinding.DataField = 'SATISKUR'
            DataBinding.DataSource = DtsFirsatlar
            Properties.DropDownListStyle = lsFixedList
            TabOrder = 9
            Width = 44
          end
          object ComboIlgili: TcxButtonEdit
            Left = 101
            Top = 107
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
            Left = 4
            Top = 114
            DataBinding.DataField = 'ILGILI'
            DataBinding.DataSource = DtsFirsatlar
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
            Left = 5
            Top = 140
            Cursor = crHandPoint
            Caption = 'F'#305'rsat Kodu*'
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
            Left = 829
            Top = 7
            DataBinding.DataField = 'PROJEKODU'
            DataBinding.DataSource = DtsFirsatlar
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
            Left = 241
            Top = 60
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
            Left = 296
            Top = 58
            DataBinding.DataField = 'TIPI'
            DataBinding.DataSource = DtsFirsatlar
            Properties.Alignment.Horz = taLeftJustify
            Properties.Items = <>
            Properties.OnCloseUp = comboPRJ_TIPIPropertiesCloseUp
            TabOrder = 4
            Width = 125
          end
          object cxLabel8: TcxLabel
            Tag = -2119
            Left = 241
            Top = 86
            Cursor = crHandPoint
            Hint = 'Proje_Olasilik'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.OLASILIK'
            Caption = 'Olas'#305'l'#305'k'
            FocusControl = ComboOLASILIK
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
          object LabelIlgili: TcxLabel
            Left = 4
            Top = 109
            Cursor = crHandPoint
            Caption = 'M'#252#351'teri '#304'lgili'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Properties.WordWrap = True
            Transparent = True
            Width = 65
          end
          object cxLabel10: TcxLabel
            Left = 241
            Top = 109
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
            Top = 33
            DataBinding.DataField = 'SUBEID'
            DataBinding.DataSource = DtsFirsatlar
            Properties.ImmediatePost = True
            Properties.Items = <>
            TabOrder = 11
            Width = 125
          end
          object LblSube: TcxLabel
            Left = 435
            Top = 35
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
          object EditSORUMLU: TcxButtonEdit
            Left = 296
            Top = 107
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
            Width = 125
          end
          object ComboOLASILIK: TcxDBImageComboBox
            Left = 296
            Top = 83
            RepositoryItem = Tablo.repFirsatOlasilik
            DataBinding.DataField = 'OLASILIK'
            DataBinding.DataSource = DtsFirsatlar
            Properties.ImmediatePost = True
            Properties.Items = <>
            TabOrder = 10
            Width = 125
          end
          object CheckTamam: TcxDBCheckBox
            Left = 636
            Top = 6
            Caption = 'Kapand'#305
            DataBinding.DataField = 'DURUM'
            DataBinding.DataSource = DtsFirsatlar
            ParentFont = False
            Properties.DisplayChecked = '2'
            Properties.DisplayUnchecked = '1'
            Properties.ValueChecked = '2'
            Properties.ValueUnchecked = '1'
            Properties.OnEditValueChanged = CheckTamamPropertiesEditValueChanged
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
            Left = 101
            Top = 140
            DataBinding.DataField = 'PROJEKODU'
            DataBinding.DataSource = DtsFirsatlar
            ParentFont = False
            Style.Color = clSkyBlue
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            TabOrder = 28
            Width = 319
          end
          object cxLabel3: TcxLabel
            Tag = -2115
            Left = 435
            Top = 85
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
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelTURUClick
          end
          object ComboSEBEBI: TcxDBImageComboBox
            Left = 511
            Top = 83
            RepositoryItem = Tablo.repFirsatSebebi
            DataBinding.DataField = 'SEBEBI'
            DataBinding.DataSource = DtsFirsatlar
            Properties.Items = <>
            TabOrder = 30
            Width = 125
          end
          object ButtonEditRakip: TcxDBButtonEdit
            Left = 511
            Top = 108
            DataBinding.DataField = 'RAKIP'
            DataBinding.DataSource = DtsFirsatlar
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.OnButtonClick = cxDBButtonEdit1PropertiesButtonClick
            ShowHint = True
            TabOrder = 31
            Width = 362
          end
          object cxLabel12: TcxLabel
            Left = 436
            Top = 109
            Caption = 'Rakipler'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Properties.WordWrap = True
            Transparent = True
            Width = 44
          end
        end
        object PageControlAlt: TcxPageControl
          Left = 0
          Top = 170
          Width = 987
          Height = 215
          Align = alClient
          TabOrder = 1
          Properties.ActivePage = TabSheetIsListesi
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 211
          ClientRectLeft = 4
          ClientRectRight = 983
          ClientRectTop = 27
          object TabSheetIsListesi: TcxTabSheet
            Caption = #304#351' Listesi'
            ImageIndex = 3
            object Panel2: TPanel
              Left = 0
              Top = 0
              Width = 979
              Height = 41
              Align = alTop
              Caption = 'Panel9'
              TabOrder = 0
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
                object ToolButton8: TToolButton
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
                  OnClick = GorevDuzenleTusClick
                end
              end
              object JvNavPanelHeader1: TJvNavPanelHeader
                Left = 147
                Top = 1
                Width = 831
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
                  Left = 47
                  Top = 12
                  Caption = 'Tamamlananlar'#305' da g'#246'ster'
                  ParentFont = False
                  Properties.OnEditValueChanged = CheckTamamlananPropertiesEditValueChanged
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
                  Left = 229
                  Top = 12
                  RepositoryItem = Tablo.RepGorevSonKac
                  ParentFont = False
                  Properties.Items = <>
                  Style.Color = clSilver
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clBlack
                  Style.Font.Height = -13
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.TextColor = clBlack
                  Style.IsFontAssigned = True
                  TabOrder = 1
                  Visible = False
                  Width = 115
                end
              end
            end
            object TreeListGorev: TcxDBTreeList
              Left = 0
              Top = 41
              Width = 979
              Height = 143
              Align = alClient
              Bands = <
                item
                end>
              DataController.DataSource = DtsGorevler
              DataController.ParentField = 'BAGIDUST'
              DataController.KeyField = 'ID'
              DragMode = dmAutomatic
              Images = Tablo.KlasorResimleri
              Navigator.Buttons.CustomButtons = <>
              OptionsCustomizing.ColumnsQuickCustomization = True
              OptionsData.Editing = False
              OptionsData.Deleting = False
              OptionsSelection.MultiSelect = True
              OptionsView.GridLines = tlglBoth
              OptionsView.Indicator = True
              OptionsView.TreeLineStyle = tllsNone
              PopupMenus.ColumnHeaderMenu.PopupMenu = AnaForm.PopupMenuTree
              RootValue = -1
              ScrollbarAnnotations.CustomAnnotations = <>
              TabOrder = 1
              OnClick = TreeListGorevClick
              OnDblClick = TreeListGorevDblClick
              object TreeListEkipmancxDBTreeListID: TcxDBTreeListColumn
                Visible = False
                DataBinding.FieldName = 'ID'
                Width = 100
                Position.ColIndex = 8
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
              object TreeListEkipmancxDBTreeListCARIAD: TcxDBTreeListColumn
                Caption.Text = 'CAR'#304' AD'
                DataBinding.FieldName = 'CARIAD'
                Options.Editing = False
                Width = 100
                Position.ColIndex = 4
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
                Position.ColIndex = 5
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
                Position.ColIndex = 6
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
                Position.ColIndex = 7
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
                Position.ColIndex = 9
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
                Position.ColIndex = 10
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
                Position.ColIndex = 11
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
                Position.ColIndex = 12
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
                Position.ColIndex = 13
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object TreeListEkipmancxDBTreeListPROJEKODU: TcxDBTreeListColumn
                DataBinding.FieldName = 'PROJEKODU'
                Width = 100
                Position.ColIndex = 14
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object TreeListEkipmancxDBTreeListEKLEYENAD: TcxDBTreeListColumn
                DataBinding.FieldName = 'EKLEYENAD'
                Width = 100
                Position.ColIndex = 15
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object TreeListEkipmancxDBTreeListEKLEMETARIHI: TcxDBTreeListColumn
                PropertiesClassName = 'TcxDateEditProperties'
                DataBinding.FieldName = 'EKLEMETARIHI'
                Width = 100
                Position.ColIndex = 16
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object TreeListGorevcxDBTreeListEKLEYEN: TcxDBTreeListColumn
                Visible = False
                DataBinding.FieldName = 'EKLEYEN'
                Width = 100
                Position.ColIndex = 17
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object TreeListGorevcxDBTreeListLISTEID: TcxDBTreeListColumn
                Visible = False
                DataBinding.FieldName = 'LISTEID'
                Width = 100
                Position.ColIndex = 18
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
            end
          end
          object TabSheetLojistik: TcxTabSheet
            Caption = 'Lojistik'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object ToolBar2: TToolBar
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 973
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
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object ButtonYeni: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = ButtonYeniClick
              end
              object ButtonSil: TToolButton
                Left = 62
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = ButtonSilClick
              end
              object ButtonKaydet: TToolButton
                Left = 124
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Visible = False
                OnClick = ButtonKaydetClick
              end
              object ButtonIptal: TToolButton
                Left = 186
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                ImageName = 'PngImage3'
                Visible = False
                OnClick = ButtonIptalClick
              end
            end
            object GridLojistik: TcxGrid
              Left = 0
              Top = 27
              Width = 979
              Height = 157
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object GridLojistikView: TcxGridDBTableView
                OnDblClick = GridBagTeklifViewDblClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCanFocusRecord = GridBagTeklifViewCanFocusRecord
                DataController.DataSource = DtsLojistik
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridLojistikViewTIPI: TcxGridDBColumn
                  Caption = 'Tipi'
                  DataBinding.FieldName = 'TIPIAD'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.OnButtonClick = GridLojistikViewTIPIPropertiesButtonClick
                end
                object GridLojistikViewKAYNAKULKE: TcxGridDBColumn
                  Caption = #220'lke-->'
                  DataBinding.FieldName = 'KAYNAKULKEAD'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = False
                  Properties.OnButtonClick = GridLojistikViewKAYNAKULKEPropertiesButtonClick
                  Width = 100
                end
                object GridLojistikViewKAYNAKLOKASYON: TcxGridDBColumn
                  Caption = 'Nereden-->'
                  DataBinding.FieldName = 'KAYNAKLOKASYONAD'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = False
                  Properties.OnButtonClick = GridLojistikViewKAYNAKLOKASYONPropertiesButtonClick
                  Width = 74
                end
                object GridLojistikViewHEDEFULKE: TcxGridDBColumn
                  Caption = '-->'#220'lke'
                  DataBinding.FieldName = 'HEDEFULKEAD'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = False
                  Properties.OnButtonClick = GridLojistikViewHEDEFULKEPropertiesButtonClick
                  Width = 135
                end
                object GridLojistikViewHEDEFLOKASYON: TcxGridDBColumn
                  Caption = '-->Nereye'
                  DataBinding.FieldName = 'HEDEFLOKASYONAD'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = False
                  Properties.OnButtonClick = GridLojistikViewHEDEFLOKASYONPropertiesButtonClick
                  Width = 233
                end
                object GridLojistikViewTARIH: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'TARIH'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.ReadOnly = False
                  Width = 87
                end
                object GridLojistikViewYUKLEME_YERI: TcxGridDBColumn
                  Caption = 'Y'#252'kleme Yeri'
                  DataBinding.FieldName = 'YUKLEME_YERI'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 80
                end
                object GridLojistikViewYUKLEME_LIMANI: TcxGridDBColumn
                  Caption = 'Y'#252'kleme Liman'#305
                  DataBinding.FieldName = 'YUKLEME_LIMANI'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 89
                end
                object GridLojistikViewTAHLIYE_LIMANI: TcxGridDBColumn
                  Caption = 'Tahliye Liman'#305
                  DataBinding.FieldName = 'TAHLIYE_LIMANI'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 87
                end
                object GridLojistikViewBOSALTMA_YERI: TcxGridDBColumn
                  Caption = 'Bo'#351'altma Yeri'
                  DataBinding.FieldName = 'BOSALTMA_YERI'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 96
                end
                object GridLojistikViewACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.ReadOnly = False
                  Width = 150
                end
              end
              object cxGridLevel2: TcxGridLevel
                GridView = GridLojistikView
              end
            end
          end
          object TabSheetAsama: TcxTabSheet
            Caption = 'A'#351'ama'
            ImageIndex = 2
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object ToolBar5: TToolBar
              Left = 0
              Top = 0
              Width = 979
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
            object GridAsama: TcxGrid
              Left = 0
              Top = 24
              Width = 979
              Height = 160
              Align = alClient
              PopupMenu = PmSagClick
              TabOrder = 1
              object GridAsamaView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsProjeAsama
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsView.GroupByBox = False
                object GridAsamaViewASAMA: TcxGridDBColumn
                  Caption = 'A'#351'ama'
                  DataBinding.FieldName = 'ASAMA'
                  RepositoryItem = Tablo.RepFirsatAsama
                  Width = 76
                end
                object GridAsamaViewASAMASORUMLUSU: TcxGridDBColumn
                  Caption = 'Sorumlu'
                  DataBinding.FieldName = 'ASAMASORUMLUSU'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.OnButtonClick = GridAsamaViewASAMASORUMLUSUPropertiesButtonClick
                  Width = 120
                end
                object GridAsamaViewACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 264
                end
                object GridAsamaViewBASTAR: TcxGridDBColumn
                  Caption = 'Ba'#351'lama'
                  DataBinding.FieldName = 'BASTAR'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.DateButtons = [btnClear, btnNow, btnToday]
                  Width = 126
                end
                object GridAsamaViewBITTAR: TcxGridDBColumn
                  Caption = 'Biti'#351
                  DataBinding.FieldName = 'BITTAR'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.DateButtons = [btnClear, btnNow, btnToday]
                  Properties.Kind = ckDateTime
                  Width = 110
                end
                object GridAsamaViewSURE: TcxGridDBColumn
                  Caption = 'S'#252're'
                  DataBinding.FieldName = 'SURE'
                  PropertiesClassName = 'TcxTextEditProperties'
                end
                object GridAsamaViewONAY: TcxGridDBColumn
                  Caption = 'Aktif'
                  DataBinding.FieldName = 'AKTIF'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Width = 34
                end
              end
              object GridAsamaLevel1: TcxGridLevel
                GridView = GridAsamaView
              end
            end
          end
          object TabSheet1: TcxTabSheet
            Caption = 'Yorum / Medya'
            ImageIndex = 0
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            DesignSize = (
              979
              184)
            object GridYorum: TcxGrid
              Left = 0
              Top = 0
              Width = 979
              Height = 123
              Align = alClient
              TabOrder = 0
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
            object Panel4: TPanel
              Left = 0
              Top = 123
              Width = 979
              Height = 41
              Align = alBottom
              TabOrder = 1
              object MemoChat: TcxRichEdit
                Left = 1
                Top = 1
                Align = alClient
                Properties.ScrollBars = ssVertical
                TabOrder = 1
                Height = 39
                Width = 831
              end
              object BtnMesajGonder: TcxButton
                Left = 832
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
                Left = 917
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
              Top = 164
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
              ExplicitTop = 163
              AnchorX = 979
            end
            object CheckZenginMetin: TcxCheckBox
              Left = 888
              Top = 162
              Anchors = [akTop, akRight]
              Caption = 'Zengin Metin'
              TabOrder = 3
            end
          end
        end
      end
      object cxDBLabel1: TcxDBLabel
        Left = 27
        Top = 44
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsFirsatlar
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 17
        Width = 42
      end
      object cxLabel13: TcxLabel
        Left = 6
        Top = 44
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
        Width = 981
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
        Width = 987
        Height = 358
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
        Left = 36
        Top = 141
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
        Height = 264
        Width = 387
      end
      object ComboBolum: TcxDBComboBox
        Left = 83
        Top = 37
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsFirsatlar
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
        Caption = #350'ablon Se'#231'iniz.'
        Style.TextColor = clMaroon
        Transparent = True
        OnClick = LabelSablonClick
      end
    end
    object ProjebagTeklif: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Bu F'#305'rsata Ba'#287'l'#305' Teklifler'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 'Alta yeni '#246'zellik ekyebilirsiniz'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnEnterPage = ProjebagTeklifEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 981
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 117
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
        object YeniTeklifGir: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni Teklif Olustur'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = YeniTeklifGirClick
        end
        object DuzenleTeklif: TToolButton
          Left = 117
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = DuzenleTeklifClick
        end
      end
      object GridBagTeklif: TcxGrid
        Left = 0
        Top = 97
        Width = 987
        Height = 358
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridBagTeklifView: TcxGridDBTableView
          OnDblClick = GridBagTeklifViewDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridBagTeklifViewCanFocusRecord
          DataController.DataSource = DtsTabBagTeklif
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
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridBagTeklifViewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object GridBagTeklifViewTEKLIFNO: TcxGridDBColumn
            Caption = 'Teklif No'
            DataBinding.FieldName = 'TEKLIFNO'
            DataBinding.IsNullValueType = True
            Width = 56
          end
          object GridBagTeklifViewKONUSU: TcxGridDBColumn
            Caption = 'Konusu'
            DataBinding.FieldName = 'KONUSU'
            DataBinding.IsNullValueType = True
            Width = 116
          end
          object GridBagTeklifViewTEKLIFTURU: TcxGridDBColumn
            Caption = 'T'#252'r'#252
            DataBinding.FieldName = 'TURU'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repTeklifTuru
            Width = 65
          end
          object GridBagTeklifViewTEKLIFDURUMU: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repTeklifDurumu
            Width = 80
          end
          object GridBagTeklifViewFIRMA: TcxGridDBColumn
            Caption = 'M'#252#351'teri'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 140
          end
          object GridBagTeklifViewHAZIRLAYANAD: TcxGridDBColumn
            Caption = 'Haz'#305'rlayan'
            DataBinding.FieldName = 'HAZIRLAYANAD'
            DataBinding.IsNullValueType = True
            Width = 85
          end
          object GridBagTeklifViewTEKLIF_TUTARI: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TEKLIF_MATRAHI'
            DataBinding.IsNullValueType = True
            Width = 49
          end
          object GridBagTeklifViewKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 36
          end
          object GridBagTeklifViewGECERLILIK_SURESI: TcxGridDBColumn
            Caption = 'S'#252're'
            DataBinding.FieldName = 'GECERLILIK_SURESI'
            DataBinding.IsNullValueType = True
            Width = 50
          end
          object GridBagTeklifViewOLASILIK: TcxGridDBColumn
            Caption = 'Olas'#305'l'#305'k'
            DataBinding.FieldName = 'OLASILIK'
            DataBinding.IsNullValueType = True
            Width = 61
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridBagTeklifView
        end
      end
    end
    object ProjeTarihceEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'F'#305'rsat Tarih'#231'esi.'
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
        Width = 987
        Height = 385
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
  object DtsFirsatlar: TDataSource
    DataSet = TabFirsatlar
    Left = 56
    Top = 354
  end
  object TabFirsatlar: TFDQuery
    BeforeEdit = TabFirsatlarBeforeEdit
    BeforePost = TabFirsatlarBeforePost
    AfterPost = TabFirsatlarAfterPost
    AfterScroll = TabFirsatlarAfterScroll
    OnNewRecord = TabFirsatlarNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'*'
      'FROM '
      #9'PROJELER'
      'WHERE '
      #9'ID = :PID'
      'ORDER BY ID')
    Left = 229
    Top = 312
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
    Left = 759
    Top = 146
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
    Left = 218
    Top = 204
  end
  object TabBagTeklif: TFDQuery
    Connection = Tablo.FDCnn
    Left = 294
    Top = 340
  end
  object DtsTabBagTeklif: TDataSource
    DataSet = TabBagTeklif
    Left = 369
    Top = 350
  end
  object PmKopyala: TPopupMenu
    Left = 552
    Top = 336
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
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
    Left = 713
    Top = 169
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
    Left = 488
    Top = 324
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
  object frxProjeler: TfrxDBDataset
    UserName = 'Projeler'
    CloseDataSource = False
    DataSet = TabFirsatlar
    BCDToCurrency = False
    DataSetOptions = []
    Left = 227
    Top = 370
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = GridYorum
    PopupMenus = <
      item
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 768
    Top = 400
  end
  object TabLojistik: TFDQuery
    OnCalcFields = TabLojistikCalcFields
    OnNewRecord = TabLojistikNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT *'
      'FROM AKTIVITELOJ A '
      'WHERE AKTIVITEID = :PID '
      'ORDER BY TARIH, ID')
    Left = 409
    Top = 222
    object TabLojistikID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabLojistikAKTIVITEID: TIntegerField
      FieldName = 'AKTIVITEID'
    end
    object TabLojistikTIPI: TSmallintField
      FieldName = 'TIPI'
    end
    object TabLojistikKAYNAKULKE: TSmallintField
      FieldName = 'KAYNAKULKE'
    end
    object TabLojistikKAYNAKLOKASYON: TSmallintField
      FieldName = 'KAYNAKLOKASYON'
    end
    object TabLojistikHEDEFULKE: TSmallintField
      FieldName = 'HEDEFULKE'
    end
    object TabLojistikHEDEFLOKASYON: TSmallintField
      FieldName = 'HEDEFLOKASYON'
    end
    object TabLojistikTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabLojistikACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      Size = 150
    end
    object TabLojistikEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabLojistikEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabLojistikDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabLojistikDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabLojistikKAYNAKULKEAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'KAYNAKULKEAD'
      Size = 50
      Calculated = True
    end
    object TabLojistikHEDEFULKEAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'HEDEFULKEAD'
      Size = 50
      Calculated = True
    end
    object TabLojistikKAYNAKLOKASYONAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'KAYNAKLOKASYONAD'
      Size = 50
      Calculated = True
    end
    object TabLojistikHEDEFLOKASYONAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'HEDEFLOKASYONAD'
      Size = 50
      Calculated = True
    end
    object TabLojistikTIPIAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'TIPIAD'
      Size = 10
      Calculated = True
    end
    object TabLojistikYUKLEME_YERI: TWideStringField
      FieldName = 'YUKLEME_YERI'
      Size = 100
    end
    object TabLojistikYUKLEME_LIMANI: TWideStringField
      FieldName = 'YUKLEME_LIMANI'
      Size = 100
    end
    object TabLojistikTAHLIYE_LIMANI: TWideStringField
      FieldName = 'TAHLIYE_LIMANI'
      Size = 100
    end
    object TabLojistikBOSALTMA_YERI: TWideStringField
      FieldName = 'BOSALTMA_YERI'
      Size = 100
    end
  end
  object DtsLojistik: TDataSource
    DataSet = TabLojistik
    OnStateChange = DtsLojistikStateChange
    Left = 473
    Top = 234
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
    Left = 560
    Top = 248
  end
  object TabProjeAsama: TFDQuery
    BeforeEdit = TabProjeAsamaBeforeEdit
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
    Left = 850
    Top = 116
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
    object TabProjeAsamaBASTAR: TDateTimeField
      FieldName = 'BASTAR'
    end
    object TabProjeAsamaBITTAR: TDateTimeField
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
    object TabProjeAsamaEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabProjeAsamaDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabProjeAsamaDEGISTIRMETARIHI: TDateTimeField
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
    Left = 931
    Top = 326
  end
  object PmSagClick: TPopupMenu
    Left = 640
    Top = 352
    object AsamalariEkle: TMenuItem
      Caption = 'T'#252'm A'#351'amalar'#305' Ekle'
      OnClick = AsamalariEkleClick
    end
  end
  object DtsGorevler: TDataSource
    DataSet = TabGorevler
    Left = 515
    Top = 408
  end
  object TabGorevler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'exec sp_Prg_IsListesi_Projeler  :RehberId, :AcKapa , :GunSay, :L' +
        'isteId')
    Left = 429
    Top = 405
  end
end
