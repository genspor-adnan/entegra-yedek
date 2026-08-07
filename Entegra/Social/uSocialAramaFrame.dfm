object SocialAramaFrame: TSocialAramaFrame
  Left = 0
  Top = 0
  Width = 289
  Height = 443
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object LabelPNO: TcxLabel
    Left = 3
    Top = 68
    Caption = #220'nvan'
    FocusControl = AraFirma
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object Label7: TcxLabel
    Left = 3
    Top = 149
    Caption = 'Medya'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraFirma: TcxTextEdit
    Left = 81
    Top = 66
    TabOrder = 1
    Width = 115
  end
  object ComboSinif: TcxImageComboBox
    Left = 81
    Top = 147
    RepositoryItem = Tablo.RepCariSinif
    Properties.Items = <>
    TabOrder = 4
    Width = 115
  end
  object ToolBar6: TToolBar
    Left = 0
    Top = 1
    Width = 265
    Height = 28
    Margins.Bottom = 0
    Align = alCustom
    AutoSize = True
    ButtonHeight = 24
    ButtonWidth = 62
    Caption = 'AletCubugu'
    Color = clTeal
    Ctl3D = False
    DockSite = False
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esNone
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
    TabOrder = 11
    Transparent = True
    object LabelTumKayitlar: TToolButton
      Tag = 3
      Left = 0
      Top = 0
      HelpType = htKeyword
      HelpKeyword = 'K.SAY'
      Caption = 'T'#252'm Liste'
      ImageIndex = 32
      ImageName = 'PngImageListe'
    end
    object buttonYenile: TToolButton
      Left = 55
      Top = 0
      Caption = 'Yenile'
      EnableDropdown = True
      ImageIndex = 9
      ImageName = 'PngImage9'
    end
  end
  object cxLabel1: TcxLabel
    AlignWithMargins = True
    Left = 3
    Top = 94
    Caption = 'Ba'#351'lama'
    Properties.Alignment.Vert = taVCenter
    AnchorY = 105
  end
  object cxLabel2: TcxLabel
    AlignWithMargins = True
    Left = 3
    Top = 121
    Caption = 'Biti'#351'  '
    Properties.Alignment.Vert = taVCenter
    AnchorY = 132
  end
  object dateEnd: TcxDateEdit
    AlignWithMargins = True
    Left = 81
    Top = 120
    Properties.DateButtons = [btnClear, btnNow, btnToday]
    Properties.DateOnError = deToday
    Properties.ShowTime = False
    TabOrder = 3
    Width = 115
  end
  object dateStart: TcxDateEdit
    AlignWithMargins = True
    Left = 81
    Top = 93
    Properties.DateButtons = [btnClear, btnNow, btnToday]
    Properties.DateOnError = deToday
    Properties.ShowTime = False
    TabOrder = 2
    Width = 115
  end
  object cxLabel3: TcxLabel
    Left = 3
    Top = 175
    Caption = #350'ehir'
    FocusControl = AraSehir
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraSehir: TcxTextEdit
    Left = 81
    Top = 174
    TabOrder = 5
    Width = 115
  end
  object comboTemsilci: TcxButtonEdit
    Left = 81
    Top = 228
    ParentShowHint = False
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
    Properties.ClearKey = 46
    Properties.ReadOnly = False
    ShowHint = True
    TabOrder = 7
    OnKeyDown = comboTemsilciKeyDown
    Width = 115
  end
  object lbl6: TcxLabel
    Left = 3
    Top = 229
    Caption = 'Temsilci'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object AraUlke: TcxTextEdit
    Left = 81
    Top = 200
    TabOrder = 6
    Width = 115
  end
  object cxLabel4: TcxLabel
    Left = 3
    Top = 201
    Caption = #220'lke'
    FocusControl = AraUlke
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object CheckFilreSatiri: TcxCheckBox
    Left = 3
    Top = 258
    Caption = 'Filtre Sat'#305'r'#305'    '
    Properties.Alignment = taLeftJustify
    Properties.Glyph.SourceDPI = 96
    Properties.Glyph.SourceHeight = 16
    Properties.Glyph.SourceWidth = 32
    Properties.Glyph.Data = {
      3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
      462D38223F3E0D0A3C7376672076657273696F6E3D22312E312220786D6C6E73
      3D22687474703A2F2F7777772E77332E6F72672F323030302F7376672220786D
      6C6E733A786C696E6B3D22687474703A2F2F7777772E77332E6F72672F313939
      392F786C696E6B2220783D223070782220793D2230707822206865696768743D
      22307078222077696474683D22307078222076696577426F783D223020302033
      36203138223E0D0A093C67207461673D225F64782E6D756C74696672616D652E
      737667223E0D0A09093C706174682066696C6C3D22233732373237322220643D
      224D392C3043342C302C302C342C302C3963302C352C342C392C392C3963352C
      302C392D342C392D394331382C342C31342C302C392C307A204D392C3136632D
      332E392C302D372D332E312D372D3763302D332E392C332E312D372C372D3720
      202623393B63332E392C302C372C332E312C372C374331362C31322E392C3132
      2E392C31362C392C31367A222F3E0D0A093C2F673E0D0A093C67207472616E73
      666F726D3D226D6174726978283120302030203120313820302922207461673D
      225F64782E6D756C74696672616D652E737667223E0D0A09093C706174682066
      696C6C3D22233033394332332220643D224D392C3043342C302C302C342C302C
      3963302C352C342C392C392C3963352C302C392D342C392D394331382C342C31
      342C302C392C307A204D31302C31326C2D322C326C2D322D326C2D322D326C32
      2D326C322C326C352D356C322C324C31302C31327A222F3E0D0A093C2F673E0D
      0A3C2F7376673E0D0A}
    Properties.GlyphCount = 2
    Style.TransparentBorder = False
    TabOrder = 17
  end
  object CheckPasifKayitlar: TcxCheckBox
    Left = 3
    Top = 282
    Caption = 'Pasif Kay'#305'tlar'#305' da g'#246'r'#252'nt'#252'le'
    Properties.Alignment = taLeftJustify
    Properties.Glyph.SourceDPI = 96
    Properties.Glyph.SourceHeight = 16
    Properties.Glyph.SourceWidth = 32
    Properties.Glyph.Data = {
      3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
      462D38223F3E0D0A3C7376672076657273696F6E3D22312E312220786D6C6E73
      3D22687474703A2F2F7777772E77332E6F72672F323030302F7376672220786D
      6C6E733A786C696E6B3D22687474703A2F2F7777772E77332E6F72672F313939
      392F786C696E6B2220783D223070782220793D2230707822206865696768743D
      22307078222077696474683D22307078222076696577426F783D223020302033
      36203138223E0D0A093C67207461673D225F64782E6D756C74696672616D652E
      737667223E0D0A09093C706174682066696C6C3D22233732373237322220643D
      224D392C3043342C302C302C342C302C3963302C352C342C392C392C3963352C
      302C392D342C392D394331382C342C31342C302C392C307A204D392C3136632D
      332E392C302D372D332E312D372D3763302D332E392C332E312D372C372D3720
      202623393B63332E392C302C372C332E312C372C374331362C31322E392C3132
      2E392C31362C392C31367A222F3E0D0A093C2F673E0D0A093C67207472616E73
      666F726D3D226D6174726978283120302030203120313820302922207461673D
      225F64782E6D756C74696672616D652E737667223E0D0A09093C706174682066
      696C6C3D22233033394332332220643D224D392C3043342C302C302C342C302C
      3963302C352C342C392C392C3963352C302C392D342C392D394331382C342C31
      342C302C392C307A204D31302C31326C2D322C326C2D322D326C2D322D326C32
      2D326C322C326C352D356C322C324C31302C31327A222F3E0D0A093C2F673E0D
      0A3C2F7376673E0D0A}
    Properties.GlyphCount = 2
    Style.TransparentBorder = False
    TabOrder = 18
  end
  object CheckGroupBox: TcxCheckBox
    Left = 3
    Top = 310
    Caption = 'G'#246'r'#252'n'#252'm Gruplama'
    Properties.Alignment = taLeftJustify
    Properties.Glyph.SourceDPI = 96
    Properties.Glyph.SourceHeight = 16
    Properties.Glyph.SourceWidth = 32
    Properties.Glyph.Data = {
      3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554
      462D38223F3E0D0A3C7376672076657273696F6E3D22312E312220786D6C6E73
      3D22687474703A2F2F7777772E77332E6F72672F323030302F7376672220786D
      6C6E733A786C696E6B3D22687474703A2F2F7777772E77332E6F72672F313939
      392F786C696E6B2220783D223070782220793D2230707822206865696768743D
      22307078222077696474683D22307078222076696577426F783D223020302033
      36203138223E0D0A093C67207461673D225F64782E6D756C74696672616D652E
      737667223E0D0A09093C706174682066696C6C3D22233732373237322220643D
      224D392C3043342C302C302C342C302C3963302C352C342C392C392C3963352C
      302C392D342C392D394331382C342C31342C302C392C307A204D392C3136632D
      332E392C302D372D332E312D372D3763302D332E392C332E312D372C372D3720
      202623393B63332E392C302C372C332E312C372C374331362C31322E392C3132
      2E392C31362C392C31367A222F3E0D0A093C2F673E0D0A093C67207472616E73
      666F726D3D226D6174726978283120302030203120313820302922207461673D
      225F64782E6D756C74696672616D652E737667223E0D0A09093C706174682066
      696C6C3D22233033394332332220643D224D392C3043342C302C302C342C302C
      3963302C352C342C392C392C3963352C302C392D342C392D394331382C342C31
      342C302C392C307A204D31302C31326C2D322C326C2D322D326C2D322D326C32
      2D326C322C326C352D356C322C324C31302C31327A222F3E0D0A093C2F673E0D
      0A3C2F7376673E0D0A}
    Properties.GlyphCount = 2
    Style.TransparentBorder = False
    TabOrder = 19
  end
  object TabSK: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        ' select top 15 R.ID,R.FIRMA from KULLANICI_REHBER K inner join R' +
        'EHBER R on K.REHBERID=R.ID where KULID=5'
      ' order by K.DEGISTIRMETARIHI desc')
    Left = 124
    Top = 143
  end
  object DtsSK: TDataSource
    DataSet = TabSK
    Left = 131
    Top = 99
  end
  object PopupMenu1: TPopupMenu
    Left = 80
    Top = 336
    object mnuTumunuYenile: TMenuItem
      Caption = 'T'#252'm Sosyal Medya Yenile'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuMetaYenile: TMenuItem
      Tag = 1
      Caption = 'Meta Form verileri'
    end
    object mnuWebFormYenile: TMenuItem
      Tag = 2
      Caption = 'Web Form Verileri'
    end
  end
end

