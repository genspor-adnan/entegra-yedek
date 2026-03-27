object BekletmeDlg: TBekletmeDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Yedek al'#305'n'#305'yor bekleyiniz...'
  ClientHeight = 89
  ClientWidth = 317
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object cxProgressBar1: TcxProgressBar
    Left = 0
    Top = 27
    TabOrder = 0
    Width = 305
  end
  object LabelUstTaraf: TcxLabel
    Left = 6
    Top = 5
    AutoSize = False
    Transparent = True
    Height = 18
    Width = 290
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 136
  end
end
