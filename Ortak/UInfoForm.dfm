object infoForm: TinfoForm
  Left = 369
  Top = 308
  AlphaBlend = True
  AlphaBlendValue = 0
  BorderStyle = bsNone
  Caption = 'infoForm'
  ClientHeight = 93
  ClientWidth = 277
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 277
    Height = 93
    Align = alClient
    BevelOuter = bvLowered
    BevelWidth = 2
    Color = 16744576
    TabOrder = 0
    object msgLabel: TcxLabel
      Left = 2
      Top = 2
      Width = 273
      Height = 89
      Align = alClient
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Properties.WordWrap = True
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -13
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsBold]
    end
  end
  object AnimationTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = AnimationTimerTimer
    Left = 8
    Top = 8
  end
  object HideTimer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = HideTimerTimer
    Left = 40
    Top = 8
  end
end
