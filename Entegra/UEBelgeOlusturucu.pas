unit UEBelgeOlusturucu;

interface

uses
  FireDAC.Comp.Client, UEBelgeGelen;

type
  TEBelgeOlusturucu = class
  public
    /// UFaturalar e-Fatura menusu icin ust seviye islemler.
    /// Bu metotlar menunun is mantigini tasir; ekran tarafinda sadece cagri ve
    /// grid yenileme kalir.
    class function MenuHazirla(AConnection: TFDConnection;
      AFatBaslikID: Integer): Boolean; static;
    class function MenuOnizle(AConnection: TFDConnection;
      AFatBaslikID: Integer): Boolean; static;
    class function MenuSifirla(AConnection: TFDConnection;
      AFatBaslikID: Integer): Boolean; static;
    class function MenuSeriDegistir(AConnection: TFDConnection;
      AFatBaslikID: Integer): Boolean; static;
    class procedure MenuHTMLKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ACariAd: string); static;
    class procedure MenuXMLKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ACariAd: string); static;
    class procedure MenuPDFKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ACariAd: string); static;
    class function MenuGonder(AConnection: TFDConnection;
      AFatBaslikID: Integer): Boolean; static;
    class function GelenFaturaCevapVer(AConnection: TFDConnection;
      AFatBaslikID: Integer; AKabul: Boolean): Boolean; static;
    class procedure KuyrukGonderimleriniIsle(AConnection: TFDConnection;
      const AFatBaslikID: Integer; out AGonderildi, AHata, AToplam: Integer;
      out AHataMesaj: string; const AIlerleme: TIlerlemeOlay = nil); static;

    class function Olustur(AConnection: TFDConnection; AFatBaslikID: Integer;
      const AAliciAlias: string; ABelgeTuruOverride: Integer = 0): Int64; static;
    class procedure Onizle(AConnection: TFDConnection;
      AFatBaslikID: Integer); static;
    class procedure HTMLKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure PDFKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure XMLKaydet(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class function Gonder(AConnection: TFDConnection;
      AFatBaslikID: Integer; const AKullanici, ASifre, ABaseURL: string;
      ATestModu: Boolean; out AYanitMesaj: string): Boolean; static;

    /// Gelen e-belge (EBELGE.YON=2) icin onizleme/dosya isleri.
    /// UBL XML'i EBELGE.UBL_XML kolonundan okur; XSLT ile HTML olusturur.
    class procedure OnizleGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer); static;
    class procedure XMLKaydetGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure HTMLKaydetGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
    class procedure PDFKaydetGelen(AConnection: TFDConnection;
      AFatBaslikID: Integer; const ADosya: string); static;
  end;

implementation

uses
  ULog, Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Classes,
  System.JSON, System.NetEncoding, System.IOUtils, System.Variants,
  System.DateUtils, Data.DB, Vcl.Dialogs, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  System.StrUtils, ComObj, Utablo, PrjConst, FetaKurulusSiniflari,
  UEBelgeAliasServis, UEBelgeKimlik, UIzibizRest, UGirisKutusuEx, UVeriMotor;

type
  // Iade faturasi (Tipi=2): iade edilen orijinal fatura referansi (cac:BillingReference)
  TEBelgeIadeRef = record
    FaturaNo: string;
    Tarih: TDateTime;
  end;

  TEBelgeBaslik = record
    ID: Integer;
    Tur: Integer;
    Tipi: Integer;
    Senaryo: Integer;
    PlanID: Integer;
    RehberID: Integer;
    EBelgeID: Int64;
    EBelgeDurum: Integer;
    Tarih: TDateTime;
    VergiNo: string;
    VergiDairesi: string;
    Baslik: string;
    CariKod: string;
    FaturaNo: string;
    IrsaliyeNo: string;
    IrsaliyeTarih: TDateTime;
    Aciklama: string;
    Aciklama2: string;
    Adres: string;
    Ilce: string;
    Il: string;
    ParaBirimi: string;
    AliciAlias: string;
    GondericiAlias: string;
    UUID: string;
    Matrah: Currency;
    KDV: Currency;
    Toplam: Currency;
    TevkifatKodu: string;
    TevkifatNedeni: string;
    KDVIstisnaKodu: string;
    KDVIstisnaNedeni: string;
    EFaturaDurum: Integer;     // FATBASLIK.EFATURADURUM (1/11/51 vs 2/12/52)
    EArsivMi: Boolean;         // EFATURADURUM in [11,12] olunca True
    EBelgeBelgeTuru: Integer;  // EBELGE.BELGETURU ? RAlias kodu (140/141/150/151)
    // Ihracat (Senaryo=3) FATURA_USER.IHRACAT JSON alanindan okunur:
    IhracatVar: Boolean;
    TeslimSartiKodu: string;   // INCOTERMS kodu (FOB, DDP...) - deliveryTerms.id
    TasimaSekliKodu: string;   // tasima modu kodu (1-8) - transportModeCode
    KapCinsiKodu: string;      // paket/kap kodu (CT, BX...) - packagingTypeCode
    FOBDeger: Currency;        // freeOnBoardValueAmount
    KapAdedi: Integer;         // actualPackage.quantity
    // Iade faturasi (Tipi=2): iade edilen orijinal fatura(lar) -> cac:BillingReference
    IadeReferanslari: TArray<TEBelgeIadeRef>;
  end;

  TEBelgeSatir = record
    SatirNo: Integer;
    UrunKodu: string;
    AliciUrunKodu: string;
    UrunAdi: string;
    Barkod: string;
    SutKodu: string;
    MarkaAdi: string;
    LotNo: string;
    SeriNo: string;
    TibbiCihazKimlik: string;
    ModelKodu: string;
    Aciklama: string;
    BirimKodu: string;
    Miktar: Double;
    BirimFiyat: Currency;
    Tutar: Currency;
    KDVOrani: Double;
    IskontoOrani: Double;
    Iskonto2Orani: Double;
    TevkifatOrani: Double;
    TevkifatKodu: string;
    TevkifatNedeni: string;
    Notu: string;
    GTIP: string;              // ihracat: satir GTIP (STOKLAR.GTIP)
  end;

  TEBelgeSatirlar = array of TEBelgeSatir;

  TEBelgeTaraf = record
    VergiNo: string;
    VergiDairesi: string;
    Unvan: string;
    Adres: string;
    Ilce: string;
    Il: string;
    Ulke: string;
    PostaKodu: string;
    Telefon: string;
    Faks: string;
    EPosta: string;
    Web: string;
    MersisNo: string;
    TicaretSicilNo: string;
  end;
  TSevkBilgisi = record
    TasiyanTipi: string;
    TasiyiciID: Integer;
    TasiyiciUnvan: string;
    TasiyiciVknTckn: string;
    Plaka: string;
    SoforID: Integer;
    SoforAdi: string;
    SoforSoyadi: string;
    SoforTckn: string;
    DorsePlaka: string;
  end;

  TEBelgeMenuBaslik = record
    ID: Integer;
    Tur: Integer;
    Senaryo: Integer;
    EFaturaDurum: Integer;
    EFaturaSonuc: Integer;
    RehberID: Integer;
    FaturaTarih: TDateTime;
    FaturaNo: string;
    FaturaSeri: string;
    VergiNo: string;
    Baslik: string;
  end;

function EBelgeGidenBaslikSQL(AFatBaslikID: Integer): string;
begin
  if AktifVeriMotor <> vmPG then begin
    Result := 'exec dbo.sp_Prog_EBelge_GidenFatura @ID=' + IntToStr(AFatBaslikID);
    Exit;
  end;

  Result :=
    'select ' +
    'FB.ID, FB.TUR, FB.TUR as BELGETURU, ' +
    'case FB.TUR when 14 then ''E-Irsaliye'' when 15 then ''E-Fatura'' end as BELGETURADI, ' +
    'FB.FATURATARIH, replace(ltrim(rtrim(coalesce(FB.VNO,''''))), '' '', '''') as VNO, FB.VD, ' +
    'coalesce(nullif(FB.BASLIK,''''), R.FIRMA) as BASLIK, R.KOD as CARIKOD, R.FIRMA as CARIUNVAN, ' +
    'FB.FATURA_MATRAHI, FB.FATURA_TUTARI, FB.KDV_TUTARI, FB.EKVERGI, FB.FATURASERI, FB.FATURANO, FB.KDVDURUM, ' +
    'case when FB.TUR=15 and coalesce(FB.SENARYO,1) in (1,2,3,7,8) then FB.SENARYO ' +
    'when FB.EFATURADURUM in (51,52) then 6 when FB.EFATURADURUM in (11,12,31,32) then 4 else coalesce(FB.SENARYO,1) end as SENARYO, ' +
    'FB.IL, FB.ILCE, FB.ADRES, FB.ACIKLAMA, coalesce(FB.ACIKLAMA2,'''') as ACIKLAMA2, coalesce(nullif(FB.KUR,''''),''TL'') as KUR, ' +
    'FB.TIPI, FB.PLANID, FB.REHBERID, FB.DOVIZ_TUTARI, FB.DOVIZ_CINSI, FB.DOVIZKUR, coalesce(nullif(FB.FATURADOVIZI,''''),''TL'') as FATURADOVIZI, ' +
    'FB.SUBEID, FB.GIRISDEPO, FB.CIKISDEPO, FB.IRSALIYENO, FB.IRSALIYETARIH, FB.EFATURADURUM, FB.EFATURASONUC, ' +
    'FB.EKLEYEN, FB.EKLEMETARIHI, FB.DEGISTIREN, FB.DEGISTIRMETARIHI, ' +
    'EB.ID as EBELGEID, coalesce(EB.DURUM,0) as EBDURUM, coalesce(EB.UUID,'''') as EBUUID, coalesce(EB.BELGENO,'''') as EBBELGENO, ' +
    'coalesce(EB.GONDERICIALIAS,'''') as GONDERICIALIAS, coalesce(nullif(EB.ALICIALIAS,''''), RA.ALIAS, '''') as ALICIALIAS, ' +
    'case when EB.ID is null then false else true end as EBELGEOLUSTU, EH.ISLEMTURU as SONISLEMTURU, EH.HTTPKODU as SONHTTPKODU, ' +
    'EH.SERVISKODU as SONSERVISKODU, EH.HATAKODU as SONHATAKODU, EH.HATAMESAJI as SONHATAMESAJI, ' +
    'EB.ID as EiInvoiceId, R.ID as EiCustomerId, R.FIRMA as EiCustomerName, coalesce(EB.DURUM,0) as EiStatus, coalesce(EB.BELGENO,'''') as EiInvoiceNo, ' +
    'false as EiIsIncomingInvoice, EH.SERVISKODU as EiProviderStatus, EB.UUID as EiUuId, case when EB.ID is null then false else true end as EiInvoiceCreated, ' +
    'true as EiAutomationInvoiceCreated, null::integer as EiAutomationId, FB.ID::varchar(15) as EiSysInvoiceNo, R.FIRMA as EiSysCustomerName, ' +
    'EH.HATAMESAJI as EiProviderDescription, case when coalesce(EB.DURUM,0)=4 then EH.HATAMESAJI else null end as EiRejectionReason, ' +
    'case when FB.EFATURADURUM in (11,12,31,32) then true else false end as EiIsEArchive, ' +
    'case when FB.TUR=14 then 7 when FB.EFATURADURUM in (11,12) then 2 when FB.EFATURADURUM in (21,22) then 3 when FB.EFATURADURUM in (31,32) then 4 else 1 end as EiInvoiceKind, ' +
    'case when FB.TUR=14 then true else false end as EiIsEWayBill, ''''::varchar(100) as CarrierName, ''''::varchar(100) as CarrierSurname, ''''::varchar(50) as CarrierIdentification, ' +
    'case when exists (select 1 from FATURA F where F.FATBASID=FB.ID and F.YERI=411) then ''IRSALIYE YERINE GECER'' else '''' end as IRSALIYE_YAZI, ' +
    'coalesce(FBU.KURUM,'''')::varchar(150) as KURUM, ''''::varchar(150) as KURUMADRES, coalesce(FBU.ISLEMNO,'''')::varchar(50) as ISLEMNO, ' +
    'coalesce(FBU.HASTA,'''') as HASTA, coalesce(to_char(FBU.OPERASYONTARIHI,''DD.MM.YYYY''),'''')::varchar(10) as OPERASYONTARIHI ' +
    'from FATBASLIK FB ' +
    'inner join REHBER R on R.ID=FB.REHBERID ' +
    'left join FATBASLIK_USER FBU on FBU.ID=FB.ID ' +
    'left join lateral (select E.* from ' + DepoTablo('EBELGE') + ' E where E.FATBASLIKID=FB.ID and E.YON=1 order by E.ID desc limit 1) EB on true ' +
    'left join lateral (select H.ISLEMTURU,H.HTTPKODU,H.SERVISKODU,H.HATAKODU,H.HATAMESAJI from ' + DepoTablo('EBELGEMESAJ') + ' H where H.EBELGEID=EB.ID order by H.ID desc limit 1) EH on true ' +
    'left join lateral (select A.ALIAS from REHBERALIAS A where A.REHBERID=FB.REHBERID and A.BELGETURU=FB.TUR and A.AKTIF=1 order by A.VARSAYILAN desc,A.ID limit 1) RA on true ' +
    'where FB.ID=' + IntToStr(AFatBaslikID) + ' and FB.TUR in (14,15) and coalesce(FB.DURUM,0)<>6';
end;

function EBelgeGidenDetaySQL(AFatBaslikID: Integer): string;
begin
  if AktifVeriMotor <> vmPG then begin
    Result := 'exec dbo.sp_Prog_EBelge_GidenFaturaDetay @invoiceId=' + IntToStr(AFatBaslikID);
    Exit;
  end;

  Result :=
    'select F.*, row_number() over(order by case when coalesce(F.SIRA,0)=0 then 2147483647 else F.SIRA end, F.ID) as LineNumber, ' +
    'case when F.TUR in (1,11) then S.STOKADI else MG.AD end as ProductName, ' +
    'case when F.TUR in (1,11) then S.KOD else MG.KOD end as ProductCode, ' +
    'case when R.OZELKOD=''DMO'' and F.TUR in (1,11) then SU.SMKODU when coalesce(R.OZELKOD,'''')<>''DMO'' and F.TUR in (1,11) then S.KOD else MG.KOD end as BuyersItemCode, ' +
    'case when F.TUR in (1,11) then S.URUNNO else MG.KOD end as ManufacturersItemCode, ' +
    'case when F.TUR in (1,11) then coalesce(S.URUNNO,'''') else '''' end as BARKOD, U.ANAHTAR as UnitName, ' +
    'case F.BIRIM when 10 then ''MIN'' when 11 then ''HUR'' when 12 then ''DAY'' when 51 then ''C62'' when 52 then ''MTR'' when 53 then ''CS'' when 54 then ''SET'' when 55 then ''SET'' when 56 then ''BX'' when 57 then ''KGM'' when 58 then ''MTK'' when 59 then ''PF'' else ''C62'' end as UnitCodeConverted, ' +
    'case when R.OZELKOD=''DMO'' and F.TUR in (1,11) then coalesce(SU.SUTKODU,'''') when F.TUR in (1,11) then coalesce(MODELG.ANAHTAR,'''') else '''' end as ModelName, ' +
    'case when FB.TUR=14 and R.OZELKOD=''DMO'' and F.TUR in (1,11) then coalesce(SU.DMOKODU,'''') when FB.TUR=15 and R.OZELKOD=''IHALE'' and F.TUR in (1,11) then coalesce(SU.IHALESIRANO,'''') when F.TUR in (1,11) then coalesce(MARKA.ANAHTAR,'''') else '''' end as BrandName, ' +
    'case when F.TUR in (1,11) then coalesce(MARKA.ANAHTAR,'''') else '''' end as ManufacturerName, ' +
    'coalesce(IZLEM.SERINO,'''') as SERINO, coalesce(IZLEM.LOTNO,'''') as LOTNO, coalesce(IZLEM.AdditionalItemIdentification,'''') as AdditionalItemIdentification, coalesce(IZLEM.Note,'''') as Note, coalesce(S.GTIP,'''') as GTIP ' +
    'from FATURA F inner join FATBASLIK FB on FB.ID=F.FATBASID inner join REHBER R on R.ID=FB.REHBERID ' +
    'left join STOKLAR S on S.ID=F.URUNID and F.TUR in (1,11) ' +
    'left join STOKLAR_USER SU on SU.ID=S.ID ' +
    'left join MASRAFGELIR MG on MG.ID=F.URUNID and F.TUR not in (1,11) ' +
    'left join lateral (select G.ANAHTAR from GENINI G where G.BOLUM=-2702 and G.DIL=-1 and G.DEGER=F.BIRIM order by G.SIRA limit 1) U on true ' +
    'left join lateral (select G.ANAHTAR from GENINI G where G.BOLUM=-2701 and G.DIL=-1 and G.DEGER=S.MARKA order by G.SIRA limit 1) MARKA on true ' +
    'left join lateral (select G.ANAHTAR from GENINI G where G.BOLUM=cast(''-2701'' || coalesce(S.MARKA,0)::varchar(10) as integer) and G.DIL=-1 and G.DEGER=S.MODEL order by G.SIRA limit 1) MODELG on true ' +
    'left join lateral (select string_agg(nullif(SL.SERINO,''''), '', '' order by SI.ID) as SERINO, ' +
    'string_agg(coalesce(nullif(SL.LOTNO,''''), nullif(SL.LOTNO_EX,'''')), '', '' order by SI.ID) as LOTNO, ' +
    'string_agg(concat(case when coalesce(S.URUNNO,'''')<>'''' then ''(UNO)'' || S.URUNNO else '''' end, case when coalesce(nullif(SL.LOTNO,''''), nullif(SL.LOTNO_EX,'''')) is not null then ''(LNO)'' || coalesce(nullif(SL.LOTNO,''''), SL.LOTNO_EX) else '''' end, case when SL.URT>date ''1990-01-01'' then ''(URT)'' || to_char(SL.URT,''YYMMDD'') else '''' end), '''' order by SI.ID) as AdditionalItemIdentification, ' +
    'string_agg(concat(case when coalesce(SL.SERINO,'''')<>'''' then ''Seri No: '' || SL.SERINO || '' '' else '''' end, case when coalesce(nullif(SL.LOTNO,''''), nullif(SL.LOTNO_EX,'''')) is not null then ''Lot No: '' || coalesce(nullif(SL.LOTNO,''''), SL.LOTNO_EX) || '' '' else '''' end, case when SL.URT>date ''1990-01-01'' then ''Uretim Tarihi: '' || to_char(SL.URT,''DD.MM.YYYY'') || '' '' else '''' end, case when SL.SKT>date ''1990-01-01'' then ''Son Kullanma Tarihi: '' || to_char(SL.SKT,''DD.MM.YYYY'') || '' '' else '''' end, case when SI.ADET is not null then ''Miktar: '' || SI.ADET::numeric(18,6)::varchar else '''' end), chr(13)||chr(10) order by SI.ID) as Note ' +
    'from STOKIZLEME SI inner join STOKSERILOT SL on SL.ID=SI.SERILOTID where SI.BASLIKID=F.FATBASID and SI.SATIRID=F.ID and SI.STOKID=F.URUNID) IZLEM on true ' +
    'where F.FATBASID=' + IntToStr(AFatBaslikID) + ' order by LineNumber';
end;

procedure PgQueryCevir(AQuery: TFDQuery);
begin
  if AktifVeriMotor = vmPG then
    AQuery.SQL.Text := PgSqlCevir(AQuery.SQL.Text);
end;

function AlanStr(ADataSet: TDataSet; const AAlan: string): string;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsString
  else
    Result := '';
end;

function AlanInt(ADataSet: TDataSet; const AAlan: string): Integer;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsInteger
  else
    Result := 0;
end;

function AlanInt64(ADataSet: TDataSet; const AAlan: string): Int64;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsLargeInt
  else
    Result := 0;
end;

function AlanFloat(ADataSet: TDataSet; const AAlan: string): Double;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsFloat
  else
    Result := 0;
end;

function AlanCurrency(ADataSet: TDataSet; const AAlan: string): Currency;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsCurrency
  else
    Result := 0;
end;

function AlanTarih(ADataSet: TDataSet; const AAlan: string): TDateTime;
var
  LField: TField;
begin
  LField := ADataSet.FindField(AAlan);
  if Assigned(LField) and not LField.IsNull then
    Result := LField.AsDateTime
  else
    Result := 0;
end;

