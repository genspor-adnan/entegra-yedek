object StokWizardDlg: TStokWizardDlg
  Left = 0
  Top = 0
  ActiveControl = PageControlUst
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Stok Kart Sihirbaz'#305
  ClientHeight = 579
  ClientWidth = 1005
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object Label11: TcxLabel
    Left = 454
    Top = 204
    Caption = 'Tipi'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 89
    Height = 579
    Align = alLeft
    TabOrder = 0
    object BtnStokKart: TcxButton
      Tag = 2
      Left = 3
      Top = 63
      Width = 81
      Height = 29
      Caption = 'Kart'
      TabOrder = 0
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnStokKartClick
    end
    object BtnDokuman: TcxButton
      Tag = 3
      Left = 3
      Top = 217
      Width = 81
      Height = 29
      Caption = 'Yorum/Medya'
      TabOrder = 5
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnDokumanClick
    end
    object BtnFiyat: TcxButton
      Tag = 4
      Left = 3
      Top = 186
      Width = 81
      Height = 29
      Caption = 'Fiyat'
      TabOrder = 4
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnFiyatClick
    end
    object BtnPaket: TcxButton
      Tag = 3
      Left = 3
      Top = 340
      Width = 81
      Height = 29
      Caption = 'Paket'
      TabOrder = 9
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnPaketClick
    end
    object BtnBarkod: TcxButton
      Tag = 4
      Left = 3
      Top = 94
      Width = 81
      Height = 29
      Caption = 'Barkod'
      TabOrder = 1
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnBarkodClick
    end
    object btnIsOrtaya: TcxButton
      Tag = 6
      Left = 3
      Top = 125
      Width = 81
      Height = 29
      Caption = #304#351' Orta'#287#305
      TabOrder = 2
      Visible = False
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = btnIsOrtayaClick
    end
    object btnEsdegerUrun: TcxButton
      Tag = 7
      Left = 3
      Top = 156
      Width = 81
      Height = 29
      Caption = 'E'#351'de'#287'er '#220'r'#252'n'
      TabOrder = 3
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      OnClick = btnEsdegerUrunClick
    end
    object BtnDetay: TcxButton
      Tag = 3
      Left = 3
      Top = 248
      Width = 81
      Height = 29
      Caption = 'Detay'
      TabOrder = 6
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnDetayClick
    end
    object BtnKota: TcxButton
      Tag = 3
      Left = 3
      Top = 279
      Width = 81
      Height = 29
      Caption = 'Kota'
      TabOrder = 7
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnKotaClick
    end
    object BtnBoyut: TcxButton
      Tag = 3
      Left = 3
      Top = 309
      Width = 81
      Height = 29
      Caption = 'Boyut'
      TabOrder = 8
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnBoyutClick
    end
    object BtnSecimler: TcxButton
      Tag = 3
      Left = 3
      Top = 371
      Width = 81
      Height = 29
      Caption = 'Se'#231'imler'
      TabOrder = 10
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnSecimlerClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 89
    Top = 0
    Width = 916
    Height = 579
    ActivePage = StokKartEkr
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
      916
      579)
    object StokKartEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Stok Kart Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Text = 
        'Se'#231'ece'#287'iniz bilgi listede yoksa sol taraftaki ba'#351'l'#305#287'a t'#305'klay'#305'p e' +
        'kleyin.'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      EnabledButtons = [bkBack, bkNext, bkFinish, bkCancel]
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      OnExitPage = StokKartEkrExitPage
      OnNextButtonClick = StokKartEkrNextButtonClick
      object PageControlUst: TcxPageControl
        Left = 0
        Top = 70
        Width = 916
        Height = 467
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = TabSeetGenelBilgiler
        Properties.CustomButtons.Buttons = <>
        OnChange = TabStokKartChange
        ClientRectBottom = 463
        ClientRectLeft = 4
        ClientRectRight = 912
        ClientRectTop = 27
        object TabSeetGenelBilgiler: TcxTabSheet
          Caption = 'Genel Bilgiler'
          Color = clSilver
          ImageIndex = 0
          ParentColor = False
          PopupMenu = PopupMenuStok
          object cxLabel2: TcxLabel
            Left = 420
            Top = 134
            Caption = 'Garanti'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Properties.WordWrap = True
            Transparent = True
            Width = 42
          end
          object Label1: TcxLabel
            Left = 0
            Top = 5
            Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
            Caption = 'Stok Kodu'
            ParentFont = False
            ParentShowHint = False
            ShowHint = True
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object Label2: TcxLabel
            Left = 0
            Top = 30
            Caption = 'Stok Ad'#305
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
            Left = 0
            Top = 108
            Cursor = crHandPoint
            Hint = 'StokKart_Grubu'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.GRUBU'
            Caption = 'Grubu'
            FocusControl = ComboGRUBU
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
          object Label4: TcxLabel
            Left = 200
            Top = 108
            Cursor = crHandPoint
            Hint = 'StokKart_'#214'zellik'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.OZELLIK'
            Caption = #214'zellik'
            FocusControl = ComboOZELLIK
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
          object Label5: TcxLabel
            Left = 0
            Top = 134
            Cursor = crHandPoint
            Hint = 'StokKart_Anabirim'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.ANABIRIM'
            Caption = 'Ana Birim'
            FocusControl = ComboANABIRIM
            ParentFont = False
            PopupMenu = PopupMenuBirim
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            OnClick = LabelMarkaClick
          end
          object Label6: TcxLabel
            Left = 200
            Top = 134
            Cursor = crHandPoint
            Hint = 'StokKart_Anabirim'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.ANABIRIM'
            Caption = '2. Birim '
            FocusControl = ComboBIRIM2
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
          object Label8: TcxLabel
            Left = 349
            Top = 134
            Caption = '='
          end
          object Label10: TcxLabel
            Left = 0
            Top = 57
            Caption = 'Kategori'
            Transparent = True
          end
          object Label13: TcxLabel
            Left = 423
            Top = 264
            Caption = 'Min Stok'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object Label17: TcxLabel
            Left = 0
            Top = 160
            Hint = 'StokKart_KDV'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.KDV'
            Caption = 'KDV %'
            FocusControl = ComboKDV
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
          object Label16: TcxLabel
            Left = 200
            Top = 239
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
          object Label7: TcxLabel
            Left = 420
            Top = 29
            Cursor = crHandPoint
            Hint = 'StokKart_Durum'
            Caption = 'Durum'
            FocusControl = ComboDURUM
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object Label9: TcxLabel
            Left = 420
            Top = 83
            Cursor = crHandPoint
            Hint = 'StokKart_Tipi'
            Caption = 'Tipi'
            FocusControl = ComboTIPI
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
          object Label12: TcxLabel
            Left = 200
            Top = 186
            Caption = 'Raf '#214'mr'#252
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object Label14: TcxLabel
            Left = 200
            Top = 160
            Caption = 'Ek Vergi %'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object Label15: TcxLabel
            Left = 0
            Top = 239
            Caption = #304'zleme Y'#246'ntemi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Properties.WordWrap = True
            Transparent = True
            Width = 80
          end
          object LabelMarka: TcxLabel
            Left = 0
            Top = 82
            Cursor = crHandPoint
            Hint = 'StokKart_Marka'
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
          object LabelModel: TcxLabel
            Left = 200
            Top = 82
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
          object EditSTOKADI: TcxDBTextEdit
            Left = 92
            Top = 28
            DataBinding.DataField = 'STOKADI'
            DataBinding.DataSource = DtsStok
            TabOrder = 3
            Width = 323
          end
          object ComboGRUBU: TcxDBImageComboBox
            Left = 92
            Top = 106
            RepositoryItem = Tablo.repStokGrubu
            DataBinding.DataField = 'GRUBU'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 7
            Width = 100
          end
          object ComboOZELLIK: TcxDBImageComboBox
            Left = 282
            Top = 104
            RepositoryItem = Tablo.repStokOzellik
            DataBinding.DataField = 'OZELLIK'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 8
            Width = 132
          end
          object ComboANABIRIM: TcxDBImageComboBox
            Left = 92
            Top = 132
            RepositoryItem = Tablo.repStokAnaBirim
            DataBinding.DataField = 'ANABIRIM'
            DataBinding.DataSource = DtsStok
            PopupMenu = PopupMenuBirim
            Properties.Items = <>
            Properties.OnCloseUp = ComboANABIRIMPropertiesCloseUp
            TabOrder = 9
            Width = 100
          end
          object ComboBIRIM2: TcxDBImageComboBox
            Left = 283
            Top = 132
            RepositoryItem = Tablo.repStokAnaBirim
            DataBinding.DataField = 'BIRIM2'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 10
            Width = 65
          end
          object EditOZELKOD: TcxDBTextEdit
            Left = 283
            Top = 238
            DataBinding.DataField = 'OZELKOD'
            DataBinding.DataSource = DtsStok
            TabOrder = 41
            Width = 132
          end
          object ComboDURUM: TcxDBImageComboBox
            Left = 553
            Top = 27
            RepositoryItem = Tablo.repStokDurum
            DataBinding.DataField = 'DURUM'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 44
            Width = 121
          end
          object ComboTIPI: TcxDBImageComboBox
            Left = 553
            Top = 81
            RepositoryItem = Tablo.repStokTipi
            DataBinding.DataField = 'TIPI'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 48
            Width = 121
          end
          object cxDBSpinEdit1: TcxDBSpinEdit
            Left = 283
            Top = 185
            DataBinding.DataField = 'RAFOMRU_SURE'
            DataBinding.DataSource = DtsStok
            TabOrder = 38
            Width = 68
          end
          object cxDBTextEdit1: TcxDBTextEdit
            Left = 283
            Top = 159
            DataBinding.DataField = 'EKVERGI'
            DataBinding.DataSource = DtsStok
            TabOrder = 36
            Width = 132
          end
          object cxDBSpinEdit2: TcxDBSpinEdit
            Left = 553
            Top = 264
            DataBinding.DataField = 'MINSTOK'
            DataBinding.DataSource = DtsStok
            TabOrder = 37
            Width = 100
          end
          object ComboRAFOMRU_BIRIM: TcxDBImageComboBox
            Left = 359
            Top = 186
            RepositoryItem = Tablo.repStokZamanBirimi
            DataBinding.DataField = 'RAFOMRU_BIRIM'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 39
            Width = 56
          end
          object ComboMARKA: TcxDBImageComboBox
            Left = 92
            Top = 80
            Cursor = crHandPoint
            RepositoryItem = Tablo.repStokMarka
            DataBinding.DataField = 'MARKA'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            Properties.OnEditValueChanged = ComboMARKAPropertiesEditValueChanged
            TabOrder = 5
            Width = 100
          end
          object ComboMODEL: TcxDBImageComboBox
            Left = 282
            Top = 76
            DataBinding.DataField = 'MODEL'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            TabOrder = 6
            Width = 132
          end
          object edGarantiSure: TcxDBSpinEdit
            Left = 553
            Top = 133
            DataBinding.DataField = 'GARANTISURESI'
            DataBinding.DataSource = DtsStok
            TabOrder = 50
            Width = 65
          end
          object EditBirim2Miktar: TcxDBCurrencyEdit
            Left = 361
            Top = 133
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            DataBinding.DataField = 'BIRIM2MIKTAR'
            DataBinding.DataSource = DtsStok
            Properties.DisplayFormat = ',0.00;-,0.00'
            Properties.MinValue = 0.000100000000000000
            TabOrder = 29
            Width = 54
          end
          object LabelMasrafMerkezi: TcxLabel
            Left = 420
            Top = 160
            Caption = 'Masraf Kalemi'
            Properties.WordWrap = True
            Transparent = True
            Width = 72
          end
          object EditMM: TcxButtonEdit
            Left = 553
            Top = 159
            HelpType = htKeyword
            HelpKeyword = 'MASRAFID'
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
            TabOrder = 51
            Width = 150
          end
          object cxLabel3: TcxLabel
            Left = 420
            Top = 186
            Caption = 'Gelir Kalemi'
            Properties.WordWrap = True
            Transparent = True
            Width = 61
          end
          object EditGM: TcxButtonEdit
            Tag = 1
            Left = 553
            Top = 185
            HelpType = htKeyword
            HelpKeyword = 'GELIRID'
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
            TabOrder = 52
            Width = 150
          end
          object cxLabel5: TcxLabel
            Left = 624
            Top = 134
            Caption = 'Ay'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Properties.WordWrap = True
            Transparent = True
            Width = 16
          end
          object EditGTIP: TcxDBTextEdit
            Left = 553
            Top = 0
            DataBinding.DataField = 'GTIP'
            DataBinding.DataSource = DtsStok
            TabOrder = 42
            Width = 121
          end
          object EditUretici: TcxButtonEdit
            Tag = 1
            Left = 553
            Top = 238
            HelpType = htKeyword
            HelpKeyword = 'GELIRID'
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
            Properties.OnButtonClick = EditUreticiPropertiesButtonClick
            TabOrder = 54
            Width = 150
          end
          object cxLabel7: TcxLabel
            Left = 420
            Top = 239
            Caption = #220'retici Kurum'
            Transparent = True
          end
          object ComboIcerik: TcxDBImageComboBox
            Left = 92
            Top = 211
            RepositoryItem = Tablo.RepStokIcerik
            DataBinding.DataField = 'ICERIK'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 33
            Width = 100
          end
          object cxLabel8: TcxLabel
            Left = 0
            Top = 213
            Cursor = crHandPoint
            Hint = 'StokKart_Grubu'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.GRUBU'
            Caption = #304#231'erik'
            FocusControl = ComboIcerik
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
          object PageControlAlt: TcxPageControl
            Left = 0
            Top = 294
            Width = 908
            Height = 142
            Align = alBottom
            TabOrder = 60
            Properties.ActivePage = TabSheerNotlar
            Properties.CustomButtons.Buttons = <>
            OnChange = PageControlAltChange
            ClientRectBottom = 138
            ClientRectLeft = 4
            ClientRectRight = 904
            ClientRectTop = 27
            object TabSheerNotlar: TcxTabSheet
              Caption = 'Notlar'
              ImageIndex = 0
              object MemoNOTLAR: TcxDBMemo
                Left = 0
                Top = 0
                Align = alClient
                DataBinding.DataField = 'NOTLAR'
                DataBinding.DataSource = DtsStok
                TabOrder = 0
                Height = 111
                Width = 900
              end
            end
            object TabSheetBoyutlar: TcxTabSheet
              Caption = #214'l'#231#252'ler'
              ImageIndex = 1
              object cxGroupBox1: TcxGroupBox
                Left = -5
                Top = 3
                TabOrder = 0
                Height = 97
                Width = 422
                object Label18: TcxLabel
                  Left = 5
                  Top = 5
                  Caption = 'En'
                  FocusControl = cxDBImageComboBox1
                  Transparent = True
                  OnClick = LabelMarkaClick
                end
                object Label19: TcxLabel
                  Left = 5
                  Top = 28
                  Caption = 'Boy'
                  FocusControl = cxDBImageComboBox2
                  Transparent = True
                  OnClick = LabelMarkaClick
                end
                object Label22: TcxLabel
                  Left = 5
                  Top = 51
                  Caption = 'Y'#252'kseklik'
                  FocusControl = cxDBImageComboBox4
                  Transparent = True
                  OnClick = LabelMarkaClick
                end
                object Label23: TcxLabel
                  Left = 5
                  Top = 74
                  Caption = 'Alan'
                  FocusControl = cxDBImageComboBox5
                  Transparent = True
                  OnClick = LabelMarkaClick
                end
                object Label24: TcxLabel
                  Left = 234
                  Top = 5
                  Caption = 'Net Hac'#305'm'
                  FocusControl = cxDBImageComboBox6
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
                object Label25: TcxLabel
                  Left = 234
                  Top = 28
                  Caption = 'Br'#252't Hac'#305'm'
                  FocusControl = cxDBImageComboBox7
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
                object Label26: TcxLabel
                  Left = 234
                  Top = 51
                  Caption = 'Net A'#287#305'rl'#305'k'
                  FocusControl = cxDBImageComboBox8
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
                object Label27: TcxLabel
                  Left = 234
                  Top = 74
                  Caption = 'Br'#252't A'#287#305'rl'#305'k'
                  FocusControl = cxDBImageComboBox9
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
                object cxDBTextEdit2: TcxDBTextEdit
                  Left = 81
                  Top = 3
                  DataBinding.DataField = 'BOYUT_EN'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 0
                  Width = 48
                end
                object cxDBImageComboBox1: TcxDBImageComboBox
                  Left = 131
                  Top = 3
                  RepositoryItem = Tablo.RepStokBirimlerUzunluk
                  DataBinding.DataField = 'UZUNLUK_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 1
                  Width = 43
                end
                object cxDBImageComboBox2: TcxDBImageComboBox
                  Left = 131
                  Top = 26
                  RepositoryItem = Tablo.RepStokBirimlerUzunluk
                  DataBinding.DataField = 'UZUNLUK_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 7
                  Width = 43
                end
                object cxDBTextEdit3: TcxDBTextEdit
                  Left = 81
                  Top = 26
                  DataBinding.DataField = 'BOYUT_BOY'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 6
                  Width = 48
                end
                object cxDBTextEdit5: TcxDBTextEdit
                  Left = 81
                  Top = 49
                  DataBinding.DataField = 'BOYUT_YUKSEKLIK'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 12
                  Width = 48
                end
                object cxDBImageComboBox4: TcxDBImageComboBox
                  Left = 131
                  Top = 49
                  RepositoryItem = Tablo.RepStokBirimlerUzunluk
                  DataBinding.DataField = 'UZUNLUK_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 13
                  Width = 43
                end
                object cxDBTextEdit6: TcxDBTextEdit
                  Left = 81
                  Top = 72
                  DataBinding.DataField = 'BOYUT_ALAN'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 19
                  Width = 48
                end
                object cxDBImageComboBox5: TcxDBImageComboBox
                  Left = 131
                  Top = 72
                  RepositoryItem = Tablo.RepStokBirimlerAlan
                  DataBinding.DataField = 'ALAN_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 20
                  Width = 43
                end
                object cxDBTextEdit7: TcxDBTextEdit
                  Left = 325
                  Top = 3
                  DataBinding.DataField = 'BOYUT_NET_HACIM'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 2
                  Width = 48
                end
                object cxDBImageComboBox6: TcxDBImageComboBox
                  Left = 374
                  Top = 3
                  RepositoryItem = Tablo.RepStokBirimlerHacim
                  DataBinding.DataField = 'HACIM_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 3
                  Width = 43
                end
                object cxDBImageComboBox7: TcxDBImageComboBox
                  Left = 374
                  Top = 26
                  RepositoryItem = Tablo.RepStokBirimlerHacim
                  DataBinding.DataField = 'HACIM_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 9
                  Width = 43
                end
                object cxDBTextEdit8: TcxDBTextEdit
                  Left = 325
                  Top = 26
                  DataBinding.DataField = 'BOYUT_BRUT_HACIM'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 8
                  Width = 48
                end
                object cxDBTextEdit9: TcxDBTextEdit
                  Left = 325
                  Top = 49
                  DataBinding.DataField = 'BOYUT_NET_AGIRLIK'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 14
                  Width = 48
                end
                object cxDBImageComboBox8: TcxDBImageComboBox
                  Left = 374
                  Top = 49
                  RepositoryItem = Tablo.RepStokBirimlerAgirlik
                  DataBinding.DataField = 'AGIRLIK_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 15
                  Width = 43
                end
                object cxDBTextEdit10: TcxDBTextEdit
                  Left = 325
                  Top = 72
                  DataBinding.DataField = 'BOYUT_BRUT_AGIRLIK'
                  DataBinding.DataSource = DtsStok
                  TabOrder = 21
                  Width = 48
                end
                object cxDBImageComboBox9: TcxDBImageComboBox
                  Left = 374
                  Top = 72
                  RepositoryItem = Tablo.RepStokBirimlerAgirlik
                  DataBinding.DataField = 'AGIRLIK_BIRIMI'
                  DataBinding.DataSource = DtsStok
                  Properties.ImmediatePost = True
                  Properties.Items = <>
                  TabOrder = 22
                  Width = 43
                end
              end
            end
            object TabSheetCevrim: TcxTabSheet
              Caption = #199'evrimler'
              ImageIndex = 2
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object ToolBar12: TToolBar
                AlignWithMargins = True
                Left = 3
                Top = 3
                Width = 894
                Height = 24
                Margins.Bottom = 0
                Anchors = [akLeft]
                AutoSize = True
                ButtonWidth = 61
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
                PopupMenu = PopupStokCevrim
                ShowCaptions = True
                TabOrder = 0
                Transparent = True
                object YeniCevrimTus: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'Yeni'
                  ImageIndex = 0
                  ImageName = 'PngImage0'
                  OnClick = YeniCevrimTusClick
                end
                object KaydetCevrimTus: TToolButton
                  Left = 61
                  Top = 0
                  Caption = 'Kaydet'
                  ImageIndex = 2
                  ImageName = 'PngImage2'
                  Visible = False
                  OnClick = KaydetCevrimTusClick
                end
                object SilCevrimTus: TToolButton
                  Left = 122
                  Top = 0
                  Caption = 'Sil'
                  ImageIndex = 1
                  ImageName = 'PngImage1'
                  OnClick = SilCevrimTusClick
                end
                object CevrimIptalTus: TToolButton
                  Left = 183
                  Top = 0
                  Caption = #304'ptal'
                  ImageIndex = 3
                  ImageName = 'PngImage3'
                  Visible = False
                  OnClick = CevrimIptalTusClick
                end
              end
              object cxGridCevrim: TcxGrid
                Left = 0
                Top = 27
                Width = 900
                Height = 84
                Align = alClient
                BevelInner = bvNone
                BevelOuter = bvNone
                Font.Charset = TURKISH_CHARSET
                Font.Color = clWindowText
                Font.Height = -12
                Font.Name = 'Trebuchet MS'
                Font.Style = []
                ParentFont = False
                TabOrder = 1
                LookAndFeel.Kind = lfStandard
                LookAndFeel.NativeStyle = True
                object cxGridDBCevrim: TcxGridDBTableView
                  PopupMenu = PopupStokCevrim
                  Navigator.Buttons.CustomButtons = <>
                  ScrollbarAnnotations.CustomAnnotations = <>
                  OnEditChanged = GridDetayViewEditChanged
                  DataController.DataModeController.SmartRefresh = True
                  DataController.DataSource = DtsCevrim
                  DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <>
                  DataController.Summary.SummaryGroups = <>
                  OptionsCustomize.ColumnsQuickCustomization = True
                  OptionsData.DeletingConfirmation = False
                  OptionsView.CellAutoHeight = True
                  OptionsView.GroupByBox = False
                  OptionsView.Header = False
                  Styles.Content = Tablo.cxStyle1
                  object cxGridDBCevrimID: TcxGridDBColumn
                    DataBinding.FieldName = 'ID'
                    DataBinding.IsNullValueType = True
                    Visible = False
                  end
                  object cxGridDBCevrimSTOKID: TcxGridDBColumn
                    DataBinding.FieldName = 'STOKID'
                    DataBinding.IsNullValueType = True
                    Visible = False
                  end
                  object cxGridDBCevrimADET1: TcxGridDBColumn
                    DataBinding.FieldName = 'ADET1'
                    DataBinding.IsNullValueType = True
                    PropertiesClassName = 'TcxTextEditProperties'
                  end
                  object cxGridDBCevrimBIRIM1: TcxGridDBColumn
                    DataBinding.FieldName = 'BIRIM1'
                    DataBinding.IsNullValueType = True
                    PropertiesClassName = 'TcxImageComboBoxProperties'
                    Properties.Items = <>
                    RepositoryItem = Tablo.repStokAnaBirim
                  end
                  object cxGridDBCevrimADET2: TcxGridDBColumn
                    DataBinding.FieldName = 'ADET2'
                    DataBinding.IsNullValueType = True
                    PropertiesClassName = 'TcxTextEditProperties'
                  end
                  object cxGridDBCevrimBIRIM2: TcxGridDBColumn
                    DataBinding.FieldName = 'BIRIM2'
                    DataBinding.IsNullValueType = True
                    PropertiesClassName = 'TcxImageComboBoxProperties'
                    Properties.Items = <>
                    RepositoryItem = Tablo.repStokAnaBirim
                  end
                end
                object cxGridLevel8: TcxGridLevel
                  GridView = cxGridDBCevrim
                end
              end
            end
            object TabSheetKalite: TcxTabSheet
              Caption = 'Kalite'
              ImageIndex = 3
              object ComboKALITEKONTROL: TcxDBComboBox
                Left = 93
                Top = 36
                DataBinding.DataField = 'KALITEKONTROL'
                Properties.ImmediatePost = True
                Properties.MaxLength = 0
                Properties.OnInitPopup = ComboKALITEKONTROLPropertiesInitPopup
                TabOrder = 0
                Width = 153
              end
              object LabelSablon: TcxLabel
                Left = 16
                Top = 37
                Cursor = crHandPoint
                Caption = #350'ablon Se'#231'iniz.'
                Style.TextColor = clMaroon
                Transparent = True
                OnClick = LabelSablonClick
              end
              object cxDBCheckBox3: TcxDBCheckBox
                Left = 90
                Top = 6
                Caption = 'Kalite Kontrol Aktif'
                DataBinding.DataField = 'KALITEKONTROLAKTIF'
                DataBinding.DataSource = DtsStok
                Properties.ImmediatePost = True
                TabOrder = 2
                Transparent = True
              end
            end
            object TabSheetYDil: TcxTabSheet
              Caption = 'Yabanc'#305' Dil'
              ImageIndex = 4
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object ToolBar4: TToolBar
                AlignWithMargins = True
                Left = 3
                Top = 3
                Width = 894
                Height = 24
                Margins.Bottom = 0
                Anchors = [akLeft]
                AutoSize = True
                ButtonWidth = 61
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
                PopupMenu = PopupStokCevrim
                ShowCaptions = True
                TabOrder = 0
                Transparent = True
                object YDilYeni: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'Yeni'
                  ImageIndex = 0
                  ImageName = 'PngImage0'
                  OnClick = YDilYeniClick
                end
                object YDilKaydet: TToolButton
                  Left = 61
                  Top = 0
                  Caption = 'Kaydet'
                  ImageIndex = 2
                  ImageName = 'PngImage2'
                  Visible = False
                  OnClick = YDilKaydetClick
                end
                object YDilSil: TToolButton
                  Left = 122
                  Top = 0
                  Caption = 'Sil'
                  ImageIndex = 1
                  ImageName = 'PngImage1'
                  OnClick = YDilSilClick
                end
                object YDilIptal: TToolButton
                  Left = 183
                  Top = 0
                  Caption = #304'ptal'
                  ImageIndex = 3
                  ImageName = 'PngImage3'
                  Visible = False
                  OnClick = YDilIptalClick
                end
              end
              object GridYDil: TcxGrid
                Left = 0
                Top = 27
                Width = 900
                Height = 84
                Align = alClient
                BevelInner = bvNone
                BevelOuter = bvNone
                Font.Charset = TURKISH_CHARSET
                Font.Color = clWindowText
                Font.Height = -12
                Font.Name = 'Trebuchet MS'
                Font.Style = []
                ParentFont = False
                TabOrder = 1
                LookAndFeel.Kind = lfStandard
                LookAndFeel.NativeStyle = True
                object GridYDilView: TcxGridDBTableView
                  PopupMenu = PopupStokCevrim
                  Navigator.Buttons.CustomButtons = <>
                  ScrollbarAnnotations.CustomAnnotations = <>
                  OnEditChanged = GridDetayViewEditChanged
                  DataController.DataModeController.SmartRefresh = True
                  DataController.DataSource = DtsYDil
                  DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                  DataController.Summary.DefaultGroupSummaryItems = <>
                  DataController.Summary.FooterSummaryItems = <>
                  DataController.Summary.SummaryGroups = <>
                  OptionsCustomize.ColumnsQuickCustomization = True
                  OptionsData.DeletingConfirmation = False
                  OptionsView.CellAutoHeight = True
                  OptionsView.GroupByBox = False
                  OptionsView.Header = False
                  Styles.Content = Tablo.cxStyle1
                  object GridYDilViewDIL: TcxGridDBColumn
                    Caption = 'Dil'
                    DataBinding.FieldName = 'DIL'
                    DataBinding.IsNullValueType = True
                    PropertiesClassName = 'TcxImageComboBoxProperties'
                    Properties.Items = <>
                    RepositoryItem = Tablo.RepDiller
                  end
                  object GridYDilViewBILGI: TcxGridDBColumn
                    Caption = 'Bilgi'
                    DataBinding.FieldName = 'BILGI'
                    DataBinding.IsNullValueType = True
                    Width = 600
                  end
                end
                object cxGridLevel9: TcxGridLevel
                  GridView = GridYDilView
                end
              end
            end
          end
          object SpinISK2: TcxDBSpinEdit
            Left = 553
            Top = 290
            DataBinding.DataField = 'ISK2'
            DataBinding.DataSource = DtsStok
            Properties.MaxValue = 100.000000000000000000
            TabOrder = 46
            Width = 46
          end
          object cxLabel9: TcxLabel
            Left = 423
            Top = 290
            Caption = #304'skonto'
            ParentColor = False
            ParentFont = False
            Style.Color = clWhite
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
          end
          object LogoResim: TcxDBImage
            Left = 680
            Top = 3
            DataBinding.DataField = 'RESIM'
            DataBinding.DataSource = DtsStok
            Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
            Properties.FitMode = ifmProportionalStretch
            Properties.GraphicClassName = 'TdxSmartImage'
            TabOrder = 62
            OnClick = cxDBImage1Click
            Height = 97
            Width = 128
          end
          object ComboKDV: TcxDBComboBox
            Tag = -2790
            Left = 92
            Top = 158
            RepositoryItem = Tablo.repStokKDV
            DataBinding.DataField = 'KDV'
            DataBinding.DataSource = DtsStok
            Properties.DropDownListStyle = lsFixedList
            Properties.ReadOnly = False
            TabOrder = 30
            Width = 100
          end
          object Combo: TcxDBImageComboBox
            Left = 553
            Top = 211
            RepositoryItem = Tablo.RepStokKaynakUretimYeri
            DataBinding.DataField = 'URETICIID'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 53
            Width = 150
          end
          object cxLabel10: TcxLabel
            Left = 421
            Top = 214
            Cursor = crHandPoint
            Hint = 'StokKart_'#214'zellik'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.OZELLIK'
            Caption = 'Kaynak / '#220'retim Yeri'
            FocusControl = Combo
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
          object CbStkBytKmbn: TcxDBImageComboBox
            Left = 769
            Top = 291
            RepositoryItem = Tablo.repStokBoyutKombinasyonlar
            DataBinding.DataField = 'BOYUTGRUBU'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            TabOrder = 64
            Visible = False
            Width = 37
          end
          object cbIzleme: TcxDBImageComboBox
            Left = 92
            Top = 237
            RepositoryItem = Tablo.RepStokIzleme
            DataBinding.DataField = 'IZLEME'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            Properties.OnEditValueChanged = cbIzlemePropertiesEditValueChanged
            TabOrder = 34
            Width = 100
          end
          object EditKategori: TcxButtonEdit
            Left = 92
            Top = 54
            HelpType = htKeyword
            HelpKeyword = 'MASRAFID'
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
            Properties.OnButtonClick = EditKategoriPropertiesButtonClick
            TabOrder = 4
            Width = 100
          end
          object LabelKategori: TcxLabel
            Left = 193
            Top = 57
            Caption = '----'
            Transparent = True
          end
          object cxDBCheckBox1: TcxDBCheckBox
            Left = 598
            Top = 291
            Caption = #304'skontosuz'
            DataBinding.DataField = 'ISKONTOSUZ'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            TabOrder = 66
            Transparent = True
          end
          object ComboKULLANIM: TcxDBImageComboBox
            Left = 553
            Top = 107
            Hint = 'Ops_StokKart_Kullanim'
            DataBinding.DataField = 'KULLANIM'
            DataBinding.DataSource = DtsStok
            Properties.Items = <>
            TabOrder = 49
            Width = 121
          end
          object cxLabel11: TcxLabel
            Left = 420
            Top = 109
            Cursor = crHandPoint
            Caption = 'Kullan'#305'm '#350'ekli'
            FocusControl = ComboKULLANIM
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object CheckEKIPMAN: TcxDBCheckBox
            Left = 765
            Top = 203
            Caption = 'Ekipman'
            DataBinding.DataField = 'EKIPMAN'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            TabOrder = 68
            Transparent = True
            OnClick = CheckEKIPMANClick
          end
          object EditOTVMIKTAR: TcxDBTextEdit
            Left = 93
            Top = 184
            DataBinding.DataField = 'OTVMIKTAR'
            DataBinding.DataSource = DtsStok
            TabOrder = 32
            Width = 100
          end
          object ComboOTVYUZDE: TcxDBImageComboBox
            Left = 1
            Top = 183
            DataBinding.DataField = 'OTVYUZDE'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            TabOrder = 31
            Width = 90
          end
          object ComboMiktarSecimi: TcxDBImageComboBox
            Left = 92
            Top = 263
            DataBinding.DataField = 'MIKTARSEC'
            DataBinding.DataSource = DtsStok
            Properties.Items = <
              item
                Description = '1 Adet'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Girilen Adet Kadar'
                Value = 2
              end>
            Properties.OnEditValueChanged = cbIzlemePropertiesEditValueChanged
            TabOrder = 35
            Width = 100
          end
          object LabelMiktarSecimi: TcxLabel
            Left = 1
            Top = 267
            Caption = 'Miktar Se'#231'imi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Properties.WordWrap = True
            Transparent = True
            Width = 71
          end
          object cxDBCheckBox2: TcxDBCheckBox
            Left = 765
            Top = 228
            Caption = #304'nternet Sat'#305#351'l'#305
            DataBinding.DataField = 'INTERNET_SATIS'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            TabOrder = 70
            Transparent = True
          end
          object cxLabel12: TcxLabel
            Left = 698
            Top = 267
            Caption = 'Temin S'#252'resi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxDBSpinEdit3: TcxDBSpinEdit
            Left = 769
            Top = 264
            DataBinding.DataField = 'TEMINSURESI'
            DataBinding.DataSource = DtsStok
            TabOrder = 47
            Width = 68
          end
          object cxLabel13: TcxLabel
            Left = 841
            Top = 268
            Caption = 'g'#252'n'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel14: TcxLabel
            Left = 200
            Top = 265
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
          object EditOZELKOD2: TcxDBTextEdit
            Left = 283
            Top = 264
            DataBinding.DataField = 'OZELKOD2'
            DataBinding.DataSource = DtsStok
            TabOrder = 43
            Width = 132
          end
          object ComboBILDIRIM: TcxDBImageComboBox
            Left = 553
            Top = 54
            DataBinding.DataField = 'BILDIRIM'
            DataBinding.DataSource = DtsStok
            Properties.Items = <
              item
                Description = 'Yok'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = #220'TS'
                Value = 2
              end>
            Properties.OnChange = ComboBILDIRIMPropertiesChange
            TabOrder = 45
            Width = 121
          end
          object LabelBildirim: TcxLabel
            Left = 420
            Top = 56
            Cursor = crHandPoint
            Hint = 'StokKart_Durum'
            Caption = 'Bildirim'
            FocusControl = ComboBILDIRIM
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object CheckKota: TcxDBCheckBox
            Left = 764
            Top = 150
            Align = alCustom
            Caption = 'Kota'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CheckPaketPropertiesEditValueChanged
            TabOrder = 75
            Transparent = True
            OnEditing = CheckPaketEditing
          end
          object CheckPaket: TcxDBCheckBox
            Left = 765
            Top = 176
            Align = alCustom
            Caption = 'Paket'
            DataBinding.DataField = 'PAKET'
            DataBinding.DataSource = DtsStok
            Properties.ImmediatePost = True
            Properties.OnEditValueChanged = CheckPaketPropertiesEditValueChanged
            TabOrder = 76
            Transparent = True
            OnEditing = CheckPaketEditing
          end
          object LblGTIP: TcxLabel
            Left = 421
            Top = 4
            Cursor = crHandPoint
            Hint = 'StokKart_Durum'
            Caption = 'GTIP'
            FocusControl = ComboDURUM
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditURUNNO: TcxDBTextEdit
            Left = 312
            Top = 2
            Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
            Align = alCustom
            DataBinding.DataField = 'URUNNO'
            ParentShowHint = False
            ShowHint = True
            StyleDisabled.BorderColor = clWindowFrame
            StyleDisabled.Color = clWindow
            StyleDisabled.TextColor = clWindowText
            TabOrder = 2
            Width = 103
          end
          object LabelURUNNO: TcxLabel
            Left = 268
            Top = 3
            Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
            Caption = #220'r'#252'n No'
            ParentFont = False
            ParentShowHint = False
            ShowHint = True
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object LabelID: TcxDBLabel
            Left = 858
            Top = 4
            Align = alCustom
            DataBinding.DataField = 'ID'
            DataBinding.DataSource = DtsStok
            Transparent = True
            Height = 17
            Width = 47
          end
          object KodAgaciTus: TcxButton
            Left = 245
            Top = 1
            Width = 25
            Height = 23
            Align = alCustom
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
            TabOrder = 80
            OnClick = btnkodbelirleClick
          end
          object EditKOD: TcxDBTextEdit
            Left = 91
            Top = 2
            Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
            Align = alCustom
            DataBinding.DataField = 'KOD'
            DataBinding.DataSource = DtsStok
            Enabled = False
            ParentShowHint = False
            ShowHint = True
            StyleDisabled.BorderColor = clWindowFrame
            StyleDisabled.Color = clWindow
            StyleDisabled.TextColor = clWindowText
            TabOrder = 1
            Width = 152
          end
          object cxLabel15: TcxLabel
            Left = 200
            Top = 213
            Caption = 'Raf (H'#252'cre)'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxDBTextEdit4: TcxDBTextEdit
            Left = 283
            Top = 212
            DataBinding.DataField = 'HUCRE'
            DataBinding.DataSource = DtsStok
            TabOrder = 40
            Width = 132
          end
        end
        object TabSheetUTS: TcxTabSheet
          Caption = #220'TS Bilgileri'
          ImageIndex = 3
          object cxLabel16: TcxLabel
            Left = 21
            Top = 21
            Hint = 'StokKart_Durum'
            Caption = 'SUT Kodu'
            FocusControl = ComboMEDIKALSINIF
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel17: TcxLabel
            Left = 20
            Top = 224
            Cursor = crHandPoint
            Hint = 'StokKart_MedikalSinif'
            HelpType = htKeyword
            HelpKeyword = 'STOKLAR.MEDIKALSINIF'
            Caption = 'S'#305'n'#305'f'
            FocusControl = ComboMEDIKALSINIF
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
          object EditSUTKODU: TcxDBTextEdit
            Left = 153
            Top = 17
            DataBinding.DataField = 'SUTKODU'
            TabOrder = 2
            Width = 152
          end
          object ComboMEDIKALSINIF: TcxDBImageComboBox
            Left = 153
            Top = 222
            RepositoryItem = Tablo.RepMedikalSinif
            DataBinding.DataField = 'MEDIKALSINIF'
            Properties.Items = <
              item
                ImageIndex = 0
              end>
            TabOrder = 9
            Width = 152
          end
          object cxLabel18: TcxLabel
            Left = 21
            Top = 282
            Hint = 'StokKart_Durum'
            Caption = 'Men'#351'ei '#220'lke'
            FocusControl = ComboITHALIMAL
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel19: TcxLabel
            Left = 20
            Top = 252
            Hint = 'StokKart_Durum'
            Caption = #304'thal/'#304'mal'
            FocusControl = ComboITHALIMAL
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object ComboITHALIMAL: TcxDBImageComboBox
            Left = 153
            Top = 250
            DataBinding.DataField = 'ITHALIMAL'
            Properties.Items = <
              item
                Description = #304'thal'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = #304'mal'
                Value = 1
              end>
            TabOrder = 10
            Width = 152
          end
          object cxLabel20: TcxLabel
            Left = 21
            Top = 141
            Hint = 'StokKart_Durum'
            Caption = 'GMDN'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditGMDN: TcxDBTextEdit
            Left = 153
            Top = 137
            DataBinding.DataField = 'GMDN'
            TabOrder = 6
            Width = 152
          end
          object cxLabel22: TcxLabel
            Left = 21
            Top = 50
            Hint = 'StokKart_Durum'
            Caption = 'Bran'#351' Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditBRANSKODU: TcxDBTextEdit
            Left = 153
            Top = 46
            DataBinding.DataField = 'BRANSKODU'
            TabOrder = 3
            Width = 152
          end
          object cxLabel24: TcxLabel
            Left = 21
            Top = 169
            Hint = 'StokKart_Durum'
            Caption = 'GMDN Ad'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditGMDNADI: TcxDBTextEdit
            Left = 153
            Top = 165
            DataBinding.DataField = 'GMDNADI'
            TabOrder = 7
            Width = 320
          end
          object ComboMENSEIULKE: TcxDBImageComboBox
            Left = 153
            Top = 280
            DataBinding.DataField = 'MENSEIULKE'
            Properties.Items = <>
            TabOrder = 11
            Width = 152
          end
          object EditDIGERURUNADI: TcxDBTextEdit
            Left = 153
            Top = 193
            DataBinding.DataField = 'DIGERURUNADI'
            TabOrder = 8
            Width = 320
          end
          object cxLabel21: TcxLabel
            Left = 21
            Top = 197
            Hint = 'StokKart_Durum'
            Caption = 'Di'#287'er '#220'r'#252'n Ad'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel23: TcxLabel
            Left = 21
            Top = 80
            Hint = 'StokKart_Durum'
            Caption = #220'TS REF (Katalog No)'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditUTSREF: TcxDBTextEdit
            Left = 153
            Top = 76
            DataBinding.DataField = 'UTSREF'
            TabOrder = 4
            Width = 152
          end
          object cxLabel25: TcxLabel
            Left = 21
            Top = 110
            Hint = 'StokKart_Durum'
            Caption = 'FTN'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditFTN: TcxDBTextEdit
            Left = 153
            Top = 106
            DataBinding.DataField = 'FTN'
            TabOrder = 5
            Width = 152
          end
          object cxLabel26: TcxLabel
            Left = 21
            Top = 314
            Hint = 'StokKart_Durum'
            Caption = #304'hale S'#305'ra No'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditIHALESIRANO: TcxDBTextEdit
            Left = 153
            Top = 310
            DataBinding.DataField = 'IHALESIRANO'
            TabOrder = 12
            Width = 152
          end
          object cxLabel27: TcxLabel
            Left = 21
            Top = 344
            Hint = 'StokKart_Durum'
            Caption = 'DMO '#350'artname Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditSMKODU: TcxDBTextEdit
            Left = 359
            Top = 340
            DataBinding.DataField = 'SMKODU'
            TabOrder = 14
            Width = 114
          end
          object cxLabel28: TcxLabel
            Left = 310
            Top = 344
            Hint = 'StokKart_Durum'
            Caption = 'SM Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object EditDMOKODU: TcxDBTextEdit
            Left = 153
            Top = 340
            DataBinding.DataField = 'DMOKODU'
            TabOrder = 13
            Width = 152
          end
        end
        object TabSheetMuhasebeHesaplari: TcxTabSheet
          Caption = 'Muhasebe Hesaplar'#305
          ImageIndex = 2
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object v: TcxGrid
            Left = 0
            Top = 24
            Width = 908
            Height = 412
            Align = alClient
            TabOrder = 0
            LookAndFeel.NativeStyle = False
            object vTableView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsStokMuhasebe
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              object vTableViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewMUHASEBEID: TcxGridDBColumn
                DataBinding.FieldName = 'MUHASEBEID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewHESAPID: TcxGridDBColumn
                DataBinding.FieldName = 'HESAPID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewMASRAFID: TcxGridDBColumn
                DataBinding.FieldName = 'MASRAFID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewEKLEYEN: TcxGridDBColumn
                DataBinding.FieldName = 'EKLEYEN'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewEKLEMETARIHI: TcxGridDBColumn
                DataBinding.FieldName = 'EKLEMETARIHI'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewDEGISTIREN: TcxGridDBColumn
                DataBinding.FieldName = 'DEGISTIREN'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewDEGISTIRMETARIHI: TcxGridDBColumn
                DataBinding.FieldName = 'DEGISTIRMETARIHI'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object vTableViewTURADI: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TURADI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 269
              end
              object vTableViewHESAPKODU: TcxGridDBColumn
                Caption = 'Hesap Kodu'
                DataBinding.FieldName = 'HESAPKODU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = GridMuhasebeHesaplariTableViewHESAPKODUPropertiesButtonClick
                Width = 75
              end
              object vTableViewHESAPADI: TcxGridDBColumn
                Caption = 'Hesap Ad'#305
                DataBinding.FieldName = 'HESAPADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = GridMuhasebeHesaplariTableViewHESAPKODUPropertiesButtonClick
                Width = 185
              end
              object vTableViewMASRAFKODU: TcxGridDBColumn
                Caption = 'Masraf Kodu'
                DataBinding.FieldName = 'MASRAFKODU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = GridMuhasebeHesaplariTableViewMASRAFKODUPropertiesButtonClick
                Width = 76
              end
              object vTableViewMASRAFADI: TcxGridDBColumn
                Caption = 'Masraf Ad'#305
                DataBinding.FieldName = 'MASRAFADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Properties.OnButtonClick = GridMuhasebeHesaplariTableViewMASRAFKODUPropertiesButtonClick
                Width = 185
              end
              object vTableViewDEGER: TcxGridDBColumn
                DataBinding.FieldName = 'DEGER'
                DataBinding.IsNullValueType = True
                Visible = False
              end
            end
            object vLevel1: TcxGridLevel
              GridView = vTableView
            end
          end
          object ToolBar2: TToolBar
            Left = 0
            Top = 0
            Width = 908
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
            TabOrder = 1
            Transparent = True
            object ToolButton11: TToolButton
              Left = 0
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsTextButton
              Visible = False
              OnClick = ToolButton11Click
            end
            object ToolButton13: TToolButton
              Left = 62
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Style = tbsTextButton
              Visible = False
              OnClick = ToolButton13Click
            end
          end
        end
        object EkAlanlarEkr: TcxTabSheet
          Caption = 'Ek Alanlar'
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
        end
      end
    end
    object BarkodEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Barkod Tan'#305'mlar'#305
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'Barkod Tan'#305'mlar'#305
      OnEnterPage = BarkodEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar5: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 910
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
        object BarkodEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = BarkodEkleTusClick
        end
        object BarkodSilTus: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = BarkodSilTusClick
        end
        object BarkodKaydetTus: TToolButton
          Left = 124
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsTextButton
          Visible = False
          OnClick = BarkodKaydetTusClick
        end
        object BarkodIptalTus: TToolButton
          Left = 186
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Style = tbsTextButton
          Visible = False
          OnClick = BarkodIptalTusClick
        end
      end
      object gridStokBarkod: TcxGrid
        Left = 0
        Top = 97
        Width = 916
        Height = 440
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object tvStokBarkod: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsBarkod
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object tvStokBarkodColumn1: TcxGridDBColumn
            Caption = 'Id'
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
            Options.Editing = False
          end
          object tvStokBarkodColumn5: TcxGridDBColumn
            Caption = 'Varsay'#305'lan'
            DataBinding.FieldName = 'VARSAYILAN'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 58
          end
          object tvStokBarkodColumn2: TcxGridDBColumn
            Caption = 'Barkod No'
            DataBinding.FieldName = 'BARKOD'
            DataBinding.IsNullValueType = True
            Width = 209
          end
          object tvStokBarkodColumn3: TcxGridDBColumn
            Caption = 'Barkod Tipi'
            DataBinding.FieldName = 'BARKODTIPI'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepStokKartBarkodAyarlar
          end
          object clmBarkodBirim: TcxGridDBColumn
            Caption = 'Barkod Birimi'
            DataBinding.FieldName = 'BARKODBIRIMI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.ImmediatePost = True
            Properties.Items = <>
            Properties.OnInitPopup = clmBarkodBirimPropertiesInitPopup
            Width = 75
          end
        end
        object cxGridLevel4: TcxGridLevel
          GridView = tvStokBarkod
        end
      end
    end
    object IsOrtagiEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #304#351' Orta'#287#305' Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'IsOrtagiEkr'
      OnEnterPage = IsOrtagiEkrEnterPage
      object ToolBar6: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 910
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
        object IOYeniTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = IOYeniTusClick
        end
        object IOSil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = IOSilClick
        end
        object ToolButton1: TToolButton
          Left = 124
          Top = 0
          Width = 13
          Caption = 'ToolButton1'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsSeparator
        end
        object IOKaydet: TToolButton
          Left = 137
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = IOKaydetClick
        end
        object IOiptal: TToolButton
          Left = 199
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = IOiptalClick
        end
        object cxLabel4: TcxLabel
          Left = 261
          Top = 1
          Caption = '             '
          Transparent = True
        end
      end
      object isOrtagiGrid: TcxGrid
        Left = 0
        Top = 97
        Width = 916
        Height = 440
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object isOrtagiGridTV: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsIsOrtagi
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object isOrtagiGridTVFIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 242
          end
          object isOrtagiGridTVILISKI: TcxGridDBColumn
            Caption = #304'li'#351'ki'
            DataBinding.FieldName = 'ILISKI'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepisOrtagiiliskiTuru
            Width = 111
          end
        end
        object cxGridLevel5: TcxGridLevel
          GridView = isOrtagiGridTV
        end
      end
    end
    object EsdegerEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'E'#351'de'#287'er Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      object StokEsdeger: TcxGrid
        Left = 0
        Top = 97
        Width = 916
        Height = 440
        Align = alClient
        PopupMenu = PopupMenuEsdeger
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object StokEsdegerTV: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsStokEsdeger
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object StokEsdegerTVTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepStokEsdegerTur
            Options.Editing = False
          end
          object StokEsdegerTVKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 94
          end
          object StokEsdegerTVSTOKADI: TcxGridDBColumn
            Caption = 'Stok Ad'#305
            DataBinding.FieldName = 'STOKADI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 239
          end
          object StokEsdegerTVACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.Editing = False
            Width = 270
          end
        end
        object cxGridLevel6: TcxGridLevel
          GridView = StokEsdegerTV
        end
      end
      object ToolBar7: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 910
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
        object EkleStokEsdeger: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = EkleStokEsdegerClick
        end
        object SilStokEsdeger: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = SilStokEsdegerClick
        end
        object ToolButton5: TToolButton
          Left = 124
          Top = 0
          Width = 13
          Caption = 'ToolButton1'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsSeparator
        end
        object KaydetStokEsdeger: TToolButton
          Left = 137
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = KaydetStokEsdegerClick
        end
        object iptalStokEsdeger: TToolButton
          Left = 199
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = iptalStokEsdegerClick
        end
        object cxLabel6: TcxLabel
          Left = 261
          Top = 1
          Caption = '             '
          Transparent = True
        end
      end
    end
    object FiyatEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Fiyat Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Text = 'Alta yeni '#246'zellik ekyebilirsiniz'
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      OnEnterPage = FiyatEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PnlFiyat: TPanel
        Left = 0
        Top = 70
        Width = 481
        Height = 467
        Align = alLeft
        TabOrder = 0
        object GridFiyat: TcxGrid
          Left = 1
          Top = 28
          Width = 479
          Height = 438
          Align = alClient
          PopupMenu = PmHesapla
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          object GridFiyatView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsFiyat
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridFiyatViewFIYATADIALIS: TcxGridDBColumn
              Caption = 'Fiyat Ad'#305
              DataBinding.FieldName = 'FIYATADI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepFiyatAdlariAlis
              Options.Editing = False
              Width = 65
            end
            object GridFiyatViewFIYATADI: TcxGridDBColumn
              Caption = 'Fiyat Ad'#305
              DataBinding.FieldName = 'FIYATADI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepFiyatAdlari
              Options.Editing = False
              Width = 73
            end
            object GridFiyatViewBIRIM: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
              Options.Editing = False
            end
            object GridFiyatViewFIYAT: TcxGridDBColumn
              Caption = 'Fiyat'
              DataBinding.FieldName = 'FIYAT'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
              Width = 58
            end
            object GridFiyatViewKUR: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              Width = 43
            end
            object GridFiyatViewKDVDurum: TcxGridDBColumn
              Caption = 'KDV Durumu'
              DataBinding.FieldName = 'KDVDURUM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepKDVDurum
              Width = 65
            end
            object GridFiyatViewSatis: TcxGridDBColumn
              DataBinding.FieldName = 'SATIS'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridFiyatViewColumn1: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'DEGISTIRMETARIHI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxDateEditProperties'
              Properties.ReadOnly = True
            end
          end
          object GridFiyatLevel1: TcxGridLevel
            GridView = GridFiyatView
          end
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 473
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
          object FiyatEkleTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
            Visible = False
            OnClick = FiyatEkleTusClick
          end
          object FiyatSilTus: TToolButton
            Left = 62
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            Visible = False
            OnClick = FiyatSilTusClick
          end
          object FiyatKaydetTus: TToolButton
            Left = 124
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsTextButton
            Visible = False
            OnClick = FiyatKaydetTusClick
          end
          object FiyatIptalTus: TToolButton
            Left = 186
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            Style = tbsTextButton
            Visible = False
            OnClick = FiyatIptalTusClick
          end
          object ComboSatis: TcxImageComboBox
            Left = 248
            Top = 0
            EditValue = '1'
            Properties.ImmediatePost = True
            Properties.Items = <
              item
                Description = 'Al'#305#351
                ImageIndex = 0
                Value = '0'
              end
              item
                Description = 'Sat'#305#351
                Value = '1'
              end>
            Properties.OnChange = cxImageComboBox2PropertiesChange
            TabOrder = 0
            Width = 82
          end
        end
      end
      object PnlKampanya: TPanel
        Left = 481
        Top = 70
        Width = 435
        Height = 467
        Align = alClient
        TabOrder = 1
        object GridKampanya: TcxGrid
          Left = 1
          Top = 28
          Width = 433
          Height = 438
          Align = alClient
          PopupMenu = PmHesapla
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          object GridKampanyaView: TcxGridDBTableView
            OnDblClick = GridKampanyaViewDblClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsKampanya
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridKampanyaKODU: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KODU'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 81
            end
            object GridKampanyaADI: TcxGridDBColumn
              Caption = 'Ad'#305
              DataBinding.FieldName = 'ADI'
              DataBinding.IsNullValueType = True
              Options.Editing = False
              Width = 129
            end
            object GridKampanyaACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 106
            end
          end
          object cxGridLevel7: TcxGridLevel
            GridView = GridKampanyaView
          end
        end
        object ToolBar9: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 427
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 101
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
          object KampanyaEkle: TToolButton
            Left = 0
            Top = 0
            AutoSize = True
            Caption = 'Ekle    '
            ImageIndex = 0
            ImageName = 'PngImage0'
            Style = tbsTextButton
            OnClick = KampanyaEkleClick
          end
          object KampanyaSil: TToolButton
            Left = 63
            Top = 0
            AutoSize = True
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = KampanyaSilClick
          end
          object KampanyaKaydet: TToolButton
            Left = 104
            Top = 0
            AutoSize = True
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsTextButton
            Visible = False
            OnClick = KampanyaKaydetClick
          end
          object ToolButton4: TToolButton
            Left = 170
            Top = 0
            Width = 8
            Caption = 'ToolButton4'
            ImageIndex = 1
            ImageName = 'PngImage1'
            Style = tbsSeparator
          end
          object YeniKampanyaOlustur: TToolButton
            Left = 178
            Top = 0
            AutoSize = True
            Caption = 'Yeni Kampanya'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = YeniKampanyaOlusturClick
          end
          object KampanyaIptal: TToolButton
            Left = 283
            Top = 0
            Width = 8
            Caption = 'KampanyaIptal'
            ImageIndex = 1
            ImageName = 'PngImage1'
            Style = tbsSeparator
            Visible = False
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
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      OnEnterPage = DokumanEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel6: TPanel
        Left = 0
        Top = 496
        Width = 916
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
          Width = 768
        end
        object BtnMesajGonder: TcxButton
          Left = 769
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
          Left = 854
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
        Top = 476
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
        ExplicitTop = 475
        AnchorX = 916
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 916
        Height = 406
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
    object PaketEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Paket Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      OnEnterPage = PaketEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel2: TPanel
        Left = 469
        Top = 70
        Width = 447
        Height = 467
        Align = alClient
        TabOrder = 1
        object GridPaketFiyat: TcxGrid
          Left = 1
          Top = 41
          Width = 445
          Height = 161
          Align = alTop
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          object GridPaketFiyatView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsPaketFiyatlar
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsSelection.HideSelection = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object cxGridDBColumn1: TcxGridDBColumn
              Caption = 'Fiyat Ad'#305
              DataBinding.FieldName = 'FIYATADI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepFiyatAdlari
              Options.Editing = False
            end
            object cxGridDBColumn2: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
              Options.Editing = False
            end
            object cxGridDBColumn3: TcxGridDBColumn
              Caption = 'Fiyat'
              DataBinding.FieldName = 'FIYAT'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
              Options.Editing = False
              Width = 57
            end
            object cxGridDBColumn4: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
              Options.Editing = False
              Width = 43
            end
            object cxGridDBColumn5: TcxGridDBColumn
              Caption = 'KDV Durumu'
              DataBinding.FieldName = 'KDVDURUM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepKDVDurum
              Options.Editing = False
              Width = 71
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = GridPaketFiyatView
          end
        end
        object GridPaketTutar: TcxGrid
          Left = 1
          Top = 226
          Width = 445
          Height = 240
          Align = alClient
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          object GridPaketTutarView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsPaketTopTutar
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsView.GroupByBox = False
            object GridPaketTutarViewANAHTAR: TcxGridDBColumn
              Caption = 'Fiyat'
              DataBinding.FieldName = 'FIYATADI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepFiyatAdlari
              Options.Editing = False
              Width = 98
            end
            object GridPaketTutarViewTOPLAM: TcxGridDBColumn
              Caption = 'Toplam Tutar'
              DataBinding.FieldName = 'TOPLAM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
              Options.Editing = False
              Width = 121
            end
            object GridPaketTutarViewKUR: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Options.Editing = False
            end
          end
          object cxGridLevel3: TcxGridLevel
            GridView = GridPaketTutarView
          end
        end
        object JvNavPanelHeader1: TJvNavPanelHeader
          Left = 1
          Top = 202
          Width = 445
          Height = 24
          Align = alTop
          Caption = 'Paket Toplam Tutar'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          ColorFrom = 14540253
          ColorTo = 11776947
          ImageIndex = 0
        end
        object JvNavPanelHeader2: TJvNavPanelHeader
          Left = 1
          Top = 1
          Width = 445
          Height = 40
          Align = alTop
          Caption = 'Birim Fiyatlar'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          ColorFrom = 14540253
          ColorTo = 11776947
          ImageIndex = 0
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 70
        Width = 469
        Height = 467
        Align = alLeft
        TabOrder = 0
        object GridPaket: TcxGrid
          Left = 1
          Top = 42
          Width = 467
          Height = 424
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          object GridPaketView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsPaketKartlar
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Appending = True
            OptionsData.Deleting = False
            OptionsView.GroupByBox = False
            object GridPaketViewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridPaketViewPAKET: TcxGridDBColumn
              Caption = 'Ana'
              DataBinding.FieldName = 'PAKET'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ReadOnly = True
              Properties.ValueChecked = '1'
              Properties.ValueUnchecked = '0'
              Options.Editing = False
            end
            object GridPaketViewKOD: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxLabelProperties'
              Options.Editing = False
              Width = 78
            end
            object GridPaketViewAD: TcxGridDBColumn
              Caption = 'Ad'
              DataBinding.FieldName = 'AD'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxLabelProperties'
              Options.Editing = False
              Width = 158
            end
            object GridPaketViewBIRIM: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
              Options.Editing = False
              Width = 73
            end
            object GridPaketViewADET: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxButtonEditProperties'
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = GridPaketViewADETPropertiesButtonClick
              Width = 31
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = GridPaketView
          end
        end
        object Panel8: TPanel
          Left = 1
          Top = 1
          Width = 467
          Height = 41
          Align = alTop
          TabOrder = 1
          object ToolBar1: TToolBar
            Left = 1
            Top = 1
            Width = 104
            Height = 39
            Margins.Bottom = 0
            Align = alLeft
            AutoSize = True
            ButtonHeight = 37
            ButtonWidth = 52
            Caption = 'AletCubugu'
            Color = clTeal
            DoubleBuffered = True
            DockSite = True
            DrawingStyle = dsGradient
            EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
            EdgeInner = esNone
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
            ParentColor = False
            ParentDoubleBuffered = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            Transparent = True
            object BtnYeniPaketKart: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni Stok'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = BtnYeniPaketKartClick
            end
            object BtnSilPaketKart: TToolButton
              Left = 52
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = BtnSilPaketKartClick
            end
          end
          object JvNavPanelHeader3: TJvNavPanelHeader
            Left = 105
            Top = 1
            Width = 361
            Height = 39
            Align = alClient
            Font.Charset = TURKISH_CHARSET
            Font.Color = clRed
            Font.Height = -13
            Font.Name = 'Trebuchet MS'
            Font.Style = [fsBold]
            ParentFont = False
            ColorFrom = 14540253
            ColorTo = 11776947
            ImageIndex = 0
            object CheckPAKET2: TcxDBCheckBox
              Left = 0
              Top = 0
              Align = alLeft
              Caption = 'Paket'
              DataBinding.DataField = 'PAKET'
              DataBinding.DataSource = DtsStok
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = CheckPaketPropertiesEditValueChanged
              Style.LookAndFeel.NativeStyle = True
              StyleDisabled.LookAndFeel.NativeStyle = True
              StyleFocused.LookAndFeel.NativeStyle = True
              StyleHot.LookAndFeel.NativeStyle = True
              StyleReadOnly.LookAndFeel.NativeStyle = True
              TabOrder = 0
              Transparent = True
              OnClick = CheckPAKET2Click
              OnEditing = CheckPaketEditing
            end
          end
        end
      end
    end
    object DetayEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Detay Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridKurIlet: TcxGrid
        Left = 0
        Top = 97
        Width = 916
        Height = 440
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
          PopupMenu = PopupDetayIslemleri
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
          object cxGridDBColumn6: TcxGridDBColumn
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
          object cxGridDBColumn7: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            OnGetPropertiesForEdit = cxGridDBColumn7GetPropertiesForEdit
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
          object GridDetayViewRESIM: TcxGridDBColumn
            DataBinding.FieldName = 'RESIM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageProperties'
            Properties.GraphicClassName = 'TdxSmartImage'
            Properties.ImmediatePost = True
          end
        end
        object cxGridDetay: TcxGridLevel
          GridView = GridDetayView
        end
      end
      object ToolBar8: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 910
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
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
      end
      object ComboBolum: TcxDBComboBox
        Left = 83
        Top = 37
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsStok
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.OnEditValueChanged = ComboBolumPropertiesEditValueChanged
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
          '                [ZORUNLU] [bit] NULL,'
          '                [RBID] [int] NULL,'
          '                [RESIM] [image] NULL,'
          '                [ESKIRESIM] [image] NULL'
          ')'
          'INSERT INTO #DETAY_:SPID_'
          'select '
          'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU,RB.ID,RR.RESIM,RR.RESIM  '
          'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
          'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI left outer join '
          'REHBERBILGIRESIM RR on RB.ID=RR.REHBERBILGIID'
          'where RB.YERI= @yeri and YER_ID= @yerid '
          'and isnull(RA.BOLUM,'#39#39')=@bolum '
          ''
          'union all'
          ''
          
            'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
            ' '
          ',null,null,null '
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
    object KotaEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Kota Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'KotaEkr'
      OnEnterPage = KotaEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar10: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 910
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 61
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
        object BtnKotaYeni: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = BtnKotaYeniClick
        end
        object BtnKotaSil: TToolButton
          Left = 61
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = BtnKotaSilClick
        end
        object BtnKotaKaydet: TToolButton
          Left = 122
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          OnClick = BtnKotaKaydetClick
        end
        object BtnKotaIptal: TToolButton
          Left = 183
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          OnClick = BtnKotaIptalClick
        end
      end
      object cxGrid4: TcxGrid
        Left = 0
        Top = 97
        Width = 916
        Height = 440
        Align = alClient
        TabOrder = 1
        object cxGrid4DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsKota
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skSum
              FieldName = 'MIKTAR'
              Column = cxGrid4DBTableView1MIKTAR
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsView.Footer = True
          OptionsView.GroupByBox = False
          object cxGrid4DBTableView1FIRMA: TcxGridDBColumn
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxLabelProperties'
            Width = 193
          end
          object cxGrid4DBTableView1MIKTAR: TcxGridDBColumn
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 83
          end
          object cxGrid4DBTableView1ACIKLAMA: TcxGridDBColumn
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 461
          end
        end
        object cxGrid4Level1: TcxGridLevel
          GridView = cxGrid4DBTableView1
        end
      end
    end
    object KategoriEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Boyut Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Visible = False
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'Boyut Ekran'#305
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel5: TPanel
        Left = 0
        Top = 70
        Width = 916
        Height = 235
        Align = alTop
        TabOrder = 0
        object GridStokBoyut: TcxGrid
          Left = 1
          Top = 25
          Width = 914
          Height = 209
          Align = alClient
          TabOrder = 0
          object GridStokBoyutDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsStokBoyut
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsSelection.CellSelect = False
            OptionsView.GroupByBox = False
            object GridStokBoyutDBTableView1DEGER1: TcxGridDBColumn
              Caption = '1. Boyut'
              DataBinding.FieldName = 'DEGER1'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              Properties.ReadOnly = True
              Options.Editing = False
              Width = 175
            end
            object GridStokBoyutDBTableView1DEGER2: TcxGridDBColumn
              Caption = '2. Boyut'
              DataBinding.FieldName = 'DEGER2'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              Properties.ReadOnly = True
              Options.Editing = False
              Width = 171
            end
            object GridStokBoyutDBTableView1DEGER3: TcxGridDBColumn
              Caption = '3. Boyut'
              DataBinding.FieldName = 'DEGER3'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              Properties.ReadOnly = True
              Options.Editing = False
              Width = 185
            end
          end
          object GridStokBoyutLevel1: TcxGridLevel
            GridView = GridStokBoyutDBTableView1
          end
        end
        object TBStokKategori: TToolBar
          Left = 1
          Top = 1
          Width = 914
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 84
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
          object ToolButton9: TToolButton
            Left = 0
            Top = 0
            Caption = 'Ekle'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = ToolButton9Click
          end
          object BtnStkKtgrSil: TToolButton
            Left = 84
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = BtnStkKtgrSilClick
          end
          object BtnStkKtgrKaydet: TToolButton
            Left = 168
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            OnClick = BtnStkKtgrKaydetClick
          end
          object BtnStkKtgrIptal: TToolButton
            Left = 252
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            OnClick = BtnStkKtgrIptalClick
          end
          object BtnBarkodUret: TToolButton
            Left = 336
            Top = 0
            Caption = 'Barkod '#220'ret'
            DropdownMenu = PopupStokBoyutBarkod
            EnableDropdown = True
            ImageIndex = 20
            ImageName = 'PngImage20'
            Indeterminate = True
            OnClick = BtnBarkodUretClick
          end
          object BtnBarkodYazdir: TToolButton
            Left = 420
            Top = 0
            Caption = 'Yazd'#305'r'
            ImageIndex = 8
            ImageName = 'PngImage15'
            Indeterminate = True
            OnClick = BtnBarkodYazdirClick
          end
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 305
        Width = 916
        Height = 232
        Align = alClient
        TabOrder = 1
        object GridBarkod: TcxGrid
          Left = 1
          Top = 25
          Width = 914
          Height = 206
          Align = alClient
          TabOrder = 0
          object GridBarkodDBTableView4: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsBoyutBarkod
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsView.GroupByBox = False
            object GridBarkodDBTableView4BARKODTIPI: TcxGridDBColumn
              Caption = 'Tip'
              DataBinding.FieldName = 'BARKODTIPI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepStokKartBarkodAyarlar
              Width = 79
            end
            object GridBarkodDBTableView4BARKOD: TcxGridDBColumn
              Caption = 'Barkod'
              DataBinding.FieldName = 'BARKOD'
              DataBinding.IsNullValueType = True
              Width = 370
            end
            object GridBarkodDBTableView4BARKODBIRIMI: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BARKODBIRIMI'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
              Options.Editing = False
              Width = 69
            end
            object GridBarkodDBTableView4VARSAYILAN: TcxGridDBColumn
              Caption = 'Varsay'#305'lan'
              DataBinding.FieldName = 'VARSAYILAN'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.NullStyle = nssUnchecked
              Options.Editing = False
              Width = 57
            end
          end
          object GridBarkodLevel8: TcxGridLevel
            GridView = GridBarkodDBTableView4
          end
        end
        object ToolBar11: TToolBar
          Left = 1
          Top = 1
          Width = 914
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 61
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
          object ToolButton2: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 0
            ImageName = 'PngImage0'
          end
          object ToolButton6: TToolButton
            Left = 61
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = ToolButton6Click
          end
          object ToolButton7: TToolButton
            Left = 122
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            OnClick = ToolButton7Click
          end
          object ToolButton8: TToolButton
            Left = 183
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            OnClick = ToolButton8Click
          end
        end
      end
    end
    object EkstraEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Se'#231'imler'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      Caption = 'EkstraEkr'
      OnEnterPage = EkstraEkrEnterPage
      object ToolBar13: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 910
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
        object EkstraEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = EkstraEkleTusClick
        end
        object EkstraSilTus: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = EkstraSilTusClick
        end
        object ToolButton12: TToolButton
          Left = 124
          Top = 0
          Width = 13
          Caption = 'ToolButton1'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsSeparator
        end
        object EkstraKaydetTus: TToolButton
          Left = 137
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = EkstraKaydetTusClick
        end
        object EkstraIptalTus: TToolButton
          Left = 199
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = EkstraIptalTusClick
        end
        object cxLabel1: TcxLabel
          Left = 261
          Top = 1
          Caption = '             '
          Transparent = True
        end
      end
      object GridSecim: TcxGrid
        Left = 0
        Top = 97
        Width = 916
        Height = 440
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridSecimView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSecim
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridEkstraSecimACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'SECIMADI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.ReadOnly = True
            Width = 313
          end
          object GridEkstraSecimNOTLAR: TcxGridDBColumn
            Caption = 'S'#305'ra'
            DataBinding.FieldName = 'SIRA'
            DataBinding.IsNullValueType = True
            Width = 54
          end
        end
        object cxGridLevel11: TcxGridLevel
          GridView = GridSecimView
        end
      end
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 14
      Width = 121
    end
    object cxDBLabel2: TcxDBLabel
      Left = 198
      Top = 160
      DataBinding.DataField = 'KATEGORI'
      DataBinding.DataSource = DtsStok
      Height = 21
      Width = 30
    end
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT  ID, YERI, YER_ID,DURUM, ICDIS,BELGENO, BELGEADI, TUR, AC' +
        'IKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'YERI = :PYeri AND'
      'YER_ID=:PYer_ID')
    Left = 562
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 614
    Top = 56
  end
  object OpenDialog1: TOpenDialog
    Left = 840
    Top = 136
  end
  object TabStok: TFDQuery
    AfterOpen = TabStokAfterOpen
    BeforeClose = TabStokBeforeClose
    BeforeEdit = TabStokBeforeEdit
    BeforePost = TabStokBeforePost
    AfterPost = TabStokAfterPost
    OnNewRecord = TabStokNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      #9'* '
      'from '
      #9'STOKLAR'
      'where '
      #9'ID = :pID')
    Left = 51
    Top = 6
  end
  object DtsStok: TDataSource
    DataSet = TabStok
    Left = 5
    Top = 1
  end
  object DtsFiyat: TDataSource
    DataSet = TabFiyat
    OnStateChange = DtsFiyatStateChange
    Left = 681
    Top = 60
  end
  object TabFiyat: TFDQuery
    AutoCalcFields = False
    AfterOpen = TabFiyatAfterOpen
    BeforePost = TabFiyatBeforePost
    OnNewRecord = TabFiyatNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select * from STOKFIYAT Where STOKID=:A0 AND SATIS=:A1')
    Left = 607
    Top = 312
  end
  object TabPaketKartlar: TFDQuery
    AfterScroll = TabPaketKartlarAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @PaketID int'
      'set @PaketID = :PPaketID'
      ''
      'select '
      #9'S.PAKET, AD=S.STOKADI,S.KOD,PD.* '
      'from '
      #9'PAKETDETAY PD left outer join '
      #9'STOKLAR S on PD.URUNID=S.ID'
      'where PD.PAKETID=@PaketID '
      'and PD.STOK=1'
      ''
      ''
      'union all '
      ''
      'select '
      #9'PAKET=0, M.AD,M.KOD,PD.* '
      'from '
      #9'PAKETDETAY PD left outer join '
      #9'MASRAFGELIR M on PD.URUNID=M.ID'
      'where PD.PAKETID=@PaketID'
      'and PD.STOK=0 '
      ''
      ''
      ''
      'order by 1 desc, 4')
    Left = 617
    Top = 130
  end
  object DtsPaketKartlar: TDataSource
    DataSet = TabPaketKartlar
    Left = 786
    Top = 231
  end
  object TabPaketFiyatlar: TFDQuery
    AfterScroll = TabPaketFiyatlarAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      #9'*'
      'from '
      #9'STOKFIYAT'
      'where'
      #9'STOKID=:PStokID '
      '')
    Left = 334
    Top = 199
  end
  object DtsPaketFiyatlar: TDataSource
    DataSet = TabPaketFiyatlar
    Left = 702
    Top = 436
  end
  object TabPaketTopTutar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @PAKETID int, @FIYATID int'
      'set @PAKETID = :PID'
      'set @FIYATID = :FID'
      'SELECT FIYATADI,TOPLAM=SUM(ADET*FIYAT),KUR'
      'from'
      '('
      'select SF.FIYATADI,P.ADET,SF.FIYAT,SF.KUR'
      'from '
      #9'STOKLAR S inner join '
      #9'STOKFIYAT SF on S.ID=SF.STOKID inner join'
      #9'PAKETDETAY P on P.URUNID=S.ID and P.STOK=1'
      #9
      'where P.PAKETID=@PAKETID and SF.FIYATADI=@FIYATID'
      ''
      'union all'
      ' '
      'select F.FIYATADI,P.ADET,F.FIYAT,F.KUR'
      'from '
      #9'MASRAFGELIR H inner join '
      #9'FIYATLAR F on H.ID=F.HIZMETID inner join'
      #9'PAKETDETAY P on P.URUNID=H.ID and P.STOK=0'#9
      'where P.PAKETID=@PAKETID and F.FIYATADI=@FIYATID'
      ''
      ')as asd'
      'group by '
      #9'FIYATADI,KUR'
      'order by 1')
    Left = 624
    Top = 2
  end
  object DtsPaketTopTutar: TDataSource
    DataSet = TabPaketTopTutar
    Left = 551
    Top = 32
  end
  object TabBarkod: TFDQuery
    AutoCalcFields = False
    BeforePost = TabBarkodBeforePost
    AfterPost = TabBarkodAfterPost
    OnNewRecord = TabBarkodNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select * from STOKBARKOD'
      'Where '
      'STOKID = :PSTOKID '
      ''
      '')
    Left = 364
    Top = 8
  end
  object DtsBarkod: TDataSource
    DataSet = TabBarkod
    OnStateChange = DtsBarkodStateChange
    Left = 468
    Top = 190
  end
  object TabIsOrtagi: TFDQuery
    BeforePost = TabIsOrtagiBeforePost
    OnNewRecord = TabIsOrtagiNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select I.STOKID,I.REHBERID,I.ILISKI,I.EKLEYEN,I.EKLEMETARIHI,I.D' +
        'EGISTIREN,I.DEGISTIRMETARIHI,'
      'FIRMA=R.FIRMA'
      'from ISORTAGI I '
      ' left outer join REHBER R on R.ID=I.REHBERID Where I.STOKID=:SID')
    Left = 431
    Top = 4
  end
  object DtsIsOrtagi: TDataSource
    DataSet = TabIsOrtagi
    OnStateChange = DtsIsOrtagiStateChange
    Left = 415
    Top = 39
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 398
    Top = 323
  end
  object TabStokEsdeger: TFDQuery
    BeforePost = TabStokEsdegerBeforePost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Declare @PStokID int'
      'Set @PStokID=:PstokID'
      'Select SE.*,S.KOD,S.STOKADI from STOKESDEGER SE left outer join '
      'STOKLAR S on S.ID=SE.STOKESDEGERID Where SE.STOKID=@PStokID'
      'union all'
      'Select SE.*,S.KOD,S.STOKADI from STOKESDEGER SE left outer join '
      'STOKLAR S on S.ID=SE.STOKID Where SE.STOKESDEGERID=@PStokID'
      'and SE.TUR=1')
    Left = 700
    Top = 351
  end
  object DtsStokEsdeger: TDataSource
    DataSet = TabStokEsdeger
    Left = 373
    Top = 258
  end
  object DETAY: TFDQuery
    BeforePost = DETAYBeforePost
    AfterScroll = DETAYAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 739
    Top = 13
  end
  object DtsDetay: TDataSource
    DataSet = DETAY
    Left = 739
    Top = 57
  end
  object PmHesapla: TPopupMenu
    Left = 303
    Top = 432
    object Hesapla1: TMenuItem
      Caption = 'Fiyat Hesapla'
      Visible = False
      OnClick = Hesapla1Click
    end
    object FiyatListeleri1: TMenuItem
      Caption = 'Fiyat Listeleri'
      Visible = False
      OnClick = FiyatListeleri1Click
    end
  end
  object TabKampanya: TFDQuery
    BeforePost = TabKampanyaBeforePost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select K.ID,K.KODU,K.ADI,K.ACIKLAMA, K.DEGISTIREN, K.DEGISTIRMET' +
        'ARIHI, K.EKLEYEN'
      'from KAMPANYA K'
      'where K.DURUM=1'
      'and ID in ('
      
        'select K.ID from KAMPANYA K left outer join KAMPANYAURUN KU2 on ' +
        'K.ID=KU2.KAMPANYAID where ISNULL(URUNID,0)=0'
      'union all'
      
        'select ID=KAMPANYAID from KAMPANYAURUN KU where KU.TUR=1 and KU.' +
        'URUNID=:StokID)')
    Left = 683
    Top = 20
  end
  object DtsKampanya: TDataSource
    DataSet = TabKampanya
    OnStateChange = DtsKampanyaStateChange
    Left = 698
    Top = 169
  end
  object TabKota: TFDQuery
    AutoCalcFields = False
    BeforePost = TabKotaBeforePost
    OnNewRecord = TabKotaNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SK.*,R.FIRMA '
      ''
      'from STOKKOTA SK left outer join REHBER R on SK.REHBERID=R.ID'
      ''
      'where SK.STOKID=:PSTOKID')
    Left = 900
    Top = 164
  end
  object DtsKota: TDataSource
    DataSet = TabKota
    OnStateChange = DtsKotaStateChange
    Left = 821
    Top = 437
  end
  object TabStokBoyut: TFDQuery
    AfterOpen = TabStokBoyutAfterOpen
    BeforePost = TabStokBoyutBeforePost
    AfterScroll = TabStokBoyutAfterScroll
    OnNewRecord = TabStokBoyutNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * '
      'from '
      '  STOKBOYUTKOMBINASYON '
      'where STOKID=:PStokID'
      ''
      'order by DEGER1,DEGER2,DEGER3')
    Left = 460
    Top = 285
  end
  object DtsStokBoyut: TDataSource
    DataSet = TabStokBoyut
    OnStateChange = DtsStokBoyutStateChange
    Left = 284
    Top = 26
  end
  object PmKopyala: TPopupMenu
    Left = 900
    Top = 25
    object Burayaekstralarkopyala1: TMenuItem
      Caption = 'Buraya Ekstralar'#305'  Kopyala'
      OnClick = Burayaekstralarkopyala1Click
    end
  end
  object TabBoyutBarkod: TFDQuery
    BeforePost = TabBoyutBarkodBeforePost
    OnNewRecord = TabBoyutBarkodNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * '
      'from '
      '  STOKBARKOD'
      'where YERI=342 and YERID=:PYerID')
    Left = 862
    Top = 28
  end
  object DtsBoyutBarkod: TDataSource
    DataSet = TabBoyutBarkod
    OnStateChange = DtsBoyutBarkodStateChange
    Left = 936
    Top = 221
  end
  object PopupStokBoyutBarkod: TPopupMenu
    Left = 499
    Top = 254
    object ret1: TMenuItem
      Caption = 'Numerik Barkod '#220'ret'
      object Bo1: TMenuItem
        Caption = 'Kullan'#305'c'#305
        OnClick = BtnBarkodUretClick
      end
    end
    object GrselBarkodret1: TMenuItem
      Caption = 'G'#246'rsel Barkod '#220'ret'
      OnClick = GrselBarkodret1Click
    end
    object VarsaylanYap1: TMenuItem
      Caption = 'Varsay'#305'lan Yap'
    end
  end
  object PopupDetayIslemleri: TPopupMenu
    Left = 494
    Top = 11
    object DetayKopyala1: TMenuItem
      Caption = 'Detay Kopyala'
      OnClick = DetayKopyala1Click
    end
  end
  object DtsCevrim: TDataSource
    DataSet = TabCevrim
    OnStateChange = DtsCevrimStateChange
    Left = 685
    Top = 272
  end
  object TabCevrim: TFDQuery
    OnNewRecord = TabCevrimNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM STOKCEVRIM'
      'WHERE'
      'STOKID= :PID')
    Left = 509
    Top = 367
  end
  object DtsSecim: TDataSource
    DataSet = TabSecim
    OnStateChange = DtsSecimStateChange
    Left = 775
    Top = 127
  end
  object TabSecim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from STOKSECIM SS inner join SECIMLER SC on SS.SECIMID=' +
        'SC.ID and BAGID=0  where STOKID=:Prm order by SS.SIRA')
    Left = 559
    Top = 196
  end
  object PopupMenuBirim: TPopupMenu
    Left = 222
    Top = 65531
    object MenuItemAnaBirim: TMenuItem
      Caption = 'Anabirimi de'#287'i'#351'tir'
      OnClick = MenuItemAnaBirimClick
    end
  end
  object PopupMenuEsdeger: TPopupMenu
    Left = 612
    Top = 193
    object MenuTurDegis: TMenuItem
      Caption = 'T'#252'r'#252'n'#252' De'#287'i'#351'tir'
      OnClick = MenuTurDegisClick
    end
    object MenuAciklamaDegis: TMenuItem
      Caption = 'A'#231#305'klamas'#305'n'#305' de'#287'i'#351'tir'
      OnClick = MenuAciklamaDegisClick
    end
  end
  object TabStokMuhasebe: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT G.DEGER, SM.*,HP.HESAPKODU,HP.HESAPADI,MASRAFKODU=MG.KOD,' +
        'MASRAFADI=MG.AD,TURADI=G.ANAHTAR'
      
        'FROM MUHASEBEKOD SM LEFT OUTER JOIN dbo.GENINI G ON SM.MUHASEBEI' +
        'D=G.DEGER AND G.BOLUM=-2755'
      #9'LEFT OUTER JOIN dbo.HESAPPLANI HP ON SM.HESAPID=HP.ID'
      #9'LEFT OUTER JOIN dbo.MASRAFGELIR MG ON SM.MASRAFID=MG.ID'
      'WHERE SM.YER=88 and  SM.YER_ID=:prm1')
    Left = 800
    Top = 16
  end
  object DtsStokMuhasebe: TDataSource
    DataSet = TabStokMuhasebe
    OnStateChange = DtsStokMuhasebeStateChange
    Left = 800
    Top = 64
  end
  object PopupStokCevrim: TPopupMenu
    Left = 492
    Top = 129
    object BakaKarttanKopyala1: TMenuItem
      Caption = 'Ba'#351'ka Karttan Kopyala'
      OnClick = BakaKarttanKopyala1Click
    end
  end
  object PopupMenuStok: TPopupMenu
    Left = 396
    Top = 113
    object MenuAnaBirimDegis: TMenuItem
      Caption = 'Ana birimi de'#287'i'#351'tir'
      OnClick = MenuAnaBirimDegisClick
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
    Left = 921
    Top = 297
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 963
    Top = 172
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 848
    Top = 184
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
    Left = 912
    Top = 232
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
    Left = 800
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
  object TabUTS: TFDQuery
    OnNewRecord = TabUTSNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  *  FROM  STOKUTS'
      'WHERE'
      'STOKID=:SID')
    Left = 138
    Top = 312
  end
  object DtsUTS: TDataSource
    DataSet = TabUTS
    Left = 206
    Top = 312
  end
  object TabYDil: TFDQuery
    BeforePost = TabYDilBeforePost
    OnNewRecord = TabYDilNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM YDIL'
      'WHERE'
      'YER=:PYER'
      'and'
      'YERID=:PYERID')
    Left = 605
    Top = 359
  end
  object DtsYDil: TDataSource
    DataSet = TabYDil
    OnStateChange = DtsYDilStateChange
    Left = 749
    Top = 330
  end
end
