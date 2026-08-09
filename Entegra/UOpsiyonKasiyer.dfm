object OpsiyonKasiyerDlg: TOpsiyonKasiyerDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Kasiyer Opsiyonlar'#305' '
  ClientHeight = 552
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 580
    Height = 514
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = TsYazarkasa
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControl1Change
    ClientRectBottom = 512
    ClientRectLeft = 2
    ClientRectRight = 578
    ClientRectTop = 25
    object cxTabSheet2: TcxTabSheet
      Caption = 'Genel'
      ImageIndex = 11
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object cxGroupBox2: TcxGroupBox
        Left = 29
        Top = 2
        Caption = 'Sat'#305#351' Varsay'#305'lanlar'#305
        ParentBackground = False
        ParentColor = False
        Style.Color = clScrollBar
        TabOrder = 0
        Height = 175
        Width = 463
        object cxLabel4: TcxLabel
          Left = 74
          Top = 64
          Caption = 'Stok Deposu'
          Transparent = True
        end
        object CbHGStokDepo: TcxImageComboBox
          Left = 200
          Top = 62
          EditValue = '0'
          Properties.Items = <>
          TabOrder = 0
          Width = 161
        end
        object cxLabel5: TcxLabel
          Left = 74
          Top = 86
          Caption = 'Nakit Kasas'#305
          Transparent = True
        end
        object CbHGStokNakitKasa: TcxImageComboBox
          Left = 200
          Top = 84
          EditValue = '0'
          Properties.Items = <>
          TabOrder = 4
          Width = 161
        end
        object CbHGPOS: TcxImageComboBox
          Left = 200
          Top = 106
          EditValue = '0'
          Properties.Items = <>
          TabOrder = 6
          Width = 161
        end
        object cxLabel6: TcxLabel
          Left = 74
          Top = 108
          Caption = 'Pos Cihaz'#305
          Transparent = True
        end
        object cxLabel8: TcxLabel
          Left = 74
          Top = 44
          Caption = 'M'#252#351'teri'
          Transparent = True
        end
        object BeditHGMusteri: TcxButtonEdit
          Left = 200
          Top = 38
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = BeditHGMusteriPropertiesButtonClick
          TabOrder = 2
          Width = 161
        end
        object cxLabel3: TcxLabel
          Left = 74
          Top = 130
          Caption = 'Fiyat Sat'#305#351
          Transparent = True
        end
        object CbHGVarsFiyat: TcxImageComboBox
          Left = 200
          Top = 128
          RepositoryItem = Tablo.RepFiyatAdlari
          Properties.Items = <>
          TabOrder = 8
          Width = 161
        end
        object cxLabel41: TcxLabel
          Left = 74
          Top = 153
          Caption = 'Fiyat Al'#305#351
          Transparent = True
        end
        object CbHGVarsFiyatAlis: TcxImageComboBox
          Left = 200
          Top = 151
          RepositoryItem = Tablo.RepFiyatAdlariAlis
          Properties.Items = <>
          TabOrder = 10
          Width = 161
        end
        object ComboSube: TcxImageComboBox
          Left = 120
          Top = 15
          RepositoryItem = Tablo.RepSubeler
          EditValue = '0'
          Properties.Items = <>
          Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
          TabOrder = 12
          Width = 240
        end
        object LabelSube: TcxLabel
          Left = 74
          Top = 15
          Caption = #350'ube'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -13
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.TextColor = clRed
          Style.IsFontAssigned = True
          Transparent = True
        end
        object LabelKaydet: TcxLabel
          Left = 393
          Top = 153
          Cursor = crHandPoint
          Caption = 'Kaydet'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clNavy
          Style.Font.Height = -11
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Properties.LabelStyle = cxlsLowered
          Transparent = True
          OnClick = LabelKaydetClick
        end
      end
      object CbHGDoviz: TcxImageComboBox
        Left = 229
        Top = 435
        EditValue = '((ALIS+SATIS)/2)'
        Properties.Items = <
          item
            Description = 'Al'#305#351
            ImageIndex = 0
            Tag = 1
            Value = 'ALIS'
          end
          item
            Description = 'Sat'#305#351
            Tag = 2
            Value = 'SATIS'
          end
          item
            Description = 'Ef. Al'#305#351
            Tag = 3
            Value = 'EFALIS'
          end
          item
            Description = 'Ef. Sat'#305#351
            Tag = 4
            Value = 'EFSATIS'
          end
          item
            Description = 'Ortalama'
            Tag = 5
            Value = '((ALIS+SATIS)/2)'
          end
          item
            Description = 'Ef. Ortalama'
            Tag = 6
            Value = '((EFALIS+EFSATIS)/2)'
          end
          item
            Description = 'Her Seferinde Sor'
            Value = ''
          end>
        TabOrder = 4
        Width = 161
      end
      object cxLabel7: TcxLabel
        Left = 103
        Top = 437
        Caption = 'Varsay'#305'lan Kur'
        Transparent = True
      end
      object cxLabel21: TcxLabel
        Left = 103
        Top = 413
        Caption = 'KDV Durumu'
        Transparent = True
      end
      object CbKHGKDVDurum: TcxImageComboBox
        Left = 229
        Top = 411
        RepositoryItem = Tablo.RepKDVDurum
        Properties.Items = <>
        TabOrder = 2
        Width = 161
      end
      object cxPageControl2: TcxPageControl
        Left = 30
        Top = 293
        Width = 463
        Height = 106
        Color = clMoneyGreen
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 1
        Properties.ActivePage = cxTabSheet5
        Properties.CustomButtons.Buttons = <>
        Properties.CustomButtons.Mode = cbmActiveTab
        Properties.NavigatorPosition = npLeftTop
        Properties.Options = [pcoAlwaysShowGoDialogButton, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize, pcoUsePageColorForTab]
        Properties.Style = 8
        ClientRectBottom = 106
        ClientRectRight = 463
        ClientRectTop = 25
        object cxTabSheet3: TcxTabSheet
          Caption = 'Tahsilat T'#252'rleri'
          ImageIndex = 34
          object CheckTahTurNakit: TcxCheckBox
            Left = 6
            Top = 3
            Caption = 'Nakit'
            State = cbsChecked
            TabOrder = 1
            Transparent = True
            Width = 121
          end
          object CheckTahTurPOS: TcxCheckBox
            Left = 6
            Top = 25
            Caption = 'POS'
            ParentColor = False
            State = cbsChecked
            Style.Color = clMoneyGreen
            TabOrder = 2
            Transparent = True
            Width = 121
          end
          object CheckTahTurHC: TcxCheckBox
            Left = 139
            Top = 8
            Caption = 'Hediye '#199'eki'
            State = cbsChecked
            TabOrder = 0
            Transparent = True
            Width = 121
          end
          object CheckTahTurIC: TcxCheckBox
            Left = 139
            Top = 29
            Caption = #304'ade '#199'eki'
            State = cbsChecked
            TabOrder = 3
            Transparent = True
            Width = 69
          end
          object checkTahTurKupon: TcxCheckBox
            Left = 139
            Top = 49
            Caption = 'Kupon'
            State = cbsChecked
            TabOrder = 5
            Transparent = True
            Width = 57
          end
          object CheckTahTurAcikHesap: TcxCheckBox
            Left = 5
            Top = 47
            Caption = 'A'#231#305'k Hesap'
            State = cbsChecked
            TabOrder = 4
            Transparent = True
            Width = 121
          end
          object LabelListe: TcxLabel
            Left = 214
            Top = 51
            Cursor = crHandPoint
            Caption = 'Liste'
            ParentFont = False
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clNavy
            Style.Font.Height = -11
            Style.Font.Name = 'Tahoma'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            Properties.LabelStyle = cxlsLowered
            Transparent = True
            OnClick = LabelListeClick
          end
        end
        object cxTabSheet4: TcxTabSheet
          Caption = #214'deme T'#252'rleri'
          ImageIndex = 34
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object CheckOdeTurIC: TcxCheckBox
            Left = 135
            Top = 26
            Caption = #304'ade '#199'eki'
            State = cbsChecked
            TabOrder = 3
            Transparent = True
            Width = 121
          end
          object CheckOdeTurHC: TcxCheckBox
            Left = 135
            Top = 6
            Caption = 'Hediye '#199'eki'
            State = cbsChecked
            TabOrder = 1
            Transparent = True
            Width = 121
          end
          object CheckOdeTurNakit: TcxCheckBox
            Left = 6
            Top = 3
            Caption = 'Nakit'
            State = cbsChecked
            TabOrder = 0
            Transparent = True
            Width = 121
          end
          object CheckOdeTurPOS: TcxCheckBox
            Left = 6
            Top = 24
            Caption = 'POS'
            State = cbsChecked
            TabOrder = 2
            Transparent = True
            Width = 121
          end
          object checkOdeTurKupon: TcxCheckBox
            Left = 6
            Top = 44
            Caption = 'Kupon'
            State = cbsChecked
            TabOrder = 4
            Transparent = True
            Width = 121
          end
        end
        object cxTabSheet5: TcxTabSheet
          Caption = 'Belge T'#252'rleri'
          ImageIndex = 19
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object CheckBelgesiz: TcxCheckBox
            Left = 308
            Top = 23
            Caption = 'Belgesiz'
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 5
            Transparent = True
            Width = 133
          end
          object CheckFis: TcxCheckBox
            Left = 6
            Top = 3
            Caption = 'Fi'#351' Kay'#305't'
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 0
            Transparent = True
            Width = 127
          end
          object CheckFatura: TcxCheckBox
            Left = 6
            Top = 23
            Caption = 'Fatura Kay'#305't'
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 3
            Transparent = True
            Width = 139
          end
          object CheckPusula: TcxCheckBox
            Left = 308
            Top = 3
            Caption = 'Gider Pusulas'#305
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 2
            Transparent = True
            Width = 133
          end
          object CheckFisBaski: TcxCheckBox
            Left = 151
            Top = 3
            Caption = 'Fi'#351' Bask'#305
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 1
            Transparent = True
            Width = 131
          end
          object CheckFaturaBaski: TcxCheckBox
            Left = 151
            Top = 23
            Caption = 'Fatura Bask'#305
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 4
            Transparent = True
            Width = 127
          end
          object CheckIrsaliyeBaski: TcxCheckBox
            Left = 151
            Top = 43
            Caption = #304'rsaliye Bask'#305
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 7
            Transparent = True
            Width = 139
          end
          object CheckIrsaliye: TcxCheckBox
            Left = 6
            Top = 43
            Caption = #304'rsaliye Kay'#305't'
            Properties.ImmediatePost = True
            State = cbsChecked
            TabOrder = 6
            Transparent = True
            Width = 139
          end
        end
      end
      object cxRadioGroup1: TcxRadioGroup
        Left = 29
        Top = 183
        Caption = 'Bu Bilgisayarda'
        ParentBackground = False
        ParentColor = False
        Properties.Items = <>
        Style.BorderStyle = ebsOffice11
        Style.Color = clSkyBlue
        Style.Shadow = False
        TabOrder = 6
        Height = 104
        Width = 463
        object CheckSatistaMiktarSor: TcxCheckBox
          Left = 73
          Top = 23
          Caption = 'Sat'#305#351'ta miktar sorsun'
          TabOrder = 0
          Transparent = True
          Width = 137
        end
        object CheckSatista2birimGelsin: TcxCheckBox
          Left = 211
          Top = 23
          Caption = 'Varsa 2.birim de gelsin'
          TabOrder = 1
          Transparent = True
          Width = 150
        end
        object cxLabel48: TcxLabel
          Left = 74
          Top = 51
          Caption = 'Stok Deposu'
          Transparent = True
        end
        object ComboDepoBuBilgisayar: TcxImageComboBox
          Left = 200
          Top = 49
          EditValue = '0'
          Properties.Items = <>
          TabOrder = 3
          Width = 161
        end
        object cxLabel52: TcxLabel
          Left = 74
          Top = 73
          Caption = 'Nakit Kasas'#305
          Transparent = True
        end
        object ComboKasaBuBilgisayar: TcxImageComboBox
          Left = 200
          Top = 71
          EditValue = '0'
          Properties.Items = <>
          TabOrder = 5
          Width = 161
        end
      end
    end
    object TabSheetsatis: TcxTabSheet
      Caption = 'Sat'#305#351' Ekran'#305' '
      ImageIndex = 19
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 572
      ExplicitHeight = 486
      object cxGroupBox3: TcxGroupBox
        Left = 1
        Top = 3
        Caption = 'Ekran D'#252'zeni'
        TabOrder = 0
        Height = 188
        Width = 224
        object KategoriEn: TcxSpinEdit
          Left = 159
          Top = 20
          Properties.ImmediatePost = True
          Properties.MaxValue = 256.000000000000000000
          Properties.MinValue = 25.000000000000000000
          TabOrder = 2
          Value = 150
          Width = 43
        end
        object cxLabel9: TcxLabel
          Left = 5
          Top = 32
          Caption = 'Kategori   :'
          Transparent = True
        end
        object cxLabel10: TcxLabel
          Left = 89
          Top = 21
          Caption = 'En (pixel)'
          Transparent = True
        end
        object cxLabel11: TcxLabel
          Left = 89
          Top = 45
          Caption = 'Boy (sat'#305'r)'
          Transparent = True
        end
        object KategoriBoy: TcxSpinEdit
          Left = 159
          Top = 44
          Properties.ImmediatePost = True
          Properties.MaxValue = 20.000000000000000000
          Properties.MinValue = 2.000000000000000000
          TabOrder = 3
          Value = 8
          Width = 43
        end
        object UrunKartEn: TcxSpinEdit
          Left = 159
          Top = 70
          Properties.ImmediatePost = True
          Properties.MaxValue = 256.000000000000000000
          Properties.MinValue = 25.000000000000000000
          TabOrder = 7
          Value = 150
          Width = 43
        end
        object cxLabel12: TcxLabel
          Left = 5
          Top = 85
          Caption = #220'r'#252'n Kart'#305' :'
          Transparent = True
        end
        object cxLabel13: TcxLabel
          Left = 89
          Top = 71
          Caption = 'En (pixel)'
          Transparent = True
        end
        object cxLabel14: TcxLabel
          Left = 89
          Top = 96
          Caption = 'Boy (sat'#305'r)'
          Transparent = True
        end
        object UrunKartBoy: TcxSpinEdit
          Left = 159
          Top = 95
          Properties.ImmediatePost = True
          Properties.MaxValue = 20.000000000000000000
          Properties.MinValue = 2.000000000000000000
          TabOrder = 8
          Value = 8
          Width = 43
        end
        object ResimPixel: TcxSpinEdit
          Left = 159
          Top = 120
          Properties.ImmediatePost = True
          Properties.MaxValue = 256.000000000000000000
          Properties.MinValue = 16.000000000000000000
          TabOrder = 10
          Value = 128
          Width = 43
        end
        object cxLabel16: TcxLabel
          Left = 5
          Top = 121
          Caption = 'Resim boyutu (pixel)'
          Transparent = True
        end
        object CerceveBoyut: TcxCheckBox
          Left = 5
          Top = 140
          Caption = #199'er'#231'eveye boyutland'#305'rma'
          Properties.Alignment = taRightJustify
          State = cbsChecked
          TabOrder = 12
          Transparent = True
          Width = 197
        end
        object spinAciklamaSatir: TcxSpinEdit
          Left = 159
          Top = 161
          Properties.ImmediatePost = True
          Properties.MaxValue = 4.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 13
          Value = 1
          Width = 43
        end
        object cxLabel49: TcxLabel
          Left = 5
          Top = 162
          Caption = 'A'#231#305'klama Sat'#305'r Say'#305's'#305
          Transparent = True
        end
      end
      object cxGroupBox6: TcxGroupBox
        Left = 232
        Top = 3
        Caption = 'Listeler'
        TabOrder = 1
        Height = 188
        Width = 257
        object BtnSatisKod: TButton
          Left = 20
          Top = 21
          Width = 139
          Height = 25
          Caption = 'Sat'#305#351' Kodlar'#305
          TabOrder = 0
          OnClick = BtnSatisKodClick
        end
        object BtnSiparisKod: TButton
          Left = 20
          Top = 51
          Width = 139
          Height = 25
          Caption = 'Sipari'#351' Kodlar'#305
          TabOrder = 2
          OnClick = BtnSiparisKodClick
        end
        object BtnTransferKod: TButton
          Left = 20
          Top = 82
          Width = 139
          Height = 25
          Caption = 'Transfer Kodlar'#305
          TabOrder = 4
          OnClick = BtnTransferKodClick
        end
        object BtnDaraKod: TButton
          Left = 20
          Top = 114
          Width = 139
          Height = 25
          Caption = 'Dara Kodlar'#305
          TabOrder = 6
          OnClick = BtnDaraKodClick
        end
        object CheckSatisKodDahil: TcxCheckBox
          Left = 162
          Top = 23
          Caption = 'Kod dahil'
          ParentFont = False
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -9
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 1
          Transparent = True
          Width = 61
        end
        object CheckSiparisKodDahil: TcxCheckBox
          Left = 162
          Top = 53
          Caption = 'Kod dahil'
          ParentFont = False
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -9
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 3
          Transparent = True
          Width = 61
        end
        object CheckTransferKodDahil: TcxCheckBox
          Left = 162
          Top = 84
          Caption = 'Kod dahil'
          ParentFont = False
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -9
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 5
          Transparent = True
          Width = 61
        end
        object CheckDaraKodDahil: TcxCheckBox
          Left = 162
          Top = 115
          Caption = 'Kod dahil'
          ParentFont = False
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -9
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 7
          Transparent = True
          Width = 61
        end
        object BtnCokSatilan: TButton
          Left = 20
          Top = 145
          Width = 139
          Height = 25
          Caption = #199'ok Sat'#305'lan '#220'r'#252'nler'
          TabOrder = 8
          OnClick = BtnCokSatilanClick
        end
      end
      object checkBelgenoSor: TcxCheckBox
        Left = 5
        Top = 194
        Caption = 'Sat'#305#351' Belgesi yazd'#305'r'#305'rken belge numaras'#305' ekrana gelsin'
        TabOrder = 2
        Transparent = True
        Width = 350
      end
      object checkKasaAcKapa: TcxCheckBox
        Left = 5
        Top = 212
        Caption = 'Kasa A'#231#305'l'#305#351'/Kapan'#305#351' '#304#351'lemleri Aktif.'
        Properties.ImmediatePost = True
        TabOrder = 3
        Transparent = True
        Width = 350
      end
      object checkHerGiristeKimlikDogrula: TcxCheckBox
        Left = 5
        Top = 230
        Caption = 'Her Yeni Giri'#351'te Kullan'#305'c'#305' Do'#287'rulama Aktif.'
        TabOrder = 4
        Transparent = True
        Width = 350
      end
      object checkIskontodaAciklamaSor: TcxCheckBox
        Left = 5
        Top = 248
        Caption = #304'skonto '#304#351'lemlerinde A'#231#305'klama '#304'ste.'
        TabOrder = 5
        Transparent = True
        Width = 350
      end
      object checkFazlaIskontoIzin: TcxCheckBox
        Left = 5
        Top = 266
        Caption = 
          #304'skonto Ekran'#305'nda Sat'#305#351' tutar'#305'ndan fazla iskonto tutar'#305' girilebi' +
          'lsin'
        TabOrder = 6
        Transparent = True
        Width = 350
      end
      object CheckFaturaBilgisiSor: TcxCheckBox
        Left = 5
        Top = 284
        Caption = 'Yeni Fatura/Fi'#351' ler i'#231'in fatura bilgilerini sor.'
        TabOrder = 7
        Transparent = True
        Width = 350
      end
      object CheckBoxSiparis: TcxCheckBox
        Left = 5
        Top = 355
        Caption = 'Sipari'#351' sadece merkeze yap'#305'ls'#305'n'
        Properties.ImmediatePost = True
        TabOrder = 8
        Transparent = True
        Width = 203
      end
      object CheckBoxBarkod: TcxCheckBox
        Left = 5
        Top = 374
        Caption = 'Resim alt'#305'nda barkod g'#246'r'#252'ns'#252'n'
        Properties.ImmediatePost = True
        TabOrder = 9
        Transparent = True
        Width = 203
      end
      object CheckNakliye: TcxCheckBox
        Left = 5
        Top = 393
        Caption = 'Nakliye butonu g'#246'r'#252'ns'#252'n'
        Properties.ImmediatePost = True
        TabOrder = 10
        Transparent = True
        Width = 203
      end
      object cxLabel1: TcxLabel
        Left = 6
        Top = 413
        Caption = 'Nakliye Kodu'
        Transparent = True
      end
      object EditNakliye: TcxButtonEdit
        Left = 112
        Top = 412
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditNakliyePropertiesButtonClick
        TabOrder = 12
        Width = 82
      end
      object CheckOzelKodGoster: TcxCheckBox
        Left = 5
        Top = 302
        Caption = #220'r'#252'n Listelerinde '#214'zel Kodu G'#246'ster.'
        TabOrder = 13
        Transparent = True
        Width = 350
      end
      object CheckTeklifSevkSec: TcxCheckBox
        Left = 5
        Top = 320
        Caption = 'Tekliflerde Ba'#351'l'#305'k Bilgisi Sorulsun'
        TabOrder = 14
        Transparent = True
        Width = 350
      end
      object CheckUrunBirimleriniTopla: TcxCheckBox
        Left = 5
        Top = 338
        Caption = #220'r'#252'nlerin Birimleri D'#246'n'#252#351't'#252'r'#252'lerek Toplans'#305'n'
        TabOrder = 15
        Transparent = True
        Width = 350
      end
      object ComboUrunBirimleriniTopla: TcxImageComboBox
        Left = 238
        Top = 338
        RepositoryItem = Tablo.repStokAnaBirim
        EditValue = '0'
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 16
        Width = 90
      end
      object EditFiyatBasamak: TcxSpinEdit
        Left = 97
        Top = 458
        Properties.ImmediatePost = True
        Properties.LargeIncrement = 1.000000000000000000
        Properties.MaxValue = 28.000000000000000000
        Properties.MinValue = 1.000000000000000000
        TabOrder = 17
        Value = 4
        Width = 43
      end
      object cxLabel50: TcxLabel
        Left = 5
        Top = 453
        Caption = 'Fiyatta virg'#252'lden'
        Transparent = True
      end
      object cxLabel51: TcxLabel
        Left = 5
        Top = 466
        Caption = 'sonra basamak'
        Transparent = True
      end
      object CheckTransferKaydetYaz: TcxCheckBox
        Left = 5
        Top = 430
        Caption = 'Transferde "Kaydet" bas'#305'nca yazs'#305'n'
        Properties.ImmediatePost = True
        TabOrder = 20
        Transparent = True
        Width = 203
      end
    end
    object TabSheetTahsilat: TcxTabSheet
      Caption = 'Tahsilat Ekran'#305
      ImageIndex = 34
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object CheckKalanAcik: TcxCheckBox
        Left = 23
        Top = 61
        Caption = 'Kalan'#305' "A'#231#305'k Hesap" Butonu G'#246'r'#252'ns'#252'n'
        Properties.ImmediatePost = True
        TabOrder = 0
        Transparent = True
        Width = 350
      end
      object CheckKalanIsk: TcxCheckBox
        Left = 23
        Top = 30
        Caption = 'Kalan'#305' "'#304'skonto" Butonu G'#246'r'#252'ns'#252'n'
        Properties.ImmediatePost = True
        TabOrder = 1
        Transparent = True
        Width = 350
      end
      object CheckPerakendeAcilHesaba: TcxCheckBox
        Left = 23
        Top = 92
        Caption = '"Perakende" m'#252#351'terisi "A'#231#305'k Hesap" a at'#305'lamas'#305'n'
        Properties.ImmediatePost = True
        TabOrder = 2
        Transparent = True
        Width = 350
      end
    end
    object TsYazarkasa: TcxTabSheet
      Caption = 'Yazarkasa'
      ImageIndex = 34
      object GrpBarkod: TcxGroupBox
        Left = 9
        Top = 133
        Caption = 'Barkod Okuyucu Port Ayarlar'#305
        TabOrder = 2
        Height = 236
        Width = 230
        object cxLabel23: TcxLabel
          Left = 9
          Top = 25
          Caption = 'Barkod Port Numaras'#305
          Transparent = True
        end
        object cxLabel25: TcxLabel
          Left = 9
          Top = 55
          Caption = 'Bekleme Zaman'#305
          Transparent = True
        end
        object cxLabel26: TcxLabel
          Left = 9
          Top = 85
          Caption = 'Boud Rate'
          Transparent = True
        end
        object cxLabel30: TcxLabel
          Left = 9
          Top = 115
          Caption = 'Data Bits'
          Transparent = True
        end
        object cxLabel31: TcxLabel
          Left = 9
          Top = 145
          Caption = 'Stop Bits'
          Transparent = True
        end
        object CbBarkodPortNo: TcxComboBox
          Left = 133
          Top = 23
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Com1'
            'Com2'
            'Com3'
            'Com4'
            'Com5'
            'Com6'
            'Com7'
            'Com8'
            'Com9')
          TabOrder = 0
          Text = 'Com1'
          Width = 90
        end
        object CbBarkodBekleme: TcxComboBox
          Left = 133
          Top = 53
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '500 ms'
            '1000 ms'
            '1500 ms'
            '2000 ms'
            '2500 ms'
            '3500 ms'
            '4500 ms'
            '')
          TabOrder = 2
          Text = '1500 ms'
          Width = 90
        end
        object CbBarkodBaundRate: TcxComboBox
          Left = 133
          Top = 83
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '4800'
            '9600')
          TabOrder = 4
          Text = '4800'
          Width = 90
        end
        object CbBarkodDataBit: TcxComboBox
          Left = 133
          Top = 113
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '7'
            '8')
          TabOrder = 6
          Text = '7'
          Width = 90
        end
        object CbBarkodStopBit: TcxComboBox
          Left = 133
          Top = 143
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '1'
            '1.5'
            '2')
          TabOrder = 8
          Text = '1'
          Width = 90
        end
        object CbBarkodParity: TcxComboBox
          Left = 133
          Top = 173
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'None'
            'Odd'
            'Even'
            'Mark'
            'Space')
          TabOrder = 10
          Text = 'Odd'
          Width = 90
        end
        object CbBarkodFlowControl: TcxComboBox
          Left = 133
          Top = 203
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Hardware'
            'Software'
            'None'
            'Custom')
          TabOrder = 12
          Text = 'None'
          Width = 90
        end
        object cxLabel32: TcxLabel
          Left = 9
          Top = 175
          Caption = 'Parity'
          Transparent = True
        end
        object cxLabel33: TcxLabel
          Left = 9
          Top = 205
          Caption = 'Flow Control'
          Transparent = True
        end
      end
      object GrpAyar: TcxGroupBox
        Left = 9
        Top = 30
        Caption = 'Yazarkasa Ayarlar'#305
        TabOrder = 1
        Height = 97
        Width = 486
        object cxLabel24: TcxLabel
          Left = 2
          Top = 22
          Caption = 'Yazarkasa Marka / Model'
          Transparent = True
        end
        object cxLabel27: TcxLabel
          Left = 2
          Top = 49
          Caption = 'Kasa Numaras'#305
          Transparent = True
        end
        object cxLabel28: TcxLabel
          Left = 11
          Top = 95
          Caption = 'Bekleme Zaman'#305
          Transparent = True
        end
        object cxLabel29: TcxLabel
          Left = 263
          Top = 47
          AutoSize = False
          Caption = 'Kasiyer Numaras'#305
          Transparent = True
          Height = 20
          Width = 98
        end
        object CbYazarkasaModel: TcxComboBox
          Left = 156
          Top = 19
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Sharp'
            'Hugin')
          TabOrder = 0
          Text = 'Sharp'
          Width = 327
        end
        object CbKasaNumarasi: TcxComboBox
          Left = 156
          Top = 46
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '1'
            '2'
            '3'
            '4'
            '5'
            '6'
            '7'
            '8'
            '9'
            '10')
          TabOrder = 2
          Text = '1'
          Width = 101
        end
        object CbKasiyerNumarasi: TcxComboBox
          Left = 356
          Top = 45
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '000001'
            '000002'
            '000003'
            '000004'
            '000005'
            '000006'
            '000007'
            '000008'
            '000009'
            '000010')
          TabOrder = 3
          Text = '000001'
          Width = 127
        end
      end
      object GrpPc: TcxGroupBox
        Left = 264
        Top = 133
        Caption = 'Pc Port Ayarlar'#305
        TabOrder = 3
        Height = 236
        Width = 230
        object cxLabel34: TcxLabel
          Left = 9
          Top = 25
          Caption = 'Pc Port Numaras'#305
          Transparent = True
        end
        object cxLabel35: TcxLabel
          Left = 9
          Top = 55
          Caption = 'Bekleme Zaman'#305
          Transparent = True
        end
        object cxLabel36: TcxLabel
          Left = 9
          Top = 84
          Caption = 'Boud Rate'
          Transparent = True
        end
        object cxLabel37: TcxLabel
          Left = 9
          Top = 115
          Caption = 'Data Bits'
          Transparent = True
        end
        object cxLabel38: TcxLabel
          Left = 9
          Top = 145
          Caption = 'Stop Bits'
          Transparent = True
        end
        object CbPcPortNo: TcxComboBox
          Left = 133
          Top = 23
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Com1'
            'Com2'
            'Com3'
            'Com4'
            'Com5'
            'Com6'
            'Com7'
            'Com8'
            'Com9')
          TabOrder = 0
          Text = 'Com1'
          Width = 90
        end
        object CbPcBekleme: TcxComboBox
          Left = 133
          Top = 53
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '500 ms'
            '1000 ms'
            '1500 ms'
            '2000 ms'
            '2500 ms'
            '3500 ms'
            '4500 ms'
            '')
          TabOrder = 2
          Text = '1500 ms'
          Width = 90
        end
        object CbPcBaundRate: TcxComboBox
          Left = 133
          Top = 83
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '4800'
            '9600')
          TabOrder = 4
          Text = '9600'
          Width = 90
        end
        object cbPcDataBit: TcxComboBox
          Left = 133
          Top = 113
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '7'
            '8')
          TabOrder = 6
          Text = '7'
          Width = 90
        end
        object CbPcStopBit: TcxComboBox
          Left = 133
          Top = 143
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '1'
            '1.5'
            '2')
          TabOrder = 8
          Text = '1'
          Width = 90
        end
        object CbPcParity: TcxComboBox
          Left = 133
          Top = 173
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'None'
            'Odd'
            'Even'
            'Mark'
            'Space')
          TabOrder = 10
          Text = 'Odd'
          Width = 90
        end
        object CbPcFlowControl: TcxComboBox
          Left = 133
          Top = 203
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Hardware'
            'Software'
            'None'
            'Custom')
          TabOrder = 12
          Text = 'None'
          Width = 90
        end
        object cxLabel39: TcxLabel
          Left = 9
          Top = 175
          Caption = 'Parity'
          Transparent = True
        end
        object cxLabel40: TcxLabel
          Left = 9
          Top = 205
          Caption = 'Flow Control'
          Transparent = True
        end
      end
      object ChkYazarkasaKullan: TcxCheckBox
        Left = 9
        Top = 3
        Caption = 'Bu bilgisayarda yazarkasa kullan'#305'ls'#305'n'
        Properties.NullStyle = nssUnchecked
        Properties.OnChange = ChkYazarkasaKullanPropertiesChange
        TabOrder = 0
        Transparent = True
        Width = 330
      end
    end
    object TabSheetTerazi: TcxTabSheet
      Caption = 'Terazi'
      ImageIndex = 19
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 572
      ExplicitHeight = 486
      object cxGroupBox7: TcxGroupBox
        Left = 11
        Top = 77
        Caption = 'Terazi Ayarlar'#305
        TabOrder = 2
        Height = 220
        Width = 230
        object cxLabel15: TcxLabel
          Left = 9
          Top = 25
          Caption = 'Port Numaras'#305
          Transparent = True
        end
        object cxLabel18: TcxLabel
          Left = 9
          Top = 56
          Caption = 'Boud Rate'
          Transparent = True
        end
        object cxLabel19: TcxLabel
          Left = 9
          Top = 86
          Caption = 'Data Bits'
          Transparent = True
        end
        object cxLabel20: TcxLabel
          Left = 9
          Top = 116
          Caption = 'Stop Bits'
          Transparent = True
        end
        object TeraziPort: TcxComboBox
          Left = 126
          Top = 23
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Com1'
            'Com2'
            'Com3'
            'Com4'
            'Com5'
            'Com6'
            'Com7'
            'Com8'
            'Com9'
            'Com10'
            'Com11'
            'Com12'
            'Com13')
          TabOrder = 0
          Text = 'Com1'
          Width = 96
        end
        object TeraziBoudRate: TcxComboBox
          Left = 126
          Top = 54
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '4800'
            '9600')
          TabOrder = 2
          Text = '9600'
          Width = 96
        end
        object TeraziDataBits: TcxComboBox
          Left = 126
          Top = 84
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '7'
            '8')
          TabOrder = 4
          Text = '8'
          Width = 96
        end
        object TeraziStopBits: TcxComboBox
          Left = 126
          Top = 114
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            '1'
            '1.5'
            '2')
          TabOrder = 6
          Text = '1'
          Width = 96
        end
        object TeraziParity: TcxComboBox
          Left = 126
          Top = 144
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'None'
            'Odd'
            'Even'
            'Mark'
            'Space')
          TabOrder = 8
          Text = 'None'
          Width = 96
        end
        object TeraziFlowControl: TcxComboBox
          Left = 126
          Top = 174
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Hardware'
            'Software'
            'None'
            'Custom')
          TabOrder = 10
          Text = 'None'
          Width = 96
        end
        object cxLabel46: TcxLabel
          Left = 9
          Top = 146
          Caption = 'Parity'
          Transparent = True
        end
        object cxLabel47: TcxLabel
          Left = 9
          Top = 176
          Caption = 'Flow Control'
          Transparent = True
        end
      end
      object ComboTerazi: TcxImageComboBox
        Left = 54
        Top = 21
        RepositoryItem = Tablo.RepHizliSatisTerazi
        Properties.Items = <>
        Properties.OnCloseUp = ComboTeraziPropertiesCloseUp
        TabOrder = 0
        Width = 187
      end
      object LabelTerazi: TcxLabel
        Left = 9
        Top = 22
        Cursor = crHandPoint
        Hint = 'HizliSatis_Terazi'
        HelpType = htKeyword
        Caption = 'Terazi'
        FocusControl = ComboTerazi
        Transparent = True
      end
      object Check_Gr_Kg_Cevir: TcxCheckBox
        Left = 11
        Top = 320
        Caption = 'Okunan Gr miktar'#305'n'#305' Kg'#39'a '#231'evirsin'
        TabOrder = 3
        Transparent = True
        Width = 222
      end
    end
    object TabSheetCafe: TcxTabSheet
      Caption = 'Cafe / Rest'
      ImageIndex = 19
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 572
      ExplicitHeight = 486
      object cxGroupBox1: TcxGroupBox
        Left = 14
        Top = 30
        Caption = 'Masa A'#231'arken'
        TabOrder = 1
        Height = 138
        Width = 244
        object CheckKisiSaySor: TcxCheckBox
          Left = 42
          Top = 96
          Caption = 'Ki'#351'i say'#305's'#305'n'#305' sorsun'
          State = cbsChecked
          TabOrder = 0
          Transparent = True
          Width = 213
        end
        object ComboGarsonAdiSorPC: TcxImageComboBox
          Left = 48
          Top = 18
          Properties.Items = <
            item
              Description = 'Garson ad'#305'n'#305' sormas'#305'n'
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Sadece a'#231#305'l'#305#351'ta garson ad'#305'n'#305' sorsun'
              Value = 1
            end
            item
              Description = 'Ayn'#305' masaya ilavelerde de garson ad'#305'n'#305' sorsun'
              Value = 2
            end>
          TabOrder = 1
          Width = 188
        end
        object CheckSifreSifirla: TcxCheckBox
          Left = 42
          Top = 72
          Caption = #350'ifre s'#305'f'#305'rlans'#305'n'
          TabOrder = 2
          Transparent = True
          Width = 168
        end
        object cxLabel53: TcxLabel
          Left = 9
          Top = 20
          Caption = 'PC'
          Transparent = True
        end
        object cxLabel54: TcxLabel
          Left = 10
          Top = 44
          Caption = 'Mobil'
          Transparent = True
        end
        object ComboGarsonAdiSorMobil: TcxImageComboBox
          Left = 47
          Top = 42
          Properties.Items = <
            item
              Description = 'Garson ad'#305'n'#305' sormas'#305'n'
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Sadece a'#231#305'l'#305#351'ta garson ad'#305'n'#305' sorsun'
              Value = 1
            end
            item
              Description = 'Ayn'#305' masaya ilavelerde de garson ad'#305'n'#305' sorsun'
              Value = 2
            end>
          TabOrder = 5
          Width = 188
        end
      end
      object Button6: TButton
        Left = 22
        Top = 2
        Width = 218
        Height = 25
        Caption = 'Mekan - Masa D'#252'zenlemesi'
        TabOrder = 0
        OnClick = Button6Click
      end
      object cxGroupBox4: TcxGroupBox
        Left = 15
        Top = 180
        Caption = 'Listeler'
        TabOrder = 2
        Height = 88
        Width = 305
        object Button5: TButton
          Left = 7
          Top = 47
          Width = 215
          Height = 25
          Caption = #199'ok Sat'#305'lan '#220'r'#252'nler'
          TabOrder = 2
          OnClick = Button5Click
        end
        object BtnCafeKod: TButton
          Left = 7
          Top = 15
          Width = 215
          Height = 25
          Caption = 'Cafe/Rest Kodlar'#305
          TabOrder = 0
          OnClick = BtnCafeKodClick
        end
        object cxCheckBox1: TcxCheckBox
          Left = 231
          Top = 16
          Caption = 'Kod dahil'
          ParentFont = False
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -9
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 1
          Transparent = True
          Width = 61
        end
      end
      object cxGroupBox5: TcxGroupBox
        Left = 275
        Top = 30
        Caption = 'Masa Renklendirme'
        TabOrder = 3
        Height = 138
        Width = 292
        object cxLabel2: TcxLabel
          Left = 3
          Top = 16
          Caption = 'Bo'#351
          Transparent = True
        end
        object ColorComboBos: TcxColorComboBox
          Left = 158
          Top = 14
          ColorValue = clWhite
          Properties.CustomColors = <>
          TabOrder = 1
          Width = 121
        end
        object cxLabel17: TcxLabel
          Left = 3
          Top = 40
          Caption = 'Dolu'
          Transparent = True
        end
        object ColorComboDolu: TcxColorComboBox
          Left = 158
          Top = 38
          ColorValue = clWhite
          Properties.CustomColors = <>
          TabOrder = 3
          Width = 121
        end
        object cxLabel22: TcxLabel
          Left = 3
          Top = 65
          Caption = 'Rezerve'
          Transparent = True
        end
        object ColorComboRezerve: TcxColorComboBox
          Left = 158
          Top = 62
          ColorValue = clWhite
          Properties.CustomColors = <>
          TabOrder = 5
          Width = 121
        end
        object cxLabel42: TcxLabel
          Left = 3
          Top = 88
          Caption = 'Hesap '#214'deyen'
          Transparent = True
        end
        object ColorComboHesap: TcxColorComboBox
          Left = 158
          Top = 86
          ColorValue = clWhite
          Properties.CustomColors = <>
          TabOrder = 7
          Width = 121
        end
        object cxLabel45: TcxLabel
          Left = 3
          Top = 111
          Caption = 'Birle'#351'mi'#351
          Transparent = True
        end
        object ColorComboBirles: TcxColorComboBox
          Left = 158
          Top = 110
          ColorValue = clWhite
          Properties.CustomColors = <>
          TabOrder = 9
          Width = 121
        end
      end
      object cxGroupBox8: TcxGroupBox
        Left = 335
        Top = 304
        Caption = 'Servis (Garsoniye) '#220'creti'
        TabOrder = 4
        Height = 90
        Width = 206
        object CheckServis: TcxCheckBox
          Left = 5
          Top = 13
          Caption = 'Servis eklensin'
          ParentFont = False
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -9
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          Transparent = True
          Width = 129
        end
        object cxLabel43: TcxLabel
          Left = 5
          Top = 37
          Caption = 'Oran %'
          Transparent = True
        end
        object EditServisOran: TcxSpinEdit
          Left = 121
          Top = 36
          Properties.ImmediatePost = True
          Properties.MaxValue = 20.000000000000000000
          Properties.MinValue = 2.000000000000000000
          TabOrder = 2
          Value = 10
          Width = 43
        end
        object cxLabel44: TcxLabel
          Left = 5
          Top = 62
          Caption = #304#351'lem Kodu'
          Transparent = True
        end
        object EditServisKod: TcxButtonEdit
          Left = 121
          Top = 61
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = EditServisKodPropertiesButtonClick
          TabOrder = 4
          Width = 82
        end
      end
      object CheckRezervasyon: TcxCheckBox
        Left = 335
        Top = 397
        Caption = 'Rezervasyon Kullan'#305'ls'#305'n'
        ParentFont = False
        State = cbsChecked
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -15
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 5
        Transparent = True
        Width = 188
      end
      object cxGroupBox9: TcxGroupBox
        Left = 338
        Top = 183
        Caption = 'A'#231#305'k Masalarda G'#246'sterilecek'
        TabOrder = 6
        Height = 120
        Width = 202
        object CheckGarsonAdi: TcxCheckBox
          Left = 3
          Top = 16
          Caption = 'Garson Ad'#305
          State = cbsChecked
          TabOrder = 0
          Transparent = True
          Width = 182
        end
        object CheckKisiSay: TcxCheckBox
          Left = 3
          Top = 36
          Caption = 'Ki'#351'i say'#305's'#305
          State = cbsChecked
          TabOrder = 1
          Transparent = True
          Width = 182
        end
        object CheckAcilisZamani: TcxCheckBox
          Left = 4
          Top = 56
          Caption = 'A'#231#305'l'#305#351' Zaman'#305
          State = cbsChecked
          TabOrder = 2
          Transparent = True
          Width = 182
        end
        object CheckGecenZaman: TcxCheckBox
          Left = 4
          Top = 75
          Caption = 'Ge'#231'en Zaman'
          State = cbsChecked
          TabOrder = 3
          Transparent = True
          Width = 182
        end
        object CheckMasaTutar: TcxCheckBox
          Left = 3
          Top = 94
          Caption = 'Masa Tutar'#305
          State = cbsChecked
          TabOrder = 4
          Transparent = True
          Width = 182
        end
      end
      object CheckSiparisYazKapansin: TcxCheckBox
        Left = 335
        Top = 426
        Caption = 'Sipari'#351'i yaz'#305'nca ekran kapans'#305'n'
        ParentFont = False
        State = cbsChecked
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -15
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 7
        Transparent = True
        Width = 235
      end
      object CheckHesapYazKapansin: TcxCheckBox
        Left = 335
        Top = 453
        Caption = 'Hesap yaz'#305'nca ekran kapans'#305'n'
        ParentFont = False
        State = cbsChecked
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -15
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 8
        Transparent = True
        Width = 225
      end
      object BtnTakipTurleri: TcxButton
        Left = 22
        Top = 274
        Width = 257
        Height = 25
        Caption = 'Adisyon Durumlar'#305
        LookAndFeel.NativeStyle = False
        TabOrder = 9
        OnClick = BtnTakipTurleriClick
      end
      object cxGroupBox10: TcxGroupBox
        Left = 15
        Top = 308
        Caption = 'Adisyon Varsay'#305'lan Durumlar'
        TabOrder = 10
        Height = 176
        Width = 267
        object Label2: TLabel
          Left = 17
          Top = 27
          Width = 20
          Height = 13
          Caption = 'Yeni'
        end
        object Label3: TLabel
          Left = 17
          Top = 54
          Width = 102
          Height = 13
          Caption = 'Sipari'#351' yazd'#305'r bas'#305'nca'
        end
        object Label4: TLabel
          Left = 17
          Top = 81
          Width = 72
          Height = 13
          Caption = 'Kurye atan'#305'nca'
        end
        object Label5: TLabel
          Left = 17
          Top = 108
          Width = 65
          Height = 13
          Caption = #304'ptal bas'#305'l'#305'nca'
        end
        object Label6: TLabel
          Left = 17
          Top = 135
          Width = 65
          Height = 13
          Caption = 'Tahsil edilince'
        end
        object ComboSiparisYeni: TcxImageComboBox
          Left = 143
          Top = 23
          RepositoryItem = Tablo.RepAdisyon
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 0
          Width = 121
        end
        object ComboSiparisYaz: TcxImageComboBox
          Left = 143
          Top = 50
          RepositoryItem = Tablo.RepAdisyon
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 1
          Width = 121
        end
        object ComboSiparisKurye: TcxImageComboBox
          Left = 143
          Top = 77
          RepositoryItem = Tablo.RepAdisyon
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 2
          Width = 121
        end
        object ComboSiparisIptal: TcxImageComboBox
          Left = 143
          Top = 104
          RepositoryItem = Tablo.RepAdisyon
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 3
          Width = 121
        end
        object ComboSiparisTahsil: TcxImageComboBox
          Left = 143
          Top = 131
          RepositoryItem = Tablo.RepAdisyon
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 4
          Width = 121
        end
      end
    end
    object TabSheetSecimler: TcxTabSheet
      Caption = 'Se'#231'imler'
      ImageIndex = 19
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar13: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 570
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
        ExplicitWidth = 566
        object SecimYeni: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = SecimYeniClick
        end
        object SecimSil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SecimSilClick
        end
        object ToolButton12: TToolButton
          Left = 124
          Top = 0
          Width = 13
          Caption = 'ToolButton1'
          ImageIndex = 4
          Style = tbsSeparator
        end
        object SecimKaydet: TToolButton
          Left = 137
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = SecimKaydetClick
        end
        object SecimIptal: TToolButton
          Left = 199
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = SecimIptalClick
        end
        object cxLabel55: TcxLabel
          Left = 261
          Top = 1
          Caption = '             '
          Transparent = True
        end
      end
      object PageControlSecim: TcxPageControl
        Left = 0
        Top = 27
        Width = 576
        Height = 23
        Align = alTop
        TabOrder = 1
        Properties.ActivePage = TabSheetTekli
        Properties.CustomButtons.Buttons = <>
        OnChange = PageControlSecimChange
        ExplicitWidth = 572
        ClientRectRight = 0
        ClientRectTop = 0
        object TabSheetTekli: TcxTabSheet
          Caption = 'Tekli Se'#231'im'
          ImageIndex = 19
        end
        object TabSheetCoklu: TcxTabSheet
          Caption = #199'oklu Se'#231'im'
          ImageIndex = 19
        end
      end
      object GridSecimDetay: TcxGrid
        Left = 0
        Top = 257
        Width = 576
        Height = 230
        Align = alClient
        TabOrder = 2
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        ExplicitWidth = 572
        ExplicitHeight = 229
        object GridSecimDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsSecimDetay
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridEkstraACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'SECIMADI'
            Width = 259
          end
          object GridEkstraMIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 69
          end
          object GridEkstraBIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.repStokAnaBirim
          end
          object GridEkstraTUTAR: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;'
            Width = 75
          end
          object GridSecimDetayViewSECILI: TcxGridDBColumn
            Caption = 'Se'#231'ili'
            DataBinding.FieldName = 'SECILI'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 41
          end
        end
        object cxGridLevel9: TcxGridLevel
          GridView = GridSecimDetayView
        end
      end
      object GridSecim: TcxGrid
        Left = 0
        Top = 50
        Width = 576
        Height = 180
        Align = alTop
        PopupMenu = PopupSecim
        TabOrder = 3
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        ExplicitWidth = 572
        object GridSecimView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsSecim
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsSelection.HideFocusRectOnExit = False
          OptionsSelection.MultiSelect = True
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridEkstraOzellikACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'SECIMADI'
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 358
          end
          object GridSecimViewZORUNLU: TcxGridDBColumn
            Caption = 'Zorunlu'
            DataBinding.FieldName = 'ZORUNLU'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Width = 44
          end
        end
        object cxGridLevel12: TcxGridLevel
          GridView = GridSecimView
        end
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 233
        Width = 570
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
        TabOrder = 4
        Transparent = True
        ExplicitWidth = 566
        object SecimDetayYeni: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = SecimDetayYeniClick
        end
        object SecimDetaySil: TToolButton
          Left = 62
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SecimDetaySilClick
        end
        object ToolButton3: TToolButton
          Left = 124
          Top = 0
          Width = 13
          Caption = 'ToolButton1'
          ImageIndex = 4
          Style = tbsSeparator
        end
        object SecimDetayKaydet: TToolButton
          Left = 137
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = SecimDetayKaydetClick
        end
        object SecimDetayIptal: TToolButton
          Left = 199
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = SecimDetayIptalClick
        end
        object cxLabel56: TcxLabel
          Left = 261
          Top = 1
          Caption = '             '
          Transparent = True
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 514
    Width = 580
    Height = 38
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 1
    object CancelBtn: TBitBtn
      Left = 462
      Top = 6
      Width = 72
      Height = 24
      Cancel = True
      Caption = 'Ka&pat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000220B0000220B000000010000000100000031DE000031
        E7000031EF000031F700FF00FF000031FF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00040404040404
        0404040404040404000004000004040404040404040404000004040000000404
        0404040404040000040404000000000404040404040000040404040402000000
        0404040400000404040404040404000000040000000404040404040404040400
        0101010004040404040404040404040401010204040404040404040404040400
        0201020304040404040404040404030201040403030404040404040404050203
        0404040405030404040404040303050404040404040303040404040303030404
        0404040404040403040403030304040404040404040404040404030304040404
        0404040404040404040404040404040404040404040404040404}
      Margin = 2
      ModalResult = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 1
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 383
      Top = 6
      Width = 73
      Height = 24
      Caption = '&Kaydet'
      Default = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000D30E0000D30E00000001000000010000008C00000094
        0000009C000000A5000000940800009C100000AD100000AD180000AD210000B5
        210000BD210018B5290000C62900319C310000CE310029AD390031B5420018C6
        420000D6420052A54A0029AD4A0029CE5A006BB5630000FF63008CBD7B00A5C6
        94005AE7A500FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF001B1B1B1B1B13
        04161B1B1B1B1B1B1B1B1B1B1B1B1B0B0A01181B1B1B1B1B1B1B1B1B1B1B160A
        0C030D1B1B1B1B1B1B1B1B1B1B1B050E0C0601191B1B1B1B1B1B1B1B1B130E0C
        170E02001B1B1B1B1B1B1B1B1B0B1517170A0C01181B1B1B1B1B1B1B1B111717
        13130C030D1B1B1B1B1B1B1B1B1B08081B1B070C01191B1B1B1B1B1B1B1B1B1B
        1B1B100C02001B1B1B1B1B1B1B1B1B1B1B1B1B090C01181B1B1B1B1B1B1B1B1B
        1B1B1B130C0F101B1B1B1B1B1B1B1B1B1B1B1B1B141A0F181B1B1B1B1B1B1B1B
        1B1B1B1B1012181B1B1B1B1B1B1B1B1B1B1B1B1B1B191B1B1B1B1B1B1B1B1B1B
        1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B}
      Margin = 2
      ModalResult = 1
      ParentFont = False
      Spacing = -1
      TabOrder = 0
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object DtsSecim: TDataSource
    DataSet = TabSecim
    OnStateChange = DtsSecimStateChange
    Left = 440
    Top = 167
  end
  object TabSecim: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabSecimBeforePost
    AfterScroll = TabSecimAfterScroll
    OnNewRecord = TabSecimNewRecord
    ParamData = <>
    SQL.Strings = (
      'select *  from SECIMLER where TUR=:Prm and BAGID=0 order by 1')
    Left = 423
    Top = 228
  end
  object TabSecimDetay: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabSecimDetayNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from SECIMLER where BAGID=:Prm order by SECIMADI')
    Left = 303
    Top = 276
  end
  object DtsSecimDetay: TDataSource
    DataSet = TabSecimDetay
    OnStateChange = DtsSecimDetayStateChange
    Left = 472
    Top = 151
  end
  object PopupSecim: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 264
    Top = 168
    object MenuKopyala: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = MenuKopyalaClick
    end
  end
end

