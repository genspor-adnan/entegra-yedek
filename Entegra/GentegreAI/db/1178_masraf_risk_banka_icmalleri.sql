-- =============================================================================
--  1178  MASRAF / MÜŞTERİ RİSK-LİMİT / BANKA MUTABAKAT İCMALLERİ
--
--  Kullanıcı (25.10.2026): "Masraf, müşteri risk ve banka mutabakat icmalleri için mockup yap" →
--  açık sorular onaylandı ("onayla, hepsini işle") → "önce mockup ları kodla".
--  Mockup: Ekranlar/İcmal/masraf_icmali.html, musteri_risk_icmali.html, banka_mutabakat_icmali.html
--  (kararlar "(karar 25.10.2026)" notlarında).
--
--  1) Ekran kodları (1003: bir kod bir menü ekranı; haklar ilgili ekranın kodundan, yalnız Gör):
--       finans.masraf_icmali          <- masraf              (Masraf Listesi)
--       finans.musteri_risk_icmali    <- finans.cari_icmali  (Cari İcmali kitlesi)
--       finans.banka_mutabakat        <- banka.hareket       (Banka Hareketleri kitlesi)
--     Aksiyon kodları (tur 1):
--       banka.mutabakat_onay   - mutabakatı onayla (haklar banka.hareket'ten: Değiştir yetkisi olan rol)
--       cari.risk_limit        - limit / teminat / sevk blokesi değiştir (haklar finans.cari_icmali Değiştir'den)
--       satis.limit_asim       - limit aşımında "engelle" kipinde yine de belge kesebilir (haklar cari.risk_limit ile aynı)
--  2) Müşteri risk alanları (karar R1): taraf.risk_limit (+ dövizi), sevk blokesi (bayrak / neden / kim / ne zaman),
--     risk_grubu; taraf_teminat (tür, tutar, döviz, bitiş).
--  3) Banka: hesap_gun_bakiye (API'siz hesabın elle gün sonu bakiyesi, karar B3), banka_mutabakat (gün + hesap
--     onayı; geriye dönük kayıt "bozuldu" yapar, karar B4).
--  4) Asistan kataloğu.
--  Ayarlar (referans, AyarDeposu beyaz listesi; boş = varsayılan): masraf.artis_esik_yuzde (25), masraf.mukerrer_gun (1),
--  satis.limit_davranis ('uyar' | 'engelle'; boş = uyar), banka.mutabakat_tolerans_kurus (0), banka.mutabakat_dort_goz (0).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

-- ------------------------------------------------------------ ekran kodları --
create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40), tur smallint, tam smallint)
  on commit drop;
insert into _bolme values
  ('finans.masraf_icmali',        'masraf',             'Masraf İcmali (Finans)',                 'Finans', 0, 0),
  ('finans.musteri_risk_icmali',  'finans.cari_icmali', 'Müşteri Risk / Limit İcmali (Finans)',   'Finans', 0, 0),
  ('finans.banka_mutabakat',      'banka.hareket',      'Banka Mutabakat İcmali (Finans)',        'Finans', 0, 0),
  ('banka.mutabakat_onay',        'banka.hareket',      'Banka mutabakatını onayla',              'Finans', 1, 1),
  ('cari.risk_limit',             'finans.cari_icmali', 'Risk limiti / teminat / sevk blokesi',   'Finans', 1, 1),
  ('satis.limit_asim',            'finans.cari_icmali', 'Limit aşımında belge kes (engel kipinde)', 'Satış', 1, 1);

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1178: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, b.tur, ye.sira, ye.urun_modu, ye.modul
  from _bolme b join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = excluded.tur, aktif = 1;

-- Ekran kodu: yalnız Gör kopyalanır. Aksiyon kodu: kaynak kodda DEĞİŞTİR yetkisi olan role Gör (aksiyon = gor).
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

-- ----------------------------------------------------------- müşteri risk --
alter table public.taraf add column if not exists risk_limit          numeric(18,2);           -- null = TANIMSIZ (limitsiz değil)
alter table public.taraf add column if not exists risk_limit_doviz    varchar(6) not null default 'TL';
alter table public.taraf add column if not exists sevk_blokesi        smallint   not null default 0;
alter table public.taraf add column if not exists sevk_blokesi_neden  varchar(300) not null default '';
alter table public.taraf add column if not exists sevk_blokesi_kim    integer;
alter table public.taraf add column if not exists sevk_blokesi_an     timestamptz;
alter table public.taraf add column if not exists risk_grubu          varchar(60) not null default '';

