# TM_* Mobil SP Seti — İnceleme ve Modernizasyon Değerlendirmesi

**Tarih:** 2026-08-07 · **Kaynak:** `BILIMPLANT` (84 SP, canlı ve güncel) · **Karşılaştırma:** `BILIM` (68), `SDI` (84), `KOSINUS` (72), `Henmed` (71)

## 1. Envanter

| Ölçüt | Değer |
|---|---|
| Toplam SP | 84 |
| Salt-okuma (liste/rapor) | 52 |
| Yazan (INSERT/UPDATE/DELETE) | 32 |
| Toplam satır | ~9.200 |
| Ortalama parametre | 6,2 — **en fazla 38** (`TM_FATURAGir` 33, `TM_FATBASLIKGuncelle` 38) |
| Delphi uygulamasından çağrılan | **1** — `TM_SiparisDurumGuncelle` (`IcerikFrame/UFaturalar.pas:3659`, "Durumu Güncelle" menüsü). Kalanı mobile ait. |

`BILIMPLANT` referans alınmalı: `BILIM`'de 17 SP hiç yok, diğer müşteri DB'lerinde sürümler farklı. Şu an **tek bir "doğru sürüm" yok** — her DB'de ayrı ayrı yaşıyor.

> **Uyarı:** `SP/tm_procs_definitions.txt` içindeki Türkçe karakterler bozuk (`Alış` → `Al??`). Canlı DB tanımları sağlam; bozulma `sqlcmd -o` çıkarımında oluşmuş. Çalışmaya başlamadan tanımlar **UTF-8 / `-f 65001`** ile yeniden çekilmeli, bu dosya kaynak kabul edilmemeli.

## 2. Bulgular

### 2.1 Sözleşme (asıl modernizasyon konusu)

- **Konumsal parametre patlaması.** `TM_FATURAGir` 33, `TM_FATBASLIKGuncelle` 38 parametre alıyor. Yeni alan = tüm istemcilerde imza kırılması. Mobil + Delphi + web'in aynı SP'yi çağıracağı bir dünyada sürdürülemez.
- **Tarih parametreleri VARCHAR** (12 SP). `@BASTAR VARCHAR(10)` istemcinin kültür ayarına göre farklı yorumlanır; ayrıca `SET @BASTAR = @BASTAR + ' 00:00:00'` gibi string aritmetiği var.
- **Sonuç kümesi sözleşmesi yok.** 47 SP `SELECT *` içeriyor — tabloya kolon eklenince istemcide kolon sırası/sayısı değişiyor. 52 SP'de `ORDER BY` gömülü, istemci sıralamayı değiştiremiyor.
- **JSON zaten kısmen var:** 7 SP `@JSON NVARCHAR(MAX)` kullanıyor (`TM_Whatsappmesaj`, `TM_UretimOlcumDetay`, `TM_FatBaslikEkalanlar`...). Desen tanıdık, yaygınlaştırılması gerekiyor.

### 2.2 Güvenlik

- **`TM_UserGiris` şifreyi istemciye döndürüyor** (`SELECT ... SIFRE ...`). Doğrulama istemcide yapılıyor demek. Şifre `REHBERBILGI.BILGI` içinde düz metin görünüyor. Kimlik doğrulama sunucuya taşınmalı; SP asla şifre/hash döndürmemeli.
- **9 SP'de string birleştirmeli dinamik SQL** (`exec(@sql)`), parametre bağlanmadan: `set @sql = @sql + 'and EMIRNO = ''' + @EMIRNO + ''''`. Enjeksiyon yüzeyi. `TM_KDRSonucDetay` DB'de saklı SQL metnini `REPLACE` ile doldurup çalıştırıyor — en riskli olanı.
- `TM_UserGiris` her çağrıda `TMLOG`'a yazıyor ama başarılı/başarısız ayrımı yok.

### 2.3 Doğruluk

- **`TM_FATURAGir.@MIKTAR int` ve `@ADET int`** — küsuratlı miktar (0,5 kg / 2,75 m) **sessizce kırpılıyor**. Fiyat `float`, miktar `int`. Veri kaybı hatası; taşımadan bağımsız olarak düzeltilmeli.
- `TM_AlisSatisAylar` `@BITTAR` parametresini hiç kullanmıyor (ölü parametre; filtre uygulanıyor sanılır).
- `TM_AlisSatisAylar` içinde `SET LANGUAGE Turkish` + sonda `us_english` — oturum dilini değiştiriyor; bağlantı havuzunda yan etki. Ay adı sunucuda değil istemcide üretilmeli.
- **32 yazan SP'nin hiçbirinde `BEGIN TRANSACTION` yok.** Çok tablolu yazımlar (fatura satırı + stok + seri/lot) yarım kalabilir. 13'ünde TRY/CATCH var ama transaction olmadığı için geri alma yok.

