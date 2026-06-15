object Tablo: TTablo
  Left = 0
  Top = 0
  Caption = 'Tablo'
  ClientHeight = 231
  ClientWidth = 810
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object cxTextEdit1: TcxTextEdit
    Left = 24
    Top = 16
    TabOrder = 0
    Text = '4650005258'
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
    Left = 222
    Top = 91
    TabOrder = 5
    Text = 'https://efatura.izibiz.com.tr:2443/EFaturaOIB'
    Width = 313
  end
  object aliasfatura: TcxMemo
    Left = 24
    Top = 134
    Lines.Strings = (
      'aliasfatura')
    TabOrder = 6
    Height = 89
    Width = 209
  end
  object aliasirsaliye: TcxMemo
    Left = 256
    Top = 134
    Lines.Strings = (
      'aliasirsaliye')
    TabOrder = 7
    Height = 89
    Width = 225
  end
  object bilgiler: TcxMemo
    Left = 504
    Top = 134
    Lines.Strings = (
      'aliasirsaliye')
    TabOrder = 8
    Height = 89
    Width = 225
  end
end
