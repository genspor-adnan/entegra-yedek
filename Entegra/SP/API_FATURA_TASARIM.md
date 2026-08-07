# Fatura/Belge CRUD — Mevcut Durum ve Önerilen Yeni Tasarım

Kaynak: `BILIMPLANT` üzerindeki `TM_FATBASLIKGuncelle`, `TM_FATURAGir`, `TM_FATBASLIK`, `TM_FaturaDetay`, `TM_FATBASLIKDurumGuncelle`, `TM_FatBaslikEkalanlar`.
Eski SP'ler **yerinde kalacak**; bu belge yeniden yazım için sözleşmeyi tanımlar.

## 1. Bugün nasıl yapılmış

| İşlem | SP | Nasıl |
|---|---|---|
| Başlık oluştur/güncelle | `TM_FATBASLIKGuncelle` | 38 konumsal parametre. `@ID` doluysa UPDATE, boşsa INSERT. |
| Başlık **sil** | aynı SP | `@FATBASLIKNO = 'Sil'` sihirli değeriyle |
| Satır ekle/güncelle | `TM_FATURAGir` | 33 konumsal parametre. `@ID` boşsa INSERT, doluysa UPDATE. |
| Satır **sil** | aynı SP | `@TUR = 'Sil'` sihirli değeriyle |
| Başlık toplamları | `TM_FATURAGir` içinde | Her satır kaydında 4 korelasyonlu `SUM()` ile yeniden hesap |
| Seri/lot | `TM_FATURAGir` içinde | `@SERILOTLISTESI NVARCHAR(MAX)` + `OPENJSON` |
| Durum (kısmi/tamam) | `TM_FATBASLIKDurumGuncelle` | Ayrı SP, elle çağrılıyor |
| Liste / detay okuma | `TM_FATBASLIK` / `TM_FaturaDetay` | `TM_FATBASLIKGuncelle` sonunda **doğrudan çağrılıyor** |

Akış: istemci başlığı kaydeder → dönen ID ile her satır için ayrı `TM_FATURAGir` çağrısı → başlık toplamları her çağrıda yeniden hesaplanır.

## 2. Tespit edilen hatalar (yeniden yazımda tekrarlanmamalı)

