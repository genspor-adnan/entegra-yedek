## Bölüm 3: TM_MizanToplu, TM_MobilAyarlar, TM_MobilAyarlar1, TM_PotansiyelDetay, TM_PotansiyelListe, TM_Rehber, TM_RehberIletisim, TM_SAP_ENG_KDRSonucDetay, TM_SAP_KDRSonuc, TM_SAP_KDRSonucDetay, TM_SatisFirsatiPerformansRaporu, TM_SatisFirsatlarListeleGuncelle, TM_SiparisAlinan

### TM_MizanToplu

**Amaç:** Belirli bir tarih aralığı için genel muhasebe mizanı (trial balance) üretir. Kasa, POS, banka, çek/senet, cari hesap (alıcı/satıcı) borç-alacak hareketleri ile masraf/gelir/gider kalemlerini tek bir sonuç kümesinde birleştirerek hesap kodu, hesap adı, borç, alacak, bakiye ve TL karşılıklarını raporlar.

**Parametreler:** `@BasTar`, `@BitTar` (DATETIME) — rapor tarih aralığı; başlangıca 00:00:00, bitişe 23:59:59 eklenir.

**Ana tablolar:** POS, KASA, KASALAR, BANKAHESAPLAR, CEKLER, CEKHAREKET, HESAPPLANI, FATBASLIK, FATURA, REHBER, REHBERPERSONEL, REHBERILETISIM, REHBERBILGI, REHBERAYAR, GENINI, SENETLER, MASRAFGELIR, STOKLAR, ISLEMTURLERI, KULLANICI.

**Dikkat çeken noktalar:** Çok sayıda `UNION ALL` ile birleştirilmiş alt sorgulardan oluşan tek dev SELECT (yaklaşık 400 satır). Döviz/TL dönüşümleri her bir alt bölümde ayrı case ifadeleriyle hesaplanıyor (TUR=88/98 gibi özel işlem kodları döviz tutarını TL karşılığı olarak kullanıyor). Çeklerde "devir bakiye" (BasTar öncesi) ile "dönem içi hareket" ayrı ayrı hesaplanıp toplanıyor. Yazma/güncelleme işlemi yok, salt okunur raporlama prosedürüdür.

---

### TM_MobilAyarlar

**Amaç:** Mobil uygulama için genel ayarları (TMMOBILAYARLAR) ve kullanıcının modül bazlı görme/ekleme/değiştirme/depo yetkilerini tek sonuç kümesinde döner; mobil ekran butonlarının (BtnSiparis, BtnFatura, BtnCrm vb.) açık/kapalı durumunu YETKI/ROLLER tablolarına göre belirler.

**Parametreler:** `@KULLANICI VARCHAR(50)` — kullanıcının e-posta/firma adı ile eşleştirilir.

**Ana tablolar:** TMMOBILAYARLAR, REHBER, KULLANICI, YETKI, YETKIEK (dolaylı), REHBERILETISIM, REHBERBILGI, MODUL, ROLLER, DEPOLAR.

**Dikkat çeken noktalar:** Çok sayıda `UNION ALL` bloğu — her biri farklı bir yetki kategorisi (ana ekran görme, ekleme, değiştirme, ücret görme, depo yetkisi) için CASE...WHEN ile MODULID değerini anlamlı buton adına çeviriyor. `ROLLER.TY` (tam yetki) bayrağı varsa doğrudan 'True' dönüyor. Kodda geçici kod içine bırakılmış açıklayıcı bir not var; yetki eklenene kadar sabit kodlanmış bir buton satırı (`Btn_Kontrol` / `BtnFatura`) bulunuyor — teknik borç işareti.

---

### TM_MobilAyarlar1

**Amaç:** TM_MobilAyarlar'ın basitleştirilmiş/hafif versiyonudur; sadece TMMOBILAYARLAR tablosundan genel ayarları ve ilgili kullanıcıya ait önceden hesaplanmış `Btn_<kullanıcı>%` anahtarlı buton kayıtlarını döner (yetki hesaplaması burada yapılmıyor, muhtemelen önceden başka bir süreçle TMMOBILAYARLAR'a yazılmış durumda).

**Parametreler:** `@KULLANICI VARCHAR(50)`.

**Ana tablolar:** TMMOBILAYARLAR (tek tablo).

