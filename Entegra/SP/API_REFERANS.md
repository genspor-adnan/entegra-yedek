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

Ortak altyapı: **`dbo.fn_Api_Belge_DipToplam(@BelgeId)`** — belge dip toplam kümesi (TUR 1=Toplam,
2=ÖTV, 3=İskonto, 4=Ara Toplam, 5/6/7=KDV satırları, 8=Ek Vergi, 9=Stopaj, 15=KDV Toplam,
20=Genel Toplam). Kanonik formülün tek kopyası; `SP_PRG_FaturaDipToplami` de bunu okur.

| Nesne | Durum | Girdi | Çıktı | Not |
|---|---|---|---|---|
| `sp_Api_Belge_ToplamHesapla_Json` | 🟨 MSSQL hazır, PG bekliyor | `{BelgeId,Yaz,Zorla}` | `{Sonuc,BelgeId,Kapsam,Neden,Yazildi,Matrah,Kdv,Toplam,Doviz,Maliyet,EkVergi}` | Kanonik formül `fn_Api_Belge_DipToplam` TVF'i. Gelen e-belge ve üretim fişinde `Kapsam=disi` → yazmaz (`Zorla=1` hariç). `GenDepoUpdate68.sql` |
| `sp_Api_Belge_DurumHesapla_Json` | ⬜ | `{BelgeId}` | `{Sonuc,Durum}` | Kısmi/tamam/yeni |
| `sp_Api_Belge_SeriLot_Yaz_Json` | ⬜ | `{BelgeId,SatirId,UrunId,SeriLot:[]}` | `{Sonuc,Satir:[]}` | Silme belge+satır filtreli |

### C. Silme

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Belge_Sil_Json` | ⬜ | `{BelgeId,Oturum,KilitKaldirildi,Gerekce}` | `{Sonuc,BelgeId,SilinenSatir}` |
| `sp_Api_Log_KayitSil_Json` | ⬜ | `{Tablo,TabNo,KayitId,UstTabNo,UstId,Oturum}` | `{Sonuc,LogId}` |
| `sp_Api_Log_DetaySil_Json` | ⬜ | `{Tablo,Kosul,TabNo,UstTabNo,UstId,Oturum}` | `{Sonuc,Adet}` |

### D. Dönüşüm

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Donusum_Kaynak_Json` | ⬜ | `{HedefTur,RehberId,DepoId,BasTarih,BitTarih,Filtre,Sayfa,SayfaBoyu}` | sonuç kümesi |
| `sp_Api_Donusum_Uygula_Json` | ⬜ | `{HedefBelgeId?,HedefTur,KaynakSatirlar:[]}` | `{Sonuc,HedefBelgeId,Satirlar:[]}` |
| `sp_Api_Donusum_Geri_Json` | ⬜ | `{HedefBelgeId}` \| `{HedefSatirId}` | `{Sonuc,Adet}` |
| `sp_Api_Donusum_Rapor_Json` | ⬜ | `{BasTarih,BitTarih,Yon,Filtre}` | sonuç kümesi |

### E. Okuma

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Belge_Liste_Json` | ⬜ | `{Tur,BasTarih,BitTarih,Filtre,Sayfa,SayfaBoyu,Sirala}` | sonuç kümesi |
| `sp_Api_Belge_Getir_Json` | ⬜ | `{BelgeId}` | 2 sonuç kümesi (başlık, satırlar) |
| `sp_Api_Belge_EkAlan_Json` | ⬜ | `{Yer,KayitId}` | tanım + değerler |

### F. Yazma

| Nesne | Durum | Girdi | Çıktı |
|---|---|---|---|
| `sp_Api_Belge_Kaydet_Json` | ⬜ | `{Surum,Oturum,Baslik,Satirlar,SatirModu}` | `{Sonuc,BelgeId,BelgeNo,Satirlar:[]}` |

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
