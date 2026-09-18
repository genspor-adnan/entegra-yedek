-- ============================================================================
--  Gentegre AI — BAKANLIK PROFİLİ 3/4: OBX-13 DEĞERLENDİRME · OBX-17 KONTRAST
--  811_bakanlik_degerlendirme_ve_kontrast.sql
--
--  Kullanıcı: *"bunları yap"* (dokuman/14, bölüm 5.5 · madde 4 ve 5).
--
--  ============ OBX-13: İKİ PUAN =====================================
--  Kılavuz 3.46, ORU mesajında radyoloğun İKİ DEĞERLENDİRME yapmasını
--  istiyor (`1^2` biçiminde):
--    Tetkik istem nedeni : 1 Yok · 2 Yetersiz · 3 Orta · 4 İyi · 5 Mükemmel
--    Çekim kalitesi      : 1 Çok kötü · 2 Kötü · 3 Orta · 4 İyi · 5 Çok iyi
--  Birincisi KLİNİSYENİ, ikincisi ÇEKİMİ değerlendirir - ikisi ayrı alan;
--  tek "kalite" alanına indirilirse hangi tarafın sorunlu olduğu kaybolur.
--  Puanlar RAPORDA durur (radyolog verir), istemde değil.
--
--  Bizdeki `telerad_istek.goruntu_durum` (tamam/eksik/hatalı) BUNUN YERİNE
--  GEÇMEZ: o "görüntü ulaştı mı" sorusunun cevabı, çekimin kalitesi değil.
--
--  ============ OBX-17: KONTRAST =====================================
--  `Veriliş yolu ^ Etkin madde ^ Konsantrasyon` (örn. `IV^Ioheksol^300`),
--  çoklu madde `~` ile. Kılavuz TİCARİ İSMİ YASAKLIYOR - etkin madde adı
--  ve konsantrasyon istiyor. Bizde bugün yalnız `kontrast` (evet/hayır) ve
--  `kontrast_ml` var; ml MİKTARDIR, konsantrasyon değildir (300 mg/ml'lik
--  maddeden 80 ml verilebilir - ikisi ayrı sayıdır).
-- ============================================================================
\set ON_ERROR_STOP on

-- ----------------------------------------------------------- kod listeleri ----
insert into public.kod_liste (kod, ad)
select v.kod, v.ad
  from (values ('rad.istem_nedeni_puan', 'Tetkik İstem Nedeni Değerlendirme'),
               ('rad.cekim_kalite_puan', 'Çekim Kalitesi Değerlendirme'))
       as v(kod, ad)
 where not exists (select 1 from public.kod_liste l where l.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('rad.istem_nedeni_puan', 1, 'Yok'),      ('rad.istem_nedeni_puan', 2, 'Yetersiz'),
    ('rad.istem_nedeni_puan', 3, 'Orta'),     ('rad.istem_nedeni_puan', 4, 'İyi'),
    ('rad.istem_nedeni_puan', 5, 'Mükemmel'),
    ('rad.cekim_kalite_puan', 1, 'Çok kötü'), ('rad.cekim_kalite_puan', 2, 'Kötü'),
    ('rad.cekim_kalite_puan', 3, 'Orta'),     ('rad.cekim_kalite_puan', 4, 'İyi'),
    ('rad.cekim_kalite_puan', 5, 'Çok iyi')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger and d.dil = 0);

-- --------------------------------------------------------- rapor puanları ----
alter table public.radyoloji_rapor
    add column if not exists istem_nedeni_puan smallint not null default 0;
alter table public.radyoloji_rapor
    add column if not exists cekim_kalite_puan smallint not null default 0;

comment on column public.radyoloji_rapor.istem_nedeni_puan is
  '811: OBX-13 birinci değer - istemin gerekçesi ne kadar yeterliydi (0 girilmedi, 1-5).';
comment on column public.radyoloji_rapor.cekim_kalite_puan is
  '811: OBX-13 ikinci değer - çekimin kalitesi (0 girilmedi, 1-5).';

alter table public.radyoloji_rapor drop constraint if exists ck_rad_rapor_nedeni_puan;
alter table public.radyoloji_rapor
    add constraint ck_rad_rapor_nedeni_puan check (istem_nedeni_puan between 0 and 5);
alter table public.radyoloji_rapor drop constraint if exists ck_rad_rapor_kalite_puan;
alter table public.radyoloji_rapor
    add constraint ck_rad_rapor_kalite_puan check (cekim_kalite_puan between 0 and 5);

