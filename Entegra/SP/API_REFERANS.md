# Gentegre API — Referans

Delphi, mobil ve web istemcilerinin ortak kullandığı veritabanı API'si.
Her nesnenin MSSQL ve PostgreSQL karşılığı vardır ve **ikisi aynı sözleşmeye uyar**.

> Bu belge **yaşayan referanstır**: her yeni nesne kabul edilmeden önce buraya işlenir.
> Tasarım gerekçeleri `API_SP_LISTESI.md` ve `API_FATURA_TASARIM.md` içinde.

## 1. Adlandırma ve yerleşim

| | MSSQL | PostgreSQL |
|---|---|---|
| Nesne | `dbo.sp_Api_<Modül>_<İşlem>_Json` | `public.fn_api_<modül>_<işlem>_json` |
| Kaynak dosya | `GenUpdate/GenDepoUpdateN.sql` | `pg/schema/NN_fn_api_*.sql` |
| Dağıtım | GenUpdate komutu (etiketsiz) | GenUpdate komutu, `ACIKLAMA` içinde `#pg` |

**Neden ayrı şema değil, önek:** API nesneleri `dbo` içinde `sp_Prog_` (Delphi ekran listeleri) ve
`TM_` (eski mobil) ile yan yana durur. Gerekçe:

- `Tablo.ListeSPJson` çağrıyı `EXEC dbo.<ad>` olarak kuruyor (`Utablo.pas`); ayrı şema bu yardımcıyı ve
  PG tarafındaki `fn_` ad üretimini değiştirmeyi gerektirir.
- PG'de ayrı şema `search_path` bağımlılığı ekler — bu projede daha önce sorun çıkarmış bir alan.
- Ayrı şemanın asıl faydası olan **toplu yetki**, şema olmadan da veritabanı rolüyle sağlanır (§4).

Şema ayrımı ileride istenirse yeniden adlandırma mekaniktir; önek zaten ayrımı görünür kılıyor.

## 2. Ortak sözleşme

### 2.1 İmza

```sql
-- okuma
CREATE OR ALTER PROCEDURE dbo.sp_Api_<X>_Json
    @Kosullar NVARCHAR(MAX),        -- JSON girdi
    @Baslik   NVARCHAR(MAX) = N''   -- opsiyonel ek-kolon parçası (sp_Prog_*_Json2 ile aynı)
-- yazma
CREATE OR ALTER PROCEDURE dbo.sp_Api_<X>_Json
    @Kosullar NVARCHAR(MAX)
```

### 2.2 Girdi zarfı

```jsonc
{
  "Surum": 1,                                   // sözleşme sürümü
  "Oturum": { "KulId": 5, "SubeId": -1, "Ip": "", "Istasyon": "", "CihazId": "" },
  "Sayfa": 1, "SayfaBoyu": 50,                  // yalnız listelerde; 0 = sınırsız
  "Sirala": "TARIH desc",                       // beyaz listeden, ham SQL değil
  ...                                            // nesneye özel alanlar
}
```

- Alan eklemek **kırıcı değildir**; bilinmeyen alan yok sayılır.
- Tarih/sayı JSON'da doğal tipte (`"2026-08-07"`, `2.75`) — VARCHAR tarih yok.
- `SayfaBoyu = 0` → `TOP`/`LIMIT` uygulanmaz (mevcut `TopN = 0` kuralı).

### 2.3 Çıktı

**Okuma:** klasik sonuç kümesi, açık kolon listesi (`SELECT *` yok), sabit kolon adları.
`Fields[0]` daima `ID` (Delphi konumsal sözleşmesi). Ek kolonlar SELECT'in **sonuna** eklenir.

**Yazma:** tek satır, tek kolon (`Sonuc`), JSON:

```jsonc
{ "Sonuc": 1, "Id": 5567, "Mesaj": "", "Uyarilar": [],
  "Satirlar": [ {"Sira":1,"Id":9001} ] }
```

### 2.4 Hata

