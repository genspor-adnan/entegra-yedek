# Belge (Fatura/İrsaliye/Sipariş/Fiş) — Yeni SP Kataloğu

Kapsam: Delphi öncelikli, mobil ve web aynı nesneleri kullanacak. Eski `TM_*` yerinde kalır.
Sözleşme: `@Kosullar NVARCHAR(MAX)` (JSON) girdi; okumalarda sonuç kümesi, yazmalarda tek satır JSON sonuç.
Her nesnenin PG ikizi: `fn_api_<ad>` (`pg/schema/NN_*.sql`), GenUpdate komutunda `#pg` etiketli.

## A. Zaten var — yeniden yazılmayacak, kullanılacak

| Nesne | İş |
|---|---|
| `sp_BelgeNoGetir` | Belge no/seri üretimi (kocan bazlı) |
| `sp_Prog_Fatura_Silinebilir_Mi` | Kilit + e-belge + kullanım/izleme/UTS/dönüşüm kontrolü, tek çağrıda |
| `sp_Prog_Siparis_Silinebilir_Mi` | Sipariş için aynısı |
| `sp_Prog_BelgeDonusum_Kaynak_Json2` | Dönüşüm kaynak satır listesi |
| `sp_Prog_AlisSatis_IrsFatFisKons_Json2`, `sp_Prog_AlisSatis_Siparis_Json2` | Delphi grid listeleri (mobil için ayrı `sp_Api_Belge_Liste_Json` yazılacak) |

## B. Hesap / yan etki servisleri (1. dalga — Delphi ilk günden kazanır)

| Nesne | Girdi | İş | Yerine geçtiği |
|---|---|---|---|
| `sp_Api_Belge_ToplamHesapla_Json` | `{BelgeId}` | Matrah/KDV/ek vergi/ÖTV/döviz/maliyet **tek formülle**; `FATBASLIK`'a yazar, hesaplananı döner | Delphi'de 9 ayrı hesap yeri + `TM_FATURAGir` içindeki kopya |
| `sp_Api_Belge_DurumHesapla_Json` | `{BelgeId}` | Kısmi/tamamlandı/yeni durumu (dönüşüm miktarına göre) | `TM_FATBASLIKDurumGuncelle` (sabit `10224` hatası düzeltilmiş) |
| `sp_Api_Belge_SeriLot_Yaz_Json` | `{BelgeId, SatirId, UrunId, SeriLot:[...]}` | `STOKSERILOT`/`STOKIZLEME`/`STOKIZLEMEDEPO` yazımı; silme **belge+satır** filtreli, `Sira` ile eşleme | `TM_FATURAGir` içindeki seri/lot bloğu (ürünün tüm seri/lotunu silen hatalı `DELETE` olmadan) |

Bunlar tek satırlık çağrı yerine geçtiği için Delphi'de call-site bazında, tek tek benimsenir.

## C. Silme (2. dalga — istenen öncelik)

Delphi'deki `TTablo.FaturaSil` bugün doğru işi yapıyor ama **Pascal'da**: mobil aynı belgeyi sildiğinde
(`TM_FATBASLIKGuncelle` ile `@FATBASLIKNO='Sil'`) yalnızca `DELETE FROM FATURA` + `DELETE FROM FATBASLIK`
çalışıyor — log yok, stok izleme yok, kasa/imaj temizliği yok, kontrol yok. **Aynı belge iki istemciden
farklı sonuçla siliniyor.** Silmeyi SP'ye almanın asıl gerekçesi bu.

| Nesne | İş |
|---|---|
| `sp_Api_Belge_Sil_Json` | Belge silme: kontrol → **loglama** → FK sırasına göre silme, tek transaction |
| `sp_Api_Log_KayitSil_Json` | Genel amaçlı SQL tarafı silme-loglayıcı (aşağıda) |
| `sp_Api_Log_DetaySil_Json` | Detay tablo satırlarını toplu logla (`STOKIZLEME`, `STOKIZLEMEDEPO`, `*_USER`) |

### C.1 `sp_Api_Belge_Sil_Json` akışı

