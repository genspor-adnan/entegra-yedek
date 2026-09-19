-- =====================================================================
-- 871 - BAĞLAMSAL YARDIM ASİSTANI
--
-- AI Rehber, kullanıcının bulunduğu ekranı SUNUCUDA doğrulayan bağlamsal
-- yardım asistanına dönüştü (RehberServisi · EkranBaglamiCozucu ·
-- YardimDizini). Bu dosya asistanın veri tarafını hazırlar:
--
--   1) EKRAN KATALOĞU SENKRONU: istemci menüsünde (listeTanimlari*.ts) olup
--      ai_rehber_ekran'da olmayan ekranlar eklendi (Diş, Sterilizasyon,
--      Çağrı Merkezi, Göz, FTR, Medula, Teleradyoloji, Yatan, Eczane,
--      Satınalma, Teknik Servis, İSG, Onay, Form...). Katalogda olmayan
--      ekranda asistan "ekranı tanımadım" diyordu. Menü yolu değişen
--      satırların yolu düzeltildi. (Üretici: web LISTELER dökümü.)
--   2) SOHBET ŞUBE İZOLASYONU: ai_sohbet.sube_id - sohbet kullanıcı +
--      şube ile okunur; eski satırlar (null) yalnız sahibine açık kalır.
--   3) GÜNLÜK ALANLARI: ai_rehber_log.ekran_kaynak / sekme / dil /
--      kaynaklar (yardım belgesi atıfları) / pii_maske. SORU ARTIK MASKELİ
--      YAZILIR (kimlik no, telefon, e-posta, IBAN, uzun numara) - eski
--      satırlar da bu dosyada maskelenir.
--   4) SAKLAMA: referans ai.log_saklama_gun (90) ve ai.sohbet_saklama_gun
--      (365); fn_ai_temizle() bunlara göre siler; zamanlı iş ai.temizlik
--      her gece 03:30. ai.saglayici_veri_saklama bilgi amaçlı (sağlayıcı
--      sözleşmesi; kod bunu değiştiremez).
--   5) YETKİ: yardım dizinini yeniden kurma (ai.yardim) yönetici işi.
-- =====================================================================

-- ---------------------------------------------------------- 1) ekranlar
insert into public.ai_rehber_ekran
  (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu,
   modul, kart_yolu, menu_gizli, anahtar, aksiyon_ekrani)