- İş kuralı reddi ve teknik hata **`THROW`** ile bildirilir; hata metni **asla sonuç kümesi olarak dönmez**.
- `Sonuc: 0` yalnız "işlem yapılmadı ama hata da değil" durumları için.
- Hata numaraları:

| Aralık | Anlam |
|---|---|
| 51000-51099 | Girdi/doğrulama (eksik alan, geçersiz tür) |
| 51100-51199 | Yetki |
| 51200-51299 | İş kuralı (kilitli belge, dönüştürülmüş kaynak, kalan miktar aşımı) |
| 51300-51399 | Durum çakışması (iyimser kilit, eşzamanlı değişiklik) |

### 2.4.1 Dış transaction uyarısı

Yazan nesneler `SET XACT_ABORT ON` + `THROW` kullanır. Bir çağrı reddedilirse (ör. 51200)
**dıştaki transaction da düşer** — `BEGIN TRAN` açıp SP'yi çağıran ve hatayı yakalayan bir kod
`ROLLBACK` diyemez ("no corresponding BEGIN TRANSACTION"). Çağıran ya transaction'ı SP'ye
bırakmalı ya da hatayı yakalamadan yukarı taşımalıdır.

### 2.5 Zorunlu kurallar

1. `SET NOCOUNT ON` + `SET XACT_ABORT ON`.
2. Yazan nesne `BEGIN TRAN` / `COMMIT`, `CATCH` içinde `IF XACT_STATE() <> 0 ROLLBACK; THROW;`.
3. Dinamik SQL yalnız `sp_executesql` + parametre bağlama.
4. `SELECT *` yok; kolon sözleşmesi bu belgede.
5. Şifre/hash asla dönmez.
6. Depo tabloları `ULog.DepoTablo` mantığıyla çözülür (synonym'e bağımlı kalınmaz).
7. Her nesnenin PG ikizi aynı anda yazılır; `pg/tools/db_diff.ps1` ile karşılaştırılır.

## 3. Nesne kataloğu

Durum: ⬜ planlandı · 🟨 geliştiriliyor · ✅ hazır (MSSQL + PG + test)

### B. Hesap / yan etki

İç yardımcılar (sonuç kümesi döndürmez, başka SP'lerden çağrılabilir):
`sp_Api_Belge_Toplam_Yaz_Ic`, `sp_Api_Belge_Durum_Yaz_Ic`. JSON nesneleri bunların ince
sarmalayıcısıdır — bir SP başka bir SP'yi çağırınca onun `SELECT`'i istemciye fazladan sonuç
kümesi olarak giderdi.

Ortak altyapı: **`dbo.fn_Api_Belge_DipToplam(@BelgeId)`** — belge dip toplam kümesi (TUR 1=Toplam,
2=ÖTV, 3=İskonto, 4=Ara Toplam, 5/6/7=KDV satırları, 8=Ek Vergi, 9=Stopaj, 15=KDV Toplam,
20=Genel Toplam). Kanonik formülün tek kopyası; `SP_PRG_FaturaDipToplami` de bunu okur.

| Nesne | Durum | Girdi | Çıktı | Not |
|---|---|---|---|---|
| `sp_Api_Belge_ToplamHesapla_Json` | 🟨 MSSQL hazır, PG bekliyor | `{BelgeId,Yaz,Zorla}` | `{Sonuc,BelgeId,Kapsam,Neden,Yazildi,Matrah,Kdv,Toplam,Doviz,Maliyet,EkVergi}` | Kanonik formül `fn_Api_Belge_DipToplam` TVF'i. Gelen e-belge ve üretim fişinde `Kapsam=disi` → yazmaz (`Zorla=1` hariç). `GenDepoUpdate68.sql` |
| `sp_Api_Belge_DurumHesapla_Json` | 🟨 MSSQL hazır, PG bekliyor | `{BelgeId,Kaynak,Yaz}` | `{Sonuc,BelgeId,Kaynak,Tur,Kapsam,Neden,Durum,OncekiDurum,Yazildi,Satir,Tamamlanan,Kismi,Acik}` | `Kaynak`: `siparis` (SIPARIS/SIPARISDETAY) \| `belge` (FATBASLIK/FATURA). Durum 0/1/9 dışındaki belgeye dokunmaz. `GenDepoUpdate69.sql` |
| `sp_Api_Belge_SeriLot_Yaz_Json` | 🟨 MSSQL hazır, PG bekliyor (iç yardımcı `sp_Api_Belge_SeriLot_Yaz_Ic` üzerinden; `Belge_Kaydet` de onu çağırır) | `{BelgeId,SatirId,UrunId,BelgeTur,IslemTip,IzlemTur,GirisDepo,CikisDepo,StokDurumDegis,KaynakSatirId,Oturum,SeriLot:[{Sira,SeriNo,LotNo,Urt,Skt,Kalan,Durum,IzlemId}]}` | `{Sonuc,BelgeId,SatirId,Silinen,Yazilan,Satirlar:[{Sira,IzlemId,SeriLotId}]}` | Kanonik kaynak `TTablo.IzlemBilgisiKaydet`. Silme `STOKID+BASLIKID+SATIRID` kapsamında. `GenDepoUpdate70.sql` |

### C. Silme

Ortak altyapı: **`dbo.fn_Api_DepoDBAdi()`** (depo DB adı = `<ANA_DB>_GENDEPO`), **`sp_Api_Log_YilTablosu`**
(`LOG<yyyy>` yoksa oluşturur, DDL `ULog.LogYilTablosu` ile birebir), **`sp_Api_Log_Yaz_Ic`** (iç yardımcı).

Değer biçimi: SQL tarafı **değişmez** biçim yazar (ISO tarih, nokta ondalık, `True`/`False`).
Pascal tarafı istemci yerel ayarıyla yazmaya devam eder; `ULog.GeriDegerAta` iki biçimi de kabul eder.
Temporal (`GENERATED ALWAYS`) ve gizli kolonlar log JSON'una **alınmaz** — geri yazılamazlar.

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Belge_Sil_Json` | 🟨 MSSQL hazır, PG bekliyor | `{BelgeId,KilitKaldirildi,Oturum}` | `{Sonuc,BelgeId,Tur,SilinenSatir,Loglanan}` — hata: 51200 `Belge silinemez: <NEDEN>` |
| `sp_Api_Log_KayitSil_Json` | 🟨 MSSQL hazır, PG bekliyor | `{Tablo,TabNo,KayitId,UstTabNo,UstId,RehberId,StokId,Oturum:{KulId,SubeId,Ip,Istasyon}}` | `{Sonuc,Yazilan}` |
| `sp_Api_Log_DetaySil_Json` | 🟨 MSSQL hazır, PG bekliyor | aynı + `Kosul` (ham WHERE, **uygulama üretir**) | `{Sonuc,Yazilan}` |

### D. Dönüşüm

Ortak altyapı: **`dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, @SatirId, @HedefUretim)`** —
bir kaynak satırın `Adet / Donusen / Kalan` değerleri. Formül `sp_Prog_BelgeDonusum_Kaynak_Json2`
içindeki üç dalın (1=teklif, 2=sipariş, 3=belge) aynısı; artık tek yerde.

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Donusum_Kontrol_Json` | 🟨 MSSQL hazır, PG bekliyor | `{Kaynak,DonusumTuru,HedefUretim,Satirlar:[{SatirId,Adet}]}` | `{Sonuc,Uygun,Satirlar:[{SatirId,Adet,Kalan,Uygun,Neden}]}` — aşırı dönüşüm koruması. `GenDepoUpdate73.sql` |
| `sp_Api_Donusum_Kaynak_Json` | ⬜ (mevcut `sp_Prog_BelgeDonusum_Kaynak_Json2` yeterli olabilir) | `{HedefTur,RehberId,DepoId,BasTarih,BitTarih,Filtre,Sayfa,SayfaBoyu}` | sonuç kümesi |
| `sp_Api_Donusum_Uygula_Json` | 🟨 MSSQL hazır, PG bekliyor | `{Kaynak,DonusumTuru,HedefUretim,HedefBelgeId,Oturum,Satirlar:[{Sira,KaynakSatirId,UrunId,Adet,BirimFiyat,Kdv,Iskonto,Iskonto2,...}]}` | `{Sonuc,HedefBelgeId,Yazilan,Satirlar:[{Sira,KaynakSatirId,SatirId}],Toplam,KaynakDurum}` — **açık-değerli sözleşme**: fiyat/iskonto/KDV hesaplamaz, çağıran gönderir. `GenDepoUpdate74.sql` |
| `sp_Api_Donusum_Geri_Json` | ⬜ (gerekmeyebilir — hedef satır silinince `YERI`/`YERID` bağı satırla gider, kalan kendiliğinden döner; `Belge_Sil` karşılıyor) | `{HedefBelgeId}` \| `{HedefSatirId}` | `{Sonuc,Adet}` |
| `sp_Api_Donusum_Rapor_Json` | 🟨 MSSQL hazır, PG bekliyor | `{Kaynak,DonusumTuru,HedefUretim,BasTarih,BitTarih,GizleKaynakTur,GizleHedefTur,KalmayanGoster,GizlenenGoster,RehberId,BelgeNo,StokKod,StokAd,Sayfa,SayfaBoyu}` | sonuç kümesi (`Fields[0] = SATIRID`) — `TM_DonusumListeleri`+`Alis`+`Satis` (906 satır, 11 sabit ekran dalı) yerine tek gövde. `GenDepoUpdate75.sql` |

### E. Okuma

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Belge_Liste_Json` | 🟨 MSSQL hazır, PG bekliyor | `{Tur\|Turler[],BasTarih,BitTarih,RehberId,SubeId,Durum,BelgeNo,Aciklama,Sayfa,SayfaBoyu,Sirala}` | sonuç kümesi (`Fields[0]=ID`). `Sirala` beyaz liste: `TARIH_DESC\|TARIH_ASC\|NO_DESC\|NO_ASC\|TUTAR_DESC`. `GenDepoUpdate76.sql` |
| `sp_Api_Belge_Getir_Json` | 🟨 MSSQL hazır, PG bekliyor | `{BelgeId}` | 2 sonuç kümesi (başlık, satırlar); ikisinde de `Fields[0]=ID`. `TM_FATBASLIK`+`TM_FaturaDetay` ikilisi yerine tek çağrı. `GenDepoUpdate76.sql` |
| `sp_Api_Belge_EkAlan_Json` | 🟨 MSSQL hazır, PG bekliyor | `{Ekran,Tablo,KayitId}` — `Tablo` beyaz liste | 2 sonuç kümesi: alan tanımları (`ALANLAR`) + `{Sonuc,KayitId,Degerler:{...}}`. `GenDepoUpdate77.sql` |

### F. Yazma

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Belge_Kaydet_Json` | 🟨 MSSQL hazır, PG bekliyor | `{Surum,SatirModu,Oturum,Baslik{...},Satirlar[{Sira,ID,Sil,UrunId,Adet,BirimFiyat,Kdv,Iskonto,Iskonto2,SeriLot[]}]}` | `{Sonuc,BelgeId,BelgeNo,Yeni,SilinenSatir,Satirlar:[{Sira,ID,Islem}],Toplam}` — açık-değerli sözleşme. `SatirModu`: `delta` (varsayılan) \| `tam`. `GenDepoUpdate78.sql` |

## 4. Yetki

Şema ayrımı yerine veritabanı rolü:

```sql
-- bir kez (GenUpdate)
IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL CREATE ROLE gentegre_api;
-- her yeni nesnede, tanımın hemen ardından
GRANT EXECUTE ON dbo.sp_Api_<X>_Json TO gentegre_api;
```

Mobil/web bağlantı kullanıcısı yalnız bu role alınır; `dbo` üzerinde geniş yetki verilmez.
PG'de karşılığı `GRANT EXECUTE ON FUNCTION public.fn_api_<x>_json(text,text) TO gentegre_api;`.

## 5. Belge nasıl güncel kalır

1. Her nesne **tanımının başında** standart başlık yorumu bulunur (amaç, girdi alanları, çıktı kolonları,
   hata kodları, yerine geçtiği eski nesne).
2. Tanım MSSQL'de `sys.sql_modules`, PG'de `pg_get_functiondef` ile okunabildiği için bu belgenin
   katalog bölümü canlı veritabanından üretilebilir — elle senkron tutmaya gerek kalmaz.
3. Üretim betiği eklendiğinde buraya not düşülecek (`SP/tools/api_dokuman_uret.ps1`).

Kaynak kodu bozulmadan çıkarmak için tanımlar **UTF-8** okunmalı; `sqlcmd -o` Türkçe karakterleri
bozar (bkz. `TM_ANALIZ.md` §1 uyarısı).


## 6. Delphi tarafı bağlama durumu

Yardımcı: **`TTablo.ApiCagir(ASPAdi, AKosullar): string`** (`Utablo.pas`) — yazma nesnesini çağırır,
tek satır/tek kolon JSON sonucunu döndürür. `ListeSPJson` ile aynı motor seam'i kullanır
(MSSQL `EXEC dbo.sp_Api_...`, PG `SELECT * FROM fn_api_...`). SP içindeki `THROW` exception olarak
yukarı gider — **yutulmaz** (silme/kaydetme sessizce başarısız olmasın).

| Çağrı yeri | Eskiden | Şimdi |
|---|---|---|
| `TTablo.FaturaSil` (`Utablo.pas`) | Ayrı bağlantıda (`LConn`), transaction'sız; Pascal loglama + 8 ayrı `DELETE` | `sp_Api_Belge_Sil_Json` — tek transaction, aynı sıra ve kapsam |
| `UFaturaWizard.FaturaTutarHesapla` | `TOPLAMLAR`'dan okuyup Pascal'da hesap + `UPDATE FATBASLIK` | `sp_Api_Belge_ToplamHesapla_Json` (ekrandaki dip toplam listesi için `TOPLAMLAR` kalıyor) |
| `UFaturalar.MenuDurumuGuncelleClick` | `EXEC TM_SiparisDurumGuncelle` | `sp_Api_Belge_DurumHesapla_Json` |

Sade sarmalayıcılar (çağıran unit'in `System.JSON`'a ihtiyacı olmasın diye):
**`Tablo.BelgeToplamHesapla(BelgeId)`** ve **`Tablo.BelgeDurumHesapla(BelgeId, Kaynak)`**.

### Toplam hesabı — tüm çağrı yerleri

| Yer | Durum |
|---|---|
| `UFaturaWizard.FaturaTutarHesapla` | ✅ `BelgeToplamHesapla` |
| `Ubelgegiris` (2 yer) | ✅ Pascal'da biriktirilen `Tutar/KDV/Toplam` yerine |
| `UHizliGunsonuDlg.FatbaslikOlustur` | ✅ (besleyen ölü sorgu da kaldırıldı) |
| `UReplikasyon` | ✅ (toplamsal `ISK1+ISK2` iskonto kuralı da düzeldi) |
| `UGiderPusulasi.FaturaTutarGuncelle` | ✅ `Post` → SP → `Refresh` |
| `UImport.FaturaTutarHesapla` | ✅ `Post` → SP → `Refresh` |
| `UEBelgeGelen` (2 yer) | ⛔ **bilerek bırakıldı** — gelen e-belge; toplamlar tedarikçinin UBL'inden gelir, SP zaten `Kapsam=disi` der |
| `UHizliGiris.TabDetayAfterPost` | ⛔ **bilerek bırakıldı** — belge `FATBASLIK`'ta değil, geçici tabloda (`AktifFatTabloAdi`); ayrıca yalnız ekran gösterimi, DB'ye yazmıyor |
| `IcerikFrame/UFaturalar` + `UFaturalar2` | ⛔ **bilerek bırakıldı** — `DURUM=6` ile toplamları **sıfırlama** (iptal), hesap değil |

**Davranış değişikliği (bilinçli, karar 2):** `UGiderPusulasi` ve `UImport` KDV Dahil belgede
matraha **brüt** `SUM(TUTAR)` yazıyordu; artık **net matrah** yazılıyor.
