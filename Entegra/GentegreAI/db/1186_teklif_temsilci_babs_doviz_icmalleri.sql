-- =============================================================================
--  1186  TEKLİF DÖNÜŞÜM / TEMSİLCİ PERFORMANS / Ba-Bs / DÖVİZ POZİSYONU İCMALLERİ
--
--  Kullanıcı (25.10.2026): "ilk dördü için mockup yap" → kararlar ("süresi geçen teklif kendiliğinden kayba
--  çevrilsin, temsilci faturadan alınsın") → "önce mockup'ları kodla". Mockup: Ekranlar/İcmal/
--  teklif_donusum_icmali.html, temsilci_performans_icmali.html, ba_bs_icmali.html, doviz_pozisyon_icmali.html.
--  Kalan açık sorularda mockup'taki öneriler uygulandı.
--
--  1) Ekran kodları (1003: bir kod bir menü ekranı; haklar ilgili ekranın kodundan, yalnız Gör):
--       satis.teklif_icmali          <- belge.satis            (Satış Teklifi Listesi kitlesi)
--       satis.temsilci_performans    <- satis.karlilik_icmali  (Kârlılık İcmali kitlesi)
--       muhasebe.babs_icmali         <- muhasebe.kdv_icmali    (KDV İcmali kitlesi)
--       finans.doviz_pozisyon        <- finans.cari_icmali     (Cari İcmali kitlesi)
--     Aksiyon kodları (tur 1, kaynakta DEĞİŞTİR yetkisi olan role):
--       satis.teklif_kayip     - teklifi "kaybedildi" işaretle (neden zorunlu)       <- belge.satis
--       satis.temsilci_hedef   - temsilci hedefi tanımla                             <- prim.plan
--       muhasebe.babs_mutabakat- Ba/Bs mutabakat gönder / yanıt işle               <- muhasebe_fis
--       finans.kur_farki       - kur farkı satırını "kesildi / gerek yok" işaretle <- belge.satis.fatura
--  2) Teklif kaybı (karar 25.10.2026): belge.teklif_durum 4 (Red) = kaybedildi; neden kod listesi
--     teklif.kayip_nedeni (9 = Süre doldu, gece işi yazar), rakip ve rakip fiyatı isteğe bağlı.
--     Geçerlilik = belge_tarihi + vade_gun (teklif kartı "Geçerlilik Süresi (gün)").
--  3) temsilci_hedef (temsilci × ay × ölçüt). Temsilci FATURADAN (belge.satici_id, karar 25.10.2026).
--  4) babs_mutabakat (dönem × form × cari: gönderim + yanıt).
--  5) kur_farki_takip (kapanan dövizli fatura için kur farkı faturası kesildi / gerek yok işareti).
--  6) Asistan kataloğu.
--  Ayarlar (AyarDeposu beyaz listesi; boş = varsayılan): teklif.otomatik_kayip (1), finans.degerleme_kuru
--  ('alis' | 'efektif' | 'satis'; boş = alis), muhasebe.babs_sinir (1176, boş = 5.000).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

-- ------------------------------------------------------------ ekran kodları --
create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40), tur smallint, tam smallint)
  on commit drop;
insert into _bolme values
  ('satis.teklif_icmali',       'belge.satis',           'Teklif / Fırsat Dönüşüm İcmali (Satış)',      'Satış',    0, 0),
  ('satis.temsilci_performans', 'satis.karlilik_icmali', 'Temsilci Performans İcmali (Satış)',          'Satış',    0, 0),
  ('muhasebe.babs_icmali',      'muhasebe.kdv_icmali',   'Ba / Bs İcmali (Muhasebe)',                   'Muhasebe', 0, 0),
  ('finans.doviz_pozisyon',     'finans.cari_icmali',    'Döviz Pozisyonu / Kur Farkı İcmali (Finans)', 'Finans',   0, 0),
  ('satis.teklif_kayip',        'belge.satis',           'Teklifi kaybedildi işaretle',                 'Satış',    1, 1),
  ('satis.temsilci_hedef',      'prim.plan',             'Temsilci hedefi tanımla',                     'Satış',    1, 1),
  ('muhasebe.babs_mutabakat',   'muhasebe_fis',          'Ba / Bs mutabakatı gönder / işle',            'Muhasebe', 1, 1),
  ('finans.kur_farki',          'belge.satis.fatura',    'Kur farkı satırını işaretle',                 'Finans',   1, 1);

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1186: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, b.tur, ye.sira, ye.urun_modu, ye.modul
  from _bolme b join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, case when b.tam = 1 then ry.degistir else ry.gor end, 0, 0, 0, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where b.tam = 0 or coalesce(ry.degistir, 0) = 1
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

