object BankaCekleriAramaFrame: TBankaCekleriAramaFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object Label1: TLabel
    Left = 0
    Top = 3
    Width = 43
    Height = 16
    Caption = 'Kod/Ad'#305':'
  end
  object btnSil: TcxButton
    Left = 116
    Top = 21
    Width = 21
    Height = 19
    Caption = #209
    TabOrder = 0
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Wingdings 2'
    Font.Style = []
    ParentFont = False
    OnClick = btnSilClick
  end
  object AraKod: TcxTextEdit
    Left = 0
    Top = 20
    TabOrder = 1
    Width = 115
  end
end
