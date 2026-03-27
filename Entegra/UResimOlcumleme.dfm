object ResimOlcumlemeDlg: TResimOlcumlemeDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Resim '#214'l'#231#252'mleme Ekran'#305
  ClientHeight = 523
  ClientWidth = 757
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 757
    Height = 74
    Align = alTop
    TabOrder = 0
    object cxTrackBar1: TcxTrackBar
      Left = 33
      Top = 37
      Position = 100
      Properties.Frequency = 10
      Properties.Max = 100
      Properties.Min = 10
      Properties.ThumbStep = cxtsJump
      Properties.TickType = tbttNumbers
      Properties.OnChange = cxTrackBar1PropertiesChange
      TabOrder = 5
      Height = 27
      Width = 191
    end
    object cxLabel1: TcxLabel
      Left = 39
      Top = 17
      Caption = 'B'#252'y'#252'kl'#252'k %'
    end
    object cxTrackBar2: TcxTrackBar
      Left = 238
      Top = 37
      Position = 100
      Properties.Frequency = 10
      Properties.Max = 100
      Properties.Min = 10
      Properties.ThumbStep = cxtsJump
      Properties.TickType = tbttNumbers
      Properties.OnChange = cxTrackBar1PropertiesChange
      TabOrder = 6
      Visible = False
      Height = 27
      Width = 191
    end
    object cxLabel2: TcxLabel
      Left = 245
      Top = 18
      Caption = 'Kalite'
      Visible = False
    end
    object cxLabel3: TcxLabel
      Left = 445
      Top = 15
      Caption = 'Kaplad'#305#287#305
    end
    object LabelAlan: TcxLabel
      Left = 454
      Top = 36
      Caption = 'Alan'
    end
    object TamamTus: TcxButton
      Left = 666
      Top = 28
      Width = 75
      Height = 25
      Caption = 'Tamam'
      ModalResult = 1
      TabOrder = 3
      OnClick = TamamTusClick
    end
  end
  object Rsm: TcxImage
    AlignWithMargins = True
    Left = 3
    Top = 77
    Align = alClient
    AutoSize = True
    Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
    Properties.GraphicClassName = 'TJPEGImage'
    Properties.Proportional = False
    Properties.ReadOnly = True
    Style.BorderColor = clBtnFace
    Style.Color = clBtnFace
    Style.Edges = []
    StyleDisabled.BorderStyle = ebsNone
    StyleFocused.BorderStyle = ebsNone
    TabOrder = 1
    Height = 443
    Width = 751
  end
end
