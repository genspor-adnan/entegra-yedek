## Bölüm 4: TM_SiparisAlinanDetay ... TM_Whatsappmesaj (Satır 6885 - 9198)

### TM_SiparisAlinanDetay
**Amaç:** Bir siparişin (SIPARIS) satır detaylarını (SIPARISDETAY) zengin bilgilerle (ürün/masraf adı, kod, ürün no, resim/döküman var mı, birim adları, ikincil birim miktarı, proje kodu, satıcı adı, stok çevrim ile dönüşen miktar, KDV tutarı, ekipman/seri no) listeler.
**Parametreler:** `@SIPARISID INT`.
**Tablolar:** SIPARISDETAY (ana), MASRAFGELIR, STOKLAR, GOREVYORUM, DOKUMAN, GENINI, PROJELER, REHBER, STOKCEVRIM, SIPARIS, EKIPMANLAR, EKIPMANREHBER.
**Notlar:** Salt okunur (sadece SELECT). TUR=0 ise satır bir masraf/gelir kalemi, değilse stok kalemi olarak ele alınıyor (çok sayıda CASE WHEN ile dallanma).

### TM_SiparisDetayGir
**Amaç:** Sipariş detay satırı (SIPARISDETAY) ekleme, güncelleme veya silme; ardından sipariş başlığındaki (SIPARIS) toplam tutarları yeniden hesaplayıp günceller.
**Parametreler:** @ID (0/boşsa yeni kayıt), @SIPARISID, @TUR (Sil ise satır silinir, Stok ise stok kalemi), @URUNID, @MIKTAR, @BIRIMFIYAT, @ISKONTO, @DOVIZ_KURU vb. çok sayıda parametre.
**Tablolar:** SIPARISDETAY (INSERT/UPDATE/DELETE), SIPARIS (UPDATE - toplamlar), DOVIZ (kur okuma).
**Notlar:** Döviz cinsi TL değilse DOVIZ tablosundan günün satış kurunu çekip tutar/birim fiyatı yeniden hesaplıyor. TRY/CATCH ile hata mesajı Türkçe döndürülüyor. Sipariş toplamları (SIPARIS_TUTARI, SIPARIS_MATRAHI, DOVIZ_TUTARI, KDV_TUTARI) her işlemden sonra SIPARISDETAY üzerinden SUM ile yeniden hesaplanıyor.

### TM_SiparisDurumGuncelle
**Amaç:** Bir siparişin durumunu (Tamamlandı/Kısmi/Yeni), satırların faturalanan miktarlarına göre otomatik günceller.
**Parametreler:** @SIPARISID INT.
**Tablolar:** SIPARIS (UPDATE DURUM), SIPARISDETAY, FATURA (YERI IN 409,410,429,473 olan faturalanmış miktarlar).
**Dikkat çekici hata:** @KISMI hesaplanan alt sorguda SD.SIPARISID = 10224 sabit (hardcoded) değer kullanılmış, parametre olan @SIPARISID kullanılmamış - bu görünüşe göre bir kopyala-yapıştır hatası ve üretimde yanlış kısmi sayısı hesaplanmasına yol açabilir. Sadece TUR=19 olan sipariş türü için çalışıyor.

### TM_SiparisGuncelle
**Amaç:** Sipariş başlığı (SIPARIS) ekleme, güncelleme veya silme (kalemleriyle birlikte).
**Parametreler:** Çok sayıda alan - @ID, @TARIH, @TUR, @TIPI, @REHBERID, @PROJEID, @SIPARISNO (Sil özel değeriyle silme tetiklenir), @DOVIZ_*, @DURUM, @VADE, @BAYIID vb.
**Tablolar:** SIPARIS (INSERT/UPDATE/DELETE), SIPARISDETAY (DELETE, silme akışında), REHBER, REHBERAYAR, REHBERBILGI, REHBERILETISIM, GENINI, DEPOLAR.
**Notlar:** Adres/vergi dairesi/vergi no gibi alanlar REHBERAYAR+REHBERBILGI'den dinamik olarak (VARSAYILAN kod eşleştirmesiyle) çekiliyor. Yeni sipariş numarası KOCANNO=1901 sabit değerine göre en büyük numaranın +1'i olarak üretiliyor. Kayıt sonrası TM_SiparisAlinan prosedürü çağrılıyor. TRY/CATCH hata yönetimi var; @SIPARISNO=Sil durumunda hem SIPARISDETAY hem SIPARIS silinir.

