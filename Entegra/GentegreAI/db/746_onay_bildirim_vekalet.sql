-- =====================================================================
--  746_onay_bildirim_vekalet.sql
--  Onay omurgasının (738-740) bildirim tetiği ve vekâlet ekranı.
-- =====================================================================

-- ======================================= 1) ŞABLON DEĞİŞKENLERİ {{...}}
--
--  739'daki şablonlar tek süslü parantez kullanıyordu ("{kayitNo}"). Şablon
--  doldurucusu (`BildirimSablonu.Doldur`) ÇİFT parantez arar; tek parantezli
--  metinde hiçbir değişken dolmaz ve mesaj kullanıcıya "Onayınızda:
--  {kayitNo}" diye giderdi. Yanlış giden bir bildirim, gitmeyenden daha
--  kötüdür: kurum sistemin çalıştığını sanır.
update public.bildirim_sablon set
       konu  = 'Onayınızda: {{kayitNo}}',
       govde = 'Sayın {{alici}},' || chr(10) || chr(10) ||
               '{{akisAd}} için onayınız bekleniyor.' || chr(10) ||
               'Kayıt: {{kayitNo}}' || chr(10) || 'Konu: {{konu}}' || chr(10) ||
               '{{olcuAdi}}: {{olcu}}' || chr(10) || 'Basamak: {{adimAd}}' || chr(10) ||
               'Termin: {{termin}}',
       degiskenler = jsonb_build_object(
           'alici', 'Alıcının adı', 'akisAd', 'Akış adı', 'kayitNo', 'Kayıt no',
           'konu', 'Kaydın konusu', 'olcu', 'Karar ölçüsü (tutar/gün)',
           'olcuAdi', 'Ölçünün adı', 'adimAd', 'Basamak adı', 'termin', 'Karar termini'),
       degistirme_tarihi = now()
 where kod = 'onay.istek';

update public.bildirim_sablon set
       konu  = 'Bekleyen onay: {{kayitNo}}',
       govde = '{{kayitNo}} kaydı {{gecikmeGun}} gündür onayınızda bekliyor.' || chr(10) ||
               'Basamak: {{adimAd}}' || chr(10) || 'Konu: {{konu}}',
       degiskenler = jsonb_build_object(
           'alici', 'Alıcının adı', 'kayitNo', 'Kayıt no', 'konu', 'Kaydın konusu',
           'adimAd', 'Basamak adı', 'gecikmeGun', 'Kaç gün gecikti'),
       degistirme_tarihi = now()
 where kod = 'onay.hatirlatma';

update public.bildirim_sablon set
       konu  = '{{kayitNo}} {{sonucAd}}',
       govde = '{{kayitNo}} kaydınız {{sonucAd}}.' || chr(10) || '{{gerekce}}',
       degiskenler = jsonb_build_object(
           'alici', 'Alıcının adı', 'kayitNo', 'Kayıt no', 'akisAd', 'Akış adı',
           'sonucAd', 'ONAYLANDI / REDDEDİLDİ', 'gerekce', 'Karar gerekçesi'),
       degistirme_tarihi = now()
 where kod = 'onay.sonuc';

-- ============================================ 2) HATIRLATMA ZAMANLI İŞİ
--
--  Termini geçmiş basamak, unutulmuş bir karardır. İş GÜNDE BİR yazar
--  (aynı basamağa bugün yazılmışsa atlar) - saatte bir hatırlatma, bir
--  günde yirmi dört mesaj demek olurdu ve gürültü okunmaz.
--
--  VARSAYILAN KAPALI: iletişim sağlayıcısı tanımlı olmayan bir kurumda
--  kuyruk hata biriktirir. Kurum bildirimi kurunca açar.
insert into public.zamanli_is (kod, ad, aktif, periyot, saat, dakika, aciklama, ekleyen)
select 'onay.hatirlatma', 'Onay Hatırlatma', 0, 2, 9, 0,
       'Termini gecmis onay basamaklari icin gunde bir hatirlatma yazar. '
       'Kimseyi otomatik onaylamaz - sessiz onay, onayin kendisini kaldirirdi.', 0
 where not exists (select 1 from public.zamanli_is where kod = 'onay.hatirlatma');

-- =============================================== 3) VEKÂLET GÖRÜNÜMÜ
--
--  Liste ham kullanıcı id'si göstermesin: "4901 → 4903" kimsenin
--  okuyamayacağı bir devirdir. Adlar `taraf` üzerinden çözülür.
create or replace view public.v_onay_vekalet as
select k.id,
       k.devreden_id,
       coalesce(nullif(dv.unvan, ''), ku1.kod, '#' || k.devreden_id::text) as devreden_ad,
       k.devralan_id,
       coalesce(nullif(da.unvan, ''), ku2.kod, '#' || k.devralan_id::text) as devralan_ad,
       k.baslangic,
       k.bitis,
       k.akis_id,
       coalesce(a.ad, '')                                      as akis_ad,
       k.aciklama,
       k.aktif,
       k.sube_id,
       -- YÜRÜRLÜKTE Mİ: "aktif" kullanıcının bayrağı, bu ise TARİHİN cevabı.
       --   İkisini tek kolonda birleştirseydik, ileri tarihli bir vekâlet
       --   "pasif" görünür ve kullanıcı onu ikinci kez tanımlardı.
       case when k.aktif = 1 and current_date between k.baslangic and k.bitis
            then 1 else 0 end::smallint                        as yururlukte,
       k.ekleme_tarihi,
       k.degistirme_tarihi
  from public.onay_vekalet k
  left join public.taraf_kullanici ku1 on ku1.id = k.devreden_id
  left join public.taraf dv            on dv.id = k.devreden_id
  left join public.taraf_kullanici ku2 on ku2.id = k.devralan_id
  left join public.taraf da            on da.id = k.devralan_id
  left join public.onay_akis a         on a.id = k.akis_id;

comment on view public.v_onay_vekalet is
  '746: onay vekaleti listesi. yururlukte = aktif VE tarih araliginda - '
  'ileri tarihli vekalet pasif gorunmesin.';

-- ================================================= 4) AKIŞ SEÇİMİ
-- Kart, devreden/devralan alanlarında kullanıcı seçtirir; onun görünümü
--   (`v_kullanici_lookup`) ZATEN VAR - ikinci bir tane açmak, aynı listeyi
--   iki yerden bakımı gereken iki nesneye çevirirdi. Yalnız akış seçimi yeni:
--   vekâlet tek bir akışla sınırlandırılabilir (yalnız satınalma onayları).
create or replace view public.v_onay_akis_lookup as
select a.id, a.ad, a.aktif from public.onay_akis a;

comment on view public.v_onay_akis_lookup is
  '746: onay akisi secimi (vekalet tek akisla sinirlandirilabilir).';
