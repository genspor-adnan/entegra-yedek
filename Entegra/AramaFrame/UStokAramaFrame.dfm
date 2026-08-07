object StokAramaFrame: TStokAramaFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 519
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
  object LabelPNO: TcxLabel
    Left = 0
    Top = 48
    AutoSize = False
    Caption = '&Stok Ad'#305
    FocusControl = AraStokAdi
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Properties.WordWrap = True
    Transparent = True
    Height = 22
    Width = 78
  end
  object Label3: TcxLabel
    Left = 0
    Top = 75
    Caption = '&Kodu/'#220'r'#252'nNo'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label12: TcxLabel
    Left = 0
    Top = 130
    Caption = 'Kategori'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label1: TcxLabel
    Left = 0
    Top = 157
    Caption = '&Marka'
    FocusControl = AraStokAdi
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label4: TcxLabel
    Left = 0
    Top = 211
    Caption = '&Grubu'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label5: TcxLabel
    Left = 0
    Top = 238
    Caption = #350'ube'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label2: TcxLabel
    Left = 0
    Top = 184
    Caption = '&Model'
    FocusControl = AraStokAdi
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label6: TcxLabel
    Left = 0
    Top = 102
    Caption = '&Barkodu'
    FocusControl = AraBarkod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraStokAdi: TcxTextEdit
    Left = 80
    Top = 49
    TabOrder = 4
    Width = 122
  end
  object AraKod: TcxTextEdit
    Left = 80
    Top = 76
    TabOrder = 6
    Width = 122
  end
  object CheckPasifler: TcxCheckBox
    Left = 0
    Top = 297
    Caption = 'Pasifleri de g'#246'ster'
    TabOrder = 21
    Transparent = True
  end
  object ComboMARKA: TcxImageComboBox
    Left = 80
    Top = 157
    RepositoryItem = Tablo.repStokMarka
    Properties.Items = <>
    Properties.OnCloseUp = ComboMarkaPropertiesCloseUp
    TabOrder = 11
    Width = 122
  end
  object ComboGRUBU: TcxImageComboBox
    Left = 80
    Top = 211
    RepositoryItem = Tablo.repStokGrubu
    Properties.Items = <>
    TabOrder = 14
    Width = 122
  end
  object ComboSUBE: TcxImageComboBox
    Left = 80
    Top = 238
    RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
    Properties.Items = <>
    TabOrder = 15
    Width = 122
  end
  object ComboMODEL: TcxImageComboBox
    Left = 80
    Top = 184
    Properties.Items = <>
    TabOrder = 13
    Width = 122
  end
  object AraBarkod: TcxTextEdit
    Left = 80
    Top = 103
    TabOrder = 8
    Width = 122
  end
  object LabelAnaliz: TcxLabel
    Left = 0
    Top = 266
    Caption = '&Analiz'
    FocusControl = AraKod
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.TextColor = clBtnText
    Style.IsFontAssigned = True
    Transparent = True
  end
  object ComboAnaliz: TcxImageComboBox
    Left = 80
    Top = 266
    Properties.Items = <
      item
        ImageIndex = 0
        Value = '0'
      end
      item
        Description = 'Kullan'#305'lan'
        Tag = 1
        Value = '1'
      end>
    TabOrder = 16
    OnClick = ComboAnalizClick
    Width = 122
  end
  object GbAnaliz: TGroupBox
    Left = 0
    Top = 319
    Width = 199
    Height = 137
    TabOrder = 17
    Visible = False
    object DateBas: TcxDateEdit
      Left = 77
      Top = 10
      Properties.ImmediatePost = True
      TabOrder = 0
      Width = 118
    end
    object DateBitis: TcxDateEdit
      Left = 77
      Top = 37
      Properties.ImmediatePost = True
      TabOrder = 2
      Width = 118
    end
    object cxLabel2: TcxLabel
      Left = 0
      Top = 11
      Caption = '&Ba'#351'lama'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clBtnText
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel3: TcxLabel
      Left = 0
      Top = 92
      Caption = '&Adet'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clBtnText
      Style.IsFontAssigned = True
      Transparent = True
    end
    object AraSorgula: TcxButton
      Left = 151
      Top = 91
      Width = 44
      Height = 25
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        424D360800000000000036000000280000002000000010000000010020000000
        000000000000C40E0000C40E00000000000000000000D2D9DC00F8F9FAFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F9FAFFD2D9DC00D2D9DC00F8F9FAFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F9FAFFD2D9DC00F8F9FAFF85B785FF0F6F
        0FFF167416FF1A761AFF1A761AFF187818FF177917FF137D13FF0D7F0DFF0A7E
        0AFF077C07FF027B02FF007000FF7FB07FFFF8F9FAFFF8F9FAFFA2A2A2FF4747
        47FF4D4D4DFF505050FF505050FF505050FF505050FF515151FF505050FF4E4E
        4EFF4C4C4CFF494949FF424242FF9B9B9BFFF8F9FAFFFFFFFFFF118311FF1F8C
        1FFF2A912AFF2F932FFF2E942EFF2C962CFF299A29FF239E23FF1CA31CFF15A4
        15FF0DA40DFF059F05FF019101FF006F00FFFFFFFFFFFFFFFFFF545454FF5F5F
        5FFF666666FF6A6A6AFF6A6A6AFF6A6A6AFF6B6B6BFF6B6B6BFF6B6B6BFF6969
        69FF666666FF5F5F5FFF555555FF414141FFFFFFFFFFFFFFFFFF198D19FF2C96
        2CFF379C37FF3D9F3DFF3C9F3CFF39A139FFA3D6A3FFFFFFFFFF24AF24FF1CB1
        1CFF13B213FF0AAD0AFF049F04FF027902FFFFFFFFFFFFFFFFFF5D5D5DFF6A6A
        6AFF727272FF767676FF767676FF767676FFC1C1C1FFFFFFFFFF767676FF7373
        73FF707070FF6A6A6AFF5F5F5FFF484848FFFFFFFFFFFFFFFFFF229122FF389C
        38FF43A243FF48A448FF45A545FF42A642FFFFFFFFFFFFFFFFFFFFFFFFFF21B5
        21FF18B618FF0EB10EFF08A308FF057E05FFFFFFFFFFFFFFFFFF636363FF7373
        73FF7B7B7BFF7E7E7EFF7D7D7DFF7D7D7DFFFFFFFFFFFFFFFFFFFFFFFFFF7878
        78FF757575FF6E6E6EFF636363FF4C4C4CFFFFFFFFFFFFFFFFFF2C962CFF42A0
        42FF4CA54CFF4FA74FFF4CA74CFF46A746FF40AA40FFFFFFFFFFFFFFFFFFFFFF
        FFFF1AB31AFF14AF14FF0FA30FFF0B800BFFFFFFFFFFFFFFFFFF6A6A6AFF7979
        79FF808080FF828282FF818181FF7F7F7FFF7E7E7EFFFFFFFFFFFFFFFFFFFFFF
        FFFF747474FF6F6F6FFF666666FF505050FFFFFFFFFFFFFFFFFF359A35FF4BA5
        4BFF52A852FF53A953FF4EA84EFF49A749FF41A841FF38AA38FFFFFFFFFFFFFF
        FFFFFFFFFFFF19AC19FF18A218FF128212FFFFFFFFFFFFFFFFFF707070FF8080
        80FF848484FF858585FF838383FF808080FF7D7D7DFF7B7B7BFFFFFFFFFFFFFF
        FFFFFFFFFFFF6F6F6FFF696969FF545454FFFFFFFFFFFFFFFFFF3F9F3FFF53A9
        53FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF1F9E1FFF188118FFFFFFFFFFFFFFFFFF777777FF8585
        85FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF696969FF555555FFFFFFFFFFFFFFFFFF45A245FF5AAC
        5AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF259A25FF1D7F1DFFFFFFFFFFFFFFFFFF7B7B7BFF8A8A
        8AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF6A6A6AFF565656FFFFFFFFFFFFFFFFFF4FA74FFF63B1
        63FF61AF61FF59AB59FF51A651FF48A248FF3F9F3FFF369C36FFFFFFFFFFFFFF
        FFFFFFFFFFFF269926FF2A972AFF217E21FFFFFFFFFFFFFFFFFF828282FF9191
        91FF8F8F8FFF898989FF838383FF7D7D7DFF777777FF727272FFFFFFFFFFFFFF
        FFFFFFFFFFFF696969FF6A6A6AFF575757FFFFFFFFFFFFFFFFFF53A953FF6CB6
        6CFF68B468FF5EAD5EFF54A854FF4CA34CFF429F42FFFFFFFFFFFFFFFFFFFFFF
        FFFF299729FF2B982BFF2D952DFF237E23FFFFFFFFFFFFFFFFFF858585FF9797
        97FF949494FF8C8C8CFF858585FF7F7F7FFF787878FFFFFFFFFFFFFFFFFFFFFF
        FFFF696969FF6B6B6BFF6A6A6AFF585858FFFFFFFFFFFFFFFFFF5EAF5EFF7ABD
        7AFF70B870FF63B063FF5AAB5AFF52A652FFFFFFFFFFFFFFFFFFFFFFFFFF3399
        33FF309930FF309830FF2F942FFF237D23FFFFFFFFFFFFFFFFFF8D8D8DFFA1A1
        A1FF9A9A9AFF909090FF898989FF838383FFFFFFFFFFFFFFFFFFFFFFFFFF6F6F
        6FFF6D6D6DFF6D6D6DFF6A6A6AFF585858FFFFFFFFFFFFFFFFFF6BB56BFF8DC6
        8DFF80C080FF6FB76FFF67B267FF60AE60FFB4D9B4FFFFFFFFFF4CA54CFF49A4
        49FF41A141FF3A9D3AFF309530FF1E7A1EFFFFFFFFFFFFFFFFFF969696FFAEAE
        AEFFA5A5A5FF999999FF939393FF8E8E8EFFC9C9C9FFFFFFFFFF808080FF7E7E
        7EFF797979FF747474FF6B6B6BFF545454FFFFFFFFFFFFFFFFFF77BB77FF9DCF
        9DFF8CC68CFF79BC79FF70B870FF69B469FF65B265FF62B062FF5DAE5DFF56AB
        56FF4EA74EFF41A141FF2F942FFF197719FFFFFFFFFFFFFFFFFF9F9F9FFFBABA
        BAFFAEAEAEFFA0A0A0FF9A9A9AFF959595FF929292FF909090FF8C8C8CFF8888
        88FF828282FF797979FF6A6A6AFF505050FFFFFFFFFFF8F9FAFFB1D8B1FF76BB
        76FF67B367FF5BAD5BFF54A954FF4FA74FFF4AA44AFF4BA54BFF46A346FF3FA0
        3FFF3B9E3BFF319831FF238C23FF8ABB8AFFF8F9FAFFF8F9FAFFC8C8C8FF9E9E
        9EFF939393FF8B8B8BFF868686FF828282FF7F7F7FFF808080FF7C7C7CFF7878
        78FF757575FF6D6D6DFF606060FFA6A6A6FFF8F9FAFFD2D9DC00F8F9FAFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F9FAFFD2D9DC00D2D9DC00F8F9FAFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F9FAFFD2D9DC00}
      OptionsImage.NumGlyphs = 2
      TabOrder = 7
    end
    object AraAdet: TcxSpinEdit
      Left = 77
      Top = 92
      TabOrder = 5
      Width = 71
    end
    object cxLabel4: TcxLabel
      Left = 0
      Top = 38
      Caption = '&Biti'#351
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clBtnText
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel5: TcxLabel
      Left = 0
      Top = 66
      Caption = '&Periyot'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clBtnText
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ComboPeriyot: TcxImageComboBox
      Left = 77
      Top = 64
      EditValue = '1'
      Properties.Items = <
        item
          Description = 'Haftal'#305'k'
          Value = '4'
        end
        item
          Description = 'Ayl'#305'k'
          Value = '1'
        end>
      TabOrder = 4
      Width = 118
    end
  end
  object ToolBarAranan: TToolBar
    Left = 0
    Top = 0
    Width = 451
    Height = 28
    AutoSize = True
    ButtonHeight = 24
    ButtonWidth = 62
    Caption = 'AletCubugu'
    Color = clTeal
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
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
    TabOrder = 19
    Transparent = True
    object LabelTumKayitlar: TToolButton
      Tag = 3
      Left = 0
      Top = 0
      Caption = 'T'#252'm'
      ImageIndex = 32
      ImageName = 'PngImageListe'
    end
    object LabelSonArananlar: TToolButton
      Tag = 5
      Left = 62
      Top = 0
      Caption = 'Son'
      ImageIndex = 21
      ImageName = 'PngImage21'
    end
    object LabelSikArananlar: TToolButton
      Tag = 3
      Left = 124
      Top = 0
      Caption = 'S'#305'k'
      ImageIndex = 31
      ImageName = 'PngImageYildiz'
    end
  end
  object EditKategori: TcxButtonEdit
    Left = 80
    Top = 130
    HelpType = htKeyword
    HelpKeyword = 'MASRAFID'
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end
      item
        Caption = '-'
        Hint = 'Temizle'
        Kind = bkText
      end>
    Properties.ReadOnly = True
    Properties.OnButtonClick = EditKategoriPropertiesButtonClick
    TabOrder = 22
    Width = 122
  end
end
