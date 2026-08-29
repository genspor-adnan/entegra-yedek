-- 258: HASTANE DEPARTMAN / BÖLÜM YAPISI + randevu için örnek veri (kullanıcı:
-- "mevcut departman ve bölümleri hastane departman ve bölümleri gibi rename et,
-- randevu için data oluşsun").
--
-- ERP kurulumundan gelen departman adları (CNC, ÜRETİM PLANLAMA, İTHALAT...)
-- HBYS'de anlamsız. Yapılan:
--   1) Değişen her satır `departman_yedek_258` tablosuna yazılır - geri dönüş
--      tek UPDATE ile mümkün (bu bir VERİ dönüşümü, şema değişikliği değil).
--   2) Hastane karşılığı olan departmanlar YENİDEN ADLANDIRILIR ve doğru üst
--      birimin altına alınır; personeli olanlar korunur (kayıt silinmez).
--   3) Hastanede karşılığı olmayanlar PASİFE çekilir - silmek, o departmana
--      bağlı personelin departmanını boşa düşürürdü.
--   4) Poliklinikler + klinik/tanı birimleri eklenir, hekim kadrosu ve örnek
--      randevular oluşturulur.
--
-- Eklenen kayıtlar KODLA işaretli: departman/görev kodları HST-*, hekim
-- kartları HEK-* - hepsi tek sorguyla bulunup geri alınabilir.

create table if not exists public.departman_yedek_258 as
select id, kod, ad, ustbirim_id, randevu_verilebilir, durum
  from public.departman where false;

insert into public.departman_yedek_258
select id, kod, ad, ustbirim_id, randevu_verilebilir, durum
  from public.departman
 where not exists (select 1 from public.departman_yedek_258 y where y.id = departman.id);

-- ------------------------------------------------------------- kök birimler --
insert into public.departman (kod, ad, randevu_verilebilir, durum, sira)
select v.kod, v.ad, 0, 1, v.sira
  from (values ('HST-POL', 'Poliklinikler', 10),
               ('HST-KLN', 'Klinik Hizmetler', 20),
               ('HST-TAN', 'Tanı Birimleri', 30),
               ('HST-IDR', 'İdari Birimler', 40),
               ('HST-DST', 'Destek Hizmetleri', 50)) as v(kod, ad, sira)
 where not exists (select 1 from public.departman d where d.kod = v.kod);

-- ------------------------------------------------------------- poliklinikler --
-- Mevcut sekiz bölüm Poliklinikler altına alınır.
update public.departman d
   set ustbirim_id = (select k.id from public.departman k where k.kod = 'HST-POL')
 where d.randevu_verilebilir = 1 and d.ustbirim_id is null;

-- Eksik poliklinikler eklenir - hepsi randevu verilebilir.
insert into public.departman (kod, ad, randevu_verilebilir, durum, sira, ustbirim_id)
select v.kod, v.ad, 1, 1, v.sira,
       (select k.id from public.departman k where k.kod = 'HST-POL')
  from (values ('HST-KRD', 'Kardiyoloji', 110),
               ('HST-KBB', 'Kulak Burun Boğaz', 120),
               ('HST-NRL', 'Nöroloji', 130),
               ('HST-URO', 'Üroloji', 140),
               ('HST-DRM', 'Dermatoloji', 150),
               ('HST-PSK', 'Psikiyatri', 160),
               ('HST-DYT', 'Beslenme ve Diyet', 170)) as v(kod, ad, sira)
 where not exists (select 1 from public.departman d where lower(d.ad) = lower(v.ad));

-- ------------------------------------------------- klinik ve tanı birimleri --
insert into public.departman (kod, ad, randevu_verilebilir, durum, sira, ustbirim_id)
select v.kod, v.ad, 0, 1, v.sira,
       (select k.id from public.departman k where k.kod = v.ust)
  from (values ('HST-ACL', 'Acil Servis',      'HST-KLN', 210),
               ('HST-AML', 'Ameliyathane',     'HST-KLN', 220),
               ('HST-YBU', 'Yoğun Bakım',      'HST-KLN', 230),
               ('HST-SRV', 'Servis / Yataklı Birim', 'HST-KLN', 240),
               ('HST-HEM', 'Hemşirelik Hizmetleri',  'HST-KLN', 250),
               ('HST-LAB', 'Laboratuvar',      'HST-TAN', 310),
               ('HST-RAD', 'Radyoloji',        'HST-TAN', 320),
               ('HST-PAT', 'Patoloji',         'HST-TAN', 330)) as v(kod, ad, ust, sira)
 where not exists (select 1 from public.departman d where lower(d.ad) = lower(v.ad));

