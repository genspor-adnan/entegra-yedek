object KaliteYonetimAramaFrame: TKaliteYonetimAramaFrame
  Left = 0
  Top = 0
  Width = 403
  Height = 584
  TabOrder = 0
  object PanelKaliteYonetim: TPanel
    Left = 0
    Top = 0
    Width = 403
    Height = 160
    Align = alTop
    TabOrder = 0
    object KaliteYonetimMenu: TCategoryButtons
      Left = 1
      Top = 1
      Width = 401
      Height = 158
      Align = alClient
      BevelOuter = bvRaised
      ButtonFlow = cbfVertical
      ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boUsePlusMinus]
      Categories = <
        item
          Caption = 'Kalite Bile'#351'enleri'
          Color = clWhite
          Collapsed = False
          GradientColor = clSilver
          Items = <
            item
              Caption = 'Sapma / Olay'
              ImageIndex = 9
              OnClick = KaliteYonetimMenuCategories0Items0Click
            end
            item
              Caption = 'D'#214'F'
              ImageIndex = 9
              OnClick = KaliteYonetimMenuCategories0Items1Click
            end
            item
              Caption = 'Denetim'
              ImageIndex = 9
              OnClick = KaliteYonetimMenuCategories0Items2Click
            end
            item
              Caption = 'E'#287'itim'
              ImageIndex = 9
              OnClick = KaliteYonetimMenuCategories0Items3Click
            end
            item
              Caption = 'Toplant'#305
              ImageIndex = 9
              OnClick = KaliteYonetimMenuCategories0Items4Click
            end>
        end>
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      HotButtonColor = 14525318
      Images = Tablo.PNGImageList2
      RegularButtonColor = clSilver
      SelectedButtonColor = 12303291
      TabOrder = 0
    end
  end
  object PanelKaliteKontrol: TPanel
    Left = 0
    Top = 160
    Width = 403
    Height = 89
    Align = alTop
    TabOrder = 1
    object KaliteKontrolMenu: TCategoryButtons
      Left = 1
      Top = 1
      Width = 401
      Height = 87
      Align = alClient
      BevelOuter = bvRaised
      ButtonFlow = cbfVertical
      ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boUsePlusMinus]
      Categories = <
        item
          Caption = 'Kalite Kontrol'
          Color = clWhite
          Collapsed = False
          GradientColor = clSilver
          Items = <
            item
              Caption = 'Giri'#351' Kalite Kontrol'
              ImageIndex = 9
              OnClick = KaliteKontrolMenuCategories0Items0Click
            end
            item
              Caption = #220'r'#252'n Kalite Kontrol'
              ImageIndex = 9
              OnClick = KaliteKontrolMenuCategories0Items1Click
            end>
        end>
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      HotButtonColor = 14525318
      Images = Tablo.PNGImageList2
      RegularButtonColor = clSilver
      SelectedButtonColor = 12303291
      TabOrder = 0
    end
  end
end
