unit ULog;

// ============================================================
// Islem/audit loglama. Tek tablo: GENDEPO.dbo.ISLEMLOG (ana DB'de synonym).
//
// Model: OTONOM. Log kendi (kalici, cache'li) baglantisinda yazilir; is
// transaction'ina karismaz, kilit tutmaz. Tum govde try/except -> loglama
// hicbir kosulda uygulamayi kirmaz/yavaslamaz. Cagriyi islem BASARILI olduktan
// sonra yap.
//
// Kullanim (ATabloID = LOG.TABLOID, yani TabNo_* sabitleri):
//   LogYaz(liEkle, TabNo_REHBER, RehberID,
//     TLogKurucu.Yeni.Deger('KOD','320.01').Deger('UNVAN','ABC Ltd'), 'Cari Kart');
//
//   LogYaz(liDegistir, TabNo_FATBASLIK_Giden, FaturaID,
//     TLogKurucu.Yeni.Alan('TUTAR', EskiTutar, YeniTutar)
//                    .Alan('ACIKLAMA', EskiAck, YeniAck), 'Fatura');
//
//   LogYaz(liSil, TabNo_STOK, StokID, TLogKurucu.Yeni.Deger('KOD', StokKod));
// ============================================================

interface

uses
  System.JSON, System.Classes, Data.DB, System.Generics.Collections;

type
  // 0=silme 1=ekleme 2=degistirme (ISLEMLOG.ISLEMTIPI ile birebir)
  TLogIslem = (liSil = 0, liEkle = 1, liDegistir = 2);

  // BILGI (json) kurucu. Fluent; TLogKurucu.Yeni ... .JSON.
  // liDegistir icin Alan(eski,yeni) -> "AD":{"e":..,"y":..} (esitse atlanir).
  // liEkle/liSil icin Deger(ad,deger) -> "AD":deger.
  TLogKurucu = class
  private
    FObj: TJSONObject;
  public
    constructor Create;
    destructor Destroy; override;
    class function Yeni: TLogKurucu; static;
    // Degisiklik (eski -> yeni). Ayni ise eklenmez.
    function Alan(const AAd, AEski, AYeni: string): TLogKurucu; overload;
    function Alan(const AAd: string; AEski, AYeni: Int64): TLogKurucu; overload;
    function Alan(const AAd: string; AEski, AYeni: Currency): TLogKurucu; overload;
    function Alan(const AAd: string; AEski, AYeni: Double): TLogKurucu; overload;
    // Tek deger (ekleme/silme ozeti).
    function Deger(const AAd, ADeger: string): TLogKurucu; overload;
    function Deger(const AAd: string; ADeger: Int64): TLogKurucu; overload;
    function Deger(const AAd: string; ADeger: Currency): TLogKurucu; overload;
    function BosMu: Boolean;
    function JSON: string;
  end;

// JSON'u string olarak veren temel cagri. ATabloID = LOG.TABLOID (TabNo_*).
// AUstTabloID/AUstKayitID: master (ör. FATBASLIK). Verilmezse ust=kendisidir;
// detay satirlarda (ör. FATURA) master gecirilir -> master+detay birlikte gorulur.
procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  const ABilgiJSON: string; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0); overload;

// TLogKurucu alan pratik cagri. AKurucu'nun SAHIPLIGINI ALIR ve serbest birakir
// (fluent kullanim icin). Kurucu bos ise BILGI NULL yazilir.
procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  AKurucu: TLogKurucu; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0); overload;

// ---- Master/detay snapshot + diff loglama (wizard'lar icin ortak) ----
// Bir dataset'in tum satirlarini (ID -> alan degerleri, alan index sirali) ASnap'e
// alir. Duzenleme oncesi (browse) cagrilir; imlec bookmark ile korunur.
procedure LogSnapshotAl(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>);

// ASnap (yukleme) ile ADataSet (mevcut) farkini loglar:
//   degisen alan -> liDegistir, snapshot'ta olmayan satir -> liEkle,
//   mevcutta olmayan snapshot satiri -> liSil.
// ADetayTabNo = satirin TABLOID'i; AUstTabNo/AUstID = master (ust) anahtari.
// ASnap bos ise tum satirlar EKLEME sayilir (yeni belge). Kaydetmeyi ASLA bozmaz.
procedure LogDiffKaydet(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64);

// Bir kaydin (ADataSet mevcut satiri) tum dolu fkData alanlarini EKLEME loglar.
procedure LogKayitEkle(ADataSet: TDataSet; ATabNo: Integer; AID: Int64;
  AUstTabNo: Integer = 0; AUstID: Int64 = 0);

// E-Belge menu islemi (Hazirla/Gonder/Sifirla/Seri/Onizle/HTML-XML-PDF Kaydet ...) audit logu:
// bir ISLEMLOG satiri yazar (kim=KULLANICIID, ne zaman=TARIH otomatik; ne=AIslem metni BILGI'de).
// Her cagri = bir satir; ust=fatura karti (ATabloID/AFaturaID). AREHBERID = faturanin carisi
// (UInfo listesi cari KOD/AD'yi bundan cozer). AIslem = menu caption'i birebir. Islem sonrasi cagir.
procedure LogEBelgeIslem(ATabloID: Integer; AFaturaID: Int64; const AIslem: string; AREHBERID: Int64 = 0);

// KAYIT-BAGIMSIZ sistem olayi (e-fatura guncelle, kullanici login vb.): TabNo_SISTEM'e
// bir ISLEMLOG satiri (kim=KULLANICIID, ne zaman=TARIH otomatik; ne=AIslem). Belirli bir
// karta bagli DEGIL -> UInfo GENEL log ekraninda "Sistem" altinda gorunur.
procedure LogSistemIslem(const AIslem: string);

// Bir kart silinirken detay tablosundaki (AUstKolon=AUstID [AND AEkKosul]) TUM
// satirlari SILME loglar. SILMEDEN ONCE cagrilmali (veri hala DB'de). Her satir ->
// liSil (ust=kart). AEkKosul: cok-amacli detay tablolari icin ek WHERE
// (ör. REHBERBILGI 'YERI=70', IMAJ 'YERI=1', GOREVKULLANICI 'TUR=11').
procedure LogDetaylariSil(const ADetayTablo, AUstKolon: string;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64; const AEkKosul: string = '');

// Kart (master) ad/kod referansini GENDEPO.LOGREFERANS'a UPSERT eder (hizli arama).
// Silinen kayit da kalir (ASilindi=True -> SILINDI=1). AD/KOD dataset alanlarindan
// (FIRMA/STOKADI/ADI/KOD...) cikarilir. Loglama gibi is akisini ASLA kirmaz.
procedure LogReferansGuncelle(ADataSet: TDataSet; ATabloID: Integer; AKayitID: Int64;
  ASilindi: Boolean);

// Kaydin varlik anahtarlarini alanlarindan cikarir: cari <- REHBERID/CARIID,
// stok <- STOKID/URUNID. Bulunamazsa 0. (LogYaz'a REHBERID/STOKID gecmek icin.)
procedure LogVarlikIDleri(ADataSet: TDataSet; out ARehberID, AStokID: Int64);

// ---- KART loglama kisayollari (tum modullerde ayni desen; yeni modul eklerken bunlari kullan) ----

// Kart EKLEME logunu TEK SEFER yazar; hem kaydet hem kapanis-fallback ayni cagriyla:
// ekleme modunda, kart DB'de (dsBrowse, ID>0) ve daha once loglanmamissa LogKayitEkle.
// True donerse loglandi -> cagiran flag'ini gunceller:
//   FEkleLogland := LogKartEkle(Ds, TabNo, IslemOp='E', FEkleLogland) or FEkleLogland;
function LogKartEkle(ADataSet: TDataSet; ATabNo: Integer;
  AEklemeModu, AZatenLogland: Boolean): Boolean;

// Kart DEGISTIRME logu: BeforeEdit'teki OncekiLogBelirle snapshot'ina gore degisen
// alanlar (LogIslemleri/4). LogGun + try/except guard icerir.
// AUstTabNo/AUstID: detay satiri loglarken master (kart) anahtari (kart icin 0).
procedure LogKartDegisti(ADataSet: TDataSet; ATabNo, AKayitID: Integer;
  AUstTabNo: Integer = 0; AUstID: Int64 = 0);

// Kart SILME logu — SILMEDEN ONCE, imlec silinecek kayittayken cagrilir
// (OncekiLogBelirle + LogIslemleri/5). Detaylar icin ayrica LogDetaylariSil cagrilir.
// DIKKAT: liste ekranlarinda DELETE+Yenile'den SONRA cagrilirsa imlec kayar, YANLIS kayit loglanir.
// AUstTabNo/AUstID: tek detay satiri silinirken master (kart) anahtari (kart icin 0).
procedure LogKartSil(ADataSet: TDataSet; ATabNo, AKayitID: Integer;
  AUstTabNo: Integer = 0; AUstID: Int64 = 0);

// Detay satiri icin ORTAK AfterPost logu: BeforeEdit'te OncekiLogBelirle cagrilmis
// olmali (LogOnceki dolu -> DEGISTIRME, bos -> yeni satir EKLEME). ID alani yoksa
// veya LogGun kapaliysa hicbir sey yapmaz. Cagiran yalnizca DataSet->TabNo esler.
procedure LogDetaySatirPost(ADataSet: TDataSet; ADetayTabNo, AUstTabNo: Integer;
  AUstID: Int64);

// Bir SILME grubunu (kart + tum detaylari) log JSON'larindan AYNI ID ile geri
// INSERT eder (silinen kaydin dirilmesi / "Geri Al"). AUstTabloID/AUstKayitID = kart
// (master) anahtari, AGun = silme islemi tarihi (gun bazli). Kart once, sonra detaylar
// eklenir (FK). Kart ID'si su an baska bir kayitta kullaniliyorsa hicbir sey eklenmez.
// Sonuc: '' = tam basari; aksi halde hata (kart) veya uyari (atlanan detay) mesaji.
function LogGeriAl(AUstTabloID: Integer; AUstKayitID: Int64; AGun: TDateTime): string;

type
  // Geri-alinabilir oturum: bir formun/wizardin snapshot kapsamindaki bir tablosu.
  TSnapshotTablo = record
    Sira: SmallInt;      // geri-yukleme sirasi (ust=kucuk, alt=buyuk)
    TabloAdi: string;    // ana DB tablosu (ör. 'SIPARISDETAY')
    Filtre: string;      // o oturumun satirlarini secen WHERE (concrete deger; subquery olabilir)
  end;

// GERI-ALINABILIR OTURUM. Duzenleme acilisinda ATablolar'daki her tablonun (Filtre'ye uyan)
// satirlarini SNAPSHOT'a (depo) yazar. Doner: OTURUMID (GUID string).
//   Cancel'da OturumGeriAl(oturum), Finish'te OturumBitir(oturum) cagrilir. Acilista BOS
//   tabloya duzenlemede eklenenler de Cancel'da silinir (kapsam satiri sayesinde).
function OturumBaslat(const AAnaTabloAdi: string; AAnaID: Int64;
  const ATablolar: array of TSnapshotTablo): string;
