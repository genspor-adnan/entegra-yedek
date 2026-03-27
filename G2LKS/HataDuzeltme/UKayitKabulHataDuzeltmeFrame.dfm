object KayitKabulHataDuzeltmeFrame: TKayitKabulHataDuzeltmeFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 117
  Align = alTop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  ExplicitWidth = 443
  object hastaKayitErisLink: TJvLinkLabel
    Left = 40
    Top = 64
    Width = 481
    Height = 13
    Caption = 
      'Bu hatay'#305' Kay'#305't Kabul mod'#252'l'#252'nden d'#252'zeltmelisiniz. Hastaya eri'#351'me' +
      'k i'#231'in <link>t'#305'klay'#305'n</link>'#13#10
    Text.Strings = (
      
        'Bu hatay'#305' Kay'#305't Kabul mod'#252'l'#252'nden d'#252'zeltmelisiniz. Hastaya eri'#351'me' +
        'k i'#231'in <link>t'#305'klay'#305'n</link>'#13#10)
    Layout = tlCenter
    OnLinkClick = hastaKayitErisLinkLinkClick
  end
  object JvPanel1: TJvPanel
    Left = 0
    Top = 0
    Width = 521
    Height = 33
    HotTrackFont.Charset = DEFAULT_CHARSET
    HotTrackFont.Color = clWindowText
    HotTrackFont.Height = -11
    HotTrackFont.Name = 'MS Sans Serif'
    HotTrackFont.Style = []
    FlatBorder = True
    FlatBorderColor = clRed
    Align = alTop
    BorderWidth = 1
    Color = 10198015
    TabOrder = 0
    object hataStaticText: TStaticText
      Left = 2
      Top = 2
      Width = 138
      Height = 17
      Align = alClient
      Caption = 'Hata a'#231#305'klamas'#305' buraya'
      TabOrder = 0
    end
  end
end