values
('calisma-plani','/calisma-plani','Çalışma Planları','Randevu › Çalışma Planları','Randevu','Çalışma Planları','randevu.plan',2,'randevu','',0,'Çalışma Planları Çalışma Planları Randevu calisma planlari calisma plani',''),
('calisma-sablon','/calisma-sablon','Çalışma Şablonları','Randevu › Çalışma Şablonları','Randevu','Çalışma Şablonları','randevu.plan',2,'randevu','/calisma-sablon',0,'Çalışma Şablonları Çalışma Şablonları Randevu calisma sablonlari calisma sablon','calisma-sablon-liste'),
('calisma-istisna','/calisma-istisna','İzin & İstisnalar','Randevu › İzin & İstisnalar','Randevu','İzin & İstisnalar','randevu.plan',2,'randevu','/calisma-istisna',0,'İzin & İstisnalar İzin & İstisnalar Randevu izin & istisnalar calisma istisna','calisma-istisna-liste'),
('iskonto-onay','/iskonto-onay','İskonto Onayı','Kayıt Kabul › İskonto Onayı','Kayıt Kabul','İskonto Onayı','iskonto_onay',2,'kayit_kabul','',0,'İskonto Onayı İskonto Onayı Kayıt Kabul iskonto onayi iskonto onay',''),
('hasta-avans','/hasta-avans','Hasta Avansları','Kayıt Kabul › Hasta Avansları','Kayıt Kabul','Hasta Avansları','kasa_islem',2,'muayene','',0,'Hasta Avansları Hasta Avansları Kayıt Kabul hasta avanslari hasta avans','avans-liste'),
('hakedisim','/hakedisim','Hakedişlerim','Muayene › Hakedişlerim','Muayene','Hakedişlerim','prim.kendi',2,'muayene','',0,'Hakedişlerim Hakedişlerim Muayene hakedislerim hakedisim',''),
('telerad-istek','/teleradyoloji','Teleradyoloji Çalışma Listesi','Teleradyoloji › Çalışma Listesi','Radyoloji','Teleradyoloji Listesi','teleradyoloji',2,'teleradyoloji','/teleradyoloji',0,'Teleradyoloji Çalışma Listesi Teleradyoloji Listesi Radyoloji teleradyoloji calisma listesi telerad istek','telerad-istek-liste'),
('telerad-pano','/telerad-pano','Teleradyoloji Panosu','Teleradyoloji › Pano','Radyoloji','Telerad Panosu','teleradyoloji',2,'teleradyoloji','',0,'Teleradyoloji Panosu Telerad Panosu Radyoloji teleradyoloji panosu telerad pano',''),
('telerad-kurum','/telerad-kurum','Teleradyoloji Kurumları','Teleradyoloji › Kurumlar','Radyoloji','Telerad Kurumları','teleradyoloji.kurum',2,'teleradyoloji','/telerad-kurum',0,'Teleradyoloji Kurumları Telerad Kurumları Radyoloji teleradyoloji kurumlari telerad kurum','telerad-kurum-liste'),
('telerad-fatura','/telerad-fatura','Teleradyoloji Dönem Faturası','Teleradyoloji › Dönem Faturası','Radyoloji','Dönem Faturası','teleradyoloji.kurum',2,'teleradyoloji','',0,'Teleradyoloji Dönem Faturası Dönem Faturası Radyoloji teleradyoloji donem faturasi telerad fatura',''),
('telerad-nobet','/telerad-nobet','Teleradyoloji Nöbet Çizelgesi','Teleradyoloji › Nöbet','Radyoloji','Nöbet Çizelgesi','teleradyoloji.nobet',2,'teleradyoloji','/telerad-nobet',0,'Teleradyoloji Nöbet Çizelgesi Nöbet Çizelgesi Radyoloji teleradyoloji nobet cizelgesi telerad nobet','telerad-nobet-liste'),
('telerad-kural','/telerad-kural','Teleradyoloji Atama Kuralları','Teleradyoloji › Atama Kuralları','Radyoloji','Atama Kuralları','teleradyoloji.kural',2,'teleradyoloji','/telerad-kural',0,'Teleradyoloji Atama Kuralları Atama Kuralları Radyoloji teleradyoloji atama kurallari telerad kural','telerad-kural-liste'),
('telerad-sozlesme','/telerad-sozlesme','Teleradyoloji Sözleşmeleri','Teleradyoloji › Sözleşmeler','Radyoloji','Telerad Sözleşmeleri','teleradyoloji.sozlesme',2,'teleradyoloji','/telerad-sozlesme',0,'Teleradyoloji Sözleşmeleri Telerad Sözleşmeleri Radyoloji teleradyoloji sozlesmeleri telerad sozlesme','telerad-sozlesme-liste'),
('telerad-teslim','/telerad-teslim','Teslim Kuyruğu','Teleradyoloji › Teslim Kuyruğu','Radyoloji','Teslim Kuyruğu','teleradyoloji',2,'teleradyoloji','',0,'Teslim Kuyruğu Teslim Kuyruğu Radyoloji teslim kuyrugu telerad teslim','telerad-teslim-liste'),
('telerad-gelen','/telerad-gelen','Gelen Raporlar','Teleradyoloji › Gelen Raporlar','Radyoloji','Gelen Raporlar','teleradyoloji',2,'teleradyoloji','',0,'Gelen Raporlar Gelen Raporlar Radyoloji gelen raporlar telerad gelen','telerad-gelen-liste'),
('telerad-bakanlik-eksik','/telerad-bakanlik-eksik','Bakanlık Gönderim Eksikleri','Teleradyoloji › Bakanlık Eksikleri','Radyoloji','Bakanlık Eksikleri','teleradyoloji',2,'teleradyoloji','',0,'Bakanlık Gönderim Eksikleri Bakanlık Eksikleri Radyoloji bakanlik gonderim eksikleri telerad bakanlik eksik',''),
('goz-akis','/goz-akis','Göz Ünitesi Akışı','Göz › Ünite Akışı','Göz','Ünite Akışı','goz',2,'goz','',0,'Göz Ünitesi Akışı Ünite Akışı Göz goz unitesi akisi goz akis','goz-akis-liste'),
('goz-muayene','/goz-muayene','Göz Muayeneleri','Göz › Muayeneler','Göz','Muayeneler','goz.muayene',2,'goz','/goz-muayene',0,'Göz Muayeneleri Muayeneler Göz goz muayeneleri goz muayene','goz-muayene-liste'),
('goz-goruntuleme','/goz-goruntuleme','Göz Görüntüleme','Göz › Görüntüleme & Testler','Göz','Görüntüleme & Testler','goz.goruntuleme',2,'goz','/goz-goruntuleme',0,'Göz Görüntüleme Görüntüleme & Testler Göz goz goruntuleme goz goruntuleme','goz-goruntuleme-liste'),
('goz-islem','/goz-islem','Göz İşlemleri','Göz › İşlemler','Göz','İşlemler','goz.islem',2,'goz','/goz-islem',0,'Göz İşlemleri İşlemler Göz goz islemleri goz islem','goz-islem-liste'),
('goz-gozluk-recete','/goz-gozluk-recete','Gözlük Reçeteleri','Göz › Gözlük Reçeteleri','Göz','Gözlük Reçeteleri','goz.recete',2,'goz','/goz-gozluk-recete',0,'Gözlük Reçeteleri Gözlük Reçeteleri Göz gozluk receteleri goz gozluk recete','goz-gozluk-recete-liste'),
('goz-takip','/goz-takip','Göz Hastalık Takibi','Göz › Hastalık Takibi','Göz','Hastalık Takibi','goz.takip',2,'goz','/goz-takip',0,'Göz Hastalık Takibi Hastalık Takibi Göz goz hastalik takibi goz takip','goz-takip-liste'),
('goz-hasta-ozet','/goz-hasta-ozet','Göz Hasta Özeti','Göz › Hasta Özeti','Göz','Hasta Özeti','goz',2,'goz','',0,'Göz Hasta Özeti Hasta Özeti Göz goz hasta ozeti goz hasta ozet','goz-hasta-ozet-liste'),
('goz-kontakt-lens','/goz-kontakt-lens','Kontakt Lens','Göz › Kontakt Lens','Göz','Kontakt Lens','goz.recete',2,'goz','/goz-kontakt-lens',0,'Kontakt Lens Kontakt Lens Göz kontakt lens goz kontakt lens','goz-kontakt-lens-liste'),
('goz-islem-protokol','/goz-islem-protokol','İşlem Protokolleri','Göz › Ayarlar › İşlem Protokolleri','Göz','İşlem Protokolleri','goz.islem',2,'goz','/goz-islem-protokol',0,'İşlem Protokolleri İşlem Protokolleri Göz islem protokolleri goz islem protokol','goz-islem-protokol-liste'),
('goz-cihaz-mesaj','/goz-cihaz-mesaj','Cihaz Mesajları','Göz › Ayarlar › Cihaz Mesajları','Göz','Cihaz Mesajları','goz.cihaz',2,'goz','',0,'Cihaz Mesajları Cihaz Mesajları Göz cihaz mesajlari goz cihaz mesaj','goz-cihaz-mesaj-liste'),
('goz-cihaz','/goz-cihaz','Göz Cihazları','Göz › Ayarlar › Cihazlar','Göz','Cihazlar','goz.cihaz',2,'goz','/goz-cihaz',0,'Göz Cihazları Cihazlar Göz goz cihazlari goz cihaz','goz-cihaz-liste'),
('dikte-terim','/dikte-terim','Dikte Sözlüğü','Göz › Ayarlar › Dikte Sözlüğü','Göz','Dikte Sözlüğü','goz.dikte_sozluk',2,'goz','/dikte-terim',0,'Dikte Sözlüğü Dikte Sözlüğü Göz dikte sozlugu dikte terim','dikte-terim-liste'),
('yatan','/yatan','Yatan Hastalar','Yatan Hasta › Servis Listesi','Yatan Hasta','Yatan Hastalar','yatan',2,'yatan_hasta','/yatan',0,'Yatan Hastalar Yatan Hastalar Yatan Hasta yatan hastalar yatan','yatan-liste'),
('yatak','/yatak','Yatak Panosu','Yatan Hasta › Yatak Panosu','Yatan Hasta','Yatak Panosu','yatan',2,'yatan_hasta','/yatak',0,'Yatak Panosu Yatak Panosu Yatan Hasta yatak panosu yatak','yatak-liste'),
('yatis-order','/yatis-order','Order Listesi','Yatan Hasta › Order','Yatan Hasta','Order','yatan.order',2,'yatan_hasta','/yatis-order',0,'Order Listesi Order Yatan Hasta order listesi yatis order','yatis-order-liste'),
('order-uygulama','/order-uygulama','Doz Kuyruğu','Yatan Hasta › İlaç Uygulama','Yatan Hasta','İlaç Uygulama','yatan.order',2,'yatan_hasta','',0,'Doz Kuyruğu İlaç Uygulama Yatan Hasta doz kuyrugu order uygulama','order-uygulama-liste'),
('yatis-izlem','/yatis-izlem','Hemşire İzlem','Yatan Hasta › İzlem','Yatan Hasta','Hemşire İzlem','yatan.izlem',2,'yatan_hasta','',0,'Hemşire İzlem Hemşire İzlem Yatan Hasta hemsire izlem yatis izlem','yatis-izlem-liste'),
('yatis-tahakkuk','/yatis-tahakkuk','Hizmet İcmali','Yatan Hasta › Hizmet İcmali','Yatan Hasta','Hizmet İcmali','yatan',2,'yatan_hasta','',0,'Hizmet İcmali Hizmet İcmali Yatan Hasta hizmet icmali yatis tahakkuk','yatis-tahakkuk-liste'),
('oda','/oda','Odalar','Yatan Hasta › Ayarlar › Odalar','Yatan Hasta','Odalar','yatan.yatak',2,'yatan_hasta','/oda',0,'Odalar Odalar Yatan Hasta odalar oda','oda-liste'),
('dis-akis','/dis-akis','Diş Kliniği Günlük Akış','Diş › Günlük Akış','Diş','Günlük Akış','dis',2,'dis','',0,'Diş Kliniği Günlük Akış Günlük Akış Diş dis klinigi gunluk akis dis akis',''),
('dis-hasta','/dis-hasta','Diş Hastaları','Diş › Hastalar','Diş','Hastalar (Odontogram)','dis.hasta',2,'dis','/dis-hasta',0,'Diş Hastaları Hastalar (Odontogram) Diş dis hastalari dis hasta','dis-hasta-liste'),
('dis-plan','/dis-plan','Tedavi Planları','Diş › Tedavi Planları','Diş','Tedavi Planları','dis.plan',2,'dis','/dis-plan',0,'Tedavi Planları Tedavi Planları Diş tedavi planlari dis plan','dis-plan-liste'),
('dis-seans','/dis-seans','Seanslar','Diş › Seanslar','Diş','Seanslar','dis.seans',2,'dis','/dis-seans',0,'Seanslar Seanslar Diş seanslar dis seans','dis-seans-liste'),
('dis-lab-isemri','/dis-lab-isemri','Lab İş Emirleri','Diş › Protez Laboratuvarı','Diş','Lab İş Emirleri','dis.lab',2,'dis','/dis-lab-isemri',0,'Lab İş Emirleri Lab İş Emirleri Diş lab is emirleri dis lab isemri','dis-lab-isemri-liste'),
('dis-odeme-plani','/dis-odeme-plani','Ödeme Planları','Diş › Ödeme Planları','Diş','Ödeme Planları','dis.odeme',2,'dis','/dis-odeme-plani',0,'Ödeme Planları Ödeme Planları Diş odeme planlari dis odeme plani','dis-odeme-plani-liste'),
('dis-unit','/dis-unit','Ünitler','Diş › Ayarlar › Ünitler','Diş','Ünitler','dis.unit',2,'dis','/dis-unit',0,'Ünitler Ünitler Diş unitler dis unit','dis-unit-liste'),
('dis-lab','/dis-lab','Laboratuvarlar','Diş › Ayarlar › Laboratuvarlar','Diş','Laboratuvarlar','dis.unit',2,'dis','/dis-lab',0,'Laboratuvarlar Laboratuvarlar Diş laboratuvarlar dis lab','dis-lab-liste'),
('ftr-pano','/ftr-pano','Ünite Panosu','FTR › Ünite Panosu','FTR','Ünite Panosu','ftr.seans',2,'ftr','',0,'Ünite Panosu Ünite Panosu FTR unite panosu ftr pano',''),
('ftr-degerlendirme','/ftr-degerlendirme','FTR Değerlendirmeleri','FTR › Değerlendirmeler','FTR','Değerlendirmeler','ftr.degerlendirme',2,'ftr','/ftr-degerlendirme',0,'FTR Değerlendirmeleri Değerlendirmeler FTR ftr degerlendirmeleri ftr degerlendirme','ftr-degerlendirme-liste'),
('ftr-program','/ftr-program','Tedavi Programları (Kür)','FTR › Tedavi Programları','FTR','Tedavi Programları','ftr.program',2,'ftr','/ftr-program',0,'Tedavi Programları (Kür) Tedavi Programları FTR tedavi programlari (kur) ftr program','ftr-program-liste'),
('ftr-program','/ftr-program-kart','Tedavi Programı (kart)','FTR › Tedavi Programı','FTR','Tedavi Programı (kart)','ftr.program',2,'ftr','/ftr-program-kart',1,'Tedavi Programı (kart) Tedavi Programı (kart) FTR tedavi programi (kart) ftr program','ftr-program-liste'),
('ftr-seans','/ftr-seans','Seanslar','FTR › Seanslar','FTR','Seanslar','ftr.seans',2,'ftr','/ftr-seans',0,'Seanslar Seanslar FTR seanslar ftr seans','ftr-seans-liste'),
('ftr-olcek','/ftr-olcek','Ölçekler','FTR › Ölçekler','FTR','Ölçekler','ftr.olcek',2,'ftr','/ftr-olcek',0,'Ölçekler Ölçekler FTR olcekler ftr olcek','ftr-olcek-liste'),
('ftr-unite','/ftr-unite','Üniteler & Kabinler','FTR › Ayarlar › Üniteler','FTR','Üniteler & Kabinler','ftr.unite',2,'ftr','/ftr-unite',0,'Üniteler & Kabinler Üniteler & Kabinler FTR uniteler & kabinler ftr unite','ftr-unite-liste'),
('form-sablon','/form-sablon','Form Şablonları','Yönetim › Formlar › Şablonlar','Yönetim','Form Şablonları','form.sablon',2,'form','/form-sablon',0,'Form Şablonları Form Şablonları Yönetim form sablonlari form sablon','form-sablon-liste'),
('form-kutuphane','/form-kutuphane','Form Kütüphanesi','Yönetim › Formlar › Kütüphane','Yönetim','Kütüphane (Bakanlık / SKS)','form.kutuphane',2,'form','',0,'Form Kütüphanesi Kütüphane (Bakanlık / SKS) Yönetim form kutuphanesi form kutuphane',''),
('form-istek','/form-istek','Doldurulan Formlar','Yönetim › Formlar › Doldurulan Formlar','Yönetim','Doldurulan Formlar','form.istek',2,'form','',0,'Doldurulan Formlar Doldurulan Formlar Yönetim doldurulan formlar form istek','form-istek-liste'),
('form-kural','/form-kural','Form Kuralları (tetikleyiciler)','Yönetim › Formlar › Kurallar','Yönetim','Kurallar (tetikleyiciler)','form.kural',2,'form','/form-kural',0,'Form Kuralları (tetikleyiciler) Kurallar (tetikleyiciler) Yönetim form kurallari (tetikleyiciler) form kural','form-kural-liste'),
('isg-pano','/isg-pano','Firma Panosu','İşyeri Hekimliği › Firma Panosu','İşyeri Hekimliği','Firma Panosu','isg.pano',2,'isg','',0,'Firma Panosu Firma Panosu İşyeri Hekimliği firma panosu isg pano',''),
('isg-takvim','/isg-takvim','Periyodik Muayene Takvimi','İşyeri Hekimliği › Periyodik Takvim','İşyeri Hekimliği','Periyodik Takvim','isg.takvim',2,'isg','',0,'Periyodik Muayene Takvimi Periyodik Takvim İşyeri Hekimliği periyodik muayene takvimi isg takvim',''),
('isg-calisan','/isg-calisan','Çalışanlar','İşyeri Hekimliği › Çalışanlar','İşyeri Hekimliği','Çalışanlar','isg.calisan',2,'isg','/isg-calisan',0,'Çalışanlar Çalışanlar İşyeri Hekimliği calisanlar isg calisan','isg-calisan-liste'),
('isg-calisan','/isg-calisan-kart','Çalışan (kart)','İşyeri Hekimliği › Çalışan','İşyeri Hekimliği','Çalışan (kart)','isg.calisan',2,'isg','/isg-calisan-kart',1,'Çalışan (kart) Çalışan (kart) İşyeri Hekimliği calisan (kart) isg calisan','isg-calisan-liste'),
('isg-muayene','/isg-muayene','Ek-2 Muayeneleri','İşyeri Hekimliği › Ek-2 Muayeneleri','İşyeri Hekimliği','Ek-2 Muayeneleri','isg.muayene',2,'isg','/isg-muayene',0,'Ek-2 Muayeneleri Ek-2 Muayeneleri İşyeri Hekimliği ek-2 muayeneleri isg muayene','isg-muayene-liste'),
('isg-ziyaret','/isg-ziyaret','İşyeri Ziyaretleri','İşyeri Hekimliği › Ziyaretler','İşyeri Hekimliği','Ziyaretler','isg.ziyaret',2,'isg','/isg-ziyaret',0,'İşyeri Ziyaretleri Ziyaretler İşyeri Hekimliği isyeri ziyaretleri isg ziyaret','isg-ziyaret-liste'),
('isg-olay','/isg-olay','İş Kazası ve Olaylar','İşyeri Hekimliği › Olaylar','İşyeri Hekimliği','Olaylar (Kaza · Bildirim)','isg.olay',2,'isg','/isg-olay',0,'İş Kazası ve Olaylar Olaylar (Kaza · Bildirim) İşyeri Hekimliği is kazasi ve olaylar isg olay','isg-olay-liste'),
('isg-firma','/isg-firma','Firmalar (İşverenler)','İşyeri Hekimliği › Ayarlar › Firmalar','İşyeri Hekimliği','Firmalar (işveren, bölüm)','isg.firma',2,'isg','/isg-firma',0,'Firmalar (İşverenler) Firmalar (işveren, bölüm) İşyeri Hekimliği firmalar (isverenler) isg firma','isg-firma-liste'),
('cagri-pano','/cagri-pano','Operatör Panosu','Çağrı Merkezi › Operatör Panosu','Çağrı Merkezi','Operatör Panosu','cagri.pano',2,'cagri','',0,'Operatör Panosu Operatör Panosu Çağrı Merkezi operator panosu cagri pano',''),
('cagri-giden','/cagri-giden','Giden Arama · Kampanya','Çağrı Merkezi › Giden Arama','Çağrı Merkezi','Giden Arama · Kampanya','cagri.giden',2,'cagri','',0,'Giden Arama · Kampanya Giden Arama · Kampanya Çağrı Merkezi giden arama · kampanya cagri giden',''),
('cagri','/cagri','Çağrı Kayıtları','Çağrı Merkezi › Çağrı Kayıtları','Çağrı Merkezi','Çağrı Kayıtları','cagri.kayit',2,'cagri','/cagri',0,'Çağrı Kayıtları Çağrı Kayıtları Çağrı Merkezi cagri kayitlari cagri','cagri-liste'),
('cagri','/cagri-kart','Çağrı (kart)','Çağrı Merkezi › Çağrı','Çağrı Merkezi','Çağrı (kart)','cagri.kayit',2,'cagri','/cagri-kart',1,'Çağrı (kart) Çağrı (kart) Çağrı Merkezi cagri (kart) cagri','cagri-liste'),
('cagri-kampanya','/cagri-kampanya','Kampanyalar','Çağrı Merkezi › Kampanyalar','Çağrı Merkezi','Kampanyalar','cagri.kampanya',2,'cagri','/cagri-kampanya',0,'Kampanyalar Kampanyalar Çağrı Merkezi kampanyalar cagri kampanya','cagri-kampanya-liste'),
('cagri-kampanya-kisi','/cagri-kampanya-kisi','Kampanya Kişileri','Çağrı Merkezi › Kampanya Kişileri','Çağrı Merkezi','Kampanya Kişileri','cagri.kampanya',2,'cagri','',1,'Kampanya Kişileri Kampanya Kişileri Çağrı Merkezi kampanya kisileri cagri kampanya kisi','cagri-kampanya-kisi-liste'),
('cagri-supervizor','/cagri-supervizor','Süpervizör Panosu','Çağrı Merkezi › Süpervizör Panosu','Çağrı Merkezi','Süpervizör Panosu','cagri.supervizor',2,'cagri','',0,'Süpervizör Panosu Süpervizör Panosu Çağrı Merkezi supervizor panosu cagri supervizor',''),
('cagri-kalite','/cagri-kalite','Kalite Değerlendirmeleri','Çağrı Merkezi › Kalite','Çağrı Merkezi','Kalite Değerlendirmeleri','cagri.kalite',2,'cagri','/cagri-kalite',0,'Kalite Değerlendirmeleri Kalite Değerlendirmeleri Çağrı Merkezi kalite degerlendirmeleri cagri kalite','cagri-kalite-liste'),
('cagri-konu','/cagri-konu','Konu Ağacı','Çağrı Merkezi › Ayarlar › Konu Ağacı','Çağrı Merkezi','Konu ağacı & SLA','cagri.ayar',2,'cagri','/cagri-konu',0,'Konu Ağacı Konu ağacı & SLA Çağrı Merkezi konu agaci cagri konu','cagri-konu-liste'),
('cagri-kuyruk','/cagri-kuyruk','Kuyruklar','Çağrı Merkezi › Ayarlar › Kuyruklar','Çağrı Merkezi','Kuyruklar & SLA','cagri.ayar',2,'cagri','/cagri-kuyruk',0,'Kuyruklar Kuyruklar & SLA Çağrı Merkezi kuyruklar cagri kuyruk','cagri-kuyruk-liste'),
('cagri-agent','/cagri-agent','Agentlar','Çağrı Merkezi › Ayarlar › Agentlar','Çağrı Merkezi','Agentlar (dahili)','cagri.ayar',2,'cagri','/cagri-agent',0,'Agentlar Agentlar (dahili) Çağrı Merkezi agentlar cagri agent','cagri-agent-liste'),
('cagri-santral','/cagri-santral','Santral · IVR · Kanallar','Çağrı Merkezi › Ayarlar › Santral','Çağrı Merkezi','Santral · IVR · Kanallar','cagri.ayar',2,'cagri','',0,'Santral · IVR · Kanallar Santral · IVR · Kanallar Çağrı Merkezi santral · ivr · kanallar cagri santral',''),
('steril-pano','/steril-pano','Sterilizasyon Panosu','Diş › Sterilizasyon › Pano','Diş','Sterilizasyon Panosu','steril.pano',2,'steril','',0,'Sterilizasyon Panosu Sterilizasyon Panosu Diş sterilizasyon panosu steril pano',''),
('steril-dongu','/steril-dongu','Döngüler','Diş › Sterilizasyon › Döngüler','Diş','Döngüler','steril.dongu',2,'steril','/steril-dongu',0,'Döngüler Döngüler Diş donguler steril dongu','steril-dongu-liste'),
('steril-dongu','/steril-dongu-kart','Döngü (kart)','Diş › Sterilizasyon › Döngü','Diş','Döngü (kart)','steril.dongu',2,'steril','/steril-dongu-kart',1,'Döngü (kart) Döngü (kart) Diş dongu (kart) steril dongu','steril-dongu-liste'),
('steril-paket','/steril-paket','Steril Depo · Paketler','Diş › Sterilizasyon › Steril Depo','Diş','Steril Depo · Paketler','steril.birim',2,'steril','',0,'Steril Depo · Paketler Steril Depo · Paketler Diş steril depo · paketler steril paket','steril-paket-liste'),
('steril-birim','/steril-birim','Setler · Döner Aletler','Diş › Sterilizasyon › Setler · Döner Aletler','Diş','Setler · Döner Aletler','steril.birim',2,'steril','/steril-birim',0,'Setler · Döner Aletler Setler · Döner Aletler Diş setler · doner aletler steril birim','steril-birim-liste'),
('steril-kullanim','/steril-kullanim','Kullanım Kayıtları','Diş › Sterilizasyon › Kullanım Kayıtları','Diş','Kullanım Kayıtları','steril.izleme',2,'steril','',0,'Kullanım Kayıtları Kullanım Kayıtları Diş kullanim kayitlari steril kullanim','steril-kullanim-liste'),
('steril-izleme','/steril-izleme','İzlenebilirlik · Geri Çağırma','Diş › Sterilizasyon › İzlenebilirlik','Diş','İzlenebilirlik · Kayıt Defteri','steril.izleme',2,'steril','',0,'İzlenebilirlik · Geri Çağırma İzlenebilirlik · Kayıt Defteri Diş izlenebilirlik · geri cagirma steril izleme',''),
('steril-geri-cagirma','/steril-geri-cagirma','Geri Çağırmalar','Diş › Sterilizasyon › Geri Çağırmalar','Diş','Geri Çağırmalar','steril.izleme',2,'steril','',1,'Geri Çağırmalar Geri Çağırmalar Diş geri cagirmalar steril geri cagirma','steril-geri-cagirma-liste'),
('steril-set','/steril-set','Set Tanımları','Diş › Sterilizasyon › Ayarlar › Set Tanımları','Diş','Set tanımları (içerik)','steril.birim',2,'steril','/steril-set',0,'Set Tanımları Set tanımları (içerik) Diş set tanimlari steril set','steril-set-liste'),
('steril-cihaz','/steril-cihaz','Cihazlar','Diş › Sterilizasyon › Ayarlar › Cihazlar','Diş','Cihazlar','steril.ayar',2,'steril','/steril-cihaz',0,'Cihazlar Cihazlar Diş cihazlar steril cihaz','steril-cihaz-liste'),
('steril-program','/steril-program','Programlar','Diş › Sterilizasyon › Ayarlar › Programlar','Diş','Programlar','steril.ayar',2,'steril','/steril-program',0,'Programlar Programlar Diş programlar steril program','steril-program-liste'),
('steril-bakim','/steril-bakim','Bakım · Validasyon','Diş › Sterilizasyon › Ayarlar › Bakım','Diş','Bakım · Validasyon','steril.ayar',2,'steril','/steril-bakim',0,'Bakım · Validasyon Bakım · Validasyon Diş bakim · validasyon steril bakim','steril-bakim-liste'),
('steril-ayar','/steril-ayar','Test Takvimi · Kurallar','Diş › Sterilizasyon › Ayarlar › Test Takvimi · Kurallar','Diş','Test takvimi · Kurallar','steril.ayar',2,'steril','',0,'Test Takvimi · Kurallar Test takvimi · Kurallar Diş test takvimi · kurallar steril ayar',''),
('medula-kabul','/medula-kabul','Medula Hasta Kabul / Provizyon','Medula › Hasta Kabul','Medula','Hasta Kabul / Provizyon','medula.provizyon',2,'','',0,'Medula Hasta Kabul / Provizyon Hasta Kabul / Provizyon Medula medula hasta kabul / provizyon medula kabul',''),
('medula-takip','/medula-takip','Medula Takipleri','Medula › Takipler','Medula','Takipler','medula',2,'','',0,'Medula Takipleri Takipler Medula medula takipleri medula takip','medula-takip-liste'),
('medula-islem','/medula-islem','Medula Hizmet Kayıtları','Medula › Hizmet Kayıtları','Medula','Hizmet Kayıtları','medula.hizmet',2,'','',0,'Medula Hizmet Kayıtları Hizmet Kayıtları Medula medula hizmet kayitlari medula islem','medula-islem-liste'),
('recete','/medula-recete','e-Reçete (Medula)','Medula › e-Reçete','Medula','e-Reçete','medula.recete',2,'','/medula-recete',0,'e-Reçete (Medula) e-Reçete Medula e-recete (medula) recete','medula-recete-liste'),
('medula-rapor','/medula-rapor','e-Rapor (Medula)','Medula › e-Rapor','Medula','e-Rapor','medula.recete',2,'','/medula-rapor',0,'e-Rapor (Medula) e-Rapor Medula e-rapor (medula) medula rapor','medula-rapor-liste'),
('medula-fatura-donem','/medula-fatura-donem','Medula Fatura & Dönem','Medula › Fatura & Dönem','Medula','Fatura & Dönem','medula.fatura',2,'','',0,'Medula Fatura & Dönem Fatura & Dönem Medula medula fatura & donem medula fatura donem',''),
('medula-fatura','/medula-fatura','Medula Faturaları','Medula › Faturalar','Medula','Faturalar','medula.fatura',2,'','/medula-fatura',0,'Medula Faturaları Faturalar Medula medula faturalari medula fatura','medula-fatura-liste'),
('medula-donem','/medula-donem','Medula Dönemleri','Medula › Dönemler','Medula','Dönemler','medula.fatura',2,'','/medula-donem',0,'Medula Dönemleri Dönemler Medula medula donemleri medula donem','medula-donem-liste'),
('medula-kesinti','/medula-kesinti','Medula Kesintileri','Medula › Kesinti / İtiraz','Medula','Kesinti / İtiraz','medula.fatura',2,'','/medula-kesinti',0,'Medula Kesintileri Kesinti / İtiraz Medula medula kesintileri medula kesinti','medula-kesinti-liste'),
('medula-kuyruk-ayar','/medula-kuyruk-ayar','Medula Gönderim Kuyruğu & Ayarlar','Medula › Gönderim Kuyruğu','Medula','Gönderim Kuyruğu & Ayarlar','medula',2,'','',0,'Medula Gönderim Kuyruğu & Ayarlar Gönderim Kuyruğu & Ayarlar Medula medula gonderim kuyrugu & ayarlar medula kuyruk ayar',''),
('medula-kuyruk','/medula-kuyruk','Medula Çağrı Günlüğü','Medula › Çağrı Günlüğü','Medula','Çağrı Günlüğü','medula',2,'','',0,'Medula Çağrı Günlüğü Çağrı Günlüğü Medula medula cagri gunlugu medula kuyruk','medula-kuyruk-liste'),
('klinikGosterge','/klinik-gosterge','Klinik Kalite Göstergeleri','Yönetim › Kalite › Klinik Kalite Göstergeleri','Yönetim','Klinik Kalite Göstergeleri','klinik_kalite.olgu',2,'','/klinik-gosterge',0,'Klinik Kalite Göstergeleri Klinik Kalite Göstergeleri Yönetim klinik kalite gostergeleri klinikgosterge','klinik-gosterge-liste'),
('klinikGostergeDonem','/klinik-gosterge-donem','Klinik Kalite Dönem Sonuçları','Yönetim › Kalite › Klinik Kalite Dönem Sonuçları','Yönetim','Klinik Kalite Dönem Sonuçları','klinik_kalite.donem',2,'','/klinik-gosterge-donem',0,'Klinik Kalite Dönem Sonuçları Klinik Kalite Dönem Sonuçları Yönetim klinik kalite donem sonuclari klinikgostergedonem','klinik-kalite-donem-liste'),
('klinikGostergeKod','/klinik-gosterge-kod','Klinik Kalite Kod Havuzu','Yönetim › Kalite › Klinik Kalite Kod Havuzu','Yönetim','Klinik Kalite Kod Havuzu','klinik_kalite',2,'','',0,'Klinik Kalite Kod Havuzu Klinik Kalite Kod Havuzu Yönetim klinik kalite kod havuzu klinikgostergekod',''),
('ameliyat','/ameliyat','Ameliyat Planı','Ameliyathane › Ameliyat Planı','Ameliyathane','Ameliyat Planı','ameliyathane.plan',2,'ameliyathane','/ameliyat',0,'Ameliyat Planı Ameliyat Planı Ameliyathane ameliyat plani ameliyat','ameliyat-liste'),
('ameliyat-cizelge','/ameliyat-cizelge','Masa Çizelgesi','Ameliyathane › Masa Çizelgesi','Ameliyathane','Masa Çizelgesi','ameliyathane.plan',2,'ameliyathane','',0,'Masa Çizelgesi Masa Çizelgesi Ameliyathane masa cizelgesi ameliyat cizelge',''),
('ameliyatTalep','/ameliyat-talep','Bekleyen Ameliyat Talepleri','Ameliyathane › Bekleyen Talepler','Ameliyathane','Bekleyen Talepler','ameliyathane.talep',2,'ameliyathane','/ameliyat-talep',0,'Bekleyen Ameliyat Talepleri Bekleyen Talepler Ameliyathane bekleyen ameliyat talepleri ameliyattalep','ameliyat-talep-liste'),
('ameliyatSalon','/ameliyat-salon','Ameliyathane Salonları','Ameliyathane › Salonlar','Ameliyathane','Salonlar','ameliyathane.salon',2,'ameliyathane','/ameliyat-salon',0,'Ameliyathane Salonları Salonlar Ameliyathane ameliyathane salonlari ameliyatsalon','ameliyat-salon-liste'),
('acilBasvuru','/acil-triyaj','Acil — Triyaj ve Kabul','Acil › Triyaj ve Kabul','Acil','Triyaj ve Kabul','acil.triyaj',2,'acil','/acil-basvuru',0,'Acil — Triyaj ve Kabul Triyaj ve Kabul Acil acil — triyaj ve kabul acilbasvuru','acil-triyaj-liste'),
('acilBasvuru','/acil-takip','Acil — Takip Panosu','Acil › Takip Panosu','Acil','Takip Panosu','acil.pano',2,'acil','/acil-basvuru',0,'Acil — Takip Panosu Takip Panosu Acil acil — takip panosu acilbasvuru','acil-takip-liste'),
('acilCagri','/acil-cagri','Acil — Çağrılar','Acil › Çağrılar','Acil','Çağrılar','acil.pano',2,'acil','',0,'Acil — Çağrılar Çağrılar Acil acil — cagrilar acilcagri','acil-cagri-liste'),
('acilYatak','/acil-yatak','Acil Yatakları','Acil › Yataklar','Acil','Yataklar','acil.yatak',2,'acil','/acil-yatak',0,'Acil Yatakları Yataklar Acil acil yataklari acilyatak','acil-yatak-liste'),
('belge','/fatura','Faturalar','Kurumlar & Sigorta › Faturalar','Kurumlar & Sigorta','Faturalar','belge',2,'','',0,'Faturalar Faturalar Kurumlar & Sigorta faturalar belge','belge-liste'),
('eczaneKontrol','/eczane-kontrol','Eczacı Kontrolü','Eczane › Eczacı Kontrolü','Eczane','Eczacı Kontrolü','eczane.order',2,'eczane','/eczane-kontrol',0,'Eczacı Kontrolü Eczacı Kontrolü Eczane eczaci kontrolu eczanekontrol','eczane-kontrol-liste'),
('eczaneDoz','/eczane-doz','Ünite Doz','Eczane › Ünite Doz','Eczane','Ünite Doz','eczane.doz',2,'eczane','/eczane-doz',0,'Ünite Doz Ünite Doz Eczane unite doz eczanedoz','eczane-doz-liste'),
('eczaneHazirlama','/eczane-hazirlama','Hazırlama (Kemoterapi / TPN)','Eczane › Hazırlama','Eczane','Hazırlama','eczane.hazirlama',2,'eczane','/eczane-hazirlama',0,'Hazırlama (Kemoterapi / TPN) Hazırlama Eczane hazirlama (kemoterapi / tpn) eczanehazirlama','eczane-hazirlama-liste'),
('eczaneIade','/eczane-iade','Servis İadeleri','Eczane › İadeler','Eczane','İadeler','eczane.iade',2,'eczane','/eczane-iade',0,'Servis İadeleri İadeler Eczane servis iadeleri eczaneiade','eczane-iade-liste'),
('eczaneImha','/eczane-imha','İmha Tutanakları','Eczane › İmha','Eczane','İmha','eczane.imha',2,'eczane','/eczane-imha',0,'İmha Tutanakları İmha Eczane imha tutanaklari eczaneimha','eczane-imha-liste'),
('kontrolluDefter','/kontrollu-defter','Kontrollü İlaç Defteri','Eczane › Kontrollü Defter','Eczane','Kontrollü Defter','eczane.kontrollu',2,'eczane','',0,'Kontrollü İlaç Defteri Kontrollü Defter Eczane kontrollu ilac defteri kontrolludefter','kontrollu-defter-liste'),
('eczaneMiad','/eczane-miad','Miad & Tüketim','Eczane › Miad & Tüketim','Eczane','Miad & Tüketim','stok',2,'eczane','',0,'Miad & Tüketim Miad & Tüketim Eczane miad & tuketim eczanemiad','eczane-miad-liste'),
('demirbasCihaz','/demirbas-cihaz','Cihaz Envanteri','Demirbaş › Cihaz Envanteri','Demirbaş','Cihaz Envanteri','demirbas.envanter',2,'','/demirbas',0,'Cihaz Envanteri Cihaz Envanteri Demirbaş cihaz envanteri demirbascihaz','demirbas-cihaz-liste'),
('demirbasKalibrasyon','/demirbas-kalibrasyon','Kalibrasyon & Güvenlik Testi','Demirbaş › Kalibrasyon','Demirbaş','Kalibrasyon','demirbas.kalibrasyon',2,'','/demirbas-kalibrasyon',0,'Kalibrasyon & Güvenlik Testi Kalibrasyon Demirbaş kalibrasyon & guvenlik testi demirbaskalibrasyon','demirbas-kalibrasyon-liste'),
('demirbasIsEmri','/demirbas-is-emri','İş Emirleri (Bakım & Arıza)','Demirbaş › İş Emirleri','Demirbaş','İş Emirleri','demirbas.isemri',2,'','/demirbas-is-emri',0,'İş Emirleri (Bakım & Arıza) İş Emirleri Demirbaş is emirleri (bakim & ariza) demirbasisemri','demirbas-is-emri-liste'),
('satinalmaTalep','/satinalma-talep','Satınalma Talepleri','Satınalma › Talepler','Satınalma','Talepler','satinalma.talep',0,'satinalma','/satinalma-talep',0,'Satınalma Talepleri Talepler Satınalma satinalma talepleri satinalmatalep','satinalma-talep-liste'),
('satinalmaTeklif','/satinalma-teklif','Teklif / İhale','Satınalma › Teklifler','Satınalma','Teklifler','satinalma.teklif',0,'satinalma','/satinalma-teklif',0,'Teklif / İhale Teklifler Satınalma teklif / ihale satinalmateklif','satinalma-teklif-liste'),
('satinalmaSiparis','/satinalma-siparis','Sipariş Takibi','Satınalma › Siparişler','Satınalma','Siparişler','satinalma.siparis',0,'satinalma','',0,'Sipariş Takibi Siparişler Satınalma siparis takibi satinalmasiparis','satinalma-siparis-liste'),
('satinalmaKabul','/satinalma-kabul','Mal Kabul (muayene tutanağı)','Satınalma › Mal Kabul','Satınalma','Mal Kabul','satinalma.kabul',0,'satinalma','/satinalma-kabul',0,'Mal Kabul (muayene tutanağı) Mal Kabul Satınalma mal kabul (muayene tutanagi) satinalmakabul','satinalma-kabul-liste'),
('satinalmaFatura','/satinalma-fatura','Fatura Kontrolü (üçlü eşleştirme)','Satınalma › Fatura Kontrolü','Satınalma','Fatura Kontrolü','satinalma.fatura',0,'satinalma','',0,'Fatura Kontrolü (üçlü eşleştirme) Fatura Kontrolü Satınalma fatura kontrolu (uclu eslestirme) satinalmafatura','satinalma-fatura-liste'),
('satinalmaTedarikci','/satinalma-tedarikci','Tedarikçi Performansı','Satınalma › Tedarikçiler','Satınalma','Tedarikçiler','satinalma.tedarikci',0,'satinalma','/cari',0,'Tedarikçi Performansı Tedarikçiler Satınalma tedarikci performansi satinalmatedarikci','satinalma-tedarikci-liste'),
('satinalmaButce','/satinalma-butce','Bütçe Durumu','Satınalma › Bütçe','Satınalma','Bütçe','satinalma.butce',0,'satinalma','/satinalma-butce',0,'Bütçe Durumu Bütçe Satınalma butce durumu satinalmabutce','satinalma-butce-liste'),
('onayKutusu','/onay-kutusu','Onayımdakiler','Yönetim › Onaylar','Yönetim','Onayımdakiler','panel',0,'','',0,'Onayımdakiler Onayımdakiler Yönetim onayimdakiler onaykutusu','onay-kutusu-liste'),
('onayAkis','/onay-akis','Onay Akışları','Yönetim › Onay Akışları','Yönetim','Onay Akışları','kullanici',0,'','/onay-akis',0,'Onay Akışları Onay Akışları Yönetim onay akislari onayakis','onay-akis-liste'),
('onayVekalet','/onay-vekalet','Onay Vekâletleri','Yönetim › Onay Vekâleti','Yönetim','Onay Vekâleti','kullanici',0,'','/onay-vekalet',0,'Onay Vekâletleri Onay Vekâleti Yönetim onay vekâletleri onayvekalet','onay-vekalet-liste'),
('personelIzin','/personel-izin','İzin Talepleri','İK & Prim › İzinler','İK & Prim','İzinler','ik.izin',0,'ik','/personel-izin',0,'İzin Talepleri İzinler İK & Prim izin talepleri personelizin','personel-izin-liste'),
('izinBakiye','/izin-bakiye','İzin Bakiyeleri','İK & Prim › İzin Bakiyesi','İK & Prim','İzin Bakiyesi','ik.izin',0,'ik','',0,'İzin Bakiyeleri İzin Bakiyesi İK & Prim izin bakiyeleri izinbakiye','izin-bakiye-liste'),
('personelAvans','/personel-avans','Personel Avansları','İK & Prim › Avanslar','İK & Prim','Avanslar','ik.avans',0,'ik','/personel-avans',0,'Personel Avansları Avanslar İK & Prim personel avanslari personelavans','personel-avans-liste'),
('personelMasraf','/personel-masraf','Masraf Beyanları','İK & Prim › Masraf Beyanları','İK & Prim','Masraf Beyanları','ik.masraf',0,'ik','/personel-masraf',0,'Masraf Beyanları Masraf Beyanları İK & Prim masraf beyanlari personelmasraf','personel-masraf-liste'),
('personelBelgeTalep','/personel-belge-talep','Belge Talepleri','İK & Prim › Belge Talepleri','İK & Prim','Belge Talepleri','ik.belge_talep',0,'ik','/personel-belge-talep',0,'Belge Talepleri Belge Talepleri İK & Prim belge talepleri personelbelgetalep','personel-belge-talep-liste'),
('resmiTatil','/resmi-tatil','Resmî Tatiller','İK & Prim › Resmî Tatiller','İK & Prim','Resmî Tatiller','ik.tatil',0,'ik','/resmi-tatil',0,'Resmî Tatiller Resmî Tatiller İK & Prim resmî tatiller resmitatil','resmi-tatil-liste'),
('personelIzinHak','/personel-izin-hak','İzin Hakedişleri','İK & Prim › İzin Hakedişi','İK & Prim','İzin Hakedişi','ik.izin_hak',0,'ik','/personel-izin-hak',1,'İzin Hakedişleri İzin Hakedişi İK & Prim izin hakedisleri personelizinhak','personel-izin-hak-liste'),
('servis-cagri','/servis-cagri','Servis Çağrıları','Teknik Servis › Çağrılar','Teknik Servis','Çağrılar','servis',0,'servis','/servis-cagri',0,'Servis Çağrıları Çağrılar Teknik Servis servis cagrilari servis cagri','servis-cagri-liste'),
('servis-is-emri','/servis-is-emri','Servis İş Emirleri','Teknik Servis › İş Emirleri','Teknik Servis','İş Emirleri','servis',0,'servis','/demirbas-is-emri',0,'Servis İş Emirleri İş Emirleri Teknik Servis servis is emirleri servis is emri','servis-is-emri-liste'),
('servis-cizelge','/servis-cizelge','Teknisyen Çizelgesi','Teknik Servis › Çizelge','Teknik Servis','Çizelge','servis',0,'servis','',0,'Teknisyen Çizelgesi Çizelge Teknik Servis teknisyen cizelgesi servis cizelge',''),
('servis-ziyaret','/servis-ziyaret','Ziyaretler','Teknik Servis › Ziyaretler','Teknik Servis','Ziyaretler','servis',0,'servis','/servis-ziyaret',0,'Ziyaretler Ziyaretler Teknik Servis ziyaretler servis ziyaret','servis-ziyaret-liste'),
('servis-emanet','/servis-emanet','Emanet Cihazlar','Teknik Servis › Emanet Cihazlar','Teknik Servis','Emanet Cihazlar','servis',0,'servis','/servis-emanet',0,'Emanet Cihazlar Emanet Cihazlar Teknik Servis emanet cihazlar servis emanet','servis-emanet-liste'),
('taraf-cihaz','/taraf-cihaz','Müşteri Cihaz Parkı','Teknik Servis › Cihaz Parkı','Teknik Servis','Cihaz Parkı','servis.cihaz',0,'servis','/taraf-cihaz',0,'Müşteri Cihaz Parkı Cihaz Parkı Teknik Servis musteri cihaz parki taraf cihaz','taraf-cihaz-liste'),
('servis-sozlesme','/servis-sozlesme','Servis Sözleşmeleri','Teknik Servis › Sözleşmeler','Teknik Servis','Sözleşmeler','servis.sozlesme',0,'servis','/servis-sozlesme',0,'Servis Sözleşmeleri Sözleşmeler Teknik Servis servis sozlesmeleri servis sozlesme','servis-sozlesme-liste'),
('kullanici','/kullanici','Kullanıcılar','Yönetim › Güvenlik › Kullanıcılar','Yönetim','Kullanıcılar','kullanici',0,'','/kullanici',0,'Kullanıcılar Kullanıcılar Yönetim kullanicilar kullanici','kullanici-liste'),
('giris-log','/giris-log','Giriş Kayıtları','Yönetim › Giriş Kayıtları','Yönetim','Giriş Kayıtları','islem_log',0,'','',0,'Giriş Kayıtları Giriş Kayıtları Yönetim giris kayitlari giris log',''),
('dokumler','/dokumler','Dökümler','Yönetim › Dökümler','Yönetim','Dökümler','dokum',0,'','',0,'Dökümler Dökümler Yönetim dokumler dokumler',''),
('kurum-profili','/kurum-profili','Kurum Profili','Yonetim › Kurum Profili','Yönetim','Kurum Profili','sube',0,'','',0,'Kurum Profili Kurum Profili Yönetim kurum profili kurum profili',''),
('iceri-alma','/iceri-alma','Excel''den İçeri Alma','Yonetim › Veri Aktarımı › İçeri Alma','Yönetim','Excel''den İçeri Alma','ayar',0,'','',0,'Excel''den İçeri Alma Excel''den İçeri Alma Yönetim excel''den iceri alma iceri alma',''),
('personel-hareket','/personel-hareket','Kadro Hareketleri','İK › Kadro Hareketleri','İK & Prim','Kadro Hareketleri','ik.kadro',0,'ik','/personel-hareket',0,'Kadro Hareketleri Kadro Hareketleri İK & Prim kadro hareketleri personel hareket','personel-hareket-liste'),
('kurum-belge','/kurum-belge','Faturalarım','Portal › Faturalarım','','Faturalarım','portal.mali',0,'','',0,'Faturalarım Faturalarım faturalarim kurum belge',''),
('kurum-ekstre','/kurum-ekstre','Cari Ekstrem','Portal › Cari Ekstre','','Cari Ekstrem','portal.mali',0,'','',0,'Cari Ekstrem Cari Ekstrem cari ekstrem kurum ekstre','')
on conflict (rota) do update set
  kaynak = excluded.kaynak, baslik = excluded.baslik, yol = excluded.yol,
  menu_grup = excluded.menu_grup, menu_ad = excluded.menu_ad,
  yetki_kodu = excluded.yetki_kodu, urun_modu = excluded.urun_modu,
  modul = excluded.modul, kart_yolu = excluded.kart_yolu,
  menu_gizli = excluded.menu_gizli, anahtar = excluded.anahtar,
  aksiyon_ekrani = case when excluded.aksiyon_ekrani <> '' then excluded.aksiyon_ekrani
                        else public.ai_rehber_ekran.aksiyon_ekrani end;

