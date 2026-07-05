object BankaTanimWizardDlg: TBankaTanimWizardDlg
  Left = 0
  Top = 0
  ActiveControl = Logo
  Caption = 'Banka Tan'#305'mlama Sihirbaz'#305
  ClientHeight = 545
  ClientWidth = 962
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  PopupMenu = CariHesapEkstresi1
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 962
    Height = 545
    ActivePage = HesapOlusturmaDuzenlemeEkr
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
    ExplicitWidth = 958
    ExplicitHeight = 544
    DesignSize = (
      962
      545)
    object HesapOlusturmaDuzenlemeEkr: TJvWizardWelcomePage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Hesap olu'#351'turma ve d'#252'zenleme'
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
      VisibleButtons = [bkFinish, bkCancel]
      Color = 11776947
      ExplicitWidth = 958
      ExplicitHeight = 502
      object LabelHesapKodu: TcxLabel
        Left = 171
        Top = 169
        Caption = 'Hesap Kodu*'
        Transparent = True
      end
      object LabelHesapAdi: TcxLabel
        Left = 380
        Top = 169
        Caption = 'Hesap Ad'#305'*'
        Transparent = True
      end
      object Label12: TcxLabel
        Left = 170
        Top = 222
        Caption = 'Para Birimi*'
        Transparent = True
      end
      object Label14: TcxLabel
        Left = 170
        Top = 278
        Caption = 'A'#231#305'klama'
        Transparent = True
      end
      object Label15: TcxLabel
        Left = 567
        Top = 107
        Caption = 'Durum'
        Transparent = True
      end
      object Label24: TcxLabel
        Left = 170
        Top = 195
        Caption = 'Hesap No*'
        Transparent = True
      end
      object Label28: TcxLabel
        Left = 380
        Top = 195
        Caption = 'IBAN*'
        Transparent = True
      end
      object Label1: TcxLabel
        Left = 380
        Top = 222
        Caption = 'Hesap Tipi*'
        Transparent = True
      end
      object Label2: TcxLabel
        Left = 170
        Top = 148
        Caption = 'Hesap ID'
        Transparent = True
      end
      object Label3: TcxLabel
        Left = 380
        Top = 246
        Caption = 'M'#252#351'teri No'
        Transparent = True
      end
      object EditHESAPKODU: TcxDBTextEdit
        Left = 256
        Top = 168
        DataBinding.DataField = 'HESAPKODU'
        DataBinding.DataSource = DtsBankaHesaplar
        TabOrder = 10
        Width = 98
      end
      object EditHESAPADI: TcxDBTextEdit
        Left = 497
        Top = 168
        DataBinding.DataField = 'HESAPADI'
        DataBinding.DataSource = DtsBankaHesaplar
        TabOrder = 11
        Width = 281
      end
      object ComboKUR: TcxDBComboBox
        Left = 257
        Top = 220
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        DataBinding.DataField = 'KUR'
        DataBinding.DataSource = DtsBankaHesaplar
        Properties.DropDownListStyle = lsFixedList
        TabOrder = 17
        Width = 98
      end
      object EditHESAPACIKLAMA: TcxDBTextEdit
        Left = 257
        Top = 277
        DataBinding.DataField = 'HESAPACIKLAMA'
        DataBinding.DataSource = DtsBankaHesaplar
        TabOrder = 24
        Width = 521
      end
      object EditHESAPNO: TcxDBTextEdit
        Left = 257
        Top = 194
        DataBinding.DataField = 'HESAPNO'
        DataBinding.DataSource = DtsBankaHesaplar
        TabOrder = 14
        Width = 98
      end
      object cxDBImageComboBox1: TcxDBImageComboBox
        Left = 627
        Top = 105
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsBankaHesaplar
        Properties.Items = <
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = True
          end
          item
            Description = 'Pasif'
            Value = False
          end>
        TabOrder = 4
        Width = 151
      end
      object EditIBAN: TcxDBTextEdit
        Left = 497
        Top = 194
        DataBinding.DataField = 'IBAN'
        DataBinding.DataSource = DtsBankaHesaplar
        TabOrder = 15
        Width = 281
      end
      object ComboBoxTIPI: TcxDBImageComboBox
        Left = 497
        Top = 220
        DataBinding.DataField = 'TIPI'
        DataBinding.DataSource = DtsBankaHesaplar
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
        TabOrder = 18
        Width = 78
      end
      object LabelBANKASUBELERID: TcxDBLabel
        Left = 784
        Top = 80
        AutoSize = True
        DataBinding.DataField = 'BANKASUBELERID'
        DataBinding.DataSource = DtsBankaHesaplar
        Transparent = True
      end
      object Logo: TcxDBImage
        AlignWithMargins = True
        Left = 166
        Top = 71
        DataBinding.DataField = 'LOGO'
        DataBinding.DataSource = DtsBankalar
        Properties.Caption = 'Se'#231'mek i'#231'in t'#305'klay'#305'n*'
        Properties.FitMode = ifmProportionalStretch
        Properties.GraphicClassName = 'TdxPNGImage'
        Properties.GraphicTransparency = gtTransparent
        Properties.ImmediatePost = True
        Properties.PopupMenuLayout.MenuItems = [pmiPaste, pmiLoad, pmiSave]
        Properties.ReadOnly = False
        Style.Shadow = True
        TabOrder = 0
        OnClick = LogoClick
        Height = 75
        Width = 151
      end
      object LabelSubeKodu: TcxDBLabel
        Left = 334
        Top = 85
        DataBinding.DataField = 'SUBEKODU'
        DataBinding.DataSource = DtsBankalar
        Style.TransparentBorder = True
        Transparent = True
        Height = 17
        Width = 77
      end
      object LabelSubeAdi: TcxDBLabel
        Left = 334
        Top = 107
        AutoSize = True
        DataBinding.DataField = 'SUBEADI'
        DataBinding.DataSource = DtsBankalar
        Transparent = True
      end
      object cxDBLabel2: TcxDBLabel
        Left = 335
        Top = 131
        AutoSize = True
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsBankaHesaplar
        Transparent = True
      end
      object PanelAlt: TPanel
        Left = 170
        Top = 301
        Width = 608
        Height = 130
        BevelOuter = bvNone
        Color = 11776947
        ParentBackground = False
        TabOrder = 25
        object Label25: TcxLabel
          Left = 0
          Top = 107
          Caption = 'Bakiye'
          Transparent = True
        end
        object Label29: TcxLabel
          Left = 456
          Top = 5
          Caption = 'Kredi Miktar'#305
          ParentFont = False
          Transparent = True
        end
        object Label30: TcxLabel
          Left = 456
          Top = 59
          Caption = 'Geri D'#246'n'#252#351' Hesap No'
          Properties.PenWidth = 0
          Properties.WordWrap = True
          Transparent = True
          Width = 61
        end
        object Label5: TcxLabel
          Left = 456
          Top = 26
          Caption = 'Geri D'#246'n'#252#351' G'#252'n Say'#305's'#305
          Properties.WordWrap = True
          Transparent = True
          Width = 58
        end
        object EditGERIDONUSHESAPKODU: TcxDBTextEdit
          Left = 534
          Top = 66
          DataBinding.DataField = 'GERIDONUSHESAPNO'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 11
          Width = 74
        end
        object CheckKREDIKARTI: TcxDBCheckBox
          Left = 83
          Top = 26
          Caption = 'Sadece POS Hesab'#305
          DataBinding.DataField = 'KREDIKARTI'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 5
          Transparent = True
        end
        object EditKREDITUTARI: TcxDBCurrencyEdit
          Left = 534
          Top = 3
          DataBinding.DataField = 'KREDITUTARI'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 2
          Width = 74
        end
        object CheckKredi: TcxDBCheckBox
          Left = 83
          Top = 4
          Caption = 'Kredili hesap'
          DataBinding.DataField = 'KREDILIHESAP'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 0
          Transparent = True
        end
        object EditGERIDONUSGUNSAY: TcxDBSpinEdit
          Left = 534
          Top = 35
          DataBinding.DataField = 'GERIDONUSGUNSAY'
          DataBinding.DataSource = DtsBankaHesaplar
          Properties.MaxValue = 365.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 7
          Width = 74
        end
        object CheckCEKHESABI: TcxDBCheckBox
          Left = 83
          Top = 58
          Caption = #199'ek Hesab'#305
          DataBinding.DataField = 'CEKHESABI'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 9
          Transparent = True
        end
        object cxDBCheckBox1: TcxDBCheckBox
          Left = 238
          Top = 26
          Caption = 'Talimat Olu'#351'turma'
          DataBinding.DataField = 'ONLINETALIMAT'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 6
          Transparent = True
        end
        object cxDBCheckBox2: TcxDBCheckBox
          Left = 238
          Top = 49
          Caption = 'Hesap Hareketleri Alma'
          DataBinding.DataField = 'ONLINEHESAPHAREKETI'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 8
          Transparent = True
        end
        object cxDBCheckBox3: TcxDBCheckBox
          Left = 238
          Top = 4
          Caption = 'G'#252'nl'#252'k Aksiyonlarda G'#246'ster'
          DataBinding.DataField = 'GUNLUKAKSIYONDAGOSTER'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 1
          Transparent = True
        end
        object EditBakiye: TcxDBCurrencyEdit
          Left = 83
          Top = 106
          DataBinding.DataField = 'BAKIYE'
          DataBinding.DataSource = DtsBankaHesaplar
          Enabled = False
          Properties.DisplayFormat = ',0.00;-,0.00'
          TabOrder = 13
          Width = 121
        end
        object cxDBCheckBox4: TcxDBCheckBox
          Left = 83
          Top = 80
          Caption = 'Maa'#351' '#304#351'lemleri Hesab'#305
          DataBinding.DataField = 'MAASHESABI'
          DataBinding.DataSource = DtsBankaHesaplar
          TabOrder = 12
          Transparent = True
        end
      end
      object cxDBCurrencyEdit1: TcxDBCurrencyEdit
        Left = 497
        Top = 245
        DataBinding.DataField = 'MUSTERINO'
        DataBinding.DataSource = DtsBankaHesaplar
        Properties.DisplayFormat = '0;-0'
        TabOrder = 19
        Width = 121
      end
      object LblSube: TcxLabel
        Left = 567
        Top = 80
        Caption = #350'ube'
      end
      object ComboSube: TcxDBImageComboBox
        Left = 627
        Top = 78
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        DataBinding.DataField = 'SUBEID'
        DataBinding.DataSource = DtsBankaHesaplar
        Properties.Alignment.Horz = taLeftJustify
        Properties.ImmediatePost = True
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
        TabOrder = 1
        Width = 151
      end
      object cxLabel1: TcxLabel
        Left = 257
        Top = 342
        Caption = '(Havalede g'#246'r'#252'nmez)'
        Style.TextColor = 4227072
        Transparent = True
      end
    end
  end
  object TabBankalar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select BS.BANKAKODU, BANKAADI,SUBEKODU,SUBEADI,LOGO'
      '   from BANKASUBELER BS '
      '        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      'where BS.ID = :PID')
    Left = 899
    Top = 137
  end
  object DtsBankalar: TDataSource
    DataSet = TabBankalar
    Left = 898
    Top = 81
  end
  object DtsBankaHesaplar: TDataSource
    DataSet = TabBankaHesaplar
    Left = 601
    Top = 17
  end
  object TabBankaHesaplar: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = TabBankaHesaplarBeforeEdit
    BeforePost = TabBankaHesaplarBeforePost
    AfterPost = TabBankaHesaplarAfterPost
    BeforeDelete = TabBankaHesaplarBeforeDelete
    AfterDelete = TabBankaHesaplarAfterDelete
    AfterScroll = TabBankaHesaplarAfterScroll
    OnNewRecord = TabBankaHesaplarNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from BANKAHESAPLAR where ID=:PId')
    Left = 508
    Top = 16
  end
  object CariHesapEkstresi1: TPopupMenu
    Left = 409
    Top = 13
    object AcilisKaydiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      Visible = False
      OnClick = AcilisKaydiMenuClick
    end
    object DevirFiiGir1: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir'
      OnClick = AcilisKaydiMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object KasaYenileMenu: TMenuItem
      Caption = 'Sadece Bu Hesab'#305'n Toplamlar'#305'n'#305' Yenile'
    end
    object BtnKasalarnToplamlarnYenile1: TMenuItem
      Caption = 'Bu Bankan'#305'n B'#252't'#252'n Hesaplar'#305'n'#305'n Toplamlar'#305'n'#305' Yenile'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object YeniBankaTanmla1: TMenuItem
      Caption = 'Yeni Banka Tan'#305'mla'
      OnClick = YeniBankaTanmla1Click
    end
    object YeniubeTanmla1: TMenuItem
      Caption = 'Yeni '#350'ube Tan'#305'mla'
      OnClick = YeniubeTanmla1Click
    end
  end
end

