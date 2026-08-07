object IKDlgGenelAramaFrame: TIKDlgGenelAramaFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
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
  object EditCARIKOD: TcxLabel
    Left = 0
    Top = 24
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
    Images = Tablo.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 3
    Transparent = True
    object LabelTumKayitlar: TToolButton
      Left = 0
      Top = 0
      Caption = 'T'#252'm'
      ImageIndex = 32
      ImageName = 'PngImageListe'
    end
    object LabelSonArananlar: TToolButton
      Left = 62
      Top = 0
      Caption = 'Son'
      ImageIndex = 21
      ImageName = 'PngImage21'
    end
    object LabelSikArananlar: TToolButton
      Left = 124
      Top = 0
      Caption = 'S'#305'k'
      ImageIndex = 31
      ImageName = 'PngImageYildiz'
    end
  end
  object cxLabel28: TcxLabel
    Left = 0
    Top = 193
    Caption = #304'l'
    ParentFont = False
    Style.Font.Charset = TURKISH_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object PageControlArama: TcxPageControl
    Left = 0
    Top = 43
    Width = 451
    Height = 261
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    Properties.HideTabs = True
    Properties.Options = [pcoAlwaysShowGoDialogButton, pcoCloseButton, pcoFixedTabWidthWhenRotated, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize]
    ClientRectBottom = 257
    ClientRectLeft = 4
    ClientRectRight = 447
    ClientRectTop = 4
    object cxTabSheet1: TcxTabSheet
      ImageIndex = 0
      object LabelPNO: TcxLabel
        Left = -2
        Top = 36
        Caption = 'Ad Soyad'
        FocusControl = AraFirma
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Width = 48
      end
      object Label3: TcxLabel
        Left = -2
        Top = 64
        Caption = '&Kod'
        FocusControl = AraKod
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object AraFirma: TcxTextEdit
        Left = 59
        Top = 34
        TabOrder = 2
        Width = 115
      end
      object AraKod: TcxTextEdit
        Left = 59
        Top = 62
        TabOrder = 4
        Width = 115
      end
      object CheckPasifler: TcxCheckBox
        Left = 59
        Top = 94
        Caption = 'Pasifleri de g'#246'ster'
        TabOrder = 6
        Transparent = True
      end
    end
    object cxTabSheet2: TcxTabSheet
      ImageIndex = 1
      object cxLabel2: TcxLabel
        Left = 0
        Top = 96
        Caption = 'Ad Soyad'
        FocusControl = AraFirma2
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Width = 48
      end
      object cxLabel3: TcxLabel
        Left = 0
        Top = 342
        Caption = #220'cret'
        FocusControl = EditUcret
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxLabel7: TcxLabel
        Left = 0
        Top = 124
        Caption = 'Cinsiyet'
        FocusControl = EditUcret
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object AraFirma2: TcxTextEdit
        Left = 77
        Top = 94
        TabOrder = 3
        Width = 115
      end
      object EditUcret: TcxTextEdit
        Left = 77
        Top = 334
        TabOrder = 4
        Width = 60
      end
      object CheckPasifler2: TcxCheckBox
        Left = 77
        Top = 361
        Caption = 'Pasifleri de g'#246'ster'
        TabOrder = 6
        Transparent = True
      end
      object ComboIl: TcxImageComboBox
        Left = 77
        Top = 253
        RepositoryItem = Tablo.Repiller
        Properties.Items = <>
        TabOrder = 7
        Width = 115
      end
      object ComboCinsiyet: TcxImageComboBox
        Left = 77
        Top = 120
        RepositoryItem = Tablo.RepIKCinsiyet
        Properties.Items = <>
        TabOrder = 9
        Width = 115
      end
      object cxSpinEdit1: TcxSpinEdit
        Left = 126
        Top = 67
        Properties.ImmediatePost = True
        TabOrder = 12
        Value = 200
        Width = 66
      end
      object cxLabel9: TcxLabel
        Left = 77
        Top = 69
        Caption = 'Kay'#305't#'
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
      object LabelGrup: TcxLabel
        Left = 0
        Top = 177
        Caption = 'Sekt'#246'r'
        FocusControl = AraKod
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxLabel11: TcxLabel
        Left = 0
        Top = 205
        Caption = 'Departman'
        FocusControl = AraKod
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label7: TcxLabel
        Left = 0
        Top = 234
        Caption = 'G'#246'rev'
        FocusControl = AraKod
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboSektor: TcxImageComboBox
        Left = 77
        Top = 172
        RepositoryItem = Tablo.RepCariSektor
        Properties.Items = <>
        TabOrder = 14
        Width = 115
      end
      object ComboDepartman: TcxImageComboBox
        Left = 77
        Top = 199
        RepositoryItem = Tablo.RepCariBolum
        Properties.Items = <>
        TabOrder = 15
        Width = 115
      end
      object ComboGorev: TcxImageComboBox
        Left = 77
        Top = 226
        RepositoryItem = Tablo.RepCariGorev
        Properties.Items = <>
        TabOrder = 17
        Width = 115
      end
      object cxLabel12: TcxLabel
        Left = 3
        Top = 259
        Caption = '&'#304'l'
        FocusControl = EditUcret
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboOgrenim: TcxImageComboBox
        Left = 77
        Top = 146
        RepositoryItem = Tablo.RepIKOgrenim
        Properties.Items = <>
        TabOrder = 19
        Width = 115
      end
      object cxLabel10: TcxLabel
        Left = 0
        Top = 150
        Caption = #214#287'r. Durumu'
        FocusControl = EditUcret
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditUcret2: TcxTextEdit
        Left = 136
        Top = 334
        TabOrder = 5
        Width = 60
      end
      object ComboDil1: TcxImageComboBox
        Left = 77
        Top = 307
        RepositoryItem = Tablo.RepIKDiller
        Properties.Items = <>
        TabOrder = 23
        Width = 58
      end
      object cxLabel1: TcxLabel
        Left = 0
        Top = 312
        Caption = 'Y.Dili'
        FocusControl = AraKod
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboDil2: TcxImageComboBox
        Left = 136
        Top = 306
        RepositoryItem = Tablo.RepIKDiller
        Properties.Items = <>
        TabOrder = 20
        Width = 56
      end
      object cxLabel4: TcxLabel
        Left = 3
        Top = 284
        Cursor = crHandPoint
        HelpType = htKeyword
        Caption = 'Uyru'#287'u'
        Transparent = True
      end
      object EditUyruk: TcxButtonEdit
        Left = 77
        Top = 280
        Hint = 'ALTBOLGE'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end
          item
            Caption = '-'
            Kind = bkText
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditUyrukPropertiesButtonClick
        TabOrder = 24
        Width = 115
      end
    end
  end
  object TabSK: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        ' select top 15 R.ID,R.FIRMA from KULLANICI_REHBER K inner join R' +
        'EHBER R on K.REHBERID=R.ID where KULID=5'
      ' order by K.DEGISTIRMETARIHI desc')
    Left = 223
    Top = 42
  end
  object DtsSK: TDataSource
    DataSet = TabSK
    Left = 206
    Top = 7
  end
end