-- -------------------------------------------------------------- teklif kaybı --
alter table public.belge add column if not exists teklif_kayip_nedeni smallint;
alter table public.belge add column if not exists teklif_rakip        varchar(120) not null default '';
alter table public.belge add column if not exists teklif_rakip_fiyat  numeric(18,2);
alter table public.belge add column if not exists teklif_kayip_an     timestamptz;
alter table public.belge add column if not exists teklif_kayip_kim    integer;   -- 0 = sistem (süre doldu)

comment on column public.belge.teklif_kayip_nedeni is
  '1186: teklif kaybedildi (teklif_durum 4) nedeni - kod listesi teklif.kayip_nedeni; 9 = Süre doldu (gece işi).';

insert into public.kod_liste (kod, ad)
select 'teklif.kayip_nedeni', 'Teklif Kayıp Nedeni'
 where not exists (select 1 from public.kod_liste where kod = 'teklif.kayip_nedeni');

insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select l.id, v.deger, 0, v.ad, v.sira, 1
  from public.kod_liste l
  cross join (values (1, 'Fiyat yüksek', 1), (2, 'Teslim süresi', 2), (3, 'Müşteri vazgeçti / bütçe yok', 3),
                     (4, 'Ürün / marka tercihi', 4), (5, 'Rakiple çalışıyor', 5), (8, 'Diğer', 8),
                     (9, 'Süre doldu', 9)) as v(deger, ad, sira)
 where l.kod = 'teklif.kayip_nedeni'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger and d.dil in (0, -1));

-- ------------------------------------------------------------ temsilci hedef --
create table if not exists public.temsilci_hedef (
  id                bigint generated always as identity primary key,
  temsilci_id       integer       not null references public.taraf(id) on delete cascade,
  donem             date          not null,                -- ayın ilk günü
  olcut             smallint      not null,                -- 1 ciro · 2 brüt kâr · 3 tahsilat · 4 yeni müşteri
  hedef             numeric(18,2) not null default 0,
  ekleyen           integer       not null default 0,
  ekleme_tarihi     timestamptz   not null default now(),
  degistiren        integer       not null default 0,
  degistirme_tarihi timestamptz,
  constraint ck_temsilci_hedef_olcut check (olcut in (1, 2, 3, 4)),
  constraint ck_temsilci_hedef_donem check (extract(day from donem) = 1)
);
create unique index if not exists ux_temsilci_hedef on public.temsilci_hedef (temsilci_id, donem, olcut);

-- ------------------------------------------------------------ Ba/Bs mutabakat --
create table if not exists public.babs_mutabakat (
  id                bigint generated always as identity primary key,
  donem             date          not null,                -- ayın ilk günü
  form              varchar(2)    not null,                -- 'BA' | 'BS'
  taraf_id          integer       not null references public.taraf(id) on delete cascade,
  vkn               varchar(20)   not null default '',
  belge_sayisi      integer       not null default 0,
  tutar             numeric(18,2) not null default 0,      -- gönderim anındaki bizim tutar (KDV hariç)
  eposta            varchar(300)  not null default '',
  gonderim_an       timestamptz,
  gonderen          integer       not null default 0,
  yanit             smallint      not null default 0,      -- 0 yanıt yok · 1 mutabık · 2 fark var
  carinin_tutari    numeric(18,2),
  carinin_belge     integer,
  yanit_an          timestamptz,
  yanit_not         varchar(500)  not null default '',
  isleyen           integer       not null default 0,
  constraint ck_babs_form  check (form in ('BA', 'BS')),
  constraint ck_babs_yanit check (yanit in (0, 1, 2)),
  constraint ck_babs_donem check (extract(day from donem) = 1)
);
create unique index if not exists ux_babs_mutabakat on public.babs_mutabakat (donem, form, taraf_id);