-- Menü yolu değişen ekranlar (istemci menüsü taşındı, katalog eski yolu anlatıyordu).
update public.ai_rehber_ekran e
   set yol = v.yol, aksiyon_ekrani = v.aksiyon, anahtar = v.anahtar
  from (values
  ('/lab-genetik-panel','Laboratuvar › Genetik › Genetik Panelleri','lab-genetik-panel-liste','Genetik Panelleri Genetik Panelleri Laboratuvar genetik panelleri lab genetik panel'),
  ('/kurum','Cari › Anlaşmalı Kurumlar','cari-liste','Anlaşmalı Kurumlar Anlaşmalı Kurumlar Kurumlar & Sigorta anlasmali kurumlar kurum'),
  ('/kampanya','Stok & Hizmet › Kampanyalar','cari-liste','Kampanyalar Kampanyalar Kurumlar & Sigorta kampanyalar kampanya'),
  ('/bildirim-sablon','Yonetim › Bildirim Şablonları','bildirim-sablon-liste','Bildirim Şablonları Bildirim Şablonları Yönetim bildirim sablonlari bildirim sablon'),
  ('/rol','IK › Roller ve Yetkiler','rol-liste','Roller Roller Yönetim roller rol'),
  ('/sube','Yönetim › Firma / Şubeler','','Firma / Şubeler Firma / Şubeler Yönetim firma / subeler sube')
  ) as v(rota, yol, aksiyon, anahtar)
 where e.rota = v.rota;