-- ---------------------------------------------- ERP departmanlarının çevrimi --
-- Hastane karşılığı olanlar: yeni ad + üst birim (personel bağı korunur).
update public.departman d
   set ad = v.yeni,
       ustbirim_id = (select k.id from public.departman k where k.kod = v.ust),
       degistirme_tarihi = now()::timestamp
  from (values ('Müşteri Hizmetleri',   'Hasta Kabul',          'HST-IDR'),
               ('Halkla İlişkiler',     'Hasta Hakları',        'HST-IDR'),
               ('Pazarlama',            'Hasta İlişkileri',     'HST-IDR'),
               ('Finans',               'Faturalama ve Vezne',  'HST-IDR'),
               ('Sekreterlik',          'Tıbbi Sekreterlik',    'HST-IDR'),
               ('Muhasebe',             'Muhasebe',             'HST-IDR'),
               ('İnsan Kaynakları',     'İnsan Kaynakları',     'HST-IDR'),
               ('Bilgi İşlem',          'Bilgi İşlem',          'HST-IDR'),
               ('Satınalma',            'Satınalma',            'HST-IDR'),
               ('Hukuk',                'Hukuk',                'HST-IDR'),
               ('Kalite Yönetimi',      'Kalite Yönetimi',      'HST-IDR'),
               ('Yönetim',              'Başhekimlik',          'HST-IDR'),
               ('İDARİ VE MALİ İŞLER',  'İdari ve Mali İşler',  'HST-IDR'),
               ('İş Sağlığı ve Güvenliği', 'İş Sağlığı ve Güvenliği', 'HST-DST'),
               ('Güvenlik',             'Güvenlik',             'HST-DST'),
               ('Teknik Destek',        'Teknik Servis',        'HST-DST'),
               ('DEPO',                 'Tıbbi Depo',           'HST-DST'),
               ('YEMEKHANE',            'Mutfak ve Diyet Hizmetleri', 'HST-DST')
       ) as v(eski, yeni, ust)
 where lower(d.ad) = lower(v.eski);

-- Hastanede karşılığı olmayanlar pasife çekilir (silinmez).
update public.departman d
   set durum = 0, degistirme_tarihi = now()::timestamp
 where d.durum = 1
   and lower(d.ad) in ('reklam', 'yazılım', 'i̇thalat ve ihracat', 'ithalat ve ihracat',
                       'servis', 'satış destek', 'cnc', 'kalite kontrol',
                       'montaj ve paketleme', 'müdür', 'satinalma & insan kaynaklari',
                       'satınalma & insan kaynakları', 'satiş', 'satış',
                       'üretim planlama', 'stajyer', 'grafik', 'arge');

-- ---------------------------------------------------------- hastane görevleri --
insert into public.personel_gorev (ad, departman_id, durum, sira)
select v.ad,
       coalesce((select d.id from public.departman d where d.kod = v.bolum_kod), 0),
       1, v.sira
  from (values ('Uzman Hekim',            null,      10),
               ('Pratisyen Hekim',        null,      20),
               ('Asistan Hekim',          null,      30),
               ('Hemşire',                null,      40),
               ('Sağlık Memuru',          null,      50),
               ('Tıbbi Sekreter',         null,      60),
               ('Laborant',               'HST-LAB', 70),
               ('Radyoloji Teknisyeni',   'HST-RAD', 80),
               ('Anestezi Teknisyeni',    'HST-AML', 90),
               ('Eczacı',                 null,     100),
               ('Diyetisyen',             'HST-DYT', 110),
               ('Fizyoterapist',          null,     120),
               ('Hasta Kabul Görevlisi',  null,     130)
       ) as v(ad, bolum_kod, sira)
 where not exists (select 1 from public.personel_gorev g where lower(g.ad) = lower(v.ad));

-- ----------------------------------------------------------- hekim kadrosu ---
-- Her poliklinik için bir uzman hekim. Kod HEK-* : sonradan tek sorguyla
--   bulunur. Şube = varsayılan (en küçük id) şube.
insert into public.taraf (kod, unvan, ad, soyad, durum, sube_id, personel,
                          randevu_verilebilir, departman, gorev_id, cep_tel, eposta)