create table if not exists public.taraf_teminat (
  id                bigint generated always as identity primary key,
  taraf_id          integer       not null references public.taraf(id) on delete cascade,
  tur               smallint      not null default 1,     -- 1 teminat mektubu · 2 ipotek · 3 çek / senet · 4 nakit · 9 diğer
  tutar             numeric(18,2) not null default 0,
  doviz             varchar(6)    not null default 'TL',
  baslangic         date,
  bitis             date,                                  -- null = süresiz
  aciklama          varchar(300)  not null default '',
  ekleyen           integer       not null default 0,
  ekleme_tarihi     timestamptz   not null default now(),
  degistiren        integer       not null default 0,
  degistirme_tarihi timestamptz,
  constraint ck_taraf_teminat_tur check (tur in (1, 2, 3, 4, 9))
);
create index if not exists ix_taraf_teminat on public.taraf_teminat (taraf_id);

-- ------------------------------------------------------------------ banka --
-- API'siz hesabın gün sonu banka bakiyesi (elle; ekstre içe aktarma gelince oradan) - karar B3.
create table if not exists public.hesap_gun_bakiye (
  id                bigint generated always as identity primary key,
  hesap_id          integer       not null references public.hesap(id) on delete cascade,
  gun               date          not null,
  bakiye            numeric(19,4) not null,
  kaynak            smallint      not null default 1,     -- 1 elle · 2 ekstre dosyası
  aciklama          varchar(300)  not null default '',
  ekleyen           integer       not null default 0,
  ekleme_tarihi     timestamptz   not null default now(),
  degistiren        integer       not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_hesap_gun_bakiye on public.hesap_gun_bakiye (hesap_id, gun);

-- Mutabakat onayı (gün + hesap). O günün bakiyeleri ve açıklama listeleri `detay`ta dondurulur; o güne geriye
--   dönük kasa işlemi girilirse durum 2 "bozuldu" olur ve yeniden onay ister (karar B4).
create table if not exists public.banka_mutabakat (
  id                bigint generated always as identity primary key,
  hesap_id          integer       not null references public.hesap(id) on delete cascade,
  gun               date          not null,
  banka_bakiye      numeric(19,4) not null,
  sistem_bakiye     numeric(19,4) not null,
  aciklanmayan      numeric(19,4) not null default 0,
  durum             smallint      not null default 1,     -- 1 onaylı · 2 bozuldu
  detay             jsonb,
  hazirlayan        integer       not null default 0,
  onaylayan         integer       not null default 0,
  onay_an           timestamptz   not null default now(),
  bozulma_an        timestamptz,
  bozulma_neden     varchar(300)  not null default '',
  constraint ck_banka_mutabakat_durum check (durum in (1, 2))
);
create unique index if not exists ux_banka_mutabakat on public.banka_mutabakat (hesap_id, gun);

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, 'Finans', v.baslik, v.yetki_kodu, 0::smallint, v.anahtar, v.aciklama, ''
  from (values
    ('masraf-icmali', '/masraf-icmali', 'Masraf İcmali', 'Finans › İcmaller › Masraf İcmali', 'finans.masraf_icmali',
     'masraf icmal gider kalem masraf merkezi aylık trend geçen yıl plan gerçek planlı gider tedarikçi belge detay kalem atanmamış mükerrer olağan dışı artış gider ciro oranı amortisman sarf',
     'Giderlerin masraf kalemi ağacı ve masraf merkezi bazında dağılımı, aylık gidişatı ve geçen yılla karşılaştırması; Planlı Giderler ile plan − gerçek, tedarikçiye göre gider, '
     || 'kalem atanmamış / mükerrer / olağan dışı artış uyarıları ve toplu masraf kalemi atama.'),
    ('musteri-risk-icmali', '/musteri-risk-icmali', 'Müşteri Risk / Limit İcmali', 'Finans › İcmaller › Müşteri Risk / Limit İcmali', 'finans.musteri_risk_icmali',
     'müşteri risk limit teminat açık bakiye vadesi geçen portföy çek faturasız irsaliye açık sipariş limit aşımı sevk blokesi ödeme davranışı skor yoğunlaşma risk grubu',
     'Müşteri bazında toplam risk (açık bakiye + portföy çek + faturasız irsaliye + açık sipariş), limit ve teminat, limit aşımı, vade özeti, çek riski, ödeme davranışı skoru, '
     || 'yoğunlaşma ve sevk blokesi önerisi; limit güncelleme, bloke koyma / kaldırma, hatırlatma.'),
    ('banka-mutabakat', '/banka-mutabakat', 'Banka Mutabakat İcmali', 'Finans › İcmaller › Banka Mutabakat İcmali', 'finans.banka_mutabakat',
     'banka mutabakat bakiye sistem bakiyesi fark işlenmemiş banka hareketi yolda verilen çek talimat valör pos mutabakat tablosu onay tutanak günlük bakiye api elle bakiye',
     'Banka hesaplarında banka bakiyesi ile sistem bakiyesinin karşılaştırması; işlenmemiş banka hareketleri, sistemde olup bankaya düşmemiş kayıtlar, açıklanmayan fark, '
     || 'API''siz hesap için elle gün sonu bakiyesi, günlük mutabakat onayı ve tutanak.'))
    as v(kaynak, rota, baslik, yol, yetki_kodu, anahtar, aciklama)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
