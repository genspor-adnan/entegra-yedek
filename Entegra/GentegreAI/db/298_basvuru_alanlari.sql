-- 298: Başvuru sekmesi alanları (mockup Ekranlar/kayit_kabul_basvuru.html).
--
-- Kullanıcı: başvuru kartına "Başvuru" sekmesi eklensin ve mockup gibi olsun.
-- Mockup'taki "Yeni Başvuru" ve "Ödeme / Provizyon" grupları kayıt kabulün
-- gerçekten doldurduğu alanlar: başvuru türü, geliş şekli/nedeni, poliklinik
-- odası, sıra no, refakatçi + provizyon (takip) bilgileri.
--
-- Hepsi belge_basvuru (1:1) uzantısında: yalnız başvuruda anlamlılar ve liste
-- "zamanla büyüyecek" (296'daki karar).
--
-- MEDULA ENTEGRASYONU YOK: provizyon alanları şimdilik ELLE girilir/okunur.
-- Müstehaklık sorgusu bir servise bağlandığında bu alanlar otomatik dolacak;
-- şema o gün değişmesin diye sorgu zamanı ve sonucu ayrı tutuluyor.

alter table public.belge_basvuru
  add column if not exists basvuru_turu     smallint,
  add column if not exists gelis_sekli      smallint,
  add column if not exists gelis_nedeni     smallint,
  add column if not exists oda              smallint,
  add column if not exists sira_no          varchar(20)  not null default '',
  add column if not exists refakatci        varchar(120) not null default '',
  -- Provizyon / takip (SGK ve anlaşmalı kurumlar)
  add column if not exists provizyon_no     varchar(40)  not null default '',
  add column if not exists provizyon_tipi   smallint,
  add column if not exists mustehaklik      smallint     not null default 0,
  add column if not exists mustehaklik_zaman timestamp,
  add column if not exists sevkli           smallint     not null default 0,
  add column if not exists sevk_kurum       varchar(150) not null default '';

comment on column public.belge_basvuru.basvuru_turu is
  'Poliklinik / Acil / Yatan Hasta / Günübirlik / Laboratuvar-Görüntüleme (kod: basvuru.tur).';
comment on column public.belge_basvuru.mustehaklik is
  '0 sorgulanmadı · 1 müstehak · 2 müstehak değil (298). MEDULA bağlanınca otomatik dolar.';
comment on column public.belge_basvuru.sira_no is
  'Poliklinik sıra numarası (A-037 gibi) - şimdilik elle girilir.';

-- ------------------------------------------------------------ kod listeleri --
-- Hepsi düzenlenebilir: hastane kendi geliş nedenlerini/odalarını tanımlar.
insert into public.kod_liste (kod, ad)
select v.kod, v.ad
  from (values ('basvuru.tur',            'Başvuru Türü'),
               ('basvuru.gelis_sekli',    'Geliş Şekli'),
               ('basvuru.gelis_nedeni',   'Geliş Nedeni'),
               ('basvuru.oda',            'Poliklinik Odası'),
               ('basvuru.provizyon_tipi', 'Provizyon Tipi')) as v(kod, ad)
 where not exists (select 1 from public.kod_liste l where l.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
        ('basvuru.tur', 1, 'Poliklinik'),
        ('basvuru.tur', 2, 'Acil'),
        ('basvuru.tur', 3, 'Yatan Hasta'),
        ('basvuru.tur', 4, 'Günübirlik'),
        ('basvuru.tur', 5, 'Laboratuvar / Görüntüleme'),
        ('basvuru.gelis_sekli', 1, 'Kendi imkânıyla'),
        ('basvuru.gelis_sekli', 2, 'Ambulans'),
        ('basvuru.gelis_sekli', 3, 'Sevkli'),
        ('basvuru.gelis_sekli', 4, 'Kurum aracı'),
        ('basvuru.gelis_nedeni', 1, 'Muayene'),
        ('basvuru.gelis_nedeni', 2, 'Kontrol'),
        ('basvuru.gelis_nedeni', 3, 'Tetkik / Tahlil'),
        ('basvuru.gelis_nedeni', 4, 'Rapor'),
        ('basvuru.gelis_nedeni', 5, 'Aşı / Enjeksiyon'),
        ('basvuru.provizyon_tipi', 1, 'Normal'),
        ('basvuru.provizyon_tipi', 2, 'Acil'),
        ('basvuru.provizyon_tipi', 3, 'İş Kazası'),
        ('basvuru.provizyon_tipi', 4, 'Trafik Kazası'),
        ('basvuru.provizyon_tipi', 5, 'Adli Vaka')
       ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- Başvuru listesinde/kartında sık sorulan: "bugün acil kaç başvuru".
create index if not exists ix_belge_basvuru_tur on public.belge_basvuru (basvuru_turu)
    where basvuru_turu is not null;