### 2.4 Performans

- **83/84 SP'de `SET NOCOUNT ON` yok** — her ifade için istemciye gereksiz `DONE_IN_PROC` paketi. Mobil/uzak bağlantıda ölçülebilir maliyet.
- **Sayfalama yok.** Sadece 2 SP'de `TOP`/`OFFSET` var. Liste SP'leri tüm tabloyu döndürüyor. Müşterilerin tamamı SQL Server **Express** kullanıyor — geniş sonuç kümeleri `RESOURCE_SEMAPHORE`'da bekletir.
- Ağır SP'ler: `TM_MobilAyarlar` 31 JOIN, `TM_SAP_*KDRSonucDetay` 48 JOIN / 350+ satır, `TM_StokAra` 36 JOIN / 85 SELECT.
- 5 SP'de dağınık `NOLOCK` — tutarlılık garantisi olmadan, üstelik tutarsız uygulanmış.
- Filtreler çoğunlukla `ISNULL(@p,'')=''` deseniyle — parametre duyarlı plan sorunları ve index kullanılamaması.

### 2.5 Bakım / tekrar

Yakın kopya aileler (tek gövdeye indirilebilir):

| A | B | Benzerlik |
|---|---|---|
| `TM_FaturaDetay` | `TM_SiparisAlinanDetay` | **%98** |
| `TM_SAP_ENG_KDRSonucDetay` | `TM_SAP_KDRSonucDetay` | **%94** |
| `TM_FatBaslikEkalanlar` | `TM_UretimPersonelZamanPlanlaEkalanlar` | %88 |
| `TM_FATBASLIK` | `TM_SiparisAlinan` | %88 |
| `TM_DonusumListeleriAlis` | `TM_DonusumListeleriSatis` | %65 (+ `TM_DonusumListeleri`) |

İsimlendirme de tutarsız: `TM_MobilAyarlar` / `TM_MobilAyarlar1`, `TM_Imaj` / `TM_ImajListele` / `TM_Imaj_Disk` / `TM_Imaj_Okuma_Disk`, karışık büyük-küçük harf (`TM_FATBASLIK` vs `TM_FatBaslikEkalanlar`).

## 3. Hedef mimari

Delphi tarafında **zaten çalışan** bir desen var: `sp_Prog_<Modül>_<Liste>_Json2(@Baslik, @Kosullar)` + PG ikizi `fn_prog_<modül>_<liste>_json2`. `BILIM`'de 29 adet Json2 SP'si üretimde. TM_ setini sıfırdan bir şey icat etmeden bu sözleşmeye taşımak en düşük riskli yol — Delphi, mobil ve web aynı nesneyi çağırır.

### 3.1 İsimlendirme

```
sp_Api_<Modül>_<İşlem>_Json      -- MSSQL
fn_api_<modül>_<işlem>_json      -- PostgreSQL ikizi
```

