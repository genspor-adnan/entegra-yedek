object DBSDlg: TDBSDlg
  Left = 0
  Top = 0
  Width = 741
  Height = 467
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  ExplicitWidth = 451
  ExplicitHeight = 304
  object Label8: TLabel
    Left = 365
    Top = 228
    Width = 43
    Height = 16
    Caption = #214'zel Kod'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Label9: TcxLabel
    Left = 365
    Top = 251
    Caption = 'Yetki Kodu'
    ParentFont = False
    Transparent = True
  end
  object lblrisk: TcxLabel
    Left = 0
    Top = 228
    Caption = 'Kredi Limiti'
    ParentFont = False
    Transparent = True
  end
  object Label3: TcxLabel
    Left = 365
    Top = 276
    Caption = 'A'#231#305'klama'
    ParentFont = False
    Transparent = True
  end
  object Label7: TcxLabel
    Left = 365
    Top = 69
    Caption = 'Durum'
    Transparent = True
  end
  object Label18: TcxLabel
    Left = 0
    Top = 251
    Caption = 'S'#246'zle'#351'me Tarihi'
    ParentFont = False
    Transparent = True
  end
  object Label17: TcxLabel
    Left = 0
    Top = 97
    Caption = 'Bor'#231'lu Cari Hesap Kodu'
    ParentFont = False
    Transparent = True
  end
  object Label14: TcxLabel
    Left = 365
    Top = 97
    Caption = 'Bor'#231'lu  '#220'nvan'#305
    ParentFont = False
    Transparent = True
  end
  object Label16: TcxLabel
    Left = 365
    Top = 122
    Caption = 'Cari '#220'nvan'#305
    ParentFont = False
    Transparent = True
  end
  object LabelIlgiliKod: TcxLabel
    Left = 0
    Top = 122
    Caption = 'Alacakl'#305' Cari Hesap Kodu'
    ParentFont = False
    Transparent = True
  end
  object Label5: TcxLabel
    Left = 0
    Top = 276
    Caption = #214'deme Tarihi'
    ParentFont = False
    Transparent = True
  end
  object LabelHesapAdi: TcxLabel
    Left = 365
    Top = 161
    Caption = 'Hesap Ad'#305' (Ticari)'
    ParentFont = False
    Transparent = True
  end
  object LabelHesapKodu: TcxLabel
    Left = 0
    Top = 161
    Caption = 'Hesap Kodu (Ticari)'
    ParentFont = False
    Transparent = True
  end
  object Label1: TcxLabel
    Left = 365
    Top = 184
    Caption = 'Hesap Ad'#305' (Kredi)'
    ParentFont = False
    Transparent = True
  end
  object Label2: TcxLabel
    Left = 0
    Top = 187
    Caption = 'Hesap Kodu (Kredi)'
    ParentFont = False
    Transparent = True
  end
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 735
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 83
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    ExplicitWidth = 445
    ExplicitHeight = 62
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Ekle'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 83
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 166
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 249
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton4: TToolButton
      Left = 332
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 340
      Top = 0
      Caption = 'YaziciYaz'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
    end
    object ToolButton1: TToolButton
      Left = 423
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 431
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
    object ToolButton2: TToolButton
      Left = 514
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 19
      Style = tbsSeparator
    end
  end
  object EditOZELKOD: TcxDBTextEdit
    Left = 485
    Top = 227
    DataBinding.DataField = 'OZELKOD'
    DataBinding.DataSource = DtsDBS
    TabOrder = 1
    Width = 78
  end
  object EditYETKIKODU: TcxDBTextEdit
    Left = 485
    Top = 250
    DataBinding.DataField = 'YETKIKODU'
    DataBinding.DataSource = DtsDBS
    TabOrder = 2
    Width = 79
  end
  object EditLIMITI: TcxDBCurrencyEdit
    Left = 150
    Top = 226
    DataBinding.DataField = 'LIMITI'
    DataBinding.DataSource = DtsDBS
    Properties.DisplayFormat = ',0.00;-,0.00'
    Properties.UseDisplayFormatWhenEditing = True
    Properties.UseLeftAlignmentOnEditing = False
    Properties.UseThousandSeparator = True
    Style.BorderStyle = ebs3D
    TabOrder = 3
    Width = 121
  end
  object EditNOTLAR: TcxDBTextEdit
    Left = 485
    Top = 275
    DataBinding.DataField = 'NOTLAR'
    DataBinding.DataSource = DtsDBS
    TabOrder = 4
    Width = 170
  end
  object ComboDURUM: TcxDBImageComboBox
    Left = 485
    Top = 67
    TabStop = False
    RepositoryItem = Tablo.RepAktifPasif
    DataBinding.DataField = 'DURUM'
    DataBinding.DataSource = DtsDBS
    Properties.Items = <>
    TabOrder = 5
    Width = 170
  end
  object DateSOZLESME_TARIHI: TcxDBDateEdit
    Left = 150
    Top = 250
    DataBinding.DataField = 'SOZLESME_TARIHI'
    DataBinding.DataSource = DtsDBS
    TabOrder = 6
    Width = 121
  end
  object EditBORCLUKOD: TcxButtonEdit
    Left = 150
    Top = 96
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
    Properties.OnButtonClick = EditBORCLUKODPropertiesButtonClick
    TabOrder = 7
    Width = 121
  end
  object EditBORCLUUNVAN: TcxTextEdit
    Left = 485
    Top = 96
    ParentColor = True
    TabOrder = 8
    Width = 170
  end
  object EditCARIUNVAN: TcxTextEdit
    Left = 485
    Top = 121
    ParentColor = True
    TabOrder = 9
    Width = 170
  end
  object BORCLUREHBERID: TcxDBTextEdit
    Left = 277
    Top = 96
    DataBinding.DataField = 'BORCLUREHBERID'
    DataBinding.DataSource = DtsDBS
    ParentColor = True
    TabOrder = 10
    Visible = False
    Width = 25
  end
  object EditAlacakCARIKOD: TcxButtonEdit
    Left = 150
    Top = 121
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
    Properties.OnButtonClick = EditAlacakCARIKODPropertiesButtonClick
    TabOrder = 11
    Width = 121
  end
  object EditREHBERID: TcxDBTextEdit
    Left = 277
    Top = 124
    DataBinding.DataField = 'REHBERID'
    DataBinding.DataSource = DtsDBS
    ParentColor = True
    TabOrder = 12
    Visible = False
    Width = 25
  end
  object EditHesapAdiTicari: TcxTextEdit
    Left = 485
    Top = 160
    TabStop = False
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 13
    Width = 170
  end
  object EditHESAPID: TcxDBTextEdit
    Left = 277
    Top = 160
    TabStop = False
    DataBinding.DataField = 'BANKA_ID_TICARI'
    DataBinding.DataSource = DtsDBS
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 14
    Visible = False
    Width = 28
  end
  object EditHESAPKODUTicari: TcxButtonEdit
    Left = 150
    Top = 160
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
    Properties.OnButtonClick = EditHESAPKODUTicariPropertiesButtonClick
    TabOrder = 15
    Width = 121
  end
  object EditHesapAdiKredi: TcxTextEdit
    Left = 485
    Top = 186
    TabStop = False
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 16
    Width = 170
  end
  object cxDBTextEdit1: TcxDBTextEdit
    Left = 277
    Top = 186
    TabStop = False
    DataBinding.DataField = 'BANKA_ID_KREDI'
    DataBinding.DataSource = DtsDBS
    ParentColor = True
    Properties.ReadOnly = True
    TabOrder = 17
    Visible = False
    Width = 28
  end
  object EditHESAPKODUKredi: TcxButtonEdit
    Left = 150
    Top = 186
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
    Properties.OnButtonClick = EditHESAPKODUKrediPropertiesButtonClick
    TabOrder = 18
    Width = 121
  end
  object LblSube: TcxLabel
    Left = 365
    Top = 44
    Caption = #350'ube'
    Transparent = True
  end
  object ComboSube: TcxDBImageComboBox
    Left = 485
    Top = 42
    RepositoryItem = Tablo.RepSubelerOrtak
    DataBinding.DataField = 'SUBEID'
    DataBinding.DataSource = DtsDBS
    Properties.Alignment.Horz = taLeftJustify
    Properties.Items = <
      item
        Description = 'Yeni'
        ImageIndex = 0
        Value = 4
      end
      item
        Description = 'Zimmet'
        Value = 1
      end
      item
        Description = 'Kay'#305'p'
        Value = 2
      end
      item
        Description = 'Hurda'
        Value = 3
      end
      item
        Description = 'Transfer'
        Value = 5
      end
      item
        Description = 'Bo'#351
        Value = 9
      end
      item
        Description = 'Serviste'
        Value = 6
      end
      item
        Description = 'Servis '#304'ade'
        Value = 7
      end>
    StyleDisabled.Color = clWhite
    StyleDisabled.TextColor = clBlack
    TabOrder = 34
    Width = 170
  end
  object DateOdemeTarihi: TcxDBDateEdit
    Left = 150
    Top = 275
    DataBinding.DataField = 'ODEME_TARIHI'
    DataBinding.DataSource = DtsDBS
    TabOrder = 35
    Width = 121
  end
  object TabDBS: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabDBSAfterScroll
    OnNewRecord = TabDBSNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from DBS ')
    Left = 140
    Top = 51
  end
  object DtsDBS: TDataSource
    DataSet = TabDBS
    OnStateChange = DtsDBSStateChange
    Left = 103
    Top = 45
  end
  object PopupMenuYaz: TPopupMenu
    Left = 32
    Top = 47
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
end


