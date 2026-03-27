object AnaForm: TAnaForm
  Left = 0
  Top = 0
  Caption = 'AnaForm'
  ClientHeight = 270
  ClientWidth = 298
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cxButton1: TcxButton
    Left = 8
    Top = 8
    Width = 281
    Height = 89
    Caption = 'Hareket Aktar'
    TabOrder = 0
    OnClick = cxButton1Click
  end
  object cxButton2: TcxButton
    Left = 8
    Top = 103
    Width = 281
    Height = 89
    Caption = #220'r'#252'n Aktar'
    TabOrder = 1
    OnClick = cxButton2Click
  end
  object cxButton3: TcxButton
    Left = 8
    Top = 198
    Width = 282
    Height = 59
    Caption = 'Kampanya'
    TabOrder = 2
    OnClick = cxButton3Click
  end
  object ADOConnection1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=FETAGEN;Persist Security Info=True;' +
      'User ID=SA;Initial Catalog=GENTEGRE;Data Source=AVT-NOTEBOOK\SQL' +
      'EXPRESS;Use Procedure for Prepare=1;Auto Translate=True;Packet S' +
      'ize=4096;Workstation ID=AVT-NOTEBOOK'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 8
    Top = 112
  end
end
