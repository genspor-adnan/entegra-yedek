## Bölüm 1: TM_AlisSatisAylar - TM_FatBaslikEkalanlar (satır 1-2310)

### TM_AlisSatisAylar
**Amaç:** Belirtilen yıl için aylık alış/satış (fatura matrahı) toplamlarını, ay adına göre gruplanmış şekilde raporlar.
**Parametreler:** `@BASTAR VARCHAR(4)` (yıl), `@BITTAR VARCHAR(4)` (tanımlı ama kodda hiç kullanılmıyor).
**Tablolar:** `FATBASLIK` (okuma).
**Notlar:** `SET LANGUAGE Turkish` ile ay isimleri Türkçe alınıyor, sonda `us_english`'e dönülüyor. TUR IN (11,12) alış, TUR IN (15,16) satış. `@BITTAR` kullanılmıyor — muhtemelen bug.

### TM_AlisSatisYillar
**Amaç:** Belirtilen tarih aralığındaki yılların alış/satış toplamlarını yıl bazında özetler (çok yıllı trend).
**Parametreler:** `@BASTAR`, `@BITTAR` (yıl, dahili DATETIME'a çevriliyor).
**Tablolar:** `FATBASLIK`.
**Notlar:** TUR IN (11,12,13) alış, TUR IN (15,16,17) satış (aylık versiyondan bir tür fazla).

### TM_CariExtre
**Amaç:** Bir cari hesabın belirli tarih aralığındaki ekstresini "Özet" veya "Detay" modunda, borç/alacak bakiyeleriyle listeler.
**Parametreler:** `@REHBERID` (KOD ile başlıyorsa REHBER.KOD'dan ID'ye çözülür), `@BASTARIH`, `@BITTARIH`, `@DetayOzet`.
**Tablolar:** `dbo.fn_Cari_Ekstre` / `dbo.fn_Cari_Detayli_Ekstre` (TVF), dolaylı `REHBER`.
**Notlar:** `GROUP BY ROLLUP(...)` ile ara/genel toplam satırları otomatik üretiliyor; TURAD alanı CASE ile "Ara Toplam :"/"Genel Toplam :" etiketlerine dönüştürülüyor.

### TM_CariExtreDetay
**Amaç:** Belirli bir fatura başlığına (FATBASID) ait satır detaylarını (ürün, adet, fiyat, iskonto, KDV, döviz tutarları) listeler.
**Parametreler:** `@ID INT` (FATBASID).
**Tablolar:** `FATURA`, `FATBASLIK`, `STOKLAR`, `MASRAFGELIR`, `GENINI`.
**Notlar:** KDV ve döviz KDV hesaplamaları KDVDURUM (Dahil/Hariç) ve OTV durumuna göre dallanan karmaşık formüllerle yapılıyor.

### TM_CiroRaporu
**Amaç:** Belirtilen tarih aralığında ciro raporu üretir: Fatura, SGK, Fiş, İade, Toplam kırılımı (Merkez şube).
**Parametreler:** `@BASTAR`, `@BITTAR`.
**Tablolar:** `FATBASLIK`, `FATURA`.
**Notlar:** TUR=15 fatura, TUR=16 fiş, TIPI=2 iade; BASLIK='SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI' SGK olarak ayrılıyor. Kodda yorum satırı halinde devre dışı, linked server (Venmed_Bornova/Fatih/Uskudar) üzerinden çoklu şube UNION ALL bloğu var — şu an pasif, sadece Merkez aktif.

### TM_CiroYuzdeDagilim
**Amaç:** Firma bazında ciro dağılımı ve kümülatif yüzdesini (Pareto/ABC analizi) hesaplar; belirli bir kümülatif yüzdeye kadar firmaları döner.
**Parametreler:** `@BASTAR`, `@BITTAR`, `@Yuzde FLOAT = 100`.
**Tablolar:** `FATBASLIK`, `REHBER`.
**Notlar:** Window function ile kümülatif oran hesaplanıyor; TUR=15 filtreleniyor.

### TM_CrmIstatistik
**Amaç:** İçinde bulunulan yıl için aylık yeni cari kayıt istatistiklerini (grup bazında) ve aylık görev sayılarını CRM dashboard'u için hazırlar.
**Parametreler:** Yok.
**Tablolar:** `REHBER`, `GENINI`, `GOREVLER`.
**Notlar:** Ay isimleri Türkçeleştirilip sıra numarasıyla (örn. "1-Ocak") formatlanıyor; iki sorgu UNION ALL ile birleşiyor; sadece cari yıl.

### TM_DashBoard
**Amaç:** Kullanıcı ana ekranı için duyuru, atanmış görev ve açık servis kayıtlarını birleştirip zaman etiketiyle ("Bugün","Yarın","X gün önce/sonra") listeler.
**Parametreler:** Tanımlı parametre yok; proc içinde `@RehberId FLOAT = 2` ve `@gunsay int = -90` sabit DECLARE ediliyor.
**Tablolar:** `DUYURU`, `UYARIAYAR`, `DUYURUKULLANICI`, `fn_prg_IsListesiBanaAtananlar` (TVF), `SERVIS`, `SERVISHAREKET`.
**Notlar:** Dikkat: `@RehberId` dışarıdan alınmıyor, kod içinde sabit (2) — kişiselleştirme çalışmıyor olabilir (muhtemel eksiklik). "Teklif Onay"/"Teklif SKT" blokları yorumla devre dışı. Sadece son 90 gün (`@GunSay`) gösteriliyor.

### TM_DokumanGuncelleListele
**Amaç:** Doküman/arşiv yönetim ekranı için tek bir dokümanı listeler, günceller veya yeni doküman/dosya ekler.
**Parametreler:** `@TIP` ('Listele'/'Guncelle'), `@ID` ve doküman meta verilerine ait çok sayıda parametre (tarih, durum, kategori, kurum, demirbaş, departman, lokasyon, arşiv süresi, gizlilik, sorumlu, klasör, belge içeriği/binary, belge türü).
**Tablolar:** `DOKUMAN` (select/update/insert), `IMAJ` (select/update/insert), `GENINI`, `REHBER`, `DEMIRBAS`, `LOKASYON`.
**Notlar:** Yeni belge eklenirken `IMAJ`'a binary yazılıyor, `sp_Imaj_Kaydetme` çağrılıyor ve **`xp_cmdshell` ile PowerShell script (`ConvertToBase64.ps1`) çalıştırılarak** dosya diske yazılıyor — güvenlik açısından dikkat çekici (xp_cmdshell kullanımı). Sonunda kendini `'Listele'` modunda tekrar çağırıyor.

### TM_DokumanKlasor
**Amaç:** Aktif doküman klasör ağacını, sıralama için hesaplanan SIRA değeriyle listeler.
**Parametreler:** Yok.
**Tablolar:** `DOKUMANKLASOR`.
**Notlar:** SIRA/SIRA1, ÜstID+ID string birleştirilip sayıya çevrilerek hiyerarşik sıralama hilesiyle hesaplanıyor. Sadece DURUM=1.

### TM_DokumanYetki
**Amaç:** Belirli bir klasördeki (ve kısayollarındaki) dokümanları tam klasör yol adıyla listeler; doküman yönetim ekranının ana veri kaynağı.
**Parametreler:** `@REHBERID`, `@KLASORID`.
**Tablolar:** `DOKUMANKLASOR` (recursive CTE), `DOKUMAN`, `IMAJ`, `REHBER`, `LOKASYON`, `DOKUMANKISAYOL`, `DOKUMANYETKI`.
**Notlar:** Recursive CTE (`Dizin`) ile klasör hiyerarşisinin tam yolu oluşturuluyor; iki UNION ALL bloğu (doğrudan klasördekiler + kısayolla bağlı olanlar).

### TM_Dokumler
**Amaç:** RaporId'ye göre ilgili raporlama saklı yordamını çağıran yönlendirici (router/dispatcher) proc.
**Parametreler:** `@BASTAR`, `@BITTAR`, `@RaporId INT`.
**Tablolar:** Doğrudan yok — alt proc çağrıları.
**Notlar:** RaporId'ye göre `TM_SatisFirsatiPerformansRaporu`, `TM_MizanToplu`, `TM_KdvOzet`, `TM_IsListesiPerformansRaporu`, `TM_CiroYuzdeDagilim`, `TM_AlisSatisYillar`, `TM_AlisSatisAylar`, `TM_CiroRaporu` çağırıyor.

### TM_DonusumListeleri
**Amaç:** Satış/alış dönüşüm listelerini (teklif→sipariş→irsaliye→fatura zinciri, üretim emri listesi) ekrana göre yönlendiren ana giriş noktası (router).
**Parametreler:** `@BasTarihi`, `@BitTarihi`, `@ekran` (örn. 'Alis1', 'Satis1', 'uel', 'siparis'), `@gizlenen`, `@kalmayan`, `@ekleyen`.
**Tablolar:** `URETIMEMRI`, `URETIMEMRIDETAY`, `STOKLAR`, `REHBER`, `LOKASYON`, `SIPARIS`, `SIPARISDETAY`, `PROJELER`, `URETIMOPERASYONFASON`, `GOREVYORUM`, `DONUSUMBILGISIGIZLE` vb.
**Notlar:** `@ekran` 'Alis%' ise `TM_DonusumListeleriAlis`, 'Satis%' ise `TM_DonusumListeleriSatis` çağrılıyor. 'uel' ve 'siparis' ekranları için kendi içinde **dinamik SQL** (string concat ile tarih parametreleri dahil) inşa edip `EXEC(@SQL)` ile çalıştırıyor — SQL injection riski taşıyan bir örüntü.

### TM_DonusumListeleriAlis
**Amaç:** Alış sürecindeki dönüşüm aşamalarını (Teklif→Sipariş→Fatura/İrsaliye/Konsinye, 6 ekran: Alis1-Alis6) listeler; "dönüşen miktar" ve "kalan miktar" hesaplanır.
**Parametreler:** `@BasTarihi`, `@BitTarihi`, `@ekran`, `@gizlenen`, `@kalmayan`.
**Tablolar:** `TEKLIF`/`TEKLIFDETAY`, `SIPARIS`/`SIPARISDETAY`, `FATBASLIK`/`FATURA`, `STOKLAR`, `REHBER`, `PROJELER`, `DONUSUMBILGISIGIZLE`, `REHBERILETISIM`.
**Notlar:** Her ekran farklı YERI/YERID koduna göre `DONUSEN`/`KALAN` hesaplıyor. `@kalmayan` tamamen dönüşmüş kayıtları, `@gizlenen` kullanıcı tarafından gizlenmiş kayıtları filtreler.

### TM_DonusumListeleriSatis
**Amaç:** Satış sürecindeki dönüşüm aşamalarını (Teklif→Sipariş→Fatura/İrsaliye, 5 ekran: Satis1-Satis5) listeler; Alış prosedürüyle simetrik satış karşılığı.
**Parametreler:** `@BasTarihi`, `@BitTarihi`, `@ekran`, `@gizlenen`, `@kalmayan`.
**Tablolar:** `TEKLIF`/`TEKLIFDETAY`, `SIPARIS`/`SIPARISDETAY`, `FATBASLIK`/`FATURA`, `STOKLAR`, `REHBER`, `PROJELER`, `DONUSUMBILGISIGIZLE`, `REHBERILETISIM`.
**Notlar:** TUR=19 (satış siparişi) ve TUR=14 (satış faturası) filtreleri; farklı YERI kodlarıyla (409/410/411/413/429 vb.) çalışıyor.

### TM_EkAlanCalistir
**Amaç:** `ALANLAR` tablosunda tanımlı, kullanıcı arama kriterine göre parametrik SQL şablonu çalıştıran genel amaçlı "ek alan arama" motoru.
**Parametreler:** `@ID` (ALANLAR kaydı), `@KOSUL` (arama metni).
**Tablolar:** `ALANLAR`.
**Notlar:** `<ara>` yer tutucusu `@KOSUL` ile değiştirilip `TOP 100` eklenerek `EXEC(@SQL)` ile çalıştırılıyor — kullanıcı girdisi doğrudan sorguya enjekte edildiği için SQL injection riski var.

### TM_EPostaHesaplari
**Amaç:** Sistemde tanımlı varsayılan e-posta hesabını/hesaplarını döner.
**Parametreler:** Yok.
**Tablolar:** `EPOSTAHESAPLARI` (VARSAYILAN=1).
**Notlar:** Çok basit, tek satırlık SELECT.

### TM_FacebookEnt
**Amaç:** Facebook/Meta Lead Ads entegrasyonundan gelen JSON lead verisini parse edip `META_Collect` tablosuna aday müşteri kaydı olarak ekler.
**Parametreler:** `@JSON NVARCHAR(MAX)`.
**Tablolar:** `META_Collect` (INSERT).
**Notlar:** `OPENJSON` ile iç içe JSON parse ediliyor; isim, telefon, e-posta, adres, şehir, ülke, cinsiyet alanları pivotlanıyor. Cinsiyet hem İngilizce hem Türkçe değerleri K/E olarak eşliyor. `FB_Support=1`, `Meta_Class=2` sabit değerlerle işaretleniyor.

### TM_FATBASLIK
**Amaç:** Fatura başlıklarını kullanıcı yetkisine (kendi faturaları/şube bazlı) göre filtrelenmiş şekilde, tarih aralığı veya tek ID için listeler; kaynağı/hedefi (teklif/servis/talep/üretimden geldiği, faturaya/irsaliyeye gittiği) hesaplayarak döner.
**Parametreler:** `@BasTarihi`, `@BitTarihi`, `@ID`, `@TAMAMLANAN`, `@BAYIID`, `@TUR`, `@KULLANICIKODU`.
**Tablolar:** `FATBASLIK`, `FATURA`, `REHBER`, `DEPOLAR`, `SIPARISDETAY`, `ISEMRI`, `REHBERBILGI`, `REHBERILETISIM`, `GOREVYORUM`, `GENINI`, `KULLANICI`, `YETKIEK`, `ROLLER`.
**Notlar:** `YETKIEK`/`ROLLER` üzerinden görme yetkisi (`@GORMEYETKISI`: 1=kendi, 10=şube bazlı) hesaplanıp WHERE'de uygulanıyor. `@BAYIID=-1` genel liste, aksi halde bayi bazlı TUR=19 liste — iki büyük SELECT bloğu neredeyse birebir tekrar (kod tekrarı). `PRINT` debug ifadeleri bırakılmış.

### TM_FATBASLIKDurumGuncelle
**Amaç:** Fatura başlığının satırlarındaki dönüşüm durumuna göre DURUM alanını otomatik günceller (0=Yeni, 1=Kısmi, 9=Tamamlandı) — sadece TUR=19 (satış) için.
**Parametreler:** `@FATBASLIKID INT`.
**Tablolar:** `FATBASLIK` (UPDATE), `FATURA` (okuma).
**Notlar:** **Dikkat çeken bug:** `@KISMI` hesaplanırken `SD.FATBASID = 10224` şeklinde **sabit (hardcoded) bir ID** kullanılmış, `@FATBASLIKID` parametresi yerine geçmiş — "kısmi tamamlanma" durumu yanlış hesaplanıyor olabilir.

### TM_FATBASLIKGuncelle
**Amaç:** Fatura başlığı kaydını ekler, günceller veya siler — fatura/irsaliye sihirbazının ana kaydetme prosedürü.
**Parametreler:** 30+ parametre: `@ID`, `@TARIH`, `@TUR`, `@TIPI`, `@REHBERID`, `@PROJEID`, `@FATBASLIKTARIH`, `@FATBASLIKNO` (='Sil' ise silme), `@CIKISDEPO`, `@BASLIK`, adres/vergi bilgileri, `@KUR`, `@DOVIZ_TUTARI`, `@DURUM`, `@FATBASLIKSERI`, `@EKLEYEN`, `@FIYAT_LISTESI`, `@DOVIZKUR`, `@SUBEID`, `@BAYIID`, `@OZELKOD`/`@OZELKOD2` vb.
**Tablolar:** `FATBASLIK` (INSERT/UPDATE/DELETE), `FATURA` (DELETE), `REHBER`, `REHBERBILGI`, `REHBERAYAR`, `REHBERILETISIM`, `KOCANAYARLARI`, `DEPOLAR`, `GENINI`.
**Notlar:** `BEGIN TRY...CATCH` hata yönetimi var. `@FATBASLIKNO='Sil'` ise önce `FATURA` sonra `FATBASLIK` siliniyor. Yeni kayıtta belge no `sp_BelgeNoGetir` ile üretiliyor. `@TUR=10`'da adres/vergi bilgisi negatif ID'li özel bir REHBER kaydından (muhtemelen kendi firma) alınıyor. Sonda `TM_FATBASLIK` çağrılarak güncel kayıt döndürülüyor.

### TM_FatBaslikEkalanlar
**Amaç:** `FATBASLIK` tablosunun kolonlarını (veya `ALANLAR`'da tanımlı "ek alanlar" alt kümesini) dinamik listeleyen ya da JSON üzerinden güncelleyen genel amaçlı dinamik alan motoru (fatura sihirbazı ek alanlar ekranı için).
**Parametreler:** `@EMIRNO` (FATBASLIK.ID), `@TIP` ('Listele'/'Guncelle'), `@JSON`.
**Tablolar:** `FATBASLIK` (dinamik SELECT/UPDATE), `SYS.OBJECTS`/`SYS.COLUMNS`/`sys.types`, `ALANLAR`, `TMLOG` (log INSERT).
**Notlar:** Ağır dinamik SQL: kolon adları `sys.columns`'tan okunup sorguya ekleniyor, `EXEC(@sql)` ile çalıştırılıyor. 'Guncelle' modunda `OPENJSON` ile gelen veri `ALANLAR` (EKRANADI='FaturaWizardDlg') tanımlarıyla eşleştirilip `FATBASLIK` güncelleniyor; boş string'ler NULL'a çevriliyor. `TRY...CATCH` ile hata durumunda `DURUM=0` + Türkçe mesaj, başarıda `DURUM=1` dönüyor. Her çağrı `TMLOG`'a loglanıyor.
