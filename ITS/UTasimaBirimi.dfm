object TasimaBirimiGirisDlg: TTasimaBirimiGirisDlg
  Left = 0
  Top = 0
  Caption = 'Ta'#351#305'ma Birimi Giri'#351
  ClientHeight = 110
  ClientWidth = 275
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ImgComboTasimaBirimi: TcxImageComboBox
    Left = 91
    Top = 52
    Properties.Items = <
      item
        Description = 'PALET'
        ImageIndex = 0
        Value = 'P'
      end
      item
        Description = 'KOL'#304
        Value = 'C'
      end
      item
        Description = 'BA'#286
        Value = 'S'
      end
      item
        Description = 'KOL'#304' '#304#199#304' KUTU'
        Value = 'B'
      end
      item
        Description = 'K'#220#199#220'K BA'#286
        Value = 'E'
      end>
    TabOrder = 0
    Width = 177
  end
  object cxLabel2: TcxLabel
    Left = 8
    Top = 56
    Caption = 'Ta'#351#305'ma Birimi'
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 269
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 64
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
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 2
    Transparent = True
    object BtnKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      Style = tbsTextButton
      OnClick = BtnKaydetClick
    end
    object BtnVazgeç: TToolButton
      Left = 64
      Top = 0
      Caption = 'Vazge'#231
      ImageIndex = 9
      OnClick = BtnVazgeçClick
    end
    object BtnYazdır: TToolButton
      Left = 128
      Top = 0
      Caption = 'Yazd'#305'r'
      ImageIndex = 8
      Visible = False
    end
  end
  object LblUstTasımaBirimi: TcxLabel
    Left = 8
    Top = 33
  end
  object cxLabel3: TcxLabel
    Left = 8
    Top = 83
    Caption = 'Adet'
  end
  object EdtAdet: TcxSpinEdit
    Left = 91
    Top = 79
    TabOrder = 5
    Value = 1
    Width = 60
  end
end
