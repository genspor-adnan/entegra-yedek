object IWUserSession: TIWUserSession
  OldCreateOrder = False
  OnCreate = IWUserSessionBaseCreate
  OnDestroy = IWUserSessionBaseDestroy
  Height = 335
  Width = 556
  object qChechUserIDPASS: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'UID'
        Attributes = [paNullable]
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 120
        Value = Null
      end
      item
        Name = 'SFIRE'
        Attributes = [paNullable]
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 100
        Value = Null
      end>
    SQL.Strings = (
      'SELECT DISTINCT R.FIRMA, K.SIFRE'
      'FROM         REHBER AS R INNER JOIN'
      '                      KULLANICI AS K ON R.ID = K.REHBERID'
      'WHERE     (R.FIRMA = :UID) AND (K.SIFRE = :SFIRE)')
    Left = 120
    Top = 32
  end
  object DBFly: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=FETAGEN;Persist Security Info=True;' +
      'User ID=sa;Initial Catalog=ENTEGRA;Data Source=FETASERVER,64855'
    ConnectOptions = coAsyncConnect
    CursorLocation = clUseServer
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 32
    Top = 8
  end
  object QDucKlasur: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT     ID, USTID, AD'
      'FROM         DOKUMANKLASOR'
      ''
      'where ID>=0'
      'ORDER BY ID, USTID')
    Left = 48
    Top = 88
    object QDucKlasurID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object QDucKlasurUSTID: TIntegerField
      FieldName = 'USTID'
    end
    object QDucKlasurAD: TWideStringField
      FieldName = 'AD'
    end
  end
  object QDocuments: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    BeforeOpen = QDocumentsBeforeOpen
    Parameters = <
      item
        Name = 'PKlasorID'
        DataType = ftInteger
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT     D.ID, D.TARIH, D.BELGENO, D.DURUM, D.YON, D.KATEGORI,' +
        ' D.AD, D.SURUM, D.KONU, D.TUR, D.BOYUT, D.SORUMLU, D.BOLUM, D.LO' +
        'KASYON, D.REHBERID, '
      
        '                      D.ILGILIID, D.PROJEID, D.AKTIVITEID, D.KLA' +
        'SOR, D.GECERLILIK_TARIHI, D.EKLEYEN, D.EKLEMETARIHI, D.DEGISTIRE' +
        'N, D.DEGISTIRMETARIHI, D.ESKIKLASOR, '
      
        '                      D.BAGI, Firma.FIRMA, Lokasyon.ACIKLAMA, Il' +
        'gili.ADSOYAD, Sorumlu.FIRMA AS Sorumluadi, '#39'.'#39' + REVERSE(SUBSTRI' +
        'NG(REVERSE(ISNULL'
      '                          ((SELECT     TOP (1) BELGEADI'
      '                              FROM         IMAJ AS I'
      
        '                              WHERE     (YERI = 1) AND (YER_ID =' +
        ' D.ID)'
      
        '                              ORDER BY ID DESC), '#39'.'#39')), 1, CHARI' +
        'NDEX('#39'.'#39', REVERSE(ISNULL'
      '                          ((SELECT     TOP (1) BELGEADI'
      '                              FROM         IMAJ AS I'
      
        '                              WHERE     (YERI = 1) AND (YER_ID =' +
        ' D.ID)'
      
        '                              ORDER BY ID DESC), '#39'.'#39')), 1) - 1))' +
        ' AS EXT, D.MODUL, DOKUMANKLASOR.AD AS Klasorad'
      'FROM         DOKUMAN AS D LEFT OUTER JOIN'
      
        '                      DOKUMANKLASOR ON D.KLASOR = DOKUMANKLASOR.' +
        'ID LEFT OUTER JOIN'
      
        '                      REHBER AS Firma ON Firma.ID = D.REHBERID L' +
        'EFT OUTER JOIN'
      
        '                      LOKASYON AS Lokasyon ON Lokasyon.ID = D.LO' +
        'KASYON LEFT OUTER JOIN'
      
        '                      REHBER AS Sorumlu ON Sorumlu.ID = D.SORUML' +
        'U LEFT OUTER JOIN'
      
        '                      REHBERPERSONEL AS Ilgili ON Ilgili.ID = D.' +
        'ILGILIID'
      'WHERE     (D.KLASOR = :PKlasorID)')
    Left = 144
    Top = 96
    object QDocumentsYONSTR: TIntegerField
      FieldKind = fkCalculated
      FieldName = 'YONSTR'
      OnGetText = QDocumentsYONSTRGetText
      Calculated = True
    end
    object QDocumentsID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object QDocumentsTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object QDocumentsBELGENO: TWideStringField
      FieldName = 'BELGENO'
      Size = 50
    end
    object QDocumentsDURUM: TWordField
      FieldName = 'DURUM'
    end
    object QDocumentsYON: TWordField
      FieldName = 'YON'
    end
    object QDocumentsKATEGORI: TWideStringField
      FieldName = 'KATEGORI'
      Size = 25
    end
    object QDocumentsAD: TWideStringField
      FieldName = 'AD'
      Size = 100
    end
    object QDocumentsSURUM: TWideStringField
      FieldName = 'SURUM'
      Size = 15
    end
    object QDocumentsKONU: TWideStringField
      FieldName = 'KONU'
      Size = 100
    end
    object QDocumentsTUR: TSmallintField
      FieldName = 'TUR'
    end
    object QDocumentsBOYUT: TBCDField
      FieldName = 'BOYUT'
      Precision = 8
      Size = 2
    end
    object QDocumentsSORUMLU: TIntegerField
      FieldName = 'SORUMLU'
    end
    object QDocumentsBOLUM: TSmallintField
      FieldName = 'BOLUM'
    end
    object QDocumentsLOKASYON: TIntegerField
      FieldName = 'LOKASYON'
    end
    object QDocumentsREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object QDocumentsILGILIID: TIntegerField
      FieldName = 'ILGILIID'
    end
    object QDocumentsPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object QDocumentsAKTIVITEID: TIntegerField
      FieldName = 'AKTIVITEID'
    end
    object QDocumentsKLASOR: TIntegerField
      FieldName = 'KLASOR'
    end
    object QDocumentsGECERLILIK_TARIHI: TDateTimeField
      FieldName = 'GECERLILIK_TARIHI'
    end
    object QDocumentsEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object QDocumentsEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object QDocumentsDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object QDocumentsDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object QDocumentsESKIKLASOR: TIntegerField
      FieldName = 'ESKIKLASOR'
    end
    object QDocumentsMODUL: TWordField
      FieldName = 'MODUL'
    end
    object QDocumentsBAGI: TIntegerField
      FieldName = 'BAGI'
    end
    object QDocumentsFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object QDocumentsACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object QDocumentsADSOYAD: TWideStringField
      FieldName = 'ADSOYAD'
      Size = 50
    end
    object QDocumentsSorumluadi: TWideStringField
      FieldName = 'Sorumluadi'
      Size = 120
    end
    object QDocumentsEXT: TStringField
      FieldName = 'EXT'
      ReadOnly = True
      Size = 101
    end
    object QDocumentsdurumstr: TStringField
      FieldKind = fkCalculated
      FieldName = 'durumstr'
      OnGetText = QDocumentsdurumstrGetText
      Calculated = True
    end
    object QDocumentsmodulstr: TStringField
      FieldKind = fkCalculated
      FieldName = 'modulstr'
      OnGetText = QDocumentsmodulstrGetText
      Size = 30
      Calculated = True
    end
    object QDocumentsKlasorad: TWideStringField
      FieldName = 'Klasorad'
    end
    object QDocumentsbolumstr: TStringField
      FieldKind = fkCalculated
      FieldName = 'bolumstr'
      OnGetText = QDocumentsbolumstrGetText
      Size = 50
      Calculated = True
    end
  end
  object QLangStringTab: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'Bl'
        DataType = ftInteger
        Size = -1
        Value = Null
      end
      item
        Name = 'DL'
        DataType = ftInteger
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select * from GENINI where BOLUM=:Bl and DIL=:DL')
    Left = 272
    Top = 112
    object QLangStringTabBOLUM: TIntegerField
      FieldName = 'BOLUM'
    end
    object QLangStringTabANAHTAR: TWideStringField
      FieldName = 'ANAHTAR'
      Size = 50
    end
    object QLangStringTabDEGER: TIntegerField
      FieldName = 'DEGER'
    end
    object QLangStringTabDIL: TSmallintField
      FieldName = 'DIL'
    end
    object QLangStringTabSIRA: TSmallintField
      FieldName = 'SIRA'
    end
  end
  object SPRetIMGFILE: TADOStoredProc
    Connection = DBFly
    ProcedureName = 'fn_Imaj_KayitliObjNesnesiniOku'
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        Attributes = [paNullable]
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@ID'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end>
    Left = 224
    Top = 192
  end
  object QRetrvieDOCIMJID: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'ID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT     TOP (1) ID ,BELGE'
      'FROM         IMAJ'
      'WHERE     (YERI = 1) AND (YER_ID =:ID)'
      'ORDER BY ID DESC')
    Left = 360
    Top = 176
    object QRetrvieDOCIMJIDID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object QRetrvieDOCIMJIDBELGE: TBlobField
      FieldName = 'BELGE'
    end
  end
  object qSPRetIMGFILE: TADOQuery
    Connection = DBFly
    Parameters = <>
    SQL.Strings = (
      'select')
    Left = 360
    Top = 80
  end
  object QFetchFileName: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'id'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT     AD'
      'FROM         DOKUMAN AS D'
      'WHERE     ( ID =  :id )')
    Left = 104
    Top = 184
    object QFetchFileNameAD: TWideStringField
      FieldName = 'AD'
      Size = 100
    end
  end
  object QGenIni: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'bolum'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'dil'
        Attributes = [paSigned, paNullable]
        DataType = ftSmallint
        Precision = 5
        Size = 2
        Value = Null
      end>
    SQL.Strings = (
      'SELECT    BOLUM, ANAHTAR, DEGER, DIL, SIRA'
      'FROM         GENINI'
      'WHERE     (BOLUM = :bolum) AND   (DIL = :dil)'
      'order by DEGER')
    Left = 216
    Top = 280
    object QGenIniBOLUM: TIntegerField
      FieldName = 'BOLUM'
    end
    object QGenIniANAHTAR: TWideStringField
      FieldName = 'ANAHTAR'
      Size = 50
    end
    object QGenIniDEGER: TIntegerField
      FieldName = 'DEGER'
    end
    object QGenIniDIL: TSmallintField
      FieldName = 'DIL'
    end
    object QGenIniSIRA: TSmallintField
      FieldName = 'SIRA'
    end
  end
  object QAraQuery1: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select R.ID,KOD,FIRMA,GRUP,ADSOYAD'
      
        'from REHBER R left outer join REHBERPERSONEL P on R.ID=P.REHBERI' +
        'D')
    Left = 64
    Top = 256
    object QAraQuery1ID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object QAraQuery1KOD: TWideStringField
      FieldName = 'KOD'
    end
    object QAraQuery1FIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object QAraQuery1GRUP: TSmallintField
      FieldName = 'GRUP'
    end
    object QAraQuery1ADSOYAD: TWideStringField
      FieldName = 'ADSOYAD'
      Size = 50
    end
    object QAraQuery1GrupSTr: TStringField
      FieldKind = fkCalculated
      FieldName = 'GrupSTr'
      OnGetText = QAraQuery1GrupSTrGetText
      Size = 255
      Calculated = True
    end
  end
  object QLocasion: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT     ID, KOD, ACIKLAMA'
      'FROM         LOKASYON'
      'WHERE     (REHBERID = - 1) AND (TUR = 2)'
      'ORDER BY ID')
    Left = 320
    Top = 264
    object QLocasionID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object QLocasionKOD: TWideStringField
      FieldName = 'KOD'
      Size = 50
    end
    object QLocasionACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
  end
  object QILGIli: TADOQuery
    Connection = DBFly
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'FRM'
        Attributes = [paNullable]
        DataType = ftWideString
        NumericScale = 255
        Precision = 255
        Size = 120
        Value = Null
      end>
    SQL.Strings = (
      'SELECT      Ilgili.ADSOYAD, Ilgili.ID'
      'FROM         REHBER AS Firma INNER JOIN'
      
        '                      REHBERPERSONEL AS Ilgili ON Firma.ID = Ilg' +
        'ili.REHBERID'
      'WHERE     (Firma.FIRMA = :FRM)')
    Left = 280
    Top = 56
    object QILGIliADSOYAD: TWideStringField
      FieldName = 'ADSOYAD'
      Size = 50
    end
    object QILGIliID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
  end
end