### TM_StokAra
**Amaç:** İnternet satışı için stok/ürün arama (ad, kod, ürün no, kategori veya barkod bazlı), fiyat listesi ve depo bazlı kalan miktar ile birlikte sonuç döndürür; kampanya bazlı iskonto hesabı da yapar.
**Parametreler:** @AD, @KOD, @URUNID (S=Sipariş bağlamı, F=Fatura bağlamı, SD=serbest depo araması, diğer=doğrudan ürün ID), @REHBERID, @BARKOD.
**Tablolar:** STOKLAR, STOKFIYAT, STOKDURUM, STOKBARKOD, GENINI, KAMPANYACARI, DEPOLAR, KATEGORI, SIPARIS, FATBASLIK.
**Notlar:** @URUNID değerine göre (S/F/SD/diğer) fiyat listesi ve depo farklı şekilde belirleniyor; sonuçlar sadece INTERNET_SATIS=1 ve DURUM=1 olan stoklarla sınırlı. SD modunda depo bazında detay JSON (DEPODETAYJSON, FOR JSON PATH) döndürülüyor. Kampanya iskontosu KAMPANYACARI+GENINI join'i ile ürün/kategori/masraf koduna göre hesaplanıyor.

### TM_StokAraDetay
**Amaç:** Belirli bir ürünün son 10 alış ve son 10 satış faturasını (opsiyonel olarak belirli bir cari/rehber ile filtrelenmiş) listeler; hızlı fiyat geçmişi görüntüleme amaçlı.
**Parametreler:** @URUNID, @REHBERID (0 ise tüm cariler).
**Tablolar:** FATBASLIK (TUR 11,12=alış; 15,16=satış), FATURA, REHBER.
**Notlar:** Salt okunur, UNION ALL ile alış/satış birleştiriliyor.

### TM_StokAraSayim
**Amaç:** Stok sayımı ekranı için ürün arama (ad/kod/barkod/kategori/depo bazlı), depo bazlı kalan miktar ile.
**Parametreler:** @AD, @KOD, @BARKOD, @DEPO, @KATEGORI.
**Tablolar:** STOKLAR, STOKFIYAT, STOKDURUM, STOKBARKOD, GENINI, KATEGORI.
**Notlar:** @FiyatAdi sabit olarak 10 atanmış (hardcoded, parametre değil). Barkod eşleşmesinde O/P/Q karakterlerini alt çizgi ile değiştirerek esnek eşleşme yapılıyor (muhtemelen benzer görünümlü karakterler/OCR hatası toleransı için).

### TM_StokSayim
**Amaç:** Belirli tarih aralığında, henüz onaylanmamış (SAYIMONAY≠1) stok sayımlarını listeler.
**Parametreler:** @BASTARIH, @BITTARIH.
**Tablolar:** STOKSAYIM, DEPOLAR, REHBER.
**Notlar:** Salt okunur, basit bir liste sorgusu.

### TM_StokSayimKalemleri
**Amaç:** Stok sayım kalemlerini (Listele/Giris/Sil tipleriyle) yönetir - sayım sırasında okutulan ürün miktarlarını, seri/lot bilgisiyle birlikte kaydeder.
**Parametreler:** @TIP (Listele/Giris/Sil), @SAYIMID, @STOKID, @SAYIMMIKTAR, @SERINO, @LOTNO, @SKT, @DEPOID vb.
**Tablolar:** STOKSAYIMKALEMLERI (INSERT/UPDATE - mevcutsa miktar arttırılıyor), STOKSERILOT (yoksa yeni seri/lot kaydı oluşturuluyor), STOKIZLEME (izleme kaydı insert/update), STOKIZLEMEDEPO (depo bazlı miktar), STOKLOKASYON (silmede).
**Notlar:** Giris akışı adım adım: önce kalem kaydı, sonra seri/lot kaydı (yoksa oluştur), sonra izleme kaydı (varsa miktarı artır, yoksa oluştur), sonra depo bazlı izleme kaydı - çok adımlı, transaction kullanılmadan (BEGIN TRAN yok) sıralı INSERT/UPDATE'ler yapılıyor; ara adımda hata olursa veri tutarsızlığı riski var. İşlem sonunda kendini Listele parametresiyle tekrar çağırarak güncel listeyi döndürüyor. Debug amaçlı PRINT ifadeleri kod içinde bırakılmış.

