object Tablo: TTablo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 623
  Width = 1239
  object IniSQL: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 135
    Top = 179
  end
  object Query1: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 18
    Top = 51
  end
  object Query2: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 58
    Top = 52
  end
  object Query3: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 99
    Top = 52
  end
  object Query4: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 17
    Top = 95
  end
  object Query5: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 59
    Top = 97
  end
  object Query6: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 99
    Top = 97
  end
  object TabLOG: TADOQuery
    AutoCalcFields = False
    Connection = cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'PTARIH'
        Attributes = [paNullable]
        DataType = ftDateTime
        Precision = 16
        Size = 16
        Value = Null
      end
      item
        Name = 'PTABLOID'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PSATIRID'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PEKLEYEN'
        Attributes = [paSigned, paNullable]
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end
      item
        Name = 'PSILME'
        Attributes = [paNullable]
        DataType = ftBoolean
        NumericScale = 255
        Precision = 255
        Size = 2
        Value = Null
      end>
    SQL.Strings = (
      'INSERT INTO [LOG] (TARIH, TABLOID,SATIRID,EKLEYEN,SILME) '
      'values( :PTARIH,:PTABLOID,:PSATIRID,:PEKLEYEN,:PSILME  ) '
      'SELECT SCOPE_IDENTITY()')
    Left = 657
    Top = 14
  end
  object cnn: TADOConnection
    CommandTimeout = 60
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=FETAGEN;Persist Security Info=True;' +
      'User ID=sa;Initial Catalog=AND;Data Source=KURTPC\SQLEXPRESS;Use' +
      ' Procedure for Prepare=1;Auto Translate=True;Packet Size=8192;Ap' +
      'plication Name=Gentegre;Workstation ID=ENTEGRA;Use Encryption fo' +
      'r Data=False;Tag with column collation when possible=False'
    ConnectionTimeout = 60
    CursorLocation = clUseServer
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    BeforeConnect = cnnBeforeConnect
    Left = 24
    Top = 7
  end
  object TabKullan: TADOTable
    Connection = cnn
    CursorType = ctStatic
    IndexFieldNames = 'ID'
    TableName = 'KULLANICI'
    Left = 904
    Top = 7
  end
  object TabListe: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 246
    Top = 11
  end
  object qryVadesiGelmisIslemler: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    AfterOpen = qryVadesiGelmisIslemlerAfterOpen
    Parameters = <
      item
        Name = 'VADEBASLA'
        Size = -1
        Value = Null
      end
      item
        Name = 'VADEBITIS'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'SELECT'
      
        #9'CARIKOD ,CARIAD,ACIKLAMA,GIREN,CIKAN,HESAPKODU,HESAPADI,VADE, K' +
        'UR '
      'FROM '
      #9'KASA '
      'WHERE '
      #9'VADE  BETWEEN :VADEBASLA AND :VADEBITIS')
    Left = 166
    Top = 317
  end
  object dsVadesiGelmisIslemler: TDataSource
    DataSet = qryVadesiGelmisIslemler
    Left = 168
    Top = 362
  end
  object tabMail: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 355
    Top = 7
  end
  object tabAraSQL: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 529
    Top = 4
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 886
    Top = 229
    PixelsPerInch = 96
    object cxstSecili: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14862279
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clGray
    end
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clInactiveBorder
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxTaksit: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 16751515
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      TextColor = clGray
    end
    object cxStFaturaKontrol: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 12189625
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clGray
    end
    object cxZrnAln: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      TextColor = clGray
    end
    object cxStSerinoCikilmis: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 8421631
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      TextColor = clBlack
    end
    object cxBlackBorder: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor]
      Color = clWhite
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor]
      Color = 14216668
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clBlack
      Font.Charset = TURKISH_CHARSET
      Font.Color = clDefault
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14408433
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      TextColor = clBlack
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor]
      Color = clSilver
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor]
      Color = clSilver
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor]
      Color = clSilver
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor]
      Color = clSilver
    end
    object cxStyle11: TcxStyle
      AssignedValues = [svColor]
      Color = clSilver
    end
    object cxStyle12: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      TextColor = clBlack
    end
    object cxStyle13: TcxStyle
      AssignedValues = [svColor]
      Color = clInactiveBorder
    end
    object cxStyle14: TcxStyle
      AssignedValues = [svColor]
      Color = clBlack
    end
    object cxStyle15: TcxStyle
      AssignedValues = [svColor]
      Color = clSilver
    end
    object cxStyle16: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object cxStyle18: TcxStyle
    end
    object cxstKismiIade: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
    object cxstTamIade: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clRed
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
    object cxStDogruBildirim: TcxStyle
      AssignedValues = [svColor]
      Color = clMoneyGreen
    end
    object cxStServerHata: TcxStyle
      AssignedValues = [svColor, svTextColor]
      Color = clInfoBk
      TextColor = 10834161
    end
    object cxStyle20: TcxStyle
      AssignedValues = [svColor]
      Color = 14740459
    end
    object cxStyle21: TcxStyle
    end
    object cxStyle22: TcxStyle
      AssignedValues = [svColor]
      Color = 15264226
    end
    object cxStyle23: TcxStyle
    end
    object cxStyle24: TcxStyle
      AssignedValues = [svColor]
      Color = 13821667
    end
    object cxStyle25: TcxStyle
    end
    object cxStyle26: TcxStyle
    end
    object cxStyle27: TcxStyle
    end
    object cxStyle28: TcxStyle
    end
    object cxStyle29: TcxStyle
    end
    object cxStyle30: TcxStyle
    end
    object cxStyle31: TcxStyle
    end
    object cxStyle32: TcxStyle
    end
    object cxStyle33: TcxStyle
    end
    object cxStyle34: TcxStyle
    end
    object cxStyle35: TcxStyle
    end
    object cxStyle36: TcxStyle
    end
    object cxStyle37: TcxStyle
    end
    object cxStyle38: TcxStyle
    end
    object cxStyle39: TcxStyle
    end
    object cxStyle40: TcxStyle
    end
    object cxGridCardViewStyleSheet1: TcxGridCardViewStyleSheet
      Styles.Background = cxStyle3
      Styles.Content = cxStyle4
      Styles.ContentEven = cxStyle4
      Styles.ContentOdd = cxStyle4
      Styles.FilterBox = cxStyle15
      Styles.Inactive = cxStyle4
      Styles.IncSearch = cxStyle16
      Styles.Selection = cxStyle12
      Styles.CaptionRow = cxStyle4
      Styles.CardBorder = cxStyle5
      Styles.CategoryRow = cxStyle13
      Styles.CategorySeparator = cxStyle14
      Styles.LayerSeparator = cxStyle10
      Styles.RowCaption = cxStyle4
      BuiltIn = True
    end
    object cxGridCardViewStyleSheetMsg: TcxGridCardViewStyleSheet
      Styles.Background = cxStyle20
      Styles.FilterBox = cxStyle26
      Styles.Inactive = cxStyle27
      Styles.IncSearch = cxStyle28
      Styles.Selection = cxStyle30
      Styles.CaptionRow = cxStyle21
      Styles.CardBorder = cxStyle22
      Styles.CategoryRow = cxStyle23
      Styles.CategorySeparator = cxStyle24
      Styles.LayerSeparator = cxStyle29
      Styles.RowCaption = cxStyle30
      BuiltIn = True
    end
  end
  object TabTeklifKurumlari: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    Left = 49
    Top = 271
  end
  object TabSiparisKurum: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    Left = 45
    Top = 312
  end
  object ADOQryGENEL: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 101
    Top = 193
  end
  object qryVadesiGelmisIslemOzet: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    AfterScroll = qryVadesiGelmisIslemOzetAfterScroll
    Parameters = <
      item
        Name = 'VADEBASLA'
        Size = -1
        Value = Null
      end
      item
        Name = 'VADEBITIS'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'SELECT'
      #9'SUM(GIREN) AS GIREN,SUM(CIKAN) AS CIKAN, KUR '
      'FROM '
      #9'KASA '
      'WHERE '
      #9'VADE  BETWEEN :VADEBASLA AND :VADEBITIS'
      '')
    Left = 53
    Top = 421
  end
  object dsVadesiGelmisIslemOzet: TDataSource
    DataSet = qryVadesiGelmisIslemOzet
    Left = 87
    Top = 422
  end
  object qryHesapGeriDonusIslemleri: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'PTARIH'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTARIH'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTARIH'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTARIH'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTARIH'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      ''
      
        'INSERT INTO KASA (TARIH, CARIKOD, CARIAD, ACIKLAMA, K.HESAPKODU,' +
        ' K.HESAPADI, GIREN, CIKAN, DOVIZ, KASA, ONAY, KULLANICI, MASRAFK' +
        'OD, MASRAFAD, VADE, KUR, GERIDONUSID)'
      'SELECT '
      #9'TARIH = :PTARIH ,'
      #9'CARIKOD,'
      #9'CARIAD,'
      #9'ACIKLAMA,'
      #9'K.HESAPKODU,'
      #9'K.HESAPADI,'
      #9'GIREN = 0,'
      #9'CIKAN = GIREN,'
      #9'DOVIZ ,'
      #9'KASA,'
      #9'ONAY='#39#39','
      #9'KULLANICI,'
      #9'MASRAFKOD,'
      #9'MASRAFAD,'
      #9'VADE=NULL,'
      #9'K.KUR,'
      #9'GERIDONUSID = SIRANO'
      ' FROM KASA K INNER JOIN HESAPLAR H'
      #9#9#9'ON K.HESAPKODU = H.HESAPKODU'
      'WHERE'
      #9'ISNULL(K.HESAPKODU,'#39#39') LIKE '#39'108%'#39' AND'
      #9'ISNULL(CARIKOD,'#39#39') NOT LIKE '#39'KASA'#39' AND'
      #9'ISNULL(GERIDONUSID,0) = 0 AND'
      #9'ISNULL(VADE,'#39'1900-01-01'#39')<= :PTARIH'
      ''
      'UNION ALL'
      'SELECT '
      #9'TARIH = :PTARIH ,'
      #9'CARIKOD,'
      #9'CARIAD,'
      #9'ACIKLAMA,'
      #9'H.GERIDONUSHESAPKODU,'
      
        #9'HESAPADI = (SELECT HESAPADI FROM HESAPLAR WHERE HESAPKODU = H.G' +
        'ERIDONUSHESAPKODU ),'
      #9'GIREN = GIREN,'
      #9'CIKAN = 0,'
      #9'DOVIZ ,'
      #9'KASA,'
      #9'ONAY='#39#39','
      #9'KULLANICI,'
      #9'MASRAFKOD,'
      #9'MASRAFAD,'
      #9'VADE=NULL,'
      #9'K.KUR,'
      #9'GERIDONUSID = SIRANO'
      ' FROM KASA K INNER JOIN HESAPLAR H'
      #9#9#9'ON K.HESAPKODU = H.HESAPKODU'
      'WHERE'
      #9'ISNULL(K.HESAPKODU,'#39#39') LIKE '#39'108%'#39' AND'
      #9'ISNULL(CARIKOD,'#39#39') NOT LIKE '#39'KASA'#39' AND'
      #9'ISNULL(GERIDONUSID,0) = 0 AND'
      #9'ISNULL(VADE,'#39'1900-01-01'#39')<= :PTARIH'
      ''
      'ORDER BY GERIDONUSID,CIKAN DESC'
      ''
      'UPDATE KASA SET GERIDONUSID = 1 '
      ' FROM KASA K INNER JOIN HESAPLAR H'
      #9#9#9'ON K.HESAPKODU = H.HESAPKODU'
      'WHERE'
      #9'ISNULL(K.HESAPKODU,'#39#39') LIKE '#39'108%'#39' AND'
      #9'ISNULL(CARIKOD,'#39#39') NOT LIKE '#39'KASA'#39' AND'
      #9'ISNULL(GERIDONUSID,0) = 0  AND'
      #9'ISNULL(VADE,'#39'1900-01-01'#39') <= :PTARIH')
    Left = 53
    Top = 471
  end
  object DtsKullan: TDataSource
    DataSet = TabKullan
    Left = 910
    Top = 71
  end
  object XMLDocument1: TXMLDocument
    Left = 661
    Top = 136
    DOMVendorDesc = 'MSXML'
  end
  object TabKimlik: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    Left = 405
    Top = 4
  end
  object TabBanka: TADOTable
    Connection = cnn
    CursorType = ctStatic
    LockType = ltReadOnly
    IndexName = 'PK_BANKALAR_1'
    TableName = 'BANKALAR'
    Left = 448
    Top = 64
  end
  object TabSube: TADOTable
    Connection = cnn
    CursorType = ctStatic
    LockType = ltReadOnly
    IndexName = 'PK_BANKASUBELER_1'
    TableName = 'BANKASUBELER'
    Left = 496
    Top = 64
  end
  object HTTPRIOImza: THTTPRIO
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 764
    Top = 181
  end
  object ImageList1: TImageList
    Left = 388
    Top = 301
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 432
    Top = 286
  end
  object TabBizim: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'Declare @IletisimID integer'
      
        'select top 1 @IletisimID = ID from REHBERILETISIM where REHBERID' +
        '=-1  order by VARSAYILAN desc'
      '    select'
      
        '    '#9'KOD,FIRMA,GRUP,KATEGORI,DURUM,OZELKOD,ARAMADACIKSIN,NOTLAR,' +
        'YETKIKODU,'
      
        '    '#9'KATEGORIADI=(select top 1 ANAHTAR from GENINI where BOLUM=-' +
        '2204 and DEGER=KATEGORI),'
      
        '    '#9'GOREVADI=(select top 1 ANAHTAR from GENINI where BOLUM=-220' +
        '5 and DEGER=KATEGORI),'
      
        '    '#9'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=40),'
      
        '    '#9'CEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '2),'
      
        '    '#9'FAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '3),'
      
        '    '#9'ADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=2),'
      
        '    '#9'ILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=' +
        '6),'
      
        '    '#9'IL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=8)' +
        ','
      
        '    '#9'PK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4)' +
        ','
      
        '    '#9'VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=20),'
      
        '    '#9'VERGINO=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=22),'
      
        '    '#9'WEB=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '8),'
      
        '    '#9'EMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=46),'
      
        '    '#9'FATURABASLIK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (noloc' +
        'k) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB' +
        '.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=1' +
        '0),'
      
        '    '#9'LOGO= (SELECT  TOP 1 BELGE FROM IMAJ I WHERE VARSAYILAN=1 A' +
        'ND YERI=11 AND YER_ID=-1 ),'
      
        '    '#9'VERGIDAI_KODU=(select TOP 1  VDKODU FROM VDLISTE VD WHERE V' +
        'D.VD =(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA' +
        '.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=20)),'
      
        '      VERGI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=20)+'#39' /' +
        ' '#39'+(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN R' +
        'EHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YE' +
        'RI=RB.YERI WHERE RB.YER_ID=-1 AND RA.VARSAYILAN=22)'
      '      from'
      '      '#9'REHBER R'
      '      WHERE ID = -1')
    Left = 712
    Top = 16
  end
  object DtsBizim: TDataSource
    DataSet = TabBizim
    Left = 758
    Top = 19
  end
  object TabYetki: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'PRolID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'declare @RolID int'
      'set @RolID=:PRolID'
      'select Y.MODULID,Y.TUR,ROLID=@RolID,Y.HAK,Y.BILGI'
      'FROM'
      #9'YETKI Y '
      'WHERE isnull(Y.ROLID,@RolID)=@RolID ')
    Left = 859
    Top = 13
  end
  object IdFTP1: TIdFTP
    OnStatus = IdFTP1Status
    IPVersion = Id_IPv4
    Host = 'ftp01.garanti.com.tr'
    Password = 'moisT62comp'
    Username = 'garfetabilg'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 667
    Top = 422
  end
  object dxSkinController1: TdxSkinController
    Kind = lfOffice11
    SkinName = 'LondonLiquidSky'
    Left = 505
    Top = 236
  end
  object frxMusteri: TfrxDBDataset
    UserName = 'Musteri'
    CloseDataSource = False
    DataSet = TabMusteri
    BCDToCurrency = False
    Left = 808
    Top = 67
  end
  object TabMusteri: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select top 1 * from REHBER')
    Left = 810
    Top = 16
  end
  object HTTPRIOLisans: THTTPRIO
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 766
    Top = 132
  end
  object TabDokum: TADOQuery
    Connection = cnn
    BeforePost = TabDokumBeforePost
    Parameters = <
      item
        Name = 'PID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'SELECT * FROM DOKUMLER D WHERE ID = :PID')
    Left = 196
    Top = 11
  end
  object TabKosul: TADOQuery
    Connection = cnn
    BeforePost = TabKosulBeforePost
    OnNewRecord = TabKosulNewRecord
    Parameters = <
      item
        Name = 'DID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'SELECT * FROM KOSULLAR WHERE DOKUMID = :DID ORDER BY ID')
    Left = 146
    Top = 10
  end
  object TabDokumYaz: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    LockType = ltReadOnly
    Parameters = <>
    Left = 298
    Top = 6
  end
  object cnn2: TADOConnection
    CommandTimeout = 60
    ConnectionTimeout = 5
    KeepConnection = False
    LoginPrompt = False
    Left = 63
    Top = 7
  end
  object IdSMTP1: TIdSMTP
    SASLMechanisms = <>
    Left = 568
    Top = 368
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'UUE'
    BccList = <>
    CCList = <>
    Encoding = meDefault
    FromList = <
      item
      end>
    Recipients = <>
    ReplyTo = <>
    ConvertPreamble = True
    Left = 512
    Top = 368
  end
  object cxEditRepository1: TcxEditRepository
    Left = 883
    Top = 127
    object cxEditRepository1BlobItem1: TcxEditRepositoryBlobItem
    end
    object cxEditRepository1ButtonItem1: TcxEditRepositoryButtonItem
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = cxEditRepository1ButtonItem1PropertiesButtonClick
    end
    object cxEditRepository1CalcItem1: TcxEditRepositoryCalcItem
      Properties.Alignment.Horz = taRightJustify
      Properties.DisplayFormat = '###,###,##0.00'
      Properties.UseThousandSeparator = True
    end
    object cxEditRepository1CheckBoxItem1: TcxEditRepositoryCheckBoxItem
      Properties.ImmediatePost = True
      Properties.NullStyle = nssUnchecked
    end
    object cxEditRepository1CheckComboBox1: TcxEditRepositoryCheckComboBox
      Properties.Delimiter = ','
      Properties.EmptySelectionText = 'Se'#231'im Yok'
      Properties.ClearKey = 46
      Properties.EditValueFormat = cvfCaptions
      Properties.ImmediatePost = True
      Properties.Items = <
        item
        end>
    end
    object cxEditRepository1CheckGroupItem1: TcxEditRepositoryCheckGroupItem
      Properties.Columns = 50
      Properties.ImmediatePost = True
      Properties.Items = <>
      Properties.WordWrap = True
    end
    object cxEditRepository1ColorComboBox1: TcxEditRepositoryColorComboBox
      Properties.ColorComboStyle = cxccsComboList
      Properties.CustomColors = <>
    end
    object cxEditRepository1ComboBoxItem1: TcxEditRepositoryComboBoxItem
      Properties.ClearKey = 46
    end
    object cxEditRepository1CurrencyItem1: TcxEditRepositoryCurrencyItem
      Properties.Alignment.Horz = taRightJustify
      Properties.ClearKey = 46
      Properties.DecimalPlaces = 2
      Properties.DisplayFormat = ',0.00;-,0.00'
      Properties.EditFormat = ',0.00;-,0.00'
      Properties.UseDisplayFormatWhenEditing = True
      Properties.UseThousandSeparator = True
    end
    object cxEditRepository1DateItem1: TcxEditRepositoryDateItem
    end
    object cxEditRepository1ExtLookupComboBoxItem1: TcxEditRepositoryExtLookupComboBoxItem
    end
    object cxEditRepository1FontNameComboBox1: TcxEditRepositoryFontNameComboBox
    end
    object cxEditRepository1HyperLinkItem1: TcxEditRepositoryHyperLinkItem
    end
    object cxEditRepository1Label1: TcxEditRepositoryLabel
    end
    object cxEditRepository1LookupComboBoxItem1: TcxEditRepositoryLookupComboBoxItem
      Properties.ListColumns = <>
    end
    object cxEditRepository1MaskItem1: TcxEditRepositoryMaskItem
      Properties.EditMask = '\(999\)999-9999'
    end
    object cxEditRepository1MemoItem1: TcxEditRepositoryMemoItem
    end
    object cxEditRepository1MRUItem1: TcxEditRepositoryMRUItem
    end
    object cxEditRepository1PopupItem1: TcxEditRepositoryPopupItem
    end
    object cxEditRepository1ProgressBar1: TcxEditRepositoryProgressBar
    end
    object cxEditRepository1RadioGroupItem1: TcxEditRepositoryRadioGroupItem
      Properties.Items = <>
    end
    object cxEditRepository1RichItem1: TcxEditRepositoryRichItem
    end
    object cxEditRepository1ShellComboBoxItem1: TcxEditRepositoryShellComboBoxItem
    end
    object cxEditRepository1SpinItem1: TcxEditRepositorySpinItem
      Properties.ClearKey = 46
      Properties.ImmediatePost = True
      Properties.UseCtrlIncrement = True
    end
    object cxEditRepository1TextItem1: TcxEditRepositoryTextItem
    end
    object cxEditRepository1TimeItem1: TcxEditRepositoryTimeItem
    end
    object cxEditRepository1TrackBar1: TcxEditRepositoryTrackBar
    end
    object cxEditRepository1TextPasswordItem: TcxEditRepositoryTextItem
      Properties.EchoMode = eemPassword
      Properties.IncrementalSearch = False
      Properties.PasswordChar = '*'
    end
    object cxEditRepository1ComboBoxItemKurlar: TcxEditRepositoryComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownRows = 5
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.MaxLength = 0
    end
    object repStokAnaBirim: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repServisTeslimSekli: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repServisTuru: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <
        item
          ImageIndex = 0
        end
        item
          Description = #304#231' Servis'
          Value = 0
        end
        item
          Description = 'D'#305#351' Servis'
          Value = '1'
        end>
    end
    object repServisDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repServisUcreti: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repServisKonusu: TcxEditRepositoryComboBoxItem
      Properties.MaxLength = 0
    end
    object repAktiviteTuru: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repAktiviteKonum: TcxEditRepositoryImageComboBoxItem
      Properties.Alignment.Horz = taLeftJustify
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repAktiviteOncelik: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repAktivitePuan: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repAktiviteDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repAktiviteTipi: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repAktiviteKonu: TcxEditRepositoryComboBoxItem
      Properties.ImmediatePost = True
      Properties.MaxLength = 0
    end
    object repTeklifBilgi: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repTeklifDurumu: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repTeklifTuru: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repTeklifTeslimSekli: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repTeklifOdeme: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repTeklifKonusu: TcxEditRepositoryComboBoxItem
    end
    object repTeklifKonusuimage: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repDemirbasAlimSekli: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repProjeTuru: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repProjeAsama: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repProjeDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repProjeKonu: TcxEditRepositoryComboBoxItem
      Properties.ImmediatePost = True
      Properties.MaxLength = 0
    end
    object repStokMarka: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repStokTipi: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repStokOzellik: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repStokGrubu: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repStokZamanBirimi: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repStokDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repProjeSonuc: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object RepAktifPasif: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Aktif'
          ImageIndex = 0
          Value = True
        end
        item
          Description = 'Pasif'
          Value = False
        end>
    end
    object RepPOSTuru: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepPOSStatusu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepKasaTurleriReadOnly: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.ReadOnly = True
    end
    object RepBankaHesapHareketleriDurum: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Aktar'#305'labilir'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'Aktar'#305'ld'#305
          Value = 1
        end
        item
          Description = 'Cari Tan'#305'ms'#305'z'
          Value = 2
        end
        item
          Description = #304#351'lem Tan'#305'ms'#305'z'
          Value = 3
        end>
      Properties.ReadOnly = True
    end
    object repGenelPersonelListesi: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.Images = PNGImageList2
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.LargeImages = PNGImageList2
    end
    object RepFiyatAdlari: TcxEditRepositoryImageComboBoxItem
      Properties.DefaultImageIndex = 0
      Properties.Items = <>
    end
    object RepStokBirimlerUzunluk: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepStokBirimlerAgirlik: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepStokBirimlerHacim: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepStokBirimlerAlan: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepDBBaglantiTurleri: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Description = 'Gentegre'
          Value = 0
        end
        item
          Description = 'GenoTIP'
          Value = 1
        end>
    end
    object RepStokDepolar: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepHizliGirisKisayolGruplari: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repProjeTipi: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.ImmediatePost = True
      Properties.Items = <>
    end
    object RepKDVDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Description = '+KDV'
          ImageIndex = 0
          Value = False
        end
        item
          Description = 'Dahil'
          Value = True
        end>
    end
    object RepKasaTurleri: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object RepStokAnaliz: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repStokKartBarkodTipi: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.DropDownRows = 10
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <
        item
          Description = 'U.P.C'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Code 39'
          Value = 2
        end
        item
          Description = 'Code 93'
          Value = 3
        end
        item
          Description = 'Code 128'
          Value = 4
        end
        item
          Description = 'Code 128A'
          Value = 5
        end
        item
          Description = 'Code 128B'
          Value = 6
        end
        item
          Description = 'Code 128C'
          Value = 7
        end
        item
          Description = 'EAN 13'
          Value = 8
        end>
    end
    object repSayimTutanakTipi: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.Items = <>
    end
    object repRehberVarsayilanListesi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepFiyatAdlariAlis: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepCekDurum_Alinan: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.Items = <>
    end
    object repSiparisDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repBelgeDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repIrsaliyeDurum: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object RepServisDetayGruplari: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepServisEkipmanTur: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Ekipman'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'Bile'#351'en'
          Value = 1
        end>
    end
    object RepisOrtagiiliskiTuru: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object Repiller: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepBelge_Turu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepCurrencyItem: TcxEditRepositoryCurrencyItem
      Properties.DisplayFormat = ',0.00;'
      Properties.EditFormat = ',0.00;'
      Properties.UseDisplayFormatWhenEditing = True
      Properties.UseThousandSeparator = True
    end
    object RepDepoVarsayilanListesi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repServisKabulSekli: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repServisBildirimSekli: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repServisBildirimYazisi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepProjeAplikasyon: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repServisOnaySekli: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepStokIzleme: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object RepDiller: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepFatDetayTur: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repZamanBirimleri: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Dakika'
          ImageIndex = 0
          Value = 10
        end
        item
          Description = 'Saat'
          Value = 11
        end
        item
          Description = 'G'#252'n'
          Value = 12
        end>
    end
    object RepCariGrup: TcxEditRepositoryImageComboBoxItem
      Tag = -2202
      Properties.Items = <>
    end
    object RepCariSinif: TcxEditRepositoryImageComboBoxItem
      Tag = -2203
      Properties.Items = <>
    end
    object RepCariKategori: TcxEditRepositoryImageComboBoxItem
      Tag = -2204
      Properties.Items = <>
    end
    object RepCariGorev: TcxEditRepositoryImageComboBoxItem
      Tag = -2205
      Properties.Items = <>
    end
    object repKampanyaKosulTur: TcxEditRepositoryImageComboBoxItem
      Tag = -2781
      Properties.Items = <>
    end
    object repKampanyaSonucTur: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repKampanyaTur: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repCheckComboHaftaninGunleri: TcxEditRepositoryCheckComboBox
      Properties.Delimiter = ','
      Properties.EmptySelectionText = 'Se'#231'im Yok'
      Properties.ClearKey = 46
      Properties.EditValueFormat = cvfIndices
      Properties.ImmediatePost = True
      Properties.Items = <
        item
        end>
    end
    object RepMasrafTuru: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repMasrafGrubu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repMasrafaSozlesmeTipi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repMasrafVarMerkezleri: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepDemirbas_Islem: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repDemirbasDurum: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repFileExtensionList: TcxEditRepositoryImageComboBoxItem
      Properties.Alignment.Horz = taLeftJustify
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.ReadOnly = True
      Properties.ShowDescriptions = False
    end
    object RepDokumanKonusu: TcxEditRepositoryComboBoxItem
    end
    object RepDokumanKategori: TcxEditRepositoryComboBoxItem
      Properties.MaxLength = 0
    end
    object RepDokumanModul: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepDokumanBolumu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepDokumanYonu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repDokumanTip: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'K'#305'sayol'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'Belge'
          Value = 1
        end>
    end
    object repDokumanKlasor: TcxEditRepositoryImageComboBoxItem
      Properties.Alignment.Horz = taLeftJustify
      Properties.Images = KlasorResimleri
      Properties.Items = <>
      Properties.LargeImages = KlasorResimleri
    end
    object RepCariBolum: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepSubeler: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepSubelerOrtak: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepCurrencyBF: TcxEditRepositoryCurrencyItem
      Properties.UseDisplayFormatWhenEditing = True
      Properties.UseThousandSeparator = True
    end
    object RepCurrencyGenel: TcxEditRepositoryCurrencyItem
      Properties.UseDisplayFormatWhenEditing = True
      Properties.UseThousandSeparator = True
    end
    object RepCurrencyDovizKuru: TcxEditRepositoryCurrencyItem
      Properties.Alignment.Horz = taRightJustify
      Properties.DisplayFormat = ',0.00;-,0.00'
      Properties.UseDisplayFormatWhenEditing = True
      Properties.UseThousandSeparator = True
    end
    object RepCurrencyAdetGenel: TcxEditRepositoryCurrencyItem
      Properties.DecimalPlaces = 6
      Properties.DisplayFormat = ',0.####;-,0.####'
      Properties.EditFormat = ',0.####;-,0.####'
      Properties.UseDisplayFormatWhenEditing = True
    end
    object RepCompenentTurleri: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Description = 'Yaz'#305
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Rakam'
          Value = 2
        end
        item
          Description = 'Tarih'
          Value = 3
        end
        item
          Description = 'Liste(Combo)'
          Value = 4
        end
        item
          Description = 'Se'#231'(Check)'
          Value = 5
        end
        item
          Description = 'Liste( Img Combo )'
          Value = 6
        end
        item
          Description = 'Btn Edit'
          Value = 7
        end
        item
          Description = 'Check Combo'
          Value = 8
        end
        item
          Description = 'Check Group'
          Value = 9
        end
        item
          Description = 'Mask Edit'
          Value = 10
        end
        item
          Description = 'Ba'#351'l'#305'k(Label)'
          Value = 11
        end
        item
          Description = 'Bilgi(Label)'
          Value = 12
        end>
    end
    object RepKrediKartiTuru: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepSenetDurum: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Genel'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Hizmete '#214'zel'
          Value = 2
        end
        item
          Description = #214'zel'
          Value = 3
        end
        item
          Description = 'Gizli'
          Value = 4
        end
        item
          Description = #199'ok Gizli'
          Value = 5
        end>
    end
    object RepDokumanArsiv: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = '1 Y'#305'l'
          ImageIndex = 0
          Tag = 1
          Value = 1
        end
        item
          Description = '2 Y'#305'l'
          Tag = 2
          Value = 2
        end
        item
          Description = '3 Y'#305'l'
          Tag = 3
          Value = 3
        end
        item
          Description = '4 Y'#305'l'
          Tag = 4
          Value = 4
        end
        item
          Description = '5 Y'#305'l'
          Tag = 5
          Value = 5
        end
        item
          Description = 'Di'#287'er'
          Tag = 6
          Value = 6
        end>
    end
    object RepStokIcerik: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repOnlinePersonel: TcxEditRepositoryImageComboBoxItem
      Properties.Images = PNGImageList2
      Properties.Items = <>
    end
    object repDuyuruOnem: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repDuyuruKategori: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepDokumanGizlilik: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepSubelerOrtakKendiSubesi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepSubelerKendiSubesi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepSubelerOrtakTumSubeler: TcxEditRepositoryImageComboBoxItem
      Properties.ClearKey = 46
      Properties.Items = <>
    end
    object RepIzinTurleri: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
      Properties.ReadOnly = True
    end
    object RepIzinTurleriBirim: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
      Properties.ReadOnly = True
    end
    object RepBilgilendirme: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'G'#246'nderme'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = #304'lkinde G'#246'nder'
          Value = 1
        end
        item
          Description = 'Her Defas'#305'nda G'#246'nder'
          Value = 2
        end
        item
          Description = 'Kullan'#305'c'#305'ya Sor'
          Value = 3
        end>
    end
    object RepAktiviteEpostaRapor: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepServisEpostaRapor: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepDilCeviri: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'T'#252'rk'#231'e'
          ImageIndex = 0
          Tag = 1
          Value = -1
        end
        item
          Description = #304'ngilizce'
          Tag = 2
          Value = -2
        end
        item
          Description = 'Almanca'
          Tag = 3
          Value = -3
        end
        item
          Description = 'Rus'#231'a'
          Tag = 4
          Value = -4
        end>
    end
    object RepDokumanBildirimTurleri: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Silme'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Revizyon'
          Value = 2
        end
        item
          Description = 'Tarama'
          Value = 3
        end
        item
          Description = 'G'#246'rme'
          Value = 4
        end
        item
          Description = 'E-Posta'
          Value = 5
        end
        item
          Description = 'Ver (Export)'
          Value = 6
        end
        item
          Description = 'T'#252'm'#252
          Value = 0
        end>
    end
    object RepKaliteEpostaRapor: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepKaliteToplantiDurum: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Plan'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Ertelendi'
          Value = 2
        end
        item
          Description = #304'ptal'
          Value = 3
        end
        item
          Description = 'Yap'#305'ld'#305
          Value = 4
        end>
    end
    object RepKaliteTespitKaynagi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Denetim'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = 'M'#252#351'teri Geri Bildirim'
          Value = 1
        end
        item
          Description = 'Toplant'#305'lar'
          Value = 2
        end
        item
          Description = 'Veri Analizi'
          Value = 3
        end
        item
          Description = 'Rutin '#199'al'#305#351'ma S'#305'ras'#305'nda Tespit'
          Value = 4
        end
        item
          Description = 'Kanun ve Y'#246'netmelikler'
          Value = 5
        end
        item
          Description = 'Di'#287'er'
          Value = 6
        end>
    end
    object RepKaliteDofFaaliyet: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'D'#252'zeltici'
          ImageIndex = 0
          Value = 0
        end
        item
          Description = #214'nleyici'
          Value = 1
        end
        item
          Description = 'Geli'#351'tirici,'#304'yile'#351'tirici'
          Value = 2
        end
        item
          Description = #214'd'#252'llendirici'
          Value = 3
        end>
    end
    object repUretimFisiGRP: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = #220'r'#252'n'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Sarf'
          Value = 0
        end>
    end
    object RepStokBoyutlar: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repStokBoyutKombinasyonlar: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object repServisKapsam: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepStokKartBarkodAyarlar: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
    end
    object RepCariBolge: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repOnayliOnaysiz: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = 'Onayl'#305
          ImageIndex = 0
          Tag = 1
          Value = True
        end
        item
          Description = 'Onays'#305'z'
          Value = False
        end>
    end
    object RepTeklifBilgiSablonu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepHizliSatisTerazi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepPDKSDurum: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object rep: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object cxEditRepository1ImageComboBoxItem1: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repStokKDV: TcxEditRepositoryComboBoxItem
      Tag = -2790
      Properties.DropDownListStyle = lsFixedList
    end
    object repStokIzlemeSKT: TcxEditRepositoryDateItem
      Properties.DateButtons = [btnToday]
      Properties.ImmediatePost = True
      Properties.InputKind = ikStandard
      Properties.SaveTime = False
      Properties.ShowTime = False
    end
    object repStokKartFisTipi: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepStokKaynakUretimYeri: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object repStokMaliyetTipi: TcxEditRepositoryImageComboBoxItem
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <
        item
          Description = 'Son Al'#305#351
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Ortalama'
          Value = 2
        end>
    end
    object RepGorunurDurumu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepStokKartEkstraTUR: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepSatinalmaAsama: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepAktivite_TarihceDurumu: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
<<<<<<< .mine    end
=======>>>>>>> .theirs  end
  object TabLOGHAR: TADOQuery
    AutoCalcFields = False
    Connection = cnn
    Parameters = <
      item
        Name = 'PLOGID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTABLOALANADI'
        Size = -1
        Value = Null
      end
      item
        Name = 'PESKIALANDEGERI'
        Size = -1
        Value = Null
      end
      item
        Name = 'PYENIALANDEGERI'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'INSERT INTO [LOGHAR] (LOGID, TABLOALANADI,ESKIALANDEGERI,YENIALA' +
        'NDEGERI)'
      ' VALUES '
      '(:PLOGID,:PTABLOALANADI,:PESKIALANDEGERI,:PYENIALANDEGERI)')
    Left = 657
    Top = 62
  end
  object cxStilTanimlari: TcxStyleRepository
    Left = 888
    Top = 282
    PixelsPerInch = 96
    object cxStyle2: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
    object gridStil_1: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = 14740459
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
    end
    object cxStyle17: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = 14740459
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
    end
    object cxStyle19: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = 11776947
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
  end
  object tabStilKosul: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT * FROM STILKOSUL'
      'ORDER BY GRIDADI')
    Left = 308
    Top = 123
  end
  object dtsStilKosul: TDataSource
    DataSet = tabStilKosul
    Left = 308
    Top = 164
  end
  object PNGImageList1: TPngImageList
    Height = 24
    ShareImages = True
    Width = 24
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D650046722031392044657A
          20323030332032303A32333A3337202B30313030813344B70000000774494D45
          07D302180F360D4BE242C4000000097048597300000AF000000AF00142AC3498
          000003244944415478DAB5955D48536118C7FF673BFB389BBAF931BF6A7E4418
          66621282D0320AAD8B2EBA29F26242449917050975A3E14D58541765105850D0
          85425D54445150614496C198384B05334D376C5BEDE36C3B673BEEECF48A0B22
          8A7396F6C08FF73DF03ECFEF79CECBE150F8CF41293DB8F5FC27ABB8143ACD0B
          D43E3E912CA5698ACDD652C32A7DD6155757F59B5509B6F42EEC0B07DD837A5A
          97D3526D46ADD5004F40C0D05418337E2E65292AB938DE55D6F54F82AA9EE9BA
          70C8F7AE725D01D35C6386D9A801A3A11017530846454C2E721872F9A5A26C53
          E7646F555FC6820D9D8EE71183B179FBA65C980D344C040DAD425292C0F22291
          2C61DCCD23363F1FE1455379E8465D50B1C0DA396EE184E822576855D7963128
          36E9C0E8D4A0D56A8890C0F1292C461298F2C4B1E4F3A194E7EC9FFB1B07140B
          4A8E0C374673987791E20A806140E9B530E954D0AA2588290A2181AC4212E0E3
          D0B04114BAE7CE796EEFEC512C283EFCB23E9A5BE08C6EDC0C464FC3A20372B4
          00190229098891DA8138F03D2181F6FB9137397ED63BD0DCABFC0E5AE6F479E5
          F37ED6B623CB4A8A973240BE1ED0AB56042C117879C043E026A69135E36EF1DD
          DBFD22A34BCE3FF0F89A7A57D3C9F2F5D9B01241A9814CA10184D44AF70B1C30
          4F56DFDD2793C1ECDC5ADCDA2E662430360F991883DB53656F35D65A69949309
          8A8C403CB9527C260ABC197CCDC5FCAADDEC831DEF7FCF97159C3A7174EBB606
          9BF3C25335C5D434606F5325EA2BB4F81A4EE2E57B37869F7D98E5C5ACB6E8C3
          5DC37FCA9715B4B7B75F6A3D74F0CCF5AB9711944AE0F4ADFF18323638288811
          9D5AF5369E13BB8FFBF6C4DFF2E504AAEEEEEE599AA6CBC6C6C6F0CDEFF57291
          7083D335B120D798224147474793C56279353A3A4A0982B0140804F6381C8E57
          4A8BCB0AEC767BBF46A339EEF1782496653B474646FA94165624686B6B737BBD
          DE75A4F347A4F3FD99169715D86CB69BA4F39D2E97EB0E795C7E355384C09A09
          48E4138E11BEA4891158823FBD97562B588E2A4221817C56E0D3706964254A04
          CB67AAD3FB789A9FA2F85A4CB01CC6F41489343F45A25CA2E29F3E093341F58B
          40B678A6827F8A1F00E04828CFDADDDF0000000049454E44AE426082}
        Name = 'PngImage1'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004D6F203133204F6B74
          20323030332031333A35353A3236202B30313030C66A42120000000774494D45
          07D30A0D0B37352A458FAB000000097048597300000AF000000AF00142AC3498
          000001E84944415478DAED934D6B134118C77FBB79E93631D8F92E7E0341281E
          140FE2C9838A2D8269159BFA82055B4B051B15C41E04C583B48A7A10AB785214
          45024AA4DA835503A6DA585AB649F3D2CDEE66D7A7F603A45B237AE80CC30C33
          0FFFDF3C33CF5FE32F376D13F01F03AEF1129F714A5CE70C5ECB01DA98667618
          31B554AE664990E400AF5A9BC155CCAEED9DEA41E619C565C777756F9C18290E
          32D71A401AF3564FAF3A7DF7060923C272C9A6305F2913E63C51AED083FD6780
          8B986347F7AB1753B36472EF046210D542E4BF975858A8CD10E7187D3CD93860
          04F3D291BDCAF713A41FDF61ABD18E110E138B86712D8F8F338B7E75C59EC4E0
          3827F9121C308C79A17B8FD2E54DB2B379BE15E688847442721411505C403F0A
          65DE4FFDB4EA5A638441E981004398C38777ABD580E9F9453E7CFE4ADD696059
          8ECC2EB6DDC0AEB8D48A8EE3E9FE65B9507F30C020E6D0A19DCA30147D376FAF
          45AEBAC197E1C8A8CA4AE7B9A494E41CD3C19F6840005D9D2A932B3299798388
          81FB5B18EAE4C51B27C480F736FEC967314793FB546AE23E9E2BCA2BB257C6A2
          8D512A5202696ACDC49B66B06BC736F5F0F55B44D097C8476C91D24C915B8F70
          53803EA099EDF136555DB23ED141AF94E2D320C2CD33384556EE3D8112D7F6AF
          CFB5C1002D6A9B807F0FF8053CF3B719AABEC0500000000049454E44AE426082}
        Name = 'PngImage0'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002A744558744372656174696F6E2054696D6500536120392046656220
          323030322031363A30313A3531202B3031303091DB5A390000000774494D4507
          D302171613070850F394000000097048597300000AF000000AF00142AC349800
          0004244944415478DAE595CB6F54551CC73FF73173E7D999DE19DA81690B7D20
          50DAD20E8D69342D0A4989242C14176E4CFC0B88C6E8C2C4C4B0D0050B2571A3
          4B1243A231C1C4B8513B051F98B48232409142DF43DBE94CDB994EE7DD7B3D53
          30B4A5540DB2F2979C7B734F4EBE9FDF39BFEFFD1D89271CD2FF0F6006714C41
          9BB5C458F52C338F0530F752913568378B74140C42D8D550DAEDDCA3792A2CF1
          E1E89056320E354699FB4700B3151F32ED9484D0AA98359472BA1BA50A976271
          BBB055B84015CB4B45300C56B225AE7E1B19945638D29120B525C06CE7A392DD
          7672A5B651523D2E14CD028A02C5022CA72197C3705460787C98DE005221833A
          718D5CC6E0D78BB7C28138C79AC4AA4702529DB6A8BBE7991D9981DF71F41E85
          A9114A8B290A75FB30B605C0B71DD9A222CB0AB22421593594CB61E4B1084B8B
          05067E19FF6AE7022F0B48695340A24D9DD49FEDACC94763987A401C87863937
          4DB2FB04B2220B5119451500D58A6CB5A2583424714C5CF81C692E4A22B6CCC5
          8199B32FA6794D089A0F01C61AF866E7D37B5EC0EF67FEE72BE8477B617A8482
          C347F6E06184346A2E85924A202FC490E251A4D4BC909256EB2132606A2AC56F
          5713678E6779FD21C09D5DBC5A15F49E7535D5525C91599A49A2EFDB05B1BB94
          BC55A849B13351DCD5ACF92B47F130C430C55C795A85913B8BE6D4CDF47B878A
          9C5A07382F4ADAB28B81C6F6BA0EB655331719C6D3DE8E754938B098BF275816
          37CD0D6FE301A41CC217D76F25CDBBB773277B0D3E5E67D3C520DDE94ADB8560
          738D84CBCBC4E01FD475876066620D608DA0B13A797F37E5EF15C8175998CF11
          8E140D97498FB0CB4FEB7EB4A16ACE35B5F85E5183D52C4EA7901C1E3C76618C
          6C668DE0FD6CCB82D902F1B965A66325A2869599FA560875E2F1E96FBCF4FE07
          67B857A50731AA539B762A432DA180137F15C33FDE6077CF41981D174B856026
          CF627C9978BCC084EC64BA760FF9FD0730DA42586B77E250653461E14ABFBFA7
          3BD4F1C3A6ADE29287777737394EF91A03A4932592530994429611C3C9E48EA7
          48EE6E26D77C0045D4CA26FE0DBB189AB0B026ECABD9EC583D3A2DE1CFDEF6BF
          75FAF4A68051B08D5472E370A7B7FEDCD50CFD2D5DD8F777E0AEA9C357E1C6A6
          94B3B4A0592C5885A0AAD950CAC262E8E918550BE3E85F7E62BA239137A59B7C
          B869B3BB64E784EAE48BAF830DD2EDAE5E827A253E5DC7ABFB50C411C862A836
          1BDB9766A9498C50393984E3FA20C6ECACE14CE76F0889B0AA705E1AA2EF91DD
          B44FE3BBC1BD0D4722DDC7F1BA5CF8AB03B4C8CB34CC8F52757718C7AD08B9D8
          8269A64BB78D2C61C54E5F204FBF146376D36EBA31C2165AC75D96CBC9E7BBD4
          632B0991E518C944C6CCA699C80B27CA16C25E8970FD02936C115BDE07DF2BBC
          B3ECE29435CB15E1CE4F2B15FABAF2DCE15FC4DFDE68FDE07E0ED26C6862FF19
          E071E38903FE0400B6AA28C80E76E70000000049454E44AE426082}
        Name = 'PngImage3'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004D69203134204D6169
          20323030332032333A34393A3035202B30313030402817570000000774494D45
          07D3050E1708348045F72A000000097048597300000B1200000B1201D2DD7EFC
          000005AE4944415478DAB5957B4C53571CC7BF2D9402A594872D9402F28688B2
          258B1A44B6C134689C2F66A273C966DC32B7198D8E9965F13126B0E826C27098
          687C3075C08401EA0633381479CB63021DE3A1054AC11628A5EF77BB73AFD91F
          CBAA2C59F64B4EEECD39F79CCFFDBDBE8781FFD918AE261B1B1BE3552AD54E77
          77F758168B15C3603022ED76BBDE6C36CB4D26935CABD5CA954A25FD6EB158E4
          645D4EAD098542695656966341404B4BCB3E3E9F5FD4DCDC0CF2445050100402
          01FCFCFCC0F6F080079B0D2693090280D56AC5C0C0003A3B3B9D0A8562476E6E
          EEF50501EDEDED1FCDCECE16B7B6B6D207A8D56A188D46381C0E70B95C7A8485
          8521232303972E5D82A7A72788B7205E6EC8CECEAE5D10D0D1D1F1BECD663B57
          525242FF2979A70709074828A0D3E990989888CCCC4CD4D6D682C3E1D0FBC8FA
          EAE3C78FB73C17F0655E1E333939393F345474A0AEEE1728A6A741E20DB95C8E
          999919DA23BD5E8F4D9B3661D5AA55E8EAEAA23D703A9D9497CB727272C4CF04
          4824129F7995B222901FBC6ECAC2C172210336BB133A83117AA3095AAD0E8F25
          12C826A7101A1A8AB9B93948A5521A4079683018C2F3F2F2269E0560F4F7F7DF
          48888DDA78A419681D52E215CE2CF421F188B78C233929045295196911EE5069
          F424C166F4F5F5616868081E24F124744E9203DEB163C7B42E01C3C3C36F0406
          0454060406625FE51486C5834849598AD26E3D7C147F20657D1A6EB78DE34C9A
          09A92BE2D0D1FE00F71B1BC0E578814DAACAA03758BB3ADBBDCAAB7EB6BB04F4
          F63EAC4F4A7A618DDAE404CFF3E9B4C668C7DDDE096C58198E970B4661910DA2
          2B7F0D461E8DA3A6BA0AE9EBB761D7750D12795AB8A91E9907FDD7940985FE41
          6A93754463367FDDB75724A34FEAE9E971F7F1666BA41E095E25BFA9E1AB7D82
          8D29F1F07733616524E71F555658580851301FCD1302143DB42168711CC2F96C
          2C11FA2026D80B7C0E1BD7EA7BBB9A0FBFB89C06D4D4D4889296C4CBEAE642F1
          438F12D3321DD6A545A0E2CE208E6C8E469702D81E65C1DA2401C6C6C6505151
          017F3F5FE89CA138787610E0F14126C00C16208034635C882FD48F25C6DF8B52
          BD6940757575647C5CACC49F2FC0D9CA01444705E0AAC417ADB52DF8F0402606
          2654F092895175642DEAEAEA6808D513417C7F4CCB09DD6EC48D3686B26184ED
          E519CEF7B67378B04A666AD0FDC1561A505E562A4A888D91452C16C19DC52235
          0DA8E6F5B05BC8467900BEF8E62E4AF746625DFA4A5CB870816EBEB6B6366CD9
          B28594F66352AAE3085EE47DF3931CEE1EF830B682C524AD6DBF8CB14FE76940
          D9F5CAEFB5BC253BCFFED886F470273253C3B174E932D8896C3109CDCD9D090B
          A90D0693458787EA5CB1588CB8B8385A46464646C0E371AF9C38F1D53B2ED5F4
          725583581F9196289B9AC7BDA661B4573541E023C5DB1BC2B035E325725002AC
          36078CA4F69B9A9AE8BAA7423431F1B4A748FD538D768608DD7E97808B6537EF
          CF2EDE986AB399E1E6C680B70703E2CE0134DE6EC250C73DC48BACD8BEED35EC
          783D0D0FFBC5E41B377A509A4449048FC7A3C0B9050505475D02CE7F5756238F
          DAB1D96AD69350386026C3E66420D0D7035E761D34D247B8336E45D1AB364C4E
          AB40F49FCE0365948A5232515F5F9F555C5C7CDA25E0DCB9F317A76276EE363A
          5944CCCCB01041FB0B64B00191DE0E5CA96A41F52E2E6635661A400DAA8389AC
          3BBBBBBBAB8947BB4F9E3CA97609282FBD2632EA750715AC90F714DC249E8615
          4883AC7622D124F61C930E376F3DC04FFB02A0353FFD7B2A0F24D1D6D1D1D1CF
          4E1323C7385D49FFDFD4B4A2BCD45735F3E4DD692CDA3FC14D8C507846C2E6B0
          C3382147C3AD36FC7A540826DB974E2AB98C64A482DE3C75EA54339E632E2F9C
          6F8B0ADD9D5653A6063E1F8F78C5AFE81EF364ACF51E46667A14546A1D7567DF
          21C97D2B3F3F7F1A0B1863A10F723F3FBC5A6FD06DB6DA9D4A9EFFA23D939353
          57A3A3A3B30F1D3AE45868EFBF02FC57FB134EE7CA37ADD29DD0000000004945
          4E44AE426082}
        Name = 'PngImage18'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500536F20323820536570
          20323030332031393A33343A3133202B30313030ADEDE1ED0000000774494D45
          07D3091C11223B44FC2834000000097048597300000AF000000AF00142AC3498
          000005094944415478DAB5947B4C537714C7CFAF2FDA4A4114815870BE402A99
          EB7C4C08D1D888D1828A0AF2073E70986DB8254CFFF199F84002D1D407542112
          424C36962C661A9922D131C65808D0A9936958892DF22CD8B53C0AA5ED6D7B77
          7EB701FCE36EBA2C3BC9497A6F7FBFF3B9E79CEF3904FE67236F3E9494B48608
          04EE1886214AA1902819C6170DE057FA7CAC92654129958AA25D2EC6EEF331D5
          72F9ECEA234712CDFF0A70ED5AF3684CCCDC10B95C0C526910C8641290CBA5E8
          12080A9200C1D32E1780C9D48F3EE01F1E76361322FC5A2209BD75F8F00AFB3B
          005AC654AAA58AD85805848549C0ED06F0F902EEF7079CFEE62EE24D878381CE
          CE6E309BFB5D9393EE072291FC2BBBFD45AD4E97E7E605E8F5CDB665CBE2E778
          3C0C84864A60C99260108944E0F1CC00A61C4BC6B940C0393B3434C13E79D2EE
          B358ACFD8585E98B780157AF360EAAD5AB22BD5E062FB3E0F5FA21323208E6CF
          97E3970B40280C047738BCE86E181F77C2C8C8043B386883B1B171080E9691BE
          BEBE91A2A28C305E804ED7D09B9C9C14EDF17839801FA351278485981829180C
          DDF0FAF53084848861DE3C19281462108B09661A0551510A282B6B81BEBE7E6B
          717166042FE0E2C547668D66E32286A1001F060F40F0BBB1D13EB0585EC1B66D
          6AEEECA14325505EFE251417DF82FCFC0C98354B00D7AFB7426F6FCFC0850B59
          4A5E4051D123A3569B1287B2C492F8A733A0D908854E181D1D84CD9B974F0346
          472760DDBA0F2127478B99005454B4425797B9E7D2A5ECF778010505B5CFD3D3
          B50954293428FDDBEB0D64C23076703A6D0850714AEAE9B1A3D242B15C424EBA
          B4D955550678F9B2D374E5CADEA5BC8073E76A9FEEDAA5E56A108000179C6509
          36D5826A1A859494784E5554A66F2A8A0AE0E64D03188DC63F4A4AF6A9780167
          CFD6B466656DFD88060C049F719BAD1FDF3940A389C7AC02006AF4DCE42480D5
          EA82FAFA67D0D1D1F15CAFFFF87D5EC0E9D335BFECD993964C88607AB8A606AB
          B7B71BA79B81F5EB974277F7180C0D39D09D18D881D94D009D1D5C25D803D353
          BD3E77252FE0D4A93B0DFBF76FDD4087EBCD09A6663275E1655AA6404F3C1E37
          EA5E84F29D8D9255C0E2C51158A266549AA5ADAC2C772D2FE0C4893B0F7373B5
          9BC4E220AE0C53106A46E34B78F5AA071212A260E1C23998C500F6632506AD87
          030736721F72FEFC7DCCCAD25C5EFE49322FE0F8F1EFEE1F3CB835952E390A60
          9819407BBB1195E2808C8CD5DC736AEA49D8B2652D2ACB0DC78E65714A2A2EBE
          87836869BC71E3D30DBC8093276F57A7A5ADCD8E8D9DCF356E0A401BF9F8F10B
          D4BA1376EF5EC39DADAEFE19A7371CE2E2166089823965E974F73083811F2A2A
          3EDBC40B3873E6E15CA773E4416A6AE29AF8F81898989801B4B53D6365322FC9
          CC5CC56D592A4BFA7EAA4FF4DDE5CB77617070A0AEB2F2732D2F805A61618BC2
          6E37DFD568566BD4EA580E4225D9D4F41B1B16E6273B76ACE4827197C98C5CAD
          561627F91E3679E0FBCACABCED7F0BA096975723954846BE4D4CFC607B52D20A
          2EFDC6C65FD9F07011D9B953CDF5C7E160716A8770A26DB8E0ECB8551D089E44
          D09FB71190F18F006A7ABD49D4D5D554A5522DDF9792B206EAEA0CAC50E82611
          11B351AE36181E7620C88B415DD82F171649F83BAE8B064244DFE8F5D986B702
          02A6131C3DAA2C898E5EF085582CC2BD3F24C060A81827EBF3914E8140F82321
          A401BBF15369E95E2B5F84B70002969F5F5DE0763BB3710136E21A6F90C9E40D
          A5A539FDEF72F79D00FFC5FE02FD98A737395B19A60000000049454E44AE4260
          82}
        Name = 'PngImage2'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500446F20323820417567
          20323030332031383A32343A3537202B30313030D24EC2A90000000774494D45
          07D3081C10192750EDD8C4000000097048597300000B1200000B1201D2DD7EFC
          0000062D4944415478DAB5956B50945518C7FFEF756FB0375C445817CDC25B65
          8E3243A386A315394ED6545F8C1C752C672C4B4BBC4C38EA841A5E1043412E2A
          8D9AA9450E69A25202824C012BD6784117505690CBDED88B0B7B7D3BEFFA69D5
          FCD679E7997DCF39EF3EBFE73CCF39E74FE17F6ED4E303454545B2402090476C
          74381C569121354DD32A8661D42CCBC6701C47F33C8FFEFEFE3EA7D3594BE66A
          C95C4D4E4ECE9D67028E1C39F2ADCFE79BFBF0E1C3F871E3C625A7A6A6C2E3F1
          401004880EA55229082062625F3487C30193C984EBD7AF0B66B3F932F9664976
          76F6BDA7024A4B4B1D0B172E545B2C1681440FB55A4D492492C85C6F6FAF1871
          04261A5919288A02891E247AC8E57290E04498D0DDDDDD1E0C060F6FD9B22537
          0A505252E258BE7CB9FA514F101C8E418AAC26E2C866B341848A40B1FFE80B01
          A1504810617EBF3F6204420D0F0FA3BEBEDEB173E74E6D14E0D0C1525B9B6BAC
          F6F5E909D08F5463528A3E326E341AD1D16E8A0002413FF14C226768700C05F1
          0986019E6340858391778693A2C5681CDCB56B97263A4525450383B13375C9EA
          004ACFF763DE141E6FBDF6226C3DB7D0DCFA0FBAAC34DC82021993595CEF74A0
          EA060F5A2AC3E6053C769C32A3E15E02E64CE7B17A2E87FAC6262B01E8A20045
          FB0B066227BFAF4B560DE354A30BD49013B3A68E865E6246D9E9569437260172
          194EAF70E26C8B07871A75908D607066991F5B2BDDA8BDAB43C62B21AC4E07FE
          A86BB4ECDEBD3B3E0AB0377FCFC0272B3ED7D96C761C3706C178ED989AA283DC
          7313E5556D286B2529E3389CFB7810BF1A8750DC340A322D8DB3994E6C3D1F44
          4D473C664F0961C30C2FAA6B1A2C7979798F03F2073E5AF4912E4EA324F90EA1
          AAD58AA4911A0C999B507EC98CC3D7C688C9C685C5BDB870630827DA75989CC8
          232B75100D7703180C2830318146B22A844B35754F020A0AF2FBFA99E9235F18
          25C1D4091ABC3CC1805050C0E5862B30DDED06CBF14850B2F085C842581A728E
          425800868214E412160C1DC2B08F6C5F568A0B17ABFBF2F3F3474501F6E4EDE8
          918E5D90A891F990478AF6E53B5ABC3AED7974996EC26AE9031D0EC01BA0101B
          2BC7FD5E179A3A8833A9044BD335D8FEC31D5477AAF04E5A0C5667A85179B6EA
          C1DEBD7B93A2003B72B7F78C4F5F9CA8607C38D9E8441CE5C4C417E29112DB8F
          A367AEE1C01F645BCB9438B72E488AEC4451B512DA2406E7564AF1D5D10134DE
          D3E0DD341A596FCAF1F3E9B34F02B6E6E4F464676F48B45AAD38D91AC690DD82
          49637550F9DAF0534D07BE6B20BB8EA4A9FA8B002EFEEDC6AE4B1AC42510C032
          01EB2A5CA833C5617E1AF0F56C1A272B2A1F1414144403B66DCBE999302D2331
          75B21E49BA18545DB363845605FF83AB42E59F3D54DE65925296C3EF9F7A50D3
          E6C19E6635D29EE3B0754E10B5B7BDF05132BC94C846EAF453C52FF709C01005
          D8BEED9B6E463F2F4925F143ADE0F0EE9C14044941FF6C6A16DABAAC54A74B86
          E4381EE37502589A428C9482009A1499149C67E0F7792335522A55F8F1C449F3
          BE7DFB92A3005B366FEC32A42D31A8782FF654F460DDDB2A4C99644087A94DF0
          0F7B28091B867738045EA640E77D07EA6F8710242B5ABB601456EDBF8A2BA678
          2C9C178B35F37538FCFD3133B9F6A3011B3766772D5DB1C6E0703A5156E3859E
          B340A650214D6F130E55DEA0CA1B63C84956E1CA46198ED50EE040B502F1060E
          97D66AF1D9C1FBA86B5762E95C1E5FBCA146D9E1234F02D6AF5FDF9099F9E10C
          4352229ACC41DC32F541476A309A69174ACE7753C78C1A500A167F6571385AEF
          C0BE5A250CC90C7E5B2EC3CAE356D4B569B02C83C2AAF458141697DD25B7F373
          5180DCDC5CADDD6E3F3E73E6CC8C39B367C168B221C42A415BAE0A653576EA87
          56B28B6238FCB5D28733D75CA834C5203D458AC5D3197459863042C54343CE08
          4D0EDAFEC2A24E0218F784646666663263C68CC9D1EBF5EB3F78FF3D5A1494E6
          9616A1ADC74D79C3528C1FC943AB60C849662111AF68864548A02362E374B988
          C2D9E172B945856B292E2E4E7DAA268B6DD3A64DA2F7F2458B16293B3A3A0421
          1CA268B273BCDE21B8898C7A3C0F892317882005897513B111F5F80EF9CF1D22
          42A235931AD8FF1320B6ACACAC89E4A78248E704E2C4EA76BB4DA47F9B285AC4
          996844CD3A0B0B0BBD7846A3F03FB77F019525CF37BA72CAA00000000049454E
          44AE426082}
        Name = 'PngImage5'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500446F203134204E6F76
          20323030322031393A35323A3139202B30313030E8DB41510000000774494D45
          07D3080C07123A996F8FBC000000097048597300000AF000000AF00142AC3498
          000005514944415478DAB5557B50545518FFDDD7B2B80BCB6E28E0F00A43F101
          1819EB885A2901D5A0163EA6C738A1899A06569396E5039D74C69C1E9ADA98D9
          944AE2834AD01AA4C46496755248040183B11070647397D73EEEEEDD7B3BF7AE
          2B28D51FCD7866BE39DFB9F77CDFEF7B1F0AF779517E46227CE9560C67BD3090
          8F3A72D67B2584486E4212745E993CD0091282294244328861A1A52968191A5A
          8A4610CD42CD3B60B55870CAADC6DB05BB704B0130EFD564F63AEC7B74818855
          31A0380E605960F02E5340C0004FD3C4227AB0893E2BC100D62EE0D851142DFD
          1C2F2ABF4F6EA61A26CFCE1CA713AA410B3D770989229123825EAF8FE4B39F17
          84017EF03FD9A8336750BB6817527C0085688B8864A362A7E4C0DD520C41BC5B
          D1BDBC1FD4BFDF4B32405D1D9A094082027062039AA262D831235317A0EDDC21
          C503FF65C5733941D4DDE73B519186EE0C0953F355FCF1F20E3CA8007CBF1E97
          62E2544911939E454B453128E6DF85FF4BB17FC9F9696DC5F5DC4F11AD0094AC
          C5C5B8D10129E113B3D1587E0CA41AFE97623F2F7BDBF627DA17ED46940270FC
          1D9C8F4F18963A22390B756525A0B9FFA7D8BFD324021D1DB8B17817462A0047
          D6C09C3041631C9E98899A6F4BC0A8FE5961685C06584EA3D422256B21449178
          0A1E3B2CAD1510F85EE59E1CA2AE2E02B0DB0FB09A0024698DA16367E0FCF113
          6055432D1C312A033FDFCC8626240A22C58296932EBAC1B1346E76B6E3F1B846
          783A7F84C3D6AAC8D86C83008ADE80392925C8A81FF7044C874F80E186BA1F9D
          F4024C8E85C8CFCD1C320E4A2B6A70F26C2DB2E31BC1D9CEA2B3E582447AA473
          C9678854000EBD0E73F2A32146C398E9A83C403C08185AA2D1C9F361EECBC1AA
          A5F307814BE41F85EA9ADFD1D4CFA0E1F255445A7F81DE790EAE5B556B96EDC5
          3605E0E02A98538C7AA321612ACABF2805A71EA87B991C0E203C610EEAC55958
          B32A77880737BABA71A4D44446890AD6EE5E84BA2F20565DFF6EE68AD22D0AC0
          57F930A74E0D350AEA78941755830C36389D00CFFBC681DC38638D5968556561
          E37B05686FB7C2D6E380DB43EE7944B848873B7809F1A31EC0D8482D0A376E42
          C684BE0FA6CCDBBE5A01F87A256A5367844DBC61D1E387E2260CD3F8DA5D56EC
          A798F1D371894FC7A6C275E05D023C646EB01C0551A2E12533C32B119E00E982
          386CDDB6134F4FE8D9F9C833EBF215802F57A02E2D3D3CB19F37E0A7922B50A9
          7D0072B9C924AFB0B84968163251F0D60674F7B8D072CDA2CC269747829BB8EC
          24BC269043465A0C3EDAFD0D9E4AB0EC4F9C59B0D80FD03C253D62B45334C054
          D6002EC097038619E84C5DD8185886CDC28CB9ABA10FD2A0B1B983584E814408
          3C51EE260F85879CE7A48FC29EFD659816DB5E923273798E1FA02DEDC9C828A7
          3704BF9EAE07A7F229954999FB640F0C0E8714B100BAC46598FC703C2ED65E23
          D39400902AE0499EDC04C4EE9690F5D8433853790121EE862319737217F87290
          8F5B93D3230D7D4E3DAE982E93D80E00C85EC83B4B4A6BF8F85C34D1CF6361CE
          345456B542242F8C70DB03CFED444F4A8E408FED2F14BEBFFFA5F2E2CD87FC55
          24A465C4303D0E03AE9A6B11103860B94C1E8FAFA2A2272E14CE3B9FA30A96CC
          66AA6BDA617779C0C8E382A1EE3C71612382A1D5AA9097B7F1C3D347B7BCA900
          1C588979B49ADB1197343AFC7A7D831222172953D1032B31D3442E55914854CD
          DD6ED5BFBAFE78DE27DB5EC9964B54CEBF241B4042E420756DB7F3E8EDB7A3A7
          8FC7BEBDC5A663FBD6A6DD791C0FBE86E87E27CA88D71D44B282965079AA1FBF
          7D7718DEC14D3537EFE3E56161C12B9D3C6F73D99DB67E87C3C63B5C365112BB
          89329B284A3696A56C2C2D7595156D3553B8CFEB6FCB4D893769257E9B000000
          0049454E44AE426082}
        Name = 'PngImage4'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002A744558744372656174696F6E2054696D65004D692031204F6B7420
          323030332030303A30363A3032202B3031303089E94A900000000774494D4507
          D3091E16070B25901671000000097048597300000B1200000B1201D2DD7EFC00
          0003844944415478DAB5955B88555518C7FFFB08CAA033E38C466373092F1945
          083DF4DA4BD053C2189A62534F82B752ACF0C5194B69B24188D24A61BA8C69A8
          054605DE061F64C6895ECCCB8833A964137A8E83A3E7CCD9F775F9FAD65A5BAB
          27854D1B16679FC55ADFEFFB7FEBFFADEDE17F7EBC072D68E9ABA76953A6426B
          0D680F9A0820B735496394D6FA5E2EC0A2EFE6D227CB76C0D75540113414C727
          081D62F3811DF863D5443EC03387DAE8C3A55DB8131711AB0052A776942A63E8
          3B7E1A37D74DE6033C7DB08D7A9675A2185E4128CA9CB98050312A7E19DF9C18
          42717D4EC053DFB6D1CE573A7123FC1D812C432B89940165FFAE0594DEA8E604
          1C68A59E150CF0472C4029C52A625459C1BEE3BFA0F4664EC0C2FDCDB4737917
          FE0A2E211293EE0C58C56450C1BE634318DFF8102E6AEEABA3D9D367B3053548
          1B1B7A20B6A3B1667DCD4C6C7E690D2BB88C9015484A2184429CFA3872FA2CA4
          28A08029BCD6EC23B79F5D76BB5246754BEA59C0DCFD8FD0571DBBE1AB2A9CC9
          C9022C8447287C94A25124D2670564CF215121664C9D8139D317427122920F5F
          CA042925B85B1DC7AEEF8F61F21EE0F1BE46FAACA307136CC554FB36A8266507
          B1AA44451CBC6A0329CDF31C2C55293C2A702E051B5CD9415052220C121CEE3F
          8760AB7080B6AF67D1A71D1FB015AF22324E8103100734BF6EB30BCEE1B92CB1
          2DA729A11BAE9C46B1314114081CEAFF0DE1BBF7010DB4EBD56EDC0846B9CE15
          CE8C175A152203F02DA125CF717095F0BBFA57D07F00EED7002403CE227A4F3A
          40CB970DB4FBB5F731561DB600D8E02E23CDD195C7EFCA3498C83237E7742F7B
          D8ACCDB97175788F53604A146DCB14B47ED1481FBFDE85E1D2009F41EADC0077
          C06641C183CDDE39CB051782D548655ECD4A4EC4EEB06B9258E2F0C9F388B667
          8047F7D4D2ACDA3A4471E4CC6B6D6A2CEBA1BEB6064B9E7F966D29FE539A3491
          3872EA829D77AEB3DCCCAA40C4F369B7F21ED868F37B9BE89D252B70BD3CC2F5
          4F3315401A0BFC307801C50D39EFA2277B5B69D3CBCB71EDF639B6A3CAFAC328
          50F871F0226EE6053CD1DB421BDADB19306CBBD4018C02899F862EA2B831E75D
          B460EF63B4BE7D31FE9C1871FDA19C0291B2828161DC7A2BE7176DFE9E39B47A
          F18B18BB732DFB5C7AF7013F9FB9941F30EFF3265AF9C27318AFDCE27F05F6BC
          BBAB14F7C7D15F2F63FCED201FA0E1A31AB27D204D8132FBB20ACF9C03F741DC
          29F301F23E7F0364F1D137EEA7186A0000000049454E44AE426082}
        Name = 'PngImage6'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D650046722031392044657A
          20323030332031343A35393A3435202B303130309EA896800000000774494D45
          07D3030513383AE7F336A3000000097048597300000AF000000AF00142AC3498
          000006504944415478DAB595796C147514C7BF73EDBDDDDDEEF6046C6B59AB16
          2A4596420ACAA5510C9888A8444C44132018238A67A222E245BC50C1331814B1
          E2850725057A60AB11DB52D8B6D07629ADDD63DAEDDEF739B3FE5AB5D8D8F89F
          2FF3DBDFCC64F67DDEFBCE7B6F28FCCF46FD7DE276BB660EF3F65B21A20A0C7B
          650AD282581A86703283480208913D4C767754F03B0382C7E28E3BC229CA2688
          F400CB705D2B97969F7EA69A199812E0768DEE9432E2530141C9F47A19041322
          9282088EA52197B250CB1928A43434721A2A19A0660105F95F300EF43B23E818
          0AE3B8258A66BBDCEA8A523FDE3A2FEFC3C377529D1380FEBE3EAF9D2DD62DD9
          D189EBE768307B9A0239591C0C64E9142C340A06720981C8FEDC2534451620E5
          084C421673498A6E3E8A4D35C3E2EF11F5767E7BDE0BE3F74F9D6AFBADD2346F
          FEB7ED5EFCD01D2411B3C8D771C85549A027E16A480672E958162C64C4F30480
          F973112EC82360E84BD2943FD79D38BF63B66C1CD0DEDAB12FA82CBE4FA396A3
          2C97235A8B708605F86202120290A169700C818C49453C730420FB0740492423
          314DD8457702B3B6F758E2EF5696FD05303F1496E87727A51AD054665C7B7220
          4B36A63F8D0C1160CC314B9E6618F2430063FE28722A8A403429C24F2AE2A22B
          89C6BE309A7A03E8E5630723EF54AE1F07B4B576AF0866642732DA7C30A48C18
          922BF1019695926B16C13471CC0944268AE84E244A4641254288893404125438
          49C34DDEB8DD9F84C395C0B173010442A96DD6572BDE180704FCA9FC8EAE8BBC
          9057444949BC2C23818A631017FC38EDF9092A49368CFAC55090D2C9043C8878
          1C88A544C4D369907246F6F42BE08A08B07B63B01279F6B7B87075BE7269F3E3
          C693137D60363B9D5EA52E7728DC8559DA62BCD7B3039FF9DF86412185C39BC0
          22ACC2EED58770F1E713A01332C4D834E2C934548602E8F28A3142D20C8A720C
          B9E278AB7E543CF64A856E4516159C00749B9D4D2E9976C948B20BEB4ECC43F5
          FC62541495A2DDD28FB6F343D85F70108DFA6634443EC5A29EF558AE5A89E28A
          CB214A95106559181C0963382422222AF1616BC612D9555836A993CF758EEEB1
          8B920772B2053C689D8D7BAB57E1B3A69F30E39785C8A5B271D3CCD57838E76E
          3CBBEC36ECEF3A8EF3F569ECA9AA41B6A108EE88089B378AB3160792AA12FCD0
          2FF9C2FF7CEEBA49802EB367933D1A7B3F775A21E6D7D2B86BB10907BF6BC3B2
          C8721CBCBF069FF39F635BF756AC5BBA90BC780ABF7CEFC7F6B9AF83430E52AC
          02BC2F891EAB073C5B0A6B5CFBF885C7B4AF4E02587AC38BCE59F996F20A2312
          E1B38838491FF83C70274671D3A29570FBFC28D35E8ECBBE29C4EA35E5F8F240
          3BBE3675E09C7B10295A093E90828BF44E8B271F85853396356F54364D026432
          19CDB7477ABC259557D14F762EC7F19146D0A4F01D7347600958D0EA6BC3E639
          5BB1F8B009253750387CB81DC1AD19D4D435C3EE89629800148619D877462ED4
          EF2A332C9452FE4980316B6C700CC98D8597B1E90E984E5E0B93B11883BD3E4C
          731B610EB5E3C2061E0BBE2A47C95205BA6B47D1B725893E0F8FDF3AFB91452A
          499468F1F4D1487FE49542E3BFC6F598359C18A99D71B562A53E15C56EF35EEC
          F2EDC4DAEB1760BA2E077AA50A1FEF398DEF57B5A06C571E9EA87E096B4C1B60
          0F04E18DD34850720CF859ECEB600FF9771AEE9A12D0D4E07E59D0A69E2CD586
          2021E576B4E318DEB5EDC5A87200DB36DF8C8F6A8EC014BA035B163C0A27EF45
          C1CC12585D41D846C308A65898835A9C1A563CC63F9DF3DA948093273DEBD34C
          EAC035572A20A4495DDB9CE09212ACA9BB1DB2B00AEBCB376071F91238432EF4
          5CB0A0EABA65B03903E0C988F0C732A873E8A1D6E7AF68D998D53025A0AD2D55
          E1740E9A6FB9C588582C0AAFD78BDA23755049D564C09149AA53830C57FC6E77
          40A5D1414BBA98F747E18B734851327CD09D9539B4AD4C7F631EE59B12402A89
          DAB3B7B3D654957773D5BC3C34D6D7A1BEB1092C2723C34E8282E94518B2D9E0
          0F4571CDDC4A24321C18452168B90119891ACFD52787465F2C289EF29B7C0912
          E7F67D1D78D0CABB1EC9D1615A3C7001B38CB9D0A865C8D26543A95260C83E88
          FE011B8A8C73906075E87252A8697589F9A5658F1EBF877AF33F01FFC88679FD
          80A57A38905EE28DA54D698A29954AD87C96637449D2CBC1785CF4C4E0740513
          368EA17EBDAED2F8C95B6B9567A6FCE8FF9FF6078219C037D3A8D3E900000000
          49454E44AE426082}
        Name = 'PngImage7'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004D6F2031352044657A
          20323030332031363A34353A3436202B30313030D95E41CB0000000774494D45
          07D30211012E0CC968888B000000097048597300000AF000000AF00142AC3498
          000003B84944415478DAB5956B48936114C79FD75D9CD7651A4E449460B8EA9B
          608A1F1241445009252C8CA1AC682853A6362F2129E812618A4CC569A0E606E2
          14FBE0973E581FC64CCD2BC8D4702311F1C674E07DBABD6FE78C26125473D881
          97673CEFBBE7772EFF731E8AFC67A37EDFE8EAEA7AC5E7F3350E8783DADBDBDB
          3C3838183C3F3FAFADAFAF3FBC11406767A72C3939598DBF2F2E2E1042E6E7E7
          87CACBCB73BD06F4F6F6661E1E1E7E2A292971B4B6B6065214F539353535DE6E
          B713168B452D2D2D31369B2DADA8A868CC2B00787DEE743A870D068358AFD73B
          3B3A3AC24E4E4E8C10492C00C8D9D919191F1F6FAFA8A828F60A303838C88485
          85612A74E0BDEAF4F4341AD6776969690F1886215007323939595F5353F3D62B
          407F7F3F1D1717476D6C6C104805F1F7F727C1C1C12420208020E0F8F8988C8D
          8D8D464444E41417173BAE0DE8EEEEB6252626DE82A2BA0EC487A669D78A40DC
          4783340D454545E5C964328F212E8052A91C292828C8DEDCDC24500BD7C16847
          4747646E6E8E848484104C21EE4F4D4D0DC077629D4EE7F418D0D2D222E272B9
          86F4F4F43B505C82A90A0C0C64381C0E595959A1E01D819A90A0A02082EF6767
          67755B5B5B055AADF69F90CB3E00E5C4822CFBE190F8FDFD7D121A1ACA88C562
          6A62628280C794AFAF2FF1F1F171D5657777974C4F4F7F10894492C2C242DA23
          80DBD46AB50065099EC64547478F64676773676666305DAE48108291ADAFAF93
          C5C5C51E88FE25FC8DF11870D51A1A1A320502C17056561617248C35A03055D8
          1B6C369B98CD667CDE37353549FF04F92B00ADAEAEEE3140F41919199C858505
          C2E3F1282C3602301AE872B2BCBC3CE3E7E7C785287FC0AA6E6E6EFEE23100AD
          B6B636273C3C7C00C607070F846148A1DA6075D5C32D631890C46432E15851C1
          C8A9C4A83C02A0555656E6464646EA525252D8ABABAB285D0A6715CCB0CBBE71
          A76F6D6D8DB1582CAF6104B5780C40532814CF00A24D4A4A624191297733E2C1
          6800634085B04DB38C46A3B9BDBD5D782DC02FC87390709F502864634AD07094
          80D7D8A4CEEAEA6A667474940DCAB3432D78D706A0C154B5242424DC858B0823
          60C05B1B485B0FF2DD8D898951E4E5E5F11A1B1BBF6B349A7B5E01CACACABE41
          2DE271CAE28504DE7E8461F9442E97D330A71EC1A0FCB8BDBDADEDE9E9917B05
          904AA54A8944F2069B0D9B129504FDD007457D01AFE9AAAA2AE1CECE8E152E32
          9B5700A8031F14F4353F3FFF3EA609BC25D823508B872A956AFAEAB75E01D04A
          4B4B43AC56AB1254F5149AEE36CCAF639068425B5B9BE946009EDA4F5309FD28
          A260454B0000000049454E44AE426082}
        Name = 'PngImage8'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500536F203137204E6F76
          20323030322031393A31373A3436202B3031303041C0B5F10000000774494D45
          07D3021717052659633C2A000000097048597300000AF000000AF00142AC3498
          000005804944415478DAB5955B6C146514C7FF33B3BB9DEDDEBA6C6969B1361A
          84D242915E9080484C441F083CF1A2263E180C04A9928005C4A00F84F8A00404
          A39840402B7751B0CAA54211042A22A59296B6F442BBDDB66CBB2DBDEDCCEECC
          7CE3F77DDBDD5E78D5997C7BBE99C99EDF39FF73E68C80FFF910D8CFDB77E667
          2699C27E4114164E3566482B48290C290A7A0D939E8661C034988D20AA1310BA
          34431BB551181A017411576D65A8D7EE1AC343A4AA6F38BCA6A124D4C9016BFF
          2EAE68E9EB7BE556B71F05F6029C5A780E29991E0882F044442631118D46A1EB
          3A344DE37B16404F20845D810FD0E6AC85F2C8406F40A968DEDCFF2AF7B0FE6E
          71F8DB9A7BF6114D4591A310E796FC064F861BA228A2B5B515C3C3C31C669A66
          C2B2C58EB4B4340EEBED08E1B3B652DCBC5285CC97BDA8AFE9517A77869339E0
          BDBBC54A59CD3D79844A50602FC4CF2F5E8037332501181919E18E0921B12C46
          016CA5A7A7F30C7A037DF83C508AFA811AB85265545574A8CA5EDDCE0125D5C5
          CAF1DA3A794457F0BC5C80338B2E70891860B24C7169988D442209B918604F70
          2BFCAE5A08AA84CB3F3C54711063809375F7E530CD20DF360FA71694C33BDD0B
          4992D0D0D0808181010E8AC3C643B3B2B23884037A3E84DF510B44255C394901
          874601EB29E0C7FBF514A0628E751E8E159EE100E628180CF248E39AC7A589CB
          E576BB6345A635F822B80D1D9E3A401551391970B6F1811CD623C895F25036FF
          34523252B80326C778CD9933E69C59B65810CC863AFBB1B7E72304DC753C83CB
          275A27027E65002A518E98870379271235F0FBFD0887C3136489EF1930D14514
          F075683B029EFB3023222E4D069C7FD0242B44C34C2107FB738ED20C62004551
          1291C63360077FF9E8B5D56A4D14797FFFC7E8F63682A8022A8EB74C0454B4B4
          CA2A9528479883DDD987E09AEA8CF53D7D9BD9494C025606322A115BBAA1C724
          33081E07077150DD814E5A0396C1C5C980CA9687B24A74A409D3F01296413735
          3E260441E45634D9D820B1E9628E5981D706904C09ED9E1A0C26074122C0F963
          CD63807729E05A9B5FD674EA5430A1D39306CE6511E97371B44599B5304BDB37
          BE97F8B548F722AC820D366A35CDC4B9234D130137DA296054DF982C84C3583D
          592D581EA26489398C83C498634990F87D89EED9334335F1CBD107130155FE0E
          59A7BA0ABC4B08BCE10C64479FE3D1D1FFC1D00D1A5984B7AD16D546F5D7A91C
          048399011ABD04C122C29D6D83A110941F190758575DA4DCEEEC965937B01B86
          4450105A827DAF7D8F1BEDD7A10E86D1F738043220C0E34C81CF37055EAF8FCE
          A13434FED38CD2D04A38921D70D892312B6B366A7BEEA0BC8CD6E0F0B80CAABB
          BAA844B10C88A821B777314AE7EEC49C5BB9F07944EA58C23A7D3BE63B16C1ED
          75538017A9A9A968A86EC21665255C4E275C920BB99E02DCECBA3C11B0F67691
          722F18940D12EB7722EA98D5B500EF3CB519CB7B162323C9073989A0C4BE0305
          9E4570A53839C0E7F3E18F8A2A7C62AC82CBEE84D3EAC46C0AF8B3BB1267BF6B
          1A03BC5999AF04940159476CBE100BC133EDF3B0CAB1061BEDAF638AE881C5A6
          619377178A52977280C7E3E12FD8A5F2DFB1C7B91A2E87130EC911033CBA829F
          0E378E01565D9DB5A7AF3B5AA23B89205969BFD30C329BF2B0DCFA16764D5F07
          97E0862045B035F32BBC90BE0C4E8F837F2386868670F5C27594656D86D36187
          C3E2429EB710373B2EE1D4E186302DB2233160969E7DFAD3509B5AEA9C661374
          D14046F34CACCFD986F2D4BD34F514C836E08DAC4D98E1CDE7E3A3BFBF9F8FF1
          AACA5B3830650B926419764B32B29367E2F4B58BE8F687CB71002B267C4D9EDD
          EDDDD8D7A5AE7E3CA058E686F31D1B16BEEFB225D13FDA9321DB655865096175
          843B669F513604DB1ADAF1A5BAEF11ACFC85E70AC382BF206103BE41EF935FF5
          FFF8F81701C11B4629E961BF0000000049454E44AE426082}
        Name = 'PngImage9'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004672203135204E6F76
          20323030322031303A30383A3239202B30313030F5A262C60000000774494D45
          07D3030509291697435FF6000000097048597300000B1200000B1201D2DD7EFC
          0000055D4944415478DAB556796C147514FEE6D8EE96B2D052604B910A142468
          A158044405DAD2430B2682C160044288C4032BA451432491238A018D50C40B35
          05E40F51FF805A055182276A444ABB2D92967469E9B93DF79A7B7EE39BDDADA8
          481A639CC9CBCCCEF17DEFF7BDF7BE590EFFF3C60D79BF1CF720821208983DCC
          E54CB398C5C992D6030317C0E3241C388DCDF4EB5F13546069021377E68F9B95
          757BDA542E3529059A6942365448BA8CE6013F7E6BF7A1A1ADC5A70F63DBF134
          0ED35BD6D004E57021016F1665CC59BBE2D65C4EE01D903405572357D02575A2
          57ED434893A11B262C4E806909F0B577C3DF13FA1C2256E159F4DF98C00667A8
          2ABBFBA1C5D99EA9301987A6701DDAE426CADC80A69B500C3B8C68C8F1A36699
          0887157435C9B5245B1EB6A1EF9F09F6A3A26CDE8AB5D963A7433264D404BE26
          1203162D5CD10D9246FF035CA590E2E711924D2572496608F994D3B809457892
          52FD0B01695E909A53B966D6124E3634FCD2F7252543B7095DA750097C306385
          CE63043AFC4A3FF2C614A32EF4335AC20308B73AA14BE152ECA074FF44C00907
          50B3BFA06C868B73E35CFF292AA80A8EE3605261EDE22A14EAA02471F0964817
          0ECF3E8EC2F4A5086B61ACF32EC227B58DB05A153F787D2276428E11ECC38285
          19D9DFACCCBA8FEB947CB822D583E7C5684FE8046CAF40A3ACB53899BD922BA1
          0E1C9C53897C4F3124534692988413DDEF63D5E98DE8F7250161FF6AECC19118
          C14B787943FEF2CDB78C9A82B33D2720720C3CC75387209AADC15834346646E5
          F1853A5131F7532C1E570C95A91038919E55B1B1AE08EF9CFB11E8C804828D1F
          622F1E1E2438B5EDFE470B35538737F83D2E77F5E272DF00A679923125358DA4
          A15510916E52E6E12E54CCAB441E81EB4C87437010B986D29A3C1CAC3B0B4512
          88601A106A6840B9312D4AC0EFE66AB714AF9BD1295FC5D1BA53589FFE1C76CE
          7E11ABCEADC679A51293DD9E680DAEDAE077562137BD10CCA2550A3CA9C850FA
          EB221C22704963608A0B689F0AC88D21942B23A204DC2E789F295893E5EDBD00
          B53B0D55F9C7106401A4BA52B1A1663D4EF67C401DC5E3E0FCCF08BC88402D70
          BCFD2AC353E717E248DD4FD4C2804149588114A03B83FAFA5204AFABC363126D
          C399C7EF7D30B7BED78B70D08DEF72BF458805218A224626A6E02B7F15C6BB27
          60E6A81C98B40BA2107585D2EA18B81C0737ED81699B08444612417D13DE3032
          63045BB1A764FE5D9B22AC1797024D98E3CEC547732B2191CBD932243A874110
          04F022771DB812073718819B74ABE10E405001C97B0C6F63D9E00A8A3327A49F
          4C4B4B865FEA40C48CA0D0B304EFCEFA384A223A048882086782930A469A572F
          BA066E7798C1109DDBBEB1807F1269DE462B687D0C07702046B08B3A5345C3DC
          9CE993DA42ADD10926A7C12393566257D66128B43B1D042E98D8549B8F43DEB3
          D459B12134EC5EB6C16DC36E9C47E074627A8330B49B8960E09A55BC8A356392
          920F09C90618656417D2E130B1E1B6B5289BBC17862063CBC507F05EED0F3474
          D43B76D2B6E646DCA47D33696812E9A4931269DE4AC6B9E3EF66C7915455EEF1
          AE122430D0ACC12000B7934766EA70B2240ED51D7D6415713906C32668994192
          D0F4F221CABEBE1AED988FE350AF77D3579042467BC691C167C319036054BC68
          7758F14C59FC59FB184AA6A19A42D76D1899C02FB6C0CD1660375A6EFCC1D98E
          5108E228460B0518491DC36BB1EB36B8DD252A0D52780410F09051B96217AD5E
          92A7B91A495846FED33CF427F32DAAB30F4F40175F802B652CC8C860390890C2
          245266DB3869A307E9777700A2FA1A4653AB6C8DC93234C1E0F63C1211C272CA
          BE044CCCA1A1F0901CE4824637452D5DFF82B23E4A050DDC0862A87F15FF79FB
          1DD900DA37576136A10000000049454E44AE426082}
        Name = 'PngImage10'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002A744558744372656174696F6E2054696D6500536120392046656220
          323030322031363A30313A3531202B3031303091DB5A390000000774494D4507
          D30911120926A1A6DF00000000097048597300000AF000000AF00142AC349800
          0004804944415478DAB5967B6C53551CC73FF7B6BD7D6EEB9E74AFEE0D8C9965
          44700259404505C964BEC084181F990F121F0841A2823140048C880415C53F4C
          0886878982CE3104E3D6618100B239188C051CDD94B16E6CACEDBA6E6BEB69B7
          480C7482E02F39B9B9F79EF3FB9CF37B7CEF95F89F4DBA9149C18DD93138B57B
          097A0A48D37D2A2D3CFBE66D03043723D3947E84674A27D1D1017BED7E0A3477
          4AE517EA6F0FE065CB4E8A0BE7916C06AB152A2BA1D9D98CCB992F6DC57F4B80
          E0B3E635E467BFC1C41C994000542AD06AE1F02190FB17494BDA36FE674070C7
          D8029AD447291EAFC72F362A89A9B20C7171505707F52D5EF282E3A5455D8E9B
          0604B765C7724A3E49C91D290C0D8DCC1C0184467434D4D4404BD731698B6BF2
          CD039E8A5BCB84D417C91C63C66880C0D03F017A3DB4B581E34290B68EA5D267
          BEF5FF0AB8B8837259CB38DF105903090B8ABC155F8DD1FA2453565E116A6BB2
          A006AE02D46A301AE1E041387FB99B54578EB492EE51018736E1FAE34F4C1E0F
          6414CE4512F934C45BB1D46E256DDA34C2A10A39379984D38B60165585179A9A
          445575EC97B60D3E302AE0E0275AA72CC9098D0DDE70A168C526B34B5E21B9E6
          4B52A64E255C452140C8F1EE7DF88D32AAF834112A01933C9D247873A415F446
          0454AF971CF9F73F926EDFFE0D97BA257CAA048A4AD792BAEB5D7266E709C048
          0E42A1A9AEA561F66692D3BA30F855B47BDC836DB6C50F4D7F9D03110155AB68
          9CFAF40BF9AD47AAF8EE541989B9B3C8C8B09061FF88BCBE7D302E4B1C4B8447
          D181FD10EDB3B6F0B9ED28E5F71E40894AE5ACBDD61BCBE5470B5EA22A126049
          E6E4491F5844F937ECD98EDDBF812B573A29282C24DE1C43D2CF1B9938D42866
          5E11AB7A082C3E4DAB3F919D5F2CA3BCAC0975740627AB2AFB8D03979E287A8D
          8A6B005B17A2B1A45357F4F0BC093E573BF5762F2EEB6AD293A3189392825A6B
          A0A76F0055FB69DC9A58FAFAFBB124C6A333C452B96B05CFCDF7A08DCDE1C4F7
          3B7D5EC7D927A7BFC5EE6BFAA0FE6366FA4CE93F6617174BE77ED94720FD43EA
          1D0A9EDE4E91E3005A9D3E3CF43A0545A309AF9971CF7D38BB659AAB17909978
          094F57375D8E96AEB2D5245CB7D10EACE4EBAC92698F1B634CD4FDB01F574115
          2D171CA2B20C288A1CAE2E8DDA8F46A316F78A48BCC2944963A9DF9247522AE2
          44A28ACFE39EF30E51D705FCBA016B874FD75838E32E63AFD3291A369A4EB742
          74F02451C16E1CE6E548E6290220A3E88D68F44978ED6564C69D09F74EC87E3F
          4FEF636B888928157B57B03C61AC755592359173F6E3E4E4125EEC17BD76E68C
          48B3089DC6D784E46A4072FF86497163161A3838225BADADF4CC7F9FD88880EA
          57D1751A68282AC9CB3D77A299CC6C181818EEB54171EDB93CACDAA1213E4761
          B1750B05E8EB0BBF1FD404B1CD5DC7CC8880306415A5437AFD9E7E8F574A4BE3
          6F510D390B06879D85644538F489B41C131C9B786C4B3462BFFBEDAB1D3DEA07
          E7DBA554A88DCCB158C0E51A76EA1FC023A2754488AB4D56512B0F72F8C1F7E8
          8BE46374C03272FBFDFC2476DC284E50A3A8B0B9341C7F7E1D3E6ED06EE8AFE2
          56EC2FE2EAA7283B68B0810000000049454E44AE426082}
        Name = 'PngImage11'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004672203135204E6F76
          20323030322031303A30383A3239202B30313030F5A262C60000000774494D45
          07D303060B2F2C16245A42000000097048597300000B1200000B1201D2DD7EFC
          000005814944415478DAB5957B6C537514C7BFF7D1766CEB5E50B65164638E37
          14194350028E8891C79448161E33CA5BF00F632404909920120D51C1C03F468D
          51130541440286F1183298C3810465EF32BA176DB7B65B1F6B7B7BDFD75F2F58
          250848A227F9A5CDBDBFDFF99CF3FD9D732E85FFD9A8FBBD5C78B1D094A430A5
          3131369FA54D3683C19823291A827CB477800B5F93C0565266EF8F8D73213E1C
          4003BDBED9B6419298B70A3327E4E6651420994D85AA2850351982C4A33FDA8F
          169F0397BCADEE9031B8B3BD25FC295E83FA40C03AD7188BD8C11E9C9C3F7DCE
          44EB34A8920651961094DD680FB5E18AB305938759218A0A288582894A4283A7
          1BB53D1D67F9DCE8D2F06CF4DF13B0A677AC45B8C99C2FB52D1D976D1C0E85C8
          E192AEC32BB7C31DF4E0D005072A6CDBF1B1732B9E1B5D044E10A0C832A0AA08
          C46238DAD6DA14192A96601EFAEE02ACFF154C501D7F6ED1C4B259B9C9F95034
          0576A90E92CAC317F6E3933375F095FBF5BDD61F52B066CA4C84633C64029024
          89C8AAA18FE3F07D5B4B35AA301707A0DC0158D63C61A32D6DEAEEE2EC2789CE
          C075E52279AB22C80D60EF896AF4958712BB471FB760D9A42918E0623A408790
          FB5108E49AB307BFF39ED7F122F62500250D59A956C1DAB97CD2DAC1063519AD
          722D34464444E0B0E7C469789685C1D27442CA3127335036BA18515ED0A3D701
          648904C20B0A8E5DB7FBA4909A8F2DE074C082AA8295D347167F5194331301D9
          03375AF503BB2B4FC3BD2488410653C2F9B3D5B330325B421A33088228EACEE3
          F7C093158B4324150D5D1E387C8197B0195FEB80A74EE67EB762DACB6543582B
          9AA51AF02A89FCD429DC5CE2479AD19C70FE4CF513A0926F222FC5424A953856
          49D9CA0AE478F9AA1468958540FE7B3C1C2E3B5C075081721D30A76A44DBAB45
          AF148A9A8826FE67EC3B578D8EC53E580665259CFFD25F839ABE9F90CAA48166
          58D0140596A241D1F15F161ED1854AF75730090CFA7D315CE9EC6D51DF54C7EB
          80B95523236B1E5B9D12527AB0FDFCE7682875DFE1FCDF5A794309BCAE0E04FA
          2534397D4161AB9C794BA233799175B615293D621BF65C3A8AF6E7834832181F
          1AB0C1BE10F5AD57110DA9B0BBFC21619B9CA1036CC72C8E8DC5AB0B1CD166D2
          B13E1C6E6C847D9107664372E2F08D680BEA07AE9267E9604845C5256288544C
          5C2A9A45580B60EF8D0A385BFC90C9453776F8ECDADB18AB03ACFB938F6C9A51
          FE82977782D3C290C85D9C6AEF44FDFC6E328392129055D716C1C1D562086D26
          438726FDA2E94B516F2D39A6C1DD1D03B912B4DAFB0E611796EA80EC03A6B50B
          F2A77F362CDD8C80E82351D1E009A4AED783CB4F3B90C4FE55A65B1D6BD1EEAB
          01AB1AF5E68AD7BE444685A4C8080E0808F9050CF0223CDD9155F8105FEA80B4
          FD48B798B2BA568E2F49EF8E7692D848C99137BCC2A3391A43CD537618E261DD
          B6E54D33C0FBFAF52C7400C9220E737786419358DA3B4201395319813710498C
          0AC3616C2BCD9AF2EE10737CB39618549C26C0A351A89AD1403263F4E73B9CEB
          71B1B5121465844C7A412123A5B79B23CDA9201223D1FBA35BF00EDEBF739A9E
          81015DA85D3E76D2349AF891955BA35D23D1096A0C424A3A2AA7FEA63FDBE9DA
          80B38DC7C132263D72AF8BD31B4FA5357439427560301BEF41BA6B5CE31B58E9
          2875A174D4A8029381258755D2A12AE2F9F00A87C13979D83BEE2036B72D2132
          7421C66908F878682483F8A0EBEA0ADD402A715E819EBBC675C2BE85155E1C29
          1A9EF3B835C30CF976163219DF92228132B2087AA3E0C28A5E39B48146281883
          D7C9D5210B8BFFEEFC9F0171DB44E42AC44623CF6E79C49C9A999E92A46F15E3
          32DCCE48260A0E84C8A7B38FF713F82E3C8A8FB05A8F070F06FC691F90842328
          23E5328F61691B4B514335E298349247E5B57AF2493989741CC60E44EFE5E2FE
          80FFC0FE005403EA37CE8511F00000000049454E44AE426082}
        Name = 'PngImage12'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004672203135204E6F76
          20323030322031303A30383A3239202B30313030F5A262C60000000774494D45
          07D303060B3009907A809B000000097048597300000B1200000B1201D2DD7EFC
          0000057C4944415478DAB595796C54451CC7BFEFD86E8596A52DA52D8BD0D656
          6A0B2BF40081886D820996268010CE08584E438C8AC42AF0075E842868448D89
          4625114110118B8D558A20D85A8E84560ADDA5D76EDBA5DDEEDDBDDEFD9C7DC8
          4A8340487492D9F7B2F3F2FDCCF73733DFA1F03F37EA6E83731B72F4F1325311
          11224FB1B4DEA4D3C5A58BB20A1F17EA1F0C079A45B03F5189033FB6CC86707F
          0015F486ABA68DA2C86CCF492AC8183F321B09BA44C8B20C41E2214A023C6137
          5A9D1D383760BEEE8FF3BDD9D91AF814CF43B927609D7D42AAD0C51E7A34735A
          D9446309145185244B708B3DF8B9BD01D9A36E80245104A5D0D053F1B8ECE846
          7D5FD7492E23B424300BEE3B02D6F4E7A5F23DCC6F15A6258FA4C58D25422A7A
          C56BF0A856ECA9ADC6F6DC0F51D5B4091B674E27E20C7841802C4980A2C01B89
          E0589BF94A70B4508A3970DD06D870018C4FC93F356FE2A2C733866542566558
          844644A410F40C8D8F6A1A615ED8012FE7C7C3C7D3B172720981501004110271
          0355852B1CC6776DADA75187D93808790860E9D582CDA611457B8AD366405101
          8BDC40262613170A74B48A2F4E34A369FE55ED5B17E746616D16E64F2800240A
          220108A46C328134F7F6A18973BC8015D81B03945E4E4E30F246EBB2496B5374
          CA3098A57A48E0C95A839440461C43E1835F7F41D73C4FAC9C1ECE8319A726A0
          D4381E14A9122F4A1A84E365545FB33845BF92892A843540795DF6EA6959C55F
          16A6CF845772C0AE98C1523AE25AD53A45BA79C006C19D85AF661E8A419C9C0B
          4FFE6E4291218538A5493909445470D9E64087D3FB0C5EC17E0DF0446DC6B7AB
          4A562E4A658D6895CFC219F6222270C481AA0929641169F27EA9BF1DB9BA32EC
          9B7AF81F27A207E57F4C41A6EE0128120D8EEC3887238CF31DF683D886E51AA0
          AC6E5CDB7385EB73545AC27B973EC618BE0C052979A0C828C330640D68B02C0D
          1DCB805382989B311F2643510CE215DD5870712A0CE4B889C4897B208C8BD6FE
          56E535255F03CCAECB0AAE995C397C50E9C3D6939FC3B594BBEF4808C8412CBE
          5402D1C5C3EBE670A5D7E9E35F95926E94E8C4F8E03AD3AAE1FD621B76D7D7A0
          6FB1FFBE01D1B6BC65067A3ABB31E81361B17BFCFC5669A4063055A7766C2EAE
          CCB6465AF1FDB5B35890F622F293F3498964D034033D1DA79587A668B22B398C
          D18F8529B16488F8C68E72B477B7C0E7200B2D4868E9725AD41DC8D300C603C3
          8E6E796CF902276F078741D8036E8464810852DA4233E4197D0BCA6150BA14D4
          143681A5D998F8CBB68568EE3C0F556661B706419121B3C57518BBB04403A41D
          D4AF2DCF9CF6D9184322BC829308D27F9F73224B765074ABF20A0FA7AAC7B1A2
          734366BEAD77052EB49D2199C5C01F10E0F7F018E40438BA83CF6237F6698011
          076048D527DB56E7971ABA4356B225296D83460715224E936E919C3856720506
          76444C7C477F251ACC759AB8488EFF756B00B41EE8ECF27BA524791C5E423016
          15BA23D85A913CE5ED51892AA2997F2B20EAC00A3FCE4CB7C5C4DFEA5B8FD36D
          B550383219F2617F4F98C4B88C6084CCDE13AAC21B7867689A9E800E36D42FCB
          9B5442D69544F48D688F8A47DF1CCC2001F468FFEDBCBE0927DB7E80CAB3247F
          140CD8235A542824B36C1DFE463098859D108702A2ED6B18E91075A62237375B
          AF638913453BC55137011D874F8AAB51E33D80E396FD503906A190049F936416
          A5684167B3F9DB9140C4B7A1EFA6E4ED37DA37306200470BC7A64F358E4C24A1
          1775A1902013A1C6D310C212825E1E5C58D15CD23A1A7E5F0403BDE14624E3E9
          5BC5FF1D106D5B48B972B0398E63AB1E4C4C48320C8F47B4D002294314162D99
          447E06FD1CDC2ECE23A9F22E3C84F751A9CD07F706DC6CEF12C3412C228A7318
          9636B114359AE893EB5271289CFA27B9526A61C011BC8ED09D24EE0EF80FDA5F
          3218CF3713424AE90000000049454E44AE426082}
        Name = 'PngImage13'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500536F20323820536570
          20323030332032333A31383A3535202B303130304E19C09F0000000774494D45
          07D3091C151316C077DB2F000000097048597300000AF000000AF00142AC3498
          0000065A4944415478DAB5967B50546518C69F7376CFE17EC9426EA35230600C
          0A33123502634D174853D434F156E27DCAB191C45BA5938022D76CB9595A60E4
          D0384E98E3A5094D25A7481C1D15911A25715920E4BACBB2E7DEBB679174FAA7
          7FDA996FF6DBEFF2FEBEF7799FF39D65F03F7F98477F1C3A74685E636363A1CD
          6633070404E4499294363030F087288A07BDBDBD5F311A8DB70E1E3CD8B262C5
          0ABFAAAAAA21DAA2FD67C082056FFA474545B6B5B6B6A4338C31D9DBDB678720
          087B15457929303030C66EB7DF20F0E4C8C8C8AB168B2599A02D53A74EAD6B6D
          6D4DA1837C17111171B5BDBD7D96C16038565151D1F018E0C081E60957AE54A5
          7674DC7CD7CF6FFE0C513CF1A2C3A1D4A9AA1CE6E1E1192F49726D4F4FB76F70
          70E8DBAAAAE5DB6C83137D7D9F286459760E055C4D87D8171414144CD996CBB2
          BC9E327DA3A6A6E6D7314071F18591279F1CEFDEDFDF86FEFE61CD6E17E5A6A6
          CFB99090D9D75956E12C96D3CF8686CE3189A225BCB7B729353474D14CABB53E
          C3E1B0BFEEE9E9314E14A5FD0CC3C4D6D57D9F3C6F5E5A1601628F1E3DB66C0C
          5052D220242525F1F1F1AEB46EDF6EC6DAB5EB70F1E2CF6869B98BD5AB97A0BA
          FA148DDF455EDE06BCF75E29CCE60E9C3851A04D9F9E297575356B667383161E
          9E71DE6ABDCDF5F75F8E8A887827B7B434BD7214704178EEB917F8C4441EB76E
          DD02C1505B5B8B2953A620252505DBB7EF407AFA222C5EBC18090909C8CCCC44
          4ECE6E0C0F0BD8BB37176565E5B0583AF1C927D9282A32A1A7C702558D914A4A
          96F10F2512E2E313F8E464773D834B972E213131110F1E3C4059C501ECFCF843
          FCF2CB656CDD92890B171A5053F30DB66EDB8C3B773A70B8FA4B6467EF447373
          1BCDFD84ACAC0D686868427EFE49A9B878145054745E98362D9E9F31C3EBDF3E
          93ACC0955A203816989430E6CBBF7A0611E8EB83DB5DFDF8B3ED0E525F4CC0F1
          E36770EFDE9FD8B8713DDE7FFFB0F4D967EFB80085853F097171D3F8975FF6D1
          373F0CA2D907C01C79138CB905DAE43990D32BF539634506D873D580757465D2
          32D8B77C0DC3E866A311D8B4E92BD9645AC9E980828273426C6C1CFFEAAB4F40
          D3464B7FBE0868C807C3135454A146CE82BCC8440EF80DFC47CF03AC11E2E633
          30566F037BAD09C2AA3D10976E8726001E1EC0071F3C02C8CF3F2B5041F9D4D4
          001DA03947EBB6B8E4E17CC1361D81123D17F212931E00B601607810CAC449F0
          581B0BF6E67508ABF3202CD9AACF7B91D299998F00F6EDAB17626262F8993303
          A9FA2E8934D6F5CD9ECE83A1BE184AEC0248CBCBF5001A7981BDD108B7EC5960
          BA7BA14425C0BEBF11AAE492C899C1E6CD8F00F2F2EA85E8E8687EF6EC60280A
          5C59381B07188EE7C0F06309D4B885105656EAE3C6D35F80AF580BB8F9C1B1E6
          7308AFBF05C8B47EF8714069E958066785A8A8283E2D2D14B2FC0F003C01BEDD
          09C3C97C28CF2F86F0EE5760EEB5C163FD3334C74173A86086E9448354A694F9
          B0E71E8336E20264653D06A817222323F8B973278D017443902D98C63A18AE9D
          841AFE02C45756C1D8540FE3C52334CB4195494F6ACC8800393A098EF9EBC78A
          9C9555451265B8007BF6FC20D22DC9BDF65A1844A763689FA2685009A4320628
          CE6FA7BEAA08453540351A5CB5728ED32267832243768C905505F0E45353E571
          B9BC6C3483DCDC3362787838B770610401E821FA4B464080110CCD767589080E
          E6F5601D1D0E8484B8EBFDFBF7ED9830C113369B0CBBDDB9DE1D6D7F7421C6BD
          898AC460E3FE4ED954BAC605C8C9392D3EFDF4339441242449A11B55818F0F4B
          8134EA4BF0F535E841FBFA04F8FB73FA897B7B1D1837CE0D232312044181B7B7
          1B7ABAFB10C2FE0E8E655054DB2697558C02B2B39D80306EE9D2C9BA8B3A3B65
          04061AF5A0168B4019B8E97DB3798432F0D0FBEDED36040579617050A44B4FA4
          43B8E37E5B1742D4EBF49C3228386A91CBCA4701BB779F12C3C2265106D12491
          8C81019936383360A82F50369CEEBFBE3E914EED92CB99C1F8F15EB45E2263A8
          78EA296F74DCEB440CCE81671DD87458913F35AD7B0838498089DCF2E531BA7B
          CC6685A460485B812EAF215D2E7A09510D86E0E9C9922C22BABB87C0712C9DDE
          4175709021540C0DD8C8AF839A286B9243F6EA2E2D5B3E5107ECDAF5FD353264
          88C5D2A109826CD534851AE89E30585916562AB69574A73E437D8DC661A557A5
          5551D82196758DB3AC6AA5D72C8DF9530B70D4D6A62AFFFA57F17F7CFE06FB7B
          45463208E4A10000000049454E44AE426082}
        Name = 'PngImage14'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500446F203134204E6F76
          20323030322032333A35393A3234202B30313030B95D9F780000000774494D45
          07D302110D1311C99C5588000000097048597300000B1200000B1201D2DD7EFC
          0000044D4944415478DAB5956B4C5B6518C79FD3D25268CB750586E0021312C0
          00D162D40FC40B99B098B8C8079831598833D3A8711AA22266C8205CC34DE583
          C592423B4CEC34C6A099269B8E0F1D864AE2200652430D946A6FA4DC4A4F4B7B
          7C9E97C1CA25D91AE39B3C39E73D3DE7FF7BAE6F39F89F1777D4C3818181D88D
          8D8D9C5028949F9A9A9A9F9E9E9EAF542AF3C53192131337272E5DBEFCB13E6A
          805EAFCFE238EE8BC2C2C2876432D98389898992E4E464C07B08091C84C200DB
          680B0B0BA12B3ACD0B9D9D9DDF471DC1E0E0E0506565E5F99C9C5C10704FA2BB
          C2BB16C21FA6A76E79BEBEA22DD26AB58EA800941A5CBFBDF4F2B922B154B623
          18297EE71AC49B6FC7349AF7DE7EFD42D435686B6B3BF548D913D7D44F3EC51D
          1217EEEE2DB3D3FE1FBFFA3C5BA3D1B8A32E724757D754ED2B17D520921C8A62
          374D3C1F80AB8397EA067A3B7551031A1B1BDF78FAF9B39F3D70B2689FF70741
          BFFE30AAFDF0AD73E7A306D4D7D79FCC2F79DCA27EB67A2F4D7BE2080A0483E0
          F97B11AC53D77819F86E634BFFBCBDBD6DC4F49AEF09E8EBEB4B1204E1315F90
          FBEE99B317634994E77970DAACE05CB280DBF627F8BDFF80421E07595959505E
          5ECEBE9B9B9B13666666CC08FBA8A3A3E3A77D80FEFEFE749C8177B1E79FCBCC
          CC7C382323437CFDC62F10ABCA05E7A2057C5E07281572C0A1031C3A50A954CC
          684E140A0588442240A79823131313C2F4F4F4A7A8F54E7373739801868686CC
          A5A5A58FE2B442381C16E2E2E2049BCD06168B85138BC5DCAE604A4A0AD03B52
          A9940946DACACA0ADC5E3683542983C05F61C164327DD0DBDBDBC5000683C18E
          A11EC7A301C8309F6402092524247034CDB40E8A92D1FB41AC89CEFC09FC9167
          02BB6B0DDE870EC174FDD6526B6BEB893D404545C51E2012841141525212E000
          EE130D0402B0B5B5053E9F0F363737C1E65C04BB7811D2844C800D11CCCFCFF3
          2D2D2D3206181919B15755551DA77B123C0A2297CBD99544499084C968EFF7FB
          1990DE5D5B5B038FC743571E6BBB03D0E9740EB55A9D46A152D128CFE469248C
          44DC6EF791A2ABABABAC0604C6FA011E94B4E7B19B7600636363AEEAEAEA63F4
          91D3E964865DC5BA066BC0405EAF17B00D99283942A2E429C1E2E3E39953744F
          CFB2B3B3C1E572F1DDDDDD7701B5B5B5C7225383FD0CD4490E878309500D2627
          27E943E63DA58C44A935C97B4A4D4C4C0C7B46DD8620BEA7A76707303C3CECAC
          A9A9515178B40E169B5243DECFCECE3210895244EBEBEB2C52829149241206C7
          346EE23B463CFEEB1800FF3C4E23FDCDBCBCBC53380F629AD08320BBDD0EE3E3
          E32C7D141DB52E3944AD4C6943E1108AD29161C0547D834EAF1F3A2ADADBDB73
          51ECD5B4B4B4BA929292F4E2E262E63101969696C0683432EFC9EB3BAD2AE07E
          066B64A04CE331B37C5F875D535393142F2FA2F86B050505E56565651C75CBE8
          E8282B300A2FE3FE4B1246D1DFA33E4D2357434343219E3517B09BCE60316F62
          FBEAAD56EB0D8C2674AF6FEF0BF05FD7BF9D46FD372772AD200000000049454E
          44AE426082}
        Name = 'PngImage15'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500446F203134204E6F76
          20323030322032333A33313A3434202B3031303084501C480000000774494D45
          07D30218001C104CD3A508000000097048597300000B1200000B1201D2DD7EFC
          000004294944415478DAE5946B4C5B6518C7FFBD7313B958D8C8A08AB3B35B22
          41402703C7026440869160F002784914936D71730EB31983986C8A8B11A390B9
          2F6359900F9801AB2CC4145BA0D38105C61018F4C22A5084164B4B4BA13D3D3D
          BE6D71A4192C6ED10FC63739C939CF39EFFFF73EFFE7790E0BFFF262FD0F01C5
          0A09966DE5E0F2F6B005A1428F73C5469EFBC10A6D863CBFFBFE012FDC880435
          FB85303EA63C6BB798B33D210C3409CFDB8189190A23FDE38C5DA751C0C32F87
          A270F6DE002F0F48C02CB49714A627E6278541B7008C1981DF6D809D505C6E60
          850156975D30C9A43A868A484757AEF1EF012A8676F2688BE2BDD2BD313B8540
          8706B0AC021E0F4091D72B449CE8C24E2E178939EDAB30FD206D43F78B458180
          23BA54721423CEEE98BA1D3B3A2C645BCCAA0F5FDF2B12470357D4809B88306C
          725AA23EA99DC2928578C40B8220761B183E1F2E928959A5621C93FA34F4940C
          F8016FABBECC498A7D476D58B04F590529A8DBA5F1C1DFEC6B3FF85C5241F663
          027468C909891D1C2E303C36C30CF4AB95A0E83AB8DD1A78E878D0F4AB916271
          718444C272585630DFD6588BBE8A633E40C4F15F0CD277D3E2E46A06D52D7D4A
          7C2DCDC2E192D73276C49CAFDC1F876EBDDF063611BFAAD232BF4E98ABD0F8F4
          69B29509B033B7AD3A2625F9A390C404E89BBEED4557D9336B1928E52DC732F6
          790B3778CBC8B45CD35487050B0ED6BF911A6BB00273C40536B165F4961132A5
          BA068D992737AC57DEE75C36573C91585498A8BFDC3EEF96166EF1032A7A3EAE
          294DABA25941080E023E691D64F293B7B3B2C5E11831FAC51DC4DCBAE6AE5EB0
          781968C8A4376D8ADCD64F45F90527E694728BB3353FD20F38D497FD4A467CE7
          93A2AD3E9F59241A26004C767F5179C49AA6AE31B7466F4D4143FAF05DBB2EEF
          72D196D4D416F3E80D83ABB5609B1F704415B64B14F5C7D1AC44BED9415A90F1
          5F5E710FF9626E7115E72EF574801B72C2D732215C1AF5F2EBC0FB9E3B339026
          3FF4C4E383E6E1C19F3CB297326EB729FF94FEDA3785A2DDE6E53500D9EA66FC
          551C9BB5627C6A013C0E1B6C921E4533189A9CBE4A6B45FB207BD81D00785E26
          7A2032446FD34FD643517E787D0EAA74674EE7C45786F379BE81211AA0BDC3E4
          5903C27FEF8D31C4B28E9F3518F9CD2AC1B9B4F10040C1953816E3303094B318
          9D652DEB805386036512C1F799A268DF74D26B62D49A55DE4CBC76E9484BA96E
          4E7BD4C69566D42B4A81E3813615C812C02C8EC2F5E056FCB8DFBE0EA8B145A6
          462F990E3D15C721D3EECBE0AF26277303E5B8012AEDDCB4CDC65C4468D405D4
          3EAADDB0C845BD8F804B7F80EFF6BC75C7BF28FC2BE3D0851C6192D5E907F4E9
          9720D7CEADEA662929389CF330993A71F1D9CD5B748315F8B3ABB557E609973F
          735134BA66A8EB1E87B301C1094DA80A32DF8BE8E600EF3AB398468E6FC7C9A8
          9BF72B7A77C03FBCFEFB803F01C5F4E828435CDC7E0000000049454E44AE4260
          82}
        Name = 'PngImage16'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002A744558744372656174696F6E2054696D65004D6F2033204D727A20
          323030332032333A35323A3535202B30313030354C72630000000774494D4507
          D3081C0C170FEEE707A4000000097048597300000AF000000AF00142AC349800
          00026B4944415478DAED965F4853511CC7BF9B4977EA6A508409266CA387396B
          E81A51C66C654912B220C9178B0887D4630FD2438F81542F1185154110044510
          56E84A21FCB34D5418455181E0AA8D116B7FEEB873CE6DA77B57979DDD5D29E1
          DA53077EF7FCCE3DF77E3FE7777EF79C735558E7A2FA3780217294BF8E2AACDD
          0197CA2D02C8508B72CA0F03C06484775C2A5509C0E58E2843A8A90118A61470
          60EB6FAA928506CC5BFD50ABCB9FC9E74B2D972BF7A5B560CEEF965200E95B7D
          20C28BE2CBD9EC2F5FACA5BED86E9CC2DF03C4D1D162FF01CAE720770EB25F11
          214561C1C468E400749F2CC07FCA89CD869DD05F192C080BBD331DEDA8759E40
          DDD97E6432F291C84DA1799A02DC784788E9D836B41EAFC7474F18C66BB7A039
          D88591BD36749A13F08C7DC39E050E4B4B45716924D2769387020CFA09B1F518
          B0CFA1839AA9C0D82C3F5D55D538A20BF24B9EE055C800FBF0680140E7838E44
          0AD8E5A500ED2F0979C2DEC5DCC501D87BF48805E360D81CB40D0C5E3F0DC3FE
          258A54AA7C15D330BA2DD86E9F2407E9D3C0C4F93EB4557851A9E1EFC556E099
          08C1FA8905C71585E8A44BB70C3A1ACB8C648A1C772E2031FC08879C754024CD
          2BE5115888E383A90B6DB7EF239994DF8FE8D1D37EF32C0578DCD94D1CCB3E6C
          316E02D22B488593A8D2551686B41C49E14DC684FDEE29B06CB9B81C40A85BE6
          6840732B39690801DA0D987607C1ED68C0F6E8573459AAF948B278EB4B42FF3E
          8D68B4749A56DB4905B3CE5380F14673CC614CE8BCFE3816BB2F217E66009A9B
          97617971153FB81CE2877BF1BCFF1E1E7C5ED369401D997C19D16E9C34DB6A9F
          D58F07AEAF49E60F65DDFF2A7E02C93647371DAEC6CB0000000049454E44AE42
          6082}
        Name = 'PngImage17'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004D6F20313520417567
          20323030352031313A33313A3134202B30313030D9FE197A0000000774494D45
          07D306050F162F5CF50E00000000097048597300000AF000000AF00142AC3498
          000003D24944415478DAB5965D4C145714C7CF9D5963E243A9F8E4036BA269E2
          631F6A1A882F6AA32F6A444D4D5A1F6AC446512B08222CB81F566061D9D24229
          28F22510F1A398B4B10F7D2144ABB8B0B4F1C1444D2088189B564D1750F663EE
          F1DC3B1F0C76567971929B7BE74EEEF99DFFFFDC3B330CDEF3C5EC37FB4ADAD1
          BD7205A4342E9F308EC019EA3D2220726A74AF32F8FBE9B327AFE2AEDCBEA6AF
          238B0678EAAE6165D18E4565767DE02EB4F5FE1ECBF830736B6778FF8D4501CA
          6AFAB1AA241740646B9B17639A928DB4814A0A86A20FA1F7F604C42626A65D71
          DCDCD57860E89D80D2D035AC2EFEBF02618BB838EA4D5518DC1A790083F7FF81
          651FAD85C8C52BD34B10B77537E40FBEDDA2503F5616E73A4A45439500280418
          1CBA0753CF5FC1EA4F3E86E8E40C44FAAECCC06C724B4F73FEADF40AC8A2EA12
          67804101CD005CFD6D1806FEB80B19CB3F80589C43EC6502A69F3C9E59BA74D9
          F6CB670B06D2007E26C0CE7702681F41229984B9440A12090DE6E6E2F05F6C16
          EE8F3F85FE5F6F3EBFD452B4C21170327815832777C97164644C3E1496885D9B
          A24152F41A35143D52CF40A37B65890A5BD6BB094A31FCADD0163AC81C0125D5
          97B0A6F47339FEF3AF8905851501052829C6DC68068C91651B3ECD9209947ACF
          425B5DBE33E044551FD696EDD10F13630B7690B945658F6881B9517CD1929C11
          E01C010E39038A2BFB30E4D9039C563E9A7AA107B682CE07346DD32C80026BDC
          1990D008E06B818EF0616740D1995EAC2BFF42DA717B78CC0288607A50949670
          B30E5C7FA6B854F82C6715244881C7DB02EDE134161DFFB607C3155F42825646
          A2E3B622A351073DEB945578BDA904D8949D251594F95BA0337CC4195018E8C6
          B0772FC469D56874CC2AB2CCDA165033B33794282E85006EA9A09C8ADCF15D1A
          8B0AFCDD58E723006D87E8E8FC3635AD305598C0A401535403400A3CBE66E8AA
          3F9A06E0EBC05AFF5710A7C3333232BEA0069A5958BB02C33E455561638E5BEE
          A20AEF4FD059FF8D33E0A8B703430102C435B8333C0F40236333B06E9B7E2ECC
          83B6297B15A9238B7C3F42D7F7C79C01474E9DC7DAC07E9823C0D09D716B5EB3
          6D554D04D66C8AA44504C8C9920A4E799BE0C20F05CE80C315AD5813C823400A
          8647272D05E25C9805D76C6A640FFACB6FFDBA2CDA1C0CFCFE46E869284C0328
          6FC5E0E93CA900ACF04C76B2E0C6028EFA13A04F28A799149138651FA7769A00
          BD8DC79D01873CE7B0BC348F6A90B44FCF07677AD6E29EDE7336BB50B791B9A0
          3ED804DDE92CDA7D20889999CB6991F6068081C855FF11A031A38F3F173F018C
          8272F95320C6E267E0C5B37FE197AE8033E07D5CAF016C967F375F70B62A0000
          000049454E44AE426082}
        Name = 'PngImage19'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000004E34944415478DA
          7D5559685C6514FE973B77EEDCC9642666B5599A65D2495C5AD4566391825644
          BB4071A18201155F04F1A5541FAC48C10711A4A088880FE2F22AF860ABD0564D
          4B92D6569B5623496BB5491B1333D99399BBFDCBF1FC375A6A5BBCCC5CEEDCFF
          9CEF9CF39DEF9CA100406EB8F09D523A8C8AA13711951672B5773AE906F2BF17
          05AD09A5609E48142C7BC1B40CE74530198545014B5470DF9F25BCAEA3BBD771
          6B81003371D0855F0FA4955A59BCE87B573CEF2FA04B5A969590805F118502EF
          650A8A275349B7695DE1053B9555A039A118FB264017463F61D138838A40052A
          0AA492520B0D8A02671430BC666027B4EBE6DBBA9FB79D0CC184D88DA50178A5
          895F863EB4A8206031CAD191C617D60A8841B45682518B59C2C9E43BD7F52692
          9537E1C84426ACEFBB4F2B532316CB10863F2D4A13CC00514D94D612306DAD29
          48C6442ADD912FF4723B85FDC00A574188A1191421ECF4E9635C0C3A8E83EF18
          43144E195586592C4DA28D220224FA86C0FDA4DB962F3CC3ADA436A180326648
          0385C5E9E15F473519B6618AD13440801E001C3B0AE80D9280D2B14A18A087AD
          7929E5B4B7177603B708604C9317552A1AEC7F4F46F5CD9DF794168EA46D3708
          CA1C0FD100BB0D120D3472AF43691E24A3CC6269C6CBE9EC5DED1D4F118B5FE5
          488F0C7D76F98F936BD7BF44E5A40D939C27855416C776199E1142C950295F89
          C07453F9D86924D1B255B6BA676DFE714AAD3823AC2C0A8E7DFD8A5BB3A1BAF9
          21BDFC43B62A1B843241905BAC4980C25CCA529665E461464A841A4274C373EE
          F09AFA079B5A77C055658F8F1D1F39F1F1BA4DAF46504C9119B7A2438A452022
          6E17665456D25302E1422985D22B48995692028DA2524B476F73FB16AA0D8D58
          043979783F4B3A4D85E7968BC76B1B5AB4625407A863149141918112CB121625
          D2A5F0559932D762F567CE1C5ED3DCF3C8B6BD46B978C298353F7761E0C8FEF5
          F7BEACB8ABC3919AEA3BC2701EEBC6D62B8572F74006584010F952FA40730A1A
          B54EFC7CEEF3CA74EE89DDEF6069582E9261547F6AE07D7FF9CFDB1ED8337B79
          A03657C7AC9490650081C12CC665E4AF040B81C2C5502365865915AE139E3DF5
          41C2CA3DB9FB00968603616ED8D79237D577685FF7DD4FBBB9C2E2D4D1C6A69E
          280C38634A95975666820809AB543A872D6716D59464EDCC8F0307DCF4AD3B76
          BD61303060AC299C0AFADBF01763A347376E7F73FACA502601A974D5DCE2E530
          228CD7122B83B550CA4045A87E3797495BD6B7075F6B6DBBBF67CB8BA8094D62
          850341B1592899BE437BEB5A36B776ED9CB8F8A5243CE9B4D96E1D671C19F625
          AA456652699BEBA599C1E2D4A87B4B4BA16B97EBD6A22071E8A9595838A17152
          9363833F0DBCBB65DBDB2175B4908EED2A1D054244D2C898CB95F9E993C5D9F3
          D95C53BE7D67B6A635DEA8DA9476ED3230BA62D07FF8AD2423F73DFCBA17F991
          F0310C4E8A5F1A9FBDD2BF30375E55D7D5D6F9682ED7BC0AF18FE37F81702870
          0AD9FCECA5BE6FF66CDEBAAF7ACD462F9C5F298E4D5F3ABAB43851D5707B67F7
          F68A4C93B18BA718A1E2CF8D4098A431E0674F7C549C39B761FDB3177FFFCA2B
          4DD7346E6AEFDA9EAD5813074332548C72ED62BB160807C8308526DC0F96BF3F
          B88791A031BFB535FF5826D310A78BD68A219584C78960694057D7C87519C587
          7882EB8ACE15CFDBD8E48AFA180257B8791DAF43B2FA1F66ECFE05FA1BD70917
          E18DF94E990000000049454E44AE426082}
        Name = 'PngImage20'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000004524944415478DA
          9554494F2A5918A50AA88202CA11F039D08AA84F8808C64E5A9FBE36E6B5EE5C
          FB1FF4EDDCA889896EFC0D6EFD0B6E9EBB468D51D2822DA0B432383068546854
          64AAA10F94A1DB61D337E452F5DDBAE79EEF3BDF3D44A954124591200859653C
          3E3EDEDCDC60160401718AA2EAEAEAF47ABD4AA5C22A22D25CFD5E1A78258AC5
          A2B490CFE74F4F4FB3D96C4B4B4B4D4D8D42A1403C97CB5D5F5FDFDDDDB5B5B5
          B5B7B7D334CDF33C3E96105F61150A05922441C1BDEF36994CE64E733299C4CE
          E7E767B95CCEB22C70F17070708079707010D44056F66E10480DC7EEEEEEDA6C
          365A45FB7D7E9CA9D56AB10D2763E9E9E909A959ADD6BDBD3D86619C4E27963E
          60C4719CC7E30144A35EEFF7F9EA6AEB589D4EAE50E06B5483E705A41C8FC7D5
          6AB5C3E1D8DEDEC67948F33D2922954A793D1E7B7FBFF7CF4356C71A1A0D0055
          2A9504498882C8F15CA958A61C0C062D964E6CB8BDBD1D1D1DFD00C8EFF7A31C
          8C8689C563164B8F56A3A3690A95465ED08DE7C1982B164BB1D8553271E57038
          4F4E4E86878791E31B2CC2ED765314FDF8F4A0A42893E92746ADA1944A8EE721
          02041578BEA22D91CD3EF97D47BDBDBDE7D1F33E7B5F7373330E7805E4DA72D5
          B0ECFD7DCAD0F4A9B9A58524C8CC43E6E1E1010792A41CBF4AD565400C06031D
          1D1D8958DC66B3B6B599DE02FDEE72A955543E5FAC6D30A0DEA9D47DBE50502A
          1572A0C8CB25572895E88F5C361B3CF6592CE648283230E06C6D6DE538FE15D0
          BE7BBF90CF318CA6C0C9548C461405454532CCA4C4470E44F94D32190DFDD56F
          B71F1F1F7FF932DCD0D000415F019D044FA291F0E7CFD670F492D668B42CABA8
          0CA02800803F545D143D077F7CD2D71B8D864838F2EBD7AF04490AAF5B894045
          367FFC703A070A253E7A79D56834EA743A8994AC72A3048E0B8542329EFFE5E7
          81402060D0EBBB7B7A38AE044D2508E9864163010D8926181B1B4375C2D10B90
          62B43A4AA52AA1C74BA5BB4482A12887DD1E08067C3EDFF8F8383A60727212BD
          8675A9C5CB409019F3E6E6262EFDB7DFBEE12A5D5C5CA6338FD01E7156AB331A
          F54D46039AFE2C14C2EAFAFAFAE1E1E1CCCCCCC2C2028493BAE9054862E872B9
          229170575717BAA9BEBE1E078A82F0FC9C4BFF9D464689449CA6551B1B1B7088
          A9A92944868686161717B151EA83B27BE08FAC8C68F4DCEB3D44EFA1C2E59B89
          02093C4DD1E843B59AF9FE7DD6EBF5E2D299CD66248882F4F5F52D2D2D810D6E
          FE0B90440FA2E301AD94C9641007298D4603A5B1F9E8E8687A7A1A4144904E53
          53D3C4C4042E204C0A3996B5AD02FDEB756544F98B1F8A225FB14A58DAD6D6D6
          FCFC3C2E309E41A1B6B6766464241C0E77767622FE16E8FD7851972060BB3B3B
          3BCBCBCBD822592BBAA4BBBB1BCD313737F7315055D43741A8060B5C59598123
          2302DB409A409C9D9D7D0B5485A83AFC7FCD1011E405C3405DD2E9345E819548
          24565757CB40EF7DF3C351C5052F6041AF582C8692C112D6D6D6FE1F50952F78
          81C8D9D9195ED11C30F57F00D8DA90E2B8A992B30000000049454E44AE426082}
        Name = 'PngImage21'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C180000055E4944415478DA
          35546B88556514FDF677CE7D5F476FA3CE383A8E8F29D34A7BC920D20333CC28
          0D0AE9570591204941FD90FA11455144442F4A2C5022881E42219450617F0289
          342D2CD38C94FB9A993BF7FD38DF73EFF6413B1CCEE172EE5EDF5E6BAFBD6066
          A6820822BEA410C82F105909D6A31EE06CD42F07AA332C3C0C4DB8D428C15501
          049E0C0822704081B85C2925942B9780D2048A7F024002722D7DBE3C383AA74E
          58B00283A1A69F0AF3B945091B290BEB7476B318DA04A090485282F83F02E2AB
          5AAD7AEF4192C49C007FA1FB51551F49279625603E91EBF87EA6D1BA233D961A
          990FDE48EB5CB7DE37ABCDD813945D2CDD8044CCE60A9010967C5EC8CEEFB597
          5BE1D97C72AD8AFEAE479548B55A182DAED3AEA1A5F951E0F32858182427BC0D
          D434E9B1E7C4F098F0E60A50A55C66D40092A7EA2FB5E84C4E0ECD764FF65C5B
          BBC0B8640771795D3DBC6822B784BCEE01113A1B06A32258D92F3B3DF9B22C8C
          91B731D04CB98A61A6DA3872363A180630DBF943135A479183287EE2584BEF1E
          5D951F4163FAC0C2782950A15C90A12573332BECC6575292854FC36C795A7B73
          B2B2B79328CEF52F5A14CA06DA79E5503918789C689ABDE3AB7323CE99487801
          2834604A790C32428FB6834793D73F644941ADDA2ED5BE3AD17DBDED1B91F5DA
          4965ADF6A41C69143DEFAFA9DB67565D9D1F31560D240A24042719910F823067
          6636A8A9B764260795EAECE973FB4E986F35286F1386BFA351368CBCB35E7408
          6FA8D97D6BD6E41759AB7ADC0E790044C7BAF2DCB532BDAC9F7895D6ED806AF1
          D2E7BF6C3FEB2FA24B7AF28E2DC03AA054821439566A4343BFB0F6DAF44227A2
          2ED7732F82DD6AC02BEE1FA46ABBF127E58617E1C2B9E3EF9EDE59B703CB4375
          682CF72C1C43321AF90104EB9BF8C6FA159961AB4D141AC478169E6C8C882824
          F719DC126EFB0C7EFBF5CB0F4F3CD2F712594D363F0339619CD028C9BA01C8F1
          1ABE79FBE470A16B7B8E57858B3D3AF040973BD78CBA181F380697BEFBB2F8DE
          1E032450A227241E310B417C182205246606B0E6C6E4FA5D43A631CD45E01331
          3526C89F1DF7651197C1CEA350FBF378E1FDDD4E35D149EFA5B764D9E70E1DAB
          E084522E55183DFF6FA3B049AFDD918D5A4DF20137123AF4AC004A6923135E9B
          B8FF6B2815FFC9BDB65356FED29840CBF5C259C158EC498C98296FA7C82D595D
          2C7746B6E8D5DBE751BDCD842C52E8BDF332B03D3B720F6C3904C5DA5CE6E367
          E9D8A78849D62806E29B4D6450B05E5AB0080C9D5EB66676BAB9742BACD806BA
          D9469760A9580B70DADEF47CB8E16928D56AF2E4F7B8FF29ECF51C8BA8B91D61
          0DBA2B4F62D018DA4396B1EA73ABB62556DE99D4ED1AD900648022E3B99DD1EB
          A0549E960EE99DC7CCA9E3AE67348265FE8A45645E18EB65898CD4C44C82FCC4
          64A3D99ABC3758BE195DC77284B84577C25DEFF354A0582E522A45677E76AFEF
          D5ADAE6A7588217CE80DA3B085819FCC120CEFBDE0DD98BFEA9AFA5C73ED8399
          F1DBE6B55A8D70EB61284C023928558B3C2F994D9B2F0E743EF94068D36F74AC
          329C0D3C63762673E4E003C7B3620F090418BEF1E69EE9ADD8EC163EFE8298D8
          89BE13C6C1562CB18338632029BA870FA983FB5972DBEE69BE07861DCC66F124
          E2400D64984E8743F34347F3A63616F6EC59B071CA9B7EC0C19280981AEFB413
          94E0F0CFE4073FFDD03AF076EFDF8B9C3BF1DE69EF9413A18030948C64789121
          77F7D6897DCFA646965BD5E558097C824D0AA55289887751C4392908B3596837
          EADF1CE91CFB519FBD803A8A498A3029C12FB82A77EBC6C53BEECB6D9E0203D2
          1A1B70FEFF9FD9954AE53290E4CD602029039190E9A46588D9695F2EBB664724
          53E1F0707A7C4C160A5222C71D33C0000346894B63A0FF00C9B6F6046F4FE106
          0000000049454E44AE426082}
        Name = 'PngImage22'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000005804944415478DA
          5D55696C545518BDCB7B6FD676A6DBB4CCB474D8974EA7B4A0262815DC6A2460
          880441B482B556D6880AC12510254645139586909010932A3FC484A2FE20B526
          04894109460109A5580A5D6698CEBEBFEDDEEB7DAF88E09D6492B9F7DD33E73B
          DFF9CE838C2F0028A508400801608040C020C300F15F23BF9E3EFFEEF6DAA5CB
          836FBE6DB53A0960981AA7045006B1008C1B930B721C7EC4011085D4D880C83C
          CC27A2970E1F94FF386B498C8B2E4F04E2866D3BFDAD8F0280296388408A7508
          3104F03F20C6810C3CA86328004018B9F6DDB19B478F54625A652D8946C26EBF
          5F968BD189046A6C0A6EDD555EEB3798530610027731E21BC6BE591818BF7CE1
          42F7C78ED1619FBB54671A21AC9049DA3DB59642963A1C857C21A490DA55EB67
          AF79CEEA2835EF31931483941202900041319BBAF4E5A15B3D877D952E574985
          ACC95C0ACC503A972BF156D24C9E8B86050963F1562C9AF34D9BBF7557DDFD8B
          B9B28C10C459E8BC3242864F9DBCB87FAF7B7CCCE32AA122A608235E2427AE68
          D14CBEDC5D6D818A8E11A118A932FF5B28486304391F59D1B8F165A7B71E1266
          009D7B7F77AAF72B37C9DB04496798095810A94068BA00AFDBCB52C166F15678
          EA8D019F44455154A94E34462074BA4A8B5677D4EE6C79EFB3AA4010CAC542FF
          B34FCE614A3634C288CEE5C314E68BEA18B28C0616E145ADF629B5C56252BB3C
          E03ED73F3D1E2AB5494810281380AE58EBEA928496AEDB167CB1032AC5E2A98D
          2BEBD5427E640813A6E5E51085E19941D2FA58E5DC86EAAAEA8A12474153C213
          A9D0E830F9EDE7AA3FCFFAB2132EBB4D1304A96A4A060AAEE75F0DACEF8072BE
          D0FFCACA590AC80D5E8CE5D399392D64595B45F36297C75761B72001719B41A3
          A52C972F84E3F1CCC83038D327FED2E7510AEE99B32282BD6ACDE6F92FB47346
          85BE358F572423312654B577552C7B5A70DA1D00620614A8036AB6D8F0A9B110
          830AD355C052BF9F0B7F7BD43934C8F45CD9D67716B47742A2919F76746149F0
          AC7B695AF37D2497269442A031A36712628421D327A6D90880121378B3991DE9
          3A3D7FAC47FDF1FBA6AED76B973E0109D5B93F62A9642C9D9EE5F3237CD7FC18
          F7A9A628A2C5C2D998D488F92DEA9A9E2BE442E1F0FCB9F30CD27CF2CC9905B1
          58349BCEFB67D4F7747F180F8F208B0D334A55B9CC37F5A9F55B7E387381281A
          F7159F675E9D4AD4B6879ABDE5CEEB43C3814083090D6F034563B14CB6E8F7B9
          DF5ABBC42687B105F33A3445D31D759BBFE83BF84D7F795929D399CAA8158BE3
          9189B5CB972C0CD45FBD722D1008700443BFDB8CA2D1645EAEF779F66D68B515
          22509410268AAC33E7D4CEFDC70F1D3F6DB3DB354556758517178E253B57B72D
          9CE71B18180C06839308774A8B24B205BFD7B777C3C35AEC6FC1E682A63A56CF
          D44D9FF6EE397442D5019F3B9D7F184A6573BB3B563D30CFFBD795C1A6A62653
          4A636829E7C535CA64B3DE6ACF9EF6A5D9D84D2CF2DA80A2AAE5DEE95D9F9CF8
          E8486F465645C09F1478E4294A6EFBC66716CCAE19BC3AD4180CDE0B148F65D2
          192EC4BE8EB65C6C5492781C005E89DB53B7F340EFB5D1096E37BEC580CE4312
          09D6B933665A2CC2E858A8B1B1F11EA078821B20EDB05BF66F5A914B8C4922BF
          0515557754FA767C7E5CB2D80151187700E54481911A1822C462916863E07F40
          F1583295E2C17960C7EA7C72DC04E2A511478577CBC75F636B29D7921829CEED
          69DA9D21D12225D3894043E0DED212F164324954B9FB8DD57232248A123F5655
          622B9FD2F9418F6477515D137808433ED70C19E1CF5CA5EE6C3AD3D0D070BBFD
          FF8A1D1E198D96BB6C27BB5F93B2379060E1A34A341D39AA1FDC7CC066B5F2C7
          0CCB9B2D9E5CBAAEE772B996961660BE84E0E4138A2C8F8DDCD4B1C835C09CBC
          99E1800FA911E888996B32D4EF588F03B9DDEE9A9A9AC9D37F0001061ECDCD62
          34A60000000049454E44AE426082}
        Name = 'PngImage23'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C180000052C4944415478DA
          9D955B6C14551CC6E7CC99FBCCCE65677766F64209A841EE8A404044821A4230
          36268A18821151093EA0108D26D80725DE12359A184324688C099868A2D1181F
          24F101BCC4D2EED28B14BA2DD22DEDF6B2DBDD76DBDD9D9D99339ED96D893EF0
          C279989C9933E797EF9CF3FDBF030A85C2C8C808494282F0895B6ABEEFD3340D
          52A914845055159F00C0473E00780CE0D185FF0001F050730A31DF09FA20E863
          089E06FA33FDA0ABAB6B514B8BA6AAB726A7D92EA43B02502291B01171F0D81B
          8A24920CC39014C510144D5114891F0C0569069210C060F924168110725DD7AE
          BB73E5F2B264CBE1670FA452F3A078A5EA6D7FEAB98819A1298E636856607896
          66598A65689EA7399E6669BC019004D0715DCF4575C7A956ECFCD4D4F2458B8F
          1F3D92EA6C82E2F1AAEDB6BEF8B261460586A338C87382C8B382C0883C23893C
          CF332C0B1B12A1E3A36AB556ABD6AB35BB50282ED2A247F71FE86C82E20DD0EE
          57DB92515DE4385284214EC01425C487429C22CB2151C02CAC1160450823EA95
          B9EADC6C757C6C32CCCBCFEFD9D7D179A1018AC566EBCEFED78F9B96268B215E
          A0058195244E57C5B0A669AA1C56555594048EC5A756F7BCD9CAEC4CB9542A96
          4647C74294B467D7631D1D0D502C00D50FBEF94E221E5543215E644491C77274
          2D148DE886A69BE188CC4914010141BA845FF7ECD25C693C9FCB8E6659877D64
          FBC3F34B0B4076F5F07B1FC662610C1225BC1C4155A488A65886118B581141E3
          089A4081897C32B053D5AF4C94C7068707D00CDAB16967FA62AA01B23068F695
          8F3EB12C0D3B4052782D24EA61D9D075CB34936A422005123B0F33164C894837
          EFE433D93E348DB6ACD99EEE4A0720CBB2E66A736D274EC6E398C0856431AC8A
          BAA644C361CB3063629CF1990030CF09DCEEFA76BE36D177B5273F34F5F8CE7D
          29ACA8BBBBDB344D0C7AFB8BCF6F8BA9725416B126855564C90847227AD8A463
          80E06E54461DD506AF0FA67A3BFA3397AF5CEAB3E4E4C7EF7F9A4E2F804A85FC
          CE275BA5B0B162E5B2B5ABEF30226A34AA9767CB76AD16339392A4B01C250892
          E3A26B6303DD3DBD994BFD1323F9C991F1D52BD67E75EA742AD5D9DC232B9B1B
          5B7FD75A2B4226A3F44041925551D1655CBF90A20D2B6A988A1696785E420814
          4B33F9C9C9D2D48C5DF14A85E2AA3B577E73FADB54B3D6F01E0D8F66D7DFBDE1
          AD675A1EDCBA646FDB85A1224351089719092908292E281C9A24C9201D90EFB9
          B6EB3B3E45954AA52D1BEF3DFBF32FE98B1DA0BBABDB308DAB43A34FEC5AF7E7
          970F2437AD39F6D29977BF4714E5E058C19A20C49371A9627DAE0F1CCFA700C2
          75E21114599FA96FD8BCB1FD8FBFD2E9767029D5A3C5F58989A9739FB5EE7D7A
          79C145B5EBD3A77ED21D731574E708C440CAFB4F10050184FC2001F08B5DB363
          86D9D6D6D6DBDB0B3A7BD24B124B2707DBC5FC6B399468FFEDDC0B87B7FDFEAB
          72CFEE13C0E72049A020EC104E2FBF1176A0D13C147C2101C07982532593C980
          546F6FBD5A077F1F5BB7CDE9EABBD2D355D97F48EC3BDB32AB1F92939B1D50A1
          3DBAA9C86F06658308163214F981B46C360B72B95CF7F9332DC50F966E1573C5
          7F8A53A1958969DB5EF6C38FD4987610812A9E4422F0BF400C283E05B12184A8
          11D5751D1B0894A66B97BF7E68B1D8C9459C6BE32033ACECD852708BE4B52C3B
          2C1F89DEDEEAFAD58694794FDF90439280E770CE8464197B580453B981F4C9FB
          5579948D1094447890203DC2C913E521A26A3D7ADFA1EFDC4A1911E066690D9A
          97056E389F2607CEFBB50A82784BDDE06E40D0851EED7BAC92545BD6C3BA8DC8
          9B826E9CE5BF00D275DF4500A5D90000000049454E44AE426082}
        Name = 'PngImage24'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000004C84944415478DA
          9D55DB8B1B65149F6FEEB77C339949369949B29B8556ABC556586F2FDA550A82
          4F05C507E95B45D087D2224528A5D0BEA808AD17BC3D880F4AC107FF015B7C2F
          22BB936CBB762FB96E93ED6E2EB3C9269BEB7C9E499AEE5244C44398395F72CE
          EF3BDFF97EE717E4D6EB1BE512A1298A223421D4C410A2288F1D39E0C1674888
          E7BB10E7119A865888A710A18608852311B498729047345D436414058F099C87
          C6EFF1121DF469CFFF7548FB40EDE66EAFD7434E6A61667A56D334EAFF5A7BB7
          BDB2BE8252A9854462B6DA6C9DBF7C45354C96653996E3788E651881F3FCA56F
          2C62281A7647C8F3BC21D8C0EB747B8D6AFDE2D9736640CDACAF03506A3A11BF
          5F71DF3873D6B2C23CCF09022F4A8220F212C708022BCBE0F2344FB30C0BA706
          8CCEA03F68F777DB9DAD72F9FAA5CB96115C5B1B012512B1CD7AF39DF3172D3B
          22F2A2207192244892284B80C207144996A1445E647968516FD06F753B9D76B7
          B9DB7E502A7FF4EEFB218CD73319004A271276B9D63873F1AA150B43BA0CB548
          BCA2CA5813B02A6B58C1AA240A80C541C37BC37EB3BDD76DF46A3BEE467EE3BD
          B74E9B589F00C5ED52CDFDE0CAA7763CAC28B2220B8AC407B06A1A8AA9EB6650
          0F620DEA12380EEEACDDEDECB49AED9DC656AD92CF14DF3E794A5370269B458E
          9302A072CD3DF7C9B5D8F45420200714515184205643269E32C311732AA4192A
          2773144B28D2A3BC5677AFB2532C6F3FC8650BAFCFBDAA8A389BCF01503A6145
          371B3B17AE5F8BC7E22A16B022E95834742D6C06239170CC881BBCCAF82C63C6
          541B12AA3EAC6E540A6BF7565F7AE2452C6A63A0D474CCDEA8D52E7DFB55C2B2
          F580185025D3500D1D87C2A144C4B6704CF0588208A0209F801E6075A9BDFB8D
          DCCAF2CAB1993955D0F2852C4A394ECCB24B6EFDE31FBF4BD896A20A3A968341
          D53074CB08DB5391B010A53D669FDB237EB748A35CCBDEBEFDC70B474F84B4A9
          42218F5269C78ED85BAEFBC54FDFCF4CC73513ABAAA8EBB2AEE19011B4CDB086
          228862C6930183556FD597EFDD75EE2EACAEFFB5F8A7F3D9D5CF0F279FCCF947
          4B2FC6AD78B6503875FACDB86D1D9F3B76E8503214D20D53DB766B1C45D99119
          515665511045C16D35EEADAF2C2C2E16D70A95ED7A295FBAF1C3CF470E3F9DCB
          E7FD66C7E3D6D29DA513AFCC332A0C061F08A85893E1FA084303C5A356383C65
          6A1A06C6773AFD6AC5AD6C5777DD56B7DB2FE68ABFDEF8E5A9234773B93C4AA7
          D396652D2D2FCDBF3C8F5491A6389AF6AF994608468CA6299EA1819FB0034807
          0C1AF1BC3E8C08032A42AAA5CAEF376F1D7FE6D95C2EE737DBB26DE74EFAE4FC
          6B9400B2C45230570C24321E210CA2588468E2238C7A0DEF81E70D0887E03168
          F57EBB75F3F9B9E77C2027E5D851ABB051FCF29BAF255544FEE5422E820A8614
          4C3C68997FEFE0105FA7FC92607289AF55A8B25DB970FEC3E46CB2582C42B353
          713B06679015958C740B948F421E221E20F86BFAA1D2A1873CF2717D50D88CA6
          5B8D5D7032B90C34DBD9DBDBC3188F88820E9065E2FA3551A3FCFDEF265BFAD6
          6AB5A00F687373737575756B6BAB5AAD369B4D68064293E80312FE98418C2008
          B07D341A354D33994C22486EB7DBAEEB82D3E97400689FBFFF0A04BAA9280A68
          34C089A28820F951918F6AF92F4007E3C1D9077A0C65F247F4CF36DE63CCACF1
          F26F38E44E8B06EF668D0000000049454E44AE426082}
        Name = 'PngImage25'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000005364944415478DA
          9D545B8C136514FEE77E9FE9B4B3D3CBB47B73B924EC8268F002E2BEE183D184
          17252A9198080430210602241031518321E883A289890479F082E88B44166350
          B924248A2C24CB6E77BBBBD36DB7BBEDB26D774B3BD376DAF1B4BB6C88BE10CF
          3F99F96732F3CD77BE73CE87E5F3F964324910047AB8C0306C69EFBAEEC246D3
          34ACBFBF1FEE65597E48A07F057C5B2A951CC7C16EDDBAD5D9D9298AE2FF0382
          B02C6B6868A801D4DADA5A2859FB8E7DACAA1E0A27090A912445920449E10481
          D3704311388EC16A32A8D76A75C7712B956A2E9F3BB07D87CC332323B106505B
          5B5B2A33BB69DB2E7F50E72986E4088E81A0199664188A65E1A02902833F008C
          E354AAD55AB9ECD856796A3AF5F9D1F774558E8D8C2E308AA4B3852D7B0F0542
          BA40731487F32CCB7234CFD11CCFF2222570808453040DDA569D6AD9AE5856A5
          582C4E4D4E1DDEF99626CBB15813281289A47373DB0EBD1B042096673882E758
          416064919525419279516081234D5208E1E56AD9B2EC62D19A2FCC25E2C9DD2F
          6FF38A4A6C6C14BB7DFB76381C4EE7B26FBE73CC307451808F089EE71489F7AA
          A25795BC8AAAC8A22434520446A58A5D2C14E70B85ECECECB89978F5B9CD8AA0
          8C8E351901D04C2EBFEB836361C3501491150889E75599D77C1EDDE7D57C9AEE
          D1649A23310280CAAE336F17EEE666D299E9F1F1F8F34F3E27F3D29839B60064
          647285B73FFA30126C151546905855E43D8AA86B9E408B1ED2423E56A111855C
          E462704215E4E4CAD9C4DDB8393CBA7EE5068953C6CD66D580C87476EEE0C913
          11230CBA0822E3F3C89A57F6B7F802FE40AB64B01803188D2EC6E1D200B3F192
          393716BD33F878FB3A50723C6E36340A854299D9FCD12F3F8984FC200DA8EBF5
          889AD7A3B76821BF3F488730975CEC638081B1683454356199FD37FBD7B43E26
          F3AA39D1040A0603D9DCFCF16FBF68338232944DE46410C8AB0474DDDFE2F7A1
          004CD8521FDB6E29353D113387C713F12B57AE1DD87EB02DDC310AA9358182E9
          747AE791FDED6DC1D53DDD915050D2285991892AA269A645354802DA9B84F297
          CAF6A039F4E75FD70707EE24E3297374E2ECA9B35DED5D66BC29B6611843B181
          679EEA65444EF107BB2201DD68F1E9ECFC6C99E0B15024E8D354197266A57B45
          6B22994C98C96C266715ED89F8E47767BE59D1B93C91482C020D0E0E6CDCD82B
          AF20A916D72E11C5114C70395A66708E90394155258E67701C776BB56AB962D9
          1518B4AA534B4DA6FACEF7F5ACEC8EC7E38BA90D0E46371FDEB8655F9B1A2EE7
          F3CC8D9FEEFDFD3D728B351CE1148211AB63581DC1811CD7ADD5614B12751C59
          33F397FEF86DEDEA474D73BC59B5807135D6F7E3ECEEB5ABF015F4D6EB99D369
          8BBE7A0A152EEB0CF81D56010B701B26E680D84E0DABD76B2E9CDC7A2699BED8
          77B1A7BB27918837526B37BADEBFFC0AD3FE8B875AB663D9EF276EBE18CDDEC8
          C484C3EBCE89B4524315BCD18D18940EE8C0A5EED6107024905D7642FEA0244A
          93A944C321BB5A57EEF9F96975F9F08155C32CC24B8EBDE7426F626AF287D7A2
          616F672313B468A95873B9F53A067A357D165C0D046B68148D46E3B1E4998923
          E8917E37D9F1D9D6ABBBBEDE94B0079C39F7F5D04905E71B2D78DF9B1F346CD0
          9E86EE601878D8D1D181E572B9ECDDFCA58173A767F62B1E7A83F0D285D4D962
          B5B2C6EAED15DF7050B98E1C0C91FFB56A8EE3545585A9805A793C1E0CFC096A
          896CFBD3FEA3BF8E7E355BB0180EEB569EDDFBC4719D532A388B4091FB9DBDC0
          0850B066501445DF0F0C920492F00A4590D746CEDF998E064475FDF2173456B7
          F01A8121A2B638B00FD259425C8A7F000FDA811DA37BE9670000000049454E44
          AE426082}
        Name = 'PngImage26'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000005674944415478DA
          9D955B6C145518C7CF99FBCE7DF6D6BD75BBB40D140817ADA21851A2C4F441E5
          81844B080F2620314204230F2ADE408D06482126C6A8892F1288C6E8033EA844
          5FD0806E3BBB545B4AD9ED8DB2DB766FDDEE6CB73B37CF4C41028F7EE7CCCC99
          C939BF7CE7FBBEF31F58989DCDE7730042002C1BDAC07686B60D301B07008DD1
          7780BE23BBFBEA8E979E18869BA6150A8560BABF0F6298202B986D3B0867827B
          61EEECA51BC4DCB5CE0DA2E6F4DB8601589DAF361A0D9852FBDBDB3B055100FF
          D7B4BA766DE81A4CA7526D89F662B572F0ED0F44C547120449A28ECCC2D11835
          82A02880E310BA1B434E1986651A4673B1592C97DE3D7048E1F9EB2323504DF5
          2D6BEBBC5598EED97738DC12A42992A14986A1180F459104CD100C437B589A24
          7012C32DDB6E1A868E280DBDA13572F9DC9937DE0C797D0E2895EA4BC43B72A5
          C2AED7DE89845A10C283280CCD728C8721598EE4399AF5B01EE42746400C2E1A
          CD7AA3BEB0B0A8D51AB7A6A65FDFFBA25F92471C50BA2F1E6B9F2E175F38FA21
          02B11C0221A7689EF788222B898C24B09CC0B0884D90286D4D5DAFD71B356DBE
          5AD1C626722F6DDBAD08622693415B4BB6B5764C970BFB8F9F8C85031CEF6159
          1AB16499F3CA22EA3EAFA448A2C8F11449A2BC2D2C366B35AD522D164BA5ECE8
          D48EA7B7CAFC5D507BBE543AF0D1C9786B0879C1710CC7D25E85F5293EBF5709
          07FD2D42882559DCCD7D13989AAECD966FE567F2D9B1899EEE2D8287CF8E6651
          FA93F1783C57AE1DE93D118D8465911578461259AFCCFBFC8148A0A5D51F9449
          0903C452152133815DD40BB9E2D4C8B5E18D2B1EE33DC2E8E8A80B6A4BE40A95
          A39F9E89865B249113055A51249F220682DED660242C44290B779C4165E964DF
          86006B006DAA32313C3CB8AE6D03C7B8A0745A8D44A38552E5FDAF3E8B44421C
          474B32DA94E497C560408EF9637E3A845BF8EDE273AB1AE1EAE65CBE7CF38F2B
          9736AE7ACAAF041D90AAAAD158AC542E9DFAFA8B445BABAC08AC40C922EF1705
          6F40097B230AF402402E716C6056EAE5ABD70706FF5151809349F5D4B14F3A13
          9D6E8C52E9682C32313EFEFC9EEDF14870DDFAB59DCB13C18057F68933A5328E
          1368776E5171144D690BD5E1E12175E0EAF848A63C5BBD39913FF7E5F915CB57
          B859535514ECA1BF071F7F72131048C2A23D122379251FCFD838E661F1965038
          D0E21365912428BD69CCCECC168B73F3957954DC53E393DF9EFD6E65D74A37D8
          E9642C9A480F0D6EDDF4C4B332B54A60E6EAFA85869525288CE048CC26481CD5
          22436118C42CD344BB6B184D0871CBB20BF9995F7FFE6DDD9AB56E8CD2C968A4
          2D3390FEA667CBB60703B2482FE88B43A3E6997943D5490AD8386E23A1829689
          440940B4DC424716C371DDB20DAD71F1E2C5EEEE6E07D4A7F6259675A8BD1F5B
          E74F3CB06FEFAC9AA457AF5F18CEFEF04B7272E71ECEA60C6842486010A2338F
          630868A198231CC2164B85575F39DCD1DE313636864057BB56775D786E7364F2
          72E0D0E9C4B6ED90E67EDFDD3372E5CF1D97336C6B0C98065A8439B286CEAC23
          77263410D775106AB53ACA66369B85FD6AD2A23C03FB77771453E4333B1F3D7D
          AE3A31F6D78E474632C587CEFF24445B4D5B47650DC11D5D748AD25E92636496
          65D56A3547AA266E8E8F4F4E673EEF157E3CB7E1ECF7F33772BE355DD9DEA357
          FAAF370F1E210DD2B45D7F80759F305214A5288ACFE70B0683B1580C562A154D
          5B9C9B1CBEB477175D2A8A58C304A05027E36F1D931EDE6CEA4D0B18368643FB
          7E8545CAC9719C24493CCFA301AC57EB0666A199735393E9E3EFCDDD186204B9
          EBE503F12D3D868E045637A18901DC396177CC767E13B75FFFFBAFC07AADDEC4
          0DCAA02052560A94E78B5ED2AF934DBB693AD946E947CD79DEE3D2BDFF2567F0
          2F0EFA98EFEA318C6A0000000049454E44AE426082}
        Name = 'PngImage27'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000004414944415478DA
          95544B4F1B5714BEF7CE0CE0010F06EA17C63636EF67116A445415A96451F103
          A24851D5A84AD52ACDAE7F205217DD765355FD01ADD4EE22A1AAEA0A252B8C79
          96464095A6E665103618DBF8813D8FDB6F3C530BBBAB5C4B773C9A73BEF39DEF
          3C68B55A3D3B3B3B3D3D75381CE4EDCFCDCD4D5F5F9FC7E3A1BAAEAFACAC88A2
          88775555DF0A8531767D7D8D7B6868881A86B1BABAEAC4519CBA6E104A6B36B8
          79ED26FFFDB9FD6A3D3920744D2B97CBA3A3A326A3783CEE549477DCBED25F3B
          7AE6449344CAA940B84A89C0E1CDF96D1A54100C43E35CF2869CE1C1FC75A154
          2A8D8D8DD9409D2E97CFE7295D6578B50C4E94333833CA0DCE29170931244962
          4C00251DDF10C7207A8B83C972EE2A8BEC2626264C20A4D6D3D3130C04AB5C6D
          65B2444455242AB234B42A3104A32A3171776F776F6F0F7004D884A9BA1E0907
          E6E6DE4B26CFF3F9DCE4E4A40DE476BB23D128D3D8717177E7FC3747F6ECFD16
          C5503E9402F39C6A94F144E2E0CDDF6F44001130A2554DEDF5F7CECCCC1C1D1D
          5D5D5D998C344D436AA8DFC0C0C03F177F3E7FF5244B760279F1537757296390
          B667CABDC72225F1D5F8FAFA3A18716846B856A98C8F4F2EDC5B383E3EBEBCBC
          341901088CFCFEDE48A4FFDBDF3F4E905FCA15E7B0CABE0A39CB7AA1B0D1E95A
          F8559E18D774DD129D52CA6B8709E6EFE4E4E4E2E2C26604A06028ACB4B47CF9
          DD9CEA3BCD54C91DAA7C3DDD7E532C145F65DA867EE8BEFF0514CD66B3B47600
          87A6696F6FEFEEEE06502A959A9E9EB653F387420151DA7F34CF5BCF8A4556BE
          71443F125D53E56CFC527EF77BCFC3A7E08F2CD0B7BCC60B40A80F7A38914820
          C0D4D4940DE4F5FBA3FDFDE9CF3FC9BDF8491748FA8215982B7C9FC89CB91F3F
          97EF7C0045111C40800029DC5D5D5D8140607B7B1B0850DD4ECDE7F345A3D1EB
          D7AF379F3C4AC762AD25922644F37A17BF7916FAEC29288011E65110048B116E
          4551909D55F166205814CED3DB3FFF985AFF43F2F48C3D7810BD7B97D6460340
          6004204B6F340DEE42A1B0BFBF0FA56767671B80D0C806C370D8E364F6B1199F
          0B94C12793C908E67818182EE8924EA7912F4AB6B8B808DF2646F5C96C3EC805
          BB013B2797CB1D1C1C40F84AA502C9D041232323F8DA00844222B2596146EBFE
          221382A1D08B972F53E7E71005A4DADADAB02C60E5F7FB513B04305DF0585B5B
          B33AFBF0F0109CEB8ADA40A288984B4B4BC3C3C383838320051748062C140E3C
          2CD56C46E6AC452200CAE7F394D2DB190108649797977183389606A481BDCBE5
          825EF66AB1186D6C6CB8CC35E24B2693C562F1FF40C16030168B21918E8E0EE4
          8E3E44ED81624A5333368140154D050B60617923A0559A3A1C5EBD5EEFE6E6A6
          2CCB5004C4618CF2372C3B0B686B6B0B2A62B23150D6DAB650AC80D8A79003DD
          1F0E87315350DA42B1A6B701C8628453A75ACF0BAFF084018A807E41304BDDA6
          636B044698BDCECE4EDEB89DEB586899F9F979A4D694D16D9B7F012C45AF1E79
          EB08C80000000049454E44AE426082}
        Name = 'PngImage28'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D6500446F203134204E6F76
          20323030322032333A35393A3234202B30313030B95D9F780000000774494D45
          07D30218173928954B7884000000097048597300000B1200000B1201D2DD7EFC
          000003E44944415478DADD954F681C551CC7BF33FB6736BB66B39B6936A9D648
          024D693D685B1A0D160A42A5077B1034A6694A3C584ACF45915E04415462ABA5
          54B0E84DF0A42729450FA2D2A04DC0BA870D24B669134936DDD9CCEE747767E6
          CD7BB3FEDE4C929A6D452A88E2C0DB7DBC79EFF7F9FDF9FEDE28F8871FE5FF0F
          689E807A65170E7017A35A0A87EC3AAE338E2955C5544AC5D5675EC7CDBF05F8
          7602BBE9ED682A85915CD78E6D9DFA003422001CF57A093333BFA054AA4069E2
          3607A68587ABAA822966627AF463DCBE07D0A4F9F767D0472B47E21A46735D7D
          3B7B7A762BC9F68701E1C2F75D94CB8B585828E0D6AD158200E97402BD8F7643
          EF4AC0B22AB863D569DD15A6E9E587DFC39E4D801F2FE0BB6C6EC7FE6CFB5635
          9BD98688AA4151A370DD2A9696F228160BA85601CF03B66CD1D1DBFB184514A1
          F736AD3968FADCAFDBAB4E69A5A61A659F11A06313E0DA275ABDBFFF60528977
          20124DC3E30DCCE4BFC6AAB18CB636404B00BADE8F5CAE8FA2E160CC86A0C208
          0851B78ACCAC18AAEB421302A898B05E6A05FC4C808181E7939CDBC1E28DF96F
          A01228A6E5D0A9EF443AA9C169AC84DE36057CFAB9535D6256ED37C5F791E03C
          8C4E02CAC67D00D73E8DD7763D3E9C12DC81A2A8989BBB44F9AC051BFAFA87E0
          2B0944E31944A36D3096A7B859991354384DA10D7230160E5F02CAB05E7CB705
          307D51ABEEDD3B9EF658833CF469D32C0CA3805AAD81EDDB0FC0714C70AF0E4E
          72595D5D4024B2A612B24011602302FA2F5104F7D420003C7532DD645690DF20
          0DBE47862D0ADBA1C30DC8F471EE11FC3AA80F02E3CD660890DECBF4048012AC
          97275A003F7DA45507878EA705232FB93468D341B6366FD06137980B2101BF06
          00695C0EE9FD1F8741293AD20A983C1F359E1E7A45972992C684606438D4BF84
          71CE824824D4306E6C3464E0B5B86B5CCE4D028C9C69015C391735F60D0EEB61
          7A78E0A9341A02C873322C652901C5E2CD8DDCCB08D621410D68CD24998E9D6D
          01FC70364E80C33AF3C23448ADCB1AC8488447D110C80F22F3B0B878B7C812B2
          0E900AF26850435AC73E68015C7E07C5279FD8DF9D4A3E141432302C58300F23
          590733CCCF2F6F06F8A1716A3479855469FEF6F8794C6C027CF526F69112C6DB
          5218EEEE7EA42B97EB412CA652475371BDB502130C8A87D9D912F5C35A0DFC50
          397603CC7171D1F6F1D6C90B28FDE96DFAC621C406F7E0392630964D470ED3BD
          93CAEA49690A1E7329E70C854205310208CABF4B8D4D19FCD2014EBFFA21661F
          E87BF0D909B42389174892473B32D1673BB3F16826D3443E6F0732651E26490F
          AF8D9DC3E4037F0F5A9FCF4F612BA9642416C351524EBB5071FAD8FBF8E2AFCE
          FDFB9FCCFF3CE077D68A6A3794B7E9E20000000049454E44AE426082}
        Name = 'PngImage29'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F80000002B744558744372656174696F6E2054696D65004D6F20313520417567
          20323030352031313A33313A3134202B30313030D9FE197A0000000774494D45
          07D3081915030074DFA5AD000000097048597300000AF000000AF00142AC3498
          000004A74944415478DAB5947B50547514C7BF7797050679ED2EA4201261F498
          CA6AA6C6A6B1191C27FD43B3C84667D4A6123445345E21ECCA4BE5CD6252180F
          7909148AE14C8E34EA0C3B8C89B8B0B45949642D83C46B90E782FBBCFBEB7797
          6D85E96EF28FBF9933BFDF3D77EEF9FCCEF79C73193CE6C52C7CF824A98A0407
          486161ADB6378C95C0CA90F99D101062A5469F850C4647C687F4469788C6927D
          AA25036485174956C27B4BBAD965E56D54365C9DF1F1956CA951445E5F122025
          AF9964274500DC6D17F8B93375D98CE60621CDA0437D170D37FB31D3DFAF7331
          928DB55FEEED782420B9E022C949FC6F069C2CDCB29279130A18B477FD81B6DE
          3178843D07D5B74D3A1121EFD41547B7FDBF4405CD242B3182375562CF8A0308
          28A0ADE30E0627F4087DED15A80766A16A6C9AC59C7953FDD7D1EDCE33A012E5
          24F103EC14B076C085964E286FDC868FD81B33462B661E98A01BFA7BD6CDCD63
          EBF9B258A513C07714F0FE2301B48F60329B6130596032B130188C989E99436F
          DF089A2FFD3871AE3441CA0B38927B81E41ED9663BABBAB4B6979C245CD75AE8
          C1CCED2C35C2ED84EE0C58FA2C1009B1695D3085D2181915A82CD8CFF0029272
          CE91BCE4EDB6F34F9AFE4585E50272203377B6DACD0E63A864EBD7AEB25D2039
          AD0C9585D1FC80CFB31B497ECA8EF9616298451DF46F8BDA76421C60ABBDF89C
          99AD0C059453C0017E406256232990ED80957E796F70723EB023E8BCB9BA0AE1
          4A25E13E150A0598339831356B4168B00F4C2C05A497A25A71901F9070A28114
          CA77DAE4B8D9A975003869B8E04FF87962E52F5781DF94304DCCC165B007F75F
          DC0C76671C0283FD60A219C8D24A51A5702251FCF17AA238BA0B262AB04ADDB7
          A0C8049E9EEE58DD7B0DE23FF331AA99C4A45607316B841F58F46F388CE55945
          D099E8DF20A314358A187E405C661D51A4ED869102BAD55A4791B942860449B0
          B2600B74635A8C8D1AD0714F0F5FDAA6EBFC09C6CD5204B568A093AC404A6A19
          AA8B9C48149B51470AD32980B683BAFB619B721DC301561DDB8CA93B1AA8E708
          8CD31610038B00B10B025D1990ED3278C6A7215E7E1AB5270F3901A45793FC8C
          8F61A4C3D3D5D5B7A806CBFDBDF0546D3A96B556605C4FF0F338818B057835DC
          1F3DADE3082DAA06B6ED4692BC0435270FF3030EA55593824C0A30B2B8D5F910
          C075919BAB08610F0660DC130EFF652C843EAE30FABA43DBA387E9D970ACF9FE
          0AA628589EFE156ABFF88C1F10937A86E46746C240011DB7FA1C7E3A4FF0177B
          E0998E6FE0A53C8DBF7AA630FDE41B30775F87C8C38AB0405FB897B76262C56A
          C8524B70F6542C3FE0E0D10A92971945011674760F3832E0D60B016E08FA742D
          042166DA4546E8EB3590D665C26BE80A3061C258E07A08148D884D2E467D719C
          1380BC82E41E8BB26500477806223AD5E4523D7C8BF600CF3318D148E1A31A86
          E08726B8657F48E92C866F08E07EF92E522A5A5096EB640E0EC8CA893C398AD6
          C0BCD00D6F773AB1F248E0DA599B5C56EFA7E1A7FC1D82C931604310EE4B58CC
          0D52FFFE136895AE41FCBEADFC800FF6E61289444CFF90EC22C0BB1B5F8797FC
          2378BFF536CC8121109C3F83A1E355B6017CA92806C36F6E8688FA47DADBF1EB
          CBE1488BDFC50F781CEB1F9FB366375A3802D80000000049454E44AE426082}
        Name = 'PngImage30'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000180000001808020000006F15AA
          AF000000097048597300000B1300000B1301009A9C18000005BF4944415478DA
          5555796C1455187FD7CC5EDDEDB654E805E5A684423805415391D2180E8DA122
          29420C1A0812398A122108B180C142D180606C3882163420A08208C423014B42
          5B4BA1959B022DDAD2D2B2BD7667E65D7E03E10FE78FC9CEEC7BDFFBBEDF3558
          4A899E5E1A214208FC706CABE3CAA548ED45D9D62AA336618CC4F9BDE91949A3
          9EF3A7A5638C9452E8FF177E5C08BB453426143BDD9186E3C722E7FE60BADDEB
          379041B48190C448206939B198C35207A7BC32A7D7E8F170AA548AC05EADE186
          9554F042528209EEBC515B57B2CDB09A834961D9DE2C9BEF6B3B861C4B618699
          21E313CC677A3B8A753C72C2A39F1FFA4E813699965C63689160AE2494648436
          9E3F5B5FB2A5474F861EDEB4EFD7236E69C4B0DB35AC205A3E39911871213A68
          4834CACCE4CCE11F1531BF4F4301E8480881298DFC7DF9FAE6953DC392D75DE2
          510B334691062014C0A131F4CE61B1D01A6A494773427BF7E7BE247FFF315985
          C51820D1DA1D8DC7DA6BD617841ED5580D3790421E8D6CAA5CD0B4968084260A
          8A29ADE05169EE02C1B46D93845499909AF1C6927EB3E70158709AAE3BB2BFE3
          40B119BB2784A488C256A8D3DAD51D304D6C7824ECD60E91465B5737350D4609
          87170A0BAE8CF810EA3D6642F13E333919DBB1CE4BCBE6C4359CD7968D290238
          30962D6DBC75DC6C56579DD67E5D7BFC448AA6CE5874E25C75B53AA5E58AF6F8
          84521C516ADBD16078D8D24D03DF5C881B2BCAEEAECCF3A96662841095306D7B
          97EA9CB13C67EDC6BA8A8ACA65B306580D4D5164BEFEFED40D5BEE545497AF9C
          9D14B907E83B8AD85C59319E9C3D337BDF517C75EFCED6ADEF7912BCD02D2630
          A813A5E1917BCEC50FCA04C2AE55565E589C97923BEBA50D5B197139FC73F9BC
          B613A5C2E397DC8929C41D1D4C4E7BF5A7725C5BB8AAE370110B0635E0A80057
          EC289BA50D1CB1ED5060C070D8DA78F74E426A9AD734A14AD5E6823B259F5B8C
          694DB1564221C1A5CFE79F7AF0577C71D5C2D8E912C3EF778022C5E06F476115
          8D197D078CDC71CCDF3F8B3ED6127056B37975EDAE4FB1D7000B489741300A90
          0EFCA0DC033FE3CAD58BEC135F81AE38685D12975D58A1F9C34639B6E4F0A019
          79F008FEE3DCFE2E7782BE564D820608F4B11EE002194AC3A0D34A4FE2DAE2F5
          4DBB3FF685E2B8063BB9AC212E9BDAEDC4F9EB26AF5943BD1EF6D4CF75E72F9C
          5CF45AA8B51179021C09F75C773411171F9E7EEC375C7FE49BABEB16F87C06D7
          1C6B2C356EE9A03DF297E41416410EC0B157B617254FC94ECA9A00E5EE9597FF
          B0203F10B9039E025F6929409DC9FD32679E29C3917BB7FECACFC5DDF7C17B1C
          31D119F5E4E6E7EC2C7D120E55854B6B76EC080E1E3265CFF7F19959F0E65659
          D9A9B9537C423A9038801C17A3E6BF3DB66837B4A0AA3E58DC766AB7A42674C4
          1D6EA6F619B7B53471D4840B1B0BAE7DF919F123D185FC7D074E2D3D9ED87FC8
          B982B76ABF3D68302C3097CC4CA081EC7DA5C92F4C73316BAD2AAF58311B75B6
          2ADB5698F2A86DA60F4A1C35BAEEC743887A04013B10CB8AF5183A2C949179FD
          C411D3C7006C0A1CF8FC835FCC99B4EB20850C72843028BDBC7D53FDDE62F099
          DDD50DB52C69634B290F63925940BFAB18A662B6A3B5E9F3282DC1F0DE603814
          0866EF3F9630244BC07A2E6C8299E24EE5AA771F94FDA209B2DB5B635262656A
          E4268D2B19204D12AC89408280A5E342DE80DF1072D2275FA44F9F2504074EDD
          8EA824C4C090D3B59BD6349C39AC98E944BB78679705DC6A0811D00B71F3D4A0
          2037BF2F0822898B8B7F76ED965E53A7430AB90B005DC12115202C3565205F7A
          FBE8FEDB5FEFEEFEF72EF782CA0DC585A3380C829887206258DD8AD0D4F11347
          AEF8307EE008309586FCC4107F085B5008098F3204D104862434D6DC527FFAE8
          83B3BFB7DDBCC965544ADB5094520F8B0F248D1ED7E7E5BC94499321A5251788
          48703A566E8461B77DF72B221476DD8D2118DD9C75BF0AD1967FA24DCD22D20E
          FA36C2E1607A060D04DDA552C238CA5591A29AB9DF11A4FF03C69457FF36EF9A
          C10000000049454E44AE426082}
        Name = 'PngImage31'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F8000000017352474200AECE1CE900000006624B474400FF00FF00FFA0BDA793
          000000097048597300000B1200000B1201D2DD7EFC0000000774494D4507DB03
          0A001224D8C748FA000005A44944415478DAB5957B4C537714C7CF6DE913FAA2
          4061A3883C8B1005448D828A583143A2C34582B809736608D943B798C53FDCD0
          CC25EA1245275BE29638C374431286CC3929B2569928117CC090378CA750DADE
          BEA0BDB7F7DEFDEE355B96B94716D9AF39E9EDEDB9E773CEF79CDFFD61F03F2F
          EC5903441697C3F0B972F0CF3990E7B6589600815B9562FA3CDE5283CF0B805D
          D1AF9DAE3CFACEABA55A8D3FD3374563473FBF00E3772E276112E5CFF302D879
          C6C8E857A532360F8DF179180C5ABCCCB98A23DF59AF556C7E66807445BE56BF
          E3ED91114A0D188A2617F321542E828673C7866C0D9F443D05282B2B83CACA4A
          EEBAB0B8B880F631B163E363DD14E5EB6CB9617AF4677F454641A2366B77A7C0
          5F012C81FD008F07837527ACF8CDF3EAA7003B5E29D6858787EFD52E5C58F2BC
          560B02A1081C0E075867CCE0C0EDE0763B1C023FBFAE5B26D3FE0643437370FA
          F6D4C0D5856D02A9021886E162300C0D23F515A3AEB66F233840726C147FC34B
          F9A509BA847DEA104D54507008B85C2E8624498CF05140FA7CE0F57A40AD54C2
          407F3F74767640EBED96BD5B3ECAAD38B4B11CC4E9BB0D7C8546AF7D2E84B1D3
          428C997380ADEDF2556FEF4F3958C5A953879353520EC6C7EBC0E5763393D366
          8CF2D140F8484000205843009A24E0FAF526989E9E8691E16187541611C90B0C
          DA929CBA242F20401E8651734E31E9CCBAF475D5D0985BF025DE73EB90307229
          60B575758C7EFD06C63D378B1104010E971B70568AB9392E731F328220814665
          73FAD214389D76786CB641585C0A3819116376D3D8B88B069BDB0B3E9450EFC0
          2F601DEF7FCF527FF41856FAC69B8FD2D2D2E2552A152693C94021978342A502
          79800CCC562B926A163C5E2F8291E86154094572508A350AFDF61100C830DA07
          B80760DC4981D9EB077E13F7A69CB8C580AD58B63C745566E6A0582C95B0CD61
          03F1F97E80F1F81016160A7216AA50824229079552857AE1E59A4E125E04A380
          46817D24FA46308A64E124F8F179303E3AC63C7CD081714DFEF4EC175DE91919
          09047AC86CB6C0E8D828B8501003D25C8E2A0A4010763E580983D56A08D30423
          A80254C8D88A2512314C4D4D81676E16640101505F7719EC763B4CD96C6739C0
          F113274D99EBD6AD619D290A5581B2B1A33EB4B7B7A38C50C96844711B0E3366
          335068146767DDE0271072598B0402F0178B202A7201C864FE5053530B1EC203
          BB8AB643EBDDAE831CE0F08747AAF5D9D9DB42351A98B158C18B32654BEDEA7A
          04F1F171E074B8384810CA7E1665D9D3DDC3C9B3303A069A8C26E8EBE982C549
          89D0DF3FC06EB2EE445D42F4CA9418C13563FB13C0FE03072A376DCA2D158B25
          6823B9B989A150E6DD3DBD10121C044291886BE88C7906844221920B5581FC3C
          1E2FEA170FF93310A61440FD0F37E05275CD9EF4956999BB8BB7173436DF7F97
          039494961DCAC9CD7DFF49200A189A010A8DE3C8C828C4C6C4A0B1C5C16AB571
          8D26BC044C4C8C738D677D272727C01FE9AE5BA086C1111B73ECE3E337972F89
          1B7A316F4B91C1D8BA8703E417149465E9379CC1308CE1F17898582201A9440A
          2DB7EF7093A441D2B17ADBED0E46241271FB05C76D287B3E07A16980D8703954
          D75EC36B6BEB4BB76DCD4E5DBB3A7DFFF59B6DA5BFBF8B7272379F5405AAF202
          D5EA0835D25A2A95320343C3F0E0DE7DACBFB7BB2127E7851E6D44C46234C2AB
          D04409946C0534C558662C205728B0F02011187E6C6DA8AAAADA9891B1FC035D
          747479DFF0740907C8CCCC04A3D1C881849A60FFA4F0055B434243374D3E9E5A
          3CDCD7FB96DD6137A1BFC8DF9259B73E2B0CC9B2363030788D5C2E5B8B5AB068
          6992966932DD6DACFAEA62F61F5F9E7F791EE8F57A686C6CFCC7732023A3109A
          9B2F3CB95E96B8AD68575175D38DB6AB172F7EB313DDA290B14726332F275A5A
          B2AEE4E5C2FCCF0CA6BB3D57AE7CFF3ABA759BDD977F5BC17F5D8BE2629472A5
          6C9FDBE333743CEC68FE5789E673FD0AF41CC0F95838AA600000000049454E44
          AE426082}
        Name = 'PngImage32'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F8000000017352474200AECE1CE9000000097048597300000EC400000EC40195
          2B0E1B00000006624B4744000000000000F943BB7F0000000976704167000001
          000000010000B267DC8A00000025744558746372656174652D64617465003230
          30392D30392D32385431313A32373A35362D30343A3030DD14AB140000002574
          4558746D6F646966792D6461746500323030392D30352D31395430393A35383A
          31302D30343A3030673840870000001974455874536F6674776172650041646F
          626520496D616765526561647971C9653C000003D64944415478DAED957D4C95
          6518C67FEFF93E807C1DBEE48425360721044B3B1E18A66E48A628E5A864CBD2
          FC6E68D2F803286AD35522A648056942C5D448D2614A45626A215A84520A910B
          C8830D11E2081CCE01CE478FB9B50AA66CD65A5BCFF6FCF3EE799FDF7DDDD775
          BFAFE4128B7F7049FF036CF6212EB4FCC0385F6F26FBDDF1F70296AE789AA36F
          977166C90EFAAB9B281BFE8EA843992C343C70FB80868606A2A3A39999B488B8
          3933F0E8E863ED710BC76AB6602A2E246DE9F2DB03C4262473F964056F3CE2C3
          81463301F332181F672426B782AF4EBEC3DC2BED4404E8C70E28DD7790AACA4A
          9C3D4D0CF65DE449C37892C23DA0F71AB829A9FFD6C40BF5814C59B286E96B77
          61CA7C98759B5EBC35C0EE70A254C8792BDBC0CAF50930380CE601B8DA032A35
          28E5381B2F407F1F5FD49BD8DE3783FEF24F58B6A798C5A9A937070CDBEDA894
          4A4EED4EC66810093973162C4338640AE4FE9EA0D6804C125001345FC3FA7327
          C11B5BC9DAFC1A19E91B6EED8124497C909B484A5C90B8FC1C5915ED982D76E4
          E2B956AB22D85389BB4A625028E9B0BAA8AC69A1FEEA9FAFFB1DD0DADA425464
          1485FBCAD8FD7A012BD39E654DD25C3E2E4AC2A8E826EBBDEFC99EE6864A2E21
          A99538AD3606E53286902134082112DD6DEDD42D3ECC630B1E1C09B85E6DC167
          2770FDD2C5473BDF24E69B6A0274905EF404D2F946B6D5F5B0E1D14930E40477
          77F8F127F0F1863803381CC20F055D35357CAEC92625F92F80E6E666C2C2C238
          21585F6ECEA3EEFD4272F41D340DC830F9F8D33B38C4A66762C47105C8C5F610
          E9319B71D6D661D58C43B2D9902CBD2C6F8B67CF8183235B5479E408F3E6CF27
          5F00824A4B29797E1545F11A14A22A3F7F0DEAD951C25061AAA797488DE2467A
          643291DDBDB02011268682AF8282F5A749DB310AE0746D2DC6D8581E6A71B1FA
          EBBD146FCC20376A008D568D5623E1373B12FC85D17EA2672A9510A21417FAC0
          2B7974BB3CD0D807492F31F1F265173A35A39B7CDD83A9E52E924D85749FAD26
          D5FA2913033D7FEB88574408D29D21A0D783D64DA850DE80BDBA15E2A7C1AC58
          8E6E7B97A9ABCFE1ED2E8D0EB83F26823AC54C162ECB24EC523EDACA3C7266F9
          E2707347EEAB85C8C920461F2F51B956E43F5028DA9E8FADD342C9F14BC8D61D
          62556AD2C8A8FF710E823CE55CB92B8760E914724B1BC61909DCD7B41397CE8B
          019B939756C42019841FBA40318556C8DB8AF39E700E773A989252456888EEE6
          8011932CF696C7A763D64570EFF96286037CF8F0580F8B62D5346B8C4C487C8A
          90D070264DD0137EB77EF4611DEBC76EFFFE72ACE62EBC7D755CACADE2B9BC5D
          6379ED3FF0CBFCD701BF027B03A4C86C4FEAAF0000000049454E44AE426082}
        Name = 'PngImage33'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
          F800000006624B474400FF00FF00FFA0BDA793000006424944415478DA9D5669
          50535714BE6FC9420821B20931211A6493A5385A1D46DC0A0A28D852772CED8C
          5A11511151D341AC28222008242EA0B26915AD4A196B1591BA54A13A6E58822C
          A282AC01220490F0C8F25EEFC371C629A053CFCCFDF1DE3DF77CE7DC7BBEEF5E
          44AFD783DEDE5E409224786F1445010A7E23280A701C4739C65C1E822040D3DF
          DFA7D3690DF41C8A61E05386C2F5485D5D1D080F0F072A950AD041E8E030206B
          BCC44E585BF5ACC1D9C56D52CCDEF8C3188621FB76EFDC585355596D67EF68FB
          B2AEB6699020B4F49A918C8E2312890052515101E6CF9F0F944AE5D004DFCCDC
          6C6BF4EEB899B3E7FA5FBA783ED34620B05DB17265180A03E5E5E51E2234FD1D
          4B962EFFB1A4A4A430397ECF9ECE0E65CF6815482492E1000291589C73B6F086
          A3BDC4CE9885930C1C4360707A0092CE8BA4480CC7B1EADAE75541010B7C5A9A
          5EB77D1260DEBC79804271EB19B3BE9A0323B1B749A313EDC4C2B106B8D71474
          7CAB1904388602331E0760E8BB2DA9AEAB6F4A4D4996E228421617FD715DD5D1
          DE3D2A80BFBF3FB238645DECEAD0F53B1980D41B73D82C6AC805013D7DFD6443
          630B4157E26867CB1E6B668AD01803833A401A4882C1C4B1E898DDDB33D20FC8
          4605085CF4353364FD96E34B972DFB81CDC061E7604399DF2EBDDF917B3CF3AF
          BAAA8A1AD851A8ABC754D7CD9B2366FACE9E6E068F1174F56AE81C28B9FC88EC
          40DCAE2812228E08E0E3E3038CF996DE4773CF1448C44253368B01EE3F7CFA66
          DBA65079D3CB9A42E8DB3A540E00B60E6E5357E4E4E6854EF370E6BDE9D180F2
          CA1AE5DA90E581AD8DAF1E8D5A41ECFEE479533DBD56CF9CEBB3C4C6828FD3FD
          1FB373D76F67B30F4741BF860FD6D020CE9BA47BE4B1313BBC358416B4B47711
          B76E96E49F3F9D9753FEE0EFB2110014E89DC755F97E0BFC9677AABA81318705
          34035A72CB86D0E8FBB7AFA5403FC37F1263FA05ADD89B9A2E93125A1DD0EB49
          C035E102D9C194B46369FBB78E5401927FA93865BEAF7F28C2601B8FB3341D9A
          8C8C88D871A5203F7984EE4356AD094FF839768FB49F18043D6F35548F5ADDF7
          4B6E5662C1A96309236E5140E02281A99568E9F6D8C4B819939D4C2CF85C70EE
          42615164F8BA60CDDB5EF5878BC6985BD9A465E6147879CDF0ECEEED078AEA17
          AA84982869FD73C5EF7AAD563532D17C7DC1342FEF90B048E9519E0997EB3E51
          0088419DF64846667AA63C2DA55DD9DA494BC23891785C5844D4AEA0C5CBD6EA
          481253AAD4A0ABBBA72BE3607CE883BB372F1B0C7A523B48E886F360610063CD
          E69FF2D6AFF93EB8BCA61138882CC0048105D041252CAFA87C5AA9A87C482108
          E6E0E4E22910D9BA68F506B4B3BB17D015708C8C40734BDB2B263950FFCF9387
          77E44971F1502A29835E4F4100EA1D93619B9A580ABDB76CDB91D4AE52332738
          BA3A797938308463F980848450C1768441A13A42451D18041DDD7DA0B155451A
          19B1000343751C26AA9CE6EE2856B6B5BECECDC9910B45B613B3B34E9CE857AB
          CA3FD0A2761C67B2C463CC2DAD0F659D3EC5E4F2251C3613589BF38001F2470F
          870E8E8EAE3EA081878BE11869C633466CADF80897C3A63ADFA80D16634C502B
          C8740AEAB2FCE889ECECA369EB87899DB548629F917DF28A9BCB24FBB38557EB
          7514C6767672B02161295555D5CD0C1C354CFD728AB8BAA6B6D9C69C8F4D9FE2
          6E73F5DAF597C70FCB8A6DC5E32DF7C7C7F9F34C4D8D366E080BAFA9787C6C18
          002419432076983B65BA6760D98DA24247F7292E7B9352D33403842E3A724398
          B2A5B1C3C3738E1F540E65F0AAEF42DC5D9C9DA2368525DC2ABE7C084131AB7D
          A919190B03023DAF5EBD5270F7CFA27DC3003E24141C3A631E5F64EF32F95BB8
          4DBABACA2717084D9F0AC519ACDDC947B28282BE09A6552BFF64B62C3D39416A
          35D65A9428CBBC289C30F10B42ABD79D3F9513FE31808F9A77E0D2358B97ADD8
          C1B7B0114D761A6FA8A97E768FC3E59933B8661E65F71E34D7552B1EBE503CDA
          F5D900288A71383CBE6BA2EC78A6C471D264756F1F6C4E0430984C7032539674
          E5D79C64D8A65D9F0D401B1BA6BC491A9BE5356BB69F3CEDE0191BA158E830C9
          CDE15C6E464CD5E3B20B434453281420202000B4B5B581D12EF08F1983C51158
          588FF3E86869788C62381BC319EC81B73D2FE1E5AAB7B3B303885AAD06A5A5A5
          802088FF1D9CB6F74F1CFA89F2EE16A459800EFDE772B9E05F504FFA172DC840
          8D0000000049454E44AE426082}
        Name = 'PngImage34'
        Background = clWindow
      end>
    Left = 771
    Top = 342
    Bitmap = {}
  end
  object PNGImageList2: TPngImageList
    PngImages = <
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D65004D692031204F6B7420
          323030332030303A30393A3134202B30313030D79824B90000000774494D4507
          D3091E160936E37B77EE000000097048597300000B1200000B1201D2DD7EFC00
          00020F4944415478DAA592CB6B534114C6BFDB97E60136585DD5454597A2B73B
          17E252117415102BCD1F2042312252912C8CC47657A8284AEA4EA54855C45811
          17D5D545E10A22141111B28879D0C4DC24F7314FE7CE055715AE38C381E1CC9C
          DF39E73B63E03F97B19D736F3969EFCB4C9A5248082120B840B555B37ECD0547
          6301F6DC4FD977664B669FB541B8875AA78AA5E7CFACEEA59880897B49FBF66C
          D16CF8DF103017F5761DE5571B969327F100BBEF26ECE5DC0DB3EE7F05A12E1A
          9D16CA2FDF59BD2B7F014CAC246C080361CF10C0901C9A5ACA15C66BEEA6AEA0
          ED74B05279BF2598AC4A0E44DA48780536AD01D36B07E5FCA98BE092414801A9
          CC655DB4FC1FA08C20A01ED2A3198C196910E6C125033C78F116B5CB5D43038E
          3C3920E74ECEC0A14D0DE19C818A008C51504E5490AF7C4219D74629C3DA9BCF
          685EED4780C3ABFBE585135974495D95C6C09471C1C1780808FE04869070AC84
          303C5580D6FC20021C7A3C25678E1D8713B454F912E11E1E317425614098D1F3
          A83E8720C6382A1B9BD8BAEE4680F1E59D5F0C1989A3DA57CA1A93F9EC995D8E
          DF56411C4ECFC7C3F50F4A4454C3FBE89D045B90D3DB8E31BD386617CEE7CC9F
          BDEF3AAB06543E5AA428E2FD83E4AD51FBDAB9B366B35FD52D398E8747EBB645
          6FC604244A23763E7BDA6C0F1A7ADEFD4180D5D79F2C5692F1003B8AC3762695
          32B9124B7F1A2ED1753C8B2F221EE05FD66F32F0622047298521000000004945
          4E44AE426082}
        Name = 'PngImage0'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D650046722031392044657A
          20323030332031343A35393A3435202B303130309EA896800000000774494D45
          07D3021A13051464D71DAB000000097048597300000AF000000AF00142AC3498
          000003134944415478DAA5936B4853611CC69FB35BD3DD6B4C5DB3B4AB56466A
          49145D20A83E058950911411D987FA165D24B12B144824F4A19B1569F745A160
          5898E9BAAD92155D57AB35CB39DC6A9E6D67E7EC9C9D4BC749C13EF7C0FB3EBC
          1F9EDFFF7DE17909FCA788D1ED4150AA0C0CD37B684E9AAD0051A02204A35294
          6413599117922C9D8E26134CD002FEA5824DBFD02B74DD1B6B8B62FF004D4F28
          6A5FEB27DDAA3213E617195164D3C26ED1C06C50C3AC5321570D18C6014A5E42
          EC170D7F204E0F0E0847376E283C96015CF0307E934155FC334C432D0AC8D52A
          603568609197395709DD2840038C975D311AE005B45E7917DFBCA5DC940138DF
          52CE05058A1A166AA8D54A98730804C32C28260D7F38059E13C0B12292340721
          95829794A04830EFCFEEAB28CB00AEF78F1C9C93A73D90A3D14292CF69517E9B
          4A767922E420130F23C172F2351CF08668BCF84242118CDCBA5C5FB16E0CF0F8
          57CD0CBBD14989DFE11C6AC1CD5813225F817BD503F07FF2205F70809218395F
          820049E0E337129A4862DBE9FA8A960CE0C6C3F0CCC23C93F776EC00B8D25E7C
          7409D895DF8CEE743BC869F711ED2C43C39253184A49707D18842FA48191212B
          AE362C7C9D01747749CA116230191DEF1EF75E70E2431F858EED9DD8E1DE89B8
          C305BF1B6828BE86618E8027402234624BCF29CDD135AD2D4C137F0B71B573C8
          BB60B161E6FA9E25689CDE0CABCA8112D354AC72CF428A8BA1759E1FCEA72E44
          0403BEFF9EF8ADA77ED2B47F3D18D5C9339EDEBA4DE5CB56745621647E0D1BEF
          40AD652FDA3FDF41828AE1F4CA3E3CF9E207ADB5E3EED3F8FD578D935767018E
          37B9DAD654CFADB5E9F468F69CC023FE1C043E89ADA68BB01179C8B5DAE1F187
          F02E62C0D7B0BECEBDBFE07C16E0D0E1AEA34B9797ECAF5A3409D13087F6FE0E
          945A2BE5FA89F00DF8A09B60876F3889C7013D285551E5AB3D264F16E0EC99E7
          1A2A45F5CF2A9F52A637B2E0530C44B90CA1E121088200953E1F41A110979E91
          EC7C35616A6B9CC16601C62411BB8F74D48DC4556B19BD653A67B4DA944AA52E
          1AA7A484A88905C9D41BE86D077F1C9EE8CAFA8DFFA33F5FB55D201E81618F00
          00000049454E44AE426082}
        Name = 'PngImage1'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D6500536F203137204E6F76
          20323030322031393A31373A3436202B3031303041C0B5F10000000774494D45
          07D3021A11252E34DB34D5000000097048597300000AF000000AF00142AC3498
          0000030C4944415478DAA593DB6F54451CC73FB3E76CBBDBEE2EA1EDEEB62CCA
          E5056250AAD407A2E083778D890F20E5A23418125F48285D2F8DBE1801294B2B
          BE90361A1BA8186B55900402BE09B4E5625AB6B4566D81256D0AD6A5EB2E2DA7
          E79C3DE7383D55FA0730934CE661E6339FDF7766040FD8C4CC50975CFB497F66
          E8838DD4ABABCB5EC4F0E8388E433E9FC734F318A68EA91B084B2139D14D4761
          63DE1C0B345C7AE7E6472E60C3B9478DF6CB57BD89E509E22FC799D6A619FC63
          108FC783655B38B64DB834C2FC4019AD9D87F83CF9214A30640ED5A60B5CC0A6
          AE4AE79B9E2B342D4D502B01B6DC90CBE55C45D334310CC39D17AB410E7735D3
          1ED8C7F54E8BBF3ECE0917B0B9FB71E7685F2F8D0BF7B3EB957749A7D30CFC36
          200D842C05B79C8AF20ACA82118E74B6702C7680E44F1AD986A959C09BD2A06D
          E00A89C85EE2AFD633A94DDE3F75C660260BDBB2F12BC5B475B57022D644DF09
          8D89FB0069F0F5EFBD7C5AB297F75FA867647C84A1E13F1132032197CCF44838
          424930CCD1EE2F38F9F0417A8F4F91F91FF0D685279CEF877BD8539460E75371
          34DB70374A79F7164C69A0EB3AC254E8B8DACAC9A54D5C3E969D33A89106A753
          032C531E21E804B0C8231C2133C03D5D714728145E1C9F891E1DE7971F6F91D9
          37F91F401A9C1DB98EAAD8E842C31426AA0A5E4950140FAA0CB350F11292B7E0
          1745CCF3F9F8F9879139C0B68B55CE85D114C26BF1527E1DAF976E217D274DEA
          760A8D7BF88B7C8443510EF4C7292E5759B17A09DFB5F590D9AFCD02DEBEB8CA
          F9F5F6288EA2B3355F47BF7283F6A9AFD8EAAB66FBBC7AA28B232C585CCE93CD
          6554AC0CF14CF9F3EC6E39CC3F0DFA2C60CBF94A67283B8EAD1A6CCCD4D1A724
          39E3FD969AD076763CB487F0A212599E425573090B2BE7B366C1B3EC6E3E3207
          A83EB5B2754C9FA8F1442C5E1BAC6538728973810EB6857751BBA2513E65873B
          A91C6F9C5FCEA2AA52D6449F6367C3A1E9BB09D3EF02780FCF63D1D867D73263
          EB57659F2E88AFAD2BB0431615A53199BC9F9BA32945FBDB28AA3EB33EADC630
          8B45C0CADEBDD7C897F641F1A0DFF95F25C5552042F1A0F80000000049454E44
          AE426082}
        Name = 'PngImage2'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D6500446F203134204E6F76
          20323030322032333A33313A3434202B3031303084501C480000000774494D45
          07D3021B00140B1CDA4902000000097048597300000B1200000B1201D2DD7EFC
          000002674944415478DA6364A01030D2D600D7BD620C7F9F57F24A8A07B0B3B0
          08BD79FEF62A2B27E7A6DF1BBD3B081B1079DE4254F8FB8696444BF1DFCC0C0C
          0F3F32301C7BC1C070EDFC6B86F7672E4E65D8E39A83DB80F85B3A4A92DF8F4C
          4CD3E35F7A9181E1C32F06869FFF19183EFE04E23F0C0C6FAE3FF9FFEDEE958C
          DFEB3D67410CC8BB5EC7C3C56EF8E5F1BD7086BFBF98794545CEAE2936D55C79
          9981E1D73F06864347AFFC7CF4F0CD6EC67F8C5C02B2D2F682062ACCF7E62DDB
          C47020DA1F6C806DDF8DDFE136EA2C3953F7D530FCFEC736BFD4A9EEF6072686
          4F409B576C3EF3F8F31FE6EC9F338C3683D4B2861F2C14D4D0ECFD7CF7D6BBEF
          4B6C44C006A8355DB8D313A5AF5CBFFEF6B79F7FFEFE6B09D2E039F1948161FF
          85477F2EDE7E17F36BBAE14A641FB2C59F3DC5C1C164F269A62113D800E6DC13
          6B37E49A075D040612E3FFBF0CBF199819BEFEFACFD0B7E6F4F2BF33CDA3D083
          883964DF025E21FE980FB38C59C006B0641DAD9B9664D6F8F9370BC3CFDF0C0C
          A2BC0C0C9376DC62B876FDE95E062EFE2F7F998536304C555C0037C17F5F012B
          D3CF0260202A800DE0CC3B9BEB6E2C3D29D2449CE1D17B06067E0E060660D831
          BC06863A0B3B03C392DD0FFF5D7DC72BC8D02DFC096C40E08174E6BFEF03FF6E
          0AF480C4427739932167D187061731DEFB4003FE314122F8D49D0F0CA76EBEF8
          FEE803C3CA3F133513E12E08399CC5CAF051E0F71A9F36783A109FF8FAE89A40
          11AB8B4FBE336CBFF585E1F8C36FF7BFBEF9B0E727937819C344C90F28811076
          5993E1E3A5C70C3BA3BFC00D606D7858A1CAFBABEEE6D30F4799193957FCEAD5
          990714FE3FC099890800003861FC11588B1A420000000049454E44AE426082}
        Name = 'PngImage3'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D65004D6F20313520417567
          20323030352031313A33313A3134202B30313030D9FE197A0000000774494D45
          07D306040C2000C4C27B10000000097048597300000AF000000AF00142AC3498
          000002074944415478DAA592CF4B545114C7BFEF511BC99C855259E9A295886E
          2472158842B61189528CD491B4A65A8C123443466F40A71917E5CB123589D248
          D4A261206CC08908252408FF018BD62EA331E6FD98D3B9EF398FB930B3A90B97
          7BEE83EFE7FBBDE73C05FFB9947C119F4D91384DD372EE46FE34DC336B98E2E8
          D1EFF72C970484AE9F2BE93432B68CC387CAF0EBF79E0429092022884876CEAD
          43B155DCF077E0F5DBB404F100B1990F140EB44BAE42683325977301858B018A
          0488E849D2821D450136032CDE8669B3FB1FE8B309D22303AA0C984C9036DC89
          6FDB3F59C8CD64A5E89FC14F306C6E226F2ED1DA5C03EDC14B3C191F548A0284
          ABEBCE02E1CE85AA282C26E7DB9E490C7881A7E34332407B94A0C848273E7FF9
          EE342F4722B64802D49EF0A12155E546E0540B359FD07FA94506DC9D7843D13B
          17B1B9B5E30084F8F8319F3305D18786F755781CE843706A11EF1AB770E17CB3
          0C08C7562816EEC28600881EEC03EA58285C85FBC3C065DCD697BC241883E201
          8623AF6852BB82F4E6CEFE138093D53ED427D9F9661F2CCB42369B452693816D
          DB883F5BE79FA70010D4167934BD58DBF8911F228E5696A32979C4731CF5B723
          3A97E27870B75E00B8169AA7B9F820763366C17F00274DD9411515D10308F9DB
          30319DC6F3331F71B5BB55EEC1AD7BF3A4AA2A5C8917C2B99D6E3C85FEAF2DAE
          2B4F65E16C9129FCEBFA0B0EB70C20B40F63B90000000049454E44AE426082}
        Name = 'PngImage4'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D65004D6F20313520417567
          20323030352031313A33313A3134202B30313030D9FE197A0000000774494D45
          07D308131104045447BFCB000000097048597300000AF000000AF00142AC3498
          0000023F4944415478DAA5925F48145114C6BF19112A370321A9B0B5242996E8
          2D2A7BB0DAA0285AAC27B78730C8DCADC87AD287680DB719A1A2A5B436A25D83
          6C45AAC5874AC8D2FC53104881F4D09F5D0C1F4AA8941AD77666676EE7CEB0E9
          54FB52172EE7DC87F33BDF39DF15F09F47C8262DE11EC6A3A665CCB79A8DAA15
          D3AAC6833774DADB9913D050B72367A793CD9D28742CC037256583E40430C6C0
          25E9869537C85DF0D778D071A7D706F90590AF3E648DBE9DB6AEBC50278A6158
          80B98700820DD014EA66817ACF5F013A013274554DA7EE330885E32CD47450B4
          032EC659E04415465E8E5121A88016A751114555A79C2EA5706F742220B5E372
          F0905D41EBCD5E76F480DBEC9A5D8FC1ACCE0657C1D518301505A4285A83B576
          C08BEB1D4C8DDDC08A5BF7904ABCC587E33EB8E473F858E2C2F88402520F2688
          70579002B91D6DBF03FA4B16B3CABDAB3052BC079FEE7763F77A054F1E1B28ED
          19C6E8BB2FE61810056CDD548A3372940087ED80DBE5AB99B77A099203099495
          2DC4F0C0048A63FD48AA0E4CFFD0A1D11C5C010734CB11B49DADB3039E4662CC
          08FAB165FB724C8F4FE2D59A6A141D6BC49BB149B3988F000EA01182A4E08A34
          073004D408E545D18A6DCB80549AD6ADE1D1900267571F12A44021051966B950
          B9C109A92582B0EC9B05DCCD1347F7D5BBD6BE26D95382039B97A6804203CF92
          2BB1AEEF39BE938786692DB795E1C2F928AEC9FE59C060BE18FFBC685ED5FC23
          A750B0CB83A9DAFDC84FCFA040BA8407EFBFF2AF6B7D2C30D3DA3C1AE50F17FE
          F5FC048FC128209A253CC30000000049454E44AE426082}
        Name = 'PngImage5'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D65004D6F20313520417567
          20323030352031313A33313A3134202B30313030D9FE197A0000000774494D45
          07D30917081D0C6069B8F9000000097048597300000AF000000AF00142AC3498
          000002534944415478DAA5D25F4853511C07F0EFBDE56423B57F24D65394157B
          281FAAB7208A4CF6302444109311D892A29C14DB68CD3B73DB9D0FE540ABC502
          ED8FA26DB55A5006D2430905F5945488605051A1CECAB57FF7EEEE74EED65637
          DA93E7E577CEBDFC3EE7777FF7C760898BC96F3CBE312247514C67CF423E0AB9
          9812443934793B9B468A029663078BDED4D13D82F2151A2CFE8C2B90A2002104
          72495226B777F53D4073C3010C05C7154801E0AF3C22D6B63AC5AD7262862A19
          1A87EFBDC0CC87399A9CC8BEA300A3001CDEFB846BD7179283C12026DFBC4322
          9582BA5405AD568B5A9D3E0B787D21E2751C6195406F8870A6FA5C722080AA9A
          9DD85EBD11534960FA3B109D18439914459DFE1038F720FA9CADCC7F01B96CCE
          E9C649BB0D25B4FCC96F02662212E2502332EAC2F1D3560A0CA0DF7954097017
          43C4D1514F9B4660B1D9A1333B9111525888A531174D235D5281AF43369CB175
          81E30771E95FE06C4F80B8CC0D48D1B6BB9C2EAC6FB1834946914C4A5814596C
          5855862F411E4693195DFC00058C4AC0CA8F12DEDA88989041F86E001155257E
          6CDE0B867ED21A15EDC1936B60C4380CD5A57818DF0243E37E256072DC24BDDC
          612CA6A4EC397C2780E9A9B78827E85FD0A851B1723574BB456C7B761BAF35FB
          5073CAA304DAB91BF4D7B4602121E5A7803614D96192A3F4F43AD6BDF28135EC
          81383C01F6E37CF7F2CBEF3B0B80D1E227573DAD988D897F0DD21F401E28CDF3
          5B287FE9C7B2E65AB8C355119BA96D6D013871CE4F5896452EA550C46F20F76C
          D78E4DD8FA691C8F854ACCCF7EE6FA2FF49C67B0C4F50BF3882020FB87868800
          00000049454E44AE426082}
        Name = 'PngImage6'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D65004D6F2031352044657A
          20323030332031363A34353A3436202B30313030D95E41CB0000000774494D45
          07D3021101300F8420E6EE000000097048597300000AF000000AF00142AC3498
          000002084944415478DA6364A01030227366CF9E3D99999939F8C993271F3839
          39834B4B4BAF1365C0E2C58B656363631F4F9D3AB5D7DADABA9089898961FBF6
          ED2FB8B8B8147273737F113400A8F1E59F3F7F3A787878A63C7FFEFC80878787
          E5A953A718DFBF7F6F575D5D7D98A001D3A64DFB09D4CCFAF2E5CB5722222242
          060606AC376EDC60B879F366734343431D41037A7A7AEEFBFAFA2A7CFDFA95E1
          EFDFBF0CAF5EBD62F8FCF933C3A3478FBEFDFEFDDB15E88A63780DE8ECEC8C96
          909058ACADADCDF8E9D3A7FF3F7FFE0419C2C8CFCFCF70EDDAB56F40BE736363
          E309BCB1D0D6D656070C079B5FBF7E31040707BBBC78F18201683B233020198E
          1F3FFE1128EEDEDCDC7C126F3482C0A4499398809A777B7979397EFBF68D8111
          0858595919F6EDDBF7E1CD9B375940F6ABCB972F1F04F2FF60350004A64C99C2
          F4F8F1E33DAEAEAE0EA03001A609C6FFFFFF339C397386014403E5AE0095F94E
          9C38F10156034020262686595656F602305D68031DC1F0E3C70FB05AA001FF41
          DE3C79F2E445A00186380D000160E2621615153D646868680972053085323C78
          F0E05F7C7C3CE392254B5EF5F6F64AE0350004B2B2B2A2D4D4D496F2F1F1311C
          3870E038300C72040404A603532B5B7777B721310648CBCBCBDF323333E33A7D
          FAF4FFDBB76F6702A37A2930C1090353F0438206400D71E4E5E59D0DB45DFEFB
          F7EF6B804E8FC4198DA402003BFCEF113D56E7AF0000000049454E44AE426082}
        Name = 'PngImage7'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000006624B474400FF00FF00FFA0BDA793000000097048597300000DD600
          000DD601906F799C000002D14944415478DA6D535F485361143F77F7DE6DE8DC
          EC3A119932248516D2A41984E01F94C2516FB5F421214458BD0515054550F460
          64D0E31E4402F7E05CBD250A43310509066396D389CDF90795F0DEAD3537BC7F
          B675BE9BC68A1D38DCEFFBEE777EE777CEF97D54A15080539B9F9FAF5A5959B9
          A8D3E9182861A2282ACDCDCDA1AEAE2EE1F48C2A06181D1DBD6CB3D9261A1A1A
          2AF3F97CA13858A3D150F178FCE7DADA5AFFD0D0D09792006363636DEDEDED9F
          9A9A9ACE9462B0B1F13DB9B8B8707D707070A92480DFEFBF63B39DF720808E61
          6892553D276472B91C026C88ABAB91BB2E97EB7D4980E9E9E9371C677E68B55A
          01FB0004841809164509B6B7B72191E0477A7B7B1FFD0548269335E170F83606
          542C2F7FBD5257676D23007A3D01608A004404D881DDDDAD25BBFD4200F769BB
          DDEEA5D6D7D7AF62F73F701C57110A8520994C81D168049A2E2E21AF7A2AF50B
          38AE125A5B1D200842BAA3A3E326B5B919BBC7F3C23B83C14023134D2412A1D0
          A0B83495EAC9198EB1D0D2D2923F3A3ACA5599ABEE5342827FAA65B5AF689A01
          9FCF07B3B3B36A66D203E227F3579DB0E8E9E981BEBE3E2C4B0149969E51FBFB
          7BC3C8E031090A0683108D46D56C269309CACACA54806C368BF4532A03D40938
          1C0E15CC5C6D7E4D0942624496A507E427CFF36A26B22E550271C20AFBA5DE33
          1A4D6FA9582CFE42928E9F2B8A021E8F07E6E6E63073395EFE134870C89A7CB3
          D90C74777783DBED56FF95971B5E52E1F03737CEF68956CBB2A8839AC3438171
          3AAF01EED549906045C9014930353505D5D59CE2743A7F48922CA36686A9E363
          B1425164135EA81F1F1FF75B2CF596CECE4E6059F61F21C9B2020B0B9F51073B
          7B0303032ED4C82EC3B0292A9D4EAB0D3A3838B00402818F2ED7AD4B8D8D6735
          A5DE422CB6999F9CF4057112376A6B6BF7885E28AFD70B333333A4FB74269339
          873AEF379BCDA6C27F5D24E2C026A7F0BD4CE8F5FA28BE971C0A097E03BE3872
          0A75FBA2F30000000049454E44AE426082}
        Name = 'PngImage8'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002A744558744372656174696F6E2054696D65004D6F2033204D727A20
          323030332032323A34323A3130202B30313030FF26557B0000000774494D4507
          D304021031162958BBF9000000097048597300000AF000000AF00142AC349800
          0001B54944415478DABD93DD2B43611CC7BF67E78CBC262FF39A5C284A286B8C
          92BF80A294524AEC4252A670E33FF00728E54A7999C85B335A5ECA950B454B29
          63C734660BDB313B7BCECBE370B192B012CFE5F3FC3E9F8BEFEFFB30F8E561FE
          57308D628660554FB92412927B308193C4054BC86783CCC168BDA5E2F8F110CE
          E333973A86EAC404CBC8C32DF6461BFAAB9CBE35501D03D759D02F8FAB057141
          F969568D1C54CA3CE7C22606A0C6E105643301EC5A1BFA6AF76E3721EB145CB8
          C3D128256DB0C2F92E28DFCEB4D4A599A64451607784A319B11D16ED9AC2862C
          DCC13962EE33BEC11214B83D61319A4ADE261CF110CD1B95FEEABC22032FB8E1
          135FE00A05A6F18031EDD56135F59AF7FD0E485A7A5797422CA2271D1884FDC3
          160CB3E9EB95B939AD1CCB4055296E9EC270FB9EEE871B7B0D07812DC42881C7
          239008473A3578FDF31A17918A10ECC682C296648E05516414A694C0FBEC0581
          0C9E17240DEED2E095AF7BB086747861AF293234B31C8398A4807214D7BC2047
          58D2ADC1B69F8B348B0C04E0A828CD69E29275F0F221394C490F86309F781327
          918928E6F549AC51D229235A9473DF55E49FFFC25F085E01B075B81134FC22DB
          0000000049454E44AE426082}
        Name = 'PngImage9'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D6500446920333020536570
          20323030332032333A35343A3236202B3031303065D5FFC10000000774494D45
          07D3091E1536385E5BCE8C000000097048597300000B1200000B1201D2DD7EFC
          0000029E4944415478DAA5924B48945114C77FDFCC3895A5869989299A956499
          E603B4905EF434348AA2A40744052E6A51B40982DAB4E80515D122A81605510B
          235B4485CEF808CD8CA6707A51166432E33C6AC6797C33DF63BA4D258DE822BA
          70E172CE3DBFFFB9FF7325FE7349A3032FA0C6078DA970B61C6C7FE73A616F40
          A2418B71AE1D1E9E023D01D00F17CC9B971C9CB12857B21FBFD3B128165BFA27
          D70B6B930B33EE1755A6270DF439B1DBFDB6755AAC2C01F03167DAE78213DBF2
          707B70B4F631F8C8BEAB026E3E87727D669AB5B276560AEE6FF43B82F475B9AF
          6E847D09806770A6F4D8E62349493AA80A3D97AD2EBF27B87DCAF4D45BD55BE7
          67E276331C08D1D6E2183044F4E20DE04B00BC8362434DE1AB39ABE64B048328
          1E1F4F9BDFC46A1A4A25BC5E743944578F4B57BF046B970B0FC634B1DB6868AB
          3ABA7E294209252A6E886EFC0188CABCEDF7F2A9C773A9160E8E3B050BD4E52F
          9BDB9C5F9209E1882814102582CB13A0FDF1579B98C0E26D208F09104EE70CC1
          B5B2FA92D559D9132124FFEA426C9733406BC790C52804B642703440EA86FDE4
          A69FAEA85B9066D24461282C8C547F77A0404CC3FB5DC6F2C4DB9BAAB3710D0C
          8E005A61535E555E5341F54CF8E617851A681A9A50366A2ABA22CE3F63311D59
          56B03C1F768443FACEEDD0120734C1CA85E5592D738AA60A35A1AAE9F8E508D6
          F621B57876B26956F604F10A01D1B4782EAAABDCED0C59F7C08A38E0BE51B2AD
          A99F5D6A9694F80567304A7797C74350AD17B85D6525298D391926F13554145D
          A7F75304E7A0BA7B07DC88036EC3B9BA5559870D9324DE0F8479F7D2F772B21E
          DB22C6F5E1E733EFC1C5C279930E601681AF51221EEDFC163834E2C14DC89862
          363CD04D52A61CD2AE0817CE3642E4EF09DD8293C3604E81EB0DF07ADC7FF0AF
          EB079F7E2E203010A8E70000000049454E44AE426082}
        Name = 'PngImage10'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D6500446920323620417567
          20323030332031323A34343A3432202B30313030DC5AB0AA0000000774494D45
          07D30A06140B39907BD933000000097048597300000B1100000B11017F645F91
          000003164944415478DA75936F48137118C7EF6E77EEE636DC60A326A6F8276B
          259A064514BD33B0721A04422F8A5E46A850F8A237426F82ECA5991932C40A2D
          72585A99F9A2ECCF366B54C89636E79FEA9C9B6EB73F6E73E7EFEED7732BA322
          0F3EDCDD73CFF7FB70BFE779486293ABF15C7341E9CED22125CB941024C12184
          3CC16070CAE170F48D8C8C4C414A1AC0E46606E3E32F9D93939F8ADD6EF787FC
          FC6D79870E1E564958DAEA74BE0BB4B4B45820C50B24FF32E8EB0B6A94CAB513
          82804EE974F4119E8FA6BCDE2F3E9FCFBB448834AEA8321C08043C0B57AFB675
          41FA43E07BC6C06E174E079743CD7A1D59C2308A34C6523827872A361894699A
          269128B22A8C14F48DAE7EB2A3A3F1D6CA4AC80D321BC0650CEEDF9F42C78F15
          22FF522A120A2552C9645ACACB3314104416118D0AEB82406046C12A6D837793
          57AE9CBDFD4BEC0056330677EEB893557BB725D1FA1A414284A6199AE3440DCB
          D2182111418CE4BE07B2DEDA9FCE5EBF7E71102456403E48296360B57E0894EF
          29A491201F2C49604C523C8FD42A95921645B40E317266C6C74C4C3CFD68B55E
          1E82A41E60EE77176EDE74B8CA2B761461096178A5D26991E1F9359A65B31828
          228542113C3FBFA0585E7EE3E9EC6CBB072D957F63E1B7C1850B9DD566F3FE07
          2CAB54E7E87512458814C7AD50B148988CADC6E28B8BB3B376BBCDD3DA7ABE7E
          7070C8D6DFDF7F0D649F012163D0D070B2A2B6B6DE4651FAA2B9F9789C0FAF7E
          E3F9AF469D2E656455CC6375B69AA22852BF658B69DFF0F0F0838181817B207B
          018433064D4D4D67EAEAEA7A128904E172B95EE5E6E60AA3A3CF4C3535477719
          0C0649144501E2591A8D866A6F6FEFF0FBFDAF41F61C08650C2A2B2B8BB45AAD
          CF62B1108220AC99CD6616634CC004457A7B7B1F4D4F4F474D26533DC4B78E8D
          8D75C1190C80CC09A4362691351A8D9724492A0D87C389EAEAEAC3656565DB63
          B1D8447777B70BBECB15A3C06E00014F8019F979C340BE1B802A400DD5F6D234
          7D060C47398E93A74E6EDD12A007144040DE837F978996C5721B0979047F9A15
          02D3C07B20F64731FC0B62B36D94CDB440369000E280F8BFC41F964A6B202208
          76DB0000000049454E44AE426082}
        Name = 'PngImage11'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C000001E94944415478DAED924D4854511886DFD3DCB98DD2C81D
          51122C29B49F4D20B4137722840B5DB5F307220299440D94903669096DA2652A
          221A2DFC4121A82068D93AC52868611359F837333A3A33F7DE73CFF9FACE9D88
          70DBA24DF72EEEF71DBEF39CF77DEF114484BF79C47F00C4B3A5D74E75A5B390
          FAFAE58C41F99EBFD977E5692B9C2AD300996D88EC0E709086F6258A455ECA00
          7B7B80D60C989A5B7C9FDAF8DCB8B2340FA5146E0FDE45F2D21320EE008184E0
          8DC8EE02B90CB40C5028709BFD033039F39C1E3F1A43BEE022168BA1B77F0883
          750F8093653CA180E21170740014F2909290CF971418486861F9C51B9241C034
          82220D152874CB4EC08A02261FC9367C97D7091E97B91C906651AEFB0BF0EAED
          3B1210B02211EEC043126D1BCD1042840326647606DFC76FF9878725760848F6
          DDA1D6B60E44AD086C3BCA4A34EAD6BA41E6E53A501AD2273E51B37CE2CDAC52
          513867E0A2B3AB87DAAF776167EB3BCB94A83E5DBBFFF1DBA6630225B6A4F9EB
          793E3C96606AC5765DEE5DF620A52C015AAEB5E3FEBDA1909A1C184E57D59C5D
          37969C8A53288BD961C0E3A3234DFBD98C7DE3666F6A6579E19CCBFFB3E756FF
          AA181D7B78559DB0E3B3D3132FB50ACAE3F18ADA0FEB6B3F8E5F98FA860B9F58
          D5E588655DE47C56594D79225179FEDF5FE59F6CE2228237C2BC360000000049
          454E44AE426082}
        Name = 'PngImage12'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          61000000097048597300000B1300000B1301009A9C18000002A64944415478DA
          6D93CD4F134118C69F99D96E3F31169780404122224140135434A807B58A173F
          087AE12FF0E0550FD2D0042EE8D978F02A1763FC48BCD11835E16268A2692908
          21310A82B2506BA1B4DBEE8CB37425AD3093496626797FF33EEF3C2FC17FE300
          414B5785EF16619495DE0B939BD1F4FAB3AF02B3A5F7A4F47088E0288F0722F7
          DA429A038E32705ECED1C4B04EDBBF5F9C13F8BC03600567A25591D13DB73543
          64E0DFA0B092E014C8B002D25E26CF2AC2CB8F75F789956D08F917BCF6C11B19
          68BDA6A5950DCC797E82AB14AA9CD6C8891C584EA027D90C7FD683878B637AE5
          B98D2D08B134275FA8131DE78F698412AC6EA640150AA23010524C5008016E9A
          10798E6ADF3E70CEF1693CAAFBFB8C1E72A5C231D8F9E4F8F0FB600EC9856540
          65C8BA004A298442404D1B20833C19B92F705435D5C39148C1199C0F915E1F1B
          32C7EAC2ADBC1AAFF74ECBD71984D4FD5BCDC36002EEAC84D9A5727106B360A2
          510B60F3570AFBAFAE8449AF970EC59EAAE15AE643ECC7AA7CC9AEAAF589D4DE
          5B77321326615080C6363FD2E90C3A068C30B9ECC2506C44098B6686B59801E1
          B4D297D595CB546C5641A66E431429C3DFE5843967A2E37EBE08980E39C2F923
          0CAB9339085978594B086983BC6D252683992125E4643212E6EB76429D32D13A
          2201979C181CBF4B86AF77B6E04D74764B3F771425085B02318AFFAD18C57D7F
          773BC6E271041F88D0D637AEF4938986331E4D39E042E2DD1A2C13EE5202CB8E
          089E0C2037F5071FBFA4F4AAE7A267DB484B7D241238EDD1D0ECC0CCDB14761B
          174ED5C18CAF637226A5D7BC144523955A79E90689349CF56A0DB5D558D457CA
          829B2A6B904EE8988C27F59A57A2DCCAA590853B3492AD17DA41D30DDB88D248
          C03CDB84FB1BD1EB1EF1DD9BA9A49D0FB7ABF42601296F67D9D07183EF68E7BF
          80051993695CEA4C0000000049454E44AE426082}
        Name = 'PngImage13'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          61000002804944415478DA6D934F4C134114C6BF99296D49FF44938500D55A0F
          4834A4565121E1E2A1A0078C42540EC6037AD09070327211A406BC603CA9410F
          CA8193987830868AA9D183BD98544AB0FEC144C4B606744D286D68B5DD5D773B
          6DD9029BBCECEEBCFD7EFBDE376F08365C2E823D4D36EB59C228D3AF2B922C85
          92A9C9EF0AE6F5EB44FF524FB07FFC4A5FC0D3DD215035430A594521901520FC
          F899D873FBAEF7AB82D94D004DFCB0B727D0D8DE2290EC1AA89C05AF4113AB61
          A884C24CF8E00F8A17C7C64B1052143F38DF15D8E76D16A894014927C05431A5
          1C2E493C88AD0A323522F232285E9A789A8710ADE7FB1D47837BBD2D02233294
          95253003C0E83A40963920A706AB72E69F3F4EBF152F3F7FD34ABACC150323BD
          A7872B6BEB90FDF1898B190FCD0745F340036891E31073FD41A4161730786F72
          90749AD8D0F5736D3EF3F66DC82D2D70319140E47F208AFAB5EA9E4C28146250
          EF4615406074362023FEC18D89173ED269A443FDC70EF8CC762BD25F42A0B934
          28A4BC81B460B1B60372A10599996171B722B3B28A517FC8474E310CF5796A7D
          96BA5AAC7D7E0F43B17CBABE8D7940C107AD0D4BE311A46271DC99897340AFDB
          E1B3EE702039F78EB75034B03407E53E58DD2A201AC7D89C0A38C9307061A76D
          B8AEED3896A79E94FE9E2F7F03A05845CD896EC4A7A7F0289A1CCC6FE3402582
          BB0EB9058BC381DFAFFD5B030A6D547B3BB0FA6D01D170441C49A3B53448FD66
          049C4D1CB2FCCABF25A0A69D8B63B3117134033E48FA51BE6A5221CD87059BCB
          85746CB10C6071EE46627E1ED1D08C78EB2FCA47590FB9E6A80ED8ED36A1C26A
          2925B561CAA652584DA4C49B3F7F6D7D9874C7B9C163A067D4142BCF28523827
          6F3ACEFF01C4441EAC867D5DDB0000000049454E44AE426082}
        Name = 'PngImage14'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000001974455874536F6674776172650041646F626520496D616765526561
          647971C9653C000002174944415478DA63FCFFFF3F03258031A4B616C16164F4
          05525224E87F0636E0EFBF7F30818C345FDFE9A69A9A0C427C7C3875BDFBF489
          E1F4F5EB0CB3366FCE640CADAB630079E3E7CF9F20B9ACB95555534F5CBECC60
          A6AD8DD51090E65357AF3258E8EA3224B7B565830D00BA9DE1DFDFBF0CDFBE7E
          CD59DFD333F9F5DBB70C27818698031509F1F323347FFC081717151666082C29
          C9051900F737D0158E698181E17F81867DFDFE9DE1FE93270C8A32320CDC9C9C
          70BE8186068315D000563636868082827CC6C0EA6A92FCFDE1DB370647636306
          760E0E06FF9C9C2246DFB23292FCBDFAC00106370B0B0601A0D77CD3D34B183D
          0B0B49F2F7A2EDDB1934E4E519E4805E0BCAC8286774C9CECEDB3061C2C4DFBF
          7E41145FBCC860AEAF0F36049D0FF2F7EABD7B19EC4C4D191E3C7CC890555353
          C368979A5AB871CA94BE9F3F7E30FCFCFD9BE1C1B3670CF7EFDF6750515060B8
          F3E00183A2A22283829414033B2B2BD8DF36E1E17B9E3E7C780AE4BABF5FBF3E
          62B4888B2BDE3C7366CF07A06D6F81581868D3D7AF5F194E9F3FCF606A68C8C0
          CDCD0D1707F9DB3D36B6E9DC9A353381FA4179E03DA3517878D9BA19333A1F01
          A348585090811DE84C74F013E8BDB7EFDFC3FDFDF9D5ABAEDBFBF74392BFBA97
          57F5B49696160560C060D38C6C08CCDF406EEBD7376F189E9C3AC5C0C8ABA696
          CECCCD2D476CEE01F91B8867C2332010B303B120103311A11FEC6F20FE011300
          0000660BA0177777650000000049454E44AE426082}
        Name = 'PngImage15'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          61000000097048597300000B1300000B1301009A9C18000002A14944415478DA
          A5934B4F135114C7FFB76F6829A5C4F25A900856131698A85B4D4C0C7E02135D
          6167E16770A9860A6A424450C0A623280D1B5898F8581089604003118540B082
          D68A5079D3D232EDCC9DEB691B85C425939CFCCFB9E79C5F66EE39C3841038CC
          C3E6DFB7375A6CAE735CE75C701DA410BA0E3D673C17FFF573E7826A34DDB814
          FD3D72E95AABCCC2E3F7654FF5A94653A11BBA9602840A2134528D1AB27EDE72
          31A9C162442C3C8F5068B8E7E6C3378D6C61B22B50515620594ACEC0642FA1C2
          24592607CA5B663FB6086C4523888E0FE2D98B9FC1BB4F6724169E781CA8F1DA
          A4E4FA1AAC9E06581C76404BFE0F3009EC6EAC21F26100D5479DB8D33625DFEA
          9EF4D11D7411C02A31C4B1134BC251751196A22C24B50F3070EC2576B030DA87
          9A3A37D4DD14013ECB4DC18F3E3637F62850EB354BD0E36006603BA610E43C6C
          CEA23C8469C8284944C6FB5151A9C168B6414D24D0D2312BFBE5291F9B79D711
          F07A0D921004604628AB51ECA5DD70D536C0EA280457535818EE45B1ED175C65
          477213511349B4747E91FD4F3EF9D8F4E8030240123C8EE47214CEF26330594D
          58598CC15973019B5F47E0295E47726B1B69258ED2F21228DBBB68EE5E946FF7
          1060EA6D5BE0C4712EC57FCCC0555507B3C50C3D43AFAE2B585E5C82BBD40AB3
          99BE8446BABE1CA33DD0506CB7A0A99300BDD33E3639742F50E9F82EB93C95B0
          1539C1D33401AED0D8D36074817A4681AE66630506A85889AE424B6B08BEDC91
          FD3D04187B7E2370B2DE2915D84D94A0666A1439CB43847EC02790D9C81009AF
          A26D704B6E1F9CF7B189A1D6BED3F5E62B48AF5373265FC8F3101CF005E5C069
          9D358EF44602CD03F17E7F68EE327B15BA7E7563E5DB59AEAA42D334DA738EAC
          6AA4FC5F9C3FCBF92AE5321A8B6C8AD1D0EBD9203BF4DF7858C01FB6BDBEF0FE
          479BA10000000049454E44AE426082}
        Name = 'PngImage16'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          61000000097048597300000B1300000B1301009A9C18000002EE4944415478DA
          75924D8814471886DFAAEAEAE99EDE9ED9F16FC80E2E2C8AA2879009E49CEB5E
          BC1842081A35E049C82DA740C8D5432E390882975C0DAC60AE86404E09094C40
          51135197557756D7D999D999D9FEA9AE1FBFEE1162040B3E1ABABE7ADEB7DEAF
          58A12DD4E421EADE0E0C6FC0D4EA608C418806F4E0AFEFA146CB7269F573D8C4
          68E7C08D82F097902B0B060EF636C0D622807BBE7D7AEB8A7B78ED223333B895
          733783A3673F2B9CCBB9CEDE0518C0884598FA7EB8476BD7F89DCB1739B3203B
          2895D9D12F6FB1935F9D26C04CC84304706F00A604902368440D7BEFC7EB6CFD
          A7557201B242C5A80C9C4E80CEEA1FE2A36F4E896065A094AEF69926C06CB48E
          002FA0B7EF5D61B7AF5E926A0CC76893B939803ECC919017809D38FF67D8FDFA
          E3344F33C104983106C39D1D8259C8203EC0258EF09FBFF845F47B0BF06AA896
          D3B0FE228A4FAE5F60D1E1DFACCAFB7996AA7D8B2DB0344D6F8CC7BB1F526E99
          75B6E02214C18DF3C7FD8DDFB995E11C6009101FC4DE99B5C7F01A13B822B046
          87711CF7589266BDC964DA9DCD12B4F635613D1F58FB16F2CEAF801F903AF917
          02B6F33E8A4FBF83AC2D60773882EF4B349B8DDB15806ED81D8E86184FC668EF
          6F230CEBD0E92EB863D5141C15F76BC80C3078BE89208CD06EB7619DB94B80B4
          678CEB7A9E409E15F8F7C13F3878E8003A9D6594F994197272307839407FE309
          568E1D411C2DA0283438C77DB6B797F4AC75DD2AEF726AA4FA841A051D7AAFB3
          444D1C5B9B9B20212C2F1F46200318A7ABE990B1076C3A9D558032ABF2091745
          5155966578B1BD4D11382C369B68B55A9052C2F33CFA6731EFE78FD870B8DBD3
          C656803449E05193A48004D971D655CD4278288C865239B436A8D743725639D8
          60FDADED5E9EAB6EA9188641A562ACA99EE9FF97AB1C2AA5C85D5EF5D2249EB1
          C7EB1B7F0F06C30FA228A2839A82B35570ECF50BFCEFF07CA225A45C4992228E
          A37E19E20FD3D9DE0995D3520559240895A609583BBF6B1964196A599E475794
          5EA92EE38568EB15C51D8BCDF6B088590000000049454E44AE426082}
        Name = 'PngImage17'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D650046722031322044657A
          20323030332032323A31303A3135202B303130305FE61F4E0000000774494D45
          07D30A06140B236D192049000000097048597300000AF000000AF00142AC3498
          000002934944415478DA7D935D48536118C7FF3305331553276D284286485416
          5430822814B4CBBAE8AA8B6E82F0CA8B1A354BC91B6FCA48B136D145F631B3A2
          961F1B7E2EA8FC28C84A1D6DC734CDDC87F34CCFB6B30FB7F5AC1DD12DEBC08F
          739EF33EEFEF7DCFF33E4784B8CB6834CA388EAB76381C475896DD61B1584C76
          BBFD6E5D5D5D3B0DBB88E0E67CD1E6C06AB5EEF37ABD634F3B5E2433D333CE50
          702D20954AB2A4929C049D4E7745ABD5B6519A7DB3245ED0A4D1745474F5E8DF
          F4F7761B232B8AC5E2A05C2EBFC8308C59A5525DA377C3C4EABF04FD57AB6A65
          EA96263585D3C43BC27DB3BEF1F6E4C4D7A3F7D5CDD514BF247E6E25107DF838
          65B8D3A82C1AEC6B5007BCE8395B82A9BC74F87364CD7DBD432385ED8FD5F594
          A721BE13E11801CFE3B85ED7DA3E60F82CA9A918A54D2602219E706078F6025A
          9E4D85CEEC7EF2F6FC2D5CA2F42F842F46109A2F9CEF78BE37D730E6448D6227
          76495280004BEB38F16362199A2E16451956D7E95A5CA6F457842546B03098CA
          490FC9529DCC24585B1849092204D7FCF0F31EF8DC3C02FE30D815B84BE468A0
          F456A1461B82B921F14ADE89EE742052E85E60896E36C04F9BE0E8F45739C06C
          86BB4C01258DA808265287758168B62F7B39BF549B0150A18303D1D32609EF24
          014D76B9A282F2AA3F93239863048C3E73A9A0AC33F37F021303FE9402F7B614
          98F559B63D659DD9C0F52D051E0FF0CD046F7954A08C17E0D3C3EDE307CFB515
          030F28EA02D868D3DAE84B7D7460160BC2EFC73156D90C038DB40835D828E2B1
          FD2838598C4AD9E194D28C344FEEB61092D67C0872AB70FDB26369CE8EC51B8F
          304FA923C46B6231BE1393897CE2005140503D901869112220FC890B8260E6AF
          4612AE24224D20F29CB0DE6782845A135415F8D727FC06230139202A0B9AB200
          00000049454E44AE426082}
        Name = 'PngImage18'
        Background = clWindow
      end
      item
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000002B744558744372656174696F6E2054696D650046722031322044657A
          20323030332032323A31303A3135202B303130305FE61F4E0000000774494D45
          07D3020D0F102A4AF1D326000000097048597300000AF000000AF00142AC3498
          000002644944415478DAA5D35D4853611807F0FF4999F36B2BFBD881DA217543
          D4A2426C3722457629D15D57D54D06461749175E26C26AE1C650B6D185903462
          D088A0BB4991848ED064836DB42CE752F7D1DCD7D9C7D976DC39BDD36E82A951
          2FBC1CCEF33CEFEF3CE79CF7A5F09F833AA8C062B11C974AA5668EE3060B8542
          29140ABD16457154AFD747FE0A70381CEF83C1E0E568341A1704A1916118A9D7
          EB5D2568CFF8F8786A5FC066B3B591C26FF3F3F3DF799EBFA1542A5764329923
          9FCF6BFC7EBFC56C360FEF0B4C4C58FA695A36B7BCFC39603018DA2AB1C9C9C9
          8196969659A7D3E933994CDD7B02A208EAE1E8B3FECE8EA60F3EAF7BC9A07FDA
          5B898F8D8D35ABD5EA3401B253535332EA77B19C7C8EDB806A0038D60596A3B1
          9991047E4884577EAD84DB7C13B8A59CB9DE7A1F6EADF6F1219A56945C2E5799
          7453B70B6C69565C6FD754E1AF515CB9A98144D10D9463E022613C9AE90573D8
          874B27E6D6CE0CA195FC016A7A7ABAE4F17804A3D1B80BF05EB9505BD3482193
          048EF6812F03DB5C02DBB918D60361E4923CEA25583F7B074CA5DE6EB73F5F5C
          5C3CA2D3E9AEED005CA04B909E7E41411C4699FD0421468209A0C4911C99F93C
          C026B0410065D58D94F9A2DA6EEAB0D60023E47D1680CA16D9220B5324C7922B
          4148731BE786F600585F7BB1B9D32AD901CACE5D204E16A6498E008502908E63
          F3FC5D9CAA0AA4BCEA9CBCCBDA003C20C0C21F402603140990882274611827AB
          02E18F0A1FDDF7B213D092BB773BED5766993C3D9B255E08628EC552CF3D5CAC
          0AB8CDA0C5FABA9166467E95AAFDD92E66D1C0B3286452882493F0145998069F
          60F69F4EE341E31700BA1A20CF45F0F10000000049454E44AE426082}
        Name = 'PngImage19'
        Background = clWindow
      end>
    Left = 770
    Top = 393
    Bitmap = {}
  end
  object frxBizim: TfrxDBDataset
    UserName = 'BizimFirma'
    CloseDataSource = False
    DataSet = TabBizim
    BCDToCurrency = False
    Left = 758
    Top = 73
  end
  object imgScheduler: TcxImageList
    Height = 18
    FormatVersion = 1
    DesignInfo = 25494358
    ImageInfo = <
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A00C24E0700C24E0700C24E
          0700C24E0700BC4B0500BC4B0500BC4B0500BC4B0500BC4B0500D2560E00FFEF
          C800FFEFC800FBD59A00FFEFC800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFF2D500FBD59A00FFEFC800FFEFC800BC4B0500D85B1300FFF1
          CE00FFF1CE00FAD6A300FFF1CE00FFFFFF000000000000000000000000000000
          0000BCBBBA00FFF3DC00FAD6A300FFF1CE00FFF1CE00C24E0700D85B1300FAD6
          A300FAD6A300FAD6A300FAD6A300FFFFFF00FFFFFF007E7D7D0000000000FFFF
          FF00FFFFFF00FADEBA00FAD6A300FAD6A300FAD6A300C6510A00DA661900FFF8
          DD00FFF8DD00FBD9AB00FFF8DD00FFF8DD00FBEBD6007E7D7D0000000000FFF5
          EB00FFF8DD00FFF8DD00FBD9AB00FFF8DD00FFF8DD00C6510A00E3691C00FFFA
          E400FFFAE400FADBAF00FFFAE400FFFAE400FBEBD6007E7D7D0000000000FFF5
          EB00FFFAE400FFFAE400FADBAF00FFFAE400FFFAE400CB580F00E3691C00FADD
          B400FADDB400FADDB400FADDB400FADDB400FDEEDC007E7D7D0000000000FFF5
          EB00FADDB400FADDB400FADDB400FADDB400FADDB400D15F1400E6752300FFFE
          F100FFFEF100FADEBA00FFFEF100FFFFF500FEF2E4007E7D7D0000000000FEF7
          EF00FFFEF100FFFEF100FADEBA00FFFEF100FFFEF100D15F1400E6752300FFFF
          F500FFFFF500FADEBA00FFFFF500FFFFFB00BCBBBA005F5E5E0000000000FEF7
          EF00FFFFF500FFFFF500FADEBA00FFFFF500FFFFF500DA661900ED7E2A00FADE
          C000FADEC000FADEC000FADEC000FDEEDC007E7D7D002020200000000000FEF7
          EF00FADEC000FADEC000FADEC000FADEC000FADEC000DA661900ED7E2A00FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FFFCF700BCBBBA0000000000FEF7
          EF00FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00DA782200EE862E00FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FCE8CD00FFFFFF00FFFFFF00FEF2
          E400FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00E6752300EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00F1963C00F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A00C24E0700C24E0700C24E
          0700C24E0700BC4B0500BC4B0500BC4B0500BC4B0500BC4B0500D2560E00FFEF
          C800FFEFC800FBD59A00FFEFC800FFFAEA00FDEEDC00FFFEF800FFFEF800FFF9
          F200FFF8E800FFEFC800FBD59A00FFEFC800FFEFC800BC4B0500D85B1300FFF1
          CE00FFF1CE00FAD6A300FFFAF500E3E3E1005F5E5E005F5E5E00202020007272
          7200FFFFFF00FFF8E800FAD6A300FFF1CE00FFF1CE00C24E0700D85B1300FAD6
          A300FAD6A300FAD6A300FFF4E7003F3E3E003F3E3E00FFFAF500CFCFCF000000
          000072727200FFFDFA00FAD6A300FAD6A300FAD6A300C6510A00DA661900FFF8
          DD00FFF8DD00FBD9AB00FFFCF7003F3E3E0097989700FFFCF700FFFFFF000000
          00000D0D0D00FFFFFF00FBD9AB00FFF8DD00FFF8DD00C6510A00E3691C00FFFA
          E400FFFAE400FADBAF00FFFEF800FFFEF800FFF5EB00FFFEF100FFFFFF000000
          000000000000FFFFFF00FADBAF00FFFAE400FFFAE400CB580F00E3691C00FADD
          B400FADDB400FADDB400FEE3BD00CFCFCF0097989700BCBBBA00727272000000
          000072727200FFFFFF00FADDB400FADDB400FADDB400D15F1400E6752300FFFE
          F100FFFEF100FADEBA00FFFEF100FFFFFB003F3E3E00515151003F3E3E007E7D
          7D00FFFFFF00FFFEF800FADEBA00FFFEF100FFFEF100D15F1400E6752300FFFF
          F500FFFFF500FADEBA00FFFFF500FFFFFB005F5E5E00FFFFFB00FFFFFB00FEF7
          EF00FFFFFB00FFFEF800FADEBA00FFFFF500FFFFF500DA661900ED7E2A00FADE
          C000FADEC000FADEC000FADEC000FFF4E7007E7D7D003F3E3E003F3E3E003F3E
          3E00BCBBBA00FBEBD600FADEC000FADEC000FADEC000DA661900ED7E2A00FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00BCBBBA003F3E3E003F3E3E003F3E
          3E0097989700FFFFFF00FADEC000FFFFFF00FFFFFF00DA782200EE862E00FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FEF7EF00FFFFFF00FFFFFF00FEF7
          EF00FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00E6752300EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00F1963C00F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A00C24E0700C24E0700C24E
          0700C24E0700BC4B0500BC4B0500BC4B0500BC4B0500BC4B0500D2560E00FFEF
          C800FFEFC800FBD59A00FFF1CE00FFFFFF00FFFFFF00FFFFFF00FFFEF800FBD5
          9A00FFEFC800FFEFC800FBD59A00FFEFC800FFEFC800BC4B0500D85B1300FFF1
          CE00FFF1CE00FAD6A300FFF2D500E3E3E1000000000020202000FFFFFF00FBDD
          B200FFF1CE00FFF1CE00FAD6A300FFF1CE00FFF1CE00C24E0700D85B1300FAD6
          A300FAD6A300FAD6A300FADBAF00FFFFFF005F5E5E0000000000CFCFCF00FBEB
          D600FAD6A300FAD6A300FAD6A300FAD6A300FAD6A300C6510A00DA661900FFF8
          DD00FFF8DD00FBD9AB00FFF8DD00FFFEF100CFCFCF000000000072727200FFFA
          F500FFF8DD00FFF8DD00FBD9AB00FFF8DD00FFF8DD00C6510A00E3691C00FFFA
          E400FFFAE400FADBAF00FFFAE400FFFEF100FFFFFF003F3E3E0020202000FFFF
          FF00FFFDFA00FFFAE400FADBAF00FFFAE400FFFAE400CB580F00E3691C00FADD
          B400FADDB400FADDB400FADDB400FBEBD6008A8A8A0033333300000000003333
          3300FFF9F200FADDB400FADDB400FADDB400FADDB400D15F1400E6752300FFFE
          F100FFFEF100FADEBA00FFFFFB00FFFFFB00FFF9F200FFFFFF00202020007272
          7200FFFFFE00FFFEF100FADEBA00FFFEF100FFFEF100D15F1400E6752300FFFF
          F500FFFFF500FADEBA00FFFFFE003F3E3E00FFFDFB00FFFFFE00979897002020
          2000FFFFFF00FFFEF800FADEBA00FFFFF500FFFFF500DA661900ED7E2A00FADE
          C000FADEC000FADEC000FFFDFB000D0D0D003F3E3E003F3E3E003F3E3E000000
          0000CFCFCF00FDEEDC00FADEC000FADEC000FADEC000DA661900ED7E2A00FFFF
          FF00FFFFFF00FADEC000FFFFFF003F3E3E003F3E3E003F3E3E003F3E3E003F3E
          3E008A8A8A00FFFFFF00FADEC000FFFFFF00FFFFFF00DA782200EE862E00FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FEF7EF00FFFFFF00FFFFFF00FEF7
          EF00FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00E6752300EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00F1963C00F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A00C24E0700C24E0700C24E
          0700C24E0700BC4B0500BC4B0500BC4B0500BC4B0500BC4B0500D2560E00FFEF
          C800FFF2D500FCE8CD00FFFAE400FFFAE400FCE8CD00FFF2D500FFEFC800FBD5
          9A00FFEFC800FFEFC800FBD59A00FFEFC800FFEFC800BC4B0500D85B1300FFF1
          CE00FFFFFF00CFCFCF007E7D7D007E7D7D00BCBBBA00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF3DC00C24E0700D85B1300FAD6
          A300FFFFFF00000000002020200033333300000000007E7D7D00FFFFFF000000
          0000000000000000000000000000BCBBBA00FADEBA00C6510A00DA661900FFF8
          DD00FFFFFF0097989700FFFFFF00FFFFFF007E7D7D000D0D0D00FFFFFF00FFFF
          FF007E7D7D003F3E3E00FFFFFF00FFFFFF00FFFAE400C6510A00E3691C00FFFA
          E400FFFEF100FCE8CD00FFFEF100FFFDFB00A7A9A90000000000FFFFFF00FBEB
          D6007E7D7D003F3E3E00FFF5EB00FFFAE400FFFAE400CB580F00E3691C00FADD
          B400FADDB400FCE8CD00BCBBBA007E7D7D00202020003F3E3E00FFFFFF00FDEE
          DC007E7D7D003F3E3E00FFF5EB00FADDB400FADDB400D15F1400E6752300FFFE
          F100FFFEF100FBEBD60097989700333333000D0D0D00CFCFCF00FFFFFB00FDEE
          DC007E7D7D003F3E3E00FEF7EF00FFFEF100FFFEF100D15F1400E6752300FFFF
          F500FFFFFB00FDEEDC00FFFFFE00FFFFFE004E4E4E0051515100FFFFFE00FEF2
          E4007E7D7D003F3E3E00FEF7EF00FFFFF500FFFFF500DA661900ED7E2A00FADE
          C000FFF5EB007E7D7D00CFCFCF00FFFFFF00515151003F3E3E00FFFCF700BCBB
          BA005F5E5E003F3E3E00FEF7EF00FADEC000FADEC000DA661900ED7E2A00FFFF
          FF00FFFFFF0051515100000000000000000000000000A7A9A900FFFFFF007E7D
          7D00202020003F3E3E00FEF7EF00FFFFFF00FFFFFF00DA782200EE862E00FFFF
          FF00FFFFFF00FFFFFF00CFCFCF00BCBBBA00E3E3E100FFFFFF00FFFFFF00FFFC
          F700BCBBBA0072727200FEF7EF00FFFFFF00FFFFFF00E6752300EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00F1963C00F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A00C24E0700C24E0700C24E
          0700C24E0700BC4B0500BC4B0500BC4B0500BC4B0500BC4B0500D2560E00FFEC
          BF00FFECBF00FBD59A00FFECBF00FFECBF00FBD59A00FFECBF00FFECBF00FBD5
          9A00FFECBF00FFECBF00FBD59A00FFECBF00FFECBF00BC4B0500D85B1300FFEF
          C800FFEFC800FBD59A00FFEFC800FFF2D500FCE4C100FFF8DD00FFF8DD00FCE4
          C100FFF2D500FFEFC800FBD59A00FFEFC800FFEFC800C24E0700D85B1300FAD6
          A300FAD6A300FBD9AB00FCE4C10067A4B100285967000C3140000C3140002859
          67006B938A00FCE4C100FBD9AB00FAD6A300FAD6A300C6510A00DA661900FFF2
          D500FFF2D500FCE4C10067A4B1003D93B60042C3E3005CDEFE005CDEFE0042C3
          E3001777920041738000FCE4C100FFF2D500FFF2D500C6510A00E3691C00FFF8
          DD00FFFAE4007BB0BC003D93B6006BDCFF0049D9FF002CCEFB002CCEFB0038D4
          FE005CDEFE00177792006B938A00FFFAE400FFF8DD00CB580F00E3691C00FADB
          AF00FCE8CD0067A4B10073CFF0005CDEFE0038D4FE0038D4FE002CCEFB002CCE
          FB0049D9FF0042C3E30028596700FCE8CD00FADBAF00D15F1400E6752300FFFA
          EA00FFFFF5003D93B60099E7FD005CDEFE0000000000000000000000000038D4
          FE0038D4FE006BDCFF000C314000FFFFF500FFFAEA00D15F1400E6752300FFFE
          F100FFFEF80067A4B10099E7FD0076E5FF006BDCFF005CDEFE000000000049D9
          FF0049D9FF0076E5FF000C314000FFFEF800FFFEF100DA661900ED7E2A00FADE
          BA00FBEBD60095CDDF0099E7FD0099E7FD0076E5FF0076E5FF00000000005CDE
          FE006BDCFF0064CBEA0041738000FBEBD600FADEBA00DA661900ED7E2A00FFFF
          FB00FFFFFB00ACDBE60095CDDF00B2ECFF0099E7FD008EDCFF00000000008EDC
          FF0099E7FD003D93B6007BB0BC00FFFFFB00FFFFFB00DA782200EE862E00FFFF
          FF00FFFFFF00FBEBD600ACDBE600ACDBE600B2ECFF00B2ECFF00B2ECFF0099E7
          FD007BB0BC007BB0BC00FBEBD600FFFFFF00FFFFFF00E6752300EE862E00FADE
          C000FADEC000FCE8CD00FBEBD600ACDBE60095CDDF007BB0BC007BB0BC007BB0
          BC0095CDDF00FBEBD600FCE8CD00FADEC000FADEC000E1802800EF8B3200FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FBEBD600FFFFFF00FFFFFF00FBEB
          D600FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00E1802800EF8B3200FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00FADE
          C000FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00E1802800EF8B3200EF8B
          3200EF8B3200EF8B3200EF8B3200EF8B3200EF8B3200EF8B3200EF8B3200EF8B
          3200EE862E00EE862E00EE862E00E8842900E8842900E8842900000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF00000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A00C24E0700C24E0700C24E
          0700BC4B0500BC4B050000000000000000000000000000000000DA661900FFF8
          DD00FFF8DD00FBD9AB00FFF8DD00FFF8DD00FBD9AB00FFF8DD00FFF8DD00FBD9
          AB00FFF8DD00C6510A0000000000000000000000000000000000E3691C00FFFA
          E400FFFAE400FADBAF00FFFAE400FFFAE400FADBAF00FFFAE400FFFAE400FADB
          AF00FFFAE400CB580F00C24E0700BC4B05000000000000000000E3691C00FADD
          B400FADDB400FADDB400FADDB400FADDB400FADDB400FADDB400FADDB400FADD
          B400FADDB400D15F1400FFF8DD00C6510A000000000000000000E6752300FFFE
          F100FFFEF100FADEBA00FFFEF100FFFEF100FADEBA00FFFEF100FFFEF100FADE
          BA00FFFEF100D15F1400FFFAE400CB580F00C24E0700BC4B0500E6752300FFFF
          F500FFFFF500FADEBA00FFFFF500FFFFF500FADEBA00FFFFF500FFFFF500FADE
          BA00FFFFF500DA661900FADDB400D15F1400FFF8DD00C6510A00ED7E2A00FADE
          C000FADEC000FADEC000FADEC000FADEC000FADEC000FADEC000FADEC000FADE
          C000FADEC000DA661900FFFEF100D15F1400FFFAE400CB580F00ED7E2A00FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00FADE
          C000FFFFFF00DA782200FFFFF500DA661900FADDB400D15F1400EE862E00FFFF
          FF00FFFFFF00FADEC000FFFFFF00FFFFFF00FADEC000FFFFFF00FFFFFF00FADE
          C000FFFFFF00E6752300FADEC000DA661900FFFEF100D15F1400EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00FFFFFF00DA782200FFFFF500DA661900F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00F1963C00FFFFFF00E6752300FADEC000DA661900F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100EF8C2A00EF8C2A00FFFFFF00DA782200000000000000
          0000F1963C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00F1963C00FFFFFF00E6752300000000000000
          0000F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100EF8C2A00EF8C2A00000000000000
          00000000000000000000F1963C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00F1963C00000000000000
          00000000000000000000F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000000F0000000F0000000300000003000000000000000000000000
          00000000000000000000000000000000000000000000C0000000C0000000F000
          0000F0000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000144B700000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000265D1000265D1000265D1000350CB000350CB000144B7000144
          B7000144B7000144B70000000000000000000000000000000000000000000000
          0000000000000887DD0012A5F20016C6F30016C6F3000CA4E6000887DD000350
          CB000350CB000144B70000000000000000000000000000000000000000000000
          000000000000000000000887DD0018DAFD0018DAFD0018DAFD0013B7F6000494
          F1000144B7000000000000000000000000000000000000000000000000001563
          C50000000000000000000887DD0018DAFD0018DAFD0018DAFD0013B7F6000494
          F1000144B70000000000000000000144B7000000000000000000000000000000
          00002372D100000000000CA4E60018DAFD0018DAFD0018DAFD0013B7F6000494
          F1000350CB00000000000144B700000000000000000000000000000000000000
          000000000000000000000CA4E60018DAFD0018DAFD0018DAFD0013B7F6000494
          F1000350CB0000000000000000000000000000000000000000004D90E5004D90
          E5003E81E2000000000011AFEA0018DAFD0018DAFD0018DAFD0013B7F6000494
          F1000265D100000000000350CB000350CB000350CB0000000000000000000000
          000000000000000000000000000011AFEA0018DAFD0018DAFD0013B7F6000887
          DD00000000000000000000000000000000000000000000000000000000000000
          000000000000529FD500000000000000000011AFEA000CA4E6000887DD000000
          0000000000002372D10000000000000000000000000000000000000000000000
          00005DB4E6000000000000000000000000000000000011AFEA00000000000000
          000000000000000000002372D1000000000000000000000000000000000073CF
          F00000000000000000000000000000000000000000000EB4F100000000000000
          00000000000000000000000000003E81E2000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000FFFF0000FEFF0000E00F0000E00F0000F01F0000B01B
          0000D0170000F01F000010110000F83F0000EC6F0000DEF70000BEFB0000FFFF
          0000FFFF0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000E9AB5800DD97
          3F00C2752000BA681E00BE762C00AA560500AA5605009F4E0500268AF300006C
          E9000350CB000350CB000350CB000027A2000027A2000027A200E9AB5800DD97
          3F00BA681E00D5AE9300E9D6C000AA560500AA5605009F4E0500268AF300006C
          E9000144B70078A8F400C8F3FF000027A2000027A2000027A200E9AB5800CC84
          3400BE762C00FFFDFA00FFFFFF00BE762C00AA5605009F4E0500268AF3000055
          ED000350CB00FFFFFF00FFFFFF000350CB000027A2000027A200E9AB5800C275
          2000E8C09500FFFFFF00FFFFFF00E7CBAD009F4E05009F4E0500268AF3000350
          CB008EDCFF00FFFFFF00FFFFFF00B2ECFF000027A2000027A20000000000CC84
          3400FFFFFF000000000000000000FFFFFF00BA681E000000000000000000006C
          E900FFFFFF000000000000000000FFFFFF000144B70000000000000000000000
          00001563C5000550B900043EA700043EA7000000000000000000000000000000
          00001563C5000550B900043EA700043EA7000000000000000000000000002372
          D10044CEFB0013B7F6000EB4F1000CA4E600043EA70000000000000000002372
          D10044CEFB0013B7F6000EB4F1000CA4E600043EA70000000000000000002372
          D10044CEFB0014BCFE000EB4F1000CA4E600043EA70000000000000000002372
          D10044CEFB0014BCFE000EB4F1000CA4E600043EA70000000000000000005F5E
          5E0044CEFB0014BCFE000EB4F1000CA4E6000000000000000000000000005F5E
          5E0044CEFB0014BCFE000EB4F1000CA4E6000000000000000000000000007E7D
          7D0044CEFB003F3E3E00202020000D0D0D000000000000000000000000007E7D
          7D0044CEFB003F3E3E00202020000D0D0D000000000000000000000000009798
          9700FFFFFF005555550033333300202020000D0D0D0000000000000000009798
          9700FFFFFF005555550033333300202020000D0D0D0000000000000000000000
          00008A8A8A00686969004E4E4E00333333000000000000000000000000000000
          00008A8A8A00686969004E4E4E00333333000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000FFFF0000000000000000000000000000000000008181
          0000C3C300008181000081810000818100008181000081810000C3C30000FFFF
          0000FFFF0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000BA681E00BA681E00BA681E00BA681E00BA68
          1E00BA681E000000000000000000000000000000000000000000CD7323000000
          00000000000000000000A65D1B0090480700904807000000000000000000BA68
          1E00BA681E00BA681E0000000000000000000000000000000000DA782200DA78
          220000000000BA681E00A65D1B00A65D1B000000000000000000000000000000
          0000BA681E00BA681E00BA681E00000000000000000000000000E1802800E180
          2800CD732300C56E2000BA681E00000000000000000000000000000000000000
          000000000000BA681E00BA681E00BA681E000000000000000000EE862E00E884
          2900E1802800E180280000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000EF8B3200EE86
          2E00EE862E00E8842900E1802800000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000F1963C00EF8B
          3200EF8B3200EE862E00E8842900E8842900000000000000000000000000CD73
          2300C56E2000C56E2000C56E2000C56E2000C56E200000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000CD732300CD732300C56E2000C56E2000C56E200000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000CD732300CD732300C56E2000C56E20000000000000000000DA78
          2200CD732300C56E200000000000000000000000000000000000000000000000
          0000DA782200CD732300CD732300CD732300CD73230000000000000000000000
          0000CD732300C56E2000BA681E0000000000000000000000000000000000DA78
          2200DA782200DA78220000000000CD732300CD73230000000000000000000000
          000000000000BA681E00BA681E00A65D1B000000000000000000E1802800E180
          2800DA782200000000000000000000000000CD73230000000000000000000000
          00000000000000000000E8842900E8842900E8842900E8842900E1802800E180
          2800000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000FFFF0000F81F0000718F000023C7000007E300000FFF
          000007FF000003810000FFC10000FFE100008FC10000C7890000E31D0000F03F
          0000FFFF0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000272727002727
          270020202000202020001515150015151500151515000D0D0D000D0D0D000D0D
          0D0007070700050505000101010001010100000000000000000033333300FFFF
          FF00272727008EDCFF008EDCFF008EDCFF008EDCFF008EDCFF008EDCFF008EDC
          FF008EDCFF008EDCFF008EDCFF008EDCFF008EDCFF00010101003F3E3E00FFFF
          FF00333333008EDCFF0021C5FE0014BCFE0014BCFE0014BCFE0014BCFE0014BC
          FE0014BCFE0014BCFE0014BCFE0014BCFE008EDCFF000707070047474700FFFF
          FF003F3E3E0099E7FD0021C5FE0021C5FE0021C5FE0021C5FE0014BCFE0014BC
          FE0014BCFE0014BCFE0014BCFE0014BCFE008EDCFF000D0D0D004E4E4E00FFFF
          FF004747470099E7FD002CCEFB002CCEFB0021C5FE0021C5FE0021C5FE0021C5
          FE0014BCFE0014BCFE0014BCFE0014BCFE008EDCFF001515150055555500FFFF
          FF005151510099E7FD0038D4FE0038D4FE002CCEFB002CCEFB002CCEFB0021C5
          FE0021C5FE0021C5FE0021C5FE0014BCFE008EDCFF00202020005F5E5E00FFFF
          FF005F5E5E00B2ECFF007BDBFF0099E7FD0076E5FF0049D9FF002CCEFB002CCE
          FB002CCEFB0021C5FE0021C5FE0021C5FE008EDCFF002020200068696900FFFF
          FF0068696900C8F3FF00BD929100BC483B00B381620076E5FF0038D4FE0038D4
          FE0038D4FE002CCEFB002CCEFB002CCEFB0099E7FD002727270072727200FFFF
          FF0068696900E1FAFF00D0514300C83F2F00C0493D0099E7FD0049D9FF0049D9
          FF0044CEFB0038D4FE0038D4FE0038D4FE0099E7FD00333333007E7D7D00FFFF
          FF0072727200C8F3FF00D5AE9300D0514300BD92910099E7FD005CDEFE0049D9
          FF0049D9FF0049D9FF0049D9FF0038D4FE0099E7FD003F3E3E008A8A8A00FFFF
          FF007E7D7D00C8F3FF00C8F3FF00E1FAFF00C8F3FF0099E7FD0099E7FD00B2EC
          FF0099E7FD006BDCFF0049D9FF0049D9FF0099E7FD00474747008A8A8A00FFFF
          FF008A8A8A00E1FAFF0057B66E000387220057B66E00C8F3FF00788FCB004654
          B200788FCB0099E7FD005CDEFE005CDEFE00B2ECFF005555550097989700FFFF
          FF008A8A8A00E1FAFF0015A754000387220003872200E1FAFF004A6FC2004654
          B2004654B200B2ECFF0076E5FF006BDCFF00B2ECFF005F5E5E0097989700FFFF
          FF0097989700E1FAFF0061D59E0015A7540061D59E00C8F3FF008C96F0004A6F
          C2008C96F000B2ECFF0076E5FF0076E5FF00B2ECFF006869690097989700FFFF
          FF0097989700E1FAFF00E1FAFF00E1FAFF00E1FAFF00E1FAFF00E1FAFF00E1FA
          FF00E1FAFF00C8F3FF00C8F3FF00C8F3FF00C8F3FF0072727200979897009798
          97009798970097989700979897009798970097989700979897008A8A8A008A8A
          8A008A8A8A008A8A8A007E7D7D007E7D7D007E7D7D007E7D7D00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF00000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CC843400C164
          0600B55D0500AA560500AA560500FBD59A00FBD59A00FBD59A00FBD59A00FBD5
          9A00FBD59A00CC843400C1640600B55D0500AA560500AA560500EFB05500E589
          0C00E5890C00E5890C00AA560500FFEBC500FFEBC500FFEBC500FFEBC500FFEB
          C500FFEBC500EFB05500E5890C00E5890C00E5890C00AA560500FBBB5800F3A1
          1200FFFFFF00E5890C00B55D0500FEE3BD00FEE3BD00FEE3BD00FEE3BD00FEE3
          BD00FEE3BD00FBBB5800F3A11200FFFFFF00E5890C00B55D0500FAC35A00F3A1
          1200F3A11200F3A11200C1640600FEE3B100FEE3B100FEE3B100FEE3B100FEE3
          B100FEE3B100FAC35A00F3A11200F3A11200F3A11200C1640600FEE3AB00FCD4
          8C00FCD48C00FCD48C00FBCB8500FEDDA500FEDDA500FEDDA500FEDDA500FEDD
          A500FEDDA500FEE3AB00FCD48C00FCD48C00FCD48C00FBCB8500E9AB5800DD97
          3F00BA681E00D5AE9300E9D6C000AA560500AA5605009F4E0500268AF300006C
          E9000144B70078A8F400C8F3FF000027A2000027A2000027A200E9AB5800CC84
          3400BE762C00FFFDFA00FFFFFF00BE762C00AA5605009F4E0500268AF3000055
          ED000350CB00FFFFFF00FFFFFF000350CB000027A2000027A200E9AB5800C275
          2000E8C09500FFFFFF00FFFFFF00E7CBAD009F4E05009F4E0500268AF3000350
          CB008EDCFF00FFFFFF00FFFFFF00B2ECFF000027A2000027A20000000000CC84
          3400FFFFFF000000000000000000FFFFFF00BA681E000000000000000000006C
          E900FFFFFF000000000000000000FFFFFF000144B70000000000000000000000
          00001563C5000550B900043EA700043EA7000000000000000000000000000000
          00001563C5000550B900043EA700043EA7000000000000000000000000002372
          D10044CEFB0013B7F6000EB4F1000CA4E600043EA70000000000000000002372
          D10044CEFB0013B7F6000EB4F1000CA4E600043EA70000000000000000002372
          D10044CEFB0014BCFE000EB4F1000CA4E600043EA70000000000000000002372
          D10044CEFB0014BCFE000EB4F1000CA4E600043EA70000000000000000005F5E
          5E0044CEFB0014BCFE000EB4F1000CA4E6000000000000000000000000005F5E
          5E0044CEFB0014BCFE000EB4F1000CA4E6000000000000000000000000007E7D
          7D0044CEFB003F3E3E00202020000D0D0D000000000000000000000000007E7D
          7D0044CEFB003F3E3E00202020000D0D0D000000000000000000000000009798
          9700FFFFFF005555550033333300202020000D0D0D0000000000000000009798
          9700FFFFFF005555550033333300202020000D0D0D0000000000000000000000
          00008A8A8A00686969004E4E4E00333333000000000000000000000000000000
          00008A8A8A00686969004E4E4E00333333000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF00000000000000000000000000000000000000000000000000000000
          00000000000081810000C3C30000818100008181000081810000818100008181
          0000C3C30000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000004E4E4E003F3E3E00333333002727
          270020202000151515000D0D0D00070707000000000000000000000000000000
          0000000000000000000000000000000000005555550057B66E0057B66E0057B6
          6E0057B66E0057B66E0057B66E0057B66E0057B66E0000000000000000000000
          000000000000202020000D0D0D000000000068696900FFFCF700FFF9F200FFF9
          F2000387220003872200038722000387220057B66E0007070700000000000000
          00003F3E3E0000000000000000000000000072727200FFF8E800FFF3DC00FFF3
          DC00FFF3DC00FFF3DC00FFF3DC000387220057B66E000D0D0D00000000000000
          0000474747000000000000000000000000008A8A8A00FFF3DC00FFEBC500FFEB
          C500FFEBC500FFEBC500FFEBC500FFEBC500FFF3DC00151515007E7D7D006869
          6900555555003F3E3E00333333000000000097989700FFEFC80014BCFE00FEE3
          AB00FEE3AB00FEE3AB00FEE3AB00FEE3AB00FFEFC80020202000000000007E7D
          7D005F5E5E004E4E4E000000000000000000A7A9A900FEE7B700FEE7B700FEE7
          B700FEE7B700FEE7B700FEE7B700FEE7B700FEE7B70033333300000000000000
          000072727200000000000000000000000000A7A9A900A7A9A900979897008A8A
          8A007E7D7D00686969005F5E5E0055555500474747003F3E3E00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000E0660300E066
          0300E0660300E0660300E0660300E0660300E0660300E0660300E0660300E066
          0300E0660300E0660300E0660300E0660300E0660300E0660300E0660300F5AB
          5F00F5AB5F00F5AB5F00F5AB5F00F5AB5F00F5AB5F00F5AB5F00F5AB5F00F5AB
          5F00F5AB5F00F5AB5F00F5AB5F00F5AB5F00F5AB5F00E0660300EE730900FCBC
          68005F5E5E005555550047474700FAC08000F5952E00F5952E00F5952E00F595
          2E00F5952E00F5952E00F5952E00F5952E00FCBC6800EE730900EE730900FAC0
          80007E7D7D00FEE3BD005F5E5E00F6C79700F8A64700F8A64700F8A64700F8A6
          4700F8A64700F8A64700F8A64700F8A64700FAC08000EE730900EE730900FBD5
          9A00979897008A8A8A007E7D7D00FBD9AB00FCC07300FCC07300FCC07300FCC0
          7300FCC07300FCC07300FCC07300FCC07300FBD59A00EE730900FA7D0E00FEE3
          BD00FEE3BD00FEE3BD00FEE3BD00FEE3BD00FEE3BD00FEE3BD00FEE3BD00FEE3
          BD00FEE3BD00FEE3BD00FEE3BD00FEE3BD00FEE3BD00FA7D0E00FA7D0E00FA7D
          0E00FA7D0E00FA7D0E00FA7D0E00FA7D0E00FA7D0E00FA7D0E00FA7D0E00FA7D
          0E00FA7D0E00FA7D0E00FA7D0E00FA7D0E00FA7D0E00FA7D0E00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FC000000FC000000E4000000DC000000DC000000040000008C00
          0000DC000000FFFF000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000FDD482000027A200043EA7001048B8001048B8001563C5002372D1002372
          D100000000000000000000000000000000000000000000000000000000000000
          0000FEDDA5001048B8001563C5002372D1002372D1003E81E2003E81E2003E81
          E2004D90E5004D90E50000000000000000000000000000000000000000000000
          0000FFEFC8002372D1003E81E2003E81E2004D90E5006B89ED006B89ED006B89
          ED0078A8F40078A8F40078A8F400272727002727270027272700000000000000
          0000FFF8E8002372D1004D90E5006B89ED0078A8F40078A8F4006B89ED00FFE0
          B40078A8F4008C96F00095CDDF00FEDDA500FAD6A30033333300000000000000
          000000000000000000004A6FC2004A6FC2004D7ECA00788FCB00FEE3BD00FEC6
          7800FCBC6800FCBC6800FBBB5800FBBB5800FEDDA5003F3E3E00000000000000
          000000000000000000000000000072727200FFFFFF005F5E5E00FFEBC500FBCB
          8500FEC67800FCC07300FCBC6800FBBB5800FBD9AB0047474700000000000000
          000000000000000000000000000072727200FFFFFF0068696900FCE8CD00FCD4
          8C00FBCB8500FEC67800FCC07300FCBC6800FADBAF0051515100000000000000
          00000000000000000000000000007E7D7D00FFFFFF0072727200FFF1CE00FBD5
          9A00FCD48C00FBCB8500FEC67800FCC07300FFE0B4005F5E5E00000000000000
          00000000000000000000000000007E7D7D00FFFFFF0072727200FFF2D500FEDD
          A500FBD59A00FCD48C00FBCB8500FFC67C00FEE3BD0068696900000000000000
          00000000000000000000000000008A8A8A00FFFFFF007E7D7D00FFF3DC00FFF2
          D500FBEBD600FCE8CD00FFEBC500FCE4C100FEE3BD0072727200000000000000
          00000000000000000000000000008A8A8A008A8A8A007E7D7D007E7D7D007E7D
          7D007E7D7D007E7D7D0072727200727272007272720072727200000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000FFFF0000FFFF0000003F0000000F0000000000000000
          0000F0000000F8000000F8000000F8000000F8000000F8000000F8000000FFFF
          0000FFFF0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000072727200686969005F5E5E00555555004E4E4E004747
          47003F3E3E003333330033333300272727002727270020202000000000000000
          000000000000000000007E7D7D00A6EED000A6EED000A6EED000A6EED00088EE
          C20088EEC20088EEC20088EEC20088EEC20088EEC20027272700000000000000
          000000000000000000007E7D7D00C5F4E10061D59E0061D59E0037DA920037DA
          920037DA920037DA920025C4770025C4770088EEC20027272700000000000000
          000000000000000000008A8A8A00C5F4E10077E7B50077E7B50061D59E0061D5
          9E0037DA920037DA920037DA920037DA920088EEC20033333300727272006869
          69005F5E5E005555550072727200979897006B938A0048866C0048866C004886
          6C0048866C0048866C0037DA920037DA920088EEC200333333007E7D7D00FEE7
          B700FEE7B700FEE3B100979897005353F0005353F0005353F0005353F0005353
          F0005353F00048866C0061D59E0037DA9200A6EED0003F3E3E007E7D7D00FCE4
          C100FCCF7A00FBCC7100A7A9A9005353F0001C1CE6001C1CE6001C1CE6001C1C
          E6005353F00048866C0061D59E0061D59E00A6EED000474747008A8A8A00FFEB
          C500FDD48200FCCF7A00A7A9A9006B89ED001C1CE6001C1CE6001C1CE6001C1C
          E6005353F00048866C0077E7B50061D59E00A6EED0005151510097989700FFEF
          C800FCD48C00FDD48200BCBBBA006B89ED005353F0001C1CE6001C1CE6001C1C
          E6005353F0006B938A0088EEC20077E7B500A6EED0005F5E5E0097989700FFF1
          CE00FBD59A00FCD48C00BCBBBA008C96F0005353F0005353F0005353F0005353
          F0006B89ED006B938A0088EEC20088EEC200C5F4E10068696900A7A9A900FFF2
          D500FEDDA500FBD59A00BCBBBA008C96F0008C96F0008C96F0008C96F0008C96
          F0008C96F00097989700C5F4E100C5F4E100C5F4E10072727200A7A9A900FFF3
          DC00FEE3AB00FEDDA500BCBBBA00BCBBBA00BCBBBA00BCBBBA00A7A9A900A7A9
          A900A7A9A90072727200979897008A8A8A007E7D7D007E7D7D00BCBBBA00FFF3
          DC00FEE7B700FEE3B100FEDDA500FEDDA500FBD59A00FCD48C00FCD48C00FDD4
          8200FEE3BD005F5E5E0000000000000000000000000000000000BCBBBA00FFF4
          E700FFECBF00FEE7B700FEE3B100FEE3AB00FEDDA500FBD59A00FBD59A00FCD4
          8C00FFECBF006869690000000000000000000000000000000000BCBBBA00FFF8
          E800FFF4E700FEF2E400FFF3DC00FFF3DC00FFF2D500FFF2D500FFF1CE00FFEF
          C800FFEBC5007272720000000000000000000000000000000000BCBBBA00BCBB
          BA00BCBBBA00BCBBBA00A7A9A900A7A9A900A7A9A90097989700979897008A8A
          8A007E7D7D007E7D7D0000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000F0000000F0000000F0000000F000000000000000000000000000
          00000000000000000000000000000000000000000000000F0000000F0000000F
          0000000F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000550B9000550
          B9000550B9000144B7000144B7000144B700043EA700043EA700043EA700043E
          A700043EA700043EA700000000000000000000000000000000000350CB00B2EC
          FF00B2ECFF0099E7FD0099E7FD008EDCFF007BDBFF007BDBFF0069CFFF0069CF
          FF0069CFFF00043EA700000000000000000000000000000000000265D100B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB0036C2FE0036C2FE002AB4FD000144
          B7000144B700043EA700000000000000000000000000000000000265D100B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB0036C2FE0036C2FE002AB4FD0014BC
          FE0069CFFF00043EA7004A6FC2004A6FC2004A6FC2004A6FC2000265D100B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB000144B7000144B7000144B7000144
          B7000144B700043EA70099E7FD008EDCFF008EDCFF004A6FC2000265D100B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB0036C2FE0036C2FE002AB4FD0014BC
          FE0069CFFF000144B70069CFFF004D7ECA004D7ECA004D7ECA000265D100B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB0036C2FE0036C2FE002AB4FD000144
          B7000144B7000144B70069CFFF005FCCFF008EDCFF004D7ECA000265D100B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB0036C2FE0036C2FE002AB4FD0014BC
          FE0069CFFF000144B7004D7ECA004D7ECA004D7ECA004D7ECA00006CE900B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB000144B7000144B7000144B7000144
          B7000144B7000550B90069CFFF005FCCFF008EDCFF004D7ECA00006CE900B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB0036C2FE0036C2FE002AB4FD0014BC
          FE0069CFFF000550B90069CFFF004D7ECA004D7ECA004D7ECA00006CE900B2EC
          FF007BDBFF006BDCFF005AD2FF0044CEFB0036C2FE0036C2FE002AB4FD000144
          B7000144B7000550B90069CFFF005FCCFF008EDCFF004D7ECA00006CE900B2EC
          FF00B2ECFF0099E7FD0099E7FD008EDCFF007BDBFF007BDBFF0069CFFF0069CF
          FF0069CFFF000550B9004D7ECA004D7ECA004D7ECA004D7ECA00006CE900006C
          E900006CE900006CE9000265D1000265D1000265D1000265D1000265D1000350
          CB000350CB000350CB0069CFFF005FCCFF008EDCFF004D7ECA00000000000000
          000000000000000000004D90E500C8F3FF0099E7FD0099E7FD008EDCFF007BDB
          FF007BDBFF0069CFFF0069CFFF004D7ECA004D7ECA004D7ECA00000000000000
          000000000000000000004D90E500C8F3FF00C8F3FF00B2ECFF00B2ECFF00B2EC
          FF00B2ECFF0099E7FD0099E7FD008EDCFF008EDCFF004D7ECA00000000000000
          000000000000000000004D90E5004D90E5004D90E5004D90E5004D90E5004D90
          E5004D90E5004D90E5004D90E5004D90E5004D90E5004D7ECA00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000000F0000000F0000000F00000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000F0000000F000
          0000F0000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000AD531100AD531100AD53
          11009F4E05009F4E0500904807008F3402008F3402008F340200000000000000
          00000000000000000000000000000000000000000000BA681E00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008F340200000000000000
          00000000000000000000000000000000000000000000C56E2000FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0090480700000000000000
          00000000000000000000000000000000000000000000CD732300FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009F4E0500CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A00DA782200FFFFFF008F34
          02008F3402008F340200FFFFFF00FFFFFF00FFFFFF00AD531100DA661900FFF8
          DD00FFF8DD00FFFAE400FFF8DD00FFF8DD00FFFAE400E1802800FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00AD531100E3691C00FFFA
          E400FFFAE400FFFAE400FFFAE400FFFAE400FFFAE400E68C3400FFFFFF008F34
          02008F3402008F3402008F3402008F340200FFFFFF00BA681E00E3691C00FADD
          B400FADDB400FADDB400FADDB400FADDB400FADDB400EF963400FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C56E2000E6752300FFFE
          F100FFFEF100FFFFF500FFFEF100FFFEF100FFFFF500FAA13900FFFFFF008F34
          02008F3402008F3402008F3402008F340200FFFFFF00CD732300E6752300FFFF
          F500FFFFF500FFFFF500FFFFF500FFFFF500FFFFF500FAA13900FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DA782200ED7E2A00FADE
          C000FADEC000FADEC000FADEC000FADEC000FADEC000FAA13900FAA13900FAA1
          3900FAA13900EF963400EF963400E68C3400E48A2E00E1802800ED7E2A00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00DA78220000000000000000000000000000000000EE862E00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00E675230000000000000000000000000000000000EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A0000000000000000000000000000000000F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00F1963C0000000000000000000000000000000000F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A3510000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FE000000FE000000FE000000FE00000000000000000000000000
          000000000000000000000000000000000000000F0000000F0000000F0000000F
          0000000F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000074190000741
          9000062C7700062C7700062C7700062C7700062C770000000000000000000000
          00000000000000000000000000000000000000000000105AA30076E5FF00C8F3
          FF0076E5FF0036C2FE0001ACF4000494F1000494F100062C7700000000000000
          000000000000000000000000000000000000000000001863AD0076E5FF00C8F3
          FF0076E5FF0038D4FE0001ACF4000494F1000494F100062C7700000000000000
          000000000000000000000000000000000000000000001E79BD0076E5FF00C8F3
          FF0076E5FF0038D4FE0014BCFE0001ACF4000494F100062C7700CC520B00CC52
          0B00CC520B00CC520B00C6510A00C6510A00C6510A002593D00076E5FF00E1FA
          FF0076E5FF0038D4FE0014BCFE0001ACF4000494F100062C7700DA661900FFF8
          DD00FFF8DD00FFFAE400FFF8DD00FFF8DD00FFFAE4002593D00076E5FF00E1FA
          FF0076E5FF0038D4FE0014BCFE0001ACF40001ACF400062C7700E3691C00FFFA
          E400FFFAE400FFFAE400FFFAE400FFFAE400FFFAE40032BBE9005DB4E600529F
          D5003D93B6001863AD000741900007419000062C770007419000E3691C00FADD
          B400FADDB400FADDB400FADDB400FADDB400FADDB40032BBE90076E5FF00E1FA
          FF0076E5FF0038D4FE0014BCFE0001ACF40001ACF40007419000E6752300FFFE
          F100FFFEF100FFFFF500FFFEF100FFFEF100FFFFF5002CCEFB0064CBEA0079BB
          E500529FD5001E79BD000755AB00074190000741900007419000E6752300FFFF
          F500FFFFF500FFFFF500FFFFF500FFFFF500FFFFF50038D4FE00F7FEFF00FFFF
          FF00F7FEFF00E1FAFF00C8F3FF00B2ECFF008EDCFF00043EA700ED7E2A00FADE
          C000FADEC000FADEC000FADEC000FADEC000FADEC000FADEC00064CBEA0095CD
          DF0064CBEA0032BBE9000CA4E6000887DD000887DD0000000000ED7E2A00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00DA78220000000000000000000000000000000000EE862E00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00E675230000000000000000000000000000000000EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A0000000000000000000000000000000000F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00F1963C0000000000000000000000000000000000F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A3510000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FF010000FE000000FE000000FE00000000000000000000000000
          000000000000000000000000000000010000000F0000000F0000000F0000000F
          0000000F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000AA5605009F4E
          05009F4E05009F4E05009F4E05009F4E05009F4E050090480700904807009048
          0700904807009048070090480700904807009048070090480700AA560500FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0090480700AA560500FFFF
          FF00FFF5EB00FFF5EB00FFF5EB00FFF4E700FFF4E700FEF2E400FEF2E400FEF2
          E400FDEEDC00FDEEDC00FDEEDC00FDEEDC00FFFFFF0090480700AA560500FFFF
          FF00FFF9F200FEF7EF00FEF7EF00FFF5EB00FFF5EB00FFF5EB00FFF4E700FFF4
          E700FEF2E400FEF2E400FEF2E400FEF2E400FFFFFF0090480700AA560500FFFF
          FF00FFFAF500FFFAF500FFF9F200FFF9F200FEF7EF00FEF7EF00FFF5EB00FFF5
          EB00FFF5EB00FFF4E700FFF4E700FEF2E400FFFFFF0090480700B55D0500FFFF
          FF00FFFDFA00FFFCF700FFFCF700FFFAF500FFFAF500FFF9F200FFF9F200FEF7
          EF00FEF7EF00FEF7EF00FFF5EB00FFF5EB00FFFFFF0090480700B55D0500FFFF
          FF00FFFDFB00FFFDFB00FFFDFA00FFFDFA00FFFCF700FFFCF700FFFAF500FFFA
          F500FFF9F200FFF9F200FEF7EF00FEF7EF00FFFFFF009F4E0500B55D0500FFFF
          FF00FFFFFF00FFFFFE00FFFFFE00FFFDFB00FFFDFB00FFFDFA00FFFDFA00FFFC
          F700FFFCF700FFFAF500FFFAF500FFFAF500FFFFFF009F4E0500C1640600FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009F4E0500C1640600EDB7
          8300EDB78300EDB78300EDB78300EDB78300EDB78300EDB78300EDB78300EDB7
          8300EDB78300EDB78300EDB78300EDB78300EDB78300AA560500C1640600EA9E
          5400EA9E5400EA9E5400EA9E5400EA9E5400EA9E5400EA9E5400EA9E5400EA9E
          5400EA9E5400F5CFAA00F5CFAA00F5CFAA00F5CFAA00AA560500C1640600E68C
          3400E68C3400E68C3400E68C3400E68C3400E68C3400E68C3400E68C3400E68C
          3400E68C3400F6C797001C1CE6001C1CE600F6C79700AA560500C1640600DA78
          2200DA782200DA782200DA782200DA782200DA782200DA782200DA782200DA78
          2200DA782200E8C095001C1CE6001C1CE600E8C09500B55D0500C1640600CB6D
          1100CB6D1100CB6D1100CB6D1100CB6D1100CB6D1100CB6D1100CB6D1100CB6D
          1100CB6D1100EDB78300EDB78300EDB78300EDB78300B55D050000000000E9A9
          6B00E9A96B00E9A96B00E9A96B00E9A96B00E9A96B00E9A96B00E9A96B00E9A9
          6B00E9A96B00E9A96B00E9A96B00E9A96B00E9A96B0000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000080010000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000050505004747470000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00003F3E3E004E4E4E0055555500979897000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFFFF00F7F7F700BCBBBA0097989700CFCFCF00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFFFF00FFFFFF00F7F7F700C4D8E7002372D1000755AB000000
          0000000000000000000000000000000000000000000000000000CC520B00CC52
          0B00CC520B00D0652700FFFAF500E1FAFF0036C2FE00268AF3001563C5000755
          AB00000000000000000000000000000000000000000000000000DA661900FFF8
          DD00FFF8DD00FFFAE400F0F9F20049D9FF0036C2FE002AB4FD00268AF3001563
          C5000755AB000000000000000000000000000000000000000000E3691C00FFFA
          E400FFFAE400FFFAE400FFFAE40099E7FD0038D4FE0036C2FE002AB4FD00268A
          F3001563C5000755AB0000000000000000000000000000000000E3691C00FADD
          B400FADDB400FADDB400FADDB400FADDB40095CDDF0038D4FE0036C2FE002AB4
          FD00268AF3001563C5000755AB00000000000000000000000000E6752300FFFE
          F100FFFEF100FFFFF500FFFEF100FFFEF100FFFFF50099E7FD0038D4FE0036C2
          FE002AB4FD00268AF3001563C5000755AB000000000000000000E6752300FFFF
          F500FFFFF500FFFFF500FFFFF500FFFFF500FFFFF500FFFFF50099E7FD0038D4
          FE0036C2FE002AB4FD00268AF3002372D100A7A9A90000000000ED7E2A00FADE
          C000FADEC000FADEC000FADEC000FADEC000FADEC000FADEC000FADEC00095CD
          DF0038D4FE0036C2FE002AB4FD006869690033333300A7A9A900ED7E2A00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF0099E7FD0044CEFB009D8EA6008A8A8A007272720051515100EE862E00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00C0937400CFCFCF00CFCFCF00BCBBBA0000000000EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00E3E3E100E3E3E1000000000000000000F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00F1963C0000000000000000000000000000000000F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A3510000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000CFFF0000C3FF0000E0FF0000E07F0000003F0000001F0000000F
          000000070000000300000001000000000000000000000001000000030000000F
          0000000F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000887DD000CA4E6000887DD001563C5004A6FC200788FCB000000
          0000000000000000000000000000788FCB0079BBE500000000000000000032BB
          E90001BFF30001ACF40001ACF40001ACF40001ACF4000494F1000265D1004654
          B2000000000000000000788FCB005DB4E60000000000000000000000000021C5
          FE0001BFF30001ACF40001ACF40001ACF40001ACF4000494F1000494F100006C
          E900043EA7003D93B6005DB4E60000000000000000000000000065D4F0002CCE
          FB0001BFF30001ACF40001ACF40001ACF40001ACF4000494F100006CE9000055
          ED000265D100161993000000000000000000000000000000000065D4F00021C5
          FE0001BFF30001ACF40001ACF40001BFF30001BFF3000494F1000055ED000055
          ED000055ED000265D1003939A00000000000000000000000000065D4F00013B7
          F60001ACF40001ACF40001BFF30001BFF30016C6F30001ACF400006CE9000055
          ED00006CE9000494F1000144B70000000000000000000000000073CFF00013B7
          F60001ACF40001ACF40001BFF30011AFEA005DB4E60059D1F20013B7F6000494
          F1000494F1000494F1000265D1001863AD0000000000000000000000000032BB
          E9000EB4F1000EB4F10016C6F3000265D1000027A2002593D00059D1F20001AC
          F4000494F1000494F1000494F100043EA70000000000000000000000000065D4
          F00044CEFB002CCEFB002CCEFB00595234001863AD000027A20044CEFB0001BF
          F3000494F1000494F10001ACF4000550B9000000000000000000000000000000
          000059D1F20044CEFB00C164060097A883000265D1000265D10001BFF30001BF
          F30001ACF40001ACF40001ACF4000550B9000000000000000000000000000000
          000000000000B55D0500B2BA8B002CCEFB0016C6F30001BFF30001BFF30001BF
          F30001BFF30001BFF30001BFF3001048B8000000000000000000000000002727
          270000000000151515002CCEFB002CCEFB0016C6F3000CA4E60016C6F30001BF
          F30001BFF30001BFF30001ACF4001E79BD000000000000000000555555000707
          070015151500A7A9A9000000000044CEFB0044CEFB00000000000000000038D4
          FE0001BFF30001BFF30032BBE900000000000000000000000000000000009798
          97004E4E4E000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000E07900008033000080070000000F0000000700000007
          0000000300008003000080030000C0030000E003000080030000098700001FFF
          0000FFFF0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000007018000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000007018000070180000000000000000000000000000000000000000000000
          0000000000000000000000000000007018000070180000701800007018000070
          18000070180057B66E0000701800000000000000000000000000000000000000
          00000000000000000000000000000387220061D59E0061D59E0061D59E0061D5
          9E0057B66E0057B66E0057B66E00007018000000000000000000C0937400C093
          7400B3816200B3816200B38162000387220077E7B50025C4770025C4770025C4
          770015A7540015A7540015A7540057B66E000070180000000000D5AE9300EFE5
          D000EFE5D000E9D6C000D5AE93000387220077E7B50037DA920037DA920025C4
          770025C4770025C4770015A7540015A7540057B66E0000701800D5AE9300EFE5
          D000E2CAB300C0937400B38162000387220088EEC20037DA920037DA920037DA
          920037DA920025C4770025C4770061D59E000070180000000000DABBA100E9D6
          C000CDA18500DABBA100EFE5D0000387220088EEC20088EEC20088EEC20077E7
          B50077E7B50077E7B50061D59E00007018000000000000000000DABBA100DEC1
          A800D5AE9300EFE5D000EFE5D000038722000387220003872200038722000387
          22000387220077E7B50003872200000000000000000000000000DEC1A800D5AE
          9300DEC1A800E9D6C000CDA18500C0937400CDA18500EFE5D000EFE5D000C093
          7400038722000387220000000000000000000000000000000000DEC1A800D5AE
          9300DEC1A800EFE5D000E9D6C000DABBA100C0937400EFE5D000EFE5D000C093
          740003872200B381620000000000000000000000000000000000DEC1A800DEC1
          A800D5AE9300EFE5D000EFE5D000E9D6C000CDA18500EFE5D000EFE5D000B381
          6200D5AE9300B381620000000000000000000000000000000000DABBA100E9D6
          C000D5AE9300E2CAB300EFE5D000EFE5D000E9D6C000EFE5D000DABBA100C093
          7400E9D6C000B381620000000000000000000000000000000000DABBA100EFE5
          D000E2CAB300D5AE9300D5AE9300DEC1A800DEC1A800D5AE9300CDA18500E2CA
          B300EFE5D000B381620000000000000000000000000000000000DABBA100EFE5
          D000EFE5D000E9D6C000DEC1A800D5AE9300D5AE9300DEC1A800EFE5D000FBEB
          D600FBEBD600B381620000000000000000000000000000000000D5AE9300DABB
          A100D5AE9300D5AE9300CDA18500CDA18500CDA18500CDA18500C0937400C093
          7400C0937400B076520000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFDF0000FFCF0000F8070000F803000000010000000000000001
          00000003000000070000000F0000000F0000000F0000000F0000000F0000000F
          0000000F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000007018000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000007018000070180000000000000000000000000000000000000000000000
          0000000000000000000000000000007018000070180000701800007018000070
          18000070180057B66E0000701800000000000000000000000000000000000000
          00000000000000000000000000000387220061D59E0061D59E0061D59E0061D5
          9E0057B66E0057B66E0057B66E00007018000000000000000000CC520B00CC52
          0B00CC520B00CC520B00C6510A000387220077E7B50025C4770025C4770025C4
          770015A7540015A7540015A7540057B66E000070180000000000DA661900FFF8
          DD00FFF8DD00FFFAE400FFF8DD000387220077E7B50037DA920037DA920025C4
          770025C4770025C4770015A7540015A7540057B66E0000701800E3691C00FFFA
          E400FFFAE400FFFAE400FFFAE4000387220088EEC20037DA920037DA920037DA
          920037DA920025C4770025C4770061D59E000070180000000000E3691C00FADD
          B400FADDB400FADDB400FADDB4000387220088EEC20088EEC20088EEC20077E7
          B50077E7B50077E7B50061D59E00007018000000000000000000E6752300FFFE
          F100FFFEF100FFFFF500FFFEF100038722000387220003872200038722000387
          22000387220077E7B50003872200000000000000000000000000E6752300FFFF
          F500FFFFF500FFFFF500FFFFF500FFFFF500FFFFF500FFFFF500FFFFF500FFFF
          F500038722000387220000000000000000000000000000000000ED7E2A00FADE
          C000FADEC000FADEC000FADEC000FADEC000FADEC000FADEC000FADEC000FADE
          C00003872200DA66190000000000000000000000000000000000ED7E2A00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00DA78220000000000000000000000000000000000EE862E00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00E675230000000000000000000000000000000000EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A0000000000000000000000000000000000F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00F1963C0000000000000000000000000000000000F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A3510000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFDF0000FFCF0000F8070000F803000000010000000000000001
          00000003000000070000000F0000000F0000000F0000000F0000000F0000000F
          0000000F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000008484840084848400848484008484
          8400848484008484840084848400848484008484840084848400000000000000
          000000000000000000000000000084848400C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400000000000000
          0000000000008484840084848400FF000000C6C6C600FFFFFF0000FFFF00FFFF
          FF00FFFFFF00FFFFFF0000FFFF00FFFFFF00C6C6C60084848400000000000000
          000084848400FF000000FF000000FF000000C6C6C600FFFFFF00FFFFFF00FFFF
          FF0000FFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60084848400000000008484
          8400FF000000FF000000FF000000FF000000C6C6C600FFFFFF0000FFFF008484
          84008484840084848400C6C6C600FFFFFF00C6C6C60084848400000000008484
          8400FF000000FF000000FF000000FF000000C6C6C600FFFFFF0084848400FF00
          0000FF000000FF00000084848400FFFFFF00C6C6C6008484840084848400FF00
          0000FF000000FF000000FF000000FF000000C6C6C600FFFFFF0084848400C6C6
          C60084848400FF00000084848400FFFFFF00C6C6C6008484840084848400FF00
          0000FF000000FF0000008484840084848400C6C6C600FFFFFF0084848400FFFF
          FF00C6C6C6008484840084848400FFFFFF00C6C6C6008484840084848400FF00
          0000FF000000848484008484840084848400C6C6C600FFFFFF0000FFFF008484
          84008484840084848400C6C6C600FFFFFF00C6C6C6008484840084848400FF00
          0000FF000000848484008484840084848400C6C6C600FFFFFF00FFFFFF00FFFF
          FF0000FFFF00FFFFFF008484840084848400848484008484840084848400FF00
          0000FF000000C6C6C6008484840084848400C6C6C600FFFFFF0000FFFF00FFFF
          FF00FFFFFF00FFFFFF00C6C6C600FFFFFF00C6C6C6000000000000000000C6C6
          C600FF000000FF000000FFFFFF00C6C6C600C6C6C600FFFFFF00FFFFFF00FFFF
          FF0000FFFF00FFFFFF00C6C6C600C6C6C600000000000000000000000000C6C6
          C600FF000000FFFFFF00C6C6C600FFFFFF00C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C600C6C6C600C6C6C600848484000000000000000000000000000000
          0000C6C6C600FF000000FF000000C6C6C600FFFFFF00C6C6C600848484008484
          8400848484008484840084848400000000000000000000000000000000000000
          000000000000C6C6C600C6C6C600FF000000FF000000FFFFFF00C6C6C6008484
          8400848484008484840000000000000000000000000000000000000000000000
          0000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FC000000F8000000E0000000C000000080000000800000000000
          0000000000000000000000000000000100008003000080030000C0070000E00F
          0000F83F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000084848400C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000000
          0000FF00000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000FF00
          00008400000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000848400FF00
          00000000000084000000FF000000FF000000FF000000FF00000084000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000008484000084
          840084000000FF000000FF000000C6C6C600C6C6C60084000000FF0000008400
          0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000848400C6C6
          C60084000000FF00000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000084
          840000FFFF00FF000000FF000000FF000000FF000000FF000000FF0000008400
          0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000000
          00000084840000FFFF00FF000000FFFFFF00FFFFFF0084000000FF0000008400
          0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000000
          0000000000000084840000FFFF00FF000000FF000000FF00000084000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000000
          00000000000084848400FF000000FF000000FF00000084000000FFFFFF00FF00
          0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFF
          FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00C6C6C600FFFFFF008484840000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00C6C6C600848484000000000000000000000000000000
          0000000000008484840084848400848484008484840084848400848484008484
          8400848484008484840084848400000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000E0000000E0000000E0000000C000000080000000000000000000
          00000000000080000000C0000000E0000000E0000000E0000000E0010000E003
          0000E0070000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000008484840084848400848484008484
          8400848484008484840084848400848484008484840000000000000000000000
          0000000000000000000000000000FF00000084848400FFFFFF0000FFFF00FFFF
          FF00FFFFFF00FFFFFF0000FFFF00FFFFFF008484840000000000000000000000
          000000000000FF000000FF000000FF00000084848400FFFFFF00FFFFFF00FFFF
          FF0000FFFF00FFFFFF00FFFFFF00FFFFFF008484840000000000000000000000
          0000FF000000FF000000FF000000FF00000084848400FFFFFF0000FFFF008400
          0000840000008400000084848400FFFFFF008484840000000000000000000000
          0000FF000000FF000000FF000000FF00000084848400FFFFFF0084840000FF00
          0000FF000000FF00000084000000FFFFFF00848484000000000000000000FF00
          0000FF000000FF000000FF000000FF00000084848400FFFFFF00848400008484
          840000840000FF00000084000000FFFFFF00848484000000000000000000FF00
          0000FF000000FF000000008400000084000084848400FFFFFF0084840000FFFF
          FF00848484000084000084000000FFFFFF00848484000000000000000000FF00
          0000FF00000000840000008400000084000084848400FFFFFF0000FFFF008484
          0000848400008484000084848400FFFFFF00848484000000000000000000FF00
          0000FF00000000840000008400000084000084848400FFFFFF00FFFFFF00FFFF
          FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FF00
          0000FF00000000000000008400000084000084848400FFFFFF0000FFFF00FFFF
          FF00FFFFFF00FFFFFF0084848400FFFFFF008484840000000000000000008484
          8400FF000000FF000000FFFFFF000000000084848400FFFFFF00FFFFFF00FFFF
          FF0000FFFF00FFFFFF0084848400848484000000000000000000000000008484
          8400FF000000FFFFFF0000000000FFFFFF008484840084848400848484008484
          8400848484008484840084848400000000000000000000000000000000000000
          000084848400FF000000FF00000000000000FFFFFF0000000000008400000084
          0000008400000084000000000000000000000000000000000000000000000000
          0000000000008484840084848400FF000000FF000000FFFFFF00000000000084
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000848484008484840084848400848484008484
          8400000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FC000000F8000000E0000000C000000080000000800000000000
          0000000000000000000000000000100100008403000088030000C5070000E08F
          0000F83F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000008484840084848400848484008484840084848400848484008484
          8400848484008484840084848400848484008484840000000000000000000000
          00000000000084848400C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C6008484840000000000000000000000
          0000FF00000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C600848484000000000000000000FF00
          0000000000000000000000000000848400008484000084840000FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C600848484000000000000848400FF00
          000084000000FF000000FF000000FF000000FF000000FF00000084840000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000848484008484
          840084000000FF000000FF000000C6C6C600C6C6C600FF000000FF0000008484
          0000FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000848484008484
          840084840000FF00000084840000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000008484
          8400C6C6C600FF00000084840000848400008484000084840000848400008484
          0000FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000008400
          000084848400C6C6C60084840000FFFFFF00FFFFFF00FF000000FFFF00008484
          0000FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000000000
          00008400000084848400C6C6C600FF000000FF000000FFFF000084840000FFFF
          FF00FFFFFF00FFFFFF00C6C6C600848484008484840000000000000000000000
          0000000000008400000084840000848400008484000084840000FFFFFF00FF00
          0000FFFFFF00C6C6C60084848400848484008484840000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF008484000084840000FFFF
          FF00FFFFFF008484840000000000000000000000000000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF0084848400FFFFFF00848484000000000000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF008484840084848400000000000000000000000000000000000000
          0000000000008484840084848400848484008484840084848400848484008484
          8400848484008484840000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000E0010000E0010000C0010000A0010000000100000001
          0000000100008001000080010000C0010000E0010000E0010000E0030000E007
          0000E00F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008484
          8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF0084840000848400008484000084840000848400008484
          0000848400008484000084840000FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF0084840000848400008484000084840000848400008484
          0000848400008484000084840000FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF00C6C6C600FFFFFF00FFFFFF0084000000840000008400
          0000FFFFFF00FFFFFF00C6C6C600FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFF000084000000FFFFFF00848400008484000000840000FF00
          000084000000FFFFFF0084000000FFFF0000FFFFFF0000000000000000008484
          8400C6C6C60084000000FFFFFF00FFFFFF0084840000FFFF0000848400000084
          000084000000FFFFFF00FFFFFF0084000000C6C6C60000000000000000008484
          8400FFFFFF00FFFF000084000000FFFFFF0084840000FFFFFF00FFFF00008484
          000084000000FFFFFF0084000000FFFF0000FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF00C6C6C600FFFFFF00FFFFFF0084840000848400008484
          0000FFFFFF00FFFFFF00C6C6C600FFFFFF00FFFFFF0000000000000000008484
          8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000008484
          8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00C6C6C600FFFFFF008484840000000000000000008484
          8400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00C6C6C600848484000000000000000000000000008484
          8400848484008484840084848400848484008484840084848400848484008484
          8400848484008484840084848400000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF00008000000080000000800000008000000080000000800000008000
          0000800000008000000080000000800000008000000080000000800100008003
          000080070000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000008484840000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000084848400C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000000000000000
          00000000000084848400FFFFFF00C6C6C600C6C6C600C6C6C600C6C6C600FFFF
          FF00C6C6C600C6C6C600C6C6C600FFFFFF00C6C6C60000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF0000840000848484000084
          000084848400FFFFFF00C6C6C600FFFFFF00C6C6C60000000000008400008484
          84000084000084848400008400008484840000840000FFFFFF00008400008484
          840000840000FFFFFF00C6C6C600FFFFFF00C6C6C60000000000848484000084
          000084848400008400008484840000840000FFFFFF0000840000848484000084
          0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C60000000000008400008484
          8400008400008484840000840000FFFFFF000084000084848400008400008484
          8400C6C6C600C6C6C600C6C6C600FFFFFF00C6C6C60000000000000000000084
          00008484840000840000FFFFFF00008400008484840000840000848484000084
          0000FFFFFF00FFFFFF00C6C6C600FFFFFF00C6C6C60000000000000000000000
          000000840000FFFFFF0000840000848484000084000084848400C6C6C600C6C6
          C600C6C6C600C6C6C600C6C6C600FFFFFF00C6C6C60000000000000000000084
          0000FFFFFF00008400008484840000840000848484000084000084848400C6C6
          C600FFFFFF00FFFFFF00C6C6C600FFFFFF00C6C6C6000000000000840000FFFF
          FF00008400008484840000840000848484000084000084848400008400008484
          8400C6C6C600C6C6C600C6C6C600FFFFFF00C6C6C60000000000848484000084
          0000848484000084000084848400FFFFFF008484840000840000848484000084
          0000FFFFFF00FFFFFF0000000000000000000000000000000000008400008484
          84000084000084848400FFFFFF00FFFFFF00FFFFFF0084848400008400008484
          8400FFFFFF00FFFFFF0084848400FFFFFF000000000000000000000000000000
          00000000000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF0084848400000000000000000000000000000000000000
          0000000000008484840084848400848484008484840084848400848484008484
          8400848484008484840084848400000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000E0000000E0000000E0000000E0000000E0000000000000000000
          00000000000080000000C000000080000000000000000000000000010000E003
          0000E0070000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000084848400C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00000000000000000000000000000000000000
          000000000000FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00000000000000000000000000000000000000
          000000000000FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00000000000000000000000000000000000000
          000000000000FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00000000000000000000000000FFFFFF000000
          000000000000FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000
          000084848400FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
          FF0000000000FFFFFF0000000000FFFFFF000000000000000000000000000000
          00000000000000000000FFFFFF0084848400FFFFFF0084848400FFFFFF008484
          8400FFFFFF0084848400FFFFFF00000000000000000000000000000000000000
          0000000000000000000000000000C0DCC00000000000C0DCC00000000000C0DC
          C00000000000C0DCC00000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000E0030000C0010000C0010000C0010000C0010000C0010000C001
          0000C0010000C0010000C0010000C0010000C0010000C0010000C0010000E003
          0000F0070000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
          000000000000000000008484840000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000084848400C6C6
          C600C6C6C600848484000000000084848400000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000084848400C6C6C600C6C6
          C600FFFF0000848484008484840000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6C600C6C6C600C6C6
          C600C6C6C60084848400C6C6C60000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6C600FFFF0000C6C6
          C600C6C6C60084848400C6C6C60000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000084848400FFFF0000FFFF
          0000C6C6C600848484008484840000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000084848400C6C6
          C600C6C6C600848484000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
          000000000000000000000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
          000000000000000000000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6
          C60000000000000000000000000000000000000000000000000000000000FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000000C0000000800000001000000030000000300000003
          0000000300000003000000070000000F0000000F0000000F0000001F0000003F
          0000007F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C60000000000C6C6C600000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000C6C6C600000000000000000000000000C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000FFFF0000FFFF0000FF
          FF00C6C6C600C6C6C6000000000000000000000000000000000000000000C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400848484008484
          8400C6C6C600C6C6C60000000000C6C6C6000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000C6C6C600C6C6C6000000000000000000C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C60000000000C6C6C60000000000C6C6C60000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000C6C6C60000000000C6C6C6000000000000000000000000000000
          000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF0000000000C6C6C60000000000C6C6C60000000000000000000000
          00000000000000000000FFFFFF00000000000000000000000000000000000000
          0000FFFFFF000000000000000000000000000000000000000000000000000000
          00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
          0000000000000000000000000000FFFFFF000000000000000000000000000000
          000000000000FFFFFF0000000000000000000000000000000000000000000000
          0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000C0070000800300000001000000010000000100000000
          00000000000080000000C0000000E0010000E0070000F0070000F0030000F803
          0000FFFF0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C60000000000C6C6C600000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000C6C6C600000000000000000000000000C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000FFFF0000FFFF0000FF
          FF00C6C6C600C6C6C6000000000000000000000000000000000000000000C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400848484008484
          8400C6C6C600C6C6C60000000000C6C6C6000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000C6C6C600C6C6C6000000000000000000C6C6
          C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
          C600C6C6C60000000000C6C6C60000000000C6C6C60000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000C6C6C60000000000C6C6C6000000000000000000000000000000
          000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF0000000000C6C6C60000000000C6C6C60084848400000000000000
          00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF0084840000FFFF0000FFFF0000FFFF000000000000000000008484
          8400000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF000084840000000000000000000084848400000000000000
          0000FFFF000084840000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
          0000FFFF0000FFFF000000000000000000000000000000000000000000008484
          8400000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF000084840000000000000000000084848400000000000000
          0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF008484840084840000FFFF0000FFFF0000FFFF000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000008484840000000000000000000000000084848400000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000C0070000800300000001000000010000000100000000
          00000000000080000000C0000000E0000000800000008007000080000000F000
          0000F8000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000331
          5F00022D58000229520002274D00000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000335
          6400FFFFFF000CA4FF0002285000000000000000000000000000EBAF5900E7A6
          4800E49D3800E0962B00DD8E2000DA8A1A00D8891900D6871800D48517000439
          6A00FFFFFF000DA6FF00032B5400000000000000000000000000ECB25B00FAE0
          A100F7D99600F4D18A00FBFBFB00FAFAFA00F9F9F900F8F8F80005457A0013B1
          FF0011ADFF000FA9FF000CA5FF00022A52000000000000000000EEB55F00FAE0
          A100F7D99600F4D18A00FDFDFD00FCFCFC00FBFBFB0007538C0017B8FF0015B4
          FF0012B0FF0010ACFF000EA8FF000CA4FF000229500000000000F0B76200FAE0
          A100F7D99600F4D18A00FEFEFE00FDFDFD000A629F00FFFFFF0018BAFF0016B6
          FF0005427500043B6B00FFFFFF000DA7FF000BA3FF0002284E00F2B96600FAE0
          A100F7D99600F4D18A00FFFFFF00FFFFFF000B6AA800FFFFFF001ABDFF00074F
          8700FAFAFA00F9F9F900043A6900FFFFFF000DA6FF00032B5300F4BC6800FAE0
          A100F7D99600F4D18A00FFFFFF00FFFFFF000D72B000FFFFFF001BBFFF000956
          8F00FCFCFC00FBFBFB00053F7000FFFFFF000EA8FF00032E5700F5BE6B00FAE0
          A100F7D99600F4D18A00FFFFFF00FFFFFF000F7BB900FFFFFF001CC2FF000A5D
          9700FDFDFD00FDFDFD0006447700FFFFFF0010ABFF0003315C00F6C16F00FAE0
          A100F7D99600F4D18A00FFFFFF00C7C7C700C7C7C7000E78B700FFFFFF000B65
          A000C7C7C700FEFEFE00074A7E00FFFFFF00053C6B0000000000F8C37200FAE0
          A100F7D99600F4D18A00FFFFFF00FFFFFF00FFFFFF00FFFFFF000E77B4000C6E
          A900FFFFFF00FFFFFF000851860006497C000000000000000000F9C57500FAE0
          A100F7D99600F4D18A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00E0911E00000000000000000000000000FAC77800FAE0
          A100F7D99600F4D18A00FFFFFF00C7C7C700C7C7C700C7C7C700C7C7C700C7C7
          C700C7C7C700FFFFFF00E2932000000000000000000000000000FBC97A00FAE0
          A100F7D99600F4D18A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00E4952100000000000000000000000000FCCB7D00FAE0
          A100F7D99600F4D18A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00E7972300000000000000000000000000FDCD8000FCC5
          6F00FBBE5F00F9B75000F8B14300F5AA3600F3A52D00F2A32A00F0A12900EE9F
          2800ED9D2700EB9B2600E99A2400000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FF870000FF870000000700000003000000010000000000000000
          0000000000000000000000010000000300000007000000070000000700000007
          000000070000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000009C4D12009A4C1100994A
          1000974A0F0096490F0000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000009E4E1400FFDCBE00FFD9
          B900FED5B300D4793A0097490F00000000000000000000000000000000000000
          00000000000000000000000000000000000000000000A1501500FFE1C700FFDE
          C200FEDBBD00D37A3A00D57B3C00984A10000000000000000000000000000000
          000010448F000F3C88000A358100062E7B00052B7600A4531600FFE5CE00FFE3
          CB00FFE1C600D27A3B00D47B3D00D77D3E00994B11000000000000000000105A
          A30076E7FF00C7F5FF0076E2FE0036C7FC0006A5F700A8551800FFE8D500FFE8
          D200FFE5CD00D27A3C00D47C3E005B2C09005A2B0900592B080000000000156A
          AF0076E7FF00CEF6FF0076E7FF0037D0FD0007B0FB00AB581A00FFECDA00FFEA
          D700FFE8D400D17A3C00D37C3E00D57F40009E4E13000000000000000000197A
          BC0076E7FF00D4F7FF0076E7FF0038D5FF0008B9FD00AF5B1C00FFEEDD00FFEC
          DC00FFEBD900D07A3C00D37D3F00D57F4100A151150000000000000000001F8B
          C90076E7FF00DAF9FF0076E7FF0038D5FF0009BFFF00B25E1E00FED4A700FED1
          A400FECE9F00FECB9B00D27D3F0065310A0063310A00622F0A0000000000259D
          D60076E7FF00E0FAFF0076E7FF0038D5FF0009BFFF0006B1FE00B45F1F00FED4
          A800FED1A400FECFA000FECB9B00D3804300A856190000000000000000002AAE
          E20056B6DF0061A1CD003783BA001665A800064C9700053D890005317C00B55F
          2000FED4A9006F370B00FECEA100FECB9C00AB581B0000000000000000002FBF
          ED0076E7FF00EBFCFF0076E7FF0038D5FF0009BFFF0006B1FE0004A4FE00043C
          9000B761210073390C00B35E1F00B15C1E00AF5B1C00000000000000000033C9
          F3005FC6EC0072B8DF00449BCE001B7BBD00065FAB00044C9B00053D8D000441
          980000000000773A0C00000000000000000000000000000000000000000036D1
          F800F7FEFF00FFFFFF00F7FEFF00E6FAFF00CBF1FF00B2E7FF0097D9FF000448
          A000000000000000000000000000000000000000000000000000000000000000
          000068CFED008DD3EB0065C9E80030B7E60008A2E4000695E0000488DE000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF0000FE0F0000FE070000FE030000C0010000800000008001
          00008001000080000000800100008001000080010000802F0000803F0000C07F
          0000FFFF0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CE530C00CD52
          0B00CB520B00CA510A00C8500A00C7500900C54F0900C44F0800C34E0700C24E
          0700C04D0600BF4C0600BE4C0500BC4B0500BB4B0400BA4A0400D2560E00FFEF
          C800FFEFC800FAD39C00FFEFC800FFEFC800FAD39C00FFEFC800FFEFC800FAD3
          9C00FFEFC800FFEFC800FAD39C00FFEFC800FFEFC800BD4C0500D6591100FFF2
          CE00FFF2CE00FAD5A000FFF2CE00FFF2CE00FAD5A000FFF2CE00FFF2CE00FAD5
          A000FFF2CE00FFF2CE00FAD5A000FFF2CE00FFF2CE00C04E0700DA5D1400FAD6
          A500FAD6A5000909BF000909BF00FAD6A500FAD6A500FAD6A500FAD6A500FAD6
          A500FAD6A500FAD6A500FAD6A500FAD6A500FAD6A500C4510900DD611700FFF8
          DD00FFF8DD000909BF000909BF00FFF8DD00FAD9AB00FFF8DD00FFF8DD00FAD9
          AB00FFF8DD00FFF8DD00FAD9AB00FFF8DD00FFF8DD00C7540C00E1661A00FFFA
          E400FFFAE400FADBAF00FFFAE400FFFAE400FADBAF00FFFAE400FFFAE400FADB
          AF00FFFAE4000909BF000909BF00FFFAE400FFFAE400CB580F00E46B1E00FADD
          B400FADDB400FADDB400FADDB400FADDB400FADDB400FADDB400FADDB400FADD
          B400FADDB4000909BF000909BF00FADDB400FADDB400CF5C1200E7712100FFFE
          F100FFFEF100FADDB900FFFEF100FFFEF100FADDB900FFFEF100FFFEF100FADD
          B900FFFEF100FFFEF100FADDB900FFFEF100FFFEF100D3611500EA762500FFFF
          F500FFFFF500FADEBB00FFFFF5000909BF000909BF00FFFFF500FFFFF500FADE
          BB00FFFFF500FFFFF500FADEBB00FFFFF500FFFFF500D7661800EC7B2800FADE
          BF00FADEBF00FADEBF00FADEBF000909BF000909BF00FADEBF00FADEBF00FADE
          BF00FADEBF00FADEBF00FADEBF00FADEBF00FADEBF00DA6C1C00EE812B00FFFF
          FF00FFFFFF00FADEC200FFFFFF00FFFFFF00FADEC200FFFFFF00FFFFFF00FADE
          C200FFFFFF00FFFFFF00FADEC200FFFFFF00FFFFFF00DE722000EF852E00FFFF
          FF00FFFFFF00FADEC200FFFFFF00FFFFFF00FADEC200FFFFFF00FFFFFF00FADE
          C200FFFFFF00FFFFFF00FADEC200FFFFFF00FFFFFF00E1772400EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00F1963C00F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000CE530C00CD52
          0B00CB520B00CA510A00C8500A00C7500900C54F0900C54F0900C54F0900C54F
          0900C54F0900C44F0800C34E0700C24E0700BC4B0500BA4A0400DD611700FDF3
          E000FDF3DF00FDF2DF00FDF2DF00FDF2DE00FDF2DE00FDF2DE00FDF1DD00FDF1
          DD00FDF1DD00FDF1DC00FDF0DC00FDF0DC00FDF0DB00C7540C00E1661A00FDF4
          E200FDF4E100FDF4E100FDF3E100FDF3E000FDF3E000FDF3E000FDF3DF00FDF2
          DF00FDF2DF000B04A1000C04A1000C05A100FDF1DD00CB580F00E46B1E00FEF5
          E300FEF5E300FEF5E300FEF5E200FEF4E200FDF4E200FDF4E200FDF4E100FDF4
          E100FDF3E1000C05A2000C04A2000B05A100FDF3DF00CF5C1200E7712100FEF6
          E500FEF6E500FEF7E800FEF6E400FEF6E4000C04A6000C04A5000C04A5000B04
          A500AAA2D500AAA1D300FDF4E200FDF5E400FDF4E100D3611500EA762500FEF8
          EA00FEF8EA00FEF8EA00FEF8E900FEF8E9000C05A8000D04A8000D04A8000D05
          A700FEF7E700AAA2D600FEF6E700FEF6E600FEF6E600D7661800EC7B2800FEF9
          F400FEF9F400FEF9F300FEF9F300FEF9F300AAA4DD00FEF8F200FEF8F200FEF8
          F100FEF8F100AAA4DD00FEF7F000FEF7F000FEF7EF00DA6C1C00EE812B00FEFA
          F600FEFAF600FEFAF600FEFAF500FEFAF5000D05AE000D05AE000D05AD000D05
          AD00AAA4DE00AAA4DE00FEF9F200FEF8F200FEF8F200DE722000EF852E00FEFC
          F800FEFBF800FEFBF700FEFBF700FEFBF7000D06B2000D06B1000D05B1000D05
          B000FEFAF500FEFAF500FEFAF500FEF9F400FEF9F400E1772400EF852E00FFFC
          FA000E05B8000E06B7000E05B700ABA6E200AAA6E100FEFCF800FEFBF800FEFB
          F700FEFBF700FEFBF700FEFBF700FEFAF600FEFAF600E1772400EF852E00FFFD
          FB000E06BB000E06BB000E06BA00FFFDFA00FFFDFA00FFFCFA00FFFCFA00FFFC
          F900FFFCF900FFFCF900FEFCF800FEFCF800FEFBF800E1772400EF8C2A00FFFE
          FD00FFFEFD00FFFEFC00FFFEFC00FFFDFC00FFFDFC00FFFDFB00FFFDFB00FFFD
          FB00FFFDFB00FFFDFA00FFFDFA00FFFCFA00FFFCFA00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00F1963C00F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000FFFF000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000005151510050505000505050004F4F4F004E4E4E004D4D
          4D004D4D4D004C4C4C004B4B4B004B4B4B004949490048484800000000000000
          000000000000000000005A5A5A00F3F3F300F3F3F300F3F3F300CFCFCF00F3F3
          F300F3F3F300CFCFCF00F3F3F300F3F3F300F3F3F3004E4E4E00000000000000
          000000000000000000005D5D5D00F4F4F400F4F4F400F4F4F400D0D0D000F4F4
          F400F3F3F300CFCFCF00F3F3F300F3F3F300F3F3F30052525200000000000000
          0000000000000000000061616100D0D0D000D0D0D000D0D0D000D0D0D000D0D0
          D000D0D0D000D0D0D000D0D0D000D0D0D000D0D0D00055555500CE530C00CD52
          0B00CB520B00CA510A0065656500F5F5F500F5F5F500F5F5F500D0D0D000F5F5
          F500F4F4F400D0D0D000F4F4F400F4F4F400F4F4F40059595900DD611700FFF8
          DD00FFF8DD00FFFAE40069696900F5F5F500F5F5F500F5F5F500D0D0D000F5F5
          F500F5F5F500D0D0D000F5F5F500F5F5F500F5F5F5005C5C5C00E1661A00FFFA
          E400FFFAE400FFFAE4006E6E6E00D1D1D100D1D1D100D1D1D100D1D1D100D1D1
          D100D1D1D100D0D0D000D0D0D000D0D0D000D0D0D00061616100E46B1E00FADD
          B400000000000000000000000000000000000000000000000000000000000000
          00000000000000000000F6F6F600F6F6F600F6F6F60065656500E7712100FFFE
          F10000000000FFFFFF00FFFFFF00A6A6A6000000000000000000A6A6A600FFFF
          FF00FFFFFF0000000000F6F6F600F6F6F600F6F6F60069696900EA762500FFFF
          F500000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
          000000000000000000008C8C8C008C8C8C008C8C8C0072727200EC7B2800FADE
          BF0000000000FFFFFF00FFFFFF00A6A6A6000000000000000000A6A6A600FFFF
          FF00FFFFFF0000000000BDBDBD00BDBDBD00BDBDBD007C7C7C00EE812B00FFFF
          FF00000000000000000000000000000000000000000000000000000000000000
          0000000000000000000089898900888888008888880087878700EF852E00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00E177240000000000000000000000000000000000EF8C2A00EF8C
          2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C2A00EF8C
          2A00EF8C2A00EF8C2A0000000000000000000000000000000000F1963C00FFC6
          7C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC67C00FFC6
          7C00FFC67C00F1963C0000000000000000000000000000000000F3A35100F3A3
          5100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A35100F3A3
          5100F3A35100F3A3510000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
        Mask.Data = {
          86000000424D86000000000000003E0000002800000010000000120000000100
          010000000000480000000000000000000000020000000000000000000000FFFF
          FF00FFFF0000F0000000F0000000F0000000F000000000000000000000000000
          00000000000000000000000000000000000000000000000F0000000F0000000F
          0000000F0000FFFF0000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000000000F0000
          001B00000025000000250000001B0000000F0000000000000000000000000000
          00000000000000000000000000000000000000000001002C056900530AB90070
          0EEA00700EEA00530AB9002D06760000002A0000001500000000000000000505
          0511101010351111113B1111113B1111113C07460FA300992CFF10C067FF1FE0
          95FF1FE095FF14C068FF03992EFF003E08940000002A0000000F2A130148893E
          05EC934104FF914003FF8F3F03FF555007FF00992CFF1BD888FF25EEA9FF25EE
          A9FF31EEAEFF42F0B4FF42DA96FF0F9A32FF002D06760000001B2A130148893E
          05EC934104FF914003FF8F3F03FF555007FF00992CFF1BD888FF25EEA9FF25EE
          A9FF31EEAEFF42F0B4FF42DA96FF0F9A32FF002D06760000001B893F04E4E2CA
          B8FFFFFFFFFFFFFFFFFFFFFFFFFF54A75EFF10C067FF25EEA9FF14C872FF0099
          2DFF04992EFF37CA7FFF73F3C7FF4CC47EFF00530AB9000000269C4904FFFFFF
          FFFFEFEFEFFFEFEFEFFFEFEFEFFF178725FF1FE095FF2BEEACFF01992EFFFFFF
          FFFF823302FF0A891BFF068518FF068518FF00740EEA00000000A04C05FFFFFF
          FFFFF0F0F0FFF0F0F0FFF0F0F0FF188725FF26E097FF3EF0B3FF07992FFFFFFF
          FFFF0A891BFF0A891BFF00000029000000000000000000000000A24E05FFFFFF
          FFFFF2F2F2FFF2F2F2FFF2F2F2FF50A35AFF21C16DFF56F1BDFF43CC84FF149A
          33FF1A9A36FF3EF0B3FF0A891BFF000000290000000000000000B66208FFFFFF
          FFFFF3F3F3FFF3F3F3FFF3F3F3FF9BC8A1FF0B9A30FF59DCA0FF3EF0B3FF3EF0
          B3FF3EF0B3FF3EF0B3FF3EF0B3FF0A891BFF0000002900000000B96509FFD4D4
          D4FFD4D4D4FFD4D4D4FFD4D4D4FFD3D4D3FF6AA871FF179B36FF5EC686FF3EF0
          B3FF3EF0B3FF3EF0B3FF3EF0B3FF3EF0B3FF0A891BFF00000000C06B0AFFC26D
          0BFFC26D0BFFC26D0BFFC88033FFC38846FFD3D4D3FF9ECBA3FF51A55BFF1989
          27FF10780EFF3EF0B3FF3EF0B3FF0A891BFF04310A5C000000002A170238C06B
          0AFFF8F8F8FFF8F8F8FFFFFFFFFFC0792AFFD4D4D4FFF8F8F8FFF8F8F8FFFFFF
          FFFF0A891BFF3EF0B3FF0A891BFF04310A5C00000000000000002A170238C06B
          0AFFF8F8F8FFF8F8F8FFFFFFFFFFC0792AFFD4D4D4FFF8F8F8FFF8F8F8FFFFFF
          FFFF0A891BFF3EF0B3FF0A891BFF04310A5C0000000000000000000000002A17
          0238C06B0AFFFEFEFEFFFFFFFFFFBC6709FFD4D4D4FFFAFAFAFFFAFAFAFFFFFF
          FFFF0A891BFF0A891BFF04310A5C000000000000000000000000000000000000
          000052433261C06B0AFFFFFFFFFFBC6709FFD4D4D4FFFBFBFBFFFBFBFBFFFFFF
          FFFFAB5707FF1515153B00000000000000000000000000000000000000000000
          00002121212445352354C06B0AFFBC6709FFD4D4D4FFFCFCFCFFFCFCFCFFEBD5
          BFFFA05309ED1313133500000000000000000000000000000000000000000000
          000014141416141414163B2A1649BE701DFFBB6D1CFFBA6B1CFFB96B1CFF914F
          0BD538240F620505050F00000000000000000000000000000000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000090000001C0000001F0000001F0000001F0000001F0000
          001F0000001F0000001F0000001F0000001C0000000900000000000000000000
          000028120148803803EA8B3C03FF893B02FF883A02FF863902FF853702FF8436
          01FF823602FF813401FF742E01EA240E005E0000001C00000000000000000000
          0000843D04E4E0CAB8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFDCC6B8FF742F01E70000001F00000000000000000000
          0000843D04E4E0CAB8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFDCC6B8FF742F01E70000001F00000000000000000000
          0000994805FFFFFFFFFF3388F3FF2C81EBFFFFFFFFFFD76519FFD05E12FFFFFF
          FFFF009F11FF009F11FFFFFFFFFF863802FF0000001F00000000000000000000
          00009F4C05FFFFFFFFFF378CF6FF3185F0FFFFFFFFFFDC6A1EFFD46216FFFFFF
          FFFF009F11FF009F11FFFFFFFFFF8A3B03FF0000001F00000000000000000000
          0000A45107FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF8F4003FF0000001F00000000000000000000
          0000A95507FFFFFFFFFF3A8FFAFF388DF7FFFFFFFFFFE57326FFDE6C1FFFFFFF
          FFFF04A315FF00A011FFFFFFFFFF944404FF0000001F00000000000000000000
          0000AE5A08FFFFFFFFFF3A8FFAFF3A8FFAFFFFFFFFFFEA782BFFE27024FFFFFF
          FFFF07A618FF02A213FFFFFFFFFF9A4805FF0000001F00000000000000000000
          0000B15C08FFEBD5BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFE7D1BFFF9F4D06FF0000001F00000000000000000000
          0000B45F09FFB45F09FFB35D09FFB15D09FFB05B08FFAF5908FFAD5807FFAB58
          07FFAA5607FFA85407FFA65306FFA55107FF0000001F00000000000000000000
          0000B66009FFD19C66FFD19C66FFD09B66FFCF9A65FFCF9965FFCE9965FFCE98
          65FFCC9764FFCC9765FFCB9664FFA95507FF0000001C00000000000000000000
          0000B66009FFD19C66FFD19C66FFD09B66FFCF9A65FFCF9965FFCE9965FFCE98
          65FFCC9764FFCC9765FFCB9664FFA95507FF0000001C00000000000000000000
          0000A55708E7B66009FFC1782FFFC1782EFFC1782FFFC1782EFFC0772FFFBE76
          2DFFBE752EFFBD752EFFAF5A08FF9D5106E90000000800000000000000000000
          00002D18023F8F4C07C9B66009FFB66009FFB66009FFB66009FFB66009FFB660
          09FFB55F08FFB45E09FF8D4A07C92C17023F0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000003600000013CE03
          64FFCE0364FF0000003600000024000000130000003600000000000000000000
          000000000000000000000000000000000000CE0364FF4A01247F8B0243BDCE03
          64FFCE0364FF8B0243BD4A01247FCE0364FF0000003600000036000000000000
          0000000000000000000000000000CE0364FFCE0364FFCE0364FFCE0364FFCE03
          64FFCE0364FFCE0364FFCE0364FFCE0364FFCE0364FF00000013000000000000
          00000000000000000000000000004A01245CCE0364FFCE0364FFCE0364FFCE03
          64FFCE0364FFCE0364FFCE0364FFCE0364FF4A01247F00000024000000000000
          00000000000000000000000000004A01245CCE0364FFCE0364FFCE0364FFCE03
          64FFCE0364FFCE0364FFCE0364FFCE0364FF4A01247F00000024000000000000
          00000000000000000000000000008B0243BDCE0364FFCE0364FFAC0353DD4D01
          256C4D01255FAB0253D4CE0364FFCE0364FF8B0243BD00000036000000000000
          00000000000000000000CE0364FFCE0364FFCE0364FFCE0364FF4D0125810000
          0014000000004D01255FCE0364FFCE0364FFCE0364FFCE0364FF000000000000
          000C0000002500000029CE0364FFF89BC6FFF89BC6FFD51C74FF55213A950000
          004B0000001F55213A6CD51C74FFF89BC6FFF89BC6FFCE0364FF2B140248873E
          06EA924305FF8F4104FF8D3E04FFB71544FFF288BAFFE0458FFFC73470FC6625
          37B3551D3793B72F70DDE0458FFFF288BAFF8B0243BD000000138E4708E4DCC0
          A8FFFFFFFFFFFFFFFFFFFFFFFFFFEDA4C7FFED73ACFFEA68A5FFDD3B88FFD316
          70FFD31570FFDD3B88FFEA68A6FFCE0364FF56293E7F00000036A7550BFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFCE0364FFE65D9EFFCE0364FFE65D9EFFE65D
          9EFFE65D9EFFE75D9EFFCE0364FFE75D9EFFCE0364FF00000000A7550BFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCE0364FFEDA4C7FFDE5697FFE047
          90FFE04790FF8B0243BD4A01245CCE0364FF0000000000000000AD5B0EFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCE03
          64FFCE0364FF0000000000000000000000000000000000000000AD5B0EFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCE03
          64FFCE0364FF0000000000000000000000000000000000000000B3610FFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9949
          07FF000000290000000000000000000000000000000000000000B86510FFB664
          10FFB46210FFB2610FFFB05E0EFFAB5A0DFFA9580CFFA6560CFFA4530BFFA151
          0AFF000000250000000000000000000000000000000000000000A85D0FE7B967
          11FFB96611FFB76511FFB66310FFB2600FFFB05E0EFFAD5C0DFFAA5A0DFF974F
          0BEA0000000A00000000000000000000000000000000000000002E19043F9251
          0DC9B96711FFB96711FFB96711FFB66510FFB56410FFB3620FFF8C4B0CC92B17
          033F000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          00000000000C0000002100000021000000210000002100000021000000210000
          002100000021000000210000001E000000100000000000000000000000003819
          005EAB5F15FFB26623FFB5743DFFB98150FFBD8C5FFFBE8D61FFBD8C60FFBD8B
          5CFFB87D45FFAD6F2DF65228008D00000019000000000000000000000000A747
          00FDC66200FFD0732AFFD89462FFE5C0A5FFF4E3DAFFFDFCFBFFFEFEFEFFFBEA
          D6FFEAB986FFD78327FF964900CC00000020000000000000000000000000AD49
          00FFC66200FFD1742AFFD99461FFE5BDA6FFF4E4DCFFFEFDFCFFF0F0F0FFE2D2
          C0FFC99F73FFBA7220FFA95300F800000029000000000000000000000000AD49
          00FFC66200FFD1742AFFD99461FFE5BDA6FFF4E4DCFFFEFDFCFFF0F0F0FFE2D2
          C0FFC99F73FFBA7220FFA95300F800000029000000000000000000000000AC51
          00EBD47623FFDA894EFFE9BD9EFFF1D9CAFFF9F1EBFF96C29BFF469A51FF1584
          21FF14811BFF3E7D1DFF5A5A06EC000000370000001500000000000000003819
          005EAE5807FFC16F31FFD4AC92FFDBC7B7FF6BA56CFF00992CFF10C067FF1FE0
          95FF1FE095FF14C068FF03992EFF003E08A00000002A0000000F00000000A747
          00FDC66200FFD0732AFFE1AC86FF96B07CFF00992CFF1BD888FF25EEA9FF25EE
          A9FF31EEAEFF42F0B4FF42DA96FF0F9A32FF002D06760000001B00000000AD49
          00FFC66200FFD1742AFFE2AC85FF4D9647FF10C067FF25EEA9FF14C872FF0099
          2DFF04992EFF37CA7FFF73F3C7FF4CC47EFF00530AB90000002600000000AC51
          00EBD47623FFDA894EFFE9BD9EFF188521FF1FE095FF2BEEACFF01992EFFFFF7
          EBFFF3CB9EFF0A891BFF068518FF068518FF00740EEA00000000000000003819
          005EAE5807FFC16F31FFD4AC92FF168320FF26E097FF3EF0B3FF07992FFFE3DA
          D0FF0A891BFF0A891BFF4522009F0000001C000000000000000000000000A747
          00FDC66200FFD0732AFFE1AC86FF4D9747FF21C16DFF56F1BDFF43CC84FF149A
          33FF1A9A36FFB9F9E4FF0A891BFF00000044000000000000000000000000AD49
          00FFC66200FFD1742AFFE2AC85FF96AF7CFF0B9A30FF59DCA0FF8BF5D1FFB9F9
          E4FFB9F9E4FFB9F9E4FFB9F9E4FF0A891BFF000000290000000000000000AD49
          00FFC66200FFD1742AFFE2AC85FF96AF7CFF0B9A30FF59DCA0FF8BF5D1FFB9F9
          E4FFB9F9E4FFB9F9E4FFB9F9E4FF0A891BFF000000290000000000000000AC51
          00EBD47623FFDA894EFFE9BD9EFFF0D9C9FF7DB67DFF179B36FF5EC686FFA4EA
          CAFFB9F9E4FFB9F9E4FFB9F9E4FFB9F9E4FF0A891BFF00000000000000003819
          005E582D0581844D23AFC59576F4CAAA92F3DAC8B9FE8FB07FFF499648FF1683
          1FFF137F18FEB9F9E4FFB9F9E4FF0A891BFF04310A5C00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000A891BFFB9F9E4FF0A891BFF04310A5C0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000A891BFF0A891BFF04310A5C000000000000000000000000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          000C000000250000002900000029000000290000002900000029000000290000
          00250000000C00000000000000000000000000000000000000002B140248873E
          06EA924305FF8F4104FF8D3E04FF893A03FF873902FF853702FF783001EB250F
          00650000002500000000000000000000000000000000000000008E4708E4DCC0
          A8FFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBCBCBCFFFFFFFFFFD5B9A6FF7932
          02E8000000290000000000000000000000000000000000000000A7550BFFFFFF
          FFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFF8B3D
          04FF000000290000000000000000000000000000000000000000A7550BFFFFFF
          FFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFF8B3D
          04FF000000290000000000000000000000000000000000000000A7550BFFBCBC
          BCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFF8B3D
          04FF000000290000000000000000000000000000000000000000AD5B0EFFFFFF
          FFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBCBCBCFFFFFFFFFFF3F3F3FF853D
          05FF000000420000001E000000160000000C0000000000000000B3610FFFFFFF
          FFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBBBCBCFF98C5E8FF499CDDFF0D75
          C8FF006FC7ED005394B6002C5071000101220000001100000000B86510FFB664
          10FFB46210FFB2610FFFB05E0EFFAA5A0EFF506874FF409CE6FF99CAF1FFE0EF
          FBFFE0EFFBFF99CAF1FF409CE6FF003E6F90000101220000000CA85D0FE7B967
          11FFB96611FFB76511FFB66310FF726A59FF409CE6FFCCE5F8FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFCCE5F8FF409CE6FF002C5071000000162E19043F9251
          0DC9B96711FFB96711FFB96711FF3C7499FF99CAF1FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF99CAF1FF005394B60000001E000000000000
          0000000000000000000000000000006FC7E6E0EFFBFFFFFFFFFFFFFFFFFF0055
          A2FF0055A2FF0055A2FFFFFFFFFFE0EFFBFF006FC7E90000001E000000000000
          0000000000000000000000000000006FC7E6E0EFFBFFFFFFFFFFFFFFFFFF0055
          A2FFFFFFFFFFFFFFFFFFFFFFFFFFE0EFFBFF006FC7E900000016000000000000
          0000000000000000000000000000006FC7E6E0EFFBFFFFFFFFFFFFFFFFFF0055
          A2FFFFFFFFFFFFFFFFFFFFFFFFFFE0EFFBFF006FC7E900000016000000000000
          0000000000000000000000000000005294AB99CAF1FFFFFFFFFFFFFFFFFF0055
          A2FFFFFFFFFFFFFFFFFFFFFFFFFF99CAF1FF005394B60000000C000000000000
          0000000000000000000000000000002C505C409CE6FFCCE5F8FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFCCE5F8FF409CE6FF002C506700000000000000000000
          000000000000000000000000000000000101003E6F80409CE6FF99CAF1FFE0EF
          FBFFE0EFFBFF99CAF1FF409CE6FF003E6F860000010100000000000000000000
          00000000000000000000000000000000000000000101002C505C005294AB006F
          C7E6006FC7E6005294AB002C505C000001010000000000000000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          000C000000250000002900000029000000290000002900000029000000290000
          00250000000C00000000000000000000000000000000000000002B140248873E
          06EA924305FF8F4104FF8D3E04FF893A03FF873902FF853702FF783001EB250F
          00650000002500000000000000000000000000000000000000008E4708E4DCC0
          A8FFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBCBCBCFFFFFFFFFFD5B9A6FF7932
          02E8000000290000000000000000000000000000000000000000A7550BFFFFFF
          FFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFF8B3D
          04FF000000290000000000000000000000000000000000000000A7550BFFFFFF
          FFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFFBCBCBCFFFFFFFFFFFFFFFFFF8B3D
          04FF000000290000000000000000000000000000000000000000A7550BFFBCBC
          BCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFFBCBCBCFF843A
          04FF000000430000002D0000002D0000001F0000000D00000000AD5B0EFFFFFF
          FFFFFFFFFFFFBCBCBCFFFFFFFFFFCCCCCCFF969696FFCCCCCCFF99B0CAFF2F4C
          79FF0050ADEA0050AEE6003777AD001732660000002F0000000EB3610FFFFFFF
          FFFFFFFFFFFFBCBCBCFF0085F0FF0085F0FF0085F0FF007BE5FF1485D5FF6BB2
          E6FFD4EAFDFFD4EAFDFF6BB2E6FF006CBBEE001C366C00000026B86510FFB664
          10FFB46210FFB2610FFF0085F0FFFFFFFFFF6DAAF2FF268ED9FF6BB2E6FFDAEE
          F9FF0055A2FFDAEEF9FFFFFFFFFF6BB2E6FF005192CC00000031A85D0FE7B967
          11FFB96611FFB76511FF0085F0FFFFFFFFFF6DAAF2FF006ECDFFD4EAFDFF0055
          A2FFDAEEF9FF0055A2FFDAEEF9FFD4EAFDFF0060C0F7000000322E19043F9251
          0DC9B96711FFB96711FF0085F0FFFFFFFFFF6DAAF2FF006ECDFFD4EAFDFFFFFF
          FFFFFFFFFFFFDAEEF9FF0055A2FFD4EAFDFF0066C6FA0000002C000000000000
          000000000000000000000085F0FFFFFFFFFF6DAAF2FF3291D9FF6BB2E6FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF6BB2E6FF0470B8E20000000D000000000000
          000000000000000000000085F0FFFFFFFFFF6DAAF2FF73AEE3FF218AD7FF6BB2
          E6FFD4EAFDFFD4EAFDFF6BB2E6FF0074D4FF0017326600000000000000000000
          000000000000000000000085F0FFFFFFFFFF6DAAF2FF73AEE3FF218AD7FF6BB2
          E6FFD4EAFDFFD4EAFDFF6BB2E6FF0074D4FF0017326600000000000000000000
          000000000000000000000085F0FFFFFFFFFFA8DBFFFF62A7E9FF86BEEAFF3C9A
          DEFF006ECDFF006ECDFF3197DFFF007BE5FF0000003300000000000000000000
          00000000000000000000000000000085F0FFFFFFFFFFA8DBFFFF6DAAF2FF6DAA
          F2FF6DAAF2FF6DAAF2FF6DAAF2FF0085F0FF0000003300000000000000000000
          00000000000000000000000000002E3D48580085F0FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF0085F0FF0000003300000000000000000000
          000000000000000000000000000004050506476173840085F0FF0085F0FF0085
          F0FF0085F0FF0085F0FF0085F0FF0085F0FF0000000000000000}
      end
      item
        Image.Data = {
          B6040000424DB604000000000000360000002800000010000000120000000100
          2000000000008004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000400080101
          0103000000000000000000000000000000000000000000000000050505111010
          10351111113B1111113B1111113B1010103B0F0F0F3B0F0F0F3B0F0F0F3B0D0D
          0D35040404110000000000000000000000000000000000000000361F0D6E893E
          06ED934104FF914003FF8F3F03FF833501FF1D700BFF6A481AFF733107EE2E18
          0B720D0D0D3500000000000000000000000000000000000000008B4106EAE2CA
          B8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0C881AFF9CBCA0FFD1BDB0FF722E
          03EA0F0F0F3B090D0C32000000000000000000000000000000009C4904FFFFFF
          FFFFEFEFEFFFEFEFEFFFEFEFEFFFEFEFEFFF008310FF499A53FFDFDFDFFF8233
          02FF1010103B008400FF23232357000000000000000000000000A04C05FFFFFF
          FFFFF0F0F0FFF0F0F0FFF0F0F0FFF0F0F0FF20922FFF0C952DFF60A76AFF7644
          14FF12121240008400FF008400FF232423580000000000000000A24E05FFFFFF
          FFFFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FF68B473FF14A243FF1BAD57FF1B8D
          31FF106521CB008400FF38D699FF008400FF2323235700000000B66208FFFFFF
          FFFFF3F3F3FFF3F3F3FFF3F3F3FFF3F3F3FFD5E5D7FF219534FF22B767FF2AC2
          7AFF31CD8BFF37D597FF3DDCA5FF40E1AEFF008400FF23232357B96509FFFFFF
          FFFFF5F5F5FFF5F5F5FFF5F5F5FFF5F5F5FFF5F5F5FFC4DFC9FF2F9E43FF13A4
          47FF36D499FF3CDBA3FF40E1AEFF40E1AEFF008400FF23232357C06B0AFFD4D4
          D4FFD4D4D4FFD4D4D4FFD4D4D4FFD4D4D4FFF7F7F7FFF7F7F7FFF0F8F2FF5F67
          11FF0B6720C5008400FF40E1AEFF008400FF2228226002020204C26D0BFFC26D
          0BFFC26D0BFFC88033FFC38846FFD4D4D4FFF8F8F8FFF8F8F8FFFFFFFFFFA551
          06FF1414143B008400FF008400FF212921610202020500000000C06B0AFFFFFF
          FFFFFFFFFFFFFFFFFFFFC0792AFFD4D4D4FFFAFAFAFFFAFAFAFFFFFFFFFFA854
          07FF1515153B008400FF0000000000000000000000000000000000000000C06B
          0AFFFEFEFEFFFFFFFFFFBC6709FFD4D4D4FFFBFBFBFFFBFBFBFFFFFFFFFFAB57
          07FF131313350000000000000000000000000000000000000000000000000000
          0000C06B0AFFFFFFFFFFBC6709FFD4D4D4FFFCFCFCFFFCFCFCFFEBD5BFFF9F52
          08EB0505050F0000000000000000000000000000000000000000000000000000
          000014141416C06B0AFFBC6709FFBB6D1CFFBA6B1CFFB96B1CFF8D4A06C92C17
          023F000000000000000000000000000000000000000000000000000000000000
          00000909090A080808090909090A080808090808080908080809000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end>
  end
  object tabCariBilgileri: TADOQuery
    Connection = cnn
    Parameters = <
      item
        Name = 'RehID'
        Size = -1
        Value = Null
      end
      item
        Name = 'IletID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'Declare @RehberID integer'
      'Declare @IletisimID integer'
      ''
      'Set @RehberID =:RehID'
      'set @IletisimID =:IletID'
      ''
      ''
      '    select'
      
        '    '#9'KOD,FIRMA,GRUP,KATEGORI,DURUM,OZELKOD,ARAMADACIKSIN,NOTLAR,' +
        'YETKIKODU,'
      ''
      
        '    '#9'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=40),'
      
        '    '#9'CEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '2),'
      
        '    '#9'FAX=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '3),'
      
        '    '#9'ADRES=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=2),'
      
        '    '#9'ILCE=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=' +
        '6),'
      
        '    '#9'IL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=8)' +
        ','
      
        '    '#9'PK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER J' +
        'OIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND ' +
        'RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4)' +
        ','
      
        '    '#9'VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) I' +
        'NNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIR' +
        'A AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILA' +
        'N=20),'
      
        '    '#9'VERGINO=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) IN' +
        'NER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA' +
        ' AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN' +
        '=22),'
      
        '    '#9'WEB=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER ' +
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=4' +
        '8),'
      
        '    '#9'EMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=46),'
      
        '    '#9'FATURABASLIK=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (noloc' +
        'k) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB' +
        '.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSA' +
        'YILAN=10),'
      
        '    '#9'LOGO= (SELECT  TOP 1 BELGE FROM IMAJ I WHERE VARSAYILAN=1 A' +
        'ND YERI=11 AND YER_ID=@RehberID ),'
      
        '    '#9'VERGIDAI_KODU=(select TOP 1  VDKODU FROM VDLISTE VD WHERE V' +
        'D.VD =(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOI' +
        'N REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA' +
        '.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=20)),'
      
        '      VERGI=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INN' +
        'ER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA ' +
        'AND RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=' +
        '20)+'#39' / '#39'+(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@RehberID AND RA.VARSAYILAN=22' +
        ')'
      '      from'
      '      '#9'REHBER R'
      '      WHERE ID = @RehberID')
    Left = 466
    Top = 13
  end
  object iohSSLTLS: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 447
    Top = 366
  end
  object XMLDocument2: TXMLDocument
    Left = 662
    Top = 188
    DOMVendorDesc = 'MSXML'
  end
  object HTTPRIOGuncelleme: THTTPRIO
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 767
    Top = 232
  end
  object ADOCommand1: TADOCommand
    Connection = cnn
    Parameters = <>
    Left = 30
    Top = 206
  end
  object HTTPRIORaporium: THTTPRIO
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 767
    Top = 288
  end
  object tabDonusturulecekBelge: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 44
    Top = 370
  end
  object ADOQuery1: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT * FROM STILKOSUL'
      'ORDER BY GRIDADI')
    Left = 560
    Top = 55
  end
  object Query7: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 18
    Top = 141
  end
  object Query8: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 60
    Top = 143
  end
  object Query9: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 100
    Top = 142
  end
  object KlasorResimleri: TcxImageList
    FormatVersion = 1
    DesignInfo = 22676306
    ImageInfo = <
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000143A4D61006696EF00638FDF0044649B00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000002D93BCFC007AADFF4CD9F7FF0CA3D2FF037FB2FC00699AE5004F
          76B100151F290000000000000000000000000000000000000000000000000000
          0000003348671888B6FC007DB0FF90EFFFFF30E0FFFF29E2FFFF1DCBEEFF0FA4
          D2FF0584B6FE006FA1EE005179B7000000000000000000000000000000000000
          0000065C7FB03B9FC6FF007FB2FF9FF1FFFF46E2FFFF40E1FFFF3AE0FFFF34E0
          FFFF33E2FFFF2DD0EEFF20B1DDFF0C86B6FF006290E40000000000000000002D
          3E560379ACEDB6F5FBFF0081B4FFB0F7FFFF5EECFFFF58E9FFFF52E7FFFF4BE4
          FFFF45E2FFFF45E0FFFF46E2FFFF3FCFF0FF006DA0FF00000000000000000052
          709A42A3C7FADDFFFFFF0084B7FFC0FCFFFF77F4FFFF70F1FFFF6AEFFFFF63EC
          FFFF5CEAFFFF58E9FFFF56E4FEFF64DAEDFF006FA2FF0000000000000000036D
          95CAABDCEAFFE5FFFFFF0086B9FFD1FFFFFF8EFDFFFF89FAFFFF82F6FFFF7AF4
          FFFF73F3FFFF6CF0FFFF4CC9E3FFAAFFFFFF0072A5FF00000000000000000183
          B3F0CAF5FAFFF1FFFFFF0088BBFFDCFFFFFFA1FFFFFF9CFBFFFF94F9FFFF8CF7
          FFFF85F6FFFF7EF5FFFF5DCBDFFFD1FFFFFF0074A7FF0000000000000000028D
          C0FB1093C2FE7EC4DDFF008ABDFFC3EDF5FF7ADBEAFF85E3EFFF92F0F8FF9CFA
          FFFF94F8FFFF65D2E7FFAAF4F9FFDAFFFFFF0077AAFF00000000000000000000
          00000000000000000000008DC0FFF2FFFFFFC8F7FBFFABE7F1FF81D4E6FF6BC7
          DFFF65C6DFFF5FC2DBFFD3FFFFFFE7FFFFFF0079ACFF00000000000000000000
          00000000000000000000007DACD931A5CDFF4AB0D3FF83CDE2FFD0EFF6FFE6FC
          FCFFF1FFFFFFE6FFFFFFDEFFFFFFF3FFFFFF007CAFFF00000000000000000000
          0000000000000000000000000000000000000025323B0048637E00678DB6006E
          9ACC148EBEFCFFFFFFFFFFFFFFFFFFFFFFFF007EB1FF00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000086B7F6EDF6FAFFFFFFFFFFFFFFFFFF007EB1FF00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000006A95BA0086B9FF0084B7FF0082B5FF0046679D00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000039211458392114583921145839211458392114583921
          1458392114583921145839211458392114583921145800000000000000000000
          0000000000003626217AA5623AFFA5623AFFA5623AFFA5623AFFA5623BFFA562
          3AFFA5623BFFA5623BFFA5623BFFA5623AFFA5623AFF5D372191000000000000
          00000000000093695DFFFDFAF7FFA9673FFFFFEAD9FFF5A45DFFF5A963FFF5AC
          68FFF5AF6DFFF5B171FFF5B77AFFDD9A5EFFDA8638F5AC602CFE000000000000
          00000000000093695DFFFDFAF7FFAA6A43FFFFEAD9FFFCB370FDFFB777FFFCBA
          7CFDFFBF83FFFCC088FDFCC994FDE6AF7AFFDE9249EFA4613AFF00000000110C
          0A3A110C0A3A93695DFFFDFAF7FFAA6A43FFFFEAD9FFFFAF6AFFFFB470FFFFB8
          76FFFFBA7BFFFFBF81FFFFC58FFFE7AC76FFEA8D39FDAA5F2CFC30231F54A562
          3AFFA5623AFF93695DFFFDFAF7FFAA6A43FFFFEAD9FFFCA457FDFFA85DFFFCAA
          62FDFFAF68FFFBB26EFDFBB97CFDE5A165FFDD8535EFAA5F2CFC93695DFFFDFA
          F7FFA9673FFF93695DFFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFEAD9FFFFB573FFFFB776FFE69D5EFFDD822FEFAA5F2CFC93695DFFFDFA
          F7FFAA6A43FF93695DFFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA68
          40FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFAA6A43FF93695DFFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFA
          F7FFAA6A44FFA9683FFFAA673EFFA8653CFFA5623AFF3921145893695DFFFDFA
          F7FFAA6A43FF93695DFFFDFAF7FFFFFFFFFFFDFDFDFDFDFDFDFDFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF30231F540000000093695DFFFDFA
          F7FFAA6942FF93695DFFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF9369
          5DFF93695DFF93695DFF93695DFF30231F54000000000000000093695DFFFDFA
          F7FFFDFAF7FFAA6942FF93695DFF93695DFF93695DFF93695DFF93695DFFFFEA
          D9FFFFEAD9FFFFEAD9FFAA5E2BFC00000000000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A44FFA9683FFFAA67
          3EFFA8653CFFA5623AFF0000000000000000000000000000000093695DFFFDFA
          F7FFFFFFFFFFFDFDFDFDFDFDFDFDFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFA
          F7FF93695DFF30231F540000000000000000000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF93695DFF93695DFF9369
          5DFF30231F54000000000000000000000000000000000000000030231F549369
          5DFF93695DFF93695DFF93695DFF93695DFF30231F5400000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFFFFFFF008500FFFFFF
          FFFFA93D3AFFA93D3AFFA93D3AFFA93D3AFFA93D3AFFA93D3AFF000000000000
          000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF008500FF0085
          00FFFFFFFFFFFFCCCCFFFF8FA0FFFF8FA0FFFF8FA0FFA93D3AFF000000002319
          163C2319163CFFFFFFFF008500FF008500FF008500FF008500FF008500FF0085
          00FF008500FFFFFFFFFFFFA3B6FFFFA3B6FFFFA3B6FFA93D3AFF59423B97A363
          3FFFA5623AFFFFFFFFFF008500FF008500FF00B000FF00B000FF00B000FF0085
          00FF008500FFFFFFFFFFFFCCCCFFFFCCCCFFFFCCCCFFA93D3AFF93695DFFFDFA
          F7FFFDFAF7FFFFFFFFFF008500FF00B000FFFFFFFFFFFFFFFFFF00B000FF0085
          00FFFFFFFFFFA93D3AFFA93D3AFFA93D3AFFA93D3AFFAA5F2CFC93695DFFFDFA
          F7FFFFFFFFFFFFFFFFFF00B000FF00B000FFFFFFFFFFFFFFFFFF00B000FFFFFF
          FFFFFFB46FFF005D9AFF005D9AFF005D9AFFE6AF7AFFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA85DFFFFFFFFFFFFB4
          6FFF005D9AFF50B6FFFF50B6FFFF50B6FFFF005D9AFFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFFA85DFFFFAF6AFFFBB36EFDFFB4
          6FFF005D9AFF99FFFFFF50B6FFFF50B6FFFF005D9AFFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFFA85DFFFFAD64FFFFAF6AFFFFB4
          6FFFFFB46FFF005D9AFF005D9AFF005D9AFFE7A56CFFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FDFFA85DFFFCAA62FDFFAF
          68FFFBB26EFDFFB877FFFBB97CFDE5A165FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFB573FFFFB36EFFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFE5B694FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFAA69
          42FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF2319163C93695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFE4D7D2FF93695DFF59423B970000000093695DFFEFD3
          BEFFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFEFD3BEFF93695DFF9369
          5DFF93695DFF93695DFF966E62FF59423B970000000000000000493731789369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF59423B970000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000110C
          0A3A110C0A3A110C0A3A110C0A3A110C0A3A110C0A3A110C0A3A110C0A3A110C
          0A3A110C0A3A110C0A3A110C0A3A0000000000000000000000005C4D49819872
          67FF987267FF987267FF987267FF987267FF987267FF987267FF987267FF9872
          67FF987267FF987267FF987267FF2A201D7D0000000000000000987267FFFFFF
          FFFFFFFFFFFF987267FFE1DCDDFFC0B0B1FFC4B4B5FFC8BABAFFCCBEBEFFCFC2
          C2FFD4C7C7FFC2AFADFF847777AD987267FF110C0A3A00000000987267FFFFFF
          FFFFFFFFFFFF987267FFE1DCDDFFBAABABFFC0B0B0FFC4B3B3FFC8B9B9FFCCBD
          BDFFCFC2C2FFC1ADAAFF817374AB987267FF110C0A3A00000000987267FFFFFF
          FFFFFFFFFFFF987267FFE1DCDDFFB7A6A6FFBAABABFFC0B0B0FFC4B3B3FFC8B9
          B9FFCDBEBEFFBEAAA8FF7E6F70AB987267FF110C0A3A00000000987267FFFFFF
          FFFFFFFFFFFF987267FFE1DCDDFFB1A19FFFB7A6A6FFBAABABFFC0B0B0FFC4B3
          B3FFC8BABAFFBBA6A4FF7B6D6DAB987267FF110C0A3A00000000987267FFFFFF
          FFFFFFFFFFFF987267FFE1DCDDFFAD9999FFB1A09EFFB6A5A5FFBAABABFFC0B0
          B0FFC4B5B5FFB7A1A0FF7B6D6DAB987267FF0604023500000000987267FFFFFF
          FFFFFFFFFFFF987267FFE1DCDDFFE1DCDDFFE1DCDDFFE1DCDDFFB6A5A5FFBAAA
          AAFFC0B1B1FFB39D9AFF7B6D6DAB987267FF76573FFD04020126987267FFFFFF
          FFFFFFFFFFFFFFFFFFFF987267FF987267FF987267FF987267FFE1DCDDFFE1DC
          DDFFE1DCDDFFE1DCDDFFE1DCDDFF987267FF76573FFD705540F7987267FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAF9F9FFFFFFFFFF987267FF9872
          67FF987267FF987267FF987267FF5C3F29FDECE5E8FF73543DFF987267FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFF83645AD75D4029FF593D27FDECE5E8FF72543DFF987267FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF987267FF987267FF987267FF9872
          67FF987267FF5D4029FFECE5E8FFECE5E8FFECE5E8FF6F543FF8000000009872
          67FF987267FF987267FF987267FF987267FF110C0A3A00000000000000000000
          00005A3F29F1ECE5E8FFECE5E8FFECE5E8FF81654FFC0201011B000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000654730F4ECE5E8FF523823EE110C0A3A00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000563B26F2523824E9110C0A3A00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000081654FFC110C0A3A00000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000002823
          2149282321492823214928232149282321492823214928232149282321492823
          2149133E6AFF133E6AFF133E6AFF2823214928232149000000002B2624579A73
          68FA9A7368FA9A7368FA9A7368FA9A7368FA9A7368FA9A7368FA9A7368FA133E
          6AFF133E6AFF133E6AFF133E6AFF9A7368FA9A7368FA2D28265C9A7368FAB99D
          94FFFFFFFFFF9A7368FAEAE5E6FFAE9591FFB49B97FFB69F9AFF133E6AFF00CC
          FFFF00CCFFFF00CCFFFF00CCFFFF133E6AFF987F79D29A7368FA9A7368FAFFFF
          FFFFFFFFFFFF9A7368FAEAE5E6FFB7A7A7FFBFB0B0FFC2B4B4FF133E6AFF00CC
          FFFF133E6AFF0B73BCFF00CCFFFF133E6AFF927E7BC09A7368FA9A7368FAFFFF
          FFFFFFFFFFFF9A7368FAEAE5E6FFB4A0A0FFBBA9A9FFBFAFAFFF133E6AFF00CC
          FFFF133E6AFF2C649DFF00CCFFFF133E6AFF907A77C09A7368FA9A7368FAFFFF
          FFFFFFFFFFFF9A7368FAEAE5E6FFB09D9DFFB6A6A6FFBBA9A9FF133E6AFF00CC
          FFFF133E6AFF133E6AFF00CCFFFF133E6AFF8E7874C09A7368FA9A7368FAFFFF
          FFFFFFFFFFFF9A7368FAEAE5E6FFAB9999FFB4A0A0FFB6A6A6FF133E6AFF00FF
          FFFF00CCFFFF00CCFFFF00CCFFFF133E6AFF8B7472C09A7368FA9A7368FAFFFF
          FFFFFFFFFFFF9A7368FAEAE5E6FFA89494FFB09C9CFFB4A2A2FFBCA7A5FF133E
          6AFF133E6AFF133E6AFF133E6AFF133E6AFF85716FC09A7368FA9A7368FAFFFF
          FFFFFFFFFFFF9A7368FAEAE5E6FFA59090FFAA9696FFAE9A9AFFB3A0A0FFB6A1
          9EFF133E6AFF307ECEFF133E6AFFCAB0AAFF7E6C6AC09A7368FA9A7368FAFFFF
          FFFFFFFFFFFF9A7368FAEAE5E6FFEAE5E6FFEAE5E6FFEAE5E6FFC7B9BAFFAB97
          97FF133E6AFF2F84D8FF133E6AFFC2ABA5FF7B6867C09A7368FA9A7368FAFFFF
          FFFFFFFFFFFFB79C94FF9A7368FA9A7368FA9A7368FA9A7368FAEAE5E6FFEAE5
          E6FF133E6AFF3294F4FF133E6AFFEAE5E6FFEAE5E6FF9A7368FA9A7368FAFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9A7368FA9A73
          68FA133E6AFF3294F4FF133E6AFF9A7368FA9A7368FA9A7368FA9A7368FAFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFF133E6AFF3294F4FF133E6AFFFFFFFFFF9A7368FA282321499A7368FAFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9A7368FA9A7368FA9A73
          68FA133E6AFF3294F4FF133E6AFF9A7368FA2823214900000000534541789A73
          68FA9A7368FA9A7368FA9A7368FA9A7368FA9A7368FA28232149000000000000
          0000133E6AFF133E6AFF133E6AFF000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000020622002C5C9B0061
          B4D3005EB3D30028599B00010522000000000000000000000000000000000000
          00000000000000000000000000000000000000152B550897E7FF36E2FFFF5FD9
          F4FF94DEF5FF91E9FFFF148CE0FF001228550000000000000000000000000000
          000000000000000000000000000000010522058EDBFF30C8F7FFB2CEE6FFF3EA
          E6FFE8E2DFFFA3BDD3FF59DEF5FF0B81D3FF000004220000000000000000A363
          3FFFA5623AFFA5623AFFA5623AFF403F5CFF10C8FFFFBCD2E9FFFFFEFBFFF7F7
          F7FFF1F1F1FFEAE7E4FFA3B9CDFF2ED6FFFF403956FF0000000093695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FF2A6C9BFF109EEBFFFFFFFFFFFFFFFFFFAAAA
          AAFF777777FFFBFBFBFFF5EBE7FF2AB3E9FF6A626AF6AC602CFE93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FF2C6896FF0793E8FFFFFFFFFFA7A7A7FF9090
          90FFA1A1A1FF8F8F8FFFFFFEF9FF1CA6E8FF686973F4A4613AFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FF645360FF00B4FFFFA5B2CAFF7E7A77FFFFFF
          FFFFFFFFFFFFF3EFECFFBDCBE1FF04B5FFFF7A584AE6AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFDD9152FF0079C1FF009AF4FFC3D1E8FFFFFF
          FFFFFFFFFFFFBDCBE2FF039CF3FF0071C1FF965F2FC9AA5F2DFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA558FFAA7A5DFF0079C1FF00B0FFFF008C
          E8FF008CE8FF00B0FFFF0075C1FF9A7867FFB36F30C1AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FDDD9153FF635360FF2C67
          94FF2B6795FF645868FFDBA16FFFE5A165FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFB573FFFFB36EFFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFAA69
          42FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF000000000000000000000000000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000242C34380D54AAFF0D54
          AAFF0D54AAFF0D54AAFF0D54AAFF0D54AAFF24292F3800000000000000000000
          000000000000000000000000000000000000000000000D54AAFF4CABFFFF2490
          FFFF2D99FFFF3EAAFFFF4DB8FFFF51BEFFFF0D54AAFF00000000000000000000
          000000000000000000000000000000000000000000000D54AAFFB9F7FFFF99E5
          FFFF6FC5FFFF55B1FFFF4EAAFFFF4DABFFFF0D54AAFF0000000000000000A363
          3FFFA5623AFFA5623AFFA5623AFFA5623AFFA5623AFF0D54AAFFB3F3FFFF97E3
          FFFF79CBFFFF5BB4FFFF4FABFFFF4DACFFFF0D54AAFF0000000093695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FFF5A158FFF5A45DFF0D54AAFFB0F3FFFF95E4
          FFFF75CAFFFF56B1FFFF50ACFFFF55B1FFFF0D54AAFFAC602CFE93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFB06AFFFCB370FD0D54AAFFB3F5FFFF99E7
          FFFF77CBFFFF57B0FFFF4EA9FFFF54B0FFFF0D54AAFFA4613AFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFAC62FFFFAF6AFF0D54AAFF7BCCFFFF52B5
          FFFF58BFFFFF66CDFFFF71D8FFFF66CDFFFF0D54AAFFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA85CFFFBAA63FD707883FF0D54AAFF0D54
          AAFF0D54AAFF0D54AAFF0D54AAFF0D54AAFF80664EE4AA5F2DFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA558FFFFA85DFFF5A660FF818164FFF6F6
          E4FF818164FFFFBA7DFFF6F6E4FF818164FF9C6129C3AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FDFFA85DFF818164FFF6F6
          E4FF818164FF818164FFF6F6E4FF818164FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FF818164FFF6F6
          E4FFF6F6E4FFF6F6E4FFF6F6E4FF818164FFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FF8181
          64FF818164FF818164FF818164FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF000000000000000000000000000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000004330
          2B75382C38FF382C38FF382C38FF382C38FF43302B7500000000000000000000
          000000000000000000000000000000000000000000000000000000000000605F
          5FFFBCB8BCFF009900FF009900FF009900FF382C38FF00000000000000003219
          064032190640321906403219064032190640321906403219064032190640605F
          5FFFAEBDAFFF33CC66FF33CC66FF009900FF382C38FF0000000032190640A363
          3FFFA5623AFFA5623AFFA5623AFFA5623AFFA5623AFFA5623BFFA5623AFF605F
          5FFFBAB7B9FF66FF99FF33CC66FF009900FF382C38FF3219064093695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FFF5A158FFF5A45DFFF5A963FFF5AC68FF605F
          5FFFC6C5C5FF8F898FFF938F93FF8E8C8BFF382C38FFAC602CFE93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFB06AFFFCB370FDFFB777FFFCBA7CFD605F
          5FFFBAC2C2FF00D9FFFF00B8FFFF00C0FEFF382C38FFA4613AFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFAC62FFFFAF6AFFFFB470FFFFB876FF605F
          5FFFB4BDBDFF99FFFFFF00C0FEFF00C0FEFF382C38FFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA85CFFFBAA63FDFFAF6AFFFBB36EFD605F
          5FFFD1D0D0FF8A847CFF908B82FFA09E9EFF382C38FFAA5F2DFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA558FFFFA85DFFFFAD64FFFFAF6AFF605F
          5FFFCCCAC8FF0037FFFF0037FFFF0037FFFF382C38FFAA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FDFFA85DFFFCAA62FD605F
          5FFFB6BBC6FF9DDBFFFF0037FFFF0037FFFF382C38FFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FF605F
          5FFFE8E7E6FFA9B6CFFFA9B4D3FFD8D6D3FF382C38FFAA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFFFEA
          D9FF605F5FFF605F5FFF605F5FFF605F5FFFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF3219064093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF271C19440000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF271C19440000000000000000271C19449369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF271C19440000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          200000000000000400000000000000000000000000000000000000000000A363
          3FFFA5623AFFA5623AFFA5623AFFA5623AFFA5623AFFA5623BFFA5623AFFA562
          3BFFA5623BFFA5623BFFA5623BFFA5623AFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FFF5A158FFF5A45DFFF5A963FFF5AC68FFF5AF
          6DFFF5B171FFF5B476FFF5B77AFFDD9A5EFFB6702FCDAC602CFE93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFB06AFFFCB370FDFFB777FFFCBA7CFDFFBF
          83FFFCC088FDFFC68FFFFCC994FDE6AF7AFFB3763BC1A4613AFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFAC62FFF3A665FFE7A365FFE6A56AFFE6A7
          6EFFE6AC74FFE6AF7BFFE5B080FFDDA571FFB37437C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFF3E4DCFF2850A5FF876862FFE39B5FFFE9A566FFE8A7
          6CFFE4A770FFE6AC74FFE4AE7BFFD89E6AFFB37234C1AA5F2DFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FF4367AAFFB0B8CCFF5E92E3FD565B82FFC28C
          60FFEEAB6FFFE8A971FFE8AD75FFDF9F68FFB36F30C1AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FF8A716BFFD5EDFFFFE8F7FFFFC0ECFFFF488F
          E7FFB58B73FFFFB877FFFBB97CFDE5A165FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFF1DDCEFF6BBBFAFFB0EEFFFF78DEFFFF8AD8
          FFFF428EE8FFB68A72FFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FF3D86B4FF8CFAFFFF72E4FFFF60D7
          FFFF6FC9FFFF3586E8FFB6B2BFFFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFF6F3F0FF35AEEDFF69F7FFFF54DD
          FFFF45CFFFFF54BBFFFF277EE8FF77534FFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDF7F4F1FF31ADECFF43F5
          FFFF36D6FFFF2BC8FFFF3AACFFFF1975E8FF000A23490000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF8F665AFF1C93
          D3FF1EF2FFFF18D0FFFF0EC0FFFF26A2FFFF0B6CE4FF16213549000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          00060081C3D500EFFFFF00CAFFFF0EBDFFFFC4E7FFFF406095B1000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000060081C2D500EEFFFFDDF6FFFF84ABE6FF1C2C4965000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000060076B7D64191E4FF0009347B00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000008080B1B2A2B
          668830398CAD313888A72121466C000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000002661092AE1FF002E
          FFFF7C96FFFF3F67FFFF0029FFFF0010C0E90000031D00000000000000000000
          00000000000000000000000000000000000000000A3B274DEFFF124CFFFF0B40
          FFFFFFFFFFFFC8D2FFFF0028FFFF0035FFFF0010C0E90000000000000000A363
          3FFFA5623AFFA5623AFFA5623AFFA5623AFF322A88FF2765FFFF1B56FFFF0D47
          FFFF4971FFFF1444FFFF002FFFFF0032FFFF002DFFFF2121466C93695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FFF5A158FF3147CDFF2B6BFFFF225FFFFF1C55
          FFFFFFFFFFFFC4D0FFFF002EFFFF0030FFFF002EFFFF6F5B96FF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFB06AFF3F56CFFF3275FFFF2A68FFFF2B65
          FFFFFFFFFFFFCCD7FFFF013AFFFF0438FFFF002DFFFF6A5C9FFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFAC62FF5250B5FF3F84FFFF3272FFFF326E
          FFFFFFFFFFFFCDD9FFFF0A45FFFF0C43FFFF0037FFFF79577BFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA85CFF8B5E55FF84ACFFFF367AFFFF3A78
          FFFFFFFFFFFFD2DDFFFF124FFFFF144FFFFF0A2BE1FFA25D33FF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA558FFFFA85DFF5E4690FF84ADFFFF3A81
          FFFFEBF4FFFFA1BEFFFF2163FFFF284EEFFF89553ED7AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FDFFA85DFF8C5E55FF5350
          B5FF354FCFFF2A43CDFF453D96FFB07B57FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFB573FFFFB36EFFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFAA69
          42FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF000000000000000000000000000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000186000019BD5000C
          CDFF000CCEFF00029FD500001960000000000000000000000000000000000000
          000000000000000000000000000000000000030661A00B3CFBFF0035FFFF0033
          FFFF0031FFFF002AFFFF0028FFFF000366A00000000000000000000000000000
          0000000000000000000000000000000018602657FBFFFCFEFFFFEDF0FFFF0C3E
          FFFF0536FFFFECEFFFFFFDFDFFFF0028FFFF000019600000000000000000A363
          3FFFA5623AFFA5623AFFA5623AFF312FA4FF1B5FFFFFEEF2FFFFFFFFFFFFE2E8
          FFFFE2E7FFFFFFFFFFFFECEFFFFF002AFFFF1B11A8FF0000000093695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FF334BCDFF2B6CFFFF2864FFFFE5EBFFFFFFFF
          FFFFFFFFFFFFE2E7FFFF0536FFFF0031FFFF000CCEFFAC602CFE93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FF4255CDFF3275FFFF316DFFFFE4EBFFFFFFFF
          FFFFFFFFFFFFE1E8FFFF0D3FFFFF0033FFFF000CCDFFA4613AFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FF574BAAFF3D83FFFFEFF4FFFFFFFFFFFFE4EB
          FFFFE5EBFFFFFFFFFFFFEDF0FFFF0036FFFF67437FF4AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FF9F6851FF82A4FBFFF7FBFFFFEFF4FFFF316F
          FFFF2A65FFFFEFF3FFFFFCFEFFFF0C3EFBFF895739D8AA5F2DFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA558FF6C4A83FF82A4FBFF3D84FFFF3277
          FFFF2C6DFFFF1E60FFFF2759FBFF594389FFB36F30C1AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FD9F6852FF564BAAFF4256
          CDFF344ACDFF403EAEFF9D7366FFE5A165FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFB573FFFFB36EFFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFAA69
          42FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF000000000000000000000000000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000490000
          00CE000000FF000000FF000000D6000000520000000000000000000000000000
          000000000000000000000000000000000000000000000000006F090909FF0808
          08FF000000FF000000FF000000FF000000FF0000008300000000000000000000
          00000000000000000000000000000000000000000023060606FF111111FF0000
          00FF000000FF000000FF000000FF000000FF000000FF0E0E0E2E00000000A363
          3FFFA5623AFFA5623AFFA5623AFFA5623AFF4F2F1BFF2A2725FF140F0CFF0E09
          06FF0B0704FF030301FF000000FF000000FF000000FF2E2E2E9693695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FFF5A158FF4D341DFF4F4742FF261911FF2517
          0FFF20160FFF18100BFF0B0704FF000000FF000000FF6D5443FF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFB06AFF6A4B2FFF6A5C53FF48362BFF3825
          18FF352318FF2A1C13FF1C120CFF0A0604FF000000FF6E5547FF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFAC62FF855B37FF433A34FF8B796CFF4B30
          1EFF472F20FF3A271AFF291B12FF160E09FF000000FF905B37FF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFC07E45FF000000FF010000FF71675FFFA790
          82FF624633FF432B1AFF322015FF1B120BFF704821EDAA5F2DFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFF6E5D8FF37759EFF06252BFF766052FF342213FF4F40
          39FD85766DFF71645BFF37302BFF64472FFFB36F30C1AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFE4DFDDFF1F6FAEFF977255FF845630FFFCAA62FDFCAC
          66FFC78D57FFC9915DFFF7B57AFFE5A165FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFB573FFFFB36EFFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFAA69
          42FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF000000000000000000000000000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000008080B1B2A2B
          6688323A8CAD323988A72121466C000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000002661092AE1FF0030
          FFFF6282FFFF1E4BFFFF002BFFFF0010C0E90000031D00000000000000000000
          00000000000000000000000000000000000000000A3B274DEFFF134CFFFF0036
          FFFFFFFFFFFF708CFFFF002CFFFF0035FFFF0010C0E90000000000000000A363
          3FFFA5623AFFA5623AFFA5623AFFA5623AFF322A88FF2765FFFF1B56FFFF0C45
          FFFF88A2FFFF1947FFFF002FFFFF0032FFFF002DFFFF2121466C93695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FFF5A158FF3147CDFF2B6BFFFF2460FFFF0F4C
          FFFFF9FAFFFFA6BAFFFF0029FFFF0030FFFF002EFFFF6F5B96FF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFB06AFF3F56CFFF3275FFFF2666FFFF1857
          FFFF5681FFFFFFFFFFFF9CB2FFFF002FFFFF002DFFFF6A5C9FFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFAC62FF5250B5FF3980FFFF8DB1FFFFADC4
          FFFF1050FFFF5380FFFFFFFFFFFF315FFFFF0035FFFF79577BFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA85CFF8B5E55FF7FA8FFFF84AFFFFFFFFF
          FFFF6D97FFFF98B4FFFFFFFFFFFF275EFFFF0829E1FFA25D33FF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA558FFFFA85DFF5E4690FF7CA6FFFF9AC0
          FFFFEAF3FFFFDFEAFFFF6896FFFF2249EFFF89553ED7AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FDFFA85DFF8C5E55FF4E4D
          B5FF354FCFFF2740CDFF423B96FFB07B57FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFB573FFFFB36EFFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFAA69
          42FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF000000000000000000000000000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          000000000000000000000000000016253754204787FF204787FF204787FF2047
          87FF204787FF204787FF204787FF204787FF32547DA40F101213000000000000
          00000000000000000000000000001B81C5FF00DCF9FF00D2F6FF00CBF8FF00A6
          E5FF0085D1FF00C2FFFF00B5FEFF00B0FFFF204787FF39404A54000000000000
          00000000000000000000000000002774BFFF0CF6FFFF00E2FFFF00DFFFFF0085
          CCFF004CA9FF00CAFFFF00BBFFFF00B6FFFF204787FF2D333C4200000000A363
          3FFFA5623AFFA5623AFFA5623AFF54414EFF4BC6EAFF00E8FFFF00DFFFFF00C7
          F5FF009EDEFF00C9FFFF00BEFFFF01B5FDFF204787FF0000000093695DFFFDFA
          F7FFFDFAF7FFA9673FFFFFEAD9FFF5A158FF3269B5FF2CF1FFFF00E6FFFF007F
          C7FF0044A4FF00C7FCFF00C7FFFF017FD4FF986131D6AC602CFE93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFB06AFFBF8E66FF4EA3DAFF00EFFFFF008B
          CEFF0047A7FF00C9FCFF00B9F8FF486996FFB3763BC1A4613AFF93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFAC62FFFFAF6AFF506993FF45E5FBFF008C
          CEFF0047A7FF00D2FFFF0178CFFFCF9B6CFFB37437C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA85CFFFBAA63FDEBA263FF347FCAFD0D9A
          D4FF0041A3FF01B9F0FF6C748AFFE5A871FFB37234C1AA5F2DFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA558FFFFA85DFFFFAD64FF88736FFF54C0
          E9FF00D6FBFF016BC1F9F6B87DFFE7A56CFFB36F30C1AA5E2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6A43FFFFEAD9FFFFA557FFFCA457FDFFA85DFFFCAA62FD3159
          91FF2077C3FF9D7F71FFFBB97CFDE5A165FFB36B2BC1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFAA6942FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEA
          D9FFFFB573FFFFB36EFFFFB776FFE69D5EFFB36926C1AA5F2CFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFAA6942FFAA6A43FFAA6A43FFAA6A43FFAA6840FFAA69
          42FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFFFEAD9FFAA5E2BFC93695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFAA6A
          44FFA9683FFFAA673EFFAA673EFFA8653CFFA5623AFF0000000093695DFFFDFA
          F7FFFDFAF7FFFFFFFFFFFDFDFDFDFFFFFFFFFDFDFDFDFDFAF7FFFDFAF7FFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF000000000000000093695DFFFDFA
          F7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FFFDFAF7FF93695DFF9369
          5DFF93695DFF93695DFF93695DFF000000000000000000000000000000009369
          5DFF93695DFF93695DFF93695DFF93695DFF93695DFF93695DFF000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000200D004DAC591EF16F2E
          00B2331300660502001700000000000000000000000000000000000000000000
          00000000000000000000000000000703001C000000008F3700D0D0C5CFFFE3DA
          DFFFFFFFFFFFBF7D52FFB6510AEA5C1F00990000000000000000000000000000
          0000000000000201000BA03B00D0E47F29FFBC550AFFCABDBDFFC5ACA7FFF6EE
          F0FFFFFFFFFFFFFFFFFFFFFFFFFFB2836DFF473A304A00000000000000000000
          00001B090043DA5200FFF1D2A8FFFFFFFFFFD3CACCFFFFFFFFFFC2A9A9FFF0E6
          E8FFF9F2F4FFF7F1F0FFFFFFFFFFBE9782FF4A3D33500000000000000000482D
          195ED6680DFFFFFFE5FFFFFFEEFFFFFFF2FFBAA29CFF99674FFFBA7547FFBF9C
          92FFCEC2C7FFF8F7FBFFFFFFFFFFBE9783FF4A3D335000000000000000009356
          26B3F4DEB0FFFFFFE3FFFFFDDBFFFFFFF0FFB9A597FFAC4A06FFFBE0C6FFEDA0
          5EFFE58534FFD29769FFBA9079FFB37A59FF44382F4700000000000000008E53
          26AFF0CA93FFFFF6CDFFFFF5CBFFFFFFE6FFCAB399FFF2F1F6FFCDC0BEFFCEC3
          C8FFAC683CFFAF5F29FFCF5D01FF340E00730000000000000000000000008E54
          27AFF0C388FFFFEBBEFFFFEBBCFFFDF1D7FFC0A388FFA57F65FFC0A58FFFD9C4
          A4FFC19168FFFAE8BBFFEA9B4FFF0200001A0000000000000000000000008E54
          28AFF0BB7AFFFFE2AFFFFFE3ACFFECD8BDFFCDB7B9FFF0E5E8FFB1958EFFA987
          7BFFD0BCACFFCFC2ADFFEA9441FF0400001F0000000000000000000000008E55
          29AFF0B46EFFFFD89FFFFFD89CFFEDD5B7FFC9B3B3FFF2E8E9FFC9B3AFFFA786
          7CFFFFFFFFFFE3E3E9FFD06D1DFF0400001F0000000000000000000000008E56
          2AAFF0AC62FFFFCF8EFFFFCF8CFFECCEAEFFCAB7BAFFF0E5E8FFF7F1F2FFFDFC
          FDFFFDFCFDFFE3E1E5FFD26F1DFF0400001F0000000000000000000000008E56
          2BAFF0A455FFFFC379FFFFC57EFFFFE0B8FFC4946EFFBE9B87FFBEA5A3FFD4C7
          CBFFFCFDFFFFE5E6EFFFD16B18FF0400001F0000000000000000000000008E56
          2CAFF19B44FFFFD8ABFFFFD6AAFFFFBE73FFFFC67AFFFFC87EFFFFCB80FFEDB6
          77FFCC9869FFC7A68BFFE6832CFF050000210000000000000000000000009258
          2AACEDA769FFFFC883FFFFB661FFFFB96BFFFFBB6EFFFFBB70FFFFBE73FFFFC7
          7EFFFFD58EFFED9844FFDD5F00F000000000000000000000000000000000130E
          0A248F3600C1D65900FEDF6D0EFFEA8328FFF79B43FFFFB362FFFFC174FFF2A1
          50FFD95F00FF6027008F00000000000000000000000000000000000000000000
          000000000000000000000502001B220E005940180091A14200D1B54E00EC7E33
          00B4040200170000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000015301BE000A00150000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000300070000000000260054037204F4108219F10155
          02BB000100030000000000000000000000000000000000000000000000000000
          00000001000200460075078A0BED20AF30FF30C248FF33C14DFF68FF9CFF30B4
          46FF046707D7015602B600000000000000000000000000000000000000000000
          00000064009C16AC20FF30CC48FF3BD75AFF4AE66EFF55F07FFF5DF88CFF76FF
          B1FF21A031FC0027005800290057000000010000000000000000000000000031
          004C0BA810FE22BB33FF2EC644FF1FB42DFF14A31EFE18A425FE52EA7CFF1C9E
          29FC001B003E0037008B08860CFF0038007C0000000000000000000000000058
          0092059F08FC12AD1DFF0CA512FB0025003E00040006001D0037058706FC0020
          003C003D008717A224FE25C938FF057708F50008001000000000000000000039
          007D014E02AB00240046002B0041000000000000000000000000004401720000
          00000037006D1FAF2EFF2ECB45FF17A122FF001F004C00000000000000000168
          02DA54E67EFF1E9D2EFF0D7F14EE026002C90144018B00000000000000000000
          0000002200401DA92AFF39D556FF21B132FF002500570000000000000000016E
          01D274FFB0FF67FF9BFF42D463FF004E00AB00000000000000000159019D0000
          0000005A00B03FD75EFF44E067FF19A426FE0016002C0000000000000000047C
          06E36AFF9FFF57F182FF48E06CFF005700B10000000000000000015E01AA0E96
          16FE2EC246FE52ED7CFF4BE671FF006D00C90000000000000000000000000482
          06EA039103FC4BE572FF49E46DFF25BA38FF005A00AB001D0037013801741AA2
          27FE65FE99FF5CF68BFF30C348FF006700BF0000000000000000000000000166
          01B10000000011A718F941DB60FF37D152FF2CC541FF17A623FF002500510587
          07E97AFFB7FF60FA91FF159E20FD016D02CD0143028900000000000000000000
          000000000000003D00570BA112F728C23DFF25C037FF1FBB2FFF006400C40159
          01A2159F1EFD026E02CB01440287000000000000000000000000000000000000
          00000000000000000000001B0028005C009D038504DF058F06EF007200D40014
          0021000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end>
  end
  object OpenPictureDialog1: TOpenPictureDialog
    DefaultExt = '*.jpg;*.jpeg;*.bmp;*.png;*.gif|*.jpg;*.jpeg'
    Filter = '*.jpg;*.jpeg;*.bmp;*.png;*.gif|*.jpg;*.jpeg;*.bmp;*.png;*.gif'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 849
    Top = 447
  end
  object cxStyleRepository3: TcxStyleRepository
    Left = 512
    Top = 288
    PixelsPerInch = 96
  end
  object cxImageList1: TcxImageList
    BkColor = 15790320
    Height = 32
    Width = 32
    FormatVersion = 1
    DesignInfo = 9830629
    ImageInfo = <
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000100000001000000010000000100000001000000010000
          0001000000010000000100000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000080000001F00000027000000270000002700000027000000270000
          002700000027000000270000001F000000080000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000001F0000007300000090000000920000009200000092000000920000
          00920000009200000090000000730000001F0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000007900FF007800FF007700FF007600FF007500FF007400FF007300FF0072
          00FF007100FF007000FF00000090000000270000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001007900FF4CD779FF33C25DFF34C25EFF33C05BFF31C05CFF32BF5BFF31BE
          5AFF2EB754FF007000FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001007A00FF68E78EFF3DD16CFF3ACF69FF39CE68FF38CD67FF39CC66FF37CB
          65FF33C25DFF007100FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001007B00FF6CE994FF43D672FF3DD36DFF3ED26CFF3CD16BFF3CD16BFF39CD
          67FF33C25DFF007200FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001007C00FF71EA96FF47D976FF3ED46EFF3ED46EFF3DD36DFF3CD16BFF39CF
          69FF34C460FF007300FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001007C00FF77EE9BFF4ADB77FF3FD56FFF3FD56FFF3ED46EFF3DD46EFF3CD0
          6AFF35C560FF007300FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000010000000100000001000000010000000100000001000000010000
          0001007D00FF7CEE9EFF4EDD7BFF41D771FF40D670FF3FD56FFF3ED46EFF3CD2
          6CFF36C661FF007400FF00000092000000280000000100000001000000010000
          0001000000010000000100000001000000010000000000000000000000000000
          00080000001F0000002700000027000000270000002700000027000000270000
          0028007E00FF80F1A0FF53E07FFF42D973FF41D872FF40D670FF41D771FF3DD3
          6DFF37C762FF007500FF0000009A000000470000002800000027000000270000
          00270000002700000027000000270000001F0000000800000000000000000000
          001F000000730000009000000092000000920000009200000092000000920000
          0092007F00FF6CED95FF55E080FF44DA74FF42D973FF41D872FF41D771FF3ED4
          6EFF38C863FF007600FF000000B10000009A0000009200000092000000920000
          0092000000920000009200000090000000730000001F00000000000000000088
          00FF008700FF008600FF008500FF008400FF008300FF008200FF008100FF0080
          00FF007F00FF4AE27DFF4BDF7AFF45DC76FF44DA74FF43D973FF42DA74FF3FD4
          6EFF3BCB66FF007600FF007600FF007500FF007300FF007300FF007100FF0070
          00FF007000FF006E00FF006E00FF000000900000002700000000000000010089
          00FF95FBB2FF5CE486FF46DD76FF48DC76FF46DC77FF47DB75FF45DB75FF45DB
          75FF46DC76FF47DE78FF47DE78FF46DD77FF45DC76FF44DB75FF43DA74FF41D7
          71FF3FD26CFF3CCD68FF3BCC67FF3ACB67FF39CA66FF38C863FF36C762FF36C6
          62FF34C661FF2DB753FF006E00FF00000092000000270000000100000001008A
          00FF96FAB0FF79EF9BFF5AE786FF54E683FF53E582FF54E382FF53E481FF50E2
          7EFF4FE17DFF50E37FFF4CE17CFF48DF79FF46DD77FF46DC76FF45DB75FF43DA
          74FF41D973FF40D56FFF3FD56FFF3FD46EFF3CD26CFF3BD16BFF3AD06AFF3ACE
          68FF37CA64FF2FBB57FF006F00FF00000092000000270000000100000001008A
          00FF97FBB2FF7EF29FFF62EA8CFF5CE989FF5CEA89FF58E886FF56E785FF56E6
          85FF56E482FF52E380FF52E27FFF4FE17DFF49DF7AFF47DD78FF46DD77FF45DB
          75FF43DA74FF42DA74FF41D771FF40D670FF40D670FF3DD36DFF3CD16BFF3CD1
          6BFF37CC66FF2FBC57FF007000FF00000092000000270000000100000001008B
          00FF98FCB2FF83F4A2FF65ED8FFF60EB8CFF61EB8BFF5EEA8AFF5CE989FF59E8
          87FF56E785FF55E583FF53E481FF51E37FFF50E37FFF4ADF7AFF47DE78FF46DC
          76FF44DB75FF43DA74FF41D872FF40D670FF3FD56FFF3ED46EFF3DD36DFF3CD1
          6BFF38CD67FF31BB56FF007000FF00000092000000270000000100000001008C
          00FF9AFBB3FF86F4A4FF6BEF93FF65ED8FFF63EC8EFF61EC8CFF60EB8BFF5EEA
          8AFF5BE988FF57E786FF56E684FF54E482FF51E37FFF50E27FFF49DF7AFF46DD
          77FF45DC76FF44DA74FF42D973FF41D872FF40D670FF3FD56FFF3ED46EFF3ED2
          6CFF3ACE68FF30BC57FF007100FF00000092000000270000000100000001008C
          00FF9CFCB4FF89F5A5FF71F197FF6BF094FF6BEF93FF69EE91FF65ED90FF63EC
          8EFF62EB8DFF5EE98AFF58E886FF56E684FF54E482FF51E37FFF4FE17DFF48DF
          79FF46DD77FF45DC76FF44DA74FF41D973FF41D771FF40D670FF3ED46EFF3DD3
          6DFF3ACF69FF31BD58FF007200FF00000092000000270000000100000000008D
          00FF9EFDB6FF8FF6A9FF8AF6A7FF88F5A6FF87F6A5FF85F4A3FF84F3A3FF82F4
          A1FF81F3A0FF7AF19CFF62EA8DFF58E886FF56E684FF53E481FF52E27FFF4CE1
          7CFF48DF79FF51E17FFF5BE486FF58E183FF54DF7FFF4FDD7CFF4CDA79FF47D8
          75FF3FD26DFF32BF5BFF007300FF00000090000000270000000000000000008E
          00FFACFFC2FF9EFDB5FF9CFDB4FF9BFDB5FF9CFCB3FF9AFCB4FF99FBB2FF98FB
          B3FF98F9B0FF90F5AAFF7BF19CFF5EE98AFF57E786FF55E583FF52E380FF4DE1
          7CFF47DE78FF4EE581FF7AF09CFF84F2A2FF80EFA0FF7CEF9DFF77EC9AFF70EB
          96FF6DE893FF4ED87AFF007300FF000000730000001F0000000000000000008E
          00FF008E00FF008C00FF008C00FF008B00FF008A00FF008900FF008800FF0087
          00FF008600FF98F8B1FF7FF39FFF62EB8DFF5BE988FF56E785FF56E682FF4BDF
          7AFF46DB76FF007D00FF007C00FF007B00FF007A00FF007900FF007800FF0077
          00FF007600FF007500FF007400FF0000001F0000000800000000000000000000
          0000000000010000000100000001000000010000000100000001000000010000
          0001008600FF99FBB1FF81F2A0FF62EC8DFF5EEA8AFF59E887FF57E685FF4EE1
          7BFF42D56FFF007E00FF00000092000000280000000100000001000000010000
          0001000000010000000100000001000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001008700FF9AFBB3FF83F3A2FF66ED8FFF60EB8BFF5DE989FF56E785FF4EE1
          7DFF42D46FFF007F00FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001008800FF9BFCB4FF84F4A3FF67EE91FF61EC8CFF5EEA8AFF58E986FF50E2
          7EFF42D570FF007F00FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001008900FF9CFCB4FF86F6A4FF69EF93FF63EC8EFF61EB8BFF5CE889FF4FE3
          7FFF44D56FFF008000FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001008A00FF9CFCB5FF87F5A5FF6BF094FF65ED8FFF60EB8CFF5DE98AFF4FE3
          7EFF43D46FFF008100FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001008A00FF9DFDB4FF8AF6A6FF72F197FF6CEF94FF67ED90FF63EB8DFF55E4
          82FF43D671FF008100FF00000092000000270000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000008B00FF9EFDB5FF8FF7A9FF8BF5A7FF88F4A5FF84F4A3FF80F2A0FF7AEF
          9CFF50DC7BFF008200FF00000090000000270000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000008C00FFACFFC0FF9EFDB5FF9CFCB5FF9AFDB5FF98FBB2FF96FAB1FF97FA
          B1FF93F9AFFF008300FF000000730000001F0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000008C00FF008B00FF008A00FF008A00FF008800FF008800FF008700FF0085
          00FF008500FF008300FF0000001F000000080000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000100000001000000010000000100000001000000010000
          0001000000010000000100000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000100000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000004000000140000002100000022000000180000000B0000
          0002000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000040000000D0000000E00000005000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000040000001F000000570000007F00000082000000680000003F0000
          001C000000070000000100000000000000000000000000000000000000000000
          000000000000000000040000001D000000450000004A0000002C000000160000
          000C000000040000000000000000000000000000000000000000000000000000
          00010000011500004496000093EE00008EEB000050BB0000119F000000920000
          0066000000310000000F00000002000000000000000000000000000000000000
          000000000005000000200000388900002B9B00000299000000840000005E0000
          0042000000220000000800000000000000000000000000000000000000000000
          000600004A850612BBFE1544EBFF123CD6FF0A21B9FF0204A6FD000051B90000
          05A1000000800000004600000019000000040000000000000000000000000000
          00060000002200004695020AAAFE0311ADFF000084EA00002EA900001B9D0000
          02950000006C0000002C00000008000000000000000000000000000000000000
          0C210000A2F21A4BFDFF1949FAFF1847F4FF1745EDFF143DD4FF081AB0FF0000
          89E5000016A20000009000000057000000200000000600000000000000060000
          002200004D9B030BAEFE0D3CF0FF0B38E4FF072BC4FF0310A9FF0107A0FF0000
          5FC9000002A00000006D00000027000000050000000000000000000000000000
          45750C21CFFF1E52FFFF1B4DFFFF1A4BFCFF194AF9FF1947F4FF1743E5FF0F2D
          BEFF0201A2FA000031A80000009900000063000000270000000D000000240000
          529F040DB3FF0F41F3FF0F3DF3FF0C3BEEFF0B38E8FF0937E4FF0834D7FF0211
          A4FF000057C50000029E0000005E000000190000000100000000000000000000
          81C42249F0FF295BFFFF2152FEFF1E4FFEFF1D4EFFFF1C4DFDFF1A4AF6FF1947
          EDFF1339CBFF0409A8FE00004BB50000019E0000006D00000043000054A2050F
          B4FE1344F6FF1041F5FF0F40F5FF0E3DF4FF0D3BF1FF0B3AEDFF0B37E8FF0831
          D4FF020DA2FF00003CB00000008E000000370000000800000000000000000000
          4E6D0204AEF82246E8FF295CFFFF2354FFFF2051FFFF1F50FFFF1E50FFFF1C4D
          F9FF1A49F1FF1640D4FF0610ABFF000058C0000003A4000049AC060FB6FE1547
          F9FF1444F7FF1242F6FF1141F5FF0F3FF4FF0E3DF3FF0D3CF3FF0B3BEFFF0B37
          E8FF082ECAFF00029AFB00000C9B000000560000001200000000000000000000
          000000004B761225CFFF2D60FFFF2658FFFF2455FFFF2354FFFF2253FFFF2051
          FFFF1E4FFBFF1C4AF4FF1744DCFF0815ADFF000081E20610B8FF184BFBFF1747
          FAFF1445F8FF1344F8FF1243F7FF1141F5FF0F3FF4FF0E3DF3FF0D3CF3FF0B39
          EEFF0937E5FF0418B3FF000035A6000000580000001300000000000000000000
          0000000065961F3EE2FF2F62FFFF2A5BFFFF2859FFFF2758FFFF2657FFFF2457
          FFFF2355FFFF2051FDFF1C4BF6FF1946E2FF0D26C9FF194BF8FF1A4AFCFF1848
          FAFF1647FAFF1545F9FF1344F8FF1243F7FF1141F5FF0F3FF4FF0E3DF3FF0E3D
          F3FF0C3DF5FF0418BDFF000054B00000002C0000000700000000000000000000
          0000000080B3325AF3FF396AFFFF3162FFFF2D5DFFFF2A5BFFFF295AFFFF2859
          FFFF2858FFFF2657FFFF2353FEFF1D4DF7FF1D4CF7FF1B4DFCFF1B4BFEFF1A4A
          FCFF1849FBFF1647FAFF1545F9FF1344F8FF1243F7FF1142F5FF1041F7FF0E3D
          F2FF030EB4FE000067B900000C33000000090000000100000000000000000000
          000000006D8B0B13C0FE3D67F6FF4073FFFF3666FFFF3162FFFF2D5EFFFF2B5C
          FFFF295AFFFF2859FFFF2659FFFF2555FEFF2152FFFF1F50FEFF1D4EFEFF1B4C
          FDFF1A4AFCFF1849FBFF1647FAFF1545F9FF1345F7FF1345F9FF0E39E9FF0102
          A4FA0000468A0000001B00000004000000000000000000000000000000000000
          00000000000000003D5000009EE5243CD9FF477AFFFF3D6EFFFF3666FFFF3061
          FFFF2D5EFFFF2B5CFFFF295AFFFF295AFFFF2556FFFF2253FFFF1F50FFFF1D4F
          FEFF1B4CFDFF1A4AFCFF1849FBFF1648FBFF1548FCFF0E31E1FF000093EE0000
          2864000000120000000300000000000000000000000000000000000000000000
          0000000000000000000000000C110000739F0A0EBEFD3F69F5FF4577FFFF3A69
          FFFF3363FFFF2F60FFFF2C5DFFFF2A5AFFFF2859FFFF2758FFFF2354FFFF2051
          FFFF1D4FFEFF1B4CFDFF194BFDFF184CFDFF0E2CD7FF000084DE0000174F0000
          000E000000010000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000364800009CE3273FDAFF4B7D
          FFFF3E6DFFFF3565FFFF3061FFFF2D5EFFFF2A5BFFFF2959FFFF2657FFFF2354
          FFFF1F50FEFF1C4EFDFF1C4FFEFF0D28D4FF000079D500000E4F0000000E0000
          0001000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000E12000072AB1018
          C1FE4475FFFF3A69FFFF3464FFFF3163FFFF2E5FFFFF2A5BFFFF2A59FFFF2658
          FFFF2254FEFF1C4DF8FF102CD4FF00007FDD000006970000004A000000100000
          0001000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000200002D540B12
          BEFE4476FFFF3B6BFFFF3666FFFF3464FFFF3162FFFF2E5FFFFF2A5BFFFF2859
          FFFF2555FEFF1D4EF6FF173ED7FF0100A2F9000013A200000080000000320000
          0008000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000A000084C13355
          EBFF4273FFFF3D6CFFFF3969FFFF3666FFFF3464FFFF3162FFFF2D5EFFFF2A5A
          FFFF295AFEFF2152FCFF1C4AEFFF112EBEFF000089E3000005A10000006A0000
          0022000000040000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000001000026440A0EC1FE4C7F
          FFFF4372FFFF3F6FFFFF3C6CFFFF3969FFFF3666FFFF3464FFFF3161FFFF2C5D
          FFFF295AFFFF2758FFFF1F50FAFF1B48E7FF0A1CB3FF000060C00000009A0000
          0053000000150000000100000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000007000071A7314EE4FF4D7D
          FFFF4574FFFF4170FFFF3F70FFFF3C6CFFFF396AFFFF3A6CFFFF3969FFFF3262
          FFFF2B5CFFFF2859FFFF2556FEFF1D4DF7FF1944DAFF030AACFE00002EA60000
          008A0000003C0000000B00000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000F240100B4F65484FFFF4B7B
          FFFF4776FFFF4473FFFF4270FFFF3E6CFFFF3B6EFFFF2A4BE8FF4374FFFF3B6A
          FFFF3061FFFF2A5AFFFF2859FEFF2153FDFF1C4AF2FF1437C9FF0000A0F30000
          0BA2000000730000002700000005000000000000000000000000000000000000
          0000000000000000000000000000000000020000537D263BD9FF5687FFFF4D7C
          FFFF4A78FFFF4675FFFF4273FFFF3E6FFFFF2D53F2FF00009FF10D13C0FE4576
          FFFF3968FFFF2E5FFFFF2859FFFF2456FFFF1E4FFAFF1A48EBFF0C23B7FF0000
          70CE0000019D0000005900000017000000010000000000000000000000000000
          00000000000000000000000000000000000900009CD55179F7FF5584FFFF4F7D
          FFFF4C7AFFFF4A78FFFF4473FFFF3D6EFFFF0204B7FA00001F72000053800C12
          C2FE4374FFFF3666FFFF2C5DFFFF2657FFFF2353FFFF1C4CF7FF1944DEFF060F
          AFFF000035A90000008D0000003E0000000B0000000000000000000000000000
          00000000000000000000000000000000253D0D14CAFE6294FFFF5685FFFF517F
          FFFF4D7CFFFF4A79FFFF4477FFFF1628D3FF00004DA00000002C000000060000
          62800F18C6FE4274FFFF3263FFFF295AFFFF2354FEFF1E4EFCFF1B48F2FF1338
          CBFF0000A5F600000DA100000075000000270000000400000000000000000000
          00000000000000000000000000000000668E364EE2FF6090FFFF5785FFFF5381
          FFFF507EFFFF4A7AFFFF345BF2FF00008EDB0000044A0000000F000000000000
          000000006C901321CAFE3E72FFFF2E60FFFF2657FFFF2051FFFF1B4CF9FF1846
          EBFF0C24B8FF000075D00000019D000000550000001200000000000000000000
          00000000000000000000000000000000ACD86893FDFF6593FFFF5B88FFFF5583
          FFFF507EFFFF4A7CFFFF070DC5FE0000277D0000001F00000003000000000000
          000000000102000075A4192DD4FF3A6EFFFF2B5BFFFF2253FFFF1D4EFEFF1949
          F5FF1642DDFF050FB0FF000032A7000000750000001D00000000000000000000
          000000000000000000000000000000008DB03D52E0FF79A9FFFF6795FFFF5C8A
          FFFF5281FFFF2744E4FF00006DB9000000390000000900000000000000000000
          00000000000000000406000088C01F3ADEFF3368FFFF2657FFFF1F50FEFF1B4D
          FFFF194DFDFF143FE1FF00009EED000000560000001400000000000000000000
          000000000000000000000000000000000A0C00008DB9222DD4FF587BF2FF709F
          FFFF5484FFFF0000B5F400001163000000170000000100000000000000000000
          0000000000000000000000000E12000096D42547E9FF2E61FFFF2357FFFF1B49
          F9FF0C23D8FF0002B0F70000649C000000170000000500000000000000000000
          0000000000000000000000000000000000000000020300004D6000008FB60B0E
          C8FC1823D1FF0000589000000022000000050000000000000000000000000000
          0000000000000000000000000000000019200000A5E51F3FE7FF0A16CBFF0000
          96DF000053850000112700000007000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          1E28000066890000061700000005000000000000000000000000000000000000
          0000000000000000000000000000000000000000263300008EC80000365C0000
          0212000000040000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000010000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0002000000070000000F000000170000001C0000002200000024000000270000
          00270000002700000027000000240000001F0000001900000010000000070000
          0001000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000100000007000000140000
          0024000000370000004E00000063000000730000008000000089000000900000
          0091000000910000008F000000860000007B0000006900000051000000320000
          0017000000050000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000500000017000000350000005C1512
          128232251D99593F2FAF7B5137C4A16740DEAD6939EACC7C43FFCC7637FFCF79
          36FFCF7B36FEAD6123E78D5121D3653D1DBA372516A40A09089B0000008A0000
          005A000000210000000400000000000000000000000000000000000000000000
          000000000000000000000000000600000024121010645B453EA4B67F6ADED388
          67FFD8987FFFDBAB97FFDDBAABFFE2C7BDFFFFEBE5FFFFFBF6FFFAECE7FFD8C9
          C3FFC4B1A6FFEACDB7FFEABE9AFFE5A76FFFD37D31FFC2610CF7513315AE0202
          0297000000540000001200000000000000000000000000000000000000000000
          000000000000000000010404041E644E4B9BC38579F7DEAFA3FFEAD1CEFFA39E
          A1FF818285FF9A9898FFA49F9EFFBBB0ACFFBEB2ACFFAAA49CFFAFABA1FFB0AB
          9FFFA8A193FFBBAE9BFFD7BBA6FFDCBDA2FFF8D2B1FFF0BD8EFFCD6E19FF5234
          18AC000000750000001D00000001000000000000000000000000000000000000
          00000000000000000005896A69A7D19F9CFFFFF8F9FFFFFFFFFFEEF1F2FF7273
          73FF828381FF868583FF878582FF888683FFA5A19BFF908B84FF7B756CFF7F76
          6CFFB9B0A2FFB4AA98FFB7A58EFFD5B597FFD9B18DFFEFC097FFD9924EFF904F
          0FCC000000880000002700000002000000000000000000000000000000000000
          0000000000001C1C1C27CB9191FFFFFFFFFFFFFFFFFFF4F6F6FFF2F2F2FFB0B0
          AFFF959293FF9E9A9BFF9D9A99FF9D9A96FFB3AFA9FFB0ABA4FFB0AAA1FF847D
          72FFBCB4A6FFC0B6A4FFBBAB94FFBCA588FFCBA783FFC79D74FFE1AB71FFB957
          00EF010101960000003700000007000000000000000000000000000000000000
          00000000000042373751D0A2A2FFFFFCFCFFEFEFEFFFEAEBEBFFD9DADAFFD3D2
          D2FFADA8ACFF689065FFA5A09EFFB2A2AAFFD2C8C8FFC6C0BAFFC3BDB4FF968F
          84FFABA296FFDACEBDFFCDBCA7FFC7B094FFC2A582FFBF996EFFD9B082FFC857
          00FF100D0A990000004B0000000E000000000000000000000000000000000000
          0000000000006A56567EDAB1A7FFF8E3DAFFE3E4E5FFE2E2E2FFCBCACBFFC9C1
          C8FFDBC4D8FF277D24FF007A00FF095A02FF65845CFFBFB4B3FFDAD1CBFFAFA8
          9CFF9D9688FFE0D6C5FFD4C5AFFFCFBA9EFFCBAE8BFFBF9C71FFE5BD8FFFD06C
          08FF31200F9F0000006000000015000000000000000000000000000000000000
          0000000000018F7577A7E4C0ADFFDFDED9FFDADADCFFDED9DEFFCEC0CDFF6596
          64FF0C7C0AFF008606FF4FE978FF61FF95FF13A028FF0A6D07FFFEECEEFFCCC2
          BAFFC1B6ACFFE8DDCEFFDBCDB7FFD7C1A5FFCEB18FFFBE9A70FFF0C597FFD680
          2AFF57320DAE000000750000001D000000010000000000000000000000000000
          000000000002B39193D1E8D1C4FFE9EDF0FFD8D2D8FFCDCACCFF0F8E0CFF09A7
          16FF40DF62FF53F07EFF5EFA8DFF62FF97FF007100FFFAE9ECFF6D9F65FF0059
          00FFD7C8C2FFE2D4C6FFD7C8B2FFDAC5A9FFDABD9BFFCFAD82FFF2C899FFDD94
          49FF8B4C0DC90000008800000027000000020000000000000000000000000000
          00000303030AC39C9EF6F3D7BBFFFAF6F9FFCFC8D0FF009300FF17B729FF37D4
          54FF2AC844FF17B028FF2DC045FF008F08FFC0CCB5FFBEC9B3FF007500FF06A1
          14FF3D7F35FFF5E1DAFFDDCEB9FFDBC7ADFFD3B795FFE5C099FFF2C698FFE4A8
          69FFB55200EC0000009500000037000000070000000000000000000000000000
          000028252534C69E9FFFF8DEBFFFFFEFEAFF55B757FF05AA0DFF28C53EFF009F
          01FF369033FF8B9F85FF007A00FF548E4EFFFFF3FCFF006D00FF25C63CFF28C9
          3DFF006800FFFBE6E0FFE8D8C5FFDFC9B0FFBAA07DFFC4A179FFEEC293FFECBC
          86FFC75400FF100E0B980000004A0000000E0000000000000000000000000000
          00004F45465FD2AEA9FFFADDBFFFF2EAD9FF008900FF009C00FF009C00FF5CB4
          5AFFE3CDE2FFDBC9D9FF399E37FFD4C1CEFFFBE8F1FF499842FF20B936FF34D2
          4FFF007A00FFF0E7D7FFF2E2D0FFA69279FFBCA181FFB6946CFFB48B5CFFDCAD
          79FFD06A04FF2D1D0D9E00000060000000150000000000000000000000000000
          000174656688DABBB1FFF9DCBFFFFDF7FBFFE1ECE3FFD6DBD5FFB8C7B7FFDAD1
          DAFFC7BEC6FFE1DCDFFFE7DEE3FFF3E9EDFFF9E4EFFF539E4BFF27C241FF3EDD
          5FFF007800FFECD8D3FFC5B6A4FFBBA78EFFC4AB8CFFC09F78FFBA8F62FFCC9B
          66FFD67F25FF583510AE000000750000001D0000000100000000000000000000
          0001998687B1E2C5B6FFFFDFC9FF8CBB81FF368F33FF3A8735FF377C34FF3C83
          3CFF599A5AFFF7F5F5FFD3CDCFFF79BE76FFB7C5AFFF008500FF4CEA74FF3AD6
          5AFF217C19FFDABFBFFFC4B6A3FFC5B299FFCFB697FFC9AA84FFC1986BFFC797
          62FFDE9141FF86480BC600000088000000270000000200000000000000000000
          0004C0A8AADCEACFB9FFFFE2D0FF46A240FF44E671FF5AFB8DFF31C64EFF026B
          00FF929692FFD2CDD0FFECDCE7FF1FA21CFF00A308FF40DB62FF58F483FF099B
          12FF399432FF8EAF7EFFD2C1B2FFCCBAA1FFD9C2A2FFD2B38EFFC8A072FFC290
          5CFFE5A15CFFB85900EE00000094000000360000000700000000000000000B0B
          0B14C9B0B3FCF3D7BBFFFFE6DAFF34A335FF5AF98DFF5FFA8FFF48E36EFF0B71
          06FFB09CAFFF9E919CFF978992FF94BF8EFF20C73AFF6AFF9FFF63FF96FF1CBD
          32FF008600FFADBA9BFFD9CBBAFFE6D3BBFFE4CAACFFDBBD99FFD0A87CFFC291
          5EFFE9B074FFC75400FF0F0D0A990000004A0000000D0000000000000000322F
          303FC8AFB0FFF6DBBCFFFFE7DEFF1DA322FF1BBA30FF4EEA78FF4CE872FF27C0
          3FFF008201FF007800FF578354FFDEC6D9FF009B00FF65FF9CFF00A808FF4B93
          3FFFBCA3A6FFCDBEB5FFEEE2D2FFF4E2CCFFF0D8BAFFE7C8A3FFD8B185FFD3A2
          6DFFE8B176FFCB6500FF2F1F109F0000005F000000150000000000000000534C
          4D65D3BBB6FFF4D9BCFFFFDFD2FF009400FF45AE46FF00A308FF40DC63FF3AD5
          57FF32D04DFF21C337FF1B841BFFFFFDFFFF4CB347FF009000FF849076FFA28E
          91FF9E948CFFC3BAADFFA79B89FFE2D1B9FFE3CBAEFFDDBF9BFFDAB488FFECBC
          86FFE7AE74FFD17619FF55330FAD000000740000001C00000001000000017B71
          7291DDC6B9FFF4D8BCFFFDDCC7FFB2C98CFFFFEEF8FF81BC72FF009500FF05AC
          15FF0BAE1BFF01A40DFF007100FFEDDFB7FFF1EDCEFFC4B8BCFFC3B9B7FFB7B0
          A8FFBAB1A6FFB7AFA1FFB3A897FFE1D1BAFFEAD3B6FFE3C5A3FFF0CA9FFFEBBD
          88FFE5AD73FFD78430FF8B4E11C600000087000000260000000100000001A196
          98B9E3CCBCFFF5D7BCFFF4D9C1FFF9DDC7FFFADDC4FFFFE2D1FFEFDFCEFF90C5
          81FF6AB967FF85C183FFCDD09DFFFFEACFFFFFEFD1FFEADFCDFFCCC8C2FFCCC6
          BDFFCAC3B8FFC9C0B3FFC6BAAAFFDFD0B9FFF2DCBFFFF2D4B0FFF1CDA2FFECBC
          89FFE6AE73FFDC9246FFC86B0DEC00000095000000350000000600000004C5B9
          BCE3EDD5BDFFF3D8BCFFF2D9BEFFF4DBC2FFF4DCC2FFF4DDC4FFFBE1C9FFFFE5
          D2FFFFE5D1FFFFE2C5FFFFE3C6FFFDE6C8FFFEECCCFFFFEED2FFE8DFD6FFDED9
          D3FFDCD5CBFFDAD1C4FFD6CBBDFFEDDBC1FFFBE3C4FFF4D7B4FFF0CDA1FFEBBD
          8BFFE5AD73FFE09F5CFFCC5B00FF0E0D0B990000004A0000000D0E0E0E17CCBF
          C2FFF5DABEFFF2D7BCFFF2D9BEFFF3DBC2FFF4DCC2FFF4DDC4FFF5DFC6FFF6E1
          C8FFF7E0C5FFF6DAB6FFF8DFBBFFFBE4C3FFFDE9C9FFFFECCDFFFFEECEFFF8EA
          D7FFEEE7DBFFF4E6D2FFFFEED3FFFFE8CAFFF8DFBDFFF4D6B0FFF1CBA0FFECBE
          8BFFE6AE74FFE0A25FFFCB6300FF27190C9F0000005F0000001432303147CBBF
          BFFFF5DBBEFFF2D7BCFFF2D8BEFFF4DBC1FFF4DAC0FFF4DBC0FFF5DEC4FFF9E6
          D0FFFAECD9FFF9EBD9FFFBF5E9FFFEF9F2FFFEFBF7FFFEFDFBFFFFFEFBFFFFFE
          FBFFFFFEFBFFFFFDFCFFFFFDFBFFFFFBF6FFFCF5EBFFFBEDDFFFF6E1C8FFF0CA
          9FFFE5A969FFE09B55FFCF6D0CFF4A2D0EAD000000730000001C53505071D5C8
          C1FFF5D9BEFFF2D4B6FFF3DAC2FFF9ECE0FFFDFAF8FFFFFFFFFFFBF5EDFFF9ED
          DEFFF7E6D0FFF8E3CBFFF9E3C6FFFAE4C5FFFCE8C9FFFEEDCEFFFFEDD2FFFFF0
          D7FFFFF2DBFFFFF4E1FFFFF6E9FFFFF8EFFFFFFDF8FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFF6E4D1FFD57F28FF79420CC500000084000000227572729ADFCE
          C0FFF8E5D2FFFFFFFFFFFDF9F4FFEFD3B1FFE9BA88FFE8B47AFFECBE8BFFF0C8
          9AFFF3D0A9FFF5D9B3FFF8DEBCFFFAE3C3FFFCE8CAFFFEEDD1FFFFEED5FFFFF0
          D9FFFFF2DEFFFFF3E3FFFFF5E8FFFFF8EDFFFFFAF3FFFFFCF9FFFFFEFEFFFFFF
          FFFFFFFFFFFFFFFFFFFFFCF8F5FFB25800EB0000007E00000020979494C3EEE9
          E6FFFEFBF5FFDC944DFFD78735FFE2A05FFFE6AF75FFE9BA86FFEDC293FFF0CA
          9FFFF3D2ABFFF5DAB5FFF8DDBCFFFAE2C3FFFCE8CAFFFEEED2FFFFEED5FFFFF0
          D9FFFFF1DEFFFFF3E2FFFFF5E7FFFFF7EDFFFFFAF2FFFFFCF8FFFFFEFEFFFFFF
          FFFFFFFFFFFFFFFFFFFFFBF3EAFFBA5F00F10000005000000012BBBABAECFFFF
          FFFFD7822DFFCE6E0DFFDB9043FFE1A567FFE6B077FFE9B985FFECC294FFF0CA
          9FFFF2D2ACFFF5D8B6FFF7DDBBFFF9E2C2FFFCE8CAFFFEECD0FFFFEED4FFFFF0
          D9FFFFF1DDFFFFF3E2FFFFF5E7FFFFF7ECFFFFF9F3FFFFFFFEFFFFFFFFFFFFFF
          FFFFFFFFFFFFE8BD92FFCC5F00FE553615810000001700000004969696BCE1E3
          E6FFFFFFFDFFEBBA89FFE2A15EFFE19D57FFE4A767FFE8B37AFFECBC89FFEFC7
          96FFF2CEA4FFF5D6B0FFF7DCB7FFF9E1BFFFFCE7C6FFFFECD0FFFFEFD4FFFFF3
          DCFFFFF5E3FFFFFBF1FFFFFFFFFFFFFFFFFFFFFFFFFFFBF2EAFFEBC4A0FFD88A
          3AFFCA5600FD9E540BBD3728164D0000000C00000002000000000F0F0F108081
          8192C3C6C6F2DEE3E8FFEDF6FEFFF8FFFFFFFBFAF9FFFEF6EFFFFEF4EAFFFFF5
          E8FFFFF6EBFFFFF9EDFFFFFBF0FFFFFCF3FFFFFDF6FFFFFAF1FFFAF2E9FFF5E7
          DAFFEDDAC4FFE6C3A1FFDDA976FFD0863DFFC96708FEC66D14E5965515AE5E39
          1472181510270000000700000001000000000000000000000000000000000000
          00000B0B0B0C3939394866666783858482AD9F9993CCB4AAA1E6C9B9A8FBCBB6
          A2FFCAB196FFCAA98BFFC9A37FFFC9A076FFCB9D70FFB68758EBAC7E4EDD9A6B
          3FC6835A31AC6F4D2A9353391F713A2C1D501817132300000005000000010000
          0001000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000030000000900000003000000000000000000000000000000000000
          0000000000000000000000000001000000010000000000000000000000000000
          0000000000000000000000000000000000080000001F00000027000000270000
          00270000001F0000000800000000000000000000000000000000000000000000
          00000000000E0000002B00000017000000040000000000000000000000000000
          000000000000000000030000000C000000100000000400000000000000000000
          00000000000000000000000000000000001F0000007300000090000000920000
          0090000000730000001F00000000000000000000000000000000000000000000
          0000002E006A000000590000004A000000160000000100000000000000000000
          0000000000030000001700060043000000350000000E00000000000000000000
          0000000000000000000000000000009300FF009300FF009300FF009300FF0093
          00FF000000900000002700000000000000000000000000000000000000000000
          0000005B00C400240091000000830000003F0000000D00000000000000000000
          00020000001500210076002800950000004A0000001000000000000000000000
          0000000000010000000100000001009300FF35CE5FFF31CA59FF1DB634FF0093
          00FF000000920000002800000001000000010000000100000000000000000000
          0001006000D2006700F5000B009E0000007A0000002E00000007000000020000
          0013001D006D006600F8001F009C0000004B0000000E00000000000000000000
          00080000001F0000002700000028009300FF54ED92FF4FE88AFF2EC750FF0093
          00FF0000009A0000004700000028000000270000001F00000008000000000000
          0001006600E0089611FF004F00D9000200A00000006500000021000000140019
          0065006700F4027A04FF0019009B000000460000000C00000000000000000000
          001F000000730000009000000092009300FF53EC8EFF4CE584FF2BC54BFF0093
          00FF000000B10000009A0000009200000090000000730000001F000000000000
          0001006C00EC10B223FF06860CFF003400B7000000980000005B001500650062
          00F00DA51AFF047F08FF00140097000000400000000A00000000000000000093
          00FF009300FF009300FF009300FF009300FF53EC8DFF4DE684FF29C247FF0093
          00FF009300FF009300FF009300FF009300FF0000009000000027000000000001
          0007006D00F713B229FF13B125FF027904FE001700A4000A0098005F00EC0CA0
          1BFF12B226FF047B07FF001000950000003A0000000800000000000000010093
          00FF42DB6DFF39D25FFF37D05AFF3CD564FF50E986FF4CE581FF3FD86AFF27C0
          44FF2AC34AFF2CC54FFF1DB634FF009300FF0000009200000027000000000005
          0010007100FC16B42FFF13AF2AFF13AB27FF006300F1005C00E80F9F1EFF13AF
          29FF14B22BFF027A04FF000C0093000000350000000600000000000000050093
          00FF65FEA4FF58F190FF56EF8EFF52EB88FF4FE882FF4CE580FF4CE581FF4DE6
          85FF4CE584FF4EE78AFF33CC5AFF009300FF000000900000002700000000000A
          001D007501FE19B634FF16AF2EFF19B532FF0B8C18FF0A8915FF17B531FF15AE
          2CFF18B532FF027803FF000800910000002F00000004000000040000001F0093
          00FF6DFFAFFF61FA9CFF5EF798FF57F08FFF52EB86FF4FE882FF50E986FF53EC
          8CFF53EC8DFF53EC91FF36CF5FFF009300FF000000730000001F000000000011
          002E027B05FF1CB93AFF19B234FF1BB736FF0F8D1EFF109422FF19B535FF18B1
          32FF1BB937FF007600FE0004008E0000002B00000008000000204C64509C0093
          00FF009300FF009300FF009300FF009300FF58F190FF52EB88FF39D25FFF0093
          00FF009300FF009300FF009300FF009300FF0000001F00000008000000000016
          003B04830AFF1FBB3FFF1CB539FF1CB83CFF119023FF15A02CFF1CB739FF1BB4
          37FF1DBB3DFF007400FB0002008D0000002F0000002905350D8CB8DBBDFED3F5
          DEFFC6F6D6FFC6F7D7FFD3EBD7FF009300FF60F99BFF58F18FFF2FC84DFF0093
          00FF37373799000000340000000900000004000000010000000000000000001D
          004909880FFF22BE45FF1FB83FFF1FBB40FF15942AFF1AA936FF1FB93EFF1EB8
          3DFF22BE44FF007100F30000009000020054084613A5199630FE49E37DFF4AE5
          7FFF47E07AFF4DEA84FFD0E6D2FE009300FF62FB9EFF59F292FF33CD53FF0093
          00FF0000009C0000004F0000002B000000160000000400000000000000000025
          00580A8F16FF25C14BFF21BA45FF22BD46FF199B32FF1EB33EFF21BC44FF20B9
          44FF22BD47FF006300E9010301A30B5219C023A440FF4FEB85FF4CE57FFF48E1
          7BFF49E37DFF4AE882FFCEE0D0FB009300FF6CFFAEFF64FDA3FF39D25DFF0093
          00FF000501A9000601910006016E00000030000000090000000000000000002B
          00660E961DFF28C452FF24BD4AFF25C04CFF1EA13CFF22BB47FF24BE4AFF23BD
          49FF22BA45FF006200EA0E6720D52FB953FF52EF89FF4DE680FF4AE37DFF4BE5
          7FFF4EEB85FF188C26FFD0E5D1FF009300FF009300FF009300FF009300FF0093
          00FFBDDCC0FF097512F80227047A000000160000000300000000000000000032
          0073129D24FF2BC756FF27C050FF27C352FF23AA46FF26BF4FFF28C14EFF27C2
          51FF20B644FF108C27FF3CCC67FF54F08AFF4EE781FF4CE57FFF4EE882FF4CE6
          80FF15851FFF1E9630FFC8FAD9FFC7F8D9FFC6F7D8FFC6F7D8FFC8FADBFFC9F1
          D5FFC2DDC4FA021D046100000012000000020000000000000000000000000039
          008116A32CFF2DC75CFF2AC356FF2AC555FF28B450FF2BC555FF2AC557FF25B7
          4BFF179631FF47DB76FF57F28CFF51EB85FF50E983FF51EC86FF49E17BFF1887
          21FF31B650FF4FEE88FF4AE47EFF46DF79FF46E07AFF4BE983FF2AB14BFF055E
          0DDB0112034A0000000D00000001000000000000000000000000000000000041
          008E1BAB36FF30CA62FF2DC65CFF2DC75BFF2DC15DFF2FCA5DFF23B249FF1C9E
          39FF50E983FF56F28CFF52EB85FF51EA84FF53EE88FF47DB75FF20952FFF40CF
          69FF50EC86FF4BE47EFF49E37DFF49E37DFF4BE983FF22A33DFF085410C50009
          0136000000090000000100000000000000000000000000000000000000010047
          009B21B241FF33CD68FF30C962FF31CB63FF31CD64FF23AE47FF25AC47FF59F2
          8CFF58F28CFF54ED87FF53EC86FF55F08AFF46D56FFF2CA640FF4ADF79FF51ED
          87FF4CE57FFF4BE47EFF4CE680FF4CE781FF1B9932FE074C11AB000300260000
          0007000000000000000000000000000000000000000000000000000000010050
          00A923B747FF33CB67FF33CA65FF32CA65FF20AA45FF31BC56FF5EF993FF59F3
          8DFF58F18BFF57F08AFF58F18BFF48D56FFF39BA54FF52EA84FF52EC86FF50E9
          83FF4DE680FF4FEB85FF49E07AFF14912AFD073F0F8E0000001B000000040000
          0000000000000000000000000000000000000000000000000000000000010059
          00B622B345FF2DC15CFF2BBD57FF1DA842FF3ECE68FF61FB95FF5CF58FFF59F2
          8CFF58F28CFF59F28CFF4BD872FF46D06AFF55F08AFF53ED87FF51EA84FF4FE8
          82FF53EE88FF45D872FF108725F5052E0C730000001600000003000000000000
          0000000000000000000000000000000000000000000000000000000000010062
          00C321AD43FF27B34EFF20AA44FF4BDF79FF62FC96FF5DF791FF5BF48EFF5AF3
          8DFF59F38DFF53E17BFF51E27CFF59F28CFF54EE88FF53EC86FF53ED87FF56F2
          8CFF3DCD67FF0F7D23E8041E085A000000100000000200000000000000000000
          000000000000000000000000000000000000000000000000000000000001006A
          00D01FA93FFF25B54FFF56EC86FF62FC96FF5DF690FF5DF690FF5DF690FF5CF6
          90FF5BF08AFF58EE88FF59F38DFF57F18BFF55EE88FF56EF89FF59F690FF33C0
          5AFF0F7121D5021205440000000C000000010000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000001118D
          25E030C25CFF5DF791FF61FA94FF5FF892FF5FF892FF5FF892FF5EF791FF5DF6
          90FF5EF58FFF5BF58FFF59F28CFF59F28CFF59F28CFF5AF791FF2CB34FFE0F62
          22BE010802310000000800000001000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000000000125AC
          4BF061FA95FF62FB95FF61FA95FF64FD97FF63FC97FF60F993FF5FF892FF5EF7
          91FF5DF690FF5BF48EFF5BF48EFF5BF58FFF59F48EFF25AC45FE0E561FA30002
          0024000000060000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000011F95
          41D35CF48EFF63FC96FF67FF9BFF4BE477FF5CF58EFF65FE99FF60F993FF5FF8
          92FF5DF690FF5DF690FF5EF892FF56EE88FF1FA63FFB0B4419860000001A0000
          0004000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000001C85
          3DBB55EE88FF66FF9BFF3BD45EFF0EA727FF1AB33DFF66FF9AFF62FB95FF61FA
          94FF5FF892FF62FB95FF4FE57FFF1A9B3AF10830126C00000014000000030000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000001A75
          37A650E781FF66FF9BFF41DA65FF019A0CFF10A925FF67FF9BFF61FA94FF61FB
          95FF64FF9AFF46DA74FF198E36E3061F0C540000000F00000002000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000001666
          308E4DE37EFF66FF99FF68FF9EFF54ED7FFF62FB94FF65FE99FF63FC96FF65FF
          9AFF3ED06AFF187F32CF0311073E0000000B0000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000001458
          2A773CD36DFF5AF28CFF67FF9BFF68FF9DFF66FF9AFF63FD97FF66FE98FF36C6
          61FF176C2FB70108032D00000007000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000061B
          0C201969337E229D48C12BBC59F83ACE69FF4CE27CFF5BF38DFF30C25CFE145F
          2B9A000100200000000500000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000020B040E0C381A4D17682F921F9643D3104B226E0000
          0010000000040000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0002000000060000000200000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000400000015000000220000
          0026000000270000002700000027000000270000002700000027000000270000
          0024000000190000000600000000000000000000000000000000000000000000
          000C000000230000001000000001000000000000000000000000000000000000
          00040000000D0000000900000001000000000000001400000055000000830000
          008E0000008E0000008F0000008F0000008F0000008F0000008F0000008E0000
          008800000062000000190000000000000000000000000000000000000000001D
          004F00000058000000390000000C000000000000000000000000000000040000
          001D000200400000001F000000040000000134343497696969F4686868F86666
          66F8676767F8686868F869696AF8686868F8676767F8676767F8676767F84848
          48C90000008A0000002400000000000000000000000000000000000000010066
          00DA000C0081000000740000002C0000000700000000000000040000001B0035
          0095000C00790000002C00000004000000015E5E5EE2DCDCDCFFFFFFFFFFFEFE
          FEFFFFFFFFFFFFFFFFFFD1D6D8FFF7F8F9FFFFFFFFFFFFFFFFFFFEFEFEFF7B7B
          7BFC000000900000002700000001000000000000000000000000000000020070
          00F2004F00D40001009D000000620000001E0000000700000019002D0089006D
          00FE0005008B0000002C00000003000000015C5C5CE5E5E5E5FFFFFFFFFFFFFF
          FFFFFFFFFFFFB35926FFA99387FFC1C5C8FFFFFFFFFFFFFFFFFFFFFFFFFF7A7A
          7AFD0000009000000027000000010000000000000000000000000002000A0071
          01FB04890CFF003000B30000009600000050000000290026007F017503FD0072
          01FE0003008E0000002700000001000000015C5C5CE5E3E3E3FFFFFFFFFFFFFF
          FFFFE5CABCFF972100FFA33F03FFACB6BDFFE1E4E4FFFFFFFFFFFFFFFFFF7A7A
          7AFD000000910000002700000001000000000000000000000000000700170172
          01FE12B427FF017402FD001400A30000008F001D0086007000FA10AF20FF0075
          00FA0000008B0000002500000001000000015C5C5CE5DEDEDEFFFEFFFFFFFFFF
          FFFFA03800FFA33A00FFA43600FFAA6E4AFFA9B2B8FFF8F9FAFFFFFFFFFF7A7A
          7AFD000000910000002700000001000000000000000000000000000C00230376
          03FE15B42BFF12A823FF006100ED001A00A5006E00F811A822FF13B228FF006D
          00F0000000850000002300000001000000015D5D5DE5DCDDDEFFFFFFFFFFBC74
          4AFFA13300FFA63D00FFA73F00FFA83600FFA79B93FFB6BCBEFFFFFFFFFF7B7B
          7BFD00000091000000270000000100000000000000000000000000130032037C
          06FF18B432FF17B32EFF0C981CFF006B00FF13AA29FF16B12DFF15B12BFF0061
          00E30000007F00000021000000020000000D5D5F5EE7DCE3E7FFDABAA5FF9E2E
          00FFA63700FFAA7654FFA83C00FFAA3E00FFAA4805FFA1A9B0FFD4D6D7FF7E7E
          7EFD000000910000002700000001000000000000000000000000001900400584
          0CFF1BB738FF18B334FF16AC2FFF07730DFF1AB935FF17B231FF17AE30FF005B
          00D800000079000000220000001100080144616D67F8CDC6C3FFA63500FFA93C
          00FFA24609FFDBEEFCFFD1A586FFA83800FFAD4100FFAA693AFFA1ABB3FF7979
          7AFD000000930000002C00000003000000000000000000000000001F004F0989
          10FF1EBA3EFF1BB639FF17A931FF0D841CFF1CB939FF1AB537FF17AE31FF0052
          00CE0000007600000032020F0354599560E3697A71FFA84403FFAA3F00FFAA3A
          00FFBFBAB5FFF0F5F9FFF0FCFFFFBB6426FFAF4300FFB34200FFA78C78FF5A5F
          62FE000000950000003C0000000C0000000100000000000000000026005D0C90
          17FF21BD45FF1EB93FFF1AA936FF149429FF1EBA40FF1EB83EFF18AC33FF0049
          00C400000084031806760B761CE77CD997FFA64D09FFAC4200FFB14100FF9372
          5AFFC0C8CCFFBCBDBDFFBDC0C2FFB8B8B8FFB04600FFB54B00FFBA4D00FF5452
          50FB000000950000005500000022000000090000000100000000002D006B0F97
          1EFF25C14BFF21BC45FF1EAD3DFF1BA237FF23BD45FF23BD46FF19AB33FF003B
          00BE041D099E118626F443D670FF79EEA1FF8C7928FFB44B00FF984E09FF5065
          5CEB4F5350D54E524ED5525552DA4D5654D5865325D9BB4F00FFB95000FF9941
          00E2010000A000000084000000490000001E000000080000000100340078129D
          25FF28C351FF26C14CFF21B144FF20AE42FF24BF4CFF26C04CFF17A62EFF046A
          0BE51A9734FC4BE37DFF50EB85FF63E990FF7AA047FF97731EFF41893FFF7AC0
          86FF7ABF85FF78BF84FF78C185FF7BC388FF73B479FF7F5C06EFB85300FFC156
          00FF803800D00000009E0000007F000000440000001A00000004003B008516A6
          2EFF2BC558FF28C251FF26B74DFF25B84CFF27C352FF29C553FF1AA237FF22A5
          41FF54EE88FF51EB85FF4EE781FF50EC86FF50BC59FF77B075FF6CDA8DFF50EE
          88FF4BE882FF4CEA84FF4EF08AFF22A540FF06530EC4080B013D9C4700D4BB55
          00FFC55A00FF6A3100C50000009C000000750000002F00000008004300931BAC
          38FF2FC95DFF2BC559FF2ABE56FF2BC256FF2CC759FF1BA13AFF2BB34DFF58F3
          8DFF53ED87FF51EB85FF53F08AFF3CC55FFF1A8A24FF49DF79FF4CE882FF49E2
          7CFF49E37DFF49E57FFF18942DFE054A0DAC0003002700000007200E0028B353
          00EEC15A00FFCA6000FE612D00BF0000008B0000003A00000009004900A022B5
          44FF32CC65FF30C95EFF31C861FF2EC55DFF1A9F39FF38C560FF5BF791FF56EF
          89FF54EE88FF55F08AFF3CC25CFF2BA53FFF50E983FF4FE983FF4AE47EFF4CE7
          81FF47E07AFF138D25FD063E0C930000001E000000090000000F000000203619
          0069C15C00FBC55D00FF9F4C00DC0000008B0000003A00000009005100AD26BC
          4EFF34CF69FF33CD66FF2FC760FF1AA03AFF44D670FF5DF892FF57F08AFF56EF
          89FF56F18BFF3EC45EFF3BBE58FF54F08AFF4FEA84FF4EE781FF4FEA84FF40DA
          71FF0E8C21FD0427098D0000002C00000017000000290000004A1009097B3C23
          23AF7E3E15C6C96100FEAF5500E10000007C0000002E00000007005A00BB26B8
          4CFF30C45FFF2BBD57FF1EA640FF50E680FF5EF892FF5AF48EFF59F28CFF57F0
          8AFF45CE68FF49D46EFF55F18BFF52EC86FF50E983FF54F089FF38D166FF0989
          1FFF433A2ACC0000006A000000430201015B1E12128C522F2FC7865151FD7342
          42F60A05056A793B008FC25F00DB000000500000001400000001006400C823B1
          47FF25B44FFF25B14BFF58F18BFF60FA94FF5BF48EFF5AF38DFF59F18BFF50DC
          76FF51E57FFF58F28CFF55EE88FF54ED87FF56F38CFF2BC358FF1B902DFF8B5C
          5AFF1D0F11A30503038C301E1EA0684040E19A6767FFD19E9EFFB48282FF3820
          20AB00000036000000096D3500700000000A0000000400000000006A00D522AF
          48FF2FBE58FF5FF993FF60F993FF5DF690FF5DF690FF5EF690FF5CEF89FF58F0
          8AFF59F48EFF56EF89FF57F18BFF58F68EFF20B84AFF30923AFFD09197FF7E44
          48FD482E2EBE825454F4B27F7FFFDDAAAAFFE9B6B6FFE4B1B1FF724242F40805
          05770000002900000009000000020000000100000000000000001D9E3AE73ACE
          6BFF64FE98FF61FB95FF5FF892FF5FF892FF5EF791FF5DF690FF5CF58FFF5AF3
          8DFF5AF38DFF5AF38DFF58F48DFF16B040FF4F9751FFCA828FFF9E676AFF9F6B
          6CFFC89595FFEDBABAFFEAB7B7FFE6B3B3FFECB9B9FFAE7B7BFF321D1DAF0000
          008B0000005A000000370000002200000014000000080000000122A649EB64FF
          99FF62FB95FF66FF9AFF67FF9BFF64FD97FF61FA94FF5FF892FF5DF690FF5BF4
          8EFF5CF690FF56F28AFF0FAB39FF5D8552FFB06873FFB57F80FFDCA9A9FFF4C1
          C1FFEEBBBBFFEAB7B7FFEDBABAFFD19E9EFF8F5C5CFF663333FF502E2ECF2314
          14A60805059C00000091000000750000004A0000001F000000051D9241CC5DF5
          8FFF66FF9BFF3DD663FF2CC552FF61FA94FF63FC96FF5FF892FF5FF892FF60FB
          95FF4EEA82FF08A331FF7B7F60FFD8939DFFF2BCBDFFF7C4C4FFF1BEBEFFEFBC
          BCFFEEBBBBFFCF9C9CFF9A6767FF8F5C5CFFBE8B8BFFE9B6B6FFCE9B9BFFA774
          74FF855151FD5E3535D4311B1B9F1008086400000022000000061C833BB657ED
          88FF6BFFA2FF08A115FF0AA321FF47E071FF65FE99FF61FA94FF63FD97FF46E2
          78FF10A337FFC7B1A1FFFFC6CFFFFCC7C7FFF4C1C1FFF2BFBFFFEEBBBBFFD7A4
          A4FFB48181FFBC8989FFDBA8A8FFEDBABAFFE7B4B4FFE4B1B1FFE9B6B6FFDEAB
          ABFFAC7979FF754444F54A2A2AA3170C0C410000000900000001197235A051E9
          83FF67FF9CFF4FE879FF34CD52FF66FF9AFF64FD97FF65FF9AFF3BD86DFF22A8
          44FFF4C5C3FFFFC9CFFFFAC5C6FFF5C2C2FFF3C0C0FFECB9B9FFDAA7A7FFDCA9
          A9FFEBB8B8FFEEBBBBFFE8B5B5FFE9B6B6FFECB9B9FFCB9898FF996666FF693D
          3DE03A2222820A060625000000070000000100000000000000001665318842D8
          73FF62FC96FF6AFFA0FF6AFF9FFF66FF9AFF66FF9BFF32D165FF35A54EFFFFCD
          D3FFFFD1D4FFFFCCCCFFFAC7C7FFF6C3C3FFF5C2C2FFF0BDBDFFF2BFBFFFF0BD
          BDFFEDBABAFFEFBCBCFFEBB8B8FFC18E8EFF935F5FFD643D3DC12C1C1C600201
          01130000000400000001000000000000000000000000000000000A2B14321D86
          3F9D28B654E133C962FE43D973FF56EE88FF2FC95FFE2D8842DBE198A4FFFFD5
          D8FFAF7C7CFFBE8B8BFFFECBCBFFF6C3C3FFF4C1C1FFF3C0C0FFF3C0C0FFF6C3
          C3FFE6B3B3FFB88686FF8C5B5BF3573737A01C11113D00000009000000020000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000010825112A145A29701E9141B40D6528866A414986E7AFB2FFFFD3
          D3FFC28F8FFFC59292FFFECBCBFFF8C5C5FFF8C5C5FFFAC7C7FFDDAAAAFFB37E
          7EFF805151DD462E2E7E0B070722000000070000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000001553E3F5EBD8B8BF3E7B4
          B4FFFFD2D2FFFFCECEFFFDCACAFFF8C5C5FFD4A1A1FFAE7C7CFD7A5252BD3322
          225B010101100000000400000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000001F171722986E
          6EB9CD9999FEEDBABAFFCF9C9CFFA47676F16547479B1E151539000000090000
          0002000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00004E3939608F6969CA4A3535750A07071F0000000600000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000010000
          0008000000170000002200000020000000140000000500000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000010000000C0000
          003000000065000000820000007C000000580000002500000007000000000000
          0000000000000000000300000008000000090000000400000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000010000000B060606422324
          25B5393E40EE2D2F33E30D0E0EAC0101019B0000006600000020000000030000
          00010000000A00000022000000390000003D0000002900000011000000030000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000A0606063E454749D88977
          6CFFC3987DFFC59E87FF7B7876FF181A1BC000000095000000470000000F0000
          000E000000380A0A0A7E08090993010101950000008000000049000000140000
          0001000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000010000000B0404043D3F4040D2837870FFF9C0
          8DFFF3BF8EFFF0BB8BFFEBB589FF6B6969FF090A0AA1000000700000002F0808
          084C3C3D3FD35D5E5FFF676769FF393C3FEE090909A2000000890000003C0000
          000A000000000000000000000000000000000000000000000000000000000000
          000000000000000000010000000D0303033E2E2E2ECF6F7275FFCAA787FFFFDA
          A9FFFFD7ABFFFFD5A9FFFFD29CFFC9AA8EFF1B1C1FBE0000009907070777494C
          4EDF97806FFFE5AB81FFE0A87DFFC8A791FF474D50F80505059F000000680000
          0018000000000000000000000000000000000000000000000000000000000000
          0000000000010000000F040404462A2A2ACC6D6D6DFF909396FFCAA991FFFFE7
          C5FFFFE3CBFFFFE2C5FFFFDBB4FFF8CBA0FF3A3E41F20F0F0FA7393A3AE37977
          75FFFFCF97FFFFD09DFFFECE99FFFCC490FFB39F8CFF17181ABD000000810000
          0022000000010000000000000000000000000000000000000000000000000000
          0002000000110606064E323232DB6F6F6FFF949494FFA4A7A8FFAC9992FFFFE6
          D3FFFFFAEFFFFFF0E0FFFFE7C8FFE3C09FFF3C4043FF3C3C3CFF88898BFFA294
          8BFFFFE1B4FFFFDDBDFFFFDCBAFFFFD8ABFFF4C89DFF313539E50000008D0000
          00330000000A0000000200000001000000000000000000000000000000020000
          001308080857373737E4414141FF959595FFAAAAAAFFBBBBBCFFBAB9BCFFB597
          8EFFF2E8E6FFFFF6E9FFFFF1D2FF84786EFF3B3D3EFF919191FFAAABACFFA098
          96FFFFE1C5FFFFF1DFFFFFECD8FFFFE2C3FFFFD3A7FF363A3EE9000000A20000
          006D0000003F000000270000001A0000001000000007000000010000000D0B0B
          0B5E2F2F2FEB606060FF515151FF848484FFC7C7C7FFD3D3D3FFE4E5E5FFA8A8
          A9FF957D7BFFA58980FF806F6BFF4E5052FF535354FFB6B6B6FFBFBFBFFFBABD
          BFFFC3A89CFFFFF9F5FFFFFFF7FFFFF4D7FFCAAE95FF675E5AF25F493EB70D04
          00A000000097000000840000006B0000004D00000027000000080D0D0D513030
          30F39A9A9AFFEEEEEEFF7B7B7BFF4F4F4FFFBBBBBBFFF4F4F4FFFFFFFFFFFFFF
          FFFF909393FF666969FF717373FF676767FF303030FFCECECEFFD4D4D4FFE6E8
          E8FFB4B1B2FFA98E89FFD4B5A8FFC5A594FF686565FFC59678FFB35117FF9F35
          00FE852900E64E1700BB260C00A10A0300890000004D00000011313131D33939
          39FFEDEDEDFF848484FFB5B5B5FFC2C2C2FF5D5D5DFF909090FFB3B3B3FF5A5A
          5AFF3F3F3FFF515151FF6A6A6AFF5D5D5DFF606060FFEDEDEDFFF4F4F4FFFFFF
          FFFFFFFFFFFFBABDBEFF6D6D6EFF959698FFC9CCD0FFC5C5C2FFC5A582FFD092
          4BFFD37714FFCA5E00FF9F3900FF5C1F00BC0000002C00000007444444F84848
          48FF8B8B8BFFBCBCBCFFCCCCCCFFCACACAFFC7C7C7FF9A9A9AFF757575FF5E5E
          5EFF4F4F4FFF4D4D4DFF3D3D3DFF3A3A3AFF7C7C7CFFBEBEBEFFD8D8D8FFC1C1
          C1FF7E7E7EFF555656FFB2B2B2FFCFCFCFFFBCBDBDFFB9BBBBFFBCC0C3FFC0C6
          CCFFC3CDD6FFC7BDB6FF651B00C90701003D00000009000000013B3B3BC95050
          50FF787878FFD6D6D6FFCBCBCBFFBEBEBEFFB6B6B6FFB2B2B2FFAFAFAFFFABAB
          ABFFA3A3A3FF959595FF8A8A8AFF7E7E7EFF717171FF696969FF353535FF3D3D
          3EFF9C9FA0FFC4C7C8FFABADAEFFA5A6A7FFAAAAABFFAFAFAFFFB6B6B6FFBABA
          BAFFC0C2C2FF8A827FD5040100760000001F00000001000000001414143C5656
          56F3595959FF565656FF898989FFA5A5A5FFB1B1B1FFAFAFAFFFA6A6A6FF9E9E
          9EFF9E9E9EFF9F9F9FFFA2A2A2FFA8A8A8FF919191FF54514FFF8E715FFFCC94
          74FFB1693CFF9C6443FF9A7F6FFF9A9D9FFF9FA6ABFFA4A9ADFFA9ACAEFFAEAF
          B0FFB5B5B5FF686869BE0000007E000000270000000400000000000000000F0F
          0F232F2F2F8080746FDBB59179FFAA9273FF8C7E6BFF76726BFF6A6A6AFF7373
          73FF7B7B7BFF7F7F7FFF7D7D7DFF5D5D5CFF766352FFCFA076FFD08442FFC05A
          03FFB85000FFB14700FFAC3F00FFA53800FFA14914FF9F6442FF9F8370FFA3A2
          A2FFA8B1B6FF797D80CE00000099000000500000001400000001000000000000
          0002443D395DA75F3BF2E08A26FFF7AB43FFFFC566FFE4AF7BFFD7AE89FF927E
          69FF5C5753FF645D55FF9E8165FFC99E76FFD99759FFC6650DFFC15B00FFBF59
          00FFBD5700FFBC5600FFBB5500FFB85100FFB44C00FFAC4300FFA73B00FFA334
          00FFA04411FF965E3EF4220B00A0020000700000002300000003000000000000
          000C5D2100A3C05A00FFF08900FFFF9B05FFF5981EFFB45005FFDE8D2FFFE098
          4AFFE6AF75FFE3A96CFFD78737FFCF7215FFC96300FFC66000FFC45E00FFC25C
          00FFC05A00FFBE5800FFBC5600FFBA5400FFB85200FFB75100FFB54F00FFB34C
          00FFAF4700FFA73F00FF963400F311060056000000110000000100000003220E
          0048A74100FBEB8500FFFC9600FFFFAA22FFBF5A05FFD68127FFDB7B0EFFD670
          00FFD46E00FFD26C00FFD06A00FFCE6800FFCC6600FFCA6400FFC86200FFC660
          00FFC35D00FFC15B00FFBF5900FFBD5700FFBB5500FFB95300FFB75100FFB650
          00FFB24C00FF9C3900F7270E006F0000001700000002000000000100000D7632
          00C6D46E00FFFA9300FFFFA415FFE3871FFFC26412FFE58D20FFDC7700FFDA73
          00FFD87100FFD56F00FFD36D00FFD16B00FFCF6900FFCD6700FFCB6500FFC963
          00FFC76100FFC55F00FFC25C00FFC05A00FFBE5800FFBC5600FFBB5500FFB953
          00FFA23E00FB3112007A0000001A0000000300000000000000002B140051B753
          00FEF79000FFFF9F0BFFFFAA31FFB95301FFE6922DFFE38009FFDE7800FFD37A
          1BFFD88325FFD7760AFFD76D00FFD56C00FFD26900FFD06900FFCE6800FFCC66
          00FFCA6400FFC86200FFC66000FFC45E00FFC15B00FFC05A00FFBF5900FFA842
          00FD3B1700860000001C00000004000000000000000000000000632A009DDA73
          00FFFF9B03FFFFAC2CFFD57618FFD57C21FFEC8F19FFE77F00FFD16A00FFDEA5
          61FFE1A968FFE0AC6EFFE2AA6BFFE19E52FFE09336FFDE841AFFDA7300FFD56C
          00FFCE6600FFCA6300FFC96300FFC76100FFC66000FFC45E00FFAB4700FE471B
          00910000002000000004000000000000000000000000000000008D3E00CDF58D
          00FFFFA61EFFF5A037FFBF5B07FFF29D2CFFEB8704FFDF7600FFD18739FFE3A9
          62FFE1A760FFE2A864FFE3AB6AFFE5AE70FFE4B175FFE6B37CFFE8B680FFE8AC
          6BFFE9A24DFFE88E1BFFD36C00FFCA6400FFCA6400FFB04C00FE5421009E0000
          0023000000050000000000000000000000000000000000000000A24700E3FFA0
          14FFFFB341FFC46008FFE7922DFFF39412FFF08900FFC36513FFE6B065FFE5AB
          60FFE5AA61FFE3AB64FFE4AB67FFE4AC6AFFE5AE6EFFE6AF71FFE6B175FFE7B4
          7CFFE6B075FFDA7603FFCF6900FFCF6900FFB75100FF5E2800AB000000280000
          00060000000000000000000000000000000000000000000000009F4A00D8FFAB
          33FFE58E2DFFD07218FFFBA425FFF38E02FFE68000FFC2620DFFC57225FFCD81
          3AFFDB9952FFE6AF69FFE8B16EFFE7B26EFFE8B16FFFE7B271FFE7B173FFE6B1
          74FFD87306FFD56F00FFD56F00FFBC5600FF652C00B60200002D000000070000
          00000000000000000000000000000000000000000000000000006B35008DD97A
          17FFC35E00FFEC9525FFFB9A0DFFFB9400FFF89100FFF79000FFF48C00FFEA81
          00FFD97000FFCE6600FFCD6C0EFFCD7827FFD3893EFFDE9F59FFE6B173FFD375
          13FFD97300FFDB7500FFC25C00FF722F00C10402003400000009000000000000
          0000000000000000000000000000000000000000000000000000060200064D27
          005D7438008F9A4900C1B15A00EFC86400FFD46E00FFDE7800FFE88200FFF38D
          00FFF48E00FFF28B00FFEF8700FFEC8500FFE47C00FFDA7000FFD06800FFDE77
          00FFE17A00FFCA6400FF7D3600CC0803003A0000000A00000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000001010000021D0F0025452100586B31008A924500BAA754
          00E8C15E00FECE6800FFD67100FFDF7900FFEA8400FFED8700FFE98300FFE882
          00FFD26C00FF883A00D60B0400410000000C0000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000010100
          0002180B001F401D0051642E00838B3D00B4AE4E00E3BE5700FDC86200FFCD67
          00FF994300DD110800400000000D000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000114080018381A004B5B28
          00791A0C002D0000000700000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00010000000B0000001A000000150000000D0000000400000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000900000034000000680000005F000000430000001A00000004000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000070E0E
          0B4074726DE7201F1FA4151515A00101018B000000460000000E000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000040000000800000004000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000007000002290021
          88AF8A93A4FFCDC7C2FF888887FF191919A20000005F00000015000000000000
          0000000000000000000000000000000000000000000000000000000000010000
          000E00000028000000390000002B000000170000000A00000004000000010000
          000000000000000000000000000000000000000000070000032B03258BB12A76
          FFFF4BADFFFFE0E6E4FFCFCBC7FF212121A70000006A0000001A000000000000
          00000000000000000000000000000000000000000000000000000000000C0903
          00431D0A008705020091000000850000005F000000400000002A0000001C0000
          00130000000900000003000000020000000A0000032C02288FB42E79FFFF56B4
          FFFF68D5FFFF5BBDFFFFAEAEAEFF6A6963D7000000430000000F000000000000
          00000000000000000000000000000000000000000000000000041D090047892D
          00E88F2F00FF882E00ED341000AB1206009C010100970000008A000000730000
          00580000003E0000002A0000002700010441042692B72F7BFFFF59B7FFFF6CD6
          FFFF5FC0FFFF3B8FFFFF123FBFD62725226F0000001100000003000000000000
          00000000000000000000000000000000000000000001010000136D2800CA712B
          0AFF782D05FF942B00FF9C3000FF9A3100FF8E2E00F25D1F00C5311000A81106
          009B010000980000008C09090887001A83BE307AFCFF5AB9FFFF6CD6FFFF5EBF
          FFFF3E8EFFFF0A38BBD3000310420000000C0000000100000000000000000000
          000000000000000000000000000000000000000000063212006F913000FE574D
          48FF636C71FF756F6CFF8B6A57FFA77359FFB67351FFBB7155FFBB7254FFB66A
          47FF9D512CF1906855D6938F85FD5B7297FF4AABF4FF6DD9FFFF5DBEFFFF3D8D
          FFFF0A33B0D100020A6D0000002C000000110000000700000001000000000000
          00000000000000000000000000000000000107020022862C00E5882900FF5A5F
          62FF676868FF838485FFABACAEFF909396FF7A7E84FF7B7F87FF7B7C81FF726A
          68FF91715CFFB97E5FFF877E79FFE2D9D2FF79A4B5FF4DB1F8FF3A8BFFFF214A
          C9E435373DA6000000940000006F0000004D0000002700000008000000000000
          0000000000000000000000000000000000094D180093A43D00FF842800FF545A
          5EFF818282FF9D9E9EFF73787EFFB0A591FFE4C695FFEFC88BFFEFC78CFFF0CE
          9EFFBCB2A1FF4D5259FF909092FFEEEDECFFEAE1D8FF4B70AAFF324DCCFFB87B
          66FE893009E74E1700BB260C00A10A0300890000004D00000011000000000000
          00000000000000000000000000031607003B922F00F7D16A00FF8D2900FF5755
          51FF94979AFF7E8084FFDEBE8CFFEFC787FFE9C58BFFE8C48DFFE9C996FFEED2
          A2FFEFC689FFEECD99FF64676DFF9A9B9CFF939392FF9E998CFFCDBDB2FFD398
          55FFD37714FFCA5E00FF9F3900FF5C1F00BC0000002C00000007000000000000
          000000000000000000000000000F662000B7B95300FFE37D00FFC86104FFAF7C
          62FF807E7FFFDEBD8CFFEAC78BFFE4C690FFE5C690FFE5C68FFFE5C487FFE6BF
          83FFEBCD9EFFEFD09BFFEECC9BFF4D5159FFB8B8B8FFC5C6C6FFC3C6C9FFC0C6
          CCFFC3CDD6FFC7BDB6FF651B00C90701003D0000000900000001000000000000
          000000000000000000042B0E005C9F3900FEDD7700FFEF8900FFFFB32DFFB08B
          6EFFAF9F88FFF4CA8BFFEBC58DFFE9C78EFFE8C691FFE7C791FFE6C791FFE5C6
          8FFFE5C185FFEBCEA1FFEFCB8CFFB1A99BFF9F9FA1FFBDBDBDFFB6B6B6FFBABA
          BAFFC0C2C2FF8A827FD5040100760000001F0000000100000000000000000000
          00000000000104010019762400D7CB6500FFE98300FFFF9A02FFE7A050FF9788
          80FFDBC08FFFF0CF94FFEECE97FFEDCE98FFEDCD97FFECCB95FFEAC992FFE8C3
          8AFFE7C086FFE6BF80FFF0D3A9FFEACC9EFF7A7E83FFBABEC1FFA9ACAEFFAEAF
          B0FFB5B5B5FF686869BE0000007E000000270000000400000000000000000000
          0000000000073F140081AB4500FFE68000FFF99300FFFFA014FFCA8656FF8C88
          86FFF3D295FFF2D8A5FFF0D7A6FFF1DBAEFFF0D8A8FFF0D49FFFEDCF98FFEBCC
          92FFE9C58AFFE8BF7FFFECC998FFF1C78BFF7F7776FFBC937CFF9F8370FFA3A2
          A2FFA8B1B6FF797D80CE00000099000000500000001400000001000000000000
          00020E04002D8C2F00EEDB7500FFF48D00FFFFA30DFFCD6B0CFFDA9E69FF908B
          89FFF7D69DFFF5E1B7FFF6E4C0FFF6E2B9FFF3DEB3FFF1D9AAFFF0D3A1FFEDCF
          98FFEBCB91FFEAC486FFEDCA93FFF1C68BFF847A75FFC57D4EFFA73B00FFA334
          00FFA04411FF965E3EF4220B00A0020000700000002300000003000000000000
          000C5D2100A3C05A00FFF08900FFFF9B05FFF5981EFFB45005FFE7AA63FFA999
          8AFFDBC395FFFBEBC9FFF9EBCBFFF8F1DCFFF8E9CDFFF5E0B5FFF2DCAFFFEFD2
          9EFFECCC94FFEAC589FFEFCB92FFE4C493FF897466FFC97D40FFB54F00FFB34C
          00FFAF4700FFA73F00FF963400F311060056000000110000000100000003220E
          0048A74100FBEB8500FFFC9600FFFFAA22FFBF5A05FFD68127FFE19136FFCBA7
          81FFAEA28DFFFBF0CBFFFCF5E4FFFCF8F1FFFBF6E6FFF8E5BEFFF3E1B8FFF0D4
          A1FFEDCE96FFECC78DFFF5CD8DFFA99D8BFFAC8462FFC36B23FFB75100FFB650
          00FFB24C00FF9C3900F7270E006F0000001700000002000000000100000D7632
          00C6D46E00FFFA9300FFFFA415FFE3871FFFC26412FFE58D20FFDD7A05FFE5A7
          62FFA39B98FFE4D6AFFFFCF5D7FFFDF8E9FFF9F1DAFFF6E9C7FFF3E0B4FFF0D6
          A3FFEECE97FFF1CE8EFFE2C38EFF7A7573FFD2925AFFBD5702FFBB5500FFB953
          00FFA23E00FB3112007A0000001A0000000300000000000000002B140051B753
          00FEF79000FFFF9F0BFFFFAA31FFB95301FFE6922DFFE38009FFDE7800FFD88A
          37FFE3BE95FF9C9A96FFE7D8B6FFFCF3D5FFFBF1D5FFF8E9C5FFF5DFB0FFF5D8
          A0FFF8D596FFE1C290FF807F7EFFC59467FFC76A18FFC05A00FFBF5900FFA842
          00FD3B1700860000001C00000004000000000000000000000000632A009DDA73
          00FFFF9B03FFFFAC2CFFD57618FFD57C21FFEC8F19FFE77F00FFD16A00FFDEA5
          61FFE7BA85FFE6CFB5FFA19F9FFFB1A995FFE0CFA7FFFCE4ADFFFADDA4FFDFC5
          97FFAEA18CFF817E7BFFC8996BFFD07A29FFC66000FFC45E00FFAB4700FE471B
          00910000002000000004000000000000000000000000000000008D3E00CDF58D
          00FFFFA61EFFF5A037FFBF5B07FFF29D2CFFEB8704FFDF7600FFD18739FFE3A9
          62FFE1A760FFE6B479FFE9C9A4FFCBBAA9FFA39E9BFF8A8A8CFF86868AFF9892
          8EFFB8A188FFEAB571FFD87D1DFFCA6400FFCA6400FFB04C00FE5421009E0000
          0023000000050000000000000000000000000000000000000000A24700E3FFA0
          14FFFFB341FFC46008FFE7922DFFF39412FFF08900FFC36513FFE6B065FFE5AB
          60FFE5AA61FFE3AB64FFE5AE6CFFE9BC87FFEDC79BFFEFCCA5FFEFCDA7FFEECB
          A4FFEBBF8FFFDB7909FFCF6900FFCF6900FFB75100FF5E2800AB000000280000
          00060000000000000000000000000000000000000000000000009F4A00D8FFAB
          33FFE58E2DFFD07218FFFBA425FFF38E02FFE68000FFC2620DFFC57225FFCD81
          3AFFDB9952FFE6AF69FFE8B16EFFE7B26EFFE8B16FFFE7B271FFE7B173FFE6B1
          74FFD87306FFD56F00FFD56F00FFBC5600FF652C00B60200002D000000070000
          00000000000000000000000000000000000000000000000000006B35008DD97A
          17FFC35E00FFEC9525FFFB9A0DFFFB9400FFF89100FFF79000FFF48C00FFEA81
          00FFD97000FFCE6600FFCD6C0EFFCD7827FFD3893EFFDE9F59FFE6B173FFD375
          13FFD97300FFDB7500FFC25C00FF722F00C10402003400000009000000000000
          0000000000000000000000000000000000000000000000000000060200064D27
          005D7438008F9A4900C1B15A00EFC86400FFD46E00FFDE7800FFE88200FFF38D
          00FFF48E00FFF28B00FFEF8700FFEC8500FFE47C00FFDA7000FFD06800FFDE77
          00FFE17A00FFCA6400FF7D3600CC0803003A0000000A00000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000001010000021D0F0025452100586B31008A924500BAA754
          00E8C15E00FECE6800FFD67100FFDF7900FFEA8400FFED8700FFE98300FFE882
          00FFD26C00FF883A00D60B0400410000000C0000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000010100
          0002180B001F401D0051642E00838B3D00B4AE4E00E3BE5700FDC86200FFCD67
          00FF994300DD110800400000000D000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000114080018381A004B5B28
          00791A0C002D0000000700000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000001000000040000000A0000
          00130000001A0000001F00000022000000240000002500000024000000210000
          001F0000001F00000021000000220000002200000023000000220000001B0000
          0010000000040000000000000000000000000000000000000000000000000000
          0000000000000000000000000001000000070000001600000029000000400000
          00580000006C0000007A00000083000000890000008C000000870000007F0000
          007B0000007B0000007E00000082000000830000008500000081000000700000
          004F000000270000000A00000001000000000000000000000000000000000000
          0000000000000000000300000013000000340000026101051B8A030838A3030A
          55BA030B6FD1030A7EE0282B98ED997984F747479FEA020268D537377AD06F68
          83D086624FD5975828E0893900DF8F3700E8823000E25A1F00C5240C00A30201
          00980000006B0000002A00000007000000000000000000000000000000000000
          0000000000010000001401031057051454A70B249FEB1031BBFF133CC1FF1846
          C9FF194DCDFF1A50CDFF83A0E4FFE48814FFB69986FF8396DBFFB38975FFCB6A
          0BFFCA6400FFCE711BFFD17929FFD0792BFFCD7324FFB85711FF9E3800FF6D25
          00D50A030077000000360000000B000000000000000000000000000000000000
          000000000005061549700E2FB0F21236BEFF2061DAFF2062DBFF205FD9FF1E5C
          D6FF1C57D5FF1B54D0FF83A0E5FFEC9012FFEB8601FFD58527FFDE7700FFE593
          3DFFEEAA67FFECA660FFEAA35AFFDD8E3DFFC36313FFAF4800FFA64303FE7C2B
          00D3401600820000001100000004000000000000000000000000000000000000
          0000030B242C143FC6FD1E5AD5FF133AC0FF2169DFFF2065DBFF2062DAFF1F60
          D9FF1E5DD7FF1D59D4FF85A4E7FFF39612FFF79E28FFEE8700FFF3B46EFFF3B7
          7BFFF1B170FFEDAB68FFD67A1EFFC45B01FFB6693BFF98768BFF7772A6E40000
          00740000001E0000000200000001000000010000000100000000000000000000
          0000030B222A184BCBFF236DE1FF2265DDFF246DE1FF236BE0FF2269DFFF2167
          DDFF2063DBFF1F5FD8FF86A6E8FFF69912FFFFB860FFFCC895FFFAC28CFFF7BC
          82FFF2B576FFDD7C0DFFCC7017FFA0889DFF6B79CDFF2F39B4FF070760C00000
          00740000002C000000190000001C0000001F0000001900000007000000000000
          0000010610131B50CDFE2674E6FF2573E6FF2574E5FF2572E5FF2570E4FF246D
          E2FF2269DFFF2165DCFF84A7EBFFF39918FFFFB85DFFFFCD9FFFFDC993FFFAC1
          88FFEB8A0CFFD37F24FF9091C3FF3B50C1FF2539B8FF2A33B0FF26265CB90000
          00910000006B0000006800000071000000780000005F0000001A000000000000
          0000000001031A54CAED287AEAFF2779E9FF287AEAFF2879EAFF2777E8FF2675
          E6FF246FE3FF226BDFFF85AAECFFF49918FFFFB85EFFFFD1A6FFFFCFA3FFFCC4
          89FFF18D03FFCF8B3EFF8390D3FF384AB7FF8A7FA5FFA58990FF9A754FD35433
          00AC714200B48E5300C1AF6700D2AF6900D20000008200000022000000000000
          000000000000184BB2C22778E9FF2B82EFFF2A81EFFF2A80EEFF297FECFF2879
          EAFF2674E6FF246EE2FF86ACEDFFF49A18FFFFA628FFFFAC39FFFFA726FFFFA2
          19FFFA9606FFF28C00FFCF8B3FFF848FCBFFCE8A3EFFF28C00FFFA9606FFFFA2
          19FFFFA726FFFFAC39FFFFA628FFD57F00E70000008600000023000000000000
          00000000000011377B822673E6FF2D89F4FF2D88F5FF2C87F4FF2B83F0FF297F
          EEFF277AEAFF2675E7FF7CA7EDFFE89E30FFE89C30FFDD9D46FFD19D5CFFC59E
          72FFB99C87FFAB9A9BFF8C86A9FF3A4FBAFF7F83CAFFC57E30F2F18D03FFFCC4
          89FFFFCFA3FFFFD1A6FFFFB85EFFD57E00E70000008700000024000000000000
          00000000000006152A2B246EE4FD3090F9FF2F91F9FF308FF8FF2E8AF5FF2A83
          F1FF206EE6FF1960DEFF6593E7FF79A4ECFF79A0E9FF6B92E3FF5F85DDFF5177
          D7FF4569D1FF3758CAFF294AC3FF3D57C6FF887DB4FCC87416EFEB8A0CFFFAC1
          88FFFDC993FFFFCD9FFFFFB85DFFD57E00E70000008800000024000000000000
          000000000000000000001B54ADB02C84F0FF339AFFFF3195FCFF2D8DF8FF1A64
          E2FF4A6FBDFF5D76B1FF4461B6FF0733C1FF1750D1FF1C5CD6FF1A50D0FF1749
          CAFF1C48C7FF3C5DCBFF7188D9FF9D7F98FFC86C13F9DD7C0DFFF2B576FFF7BC
          82FFFAC28CFFFCC895FFFFB860FFDE8300EC0000008800000024000000000000
          0000000000000000000005111F20236DD9EC2F8FF8FF3093FBFF2984F3FF3D70
          CDFFBDAF97FFB6AD9FFFB7AD99FF9E9997FF132FB5FF1549CDFF4E79DBFF7795
          E0FF8C9CD6FF9D8796FFB6683AFFC35B01FFD67A1EFFEDAB68FFF1B170FFF3B7
          7BFFF3B46EFFEE8700FFF79E28FFDC8200EC0000008300000024000000000000
          00000000000000000000000000000B203A3C236DD9EC2B80EFFF277FF1FF4674
          CCFFB3B5B3FF82A9D0FF77A4D1FF88A5BFFF949299FF3C4DC0FF8D6E7FFFA650
          2CFFA74204FFAF4800FFC36313FFDD8E3DFFEAA35AFFECA660FFEEAA67FFE593
          3DFFDE7700FFB26200D6E98400FEDB8000EC000000640000001F000000000000
          00000000000000000000000000000000000005111F20184998AF2168DCFC298D
          FAFF2B9AFFFF37A0FFFF3BA2FFFF34A0FFFF2FA0FFFF3475E0FF7D7DBFFF9545
          29FF9E3800FFB85711FFCD7324FFD0792BFFD17929FFCE711BFFCA6400FFC161
          00F260330084030100186238006CD77900E90000002A0000000E000000000000
          0000000000000000000000000000000000000000000206121B382A85DFE94EAB
          FFFF63B7FFFF61B6FFFF60B6FFFF5EB4FFFF5BB2FFFF42A9FFFF3586E4F35454
          63B3785443BD6A2500BB8D3300E0973B00E6943D00DC7B3600B34B2400720E07
          00200000000600000001000000004B2A004F0000000700000002000000000000
          0000000000000000000000000000000000000000000B2475B2C351ABFFFF6ABB
          FFFF68BAFFFF67B9FFFF66B8FFFF63B8FFFF60B5FFFF5FB5FFFF40A5FFFF1743
          5FB0000000890000003000000006000000010000000100000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000D2B3B4C3A9FFEFE70BFFFFF6EBD
          FFFF6FBEFFFF70C0FFFF70BEFFFF6DBCFFFF67B9FFFF64B7FFFF5FB3FFFF2F90
          ECF40105089A0000004B0000000E000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000011E5F8D9A57AFFFFF75C1FFFF77C2
          FFFF78C4FFFF79C4FFFF77C3FFFF75C1FFFF6EBEFFFF68BBFFFF65B8FFFF42A2
          FFFF0C2435A00000006800000022000000040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000022983CCD36EBEFFFF7BC6FFFF7FC7
          FFFF81C9FFFF82CBFFFF81C8FFFF7BC7FFFF75C2FFFF6FBDFFFF69BAFFFF4EAA
          FFFF154363B10000008F00000055000000170000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000101082F87EDF07DC7FFFF7FC7FFFF86CD
          FFFF8BD0FFFF8CCFFFFF89CDFFFF83CBFFFF7AC5FFFF72C0FFFF6BBDFFFF5AB0
          FFFF1964A6D4002B3EAC00000088000000300000000600000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000010A12283192FBFC83CBFFFF83CBFFFF8BD0
          FFFF94D4FFFF96D7FFFF8FD2FFFF86CCFFFF7FC7FFFF78C4FFFF77C3FFFF62B6
          FFFF006C9DFF0073A5FD00070A97000000470000000C00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000365289127AC6FF86CEFFFF83CAFFFF8DD1
          FFFF96D6FFFF9BD9FFFF93D4FFFF87CDFFFF80CAFFFF7EC7FFFF1882B9FF1883
          BBFF0077A9FF007BAEFF0019239C000000540000001100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000003D5B900067A2FF87CFFFFF83CAFFFF8ACF
          FFFF90D3FFFF93D4FFFF8DD1FFFF86CDFFFF83C9FFFF53ABE5FF0071A3FF007A
          ACFF0081B4FF0080B3FF002738A3000000560000001200000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000395687005D8EFF6ABAF8FF81CAFFFF84CB
          FFFF88CEFFFF89CFFFFF86CDFFFF81C8FFFF82CAFFFF2D92CAFF007FB2FF008B
          BEFF008DC0FF0083B6FF002C3DA40000004D0000000F00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000002F476C006395FF1E7EB4FF84CEFFFF7EC6
          FFFF7EC7FFFF7FC8FFFF7EC8FFFF7CC6FFFF80C8FFFF0076A8FF008BBDFF008E
          C1FF008EC1FF0086B9FF0024349B0000003B0000000900000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000018243800689BFF006193FF3B93CEFF84CD
          FFFF80CAFFFF80C9FFFF7FC8FFFF82CBFFFF3197D0FF007EB0FF0091C4FF0090
          C3FF0092C5FF0085B6FE00121882000000240000000200000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000010303005C88E10074A6FF006495FF086D
          A2FF2A8BC3FF2A8CC5FF1B86BCFF077AAFFF007AACFF0090C2FF0091C4FF0093
          C6FF0094C7FF007196E10001014F000000100000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000002E4564006B9FFF007DB0FF007A
          ACFF0077A9FF007BADFF0082B4FF0089BCFF0090C3FF0091C4FF0096C9FF0099
          CCFF0091C6FF003141850000001F000000040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000436690006B9FFE0078
          ABFF0081B4FF0085B8FF0087BAFF0086B9FF008ABDFF0090C3FF0091C4FF008F
          C3FE005979A30000001E00000005000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000001D2D440045
          66AA005C87DA006390E2005F87D0004A69A6005475B0006189C6005575AB002D
          3D5B0000000D0000000300000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000030000000E0000001C0000002400000027000000240000
          0017000000060000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000060000001D00000047000000700000008900000090000000880000
          005B000000170000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0004000000221919197D3B3B3BC65D5D5DF86C6C6CFF666666FE393939BE0000
          007A0000001F0000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000010101
          0117343434A7787878FEBDBDBDFFCFCFCFFFB0B0B0FF939393FF545454DE0000
          0069000000190000000100000003000000070000000200000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000042E2E
          2E8B888888FFE9E9E9FFBCBCBCFFA5A5A5FFA3A3A3FF898989FF474747C70000
          003400000009000000070000001D0000002F0000001500000002000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000808081B6161
          61F5E6E6E6FFA7A7A7FFA2A2A2FFA6A6A6FF8A8A8AFF4E4E4EDC0909094D0000
          000F0000000A0000002C1919197B0000007B000000420000000C000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000001F1F1F578D8D
          8DFFADADADFFA5A5A5FFA7A7A7FF898989FF4A4A4ADC05050587000000450000
          00290202023B3A3A3AB2686868FE1212129D0000006800000019000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000012C2C2C778484
          84FEAAAAAAFFA6A6A6FFA8A8A8FF7D7D7DFE373737C4030303A6000000960303
          03883A3A3AC38F8F8FFEABABABF5313131BC0000008100000022000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000001000000112C2C2C8B8787
          87FFABABABFFA8A8A8FFA8A8A8FFAAAAAAFE757575FE656565FD565656E44B4B
          4BE2A1A1A1FFEFEFEFFFA7A7A7FE4D4D4DE30000008A00000024000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000100000010111111595C5C5CED9F9F
          9FFEACACACFFA9A9A9FFA8A8A8FFA9A9A9FFA2A2A2FF7C7C7CFF828282FF8282
          82F6FDFDFDFEAEAEAEFFA2A2A2FF5D5D5DF80000008100000022000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000010000001011111158595959EABABABAFFBABA
          BAFEABABABFFAAAAAAFFA9A9A9FFA8A8A8FFA8A8A8FFA9A9A9FF9C9C9CFF8E8E
          8EF9B5B5B5FDA2A2A2FFA2A2A2FF505050E60000006300000017000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000010000000F101010555A5A5AE9BEBEBEFFCACACAFDAAAA
          AAFEACACACFFACACACFFABABABFFAAAAAAFFA9A9A9FFA9A9A9FFA8A8A8FFA7A7
          A7FFA5A5A5FFA8A8A8FF8C8C8CFF323232B00000003600000009000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000010000000F101010545C5C5CE8C0C0C0FFCFCFCFFEABABABFEB5B5
          B5FFCACACAFFC5C5C5FFB3B3B3FFABABABFFAAAAAAFFA9A9A9FFA8A8A8FFA8A8
          A8FFAAAAAAFF9A9A9AFF5C5C5CF00C0C0C540000001100000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00010000000F0F0F0F515A5A5AE5C2C2C2FFD5D5D5FEAEAEAEFEB5B5B5FFC5C5
          C5FFBABABAFFC2C2C2FFC7C7C7FFACACACFFAFAFAFFFAEAEAEFFAEAEAEFFAFAF
          AFFF8D8D8DFF575757EA15151558000000100000000200000000000000000000
          0000000000000000000000000000000000000000000000000000000000010000
          000F0F0F0F515C5C5CE5C5C5C5FFDADADAFEB0B0B0FEB6B6B6FFC0C0C0FFBABA
          BAFFBBBBBBFFC7C7C7FFB8B8B8FF9F9F9FFF7D7D7DFF838383FF818181FF6969
          69FD424242B20B0B0B3200000009000000010000000000000000000000000000
          00000000000000000000000000000000000100000001000000020000000E1010
          104F5D5D5DE3C7C7C7FFE0E0E0FEB3B3B3FEB6B6B6FFBDBDBDFFB9B9B9FFBABA
          BAFFC3C3C3FFB8B8B8FFA0A0A0FF595959E91E1E1E7125252567282828650F0F
          0F2D000000070000000100000000000000000000000000000000000000000000
          00000000000000000004000000100000001B0000001F000000220D0D0D505E5E
          5EE1CBCBCBFFE7E7E7FEB6B6B6FEB7B7B7FFB7B7B7FFB8B8B8FFB8B8B8FFBEBE
          BEFFB9B9B9FFA5A5A5FF5E5E5EEC1212125A0000001100000002000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000100000009000000240000004F0000006F000000790A0A0A7E5E5E5EE1CCCC
          CCFFEDEDEDFEB9B9B9FEB7B7B7FFAFAFAFFFB7B7B7FFB9B9B9FFBABABAFFBABA
          BAFFA8A8A8FF636363EE1212125C000000120000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0009020202322929298F515151C55F5F5FD54E4E4EC65E5E5EE1CFCFCFFFF2F2
          F2FEBCBCBCFEB9B9B9FFA4A4A4FFB2B2B2FFB5B5B5FFB4B4B4FFBABABAFFABAB
          ABFF646464EE1515155E00000012000000020000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000050909
          0934545454C6999999FFBEBEBEFFB2B2B2FF939393FFB5B5B5FEFBFBFBFEC0C0
          C0FEB9B9B9FF9B9B9BFFACACACFFB1B1B1FFA9A9A9FFBBBBBBFFAFAFAFFF6868
          68F0161616610000001200000002000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000606061B5C5C
          5CCDB5B5B5FFE3E3E3FFD1D1D1FFC6C6C6FFB0B0B0FFBBBBBBFEC5C5C5FEBABA
          BAFF919191FFA8A8A8FFADADADFF9F9F9FFFBBBBBBFFB2B2B2FF6B6B6BF01616
          1661000000130000000200000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000039393980AFAF
          AFFFE9E9E9FFCBCBCBFFC8C8C8FFC8C8C8FFC8C8C8FFC6C6C6FFC7C7C7FF9292
          92FF9B9B9BFFA8A8A8FF939393FFBABABAFFB6B6B6FF6E6E6EF1191919650000
          0014000000020000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000656565CEDBDB
          DBFFCBCBCBFFCACACAFFC9C9C9FFC8C8C8FFC7C7C7FFC6C6C6FFC7C7C7FFB5B5
          B5FF898989FF8B8B8BFFBABABAFFB9B9B9FF707070F31A1A1A65000000140000
          0002000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000007F7F7FF6D0D0
          D0FDCDCDCDFFCDCDCDFFCDCDCDFFCCCCCCFFCACACAFFC8C8C8FFC6C6C6FFC8C8
          C8FFC6C6C6FFC6C6C6FFBDBDBDFF737373F31B1B1B6B00000014000000020000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000929292FED2D2
          D2FFD1D1D1FFB7B7B7FFA5A5A5FFAEAEAEFFB7B7B7FFC4C4C4FFCACACAFFC7C7
          C7FFC7C7C7FFC7C7C7FF777777F6171717900000002D00000004000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000989898FFD5D5
          D5FFB7B7B7FF6E6E6EDE3333337E4848488B595959A8838383FACCCCCCFFC8C8
          C8FFC7C7C7FFC5C5C5FF6C6C6CE5000000900000002C00000003000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000009B9B9BFFBBBB
          BBFF6F6F6FDF0F0F0F4A0000000E00000004000000175A5A5ABCAFAFAFFFCBCB
          CBFFC8C8C8FFCDCDCDFF868686FE060606890000002900000002000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000898989F37A7A
          7ADF121212410000000E00000002000000102B2B2B768C8C8CFCCDCDCDFFCCCC
          CCFFCBCBCBFFD0D0D0FF7D7D7DF90404046D0000001A00000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000353535561414
          142700000006000000010000000426262659888888F8D8D8D8FECCCCCCFCCBCB
          CBFFCFCFCFFFB2B2B2FF4F4F4FBD0000003C0000000A00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000E0E0E1A868686F1E1E1E1FED4D4D4FDCCCCCCFFCFCF
          CFFFCCCCCCFF7D7D7DF613131364000000160000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000131313249F9F9FFFEAEAEAFECCCCCCFECFCFCFFFB7B7
          B7FF8E8E8EFE3535358100000019000000040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000D0D0D168F8F8FFEA0A0A0FE969696FF7D7D7DF25656
          56B0242424550000000C00000003000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000001000000070000000D0000000C000000150000001C000000120000
          0004000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000020000
          000A0000001B0000003400000047000000470000005E00000073000000550000
          0024000000090000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000040000000E000000200000
          003F0808086F2223239C09090997272727A95D5D5DE6222222A90000009A0000
          006D000000320000000F00000002000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000001000000050000001100000026000000481111127B3E42
          45B5827B72F8AD814CFF838080FEA1A5A8FFCBCBCBFF9B9B9BFF3D3D3DC30303
          03A10000007E0000004200000017000000040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000100000007000000150000002C010101521C1C1D8853565BC6998A78FDCD9A
          58FFEAA344FFE2973BFFD5730AFF9C8B77FFC7C9CBFFCFCFCFFFB1B1B1FF5858
          58E10C0C0CA30000008E00000055000000220000000700000001000000000000
          0000000000000000000000000000000000000000000000000000000000020000
          0011000000320404045F2728299564696BD9A9947BFEDEA660FFEEA952FFE7A5
          50FFE3A14BFFE2A356FFD47207FF996F43FFCBCFD3FFC6C6C6FFC9C9C9FFC1C1
          C1FF747474F71C1C1CA700000099000000680000002F0000000C000000010000
          00000000000000000000000000000000000000000000000000000000000C0B0B
          0B4938393BA07E7E7EE9BDA07FFFECB169FFF1B161FFEBAC5EFFE7A959FFE5A6
          55FFE4A44EFFE6AF6CFFD67A10FF9A754BFFD2D5DAFFC4C4C4FFC5C5C5FFC5C5
          C5FFC9C9C9FF8F8F8FFE343434BC030303A10000007A0000003E000000140000
          0003000000000000000000000000000000000000000000000000303030589A95
          8EF6CFAD84FFF6BA73FFF4B76EFFEEB46BFFEDB067FFEAAE62FFE9AB5EFFE7A9
          59FFE5A552FFEABC82FFDA7F16FF99764EFFD5D9DDFFC3C3C3FFC2C2C2FFC1C1
          C1FFC2C2C2FFC8C8C8FFA6A6A6FF4D4D4DD9080808A100000087000000450000
          000F000000000000000000000000000000000000000000000000484A4B86E8B8
          86FFFABE7CFFF3BB78FFF2B774FFEFB56FFFEDB26BFFECB067FFEAAE62FFE9AA
          5BFFE7A552FFEFC895FFDC871DFF977752FFD7DBDFFFC0C0C0FFC0C0C0FFC0C0
          C0FFBFBFBFFFC0C0C0FFC2C2C2FFB7B7B7FF6B6B6BF2151515A1000000720000
          001C00000000000000000000000000000000000000000000000052555898EDBC
          8AFFF8C081FFF4BC7DFFF2BA78FFF0B773FFEFB56EFFEEB26AFFEFB266FFF8CA
          8EFFF2CE9DFFCDAD8CFFF5B665FF9A7950FFDBDEE2FFBEBEBEFFBFBFBFFFBEBE
          BEFFBDBDBDFFBEBEBEFFBBBBBBFFC0C0C0FFC4C4C4FF4E4E4ED2000000820000
          00220000000100000000000000000000000000000000000000005D6164A9F7C2
          8BFFF8C186FFF5BE81FFF4BC7CFFF4BB79FFF8C588FFFAD39FFFD3A880FF965B
          33FF5E2206FF4B1B05FF613D1FFF948A7DFFE0E1E3FFBDBDBDFFBDBDBDFFBCBC
          BCFFBDBDBDFFB8B8B8FFADADADFFB3B3B3FFBFBFBFFF5F5F5FDF000000880000
          00240000000100000000000000000000000000000000000000006B6F73BAFFC7
          8EFFFBC48BFFFAC68CFFFDD19EFFE9B683FFBC703EFF882A00FF721E00FF5523
          0BFF6C5A53FF9EA0A4FFDDE0E3FFE9EAECFFDEDFDFFFBABABAFFBBBBBBFFBCBC
          BCFFBDBDBDFFACACACFF9E9E9EFFA5A5A5FFB1B1B1FF727272EB0000008E0000
          00270000000100000000000000000000000000000000000000007D7F80CBFFD0
          97FFF8C58DFFE09E60FFBB5E16FF9F3400FF722300FF775647FF9E9FA0FFDDE1
          E4FFEDEFF0FFE9EAEAFFE6E6E6FFE7E7E7FFE3E3E3FFB7B7B7FFBABABAFFBBBB
          BBFFA7A7A7FF808080FF848484FF7D7D7DFF686868FF7D7D7DF9000000920000
          002C000000040000000100000001000000010000000000000000777979ACC6B5
          A6FEE1AB6FFF9B5918FF88664BFF9C9E9EFFD8E0E4FFEDF1F2FFEBECEDFFE8E9
          EAFFE9EBEEFFECF0F3FFEEF0F1FFECECECFFEDEDEDFFB5B5B5FFB8B8B8FFBDBD
          BDFF6D6D6DFF989898FF939393FF878787FF6A6A6AFF707070FE020202940000
          003A0000001B00000023000000270000001C0000000A00000001000000028B8C
          8ECADADEE3FFD1D6DCFFEDF1F4FFECEDEEFFEAEBEBFFEBEFF1FFEFF4F7FFEEF3
          F7FFDEC9B2FFAD7355FFC4BDBAFFF4F7F8FFFBFBFBFFB3B3B3FFB6B6B6FFBCBC
          BCFF545454FFC6C6C6FFA0A0A0FF848484FF6F6F6FFF797A7AFF0505059C0000
          006600000068030000820000008A0000006F0000003200000009000000019797
          97CDEDEEEEFFEBEDEFFFEEF2F6FFF1F6F9FFF0F2F2FFCDAA91FF9B6A52FFE3CB
          ABFFEEAC58FFDA8C37FF8C3900FFF8FFFFFFFEFEFEFFC3C3C3FFB4B4B4FFB9B9
          B9FF747474FF848484FFACACACFF7B7B7BFF757676FF8F9799FF0F0A09A43B08
          00B0751A01E9872903FE661A00D50902009D0000006600000018000000019E9E
          9ED1F3F4F6FFEFEBE6FFC2916EFF96664DFFEDC188FFEDAC59FFBE5A06FFCF8E
          4EFFF3B871FFEEB366FFC35A00FFDBE1E7FFFFFFFFFFDADADAFFB0B0B0FFB3B3
          B3FFB5B5B5FFA7A8A9FFA9B0B2FF7B7C7FFF869095FF956F66FF822000FB9241
          09FFA65509FFB55D04FFB05708FF4E1900BF0000008300000022000000009999
          99CCF9FDFFFFEFBC7CFFECAB56FFB94F00FFEFB26FFFF1B66FFFE0943CFFC381
          3FFFF7BC79FFEFB164FFD58D41FFF9FFFFFFFFFFFFFFF9F9F9FFABABABFFB1B1
          B1FFB1B1B2FFB9BFC2FF9F451CFF802C00FF973604FF9D3F00FFB45901FFC863
          00FFD16D08FFD87C1EFFE4923CFFA24D15F10000007E00000020000000008585
          85B4F9FDFFFFF4C286FFEEB46AFFDB8527FFD69B5EFFF4B872FFEAA04EFFE2D1
          C1FFFFF4E8FFFBEAD7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFADAD
          ADFFB5B6B7FFBAA9A5FFAD4000FFA3550AFFCF6500FFD36F0BFFD97C1FFFDE8B
          37FFE69B4FFFEFAC6AFFFDC58CFFAA6224EB0000005300000013000000006767
          6788EAEDEFFFFEECD8FFF3B46DFFEDAE6CFFF0EFEFFFFFF9F0FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFF9F8F7FFE0D7CEFFFFFFFFFFFFFFFFFFEDEDEDFFA7A7
          A7FFBABBBBFFD2D0CEFFBE5200FFBC7021FFE48D35FFDA8737FFE3984FFFF3B7
          79FFFDCA96FFFBC691FFE29E56FE5937138B0000001A00000004000000003434
          3442D2D2D2FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE4C3
          A2FFD8CBBDFFFFFFFFFFE9A459FFD5720AFFA46124FFF3F9FFFFFEFEFEFFC5C5
          C5FFA8A8A9FFEEF4F9FFC98E58FFD28537FFC18D59FFA59280FF664829C67849
          17AF9B6322B88C5D22A3482F11590000000C0000000300000000000000000101
          0102A3A3A3D6FCFCFCFFFFFFFFFFFDF6F0FFD2914FFFC19E7DFFF5E0C8FFE89E
          47FFCB6300FFB58154FFF6BA72FFEFB467FFC76710FFBCA497FFF2F4F5FFF6F6
          F6FFB3B3B3FFA2A3A4FFA5A9ADFFAAA6A2FFA6ABB0FF9FA2A6FF2A2C2EAB0000
          0065000000180000000100000001000000000000000000000000000000000000
          000045454552D3D3D3FEFFFFFFFFF6D1A4FFEDAD5DFFD07316FFB26D32FFF6BA
          72FFF0B061FFA24F14FFF8D6AFFFF3B467FFDF9B50FFE2E1E2FFEAEAEBFFE8E8
          E8FFF3F3F3FFCBCBCBFFA6A6A6FFA6A6A7FFA7A7A7FFA2A2A2FF363636B20000
          006B0000001A0000000100000000000000000000000000000000000000000000
          00000000000077777796DBDCDEFEF7EEE2FFF3B870FFEFAF5CFFC29779FFF3DE
          C4FFF0C085FFE0D0C2FFEAF0F6FFE8E7E4FFE9ECEEFFE1E3E6FFD8D8D8FFCBCB
          CCFFC0C0C0FFB1B1B1FFA4A4A4FFA4A4A4FFA4A4A4FFA3A3A3FF3E3E3EB90000
          00720000001C0000000100000000000000000000000000000000000000000000
          000000000000020202037A7A7A99D2D4D7FEECEAE8FFEBDCCAFFEAEFF5FFEAED
          F2FFE8EBF1FFE5E6E9FFDDDDDEFFD6D6D7FFD1D2D2FFCBCBCBFFB5B5B5FF9D9D
          9DFFC7C7C7FFADADADFFA4A4A4FFA3A3A3FFA2A2A2FFA5A5A5FF474747C20000
          00780000001E0000000100000000000000000000000000000000000000000000
          000000000000000000000000000049494959A9AAAAE9ECEDF2FFC8C8C8FFB7B7
          B7FFA1A1A1FF8C8C8CFF787878FF606060FF444444FF313131FF2E2E2EFF2323
          23FF8C8C8CFFB7B7B9FFA7A7A7FFA1A1A1FFA0A0A0FFA4A4A4FF525252CC0000
          007E000000200000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000018A8A8ABADBDBDBFF616161FF5B5B
          5BFF595959FF565656FF545454FF505050FF4E4E4EFF4B4B4BFF464646FF3C3C
          3CFF838383FFC0C0C0FFACACACFF9E9E9EFF9F9F9FFFA1A1A1FF5F5F5FD70000
          0084000000230000000100000000000000000000000000000000000000000000
          000000000000000000000000000000000001909090BCD4D4D4FF6A6A6AFF7272
          72FF6C6C6CFF686868FF646464FF606060FF5C5C5CFF575757FF535353FF4949
          49FF757575FFC4C4C4FFB3B3B3FF9D9D9DFF9D9D9DFFA0A0A0FF6D6D6DE30000
          008A000000250000000100000000000000000000000000000000000000000000
          000000000000000000000000000000000000959595C1CBCBCBFF737373FF8080
          80FF7A7A7AFF737373FF6B6B6BFF636363FF5D5D5DFF5B5B5BFF5E5E5EFF6969
          69FF828282FFC4C4C4FFB6B6B6FF969696FF999999FF9C9C9CFF787878EF0000
          0085000000250000000100000000000000000000000000000000000000000000
          000000000000000000000000000000000000979797C2C6C6C6FF4D4D4DFF6A6A
          6AFF797979FF8B8B8BFFA0A0A0FFB4B4B4FFC8C8C8FFDADADAFFEAEAEAFFF1F1
          F1FFF6F6F6FFFDFDFDFFFDFDFDFFE4E4E5FFC7C7C7FFACACACFF7C7C7CF90101
          015E0000001A0000000100000000000000000000000000000000000000000000
          000000000000000000000000000000000000989898C3E7E7E7FFE6E6E6FFE8E8
          E8FFEAEAEAFFEAEAEAFFE9E9E9FFE9E9E9FFE8E8E8FFE3E3E3FFDDDDDDFFD5D5
          D5FFCCCCCCFFC2C2C2FFB7B7B7FFADADADFC9F9F9FEE878787D85C5C5CB90202
          021B000000060000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000018181820383838574E4E4E7C6464
          64A07B7B7BC2989898E5919191E07A7A7ACA646464B35454549C454545863737
          376F292929581C1C1C4010101027050505100000000400000001000000010000
          0001000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000100000004000000090000000D0000000C0000
          0007000000020000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000100000007000000180000002C0000003E00000047000000450000
          0037000000230000001100000004000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00020000000F0000002F0006086600131B8C0018269800172299000B0F950000
          00920000007B0000005000000021000000060000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000030000
          001600080A4D00425FB0006FA0F40A81AFFB017DADFA0075A6FA006F9AFA005C
          77DF001E25A40000009700000064000000200000000400000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000000000D0020
          2C69005782D62CA0C3F835BEDDFC14A5D2FF0095C8FF018EC0FF0079ACFF0063
          96FC006D9CFD00394DBC000101950000004700000012000000090000000B0000
          0009000000040000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000002A3C5E0B8D
          BBFB48C5DFFE3DC2E0FE2AB6DBFF1EA6CFFF0F8AB8FF00659CFF1E8FB8FF2AA0
          C4FF0076A7FE0076A6FE001826A00000006D000000400000003F000000430000
          003C0000002B0000001A00000009000000010000000000000000000000000000
          000000000000000000000000000000000000000000000000000000557CBA7DEA
          F4FE88F5FAFF83F0F7FF76E8F2FF6DE2F1FF68E2F2FF5ED7EAFF2E9CBFFF088D
          BDFF38C1E1FF0287BAFE002538AE0004069A00131C9500151F97000E15970002
          04960000008A00000068000000360000000E0000000100000000000000000000
          0000000000000000000000000000000000000000000000000000006994D191FB
          FDFF74E6F2FF69DFEEFF5FD8EBFF55D2E8FF4BCBE4FF43C7E2FF3BC4E2FF30B4
          D7FF1CACD6FF129BC8FF005682E30981AFFB028ABCFF007EB4FF0071A6FF0067
          99F7003B56BC00080C9E0000007C0000002E0000000700000000000000000000
          00000000000000000000000000000000000000000000000000000078A3DB83F1
          F9FF67DEEDFF5CD6EAFF52D0E7FF49CAE3FF3FC3E0FF35BDDDFF2CB6DAFF24B1
          D8FF1BADD7FF0A95C5FF54CEE4FF52D4EBFF43C8E4FF3BBDDCFF33ACCFFF1A82
          ACFF006BA2FF006392EE00070B96000000480000000D00000000000000000000
          0000000000000000000000000000000000000000000000000000004C698B3ABC
          DCFF64DEEFFF53D0E8FF47C9E2FF3CC1DFFF33BBDCFF29B4D9FF1FB0D7FF17A9
          D5FF018EC0FF56C9E0FF8CF8FDFF7CECF5FF6FE2F0FF64DCEEFF56D6EBFF51D5
          EBFF4DCBE4FF098AB9FF001A279D000000520000001700000004000000000000
          000000000000000000000000000000000000000000000000000000020305005F
          839D19A5D1FE3CC0DEFF3AC0DFFF30B9DBFF27B2D9FF1FAFD8FF11A5D1FF0387
          BAFF005A84DD61D7E9FF75E9F3FF64DBECFF58D4E9FF4DCCE5FF42C5E1FF37BE
          DDFF2EB9DDFF21A4CDFF001D2BA00000006A00000045000000260000000C0000
          0002000000000000000000000000000000000000000000000000000000000000
          0000002B3B510083B9FD3EBFDCFF37BEDEFF0FA4D1FF008DC0FF0076AAFF006A
          9BFE0074A7FE43C5E1FF6DE2F0FF56D3E7FF4ACAE4FF3FC3E0FF34BDDCFF29B5
          DAFF20B3DBFF0B8CC8FE00151EA40015009B0002009500000078000000410000
          0017000000040000000000000000000000000000000000000000000000000000
          0000002A3B544CC2DCFF6CE2F1FF31B9DCFF019BCDFF0087BCFF0076AAFF0066
          99FF007FB3FE0084B9FE30B5D9FF4BCCE5FF42C7E3FF35BDE1FF29B7E1FF1AAB
          DEFF078ED5FF027072FD066D00F6047F07FE014F03D9000B00A20000008E0000
          0058000000260000000A00000001000000000000000000000000000000000000
          0000003A536F59CDE2FE71E6F1FF5FD8EBFF3BC1E0FF11A3D0FF0086B8FF006B
          9FFF0084B7FE006796F6001B27A100496FB7006EA6D90387BAFA0184A7FF027E
          79FF088A2FFF079B01FF04A306FF0CA217FE007B00FE016706F8002001A90001
          009D000000700000003900000013000000040000000000000000000000000000
          0000004C6B8A62D8E9FF8AF6FAFF62DAECFF30B9DCFF16A6D2FF1DA6CFFF118C
          B9FF006298FF0077B0FF00394EC0052C03A80D680DD7139114FE10A012FF0DA9
          0EFF0BA611FF07A20FFF039C07FF16AD27FE007F00FF007F00FE017003FE003E
          01C9000600A10000008600000050000000200000000700000000000000000000
          0001005171914BC6E0FE58D5EAFF1EADD5FF0091C7FF007FB5FF006EA3FF1B8C
          B5FF3BC1DFFF0B9BD2FF339D4EFF8B9B88FF37A148FE0FB022FF0FAA20FF0CA5
          1AFF0AA313FF049D0AFF009600FF16B027FE008100FF007F00FF007E00FE0074
          01FD005B00EE001700A300000097000000640000002400000005000000000000
          0001007BA9C97EEDF6FF4FCDE5FF3CC1E0FF27B2D7FF22A0C8FF0978A9FF005B
          92FF0085B9FF0AB1E3FFA2A5AEFFBBA4B5FF36A444FF0DAC21FF0DA61BFF07A0
          11FF069F0EFF1FB834FF38D15FFF48E282FF3AD166FF058904FF007B00FF007E
          00FF007900FD006800FD003500BA000200950000004D00000010000000000000
          00010AA3D1EC98FEFFFF82EFF7FF73E6F2FF66DDEDFF5AD8ECFF57D7EDFF48C3
          DEFF0B99C7FF72ACBEFFB9ADABFFBAABB7FF31A33EFF08A819FF24BD3DFF39D2
          60FF48E17DFF3BD472FF3BD46FFF33CD67FF2FC862FF3CD470FF1AA62EFF0079
          00FF007C00FF007B00FE006B00FD001C00A50000006500000017000000000003
          03030A9ECFF687F2FCFE69DEF1FF5AD5E9FF4DCCE5FF41C4E1FF34BCDDFF25B3
          D9FF14B0DBFFCFB7B1FFB4B1B1FFB7B3B6FF61B978FF3AE976FF39DA72FF3AD6
          70FF47E07AFF59F28CFF67FF9AFF67FF9AFF45DB77FF2ABB58FF30C061FF2DBB
          53FF038505FF007A00FF007500FF002B00B4000000750000001D000000000000
          0000006582952DB89BFE56D4E1FF4DCAF5FF3DC2EDFF30B6E7FF1EACE2FF0DA1
          D9FF6EAFC9FFD8D0CDFFD9DEDAFFDEE1DFFFD6C8D2FF94A198FF5CCC82FF58FD
          91FF5FFB97FF61FA97FF57F08AFF4DE779FF45DF6BFF2DC54AFF0EA221FF08A1
          11FF22B043FF10911EFE007900FE003E00C8000000760000001E000000000000
          0000000001021B9928D42FCB54FF2CC65CFF2AC16DFF2FC47EFF36D17DFF6DE1
          89FFFFF9F9FFF1E5EDFFC7C4C7FFB1B1B1FFA7A6A6FFA39EA1FFAA96A4FF669B
          6FFF0CB023FF08A117FF069F10FF039C0CFF039C0BFF049D09FF049E08FF009C
          00FF139925FF20A242FE149428FE005500E50000004D00000012000000000000
          00000000000125AF46E932CB64FC31C35EF63ACC64F938CF65FE30C95AFF23C3
          4EFF11BD3BFF37B453FFB6ABB4FFACACACFFAAAAAAFFA8A8A8FFAEA5ACFF699E
          70FF06AC1BFF10A921FF0DA61CFF0BA418FF09A213FF07A00FFF059E0AFF0099
          00FF119A1FFE087511FE024404C8002E01920000001C00000004000000000000
          00000001000225A24DE933CB66FE2FC85FFF2DC65BFF2BC455FF28C152FF26BF
          4DFF1EBD44FF4ABA63FFC6B7C3FFB4B4B4FFB2B2B2FFB0B0B0FFB6ADB4FF6EA2
          75FF03AA16FF0DA61BFF08A114FF059E0FFF039C07FF039C07FF0AA311FF11AC
          1EFF21B33BFF027304FE010E029D000000620000001700000000000000000000
          00000000000122A047D433CD66FF2FC85FFF2DC65BFF2AC356FF27C152FF24BE
          4BFF1BBA40FF4DBA65FFCABCC7FFB9B9B9FFB6B6B6FFB3B3B3FFB7B1B5FF7AAA
          83FF1AC640FF2EC953FF33CD5CFF39D466FF3ED973FF43DC7BFF42DC7BFF40DA
          79FF41DB77FF007700FF033708B3000000780000001F00000001000000000000
          00000000000127B552EA31C963FE2BC45BFF27C055FF28C154FE2BC558FE30CE
          5DFF2FD45EFF64D686FFEFDBEAFFE1E0E1FFE5E5E5FFE9E9E9FFEEEDEEFFEAE5
          EAFF62DB8CFF64F493FF6AF597FF6DF79AFF70FC9EFF72FFA0FF69FE9BFF33CE
          67FF3BD673FF139F20FF05560BD0000000880000002600000001000000000000
          00000001000129B258F44AE17DFC5DF48EFC5BF490FD79F9A1FD81FAA5FF87FB
          A9FF8DFBABFF8AFCA9FFCCFFD7FFFFF5FEFFF2F0F2FFECEBECFFE7E7E7FFE7E2
          E5FFD8D6D7FF83F9A4FF83FFA9FF7EFFA5FF7BFFA3FF76FFA1FF75FFA4FF45DF
          78FF39D46FFF2DC354FE046E08EE0000008B0000002D00000004000000000000
          0000000000000A2C1434239645CE44D774FE60FA92FE76FA9EFFC9FFCBFFC4FF
          C8FFBAFFC3FFB2FFC0FFA7FFB7FFBBFCC9FFF6EDF2FFECE8EBFFE3E3E3FFE0DF
          E0FFE2DBE0FFC0CEC3FF83FFA7FF89FFAEFF83FFAAFF77FFA2FF6FFF9FFF59F1
          8CFF3FDD77FF42E27DFD077C0FFB0007006E0000002400000004000000000000
          000000000000000000000005010517632F7C2EC35EF751EC85FE5EF892FFB2FF
          BFFFCAFFCDFFBFFFC6FFAEFFBEFF9CFFB3FF97FCB1FFEDE8EDFFF6E6F2FFF1E0
          EBFFF0DDEAFFF4D9EDFF98C6A8FF2DCB60FF2BBE56FF25B34CFF1FA540FE1B9A
          36FE168D2AFC0E821CED087010D6000E02350000000900000001000000000000
          00000000000000000000000000000000000008251229249244C441DA74FE4DEA
          82FF46E27CFF39DB70FF35D46AFF30CD64FE27C65BFA31C35EEC47B466D8309D
          4FC41D853BB00E70299C0D6023880D4F1F73093D1760072C0E4A041D0834010E
          041E000400090000000200000001000000010000000000000000000000000000
          00000000000000000000000000000000000000000000000201021550275F165F
          2E71124C245F0C371A4A082612340414081E0106020B00000002000000010000
          0001000000010000000100000001000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0001000000070000000D000000100000000F0000000800000002000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000030000000D0000
          001F0000003500000049000000520000004D000000390000001F0000000C0000
          0002000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000002000000070000000A0000
          000900000004000000010000000000000000000000040000001A000000440905
          0579180C0C961E0F0FA11A0C0C9F0A0505990000009200000070000000420000
          001E000000090000000100000000000000000000000000000000000000000000
          0000000000000000000000000001000000090000002200000035000000400000
          003F0000002A0000001600000008000000050000001B190D0D714C2727CD8051
          51FEA17777FFA98181FFA07777FF724141FE3B1B1BC80A0404A0000000930000
          006A0000003A0000001A00000007000000010000000000000000000000000000
          000000000000000000000000000202010125090505750F070793100707970101
          0196000000840000005F000000390000002B331C1C8E825252FCE7C6C6FFFFEE
          EEFFFFEAEAFFFFECECFFFFEEEEFFFFF4F4FFB79393FF5D2A2AFC301515BC0603
          03A00000008E0000006200000032000000110000000200000000000000000000
          000000000000000000000A060613704343E98A5D5DFFA17878FF7A4A4AFF4D20
          20EA200D0DAE0502029E000000911F12128E885959FEFFE2E2FFFFE2E2FFFFE0
          E0FFFFE8E8FFFFE2E2FFFFE2E2FFFFE5E5FFFFF3F3FFA87F7FFF703C3CFF5928
          28F8240E0EB20201019F00000083000000460000001200000001000000000000
          000000000000000000000703030B7A4C4CEAFFE7E7FFFFF3F3FFE2C3C3FE7843
          43FE6D3A3AFF582727FC2D0F0FC3653838E6EEC8C8FFFFDFDFFFFFDDDDFFF7DD
          DDFFE6B3B3FFF7CACAFFFFE2E2FFFFE2E2FFFFE8E8FFDFC3C3FF733E3EFF7D4A
          4AFF6A3737FF4D1E1EEE0D0404A2000000850000003700000009000000000000
          0000000000000000000000000000442C2C75B28888FFFFEBEBFFFDEBEBFE9D73
          73FB814E4EFF845151FF764343FF9A6A6AFFFFE3E3FFFFD9D9FFFFDEDEFFC5A0
          A0FFB07B7BFFC29090FFFFE6E6FFFFE0E0FFFFE3E3FFF4DFDFFF612C2CFF703D
          3DFF764343FF774444FF502222F40602029E0000006100000016000000000000
          0000000000000000000000000000060303097D4F4FE2F4D4D4FFFFE6E6FFEED1
          D1FC7F4B4BFE865353FF824F4FFFBD8F8FFFFFDCDCFFFFD7D7FFFFDFDFFFA179
          79FF8F5B5BFF915D5DFFFFE6E6FFFFDFDFFFFFE2E2FFFAE3E3FF663030FF6936
          36FF683535FF6E3B3BFF673434FF250F0FB40000007E00000020000000000000
          000000000000000000000000000000000000402A2A65B48686FFFFE9E9FFFFE8
          E8FFB58C8CFD875353FF855252FFC79898FFFFD9D9FFFFD5D5FFFFDEDEFF9368
          68FF814D4DFF8E5C5CFFFFE5E5FFFFDEDEFFFFE2E2FFE7CECEFF814C4CFF7E4B
          4BFF764343FF6D3A3AFF683535FF481F1FDF0000008800000024000000000000
          000000000000000000000000000000000000020101047E5252D8EFCBCBFFFFE4
          E4FFF9DBDBFE885858FE895656FFBE8D8DFFFFD8D8FFFFD3D3FFFFDBDBFF9D72
          72FF693434FFAE8181FFFFE2E2FFFFDDDDFFFFE3E3FFCEAEAEFF9B6767FF9562
          62FF8D5A5AFF845151FF7C4949FF5A2A2AF30000008200000022000000000000
          0000000000000000000000000000000000000000000038262658B08282FEFFE6
          E6FFFFE5E5FFC5A0A0FE8C5757FF9C6969FFFFDADAFFFFD1D1FFFFD5D5FFF2C7
          C7FFC09292FFFFDADAFFFFDBDBFFFFDCDCFFFDE6E6FFC08C8CFFB68383FFAD7A
          7AFFA47171FF9C6969FF925F5FFF522626E40000006B0000001A000000000000
          000000000000000000000000000100000004000000090100000C795454CDE9C3
          C3FFFFDFDFFFFDE1E1FE956767FE8D5959FFCD9C9CFFFFD9D9FFFFD4D4FFFFD5
          D5FFFFD9D9FFFFD8D8FFFFDADAFFFEE4E4FFE0B3B3FFD4A0A0FFCD9A9AFFC592
          92FFBE8B8BFFB78484FF986565FF391D1DBD000000450000000D000000000000
          000000000001000000080000001A0000002D0000003D0000003F2B1D1D64AD7D
          7DFEFFE4E4FFFFE1E1FFD5B3B3FE925D5DFF8F5C5CFFB78A8AFFEBC3C3FFFFE3
          E3FFFFE6E6FFFFE2E2FFFFDEDEFFF7C5C5FFEEBBBBFFE7B4B4FFE0ADADFFD9A6
          A6FFD4A1A1FFD29F9FFF7B4747FE180C0C7A0000001D00000003000000000000
          00010000000E00000033050303691209098E1109099606030396000000936C48
          48C8E5BDBDFFFFDEDEFFFDE3E3FEA57979FF986464FF956161FF8E5A5AFF9360
          60FFB88D8DFFEBC8C8FFFFE4E4FFFFDBDBFFFFD1D1FFFDCBCBFFF8C4C4FFF3C0
          C0FFEAB7B7FF8E5A5AFF3E2121A6000000210000000600000000000000000000
          000C0C07074A452828B47F4E4EF9A27777FFA47979FF895B5BFE542B2BDE4C2A
          2ACF996666FFFFE2E2FFFFDDDDFFE6C6C6FF966161FF9A6767FF986565FF9562
          62FF7D4A4AFF6E3D3DF9906060FDC49D9DFFEDCACAFFF4CDCDFFE6B8B8FFBC88
          88FF714141F2341C1C830000001500000004000000000000000000000004170E
          0E46744545E8CFA9A9FFFFEDEDFFFFEBEBFFFFECECFFFFF2F2FFE7C9C9FF7C49
          49FF6C3939FFCEA3A3FFFFDEDEFFFFE3E3FFB58B8BFF9C6868FF9B6868FF9865
          65FF946262FF512121F41009099F3720209F5B3434BE623737C9522E2EAF331D
          1D76090505230000000600000001000000000000000000000000040303187346
          46DAE1BBBBFFFFE6E6FFFFE0E0FFFFE8E8FFFFE4E4FFFFE3E3FFFFEBEBFFE1C4
          C4FF6F3A3AFF845151FFFFE1E1FFFFDCDCFFF2D4D4FF9B6666FF9E6B6BFF9B68
          68FF9B6868FF7E4B4BFF2A1313BA00000093000000420000000C000000010000
          000100000000000000000000000000000000000000000000000039262670B788
          88FFFFE4E4FFFFDDDDFFFBE3E3FFDEADADFFF2C7C7FFFFE4E4FFFFE2E2FFFFF2
          F2FF794D4DFF663232FFC49898FFFFDFDFFFFFE1E1FFC29C9CFF9E6A6AFF9D6A
          6AFF9A6767FF9B6868FF643131FC0A0404A00000007300000023000000030000
          00000000000000000000000000000000000000000000000000006A4646B7E5BC
          BCFFFFDCDCFFFFDDDDFFD4B1B1FFA77171FFC19090FFFFE5E5FFFFE1E1FFFFEC
          ECFF9F7A7AFF663333FF6A3737FFFFDCDCFFFFDADAFFFADFDFFF9F6D6DFFA06D
          6DFF9C6969FF9B6868FF885656FF3E1C1CCC000000990000004D000000100000
          0000000000000000000000000000000000000000000000000000895E5EDEFBD3
          D3FFFFD8D8FFFFDDDDFFB99393FF8B5757FF9A6767FFFFE6E6FFFFDFDFFFFFE8
          E8FFB38E8EFF845050FF754242FFBC8F8FFFFFDEDEFFFFDEDEFFCDABABFFA06B
          6BFF9E6B6BFF9C6969FF9A6767FF6F3C3CFE130909A20000007D0000002B0000
          0005000000000000000000000000000000000000000000000000926464E3FFD4
          D4FFFFD6D6FFFFDCDCFFAE8787FF7D4949FF9A6A6AFFFFE4E4FFFFDEDEFFFFE8
          E8FFBA9191FFA06D6DFF976363FF8A5656FFFFD8D8FFFFD9D9FFFFE5E5FFA473
          73FFA06D6DFF9C6969FF9A6767FF8F5C5CFF4B2525DF0101019F000000580000
          0015000000010000000000000000000000000000000000000000875E5EC8F3C5
          C5FFFFD4D4FFFFD9D9FFBE9595FF632E2EFFC39898FFFFE0E0FFFFDDDDFFFEE8
          E8FFC48F8FFFBC8989FFB27F7FFFA57171FFCA9C9CFFFFDDDDFFFFDCDCFFD7BA
          BAFF9F6A6AFF9E6B6BFF9A6767FF996666FF794646FF1E0F0FA9000000880000
          00350000000700000000000000000000000000000000000000005B414183D5A3
          A3FFFFD6D6FFFFD3D3FFFFD6D6FFD8ADADFFFFDDDDFFFFDBDBFFFFDFDFFFEECA
          CAFFDBA7A7FFD4A1A1FFCD9A9AFFC39090FFB78383FFFDD6D6FFFFDBDBFFFFE9
          E9FFA97B7BFF9D6969FF9B6767FF976464FF936060FF603232F0040202A00000
          00620000001800000001000000000000000000000000000000000F0B0B14A778
          78E7EBBCBCFFFFD6D6FFFFD6D6FFFFD9D9FFFFD8D8FFFFDDDDFFFEE3E3FFF9C5
          C5FFF2BEBEFFE9B6B6FFE1AEAEFFDAA7A7FFD4A0A0FFD0A2A2FFFED9D9FFFFE2
          E2FFEBCDCDFFC09797FFA87C7CFF956262FF925F5FFF824F4FFF321A1AB20000
          0078000000220000000200000000000000000000000000000000000000002A1F
          1F32A37676DED1A7A7FFE7C0C0FFEBC7C7FFF1D8D8FFFEEAEAFFFFE5E5FFFFDF
          DFFFFFD9D9FFFFD0D0FFFDC9C9FFF6C3C3FFC28F8FFF7A4E4EDE986969E2AF79
          79FDBB8787FFC79393FFD3A2A2FFD8ABABFFBF9090FFA17070FF744141FA0603
          0351000000140000000100000000000000000000000000000000000000000000
          00000605050841303053654949867C5959A8956A6ACAAB7878EBB58181FEBE90
          90FFC99E9EFFD3A6A6FFCC9C9CFFA97777FA5B3D3D9D0604042000000007110B
          0B183221214A5137377D704A4AAE855959D2784F4FC2613E3EAB3F26267E0000
          0012000000040000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000001000000010D090911251A
          1A343E2C2C584933336C3A28285B0F0B0B200000000500000001000000000000
          0000000000000000000000000000000000010000000100000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000020000000F0000001F000000250000
          0026000000260000002600000026000000260000002600000026000000260000
          0026000000260000002600000026000000260000002600000026000000260000
          002600000026000000250000001E0000000E0000000200000000000000000000
          00000000000000000000000000000000000F00000042000000770000008A0000
          008C0000008D0000008D0000008D0000008D0000008D0000008D0000008D0000
          008D0000008D0000008D0000008D0000008D0000008D0000008D0000008D0000
          008D0000008C0000008A00000077000000410000000E00000000000000000000
          00000000000000000000000000002424245A757575E08C8C8CF3898989F38787
          87F3878787F3848484F3848484F3828282F3808080F3808080F37D7D7DF37B7B
          7BF37B7B7BF3787878F3787878F3757575F3737373F3737373F3707070F36E6E
          6EF36F6F6FF3555555E10E0E0EA0000000780000001F00000000000000000000
          00000000000000000000000000007E7E7EE3EFEFEFFFEFEFEFFFEEEEEEFFEEEE
          EEFFEFEFEFFFEFEFEFFFEEEEEEFFEDEDEDFFEDEDEDFFECECECFFEAEAEAFFE9E9
          E9FFE8E8E8FFE6E6E6FFE5E5E5FFE3E3E3FFE1E1E1FFE0E0E0FFDEDEDEFFDCDC
          DCFFDADADAFFD8D8D8FF595959E50000008B0000002500000000000000000000
          0000000000000000000000000001949494F7F1F1F1FFEBEBEBFFEBEBEBFFEBEB
          EBFFECECEBFFEEEDEAFFF2EFEAFFF2EFE9FFEEECE8FFE8E8E7FFE7E7E6FFE4E4
          E4FFE5E4E3FFE8E2E1FFE9E2E1FFE6E0DEFFE0DDDCFFDADADAFFD8D8D8FFD6D6
          D6FFD4D4D4FFD9D9D9FF707070F70000008E0000002600000001000000000000
          0000000000000000000000000001929292F7F4F4F4FFEEEEEEFFEEEEEEFFF2F1
          EEFFFDF8EEFFC9D3F1FF8BA8F4FF81A0F4FFA1B5F1FFECECEBFFF3EFE8FFF2EA
          E7FFE8E6E6FF98D0E0FF76C5DDFF7EC6DCFFBBD5DCFFECE0DDFFDEDBDAFFD8D8
          D8FFD6D6D6FFDBDBDBFF717171F70000008E0000002700000001000000000000
          0000000000000000000000000001959595F7F7F7F7FFF0F0F0FFF7F5F1FFDFE5
          F3FF3773FCFF024DFFFF084FFFFF074DFFFF0246FFFF0344FFFF92A3F4FF88D2
          E5FF00A9DFFF00A7DDFF00A7DCFF00A5DAFF00A1D8FF26AED8FFCCD9DCFFE0DC
          DBFFD9D9D8FFDCDCDCFF737373F70000008E0000002700000001000000000000
          0000000000000000000000000001959595F7FAFAFAFFF6F5F3FFE5EAF5FF1560
          FFFF125FFFFF1760FFFF155EFFFF145AFFFF1256FFFF0F4CFFFF007FF0FF00B1
          E3FF00AFE2FF00AEE1FF00ADE0FF00ABDEFF00A9DCFF00A5D9FF00A4D7FFD0D9
          DBFFDCDAD9FFDEDEDEFF757575F70000008E0000002700000001000000000000
          0000000000000000000000000001969696F7FCFCFCFFFFFFF6FF4988FDFF1768
          FFFF1C6AFFFF1B68FFFF1965FFFF1762FFFF155CFFFF0F6BFAFF00BBE6FF00B5
          E7FF00B3E6FF00B2E5FF00B0E3FF00AEE1FF00ACDFFF00A9DCFF00A6DAFF31B1
          D8FFE8DDDAFFDFDFDFFF787878F70000008E0000002700000001000000000000
          0000000000000000000000000001979797F7FFFFFFFFE5EDF9FF0E68FFFF2173
          FFFF2074FFFF1F70FFFF1D6DFFFF1B69FFFF1961FFFF089BF2FF00BBEBFF00B8
          EBFF00B7EAFF00B6E9FF00B4E7FF00B2E5FF00AFE2FF00ACDFFF00A9DCFF00A3
          D9FFCDD7DCFFE2E0E0FF787878F70000008E0000002700000001000000000000
          0000000000000000000000000001989898F7FFFFFFFFB5D0FCFF1A74FFFF257C
          FFFF257BFFFF2378FFFF2176FFFF1F70FFFF1E65FFFF03B2F2FF00BFF0FF00BE
          F1FF00BCEFFF00BAEDFF00B8EBFF00B5E8FF00B2E5FF00AFE2FF00ACDFFF00A6
          DBFF99CCDBFFE6E2E1FF7B7B7BF70000008E0000002700000001000000000000
          0000000000000000000100000001999999F7FFFFFFFFB8D5FEFF1E7DFFFF2A84
          FFFF2983FFFF2780FFFF257DFFFF2276FFFF216CFFFF04B6F5FF00C2F4FF00C1
          F4FF00C0F3FF00BEF1FF00BBEEFF00B8EBFF00B5E8FF00B1E4FF00AEE1FF00A8
          DDFF99CDDCFFE7E3E2FF7B7B7BF70000008E0000002700000001000000000000
          00020000000F0000001F00000025989898F7FFFFFFFFEBF3FFFF1D83FFFF2E8D
          FFFF2D8BFFFF2B87FFFF2882FFFF257BFFFF2271FFFF0BA8FAFF00C8F8FF00C5
          F8FF00C4F7FF00C1F4FF00BEF1FF00BBEEFF00B7EAFF00B3E6FF00AFE2FF00A9
          DFFFCEDADEFFE5E3E3FF7E7E7EF70000008E0000002700000001000000000000
          000F00000042000000770000008AB3B3B3F9FFFFFFFFFFFFFFFF73B6FFFF68B2
          FFFF6AB2FFFF69AEFFFF66A8FFFF62A4FFFF619CFFFF58A5FEFF46DEFCFF46D9
          FDFF46D6FCFF46D4F9FF46D3F7FF46CFF4FF46CCF1FF46C9EEFF46C7EBFF4EC3
          E5FFEEE2DFFFE4E4E4FF7E7E7EF70000008E0000002700000001000000002424
          245A767575E08D8C8BF38B8989F3969594FF9A9898FF989695FF969595FF8C8E
          92FF8A8D90FF898B90FF87898EFF85878CFF83858CFF818389FF7F8489FF7D85
          86FF7B8384FF7A8184FF787F82FF747B7EFF747B7EFF5D757BFF37A4C3FFDAE4
          E6FFE4E1E0FFE4E4E4FF818181F70000008E0000002700000001000000007E7E
          7EE3F3EFEEFFE6EEF0FFD9EBF1FFDAECEFFFDAEBF0FFDAEAEFFFD9EAEFFFDAEA
          EEFFD8E7EDFFD7E7ECFFD6E7EAFFD5E4E9FFD4E4E7FFD3E1E7FFD1E1E4FFD0DF
          E2FFCEDDE0FFCDDBE0FFCBD8DDFFC9D8DBFFD3D9DAFFDCD9D8FF777979FFEDE9
          E7FFE0E0E0FFE5E5E5FF818181F70000008E0000002600000001000000019594
          93F7ECF1F2FF00C7FEFF00C5FAFF00C1F7FF00C0F5FF00BCF2FF00B9EFFF00B6
          EBFF00B2E8FF00B1E6FF00ADE3FF00ACE1FF00A8DEFF00A7DCFF00A3D9FF00A1
          D7FF009ED4FF009CD2FF009AD0FF0099CFFF0097CEFFD7D9DAFF7C7B7AFFE7E7
          E7FFE1E1E1FFE4E4E4FF848484F70000008B0000002500000000000000019593
          92F7E2F2F4FF00C8FDFF00C6F9FF00C3F6FF00C0F3FF00BDF0FF00BAEDFF00B8
          EBFF00B5E8FF00B2E5FF00B0E3FF00ADE0FF00AADDFF00A8DBFF00A5D8FF00A2
          D5FF00A0D3FF009DD0FF009BCEFF0099CCFF0096CCFFCBD7DAFF7D7C7BFFE7E7
          E7FFE1E1E1FFE5E5E5FF868686F7000000780000001F00000000000000019895
          95F7E3F3F9FF00C7FCFF00C5F8FF00C3F6FF00C0F3FF00BDF0FF00BAEDFF00B7
          EAFF00B4E7FF00B2E5FF00AFE2FF00ACDFFF00AADDFF00A7DAFF00A4D7FF00A1
          D4FF009FD2FF009CCFFF009ACDFF0099CCFF0096CCFFCDD8DBFF807F7EFFECEC
          ECFFE8E8E8FFE6E6E6FF707070E5000000420000000F00000000000000019896
          95F7DFF5FAFF00C4FCFF00C3F8FF00C0F5FF00BEF3FF00BBF0FF00B7EDFF00B4
          EAFF00B1E7FF00B0E5FF00ACE2FF00A9DFFF00A6DCFF00A4DAFF00A1D7FF009E
          D4FF009BD1FF0098CEFF0096CCFF0096CCFF0092CBFFCDD9DCFF7F7E7DFFABAB
          ABF98E8E8EF77A7A7AE42323235B0000000F0000000200000000000000019796
          96F7F7FBFDFFAFE8F8FFB5E9F7FFB5E8F6FFB6E7F5FFB4E7F4FFB5E4F2FFB3E4
          F1FFB2E1EFFFB1E0EDFFB0DEEBFFAFDCE9FFACDAE7FFABD9E5FFABD5E4FFA8D3
          E0FFA8D2DFFFA5CEDDFFA3CCD9FFA2CAD9FF9AC8D6FFDDDFDFFF787878F70000
          008E000000270000000100000001000000000000000000000000000000019797
          97F7FFFFFFFFFFFAF9FFFFFAF9FFFFFAF9FFFFFAF9FFFEF9F8FFFDF8F7FFFCF7
          F6FFFCF7F6FFF9F4F3FFF7F2F1FFF5F0EFFFF2EEEDFFF0ECEBFFEEEAE9FFECE8
          E7FFEBE7E6FFE7E3E2FFE5E1E0FFE3DFDEFFE1DDDCFFE1E0E0FF787878F70000
          008E000000270000000100000000000000000000000000000000000000019898
          98F7FFFFFFFFFBFBFBFFFCFCFCFFFCFCFCFFFBFBFBFFFBFBFBFFFAFAFAFFF8F8
          F8FFF7F7F7FFF5F5F5FFF3F3F3FFF1F1F1FFEFEFEFFFEDEDEDFFEBEBEBFFE9E9
          E9FFE6E6E6FFE4E4E4FFE1E1E1FFDFDFDFFFDDDDDDFFE1E1E1FF7B7B7BF70000
          008E000000270000000100000000000000000000000000000000000000019999
          99F7FFFFFFFFFFFFFFFFFEFEFEFFFEFEFEFFFFFFFFFFFDFDFDFFFCFCFCFFFBFB
          FBFFF9F9F9FFF7F7F7FFF5F5F5FFF3F3F3FFF1F1F1FFEFEFEFFFECECECFFEAEA
          EAFFE7E7E7FFE5E5E5FFE3E3E3FFE0E0E0FFDEDEDEFFE2E2E2FF7B7B7BF70000
          008E000000270000000100000000000000000000000000000000000000019898
          99F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFF
          FFFFFCFFFFFFFAFDFFFFF8FCFEFFF7FAFCFFF3F7F9FFF2F5F7FFF0F3F5FFEDF0
          F2FFECEEF0FFE8EBEDFFE7E9EBFFE3E6E8FFE1E4E5FFE3E3E4FF7E7E7EF70000
          008E00000027000000010000000000000000000000000000000000000001999A
          9BF7FFFFF8FFFCD8A4FFFAD9AAFFF8D7AAFFF7D5AAFFF5D3AAFFF3D1AAFFF1D0
          ABFFEECDAAFFEBC8A7FFE7C5A7FFE4C3A4FFE0BEA3FFDEBAA0FFD9B8A0FFD5B4
          9DFFD3B29BFFCEAD9BFFCBA998FFC9A796FFC6A290FFE4E5E5FF7E7F7FF70000
          008E000000270000000100000000000000000000000000000000000000019A9C
          9FF7FFF2D4FFF88700FFF28700FFED8200FFE77C00FFE07500FFDB7000FFD569
          00FFD06400FFC95E00FFC55900FFBE5300FFB94E00FFB24700FFAE4300FFA73C
          00FFA13500FF9C3000FF972B00FF962A00FF921F00FFE5E6E6FF818182F70000
          008E000000270000000100000000000000000000000000000000000000019C9E
          A1F7FFF5DAFFF88C00FFF38D00FFED8700FFE78100FFE27C00FFDC7600FFD771
          00FFD16B00FFCC6600FFC76100FFC15B00FFBC5600FFB65000FFB14B00FFAB45
          00FFA64000FFA13B00FF9C3600FF993300FF942600FFE5E7EAFF828282F70000
          008E000000260000000100000000000000000000000000000000000000009C9D
          A0F7FFF6DCFFF98D00FFF38D00FFEE8800FFE88200FFE37D00FFDD7700FFD872
          00FFD26C00FFCD6700FFC86200FFC35D00FFBD5700FFB85200FFB34D00FFAE48
          00FFA94300FFA43E00FFA03A00FF9D3700FF962700FFE5E7E8FF848585F70000
          008B000000250000000000000000000000000000000000000000000000009E9F
          A0F7FFFEF1FFFA8A00FFF48700FFEF8200FFE87A00FFE37500FFDE7000FFD76A
          00FFD26400FFCD5F00FFC75900FFC25400FFBC4E00FFB74900FFB24400FFAE40
          00FFA93B00FFA53700FFA23400FF9F3000FFA03600FFE8EBEEFF868686F70000
          00780000001F0000000000000000000000000000000000000000000000008B8B
          8BE4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFEFBFFFDFBF9FFFAF8F6FFF7F5F4FFF4F2
          F0FFF1EFEEFFEEECEAFFECE9E8FFE9E6E4FFE8EAECFFE7E8E8FF707070E50000
          00420000000F0000000000000000000000000000000000000000000000002D2D
          2D4E8B8B8BE4A1A2A3F79FA0A1F79E9FA0F79D9E9FF79C9D9EF79B9C9CF79A9B
          9BF79B9B9CF79A9A9BF7979898F7969797F7959697F7959697F7919293F79191
          92F7909091F78F8F90F78F9091F78E8F90F78F8F8FF77A7A7AE42323235B0000
          000F000000020000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000004000000100000001200000009000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000E0000003A00000050000000390000001A0000
          0007000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000563A3A88462F2F940E0909890000008E000000620000
          002A000000080000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000035252554A37070FF9E6D6DFC452E2EB60202029E0000
          006C000000250000000400000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00010000000100000004070404119E6C6CF7EEBEBEFFBA8A8AFF593C3CC80101
          019B000000570000001300000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000030000000C0000
          0019000000240000002F00000038835A5AD4E5B1B1FFF2C8C8FFB28282FF2F1E
          1EA9000000820000002800000003000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000900000021000000430100
          006909070784100C0C90110C0C947E5858DBE7B5B5FFECB9B9FFEAC7C7FF8255
          55EA0101019C0000004E00000015000000020000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000020000001000000038261C1C7F654B4BB79C78
          78E9BC8B8BFEC18E8EFFBF8C8CFFBE8B8BFFF5C1C1FFEFBBBBFFF8D7D7FFAC79
          79FF140D0DA40000008B00000048000000140000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000010000000F191313528A6767C6D2A0A0FFEABABAFFFDCF
          CFFFFFD1D1FFFFD0D0FFFFCDCDFFFCC9C9FFF5C4C4FFF2BEBEFFF7D5D5FFD6A9
          A9FF8D5E5EF0181111A2000000880000003E0000000C00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000062B202052BD9090EEEDC0C0FFFFD8D8FFFFD5D5FFFFD3
          D3FFFFD0D0FFFFCECEFFFFCCCCFFFDCACAFFF9C6C6FFF5C3C3FFF4C9C9FFF7DC
          DCFFE8C2C2FF956464F50F0A0AA0000000720000002000000002000000000000
          0000000000000000000000000000000000000000000000000000000000010000
          0004000000050E0A0A21BB8E8EE4F6CFCFFFFFDBDBFFFFD9D9FFFFD7D7FFFFD5
          D5FFFFD3D3FF020101FF000000FFFFCCCCFFFDCACAFFF9C6C6FFF5C2C2FFF1BD
          BDFFF6D5D5FFD9B0B0FF6A4646CE000000930000003A00000008000000000000
          000000000000000000000000000000000000000000020000000C0000001D0000
          00280000001C6D545486ECC1C1FFFFE0E0FFFFDCDCFFFFDBDBFFFFD9D9FFFFD8
          D8FFFFD6D6FFFFD4D4FFFFD1D1FFFFCFCFFFFFCCCCFFFDC9C9FFF8C5C5FFF4C1
          C1FFF0BDBDFFFAE0E0FFA97777FE0F0A0A9A0000005300000011000000000000
          0000000000000000000000000000000000040000001A0000004209060672140E
          0E7C00000037B88E8ECBFBDBDBFFFFE6E6FFFFDFDFFFFFDEDEFFFFDCDCFFFFDA
          DAFFFFD8D8FF755F5FFF735C5CFFFFD1D1FFFFCECEFFFFCDCDFFFAC8C8FFF6C4
          C4FFF2BEBEFFF5CFCFFFC79C9CFF2D1E1EA40000005F00000015000000000000
          00000000000000000000000000040000001F211717716A4949C59E6D6DFC2318
          188F0000002CD8A8A8E4FFEEEEFFFFFAFAFFFFEBEBFFFFE1E1FFFFDFDFFFFFDD
          DDFFFFDBDBFF412F2FFF3F2C2CFFFFD3D3FFFFD0D0FFFFCDCDFFFECACAFFF9C6
          C6FFF4C2C2FFF4C5C5FFD7B2B2FF432D2DAF0000005C00000014000000000000
          0000000000000000000100000014543C3C97B48080FDDBA9A9FF956868F00201
          01760000001FD4A4A4DCFDEEEEFFFFF9F9FFFFF6F6FFFFEBEBFFFFE2E2FFFFE0
          E0FFFFDDDDFF412C2CFF3E2A2AFFFFD5D5FFFFD2D2FFFFCFCFFFFECCCCFFFBC8
          C8FFF6C4C4FFF4C2C2FFD7B1B1FF412D2DAA0000004A0000000D000000000000
          000000000000000000064C37377CC08D8DFEF7C4C4FFE4B8B8FF634444C20000
          00730000002C9D7B7BA9F9DEDEFFFFFDFDFFFFF7F7FFFFF4F4FFFFEAEAFFFFE2
          E2FFFFDFDFFF422929FF3D2626FFFFD7D7FFFFD4D4FFFFD1D1FFFFCDCDFFFECA
          CAFFF8C5C5FFF7C8C8FFC99B9BFF281C1C910000002C00000004000000000000
          0000000000010F0B0B24AE7F7FF1F8C5C5FFFCCDCDFFDDB0B0FF4A3333B30000
          00930000006D30272777F3C4C4FEFFFBFBFFFFFAFAFFFFF7F7FFFFF3F3FFFFEB
          EBFFFFE3E3FF4A2828FF402525FFFFD8D8FFFFD5D5FFFFD2D2FFFFCFCFFFFFCB
          CBFFFAC8C8FFF2C7C7FFA37373EF080505570000001300000000000000000000
          00010000000C4A36367DD8A6A6FFFFCECEFFFFD6D6FFE8B9B9FF815A5ADA4430
          30B03F2B2BAC2C1E1EA4A78181D8F8D2D2FFFFFBFBFFFFFAFAFFFFF6F6FFFFF1
          F1FFFFEEEEFF552C2CFF4C2727FFFFD9D9FFFFD6D6FFFFD3D3FFFFD1D1FFFFCD
          CDFFFCCACAFFC69494FE412E2E860000001D0000000400000000000000000000
          000A0D0A0A40896666CEEDBEBEFFFFCFCFFFFED6D6FFFED5D5FFE0AFAFFFDDAB
          ABFFD8A5A5FFCC9999FFB68181FFDAA5A5FFF5C9C9FFFDECECFFFFF9F9FFFFF7
          F7FFFFF2F2FFFFEFEFFFFFEBEBFFFFE5E5FFFFD9D9FFFFD6D6FFFFD4D4FFF3C1
          C1FFC89797FD5A4242900000001A000000040000000000000000000000041711
          1139A37B7BDCE4B5B5FFFFD4D4FFFFD1D1FFFFD2D2FFFFE6E6FFFFE4E4FFFFE2
          E2FFFFE4E4FFFDE4E4FFFBDBDBFFEFC3C3FFE9B4B4FFEBB5B5FFF4C7C7FFF7D6
          D6FFFADFDFFFFDE4E4FFFDE2E2FFFBDBDBFFF4CCCCFFE9BABAFFD7A5A5FEA278
          78CE342727550000000D00000003000000000000000000000000030202139E76
          76CCEDC3C3FFFFDADAFFFFD7D7FFFFD4D4FFFFD3D3FFFFD1D1FFFFCECEFFFECC
          CCFFFFCACAFFFBC8C8FFF9CECEFFF9DCDCFFF8DDDDFFE7B8B8FFC08C8CFFAD81
          81E98C6D6DC3B48B8BD2C09292D5B28989CA967171AF694F4F832B21213D0000
          00090000000200000000000000000000000000000000000000004A383868E3B4
          B4FFFFDFDFFFFFDADAFFFFD9D9FFFFD7D7FFFFD6D6FFFFD4D4FF130C0CFF0502
          02FFFACBCBFFFFCBCBFFFAC8C8FFF7C2C2FFF6CDCDFFF9E3E3FFEDBEBEFFA371
          71FD140D0DA00000006E0000001C000000010000000100000001000000000000
          00000000000000000000000000000000000000000000000000009D7777BEF8D3
          D3FFFFDFDFFFFFDDDDFFFFDCDCFFFFDADAFFFFD8D8FFFFD7D7FFAE9090FFA989
          89FFFECFCFFFFECDCDFFFECCCCFFFAC7C7FFF6C2C2FFF4CBCBFFF8E1E1FFD6A2
          A2FF604242C50000008800000027000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000D7A5A5F5FFE8
          E8FFFFE4E4FFFFE0E0FFFFDFDFFFFFDDDDFFFFDBDBFFFFD9D9FF3D2B2BFF4331
          31FFFFD2D2FFFFCFCFFFFECDCDFFFCC9C9FFF8C5C5FFF4C0C0FFF7DCDCFFF2C6
          C6FF9B6B6BF40101018F0000002B000000020000000000000000000000000000
          0000000000000000000000000000000000000000000000000000E9B6B6FFFFF9
          F9FFFFF8F8FFFFE8E8FFFFE1E1FFFFE0E0FFFFDEDEFFFFDBDBFF4F3737FF2918
          18FF9E7E7EFFFCCFCFFFFFCECEFFFFCDCDFFFAC8C8FFF6C3C3FFF5CBCBFFF5D0
          D0FFAD7C7CFE0604048A00000027000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000E8B6B6FCFFF9
          F9FFFFF9F9FFFFF5F5FFFFE9E9FFFFE2E2FFFFE0E0FFFFDEDEFFFAD7D7FF9B7D
          7DFF231212FF7F6161FFFFD0D0FFFECDCDFFFCCACAFFF8C5C5FFF5C8C8FFF6CE
          CEFFA67676F8020202740000001D000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000C19595D1FCED
          EDFFFFFCFCFFFFF6F6FFFFF4F4FFFFE9E9FFFFE2E2FFFEDFDFFFFFDDDDFFFFDA
          DAFF3D2525FF2E1919FFFFD1D1FFFFCECEFFFFCBCBFFFAC7C7FFF9CFCFFFE6B4
          B4FF7B5757CB0000004C0000000F000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000006751516FF5CC
          CCFFFFFEFEFFFFF9F9FFFFF5F5FFFFF2F2FFFFEAEAFF6D4747FFA58282FF8E6C
          6CFF331919FF452B2BFFFFD3D3FFFFD0D0FFFECCCCFFFBC9C9FFFBCDCDFFC894
          94FF332424870000002200000004000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000006050506C196
          96CCF8DCDCFFFFFDFDFFFFF9F9FFFFF5F5FFFFF0F0FF866262FF5C3434FF4A26
          26FF634242FFCFAAAAFFFFD4D4FFFFD2D2FFFFCECEFFFFCECEFFDBA8A8FF7A57
          57C00101012F0000000800000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000001915
          151AC29898CDF6D0D0FFFEF3F3FFFFF9F9FFFFF6F6FFFFF1F1FFFFEDEDFFFFEA
          EAFFFFE4E4FFFFDADAFFFFD5D5FFFFD4D4FFFACBCBFFD8A5A5FF846060C10A08
          082E000000080000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000070606077E636381E1AFAFEEF3CBCBFFF7DADAFFFBE4E4FFFEE9E9FFFFE7
          E7FFFEE1E1FFF9D2D2FFEFC2C2FFE0AFAFFFB78A8AE8543E3E7B020202160000
          0004000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000B08080C503E3E58896B6B98AF8787C4C39696DDC698
          98E4BD9191DEA17C7CC3755959973F30305B0604041400000004000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000006A41036CBB7C
          22BFBE822DBFBA7D28BFBE822BBFBA7D28BFBE822BBFBA7D27BFBE812BBFBA7C
          26BFBE802ABFBA7C25BFBE7F29BFB97B25BFBF7E22BF6C42046C000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000B57619C3E8CA
          B2FFFDE7E1FFE5CFC6FFFDE6DDFFE5CFC6FFFDE4DBFFE5CCC2FFFDE0D6FFE5C7
          BEFFFDDAD1FFE5C3B9FFFDD5CCFFE4BDB7FFFFD4BAFFC38023C3000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000B27620C0D2BF
          B9FFDBD0D5FFCEC2C5FFDCCFD2FFCEC1C4FFDCCED0FFCEBEC0FFDCC8CBFFCEB9
          BCFFDCC2C5FFCEB3B6FFDCBBBEFFCDACB1FFE2BCB6FFBA7B26C0000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000003B2771EC2EAD6
          C2FFFEF2EAFFE8DBD0FFFEF2E7FFE8DACFFFFEEDE3FFE8D5CAFFFEE8DDFFE8CF
          C4FFFEDFD5FFE8C7BCFFFFD7CCFFE8BFB7FFFFD7C4FFBF7F28BF000000000000
          00000000000000000000000000000000000000000002000000070000000A0000
          000900000004000000010000000000000000000000040000001AA26D28D08B99
          DFFF8FA6FCFF849AEEFF91A7FAFF8499EDFF91A5F9FF8497EBFF91A2F5FF8493
          E7FF919EF1FF848FE4FF9099EDFF7E88E1FF9B9CE1FFAB732DBF000000000000
          0000000000000000000000000001000000090000002200000035000000400000
          003F0000002A0000001600000008000000050000001B190D0D71A66D3BF25A8B
          F3FF5F9FFFFF508AFFFF629FFFFF508AFFFF629FFFFF508BFFFF62A0FFFF508B
          FFFF62A1FFFF508CFFFF5F9FFFFF4283FFFF76ACF3FFA17331BF000000000000
          000000000000000000000000000202010125090505750F070793100707970101
          0196000000840000005F000000390000002B331C1C8E825252FCD49B61FF6B92
          EEFF6498FFFF6090FDFF6799FFFF6090FDFF6799FFFF6090FDFF6799FEFF608F
          FCFF6798FEFF608FFCFF6494FDFF5284FBFF779FEEFFA17030BF000000000000
          000000000000000000000A060613704343E98A5D5DFFA17878FF7A4A4AFF4D20
          20EA200D0DAE0502029E000000911F12128E885959FEFFE2E2FFEFAF5AFFD8D4
          D8FFEBEFFFFFD5D8E5FFEBEEFDFFD5D8E5FFEBEFFEFFD5D5E3FFEBE7F6FFD5CC
          D9FFEBDCECFFD5C3D0FFEBD3E2FFD4BACAFFF2D2D8FFBC7E2BBF000000000000
          000000000000000000000703030B7A4C4CEAFFE7E7FFFFF3F3FFE2C3C3FE7843
          43FE6D3A3AFF582727FC2D0F0FC3653838E6EEC8C8FFFFDFDFFFF2B059FFD6CF
          C3FFDFE0E1FFD2D1CEFFE0DFDCFFD2D1CEFFE0E0DDFFD2CFCCFFE0D8D6FFD2C6
          C3FFE0CECCFFD2BCBAFFE0C6C3FFD1B4B5FFE5C3B8FFB97B24C1000000000000
          0000000000000000000000000000442C2C75B28888FFFFEBEBFFFDEBEBFE9D73
          73FB814E4EFF845151FF764343FF9A6A6AFFFFE3E3FFFFD9D9FFF0AF59FFE0DB
          D5FFF4F7FDFFDDDFE2FFF4F6F8FFDDDFE2FFF4F7F9FFDDDDE0FFF4EEF1FFDDD3
          D6FFF4E4E6FFDDC9CCFFF4DADCFFDCC0C6FFFAD8D2FFBD7F2AC5000000000000
          0000000000000000000000000000060303097D4F4FE2F4D4D4FFFFE6E6FFEED1
          D1FC7F4B4BFE865353FF824F4FFFBD8F8FFFFFDCDCFFFFD7D7FFF2AF57FFD5C8
          B4FFDFDAD2FFD2CCC2FFDFD9CFFFD2CCC2FFDFD9CFFFD2C9BFFFDFD2C7FFD2C1
          B7FFDFC9BFFFD2B9AFFFDFC1B7FFD1B1AAFFE5C0ADFFBA7C23C7000000000000
          000000000000000000000000000000000000402A2A65B48686FFFFE9E9FFFFE8
          E8FFB58C8CFD875353FF855252FFC79898FFFFD9D9FFFFD5D5FFFEAE42FFF59A
          18FFEE8B00FFF08E00FFEF8C00FFF08E00FFEF8C00FFF08E00FFEF8C00FFF08D
          00FFEF8C00FFF08D00FFEF8B00FFF08C00FFF28F00FFC17401CB000000000000
          000000000000000000000000000000000000020101047E5252D8EFCBCBFFFFE4
          E4FFF9DBDBFE885858FE895656FFBE8D8DFFFFD8D8FFFFD3D3FFFFB65BFFFBB2
          57FFF5A341FFF6A540FFF6A540FFF6A540FFF6A540FFF6A540FFF6A540FFF6A5
          40FFF6A540FFF6A540FFF6A541FFF5A542FFF99F24FFB06A03BB000000000000
          0000000000000000000000000000000000000000000038262658B08282FEFFE6
          E6FFFFE5E5FFC5A0A0FE8C5757FF9C6969FFFFDADAFFFFD1D1FFFFC396FFFBB1
          5BFFEFA347FFFFB558FFFFB659FFFFB659FFFEB85BFFEFA245FFED9F43FFEA9D
          40FFE89B3EFFE6993CFFE4963AFFD3882CF8AF6F12D14F300161000000000000
          000000000000000000000000000100000004000000090100000C795454CDE9C3
          C3FFFFDFDFFFFDE1E1FE956767FE8D5959FFCD9C9CFFFFD9D9FFFFD4D4FFFFD5
          D5FFFFD9D9FFFFD8D8FFFFDADAFFFEE4E4FFE0B3B3FFD4A0A0FFCD9A9AFFC592
          92FFBE8B8BFFB78484FF986565FF391D1DBD000000450000000D000000000000
          000000000001000000080000001A0000002D0000003D0000003F2B1D1D64AD7D
          7DFEFFE4E4FFFFE1E1FFD5B3B3FE925D5DFF8F5C5CFFB78A8AFFEBC3C3FFFFE3
          E3FFFFE6E6FFFFE2E2FFFFDEDEFFF7C5C5FFEEBBBBFFE7B4B4FFE0ADADFFD9A6
          A6FFD4A1A1FFD29F9FFF7B4747FE180C0C7A0000001D00000003000000000000
          00010000000E00000033050303691209098E1109099606030396000000936C48
          48C8E5BDBDFFFFDEDEFFFDE3E3FEA57979FF986464FF956161FF8E5A5AFF9360
          60FFB88D8DFFEBC8C8FFFFE4E4FFFFDBDBFFFFD1D1FFFDCBCBFFF8C4C4FFF3C0
          C0FFEAB7B7FF8E5A5AFF3E2121A6000000210000000600000000000000000000
          000C0C07074A452828B47F4E4EF9A27777FFA47979FF895B5BFE542B2BDE4C2A
          2ACF996666FFFFE2E2FFFFDDDDFFE6C6C6FF966161FF9A6767FF986565FF9562
          62FF7D4A4AFF6E3D3DF9906060FDC49D9DFFEDCACAFFF4CDCDFFE6B8B8FFBC88
          88FF714141F2341C1C830000001500000004000000000000000000000004170E
          0E46744545E8CFA9A9FFFFEDEDFFFFEBEBFFFFECECFFFFF2F2FFE7C9C9FF7C49
          49FF6C3939FFCEA3A3FFFFDEDEFFFFE3E3FFB58B8BFF9C6868FF9B6868FF9865
          65FF946262FF512121F41009099F3720209F5B3434BE623737C9522E2EAF331D
          1D76090505230000000600000001000000000000000000000000040303187346
          46DAE1BBBBFFFFE6E6FFFFE0E0FFFFE8E8FFFFE4E4FFFFE3E3FFFFEBEBFFE1C4
          C4FF6F3A3AFF845151FFFFE1E1FFFFDCDCFFF2D4D4FF9B6666FF9E6B6BFF9B68
          68FF9B6868FF7E4B4BFF2A1313BA00000093000000420000000C000000010000
          000100000000000000000000000000000000000000000000000039262670B788
          88FFFFE4E4FFFFDDDDFFFBE3E3FFDEADADFFF2C7C7FFFFE4E4FFFFE2E2FFFFF2
          F2FF794D4DFF663232FFC49898FFFFDFDFFFFFE1E1FFC29C9CFF9E6A6AFF9D6A
          6AFF9A6767FF9B6868FF643131FC0A0404A00000007300000023000000030000
          00000000000000000000000000000000000000000000000000006A4646B7E5BC
          BCFFFFDCDCFFFFDDDDFFD4B1B1FFA77171FFC19090FFFFE5E5FFFFE1E1FFFFEC
          ECFF9F7A7AFF663333FF6A3737FFFFDCDCFFFFDADAFFFADFDFFF9F6D6DFFA06D
          6DFF9C6969FF9B6868FF885656FF3E1C1CCC000000990000004D000000100000
          0000000000000000000000000000000000000000000000000000895E5EDEFBD3
          D3FFFFD8D8FFFFDDDDFFB99393FF8B5757FF9A6767FFFFE6E6FFFFDFDFFFFFE8
          E8FFB38E8EFF845050FF754242FFBC8F8FFFFFDEDEFFFFDEDEFFCDABABFFA06B
          6BFF9E6B6BFF9C6969FF9A6767FF6F3C3CFE130909A20000007D0000002B0000
          0005000000000000000000000000000000000000000000000000926464E3FFD4
          D4FFFFD6D6FFFFDCDCFFAE8787FF7D4949FF9A6A6AFFFFE4E4FFFFDEDEFFFFE8
          E8FFBA9191FFA06D6DFF976363FF8A5656FFFFD8D8FFFFD9D9FFFFE5E5FFA473
          73FFA06D6DFF9C6969FF9A6767FF8F5C5CFF4B2525DF0101019F000000580000
          0015000000010000000000000000000000000000000000000000875E5EC8F3C5
          C5FFFFD4D4FFFFD9D9FFBE9595FF632E2EFFC39898FFFFE0E0FFFFDDDDFFFEE8
          E8FFC48F8FFFBC8989FFB27F7FFFA57171FFCA9C9CFFFFDDDDFFFFDCDCFFD7BA
          BAFF9F6A6AFF9E6B6BFF9A6767FF996666FF794646FF1E0F0FA9000000880000
          00350000000700000000000000000000000000000000000000005B414183D5A3
          A3FFFFD6D6FFFFD3D3FFFFD6D6FFD8ADADFFFFDDDDFFFFDBDBFFFFDFDFFFEECA
          CAFFDBA7A7FFD4A1A1FFCD9A9AFFC39090FFB78383FFFDD6D6FFFFDBDBFFFFE9
          E9FFA97B7BFF9D6969FF9B6767FF976464FF936060FF603232F0040202A00000
          00620000001800000001000000000000000000000000000000000F0B0B14A778
          78E7EBBCBCFFFFD6D6FFFFD6D6FFFFD9D9FFFFD8D8FFFFDDDDFFFEE3E3FFF9C5
          C5FFF2BEBEFFE9B6B6FFE1AEAEFFDAA7A7FFD4A0A0FFD0A2A2FFFED9D9FFFFE2
          E2FFEBCDCDFFC09797FFA87C7CFF956262FF925F5FFF824F4FFF321A1AB20000
          0078000000220000000200000000000000000000000000000000000000002A1F
          1F32A37676DED1A7A7FFE7C0C0FFEBC7C7FFF1D8D8FFFEEAEAFFFFE5E5FFFFDF
          DFFFFFD9D9FFFFD0D0FFFDC9C9FFF6C3C3FFC28F8FFF7A4E4EDE986969E2AF79
          79FDBB8787FFC79393FFD3A2A2FFD8ABABFFBF9090FFA17070FF744141FA0603
          0351000000140000000100000000000000000000000000000000000000000000
          00000605050841303053654949867C5959A8956A6ACAAB7878EBB58181FEBE90
          90FFC99E9EFFD3A6A6FFCC9C9CFFA97777FA5B3D3D9D0604042000000007110B
          0B183221214A5137377D704A4AAE855959D2784F4FC2613E3EAB3F26267E0000
          0012000000040000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000001000000010D090911251A
          1A343E2C2C584933336C3A28285B0F0B0B200000000500000001000000000000
          0000000000000000000000000000000000010000000100000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000663F076CA170
          2DBFA37430BF9E6E30BFA37430BF9E6E30BFA37430BF9E6E30BFA37430BF9E6E
          30BFA37430BF9E6E30BFA37430BF9D6E30BFA7762DBF6841076C000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000009C682EC3789B
          E1FF7EAFF0FF6693F0FF81AFF0FF6693F0FF81AFF0FF6693F0FF81AFF0FF6693
          F0FF81AFF0FF6693F0FF81AFF0FF6292F0FF95BBE1FFAB792EC3000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000976631C05482
          F4FF4B86FFFF3F77FFFF4F87FFFF3F77FFFF4F87FFFF3F77FFFF4F87FFFF3F77
          FFFF4F87FFFF3F77FFFF4F87FFFF3B75FFFF6291F4FF9E6F31C0000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000003976530C26692
          F0FF69A3FFFF5389FFFF6DA4FFFF5389FFFF6DA4FFFF5389FFFF6DA4FFFF5389
          FFFF6DA4FFFF5389FFFF6DA4FFFF4F88FFFF81AFF0FFA37430BF000000000000
          00000000000000000000000000000000000000000002000000070000000A0000
          000900000004000000010000000000000000000000040000001A966630D05783
          F0FF4F87FFFF4378FFFF5389FFFF4378FFFF5389FFFF4378FFFF5389FFFF4378
          FFFF5389FFFF4378FFFF5389FFFF3F77FFFF6593F0FF9E6E30BF000000000000
          0000000000000000000000000001000000090000002200000035000000400000
          003F0000002A0000001600000008000000050000001B190D0D71AA6F3AF26692
          F0FF69A3FFFF5389FFFF6DA4FFFF5389FFFF6DA4FFFF5389FFFF6DA4FFFF5389
          FFFF6DA4FFFF5389FFFF6DA4FFFF4F88FFFF81AFF0FFA37430BF000000000000
          000000000000000000000000000202010125090505750F070793100707970101
          0196000000840000005F000000390000002B331C1C8E825252FCD19862FF5783
          F0FF4F87FFFF4378FFFF5389FFFF4378FFFF5389FFFF4378FFFF5389FFFF4378
          FFFF5389FFFF4378FFFF5389FFFF3F77FFFF6593F0FF9E6E30BF000000000000
          000000000000000000000A060613704343E98A5D5DFFA17878FF7A4A4AFF4D20
          20EA200D0DAE0502029E000000911F12128E885959FEFFE2E2FFD79E69FF6692
          F0FF69A3FFFF5389FFFF6DA4FFFF5389FFFF6DA4FFFF5389FFFF6DA4FFFF5389
          FFFF6DA4FFFF5389FFFF6DA4FFFF4F88FFFF81AFF0FFA37430BF000000000000
          000000000000000000000703030B7A4C4CEAFFE7E7FFFFF3F3FFE2C3C3FE7843
          43FE6D3A3AFF582727FC2D0F0FC3653838E6EEC8C8FFFFDFDFFFD79D67FF5783
          F0FF4F87FFFF4378FFFF5389FFFF4378FFFF5389FFFF4378FFFF5389FFFF4378
          FFFF5389FFFF4378FFFF5389FFFF3F77FFFF6593F0FF9E6E30C1000000000000
          0000000000000000000000000000442C2C75B28888FFFFEBEBFFFDEBEBFE9D73
          73FB814E4EFF845151FF764343FF9A6A6AFFFFE3E3FFFFD9D9FFD59C68FF6290
          F4FF66A2FFFF4F87FFFF69A3FFFF4F87FFFF69A3FFFF4F87FFFF69A3FFFF4F87
          FFFF69A3FFFF4F87FFFF69A3FFFF4B86FFFF7DAFF4FFA27431C5000000000000
          0000000000000000000000000000060303097D4F4FE2F4D4D4FFFFE6E6FFEED1
          D1FC7F4B4BFE865353FF824F4FFFBD8F8FFFFFDCDCFFFFD7D7FFDBA064FF6D8E
          DFFF6391F0FF5883F0FF6692F0FF5883F0FF6692F0FF5883F0FF6692F0FF5883
          F0FF6692F0FF5883F0FF6692F0FF5582F0FF789BE1FFA2702DC7000000000000
          000000000000000000000000000000000000402A2A65B48686FFFFE9E9FFFFE8
          E8FFB58C8CFD875353FF855252FFC79898FFFFD9D9FFFFD5D5FFFDAD43FFED94
          1FFFE58407FFE78707FFE68607FFE78707FFE68607FFE78707FFE68607FFE787
          07FFE68607FFE78707FFE68607FFE78707FFE9890AFFBF7302CB000000000000
          000000000000000000000000000000000000020101047E5252D8EFCBCBFFFFE4
          E4FFF9DBDBFE885858FE895656FFBE8D8DFFFFD8D8FFFFD3D3FFFFB65BFFFDB3
          56FFF8A540FFF8A63FFFF8A63FFFF8A63FFFF8A63FFFF8A63FFFF8A63FFFF8A6
          3FFFF8A63FFFF8A63FFFF8A63FFFF8A640FFFBA022FFB06A03BB000000000000
          0000000000000000000000000000000000000000000038262658B08282FEFFE6
          E6FFFFE5E5FFC5A0A0FE8C5757FF9C6969FFFFDADAFFFFD1D1FFFFC396FFFBB1
          5BFFEFA347FFFFB558FFFFB659FFFFB659FFFEB85BFFEFA245FFED9F43FFEA9D
          40FFE89B3EFFE6993CFFE4963AFFD3882CF8AF6F12D14F300161000000000000
          000000000000000000000000000100000004000000090100000C795454CDE9C3
          C3FFFFDFDFFFFDE1E1FE956767FE8D5959FFCD9C9CFFFFD9D9FFFFD4D4FFFFD5
          D5FFFFD9D9FFFFD8D8FFFFDADAFFFEE4E4FFE0B3B3FFD4A0A0FFCD9A9AFFC592
          92FFBE8B8BFFB78484FF986565FF391D1DBD000000450000000D000000000000
          000000000001000000080000001A0000002D0000003D0000003F2B1D1D64AD7D
          7DFEFFE4E4FFFFE1E1FFD5B3B3FE925D5DFF8F5C5CFFB78A8AFFEBC3C3FFFFE3
          E3FFFFE6E6FFFFE2E2FFFFDEDEFFF7C5C5FFEEBBBBFFE7B4B4FFE0ADADFFD9A6
          A6FFD4A1A1FFD29F9FFF7B4747FE180C0C7A0000001D00000003000000000000
          00010000000E00000033050303691209098E1109099606030396000000936C48
          48C8E5BDBDFFFFDEDEFFFDE3E3FEA57979FF986464FF956161FF8E5A5AFF9360
          60FFB88D8DFFEBC8C8FFFFE4E4FFFFDBDBFFFFD1D1FFFDCBCBFFF8C4C4FFF3C0
          C0FFEAB7B7FF8E5A5AFF3E2121A6000000210000000600000000000000000000
          000C0C07074A452828B47F4E4EF9A27777FFA47979FF895B5BFE542B2BDE4C2A
          2ACF996666FFFFE2E2FFFFDDDDFFE6C6C6FF966161FF9A6767FF986565FF9562
          62FF7D4A4AFF6E3D3DF9906060FDC49D9DFFEDCACAFFF4CDCDFFE6B8B8FFBC88
          88FF714141F2341C1C830000001500000004000000000000000000000004170E
          0E46744545E8CFA9A9FFFFEDEDFFFFEBEBFFFFECECFFFFF2F2FFE7C9C9FF7C49
          49FF6C3939FFCEA3A3FFFFDEDEFFFFE3E3FFB58B8BFF9C6868FF9B6868FF9865
          65FF946262FF512121F41009099F3720209F5B3434BE623737C9522E2EAF331D
          1D76090505230000000600000001000000000000000000000000040303187346
          46DAE1BBBBFFFFE6E6FFFFE0E0FFFFE8E8FFFFE4E4FFFFE3E3FFFFEBEBFFE1C4
          C4FF6F3A3AFF845151FFFFE1E1FFFFDCDCFFF2D4D4FF9B6666FF9E6B6BFF9B68
          68FF9B6868FF7E4B4BFF2A1313BA00000093000000420000000C000000010000
          000100000000000000000000000000000000000000000000000039262670B788
          88FFFFE4E4FFFFDDDDFFFBE3E3FFDEADADFFF2C7C7FFFFE4E4FFFFE2E2FFFFF2
          F2FF794D4DFF663232FFC49898FFFFDFDFFFFFE1E1FFC29C9CFF9E6A6AFF9D6A
          6AFF9A6767FF9B6868FF643131FC0A0404A00000007300000023000000030000
          00000000000000000000000000000000000000000000000000006A4646B7E5BC
          BCFFFFDCDCFFFFDDDDFFD4B1B1FFA77171FFC19090FFFFE5E5FFFFE1E1FFFFEC
          ECFF9F7A7AFF663333FF6A3737FFFFDCDCFFFFDADAFFFADFDFFF9F6D6DFFA06D
          6DFF9C6969FF9B6868FF885656FF3E1C1CCC000000990000004D000000100000
          0000000000000000000000000000000000000000000000000000895E5EDEFBD3
          D3FFFFD8D8FFFFDDDDFFB99393FF8B5757FF9A6767FFFFE6E6FFFFDFDFFFFFE8
          E8FFB38E8EFF845050FF754242FFBC8F8FFFFFDEDEFFFFDEDEFFCDABABFFA06B
          6BFF9E6B6BFF9C6969FF9A6767FF6F3C3CFE130909A20000007D0000002B0000
          0005000000000000000000000000000000000000000000000000926464E3FFD4
          D4FFFFD6D6FFFFDCDCFFAE8787FF7D4949FF9A6A6AFFFFE4E4FFFFDEDEFFFFE8
          E8FFBA9191FFA06D6DFF976363FF8A5656FFFFD8D8FFFFD9D9FFFFE5E5FFA473
          73FFA06D6DFF9C6969FF9A6767FF8F5C5CFF4B2525DF0101019F000000580000
          0015000000010000000000000000000000000000000000000000875E5EC8F3C5
          C5FFFFD4D4FFFFD9D9FFBE9595FF632E2EFFC39898FFFFE0E0FFFFDDDDFFFEE8
          E8FFC48F8FFFBC8989FFB27F7FFFA57171FFCA9C9CFFFFDDDDFFFFDCDCFFD7BA
          BAFF9F6A6AFF9E6B6BFF9A6767FF996666FF794646FF1E0F0FA9000000880000
          00350000000700000000000000000000000000000000000000005B414183D5A3
          A3FFFFD6D6FFFFD3D3FFFFD6D6FFD8ADADFFFFDDDDFFFFDBDBFFFFDFDFFFEECA
          CAFFDBA7A7FFD4A1A1FFCD9A9AFFC39090FFB78383FFFDD6D6FFFFDBDBFFFFE9
          E9FFA97B7BFF9D6969FF9B6767FF976464FF936060FF603232F0040202A00000
          00620000001800000001000000000000000000000000000000000F0B0B14A778
          78E7EBBCBCFFFFD6D6FFFFD6D6FFFFD9D9FFFFD8D8FFFFDDDDFFFEE3E3FFF9C5
          C5FFF2BEBEFFE9B6B6FFE1AEAEFFDAA7A7FFD4A0A0FFD0A2A2FFFED9D9FFFFE2
          E2FFEBCDCDFFC09797FFA87C7CFF956262FF925F5FFF824F4FFF321A1AB20000
          0078000000220000000200000000000000000000000000000000000000002A1F
          1F32A37676DED1A7A7FFE7C0C0FFEBC7C7FFF1D8D8FFFEEAEAFFFFE5E5FFFFDF
          DFFFFFD9D9FFFFD0D0FFFDC9C9FFF6C3C3FFC28F8FFF7A4E4EDE986969E2AF79
          79FDBB8787FFC79393FFD3A2A2FFD8ABABFFBF9090FFA17070FF744141FA0603
          0351000000140000000100000000000000000000000000000000000000000000
          00000605050841303053654949867C5959A8956A6ACAAB7878EBB58181FEBE90
          90FFC99E9EFFD3A6A6FFCC9C9CFFA97777FA5B3D3D9D0604042000000007110B
          0B183221214A5137377D704A4AAE855959D2784F4FC2613E3EAB3F26267E0000
          0012000000040000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000001000000010D090911251A
          1A343E2C2C584933336C3A28285B0F0B0B200000000500000001000000000000
          0000000000000000000000000000000000010000000100000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          000000000000000000020000000D0000001B00000022000000210000001C0000
          001900000014000000100000000C000000080000000400000001000000010000
          0001000000010000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000F000000410000006D000000820000007E000000730000
          00680000005D00000051000000450000003A0000002F00000027000000220000
          001E0000001A00000015000000110000000D0000000900000005000000020000
          0001000000010000000100000000000000000000000000000000000000000000
          0000000000003C20045C864604C1BA6006EC9B5006D77C3F04C5603203B64725
          03AA331B02A12111019B1209019607040095010000930000008B000000810000
          00760000006A0000006000000054000000480000003D00000032000000290000
          00230000001E0000001400000005000000000000000000000000000000000000
          000000000000D06C08F5F6CB92FFE0872BFFFEB15FFFF7A54EFFF19B41FFED92
          36FFE78B2CFFE38222FFDD7B16FFD5710DFDC66805F2AC5603DD894502C96B36
          02B9502801AC3A1E01A32714019C170B009809050096020100940000008E0000
          0083000000760000005400000015000000000000000000000000000000000000
          000000000001D16C06F5FFEFCAFFE18A2FFFFFB96AFFFFB465FFFFB362FFFFB2
          5EFFFFB25DFFFFB05CFFFFB05CFFFFB15AFFFFAE58FFFDA74EFFF79D42FFF195
          38FFEB8E2EFFE68625FFE17F1BFFDB7714FFD4700AFEC66503F6AF5600E28D46
          00CD613101B40000008300000022000000000000000000000000000000000000
          000000000001D16C05F5FFEDCAFFE38E35FFFFB96BFFFFB462FFECB566FFF0C5
          8DFFF0C285FFEFBD80FFFDB668FFFFAC54FFFFA639FFFFA944FFFFAB4CFFFFA9
          4EFFFFA84EFFFFA84EFFFFA748FFFFA546FFFFA545FFFFA343FFFEA03FFFF998
          37FFC16001F50000008D00000025000000010000000000000000000000000000
          000000000001D46D06F5FFEECBFFE5943EFFFFBB6EFFFEB35FFFE7CDAFFFF7FE
          FFFFEAEDF2FFCDD3DDFFEDBD82FFF89D32FFE2E7EDFFEAE5DFFFE1D7C7FFD2C8
          B7FFFFB25AFFFAAA4DFFE5B77EFFEBB675FFF0B470FFFAB365FFFFA141FFFFA2
          42FFC06101F50000008E00000026000000010000000000000000000000000000
          000000000001D56E09F5FFEFCEFFE99947FFFFBB70FFFDB362FFEBD2BBFFFFFF
          FFFFF9FDFFFFD6DCE5FFF0BA77FFF19633FFFDFFFFFFFFFFFFFFEDEEF0FFC8CD
          D6FFFFB153FFF4B25DFFCFD6E2FFCACED3FFBEC3CAFFC8C2B6FFFFA543FFFFA2
          44FFC16203F50000008E00000026000000010000000000000000000000000000
          000000000001D66E09F5FFEFD1FFEBA150FFFFBE72FFFEB96CFFDC9E68FFEFC1
          94FFEDC696FFDEC193FFF4B35EFFEB9139FFF3EEEAFFFDFFFFFFEAF0F6FFC6D0
          DCFFFFAC48FFF8B35AFFE8EDF4FFE1E1E1FFD5D6D8FFD6CAB6FFFFA543FFFFA5
          48FFC26303F50000008E00000026000000010000000000000000000000000000
          000000000001D76F0AF5FFF0D2FFEEA659FFFFBD75FFFFBC71FFFDB14EFFFFB3
          51FFFFB556FFFFB960FFFFB666FFFFB565FFF2983DFFF49732FFFBA034FFFCA9
          40FFFFAC51FFF7B360FFFCFFFFFFF3F3F3FFE4E5E7FFE1D1B8FFFFA544FFFFA5
          49FFC36404F50000008E00000026000000010000000000000000000000000000
          000000000001D8720BF5FFF1D6FFF0AB62FFFFBF76FFFEB96BFFE2C9A9FFECF3
          FCFFE2E4E9FFC9CBCDFFF0C087FFFBA742FFE8D0A8FFEED4ACFFE8CCA7FFDFC3
          9FFFFFB561FFF1AD61FFFFFFFFFFFFFFFFFFF1F3F6FFE9D5B8FFFFA646FFFFA8
          4DFFC46505F50000008E00000026000000010000000000000000000000000000
          000000000001D9740CF5FFF1D6FFF2B26CFFFFC179FFFDBA6CFFEDD1B6FFFFFF
          FFFFF7F8F9FFD5D8DEFFEFBD7FFFF49C3CFFF8FDFFFFFDFFFFFFE9EBEFFFC6CD
          D5FFFFB75EFFEBA661FFFFFFFFFFFFFFFFFFFAFCFFFFEED8B6FFFFA647FFFFA9
          50FFC66605F50000008E00000026000000010000000000000000000000000000
          000000000001DB750DF5FFF2D9FFF4B976FFFFC27BFFFDBC73FFDAB297FFFAF7
          F2FFF1F1F1FFCFD7E2FFEFB973FFEB953EFFFDFFFFFFFFFFFFFFEDF2F9FFC8D0
          DBFFFFB453FFE5A366FFFFFFFFFFFFFFFFFFFCFFFFFFEFD8B3FFFFA84AFFFFAC
          53FFC96706F50000008E00000026000000010000000000000000000000000000
          000000000001DC750EF5FFF2DBFFF7C180FFFFC47EFFFFC27CFFF8B164FFF4A5
          4EFFFAA846FFFFAF44FFFFB864FFFBB367FFE69B52FFF1AA5BFFF3B15DFFF0B2
          62FFFFB45AFFEA9C53FFE7B68BFFEDBD90FFF0C697FFEEB66AFFFFAC53FFFFAC
          55FFC96909F50000008E00000026000000010000000000000000000000000000
          000000000001DF7610F5FFF3DEFFF9C68AFFFFC481FFFFC17BFFE7B872FFEDD3
          ACFFE9D0ABFFDCC6AAFFF5C487FFFFB259FFF0C07EFFF4C585FFF1C387FFEDBF
          89FFFFBA6BFFFCAE51FFFAB154FFFDB458FFFDB65EFFFFB867FFFFAE59FFFFAF
          58FFCA6A09F50000008E00000026000000010000000000000000000000000000
          000000000001DF7711F5FFF4DEFFFBCC94FFFFC683FFFEC179FFEACFB1FFFDFF
          FFFFF0F2F6FFD0D5DBFFEEC288FFF5A244FFF1F7FFFFF6FAFFFFE3E6EBFFBFC8
          D1FFFFBC6BFFECAC61FFEEF8FFFFECF1F8FFD4D8E1FFCCC4B6FFFFB159FFFFAF
          5BFFCB6B0AF50000008E00000026000000010000000000000000000000000000
          000000000001E07911F5FFF4E1FFFED5A2FFFFC785FFFDC27BFFE8CDB7FFFFFF
          FFFFF8FCFFFFD4DBE5FFEFBE7EFFED9C46FFFEFFFFFFFFFFFFFFEEF1F6FFC7CE
          D8FFFFB95FFFE9A868FFFFFFFFFFFFFFFFFFE3E7EDFFD3C6AEFFFFB15AFFFFB2
          5DFFCC6C0BF50000008E00000026000000010000000000000000000000000000
          000000000001E17A12F5FFF5E4FFFFD7A7FFFFC988FFFFC886FFE0A166FFEDB4
          76FFF1B873FFEEB970FFFBBB6CFFF3AC64FFE2B083FFF0BF8AFFEDBF83FFE2B9
          7EFFFFB962FFE29857FFE7C3A1FFEFCBA0FFE6C595FFE2B675FFFFB25FFFFFB2
          60FFCD6D0CF50000008E00000026000000010000000000000000000000000000
          000000000001E27B13F5FFF6E6FFFFD9AAFFFFCB8BFFFFCA8AFFFFD087FFFFCF
          82FFFFCE81FFFFCC7FFFFFC77FFFFFC57FFFFFC37AFFFFC176FFFFC074FFFFBF
          72FFFFBC72FFFFBD71FFFFBA69FFFFB866FFFFB664FFFFB564FFFFB464FFFFB4
          64FFCF6D0CF50000008E00000026000000010000000000000000000000000000
          000000000001E37C16F5FFF7E9FFFFDAACFFFFCC8EFFFFD088FF805E6BFF5F5E
          A6FF6460A8FF5755AAFFDAB090FFFFB65EFFC09F6DFFC5A77AFFC1A781FFB5A2
          83FFFFC57CFFEDA850FFCBA56FFFCEA977FFC8A87DFFD4B082FFFFB767FFFFB7
          65FFD06E0DF50000008E00000026000000010000000000000000000000000000
          000000000001E67D16F5FFF8EDFFFFDCAFFFFFCE90FFFFD188FF5755A3FF3763
          F8FF2F53E3FF0F2BCCFFC39D8BFFFAAD52FFB3B6BEFFB8BABDFFA6A7AAFF858B
          91FFFFC575FFDC9F59FFB4BAC3FFB3B5B9FF9B9FA3FFA39986FFFFBB6AFFFFB7
          69FFD0700FF50000008E00000026000000010000000000000000000000000000
          000000000001E77E17F5FFF8EEFFFFDDB2FFFFCF93FFFFD18BFF4B4DA5FF3769
          FFFF2C53EAFF0B2AD4FFC29680FFF0A553FFC3C8CFFFC8CDD2FFAEB1B7FF8991
          9BFFFFC169FFD6995EFFC9D1DAFFC2C7CDFFA3A8B0FFA69980FFFFBC6BFFFFBA
          6CFFD2700FF50000008E00000026000000010000000000000000000000000000
          000000000001E88018F5FFF9F2FFFFDEB5FFFFD196FFFFD395FFBF8969FFBB8E
          77FFC39472FFC2936FFFF7BD77FFF8BC79FFD79A60FFE3A764FFE6AB5DFFE6AC
          5BFFFFC274FFEBA862FFDD9F62FFE5A85FFFE7AA59FFEEAE59FFFFBB6FFFFFBA
          70FFD37110F50000008E00000026000000010000000000000000000000000000
          000000000001E98119F5FFFAF3FFFFE0B7FFFFD39AFFFFD29AFFFFD598FFFFD4
          95FFFFD092FFFFCF8FFFFFCB8CFFFFCA8AFFFFC988FFFFC785FFFFC683FFFFC5
          82FFFFC37FFFFFC37DFFFFC27CFFFFC078FFFFC078FFFFBF76FFFFBE74FFFFBC
          70FFD47210F50000008E00000026000000010000000000000000000000000000
          000000000001E9821BF5FFFBF7FFFFE1BAFFFFD49DFFF1C874FFB6D78FFFBBDC
          9AFFBADC9DFFBEDD9FFFBCE0A1FFBEE0A3FFC1E3A6FFC1E4AAFFC6E6ADFFC7E8
          B0FFCAEBB3FFCEEBB6FFD1EEBAFFD5F0BDFFD9F2C1FFDCF6C6FFF7E0AFFFFFBB
          71FFD57413F50000008E00000026000000010000000000000000000000000000
          000000000001EB831CF5FFFEF9FFFFE3BDFFFFD8A4FFCBAB33FF31D372FF44D4
          76FF4ED67BFF58D981FF60DC87FF6ADF8EFF72E294FF7BE599FF85E89FFF8FEB
          A5FF97EFABFFA1F2B1FFABF4B6FFB3F7BDFFBDFAC3FFC1FFC9FFF2E1ADFFFFBD
          72FFD67413F50000008E00000026000000010000000000000000000000000000
          000000000001EC841DF5FEFEFCFFFFE4BFFFFFDAA7FFC29E36FF39D573FF4CD3
          76FF54D67CFF5DD982FF65DC88FF6EDF8DFF78E293FF7FE499FF89E79EFF90EA
          A4FF9AEDAAFFA1F0AFFFA9F3B5FFB2F5BAFFB9F9BEFFB9FBC3FFF1E1ADFFFFBD
          76FFD77513F50000008E00000026000000010000000000000000000000000000
          000000000001ED861DF5FEFFFFFFFFE5C2FFFFDDABFFB59336FF39D474FF4AD3
          75FF53D77CFF5BDA82FF64DC87FF6BE08EFF74E395FF7CE79AFF84E9A1FF8CEC
          A7FF95EFADFF9BF2B3FFA4F4B9FFA9F6BDFFAFF8C0FFADFAC2FFEEE1AEFFFFC1
          79FFD87816F50000008D00000025000000010000000000000000000000000000
          000000000000EE8720F5FEFFFFFFFFE7C5FFFFE0AEFFA48535FF2ED873FF40D5
          75FF4DD174FF5ACF75FF69CB73FF74CA72FF81C76EFF8EC56DFF9AC468FFA6C2
          64FFB2C260FFBDC15AFFC8C155FFD1C354FFDACB69FFDDD585FFF8D496FFFFC2
          7DFFDB7816F50000008700000024000000000000000000000000000000000000
          000000000000EF8721F5FFFFFFFFFFE8C7FFFFE0AEFFD6925CFFD3874CFFE18C
          50FFE89555FFED9E5CFFF2A664FFF6AE6AFFF9B56FFFFDBA76FFFEBF7AFFFFC3
          81FFFFC787FFFFCB8BFFFFCC90FFFFCC91FFFFCD8FFFFFCA8CFFFFC886FFFFC5
          83FFDE7B19F5000000620000001A000000000000000000000000000000000000
          000000000000F08B25F5FCE7D2FEFBEACEFCFFDEADFFFFDEAAFFFFD9A1FFFFD3
          98FFFFCC8EFFFEC683FFFCC07AFFFCBB70FFFBB566FFFAAE5EFFF9AA56FFF7A5
          4EFFF6A046FFF59B3EFFF39637FFF29230FFEF8B28FEE98721FAE3861EF3E37F
          1CE8BF6C1AC70000001A00000007000000000000000000000000000000000000
          0000000000005E371160BD6C1DC3EA8823F0DD7E20E4D07720D8BF6E1DCBB267
          1ABFA56018B2985718A68A50159A7D48128D71421280643A0F7358320D674C2C
          0C5A4025094D331E073F281606311B100423100902170704010C010000030000
          0001000000010000000100000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000020000000200000002000000020000000200000002000000020000
          0002000000020000000200000002000000020000000200000002000000020000
          0002000000020000000200000002000000020000000200000002000000020000
          0002000000020000000200000002000000010000000000000000000000000000
          00060000000F0000001300000014000000140000001400000014000000140000
          0014000000140000001400000014000000140000001400000014000000140000
          0014000000140000001400000014000000140000001400000014000000140000
          0014000000140000001400000013000000120000000A00000002000000020000
          0016000000350000003C0000003D0000003D0000003D0000003D0000003D0000
          003D0000003D0000003D0000003D0000003D0000003D0000003D0000003D0000
          003D0000003D0000003D0000003D0000003D0000003D0000003D0000003D0000
          003D0000003D0000003D0000003D000000320000001E000000070000001E0808
          0899161616B9141414BB141414BB131313BB131313BB141414BB141414BB1414
          14BB141414BB141414BB141414BB141414BB141414BB151515BB151515BB1515
          15BB151515BB151515BB151515BB151515BB151515BB161616BB161616BB1616
          16BB161616BB171717BB161616BE0404048F0000003200000009020202517474
          74FFC6C6C6FFC1C1C1FFBFBFBFFFC3C3C3FFC5C5C5FFC8C8C8FFC5C5C5FFC3C3
          C3FFC9C9C9FFC3C3C3FFC7C7C7FFC9C9C9FFCACACAFFCACACAFFC9C9C9FFC8C8
          C8FFCACACAFFC9C9C9FFC9C9C9FFC6C6C6FFCACACAFFC8C8C8FFCACACAFFC8C8
          C8FFC8C8C8FFCACACAFFC6C6C6FF333333F0000000420000000603030358AAAA
          AAFFFFFFFFFFEFEFEFFFF8F8F8FFF2F2F2FFF1F1F1FFE5E5E5FFF3F3F3FFFBFB
          FBFFEBEBEBFFFFFFFFFFF5F5F5FFEFEFEFFFE7E7E7FFF3F3F3FFF7F7F7FFFEFE
          FEFFEFEFEFFFF9F9F9FFFAFAFAFFFFFFFFFFF5F5F5FFFFFFFFFFF6F6F6FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF464646F4000000450000000603030354A5A5
          A5FFF0F0F0FF7A7A7AFFC5C5C5FF8D8D8DFF787878FF8C8C8CFF969696FFA3A3
          A3FF7A7A7AFFABABABFF989898FF707070FF686868FF616161FF777777FFA7A7
          A7FF7A7A7AFF525252FF848484FFF9F9F9FF8D8D8DFFBABABAFF9E9E9EFFB5B5
          B5FFC0C0C0FF959595FFFFFFFFFF404040EF000000430000000603030354A5A5
          A5FFEEEEEEFF696969FFC3C3C3FFACACACFF818181FF939393FF8E8E8EFF9F9F
          9FFF696969FFADADADFF8C8C8CFF686868FF686868FF7C7C7CFF7D7D7DFFAAAA
          AAFF6E6E6EFF6D6D6DFF929292FFF8F8F8FF7C7C7CFFB6B6B6FF8B8B8BFFB6B6
          B6FFB4B4B4FF848484FFFFFFFFFF404040EF000000430000000603030354A5A5
          A5FFEFEFEFFF6D6D6DFFB4B4B4FFF7F7F7FFEAEAEAFFE6E6E6FFEDEDEDFFEDED
          EDFFE4E4E4FFF5F5F5FFEBEBEBFFEEEEEEFFEFEFEFFFF1F1F1FFF3F3F3FFF5F5
          F5FFECECECFFF2F2F2FFF6F6F6FFFAFAFAFFF2F2F2FFF3F3F3FFF2F2F2FFF6F6
          F6FFA5A5A5FF8A8A8AFFFFFFFFFF404040EF000000430000000603030354A5A5
          A5FFEEEEEEFF7C7C7CFF767676FF7D7D7DFF989898FFB2B2B2FF626262FFB8B8
          B8FFD3D3D3FF8A8A8AFFBABABAFF828282FF595959FFB5B5B5FF9A9A9AFFB0B0
          B0FFA5A5A5FF575757FF9C9C9CFFADADADFFACACACFF6E6E6EFFBDBDBDFF7777
          77FF939393FF949494FFFFFFFFFF404040EF000000430000000603030354A5A5
          A5FFECECECFF868686FF474747FF212121FF5C5C5CFF878787FF030303FF9191
          91FFBCBCBCFF414141FF919191FF303030FF000000FF868686FF585858FF7D7D
          7DFF686868FF000000FF5A5A5AFF777777FF737373FF0D0D0DFF8D8D8DFF1717
          17FF888888FF9A9A9AFFFFFFFFFF3F3F3FEF000000430000000603030354A5A5
          A5FFECECECFF838383FF515151FF373737FF6A6A6AFF8F8F8FFF0D0D0DFF9A9A
          9AFFC0C0C0FF525252FF9A9A9AFF444444FF000000FF8F8F8FFF676767FF8989
          89FF777777FF000000FF616161FF848484FF808080FF171717FF949494FF2121
          21FF8B8B8BFF989898FFFFFFFFFF3E3E3EEF000000430000000603030354A5A5
          A5FFECECECFF838383FF505050FF343434FF686868FF8D8D8DFF0D0D0DFF9999
          99FFC0C0C0FF505050FF989898FF424242FF000000FF8D8D8DFF656565FF8787
          87FF757575FF000000FF616161FF828282FF7E7E7EFF171717FF949494FF2121
          21FF8B8B8BFF989898FFFFFFFFFF3E3E3EEF000000430000000603030354A5A5
          A5FFECECECFF828282FF4F4F4FFF343434FF686868FF8D8D8DFF0D0D0DFF9797
          97FFBEBEBEFF505050FF989898FF424242FF000000FF8D8D8DFF656565FF8787
          87FF757575FF000000FF606060FF818181FF7E7E7EFF171717FF929292FF2121
          21FF898989FF999999FFFFFFFFFF3E3E3EEF000000430000000603030354A5A5
          A5FFECECECFF828282FF4F4F4FFF343434FF686868FF8D8D8DFF0D0D0DFF9898
          98FFBEBEBEFF505050FF989898FF424242FF000000FF8D8D8DFF656565FF8686
          86FF747474FF000000FF606060FF818181FF7D7D7DFF171717FF929292FF2121
          21FF898989FF999999FFFFFFFFFF3C3C3CEF000000430000000603030354A5A5
          A5FFEBEBEBFF818181FF4F4F4FFF343434FF676767FF8C8C8CFF0D0D0DFF9696
          96FFBCBCBCFF4F4F4FFF979797FF414141FF000000FF8C8C8CFF656565FF8686
          86FF747474FF000000FF5F5F5FFF818181FF7D7D7DFF171717FF929292FF2121
          21FF888888FF989898FFFFFFFFFF3D3D3DEF000000430000000603030354A6A6
          A6FFEBEBEBFF808080FF4F4F4FFF343434FF676767FF8B8B8BFF0D0D0DFF9696
          96FFBCBCBCFF4F4F4FFF979797FF414141FF000000FF8B8B8BFF646464FF8585
          85FF737373FF000000FF606060FF808080FF7C7C7CFF171717FF919191FF2121
          21FF888888FF999999FFFFFFFFFF3C3C3CEF000000430000000603030354A6A6
          A6FFEBEBEBFF808080FF4F4F4FFF333333FF666666FF8B8B8BFF0D0D0DFF9494
          94FFBBBBBBFF4F4F4FFF959595FF414141FF000000FF8B8B8BFF646464FF8484
          84FF737373FF000000FF5F5F5FFF808080FF7C7C7CFF171717FF909090FF2020
          20FF878787FF999999FFFFFFFFFF3C3C3CEF000000430000000603030354A6A6
          A6FFEBEBEBFF7F7F7FFF4E4E4EFF333333FF666666FF8A8A8AFF0D0D0DFF9595
          95FFBABABAFF4E4E4EFF959595FF414141FF000000FF8A8A8AFF636363FF8484
          84FF737373FF000000FF5E5E5EFF7F7F7FFF7B7B7BFF171717FF909090FF2121
          21FF878787FF989898FFFFFFFFFF3B3B3BEF000000430000000603030354A6A6
          A6FFEAEAEAFF7E7E7EFF4E4E4EFF333333FF666666FF898989FF0D0D0DFF9494
          94FFBABABAFF4E4E4EFF959595FF414141FF000000FF8A8A8AFF636363FF8484
          84FF727272FF000000FF5E5E5EFF7F7F7FFF7B7B7BFF171717FF909090FF2020
          20FF858585FF989898FFFFFFFFFF3B3B3BEF000000430000000603030354A6A6
          A6FFEAEAEAFF7D7D7DFF4E4E4EFF333333FF656565FF888888FF0D0D0DFF9393
          93FFB9B9B9FF4D4D4DFF939393FF404040FF000000FF898989FF636363FF8383
          83FF717171FF000000FF5D5D5DFF7F7F7FFF7B7B7BFF161616FF8F8F8FFF2020
          20FF858585FF989898FFFFFFFFFF3A3A3AEF000000430000000603030354A6A6
          A6FFEAEAEAFF7D7D7DFF4E4E4EFF333333FF656565FF888888FF0D0D0DFF9393
          93FFB8B8B8FF4D4D4DFF939393FF404040FF000000FF888888FF626262FF8282
          82FF717171FF000000FF5D5D5DFF7D7D7DFF7A7A7AFF161616FF8E8E8EFF2020
          20FF858585FF989898FFFFFFFFFF3A3A3AEF000000430000000603030354A6A6
          A6FFE9E9E9FF7C7C7CFF4D4D4DFF323232FF656565FF888888FF0C0C0CFF9191
          91FFB7B7B7FF4D4D4DFF939393FF404040FF000000FF878787FF626262FF8282
          82FF717171FF000000FF5D5D5DFF7D7D7DFF7A7A7AFF161616FF8D8D8DFF2020
          20FF838383FF989898FFFFFFFFFF3A3A3AEF000000430000000603030354A6A6
          A6FFE9E9E9FF7C7C7CFF4D4D4DFF323232FF646464FF878787FF0C0C0CFF9191
          91FFB6B6B6FF4C4C4CFF929292FF404040FF000000FF878787FF616161FF8181
          81FF707070FF000000FF5D5D5DFF7C7C7CFF797979FF161616FF8D8D8DFF2020
          20FF838383FF989898FFFFFFFFFF393939EF000000430000000603030354A6A6
          A6FFE9E9E9FF7A7A7AFF4C4C4CFF323232FF646464FF878787FF0C0C0CFF9090
          90FFB6B6B6FF4C4C4CFF919191FF3F3F3FFF000000FF868686FF616161FF8181
          81FF707070FF000000FF5C5C5CFF7C7C7CFF797979FF161616FF8C8C8CFF2020
          20FF838383FF979797FFFFFFFFFF3A3A3AEF000000430000000603030354A6A6
          A6FFE9E9E9FF7A7A7AFF4C4C4CFF333333FF646464FF868686FF0C0C0CFF9090
          90FFB5B5B5FF4D4D4DFF919191FF404040FF000000FF868686FF626262FF8181
          81FF707070FF000000FF5C5C5CFF7C7C7CFF797979FF161616FF8C8C8CFF2020
          20FF838383FF979797FFFFFFFFFF393939EF000000430000000603030354A7A7
          A7FFE7E7E7FF727272FF414141FF252525FF5A5A5AFF808080FF030303FF8989
          89FFB1B1B1FF414141FF8A8A8AFF313131FF000000FF808080FF575757FF7878
          78FF656565FF000000FF555555FF737373FF6F6F6FFF0D0D0DFF868686FF1616
          16FF7A7A7AFF8F8F8FFFFFFFFFFF393939EF000000430000000603030354A5A5
          A5FFE8E8E8FF818181FF595959FF424242FF6D6D6DFF8D8D8DFF2A2A2AFF9696
          96FFB6B6B6FF595959FF969696FF4C4C4CFF202020FF909090FF6B6B6BFF8888
          88FF787878FF1F1F1FFF6F6F6FFF848484FF818181FF353535FF969696FF3F3F
          3FFF8B8B8BFF9F9F9FFFFAFAFAFF393939EE000000420000000603030355A9A9
          A9FFFDFDFDFFD2D2D2FFD2D2D2FFCFCFCFFFD5D5D5FFD9D9D9FFCCCCCCFFDDDD
          DDFFE1E1E1FFD7D7D7FFE0E0E0FFD7D7D7FFCECECEFFE0E0E0FFDEDEDEFFE2E2
          E2FFE1E1E1FFCECECEFFDEDEDEFFE5E5E5FFE5E5E5FFD6D6D6FFE7E7E7FFD8D8
          D8FFE9E9E9FFEFEFEFFFF8F8F8FF3D3D3DF20000003900000002020202518484
          84FFEDEDEDFFE1E1E1FFE6E6E6FFE8E8E8FFE5E5E5FFE2E2E2FFECECECFFE3E3
          E3FFE0E0E0FFE9E9E9FFE4E4E4FFEBEBEBFFF0F0F0FFE6E6E6FFE9E9E9FFE7E7
          E7FFE9E9E9FFF1F1F1FFEAEAEAFFE9E9E9FFE9E9E9FFEFEFEFFFE8E8E8FFEEEE
          EEFFEAEAEAFFECECECFFDEDEDEFF373737EA00000026000000000000001A0A0A
          0A8A1818189F1717179D1616169D1616169D1616169D1616169D1616169D1616
          169D1616169D1616169D1616169D1616169D1616169D1616169D1616169D1616
          169D1616169D1616169D1616169D1616169D1616169D1616169D1616169D1616
          169D1616169D1616169D171717A40404045E0000000500000000000000010000
          001A000000270000002500000025000000250000002500000025000000250000
          0025000000250000002500000025000000250000002500000025000000250000
          0025000000250000002500000025000000250000002500000025000000250000
          00250000002500000025000000280000000B0000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000100000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000010000000B0000001B000000210000001A0000000E0000
          0004000000010000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000A000000360000006D0000007F0000006C0000004A0000
          002A000000170000000A00000002000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000012415003F975800CFAF6400E96D3E00C0221300A00201009A0000
          0085000000620000003E00000023000000120000000700000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000004A56100C5F4B872FFFFD3A6FFF3B36EFFDC9029FFAD6300EA5530
          00B2150C009E000000960000007B00000057000000350000001D0000000E0000
          0004000000010000000000000000000000000000000000000000000000000000
          0000000000000000000600000012000000070000000100000000000000000000
          00000D080018D48305FBFFD5A9FFFFCC99FFFFCD99FFFFCE9CFFFFC78EFFEAA3
          4FFFD07D10FE954F00D63A2000A70904009D0000008F000000700000004A0000
          002B000000170000000800000001000000000000000000000000000000000000
          0000000000000000001700000046000000240000000500000000000000000000
          00003F260054E2992FFFFFD0A2FFFFCA95FFFFC993FFFFC78FFFFFC88EFFFFC8
          8EFFFFCA90FFF9B772FFDE9037FFBE6700F9713A00C2241300A10201009B0000
          008500000061000000330000000D000000010000000000000000000000000000
          000000000000903D00BF0703006D0000004D0000001100000000000000000000
          00017243008EECAC5AFFFFCD9BFFFFC993FFFFC891FFFFC78EFFFFC58BFFFFC3
          87FFFFC385FFFFC383FFFFC383FFFFC381FFEEA455FFD27D20FFA25300EB5028
          00B20C06009D0000007B0000002B000000050000000000000000000000000000
          000000000001A64700E837160093000000710000001F00000001000000000000
          0004A65E00C8F9C284FFFFCB96FFFFC891FFFFC78FFFFFC68CFFFFC489FFFFC3
          86FFFFC183FFFFBF7FFFFFBD7BFFFFBC78FFFFBC77FFFFBD76FFFFB76AFFE28E
          39FFA65200EE0A0500930000003D000000090000000000000000000000000000
          000000000001A14500E07C3300CC0000008B0000003300000006000000000B06
          0016C97700F8FFCF9DFFFFC790FFFFC78EFFFFC68CFFFFC58AFFFFC388FFFFC2
          84FFFFC081FFFFC180FFFFC07DFFFFBE79FFFFBB75FFFFB971FFFFB86DFFFFBD
          70FFD37C22FF2B15008B0000002C000000050000000000000000000000000000
          0000000000019D4200DFAA4701FC080300950000004D0000000F000000003820
          0050DB8E29FFFFCF9DFFFFC68DFFFFC68CFFFFC58AFFFFC488FFFFC286FFFFC1
          83FFFFC280FFFCB871FFF0A657FFF1A75AFFF3AA5CFFF4AA5CFFF9AB5DFFEB98
          45FFAB5600EF110700460000000E000000010000000000000000000000000000
          0000000000019E4200E1C6610DFF230E009E0000006300000017000000016B3B
          008AE7A554FFFFCC97FFFFC58AFFFFC58AFFFFC488FFFFC386FFFFC283FFFFC0
          81FFFFC181FFF0A759FFB15A00FA673600BF7F4000BD8D4600BF954900C57B3C
          00A62311003C0000000900000001000000000000000000000000000000000000
          000000000003A54300EFE27A1AFF421A00B1000000750000001D000000049D55
          00C5F6C085FFFFC58BFFFFC488FFFFC387FFFFC386FFFFC285FFFFC081FFFFBF
          7FFFFFBE7DFFFFC383FFCA7513FE221200A20000007E0000002D000000070000
          0001000000010000000000000000000000000000000000000000000000000000
          00000602000EA94701FDF78D21FF622500C9000000810000002209040015C06C
          00F6FFD2A4FFFFC386FFFFC287FFFFC488FFFFC487FFFFCC95FFFFC181FFFFBE
          7CFFFFBD79FFFFBE79FFF5AC60FF8F4700DD0201009F0000005E0000001A0000
          0002000000000000000000000000000000000000000000000000000000000000
          00001B0B0035B55205FFFF9624FF7A2D00DF00000087000000242E19004CD583
          20FFFFD6A8FFFFC284FFFFC285FFFFC385FFC87005FFFEBE7BFFFFD4A7FFFFBC
          77FFFFBB77FFFFBA75FFFFBE79FFD58126FF422100AD00000091000000460000
          0011000000010000000000000000000000000000000000000000000000000000
          00013E19006AC9630DFFFF9A23FF883200EA00000086000000245B300086E39D
          4DFFFFD3A4FFFFC180FFFFC78CFFD78529FF934D00D9DB882DFFFFD19FFFFFCA
          94FFFFBA71FFFFB971FFFFB870FFFFB96EFFB85E02FA170B00A2000000830000
          003C0000000F0000000200000000000000000000000000000000000000010000
          000B6C2C00B2E37B16FFFF9720FF843000E90000007F000000218A4600C0F3C0
          88FFFFCD9AFFFFC382FFEDA85DFF874600CF09050047A65600E1F9B166FFFFDA
          B4FFFFC07FFFFFB86CFFFFB66BFFFFB76CFFF3A554FF984800E70C0500A30000
          00800000004200000018000000070000000100000001000000030000000D1509
          0046A14300F8FF9822FFFD8D1CFF752A00DC000000700000001BA15300DEFFD0
          9DFFFFD4A6FFFFBF7EFFB76100F6190D00650000001747250055C96F0DFEFFC7
          88FFFFDAB4FFFFB86FFFFFB569FFFFB365FFFFB668FFE99641FF8E4200E20F07
          00A30000008E0000005D0000003500000023000000200000002A0402004A6A2A
          00C7DE7614FFFF9620FFEC7D15FF572100C20000005800000013763C00A2DA89
          31FFFFD2A1FFD18128FF4D29008D000000200000000400000000834100A8DC89
          30FFFFD19BFFFFD5A9FFFFB364FFFFB262FFFFB15FFFFFB361FFEE9942FFA64D
          00F43A1900AB050200A000000091000000810000007E190A008C6F2C00CECA65
          0EFFFF9722FFFF931CFFD0650CFF361400A30000003B000000090B05000F773D
          0099A55200D36F390093010000160000000500000000000000000D0600109D4C
          00DCF09D4AFFFFD4A6FFFFCF9FFFFFB05CFFFFAE5CFFFFAE58FFFFAF57FFFEAA
          51FFD2751FFFA74C00F87D3500D5743000CD983E00E9B75606FEE57D19FFFF97
          23FFFF911CFFFF971CFFAB4702FE1307007A0000001F00000002000000000000
          0000000000010000000100000000000000000000000000000000000000002512
          002DAC5300F0F6A754FFFFD5A8FFFFCC98FFFFAC57FFFFAB54FFFFA951FFFFAA
          50FFFFAB4FFFFFAB4BFFFA9B3AFFF69430FFFF9D31FFFF9B2CFFFF9522FFFF90
          1DFFFF921BFFE67811FF6C2700C9000000420000000C00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000034190040AC5100F3F4A24DFFFFD2A1FFFFCF9AFFFFAE59FFFFA74AFFFFA6
          4AFFFFA448FFFFA342FFFF9F3BFFFF9C34FFFF972DFFFF9424FFFF911EFFFF91
          1AFFFF9219FFA64001FC1D0A006F0000001A0000000200000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000003017003DA34900EBE68D36FFFFCB8CFFFFD4A4FFFFBC76FFFFA7
          49FFFFA13EFFFF9F3AFFFF9B34FFFF992DFFFF9627FFFF9221FFFF911BFFFF94
          1AFFB55006FE491B009700000021000000050000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000001C0C0023883E00CAC86811FFFDAD5AFFFFCA8DFFFFD0
          9CFFFFC280FFFFB365FFFFAC54FFFFA849FFFFA644FFFF9823FFF78716FFAF4A
          03FE5620009B0000001E00000005000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000003010005522400739B4100EAC96711FFEB8F
          36FFFFAE57FFFFB65FFFFFB156FFFE9E3CFFE37B19FFBD5506FF873000DF3614
          0065000000100000000300000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000803000B3C1A005F6B2B
          00AC8A3400DD9D3E00F4993A00F3823000D85F2300A43012005B020100110000
          0004000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000010000000100000001000000010000000100000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000AAAAAAFFB3B3
          B3FFBABABAFFC1C1C1FFBFBFBFFFBFBFBFFFC1C1C1FFC2C2C2FFC3C3C3FFC5C5
          C5FFC5C5C5FFC6C6C6FFC8C8C8FFC9C9C9FFCACACAFFC9C9C9FFCACACAFFC9C9
          C9FFCACACAFFC8C8C8FFC6C6C6FFC6C6C6FFC6C6C6FFC3C3C3FFC4C4C4FFC3C3
          C3FFC0C0C0FFC0C0C0FFC1C1C1FFBDBDBDFFB5B5B5FFACACACFFA2A2A2FFB4B4
          B4FFBFBFBFFFBABABAFFC0C0C0FFC4C4C4FFC2C2C2FFC3C3C3FFC6C6C6FFC9C9
          C9FFC5C5C5FFC2C2C2FFCACACAFFCDCDCDFFCCCCCCFFCBCBCBFFCBCBCBFFCBCB
          CBFFCDCDCDFFCCCCCCFFC3C3C3FFC5C5C5FFCACACAFFC5C5C5FFC4C4C4FFC3C3
          C3FFC4C4C4FFC0C0C0FFBBBBBBFFBEBEBEFFB9B9B9FFA3A3A3FF9F9F9FFFAFAF
          AFFFB2B2B2FFBABABAFF959595FF6D6D6DFF595959FF575757FF565656FF6060
          60FFA6A6A6FFCBCBCBFF949494FF5A5A5BFF575757FF5A5A5AFF5A5B5AFF595A
          59FF585858FF868686FFC8C8C8FFB1B1B1FF696969FF575757FF585858FF5858
          58FF6B6B6BFF8F8F8FFFB9B9B9FFB7B7B7FFB1B1B1FFA5A5A5FFA0A0A0FFA0A0
          A0FFABABABFF676767FF232323FF252525FF282828FF282828FF252525FF1717
          17FF5D5D5DFFC0C0C0FF2A2A2AFF202021FF292A29FF2B2C2AFF2C2D2AFF2A2B
          29FF232322FF1D1D1DFFABABABFF707070FF141414FF272727FF2B2B2BFF2C2C
          2CFF272727FF222222FF555555FFAAAAAAFFA1A1A1FFA4A4A4FF9B9B9BFF9B9B
          9BFF858585FF232323FF2B2B2BFF333333FF383838FF373737FF313131FF2323
          23FF5D5D5DFFB4B4B4FF282828FF2D2C2DFF383838FF434442FF484947FF3C3D
          3BFF323231FF1F1F1FFF9F9F9FFF6C6C6CFF212121FF323232FF3A3A3AFF4A4A
          4AFF3E3E3EFF313131FF212121FF7A7A7AFF9C9C9CFF9B9B9BFF9A9A9AFF9595
          95FF676767FF212121FF303030FF383838FF909090FF505050FF323232FF2424
          24FF5A5A5AFFADADADFF292929FF2F2F2FFF363736FF878886FF9C9D9BFF4A4B
          49FF323231FF222222FF989898FF686868FF222222FF2F2F2FFF666666FF9797
          97FF898989FF383838FF272727FF5A5A5AFF979797FF939393FF989898FF8D8D
          8DFF5C5C5CFF232323FF323232FF373737FFA6A6A6FF575757FF313131FF2323
          23FF545454FFA2A2A2FF292929FF2E2F2FFF3C3B3BFF666464FFAEADACFF5150
          50FF333332FF212121FF8F8F8FFF636363FF222222FF343434FF454545FF8686
          86FF9F9F9FFF393939FF292929FF4A4A4AFF909090FF909090FF979797FF8B8B
          8BFF595959FF212121FF2E2E2EFF4C4C4CFFB8B8B8FF4F4F4FFF2E2E2EFF2323
          23FF4F4F4FFF959595FF272727FF2C2C2CFF373737FF908E8EFFBEBCBCFF625F
          5FFF2D2C2CFF202020FF838383FF5B5B5BFF212121FF2D2D2DFF616161FFADAD
          ADFF919191FF333333FF272727FF474747FF8D8D8DFF909090FF979797FF8D8D
          8DFF575757FF1E1E1EFF2B2B2BFF3B3B3BFF4D4D4DFF343434FF2B2B2BFF1F1F
          1FFF4B4B4BFF909090FF222222FF282828FF2F2F2FFF434141FF525050FF3634
          34FF2D2C2CFF1C1C1CFF7E7E7EFF565656FF1E1E1EFF2B2B2BFF383838FF5656
          56FF424242FF2F2F2FFF222222FF464646FF8E8E8EFF919191FF9A9A9AFF8F8F
          8FFF616161FF121212FF1D1D1DFF1F1F1FFF1C1C1CFF202020FF1C1C1CFF1111
          11FF555555FFA5A5A5FF2F2F2FFF151515FF1E1E1EFF201E1EFF201E1EFF211F
          1FFF191818FF1E1E1EFF999999FF656565FF0F0F0FFF1B1B1BFF1F1F1FFF1E1E
          1EFF1F1F1FFF1E1E1EFF131313FF545454FF939393FF939393FF9E9E9EFF9090
          90FF8F8F8FFF636363FF5A5A5AFF5F5F5FFF626262FF636363FF626262FF6A6A
          6AFFA0A0A0FFB5B5B5FF989898FF666666FF676767FF686868FF686868FF6767
          67FF656565FF8C8B8BFFB6B6B6FFA9A9A9FF717171FF616161FF636363FF6262
          62FF606060FF5D5D5DFF5F5F5FFF8C8C8CFF929292FF969696FFA1A1A1FF9292
          92FF9D9D9DFF959595FF8B8B8BFF8F8F8FFF909090FF939393FF939393FF9D9D
          9DFFB7B7B7FFB6B6B6FFB7B7B7FF9B9B9BFF989898FF989898FF999999FF9999
          99FF989898FFB3B3B3FFB9B9B9FFB9B9B9FFA5A5A5FF939393FF929292FF9191
          91FF8E8E8EFF8B8B8BFF909090FF9E9E9EFF959595FF9B9B9BFFA2A2A2FF9898
          98FF7A7A7AFF292929FF272828FF2B2B2BFF2C2C2CFF2C2C2CFF282828FF2424
          24FF777777FFBEBEBEFF545454FF232323FF2B2B2BFF2C2C2CFF2C2C2DFF292A
          2AFF242424FF424242FFB6B6B6FF888888FF262727FF272828FF2B2B2BFF2E2E
          2EFF2D2D2DFF2B2B2BFF232323FF717171FF9B9B9BFF9D9D9DFFA5A5A5FF9E9E
          9EFF626262FF212020FF302F2FFF363535FF323131FF333333FF313131FF2121
          21FF575757FFACACACFF282828FF2A2A2BFF333333FF302F2FFF31302FFF3635
          34FF2E2D2DFF1D1D1DFF969696FF646464FF1F1E1EFF313030FF363535FF3433
          33FF343333FF343333FF242323FF504F4FFF9F9F9FFF9D9D9DFFA5A5A5FF9F9F
          9FFF626262FF262525FF3A3838FF403E3EFF6F6C6CFF5D5B5BFF313131FF2424
          24FF585858FFAAAAAAFF2A2A2AFF2E2E2EFF3E3E3DFF8F8D8CFF898786FF413E
          3DFF333231FF202121FF949494FF676767FF252323FF363434FF535151FF9E9C
          9CFF7B7979FF393737FF2A2828FF4F4E4EFF9F9F9FFF9F9F9FFFA5A5A5FFA0A0
          A0FF636363FF252424FF383636FF969494FFD5D3D3FF979696FF313232FF2424
          24FF595959FFACACACFF2A2A2AFF2F2F2FFF444344FF7B7977FFC1BFBEFF5C5A
          59FF302F2FFF212121FF969696FF686868FF252323FF302E2EFF8E8C8CFFB5B3
          B3FFA09E9EFF403E3EFF2B2929FF504F4FFFA1A1A1FFA0A0A0FFA6A6A6FFA1A1
          A1FF626262FF242323FF333131FF787676FFD7D5D5FF777676FF313232FF2323
          23FF5A5A5AFFB1B1B1FF282828FF2D2D2DFF393938FFA09E9DFF9F9C9BFF4946
          45FF313030FF1E1E1FFF9B9B9BFF6A6969FF211F1FFF343232FF595757FFC7C5
          C5FF7A7878FF373535FF282626FF4E4D4DFFA2A2A2FFA1A1A1FFA7A7A7FFA4A4
          A4FF626262FF1F1F1FFF313030FF3D3D3DFF8C8B8BFF525252FF2E2E2EFF2020
          20FF5A5A5AFFB3B3B3FF262626FF2B2B2BFF323231FF706F6FFF898989FF3F3F
          3EFF2B2B2AFF1D1D1DFF9D9D9DFF6A6A6AFF1D1D1DFF2F2E2EFF323232FF6767
          67FF606060FF2E2E2EFF232323FF4D4D4DFFA4A4A4FFA1A1A1FFADADADFFB3B3
          B3FF686868FF151515FF262626FF2A2A2AFF272828FF2A2A2AFF272727FF1616
          16FF585858FFBDBDBDFF202020FF212121FF2B2B2BFF292929FF262727FF2A2A
          2AFF242424FF141414FFA5A5A5FF6A6A6AFF121212FF242424FF2A2A2AFF2727
          27FF272828FF292929FF181818FF525252FFB3B3B3FFA9A9A9FFBABABAFFB4B4
          B4FF999999FF323232FF272727FF2B2B2BFF2D2D2DFF2C2C2CFF282828FF2B2B
          2BFF959595FFD8D8D8FF757575FF262626FF2B2B2BFF2D2D2DFF2C2C2CFF2B2B
          2BFF262626FF5D5D5DFFD0D0D0FFA8A8A8FF353535FF282828FF2B2B2BFF2B2B
          2BFF2C2C2CFF292929FF2A2A2AFF8C8C8CFFB9B9B9FFB8B8B8FFBEBEBEFFB2B2
          B2FFC0C0C0FFC2C2C2FFB9B9B9FFBDBDBDFFBFBFBFFFC0C0C0FFC0C0C0FFCDCD
          CDFFD7D7D7FFCDCDCDFFDCDCDCFFCACACAFFC7C7C7FFC7C7C7FFC8C8C8FFC7C7
          C7FFC9C9C9FFDCDCDCFFD1D1D1FFD7D7D7FFD1D1D1FFC1C1C1FFC0C0C0FFC0C0
          C0FFBEBEBEFFBBBBBBFFBFBFBFFFC3C3C3FFB4B4B4FFB9B9B9FFC4C4C4FFC1C1
          C1FFAAAAAAFF656565FF5E5E5EFF626262FF636363FF636363FF626262FF6464
          64FFAAAAAAFFDDDDDDFF939393FF606060FF656565FF666666FF666666FF6565
          65FF616161FF848484FFD9D9D9FFBABABAFF6A6A6AFF606060FF636363FF6464
          64FF636363FF606060FF5F5F5FFFA7A7A7FFC2C2C2FFC0C0C0FFCACACAFFCFCF
          CFFF7C7C7CFF171717FF252525FF272727FF272727FF282828FF242424FF1515
          15FF656565FFD0D0D0FF2D2D2DFF1F1F1FFF262626FF292929FF292929FF2929
          29FF212121FF1C1C1CFFB9B9B9FF7A7A7AFF141414FF252525FF272727FF2626
          26FF282828FF262626FF171717FF656565FFD0D0D0FFC7C7C7FFD0D0D0FFD4D4
          D4FF777777FF202020FF303131FF3D3D3DFF3B3B3BFF353535FF2F2F2FFF2121
          21FF626262FFC4C4C4FF272727FF2E2E2EFF373737FF454545FF4E4E4EFF3D3D
          3DFF323232FF1F1F1FFFA9A9A9FF747474FF1F1F1FFF313131FF393939FF4646
          46FF383838FF333333FF242424FF595959FFD3D3D3FFCDCDCDFFD6D6D6FFDBDB
          DBFF787979FF212121FF313030FF636262FFA3A2A2FF383737FF343535FF2222
          22FF636363FFC5C5C5FF292929FF2F2F2FFF414140FF9F9E9EFFB8B7B7FF6E6D
          6DFF313030FF212121FFABABABFF757575FF212121FF353535FF3A3A3AFF9F9F
          9FFF828282FF343434FF262626FF5E5E5EFFD8D8D8FFD3D3D3FFD9D9D9FFE0E0
          E0FF7A7A7AFF1F1E1EFF373535FF3C3A3AFFACAAAAFF6F6E6EFF323232FF2323
          23FF626262FFC3C3C3FF282828FF2F2F2FFF3E3E3EFFA4A2A1FFCECCCBFF6866
          65FF333231FF1F2020FFA9A9A9FF737373FF202020FF313131FF747474FFC0C0
          C0FFABABABFF3A3A3AFF252525FF5E5E5EFFDBDBDBFFD8D8D8FFDDDDDDFFE2E2
          E2FF8C8C8CFF1B1A1AFF312F2FFF5D5B5BFF9C9A9AFF999898FF303030FF2020
          20FF606060FFC0C0C0FF262626FF2C2D2DFF393938FF888685FFB2B0AFFF5956
          55FF31302FFF1E1E1EFFA6A6A6FF707070FF1F1F1FFF2E2E2EFF717171FFA8A8
          A8FF8C8C8CFF373737FF202020FF777777FFE3E3E3FFDBDBDBFFD9D9D9FFE2E2
          E2FFBDBDBDFF232222FF252323FF3C3A3AFF444242FF3B3A3AFF2F2F2FFF1D1D
          1DFF5C5C5CFFBBBBBBFF212121FF272727FF323131FF3B3837FF403E3DFF3533
          32FF2C2B2AFF191818FFA1A1A1FF6A6A6AFF191919FF2D2D2DFF323232FF4242
          42FF393939FF2A2A2AFF1B1B1BFFABABABFFE4E4E4FFDBDBDBFFCECECEFFE3E3
          E3FFE6E6E6FF989898FF252424FF1E1D1DFF1E1E1EFF202020FF1C1C1CFF0F0F
          0FFF636363FFCBCBCBFF2D2D2DFF151515FF1E1E1EFF201F1FFF1E1E1DFF1F1F
          1EFF181818FF1C1C1CFFB6B6B6FF797979FF0E0E0EFF1A1A1AFF1E1E1EFF1D1D
          1DFF1C1C1CFF202020FF7F7F7FFFE3E3E3FFE2E2E2FFD5D5D5FFBEBEBEFFD8D8
          D8FFE2E2E2FFE5E5E5FFBEBFBFFF8D8D8DFF808080FF7E7E7EFF7A7A7AFF7F7F
          7FFFB6B6B6FFD2D2D2FFA9A9A9FF7A7A7AFF7B7C7CFF7C7C7CFF7C7C7CFF7B7B
          7BFF797979FF9C9C9CFFD1D1D1FFC1C1C1FF858585FF7A7A7AFF7C7C7CFF7E7E
          7EFF8A8A8AFFB1B1B1FFE3E3E3FFE3E3E3FFDEDEDEFFC2C2C2FFBBBBBBFFBBBB
          BBFFD3D3D3FFDDDDDDFFDDDDDDFFDCDCDCFFDBDBDBFFD8D8D8FFD6D6D6FFD6D6
          D6FFCFCFCFFFCACACAFFD1D1D1FFD7D7D7FFD6D6D6FFD6D6D6FFD6D6D6FFD6D6
          D6FFD7D7D7FFD3D3D3FFCBCBCBFFCDCDCDFFD5D5D5FFD7D7D7FFD8D8D8FFD9D9
          D9FFDBDBDBFFDCDCDCFFDEDEDEFFD8D8D8FFBEBEBEFFBABABAFFBABABAFFB0B0
          B0FFA7A7A7FFB7B7B7FFC7C7C7FFD0D0D0FFD1D1D1FFCFCFCFFFCDCDCDFFCECE
          CEFFCECECEFFCECECEFFCECECEFFCECECEFFCECECEFFCECECEFFCECECEFFCECE
          CEFFCECECEFFCECECEFFCECECEFFCECECEFFCECECEFFCECECEFFCFCFCFFFD1D1
          D1FFD1D1D1FFCCCCCCFFBCBCBCFFA9A9A9FFADADADFFB9B9B9FF}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000070000
          0017000000190000000C00000007000000020000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000010000001D0000
          005E0000006800000046000000360000001F0000000700000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000010101011151514EC54646
          46C5070707A00B0B0B9701010190000000680000002200000003000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000E00061C4E7E7C7FFEB3B3
          AFFF7E7E7EFE838383FF454545CC010101920000003D00000009000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000010000000F0005184B0332CDDE3170ECFFADA8
          A4FFE5E4E3FF929292FF858585FF10101099000000480000000D000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000010000000F00051B4E0634D1E12B74FFFF4198FFFF66B4
          E9FFEBE3DFFFEAE9E8FF7F7F7FFE0D0D0D9C0000005D00000014000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000010000000F00061D510636D2E22C76FFFF4399FFFF5EC0FFFF64D0
          FFFF7EC6EFFFCBC3BDFFB3B3B1FE262626A50000006600000019000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00020000001000061F540837D5E42E77FFFF4499FFFF5FC1FFFF68CFFFFF64C9
          FFFF4BAAFFFF5589D3FFA19B90FF636363DE000000320000000B000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000070000
          001C00072058093BD9E62F78FFFF469CFFFF60C3FFFF68CFFFFF63C8FFFF4FA9
          FFFF3B8CFFFF1256F9FB1C265396131211420000000900000001000000000000
          0000000000000000000000000000000000000000000000000000000000010000
          0001000000010000000100000001000000010000000000000005000000240005
          1D6E0936CCE92E7AFFFF479DFFFF60C4FFFF68CFFFFF63C7FFFF4EA8FFFF3A8B
          FFFF1957F9FB000F4A7D0000001A000000040000000000000000000000000000
          000000000000000000000000000000000000000000030000000C000000170000
          001F00000022000000220000001E000000160000000B0A0A0A224C4A45B01A37
          9AEB266AE1FF479DFDFF61C6FFFF68CFFFFF62C6FFFF4EA7FFFF3A8AFFFF1854
          F7FA000F46790000001800000003000000000000000000000000000000000000
          00000000000000000000000000020000000C0000002300000042000000610000
          00750000007E0000007D000000730000005D0000003F2222226B9B9B99FF9491
          8BFF407DC1FF5ABBF4FF69D1FFFF62C6FFFF4DA6FFFF3989FFFF1553F4F8000D
          4175000000170000000300000000000000000000000000000000000000000000
          000000000000000000040000001700000042131313822B2B2CAF3E3F40D24546
          48E4424445E3363636CF212121AF0B0B0B950000008E050505816F6F6FF0D1CF
          CFFFADABA7FF57A8CFFF59BDF5FF4BA6FFFF3987FFFF1450F3F7000C3D710000
          0016000000030000000000000000000000000000000000000000000000000000
          0000000000040000001C1313136C464748D364676AF5858687F0A09586E9A99C
          83E2AB9B85E1A2998CE586888CEB515457F12E2F2FCD3E3E3EDA959595FFB8B8
          B8FFFFFFFFFFA5A7A7FF3E87D0FF3079E9FF1248E8F6000C396F000000150000
          0003000000000000000000000000000000000000000000000000000000000000
          0001000000172A2A2A8965676BF8918E87F1BEA479EAC29A5EE2C39E64E3C3A1
          68E4C39F67E5C39B5EE4C29955E4D0B58BEBA2A1A1F2434447FD8C8C8CFFF2F2
          F2FFCDCDCDFFDCDAD9FF85898CFF0B38BDF4000830780000001C000000030000
          0000000000000000000000000000000000000000000000000000000000000000
          000B2E2E2E80717478FCA89C85F0C19D63E1BF9E66E1BFA06CE2BE9F6BE2BFA1
          6FE2C5A877E5CBB187E8CCB188E8C5A36DE7C4995AE5CEC3B5F6484B4EFF9494
          95FFA1A1A1FF8F8F8FFEA8A7A3FF373738A00000002C00000009000000000000
          0000000000000000000000000000000000000000000000000000000000021818
          1847707275F9A69982F0C09F65DFBA9D68DFB99C68DEB99C68DFB99C68DFB99A
          65DFB99964DFBA9861E0C1A372E4CEB58FE9CBB083E8C19654E4CDC3B5F64446
          49FE4F4F4FF01414148A4B4B4BA3121212380000000900000001000000000000
          0000000000000000000000000000000000000000000000000000000000095D5E
          5FC5908B86F7C1A26BDEB99D6CDDB89E6DDDB89E6DDDB89E6DDDB89D6CDDB99E
          6BDEB99E6BDEB99C66DFB99964DFBD9C66E2CCB48FE8CCB183E8C59A5BE5A2A3
          A3FA262626BD0000008B00000034000000070000000000000000000000000000
          00000000000000000000000000000000000000000000000000001A1A1A407D7F
          83FEB59F76E5B9A070DDB8A072DDB8A273DDB8A174DCB8A274DCB8A074DCB89F
          71DCB89F6EDDB99E6CDEB99C6BDEB99A64DFBE9D68E2CFB993E9C6A470E6D2B9
          94ED535559F9040404960000004F0000000F0000000000000000000000000000
          00000000000000000000000000000000000000000000000000004242428B8886
          83F9C0A674DDB8A275DCB9A57BDDB7A378DBB7A378DBB7A378DBB9A479DCB8A2
          76DCB8A174DCB89F71DCB89E6DDDB99D6ADEB99A64DFC5A87BE5CDB38DE9C49B
          5DE48D8F95FD151515A000000065000000170000000000000000000000000000
          0000000000000000000000000000000000000000000000000000606162BB988F
          7EF0BEA67ADCBAA77EDCBAA881DCB8A67EDAB8A780DAB8A780DAB8A67DDAB9A6
          7CDBB9A479DBB8A275DCB8A073DCB89E6DDDB99D6ADEBC9D67E0CEB693E8C49E
          63E4A9A49BF8252525B40000006E0000001B0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000747677D4A096
          7EECBCA97DDBBDAE8BDDBBAD89DCC0B394DEC0B596DEBFB392DDBBAD8ADCB9A8
          81DAB8A67DDAB9A47ADBB8A275DCB8A071DCB89D6CDDB99C65DFCAB28BE7C5A3
          6EE4B6AA97F3313132C30000006E0000001B0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000787979D49F94
          7DEBBBA880DABFB392DDCABFA7E2C5BA9DDFBFB699DDBDB394DCBBB08FDBB9AC
          86D9B9A882DAB8A67EDAB9A47BDBB8A274DCB89F6FDDB99D69DEC5AD82E4C4A4
          6FE4B4A795F3323233C300000065000000170000000000000000000000000000
          0000000000000000000000000000000000000000000000000000707071BC958E
          7EEEBCAD82D9C7BEA3E1CEC6B3E4C5BCA2DEC4BEA4DFC1B89EDDBAB394DABAAE
          8FDABAAE8CDBB8A881DAB9A67DDBB9A377DCB8A073DCB89D6CDDC4AB7FE3C3A2
          6CE2A49E91F72B2C2CB400000051000000100000000000000000000000000000
          00000000000000000000000000000000000000000000000000005656578A8886
          83F8C0B38AD8CBC4ACE2D3CFBDE7D3CFBDE7E1E0D7EFDDDAD0ECC1BAA0DDBEB4
          97DBBDB394DCBAAB87DAB8A77FDAB9A479DBB8A174DCB89E6EDDC4AB7FE2C4A0
          68E286888CFD1B1B1B9A00000035000000070000000000000000000000000000
          0000000000000000000000000000000000000000000000000000272727399092
          96FEB2A788DEC9C4AAE1D4D1C0E7E2E1D9EFE6E6DFF1E2E2DBEFCAC6B1E2C0B8
          9EDCC1B89BDDBAAD8ADAB8A780DAB9A47BDBB8A374DCB89F6FDDC2A879E2BDA7
          82EA64666AFB080808700000001C000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000009090
          91C788847BF3C9C6A7DDCCC9B3E2DBDACFEBE7E6E1F1DBDBD0EBC4C0AADEC1BD
          A2DDC2B99FDEB7AA86D9B7A680D9B9A47CDBB8A275DCBAA273DEC2A36EE0918F
          8DF939393ABA0000003900000009000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000002F2F
          2F3CA1A1A4FB9C9683E8CDCDB7E0CBCAB7E2D1D0C2E5D2D1C2E6CECAB7E2CAC5
          AFE2C1B799DDBAAD8BDAB9A882DAB9A47BDBB9A375DCBFA370DDA69C8AF16163
          65F40C0C0C5E0000001400000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000616161799A9B9EFE9C9886E8CACAB1DECCC9B6E1CDCAB6E2CAC6B2E2C1B9
          9FDDBAAF8EDAB8A985D9B9A87FDABAA57BDBC0A774DDA49984EF6F7175FC2323
          237D0000001A0000000300000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000006666667EA1A2A3FC86857BF1B3AA8DDCBDB594D7BAB18ED7BAAF
          8CD8BBAD86D9BCAA82D9BFAB7FDBB3A27EE48B8884F4727376F82C2C2C7D0000
          0017000000040000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000003B3B3B4A979798DB8D8E90FC858481F3938E80E99D94
          80E69F9580E7928C7EE983817EF47A7B7FFB606060D21B1B1B4E0000000C0000
          0002000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000030303053838385869696AAA878789DD8C8D
          8EF2868788EF757576DA525252A5232323570101010F00000003000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000001000003171717602A2A2AC4383737F43533
          33EC212020950202020A00000000009300FF009300FF009300FF009300FF0093
          00FF000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000017151543393939CF403D3DFF776161FF9B7878FF9E7A
          7AFF645454FF292929AD00000000009300FF35CE5FFF31CA59FF1DB634FF0093
          00FF000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00001916163D423939BE625252FE464040FF8B6D6DFFA47E7EFFAA8282FFB288
          88FFBB8D8DFF504747FE13121244009300FF54ED92FF4FE88AFF2EC750FF0093
          00FF000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000001B1717394E41
          41BA6C5959FE9D7E7EFFAD8B8BFF5D4F4FFFB68A8AFFAD8484FFAA9F9FFF908D
          8DFFB28787FFB49999FF605E5EBC009300FF53EC8EFF4CE584FF2BC54BFF0093
          00FF000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000201919395B4949B8796363FEA281
          81FFC3A1A1FFC9A9A9FFA69090FF6D5959FF816262FF473A3AFF978585FF0093
          00FF009300FF009300FF009300FF009300FF53EC8DFF4DE684FF29C247FF0093
          00FF009300FF009300FF009300FF009300FF0000000000000000000000000000
          00000000000000000000231A1A37685151B9866C6CFEA98A8AFFC6A5A5FFC9AC
          ACFFCCB2B2FFD4BBBBFFCBB7B7FF4D4040FF765C5CFF9C7979FFB19898FF0093
          00FF42DB6DFF39D25FFF37D05AFF3CD564FF50E986FF4CE581FF3FD86AFF27C0
          44FF2AC34AFF2CC54FFF1DB634FF009300FF0000000000000000000000000000
          0000181212246D5656B3937676FEAF8F8FFFCAAAAAFFCDB2B2FFD0B8B8FFD4BE
          BEFFD9C6C6FFDECFCFFFEDE0E0FF847575FF695555FF7F6767FFAEA2A2FF0093
          00FF65FEA4FF58F190FF56EF8EFF52EB88FF4FE882FF4CE580FF4CE581FF4DE6
          85FF4CE584FF4EE78AFF33CC5AFF009300FF0000000000000000000000001A13
          1326906F6FEBB49494FFCCAFAFFFCFB6B6FFD2BDBDFFD7C3C3FFDCCBCBFFE2D3
          D3FFE7DBDBFFEDE2E2FFF7F0F0FFFFFFFFFF8E8686FF4B4141FFB1ADADFF0093
          00FF6DFFAFFF61FA9CFF5EF798FF57F08FFF52EB86FF4FE882FF50E986FF53EC
          8CFF53EC8DFF53EC91FF36CF5FFF009300FF0000000000000000000000006D54
          54ADBD9F9FFFD3BCBCFFD5C2C2FFDBC8C8FFE0D0D0FFE5D8D8FFEAE1E1FFF0E8
          E8FFF8F5F5FFFFFFFFFFE9E6E6FF928787FF5D4C4CFF9B8080FFD9B2B2FF0093
          00FF009300FF009300FF009300FF009300FF58F190FF52EB88FF39D25FFF0093
          00FF009300FF009300FF009300FF009300FF0000000000000000000000009C75
          75EDDBC8C8FFDECDCDFFE3D5D5FFE8DDDDFFEDE6E6FFF4EDEDFFFDFAFAFFFFFF
          FFFFE0DADAFF907D7DFF6E5555FFAA8A8AFFDFB7B7FFDEB8B8FFE4C8C8FFE3CA
          CAFFE5CBCBFFE9CFCFFFD9CACAFF009300FF60F99BFF58F18FFF2FC84DFF0093
          00FF000000000000000000000000000000000000000000000000000000009C74
          74E4E6D9D9FFEEE4E4FFF2EBEBFFF8F3F3FFFFFFFFFFFFFFFFFFDCD1D1FF947A
          7AFF896A6AFFBB9999FFE0BABAFFDEB9B9FFDBB8B8FFDDBABAFFDDBCBCFFDEBE
          BEFFDFC0C0FFE3C6C6FFDAC7C7FF009300FF62FB9EFF59F292FF33CD53FF0093
          00FF000000000000000000000000000000000000000000000000000000006D51
          5196D7BBBBFFFFFFFFFFFFFFFFFFFFFFFFFFD8C8C8FFA17E7EFD7B5D5DEBAE8E
          8EFFE2BDBDFFDDBABAFFDBBBBBFFDDBCBCFFDEBEBEFFDFC0C0FFE0C3C3FFE1C5
          C5FFE2C7C7FFE5CBCBFFE4D3D3FF009300FF6CFFAEFF64FDA3FF39D25DFF0093
          00FF000000000000000000000000000000000000000000000000000000000E0B
          0B119B7474CED1B1B1FFD6BCBCFFAA8080F86E52529E1C15152A352B2B72A88B
          8BFFE3C1C1FFDEBEBEFFDFC0C0FFE0C3C3FFE1C5C5FFE2C7C7FFE3C9C9FFE4CB
          CBFFE5CDCDFFE6CFCFFFEDD7D7FF009300FF009300FF009300FF009300FF0093
          00FF000000000000000000000000000000000000000000000000000000000000
          000006030306413131504937375E150F0F1A00000000000000002921214F9D82
          82FFE6C8C8FFE1C5C5FFE2C7C7FFE3C9C9FFE4CBCBFFE5CDCDFFE6CFCFFFE7D1
          D1FFE8D3D3FFE9D7D7FFF7E4E4FFBAB3B3FC0202020700000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000001B1616319479
          79FFEAD1D1FFE4CBCBFFE5CDCDFFE6CFCFFFE7D1D1FFE8D3D3FFE9D6D6FFEAD8
          D8FFECDADAFFEDDCDCFFFAEAEAFF6B5B5BFE0A07071700000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000D0A0A168C70
          70FFEFD8D8FFE7D1D1FFE8D3D3FFE9D5D5FFEAD8D8FFEBDADAFFEDDCDCFFEEDE
          DEFFEFE0E0FFF0E2E2FFFBEFEFFF7E6C6CFF1310102E00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000010101038A6B
          6BFAF1DCDCFFEAD7D7FFEBDADAFFEDDCDCFFEEDEDEFFEFE0E0FFF0E2E2FFF1E4
          E4FFF2E7E7FFF3E9E9FFFDF6F6FF918181FF1F1A1A4900000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000008666
          66E6EDDCDCFFF0E0E0FFEFE0E0FFF0E2E2FFF1E4E4FFF2E6E6FFF3E9E9FFF4EB
          EBFFF5EDEDFFF6EFEFFFFFFAFAFFA99B9BFF2D25256900000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000007C5F
          5FCFE6D8D8FFF3E6E6FFF2E6E6FFF3E8E8FFF4EBEBFFF5EDEDFFF6EFEFFFF7F1
          F1FFF9F3F3FFFAF5F5FFFFFFFFFFC2B7B7FF3F33339000000000000000000606
          06151D1C1C7D272424A2211B1B790303030E0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000007258
          58B7E0D1D1FFF7EEEEFFF5EDEDFFF6EFEFFFF7F1F1FFF8F3F3FFFAF5F5FFFBF7
          F7FFFCFAFAFFFDFDFDFFFFFFFFFFE4E0E0FF4E3E3EBE0B080820302626924237
          37F4655353FFBD9494FF8C7171FF302B2BD20403031000000000000000000000
          000000000000000000000000000000000000000000000000000000000000654D
          4D9DD8C7C7FFFAF5F5FFF8F3F3FFF9F5F5FFFBF7F7FFFCF9F9FFFDFDFDFFFFFD
          FDFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFF664F4FFA574444FA8C6969FF5140
          40FFEAB8B8FFFFCECEFFFFD9D9FF997B7BFF211E1E8A00000000000000000000
          0000000000000000000000000000000000000000000000000000000000005640
          4080CFBCBCFFFFFDFDFFFCF9F9FFFDFDFDFFFFFDFDFFFEFEFEFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8D7F7FFFAD8181FFD89F9FFF7A5E
          5EFFA78787FFFFD4D4FFFFD0D0FFF6C6C6FF352C2CD800000000000000000000
          0000000000000000000000000000000000000000000000000000000000004030
          305EC5ADADFFFFFFFFFFFEFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCEC8C8FF826363FFBF9090FF785A
          5AFF473737FFF2C2C2FFFCC9C9FFEFBABAFF3F3232E200000000000000000000
          000000000000000000000000000000000000000000000000000000000000271E
          1E38B59494FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7A6767FF735858FFC69C
          9CFFF9C3C3FFE6B2B2FFDBA5A5FF956F6FFF3228289B00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000806
          060BA07979F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFF1EEEEFF6F5C5CFFA27E
          7EFFB58888FFA37979FF7F5E5EFF503B3BD10906061600000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00008B6666C6EFE8E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFEFFFFFFFFFFFFFFFEFDFDFFFCF8F8FFFAF5F5FFFCF5F5FFD3C8C8FF6B5A
          5AFF615151FD504343C92F272773030202090000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000057424279CEB8B8FFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFD
          FDFFFCFAFAFFF9F5F5FFF6F0F0FFD6C9C9FFA59292FF786161FD584747C6352B
          2B730F0D0D200000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000120E0E19A37C7CF5FFFFFFFFFFFFFFFFFEFEFEFFFBF9F9FFF9F5F5FFF6EF
          EFFFD6C7C7FFAD9999FF836969FC634C4CC3372C2C6D0F0B0B1C000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000056404071B49393FEEFE7E7FFF3ECECFFD8C9C9FFB49B9BFF8F6F
          6FFB6B5353BE3D2F2F6C100D0D1B000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000045353564816161D2896767E66A5252B83B2E2E670F0B
          0B18000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000846150FF866150FF84604FFF84604FFF84604FFF8460
          4FFF84604FFF83604FFF83604FFF83604FFF835F4EFF825F4EFF825F4EFF815F
          4EFF815E4DFF805E4DFF805D4EFFB9A69DFF009300FF009300FF009300FF0093
          00FF009300FFB7A59CFF00000000000000000000000000000000000000000000
          00000000000000000000856150FFF8E4D3FFF2DECCFFF2DECCFFF2DECCFFF2DE
          CCFFF2DECCFFF2DECCFFF2DECCFFF2DFCCFFF2DDCCFFF2DDCBFFF2DDCBFFF2DE
          CAFFF2DCCAFFF2DCC7FFF3DBC7FFF7EBDFFF009300FF35CE5FFF31CA59FF1DB6
          34FF009300FFB7A59CFF00000000000000000000000000000000000000000000
          00000000000000000000866150FFFFFDF2FFFAF4E8FFFAF3E9FFFAF3E9FFFAF3
          E9FFFAF3E9FFFAF3E9FFFAF3E8FFFAF4E8FFFAF2E8FFFAF2E7FFFAF2E7FFFAF3
          E6FFFAF1E6FFFAF2E5FFFAF2E4FFFCF7EFFF009300FF54ED92FF4FE88AFF2EC7
          50FF009300FFB7A49BFF00000000000000000000000000000000000000000000
          00000000000000000000866150FFFFFEF5FFFBF6EAFFFBF5ECFFFBF5EBFFFBF5
          EBFFFBF5EBFFFBF5ECFFFBF5EAFFFBF6EAFFFBF4EBFFFBF4E9FFFBF4EAFFFBF5
          E8FFFDF8F3FFFDF8F2FFFDF9F1FFFCF8F1FF009300FF53EC8EFF4CE584FF2BC5
          4BFF009300FFB8A59CFF00000000000000000000000000000000000000000000
          00000000000000000000876351FFFFFEF7FFFBF5ECFFFCF6ECFFDEC4B7FFDEC5
          B7FFDEC5B7FFDEC4B7FFDDC3B5FFDDC3B5FFDDC2B3FFDDC1B2FFDDC1B0FFECDC
          D3FF009300FF009300FF009300FF009300FF009300FF53EC8DFF4DE684FF29C2
          47FF009300FF009300FF009300FF009300FF009300FF00000000000000000000
          00000000000000000000886251FFFFFFF7FFFCF6EDFFFCF6EEFFDBC0B4FFDBC0
          B4FFDBC0B4FFDBC0B4FFDBC0B3FFDBBFB2FFDBBEB1FFDBBDAEFFDABBACFFEBD9
          D0FF009300FF42DB6DFF39D25FFF37D05AFF3CD564FF50E986FF4CE581FF3FD8
          6AFF27C044FF2AC34AFF2CC54FFF1DB634FF009300FF00000000000000000000
          00000000000000000000896352FFFFFFFAFFFCF7EFFFFCF7EFFFDBC2B8FFDBC2
          B8FFDBC2B8FFDBC2B7FFDBC2B6FFDBC0B5FFDBBFB2FFDBBEB1FFDBBDAFFFEBDA
          D1FF009300FF65FEA4FF58F190FF56EF8EFF52EB88FF4FE882FF4CE580FF4CE5
          81FF4DE685FF4CE584FF4EE78AFF33CC5AFF009300FF00000000000000000000
          000000000000000000008A6453FFFFFFFAFFFCF8F0FFFCF8F1FFDBC3BBFFDBC4
          BBFFDBC4BBFFDBC3BBFFDBC3B9FFDBC2B8FFDBC0B6FFDBBFB3FFDBBEB1FFEBDB
          D3FF009300FF6DFFAFFF61FA9CFF5EF798FF57F08FFF52EB86FF4FE882FF50E9
          86FF53EC8CFF53EC8DFF53EC91FF36CF5FFF009300FF00000000000000000000
          000000000000000000008B6553FFFFFFFBFFFCF8F2FFFCF8F2FFDBC6BEFFDBC6
          BFFFDBC6BFFFDBC4BEFFDBC4BCFFDBC3BAFFDBC1B7FFDBC0B5FFDBBEB3FFEBDB
          D3FF009300FF009300FF009300FF009300FF009300FF58F190FF52EB88FF39D2
          5FFF009300FF009300FF009300FF009300FF009300FF00000000000000000000
          000000000000000000008C6754FFFFFFFEFFFDF9F3FFFDF9F4FFDBC7C2FFDBC7
          C3FFDBC7C3FFDBC6C2FFDBC5BFFFDBC4BCFFDBC3BAFFDBC1B7FFDBBFB3FFEDDF
          D8FFEBDAD3FFEBDAD1FFEBD9CFFFEBD8CEFF009300FF60F99BFF58F18FFF2FC8
          4DFF009300FFB9A79DFF00000000000000000000000000000000000000000000
          000000000000000000008F6655FFFFFFFFFFFDFAF5FFFDFAF5FFDBC8C3FFDBC8
          C4FFDBC8C4FFDBC8C2FFDBC6C0FFDBC4BDFFDBC3BAFFDBC2B8FFDBC0B5FFDBBE
          B2FFDBBDAFFFDBBBACFFDBBAA9FFEBD9CFFF009300FF62FB9EFF59F292FF33CD
          53FF009300FFBAA69DFF00000000000000000000000000000000000000000000
          000000000000000000008F6754FFFFFFFFFFFDFAF6FFFDFBF7FFDBC7C3FFDBC7
          C4FFDBC7C4FFDBC7C3FFDBC6C0FFDBC5BEFFDBC4BBFFDBC2B8FFDBC0B5FFDBBF
          B3FFDBBDAFFFDBBCACFFDBBAAAFFEBD8CEFF009300FF6CFFAEFF64FDA3FF39D2
          5DFF009300FFBAA79EFF00000000000000000000000000000000000000000000
          00000000000000000000916855FFFFFFFFFFFDFBF8FFFDFBF8FFDCC7C2FFDBC6
          C3FFDBC6C3FFDBC6C1FFDBC5C0FFDBC4BDFFDBC3BBFFDBC1B9FFDBC0B5FFDBBF
          B2FFDBBEB0FFDBBCADFFDBBAAAFFEBD8CFFF009300FF009300FF009300FF0093
          00FF009300FFBBA79DFF00000000000000000000000000000000000000000000
          00000000000000000000926957FFFFFFFFFFFEFCF9FFFEFCFAFFDCC6C0FFDCC6
          C0FFDCC6C0FFDCC6C0FFDCC5BFFFDCC4BDFFDBC3BAFFDBC2B7FFDBC0B5FFDBBE
          B2FFDBBDAFFFDBBCADFFDBBAAAFFEDDDD3FFEBD9CFFFEDDBD1FFFDFAF5FFFDFA
          F5FFFAF1E8FFB9A59BFF00000000000000000000000000000000000000000000
          00000000000000000000936A56FFFFFFFFFFFEFCFBFFFEFDFBFFDCC6C0FFDCC6
          C0FFDCC6C0FFDCC6BEFFDCC4BEFFDCC4BBFFDCC3BAFFDBC1B7FFDBC0B4FFDBBE
          B2FFDBBDAFFFDBBCADFFDBBBAAFFDBB9A7FFDBB9A7FFDEBDAAFFFCF6EDFFFCF6
          EEFFF5E5D7FF845F4FFF00000000000000000000000000000000000000000000
          00000000000000000000946C57FFFFFFFFFFFEFDFCFFFEFDFDFFFEFEFDFFFEFE
          FDFFFEFEFDFFFEFDFDFFFEFDFCFFFEFDFBFFFEFCFBFFFEFCFAFFFDFBF9FFFDFB
          F7FFFDFAF6FFFDFAF5FFFDF9F4FFFCF8F2FFFCF8F1FFFCF7EFFFFCF6EEFFFDF8
          EFFFF7E6D6FF845F4EFF00000000000000000000000000000000000000000000
          00000000000000000000956B59FFFFFFFFFFFEFEFDFFFEFEFEFFFEFEFEFFFFFF
          FFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFDFDFFFEFDFCFFFEFCFBFFFEFCF9FFFDFB
          F8FFFDFBF7FFFDFAF6FFFDF9F4FFFDF9F3FFFCF8F1FFFCF7F0FFFCF7EFFFFDF7
          EFFFF6E6D8FF85614EFF00000000000000000000000000000000000000000000
          00000000000000000000966C58FFFFFFFFFFFEFEFEFFFFFFFFFFE0CFCEFFE0D0
          CFFFE0CFCDFFDFCDCAFFDFCDCAFFDFCBC8FFDFC9C5FFDFC8C2FFDFC7BDFFDFC5
          BBFFDFC3B8FFDFC1B4FFDFC0B1FFDFBFACFFDFBFACFFE1C2B0FFFCF7EFFFFDF7
          F0FFF6E6D8FF856050FF00000000000000000000000000000000000000000000
          00000000000000000000976D59FFFFFFFFFFFFFFFFFFFFFFFFFFDDCBC9FFDDCB
          CBFFDDCAC9FFDDC9C6FFDDC9C6FFDCC7C3FFDCC5C0FFDCC3BCFFDCC2B9FFDCC0
          B5FFDBBEB2FFDBBDAFFFDBBAAAFFDBB9A7FFDBB9A7FFDEBEABFFFCF7EFFFFDF7
          F0FFF6E6D7FF86604FFF00000000000000000000000000000000000000000000
          00000000000000000000986E5BFFFFFFFFFFFFFFFFFFFFFFFFFFDDCBC9FFDDCB
          CBFFDDCAC9FFDDC9C6FFDDC9C6FFDCC7C3FFDCC5C0FFDCC3BCFFDCC2B9FFDCC0
          B5FFDBBEB2FFDBBDAFFFDBBAAAFFDBB9A7FFDBB9A7FFDEBEABFFFDF8F1FFFDF8
          F1FFF7E7D9FF866150FF00000000000000000000000000000000000000000000
          0000000000000000000099705AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFDFFFEFDFCFFFEFC
          FAFFFFFDF9FFFEFDF9FFFFFDF9FFFFFDF7FFFEFBF7FFFDF8F3FFF9F5EDFFF5F0
          E8FFE9D6C8FF85614FFC00000000000000000000000000000000000000000000
          000000000000000000009A6F5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFDFCFFFEFC
          FAFFFFFDFBFFE6DCD7FFD9CBC2FFE0D3CCFFDACCC5FFD5C5BEFFC8B6ADFFBBA4
          9AFF977565FF60463AB600000000000000000000000000000000000000000000
          000000000000000000009B705BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFDFFFEFDFCFFFEFC
          FAFFFFFFFFFFBBA295FFA18072FFA78978FFA5836FFFA37F67FFB08866FF936C
          54FF6A4D40C40705040E00000000000000000000000000000000000000000000
          000000000000000000009C725DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFEFDFFFEFDFCFFFEFC
          FAFFFFFFFFFFCBB7ADFFC5AD9FFFFFF5E0FFF9E1BBFFF8D69CFFC59E6EFF684B
          3FC10704040C0000000000000000000000000000000000000000000000000000
          000000000000000000009E725CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFEFEFFFEFDFCFFFEFDFBFFFEFC
          FAFFFFFFFCFFCCBAB0FFBEA18BFFF6DFB8FFF3CF96FFC0986AFF6E5044CF0805
          040E000000000000000000000000000000000000000000000000000000000000
          000000000000000000009C725CFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFEFEFFFEFDFDFFFEFDFCFFFEFCFAFFFEFC
          F9FFFFFEFCFFD7C9C1FFB28D72FFF6D39AFFC89F6EFF6E5044CC0B0807120000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000009D715DFFFFFFFFFFFEFEFDFFFEFEFEFFFEFEFEFFFFFF
          FFFFFEFEFEFFFEFEFEFFFEFEFEFFFEFDFDFFFEFDFCFFFEFCFBFFFEFCFAFFFDFB
          F8FFFFFFFBFFD3C2B9FFB7906AFFCBA16FFF705044CD0A070511000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000009B715BFFFFFFFFFFFEFDFCFFFEFDFDFFFEFEFDFFFEFE
          FDFFFEFEFDFFFEFEFDFFFEFDFCFFFEFDFCFFFEFCFBFFFEFCFAFFFDFBF9FFFDFB
          F7FFFFFEFBFFCEBAB1FFA2795AFF785848D60F0B091900000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000009C715DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFB39789FF775647D40F0A09170000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000009A715DFF9D725FFF9B715DFF9C715DFF9A715DFF9A71
          5DFF99705BFF98705CFF986F5AFF976D5BFF966E59FF956C5AFF946B59FF936A
          58FF936C59FF674B3EB90D090716000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000060E9DD400007CB200000000000000000000000000000000000000000000
          0000000000000505050A2D2D2D605C5C5CC65D5D5DCA3434346F0B0B0B180000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000050E
          91C8102DD5FF1E4EFAFF0102A5FE00004A73000004050000000000002F41030B
          B1FE020DA9FF01019AFF6C74B2FFE4E4E4FFA3A3A3FF7B7B7BFF757575FA5858
          58B52A2A2A590404040A00000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000006070000
          96F12150F7FF2360FFFF215DFFFF0919BDFF0E0E73C122224D850207ACFF1340
          EAFF144FFFFF0F4AFFFF0504A6FFFFFFFFFFA9A9A9FF848484FF848484FF7E7E
          7EFF797979FF6E6E6EF14B4B4B9F202020420101010300000000000000000000
          0000000000000000000000000000000000000000000000000000000000000202
          547D0F25C8FF2860FFFF2358FFFF245EFFFF0D22C7FF000099FF1744EAFF174D
          FFFF1349FFFF1142EAFF0415B6FFFEFEFEFFABABABFF898989FF838383FF8383
          83FF868686FF848484FF7E7E7EFF767676FE656565E23F3F3F891515152C0000
          0000000000000000000000000000000000000000000000000000000000000202
          0203080FB5FF1F49EAFF2A61FFFF2459FFFF235AFFFF1A44EAFF1D51FFFF1A4F
          FFFF1643EAFF071BC2FF7E7ECAFFFBFBFBFFAEAEAEFF8E8E8EFF7E7E7EFF6E6E
          6EFF747474FF7D7D7DFF868686FF888888FF838383FF7A7A7AFF737373FE5E5E
          5ECE333333720C0C0C1900000000000000000000000000000000000000006969
          69C78282A8FE13139BFF1938DBFF2C63FFFF2557FFFF2254FFFF1F53FFFF1F55
          FFFF050CACFF7272C5FFF4F4F7FFF9F9F9FFAEAEAEFF949494FF8B8B8BFF7474
          74FF666666FF666666FF6A6A6AFF737373FF7F7F7FFF878787FF888888FF8282
          82FF787878FF6D6D6DFB525252B82929295C0505050C00000000000000007777
          77E3FFFFFFFFE3E3F5FF303099FF1E42E5FF285DFFFF2557FFFF2458FFFF1737
          DCFF3C3CA2FFF4F4F5FFDADADAFFA4A4A4FF808080FF757575FF808080FF9393
          93FF959595FF838383FF717171FF616161FF636363FF676767FF737373FF8080
          80FF898989FF878787FF7E7E7EFF747474FF5F5F5FE500000000000000007878
          78E3FCFCFCFFFEFEFEFF0C0C91FF3268FFFF2D62FFFF2A60FFFF275DFFFF255E
          FFFF0305A1FF8A8AB9FFBBBBBBFFDBDBDBFFB5B5B5FF8F8F8FFF7A7A7AFF6565
          65FF6D6D6DFF7F7F7FFF929292FF959595FF818181FF6D6D6DFF5D5D5DFF5E5E
          5EFF656565FF737373FF858585FF898989FF696969F500000000000000007979
          79E3F9F9F9FFBEBEE8FF0D1AADFF3871FFFF356EFFFF142CCCFF2556FDFF2962
          FFFF2054FFFF13139BFFD3D3E8FFE7E7E7FFB8B8B8FFA2A2A2FFA0A0A0FFA0A0
          A0FF8F8F8FFF7B7B7BFF676767FF6C6C6CFF7E7E7EFF919191FF959595FF7F7F
          7FFF696969FF595959FF7A7A7AFF8D8D8DFF686868F500000000000000007C7C
          7CE3F6F6F6FF2222ACFF284FEAFF3C75FFFF1B37D4FF39399DFF080893FF1D47
          EAFF2863FFFF1333DEFF6D6DBAFFE4E4E4FFC4C4C4FFB2B2B2FFACACACFFA6A6
          A6FFA2A2A2FFA0A0A0FFA0A0A0FF929292FF7C7C7CFF686868FF6B6B6BFF7D7D
          7DFF909090FF939393FF8D8D8DFF929292FF696969F500000000000000007A7A
          7AE0C8C8C8FF0609A7FF3666EAFF2A54EAFF15159BFFE3E3EDFFEFEFEFFF0303
          A0FF1E4AEAFF2669FFFF040BA6FFE5E5E5FFD2D2D2FFC8C8C8FFC0C0C0FFB9B9
          B9FFB3B3B3FFACACACFFA6A6A6FFA2A2A2FFA2A2A2FFA0A0A0FF939393FF7F7F
          7FFF6A6A6AFF6A6A6AFF7C7C7CFF8D8D8DFF6B6B6BF500000000000000007A7A
          7ADDE4E4E4FF5454B9FF1E35D1FF101EBBFFA2A2D9FFEFEFEFFFE5E5E5FFE0E0
          E0FF070DB4FF1C48F8FF0610B8FFEDEDEDFFE8E8E8FFE1E1E1FFD8D8D8FFD0D0
          D0FFC8C8C8FFC1C1C1FFBABABAFFB3B3B3FFADADADFFA7A7A7FFA2A2A2FFA1A1
          A1FFA1A1A1FF949494FF808080FF6B6B6BFF6B6B6BF500000000000000007B7B
          7BDDE6E6E6FFE8E8E8FF9292D7FF4646BDFFEDEDF0FFE6E6E6FFDEDEDEFFDBDB
          DBFFD9D9D9FF4F4FC4FF9595C9FFF4F4F4FFEBEBEBFFECECECFFEAEAEAFFE8E8
          E8FFE1E1E1FFDADADAFFD1D1D1FFC9C9C9FFC1C1C1FFBBBBBBFFB7B5B7FFAEAA
          ADFFACA7ABFFA7A4A7FFA1A0A1FFA1A1A1FF6D6D6DF500000000000000007B7B
          7BDDE1E1E1FFE6E6E6FFE3E3E3FFE7E7E7FFEAEAEAFFDBDBDBFFD9D9D9FFD6D6
          D6FFD2D2D2FFDEDEDEFFF6F6F6FFF3F3F3FFEEEEEEFFEDEDEDFFECECECFFEBEB
          EBFFECECECFFEAEAEAFFE7E7E7FFE2E2E2FFD9D9D9FFD3D3D3FFAAABA9FF5BBC
          6EFF4CC25FFF72BF7BFFB9B7B8FFA9A9A9FF6A6A6AF300000000000000007C7C
          7CDDE0E0E0FFE2E2E2FFDEDEDEFFDBDBDBFFD9D9D9FFD6D6D6FFD4D4D4FFD6D6
          D6FEEBEBEBFEEDEDEDFFF3F3F3FFF4F4F4FFF1F1F1FFF1F1F1FFEFEFEFFFEEEE
          EEFFEDEDEDFFECECECFFECECECFFECECECFFECECECFFECEBECFFA0A4A1FF42D4
          65FF34D652FF19C02FFF85C28AFFB1AFB1FD5A5A5ACF00000000000000007676
          76CECCCCCCFFE0E0E0FFDBDBDBFFD6D6D6FFD2D2D2FED6D6D6FCDBDBDBFDBCBC
          BCFEA9A9A9FFB0B0B0FFBDBDBDFFD0D0D0FFE1E1E1FFEDEDEDFFF4F4F4FFF2F2
          F2FFF2F2F2FFEFEFEFFFEEEEEEFFEDEDEDFFECECECFFEDEDEDFFEDECEDFFACAB
          ACFF84AF8CFF90BD96FFDAD9D9FE898889FD2F2F2F6400000000000000002323
          233A7D7D7DDAA1A1A1FFB4B4B4FFD2D2D2FEF7F7F7FEFFFFFFFF787878FF5E5F
          5EFF5F6162FF6D6E6FFF808081FF959595FFA7A7A7FFB2B2B2FFC1C1C1FFD6D6
          D6FFE4E4E4FFF0F0F0FFF3F3F3FFF2F2F2FFF0F0F0FFEEEEEEFFEEEEEEFFF0EF
          EFFFF5F2F4FFEEECEEFF969596FF4C4C4CA20000000100000000000000000000
          0000020202042626263F4C4C4C7F6C6C6CBC878787F0A4A4A4FE6A6C6DFFFFE0
          C2FFDDC3ACFFB4A392FF8A8179FF646464FF626464FF717273FF838384FF9999
          99FFAAAAAAFFB6B6B6FFC7C7C7FFD7D7D7FFE5E5E5FFF1F1F1FFF4F4F4FFF4F4
          F4FFC3C3C3FF7C7C7CFA3D3D3D82010101020000000000000000000000000000
          00000000000000000000000000000000000002020204232323447B7978FEFFE8
          CDFFFFE3C6FFFFE4C5FFFFE4C2FFFFE1C0FFE3C6ABFFB9A592FF90867BFF6866
          65FF636566FF727374FF848585FFC5C5C5FFEDEDEDFFE3E3E3FFB7B7B7FF8080
          80FC545454AE1717172C00000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000002424244C9C948EFFFFE9
          D1FFFFE4CBFFFFE3C9FFFFE1C6FFFFE0C4FFFFE1C1FFFFE0BFFFFFE1BEFFFFDF
          BBFFE9C8AAFFC0A892FF847B72FF9C9D9EFF878787FD686868D3404040801212
          1224000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000045454590C2B6ACFFFFEC
          D7FFFFE7D1FFFFE6CFFFFFE5CCFFFFE3CAFFFFE2C7FFFFE1C4FFFFDFC1FFFFDF
          BEFFFFDDBDFFFFE1BDFFB7A490FB282828500E0E0E1A00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000016C6C6CDCF2E3D5FFFFED
          DDFFFFEAD8FFFFE9D5FFFFE8D2FFFFE6D0FFFFE5CDFFFFE4CBFFFFE3C8FFFFE1
          C5FFFFE0C2FFFFE2C2FF90847ADB000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000026262645979492FEFFF7E9FFFFEF
          E1FFFFEEDEFFFFECDCFFFFEBD9FFFFEAD6FFFFE8D3FFFFE7D1FFFFE6CEFFFFE4
          CBFFFFE3CAFFFFE8CBFF4E4B499B000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000626263BBD7D1CBFFFFF6ECFFFFF2
          E7FFFFF1E5FFFFF0E2FFFFEEDFFFFFEDDCFFFFEBDAFFFFEAD7FFFFE9D4FFFFE7
          D2FFFFE8D0FFE1CCB8FF1E1E1F4C000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000027272743969796FEFFFDF8FFFFF7F0FFFFF6
          EEFFFFF4EBFFFFF3E8FFFFF2E6FFFFF0E3FFFFEFE0FFFFEDDDFFFFECDBFFFFEC
          D8FFFFEFDAFF8F8881DF01010104000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000707070B757575DAE6E5E4FFFFFFFDFFFFFAF7FFFFF9
          F4FFFFF8F1FFFFF6EFFFFFF5ECFFFFF3E9FFFFF2E7FFFFF1E4FFFFEFE1FFFFF0
          E0FFEBDBCCFF2C2C2B6900000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000001010102616161A6C0C0C0FFFFFFFFFFFFFFFFFFFFFFFEFFFFFC
          FCFFFFFBF8FFFFFAF5FFFFF8F2FFFFF7F0FFFFF5EDFFFFF4EAFFFFF4E9FFFFF8
          EBFF77736FCB0101010400000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000004B4B4B73A4A4A4FEFCFCFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFEFFFFFBFAFFFFFAF6FFFFF9F3FFFFF7F2FFFFFDF4FFAFAA
          A3F21010102A0000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000C0C0C12292929443C3C3C685555558E7B7B7BB3A1A1A1D9BEBE
          BEF8D2D2D2FEE7E7E7FFFDFCFCFFFFFFFFFFFFFFFFFFFFFFFFFFC3C0BDFA2121
          214F000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000303
          0307131313262323234C343434724E4E4E97747474BD898989D7202020510000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          20000000000000100000000000000000000000000000000000003333337D0F0F
          0F30111111301111113011111130111111301111113011111130111111301111
          1130111111301111113011111130111111301111113011111130111111301111
          1130111111301111113011111130111111301111113011111130111111301111
          113011111130111111301111113011111130111111301212123E2828286C0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303132929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000090605133D20197E3C1D15802E221E430000
          0000000000001D13123F3C1D188036221F69000000001E13104055282190653A
          32BE5D3028AE3F1E196C050303090F090918491A17833A1B197B0806050D0000
          0000000000000604030E401F1880341D166D00000001030303162929296D0000
          000000000000000000000000000037231E60943522FF983520FF733E2FCC0000
          0000000000002C1410569E3524FF83372BE800000000713B30C48F331FFF9336
          24FF923522FF91341DFF823C33D73627264B873D30F2973022FF5C372E943B26
          2042372621424C2C257498341CFF7E3C2CDC01000001030303162929296D0000
          00000000000000000000000000005F352CB09B341EFF953623FF8B3924F5180F
          0E25000000002719173B9D3628FE8D3C28F30B0807132E1A185E47201B7C1F15
          124228181447803627DA90341EFF63342DAB472C2675983522FF8F3D26FF953F
          27FF913C27FF9F3C29FF983522FF5F362A9F00000000030303182929296D0000
          000000000000000000000603030D7C3328E6953A23F9853F2EE796351CFF5B31
          2A96000000000B0504178B3224F2963C22FF2C1D174800000000000000000000
          0000040202077A3C30D59A3420FF76322CD31B1110288E3A2DFA973623FF7637
          28CE693A29BA933C2AFA8D3723FF2F1B155100000000020303182929296D0000
          000000000000000000001F1613329F3728FF773425D736221E5B943624FF8938
          2CE5030202050704030C813829E994321FFF5B39318000000000020101024F31
          2F7879311FDE953722FF98321FFF522D278D010000015C2C24A693331FFF4A28
          207D0201010385392DF3933C25F91B13112800000000020303182929296D0000
          00000000000000000000422820729B2E19FF584A54AC0707070C8C3526F28E37
          24FF38261F60010000016E3425C58E311EFF7D453DB8000000004F35307A9036
          22FF9E3422FF873A27F45226208C00000000000000002213103B923421FF8642
          32DA2417163C933823FF823424DE0302020600000000030303182929296D0000
          000000000000000000006D2A1EB9704747FF3E89B0BA0000000064322A9E9432
          1AFF74362ACA0000000064362C9F92331EFF76372DC8000000006D261AC69338
          1FFF7A352CD00A0605170000000000000000000000000503030979382CDC9437
          26FC744138BC94351FFF753D30C70101010200000000030303182727266D0000
          0000000000000705040E664F52EF198FE4FF4772868600000000201212369537
          23FF943726F7110C0B1B3D29236394371EFF83382CDB00000000653026AC9234
          1DFF833E31E12913114A29100C4B4B2C27850705050B00000000402320689237
          22FF923926FF923821FF5528228D0000000000000000030303182D2B2A6C080A
          0B0F081A22272E6B96AC229DF2FF13A1FAFF2D404A4A000000000604030A8038
          2BE191311CFF55332DA11C181635963620FF94412CFF130F0E1C150E0C247D37
          2DE3963722FF983729FF953923FF933A2EFF0A070613000000000F0A09188B3A
          2EF68F351FFF93351FFF462F2B620000000000000000030303183031326A282F
          343C2C4A5F6C305D7D892D567480425E6D7808090A0A00000000000000003527
          244C4B2F2B803927266A0D0909184329247C462D288018141423000000000E09
          0818341D195F3E1B15803A1B0F803B1F196B0201010500000000000000002316
          143E4A322E80482E2A7B0C0909110000000000000000030303182C28266D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182928286D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182929296D0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303182A2A2A6C0000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000030303132626267D0303
          0330040404300404043004040430040404300404043004040430040404300404
          0430040404300404043004040430040404300404043004040430040404300404
          0430040404300404043004040430040404300404043004040430040404300404
          043004040430040404300404043004040430040404300606063E}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000AF6D29FFAF6F
          27FFB06F27FFB07027FFB17028FFB07027FFB06F27FFAF6D28FFAF6D28FFAF6D
          29FFAF6D28FFAF6D28FFAE6C28FFAD6B27FFAD6B27FFAD6B27FFAE6A26FFAD69
          25FFAD6826FFAD6826FFAC6725FFAB6625FFAB6524FFAA6424FFAA6424FFAA63
          27FFA96227FFA96325FFA96325FFA96225FFAB6020FFAD703BFFB26E2AFFB371
          27FFB37227FFB37228FFB37228FFB37228FFB37227FFB37128FFB37128FFB371
          27FFB27127FFB27026FFB17026FFB16F26FFB06D28FFAF6C27FFB06B26FFB06B
          26FFB06926FFAF6826FFAE6825FFAE6825FFAE6725FFAC6425FFAC6525FFAB64
          24FFAB6423FFAA6324FFAA6324FFAA6225FFAC601FFFAE703AFFB27129FFB273
          29FFB37328FFB37328FFB37428FFB37428FFB37428FFB37526FFB37526FFB374
          28FFB27228FFB27228FFB27227FFB17126FFB27027FFB16F26FFB06E25FFAF6D
          25FFAF6B26FFAF6B26FFAE6A25FFAF6A25FFAE6925FFAE6726FFAC6624FFAC66
          23FFAB6522FFAB6523FFAA6324FFAA6324FFAC601EFFAE7039FFB37628FFB376
          28FFB47728FFB47727FFB57827FFB57828FFB47727FFB47727FFB47727FFB476
          28FFB37528FFB37527FFB37527FFB27326FFB37227FFB37227FFB27127FFB170
          26FFAF6D27FFAF6C27FFAF6B26FFB06B25FFAE6924FFAE6825FFAE6825FFAC66
          23FFAB6522FFAB6523FFAA6324FFAB6324FFAD611DFFAF7139FFB57A29FFB57A
          29FFB67A29FFB67A28FFB67B29FFB67B29FFB57A28FFB67A29FFB67929FFB57A
          28FFB47927FFB57928FFB57828FFB47727FFB47528FFB47427FFB37327FFB272
          27FFB17028FFB06E27FFB06D26FFAF6C25FFAF6B25FFAF6926FFAE6925FFAE67
          25FFAD6724FFAB6524FFAB6524FFAB6524FFAD621FFFAF713AFFB67D29FFB67D
          29FFB87E2AFFB87E2AFFB87E2BFFB87E2BFFB87E2BFFB77E2AFFB87E2BFFB67D
          29FFB57C28FFB67B29FFB77A29FFB67928FFB57828FFB47727FFB27426FFB274
          26FFB37227FFB17025FFB17025FFB06F25FFAF6E24FFB06B26FFB06B26FFAE69
          25FFAE6825FFAD6723FFAB6622FFAB6522FFAD6120FFAF7139FFB88029FFB981
          2AFFBA822AFFBA822AFFBA822AFFBA822AFFBA822AFFBA8229FFBA8229FFB981
          29FFB98028FFB97F29FFB97E29FFB87D29FFB67A2AFFB57928FFB47728FFB376
          27FFB57428FFB47327FFB37227FFB17126FFB16F26FFB06C26FFB06B26FFAF6A
          26FFAE6825FFAE6825FFAD6724FFAC6623FFAD6120FFAF7139FFB9842BFFBA85
          2CFFBA852CFFBA852BFFBA852BFFBB862BFFBC872AFFBC8627FFBC8627FFBB84
          29FFBB8329FFBB822BFFB9802AFFB97F29FFB77E28FFB77D28FFB57B28FFB379
          26FFB57726FFB67626FFB37325FFB07225FFB07124FFB16F24FFAF6D23FFAE6A
          25FFAD6925FFAE6825FFAE6724FFAB6522FFAB621CFFAE7338FFBC882CFFBD89
          2DFFBE8A2CFFBE8B2BFFBF8B2CFFBF8B2CFFBC8A2BFFBC8B2FFFBB8B2FFFBA89
          30FFBB8831FFB98224FFB98025FFBB842EFFBA822EFFB87F29FFB87E2BFFB57B
          29FFB37A2AFFB27726FFB17629FFB27429FFB0742AFFB1722BFFB07128FFAD6C
          28FFAC6B2BFFAB6726FFAB6420FFAC6928FFAB6521FFAA7135FFBE8B2FFFBF8D
          2DFFC18F2DFFC18F2EFFC0902DFFBD8B24FFD7C28FFFE8DFC8FFE2D6B4FFE1D5
          B2FFE7DABFFFCEB780FFD8C59CFFE2D6BAFFE9DDC8FFD0B484FFB37A1FFFE1D2
          B7FFE5DAC6FFCCBC98FFE2D5BCFFE4DAC4FFE1D4BCFFDFCDB2FFDCD0B4FFDFD3
          BDFFDECBB2FFDAC7A9FFDED1BBFFDDCDB7FFDDC8B0FFDACDB4FFC18F2FFFC292
          2DFFC4932EFFC4932EFFC2942EFFBF8E26FFE5D8AFFFD4C185FFCAB374FFD2B8
          7FFFC7AA61FFE8E3CAFFDCCFA4FFC4A55EFFCFB986FFE9E6D5FFD3BE97FFE9E2
          CCFFCAB083FFEDF0EAFFD3B78CFFD6C09EFFC0995EFFC6A474FFC7B594FFDAC8
          B2FFC59E74FFBB925FFFD5C1A8FFCCAE8FFFC29C70FFBC9365FFC5952FFFC797
          2FFFC7982FFFC6982EFFC6992FFFC49329FFE4D7AEFFD2BB76FFDCC68DFFE2D6
          B0FFEAE7D2FFC29639FFC9AA5FFFEAE7D1FFBB9744FFCBAD7AFFD2BF90FFE6DD
          C2FFBF9348FFCFB68CFFB68F4AFFE1CEADFFBD8F4FFFD7BD99FFDFCFB8FFEFE8
          DEFFD3BFA0FFBD915CFFCAAC85FFE3D5C1FFCEB293FFB07B42FFC59B2FFFC79C
          30FFC79E32FFC79E32FFC99F33FFC89A2CFFE5D9AFFFD4BC73FFDAC78BFFE2D6
          AAFFE7D7AFFFC5A752FFCBAD66FFDFD0A9FFC7A55AFFE9E3C8FFC29C56FFD2B7
          80FFBF9E58FFDED3B7FFBD9755FFD5BD95FFC18F4CFFD6BC96FFE0D1B6FFC79F
          72FFC0905EFFDDC4A8FFE4DAC7FFB07A40FFD4B290FFE0D0BDFFC7A134FFCAA4
          36FFCBA63AFFCEA63BFFCCA63CFFCAA333FFE5DFB8FFE4D5A5FFDAC286FFD9C4
          8CFFD5BE7BFFECEDD9FFE9E2C6FFCFB67AFFD3B974FFD0B780FFD1BC86FFEDE6
          D6FFD2B27CFFCDB27FFFCFAD7EFFE9E3D0FFCCAF80FFCDAC7EFFD0BA98FFE1D6
          C4FFC6A677FFC5A275FFE3D8C5FFD6BB99FFC39F79FFCAAA88FFC9A336FFCAA7
          3AFFC9AC40FFCEA83FFFCCA93EFFCDA63DFFD9C37CFFE6D7A9FFE3D6A3FFE2D4
          9FFFE2D5A3FFCEB462FFD3B96DFFDFD19CFFDECE98FFDECC99FFD9C68EFFD8C3
          8EFFDBC798FFDBC598FFD5BE8CFFD3BB89FFD8C299FFD9C59DFFD7BF95FFCCB2
          88FFD0B78EFFD4BC95FFD1B792FFCDAC86FFD5B997FFD6C3A7FFD8C67FFFD6BA
          68FFCFAF49FFD8C585FFD9C78BFFDAC380FFD4BE73FFD9BF79FFD7BC72FFDAC1
          74FFD7BE73FFD6C174FFD7BE6FFFCFB864FFD0B566FFCCA951FFCDAB5DFFCEAB
          65FFCCA967FFC7A055FFC59D55FFCBA564FFC59B59FFAE7217FFBA8E4BFFC29B
          65FFC2975CFFB68443FFBF945CFFBF9262FFB07231FFAB6F2DFFE1D9B3FFF0ED
          D4FFECE4C7FFECE7CDFFDCCE9DFFECECDDFFEEEBD1FFE9E2C2FFF4F4EAFFE7DF
          C1FFE2DEBAFFDCC893FFDACA96FFE8E3CBFFE0D8A8FFEEEEE7FFE3DEC6FFE2DC
          B5FFDED1ADFFF3F5EDFFD7CAA2FFC6B07AFFE9E3CAFFDFCEB4FFE4DCC6FFC3AE
          86FFDED0B7FFF6FBFAFFD2BC9FFFDCD0BEFFD3B48DFFAE6F2EFFE0D19BFFD5C1
          7BFFDBCF9EFFD5BE7AFFD9C17FFFE1DBB2FFDBCA90FFD7BE79FFEEE3C5FFDCC8
          8CFFD6C184FFDBC989FFE5DAB4FFEAE5C8FFCCAD4FFFEBE0C4FFCEBC71FFD6C7
          89FFCBB06AFFD4BB89FFD0B374FFDDCBA4FFC09447FFCAB080FFBC914CFFBA92
          53FFCCAE87FFE5DFCEFFA76A20FFCCAA7DFFD3B590FFB0702FFFEBE8D3FFDBC2
          84FFE4D7ADFFE3C996FFE6DBB3FFD2C17EFFDCCD92FFE5D8AEFFD8C684FFE2CC
          96FFD8C689FFD0BB73FFD2C58FFFE5E0BFFFCEB051FFDFCB93FFC8AF5AFFE2D0
          9FFFD1B672FFC5A862FFE1CFABFFFFFFFFFFC3A05EFFD7C398FFBF9A5BFFDAC7
          AAFFC6A771FFC19B68FFC2A277FFCEAD86FFD4B48FFFAE712FFFE7E0BEFFE3D3
          A6FFD3B971FFF0EAD5FFE9DDB7FFD0AF57FFE9E2CAFFF1F1E4FFD0B465FFDFCB
          92FFD8C589FFD1BA6EFFD4C589FFE5DDBDFFCCAF55FFD6C887FFC7B059FFDCCA
          8FFFCFBA6EFFE4D5B6FFC6A660FFD1BB87FFD6C5A1FFBE944BFFDAC5A1FFE9E5
          D7FFAB7423FFD4BC92FFE4D3BDFFCDAA81FFD5B692FFAD712FFFDBCC87FFF2EF
          DCFFE9E7C9FFF7F3EBFFF3EFDEFFEEE7D1FFECE7C5FFE9DFB6FFEEEAD3FFEEEC
          D6FFEFEBD6FFE8DFBEFFE9DFBBFFEFEBD6FFEBE1C1FFE5D9B2FFE4DDB6FFF0EE
          DBFFEAE5CDFFEFF0E0FFE7DFC2FFE4D7B3FFF0EDDCFFE2D9B9FFE9E4D2FFE8E8
          D8FFE0D4B9FFE3E0D2FFE6E0D3FFECE2D4FFCBAA81FFAE7330FFDCC372FFDFCC
          81FFE3D18BFFE1CC87FFE2D28AFFE1D390FFE2CC81FFE2C97FFFE4CE8CFFE1CD
          83FFDDCA80FFDDC880FFDBC47AFFD6BF6EFFD8BC6AFFD7B965FFD1B35AFFCBAA
          48FFCAA948FFC69E3CFFC69A3DFFC69C44FFC2953FFFC29346FFBE8A38FFB987
          37FFBC8B43FFB57E34FFB67E35FFB7803DFFB37327FFB27B3CFFDCC679FFE0C9
          79FFE0CA7FFFE0CD80FFE3CE82FFE4CE81FFE1CE81FFE2CE81FFE4C97EFFDEC8
          77FFDCC573FFDCC16EFFDBBD66FFD6B95EFFD4B657FFD3B14FFFD0AC46FFCDA5
          3CFFC99F31FFC4992DFFC2952BFFBF8F29FFBC8A29FFBA8728FFBB8229FFB97E
          26FFB67A25FFB47725FFB17325FFB07023FFAE6D21FFB27B3DFFDFC87DFFE4CC
          80FFE2CF83FFE1D185FFE4D388FFE6D289FFE6D288FFE6CF86FFE3CD85FFDFCB
          7FFFDEC77CFFDCC476FFDAC06DFFD7BC65FFD4B85EFFD3B456FFD0AF4CFFCEA9
          42FFCAA338FFC89D31FFC5972DFFC3922EFFC08E2DFFBE8A2BFFB9852AFFB981
          29FFB67D29FFB57929FFB47628FFB27427FFB36F22FFB37D3CFFE1CA7FFFE5CE
          83FFE3D087FFE3D28BFFE6D48DFFE4D38EFFE5D38EFFE8D28AFFE5CF87FFE0CD
          81FFDFC97DFFDDC577FFDCC26FFFD9BE67FFD6BA5FFFD4B557FFD1B04CFFD0AB
          43FFCCA53AFFC89E32FFC6982EFFC3932EFFC08E2DFFBE8A2BFFBA852BFFB981
          29FFB67D29FFB57929FFB47628FFB27428FFB26F22FFB37D3CFFE0CB80FFE4CF
          84FFE3D289FFE3D48CFFE5D68FFFE5D591FFE4D48FFFE5D48CFFE5D089FFE3CE
          85FFE1CA7EFFDEC777FFDDC36FFFDABF69FFD7BB63FFD5B559FFD2B04FFFD0AA
          45FFCBA53AFFC79E33FFC6992EFFC4942CFFC08E2CFFBE8A2BFFBA852BFFB981
          29FFB67D29FFB57929FFB47727FFB27428FFB26F22FFB37D3CFFE1CC81FFE4CF
          84FFE3D289FFE3D48CFFE5D58FFFE5D591FFE5D690FFE4D48CFFE5D089FFE2CE
          86FFE1CA7EFFDEC777FFDDC36FFFDABF69FFD7BB63FFD5B559FFD2B04FFFD0AA
          45FFCBA53AFFC79E33FFC6992EFFC4942CFFC08E2CFFBE8A2BFFBA852BFFB981
          29FFB67D29FFB57929FFB47727FFB27428FFB26F22FFB37D3CFFE1CC81FFE4CF
          84FFE4D189FFE4D38CFFE6D58FFFE5D490FFE4D48FFFE4D48CFFE5D087FFE2CE
          83FFE1CB7EFFDFC777FFDDC370FFDABF68FFD7BB61FFD5B659FFD2B04EFFD0AA
          45FFCDA53AFFC89E33FFC6992FFFC4942DFFC08E2DFFBE8A2BFFBA852BFFB981
          29FFB67D29FFB57929FFB47727FFB17427FFB26F22FFB37D3CFFDFCA7FFFE2CD
          82FFE2CF87FFE3D18AFFE4D48DFFE3D48DFFE2D38CFFE1D28AFFE3D084FFE0CD
          81FFDFCA7CFFDDC676FFDCC26FFFD9BE67FFD6BA5FFFD4B557FFD1AF4DFFCFAA
          45FFCEA43AFFC89E32FFC4982EFFC2922DFFC08E2DFFBD8A2BFFBA852BFFB981
          29FFB67D29FFB57929FFB47727FFB17427FFB36F22FFB37D3CFFDEC87CFFE1CB
          80FFE2CD84FFE2CF87FFE4D288FFE3D287FFE2D186FFE2D087FFE2CD82FFDFCB
          7FFFDFC879FFDDC473FFDBC06DFFD8BC65FFD5B85DFFD3B354FFD0AE4BFFCEA9
          43FFCCA238FFC69C31FFC4962FFFC3922EFFC18E2EFFBE892AFFBB852AFFBA81
          29FFB77D28FFB57A27FFB37726FFB27428FFB37022FFB37D3CFFDDC579FFE0C8
          7CFFE1CB7FFFE2CD81FFE4CF83FFE3CE83FFE3CD82FFE4CC81FFE2CB80FFE0C8
          7CFFE0C675FFDDC26FFFDABE69FFD8BA62FFD5B659FFD2B151FFCEAC48FFCCA8
          40FFCAA233FFC49B2EFFC3972DFFC2922BFFBF8D2BFFBD882AFFBA842AFFB97F
          2BFFB67C28FFB77926FFB77526FFB37229FFB16F22FFB17C3CFFDAC276FFDDC5
          79FFDDC77CFFDDC87DFFE0CB80FFE0CB80FFDFCA7FFFE0C97EFFDEC77CFFDCC5
          79FFDCC273FFDABF6DFFD7BB66FFD5B75FFFD2B457FFD0AF4FFFCCAA46FFCAA6
          3EFFC79E34FFC39832FFC19431FFBD8F2FFFBA8A2EFFB9872CFFB7832EFFB57F
          2EFFB27B2BFFB27929FFB0752AFFAD712CFFAD6D25FFAE7B3FFF}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000604161C1B1355641E15728C1F0F
          8D9F28188D9F23156B7A0E093140000001010000000000000000000000000000
          000000000000162B3E421F51797B2568999F1B629B9F2157828E153D5B600B1A
          2627000000000000000000000000000000000000000000000000000000000000
          000000000000000000000B09181D23147F9E210BD3F31D06E2FF1D06E2FF1E08
          E1FF1C06E1FF1B08DEFF2209E2FF210EADCE130A4A5A00000000000000001B34
          484F2378BEC61F93FDFF2091FDFF2091FFFF2092FFFF1E92FFFF2092FEFF2492
          F5FB2969A2AB0C161E2100000000000000000000000000000000000000000000
          0000000000000D0730422A14CEEE1C06E4FF1C09E3FF2009E1FF2009E1FF2009
          E1FF2009E1FF2009E2FF1E0ADEFF1C07E6FF1E07E0FF200F849D2A558B962295
          FCFF2093FBFF2294FAFF2093FDFF2193FEFF2193FEFF2193FEFF2193FEFF2194
          FBFF1B92FDFF2793EFF61C3C565F000000000000000000000000000000000000
          0000120E32401E09D2F41D08E2FF2109E1FF2009E1FF2009E1FF2009E1FF2009
          E1FF2009E1FF1F09E1FF2009E2FF2008E0FF1B10E0FF1F2BE7FF1B5DEBFF209B
          FAFF2193FDFF2092FFFF2293FDFF2193FEFF2193FEFF2193FEFF2193FEFF2193
          FEFF2093FFFF2392FEFF1D8FF9FE2341575E0000000000000000000000001110
          2125230FCEEE1B09E1FF2208E2FF2009E1FF2009E1FF2009E1FF2009E1FF2009
          E1FF2009E1FF2009E1FF2009E1FF2003E0FF212DE2FF2477F4FF1E71F2FF2477
          F4FF2395FEFF2193FEFF2193FEFF2193FEFF2193FEFF2193FEFF2193FEFF2193
          FEFF2193FEFF2094FDFF2092FCFF2593FAFE0C17222500000000000000002214
          83941A07E0FF2109E2FF2109E3FF1E08E4FF2008E6FF1F09E3FF1E08E6FF1B09
          E5FF1F08E4FF2209E3FF1D08E4FF2012E2FF1E2CE6FF1D26E9FF2123E9FF1F2F
          E6FF248BF9FF1E96FFFF2196FFFF2193FFFF2096FFFF2095FFFF1F94FFFF2095
          FFFF2193FDFF2393FFFF2094FFFF1F95FFFF256BA7B2010203030C091A1F210B
          C2F81903D4FF1606D0FF1B06C9FF1C03D7FF1B02C1FF1503C6FF1902C7FF1E06
          BAFF1901CEFF1801D4FF1A00C1FF182FEAFF1F78D0FF2073D9FF1F6FE0FF2071
          E5FF1E80FDFF1C88E7FF1F79D3FF1A8BF0FF227DD9FF1D81DFFF1F83E3FF1984
          E1FF1E94FFFF1C82DFFF1D7FDCFF1C82DFFF1D93FBFF1322313422174F5D837B
          A4FF7B69A5FF8274B3FF8A7DADFF84709BFFB3ABB3FFB8B1C7FFA99CAAFFC1BA
          BFFFB3AED6FF89799DFFC3BDC9FF644C92FFB7AAB0FFBFB6D3FF988BA3FF8671
          D7FF160BCBFF898D8FFFD1C9C3FF98A2AFFFB1B0AEFFB2C1C7FFA4ACAEFFA0B1
          C1FF388AD3FF9B9A9AFFC5C6C2FFB3BCC2FF5FB3F8FF24506F7615076C85A296
          CDFFB9B5B1FFE1DCDEFFB8B0C1FFE0E1CDFFD9D6E9FFA193C3FFD2D1F3FF553A
          9EFFDAD6CAFFF1EDD7FFC3BFE6FFA2939BFFCFCAE3FF725DB6FF9181A4FFD1CC
          F7FF4229A6FFF3F3E5FF71C0FFFF7CADD7FFE1EEF8FFA2BCD1FFE7E7E2FFDCE5
          E4FF749FC3FFECEFEFFF76B6EBFFE5E9E7FF5EB3FBFF1B619BA3220DA6B77D6B
          C5FFD9D4BDFFE0D8D1FFC7BEB6FFC2BEE8FF8777CEFFCCC6D2FFE2D9D5FFCCC2
          B3FFC3BEE5FF6A5A9BFFC4BEDFFF9281AEFFE6E4ECFFD1CED2FFBEB3B6FFD6D1
          E0FF7C64A7FFD9E9F1FF1991FEFF148DFDFF8ABADCFFC9CDCFFFDFE2E2FFD6D9
          D5FFAFBFCDFFE1EAE7FF4889C5FFC2BCBAFF7CC5FFFF07579D9F2A22AABA5A45
          BAFFFDFDE9FFA09AB6FFDAD8CDFFD8D5E3FF8B7DA6FFD7D0CDFFD4D0E3FFB9B3
          E1FFDFDBDEFF9689ACFFF2F1DFFFAFA3DAFFCCBEDCFFE0D7D5FF8C74D5FFD6D1
          E0FFD8CDCBFFEAE9DFFF66A9E8FF2776BBFF8FA8BDFFD5D1CAFFD1E1E7FFB8C9
          CFFFF0F2EFFFBDD2DBFFE6E7E2FFEDEADCFF95CCF9FF0958A1A32E246F7C3622
          C7FFF6F5F1FF8A7EDEFFA396D4FFF2F0FDFF4E3DE3FF5B4CE9FF3320E3FF2110
          DAFF5F4CE9FF4B3BD7FFA89CE5FF4F61EDFF3252E8FF5577EEFF1F39E6FF3F5E
          EDFF395DE3FF7EB0E2FFEAF0EAFFE7E1DAFF6CBBFBFF5CB3FEFF419FF8FF369E
          F8FF45A5FBFF319CF8FF3EA6FBFF7DABCBFFB5DDF9FF1F4F7D85120F2E3A210B
          E2FF3520DFFF2B14E2FF2710E2FF3821E2FF1F0AE0FF1700E1FF1C05E0FF1D07
          E1FF1700E1FF1804E3FF1600E2FF1E50E9FF2071F4FF1A69F1FF2270F1FF1B69
          F0FF1E7BF7FF1B91FEFF3B9DFCFF46A7FEFF2394FDFF178EFDFF1E91FEFF1F92
          FDFF1990FEFF1E91FEFF1B90FEFF2395FDFF359BFAFF14334A4F020204062713
          A8CA1702E3FF1E07E1FF1E07E1FF1C05E1FF2008E1FF2009E1FF2009E1FF2009
          E1FF2009E1FF1F0ADFFF2107E3FF200BE2FF1E39E7FF1F39EBFF1F39EAFF1F32
          E8FF226BF3FF2299FFFF1A93FEFF1C90FFFF2093FEFF2193FEFF2193FEFF2193
          FEFF2193FEFF2193FEFF2193FEFF1E91FFFF238DDFE9060F1214000000001711
          43521B05DFFF2109E2FF2009E1FF2009E1FF2009E1FF2009E1FF2009E1FF2009
          E1FF2009E1FF2109E0FF1F09DFFF200BE0FF1F5FEEFF2171F3FF236AF0FF2383
          F6FF219AFDFF2392FEFF2292FFFF2193FEFF2193FEFF2193FEFF2193FEFF2193
          FEFF2193FEFF2393FEFF2493FFFF1E91FDFF274E6B6F00000000000000000101
          0202352A97AE1B02E2FF2109E1FF2009E1FF2009E1FF2009E1FF2009E1FF2009
          E1FF2009E1FF2009E1FF2009E1FF2008E3FF2002DEFF2127E2FF1C32E5FF2375
          F4FF2098FEFF2193FEFF2193FEFF2193FEFF2193FEFF2193FEFF2193FEFF2193
          FEFF2193FEFF2194FDFF2092FEFF1F68A7B00204050500000000000000000000
          00000404070824178EB01E06E2FF1E08E2FF1F0AE0FF200AE0FF1E09E1FF1F09
          E2FF200ADFFF2009E1FF1F09E1FF1F0AE0FF1A01E3FF213ADBF52898EDF21A96
          FEFF2392FEFF2193FEFF2293FDFF2293FEFF2193FEFF2294FCFF2193FEFF2194
          FDFF2092FFFF1D91FEFF266CAAB7020508090000000000000000000000000000
          000000000000000000001A145E7C260BDFF91E05E5FF1D07E2FF2008E2FF2109
          E2FF2009DFFF1F07E2FF1D06E3FF1E07E1FF2717AACD0D0C262F111B2729347A
          B9C11D93FCFF1D92FDFF2292FCFF1F92FFFF2094FDFF1E93FBFF1F92FEFF1E91
          FEFF2897F9FF396B969F0306090A000000000000000000000000000000000000
          00000000000000000000000000000B071D24180F667F2615AFD4220ED7F71F08
          E2FF210CDFFF2412CBEE2815A1BB130D3C4E0101030400000000000000000000
          000010283D413774ADB72286E2E62997FBFF1E92FEFF2897FAFF2682CED92157
          858D13222E310000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000302080B150F394A1B106C811304
          8D9F1D118E9F231B6273110B2C33000000000000000000000000000000000000
          00000000000016232E311D476A6B22649C9F0F599E9F2B66979B17354A51050C
          1112000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000494949947171
          719F6E6E6E9F6E6E6E9F6E6E6E9F6E6E6E9F70706D9F666B6C9F3E5C699F1D4F
          6C9F07436C9F00406C9F00406E9F00426E9F01436D9F02456D9F04446D9F0145
          6E9F01456E9F03436E9F02446E9F01456E9F02446E9F02446E9F02446E9F0244
          6E9F02446E9F02446E9F02436E9F04446C9F04476B9F0A375694A6A6A6F6F7F7
          F7FFF6F6F6FFF6F6F6FFF6F6F6FFF6F6F6FFF7F7F6FFF2F6F6FFDEF1F6FFBEE1
          F4FF81C2EEFF43ABEFFF1898EFFF0091F2FF008EF2FF008FF3FF0893F3FF0996
          F5FF0695F6FF0793F5FF0195F5FF0695F5FF0694F6FF0294F6FF0294F6FF0294
          F6FF0294F6FF0294F6FF0394F6FF0695F3FF0499F5FF0D7DCBF6A6A6A6EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFDFFFCFFFFFFE9F5FCFFC1E3F9FF94D1FCFF47B6F6FF119FF7FF0095
          FAFF0094FFFF0098FEFF0599FFFF0699FFFF0399FFFF0199FFFF0199FFFF0199
          FFFF0199FFFF0199FFFF0199FFFF039BFEFF009DFFFF077DCBEDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE
          FFFFFDFCFDFFFDFDFCFFFDFFFBFFFFFFFAFFFFFFFDFFFFFFFFFFDDF2F9FFA0D3
          F5FF58B8F4FF22A3F8FF0091FAFF0093FFFF0499FDFF0098FFFF0198FFFF0198
          FFFF0198FFFF0198FFFF0198FFFF039AFCFF009CFFFF077CCAEDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFEFEFEFFFEFDFEFFFCFCFEFFFBFEFDFFFBFFFDFFFCFFFEFFFFFFFBFFFFFF
          FDFFFFFFFCFFF0FBF9FFA9DDF9FF49B2F7FF0798F8FF0092FDFF0097FFFF029B
          FDFF029AFEFF0399FCFF0298FFFF039AFCFF009CFFFF077CCAEDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFAFFFFFFFFFFFAFFFFFFF7FFE0F1FAFF96CFF7FF28A6F7FF0094
          FCFF0295FDFF069AFCFF0198FEFF039AFCFF009CFFFF077CCAEDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFEFDFDFFFAFFFBFFFDFEFCFFFFFEFCFFFFFFF8FFF0FBFBFF9CD1
          F6FF38AFF7FF0293FBFF0096FCFF039AFCFF009CFFFF077CCAEDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFF8FFFDFFFAFEFFFFFEFFFEFFFFFF
          FCFFFFFFF9FFB3E1F6FF31A8F5FF0095F9FF0098FFFF087DC7EDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F9
          F9FFEBEBEBFFE2E2E2FFD8D8D8FFF6F6F6FFF9F9F9FFDDDDDDFFE7E7E7FFEFEF
          EFFFD2D2D2FFF0EFEFFFE1E1E1FFDEDEDEFFECECECFFFFFFFFFFFFFFFFFFFEFF
          FEFFFFFFFDFFFFFFFFFFF7FDFDFFABDCFAFF29A5FBFF0379C3EDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE2E2
          E2FF9D9D9DFFA9A9A9FFADAEAEFFD7D7D7FFD1D1D1FF929292FFA4A4A4FFC8C8
          C8FFBABABAFFBEBEBEFFA0A0A0FF969696FFE1E1E1FFFFFFFFFFFFFFFFFFFEFF
          FEFFFEFFFEFFFFFEFEFFFFFDFFFFFFFFFBFFE9F9FEFF6EA3C8EDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFF3F3F3FFF2F2F2FFE7E7E7FFE7E7E6FFE4E4E4FFFFFAF9FFFFFBF8FFF7F2
          F0FFDBD9D8FFEFF0F0FFE8E8E8FFF1F1F1FFF1F1F1FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFCECDC7EDA7A7A7EDFFFF
          FFFF717171FF525252FF969696FFFFFFFFFF8C8C8CFFC2C2C2FF474747FF5F5F
          5FFFFEFEFEFFDDDCDDFF4E4F4EFF55504EFFF1EEEEFFBDE9FBFF74C1F6FF7ECB
          F3FFE2F6FDFFFFFFFFFFD0D0D1FF979797FFFFFFFFFFD1D1D1FF555555FF6262
          62FFB4B4B4FFA4A4A4FFD0D0D0FF7A7A7BFFFFFFFEFFCBCCCCEDA8A8A8EDFEFE
          FEFF323232FFA3A3A3FF545454FF7C7C7CFF4B4B4BFF9F9F9FFFB4B4B4FF5555
          55FF707070FF424241FF9A9B9CFFB8B7B6FFB6D4E5FF6ABBF7FF9FCFF9FF8DC3
          FEFF75BFF7FFFAFEFFFF666463FF1A1A1AFFFFFFFFFFACACACFF454545FFCCCC
          CCFFA7A7A7FF464646FF4D4D4DFFBFBFBFFFFFFFFFFFCACACAEDA8A8A8EDFDFD
          FDFF414141FFF9F9F9FFDFDFDFFF282828FF3F3F3FFFE3E3E3FF9F9F9FFF3A3A
          3AFF6F6F6FFF555554FFFFFFFFFFFFFFFFFF99D5F8FF92C2FCFFD7F0FCFFD4EA
          FDFF7BCAFEFFB0CFDDFF423D3BFF525252FFB8B8B8FFBDBDBDFF2E2E2EFF8D8D
          8DFFADADADFF121212FF383838FFE0E0E0FFFFFFFFFFCACACAEDA8A8A8EDFCFC
          FCFF3C3C3CFFEBEBEBFF868686FF484848FF535353FF868686FF373737FFEEEE
          EEFFD5D5D5FF272626FFE2E5E4FFFBFAF5FFA7D4F0FF6BBBFCFFC0D9FEFFA7D6
          FBFF78C7FFFF718188FF7A7775FFD0D0D0FF454545FFADADADFF555555FFE8E8
          E8FFAAAAAAFF676767FF919191FF5D5D5DFFFFFFFFFFCBCBCBEDA7A7A7EDFEFE
          FEFF505050FF505050FF707070FFE6E6E6FF6B6B6BFFC7C7C7FF565656FF6565
          65FFEDEDEDFFAFAFAFFF454545FF545650FFDFDFDEFFA7D7FDFF71BEF2FF78C5
          F6FFBADDF1FF645D59FFDBDCDCFFFBFBFBFF656565FFA0A0A0FF404040FF6D6D
          6DFFB1B1B1FF414141FF5E5E5EFFB8B8B8FFECECECFFCDCDCDEDA5A5A5EDFFFF
          FFFFFFFFFFFFFDFDFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFA
          FAFFFFFFFFFFFFFFFFFFFCFBFAFFF5F4F7FFFCFFF7FFFFFFF8FFF1F7FDFFF8FA
          FBFFFBFCF6FFF7FFFCFFFFFFFFFFFCFCFCFFFFFFFFFFFCFCFCFFFFFFFFFFFCFC
          FCFFFDFDFDFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFCACACAEDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFEFEFEFFFFFFFFFFFFFF
          FFFFFEFEFEFFFFFFFFFFFEFFFEFFFFFFFEFFFFFDFFFFFCFFFFFFFEFFFDFFFEFF
          FCFFFEFDFEFFFFFEFFFFFEFFFEFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFFFF
          FFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCACACAEDA5A5A5EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCACACAEDA7A7A7EDFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCCCCCCED9D9D9DF6EAEA
          EAFFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9
          E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9
          E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9
          E9FFE9E9E9FFE9E9E9FFE9E9E9FFE9E9E9FFEAEAEAFFBFBFBFF6292929944040
          409F3F3F3F9F3F3F3F9F3F3F3F9F3F3F3F9F3F3F3F9F3F3F3F9F3F3F3F9F3F3F
          3F9F3F3F3F9F3F3F3F9F3F3F3F9F4040409F4040409F4040409F4040409F4040
          409F4040409F4040409F4040409F4040409F4040409F4040409F4040409F4040
          409F4040409F4040409F4040409F4040409F4141419F32323294000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000007345
          0073FF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FF734500730000000000000000FF99
          00FF2E5EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFFFF9900FF0000000000000000FF99
          00FF3867FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF3C6BFFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF2052FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFFFF9900FF0000000000000000FF99
          00FF2E5EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFFFF9900FF0000000000000000FF99
          00FF3867FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF3C6BFFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF2052FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFFFF9900FF0000000000000000FF99
          00FF2E5EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFFFF9900FF0000000000000000FF99
          00FF3867FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF3C6BFFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF2052FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFFFF9900FF0000000000000000FF99
          00FF2E5EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFFFF9900FF0000000000000000FF99
          00FF3867FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF3C6BFFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF2052FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFF1446FFFF2052FFFF2052FFFF1C4E
          FFFF1446FFFF2052FFFF2052FFFF1C4EFFFFFF9900FF0000000000000000FF99
          00FF2E5EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3
          FFFF1C4EFFFF79B1FFFF79B1FFFF6EA3FFFFFF9900FF0000000000000000FF99
          00FF3867FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFF8BC6FFFF85BFFFFF79B1
          FFFF2052FFFF8BC6FFFF85BFFFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF3C6BFFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFF9DDBFFFF8BC6FFFF79B1
          FFFF2052FFFF9DDBFFFF8BC6FFFF79B1FFFFFF9900FF0000000000000000FF99
          00FF3867FFFF3C6BFFFF3867FFFF2E5EFFFF2052FFFF3C6BFFFF3867FFFF2E5E
          FFFF2052FFFF3C6BFFFF3867FFFF2E5EFFFF2052FFFF3C6BFFFF3867FFFF2E5E
          FFFF2052FFFF3C6BFFFF3867FFFF2E5EFFFF2052FFFF3C6BFFFF3867FFFF2E5E
          FFFF2052FFFF3C6BFFFF3867FFFF2E5EFFFFFF9900FF0000000000000000FF99
          00FFFF9C0AFFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FF0000000000000000FF99
          00FFFFB553FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E
          00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E
          00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E
          00FFF48E00FFF48E00FFF48E00FFFB9500FFFF9900FF0000000000000000FF99
          00FFFFC074FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB85
          00FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB85
          00FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB85
          00FFEB8500FFEB8500FFEB8500FFF79100FFFF9900FF0000000000000000C174
          00C1FFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC
          99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC
          99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC
          99FFFFCC99FFFFCC99FFFFC074FFFFAD3DFFC17400C10000000000000000472B
          0047C17400C1FF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFC17400C1472B004700000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000007345
          0073FF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FF734500730000000000000000FF99
          00FFC2A587FFFFF1F1FFFFEEEEFFFFEEEEFFB8ACACFFFFEEEEFFFFEEEEFFFFEE
          EEFFB8ACACFFFFEDEDFFFFECECFFFFEBEBFFB8AAAAFFFFEAEAFFFFE9E9FFFFE7
          E7FFB8A7A7FFFFE6E6FFFFE4E4FFFFE4E4FFB8A3A3FFFFE1E1FFFFDFDFFFFFDE
          DEFFB89F9FFFFFDBDBFFFFDADAFFFFD0ABFFFF9900FF0000000000000000FF99
          00FFBDACACFFFFEAEAFFFFEBEBFFFFEBEBFFB8AAAAFFFFEBEBFFFFEBEBFFFFEB
          EBFFB8AAAAFFFFEAEAFFFFE9E9FFFFE8E8FFB8A7A7FFFFE5E5FFFFE5E5FFFFE3
          E3FFB8A2A2FFFFE0E0FFFFDEDEFFFFDCDCFFB89E9EFFFFD9D9FFFFD7D7FFFFD5
          D5FFB89999FFFFD1D1FFFFD0D0FFFFD9D9FFFF9900FF0000000000000000FF99
          00FFBDAEAEFFFFEDEDFFFFEDEDFFFFEDEDFFB8ABABFFFFEDEDFFFFEDEDFFFFED
          EDFFB8ABABFFFFEDEDFFFFECECFFFFEBEBFFB8A8A8FFFFE8E8FFFFE6E6FFFFE5
          E5FFB8A4A4FFFFE1E1FFFFE0E0FFFFDEDEFFB89F9FFFFFDBDBFFFFD8D8FFFFD7
          D7FFB89999FFFFD3D3FFFFD0D0FFFFDADAFFFF9900FF0000000000000000FF99
          00FFBDAFAFFFB8ACACFFB8ACACFFB8ADADFFB8ADADFFB8ADADFFB8ADADFFB8AD
          ADFFB8ACACFFB8ACACFFB8ABABFFB8ABABFFB8AAAAFFB8A9A9FFB8A7A7FFB8A7
          A7FFB8A5A5FFB8A5A5FFB8A2A2FFB8A2A2FFB8A0A0FFB89F9FFFB89D9DFFB89C
          9CFFB89A9AFFB89999FFB89898FFB89E9EFFFF9900FF0000000000000000FF99
          00FFBDB1B1FFFFF1F1FFFFF2F2FFFFF3F3FFB8AFAFFFFFF3F3FFFFF3F3FFFFF3
          F3FFB8AFAFFFFFF1F1FFFFF0F0FFFFEFEFFFB8ABABFFFFEDEDFFFFEBEBFFFFE9
          E9FFB8A7A7FFFFE5E5FFFFE3E3FFFFE1E1FFB8A2A2FFFFDDDDFFFFDCDCFFFFD9
          D9FFB89C9CFFFFD5D5FFFFD3D3FFFFDCDCFFFF9900FF0000000000000000FF99
          00FFBDB4B4FFFFF4F4FFFFF5F5FFFFF6F6FFB8B2B2FFFFF6F6FFFFF6F6FFFFF6
          F6FFB8B1B1FFFFF4F4FFFFF3F3FFFFF2F2FFB8ADADFFFFEEEEFFFFEDEDFFFFEB
          EBFFB8A8A8FFFFE7E7FFFFE5E5FFFFE3E3FFB8A2A2FFFFDFDFFFFFDCDCFFFFDB
          DBFFB89C9CFFFFD6D6FFFFD4D4FFFFDDDDFFFF9900FF0000000000000000FF99
          00FFBDB6B6FFFFF6F6FFFFF7F7FFFFF8F8FFB8B3B3FFFFF8F8FFFFF8F8FFFFF8
          F8FFB8B2B2FFFFF6F6FFFFF6F6FFFFF4F4FFB8AFAFFFFFF0F0FFFFEEEEFFFFED
          EDFFB8AAAAFFFFE8E8FFFFE6E6FFFFE5E5FFB8A3A3FFFFE0E0FFFFDEDEFFFFDC
          DCFFB89D9DFFFFD8D8FFFFD5D5FFFFDEDEFFFF9900FF0000000000000000FF99
          00FFBDB7B7FFB8B4B4FFB8B4B4FFB8B5B5FFB8B5B5FFB8B5B5FFB8B5B5FFB8B5
          B5FF2052FFFF2052FFFF2052FFFF1C4EFFFF1446FFFFB8AFAFFFB8ADADFFB8AC
          ACFFB8ABABFFB8A9A9FFB8A7A7FFB8A5A5FFB8A4A4FFB8A2A2FFB8A1A1FFB89F
          9FFFB89E9EFFB89C9CFFB89A9AFFB8A0A0FFFF9900FF0000000000000000FF99
          00FFBDB9B9FFFFFBFBFFFFFDFDFFFFFEFEFFB8B7B7FFFFFEFEFFFFFEFEFFFFFE
          FEFF2E5EFFFF79B1FFFF79B1FFFF6EA3FFFF1C4EFFFFFFF5F5FFFFF2F2FFFFF0
          F0FFB8ABABFFFFECECFFFFE9E9FFFFE7E7FFB8A5A5FFFFE2E2FFFFE0E0FFFFDE
          DEFFB89F9FFFFFD9D9FFFFD7D7FFFFDEDEFFFF9900FF0000000000000000FF99
          00FFBDBABAFFFFFEFEFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFF3867FFFF8BC6FFFF85BFFFFF79B1FFFF2052FFFFFFF6F6FFFFF4F4FFFFF2
          F2FFB8ACACFFFFEDEDFFFFEBEBFFFFE8E8FFB8A5A5FFFFE3E3FFFFE0E0FFFFDF
          DFFFB89F9FFFFFDADAFFFFD8D8FFFFDFDFFFFF9900FF0000000000000000FF99
          00FFBDBCBCFFFFFFFFFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFF3C6BFFFF9DDBFFFF8BC6FFFF79B1FFFF2052FFFFFFF7F7FFFFF6F6FFFFF3
          F3FFB8ADADFFFFEDEDFFFFECECFFFFE9E9FFB8A6A6FFFFE4E4FFFFE1E1FFFFDF
          DFFFB89F9FFFFFDBDBFFFFD8D8FFFFE0E0FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8
          B8FF3867FFFF3C6BFFFF3867FFFF2E5EFFFF2052FFFFB8B4B4FFB8B2B2FFB8B0
          B0FFB8AEAEFFB8ACACFFB8ABABFFB8A9A9FFB8A7A7FFB8A5A5FFB8A3A3FFB8A2
          A2FFB89F9FFFB89E9EFFB89C9CFFB8A2A2FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFFFFFFB8B7B7FFFFFAFAFFFFF7F7FFFFF5
          F5FFB8AFAFFFFFEFEFFFFFEDEDFFFFEBEBFFB8A7A7FFFFE5E5FFFFE3E3FFFFE0
          E0FFB8A0A0FFFFDCDCFFFFD9D9FFFFE1E1FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFFFFFFB8B7B7FFFFFBFBFFFFF8F8FFFFF6
          F6FFB8AFAFFFFFF0F0FFFFEDEDFFFFEBEBFFB8A7A7FFFFE5E5FFFFE3E3FFFFE0
          E0FFB8A0A0FFFFDCDCFFFFD9D9FFFFE1E1FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFFFFFFB8B7B7FFFFFBFBFFFFF8F8FFFFF6
          F6FFB8AFAFFFFFF0F0FFFFEDEDFFFFEBEBFFB8A7A7FFFFE5E5FFFFE3E3FFFFE0
          E0FFB8A0A0FFFFDCDCFFFFD9D9FFFFE1E1FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8
          B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B7B7FFB8B5B5FFB8B3B3FFB8B2
          B2FFB8AFAFFFB8ADADFFB8ABABFFB8AAAAFFB8A7A7FFB8A5A5FFB8A4A4FFB8A2
          A2FFB8A0A0FFB89F9FFFB89D9DFFB8A2A2FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFFFFFFB8B7B7FFFFFBFBFFFFF8F8FFFFF6
          F6FFB8AFAFFFFFF0F0FFFFEDEDFFFFEBEBFFB8A7A7FFFFE5E5FFFFE3E3FFFFE0
          E0FFB8A0A0FFFFDCDCFFFFD9D9FFFFE1E1FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFFFFFFB8B7B7FFFFFBFBFFFFF8F8FFFFF6
          F6FFB8AFAFFFFFF0F0FFFFEDEDFFFFEBEBFFB8A7A7FFFFE5E5FFFFE3E3FFFFE0
          E0FFB8A0A0FFFFDCDCFFFFD9D9FFFFE1E1FFFF9900FF0000000000000000FF99
          00FFBDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFF
          FFFFB8B8B8FFFFFFFFFFFFFFFFFFFFFFFFFFB8B7B7FFFFFAFAFFFFF7F7FFFFF5
          F5FFB8AFAFFFFFEFEFFFFFEDEDFFFFEBEBFFB8A7A7FFFFE5E5FFFFE3E3FFFFE0
          E0FFB8A0A0FFFFDCDCFFFFD9D9FFFFE1E1FFFF9900FF0000000000000000FF99
          00FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B8
          B8FFB8B8B8FFB8B8B8FFB8B8B8FFB8B7B7FFB8B5B5FFB8B4B4FFB8B1B1FFB8B0
          B0FFB8AEAEFFB8ACACFFB8ABABFFB8A9A9FFB8A7A7FFB8A5A5FFB8A3A3FFB8A2
          A2FFB89F9FFFB89E9EFFB89C9CFFBFA9A9FFFF9900FF0000000000000000FF99
          00FFFF9C0AFFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FF0000000000000000FF99
          00FFFFB553FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E
          00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E
          00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E00FFF48E
          00FFF48E00FFF48E00FFF48E00FFFB9500FFFF9900FF0000000000000000FF99
          00FFFFC074FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB85
          00FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB85
          00FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB8500FFEB85
          00FFEB8500FFEB8500FFEB8500FFF79100FFFF9900FF0000000000000000C174
          00C1FFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC
          99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC
          99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC99FFFFCC
          99FFFFCC99FFFFCC99FFFFC074FFFFAD3DFFC17400C10000000000000000472B
          0047C17400C1FF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF9900FFFF99
          00FFFF9900FFFF9900FFFF9900FFC17400C1472B004700000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000A577
          77C7A47474C2876262A56F5050875740406A3E2E2E4D261D1D300F0C0C140101
          0102000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000C593
          93F5DB9898FFF4BDBDFFECB3B3FFE4ADADFFDEA6A6FFD69E9EFFCD9797FEC392
          92F3B48888D89B7878BB8266669E6A53538152414164382F2F47221B1B2B0A0B
          0B0F010000010000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000BD91
          91F5DFAFAFFFE8ABABFFFFD8D8FFFFD3D3FFFFD2D2FFFFD2D2FFFFD0D0FFFFCC
          CCFFF8C5C5FFF2BEBEFFE8B6B6FFE0B0B0FFD6AAAAFFCEA2A2FFC29B9BFFB698
          98FDA49797EE9E8787D3897575B6736464995C50507C463E3E60312C2C431B19
          19260707070A000000000000000000000000000000000000000000000000C28D
          8DF5F9EFEFFFE0A2A2FFF1C2C2FFFFDDDDFFFFD8D8FFFFD7D7FFFFD5D5FFFFD4
          D4FFFFD4D4FFFFD2D2FFFFD2D2FFFFD2D2FFFFD1D1FFFFD0D0FFFFCECEFFFFCE
          CEFFFDC7C7FFF3C0C0FFE9B9B9FFDCB2B2FFD3ACACFFC6A6A6FFBA9E9EFFAC99
          99FFA49595FEA19696EB908686CF7D7777B4434040630000000000000000C58D
          8DF5F9EDEDFFFEECECFFDA9292FFFBDADAFFFFE4E4FFFFE0E0FFFFDEDEFFFFDD
          DDFFFFDCDCFFFFDBDBFFFFD9D9FFFFD8D8FFFFD7D7FFFFD5D5FFFFD4D4FFFFD3
          D3FFFFD3D3FFFFD1D1FFFFD1D1FFFFD0D0FFFFD0D0FFFFCFCFFFFFCDCDFFFFCD
          CDFFFFCACAFFFDC6C6FFC9AAAAFFA29898FF6C6868AD0000000000000000C68D
          8DF5F9EBEBFFFFF5F5FFF7D2D2FFDC9696FFFFEDEDFFFFEBEBFFFFE8E8FFFFE6
          E6FFFFE5E5FFFFE4E4FFFFE2E2FFFFE1E1FFFFE0E0FFFFDFDFFFFFDDDDFFFFDC
          DCFFFFDBDBFFFFD9D9FFFFD8D8FFFFD7D7FFFFD6D6FFFFD4D4FFFFD3D3FFFFD2
          D2FFFFD6D6FFE5BEBEFFAE9999FFD1B2B2FF6C6767AD0000000000000000C98D
          8DF5F9ECECFFFFF2F2FFFFEDEDFFEFBBBBFFE2A7A7FFFFFAFAFFFFF3F3FFFFEF
          EFFFFFEEEEFFFFEDEDFFFFECECFFFFEAEAFFFFE9E9FFFFE8E8FFFFE6E6FFFFE5
          E5FFFFE4E4FFFFE3E3FFFFE1E1FFFFE0E0FFFFDFDFFFFFDDDDFFFFDCDCFFFFE0
          E0FFE5C5C5FFAA9595FFFFC7C7FFD8B8B8FF6E6666AD0000000000000000CD8C
          8CF5FAEEEEFFFFF5F5FFFFEBEBFFFFE9E9FFE7A9A9FFE9B8B8FFFFFFFFFFFFFB
          FBFFFFF7F7FFFFF6F6FFFFF5F5FFFFF3F3FFFFF2F2FFFFF1F1FFFFF0F0FFFFEE
          EEFFFFEDEDFFFFECECFFFFEAEAFFFFE9E9FFFFE8E8FFFFE8E8FFFFEBEBFFE4C8
          C8FFB19494FFFBC3C3FFFFD1D1FFD8B9B9FF706666AD0000000000000000CF8C
          8CF5F9F1F1FFFFF8F8FFFFEEEEFFFFE8E8FFFFE3E3FFE49D9DFFEDC7C7FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFDFDFFFFFCFCFFFFFBFBFFFFFAFAFFFFFAFAFFFFF7
          F7FFFFF6F6FFFFF5F5FFFFF4F4FFFFF2F2FFFFF2F2FFFFF9F9FFE0C7C7FFB795
          95FFFCC8C8FFFFD0D0FFFFD8D8FFDCBFBFFF716666AD0000000000000000D18C
          8CF5FAF1F1FFFFFCFCFFFFF3F3FFFFECECFFFFE6E6FFFFE0E0FFE29898FFF0CE
          CEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFFFFFE
          FEFFFFFFFFFFFFFDFDFFFFFDFDFFFFFEFEFFFFFFFFFFD7BCBCFFC29B9BFFFFD3
          D3FFFFD6D6FFFFD9D9FFFFE1E1FFDCC2C2FF736666AD0000000000000000D48C
          8CF5FBF4F4FFFFFFFFFFFFF8F8FFFFF1F1FFFFEAEAFFFFE7E7FFFFE0E0FFE296
          96FFEFCCCCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCDA8A8FFD0A8A8FFFFE1E1FFFFDF
          DFFFFFE0E0FFFFE3E3FFFFECECFFDEC7C7FF776666AD0000000000000000D88C
          8CF5FDF3F3FFFFFFFFFFFFFEFEFFFFF7F7FFFFF1F1FFFFEBEBFFFFE8E8FFFFE3
          E3FFE49C9CFFECBEBEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFF4E8E8FFC79393FFE3C3C3FFFFF0F0FFFFEAEAFFFFE9
          E9FFFFEAEAFFFFEDEDFFFFF5F5FFE1CECEFF796565AD0000000000000000DD8C
          8CF5FCF3F3FFFFFFFFFFFFFEFEFFFFFEFEFFFFF7F7FFFFF2F2FFFFEEEEFFFFED
          EDFFFFF1F1FFE7A4A7FFE5A4A5FFFDF8F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFDFBFBFFE0B8B8FFCD9696FFF9F3F3FFFFFFFFFFFFF7F7FFFFF4F4FFFFF4
          F4FFFFF5F5FFFFF8F8FFFFFFFFFFE1D2D2FF7B6565AD0000000000000000E08C
          8CF5FDF3F3FFFFFFFFFFFFFFFFFFFFFEFEFFFFFEFEFFFFFBFBFFFFFAFAFFFFF2
          F2FFEAB2B8FFAD8F79FFE4C7C3FFE29394FFECBBBBFFF5DFDFFFF2D8D8FFE4B6
          B6FFD79797FFD9BDBDFFDA9E9EFFE4B2B2FFFDF8F8FFFFFFFFFFFFFFFFFFFFFE
          FEFFFFFFFFFFFFFEFEFFFFFFFFFFE4D1D1FF7D6565AD0000000000000000E18C
          8CF5FCF3F3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7D5DAFFE496
          9FFF99CB98FF17C638FF99D39AFFFAF6FCFFB19393FFCA9797FFE1B5B5FFD7C1
          C1FF8F9191FF919595FFD7DCDCFFD6BABAFFD79091FFECC4C7FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFE4D1D1FF7F6565AD0000000000000000E58C
          8CF5FDF3F3FFFFFFFFFFFFFFFFFFFFFFFFFFFCF0F0FFEBA3A7FFA09168FF0A9C
          08FF50F587FF58F68DFF1CA119FFFFF8FFFFC7C8C9FFEAEFEFFFD3D7D7FF7578
          78FFD5D6D6FFC5C5C5FFA3A4A4FFD4D7D7FFD1D0D4FF899761FFE0959EFFF3D6
          DAFFFFFFFFFFFFFFFFFFFFFFFFFFE8D5D5FF826464AD0000000000000000E88C
          8CF5FFF7F7FFFFFFFFFFFFFFFFFFF3BFBFFFE39393FFE0C3CCFF3EAF43FF0096
          00FF06A009FF62FC99FF19BD32FFA1CF9EFFF4EEF4FFEDEDEDFF828282FFE6E6
          E6FFE5E5E5FF808080FFCFCFCFFFCECECEFFD6D3D6FF8CBE8FFF16AB21FFB3A6
          90FFE49FA7FFF9EAECFFFFFFFFFFEAD6D6FF846464AD0000000000000000EA8D
          8DF5FFFEFEFFFCDCDCFFF19494FFDFADADFFD2D5D5FFD9D7DCFF97C497FF0096
          00FF009600FF12AB1BFF60FB99FF029B04FFEBE8EAFFEFEDEFFF8B8B8BFFBABA
          BAFF7A7A7AFFAAAAAAFF7E7E7EFF8F8F8FFFA8A8A8FFE0D2E0FF149D14FF34E0
          6EFF64CA7EFFC5978EFFEBB7BFFFE9CCCEFF876666AD0000000000000000ED91
          91F5FBA7A7FFEC9D9DFFD3C9C9FFD1D4D4FFD2D3D3FFD7D5D7FFE0D8E0FF0097
          00FF049F07FF0CA514FF21BA33FF43E271FF30A62DFFFAEDFAFFE4E3E4FFBBBB
          BBFFC1C1C1FF868686FFDFDFDFFFD2D2D2FF898989FFD8D2D8FF7FB77CFF1BBD
          3AFF30CF5DFF24CD53FF5A9B45FFD49596FF90686EAD0000000000000000DB87
          87E1E4AEAEFFCAD6D6FFD0D2D2FFD1D1D1FFD3D3D3FFD4D4D4FFE5DBE5FF36A8
          34FF18B528FF15AE23FF0DA614FF31CB50FF27C947FF5AB455FFF7E9F7FFE9E8
          E9FF878787FFE7E7E7FFCFCFCFFF747474FFCBCBCBFFD1CFD1FFC7C9C6FF00A3
          08FF2DC753FF2BC54EFF28CB53FF009A00FF2E41236D00000000000000002A1B
          1B2BD78989E4D9BEBEFFCFD4D4FFD2D3D3FFD3D3D3FFD5D5D5FFDED9DEFF87BF
          85FF17B82DFF08A10CFF40D966FF009700FF42DB6BFF18BC31FF5EB45AFFF8EA
          F7FFC0BDC0FF868686FF858585FFD1D1D1FFD5D5D5FFCFCFCFFFDFD1DFFF08A0
          0CFF3BD56BFF22BB3BFF26C046FF2CC856FF008600E400000000000000000000
          000021161621CD8080D9DDB7B7FFD0D8D8FFD4D5D5FFD5D5D5FFDAD8DAFFD8D9
          D7FF009700FF41DA6BFF069F08FF4DE680FF009200FF4DE67EFF1BBE35FF3FA9
          3AFFEFE5EEFFEAE5EAFFE0DFE0FFD8D8D8FFD4D4D4FFD2D2D2FFE5D6E4FF0B9E
          0BFF45DF7EFF34CD5FFF2AC34EFF0AA312FE005A008D00000000000000000000
          000000000000130D0D13B57474C1E2AEAEFFD3D9D9FFD6D7D7FFD7D7D7FFEBDF
          EBFF22A01FFF3FDB6CFF0DA617FF34CD56FF3CD564FF009500FF52EB89FF30CF
          56FF0A9B0AFFAACCA8FFF0E1EFFFE3DCE3FFDDDADDFFE0D8E0FFC9CFC7FF02A6
          0EFF46DF80FF36CF63FF029903F8004300630000000000000000000000000000
          00000000000000000000070505079D65659EEBA6A6FFD7D6D6FFD8DBDBFFE2DC
          E2FF77BB74FF18B82FFF45DE75FF009600FF55EE8EFF2AC347FF059E07FF54ED
          8CFF48E47CFF0DB020FF20A01DFF7EBD7CFFB0CBAEFF9CC499FF129B10FF37D4
          69FF2CC552FF009600FB00460067000000000000000000000000000000000000
          0000000000000000000000000000000000006D4A4A6DE89797F9DDCBCBFFDDE0
          E3FFCCD7CDFF009900FF50E989FF13AC20FF25BE3DFF55EE90FF18B129FF12AB
          1FFF51EA88FF3CD565FF32CE5AFF24C446FF11B528FF17B933FF3FDB74FF21BB
          3BFF007C00D3001F002D00000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000038272738D18383DEE4B6
          B6FFEEE6F3FF119D0FFF32CD5AFF2BC44AFF009500FF3AD362FF35CE5AFF029B
          04FF21BA38FF37D05FFF2FC852FF3BD467FF49E281FF48E182FF14AD23FF0077
          00C70009000E0000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000E09090E9C63
          639CF5A1A8FD6BA959FF18B932FF31CA56FF10A91DFF1CB530FF2DC64DFF29C2
          48FF009800FF26BF42FF28C146FF2AC347FF3FD86EFF09A310FE005A008D0003
          0006000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00003C28293C9B7865CA00A50BFF30C956FF2AC34BFF019A01FF34CD5DFF30C9
          55FF2FC853FF009400FF30C954FF2CC54CFF039B04F800430063000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000001020003008600E227C147FF12AC21FF009800FF11AB20FF22BC
          3DFF019602F60061009A039705F7008E00EA002A003F00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000550084005E009F003000510E11091C007B00D00060
          00A20013001F000000000032004F001600220000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000001
          0102004166AA004B71BD001F2F46000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000003B
          5E8D0382B4FD0078ABFE0071A4FE005A88CD00293E5D001D2C3D000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000354F6E077F
          B1FE16AED9FD0079ADFF007DB0FF007BAFFF177AA4FF446E82FE055D88CF002C
          4460000205070000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000293C52077AACFC1AB0
          DAFF21AED5FE0079AEFF007DB0FF007CB0FF2E89AFFF7E706AFF76675FFF3367
          81FF004367A700141E2A00000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000001D2B390472A3F529B7DDFF1CAC
          D5FF2DB4D8FE007AAFFF007FB2FF007EB2FF2E8BB0FF7C726FFF716B67FF4471
          84FF0078B0FF006DA3FD00527BB90021334B0001010200000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000131C25006A9AE935BDDDFF2BB7DCFF1DAE
          D6FF39BADCFE007CB1FF0081B4FF007FB4FF328EB2FF7B7573FF746D6AFF4873
          85FF007CB3FF007BAEFF007AADFF006FA2FF005888D9003959860030496A0005
          070B000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000A111500628FDA3DBFDDFF3AC1E0FF2DB7DAFF21B1
          D7FF44C1DEFF007EB3FF0083B6FF0081B6FF3791B6FF817874FF78726FFF4A76
          88FF007FB6FF007CAFFF007CAFFF007AADFF0079AEFF3A82A3FE4B6572FE0F62
          89ED002B425B0000000000000000000000000000000000000000000000000000
          00000000000000050709005982C63EBCDAFF49CCE7FF3BC0E0FF31BADCFF24B2
          D8FF51C5E2FF0080B5FF0085B8FF0083B7FF3A94B7FF857D79FF7B7572FF4F79
          89FF0080B8FF007EB1FF007DB0FF007CAFFF0079AEFF3E8CADFF7C6B64FF6F69
          66FF006DA7FD004E76B1001C2937000000000000000000000000000000000000
          000000000000004566893BB5D4FF59D8ECFF48C9E3FF3FC3E0FF35BCDDFF27B4
          DAFF5ACBE4FF0081B7FF0087BAFF0085B9FF3D97BBFF8A7F7CFF7F7976FF527B
          8CFF0082BAFF0080B3FF007FB2FF007EB1FF007DB1FF318CB1FF7E746EFF756C
          67FF007CB6FF0078ABFF006295DB000000000000000000000000000000000000
          000000000000005983B063DDEEFF57D3E8FF4CCCE4FF43C6E1FF39BFDEFF2AB7
          DBFF65CFE6FF0085BBFF0089BCFF0087BBFF409BBCFF8B827FFF827C79FF557F
          90FF0084BCFF0082B5FF0081B4FF0080B3FF007FB2FF248AB3FF877B76FF7E6E
          68FF007CB3FF007CAFFF006CA4F0000000010000000000000000000000000000
          000000000000006998CA6FE7F4FF59D4EAFF4FCEE6FF47C8E3FF3DC2E0FF2EBB
          DCFF70D4E8FF0086BCFF008CBFFF008ABFFF459EC0FF8C8582FF86807DFF5A81
          91FF0085BEFF0084B7FF0083B6FF0082B5FF0081B4FF1789B6FF90837EFF8072
          6BFF027CAEFF007DB1FF006D9FFC0006080C0000000000000000000000000000
          000000000000027FB2E375EAF6FF5DD7EAFF53D1E7FF4BCBE4FF42C5E1FF31BC
          DEFF7AD7EAFF0087BEFF008EC1FF008BC0FF48A1C1FF928885FF898380FF5D84
          93FF0087C0FF0086B9FF0085B8FF0084B7FF0083B6FF0B87B9FF9A8C86FF8375
          70FF0F7DABFF0081B5FF006EA1FF000D14210000000000000000000000000000
          0000000203050E8FBEF777EAF5FF61D9EBFF57D3E8FF4ECDE5FF46C7E2FF35BF
          DFFF83DCECFF0089C0FF0090C3FF008DC2FF4DA6C4FF958C8AFF8D8785FF5F87
          97FF0089C2FF0088BBFF0087BAFF0086B9FF0085B8FF0087BBFFA4958EFF8679
          74FF1B7FA7FF0082B7FF0072A5FF001622380000000000000000000000000000
          0000000C11181E9DC6FE7AECF6FF65DCEDFF5BD6E9FF52D0E6FF49CAE4FF38C2
          DFFF8DDEEEFF008BC2FF0092C5FF008FC4FF50A8C8FF9B918CFF908A87FF658A
          98FF008DC5FF008CC0FF0089BFFF0089BEFF0087BBFF0087BEFFAA9B97FF897D
          79FF2881A4FF0084B9FF0075A8FF002030500000000000000000000000000000
          0000001822312EACD0FF7DEEF6FF69DFEEFF5FD8EBFF56D2E8FF4DCCE5FF3AC3
          E1FF91DFEFFF008DC5FF0094C7FF0091C6FF56ACC9FF9B928FFF948E8CFF688D
          9BFF008EC7FF008DC3FF48869CFF1483ACFF008BC0FF0087BFFFACA29EFF8D82
          7EFF3784A2FF0086BCFF007AADFF00283C670000000000000000000000000000
          00000026364B3FB9D7FF7FEEF6FF6DE1EFFF63DBECFF5AD5E9FF4CCEE6FF4BCB
          E6FFC4F4FAFF1BA5D2FF008FC7FF008DC7FF53ABC9FF9E9290FF97918EFF6C90
          9EFF0090C9FF008FC7FFA38B83FF866B61FF1087B3FF0088C2FFA7A6A8FF8F84
          80FF4587A0FF0087BEFF0081B4FF0030497E0000000000000000000000000000
          00000033486451C9E2FF82F0F8FF71E4F1FF67DEEEFF5AD8EAFF8AE5F2FFA3EF
          F9FF5CDEF2FF7DD9E9FFA2FDFFFF7CE5F7FF9CE0EDFFBAB2AEFFA5938FFF738E
          99FF008EC7FF0090C9FFAA9B97FF8A7C76FF198AB2FF008CC6FFA0ABAFFF9388
          84FF558A9FFF0088C0FF0086B9FF003A58960000000000000000000000000000
          000000405B7E66DAE9FF84F3F8FF74E7F3FF77E9F4FF9BE8F4FF43C6E7FF189C
          C6FF003A6DFF001F57FF003167FF0B5C8BFF1985AEFF41BBDAFF75E9FAFF80DB
          ECFF44C4E5FF18AAD7FFB9A9A5FF9C837BFF2A8BAFFF008BC5FF99AEB7FF978C
          89FF658D9CFF008AC2FF008DC0FF004365AD0000000000000000000000000000
          0000004D70977AEAF4FF8CFAFCFF92F2F8FE4DBADEFE0090C8FF005B8EFF0030
          66FF003C6FFF003F72FF003E71FF003B6FFF00366AFF003268FF003269FF0052
          85FF0C75A3FF229FC7FF49C8E6FF6ECBDDFF41B4D5FE0AA0D1FE9AB5BEFFA690
          88FF7D9198FF008DC4FF008FC2FF004E76C40000000000000000000000000000
          0000005D84B19CFEFEFE67C9DDFD007DB1FE00669CFF003F73FF004174FF0046
          79FF00477AFF00477AFF00477AFF00487BFF00487BFF00497CFF00497CFF0046
          79FF004276FF004E83FF00457BFF005288FF006B9DFF0281B4FE1FA4CEFE49B0
          CEFE5AA5BCFE0094C9FE0094C7FE005D89DB0000000000000000000000000000
          000000739CCC4DB2CBFB006B9EFE005488FE003F76FF004177FF004378FF0048
          7DFF004C80FF004F82FF004F82FF004F82FF005083FF005083FF005184FF0051
          84FF005083FF006497FF006194FF005D90FF00578AFF004F82FF00477CFF0052
          87FF007CB1FF0088BCFE007BAFFE005A8BDD0000000000000000000000000000
          00000488B5E47DEFF9FF6CE7F5FF66E4F5FE57D7ECFE42C1DDFF31A9CCFF208D
          B5FF005E93FF00598CFF005487FF005487FF00558BFF00568BFF00598CFF0059
          8CFF005A8DFF00679AFF00699CFF00689BFF00689BFF006B9DFF006A9DFF006A
          9DFE005888D7003758890019263A000101020000000000000000000000000000
          00000696C3F385F2F8FF6DE1EFFF66DCEDFF5ED9EBFF58D5EBFF53D4EBFF40BE
          DDFF0082B7FF0084B7FF0080B3FF0076ABFF4082A3FF1C6D96FF006194FF005C
          91FF005A8DFF005F92FF00578AFF005083FF004B7FFD003A62C500253D76000D
          1628000000000000000000000000000000000000000000000000000000000000
          00000091C2F18FF8FAFE76E8F3FF6EE3F0FF66DDEDFF5ED8EBFF59D7EAFF30B2
          D7FF008FC5FF008EC1FF008BBEFF078FC2FFD2BBB1FFA89D98FFBBA197FF1583
          B0FF007AAEFF006FA2FF006194FF00588BFF005285FD004775E100365FB80030
          509000294067001B293E000A1015000000000000000000000000000000000000
          0000007AABDB96FEFEFE83EFF6FF78E9F3FF70E4F0FF68DEEEFF7BE6F2FF15A7
          D2FF0BA3D0FF069ECEFF0096CBFF64BAD6FFB9AFACFFAAA7A7FFA8A19EFF0088
          C0FF0087BBFF0086B9FF0084B7FF0081B4FF007EB1FF0078AFFFCABFBAFF828D
          96FF3A7A99FF00679CFF006D9FFE006899DD0000000000000000000000000000
          0000005E83A774E4F1FE91FBFCFF81EFF8FF79EAF4FF74E6F1FF74DAECFF32BB
          DEFF31B9DBFF26B4D9FF0EACD7FFD9D8D6FFBFBCBAFFC2B8B5FF62A7BDFF0095
          CDFF0094C7FF0091C4FF008EC1FF008BBEFF0085BBFF3CA0C7FFBFB1ACFFB1A1
          9AFF2D85A8FF0079AEFF0077AAFF00547DC90000000000000000000000000000
          0000002C3A4315ABD6FDA8FEFEFE98FFFFFF8FF7FAFFA1F4F8FF5CD9ECFF55D5
          E9FF4AD0E6FF38C8E4FFBAE2EAFFDCD2D1FFD0CACAFFCAC5C5FF1DB1D8FF19AC
          D6FF15A7D2FF0BA2D0FF049DCDFF0098CBFF008EC7FFC2D1D6FFBEB5B2FFB2B0
          AEFF0087BEFF0089BCFF007BADFE00334B7B0000000000000000000000000000
          00000000000000516E730BA0CAF347C6E2FF5ACBE5FF4FD1E7FFA6F2F6FDB1F9
          FAFEB9F6FAFFF7FAFAFFFDECE7FFF2E4E1FFEAE1DDFF63D5E7FF46CDE7FF3EC5
          E2FF2FBDDDFF26B6DBFF17B0D7FF0FABD6FFAFD9E5FFE0D2CEFFDECAC6FF33A5
          CAFF0098CFFF0091C3FE006291E200080B100000000000000000000000000000
          000000000000000000000003060600131A1D00222F350033454E0078A5BC55BB
          DFFD96D0E7FFA8D5E6FFB5DAE5FF76BFD9FD12A3D0F11EA7D3FB28ABCFFE82D6
          E7FEB8F2F8FEB0EDF5FED2F3F8FFFFFFFBFFFFF2EAFFF5E9E3FF6FCBE0FF19B5
          DDFF0D93C2FF006594E30016232D000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000000B
          0E110019232C002838490031465D00141D22000000010005080A00121B25003D
          597E127095CB4691AFDC3F93B5E93C96BCF63790B6F4006D9CE4006B98E00052
          79BF0032497400080B0F00000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000204060033486D005880C20067
          94E000638ED700587EC1004E71AC00456499003D58880038517E00364F7A0037
          507C003A5584003E5B8F0043629C004668A5004564A200375182001A273A0000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000080C0F005F85C50077AAFF0079ACFF007A
          ADFF007BAEFF007BAEFF007BAEFF007AADFF0079ACFF0078ABFF0077AAFF0075
          A8FF0074A7FF0072A5FF0070A3FF006EA1FF006B9EFF00699CFF006C9FFE0050
          77B300070B0F0000000000000000000000000000000000000000000000000000
          000000000000000000000000000000557AA70079ACFF007CAFFF007EB1FF0080
          B3FF0081B4FF0082B5FF0084B7FF0084B7FF0082B5FF0082B5FF007FB2FF007D
          B0FF007CAFFF0078ABFF0075A8FF0072A5FF006EA1FF006A9DFF00679AFF0068
          9BFF005279B60000000100000000000000000000000000000000000000000000
          000000000000000000000019232F007BAEFE007EB1FF0081B4FF0084B7FF0086
          B9FF0087BAFF0088BBFF0089BCFF0089BCFF0088BBFF0087BAFF0085B8FF0083
          B6FF0080B3FF007DB0FF007AADFF0076A9FF0072A5FF006EA1FF006A9DFF0066
          99FF006B9EFE001F2E4600000000000000000000000000000000000000000000
          0000000000000000000000425D87007EB1FF0083B6FF0086B9FF0089BCFF008B
          BEFF008DC0FF008EC1FF008FC2FF008FC2FF008EC1FF008DC0FF008BBEFF0088
          BBFF0085B8FF0082B5FF007EB1FF007BAEFF0076A9FF0072A5FF006EA1FF0069
          9CFF00689BFF0042619D00000000000000000000000000000000000000000000
          00000000000000000000006087C20083B6FF0088BBFF008CBFFF008FC2FF0091
          C4FF0093C6FF0094C7FF0095C8FF0095C8FF0094C7FF0093C6FF0090C3FF008E
          C1FF008BBEFF0087BAFF0083B6FF007FB2FF007AADFF0076A9FF0071A4FF006C
          9FFF00699CFF005780CF00000000000000000000000000000000000000000000
          0000000000000000000000719EE10089BCFF008EC1FF0090C3FF0094C7FF0097
          CAFF039ACCFF099CCEFF0C9DCFFF0B9DCFFF089CCEFF0299CCFF0096C9FF0093
          C6FF008FC2FF008CBFFF0087BAFF0083B6FF007EB1FF0079ACFF0074A7FF0070
          A3FF006B9EFF005F8CE100000000000000000000000000000000000000000000
          000000000000000000000077A7EC008DC0FF0091C4FF0095C8FF059ACCFF109F
          D1FF1BA4D4FF22A7D6FF25A8D7FF26A8D7FF20A6D6FF18A3D3FF0D9ECFFF0199
          CBFF0094C7FF0090C3FF008BBEFF0086B9FF0081B4FF007CAFFF0077AAFF0072
          A5FF006DA0FF005F8CE100000000000000000000000000000000000000000000
          000000000000000000000075A1E30090C3FF0095C8FF079BCDFF17A2D3FF27AA
          D9FF32AFDBFF3CB1DEFF40B4DFFF3EB4DFFF3AB0DFFF30ACDAFF23A7D6FF12A0
          D1FF0299CCFF0094C7FF008FC2FF008ABDFF0085B8FF007FB2FF007AADFF0075
          A8FF0070A3FF005983CE00000000000000000000000000000000000000000000
          00000000000000000000006990C90092C5FF049ACCFF17A2D3FF2BAAD9FF3CB1
          DEFF4AB7E3FF53BDE6FF58BDE9FF57BDE7FF52BCE5FF46B7E3FF37AFDEFF26A8
          D7FF11A0D1FF0198CBFF0092C5FF008DC0FF0087BAFF0082B5FF007CAFFF0077
          AAFF0071A4FF004A6CAA00000000000000000000000000000000000000000000
          000000000000000000000052719C0091C4FF0FA0D0FF27A8D7FF3CB2DEFF4FB9
          E4FF60C0EBFF6CC7EFFF74C8F0FF71C9F1FF69C4EEFF5BC0E8FF4AB7E4FF36B0
          DCFF1FA6D5FF099CCEFF0095C8FF008FC2FF0089BCFF0084B7FF007EB1FF0078
          ABFF0072A5FF00364E7B00000000000000000000000000000000000000000000
          000000000000000000000033465F038FC1FF19A5D6FF32ADDBFF49B8E4FF5FC0
          EBFF73CAF0FF84D0F5FF8ED4F9FF8BD3F9FF7FCFF5FF6EC6EEFF59BFE9FF43B4
          E0FF2AAADAFF13A0D1FF0097CAFF0091C4FF008BBEFF0085B8FF007FB2FF007B
          AEFF0072A5FF001B273D00000000000000000000000000000000000000000000
          00000000000000000000000D12170088BAF921A8D8FF3AB2DFFF53BBE6FF6BC5
          EFFF82D0F5FF98D8FDFF9FDBFFFF9EDBFFFF93D6FBFF7DCDF4FF64C2EBFF4CB8
          E3FF32AFDBFF19A3D3FF0399CCFF0092C5FF008CBFFF0086B9FF0080B3FF007B
          AEFF006A9AEC0003040600000000000000000000000000000000000000000000
          000000000000000000000000000000648BAD189DCEFF40B4E1FF57BCE7FF6FC7
          EFFF8BD3F9FF9EDBFFFF9EDCFFFF9EDCFFFF9BD9FEFF83D0F5FF69C4EEFF4EBB
          E4FF35AFDCFF1CA4D4FF049ACCFF0093C6FF008DC0FF0088BBFF0081B4FF0077
          AAFF00415E860000000000000000000000000000000000000000000000000000
          0000000000000000000000000000002330370190C1FD3EB3E0FF56BDE7FF6DC8
          F0FF88D2F8FF9DDAFEFF9EDCFFFF9DDBFFFF99D8FDFF81CFF4FF67C5ECFF4DB9
          E4FF34B0DCFF1BA4D4FF049ACCFF0093C6FF008EC1FF0087BAFF007FB1FF0065
          93DD00070A0E0000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000005D7F9C159BCCFF53BDE7FF67C4
          EDFF7BCDF4FF8ED5FAFF99D9FDFF98D8FDFF8AD3F8FF75C9F2FF5FC1EBFF48B6
          E2FF30ACDAFF16A2D2FF0198CBFF0092C5FF008DC0FF0082B5FF0070A0F00019
          2530000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000060809006C91BF169CCCFF59BE
          E9FF6CC7EFFF79CAF3FF80CFF4FF7FCEF4FF74CAF2FF65C2EDFF52BCE5FF3DB3
          DEFF25A8D7FF0E9ED0FF0096C9FF0092C5FF0084B7FF00709DE8001E2B370000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000507070055728E0090
          C3FB45B5E0FF63C4EDFF67C3EDFF65C2EDFF5CBFE9FF51BAE5FF41B3E0FF2EAB
          DBFF18A3D3FF049ACDFF0094C7FF0083B6FF00618BCA00111820000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000029
          38410084B4ED3AAFDCFF4DB9E4FF4CB9E3FF46B7E1FF3BB2DEFF2DACDAFF1DA5
          D4FF099DCFFF0095C8FF0080B3FE004C6C900004050600000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000002A3B430191C2FD34AFDDFF31ACDAFF2CA9D9FF22A4D5FF159FD1FF069A
          CDFF0094C8FF007FB1F900354A5C000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000638BB016A6D4FF2BC1EDFF2AC9F4FF27C9F4FF24C5F0FF18B5
          E4FF0083B8FE0030456000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000598E919180E6FEFE4BD7FBFF36D2FAFF31D0F8FF3AD4FAFF5CDB
          F8FB8BE4F7F71E26262600000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000093BABABA7BE6FEFE44C7EDFF2DB0DAFE29A8D3FE31ACD5FF59CC
          ECFF8EEAF8F8212C2C2C00000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000008E9393930C81B1FF0091C7FF0088BCFF007FB3FF0076AAFF0063
          99FF4386A4DB2023232300000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000025374A0083B6FF0096C9FF008BBEFF0082B5FF007AADFF0071
          A4FF006498FE004670BE00172434000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000050708006D97D30D99CBFF0096C9FF008CBFFF0083B6FF0079ACFF0071
          A4FF00699CFF006699FF006798FC004163970004050700000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000052708B1497C7FF1BA6D6FF008DC0FF0080B3FF007AADFF0076A9FF0072
          A5FF006B9EFF006699FF006699FF006699FF0043679D00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000001E
          2A2F0893C7FC2BA8D7FF008BBFFF007AADFF0071A4FF0076A9FF007CAFFF007D
          B0FF0078ABFF006B9EFF006699FF006699FF005784C900000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000046
          5E6E0297C7FE007A99C9005074B0006296F6006EA1FF0075A8FF007CAFFF0080
          B3FF0085B8FE006A91B7001B2737001621320002040500000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000000A
          0E10002A33420000010100000000000C121C003E5B91006391E00070A0F1005B
          80BB0028384B0000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000B0B0B154747478D747474EC6F6F6FE74D4D4D9F1F1F1F3D000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000808080E4747
          477F7C7C7CF1909090FFA2A2A2FF989898FE8D8D8DFF808080FE6D6D6DD53A3A
          3A700A0A0A140000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000005050508404040727C7C7CEA9494
          94FFA9A9A9FFAAAAAAFF8D8D8DFF7D7D7DFE939393FF919191FF8E8E8EFF8585
          85FF777777F6525252A52020203F000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000020202043A3A3A64797979E2979797FFB0B0B0FFB2B2
          B2FF8E8E8EFF616161FF7B7B7BFF848484FF636363FF656565FF444444FF5959
          59FF7D7D7DFF888888FF7C7C7CFE696969D7373737730A0A0A14000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000101010234343456777777D8999999FEB5B5B5FFB7B7B7FF909090FF6666
          66FF868686FFC1C1C1FFDBDBDBFFB3B3B3FFADADADFF939393FF5C5C5CFF2B2B
          2BFF313131FF424242FF646464FF7F7F7FFF7D7D7DFF707070F74D4D4DA62020
          2041000000010000000000000000000000000000000000000000000000000000
          0000737373BE9B9B9BFEBABABAFFBDBDBDFF939393FF6E6E6EFF979797FFCFCF
          CFFFDDDDDDFFD6D6D6FFD4D4D4FFB1B1B1FFACACACFFB2B2B2FF757575FF4C4C
          4CFF2D2D2DFF2B2B2BFF2E2E2EFF313131FF4C4C4CFF6A6A6AFF7A7A7AFF7373
          73FE646464D9343434750B0B0B16000000000000000000000000000000000202
          0204909090F6C2C2C2FF969696FF787878FFA7A7A7FFDBDBDBFFE0E0E0FFDCDC
          DCFFD7D7D7FFD5D5D5FFD6D6D6FFB1B1B1FFB0B0B0FFB1B1B1FFB1B1B1FF8B8B
          8BFF6B6B6BFF515151FF3C3C3CFF2A2A2AFF292929FF2C2C2CFF373737FF5353
          53FF6D6D6DFF727272FF696969F7414141880000000000000000000000002424
          2440888888FE878787FFB7B7B7FFE4E4E4FFE5E5E5FFE0E0E0FFDCDCDCFFDBDB
          DBFFD9D9D9FFD7D7D7FFD7D7D7FFB2B2B2FFB3B3B3FFB2B2B2FFB3B3B3FFB4B5
          B5FFB6B7B7FFA0A1A1FF828383FF676767FF505050FF3C3C3CFF292929FF2929
          29FF2C2C2CFF3C3C3CFF656565FF636363E40000000000000000000000008383
          83EAC6C6C6FFEBEBEBFFE9E9E9FFE4E4E4FFE1E1E1FFE0E0E0FFDEDEDEFFDDDD
          DDFFDBDBDBFFD9D9D9FFD3D3D3FFB7B7B7FFB7B7B7FFB6B6B6FFB6B7B7FFB5B8
          BBFFB4B8BEFFB5B6BAFFB7BBC1FFB6BDC5FF9DA3A7FF818384FF676868FF4F4F
          4FFF393939FF303030FF666666FF626262FD3232327300000000000000008282
          82E6EBEBEBFFE9E9E9FFE6E6E6FFE5E5E5FFE4E4E4FFE2E2E2FFE1E1E1FFDFDF
          DFFFDDDDDDFFDDDDDDFFCFCFCFFFBABABAFFBBBBBBFFBABABAFFB9BCBFFFC2A9
          8CFFD67B14FFD77B11FFD4740AFFCC7A1FFFC69059FFBBB4ADFFB8BDC3FF9F9F
          A0FF808080FF6F6F6FFF9E9E9EFFA4A4A4FF595959E600000000000000007C7C
          7CD6E6E6E6FFECECECFFE9E9E9FFE7E7E7FFE6E6E6FFE4E4E4FFE3E3E3FFE1E1
          E1FFDFDFDFFFDEDEDEFFCACACAFFBFBFBFFFBEBEBEFFBEBEC0FFBEC0C3FFD581
          1EFFE8AC5FFFE9A95AFFE7A858FFE39F47FFDB8A29FFD16A00FFC29465FFB8BE
          C3FFBBBBBBFFBCBCBCFFB9B9B9FFB3B3B3FF505050D800000000000000006F6F
          6FB6DDDDDDFFEEEEEEFFEBEBEBFFEAEAEAFFE8E8E8FFE6E6E6FFE4E4E4FFE2E2
          E2FFE0E0E0FFE0E0E0FFC5C5C5FFC3C3C3FFC2C2C2FFC2C5CBFFCCA574FFE29A
          43FFEBB46DFFE7A858FFE6A655FFE4A454FFE4A651FFE4A34EFFD36D00FFBEB2
          A6FFBCBDBDFFC0BDBAFFBCBBBAFFAAAAAAFF464646BA00000000000000005656
          568AD0D0D0FFF3F3F3FFEEEEEEFFECECECFFEAEAEAFFE8E8E8FFE6E6E6FFE4E4
          E4FFE4E4E4FFD9D9D9FFC7C7C7FFC7C7C7FFC6C7C8FFC7C7C9FFD78521FFEEBB
          7CFFEBAE64FFE8AA5BFFE6A858FFE5A654FFE4A450FFE5A552FFD77D17FFC6AD
          92FFB1B7BDFF79B6EEFFCBC7C5FF9A9A99FF3838389100000000000000003232
          324CBBBBBBFFF7F7F7FFF0F0F0FFEEEEEEFFECECECFFEAEAEAFFE8E8E8FFE5E5
          E5FFE5E5E5FFD0D0D0FFCBCBCBFFCACACAFFCACED4FFD2A771FFE4A14EFFEFBD
          7EFFEAAD62FFE9AB5EFFE7A95AFFE6A756FFE5A553FFE4A654FFD77A11FFC0AD
          9CFF5BA3DAFF36AEFFFFB8C4CDFF868584FF2222225400000000000000000606
          06099E9E9EEDF5F5F5FFF3F3F3FFF0F0F0FFEEEEEEFFEBEBEBFFE9E9E9FFE7E7
          E7FFE0E0E0FFD2D2D2FFD1D1D1FFD0D2D5FFD1C9C0FFDC8E2AFFF1C085FFEDB5
          70FFEBAE64FFE9AC60FFE8AA5CFFE7A858FFE5A656FFE5A552FFD57711FFAFAE
          B1FF4CA5E1FF51B4FAFFC4BEBAFF6A6A6AF50606060F00000000000000000000
          00006565658ACFCFCFFFFAFAFAFFF3F3F3FFEFEFEFFFECECECFFEBEBEBFFE7E7
          E7FFDADADAFFD8D8D8FFD7D8DAFFD6D8DDFFDA9842FFEEB470FFF2BF82FFEDB2
          6BFFECB066FFEAAE62FFE9AB5EFFE7A95AFFE6A858FFE0983DFFD19652FFCDD1
          D6FF7E8A91FFA8AAADFFA8A6A5FF4B4B4B9C0000000000000000000000000000
          00000E0E0E119C9C9CE2E6E6E6FDF9F9F9FFF3F3F3FFF0F0F0FFEBEBEBFFE1E1
          E1FFDFDFDFFFDEDFE1FFDDE2E8FFDEA75FFFE8AC5DFFF4C58EFFF0B874FFEEB3
          6CFFECB168FFEBAF64FFE9AC60FFE8AA5DFFE9AB5DFFD9821BFFD1C0ADFFD0D2
          D5FFD5D4D3FFD1D1D0FF777776F5111111210000000000000000000000000000
          00000000000027272730A2A2A2E4CACACAFCD6D6D7FFD8D8D9FFDDDEDFFFE4E5
          E7FFE7EAEEFFE4E3E3FFE4AE67FFEAAE63FFF7CA97FFF2BC7DFFF0B672FFEEB4
          6EFFEDB26AFFEBAF65FFEAAD61FFEAAD5FFFE39E47FFD79444FFD6DDE5FFD7D8
          D8FFDADADAFF929292FE3E3E3E6F000000000000000000000000000000000000
          000000000000000000000D0D0D106667679DB4B3AFFFCAC5BFFFBDB5ACFFBEAC
          99FFD3B28AFFECAF63FFF4C083FFFACD9EFFF4BF82FFF2B977FFF0B773FFEFB5
          6FFFEDB26BFFECB067FFEBAF66FFEAAB5BFFDA8824FFDFD8D1FFE2E4E5FFDBDB
          DBFF999999FE5858589600000000000000000000000000000000000000000000
          00000000000000000000000000005B5B5C9DD9D1C6FFFFFAE6FFFFEED3FFFABD
          78FFF4B770FFF5C48CFFF6C289FFF5BC7CFFF4BB7BFFF3BC7BFFF3BB78FFF0B7
          74FFF0B670FFEEB46EFFE9AB5EFFDE912DFFC4AC8EFFC7CCD0FFB1B1B1FF8686
          86F04444446E0000000000000000000000000000000000000000000000000000
          00000000000000000000000000007F7F80D9F9EFDFFFFFF5E5FFFFF4E4FFFFF1
          DDFFFBDEBBFFF7CF9EFFF3C286FFEDB66EFFE8AA59FFE3A14AFFE09C40FFE19D
          3EFFE59D3EFFDC9A3FFEBB872FD75F4B2F7655585C8759595A8F3D3D3D620C0C
          0C12000000000000000000000000000000000000000000000000000000000000
          0000000000000000000010101019989899FDFFFEF1FFFFF6E6FFFFF4E4FFFFF4
          E3FFFFF3E1FFFFF3E1FFFFF3DEFFFFF2DDFFFFF2DAFFFFF0D7FFFFEFD0FFCDC1
          AAFF53514E9B0E0A031001000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000034353554B7B5B1FFFFFDF2FFFFF6EBFFFFF5E7FFFFF4
          E4FFFFF2E0FFFFF1DDFFFFEFD9FFFFEED5FFFFEDD2FFFFEBCFFFFFF1D0FFA69F
          99FF29292A4C0000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000005B5B5C91D5D2CDFFFFFCF2FFFFF7ECFFFFF6E9FFFFF4
          E6FFFFF3E2FFFFF2DEFFFFF0DBFFFFEFD7FFFFEDD3FFFFEDCFFFFFF1CFFF7D7F
          81F60707070C0000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000808181CDF9F6F0FFFFFFFBFFFFFEF5FFFFFDF0FFFFFA
          EBFFFFF9E6FFFFF5E3FFFFF3DFFFFFF2DAFFFFEFD6FFFFF0D3FFE4D4BDFF6567
          67BB000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000909090E979798FBB2B1B0FFB7B5B3FFBCBBB9FFC4C0BCFFC9C5
          BEFFD0CAC1FFD8CFC4FFDFD6C7FFE8DBC8FFEFE1CAFFFCEBCFFFBBB3A6FF4141
          4173000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000002020204141414221C1C1C31262727412E2E2E50373737603E3F
          3F6F4647477F4E4F4F8E5454559D5C5C5DAD606163BD696A6BCC737374DB1818
          1829000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000008120918115A19B00F6B14E6096209E60A5A08E8857E
          85FF949494FF9B979AFFA19DA0FFA5A2A5FFAAA6A9FFA9A8A9FFA1A1A1FF9797
          97FF909090FF888888FF808080FF7D797DFF20491FF3055D01E6065A03E6065A
          03E6055A01E60A5A06DF0837077C010101020000000000000000000000000000
          00000000000006110816137926D5179F32FF21BB44FF20BA43FF20AE41FF9C8F
          99FFB2BFB5FF99CAA5FFA6D3B3FFB0DCBCFFB4E7C4FFFFFDFFFFFFFFFFFFF6F6
          F6FFE8E8E8FFDBDBDBFFCFCFCFFFCAC3C9FF2B7640FF28C856FF2BC456FF28C2
          57FF4BCD72FF2AC056FF05770DFF0B3D0B830000000000000000000000000000
          00000D1A10201B8935D31DAA3BFF22BD44FF21BA43FF20BB42FF23B244FF9686
          92FF82B08DFF12BD3BFF1BBE44FF1EC14AFF14C248FFEDE8EBFFF7F6F6FFFDFD
          FDFFF1F1F1FFE3E3E3FFD6D6D6FFD3CCD1FF2D7641FF2ACA57FF2BC558FF27C5
          56FF88E0A3FF30CB61FF2AC359FF0A5F07E90000000000000000000000000000
          00002AA54DE51FB241FF1EB93EFF1EB73FFF1FB83FFF1FB940FF23B240FF9A89
          96FF7BA481FF14B634FF1EB73EFF22BB45FF19BF44FFE0DCDFFFE8E7E8FFF4F4
          F4FFFDFDFDFFF1F1F1FFE5E5E5FFE1DAE0FF2D7641FF28C853FF2AC355FF25C3
          52FF82DC9EFF2DC75CFF2DC95DFF156C10FF0000000000000000000000000000
          00002DBF5BFF1CB63AFF1DB63CFF1DB63CFF1DB63DFF1EB93DFF20AF3FFFA796
          A3FF7EA785FF0EB026FF18B132FF1DB63BFF15BB3CFFD4CDD3FFDBDADAFFE6E6
          E6FFF4F4F4FFFDFDFDFFF3F3F3FFF1EAEFFF2F7840FF27C751FF29C253FF24C2
          50FF83DD9DFF2CC65AFF2BC75CFF146C0FFF0000000000000000000000000000
          000034CA64FF1CB536FF1CB539FF1CB53AFF1CB53AFF1CB53BFF20AE3DFFB3A3
          B0FF86B08AFF05A816FF13AC27FF18B132FF12B735FFC5C1C5FFCECDCDFFD9D9
          D9FFE6E6E6FFF3F3F3FFFDFDFDFFFFF9FEFF2E7741FF26C64FFF28C151FF23C1
          4EFF84DC9DFF2DC559FF2AC85AFF146C10FF0000000000000000000000000000
          000035CE69FF19B234FF1AB337FF1BB437FF1BB438FF1BB438FF1FAE39FFC0AF
          BEFF8FB990FF00A005FF0EA81CFF14AE2AFF10B42FFFB8B4B7FFC1C0C0FFCDCD
          CDFFD9D9D9FFE5E5E5FFF2F2F2FFFFFFFFFF2F7840FF25C54EFF27C04FFF22C0
          4CFF82DB9AFF2BC557FF2BC657FF146C10FF0000000000000000000000000000
          000035CE69FF17B030FF19B234FF19B234FF1AB335FF1AB336FF1CAC37FFC9B8
          C7FF99C19AFF059D0BFF16A722FF1BAD30FF1AB436FFA8A6A8FFB4B3B4FFBFBF
          BFFFCCCCCCFFD8D8D8FFE5E5E5FFFFFAFFFF2F7B42FF24C64DFF26C24FFF21C1
          4DFF85DC9CFF2BC455FF29C557FF146C10FF0000000000000000000000000000
          000035CE69FF16AF2FFF18B132FF18B132FF18B133FF19B333FF1DAB35FFD7C4
          D4FFEEE3EDFFE7D4E4FFD7C4D5FFC8B5C5FFB6A4B2FFA39BA1FFACA5ABFFBAB3
          B8FFC9C2C7FFD6CFD4FFE3DCE2FFFEF1FBFF306B3EFF1DA83FFF20A442FF1EA2
          40FF5ACF79FF2AC255FF28C354FF146C10FF0000000000000000000000000000
          000035CD6AFF16AF2BFF17B02FFF17B030FF17B030FF17B031FF1BAD34FF5796
          62FF569C63FF5A9F66FF5CA067FF599F66FF559B63FF51975FFF4C915AFF488C
          56FF438851FF3C834DFF387E48FF377A46FF288A40FF1E9F3DFF1F9C3FFF209B
          3FFF24BC4DFF28C251FF27C453FF146C10FF0000000000000000000000000000
          000035CD68FF13AC2AFF15AE2DFF16AF2DFF16AF2EFF16AF2EFF17B12FFF13B2
          2DFF13B32DFF12B32EFF14B431FF15B632FF15B533FF17B735FF19B838FF1ABA
          39FF1BBB3CFF1CBD3EFF1EBE41FF20BF43FF22BF45FF23BF48FF24C04AFF25C1
          4CFF26C04DFF27C04FFF28C253FF146C11FF0000000000000000000000000000
          000035CD69FF12AB25FF14AD2AFF14AD2BFF15AE2BFF15AE2CFF15AE2DFF16AF
          2EFF17B02FFF17B030FF18B132FF18B133FF19B234FF1AB336FF1BB438FF1CB5
          39FF1DB63BFF1EB73DFF1FB83FFF20B941FF21BA43FF22BB45FF23BC47FF24BD
          49FF25BE4BFF26BF4FFF26C150FF146C11FF0000000000000000000000000000
          000035CD69FF11AA24FF13AC28FF13AC28FF0FAC26FF0CAD22FF0BAD22FF0CAE
          25FF0CAE25FF0DAF26FF0EB027FF10B22AFF0FB12BFF10B22EFF11B330FF13B5
          32FF14B633FF15B735FF16B837FF18BA39FF19BB3BFF1ABC3FFF1CBD42FF20BD
          46FF24BD4AFF25BE4CFF25C24FFF156C11FF0000000000000000000000000000
          000035CD69FF10A920FF12AB25FF0FAB23FF44AC51FF82AC88FF7CAC82FF7BAB
          83FF7DAB82FF7CAD84FF7CAB83FF7BAB83FF7BAB83FF7BAA83FF79AA82FF7AA9
          82FF78A982FF77A881FF76A781FF75A680FF74A57FFF74A47FFF78A381FF49B1
          62FF22BF48FF26BF4BFF26C04EFF156C11FF0000000000000000000000000000
          000035CD69FF0DA61EFF10A923FF0BAA1EFF5CAD66FFCFC3CDFFDDD8DDFFDBD6
          DAFFDDD8DBFFDCD7DBFFDCD7DBFFDDD8DBFFDBD6DAFFDAD5D9FFD9D5D8FFD7D2
          D6FFD4D0D4FFD2CDD2FFD0CBD0FFCEC9CDFFCCC8CCFFCBC6C9FFBAAFB7FF5BAB
          6EFF1FBD44FF24BD4AFF24BF4DFF156C11FF0000000000000000000000000000
          000035CD69FF0CA51AFF0FA820FF09A81CFF59AB64FFD5CED5FFE9E9E9FFE9E9
          E9FFE9E9E9FFECECECFFECECECFFEDEDEDFFEBEBEBFFEAEAEAFFE7E7E7FFE7E7
          E7FFE4E4E4FFE2E2E2FFE0E0E0FFDDDDDDFFDBDBDBFFDADADAFFC1B9BFFF5AAA
          6BFF1DBC43FF25BE49FF25C04CFF156C11FF0000000000000000000000000000
          000035CD69FF0BA419FF0EA71DFF07A718FF5AAC63FFD7CED5FFECECECFFEAEA
          EAFFEEEEEEFFD0D0D0FFCECECEFFCECECEFFCECECEFFCECECEFFCECECEFFCFCF
          CFFFCDCDCDFFCECECEFFCDCDCDFFDCDCDCFFDADADAFFDADADAFFC0BABEFF59AC
          6BFF1EBD42FF23BC48FF23BE4AFF156C11FF0000000000000000000000000000
          000035CD6BFF0BA415FF0DA61BFF06A616FF5CAE63FFDAD2D9FFEFEFEFFFEDED
          EDFFF1F1F1FFCCCCCCFFC9C9C9FFCACACAFFCACACAFFCACACAFFCACACAFFCBCB
          CBFFCBCBCBFFCBCBCBFFCACACAFFDFDFDFFFDDDDDDFFDCDCDCFFC3BCC2FF59AB
          6BFF1CBB41FF22BB47FF24BF49FF156C11FF0000000000000000000000000000
          000036CD69FF08A112FF0BA418FF05A513FF5BAD63FFDDD5DCFFF2F2F2FFF0F0
          F0FFF4F4F4FFECECECFFECECECFFEDEDEDFFEBEBEBFFEAEAEAFFE8E8E8FFE6E6
          E6FFE4E4E4FFE2E2E2FFDFDFDFFFE1E1E1FFDDDDDDFFDDDDDDFFC3BDC2FF59AB
          6BFF1DBC40FF22BB46FF22BD48FF156C12FF0000000000000000000000000000
          000034CD69FF07A010FF0AA316FF05A411FF5CAE63FFE0D9E0FFF4F4F4FFF3F3
          F3FFF7F7F7FFE6E6E6FFE6E6E6FFE7E7E7FFE5E5E5FFE4E4E4FFE3E3E3FFE0E0
          E0FFE0E0E0FFDDDDDDFFDADADAFFE3E3E3FFE0E0E0FFDFDFDFFFC4BEC3FF5BAD
          6BFF1BBA3FFF23BC45FF22BD47FF156C12FF0000000000000000000000000000
          000035CE6AFF069F0CFF09A213FF02A20DFF5EB063FFE2DAE2FFF7F7F7FFF6F6
          F6FFFBFBFBFFCCCCCCFFC9C9C9FFC9C9C9FFC9C9C9FFC9C9C9FFCACACAFFCACA
          CAFFCACACAFFCBCBCBFFC9C9C9FFE3E3E3FFE0E0E0FFE0E0E0FFC5BFC4FF5AAC
          6BFF1BBA3DFF21BA44FF23BE48FF156C12FF0000000000000000000000000000
          000035CE6AFF059E0BFF08A111FF00A00BFF5DAF64FFE4DCE4FFF9F9F9FFF9F9
          F9FFFEFEFEFFDBDBDBFFD9D9D9FFDADADAFFD8D8D8FFD7D7D7FFD8D8D8FFD7D7
          D7FFD6D6D6FFD5D5D5FFD3D3D3FFE5E5E5FFE1E1E1FFE0E0E0FFC7C0C6FF5AAC
          6BFF1BBB3EFF21BA43FF21BC46FF156C12FF0000000000000000000000000000
          000035CE6AFF049D07FF07A00FFF009F09FF5FAF62FFE6DFE6FFFBFBFBFFFBFB
          FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFCFCFFF8F8
          F8FFF5F5F5FFEFEFEFFFECECECFFE6E6E6FFE1E1E1FFE1E1E1FFC6C0C5FF5AAC
          6BFF1ABB3DFF22BD44FF21BC46FF166F15FF0000000000000000000000000000
          000035CF6AFF029B05FF059E0CFF009E07FF5EB162FFE9E2E9FFFCFCFCFFFCFC
          FCFFFFFFFFFFDADADAFFD6D6D6FFD6D6D6FFD7D7D7FFD6D6D6FFD5D5D5FFD4D4
          D4FFD3D3D3FFD4D4D4FFD1D1D1FFE5E5E5FFE3E3E3FFE1E1E1FFC8C1C7FF5AAE
          6CFF17A937FF1DAA3CFF21BF46FF1A781DFF0000000000000000000000000000
          000035CD6BFF019A02FF049D0AFF009D05FF5EB063FFE8E1E8FFFCFCFCFFFCFC
          FCFFFFFFFFFFCBCBCBFFC8C8C8FFC9C9C9FFC9C9C9FFC9C9C9FFC9C9C9FFC9C9
          C9FFCACACAFFCACACAFFC9C9C9FFE5E5E5FFE3E3E3FFE1E1E1FFC8C1C6FF5BB0
          6DFF0E7523FF177A2DFF22C047FF1F8327FF0000000000000000000000000000
          000039CA6CF9009901FF039C07FF009C02FF5EB161FFE9E2E9FFFBFBFBFFFBFB
          FBFFFFFFFFFFF4F4F4FFF4F4F4FFF4F4F4FFF2F2F2FFF0F0F0FFECECECFFEBEB
          EBFFE7E7E7FFE5E5E5FFE1E1E1FFE6E6E6FFE1E1E1FFE1E1E1FFC8C1C7FF5BAE
          6CFF13962FFF1B9D38FF20BC44FF187A24E90000000000000000000000000000
          0000278447A222BC45FF019B03FF009900FF5DAF5EFFEAE2E9FFFBFBFBFFFDFC
          FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFDFCFCFFF9F9F9FFF5F5
          F5FFF2F2F2FFEFEFEFFFEBEAEBFFE8E7E8FFE4E3E4FFE3E2E3FFC9C1C8FF5AAD
          6BFF19BB3AFF20BB42FF179E33FF12501C890000000000000000000000000000
          0000060C080E257B43983CC66EF139D06DFF7CCD98FFCAC8C9FFC5C8C6FFC6C9
          C7FFC6CAC7FFC5C9C6FFC2C7C3FFC1C3C2FFBDC2BEFFBCBEBDFFB8BBB9FFB5B8
          B6FFB2B7B3FFAFB3B2FFAEB0AEFFAAADABFFA7ACA8FFA5A9A7FFA8A7A8FF66B2
          7DFF2AB552FF27A046ED165A278B030503070000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000002A2A
          2A57505050B4484848A13F3F3F8B373737762D2D2D612525254C1A1A1A361010
          10210606060C0000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000004040409444444997B7B
          7BFEC6C6C6FFC5C5C5FFB7B7B7FFACACACFFA1A1A1FF979797FF8F8F8FFF8686
          86FF7F7F7FFE7E7875F5A34A00E28F4005CD7E3704B86D2D04A25C27068D4D20
          05783D1F0D62292A2B4C1E1E1E36090909100000000000000000000000000000
          00000000000000000000000000000000000013131329595959D1909090FFC7C7
          C7FFE4E4E4FEEDEDEDFFEBEBEBFFEAEAEAFFE8E8E8FFE7E7E7FFE4E4E4FFE3E3
          E3FFE2E2E3FFD9D6D3FFB55300FFD98A1CFFD27F18FFCB7715FFC56E11FFB95D
          09FF9E4A1AFF9CA1A4FF909090FE4747477E0000000000000000000000000000
          00000000000000000000000000002D2D2D5F696969F3A7A7A7FFC6C6C6FFC1C1
          C1FFE4E4E4FEEEEEEEFFEAEAEAFFE8E8E8FFE6E6E6FFE4E4E4FFE2E2E2FFDFDF
          DFFFDDDEDEFFD9D5D1FFB95700FFE59C31FFE5992FFFE49A2EFFE49A2CFFDA8A
          1FFFA85422FFD3D9DCFFB2B2B2FF4E4E4E8B0000000000000000000000000000
          0000000000000606060C474747A17A7A7AFEB7B7B7FFBFBFBFFFBDBDBDFFBCBC
          BCFFE7E7E7FFF0F0F0FFECECECFFEAEAEAFFE8E8E8FFE6E6E6FFE4E4E4FFE1E1
          E1FFDFE0E0FFDCD8D3FFBC5C00FFEAA540FFE7A13EFFE79F3CFFE69E38FFDA8B
          28FFAB5B26FFCFD5D9FFB3B3B3FE565656980000000000000000000000000000
          00001515152D5A5A5AD68D8D8DFFBCBCBCFFB9B9B9FFB9B9B9FFBABABAFFB9B9
          B9FFE9E9E9FEF2F2F2FFEFEFEFFFECECECFFEAEAEAFFE8E8E8FFE5E5E5FFE3E3
          E3FFE1E2E2FFDDD9D5FFC16100FFD48734FFD17B24FFEAA549FFE9A445FFDD92
          33FFAE5F24FFD0D5D9FFB8B8B8FF5E5E5EA40000000000000000000000000000
          00004C4C4CA8979797FFBABABAFFB6B6B6FFB5B5B5FFB6B6B6FFB7B7B7FFB5B5
          B5FFEDEDEDFEF4F4F4FFF6F6F6FFF5F5F5FFF3F3F3FFF0F0F0FFEEEEEEFFE9E9
          E9FFE4E4E5FFDFDBD7FFC46700FFD78B3FFFD07926FFEDAC56FFEDAA53FFE097
          3CFFB26325FFD2D7DBFFBDBDBDFE656565B10000000000000000000000000000
          00004F4F4FB3A4A4A4FFB4B4B4FFB2B2B2FFB2B2B2FFB2B2B2FFB3B3B3FFB2B2
          B2FFF3F3F3FFFAFAFAFFA4A4A4FF808080FF878787FF8D8D8DFF949494FFA6A6
          A6FFE9E9EAFFE1DED9FFC76A00FFF4B96CFFF3B668FFF0B164FFF0B15FFFE29A
          43FFB76B2AFFD4D9DDFFC3C3C3FF6E6E6EBD0000000000000000000000000000
          0000555555BCA3A3A3FFAFAFAFFFAEAEAEFFAFAFAFFFAFAFAFFFB1B1B1FFAFAF
          AFFFF5F5F5FEFDFDFDFF9C9C9CFFACACACFFBFBFBFFFC0C0C0FFBFBFBFFF9494
          94FFEDEDEEFFE3E0DBFFCA6F00FFF7BC78FFF4B973FFF5B971FFF3B56AFFE59E
          4BFFBA6F2BFFD5DADFFFC8C8C8FE757575CA0000000000000000000000000000
          00005A5A5AC6A3A3A3FFACACACFFABABABFFABABABFFACACACFFADADADFFABAB
          ABFFFAFAFAFEFFFFFFFF959595FFA7A7A7FFB8B8B8FFBCBCBCFFBDBDBDFF9191
          91FFEFF0F0FFE6E2DCFFCE7200FFF9C486FFF9C182FFF8BD7DFFF5BB74FFE7A2
          51FFBD732AFFD7DCE1FFCECECEFF7E7E7ED60000000000000000000000000000
          0000606060CFA4A4A4FFA9A9A9FFA8A8A8FFA8A8A8FFA9A9A9FFABABABFFA9A9
          A9FFFEFEFEFFFFFFFFFF8F8F8FFFA3A3A3FFB2B2B2FFB6B6B6FFB8B8B8FF8C8C
          8CFFF3F3F4FFE8E4DEFFD27900FFFFCD9AFFFECC99FFFCC88EFFFAC382FFE9A6
          57FFC07A31FFDADFE4FFD3D3D3FE868686E30000000000000000000000000000
          0000646464D9A3A3A3FFA6A6A6FFA4A4A4FFA5A6A6FFA6A8A9FFA8ABAEFFA7A6
          A7FEEEF0F1FFFFFFFFFF888888FFA1A1A1FFB1B1B1FFB5B5B5FFB8B8B8FF8A8A
          8AFFF5F5F6FFEAE5DFFFCF7100FFCF7500FFCD7100FFC96E00FFC86A00FFC465
          00FFC57C2BFFDBE0E4FFD9D9D9FF8E8E8EEF0000000000000000000000000000
          00006B6B6BE3A2A2A2FFA1A1A1FFA1A2A3FFA0A5AAFFA69181FFAC5A14FFA94C
          00FED1CCC9FFF5F7F8FF7C7C7CFF6E6E6EFF757575FF7C7C7CFF7F7F7FFF8282
          82FFF6F6F7FFEFEFF0FFEBEDF0FFEAE9EAFFE6E6E7FFE5E3E1FFE1E1DEFFDFDB
          D6FFDDD9D6FFDCDDDEFFDDDDDDFF919191F80202020400000000000000000000
          0000707070ECA1A1A2FF9DA1A6FFA1968EFFAD6929FFB95800FFD98B2AFFD17F
          21FFAC540DFFD4D3D2FFE2E3E5FFECEDEDFFE9E9E9FFE3E3E3FFE0E0E0FFDFDF
          DFFFF4F4F4FFF0F0F0FFEDEDEDFFEBEBECFFE9EAEAFFE8E8E8FFE4E5E5FFE2E3
          E3FFE0E1E1FFDEDEDEFFE0E1E2FF92969AFC0707070C00000000000000000000
          000174787CF4A1A09FFFAD763EFFBB5B00FFD68526FFEBA646FFEAA445FFEBA6
          46FFCD791FFFAE5A17FFD5D8D9FFF2F3F5FFFFFFFFFFFDFDFDFFFBFBFBFFF7F7
          F7FFF4F4F4FFF2F2F2FFF0F0F0FFEDEDEDFFEBEBEBFFE9E9E9FFE6E6E6FFE4E4
          E4FFE2E2E2FFE1E2E3FFE0E5EAFEB7752BFE874200B800000000000000000805
          010C946C41FABE6200FFD3801DFFEAA549FFECA84DFFEBA64DFFEAA64CFFEAA6
          4BFFECA94DFFC9731AFFAF6122FFD8DBDEFFF3F4F5FFFFFFFFFFFBFBFBFFF9F9
          F9FFF6F6F6FFF4F4F4FFF2F2F2FFEFEFEFFFEDEDEDFFEBEBEBFFE9E9E9FFE6E6
          E6FFE5E6E8FFE2E2E2FECE8A2FFEBC5E00FE5F2F007C0000000000000000A95B
          00DCD07B15FFE9A246FFEDAA51FFEDAA52FFECAA53FFECAB54FFECAB56FFECAA
          55FFEDA953FFEFAD52FFC76F17FFB2692FFFDADFE3FFF4F4F5FFFFFFFFFFFBFB
          FBFFF8F8F8FFF6F6F6FFF4F4F4FFF2F2F2FFEFEFEFFFEDEDEDFFEBEBECFFE9EC
          EFFFE4DDD3FFC77613FEB65900FA502600630000000000000000000000006236
          0078CC770FFEECAC54FFEEAC57FFEEAD59FFEEAE5CFFEFAF5DFFEFAF5DFFEEAE
          5CFFEEAD5AFFEDAB56FFEFAE56FFC36811FFB5723DFFDCE1E6FFF6F6F7FFFFFF
          FFFFFCFCFCFFF8F8F8FFF6F6F6FFF4F4F4FFF1F1F1FFEFF0F0FFEFF3F7FFE2D0
          BCFFC06500FFB15700F53D1E004D000000000000000000000000000000000000
          0000713E0084CD7913FEF0B162FFF1B262FFF1B264FFF1B367FFF1B367FFF1B2
          64FFF0B162FFEFAF5EFFEFAE5AFFEFAE57FFBF620AFFB77C4CFFDEE3E9FFF7F7
          F8FFFFFFFFFFFAFAFAFFF8F8F8FFF6F6F6FFF5F5F6FFF4FAFFFFDCBB9AFFB958
          00FFAA5200EC2F16003A00000000000000000000000000000000000000000000
          0000000000007342008FCF7D19FFF4B86EFFF4B76DFFF3B76EFFF3B76EFFF3B6
          6EFFF2B56BFFF1B365FFEFB060FFEFAE5BFFEEAD55FFBB5C04FFBB885EFFDFE5
          EAFFF8F8F9FFFDFDFDFFFAFAFAFFF9F9FAFFFAFFFFFFD19F71FFB35100FFA24D
          00E0200F00290000000000000000000000000000000000000000000000000000
          000000000000010000017745009BD28121FEF7BF7BFFF5BC78FFF5BB77FFF5BA
          75FFF4B871FFF3B66CFFF1B367FFEFB15FFFEEAD59FFECAA51FFB85700FFBD93
          6EFFE1E6EBFFF9FAFAFFFEFFFFFFFDFFFFFFC37E49FFB14D00FF964800D2150A
          001C000000000000000000000000000000000000000000000000000000000000
          0000000000000000000002010003824600A6D6882AFFFAC487FFF9C081FFF7BE
          7EFFF6BD79FFF4B973FFF2B56BFFF0B263FFEEAE5CFFEDAB55FFEAA64AFFB553
          00FFC19D7FFFE4EBF0FFF8F5F3FFB56026FFB04E00FF8A4200C10D0500110000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000003020004884800B0D98F35FFFEC990FFFAC2
          85FFF7BE7FFFF5BB78FFF3B76FFFF1B367FFEFAF5EFFEDAB56FFECA950FFE7A1
          42FFB45200FFBF9676FFA4450CFFAF4E00FF7B3B00AD07020008000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000007030007904D00B9DE9540FFFECB
          95FFFAC388FFF8BF80FFF7BC77FFF5B86FFFF2B566FFF0B25DFFECAA52FFE8A2
          45FFDC8F2FFFB15000FFAF4F00FE703500970201000300000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000904000B975300C2DB8F
          36FFDC943EFFD6882EFFCF7E21FFC97314FFC16A09FFBD6001FDB65800F0A74E
          00DC954600C7853F00B25C2B0076000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000C07000F6637
          007C5A31006F4926005A371D004526140030150B001B06020007000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000100000004000000080000000A000000080000000300000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000100000006000000110000
          001E0000002B0000003A000000400000003A0000002A0000001B0000000E0000
          0004000000010000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000100000008000000170000002F000000520202
          02750B0B0B8D0F0F0F950B0B0B9601010196000000890000006D0000004B0000
          002C000000180000000A00000002000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000060000001700000035040404641D1D1D973C3C3CC85F5F
          5FF9747474FF7B7B7BFF717171FF545454F2313131BF121212A10101019B0000
          0087000000650000003E000000210000000F0000000400000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00010000000D0000002B080808652B2B2BA9585858F18D8D8DFFB8B8B8FFCBCB
          CBFFC1C1C1FFBBBBBBFFBABABAFFB3B3B3FF939393FF727272FF505050EE2828
          28B40909099E00000094000000750000004D0000002A00000013000000060000
          0001000000000000000000000000000000000000000000000000000000010000
          0011030303432828289F5C5C5CF49F9F9FFFDADADAFFDADADAFFCACACAFFBABA
          BAFFB7B7B7FFB6B6B6FFB3B3B3FFB3B3B3FFB1B1B1FFACACACFF9C9C9CFF7B7B
          7BFF5F5F5FFE3C3C3CCD131313A30101019C0000008100000058000000300000
          0017000000070000000100000000000000000000000000000000000000091111
          1156494949DB9A9A9AFFE7E7E7FFE8E8E8FFD9D9D9FFC2C2C2FFBBBBBBFFABAB
          ABFFA5A5A5FFB7B7B7FFB7B7B7FFB3B3B3FFB2B2B2FFAFAFAFFFA9A9A9FFA5A5
          A5FF979797FF7B7B7BFF626262FF464646E5191919A90202029E000000870000
          005E0000003200000017000000060000000100000000000000001111113B5F5F
          5FF1DEDEDEFFF8F8F8FFEBEBEBFFCFCFCFFFBDBDBDFFBCBCBCFF989898FFB6B6
          B6FFC1C1C1FF999999FF929292FFABABABFFB4B4B4FFA7A7A7FFD4D4D4FFB1B1
          B1FF9D9D9DFFA2A2A2FF8E8E8EFF767676FF616161FF494949F01D1D1DAE0202
          029F000000880000005C0000002D0000001000000003000000003F3F3FB3CBCB
          CBFFFEFEFEFFE4E4E4FFC3C3C3FFBFBFBFFFAEAEAEFF9A9A9AFFE4E4E4FFF8F8
          F8FFF7F7F7FFF9F9F9FFE9E9E9FFB6B6B6FF8F8F8FFF8E8E8EFFB9B9B9FFE1E1
          E1FFE7E7E7FFADADADFF888888FF979797FF828282FF6E6E6EFF5C5C5CFF4747
          47F21A1A1AAC0101019E0000007F000000470000001600000002515151DAF4F4
          F4FFE3E3E3FFC0C0C0FFC3C3C3FFB6B6B6FFC3C3C3FFFBFBFBFFF7F7F7FFF6F6
          F6FFF6F6F6FFF6F6F6FFF5F5F5FFF5F5F5FFF5F5F5FFDBDBDBFFA1A1A1FF8080
          80FF8D8D8DFFC2C2C2FFC7C7C7FFB0B0B0FFADADADFF999999FF727272FF6363
          63FF555555FF3B3B3BE40B0B0BA20000008B000000420000000C3E3E3E9CB6B6
          B6FFD7D7D7FFBFBFBFFF9E9E9EFFA9A9A9FFACACACFFD1D1D1FFE9E9E9FFFFFF
          FFFFFFFFFFFFFBFBFBFFF6F6F6FFF3F3F3FFEFEFEFFFEDEDEDFFECECECFFECEC
          ECFFC4C4C4FF8F8F8FFF7A7A7AFF979797FFABABABFFABABABFFACACACFF8D8D
          8DFF626262FF585858FF454545FB0B0B0B9E0000006300000017080808155A5A
          5AD2939393FFBCBCBCFFD6D6D6FFE4E4E4FFE9E9E9FFD2D2D2FFB9B9B9FFA5A5
          A5FFC5C5C5FFE6E6E6FFFAFAFAFFF8F8F8FFF2F2F2FFEDEDEDFFE8E8E8FFE4E4
          E4FFE2E2E2FFE2E2E2FFE1E1E1FFAFAFAFFFA5A5A5FFAAAAAAFFACACACFFADAD
          ADFFA9A9A9FF686868FF555555FF282828C30000005200000012000000000303
          03073535356C676767D6878787FEA5A5A5FFBCBCBCFFC6C6C6FFD9D9D9FFE8E8
          E8FFD4D4D4FFB9B9B9FF9F9F9FFFACACACFFD6D6D6FFE8E8E8FFEDEDEDFFE7E7
          E7FFE2E2E2FFDEDEDEFFC4C4C4FFACACACFF909090FF969696FF7E7E7EFF7E7E
          7EFFA9A9A9FF9D9D9DFF4E4E4EFF1C1C1C980000002400000005000000000000
          000000000000000000012020203B4F4F4F96767676E58F8F8FFEA4A4A4FFB2B2
          B2FFBCBCBCFFC6C6C6FFD5D5D5FFD0D0D0FFAFAFAFFF9C9C9CFF989898FFC2C2
          C2FFCFCFCFFFB2B2B2FF9B9B9BFFB7B7B7FFEEEEEEFFF3F3F3FFEBEBEBFFBFBF
          BFFFA6A6A6FF646464FE2D2D2DB2010101260000000700000000000000000000
          000000000000000000000000000000000000010101031F1F1F354A4A4A827575
          75CB8D8D8DFC9A9A9AFFA5A5A5FFB1B1B1FFBCBCBCFFC6C6C6FFC4C4C4FFABAB
          ABFFB2B2B2FFAFAFAFFFDADADAFFFFFFFFFFFCFCFCFFD5D5D5FFACACACFF7C7C
          7CFF474747ED2020207A00000014000000040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000A0A0A122F2F2F5252525295707070D1818181FB8C8C8CFF979797FFA3A3
          A3FFB0B0B0FFB6B6B6FFB4B4B4FFB6B6B6FFA4A4A4FF797979FF4F4F4FEF2B2B
          2B93070707260000000700000001000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000109090911232323463C3C3C7B5050
          50AB5F5F5FD06C6C6CF26D6D6DFC616161F84A4A4AC3272727720404041C0000
          0005000000010000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000001000000030606060D040404090000000200000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000009300FF009300FF009300FF0093
          00FF009300FF0007000900000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000009300FF35CE5FFF31CA59FF1DB6
          34FF009300FF0006000900000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000001219000571AB000570A90000
          111800000000000000000000000000000000009300FF54ED92FF4FE88AFF2EC7
          50FF009300FF0006000900000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000004485B0007A1EE0019CEFF0018CAFF7377
          CAF500034257000000000000000000000000009300FF53EC8EFF4CE584FF2BC5
          4BFF009300FF000B001100050007000500070004000600000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000D0F00087DA70012BEFE0028EAFF002BEFFF0029ECFF7387
          EDFF009300FF009300FF009300FF009300FF009300FF53EC8DFF4DE684FF29C2
          47FF009300FF009300FF009300FF009300FF009300FF00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000032D36000C9DDD001FD7FF0032FEFF002FF8FF002DF3FF002BF0FF738A
          F5FF009300FF42DB6DFF39D25FFF37D05AFF3CD564FF50E986FF4CE581FF3FD8
          6AFF27C044FF2AC34AFF2CC54FFF1DB634FF009300FF00000000000000000000
          0000000000000000000000000000000000000000000000000000000000000006
          56650010B9F8032FEFFF0338FFFF0134FFFF0033FFFF0031FBFF002FF9FF738B
          F9FF009300FF65FEA4FF58F190FF56EF8EFF52EB88FF4FE882FF4CE580FF4CE5
          81FF4DE685FF4CE584FF4EE78AFF33CC5AFF009300FF00000000000000000000
          0000000000000000000000000000000000000000000000000304000B77940217
          C8FE093AFDFF083DFFFF073AFFFF0639FFFF0537FFFF0335FFFF0133FFFF738E
          FEFF009300FF6DFFAFFF61FA9CFF5EF798FF57F08FFF52EB86FF4FE882FF50E9
          86FF53EC8CFF53EC8DFF53EC91FF36CF5FFF009300FF00000000000000000000
          0000000000000000000000000000000000000000080A000E89B20522D3FE0E43
          FFFF0F41FFFF0D3FFFFF0C3FFFFF0B3DFFFF093CFFFF073AFFFF0538FFFF7490
          FEFF009300FF009300FF009300FF009300FF009300FF58F190FF52EB88FF39D2
          5FFF009300FF009300FF009300FF009300FF009300FF00000000000000000000
          000000000000000000000000000000010A0C001097BF082ADEFF1449FFFF1346
          FFFF1345FFFF1244FFFF1143FFFF1042FFFF0E40FFFF0C3EFFFF093CFFFF7692
          FFFF7491FFFF748FFFFF738EFCFF738BF8FF009300FF60F99BFF58F18FFF2FC8
          4DFF009300FF0000000000000000000000000000000000000000000000000000
          0000000000000000000000000809001299BF0A2EE2FF1A4DFFFF1949FFFF184A
          FFFF1849FFFF1749FFFF1648FFFF1446FFFF1244FFFF1042FFFF0D40FFFF0B3D
          FFFF073AFFFF0437FFFF0133FFFF738EFCFF009300FF62FB9EFF59F292FF33CD
          53FF009300FF0000060700000000000000000000000000000000000000000000
          0000000000000000020200128BAD0A2EE2FF1D51FFFF1C4DFFFF1D4EFFFF1D4E
          FFFF1D4EFFFF1C4EFFFF1B4CFFFF194BFFFF1749FFFF1446FFFF1244FFFF0E41
          FFFF0B3DFFFF073AFFFF0436FFFF738FFEFF009300FF6CFFAEFF64FDA3FF39D2
          5DFF009300FF42499ABF00000101000000000000000000000000000000000000
          000000000000000F72830728DDFF2054FFFF1F50FFFF2152FFFF2253FFFF2253
          FFFF2253FFFF2152FFFF2051FFFF1E4FFFFF1B4DFFFF194AFFFF1547FFFF1244
          FFFF0F41FFFF0B3DFFFF0739FFFF7490FFFF009300FF009300FF009300FF0093
          00FF009300FF737EDCFF00085E7D000000000000000000000000000000000000
          000000083C3D0020D8FC2053FFFF2154FFFF2455FFFF2556FFFF2757FFFF2758
          FFFF2759FFFF2657FFFF2455FFFF2253FFFF2051FFFF1D4EFFFF194BFFFF1647
          FFFF1244FFFF0E40FFFF0A3CFFFF7692FFFF7490FFFF738EFCFF738BF8FF7389
          F3FF7386EFFF6F85E4FF0011B9FB00032F380000000000000000000000000000
          0203001AB6D21946F7FF2556FFFF2657FFFF2859FFFF2A5BFFFF2B5CFFFF2C5C
          FFFF2C5CFFFF2B5BFFFF295AFFFF2857FFFF2455FFFF2052FFFF1D4EFFFF194A
          FFFF1547FFFF1143FFFF0C3FFFFF083AFFFF0336FFFF0032FDFF002EF6FF0029
          ECFF0025E4FF0022DDFF0019CEFF000F9ECE000001020000000000000000000A
          4851072CE4FE2659FFFF2657FFFF2A5AFFFF2C5DFFFF2F5FFFFF3060FFFF3161
          FFFF3162FFFF2F5FFFFF2D5EFFFF2B5BFFFF2758FFFF2455FFFF2051FFFF1C4D
          FFFF1749FFFF1345FFFF0F41FFFF0A3CFFFF0538FFFF0134FFFF002FF9FF002B
          EFFF0026E7FF0022DEFF001FD8FF0014C2FE00053C4D00000000000000000015
          95AA1744F5FF2858FFFF2A5AFFFF2D5EFFFF3161FFFF3363FFFF3565FFFF3665
          FFFF3765FFFF3464FFFF3361FFFF2E5FFFFF2B5BFFFF2758FFFF2354FFFF1E50
          FFFF1A4BFFFF1547FFFF1143FFFF0D3FFFFF083AFFFF0235FEFF0030FAFF002C
          F2FF0028E9FF0023E1FF001FD8FF0018CBFF000C7BA40000000000000000001D
          C4DE2355FFFF285AFFFF2C5DFFFF3161FFFF3665FFFF3A69FFFF3C6BFFFF3C6B
          FFFF3A6AFFFF3868FFFF3565FFFF3263FFFF2E5EFFFF295AFFFF2556FFFF2052
          FFFF1C4DFFFF194AFFFF1748FFFF1445FFFF1140FFFF083AFFFF0133FDFF002D
          F5FF0029EBFF0024E2FF0020DBFF001CD1FF0011A5D80000000000000000001F
          D5EC2658FFFF2B5AFFFF305FFFFF3665FFFF3C6CFFFF4270FFFF4371FFFF4371
          FFFF406FFFFF3C6BFFFF3968FFFF3464FFFF3060FFFF2B5CFFFF2758FFFF2253
          FFFF1F50FFFF1F4FFFFF1E4FFFFF1C4BFFFF1748FFFF0F41FFFF0637FDFF012F
          F5FF0029ECFF0025E4FF0020DBFF001BD1FF0014B3E60000000000000000001F
          C7DC2556FEFF2B5DFFFF3362FFFF3C6AFFFF4370FFFF4875FFFF4B78FFFF4B78
          FFFF4775FFFF406FFFFF3B6AFFFF3666FFFF3161FFFF2D5DFFFF2859FFFF2354
          FFFF2253FFFF2553FFFF2654FFFF2553FFFF1F4EFFFF1644FFFF0A3CFFFF0331
          F7FF002AEDFF0025E4FF0021DDFF001CD2FF0012A9D60000000000000000001B
          A9B71E4EFAFF2D5FFFFF3664FFFF3D6BFFFF4673FFFF4D78FFFF4F7BFFFF507E
          FFFF4B78FFFF4270FFFF3C6BFFFF3766FFFF3363FFFF2D5DFEFF2959FEFF2456
          FFFF2454FFFF2755FFFF2757FFFF2D57FFFF2652FFFF1947FFFF0C3EFEFF0432
          F6FF002AEDFF0025E4FF0021DCFF001CD2FF00118EB100000000000000000014
          7179123FF5FF2F5FFFFF3463FFFF3C6AFFFF4572FFFF4C78FFFF4E7AFFFF4E7A
          FFFF4976FFFF416FFFFF3B6AFFFF3667FFFF3565FFFF1841F0FF1540F0FF2557
          FFFF2354FFFF2654FFFF2654FFFF2855FFFF2250FFFF1847FFFF0C3CFFFF0432
          F7FF002AEDFF0025E4FF0021DCFF001BD2FF000B5D7300000000000000000005
          1F1F002AEEFA2D5EFFFF3362FFFF3B69FFFF416FFFFF4673FFFF4875FFFF4875
          FFFF4472FFFF3D6CFFFF3968FFFF3766FFFF2F5EFEFF001ED6F3001FD6F42253
          FEFF2152FFFF2252FFFF2250FFFF1F4EFFFF1A49FFFF1343FFFF0839FDFF0230
          F5FF0029ECFF0025E4FF0020DBFF001ACEF80002181A00000000000000000000
          0000001B9595113FF7FF3262FFFF3665FFFF3A6AFFFF3E6CFFFF416FFFFF3F6D
          FFFF3C6BFFFF3968FFFF3867FFFF3463FFFF052DE8FE000F5D60000F6266052A
          E6FE1D50FFFF1C4DFFFF1A4AFFFF1749FFFF1444FFFF0B3CFFFF0334FDFF002D
          F5FF0029EBFF0024E2FF001FD8FF0011828F0000000000000000000000000000
          000000020C0C0022C7CE1544F9FF3263FFFF3566FFFF3867FFFF3968FFFF3968
          FFFF3869FFFF3869FFFF2C5BFCFF042DEBFD0013767600000000000000000014
          7B7B0328E6FD1343FCFF1446FFFF0F42FFFF0B3CFFFF0437FEFF0031FBFF002C
          F3FF0029EAFF0022DEFF0018AECA0001090A0000000000000000000000000000
          000000000000000312120020B3B30535F9FE1E4EFCFF2D5EFEFF3364FFFF3162
          FFFF2654FBFF0F3DF4FF0022D1E2000E4C4C0000000000000000000000000000
          0000000D50500020CCE3052FEEFF0737F9FF0538FFFF0135FFFF002FF7FF0028
          EAFF0023E1FE0019A4B000021010000000000000000000000000000000000000
          0000000000000000000000000000000D4444001C9EA40024D0D90027E3EC0024
          D4DE001CA6B000105A6000010808000000000000000000000000000000000000
          00000000000000010909000E5861001AA0B1001FC6DF0021D3ED001FBFD90016
          90A3000A40440000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end>
  end
  object cxImageList2: TcxImageList
    BkColor = 15790320
    Height = 32
    Width = 32
    FormatVersion = 1
    DesignInfo = 13500646
    ImageInfo = <
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000100000001000000010000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000100000007000000150000002200000022000000180000000C000000030000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000001000000070000
          0017000000340000005F00000080000000810000006700000042000000250000
          0012000000070000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000010000000500000014000000300707
          0763363636A86F6F6FED676767E9383838B80F0F0F9E000000970000007C0000
          0057000000320000001B0000000C000000030000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000004000000120000002C0505055C343434A17777
          77F1909090FFA2A2A2FF979797FE8D8D8DFF7F7F7FFE616161DA242424A70404
          049D0000008C0000006A00000044000000250000001200000007000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000040000001000000029030303552E2E2E99767676EB949494FFA9A9
          A9FFAAAAAAFF8D8D8DFF7D7D7DFE939393FF919191FF8E8E8EFF858585FF7474
          74F63D3D3DBC1010109F000000970000007D00000058000000330000001C0000
          000C000000030000000000000000000000000000000000000000000000000000
          0007000000220202024F29292992717171E4979797FFB0B0B0FFB2B2B2FF8E8E
          8EFF616161FF7B7B7BFF848484FF636363FF656565FF444444FF595959FF7D7D
          7DFF888888FF7C7C7CFE5E5E5EDC222222A80404049D0000008D0000006B0000
          0045000000260000001300000007000000010000000000000000000000010101
          011C262626826D6D6DDC989898FEB5B5B5FFB7B7B7FF909090FF666666FF8686
          86FFC1C1C1FFDBDBDBFFB3B3B3FFADADADFF939393FF5C5C5CFF2B2B2BFF3131
          31FF424242FF646464FF7F7F7FFF7D7D7DFF6D6D6DF73A3A3ABC101010A00000
          00970000007D0000005800000032000000170000000400000000000000036F6F
          6FC19A9A9AFEBABABAFFBDBDBDFF939393FF6E6E6EFF979797FFCFCFCFFFDDDD
          DDFFD6D6D6FFD4D4D4FFB1B1B1FFACACACFFB2B2B2FF757575FF4C4C4CFF2D2D
          2DFF2B2B2BFF2E2E2EFF313131FF4C4C4CFF6A6A6AFF7A7A7AFF737373FE5A5A
          5ADD202020A80404049D00000089000000540000001400000000020202128E8E
          8EF6C2C2C2FF969696FF787878FFA7A7A7FFDBDBDBFFE0E0E0FFDCDCDCFFD7D7
          D7FFD5D5D5FFD6D6D6FFB1B1B1FFB0B0B0FFB1B1B1FFB1B1B1FF8B8B8BFF6B6B
          6BFF515151FF3C3C3CFF2A2A2AFF292929FF2C2C2CFF373737FF535353FF6D6D
          6DFF727272FF666666F72C2C2CAE000000830000002C00000004202020518888
          88FE878787FFB7B7B7FFE4E4E4FFE5E5E5FFE0E0E0FFDCDCDCFFDBDBDBFFD9D9
          D9FFD7D7D7FFD7D7D7FFB2B2B2FFB3B3B3FFB2B2B2FFB3B3B3FFB4B5B5FFB6B7
          B7FFA0A1A1FF828383FF676767FF505050FF3C3C3CFF292929FF292929FF2C2C
          2CFF3C3C3CFF656565FF5C5C5CE60000009F0000005500000012818181EAC6C6
          C6FFEBEBEBFFE9E9E9FFE4E4E4FFE1E1E1FFE0E0E0FFDEDEDEFFDDDDDDFFDBDB
          DBFFD9D9D9FFD3D3D3FFB7B7B7FFB7B7B7FFB6B6B6FFB6B7B7FFB5B8BBFFB4B8
          BEFFB5B6BAFFB7BBC1FFB6BDC5FF9DA3A7FF818384FF676868FF4F4F4FFF3939
          39FF303030FF666666FF626262FD1F1F1FA80000007B0000001F808080E6EBEB
          EBFFE9E9E9FFE6E6E6FFE5E5E5FFE4E4E4FFE2E2E2FFE1E1E1FFDFDFDFFFDDDD
          DDFFDDDDDDFFCFCFCFFFBABABAFFBBBBBBFFBABABAFFB9BCBFFFC2A98CFFD67B
          14FFD77B11FFD4740AFFCC7A1FFFC69059FFBBB4ADFFB8BDC3FF9F9FA0FF8080
          80FF6F6F6FFF9E9E9EFFA4A4A4FF545454E80000007F000000217A7A7AD7E6E6
          E6FFECECECFFE9E9E9FFE7E7E7FFE6E6E6FFE4E4E4FFE3E3E3FFE1E1E1FFDFDF
          DFFFDEDEDEFFCACACAFFBFBFBFFFBEBEBEFFBEBEC0FFBEC0C3FFD5811EFFE8AC
          5FFFE9A95AFFE7A858FFE39F47FFDB8A29FFD16A00FFC29465FFB8BEC3FFBBBB
          BBFFBCBCBCFFB9B9B9FFB3B3B3FF484848DC000000730000001C6C6C6CB8DDDD
          DDFFEEEEEEFFEBEBEBFFEAEAEAFFE8E8E8FFE6E6E6FFE4E4E4FFE2E2E2FFE0E0
          E0FFE0E0E0FFC5C5C5FFC3C3C3FFC2C2C2FFC2C5CBFFCCA574FFE29A43FFEBB4
          6DFFE7A858FFE6A655FFE4A454FFE4A651FFE4A34EFFD36D00FFBEB2A6FFBCBD
          BDFFC0BDBAFFBCBBBAFFAAAAAAFF393939C600000062000000165454548DD0D0
          D0FFF3F3F3FFEEEEEEFFECECECFFEAEAEAFFE8E8E8FFE6E6E6FFE4E4E4FFE4E4
          E4FFD9D9D9FFC7C7C7FFC7C7C7FFC6C7C8FFC7C7C9FFD78521FFEEBB7CFFEBAE
          64FFE8AA5BFFE6A858FFE5A654FFE4A450FFE5A552FFD77D17FFC6AD92FFB1B7
          BDFF79B6EEFFCBC7C5FF9A9A99FF292929AE000000490000000D3131314EBBBB
          BBFFF7F7F7FFF0F0F0FFEEEEEEFFECECECFFEAEAEAFFE8E8E8FFE5E5E5FFE5E5
          E5FFD0D0D0FFCBCBCBFFCACACAFFCACED4FFD2A771FFE4A14EFFEFBD7EFFEAAD
          62FFE9AB5EFFE7A95AFFE6A756FFE5A553FFE4A654FFD77A11FFC0AD9CFF5BA3
          DAFF36AEFFFFB8C4CDFF868584FF151515920000002F000000050707070A9D9D
          9DEDF5F5F5FFF3F3F3FFF0F0F0FFEEEEEEFFEBEBEBFFE9E9E9FFE7E7E7FFE0E0
          E0FFD2D2D2FFD1D1D1FFD0D2D5FFD1C9C0FFDC8E2AFFF1C085FFEDB570FFEBAE
          64FFE9AC60FFE8AA5CFFE7A858FFE5A656FFE5A552FFD57711FFAFAEB1FF4CA5
          E1FF51B4FAFFC4BEBAFF676767F5040404680000001900000001000000006464
          648BCFCFCFFFFAFAFAFFF3F3F3FFEFEFEFFFECECECFFEBEBEBFFE7E7E7FFDADA
          DAFFD8D8D8FFD7D8DAFFD6D8DDFFDA9842FFEEB470FFF2BF82FFEDB26BFFECB0
          66FFEAAE62FFE9AB5EFFE7A95AFFE6A858FFE0983DFFD19652FFCDD1D6FF7E8A
          91FFA8AAADFFA8A6A5FF3B3B3BB1000000370000000900000000000000000E0E
          0E129A9A9AE2E6E6E6FDF9F9F9FFF3F3F3FFF0F0F0FFEBEBEBFFE1E1E1FFDFDF
          DFFFDEDFE1FFDDE2E8FFDEA75FFFE8AC5DFFF4C58EFFF0B874FFEEB36CFFECB1
          68FFEBAF64FFE9AC60FFE8AA5DFFE9AB5DFFD9821BFFD1C0ADFFD0D2D5FFD5D4
          D3FFD1D1D0FF747473F50C0C0C61000000150000000100000000000000000000
          000027272731A1A1A1E4C9C9C9FCD6D6D7FFD8D8D9FFDDDEDFFFE4E5E7FFE7EA
          EEFFE4E3E3FFE4AE67FFEAAE63FFF7CA97FFF2BC7DFFF0B672FFEEB46EFFEDB2
          6AFFEBAF65FFEAAD61FFEAAD5FFFE39E47FFD79444FFD6DDE5FFD7D8D8FFDADA
          DAFF919191FE3131318D00000020000000040000000000000000000000000000
          0000000000000D0D0D11626262A1B4B3AFFFCAC5BFFFBDB5ACFFBEAC99FFD3B2
          8AFFECAF63FFF4C083FFFACD9EFFF4BF82FFF2B977FFF0B773FFEFB56FFFEDB2
          6BFFECB067FFEBAF66FFEAAB5BFFDA8824FFDFD8D1FFE2E4E5FFDBDBDBFF9898
          98FE4B4B4BA40000002000000005000000000000000000000000000000000000
          00000000000000000001565657A2D9D1C6FFFFFAE6FFFFEED3FFFABD78FFF4B7
          70FFF5C48CFFF6C289FFF5BC7CFFF4BB7BFFF3BC7BFFF3BB78FFF0B774FFF0B6
          70FFEEB46EFFE9AB5EFFDE912DFFC4AC8EFFC7CCD0FFB1B1B1FF838383F03D3D
          3D7D000000140000000400000000000000000000000000000000000000000000
          000000000000000000067B7B7CDAF9EFDFFFFFF5E5FFFFF4E4FFFFF1DDFFFBDE
          BBFFF7CF9EFFF3C286FFEDB66EFFE8AA59FFE3A14AFFE09C40FFE19D3EFFE59D
          3EFFDC9A3FFEB4822ED859462C805155588C565656933A3A3A690B0B0B1F0000
          0006000000010000000000000000000000000000000000000000000000000000
          0000000000000F0F0F25979798FDFFFEF1FFFFF6E6FFFFF4E4FFFFF4E3FFFFF3
          E1FFFFF3E1FFFFF3DEFFFFF2DDFFFFF2DAFFFFF0D7FFFFEFD0FFCDC1AAFF3F3E
          3CB30B0802500100001000000001000000010000000100000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000003131315EB7B5B1FFFFFDF2FFFFF6EBFFFFF5E7FFFFF4E4FFFFF2
          E0FFFFF1DDFFFFEFD9FFFFEED5FFFFEDD2FFFFEBCFFFFFF1D0FFA69F99FF191A
          1A910000002E0000000400000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000156565697D5D2CDFFFFFCF2FFFFF7ECFFFFF6E9FFFFF4E6FFFFF3
          E2FFFFF2DEFFFFF0DBFFFFEFD7FFFFEDD3FFFFEDCFFFFFF1CFFF7B7C7EF60404
          04760000001E0000000100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000017C7D7DCEF9F6F0FFFFFFFBFFFFFEF5FFFFFDF0FFFFFAEBFFFFF9
          E6FFFFF5E3FFFFF3DFFFFFF2DAFFFFEFD6FFFFF0D3FFE4D4BDFF555556C60000
          0055000000120000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000909090F979798FBB2B1B0FFB7B5B3FFBCBBB9FFC4C0BCFFC9C5BEFFD0CA
          C1FFD8CFC4FFDFD6C7FFE8DBC8FFEFE1CAFFFCEBCFFFBBB3A6FF323232940000
          0030000000080000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000002020204141414231C1C1C34252626462C2C2C55353535653D3D3D744444
          45844B4C4C92505052A059595AB05E5E60BF666769CD727273DC1616163D0000
          000B000000010000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000100000001000000010000000100000001000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end
      item
        Image.Data = {
          36100000424D3610000000000000360000002800000020000000200000000100
          2000000000000010000000000000000000000000000000000000000000000000
          000000000000000000080000001F000000270000002700000027000000270000
          0027000000270000002700000027000000270000002700000027000000270000
          0027000000270000002700000027000000270000002700000027000000270000
          0027000000270000002200000012000000040000000000000000000000000000
          0000000000000000001F00000073000000900000009200000092000000920000
          0092000000920000009200000092000000920000009200000092000000920000
          0092000000920000009200000092000000920000009200000092000000920000
          00920000009100000083000000500000001B0000000400000000000000000000
          000000000000846150FF866150FF84604FFF84604FFF84604FFF84604FFF8460
          4FFF83604FFF83604FFF83604FFF835F4EFF825F4EFF825F4EFF815F4EFF815E
          4DFF805E4DFF805D4EFF7F5D4CFF7F5D4DFF7E5C4BFFAB958AFFBCAFA6FF8C89
          82FF8C807AFF141414A50101018F000000460000000E00000000000000000000
          000000000001856150FFF8E4D3FFF2DECCFFF2DECCFFF2DECCFFF2DECCFFF2DE
          CCFFF2DECCFFF2DECCFFF2DFCCFFF2DDCCFFF2DDCBFFF2DDCBFFF2DECAFFF2DC
          CAFFF2DCC7FFF3DBC7FFF1DAC4FFF1D9C2FFF2D8C0FFF3E3D5FF5C7CEFFF8A93
          A4FFCDC7C2FF888887FF191919A20000005F0000001500000000000000000000
          000000000001866150FFFFFDF2FFFAF4E8FFFAF3E9FFFAF3E9FFFAF3E9FFFAF3
          E9FFFAF3E9FFFAF3E8FFFAF4E8FFFAF2E8FFFAF2E7FFFAF2E7FFFAF3E6FFFAF1
          E6FFFAF2E5FFFAF2E4FFF9F1E2FFF9F0E0FFF6ECDEFF5D81F2FF2A76FFFF4BAD
          FFFFE0E6E4FFCFCBC7FF212121A70000006A0000001A00000000000000000000
          000000000001866150FFFFFEF5FFFBF6EAFFFBF5ECFFFBF5EBFFFBF5EBFFFBF5
          EBFFFBF5ECFFFBF5EAFFFBF6EAFFFBF4EBFFFBF4E9FFFBF4EAFFFBF5E8FFFBF3
          E9FFFBF3E7FFFCF4E6FFFAF2E5FFF6EDE5FF5981F5FF2E79FFFF56B4FFFF68D5
          FFFF5BBDFFFFAEAEAEFF6A6963D7000000430000000F00000000000000000000
          000000000001876351FFFFFEF7FFFBF5ECFFFCF6ECFFFCF6ECFFFCF6ECFFFCF6
          ECFFFCF6ECFFFBF5ECFFFBF5ECFFFBF5EBFFFBF5EBFFFBF5EAFFFBF4EAFFFBF4
          E9FFFBF4E8FFFBF3E8FFF6EFE7FF567CF7FF2F7BFFFF59B7FFFF6CD6FFFF5FC0
          FFFF3B8FFFFF123EB9D725242073000000120000000300000000000000000000
          000000000001886251FFFFFFF7FFFCF6EDFFFCF6EEFFFCF6EEFFFCF6EEFFFCF6
          EEFFFCF6EEFFFCF6EDFFFCF6EDFFFCF6EDFFFCF6ECFFFBF5ECFFFBF5EBFFFBF5
          EAFFFBF4EAFFEAE3D8FF4F6CE9FF307AFCFF5AB9FFFF6CD6FFFF5EBFFFFF3E8E
          FFFF2C5BE9FF000209900000002A000000010000000000000000000000000000
          000000000001896352FFFFFFFAFFFCF7EFFFFCF7EFFFFCF7EFFFFCF7EFFFFCF7
          EFFFFCF7EFFFFEFCF8FFFEFCF8FFFEFBF8FFFDF9F4FFFDF9F3FFFDF9F3FFFCF8
          F3FFF7F3EDFF97938AFF5B7297FF4AABF4FF6DD9FFFF5DBEFFFF3D8DFFFF3E6A
          F5FFBBB0B8FF0000009200000027000000010000000000000000000000000000
          0000000000018A6453FFFFFFFAFFFCF8F0FFFCF8F1FFFCF8F1FFFCF8F1FFFCF8
          F1FFFDFAF6FFF4F1ECFFB4B2B0FF898A8EFF83878EFF83878CFF818386FFAEAC
          AAFFE5E2DDFF8D8D8BFFE2D9D2FF79A4B5FF4DB1F8FF3A8BFFFF4371FAFFEAE2
          E4FFAC968AFF0000009200000027000000010000000000000000000000000000
          0000000000018B6553FFFFFFFBFFFCF8F2FFFCF8F2FFFDF9F2FFFDF9F2FFFDF9
          F2FFDAD7D3FF7A7F85FFB5A995FFE9CB99FFF5CD8FFFF5CC8FFFF5D2A1FFC0B5
          A4FF4D535AFF909092FFEEEDECFFEAE1D8FF4B70AAFF3D67EDFFEFE9EAFFF8ED
          E2FF7F5C4DFF0000009200000027000000010000000000000000000000000000
          0000000000018C6754FFFFFFFEFFFDF9F3FFFDF9F4FFFDF9F4FFFDF9F4FFDEDB
          D8FF828387FFE6C693FFF8CF8EFFF1CC92FFEFCA93FFF0CF9BFFF3D7A6FFF4CA
          8DFFF2D09CFF64676DFF9A9B9CFF959492FF9F9A8CFFE9E5E3FFFCF6EAFFF5E4
          D2FF805E4CFF0000009200000027000000010000000000000000000000000000
          0000000000018F6655FFFFFFFFFFFDFAF5FFFDFAF5FFFDFAF5FFF7F5F0FF878A
          8EFFE6C898FFF4D297FFEECF98FFEECF97FFEECE96FFEDCC8EFFEDC789FFF1D2
          A2FFF4D59EFFF2CF9EFF4D525AFFDBD8D3FFE5E0D7FFFBF5EAFFFCF5EBFFF5E4
          D3FF825D4CFF0000009200000027000000010000000000000000000000000000
          0000000000018F6754FFFFFFFFFFFDFAF6FFFDFBF7FFFDFBF7FFC8C7C6FFB1A4
          8FFFFAD9A1FFF1D5A3FFF0D8A3FFF0D5A4FFF0D5A1FFEFD29CFFEECF96FFEDC9
          8BFFF1D3A6FFF5CF90FFB3AB9CFFC0BEBCFFFDF9F3FFFBF5EBFFFCF5ECFFF5E4
          D4FF815F4EFF0000009200000027000000010000000000000000000000000000
          000000000001916855FFFFFFFFFFFDFBF8FFFDFBF8FFFDFBF8FFA3A4A8FFDEC9
          9EFFF4DCABFFF3DDAFFFF3DDAFFFF3DDAEFFF3DCACFFF1DAA8FFEFD39FFFEECF
          98FFEDCB8DFFF6DAB0FFEFD0A2FF8F8F90FFFDF9F3FFFBF5ECFFFCF7EDFFF5E5
          D6FF835E4DFF0000009200000027000000010000000000000000000000000000
          000000000001926957FFFFFFFFFFFEFCF9FFFEFCFAFFFEFCFAFF909297FFF7DF
          AAFFF7E6BCFFF6E5BDFFF6E8C4FFF5E7BFFFF6E4B7FFF3DEAFFFF1DBA8FFEFD3
          9FFFEECE94FFF1D5A7FFF6D299FF8B8E92FFFDF9F4FFFCF6EDFFFCF6EDFFF5E5
          D5FF83604DFF0000009200000027000000010000000000000000000000000000
          000000000001936A56FFFFFFFFFFFEFCFBFFFEFDFBFFFEFDFCFF93969CFFFBE4
          B4FFF9EDCCFFFBF0D4FFFBEFCFFFF8EDCBFFF6E9C2FFF5E3B9FFF3DEAFFFF1DA
          A7FFEFD29BFFF2D6A4FFF5D09AFF8D9093FFFDFAF5FFFCF6EDFFFCF6EEFFF5E5
          D7FF845F4FFF0000009200000027000000010000000000000000000000000000
          000000000001946C57FFFFFFFFFFFEFDFCFFFEFDFDFFFEFEFDFFB0B1B4FFDFCF
          A9FFFFF6DCFFFCF6DDFFFBF9EBFFFCF5E0FFFBEFCEFFF7EBC6FFF5E1B6FFF2DB
          ABFFEFD49FFFF4D7A4FFE7CC9FFF979798FFFCF7EFFFFCF6EEFFFDF8EFFFF7E6
          D6FF845F4EFF0000009200000027000000010000000000000000000000000000
          000000000001956B59FFFFFFFFFFFEFEFDFFFEFEFEFFFEFEFEFFDADADBFFB0A9
          98FFFFFCE0FFFEFDF1FFFEFDFAFFFEFEF3FFFCF4D6FFF8EECEFFF5E4B9FFF3DD
          AEFFF1D5A3FFFADAA0FFABA191FFC5C3C0FFFCF7F0FFFCF7EFFFFDF7EFFFF6E6
          D8FF85614EFF0000009200000027000000010000000000000000000000000000
          000000000001966C58FFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFCFCFCFFA5A4
          A8FFE7E0C2FFFFFFEAFFFFFFF6FFFCFBEBFFFBF5DCFFF8EECBFFF6E5BBFFF3DD
          AFFFF6DCA3FFE6CD9DFF7F8388FFF8F4EFFFFCF8F1FFFCF7EFFFFDF7F0FFF6E6
          D8FF856050FF0000009100000027000000010000000000000000000000000000
          000000000001976D59FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5F5
          F5FF9D9D9CFFEAE3C9FFFFFFE9FFFFFCE8FFFBF5DAFFFAEEC9FFFAE6B9FFFDE3
          AEFFE5CDA1FF828386FFE0DDD9FFFDF9F2FFFCF8F1FFFCF7EFFFFDF7F0FFF6E6
          D7FF86604FFF0000009100000027000000010000000000000000000000000000
          000000000001986E5BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFF3F3F3FFA3A3A7FFB2AE9EFFE3D8B8FFFFF0C3FFFDEABCFFE2D0AAFFB0A7
          96FF84888BFFDFDDDAFFFDF9F4FFFDF9F3FFFCF8F1FFFDF8F1FFFDF8F1FFF7E7
          D9FF866150FF0000008900000024000000000000000000000000000000000000
          00000000000199705AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFAFAFAFFD3D3D4FFA6A7ABFF8B8D90FF87898EFF9B9DA0FFBFBE
          BEFFF7F6F2FFFFFDF9FFFFFDF7FFFEFBF7FFFDF8F3FFF9F5EDFFF5F0E8FFE9D6
          C8FF84604EFC0000006800000019000000000000000000000000000000000000
          0000000000019A6F5CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFDFCFFFEFCFAFFFFFD
          FBFFE6DCD7FFD9CBC2FFE0D3CCFFDACCC5FFD5C5BEFFC8B6ADFFBBA49AFF9775
          65FF533D32BF0000002E00000007000000000000000000000000000000000000
          0000000000019B705BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFDFFFEFDFCFFFEFCFAFFFFFF
          FFFFBBA295FFA18072FFA78978FFA5836FFFA37F67FFB08866FF936C54FF5F45
          39CA060404380000000900000001000000000000000000000000000000000000
          0000000000019C725DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFEFDFFFEFDFCFFFEFCFAFFFFFF
          FFFFCBB7ADFFC5AD9FFFFFF5E0FFF9E1BBFFF8D69CFFC59E6EFF5C4338C80604
          0439000000090000000100000000000000000000000000000000000000000000
          0000000000019E725CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFEFEFFFEFDFCFFFEFDFBFFFEFCFAFFFFFF
          FCFFCCBAB0FFBEA18BFFF6DFB8FFF3CF96FFC0986AFF65493ED30604033A0000
          000A000000010000000000000000000000000000000000000000000000000000
          0000000000019C725CFFFFFFFFFFFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFEFEFEFFFEFEFEFFFEFDFDFFFEFDFCFFFEFCFAFFFEFCF9FFFFFE
          FCFFD7C9C1FFB28D72FFF6D39AFFC89F6EFF63493DD10906063D0000000B0000
          0001000000000000000000000000000000000000000000000000000000000000
          0000000000019D715DFFFFFFFFFFFEFEFDFFFEFEFEFFFEFEFEFFFFFFFFFFFEFE
          FEFFFEFEFEFFFEFEFEFFFEFDFDFFFEFDFCFFFEFCFBFFFEFCFAFFFDFBF8FFFFFF
          FBFFD3C2B9FFB7906AFFCBA16FFF65493DD20805043F0000000B000000010000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000009B715BFFFFFFFFFFFEFDFCFFFEFDFDFFFEFEFDFFFEFEFDFFFEFE
          FDFFFEFEFDFFFEFDFCFFFEFDFCFFFEFCFBFFFEFCFAFFFDFBF9FFFDFBF7FFFFFE
          FBFFCEBAB1FFA2795AFF6F5242D90C0907450000000C00000001000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000009C715DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFB39789FF6E4F42D70C0807400000000C0000000100000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000009A715DFF9D725FFF9B715DFF9C715DFF9A715DFF9A715DFF9970
          5BFF98705CFF986F5AFF976D5BFF966E59FF956C5AFF946B59FF936A58FF936C
          59FF63483BBC0C09072C00000009000000010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000}
      end>
  end
end