select v.kod, v.unvan, v.ad, v.soyad, 1,
       (select min(s.id) from public.sube s), 1, 1,
       (select d.id from public.departman d where d.kod = v.bolum_kod),
       (select g.id from public.personel_gorev g where g.ad = 'Uzman Hekim'),
       v.tel, v.eposta
  from (values
        ('HEK-01', 'Dr. Selim Aydın',    'Selim',  'Aydın',    'HST-KRD', '+90 532 000 00 01', 'selim.aydin@ornek.com'),
        ('HEK-02', 'Dr. Nazlı Ergün',    'Nazlı',  'Ergün',    'HST-KBB', '+90 532 000 00 02', 'nazli.ergun@ornek.com'),
        ('HEK-03', 'Dr. Kemal Şahin',    'Kemal',  'Şahin',    'HST-NRL', '+90 532 000 00 03', 'kemal.sahin@ornek.com'),
        ('HEK-04', 'Dr. Aylin Kurt',     'Aylin',  'Kurt',     'HST-URO', '+90 532 000 00 04', 'aylin.kurt@ornek.com'),
        ('HEK-05', 'Dr. Burak Yıldız',   'Burak',  'Yıldız',   'HST-DRM', '+90 532 000 00 05', 'burak.yildiz@ornek.com'),
        ('HEK-06', 'Dr. Esra Tunç',      'Esra',   'Tunç',     'HST-PSK', '+90 532 000 00 06', 'esra.tunc@ornek.com')
       ) as v(kod, unvan, ad, soyad, bolum_kod, tel, eposta)
 where not exists (select 1 from public.taraf t where t.kod = v.kod);

-- Mevcut sekiz poliklinikte hekim yoksa oraya da birer hekim.
insert into public.taraf (kod, unvan, ad, soyad, durum, sube_id, personel,
                          randevu_verilebilir, departman, gorev_id, cep_tel, eposta)
select v.kod, v.unvan, v.ad, v.soyad, 1,
       (select min(s.id) from public.sube s), 1, 1,
       (select d.id from public.departman d where lower(d.ad) = lower(v.bolum)),
       (select g.id from public.personel_gorev g where g.ad = 'Uzman Hekim'),
       v.tel, v.eposta
  from (values
        ('HEK-07', 'Dr. Deniz Acar',    'Deniz',  'Acar',    'Diş',          '+90 532 000 00 07', 'deniz.acar@ornek.com'),
        ('HEK-08', 'Dr. Sinem Uysal',   'Sinem',  'Uysal',   'Göz',          '+90 532 000 00 08', 'sinem.uysal@ornek.com'),
        ('HEK-09', 'Dr. Onur Çetin',    'Onur',   'Çetin',   'Ortopedi',     '+90 532 000 00 09', 'onur.cetin@ornek.com'),
        ('HEK-10', 'Dr. Pelin Doğan',   'Pelin',  'Doğan',   'Kadın Doğum',  '+90 532 000 00 10', 'pelin.dogan@ornek.com'),
        ('HEK-11', 'Dr. Mert Şen',      'Mert',   'Şen',     'Çocuk',        '+90 532 000 00 11', 'mert.sen@ornek.com'),
        ('HEK-12', 'Dr. Gizem Aslan',   'Gizem',  'Aslan',   'Fizik Tedavi', '+90 532 000 00 12', 'gizem.aslan@ornek.com'),
        ('HEK-13', 'Dr. Cem Korkmaz',   'Cem',    'Korkmaz', 'Genel Cerrahi','+90 532 000 00 13', 'cem.korkmaz@ornek.com')
       ) as v(kod, unvan, ad, soyad, bolum, tel, eposta)
 where not exists (select 1 from public.taraf t where t.kod = v.kod)
   and exists (select 1 from public.departman d where lower(d.ad) = lower(v.bolum));

-- Mevcut hekimlerin (251 testinde Dahiliye'ye alınanlar) görevi de Uzman Hekim.
update public.taraf t
   set gorev_id = (select g.id from public.personel_gorev g where g.ad = 'Uzman Hekim')
 where t.randevu_verilebilir = 1 and t.personel = 1
   and (t.gorev_id is null or t.gorev_id = 0);

-- ------------------------------------------------------------ örnek randevu --
-- Yarından başlayarak her poliklinikte birer randevu; hasta olarak mevcut
--   hasta kartları dönüşümlü kullanılır. Aynı hekime aynı saatte ikinci kayıt
--   ux_randevu_hekim_saat'e takılmasın diye saatler hekim başına kaydırılır.
insert into public.randevu (sube_id, bolum, hekim_id, hasta_id, baslangic, sure_dk,
                            durum, aciklama, ekleyen)
select (select min(s.id) from public.sube s),
       h.departman,
       h.id,
       (select t.id from public.taraf t where t.hasta = 1
         order by t.id offset (h.sira % greatest((select count(*) from public.taraf where hasta = 1), 1)) limit 1),
       (current_date + 1) + ((9 + (h.sira % 6)) * interval '1 hour'),
       20, 1, 'Örnek randevu (258)', 0
  from (select t.id, t.departman,
               row_number() over (order by t.kod) - 1 as sira
          from public.taraf t
         where t.kod like 'HEK-%' and t.randevu_verilebilir = 1) h
 where h.departman is not null
   and exists (select 1 from public.taraf t where t.hasta = 1)
   and not exists (select 1 from public.randevu r
                    where r.hekim_id = h.id and r.aciklama = 'Örnek randevu (258)');