// Cancel: acilis anina don — filtreyle mevcut satirlari sil (cocuk once), snapshot'i AYNI
// ID ile geri yaz (ust once, IDENTITY_INSERT), sonra snapshot'i temizle. Islem transaction'li.
procedure OturumGeriAl(const AOturum: string);
// Finish: oturum snapshot'ini sil (kayit kalici oldu, geri-alma gerekmez).
procedure OturumBitir(const AOturum: string);
// Config yardimcisi: tek TSnapshotTablo uretir (OturumBaslat cagrilarini sadelestirir).
function SnapTablo(ASira: SmallInt; const ATabloAdi, AFiltre: string): TSnapshotTablo;

// Program girisinde: BILINEN depo synonym'leri (EBELGE/ISLEMLOG/LOGREFERANS/...) ini'deki
// depoyu (DepoDBAdi = GENINI ANAHTAR) gostermiyorsa ona cevir. Hedef depo yoksa DOKUNMAZ.
// DepoyaGec'in "opsiyon degismezse atla" bosluğunu kapatir -> onek'siz (SP/synonym) erisim
// de her giriste dogru depoya gider. best-effort (giris akisini bozmaz).
procedure DepoSynonymDenetle;

// Program girisinde: SNAPSHOT'ta kalmis YETIM oturum kayitlarini (app cokme/anormal
// kapanis) temizle -> AGun gunden eski TARIH'liler silinir. best-effort.
procedure SnapshotEskiTemizle(AGun: Integer = 10);

// ---- Depo (log/e-belge) DB adi ----
// Depo DB adi — opsiyon Ops_FaturaOpsiyon_DepoDBAdi (default 'GENDEPO'). Log otonom
// baglantisi bu ada baglanir; ayni zamanda EBELGE* tablolari da bu DB'de.
function DepoDBAdi: string;

// Depo tablosunun TAM NITELIKLI adi: DepoDBAdi + '.dbo.' + ATablo
// (ör. DepoTablo('EBELGEMESAJ') -> 'GENDEPO.dbo.EBELGEMESAJ').
// DEPODA bulunan tablolarla (EBELGE / EBELGEMESAJ / EBELGEKUYRUK / ISLEMLOG /
// LOGREFERANS / LOGCOZUM ...) ANA baglantidan calisirken sabit 'GENDEPO' yazmak
// yerine BUNU onek olarak kullan -> depo DB adi degisince kod kirilmaz.
function DepoTablo(const ATablo: string): string;

// Depo DB adi cache'ini sifirla (ad degisince cagir; log baglantisi da yeniden acilir).
procedure DepoAdiSifirla;

// ORTAK: verilen depoya ANINDA gec - opsiyonu yaz, ana DB synonym'lerini (eski
// depoyu gosterenler) yeni depoya cevir, runtime cache'i sifirla. Kopyala sonrasi
// VE opsiyon Kaydet'te cagrilir. Yeniden baslatmaya gerek kalmadan aktif olur.
procedure DepoyaGec(const AYeniDepo: string);

// ---- DOSYA: belge/resim/medya ICERIK deposu (GENDEPO.DOSYA, FILESTREAM, hash-dedup) ----
// AStream'i DOSYA'ya kaydeder. Ayni icerik (SHA-256) zaten varsa YENIDEN EKLEMEZ ->
// mevcut satirin REFSAYAC'ini artirir ve o ID'yi doner (tekillestirme). Yeni ise ekler.
// AUzanti ('.pdf') / AMimeType opsiyonel. 0 = hata. IMAJ.DOSYAID'e bu ID yazilir.
function DosyaKaydet(AStream: TStream; const AUzanti: string = ''; const AMimeType: string = ''): Int64;
// DOSYA.ID'nin icerigini ADest stream'e yazar (pozisyon 0'a alinir). True = bulundu.
function DosyaGetir(AID: Int64; ADest: TStream): Boolean;
// Referansi azaltir; REFSAYAC 0'a inince satiri (ve FILESTREAM dosyasini) siler. (Belge silmede.)
procedure DosyaReferansAzalt(AID: Int64);
// Mevcut IMAJ satirinin ICERIGINI dosyadan okuyup DOSYA'ya (yeni/dedup) yazar, satiri
//  referansa cevirir (DOSYAID/BOYUT/ICDIS=0/BELGE=NULL; eski DOSYAID varsa ref azaltilir).
//  Dokuman DUZENLE-KAYDET (uzerine yaz) yolu icin. False = DOSYA yazilamadi -> cagiran
//  eski IMAJ.BELGE yoluna dusmeli.
function DosyaIleImajGuncelle(AImajID: Integer; const AFileName: string; const ADegistiren: string = ''): Boolean;

var
  // Ana kart islem modu: DETAY log satirlari bu moda gore ISLEMTIPI yazar
  //   -1 = kapali (detayin kendi modu: yeni->ekle, degisen->degis, silinen->sil)
  //    0 = sil, 1 = ekle, 2 = degis  (TLogIslem ile birebir)
  // Form/wizard ACILISTA set eder (yeni->1, duzenleme->2, silme->0), KAPANISTA -1.
  // Amac: tek kaydette kart + tum alt hareketler AYNI ISLEMTIPI'de -> UInfo'da tek satir
  // (ör. cari DEGIS modunda eklenen iletisim de 'degistir' loglanir, ayri 'ekleme' cikmaz).
  LogUstModu: Integer = -1;

  // Ayar (GENINI) loglama bayragi: opsiyon formu ACIK iken True. GENINI.Write* bayrak
  // aciksa degisen opsiyonu (BOLUM, eski->yeni) loglar. Form acilista True, kapanista False.
  // Amac: GENINI HER YERDEN yazildigi icin (lisans/oturum) yalniz opsiyon formundaki
  // kullanici degisiklikleri loglansin.
  LogAyarModu: Boolean = False;

  // Ayar (opsiyon) kaydet-oturumu anahtari: opsiyon formu ACILINCA (kapali->acik gecis)
  // set edilir; o form boyunca yazilan TUM opsiyon loglari bunu USTKAYITID yapar ->
  // UInfo'da tek save = TEK satirda gruplanir (KAYITID=BOLUM detay/bolum icin kalir).
  LogAyarOturum: Integer = 0;

implementation

uses
  System.SysUtils, System.SyncObjs, System.DateUtils, FireDAC.Comp.Client, Winapi.Windows,
  Utablo, PrjConst, uUtility_my,  System.Hash, UVeriMotor;

var
  GLogCnn: TFDConnection = nil;   // otonom log baglantisi (GENDEPO'ya baglanir, cache)
  GLock: TCriticalSection = nil;  // log yazimlarini seri yapar
  GIP: string = #1;               // #1 = henuz hesaplanmadi
  GDepoDBAdi: string = '';        // depo DB adi cache (INI'den 1 kez okunur)
  GIstasyon: string = #1;
  GYillar: TStringList = nil;     // bu oturumda garantilenen LOG<yyyy> tablolari

{ ---- yardimcilar ---- }

function YerelIP: string;
begin
  if GIP = #1 then
    try
      GIP := GetIPAddress;
    except
      GIP := '';
    end;
  Result := GIP;
end;

function Istasyon: string;
begin
  if GIstasyon = #1 then
    try
      GIstasyon := GetEnvironmentVariable('COMPUTERNAME');
    except
      GIstasyon := '';
    end;
  Result := GIstasyon;
end;

function DepoDBAdi: string;
begin
  // INI'den YALNIZ 1 KEZ oku, sonra cache (DepoTablo ~50 sorguda cagriliyor).
  // Ad degisirse uygulama yeniden baslatilmali (log baglantisi de cache'li).
  if GDepoDBAdi = '' then
  begin
    try
      GDepoDBAdi := Trim(Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_DepoDBAdi, 'GENDEPO'));
    except
      GDepoDBAdi := '';
    end;
    if GDepoDBAdi = '' then GDepoDBAdi := 'GENDEPO';
  end;
  Result := GDepoDBAdi;
end;

function DepoTablo(const ATablo: string): string;
begin
  if AktifVeriMotor = vmPG then
    // PG: cross-DB yok -> ayri GENDEPO yerine 'depo' SCHEMA (01_depo.sql). Ad kucuk harf.
    Result := 'depo.' + LowerCase(ATablo)
  else
    // Ad koseli parantezle kacisli (bosluk/ozel karakter guvenli); ATablo ham gecirilir.
    Result := '[' + DepoDBAdi + '].dbo.' + ATablo;
end;

function DosyaKaydet(AStream: TStream; const AUzanti: string; const AMimeType: string): Int64;
var
  LBuf, LHash: TBytes;
  LSHA: THashSHA2;
  LQ: TFDQuery;
  LTbl: string;
  LHashStream: TBytesStream;
begin
  Result := 0;
  if AStream = nil then Exit;
  try
    // Icerigi oku + SHA-256 (1-2 MB dosyalar; hash TBytes uzerinden).
    AStream.Position := 0;
    SetLength(LBuf, AStream.Size);
    if Length(LBuf) > 0 then AStream.ReadBuffer(LBuf[0], Length(LBuf));
    LSHA := THashSHA2.Create(SHA256);
    LSHA.Update(LBuf);
    LHash := LSHA.HashAsBytes;

    LTbl := DepoTablo('DOSYA');
    LQ := TFDQuery.Create(nil);
    LHashStream := TBytesStream.Create(LHash);   // HASH param'i stream ile set (AsBytes yok)
    try
      LQ.Connection := Tablo.FDCnn;
      // 1) Ayni HASH varsa REFSAYAC++ ve mevcut ID'yi don (TEKILLESTIRME).
      LQ.SQL.Text := 'UPDATE ' + LTbl +
        ' SET REFSAYAC = REFSAYAC + 1 OUTPUT INSERTED.ID WHERE HASH = :H';
      LHashStream.Position := 0;
      LQ.ParamByName('H').LoadFromStream(LHashStream, ftVarBytes);
      LQ.Open;
      if not LQ.IsEmpty then
      begin
        Result := LQ.Fields[0].AsLargeInt;
        LQ.Close;
        Exit;
      end;
      LQ.Close;
      // 2) Yok -> yeni satir (ICERIK = FILESTREAM blob).
      LQ.SQL.Text := 'INSERT INTO ' + LTbl +
        '(HASH, BOYUT, UZANTI, MIMETYPE, ICERIK) OUTPUT INSERTED.ID ' +
        'VALUES(:H, :B, :U, :M, :I)';
      LHashStream.Position := 0;
      LQ.ParamByName('H').LoadFromStream(LHashStream, ftVarBytes);
      LQ.ParamByName('B').AsLargeInt := Length(LBuf);
      LQ.ParamByName('U').DataType := ftWideString;   // NULL'da tip bilinmesin diye
      if Trim(AUzanti) = '' then LQ.ParamByName('U').Clear
        else LQ.ParamByName('U').AsString := AUzanti;
      LQ.ParamByName('M').DataType := ftWideString;
      if Trim(AMimeType) = '' then LQ.ParamByName('M').Clear
        else LQ.ParamByName('M').AsString := AMimeType;
      AStream.Position := 0;
      LQ.ParamByName('I').LoadFromStream(AStream, ftBlob);
      LQ.Open;
      if not LQ.IsEmpty then Result := LQ.Fields[0].AsLargeInt;
      LQ.Close;
    finally
      LHashStream.Free;
      LQ.Free;
    end;
  except
    Result := 0;
  end;