function XMLEscape(const ADeger: string): string;
begin
  Result := StringReplace(ADeger, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
end;

function HTMLEscape(const ADeger: string): string;
begin
  Result := XMLEscape(ADeger);
  Result := StringReplace(Result, sLineBreak, '<br>', [rfReplaceAll]);
end;

function TurkceMojibakeDuzelt(const ADeger: string): string;
begin
  Result := ADeger;
  Result := StringReplace(Result, 'Ã‡', 'Ç', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ã–', 'Ö', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ãœ', 'Ü', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ä°', 'İ', [rfReplaceAll]);
  Result := StringReplace(Result, 'Äž', 'Ğ', [rfReplaceAll]);
  Result := StringReplace(Result, 'Åž', 'Ş', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ã§', 'ç', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ã¶', 'ö', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ã¼', 'ü', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ä±', 'ı', [rfReplaceAll]);
  Result := StringReplace(Result, 'ÄŸ', 'ğ', [rfReplaceAll]);
  Result := StringReplace(Result, 'ÅŸ', 'ş', [rfReplaceAll]);
end;

function Ondalik(const ADeger: Extended; const AFormat: string): string;
begin
  Result := StringReplace(FormatFloat(AFormat, ADeger), ',', '.',
    [rfReplaceAll]);
end;

function ParaBirimiNormallestir(const ADeger: string): string;
begin
  Result := UpperCase(Trim(ADeger));
  if (Result = '') or (Result = 'TL') or (Result = 'YTL') then
    Result := 'TRY';
end;

function KimlikSemasi(const AVergiNo: string): string;
begin
  if Length(Trim(AVergiNo)) = 11 then
    Result := 'TCKN'
  else
    Result := 'VKN';
end;

function FaturaTipKodu(const ABaslik: TEBelgeBaslik): string;
begin
  if ABaslik.Tipi = 2 then
    Result := 'IADE'
  else if ABaslik.Tipi in [3, 5] then
    Result := 'SATIS'
  else if ABaslik.Tipi = 9 then
    Result := 'IHRACKAYITLI'
  else if ABaslik.Tipi = 22 then
    Result := 'TEVKIFAT'
  else if ABaslik.Tipi = 24 then
    Result := 'ISTISNA'
  else
    Result := 'SATIS';
end;

function SenaryoProfilKodu(const ABaslik: TEBelgeBaslik): string;
begin
  if ABaslik.Tur = EBelgeTuruEIrsaliye then
    Exit('TEMELIRSALIYE');
  if ABaslik.EArsivMi then
    Exit('EARSIVFATURA');

  case ABaslik.Senaryo of
    2: Result := 'TICARIFATURA';
    3: Result := 'IHRACAT';
    7: Result := 'KAMU';
    8: Result := 'ILAC_TIBBICIHAZ';
  else
    Result := 'TEMELFATURA';
  end;
end;

function SatirKDVBrut(const ASatir: TEBelgeSatir): Currency;
begin
  Result := ASatir.Tutar * ASatir.KDVOrani / 100;
end;

// Satir kalemi kimlik degerleri (UBL + JSON'da ortak):
//   Alici (buyer)   = AliciUrunKodu
//   Satici (seller) = UrunKodu
//   Uretici         = SutKodu/ManufacturersItemCode
function SatirAliciKimlik(const ASatir: TEBelgeSatir): string;
begin
  Result := ASatir.AliciUrunKodu;
end;

function SatirSaticiKimlik(const ASatir: TEBelgeSatir): string;
begin
  Result := ASatir.UrunKodu;
end;

function SatirBrutTutar(const ASatir: TEBelgeSatir): Currency;
begin
  Result := ASatir.BirimFiyat * ASatir.Miktar;
end;

function SatirIskontoTutar(const ASatir: TEBelgeSatir): Currency;
var
  LBrut: Currency;
begin
  // GERCEK iskonto orani (ISKONTO/ISKONTO2) yoksa BirimFiyat*Miktar ile yuvarlanmis Tutar
  // arasindaki minik fark yuvarlama artigidir (SAHTE iskonto degil) -> 0 don. LineExtension
  // (=Tutar=round(Miktar*BirimFiyat)) GIB yuvarlama toleransi icinde kalir; PriceAmount ham
  // BirimFiyat olarak emit edilir (kullanici birim fiyatta ondalik gormesin).
  if (ASatir.IskontoOrani <= 0.001) and (ASatir.Iskonto2Orani <= 0.001) then
    Exit(0);
  LBrut := SatirBrutTutar(ASatir);
  if LBrut > ASatir.Tutar then
    Result := LBrut - ASatir.Tutar
  else
    Result := 0;
end;

function SatirIskontoOrani(const ASatir: TEBelgeSatir): Double;
var
  LBrut: Currency;
begin
  if ASatir.IskontoOrani > 0.001 then begin
    Result := ASatir.IskontoOrani;
    Exit;
  end;

  LBrut := SatirBrutTutar(ASatir);
  if LBrut > 0.0001 then
    Result := SatirIskontoTutar(ASatir) / LBrut * 100
  else
    Result := 0;
end;

function SatirlarIskontoToplami(const ASatirlar: TEBelgeSatirlar): Currency;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(ASatirlar) do
    Result := Result + SatirIskontoTutar(ASatirlar[I]);
end;

function SatirTevkifatTutar(const ASatir: TEBelgeSatir): Currency;
begin
  if ASatir.TevkifatOrani > 0.001 then
    Result := SatirKDVBrut(ASatir) * ASatir.TevkifatOrani / 100
  else
    Result := 0;
end;

function SatirlardaTevkifatVar(const ASatirlar: TEBelgeSatirlar): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(ASatirlar) do
    if SatirTevkifatTutar(ASatirlar[I]) > 0.0001 then begin
      Result := True;
      Exit;
    end;
end;

function SatirTamIskontoMu(const ASatir: TEBelgeSatir): Boolean;
begin
  Result := ((100 - ASatir.IskontoOrani) * (100 - ASatir.Iskonto2Orani) <= 0.0001);
end;

function SatirlardaTamIskontoVar(const ASatirlar: TEBelgeSatirlar): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(ASatirlar) do
    if SatirTamIskontoMu(ASatirlar[I]) then begin
      Result := True;
      Exit;
    end;
end;

function IlkUcHaneliKod(const ADeger: string): string;
var
  I: Integer;
begin
  Result := Copy(Trim(ADeger), 1, 3);
  if Length(Result) <> 3 then begin
    Result := '';
    Exit;
  end;
  for I := 1 to 3 do
    if not CharInSet(Result[I], ['0'..'9']) then begin
      Result := '';
      Exit;
    end;
end;

function MetinBasindakiAyiraclariSil(const ADeger: string): string;
begin
  Result := Trim(ADeger);
  while (Result <> '') and CharInSet(Result[1], [' ', '-', ':', '/', '\']) do
    Delete(Result, 1, 1);
end;

procedure TevkifatBilgisiGetir(ATevkifatNedeniID: Integer; out AKod,
  ANeden: string);
var
  LQuery: TFDQuery;
  LAnahtar, LKod: string;
  LDeger: Integer;
begin
  AKod := '';
  ANeden := '';
  if ATevkifatNedeniID <= 0 then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Tablo.FDCnn;
    LQuery.SQL.Text :=
      'select '+DbUst(1)+'ANAHTAR, DEGER from GENINI where BOLUM=:BOLUM and DIL=-1 ' +
      'and DEGER=:DEGER order by SIRA, ANAHTAR '+DbSinir(1);
    LQuery.ParamByName('BOLUM').AsInteger := Ops_TevkifatNedeni;
    LQuery.ParamByName('DEGER').AsInteger := ATevkifatNedeniID;
    LQuery.Open;
    if LQuery.Eof then
      Exit;

    LAnahtar := Trim(LQuery.FieldByName('ANAHTAR').AsString);
    LDeger := LQuery.FieldByName('DEGER').AsInteger;
    LKod := IlkUcHaneliKod(LAnahtar);
    if LKod = '' then
      LKod := IntToStr(LDeger);
    AKod := LKod;
    ANeden := MetinBasindakiAyiraclariSil(Copy(LAnahtar, Length(LKod) + 1, MaxInt));
    if ANeden = '' then
      ANeden := LAnahtar;
    if ANeden = '' then
      ANeden := 'Tevkifat Kodu ' + AKod;
  finally
    LQuery.Free;
  end;
end;

procedure KDVIstisnaBilgisiGetir(AIstisnaNedeniID: Integer; out AKod,
  ANeden: string);
var
  LQuery: TFDQuery;
  LAnahtar, LKod: string;
  LDeger: Integer;
begin
  AKod := '';
  ANeden := '';
  if AIstisnaNedeniID <= 0 then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Tablo.FDCnn;
    LQuery.SQL.Text :=
      'select '+DbUst(1)+'ANAHTAR, DEGER from GENINI where BOLUM=:BOLUM and DIL=-1 ' +
      'and DEGER=:DEGER order by SIRA, ANAHTAR '+DbSinir(1);
    LQuery.ParamByName('BOLUM').AsInteger := Ops_KDVIstisnaNedeni;
    LQuery.ParamByName('DEGER').AsInteger := AIstisnaNedeniID;
    LQuery.Open;
    if LQuery.Eof then
      Exit;

    LAnahtar := Trim(LQuery.FieldByName('ANAHTAR').AsString);
    LDeger := LQuery.FieldByName('DEGER').AsInteger;
    LKod := IlkUcHaneliKod(LAnahtar);
    if LKod = '' then
      LKod := IntToStr(LDeger);
    AKod := LKod;
    ANeden := MetinBasindakiAyiraclariSil(Copy(LAnahtar, Length(LKod) + 1, MaxInt));
    if ANeden = '' then
      ANeden := LAnahtar;
    if ANeden = '' then
      ANeden := 'KDV Istisna Kodu ' + AKod;
  finally
    LQuery.Free;
  end;
end;

function TevkifatKodu(const ABaslik: TEBelgeBaslik): string;
begin
  Result := Trim(ABaslik.TevkifatKodu);
  if (Result = '') and (ABaslik.PlanID > 0) then
    Result := IntToStr(ABaslik.PlanID);
end;

function TevkifatNedeni(const ABaslik: TEBelgeBaslik): string;
begin
  Result := Trim(ABaslik.TevkifatNedeni);
  if (Result = '') and (ABaslik.PlanID > 0) then
    Result := 'Tevkifat Kodu ' + TevkifatKodu(ABaslik);
end;

function KDVIstisnaKodu(const ABaslik: TEBelgeBaslik): string;
begin
  Result := Trim(ABaslik.KDVIstisnaKodu);
  if (Result = '') and (ABaslik.PlanID > 0) then
    Result := IntToStr(ABaslik.PlanID);
end;

function KDVIstisnaNedeni(const ABaslik: TEBelgeBaslik): string;
begin
  Result := Trim(ABaslik.KDVIstisnaNedeni);
  if (Result = '') and (ABaslik.PlanID > 0) then
    Result := 'KDV Istisna Kodu ' + KDVIstisnaKodu(ABaslik);
end;

// KDV tutari 0 olan 0015 grubu icin muafiyet kodu/neden (GIB schematron: TaxAmount=0
//   olan 0015 KDV -> TaxExemptionReason ZORUNLU). Kod kullanicidan secilmis olmali;
//   sessiz 351 fallback yapilmaz.
procedure KDVMuafiyetKodNeden(const ABaslik: TEBelgeBaslik; out AKod, ANeden: string);
begin
  AKod := KDVIstisnaKodu(ABaslik);
  if AKod <> '' then begin
    ANeden := AKod + ' ' + KDVIstisnaNedeni(ABaslik);
    Exit;
  end;
  raise Exception.Create('%0 KDV / muafiyetli satır için istisna nedeni seçilmemiş (FATBASLIK.PLANID).');
end;

function KDVIstisnaNotu(const ABaslik: TEBelgeBaslik): string;
begin
  Result := '';
  if not ((ABaslik.Tur = EBelgeTuruEFatura) and (ABaslik.Tipi = 24)) then
    Exit;
  if ABaslik.PlanID <= 0 then
    Exit;
  Result := 'KDV Istisna Nedeni: ' + KDVIstisnaKodu(ABaslik) + ' - ' +
    KDVIstisnaNedeni(ABaslik);
end;

// Tevkifatli faturada dip nota eklenecek aciklama: sadece tevkifat nedeni
// (kod - neden). Tevkifat yoksa '' doner. (KDVIstisnaNotu deseni.)
function TevkifatNotu(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar): string;
begin
  Result := '';
  if not ((ABaslik.Tipi = 22) or SatirlardaTevkifatVar(ASatirlar)) then
    Exit;
  if Trim(TevkifatNedeni(ABaslik)) = '' then
    Exit;
  Result := 'Tevkifat Nedeni: ' + Trim(TevkifatKodu(ABaslik)) + ' - ' +
    Trim(TevkifatNedeni(ABaslik));
end;

procedure TevkifatNedeniKontrolEt(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar);
var
  I: Integer;
  LOranVar: Boolean;
begin
  if (ABaslik.Tipi = 22) and (ABaslik.PlanID <= 0) then
    raise Exception.Create('Tevkifatli faturada (Fatura Tipi 22) tevkifat nedeni secilmemis. ' +
      'Lutfen FATBASLIK.PLANID alaninda tevkifat nedenini secin.');

  if Trim(ABaslik.TevkifatKodu) = '' then begin
    if ABaslik.PlanID <= 0 then
      raise Exception.Create('Tevkifatli belgede tevkifat nedeni secilmemis (FATBASLIK.PLANID).');
  end;

  // Tevkifatli fatura tipinde (Tipi=22) satirlarda KDV tevkifat orani
  // (FATURA.KDVMUHAFIYETI) girilmis olmali; aksi halde gecersiz tevkifatli
  // belge uretilir. En az bir satirda oran > 0 araniyor.
  if ABaslik.Tipi = 22 then begin
    LOranVar := False;
    for I := 0 to High(ASatirlar) do
      if ASatirlar[I].TevkifatOrani > 0.001 then begin
        LOranVar := True;
        Break;
      end;
    if not LOranVar then
      raise Exception.Create('Tevkifatli faturada (Fatura Tipi 22) hicbir satirda ' +
        'KDV tevkifat orani (KDVMUHAFIYETI) girilmemis. Lutfen tevkifata tabi ' +
        'satirlara tevkifat oranini girin.');
  end;
end;

procedure TamIskontoNedeniKontrolEt(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar);
var
  I: Integer;
  LUrun: string;
begin
  if not SatirlardaTamIskontoVar(ASatirlar) then
    Exit;

  if (ABaslik.PlanID > 0) and (Trim(KDVIstisnaKodu(ABaslik)) <> '') then
    Exit;

  LUrun := '';
  for I := 0 to High(ASatirlar) do
    if SatirTamIskontoMu(ASatirlar[I]) then begin
      LUrun := Trim(ASatirlar[I].UrunKodu);
      if LUrun = '' then
        LUrun := Trim(ASatirlar[I].UrunAdi);
      Break;
    end;

  raise Exception.Create('%100 iskonto satırı için tam istisna nedeni seçilmemiş ' +
    '(FATBASLIK.PLANID).' + IfThen(LUrun <> '', ' Ürün: ' + LUrun, ''));
end;

function YeniUUID: string;
begin
  Result := TGUID.NewGuid.ToString;
  Result := StringReplace(Result, '{', '', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '', [rfReplaceAll]);
end;

function GondericiAliasGetir(ABelgeTuru: Integer): string;
begin
  Result := '';
  Tablo.TablodanSorguAc(1,
    'select '+DbUst(1)+'ALIAS from REHBERALIAS where REHBERID=-1 and BELGETURU=' +
    IntToStr(ABelgeTuru) + ' and AKTIF=1 order by VARSAYILAN desc, ID '+DbSinir(1));
  if not Tablo.Query1.Eof then
    Result := Tablo.Query1.Fields[0].AsString;
end;

// e-Arsiv alicinin e-posta adresi REHBERALIAS'ta tutulur: BELGETURU=RAlias_EArsiv(150),
// ALIAS = duz mail (ör 'muhasebe@an-ka.com.tr'). Contact/ElectronicMail'e yazilir.
// Local query (XML uretim sirasinda Query1 mesgul olabilir).
function AliciEArsivEPostaGetir(ARehberID: Integer): string;
var
  LQ: TFDQuery;
begin
  Result := '';
  if ARehberID <= 0 then Exit;
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.TabBizim.Connection;
      LQ.SQL.Text :=
        'select '+DbUst(1)+'ALIAS from REHBERALIAS where REHBERID=:r and BELGETURU=:b ' +
        'and AKTIF=1 order by VARSAYILAN desc, ID '+DbSinir(1);
      LQ.ParamByName('r').AsInteger := ARehberID;
      LQ.ParamByName('b').AsInteger := RAlias_EArsiv;
      LQ.Open;
      if not LQ.IsEmpty then Result := Trim(LQ.Fields[0].AsString);
    finally
      LQ.Free;
    end;
  except
    Result := '';
  end;
end;

// Alici (cari) iletisim: e-posta + telefon REHBERILETISIM/REHBERBILGI (YERI=1)
// iletisim sisteminden okunur (REHBER'de EMAIL/telefon kolonu YOK; EPOSTA bit'tir).
// izibiz JSON customerParty.address email/telephone alanlarina gider (e-Arsiv'de
// posta iletimi icin gerekli; e-Fatura'da opsiyonel).
procedure AliciIletisimGetir(ARehberID: Integer; out AEPosta, ATelefon: string);
var
  LQ: TFDQuery;
begin
  AEPosta := '';
  ATelefon := '';
  if ARehberID <= 0 then Exit;
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.TabBizim.Connection;
      LQ.SQL.Text :=
        'SELECT ' +
        '(SELECT '+DbUst(1)+'RB.BILGI FROM REHBERBILGI RB ' +
        'INNER JOIN REHBERILETISIM RI ON RB.YER_ID=RI.ID ' +
        'WHERE RI.REHBERID=R.ID AND RB.YERI=1 AND RB.BILGI LIKE ''%@%'' '+DbSinir(1)+') AS EMAIL, ' +
        '(SELECT '+DbUst(1)+'RB.BILGI FROM REHBERBILGI RB ' +
        'INNER JOIN REHBERILETISIM RI ON RB.YER_ID=RI.ID ' +
        'INNER JOIN REHBERAYAR RA ON RA.YERI=1 AND RA.SIRA=RB.SIRA ' +
        'WHERE RI.REHBERID=R.ID AND RB.YERI=1 AND ' +
        '(RA.ETIKET LIKE ''%Tel%'' OR RA.ETIKET LIKE ''%GSM%'') '+DbSinir(1)+') AS ISTEL ' +
        'FROM REHBER R WHERE R.ID=:r';
      LQ.ParamByName('r').AsInteger := ARehberID;
      LQ.Open;
      if not LQ.IsEmpty then begin
        AEPosta := Trim(LQ.FieldByName('EMAIL').AsString);
        ATelefon := Trim(LQ.FieldByName('ISTEL').AsString);
      end;
    finally
      LQ.Free;
    end;
  except
    AEPosta := '';
    ATelefon := '';
  end;
end;
function JSONNesneStr(AObj: TJSONObject; const AAd: string): string;
var
  LVal: TJSONValue;
begin
  Result := '';
  if not Assigned(AObj) then
    Exit;
  LVal := AObj.GetValue(AAd);
  if Assigned(LVal) then
    Result := LVal.Value;
end;
function SevkBilgisiGetir(AFatBaslikID: Integer): TSevkBilgisi;
var
  LJSON: string;
  LVal: TJSONValue;
  LObj: TJSONObject;
begin
  Result := Default(TSevkBilgisi);
  Tablo.TablodanSorguAc(1,
    'select SEVKBILGISI from FATBASLIK_USER where ID=' + IntToStr(AFatBaslikID));
  if Tablo.Query1.Eof then
    Exit;
  LJSON := Trim(AlanStr(Tablo.Query1, 'SEVKBILGISI'));
  Tablo.Query1.Close;
  if LJSON = '' then
    Exit;
  LVal := TJSONObject.ParseJSONValue(LJSON);
  if not (LVal is TJSONObject) then begin
    LVal.Free;
    Exit;
  end;
  LObj := TJSONObject(LVal);
  try
    Result.TasiyanTipi := JSONNesneStr(LObj, 'tasiyanTipi');
    Result.TasiyiciID := StrToIntDef(JSONNesneStr(LObj, 'tasiyiciId'), 0);
    Result.TasiyiciUnvan := Trim(JSONNesneStr(LObj, 'tasiyiciUnvan'));
    if Result.TasiyiciUnvan = '' then
      Result.TasiyiciUnvan := Trim(JSONNesneStr(LObj, 'tasiyici'));
    Result.TasiyiciVknTckn := StringReplace(
      Trim(JSONNesneStr(LObj, 'tasiyiciVknTckn')), ' ', '', [rfReplaceAll]);
    Result.Plaka := Trim(JSONNesneStr(LObj, 'plaka'));
    Result.SoforID := StrToIntDef(JSONNesneStr(LObj, 'soforId'), 0);
    Result.SoforAdi := Trim(JSONNesneStr(LObj, 'soforAdi'));
    if Result.SoforAdi = '' then
      Result.SoforAdi := Trim(JSONNesneStr(LObj, 'sofor'));
    Result.SoforSoyadi := Trim(JSONNesneStr(LObj, 'soforSoyadi'));
    Result.SoforTckn := StringReplace(
      Trim(JSONNesneStr(LObj, 'soforTckn')), ' ', '', [rfReplaceAll]);
    Result.DorsePlaka := Trim(JSONNesneStr(LObj, 'dorsePlaka'));
  finally
    LObj.Free;
  end;
end;
function SevkTasiyiciTaraf(const ASevk: TSevkBilgisi;
  const AGonderici: TEBelgeTaraf): TEBelgeTaraf;
begin
  if SameText(Trim(ASevk.TasiyanTipi), 'kendimiz') then begin
    Result := AGonderici;
    Exit;
  end;
  Result := Default(TEBelgeTaraf);
  Result.Unvan := ASevk.TasiyiciUnvan;
  Result.VergiNo := ASevk.TasiyiciVknTckn;
  Result.Ulke := 'Turkiye';
end;
function SevkBilgisiDogrula(const ASevk: TSevkBilgisi): string;
var
  LTasiyiciTam, LSoforTam: Boolean;
begin
  // e-Irsaliye'de tasima sorumlusu zorunlu: YA tasiyici (unvan + vergi/TC no)
  // YA DA sofor (ad soyad + TC no) tam girilmelidir. Plaka zorunlu DEGILDIR.
  // "Kendimiz" tasiyorsak tasiyici = gonderici firma oldugundan tasiyici tamdir.
  LTasiyiciTam := SameText(Trim(ASevk.TasiyanTipi), 'kendimiz') or
    ((Trim(ASevk.TasiyiciUnvan) <> '') and (Trim(ASevk.TasiyiciVknTckn) <> ''));
  LSoforTam := (Trim(ASevk.SoforAdi) <> '') and (Trim(ASevk.SoforTckn) <> '');
  if LTasiyiciTam or LSoforTam then
    Result := ''
  else
    Result := 'Sevk/tasima bilgileri eksik: tasiyici unvani ve vergi no, ' +
      'VEYA sofor adi soyadi ve TC no girilmelidir.';
end;

// Sofor ad/soyadini GIB DriverPerson icin AYIRIR (FirstName + FamilyName ZORUNLU).
// - Soyad doluysa: ad->First, soyad->Family.
// - Soyad bossa: tam adi SON bosluktan ayir (sirket adi "... A.S" gibi).
// - Tek kelime ise: sema gecerliligi icin FamilyName=FirstName (nil/eksik olmasin).
procedure SoforAdSoyadAyir(const AAd, ASoyad: string; out AFirst, AFamily: string);
var
  P: Integer;
begin
  AFirst := Trim(AAd);
  AFamily := Trim(ASoyad);
  if AFamily = '' then begin
    P := LastDelimiter(' ', AFirst);
    if (P > 1) and (P < Length(AFirst)) then begin
      AFamily := Trim(Copy(AFirst, P + 1, MaxInt));
      AFirst  := Trim(Copy(AFirst, 1, P - 1));
    end else
      AFamily := AFirst;   // tek kelime -> FamilyName zorunlu oldugundan First ile ayni
  end;
end;

// "KOD - Aciklama" formatindaki ihracat JSON degerinden kodu ("KOD") ayiklar.
function IhracatKodOnEk(const S: string): string;
var
  P: Integer;
begin
  Result := Trim(S);
  P := Pos(' - ', Result);
  if P > 0 then
    Result := Trim(Copy(Result, 1, P - 1));
end;

// Ihracat JSON sayi degerini locale-bagimsiz ayristir. Grid degeri
// "12345.67" gibi NOKTA ondalik ile saklar; sistem locale ',' ise StrToCurr
// bunu bozar. Once '.' ondalik, sonra ',' ondalik dener.
function IhracatSayiParse(const S: string): Currency;
var
  LFS: TFormatSettings;
  LS: string;
begin
  Result := 0;
  LS := Trim(S);
  if LS = '' then
    Exit;
  LFS := TFormatSettings.Invariant;       // '.' ondalik, ',' binlik
  if TryStrToCurr(LS, Result, LFS) then
    Exit;
  LFS.DecimalSeparator := ',';
  LFS.ThousandSeparator := '.';
  if TryStrToCurr(LS, Result, LFS) then
    Exit;
  Result := StrToCurrDef(LS, 0);          // son care: sistem locale
end;

// Ihracat bilgilerini FATURA_USER.IHRACAT JSON alanindan okur. Kodlar combo
// metninin " - " on ekinden alinir (ornegin "FCA - Tasıyıcıya Masrafsız").
procedure IhracatBilgisiOku(AFatBaslikID: Integer; var ABaslik: TEBelgeBaslik);
var
  LQ: TFDQuery;
  LJson: string;
  LVal: TJSONValue;
  LObj: TJSONObject;
begin
  LJson := '';
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text :=
      'select top 1 FU.IHRACAT ' +
      'from FATURA_USER FU ' +
      'inner join FATURA F on F.ID=FU.ID ' +
      'where F.FATBASID=:ID and isnull(cast(FU.IHRACAT as nvarchar(max)),'''')<>'''' ' +
      'order by isnull(F.SIRA,2147483647), F.ID';
    LQ.ParamByName('ID').AsInteger := AFatBaslikID;
    LQ.Open;
    if not LQ.IsEmpty then
      LJson := Trim(LQ.FieldByName('IHRACAT').AsString);
  finally
    LQ.Free;
  end;

  if LJson <> '' then begin
    LVal := TJSONObject.ParseJSONValue(LJson);
    if LVal is TJSONObject then begin
      LObj := TJSONObject(LVal);
      try
        ABaslik.TeslimSartiKodu := IhracatKodOnEk(JSONNesneStr(LObj, 'TeslimSarti'));
        ABaslik.TasimaSekliKodu := IhracatKodOnEk(JSONNesneStr(LObj, 'TasimaSekli'));
        ABaslik.KapCinsiKodu := IhracatKodOnEk(JSONNesneStr(LObj, 'KapAmbalajCinsi'));
        ABaslik.FOBDeger := IhracatSayiParse(JSONNesneStr(LObj, 'FOBDegeri'));
        ABaslik.KapAdedi := Round(IhracatSayiParse(JSONNesneStr(LObj, 'KapAdedi')));
      finally
        LObj.Free;
      end;
    end else
      LVal.Free;
  end;

  ABaslik.IhracatVar := (ABaslik.TeslimSartiKodu <> '') or
    (ABaslik.TasimaSekliKodu <> '') or (ABaslik.KapCinsiKodu <> '') or
    (ABaslik.FOBDeger > 0);
  // Ihracat KDV istisna kodu (KDV%=0 icin taxExemptionCode) yoksa varsayilan:
  // 301 = 11/1-a Mal ihracati (GENINI BOLUM=-2333). Hizmet ihracatinda 302
  // faturada KDV istisna nedeni secilerek override edilir.
  if Trim(ABaslik.KDVIstisnaKodu) = '' then begin
    ABaslik.KDVIstisnaKodu := '301';
    ABaslik.KDVIstisnaNedeni := '11/1-a Mal ihracatı';
  end;
end;

// Ihracat faturasi icin zorunlu alanlarin eksik olanlarini satir satir dondurur
// (bos = tumu tamam). Hazirla asamasinda uyari + durdurma icin kullanilir.
function IhracatEksikAlanlar(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar): string;
var
  LEksik: TStringList;
  I: Integer;
  LGtipYok, LIhracatYok, LSatirKod: string;
  LQ: TFDQuery;
begin
  LEksik := TStringList.Create;
  try
    if Trim(ABaslik.TeslimSartiKodu) = '' then
      LEksik.Add('- Teslim Şartı (INCOTERMS)');
    if Trim(ABaslik.TasimaSekliKodu) = '' then
      LEksik.Add('- Taşıma Şekli');
    if Trim(ABaslik.KapCinsiKodu) = '' then
      LEksik.Add('- Kap / Ambalaj Cinsi');
    if ABaslik.FOBDeger <= 0 then
      LEksik.Add('- FOB Değeri');

    LIhracatYok := '';
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text :=
        'select F.ID, ' +
        'coalesce(nullif(S.KOD,''''), nullif(MG.KOD,''''), convert(nvarchar(20),F.ID)) as SATIRKOD ' +
        'from FATURA F ' +
        'left join FATURA_USER FU on FU.ID=F.ID ' +
        'left join STOKLAR S on S.ID=F.URUNID and F.TUR in (1,11) ' +
        'left join MASRAFGELIR MG on MG.ID=F.URUNID and F.TUR not in (1,11) ' +
        'where F.FATBASID=:ID and isnull(cast(FU.IHRACAT as nvarchar(max)),'''')='''' ' +
        'order by isnull(F.SIRA,2147483647), F.ID';
      LQ.ParamByName('ID').AsInteger := ABaslik.ID;
      LQ.Open;
      while not LQ.Eof do begin
        LSatirKod := Trim(LQ.FieldByName('SATIRKOD').AsString);
        if LIhracatYok <> '' then
          LIhracatYok := LIhracatYok + ', ';
        LIhracatYok := LIhracatYok + LSatirKod;
        LQ.Next;
      end;
    finally
      LQ.Free;
    end;
    if LIhracatYok <> '' then
      LEksik.Add('- İhracat bilgileri JSON (satır: ' + LIhracatYok + ')');

    // Urun satirlarinda GTIP zorunlu (ihracatta gumruk); bos olanlari topla.
    LGtipYok := '';
    for I := 0 to High(ASatirlar) do
      if (Trim(ASatirlar[I].UrunKodu) <> '') and (Trim(ASatirlar[I].GTIP) = '') then begin
        if LGtipYok <> '' then
          LGtipYok := LGtipYok + ', ';
        LGtipYok := LGtipYok + ASatirlar[I].UrunKodu;
      end;
    if LGtipYok <> '' then
      LEksik.Add('- GTIP (ürün: ' + LGtipYok + ')');
    Result  := TrimRight(LEksik.Text);
  finally
    LEksik.Free;
  end;
end;

// Iade faturasinin (Tipi=2) iade edilen ORIJINAL fatura(sini) -> cac:BillingReference.
//   GUVENILIR kaynak: iade FATBASLIK.ANAKAYITID = orijinal FATBASLIK.ID (FaturaIadeAl set eder).
//   Eski iade'de (ANAKAYITID yok) FATURA satir YERID -> orijinal FATBASLIK fallback.
function IadeReferanslariGetir(AFatBasID: Integer): TArray<TEBelgeIadeRef>;
var LRef: TEBelgeIadeRef;
  // 16-hane belge no = FATURASERI+FATURANO; ama FATURANO zaten seri ile basliyorsa
  //   cift-seri olmasin -> sadece FATURANO. (kocanno/kocanseri DEGIL, FATURANO.)
  function BelgeNoIfade(const A: string): string;
  begin
    Result := 'CASE WHEN COALESCE(' + A + '.FATURASERI, '''') <> '''' AND ' +
      A + '.FATURANO LIKE ' + A + '.FATURASERI + ''%'' THEN ' + A + '.FATURANO ' +
      'ELSE COALESCE(' + A + '.FATURASERI, '''') + COALESCE(' + A + '.FATURANO, '''') END';
  end;
begin
  SetLength(Result, 0);
  // 1) ANAKAYITID (guvenilir): iade FATBASLIK.ANAKAYITID -> orijinal FATBASLIK.
  Tablo.TablodanSorguAc(3,
    'SELECT ' + BelgeNoIfade('ORI') + ' AS BELGENO, ORI.FATURATARIH ' +
    'FROM FATBASLIK IADE INNER JOIN FATBASLIK ORI ON ORI.ID = IADE.ANAKAYITID ' +
    'WHERE IADE.ID = ' + IntToStr(AFatBasID) +
    ' AND COALESCE(IADE.ANAKAYITID, 0) > 0' +
    ' AND COALESCE(ORI.FATURANO, '''') <> ''''');
  // 2) Fallback (eski iade): FATURA satir YERID -> orijinal FATBASLIK (DISTINCT).
  if Tablo.Query3.Eof then
    Tablo.TablodanSorguAc(3,
      'SELECT DISTINCT ' + BelgeNoIfade('FB') + ' AS BELGENO, FB.FATURATARIH ' +
      'FROM FATURA F INNER JOIN FATURA OF2 ON OF2.ID = F.YERID ' +
      'INNER JOIN FATBASLIK FB ON FB.ID = OF2.FATBASID ' +
      'WHERE F.FATBASID = ' + IntToStr(AFatBasID) +
      ' AND F.YERI IN (' + IntToStr(TabNo_IADE_ALISBELGE) + ',' +
        IntToStr(TabNo_IADE_SATISBELGE) + ')' +
      ' AND FB.ID <> ' + IntToStr(AFatBasID) +
      ' AND COALESCE(FB.FATURANO, '''') <> ''''');
  while not Tablo.Query3.Eof do begin
    LRef.FaturaNo := Tablo.Query3.FieldByName('BELGENO').AsString;
    LRef.Tarih := Tablo.Query3.FieldByName('FATURATARIH').AsDateTime;
    Result := Result + [LRef];
    Tablo.Query3.Next;
  end;
  Tablo.Query3.Close;
end;

procedure VerileriOku(AFatBaslikID: Integer; out ABaslik: TEBelgeBaslik;
  out ASatirlar: TEBelgeSatirlar);
var
  LSatir: TEBelgeSatir;
  LMiktar: Double;
  LSatirID: Integer;
  LKimlikQuery: TFDQuery;
begin
  ABaslik := Default(TEBelgeBaslik);
  SetLength(ASatirlar, 0);
  LKimlikQuery := nil;

  Tablo.TablodanSorguAc(1, EBelgeGidenBaslikSQL(AFatBaslikID));
  if Tablo.Query1.Eof then
    raise Exception.Create('Giden e-belge baslik bilgisi bulunamadi.');

  ABaslik.ID := AlanInt(Tablo.Query1, 'ID');
  ABaslik.Tur := AlanInt(Tablo.Query1, 'TUR');
  ABaslik.Tipi := AlanInt(Tablo.Query1, 'TIPI');
  // Iade faturasi: iade edilen orijinal fatura referans(lar)i (cac:BillingReference)
  if ABaslik.Tipi = 2 then
    ABaslik.IadeReferanslari := IadeReferanslariGetir(AFatBaslikID);
  ABaslik.Senaryo := AlanInt(Tablo.Query1, 'SENARYO');
  ABaslik.PlanID := AlanInt(Tablo.Query1, 'PLANID');
  TevkifatBilgisiGetir(ABaslik.PlanID, ABaslik.TevkifatKodu,
    ABaslik.TevkifatNedeni);
  // KDV istisna kodu: Tipi=24 (KDV istisna faturasi) veya Senaryo=3 (ihracat)
  // -> izibiz KDV%=0'da taxExemptionCode zorunlu kilar.
  if (ABaslik.Tipi = 24) or (ABaslik.Senaryo = 3) then
    KDVIstisnaBilgisiGetir(ABaslik.PlanID, ABaslik.KDVIstisnaKodu,
      ABaslik.KDVIstisnaNedeni);
  ABaslik.RehberID := AlanInt(Tablo.Query1, 'REHBERID');
  ABaslik.EBelgeID := AlanInt64(Tablo.Query1, 'EBELGEID');
  ABaslik.EBelgeDurum := AlanInt(Tablo.Query1, 'EBDURUM');
  ABaslik.EFaturaDurum := AlanInt(Tablo.Query1, 'EFATURADURUM');
  ABaslik.EArsivMi := ABaslik.EFaturaDurum in [11, 12];
  ABaslik.Tarih := AlanTarih(Tablo.Query1, 'FATURATARIH');
  ABaslik.VergiNo := AlanStr(Tablo.Query1, 'VNO');
  ABaslik.VergiDairesi := AlanStr(Tablo.Query1, 'VD');
  ABaslik.Baslik := AlanStr(Tablo.Query1, 'BASLIK');
  ABaslik.CariKod := AlanStr(Tablo.Query1, 'CARIKOD');
  ABaslik.FaturaNo := AlanStr(Tablo.Query1, 'FATURANO');
  ABaslik.IrsaliyeNo := AlanStr(Tablo.Query1, 'IRSALIYENO');
  ABaslik.IrsaliyeTarih := AlanTarih(Tablo.Query1, 'IRSALIYETARIH');
  ABaslik.Aciklama := AlanStr(Tablo.Query1, 'ACIKLAMA');
  ABaslik.Aciklama2 := AlanStr(Tablo.Query1, 'ACIKLAMA2');
  ABaslik.Adres := AlanStr(Tablo.Query1, 'ADRES');
  ABaslik.Ilce := AlanStr(Tablo.Query1, 'ILCE');
  ABaslik.Il := AlanStr(Tablo.Query1, 'IL');
  ABaslik.ParaBirimi := ParaBirimiNormallestir(
    AlanStr(Tablo.Query1, 'FATURADOVIZI'));
  ABaslik.AliciAlias := AlanStr(Tablo.Query1, 'ALICIALIAS');
  ABaslik.GondericiAlias := AlanStr(Tablo.Query1, 'GONDERICIALIAS');
  ABaslik.UUID := AlanStr(Tablo.Query1, 'EBUUID');
  ABaslik.Matrah := AlanCurrency(Tablo.Query1, 'FATURA_MATRAHI');
  ABaslik.KDV := AlanCurrency(Tablo.Query1, 'KDV_TUTARI');
  ABaslik.Toplam := AlanCurrency(Tablo.Query1, 'FATURA_TUTARI');

  // Ihracat faturasi (Senaryo=3): FATURA_USER.IHRACAT JSON alanindan teslim
  // sarti, tasima, kap, FOB, kap adedi oku (JSON delivery/shipment icin).
  if ABaslik.Senaryo = 3 then
    IhracatBilgisiOku(AFatBaslikID, ABaslik);

  Tablo.TablodanSorguAc(1, EBelgeGidenDetaySQL(AFatBaslikID));
  try
    while not Tablo.Query1.Eof do begin
      LSatir := Default(TEBelgeSatir);
      LSatirID := AlanInt(Tablo.Query1, 'ID');
      LSatir.SatirNo := AlanInt(Tablo.Query1, 'LineNumber');
      LSatir.UrunKodu := AlanStr(Tablo.Query1, 'ProductCode');
      LSatir.AliciUrunKodu := AlanStr(Tablo.Query1, 'BuyersItemCode');
      LSatir.UrunAdi := AlanStr(Tablo.Query1, 'ProductName');
      LSatir.Barkod := AlanStr(Tablo.Query1, 'BARKOD');
      LSatir.SutKodu := AlanStr(Tablo.Query1, 'ManufacturersItemCode');
      LSatir.MarkaAdi := AlanStr(Tablo.Query1, 'BrandName');
      LSatir.LotNo := AlanStr(Tablo.Query1, 'LOTNO');
      LSatir.SeriNo := AlanStr(Tablo.Query1, 'SERINO');
      LSatir.TibbiCihazKimlik := AlanStr(Tablo.Query1, 'AdditionalItemIdentification');
      LSatir.ModelKodu := AlanStr(Tablo.Query1, 'ModelName');
      if (ABaslik.Senaryo = 8) and (Trim(LSatir.TibbiCihazKimlik) = '') and
        (LSatirID > 0) then begin
        if not Assigned(LKimlikQuery) then begin
          LKimlikQuery := TFDQuery.Create(nil);
          LKimlikQuery.Connection := Tablo.FDCnn;
          if AktifVeriMotor = vmPG then
            LKimlikQuery.SQL.Text :=
              'select coalesce(string_agg(concat(' +
              'case when coalesce(S.URUNNO,'''')<>'''' then ''(UNO)'' || S.URUNNO else '''' end, ' +
              'case when coalesce(nullif(SL.LOTNO,''''), nullif(SL.LOTNO_EX,'''')) is not null then ''(LNO)'' || coalesce(nullif(SL.LOTNO,''''), SL.LOTNO_EX) else '''' end, ' +
              'case when SL.URT>date ''1990-01-01'' then ''(URT)'' || to_char(SL.URT,''YYMMDD'') else '''' end), '''' order by SI.ID), '''') as KIMLIK ' +
              'from STOKIZLEME SI inner join STOKSERILOT SL on SL.ID=SI.SERILOTID ' +
              'inner join STOKLAR S on S.ID=SI.STOKID ' +
              'where SI.BASLIKID=:FATBASID and SI.SATIRID=:SATIRID'
          else
            LKimlikQuery.SQL.Text :=
              'select dbo.fn_Efatura_AdditionalItemIdentification(:FATBASID,:SATIRID) as KIMLIK';
        end;
        LKimlikQuery.Close;
        LKimlikQuery.ParamByName('FATBASID').AsInteger := AFatBaslikID;
        LKimlikQuery.ParamByName('SATIRID').AsInteger := LSatirID;
        LKimlikQuery.Open;
        LSatir.TibbiCihazKimlik := AlanStr(LKimlikQuery, 'KIMLIK');
      end;
      LSatir.Aciklama := AlanStr(Tablo.Query1, 'ACIKLAMA');
      // E-fatura satir adi = urun/hizmet adi + 1 bosluk + FATURA.ACIKLAMA (kullanici istegi).
      //   UrunAdi tum ciktilarda kullanilir (UBL <cbc:Name>, izibiz JSON itemName, HTML) -> tek yerde.
      //   Satir ACIKLAMA'si baska yerde emit edilmiyor (mukerrerlik yok). Bos ise ek yapma.
      if Trim(LSatir.Aciklama) <> '' then
        LSatir.UrunAdi := Trim(LSatir.UrunAdi) + ' ' + Trim(LSatir.Aciklama);
      LSatir.BirimKodu := AlanStr(Tablo.Query1, 'UnitCodeConverted');
      LMiktar := AlanFloat(Tablo.Query1, 'MIKTAR');
      if LMiktar = 0 then
        LMiktar := AlanFloat(Tablo.Query1, 'ADET');
      if LMiktar = 0 then
        LMiktar := 1;
      LSatir.Miktar := LMiktar;
      LSatir.BirimFiyat := AlanCurrency(Tablo.Query1, 'BIRIMFIYAT');
      LSatir.Tutar := AlanCurrency(Tablo.Query1, 'TUTAR');
      LSatir.KDVOrani := AlanFloat(Tablo.Query1, 'KDV');
      LSatir.IskontoOrani := AlanFloat(Tablo.Query1, 'ISKONTO');
      LSatir.Iskonto2Orani := AlanFloat(Tablo.Query1, 'ISKONTO2');
      LSatir.TevkifatOrani := AlanFloat(Tablo.Query1, 'KDVMUHAFIYETI');
      LSatir.Notu := AlanStr(Tablo.Query1, 'Note');
      LSatir.GTIP := AlanStr(Tablo.Query1, 'GTIP');
      SetLength(ASatirlar, Length(ASatirlar) + 1);
      ASatirlar[High(ASatirlar)] := LSatir;
      Tablo.Query1.Next;
    end;

    if SatirlardaTamIskontoVar(ASatirlar) and (ABaslik.PlanID > 0) and
       (Trim(ABaslik.KDVIstisnaKodu) = '') then
      KDVIstisnaBilgisiGetir(ABaslik.PlanID, ABaslik.KDVIstisnaKodu,
        ABaslik.KDVIstisnaNedeni);
  finally
    LKimlikQuery.Free;
  end;
end;

function PartyXML(const ARol: string; const ATaraf: TEBelgeTaraf): string;
var
  LXML: TStringBuilder;
begin
  LXML := TStringBuilder.Create;
  try
    LXML.AppendLine('<cac:' + ARol + '>');
    LXML.AppendLine('<cac:Party>');
    if Trim(ATaraf.Web) <> '' then
      LXML.AppendLine('<cbc:WebsiteURI>' + XMLEscape(ATaraf.Web) +
        '</cbc:WebsiteURI>');
    if Trim(ATaraf.VergiNo) <> '' then
      LXML.AppendLine('<cac:PartyIdentification><cbc:ID schemeID="' +
        KimlikSemasi(ATaraf.VergiNo) + '">' + XMLEscape(ATaraf.VergiNo) +
        '</cbc:ID></cac:PartyIdentification>');
    // MERSIS No / Ticaret Sicil No (REHBERBILGI ticari bilgiler) -> ek PartyIdentification.
    if Trim(ATaraf.MersisNo) <> '' then
      LXML.AppendLine('<cac:PartyIdentification><cbc:ID schemeID="MERSISNO">' +
        XMLEscape(ATaraf.MersisNo) + '</cbc:ID></cac:PartyIdentification>');
    if Trim(ATaraf.TicaretSicilNo) <> '' then
      LXML.AppendLine('<cac:PartyIdentification><cbc:ID schemeID="TICARETSICILNO">' +
        XMLEscape(ATaraf.TicaretSicilNo) + '</cbc:ID></cac:PartyIdentification>');
    LXML.AppendLine('<cac:PartyName><cbc:Name>' + XMLEscape(ATaraf.Unvan) +
      '</cbc:Name></cac:PartyName>');
    LXML.AppendLine('<cac:PostalAddress>');
    if Trim(ATaraf.Adres) <> '' then
      LXML.AppendLine('<cbc:StreetName>' + XMLEscape(ATaraf.Adres) +
        '</cbc:StreetName>');
    if Trim(ATaraf.Ilce) <> '' then
      LXML.AppendLine('<cbc:CitySubdivisionName>' + XMLEscape(ATaraf.Ilce) +
        '</cbc:CitySubdivisionName>');
    if Trim(ATaraf.Il) <> '' then
      LXML.AppendLine('<cbc:CityName>' + XMLEscape(ATaraf.Il) +
        '</cbc:CityName>');
    if Trim(ATaraf.PostaKodu) <> '' then
      LXML.AppendLine('<cbc:PostalZone>' + XMLEscape(ATaraf.PostaKodu) +
        '</cbc:PostalZone>');
    if Trim(ATaraf.Ulke) = '' then
      LXML.AppendLine('<cac:Country><cbc:Name>Turkiye</cbc:Name></cac:Country>')
    else
      LXML.AppendLine('<cac:Country><cbc:Name>' + XMLEscape(ATaraf.Ulke) +
        '</cbc:Name></cac:Country>');
    LXML.AppendLine('</cac:PostalAddress>');
    if Trim(ATaraf.VergiDairesi) <> '' then
      LXML.AppendLine('<cac:PartyTaxScheme><cac:TaxScheme><cbc:Name>' +
        XMLEscape(ATaraf.VergiDairesi) +
        '</cbc:Name></cac:TaxScheme></cac:PartyTaxScheme>');
    LXML.AppendLine('<cac:PartyLegalEntity><cbc:RegistrationName>' +
      XMLEscape(ATaraf.Unvan) +
      '</cbc:RegistrationName></cac:PartyLegalEntity>');
    if (Trim(ATaraf.Telefon) <> '') or (Trim(ATaraf.Faks) <> '') or
      (Trim(ATaraf.EPosta) <> '') then begin
      LXML.AppendLine('<cac:Contact>');
      if Trim(ATaraf.Telefon) <> '' then
        LXML.AppendLine('<cbc:Telephone>' + XMLEscape(ATaraf.Telefon) +
          '</cbc:Telephone>');
      if Trim(ATaraf.Faks) <> '' then
        LXML.AppendLine('<cbc:Telefax>' + XMLEscape(ATaraf.Faks) +
          '</cbc:Telefax>');
      if Trim(ATaraf.EPosta) <> '' then
        LXML.AppendLine('<cbc:ElectronicMail>' + XMLEscape(ATaraf.EPosta) +
          '</cbc:ElectronicMail>');
      LXML.AppendLine('</cac:Contact>');
    end;
    LXML.AppendLine('</cac:Party>');
    LXML.AppendLine('</cac:' + ARol + '>');
    Result := LXML.ToString;
  finally
    LXML.Free;
  end;
end;

type
  TKimlikParca = record
    Deger: string;
    Scheme: string;
  end;

// TibbiCihazKimlik string'ini { ... } parcalarina bolup temizler; her parca icin
// (deger, schemeID) doner. Bos ise placeholder ('1111111111','DIGER'), tek parca
// (parantezsiz) ise TIBBICIHAZ, coklu {..} ise her biri TIBBICIHAZ.
// XML (TibbiCihazKimlikXMLYaz) ve JSON (TibbiCihazKimlikJSONDizi) bunu ortak kullanir.
function TibbiCihazKimlikParcala(const AKimlik: string): TArray<TKimlikParca>;

  procedure Ekle(const ADeger, ASchemeID: string);
  var
    LTemiz: string;
  begin
    LTemiz := Trim(ADeger);
    while (LTemiz <> '') and (LTemiz[1] = '{') do begin
      Delete(LTemiz, 1, 1);
      LTemiz := Trim(LTemiz);
    end;
    while (LTemiz <> '') and (LTemiz[Length(LTemiz)] = '}') do begin
      Delete(LTemiz, Length(LTemiz), 1);
      LTemiz := Trim(LTemiz);
    end;
    if LTemiz = '' then
      Exit;
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)].Deger := LTemiz;
    Result[High(Result)].Scheme := ASchemeID;
  end;

var
  LDeger, LParca: string;
  LBas, LSon: Integer;
begin
  Result := nil;
  LDeger := Trim(AKimlik);
  if LDeger = '' then begin
    Ekle('1111111111', 'DIGER');
    Exit;
  end;
  if Pos('{', LDeger) = 0 then begin
    Ekle(LDeger, 'TIBBICIHAZ');
    Exit;
  end;
  while LDeger <> '' do begin
    LBas := Pos('{', LDeger);
    if LBas = 0 then
      Break;
    Delete(LDeger, 1, LBas);
    LSon := Pos('}', LDeger);
    if LSon = 0 then begin
      Ekle(LDeger, 'TIBBICIHAZ');
      Break;
    end;
    LParca := Copy(LDeger, 1, LSon - 1);
    Ekle(LParca, 'TIBBICIHAZ');
    Delete(LDeger, 1, LSon);
  end;
end;

// UBL: her parca icin <cac:AdditionalItemIdentification> yazar.
procedure TibbiCihazKimlikXMLYaz(AXML: TStringBuilder; const AKimlik: string);
var
  LParca: TKimlikParca;
begin
  for LParca in TibbiCihazKimlikParcala(AKimlik) do begin
    AXML.AppendLine('<cac:AdditionalItemIdentification>');
    AXML.AppendLine('<cbc:ID schemeID="' + XMLEscape(LParca.Scheme) + '">' +
      XMLEscape(LParca.Deger) + '</cbc:ID>');
    AXML.AppendLine('</cac:AdditionalItemIdentification>');
  end;
end;

// JSON: Izibiz earchives "additionalItemIdentifications":[{schemeID,itemIdentification}].
function TibbiCihazKimlikJSONDizi(const AKimlik: string): TJSONArray;
var
  LParca: TKimlikParca;
  LObj: TJSONObject;
begin
  Result := TJSONArray.Create;
  for LParca in TibbiCihazKimlikParcala(AKimlik) do begin
    LObj := TJSONObject.Create;
    LObj.AddPair('schemeID', LParca.Scheme);
    LObj.AddPair('itemIdentification', LParca.Deger);
    Result.AddElement(LObj);
  end;
end;

// REHBERBILGI (etiket-deger tablosu) firma/cari ek bilgisi okur.
// "Ticari bilgiler": YER_ID=REHBERID (bizim firma=-1), YERI=2, ETIKET (ör 'Mersis No').
// ETIKET'e gore eslesir (SIRA'dan bagimsiz, sagliklidir).
function RehberBilgiGetir(AYerID: Integer; const AEtiketLike: string): string;
var
  LQ: TFDQuery;
begin
  Result := '';
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.TabBizim.Connection;
      LQ.SQL.Text :=
        'SELECT '+DbUst(1)+'BILGI FROM REHBERBILGI ' +
        'WHERE YER_ID=:y AND YERI=2 AND ETIKET LIKE :e AND ISNULL(BILGI,'''')<>'''' ' +
        'ORDER BY SIRA '+DbSinir(1);
      LQ.ParamByName('y').AsInteger := AYerID;
      LQ.ParamByName('e').AsString := AEtiketLike;
      LQ.Open;
      if not LQ.IsEmpty then Result := Trim(LQ.Fields[0].AsString);
    finally
      LQ.Free;
    end;
  except
    Result := '';
  end;
end;

function BizimTarafGetir(const AVergiNo, AUnvan: string): TEBelgeTaraf;
begin
  Result := Default(TEBelgeTaraf);
  Result.VergiNo := AVergiNo;
  Result.Unvan := AUnvan;

  if not Tablo.TabBizim.Active then
    Tablo.TabBizim.Open;
  if Tablo.TabBizim.IsEmpty then
    Exit;

  Result.VergiNo := AlanStr(Tablo.TabBizim, 'VERGINO');
  Result.VergiDairesi := AlanStr(Tablo.TabBizim, 'VERGIDAI');
  Result.Unvan := AlanStr(Tablo.TabBizim, 'FATURABASLIK');
  if Trim(Result.Unvan) = '' then
    Result.Unvan := AlanStr(Tablo.TabBizim, 'FIRMA');
  Result.Adres := AlanStr(Tablo.TabBizim, 'ADRES');
  Result.Ilce := AlanStr(Tablo.TabBizim, 'ILCE');
  Result.Il := AlanStr(Tablo.TabBizim, 'IL');
  Result.Ulke := AlanStr(Tablo.TabBizim, 'ULKE');
  Result.PostaKodu := AlanStr(Tablo.TabBizim, 'PK');
  Result.Telefon := AlanStr(Tablo.TabBizim, 'ISTEL');
  Result.Faks := AlanStr(Tablo.TabBizim, 'FAX');
  Result.EPosta := AlanStr(Tablo.TabBizim, 'EMAIL');
  Result.Web := AlanStr(Tablo.TabBizim, 'WEB');

  // Ticari bilgiler (REHBERBILGI, bizim firma=-1): Mersis / Ticaret Sicil No.
  // Mersis 16 hane -> bosluklar atilir; Ticaret Sicil ham (ör '918211-0').
  Result.MersisNo := StringReplace(RehberBilgiGetir(-1, '%ersis%'), ' ', '', [rfReplaceAll]);
  Result.TicaretSicilNo := RehberBilgiGetir(-1, '%icil%');

  if Trim(Result.VergiNo) = '' then
    Result.VergiNo := AVergiNo;
  Result.VergiNo := StringReplace(Result.VergiNo, ' ', '', [rfReplaceAll]);
  if Trim(Result.Unvan) = '' then
    Result.Unvan := AUnvan;
end;

// ----- Sabit not (e-Belge dipnotlari) yardimcilari -------------------------

// Uc basamakli (0..999) tam sayiyi Turkce yaziya cevirir. "Yuz" basinda "Bir"
// kullanilmaz (100 -> "Yuz", 200 -> "IkiYuz").
function UcBasamakYaziya(N: Integer): string;
const
  BIRLER: array[0..9] of string = ('', 'Bir', 'İki', 'Üç', 'Dört', 'Beş',
    'Altı', 'Yedi', 'Sekiz', 'Dokuz');
  ONLAR: array[0..9] of string = ('', 'On', 'Yirmi', 'Otuz', 'Kırk', 'Elli',
    'Altmış', 'Yetmiş', 'Seksen', 'Doksan');
var
  Y, O, B: Integer;
begin
  Result := '';
  Y := N div 100;
  O := (N mod 100) div 10;
  B := N mod 10;
  if Y = 1 then
    Result := 'Yüz'
  else if Y > 1 then
    Result := BIRLER[Y] + 'Yüz';
  Result := Result + ONLAR[O] + BIRLER[B];
end;

// Tam sayiyi (milyara kadar) Turkce yaziya cevirir. "Bin" basinda "Bir"
// kullanilmaz (1000 -> "Bin", 2000 -> "İkiBin").
function TamSayiYaziya(N: Int64): string;
var
  LMilyar, LMilyon, LBin, LYuz: Integer;
begin
  if N <= 0 then
    Exit('Sıfır');
  Result := '';
  LMilyar := N div 1000000000;
  LMilyon := (N div 1000000) mod 1000;
  LBin := (N div 1000) mod 1000;
  LYuz := N mod 1000;
  if LMilyar > 0 then
    Result := Result + UcBasamakYaziya(LMilyar) + 'Milyar';
  if LMilyon > 0 then
    Result := Result + UcBasamakYaziya(LMilyon) + 'Milyon';
  if LBin = 1 then
    Result := Result + 'Bin'
  else if LBin > 1 then
    Result := Result + UcBasamakYaziya(LBin) + 'Bin';
  if LYuz > 0 then
    Result := Result + UcBasamakYaziya(LYuz);
  if Result = '' then
    Result := 'Sıfır';
end;

// Para tutarini "Yalniz" ifadesinde kullanilacak sekilde yaziya cevirir.
// Ornek: 1234.56 TRY -> "BinİkiyüzOtuzdört Türk Lirası Ellialtı Kuruş".
function TutarYaziya(ATutar: Currency; const AParaBirimi: string): string;
var
  LToplamKurus: Int64;
  LTam: Int64;
  LKurus: Integer;
  LLiraAdi, LKurusAdi, LPB: string;
begin
  LToplamKurus := Round(ATutar * 100);
  if LToplamKurus < 0 then
    LToplamKurus := -LToplamKurus;
  LTam := LToplamKurus div 100;
  LKurus := LToplamKurus mod 100;

  LPB := UpperCase(Trim(AParaBirimi));
  if (LPB = 'USD') then begin
    LLiraAdi := 'ABD Doları'; LKurusAdi := 'Cent';
  end else if (LPB = 'EUR') then begin
    LLiraAdi := 'Euro'; LKurusAdi := 'Cent';
  end else if (LPB = 'GBP') then begin
    LLiraAdi := 'İngiliz Sterlini'; LKurusAdi := 'Peni';
  end else begin
    LLiraAdi := 'Türk Lirası'; LKurusAdi := 'Kuruş';
  end;

  Result := TamSayiYaziya(LTam) + ' ' + LLiraAdi;
  if LKurus > 0 then
    Result := Result + ' ' + TamSayiYaziya(LKurus) + ' ' + LKurusAdi;
end;

// Bir sabit not satirindaki yer tutucularini gercek degerlerle degistirir.
//   {ALANADI}            -> AKaynaklar'daki ilk eslesen alanin icerigi
//   {PaymentTotalAsText} -> toplam tutar yaziyla (alan degil, ozel hesap)
// AKaynaklar oncelik sirasinda verilir: sp_Prog_EBelge_GidenFatura -> FATBASLIK_USER -> FATBASLIK.
// Hicbir kaynakta karsiligi olmayan token oldugu gibi birakilir.
function SabitNotYerTutucuDegistir(const ASatir: string;
  const ABaslik: TEBelgeBaslik; const AKaynaklar: array of TDataSet): string;
var
  LBaslangic, LBitis, K: Integer;
  LToken, LDeger: string;
  LField: TField;
begin
  Result := ASatir;
  // Ozel token: yaziyla toplam tutar
  Result := StringReplace(Result, '{PaymentTotalAsText}',
    TutarYaziya(ABaslik.Toplam, ABaslik.ParaBirimi), [rfReplaceAll, rfIgnoreCase]);

  // {ALAN} tokenlarini kaynaklardaki ayni adli alanin degeriyle (oncelik sirasiyla) degistir
  LBaslangic := 1;
  while True do begin
    LBaslangic := PosEx('{', Result, LBaslangic);
    if LBaslangic = 0 then
      Break;
    LBitis := PosEx('}', Result, LBaslangic + 1);
    if LBitis = 0 then
      Break;
    LToken := Trim(Copy(Result, LBaslangic + 1, LBitis - LBaslangic - 1));
    LField := nil;
    if LToken <> '' then
      for K := 0 to High(AKaynaklar) do
        if AKaynaklar[K] <> nil then begin
          LField := AKaynaklar[K].FindField(LToken);
          if LField <> nil then
            Break;
        end;
    if LField <> nil then begin
      if LField.IsNull then
        LDeger := ''
      else if LField.DataType in [ftDate, ftDateTime, ftTimeStamp, ftTime] then
        LDeger := FormatDateTime('dd.mm.yyyy', LField.AsDateTime)
      else
        LDeger := Trim(LField.AsString);
      Result := Copy(Result, 1, LBaslangic - 1) + LDeger +
                Copy(Result, LBitis + 1, MaxInt);
      LBaslangic := LBaslangic + Length(LDeger);  // degerden sonrasini tara
    end else
      LBaslangic := LBitis + 1;  // bilinmeyen token: oldugu gibi birak, sonrakine gec
  end;
end;

// Belge tipine (e-Fatura / e-Arsiv / e-Irsaliye) gore GENINI'den sabit not
// sablonunu okur, satir satir yer tutuculari degistirir ve bos olmayan
// satirlari dondurur. Sablon tanimli degilse bos dizi doner.
function SabitNotlariGetir(const ABaslik: TEBelgeBaslik): TArray<string>;
var
  LAnahtar: Integer;
  LSablon, LSatir: string;
  LSatirlar: TStringList;
  LFat, LFatU, LSp: TFDQuery;
  I: Integer;
begin
  SetLength(Result, 0);

  // Once cariye ait fatura dip notu (GOREVYORUM TUR=400); doluysa onu kullan.
  LSablon := '';
  if ABaslik.RehberID > 0 then begin
    Tablo.TablodanSorguAc(1,
      'select '+DbUst(1)+'YORUM from GOREVYORUM where TUR=400 and GOREVID=' +
      IntToStr(ABaslik.RehberID) + ' order by ID '+DbSinir(1));
    if not Tablo.Query1.Eof then
      LSablon := Trim(Tablo.Query1.FieldByName('YORUM').AsString);
    Tablo.Query1.Close;
  end;

  // Cariye ait dip notu yoksa belge tipinin default sabit notunu kullan.
  if LSablon = '' then begin
    if ABaslik.Tur = EBelgeTuruEIrsaliye then
      LAnahtar := Ops_FaturaOpsiyon_EIrsaliyeSabitNotlar
    else if ABaslik.EArsivMi then
      LAnahtar := Ops_FaturaOpsiyon_EArsivFaturaSabitNotlar
    else
      LAnahtar := Ops_FaturaOpsiyon_EFaturaSabitNotlar;
    LSablon := Trim(Tablo.GENINI.ReadString(LAnahtar, ''));
  end;

  if LSablon = '' then
    Exit;

  // {ALAN} yer tutucularinda kullanmak uzere FATBASLIK satirini ve uzantisi
  // FATBASLIK_USER'i (varsa, musteriye ozel ek alanlar burada olabilir) oku.
  LSp := TFDQuery.Create(nil);
  LFat := TFDQuery.Create(nil);
  LFatU := nil;
  try
    // 1. oncelik: sp_Prog_EBelge_GidenFatura SP ciktisi (e-belgeye giden degerler)
    LSp.Connection := Tablo.FDCnn;
    LSp.SQL.Text := EBelgeGidenBaslikSQL(ABaslik.ID);
    LSp.Open;

    // 3. oncelik: FATBASLIK
    LFat.Connection := Tablo.FDCnn;
    LFat.SQL.Text := 'select * from FATBASLIK where ID=' + IntToStr(ABaslik.ID);
    LFat.Open;

    // 2. oncelik: FATBASLIK_USER (uzanti) varsa; musteriye ozel ek alanlar burada olabilir.
    if ((AktifVeriMotor = vmPG) and Veritabani.VeriVarMi(Tablo.FDCnn,
         'select 1 as X where to_regclass(''fatbaslik_user'') is not null', [], [])) or
       ((AktifVeriMotor <> vmPG) and Veritabani.VeriVarMi(Tablo.FDCnn,
         'select 1 X where object_id(''dbo.FATBASLIK_USER'',''U'') is not null', [], [])) then begin
      LFatU := TFDQuery.Create(nil);
      LFatU.Connection := Tablo.FDCnn;
      LFatU.SQL.Text := 'select * from FATBASLIK_USER where ID=' + IntToStr(ABaslik.ID);
      LFatU.Open;
    end;

    LSatirlar := TStringList.Create;
    try
      LSatirlar.Text := LSablon;
      for I := 0 to LSatirlar.Count - 1 do begin
        // Oncelik: SP -> FATBASLIK_USER -> FATBASLIK
        LSatir := Trim(SabitNotYerTutucuDegistir(LSatirlar[I], ABaslik, [LSp, LFatU, LFat]));
        if LSatir <> '' then begin
          SetLength(Result, Length(Result) + 1);
          Result[High(Result)] := LSatir;
        end;
      end;
    finally
      LSatirlar.Free;
    end;
  finally
    LSp.Free;
    LFat.Free;
    LFatU.Free;   // nil ise zararsiz
  end;
end;

function BelgeXSLTGetir(ARehberID, ABelgeTuru: Integer;
  AEArsivMi, AGelenMi: Boolean; out AXSLT: string): Boolean; forward;
function OrnekEArsivXSLTGetir(out AXSLT: string): Boolean; forward;
function GumrukPartyXML(const ARol: string): string; forward;
function IhracatSatirDeliveryXML(const ABaslik: TEBelgeBaslik;
  const ASatir: TEBelgeSatir): string; forward;

function Base64TekSatir(const ABytes: TBytes): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(ABytes);
  Result := StringReplace(Result, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '', [rfReplaceAll]);
end;

function UBLXMLUret(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar; const AGondericiVergiNo,
  AGondericiUnvan: string): string;
var
  LXML: TStringBuilder;
  I, J: Integer;
  LSatirVergi, LSatirTevkifat, LSatirIskonto, LSatirBrut, LToplamMatrah, LToplamVergi,
    LToplamTevkifat, LToplamIskonto, LGrupMatrah, LGrupVergi,
    LGrupTevkifat: Currency;
  LSatirTuru, LMiktarTuru, LRoot, LProfil, LXSLT, LIstisnaNotu,
    LSatirNotu, LSatirIstisnaXml: string;
  LGonderici, LAlici, LTasiyici: TEBelgeTaraf;
  LSevk: TSevkBilgisi;
  LTevkifatVar, LOranIslendi: Boolean;
  LSabitNotlar: TArray<string>;
  LNotlar: TArray<string>;
begin
  if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
    LRoot := 'DespatchAdvice';
    LSatirTuru := 'DespatchLine';
    LMiktarTuru := 'DeliveredQuantity';
  end else if ABaslik.EArsivMi then begin
    LRoot := 'Invoice';
    LSatirTuru := 'InvoiceLine';
    LMiktarTuru := 'InvoicedQuantity';
  end else begin
    LRoot := 'Invoice';
    LSatirTuru := 'InvoiceLine';
    LMiktarTuru := 'InvoicedQuantity';
  end;
  LProfil := SenaryoProfilKodu(ABaslik);

  LGonderici := BizimTarafGetir(AGondericiVergiNo, AGondericiUnvan);
  LSevk := Default(TSevkBilgisi);
  LTasiyici := Default(TEBelgeTaraf);
  if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
    LSevk := SevkBilgisiGetir(ABaslik.ID);
    LTasiyici := SevkTasiyiciTaraf(LSevk, LGonderici);
  end;
  LAlici := Default(TEBelgeTaraf);
  LAlici.VergiNo := ABaslik.VergiNo;
  LAlici.VergiDairesi := ABaslik.VergiDairesi;
  LAlici.Unvan := ABaslik.Baslik;
  LAlici.Adres := ABaslik.Adres;
  LAlici.Ilce := ABaslik.Ilce;
  LAlici.Il := ABaslik.Il;
  LAlici.Ulke := 'Turkiye';
  // e-Arsiv: alici e-postasi (REHBERALIAS 150) -> Contact/ElectronicMail
  if ABaslik.EArsivMi then
    LAlici.EPosta := AliciEArsivEPostaGetir(ABaslik.RehberID);
  LTevkifatVar := (ABaslik.Tipi = 22) or SatirlardaTevkifatVar(ASatirlar);
  if LTevkifatVar then
    TevkifatNedeniKontrolEt(ABaslik, ASatirlar);
  TamIskontoNedeniKontrolEt(ABaslik, ASatirlar);
  LToplamMatrah := 0;
  LToplamVergi := 0;
  LToplamTevkifat := 0;
  LToplamIskonto := SatirlarIskontoToplami(ASatirlar);
  for I := 0 to High(ASatirlar) do begin
    LToplamMatrah := LToplamMatrah + ASatirlar[I].Tutar;
    LToplamVergi := LToplamVergi + SatirKDVBrut(ASatirlar[I]);
    LToplamTevkifat := LToplamTevkifat + SatirTevkifatTutar(ASatirlar[I]);
  end;
  if Abs(LToplamMatrah - ABaslik.Matrah) < 0.02 then
    LToplamMatrah := ABaslik.Matrah;
  if Abs(LToplamVergi - ABaslik.KDV) < 0.02 then
    LToplamVergi := ABaslik.KDV;

  LXML := TStringBuilder.Create;
  try
    LXML.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
    if ABaslik.Tur = EBelgeTuruEIrsaliye then
      LXML.AppendLine('<DespatchAdvice' +
        ' xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' +
        ' xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' +
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
        ' xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' +
        ' xmlns:schemaLocation="urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2 ..\xsdrt\maindoc\UBL-DespatchAdvice-2.1.xsd"' +
        ' xmlns="urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2">')
    else if ABaslik.EArsivMi then
      LXML.AppendLine('<' + LRoot +
        ' xmlns="urn:oasis:names:specification:ubl:schema:xsd:' + LRoot +
        '-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' +
        ' xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' +
        ' xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"' +
        ' xmlns:ccts="urn:un:unece:uncefact:documentation:2"' +
        ' xmlns:ubltr="urn:oasis:names:specification:ubl:schema:xsd:TurkishCustomizationExtensionComponents"' +
        ' xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"' +
        ' xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' +
        ' xmlns:ds="http://www.w3.org/2000/09/xmldsig#">')
    else
      LXML.AppendLine('<' + LRoot +
        ' xmlns="urn:oasis:names:specification:ubl:schema:xsd:' + LRoot +
        '-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' +
        ' xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">');
    if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
      LXML.AppendLine('<ext:UBLExtensions>');
      LXML.AppendLine('<ext:UBLExtension>');
      LXML.AppendLine('<ext:ExtensionContent></ext:ExtensionContent>');
      LXML.AppendLine('</ext:UBLExtension>');
      LXML.AppendLine('</ext:UBLExtensions>');
    end;
    LXML.AppendLine('<cbc:UBLVersionID>2.1</cbc:UBLVersionID>');
    LXML.AppendLine('<cbc:CustomizationID>TR1.2</cbc:CustomizationID>');
    LXML.AppendLine('<cbc:ProfileID>' + LProfil + '</cbc:ProfileID>');
    LXML.AppendLine('<cbc:ID>' + XMLEscape(ABaslik.FaturaNo) + '</cbc:ID>');
    LXML.AppendLine('<cbc:CopyIndicator>false</cbc:CopyIndicator>');
    LXML.AppendLine('<cbc:UUID>' + XMLEscape(ABaslik.UUID) + '</cbc:UUID>');
    LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
      ABaslik.Tarih) + '</cbc:IssueDate>');
    LXML.AppendLine('<cbc:IssueTime>' + FormatDateTime('hh:nn:ss',
      ABaslik.Tarih) + '</cbc:IssueTime>');
    if ABaslik.Tur = EBelgeTuruEIrsaliye then
      LXML.AppendLine('<cbc:DespatchAdviceTypeCode>SEVK</cbc:DespatchAdviceTypeCode>')
    else if LProfil = 'IHRACAT' then
      LXML.AppendLine('<cbc:InvoiceTypeCode>ISTISNA</cbc:InvoiceTypeCode>')
    else
      LXML.AppendLine('<cbc:InvoiceTypeCode>' + FaturaTipKodu(ABaslik) +
        '</cbc:InvoiceTypeCode>');
    // Dipnotlari TOPLA: sabit notlar (yer tutuculu) varsa onlar; yoksa ACIKLAMA/ACIKLAMA2
    //   + KDV istisna + tevkifat notu. YAZIM YERI belge turune gore:
    //   Header'da yazilir (standart UBL): fatura InvoiceTypeCode sonrasi, irsaliye DespatchAdviceTypeCode sonrasi.
    LNotlar := [];
    LSabitNotlar := SabitNotlariGetir(ABaslik);
    if Length(LSabitNotlar) > 0 then begin
      for I := 0 to High(LSabitNotlar) do
        LNotlar := LNotlar + [LSabitNotlar[I]];
    end else begin
      if Trim(ABaslik.Aciklama) <> '' then
        LNotlar := LNotlar + [ABaslik.Aciklama];
      if Trim(ABaslik.Aciklama2) <> '' then
        LNotlar := LNotlar + [ABaslik.Aciklama2];
    end;
    LIstisnaNotu := KDVIstisnaNotu(ABaslik);
    if LIstisnaNotu <> '' then
      LNotlar := LNotlar + [LIstisnaNotu];
    var LTevkNotu: string := TevkifatNotu(ABaslik, ASatirlar);  // dip nota tevkifat nedeni
    if LTevkNotu <> '' then
      LNotlar := LNotlar + [LTevkNotu];
    // Belge (dip) notu header'da: fatura InvoiceTypeCode sonrasi, irsaliye
    //   DespatchAdviceTypeCode sonrasi (standart UBL Note konumu; satir-notundan bagimsiz).
    for I := 0 to High(LNotlar) do
      LXML.AppendLine('<cbc:Note>' + XMLEscape(LNotlar[I]) + '</cbc:Note>');
    if ABaslik.Tur <> EBelgeTuruEIrsaliye then
      LXML.AppendLine('<cbc:DocumentCurrencyCode>' +
        XMLEscape(ABaslik.ParaBirimi) + '</cbc:DocumentCurrencyCode>');
    LXML.AppendLine('<cbc:LineCountNumeric>' + IntToStr(Length(ASatirlar)) +
      '</cbc:LineCountNumeric>');

    // Iade (Tipi=2) referansi: e-FATURA -> cac:BillingReference (DespatchAdvice'ta GECERSIZ).
    //   e-Irsaliye -> asagida cac:DespatchDocumentReference (irsaliye dalinda).
    if (ABaslik.Tipi = 2) and (ABaslik.Tur <> EBelgeTuruEIrsaliye) then
      for J := 0 to High(ABaslik.IadeReferanslari) do begin
        LXML.AppendLine('<cac:BillingReference>');
        LXML.AppendLine('<cac:InvoiceDocumentReference>');
        LXML.AppendLine('<cbc:ID>' + XMLEscape(ABaslik.IadeReferanslari[J].FaturaNo) +
          '</cbc:ID>');
        LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
          ABaslik.IadeReferanslari[J].Tarih) + '</cbc:IssueDate>');
        LXML.AppendLine('<cbc:DocumentTypeCode>IADE</cbc:DocumentTypeCode>');
        LXML.AppendLine('<cbc:DocumentType>İade Edilen Fatura</cbc:DocumentType>');
        LXML.AppendLine('</cac:InvoiceDocumentReference>');
        LXML.AppendLine('</cac:BillingReference>');
      end;

    if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
      // Iade irsaliyesi (Tipi=2): iade edilen orijinal irsaliye(ler)e cac:DespatchDocumentReference.
      if ABaslik.Tipi = 2 then
        for J := 0 to High(ABaslik.IadeReferanslari) do begin
          LXML.AppendLine('<cac:DespatchDocumentReference>');
          LXML.AppendLine('<cbc:ID>' + XMLEscape(ABaslik.IadeReferanslari[J].FaturaNo) +
            '</cbc:ID>');
          LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
            ABaslik.IadeReferanslari[J].Tarih) + '</cbc:IssueDate>');
          LXML.AppendLine('<cbc:DocumentTypeCode>IADE</cbc:DocumentTypeCode>');
          LXML.AppendLine('<cbc:DocumentType>İade Edilen İrsaliye</cbc:DocumentType>');
          LXML.AppendLine('</cac:DespatchDocumentReference>');
        end;
      if BelgeXSLTGetir(ABaslik.RehberID, ABaslik.Tur, ABaslik.EArsivMi, False, LXSLT) then begin
        LXML.AppendLine('<cac:AdditionalDocumentReference>');
        LXML.AppendLine('<cbc:ID>' + XMLEscape(ABaslik.UUID) + '</cbc:ID>');
        LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd', ABaslik.Tarih) +
          '</cbc:IssueDate>');
        LXML.AppendLine('<cac:Attachment>');
        LXML.AppendLine('<cbc:EmbeddedDocumentBinaryObject characterSetCode="UTF-8" encodingCode="Base64" filename="' +
          XMLEscape(ABaslik.FaturaNo) + '.xslt" mimeCode="application/xml">' +
          Base64TekSatir(TEncoding.UTF8.GetBytes(LXSLT)) +
          '</cbc:EmbeddedDocumentBinaryObject>');
        LXML.AppendLine('</cac:Attachment>');
        LXML.AppendLine('</cac:AdditionalDocumentReference>');
      end;
      LXML.AppendLine('<cac:Signature>');
      LXML.AppendLine('<cbc:ID schemeID="' + KimlikSemasi(LGonderici.VergiNo) + '">' +
        XMLEscape(LGonderici.VergiNo) + '</cbc:ID>');
      LXML.AppendLine('<cac:SignatoryParty>');
      LXML.AppendLine('<cac:PartyIdentification><cbc:ID schemeID="' +
        KimlikSemasi(LGonderici.VergiNo) + '">' + XMLEscape(LGonderici.VergiNo) +
        '</cbc:ID></cac:PartyIdentification>');
      LXML.AppendLine('<cac:PartyName><cbc:Name>' + XMLEscape(LGonderici.Unvan) +
        '</cbc:Name></cac:PartyName>');
      LXML.AppendLine('</cac:SignatoryParty>');
      LXML.AppendLine('<cac:DigitalSignatureAttachment><cac:ExternalReference><cbc:URI>#Signature_' +
        XMLEscape(ABaslik.UUID) + '</cbc:URI></cac:ExternalReference></cac:DigitalSignatureAttachment>');
      LXML.AppendLine('</cac:Signature>');
    end else begin
      if Trim(ABaslik.IrsaliyeNo) <> '' then begin
        LXML.AppendLine('<cac:DespatchDocumentReference>');
        LXML.AppendLine('<cbc:ID>' + XMLEscape(ABaslik.IrsaliyeNo) + '</cbc:ID>');
        if ABaslik.IrsaliyeTarih > 0 then
          LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
            ABaslik.IrsaliyeTarih) + '</cbc:IssueDate>')
        else
          LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
            ABaslik.Tarih) + '</cbc:IssueDate>');
        LXML.AppendLine('</cac:DespatchDocumentReference>');
      end;
      if ABaslik.EArsivMi then begin
        LXML.AppendLine('<cac:AdditionalDocumentReference>');
        LXML.AppendLine('<cbc:ID>1</cbc:ID>');
        LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
          ABaslik.Tarih) + '</cbc:IssueDate>');
        LXML.AppendLine('<cbc:DocumentTypeCode>SendingType</cbc:DocumentTypeCode>');
        LXML.AppendLine('<cbc:DocumentType>' +
          IfThen(Trim(ABaslik.AliciAlias) <> '', 'ELEKTRONIK', 'KAGIT') +
          '</cbc:DocumentType>');
        LXML.AppendLine('</cac:AdditionalDocumentReference>');
      end;
      if ABaslik.EArsivMi and
        (OrnekEArsivXSLTGetir(LXSLT) or
         BelgeXSLTGetir(ABaslik.RehberID, ABaslik.Tur, ABaslik.EArsivMi, False, LXSLT)) then begin
        var LXSLTDosyaAdi := Trim(ABaslik.FaturaNo);
        if LXSLTDosyaAdi = '' then
          LXSLTDosyaAdi := ABaslik.UUID;
        LXSLTDosyaAdi := LXSLTDosyaAdi + '.xslt';
        LXML.AppendLine('<cac:AdditionalDocumentReference>');
        LXML.AppendLine('<cbc:ID>' + XMLEscape(ABaslik.UUID) + '</cbc:ID>');
        LXML.AppendLine('<cbc:IssueDate>' + FormatDateTime('yyyy-mm-dd',
          ABaslik.Tarih) + '</cbc:IssueDate>');
        LXML.AppendLine('<cac:Attachment>');
        LXML.AppendLine('<cbc:EmbeddedDocumentBinaryObject characterSetCode="UTF-8" encodingCode="Base64" filename="' +
          XMLEscape(LXSLTDosyaAdi) + '" mimeCode="application/xml">' +
          Base64TekSatir(TEncoding.UTF8.GetBytes(LXSLT)) +
          '</cbc:EmbeddedDocumentBinaryObject>');
        LXML.AppendLine('</cac:Attachment>');
        LXML.AppendLine('</cac:AdditionalDocumentReference>');
      end;
    end;

    if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
      LXML.Append(PartyXML('DespatchSupplierParty', LGonderici));
      LXML.Append(PartyXML('DeliveryCustomerParty', LAlici));
      LXML.AppendLine('<cac:Shipment>');
      LXML.AppendLine('<cbc:ID />');
      LXML.AppendLine('<cac:GoodsItem><cbc:ValueAmount currencyID="' +
        XMLEscape(ABaslik.ParaBirimi) + '">' + Ondalik(ABaslik.Matrah, '0.00##') +
        '</cbc:ValueAmount></cac:GoodsItem>');
      LXML.AppendLine('<cac:ShipmentStage>');
      LXML.AppendLine('<cac:TransportMeans>');
      LXML.AppendLine('<cac:RoadTransport>');
      LXML.AppendLine('<cbc:LicensePlateID schemeID="PLAKA">' + XMLEscape(LSevk.Plaka) +
        '</cbc:LicensePlateID>');
      LXML.AppendLine('</cac:RoadTransport>');
      LXML.AppendLine('</cac:TransportMeans>');
      if (Trim(LSevk.SoforAdi) <> '') or (Trim(LSevk.SoforSoyadi) <> '') or
         (Trim(LSevk.SoforTckn) <> '') then begin
        LXML.AppendLine('<cac:DriverPerson>');
        var LDFirst, LDFamily: string;
        SoforAdSoyadAyir(LSevk.SoforAdi, LSevk.SoforSoyadi, LDFirst, LDFamily);
        // GIB: FirstName + FamilyName ZORUNLU (ikisi de daima yazilir).
        LXML.AppendLine('<cbc:FirstName>' + XMLEscape(LDFirst) + '</cbc:FirstName>');
        LXML.AppendLine('<cbc:FamilyName>' + XMLEscape(LDFamily) + '</cbc:FamilyName>');
        LXML.AppendLine('<cbc:Title>Şoför</cbc:Title>');
        if Trim(LSevk.SoforTckn) <> '' then
          LXML.AppendLine('<cbc:NationalityID>' + XMLEscape(LSevk.SoforTckn) +
            '</cbc:NationalityID>');
        LXML.AppendLine('</cac:DriverPerson>');
      end;
      LXML.AppendLine('</cac:ShipmentStage>');
      LXML.AppendLine('<cac:Delivery>');
      LXML.AppendLine('<cac:DeliveryAddress>');
      if Trim(ABaslik.Adres) <> '' then
        LXML.AppendLine('<cbc:StreetName>' + XMLEscape(ABaslik.Adres) +
          '</cbc:StreetName>');
      if Trim(ABaslik.Ilce) <> '' then
        LXML.AppendLine('<cbc:CitySubdivisionName>' + XMLEscape(ABaslik.Ilce) +
          '</cbc:CitySubdivisionName>');
      if Trim(ABaslik.Il) <> '' then
        LXML.AppendLine('<cbc:CityName>' + XMLEscape(ABaslik.Il) +
          '</cbc:CityName>');
      LXML.AppendLine('<cbc:PostalZone>34000</cbc:PostalZone>');
      LXML.AppendLine('<cac:Country><cbc:Name>Turkiye</cbc:Name></cac:Country>');
      LXML.AppendLine('</cac:DeliveryAddress>');
      LXML.AppendLine('<cac:Despatch>');
      LXML.AppendLine('<cbc:ActualDespatchDate>' + FormatDateTime('yyyy-mm-dd',
        ABaslik.Tarih) + '</cbc:ActualDespatchDate>');
      LXML.AppendLine('<cbc:ActualDespatchTime>' + FormatDateTime('hh:nn:ss',
        ABaslik.Tarih) + '</cbc:ActualDespatchTime>');
      LXML.AppendLine('</cac:Despatch>');
      LXML.AppendLine('</cac:Delivery>');
      LXML.AppendLine('</cac:Shipment>');
    end else begin
      LXML.Append(PartyXML('AccountingSupplierParty', LGonderici));
      if LProfil = 'IHRACAT' then begin
        LXML.Append(GumrukPartyXML('AccountingCustomerParty'));
        LXML.Append(PartyXML('BuyerCustomerParty', LAlici));
      end else
        LXML.Append(PartyXML('AccountingCustomerParty', LAlici));
      if LToplamIskonto > 0.0001 then begin
        LXML.AppendLine('<cac:AllowanceCharge>');
        LXML.AppendLine('<cbc:ChargeIndicator>false</cbc:ChargeIndicator>');
        LXML.AppendLine('<cbc:AllowanceChargeReason>Iskonto</cbc:AllowanceChargeReason>');
        LXML.AppendLine('<cbc:Amount currencyID="' + ABaslik.ParaBirimi +
          '">' + Ondalik(LToplamIskonto, '0.00##') + '</cbc:Amount>');
        LXML.AppendLine('</cac:AllowanceCharge>');
      end;
      // Fatura tek KDV oranli mi? Oyleyse TaxSubtotal dip-toplam (ABaslik.Matrah/KDV) ile emit
      //   edilir (Σ-satir=sum-of-rounded yerine round-of-sum). JSON gonderim de boyle yapiyor ->
      //   UBL export = JSON = izibiz PDF (header ile tutarli). Cok-oranli: per-satir grup korunur.
      var LTekOran: Boolean := True;
      for I := 1 to High(ASatirlar) do
        if (Abs(ASatirlar[I].KDVOrani - ASatirlar[0].KDVOrani) > 0.001) or
           ((SatirKDVBrut(ASatirlar[I]) < 0.001) <> (SatirKDVBrut(ASatirlar[0]) < 0.001)) then begin
          LTekOran := False; Break;
        end;
      LXML.AppendLine('<cac:TaxTotal>');
      LXML.AppendLine('<cbc:TaxAmount currencyID="' + ABaslik.ParaBirimi +
        '">' + Ondalik(LToplamVergi, '0.00##') + '</cbc:TaxAmount>');
      for I := 0 to High(ASatirlar) do begin
        LOranIslendi := False;
        for J := 0 to I - 1 do
          if (Abs(ASatirlar[J].KDVOrani - ASatirlar[I].KDVOrani) < 0.001) and
             ((SatirKDVBrut(ASatirlar[J]) < 0.001) = (SatirKDVBrut(ASatirlar[I]) < 0.001)) then begin
            LOranIslendi := True;
            Break;
          end;
        if LOranIslendi then
          Continue;
        LGrupMatrah := 0;
        LGrupVergi := 0;
        for J := I to High(ASatirlar) do
          if (Abs(ASatirlar[J].KDVOrani - ASatirlar[I].KDVOrani) < 0.001) and
             ((SatirKDVBrut(ASatirlar[J]) < 0.001) = (SatirKDVBrut(ASatirlar[I]) < 0.001)) then begin
            LGrupMatrah := LGrupMatrah + ASatirlar[J].Tutar;
            LGrupVergi := LGrupVergi + SatirKDVBrut(ASatirlar[J]);
          end;
        // Tek oranli: dip-toplam (round-of-sum) ile hizala -> Σ-satir yerine ABaslik.Matrah/KDV
        if LTekOran then begin
          LGrupMatrah := LToplamMatrah;
          LGrupVergi := LToplamVergi;
        end;
        // KDV tutari 0 olan 0015 grubunda GIB TaxExemptionReasonCode/Reason ZORUNLU (cac:TaxCategory
        //   icinde, TaxScheme'den ONCE). Istisna/ihracat -> plan kodu; bedelsiz (%100 iskonto, net
        //   matrah 0 -> KDV 0) -> muafiyet kodu 351. Tetik: KDV tutari 0 (oran degil - bedelsizde oran 18).
        var LIstisnaXml: string := '';
        if LGrupVergi < 0.001 then begin
          var LMufKod, LMufNeden: string;
          KDVMuafiyetKodNeden(ABaslik, LMufKod, LMufNeden);
          LIstisnaXml :=
            '<cbc:TaxExemptionReasonCode>' + XMLEscape(LMufKod) + '</cbc:TaxExemptionReasonCode>' +
            '<cbc:TaxExemptionReason>' + XMLEscape(LMufNeden) + '</cbc:TaxExemptionReason>';
        end;
        LXML.AppendLine('<cac:TaxSubtotal><cbc:TaxableAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LGrupMatrah, '0.00##') +
          '</cbc:TaxableAmount><cbc:TaxAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LGrupVergi, '0.00##') +
          '</cbc:TaxAmount><cbc:Percent>' +
          Ondalik(ASatirlar[I].KDVOrani, '0.##') +
          '</cbc:Percent><cac:TaxCategory>' + LIstisnaXml + '<cac:TaxScheme><cbc:Name>KDV</cbc:Name>' +
          '<cbc:TaxTypeCode>0015</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory>' +
          '</cac:TaxSubtotal>');
      end;
      LXML.AppendLine('</cac:TaxTotal>');
      if LToplamTevkifat > 0 then begin
        LXML.AppendLine('<cac:WithholdingTaxTotal><cbc:TaxAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LToplamTevkifat, '0.00##') +
          '</cbc:TaxAmount>');
        for I := 0 to High(ASatirlar) do begin
          if SatirTevkifatTutar(ASatirlar[I]) <= 0 then
            Continue;
          LOranIslendi := False;
          for J := 0 to I - 1 do
            if Abs(ASatirlar[J].TevkifatOrani - ASatirlar[I].TevkifatOrani) < 0.001 then begin
              LOranIslendi := True;
              Break;
            end;
          if LOranIslendi then
            Continue;
          LGrupMatrah := 0;
          LGrupTevkifat := 0;
          for J := I to High(ASatirlar) do
            if Abs(ASatirlar[J].TevkifatOrani - ASatirlar[I].TevkifatOrani) < 0.001 then begin
              LGrupMatrah := LGrupMatrah + SatirKDVBrut(ASatirlar[J]);  // tevkifat matrahi = KDV tutari (net degil; izibiz sematron)
              LGrupTevkifat := LGrupTevkifat + SatirTevkifatTutar(ASatirlar[J]);
            end;
          LXML.AppendLine('<cac:TaxSubtotal><cbc:TaxableAmount currencyID="' +
            ABaslik.ParaBirimi + '">' + Ondalik(LGrupMatrah, '0.00##') +
            '</cbc:TaxableAmount><cbc:TaxAmount currencyID="' +
            ABaslik.ParaBirimi + '">' + Ondalik(LGrupTevkifat, '0.00##') +
            '</cbc:TaxAmount><cbc:Percent>' +
            Ondalik(ASatirlar[I].TevkifatOrani, '0.##') +
            '</cbc:Percent><cac:TaxCategory><cac:TaxScheme><cbc:Name>' +
            XMLEscape(TevkifatNedeni(ABaslik)) +
            '</cbc:Name><cbc:TaxTypeCode>' +
            XMLEscape(TevkifatKodu(ABaslik)) +
            '</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory>' +
            '</cac:TaxSubtotal>');
        end;
        LXML.AppendLine('</cac:WithholdingTaxTotal>');
      end;
      LXML.AppendLine('<cac:LegalMonetaryTotal>');
      // Mal Hizmet Toplam Tutari = BRUT (iskonto oncesi = Matrah + toplam iskonto). GIB/izibiz boyle
      //   bekler; TaxExclusive = NET (Matrah). brut - AllowanceTotal = TaxExclusive.
      LXML.AppendLine('<cbc:LineExtensionAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(LToplamMatrah + LToplamIskonto, '0.00##') +
        '</cbc:LineExtensionAmount>');
      LXML.AppendLine('<cbc:TaxExclusiveAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(LToplamMatrah, '0.00##') +
        '</cbc:TaxExclusiveAmount>');
      LXML.AppendLine('<cbc:TaxInclusiveAmount currencyID="' +
        ABaslik.ParaBirimi + '">' +
        Ondalik(LToplamMatrah + LToplamVergi, '0.00##') +
        '</cbc:TaxInclusiveAmount>');
      if LToplamIskonto > 0.0001 then
        LXML.AppendLine('<cbc:AllowanceTotalAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LToplamIskonto, '0.00##') +
          '</cbc:AllowanceTotalAmount>');
      var LPayable: Currency := LToplamMatrah + LToplamVergi - LToplamTevkifat;
      if Abs(LPayable - ABaslik.Toplam) < 0.02 then
        LPayable := ABaslik.Toplam;
      LXML.AppendLine('<cbc:PayableAmount currencyID="' +
        ABaslik.ParaBirimi + '">' + Ondalik(LPayable, '0.00##') +
        '</cbc:PayableAmount>');
      LXML.AppendLine('</cac:LegalMonetaryTotal>');
    end;

    for I := 0 to High(ASatirlar) do begin
      LXML.AppendLine('<cac:' + LSatirTuru + '>');
      LXML.AppendLine('<cbc:ID>' + IntToStr(ASatirlar[I].SatirNo) +
        '</cbc:ID>');
      // Satir notu (Lot/SKT/Miktar) cbc:ID'den HEMEN SONRA: fatura -> InvoiceLine/Note,
      //   irsaliye -> DespatchLine/Note (GIB e-Irsaliye kilavuz diyagrami 2.3.22: ID sonrasi).
      //   Izibiz de irsaliyede notu DespatchLine seviyesinde tutar (ic InvoiceLine'da DEGIL).
      if Trim(ASatirlar[I].Notu) <> '' then
        LXML.AppendLine('<cbc:Note>' + XMLEscape(ASatirlar[I].Notu) + '</cbc:Note>');
      LXML.AppendLine('<cbc:' + LMiktarTuru + ' unitCode="' +
        XMLEscape(IfThen((ABaslik.Tur = EBelgeTuruEIrsaliye) and
          SameText(ASatirlar[I].BirimKodu, 'C62'), 'NIU', ASatirlar[I].BirimKodu)) + '">' +
        Ondalik(ASatirlar[I].Miktar, IfThen(ABaslik.Tur = EBelgeTuruEIrsaliye, '0.00##', '0.######')) + '</cbc:' +
        LMiktarTuru + '>');
      if ABaslik.Tur = EBelgeTuruEIrsaliye then begin
        LXML.AppendLine('<cac:OrderLineReference>');
        LXML.AppendLine('<cbc:LineID>' + IntToStr(ASatirlar[I].SatirNo) + '</cbc:LineID>');
        LXML.AppendLine('</cac:OrderLineReference>');
        LXML.AppendLine('<cac:Item>');
        LXML.AppendLine('<cbc:Name>' + XMLEscape(ASatirlar[I].UrunAdi) + '</cbc:Name>');
        if Trim(ASatirlar[I].MarkaAdi) <> '' then
          LXML.AppendLine('<cbc:BrandName>' + XMLEscape(ASatirlar[I].MarkaAdi) +
            '</cbc:BrandName>');
        if Trim(ASatirlar[I].ModelKodu) <> '' then
          LXML.AppendLine('<cbc:ModelName>' + XMLEscape(ASatirlar[I].ModelKodu) +
            '</cbc:ModelName>');
        if Trim(SatirAliciKimlik(ASatirlar[I])) <> '' then
          LXML.AppendLine('<cac:BuyersItemIdentification><cbc:ID>' +
            XMLEscape(SatirAliciKimlik(ASatirlar[I])) +
            '</cbc:ID></cac:BuyersItemIdentification>');
        LXML.AppendLine('<cac:SellersItemIdentification><cbc:ID>' +
          XMLEscape(SatirSaticiKimlik(ASatirlar[I])) +
          '</cbc:ID></cac:SellersItemIdentification>');
        if Trim(ASatirlar[I].SutKodu) <> '' then
          LXML.AppendLine('<cac:ManufacturersItemIdentification><cbc:ID>' +
            XMLEscape(ASatirlar[I].SutKodu) +
            '</cbc:ID></cac:ManufacturersItemIdentification>');
        // GTIN (URUNNO -> BARKOD) fatura/arsiv ile ayni sekilde irsaliyede de
        if Trim(ASatirlar[I].Barkod) <> '' then
          LXML.AppendLine('<cac:StandardItemIdentification><cbc:ID schemeID="GTIN">' +
            XMLEscape(ASatirlar[I].Barkod) +
            '</cbc:ID></cac:StandardItemIdentification>');
        // Ilac/tibbi cihaz kimligi: YALNIZ ilac/tibbi cihaz senaryosunda (Senaryo=8).
        // e-Irsaliye ilac/tibbi cihaz DEGILSE AdditionalItemIdentification yazilmaz
        // (SP ilac-disi urunlerde de deger dondurdugunden Senaryo ile gate edilir).
        if (ABaslik.Senaryo = 8) and (Trim(ASatirlar[I].TibbiCihazKimlik) <> '') then
          TibbiCihazKimlikXMLYaz(LXML, ASatirlar[I].TibbiCihazKimlik);
        if Trim(ASatirlar[I].LotNo) <> '' then
          LXML.AppendLine('<cac:AdditionalItemProperty><cbc:Name>LOTNO</cbc:Name><cbc:Value>' +
            XMLEscape(ASatirlar[I].LotNo) +
            '</cbc:Value></cac:AdditionalItemProperty>');
        if Trim(ASatirlar[I].SeriNo) <> '' then
          LXML.AppendLine('<cac:ItemInstance><cbc:SerialID>' +
            XMLEscape(ASatirlar[I].SeriNo) +
            '</cbc:SerialID></cac:ItemInstance>');
        LXML.AppendLine('</cac:Item>');
        LXML.AppendLine('<cac:Shipment>');
        LXML.AppendLine('<cbc:ID />');
        LXML.AppendLine('<cac:GoodsItem>');
        LXML.AppendLine('<cac:InvoiceLine>');
        LXML.AppendLine('<cbc:ID>' + IntToStr(ASatirlar[I].SatirNo) + '</cbc:ID>');
        // NOT: satir notu artik DIS DespatchLine/cbc:ID sonrasi yaziliyor (kilavuz+izibiz);
        //   ic InvoiceLine'da mukerrer yazilmaz.
        LXML.AppendLine('<cbc:InvoicedQuantity>' +
          Ondalik(ASatirlar[I].Miktar, '0.00##') + '</cbc:InvoicedQuantity>');
        LXML.AppendLine('<cbc:LineExtensionAmount currencyID="' +
          XMLEscape(ABaslik.ParaBirimi) + '">0.00</cbc:LineExtensionAmount>');
        LXML.AppendLine('<cac:Item>');
        LXML.AppendLine('<cbc:Name>' + XMLEscape(ASatirlar[I].UrunAdi) + '</cbc:Name>');
        // BrandName/ModelName YALNIZ dis DespatchLine/Item'da yazilir (GIB/ITS oradan
        // okur); ic GoodsItem/InvoiceLine/Item legacy -> mukerrer yazilmaz.
        if Trim(ASatirlar[I].SeriNo) <> '' then
          LXML.AppendLine('<cac:ItemInstance><cbc:SerialID>' +
            XMLEscape(ASatirlar[I].SeriNo) +
            '</cbc:SerialID></cac:ItemInstance>');
        LXML.AppendLine('</cac:Item>');
        LXML.AppendLine('<cac:Price><cbc:PriceAmount currencyID="' +
          XMLEscape(ABaslik.ParaBirimi) + '">0.0000</cbc:PriceAmount></cac:Price>');
        LXML.AppendLine('</cac:InvoiceLine>');
        LXML.AppendLine('</cac:GoodsItem>');
        LXML.AppendLine('</cac:Shipment>');
        LXML.AppendLine('</cac:' + LSatirTuru + '>');
        Continue;
      end;
      if ABaslik.Tur <> EBelgeTuruEIrsaliye then begin
        LXML.AppendLine('<cbc:LineExtensionAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(ASatirlar[I].Tutar,
          '0.00##') + '</cbc:LineExtensionAmount>');
        if (LProfil = 'IHRACAT') and ABaslik.IhracatVar then
          LXML.Append(IhracatSatirDeliveryXML(ABaslik, ASatirlar[I]));
        LSatirVergi := SatirKDVBrut(ASatirlar[I]);
        LSatirTevkifat := SatirTevkifatTutar(ASatirlar[I]);
        LSatirIskonto := SatirIskontoTutar(ASatirlar[I]);
        LSatirBrut := SatirBrutTutar(ASatirlar[I]);
        LSatirIstisnaXml := '';
        if LSatirVergi < 0.001 then begin
          var LMufKod, LMufNeden: string;
          KDVMuafiyetKodNeden(ABaslik, LMufKod, LMufNeden);
          LSatirIstisnaXml :=
            '<cbc:TaxExemptionReasonCode>' + XMLEscape(LMufKod) +
            '</cbc:TaxExemptionReasonCode><cbc:TaxExemptionReason>' +
            XMLEscape(LMufNeden) + '</cbc:TaxExemptionReason>';
        end;
        if LSatirIskonto > 0.0001 then begin
          LXML.AppendLine('<cac:AllowanceCharge>');
          LXML.AppendLine('<cbc:ChargeIndicator>false</cbc:ChargeIndicator>');
          LXML.AppendLine('<cbc:AllowanceChargeReason>Iskonto</cbc:AllowanceChargeReason>');
          LXML.AppendLine('<cbc:MultiplierFactorNumeric>' +
            Ondalik(SatirIskontoOrani(ASatirlar[I]) / 100, '0.######') +
            '</cbc:MultiplierFactorNumeric>');
          LXML.AppendLine('<cbc:Amount currencyID="' + ABaslik.ParaBirimi +
            '">' + Ondalik(LSatirIskonto, '0.00##') + '</cbc:Amount>');
          if LSatirBrut > 0.0001 then
            LXML.AppendLine('<cbc:BaseAmount currencyID="' +
              ABaslik.ParaBirimi + '">' + Ondalik(LSatirBrut, '0.00##') +
              '</cbc:BaseAmount>');
          LXML.AppendLine('</cac:AllowanceCharge>');
        end;
        LXML.AppendLine('<cac:TaxTotal><cbc:TaxAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LSatirVergi, '0.00##') +
          '</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(ASatirlar[I].Tutar,
          '0.00##') + '</cbc:TaxableAmount><cbc:TaxAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(LSatirVergi, '0.00##') +
          '</cbc:TaxAmount><cbc:Percent>' +
          Ondalik(ASatirlar[I].KDVOrani, '0.##') +
          '</cbc:Percent><cac:TaxCategory>' +
          LSatirIstisnaXml + '<cac:TaxScheme><cbc:Name>KDV</cbc:Name>' +
          '<cbc:TaxTypeCode>0015</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory>' +
          '</cac:TaxSubtotal></cac:TaxTotal>');
        if LSatirTevkifat > 0 then
          LXML.AppendLine('<cac:WithholdingTaxTotal><cbc:TaxAmount currencyID="' +
            ABaslik.ParaBirimi + '">' + Ondalik(LSatirTevkifat, '0.00##') +
            '</cbc:TaxAmount><cac:TaxSubtotal><cbc:TaxableAmount currencyID="' +
            ABaslik.ParaBirimi + '">' + Ondalik(SatirKDVBrut(ASatirlar[I]),
            '0.00##') + '</cbc:TaxableAmount><cbc:TaxAmount currencyID="' +
            ABaslik.ParaBirimi + '">' + Ondalik(LSatirTevkifat, '0.00##') +
            '</cbc:TaxAmount><cbc:Percent>' +
            Ondalik(ASatirlar[I].TevkifatOrani, '0.##') +
            '</cbc:Percent><cac:TaxCategory><cac:TaxScheme><cbc:Name>' +
            XMLEscape(TevkifatNedeni(ABaslik)) +
            '</cbc:Name><cbc:TaxTypeCode>' +
            XMLEscape(TevkifatKodu(ABaslik)) +
            '</cbc:TaxTypeCode></cac:TaxScheme></cac:TaxCategory>' +
            '</cac:TaxSubtotal></cac:WithholdingTaxTotal>');
      end;
      LXML.AppendLine('<cac:Item>');
      LXML.AppendLine('<cbc:Name>' + XMLEscape(ASatirlar[I].UrunAdi) +
        '</cbc:Name>');
      if Trim(ASatirlar[I].MarkaAdi) <> '' then
        LXML.AppendLine('<cbc:BrandName>' + XMLEscape(ASatirlar[I].MarkaAdi) +
          '</cbc:BrandName>');
      if Trim(ASatirlar[I].ModelKodu) <> '' then
        LXML.AppendLine('<cbc:ModelName>' + XMLEscape(ASatirlar[I].ModelKodu) +
          '</cbc:ModelName>');
      if Trim(SatirAliciKimlik(ASatirlar[I])) <> '' then
        LXML.AppendLine('<cac:BuyersItemIdentification><cbc:ID>' +
          XMLEscape(SatirAliciKimlik(ASatirlar[I])) +
          '</cbc:ID></cac:BuyersItemIdentification>');
      LXML.AppendLine('<cac:SellersItemIdentification><cbc:ID>' +
        XMLEscape(SatirSaticiKimlik(ASatirlar[I])) +
        '</cbc:ID></cac:SellersItemIdentification>');
      if Trim(ASatirlar[I].SutKodu) <> '' then
        LXML.AppendLine('<cac:ManufacturersItemIdentification><cbc:ID>' +
          XMLEscape(ASatirlar[I].SutKodu) +
          '</cbc:ID></cac:ManufacturersItemIdentification>');
      if Trim(ASatirlar[I].Barkod) <> '' then
        LXML.AppendLine('<cac:StandardItemIdentification><cbc:ID schemeID="GTIN">' +
          XMLEscape(ASatirlar[I].Barkod) +
          '</cbc:ID></cac:StandardItemIdentification>');
      if ABaslik.Tur <> EBelgeTuruEIrsaliye then begin
        if Trim(ASatirlar[I].LotNo) <> '' then
          LXML.AppendLine('<cac:AdditionalItemProperty><cbc:Name>LOTNO</cbc:Name><cbc:Value>' +
            XMLEscape(ASatirlar[I].LotNo) +
            '</cbc:Value></cac:AdditionalItemProperty>');
        if ABaslik.Senaryo = 8 then
          TibbiCihazKimlikXMLYaz(LXML, ASatirlar[I].TibbiCihazKimlik)
        else begin
          if Trim(ASatirlar[I].SeriNo) <> '' then
            LXML.AppendLine('<cac:AdditionalItemProperty><cbc:Name>SERINO</cbc:Name><cbc:Value>' +
              XMLEscape(ASatirlar[I].SeriNo) +
              '</cbc:Value></cac:AdditionalItemProperty>');
        end;
      end;
      LXML.AppendLine('</cac:Item>');
      if ABaslik.Tur <> EBelgeTuruEIrsaliye then
        LXML.AppendLine('<cac:Price><cbc:PriceAmount currencyID="' +
          ABaslik.ParaBirimi + '">' + Ondalik(ASatirlar[I].BirimFiyat,
          '0.00######') + '</cbc:PriceAmount></cac:Price>');
      LXML.AppendLine('</cac:' + LSatirTuru + '>');
    end;
    LXML.AppendLine('</' + LRoot + '>');
    Result := LXML.ToString;
  finally
    LXML.Free;
  end;
