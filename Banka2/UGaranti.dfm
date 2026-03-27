object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 528
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object memoSonuc: TMemo
    Left = 0
    Top = 41
    Width = 628
    Height = 487
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 88
    ExplicitTop = 8
    ExplicitWidth = 532
    ExplicitHeight = 512
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 628
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 1
    ExplicitLeft = 16
    ExplicitTop = 96
    ExplicitWidth = 185
    object btnBaglan: TcxButton
      Left = 16
      Top = 7
      Width = 75
      Height = 25
      Caption = 'btnBaglan'
      TabOrder = 0
      OnClick = btnBaglanClick
    end
  end
end