-- Hasta ekranının yetkisi 'personel' kalmıştı; istemci 'hasta' yetkisiyle açar.
update public.ai_rehber_ekran set yetki_kodu = 'hasta'
 where rota = '/hasta' and exists (select 1 from public.yetki where kod = 'hasta');

-- ------------------------------------------------------- 2) sohbet şube
alter table public.ai_sohbet add column if not exists sube_id integer;
create index if not exists ix_ai_sohbet_kullanici_sube
    on public.ai_sohbet (kullanici_id, sube_id, durum, son_tarih desc);

-- --------------------------------------------------- 3) günlük alanları
alter table public.ai_rehber_log
    add column if not exists ekran_kaynak varchar(60)  not null default '',
    add column if not exists sekme        varchar(60)  not null default '',
    add column if not exists dil          varchar(5)   not null default 'tr',
    add column if not exists kaynaklar    varchar(400) not null default '',
    add column if not exists pii_maske    smallint     not null default 0;

-- Eski soruları geriye dönük maskele: 11 haneli sayı = kimlik no, 7+ hane = numara,
--   e-posta, +90/0 ile başlayan telefon. Geri alınamaz; günlük analizinde soru
--   metninin anlamı sayılara bağlı değil.
update public.ai_rehber_log
   set soru = regexp_replace(
                regexp_replace(
                  regexp_replace(
                    regexp_replace(soru, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[e-posta]', 'g'),
                    '(\+\s?90|\m0)\s?\(?\d{3}\)?\s?\d{3}\s?\d{2}\s?\d{2}\M', '[telefon]', 'g'),
                  '\m\d{11}\M', '[kimlik-no]', 'g'),
                '\m\d{7,}\M', '[numara]', 'g'),
       pii_maske = 1
 where soru ~ '\d{7,}' or soru ~ '@';

-- ------------------------------------------------------------ 4) saklama
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, 'sayi', 'firma', v.aciklama
  from (values
    ('ai.log_saklama_gun',    '90',  'AI rehber soru günlüğü (ai_rehber_log) kaç gün saklanır; 0 = silinmez.'),
    ('ai.sohbet_saklama_gun', '365', 'AI sohbetleri ve mesajları kaç gün saklanır (son mesajdan itibaren); 0 = silinmez.'),
    ('ai.saglayici_veri_saklama', '0', 'Bilgi: dil modeli sağlayıcısının istekleri saklayıp saklamadığı (sözleşme). 0 = saklamaz. Kod bunu uygulamaz; yalnız raporlar.')
  ) as v(anahtar, deger, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

create or replace function public.fn_ai_temizle()
returns text
language plpgsql
as $$
declare
    v_log_gun    integer := coalesce((select nullif(deger, '')::integer from public.referans where anahtar = 'ai.log_saklama_gun'), 90);
    v_sohbet_gun integer := coalesce((select nullif(deger, '')::integer from public.referans where anahtar = 'ai.sohbet_saklama_gun'), 365);
    v_log        integer := 0;
    v_sohbet     integer := 0;
    v_mesaj      integer := 0;
begin
    if v_log_gun > 0 then
        -- Kontör hareketi günlüğe bağlı: bağı koparıp günlüğü sil (hareket kalır, muhasebe bozulmaz).
        update public.ai_kontor_hareket set rehber_log_id = null
         where rehber_log_id in (select id from public.ai_rehber_log where tarih < now() - make_interval(days => v_log_gun));
        delete from public.ai_rehber_log where tarih < now() - make_interval(days => v_log_gun);
        get diagnostics v_log = row_count;
    end if;
    if v_sohbet_gun > 0 then
        delete from public.ai_arac_log where sohbet_id in
            (select id from public.ai_sohbet where son_tarih < now() - make_interval(days => v_sohbet_gun));
        delete from public.ai_taslak where sohbet_id in
            (select id from public.ai_sohbet where son_tarih < now() - make_interval(days => v_sohbet_gun));
        delete from public.ai_mesaj where sohbet_id in
            (select id from public.ai_sohbet where son_tarih < now() - make_interval(days => v_sohbet_gun));
        get diagnostics v_mesaj = row_count;
        delete from public.ai_sohbet where son_tarih < now() - make_interval(days => v_sohbet_gun);
        get diagnostics v_sohbet = row_count;
    end if;
    return format('%s günlük satırı, %s sohbet (%s mesaj) silindi.', v_log, v_sohbet, v_mesaj);
end $$;

insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aktif, aciklama)
select 'ai.temizlik', 'AI günlük ve sohbet temizliği', 2, 1, 3, 30, 1,
       'ai_rehber_log ve eski sohbetleri referans ai.log_saklama_gun / ai.sohbet_saklama_gun süresine göre siler (fn_ai_temizle).'
 where not exists (select 1 from public.zamanli_is where kod = 'ai.temizlik');

-- --------------------------------------------------------------- 5) yetki
insert into public.yetki (kod, ad, grup, sira, urun_modu)
select 'ai.yardim', 'AI yardım dizini (yeniden kurma)', 'yonetim', 76, 0
 where not exists (select 1 from public.yetki where kod = 'ai.yardim');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1
  from public.yetki y
 where y.kod = 'ai.yardim'
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = 1 and ry.yetki_id = y.id);

do $$
begin
    raise notice '871 tamam: ai_rehber_ekran % satır, ai_sohbet.sube_id, ai_rehber_log +5 kolon, fn_ai_temizle, zamanlı iş ai.temizlik, yetki ai.yardim',
        (select count(*) from public.ai_rehber_ekran where durum = 0);
end $$;
