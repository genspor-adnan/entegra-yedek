object frmImageView: TfrmImageView
  Left = 0
  Top = 0
  Caption = 'frmImageView'
  ClientHeight = 502
  ClientWidth = 802
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object ScrollBox1: TScrollBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 796
    Height = 462
    Align = alClient
    TabOrder = 0
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 100
      Height = 321
      ParentShowHint = False
      ShowHint = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 468
    Width = 802
    Height = 34
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 405
    ExplicitWidth = 830
    object buttonKapat: TButton
      AlignWithMargins = True
      Left = 723
      Top = 4
      Width = 75
      Height = 26
      Align = alRight
      Caption = 'Kapat'
      TabOrder = 0
      OnClick = buttonKapatClick
      ExplicitLeft = 744
      ExplicitTop = 8
      ExplicitHeight = 25
    end
  end
end