### TM_StokSeriLotListele
**Amaç:** Belge türüne göre (10=alış girişi, 14/20=çıkış/transfer) seçilebilecek seri/lot stoklarını listeler; ayrıca bir faturaya bağlı seri/lot hareketlerini silme işlevi sunar.
**Parametreler:** @TIP (Sil veya liste), @STOKID, @DEPOID, @STOKSERILOTID (silmede aslında bir FATURA.ID olarak kullanılıyor), @SIPARISID (aslında FATBASLIK.ID).
**Tablolar:** STOKDURUMIZLEME, STOKSERILOT, STOKIZLEME, STOKLOKASYON, FATURA, FATBASLIK.
**Notlar:** Sil modunda STOKIZLEME, STOKLOKASYON ve FATURA satırları ilişkili FATURA.ID üzerinden siliniyor.

### TM_STOKTRANSFER
**Amaç:** Depolar arası stok transfer belgelerini (FATBASLIK TUR=20) tarih aralığına veya tek bir ID'ye göre, opsiyonel olarak belirli bir bayiye (@BAYIID) göre listeler.
**Parametreler:** @BasTarihi, @BitTarihi, @ID, @TAMAMLANAN, @BAYIID (-1 ise tüm bayiler), @KULLANICIKODU.
**Tablolar:** FATBASLIK, DEPOLAR, REHBER, YETKIEK, ROLLER, KULLANICI, SIPARISDETAY, FATURA.
**Dikkat çekici nokta:** Prosedürün başında kullanıcının görme yetkisi (@GORMEYETKISI, @SUBEID) hesaplanıyor, fakat asıl WHERE koşulunda bu yetki filtreleri (ONAY, SATICIKODU, SUBEID bazlı satırlar) yorum satırına alınmış - yani hesaplanan yetki kontrolü fiilen uygulanmıyor; tüm transfer belgeleri (yetkiye bakılmaksızın) listeleniyor. Potansiyel bir yetkilendirme açığı/eksik kontrol olabilir.

### TM_STOKTRANSFERGuncelle
**Amaç:** Stok transfer belgesi (FATBASLIK, TUR=20) ekleme, güncelleme veya silme.
**Parametreler:** @TUR (Sil ise silme), @ID, @REHBERID (teslim alan), @SATICIKODU (teslim eden), @CIKISDEPO, @GIRISDEPO, @DURUM, @BAYIID.
**Tablolar:** FATBASLIK (INSERT/UPDATE/DELETE), FATURA (DELETE, silmede), DEPOLAR, KOCANAYARLARI.
**Notlar:** Yeni kayıtta belge numarası sp_BelgeNoGetir saklı yordamıyla otomatik alınıyor (bir table variable üzerinden). İşlem sonunda TM_STOKTRANSFER çağrılarak güncel kayıt/liste döndürülüyor. TRY/CATCH hata yönetimi var.

### TM_UretimEkAlanOzellikler
**Amaç:** Üretim ile ilgili ekranlarda (UretimEmriWizardDlg, IsEmriPersonelZamanDlg, FaturaWizardDlg) dinamik olarak gösterilecek ek alan tanımlarını ve bu alanların seçenek listesini (GENINI üzerinden STRING_AGG ile birleştirilmiş) döndürür.
**Parametreler:** @KONUM VARCHAR(50).
**Tablolar:** ALANLAR, GENINI.
**Notlar:** Meta-veri/konfigürasyon amaçlı, form alanlarının dinamik olarak (kod değişikliği gerektirmeden) tanımlanabilmesini sağlıyor.

### TM_UretimFason
**Amaç:** Üretim operasyonlarında dış kaynak (fason) kullanımıyla ilgili giriş/çıkış hareketlerini (URETIMOPERASYONFASON) yönetir.
**Parametreler:** @TIP (ListeleUel/GuncelleUel), @URETIMOPERASYONID, @OLAY (Giriş/Çıkış), @REHBERID, @GIREN, @CIKAN, @FASONTIPI, @ID.
**Tablolar:** URETIMOPERASYONFASON (INSERT/UPDATE/SELECT), REHBER, GENINI.
**Notlar:** Güncelleme sonrası kendini ListeleUel parametresiyle tekrar çağırarak güncel listeyi döndürüyor (liste + güncelleme tek prosedürde birleştirilmiş).

