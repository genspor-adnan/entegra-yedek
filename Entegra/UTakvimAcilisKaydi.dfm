object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Form1'
  ClientHeight = 454
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object tlb1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 380
    Height = 22
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 20
    ButtonWidth = 46
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object KaydetTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 46
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
    end
    object SilTus: TToolButton
      Left = 92
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
    end
    object btn1: TToolButton
      Left = 138
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object BelgeTus: TToolButton
      Left = 146
      Top = 0
      Caption = 'Belge'
      ImageIndex = 28
    end
    object ToolButton1: TToolButton
      Left = 192
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object Iptal: TToolButton
      Left = 200
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
    end
  end
  object TabKasa: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 332
    Top = 35
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    Left = 334
    Top = 79
  end
end