**Dikkat çeken noktalar:** TM_MobilAyarlar prosedürüne göre çok daha basit ve hızlıdır; muhtemelen performans nedeniyle canlı yetki hesaplaması yerine önbelleklenmiş ayarları okuyan alternatif/yeni bir sürümdür.

---

### TM_PotansiyelDetay

**Amaç:** Potansiyel müşteri / cari (REHBER) kaydının detayını görüntüler (`Listele`) veya ekler/günceller (`Guncelle`); iletişim bilgileri, vergi bilgileri ve "ilgili kişiler" listesini JSON olarak işler.

**Parametreler:** `@ID`, `@TIP` ('Listele'/'Guncelle'), firma/grup/temas/sektör/kategori/sınıf/durum/bölge/altbölge/özelkod/temsilci gibi çok sayıda REHBER alanı, iletişim alanları (@ILETISIMISTEL, @ILETISIMADRES, @ILETISIMILCE, @ILETISIMIL, @ILETISIMEPOSTA, @ILETISIMWEB), @VD, @VNO, `@ILGILIJSON` (ilgili kişiler JSON), `@VARSAYILANKOD`, `@FATBASLIK`.

**Ana tablolar:** REHBER (SELECT/UPDATE/INSERT), REHBERILETISIM (INSERT), REHBERBILGI (UPDATE/INSERT — upsert deseni), REHBERAYAR, GENINI (kod çözümleme), geçici `ILGILIJSON` tablosu (OPENJSON ile doldurulup DROP ediliyor), TM_Ilgililer prosedürü (cursor içinde çağrılıyor).

**Dikkat çeken noktalar:** `BEGIN TRY...CATCH` ile genel hata yönetimi var; hata durumunda `ACIKLAMA='Hata oluştu....'+ERROR_MESSAGE()` dönüyor. Yeni kayıt eklerken `@VARSAYILANKOD` verilmişse, mevcut en son alt kod (`.01`, `.02` gibi hiyerarşik kod) bulunup bir artırılarak otomatik kod üretiliyor (string manipülasyonuyla REVERSE/SUBSTRING/CHARINDEX kullanılıyor — kırılgan bir mantık). `@ILGILIJSON` üzerinden `OPENJSON` ile JSON parse edilip CURSOR ile satır satır TM_Ilgililer prosedürüne aktarılıyor (satır bazlı cursor kullanımı — performans açısından dikkat edilmesi gereken bir nokta). REHBERBILGI alanları için "varsa UPDATE, @@ROWCOUNT=0 ise INSERT" upsert deseni tekrar tekrar kullanılıyor. Kodun sonunda büyük bir yorum satırı bloğu (kullanılmayan/iptal edilmiş eski mantık) bırakılmış.

---

### TM_PotansiyelListe

**Amaç:** Potansiyel müşteri/cari listesini filtreli ve yetkiye göre kısıtlanmış şekilde arar; unvan, ilgili kişi, durum, temsilci, grup ve serbest metin arama (detay arama) destekler; her satırda son aktivite ve son satış bilgisini de gösterir.

**Parametreler:** `@UNVAN`, `@ILGILI`, `@DURUM`, `@TEMSILCIAD`, `@GRUP`, `@TUML` (tümünü listele bayrağı), `@DETAYARA` (serbest metin arama), `@KOD`, `@KULLANICIKODU`, `@EKRAN` ('Cari' veya diğer — Potansiyel).

**Ana tablolar:** REHBER, REHBERILETISIM, REHBERBILGI, GENINI, YETKIEK, GOREVLER, FATBASLIK.

**Dikkat çeken noktalar:** YETKIEK tablosundan kullanıcının "görme yetkisi" (`@GORMEYETKISI`) okunuyor; yetki=1 ise sadece kendi temsilciliği altındaki kayıtlar, yetki=10 ise sadece kendi şubesindeki kayıtlar gösteriliyor (satır bazlı erişim kontrolü). Sonuç `TOP 500` ile sınırlandırılmış. Alt sorgu önce temel filtrelerle 500 kayıt getiriyor, dış sorgu ise `@DETAYARA` serbest metnini birçok alanda (`LIKE '%...%'`) arıyor — iki aşamalı filtreleme.

---

### TM_Rehber

