object OpsiyonKasaDlg: TOpsiyonKasaDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Kasa Opsiyonlar'#305' '
  ClientHeight = 698
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 512
    Height = 660
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 658
    ClientRectLeft = 2
    ClientRectRight = 510
    ClientRectTop = 28
    object cxTabSheet1: TcxTabSheet
      Caption = 'Genel'
      ImageIndex = 11
      object RadioBakiye: TcxRadioGroup
        Left = 328
        Top = 124
        Caption = 'Kasa Bakiye Kural'#305
        Properties.Items = <
          item
            Caption = 'Yetersizse '#231#305'kamas'#305'n'
          end
          item
            Caption = 'Yetersizse de '#231#305'kabilsin'
          end>
        ItemIndex = 0
        TabOrder = 4
        Height = 68
        Width = 177
      end
      object EditKDV: TcxSpinEdit
        Left = 111
        Top = 5
        Properties.AssignedValues.MinValue = True
        Properties.MaxValue = 50.000000000000000000
        TabOrder = 0
        Width = 40
      end
      object cxLabel2: TcxLabel
        Left = 5
        Top = 6
        Caption = 'Varsay'#305'lan KDV %'
        Transparent = True
      end
      object cxGroupBox4: TcxGroupBox
        Left = 5
        Top = 392
        Caption = 'B'#252't'#231'e Ger'#231'ekle'#351'en Bilgileri'
        TabOrder = 6
        Height = 63
        Width = 320
        object RadioBtnButceFaturadan: TcxRadioButton
          Left = 1
          Top = 20
          Width = 186
          Height = 17
          Caption = 'Al'#305#351'-Sat'#305#351' Belgelerinden Derle'
          TabOrder = 0
          Transparent = True
        end
        object RadioBtnButceKasadan: TcxRadioButton
          Left = 1
          Top = 41
          Width = 187
          Height = 17
          Caption = 'Ger'#231'ekle'#351'en '#214'demelerden Derle'
          Checked = True
          TabOrder = 1
          TabStop = True
          Transparent = True
        end
      end
      object btnKampanyalar: TcxButton
        Left = 178
        Top = 5
        Width = 160
        Height = 25
        Caption = 'Kampanyalar'
        TabOrder = 1
        OnClick = btnKampanyalarClick
      end
      object Button6: TButton
        Left = 346
        Top = 79
        Width = 157
        Height = 25
        Caption = 'Tahsilat A'#231#305'klama Listesi'
        TabOrder = 3
        OnClick = Button6Click
      end
      object Button7: TButton
        Left = 346
        Top = 50
        Width = 157
        Height = 25
        Caption = #214'deme A'#231#305'klama Listesi'
        TabOrder = 2
        OnClick = Button7Click
      end
      object cxLabel42: TcxLabel
        Left = 5
        Top = 469
        Caption = 'Masraf-Gelir Merkezi G'#246'r'#252'necek '#350'ubeler'
        Transparent = True
      end
      object CbSubeler: TcxImageComboBox
        Left = 221
        Top = 467
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
        Width = 151
      end
      object cxLabel43: TcxLabel
        Left = 5
        Top = 496
        Caption = 'Kasa Tan'#305'mlar'#305' G'#246'r'#252'necek '#350'ubeler'
        Transparent = True
      end
      object CbSubeler2: TcxImageComboBox
        Left = 221
        Top = 494
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
        TabOrder = 9
        Width = 151
      end
      object ComboBilgiEposta: TcxImageComboBox
        Left = 221
        Top = 522
        RepositoryItem = Tablo.RepBilgilendirme
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 11
        Width = 151
      end
      object cxLabel44: TcxLabel
        Left = 5
        Top = 524
        Caption = #214'deme Plan'#305' Bilgilendirme E-Posta'
        Transparent = True
      end
      object cxLabel45: TcxLabel
        Left = 5
        Top = 551
        Caption = #214'deme Plan'#305' Bilgilendirme Sms'
        Transparent = True
      end
      object comboBilgiSms: TcxImageComboBox
        Left = 221
        Top = 549
        RepositoryItem = Tablo.RepBilgilendirme
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 13
        Width = 151
      end
      object GBBelgeGiris: TcxGroupBox
        Left = 5
        Top = 53
        Caption = 'Belge Giri'#351'te'
        TabOrder = 15
        Height = 75
        Width = 320
        object ComboBelgeGirisMM: TcxImageComboBox
          Left = 137
          Top = 18
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 0
          Width = 151
        end
        object cxLabel3: TcxLabel
          Left = 1
          Top = 20
          Caption = 'Masraf Kalemi'
          Transparent = True
        end
        object cxLabel4: TcxLabel
          Left = 1
          Top = 47
          Caption = 'Srm.Mrk. Gider'
          Transparent = True
        end
        object ComboBelgeGirisSRM: TcxImageComboBox
          Left = 137
          Top = 45
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 3
          Width = 151
        end
      end
      object cxGroupBox2: TcxGroupBox
        Left = 5
        Top = 139
        Caption = 'Belge '#199#305'k'#305#351'ta'
        TabOrder = 16
        Height = 75
        Width = 320
        object ComboBelgeCikisGM: TcxImageComboBox
          Left = 137
          Top = 18
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 0
          Width = 151
        end
        object cxLabel5: TcxLabel
          Left = 1
          Top = 20
          Caption = 'Gelir Kalemi'
          Transparent = True
        end
        object cxLabel6: TcxLabel
          Left = 1
          Top = 46
          Caption = 'Srm.Mrk. Gelir'
          Transparent = True
        end
        object ComboBelgeCikisSRM: TcxImageComboBox
          Left = 137
          Top = 44
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 3
          Width = 151
        end
      end
      object cxGroupBox3: TcxGroupBox
        Left = 6
        Top = 225
        Caption = #214'demede'
        TabOrder = 17
        Height = 75
        Width = 320
        object ComboOdemeMM: TcxImageComboBox
          Left = 137
          Top = 17
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 0
          Width = 151
        end
        object cxLabel7: TcxLabel
          Left = 1
          Top = 19
          Caption = 'Masraf Kalemi'
          Transparent = True
        end
        object cxLabel8: TcxLabel
          Left = 1
          Top = 45
          Caption = 'Srm.Mrk. Gider'
          Transparent = True
        end
        object ComboOdemeSRM: TcxImageComboBox
          Left = 137
          Top = 43
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 3
          Width = 151
        end
      end
      object cxGroupBox6: TcxGroupBox
        Left = 5
        Top = 307
        Caption = 'Tahsilatta'
        TabOrder = 18
        Height = 75
        Width = 320
        object ComboTahsilatGM: TcxImageComboBox
          Left = 137
          Top = 17
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 0
          Width = 151
        end
        object cxLabel9: TcxLabel
          Left = 1
          Top = 21
          Caption = 'Gelir Kalemi'
          Transparent = True
        end
        object cxLabel10: TcxLabel
          Left = 1
          Top = 45
          Caption = 'Srm.Mrk. Gelir'
          Transparent = True
        end
        object ComboTahsilatSRM: TcxImageComboBox
          Left = 137
          Top = 43
          RepositoryItem = Tablo.RepGorunurDurumu
          Properties.ImmediatePost = True
          Properties.Items = <>
          TabOrder = 3
          Width = 151
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 660
    Width = 512
    Height = 38
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 1
    object CancelBtn: TBitBtn
      Left = 422
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
      Left = 344
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
end
