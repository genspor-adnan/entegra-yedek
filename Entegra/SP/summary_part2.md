## Bölüm 2: TM_FaturaDetay – TM_KdvOzet (Satır 2311-4477)


### TM_FaturaDetay
**Amaç:** Bir fatura başlığına (FATBASID/SIPARISID) bağlı fatura satırlarını, ürün/masraf bilgileri, birim, ekipman, seri no, proje ve satıcı bilgileriyle zenginleştirerek listeler.
**Parametreler:** @SIPARISID INT — FATURA.FATBASID.
**Ana tablolar:** FATURA (okuma), STOKLAR, MASRAFGELIR, GENINI, PROJELER, REHBER, STOKCEVRIM, FATBASLIK, EKIPMANLAR, EKIPMANREHBER, GOREVYORUM, DOKUMAN.
**Notlar:** TUR=0 ise masraf/gelir kalemi, aksi halde stok kalemi olarak farklı alanlar (AD, KOD, BIRIM2AD vb.) hesaplanıyor. Dönüşen miktar STOKCEVRIM üzerinden hesaplanıyor. Üretim planında gösterim durumu (URETIMPLANINDAGOSTER) özel bir CASE mantığıyla belirleniyor.

### TM_FATURAGir
**Amaç:** Bir sipariş/fatura başlığına (FATBASLIK) bağlı fatura satırlarını (FATURA) ekler, günceller veya siler; ayrıca stok hareketlerini (STOKIZLEME/STOKIZLEMEDEPO) ve seri/lot takibini işler, üst faturanın toplam tutarlarını yeniden hesaplar.
**Parametreler:** Çok sayıda parametre var — @ID (0 ise yeni kayıt), @SIPARISID, @REHBERID, @TUR ('Stok'/'Sil'), @URUNID, @MIKTAR, @BIRIMFIYAT, @ISKONTO, @KDV, döviz alanları (@DOVIZ_KURU, @DOVIZKURDEGERI vb.), @EKIPMANID, @SERILOTLISTESI (JSON, seri/lot listesi).
**Ana tablolar:** FATURA (insert/update/delete), FATBASLIK (update — RAPORDOVIZ, DOVIZKUR, FATURA_TUTARI, KDV_TUTARI vb.), STOKIZLEME, STOKIZLEMEDEPO, STOKSERILOT, STOKDURUMIZLEME, DOVIZ (kur okuma), STOKLAR.
**Dikkat çeken iş mantığı:**
- @TUR='Sil' ise satırı siler; @ID boşsa INSERT, doluysa UPDATE yapılıyor (upsert deseni).
- Döviz cinsi TL değilse, birim fiyat ve tutar günün DOVIZ kuru (SATIS) ile TL'ye çevriliyor.
- Belge türüne göre (FATBASLIK.TUR: 14=Satış, 10=Alış, 20=Transfer) çıkış/giriş depoları farklı belirleniyor.
- @SERILOTLISTESI JSON parametresi OPENJSON ile parse edilip STOKIZLEME/STOKIZLEMEDEPO/STOKSERILOT tablolarına toplu (bulk) insert yapılıyor; OUTPUT ... INTO ile üretilen ID'ler tablo değişkenlerinde (@InsertedRows) yakalanıyor. Belge türü 10 (Alış) için yeni STOKSERILOT kayıtları oluşturuluyor, 14/20 (Satış/Transfer) için mevcut seri/lotlar kullanılıyor.
- İşlem sonunda üst FATBASLIK kaydının FATURA_TUTARI, FATURA_MATRAHI, DOVIZ_TUTARI, KDV_TUTARI alanları alt satırlardan yeniden toplanarak güncelleniyor.
- En sonda TM_FaturaDetay prosedürü çağrılarak güncel liste döndürülüyor (self-call/zincirleme).

