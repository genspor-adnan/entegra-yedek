object KrediEkleDlg: TKrediEkleDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Kredi Ekleme Ekran'#305
  ClientHeight = 222
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object KapatTus: TSpeedButton
    Left = 317
    Top = 173
    Width = 60
    Height = 22
    Caption = 'Kapat'
    Flat = True
    Glyph.Data = {
      66010000424D6601000000000000760000002800000013000000140000000100
      040000000000F000000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      7777777600007777777777777777777000007777777777777777777000007777
      777777777777777000007777777777777770F77C0000777770F7777777777776
      00007777000F7777770F777000007777000F777770F77770000077777000F777
      00F7777E0000777777000F700F7777700000777777700000F777777F00007777
      7777000F777777760000777777700000F77777700000777777000F70F7777770
      000077770000F77700F7777000007770000F7777700F7770000077700F777777
      7700F77400007777777777777777777600007777777777777777777000007777
      77777777777777700000}
    OnClick = KapatTusClick
  end
  object SpeedButton1: TSpeedButton
    Left = 237
    Top = 173
    Width = 60
    Height = 22
    Caption = 'Kaydet'
    Flat = True
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      33333333FF33333333FF333993333333300033377F3333333777333993333333
      300033F77FFF3333377739999993333333333777777F3333333F399999933333
      33003777777333333377333993333333330033377F3333333377333993333333
      3333333773333333333F333333333333330033333333F33333773333333C3333
      330033333337FF3333773333333CC333333333FFFFF77FFF3FF33CCCCCCCCCC3
      993337777777777F77F33CCCCCCCCCC3993337777777777377333333333CC333
      333333333337733333FF3333333C333330003333333733333777333333333333
      3000333333333333377733333333333333333333333333333333}
    NumGlyphs = 2
    OnClick = SpeedButton1Click
  end
  object Label8: TcxLabel
    Left = 5
    Top = 28
    Caption = 'Tarih'
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
    Left = 5
    Top = 60
    Caption = 'Referans No'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label10: TcxLabel
    Left = 5
    Top = 131
    Caption = 'A'#231#305'klama'
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
    Left = 5
    Top = 95
    Caption = 'Tutar'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object EditRef: TcxTextEdit
    Tag = 1
    Left = 103
    Top = 60
    TabOrder = 1
    OnExit = EditRefExit
    Width = 158
  end
  object EditAcik: TcxTextEdit
    Left = 103
    Top = 131
    TabOrder = 4
    Width = 280
  end
  object EditTutar: TcxCurrencyEdit
    Tag = 2
    Left = 103
    Top = 95
    TabOrder = 2
    Width = 157
  end
  object DateTimePickerOdemeBasl: TcxDateEdit
    Left = 103
    Top = 28
    Properties.DateButtons = [btnClear, btnNow, btnToday]
    Properties.Kind = ckDateTime
    TabOrder = 0
    Width = 158
  end
end
