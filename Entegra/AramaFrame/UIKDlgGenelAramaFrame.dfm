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
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    TabOrder = 2
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    Properties.HideTabs = True
    Properties.Options = [pcoAlwaysShowGoDialogButton, pcoCloseButton, pcoFixedTabWidthWhenRotated, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize]
    ClientRectBottom = 303
    ClientRectLeft = 1
    ClientRectRight = 450
    ClientRectTop = 1
    object cxTabSheet1: TcxTabSheet
      ImageIndex = 0
      object LabelPNO: TcxLabel
        Left = 8
        Top = 110
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
        Left = 8
        Top = 138
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
      object LabelSonArananlar: TcxLabel
        Tag = 4
        Left = 8
        Top = 27
        Cursor = crHandPoint
        HelpType = htKeyword
        HelpKeyword = 'K.DEGISTIRMETARIHI'
        Caption = 'Son Arananlar'
        FocusControl = AraFirma
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelSIKArananlar: TcxLabel
        Tag = 3
        Left = 8
        Top = 51
        Cursor = crHandPoint
        HelpType = htKeyword
        HelpKeyword = 'K.SAY'
        Caption = 'S'#305'k Arananlar'
        FocusControl = AraFirma
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object AraFirma: TcxTextEdit
        Left = 85
        Top = 108
        TabOrder = 4
        Width = 115
      end
      object AraKod: TcxTextEdit
        Left = 85
        Top = 136
        TabOrder = 5
        Width = 115
      end
      object CheckPasifler: TcxCheckBox
        Left = 85
        Top = 168
        Caption = 'Pasifleri de g'#246'ster'
        TabOrder = 6
        Transparent = True
        Width = 132
      end
      object LabelTumKayitlar: TcxLabel
        Tag = 3
        Left = 8
        Top = 4
        Cursor = crHandPoint
        HelpType = htKeyword
        HelpKeyword = 'K.SAY'
        Caption = 'T'#252'm Kay'#305'tlar'
        FocusControl = AraFirma
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object SpinKayitSayisi: TcxSpinEdit
        Left = 134
        Top = 77
        Properties.ImmediatePost = True
        TabOrder = 8
        Value = 200
        Width = 66
      end
      object cxLabel6: TcxLabel
        Left = 85
        Top = 79
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
      object LabelSonArananlar2: TcxLabel
        Tag = 4
        Left = 0
        Top = 27
        Cursor = crHandPoint
        HelpType = htKeyword
        HelpKeyword = 'K.DEGISTIRMETARIHI'
        Caption = 'Son Arananlar'
        FocusControl = AraFirma2
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelSIKArananlar2: TcxLabel
        Tag = 3
        Left = 0
        Top = 51
        Cursor = crHandPoint
        HelpType = htKeyword
        HelpKeyword = 'K.SAY'
        Caption = 'S'#305'k Arananlar'
        FocusControl = AraFirma2
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
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
        TabOrder = 5
        Width = 115
      end
      object EditUcret: TcxTextEdit
        Left = 77
        Top = 334
        TabOrder = 6
        Width = 60
      end
      object CheckPasifler2: TcxCheckBox
        Left = 77
        Top = 361
        Caption = 'Pasifleri de g'#246'ster'
        TabOrder = 8
        Transparent = True
        Width = 132
      end
      object LabelTumKayitlar2: TcxLabel
        Tag = 3
        Left = 0
        Top = 4
        Cursor = crHandPoint
        HelpType = htKeyword
        HelpKeyword = 'K.SAY'
        Caption = 'T'#252'm Kay'#305'tlar'
        FocusControl = AraFirma2
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboIl: TcxImageComboBox
        Left = 77
        Top = 253
        RepositoryItem = Tablo.Repiller
        Properties.Items = <>
        TabOrder = 10
        Width = 115
      end
      object ComboCinsiyet: TcxImageComboBox
        Left = 77
        Top = 120
        RepositoryItem = Tablo.RepIKCinsiyet
        Properties.Items = <>
        TabOrder = 11
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
        TabOrder = 17
        Width = 115
      end
      object ComboDepartman: TcxImageComboBox
        Left = 77
        Top = 199
        RepositoryItem = Tablo.RepCariBolum
        Properties.Items = <>
        TabOrder = 18
        Width = 115
      end
      object ComboGorev: TcxImageComboBox
        Left = 77
        Top = 226
        RepositoryItem = Tablo.RepCariGorev
        Properties.Items = <>
        TabOrder = 19
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
        TabOrder = 21
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
        TabOrder = 7
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
        TabOrder = 25
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
        TabOrder = 27
        Width = 115
      end
    end
  end
  object TabSK: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        ' select top 15 R.ID,R.FIRMA from KULLANICI_REHBER K inner join R' +
        'EHBER R on K.REHBERID=R.ID where KULID=5'
      ' order by K.DEGISTIRMETARIHI desc')
    Left = 223
    Top = 50
  end
  object DtsSK: TDataSource
    DataSet = TabSK
    Left = 174
    Top = 39
  end
end



