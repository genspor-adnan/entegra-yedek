object BankaFrame: TBankaFrame
  Left = 0
  Top = 0
  Width = 497
  Height = 398
  Align = alClient
  TabOrder = 0
  ExplicitWidth = 451
  ExplicitHeight = 304
  object JvPanel1: TJvPanel
    Left = 185
    Top = 0
    Width = 312
    Height = 398
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'Tahoma'
    HotTrackFont.Style = []
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 266
    ExplicitHeight = 304
    object AnaSayfaDenetimi: TcxPageControl
      Left = 0
      Top = 28
      Width = 312
      Height = 370
      Align = alClient
      HideTabs = True
      TabOrder = 0
      ExplicitWidth = 266
      ExplicitHeight = 276
      ClientRectBottom = 369
      ClientRectLeft = 1
      ClientRectRight = 311
      ClientRectTop = 1
    end
    object pnlBaslik: TJvPanel
      Left = 0
      Top = 0
      Width = 312
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
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      ExplicitWidth = 266
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 398
    Align = alLeft
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    ExplicitHeight = 304
    object pnl1: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 179
      Height = 325
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
      object btnVadeliHesap: TcxButton
        Tag = 11
        AlignWithMargins = True
        Left = 3
        Top = 187
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'Vadeli Hesap'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnVadeliHesapClick
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btnDokumler: TcxButton
        AlignWithMargins = True
        Left = 3
        Top = 279
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'D'#246'k'#252'mler'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btnTeminatMektubu: TcxButton
        Tag = 11
        AlignWithMargins = True
        Left = 3
        Top = 141
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'Teminat Mektubu'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnTeminatMektubuClick
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btnBankaKredileri: TcxButton
        Tag = 11
        AlignWithMargins = True
        Left = 3
        Top = 95
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'Banka Kredileri'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = btnBankaKredileriClick
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btnBankaHareketleri: TcxButton
        Tag = 11
        AlignWithMargins = True
        Left = 3
        Top = 49
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'Banka Hareketleri'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnClick = btnBankaHareketleriClick
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btnBankaTanimlari: TcxButton
        Tag = 11
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 173
        Height = 40
        Align = alTop
        Caption = 'Banka Tan'#305'mlar'#305
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        OnClick = btnBankaClick
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
      object btnCekKocani: TcxButton
        Tag = 11
        AlignWithMargins = True
        Left = 3
        Top = 233
        Width = 173
        Height = 40
        Align = alTop
        Caption = #199'ek Ko'#231'an'#305
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 6
        OnClick = btnCekKocaniClick
        LookAndFeel.SkinName = 'LondonLiquidSky'
        SpeedButtonOptions.GroupIndex = 5
      end
    end
    object cxGroupBox1: TcxGroupBox
      Left = 0
      Top = 331
      Align = alClient
      Caption = 'Arama'
      Style.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
      StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
      TabOrder = 1
      ExplicitHeight = 189
      Height = 67
      Width = 185
      object ScrollBox2: TScrollBox
        Left = 2
        Top = 18
        Width = 181
        Height = 42
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
        ExplicitHeight = 171
        object pcArama: TcxPageControl
          Left = 0
          Top = 0
          Width = 181
          Height = 42
          Align = alClient
          HideTabs = True
          TabOrder = 0
          ExplicitWidth = 183
          ExplicitHeight = 171
          ClientRectBottom = 41
          ClientRectLeft = 1
          ClientRectRight = 180
          ClientRectTop = 1
        end
      end
    end
  end
end
