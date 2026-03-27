object BankaFTPBilgileriDLG: TBankaFTPBilgileriDLG
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Banka FTP Bilgileri'
  ClientHeight = 448
  ClientWidth = 758
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 752
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
    TabOrder = 0
    Transparent = True
    object KaydetTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 70
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      OnClick = IptalTusClick
    end
    object ToolButton1: TToolButton
      Left = 140
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object btnIptal: TToolButton
      Left = 148
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnIptalClick
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 35
    Width = 758
    Height = 413
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 409
    ClientRectLeft = 4
    ClientRectRight = 754
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Ba'#287'lant'#305' Olu'#351'turma'
      ImageIndex = 0
      object RadioGuvenlikTuru: TcxDBRadioGroup
        Left = 3
        Top = 3
        Align = alCustom
        Caption = 'FTP Guvenlik Turu'
        DataBinding.DataField = 'FTP_GUVENLIK_TURU'
        DataBinding.DataSource = DtsFTP
        Properties.Columns = 3
        Properties.Items = <
          item
            Caption = 'Yok'
            Value = 'Yok'
          end
          item
            Caption = 'SSL'
            Value = 'SSL'
          end
          item
            Caption = 'SSH'
            Value = 'SSH'
          end>
        Style.BorderColor = clBtnFace
        TabOrder = 0
        OnClick = RadioGuvenlikTuruClick
        Height = 53
        Width = 314
      end
      object cxGroupBox2: TcxGroupBox
        Left = 3
        Top = 62
        Caption = 'Sunucu Bilgileri'
        TabOrder = 1
        DesignSize = (
          314
          211)
        Height = 211
        Width = 314
        object LabelAdres: TcxLabel
          Left = 9
          Top = 21
          Caption = 'Ftp Sunucu Adresi:'
          Transparent = True
        end
        object LabelFTP: TcxLabel
          Left = 9
          Top = 42
          AutoSize = False
          Caption = 'Ftp://'
          Height = 21
          Width = 32
        end
        object EditAdres: TcxDBTextEdit
          Left = 38
          Top = 41
          Hint = #214'r: ftp.genyazilim.com'
          Anchors = [akLeft, akTop, akRight]
          DataBinding.DataField = 'FTP_ADRES'
          DataBinding.DataSource = DtsFTP
          TabOrder = 2
          Width = 206
        end
        object EditDizin: TcxDBTextEdit
          Left = 9
          Top = 86
          Hint = 'i'#231'erik, "/klas'#246'r ad'#305'/klas'#246'r ad'#305'/..../" '#351'eklinde yaz'#305'lmal'#305
          Anchors = [akLeft, akTop, akRight]
          DataBinding.DataField = 'FTP_DIZIN'
          DataBinding.DataSource = DtsFTP
          TabOrder = 3
          Width = 235
        end
        object LabelDizin: TcxLabel
          Left = 9
          Top = 68
          Caption = 'Ftp Dosya Yolu(G'#246'nderilecek):'
          Transparent = True
        end
        object LabelIkinokta: TcxLabel
          Left = 246
          Top = 42
          Anchors = [akTop, akRight]
          Caption = ':'
        end
        object LabelPort: TcxLabel
          Left = 244
          Top = 21
          Anchors = [akTop, akRight]
          Caption = 'Port:'
          Transparent = True
        end
        object DBEdit1: TcxDBTextEdit
          Left = 257
          Top = 41
          Hint = 'Genelde; Ftp i'#231'in 21,SSH i'#231'in 22 dir. '
          Anchors = [akTop, akRight]
          DataBinding.DataField = 'FTP_PORT'
          DataBinding.DataSource = DtsFTP
          TabOrder = 7
          Width = 50
        end
        object EditDizin2: TcxDBTextEdit
          Left = 9
          Top = 129
          Hint = 'i'#231'erik, "/klas'#246'r ad'#305'/klas'#246'r ad'#305'/..../" '#351'eklinde yaz'#305'lmal'#305
          Anchors = [akLeft, akTop, akRight]
          DataBinding.DataField = 'FTP_DIZIN_AKIBET'
          DataBinding.DataSource = DtsFTP
          TabOrder = 8
          Width = 235
        end
        object cxLabel9: TcxLabel
          Left = 9
          Top = 111
          Caption = 'Ftp Dosya Yolu(Al'#305'nacak):'
          Transparent = True
        end
      end
      object cxGroupBox4: TcxGroupBox
        Left = 323
        Top = 129
        Caption = 'Kullan'#305'c'#305' Bilgileri'
        TabOrder = 3
        DesignSize = (
          269
          144)
        Height = 144
        Width = 269
        object LabelUser: TcxLabel
          Left = 5
          Top = 63
          Caption = 'Kullan'#305'c'#305' Ad'#305':'
          Transparent = True
        end
        object EditUser: TcxDBTextEdit
          Left = 103
          Top = 62
          DataBinding.DataField = 'FTP_USER'
          DataBinding.DataSource = DtsFTP
          TabOrder = 1
          Width = 163
        end
        object LabelPassword: TcxLabel
          Left = 5
          Top = 115
          Caption = #350'ifre:'
          Transparent = True
        end
        object EditPassword: TcxDBTextEdit
          Left = 103
          Top = 114
          Anchors = [akLeft, akTop, akRight]
          DataBinding.DataField = 'FTP_PASSWORD'
          DataBinding.DataSource = DtsFTP
          TabOrder = 3
          Width = 158
        end
        object BtnPrivateKey: TcxButton
          Left = 103
          Top = 89
          Width = 92
          Height = 23
          Caption = 'Dosyay'#305' Al'
          TabOrder = 4
          Visible = False
          OnClick = BtnPrivateKeyClick
        end
        object LabelOzelAnahtar: TcxLabel
          Left = 5
          Top = 89
          Caption = #214'zel Anahtar '#304#231'in;'
          Transparent = True
          Visible = False
        end
        object RadioKimlikDogrulamasi: TcxDBRadioGroup
          Left = 5
          Top = 19
          Caption = 'Kimlik Do'#287'rulamas'#305' T'#252'r'#252
          DataBinding.DataField = 'FTP_AUTHENTICATION'
          DataBinding.DataSource = DtsFTP
          Properties.Columns = 2
          Properties.Items = <
            item
              Caption = 'Parola'
              Value = False
            end
            item
              Caption = 'Dosya'
              Value = True
            end>
          TabOrder = 6
          OnClick = RadioKimlikDogrulamasiClick
          Height = 38
          Width = 261
        end
      end
      object GroupSSL: TcxGroupBox
        Left = 323
        Top = 3
        Caption = 'SSL Ayarlar'#305
        TabOrder = 4
        Height = 116
        Width = 269
      end
      object GroupSSH: TcxGroupBox
        Left = 323
        Top = 3
        Caption = 'SSH Ayarlar'#305
        TabOrder = 2
        Height = 120
        Width = 269
        object LabelSSH2: TcxLabel
          Left = 5
          Top = 60
          Caption = 'Anh. Ad'#305':'
          Transparent = True
        end
        object EditAnahtarAdi: TcxDBTextEdit
          Left = 82
          Top = 59
          DataBinding.DataField = 'FTP_HOST_KEY_NAME'
          DataBinding.DataSource = DtsFTP
          TabOrder = 1
          Width = 184
        end
        object EditAnahtarSifresi: TcxDBTextEdit
          Left = 82
          Top = 86
          DataBinding.DataField = 'FTP_HOST_KEY_PASSWORD'
          DataBinding.DataSource = DtsFTP
          TabOrder = 2
          Width = 184
        end
        object LabelSSH3: TcxLabel
          Left = 5
          Top = 87
          Caption = 'Anh. '#350'ifresi:'
          Transparent = True
        end
        object CheckGroupSSHAnahtar: TcxDBCheckGroup
          Left = 5
          Top = 16
          Caption = #214'zel Anahtar Algoritmas'#305
          Properties.Columns = 2
          Properties.EditValueFormat = cvfInteger
          Properties.Items = <
            item
              Caption = 'ssh-dss'
            end
            item
              Caption = 'ssh-rsa'
            end>
          TabOrder = 4
          DataBinding.DataField = 'FTP_HOST_KEY_ALGORITHM'
          DataBinding.DataSource = DtsFTP
          Height = 38
          Width = 261
        end
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'Dosya Olu'#351'turma'
      ImageIndex = 1
      object cxGroupBox1: TcxGroupBox
        Left = 3
        Top = 3
        Caption = 'Banka Deseni (Txt Dosya)'
        TabOrder = 0
        Height = 123
        Width = 348
        object CheckBankaDeseniOlustur: TcxDBCheckBox
          Left = 1
          Top = 34
          Caption = 'Olustur'
          DataBinding.DataField = 'TEXT_OLUSTUR'
          DataBinding.DataSource = DtsFTP
          Properties.NullStyle = nssUnchecked
          TabOrder = 0
          Transparent = True
          OnClick = CheckBankaDeseniOlusturClick
          Width = 121
        end
        object CheckBankaDeseniImzala: TcxDBCheckBox
          Left = 1
          Top = 55
          Caption = 'Mobil '#304'mza Ekle'
          DataBinding.DataField = 'TEXT_IMZALA'
          DataBinding.DataSource = DtsFTP
          Properties.NullStyle = nssUnchecked
          TabOrder = 1
          Transparent = True
          OnClick = CheckBankaDeseniImzalaClick
          Width = 111
        end
        object cxLabel2: TcxLabel
          Left = 2
          Top = 18
          Caption = 'Dosya'
        end
        object RadioTextGonder: TcxDBRadioGroup
          Left = 163
          Top = 18
          DataBinding.DataField = 'TEXT_GONDER'
          DataBinding.DataSource = DtsFTP
          Properties.Items = <
            item
              Caption = 'G'#246'nderme'
              Value = 0
            end
            item
              Caption = 'FTPye G'#246'nder'
              Value = 1
            end
            item
              Caption = 'SFTPye G'#246'nder(SSH)'
              Value = 2
            end
            item
              Caption = 'FTPSe G'#246'nder(SSL)'
              Value = 3
            end>
          Style.BorderStyle = ebsNone
          TabOrder = 4
          Transparent = True
          Height = 76
          Width = 174
        end
        object cxLabel1: TcxLabel
          Left = 184
          Top = 21
          Caption = 'G'#246'nderim'
        end
        object CheckTextEmail: TcxDBCheckBox
          Left = 165
          Top = 97
          Caption = 'E-Posta '#304'le de G'#246'nder'
          DataBinding.DataField = 'TEXT_EMAIL'
          DataBinding.DataSource = DtsFTP
          Properties.OnEditValueChanged = CheckTalimatEmailPropertiesEditValueChanged
          TabOrder = 5
          Transparent = True
          Width = 172
        end
      end
      object cxGroupBox6: TcxGroupBox
        Left = 3
        Top = 130
        Caption = 'Talimat (PDF Dosya)'
        TabOrder = 1
        Height = 123
        Width = 348
        object CheckTalimatOlustur: TcxDBCheckBox
          Left = 0
          Top = 37
          Caption = 'Olustur'
          DataBinding.DataField = 'TALIMAT_OLUSTUR'
          DataBinding.DataSource = DtsFTP
          Properties.NullStyle = nssUnchecked
          TabOrder = 0
          Transparent = True
          OnClick = CheckTalimatOlusturClick
          Width = 121
        end
        object CheckTalimatImzala: TcxDBCheckBox
          Left = 0
          Top = 56
          Caption = 'Mobil '#304'mza Ekle'
          DataBinding.DataField = 'TALIMAT_IMZALA'
          DataBinding.DataSource = DtsFTP
          Properties.NullStyle = nssUnchecked
          TabOrder = 1
          Transparent = True
          OnClick = CheckBankaDeseniImzalaClick
          Width = 111
        end
        object cxLabel3: TcxLabel
          Left = 0
          Top = 19
          Caption = 'Dosya'
        end
        object RadioTalimatGonder: TcxDBRadioGroup
          Left = 156
          Top = 14
          DataBinding.DataField = 'TALIMAT_GONDER'
          DataBinding.DataSource = DtsFTP
          Properties.Items = <
            item
              Caption = 'G'#246'nderme'
              Value = 0
            end
            item
              Caption = 'FTPye G'#246'nder'
              Value = 1
            end
            item
              Caption = 'SFTPye G'#246'nder(SSH)'
              Value = 2
            end
            item
              Caption = 'FTPSe G'#246'nder(SSL)'
              Value = 3
            end>
          Style.BorderStyle = ebsNone
          TabOrder = 4
          Transparent = True
          Height = 76
          Width = 181
        end
        object cxLabel4: TcxLabel
          Left = 167
          Top = 19
          Caption = 'G'#246'nderim'
        end
        object CheckTalimatEmail: TcxDBCheckBox
          Left = 165
          Top = 96
          Caption = 'E-Posta '#304'le de G'#246'nder'
          DataBinding.DataField = 'TALIMAT_EMAIL'
          DataBinding.DataSource = DtsFTP
          Properties.OnEditValueChanged = CheckTalimatEmailPropertiesEditValueChanged
          TabOrder = 5
          Transparent = True
          Width = 172
        end
      end
      object GroupBoxEImza: TcxGroupBox
        Left = 357
        Top = 1
        Caption = 'Mobil '#304'mza Ekleme'
        TabOrder = 2
        Height = 123
        Width = 236
        object cxDBRadioGroup1: TcxDBRadioGroup
          Left = 3
          Top = 17
          Caption = 'GSM Operat'#246'r'#252
          DataBinding.DataField = 'IMZA_GSM_OP'
          DataBinding.DataSource = DtsFTP
          Properties.Items = <
            item
              Caption = 'Turkcell                            (Destekleniyor)'
              Value = 1
            end
            item
              Caption = 'Avea                                 (Destekleniyor)'
              Value = 2
            end
            item
              Caption = 'VodaFone                      (Desteklenmiyor)'
              Value = 3
            end>
          TabOrder = 0
          Height = 74
          Width = 229
        end
        object cxLabel5: TcxLabel
          Left = 5
          Top = 95
          Caption = 'GSM:'
        end
        object cxDBTextEdit1: TcxDBTextEdit
          Left = 38
          Top = 94
          DataBinding.DataField = 'IMZA_GSM'
          DataBinding.DataSource = DtsFTP
          TabOrder = 2
          Width = 194
        end
      end
      object GroupBoxEPosta: TcxGroupBox
        Left = 357
        Top = 130
        Caption = 'E-Posta Bilgileri'
        TabOrder = 3
        Height = 123
        Width = 236
        object EditKime: TcxDBTextEdit
          Left = 38
          Top = 40
          DataBinding.DataField = 'MAIL_TO'
          DataBinding.DataSource = DtsFTP
          TabOrder = 0
          Width = 194
        end
        object EditBilgi: TcxDBTextEdit
          Left = 38
          Top = 65
          DataBinding.DataField = 'MAIL_CC'
          DataBinding.DataSource = DtsFTP
          TabOrder = 1
          Width = 194
        end
        object EditGizli: TcxDBTextEdit
          Left = 38
          Top = 90
          DataBinding.DataField = 'MAIL_BCC'
          DataBinding.DataSource = DtsFTP
          TabOrder = 2
          Width = 194
        end
        object cxLabel6: TcxLabel
          Left = 0
          Top = 40
          Caption = 'Kime'
        end
        object cxLabel7: TcxLabel
          Left = 0
          Top = 66
          Caption = 'Bilgi'
        end
        object cxLabel8: TcxLabel
          Left = 0
          Top = 91
          Caption = 'Gizli'
        end
      end
    end
    object SheetExtre: TcxTabSheet
      Caption = 'Ekstre Bilgileri'
      ImageIndex = 2
      object EditExKullaniciAdi: TcxDBTextEdit
        Left = 117
        Top = 116
        DataBinding.DataField = 'EKSTREKULLANICI'
        DataBinding.DataSource = DtsFTP
        TabOrder = 0
        Width = 121
      end
      object EditExSifre: TcxDBTextEdit
        Left = 117
        Top = 143
        DataBinding.DataField = 'EKSTRESIFRE'
        DataBinding.DataSource = DtsFTP
        TabOrder = 1
        Width = 121
      end
      object cxLabel10: TcxLabel
        Left = 5
        Top = 144
        Caption = #350'ifre:'
        Transparent = True
      end
      object cxLabel11: TcxLabel
        Left = 5
        Top = 117
        Caption = 'Kullan'#305'c'#305' Ad'#305':'
        Transparent = True
      end
      object CheckExtSor: TcxDBCheckBox
        Left = 5
        Top = 91
        Caption = 'Her seferinde sor.'
        DataBinding.DataField = 'EKSTREHERSEFERINDESOR'
        DataBinding.DataSource = DtsFTP
        Properties.NullStyle = nssUnchecked
        Properties.OnEditValueChanged = CheckExtSorPropertiesEditValueChanged
        TabOrder = 4
        Width = 121
      end
      object cxLabel12: TcxLabel
        Left = 5
        Top = 38
        Caption = 'Servis ID:'
        Transparent = True
      end
      object EditExServisID: TcxDBTextEdit
        Left = 117
        Top = 37
        DataBinding.DataField = 'EKSTRESERVISID'
        DataBinding.DataSource = DtsFTP
        TabOrder = 6
        Width = 121
      end
      object EditExAnahtar: TcxDBTextEdit
        Left = 117
        Top = 63
        DataBinding.DataField = 'EKSTREANAHTAR'
        DataBinding.DataSource = DtsFTP
        TabOrder = 7
        Width = 121
      end
      object cxLabel13: TcxLabel
        Left = 5
        Top = 64
        Caption = 'Anahtar:'
        Transparent = True
      end
      object EditExFirmaAdi: TcxDBTextEdit
        Left = 117
        Top = 11
        DataBinding.DataField = 'EKSTREFIRMAADI'
        DataBinding.DataSource = DtsFTP
        TabOrder = 9
        Width = 121
      end
      object cxLabel14: TcxLabel
        Left = 5
        Top = 12
        Caption = 'FirmaAd'#305':'
        Transparent = True
      end
    end
  end
  object DtsFTP: TDataSource
    DataSet = TabFTP
    OnStateChange = DtsFTPStateChange
    Left = 376
    Top = 7
  end
  object TabFTP: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabFTPBeforePost
    OnNewRecord = TabFTPNewRecord
    ParamData = <
      item
        Name = 'PBKod'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select * from BANKAFTP'
      'where BANKAKODU = :PBKod')
    Left = 420
    Top = 5
  end
  object OpenDialog1: TOpenDialog
    Left = 324
    Top = 6
  end
end

