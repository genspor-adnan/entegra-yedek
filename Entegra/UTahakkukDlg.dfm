object TahakkukDlg: TTahakkukDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Tahakkuk Ekran'#305
  ClientHeight = 341
  ClientWidth = 684
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object UstPanel: TJvPanel
    Left = 0
    Top = 0
    Width = 684
    Height = 57
    FlatBorder = True
    Align = alTop
    BorderWidth = 1
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object LabelAd: TcxLabel
      Left = 166
      Top = 2
      Cursor = crHandPoint
      ParentCustomHint = False
      Align = alRight
      AutoSize = False
      Caption = 'Ad'#305
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clRed
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.Shadow = False
      Style.IsFontAssigned = True
      Properties.LabelEffect = cxleCool
      Properties.LabelStyle = cxlsRaised
      Properties.WordWrap = True
      Transparent = True
      OnClick = LabelAdClick
      Height = 53
      Width = 407
    end
    object ToolBar1: TToolBar
      Left = 573
      Top = 2
      Width = 109
      Height = 53
      Margins.Bottom = 0
      Align = alRight
      AutoSize = True
      ButtonHeight = 54
      ButtonWidth = 107
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
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      GradientEndColor = 11776947
      GradientStartColor = 14540253
      HotTrackColor = 65408
      Images = Tablo.PngImageListTicari
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 1
      Transparent = True
      object YaziciYaz: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 7
        ImageName = 'PngImage7'
      end
    end
    object Panel1: TPanel
      Left = 2
      Top = 2
      Width = 164
      Height = 53
      Align = alClient
      TabOrder = 2
      object LabelKod: TcxLabel
        Left = 1
        Top = 1
        Cursor = crHandPoint
        Align = alTop
        Caption = 'Kodu'
        DragCursor = crDefault
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -13
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
      end
      object Label1: TcxLabel
        Left = 1
        Top = 23
        Align = alClient
        Caption = '---'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
  end
  object OrtaPanel: TPanel
    Left = 0
    Top = 57
    Width = 684
    Height = 243
    Align = alClient
    TabOrder = 1
    object Label15: TcxLabel
      Left = 5
      Top = 74
      Caption = 'A'#231#305'klama'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelMasrafMerkezi: TcxLabel
      Left = 5
      Top = 97
      Caption = 'Masraf Kalemi'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel3: TcxLabel
      Left = 3
      Top = 14
      Caption = 'Tutar'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditTutar: TcxDBCurrencyEdit
      Left = 112
      Top = 13
      DataBinding.DataField = 'FATURA_TUTARI'
      DataBinding.DataSource = DtsFatBaslik
      Properties.DisplayFormat = ',0.00 ;-,0.00 '
      Properties.UseDisplayFormatWhenEditing = True
      Properties.UseThousandSeparator = True
      TabOrder = 3
      OnKeyUp = EditTutarKeyUp
      Width = 68
    end
    object EditMM: TcxButtonEdit
      Left = 114
      Top = 97
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
      Properties.OnButtonClick = ComboBoxTahAciklamaPropertiesButtonClick
      TabOrder = 4
      Width = 241
    end
    object LabelSRM: TcxLabel
      Left = 5
      Top = 120
      Caption = 'Srm. Mrk'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditSRMMerkezi: TcxButtonEdit
      Left = 114
      Top = 120
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
      Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
      TabOrder = 6
      Width = 241
    end
    object EditAciklama: TcxDBTextEdit
      Left = 114
      Top = 74
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = DtsFatBaslik
      TabOrder = 7
      Width = 241
    end
    object BeditBagliGorev: TcxButtonEdit
      Left = 114
      Top = 188
      ParentShowHint = False
      Properties.Buttons = <
        item
          Default = True
          Hint = 'Ekle'
          Kind = bkEllipsis
        end
        item
          Caption = '-'
          Hint = 'Sil'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = BeditBagliGorevPropertiesButtonClick
      ShowHint = True
      TabOrder = 8
      Width = 366
    end
    object LabelProje: TcxLabel
      Left = 5
      Top = 165
      Caption = 'Proje Kodu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelAktivite: TcxLabel
      Left = 5
      Top = 188
      Caption = 'Aktivite Konusu'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object EditProje: TcxButtonEdit
      Left = 114
      Top = 165
      ParentShowHint = False
      Properties.Buttons = <
        item
          Caption = '++'
          Default = True
          Hint = 'T'#252'm proje listesi'
          Kind = bkText
        end
        item
          Caption = '+'
          Hint = 'Bu carinin proje listesi'
          Kind = bkText
        end
        item
          Caption = '-'
          Hint = 'Sil'
          Kind = bkText
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditProjePropertiesButtonClick
      ShowHint = True
      TabOrder = 11
      OnDblClick = EditProjeDblClick
      Width = 241
    end
    object cbIrsaliyeli: TcxDBCheckBox
      Left = 355
      Top = 74
      DataBinding.DataField = 'R'
      DataBinding.DataSource = DtsFatBaslik
      Properties.ImmediatePost = True
      Properties.NullStyle = nssUnchecked
      TabOrder = 12
    end
    object LabelKarsiligi: TcxLabel
      Left = 7
      Top = 40
      Cursor = crHandPoint
      Caption = 'Kar'#351#305'l'#305#287#305
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clNavy
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.HotTrack = False
      Style.TextColor = clNavy
      Style.TextStyle = [fsUnderline]
      Style.IsFontAssigned = True
      Transparent = True
      OnClick = LabelKarsiligiClick
    end
    object ComboSube: TcxDBImageComboBox
      Left = 538
      Top = 13
      RepositoryItem = Tablo.RepSubeler
      DataBinding.DataField = 'SUBEID'
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <
        item
          Description = 'Yap'#305'lmad'#305
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'K'#305'smi'
          Value = 1
        end
        item
          Description = #304'ptal'
          Value = 6
        end
        item
          Description = 'Tamamland'#305
          Value = 9
        end>
      Properties.ReadOnly = True
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 15
      Width = 120
    end
    object LblSube: TcxLabel
      Left = 484
      Top = 14
      Caption = #350'ube'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel1: TcxLabel
      Left = 484
      Top = 82
      Caption = 'Belge No'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBTextEdit1: TcxDBTextEdit
      Left = 538
      Top = 82
      DataBinding.DataField = 'FATURANO'
      DataBinding.DataSource = DtsFatBaslik
      TabOrder = 18
      Width = 120
    end
    object EditTarih: TcxDBDateEdit
      Left = 538
      Top = 106
      DataBinding.DataField = 'FATURATARIH'
      DataBinding.DataSource = DtsFatBaslik
      Properties.Kind = ckDateTime
      TabOrder = 19
      Width = 120
    end
    object LabelTarih: TcxLabel
      Left = 484
      Top = 106
      Caption = 'Tarih'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 484
      Top = 130
      Caption = 'Vade'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
    end
    object EditVade: TcxDBCurrencyEdit
      Left = 538
      Top = 130
      DataBinding.DataField = 'VADE'
      DataBinding.DataSource = DtsFatBaslik
      Properties.DisplayFormat = '0;-0'
      Properties.MaxValue = 255.000000000000000000
      TabOrder = 22
      Width = 120
    end
    object EditDemirbas: TcxButtonEdit
      Left = 114
      Top = 143
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
      Properties.OnButtonClick = EditDemirbasPropertiesButtonClick
      TabOrder = 23
      Width = 241
    end
    object lblDemirbas: TcxLabel
      Left = 5
      Top = 143
      Caption = 'Demirba'#351
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object SqlMemoMasrafKalemi: TMemo
      Left = 497
      Top = 184
      Width = 436
      Height = 30
      Lines.Strings = (
        
          '  select ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'#39' '#39','#39#39'),' +
          'CHARINDEX'
        '('#39'.'#39',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'#39' '#39','#39#39')'
        '    )-(CHARINDEX('#39'.'#39',REVERSE(REPLACE(KOD,'#39' '#39','#39#39')),1)-1))),'
        
          ' M.ID,  M.KOD, M.AD,PROJEID,MASRAFID,SUBEID=-1,DURUM=1, GELIRMI=' +
          '0, '
        'BARKOD=0'
        
          ' from PROJEBUTCE PB inner join MASRAFGELIR M on M.ID = PB.MASRAF' +
          'ID ')
      TabOrder = 25
      Visible = False
    end
    object LabelCoklu: TcxLabel
      Left = 361
      Top = 168
      Cursor = crHandPoint
      Caption = #199'oklu Proje/Masraf'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clNavy
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.HotTrack = False
      Style.TextColor = clNavy
      Style.TextStyle = [fsUnderline]
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
      OnClick = LabelCokluClick
    end
    object PanelKarsilik: TPanel
      Left = 111
      Top = 40
      Width = 409
      Height = 27
      Align = alCustom
      BevelEdges = []
      BevelOuter = bvNone
      TabOrder = 13
      Visible = False
      object EditDovTutar: TcxDBCurrencyEdit
        Left = 2
        Top = 0
        DataBinding.DataField = 'DOVIZ_TUTARI'
        DataBinding.DataSource = DtsFatBaslik
        Properties.DisplayFormat = ',0.00 ;-,0.00 '
        TabOrder = 0
        OnKeyUp = EditDovTutarKeyUp
        Width = 68
      end
      object EditKulKur: TcxDBCurrencyEdit
        Left = 134
        Top = -1
        TabStop = False
        RepositoryItem = Tablo.RepCurrencyDovizKuru
        DataBinding.DataField = 'DOVIZKUR'
        DataBinding.DataSource = DtsFatBaslik
        ParentFont = False
        Properties.DisplayFormat = ',0.0000;(,0.0000)'
        Style.Color = clInactiveCaption
        TabOrder = 1
        OnKeyUp = EditKulKurKeyUp
        Width = 49
      end
      object ComboDovKur: TcxDBComboBox
        Left = 74
        Top = 0
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        DataBinding.DataField = 'DOVIZ_CINSI'
        DataBinding.DataSource = DtsFatBaslik
        Properties.DropDownListStyle = lsFixedList
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.ReadOnly = False
        Properties.OnCloseUp = ComboKurPropertiesCloseUp
        TabOrder = 2
        Width = 52
      end
      object CheckEKSTREDEKULLAN: TcxDBCheckBox
        Left = 191
        Top = 3
        Caption = 'Ekstrede bunu kullan'
        DataBinding.DataField = 'EKSTREDEKULLAN'
        DataBinding.DataSource = DtsFatBaslik
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        Style.TransparentBorder = False
        TabOrder = 3
        Transparent = True
      end
    end
    object ComboKur: TcxDBComboBox
      Left = 186
      Top = 13
      RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
      DataBinding.DataField = 'KUR'
      DataBinding.DataSource = DtsFatBaslik
      Properties.DropDownListStyle = lsFixedList
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.ReadOnly = False
      Properties.OnCloseUp = ComboKurPropertiesCloseUp
      TabOrder = 27
      Width = 52
    end
  end
  object AltPanel: TPanel
    Left = 0
    Top = 300
    Width = 684
    Height = 41
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      684
      41)
    object iptalButton: TButton
      Left = 568
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #304'ptal'
      ModalResult = 2
      TabOrder = 0
      OnClick = iptalButtonClick
    end
    object tamamButton: TButton
      Left = 487
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Kaydet'
      Default = True
      TabOrder = 1
      OnClick = tamamButtonClick
    end
    object KaydetveOdemeTus: TButton
      Tag = 9
      Left = 243
      Top = 9
      Width = 129
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Kaydet ve '#214'deme'
      Default = True
      TabOrder = 2
      OnClick = KaydetveOdemeTusClick
    end
  end
  object TabFatBaslik: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabFatBaslikAfterOpen
    BeforeEdit = TabFatBaslikBeforeEdit
    BeforePost = TabFatBaslikBeforePost
    AfterPost = TabFatBaslikAfterPost
    OnNewRecord = TabFatBaslikNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT * ,'
      'KOD= (select MG.KOD from MASRAFGELIR MG where MG.ID=F.MASRAFID),'
      'AD = (select MG.AD from MASRAFGELIR MG where MG.ID=F.MASRAFID),'
      
        'PROJEKODU=(Select top 1 P.PROJEKODU from PROJELER P Where P.ID=F' +
        '.PROJEID),'
      
        'YAZIYLATOPLAM=( dbo.fn_ParaTextOlarakTumDiller(F.FATURA_TUTARI,'#39 +
        'TL'#39','#39'Kuru'#351#39',0,F.DIL))'
      'FROM FATBASLIK F'
      'WHERE ID = :PID'
      '')
    Left = 293
    Top = 65533
  end
  object DtsFatBaslik: TDataSource
    DataSet = TabFatBaslik
    Left = 369
    Top = 6
  end
  object PopupMenuYaz: TPopupMenu
    Left = 493
    Top = 10
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YaziciyaYazdirMenu: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
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
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'FATBASLIK'
    CloseDataSource = False
    DataSet = TabFatBaslik
    BCDToCurrency = False
    DataSetOptions = []
    Left = 338
    Top = 161
  end
end
