-- ============================================================================
--  Gentegre AI — FİRMA LOGO / KAŞE / İMZA
--  193_firma_kase.sql
--
--  Mockup: Ekranlar/firma_bilgileri.html › "Logo & Kaşe" sekmesi
--    Logo · Kaşe / İmza · belge üstbilgisi önizlemesi
--
--  GÖRSELLER AYRI KOLON DEĞİL, DOKÜMAN: sube.logo (bytea) kolonu duruyor ama
--  kullanılmıyordu; üç ayrı bytea kolonu (logo/kaşe/imza) açmak yerine mevcut
--  `dokuman` altyapısı kullanılır - hash-dedup, içerik tipi denetimi, boyut
--  sınırı ve log zaten orada. Ayrım `dokuman.belge_turu` alanında:
--      'Logo' · 'Kaşe' · 'İmza'      (kaynak = 'sube', kaynak_id = şube)
--
--  MERKEZDEN MİRAS: şube kendi logosunu yüklemediyse merkezin logosu kullanılır
--  (fn_sube_gorsel) - e-Belge kimliği ve mali ayarlardaki desenin aynısı. Çok
--  şubeli firmada her şubeye aynı logoyu yüklettirmek anlamsız.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.sube
    -- MERKEZ / ŞUBE AYRIMI (kullanıcı): mali ayarlardaki bayrağın aynısı.
    --   1 = merkezin logo/kaşe/imzası kullanılır (çok şubeli firmada olağan)
    --   0 = şube kendi görsellerini yükler (ayrı VKN'li şube, farklı marka)
    add column if not exists merkez_gorsel_kullan smallint not null default 1,
    -- e-Arşiv PDF'i ve kağıt çıktı AYRI kararlar: e-Arşiv PDF'i müşteriye
    --   giden resmî belgedir, kaşe basmak isteğe bağlıdır; kağıt çıktıda
    --   ıslak imza yerine kaşe görüntüsü kullanmak ayrı bir tercihtir.
    add column if not exists kase_pdf_bas    smallint not null default 0,
    add column if not exists kase_kagit_bas  smallint not null default 0,
    -- Belge üstbilgisi şablonu (antet). Şubeye özel antet mümkün olsun.
    add column if not exists antet_sablonu   varchar(80) not null default '';

comment on column public.sube.merkez_gorsel_kullan is
  'Sube logo/kase/imzayi merkezden mi alsin (193): 1 merkez, 0 kendi gorselleri.';
comment on column public.sube.kase_pdf_bas is
  'e-Arsiv PDF ciktisina kase + imza basilsin mi (193).';
comment on column public.sube.kase_kagit_bas is
  'Kagit ciktilarda kase gorunsun mu (193).';
comment on column public.sube.antet_sablonu is
  'Belge ustbilgisi (antet) sablon adi; bos ise varsayilan sablon (193).';

-- ---------------------------------------------------------------------------
--  ETKİN GÖRSEL: şubenin kendi görseli yoksa merkezinki.
--    p_amac: 'Logo' | 'Kaşe' | 'İmza'
-- ---------------------------------------------------------------------------
create or replace function public.fn_sube_gorsel(p_sube_id integer, p_amac varchar)
returns table (dokuman_id bigint, sube_id integer, merkezden boolean,
               ad varchar, content_type varchar, boyut bigint)
language sql stable as $$
    with hedef as (
        select s.id as sube_id,
               coalesce(public.fn_sube_merkez_id(s.id), s.id) as merkez_id,
               s.merkez_gorsel_kullan
          from public.sube s where s.id = p_sube_id),
    -- BAYRAK: merkez_gorsel_kullan = 1 ise subenin kendi gorseli ARANMAZ;
    --   kullanici merkezi secmisse yanlislikla yuklenmis eski bir sube
    --   gorseli devreye girmemeli.
    kendi as (
        select d.id, d.ad, d.content_type, d.boyut
          from public.dokuman d, hedef h
         where h.merkez_gorsel_kullan = 0
           and d.kaynak = 'sube' and d.kaynak_id = h.sube_id
           and d.belge_turu = p_amac and coalesce(d.durum, 1) = 1
         order by d.varsayilan desc, d.id desc limit 1),
    merkez as (
        select d.id, d.ad, d.content_type, d.boyut
          from public.dokuman d, hedef h
         where d.kaynak = 'sube' and d.kaynak_id = h.merkez_id
           and d.belge_turu = p_amac and coalesce(d.durum, 1) = 1
         order by d.varsayilan desc, d.id desc limit 1)
    select k.id, (select sube_id from hedef), false, k.ad, k.content_type, k.boyut from kendi k
    union all
    -- merkezden bayragi: MERKEZIN KENDISI icin false - kendi gorselini
    --   kullaniyor, miras almiyor.
    select m.id, (select merkez_id from hedef),
           (select sube_id <> merkez_id from hedef),
           m.ad, m.content_type, m.boyut
      from merkez m
     where not exists (select 1 from kendi)
$$;

comment on function public.fn_sube_gorsel(integer, varchar) is
  'Subenin etkin logo/kase/imza dokumani (193); sube kendi gorselini yuklemediyse merkezinki doner.';

-- Görsel amaçları kod listesi (yükleme ekranındaki seçim).
insert into public.kod_liste (kod, ad)
select 'sube.gorsel_amac', 'Firma Görseli Türü'
 where not exists (select 1 from public.kod_liste where kod = 'sube.gorsel_amac');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.sira, 1
  from (values (1, 'Logo', 10), (2, 'Kaşe', 20), (3, 'İmza', 30),
               (4, 'Antet', 40)) as v(deger, ad, sira)
  join public.kod_liste l on l.kod = 'sube.gorsel_amac'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

do $$
begin
    raise notice '193 tamam: sube kase/imza bayraklari + antet sablonu, fn_sube_gorsel (dokuman kaynak=sube).';
end $$;