```
{ "BelgeId": 5567, "Oturum": {"KulId":5,"SubeId":-1,"Ip":"","Istasyon":""},
  "KilitKaldirildi": false, "Gerekce": "" }
```

1. **Kontrol** — `sp_Prog_Fatura_Silinebilir_Mi` / `_Siparis_` (türe göre). Engel varsa hiç yazmadan
   `{"Sonuc":0,"Mesaj":"..."} `+ `THROW`.
2. `BEGIN TRAN` (`SET XACT_ABORT ON`).
3. **Loglama — silmeden ÖNCE** (Geri Al'ın çalışması buna bağlı), Delphi'deki sırayla birebir:
   - kart: `FATBASLIK` (TabNo belge türüne göre: irsaliye gelen/giden, fiş, transfer, üretim, konsinye, gider pusulası...)
   - her satır: `FATURA`, ardından `FATURA_USER`
   - `STOKIZLEME`, sonra `STOKIZLEMEDEPO` (restore sırası FK için böyle)
   - `FATBASLIK_USER`
4. **Silme**, FK sırasına göre: `STOKIZLEME` → `STOKLOKASYON` → (üretim fişiyse artık kullanılmayan `STOKSERILOT`) →
   `FATURA` → `REHBERBILGI` (detay şablon) → `IMAJ` (YERI=31) → `KASA` (TUR 61,71) → `FATBASLIK`.
5. Gider pusulasıysa kaynak fatura satırının iade miktarını güncelle.
6. `COMMIT` → `{"Sonuc":1,"BelgeId":5567,"SilinenSatir":n}`.

Bugüne göre kazanç: **tek transaction** (bugün ayrı bağlantıda, transaction'sız — yarıda kalırsa belge
kısmen silinmiş kalıyor), tek uygulama, mobil de aynı korumaları alıyor.

### C.2 SQL tarafı loglayıcı — kritik nokta

`ISLEMLOG.BILGI` alanı **JSON**; `LogGeriAl` bu JSON'dan dinamik `INSERT` üretiyor. Silme SP'ye
taşınırken log yazımı da SQL tarafında olmalı ve **aynı JSON biçimini** üretmeli, yoksa Geri Al bozulur.

`sp_Api_Log_KayitSil_Json` yapısı:
- `sys.columns` üzerinden satırı okur, `fkData` olmayan/BLOB/boş alanları atlar (Pascal'daki `LogKayitSil` ile aynı kural),
- `FOR JSON` ile `{"KOD":"...","UNVAN":"..."}` biçiminde `BILGI` üretir,
- `GENDEPO.dbo.LOG<yyyy>`'ye `ULog.LogYaz` ile birebir aynı kolonlarla yazar
  (`IP, ISTASYON, KULLANICIID, SUBEID, ISLEMTIPI, ALTISLEMTIPI, USTTABLOID, USTKAYITID, TABLOID, KAYITID, REHBERID, STOKID, BILGI`),
- depo adı sabit değil: `ULog.DepoTablo` mantığı SQL tarafında da uygulanmalı (synonym'e bağımlı kalınmamalı).

**Doğrulama yöntemi:** aynı belge iki kez silinir — biri bugünkü Pascal yoluyla, biri yeni SP ile —
`ISLEMLOG` satırları karşılaştırılır. Birebir aynı olmalı; sonra ikisinde de "Geri Al" denenir.

BLOB yedeği (`LogBlobYedekle` → `GENDEPO.DOSYA`) 1. sürümde Pascal'da kalabilir; belge silmede
kart blob'u yok, resim `IMAJ`/`DOSYA` üzerinden zaten korunuyor.

## D. Dönüşüm (sipariş → irsaliye → fatura, irsaliye → fatura, teklif → sipariş)

Bugün: kaynak listesi `sp_Prog_BelgeDonusum_Kaynak_Json2`'den geliyor, **dönüşümü yazan kod Delphi'de**;
bağ `FATURA.YERI` (409/410/429/473) + `FATURA.YERID` ile kuruluyor. Mobilde karşılığı yok —
`TM_DonusumListeleri` / `...Alis` / `...Satis` yalnızca **rapor** amaçlı, dönüşüm yapmıyor.

| Nesne | Girdi | İş |
|---|---|---|
| `sp_Api_Donusum_Kaynak_Json` | `{HedefTur, RehberId, Depo, Tarih aralığı, Filtre}` | Dönüştürülebilir kaynak satırlar + kalan miktar (açık bakiye), sayfalı |
| `sp_Api_Donusum_Uygula_Json` | `{HedefBelgeId?, HedefTur, KaynakSatirlar:[{SatirId, Miktar, SeriLot:[...]}]}` | Hedef belge yoksa oluşturur, satırları kopyalar, `YERI`/`YERID` bağını kurar, kalan miktarı denetler, seri/lot taşır, toplam+durum hesaplar — **tek transaction** |
| `sp_Api_Donusum_Geri_Json` | `{HedefBelgeId}` veya `{HedefSatirId}` | Dönüşümü geri alır (bağı çözer, kaynak kalan miktarını iade eder) |
| `sp_Api_Donusum_Rapor_Json` | `{BasTarih, BitTarih, Yon, Filtre}` | `TM_DonusumListeleri` + `...Alis` + `...Satis` üçlüsünün yerine tek nesne (`Yon` parametresiyle; üçü %65 aynı kod) |

`Donusum_Uygula` içinde iki kural mutlaka sunucuda olmalı — bugün istemcide:
**aşırı dönüşüm koruması** (kalan miktardan fazlası dönüştürülemez; iki istemci aynı anda dönüştürürse
bugün ikisi de geçer) ve **kaynak kilidi** (dönüştürülmüş belge silinemez/değiştirilemez).

## E. Okuma

| Nesne | Kullanım |
|---|---|
| `sp_Api_Belge_Liste_Json` | Mobil/web belge listesi — sayfalı, `Tur` ile filtre. `TM_FATBASLIK` + `TM_SiparisAlinan` (%88 aynı) yerine tek nesne |
| `sp_Api_Belge_Getir_Json` | Tek belge: başlık + satırlar. Mobil belge açma; Delphi'de kart ekranında **değil**, e-Belge oluşturucu / önizleme / iade referansı / dönüşüm kaynağı gibi salt-okuma yerlerde. `TM_FATBASLIK`+`TM_FaturaDetay` ikilisi yerine tek çağrı |
| `sp_Api_Belge_EkAlan_Json` | `FATBASLIK_USER` / `FATURA_USER` ek alan tanımı + değerleri. `TM_FatBaslikEkalanlar` yerine (dinamik SQL'i parametreli hale getirilmiş) |

## F. Yazma (3. dalga — mobil/web önce, Delphi wizard'ı en son)

| Nesne | Kullanım |
|---|---|
| `sp_Api_Belge_Kaydet_Json` | Başlık + satırlar + seri/lot, tek transaction. `SatirModu: delta\|tam`. `TM_FATBASLIKGuncelle` (38 parametre) + `TM_FATURAGir` (33 parametre) yerine |

## G. Uygulama sırası

1. **B grubu** — `ToplamHesapla`, `DurumHesapla`, `SeriLot_Yaz`. Delphi'de call-site bazında benimsenir, mobil sonra devralır.
2. **C grubu** — `Belge_Sil` + SQL tarafı loglayıcı. Delphi `TTablo.FaturaSil` bu SP'yi çağırır hale gelir; mobilin silme davranışı bir anda Delphi ile eşitlenir.
3. **D grubu** — `Donusum_Kaynak` / `Donusum_Uygula` / `Donusum_Geri`, sonra `Donusum_Rapor`.
4. **E grubu** — okuma nesneleri (mobil geçişiyle birlikte).
5. **F grubu** — `Belge_Kaydet`; Delphi wizard'ı en son, ayrı iş olarak.

Her adımda PG ikizi aynı anda yazılır ve `pg/tools/db_diff.ps1` ile iki motor karşılaştırılır.
