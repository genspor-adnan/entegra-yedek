object OpsiyonDokumanDlg: TOpsiyonDokumanDlg
  Left = 0
  Top = 0
  Caption = 'Dok'#252'man Opsiyonlar'#305
  ClientHeight = 491
  ClientWidth = 521
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 0
    Width = 521
    Height = 450
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 446
    ClientRectLeft = 4
    ClientRectRight = 517
    ClientRectTop = 24
    object cxTabSheet1: TcxTabSheet
      Caption = 'Dok'#252'man'
      ImageIndex = 0
      object Panel1: TPanel
        Left = 0
        Top = 380
        Width = 513
        Height = 42
        Align = alBottom
        Alignment = taLeftJustify
        TabOrder = 0
        object DosyaMigrasyonTus: TcxButton
          Left = 8
          Top = 8
          Width = 240
          Height = 27
          Caption = 'Belgeleri DOSYA deposuna ta'#351#305' (Migrasyon)'
          TabOrder = 0
          OnClick = DosyaMigrasyonTusClick
        end
      end
      object LabelDosyaToplam: TcxLabel
        Left = 420
        Top = 220
        Caption = '-----'
      end
      object Label2: TcxLabel
        Left = 16
        Top = 264
        Caption = 'Outlook Gelen Kutusu Varsay'#305'lan Klasor'
      end
      object Label3: TcxLabel
        Left = 16
        Top = 289
        Caption = 'Outlook Giden Kutusu Varsay'#305'lan Klasor'
      end
      object GroupBox4: TGroupBox
        Left = 8
        Top = 13
        Width = 490
        Height = 224
        Caption = 'Dok'#252'man kay'#305't bilgileri'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 4
        object LabelDizin: TcxLabel
          Left = 15
          Top = 65
          Caption = 'Dizin'
        end
        object Label9: TcxLabel
          Left = 15
          Top = 170
          Caption = 'Ar'#351'iv i'#231'in max dosya b'#252'y'#252'kl'#252#287#252
          Properties.WordWrap = True
          Width = 158
        end
        object DokumanDizin: TcxButtonEdit
          Left = 180
          Top = 64
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.MaxLength = 0
          Properties.ReadOnly = False
          Properties.OnButtonClick = DokumanDizinPropertiesButtonClick
          TabOrder = 3
          Width = 301
        end
        object cxLabel5: TcxLabel
          Left = 15
          Top = 36
          Caption = 'Dok'#252'man kay'#305't ortam'#305
        end
        object DokumanOrtami: TcxRadioGroup
          Left = 180
          Top = 18
          Properties.Columns = 2
          Properties.Items = <
            item
              Caption = 'Veri Taban'#305
            end
            item
              Caption = 'Diskte Klas'#246'r'
            end>
          Properties.OnChange = DokumanOrtamiPropertiesChange
          ItemIndex = 1
          TabOrder = 0
          Height = 45
          Width = 302
        end
        object cxLabel6: TcxLabel
          Left = 267
          Top = 170
          Caption = 'KB'
        end
        object DokumanBoyut: TcxSpinEdit
          Left = 180
          Top = 166
          TabOrder = 6
          Width = 81
        end
        object cxLabel1: TcxLabel
          Left = 15
          Top = 201
          Caption = 'Kay'#305'tl'#305' Dosya Say'#305's'#305
        end
        object LabelDosyaSay: TcxLabel
          Left = 180
          Top = 201
          Caption = '----'
        end
        object KlasorVTAktarTus: TcxButton
          Left = 346
          Top = 167
          Width = 135
          Height = 25
          Caption = 'Klas'#246'r --> VT Aktar'
          TabOrder = 9
          OnClick = KlasorVTAktarTusClick
        end
      end
      object VarsayilanKlasor: TcxButtonEdit
        Left = 209
        Top = 262
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorPropertiesButtonClick
        TabOrder = 5
        Text = 'VarsayilanKlasor'
        Width = 121
      end
      object VarsayilanKlasorGiden: TcxButtonEdit
        Left = 209
        Top = 287
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorGidenPropertiesButtonClick
        TabOrder = 6
        Text = 'VarsayilanKlasor'
        Width = 121
      end
      object CheckTarayiciKullanimda: TcxCheckBox
        Left = 97
        Top = 312
        Caption = 'Taray'#305'c'#305' Kullan'#305'mdad'#305'r'
        Properties.Alignment = taRightJustify
        TabOrder = 7
        Transparent = True
      end
      object PanelDizinDikkat: TPanel
        Left = 156
        Top = 112
        Width = 339
        Height = 65
        Align = alCustom
        Alignment = taLeftJustify
        BevelOuter = bvNone
        TabOrder = 8
        object cxLabel7: TcxLabel
          Left = 0
          Top = -3
          Caption = 
            'Dikkat! Veri taban'#305'n'#305'n bulundu'#287'u bilgisayarda dizin olu'#351'turulmal' +
            #305'd'#305'r.'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object cxLabel8: TcxLabel
          Left = 1
          Top = 15
          Caption = 'C,D,E s'#252'r'#252'c'#252'lerine bak'#305'p en geni'#351' alanl'#305' yerde dizin olu'#351'turun.'
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clRed
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
        end
        object cxButton1: TcxButton
          Left = 198
          Top = 37
          Width = 135
          Height = 25
          Caption = 'Klas'#246're kay'#305't yetkisi ver'
          TabOrder = 2
          OnClick = cxButton1Click
        end
      end
      object cxLabel4: TcxLabel
        Left = 291
        Top = 220
        Caption = 'Toplam Dosya B'#252'y'#252'kl'#252#287#252
      end
      object ComboRevizeMiktar: TcxComboBox
        Left = 209
        Top = 339
        ParentFont = False
        Properties.Items.Strings = (
          'Manuel'
          'Ondal'#305'k'
          'Tamsay'#305)
        TabOrder = 10
        Width = 121
      end
      object cxLabel14: TcxLabel
        Left = 77
        Top = 339
        Caption = 'Yeni Revize Art'#305#351' Miktar'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Width = 126
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 450
    Width = 521
    Height = 41
    Align = alBottom
    TabOrder = 1
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
  end
  object OpenDialog1: TOpenDialog
    Left = 444
    Top = 317
  end
end