end;

function DosyaGetir(AID: Int64; ADest: TStream): Boolean;
var
  LQ: TFDQuery;
begin
  Result := False;
  if (AID <= 0) or (ADest = nil) then Exit;
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text := 'SELECT ICERIK FROM ' + DepoTablo('DOSYA') + ' WHERE ID = :I';
      LQ.ParamByName('I').AsLargeInt := AID;
      LQ.Open;
      if (not LQ.IsEmpty) and (not LQ.Fields[0].IsNull) then
      begin
        TBlobField(LQ.Fields[0]).SaveToStream(ADest);
        ADest.Position := 0;
        Result := True;
      end;
      LQ.Close;
    finally
      LQ.Free;
    end;
  except
    Result := False;
  end;
end;

procedure DosyaReferansAzalt(AID: Int64);
var
  LQ: TFDQuery;
  LTbl: string;
begin
  if AID <= 0 then Exit;
  try
    LTbl := DepoTablo('DOSYA');
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      // REFSAYAC-- ; 0'a inince gercek sil (FILESTREAM dosyasi da GC ile gider).
      LQ.SQL.Text :=
        'UPDATE ' + LTbl + ' SET REFSAYAC = REFSAYAC - 1 WHERE ID = :I; ' +
        'DELETE FROM ' + LTbl + ' WHERE ID = :I AND REFSAYAC <= 0;';
      LQ.ParamByName('I').AsLargeInt := AID;
      LQ.ExecSQL;
    finally
      LQ.Free;
    end;
  except
  end;
end;

function DosyaIleImajGuncelle(AImajID: Integer; const AFileName: string; const ADegistiren: string): Boolean;
var
  LFs: TFileStream;
  LDosyaID, LEskiID: Int64;
  LBoyutKB: Integer;
  LQ: TFDQuery;
  LDeg: string;
begin
  Result := False;
  if (AImajID <= 0) or (not FileExists(AFileName)) then Exit;
  try
    // 1) icerigi dosyadan oku -> DOSYA'ya (ham, hash-dedup) yaz
    LFs := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    try
      LBoyutKB := (LFs.Size + 1023) div 1024;   // IMAJ.BOYUT = KB
      LFs.Position := 0;
      LDosyaID := DosyaKaydet(LFs, LowerCase(ExtractFileExt(AFileName)), '');
    finally
      LFs.Free;
    end;
    if LDosyaID <= 0 then Exit;   // DOSYA yazilamadi -> cagiran eski IMAJ.BELGE yoluna dusmeli

    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      // 2) eski DOSYAID (ref azaltmak icin)
      LQ.SQL.Text := 'SELECT DOSYAID FROM IMAJ WHERE ID=' + IntToStr(AImajID);
      LQ.Open;
      LEskiID := 0;
      if (not LQ.IsEmpty) and (not LQ.Fields[0].IsNull) then LEskiID := LQ.Fields[0].AsLargeInt;
      LQ.Close;

      // 3) IMAJ'i yeni icerige referansla (BELGE=NULL -> gorutuleme DOSYAID'den okur)
      if Trim(ADegistiren) = '' then LDeg := 'NULL' else LDeg := ADegistiren;
      LQ.SQL.Text := 'UPDATE IMAJ SET DOSYAID=' + IntToStr(LDosyaID) +
        ', BOYUT=' + IntToStr(LBoyutKB) + ', ICDIS=0, BELGE=NULL' +
        ', DEGISTIRMETARIHI=' + DbSimdi + ', DEGISTIREN=' + LDeg +
        ' WHERE ID=' + IntToStr(AImajID);
      LQ.ExecSQL;
    finally
      LQ.Free;
    end;

    // 4) eski icerik referansini azalt. Her durumda dogru:
    //  - icerik DEGISTI (LEskiID<>LDosyaID): IMAJ artik eskiyi gostermiyor -> eski ref--
    //  - icerik AYNI (LEskiID=LDosyaID): DosyaKaydet dedup ile ref++ etmisti -> geri al (net 0)
    if LEskiID > 0 then
      DosyaReferansAzalt(LEskiID);

    Result := True;
  except
    Result := False;
  end;
end;

procedure DepoAdiSifirla;
begin
  // Cache'i bosalt -> DepoDBAdi bir dahaki cagride INI'den yeniden okur.
  GDepoDBAdi := '';
  // Otonom log baglantisi eski depoya bagli; kapat/bosalt -> LogBaglantisi yeniden acar.
  if GLogCnn <> nil then
  begin
    try
      GLogCnn.Connected := False;
    except
    end;
    FreeAndNil(GLogCnn);
  end;
end;

procedure DepoyaGec(const AYeniDepo: string);
var
  LQ: TFDQuery;
  LSyn: TStringList;
  LEski, LAd, LTbl: string;
  i, p: Integer;
begin
  if Trim(AYeniDepo) = '' then Exit;
  LEski := Trim(Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_DepoDBAdi, 'GENDEPO'));

  // 1) Opsiyonu yaz.
  Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_DepoDBAdi, Trim(AYeniDepo));

  // Ad degismediyse synonym/cache ile ugrasma.
  if not SameText(LEski, Trim(AYeniDepo)) then
  begin
    // 2) Ana DB synonym'lerini (ESKI depoyu gosterenleri) YENI depoya cevir.
    LQ := TFDQuery.Create(nil);
    LSyn := TStringList.Create;
    try
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text :=
        'SELECT name, PARSENAME(base_object_name,1) FROM sys.synonyms ' +
        'WHERE PARSENAME(base_object_name,2)=''dbo'' AND PARSENAME(base_object_name,3)=:E';
      LQ.ParamByName('E').AsString := LEski;
      LQ.Open;
      while not LQ.Eof do
      begin
        LSyn.Add(LQ.Fields[0].AsString + '|' + LQ.Fields[1].AsString);
        LQ.Next;
      end;
      LQ.Close;

      for i := 0 to LSyn.Count - 1 do
      begin
        p := Pos('|', LSyn[i]);
        LAd := Copy(LSyn[i], 1, p - 1);
        LTbl := Copy(LSyn[i], p + 1, MaxInt);
        LQ.SQL.Text :=
          'DROP SYNONYM dbo.[' + LAd + ']; ' +
          'CREATE SYNONYM dbo.[' + LAd + '] FOR [' + Trim(AYeniDepo) + '].dbo.[' + LTbl + ']';
        LQ.ExecSQL;
      end;
    finally
      LSyn.Free;
      LQ.Free;
    end;

    // 3) Runtime cache'i sifirla -> yeni depo aninda kullanilir.
    DepoAdiSifirla;
  end;
end;

procedure DepoSynonymDenetle;
var
  LQ: TFDQuery;
  LList: TStringList;
  LYeni, LAd, LTbl: string;
  i, p: Integer;
begin
  if AktifVeriMotor = vmPG then Exit;   // PG: cross-DB synonym mekanizmasi yok ('depo' schema)
  try
    LYeni := Trim(DepoDBAdi);
    if LYeni = '' then Exit;
    LQ := TFDQuery.Create(nil);
    LList := TStringList.Create;
    try
      LQ.Connection := Tablo.FDCnn;
      // Hedef depo YOKSA dokunma (var olmayan depoya synonym baglayip prefix'siz erisimi kirmayalim).
      LQ.SQL.Text := 'SELECT DB_ID(:Y)';
      LQ.ParamByName('Y').AsString := LYeni;
      LQ.Open;
      if LQ.Fields[0].IsNull then begin LQ.Close; Exit; end;
      LQ.Close;
      // BILINEN depo synonym'leri: hedefi YENI depo DEGILSE topla (eslesenlere dokunma).
      LQ.SQL.Text :=
        'SELECT name, PARSENAME(base_object_name,1) FROM sys.synonyms ' +
        'WHERE name IN (''EBELGE'',''EBELGEMESAJ'',''EBELGEKUYRUK'',''ISLEMLOG'',' +
        '''LOGREFERANS'',''LOGCOZUM'',''SNAPSHOT'',''DOSYA'') ' +
        'AND PARSENAME(base_object_name,2)=''dbo'' ' +
        'AND ISNULL(PARSENAME(base_object_name,3),'''') <> :Y';
      LQ.ParamByName('Y').AsString := LYeni;
      LQ.Open;
      while not LQ.Eof do
      begin
        LList.Add(LQ.Fields[0].AsString + '|' + LQ.Fields[1].AsString);
        LQ.Next;
      end;
      LQ.Close;
      for i := 0 to LList.Count - 1 do
      begin
        p := Pos('|', LList[i]);
        LAd := Copy(LList[i], 1, p - 1);
        LTbl := Copy(LList[i], p + 1, MaxInt);
        LQ.SQL.Text := 'DROP SYNONYM dbo.[' + LAd + ']; ' +
          'CREATE SYNONYM dbo.[' + LAd + '] FOR [' + LYeni + '].dbo.[' + LTbl + ']';
        LQ.ExecSQL;
      end;
    finally
      LList.Free;
      LQ.Free;
    end;
  except
    // giris akisini bozma; synonym senkronu best-effort.
  end;
end;

procedure SnapshotEskiTemizle(AGun: Integer = 10);
var LQ: TFDQuery;
begin
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection  := Tablo.FDCnn;
      LQ.SQL.Text := 'DELETE FROM ' + DepoTablo('SNAPSHOT') +
        ' WHERE TARIH < ' + DbGunEkle(DbSimdi, -AGun);
      LQ.ExecSQL;
    finally
      LQ.Free;
    end;
  except
    // best-effort; SNAPSHOT/depo yoksa ya da hata olursa giris akisini bozma.
  end;
end;

function LogBaglantisi: TFDConnection;
begin
  if AktifVeriMotor = vmPG then Exit(Tablo.FDCnn);  // PG: ayri GENDEPO DB yok -> ana baglanti ('depo' schema ayni DB'de)
  if GLogCnn = nil then
  begin
    // Otonom baglanti dogrudan DEPO DB'ye (GENDEPO) baglanir; yillik tablolar
    // LOG<yyyy> ve birlesim view'i ISLEMLOG orada. Params ana baglantidan
    // klonlanip Database override edilir.
    GLogCnn := TFDConnection.Create(nil);
    GLogCnn.LoginPrompt := False;
    GLogCnn.Params.Assign(Tablo.FDCnn.Params);
    GLogCnn.Params.Database := DepoDBAdi;
    GLogCnn.Params.Values['MARS_Connection'] := 'Yes';
    GLogCnn.Connected := True;
  end
  else if not GLogCnn.Connected then
    GLogCnn.Connected := True;
  Result := GLogCnn;
