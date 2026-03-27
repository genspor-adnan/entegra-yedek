object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Sesle Hasta Kayd'#305
  ClientHeight = 360
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnBasla: TButton
    Left = 16
    Top = 16
    Width = 120
    Height = 33
    Caption = 'Ba'#351'la'
    TabOrder = 0
    OnClick = btnBaslaClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 64
    Width = 528
    Height = 280
    Lines.Strings = (
      'Haz'#305'r. "Ba'#351'la"ya t'#305'klay'#305'n.')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end