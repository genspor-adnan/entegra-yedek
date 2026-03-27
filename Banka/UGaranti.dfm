object GarantiDlg: TGarantiDlg
  Left = 0
  Top = 0
  Caption = 'GarantiDlg'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Button1: TButton
    Left = 264
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Get Transactions'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 608
    Height = 186
    ScrollBars = ssBoth
    TabOrder = 1
  end
end