end;

function APIJSONUret(const ABaslik: TEBelgeBaslik; const AUBLXML: string): string;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  try
    LJSON.AddPair('provider', 'IZIBIZ');
    LJSON.AddPair('direction', 'OUTBOUND');
    if ABaslik.Tur = EBelgeTuruEIrsaliye then
      LJSON.AddPair('documentType', 'DESPATCHADVICE')
    else
      LJSON.AddPair('documentType', 'INVOICE');
    LJSON.AddPair('sourceId', IntToStr(ABaslik.ID));
    LJSON.AddPair('documentNo', ABaslik.FaturaNo);
    LJSON.AddPair('uuid', ABaslik.UUID);
    LJSON.AddPair('senderAlias', ABaslik.GondericiAlias);
    LJSON.AddPair('receiverAlias', ABaslik.AliciAlias);
    LJSON.AddPair('contentType', 'application/xml');
    LJSON.AddPair('contentEncoding', 'base64');
    LJSON.AddPair('content', Base64TekSatir(TEncoding.UTF8.GetBytes(AUBLXML)));
    Result := LJSON.ToJSON;
  finally
    LJSON.Free;
  end;
end;

function IzibizRawUBLJSONUret(const ABaslik: TEBelgeBaslik; const AUBLXML: string): string;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  try
    LJSON.AddPair('documentAction', 'SEND');
    LJSON.AddPair('assignNumber', IfThen(Trim(ABaslik.FaturaNo) = '', 'true', 'false'));
    if Trim(ABaslik.FaturaNo) <> '' then
      LJSON.AddPair('seriePrefix', Copy(ABaslik.FaturaNo, 1, 3));
    LJSON.AddPair('profile', SenaryoProfilKodu(ABaslik));
    if ABaslik.Tur = EBelgeTuruEIrsaliye then
      LJSON.AddPair('documentType', 'DESPATCHADVICE')
    else
      LJSON.AddPair('documentType', 'INVOICE');
    LJSON.AddPair('documentTypeCode', FaturaTipKodu(ABaslik));
    if Trim(ABaslik.FaturaNo) <> '' then
      LJSON.AddPair('documentNo', ABaslik.FaturaNo);
    if Trim(ABaslik.UUID) <> '' then
      LJSON.AddPair('uuid', ABaslik.UUID);
    LJSON.AddPair('contentType', 'application/xml');
    LJSON.AddPair('contentEncoding', 'base64');
    LJSON.AddPair('content', Base64TekSatir(TEncoding.UTF8.GetBytes(AUBLXML)));
    Result := LJSON.ToJSON;
  finally
    LJSON.Free;
  end;