`sp_Prog_` (Delphi'ye özel ekran listeleri) ile ayrı tutulur; `sp_Api_` çok-istemcili sözleşmedir. Örnek eşleme:

| Eski | Yeni |
|---|---|
| `TM_FATBASLIK`, `TM_SiparisAlinan` | `sp_Api_Belge_Liste_Json` (`Tur` parametresiyle) |
| `TM_FaturaDetay`, `TM_SiparisAlinanDetay` | `sp_Api_Belge_Detay_Json` |
| `TM_FATURAGir`, `TM_SiparisDetayGir` | `sp_Api_Belge_SatirYaz_Json` |
| `TM_StokAra`, `TM_StokAraDetay`, `TM_StokAraSayim` | `sp_Api_Stok_Ara_Json` (`Mod` parametresi) |
| `TM_UserGiris` | `sp_Api_Kimlik_Giris_Json` (şifre **döndürmez**, doğrular) |

84 SP → tahmini **~45-50** nesne.

### 3.2 Sözleşme

```sql
CREATE OR ALTER PROCEDURE dbo.sp_Api_<X>_Json
    @Kosullar NVARCHAR(MAX),      -- girdi: JSON
    @Baslik   NVARCHAR(MAX) = N'' -- opsiyonel ek-kolon parcasi (mevcut Json2 deseniyle ayni)
```

- Girdi tek JSON: `{"Surum":1,"KulId":5,"Sayfa":1,"SayfaBoyu":50,"Sirala":"TARIH desc","Filtre":{...}}`
- **Yeni alan eklemek imzayı kırmaz** — istemciler kademeli güncellenir. `Surum` alanı ileri uyumluluk verir.
- Çıktı: açık kolon listesi (asla `SELECT *`), sabit kolon adları. Yazan SP'ler `{"Sonuc":1,"ID":123,"Mesaj":""}` şeklinde tek satır JSON döndürür.
- Sıralama/sayfalama **parametreyle**, gömülü `ORDER BY` ile değil. `SayfaBoyu = 0` → sınırsız (mevcut `TopN = 0` kuralının aynısı).

### 3.3 Zorunlu kurallar

1. `SET NOCOUNT ON` + `SET XACT_ABORT ON` her SP'de.
2. Yazan her SP `BEGIN TRAN` / `COMMIT` / `CATCH → ROLLBACK` içinde.
3. Dinamik SQL yalnızca `sp_executesql` + parametre bağlama; kullanıcı verisi asla birleştirilmez.
4. Tarih/sayı parametreleri JSON'da doğal tipte, `TRY_CAST` ile okunur; VARCHAR tarih yok.
5. `SELECT *` yok; kolon sözleşmesi dokümante edilir.
6. Kimlik/yetki sunucuda; şifre/hash asla dönmez.
7. Her nesne `GenUpdate/GenDepoUpdateN.sql`'e girer (tek kaynak), müşteriye GenUpdate zinciriyle gider — bugünkü gibi DB'den DB'ye elle kopyalanmaz.
8. PG ikizi aynı anda yazılır (`pg/schema/NN_fn_api_*.sql`), `#pg` etiketiyle dağıtılır.

### 3.4 Performans kazanımı

- `NOCOUNT` + sayfalama + `SELECT *` kaldırma: mobil liste ekranlarında en büyük kazanç.
- Ağır olanlarda (`TM_MobilAyarlar` 31 JOIN, `TM_SAP_*` 48 JOIN) opsiyonel JOIN deseni: detay tablosu yalnızca ilgili filtre/kolon istendiğinde bağlanır — Express bellek grant sorununun bilinen çözümü.
- 5 yakın-kopya aile tek gövdeye inince plan cache tekrar kullanımı artar.

## 4. Kademeli geçiş (geriye uyumlu)

| Aşama | İş | Risk |
|---|---|---|
| 0 | Tanımları `BILIMPLANT`'tan UTF-8 doğru çıkar, `GenUpdate/` altına sürümle. DB'ler arası fark raporu. | yok |
| 1 | Kritik hataları yerinde düzelt: `@MIKTAR/@ADET` ondalık, `SET NOCOUNT ON`, `TM_UserGiris` şifre sızıntısı, 9 enjeksiyon noktası, yazanlara transaction. | düşük |
| 2 | `sp_Api_*_Json` nesnelerini **yeni** olarak yaz; eski `TM_*` aynen dursun (mobil kırılmaz). Yakın kopyaları birleştir. | düşük |
| 3 | Mobil istemciyi yeni uçlara al; Delphi'nin ihtiyaç duyduğu yerlerde aynı SP'yi kullan. | orta |
| 4 | PG ikizlerini yaz, iki motorda differential test (`pg/tools/db_diff.ps1`). | orta |
| 5 | `TM_*` nesnelerini kullanımdan kaldır (önce log, sonra sil). | düşük |

Aşama 1 tek başına dağıtılabilir ve mobil uygulamada değişiklik gerektirmez.

## 5. Önce yapılacaklar (öneri sırası)

1. `TM_FATURAGir` / `TM_SiparisDetayGir` miktar tipi — **veri kaybı**, acil.
2. `TM_UserGiris` — şifre döndürmeyi kes.
3. 9 dinamik SQL noktasını parametreli hale getir.
4. 32 yazan SP'ye transaction + `XACT_ABORT`.
5. Tüm sete `SET NOCOUNT ON`.
6. Sonra `sp_Api_*_Json` yazımına başla — en çok kullanılan 5 liste ekranından.