1. **`TM_FATBASLIKDurumGuncelle` içinde sabit ID.** `@KISMI` hesabında `SD.FATBASID = 10224` yazıyor — parametre değil. Kısmi teslim durumu her belgede yanlış.
2. **`SET @YENIID = @@IDENTITY`.** Tetikleyici başka tabloya yazarsa yanlış ID döner. `SCOPE_IDENTITY()` olmalı.
3. **Transaction yok.** Başlık INSERT + satır + `STOKIZLEME` + `STOKIZLEMEDEPO` + `STOKSERILOT` yazımları ayrı ayrı; ortada hata olursa yarım kayıt kalır.
4. **Hata bir sonuç kümesi olarak dönüyor.** `CATCH` bloğu `SELECT 'Hata oluştu....' + ERROR_MESSAGE()` yapıyor; istemci bunu veriden ayırt edemez, üstelik kısmi yazım kalmıştır.
5. **Seri/lot silme fazla geniş.** `DELETE FROM STOKSERILOT ... WHERE STOKID = @URUNID` — belge/satır filtresi yok, ürünün **tüm** seri/lot kayıtlarını siliyor. `STOKDURUMIZLEME` silmesi de aynı.
6. **`OUTPUT` sırası ile JSON sırası eşleştiriliyor.** `ROW_NUMBER()` ile eşleme yapılıyor; `INSERT ... OUTPUT` satır sırasını garanti etmez. Anahtar taşınmalı (`MERGE ... OUTPUT` veya JSON'da `SIRA` alanı).
7. **INSERT ve UPDATE farklı kolon yazıyor.** UPDATE `VD`/`VNO`, INSERT `ID_VERGIDAI`/`ID_VERGINO` dolduruyor. Aynı belge kaydetme yoluna göre farklı alanlara yazıyor.
8. **`@MIKTAR INT`, `@ADET INT`.** Küsuratlı miktar sessizce kırpılıyor.
9. **Döviz kuru satır başına, sargı-dışı sorgu ile.** `CONVERT(DATE,D.TARIH,102) = CONVERT(DATE,GETDATE(),102)` index kullanmaz; o güne kur girilmemişse `NULL` → `TUTAR` NULL olur, hata verilmez.
10. **`DOVIZ_TUTARI` CASE'inin iki dalı da aynı** ve kurla çarpılmıyor — dövizli belgede yanlış.
11. **O(n²) toplam hesabı.** n satırlık belge kaydederken başlık toplamı n kez, her seferinde tüm satırlar taranarak hesaplanıyor.
12. **Komut ve sorgu karışık.** Yazma SP'si sonunda liste SP'sini çağırıp sonuç kümesi döndürüyor.
13. **Silme sihirli string ile.** `@FATBASLIKNO='Sil'` / `@TUR='Sil'` — belge numarası alanına "Sil" yazan bir istemci belgeyi siler.

## 3. Önerilen tasarım

### 3.1 Belge tümü tek çağrıda (asıl değişiklik)

Satır satır çağrı yerine **belge bir bütün olarak** gönderilir. Tek transaction, tek toplam hesabı, tutarlı sonuç.

```
sp_Api_Belge_Kaydet_Json   @Kosullar  -- başlık + satırlar + seri/lot, tek JSON
sp_Api_Belge_Sil_Json      @Kosullar  -- ayrı nesne; sihirli string yok
sp_Api_Belge_Liste_Json    @Kosullar  -- salt okuma, sayfalı
sp_Api_Belge_Getir_Json    @Kosullar  -- tek belge: başlık + satırlar
```

PostgreSQL ikizleri: `fn_api_belge_kaydet_json` vb.

### 3.1.1 FATBASLIK ve FATURA: ayrı mı, tek mi?

**Yazma tarafı tek olmalı** — `sp_Api_Belge_Kaydet_Json`. Gerekçe:

- Belge bir bütündür: başlık + satır + seri/lot + stok hareketi + başlık toplamı + durum aynı transaction'da ya hep ya hiç yazılmalı. İki ayrı SP demek, aralarında bir yerde hata olduğunda yarım belge demek (bugünkü sorun).
- Başlık toplamı ve durum, satırlar bilinmeden doğru hesaplanamaz. Bugün her satır çağrısında yeniden hesaplanıyor: n satırlık belgede n kez tam tarama.
- Belge no üretimi (`sp_BelgeNoGetir`) yalnızca yeni belgede ve transaction içinde bir kez çalışmalı.
- Üç istemcinin (Delphi/mobil/web) tek çağrıyla iş görmesi, ağ gidiş-dönüşünü n+1'den 1'e indirir. Mobilde en belirgin kazanç burası.

**Tek SP, kısmi gönderimi de karşılar** — ayrı SP'ye ihtiyaç bırakmaz:

| Senaryo | Gönderilen JSON | Davranış |
|---|---|---|
| Yalnız başlık düzenleme | `Satirlar` alanı **hiç yok** | Satırlara dokunulmaz |
| Barkod okutarak tek satır ekleme (mobil depo) | `Baslik: {ID: 5567}` + tek elemanlı `Satirlar` | Yalnız o satır işlenir |
| Tüm belgeyi kaydetme | başlık + tüm satırlar + `"SatirModu":"tam"` | Gönderilmeyen satırlar silinir (senkron) |
| Varsayılan | `"SatirModu":"delta"` | Yalnız gelen satırlar eklenir/güncellenir/silinir |

Yani "satır satır çalışan mobil" için ayrı bir `sp_Api_BelgeSatir_Yaz_Json` yazmaya gerek yok; aynı nesneye tek satırlık `Satirlar` dizisi gönderilir. Sözleşme tek, iş kuralı tek yerde.

**Okuma tarafı ayrı kalsın:**

- `sp_Api_Belge_Liste_Json` — çok belge, az kolon, sayfalı, sık çağrılır.
- `sp_Api_Belge_Getir_Json` — tek belge, başlık + satırlar (iki sonuç kümesi), belge açılırken bir kez.

Bunları birleştirmek listeye gereksiz satır detayı taşır; farklı şekil, farklı sıklık, farklı sayfalama.

**Silme ayrı:** `sp_Api_Belge_Sil_Json`. Silme farklı yetki ister, iptal/iade kuralları vardır ve kaydetme yolunun içinde sihirli bir alan olarak durmamalıdır (bugünkü `@FATBASLIKNO='Sil'` hatası).

### 3.2 Girdi sözleşmesi

```jsonc
{
  "Surum": 1,
  "Oturum": { "KulId": 5, "SubeId": -1, "CihazId": "..." },
  "Baslik": {
    "ID": 0,                    // 0/yok = yeni belge
    "Tur": 14, "Tipi": 1,
    "Tarih": "2026-08-07",      // ISO, string aritmetiği yok
    "RehberId": 1874,
    "DepoId": 3,                // ad değil ID (bugün depo ADIYLA aranıyor)
    "Doviz": { "Cinsi": "USD", "Kur": 34.15 },   // kur İSTEMCİDEN/tarihten, satır başına sorgu yok
    "ProjeId": null, "Aciklama": "", "OzelKod": "", "OzelKod2": ""
  },
  "Satirlar": [
    { "Sira": 1, "ID": 0, "UrunId": 505, "Tur": "Stok",
      "Miktar": 2.75,            // DECIMAL(18,6) — int değil
      "BirimFiyat": 150.00, "Iskonto": 10, "Kdv": 20,
      "SeriLot": [ { "SeriLotId": 12, "Miktar": 2.75 } ] },
    { "Sira": 2, "ID": 991, "Sil": true }        // satır silme: alan, sihirli string değil
  ]
}
```

- `Sira` alanı zorunlu → `OUTPUT` sırası varsayımı ortadan kalkar.
- Yeni alan eklemek imzayı kırmaz; `Surum` ileri uyumluluk sağlar.
- Silme ayrı nesne / açık `Sil` alanı ile.

### 3.3 Çıktı sözleşmesi

Yazma SP'leri **veri değil sonuç** döndürür — tek satır, tek JSON kolonu:

```jsonc
{ "Sonuc": 1, "BelgeId": 5567, "BelgeNo": "A-000123",
  "Satirlar": [ {"Sira":1,"ID":9001}, {"Sira":2,"ID":0} ],
  "Uyarilar": [], "Mesaj": "" }
```

Hata durumunda `Sonuc: 0` + `Mesaj` **ve** `THROW` — istemci hem yapılandırılmış hem de sürücü seviyesinde hatayı görür. Sonuç kümesi olarak hata metni dönmez.

Okuma SP'leri klasik sonuç kümesi döndürür (açık kolon listesi, `SELECT *` yok), `sp_Prog_*_Json2` ile aynı davranış.

### 3.4 İskelet

```sql
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Kaydet_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;              -- kopan bağlantıda transaction açık kalmaz

    DECLARE @BelgeId INT   = TRY_CAST(JSON_VALUE(@Kosullar,'$.Baslik.ID') AS INT);
    DECLARE @Tur     INT   = TRY_CAST(JSON_VALUE(@Kosullar,'$.Baslik.Tur') AS INT);
    DECLARE @KulId   INT   = TRY_CAST(JSON_VALUE(@Kosullar,'$.Oturum.KulId') AS INT);
    -- ... diğer başlık alanları

    -- 1) DOĞRULAMA (yazmadan önce, tek yerde)
    IF @KulId IS NULL              THROW 51001, N'Oturum bilgisi eksik.', 1;
    IF @Tur   IS NULL              THROW 51002, N'Belge türü zorunlu.', 1;
    -- yetki kontrolü, depo/cari var mı, belge kilitli mi ...

    BEGIN TRY
        BEGIN TRAN;

        -- 2) BAŞLIK  (SCOPE_IDENTITY, @@IDENTITY değil)
        IF ISNULL(@BelgeId,0) = 0
        BEGIN
            INSERT INTO FATBASLIK (...) VALUES (...);
            SET @BelgeId = SCOPE_IDENTITY();
        END
        ELSE
            UPDATE FATBASLIK SET ... WHERE ID = @BelgeId;
            -- INSERT ve UPDATE AYNI kolon kümesini yazar

        -- 3) SATIRLAR — küme işlemi, satır başına çağrı yok
        DECLARE @S TABLE (Sira INT, ID INT, UrunId INT, Miktar DECIMAL(18,6),
                          BirimFiyat DECIMAL(18,6), Iskonto DECIMAL(9,4), Kdv DECIMAL(9,4), Sil BIT);
        INSERT @S
        SELECT Sira, ID, UrunId, Miktar, BirimFiyat, Iskonto, Kdv, ISNULL(Sil,0)
        FROM OPENJSON(@Kosullar,'$.Satirlar')
        WITH (Sira INT, ID INT, UrunId INT, Miktar DECIMAL(18,6),
              BirimFiyat DECIMAL(18,6), Iskonto DECIMAL(9,4), Kdv DECIMAL(9,4), Sil BIT);

        DELETE F FROM FATURA F INNER JOIN @S S ON S.ID = F.ID WHERE S.Sil = 1 AND F.FATBASID = @BelgeId;
        UPDATE F SET ... FROM FATURA F INNER JOIN @S S ON S.ID = F.ID WHERE S.Sil = 0 AND F.FATBASID = @BelgeId;
        INSERT INTO FATURA (...) SELECT ... FROM @S S WHERE S.Sil = 0 AND ISNULL(S.ID,0) = 0;

        -- 4) SERİ/LOT — yalnız BU belgenin BU satırının kayıtları silinir
        --    (STOKID tek başına filtre DEĞİL; Sira ile eşleme, OUTPUT sırasına güvenilmez)

        -- 5) BAŞLIK TOPLAMLARI — belge başına BİR kez
        UPDATE B SET FATURA_MATRAHI = T.Matrah, KDV_TUTARI = T.Kdv, FATURA_TUTARI = T.Matrah + T.Kdv
        FROM FATBASLIK B
        CROSS APPLY (SELECT Matrah = SUM(TUTAR), Kdv = SUM(KDVDAHILFIYAT - TUTAR)
                     FROM FATURA WHERE FATBASID = @BelgeId) T
        WHERE B.ID = @BelgeId;

        -- 6) DURUM (sabit ID hatası düzeltilmiş haliyle, inline)

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;                       -- hata sonuç kümesi olarak DÖNMEZ
    END CATCH

    SELECT (SELECT @BelgeId AS BelgeId, 1 AS Sonuc FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
```

### 3.5 Eşzamanlılık ve belge no

- Belge numarası `sp_BelgeNoGetir` ile alınmaya devam etsin ama **transaction içinde** — bugün ayrı çağrı, çakışma riski var.
- Belge güncellemede `ROWVERSION`/`DEGISTIRMETARIHI` karşılaştırması ile iyimser kilit: mobil ve Delphi aynı belgeyi açtığında son yazan diğerini sessizce ezmesin.

### 3.6 Üç istemcinin ortak kullanımı

- **Mobil:** doğrudan SP çağrısı (bugünkü gibi) veya ileride REST katmanı — JSON sözleşmesi ikisinde de aynı kalır.
- **Delphi:** `Tablo.ListeSPJson` deseni okuma için hazır; yazma için aynı JSON'u üreten tek bir yardımcı yeterli.
- **Web:** ince REST katmanı JSON'u aynen SP'ye geçirir; iş kuralı tek yerde (DB) kalır, üç istemcide tekrar edilmez.

### 3.7 Dağıtım

- Her nesne `GenUpdate/GenDepoUpdateN.sql` içinde tek kaynaktan; müşteriye GenUpdate zinciriyle gider.
- PG ikizi `pg/schema/NN_fn_api_*.sql` ve GenUpdate komutunda `#pg` etiketiyle.
- Eski `TM_*` nesneleri silinmez; mobil istemci yeni uçlara geçtikten sonra ayrı bir aşamada kaldırılır.

## 3.8 Delphi öncelikli yol (seçilen)

Delphi'nin durumu farklı: liste tarafı zaten `sp_Prog_*_Json2` ile sunucuya taşınmış, kart tarafı ise
canlı düzenlenebilir `TFDQuery` üzerinde (`SELECT F.* FROM FATBASLIK F WHERE F.ID = :Par`) ve FireDAC ile
post ediyor. Dolayısıyla monolitik `Kaydet` ile başlamak, wizard'ın tüm düzenleme modelini yeniden yazmak
demek — büyük ve riskli.

Delphi için gerçek kazanç **dağılmış iş kuralında**. Belge toplamı bugün en az 8 ayrı unit'te, her biri
kendi formülüyle hesaplanıp `FATBASLIK`'a yazılıyor:

`UFaturaWizard`, `IcerikFrame/UFaturalar`, `UFaturalar2`, `Ubelgegiris`, `UEBelgeGelen`, `UHizliGiris`,
`UHizliGunsonuDlg`, `UImport`, `UReplikasyon`, `UGiderPusulasi` — artı mobil tarafta `TM_FATURAGir` içindeki
dokuzuncu kopya. (`FATURA_MATRAHI`/`KDV_TUTARI`/`FATURA_TUTARI` geçen 283 kod satırı.)

Bu yüzden Delphi öncelikli sırada **önce hesap/yan-etki servisleri** yazılır; her biri tek bir çağrı
yerine geçtiği için call-site bazında, tek tek ve geri alınabilir şekilde benimsenir:

| Nesne | Ne yapar | Delphi'de nereye girer |
|---|---|---|
| `sp_Api_Belge_ToplamHesapla_Json` | `@BelgeId` → matrah/KDV/ek vergi/döviz/maliyet **tek formülle** hesaplar, `FATBASLIK`'a yazar, sonucu JSON döner | Yukarıdaki 8+ hesap yerinin her biri sırayla |
| `sp_Api_Belge_DurumHesapla_Json` | Kısmi/tamamlandı durumu (TM'deki sabit `10224` hatası düzeltilmiş) | Belge kaydı ve dönüşüm sonrası |
| `sp_Api_Belge_SeriLot_Yaz_Json` | Seri/lot + `STOKIZLEME`/`STOKIZLEMEDEPO` yazımı, belge+satır filtreli silme | Wizard'ın seri/lot kaydetme yolu |
| `sp_Api_Belge_Getir_Json` | Tek belge başlık + satır, salt okuma | Kart ekranında **değil**; e-Belge oluşturucu, önizleme, iade/referans seçimi, dönüşüm kaynağı |
| `sp_Api_Belge_Kaydet_Json` | Belge bütünü, tek transaction | Önce mobil/web; Delphi wizard'ı en son, ayrı iş olarak |

Bu sırada Delphi ilk günden kazanır (formül tek yerde, PG'de de aynı), mobil aynı nesneleri devraldığında
iş kuralı kendiliğinden ortaklaşır, kimsenin mevcut düzenleme modeli bozulmaz.

## 4. Sıra önerisi

1. `sp_Api_Belge_Getir_Json` + `sp_Api_Belge_Liste_Json` (salt okuma — risksiz, sözleşme oturur).
2. `sp_Api_Belge_Kaydet_Json` (başlık + satır + seri/lot, tek transaction).
3. `sp_Api_Belge_Sil_Json`.
4. PG ikizleri + differential test.
5. Mobil istemci geçişi, sonra `TM_*` kullanımdan kaldırma.
