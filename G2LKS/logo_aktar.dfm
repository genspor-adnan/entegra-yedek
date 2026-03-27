object logoaktar: Tlogoaktar
  Left = 0
  Top = 0
  Caption = 'Logo Aktar'#305'm'
  ClientHeight = 678
  ClientWidth = 1098
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1098
    Height = 50
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 100
      Height = 48
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object cxDateEdit2: TcxDateEdit
        Left = 0
        Top = 21
        Align = alTop
        Properties.ShowTime = False
        TabOrder = 0
        Width = 100
      end
      object cxDateEdit1: TcxDateEdit
        Left = 0
        Top = 0
        Align = alTop
        Properties.ShowTime = False
        TabOrder = 1
        Width = 100
      end
    end
    object Panel3: TPanel
      Left = 101
      Top = 1
      Width = 120
      Height = 48
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object cxRadioButton1: TcxRadioButton
        Left = 8
        Top = 4
        Width = 113
        Height = 17
        Caption = 'Al'#305#351' Faturas'#305
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object cxRadioButton2: TcxRadioButton
        Left = 8
        Top = 25
        Width = 113
        Height = 17
        Caption = 'Sat'#305#351' Faturas'#305
        TabOrder = 1
      end
    end
    object cxButton1: TcxButton
      Left = 221
      Top = 1
      Width = 75
      Height = 48
      Align = alLeft
      Caption = 'Listele'
      TabOrder = 2
      OnClick = cxButton1Click
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 50
    Width = 913
    Height = 411
    Align = alClient
    TabOrder = 1
    object cxGrid1DBTableView1: TcxGridDBTableView
      PopupMenu = PopupMenu1
      Navigator.Buttons.CustomButtons = <>
      OnCellClick = cxGrid1DBTableView1CellClick
      DataController.DataSource = SR_ftbaslik
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1sec: TcxGridDBColumn
        Caption = 'SE'#199
        DataBinding.FieldName = 'sec'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ValueChecked = '1'
        Properties.ValueUnchecked = '0'
        Width = 35
      end
      object cxGrid1DBTableView1FATURATARIH: TcxGridDBColumn
        DataBinding.FieldName = 'FATURATARIH'
        Width = 100
      end
      object cxGrid1DBTableView1FATURANO: TcxGridDBColumn
        DataBinding.FieldName = 'FATURANO'
        Width = 100
      end
      object cxGrid1DBTableView1KOD: TcxGridDBColumn
        DataBinding.FieldName = 'KOD'
        Width = 120
      end
      object cxGrid1DBTableView1FIRMA: TcxGridDBColumn
        DataBinding.FieldName = 'FIRMA'
        Width = 180
      end
      object cxGrid1DBTableView1FATURA_MATRAHI: TcxGridDBColumn
        DataBinding.FieldName = 'FATURA_MATRAHI'
        Width = 100
      end
      object cxGrid1DBTableView1KDV_TUTARI: TcxGridDBColumn
        DataBinding.FieldName = 'KDV_TUTARI'
        Width = 80
      end
      object cxGrid1DBTableView1FATURA_TUTARI: TcxGridDBColumn
        DataBinding.FieldName = 'FATURA_TUTARI'
        Width = 100
      end
      object cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn
        DataBinding.FieldName = 'ACIKLAMA'
        Width = 150
      end
      object cxGrid1DBTableView1AD: TcxGridDBColumn
        DataBinding.FieldName = 'AD'
        Width = 90
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 628
    Width = 1098
    Height = 50
    Align = alBottom
    TabOrder = 2
    object cxButton2: TcxButton
      Left = 1
      Top = 1
      Width = 160
      Height = 48
      Align = alLeft
      Caption = 'XML Olu'#351'tur'
      Enabled = False
      TabOrder = 0
      OnClick = cxButton2Click
    end
    object Panel4: TPanel
      Left = 161
      Top = 1
      Width = 185
      Height = 48
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
    end
  end
  object Panel6: TPanel
    Left = 913
    Top = 50
    Width = 185
    Height = 411
    Align = alRight
    TabOrder = 3
    object cxButton3: TcxButton
      Left = 1
      Top = 1
      Width = 183
      Height = 75
      Align = alTop
      Caption = 'Cari ve Stok Kontrol'
      TabOrder = 0
      OnClick = cxButton3Click
    end
    object cxButton4: TcxButton
      Left = 1
      Top = 335
      Width = 183
      Height = 75
      Align = alBottom
      Caption = 'Aktar'#305'lan Faturalar'#305' '#304#351'aretle'
      TabOrder = 1
      OnClick = cxButton4Click
    end
    object RichEdit1: TRichEdit
      Left = 1
      Top = 76
      Width = 183
      Height = 259
      Align = alClient
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
  object cxGrid2: TcxGrid
    Left = 0
    Top = 461
    Width = 1098
    Height = 167
    Align = alBottom
    TabOrder = 4
    object cxGrid2DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      object cxGrid2DBTableView1KOD: TcxGridDBColumn
        DataBinding.FieldName = 'KOD'
        Width = 100
      end
      object cxGrid2DBTableView1STOKADI: TcxGridDBColumn
        DataBinding.FieldName = 'STOKADI'
        Width = 180
      end
      object cxGrid2DBTableView1ADET: TcxGridDBColumn
        DataBinding.FieldName = 'ADET'
      end
      object cxGrid2DBTableView1BIRIM: TcxGridDBColumn
        DataBinding.FieldName = 'BIRIM'
      end
      object cxGrid2DBTableView1MIKTAR: TcxGridDBColumn
        DataBinding.FieldName = 'MIKTAR'
      end
      object cxGrid2DBTableView1BIRIMFIYAT: TcxGridDBColumn
        DataBinding.FieldName = 'BIRIMFIYAT'
      end
      object cxGrid2DBTableView1TUTAR: TcxGridDBColumn
        DataBinding.FieldName = 'TUTAR'
      end
      object cxGrid2DBTableView1KDV: TcxGridDBColumn
        DataBinding.FieldName = 'KDV'
      end
      object cxGrid2DBTableView1ACIKLAMA: TcxGridDBColumn
        DataBinding.FieldName = 'ACIKLAMA'
        Width = 200
      end
    end
    object cxGrid2Level1: TcxGridLevel
      GridView = cxGrid2DBTableView1
    end
  end
  object sqltext: TRichEdit
    Left = 208
    Top = 535
    Width = 449
    Height = 135
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'SELECT     dbo.FATBASLIK.ID, dbo.FATBASLIK.TARIH, '
      'dbo.FATBASLIK.TUR, dbo.FATBASLIK.TIPI, dbo.FATBASLIK.REHBERID, '
      'dbo.FATBASLIK.FATURATARIH, dbo.REHBER.KOD, '
      '                      dbo.REHBER.FIRMA, dbo.FATBASLIK.KDVDURUM, '
      'dbo.FATBASLIK.FATURA_MATRAHI, dbo.FATBASLIK.KDV_TUTARI, '
      'dbo.FATBASLIK.FATURA_TUTARI, '
      
        '                      dbo.FATBASLIK.ACIKLAMA, dbo.FATBASLIK.IRSA' +
        'LIYE_NO, '
      'dbo.FATBASLIK.IRSALIYENO, dbo.FATBASLIK.IRSALIYETARIH, '
      'dbo.FATBASLIK.FATURANO, '
      '                      dbo.ISLEMTURLERI.AD'
      'FROM         dbo.FATBASLIK LEFT OUTER JOIN'
      '                      dbo.ISLEMTURLERI ON dbo.FATBASLIK.TUR = '
      'dbo.ISLEMTURLERI.TUR AND dbo.FATBASLIK.TIPI = '
      'dbo.ISLEMTURLERI.TIP LEFT OUTER JOIN'
      '                      dbo.REHBER ON dbo.FATBASLIK.REHBERID = '
      'dbo.REHBER.ID')
    ParentFont = False
    TabOrder = 5
    Visible = False
  end
  object volustur: TRichEdit
    Left = 21
    Top = 304
    Width = 492
    Height = 121
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'CREATE VIEW [dbo].[uv_FATURASTOK]'
      'AS'
      'SELECT     dbo.STOKLAR.KOD, dbo.STOKLAR.STOKADI, dbo.FATURA.*'
      'FROM         dbo.FATURA LEFT OUTER JOIN'
      
        '                      dbo.STOKLAR ON dbo.FATURA.URUNID = dbo.STO' +
        'KLAR.ID'
      'WHERE     (dbo.FATURA.TUR = '#39'1'#39')'
      'UNION ALL'
      'SELECT     dbo.MASRAFGELIR.KOD, dbo.MASRAFGELIR.AD, dbo.FATURA.*'
      'FROM         dbo.FATURA LEFT OUTER JOIN'
      
        '                      dbo.MASRAFGELIR ON dbo.FATURA.URUNID = dbo' +
        '.MASRAFGELIR.ID'
      'WHERE     (dbo.FATURA.TUR = '#39'0'#39')')
    ParentFont = False
    TabOrder = 6
    Visible = False
  end
  object QR_ftbaslik2: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT     dbo.FATBASLIK.ID, dbo.FATBASLIK.TARIH, dbo.FATBASLIK.' +
        'TUR, dbo.FATBASLIK.TIPI, dbo.FATBASLIK.REHBERID, dbo.FATBASLIK.F' +
        'ATURATARIH, dbo.REHBER.KOD, '
      
        '                      dbo.REHBER.FIRMA, dbo.FATBASLIK.KDVDURUM, ' +
        'dbo.FATBASLIK.FATURA_MATRAHI, dbo.FATBASLIK.KDV_TUTARI, dbo.FATB' +
        'ASLIK.FATURA_TUTARI,dbo.FATBASLIK.FATURANO, '
      
        '                      dbo.FATBASLIK.ACIKLAMA, dbo.FATBASLIK.IRSA' +
        'LIYE_NO, dbo.FATBASLIK.IRSALIYENO, dbo.FATBASLIK.IRSALIYETARIH, ' +
        'dbo.ISLEMTURLERI.AD'
      'FROM         dbo.FATBASLIK INNER JOIN'
      
        '                      dbo.REHBER ON dbo.FATBASLIK.REHBERID = dbo' +
        '.REHBER.ID INNER JOIN'
      
        '                      dbo.ISLEMTURLERI ON dbo.FATBASLIK.TUR = db' +
        'o.ISLEMTURLERI.TUR')
    Left = 544
    Top = 160
    object QR_ftbaslik2ID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object QR_ftbaslik2TARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object QR_ftbaslik2TUR: TSmallintField
      FieldName = 'TUR'
    end
    object QR_ftbaslik2TIPI: TSmallintField
      FieldName = 'TIPI'
    end
    object QR_ftbaslik2REHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object QR_ftbaslik2FATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object QR_ftbaslik2KOD: TWideStringField
      FieldName = 'KOD'
    end
    object QR_ftbaslik2FIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object QR_ftbaslik2KDVDURUM: TWideStringField
      FieldName = 'KDVDURUM'
      Size = 5
    end
    object QR_ftbaslik2FATURA_MATRAHI: TBCDField
      FieldName = 'FATURA_MATRAHI'
      Precision = 19
    end
    object QR_ftbaslik2KDV_TUTARI: TBCDField
      FieldName = 'KDV_TUTARI'
      Precision = 19
    end
    object QR_ftbaslik2FATURA_TUTARI: TBCDField
      FieldName = 'FATURA_TUTARI'
      Precision = 19
    end
    object QR_ftbaslik2ACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object QR_ftbaslik2IRSALIYE_NO: TSmallintField
      FieldName = 'IRSALIYE_NO'
    end
    object QR_ftbaslik2IRSALIYENO: TStringField
      FieldName = 'IRSALIYENO'
      Size = 50
    end
    object QR_ftbaslik2IRSALIYETARIH: TDateTimeField
      FieldName = 'IRSALIYETARIH'
    end
    object QR_ftbaslik2AD: TWideStringField
      FieldName = 'AD'
      Size = 100
    end
    object QR_ftbaslik2FATURANO: TWideStringField
      FieldName = 'FATURANO'
    end
  end
  object SR_ftbaslik: TDataSource
    DataSet = QR_ftbaslik
    Left = 408
    Top = 216
  end
  object XMLDocument1: TXMLDocument
    Left = 584
    Top = 32
    DOMVendorDesc = 'MSXML'
  end
  object QR_detay: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    OnCalcFields = QR_detayCalcFields
    Parameters = <>
    SQL.Strings = (
      'select * from uv_FATURASTOK')
    Left = 768
    Top = 232
    object QR_detayKOD: TWideStringField
      FieldName = 'KOD'
      Size = 50
    end
    object QR_detaySTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 200
    end
    object QR_detayID: TIntegerField
      FieldName = 'ID'
    end
    object QR_detayFATBASID: TIntegerField
      FieldName = 'FATBASID'
    end
    object QR_detayREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object QR_detaySEC: TWideStringField
      FieldName = 'SEC'
      Size = 1
    end
    object QR_detayTUR: TSmallintField
      FieldName = 'TUR'
    end
    object QR_detayURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object QR_detayACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
      Size = 100
    end
    object QR_detayADET: TFloatField
      FieldName = 'ADET'
    end
    object QR_detayMF: TFloatField
      FieldName = 'MF'
    end
    object QR_detayBIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object QR_detayMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object QR_detayBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 18
    end
    object QR_detayTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 18
    end
    object QR_detayKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object QR_detayISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object QR_detayKDV: TSmallintField
      FieldName = 'KDV'
    end
    object QR_detayMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object QR_detayIZLEMEKODU: TWideStringField
      FieldName = 'IZLEMEKODU'
      Size = 15
    end
    object QR_detayOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Size = 25
    end
    object QR_detayMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 25
    end
    object QR_detayKASA: TSmallintField
      FieldName = 'KASA'
    end
    object QR_detayONAY: TWideStringField
      FieldName = 'ONAY'
      Size = 1
    end
    object QR_detayDOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 18
    end
    object QR_detayDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object QR_detayISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object QR_detayIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object QR_detayIADEADET: TFloatField
      FieldName = 'IADEADET'
    end
    object QR_detayIADEFATURAID: TIntegerField
      FieldName = 'IADEFATURAID'
    end
    object QR_detayYERI: TIntegerField
      FieldName = 'YERI'
    end
    object QR_detayYERID: TIntegerField
      FieldName = 'YERID'
    end
    object QR_detayEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object QR_detayEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object QR_detayDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object QR_detayDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object QR_detayDOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 18
    end
    object QR_detayDOVIZKURDEGERI: TBCDField
      FieldName = 'DOVIZKURDEGERI'
      Precision = 19
    end
    object QR_detayPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object QR_detayKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object QR_detayVADE: TWordField
      FieldName = 'VADE'
    end
    object QR_detaySTOKDURUMDEGIS: TBooleanField
      FieldName = 'STOKDURUMDEGIS'
    end
    object QR_detaySUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object QR_detayKDVMUHAFIYETI: TSmallintField
      FieldName = 'KDVMUHAFIYETI'
    end
    object QR_detayEKMALIYET: TBCDField
      FieldName = 'EKMALIYET'
      Precision = 19
    end
    object QR_detayBASTAR: TDateTimeField
      FieldName = 'BASTAR'
    end
    object QR_detayBITTAR: TDateTimeField
      FieldName = 'BITTAR'
    end
    object QR_detayURETIMPLANID: TIntegerField
      FieldName = 'URETIMPLANID'
    end
    object QR_detayURETIMPLANDETAYID: TIntegerField
      FieldName = 'URETIMPLANDETAYID'
    end
    object QR_detayMERKEZID: TIntegerField
      FieldName = 'MERKEZID'
    end
    object QR_detayckdvtut: TFloatField
      FieldKind = fkCalculated
      FieldName = 'ckdvtut'
      Calculated = True
    end
  end
  object QR_logostok: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select CODE,NAME from LG_001_ITEMS')
    Left = 848
    Top = 600
    object QR_logostokCODE: TStringField
      FieldName = 'CODE'
      Size = 25
    end
    object QR_logostokNAME: TStringField
      FieldName = 'NAME'
      Size = 51
    end
  end
  object QR_logocari: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select CODE,DEFINITION_ from LG_001_CLCARD')
    Left = 776
    Top = 600
    object QR_logocariCODE: TStringField
      FieldName = 'CODE'
      Size = 17
    end
    object QR_logocariDEFINITION_: TStringField
      FieldName = 'DEFINITION_'
      Size = 51
    end
  end
  object QR_logofatura: TADOQuery
    Parameters = <>
    Left = 712
    Top = 600
  end
  object QR_update: TADOQuery
    Connection = Tablo.cnn
    Parameters = <>
    Left = 704
    Top = 232
  end
  object ADOQuery1: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from uv_FATURASTOK')
    Left = 720
    Top = 536
    object ADOQuery1KOD: TWideStringField
      FieldName = 'KOD'
      Size = 50
    end
    object ADOQuery1STOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 200
    end
    object ADOQuery1ID: TIntegerField
      FieldName = 'ID'
    end
    object ADOQuery1FATBASID: TIntegerField
      FieldName = 'FATBASID'
    end
    object ADOQuery1REHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object ADOQuery1SEC: TWideStringField
      FieldName = 'SEC'
      Size = 1
    end
    object ADOQuery1TUR: TSmallintField
      FieldName = 'TUR'
    end
    object ADOQuery1URUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object ADOQuery1ACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
      Size = 100
    end
    object ADOQuery1ADET: TFloatField
      FieldName = 'ADET'
    end
    object ADOQuery1MF: TFloatField
      FieldName = 'MF'
    end
    object ADOQuery1BIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object ADOQuery1MIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object ADOQuery1BIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 18
    end
    object ADOQuery1TUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 18
    end
    object ADOQuery1KUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object ADOQuery1ISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object ADOQuery1KDV: TSmallintField
      FieldName = 'KDV'
    end
    object ADOQuery1MASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object ADOQuery1IZLEMEKODU: TWideStringField
      FieldName = 'IZLEMEKODU'
      Size = 15
    end
    object ADOQuery1OZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Size = 25
    end
    object ADOQuery1MUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 25
    end
    object ADOQuery1KASA: TSmallintField
      FieldName = 'KASA'
    end
    object ADOQuery1ONAY: TWideStringField
      FieldName = 'ONAY'
      Size = 1
    end
    object ADOQuery1DOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 18
    end
    object ADOQuery1DOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object ADOQuery1ISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object ADOQuery1IZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object ADOQuery1IADEADET: TFloatField
      FieldName = 'IADEADET'
    end
    object ADOQuery1IADEFATURAID: TIntegerField
      FieldName = 'IADEFATURAID'
    end
    object ADOQuery1YERI: TIntegerField
      FieldName = 'YERI'
    end
    object ADOQuery1YERID: TIntegerField
      FieldName = 'YERID'
    end
    object ADOQuery1EKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object ADOQuery1EKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object ADOQuery1DEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object ADOQuery1DEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object ADOQuery1DOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 18
    end
    object ADOQuery1DOVIZKURDEGERI: TBCDField
      FieldName = 'DOVIZKURDEGERI'
      Precision = 19
    end
    object ADOQuery1PROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object ADOQuery1KAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object ADOQuery1VADE: TWordField
      FieldName = 'VADE'
    end
    object ADOQuery1STOKDURUMDEGIS: TBooleanField
      FieldName = 'STOKDURUMDEGIS'
    end
    object ADOQuery1SUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object ADOQuery1KDVMUHAFIYETI: TSmallintField
      FieldName = 'KDVMUHAFIYETI'
    end
    object ADOQuery1EKMALIYET: TBCDField
      FieldName = 'EKMALIYET'
      Precision = 19
    end
    object ADOQuery1BASTAR: TDateTimeField
      FieldName = 'BASTAR'
    end
    object ADOQuery1BITTAR: TDateTimeField
      FieldName = 'BITTAR'
    end
    object ADOQuery1URETIMPLANID: TIntegerField
      FieldName = 'URETIMPLANID'
    end
    object ADOQuery1URETIMPLANDETAYID: TIntegerField
      FieldName = 'URETIMPLANDETAYID'
    end
    object ADOQuery1MERKEZID: TIntegerField
      FieldName = 'MERKEZID'
    end
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 776
    Top = 536
  end
  object DataSource2: TDataSource
    Left = 520
    Top = 320
  end
  object ADOCommand1: TADOCommand
    Parameters = <>
    Left = 728
    Top = 312
  end
  object ADOQuery2: TADOQuery
    Parameters = <>
    Left = 88
    Top = 240
  end
  object QR_ftbaslik: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 344
    Top = 216
    object QR_ftbaslikID: TIntegerField
      FieldName = 'ID'
    end
    object QR_ftbaslikTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object QR_ftbaslikTUR: TIntegerField
      FieldName = 'TUR'
    end
    object QR_ftbaslikTIPI: TIntegerField
      FieldName = 'TIPI'
    end
    object QR_ftbaslikREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object QR_ftbaslikFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object QR_ftbaslikKOD: TStringField
      FieldName = 'KOD'
      Size = 30
    end
    object QR_ftbaslikFIRMA: TStringField
      FieldName = 'FIRMA'
      Size = 150
    end
    object QR_ftbaslikKDVDURUM: TStringField
      FieldName = 'KDVDURUM'
      Size = 5
    end
    object QR_ftbaslikFATURA_MATRAHI: TCurrencyField
      FieldName = 'FATURA_MATRAHI'
      DisplayFormat = '##,###.00'
    end
    object QR_ftbaslikKDV_TUTARI: TCurrencyField
      FieldName = 'KDV_TUTARI'
      DisplayFormat = '##,###.00'
    end
    object QR_ftbaslikFATURA_TUTARI: TCurrencyField
      FieldName = 'FATURA_TUTARI'
      DisplayFormat = '##,###.00'
    end
    object QR_ftbaslikFATURANO: TStringField
      FieldName = 'FATURANO'
      Size = 30
    end
    object QR_ftbaslikACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      Size = 200
    end
    object QR_ftbaslikAD: TStringField
      FieldName = 'AD'
      Size = 75
    end
    object QR_ftbasliksec: TIntegerField
      FieldName = 'sec'
    end
  end
  object QR_logohizmet: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    Left = 920
    Top = 600
  end
  object PopupMenu1: TPopupMenu
    Left = 640
    Top = 224
    object mnSe1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      OnClick = mnSe1Click
    end
  end
end
