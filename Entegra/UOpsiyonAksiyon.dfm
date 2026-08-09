object OpsiyonAksiyonDlg: TOpsiyonAksiyonDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'CRM Opsiyonlar'
  ClientHeight = 524
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 483
    Width = 580
    Height = 41
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 0
    object CancelBtn: TBitBtn
      Left = 256
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
      TabOrder = 0
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 177
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
      TabOrder = 1
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object PageControl1: TPageControl
    Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 580
    Height = 483
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'Genel'
      ImageIndex = 11
      object BitBtn2: TBitBtn
        Left = 14
        Top = 76
        Width = 317
        Height = 25
        Caption = 'Personele Toplu Proje Aktar'#305'm'#305
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
        OnClick = BitBtn2Click
      end
      object BitBtn4: TBitBtn
        Left = 14
        Top = 107
        Width = 317
        Height = 25
        Caption = 'Personele Toplu Aktivite Aktar'#305'm'#305
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
        OnClick = BitBtn4Click
      end
    end
    object FirsatPage: TTabSheet
      Caption = 'Sat'#305#351' F'#305'rsat'#305
      ImageIndex = 31
      object cxLabel1: TcxLabel
        Left = 58
        Top = 142
        Caption = 'F'#305'rsat Kodu Olu'#351'turma'
        Transparent = True
      end
      object ComboFirsatKodu: TcxImageComboBox
        Left = 204
        Top = 140
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Manuel'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Otomatik'
            Value = 1
          end>
        TabOrder = 1
        Width = 151
      end
      object CheckLojistikSekme: TcxCheckBox
        Left = 59
        Top = 61
        Caption = 'Lojistik sekmesi g'#246'r'#252'ns'#252'n'
        TabOrder = 2
        Transparent = True
      end
      object CheckFirsatAsama: TcxCheckBox
        Left = 60
        Top = 90
        Caption = 'A'#351'ama sekmesi g'#246'r'#252'ns'#252'n'
        TabOrder = 3
        Transparent = True
      end
      object CheckIsListesiSekme: TcxCheckBox
        Left = 59
        Top = 31
        Caption = #304#351' Listesi sekmesi g'#246'r'#252'ns'#252'n'
        TabOrder = 4
        Transparent = True
      end
    end
    object ProjePage: TTabSheet
      Caption = 'Proje'
      ImageIndex = 13
      OnShow = ProjePageShow
      object Label1: TLabel
        Left = 4
        Top = 327
        Width = 84
        Height = 16
        Caption = 'Varsay'#305'lan Klasor'
      end
      object BitBtn3: TBitBtn
        Left = 148
        Top = 407
        Width = 317
        Height = 25
        Caption = #304'lgili / G'#246'revi Ayarlama'
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
      end
      object cxGroupBox5: TcxGroupBox
        Left = 145
        Top = 13
        Caption = 'Proje Detay Alanlar'#305
        TabOrder = 1
        Height = 181
        Width = 134
        object ProjeDetayAlanlariList: TcxListBox
          Left = 2
          Top = 48
          Width = 130
          Height = 131
          Align = alClient
          ItemHeight = 16
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          OnClick = ProjeDetayAlanlariListClick
        end
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 5
          Top = 24
          Width = 124
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
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
          List = True
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          Transparent = True
          object ToolButton2: TToolButton
            Left = 0
            Top = 0
            Caption = 'Projeye Ba'#287'la'
            ImageIndex = 0
            OnClick = ToolButton2Click
          end
          object ToolButton4: TToolButton
            Left = 23
            Top = 0
            Caption = 'ToolButton4'
            ImageIndex = 7
            OnClick = ToolButton4Click
          end
          object ToolButton3: TToolButton
            Left = 46
            Top = 0
            Caption = 'ToolButton1'
            ImageIndex = 1
            OnClick = ToolButton3Click
          end
        end
      end
      object cxGroupBox7: TcxGroupBox
        Left = 285
        Top = 13
        Caption = 'Tarih'#231'eye eklenecekler'
        TabOrder = 2
        Height = 181
        Width = 139
        object CbProjTrhcSorumlu: TcxCheckBox
          Left = 3
          Top = 17
          Caption = 'Sorumlu'
          State = cbsChecked
          TabOrder = 0
          Transparent = True
        end
        object CbProjTrhcAsama: TcxCheckBox
          Left = 3
          Top = 36
          Caption = 'A'#351'ama'
          State = cbsChecked
          TabOrder = 1
          Transparent = True
        end
        object CbProjTrhcDurum: TcxCheckBox
          Left = 3
          Top = 55
          Caption = 'Durum'
          State = cbsChecked
          TabOrder = 2
          Transparent = True
        end
        object CbProjTrhcSonuc: TcxCheckBox
          Left = 3
          Top = 74
          Caption = 'Sonu'#231
          State = cbsChecked
          TabOrder = 3
          Transparent = True
        end
        object CbProjTrhcMusteriIlgili: TcxCheckBox
          Left = 3
          Top = 94
          Caption = 'M'#252#351'teri '#304'lgili'
          State = cbsChecked
          TabOrder = 4
          Transparent = True
        end
      end
      object GBProje: TcxGroupBox
        Left = 2
        Top = 13
        Caption = 'Proje Listeleri Ayarlama'
        TabOrder = 3
        Height = 181
        Width = 137
      end
      object VarsayilanKlasor: TcxButtonEdit
        Left = 150
        Top = 324
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = VarsayilanKlasorPropertiesButtonClick
        TabOrder = 4
        Text = 'VarsayilanKlasor'
        Width = 151
      end
      object cxLabel43: TcxLabel
        Left = 3
        Top = 352
        Caption = 'G'#246'r'#252'necek '#350'ubeler'
        Transparent = True
      end
      object CbSubeler: TcxImageComboBox
        Left = 149
        Top = 350
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
        TabOrder = 6
        Width = 151
      end
      object cxLabel2: TcxLabel
        Left = 4
        Top = 376
        Caption = 'Panel Alan'
        Transparent = True
      end
      object SEditPanelAlan: TSpinEdit
        Left = 150
        Top = 375
        Width = 62
        Height = 26
        MaxValue = 0
        MinValue = 0
        TabOrder = 8
        Value = 200
      end
      object cxLabel5: TcxLabel
        Left = 3
        Top = 301
        Caption = 'Proje Kodu Olu'#351'turma'
        Transparent = True
      end
      object ComboProjeKodu: TcxImageComboBox
        Left = 149
        Top = 294
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Manuel'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Otomatik'
            Value = 1
          end>
        TabOrder = 10
        Width = 151
      end
      object CheckPrjKapatma: TcxCheckBox
        Left = 3
        Top = 200
        Caption = 'Proje kapan'#305'nca ba'#287'l'#305' tekliflerin durumunu  sorsun'
        State = cbsChecked
        TabOrder = 11
        Transparent = True
      end
      object CheckPrjMaliyetEflow: TcxCheckBox
        Left = 3
        Top = 222
        Caption = 
          'Proje maliyet hesaplamas'#305'n'#305' E-Flow '#214'demelerine g'#246're yap ('#214'zel Ko' +
          'd Alan'#305'na Bak)'
        State = cbsChecked
        TabOrder = 12
        Transparent = True
      end
    end
    object GorevPage: TTabSheet
      Caption = #304#351' Listesi'
      ImageIndex = 32
      object checkGorevAciklama: TCheckBox
        Left = 34
        Top = 288
        Width = 240
        Height = 17
        Caption = 'Durum De'#287'i'#351'ikli'#287'inde a'#231#305'klama bilgisi al'
        TabOrder = 0
      end
      object cxLabel3: TcxLabel
        Left = 25
        Top = 240
        AutoSize = False
        Caption = 
          'Sistem tarihinden                                               ' +
          '                  g'#252'n sonras'#305'na kadar olan g'#246'revleri g'#246'ster'
        Properties.WordWrap = True
        Transparent = True
        Height = 35
        Width = 312
      end
      object edGorevGunSayisi: TSpinEdit
        Left = 260
        Top = 240
        Width = 40
        Height = 26
        MaxValue = 30
        MinValue = 0
        TabOrder = 2
        Value = 0
      end
      object groupGorevAtamaIzinKontrol: TcxRadioGroup
        Left = 315
        Top = 87
        Caption = 'Aktivite tarihinde Personel '#304'zinliyse'
        Properties.Items = <
          item
            Caption = 'G'#246'rev Atamas'#305'na '#304'zin Verme'
          end
          item
            Caption = 'Vekalet Eden Personele Ata'
          end
          item
            Caption = 'G'#246'rev Atamas'#305'na '#304'zin Ver'
          end>
        TabOrder = 3
        Height = 139
        Width = 233
      end
      object cxGroupBox3: TcxGroupBox
        Left = 25
        Top = 87
        Caption = 'Varsay'#305'lan Durumlar'
        TabOrder = 4
        Height = 139
        Width = 267
        object Label3: TLabel
          Left = 17
          Top = 27
          Width = 21
          Height = 16
          Caption = 'Yeni'
        end
        object Label5: TLabel
          Left = 17
          Top = 54
          Width = 91
          Height = 16
          Caption = 'Sonland'#305'rma Onay'#305
        end
        object Label6: TLabel
          Left = 17
          Top = 81
          Width = 80
          Height = 16
          Caption = 'Sonland'#305'rma Red'
        end
        object Label7: TLabel
          Left = 17
          Top = 108
          Width = 59
          Height = 16
          Caption = 'Sonland'#305'r'#305'ld'#305
        end
        object ComboYeni: TcxImageComboBox
          Left = 143
          Top = 23
          RepositoryItem = Tablo.RepGorevDurum
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 0
          Width = 121
        end
        object ComboSonOnay: TcxImageComboBox
          Left = 143
          Top = 50
          RepositoryItem = Tablo.RepGorevDurum
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 1
          Width = 121
        end
        object ComboSonRed: TcxImageComboBox
          Left = 143
          Top = 77
          RepositoryItem = Tablo.RepGorevDurum
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 2
          Width = 121
        end
        object ComboSon: TcxImageComboBox
          Left = 143
          Top = 104
          RepositoryItem = Tablo.RepGorevDurum
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 3
          Width = 121
        end
      end
      object BtnDurumlar: TcxButton
        Left = 25
        Top = 18
        Width = 132
        Height = 25
        Caption = 'Durumlar'
        LookAndFeel.NativeStyle = False
        TabOrder = 5
        OnClick = BtnDurumlarClick
      end
      object BtnTurler: TcxButton
        Left = 25
        Top = 49
        Width = 132
        Height = 25
        Caption = 'T'#252'rler'
        LookAndFeel.NativeStyle = False
        TabOrder = 6
        OnClick = BtnTurlerClick
      end
      object CheckOnay: TCheckBox
        Left = 34
        Top = 311
        Width = 240
        Height = 17
        Caption = 'Tamamlanan '#304#351'ler Onaya Gelsin '
        TabOrder = 7
      end
      object ComboKlasor: TcxImageComboBox
        Left = 34
        Top = 413
        RepositoryItem = Tablo.RepIsKlasorListesi
        Properties.ImmediatePost = True
        Properties.Items = <>
        TabOrder = 8
        Width = 321
      end
      object cxLabel6: TcxLabel
        Tag = -2105
        Left = 34
        Top = 390
        Cursor = crHandPoint
        Hint = 'Aktivite_Durum'
        HelpType = htKeyword
        HelpKeyword = 'AKTIVITELER.DURUM'
        Caption = 
          'Projeler sekmesinde yeni i'#351' olu'#351'turuldu'#287'unda varsay'#305'lan gelecek ' +
          'klas'#246'r'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -12
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object CheckEkipmanGor: TCheckBox
        Left = 34
        Top = 359
        Width = 240
        Height = 17
        Caption = #304#351' ekran'#305'nda ekipman bilgisi g'#246'r'#252'ns'#252'n'
        TabOrder = 10
      end
      object CheckProjeGor: TCheckBox
        Left = 34
        Top = 334
        Width = 240
        Height = 17
        Caption = #304#351' ekran'#305'nda f'#305'rsat/proje bilgisi g'#246'r'#252'ns'#252'n'
        TabOrder = 11
      end
      object CheckDemirbasGor: TCheckBox
        Tag = -5
        Left = 329
        Top = 288
        Width = 240
        Height = 17
        Caption = #304#351' listesinde "Demirba'#351'" g'#246'r'#252'ns'#252'n'
        TabOrder = 12
      end
      object CheckServisGor: TCheckBox
        Tag = -6
        Left = 329
        Top = 311
        Width = 240
        Height = 17
        Caption = #304#351' listesinde "Servis" g'#246'r'#252'ns'#252'n'
        TabOrder = 13
      end
      object CheckToplantiGor: TCheckBox
        Tag = -7
        Left = 329
        Top = 334
        Width = 240
        Height = 17
        Caption = #304#351' listesinde "Toplant'#305'" g'#246'r'#252'ns'#252'n'
        TabOrder = 14
      end
      object CheckGoogleTakvim: TCheckBox
        Tag = -7
        Left = 329
        Top = 357
        Width = 240
        Height = 17
        Caption = #304#351' listesi Google Takvimde g'#246'r'#252'ns'#252'n'
        TabOrder = 15
      end
    end
    object shSocial: TTabSheet
      Caption = 'SosyalMeyda'
      ImageIndex = 19
      object PageSocial: TcxPageControl
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 566
        Height = 446
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = shSocialMeta
        Properties.CustomButtons.Buttons = <>
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.SkinName = 'LondonLiquidSky'
        ClientRectBottom = 442
        ClientRectLeft = 4
        ClientRectRight = 562
        ClientRectTop = 27
        object shSocialMeta: TcxTabSheet
          Caption = 'Meta Business'
          ImageIndex = 19
          object dxSocialGroupBox: TdxCheckGroupBox
            AlignWithMargins = True
            Left = 3
            Top = 3
            Align = alTop
            Caption = ' Meta Business Kullan'#305'l'#305'yor '
            TabOrder = 0
            Height = 366
            Width = 552
            object Label13: TLabel
              Left = 8
              Top = 23
              Width = 152
              Height = 16
              Caption = 'Meta Facebook '#304#351'letme Kodu : '
            end
            object Label14: TLabel
              Left = 8
              Top = 53
              Width = 97
              Height = 16
              Caption = 'Uygulama (APP) ID :'
            end
            object Label19: TLabel
              Left = 9
              Top = 83
              Width = 82
              Height = 16
              Caption = 'Sayfa (Page) ID :'
            end
            object Label21: TLabel
              Left = 9
              Top = 114
              Width = 124
              Height = 16
              Caption = 'Instagram Isletme Kodu :'
            end
            object Label22: TLabel
              Left = 8
              Top = 144
              Width = 126
              Height = 16
              Caption = 'Whatsapp '#304#351'letme Kodu : '
            end
            object Label15: TLabel
              Left = 9
              Top = 174
              Width = 137
              Height = 16
              Caption = 'G'#252'ncelleme s'#305'n'#305'r'#305' (dakika)  :'
            end
            object editMetaIsletmeKodu: TcxDBTextEdit
              Left = 158
              Top = 20
              DataBinding.DataField = 'MetaIsletmeKodu'
              DataBinding.DataSource = dtsSocial
              TabOrder = 0
              Width = 252
            end
            object editApplicationID: TcxDBTextEdit
              Left = 158
              Top = 50
              DataBinding.DataField = 'FB_APPID'
              DataBinding.DataSource = dtsSocial
              TabOrder = 1
              Width = 252
            end
            object editPageID: TcxDBTextEdit
              Left = 158
              Top = 80
              DataBinding.DataField = 'FB_PageID'
              DataBinding.DataSource = dtsSocial
              TabOrder = 2
              Width = 252
            end
            object editInstagramId: TcxDBTextEdit
              Left = 158
              Top = 111
              DataBinding.DataField = 'InstagramIsletmeKodu'
              DataBinding.DataSource = dtsSocial
              TabOrder = 3
              Width = 252
            end
            object editWahtsappId: TcxDBTextEdit
              Left = 158
              Top = 141
              DataBinding.DataField = 'WhatsAppHesapKodu'
              DataBinding.DataSource = dtsSocial
              TabOrder = 4
              Width = 252
            end
            object GroupBox8: TGroupBox
              Left = 9
              Top = 202
              Width = 539
              Height = 144
              Caption = ' Eri'#351'im Anahtarlar'#305' '
              TabOrder = 6
              object Label16: TLabel
                Left = 6
                Top = 17
                Width = 61
                Height = 16
                Caption = 'App Secret :'
              end
              object Label18: TLabel
                Left = 6
                Top = 47
                Width = 86
                Height = 16
                Caption = 'App ClientToken :'
              end
              object Label20: TLabel
                Left = 6
                Top = 77
                Width = 98
                Height = 16
                Caption = 'User Access Token :'
              end
              object Label17: TLabel
                Left = 6
                Top = 107
                Width = 98
                Height = 16
                Caption = 'Page Access Token :'
              end
              object editAppSecret: TcxDBTextEdit
                Left = 132
                Top = 14
                DataBinding.DataField = 'FB_AppSecret'
                DataBinding.DataSource = dtsSocial
                TabOrder = 0
                Width = 252
              end
              object editAppClientToken: TcxDBTextEdit
                Left = 132
                Top = 44
                DataBinding.DataField = 'FB_AppClientToken'
                DataBinding.DataSource = dtsSocial
                TabOrder = 1
                Width = 252
              end
              object editUAToken: TcxDBTextEdit
                Left = 132
                Top = 74
                DataBinding.DataField = 'FB_UserAccessToken'
                DataBinding.DataSource = dtsSocial
                TabOrder = 2
                Width = 400
              end
              object editPAToken: TcxDBTextEdit
                Left = 132
                Top = 104
                DataBinding.DataField = 'FB_PageAccessToken'
                DataBinding.DataSource = dtsSocial
                TabOrder = 3
                Width = 400
              end
            end
            object editMetaTimePeriod: TcxDBSpinEdit
              Left = 158
              Top = 171
              DataBinding.DataField = 'MetaUpdatePeriod'
              DataBinding.DataSource = dtsSocial
              Properties.MaxValue = 120.000000000000000000
              Properties.MinValue = 10.000000000000000000
              TabOrder = 5
              Width = 78
            end
          end
        end
        object shSocialIMAP: TcxTabSheet
          Caption = 'Web Forn ePosta'
          ImageIndex = 17
          object dxSocialIMAPGroupBox: TdxCheckGroupBox
            AlignWithMargins = True
            Left = 3
            Top = 3
            Align = alTop
            Caption = ' IMAP ePosta kullan'#305'l'#305'yor  '
            TabOrder = 0
            Height = 334
            Width = 552
            object Label2: TLabel
              Left = 8
              Top = 23
              Width = 69
              Height = 16
              Caption = 'IMAP Sunucu :'
            end
            object Label4: TLabel
              Left = 8
              Top = 53
              Width = 118
              Height = 16
              Caption = 'Kullan'#305'c'#305' (user@server :'
            end
            object Label8: TLabel
              Left = 9
              Top = 83
              Width = 37
              Height = 16
              Caption = 'Parola :'
            end
            object Label9: TLabel
              Left = 9
              Top = 113
              Width = 93
              Height = 16
              Caption = 'IMAP Sunucu Port :'
            end
            object Label10: TLabel
              Left = 8
              Top = 144
              Width = 102
              Height = 16
              Caption = 'SSL/TLS (OpenSSL) : '
            end
            object Label11: TLabel
              Left = 9
              Top = 174
              Width = 61
              Height = 16
              Caption = 'K'#246'k Klas'#246'r : '
            end
            object Label12: TLabel
              Left = 9
              Top = 204
              Width = 100
              Height = 16
              Caption = 'Al'#305'c'#305' ePosta adresi : '
            end
            object editIMAPServer: TcxDBTextEdit
              Left = 158
              Top = 20
              DataBinding.DataField = 'IMAP_Server'
              DataBinding.DataSource = dtsSocial
              TabOrder = 0
              Width = 252
            end
            object editIMAPuser: TcxDBTextEdit
              Left = 158
              Top = 50
              DataBinding.DataField = 'IMAP_User'
              DataBinding.DataSource = dtsSocial
              TabOrder = 1
              Width = 252
            end
            object editIMAPpassword: TcxDBTextEdit
              Left = 158
              Top = 80
              DataBinding.DataField = 'IMAP_Passwd'
              DataBinding.DataSource = dtsSocial
              Properties.EchoMode = eemPassword
              Properties.PasswordChar = '*'
              Properties.ShowPasswordRevealButton = True
              TabOrder = 2
              Width = 252
            end
            object comboTLS: TcxDBImageComboBox
              Left = 158
              Top = 140
              DataBinding.DataField = 'IMAP_TLS'
              DataBinding.DataSource = dtsSocial
              Properties.Items = <
                item
                  Description = '(Yok)'
                  ImageIndex = 0
                  Value = 0
                end
                item
                  Description = 'ImplicitTLS'
                  Value = 1
                end
                item
                  Description = 'RequireTLS'
                  Value = 2
                end
                item
                  Description = 'ExplicitTLS'
                  Value = 3
                end>
              TabOrder = 4
              Width = 121
            end
            object editIMAPfolder: TcxDBTextEdit
              Left = 158
              Top = 170
              DataBinding.DataField = 'IMAP_RootFolder'
              DataBinding.DataSource = dtsSocial
              TabOrder = 5
              Width = 252
            end
            object editIMAPport: TcxDBSpinEdit
              Left = 158
              Top = 110
              DataBinding.DataField = 'IMAP_Port'
              DataBinding.DataSource = dtsSocial
              Properties.SpinButtons.Visible = False
              TabOrder = 3
              Width = 121
            end
            object editToMail: TcxDBTextEdit
              Left = 158
              Top = 200
              DataBinding.DataField = 'IMAP_ToMail'
              DataBinding.DataSource = dtsSocial
              TabOrder = 6
              Width = 252
            end
          end
        end
      end
    end
  end
  object tabSocial: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT TOP 1 * FROM SOCIAL_MEDIA')
    Left = 543
    Top = 267
  end
  object dtsSocial: TDataSource
    DataSet = tabSocial
    Left = 543
    Top = 318
  end
end
