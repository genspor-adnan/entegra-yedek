object ConfirmDialogForm: TConfirmDialogForm
  Left = 302
  Top = 261
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Onay'
  ClientHeight = 158
  ClientWidth = 496
  Color = clCream
  DefaultMonitor = dmPrimary
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    496
    158)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 132
    Width = 477
    Height = 7
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object Label3: TLabel
    Left = 8
    Top = 138
    Width = 76
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Genot'#305'p 2008'
    Enabled = False
  end
  object Image1: TImage
    Left = 8
    Top = 24
    Width = 65
    Height = 65
    Center = True
    Stretch = True
    Transparent = True
  end
  object messageMemo: TMemo
    Left = 99
    Top = 24
    Width = 393
    Height = 65
    BorderStyle = bsNone
    Color = clCream
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 0
  end
  object EnableTimer: TTimer
    Enabled = False
    Interval = 2500
    OnTimer = EnableTimerTimer
    Left = 8
    Top = 96
  end
end