### TM_FirsatBagla
**Amaç:** Bir cariye (REHBERID) bağlı veya tüm açık (DURUM=1) satış fırsatlarını/projeleri listeler; fırsat bağlama ekranı için kaynak veri sağlar.
**Parametreler:** @REHBERID varchar(20) — '0' ise tüm açık projeler, aksi halde o cariye ait projeler.
**Ana tablolar:** PROJELER, REHBER (INNER JOIN).
**Notlar:** Basit bir filtreleme prosedürü, iş mantığı sade.

### TM_GorevDetayListeleGuncelle
**Amaç:** Görev (CRM iş/aktivite) kayıtlarını listeler, ekler veya günceller; ayrıca göreve atanan kişileri ve bilgilendirilecek kişileri (GOREVKULLANICI) ve not/yorumu (GOREVYORUM) yönetir.
**Parametreler:** @TIP ('Listele'/'Guncelle'/'Sil'), @ID, @LISTEID, @DURUM, @KONUSU, @TURU, @REHBERID, tarih/saat alanları, @YORUM, @ATANAN/@BILGI (JSON kişi listeleri), @BAYRAK, @MUS_ILGILI/@MUS_ILGILI2, @PROJEID.
**Ana tablolar:** GOREVLER (insert/update/delete), GOREVYORUM, GOREVKULLANICI (atanan=TUR 11, bilgi=TUR 12), GENINI (durum/tür kod çözümü), REHBER, PROJELER.
**Dikkat çeken iş mantığı:**
- DURUM ve TURU kodları GENINI tablosundan (BOLUM=-21042 / -21044) metin/kod dönüşümü ile eşleştiriliyor.
- @ATANAN ve @BILGI JSON parametreleri OPENJSON ile parse edilip GOREVKULLANICI tablosuna atanan/bilgi kişileri olarak yazılıyor (önce mevcut kayıtlar siliniyor, sonra yeniden ekleniyor).
- Güncelleme/ekleme sonrasında WhatsApp ve mail bildirimi için TM_GOREVLERWHATSAPPGONDERMAIL ve TM_GOREVLERWHATSAPPGONDERWA prosedürleri otomatik çağrılıyor — harici entegrasyon tetikleyicisi.