-- -------------------------------------------------------- kontrast yolu ----
create table if not exists public.rad_kontrast_yol (
    kod    varchar(3)  primary key,
    ad     varchar(40) not null,
    sira   smallint    not null default 0,
    aktif  smallint    not null default 1
);

comment on table public.rad_kontrast_yol is
  '811: kontrast veriliş yolu (OBX-17 birinci parça) - kılavuzun kısaltmaları.';

insert into public.rad_kontrast_yol (kod, ad, sira)
select v.kod, v.ad, v.sira
  from (values ('IV', 'İntravenöz', 10), ('O',  'Oral', 20),
               ('IA', 'İntraarteriyel', 30), ('IT', 'İntratekal', 40),
               ('ID', 'İntradiskal', 50), ('R',  'Rektal', 60))
       as v(kod, ad, sira)
 where not exists (select 1 from public.rad_kontrast_yol y where y.kod = v.kod);

create or replace view public.v_rad_kontrast_yol_lookup as
select y.kod as id, y.kod || ' · ' || y.ad as ad, y.aktif
  from public.rad_kontrast_yol y
 order by y.sira;

comment on view public.v_rad_kontrast_yol_lookup is
  '811: kontrast veriliş yolu lookup listesi.';

-- --------------------------------------------------------- istem alanları ----
alter table public.radyoloji_istem
    add column if not exists kontrast_yol varchar(3) not null default '';
alter table public.radyoloji_istem
    add column if not exists kontrast_madde varchar(80) not null default '';
alter table public.radyoloji_istem
    add column if not exists kontrast_konsantrasyon numeric(9,2) not null default 0;

comment on column public.radyoloji_istem.kontrast_yol is
  '811: OBX-17 veriliş yolu (rad_kontrast_yol): IV/O/IA/IT/ID/R.';
comment on column public.radyoloji_istem.kontrast_madde is
  '811: OBX-17 ETKİN MADDE adı (Ioheksol gibi) - kılavuz ticari ismi yasaklıyor.';
comment on column public.radyoloji_istem.kontrast_konsantrasyon is
  '811: OBX-17 konsantrasyon (mg/ml). kontrast_ml MİKTARDIR, bu ayrı sayıdır.';

-- Boş dize FK'yi bozmasın: "yol seçilmedi" hâli için karşılığı olan bir satır
--   gerekiyor. Kod listesine sahte değer eklemek yerine boş kod tutuluyor -
--   lookup'ta görünmez (aktif = 0).
insert into public.rad_kontrast_yol (kod, ad, sira, aktif)
select '', '(seçilmedi)', 0, 0
 where not exists (select 1 from public.rad_kontrast_yol y where y.kod = '');

alter table public.radyoloji_istem drop constraint if exists fk_rad_istem_kontrast_yol;
alter table public.radyoloji_istem
    add constraint fk_rad_istem_kontrast_yol
    foreign key (kontrast_yol) references public.rad_kontrast_yol(kod);

-- ------------------------------------------------------- OBX-17 metni ----
-- TEK ÜRETİCİ: ileride ORU üreticisi de, gönderim öncesi kontrol de buradan
--   okur. Kontrast verilmemişse boş döner (boş OBX-17 gönderilmez).
create or replace function public.fn_rad_kontrast_obx17(p_istem_id integer)
returns text
language sql stable as $$
  select case
           when coalesce(i.kontrast, 0) = 0 then ''
           when btrim(coalesce(i.kontrast_madde, '')) = ''
             or coalesce(i.kontrast_yol, '') = '' then ''
           else i.kontrast_yol || '^' || btrim(i.kontrast_madde) ||
                case when coalesce(i.kontrast_konsantrasyon, 0) > 0
                     then '^' || trim(trailing '.' from
                                 trim(trailing '0' from
                                   to_char(i.kontrast_konsantrasyon, 'FM9999990.00')))
                     else '' end
         end
    from public.radyoloji_istem i
   where i.id = p_istem_id;
$$;

comment on function public.fn_rad_kontrast_obx17(integer) is
  '811: OBX-17 gövdesi (yol^etkin madde^konsantrasyon); eksik veride boş.';

do $$
begin
    raise notice '811 tamam: rapor puan alanlari, kontrast yol/madde/'
                 'konsantrasyon ve OBX-17 uretici hazir.';
end $$;