end;

// GENDEPO'da tum LOG<yyyy> tablolarini birlestiren ISLEMLOG view'ini (yeniden) kurar.
procedure IslemLogViewKur(ACnn: TFDConnection);
var
  LQ: TFDQuery;
  LUnion, LT: string;
  LTablolar: TStringList;
  i: Integer;
begin
  if AktifVeriMotor = vmPG then Exit;  // PG: depo.islemlog view + depo.log<yyyy> onceden var (01_depo.sql)
  LQ := TFDQuery.Create(nil);
  LTablolar := TStringList.Create;
  try
    LQ.Connection := ACnn;
    LQ.SQL.Text := 'SELECT name FROM sys.tables ' +
      'WHERE name LIKE ''LOG[0-9][0-9][0-9][0-9]'' ORDER BY name';
    LQ.Open;
    while not LQ.Eof do begin LTablolar.Add(LQ.Fields[0].AsString); LQ.Next; end;
    LQ.Close;
    if LTablolar.Count = 0 then Exit;
    LUnion := '';
    for i := 0 to LTablolar.Count - 1 do
    begin
      LT := LTablolar[i];
      // Eski LOG tablolarina REHBERID/STOKID kolonu + indeks (yoksa) ekle.
      LQ.SQL.Text := 'IF COL_LENGTH(''dbo.' + LT + ''',''REHBERID'') IS NULL' +
        ' ALTER TABLE dbo.' + LT + ' ADD REHBERID bigint NULL;';
      LQ.ExecSQL;
      LQ.SQL.Text := 'IF COL_LENGTH(''dbo.' + LT + ''',''STOKID'') IS NULL' +
        ' ALTER TABLE dbo.' + LT + ' ADD STOKID bigint NULL;';
      LQ.ExecSQL;
      // ALTISLEMTIPI: satirin GERCEK islem tipi (ISLEMTIPI grup/kart moduna override
      // edilmis olabilir; UInfo Icerik gercek tipi bundan gosterir).
      LQ.SQL.Text := 'IF COL_LENGTH(''dbo.' + LT + ''',''ALTISLEMTIPI'') IS NULL' +
        ' ALTER TABLE dbo.' + LT + ' ADD ALTISLEMTIPI tinyint NULL;';
      LQ.ExecSQL;
      LQ.SQL.Text := 'IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=''IX_' + LT +
        '_REHBER'' AND object_id=OBJECT_ID(''dbo.' + LT + ''')) CREATE INDEX IX_' + LT +
        '_REHBER ON dbo.' + LT + '(REHBERID);';
      LQ.ExecSQL;
      LQ.SQL.Text := 'IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=''IX_' + LT +
        '_STOK'' AND object_id=OBJECT_ID(''dbo.' + LT + ''')) CREATE INDEX IX_' + LT +
        '_STOK ON dbo.' + LT + '(STOKID);';
      LQ.ExecSQL;
      if LUnion <> '' then LUnion := LUnion + ' UNION ALL ';
      LUnion := LUnion +
        'SELECT ID,TARIH,IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,ALTISLEMTIPI,' +
        'USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI ' +
        'FROM dbo.' + LT;
    end;
    LQ.SQL.Text := 'CREATE OR ALTER VIEW dbo.ISLEMLOG AS ' + LUnion;
    LQ.ExecSQL;
  finally
    LTablolar.Free;
    LQ.Free;
  end;
end;

// LOG<yyyy> tablosunu (yoksa) olusturur + ISLEMLOG view'ini gunceller.
// Oturumda yil basina bir kez calisir (GYillar cache). Tablo adini doner.
function  LogYilTablosu(ACnn: TFDConnection; AYil: Integer): string;
var
  LQ: TFDQuery;
  LT: string;
begin
  LT := 'LOG' + IntToStr(AYil);
  Result := LT;
  if GYillar.IndexOf(LT) >= 0 then Exit;
  if AktifVeriMotor = vmPG then begin GYillar.Add(LT); Exit; end;  // PG: depo.log<yyyy> onceden var; DDL yok
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := ACnn;
    LQ.SQL.Text :=
      'IF OBJECT_ID(''dbo.' + LT + ''',''U'') IS NULL BEGIN ' +
      'CREATE TABLE dbo.' + LT + '(' +
      ' ID bigint IDENTITY(1,1) NOT NULL,' +
      ' TARIH datetime2(0) NOT NULL CONSTRAINT DF_' + LT + '_TARIH DEFAULT(SYSDATETIME()),' +
      ' IP varchar(45) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,' +
      ' ISTASYON varchar(64) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL, KULLANICIID int NULL,' +
      ' SUBEID smallint NULL, ISLEMTIPI tinyint NOT NULL, ALTISLEMTIPI tinyint NULL,' +
      ' USTTABLOID int NULL, USTKAYITID bigint NULL,' +
      ' TABLOID int NULL, KAYITID bigint NULL,' +
      ' REHBERID bigint NULL, STOKID bigint NULL,' +   // varlik baglantisi (cari/stok)
      ' BILGI varbinary(max) NULL,' +
      ' CONSTRAINT PK_' + LT + ' PRIMARY KEY CLUSTERED (ID));' +
      ' CREATE INDEX IX_' + LT + '_UST ON dbo.' + LT + '(USTTABLOID,USTKAYITID);' +
      ' CREATE INDEX IX_' + LT + '_KAYIT ON dbo.' + LT + '(TABLOID,KAYITID);' +
      ' CREATE INDEX IX_' + LT + '_REHBER ON dbo.' + LT + '(REHBERID);' +
      ' CREATE INDEX IX_' + LT + '_STOK ON dbo.' + LT + '(STOKID);' +
      ' CREATE INDEX IX_' + LT + '_TARIH ON dbo.' + LT + '(TARIH); END';
    LQ.ExecSQL;
  finally
    LQ.Free;
  end;
  IslemLogViewKur(ACnn);   // yeni yil tablosu view'e dahil edilsin
  GYillar.Add(LT);         // view kurulumu BASARILIYSA cache'le (yoksa tekrar denenir)
end;

{ TLogKurucu }

constructor TLogKurucu.Create;
begin
  inherited Create;
  FObj := TJSONObject.Create;
end;

destructor TLogKurucu.Destroy;
begin
  FObj.Free;
  inherited;
end;

class function TLogKurucu.Yeni: TLogKurucu;
begin
  Result := TLogKurucu.Create;
end;

function TLogKurucu.Alan(const AAd, AEski, AYeni: string): TLogKurucu;
begin
  Result := Self;
  if AEski = AYeni then Exit;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', AEski)
    .AddPair('y', AYeni));
end;

function TLogKurucu.Alan(const AAd: string; AEski, AYeni: Int64): TLogKurucu;
begin
  Result := Self;
  if AEski = AYeni then Exit;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', TJSONNumber.Create(AEski))
    .AddPair('y', TJSONNumber.Create(AYeni)));
end;

function TLogKurucu.Alan(const AAd: string; AEski, AYeni: Currency): TLogKurucu;
var
  LE, LY: Double;  // Currency -> Double deger donusumu (TJSONNumber ambiguity'sini onler)
begin
  Result := Self;
  if AEski = AYeni then Exit;
  LE := AEski; LY := AYeni;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', TJSONNumber.Create(LE))
    .AddPair('y', TJSONNumber.Create(LY)));
end;

function TLogKurucu.Alan(const AAd: string; AEski, AYeni: Double): TLogKurucu;
begin
  Result := Self;
  if AEski = AYeni then Exit;
  FObj.AddPair(AAd, TJSONObject.Create
    .AddPair('e', TJSONNumber.Create(AEski))
    .AddPair('y', TJSONNumber.Create(AYeni)));
end;

function TLogKurucu.Deger(const AAd, ADeger: string): TLogKurucu;
begin
  Result := Self;
  FObj.AddPair(AAd, ADeger);
end;

function TLogKurucu.Deger(const AAd: string; ADeger: Int64): TLogKurucu;
begin
  Result := Self;
  FObj.AddPair(AAd, TJSONNumber.Create(ADeger));
end;

function TLogKurucu.Deger(const AAd: string; ADeger: Currency): TLogKurucu;
var
  LD: Double;  // Currency -> Double deger donusumu
begin
  Result := Self;
  LD := ADeger;
  FObj.AddPair(AAd, TJSONNumber.Create(LD));
end;

function TLogKurucu.BosMu: Boolean;
begin
  Result := FObj.Count = 0;
end;

function TLogKurucu.JSON: string;
begin
  Result := FObj.ToString;
end;

{ LogYaz }

procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  const ABilgiJSON: string; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0);
var
  LQ: TFDQuery;
  LCnn: TFDConnection;
  LBilgiVar: Boolean;
  LTablo: string;
  LUstT: Integer;
  LUstK: Int64;
  LIslem: TLogIslem;