**Amaç:** Rehber (cari/firma) kayıtlarını farklı bağlamlarda (genel arama, yetki kısıtlı arama, satıcı, bağlı firma, rakip, bayi) aramak için kullanılan çok amaçlı arama prosedürüdür; her dal en fazla 50 sonuç döner.

**Parametreler:** `@KOD`, `@FIRMA`, `@TIP` ('335', 'YETKIKISITLI', 'SATICI', 'BAGLI', 'RAKIP', 'BAYI'), `@KULLANICIKODU`.

**Ana tablolar:** REHBER, REHBERBILGI, GOREVYORUM, REHBERILETISIM, KULLANICI, YETKIEK, ROLLER.

**Dikkat çeken noktalar:** `@TIP` değerine göre 6 farklı ayrı SELECT bloğu çalışıyor (dallanmış mantık, dinamik SQL değil, statik IF blokları). 'YETKIKISITLI' dalında ROLLER.TY (tam yetki) kontrolü ile görme yetkisi belirleniyor ve temsilci/şube bazlı satır filtresi uygulanıyor. RAKIP dalı sabit `GRUP = 950` filtresiyle rakip firmaları getiriyor. GOREVYORUM tablosundan not/uyarı/yasak (TUR 11/12/13) yorumları STRING_AGG ile birleştirilip müşteri kartında gösteriliyor.

---

### TM_RehberIletisim

**Amaç:** Belirli bir rehber (cari) kaydına ait iletişim noktalarının (REHBERILETISIM) adres, ilçe, il, vergi dairesi ve vergi numarası bilgilerini döner.

**Parametreler:** `@REHBERID INTEGER`.

**Ana tablolar:** REHBERILETISIM, REHBERAYAR, REHBERBILGI.

**Dikkat çeken noktalar:** Basit, tek SELECT'lik salt okunur prosedürdür. REHBERAYAR.VARSAYILAN sabit kodlarına göre (2=Adres, 6=İlçe, 8=İl, 20=Vergi Dairesi, 22=Vergi No) REHBERBILGI'den ilgili alan çekiliyor — alan/etiket eşlemesi konfigürasyon tablosu (REHBERAYAR) üzerinden yapılan esnek (EAV benzeri) bir veri modeli kullanıldığını gösteriyor.

---

### TM_SAP_ENG_KDRSonucDetay

**Amaç:** SAP Business One (SBO) muhasebe verilerinden konsolide bakiye detay raporu üretir — borçlu/alacaklı cariler, banka, POS, alınan/verilen çek-senet, kasa, kredi, kredi kartı ve stok bakiyelerini `@TIP` parametresine göre (1-13 arası) SAP tablolarından okuyarak İngilizce kolon adlarıyla (CardCode, CardName, Balance, Currency, Balance Local Currency) döner.

**Parametreler:** `@TIP VARCHAR(2)` — hangi bakiye detayının isteneceğini belirler (1=Borç, 2=Banka, 3=Pos, 4=Alınan Çek, 5=Alınan Senet, 6=Kasa, 7=Stok, 8=Alacak, 9=Kredi, 10=Kredi Kartı, 11=Verilen Çek, 12=Verilen Senet, 13=Borç tekrar).

**Ana tablolar (SAP Business One şema tabloları):** OCRD (cari kartlar), OCRG (cari grupları), JDT1/OJDT (muhasebe fişi satır/başlık), OACT (hesap planı), @GRNT_KDR (özel kullanıcı alanı/tablosu — grup eşleme), UFD1 (kullanıcı tanımlı alan değerleri), OFPR (mali dönem — F_RefDate ile dönem başlangıcı belirleniyor), OINM/OITM/OUGP/OITB (stok hareketleri ve kartları).

**Dikkat çeken noktalar:** Bu, harici bir SAP Business One ERP sistemine doğrudan bağlanan/entegre olan bir prosedürdür (BILIMPLANT_V2 dışındaki SAP şemasına referans veriyor — muhtemelen linked server veya aynı sunucuda ayrı bir SAP veritabanı). Her `@TIP` dalı hemen hemen aynı yapıyı (JDT1-OJDT-OACT-@GRNT_KDR-UFD1 join zinciri) tekrarlıyor, sadece T4.Descr filtre değeri değişiyor — kod tekrarı yüksek, parametrik tek bir sorguya indirgenebilecek bir yapı. RefDate son mali dönem başlangıcı ile GETDATE() arasında filtrelenerek cari dönem bakiyesi hesaplanıyor. `@SQL` değişkeni tanımlanmış ama hiç kullanılmıyor (muhtemelen eski/iptal edilmiş dinamik SQL yaklaşımından kalıntı).