end;

function JSONAlanDegeri(AObject: TJSONObject; const AAlan: string): string;
var
  LValue: TJSONValue;
begin
  Result := '';
  if AObject = nil then
    Exit;
  LValue := AObject.GetValue(AAlan);
  if LValue <> nil then
    Result := LValue.Value;
end;

procedure EFaturaXSLTReferanslariniTemizle(var ABody: string);
var
  LJSON, LContentValue, LRefsValue, LRefValue, LRemoved: TJSONValue;
  LRemovedPair: TJSONPair;
  LRoot, LRef: TJSONObject;
  LRefs: TJSONArray;
  I: Integer;
begin
  LJSON := TJSONObject.ParseJSONValue(ABody);
  try
    if not (LJSON is TJSONObject) then
      Exit;

    LRoot := TJSONObject(LJSON);
    LRemovedPair := LRoot.RemovePair('xsltName');
    LRemovedPair.Free;

    LContentValue := LRoot.GetValue('content');
    if LContentValue is TJSONObject then begin
      LRefsValue := TJSONObject(LContentValue).GetValue('additionalReferences');
      if LRefsValue is TJSONArray then begin
        LRefs := TJSONArray(LRefsValue);
        for I := LRefs.Count - 1 downto 0 do begin
          LRefValue := LRefs.Items[I];
          if not (LRefValue is TJSONObject) then
            Continue;
          LRef := TJSONObject(LRefValue);
          if SameText(Trim(JSONAlanDegeri(LRef, 'documentType')), 'XSLT') then begin
            LRemoved := LRefs.Remove(I);
            LRemoved.Free;
          end;
        end;
      end;
    end;

    ABody := LRoot.ToJSON;
  finally
    LJSON.Free;
  end;
end;

function HTMLUret(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar): string;
var
  LHTML: TStringBuilder;
  I: Integer;
  LBelgeTuru: string;
begin
  if ABaslik.Tur = EBelgeTuruEIrsaliye then
    LBelgeTuru := 'e-Irsaliye'
  else
    LBelgeTuru := 'e-Fatura';

  LHTML := TStringBuilder.Create;
  try
    LHTML.AppendLine('<!doctype html><html><head><meta charset="utf-8">');
    LHTML.AppendLine('<title>' + LBelgeTuru + ' ' +
      HTMLEscape(ABaslik.FaturaNo) + '</title>');
    LHTML.AppendLine('<style>body{font-family:Segoe UI,Arial;margin:32px;color:#222}' +
      'h1{margin-bottom:4px}.muted{color:#666}.box{border:1px solid #ddd;padding:16px;margin:18px 0}' +
      'table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:8px}' +
      'th{background:#f3f5f7;text-align:left}.num{text-align:right}</style></head><body>');
    LHTML.AppendLine('<h1>' + LBelgeTuru + '</h1><div class="muted">EBELGE ID: ' +
      IntToStr(ABaslik.EBelgeID) + ' | UUID: ' + HTMLEscape(ABaslik.UUID) +
      '</div>');
    LHTML.AppendLine('<div class="box"><b>Belge No:</b> ' +
      HTMLEscape(ABaslik.FaturaNo) + '<br><b>Tarih:</b> ' +
      FormatDateTime('dd.mm.yyyy hh:nn', ABaslik.Tarih) +
      '<br><b>Alici:</b> ' + HTMLEscape(ABaslik.Baslik) +
      '<br><b>VKN/TCKN:</b> ' + HTMLEscape(ABaslik.VergiNo) +
      '<br><b>Alias:</b> ' + HTMLEscape(ABaslik.AliciAlias) +
      '<br><b>Adres:</b> ' + HTMLEscape(ABaslik.Adres + ' ' +
      ABaslik.Ilce + ' ' + ABaslik.Il) + '</div>');
    LHTML.AppendLine('<table><thead><tr><th>No</th><th>Kod</th><th>Barkod</th><th>SUT</th><th>Lot</th><th>Seri</th><th>Urun/Hizmet</th>' +
      '<th class="num">Miktar</th><th class="num">Birim Fiyat</th>' +
      '<th class="num">KDV %</th><th class="num">Tutar</th></tr></thead><tbody>');
    for I := 0 to High(ASatirlar) do
      LHTML.AppendLine('<tr><td>' + IntToStr(ASatirlar[I].SatirNo) +
        '</td><td>' + HTMLEscape(ASatirlar[I].UrunKodu) + '</td><td>' +
        HTMLEscape(ASatirlar[I].Barkod) + '</td><td>' +
        HTMLEscape(ASatirlar[I].SutKodu) + '</td><td>' +
        HTMLEscape(ASatirlar[I].LotNo) + '</td><td>' +
        HTMLEscape(ASatirlar[I].SeriNo) + '</td><td>' +
        HTMLEscape(ASatirlar[I].UrunAdi) + '</td><td class="num">' +
        FormatFloat('#,##0.######', ASatirlar[I].Miktar) + ' ' +
        HTMLEscape(ASatirlar[I].BirimKodu) + '</td><td class="num">' +
        FormatFloat('#,##0.00####', ASatirlar[I].BirimFiyat) +
        '</td><td class="num">' + FormatFloat('#,##0.##',
        ASatirlar[I].KDVOrani) + '</td><td class="num">' +
        FormatFloat('#,##0.00', ASatirlar[I].Tutar) + '</td></tr>');
    LHTML.AppendLine('</tbody></table>');
    // Dip-toplam: iskonto varsa Mal Hizmet Toplam (BRUT) + Toplam Iskonto goster, sonra
    //   Net Tutar (Matrah) = iskonto sonrasi vergi matrahi (ABaslik.Matrah net). brut = Matrah + iskonto.
    var LDipIsk: Currency := SatirlarIskontoToplami(ASatirlar);
    var LDip: string := '<div class="box" style="text-align:right">';
    if LDipIsk > 0.0001 then
      LDip := LDip + '<b>Mal Hizmet Toplam Tutari:</b> ' +
        FormatFloat('#,##0.00', ABaslik.Matrah + LDipIsk) + ' ' + ABaslik.ParaBirimi +
        '<br><b>Toplam Iskonto:</b> ' + FormatFloat('#,##0.00', LDipIsk) + ' ' +
        ABaslik.ParaBirimi + '<br>';
    LDip := LDip + '<b>Net Tutar (Matrah):</b> ' +
      FormatFloat('#,##0.00', ABaslik.Matrah) + ' ' + ABaslik.ParaBirimi +
      '<br><b>KDV:</b> ' + FormatFloat('#,##0.00', ABaslik.KDV) + ' ' +
      ABaslik.ParaBirimi + '<br><b>Genel Toplam:</b> ' +
      FormatFloat('#,##0.00', ABaslik.Toplam) + ' ' + ABaslik.ParaBirimi + '</div>';
    LHTML.AppendLine(LDip);
    if Trim(ABaslik.Aciklama) <> '' then
      LHTML.AppendLine('<div class="box"><b>Aciklama:</b><br>' +
        HTMLEscape(ABaslik.Aciklama) + '</div>');
    LHTML.AppendLine('</body></html>');
    Result := LHTML.ToString;
  finally
    LHTML.Free;
  end;
end;

function TaslakFiligranGerekli(const ABaslik: TEBelgeBaslik): Boolean;
begin
  Result := (ABaslik.Tur in [EBelgeTuruEFatura, EBelgeTuruEIrsaliye]) and
            (ABaslik.EBelgeDurum <> 2) and
            not (ABaslik.EFaturaDurum in [2, 12, 22, 32, 52]);
end;

function TaslakFiligranMetni(const ABaslik: TEBelgeBaslik): string;
begin
  if ABaslik.Tur = EBelgeTuruEIrsaliye then
    Result := 'TASLAK IRSALIYE'
  else
    Result := 'TASLAK FATURA';
end;

function HTMLTaslakFiligranEkle(const AHTML, ATaslakText: string): string;
var
  LAltHTML, LFiligran: string;
  LPos: Integer;
begin
  Result := AHTML;
  if Pos(ATaslakText, Result) > 0 then
    Exit;

  LFiligran :=
    '<div style="position:fixed;left:50%;top:50%;' +
    'transform:translate(-50%,-50%) rotate(-35deg);' +
    'font-family:Arial,Segoe UI,sans-serif;font-size:72px;' +
    'font-weight:bold;color:#b00000;opacity:0.16;' +
    'z-index:2147483647;pointer-events:none;white-space:nowrap;' +
    '-webkit-print-color-adjust:exact;print-color-adjust:exact;">' +
    ATaslakText + '</div>';

  LAltHTML := AnsiLowerCase(Result);
  LPos := Pos('</body>', LAltHTML);
  if LPos > 0 then
    Insert(LFiligran, Result, LPos)
  else
    Result := Result + LFiligran;
end;

function BelgeXSLTGetir(ARehberID, ABelgeTuru: Integer;
  AEArsivMi, AGelenMi: Boolean; out AXSLT: string): Boolean;
// AGelenMi=True ise gelen XSLT opsiyonlari, False ise giden opsiyonlari kullanilir.
// Kurum (cari) ozel XSLT override sadece giden tarafi icin uygulanir; GENINI'den
// okunur (BOLUM=belge tipi, DEGER=REHBERID, ANAHTAR=XSLT adi).
var
  LXSLTID, LBolum: Integer;
  LXSLTAdi: string;
begin
  Result := False;
  AXSLT := '';
  LXSLTAdi := '';

  // Kurum (cari) ozel XSLT override sadece GIDEN icin gecerli.
  if (not AGelenMi) and (ARehberID > 0) then begin
    if ABelgeTuru = EBelgeTuruEIrsaliye then
      LBolum := Ops_KurumXSLT_EIrsaliye
    else if AEArsivMi then
      LBolum := Ops_KurumXSLT_EArsiv
    else
      LBolum := Ops_KurumXSLT_EFatura;
    Tablo.TablodanSorguAc(1,
      'select '+DbUst(1)+'ANAHTAR from GENINI where DIL=-1 and BOLUM=' +
      IntToStr(LBolum) + ' and DEGER=' + IntToStr(ARehberID) + ' '+DbSinir(1));
    if not Tablo.Query1.Eof then
      LXSLTAdi := Trim(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Close;
    if LXSLTAdi <> '' then begin
      Tablo.TablodanSorguAc(1,
        'select '+DbUst(1)+'SQL from DOKUMLER where GRUBU=''XSLT'' and RAPORADI=' +
        QuotedStr(LXSLTAdi) + ' order by ID desc '+DbSinir(1));
      if not Tablo.Query1.Eof then
        AXSLT := TurkceMojibakeDuzelt(Tablo.Query1.Fields[0].AsString);
      Tablo.Query1.Close;
    end;
  end;

  if Trim(AXSLT) = '' then begin
    // Gelen XSLT opsiyonlari Utablo cache'ine alinmiyor; GENINI'den dogrudan
    // okunur (giden tarafi mevcut Varsayilan* globallerini kullanmaya devam eder).
    if AGelenMi then begin
      if ABelgeTuru = EBelgeTuruEIrsaliye then
        LXSLTID := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EIrsaliyeGelenXSLT, 0)
      else if AEArsivMi then
        LXSLTID := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EArsivFaturaGelenXSLT, 0)
      else
        LXSLTID := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EFaturaGelenXSLT, 0);
    end else begin
      if ABelgeTuru = EBelgeTuruEIrsaliye then
        LXSLTID := VarsayilanEIrsaliyeXSLT
      else if AEArsivMi then
        LXSLTID := VarsayilanEArsivFaturaXSLT
      else
        LXSLTID := VarsayilanEFaturaXSLT;
    end;
    if LXSLTID > 0 then begin
      Tablo.TablodanSorguAc(1,
        'select SQL from DOKUMLER where ID=' + IntToStr(LXSLTID) +
        ' and GRUBU=''XSLT''' );
      if not Tablo.Query1.Eof then
        AXSLT := TurkceMojibakeDuzelt(Tablo.Query1.Fields[0].AsString);
      Tablo.Query1.Close;
    end;
  end;

  Result := Trim(AXSLT) <> '';
end;

function XSLTDonustur(const AUBLXML, AXSLT: string): string;
var
  LXMLBelgesi, LXSLTBelgesi: OleVariant;
begin
  Result := '';
  if (Trim(AUBLXML) = '') or (Trim(AXSLT) = '') then
    Exit;

  try
    LXMLBelgesi := CreateOleObject('Msxml2.DOMDocument.6.0');
    LXMLBelgesi.async := False;
    LXMLBelgesi.validateOnParse := False;
    LXMLBelgesi.resolveExternals := False;
    try LXMLBelgesi.setProperty('ProhibitDTD', True); except end;
    if not LXMLBelgesi.loadXML(AUBLXML) then
      Exit;

    LXSLTBelgesi := CreateOleObject('Msxml2.DOMDocument.6.0');
    LXSLTBelgesi.async := False;
    LXSLTBelgesi.validateOnParse := False;
    LXSLTBelgesi.resolveExternals := False;
    try LXSLTBelgesi.setProperty('ProhibitDTD', True); except end;
    try LXSLTBelgesi.setProperty('AllowDocumentFunction', False); except end;
    try LXSLTBelgesi.setProperty('AllowXsltScript', False); except end;
    if not LXSLTBelgesi.loadXML(AXSLT) then
      Exit;

    Result := TurkceMojibakeDuzelt(LXMLBelgesi.transformNode(LXSLTBelgesi));
  except
    Result := '';
  end;
end;

function XSLTGecerliMi(const AXSLT: string; out AHata: string): Boolean;
var
  LXSLTBelgesi, LRoot: OleVariant;
  LRootName, LRootNS: string;