begin
  // Loglama hicbir kosulda uygulamayi kirmaz/yavaslamaz.
  try
    // Ust (master) verilmediyse kendisidir (baslik kendi kaydi). Detay satirda
    // cagiran USTTABLOID/USTKAYITID = master (ör. FATBASLIK) gecirir; boylece
    // master+detay loglari birlikte sorgulanabilir.
    LUstT := AUstTabloID; if LUstT = 0 then LUstT := ATabloID;
    LUstK := AUstKayitID; if LUstK = 0 then LUstK := AKayitID;
    // ISLEMTIPI: DETAY satiri (master kendisi degil) + ana kart modu set edilmisse,
    // detayin kendi tipi yerine ANA KARTIN modunu izler -> kart+detaylar tek grup.
    // Kart (master) satiri kendi modunu korur (LogKartEkle/Degisti/Sil zaten dogru verir).
    LIslem := AIslemTipi;
    if (LogUstModu >= 0) and ((LUstT <> ATabloID) or (LUstK <> AKayitID)) then
      LIslem := TLogIslem(LogUstModu);
    // Varlik anahtari verilmediyse KART tipinden turet: cari/IK (71/73/74) ve stok(88)
    // kartinin KENDISI -> KAYITID; altindaki DETAY -> USTKAYITID. Boylece bir cari/IK
    // personelinin (REHBER) veya stokun TUM loglari REHBERID/STOKID ile bulunur.
    if AREHBERID <= 0 then
    begin
      if (ATabloID = TabNo_REHBER) or (ATabloID = TabNo_IK) or (ATabloID = TabNo_IK_POTANSIYEL) then
        AREHBERID := AKayitID
      else if (LUstT = TabNo_REHBER) or (LUstT = TabNo_IK) or (LUstT = TabNo_IK_POTANSIYEL) then
        AREHBERID := LUstK;
    end;
    if ASTOKID <= 0 then
    begin
      if ATabloID = TabNo_STOKLAR then ASTOKID := AKayitID
      else if LUstT = TabNo_STOKLAR then ASTOKID := LUstK;
    end;
    GLock.Enter;
    try
      LCnn := LogBaglantisi;
      LTablo := LogYilTablosu(LCnn, YearOf(Now));   // yila gore LOG<yyyy>
      LBilgiVar := Trim(ABilgiJSON) <> '';
      LQ := TFDQuery.Create(nil);
      try
        LQ.Connection := LCnn;
        // MODUL log tablolarinda TUTULMAZ; TABLOID -> TABLOLAR.MODUL ile alinir.
        // AModul param'i geriye uyumluluk icin durur (yazilmaz).
        if LBilgiVar then
          LQ.SQL.Text :=
             'INSERT INTO ' + DepoTablo(LTablo) + '(IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,ALTISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI) ' +
             'VALUES(:IP,:IST,:KUL,:SUB,:IT,:AIT,:UTID,:UKYT,:TID,:KYT, NULLIF(:REH,0), NULLIF(:STK,0), ' + DbLogBilgiYaz(':BILGI') + ')'
        else
           LQ.SQL.Text :=
            'INSERT INTO ' + DepoTablo(LTablo) + '(IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,ALTISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID) ' +
            'VALUES(:IP,:IST,:KUL,:SUB,:IT,:AIT,:UTID,:UKYT,:TID,:KYT, NULLIF(:REH,0), NULLIF(:STK,0))';
        LQ.ParamByName('IP').AsString  := Copy(YerelIP, 1, 45);
        LQ.ParamByName('IST').AsString := Copy(Istasyon, 1, 64);
        LQ.ParamByName('KUL').AsInteger := StrToIntDef(Trim(Kullanan), 0);
        LQ.ParamByName('SUB').AsInteger := StrToIntDef(Trim(SubeIDYazi), 0);
        LQ.ParamByName('IT').AsInteger := Ord(LIslem);        // ISLEMTIPI = grup/kart modu (override edilmis olabilir)
        LQ.ParamByName('AIT').AsInteger := Ord(AIslemTipi);   // ALTISLEMTIPI = satirin GERCEK tipi
        LQ.ParamByName('UTID').AsInteger := LUstT;
        LQ.ParamByName('UKYT').AsLargeInt := LUstK;
        LQ.ParamByName('TID').AsInteger := ATabloID;
        LQ.ParamByName('KYT').AsLargeInt := AKayitID;
        LQ.ParamByName('REH').AsLargeInt := AREHBERID;
        LQ.ParamByName('STK').AsLargeInt := ASTOKID;
        if LBilgiVar then
        begin
          LQ.ParamByName('BILGI').DataType := ftWideMemo;
          LQ.ParamByName('BILGI').AsWideMemo := ABilgiJSON;
        end;
        LQ.ExecSQL;
      finally
        LQ.Free;
      end;
    finally
      GLock.Leave;
    end;
  except
    // yut: loglama hatasi is akisini etkilemesin
  end;
end;

// Kaydin cari/stok anahtarlarini alanlarindan cikarir (REHBERID/CARIID, STOKID/URUNID).
procedure LogVarlikIDleri(ADataSet: TDataSet; out ARehberID, AStokID: Int64);
  function AlanID(const AAlanlar: array of string): Int64;
  var i: Integer; F: TField;
  begin
    Result := 0;
    if ADataSet = nil then Exit;
    for i := 0 to High(AAlanlar) do
    begin
      F := ADataSet.FindField(AAlanlar[i]);
      if (F <> nil) and (not F.IsNull) and (F.AsLargeInt > 0) then
        Exit(F.AsLargeInt);
    end;
  end;
begin
  ARehberID := AlanID(['REHBERID', 'CARIID']);
  AStokID   := AlanID(['STOKID', 'URUNID']);
end;

// AD/KOD'u oncelikli alan listelerinden cikarir; GENDEPO.LOGREFERANS'a upsert eder.
procedure LogReferansGuncelle(ADataSet: TDataSet; ATabloID: Integer; AKayitID: Int64;
  ASilindi: Boolean);

  function IlkDolu(const AAlanlar: array of string): string;
  var i: Integer; F: TField;
  begin
    Result := '';
    if ADataSet = nil then Exit;
    for i := 0 to High(AAlanlar) do
    begin
      F := ADataSet.FindField(AAlanlar[i]);
      if (F <> nil) and (Trim(F.AsString) <> '') then
        Exit(Trim(F.AsString));
    end;
  end;

var
  LQ: TFDQuery;
  LCnn: TFDConnection;
  LAd, LKod: string;
begin
  try
    // ADI/KODU -> POS, Kredi Karti; HESAPADI/HESAPKODU -> Banka; KREDIKODU -> Krediler;
    // BORCLU/SERINO -> Cek/Senet; KASAADI/KASAKODU -> Kasa tanimi.
    // (IlkDolu var olmayan alani atlar -> fazla aday zararsiz.)
    LAd  := Copy(IlkDolu(['FIRMA','STOKADI','ADI','ADSOYAD','KONUSU','PROJEADI',
                          'ACIKLAMA','TANIM','UNVAN','ISIM','HESAPADI','BANKAADI',
                          'BORCLU','KASAADI','DEPOADI','AD']), 1, 200);
    LKod := Copy(IlkDolu(['KOD','STOKKOD','KODU','CARIKOD','HESAPKODU','HESAPNO',
                          'KREDIKODU','SERINO','KASAKODU']), 1, 60);
    if (LAd = '') and (LKod = '') then Exit;   // referanslanacak ad/kod yok
    GLock.Enter;
    try
      LCnn := LogBaglantisi;
      LQ := TFDQuery.Create(nil);
      try
        LQ.Connection := LCnn;
        // Son satirin AD/KOD/SILINDI'sini al. DEGISMISSE YENI SATIR ekle -> eski isim
        // korunur (isim gecmisi); eski isimle de arama yapilabilir.
        LQ.SQL.Text := 'SELECT ' + DbUst(1) + 'AD, KOD, SILINDI FROM ' + DepoTablo('LOGREFERANS') +
                       ' WHERE TABLOID=:TID AND KAYITID=:KYT ORDER BY ID DESC ' + DbSinir(1);
        LQ.ParamByName('TID').AsInteger  := ATabloID;
        LQ.ParamByName('KYT').AsLargeInt := AKayitID;
        LQ.Open;
        var LAyni: Boolean := (not LQ.IsEmpty)
                          and (LQ.FieldByName('AD').AsString = LAd)
                          and (LQ.FieldByName('KOD').AsString = LKod)
                          and (LQ.FieldByName('SILINDI').AsBoolean = ASilindi);
        LQ.Close;
        if LAyni then Exit;   // ad/kod/silindi degismemis -> yeni satir gerekmez
        LQ.SQL.Text :=
          'INSERT INTO ' + DepoTablo('LOGREFERANS') + '(TABLOID,KAYITID,AD,KOD,SILINDI,SONISLEM)' +
          ' VALUES(:TID,:KYT,:AD,:KOD,:SIL,' + DbSimdi + ')';
        LQ.ParamByName('TID').AsInteger  := ATabloID;
        LQ.ParamByName('KYT').AsLargeInt := AKayitID;
        LQ.ParamByName('AD').AsString    := LAd;
        LQ.ParamByName('KOD').AsString   := LKod;
        LQ.ParamByName('SIL').AsInteger  := Ord(ASilindi);
        LQ.ExecSQL;
      finally
        LQ.Free;
      end;
    finally
      GLock.Leave;
    end;
  except
    // yut
  end;
end;

procedure LogYaz(AIslemTipi: TLogIslem; ATabloID: Integer; AKayitID: Int64;
  AKurucu: TLogKurucu; const AModul: string = '';
  AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0;
  AREHBERID: Int64 = 0; ASTOKID: Int64 = 0);
var
  LJSON: string;
begin
  try
    if AKurucu = nil then
      LJSON := ''
    else if AKurucu.BosMu then
      LJSON := ''
    else
      LJSON := AKurucu.JSON;
    LogYaz(AIslemTipi, ATabloID, AKayitID, LJSON, AModul, AUstTabloID, AUstKayitID,
           AREHBERID, ASTOKID);
  finally
    AKurucu.Free;  // sahipligi aldik
  end;
end;

procedure LogSnapshotAl(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>);
var
  LBM: TBookmark;
  LSL: TStringList;
  i: Integer;
begin
  if ASnap = nil then Exit;
  ASnap.Clear;
  if (ADataSet = nil) or (not ADataSet.Active) then Exit;
  ADataSet.DisableControls;
  try
    LBM := ADataSet.Bookmark;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        LSL := TStringList.Create;
        for i := 0 to ADataSet.FieldCount - 1 do
          LSL.Add(ADataSet.Fields[i].AsString);
        ASnap.AddOrSetValue(ADataSet.FieldByName('ID').AsInteger, LSL);
        ADataSet.Next;
      end;
    finally
      if ADataSet.BookmarkValid(LBM) then ADataSet.Bookmark := LBM;
    end;
  finally
    ADataSet.EnableControls;
  end;
end;

procedure LogDiffKaydet(ADataSet: TDataSet;
  ASnap: TObjectDictionary<Integer, TStringList>;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64);
var
  i, LID: Integer;
  LSnap: TStringList;
  LK: TLogKurucu;
  LGorulen: TList<Integer>;
  LPair: TPair<Integer, TStringList>;
  LBM: TBookmark;
  LReh, LStk: Int64;

  // Mevcut satirin tum dolu fkData alanlarini deger olarak iceren kurucu (ekle/sil).
  function DoluAlanlar(ASL: TStringList): TLogKurucu;
  var j: Integer;
  begin
    Result := TLogKurucu.Yeni;
    for j := 0 to ADataSet.FieldCount - 1 do
      if (ADataSet.Fields[j].FieldKind = fkData) and
         (ADataSet.Fields[j].DataType <> ftBlob) and
         (ADataSet.Fields[j].DataType <> ftMemo) then
      begin
        if ASL <> nil then      // snapshot degeri (silinen satir)
        begin
          if (j < ASL.Count) and (Trim(ASL[j]) <> '') then
            Result.Deger(ADataSet.Fields[j].FieldName, ASL[j]);
        end
        else if Trim(ADataSet.Fields[j].AsString) <> '' then   // mevcut satir (ekleme)
          Result.Deger(ADataSet.Fields[j].FieldName, ADataSet.Fields[j].AsString);
      end;
  end;

