object AnaForm: TAnaForm
  Left = 200
  Top = 62
  Caption = 'PDKS Giri'#351'-'#199#305'k'#305#351' Kontrol (ver.20.10.11.06)'
  ClientHeight = 601
  ClientWidth = 1038
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnMouseMove = FormMouseMove
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object ComLed2: TComLed
    Left = 88
    Top = 0
    Width = 25
    Height = 25
    LedSignal = lsConn
    Kind = lkRedLight
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1038
    Height = 25
    Align = alTop
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object ComLed1: TComLed
      Left = 88
      Top = 1
      Width = 25
      Height = 25
      LedSignal = lsConn
      Kind = lkRedLight
      Visible = False
    end
    object Label1: TLabel
      Left = 128
      Top = 6
      Width = 113
      Height = 13
      Caption = 'Server Tarihi-Saati :'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LBTarSa: TLabel
      Left = 248
      Top = 6
      Width = 89
      Height = 13
      Caption = 'Server Tarihi-Saati'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LBHata: TLabel
      Left = 735
      Top = 6
      Width = 3
      Height = 13
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BTNKamera: TSpeedButton
      Left = 863
      Top = 1
      Width = 81
      Height = 23
      Caption = 'Kamera'
      Flat = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000330B0000330B00000001000000010000A5520000DE73
        0000D67B0000E77B00009C520800B55A0800CE7308009C5A10009C631000C66B
        1000634221006B422100292929009C63290031313100524231005A4A3100634A
        310039393900524A390039424200424242009473420039424A0042424A00424A
        4A004A4A4A006B5A4A00525252008C73520052525A0063636300736B63008473
        6300D69C630063636B006B6B6B006B6B73007373730073737B007B7B7B00847B
        7B008484840084848C008C8C8C008C949400949494009C9C9C009C9CA500A5A5
        A500ADADAD00B5B5B500B5BDBD00BDBDBD00C6C6C600CECECE00D6D6D600DEDE
        DE00E7E7E700FF00FF002142FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF003B3B3B3B3B3B
        0C121A1A1A1A1A123B3B3B3B3B3B0E1A1A1A1F1F3333311A1A3B3B3B121A1A2A
        281F2828313737372F153B1F1A2F2E2E2C2F3128313737372E123B2C3131312F
        2E313128312D2B302A123B2C333232313132312E2721161B1E153B2C33333532
        32283226200603020F153B2C36353328322832251D09050108183B2C36283528
        3233322421220D0007193B2C372835353535321F31130A040B193B2C37373737
        363533262829111115153B333C3C3737363636311A1F27231A3B3B333C3C3A39
        39363636261C1A1C153B1A2C3A35333233352E3733312E1A3B3B1A331A1A3539
        3A3835331A1A1A3B3B3B3B1A3B3B1A1A1A1A1A1A3B3B3B3B3B3B}
      ParentFont = False
      Visible = False
      OnClick = BTNKameraClick
    end
    object BTNResim: TSpeedButton
      Left = 944
      Top = 1
      Width = 81
      Height = 23
      Caption = 'Resim'
      Flat = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000C30E0000C30E00000001000000010000005A00000073
        0800008C0800088410009C5A2900B5732900A5633900BD7B4A00E7944A005252
        52005A5A5A00AD7B5A0063636300636B6B0094736B00B5946B005A6B73006B73
        730073737300DE9C7300E7A5730000007B007B7B7B00293184009C8484006B6B
        8C006B848C008C8C8C00AD8C8C00394A9400949494004A6B9C00949C9C000008
        A500BDADA500739CAD00E7CEB5003139BD007B94C6008CB5C600ADB5CE00F7E7
        D600CECEDE00D6DEDE00DEDEDE000010E700ADCEE700E7E7E700CEDEEF00EFEF
        EF00F7F7F700FFF7F700FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00343434343434
        3434343434343434343434090909090909090909090909090934340935353535
        35353535353535350934340A3204060505050506060404320A34340C32070507
        07070705060413320C34340D312914080E100B07051331310D34341131353322
        1A1F190F24333531113400122F352B191F2626273535352F123401002F322826
        262726262F35352F1634010100352A23202E28171935352F1834030202352F2E
        28261D151D35352C1B3402022C352825252121212635352C1B34021B2C353025
        212121253135352C1B34341B2C353528252D25283535352C1C34341E2C2C2C2C
        2C2C2C2C2C2C2C2C1E34341E1E1E1E1E1E1E1E1E1E1E1E1E1E34}
      ParentFont = False
      OnClick = BTNResimClick
    end
    object SpeedButton1: TSpeedButton
      Left = 360
      Top = 1
      Width = 81
      Height = 22
      Caption = 'Yenile'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000004282
        A5FF1879ADFF216DA5FF00000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000000000000000000000319E
        C6FF00D3F7FF08E3FFFF395D7BFF000000000000000000000000000000000000
        000000000000000000000000000000000000000000000000000000000000529A
        BDFF00E3F7FF00CBF7FF00BAEFFF0886C6FF737984FF00000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000319EC6FF00E3F7FF00CBF7FF10E7FFFF215994FF737584FF000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000319EC6FF00E3FFFF00BAEFFF08E3FFFF0892DEFF295194FF6B71
        84FF000000000000000000000000000000000000000000000000000000000000
        00000000000000000000319EC6FF00E3FFFF00BAEFFF18EFFFFF18D7FFFF088A
        E7FF007DE7FF214994FF00000000000000000000000000000000000000000000
        0000000000000000000000000000319ACEFF00E7FFFF00BAEFFF29F7FFFF4AF7
        FFFF7BF7FFFF4AC7FFFF0855C6FF7B7984FF0000000000000000000000000000
        000000000000000000000000000000000000319ACEFF00E3FFFF00BAEFFF29F7
        FFFF5AFFFFFF8CFFFFFF73DFFFFF0859C6FF0000000000000000000000000000
        0000000000000000000000000000000000005A82ADFF00D7FFFF00EFFFFF00FB
        FFFF29F7FFFF5AFFFFFF94FFFFFF4AC7FFFF29458CFF00000000000000000000
        00000000000000000000000000000000000018AADEFF00CBFFFF00D7FFFF00EF
        FFFF00FBFFFF29D7FFFF31D7FFFF84FBFFFF088AF7FF00000000000000000000
        0000000000000000000000000000000000000000000000CBF7FF00CBFFFF00D7
        FFFF10E7FFFF636994FF4A75BDFF21DFFFFF316DC6FF00000000000000000000
        000000000000000000000000000000000000000000005A92CEFF00CBFFFF00CB
        FFFF00D7FFFF1865ADFF0882CEFF2975C6FF0000000000000000000000000000
        00000000000000000000000000000000000000000000000000007B9ACEFF08AE
        E7FF00D7FFFF00E3FFFF317DC6FF000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000528ED6FF3982C6FF00000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000}
      ParentFont = False
      OnClick = SpeedButton1Click
    end
    object btnVerileriAl: TSpeedButton
      Left = 447
      Top = 1
      Width = 90
      Height = 22
      Caption = 'Verileri Al'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000F30E0000F30E0000000100000001000000520000005A
        000000630000006B000000630800006B0800086B080000730800007B08000084
        0800009408000094100008941800109C180010942100109C210010A521001894
        3100189C310018AD310018B531004242420021AD420029AD420021B542004A42
        4A0052424A004A4A4A004A524A0029C64A00525252005A63520029C652005A5A
        5A005A635A0063635A006B635A0031C65A00525263005A5263005A5A6300635A
        63005A636300636363006B6363006B6B6300635A6B0063636B006B6B6B006B73
        6B0039D66B00636B7300736B73006B737300737373007B73730084737300737B
        730042DE730073737B007B737B0084737B007B7B7B008C847B0042E77B008484
        84008C848C00848C8C008C8C8C008C948C00949494009CA594009C9C9C00A5A5
        A500ADADAD00ADADB500B5B5B500BDBDBD00C6C6C600CECECE00D6D6D600E7DE
        D600DEDEDE00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00535353535353
        5353535353535353535353535353535353535353535353535353535353414836
        2B364A4C4D49414153535353531B52412B3E494D504E4A485353535353155041
        2B36494C504E4A4853535353531B52412B3E494C504E490153535353531B4936
        2136494C4D49011701535353531550412B36494C5001123A1601535353155042
        2F37494C010F161D130F5353531552422B3E494C0101011301015353531A4936
        2B36494C4F4C010C01535353531A51422C36494A4F4E010B01535353531A5142
        2331484A4F010B0753535353531A49362E3100010808040153535353531C4B44
        474949494A49443E5353535353533F3C343B3636363E41535353}
      ParentFont = False
      OnClick = btnVerileriAlClick
    end
    object SbAttendVeriAl: TSpeedButton
      Left = 631
      Top = 1
      Width = 90
      Height = 22
      Caption = 'Verileri Al'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000F30E0000F30E0000000100000001000000520000005A
        000000630000006B000000630800006B0800086B080000730800007B08000084
        0800009408000094100008941800109C180010942100109C210010A521001894
        3100189C310018AD310018B531004242420021AD420029AD420021B542004A42
        4A0052424A004A4A4A004A524A0029C64A00525252005A63520029C652005A5A
        5A005A635A0063635A006B635A0031C65A00525263005A5263005A5A6300635A
        63005A636300636363006B6363006B6B6300635A6B0063636B006B6B6B006B73
        6B0039D66B00636B7300736B73006B737300737373007B73730084737300737B
        730042DE730073737B007B737B0084737B007B7B7B008C847B0042E77B008484
        84008C848C00848C8C008C8C8C008C948C00949494009CA594009C9C9C00A5A5
        A500ADADAD00ADADB500B5B5B500BDBDBD00C6C6C600CECECE00D6D6D600E7DE
        D600DEDEDE00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00535353535353
        5353535353535353535353535353535353535353535353535353535353414836
        2B364A4C4D49414153535353531B52412B3E494D504E4A485353535353155041
        2B36494C504E4A4853535353531B52412B3E494C504E490153535353531B4936
        2136494C4D49011701535353531550412B36494C5001123A1601535353155042
        2F37494C010F161D130F5353531552422B3E494C0101011301015353531A4936
        2B36494C4F4C010C01535353531A51422C36494A4F4E010B01535353531A5142
        2331484A4F010B0753535353531A49362E3100010808040153535353531C4B44
        474949494A49443E5353535353533F3C343B3636363E41535353}
      ParentFont = False
      Visible = False
      OnClick = SbAttendVeriAlClick
    end
    object BTNAc: TButton
      Left = 1
      Top = 1
      Width = 89
      Height = 25
      Caption = 'BA'#350'LAT'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = BTNAcClick
    end
    object Edit1: TEdit
      Left = 840
      Top = -1
      Width = 17
      Height = 21
      TabOrder = 0
      Visible = False
      OnKeyPress = Edit1KeyPress
    end
    object dtpVerileriAl: TDateTimePicker
      Left = 543
      Top = 1
      Width = 85
      Height = 21
      Date = 40581.481322187500000000
      Time = 40581.481322187500000000
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 576
    Width = 1038
    Height = 25
    Align = alBottom
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object DBText1: TDBText
      Left = 1
      Top = 1
      Width = 48
      Height = 23
      Align = alLeft
      AutoSize = True
      DataField = 'SONUC'
      DataSource = Tablo.DtsKARTOKU
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitHeight = 13
    end
    object DBText2: TDBText
      Left = 49
      Top = 1
      Width = 48
      Height = 23
      Align = alLeft
      AutoSize = True
      DataField = 'SONUC'
      DataSource = Tablo.DtsKARTOKUYEMEK
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitHeight = 13
    end
    object lblMesaj: TLabel
      Left = 1014
      Top = 8
      Width = 3
      Height = 13
      Alignment = taRightJustify
    end
  end
  object ResimPanel: TPanel
    Left = 0
    Top = 365
    Width = 1038
    Height = 211
    Align = alBottom
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 281
      Top = 1
      Width = 280
      Height = 209
      Align = alLeft
      Caption = #199'IKI'#350
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object IMCIKIS: TImage
        Left = 2
        Top = 15
        Width = 276
        Height = 192
        Align = alClient
        Stretch = True
        ExplicitLeft = 4
        ExplicitTop = 14
      end
    end
    object GroupBox2: TGroupBox
      Left = 1
      Top = 1
      Width = 280
      Height = 209
      Align = alLeft
      Caption = 'G'#304'R'#304#350
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      object IMGIRIS: TImage
        Left = 2
        Top = 15
        Width = 276
        Height = 192
        Align = alClient
        Stretch = True
      end
    end
    object Memo1: TMemo
      Left = 561
      Top = 1
      Width = 476
      Height = 209
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 2
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 121
    Width = 1038
    Height = 236
    Align = alClient
    TabOrder = 3
    object cxGrid1: TcxGrid
      Left = 1
      Top = 1
      Width = 1036
      Height = 234
      Align = alClient
      TabOrder = 0
      object cxGrid1DBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        OnCustomDrawCell = cxGrid1DBTableView1CustomDrawCell
        DataController.DataSource = Tablo.DtsStatus
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        object cxGrid1DBTableView1FIRMA: TcxGridDBColumn
          Caption = 'Ad Soyad'
          DataBinding.FieldName = 'FIRMA'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 116
        end
        object cxGrid1DBTableView1GIRIS: TcxGridDBColumn
          Caption = 'G'#304'R'#304#350
          DataBinding.FieldName = 'GIRIS'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 131
        end
        object cxGrid1DBTableView1CIKIS: TcxGridDBColumn
          Caption = #199'IKI'#350
          DataBinding.FieldName = 'CIKIS'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 123
        end
        object cxGrid1DBTableView1VARGIRIS: TcxGridDBColumn
          Caption = 'VAR.G'#304'R'#304#350
          DataBinding.FieldName = 'VARGIRIS'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 92
        end
        object cxGrid1DBTableView1VARCIKIS: TcxGridDBColumn
          Caption = 'VAR.'#199'IKI'#350
          DataBinding.FieldName = 'VARCIKIS'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 80
        end
        object tvGirCik: TcxGridDBColumn
          Caption = 'G'#304'R'#304#350'/'#199'IKI'#350
          DataBinding.FieldName = 'GIRCIK'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 92
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = cxGrid1DBTableView1
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 25
    Width = 1038
    Height = 88
    Align = alTop
    TabOrder = 4
    Visible = False
    object cxGrid2: TcxGrid
      Left = 1
      Top = 1
      Width = 1036
      Height = 170
      TabOrder = 0
      Visible = False
      object cxGridDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = Tablo.DtsYemekhane
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        object TVGirCikSICILNO: TcxGridDBColumn
          Caption = 'DOSYA NO'
          DataBinding.FieldName = 'PERKOD'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 91
        end
        object TVGirCikADI: TcxGridDBColumn
          DataBinding.FieldName = 'ADI'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 155
        end
        object TVGirCikSOYADI: TcxGridDBColumn
          DataBinding.FieldName = 'SOYADI'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 155
        end
        object TVGirCikDEPARTMAN: TcxGridDBColumn
          DataBinding.FieldName = 'DEPARTMAN'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 102
        end
        object TVGirCikGIRIS: TcxGridDBColumn
          DataBinding.FieldName = 'SABAH'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 162
        end
        object TVGirCikCIKIS: TcxGridDBColumn
          Caption = #214#286'LE'
          DataBinding.FieldName = 'OGLEN'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 162
        end
        object TVGirCikVARDIYA: TcxGridDBColumn
          Caption = 'AK'#350'AM'
          DataBinding.FieldName = 'AKSAM'
          HeaderAlignmentHorz = taCenter
          Styles.Header = cxStyle1
          Width = 162
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = cxGridDBTableView1
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 113
    Width = 1038
    Height = 8
    HotZoneClassName = 'TcxXPTaskBarStyle'
    AlignSplitter = salTop
    Control = Panel3
  end
  object cxSplitter3: TcxSplitter
    Left = 0
    Top = 357
    Width = 1038
    Height = 8
    HotZoneClassName = 'TcxXPTaskBarStyle'
    AlignSplitter = salBottom
    Control = ResimPanel
  end
  object Panel5: TPanel
    Left = 981
    Top = 255
    Width = 36
    Height = 142
    Caption = 'Panel5'
    TabOrder = 7
    Visible = False
    object PERS_PDKS: TcxGrid
      Left = 0
      Top = 4
      Width = 386
      Height = 113
      TabOrder = 0
      object PERS_PDKSDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = dtsqry1
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        object PERS_PDKSDBTableView1ID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
        object PERS_PDKSDBTableView1ADI: TcxGridDBColumn
          DataBinding.FieldName = 'ADI'
          Width = 100
        end
        object PERS_PDKSDBTableView1SOYADI: TcxGridDBColumn
          DataBinding.FieldName = 'SOYADI'
          Width = 100
        end
        object PERS_PDKSDBTableView1PERKOD: TcxGridDBColumn
          DataBinding.FieldName = 'PERKOD'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1KARTNO: TcxGridDBColumn
          DataBinding.FieldName = 'KARTNO'
          MinWidth = 5
          Width = 100
        end
        object PERS_PDKSDBTableView1GIRIS: TcxGridDBColumn
          DataBinding.FieldName = 'GIRIS'
          Width = 100
        end
        object PERS_PDKSDBTableView1CIKIS: TcxGridDBColumn
          DataBinding.FieldName = 'CIKIS'
          Width = 100
        end
        object PERS_PDKSDBTableView1VARDIYA: TcxGridDBColumn
          DataBinding.FieldName = 'VARDIYA'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1VARGIRIS: TcxGridDBColumn
          DataBinding.FieldName = 'VARGIRIS'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1VARCIKIS: TcxGridDBColumn
          DataBinding.FieldName = 'VARCIKIS'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1VARCALSURE: TcxGridDBColumn
          DataBinding.FieldName = 'VARCALSURE'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1UCRETLISAAT: TcxGridDBColumn
          DataBinding.FieldName = 'UCRETLISAAT'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1UCRETSIZSAAT: TcxGridDBColumn
          DataBinding.FieldName = 'UCRETSIZSAAT'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1GIRFARK: TcxGridDBColumn
          DataBinding.FieldName = 'GIRFARK'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1CIKFARK: TcxGridDBColumn
          DataBinding.FieldName = 'CIKFARK'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1CALSURE: TcxGridDBColumn
          DataBinding.FieldName = 'CALSURE'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1CALFARK: TcxGridDBColumn
          DataBinding.FieldName = 'CALFARK'
          MinWidth = 6
          Width = 100
        end
        object PERS_PDKSDBTableView1IZINVEREN: TcxGridDBColumn
          DataBinding.FieldName = 'IZINVEREN'
          Width = 100
        end
        object PERS_PDKSDBTableView1ACIKLAMA: TcxGridDBColumn
          DataBinding.FieldName = 'ACIKLAMA'
          Width = 500
        end
      end
      object PERS_PDKSLevel1: TcxGridLevel
        GridView = PERS_PDKSDBTableView1
      end
    end
  end
  object CZKEMYemekhane: TCZKEM
    Left = 128
    Top = 120
    Width = 57
    Height = 51
    TabOrder = 8
    Visible = False
    OnConnected = CZKEMYemekhaneConnected
    ControlData = {00090000E405000045050000}
  end
  object CZKEMPDKS: TCZKEM
    Left = 191
    Top = 120
    Width = 57
    Height = 51
    TabOrder = 9
    Visible = False
    OnVerify = CZKEMPDKSVerify
    OnHIDNum = CZKEMPDKSHIDNum
    OnAttTransactionEx = CZKEMPDKSAttTransactionEx
    ControlData = {00090000E405000045050000}
  end
  object FKAttend: TFKAttend
    Left = 391
    Top = 139
    Width = 32
    Height = 32
    TabOrder = 10
    Visible = False
    ControlData = {000001004F0300004F03000000000000}
  end
  object FKAttendy: TFKAttend
    Left = 429
    Top = 139
    Width = 32
    Height = 32
    TabOrder = 11
    Visible = False
    ControlData = {000001004F0300004F03000000000000}
  end
  object PopupMenu1: TPopupMenu
    OwnerDraw = True
    Left = 256
    Top = 96
    object ProgramA1: TMenuItem
      Caption = 'Program'#305' A'#231
      OnClick = ProgramA1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Seaenekler1: TMenuItem
      Caption = 'Se'#231'enekler'
      object SeriPortAyarlar2: TMenuItem
        Caption = 'Seri Port Ayarlar'#305
        OnClick = SeriPortAyarlar1Click
      end
      object Opsiyonlar1: TMenuItem
        Caption = 'Opsiyonlar'
        ShortCut = 16464
        OnClick = ProgramAyarlar1Click
      end
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Kapat1: TMenuItem
      Caption = 'Kapat'
      OnClick = Kapat1Click
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 16
    Top = 88
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 552
    Top = 88
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
  end
  object MainMenu1: TMainMenu
    OwnerDraw = True
    Left = 192
    Top = 96
    object MNSecenek: TMenuItem
      Caption = 'Se'#231'enekler'
      object SeriPortAyarlar1: TMenuItem
        Caption = 'Seri Port Ayarlar'#305
        ShortCut = 16467
        OnClick = SeriPortAyarlar1Click
      end
      object ProgramAyarlar1: TMenuItem
        Caption = 'Opsiyonlar'
        ShortCut = 16464
        OnClick = ProgramAyarlar1Click
      end
      object MNDonemAktar: TMenuItem
        Caption = 'MNDonemAktar'
        Visible = False
      end
      object N3: TMenuItem
        Caption = '-'
        Visible = False
      end
    end
    object izinler: TMenuItem
      Caption = #304'zin'
      Visible = False
      object GenelDokumler: TMenuItem
        Caption = #304'zin'
        OnClick = GenelDokumlerClick
      end
    end
    object Yardm1: TMenuItem
      Caption = 'Yard'#305'm'
      object Hakknda1: TMenuItem
        Caption = 'Hakk'#305'nda'
        OnClick = Hakknda1Click
      end
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    PopupMenus = <>
    Left = 320
    Top = 104
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer2Timer
    Left = 16
    Top = 120
  end
  object Timer3: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer3Timer
    Left = 56
    Top = 89
  end
  object ComPort1: TComPort
    BaudRate = br115200
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrHandshake
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    Timeouts.ReadInterval = 50
    Timeouts.ReadTotalConstant = 100
    Timeouts.WriteTotalMultiplier = 0
    Timeouts.WriteTotalConstant = 100
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnRxChar = ComPort1RxChar
    Left = 384
    Top = 88
  end
  object Timer4: TTimer
    Interval = 3000
    OnTimer = Timer4Timer
    Left = 56
    Top = 137
  end
  object tmrSupremaTarama: TTimer
    Enabled = False
    OnTimer = tmrSupremaTaramaTimer
    Left = 40
    Top = 185
  end
  object tmrOkuyucu2: TTimer
    Enabled = False
    OnTimer = tmrOkuyucu2Timer
    Left = 720
    Top = 88
  end
  object SaveDialog1: TSaveDialog
    Left = 496
    Top = 88
  end
  object OpenDialog1: TOpenDialog
    Left = 632
    Top = 88
  end
  object FkAttendSorgula: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = FkAttendSorgulaTimer
    Left = 552
    Top = 137
  end
  object MemoTemizle: TTimer
    Interval = 300000
    OnTimer = MemoTemizleTimer
    Left = 624
    Top = 129
  end
  object tmrOkuyucuAktar: TTimer
    Interval = 2000
    OnTimer = tmrOkuyucuAktarTimer
    Left = 720
    Top = 152
  end
  object dtsqry1: TDataSource
    DataSet = qry1
    Left = 928
    Top = 120
  end
  object qry1: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'Select'
      'R.FIRMA,PK.*,'
      
        'UCRETLISAAT=isnull(dbo.fn_YIL_GUN_IZIN( GIRIS, R.KOD, '#39#220'CRETL'#304' S' +
        'AAT '#304'ZN'#304#39'),'#39'00:00'#39'),'
      
        'UCRETSIZSAAT=isnull(dbo.fn_YIL_GUN_IZIN( GIRIS, R.KOD, '#39#220'CRETS'#304'Z' +
        ' SAAT '#304'ZN'#304#39'),'#39'00:00'#39'),'
      'GIRFARK=isnull(dbo.fn_GIRFARK(VARGIRIS,GIRIS),'#39'00:00'#39'),'
      
        'CIKFARK=isnull(dbo.fn_CIKFARK(VARGIRIS,VARCALSURE,GIRIS,CIKIS),'#39 +
        '00:00'#39'),'
      'CALSURE=dbo.fn_SaatOlarak(DATEDIFF(mi,GIRIS,CIKIS)),'
      
        '--CALFARK=dbo.fn_CALFARK(VARCALSURE,dbo.fn_SaatOlarak(DATEDIFF(m' +
        'i,GIRIS,CIKIS))),'
      
        'CALFARK= CASE WHEN  charindex('#39'*'#39',dbo.fn_SaatOlarak(DATEDIFF(mi,' +
        'GIRIS,CIKIS)))=0 THEN dbo.fn_CALFARK(VARCALSURE,dbo.fn_SaatOlara' +
        'k(DATEDIFF(mi,GIRIS,CIKIS))) ELSE '#39'00:00'#39' END,'
      
        'IZINVEREN=(Select YETADI from PERS_IZIN where PERKOD=PK.PERKOD a' +
        'nd AITYIL=YEAR(GIRIS) and (GIRIS>=BASTAR) and (GIRIS<=BITTAR) ),'
      
        'ACIKLAMA=(Select NOTU from PERS_IZIN where PERKOD=PK.PERKOD and ' +
        'AITYIL=YEAR(GIRIS) and (GIRIS>=BASTAR) and (GIRIS<=BITTAR) )'
      'from PERS_PDKS PK inner join '
      ' REHBER R on PK.REHBERID = R.ID'
      ' where PK.GIRIS >=convert(varchar(10),GETDATE(),102)'
      'ORDER BY PK.GIRIS,PK.CIKIS,PK.VARDIYA,PK.VARGIRIS,PK.VARCIKIS')
    Left = 976
    Top = 120
    object qry1ID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object qry1PERKOD: TIntegerField
      FieldName = 'PERKOD'
    end
    object qry1KARTNO: TStringField
      FieldName = 'KARTNO'
    end
    object qry1GIRIS: TDateTimeField
      FieldName = 'GIRIS'
    end
    object qry1CIKIS: TDateTimeField
      FieldName = 'CIKIS'
    end
    object qry1VARDIYA: TStringField
      FieldName = 'VARDIYA'
    end
    object qry1VARGIRIS: TStringField
      FieldName = 'VARGIRIS'
      Size = 5
    end
    object qry1VARCIKIS: TStringField
      FieldName = 'VARCIKIS'
      Size = 5
    end
    object qry1VARCALSURE: TStringField
      FieldName = 'VARCALSURE'
      Size = 5
    end
    object qry1IGIRIS: TDateTimeField
      FieldName = 'IGIRIS'
    end
    object qry1ICIKIS: TDateTimeField
      FieldName = 'ICIKIS'
    end
    object qry1IVARDIYA: TStringField
      FieldName = 'IVARDIYA'
    end
    object qry1IVARGIRIS: TStringField
      FieldName = 'IVARGIRIS'
      Size = 5
    end
    object qry1IVARCIKIS: TStringField
      FieldName = 'IVARCIKIS'
      Size = 5
    end
    object qry1IVARCALSURE: TStringField
      FieldName = 'IVARCALSURE'
      Size = 5
    end
    object qry1GEC_MAZERET: TStringField
      FieldName = 'GEC_MAZERET'
      Size = 100
    end
    object qry1ERKEN_MAZERET: TStringField
      FieldName = 'ERKEN_MAZERET'
      Size = 100
    end
    object qry1UCRETLISAAT: TStringField
      FieldName = 'UCRETLISAAT'
      ReadOnly = True
      Size = 5
    end
    object qry1UCRETSIZSAAT: TStringField
      FieldName = 'UCRETSIZSAAT'
      ReadOnly = True
      Size = 5
    end
    object qry1GIRFARK: TStringField
      FieldName = 'GIRFARK'
      ReadOnly = True
      Size = 15
    end
    object qry1CIKFARK: TStringField
      FieldName = 'CIKFARK'
      ReadOnly = True
      Size = 15
    end
    object qry1CALSURE: TStringField
      FieldName = 'CALSURE'
      ReadOnly = True
      Size = 10
    end
    object qry1CALFARK: TStringField
      FieldName = 'CALFARK'
      ReadOnly = True
      Size = 15
    end
    object qry1IZINVEREN: TStringField
      FieldName = 'IZINVEREN'
      ReadOnly = True
      Size = 80
    end
    object qry1ACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      ReadOnly = True
      Size = 200
    end
    object qry1ADI: TStringField
      FieldName = 'ADI'
      Size = 50
    end
    object qry1SOYADI: TStringField
      FieldName = 'SOYADI'
      Size = 50
    end
  end
  object qry2: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'TARIH1'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = Null
      end
      item
        Name = 'TARIH2'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT  PS.ADI,PC.ID,PS.SOYADI,PK.KARTNO,PC.KARTNO,PC.TARIH,PC.K' +
        'AYITTARIH FROM PERS_CIHAZ_ALINAN PC'
      #9'left JOIN PERS_KART PK ON PK.KARTNO=PC.KARTNO'
      #9'left JOIN PER_SABIT PS ON PS.PERKOD=PK.PERKOD'
      
        'WHERE PC.TARIH BETWEEN CONVERT(DATETIME,:TARIH1,120) AND CONVERT' +
        '(DATETIME,:TARIH2,120) '
      'ORDER BY PC.ID')
    Left = 984
    Top = 80
  end
end
