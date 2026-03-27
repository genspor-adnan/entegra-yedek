object Tablo: TTablo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 327
  Width = 955
  object frxDetay: TfrxDBDataset
    UserName = 'frxDetay'
    CloseDataSource = False
    DataSource = DtsDetay
    BCDToCurrency = False
    Left = 391
    Top = 80
  end
  object TabDetay: TFDQuery
    Connection = FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select  F.*,AD=S.STOKADI, ACIKLAMA2=ACIKLAMA,BIRIMAD=(select top' +
        ' 1 ANAHTAR from GENINI G where BOLUM=-2702 and G.DEGER=F.BIRIM a' +
        'nd DIL=-1)  from FATURA F inner join STOKLAR S on F.URUNID=S.ID ' +
        ' '
      'where FATBASID=:PRM1'
      '')
    Left = 265
    Top = 72
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 329
    Top = 79
  end
  object cnn: TFDConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=fetagen;Persist Security Info=True;' +
      'User ID=sa;Initial Catalog=SAHINLER_GENTEGRE;Data Source=ADNANUL' +
      'TRABOOK\SQL2012;Use Procedure for Prepare=1;Auto Translate=True;' +
      'Packet Size=8192;Application Name=Gentegre;Workstation ID=ENTEGR' +
      'A;Use Encryption for Data=False;Tag with column collation when p' +
      'ossible=False'
    ConnectionTimeout = 60
    CursorLocation = clUseServer
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 24
    Top = 7
  end
  object FDCnn: TFDConnection
    LoginPrompt = False
    Left = 96
    Top = 40
  end
  object TabBizim: TFDQuery
    Connection = FDCnn
    ParamData = <>
    SQL.Strings = (
      'Declare @IletisimID integer'
      
        'select top 1 @IletisimID = ID from REHBERILETISIM where REHBERID' +
        '=-1  order by VARSAYILAN desc'
      '    select'
      '    '#9'R.*,'
      
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
    Left = 64
    Top = 168
  end
  object DtsBizim: TDataSource
    DataSet = TabBizim
    Left = 30
    Top = 219
  end
  object frxMusteri: TfrxDBDataset
    UserName = 'Musteri'
    CloseDataSource = False
    DataSet = TabMusteri
    BCDToCurrency = False
    Left = 128
    Top = 219
  end
  object TabMusteri: TFDQuery
    Connection = FDCnn
    ParamData = <>
    SQL.Strings = (
      'select top 1 * from REHBER')
    Left = 122
    Top = 168
  end
  object frxBizim: TfrxDBDataset
    UserName = 'BizimFirma'
    CloseDataSource = False
    DataSet = TabBizim
    BCDToCurrency = False
    Left = 70
    Top = 225
  end
  object TabSevkAdresi: TFDQuery
    Connection = FDCnn
    ParamData = <>
    SQL.Strings = (
      'Declare @IletisimID integer, @RehberID integer'
      'set @RehberID = :PRehID'
      'set @IletisimID = :PRIID'
      '    select'
      
        '    '#9'KOD,FIRMA,GRUP,KATEGORI,DURUM,OZELKOD,NOTLAR,' +
        'YETKIKODU,'
      
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
      
        '     '#9'WEB=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER' +
        ' JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AN' +
        'D RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN=' +
        '48),'
      
        '    '#9'EMAIL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA A' +
        'ND RA.YERI=RB.YERI WHERE RB.YER_ID=@IletisimID AND RA.VARSAYILAN' +
        '=46)'
      '      from'
      '      '#9'REHBER R'
      '      WHERE ID = @RehberID')
    Left = 186
    Top = 168
  end
  object frxFatBasDetay: TfrxDBDataset
    UserName = 'frxFatBasDetay'
    CloseDataSource = False
    DataSource = DtsFatBas
    BCDToCurrency = False
    Left = 487
    Top = 177
  end
  object TabHazirlayanDetay: TFDQuery
    AutoCalcFields = False
    Connection = FDCnn
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'Declare @IletisimID integer, @RehberID integer'
      'set @RehberID = :PRehID'
      
        'select top 1 @IletisimID = ID from REHBERILETISIM where REHBERID' +
        '=@RehberID  order by VARSAYILAN desc'
      '    select'
      
        '    '#9'KOD,FIRMA,GRUP,KATEGORI,DURUM,OZELKOD,NOTLAR,' +
        'YETKIKODU,'
      
        '    '#9'KATEGORIADI=(select top 1 ANAHTAR from GENINI where BOLUM=-' +
        '2204 and DEGER=KATEGORI and DIL=-1),'
      
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
    Left = 522
    Top = 89
  end
  object frxHazirlayanDetay: TfrxDBDataset
    UserName = 'HazirlayanDetay'
    CloseDataSource = False
    DataSet = TabHazirlayanDetay
    BCDToCurrency = False
    Left = 613
    Top = 95
  end
  object Query1: TFDQuery
    Connection = FDCnn
    ParamData = <>
    Left = 90
    Top = 43
  end
  object Query9: TFDQuery
    Connection = FDCnn
    ParamData = <>
    Left = 146
    Top = 27
  end
  object Query2: TFDQuery
    Connection = FDCnn
    ParamData = <>
    Left = 18
    Top = 68
  end
  object Query3: TFDQuery
    Connection = FDCnn
    ParamData = <>
    Left = 59
    Top = 68
  end
  object cxEditRepository1: TcxEditRepository
    Left = 456
    Top = 32
    object RepDiller: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
    object RepDilCeviri: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <>
    end
  end
  object TabFatBas: TFDQuery
    Connection = FDCnn
    ParamData = <>
    SQL.Strings = (
      'select *,AD='#39#39' from FATBASLIK where ID=:PID')
    Left = 295
    Top = 160
  end
  object DtsFatBas: TDataSource
    DataSet = TabFatBas
    Left = 377
    Top = 167
  end
end


