object KrediKarti: TKrediKarti
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 69
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
    TabOrder = 0
    Transparent = True
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 69
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton5: TToolButton
      Left = 138
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object KaydetTus: TToolButton
      Left = 146
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 215
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton1: TToolButton
      Left = 284
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object KapatTus: TToolButton
      Left = 292
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = KapatTusClick
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 32
    Width = 451
    Height = 272
    Align = alClient
    TabOrder = 1
    object Label2: TcxLabel
      Left = 5
      Top = 18
      Caption = 'Kodu'
      FocusControl = EditKODU
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
      Left = 6
      Top = 45
      Caption = 'Ad'#305
      FocusControl = EditADI
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label4: TcxLabel
      Left = 5
      Top = 72
      Caption = #220'zerindeki '#304'sim'
      FocusControl = EditUzerindekiisim
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label5: TcxLabel
      Left = 5
      Top = 99
      Caption = 'Tipi'
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
      Left = 5
      Top = 125
      Caption = 'T'#252'r'#252
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
      Left = 5
      Top = 153
      Caption = 'Banka'
      FocusControl = DBEdit7
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label8: TcxLabel
      Left = 5
      Top = 178
      Caption = 'Kart Numaras'#305
      FocusControl = KartNumarasi
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
      Left = 475
      Top = 443
      Caption = 'Tan'#305'ml'#305' Ki'#351'i'
      FocusControl = DBEdit9
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object Label10: TcxLabel
      Left = 5
      Top = 205
      Caption = 'Genel Limit'
      FocusControl = GenelLimit
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label11: TcxLabel
      Left = 548
      Top = 419
      Caption = 'Dahili Limit'
      FocusControl = DBEdit11
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object Label12: TcxLabel
      Left = 5
      Top = 232
      Caption = 'Para Birimi'
      FocusControl = ComboKur
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label13: TcxLabel
      Left = 548
      Top = 395
      Caption = 'Dahili Limit '
      FocusControl = DBEdit13
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object Label14: TcxLabel
      Left = 5
      Top = 258
      Caption = 'SKT'
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
      Left = 411
      Top = 126
      Caption = 'Hesap Kesimi Ay'#305'n Ka'#231#305'nda'
      FocusControl = EditHesapKesim
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label16: TcxLabel
      Left = 629
      Top = 126
      Caption = #214'deme G'#252'n Say'#305's'#305
      FocusControl = EditOdemeGun
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
      Left = 411
      Top = 153
      Caption = 'Nakit Faiz Oran'#305
      FocusControl = NakitFaizOrani
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label18: TcxLabel
      Left = 411
      Top = 181
      Caption = 'Al'#305#351'veri'#351' Faiz Oran'#305
      FocusControl = AVFaizOrani
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label19: TcxLabel
      Left = 411
      Top = 205
      Caption = 'Gecikme Faiz Oran'#305
      FocusControl = GFaizOrani
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label20: TcxLabel
      Left = 585
      Top = 338
      Caption = 'Uyar'#305' G'#252'n'#252
      FocusControl = UyariGun
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label21: TcxLabel
      Left = 2
      Top = 419
      Caption = #214'denecek Banka'
      FocusControl = DBEdit21
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object Label22: TcxLabel
      Left = 411
      Top = 232
      Caption = 'Y'#305'll'#305'k '#220'creti'
      FocusControl = YillikUcret
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label23: TcxLabel
      Left = 411
      Top = 72
      Caption = 'Al'#305'n'#305#351' Tarihi'
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
      Left = 411
      Top = 99
      Caption = 'Kapan'#305#351' Tarihi'
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
      Left = 411
      Top = 283
      Caption = #214'zel Kod'
      FocusControl = OzelKodu
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Label27: TcxLabel
      Left = 411
      Top = 258
      Caption = 'Yetki Kodu'
      FocusControl = YetkiKodu
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object DBEdit1: TcxDBLabel
      Left = 221
      Top = 18
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = DtsKK
      Height = 21
      Width = 104
    end
    object EditKODU: TcxDBTextEdit
      Left = 111
      Top = 18
      DataBinding.DataField = 'KODU'
      DataBinding.DataSource = DtsKK
      TabOrder = 1
      Width = 104
    end
    object EditADI: TcxDBTextEdit
      Left = 111
      Top = 45
      DataBinding.DataField = 'ADI'
      DataBinding.DataSource = DtsKK
      TabOrder = 2
      Width = 209
    end
    object EditUzerindekiisim: TcxDBTextEdit
      Left = 111
      Top = 72
      DataBinding.DataField = 'HAMILI'
      DataBinding.DataSource = DtsKK
      TabOrder = 3
      Width = 209
    end
    object DBEdit7: TcxDBTextEdit
      Left = 240
      Top = 129
      DataBinding.DataField = 'BANKAHESAPID'
      DataBinding.DataSource = DtsKK
      TabOrder = 4
      Visible = False
      Width = 63
    end
    object KartNumarasi: TcxDBTextEdit
      Left = 111
      Top = 178
      DataBinding.DataField = 'NOSU'
      DataBinding.DataSource = DtsKK
      TabOrder = 5
      Width = 209
    end
    object DBEdit9: TcxDBTextEdit
      Left = 548
      Top = 443
      DataBinding.DataField = 'TANIMLI_KISI'
      DataBinding.DataSource = DtsKK
      TabOrder = 6
      Visible = False
      Width = 201
    end
    object GenelLimit: TcxDBTextEdit
      Left = 111
      Top = 205
      DataBinding.DataField = 'GENELLIMIT'
      DataBinding.DataSource = DtsKK
      TabOrder = 7
      Width = 104
    end
    object DBEdit11: TcxDBTextEdit
      Left = 655
      Top = 419
      DataBinding.DataField = 'DAHILILIMIT'
      DataBinding.DataSource = DtsKK
      TabOrder = 8
      Visible = False
      Width = 94
    end
    object ComboKur: TcxDBComboBox
      Left = 111
      Top = 232
      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsKK
      Properties.DropDownListStyle = lsFixedList
      TabOrder = 9
      Width = 44
    end
    object DBEdit13: TcxDBTextEdit
      Left = 656
      Top = 395
      DataBinding.DataField = 'DAHILI_LIMIT_VADESI'
      DataBinding.DataSource = DtsKK
      TabOrder = 10
      Visible = False
      Width = 93
    end
    object EditHesapKesim: TcxDBSpinEdit
      Left = 587
      Top = 124
      DataBinding.DataField = 'HESAP_KESIM_TARIHI'
      DataBinding.DataSource = DtsKK
      Properties.MaxValue = 28.000000000000000000
      Properties.MinValue = 1.000000000000000000
      TabOrder = 11
      Width = 41
    end
    object EditOdemeGun: TcxDBSpinEdit
      Left = 719
      Top = 123
      DataBinding.DataField = 'ODEME_GUN_SAYISI'
      DataBinding.DataSource = DtsKK
      Properties.LargeIncrement = 1.000000000000000000
      Properties.MaxValue = 20.000000000000000000
      Properties.MinValue = 1.000000000000000000
      TabOrder = 12
      Width = 42
    end
    object NakitFaizOrani: TcxDBTextEdit
      Left = 585
      Top = 153
      DataBinding.DataField = 'NAKIT_FAIZORANI'
      DataBinding.DataSource = DtsKK
      TabOrder = 13
      Width = 100
    end
    object AVFaizOrani: TcxDBTextEdit
      Left = 585
      Top = 180
      DataBinding.DataField = 'ALISVERIS_FAIZORANI'
      DataBinding.DataSource = DtsKK
      TabOrder = 14
      Width = 100
    end
    object GFaizOrani: TcxDBTextEdit
      Left = 585
      Top = 205
      DataBinding.DataField = 'GECIKME_FAIZORANI'
      DataBinding.DataSource = DtsKK
      TabOrder = 15
      Width = 100
    end
    object CheckUyari: TDBCheckBox
      Left = 411
      Top = 341
      Width = 46
      Height = 15
      Caption = 'Uyar'
      DataField = 'UYAR'
      DataSource = DtsKK
      TabOrder = 16
    end
    object UyariGun: TcxDBTextEdit
      Left = 644
      Top = 338
      DataBinding.DataField = 'UYARIGUN'
      DataBinding.DataSource = DtsKK
      TabOrder = 17
      Width = 41
    end
    object CheckOtomatikOdeme: TDBCheckBox
      Left = 585
      Top = 312
      Width = 97
      Height = 17
      Caption = 'Otomatik '#214'deme'
      DataField = 'OTOMATIK_ODEME'
      DataSource = DtsKK
      TabOrder = 18
    end
    object DBEdit21: TcxDBTextEdit
      Left = 95
      Top = 395
      DataBinding.DataField = 'ODEME_BANKAHESAPID'
      DataBinding.DataSource = DtsKK
      TabOrder = 19
      Visible = False
      Width = 40
    end
    object YillikUcret: TcxDBTextEdit
      Left = 585
      Top = 232
      DataBinding.DataField = 'YILLIK_UCRETI'
      DataBinding.DataSource = DtsKK
      TabOrder = 20
      Width = 100
    end
    object OzelKodu: TcxDBTextEdit
      Left = 585
      Top = 285
      DataBinding.DataField = 'OZELKOD'
      DataBinding.DataSource = DtsKK
      TabOrder = 21
      Width = 100
    end
    object YetkiKodu: TcxDBTextEdit
      Left = 585
      Top = 259
      DataBinding.DataField = 'YETKIKODU'
      DataBinding.DataSource = DtsKK
      TabOrder = 22
      Width = 100
    end
    object ComboOdeBankaKodu: TcxButtonEdit
      Left = 95
      Top = 419
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EdiBANKATICARIHESAPKODUPropertiesButtonClick
      TabOrder = 48
      Visible = False
      Width = 91
    end
    object ComboBankaKodu: TcxButtonEdit
      Left = 111
      Top = 153
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end
        item
          Caption = '-'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
      TabOrder = 49
      Width = 104
    end
    object EditBanka: TcxTextEdit
      Left = 218
      Top = 153
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 50
      Width = 185
    end
    object EditOdeBanka: TcxTextEdit
      Left = 191
      Top = 419
      TabStop = False
      ParentColor = True
      Properties.ReadOnly = True
      TabOrder = 51
      Visible = False
      Width = 199
    end
    object CbTipi: TcxDBImageComboBox
      Left = 111
      Top = 100
      DataBinding.DataField = 'TIPI'
      DataBinding.DataSource = DtsKK
      Properties.Items = <
        item
          Description = 'Visa'
          ImageIndex = 0
          Value = '0'
        end
        item
          Description = 'Master'
          Value = '1'
        end>
      TabOrder = 52
      Width = 104
    end
    object CbTuru: TcxDBImageComboBox
      Left = 111
      Top = 126
      RepositoryItem = Tablo.RepKrediKartiTuru
      DataBinding.DataField = 'TURU'
      DataBinding.DataSource = DtsKK
      Properties.Items = <>
      TabOrder = 53
      Width = 104
    end
    object SKTGun: TcxDBImageComboBox
      Left = 111
      Top = 258
      DataBinding.DataField = 'SKTAY'
      DataBinding.DataSource = DtsKK
      Properties.Items = <
        item
          Description = '01'
          ImageIndex = 0
          Value = '01'
        end
        item
          Description = '02'
          Value = '02'
        end
        item
          Description = '03'
          Value = '03'
        end
        item
          Description = '04'
          Value = '04'
        end
        item
          Description = '05'
          Value = '05'
        end
        item
          Description = '06'
          Value = '06'
        end
        item
          Description = '07'
          Value = '07'
        end
        item
          Description = '08'
          Value = '08'
        end
        item
          Description = '09'
          Value = '09'
        end
        item
          Description = '10'
          Value = '10'
        end
        item
          Description = '11'
          Value = '11'
        end
        item
          Description = '12'
          Value = '12'
        end>
      TabOrder = 54
      Width = 44
    end
    object SktYil: TcxDBImageComboBox
      Left = 161
      Top = 258
      DataBinding.DataField = 'SKTYIL'
      DataBinding.DataSource = DtsKK
      Properties.Items = <
        item
          Description = '12'
          ImageIndex = 0
          Value = '12'
        end
        item
          Description = '13'
          Value = '13'
        end
        item
          Description = '14'
          Value = '14'
        end
        item
          Description = '15'
          Value = '15'
        end
        item
          Description = '16'
          Value = '16'
        end
        item
          Description = '17'
          Value = '17'
        end
        item
          Description = '18'
          Value = '18'
        end
        item
          Description = '19'
          Value = '19'
        end
        item
          Description = '20'
          Value = '20'
        end
        item
          Description = '21'
          Value = '21'
        end
        item
          Description = '22'
          Value = '22'
        end
        item
          Description = '23'
          Value = '23'
        end
        item
          Description = '24'
          Value = '24'
        end
        item
          Description = '25'
          Value = '25'
        end
        item
          Description = '26'
          Value = '26'
        end>
      TabOrder = 55
      Width = 54
    end
    object Label34: TcxLabel
      Left = 411
      Top = 46
      Cursor = crHandPoint
      Hint = 'CariKart_Durum'
      HelpType = htKeyword
      HelpKeyword = 'REHBER.DURUM'
      Caption = 'Durum'
      FocusControl = ComboDURUM
      Transparent = True
    end
    object ComboDURUM: TcxDBImageComboBox
      Left = 585
      Top = 44
      RepositoryItem = Tablo.RepAktifPasif
      DataBinding.DataField = 'DURUM'
      DataBinding.DataSource = DtsKK
      Properties.ImageAlign = iaRight
      Properties.ImmediatePost = True
      Properties.Items = <>
      TabOrder = 57
      Width = 172
    end
    object DateAlmaTarihi: TcxDBDateEdit
      Left = 585
      Top = 72
      DataBinding.DataField = 'ALINISTARIHI'
      DataBinding.DataSource = DtsKK
      TabOrder = 58
      Width = 172
    end
    object DateKapanmaTarihi: TcxDBDateEdit
      Left = 585
      Top = 99
      DataBinding.DataField = 'KAPANISTARIHI'
      DataBinding.DataSource = DtsKK
      TabOrder = 59
      Width = 172
    end
    object LblSube: TcxLabel
      Left = 411
      Top = 19
      Caption = #350'ube'
    end
    object ComboSube: TcxDBImageComboBox
      Left = 585
      Top = 17
      RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      DataBinding.DataField = 'SUBEID'
      DataBinding.DataSource = DtsKK
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
      TabOrder = 61
      Width = 172
    end
  end
  object TabKK: TFDQuery
    BeforeEdit = TabKKBeforeEdit
    BeforePost = TabKKBeforePost
    AfterPost = TabKKAfterPost
    AfterScroll = TabKKAfterScroll
    OnNewRecord = TabKKNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select *'
      ' from KREDIKARTI where ID= :Par')
    Left = 376
    Top = 406
  end
  object DtsKK: TDataSource
    DataSet = TabKK
    OnStateChange = DtsKKStateChange
    Left = 254
    Top = 366
  end
end
