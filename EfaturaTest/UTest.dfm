object Tablo: TTablo
  Left = 0
  Top = 0
  Caption = 'Tablo'
  ClientHeight = 231
  ClientWidth = 551
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cxTextEdit1: TcxTextEdit
    Left = 24
    Top = 16
    TabOrder = 0
    Text = '3850065757'
    Width = 121
  end
  object cxButton1: TcxButton
    Left = 24
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Kontrol'
    TabOrder = 1
    OnClick = cxButton1Click
  end
  object cxComboBox1: TcxComboBox
    Left = 184
    Top = 16
    Properties.Items.Strings = (
      #304'zibiz'
      'QNB '
      'Logo')
    TabOrder = 2
    Text = #304'zibiz'
    Width = 121
  end
  object Ent_Sifre1: TcxTextEdit
    Left = 184
    Top = 70
    TabOrder = 3
    Text = 'fetagen'
    Width = 121
  end
  object Ent_Kullanici1: TcxTextEdit
    Left = 184
    Top = 43
    TabOrder = 4
    Text = 'genyazilim'
    Width = 121
  end
  object Ent_Addr1: TcxTextEdit
    Left = 184
    Top = 142
    TabOrder = 5
    Text = 'https://efatura.izibiz.com.tr:2443/EFaturaOIB'
    Width = 313
  end
end
