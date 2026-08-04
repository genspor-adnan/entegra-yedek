object OpsiyonDlg: TOpsiyonDlg
  Left = 444
  Top = 169
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Gentegre Se'#231'enekleri'
  ClientHeight = 582
  ClientWidth = 706
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object Label1: TLabel
    Left = 24
    Top = 416
    Width = 32
    Height = 16
    Caption = 'Label1'
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 706
    Height = 540
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'Genel Ayarlar'
      object Label10: TLabel
        Left = 6
        Top = 385
        Width = 107
        Height = 16
        Caption = 'Varsay'#305'lan Para Birimi'
      end
      object Label2: TLabel
        Left = 174
        Top = 385
        Width = 113
        Height = 16
        Caption = 'Varsay'#305'lan D'#246'viz Birimi'
      end
      object GroupBox3: TGroupBox
        Left = 4
        Top = 105
        Width = 444
        Height = 45
        Caption = 'Seyir Defteri'
        TabOrder = 4
        object Label5: TLabel
          Left = 4
          Top = 19
          Width = 17
          Height = 16
          Caption = 'Son'
        end
        object Label4: TLabel
          Left = 67
          Top = 19
          Width = 113
          Height = 16
          Caption = 'g'#252'n'#252'n bilgileri tutulsun'
        end
        object Ekleme: TCheckBox
          Left = 189
          Top = 17
          Width = 65
          Height = 17
          Caption = 'Ekleme'
          TabOrder = 1
        end
        object Silme: TCheckBox
          Left = 266
          Top = 17
          Width = 84
          Height = 17
          Caption = 'Silme'
          TabOrder = 2
        end
        object Degistirme: TCheckBox
          Left = 356
          Top = 17
          Width = 84
          Height = 17
          Caption = 'De'#287'i'#351'tirme'
          TabOrder = 3
        end
        object LogGunSay: TEdit
          Left = 25
          Top = 16
          Width = 39
          Height = 24
          TabOrder = 0
          Text = '0'
        end
      end
      object GroupBox2: TGroupBox
        Left = 4
        Top = 66
        Width = 444
        Height = 42
        Caption = 'Dok'#252'man Dizini'
        TabOrder = 3
        object DokumanDizin: TcxButtonEdit
          Left = 93
          Top = 13
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = False
          Properties.OnButtonClick = DokumanDizinPropertiesButtonClick
          TabOrder = 0
          Width = 210
        end
        object cxButton1: TcxButton
          Left = 309
          Top = 12
          Width = 130
          Height = 25
          Caption = 'Klas'#246're kay'#305't yetkisi ver'
          TabOrder = 1
          OnClick = cxButton1Click
        end
      end
      object BitBtn1: TBitBtn
        Left = 140
        Top = 2
        Width = 171
        Height = 25
        Caption = 'Gentegre Bilgilerini Ayarlama'
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000420B0000420B00000001000000010000000000000084
          0000210021005A4A29004A3939005A5242004A4A4A005A524A0073524A005A52
          52006300630073737300BD847B00C6947B00CE9C7B00B58484009C948400BD94
          9400EFCE9400F7CE9400C6A59C00EFCE9C00F7CE9C00F7D69C00C6ADA500CEAD
          A500F7D6A500C6ADAD00CEB5AD00D6B5AD00EFD6AD00F7D6AD00C6B5B500D6BD
          B500DEBDB500DEC6B500E7C6B500EFC6B500EFCEB500F7D6B500F7DEB500D6C6
          BD00DECEBD00EFCEBD00F7DEBD0000C6C600C6C6C600D6CEC600F7DEC600F7E7
          C600E7CECE00E7D6CE00F7E7CE00E7D6D600F7E7D600FFE7D600FFEFD600FFEF
          DE00FFEFE700FFF7E70021F7EF00FFF7EF0018F7F700FFF7F700FFFFF700FF00
          FF0000FFFF0021FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0041410F0F0F0F
          0F0F0F0F0F0F0F0F0F4141411438312C281E1A15121212170F41414114382E2E
          2E2E2E2E2E2E2E150F414141183A3634302C1E15151512150F414141183B3634
          31302805151515120F4141411C402E2E2E2E2E06002E2E150F4141411D443D3A
          363431070000291E0F41414121443F3D39363407422D00290F41414121442E2E
          2E2E2E0B3E2D002911414141224444443F3A393609422D001B41414123444444
          443F3A3910432D002041414124442E2E2E2E2E2E3604422D0041414124444444
          4444444032083C2D004141412B44444444444444330D030001004141243F3D3D
          3D3D3D3D320D0801010241412426262626242426210C410A0A41}
        TabOrder = 1
        Visible = False
        OnClick = BitBtn1Click
      end
      object CheckDovizPanelGor: TCheckBox
        Left = 3
        Top = 316
        Width = 360
        Height = 9
        Caption = 'G'#252'nl'#252'k d'#246'viz kurlar'#305' kasa ekran'#305'nda g'#246'r'#252'ns'#252'n'
        TabOrder = 7
      end
      object CheckDovizOtoGuncelle: TCheckBox
        Left = 7
        Top = 357
        Width = 432
        Height = 17
        Caption = 'Program a'#231#305'l'#305#351#305'nda d'#246'viz kurlar'#305'n'#305' otomatik olarak g'#252'ncelle'
        TabOrder = 11
      end
      object cxLabel3: TcxLabel
        Left = 6
        Top = 332
        Caption = 
          'Varsay'#305'lan kur olarak                                           ' +
          '           kullan.'
        Transparent = True
      end
      object ComboDefaultDoviz: TcxImageComboBox
        Left = 115
        Top = 331
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
        TabOrder = 8
        Width = 156
      end
      object BtnYilSonuDevir: TcxButton
        Left = 345
        Top = 424
        Width = 154
        Height = 23
        Caption = 'Y'#305'l Sonu Devir '#304#351'lemleri'
        TabOrder = 15
        OnClick = BtnYilSonuDevirClick
      end
      object btnEntegrasyonEslestirme: TcxButton
        Left = 345
        Top = 396
        Width = 154
        Height = 25
        Caption = 'Entegrasyon E'#351'le'#351'tirme'
        TabOrder = 12
        OnClick = btnEntegrasyonEslestirmeClick
      end
      object BtnBaglantiDuzenle: TcxButton
        Left = 345
        Top = 367
        Width = 154
        Height = 25
        Caption = 'Ba'#287'lant'#305' Bilgilerini D'#252'zenle'
        TabOrder = 9
        OnClick = BtnBaglantiDuzenleClick
      end
      object BtnGENINI: TcxButton
        Left = 4
        Top = 2
        Width = 91
        Height = 25
        Caption = '...'
        TabOrder = 0
        OnClick = BtnGENINIClick
      end
      object GroupBox5: TGroupBox
        Left = 4
        Top = 152
        Width = 444
        Height = 48
        Caption = 'Program '#39'Exe'#39'si G'#252'ncelleme'
        TabOrder = 5
        object Label3: TLabel
          Left = 5
          Top = 23
          Width = 35
          Height = 16
          Caption = 'Adresi:'
        end
        object Label6: TLabel
          Left = 319
          Top = 25
          Width = 62
          Height = 16
          Caption = 'Versiyon No '
        end
        object EditGenYazilimIPAdress: TcxTextEdit
          Left = 63
          Top = 21
          TabOrder = 1
          Text = 'genupdate.genyazilim.com:8090'
          Width = 252
        end
        object SEVersiyonNo: TcxSpinEdit
          Left = 385
          Top = 20
          TabOrder = 0
          Width = 55
        end
      end
      object GroupBox4: TGroupBox
        Left = 3
        Top = 204
        Width = 444
        Height = 48
        Caption = 'Program '#304#231'i Mesajla'#351'ma'
        TabOrder = 6
        object Label8: TLabel
          Left = 5
          Top = 23
          Width = 35
          Height = 16
          Caption = 'Adresi:'
        end
        object Label9: TLabel
          Left = 318
          Top = 25
          Width = 27
          Height = 16
          Caption = 'Portu'
        end
        object EdChatAdress: TcxTextEdit
          Left = 57
          Top = 21
          TabOrder = 0
          Text = '192.168.0.101'
          Width = 252
        end
        object EdChatPort: TcxSpinEdit
          Left = 353
          Top = 21
          TabOrder = 1
          Value = 7777
          Width = 87
        end
      end
      object ComboBilgiEposta: TcxImageComboBox
        Left = 164
        Top = 412
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 13
        Width = 151
      end
      object cxLabel44: TcxLabel
        Left = 6
        Top = 413
        Caption = 'Duyuru Bilgilendirme E-Posta'
      end
      object cxLabel45: TcxLabel
        Left = 6
        Top = 442
        Caption = 'Duyuru Bilgilendirme Sms'
      end
      object comboBilgiSms: TcxImageComboBox
        Left = 164
        Top = 440
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 16
        Width = 151
      end
      object BTNDiller: TcxButton
        Left = 359
        Top = 2
        Width = 91
        Height = 25
        Caption = 'Diller'
        TabOrder = 2
        Visible = False
        OnClick = BTNDillerClick
      end
      object cxLabel10: TcxLabel
        Left = 350
        Top = 484
        Caption = 'Kullan'#305'c'#305' '#351'ifre kullan'#305'm'#305
        Visible = False
      end
      object cbSifreYontemi: TcxImageComboBox
        Left = 508
        Top = 482
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'Bo'#351' '#350'ifre Var'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Bo'#351' '#350'ifre Yok'
            Value = 1
          end
          item
            Description = 'Kompleks '#350'ifreye Zorla'
            Value = 2
          end>
        TabOrder = 18
        Visible = False
        Width = 151
      end
      object EditVarsayDoviz: TEdit
        Left = 127
        Top = 380
        Width = 44
        Height = 24
        TabOrder = 20
        Text = 'TL'
      end
      object GroupBox6: TGroupBox
        Left = 0
        Top = 254
        Width = 444
        Height = 48
        Caption = 'Proxy Ayar'
        TabOrder = 21
        object Label11: TLabel
          Left = 5
          Top = 23
          Width = 35
          Height = 16
          Caption = 'Adresi:'
        end
        object Label12: TLabel
          Left = 318
          Top = 25
          Width = 27
          Height = 16
          Caption = 'Portu'
        end
        object EdProxyAdres: TcxTextEdit
          Left = 57
          Top = 21
          TabOrder = 0
          Width = 252
        end
        object EdProxyPort: TcxSpinEdit
          Left = 353
          Top = 21
          TabOrder = 1
          Width = 87
        end
      end
      object EditVarsayYabanci: TEdit
        Left = 295
        Top = 380
        Width = 44
        Height = 24
        TabOrder = 22
        Text = #8364
      end
      object cxLabel18: TcxLabel
        Left = 6
        Top = 469
        Caption = 'Kullan'#305'c'#305' '#351'ifre s'#252'resi'
      end
      object ComboSifreSuresi: TcxImageComboBox
        Left = 164
        Top = 467
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = '1'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = '3'
            Value = 3
          end
          item
            Description = '6'
            Value = 6
          end>
        TabOrder = 24
        Width = 69
      end
      object cxLabel19: TcxLabel
        Left = 239
        Top = 470
        Caption = 'ay'
      end
      object cxLabelListeUzunluk: TcxLabel
        Left = 347
        Top = 454
        Caption = 'Liste sayfa uzunlu'#287'u'
      end
      object SpinListeUzunluk: TcxSpinEdit
        Left = 505
        Top = 452
        Properties.MaxValue = 10000.000000000000000000
        Properties.MinValue = 25.000000000000000000
        TabOrder = 28
        Value = 100
        Width = 69
      end
      object GroupBox7: TGroupBox
        Left = 4
        Top = 27
        Width = 444
        Height = 42
        Caption = '2.Depo DB Ad'#305
        TabOrder = 26
        object EditDepoDBAdi: TcxButtonEdit
          Left = 93
          Top = 13
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = False
          Properties.OnButtonClick = EditDepoDBAdiPropertiesButtonClick
          TabOrder = 0
          Text = 'GENDEPO'
          Width = 210
        end
        object btnDepoKopyala: TcxButton
          Left = 313
          Top = 14
          Width = 75
          Height = 25
          Caption = 'Kopyala'
          TabOrder = 1
          OnClick = btnDepoKopyalaClick
        end
      end
    end
    object TabSheet6: TTabSheet
      Caption = 'Uyar'#305'lar'
      ImageIndex = 5
      object cxDBTreeList1: TcxDBTreeList
        Left = 0
        Top = 81
        Width = 698
        Height = 428
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsUyariAyar
        DataController.ParentField = 'ROOTKOD'
        DataController.KeyField = 'KOD'
        Enabled = False
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        Navigator.Buttons.CustomButtons = <>
        OptionsData.Deleting = False
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 1
        object cxDBTreeListKOD: TcxDBTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Caption.Text = 'Uyar'#305' Kodu'
          DataBinding.FieldName = 'KOD'
          Width = 100
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeList1cACIKLAMA: TcxDBTreeListColumn
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Caption.Text = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
          Width = 248
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeListACIKLAMA: TcxDBTreeListColumn
          PropertiesClassName = 'TcxButtonEditProperties'
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = cxDBTreeList1cxDBTreeListColumn5PropertiesButtonClick
          Caption.Text = 'Aktivite '#350'ablonu'
          DataBinding.FieldName = 'SABLONADI'
          Options.ShowEditButtons = eisbAlways
          Width = 122
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeListZAMAN: TcxDBTreeListColumn
          PropertiesClassName = 'TcxSpinEditProperties'
          Properties.AssignedValues.MinValue = True
          Properties.MaxValue = 30.000000000000000000
          Caption.Text = 'Zaman'
          DataBinding.FieldName = 'ZAMAN'
          Width = 100
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeListZAMANISARETI: TcxDBTreeListColumn
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              ImageIndex = 0
            end
            item
              Description = 'g'#252'n '#246'nce'
              ImageIndex = 0
              Value = False
            end
            item
              Description = 'g'#252'n sonra'
              Value = True
            end>
          Caption.Text = #214'nce/Sonra'
          DataBinding.FieldName = 'ZAMANISARETI'
          Width = 100
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object cxDBTreeListDURUM: TcxDBTreeListColumn
          PropertiesClassName = 'TcxCheckBoxProperties'
          Caption.Text = 'Aktif'
          DataBinding.FieldName = 'DURUM'
          Width = 100
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 698
        Height = 81
        Align = alTop
        TabOrder = 0
        object cxLabel2: TcxLabel
          Left = 429
          Top = 9
          Caption = 'Yeni Aktiviteler (g'#252'n)'
          Transparent = True
        end
        object CheckUyarilarAktif: TcxCheckBox
          Left = 3
          Top = 4
          Caption = #304#351' Listesine Yaz'#305'lan Uyar'#305'lar Aktif '
          Properties.OnEditValueChanged = CheckUyarilarAktifPropertiesEditValueChanged
          TabOrder = 0
          Transparent = True
        end
        object EditYeniKayitSuresi: TcxSpinEdit
          Left = 546
          Top = 7
          Enabled = False
          Properties.MinValue = 5.000000000000000000
          TabOrder = 3
          Value = 5
          Width = 51
        end
        object cxLabel1: TcxLabel
          Left = 234
          Top = 7
          Caption = 'Yenileme S'#252'resi (sn)'
          Transparent = True
        end
        object EditYenilemeSuresi: TcxSpinEdit
          Left = 342
          Top = 6
          Enabled = False
          Properties.MinValue = 1.000000000000000000
          TabOrder = 1
          Value = 1
          Width = 50
        end
        object EditGorunmesin: TcxSpinEdit
          Left = 186
          Top = 39
          Properties.MinValue = 1.000000000000000000
          TabOrder = 5
          Value = 90
          Width = 50
        end
        object cxLabel15: TcxLabel
          Left = 6
          Top = 42
          Caption = 'Panoda ka'#231' g'#252'n '#246'ncesi g'#246'r'#252'nmesin'
          Transparent = True
        end
        object cxLabel17: TcxLabel
          Left = 448
          Top = 35
          Caption = #246'nceden uyar'#305'larda g'#246'r'#252'ns'#252'n'
          Transparent = True
        end
      end
    end
    object shtStiller: TTabSheet
      Caption = 'Stiller'
      ImageIndex = 5
      OnShow = shtStillerShow
      object pageStil: TPageControl
        Left = 0
        Top = 0
        Width = 698
        Height = 509
        ActivePage = TabSheet5
        Align = alClient
        TabOrder = 0
        OnChange = pageStilChange
        object TabSheet5: TTabSheet
          Caption = 'Stiller'
          object gridStilTanim: TcxGrid
            Left = 0
            Top = 27
            Width = 690
            Height = 451
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            object tvStilTanim: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dtsStiller
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              object clmStilId: TcxGridDBColumn
                Caption = 'Id'
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 45
              end
              object clmStilAdi: TcxGridDBColumn
                Caption = 'Stil Ad'#305
                DataBinding.FieldName = 'STILADI'
                DataBinding.IsNullValueType = True
                Width = 103
              end
              object clmStilFont: TcxGridDBColumn
                Caption = 'Font'
                DataBinding.FieldName = 'FONT'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxFontNameComboBoxProperties'
                Properties.FontPreview.ShowButtons = False
                Properties.ImmediatePost = True
                Width = 72
              end
              object clmStilPunto: TcxGridDBColumn
                Caption = 'Punto'
                DataBinding.FieldName = 'PUNTO'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxSpinEditProperties'
                Properties.ImmediatePost = True
                Properties.LargeIncrement = 2.000000000000000000
                Properties.MaxValue = 14.000000000000000000
                Properties.MinValue = 6.000000000000000000
              end
              object clmStilBold: TcxGridDBColumn
                Caption = 'Bold'
                DataBinding.FieldName = 'BOLD'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
              end
              object clmStilItalik: TcxGridDBColumn
                Caption = #304'talik'
                DataBinding.FieldName = 'ITALIK'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
              end
              object clmStilAltCizgi: TcxGridDBColumn
                Caption = 'Alt '#199'izgi'
                DataBinding.FieldName = 'ALTCIZGI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
              end
              object clmFontRenk: TcxGridDBColumn
                Caption = 'Font Rengi'
                DataBinding.FieldName = 'FONTRENK'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxColorComboBoxProperties'
                Properties.AllowSelectColor = True
                Properties.CustomColors = <>
              end
              object clmStilArkaRenk: TcxGridDBColumn
                Caption = 'Arka Plan Rengi'
                DataBinding.FieldName = 'ARKARENK'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxColorComboBoxProperties'
                Properties.CustomColors = <>
                Width = 86
              end
            end
            object gridStilTanimLevel1: TcxGridLevel
              GridView = tvStilTanim
            end
          end
          object ToolBar2: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 684
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
            object StilEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Ekle'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsTextButton
              OnClick = StilEkleTusClick
            end
            object StilSilTus: TToolButton
              Left = 62
              Top = 0
              Caption = 'Sil'
              ImageIndex = 5
              ImageName = 'PngImage5'
              Style = tbsTextButton
              OnClick = StilSilTusClick
            end
            object ToolButton2: TToolButton
              Left = 124
              Top = 0
              Width = 8
              Caption = 'ToolButton2'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsSeparator
            end
            object StilKaydetTus: TToolButton
              Left = 132
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = StilKaydetTusClick
            end
            object StilIptalTus: TToolButton
              Left = 194
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = StilIptalTusClick
            end
          end
        end
        object shtStilKosullari: TTabSheet
          Caption = 'Stil Kullan'#305'm'#305
          ImageIndex = 1
          object ToolBar1: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 684
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
            object StilKosulEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Ekle'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsTextButton
              OnClick = StilKosulEkleTusClick
            end
            object StilKosulSilTus: TToolButton
              Left = 62
              Top = 0
              Caption = 'Sil'
              ImageIndex = 5
              ImageName = 'PngImage5'
              Style = tbsTextButton
              OnClick = StilKosulSilTusClick
            end
            object ToolButton4: TToolButton
              Left = 124
              Top = 0
              Width = 8
              Caption = 'ToolButton2'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsSeparator
            end
            object StilKosulKaydetTus: TToolButton
              Left = 132
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = StilKosulKaydetTusClick
            end
            object StilKosulIptalTus: TToolButton
              Left = 194
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = StilKosulIptalTusClick
            end
          end
          object gridStilKosul: TcxGrid
            Left = 0
            Top = 27
            Width = 690
            Height = 451
            Align = alClient
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            object tvStilKosul: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dtsStilKosul
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              object clmStilKosulId: TcxGridDBColumn
                Caption = 'Id'
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object clmStilKosulStilAdi: TcxGridDBColumn
                Caption = 'Uygulanacak Stil Ad'#305
                DataBinding.FieldName = 'STILID'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                Width = 105
              end
              object clmStilKosulGridAdi: TcxGridDBColumn
                Caption = 'Grid Ad'#305
                DataBinding.FieldName = 'GRIDADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxComboBoxProperties'
                Properties.ImmediatePost = True
              end
              object clmStilKosulAlanAdi: TcxGridDBColumn
                Caption = 'Alan Ad'#305
                DataBinding.FieldName = 'ALANADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxComboBoxProperties'
                Properties.ImmediatePost = True
              end
              object clmStilKosulTur: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
              end
              object clmStilKosulAltDeger: TcxGridDBColumn
                Caption = 'Alt De'#287'er'
                DataBinding.FieldName = 'ALTDEGER'
                DataBinding.IsNullValueType = True
              end
              object clmStilKosulUstDeger: TcxGridDBColumn
                Caption = #220'st De'#287'er'
                DataBinding.FieldName = 'USTDEGER'
                DataBinding.IsNullValueType = True
              end
            end
            object gridStilKosulLevel1: TcxGridLevel
              GridView = tvStilKosul
            end
          end
        end
      end
    end
    object shtKocanAyarlari: TTabSheet
      Caption = 'Ko'#231'an Ayarlar'#305
      ImageIndex = 6
      OnEnter = shtKocanAyarlariEnter
      object gridKocanAyar: TcxGrid
        Left = 0
        Top = 67
        Width = 698
        Height = 361
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        object tvKocanAyarlari: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = dtsKocanAyarlari
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object clmKocanNo: TcxGridDBColumn
            Caption = 'Ko'#231'an No'
            DataBinding.FieldName = 'KOCANNO'
            DataBinding.IsNullValueType = True
          end
          object clmKocanTur: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.ImmediatePost = True
            Properties.Items = <>
          end
          object tvKocanAyarlariKOCANKULLAN: TcxGridDBColumn
            Caption = 'Kullan'#305'm'
            DataBinding.FieldName = 'KOCANKULLAN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Ko'#231'an Numaras'#305
                ImageIndex = 0
                Value = True
              end
              item
                Description = 'ID Numaras'#305
                Value = False
              end>
          end
          object clmKocanBasTarihi: TcxGridDBColumn
            Caption = 'Ba'#351'lang'#305#231' Tarihi'
            DataBinding.FieldName = 'BASLANGICTARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.DateButtons = [btnClear, btnNow, btnToday]
            Properties.ImmediatePost = True
            Properties.Kind = ckDateTime
            Width = 88
          end
          object clmKocanSeriNo: TcxGridDBColumn
            Caption = 'SeriNo-'#214'n Ek'
            DataBinding.FieldName = 'SERINO'
            DataBinding.IsNullValueType = True
            Width = 90
          end
          object clmKocanBaslangicNo: TcxGridDBColumn
            Caption = 'Ba'#351'lang'#305#231' No'
            DataBinding.FieldName = 'BASLANGICNO'
            DataBinding.IsNullValueType = True
            Width = 90
          end
          object tvKocanAyarlariColumn1: TcxGridDBColumn
            Caption = 'S'#305'f'#305'rlama'
            DataBinding.FieldName = 'SIFIRLA'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.ImmediatePost = True
            Properties.Items = <
              item
                Description = 'S'#305'f'#305'rlama Yok'
                ImageIndex = 0
                Value = '0'
              end
              item
                Description = 'G'#252'nl'#252'k S'#305'f'#305'rla'
                Value = '1'
              end
              item
                Description = 'Y'#305'll'#305'k S'#305'f'#305'rla'
                Value = '2'
              end>
          end
          object tvKocanAyarlariSube: TcxGridDBColumn
            Caption = #350'ube'
            DataBinding.FieldName = 'SUBEID'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = tvKocanAyarlari
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 698
        Height = 67
        Align = alTop
        TabOrder = 0
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 690
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
          object btnKocanEkle: TToolButton
            Left = 0
            Top = 0
            Caption = 'Ekle'
            ImageIndex = 4
            ImageName = 'PngImage4'
            Style = tbsTextButton
            OnClick = btnKocanEkleClick
          end
          object btnKocanSil: TToolButton
            Left = 62
            Top = 0
            Caption = 'Sil'
            ImageIndex = 5
            ImageName = 'PngImage5'
            Style = tbsTextButton
            OnClick = btnKocanSilClick
          end
          object ToolButton5: TToolButton
            Left = 124
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 7
            ImageName = 'PngImage7'
            Style = tbsSeparator
          end
          object btnKocanKaydet: TToolButton
            Left = 132
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Visible = False
            OnClick = btnKocanKaydetClick
          end
          object btnKocanIptal: TToolButton
            Left = 194
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 3
            ImageName = 'PngImage3'
            Visible = False
            OnClick = btnKocanIptalClick
          end
          object btnKocanSec: TcxButton
            Left = 256
            Top = 0
            Width = 307
            Height = 22
            Align = alRight
            Caption = 'Bu bilgisayarda bu ko'#231'an'#305' kullan'
            Enabled = False
            LookAndFeel.NativeStyle = True
            TabOrder = 0
            OnClick = btnKocanSecClick
          end
        end
        object cxLabel11: TcxLabel
          Left = 10
          Top = 35
          Cursor = crHandPoint
          Caption = 'Eksik Ko'#231'an tan'#305'mlar'#305'n'#305' tamamla..'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlue
          Style.Font.Height = -13
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          Transparent = True
          OnClick = cxLabel11Click
        end
        object cxImageComboBox1: TcxImageComboBox
          Left = 345
          Top = 35
          Properties.Items = <>
          Properties.OnCloseUp = cxImageComboBox1PropertiesCloseUp
          TabOrder = 2
          Width = 121
        end
        object cxLabel13: TcxLabel
          Left = 312
          Top = 37
          Caption = #350'ube'
          Transparent = True
          Visible = False
        end
      end
      object Panel5: TPanel
        Left = 0
        Top = 428
        Width = 698
        Height = 81
        Align = alBottom
        Alignment = taLeftJustify
        TabOrder = 2
        object lbSatisFatKocan: TcxLabel
          Left = 4
          Top = 2
          Caption = 'Aktif Fatura Ko'#231'an'#305
          Transparent = True
        end
        object lbAlisSipKocan: TcxLabel
          Left = 4
          Top = 21
          Caption = 'Aktif Al'#305#351' Sipari'#351'i Ko'#231'an'#305
          Transparent = True
        end
        object lbSatisFisKocan: TcxLabel
          Left = 190
          Top = 2
          Caption = 'Aktif Fi'#351' Ko'#231'an'#305
          Transparent = True
        end
        object lbSatisSipKocan: TcxLabel
          Left = 190
          Top = 21
          Caption = 'Aktif Sat'#305#351'Sipari'#351'i Ko'#231'an'#305
          Transparent = True
        end
        object lbSatisIrsKocan: TcxLabel
          Left = 368
          Top = 2
          Caption = 'Aktif '#304'rsaliye Ko'#231'an'#305
          Transparent = True
        end
        object lbGiderPusKocani: TcxLabel
          Left = 368
          Top = 21
          Caption = 'Aktif Gider Pusulas'#305' Ko'#231'an'#305
          Transparent = True
        end
        object lbSatIrsFatKocan: TcxLabel
          Left = 4
          Top = 40
          Caption = 'Aktif '#304'rsaliyeli Fatura Ko'#231'an'#305
          Transparent = True
        end
        object lbTransferKocan: TcxLabel
          Left = 190
          Top = 40
          Caption = 'Aktif Transfer Fi'#351'i Ko'#231'an'#305
          Transparent = True
        end
        object lbServisKocani: TcxLabel
          Left = 368
          Top = 40
          Caption = 'Aktif Servis Fi'#351'i Ko'#231'an'#305
          Transparent = True
        end
        object lbAlinanTeklifKocan: TcxLabel
          Left = 4
          Top = 59
          Caption = 'Aktif Al'#305'nan Teklif Ko'#231'an'#305
          Transparent = True
        end
        object lbVerilenTeklifKocan: TcxLabel
          Left = 190
          Top = 59
          Caption = 'Aktif Verilen Teklif Ko'#231'an'#305
          Transparent = True
        end
        object lbTahsilKocani: TcxLabel
          Left = 537
          Top = 2
          Caption = 'Aktif Tahsilat Makbuzu'
          Transparent = True
        end
        object lbOdemeKocani: TcxLabel
          Left = 537
          Top = 21
          Caption = 'Aktif Tediye Makbuzu'
          Transparent = True
        end
        object lbVirmanKocani: TcxLabel
          Left = 537
          Top = 41
          Caption = 'Aktif Virman Makbuzu'
          Transparent = True
        end
      end
      object MemoSQLKocan: TMemo
        Left = 11
        Top = 108
        Width = 677
        Height = 39
        Lines.Strings = (
          
            'INSERT INTO KOCANAYARLARI (KOCANNO,TUR,KOCANKULLAN,BASLANGICTARI' +
            'HI,BASLANGICNO,SIFIRLA,SUBEID,SERINO)'
          ''
          'SELECT DISTINCT'
          
            '             KOCANNO=CONVERT(INT,(CONVERT(VARCHAR(10),TUR)+'#39'0'#39'+C' +
            'ONVERT(VARCHAR(2),ABS(R.ID)))),TUR,1,BASLANGICTARIHI=cast(cast(Y' +
            'EAR(GETDATE()) as varchar(4))+'#39'-01-01'#39' as datetime) ,'
          '             BASLANGICNO='#39'000001'#39',SIFIRLA=0,R.ID,SERINO='#39#39
          ''
          'FROM   '
          '             ISLEMTURLERI IT LEFT JOIN REHBER R ON R.ID<0 '
          '             '
          'WHERE   IT.KOCANAYARI=1'
          
            '             AND NOT EXISTS (SELECT TUR FROM KOCANAYARLARI K WHE' +
            'RE IT.TUR=K.TUR and K.SUBEID=R.ID)'
          ''
          'union all'
          
            'select KOCANNO=CONVERT(INT,(CONVERT(VARCHAR(10),101)+'#39'0'#39'+CONVERT' +
            '(VARCHAR(2),ABS(R.ID)))),-101,1,'
          
            'BASLANGICTARIHI=cast(cast(YEAR(GETDATE()) as varchar(4))+'#39'-01-01' +
            #39' as datetime) ,'
          '             BASLANGICNO='#39'000001'#39',SIFIRLA=0,R.ID,SERINO='#39'T'#39
          
            'from REHBER R where R.ID<0 AND NOT EXISTS (SELECT 1 FROM KOCANAY' +
            'ARLARI K WHERE K.TUR=-101 and K.SUBEID=R.ID)'
          'union all'
          
            'select KOCANNO=CONVERT(INT,(CONVERT(VARCHAR(10),102)+'#39'0'#39'+CONVERT' +
            '(VARCHAR(2),ABS(R.ID)))),-102,1,'
          
            'BASLANGICTARIHI=cast(cast(YEAR(GETDATE()) as varchar(4))+'#39'-01-01' +
            #39' as datetime) ,'
          '             BASLANGICNO='#39'000001'#39',SIFIRLA=0,R.ID,SERINO='#39#214#39
          
            'from REHBER R where R.ID<0 AND NOT EXISTS (SELECT 1 FROM KOCANAY' +
            'ARLARI K WHERE K.TUR=-102 and K.SUBEID=R.ID)'
          'union all'
          
            'select KOCANNO=CONVERT(INT,(CONVERT(VARCHAR(10),103)+'#39'0'#39'+CONVERT' +
            '(VARCHAR(2),ABS(R.ID)))),-103,1,'
          
            'BASLANGICTARIHI=cast(cast(YEAR(GETDATE()) as varchar(4))+'#39'-01-01' +
            #39' as datetime) ,'
          '             BASLANGICNO='#39'000001'#39',SIFIRLA=0,R.ID,SERINO='#39'V'#39
          
            'from REHBER R where R.ID<0 AND NOT EXISTS (SELECT 1 FROM KOCANAY' +
            'ARLARI K WHERE K.TUR=-103 and K.SUBEID=R.ID)')
        TabOrder = 3
        Visible = False
        WordWrap = False
      end
    end
    object shtBildirim: TTabSheet
      Caption = 'Bildirim'
      ImageIndex = 7
      object pgBildirim: TPageControl
        Left = 0
        Top = 0
        Width = 698
        Height = 509
        ActivePage = TabSheet7
        Align = alClient
        TabOrder = 0
        OnChange = pgBildirimChange
        object TabSheet7: TTabSheet
          Caption = 'SMS'
          object GroupBox1: TGroupBox
            Left = 0
            Top = 0
            Width = 690
            Height = 155
            Align = alTop
            Caption = 'SMS Hesaplar'#305
            TabOrder = 0
            object ToolBar4: TToolBar
              AlignWithMargins = True
              Left = 5
              Top = 21
              Width = 680
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
              object btnSMSHesapEkle: TToolButton
                Left = 0
                Top = 0
                Caption = 'Ekle'
                ImageIndex = 4
                ImageName = 'PngImage4'
                Style = tbsTextButton
                OnClick = btnSMSHesapEkleClick
              end
              object btnSMSHesapSil: TToolButton
                Left = 61
                Top = 0
                Caption = 'Sil'
                ImageIndex = 5
                ImageName = 'PngImage5'
                Style = tbsTextButton
                OnClick = btnSMSHesapSilClick
              end
              object ToolButton6: TToolButton
                Left = 122
                Top = 0
                Width = 8
                Caption = 'ToolButton2'
                ImageIndex = 7
                ImageName = 'PngImage7'
                Style = tbsSeparator
              end
              object btnSMSHesapKaydet: TToolButton
                Left = 130
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Visible = False
                OnClick = btnSMSHesapKaydetClick
              end
              object btnSMSHesapIptal: TToolButton
                Left = 191
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                ImageName = 'PngImage3'
                Visible = False
                OnClick = btnSMSHesapIptalClick
              end
              object btnSMSHesapSec: TcxButton
                Left = 252
                Top = 0
                Width = 307
                Height = 22
                Align = alRight
                Caption = 'SMS G'#246'nderimleri i'#231'in bu hesab'#305' kullan'
                LookAndFeel.NativeStyle = True
                TabOrder = 0
                OnClick = btnSMSHesapSecClick
              end
            end
            object cxGrid1: TcxGrid
              Left = 2
              Top = 45
              Width = 686
              Height = 108
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              object tvSMSHesaplari: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = dtsSMSHesaplari
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsView.GroupByBox = False
                Styles.OnGetContentStyle = tvSMSHesaplariStylesGetContentStyle
                object tvSMSHesaplariColumn1: TcxGridDBColumn
                  Caption = 'Servis'
                  DataBinding.FieldName = 'SMSSERVISI'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <
                    item
                      Description = 'Posta G'#252'vercini'
                      ImageIndex = 0
                      Value = '1'
                    end>
                end
                object tvSMSHesaplariColumn2: TcxGridDBColumn
                  Caption = 'Kullan'#305'c'#305' Ad'#305
                  DataBinding.FieldName = 'SMSKULLANICIADI'
                  DataBinding.IsNullValueType = True
                end
                object tvSMSHesaplariColumn3: TcxGridDBColumn
                  Caption = #350'ifre'
                  DataBinding.FieldName = 'SMSSIFRE'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.EchoMode = eemPassword
                end
                object tvSMSHesaplariColumn4: TcxGridDBColumn
                  Caption = 'Ba'#351'l'#305'k'
                  DataBinding.FieldName = 'SMSBASLIK'
                  DataBinding.IsNullValueType = True
                end
                object tvSMSHesaplariColumn5: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'DURUM'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <
                    item
                      Description = 'Aktif'
                      ImageIndex = 0
                      Value = '1'
                    end
                    item
                      Description = 'Pasif'
                      Value = '0'
                    end>
                end
                object tvSMSHesaplariColumn6: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                end
                object tvSMSHesaplariColumn7: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object tvSMSHesaplariVarsayilan: TcxGridDBColumn
                  Caption = 'Varsay'#305'lan'
                  DataBinding.FieldName = 'VARSAYILAN'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
              end
              object cxGrid1Level1: TcxGridLevel
                GridView = tvSMSHesaplari
              end
            end
          end
          object checkAktiviteSMSBildirim: TcxCheckBox
            Left = 2
            Top = 161
            Caption = 'Aktiviteler '#304#231'in SMS Bildirimini Kullan'
            TabOrder = 1
            Visible = False
          end
        end
        object TabSheet8: TTabSheet
          Caption = 'E-Posta'
          ImageIndex = 1
          object GroupEPostaHesaplari: TGroupBox
            Left = 0
            Top = 56
            Width = 497
            Height = 155
            Caption = 'EPosta Hesaplar'#305
            TabOrder = 1
            object ToolBar5: TToolBar
              AlignWithMargins = True
              Left = 5
              Top = 21
              Width = 487
              Height = 54
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
              object btnEpostaEkle: TToolButton
                Left = 0
                Top = 0
                Caption = 'Ekle'
                ImageIndex = 4
                ImageName = 'PngImage4'
                Style = tbsTextButton
                OnClick = btnEpostaEkleClick
              end
              object btnEpostaSil: TToolButton
                Left = 61
                Top = 0
                Caption = 'Sil'
                ImageIndex = 5
                ImageName = 'PngImage5'
                Style = tbsTextButton
                OnClick = btnEpostaSilClick
              end
              object ToolButton7: TToolButton
                Left = 0
                Top = 0
                Width = 8
                Caption = 'ToolButton2'
                ImageIndex = 7
                ImageName = 'PngImage7'
                Wrap = True
                Style = tbsSeparator
              end
              object btnEpostaKaydet: TToolButton
                Left = 0
                Top = 30
                Caption = 'Kaydet'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Visible = False
                OnClick = btnEpostaKaydetClick
              end
              object btnEpostaIptal: TToolButton
                Left = 61
                Top = 30
                Caption = #304'ptal'
                ImageIndex = 3
                ImageName = 'PngImage3'
                Visible = False
                OnClick = btnEpostaIptalClick
              end
              object btnEpostaSecimKaydet: TcxButton
                Left = 122
                Top = 30
                Width = 307
                Height = 22
                Align = alRight
                Caption = 'Eposta G'#246'nderimleri i'#231'in bu hesab'#305' kullan'
                LookAndFeel.NativeStyle = True
                TabOrder = 0
                OnClick = btnEpostaSecimKaydetClick
              end
            end
            object gridEpostaHesaplari: TcxGrid
              Left = 2
              Top = 75
              Width = 493
              Height = 110
              Align = alTop
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              object tvEpostaHesaplari: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = dtsEpostaHesaplari
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsView.GroupByBox = False
                Styles.OnGetContentStyle = tvEpostaHesaplariStylesGetContentStyle
                object tvEpostaHesaplariColumn1: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Width = 20
                end
                object tvEpostaHesaplariColumn9: TcxGridDBColumn
                  Caption = 'G'#246'nderen'
                  DataBinding.FieldName = 'GONDEREN'
                  DataBinding.IsNullValueType = True
                end
                object tvEpostaHesaplariColumn2: TcxGridDBColumn
                  Caption = 'EPosta Adresi'
                  DataBinding.FieldName = 'EPOSTAADRESI'
                  DataBinding.IsNullValueType = True
                end
                object tvEpostaHesaplariColumn3: TcxGridDBColumn
                  Caption = 'Kullan'#305'c'#305' Ad'#305
                  DataBinding.FieldName = 'KULLANICIADI'
                  DataBinding.IsNullValueType = True
                end
                object tvEpostaHesaplariColumn4: TcxGridDBColumn
                  Caption = 'Parola'
                  DataBinding.FieldName = 'SIFRE'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxTextEditProperties'
                  Properties.EchoMode = eemPassword
                end
                object tvEpostaHesaplariColumn5: TcxGridDBColumn
                  Caption = 'Sunucu'
                  DataBinding.FieldName = 'MAILSUNUCU'
                  DataBinding.IsNullValueType = True
                end
                object tvEpostaHesaplariColumn6: TcxGridDBColumn
                  Caption = 'Port'
                  DataBinding.FieldName = 'PORT'
                  DataBinding.IsNullValueType = True
                end
                object tvEpostaHesaplariColumn7: TcxGridDBColumn
                  Caption = 'Kimlik Do'#287'rulama'
                  DataBinding.FieldName = 'KIMLIKDOGRULAMA'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ImmediatePost = True
                  Properties.NullStyle = nssUnchecked
                  Width = 20
                end
                object tvEpostaHesaplariColumn8: TcxGridDBColumn
                  Caption = #350'ifreleme'
                  DataBinding.FieldName = 'SIFRELEME'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <
                    item
                      Description = 'Yok'
                      ImageIndex = 0
                      Value = '0'
                    end
                    item
                      Description = 'TLS'
                      Value = '1'
                    end
                    item
                      Description = 'SSL v2'
                      Value = '2'
                    end
                    item
                      Description = 'SSL v3'
                      Value = '3'
                    end
                    item
                      Description = 'SSL v23'
                      Value = '4'
                    end>
                  Width = 27
                end
                object tvEpostaHesaplariVarsayilan: TcxGridDBColumn
                  Caption = 'Varsay'#305'lan'
                  DataBinding.FieldName = 'VARSAYILAN'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 64
                end
              end
              object cxGridLevel2: TcxGridLevel
                GridView = tvEpostaHesaplari
              end
            end
          end
          object checkAktiviteEpostaBildirim: TcxCheckBox
            Left = 2
            Top = 217
            Caption = 'Aktiviteler '#304#231'in Eposta Bildirimini Kullan'
            TabOrder = 2
            Visible = False
          end
          object EPostaGonderimSekli: TcxRadioGroup
            Left = 4
            Top = 13
            Caption = 'E-Posta G'#246'nderim '#350'ekli'
            Properties.Columns = 2
            Properties.Items = <
              item
                Caption = 'Outlook '#220'zerinden'
              end
              item
                Caption = 'Kendi Hesab'#305'mdan'
              end>
            Properties.OnChange = EPostaGonderimSekliPropertiesChange
            ItemIndex = 0
            TabOrder = 0
            Height = 42
            Width = 491
          end
          object btnMailSablon: TcxButton
            Left = 16
            Top = 263
            Width = 143
            Height = 25
            Caption = 'E-Posta '#350'ablonlar'#305
            TabOrder = 3
            OnClick = btnMailSablonClick
          end
        end
        object TabSheet9: TTabSheet
          Caption = 'ITS'
          ImageIndex = 2
          object GroupBox10: TGroupBox
            Left = 0
            Top = 0
            Width = 690
            Height = 155
            Align = alTop
            Caption = 'ITS/PTS Hesaplar'#305
            TabOrder = 0
            object ToolBar6: TToolBar
              AlignWithMargins = True
              Left = 5
              Top = 21
              Width = 680
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
              object BtnITSHesapEkle: TToolButton
                Left = 0
                Top = 0
                Caption = 'Ekle'
                ImageIndex = 4
                ImageName = 'PngImage4'
                Style = tbsTextButton
                OnClick = BtnITSHesapEkleClick
              end
              object BtnITSHesapSil: TToolButton
                Left = 61
                Top = 0
                Caption = 'Sil'
                ImageIndex = 5
                ImageName = 'PngImage5'
                Style = tbsTextButton
                OnClick = BtnITSHesapSilClick
              end
              object ToolButton8: TToolButton
                Left = 122
                Top = 0
                Width = 8
                Caption = 'ToolButton2'
                ImageIndex = 7
                ImageName = 'PngImage7'
                Style = tbsSeparator
              end
              object BtnITSHesapKaydet: TToolButton
                Left = 130
                Top = 0
                Caption = 'Kaydet'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Visible = False
                OnClick = BtnITSHesapKaydetClick
              end
              object BtnITSHesapVazgec: TToolButton
                Left = 191
                Top = 0
                Caption = #304'ptal'
                ImageIndex = 3
                ImageName = 'PngImage3'
                Visible = False
                OnClick = BtnITSHesapVazgecClick
              end
              object VarsayilanKaydet: TcxButton
                Left = 252
                Top = 0
                Width = 307
                Height = 22
                Align = alRight
                Caption = 'ITS G'#246'nderimleri i'#231'in bu hesab'#305' kullan'
                LookAndFeel.NativeStyle = True
                TabOrder = 0
                OnClick = VarsayilanKaydetClick
              end
            end
            object GridITSHesaplari: TcxGrid
              Left = 2
              Top = 45
              Width = 686
              Height = 108
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              object TvITSHesaplari: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsITSHesaplari
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsView.GroupByBox = False
                Styles.OnGetContentStyle = TvITSHesaplariStylesGetContentStyle
                object cxGridDBColumn1: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Width = 31
                end
                object cxGridDBColumn2: TcxGridDBColumn
                  Caption = 'G'#246'nderen'
                  DataBinding.FieldName = 'GONDEREN'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxComboBoxProperties'
                  Properties.Items.Strings = (
                    'EczaDepo'
                    'EczaUretici'
                    'EczaEczane'
                    'EczaHastane')
                  Width = 81
                end
                object cxGridDBColumn4: TcxGridDBColumn
                  Caption = 'Kullan'#305'c'#305' Ad'#305
                  DataBinding.FieldName = 'KULLANICIADI'
                  DataBinding.IsNullValueType = True
                  Width = 87
                end
                object cxGridDBColumn5: TcxGridDBColumn
                  Caption = 'Parola'
                  DataBinding.FieldName = 'SIFRE'
                  DataBinding.IsNullValueType = True
                  Width = 109
                end
                object cxGridDBColumn6: TcxGridDBColumn
                  Caption = 'Sunucu'
                  DataBinding.FieldName = 'SERVIS'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxComboBoxProperties'
                  Properties.Items.Strings = (
                    'http://212.174.130.240/'
                    'http://its.saglik.gov.tr/')
                  Width = 136
                end
              end
              object cxGridLevel3: TcxGridLevel
                GridView = TvITSHesaplari
              end
            end
          end
        end
        object TabGoogle: TTabSheet
          Caption = 'Google Takvim'
          ImageIndex = 3
          object ToolBar7: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 684
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
            object btnSMSGoogleEkle: TToolButton
              Left = 0
              Top = 0
              Caption = 'Ekle'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsTextButton
              OnClick = btnSMSGoogleEkleClick
            end
            object btnSMSGoogleSil: TToolButton
              Left = 61
              Top = 0
              Caption = 'Sil'
              ImageIndex = 5
              ImageName = 'PngImage5'
              Style = tbsTextButton
              OnClick = btnSMSGoogleSilClick
            end
            object ToolButton9: TToolButton
              Left = 122
              Top = 0
              Width = 8
              Caption = 'ToolButton2'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsSeparator
            end
            object btnSMSGoogleKaydet: TToolButton
              Left = 130
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = btnSMSGoogleKaydetClick
            end
            object btnSMSGoogleIptal: TToolButton
              Left = 191
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = btnSMSGoogleIptalClick
            end
          end
          object cxGrid2: TcxGrid
            Left = 0
            Top = 27
            Width = 690
            Height = 310
            Align = alTop
            TabOrder = 1
            object cxGrid2DBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsGoogleTakvim
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              object cxGridKullaniciAdi: TcxGridDBColumn
                Caption = 'Kullan'#305'c'#305
                DataBinding.FieldName = 'KULLANAN'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = ButtonEdit
                Width = 120
              end
              object cxGridEMail: TcxGridDBColumn
                Caption = 'E-Posta'
                DataBinding.FieldName = 'EMAIL'
                Width = 111
              end
              object cxGridSifre: TcxGridDBColumn
                Caption = #350'ifre'
                DataBinding.FieldName = 'SIFRE'
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.AutoSelect = False
                Properties.EchoMode = eemPassword
                Width = 90
              end
              object cxGridTakvimID: TcxGridDBColumn
                Caption = 'Takvim Id'
                DataBinding.FieldName = 'TAKVIMID'
                Width = 110
              end
              object cxGridAciklama: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                Width = 96
              end
              object cxGrid2DBTableView1P12DOSYA: TcxGridDBColumn
                Caption = 'P12 Dosya'
                DataBinding.FieldName = 'P12DOSYA'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = cxGrid2DBTableView1P12DOSYAPropertiesButtonClick
              end
              object cxGrid2DBTableView1KULLANICIADI: TcxGridDBColumn
                Caption = 'Google Kullan'#305'c'#305
                DataBinding.FieldName = 'KULLANICIADI'
              end
            end
            object cxGrid2Level1: TcxGridLevel
              GridView = cxGrid2DBTableView1
            end
          end
        end
      end
    end
    object SheetListeDuzenle: TTabSheet
      Caption = 'Listeler'
      ImageIndex = 7
      TabVisible = False
      object GridListeDuzenle: TcxGrid
        Left = 0
        Top = 0
        Width = 698
        Height = 509
        Align = alClient
        TabOrder = 0
        object GridListeDuzenleDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellDblClick = GridListeDuzenleDBTableView1CellDblClick
          DataController.DataSource = DtsListeDuzenle
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.InvertSelect = False
          OptionsView.GroupByBox = False
          object GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn
            Caption = 'B'#246'l'#252'm'
            DataBinding.FieldName = 'ANAHTAR'
            DataBinding.IsNullValueType = True
            Width = 257
          end
          object GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn
            DataBinding.FieldName = 'DEGER'
            DataBinding.IsNullValueType = True
            Visible = False
          end
        end
        object GridListeDuzenleLevel1: TcxGridLevel
          GridView = GridListeDuzenleDBTableView1
        end
      end
    end
    object ShtKilitleme: TTabSheet
      Caption = 'Kilitleme'
      ImageIndex = 6
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 698
        Height = 53
        Align = alTop
        TabOrder = 0
        object ComboSube: TcxImageComboBox
          Left = 41
          Top = 10
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          Properties.OnChange = ComboSubePropertiesChange
          Style.BorderColor = 5253759
          Style.BorderStyle = ebsOffice11
          Style.LookAndFeel.Kind = lfOffice11
          Style.LookAndFeel.NativeStyle = False
          StyleDisabled.LookAndFeel.Kind = lfOffice11
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.Kind = lfOffice11
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.Kind = lfOffice11
          StyleHot.LookAndFeel.NativeStyle = False
          StyleReadOnly.LookAndFeel.Kind = lfOffice11
          StyleReadOnly.LookAndFeel.NativeStyle = False
          TabOrder = 3
          Visible = False
          Width = 203
        end
        object lblSube: TcxLabel
          Left = -1
          Top = 12
          Caption = #350'ube'
          Transparent = True
          Visible = False
        end
        object cxLabel4: TcxLabel
          Tag = 4
          Left = 356
          Top = 4
          Cursor = crHandPoint
          Caption = 'Tarih Ata'
          ParentColor = False
          Style.Color = clBtnFace
          Style.TextColor = clNavy
          Transparent = True
          OnClick = YeniKilit1Click
        end
        object cxLabel5: TcxLabel
          Tag = 5
          Left = 356
          Top = 23
          Cursor = crHandPoint
          Caption = 'G'#252'n Ata'
          ParentColor = False
          Style.Color = clBtnFace
          Style.TextColor = clNavy
          Transparent = True
          OnClick = YeniKilit1Click
        end
        object cxLabel6: TcxLabel
          Tag = 1
          Left = 257
          Top = 4
          Cursor = crHandPoint
          Caption = 'T'#252'm'#252'n'#252' Se'#231
          ParentColor = False
          Style.Color = clBtnFace
          Style.TextColor = clNavy
          Transparent = True
          OnClick = TumunuSecKaldirClick
        end
        object cxLabel7: TcxLabel
          Tag = 2
          Left = 256
          Top = 24
          Cursor = crHandPoint
          Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
          ParentColor = False
          Style.Color = clBtnFace
          Style.TextColor = clNavy
          Transparent = True
          OnClick = TumunuSecKaldirClick
        end
        object cxLabel8: TcxLabel
          Left = 431
          Top = 4
          Cursor = crHandPoint
          Caption = 'Kilit A'#231
          ParentColor = False
          Style.Color = clBtnFace
          Style.TextColor = clNavy
          Transparent = True
          OnClick = Aktif1Click
        end
        object cxLabel9: TcxLabel
          Tag = 1
          Left = 431
          Top = 24
          Cursor = crHandPoint
          Caption = 'Kilit Kapat'
          ParentColor = False
          Style.Color = clBtnFace
          Style.TextColor = clNavy
          Transparent = True
          OnClick = Aktif1Click
        end
      end
      object GridKilitListesi: TcxGrid
        Left = 0
        Top = 77
        Width = 698
        Height = 432
        Align = alClient
        PopupMenu = KilitlemeMenu
        TabOrder = 1
        object KilitListesiView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DsTabKilitler
          DataController.KeyFieldNames = 'ID'
          DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object KilitListesiViewSEC: TcxGridDBColumn
            Caption = 'Se'#231
            DataBinding.ValueType = 'Boolean'
            PropertiesClassName = 'TcxCheckBoxProperties'
            Properties.ImmediatePost = True
            Properties.NullStyle = nssUnchecked
            Properties.OnChange = KilitListesiViewSECPropertiesChange
            Width = 29
          end
          object KilitListesiViewMODULADI: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'MODULADI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 173
          end
          object KilitListesiViewGUNCELTARIH: TcxGridDBColumn
            Caption = 'Son Kilit Tarihi'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ImmediatePost = True
            Properties.ShowTime = False
            Options.Editing = False
            Width = 101
          end
          object KilitListesiViewOTOGUN: TcxGridDBColumn
            Caption = 'Oto. Kilitleme'
            DataBinding.FieldName = 'OTOGUN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Options.Editing = False
            Width = 111
          end
          object KilitListesiViewKILITLEME: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'KILIT'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Images = Tablo.PNGImageList2
            Properties.ImmediatePost = True
            Properties.Items = <
              item
                ImageIndex = 24
                Value = True
              end
              item
                ImageIndex = 23
                Value = False
              end>
            Options.Editing = False
            Width = 56
          end
          object KilitListesiViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
            Options.Editing = False
          end
          object KilitListesiViewDEGISTIRMETARIHI: TcxGridDBColumn
            Caption = 'D_Tarihi'
            DataBinding.FieldName = 'DEGISTIRMETARIHI'
            DataBinding.IsNullValueType = True
            Visible = False
            Options.Editing = False
          end
        end
        object GridKilitListesiLevel1: TcxGridLevel
          GridView = KilitListesiView
        end
      end
      object PageControlKilit: TcxPageControl
        Left = 0
        Top = 53
        Width = 698
        Height = 24
        Align = alTop
        TabOrder = 2
        Properties.ActivePage = TabSheetKilitYeni
        Properties.CustomButtons.Buttons = <>
        Properties.Style = 8
        OnChange = PageControlKilitChange
        ClientRectBottom = 26
        ClientRectRight = 698
        ClientRectTop = 26
        object TabSheetKilitYeni: TcxTabSheet
          Tag = 1
          Caption = 'Yeni Kay'#305't Giri'#351'i'
          ImageIndex = 0
        end
        object TabSheetGuncel: TcxTabSheet
          Caption = 'G'#252'ncelleme (De'#287'i'#351'iklik,Silme)'
          ImageIndex = 1
        end
      end
      object SQLKilitGuncel: TMemo
        Left = 20
        Top = 284
        Width = 677
        Height = 39
        Lines.Strings = (
          
            'SELECT  [ID],[MODULID],[MODULADI],OTOGUN=[OTOGUNGUNCEL],TARIH=[T' +
            'ARIHGUNCEL],KILIT=[KILITGUNCEL],[KASATUR],[SUBEID]'
          'FROM MODUL WHERE ISNULL(KASATUR,0)>0'
          'order by cast(MODULID as varchar(20))')
        TabOrder = 3
        Visible = False
        WordWrap = False
      end
      object SQLKilitGiris: TMemo
        Left = 20
        Top = 218
        Width = 677
        Height = 39
        Lines.Strings = (
          
            'SELECT  [ID],[MODULID],[MODULADI],OTOGUN=[OTOGUNYENI], TARIH=[TA' +
            'RIHYENI],KILIT=[KILITYENI] ,[KASATUR] ,[SUBEID] '
          'FROM MODUL WHERE ISNULL(KASATUR,0)>0'
          'order by cast(MODULID as varchar(20))')
        TabOrder = 4
        Visible = False
        WordWrap = False
      end
    end
    object TabSheetSecenekler: TTabSheet
      Caption = 'Se'#231'enekler'
      ImageIndex = 7
      object cxLabel12: TcxLabel
        Left = 28
        Top = 64
        Caption = 'Bug'#252'nden sonraki tarihe kay'#305't'
        ParentColor = False
        Transparent = True
      end
      object ComboIleriTarih: TcxImageComboBox
        Left = 196
        Top = 62
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'Yapabilsin'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Onay sorsun'
            Value = 1
          end
          item
            Description = 'Yap'#305'lmas'#305'n'
            Value = 2
          end>
        TabOrder = 1
        Width = 151
      end
      object cbTarihFarkFormati: TcxImageComboBox
        Left = 196
        Top = 92
        Properties.Items = <
          item
            Description = 'GGGg SSs DDd'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'G.GG G'#252'n'
            Value = 2
          end
          item
            Description = 'S.SS Saat'
            Value = 3
          end
          item
            Description = 'D Dakika'
            Value = 4
          end>
        TabOrder = 2
        Width = 151
      end
      object cxLabel14: TcxLabel
        Left = 28
        Top = 94
        Caption = 'Tarih Fark'#305' Format'#305
        ParentColor = False
        Transparent = True
      end
      object cxLabel16: TcxLabel
        Left = 28
        Top = 34
        Caption = 'Ge'#231'mi'#351' y'#305'la kay'#305't'
        ParentColor = False
        Transparent = True
      end
      object ComboEskiTarih: TcxImageComboBox
        Left = 196
        Top = 32
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'Yapabilsin'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Onay sorsun'
            Value = 1
          end
          item
            Description = 'Devir varsa yap'#305'lamas'#305'n'
            Value = 2
          end>
        TabOrder = 5
        Width = 151
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 540
    Width = 706
    Height = 42
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 1
    object CancelBtn: TBitBtn
      Left = 232
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
      Left = 153
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
  object BayramMenu: TPopupMenu
    Left = 647
    Top = 199
    object Ramazan: TMenuItem
      Caption = 'Ramazan Bayram'#305' Ekle'
    end
    object Kurban: TMenuItem
      Caption = 'Kurban Bayram'#305' Ekle'
    end
    object DierTatilgnEkle1: TMenuItem
      Caption = 'Di'#287'er Tatil g'#252'n'#252' Ekle'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object DierTatilGnSil1: TMenuItem
      Caption = 'Di'#287'er Tatil G'#252'n'#252' Sil'
    end
  end
  object TabUyariAyar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      '  U.ID,U.KOD,U.ROOTKOD,U.ACIKLAMA,--G.SABLONADI'
      ' SABLONID=D.ID,'
      ' SABLONADI=D.KONU, ZAMAN,ZAMANISARETI,DURUM'
      'FROM '
      '  UYARIAYAR U '
      '--LEFT OUTER JOIN AKTIVITE_SABLON G ON U.SABLONGOREVID=G.ID'
      'LEFT OUTER JOIN DUYURU D ON U.SABLONDUYURUID=D.ID')
    Left = 621
    Top = 383
  end
  object DtsUyariAyar: TDataSource
    DataSet = TabUyariAyar
    Left = 494
    Top = 366
  end
  object OpenDialog1: TOpenDialog
    Left = 642
    Top = 137
  end
  object tabStiller: TFDQuery
    BeforePost = tabStillerBeforePost
    OnNewRecord = tabStillerNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM STIL')
    Left = 415
    Top = 261
  end
  object dtsStiller: TDataSource
    DataSet = tabStiller
    OnStateChange = dtsStillerStateChange
    Left = 415
    Top = 200
  end
  object dtsStilKosul: TDataSource
    DataSet = tabStilKosul
    OnStateChange = dtsStilKosulStateChange
    Left = 52
    Top = 79
  end
  object tabStilKosul: TFDQuery
    BeforeOpen = tabStilKosulBeforeOpen
    AfterOpen = tabStilKosulAfterOpen
    OnNewRecord = tabStilKosulNewRecord
    Connection = Tablo.FDCnn
    Left = 623
    Top = 99
  end
  object FontDialog1: TFontDialog
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    Left = 400
    Top = 310
  end
  object tabKocanAyarlari: TFDQuery
    AfterOpen = tabKocanAyarlariAfterOpen
    BeforePost = tabKocanAyarlariBeforePost
    AfterPost = tabKocanAyarlariAfterPost
    OnNewRecord = tabKocanAyarlariNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      ''
      'declare @KOCANTUR INT,'
      '        @SUBE INT'
      'SET @KOCANTUR= :PTUR'
      'SET @SUBE= :SUBE'
      ''
      'SELECT * FROM KOCANAYARLARI'
      'WHERE'
      '1 = CASE WHEN @KOCANTUR = -99 THEN 1'
      '                              WHEN TUR = @KOCANTUR THEN 1'
      '                     ELSE 0'
      '               END'
      'and'
      '1 = CASE WHEN @SUBE = 0 THEN 1'
      '                              WHEN SUBEID = @SUBE THEN 1'
      '                     ELSE 0'
      '               END')
    Left = 392
    Top = 136
  end
  object dtsKocanAyarlari: TDataSource
    DataSet = tabKocanAyarlari
    OnStateChange = dtsKocanAyarlariStateChange
    Left = 584
    Top = 142
  end
  object tabSMSHesapAyarlari: TFDQuery
    AfterOpen = tabSMSHesapAyarlariAfterOpen
    BeforePost = tabSMSHesapAyarlariBeforePost
    AfterPost = tabSMSHesapAyarlariAfterPost
    OnNewRecord = tabSMSHesapAyarlariNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from SMSHESAPLARI')
    Left = 570
    Top = 337
  end
  object dtsSMSHesaplari: TDataSource
    DataSet = tabSMSHesapAyarlari
    OnStateChange = dtsSMSHesaplariStateChange
    Left = 534
    Top = 371
  end
  object tabEpostaHesaplari: TFDQuery
    AfterOpen = tabEpostaHesaplariAfterOpen
    BeforePost = tabEpostaHesaplariBeforePost
    AfterPost = tabEpostaHesaplariAfterPost
    OnNewRecord = tabEpostaHesaplariNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from EPOSTAHESAPLARI')
    Left = 488
    Top = 165
  end
  object dtsEpostaHesaplari: TDataSource
    DataSet = tabEpostaHesaplari
    OnStateChange = dtsEpostaHesaplariStateChange
    Left = 575
    Top = 396
  end
  object DtsITSHesaplari: TDataSource
    DataSet = TabITSHesaplari
    OnStateChange = DtsITSHesaplariStateChange
    Left = 583
    Top = 396
  end
  object TabITSHesaplari: TFDQuery
    BeforePost = TabITSHesaplariBeforePost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from ITSHESAPLARI')
    Left = 512
    Top = 229
  end
  object TabListeDuzenle: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from GENINI where BOLUM=0 and DIL=:PDil')
    Left = 643
    Top = 299
  end
  object DtsListeDuzenle: TDataSource
    DataSet = TabListeDuzenle
    Left = 591
    Top = 282
  end
  object TabGoogleTakvim: TFDQuery
    AutoCalcFields = False
    BeforePost = TabGoogleTakvimBeforePost
    OnCalcFields = TabGoogleTakvimCalcFields
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  *  FROM GOOGLETAKVIMHESAPLARI'
      '--where'
      '--REHBERID = :KULLANICI')
    Left = 528
    Top = 128
    object TabGoogleTakvimID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabGoogleTakvimREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabGoogleTakvimEMAIL: TWideStringField
      FieldName = 'EMAIL'
      Size = 100
    end
    object TabGoogleTakvimSIFRE: TWideStringField
      FieldName = 'SIFRE'
      Size = 100
    end
    object TabGoogleTakvimTAKVIMID: TWideStringField
      FieldName = 'TAKVIMID'
      Size = 250
    end
    object TabGoogleTakvimACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object TabGoogleTakvimKULLANICIADI: TWideStringField
      FieldName = 'KULLANICIADI'
      Size = 250
    end
    object TabGoogleTakvimP12DOSYA: TBlobField
      FieldName = 'P12DOSYA'
    end
    object TabGoogleTakvimKULLANAN: TStringField
      FieldKind = fkCalculated
      FieldName = 'KULLANAN'
      Calculated = True
    end
  end
  object DtsGoogleTakvim: TDataSource
    DataSet = TabGoogleTakvim
    OnStateChange = DtsGoogleTakvimStateChange
    Left = 600
    Top = 232
  end
  object KilitlemeMenu: TPopupMenu
    Left = 295
    Top = 215
    object TumunuSecKaldir: TMenuItem
      Tag = 1
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      OnClick = TumunuSecKaldirClick
    end
    object mnKaldr1: TMenuItem
      Tag = 2
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      OnClick = TumunuSecKaldirClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object SeililereTarihAta1: TMenuItem
      Tag = 4
      Caption = 'Se'#231'ilenlere Tarih Ata'
      OnClick = YeniKilit1Click
    end
    object SeilenlereOtomatikGnGir1: TMenuItem
      Tag = 5
      Caption = 'Se'#231'ilenlere Otomatik G'#252'n Ata'
      OnClick = YeniKilit1Click
    end
    object SeilenleriAktifYap1: TMenuItem
      Caption = 'Se'#231'ilenleri Kilidini'
      object Aktif1: TMenuItem
        Caption = 'Aktif Ata'
        OnClick = Aktif1Click
      end
      object PasifAta1: TMenuItem
        Caption = 'Pasif Ata'
      end
    end
  end
  object DsTabKilitler: TDataSource
    DataSet = TabKilitler
    OnStateChange = DtsITSHesaplariStateChange
    Left = 191
    Top = 212
  end
  object TabKilitler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        ' SELECT  [ID],[MODULID],[MODULADI],OTOGUN=[OTOGUNYENI], TARIH=[T' +
        'ARIHYENI],KILIT=[KILITYENI] ,[KASATUR] ,[SUBEID] '
      'FROM MODUL WHERE ISNULL(KASATUR,0)>0'
      'order by cast(MODULID as varchar(20))')
    Left = 139
    Top = 211
  end
  object JvOpenDialog1: TJvOpenDialog
    Height = 0
    Width = 0
    Left = 296
    Top = 224
  end
end
