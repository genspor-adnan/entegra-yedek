object frmEvrakTanim: TfrmEvrakTanim
  Left = 0
  Top = 0
  Caption = 'Evrak Tan'#305'mlar'#305
  ClientHeight = 643
  ClientWidth = 1015
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 18
  object UstPanel: TJvPanel
    Left = 0
    Top = 0
    Width = 1015
    Height = 64
    FlatBorder = True
    Align = alTop
    BorderWidth = 1
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 1011
    object LabelAltBaslik: TLabel
      Left = 9
      Top = 42
      Width = 392
      Height = 13
      Caption = 
        'Girilmesi gereken Evrak Takibi parametre tan'#305'mlar'#305'n'#305'  tamamlay'#305'n' +
        #305'z.'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object BaslikLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 99
      Height = 25
      Align = alTop
      Caption = 'Tan'#305'mlar'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
  end
  object FrameListesi: TcxListView
    AlignWithMargins = True
    Left = 3
    Top = 67
    Width = 222
    Height = 573
    Align = alLeft
    Columns = <
      item
      end>
    TabOrder = 1
    ViewStyle = vsReport
    OnCustomDrawItem = FrameListesiCustomDrawItem
    OnResize = FrameListesiResize
    OnSelectItem = FrameListesiSelectItem
  end
  object cxSplitter1: TcxSplitter
    Left = 228
    Top = 64
    Width = 8
    Height = 579
    HotZoneClassName = 'TcxSimpleStyle'
    ResizeUpdate = True
    Control = FrameListesi
    ExplicitHeight = 578
  end
  object PageTanim: TcxPageControl
    AlignWithMargins = True
    Left = 239
    Top = 67
    Width = 773
    Height = 573
    Align = alClient
    TabOrder = 3
    Properties.ActivateFocusedTab = False
    Properties.CustomButtons.Buttons = <>
    Properties.MultiLine = True
    Properties.MultiLineTabCaptions = True
    LookAndFeel.Kind = lfFlat
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = ''
    ExplicitWidth = 769
    ExplicitHeight = 572
    ClientRectBottom = 572
    ClientRectLeft = 1
    ClientRectRight = 772
    ClientRectTop = 1
  end
end