---

### TM_SAP_KDRSonuc

**Amaç:** TM_SAP_ENG_KDRSonucDetay prosedüründeki tüm bakiye kategorilerinin (Alacaklılar, Alınan Çek/Senet, Banka, Borçlular, Kasa, Kredi Kartı, Krediler, POS, Stok, Verilen Çek/Senet) toplamlarını tek satırlık özet/kontrol raporu (KDR — muhtemelen kur/döviz risk raporu benzeri bir kısaltma) olarak PIVOT ile döner; ayrıca genel "SONUÇ" toplamını hesaplar.

**Parametreler:** Yok (parametresiz).

**Ana tablolar:** OCRD, OCRG, JDT1, OJDT (borçlu/alacaklı hesaplama), OINM/OITM/OUGP/OITB (stok), UFD1 (@GRNT_KDR kategori listesi — CUBE ile eksik kategoriler de 0 olarak tamamlanıyor), OFPR.

**Dikkat çeken noktalar:** `GROUP BY CUBE(Descr)` kullanılarak hem kategori bazlı toplamlar hem de genel toplam (SONUÇ) tek sorguda elde ediliyor; ardından sabit kategori listesiyle PIVOT uygulanarak satır bazlı veriler tek satıra dönüştürülüyor — muhasebe kontrol/mutabakat panosu niteliğinde. TM_SAP_ENG_KDRSonucDetay ile neredeyse aynı SAP sorgu mantığını tekrar içeriyor (kod tekrarı).

---

### TM_SAP_KDRSonucDetay

**Amaç:** TM_SAP_ENG_KDRSonucDetay ile birebir aynı iş mantığını uygular (aynı 13 `@TIP` dalı, aynı SAP tabloları, aynı filtreler); tek fark sonuç kolon adlarının Türkçeleştirilmiş olmasıdır (KOD, FIRMA, BAKIYE, KUR, TLKARSILIK yerine CardCode, CardName, Balance, Currency, Balance Local Currency).

**Parametreler:** `@TIP VARCHAR(2)` (1-13, TM_SAP_ENG_KDRSonucDetay ile aynı anlamlarda).

**Ana tablolar:** TM_SAP_ENG_KDRSonucDetay ile aynı: OCRD, OCRG, JDT1, OJDT, OACT, @GRNT_KDR, UFD1, OFPR, OINM, OITM, OUGP, OITB.

**Dikkat çeken noktalar:** Bu prosedür TM_SAP_ENG_KDRSonucDetay prosedürünün neredeyse birebir kopyasıdır — muhtemelen biri Türkçe arayüz/raporlama için, diğeri (ENG sürümü) İngilizce dışa aktarım/entegrasyon için kullanılıyor. İki prosedürün bakım yükünü ikiye katlayan belirgin bir kod tekrarı söz konusu; iş mantığı değişirse her iki yerde de güncelleme gerekir.

---

### TM_SatisFirsatiPerformansRaporu

**Amaç:** Belirtilen tarih aralığında satış fırsatları (PROJELER, MODUL=1) için sorumlu bazında performans raporu üretir; her sorumlunun aşama (ASAMA) bazında proje sayılarını, toplam proje sayısını, yeni müşteri sayısını ve teklif sayısını pivot tablo halinde gösterir.

**Parametreler:** `@BASTAR`, `@BITTAR` (DATETIME).

