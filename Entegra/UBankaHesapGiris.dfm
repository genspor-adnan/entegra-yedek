object bankaHesapGirisdlg: TbankaHesapGirisdlg
  Left = 0
  Top = 0
  Caption = 'Banka Hesap H'#305'zl'#305' Giri'#351
  ClientHeight = 600
  ClientWidth = 1180
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 13
  object PanelUst: TPanel
    Left = 0
    Top = 0
    Width = 1180
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    Color = clSkyBlue
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      1180
      50)
    object btnHesapSec: TcxButton
      Left = 8
      Top = 11
      Width = 130
      Height = 28
      Caption = 'Hesap Se'#231
      TabOrder = 0
      OnClick = btnHesapSecClick
    end
    object btnMT940Al: TcxButton
      Left = 1042
      Top = 11
      Width = 130
      Height = 28
      Anchors = [akTop, akRight]
      Caption = 'MT940 '#304#231'eri Al'
      TabOrder = 1
      OnClick = btnMT940AlClick
    end
    object lblBanka: TcxLabel
      Left = 170
      Top = 4
      Caption = 'Banka : -'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblSube: TcxLabel
      Left = 170
      Top = 24
      Caption = #350'ube   : -'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblHesap: TcxLabel
      Left = 580
      Top = 4
      Caption = 'Hesap : -'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblHesapDoviz: TcxLabel
      Left = 580
      Top = 24
      Caption = 'P.Birimi : -'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -13
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object ButtonExcelAl: TcxButton
      Left = 906
      Top = 11
      Width = 130
      Height = 28
      Anchors = [akTop, akRight]
      Caption = 'Excel '#304#231'eri Al'
      TabOrder = 6
      OnClick = ButtonExcelAlClick
    end
  end
  object PanelGiris: TPanel
    Left = 0
    Top = 50
    Width = 1180
    Height = 97
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lbl_Tarih: TcxLabel
      Left = 8
      Top = 4
      Caption = 'Tarih'
    end
    object cxDateEdit1: TcxDateEdit
      Left = 8
      Top = 22
      EditValue = 0d
      Properties.Kind = ckDateTime
      TabOrder = 0
      Width = 145
    end
    object lbl_Tur: TcxLabel
      Left = 160
      Top = 4
      Caption = 'T'#252'r'
    end
    object cbTur: TcxImageComboBox
      Left = 160
      Top = 22
      Properties.DropDownRows = 16
      Properties.Items = <>
      Properties.OnChange = cbTurPropertiesChange
      TabOrder = 1
      Width = 200
    end
    object lbl_Secim: TcxLabel
      Left = 366
      Top = 4
      Caption = 'Se'#231'im'
    end
    object beSecim: TcxButtonEdit
      Left = 366
      Top = 22
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = beSecimPropertiesButtonClick
      TabOrder = 2
      Width = 250
    end
    object lbl_Tutar: TcxLabel
      Left = 622
      Top = 4
      Caption = 'Tutar'
    end
    object ceTutar: TcxCurrencyEdit
      Left = 622
      Top = 22
      Properties.DecimalPlaces = 2
      Properties.DisplayFormat = '#,##0.00'
      Properties.OnChange = ceTutarPropertiesChange
      TabOrder = 3
      Width = 90
    end
    object lbl_Masraf: TcxLabel
      Left = 718
      Top = 4
      Caption = 'Banka Komisyonu'
    end
    object ceKomisyon: TcxCurrencyEdit
      Left = 718
      Top = 22
      Properties.DecimalPlaces = 2
      Properties.DisplayFormat = '#,##0.00'
      TabOrder = 4
      Width = 93
    end
    object lbl_Aciklama: TcxLabel
      Left = 8
      Top = 48
      Caption = 'A'#231#305'klama'
    end
    object teAciklama: TcxTextEdit
      Left = 8
      Top = 66
      TabOrder = 5
      Width = 240
    end
    object lbl_MasrafKalemi: TcxLabel
      Left = 254
      Top = 48
      Caption = 'Masraf Kalemi'
      Visible = False
    end
    object beMasrafKalemi: TcxButtonEdit
      Left = 254
      Top = 66
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = beMasrafKalemiPropertiesButtonClick
      TabOrder = 17
      Visible = False
      Width = 150
    end
    object lbl_BelgeNo: TcxLabel
      Left = 414
      Top = 48
      Caption = 'Belge No'
    end
    object teBelgeNo: TcxTextEdit
      Left = 414
      Top = 66
      TabOrder = 16
      Width = 200
    end
    object chkKarsiligi: TcxCheckBox
      Left = 817
      Top = 22
      Caption = 'Kar'#351#305'l'#305#287#305
      Properties.OnChange = chkKarsiligiClick
      TabOrder = 6
    end
    object chkEkstrede: TcxCheckBox
      Left = 622
      Top = 66
      Caption = 'Ekstrede Kullan'
      TabOrder = 7
    end
    object PanelKarsiligiSag: TPanel
      Left = 880
      Top = 0
      Width = 300
      Height = 97
      Align = alRight
      BevelOuter = bvNone
      Color = clMoneyGreen
      ParentBackground = False
      TabOrder = 8
      Visible = False
      object lbl_DovizTipi: TcxLabel
        Left = 8
        Top = 4
        Caption = 'D'#246'viz Tipi'
      end
      object cbDovizTipi: TcxImageComboBox
        Left = 8
        Top = 22
        Properties.Items = <>
        Properties.OnChange = cbDovizTipiPropertiesChange
        TabOrder = 0
        Width = 49
      end
      object lbl_Kur: TcxLabel
        Left = 63
        Top = 5
        Caption = 'Kur'
      end
      object ceKur: TcxCurrencyEdit
        Left = 63
        Top = 23
        Properties.DecimalPlaces = 4
        Properties.DisplayFormat = '#,##0.0000'
        Properties.OnChange = ceKurPropertiesChange
        TabOrder = 1
        Width = 66
      end
      object lbl_DovizTutar: TcxLabel
        Left = 8
        Top = 50
        Caption = 'D'#246'viz Tutar'
      end
      object ceDovizTutar: TcxCurrencyEdit
        Left = 8
        Top = 68
        Properties.DecimalPlaces = 2
        Properties.DisplayFormat = '#,##0.00'
        Properties.ReadOnly = True
        Style.Color = clBtnFace
        TabOrder = 2
        Width = 121
      end
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 147
    Width = 1180
    Height = 408
    Align = alClient
    TabOrder = 3
    LookAndFeel.ScrollbarMode = sbmClassic
    object cxGrid1DBTableView1: TcxGridDBTableView
      PopupMenu = PopupMenu1
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCellClick = cxGrid1DBTableView1CellClick
      OnEditing = cxGrid1DBTableView1Editing
      OnFocusedRecordChanged = cxGrid1DBTableView1FocusedRecordChanged
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = 'Kay'#305't: 0'
          Kind = skCount
          Column = cxGrid1DBTableView1TARIH
        end>
      DataController.Summary.SummaryGroups = <>
      Filtering.ColumnAddValueItems = False
      Filtering.ColumnMRUItemsList = False
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      Styles.OnGetContentStyle = cxGrid1DBTableView1StylesGetContentStyle
      object cxGrid1DBTableView1ONAY: TcxGridDBColumn
        Caption = 'Onay'
        DataBinding.FieldName = 'ONAY'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.DisplayChecked = ' '
        Properties.DisplayUnchecked = ' '
        Properties.DisplayGrayed = ' '
        Visible = False
        Width = 50
      end
      object cxGrid1DBTableView1TARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.Kind = ckDateTime
        Options.Editing = False
        Width = 120
      end
      object cxGrid1DBTableView1TURID: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TURID'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        Properties.OnChange = cxGrid1DBTableView1TURIDPropertiesChange
        Width = 160
      end
      object cxGrid1DBTableView1TUR: TcxGridDBColumn
        Caption = 'T'#252'r Ad'#305
        DataBinding.FieldName = 'TUR'
        Visible = False
        Options.Editing = False
        Width = 130
      end
      object cxGrid1DBTableView1SECIMID: TcxGridDBColumn
        Caption = 'Se'#231'im Id'
        DataBinding.FieldName = 'SECIMID'
        Visible = False
        Options.Editing = False
        Width = 60
      end
      object cxGrid1DBTableView1SECIM: TcxGridDBColumn
        Caption = 'Se'#231'im'
        DataBinding.FieldName = 'SECIM'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = cxGrid1DBTableView1SECIMPropertiesButtonClick
        Width = 170
      end
      object cxGrid1DBTableView1TUTAR: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTAR'
        Options.Editing = False
        Width = 90
      end
      object cxGrid1DBTableView1PBIRIMI: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'PBIRIMI'
        Options.Editing = False
        Width = 55
      end
      object cxGrid1DBTableView1KOMISYON: TcxGridDBColumn
        Caption = 'Banka Komisyonu'
        DataBinding.FieldName = 'KOMISYON'
        Options.Editing = False
        Width = 70
      end
      object cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        Options.Editing = False
        Width = 180
      end
      object cxGrid1DBTableView1BELGENO: TcxGridDBColumn
        Caption = 'Belge No'
        DataBinding.FieldName = 'BELGENO'
        Options.Editing = False
        Width = 100
      end
      object cxGrid1DBTableView1KARSILIGI: TcxGridDBColumn
        Caption = 'Kar'#351#305'l'#305#287#305
        DataBinding.FieldName = 'KARSILIGI'
        Options.Editing = False
        Width = 60
      end
      object cxGrid1DBTableView1DOVIZ_TUTARI: TcxGridDBColumn
        Caption = 'D'#246'viz Tutar'#305
        DataBinding.FieldName = 'DOVIZ_TUTARI'
        Options.Editing = False
        Width = 90
      end
      object cxGrid1DBTableView1DOVIZ_TIPI: TcxGridDBColumn
        Caption = 'D'#246'viz Tipi'
        DataBinding.FieldName = 'DOVIZ_TIPI'
        Options.Editing = False
        Width = 60
      end
      object cxGrid1DBTableView1KUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        Options.Editing = False
        Width = 70
      end
      object cxGrid1DBTableView1EKSTREDE_KULLAN: TcxGridDBColumn
        Caption = 'Ekstrede Kullan'
        DataBinding.FieldName = 'EKSTREDE_KULLAN'
        Options.Editing = False
        Width = 95
      end
      object cxGrid1DBTableView1MASRAFID: TcxGridDBColumn
        Caption = 'Masraf/Gelir Id'
        DataBinding.FieldName = 'MASRAFID'
        Visible = False
        Options.Editing = False
        Width = 80
      end
      object cxGrid1DBTableView1MASRAFKALEMI: TcxGridDBColumn
        Caption = 'Masraf/Gelir Kalemi'
        DataBinding.FieldName = 'MASRAFKALEMI'
        Options.Editing = False
        Width = 160
      end
      object cxGrid1DBTableView1CONFIDENCE: TcxGridDBColumn
        Caption = 'G'#252'ven'
        DataBinding.FieldName = 'CONFIDENCE'
        Visible = False
        Options.Editing = False
        Width = 50
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object PanelAlt: TPanel
    Left = 0
    Top = 555
    Width = 1180
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnF5Kaydet: TcxButton
      Left = 8
      Top = 6
      Width = 160
      Height = 33
      Caption = 'F5 Kaydet'
      TabOrder = 0
      OnClick = btnF5KaydetClick
    end
    object btnF8Devam: TcxButton
      Left = 174
      Top = 6
      Width = 160
      Height = 33
      Caption = 'F8 Giri'#351' Devam'
      TabOrder = 1
      OnClick = btnF8DevamClick
    end
  end
  object dxMemData1: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 40
    Top = 160
    object dxMemData1TARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object dxMemData1TURID: TSmallintField
      FieldName = 'TURID'
    end
    object dxMemData1TUR: TStringField
      FieldName = 'TUR'
      Size = 50
    end
    object dxMemData1SECIMID: TIntegerField
      FieldName = 'SECIMID'
    end
    object dxMemData1SECIM: TStringField
      FieldName = 'SECIM'
      Size = 150
    end
    object dxMemData1TUTAR: TCurrencyField
      FieldName = 'TUTAR'
      DisplayFormat = '#,##0.00'
    end
    object dxMemData1PBIRIMI: TStringField
      FieldName = 'PBIRIMI'
      Size = 5
    end
    object dxMemData1KOMISYON: TCurrencyField
      FieldName = 'KOMISYON'
      DisplayFormat = '#,##0.00'
    end
    object dxMemData1ACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      Size = 150
    end
    object dxMemData1BELGENO: TStringField
      FieldName = 'BELGENO'
      Size = 30
    end
    object dxMemData1IBAN: TStringField
      FieldName = 'IBAN'
      Size = 34
    end
    object dxMemData1HAMAD: TStringField
      FieldName = 'HAMAD'
      Size = 150
    end
    object dxMemData1ICERIALINDI: TBooleanField
      FieldName = 'ICERIALINDI'
    end
    object dxMemData1KARSILIGI: TBooleanField
      FieldName = 'KARSILIGI'
    end
    object dxMemData1DOVIZ_TUTARI: TCurrencyField
      FieldName = 'DOVIZ_TUTARI'
      DisplayFormat = '#,##0.00'
    end
    object dxMemData1DOVIZ_TIPI: TStringField
      FieldName = 'DOVIZ_TIPI'
      Size = 5
    end
    object dxMemData1KUR: TCurrencyField
      FieldName = 'KUR'
      DisplayFormat = '#,##0.0000'
    end
    object dxMemData1EKSTREDE_KULLAN: TBooleanField
      FieldName = 'EKSTREDE_KULLAN'
    end
    object dxMemData1MASRAFID: TIntegerField
      FieldName = 'MASRAFID'
    end
    object dxMemData1MASRAFKALEMI: TStringField
      FieldName = 'MASRAFKALEMI'
      Size = 150
    end
    object dxMemData1CONFIDENCE: TIntegerField
      FieldName = 'CONFIDENCE'
    end
    object dxMemData1ONAY: TBooleanField
      FieldName = 'ONAY'
    end
    object dxMemData1KREDIDETAYID: TIntegerField
      FieldName = 'KREDIDETAYID'
    end
  end
  object DataSource1: TDataSource
    DataSet = dxMemData1
    Left = 48
    Top = 232
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 320
    Top = 184
    object miSatirSil: TMenuItem
      Caption = 'Sat'#305'r Sil'
      ImageIndex = 1
      OnClick = miSatirSilClick
    end
    object miBenzerlerineUygula: TMenuItem
      Caption = 'Benzerlerine Uygula'
      ImageIndex = 15
      OnClick = miBenzerlerineUygulaClick
    end
  end
  object Od1: TOpenDialog
    DefaultExt = 'csv'
    Filter = 
      'Banka Hareketleri (*.csv;*.xls)|*.csv;*.xls|CSV (*.csv)|*.csv|Ex' +
      'cel 97-2003 (*.xls)|*.xls'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 544
    Top = 192
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 528
    Top = 304
    PixelsPerInch = 96
    object StyleYesil: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 13369292
      TextColor = clBlack
    end
    object StyleSari: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 11531519
      TextColor = clBlack
    end
    object StyleKirmizi: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = 13556476
      TextColor = clBlack
    end
  end
end