begin
  Result := False;
  AHata := '';
  if Trim(AXSLT) = '' then begin
    AHata := 'XSLT icerigi bos.';
    Exit;
  end;

  try
    LXSLTBelgesi := CreateOleObject('Msxml2.DOMDocument.6.0');
    LXSLTBelgesi.async := False;
    LXSLTBelgesi.validateOnParse := False;
    LXSLTBelgesi.resolveExternals := False;
    try LXSLTBelgesi.setProperty('ProhibitDTD', True); except end;
    try LXSLTBelgesi.setProperty('AllowDocumentFunction', False); except end;
    try LXSLTBelgesi.setProperty('AllowXsltScript', False); except end;
    if not LXSLTBelgesi.loadXML(AXSLT) then begin
      AHata := Trim(VarToStr(LXSLTBelgesi.parseError.reason));
      if AHata = '' then
        AHata := 'XSLT XML olarak okunamadi.';
      Exit;
    end;

    LRoot := LXSLTBelgesi.documentElement;
    if VarIsEmpty(LRoot) or VarIsNull(LRoot) then begin
      AHata := 'XSLT kok elementi bulunamadi.';
      Exit;
    end;
    LRootName := LowerCase(VarToStr(LRoot.baseName));
    LRootNS := VarToStr(LRoot.namespaceURI);
    if not ((LRootName = 'stylesheet') or (LRootName = 'transform')) or
       not SameText(LRootNS, 'http://www.w3.org/1999/XSL/Transform') then begin
      AHata := 'XSLT kok elementi xsl:stylesheet veya xsl:transform degil.';
      Exit;
    end;

    Result := True;
  except
    on E: Exception do
      AHata := E.Message;
  end;
end;

function HTMLLotNoBilgisiEkle(const AHTML: string;
  const ASatirlar: TEBelgeSatirlar): string;
var
  LHTML: TStringBuilder;
  I: Integer;
  LEklenecek: Boolean;
  LBlok: string;
  LBodyPos, LBodySonu: Integer;
begin
  Result := AHTML;
  LEklenecek := False;
  if Pos('data-entegra-lotno="1"', LowerCase(Result)) > 0 then
    Exit;
  for I := 0 to High(ASatirlar) do
    if Trim(ASatirlar[I].LotNo) <> '' then begin
      LEklenecek := True;
      Break;
    end;
  if not LEklenecek then
    Exit;

  LHTML := TStringBuilder.Create;
  try
    LHTML.AppendLine('<div data-entegra-lotno="1" style="display:block !important;position:fixed;top:0;left:0;right:0;z-index:2147483647;background:#fff3cd;color:#000;border:2px solid #000;padding:8px 12px;font-family:Tahoma,Arial;font-size:12px;">');
    LHTML.AppendLine('<div style="display:block !important;font-weight:bold;margin-bottom:4px;">LOTNO Bilgileri</div>');
    LHTML.AppendLine('<table style="display:table !important;border-collapse:collapse;width:100%;background:#fff;">');
    LHTML.AppendLine('<thead style="display:table-header-group !important;"><tr><th style="border:1px solid #000;padding:4px;text-align:left;">Satir</th>' +
      '<th style="border:1px solid #000;padding:4px;text-align:left;">Urun</th>' +
      '<th style="border:1px solid #000;padding:4px;text-align:left;">LOTNO</th></tr></thead><tbody style="display:table-row-group !important;">');
    for I := 0 to High(ASatirlar) do
      if Trim(ASatirlar[I].LotNo) <> '' then
        LHTML.AppendLine('<tr style="display:table-row !important;"><td style="display:table-cell !important;border:1px solid #000;padding:4px;">' +
          IntToStr(ASatirlar[I].SatirNo) + '</td><td style="display:table-cell !important;border:1px solid #000;padding:4px;">' +
          HTMLEscape(ASatirlar[I].UrunAdi) + '</td><td style="display:table-cell !important;border:1px solid #000;padding:4px;font-weight:bold;">' +
          HTMLEscape(ASatirlar[I].LotNo) + '</td></tr>');
    LHTML.AppendLine('</tbody></table></div>');
    LBlok := LHTML.ToString;
  finally
    LHTML.Free;
  end;

  LBodyPos := Pos('<body', LowerCase(Result));
  if LBodyPos > 0 then begin
    LBodySonu := PosEx('>', Result, LBodyPos);
    if LBodySonu > 0 then begin
      Insert(LBlok, Result, LBodySonu + 1);
      Exit;
    end;
  end;

  if Pos('</body>', LowerCase(Result)) > 0 then
    Insert(LBlok, Result, Pos('</body>', LowerCase(Result)))
  else
    Result := LBlok + Result;
end;

function XSLTOnizlemeUret(ARehberID, ABelgeTuru: Integer;
  AEArsivMi, AGelenMi: Boolean; const AUBLXML: string): string;
var
  LXSLT: string;
begin
  Result := '';
  if Trim(AUBLXML) = '' then
    Exit;
  if not BelgeXSLTGetir(ARehberID, ABelgeTuru, AEArsivMi, AGelenMi, LXSLT) then
    Exit;
  Result := XSLTDonustur(AUBLXML, LXSLT);
end;

function GömülüXSLTGetir(const AUBLXML: string; out AXSLT: string): Boolean;
var
  LXMLBelgesi, LNode: OleVariant;
  LBase64: string;
  LBytes: TBytes;