begin
  if (ASnap = nil) or (ADataSet = nil) or (not ADataSet.Active) then Exit;
  try
    LGorulen := TList<Integer>.Create;
    try
      ADataSet.DisableControls;
      try
        LBM := ADataSet.Bookmark;
        try
          ADataSet.First;
          while not ADataSet.Eof do
          begin
            LID := ADataSet.FieldByName('ID').AsInteger;
            LGorulen.Add(LID);
            LogVarlikIDleri(ADataSet, LReh, LStk);   // satirin cari/stok anahtarlari
            if ASnap.TryGetValue(LID, LSnap) then
            begin
              // Mevcut satir snapshot'ta var -> degisen alanlar
              LK := TLogKurucu.Yeni;
              for i := 0 to ADataSet.FieldCount - 1 do
                if (ADataSet.Fields[i].FieldKind = fkData) and
                   (ADataSet.Fields[i].DataType <> ftBlob) and
                   (ADataSet.Fields[i].DataType <> ftMemo) and
                   (i < LSnap.Count) and
                   (ADataSet.Fields[i].AsString <> LSnap[i]) then
                  LK.Alan(ADataSet.Fields[i].FieldName, LSnap[i],
                          ADataSet.Fields[i].AsString);
              if not LK.BosMu then
                LogYaz(liDegistir, ADetayTabNo, LID, LK, '', AUstTabNo, AUstID, LReh, LStk)
              else
                LK.Free;
            end
            else
              // snapshot'ta yok -> yeni satir -> EKLEME
              LogYaz(liEkle, ADetayTabNo, LID, DoluAlanlar(nil), '', AUstTabNo, AUstID, LReh, LStk);
            ADataSet.Next;
          end;
        finally
          if ADataSet.BookmarkValid(LBM) then ADataSet.Bookmark := LBM;
        end;
      finally
        ADataSet.EnableControls;
      end;

      // Snapshot'ta olup mevcutta olmayan -> SILME
      for LPair in ASnap do
        if LGorulen.IndexOf(LPair.Key) < 0 then
          LogYaz(liSil, ADetayTabNo, LPair.Key, DoluAlanlar(LPair.Value),
                 '', AUstTabNo, AUstID);
    finally
      LGorulen.Free;
    end;
  except
    // loglama kaydetmeyi bozmaz
  end;
end;

procedure LogKayitEkle(ADataSet: TDataSet; ATabNo: Integer; AID: Int64;
  AUstTabNo: Integer = 0; AUstID: Int64 = 0);
var
  LK: TLogKurucu;
  i: Integer;
  LReh, LStk: Int64;
begin
  if (ADataSet = nil) or (not ADataSet.Active) then Exit;
  try
    LK := TLogKurucu.Yeni;
    for i := 0 to ADataSet.FieldCount - 1 do
      if (ADataSet.Fields[i].FieldKind = fkData) and
         (ADataSet.Fields[i].DataType <> ftBlob) and
         (ADataSet.Fields[i].DataType <> ftMemo) and
         (Trim(ADataSet.Fields[i].AsString) <> '') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'DEGISTIREN') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'DEGISTIRMETARIHI') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'EKLEYEN') and
         (UpperCase(ADataSet.Fields[i].FieldName) <> 'EKLEMETARIHI') then
        LK.Deger(ADataSet.Fields[i].FieldName, ADataSet.Fields[i].AsString);
    LogVarlikIDleri(ADataSet, LReh, LStk);   // cari/stok anahtarlari
    LogYaz(liEkle, ATabNo, AID, LK, '', AUstTabNo, AUstID, LReh, LStk);
    // Master (kart) ise LOGREFERANS'a upsert (hizli ad/kod arama).
    if (AUstTabNo = 0) or ((AUstTabNo = ATabNo) and (AUstID = AID)) then
      LogReferansGuncelle(ADataSet, ATabNo, AID, False);
  except
  end;
end;

procedure LogEBelgeIslem(ATabloID: Integer; AFaturaID: Int64; const AIslem: string; AREHBERID: Int64 = 0);
begin
  if LogGun <= 0 then Exit;
  try
    LogYaz(liDegistir, ATabloID, AFaturaID,
      TLogKurucu.Yeni.Deger('E-Belge İşlemi', AIslem), 'E-Belge', 0, 0, AREHBERID);
  except
  end;
end;

procedure LogSistemIslem(const AIslem: string);
begin
  if LogGun <= 0 then Exit;
  try
    LogYaz(liEkle, TabNo_SISTEM, 0, TLogKurucu.Yeni.Deger('İşlem', AIslem), 'Sistem');
  except
  end;
end;

procedure LogDetaylariSil(const ADetayTablo, AUstKolon: string;
  ADetayTabNo, AUstTabNo: Integer; AUstID: Int64; const AEkKosul: string = '');
var
  LQ: TFDQuery;
  LK: TLogKurucu;
  i: Integer;
  LReh, LStk: Int64;
begin
  if (LogGun <= 0) or (Trim(ADetayTablo) = '') then Exit;
  try
    LQ := TFDQuery.Create(nil);
    try
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text := 'select * from ' + ADetayTablo + ' where ' + AUstKolon + ' = ' + IntToStr(AUstID);
      if Trim(AEkKosul) <> '' then
        LQ.SQL.Text := LQ.SQL.Text + ' and (' + AEkKosul + ')';
      LQ.Open;
      while not LQ.Eof do
      begin
        LK := TLogKurucu.Yeni;
        for i := 0 to LQ.FieldCount - 1 do
          if (LQ.Fields[i].FieldKind = fkData) and
             (LQ.Fields[i].DataType <> ftBlob) and (LQ.Fields[i].DataType <> ftMemo) and
             (Trim(LQ.Fields[i].AsString) <> '') then
            LK.Deger(LQ.Fields[i].FieldName, LQ.Fields[i].AsString);
        LogVarlikIDleri(LQ, LReh, LStk);
        LogYaz(liSil, ADetayTabNo, LQ.FieldByName('ID').AsLargeInt, LK, '',
               AUstTabNo, AUstID, LReh, LStk);   // LK sahipligi LogYaz'a gecer
        LQ.Next;
      end;
    finally
      LQ.Free;
    end;
  except
    // loglama silme islemini ASLA bozmaz
  end;
end;

{ ---- KART loglama kisayollari ---- }

function LogKartEkle(ADataSet: TDataSet; ATabNo: Integer;
  AEklemeModu, AZatenLogland: Boolean): Boolean;
var
  LID: Integer;
begin
  Result := False;
  if (LogGun <= 0) or (not AEklemeModu) or AZatenLogland then Exit;
  try
    if (ADataSet <> nil) and ADataSet.Active and (ADataSet.State = dsBrowse) and
       (ADataSet.FindField('ID') <> nil) then
    begin
      LID := ADataSet.FieldByName('ID').AsInteger;
      if LID > 0 then
      begin
        LogKayitEkle(ADataSet, ATabNo, LID, ATabNo, LID);
        Result := True;
      end;
    end;
  except
    // loglama is akisini ASLA bozmaz
  end;
end;

procedure LogKartDegisti(ADataSet: TDataSet; ATabNo, AKayitID: Integer;
  AUstTabNo: Integer; AUstID: Int64);
begin
  if LogGun <= 0 then Exit;
  try
    Tablo.LogIslemleri(ATabNo, AKayitID, 4, ADataSet, AUstTabNo, AUstID);
  except
  end;
end;

procedure LogKartSil(ADataSet: TDataSet; ATabNo, AKayitID: Integer;
  AUstTabNo: Integer; AUstID: Int64);
begin
  if LogGun <= 0 then Exit;
  try
    Tablo.OncekiLogBelirle(ADataSet);
    Tablo.LogIslemleri(ATabNo, AKayitID, 5, ADataSet, AUstTabNo, AUstID);
  except
  end;
end;

procedure LogDetaySatirPost(ADataSet: TDataSet; ADetayTabNo, AUstTabNo: Integer;
  AUstID: Int64);
var
  LID: Integer;
begin
  if LogGun <= 0 then Exit;
  try
    if (ADataSet = nil) or (ADataSet.FindField('ID') = nil) then Exit;
    LID := ADataSet.FieldByName('ID').AsInteger;
    if LogOnceki.Count > 0 then   // duzenleme (BeforeEdit OncekiLog'u doldurdu)
      Tablo.LogIslemleri(ADetayTabNo, LID, 4, ADataSet, AUstTabNo, AUstID)
    else                                // yeni satir -> EKLEME
      LogKayitEkle(ADataSet, ADetayTabNo, LID, AUstTabNo, AUstID);
  except
  end;
end;

{ ---- Geri Al (silinen kaydi dirilt) ---- }

type
  TGeriKayit = record
    TabloID: Integer;
    KayitID: Int64;
    JSON: string;
  end;

// ANA DB'de TABLOID -> fiziksel tablo adi (TABLOLAR). Bulunamazsa ''.
function GeriTabloAdiGetir(ATabloID: Integer): string;
var LQ: TFDQuery;
begin
  Result := '';
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text := 'SELECT TABLOADI FROM TABLOLAR WHERE TABLOID=:t';
    LQ.ParamByName('t').AsInteger := ATabloID;
    LQ.Open;
    if not LQ.IsEmpty then Result := Trim(LQ.Fields[0].AsString);
  finally
    LQ.Free;
  end;
end;

// ANA DB: <ATablo>'da ID=AID kaydi var mi? (cakisma / mukerrer kontrolu)
function GeriKayitVarMi(const ATablo: string; AID: Int64): Boolean;
var LQ: TFDQuery;
begin
  Result := False;
  if Trim(ATablo) = '' then Exit;
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text := 'SELECT 1 FROM ' + ATablo + ' WHERE ID=:id';
    LQ.ParamByName('id').AsLargeInt := AID;
    LQ.Open;
    Result := not LQ.IsEmpty;
  finally
    LQ.Free;
  end;
end;

// Tablonun IDENTITY kolonu var mi? (IDENTITY_INSERT sadece varsa acilir)
function GeriIdentityVarMi(const ATablo: string): Boolean;
var LQ: TFDQuery;
begin
  Result := False;
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text := 'SELECT OBJECTPROPERTY(OBJECT_ID(:t), ''TableHasIdentity'')';
    LQ.ParamByName('t').AsString := ATablo;
    LQ.Open;
    if (not LQ.IsEmpty) and (not LQ.Fields[0].IsNull) then
      Result := LQ.Fields[0].AsInteger = 1;
  finally
    LQ.Free;
  end;
end;

// JSON degerini duz string'e cevirir (silme JSON'unda degerler string tutulur ama
// sayi/bool da gelebilir). Nesne/dizi beklenmez (duz key-value).
function GeriJsonDeger(V: TJSONValue): string;
begin
  if V = nil then
    Result := ''
  else if V is TJSONString then
    Result := TJSONString(V).Value
  else if (V is TJSONNumber) or (V is TJSONBool) then
    Result := V.Value
  else
    Result := V.ToString;
end;

// Tek bir kaydi (JSON alanlari) ATabloAdi'na AYNI ID ile ekler. Format-guvenli
// (TField.AsString -> kultur-aware). Sonuc: '' = basari, aksi halde hata mesaji.
function GeriKayitEkle(const ATabloAdi, AJSON: string): string;
var
  LQ, LIns: TFDQuery;
  LParsed: TJSONValue;
  LObj: TJSONObject;
  LPair: TJSONPair;
  F: TField;
  LDeger, LCols, LVals: string;
  LKolonlar: TStringList;
  i: Integer;
  LIdentity, LIdentityAcik: Boolean;
