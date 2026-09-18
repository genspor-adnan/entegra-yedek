-- ============================================================================
--  Gentegre AI — BAKANLIK PROFİLİ 2/4: HEKİM TCKN'LERİ · MODALİTE KODU
--  810_bakanlik_hekim_ve_modalite.sql
--
--  Kullanıcı: *"bunları yap"* (dokuman/14, bölüm 5.5 · madde 2 ve 3).
--
--  ============ 1) HEKİM TCKN ========================================
--  Kılavuz 3.46 iki alanda TCKN istiyor ve eksik/hatalıysa mesajı reddediyor:
--    ORC-12 / OBR-16 : istemi yapan klinisyen hekim
--    OBX-16          : raporu onaylayan radyolog (varsa ikinci radyolog ~ ile)
--
--  Radyolog bizde `taraf`: TCKN'si `taraf.vkno`'dur (kişi rolünde vkno = TC
--  kimlik no, 001) - yeni kolon GEREKMEZ, okunacak yer bellidir.
--  İsteyen hekim ise teleradyolojide DIŞARIDAN gelir ve bugün yalnız
--  `telerad_istek.isteyen_hekim` (düz ad) olarak duruyor; aynı boşluk iç
--  istemde `radyoloji_istem.dis_hekim_ad` için de var. İkisine de TCKN
--  kolonu açılıyor - ad ile TCKN aynı alana sıkıştırılırsa ikisi de bozulur.
--
--  ============ 2) MODALİTE =========================================
--  OBR-24 "Kayıtlı Yöntemler" listesinden EN AZ İKİ HARF ister (MR, CT, CR…);
--  bizdeki `modalite` ise kendi smallint kodumuz (1 BT, 2 MR, 3 USG…).
--  Eşleme KOD İÇİNE GÖMÜLMEZ: hastaneye göre değişir - kimi röntgeni CR,
--  kimi DX bildirir. Bu yüzden veri olarak tablo.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------- hekim TCKN'si ----
alter table public.telerad_istek
    add column if not exists isteyen_hekim_tckn varchar(11) not null default '';
alter table public.radyoloji_istem
    add column if not exists dis_hekim_tckn varchar(11) not null default '';

comment on column public.telerad_istek.isteyen_hekim_tckn is
  '810: istemi yapan dış hekimin TCKN''si - Bakanlık ORC-12 / OBR-16 zorunlu alanı.';
comment on column public.radyoloji_istem.dis_hekim_tckn is
  '810: dış istem hekiminin TCKN''si (ORC-12). İç hekimde istek_hekim_id -> taraf.vkno.';

-- BİÇİM KONTROLÜ, DOĞRULUK DEĞİL: 11 hane ve rakam. Gerçek TCKN algoritması
--   uygulama katmanında (KimlikDogrulama.TcknGecerli) - burada tekrarlanmaz,
--   iki yerde iki farklı kural olmasın.
alter table public.telerad_istek
    drop constraint if exists ck_telerad_istek_hekim_tckn;
alter table public.telerad_istek
    add constraint ck_telerad_istek_hekim_tckn
    check (isteyen_hekim_tckn = '' or isteyen_hekim_tckn ~ '^[0-9]{11}$');

alter table public.radyoloji_istem
    drop constraint if exists ck_rad_istem_dis_hekim_tckn;
alter table public.radyoloji_istem
    add constraint ck_rad_istem_dis_hekim_tckn
    check (dis_hekim_tckn = '' or dis_hekim_tckn ~ '^[0-9]{11}$');

-- ----------------------------------------------------- modalite eşlemesi ----
create table if not exists public.rad_modalite_kod (
    modalite   smallint     primary key,
    dicom_kod  varchar(4)   not null,
    ad         varchar(60)  not null default '',
    aciklama   varchar(200) not null default '',
    constraint ck_rad_modalite_kod check (dicom_kod ~ '^[A-Z]{2,4}$')
);

comment on table public.rad_modalite_kod is
  '810: kendi modalite kodumuz (rad.modalite) ile DICOM/Bakanlık OBR-24 '
  'kısaltması arasındaki eşleme. En az iki harf zorunlu (kılavuz 3.46).';

insert into public.rad_modalite_kod (modalite, dicom_kod, ad, aciklama)
select v.modalite, v.dicom_kod, v.ad, v.aciklama
  from (values
    (1::smallint, 'CT',  'BT',        'Bilgisayarlı tomografi'),
    (2::smallint, 'MR',  'MR',        'Manyetik rezonans'),
    (3::smallint, 'US',  'USG',       'Ultrasonografi'),
    -- RÖNTGEN İKİ KODLA BİLDİRİLEBİLİR: CR (computed radiography) ile DX
    --   (digital radiography). Kılavuz örneği CR kullanıyor, varsayılan o;
    --   dijital detektörle çalışan kurum bu satırı DX yapar.
    (4::smallint, 'CR',  'Röntgen',   'Direkt grafi - dijital detektörde DX olarak değiştirilebilir'),
    (5::smallint, 'MG',  'Mamografi', 'Mamografi'),
    (6::smallint, 'BMD', 'DEXA',      'Kemik mineral dansitometri'),
    (7::smallint, 'XA',  'Anjiyo',    'Anjiyografi'),
    (8::smallint, 'RF',  'Skopi',     'Floroskopi')
  ) as v(modalite, dicom_kod, ad, aciklama)
 where not exists (select 1 from public.rad_modalite_kod m
                    where m.modalite = v.modalite);

-- TEK OKUYUCU: eşleme yoksa BOŞ döner (uydurma kod üretmez) - eksiklik
--   gönderim öncesi kontrolde görünür.
create or replace function public.fn_rad_modalite_kod(p_modalite smallint)
returns varchar
language sql stable as $$
  select coalesce((select m.dicom_kod from public.rad_modalite_kod m
                    where m.modalite = p_modalite), '')::varchar;
$$;

comment on function public.fn_rad_modalite_kod(smallint) is
  '810: modalite kodumuzun Bakanlık OBR-24 karşılığı; eşleme yoksa boş.';

-- Kart/liste ekranlarının okuduğu lookup (kod tablosu deseni: id + ad).
create or replace view public.v_rad_modalite_kod_lookup as
select m.modalite as id,
       m.dicom_kod || ' · ' || m.ad as ad,
       1::smallint as aktif
  from public.rad_modalite_kod m
 order by m.modalite;

comment on view public.v_rad_modalite_kod_lookup is
  '810: modalite-DICOM kodu eşlemesi lookup listesi.';

do $$
declare v_eksik integer;
begin
    select count(*) into v_eksik
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id and l.kod = 'rad.modalite'
      left join public.rad_modalite_kod m on m.modalite = d.deger
     where d.dil = 0 and coalesce(d.aktif, 1) = 1 and m.modalite is null;
    raise notice '810 tamam: % modalite kodu DICOM karsiligi olmadan kaldi '
                 '(0 olmali).', v_eksik;
end $$;