begin
  Result := False;
  AXSLT := '';
  if Trim(AUBLXML) = '' then
    Exit;
  try
    LXMLBelgesi := CreateOleObject('Msxml2.DOMDocument.6.0');
    LXMLBelgesi.async := False;
    LXMLBelgesi.validateOnParse := False;
    LXMLBelgesi.resolveExternals := False;
    try LXMLBelgesi.setProperty('ProhibitDTD', True); except end;
    if not LXMLBelgesi.loadXML(AUBLXML) then
      Exit;

    LNode := LXMLBelgesi.selectSingleNode(
      '//*[local-name()="AdditionalDocumentReference"]' +
      '[*[local-name()="DocumentType" and translate(normalize-space(.),"xslt","XSLT")="XSLT"]]' +
      '//*[local-name()="EmbeddedDocumentBinaryObject"][1]');
    // NOT: selectSingleNode bazi belgelerde ( or. 113635) NULL/Empty degil,
    // "nil-dispatch" bir OleVariant dondurebiliyor; VarIsNull/VarIsEmpty bunu
    // yakalamaz, LNode.Text nil dereference -> AV. VType/VDispatch ile kesin kontrol.
    if VarIsEmpty(LNode) or VarIsNull(LNode) or
       (TVarData(LNode).VType <> varDispatch) or (TVarData(LNode).VDispatch = nil) then
      LNode := LXMLBelgesi.selectSingleNode(
        '//*[local-name()="EmbeddedDocumentBinaryObject"]' +
        '[contains(translate(string(@filename),"xslt","XSLT"),".XSLT")][1]');
    if VarIsEmpty(LNode) or VarIsNull(LNode) or
       (TVarData(LNode).VType <> varDispatch) or (TVarData(LNode).VDispatch = nil) then
      Exit;

    LBase64 := Trim(VarToStr(LNode.Text));
    LBase64 := StringReplace(LBase64, #13, '', [rfReplaceAll]);
    LBase64 := StringReplace(LBase64, #10, '', [rfReplaceAll]);
    LBase64 := StringReplace(LBase64, #9, '', [rfReplaceAll]);
    LBase64 := StringReplace(LBase64, ' ', '', [rfReplaceAll]);
    if LBase64 = '' then
      Exit;

    LBytes := TNetEncoding.Base64.DecodeStringToBytes(LBase64);
    AXSLT := TEncoding.UTF8.GetString(LBytes);
    if (AXSLT <> '') and (AXSLT[1] = #$FEFF) then
      Delete(AXSLT, 1, 1);
    Result := Trim(AXSLT) <> '';
  except
    AXSLT := '';
    Result := False;
  end;
end;

function OrnekEArsivXSLTGetir(out AXSLT: string): Boolean;
const
  COrnekXSLT = 'Ekspert_general_earsiv.xslt';
  COrnekDosya = 'EKA2026000000020_earsiv';
var
  LYollar: array[0..2] of string;
  I: Integer;
  LXML: string;
begin
  Result := False;
  AXSLT := '';
  LYollar[0] := TPath.Combine(GetCurrentDir, COrnekXSLT);
  LYollar[1] := TPath.Combine(ExtractFilePath(ParamStr(0)), COrnekXSLT);
  LYollar[2] := TPath.Combine('C:\Users\HP\Entegra\Entegra', COrnekXSLT);

  for I := Low(LYollar) to High(LYollar) do begin
    if not TFile.Exists(LYollar[I]) then
      Continue;
    AXSLT := TFile.ReadAllText(LYollar[I], TEncoding.UTF8);
    if (AXSLT <> '') and (AXSLT[1] = #$FEFF) then
      Delete(AXSLT, 1, 1);
    Result := Trim(AXSLT) <> '';
    if Result then
      Exit;
  end;

  LYollar[0] := TPath.Combine(GetCurrentDir, COrnekDosya);
  LYollar[1] := TPath.Combine(ExtractFilePath(ParamStr(0)), COrnekDosya);
  LYollar[2] := TPath.Combine('C:\Users\HP\Entegra\Entegra', COrnekDosya);

  for I := Low(LYollar) to High(LYollar) do begin
    if not TFile.Exists(LYollar[I]) then
      Continue;
    LXML := TFile.ReadAllText(LYollar[I], TEncoding.UTF8);
    Result := GömülüXSLTGetir(LXML, AXSLT);
    if Result then
      Exit;
  end;
end;

function XMLHTMLUret(const ATitle, AXML: string): string;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8">' +
    '<title>' + HTMLEscape(ATitle) + '</title>' +
    '<style>body{font-family:Segoe UI,Arial;margin:24px;color:#222}' +
    'pre{white-space:pre-wrap;word-break:break-word;border:1px solid #ddd;' +
    'background:#f8f8f8;padding:16px}</style></head><body>' +
    '<h2>' + HTMLEscape(ATitle) + '</h2>' +
    '<p>Bu gelen belgede kullanilabilir XSLT bulunamadi; ham XML gosteriliyor.</p>' +
    '<pre>' + HTMLEscape(AXML) + '</pre></body></html>';
end;

function GidenUBLXMLUret(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar): string;
var
  LGondericiVergiNo, LGondericiUnvan: string;
begin
  LGondericiVergiNo := Tablo.GENINI.ReadString(
    Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LGondericiUnvan := KURUMADI;
  Result := UBLXMLUret(ABaslik, ASatirlar, LGondericiVergiNo,
    LGondericiUnvan);
end;

function GidenHTMLUret(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar; const AUBLXML: string;
  ATaslakFiligran: Boolean): string;
begin
  Result := XSLTOnizlemeUret(ABaslik.RehberID, ABaslik.Tur,
                             ABaslik.EArsivMi, False, AUBLXML);
  if Trim(Result) = '' then
    Result := HTMLUret(ABaslik, ASatirlar);
  if ATaslakFiligran and TaslakFiligranGerekli(ABaslik) then
    Result := HTMLTaslakFiligranEkle(Result, TaslakFiligranMetni(ABaslik));
end;

procedure OlusturulmusGidenBelgeOku(AFatBaslikID: Integer;
  const AIslem: string; out ABaslik: TEBelgeBaslik;
  out ASatirlar: TEBelgeSatirlar);
begin
  VerileriOku(AFatBaslikID, ABaslik, ASatirlar);
  if ABaslik.EBelgeID = 0 then
    raise Exception.Create(AIslem + ' icin once e-belgeyi olusturun.');
end;

procedure HTMLDosyaPDFeCevir(const ATempHTML, ADosya: string); forward;

// EBELGE.UBL_XML sikistirma (opsiyon default AÇIK). Aktiflik + kolon garantisi
// UEBelgeGelen.EBelgeUBLSikistir(AConnection) ile yonetilir. Okuma her durumda
// COALESCE(DECOMPRESS(UBL_XML_ZIP), UBL_XML) ile calisir (SQL 2016+).
// UBL_XML'i okuyan SQL ifadesi (zipli/duz farketmez). SELECT'lerde kullanilir.
const
  C_UBL_OKU =
    'COALESCE(CAST(DECOMPRESS(UBL_XML_ZIP) AS NVARCHAR(MAX)),' +
    'CAST(UBL_XML AS NVARCHAR(MAX)))';

procedure EBelgeGuncelle(AConnection: TFDConnection;
  const ABaslik: TEBelgeBaslik; const AAPIJSON, AUBLXML: string;
  AKullanan: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConnection;
    LQuery.ResourceOptions.MacroCreate := False;
    var LUblSet: string;
    if (Trim(AUBLXML) <> '') and EBelgeUBLSikistir(AConnection) then
      LUblSet := 'UBL_XML=NULL, UBL_XML_ZIP=COMPRESS(cast(:UBL_XML as nvarchar(max))), '
    else
      LUblSet := 'UBL_XML=cast(:UBL_XML as nvarchar(max)), UBL_XML_ZIP=NULL, ';
    LQuery.SQL.Text :=
      'update ' + DepoTablo('EBELGE') + ' set REHBERID=:REHBERID, UUID=:UUID, BELGENO=:BELGENO, ' +
      'GONDERICIALIAS=:GONDERICIALIAS, ALICIALIAS=:ALICIALIAS, DURUM=1, ' +
      'API_JSON=cast(:API_JSON as nvarchar(max)), ' +
      LUblSet + 'DEGISTIREN=:DEGISTIREN, ' +
      'DEGISTIRMETARIHI=getdate() where ID=:ID';
    if AktifVeriMotor = vmPG then
      LQuery.SQL.Text := PgSqlCevir(LQuery.SQL.Text);
    LQuery.ParamByName('REHBERID').AsInteger := ABaslik.RehberID;
    LQuery.ParamByName('UUID').AsString := ABaslik.UUID;
    LQuery.ParamByName('BELGENO').AsString := ABaslik.FaturaNo;
    LQuery.ParamByName('GONDERICIALIAS').AsString := ABaslik.GondericiAlias;
    LQuery.ParamByName('ALICIALIAS').AsString := ABaslik.AliciAlias;
    LQuery.ParamByName('API_JSON').DataType := ftWideMemo;
    LQuery.ParamByName('API_JSON').Size := Length(AAPIJSON);
    LQuery.ParamByName('API_JSON').AsWideMemo := AAPIJSON;
    LQuery.ParamByName('UBL_XML').DataType := ftWideMemo;
    LQuery.ParamByName('UBL_XML').Size := Length(AUBLXML);
    LQuery.ParamByName('UBL_XML').AsWideMemo := AUBLXML;
    LQuery.ParamByName('DEGISTIREN').AsInteger := AKullanan;
    LQuery.ParamByName('ID').AsLargeInt := ABaslik.EBelgeID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function EBelgeEkle(AConnection: TFDConnection;
  const ABaslik: TEBelgeBaslik; const AAPIJSON, AUBLXML: string;
  AKullanan: Integer): Int64;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConnection;
    LQuery.ResourceOptions.MacroCreate := False;
    var LUblVals: string;
    if (Trim(AUBLXML) <> '') and EBelgeUBLSikistir(AConnection) then
      LUblVals := 'NULL,COMPRESS(cast(:UBL_XML as nvarchar(max)))'
    else
      LUblVals := 'cast(:UBL_XML as nvarchar(max)),NULL';
    LQuery.SQL.Text :=
      'insert into ' + DepoTablo('EBELGE') + '(FATBASLIKID,REHBERID,BELGETURU,YON,UUID,BELGENO,' +
      'GONDERICIALIAS,ALICIALIAS,DURUM,API_JSON,UBL_XML,UBL_XML_ZIP,EKLEYEN) values(' +
      ':FATBASLIKID,:REHBERID,:BELGETURU,1,:UUID,:BELGENO,:GONDERICIALIAS,' +
      ':ALICIALIAS,1,cast(:API_JSON as nvarchar(max)),' +
      LUblVals + ',:EKLEYEN)';
    if AktifVeriMotor = vmPG then
      LQuery.SQL.Text := PgSqlCevir(LQuery.SQL.Text + ' returning ID')
    else
      LQuery.SQL.Text := LQuery.SQL.Text + '; select cast(scope_identity() as bigint) as ID';
    LQuery.ParamByName('FATBASLIKID').AsInteger := ABaslik.ID;
    LQuery.ParamByName('REHBERID').AsInteger := ABaslik.RehberID;
    LQuery.ParamByName('BELGETURU').AsInteger := ABaslik.EBelgeBelgeTuru;
    LQuery.ParamByName('UUID').AsString := ABaslik.UUID;
    LQuery.ParamByName('BELGENO').AsString := ABaslik.FaturaNo;
    LQuery.ParamByName('GONDERICIALIAS').AsString := ABaslik.GondericiAlias;
    LQuery.ParamByName('ALICIALIAS').AsString := ABaslik.AliciAlias;
    LQuery.ParamByName('API_JSON').DataType := ftWideMemo;
    LQuery.ParamByName('API_JSON').Size := Length(AAPIJSON);
    LQuery.ParamByName('API_JSON').AsWideMemo := AAPIJSON;
    LQuery.ParamByName('UBL_XML').DataType := ftWideMemo;
    LQuery.ParamByName('UBL_XML').Size := Length(AUBLXML);
    LQuery.ParamByName('UBL_XML').AsWideMemo := AUBLXML;
    LQuery.ParamByName('EKLEYEN').AsInteger := AKullanan;
    LQuery.Open;
    Result := LQuery.FieldByName('ID').AsLargeInt;
  finally
    LQuery.Free;
  end;
end;

function MenuBaslikOku(AConnection: TFDConnection; AFatBaslikID: Integer;
  out ABaslik: TEBelgeMenuBaslik): Boolean;
var
  LQ: TFDQuery;
begin
  Result := False;
  ABaslik := Default(TEBelgeMenuBaslik);
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConnection;
    LQ.SQL.Text :=
      'select ID,TUR,isnull(EFATURADURUM,0) EFATURADURUM,' +
      'isnull(EFATURASONUC,0) EFATURASONUC,isnull(SENARYO,0) SENARYO,REHBERID,FATURATARIH,' +
      'isnull(FATURANO,'''') FATURANO,isnull(FATURASERI,'''') FATURASERI,' +
      'isnull(VNO,'''') VNO,isnull(BASLIK,'''') BASLIK ' +
      'from FATBASLIK where ID=:ID';
    if AktifVeriMotor = vmPG then
      LQ.SQL.Text := PgSqlCevir(LQ.SQL.Text);
    LQ.ParamByName('ID').AsInteger := AFatBaslikID;
    LQ.Open;
    if LQ.Eof then
      Exit;
    ABaslik.ID := LQ.FieldByName('ID').AsInteger;
    ABaslik.Tur := LQ.FieldByName('TUR').AsInteger;
    ABaslik.Senaryo := LQ.FieldByName('SENARYO').AsInteger;
    ABaslik.EFaturaDurum := LQ.FieldByName('EFATURADURUM').AsInteger;
    ABaslik.EFaturaSonuc := LQ.FieldByName('EFATURASONUC').AsInteger;
    ABaslik.RehberID := LQ.FieldByName('REHBERID').AsInteger;
    ABaslik.FaturaTarih := LQ.FieldByName('FATURATARIH').AsDateTime;
    ABaslik.FaturaNo := LQ.FieldByName('FATURANO').AsString;
    ABaslik.FaturaSeri := LQ.FieldByName('FATURASERI').AsString;
    ABaslik.VergiNo := LQ.FieldByName('VNO').AsString;
    ABaslik.Baslik := LQ.FieldByName('BASLIK').AsString;
    Result := True;
  finally
    LQ.Free;
  end;
end;

function EBelgeSerileri(ATur, ABelgeTuru: Integer): string;
begin
  if ATur = EBelgeTuruEIrsaliye then
    Result := Trim(EIrsaliyeSerileri)
  else if ABelgeTuru = RAlias_EArsiv then
    Result := Trim(EArsivFaturaSerileri)
  else
    Result := Trim(EFaturaSerileri);
end;

function EBelgeSeriKuralBolumu(ATur, ABelgeTuru: Integer): Integer;
begin
  if ATur = EBelgeTuruEIrsaliye then
    Result := Ops_FaturaOpsiyon_EIrsaliyeSeriKurallari
  else if ABelgeTuru = RAlias_EArsiv then
    Result := Ops_FaturaOpsiyon_EArsivSeriKurallari
  else
    Result := Ops_FaturaOpsiyon_EFaturaSeriKurallari;
end;

function EBelgeSerileriYeni(AConnection: TFDConnection; ATur, ABelgeTuru,
  ASenaryo, AKullaniciID: Integer): string;
var
  LQ: TFDQuery;
  LListe, LParcalar: TStringList;
  LSeri: string;
  LSatirSenaryo, LSatirKullaniciID: Integer;
begin
  Result := '';
  LListe := TStringList.Create;
  LParcalar := TStringList.Create;
  LQ := TFDQuery.Create(nil);
  try
    LParcalar.StrictDelimiter := True;
    LParcalar.Delimiter := ',';
    LQ.Connection := AConnection;
    if AktifVeriMotor = vmPG then
      LQ.SQL.Text :=
        'select ANAHTAR, SIRA from GENINI where BOLUM=' +
        IntToStr(EBelgeSeriKuralBolumu(ATur, ABelgeTuru)) +
        ' and DIL=-1 order by coalesce(SIRA,0), ANAHTAR'
    else
      LQ.SQL.Text :=
        'with K as (' +
        'select SERI=left(ANAHTAR, charindex('','', ANAHTAR+'','')-1), ' +
        'SENARYO=try_convert(int, parsename(replace(ANAHTAR,'','',''.''),2)), ' +
        'KULLANICIID=try_convert(int, parsename(replace(ANAHTAR,'','',''.''),1)), ' +
        'SIRA ' +
        'from GENINI where BOLUM=:BOLUM and DIL=-1) ' +
        'select SERI from K ' +
        'where isnull(SERI,'''')<>'''' ' +
        'and isnull(SENARYO,0) in (0,:SENARYO) ' +
        'and isnull(KULLANICIID,0) in (0,:KULLANICIID) ' +
        'order by case ' +
        'when SENARYO=:SENARYO and KULLANICIID=:KULLANICIID then 1 ' +
        'when SENARYO=0 and KULLANICIID=:KULLANICIID then 2 ' +
        'when SENARYO=:SENARYO and KULLANICIID=0 then 3 ' +
        'else 4 end, isnull(SIRA,0), SERI';
    if AktifVeriMotor <> vmPG then begin
      LQ.ParamByName('BOLUM').AsInteger := EBelgeSeriKuralBolumu(ATur, ABelgeTuru);
      LQ.ParamByName('SENARYO').AsInteger := ASenaryo;
      LQ.ParamByName('KULLANICIID').AsInteger := AKullaniciID;
    end;
    LQ.Open;
    while not LQ.Eof do begin
      if AktifVeriMotor = vmPG then begin
        LParcalar.DelimitedText := LQ.FieldByName('ANAHTAR').AsString;
        LSeri := '';
        LSatirSenaryo := 0;
        LSatirKullaniciID := 0;
        if LParcalar.Count > 0 then
           LSeri := Trim(LParcalar[0]);
        if LParcalar.Count > 1 then
           LSatirSenaryo := StrToIntDef(Trim(LParcalar[1]), 0);
        if LParcalar.Count > 2 then
           LSatirKullaniciID := StrToIntDef(Trim(LParcalar[2]), 0);
        if not ((LSatirSenaryo in [0, ASenaryo]) and
          (LSatirKullaniciID in [0, AKullaniciID])) then begin
          LQ.Next;
          Continue;
        end;
      end else
        LSeri := Trim(LQ.FieldByName('SERI').AsString);
      if (LSeri <> '') and (LListe.IndexOf(LSeri) < 0) then
        LListe.Add(LSeri);
      LQ.Next;
    end;
    if LListe.Count > 0 then
      Result := LListe.CommaText
    else
      Result := EBelgeSerileri(ATur, ABelgeTuru);
  finally
    LQ.Free;
    LParcalar.Free;
    LListe.Free;
  end;
end;

function SeriSecimi(AConnection: TFDConnection; ATur, ABelgeTuru, ASenaryo,
  AKullaniciID: Integer; const AExcludeSeri: string; out AYeniSeri: string): Boolean;
var
  i: Integer;
  LSeriler: string;
  LListe: TStringList;
  LCtrls: TGirdiDenetimleri;
  LVarSecim: Variant;
begin
  Result := False;
  AYeniSeri := '';
  LSeriler := EBelgeSerileriYeni(AConnection, ATur, ABelgeTuru, ASenaryo, AKullaniciID);
  if LSeriler = '' then begin
    ShowMessage('Bu belge turu icin seri tanimi bulunamadi (Opsiyon ekranindan tanimlayin).');
    Exit;
  end;

  LListe := TStringList.Create;
  try
    LListe.Delimiter := ',';
    LListe.StrictDelimiter := True;
    LListe.DelimitedText := LSeriler;
    for i := LListe.Count - 1 downto 0 do begin
      LListe[i] := Trim(LListe[i]);
      if (LListe[i] = '') or
         ((AExcludeSeri <> '') and SameText(LListe[i], AExcludeSeri)) then
        LListe.Delete(i);
    end;

    if LListe.Count = 0 then begin
      if AExcludeSeri <> '' then
        ShowMessage('Tek seri tanimli, seri degistirilemez.')
      else
        ShowMessage('Tanimli seri bulunamadi.');
      Exit;
    end;

    if LListe.Count = 1 then
      AYeniSeri := LListe[0]
    else begin
      LVarSecim := LListe[0];
      LCtrls := TGirdiDenetimleri.Create.ComboBox('Seri seciniz:', @LVarSecim, LListe);
      if TGirisKutusuEx.BilgiAlEx('Belge Seri Secimi', LCtrls) <> mrOk then
        Exit;
      AYeniSeri := Trim(VarToStrDef(LVarSecim, ''));
    end;

    if Length(AYeniSeri) <> 3 then begin
      ShowMessage('Seri 3 karakter olmalidir.');
      Exit;
    end;
    Result := True;
  finally
    LListe.Free;
  end;
end;

function SonrakiSiraNo(AID, ATur: Integer; const ASeri: string;
  AYil: Integer; out ASeq: Int64): Boolean;
var
  LAdet, LBaslangic, LGonderilmisAdet: Integer;
  LIlkBosluk, LSonraki: Int64;
  LSeriYil, LBelgeTuruList: string;
  LStartStr, LSecim: Variant;
  LCtrls: TGirdiDenetimleri;
  LSecenekler: TStringList;
begin
  Result := False;
  ASeq := 0;
  LSeriYil := ASeri + IntToStr(AYil);

  // Mevcut (gonderilmis veya olusturulmus, sifirlanmamis) numaralari oku.
  // ILKBOSLUK: serideki ilk bos numara. SONRAKI: en buyuk numara + 1.
  // Hic gonderilmis belge yoksa ve bu iki aday farkliysa kullanici secer.
  if AktifVeriMotor = vmPG then
    Tablo.TablodanSorguAc(1,
      'with K as (select cast(right(FATURANO,9) as bigint) as N, EFATURADURUM ' +
      'from FATBASLIK where ID<>' + IntToStr(AID) +
      ' and TUR=' + IntToStr(ATur) +
      ' and length(FATURANO)=16 and FATURANO like ''' + LSeriYil + '%''' +
      ' and right(FATURANO,9) ~ ''^[0-9]+$'') ' +
      'select (select count(*) from K) as ADET, ' +
      '(select count(*) from K where EFATURADURUM in (2,12,52)) as GONDERILMIS, ' +
      'coalesce(coalesce(' +
      '(select min(K.N+1) from K where K.N<(select max(N) from K) ' +
      'and not exists (select 1 from K K2 where K2.N=K.N+1)), ' +
      '(select case when min(N)>1 then min(N)-1 end from K), ' +
      '(select max(N)+1 from K)),1) as ILKBOSLUK, ' +
      'coalesce((select max(N)+1 from K),1) as SONRAKI')
  else
    Tablo.TablodanSorguAc(1,
      'with K as (select try_convert(bigint,right(FATURANO,9)) as N, EFATURADURUM ' +
      'from FATBASLIK where ID<>' + IntToStr(AID) +
      ' and TUR=' + IntToStr(ATur) +
      ' and len(FATURANO)=16 and FATURANO like ''' + LSeriYil + '%''' +
      ' and try_convert(bigint,right(FATURANO,9)) is not null) ' +
      'select ADET=(select count(*) from K), ' +
      'GONDERILMIS=(select count(*) from K where EFATURADURUM in (2,12,52)), ' +
      'ILKBOSLUK=isnull(coalesce(' +
      '(select min(K.N+1) from K where K.N<(select max(N) from K) ' +
      'and not exists (select 1 from K K2 where K2.N=K.N+1)), ' +
      '(select case when min(N)>1 then min(N)-1 end from K), ' +
      '(select max(N)+1 from K)),1), ' +
      'SONRAKI=isnull((select max(N)+1 from K),1)');
  LAdet := Tablo.Query1.FieldByName('ADET').AsInteger;
  LGonderilmisAdet := Tablo.Query1.FieldByName('GONDERILMIS').AsInteger;
  LIlkBosluk := Tablo.Query1.FieldByName('ILKBOSLUK').AsLargeInt;
  LSonraki := Tablo.Query1.FieldByName('SONRAKI').AsLargeInt;
  // Varsayilan: en son numaradan 1 fazlasi (SONRAKI = max+1). Boslugu OTOMATIK
  // doldurmaz; bosluk doldurma yalnizca (gonderilmis belge yoksa) diyalogla secilir.
  ASeq := LSonraki;
  Tablo.Query1.Close;

  if (LAdet > 0) and (LGonderilmisAdet = 0) and (LIlkBosluk <> LSonraki) then begin
    LSecenekler := TStringList.Create;
    try
      LSecenekler.Add(IntToStr(LSonraki));    // varsayilan: en son numaradan +1 (append)
      LSecenekler.Add(IntToStr(LIlkBosluk));  // alternatif: ilk bos numarayi doldur
      LSecim := IntToStr(LSonraki);
      LCtrls := TGirdiDenetimleri.Create.ComboBox('Belge sira no seciniz:', @LSecim,
        LSecenekler, csDropDownList);
      if TGirisKutusuEx.BilgiAlEx('Belge No Secimi - ' + LSeriYil, LCtrls) <> mrOk then
        Exit;
      ASeq := StrToInt64Def(VarToStrDef(LSecim, ''), 0);
      if (ASeq <> LIlkBosluk) and (ASeq <> LSonraki) then begin
        ShowMessage('Gecerli bir belge sira no seciniz.');
        Exit;
      end;
    finally
      LSecenekler.Free;
    end;
  end;

  if LAdet = 0 then begin
    if ATur = EBelgeTuruEIrsaliye then
      LBelgeTuruList := '140,141'
    else
      LBelgeTuruList := '150,151';
    Tablo.TablodanSorguAc(1,
      'select ADET=count(*) from ' + DepoTablo('EBELGE') + ' where YON=1' +
      ' and BELGETURU in (' + LBelgeTuruList + ')' +
      ' and len(BELGENO)=16 and BELGENO like ''' + ASeri + '%''');
    LAdet := Tablo.Query1.FieldByName('ADET').AsInteger;
    Tablo.Query1.Close;

    if LAdet = 0 then begin
      LStartStr := '1';
      LCtrls := TGirdiDenetimleri.Create.Edit(
        'Baslangic numarasi (max 9 hane):', @LStartStr);
      if TGirisKutusuEx.BilgiAlEx('Baslangic No - ' + ASeri, LCtrls) <> mrOk then
        Exit;
      LBaslangic := StrToIntDef(VarToStrDef(LStartStr, '0'), 0);
      if LBaslangic <= 0 then begin
        ShowMessage('Gecerli bir baslangic numarasi giriniz.');
        Exit;
      end;
      ASeq := LBaslangic;
    end else
      ASeq := 1;
  end;

  if (ASeq <= 0) or (ASeq > 999999999) then begin
    ShowMessage('Yillik sira numarasi siniri asildi (max 9 hane).');
    Exit;
  end;

  Result := True;
end;

function IlkIkiKelime(const S: string): string;
var
  i: Integer;
  Tmp, C: string;
  Parcalar: TArray<string>;
begin
  Tmp := Trim(S);
  for i := 1 to Length(Tmp) do begin
    C := Tmp[i];
    if Pos(C, '\/:*?"<>|') > 0 then
      Tmp[i] := ' ';
  end;
  Parcalar := Tmp.Split([' '], TStringSplitOptions.ExcludeEmpty);
  if Length(Parcalar) = 0 then
    Result := 'eBelge'
  else if Length(Parcalar) = 1 then
    Result := Parcalar[0]
  else
    Result := Parcalar[0] + ' ' + Parcalar[1];
end;

function BelgeTurAdi(AConnection: TFDConnection; AFatBaslikID, ATur: Integer): string;
var
  LQ: TFDQuery;
  LAlias: string;
begin
  case ATur of
    EBelgeTuruEIrsaliye: Result := 'E-Irsaliye';
    EBelgeTuruEFatura:
      begin
        LAlias := '';
        LQ := TFDQuery.Create(nil);
        try
          LQ.Connection := AConnection;
          LQ.SQL.Text :=
            'SELECT '+DbUst(1)+'ALICIALIAS FROM ' + DepoTablo('EBELGE') + ' WHERE FATBASLIKID=:ID ORDER BY ID DESC '+DbSinir(1);
          LQ.ParamByName('ID').AsInteger := AFatBaslikID;
          LQ.Open;
          if not LQ.Eof then
            LAlias := LQ.Fields[0].AsString;
        finally
          LQ.Free;
        end;
        if Trim(LAlias) <> '' then
          Result := 'E-Fatura'
        else
          Result := 'E-ArsivFatura';
      end;
  else
    Result := 'eBelge';
  end;
end;

function EskiBosFaturaOnayi(AConnection: TFDConnection;
  const ABaslik: TEBelgeMenuBaslik): Boolean;
var
  LQ: TFDQuery;
  LMesaj: string;
begin
  Result := True;
  if Trim(ABaslik.FaturaNo) <> '0' then
    Exit;

  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConnection;
    LQ.SQL.Text :=
      'select '+DbUst(1)+'ID,FATURATARIH from FATBASLIK ' +
      'where ID<>:ID and TUR=:TUR and isnull(EFATURADURUM,0)=0 ' +
      'and ltrim(rtrim(isnull(FATURANO,'''')))=''0'' ' +
      'and cast(FATURATARIH as date)<cast(:TARIH as date) ' +
      'order by FATURATARIH,ID '+DbSinir(1);
    PgQueryCevir(LQ);
    LQ.ParamByName('ID').AsInteger := ABaslik.ID;
    LQ.ParamByName('TUR').AsInteger := ABaslik.Tur;
    LQ.ParamByName('TARIH').AsDateTime := ABaslik.FaturaTarih;
    LQ.Open;
    if LQ.Eof then
      Exit;

    LMesaj :=
      'Daha onceki tarihe ait numara verilmemis/hazirlanmamis fatura var.' +
      sLineBreak +
      'ID: ' + LQ.FieldByName('ID').AsString +
      ' Tarih: ' + FormatDateTime('dd.mm.yyyy',
        LQ.FieldByName('FATURATARIH').AsDateTime) +
      sLineBreak + sLineBreak +
      'Yine de bu belgeyi hazirlamak istiyor musunuz?';
    Result := Application.MessageBox(PChar(LMesaj), 'Uyari',
      MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2) = IDYES;
  finally
    LQ.Free;
  end;
end;

{ ---- Menu ortak yardimcilari ---- }

// Gonderilmis (EFATURADURUM 2/12/52) belge islem engeli; True = engellendi (mesaj gosterilir).
function GonderilmisEngeli(AEFaturaDurum: Integer; const AMesaj: string = ''): Boolean;
begin
  Result := AEFaturaDurum in [2, 12, 52];
  if Result then
    if AMesaj <> '' then
      ShowMessage(AMesaj)
    else
      ShowMessage('Gonderilmis belge uzerinde islem yapilamaz.');
end;

// Virgullu seri listesinden ILK seriyi dondurur ('GNT,GNY' -> 'GNT').
function IlkSeri(const ASeriler: string): string;
var
  P: Integer;
begin
  P := Pos(',', ASeriler);
  if P > 0 then
    Result := Trim(Copy(ASeriler, 1, P - 1))
  else
    Result := Trim(ASeriler);
end;

// 16 karakterlik belge no: SERI(3) + YIL(4) + 9 haneli sira numarasi.
function BelgeNoUret(const ASeri: string; AYil: Integer; ASiraNo: Int64): string;
var
  LNo: string;
begin
  LNo := IntToStr(ASiraNo);
  while Length(LNo) < 9 do
    LNo := '0' + LNo;
  Result := ASeri + IntToStr(AYil) + LNo;
end;

class function TEBelgeOlusturucu.MenuHazirla(AConnection: TFDConnection;
  AFatBaslikID: Integer): Boolean;
var
  LBaslik: TEBelgeMenuBaslik;
  LSeri, LNumara, LAlias, LVergiNo,
  LAliasUyari, LMesaj, LCariAdi, LRehberMail: string;
  LNumaraYili: Integer;
  LSonrakiNo, LEBelgeID: Int64;
  LOwnTransaction: Boolean;
  LAliasSonuc: TAliasYonetimSonuc;
  LDurum: Integer;
  LOnBaslik: TEBelgeBaslik;
  LOnSatirlar: TEBelgeSatirlar;
  LOnSevkHata: string;
begin
  Result := False;
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;

  if GonderilmisEngeli(LBaslik.EFaturaDurum) then
    Exit;
  if LBaslik.EFaturaDurum > 0 then begin
    ShowMessage('eBelge zaten olusturulmus.');
    Exit;
  end;
  if not (LBaslik.Tur in [EBelgeTuruEIrsaliye, EBelgeTuruEFatura]) then begin
    ShowMessage('Bu islem yalnizca e-Fatura ve e-Irsaliye belgeleri icin kullanilabilir.');
    Exit;
  end;

  try
    // VALIDASYON EN BASTA: tevkifat dogrulamasini, FATURANO uretilmeden ve
    // alias islemleri yapilmadan ONCE calistir. Boylece validasyon basarisiz
    // olursa fatura numarasi tuketilmez / alias bosa olusturulmaz.
    VerileriOku(LBaslik.ID, LOnBaslik, LOnSatirlar);
    if (LOnBaslik.Tipi = 22) or SatirlardaTevkifatVar(LOnSatirlar) then
      TevkifatNedeniKontrolEt(LOnBaslik, LOnSatirlar);
    TamIskontoNedeniKontrolEt(LOnBaslik, LOnSatirlar);

    // TEVKIFAT faturasi (Tipi=22): en az bir satirda GECERLI tevkifat (>0) olmali.
    // Satirin KDV orani 0 ise tevkifat tutari da 0 olur (tevkifat = KDV'nin yuzdesi)
    // -> izibiz "en az bir satira tevkifat uygulanmali" reddeder. Numara tuketmeden dur.
    if LOnBaslik.Tipi = 22 then begin
      var LTevkToplam: Currency := 0;
      for var LTS in LOnSatirlar do
        LTevkToplam := LTevkToplam + SatirTevkifatTutar(LTS);
      if LTevkToplam <= 0 then
        raise Exception.Create(
          'Tevkifat faturasında hiçbir satırda geçerli tevkifat yok. ' +
          'Tevkifat, KDV''nin bir yüzdesidir; satırların KDV oranının 0 olmadığından ' +
          've tevkifat oranının girildiğinden emin olun.');
    end;

    // KDV İstisna fatura (TIPI=24): istisna nedeni (PLANID) secilmemisse durdur.
    if (LOnBaslik.Tipi = 24) and (LOnBaslik.PlanID <= 0) then
      raise Exception.Create('KDV Istisna faturasinda istisna nedeni secilmemis ' +
        '(FATBASLIK.PLANID). Lutfen fatura uzerinde KDV Istisna Nedeni secin.');

    // e-Irsaliye icin sevk/tasima bilgisi zorunlu; eksikse numara/alias
    // tuketmeden once durdur.
    if LOnBaslik.Tur = EBelgeTuruEIrsaliye then begin
      LOnSevkHata := SevkBilgisiDogrula(SevkBilgisiGetir(LOnBaslik.ID));
      if LOnSevkHata <> '' then
        raise Exception.Create(LOnSevkHata + sLineBreak +
          'Sevk bilgilerini "Sevk Adresi" alanindan girebilirsiniz.');
    end;

    // Ihracat faturasi (Senaryo=3): FATURA_USER.IHRACAT + urun GTIP zorunlu.
    // Eksikse numara/alias tuketmeden UYAR ve DUR.
    if LOnBaslik.Senaryo = 3 then begin
      var LIhrEksik: string := IhracatEksikAlanlar(LOnBaslik, LOnSatirlar);
      if LIhrEksik <> '' then
        raise Exception.Create(
          'İhracat faturası hazırlanamaz. Aşağıdaki zorunlu alanlar eksik:' +
          sLineBreak + LIhrEksik + sLineBreak + sLineBreak +
          'Grid sağ tuş menüsünden "İhracat Bilgilerini Düzenle" alanını doldurun; ürün kartında GTIP girin.');
    end;

    if not EskiBosFaturaOnayi(AConnection, LBaslik) then
      Exit;

    LVergiNo := Trim(LBaslik.VergiNo);
    if LVergiNo = '' then
      LVergiNo := Tablo.TicariBilgiGetir(2, LBaslik.RehberID, RehVars_Vergi_No);

    LCariAdi := Tablo.AciklamaGetir('REHBER', 'FIRMA', LBaslik.RehberID);
    LRehberMail := '';
    try
      Tablo.TablodanSorguAc(8,
        ' SELECT RI.AD, RB.ETIKET, RB.BILGI ' +
        ' FROM REHBERBILGI RB INNER JOIN REHBERILETISIM RI ON RB.YER_ID = RI.ID ' +
        ' WHERE RI.REHBERID = ' + IntToStr(LBaslik.RehberID) +
        ' AND RB.YERI = 1 AND RB.BILGI LIKE ''%@%'' ');
      while not Tablo.Query8.Eof do begin
        if LRehberMail <> '' then
          LRehberMail := LRehberMail + ', ';
        LRehberMail := LRehberMail + Trim(Tablo.Query8.FieldByName('BILGI').AsString);
        Tablo.Query8.Next;
      end;
    except
    end;

    if LOnBaslik.Senaryo = 3 then begin
      // IHRACAT: alici Gumruk'tur; yurt disi gercek alici GIB mukellefi DEGIL.
      // Alici alias sorgusu YAPILMAZ (yoksa alias bulunamayip e-Arsiv'e duser veya
      // "iptal" olur). Belge her zaman e-Fatura; alias bos (gonderimde IHRACAT'ta
      // receiverAlias gonderilmez, izibiz Gumruk'e customerParty'den yonlendirir).
      LAliasSonuc := Default(TAliasYonetimSonuc);
      LAliasSonuc.Basari := True;
      LAliasSonuc.BelgeTuru := RAlias_EFatura;
      LAliasSonuc.Alias := '';
      LAliasSonuc.Mesaj := '';
    end else
      LAliasSonuc := TEBelgeAliasServis.AliasIslemiYap(AConnection,
        LBaslik.RehberID, LBaslik.Tur, LVergiNo, LCariAdi, LRehberMail);
    if not LAliasSonuc.Basari then begin
      ShowMessage('e-Belge olusturma iptal: ' + LAliasSonuc.Mesaj);
      Exit;
    end;
    LAlias := LAliasSonuc.Alias;
    LAliasUyari := LAliasSonuc.Mesaj;

    if Trim(LBaslik.FaturaNo) = '0' then begin
      LSeri := IlkSeri(EBelgeSerileriYeni(AConnection, LBaslik.Tur,
        LAliasSonuc.BelgeTuru, LOnBaslik.Senaryo, StrToIntDef(Kullanan, 0)));
      if Length(LSeri) <> 3 then begin
        ShowMessage('Bu belge turu icin gecerli ilk seri tanimi yok (3 karakter olmali).');
        Exit;
      end;

      LNumaraYili := YearOf(LBaslik.FaturaTarih);
      if not SonrakiSiraNo(LBaslik.ID, LBaslik.Tur, LSeri, LNumaraYili, LSonrakiNo) then
        Exit;
      LNumara := BelgeNoUret(LSeri, LNumaraYili, LSonrakiNo);

      LOwnTransaction := not AConnection.InTransaction;
      if LOwnTransaction then
        AConnection.StartTransaction;
      try
        Veritabani.BasitKomutÇalıştır(AConnection,
          'update FATBASLIK set FATURANO=&FATURANO,FATURASERI=&SERI ' +
          'where ID=&ID and ltrim(rtrim(isnull(FATURANO,'''')))=''0''',
          ['&FATURANO', '&SERI', '&ID'], [LNumara, LSeri, LBaslik.ID]);
        if LOwnTransaction then
          AConnection.Commit;
      except
        if LOwnTransaction and AConnection.InTransaction then
          AConnection.Rollback;
        raise;
      end;
    end else
      LNumara := LBaslik.FaturaNo;

    LEBelgeID := Olustur(AConnection, LBaslik.ID, LAlias, LAliasSonuc.BelgeTuru);
    if LEBelgeID > 0 then begin
      LDurum := 0;
      case LAliasSonuc.BelgeTuru of
        RAlias_EFatura: LDurum := 1;
        RAlias_EArsiv: LDurum := 11;
        RAlias_EIrsaliyeGIB, RAlias_EIrsaliyeKendi: LDurum := 51;
      end;
      if LDurum > 0 then
        Veritabani.BasitKomutÇalıştır(AConnection,
          'UPDATE FATBASLIK SET EFATURADURUM=&D, EFATURASONUC=0 WHERE ID=&ID',
          ['&D', '&ID'], [LDurum, LBaslik.ID]);
      if (AktifVeriMotor = vmPG) and AConnection.InTransaction then
        AConnection.Commit;
    end;

    LMesaj := 'Belge No: ' + LNumara + sLineBreak +
      'EBELGE ID: ' + IntToStr(LEBelgeID);
    if LAlias <> '' then
      LMesaj := LMesaj + sLineBreak + 'Alias: ' + LAlias
    else
      LMesaj := LMesaj + sLineBreak + 'Bu belge turu icin alias bulunamadi.';
    if LAliasUyari <> '' then
      LMesaj := LMesaj + sLineBreak + 'Alias servis uyarisi: ' + LAliasUyari;
    ShowMessage(LMesaj);
    Result := True;
  except
    on E: Exception do
      ShowMessage('e-Belge olusturma hatasi: ' + E.Message);
  end;
end;

class function TEBelgeOlusturucu.MenuOnizle(AConnection: TFDConnection;
  AFatBaslikID: Integer): Boolean;
var
  LBaslik: TEBelgeMenuBaslik;
begin
  Result := False;
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;
  try
    if LBaslik.Tur = 11 then begin
      OnizleGelen(AConnection, AFatBaslikID);
      Result := True;
      Exit;
    end;

    if LBaslik.EFaturaDurum = 0 then begin
      if not MenuHazirla(AConnection, AFatBaslikID) then
        Exit;
      if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
        Exit;
      if LBaslik.EFaturaDurum = 0 then
        Exit;
    end;

    Onizle(AConnection, AFatBaslikID);
    Result := True;
  except
    on E: Exception do
      ShowMessage('e-Belge onizleme hatasi: ' + E.Message);
  end;
end;

class function TEBelgeOlusturucu.MenuSifirla(AConnection: TFDConnection;
  AFatBaslikID: Integer): Boolean;
var
  LBaslik: TEBelgeMenuBaslik;
  LOwnTransaction: Boolean;
begin
  Result := False;
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;

  if GonderilmisEngeli(LBaslik.EFaturaDurum, 'Gonderilmis eBelge geri alinamaz!') then
    Exit;
  if LBaslik.EFaturaDurum = 0 then begin
    ShowMessage('Henuz eBelge olusmamis!');
    Exit;
  end;
  if not (LBaslik.EFaturaDurum in [1, 11, 51]) then begin
    ShowMessage('Bilinmeyen eFatura durumu: ' + IntToStr(LBaslik.EFaturaDurum));
    Exit;
  end;

  LOwnTransaction := not AConnection.InTransaction;
  if LOwnTransaction then
    AConnection.StartTransaction;
  try
    Veritabani.BasitKomutÇalıştır(AConnection,
      'DELETE FROM ' + DepoTablo('EBELGEKUYRUK') + ' WHERE FATBASLIKID=&ID OR EBELGEID IN ' +
      '(SELECT ID FROM ' + DepoTablo('EBELGE') + ' WHERE FATBASLIKID=&ID)',
      ['&ID'], [LBaslik.ID]);
    Veritabani.BasitKomutÇalıştır(AConnection,
      'DELETE FROM ' + DepoTablo('EBELGEMESAJ') + ' WHERE EBELGEID IN ' +
      '(SELECT ID FROM ' + DepoTablo('EBELGE') + ' WHERE FATBASLIKID=&ID)',
      ['&ID'], [LBaslik.ID]);
    Veritabani.BasitKomutÇalıştır(AConnection,
      'DELETE FROM ' + DepoTablo('EBELGE') + ' WHERE FATBASLIKID=&ID',
      ['&ID'], [LBaslik.ID]);
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE FATBASLIK SET EFATURADURUM=0, EFATURASONUC=0, FATURANO=''0'' WHERE ID=&ID',
      ['&ID'], [LBaslik.ID]);
    if LOwnTransaction then
      AConnection.Commit;
    ShowMessage('eBelge geri alindi.');
    Result := True;
  except
    on E: Exception do begin
      if LOwnTransaction and AConnection.InTransaction then
        AConnection.Rollback;
      ShowMessage('e-Belge geri alma hatasi: ' + E.Message);
    end;
  end;
end;

class function TEBelgeOlusturucu.MenuSeriDegistir(AConnection: TFDConnection;
  AFatBaslikID: Integer): Boolean;
var
  LBaslik: TEBelgeMenuBaslik;
  LYil, LBelgeTuru: Integer;
  LMevcutSeri, LYeniSeri, LYeniNo, LFatNo: string;
  LSonrakiSeq: Int64;
  LFatNoYok: Boolean;
begin
  Result := False;
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;

  LFatNo := Trim(LBaslik.FaturaNo);
  LYil := YearOf(LBaslik.FaturaTarih);
  LFatNoYok := LFatNo = '0';
  case LBaslik.EFaturaDurum of
    11, 12: LBelgeTuru := RAlias_EArsiv;
    51, 52: LBelgeTuru := RAlias_EIrsaliyeKendi;
  else
    LBelgeTuru := RAlias_EFatura;
  end;

  if not (LBaslik.Tur in [EBelgeTuruEIrsaliye, EBelgeTuruEFatura]) then begin
    ShowMessage('Bu islem yalnizca e-Fatura/e-Irsaliye belgeleri icin kullanilabilir.');
    Exit;
  end;
  if GonderilmisEngeli(LBaslik.EFaturaDurum) then
    Exit;

  if LFatNoYok then
    LMevcutSeri := IlkSeri(EBelgeSerileriYeni(AConnection, LBaslik.Tur,
      LBelgeTuru, LBaslik.Senaryo, StrToIntDef(Kullanan, 0)))
  else if Length(LFatNo) >= 3 then
    LMevcutSeri := Copy(LFatNo, 1, 3)
  else
    LMevcutSeri := Trim(LBaslik.FaturaSeri);

  if not SeriSecimi(AConnection, LBaslik.Tur, LBelgeTuru, LBaslik.Senaryo,
    StrToIntDef(Kullanan, 0), LMevcutSeri, LYeniSeri) then
    Exit;
  if not SonrakiSiraNo(LBaslik.ID, LBaslik.Tur, LYeniSeri, LYil, LSonrakiSeq) then
    Exit;

  LYeniNo := BelgeNoUret(LYeniSeri, LYil, LSonrakiSeq);

  Veritabani.BasitKomutÇalıştır(AConnection,
    'update FATBASLIK set FATURANO=&NO, FATURASERI=&SERI where ID=&ID',
    ['&NO', '&SERI', '&ID'], [LYeniNo, LYeniSeri, LBaslik.ID]);

  if LFatNoYok then
    Result := MenuHazirla(AConnection, AFatBaslikID)
  else begin
    ShowMessage('Yeni Belge No: ' + LYeniNo);
    Result := True;
  end;
end;

// Kuyruk kaydini hataya (DURUM=9) ceker, 5 dk sonraya erteler; FATBASLIK
// EFATURASONUC=3 (hata) yapilir. else/except dallarindaki ortak SQL cifti.
procedure KuyrukHataYaz(AConnection: TFDConnection; AQueueID, AFatBaslikID: Integer;
  const AHata: string);
begin
  Veritabani.BasitKomutÇalıştır(AConnection,
    'update ' + DepoTablo('EBELGEKUYRUK') + ' set DURUM=9,SON_HATA=&HATA,SONRAKI_DENEME_TARIHI='+DbTarihEkle('minute','5','getdate()')+', ' +
    'DEGISTIREN=&KUL,DEGISTIRMETARIHI=getdate() where ID=&ID',
    ['&HATA', '&KUL', '&ID'], [Copy(AHata, 1, 1000), StrToIntDef(Kullanan, 0), AQueueID]);
  Veritabani.BasitKomutÇalıştır(AConnection,
    'UPDATE FATBASLIK SET EFATURASONUC=3 WHERE ID=&ID', ['&ID'], [AFatBaslikID]);
end;

procedure MenuDosyaKaydet(AConnection: TFDConnection; AFatBaslikID: Integer;
  const ACariAd, ATurDosya: string);
var
  LBaslik: TEBelgeMenuBaslik;
  LDefaultAd, LBelgeNo: string;
  I: Integer;
  Sd: TSaveDialog;
  LGelen: Boolean;
begin
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;
  LGelen := LBaslik.Tur = 11;
  if (not LGelen) and (LBaslik.EFaturaDurum = 0) then begin
    ShowMessage('Henuz eBelge olusmamis!');
    Exit;
  end;

  // Dosya adi: <BelgeTur> <BelgeNo> <Firma ilk 2 kelime>. Belge numarasi firma
  // adinin SOLUNA eklenir; dosya adinda gecersiz karakterler temizlenir.
  LBelgeNo := Trim(LBaslik.FaturaNo);
  if LBelgeNo = '0' then
    LBelgeNo := '';
  for I := 1 to Length(LBelgeNo) do
    if Pos(LBelgeNo[I], '\/:*?"<>|') > 0 then
      LBelgeNo[I] := '_';

  LDefaultAd := BelgeTurAdi(AConnection, AFatBaslikID, LBaslik.Tur) + ' ';
  if LBelgeNo <> '' then
    LDefaultAd := LDefaultAd + LBelgeNo + ' ';
  LDefaultAd := LDefaultAd +
                IlkIkiKelime(IfThen(Trim(ACariAd) <> '', ACariAd, LBaslik.Baslik));
  Sd := TSaveDialog.Create(nil);
  try
    Sd.Title := 'eBelge ' + UpperCase(ATurDosya) + ' Kaydet';
    if SameText(ATurDosya, 'html') then
      Sd.Filter := 'HTML dosyasi (*.html)|*.html|Tum dosyalar|*.*'
    else if SameText(ATurDosya, 'xml') then
      Sd.Filter := 'XML dosyasi (*.xml)|*.xml|Tum dosyalar|*.*'
    else
      Sd.Filter := 'PDF dosyasi (*.pdf)|*.pdf|Tum dosyalar|*.*';
    Sd.DefaultExt := ATurDosya;
    Sd.FileName := LDefaultAd + '.' + ATurDosya;
    Sd.Options := Sd.Options + [ofOverwritePrompt, ofPathMustExist];
    if not Sd.Execute then
      Exit;
    try
      if SameText(ATurDosya, 'html') then begin
        if LGelen then
          TEBelgeOlusturucu.HTMLKaydetGelen(AConnection, AFatBaslikID, Sd.FileName)
        else
          TEBelgeOlusturucu.HTMLKaydet(AConnection, AFatBaslikID, Sd.FileName);
      end else if SameText(ATurDosya, 'xml') then begin
        if LGelen then
          TEBelgeOlusturucu.XMLKaydetGelen(AConnection, AFatBaslikID, Sd.FileName)
        else
          TEBelgeOlusturucu.XMLKaydet(AConnection, AFatBaslikID, Sd.FileName);
      end else begin
        if LGelen then
          TEBelgeOlusturucu.PDFKaydetGelen(AConnection, AFatBaslikID, Sd.FileName)
        else
          TEBelgeOlusturucu.PDFKaydet(AConnection, AFatBaslikID, Sd.FileName);
      end;
      ShowMessage(UpperCase(ATurDosya) + ' kaydedildi: ' + Sd.FileName);
    except
      on E: Exception do
        ShowMessage(UpperCase(ATurDosya) + ' kaydetme hatasi: ' + E.Message);
    end;
  finally
    Sd.Free;
  end;
end;

class procedure TEBelgeOlusturucu.MenuHTMLKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ACariAd: string);
begin
  MenuDosyaKaydet(AConnection, AFatBaslikID, ACariAd, 'html');
end;

class procedure TEBelgeOlusturucu.MenuXMLKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ACariAd: string);
begin
  MenuDosyaKaydet(AConnection, AFatBaslikID, ACariAd, 'xml');
end;

class procedure TEBelgeOlusturucu.MenuPDFKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ACariAd: string);
begin
  MenuDosyaKaydet(AConnection, AFatBaslikID, ACariAd, 'pdf');
end;

class procedure TEBelgeOlusturucu.KuyrukGonderimleriniIsle(
  AConnection: TFDConnection; const AFatBaslikID: Integer;
  out AGonderildi, AHata, AToplam: Integer; out AHataMesaj: string;
  const AIlerleme: TIlerlemeOlay);
var
  LQ: TFDQuery;
  LListe: TStringList;
  i, LQueueID, LFatBaslikID: Integer;
  LUser, LSifre, LURL, LYan: string;
  LTest: Boolean;
  LSQL: string;
begin
  AGonderildi := 0;
  AHata := 0;
  AToplam := 0;
  AHataMesaj := '';

  TEBelgeKimlik.Yukle(LUser, LSifre, LURL, LTest);
  if (Trim(LUser) = '') or (Trim(LSifre) = '') or (Trim(LURL) = '') then begin
    AHataMesaj := 'Kuyruk gonderimi atlandi: eBelge kullanici/sifre/URL eksik.';
    Exit;
  end;

  LListe := TStringList.Create;
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConnection;
    Veritabani.BasitKomutÇalıştır(AConnection,
      'update ' + DepoTablo('EBELGEKUYRUK') + ' set DURUM=0 ' +
      'where ISLEMTURU=1 and DURUM=1 ' +
      '  and (SON_DENEME_TARIHI is null or SON_DENEME_TARIHI<'+DbTarihEkle('minute','-5','getdate()')+')',
      [], []);

    LSQL := 'select ID,FATBASLIKID from ' + DepoTablo('EBELGEKUYRUK') + ' ' +
      'where ISLEMTURU=1 and DURUM in (0,9) ';
    if AFatBaslikID > 0 then
      LSQL := LSQL + 'and FATBASLIKID=' + IntToStr(AFatBaslikID) + ' '
    else
      LSQL := LSQL +
        'and (SONRAKI_DENEME_TARIHI is null or SONRAKI_DENEME_TARIHI<=getdate()) ';
    LSQL := LSQL + 'order by ONCELIK,ID';
    LQ.SQL.Text := LSQL;
    PgQueryCevir(LQ);
    LQ.Open;
    while not LQ.Eof do begin
      LListe.Add(LQ.FieldByName('ID').AsString + '=' + LQ.FieldByName('FATBASLIKID').AsString);
      LQ.Next;
    end;
    LQ.Close;

    AToplam := LListe.Count;
    for i := 0 to LListe.Count - 1 do begin
      LQueueID := StrToIntDef(LListe.Names[i], 0);
      LFatBaslikID := StrToIntDef(LListe.ValueFromIndex[i], 0);
      if (LQueueID <= 0) or (LFatBaslikID <= 0) then
        Continue;

      if Assigned(AIlerleme) then
        AIlerleme(i + 1, LListe.Count, 'Kuyruk gonderiliyor');

      Veritabani.BasitKomutÇalıştır(AConnection,
        'update ' + DepoTablo('EBELGEKUYRUK') + ' set DURUM=1,SON_DENEME_TARIHI=getdate(), ' +
        'DENEME_SAYISI=DENEME_SAYISI+1,DEGISTIREN=&KUL,DEGISTIRMETARIHI=getdate() where ID=&ID',
        ['&KUL', '&ID'], [StrToIntDef(Kullanan, 0), LQueueID]);
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE FATBASLIK SET EFATURASONUC=1 WHERE ID=&ID', ['&ID'], [LFatBaslikID]);

      try
        if TEBelgeOlusturucu.Gonder(AConnection, LFatBaslikID, LUser, LSifre, LURL, LTest, LYan) then begin
          Inc(AGonderildi);
          Veritabani.BasitKomutÇalıştır(AConnection,
            'delete from ' + DepoTablo('EBELGEKUYRUK') + ' where ID=&ID', ['&ID'], [LQueueID]);
        end else begin
          Inc(AHata);
          if AHataMesaj = '' then
            AHataMesaj := LYan;
          KuyrukHataYaz(AConnection, LQueueID, LFatBaslikID, LYan);
        end;
      except
        on E: Exception do begin
          Inc(AHata);
          if AHataMesaj = '' then
            AHataMesaj := E.Message;
          KuyrukHataYaz(AConnection, LQueueID, LFatBaslikID, E.Message);
        end;
      end;
    end;
  finally
    LQ.Free;
    LListe.Free;
  end;
end;

class function TEBelgeOlusturucu.MenuGonder(AConnection: TFDConnection;
  AFatBaslikID: Integer): Boolean;
var
  LBaslik: TEBelgeMenuBaslik;
  LFaturaNo, LSeri, LSeriYil, LBekleyen: string;
  LEBelgeID, LCurSeq: Int64;
  LBelgeTuru, LKGonderildi, LKHata, LKToplam: Integer;
  LKHataMesaj: string;
  LQ: TFDQuery;
begin
  Result := False;
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;
  if GonderilmisEngeli(LBaslik.EFaturaDurum) then
    Exit;
  if LBaslik.EFaturaDurum = 0 then begin
    ShowMessage('Henuz eBelge olusmamis!');
    Exit;
  end;

  LFaturaNo := Trim(LBaslik.FaturaNo);
  LSeri := Trim(LBaslik.FaturaSeri);
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConnection;
    if (Length(LFaturaNo) = 16) and (Length(LSeri) = 3) then begin
      LSeriYil := Copy(LFaturaNo, 1, 7);
      LCurSeq := StrToInt64Def(Copy(LFaturaNo, 8, 9), 0);
      if LCurSeq > 1 then begin
        LQ.SQL.Text :=
          'select '+DbUst(1)+'FATURANO from FATBASLIK where FATURASERI=' + QuotedStr(LSeri) +
          ' and TUR=' + IntToStr(LBaslik.Tur) +
          ' and EFATURADURUM in (1,11,51)';
        if AktifVeriMotor = vmPG then
          LQ.SQL.Text := LQ.SQL.Text +
            ' and length(FATURANO)=16 and left(FATURANO,7)=' + QuotedStr(LSeriYil) +
            ' and right(FATURANO,9) ~ ''^[0-9]+$''' +
            ' and cast(right(FATURANO,9) as bigint)<' + IntToStr(LCurSeq) +
            ' order by cast(right(FATURANO,9) as bigint) '+DbSinir(1)
        else
          LQ.SQL.Text := LQ.SQL.Text +
            ' and len(FATURANO)=16 and left(FATURANO,7)=' + QuotedStr(LSeriYil) +
            ' and try_convert(bigint,right(FATURANO,9)) is not null' +
            ' and try_convert(bigint,right(FATURANO,9))<' + IntToStr(LCurSeq) +
            ' order by try_convert(bigint,right(FATURANO,9)) '+DbSinir(1);
        LQ.Open;
        if not LQ.Eof then
          LBekleyen := LQ.Fields[0].AsString
        else
          LBekleyen := '';
        LQ.Close;
        if LBekleyen <> '' then begin
          ShowMessage('Sira kurali: Once daha kucuk numarali belge gonderilmelidir.' +
                      sLineBreak + 'Bekleyen: ' + LBekleyen);
          Exit;
        end;
      end;
    end;

    LQ.SQL.Text :=
      'select '+DbUst(1)+'ID,BELGETURU from ' + DepoTablo('EBELGE') + ' where FATBASLIKID=:ID and YON=1 order by ID desc '+DbSinir(1);
    PgQueryCevir(LQ);
    LQ.ParamByName('ID').AsInteger := AFatBaslikID;
    LQ.Open;
    if LQ.Eof then begin
      ShowMessage('Gonderilecek EBELGE kaydi bulunamadi. Once Hazirla menusu ile eBelge hazirlayin.');
      Exit;
    end;
    LEBelgeID := LQ.FieldByName('ID').AsLargeInt;
    LBelgeTuru := LQ.FieldByName('BELGETURU').AsInteger;
    LQ.Close;

    LQ.SQL.Text :=
      'select '+DbUst(1)+'DURUM from ' + DepoTablo('EBELGEKUYRUK') + ' where EBELGEID=:EID and ISLEMTURU=1 and DURUM in (0,1,9) '+DbSinir(1);
    PgQueryCevir(LQ);
    LQ.ParamByName('EID').AsLargeInt := LEBelgeID;
    LQ.Open;
    if LQ.Eof then begin
      Veritabani.BasitKomutÇalıştır(AConnection,
        'INSERT INTO ' + DepoTablo('EBELGEKUYRUK') + '(EBELGEID,FATBASLIKID,BELGETURU,YON,ISLEMTURU,DURUM,ONCELIK,EKLEYEN,EKLEMETARIHI) ' +
        'VALUES(&EID,&FID,&BT,1,1,0,5,&KUL,GETDATE())',
        ['&EID', '&FID', '&BT', '&KUL'], [LEBelgeID, AFatBaslikID, LBelgeTuru, StrToIntDef(Kullanan, 0)]);
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE FATBASLIK SET EFATURASONUC=6 WHERE ID=&ID',
        ['&ID'], [AFatBaslikID]);
      Veritabani.BasitKomutÇalıştır(AConnection,
        'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
        'VALUES(&EID,1,1,1,&MSG,&KUL,GETDATE())',
        ['&EID', '&MSG', '&KUL'],
        [LEBelgeID, 'Gonderim isi EBELGEKUYRUK tablosuna alindi.', StrToIntDef(Kullanan, 0)]);
    end;
    LQ.Close;
  finally
    LQ.Free;
  end;

  Screen.Cursor := crHourGlass;
  try
    KuyrukGonderimleriniIsle(AConnection, AFatBaslikID, LKGonderildi, LKHata,
      LKToplam, LKHataMesaj, nil);
  finally
    Screen.Cursor := crDefault;
  end;

  if LKGonderildi > 0 then
    ShowMessage('eBelge Izibiz''e gonderildi.')
  else if LKHata > 0 then
    ShowMessage('eBelge kuyruga alindi ancak gonderim hatasi: ' + LKHataMesaj)
  else if Trim(LKHataMesaj) <> '' then
    ShowMessage('eBelge kuyruga alindi: ' + LKHataMesaj)
  else
    ShowMessage('eBelge gonderim kuyruguna alindi.');
  Result := True;
end;

class function TEBelgeOlusturucu.GelenFaturaCevapVer(
  AConnection: TFDConnection; AFatBaslikID: Integer; AKabul: Boolean): Boolean;
var
  LBaslik: TEBelgeMenuBaslik;
  LKullanan, LHttpKodu: Integer;
  LEBelgeID: Int64;
  LUser, LSifre, LURL, LToken, LHata, LAciklama: string;
  LRedSebep, LRedEkAciklama: Variant;
  LRedListe: TStringList;
  LUUID, LAPIJSON, LIzibizID, LMesaj: string;
  LTest: Boolean;
  LQ: TFDQuery;
  LJSON: TJSONValue;
  LObj: TJSONObject;
  LVal: TJSONValue;
  LSonuc: TIzibizGonderimSonuc;
begin
  Result := False;
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;
  if LBaslik.Tur <> 11 then begin
    ShowMessage('Bu islem sadece gelen e-fatura icin kullanilir.');
    Exit;
  end;
  if LBaslik.EFaturaSonuc <> 6 then begin
    ShowMessage('Bu faturada cevap beklenmiyor.');
    Exit;
  end;

  LAciklama := '';
  if not AKabul then begin
    LRedSebep := 'Fatura tutari hatalidir.';
    LRedEkAciklama := '';
    LRedListe := TStringList.Create;
    try
      LRedListe.Add('Mal/hizmet tarafimiza ait degildir.');
      LRedListe.Add('Fatura tutari hatalidir.');
      LRedListe.Add('Birim fiyat hatalidir.');
      LRedListe.Add('KDV orani hatalidir.');
      LRedListe.Add('Siparis/irsaliye ile uyumsuzdur.');
      LRedListe.Add('Cari bilgiler hatalidir.');
      LRedListe.Add('Mukerrer fatura duzenlenmistir.');
      LRedListe.Add('Fatura tarihi/numarasi hatalidir.');
      LRedListe.Add('Urun/hizmet aciklamasi hatalidir.');
      LRedListe.Add('Ilgili teslimat gerceklesmemistir.');
      if TGirisKutusuEx.BilgiAlEx('Red Nedeni',
        TGirdiDenetimleri.Create.ComboBox('Sebep:', @LRedSebep, LRedListe, csDropDownList)
          .Memo('Ek aciklama:', @LRedEkAciklama)) <> mrOk then
        Exit;
    finally
      LRedListe.Free;
    end;
    LAciklama := Trim(VarToStr(LRedSebep));
    if Trim(VarToStr(LRedEkAciklama)) <> '' then
      LAciklama := LAciklama + ' ' + Trim(VarToStr(LRedEkAciklama));
    if LAciklama = '' then begin
      ShowMessage('Red icin sebep girilmelidir.');
      Exit;
    end;
  end;

  LEBelgeID := 0;
  LUUID := '';
  LAPIJSON := '';
  LIzibizID := '';
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConnection;
    LQ.SQL.Text :=
      'select '+DbUst(1)+'ID, UUID, cast(API_JSON as nvarchar(max)) API_JSON ' +
      'from ' + DepoTablo('EBELGE') + ' where YON=2 and FATBASLIKID=:FID order by ID desc '+DbSinir(1);
    PgQueryCevir(LQ);
    LQ.ParamByName('FID').AsInteger := AFatBaslikID;
    LQ.Open;
    if not LQ.Eof then begin
      LEBelgeID := LQ.FieldByName('ID').AsLargeInt;
      LUUID := LQ.FieldByName('UUID').AsString;
      LAPIJSON := LQ.FieldByName('API_JSON').AsString;
    end;
  finally
    LQ.Free;
  end;
  if LEBelgeID <= 0 then begin
    ShowMessage('Bu gelen fatura icin EBELGE kaydi bulunamadi.');
    Exit;
  end;

  LJSON := TJSONObject.ParseJSONValue(LAPIJSON);
  try
    if LJSON is TJSONObject then begin
      LObj := TJSONObject(LJSON);
      LVal := LObj.GetValue('id');
      if LVal <> nil then
        LIzibizID := LVal.Value;
      if LIzibizID = '' then begin
        LVal := LObj.GetValue('documentId');
        if LVal <> nil then
          LIzibizID := LVal.Value;
      end;
      if LIzibizID = '' then begin
        LVal := LObj.GetValue('documentID');
        if LVal <> nil then
          LIzibizID := LVal.Value;
      end;
    end;
  finally
    if LJSON <> nil then
      LJSON.Free;
  end;
  if LIzibizID = '' then
    LIzibizID := LUUID;

  TEBelgeKimlik.Yukle(LUser, LSifre, LURL, LTest);
  if (Trim(LUser) = '') or (Trim(LSifre) = '') or (Trim(LURL) = '') then begin
    ShowMessage('eBelge kullanici/sifre/URL eksik.');
    Exit;
  end;

  LToken := TEBelgeKimlik.TokenAl;
  if LToken = '' then begin
    if not TIzibizRest.Login(LURL, LUser, LSifre,
      Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EBelgeVergiNo, ''),
      KURUMADI, LToken, LHata) then begin
      Veritabani.BasitKomutÇalıştır(AConnection,
        'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
        'VALUES(&EID,2,3,9,&MSG,&KUL,GETDATE())',
        ['&EID','&MSG','&KUL'],
        [LEBelgeID, 'Cevap login hatasi: ' + Copy(LHata, 1, 3500), StrToIntDef(Kullanan, 0)]);
      ShowMessage('Izibiz login basarisiz: ' + LHata);
      Exit;
    end;
    TEBelgeKimlik.TokenSet(LToken);
  end;

  LKullanan := StrToIntDef(Kullanan, 0);
  Screen.Cursor := crHourGlass;
  try
    if TIzibizRest.InboxResponse(LURL, LToken, LIzibizID, LUUID, LAciklama, AKabul, LSonuc) then begin
      if AKabul then
        LMesaj := 'Gelen fatura kabul edildi.'
      else
        LMesaj := 'Gelen fatura red edildi.';

      Veritabani.BasitKomutÇalıştır(AConnection,
        'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,HTTPKODU,SERVISKODU,EKLEYEN,EKLEMETARIHI) ' +
        'VALUES(&EID,2,3,2,&MSG,&HK,&SRV,&KUL,GETDATE())',
        ['&EID','&MSG','&HK','&SRV','&KUL'],
        [LEBelgeID, LMesaj + ' ' + Copy(LSonuc.YanitJSON, 1, 2500),
         LSonuc.HttpKodu, 'IZIBIZ', LKullanan]);
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE ' + DepoTablo('EBELGE') + ' SET DURUM=&D, DEGISTIREN=&KUL, DEGISTIRMETARIHI=GETDATE() WHERE ID=&EID',
        ['&D','&KUL','&EID'], [2 + Ord(not AKabul), LKullanan, LEBelgeID]);
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE FATBASLIK SET EFATURASONUC=&S WHERE ID=&ID',
        ['&S','&ID'], [2 + Ord(not AKabul), AFatBaslikID]);
      ShowMessage(LMesaj);
      Result := True;
    end else begin
      LHttpKodu := LSonuc.HttpKodu;
      Veritabani.BasitKomutÇalıştır(AConnection,
        'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,HTTPKODU,SERVISKODU,HATAMESAJI,EKLEYEN,EKLEMETARIHI) ' +
        'VALUES(&EID,2,3,9,&MSG,&HK,&SRV,&HATA,&KUL,GETDATE())',
        ['&EID','&MSG','&HK','&SRV','&HATA','&KUL'],
        [LEBelgeID, 'Izibiz cevap gonderilemedi.', LHttpKodu, 'IZIBIZ',
         Copy(LSonuc.Mesaj, 1, 3500), LKullanan]);
      ShowMessage('Izibiz cevap gonderilemedi: ' + LSonuc.Mesaj);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