### TM_UretimImajListele
**Amaç:** Bir üretim operasyonuna bağlı stoğun resim ve dökümanlarını (ikisi birleşik) listeler.
**Parametreler:** @ID (URETIMOPERASYON.ID).
**Tablolar:** URETIMOPERASYON, STOKLAR, IMAJ, GOREVYORUM, DOKUMAN.
**Notlar:** Salt okunur, UNION ALL ile Resim ve Döküman türleri birleştiriliyor.

### TM_UretimOlcum
**Amaç:** Üretim operasyonu personeline bağlı kalite ölçüm kayıtlarını (URETIMOLCUM) listeler ve yönetir; yeni ölçüm oluşturulduğunda ilgili kalite şablonundan (KALITESABLONDETAY) otomatik olarak ölçüm detay satırları (URETIMOLCUMDETAY) üretir.
**Parametreler:** @ID, @OPID, @TIP (Listele/Guncelle), @TARIH, @KONUSU, @PERSONEL, @ADET, @DURUM (Bekliyor/Çalışılıyor/Tamamlandı).
**Tablolar:** URETIMOLCUM (INSERT/UPDATE/SELECT), URETIMOLCUMDETAY (INSERT), KALITESABLONDETAY, GENINI, REHBER, LOKASYON.
**Notlar:** Listelemede her ölçüm için ALARM durumu, altındaki detay satırlarının alarm durumuna göre hesaplanıyor (2=bekliyor, 4=uyarı, 3=normal). Yeni kayıt eklenirken nominal/limit değerlerine göre otomatik sapma ve alarm hesaplaması yapılıyor (ancak @DEGER değişkeni sabit 10 olarak atanmış - muhtemelen eksik/geliştirme aşamasında kalmış bir mantık, gerçek ölçüm değeri henüz girilmemiş olduğundan varsayılan). TRY/CATCH var.

### TM_UretimOlcumDetay
**Amaç:** Bir üretim ölçümüne ait detay satırlarını (kalite test değerleri, tolerans, nominal, alarm) listeler ve günceller.
**Parametreler:** @ID, @OLCUMID, @TIP (Listele/Guncelle), @JSON.
**Tablolar:** URETIMOLCUMDETAY, KALITESABLONDETAY, KALITETEST, GENINI, geçici tablo #URETIMDETAY.
**Dikkat çekici nokta (dinamik SQL + cursor):** Listeleme sırasında her satırın KAYNAK sütununda saklı bir SQL sorgu metni varsa, bir CURSOR ile tek tek dolaşılıp sp_executesql ile dinamik olarak çalıştırılıyor ve sonucu KAYNAKSONUC alanına yazılıyor. Bu, veritabanında saklı serbest metin SQL'in doğrudan çalıştırılması anlamına geliyor - performans açısından satır satır cursor kullanımı maliyetli, güvenlik açısından da KAYNAK alanının kim tarafından/nasıl doldurulduğuna bağlı olarak potansiyel bir risk taşıyor. Güncelleme kısmında OPENJSON ile tolerans/alarm hesaplaması (nominal artı/eksi limit) yapılıyor. TRY/CATCH var.

### TM_UretimPersonelZamanPlanla
**Amaç:** Üretim emirlerini (URETIMEMRI) tarih aralığına veya belirli bir emir numarasına göre, fason/yorum/sipariş bilgileriyle zenginleştirilmiş şekilde listeler.
**Parametreler:** @BasTarihi, @BitTarihi, @kalmayan (0 ise sadece DURUM>0 olanlar), @EMIRNO.
**Tablolar:** URETIMEMRI, GENINI, REHBER, URETIMOPERASYONFASON, GOREVYORUM, STOKLAR, SIPARIS.
**Dikkat çekici nokta (dinamik SQL):** Sorgu tamamen bir @sql string değişkeninde inşa edilip EXEC(@SQL) ile çalıştırılıyor; @EMIRNO ve tarih parametreleri doğrudan string birleştirme ile sorguya ekleniyor (parametrized query değil). Bu, parametreler kullanıcı girdisinden geliyorsa SQL injection riski taşır.

### TM_UretimPersonelZamanPlanlaDetay
**Amaç:** Bir üretim operasyonuna atanmış personelin zaman planlama detaylarını (başlama/bitiş, mola, süre, lot, sıcaklık, voltaj, reçete süresi, iskarta, üretilen adet) listeler.
**Parametreler:** @ID (URETIMOPERASYON.ID).
**Tablolar:** URETIMOPERASYONPERSONEL, URETIMOPERASYON, GENINI, REHBER, LOKASYON, URETIMOLCUM (ölçüm adedi sayımı için).
**Notlar:** Süre, FORMAT(DATEADD(...)) ile HH:mm formatında hesaplanıyor. Salt okunur.

