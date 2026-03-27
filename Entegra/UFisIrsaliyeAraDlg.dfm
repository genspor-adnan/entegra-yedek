object FisIrsaliyeAraDlg: TFisIrsaliyeAraDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Fi'#351' - '#304'rsaliye Arama'
  ClientHeight = 587
  ClientWidth = 757
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label3: TLabel
    Left = 32
    Top = 296
    Width = 32
    Height = 16
    Caption = 'Label3'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 757
    Height = 41
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 14
      Width = 46
      Height = 16
      Caption = 'Ba'#351'lang'#305#231
      Transparent = True
    end
    object Label2: TLabel
      Left = 224
      Top = 14
      Width = 22
      Height = 16
      Caption = 'Biti'#351
      Transparent = True
    end
    object lblSeciliKayit: TLabel
      Left = 5
      Top = 24
      Width = 6
      Height = 16
      Caption = '0'
      Transparent = True
    end
    object dateBaslangic: TcxDateEdit
      Left = 66
      Top = 12
      Properties.OnCloseUp = dateBitisPropertiesCloseUp
      TabOrder = 0
      Width = 121
    end
    object dateBitis: TcxDateEdit
      Left = 258
      Top = 12
      Properties.OnCloseUp = dateBitisPropertiesCloseUp
      TabOrder = 1
      Width = 121
    end
  end
  object GridFat: TcxGrid
    Left = 0
    Top = 222
    Width = 757
    Height = 162
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'LondonLiquidSky'
    object GridFatDBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsFatura
      DataController.KeyFieldNames = 'ID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsSelection.HideSelection = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = GridFatDBTableView1StylesGetContentStyle
      Styles.Indicator = AnaForm.cxStyle1
      object clmSec: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.ValueType = 'Boolean'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        Width = 29
      end
      object GridFatDBTableView1TUR: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TUR'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        Options.Editing = False
      end
      object GridFatDBTableView1KOD1: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Alignment.Horz = taLeftJustify
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = False
        Options.Editing = False
        Width = 53
      end
      object GridFatDBTableView1ACIKLAMA1: TcxGridDBColumn
        Caption = 'Ad'
        DataBinding.FieldName = 'AD'
        Options.Editing = False
        Width = 228
      end
      object GridFatDBTableView1ADET1: TcxGridDBColumn
        Caption = 'Adet'
        DataBinding.FieldName = 'ADET'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ReadOnly = False
        Options.Editing = False
        Width = 35
      end
      object GridFatDBTableView1BIRIM1: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'BIRIM'
        RepositoryItem = Tablo.repStokAnaBirim
        Options.Editing = False
        Width = 42
      end
      object GridFatDBTableView1Column1: TcxGridDBColumn
        Caption = 'Bekleyen Miktar'
        DataBinding.FieldName = 'BEKLEYENMIKTAR'
        Options.Editing = False
        Width = 75
      end
      object GridFatDBTableView1BIRIMFIYAT1: TcxGridDBColumn
        Caption = 'Birim Fiyat'
        DataBinding.FieldName = 'BIRIMFIYAT'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;(,0.00)'
        Options.Editing = False
        Width = 84
      end
      object GridFatDBTableView1ISKONTO1: TcxGridDBColumn
        Caption = #304'sk%'
        DataBinding.FieldName = 'ISKONTO'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ReadOnly = False
        Options.Editing = False
        Width = 41
      end
      object GridFatDBTableView1KDV1: TcxGridDBColumn
        DataBinding.FieldName = 'KDV'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ReadOnly = False
        Options.Editing = False
        Width = 34
      end
      object GridFatDBTableView1TUTAR1: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTAR'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;(,0.00)'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 97
      end
      object GridFatDBTableView1Column2: TcxGridDBColumn
        DataBinding.FieldName = 'SEPETID'
        Visible = False
        Options.Editing = False
      end
    end
    object GridFatLevel1: TcxGridLevel
      GridView = GridFatDBTableView1
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 41
    Width = 757
    Height = 151
    Align = alTop
    TabOrder = 2
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'LondonLiquidSky'
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsFatBaslik
      DataController.KeyFieldNames = 'ID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1Column1: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TUR'
        RepositoryItem = Tablo.RepKasaTurleriReadOnly
      end
      object cxGrid1DBTableView1Column2: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        Options.Editing = False
      end
      object cxGrid1DBTableView1Column3: TcxGridDBColumn
        Caption = 'B.Tarih'
        DataBinding.FieldName = 'TARIH'
        Options.Editing = False
      end
      object cxGrid1DBTableView1Column4: TcxGridDBColumn
        Caption = 'Belge No'
        DataBinding.FieldName = 'BELGENO'
        Options.Editing = False
      end
      object cxGrid1DBTableView1Column6: TcxGridDBColumn
        Caption = 'B.Tutar'#305
        DataBinding.FieldName = 'BELGETUTARI'
        Options.Editing = False
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object GridSepet: TcxGrid
    Left = 0
    Top = 414
    Width = 757
    Height = 173
    Align = alBottom
    TabOrder = 3
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = False
    LookAndFeel.SkinName = 'LondonLiquidSky'
    object cxGridDBTableView1: TcxGridDBTableView
      PopupMenu = pmSepet
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = dtsSepet
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.HideSelection = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      Styles.Indicator = AnaForm.cxStyle1
      object cxGridDBTableView1Column3: TcxGridDBColumn
        Caption = 'Belge T'#252'r'#252
        DataBinding.FieldName = 'FATBASTUR'
        RepositoryItem = Tablo.RepKasaTurleriReadOnly
      end
      object cxGridDBTableView1Column1: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'FATBASTARIH'
      end
      object cxGridDBTableView1Column2: TcxGridDBColumn
        Caption = 'BelgeNo'
        DataBinding.FieldName = 'FATBASBELGENO'
      end
      object cxGridDBColumn2: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Alignment.Horz = taLeftJustify
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = False
        Width = 53
      end
      object cxGridDBColumn3: TcxGridDBColumn
        Caption = 'Ad'
        DataBinding.FieldName = 'AD'
        Width = 228
      end
      object cxGridDBColumn4: TcxGridDBColumn
        Caption = 'Adet'
        DataBinding.FieldName = 'ADET'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ReadOnly = False
        Width = 35
      end
      object cxGridDBColumn5: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'BIRIM'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repStokAnaBirim
        Width = 42
      end
      object cxGridDBColumn6: TcxGridDBColumn
        Caption = 'Birim Fiyat'
        DataBinding.FieldName = 'BIRIMFIYAT'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;(,0.00)'
        Width = 84
      end
      object cxGridDBColumn7: TcxGridDBColumn
        Caption = #304'sk%'
        DataBinding.FieldName = 'ISKONTO'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ReadOnly = False
        Width = 41
      end
      object cxGridDBColumn8: TcxGridDBColumn
        DataBinding.FieldName = 'KDV'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ReadOnly = False
        Width = 34
      end
      object cxGridDBColumn9: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTAR'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.DisplayFormat = ',0.00;(,0.00)'
        HeaderAlignmentHorz = taCenter
        Width = 97
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = cxGridDBTableView1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 192
    Width = 757
    Height = 30
    Align = alTop
    TabOrder = 4
    object btnSecilileriEkle: TcxButton
      Left = 126
      Top = 2
      Width = 123
      Height = 25
      Caption = 'Se'#231'ilenleri Ekle'
      TabOrder = 0
      OnClick = btnTumunuEkleClick
    end
    object btnTumunuEkle: TcxButton
      Left = 3
      Top = 2
      Width = 123
      Height = 25
      Caption = 'T'#252'm'#252'n'#252' Ekle'
      TabOrder = 1
      OnClick = btnTumunuEkleClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 384
    Width = 757
    Height = 30
    Align = alBottom
    TabOrder = 5
    object btnIslemiTamamla: TcxButton
      Left = 4
      Top = 3
      Width = 123
      Height = 25
      Caption = #304#351'lemi Tamamla'
      TabOrder = 0
      OnClick = btnIslemiTamamlaClick
    end
  end
  object MemoFaturaDetaylari: TMemo
    Left = 54
    Top = 267
    Width = 600
    Height = 33
    Color = clYellow
    Lines.Strings = (
      'Select '
      #9'F.* ,'
      
        #9'AD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKL' +
        'AR WHERE ID = F.URUNID ) ELSE  '
      '(SELECT AD FROM MASRAFGELIR WHERE ID = F.URUNID)  END,'
      
        #9'KOD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR ' +
        'WHERE ID = F.URUNID ) ELSE  (SELECT '
      'KOD FROM MASRAFGELIR WHERE ID= F.URUNID )  END,'
      
        #9'BEKLEYENMIKTAR = ISNULL(F.MIKTAR,0)-ISNULL((SELECT SUM(MIKTAR) ' +
        'FROM FATURA WHERE YERI IN '
      '(408,411) AND '
      'YERID = F.ID ),0)'
      #9',ISNULL(S.ID,-999) SEPETID '
      'from '
      
        #9'FATURA F LEFT OUTER JOIN ##SEPET_BELGEDONUSUM S ON S.DETAYSATIR' +
        'ID = F.ID'
      'Where '
      #9'F.FATBASID = @BASLIKID')
    TabOrder = 6
    Visible = False
  end
  object MemoSiparisDetaylari: TMemo
    Left = 70
    Top = 287
    Width = 600
    Height = 33
    Color = clYellow
    Lines.Strings = (
      'Select '
      #9'F.* ,'
      
        #9'AD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKL' +
        'AR WHERE ID = F.URUNID ) ELSE  '
      '(SELECT AD FROM MASRAFGELIR WHERE ID = F.URUNID)  END,'
      
        #9'KOD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR ' +
        'WHERE ID = F.URUNID ) ELSE  (SELECT '
      'KOD FROM MASRAFGELIR WHERE ID= F.URUNID )  END,'
      
        #9'BEKLEYENMIKTAR = ISNULL(F.MIKTAR,0)-ISNULL((SELECT SUM(MIKTAR) ' +
        'FROM FATURA WHERE YERI IN '
      '(406,407,409,410) AND '
      'YERID = F.ID ),0)'
      #9',ISNULL(S.ID,-999) SEPETID '
      'from '
      
        #9'SIPARISDETAY F LEFT OUTER JOIN ##SEPET_BELGEDONUSUM S ON S.DETA' +
        'YSATIRID = F.ID'
      'Where '
      #9'F.SIPARISID = @BASLIKID')
    TabOrder = 7
    Visible = False
  end
  object MemoSepet: TMemo
    Left = 26
    Top = 447
    Width = 600
    Height = 33
    Color = clYellow
    Lines.Strings = (
      'BEGIN TRY'
      ' '
      'CREATE TABLE ##SEPET_BELGEDONUSUM ('
      #9'ID int IDENTITY(1,1) NOT NULL,'
      #9'FATBASTUR INT NOT NULL,'
      #9'FATBASTARIH DATETIME NOT NULL,'
      #9'GIRISDEPO INT ,'
      #9'CIKISDEPO INT ,'
      #9'FATBASBELGENO VARCHAR(20),'
      #9'FATBASKDVDURUM VARCHAR(10),'
      #9'FATBASID int NOT NULL,'
      '                DETAYSATIRID int NOT NULL,'
      #9'REHBERID int NOT NULL,'
      #9'SEC nvarchar(1) NULL,'
      #9'TUR smallint NULL,'
      #9'URUNID int NULL,'
      #9'KOD nvarchar(15) NULL,'
      #9'ACIKLAMA nvarchar(100) NULL,'
      #9'ADET float NULL,'
      #9'BIRIM smallint NULL,'
      #9'MIKTAR float NULL,'
      #9'BIRIMFIYAT numeric(18, 6) NULL,'
      #9'TUTAR money NULL,'
      #9'ISKONTO float NULL,'
      #9'KDV smallint NULL,'
      #9'MASRAFID smallint NULL,'
      #9'SKT datetime NULL,'
      #9'OZELKOD nvarchar(10) NULL,'
      #9'MUHKODU nvarchar(10) NULL,'
      #9'KASA smallint NULL,'
      #9'ONAY nvarchar(1) NULL,'
      #9'EKLEYEN smallint NULL,'
      #9'EKLEMETARIHI smalldatetime NULL,'
      #9'DEGISTIREN smallint NULL,'
      #9'DEGISTIRMETARIHI smalldatetime NULL,'
      #9'KUR nvarchar(5) NULL,'
      #9'IZLEMEKODU nvarchar(15) NULL,'
      #9'AD nvarchar(100) NULL,'
      #9'DOVIZ_TUTARI money NULL,'
      #9'DOVIZ_KURU nvarchar(5) NULL,'
      #9'ISKONTO2 float NULL,'
      #9'IZLEME smallint NULL'
      ')'
      ''
      '  SELECT * FROM ##SEPET_BELGEDONUSUM'
      ''
      'END TRY'
      ''
      ''
      'BEGIN CATCH'
      '  TRUNCATE TABLE ##SEPET_BELGEDONUSUM'
      ''
      '  SELECT * FROM ##SEPET_BELGEDONUSUM'
      ''
      'END CATCH'
      ' '
      '')
    TabOrder = 8
    Visible = False
  end
  object TabFatBaslik: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterOpen = TabFatBaslikAfterOpen
    AfterScroll = TabFatBaslikAfterScroll
    ParamData = <>
    SQL.Strings = (
      'DECLARE @BASTAR SMALLDATETIME,'
      '                @BITTAR SMALLDATETIME,'
      '                @REHBERID INT,'
      '                @TURLER VARCHAR(15)'
      ''
      'SET @REHBERID = :PRehberId'
      'SET @BASTAR = :PBastar'
      'SET @BITTAR = :PBittar'
      'SET @TURLER = :PTurler'
      'select '
      #9'F.*, CARIKOD=R.KOD,CARIAD=R.FIRMA, '
      'YAZIYLATOPLAM=( dbo.fn_MoneyToText(FATURA_TUTARI,'#39'TL'#39','#39'Kr'#39',0)) '
      ''
      'from '
      #9'FATBASLIK F (NOLOCK) '
      #9'inner join REHBER R on R.ID = F.REHBERID'
      'where '
      '                REHBERID = @REHBERID AND'
      '                TARIH BETWEEN @BASTAR AND @BITTAR'
      #9'TUR IN (@PTURLER) AND'
      '                DURUM NOT IN (15, 11)')
    Left = 194
    Top = 118
  end
  object DtsFatBaslik: TDataSource
    DataSet = TabFatBaslik
    Left = 136
    Top = 143
  end
  object DtsFatura: TDataSource
    DataSet = TabFatura
    Left = 256
    Top = 298
  end
  object TabFatura: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'DECLARE @BASLIKID INT '
      'SET @BASLIKID = :Par'
      'Select F.* ,'
      
        '    AD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT STOKADI FROM ST' +
        'OKLAR WHERE ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WH' +
        'ERE ID = F.URUNID)  END,'
      
        '    KOD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT KOD FROM STOKL' +
        'AR WHERE ID = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHER' +
        'E ID= F.URUNID )  END,'
      
        '   BEKLEYENMIKTAR = ISNULL(F.MIKTAR,0)-ISNULL((SELECT SUM(MIKTAR' +
        ') FROM FATURA WHERE YERI=@YERI AND YERID = F.ID ),0)'
      ',ISNULL(S.ID,-999) SEPETID '
      'from FATURA F LEFT OUTER JOIN #SEPET S ON S.DETAYSATIRID = F.ID'
      'Where '
      'F.FATBASID = @BASLIKID'
      'UNION ALL'
      'SELECT '
      'F.* ,'
      
        'AD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ' +
        'ID = F.URUNID)  END,'
      
        'KOD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR W' +
        'HERE ID = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID' +
        '= F.URUNID )  END'
      
        #9'BEKLEYENMIKTAR = ISNULL(F.MIKTAR,0)-ISNULL((SELECT SUM(MIKTAR) ' +
        'FROM FATURA WHERE YERI=@YERI AND YERID = F.ID ),0)'
      ',ISNULL(S.ID,-999) SEPETID '
      
        'from SIPARISDETAY F LEFT OUTER JOIN #SEPET S ON S.DETAYSATIRID =' +
        ' F.ID'
      'Where '
      'F.SIPARISID = @BASLIKID'
      ' order by 1')
    Left = 196
    Top = 320
  end
  object cxEditRepository1: TcxEditRepository
    Left = 384
    Top = 24
    object cxEditRepository1CheckBoxItem1: TcxEditRepositoryCheckBoxItem
      Properties.ImmediatePost = True
      Properties.NullStyle = nssUnchecked
    end
  end
  object dtsSepet: TDataSource
    DataSet = tabDonusumSepet
    Left = 368
    Top = 475
  end
  object pmSepet: TPopupMenu
    Left = 668
    Top = 444
    object SatrSil1: TMenuItem
      Caption = 'Sat'#305'r'#305' Sil'
      OnClick = SatrSil1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnSil: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Sil'
      OnClick = mnSilClick
    end
  end
  object tabDonusumSepet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ' SELECT * FROM ##SEPET_BELGEDONUSUM')
    Left = 142
    Top = 481
  end
end