class function TEBelgeOlusturucu.Olustur(AConnection: TFDConnection;
  AFatBaslikID: Integer; const AAliciAlias: string;
  ABelgeTuruOverride: Integer = 0): Int64;
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LUBLXML, LAPIJSON: string;
  LKullanan: Integer;
  LOwnTransaction: Boolean;
  LSevk: TSevkBilgisi;
  LSevkHata: string;
begin
  VerileriOku(AFatBaslikID, LBaslik, LSatirlar);
  if Trim(LBaslik.FaturaNo) = '' then
    raise Exception.Create('Belge numarasi bulunamadi.');
  if Length(LSatirlar) = 0 then
    raise Exception.Create('Belge detayi bulunamadi.');

  // ABelgeTuruOverride = RAlias kodu (140/141/150/151).
  // FATBASLIK.TUR (14/15) degismez ? uygulamadaki belge tipi kodu olarak kalir.
  // EBELGE.BELGETURU bu RAlias kodu olarak saklanir.
  if ABelgeTuruOverride > 0 then begin
    LBaslik.EBelgeBelgeTuru := ABelgeTuruOverride;
    LBaslik.EArsivMi := ABelgeTuruOverride = RAlias_EArsiv;
  end;
  if LBaslik.EBelgeBelgeTuru = 0 then begin
    // Olusturucu cagrildi ama override gelmedi ? FATBASLIK.TUR'a gore varsayilan
    if LBaslik.Tur = EBelgeTuruEIrsaliye then
      LBaslik.EBelgeBelgeTuru := RAlias_EIrsaliyeKendi
    else
      LBaslik.EBelgeBelgeTuru := RAlias_EFatura;
  end;
  if Trim(AAliciAlias) <> '' then
    LBaslik.AliciAlias := AAliciAlias;
  if Trim(LBaslik.GondericiAlias) = '' then
    LBaslik.GondericiAlias := GondericiAliasGetir(LBaslik.Tur);
  if Trim(LBaslik.UUID) = '' then
    LBaslik.UUID := YeniUUID;

  LUBLXML := GidenUBLXMLUret(LBaslik, LSatirlar);
  LAPIJSON := APIJSONUret(LBaslik, LUBLXML);
  LKullanan := StrToIntDef(Kullanan, 0);

  LOwnTransaction := not AConnection.InTransaction;
  if LOwnTransaction then
    AConnection.StartTransaction;
  try
    if LBaslik.EBelgeID > 0 then begin
      EBelgeGuncelle(AConnection, LBaslik, LAPIJSON, LUBLXML, LKullanan);
      Result := LBaslik.EBelgeID;
    end else
      Result := EBelgeEkle(AConnection, LBaslik, LAPIJSON, LUBLXML,
        LKullanan);
    if Result = 0 then
      raise Exception.Create('EBELGE kayit ID bilgisi alinamadi.');

    Veritabani.BasitKomutÇalıştır(AConnection,
      'insert into ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,' +
      'EKLEYEN) values(~P1~,1,1,1,~P2~,~P3~)',
      ['~P1~', '~P2~', '~P3~'],
      [Result, 'UBL/XML ve Izibiz kuyruk JSON bilgisi olusturuldu.',
       LKullanan]);

    if LOwnTransaction then
      AConnection.Commit;
  except
    if LOwnTransaction and AConnection.InTransaction then
      AConnection.Rollback;
    raise;
  end;
end;

class procedure TEBelgeOlusturucu.Onizle(AConnection: TFDConnection;
  AFatBaslikID: Integer);
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LDosya, LHTML, LUBLXML: string;
  LSonuc: HINST;
begin
  OlusturulmusGidenBelgeOku(AFatBaslikID, 'Onizleme', LBaslik, LSatirlar);
  if Trim(LBaslik.UUID) = '' then
    raise Exception.Create('Olusturulmus e-belgenin UUID bilgisi bulunamadi.');

  LUBLXML := GidenUBLXMLUret(LBaslik, LSatirlar);
  LHTML := GidenHTMLUret(LBaslik, LSatirlar, LUBLXML, False);
  LDosya := TPath.Combine(TPath.GetTempPath,
    'Gentegre_EBelge_' + IntToStr(AFatBaslikID) + '_' +
    FormatDateTime('yyyymmddhhnnsszzz', Now) + '.html');
  TFile.WriteAllText(LDosya, LHTML, TEncoding.UTF8);
  LSonuc := ShellExecute(0, 'open', PChar(LDosya), nil, nil, SW_SHOWNORMAL);
  if LSonuc <= 32 then
    raise Exception.Create('E-belge onizleme dosyasi acilamadi.');
end;


class procedure TEBelgeOlusturucu.XMLKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LUBLXML: string;
begin
  OlusturulmusGidenBelgeOku(AFatBaslikID, 'XML', LBaslik, LSatirlar);

  LUBLXML := GidenUBLXMLUret(LBaslik, LSatirlar);

  TFile.WriteAllText(ADosya, LUBLXML, TEncoding.UTF8);
end;

class procedure TEBelgeOlusturucu.HTMLKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
// ?nizle ile ayn? HTML ?retimi � ama belirtilen dosyaya kaydeder, a?maz.
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LHTML, LUBLXML: string;
begin
  OlusturulmusGidenBelgeOku(AFatBaslikID, 'HTML', LBaslik, LSatirlar);

  LUBLXML := GidenUBLXMLUret(LBaslik, LSatirlar);
  LHTML := GidenHTMLUret(LBaslik, LSatirlar, LUBLXML, True);

  TFile.WriteAllText(ADosya, LHTML, TEncoding.UTF8);
end;

class procedure TEBelgeOlusturucu.PDFKaydet(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
// HTML ?retilip ge?ici dosyaya yaz?l?r � headless Edge ile PDF'e d?n??t?r?l?r.
// Edge Windows 10+'da varsay?lan olarak y?kl?; bulunamazsa Chrome denenir.
var
  LTempHTML: string;
begin
  LTempHTML := TPath.Combine(TPath.GetTempPath,
    'Gentegre_EBelge_PDF_' + IntToStr(AFatBaslikID) + '.html');
  HTMLKaydet(AConnection, AFatBaslikID, LTempHTML);
  HTMLDosyaPDFeCevir(LTempHTML, ADosya);
end;

// ---- Izibiz JSON body uretici (sadelestirilmis) ----
// Ihracat e-Faturasi muhasebe alicisi (customerParty) = Gumruk. GIB kurali:
// ProfileID=IHRACAT iken customerParty Gumruk ve Ticaret Bakanligi (VKN 1460415308);
// gercek yurt disi alici buyerCustomerParty (PARTYTYPE=EXPORT) olarak yazilir.
function GumrukCustomerPartyOlustur: TJSONObject;
var
  LAdr: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('schemeId', 'VKN');
  Result.AddPair('identifier', '1460415308');
  Result.AddPair('name',
    'Gümrük ve Ticaret Bakanlığı Gümrükler Genel Müdürlüğü- Bilgi İşlem Dairesi Başkanlığı');
  Result.AddPair('taxOffice', 'ULUS');
  LAdr := TJSONObject.Create;
  LAdr.AddPair('city', 'ANKARA');
  LAdr.AddPair('country', 'TÜRKİYE');
  Result.AddPair('address', LAdr);
end;

function GumrukPartyXML(const ARol: string): string;
var
  LXML: TStringBuilder;
begin
  LXML := TStringBuilder.Create;
  try
    LXML.AppendLine('<cac:' + ARol + '>');
    LXML.AppendLine('<cac:Party>');
    LXML.AppendLine('<cac:PartyIdentification><cbc:ID schemeID="VKN">1460415308</cbc:ID></cac:PartyIdentification>');
    LXML.AppendLine('<cac:PartyName><cbc:Name>Gümrük ve Ticaret Bakanlığı Gümrükler Genel Müdürlüğü- Bilgi İşlem Dairesi Başkanlığı</cbc:Name></cac:PartyName>');
    LXML.AppendLine('<cac:PostalAddress>');
    LXML.AppendLine('<cbc:CityName>ANKARA</cbc:CityName>');
    LXML.AppendLine('<cac:Country><cbc:Name>TÜRKİYE</cbc:Name></cac:Country>');
    LXML.AppendLine('</cac:PostalAddress>');
    LXML.AppendLine('<cac:PartyTaxScheme><cac:TaxScheme><cbc:Name>ULUS</cbc:Name></cac:TaxScheme></cac:PartyTaxScheme>');
    LXML.AppendLine('<cac:PartyLegalEntity><cbc:RegistrationName>Gümrük ve Ticaret Bakanlığı Gümrükler Genel Müdürlüğü- Bilgi İşlem Dairesi Başkanlığı</cbc:RegistrationName></cac:PartyLegalEntity>');
    LXML.AppendLine('</cac:Party>');
    LXML.AppendLine('</cac:' + ARol + '>');
    Result := LXML.ToString;
  finally
    LXML.Free;
  end;
end;

function IhracatSatirDeliveryXML(const ABaslik: TEBelgeBaslik;
  const ASatir: TEBelgeSatir): string;
var
  LXML: TStringBuilder;
begin
  LXML := TStringBuilder.Create;
  try
    LXML.AppendLine('<cac:Delivery>');
    LXML.AppendLine('<cac:DeliveryAddress>');
    if Trim(ABaslik.Adres) <> '' then
      LXML.AppendLine('<cbc:StreetName>' + XMLEscape(ABaslik.Adres) + '</cbc:StreetName>');
    if Trim(ABaslik.Ilce) <> '' then
      LXML.AppendLine('<cbc:CitySubdivisionName>' + XMLEscape(ABaslik.Ilce) + '</cbc:CitySubdivisionName>');
    if Trim(ABaslik.Il) <> '' then
      LXML.AppendLine('<cbc:CityName>' + XMLEscape(ABaslik.Il) + '</cbc:CityName>');
    LXML.AppendLine('<cac:Country><cbc:Name>TR</cbc:Name></cac:Country>');
    LXML.AppendLine('</cac:DeliveryAddress>');
    if Trim(ABaslik.TeslimSartiKodu) <> '' then begin
      LXML.AppendLine('<cac:DeliveryTerms>');
      LXML.AppendLine('<cbc:ID schemeID="INCOTERMS">' + XMLEscape(ABaslik.TeslimSartiKodu) + '</cbc:ID>');
      LXML.AppendLine('</cac:DeliveryTerms>');
    end;
    LXML.AppendLine('<cac:Shipment>');
    LXML.AppendLine('<cbc:ID>' + IntToStr(ASatir.SatirNo) + '</cbc:ID>');
    if ABaslik.FOBDeger > 0 then
      LXML.AppendLine('<cbc:FreeOnBoardValueAmount currencyID="' + XMLEscape(ABaslik.ParaBirimi) + '">' +
        Ondalik(ABaslik.FOBDeger, '0.00##') + '</cbc:FreeOnBoardValueAmount>');
    if Trim(ASatir.GTIP) <> '' then begin
      LXML.AppendLine('<cac:GoodsItem>');
      LXML.AppendLine('<cbc:RequiredCustomsID>' + XMLEscape(Trim(ASatir.GTIP)) + '</cbc:RequiredCustomsID>');
      LXML.AppendLine('</cac:GoodsItem>');
    end;
    if Trim(ABaslik.TasimaSekliKodu) <> '' then begin
      LXML.AppendLine('<cac:ShipmentStage>');
      LXML.AppendLine('<cbc:TransportModeCode>' + XMLEscape(ABaslik.TasimaSekliKodu) + '</cbc:TransportModeCode>');
      LXML.AppendLine('</cac:ShipmentStage>');
    end;
    if Trim(ABaslik.KapCinsiKodu) <> '' then begin
      LXML.AppendLine('<cac:TransportHandlingUnit>');
      LXML.AppendLine('<cac:ActualPackage>');
      LXML.AppendLine('<cbc:ID>' + IntToStr(ASatir.SatirNo) + '</cbc:ID>');
      if ABaslik.KapAdedi > 0 then
        LXML.AppendLine('<cbc:Quantity>' + IntToStr(ABaslik.KapAdedi) + '</cbc:Quantity>');
      LXML.AppendLine('<cbc:PackagingTypeCode>' + XMLEscape(ABaslik.KapCinsiKodu) + '</cbc:PackagingTypeCode>');
      LXML.AppendLine('</cac:ActualPackage>');
      LXML.AppendLine('</cac:TransportHandlingUnit>');
    end;
    LXML.AppendLine('</cac:Shipment>');
    LXML.AppendLine('</cac:Delivery>');
    Result := LXML.ToString;
  finally
    LXML.Free;
  end;
end;

// Ihracat satir duzeyi delivery JSON'u (izibiz IHRACAT ornegi): deliveryAddress +
// deliveryTerms(INCOTERMS) + shipment(FOB, GTIP, tasima modu, kap). Baslik alanlari
// 'İhracat' sablonundan (IhracatBilgisiOku okur), GTIP satirdan gelir.
function IhracatSatirDeliveryOlustur(const ABaslik: TEBelgeBaslik;
  const ASatir: TEBelgeSatir): TJSONObject;
var
  LDelAdr, LTerms, LShip, LGood, LStage, LThu, LPkg: TJSONObject;
  LGoodsArr, LStagesArr, LThuArr: TJSONArray;
begin
  Result := TJSONObject.Create;
  // GIB schematron: IHRACAT'ta en az bir satirda Delivery/DeliveryAddress olmali.
  LDelAdr := TJSONObject.Create;
  if Trim(ABaslik.Il) <> '' then
    LDelAdr.AddPair('city', ABaslik.Il);
  if Trim(ABaslik.Ilce) <> '' then
    LDelAdr.AddPair('subCity', ABaslik.Ilce);
  if Trim(ABaslik.Adres) <> '' then
    LDelAdr.AddPair('streetName', ABaslik.Adres);
  LDelAdr.AddPair('country', 'TR');
  Result.AddPair('deliveryAddress', LDelAdr);
  if ABaslik.TeslimSartiKodu <> '' then begin
    LTerms := TJSONObject.Create;
    LTerms.AddPair('schemeID', 'INCOTERMS');
    LTerms.AddPair('id', ABaslik.TeslimSartiKodu);
    Result.AddPair('deliveryTerms', LTerms);
  end;
  LShip := TJSONObject.Create;
  if ABaslik.FOBDeger > 0 then
    LShip.AddPair('freeOnBoardValueAmount', Ondalik(ABaslik.FOBDeger, '0.00##'));
  if Trim(ASatir.GTIP) <> '' then begin
    LGoodsArr := TJSONArray.Create;
    LGood := TJSONObject.Create;
    LGood.AddPair('requiredCustomsID', Trim(ASatir.GTIP));  // GTIP - string (bastaki 0 korunur)
    LGoodsArr.AddElement(LGood);
    LShip.AddPair('goodsItems', LGoodsArr);
  end;
  if ABaslik.TasimaSekliKodu <> '' then begin
    LStagesArr := TJSONArray.Create;
    LStage := TJSONObject.Create;
    LStage.AddPair('transportModeCode',
      TJSONNumber.Create(StrToIntDef(ABaslik.TasimaSekliKodu, 0)));
    LStagesArr.AddElement(LStage);
    LShip.AddPair('shipmentStages', LStagesArr);
  end;
  if ABaslik.KapCinsiKodu <> '' then begin
    LThuArr := TJSONArray.Create;
    LThu := TJSONObject.Create;
    LPkg := TJSONObject.Create;
    LPkg.AddPair('id', IntToStr(ASatir.SatirNo));
    if ABaslik.KapAdedi > 0 then
      LPkg.AddPair('quantity', IntToStr(ABaslik.KapAdedi));
    LPkg.AddPair('packagingTypeCode', ABaslik.KapCinsiKodu);
    LThu.AddPair('actualPackage', LPkg);
    LThuArr.AddElement(LThu);
    LShip.AddPair('transportHandlingUnits', LThuArr);
  end;
  Result.AddPair('shipment', LShip);
end;

// Tevkifat withholding taxSubTotal JSON ogesi (header + satir ORTAK yapisi):
// taxableAmount/taxAmount/calculationSequenceNumeric/percent(integer)/taxScheme.
// AMatrah=KDV tutari (net degil), AOran=tevkifat orani (%). izibiz: percent integer.
function TevkifatSubOlustur(AMatrah, ATevkifat: Currency; AOran: Double;
  const ABaslik: TEBelgeBaslik): TJSONObject;
var
  LScheme: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('taxableAmount', TJSONNumber.Create(AMatrah));
  Result.AddPair('taxAmount', TJSONNumber.Create(ATevkifat));
  Result.AddPair('calculationSequenceNumeric', TJSONNumber.Create(1));
  Result.AddPair('percent', TJSONNumber.Create(Round(AOran)));   // integer (izibiz "50.0" degil "50")
  LScheme := TJSONObject.Create;
  LScheme.AddPair('name', TevkifatNedeni(ABaslik));
  LScheme.AddPair('typeCode', TevkifatKodu(ABaslik));
  Result.AddPair('taxScheme', LScheme);
end;

function _IzibizJSONOlustur(const ABaslik: TEBelgeBaslik;
  const ASatirlar: TEBelgeSatirlar;
  const AGondericiTaraf: TEBelgeTaraf): string;
var
  LRoot, LContent, LSupplier, LSupplierAdr, LCustomer, LTax, LTaxSub, LTaxScheme,
    LMonetary, LLine, LLineTax, LLineTaxSub, LLineTaxScheme,
    LWithholdingTax, LWithholdingSub: TJSONObject;
  LNotes, LLines, LTaxSubArr, LLineTaxSubArr, LAddRefs,
    LWithholdingSubArr: TJSONArray;
  LAddRefSend: TJSONObject;
  i, J, LBosluk: Integer;
  LToplamMatrah, LToplamKDV, LToplamTevkifat, LGrupMatrah, LGrupVergi,
    LGrupTevkifat, LSatirVergi, LSatirTevkifat: Currency;
  LSatir: TEBelgeSatir;
  LIsArsiv, LIsIrsaliye, LTevkifatVar, LOranIslendi: Boolean;
  LAd, LSoyad, LProfil, LCustSeli, LTrimmed, LDocTypeCode: string;
  LSabitNotlar: TArray<string>;
  LSevk: TSevkBilgisi;
  LTasiyici: TEBelgeTaraf;
begin
  LIsIrsaliye := ABaslik.Tur = EBelgeTuruEIrsaliye;
  LIsArsiv := ABaslik.EArsivMi;
  LAddRefs := nil;
  if LIsIrsaliye then begin
    LDocTypeCode := 'SEVK';
  end else begin
    LDocTypeCode := FaturaTipKodu(ABaslik);
  end;
  LProfil := SenaryoProfilKodu(ABaslik);
  // Ihracat faturasi: izibiz IHRACAT ornegi profile=IHRACAT + documentTypeCode=ISTISNA kullanir
  // (belge tipi ISTISNA, senaryo/profil IHRACAT). Belge tipi zaten ISTISNA degilse ISTISNA'ya cek.
  if (LProfil = 'IHRACAT') and (LDocTypeCode <> 'ISTISNA') then
    LDocTypeCode := 'ISTISNA';
  LTevkifatVar := (not LIsIrsaliye) and
    ((ABaslik.Tipi = 22) or SatirlardaTevkifatVar(ASatirlar));
  if LTevkifatVar then
    TevkifatNedeniKontrolEt(ABaslik, ASatirlar);
  if not LIsIrsaliye then
    TamIskontoNedeniKontrolEt(ABaslik, ASatirlar);

  LSevk := Default(TSevkBilgisi);
  LTasiyici := Default(TEBelgeTaraf);
  if LIsIrsaliye then begin
    LSevk := SevkBilgisiGetir(ABaslik.ID);
    LTasiyici := SevkTasiyiciTaraf(LSevk, AGondericiTaraf);
  end;
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair('documentAction', 'SEND');
    // EArsiv: alici e-postasina iletim izibiz REST'te mailFlag+mailAdress ile TETIKLENIR
    // (documentAction:SEND altinda; customerParty.address.email/SendingType tek basina
    // posta gondermiyor). E-posta = AliciAlias (e-arsiv'de mail adresi), yoksa cari REHBER.
    if LIsArsiv then begin
      var LArsivMail: string := Trim(ABaslik.AliciAlias);
      if LArsivMail = '' then begin
        var LArsivTel: string := '';
        AliciIletisimGetir(ABaslik.RehberID, LArsivMail, LArsivTel);
      end;
      if LArsivMail <> '' then begin
        LRoot.AddPair('mailFlag', TJSONBool.Create(True));
        var LMailArr: TJSONArray := TJSONArray.Create;
        // Birden fazla e-posta (; , veya satir ile ayrilmis) -> her biri ayri element.
        for var LM in LArsivMail.Split([';', ',', #13, #10]) do
          if Trim(LM) <> '' then
            LMailArr.Add(Trim(LM));
        if LMailArr.Count = 0 then
          LMailArr.Add(Trim(LArsivMail));
        LRoot.AddPair('mailAdress', LMailArr);
      end;
    end;
    // Postman ornegine gore string "true"/"false" gonderiliyor (bool degil)
    LRoot.AddPair('assignNumber',
                  IfThen(Trim(ABaslik.FaturaNo) = '', 'true', 'false'));
    LRoot.AddPair('seriePrefix', Copy(ABaslik.FaturaNo, 1, 3));
    if LIsIrsaliye then
      LRoot.AddPair('compressed', 'false');  // irsaliye base64 olarak parse edilmesin

    // ALICI POSTA KUTUSU (alias): RECEIVER_ALIAS request'te GONDERILMEZSE Izibiz ilk
    // buldugu URN:MAIL etiketine yollar -> coklu subeli/aliasli mukellefte YANLIS
    // kutuya gidiyor (izibiz teyidi). Secili alias'i (EBELGE.ALICIALIAS) request'e ekle.
    // IHRACAT: alici Gumruk oldugu icin gercek alicinin alias'i GONDERILMEZ (yurt disi
    // alici GIB kullanicisi degil -> RECEIVER_COULD_NOT_FOUND). Izibiz customerParty
    // (Gumruk VKN 1460415308) uzerinden otomatik yonlendirir.
    if (LProfil <> 'IHRACAT') and (Trim(ABaslik.AliciAlias) <> '') then
      LRoot.AddPair('receiverAlias', ABaslik.AliciAlias);
    if Trim(ABaslik.GondericiAlias) <> '' then
      LRoot.AddPair('senderAlias', ABaslik.GondericiAlias);

    LContent := TJSONObject.Create;
    LContent.AddPair('profile', LProfil);
    LContent.AddPair('documentTypeCode', LDocTypeCode);
    if Trim(ABaslik.FaturaNo) <> '' then
      LContent.AddPair('documentNo', ABaslik.FaturaNo);
    if Trim(ABaslik.UUID) <> '' then
      LContent.AddPair('uuid', ABaslik.UUID)
    else
      LContent.AddPair('uuid', YeniUUID);
    LContent.AddPair('issueDate', FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
    LContent.AddPair('issueTime', FormatDateTime('hh:nn:ss', ABaslik.Tarih));
    LNotes := TJSONArray.Create;
    LContent.AddPair('notes', LNotes);
    // Dipnotlar: belge tipine gore tanimli sabit notlar (yer tutuculari islenmis)
    // GIB'e gonderilen belgeye de eklenir.
    LSabitNotlar := SabitNotlariGetir(ABaslik);
    for i := 0 to High(LSabitNotlar) do
      LNotes.Add(LSabitNotlar[i]);
    LTrimmed := KDVIstisnaNotu(ABaslik);
    if LTrimmed <> '' then
      LNotes.Add(LTrimmed);
    LTrimmed := TevkifatNotu(ABaslik, ASatirlar);   // tevkifatli faturada dip nota tevkifat aciklamasi
    if LTrimmed <> '' then
      LNotes.Add(LTrimmed);
    LContent.AddPair('currencyCode', IfThen(Trim(ABaslik.ParaBirimi) = '', 'TRY', ABaslik.ParaBirimi));

    // Supplier (gonderici = bizim firma)
    LSupplier := TJSONObject.Create;
    LSupplier.AddPair('name', AGondericiTaraf.Unvan);
    LSupplier.AddPair('identifier', AGondericiTaraf.VergiNo);
    LSupplier.AddPair('schemeId', KimlikSemasi(AGondericiTaraf.VergiNo));
    if Trim(AGondericiTaraf.VergiDairesi) <> '' then
      LSupplier.AddPair('taxOffice', AGondericiTaraf.VergiDairesi);
    LSupplierAdr := TJSONObject.Create;
    LSupplierAdr.AddPair('country', 'TR');
    if Trim(AGondericiTaraf.Il) <> '' then
      LSupplierAdr.AddPair('city', AGondericiTaraf.Il);
    if Trim(AGondericiTaraf.Ilce) <> '' then
      LSupplierAdr.AddPair('subCity', AGondericiTaraf.Ilce);
    if Trim(AGondericiTaraf.Adres) <> '' then
      LSupplierAdr.AddPair('streetName', AGondericiTaraf.Adres);
    if Trim(AGondericiTaraf.PostaKodu) <> '' then
      LSupplierAdr.AddPair('postalCode', AGondericiTaraf.PostaKodu);
    // Gonderici iletisim: izibiz adres objesi 'email' alanini destekliyor (musteri tarafinda
    // LCustomerAdr'da kullaniliyor). telephone/webSite izibiz'de kabul edilmezse yok sayilir.
    if Trim(AGondericiTaraf.EPosta) <> '' then
      LSupplierAdr.AddPair('email', AGondericiTaraf.EPosta);
    if Trim(AGondericiTaraf.Telefon) <> '' then
      LSupplierAdr.AddPair('telephone', AGondericiTaraf.Telefon);
    if Trim(AGondericiTaraf.Web) <> '' then
      LSupplierAdr.AddPair('webSite', AGondericiTaraf.Web);
    LSupplier.AddPair('address', LSupplierAdr);
    // MERSIS / Ticaret Sicil No -> izibiz 'identifications' dizisi (scheme/value).
    // Yerel UBL bunlari <cac:PartyIdentification> olarak yaziyordu; izibiz JSON'una
    // da eklenir ki izibiz'in urettigi UBL'de de gozuksun.
    if (Trim(AGondericiTaraf.MersisNo) <> '') or (Trim(AGondericiTaraf.TicaretSicilNo) <> '') then
    begin
      var LSupIds: TJSONArray := TJSONArray.Create;
      if Trim(AGondericiTaraf.MersisNo) <> '' then
      begin
        var LMersis: TJSONObject := TJSONObject.Create;
        LMersis.AddPair('scheme', 'MERSISNO');
        LMersis.AddPair('value', Trim(AGondericiTaraf.MersisNo));
        LSupIds.AddElement(LMersis);
      end;
      if Trim(AGondericiTaraf.TicaretSicilNo) <> '' then
      begin
        var LSicil: TJSONObject := TJSONObject.Create;
        LSicil.AddPair('scheme', 'TICARETSICILNO');
        LSicil.AddPair('value', Trim(AGondericiTaraf.TicaretSicilNo));
        LSupIds.AddElement(LSicil);
      end;
      LSupplier.AddPair('identifications', LSupIds);
    end;
    LContent.AddPair('supplierParty', LSupplier);

    // Iade (Tipi=2): iade edilen orijinal belge referans(lar)i. izibiz JSON-native:
    //   e-Fatura   -> "billingReference":[{id,issueDate,documentTypeCode:IADE,documentType}]
    //   e-Irsaliye -> "despatchDocumentReference":[{...}]
    // GIB schematron 10003 bu elemani 16-hane ID + documentTypeCode=IADE ile ZORUNLU tutar;
    // JSON'da yoksa izibiz UBL'i referanssiz kurar -> "10003" reddi. (UBLXMLUret'teki
    // cac:BillingReference yalnizca base64-UBL gonderiminde islerdi; asil gonderim buradan.)
    if (ABaslik.Tipi = 2) and (Length(ABaslik.IadeReferanslari) > 0) then begin
      var LIadeRefArr: TJSONArray := TJSONArray.Create;
      for J := 0 to High(ABaslik.IadeReferanslari) do begin
        var LIadeRef: TJSONObject := TJSONObject.Create;
        LIadeRef.AddPair('id', ABaslik.IadeReferanslari[J].FaturaNo);
        LIadeRef.AddPair('issueDate',
          FormatDateTime('yyyy-mm-dd', ABaslik.IadeReferanslari[J].Tarih));
        LIadeRef.AddPair('documentTypeCode', 'IADE');
        LIadeRef.AddPair('documentType',
          IfThen(LIsIrsaliye, 'İade Edilen İrsaliye', 'İade Edilen Fatura'));
        LIadeRefArr.AddElement(LIadeRef);
      end;
      if LIsIrsaliye then
        LContent.AddPair('despatchDocumentReference', LIadeRefArr)
      else
        LContent.AddPair('billingReference', LIadeRefArr);
    end;

    // EArsiv'e ozel: additionalReferences -> SendingType. Alici e-postasi (AliciAlias =
    // REHBERALIAS 150) varsa ELEKTRONIK gonder -> izibiz e-postayi yollar (SOAP'taki
    // EARSIV_EMAIL_FLAG=Y karsiligi). E-posta yoksa KAGIT. Email adresi asagida
    // customerParty.address.email'e yazilir (EARSIV_EMAIL karsiligi).
    if LIsArsiv then begin
      LAddRefs := TJSONArray.Create;
      LAddRefSend := TJSONObject.Create;
      LAddRefSend.AddPair('documentTypeCode', 'SendingType');
      LAddRefSend.AddPair('documentType',
        IfThen(Trim(ABaslik.AliciAlias) <> '', 'ELEKTRONIK', 'KAGIT'));
      LAddRefSend.AddPair('id', '1');
      LAddRefSend.AddPair('issueDate',
                          FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
      LAddRefs.AddElement(LAddRefSend);
      LContent.AddPair('additionalReferences', LAddRefs);
    end;

    // Goruntuleme sablonunu belge icerigine GOMER (additionalReferences,
    // documentType=XSLT) - tum turler icin. Kayitli 'DEFAULT' sabloruna BAGIMLI
    // DEGIL; saglam yol. NOT: Bir ara xsltName="DEFAULT"'a gecilmisti ama uretim
    // hesabinda "DEFAULT" kayitli sablon olmadigindan RESOURCE / "imza bilgisi
    // bulunamadi" hatasi verdi. Eskiden XSLT sandigimiz "unique result: 2" ise
    // XSLT'den degil MUKERRER SERI'den geliyordu (documentType=XSLT ile iki
    // referans tipli oldugundan belirsizlik de kalmaz).
    begin
      var LXSLT: string := '';
      if LIsArsiv then
        OrnekEArsivXSLTGetir(LXSLT);
      if (Trim(LXSLT) <> '') or
        BelgeXSLTGetir(ABaslik.RehberID, ABaslik.Tur, ABaslik.EArsivMi, False, LXSLT) then begin
        var LXSLTHata: string := '';
        if not XSLTGecerliMi(LXSLT, LXSLTHata) then
          raise Exception.Create('Gonderilecek XSLT sablonu gecersiz: ' + LXSLTHata);
        var LXSLTDosyaAdi := Trim(ABaslik.FaturaNo);
        if LXSLTDosyaAdi = '' then
          LXSLTDosyaAdi := ABaslik.UUID;
        LXSLTDosyaAdi := LXSLTDosyaAdi + '.xslt';
        var LAddXslt: TJSONObject := TJSONObject.Create;
        LAddXslt.AddPair('id', ABaslik.UUID);
        LAddXslt.AddPair('documentType', 'XSLT');
        LAddXslt.AddPair('issueDate',
                         FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
        var LAttach: TJSONObject := TJSONObject.Create;
        LAttach.AddPair('characterSetCode', 'UTF-8');
        LAttach.AddPair('encodingCode', 'Base64');
        LAttach.AddPair('filename', LXSLTDosyaAdi);
        LAttach.AddPair('mimeCode', 'application/xml');
        LAttach.AddPair('content', Base64TekSatir(TEncoding.UTF8.GetBytes(LXSLT)));
        LAddXslt.AddPair('attachment', LAttach);
        if LAddRefs = nil then
          LAddRefs := TJSONArray.Create;
        LAddRefs.AddElement(LAddXslt);
        if LContent.GetValue('additionalReferences') = nil then
          LContent.AddPair('additionalReferences', LAddRefs);
      end else
        raise Exception.Create('Gonderim icin XSLT sablonu bulunamadi.');
    end;

    // Customer (alici)
    LCustomer := TJSONObject.Create;
    LCustSeli := KimlikSemasi(ABaslik.VergiNo);
    // EIrsaliye'de de schemeId aciktan yazilir (yoksa Izibiz uzunluktan tahmin eder)
    if LProfil = 'IHRACAT' then begin
      // Ihracat: gercek alici buyerCustomerParty olur; GIB schematron PARTYTYPE=EXPORT
      // kimligi ister (customerParty ise asagida Gumruk'e cevrilir).
      LCustomer.AddPair('schemeId', 'PARTYTYPE');
      LCustomer.AddPair('partyType', 'EXPORT');
      LCustomer.AddPair('identifier', ABaslik.VergiNo);
    end else begin
      LCustomer.AddPair('schemeId', LCustSeli);
      LCustomer.AddPair('identifier', ABaslik.VergiNo);
    end;
    if SameText(LCustSeli, 'TCKN') and (LIsArsiv or LIsIrsaliye) then begin
      // Baslik'tan ad/soyad ayir: SON kelime SOYAD, oncesi AD (orn "Mehmet Ali Ay" -> Ad="Mehmet Ali", Soyad="Ay")
      LTrimmed := Trim(ABaslik.Baslik);
      LBosluk := LastDelimiter(' ', LTrimmed);
      if LBosluk > 0 then begin
        LAd := Trim(Copy(LTrimmed, 1, LBosluk - 1));
        LSoyad := Trim(Copy(LTrimmed, LBosluk + 1, MaxInt));
      end else begin
        LAd := LTrimmed;
        LSoyad := LTrimmed;
      end;
      LCustomer.AddPair('firstName', LAd);
      LCustomer.AddPair('lastName', LSoyad);
    end else begin
      LCustomer.AddPair('name', ABaslik.Baslik);
      // EIrsaliye taxOffice'i de gonderebilir
      if Trim(ABaslik.VergiDairesi) <> '' then
        LCustomer.AddPair('taxOffice', ABaslik.VergiDairesi);
      // Sahis firma (TCKN=11 hane) e-Fatura: GIB kilavuzu (2.2.13) alicinin sahis
      // olmasi durumunda cac:Person (Ad/Soyad) ister. izibiz JSON-native'de
      // firstName/lastName yoksa "Belge gönderici/alıcı Ad boş olamaz" (kod 816).
      // name (unvan->PartyName) + taxOffice (vergi dairesi->TaxScheme) yaninda Person
      // de gonder (ornek: YILDIRIM ALÜMİNYUM XML, schemeID=TCKN + PartyName + TaxScheme).
      if SameText(LCustSeli, 'TCKN') then begin
        LTrimmed := Trim(ABaslik.Baslik);
        LBosluk := LastDelimiter(' ', LTrimmed);  // SON kelime = soyad, oncesi = ad
        if LBosluk > 0 then begin
          LAd := Trim(Copy(LTrimmed, 1, LBosluk - 1));
          LSoyad := Trim(Copy(LTrimmed, LBosluk + 1, MaxInt));
        end else begin
          LAd := LTrimmed;
          LSoyad := LTrimmed;
        end;
        LCustomer.AddPair('firstName', LAd);
        LCustomer.AddPair('lastName', LSoyad);
      end;
    end;
    // Address ? Postman ornegine gore VARSAYILAN olarak gonderilir (Izibiz NPE atmasin)
    var LCustomerAdr: TJSONObject := TJSONObject.Create;
    LCustomerAdr.AddPair('country', 'TR');
    if Trim(ABaslik.Il) <> '' then
      LCustomerAdr.AddPair('city', ABaslik.Il);
    if Trim(ABaslik.Ilce) <> '' then
      LCustomerAdr.AddPair('subCity', ABaslik.Ilce);
    if Trim(ABaslik.Adres) <> '' then
      LCustomerAdr.AddPair('streetName', ABaslik.Adres);
    // EArsiv: aliciAlias mail adresidir, Izibiz buradan iletim yapar
    if LIsArsiv and (Trim(ABaslik.AliciAlias) <> '') then
      LCustomerAdr.AddPair('email', Trim(ABaslik.AliciAlias));
    // Alici iletisim (e-posta + telefon): yalniz e-Arsiv'de gerekli (posta iletimi).
    // e-Fatura GIB posta kutusuna gider; email/telefon opsiyonel oldugundan cekilmez.
    if LIsArsiv then begin
      var LAliciMail: string := '';
      var LAliciTel: string := '';
      AliciIletisimGetir(ABaslik.RehberID, LAliciMail, LAliciTel);
      if (LAliciMail <> '') and (LCustomerAdr.GetValue('email') = nil) then
        LCustomerAdr.AddPair('email', LAliciMail);
      if LAliciTel <> '' then
        LCustomerAdr.AddPair('telephone', LAliciTel);
    end;
    LCustomer.AddPair('address', LCustomerAdr);
    if LProfil = 'IHRACAT' then begin
      // Ihracat: gercek alici buyerCustomerParty; muhasebe alicisi (customerParty)
      // = Gumruk ve Ticaret Bakanligi (GIB kurali, VKN 1460415308).
      LContent.AddPair('buyerCustomerParty', LCustomer);
      LContent.AddPair('customerParty', GumrukCustomerPartyOlustur);
    end else
      LContent.AddPair('customerParty', LCustomer);

    // Tax / Monetary ? sadece fatura/arsiv icin (irsaliyede yok)
    if not LIsIrsaliye then begin
      LToplamMatrah := 0;
      LToplamKDV := 0;
      LToplamTevkifat := 0;
      for i := 0 to High(ASatirlar) do begin
        LToplamMatrah := LToplamMatrah + ASatirlar[i].Tutar;
        LToplamTevkifat := LToplamTevkifat + SatirTevkifatTutar(ASatirlar[i]);
      end;
      LTax := TJSONObject.Create;
      LTaxSubArr := TJSONArray.Create;
      for i := 0 to High(ASatirlar) do begin
        LOranIslendi := False;
        for J := 0 to i - 1 do
          if (Abs(ASatirlar[J].KDVOrani - ASatirlar[i].KDVOrani) < 0.001) and
             ((SatirKDVBrut(ASatirlar[J]) < 0.001) = (SatirKDVBrut(ASatirlar[i]) < 0.001)) then begin
            LOranIslendi := True;
            Break;
          end;
        if LOranIslendi then
          Continue;

        LGrupMatrah := 0;
        LGrupVergi := 0;
        for J := i to High(ASatirlar) do
          if (Abs(ASatirlar[J].KDVOrani - ASatirlar[i].KDVOrani) < 0.001) and
             ((SatirKDVBrut(ASatirlar[J]) < 0.001) = (SatirKDVBrut(ASatirlar[i]) < 0.001)) then begin
            LGrupMatrah := LGrupMatrah + ASatirlar[J].Tutar;
            LGrupVergi := LGrupVergi + SatirKDVBrut(ASatirlar[J]);
          end;
        LToplamKDV := LToplamKDV + LGrupVergi;

        LTaxSub := TJSONObject.Create;
        LTaxSub.AddPair('calculationSequenceNumeric', TJSONNumber.Create(1));
        LTaxSub.AddPair('taxableAmount', TJSONNumber.Create(LGrupMatrah));
        LTaxSub.AddPair('percent', TJSONNumber.Create(ASatirlar[i].KDVOrani));
        LTaxSub.AddPair('taxAmount', TJSONNumber.Create(LGrupVergi));
        if LGrupVergi < 0.001 then begin
          var LMufKod, LMufNeden: string;
          KDVMuafiyetKodNeden(ABaslik, LMufKod, LMufNeden);
          LTaxSub.AddPair('taxExemptionCode', LMufKod);
          LTaxSub.AddPair('taxExemptionReason', LMufNeden);
        end;
        LTaxScheme := TJSONObject.Create;
        LTaxScheme.AddPair('name', 'KDV');
        LTaxScheme.AddPair('typeCode', '0015');
        LTaxSub.AddPair('taxScheme', LTaxScheme);
        LTaxSubArr.AddElement(LTaxSub);
      end;
      if Abs(LToplamKDV - ABaslik.KDV) < 0.02 then
        LToplamKDV := ABaslik.KDV;
      LTax.AddPair('taxAmount', TJSONNumber.Create(LToplamKDV));
      LTax.AddPair('taxSubTotal', LTaxSubArr);
      LContent.AddPair('taxTotal', LTax);

      if LToplamTevkifat > 0 then begin
        LWithholdingTax := TJSONObject.Create;
        LWithholdingTax.AddPair('taxAmount', TJSONNumber.Create(LToplamTevkifat));
        LWithholdingSubArr := TJSONArray.Create;
        for i := 0 to High(ASatirlar) do begin
          if SatirTevkifatTutar(ASatirlar[i]) <= 0 then
            Continue;
          LOranIslendi := False;
          for J := 0 to i - 1 do
            if Abs(ASatirlar[J].TevkifatOrani - ASatirlar[i].TevkifatOrani) < 0.001 then begin
              LOranIslendi := True;
              Break;
            end;
          if LOranIslendi then
            Continue;
          LGrupMatrah := 0;
          LGrupTevkifat := 0;
          for J := i to High(ASatirlar) do
            if Abs(ASatirlar[J].TevkifatOrani - ASatirlar[i].TevkifatOrani) < 0.001 then begin
              LGrupMatrah := LGrupMatrah + SatirKDVBrut(ASatirlar[J]);  // tevkifat matrahi = KDV tutari (net degil; izibiz sematron)
              LGrupTevkifat := LGrupTevkifat + SatirTevkifatTutar(ASatirlar[J]);
            end;
          LWithholdingSub := TevkifatSubOlustur(LGrupMatrah, LGrupTevkifat,
            ASatirlar[i].TevkifatOrani, ABaslik);
          LWithholdingSubArr.AddElement(LWithholdingSub);
        end;
        LWithholdingTax.AddPair('taxSubTotal', LWithholdingSubArr);
        // izibiz FATURA (content) duzeyinde 'withHoldingTax' anahtarini bekler
        // (satirda 'withholdingTaxTotal'). Yanlis anahtar -> fatura tevkifati kurulmaz
        // -> "satirda tevkifat yok" schematron hatasi.
        LContent.AddPair('withHoldingTax', LWithholdingTax);
      end;

      // GIB/izibiz: legalMonetaryTotal.lineExtensionAmount = "Mal Hizmet Toplam Tutari" = BRUT
      //   (iskonto ONCESI = net + toplam iskonto). taxExclusiveAmount = NET (iskonto sonrasi vergi matrahi).
      //   brut - allowanceTotal = taxExclusive. (LToplamMatrah net; satir LineExtensionAmount net kalir.)
      var LTopIsk: Currency := SatirlarIskontoToplami(ASatirlar);
      var LPayable: Currency := LToplamMatrah + LToplamKDV - LToplamTevkifat;
      if Abs(LPayable - ABaslik.Toplam) < 0.02 then
        LPayable := ABaslik.Toplam;
      LMonetary := TJSONObject.Create;
      LMonetary.AddPair('lineExtensionAmount', TJSONNumber.Create(LToplamMatrah + LTopIsk));  // BRUT
      LMonetary.AddPair('taxExclusiveAmount', TJSONNumber.Create(LToplamMatrah));               // NET
      LMonetary.AddPair('taxInclusiveAmount', TJSONNumber.Create(LToplamMatrah + LToplamKDV));
      LMonetary.AddPair('payableAmount', TJSONNumber.Create(LPayable));
      if LTopIsk > 0.0001 then
        LMonetary.AddPair('allowanceTotalAmount', TJSONNumber.Create(LTopIsk));
      LContent.AddPair('legalMonetaryTotal', LMonetary);
    end else begin
      // E-Irsaliye: shipment blogu
      var LShipment: TJSONObject := TJSONObject.Create;
      LShipment.AddPair('id', TJSONNumber.Create(1));

      var LGoods: TJSONArray := TJSONArray.Create;
      var LGood: TJSONObject := TJSONObject.Create;
      LGood.AddPair('currencyId', IfThen(Trim(ABaslik.ParaBirimi) = '', 'TRY', ABaslik.ParaBirimi));
      LGood.AddPair('valueAmount', TJSONNumber.Create(ABaslik.Matrah));
      LGoods.AddElement(LGood);
      LShipment.AddPair('goodsItems', LGoods);

      var LStages: TJSONArray := TJSONArray.Create;
      var LStage: TJSONObject := TJSONObject.Create;
      if Trim(LSevk.Plaka) <> '' then
        LStage.AddPair('licensePlateID', LSevk.Plaka);
      if Trim(LSevk.DorsePlaka) <> '' then
        LStage.AddPair('trailerPlateID', LSevk.DorsePlaka);
      if (Trim(LSevk.SoforAdi) <> '') or (Trim(LSevk.SoforSoyadi) <> '') or
         (Trim(LSevk.SoforTckn) <> '') then begin
        var LDriver: TJSONObject := TJSONObject.Create;
        var LDFirst, LDFamily: string;
        SoforAdSoyadAyir(LSevk.SoforAdi, LSevk.SoforSoyadi, LDFirst, LDFamily);
        // GIB DriverPerson: FirstName + FamilyName ZORUNLU (eksikse xsi:nil -> sematron reddi).
        LDriver.AddPair('firstName', LDFirst);
        LDriver.AddPair('familyName', LDFamily);
        LDriver.AddPair('title', 'Surucu');
        // GIB'de kimlik no NationalityID elementinde tasinir (ornek: <cbc:NationalityID>TCKN</...>).
        if Trim(LSevk.SoforTckn) <> '' then
          LDriver.AddPair('nationalityID', LSevk.SoforTckn);
        LStage.AddPair('driverPerson', LDriver);
      end;
      if (Trim(LTasiyici.Unvan) <> '') or (Trim(LTasiyici.VergiNo) <> '') then begin
        var LCarrier: TJSONObject := TJSONObject.Create;
        if Trim(LTasiyici.Unvan) <> '' then
          LCarrier.AddPair('name', LTasiyici.Unvan);
        if Trim(LTasiyici.VergiNo) <> '' then begin
          LCarrier.AddPair('identifier', LTasiyici.VergiNo);
          LCarrier.AddPair('schemeId', KimlikSemasi(LTasiyici.VergiNo));
        end;
        LStage.AddPair('carrierParty', LCarrier);
      end;
      LStages.AddElement(LStage);
      LShipment.AddPair('shipmentStages', LStages);

      var LDelivery: TJSONObject := TJSONObject.Create;
      var LDelAdr: TJSONObject := TJSONObject.Create;
      LDelAdr.AddPair('country', 'TR');
      if Trim(ABaslik.Il) <> '' then LDelAdr.AddPair('city', ABaslik.Il);
      if Trim(ABaslik.Ilce) <> '' then LDelAdr.AddPair('subCity', ABaslik.Ilce);
      if Trim(ABaslik.Adres) <> '' then LDelAdr.AddPair('streetName', ABaslik.Adres);
      LDelAdr.AddPair('postalZone', '34000');
      LDelivery.AddPair('deliveryAddress', LDelAdr);

      var LDespatch: TJSONObject := TJSONObject.Create;
      LDespatch.AddPair('actualDespatchDate', FormatDateTime('yyyy-mm-dd', ABaslik.Tarih));
      LDespatch.AddPair('actualDespatchTime', FormatDateTime('hh:nn:ss', ABaslik.Tarih));
      LDelivery.AddPair('despatch', LDespatch);

      LShipment.AddPair('delivery', LDelivery);
      LContent.AddPair('shipment', LShipment);
    end;

    // Lines
    LLines := TJSONArray.Create;
    for i := 0 to Length(ASatirlar) - 1 do begin
      LSatir := ASatirlar[i];
      LLine := TJSONObject.Create;
      LLine.AddPair('id', TJSONNumber.Create(LSatir.SatirNo));
      LLine.AddPair('quantity', TJSONNumber.Create(LSatir.Miktar));
      LLine.AddPair('unitCode', IfThen(LSatir.BirimKodu = '', 'C62', LSatir.BirimKodu));
      LLine.AddPair('lineExtensionAmount', TJSONNumber.Create(LSatir.Tutar));
      LLine.AddPair('itemName', LSatir.UrunAdi);
      LLine.AddPair('itemPrice', TJSONNumber.Create(LSatir.BirimFiyat));
      // Satir iskontosu -> izibiz JSON 'allowanceCharge' dizisi (UBL cac:AllowanceCharge aynasi).
      //   Eksikse izibiz iskonto=0 gosterir + mal/hizmet'i iskonto-sonrasi (net) sanar. lineExtension
      //   NET kalir; baseAmount=brut, amount=iskonto. multiplierFactorNumeric = KESIR (oran/100; izibiz
      //   dogru cikti 0.15 -> base*mfn=amount). YALNIZ fatura (irsaliye'de yok).
      if (not LIsIrsaliye) then begin
        var LSIskonto: Currency := SatirIskontoTutar(LSatir);
        if LSIskonto > 0.0001 then begin
          var LAllowArr: TJSONArray := TJSONArray.Create;
          var LAllow: TJSONObject := TJSONObject.Create;
          LAllow.AddPair('chargeIndicator', TJSONBool.Create(False));
          LAllow.AddPair('reason', 'Iskonto');
          LAllow.AddPair('multiplierFactorNumeric', TJSONNumber.Create(SatirIskontoOrani(LSatir) / 100.0));
          LAllow.AddPair('amount', TJSONNumber.Create(LSIskonto));
          var LSBrut: Currency := SatirBrutTutar(LSatir);
          if LSBrut > 0.0001 then
            LAllow.AddPair('baseAmount', TJSONNumber.Create(LSBrut));
          LAllowArr.AddElement(LAllow);
          LLine.AddPair('allowanceCharge', LAllowArr);
        end;
      end;
      // Item kimlikleri: Izibiz earchives JSON'unda DUZ string alan bekliyor
      // (nesne {id:..} DEGIL). Dogru anahtarlar Izibiz tarafindan bildirildi:
      //   buyerIdentificationId / sellerIdentificationId / manufacturerIdentificationId
      var LBuyerId: string := Trim(SatirAliciKimlik(LSatir));
      if LBuyerId <> '' then
        LLine.AddPair('buyerIdentificationId', LBuyerId);
      var LSellerId: string := Trim(SatirSaticiKimlik(LSatir));
      if LSellerId <> '' then
        LLine.AddPair('sellerIdentificationId', LSellerId);
      if Trim(LSatir.SutKodu) <> '' then
        LLine.AddPair('manufacturerIdentificationId', Trim(LSatir.SutKodu));
      // Marka / Model / Not -> Izibiz duz alanlar (kimliklerin altinda, Izibiz'in
      // belirttigi yapida). Not: satir notu (LOTNO metni) artik 'note' duz alani.
      if Trim(LSatir.MarkaAdi) <> '' then
        LLine.AddPair('brandName', Trim(LSatir.MarkaAdi));
      if Trim(LSatir.ModelKodu) <> '' then
        LLine.AddPair('modelName', Trim(LSatir.ModelKodu));
      // Satir notu: "Lot No: .. Miktar: .." (LOTNO oneki yok, formatla birebir)
      if Trim(LSatir.Notu) <> '' then
        LLine.AddPair('note', Trim(LSatir.Notu));
      // Ilac/tibbi cihaz kimligi -> Izibiz: additionalItemIdentifications
      // [{schemeID, itemIdentification}]. Yerel UBL TibbiCihazKimlikXMLYaz ile ayni.
      // YALNIZ ilac/tibbi cihaz senaryosunda (8) VE gercek kimlik verisi varsa.
      // e-Irsaliye ilac/tibbi cihaz DEGILSE (Senaryo<>8) yazilmaz -- SP ilac-disi
      // urunlerde de deger dondurdugunden fatura ile ayni sekilde Senaryo ile gate.
      if (ABaslik.Senaryo = 8) and (Trim(LSatir.TibbiCihazKimlik) <> '') then
        LLine.AddPair('additionalItemIdentifications',
          TibbiCihazKimlikJSONDizi(LSatir.TibbiCihazKimlik));
      if Trim(LSatir.LotNo) <> '' then begin
        var LItemProps: TJSONArray := TJSONArray.Create;
        var LItemProp: TJSONObject := TJSONObject.Create;
        LItemProp.AddPair('name', 'LOTNO');
        LItemProp.AddPair('value', Trim(LSatir.LotNo));
        LItemProps.AddElement(LItemProp);
        LLine.AddPair('additionalItemProperties', LItemProps);
      end;
      if LIsIrsaliye then begin
        LLine.AddPair('currencyId',
          IfThen(Trim(ABaslik.ParaBirimi) = '', 'TRY', ABaslik.ParaBirimi));
        LLines.AddElement(LLine);
        Continue;
      end;
      // line tax ? sadece fatura/arsiv
      LSatirVergi := SatirKDVBrut(LSatir);
      LSatirTevkifat := SatirTevkifatTutar(LSatir);
      LLineTax := TJSONObject.Create;
      LLineTax.AddPair('taxAmount', TJSONNumber.Create(LSatirVergi));
      LLineTaxSubArr := TJSONArray.Create;
      LLineTaxSub := TJSONObject.Create;
      LLineTaxSub.AddPair('taxableAmount', TJSONNumber.Create(LSatir.Tutar));
      LLineTaxSub.AddPair('taxAmount', TJSONNumber.Create(LSatirVergi));
      LLineTaxSub.AddPair('calculationSequenceNumeric', TJSONNumber.Create(1));
      LLineTaxSub.AddPair('percent', TJSONNumber.Create(LSatir.KDVOrani));
      if LSatirVergi < 0.001 then begin
        var LMufKod, LMufNeden: string;
        KDVMuafiyetKodNeden(ABaslik, LMufKod, LMufNeden);
        LLineTaxSub.AddPair('taxExemptionCode', LMufKod);
        LLineTaxSub.AddPair('taxExemptionReason', LMufNeden);
      end;
      LLineTaxScheme := TJSONObject.Create;
      LLineTaxScheme.AddPair('name', 'KDV');
      LLineTaxScheme.AddPair('typeCode', '0015');   // izibiz KDV her zaman 0015 (KDV=0 dahil; 9015 gecersiz)
      LLineTaxSub.AddPair('taxScheme', LLineTaxScheme);
      LLineTaxSubArr.AddElement(LLineTaxSub);
      LLineTax.AddPair('taxSubTotal', LLineTaxSubArr);
      LLine.AddPair('taxTotal', LLineTax);
      if LSatirTevkifat > 0 then begin
        LWithholdingTax := TJSONObject.Create;
        LWithholdingTax.AddPair('taxAmount', TJSONNumber.Create(LSatirTevkifat));
        LWithholdingSubArr := TJSONArray.Create;
        LWithholdingSub := TevkifatSubOlustur(SatirKDVBrut(LSatir), LSatirTevkifat,
          LSatir.TevkifatOrani, ABaslik);
        LWithholdingSubArr.AddElement(LWithholdingSub);
        LWithholdingTax.AddPair('taxSubTotal', LWithholdingSubArr);
        LLine.AddPair('withholdingTaxTotal', LWithholdingTax);
      end;
      // IHRACAT: satir duzeyi delivery (deliveryAddress + deliveryTerms + shipment).
      if (LProfil = 'IHRACAT') and ABaslik.IhracatVar then
        LLine.AddPair('delivery', IhracatSatirDeliveryOlustur(ABaslik, LSatir));
      LLines.AddElement(LLine);
    end;
    LContent.AddPair('lines', LLines);

    LRoot.AddPair('content', LContent);
    Result := LRoot.ToJSON;
  finally
    LRoot.Free;
  end;
end;

class function TEBelgeOlusturucu.Gonder(AConnection: TFDConnection;
  AFatBaslikID: Integer; const AKullanici, ASifre, ABaseURL: string;
  ATestModu: Boolean; out AYanitMesaj: string): Boolean;
// Izibiz REST entegrasyonu: Login -> SendInvoice -> DB update.
var
  LBaslik: TEBelgeBaslik;
  LSatirlar: TEBelgeSatirlar;
  LEBelgeID: Int64;
  LKullanan: Integer;
  LOwnTransaction: Boolean;
  LSessionID, LHata, LBody, LYol, LGondericiVKN, LGondericiUnvan: string;
  LSonuc: TIzibizGonderimSonuc;
begin
  Result := False;
  AYanitMesaj := '';
  OlusturulmusGidenBelgeOku(AFatBaslikID, 'Gonderim', LBaslik, LSatirlar);

  LEBelgeID := LBaslik.EBelgeID;
  LKullanan := StrToIntDef(Kullanan, 0);
  LGondericiVKN := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EBelgeVergiNo, '');
  LGondericiUnvan := KURUMADI;

  // 1) Login � Basic Auth + identifier(VKN) + name(firma)
  if not TIzibizRest.Login(ABaseURL, AKullanici, ASifre,
                           LGondericiVKN, LGondericiUnvan,
                           LSessionID, LHata) then begin
    AYanitMesaj := 'Login basarisiz: ' + LHata;
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
      'VALUES(&EID,1,2,9,&MSG,&KUL,GETDATE())',
      ['&EID', '&MSG', '&KUL'], [LEBelgeID, AYanitMesaj, LKullanan]);
    Exit;
  end;

  // 2) JSON body olustur � gonderici tarafini Tablo.TabBizim'den cek
  //    Test modunda gonderici VKN, Izibiz test hesabinin VKN'sine override edilir
  //    (Izibiz oturum acan hesabin VKN'si ile belge VKN'sinin uyusmasini bekliyor)
  var LGondericiTaraf: TEBelgeTaraf := BizimTarafGetir(LGondericiVKN, LGondericiUnvan);
  if ATestModu then
    LGondericiTaraf.VergiNo := LGondericiVKN;   // Ops_FaturaOpsiyon_EBelgeVergiNo (Izibiz test VKN)
  LBody := _IzibizJSONOlustur(LBaslik, LSatirlar, LGondericiTaraf);

  // 3) SendInvoice ? belge turune gore endpoint
  //   /v1/einvoices, /v1/earchives, /v2/edespatches/send (irsaliye v2 ve /send suffixli)
  if LBaslik.Tur = EBelgeTuruEIrsaliye then
    LYol := '/v2/edespatches/send'
  else if LBaslik.EArsivMi then
    LYol := '/v1/earchives'
  else begin
    LYol := '/v1/einvoices';
  end;

  // Login log
  Veritabani.BasitKomutÇalıştır(AConnection,
    'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
    'VALUES(&EID,1,2,1,&MSG,&KUL,GETDATE())',
    ['&EID', '&MSG', '&KUL'],
    [LEBelgeID,
     IfThen(ATestModu, 'TEST', 'URETIM') + ' modunda gonderim: ' + ABaseURL + LYol,
     LKullanan]);

  // Debug: yalnizca TEST modunda gonderilen JSON body'sini "Belgelerim" altina
  // yazar + yolunu EBELGEMESAJ'a loglar. Uretimde disk/gizlilik icin yazilmaz.
  if ATestModu then begin
    var LReqDosya: string := TPath.Combine(TPath.GetDocumentsPath,
      'EBelge_Request_' + IfThen(Trim(LBaslik.FaturaNo) <> '',
        LBaslik.FaturaNo, IntToStr(LEBelgeID)) + '.json');
    try
      TFile.WriteAllText(LReqDosya, LBody, TEncoding.UTF8);
    except
      on E: Exception do
        LReqDosya := 'YAZILAMADI (' + E.Message + ')';
    end;
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,EKLEYEN,EKLEMETARIHI) ' +
      'VALUES(&EID,1,2,3,&MSG,&KUL,GETDATE())',
      ['&EID', '&MSG', '&KUL'],
      [LEBelgeID, 'REQUEST BODY dosyasi: ' + LReqDosya + sLineBreak +
                  'Ilk 3500 char: ' + Copy(LBody, 1, 3500), LKullanan]);
  end;

  if not TIzibizRest.SendInvoice(ABaseURL, LSessionID, LYol, LBody, LSonuc) then begin
    AYanitMesaj := 'SendInvoice basarisiz: ' + LSonuc.Mesaj;
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,HTTPKODU,EKLEYEN,EKLEMETARIHI) ' +
      'VALUES(&EID,1,2,9,&MSG,&HK,&KUL,GETDATE())',
      ['&EID', '&MSG', '&HK', '&KUL'],
      [LEBelgeID, AYanitMesaj, LSonuc.HttpKodu, LKullanan]);
    // Gonderim teknik olarak basarisiz -> gridde Hata/Red olarak gorunsun.
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE FATBASLIK SET EFATURASONUC=3 WHERE ID=&ID', ['&ID'], [AFatBaslikID]);
    Exit;
  end;

  // 4) Basarili � DB guncelle
  LOwnTransaction := not AConnection.InTransaction;
  if LOwnTransaction then AConnection.StartTransaction;
  try
    Veritabani.BasitKomutÇalıştır(AConnection,
      'INSERT INTO ' + DepoTablo('EBELGEMESAJ') + '(EBELGEID,YON,ISLEMTURU,MESAJTIPI,MESAJ,HTTPKODU,SERVISKODU,EKLEYEN,EKLEMETARIHI) ' +
      'VALUES(&EID,1,2,2,&MSG,&HK,&SRV,&KUL,GETDATE())',
      ['&EID', '&MSG', '&HK', '&SRV', '&KUL'],
      [LEBelgeID, 'Gonderim basarili. UUID: ' + LSonuc.UUID,
       LSonuc.HttpKodu, IfThen(ATestModu, 'TEST', 'URETIM'), LKullanan]);

    if Trim(LSonuc.UUID) <> '' then
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE ' + DepoTablo('EBELGE') + ' SET UUID=&U, DURUM=2, DEGISTIREN=&KUL, DEGISTIRMETARIHI=GETDATE() WHERE ID=&EID',
        ['&U', '&KUL', '&EID'], [LSonuc.UUID, LKullanan, LEBelgeID])
    else
      Veritabani.BasitKomutÇalıştır(AConnection,
        'UPDATE ' + DepoTablo('EBELGE') + ' SET DURUM=2, DEGISTIREN=&KUL, DEGISTIRMETARIHI=GETDATE() WHERE ID=&EID',
        ['&KUL', '&EID'], [LKullanan, LEBelgeID]);

    // Gonderim sonrasi durum: 1->2 (eFatura), 11->12 (eArsiv), 51->52 (eIrsaliye)
    Veritabani.BasitKomutÇalıştır(AConnection,
      'UPDATE FATBASLIK SET EFATURADURUM = CASE EFATURADURUM ' +
      ' WHEN 1 THEN 2 WHEN 11 THEN 12 WHEN 51 THEN 52 ELSE EFATURADURUM END, ' +
      'EFATURASONUC=9 WHERE ID=&ID',
      ['&ID'], [AFatBaslikID]);

    if LOwnTransaction then AConnection.Commit;
    AYanitMesaj := LSonuc.Mesaj;
    if Trim(LSonuc.UUID) <> '' then AYanitMesaj := AYanitMesaj + ' UUID=' + LSonuc.UUID;
    Result := True;
  except
    on E: Exception do begin
      if LOwnTransaction and AConnection.InTransaction then AConnection.Rollback;
      AYanitMesaj := 'DB guncelleme hatasi: ' + E.Message;
    end;
  end;
