object AksiyonlarFrame: TAksiyonlarFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object pnl2: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 304
    Align = alLeft
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object pnl1: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 179
      Height = 136
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      object btn1: TcxButton
        AlignWithMargins = True
        Left = 3
        Top = 95
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'Takvim'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btn1Click
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btn2: TcxButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'Aksiyon Ekle'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = btn2Click
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btn3: TcxButton
        AlignWithMargins = True
        Left = 3
        Top = 49
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'G'#252'nl'#252'k Aksiyonlar'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btn3Click
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
    end
    object cxGroupBox1: TcxGroupBox
      Left = 0
      Top = 142
      Align = alClient
      Caption = 'Arama'
      Style.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
      TabOrder = 1
      ExplicitTop = 144
      Height = 162
      Width = 185
      object ScrollBox2: TScrollBox
        Left = 2
        Top = 18
        Width = 181
        Height = 137
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Color = clWhite
        Ctl3D = False
        ParentColor = False
        ParentCtl3D = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 17
        ExplicitWidth = 183
        ExplicitHeight = 144
        object pcArama: TcxPageControl
          Left = 0
          Top = 0
          Width = 181
          Height = 137
          Align = alClient
          HideTabs = True
          TabOrder = 0
          ExplicitWidth = 183
          ExplicitHeight = 144
          ClientRectBottom = 136
          ClientRectLeft = 1
          ClientRectRight = 180
          ClientRectTop = 1
        end
      end
    end
  end
  object JvPanel1: TJvPanel
    Left = 185
    Top = 0
    Width = 266
    Height = 304
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object AnaSayfaDenetimi: TcxPageControl
      Left = 0
      Top = 28
      Width = 266
      Height = 276
      Align = alClient
      HideTabs = True
      TabOrder = 0
      ClientRectBottom = 275
      ClientRectLeft = 1
      ClientRectRight = 265
      ClientRectTop = 1
    end
    object pnlBaslik: TJvPanel
      Left = 0
      Top = 0
      Width = 266
      Height = 28
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -11
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      FlatBorderColor = clBlue
      OnPaint = pnlBaslikPaint
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 1
      Color = 13482924
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
    end
  end
end
