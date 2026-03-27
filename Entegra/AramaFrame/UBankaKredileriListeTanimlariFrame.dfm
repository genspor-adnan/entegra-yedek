object BankaKredileriListeTanimlariFrame: TBankaKredileriListeTanimlariFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object KredilerMenu: TCategoryButtons
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alTop
    ButtonFlow = cbfVertical
    ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boUsePlusMinus]
    Categories = <
      item
        Caption = 'Gayrinakit Krediler'
        Color = 16053492
        Collapsed = False
        GradientColor = clGray
        Items = <
          item
            Caption = 'Pos'
            Hint = '2521'
            OnClick = KredilerMenuCategories1Items0Click
          end
          item
            Caption = 'Kredi Kart'#305
            Hint = '253130'
            OnClick = KredilerMenuCategories1Items1Click
          end
          item
            Caption = 'Teminat Mektubu'
            Hint = '2531350'
            OnClick = KredilerMenuCategories1Items3Click
          end
          item
            Caption = 'Do'#287'rudan Bor'#231'lanma'
            Hint = '253160'
            OnClick = KredilerMenuCategories1Items4Click
          end>
      end
      item
        Caption = 'Di'#287'er'
        Color = 16053492
        Collapsed = False
        Items = <
          item
            Caption = 'Vadeli Hesap'
            Hint = '2541'
            OnClick = KredilerMenuCategories2Items0Click
          end>
      end>
    DoubleBuffered = True
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    HotButtonColor = 14525318
    ParentDoubleBuffered = False
    RegularButtonColor = clSilver
    SelectedButtonColor = 12303291
    TabOrder = 0
  end
end