end;

// ---- GELEN E-BELGE (YON=2) icin uretim ----

function _GelenUBLOku(AConnection: TFDConnection; AFatBaslikID: Integer;
  out ARehberID: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := '';
  ARehberID := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := AConnection;
    LQry.SQL.Text :=
      'SELECT '+DbUst(1) + C_UBL_OKU + ' as UBLX, ' +
      '  isnull(FB.REHBERID, 0) as RID ' +
      'FROM ' + DepoTablo('EBELGE') + ' E ' +
      ' INNER JOIN FATBASLIK FB ON FB.ID = E.FATBASLIKID ' +
      'WHERE E.YON = 2 AND E.FATBASLIKID = :FID ' +
      'ORDER BY E.ID DESC '+DbSinir(1);
    PgQueryCevir(LQry);
    LQry.ParamByName('FID').AsInteger := AFatBaslikID;
    LQry.Open;
    if not LQry.Eof then begin
      Result := LQry.FieldByName('UBLX').AsString;
      ARehberID := LQry.FieldByName('RID').AsInteger;
    end;
    LQry.Close;
  finally
    LQry.Free;
  end;
end;

procedure GelenBelgeOku(AConnection: TFDConnection; AFatBaslikID: Integer;
  out AUBL: string; out ARehberID: Integer);
begin
  AUBL := _GelenUBLOku(AConnection, AFatBaslikID, ARehberID);
  if Trim(AUBL) = '' then
    raise Exception.Create('Gelen e-belgenin UBL XML bilgisi bulunamadi.');
end;

function GelenHTMLUret(ARehberID: Integer; const AUBL: string): string;
var
  LXSLT: string;
begin
  Result := '';

  // 1) Gelen UBL icindeki gondericiye ait gomulu XSLT varsa once onu kullan.
  if GömülüXSLTGetir(AUBL, LXSLT) then
    Result := XSLTDonustur(AUBL, LXSLT);

  // 2) Gomulu XSLT yoksa veya calismazsa opsiyonda tanimli Gelen e-Fatura XSLT.
  if Trim(Result) = '' then
    Result := XSLTOnizlemeUret(ARehberID, EBelgeTuruEFatura, False, True, AUBL);

  // 3) Son care: XSLT olmadan ham XML'i HTML icinde goster.
  if Trim(Result) = '' then
    Result := XMLHTMLUret('Gelen e-Fatura XML', AUBL);
end;

class procedure TEBelgeOlusturucu.OnizleGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer);
var
  LUBL, LHTML, LDosya: string;
  LRehberID: Integer;
  LSonuc: HINST;
begin
  GelenBelgeOku(AConnection, AFatBaslikID, LUBL, LRehberID);
  LHTML := GelenHTMLUret(LRehberID, LUBL);

  LDosya := TPath.Combine(TPath.GetTempPath,
    'Gentegre_GelenEBelge_' + IntToStr(AFatBaslikID) + '.html');
  TFile.WriteAllText(LDosya, LHTML, TEncoding.UTF8);
  LSonuc := ShellExecute(0, 'open', PChar(LDosya), nil, nil, SW_SHOWNORMAL);
  if LSonuc <= 32 then
    raise Exception.Create('Gelen e-belge onizleme dosyasi acilamadi.');
end;

class procedure TEBelgeOlusturucu.XMLKaydetGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LUBL: string;
  LRehberID: Integer;
begin
  GelenBelgeOku(AConnection, AFatBaslikID, LUBL, LRehberID);
  TFile.WriteAllText(ADosya, LUBL, TEncoding.UTF8);
end;

class procedure TEBelgeOlusturucu.HTMLKaydetGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LUBL, LHTML: string;
  LRehberID: Integer;
begin
  GelenBelgeOku(AConnection, AFatBaslikID, LUBL, LRehberID);
  LHTML := GelenHTMLUret(LRehberID, LUBL);
  TFile.WriteAllText(ADosya, LHTML, TEncoding.UTF8);
end;

procedure HTMLDosyaPDFeCevir(const ATempHTML, ADosya: string);
var
  LEdge, LKomut: string;
  LStartInfo: TStartupInfo;
  LProcInfo: TProcessInformation;
begin
  LEdge := 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe';
  if not FileExists(LEdge) then
    LEdge := 'C:\Program Files\Microsoft\Edge\Application\msedge.exe';
  if not FileExists(LEdge) then begin
    LEdge := 'C:\Program Files\Google\Chrome\Application\chrome.exe';
    if not FileExists(LEdge) then
      LEdge := 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe';
  end;
  if not FileExists(LEdge) then begin
    try TFile.Delete(ATempHTML); except end;
    raise Exception.Create(
      'PDF olusturmak icin Microsoft Edge veya Google Chrome kurulu olmalidir.');
  end;

  // Izole profil (--user-data-dir) ZORUNLU: kullanicida Edge/Chrome zaten aciksa
  // --headless komutu calisan ornege baglanip PDF uretmeden cikar ("PDF dosyasi
  // olusturulamadi"). Ayri profil klasoru bunu onler. Ayrica --no-first-run vb.
  var LProfil: string := TPath.Combine(TPath.GetTempPath,
    'GentegrePDF_' + IntToStr(GetCurrentProcessId) + '_' + IntToStr(GetTickCount));
  LKomut := '"' + LEdge + '" --headless --disable-gpu --no-margins ' +
            '--user-data-dir="' + LProfil + '" --no-first-run ' +
            '--no-default-browser-check --disable-extensions ' +
            '--print-to-pdf="' + ADosya + '" "' + ATempHTML + '"';
  FillChar(LStartInfo, SizeOf(LStartInfo), 0);
  LStartInfo.cb := SizeOf(LStartInfo);
  LStartInfo.dwFlags := STARTF_USESHOWWINDOW;
  LStartInfo.wShowWindow := SW_HIDE;
  if not CreateProcess(nil, PChar(LKomut), nil, nil, False, 0, nil, nil,
                       LStartInfo, LProcInfo) then begin
    try TFile.Delete(ATempHTML); except end;
    raise Exception.Create('PDF olusturma islemi baslatilamadi.');
  end;
  try
    WaitForSingleObject(LProcInfo.hProcess, 60000);
  finally
    CloseHandle(LProcInfo.hThread);
    CloseHandle(LProcInfo.hProcess);
  end;
  // Yeni headless mod (Edge/Chrome 132+) PDF'i alt surecte yazip ANA sureci erken
  // kapatir; sadece parent'i beklemek yetmez. Cikti dosyasi olusana kadar
  // (max ~30sn) kisa araliklarla poll et.
  begin
    var LBek: Integer := 0;
    while (not FileExists(ADosya)) and (LBek < 30000) do begin
      Sleep(300);
      Inc(LBek, 300);
    end;
  end;
  try TFile.Delete(ATempHTML); except end;
  try if TDirectory.Exists(LProfil) then TDirectory.Delete(LProfil, True); except end;
  if not FileExists(ADosya) then
    raise Exception.Create('PDF dosyasi olusturulamadi (Edge/Chrome headless PDF uretemedi ' +
      '- tarayici versiyonu/izinleri veya profil erisimi kontrol edin).');
end;

class procedure TEBelgeOlusturucu.PDFKaydetGelen(AConnection: TFDConnection;
  AFatBaslikID: Integer; const ADosya: string);
var
  LTempHTML: string;
begin
  LTempHTML := TPath.Combine(TPath.GetTempPath,
    'Gentegre_GelenEBelge_PDF_' + IntToStr(AFatBaslikID) + '.html');
  HTMLKaydetGelen(AConnection, AFatBaslikID, LTempHTML);
  HTMLDosyaPDFeCevir(LTempHTML, ADosya);
end;

end.