**Ana tablolar:** GENINI (BOLUM=-2114, aşama listesi — geçici #TEMP_ASAMA tablosuna aktarılıyor), PROJELER, REHBER, TEKLIF.

**Dikkat çeken noktalar:** Dinamik SQL kullanıyor — aşama listesi (GENINI'den) önce geçici tabloya alınıp bir WHILE döngüsüyle PIVOT için gereken kolon listesi (@ALAN), toplam ifadesi (@ALAN2) ve genel toplam ifadesi (@ALAN3) string olarak dinamik biçimde oluşturuluyor, sonra `EXEC(@SQL)` ile çalıştırılıyor. Bu yaklaşım, aşama sayısı/isimleri değişse bile kod değişikliği gerektirmeden PIVOT kolonlarının otomatik oluşmasını sağlıyor. İşlem sonunda geçici tablo (#TEMP_ASAMA) DROP ediliyor. Dinamik SQL içinde tarih değerleri string birleştirme ile ekleniyor — parametreler DATETIME tipinde geldiği için injection riski düşük olsa da yine de dikkat edilmesi gereken bir örüntüdür.

---

### TM_SatisFirsatlarListeleGuncelle

**Amaç:** Satış fırsatları (PROJELER tablosu, MODUL=1) için CRUD işlemleri sağlar: listeleme, ekleme/güncelleme ve silme. Her yazma işleminden sonra güncel listeyi tekrar döndürerek istemci tarafında yenileme kolaylaştırılıyor.

**Parametreler:** `@TIP` ('Listele'/'Guncelle'/'Sil'), `@ACKAPA` (açık/kapalı durum), `@BASLAMATARIHI`, `@BITISTARIHI`, `@KONUSU`, `@SATISFIYATI`, `@SATISKUR`, `@PROJESORUMLUSUID`, `@TURU`, `@TIPI`, `@PROJEKODU`, `@ILGILI`, `@OLASILIK`, `@ID`, `@SEBEBI`, `@RAKIP`, `@REHBERID`, `@ASAMA`, `@KAPALILARDAGELSIN`.

**Ana tablolar:** PROJELER (SELECT/UPDATE/INSERT/DELETE), REHBER, GENINI (çoklu kod çözümleme — TURU/TIPI/OLASILIK/SEBEBI/ASAMA), GOREVLER, GOREVYORUM.

**Dikkat çeken noktalar:** Guncelle ve Sil dallarının sonunda prosedür kendi kendini (`EXEC [TM_SatisFirsatlarListeleGuncelle] 'Listele', ...`) çağırarak güncel listeyi geri döndürüyor — yazma ve okuma tek çağrıda birleştirilmiş (tek seviyeli öz çağrı). TIPI alanı hiyerarşik GENINI kodlamasıyla (-2112 önekine TURU değeri eklenerek) çözülüyor — üst kategoriye bağlı alt kategori seçimi. Silme işleminde soft-delete değil, doğrudan DELETE FROM PROJELER kullanılıyor (fiziksel silme, geri alınamaz).

---

### TM_SiparisAlinan

**Amaç:** Alınan siparişleri (SIPARIS tablosu, TUR=19) tarih aralığına, siparişe veya bayiye göre listeler; sipariş tutarı, KDV, döviz karşılıkları, teslim tarihi, hangi süreçten geldiği (teklif/servis/talep/üretim) ve hangi sürece gittiği (fatura/irsaliye/konsinye/üretim fişi) gibi zengin türetilmiş alanlar sunar.

**Parametreler:** `@BasTarihi`, `@BitTarihi` (VARCHAR tarih), `@ID` (belirli sipariş), `@TAMAMLANAN` (tamamlanmışları filtreleme bayrağı), `@BAYIID` (belirli bayi/cari filtresi, -1 ise tüm bayiler), `@KULLANICIKODU`.

**Ana tablolar:** SIPARIS (NOLOCK ile okunuyor), REHBER, SIPARISDETAY, DEPOLAR, REHBERILETISIM, GENINI, FATURA, ISEMRI, YETKIEK, REHBERBILGI.

**Dikkat çeken noktalar:** @BAYIID=-1 durumuna göre neredeyse birebir aynı iki büyük SELECT bloğu tekrarlanıyor (biri tüm bayiler için, diğeri R.ID=@BAYIID filtresiyle) — IF/ELSE ile dallanan, dinamik SQL kullanmayan ama kod tekrarına yol açan bir yapı. DURUMNEREDEN ve DURUMNEREYE alanları, siparişin SIPARISDETAY/FATURA tablolarındaki "YERI" kod değerlerine bakarak siparişin hangi iş akışı adımından geldiğini/gittiğini metinsel olarak türetiyor — karmaşık iş akışı izleme mantığı iç içe alt sorgularla uygulanmış. Yetki kontrolünde @GORMEYETKISI=1 ise satıcı bazlı, =10 ise şube bazlı satır filtresi uygulanıyor (diğer prosedürlerle tutarlı bir yetkilendirme deseni). SIPARIS tablosu NOLOCK hint'i ile okunuyor (kirli okuma riski, ancak performans için tercih edilmiş).
