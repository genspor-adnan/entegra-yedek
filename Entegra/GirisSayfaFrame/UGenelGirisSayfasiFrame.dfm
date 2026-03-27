object GenelGirisSayfasiFrame: TGenelGirisSayfasiFrame
  Left = 0
  Top = 0
  Width = 749
  Height = 507
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
  object pnlGenel: TJvPanel
    Left = 0
    Top = 0
    Width = 749
    Height = 507
    OnPaint = pnlGenelPaint
    Align = alClient
    BevelOuter = bvNone
    Color = 16753828
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 441
    ExplicitHeight = 386
    object Label1: TLabel
      Left = 42
      Top = 33
      Width = 120
      Height = 29
      Caption = 'GENTEGRE'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 42
      Top = 74
      Width = 462
      Height = 22
      Caption = 
        'Sol taraftaki gezinme panelini kullanarak i'#351'lemleri ger'#231'ekle'#351'tir' +
        'in.'
      Font.Charset = TURKISH_CHARSET
      Font.Color = 16744448
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Shape1: TShape
      Left = 42
      Top = 66
      Width = 379
      Height = 1
    end
  end
end
