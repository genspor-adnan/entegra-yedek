object UrunBilgiDlg: TUrunBilgiDlg
  Left = 0
  Top = 0
  BiDiMode = bdLeftToRight
  BorderStyle = bsSizeToolWin
  ClientHeight = 400
  ClientWidth = 655
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ParentBiDiMode = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object JvNavPanelHeader1: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 655
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clBtnFace
    ColorTo = clSilver
    ImageIndex = 0
    object Label1: TLabel
      Left = 3
      Top = 5
      Width = 87
      Height = 19
      Caption = #304'la'#231' Bilgileri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 27
    Width = 655
    Height = 86
    Align = alTop
    BevelOuter = bvLowered
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object cxLabel1: TcxLabel
      Left = 3
      Top = 6
      Caption = 'GTIN'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clGreen
      Style.IsFontAssigned = True
    end
    object cxLabel2: TcxLabel
      Left = 3
      Top = 29
      Caption = #304'la'#231' Ad'#305
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clGreen
      Style.IsFontAssigned = True
    end
    object cxLabel3: TcxLabel
      Left = 3
      Top = 54
      Caption = 'Stok Durum'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clGreen
      Style.IsFontAssigned = True
    end
    object cxLabel4: TcxLabel
      Left = 237
      Top = 6
      Caption = 'S'#305'ra No'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clGreen
      Style.IsFontAssigned = True
    end
    object cxLabel5: TcxLabel
      Left = 425
      Top = 6
      Caption = 'Son Kullanma Tarihi'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clGreen
      Style.IsFontAssigned = True
    end
    object cxLabel6: TcxLabel
      Left = 237
      Top = 29
      Caption = 'Lot No'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clGreen
      Style.IsFontAssigned = True
    end
    object cxLabel7: TcxLabel
      Left = 425
      Top = 29
      Caption = #220'retim Tarihi'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clGreen
      Style.IsFontAssigned = True
    end
    object cxDBLabel1: TcxDBLabel
      Left = 48
      Top = 6
      DataBinding.DataField = 'URUNBARKOD'
      DataBinding.DataSource = DtsTabUrunBilgi
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Height = 21
      Width = 121
    end
    object cxDBLabel2: TcxDBLabel
      Left = 48
      Top = 29
      DataBinding.DataField = 'STOKADI'
      DataBinding.DataSource = DtsTabUrunBilgi
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Height = 21
      Width = 177
    end
    object cxDBLabel3: TcxDBLabel
      Left = 280
      Top = 6
      DataBinding.DataField = 'SIRANO'
      DataBinding.DataSource = DtsTabUrunBilgi
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Height = 21
      Width = 121
    end
    object cxDBLabel4: TcxDBLabel
      Left = 281
      Top = 29
      DataBinding.DataField = 'LOTNO'
      DataBinding.DataSource = DtsTabUrunBilgi
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Height = 21
      Width = 121
    end
    object cxDBLabel5: TcxDBLabel
      Left = 527
      Top = 6
      DataBinding.DataField = 'SONKULLANIM'
      DataBinding.DataSource = DtsTabUrunBilgi
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Height = 21
      Width = 121
    end
    object cxDBLabel6: TcxDBLabel
      Left = 527
      Top = 29
      DataBinding.DataField = 'URETIMTARIHI'
      DataBinding.DataSource = DtsTabUrunBilgi
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Height = 21
      Width = 121
    end
  end
  object JvNavPanelHeader4: TJvNavPanelHeader
    Left = 0
    Top = 113
    Width = 655
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clBtnFace
    ColorTo = clSilver
    ImageIndex = 0
    object Label3: TLabel
      Left = 3
      Top = 5
      Width = 123
      Height = 19
      Caption = #220'r'#252'n Bildirimleri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 140
    Width = 655
    Height = 260
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 3
    object GridUrunDurum: TcxGrid
      Left = 1
      Top = 1
      Width = 653
      Height = 258
      Align = alClient
      TabOrder = 0
      object TvUrunDurum: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsUrunDurum
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            FieldName = 'SIRANO'
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.AlwaysShowEditor = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.FooterAutoHeight = True
        OptionsView.FooterMultiSummaries = True
        OptionsView.GroupByBox = False
        object TvUrunDurumBILDIRIM_TARIH: TcxGridDBColumn
          Caption = 'Bildirim Tarihi'
          DataBinding.FieldName = 'BILDIRIM_TARIH'
          Width = 93
        end
        object TvUrunDurumURUN_DURUM: TcxGridDBColumn
          Caption = 'Servis'
          DataBinding.FieldName = 'URUN_DURUM'
          Width = 96
        end
        object TvUrunDurumHATA_KODU: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'HATA_KODU'
          Width = 42
        end
        object TvUrunDurumHATA_ACIKLAMA: TcxGridDBColumn
          Caption = 'A'#231'iklama'
          DataBinding.FieldName = 'HATA_ACIKLAMA'
          Width = 420
        end
      end
      object GlUrunDurum: TcxGridLevel
        GridView = TvUrunDurum
      end
    end
  end
  object TabUrunDurum: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'BARKOD'
        Attributes = [paNullable]
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 20
        Value = Null
      end
      item
        Name = 'SIRANO'
        Attributes = [paNullable]
        DataType = ftString
        NumericScale = 255
        Precision = 255
        Size = 20
        Value = Null
      end>
    SQL.Strings = (
      
        'select BILDIRIM_TARIH,URUN_DURUM,HATA_KODU,HATA_ACIKLAMA,ID from' +
        ' ITS_URUNLER'
      'WHERE URUN_BARKOD_NO =:BARKOD AND URUN_SIRA_NO=:SIRANO'
      'ORDER BY BILDIRIM_TARIH DESC')
    Left = 493
    Top = 179
    object TabUrunDurumBILDIRIM_TARIH: TDateTimeField
      FieldName = 'BILDIRIM_TARIH'
    end
    object TabUrunDurumURUN_DURUM: TStringField
      FieldName = 'URUN_DURUM'
      Size = 250
    end
    object TabUrunDurumHATA_KODU: TStringField
      FieldName = 'HATA_KODU'
      Size = 250
    end
    object TabUrunDurumHATA_ACIKLAMA: TStringField
      FieldName = 'HATA_ACIKLAMA'
      Size = 250
    end
    object TabUrunDurumID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
  end
  object DtsUrunDurum: TDataSource
    DataSet = TabUrunDurum
    Left = 588
    Top = 178
  end
  object TabUrunBilgi: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    AfterScroll = TabUrunBilgiAfterScroll
    Parameters = <
      item
        Name = 'ID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT * FROM STOKID SI'
      'INNER JOIN STOKLAR S ON SI.STOKID=S.ID'
      'INNER JOIN KAREKOD K ON K.STOKIDID=SI.ID'
      'WHERE SI.ID=:ID')
    Left = 493
    Top = 107
    object TabUrunBilgiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabUrunBilgiGIRISTURU: TWordField
      FieldName = 'GIRISTURU'
    end
    object TabUrunBilgiSTOKID: TIntegerField
      FieldName = 'STOKID'
    end
    object TabUrunBilgiGIRFATBASID: TIntegerField
      FieldName = 'GIRFATBASID'
    end
    object TabUrunBilgiGIRFATURAID: TIntegerField
      FieldName = 'GIRFATURAID'
    end
    object TabUrunBilgiURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabUrunBilgiSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabUrunBilgiSERINO: TStringField
      FieldName = 'SERINO'
    end
    object TabUrunBilgiCIKISTURU: TWordField
      FieldName = 'CIKISTURU'
    end
    object TabUrunBilgiCIKFATBASID: TIntegerField
      FieldName = 'CIKFATBASID'
    end
    object TabUrunBilgiCIKFATURAID: TIntegerField
      FieldName = 'CIKFATURAID'
    end
    object TabUrunBilgiGARANTIBITIS: TDateTimeField
      FieldName = 'GARANTIBITIS'
    end
    object TabUrunBilgiIZLEMTURU: TWordField
      FieldName = 'IZLEMTURU'
    end
    object TabUrunBilgiONAY: TBooleanField
      FieldName = 'ONAY'
    end
    object TabUrunBilgiSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object TabUrunBilgiLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabUrunBilgiURETIMTIPI: TStringField
      FieldName = 'URETIMTIPI'
      Size = 5
    end
    object TabUrunBilgiURUNCINSI: TStringField
      FieldName = 'URUNCINSI'
      Size = 5
    end
    object TabUrunBilgiURETIMTARIHI: TDateTimeField
      FieldName = 'URETIMTARIHI'
    end
    object TabUrunBilgiPAKETID: TIntegerField
      FieldName = 'PAKETID'
    end
    object TabUrunBilgiTASIMA_BIRIMI_ID: TIntegerField
      FieldName = 'TASIMA_BIRIMI_ID'
    end
    object TabUrunBilgiDEPOID: TIntegerField
      FieldName = 'DEPOID'
    end
    object TabUrunBilgiSEC: TBooleanField
      FieldName = 'SEC'
    end
    object TabUrunBilgiPOSAYISI: TStringField
      FieldName = 'POSAYISI'
      Size = 10
    end
    object TabUrunBilgiID_1: TAutoIncField
      FieldName = 'ID_1'
      ReadOnly = True
    end
    object TabUrunBilgiKOD: TWideStringField
      FieldName = 'KOD'
      Size = 25
    end
    object TabUrunBilgiSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabUrunBilgiTIPI: TSmallintField
      FieldName = 'TIPI'
    end
    object TabUrunBilgiMARKA: TSmallintField
      FieldName = 'MARKA'
    end
    object TabUrunBilgiMODEL: TSmallintField
      FieldName = 'MODEL'
    end
    object TabUrunBilgiGRUBU: TSmallintField
      FieldName = 'GRUBU'
    end
    object TabUrunBilgiOZELLIK: TSmallintField
      FieldName = 'OZELLIK'
    end
    object TabUrunBilgiOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Size = 30
    end
    object TabUrunBilgiMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 10
    end
    object TabUrunBilgiANABIRIM: TWordField
      FieldName = 'ANABIRIM'
    end
    object TabUrunBilgiBIRIM2: TWordField
      FieldName = 'BIRIM2'
    end
    object TabUrunBilgiBIRIM2MIKTAR: TIntegerField
      FieldName = 'BIRIM2MIKTAR'
    end
    object TabUrunBilgiMINSTOK: TIntegerField
      FieldName = 'MINSTOK'
    end
    object TabUrunBilgiYERI: TWordField
      FieldName = 'YERI'
    end
    object TabUrunBilgiURETICIID: TIntegerField
      FieldName = 'URETICIID'
    end
    object TabUrunBilgiSATICIID: TIntegerField
      FieldName = 'SATICIID'
    end
    object TabUrunBilgiKDV: TWordField
      FieldName = 'KDV'
    end
    object TabUrunBilgiEKVERGI: TWordField
      FieldName = 'EKVERGI'
    end
    object TabUrunBilgiXBARKODX: TWideStringField
      FieldName = 'XBARKODX'
      Size = 15
    end
    object TabUrunBilgiDURUM: TWordField
      FieldName = 'DURUM'
    end
    object TabUrunBilgiFIYAT_LISTE: TWordField
      FieldName = 'FIYAT_LISTE'
    end
    object TabUrunBilgiIZLEME: TWordField
      FieldName = 'IZLEME'
    end
    object TabUrunBilgiRAFOMRU_SURE: TSmallintField
      FieldName = 'RAFOMRU_SURE'
    end
    object TabUrunBilgiRAFOMRU_BIRIM: TIntegerField
      FieldName = 'RAFOMRU_BIRIM'
    end
    object TabUrunBilgiMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object TabUrunBilgiBOYUT_EN: TFloatField
      FieldName = 'BOYUT_EN'
    end
    object TabUrunBilgiBOYUT_BOY: TFloatField
      FieldName = 'BOYUT_BOY'
    end
    object TabUrunBilgiBOYUT_YUKSEKLIK: TFloatField
      FieldName = 'BOYUT_YUKSEKLIK'
    end
    object TabUrunBilgiBOYUT_ALAN: TFloatField
      FieldName = 'BOYUT_ALAN'
    end
    object TabUrunBilgiBOYUT_NET_HACIM: TFloatField
      FieldName = 'BOYUT_NET_HACIM'
    end
    object TabUrunBilgiBOYUT_BRUT_HACIM: TFloatField
      FieldName = 'BOYUT_BRUT_HACIM'
    end
    object TabUrunBilgiBOYUT_NET_AGIRLIK: TFloatField
      FieldName = 'BOYUT_NET_AGIRLIK'
    end
    object TabUrunBilgiBOYUT_BRUT_AGIRLIK: TFloatField
      FieldName = 'BOYUT_BRUT_AGIRLIK'
    end
    object TabUrunBilgiUZUNLUK_BIRIMI: TWordField
      FieldName = 'UZUNLUK_BIRIMI'
    end
    object TabUrunBilgiALAN_BIRIMI: TWordField
      FieldName = 'ALAN_BIRIMI'
    end
    object TabUrunBilgiHACIM_BIRIMI: TWordField
      FieldName = 'HACIM_BIRIMI'
    end
    object TabUrunBilgiAGIRLIK_BIRIMI: TWordField
      FieldName = 'AGIRLIK_BIRIMI'
    end
    object TabUrunBilgiNOTLAR: TWideStringField
      FieldName = 'NOTLAR'
      Size = 500
    end
    object TabUrunBilgiYETKIKODU: TWideStringField
      FieldName = 'YETKIKODU'
      Size = 10
    end
    object TabUrunBilgiGARANTISURESI: TSmallintField
      FieldName = 'GARANTISURESI'
    end
    object TabUrunBilgiKISAYOLGRUBU: TWordField
      FieldName = 'KISAYOLGRUBU'
    end
    object TabUrunBilgiPAKET: TBooleanField
      FieldName = 'PAKET'
    end
    object TabUrunBilgiEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabUrunBilgiEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object TabUrunBilgiDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabUrunBilgiDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabUrunBilgiGELIRID: TSmallintField
      FieldName = 'GELIRID'
    end
    object TabUrunBilgiDETAYBOLUMU: TWideStringField
      FieldName = 'DETAYBOLUMU'
    end
    object TabUrunBilgiID_2: TAutoIncField
      FieldName = 'ID_2'
      ReadOnly = True
    end
    object TabUrunBilgiSTOKIDID: TIntegerField
      FieldName = 'STOKIDID'
    end
    object TabUrunBilgiSTOKID_1: TIntegerField
      FieldName = 'STOKID_1'
    end
    object TabUrunBilgiURUNKODU: TStringField
      FieldName = 'URUNKODU'
      Size = 50
    end
    object TabUrunBilgiDOGRULAMA_DURUM: TWideStringField
      FieldName = 'DOGRULAMA_DURUM'
      Size = 250
    end
    object TabUrunBilgiDOGRULAMA_TARIH: TDateTimeField
      FieldName = 'DOGRULAMA_TARIH'
    end
    object TabUrunBilgiALIM_DURUM: TWideStringField
      FieldName = 'ALIM_DURUM'
      Size = 250
    end
    object TabUrunBilgiALIM_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'ALIM_BILDIRIM_TARIH'
    end
    object TabUrunBilgiSATIS_DURUM: TWideStringField
      FieldName = 'SATIS_DURUM'
      Size = 250
    end
    object TabUrunBilgiSATIS_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'SATIS_BILDIRIM_TARIH'
    end
    object TabUrunBilgiALIM_IADE_DURUM: TWideStringField
      FieldName = 'ALIM_IADE_DURUM'
      Size = 250
    end
    object TabUrunBilgiALIM_IADE_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'ALIM_IADE_BILDIRIM_TARIH'
    end
    object TabUrunBilgiSATIS_IPTAL_DURUM: TWideStringField
      FieldName = 'SATIS_IPTAL_DURUM'
      Size = 250
    end
    object TabUrunBilgiSATIS_IPTAL_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'SATIS_IPTAL_BILDIRIM_TARIH'
    end
    object TabUrunBilgiDEAKTIVASYON_DURUM: TWideStringField
      FieldName = 'DEAKTIVASYON_DURUM'
      Size = 250
    end
    object TabUrunBilgiDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'DEAKTIVASYON_BILDIRIM_TARIH'
    end
    object TabUrunBilgiMALALINANGLN: TWideStringField
      FieldName = 'MALALINANGLN'
    end
    object TabUrunBilgiMALSATILANGLN: TWideStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabUrunBilgiTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabUrunBilgiURETIM_DURUM: TStringField
      FieldName = 'URETIM_DURUM'
      Size = 150
    end
    object TabUrunBilgiURETIM_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'URETIM_BILDIRIM_TARIH'
    end
  end
  object DtsTabUrunBilgi: TDataSource
    DataSet = TabUrunBilgi
    Left = 588
    Top = 106
  end
end