begin
  Result := '';
  LIdentityAcik := False;
  LParsed := nil;
  LKolonlar := TStringList.Create;
  LQ := TFDQuery.Create(nil);
  LIns := TFDQuery.Create(nil);
  try
    try
      LParsed := TJSONObject.ParseJSONValue(AJSON);
      if not (LParsed is TJSONObject) then
        Exit('JSON cozumlenemedi.');
      LObj := TJSONObject(LParsed);

      // 1) Bos sablon dataset -> JSON degerlerini kultur-aware (Turkce ondalik/tarih) TField'a
      //    parse etmek icin. (Insert BU dataset'le YAPILMAZ; FireDAC identity kolonu INSERT'e
      //    almiyor -> asagida dinamik INSERT ile ID dahil acikca yazilir.)
      LQ.Connection := Tablo.FDCnn;
      LQ.SQL.Text := 'SELECT * FROM ' + ATabloAdi + ' WHERE 1=0';
      LQ.Open;
      F := LQ.FindField('ID');
      if F <> nil then begin F.ReadOnly := False; F.Required := False; end;
      LQ.Append;
      for LPair in LObj do
      begin
        F := LQ.FindField(LPair.JsonString.Value);   // computed/olmayan kolon -> nil, atla
        if F = nil then Continue;
        if F.ReadOnly then Continue;                 // computed/salt-okunur -> atla
        LDeger := GeriJsonDeger(LPair.JsonValue);
        if Trim(LDeger) = '' then F.Clear else F.AsString := LDeger;
        LKolonlar.Add(F.FieldName);
      end;

      if LKolonlar.Count = 0 then Exit('Yazilacak alan yok.');

      // 2) Dinamik INSERT (ID dahil tum eslenen kolonlar acikca) - param degerleri
      //    LQ.FieldByName().Value uzerinden (dogru tip, format-guvenli).
      LCols := ''; LVals := '';
      for i := 0 to LKolonlar.Count - 1 do
      begin
        if LCols <> '' then begin LCols := LCols + ','; LVals := LVals + ','; end;
        LCols := LCols + '[' + LKolonlar[i] + ']';
        LVals := LVals + ':P' + IntToStr(i);
      end;
      LIns.Connection := Tablo.FDCnn;
      LIns.SQL.Text := 'INSERT INTO ' + ATabloAdi + ' (' + LCols + ') VALUES (' + LVals + ')';
      for i := 0 to LKolonlar.Count - 1 do
      begin
        F := LQ.FieldByName(LKolonlar[i]);
        // Param tipini alandan ver (NULL degerde de belli olsun -> 'data type unknown' engeli).
        if F.DataType = ftAutoInc then
          LIns.Params[i].DataType := ftLargeint
        else
          LIns.Params[i].DataType := F.DataType;
        if F.IsNull then
          LIns.Params[i].Clear
        else
          LIns.Params[i].Value := F.Value;
      end;

      LIdentity := GeriIdentityVarMi(ATabloAdi);
      if LIdentity then
      begin
        Tablo.FDCnn.ExecSQL('SET IDENTITY_INSERT ' + ATabloAdi + ' ON');
        LIdentityAcik := True;
      end;
      LIns.ExecSQL;
    except
      on E: Exception do
      begin
        try if LQ.State in [dsInsert, dsEdit] then LQ.Cancel; except end;
        Result := E.Message;
      end;
    end;
  finally
    if LIdentityAcik then
      try Tablo.FDCnn.ExecSQL('SET IDENTITY_INSERT ' + ATabloAdi + ' OFF'); except end;
    LQ.Free;
    LIns.Free;
    LKolonlar.Free;
    if LParsed <> nil then LParsed.Free;
  end;
end;

// ==== GERI-ALINABILIR OTURUM (SNAPSHOT depo tablosu; Cancel=geri yukle, Finish=sil) ====

function SnapTablo(ASira: SmallInt; const ATabloAdi, AFiltre: string): TSnapshotTablo;
begin
  Result.Sira := ASira;
  Result.TabloAdi := ATabloAdi;
  Result.Filtre := AFiltre;
end;

procedure OturumBitir(const AOturum: string);
var LQ: TFDQuery;
begin
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := Tablo.FDCnn;
    LQ.SQL.Text := 'DELETE FROM ' + DepoTablo('SNAPSHOT') + ' WHERE OTURUMID=:O';
    LQ.ParamByName('O').AsString := AOturum;
    LQ.ExecSQL;
  finally
    LQ.Free;
  end;
end;

function OturumBaslat(const AAnaTabloAdi: string; AAnaID: Int64;
  const ATablolar: array of TSnapshotTablo): string;
var
  LGuid: TGUID;
  LSnap, LJson: string;
  i, j: Integer;
  LRowQ, LInsQ: TFDQuery;
  LK: TLogKurucu;

  procedure ParamlariYaz(AKapsam: Boolean);
  begin
    LInsQ.ParamByName('O').AsString  := Result;
    LInsQ.ParamByName('AT').AsString := AAnaTabloAdi;
    LInsQ.ParamByName('AI').AsLargeInt := AAnaID;
    LInsQ.ParamByName('S').AsInteger := ATablolar[i].Sira;
    LInsQ.ParamByName('T').AsString  := ATablolar[i].TabloAdi;
    LInsQ.ParamByName('F').AsString  := ATablolar[i].Filtre;
    if AKapsam then
    begin
      LInsQ.ParamByName('K').Clear;
      LInsQ.ParamByName('J').Clear;
    end
    else
    begin
      LInsQ.ParamByName('K').AsLargeInt := LRowQ.FieldByName('ID').AsLargeInt;
      LInsQ.ParamByName('J').AsWideMemo := LJson;   // ftWideMemo (AsString tipi degistirir -> reprepare hatasi)
    end;
  end;

begin
  CreateGUID(LGuid);
  Result := Copy(GUIDToString(LGuid), 2, 36);   // suslu parantezsiz 36 hane
  LSnap := DepoTablo('SNAPSHOT');
  LRowQ := TFDQuery.Create(nil);
  LInsQ := TFDQuery.Create(nil);
  try
    LRowQ.Connection := Tablo.FDCnn;
    LInsQ.Connection := Tablo.FDCnn;
    LInsQ.SQL.Text :=
      'INSERT INTO ' + LSnap +
      '(OTURUMID,ANATABLOADI,ANAID,SIRA,TABLOADI,FILTRE,KAYITID,SATIRJSON) ' +
      'VALUES(:O,:AT,:AI,:S,:T,:F,:K,:J)';
    // NULL gelebilen K/J param tiplerini acikca ver (cross-DB describe garantisi yok ->
    // "data type unknown" engeli).
    LInsQ.ParamByName('K').DataType := ftLargeint;
    LInsQ.ParamByName('J').DataType := ftWideMemo;
    for i := 0 to High(ATablolar) do
    begin
      // Tablo-basina KORUMALI: bir tablo snapshot'lanamazsa (ID PK yok / tablo yok / izin)
      // ATLA, digerlerini bozma. Once VERI (ID erisimi burada) -> hata olursa kapsam da yazilmaz
      // (yarim kapsam -> OturumGeriAl'da yanlis silme onlenir).
      try
        LRowQ.SQL.Text := 'SELECT * FROM ' + ATablolar[i].TabloAdi + ' WHERE ' + ATablolar[i].Filtre;
        LRowQ.Open;
        while not LRowQ.Eof do
        begin
          LK := TLogKurucu.Yeni;
          try
            for j := 0 to LRowQ.FieldCount - 1 do
              if (LRowQ.Fields[j].FieldKind = fkData) and
                 (LRowQ.Fields[j].DataType <> ftBlob) then
                LK.Deger(LRowQ.Fields[j].FieldName, LRowQ.Fields[j].AsString);
            LJson := LK.JSON;
          finally
            LK.Free;
          end;
          ParamlariYaz(False);   // KAYITID = LRowQ.ID (yoksa burada hata -> tablo atlanir)
          LInsQ.ExecSQL;
          LRowQ.Next;
        end;
        LRowQ.Close;
        // Kapsam satiri (veri OK -> tablo kapsamda; acilista bos tabloya eklenenleri silmek icin).
        ParamlariYaz(True);
        LInsQ.ExecSQL;
      except
        try if LRowQ.Active then LRowQ.Close; except end;   // bu tabloyu atla, devam.
      end;
    end;
  finally
    LRowQ.Free;
    LInsQ.Free;
  end;
end;

// Snapshot satirini geri yazar: kayit VARSA UPDATE (SILMEZ -> dis FK guvenli), YOKSA INSERT
// (GeriKayitEkle, ayni ID). Format-guvenli (bos sablon dataset + TField.AsString). '' = basari.
function GeriKayitYaz(const ATabloAdi, AJSON: string): string;
var
  LTmpl, LStmt: TFDQuery;
  LParsed, LVal: TJSONValue;
  LObj: TJSONObject;
  LPair: TJSONPair;
  F: TField;
  LDeger, LSet: string;
  LID: Int64;
  LKolonlar: TStringList;
  i: Integer;
begin
  Result := '';
  LParsed := nil;
  LKolonlar := TStringList.Create;
  LTmpl := TFDQuery.Create(nil);
  LStmt := TFDQuery.Create(nil);
  try
    try
      LParsed := TJSONObject.ParseJSONValue(AJSON);
      if not (LParsed is TJSONObject) then Exit('JSON cozumlenemedi.');
      LObj := TJSONObject(LParsed);
      LVal := LObj.GetValue('ID');
      if LVal = nil then Exit('ID yok.');
      LID := StrToInt64Def(GeriJsonDeger(LVal), 0);

      // Bos sablon dataset -> JSON degerlerini kultur-aware TField'a parse et.
      LTmpl.Connection := Tablo.FDCnn;
      LTmpl.SQL.Text := 'SELECT * FROM ' + ATabloAdi + ' WHERE 1=0';
      LTmpl.Open;
      F := LTmpl.FindField('ID');
      if F <> nil then begin F.ReadOnly := False; F.Required := False; end;
      LTmpl.Append;
      for LPair in LObj do
      begin
        F := LTmpl.FindField(LPair.JsonString.Value);
        if (F = nil) or F.ReadOnly then Continue;
        LDeger := GeriJsonDeger(LPair.JsonValue);
        if Trim(LDeger) = '' then F.Clear else F.AsString := LDeger;
        if not SameText(F.FieldName, 'ID') then
          LKolonlar.Add(F.FieldName);
      end;
      if LKolonlar.Count = 0 then Exit('');   // ID disi yazilacak alan yok -> gec

      LStmt.Connection := Tablo.FDCnn;
      // 1) Kayit VAR MI? (RowsAffected trigger/NOCOUNT'tan etkilenip yaniltir -> acikca sorgula.)
      LStmt.SQL.Text := 'SELECT 1 FROM ' + ATabloAdi + ' WHERE ID=:PID';
      LStmt.ParamByName('PID').AsLargeInt := LID;
      LStmt.Open;
      if LStmt.IsEmpty then
      begin
        LStmt.Close;
        Result := GeriKayitEkle(ATabloAdi, AJSON);   // yok (oturumda silinmisti) -> ayni ID INSERT
        Exit;
      end;
      LStmt.Close;

      // 2) VAR -> UPDATE (tum ID-disi kolonlar; WHERE ID). Silmez -> dis FK guvenli.
      LSet := '';
      for i := 0 to LKolonlar.Count - 1 do
      begin
        if LSet <> '' then LSet := LSet + ',';
        LSet := LSet + '[' + LKolonlar[i] + ']=:P' + IntToStr(i);
      end;
      LStmt.SQL.Text := 'UPDATE ' + ATabloAdi + ' SET ' + LSet + ' WHERE [ID]=:PID';
      for i := 0 to LKolonlar.Count - 1 do
      begin
        F := LTmpl.FieldByName(LKolonlar[i]);
        if F.DataType = ftAutoInc then
          LStmt.ParamByName('P' + IntToStr(i)).DataType := ftLargeint
        else
          LStmt.ParamByName('P' + IntToStr(i)).DataType := F.DataType;
        if F.IsNull then LStmt.ParamByName('P' + IntToStr(i)).Clear
        else LStmt.ParamByName('P' + IntToStr(i)).Value := F.Value;
      end;
      LStmt.ParamByName('PID').AsLargeInt := LID;
      LStmt.ExecSQL;
    except
      on E: Exception do
      begin
        try if LTmpl.State in [dsInsert, dsEdit] then LTmpl.Cancel; except end;
        Result := E.Message;
      end;
    end;
  finally
    LTmpl.Free;
    LStmt.Free;
    LKolonlar.Free;
    if LParsed <> nil then LParsed.Free;
  end;
