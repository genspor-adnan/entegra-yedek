object SecimDlg: TSecimDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Se'#231'im Ekran'#305
  ClientHeight = 334
  ClientWidth = 526
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 27
    Width = 526
    Height = 307
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 303
    ClientRectLeft = 4
    ClientRectRight = 522
    ClientRectTop = 27
    object cxTabSheet1: TcxTabSheet
      Caption = 'Bildirilen Sorunlar'
      ImageIndex = 0
      object CheckListSorun: TcxCheckListBox
        Left = 0
        Top = 0
        Width = 518
        Height = 276
        Align = alClient
        Columns = 2
        Items = <>
        TabOrder = 0
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'Teslim Al'#305'nanlar'
      ImageIndex = 1
      object CheckListTeslim: TcxCheckListBox
        Left = 0
        Top = 0
        Width = 518
        Height = 276
        Align = alClient
        Columns = 2
        Items = <>
        TabOrder = 0
      end
    end
  end
  object ToolBar5: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 520
    Height = 24
    Margins.Bottom = 0
    AutoSize = True
    ButtonWidth = 62
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
    TabOrder = 1
    Transparent = True
    object SatirEkle: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 0
      OnClick = SatirEkleClick
    end
    object SatirSil: TToolButton
      Left = 62
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 1
      OnClick = SatirSilClick
    end
    object ToolButton4: TToolButton
      Left = 124
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 2
      Style = tbsSeparator
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 91
    Top = 129
    object Sorunlistesi1: TMenuItem
      Caption = 'Sorun listesi'
      OnClick = Sorunlistesi1Click
    end
    object eslimalnanlistesi1: TMenuItem
      Caption = 'Teslim al'#305'nan listesi'
      OnClick = eslimalnanlistesi1Click
    end
  end
end