### TM_UretimPersonelZamanPlanlaDetayGuncelle
**Amaç:** Personel zaman planlama detay satırını (URETIMOPERASYONPERSONEL) ekler veya günceller (üretim süreç takibi - başlama/bitiş saatleri, lot, sıcaklık, voltaj vb. üretim parametreleri).
**Parametreler:** @OPID, @BasTar/@BitTar/@BasTarT/@BitTarT (tarih+saat ayrı ayrı, string birleştirme ile datetime'a çevriliyor), @LOTU, @SICAKLIGI, @VOLTAJ, @RECETESURE, @ISKARTA, @URETILEN, @SIRA.
**Tablolar:** URETIMOPERASYONPERSONEL (INSERT/UPDATE), URETIMRECETEOPR (yeni kayıtta YERID eşleştirmesi için).
**Notlar:** Tarih/saat, string birleştirmesiyle oluşturuluyor (implicit convert'e güveniliyor, format hatalarına açık). Boş string parametreler NULL'a çevriliyor. Güncelleme sonrası TM_UretimPersonelZamanPlanlaDetay çağrılarak güncel liste döndürülüyor. TRY/CATCH var.

### TM_UretimPersonelZamanPlanlaDurumGuncelle
**Amaç:** Emir numarasına göre üretim emrinin (URETIMEMRI) durumunu, GENINI tablosundaki karşılık gelen koda çevirerek günceller.
**Parametreler:** @UID (EMIRNO), @DURUM (metin karşılığı, örnek Tamamlandı).
**Tablolar:** URETIMEMRI (UPDATE), GENINI.
**Notlar:** Tek satırlık basit bir durum güncelleme prosedürü.

### TM_UretimPersonelZamanPlanlaEkalanlar
**Amaç:** URETIMEMRI tablosundaki tüm sütunları meta-veri (SYS.COLUMNS) üzerinden dinamik olarak sorgulayıp, ek alanlar ekranı için hem listeleme hem de JSON tabanlı toplu güncelleme yapan generic (tabloya bağımlı olmayan) bir prosedür.
**Parametreler:** @EMIRNO, @TIP (Listele/Guncelle), @JSON.
**Tablolar:** URETIMEMRI, ALANLAR (hangi alanların bu ekranda gösterileceğini belirleyen konfigürasyon), sistem tabloları SYS.OBJECTS/SYS.COLUMNS/sys.types.
**Dikkat çekici nokta (yoğun dinamik SQL):** Kolon listesi ve UPDATE/SELECT cümleleri tamamen metin birleştirmeyle (@sql, @alanadlari) inşa edilip EXEC(@sql) ile çalıştırılıyor. @EMIRNO ve @json parametreleri de doğrudan string olarak sorguya ekleniyor (tek tırnak escape'i görünmüyor) - bu, SQL injection açısından riskli bir tasarım. Güncellemede OPENJSON + dinamik kolon eşleştirmesiyle URETIMEMRI satırı toplu güncelleniyor. TRY/CATCH var.

### TM_UretimPersonelZamanPlanlaEkalanlarSatir
**Amaç:** Yukarıdaki (TM_UretimPersonelZamanPlanlaEkalanlar) ile aynı mantığın URETIMOPERASYONPERSONEL (satır bazlı personel zaman planı) tablosu için versiyonu.
**Parametreler:** @ID, @TIP (Listele/Guncelle), @JSON.
**Tablolar:** URETIMOPERASYONPERSONEL, ALANLAR, TMLOG (JSON loglama), sistem tabloları.
**Notlar:** Güncelleme öncesi gelen JSON, TMLOG tablosuna ham olarak kaydediliyor (denetim/log amaçlı). Aynı şekilde tamamen dinamik SQL (EXEC(@sql)) kullanıyor; @ID ve @json string birleştirmeyle sorguya giriyor - SQL injection riski burada da geçerli.

### TM_UretimPersonelZamanPlanlaOpr
**Amaç:** Belirli bir üretim operasyonunun (URETIMOPERASYON) tüm özet bilgilerini (emir no, ürün kodu, personel, planlanan başlama/bitiş, giriş/çıkış depoları, reçete) ve reçete adımlarını (JSON olarak) tek satırda döndürür.
**Parametreler:** @ID (URETIMOPERASYON.ID).
**Tablolar:** URETIMOPERASYON, URETIMEMRI, STOKLAR, REHBER, GENINI, DEPOLAR, URETIMRECETEOPR, IMAJ, GOREVYORUM, DOKUMAN.
**Notlar:** RECETELISTE alanı, URETIMRECETEOPR'daki reçete adımlarını FOR JSON PATH ile serileştirip elle bir JSON zarfına (success/results) sarıyor - sadece URETIMEMRI.DURUM > 0 olan emirler için çalışıyor.

### TM_UserGiris
**Amaç:** Kullanıcı girişi (login) sorgusu - kullanıcı adı veya e-posta ile eşleşen kullanıcı kaydını ve şifresini döndürür.
**Parametreler:** @KADI VARCHAR(50) (kullanıcı adı veya e-posta), @CIHAZID VARCHAR(250)=NULL (cihaz kimliği, opsiyonel).
**Tablolar:** TMLOG (INSERT - login denemesi loglanıyor), KULLANICI, REHBER, REHBERILETISIM, REHBERBILGI.
**GÜVENLİK NOTU (önemli):** Bu prosedür şifre doğrulaması yapmıyor - parametre listesinde bir şifre/parola parametresi bile yok. Sadece kullanıcı adı/e-posta ile eşleştirme yapıp KULLANICI tablosundaki SIFRE alanını olduğu gibi (düz metin gibi görünen bir SELECT ile) çağırana geri döndürüyor. Bu, şifre doğrulamasının sunucu tarafında değil, muhtemelen istemci (client/uygulama) tarafında, sunucudan gelen şifre değeriyle karşılaştırılarak yapıldığını gösteriyor - ki bu ciddi bir güvenlik zafiyetidir: (1) Şifre ağ üzerinden istemciye açık şekilde taşınıyor, (2) sorguda herhangi bir hash fonksiyonu (HASHBYTES vb.) kullanılmıyor, şifrenin veritabanında da düz metin saklanıyor olma ihtimalini güçlendiriyor, (3) prosedür SIFRE alanını kimliği doğrulanmamış herhangi bir çağırana (sadece kullanıcı adını bilen herkese) döndürüyor - bu da hesap ele geçirme riskini artırıyor. Ayrıca UNION ALL bloğunda, REHBER.BAGID ile bağlı alt hesaplar (GRUP=951) için SIFRE alanı olarak REHBERBILGI tablosundaki Eposta etiketli değer (yani kullanıcının e-posta adresi) döndürülüyor - bu grup için şifre fiilen e-posta adresiyle aynı, bu da ayrı bir güvenlik zafiyeti oluşturuyor.

### TM_Whatsappcontacts
**Amaç:** Harici bir WhatsApp entegrasyonundan (muhtemelen whatsapp-web.js benzeri bir servisten) gelen kişi listesini JSON olarak alıp TMWHATSAPPCONTACTS tablosuna aktarır.
**Parametreler:** @JSON NVARCHAR(MAX).
**Tablolar:** TMWHATSAPPCONTACTS (TRUNCATE + INSERT).
**Notlar:** Her çağrıda tablo TRUNCATE edilip tamamen yeniden dolduruluyor (tam senkronizasyon mantığı; kısmi/artımlı güncelleme değil - büyük kişi listelerinde performans ve eşzamanlılık riski olabilir). OPENJSON ile contacts yolu parse ediliyor, serverx=lid olan kayıtlar (özel WhatsApp ID formatı) hariç tutuluyor.

### TM_Whatsappmesaj
**Amaç:** Harici WhatsApp entegrasyonundan gelen mesaj JSON'unu ham olarak loglar, TMWHATSAPPMESAJCHAT tablosuna ayrıştırıp kaydeder, ayrıca bildirim amaçlı filtrelenmiş bir mesaj seçimi döndürür.
**Parametreler:** @JSON NVARCHAR(MAX).
**Tablolar:** TMLOG (INSERT - ham JSON log), TMWHATSAPPMESAJCHAT (INSERT, OPENJSON ile parse).
**Notlar:** body yolu OPENJSON ile parse edilerek ack, mesaj içeriği, gönderen/alıcı, zaman damgası gibi alanlar tabloya yazılıyor. Sonda ayrı bir SELECT ile typex NOT IN (e2e_notification, notification_template) filtresiyle gerçek mesajlar döndürülüyor - muhtemelen çağıran uygulamanın bildirim göstermesi için kullanılıyor.