end;

procedure OturumGeriAl(const AOturum: string);
var
  LPlanQ, LDataQ, LDelQ: TFDQuery;
  LSnap, LErr: string;
begin
  LSnap := DepoTablo('SNAPSHOT');
  LPlanQ := TFDQuery.Create(nil);
  LDataQ := TFDQuery.Create(nil);
  LDelQ := TFDQuery.Create(nil);
  try
    LPlanQ.Connection := Tablo.FDCnn;
    LDataQ.Connection := Tablo.FDCnn;
    LDelQ.Connection := Tablo.FDCnn;

    Tablo.FDCnn.StartTransaction;
    try
      // 1) Mevcut satirlari SIL: cocuk once (SIRA DESC). Filtre subquery olabilir; ust tablo
      //    henuz silinmediginden alt tablonun filtresi dogru cozer.
      LPlanQ.SQL.Text :=
        'SELECT DISTINCT SIRA, TABLOADI, FILTRE FROM ' + LSnap +
        ' WHERE OTURUMID=:O ORDER BY SIRA DESC';
      LPlanQ.ParamByName('O').AsString := AOturum;
      LPlanQ.Open;
      while not LPlanQ.Eof do
      begin
        // YALNIZ EKLENEN satirlari sil (snapshot'ta OLMAYAN ID'ler). Mevcut satirlar
        // SILINMEZ -> dis FK (KULLANICI, FATBASLIK...) korunur; onlar asagida UPDATE ile gelir.
        LDelQ.SQL.Text := 'DELETE FROM ' + LPlanQ.FieldByName('TABLOADI').AsString +
          ' WHERE (' + LPlanQ.FieldByName('FILTRE').AsString + ') AND ID NOT IN (' +
          'SELECT KAYITID FROM ' + LSnap + ' WHERE OTURUMID=:O AND TABLOADI=:T AND KAYITID IS NOT NULL)';
        LDelQ.ParamByName('O').AsString := AOturum;
        LDelQ.ParamByName('T').AsString := LPlanQ.FieldByName('TABLOADI').AsString;
        LDelQ.ExecSQL;
        LPlanQ.Next;
      end;
      LPlanQ.Close;

      // 2) Snapshot satirlarini geri yaz: VAR ise UPDATE (silmez -> FK guvenli), YOK ise
      //    INSERT (ayni ID). Ust once (SIRA ASC). Hata -> raise -> rollback.
      LDataQ.SQL.Text :=
        'SELECT TABLOADI, SATIRJSON FROM ' + LSnap +
        ' WHERE OTURUMID=:O AND KAYITID IS NOT NULL ORDER BY SIRA ASC, ID ASC';
      LDataQ.ParamByName('O').AsString := AOturum;
      LDataQ.Open;
      while not LDataQ.Eof do
      begin
        LErr := GeriKayitYaz(LDataQ.FieldByName('TABLOADI').AsString,
                             LDataQ.FieldByName('SATIRJSON').AsString);
        if LErr <> '' then
          raise Exception.Create('Geri yukleme hatasi (' +
            LDataQ.FieldByName('TABLOADI').AsString + '): ' + LErr);
        LDataQ.Next;
      end;
      LDataQ.Close;

      Tablo.FDCnn.Commit;
    except
      if Tablo.FDCnn.InTransaction then Tablo.FDCnn.Rollback;
      raise;
    end;
  finally
    LPlanQ.Free;
    LDataQ.Free;
    LDelQ.Free;
  end;
  // 3) Basarili commit'ten SONRA snapshot'i temizle (hata olursa snapshot kalir, tekrar denenir).
  OturumBitir(AOturum);
end;

function LogGeriAl(AUstTabloID: Integer; AUstKayitID: Int64; AGun: TDateTime): string;
var
  LCnn: TFDConnection;
  LLogQ: TFDQuery;
  LList: TList<TGeriKayit>;
  LRec: TGeriKayit;
  i: Integer;
  LTabloAdi, LKartTabloAdi, LUyari, LHata: string;
  LKart: Boolean;
begin
  Result := '';
  LList := TList<TGeriKayit>.Create;
  try
    // a. GENDEPO (otonom log baglantisi) - silme grubunu oku, KART ONCE (FK icin).
    //    Tum satirlar once listeye alinir (ayni conn'da baska sorgu acmamak icin).
    try
      GLock.Enter;
      try
        LCnn := LogBaglantisi;
        LLogQ := TFDQuery.Create(nil);
        try
          LLogQ.Connection := LCnn;
          LLogQ.SQL.Text :=
            'SELECT TABLOID, KAYITID, ' + DbLogBilgiOku('BILGI') + ' J ' +
            'FROM ' + DepoTablo('ISLEMLOG') + ' WHERE USTKAYITID=:u AND USTTABLOID=:ut AND ISLEMTIPI=0 ' +
            'AND CAST(TARIH AS date)=:g ' +
            'ORDER BY CASE WHEN TABLOID=:ut2 THEN 0 ELSE 1 END, ID';
          LLogQ.ParamByName('u').AsLargeInt := AUstKayitID;
          LLogQ.ParamByName('ut').AsInteger := AUstTabloID;
          LLogQ.ParamByName('ut2').AsInteger := AUstTabloID;
          LLogQ.ParamByName('g').AsString := FormatDateTime('yyyy-mm-dd', AGun);
          LLogQ.Open;
          while not LLogQ.Eof do
          begin
            LRec.TabloID := LLogQ.FieldByName('TABLOID').AsInteger;
            LRec.KayitID := LLogQ.FieldByName('KAYITID').AsLargeInt;
            LRec.JSON    := LLogQ.FieldByName('J').AsString;
            LList.Add(LRec);
            LLogQ.Next;
          end;
        finally
          LLogQ.Free;
        end;
      finally
        GLock.Leave;
      end;
    except
      on E: Exception do
        Exit('Log kayitlari okunamadi: ' + E.Message);
    end;

    if LList.Count = 0 then
      Exit('Bu silme islemine ait geri alinacak kayit bulunamadi.');

    // b. KART cakisma kontrolu (ANA DB): kart ID'si su an kullaniliyorsa hicbir sey ekleme.
    LKartTabloAdi := GeriTabloAdiGetir(AUstTabloID);
    if LKartTabloAdi = '' then
      Exit('Kart tablosu (TABLOID=' + IntToStr(AUstTabloID) + ') bulunamadi; geri alinamaz.');
    if GeriKayitVarMi(LKartTabloAdi, AUstKayitID) then
      Exit('Bu ID (' + IntToStr(AUstKayitID) + ') su an baska bir kayitta kullaniliyor; geri alinamaz.');

    // c. Sirayla INSERT (kart once, sonra detaylar).
    LUyari := '';
    for i := 0 to LList.Count - 1 do
    begin
      LRec := LList[i];
      LKart := (LRec.TabloID = AUstTabloID) and (LRec.KayitID = AUstKayitID);

      LTabloAdi := GeriTabloAdiGetir(LRec.TabloID);
      if LTabloAdi = '' then
      begin
        if LKart then Exit('Kart tablosu bulunamadi; geri alinamaz.');
        LUyari := LUyari + 'TABLOID=' + IntToStr(LRec.TabloID) + ' tablo adi bulunamadi, atlandi.'#13#10;
        Continue;
      end;

      // Zaten varsa atla (detaylarda parcali cakisma; kart b'de kontrol edildi).
      if GeriKayitVarMi(LTabloAdi, LRec.KayitID) then
      begin
        if not LKart then
          LUyari := LUyari + LTabloAdi + ' ID=' + IntToStr(LRec.KayitID) + ' zaten mevcut, atlandi.'#13#10;
        Continue;
      end;

      LHata := GeriKayitEkle(LTabloAdi, LRec.JSON);
      if LHata <> '' then
      begin
        if LKart then
          Exit('Kart geri eklenemedi: ' + LHata)   // kart basarisiz -> tum islem iptal
        else
          LUyari := LUyari + LTabloAdi + ' ID=' + IntToStr(LRec.KayitID) + ': ' + LHata + #13#10;
      end
      else
      begin
        // Geri alma basarili -> "Ekleme" logu (kim/ne zaman geri aldi). REHBERID/STOKID JSON'dan.
        var LReh: Int64 := 0;
        var LStk: Int64 := 0;
        var LObj := TJSONObject.ParseJSONValue(LRec.JSON) as TJSONObject;
        if LObj <> nil then
        try
          LReh := StrToInt64Def(GeriJsonDeger(LObj.GetValue('REHBERID')),
                    StrToInt64Def(GeriJsonDeger(LObj.GetValue('CARIID')), 0));
          LStk := StrToInt64Def(GeriJsonDeger(LObj.GetValue('STOKID')),
                    StrToInt64Def(GeriJsonDeger(LObj.GetValue('URUNID')), 0));
        finally
          LObj.Free;
        end;
        LogYaz(liEkle, LRec.TabloID, LRec.KayitID, LRec.JSON, 'Geri Al',
               AUstTabloID, AUstKayitID, LReh, LStk);
      end;
    end;

    Result := LUyari;   // '' = tam basari; aksi halde atlanan detay uyarilari
  finally
    LList.Free;
  end;
end;

initialization
  GLock := TCriticalSection.Create;
  GYillar := TStringList.Create;

finalization
  if GLogCnn <> nil then
  begin
    try GLogCnn.Free; except end;
    GLogCnn := nil;
  end;
  GYillar.Free;
  GLock.Free;

end.
