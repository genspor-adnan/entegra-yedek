object Yukle1: TYukle1
  Left = 295
  Top = 214
  Width = 409
  Height = 278
  Caption = 'Yukle1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 16
    Top = 8
    Width = 105
    Height = 185
  end
  object Label2: TLabel
    Left = 136
    Top = 64
    Width = 249
    Height = 23
    Caption = 'Yüklenecek Yedek Dosya :'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SpeedButton1: TSpeedButton
    Left = 372
    Top = 95
    Width = 23
    Height = 22
    Glyph.Data = {
      7E010000424D7E01000000000000760000002800000016000000160000000100
      0400000000000801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0078FFFFFFFFFF
      FFFFFFFFFF00780777777777777777777F00780777777777777777777F007807
      77777700077777777F00780770000707077777777F0078077077770007777777
      7F00780770777777777777777F00780770777777777700077F00780770777770
      000707077F00780770777770777700077F00780770777777777777777F007807
      70777700077777777F00780770000707077777777F0078077077770007777777
      7F00780777777777777777777F00780700077777777777777F00780707077777
      777777777F00780700077777777777777F00780777777777777777777F007800
      00000000000000000F0078888888888888888888880077777777777777777777
      7700}
    OnClick = SpeedButton1Click
  end
  object Button1: TButton
    Left = 228
    Top = 193
    Width = 75
    Height = 25
    Caption = 'Sonraki'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 308
    Top = 193
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Ýptal'
    ModalResult = 2
    TabOrder = 1
  end
  object Ad: TEdit
    Left = 144
    Top = 96
    Width = 225
    Height = 21
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    Left = 176
    Top = 16
  end
end
