object Yukle2: TYukle2
  Left = 309
  Top = 221
  Width = 406
  Height = 264
  Caption = 'Yukle2'
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
  object Label1: TLabel
    Left = 152
    Top = 64
    Width = 132
    Height = 23
    Caption = 'Yükleme Adý :'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Son: TButton
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
    Left = 148
    Top = 193
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Önceki'
    ModalResult = 4
    TabOrder = 1
  end
  object Button1: TButton
    Left = 308
    Top = 192
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Ýptal'
    ModalResult = 2
    TabOrder = 2
  end
  object Ad: TEdit
    Left = 176
    Top = 96
    Width = 193
    Height = 21
    TabOrder = 3
  end
  object SaveDialog1: TSaveDialog
    Left = 160
    Top = 128
  end
end