-- ------------------------------------------------------------ kur farkı takip --
create table if not exists public.kur_farki_takip (
  id                bigint generated always as identity primary key,
  taraf_id          integer       not null references public.taraf(id) on delete cascade,
  belge_id          integer       not null,                -- kapanan dövizli fatura
  kapama_anahtar    varchar(60)   not null default '',     -- kapatan tahsilat / ödeme (kasa_islem id ya da belge id)
  doviz             varchar(6)    not null,
  tutar_doviz       numeric(18,2) not null default 0,
  fatura_kuru       numeric(18,6) not null default 0,
  kapama_kuru       numeric(18,6) not null default 0,
  kur_farki         numeric(18,2) not null default 0,      -- TL; + lehimize
  durum             smallint      not null default 1,      -- 1 kesildi · 2 gerek yok
  kesilen_belge_id  integer,
  aciklama          varchar(300)  not null default '',
  ekleyen           integer       not null default 0,
  ekleme_tarihi     timestamptz   not null default now(),
  constraint ck_kur_farki_durum check (durum in (1, 2))
);
create unique index if not exists ux_kur_farki_takip on public.kur_farki_takip (belge_id, kapama_anahtar);

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.grup, v.baslik, v.yetki_kodu, case when v.grup = 'Satış' then 1 else 0 end::smallint,
       v.anahtar, v.aciklama, ''
  from (values
    ('teklif-icmali', '/teklif-icmali', 'Teklif / Fırsat Dönüşüm İcmali', 'Satış › İcmaller › Teklif / Fırsat Dönüşüm İcmali', 'Satış',
     'satis.teklif_icmali',
     'teklif fırsat dönüşüm huni siparişe dönen kaybedilen kayıp nedeni rakip süresi dolan geçerlilik takip temsilci müşteri kategori iskonto',
     'Fırsat → teklif → sipariş hunisi, dönüşüm oranı temsilci / müşteri / kategori bazında, kayıp nedenleri ve rakipler, '
     || 'süresi dolmak üzere olan teklifler; süresi dolan teklif gece kendiliğinden "kaybedildi · süre doldu" olur.'),
    ('temsilci-performans', '/temsilci-performans', 'Temsilci Performans İcmali', 'Satış › İcmaller › Temsilci Performans İcmali', 'Satış',
     'satis.temsilci_performans',
     'temsilci satış performans ciro brüt kâr marj tahsilat vadesi geçen yeni müşteri hedef gerçekleşen prim portföy aktivite ziyaret',
     'Temsilci (faturadaki satıcı) bazında ciro, brüt kâr, tahsilat, vadesi geçen alacak, yeni müşteri; hedef / gerçekleşen, '
     || 'aylık gidişat, müşteri portföyü, tahsilat kalitesi, CRM aktivitesi ve prim taslağı.'),
    ('babs-icmali', '/babs-icmali', 'Ba / Bs İcmali', 'Muhasebe › İcmaller › Ba / Bs İcmali', 'Muhasebe',
     'muhasebe.babs_icmali',
     'ba bs form ba form bs 5000 eşik vkn tckn mutabakat mektubu cari mutabakat beyanname bildirim alış satış belge sayısı',
     'Aylık Form Ba (alış) ve Form Bs (satış): eşik üstü cariler VKN bazında belge sayısı ve KDV hariç tutar, eşik altı, eksik / hatalı VKN '
     || 'uyarıları, cari mutabakat gönderimi ve yanıtları, KDV İcmali ile kıyas.'),
    ('doviz-pozisyon', '/doviz-pozisyon', 'Döviz Pozisyonu / Kur Farkı İcmali', 'Finans › İcmaller › Döviz Pozisyonu / Kur Farkı İcmali', 'Finans',
     'finans.doviz_pozisyon',
     'döviz pozisyon kur farkı değerleme usd eur gbp döviz kasa döviz banka dövizli cari açık pozisyon kur duyarlılık kur farkı faturası',
     'Döviz bazında net pozisyon (döviz kasa, banka, dövizli cari alacak / borç, portföy çek), dövizli carilerin değerleme farkı, '
     || 'gerçekleşen kur farkı, kesilmesi gereken kur farkı faturaları, döviz vade takvimi ve kur duyarlılığı.'))
    as v(kaynak, rota, baslik, yol, grup, yetki_kodu, anahtar, aciklama)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
