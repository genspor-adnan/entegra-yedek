object DokumAramaFrame: TDokumAramaFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object dokumListesi: TCategoryButtons
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    ButtonFlow = cbfVertical
    ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boBoldCaptions, boUsePlusMinus]
    Categories = <
      item
        Caption = 'Genel'
        Color = clWhite
        Collapsed = False
        GradientColor = clGray
        Items = <
          item
            Caption = 'fgsdgdsg'
            ImageIndex = 0
          end>
      end
      item
        Caption = 'G'#252'nel'
        Color = 16053492
        Collapsed = False
        Items = <
          item
            Caption = 'a'
          end
          item
            Caption = 'b'
          end
          item
            Caption = 'c'
          end>
      end>
    HotButtonColor = 14525318
    RegularButtonColor = clSilver
    SelectedButtonColor = 12303291
    TabOrder = 0
    OnButtonClicked = dokumListesiButtonClicked
  end
end
