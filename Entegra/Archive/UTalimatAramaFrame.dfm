object TalimatAramaFrame: TTalimatAramaFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object Label1: TcxLabel
    Left = 0
    Top = 1
    Caption = 'Kod/'#220'nvan:'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
  end
  object btnSil: TcxButton
    Left = 131
    Top = 20
    Width = 21
    Height = 19
    Caption = #209
    TabOrder = 0
    Visible = False
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
    Width = 125
  end
  object EditCARIID: TcxLabel
    Left = 0
    Top = 206
  end
  object Panel1: TPanel
    Left = 0
    Top = 80
    Width = 125
    Height = 113
    TabOrder = 3
    object Label2: TcxLabel
      Left = 2
      Top = 9
      Caption = 'Ba'#351'lama'
      ParentFont = False
    end
    object Label3: TcxLabel
      Left = 2
      Top = 60
      Caption = 'Biti'#351
      ParentFont = False
    end
    object Calendar2: TcxDateEdit
      Left = 2
      Top = 84
      TabOrder = 0
      Width = 117
    end
    object Calendar1: TcxDateEdit
      Left = 2
      Top = 33
      TabOrder = 1
      Width = 117
    end
  end
  object CheckTarihAralik: TcxCheckBox
    Left = 0
    Top = 54
    Caption = 'Tarih Aral'#305#287#305
    State = cbsChecked
    TabOrder = 4
    Width = 121
  end
end
