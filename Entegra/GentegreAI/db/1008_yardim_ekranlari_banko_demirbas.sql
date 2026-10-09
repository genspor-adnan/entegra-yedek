-- =============================================================================
--  1008 - YARDIM ASİSTANI EKRAN KATALOĞU: BANKO VE SABİT VARLIK EKRANLARI
--
--  Kullanıcı (10.10.2026): "yardım dosyalarını da oluştur" (görüntüleme
--  merkezi). Yeni yardım belgeleri (dokuman/yardim/banko-oturum-gun-sonu ...)
--  bu ekranlara bağlı; ekran `ai_rehber_ekran`'da yoksa asistan "ekranı
--  tanımadım" der (871 kuralı). Eksik altı ekran eklenir. Satır varsa
--  dokunulmaz (kurum açıklamayı değiştirmiş olabilir).
-- =============================================================================

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.menu_grup, v.menu_ad, v.yetki_kodu, v.urun_modu,
       v.anahtar, v.aciklama, v.aksiyon_ekrani
  from (values
    ('banko-oturum', '/banko-oturum', 'Banko Oturumu', 'Kayıt Kabul › Banko Oturumu',
     'Kayıt Kabul', 'Banko Oturumu', 'banko_oturum', 2,
     'banko oturum vardiya gün sonu kasa teslimi tahsilat pos sayım',
     'Banko görevlisinin vardiyası: oturum açma, tahsilat, POS gün sonu, sayım ve kasa teslimi.', ''),
    ('bankoOturum', '/banko-oturumlar', 'Banko Oturumları', 'Kayıt Kabul › Banko Oturumları',
     'Kayıt Kabul', 'Banko Oturumları', 'banko_oturum', 2,
     'banko oturumları vardiya geçmişi fark yeni oturum aç',
     'Vardiya kayıtları; buradan yeni oturum açılır, açık oturuma devam edilir.', 'banko-oturum-liste'),
    ('banko-onay', '/banko-onay', 'Banko Onay Kuyruğu', 'Kayıt Kabul › Banko Onayları',
     'Kayıt Kabul', 'Banko Onayları', 'banko_onay', 2,
     'banko onay kuyruğu açılış onayı gün sonu onayı teslim alma',
     'Sorumlunun onay kuyruğu: oturum açılış ve gün sonu teslim onayları.', ''),
    ('banko', '/banko', 'Bankolar', 'Finans › Bankolar',
     'Finans', 'Bankolar', 'banko', 0,
     'banko tanımı kasa pos devir hedefi',
     'Banko tanımları: kasa hesabı, POS cihazları, devir hedefi ve onay kuralları.', 'banko-liste'),
    ('demirbas-zimmet', '/demirbas-zimmet', 'Zimmet / Hareketler', 'Sabit Varlıklar › Zimmet / Hareketler',
     'Sabit Varlıklar', 'Zimmet / Hareketler', 'demirbas.zimmet', 0,
     'zimmet iade devir yer değiştir tutanak demirbaş hareket',
     'Demirbaş zimmet, iade, devir ve yer değişikliği; zimmet tutanağı.', ''),
    ('demirbas-ayarlar', '/demirbas-ayarlar', 'Demirbaş Ayarları', 'Sabit Varlıklar › Ayarlar › Demirbaş',
     'Sabit Varlıklar', 'Demirbaş', 'demirbas.ayar', 0,
     'demirbaş ayarları iade lokasyonu tutanak metni amortisman kategori lokasyon',
     'İade lokasyonu, tutanak metni, amortisman varsayılanları ve kod listeleri.', '')
  ) as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);
