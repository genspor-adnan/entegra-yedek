object OpsiyonIKDlg: TOpsiyonIKDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #304'K Opsiyonlar'
  ClientHeight = 501
  ClientWidth = 507
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 460
    Width = 507
    Height = 41
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 0
    object CancelBtn: TBitBtn
      Left = 256
      Top = 9
      Width = 72
      Height = 24
      Cancel = True
      Caption = '&Kapat'
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
      TabOrder = 0
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 179
      Top = 9
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
      TabOrder = 1
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 507
    Height = 460
    ActivePage = TabSheetGenel
    Align = alClient
    TabOrder = 1
    object TabSheetGenel: TTabSheet
      Caption = 'Genel'
      object BitBtn1: TBitBtn
        Left = 7
        Top = 4
        Width = 300
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
        TabOrder = 0
        Visible = False
        OnClick = BitBtn1Click
      end
      object GrupKategoriTus: TBitBtn
        Left = 7
        Top = 34
        Width = 300
        Height = 25
        Caption = 'Personl Kart Grup-Kategori Bilgilerini Ayarlama'
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
        OnClick = GrupKategoriTusClick
      end
      object cxGroupBox3: TcxGroupBox
        Left = 9
        Top = 65
        Caption = 'Cari Kart Bilgi Ayarlar'#305
        TabOrder = 2
        Height = 138
        Width = 183
        object ListBoxBilgi: TcxListBox
          Left = 2
          Top = 18
          Width = 179
          Height = 118
          Align = alClient
          ItemHeight = 13
          Items.Strings = (
            'Personel '#304'leti'#351'im'
            '-'
            'Personel Temel'
            'Personel '#304'lgili'
            'Personel '#220'cret Tahakkuk'
            'Personel '#220'cret Kesinti')
          ParentShowHint = False
          ShowHint = False
          TabOrder = 0
          OnClick = ListBoxBilgiClick
        end
      end
      object cxLabel4: TcxLabel
        Left = 9
        Top = 223
        Caption = 'Personel Kod Giri'#351'i'
        Transparent = True
      end
      object cbPersKodGirisi: TcxImageComboBox
        Left = 154
        Top = 221
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Manuel'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Kod A'#287'ac'#305'ndan'
            Value = 2
          end>
        TabOrder = 4
        Width = 153
      end
      object VarsayilanKlasor: TcxButtonEdit
        Left = 154
        Top = 269
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorPropertiesButtonClick
        TabOrder = 5
        Text = 'VarsayilanKlasor'
        Width = 153
      end
      object cxLabel6: TcxLabel
        Left = 9
        Top = 247
        Caption = 'G'#246'r'#252'necek '#350'ubeler'
        Transparent = True
      end
      object CbSubeler: TcxImageComboBox
        Left = 154
        Top = 245
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Sadece Ortak'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Sadece Kendi '#350'ubesi'
            Value = 1
          end
          item
            Description = 'Ortak + Kendi '#350'ubesi'
            Value = 2
          end
          item
            Description = 'Ortak + T'#252'm '#350'ubeler'
            Value = 3
          end>
        TabOrder = 7
        Width = 153
      end
      object cxLabel2: TcxLabel
        Left = 9
        Top = 270
        Caption = 'Varsay'#305'lan Klasor'
        Transparent = True
      end
      object cxLabel7: TcxLabel
        Left = 9
        Top = 300
        Caption = 'Bedelsiz S'#305'f'#305'rlama'
        Transparent = True
      end
      object RadioBedelsizGunluk: TcxRadioButton
        Left = 107
        Top = 301
        Width = 53
        Height = 17
        Caption = 'G'#252'nl'#252'k'
        Checked = True
        TabOrder = 10
        TabStop = True
      end
      object RadioBedelsizAylik: TcxRadioButton
        Left = 185
        Top = 301
        Width = 76
        Height = 17
        Caption = 'Ayl'#305'k'
        TabOrder = 11
      end
      object EditGratisBasGun: TcxSpinEdit
        Left = 264
        Top = 299
        Properties.ImmediatePost = True
        Properties.LargeIncrement = 1.000000000000000000
        Properties.MaxValue = 28.000000000000000000
        Properties.MinValue = 1.000000000000000000
        TabOrder = 12
        Value = 1
        Width = 43
      end
      object CheckOdemeEksiOlamaz: TcxCheckBox
        Left = 21
        Top = 352
        Caption = #199'ar'#351'af Listede Maa'#351' '#214'demesi Eksi olamaz'
        TabOrder = 13
      end
      object SektorTus: TcxButton
        Left = 264
        Top = 65
        Width = 134
        Height = 25
        Caption = 'Sekt'#246'r Listesi'
        TabOrder = 14
        OnClick = SektorTusClick
      end
      object DepartmanTus: TcxButton
        Left = 264
        Top = 96
        Width = 134
        Height = 25
        Caption = 'Genel Departman Listesi'
        TabOrder = 15
        OnClick = DepartmanTusClick
      end
      object GorevTus: TcxButton
        Left = 264
        Top = 127
        Width = 134
        Height = 25
        Caption = 'Genel G'#246'rev Listesi'
        TabOrder = 16
        OnClick = GorevTusClick
      end
      object BizimDepartmanTus: TcxButton
        Left = 265
        Top = 158
        Width = 134
        Height = 25
        Caption = 'Bizim Departman Listesi'
        TabOrder = 17
        OnClick = BizimDepartmanTusClick
      end
      object BizimGorevTus: TcxButton
        Left = 265
        Top = 188
        Width = 134
        Height = 25
        Caption = 'Bizim G'#246'rev Listesi'
        TabOrder = 18
        OnClick = BizimGorevTusClick
      end
      object cxButton2: TcxButton
        Left = 310
        Top = 346
        Width = 134
        Height = 25
        Caption = 'Yabanc'#305' Diller Listesi'
        Default = True
        TabOrder = 19
        OnClick = cxButton2Click
      end
      object cxLabel18: TcxLabel
        Left = 24
        Top = 387
        Caption = 'Maa'#351' Masraf Kalemi'
        Transparent = True
      end
      object BeMasrafMerkezi: TcxButtonEdit
        Left = 143
        Top = 386
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = False
        Properties.OnButtonClick = BeMasrafMerkeziPropertiesButtonClick
        TabOrder = 21
        Width = 192
      end
    end
    object TabSheetPDKS: TTabSheet
      Caption = 'PDKS'
      ImageIndex = 1
      object BtnVardiyaTanimlari: TcxButton
        Left = 55
        Top = 24
        Width = 134
        Height = 25
        Caption = 'Vardiya Tan'#305'mlar'#305
        TabOrder = 0
        OnClick = BtnVardiyaTanimlariClick
      end
      object cxLabel1: TcxLabel
        Left = 30
        Top = 229
        Caption = 'PDKS Bilgi Giri'#351'i'
        Transparent = True
      end
      object ComboPDKSGirisi: TcxImageComboBox
        Left = 134
        Top = 227
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Manuel'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Cihazdan'
            Value = 1
          end>
        TabOrder = 2
        Width = 151
      end
      object PDKSDurumListesiTus: TcxButton
        Left = 55
        Top = 55
        Width = 134
        Height = 25
        Caption = 'PDKS Durum Listesi'
        TabOrder = 3
        OnClick = PDKSDurumListesiTusClick
      end
      object BtnHareketTanimlari: TcxButton
        Left = 55
        Top = 86
        Width = 134
        Height = 25
        Caption = 'Hareket Tan'#305'mlar'#305
        TabOrder = 4
        OnClick = BtnHareketTanimlariClick
      end
      object cxButton1: TcxButton
        Left = 313
        Top = 24
        Width = 134
        Height = 25
        Caption = 'PDKS Giri'#351' T'#252'rleri'
        TabOrder = 5
        OnClick = cxButton1Click
      end
      object chkKartNoSorgula: TCheckBox
        Left = 307
        Top = 229
        Width = 152
        Height = 17
        Caption = 'Kart No Sorgula'
        TabOrder = 6
      end
      object BtnVardiyatTur: TcxButton
        Left = 313
        Top = 55
        Width = 134
        Height = 25
        Caption = 'Vardiya T'#252'rleri'
        TabOrder = 7
        OnClick = BtnVardiyatTurClick
      end
      object cxLabel3: TcxLabel
        Left = 30
        Top = 270
        Caption = 'Maa'#351' G'#252'n'#252
        Transparent = True
      end
      object EditMaasGunu: TcxSpinEdit
        Left = 134
        Top = 268
        Properties.MaxValue = 28.000000000000000000
        Properties.MinValue = 1.000000000000000000
        TabOrder = 9
        Value = 1
        Width = 53
      end
      object cxLabel5: TcxLabel
        Left = 223
        Top = 269
        Caption = 'Avans G'#252'n'#252
        Transparent = True
      end
      object EditAvansGunu: TcxSpinEdit
        Left = 307
        Top = 268
        Properties.MaxValue = 28.000000000000000000
        Properties.MinValue = 1.000000000000000000
        TabOrder = 11
        Value = 1
        Width = 53
      end
      object CheckResmiCalisma: TcxCheckBox
        Left = 13
        Top = 344
        Caption = 'Resmi bayramlarda '#231'al'#305#351'ma var'
        TabOrder = 12
      end
      object CheckDiniCalisma: TcxCheckBox
        Left = 13
        Top = 371
        Caption = 'Dini bayramlarda '#231'al'#305#351'ma var'
        TabOrder = 13
      end
      object CheckResmiMesai: TcxCheckBox
        Left = 273
        Top = 344
        Caption = 'Resmi bayramlarda mesai eklenecek'
        TabOrder = 14
      end
      object CheckDiniMesai: TcxCheckBox
        Left = 273
        Top = 371
        Caption = 'Dini bayramlarda mesai eklenecek'
        TabOrder = 15
      end
      object CheckMaasDevir: TcxCheckBox
        Left = 30
        Top = 304
        Caption = 'Maa'#351' listesine varsa '#246'nceki aylardan devirler gelsin'
        TabOrder = 16
      end
      object cxLabel17: TcxLabel
        Left = 31
        Top = 181
        Caption = 'Yemek Mola S'#252'resi'
      end
      object EditMola: TcxTimeEdit
        Left = 134
        Top = 179
        Properties.TimeFormat = tfHourMin
        TabOrder = 18
        Width = 70
      end
    end
    object TabSheetIzin: TTabSheet
      Caption = #304'zin'
      ImageIndex = 2
      object GBGorev: TcxGroupBox
        Left = 19
        Top = 34
        Caption = #304'zin Listeleri Ayarlama'
        TabOrder = 0
        Height = 214
        Width = 134
        object cxGrid2: TcxGrid
          Left = 2
          Top = 18
          Width = 130
          Height = 194
          Align = alClient
          TabOrder = 0
          object GridListeDuzenleDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
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
              Width = 130
            end
            object GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn
              DataBinding.FieldName = 'DEGER'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = GridListeDuzenleDBTableView1
          end
        end
      end
      object cxGroupBox1: TcxGroupBox
        Left = 175
        Top = 35
        Caption = 'Standart '#304'zin S'#252'releri'
        TabOrder = 1
        Height = 213
        Width = 229
        object cxLabel8: TcxLabel
          Left = 21
          Top = 34
          Caption = '1 -'
          Transparent = True
        end
        object EditIzinYil1: TcxSpinEdit
          Left = 44
          Top = 33
          Properties.MaxValue = 28.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 1
          Value = 5
          Width = 53
        end
        object cxLabel9: TcxLabel
          Left = 194
          Top = 37
          Caption = 'g'#252'n'
          Transparent = True
        end
        object EditIzinSure1: TcxSpinEdit
          Left = 135
          Top = 33
          Properties.MaxValue = 28.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 3
          Value = 14
          Width = 53
        end
        object CheckIzinCumartesi: TcxCheckBox
          Left = 44
          Top = 113
          Caption = 'Cumartesi g'#252'nleri izne dahil'
          TabOrder = 4
        end
        object CheckIzinPazar: TcxCheckBox
          Left = 44
          Top = 135
          Caption = 'Pazar g'#252'nleri izne dahil'
          TabOrder = 5
        end
        object cxLabel10: TcxLabel
          Left = 103
          Top = 34
          Caption = 'y'#305'l'
          Transparent = True
        end
        object cxLabel11: TcxLabel
          Left = 23
          Top = 61
          Caption = '6 -'
          Transparent = True
        end
        object EditIzinYil2: TcxSpinEdit
          Left = 44
          Top = 60
          Properties.MaxValue = 28.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 8
          Value = 10
          Width = 53
        end
        object cxLabel12: TcxLabel
          Left = 194
          Top = 64
          Caption = 'g'#252'n'
          Transparent = True
        end
        object EditIzinSure2: TcxSpinEdit
          Left = 135
          Top = 60
          Properties.MaxValue = 28.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 10
          Value = 20
          Width = 53
        end
        object cxLabel13: TcxLabel
          Left = 103
          Top = 61
          Caption = 'y'#305'l'
          Transparent = True
        end
        object cxLabel14: TcxLabel
          Left = 21
          Top = 87
          Caption = '11 -'
          Transparent = True
        end
        object EditIzinYil3: TcxSpinEdit
          Left = 44
          Top = 86
          Properties.MaxValue = 28.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 13
          Value = 28
          Width = 53
        end
        object cxLabel15: TcxLabel
          Left = 194
          Top = 90
          Caption = 'g'#252'n'
          Transparent = True
        end
        object EditIzinSure3: TcxSpinEdit
          Left = 135
          Top = 86
          Properties.MaxValue = 28.000000000000000000
          Properties.MinValue = 1.000000000000000000
          TabOrder = 15
          Value = 26
          Width = 53
        end
        object cxLabel16: TcxLabel
          Left = 103
          Top = 87
          Caption = 'y'#305'l'
          Transparent = True
        end
        object ButunPersYillikIzinEkle: TcxButton
          Left = 23
          Top = 167
          Width = 203
          Height = 25
          Caption = 'B'#252't'#252'n personelin y'#305'll'#305'k izinlerini ekle'
          TabOrder = 17
          OnClick = ButunPersYillikIzinEkleClick
        end
      end
    end
  end
end