### TM_GorevFonsiyonGetir
**Amaç:** Kullanıcının erişebildiği görev listelerini (klasörleri) ve özel "akıllı liste" görünümlerini (masaüstü, bu hafta, bana atananlar, atadıklarım, atanmamışlar, bayraklı, tüm liste) çeşitli table-valued fonksiyonlar üzerinden getirir.
**Parametreler:** @Kullanici INT, @AcKapa INT (açık/kapalı filtre), @BaslaGun INT, @ListeId INT (negatif değerler özel/sanal listeleri temsil ediyor: -27, -24, -18, -15, -12, -9, -3).
**Ana tablolar:** GOREVLISTE, GOREVKULLANICI, GOREVLER, GENINI, ROLLER, KULLANICI; ayrıca fn_Prg_IsListesiListeler, fn_prg_IsListesiMasaUstu, fn_prg_IsListesiBuHafta, fn_prg_IsListesiBanaAtananlar, fn_prg_IsListesiAtadiklarim, fn_prg_IsListesiAtanmamislar, fn_prg_IsListesiBayrakli, fn_prg_IsListesiTumListe gibi table-valued fonksiyonlar ve fn_GorevVerilenKisilerUzunAd skaler fonksiyonu.
**Dikkat çeken iş mantığı:** Erişim yetkisi karmaşık bir CASE/OR koşuluyla kontrol ediliyor (liste herkese açık mı, ekleyen kullanıcı mı, ya da GOREVKULLANICI üzerinden 4 farklı TUR/rol kombinasyonuyla (TUR=1..4, sabit REHBERID'ler 103, 64, -1) yetkilendirilmiş mi). @ListeId=-3 durumunda kullanıcının rolü (TY) ROLLER/KULLANICI tablosundan okunup fonksiyona ek parametre olarak veriliyor.

### TM_GOREVLERWHATSAPPGONDER
**Amaç:** Belirli bir görev (GOREVID) için detaylı bir metin mesajı (ID, tarih, konu, durum, müşteri, ilgili, atanan, notlar) oluşturup TMWHATSAPPMESAJ kuyruk tablosuna "Mail" türünde ekler — dış bir mail/whatsapp gönderim servisinin işleyeceği bir kuyruk kaydı yaratır.
**Parametreler:** @GOREVID INT.
**Ana tablolar:** GOREVLER, REHBER, GENINI, GOREVLISTE, GOREVKULLANICI, GOREVYORUM, REHBERILETISIM, REHBERBILGI (okuma) -> TMWHATSAPPMESAJ (insert).
**Notlar:** Alıcı mail adresleri GOREVKULLANICI üzerinden STRING_AGG ile ';' ayracıyla birleştiriliyor. Cep telefonu ile WhatsApp gönderimi kod içinde yorum satırına alınmış (devre dışı) — yerini muhtemelen ayrı WA prosedürleri (aşağıdaki iki proc) almış görünüyor.

### TM_GOREVLERWHATSAPPGONDERMAIL
**Amaç:** TM_GOREVLERWHATSAPPGONDER'in HTML formatlı, daha detaylı (yorum geçmişini de içeren) bir versiyonu; görev bilgilerini HTML etiketleriyle (<b>, <br>) biçimlendirip TMWHATSAPPMESAJ tablosuna "Mail" türünde kaydeder.
**Parametreler:** @GOREVID INT.
**Ana tablolar:** GOREVLER, REHBER, GENINI, GOREVLISTE, GOREVYORUM (TUR=1 notlar, TUR=33 yorum geçmişi), REHBERILETISIM, REHBERBILGI -> TMWHATSAPPMESAJ (insert).
**Notlar:** fn_GorevVerilenKisilerUzunAd fonksiyonuyla atanan kişi adları alınıyor; yorum geçmişi STRING_AGG ile tarih/kişi/yorum formatında HTML bloklarına dönüştürülüyor. Alıcı mail listesi hem atanan/bilgi kişilerden hem de görevi oluşturandan toplanıyor.

### TM_GOREVLERWHATSAPPGONDERWA
**Amaç:** Görev bilgilerini WhatsApp mesaj formatında (yıldızlarla kalın yazı, *...*) hazırlayıp, atanan/bilgi kişilerinin ve görevi oluşturanın cep telefonlarına (TM_TelFormatla ile normalize edilip '@c.us' eklenerek) veya mail adreslerine TMWHATSAPPMESAJ tablosuna "WA" türünde kayıt açar.
**Parametreler:** @GOREVID INT.
**Ana tablolar:** GOREVLER, REHBER, GENINI, GOREVLISTE, GOREVYORUM, GOREVKULLANICI, REHBERILETISIM, REHBERBILGI (Cep Tel) -> geçici tablo #TEMPWA -> TMWHATSAPPMESAJ (insert).
**Dikkat çeken iş mantığı:** İki UNION ALL sorgusuyla hem atanan/bilgi kişilerin cep telefonlarını hem de görevi oluşturanın bilgisini (BILGI alanı — muhtemelen mail) tek geçici tabloda topluyor; DBO.TM_TelFormatla fonksiyonu ile telefon numarası WhatsApp API formatına çevriliyor. Harici WhatsApp entegrasyon kuyruğuna yazma işlemi.

### TM_GorevListe
**Amaç:** Kullanıcının görebileceği görev listelerini (klasörleri) — hem normal (GOREVLISTE tablosundan, yetki kontrolüyle) hem de sabit/sanal "akıllı" listeleri (-24, -18, -12, -15, -3, -9 ID'li: Bu Hafta, Bana Atananlar vb.) birleştirerek döner.
**Parametreler:** @REHBERID INT.
**Ana tablolar:** GOREVLISTE, GOREVKULLANICI.
**Notlar:** TM_GorevFonsiyonGetir'deki ile aynı yetkilendirme mantığı (HERKESEACIK, EKLEYEN, veya GOREVKULLANICI TUR/REHBERID eşleşmesi) kullanılıyor. TUR=1 (kullanıcıya özel) ve TUR=0 (sabit) olarak iki grup UNION ALL ile birleştiriliyor.

### TM_GorevYorum
**Amaç:** Bir göreve (GOREVID) bağlı farklı bağlamlardaki yorumları/notları (irsaliye, ÜEL, iş listesi, sipariş/sipariş satırı, satış fırsatları) listeler ve ekler/günceller; her ekleme/güncelleme sonrası ilgili listeleme çağrısını tekrar tetikleyerek güncel veriyi döner.
**Parametreler:** @GOREVID INT, @TIP varchar(50) (ListeleIrsaliye/ListeleUel/ListeleIslistesi/ListeleSiparis/ListeleSatisFirsatlari ve karşılık gelen Guncelle* varyantları), @EKLEYEN, @EKLEMETARIHI, @YORUM, @ID.
**Ana tablolar:** GOREVYORUM (farklı TUR değerleriyle bağlam ayrımı: 105=irsaliye, 142=ÜEL, 33=iş listesi, 91/93=sipariş/sipariş satırı, 70=satış fırsatları), REHBER, IMAJ, DOKUMAN.
**Dikkat çeken iş mantığı:** @ID=0 ise INSERT, değilse UPDATE (upsert). GuncelleIslistesi tipi işlemden sonra yine WhatsApp/mail bildirim prosedürleri (TM_GOREVLERWHATSAPPGONDERMAIL, TM_GOREVLERWHATSAPPGONDERWA) tetikleniyor. Prosedür kendi içinde farklı @TIP değerleriyle kendisini çağırıyor (self-call) — güncelleme sonrası taze liste döndürmek için.

### TM_HesapPlani
**Amaç:** Muhasebe hesap planını (HESAPPLANI), varsayılan hesap gruplarıyla (GENINI, BOLUM=-2200, "Personel" hariç) eşleştirip kök hesap kodunu (ROOTKOD) da hesaplayarak listeler.
**Parametreler:** @TIP VARCHAR(20) (kodda kullanılmıyor gibi görünüyor).
**Ana tablolar:** HESAPPLANI, GENINI.
**Notlar:** ROOTKOD, hesap kodundaki son noktadan sonraki kısmın tersten alınmasıyla (REVERSE/SUBSTRING/CHARINDEX) hesaplanıyor — hiyerarşik hesap kodu ayrıştırma mantığı.

### TM_Ilgililer
**Amaç:** Bir firmaya bağlı ilgili kişi (contact) kaydını oluşturur veya günceller; kişi REHBER tablosunda yoksa yeni bir REHBER + REHBERILETISIM kaydı açar, iletişim bilgilerini (iş tel, cep tel, e-posta, görevi, iletişimi) REHBERBILGI tablosuna upsert eder.
**Parametreler:** @ILGILIFIRMAID, @ILGILIAD, @ILGILIISTEL, @ILGILICEPTEL, @ILGILIEPOSTA, @ILGILIGOREVI, @ILGILIILETISIMI, @EKLEYEN, @DURUM, @ID (bağlı olduğu üst firma/kayıt ID'si).
**Ana tablolar:** REHBER (insert), REHBERILETISIM (insert), REHBERBILGI (update/insert — her etiket için UPDATE denenip @@ROWCOUNT=0 ise INSERT yapılıyor).
**Dikkat çeken iş mantığı:** @ILGILIFIRMAID=0 ise yeni REHBER kaydı (GRUP=334, sabit değerlerle) oluşturuluyor; SCOPE_IDENTITY() ile yeni ID alınıyor. Her iletişim bilgisi alanı için "upsert" deseni (UPDATE, @@ROWCOUNT=0 ise INSERT) tekrar ediyor — REHBERAYAR tablosundan SIRA değeri alınarak.

### TM_Iller
**Amaç:** İl (@TIP='IL') veya ilçe (@TIP='ILCE') listesini döner; adres/lokasyon seçim ekranları için referans veri sağlar.
**Parametreler:** @TIP VARCHAR(20), @ILADI VARCHAR(30) (ilçe sorgusunda kod içinde yorum satırına alınmış, kullanılmıyor).
**Ana tablolar:** ILLER, ILCELER.
**Notlar:** Basit referans veri prosedürü; ILNO<82 filtresiyle Türkiye illeriyle sınırlı.

### TM_Imaj
**Amaç:** Bir görsel/imaj kaydını (IMAJ tablosu) ID'sine göre okuyup binary içeriğini (varbinary) ve belge türünü döner; harici sp_Imaj_Okuma prosedürünü sarmalıyor.
**Parametreler:** @ID INT.
**Ana tablolar:** IMAJ (dolaylı olarak sp_Imaj_Okuma üzerinden).
**Dikkat çeken iş mantığı:** TRY/CATCH bloğu var; CATCH içindeki alternatif sorgu tamamen yorum satırına alınmış, yani hata durumunda sessizce boş sonuç dönüyor (hata bastırılıyor, kullanıcıya bildirilmiyor).

### TM_Imaj_Disk
**Amaç:** Bir tablo/kayıt için diskte bir harici .exe (GentegreMobilReport.exe) çalıştırarak PDF (örn. irsaliye) üretir, ardından bu PDF dosyasını OPENROWSET ile binary olarak okuyup döner.
**Parametreler:** @TabloAdi VARCHAR(100), @ID INT.
**Ana tablolar:** Doğrudan tablo erişimi yok; dosya sistemi ve xp_cmdshell kullanıyor.
**Dikkat çeken iş mantığı (önemli/riskli):**
- sp_configure ile xp_cmdshell sunucu düzeyinde açılıp iş bitince tekrar kapatılıyor — güvenlik açısından hassas bir işlem (komut satırı çalıştırma yetkisi).
- xp_cmdshell ile harici bir .exe tetikleniyor, üretilen PDF dosyası OPENROWSET(BULK ..., SINGLE_BLOB) ile okunuyor.
- TRY/CATCH var ama CATCH bloğundaki hata raporlama kodu da yorum satırına alınmış — hata sessizce yutuluyor.
- Dosya silme adımı da (DEL komutu) yorum satırına alınmış, yani üretilen PDF diskte kalıyor.

### TM_Imaj_Okuma_Disk
**Amaç:** Verilen bir dosya yolundaki (@DosyaYolu) dosyayı OPENROWSET ile binary (varbinary) olarak okuyup OUTPUT parametresiyle döner; TM_Imaj_Disk ve benzer prosedürler tarafından yardımcı fonksiyon olarak kullanılıyor.
**Parametreler:** @DosyaYolu VARCHAR(255), @SONUC varbinary(MAX) OUTPUT.
**Ana tablolar:** Yok — sadece dosya sistemi erişimi (dinamik SQL ile sp_executesql).
**Notlar:** Dinamik SQL kullanımı var; @DosyaYolu doğrudan string concatenation ile SQL'e ekleniyor — parametre değeri kontrolsüzse SQL injection riski taşıyabilir (dosya yolu bir T-SQL string literalı olarak birleştiriliyor).

### TM_ImajListele
**Amaç:** Bir göreve (GOREVYORUM.ID) bağlı resim (IMAJ) ve doküman (DOKUMAN) kayıtlarını birleşik bir liste olarak döner.
**Parametreler:** @ID INT, @TUR INT.
**Ana tablolar:** GOREVYORUM, IMAJ, DOKUMAN.
**Notlar:** UNION ALL ile "Resim" ve "Doküman" türleri tek sonuç kümesinde birleştiriliyor; DOKUMAN eşleşmesi KLASOR = -1*@TUR gibi işaretli bir kodlama kullanıyor.

### TM_IniOku
**Amaç:** Uygulamanın çeşitli açılır listelerini (combobox/dropdown) tek seferde doldurmak için dev bir "referans veri" sorgusu; birim, depo, fiyat listesi, ödeme/teslim şekli, durum kodları, il/ilçe/lokasyon, döviz kurları, kategori, özel kod tanımları, satış/potansiyel/dokuman modülü sabit kodları gibi onlarca farklı kaynağı UNION ALL ile tek bir FILTRE sütunlu tabloya birleştiriyor.
**Parametreler:** Yok.
**Ana tablolar:** LOKASYON, GENINI (çok sayıda farklı BOLUM değeriyle), DEPOLAR, REHBER, KULLANICI, ROLLER, YETKI, DOVIZ, KATEGORI.
**Dikkat çeken iş mantığı:** 40'tan fazla UNION ALL bloğu var; her biri farklı bir FILTRE etiketiyle (KONUSU, LOKASYON, KAYNAK, BIRIM, DEPO, FIYAT_LISTESI, SORUMLU, ODEME, TESLIM_SEKLI, DURUM, FATURADURUM, DOVIZ, STOKKATEGORI, OZELKODTIP1/2 vb.) sonuç döndürüyor. SORUMLU/OLCUMSORUMLU filtrelerinde YETKI/ROLLER üzerinden modül bazlı (MODULID=33062010) yetki kontrolü yapılıyor. Tek bir "her şeyi getir" (kitchen-sink) referans veri prosedürü.

### TM_IsListesiPerformansRaporu
**Amaç:** Belirli bir tarih aralığında kişi/tür/firma bazında görev (iş listesi) performansını, firma sayılarını, yeni müşteri sayısını ve satış fırsatı sayısını pivotlanmış (görev türlerine göre sütunlaşmış) bir raporla döner.
**Parametreler:** @BASTAR DATETIME, @BITTAR DATETIME, @KISI varchar(50)=NULL, @TUR varchar(50)=NULL, @FIRMA varchar(50)=NULL.
**Ana tablolar:** GOREVLER, GOREVLISTE, REHBER, GENINI (#TEMP_TUR geçici tablosuna aktarılıyor), PROJELER.
**Dikkat çeken iş mantığı:**
- Dinamik SQL kullanımı: GENINI'deki görev türleri (BOLUM=-21044) bir WHILE döngüsüyle gezilerek dinamik olarak PIVOT sütun listesi (@ALAN, @ALAN2, @ALAN3, @ALAN4) string concatenation ile oluşturuluyor, sonra tüm sorgu EXEC(@SQL) ile çalıştırılıyor.
- PIVOT operatörü ile görev türleri satırdan sütuna çevriliyor.
- Parametre değerleri (@KISI, @TUR, @FIRMA) doğrudan dinamik SQL string'ine ekleniyor — SQL injection riski taşıyan bir desen (parametrized query değil, string concatenation).
- Satış fırsatları (PROJELER, MODUL=1) ile görev verileri UNION ALL ile birleştirilip yeni müşteri sayısı ayrı bir alt sorguyla (Y) LEFT JOIN'leniyor.

### TM_KDRSonuc
**Amaç:** Şirketin "KDR" (muhtemelen Kısa Dönem Rasyo/likidite/kredi değerlendirme raporu) özet finansal tablosunu hesaplar: kasa, banka, POS, alınan/verilen çek-senet, stok, borçlular/alacaklılar, krediler ve kredi kartı bakiyelerini TL karşılığıyla toplayıp net bir SONUC (özkaynak/likidite göstergesi) üretir.
**Parametreler:** Yok (mevcut yıl GETDATE()'ten alınıyor).
**Ana tablolar:** POS, KASA, KASALAR, CEKLER, REHBER, FATBASLIK, KREDILER, PLANKREDI, KREDIKARTI, BANKAHESAPLAR, STOKLAR, STOK_ORT_MALIYET, FATURA, DOVIZ, GENINI.
**Dikkat çeken iş mantığı:** Çok karmaşık, iç içe alt sorgulardan oluşan tek bir dev SELECT; her bir bileşen (KDR_POS, KDR_ALINAN_CEK, KDR_KASA, KDR_STOK, KDR_ALACAKLILAR, KDR_KREDILER, KDR_KREDI_KARTI, KDR_VERILEN_CEK/SENET, KDR_BORCLULAR, KDR_BANKA) ayrı ayrı hesaplanıp döviz kuru (DOVIZ.SATIS) ile TL'ye çevriliyor; borçlular/alacaklılar ayrımı TOPLAM_BORC/TOPLAM_ALACAK karşılaştırmasıyla (R.KDR_Disi='False' filtresiyle) yapılıyor. Sonuç formülü: (Borçlular+Banka+POS+AlınanÇek+AlınanSenet+Kasa+Stok) - (Alacaklılar+Krediler+KrediKartı+VerilenÇek+VerilenSenet).

### TM_KDRSonucDetay
**Amaç:** TM_KDRSonuc'taki her bir bileşenin (banka, POS, çek, senet, kasa, stok, alacaklı/borçlu, kredi, kredi kartı) detay dökümünü, DOKUMLER tablosunda saklı hazır SQL raporlarını çalıştırarak döner.
**Parametreler:** @TIP varchar(2) (1-13 arası, her biri farklı bir detay raporuna karşılık geliyor).
**Ana tablolar:** DOKUMLER (rapor SQL'lerini saklıyor), dinamik olarak çalıştırılan raporun hedef tabloları (borçlular/alacaklılar için geçici tablo #TempResults / #TempResults1 kullanılıyor).
**Dikkat çeken iş mantığı:**
- Dinamik SQL: DOKUMLER tablosundan RAPORADI'ye göre çekilen SQL metninde :PDonemBas ve :PDonemSon parametre yer tutucuları, o yılın başlangıç/bitiş tarihleriyle REPLACE edilip EXEC(@SQL) ile çalıştırılıyor — bir tür şablon tabanlı rapor motoru.
- @TIP=1 ve @TIP=8 durumlarında sonuç önce geçici tabloya INSERT edilip ardından DETAY='Ekstre' sütunu eklenerek tekrar SELECT ediliyor; diğer durumlarda doğrudan EXEC ile sonuç dönülüyor.

### TM_KdvOzet
**Amaç:** Belirli bir tarih aralığında Hesaplanan KDV (satış faturaları, TUR 15/16) ile İndirilen KDV (alış faturaları, TUR 8/11/12) tutarlarını ve matrahlarını, KDV oranı ve KDV muafiyeti durumuna göre hesaplayıp özetler.
**Parametreler:** @BasTar DATETIME, @BitTar DATETIME, @KDVDURUM VARCHAR(20)=NULL (sonuçları 'Hesaplanan'/'İndirilen' ile filtrelemek için LIKE kullanılıyor).
**Ana tablolar:** FATURA, FATBASLIK, ISLEMTURLERI.
**Dikkat çeken iş mantığı:** KDV tutarı, faturanın KDVDURUM'una (Dahil/Hariç) ve KDVMUHAFIYETI (muafiyet yüzdesi) alanına göre 4 farklı formülle hesaplanıyor; İndirilen KDV tutarı raporda -1 ile çarpılarak negatif gösteriliyor (muhtemelen mahsuplaşma/rapor mantığı için).
