object CekWizardDlg: TCekWizardDlg
  Left = 0
  Top = 0
  ActiveControl = Logo
  BorderIcons = [biSystemMenu]
  Caption = #199'ek Sihirbaz'#305
  ClientHeight = 528
  ClientWidth = 1048
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 528
    Align = alLeft
    TabOrder = 0
    object CekTus: TcxButton
      Tag = 1
      Left = 3
      Top = 80
      Width = 80
      Height = 29
      Caption = #199'ek'
      TabOrder = 0
      OnClick = CekTusClick
    end
    object DokumanTus: TcxButton
      Tag = 2
      Left = 3
      Top = 111
      Width = 80
      Height = 29
      Caption = 'Yorum/Medya'
      TabOrder = 1
      OnClick = DokumanTusClick
    end
    object TarihceTus: TcxButton
      Tag = 3
      Left = 3
      Top = 143
      Width = 80
      Height = 29
      Caption = 'Tarih'#231'e'
      TabOrder = 2
      OnClick = TarihceTusClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 962
    Height = 528
    ActivePage = CekEkr
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
      962
      528)
    object CekEkr: TJvWizardInteriorPage
      Tag = 1
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #199'ek'
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
      OnExitPage = CekEkrExitPage
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 956
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 56
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
        TabOrder = 0
        Transparent = True
        object YaziciYaz: TToolButton
          Left = 0
          Top = 0
          Caption = #199'ek'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 8
          ImageName = 'PngImage15'
          Style = tbsTextButton
        end
        object ToolButton1: TToolButton
          Left = 56
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 17
          ImageName = 'PngImage17'
          Style = tbsSeparator
        end
        object ResimTus: TToolButton
          Left = 64
          Top = 0
          Caption = 'Resim'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = ResimTusClick
        end
      end
      object Panel5: TPanel
        Left = 0
        Top = 97
        Width = 962
        Height = 389
        Align = alClient
        BevelInner = bvLowered
        BorderWidth = 4
        Color = 14079702
        ParentBackground = False
        TabOrder = 1
        object cxLabel8: TcxLabel
          Left = 9
          Top = 236
          Caption = 'Seri No*'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label3: TcxLabel
          Left = 594
          Top = 64
          Caption = 'Kay'#305't Tarihi'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label6: TcxLabel
          Left = 594
          Top = 159
          Caption = 'Vade Tarihi*'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label7: TcxLabel
          Left = 594
          Top = 38
          Caption = 'Durum'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label17: TcxLabel
          Left = 9
          Top = 131
          Caption = 'M'#252#351'teri*'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label18: TcxLabel
          Left = 220
          Top = 131
          Caption = 'Tutar*'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object LabelODEMEYERI: TcxLabel
          Left = 594
          Top = 131
          Caption = 'Ke'#351'ide Yeri*'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label15: TcxLabel
          Left = 594
          Top = 187
          Caption = 'Hesap No'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label8: TcxLabel
          Left = 594
          Top = 293
          Caption = #214'zel Kod'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label16: TcxLabel
          Left = 361
          Top = 64
          Caption = 'Bordro No'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Visible = False
        end
        object Label19: TcxLabel
          Left = 361
          Top = 38
          Caption = 'Kodu'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label25: TcxLabel
          Left = 220
          Top = 238
          Caption = 'Ko'#231'an No'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object Label1: TcxLabel
          Left = 594
          Top = 90
          Caption = 'Makbuz No'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object EditCARIKOD: TcxButtonEdit
          Left = 65
          Top = 130
          ParentShowHint = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end
            item
              Caption = '-'
              Enabled = False
              Hint = 'Temizle'
              Kind = bkText
            end>
          Properties.OnButtonClick = EditCARIKODPropertiesButtonClick
          ShowHint = True
          TabOrder = 16
          Width = 121
        end
        object ComboKUR: TcxDBComboBox
          Left = 469
          Top = 129
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          DataBinding.DataField = 'KUR'
          DataBinding.DataSource = DtsCekler
          Properties.OnCloseUp = ComboKURPropertiesCloseUp
          TabOrder = 19
          Width = 49
        end
        object EditOZELKOD: TcxDBTextEdit
          Left = 681
          Top = 292
          DataBinding.DataField = 'OZELKOD'
          DataBinding.DataSource = DtsCekler
          TabOrder = 34
          Width = 121
        end
        object EditCekSERINO: TcxDBTextEdit
          Left = 99
          Top = 237
          DataBinding.DataField = 'SERINO'
          DataBinding.DataSource = DtsCekler
          Properties.ReadOnly = True
          TabOrder = 29
          Width = 116
        end
        object EditACIKLAMA: TcxDBTextEdit
          Left = 103
          Top = 291
          DataBinding.DataField = 'ACIKLAMA'
          DataBinding.DataSource = DtsCekler
          TabOrder = 40
          Width = 466
        end
        object EditHesapNo: TcxDBTextEdit
          Left = 680
          Top = 186
          DataBinding.DataField = 'HESAPNO'
          DataBinding.DataSource = DtsCekler
          TabOrder = 27
          Width = 122
        end
        object DateKesideTarihi: TcxDBDateEdit
          Left = 680
          Top = 158
          DataBinding.DataField = 'VADE'
          DataBinding.DataSource = DtsCekler
          TabOrder = 22
          Width = 122
        end
        object EditTUTAR: TcxDBCurrencyEdit
          Left = 332
          Top = 130
          DataBinding.DataField = 'TUTAR'
          DataBinding.DataSource = DtsCekler
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00;-,0.00'
          TabOrder = 18
          Width = 132
        end
        object cxDBTextEdit1: TcxDBTextEdit
          Left = 190
          Top = 130
          DataBinding.DataField = 'REHBERID'
          DataBinding.DataSource = DtsCekler
          ParentColor = True
          TabOrder = 17
          Visible = False
          Width = 25
        end
        object Logo: TcxDBImage
          AlignWithMargins = True
          Left = 9
          Top = 11
          DataBinding.DataField = 'LOGO'
          DataBinding.DataSource = DtsBankalar
          Properties.Caption = 'Banka se'#231'mek i'#231'in t'#305'klay'#305'n'
          Properties.GraphicClassName = 'TdxPNGImage'
          Properties.GraphicTransparency = gtTransparent
          Properties.ReadOnly = True
          Style.Shadow = True
          TabOrder = 1
          OnClick = LogoClick
          Height = 82
          Width = 127
        end
        object LabelSubeKodu: TcxDBLabel
          Left = 142
          Top = 19
          DataBinding.DataField = 'SUBEKODU'
          DataBinding.DataSource = DtsBankalar
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          Height = 20
          Width = 83
        end
        object LabelSubeAdi: TcxDBLabel
          Left = 142
          Top = 40
          AutoSize = True
          DataBinding.DataField = 'SUBEADI'
          DataBinding.DataSource = DtsBankalar
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object DateTARIH: TcxDateEdit
          Left = 681
          Top = 63
          Properties.Kind = ckDateTime
          TabOrder = 6
          OnExit = DateTARIHExit
          Width = 121
        end
        object EditCekBORDRO: TcxDBTextEdit
          Left = 450
          Top = 64
          DataBinding.DataField = 'BORDRO'
          DataBinding.DataSource = DtsCekler
          Enabled = False
          ParentColor = True
          ParentFont = False
          Properties.ReadOnly = True
          Style.BorderColor = clGrayText
          Style.Edges = []
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.LookAndFeel.Kind = lfOffice11
          Style.LookAndFeel.NativeStyle = False
          Style.IsFontAssigned = True
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.Kind = lfOffice11
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 10
          Visible = False
          Width = 99
        end
        object EditCekKOD: TcxDBTextEdit
          Left = 448
          Top = 39
          DataBinding.DataField = 'KOD'
          DataBinding.DataSource = DtsCekler
          Enabled = False
          ParentColor = True
          ParentFont = False
          Style.BorderColor = clGrayText
          Style.Edges = []
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.LookAndFeel.Kind = lfOffice11
          Style.LookAndFeel.NativeStyle = False
          Style.IsFontAssigned = True
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.Kind = lfOffice11
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 4
          Width = 99
        end
        object SeriNoTus: TcxButton
          Left = 9
          Top = 236
          Width = 48
          Height = 25
          Caption = 'Seri No'
          TabOrder = 28
          OnClick = SeriNoTusClick
        end
        object EditCekKocanNo: TcxTextEdit
          Left = 332
          Top = 237
          Enabled = False
          Properties.ReadOnly = True
          TabOrder = 30
          Width = 58
        end
        object LabelCekBankaHesapID: TcxLabel
          Left = 144
          Top = 61
          Caption = '--'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Visible = False
        end
        object EditMakbuzNo: TcxTextEdit
          Left = 681
          Top = 89
          TabOrder = 12
          OnExit = DateTARIHExit
          OnKeyUp = EditMakbuzNoKeyUp
          Width = 121
        end
        object EditODEMEYERI: TcxDBComboBox
          Left = 680
          Top = 130
          DataBinding.DataField = 'ODEMEYERI'
          DataBinding.DataSource = DtsCekler
          TabOrder = 20
          Width = 122
        end
        object EditMM: TcxButtonEdit
          Left = 680
          Top = 265
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
          Properties.OnButtonClick = EditMMPropertiesButtonClick
          ShowHint = True
          TabOrder = 31
          Width = 208
        end
        object LabelMasrafMerkezi: TcxLabel
          Left = 593
          Top = 266
          Caption = 'Masraf Kalemi'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LabelAd: TcxLabel
          Left = 9
          Top = 159
          AutoSize = False
          Caption = 'LabelAd'
          Properties.WordWrap = True
          Height = 20
          Width = 192
        end
        object ComboDURUM: TcxImageComboBox
          Left = 681
          Top = 36
          Enabled = False
          Properties.Items = <>
          StyleDisabled.Color = clWhite
          StyleDisabled.TextColor = clWindowText
          TabOrder = 0
          Width = 121
        end
        object cxLabel9: TcxLabel
          Left = 9
          Top = 292
          Caption = 'A'#231#305'klama'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object LabelIBAN: TcxLabel
          Left = 220
          Top = 210
          Caption = 'IBAN* '
          Transparent = True
        end
        object LabelBorclu: TcxLabel
          Left = 141
          Top = 265
          Caption = 'Bor'#231'lu'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object EditBORCLU: TcxDBTextEdit
          Left = 207
          Top = 264
          DataBinding.DataField = 'BORCLU'
          DataBinding.DataSource = DtsCekler
          TabOrder = 33
          Width = 362
        end
        object cxLabel14: TcxLabel
          Left = 392
          Top = 238
          Caption = 'VKNO'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object cxDBTextEdit3: TcxDBTextEdit
          Left = 459
          Top = 237
          DataBinding.DataField = 'VKNO'
          DataBinding.DataSource = DtsCekler
          TabOrder = 32
          Width = 110
        end
        object cxLabel15: TcxLabel
          Left = 9
          Top = 210
          Caption = 'D'#246'viz Kar'#351#305'l'#305#287#305
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Visible = False
        end
        object cxDBLabel1: TcxDBLabel
          Left = 161
          Top = 210
          Cursor = crHandPoint
          DataBinding.DataField = 'DOVIZ_KURU'
          DataBinding.DataSource = DtsCekler
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.TransparentBorder = True
          Style.IsFontAssigned = True
          Visible = False
          Height = 24
          Width = 54
        end
        object LabelDOVIZ_TUTARI: TcxDBCurrencyEdit
          Left = 120
          Top = 209
          Cursor = crHandPoint
          DataBinding.DataField = 'DOVIZ_TUTARI'
          DataBinding.DataSource = DtsCekler
          ParentColor = True
          Properties.DisplayFormat = ',0.00;(,0.00)'
          Style.Edges = []
          TabOrder = 25
          Visible = False
          Width = 35
        end
        object LblSube: TcxLabel
          Left = 594
          Top = 11
          Caption = #350'ube*'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object ComboSube: TcxDBImageComboBox
          Left = 681
          Top = 9
          RepositoryItem = Tablo.RepSubeler
          DataBinding.DataField = 'SUBEID'
          DataBinding.DataSource = DtsCekler
          Properties.Items = <>
          StyleDisabled.Color = clWhite
          StyleDisabled.TextColor = clWindowText
          TabOrder = 49
          Width = 121
        end
        object LabelDovizTuru: TcxLabel
          Left = 220
          Top = 160
          Cursor = crHandPoint
          Caption = 'Ekstre D'#246'vizi ...'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.HotTrack = False
          Style.TextColor = clNavy
          Style.TextStyle = [fsUnderline]
          Style.IsFontAssigned = True
          Transparent = True
          Visible = False
          OnClick = LabelDovizTuruClick
        end
        object EditDovTutar: TcxDBCurrencyEdit
          Left = 332
          Top = 158
          DataBinding.DataField = 'DOVIZ_TUTARI'
          DataBinding.DataSource = DtsCekler
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.00 ;-,0.00 '
          TabOrder = 51
          Visible = False
          OnKeyUp = EditDovTutarKeyUp
          Width = 131
        end
        object ComboDovKur: TcxDBComboBox
          Left = 469
          Top = 157
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          DataBinding.DataField = 'DOVIZ_KURU'
          DataBinding.DataSource = DtsCekler
          Properties.DropDownListStyle = lsFixedList
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.ReadOnly = False
          Properties.OnCloseUp = ComboDovKurPropertiesCloseUp
          TabOrder = 52
          Visible = False
          Width = 49
        end
        object EditKulKur: TcxCurrencyEdit
          Left = 520
          Top = 159
          TabStop = False
          EditValue = 100000c
          ParentFont = False
          Properties.DecimalPlaces = 4
          Properties.DisplayFormat = ',0.0000 ;-,0.0000 '
          Properties.EditFormat = ',0.0000 ;-,0.0000 '
          TabOrder = 53
          Visible = False
          Width = 49
        end
        object CheckCIROLU: TcxDBCheckBox
          Left = 9
          Top = 264
          Caption = 'Ba'#351'kas'#305'n'#305'n '#231'eki'
          DataBinding.DataField = 'BASKASININ'
          DataBinding.DataSource = DtsCekler
          Properties.OnChange = CheckCIROLUPropertiesChange
          TabOrder = 54
        end
        object EditIBAN: TcxDBMaskEdit
          Left = 332
          Top = 209
          DataBinding.DataField = 'IBAN'
          DataBinding.DataSource = DtsCekler
          Properties.IgnoreMaskBlank = True
          Properties.EditMask = '!\TRAA AAAA AAAA AAAA AAAA AAAA AA;1;_'
          TabOrder = 23
          Width = 237
        end
        object CheckEKSTREDEKULLAN: TcxDBCheckBox
          Left = 220
          Top = 176
          Caption = 'bunu kullan'
          DataBinding.DataField = 'EKSTREDEKULLAN'
          DataBinding.DataSource = DtsCekler
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          TabOrder = 55
          Visible = False
        end
        object BeditProje: TcxButtonEdit
          Left = 680
          Top = 238
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
          TabOrder = 56
          Width = 208
        end
        object cxLabel1: TcxLabel
          Left = 593
          Top = 239
          Caption = 'Proje'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LabelCoklu: TcxLabel
          Left = 892
          Top = 245
          Cursor = crHandPoint
          Caption = #199'oklu Proje/Masraf'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.HotTrack = False
          Style.TextColor = clNavy
          Style.TextStyle = [fsUnderline]
          Style.IsFontAssigned = True
          Transparent = True
          OnClick = LabelCokluClick
        end
        object PanelKefil: TPanel
          Left = 6
          Top = 318
          Width = 950
          Height = 65
          Align = alBottom
          BevelKind = bkSoft
          TabOrder = 59
          Visible = False
          object cxLabel2: TcxLabel
            Left = 6
            Top = 1
            Caption = 'Kefil'
            Transparent = True
          end
          object EditKEFIL_AD: TcxDBTextEdit
            Left = 98
            Top = 1
            DataBinding.DataField = 'KEFIL_AD'
            DataBinding.DataSource = DtsCekler
            TabOrder = 1
            Width = 465
          end
          object cxLabel3: TcxLabel
            Left = 592
            Top = 4
            Caption = 'Kefil Adres'
            Transparent = True
          end
          object MemoKEFIL_ADRES: TcxDBMemo
            Left = 675
            Top = 4
            DataBinding.DataField = 'KEFIL_ADRES'
            DataBinding.DataSource = DtsCekler
            TabOrder = 4
            Height = 52
            Width = 263
          end
          object cxLabel4: TcxLabel
            Left = 6
            Top = 28
            Caption = 'Telefon'
            Transparent = True
          end
          object EditKEFIL_TEL: TcxDBTextEdit
            Left = 98
            Top = 28
            DataBinding.DataField = 'KEFIL_TEL'
            DataBinding.DataSource = DtsCekler
            TabOrder = 2
            Width = 207
          end
          object cxLabel5: TcxLabel
            Left = 311
            Top = 31
            Caption = 'VKNO'
            Transparent = True
          end
          object EditKEFIL_VKNO: TcxDBTextEdit
            Left = 356
            Top = 28
            DataBinding.DataField = 'KEFIL_VKNO'
            DataBinding.DataSource = DtsCekler
            TabOrder = 3
            Width = 207
          end
        end
        object cbIrsaliyeli: TcxDBCheckBox
          Left = 808
          Top = 90
          DataBinding.DataField = 'R'
          DataBinding.DataSource = DtsCekler
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          TabOrder = 13
          Transparent = True
        end
      end
      object SeriNoSQLMemo: TcxMemo
        Left = 832
        Top = 206
        Lines.Strings = (
          'DECLARE '
          '@I BIGINT,'
          '@BIT   BIGINT,   '
          '@CKID INT '
          ''
          ' CREATE TABLE #GECICI( SERINO BIGINT, KOCANNO INT) '
          'SET @CKID=:PCKID '
          'DECLARE cek CURSOR FOR '
          ' --SELECT BASSERINO, BITSERINO from CEKKOCAN order by TARIH'
          ' select BASSERINO, BITSERINO ,CK.ID--select *'
          
            '  from CEKKOCAN CK inner join KREDILER C on CK.KREDIID= C.ID whe' +
            're CK.ID=@CKID order by CK.TARIH'
          ' '
          'OPEN cek '
          'FETCH NEXT FROM cek INTO  @I,@BIT,@CKID'
          ''
          'WHILE @@FETCH_STATUS = 0 '
          'begin'
          ' WHILE @I <= @BIT'
          '   BEGIN  '
          '     if not exists(select * from CEKLER C1 where SERINO=@I)'
          '     begin'
          '       INSERT INTO #GECICI (SERINO,KOCANNO)VALUES (@I,@CKID)'
          '     end'
          '     SET @I = @I + 1'
          '   END    '
          'FETCH NEXT FROM cek INTO  @I,@BIT,@CKID'
          'end'
          ''
          'CLOSE cek '
          'DEALLOCATE cek'
          ''
          
            ' select SERINO from #GECICI where  SERINO like '#39'%<ara>%'#39' order b' +
            'y 1                                                             '
          ' drop table #GECICI ;'#9#9)
        TabOrder = 2
        Visible = False
        Height = 45
        Width = 597
      end
      object DetaySQLMemo: TcxMemo
        Left = 856
        Top = 155
        Lines.Strings = (
          'select '
          
            #9'LIMITADET=MAX(CK.KREDILIMIT)/(SELECT CR2.TUTAR FROM CEKRISKPAYI' +
            ' CR2 WHERE GETDATE() BETWEEN '
          'CR2.BASTARIH AND CR2.BITTARIH),'
          
            #9'RISKADET=SUM(DISTINCT CKK.BITSERINO+1) - SUM(DISTINCT CKK.BASSE' +
            'RINO)-SUM(CASE WHEN '
          'C.DURUM<>1 THEN 0 ELSE 1 END),'
          
            #9'KALANADET=(MAX(CK.KREDILIMIT)/(SELECT CR2.TUTAR FROM CEKRISKPAY' +
            'I CR2 WHERE GETDATE() '
          'BETWEEN '
          'CR2.BASTARIH AND CR2.BITTARIH))-'
          
            #9'(SUM(DISTINCT CKK.BITSERINO+1) - SUM(DISTINCT CKK.BASSERINO)-SU' +
            'M(CASE WHEN C.DURUM<>1 THEN '
          '0 '
          'ELSE 1 END)),'
          #9'LIMITTUTAR=MAX(CK.KREDILIMIT),'
          
            #9'RISKTUTAR=(SUM(DISTINCT CKK.BITSERINO+1) - SUM(DISTINCT CKK.BAS' +
            'SERINO)-SUM(CASE WHEN '
          'C.DURUM<>1 THEN 0 ELSE 1 END))*'
          
            #9'(SELECT CR2.TUTAR FROM CEKRISKPAYI CR2 WHERE GETDATE() BETWEEN ' +
            'CR2.BASTARIH AND '
          'CR2.BITTARIH),'
          
            #9'KALANTUTAR=MAX(CK.KREDILIMIT)-((SUM(DISTINCT CKK.BITSERINO+1) -' +
            ' SUM(DISTINCT CKK.BASSERINO)-'
          'SUM(CASE WHEN C.DURUM<>1 THEN 0 ELSE 1 END))*'
          
            #9'(SELECT CR2.TUTAR FROM CEKRISKPAYI CR2 WHERE GETDATE() BETWEEN ' +
            'CR2.BASTARIH AND '
          'CR2.BITTARIH))'
          'from '
          #9'CEKKREDI CK inner join '
          #9'CEKKOCAN CKK on '
          #9#9'CKK.KREDIID=CK.ID inner join '
          '    CEKLER C on '
          #9#9'C.SERINO between CKK.BASSERINO and CKK.BITSERINO inner join  '
          '    CEKRISKPAYI CR on '
          #9#9'C.TARIH between CR.BASTARIH and CR.BITTARIH  '
          'where '
          #9'CK.ID= :PCekkrediID'#9)
        TabOrder = 3
        Visible = False
        Height = 45
        Width = 597
      end
      object cxLabel16: TcxLabel
        Left = 6
        Top = 47
        Caption = 'ID'
        ParentFont = False
        Transparent = True
      end
      object cxDBLabel2: TcxDBLabel
        Left = 19
        Top = 45
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsCekler
        Transparent = True
        Height = 21
        Width = 37
      end
      object lblAd: TcxLabel
        Left = 218
        Top = 36
        Cursor = crHandPoint
        ParentCustomHint = False
        Caption = 'Ad'#305
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        Style.BorderStyle = ebsNone
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.Shadow = False
        Style.IsFontAssigned = True
        Properties.LabelEffect = cxleCool
        Properties.LabelStyle = cxlsRaised
        Transparent = True
      end
      object LabelKod: TcxLabel
        Left = 218
        Top = 4
        Cursor = crHandPoint
        Caption = 'Kodu'
        DragCursor = crDefault
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clBlack
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
      end
    end
    object DokumanEkr: TJvWizardInteriorPage
      Tag = 2
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
      object Panel4: TPanel
        Left = 0
        Top = 445
        Width = 962
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
          Width = 814
        end
        object BtnMesajGonder: TcxButton
          Left = 815
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
          Left = 900
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
        Top = 425
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
        AnchorX = 962
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 962
        Height = 355
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
      Tag = 3
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
      object cxGridTarihce: TcxGrid
        Left = 0
        Top = 70
        Width = 962
        Height = 416
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object cxGridTarihceDBTableView1: TcxGridDBTableView
          PopupMenu = PopupCekHareket
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
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
            Width = 150
          end
          object cxGridTarihceDBTableView1BELGENO: TcxGridDBColumn
            Caption = 'Makbuz No'
            DataBinding.FieldName = 'BELGENO'
            DataBinding.IsNullValueType = True
            Width = 88
          end
          object cxGridTarihceDBTableView1ISLEM: TcxGridDBColumn
            Caption = #304#351'lem'
            DataBinding.FieldName = 'ISLEM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepKasaTurleriReadOnly
            Width = 112
          end
          object cxGridTarihceDBTableView1ISLEMYERI: TcxGridDBColumn
            Caption = #304#351'lem Yeri'
            DataBinding.FieldName = 'ISLEMYERI'
            DataBinding.IsNullValueType = True
            Width = 229
          end
          object cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 139
          end
          object cxGridTarihceDBTableView1DOVIZ_TUTARI: TcxGridDBColumn
            Caption = 'Yerel Tutar'
            DataBinding.FieldName = 'DOVIZ_TUTARI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 93
          end
        end
        object cxGridTarihceLevel1: TcxGridLevel
          GridView = cxGridTarihceDBTableView1
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
  object OpenDialog1: TOpenDialog
    Left = 260
    Top = 175
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 552
    Top = 32
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
  object PopupMenuYaz: TPopupMenu
    Left = 335
    Top = 177
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
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object TabCekler: TFDQuery
    AfterOpen = TabCeklerAfterOpen
    BeforeEdit = TabCeklerBeforeEdit
    BeforePost = TabCeklerBeforePost
    AfterPost = TabCeklerAfterPost
    OnNewRecord = TabCeklerNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT C.*,'
      
        'SONHAREKET=(select top 1 ISLEM from CEKHAREKET CH where CH.CEKSE' +
        'NETLERID=C.ID order by CH.TARIH desc),'
      
        'YAZIYLATOPLAM=dbo.fn_MoneyToText(convert(varchar(100),C.TUTAR),C' +
        '.KUR,0)'
      ''
      ' FROM CEKLER C WHERE C.ID = :PID')
    Left = 31
    Top = 193
  end
  object DtsCekler: TDataSource
    DataSet = TabCekler
    Left = 24
    Top = 227
  end
  object TabBankalar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select BS.BANKAKODU, BANKAADI,SUBEKODU,SUBEADI,LOGO'
      '   from BANKASUBELER BS '
      '        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where BS.ID = :PID')
    Left = 37
    Top = 299
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object DtsBankalar: TDataSource
    DataSet = TabBankalar
    Left = 36
    Top = 363
  end
  object frxCekler: TfrxDBDataset
    UserName = 'CEKLER'
    CloseDataSource = False
    DataSet = TabCekler
    BCDToCurrency = False
    DataSetOptions = []
    Left = 197
    Top = 225
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 702
    Top = 21
  end
  object DtsCekHareketler: TDataSource
    DataSet = TabCekHareketler
    Left = 33
    Top = 465
  end
  object TabCekHareketler: TFDQuery
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
      'order by CH.ID')
    Left = 30
    Top = 416
  end
  object PopupCekHareket: TPopupMenu
    Left = 480
    Top = 240
    object arihDeitir1: TMenuItem
      Caption = 'Tarih/Makbuz No/A'#231#305'klama'
      OnClick = arihDeitir1Click
    end
    object HareketiSil1: TMenuItem
      Caption = 'Hareketi Sil'
      OnClick = HareketiSil1Click
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
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 587
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 112
    Top = 96
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
    Left = 736
    Top = 416
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
