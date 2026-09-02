-- 347: SONOMED işlem listesinden RADYOLOJİ kategori ağacı + hizmet bağlama.
--
-- Kullanıcı: "Excel'deki Sonomed işlem fiyat listesinde en üst kod RAD >
-- alt kod OZELKOD > alt kod MUHKODU olarak hizmet kategoriye ekle, sonra bu
-- kategori ID'yi hizmet listesinde Kategori'ye güncelle."
--
-- KAYNAK: `Dosya/SONOMED ISLEM-FIYAT LISTESI.xlsx` → ISLEMADI sayfası
-- (KOD · ISLEMADI · TUR · OZELKOD · MUHKODU) CSV'ye çıkarılıp `stg_sonomed`
-- tablosuna yüklenir:
--     copy stg_sonomed from '/tmp/sonomed.csv' with (format csv, header true);
-- Bu dosya stg tablosu YOKSA sessizce atlar - müşteri kurulumunda çalışsa da
-- hata vermez.
--
-- ÜÇ SEVİYE: RAD (kök) → OZELKOD → MUHKODU. Ara seviye BOŞSA atlanır ve
-- hizmet bir üst seviyeye bağlanır: boş kodla "(boş)" adında kategori açmak
-- ağacı kirletirdi. Aynı ad iki farklı üst altında olabildiği için kategori
-- kodu YOL olarak üretilir (RAD · RAD-BT · RAD-BT-BT Kontrast).
--
-- Kategori türü 2 (hizmet, 346): bu ağaç hizmet listesinde kullanılacak.
\set ON_ERROR_STOP on

-- Yol kodu 30 karakteri aşabiliyor ("RAD-BTA-BT Koroner Angio"). Kolon tipini
--   değiştirmek için ona bağlı görünüm önce düşürülür, sonra AYNEN kurulur
--   (PG "cannot alter type of a column used by a view" der).
drop view if exists public.v_kategori_lookup;

alter table public.kategori alter column kod type varchar(80);

create view public.v_kategori_lookup as
with recursive agac as (
    select k.id, k.aktif,
           case when k.kod::text = '' then k.ad::text
                else (k.kod::text || ' - ') || k.ad::text end as yol,
           1 as derinlik
      from public.kategori k
     where k.ust_id is null
    union all
    select k.id, k.aktif,
           (a.yol || ' > ') ||
           case when k.kod::text = '' then k.ad::text
                else (k.kod::text || ' - ') || k.ad::text end,
           a.derinlik + 1
      from public.kategori k
      join agac a on a.id = k.ust_id
     where a.derinlik < 20
)
select id, yol::varchar(400) as ad, aktif from agac;

comment on view public.v_kategori_lookup is
  'Kategori secim listesi: kok > alt yolu tek metinde (270); kod alani 80 (347).';

do $$
declare
    v_kok   integer;
    v_ozel  integer;
    v_muh   integer;
    r       record;
    v_adet  integer := 0;
begin
    if to_regclass('public.stg_sonomed') is null then
        raise notice '347 atlandi: stg_sonomed yok (Excel yuklenmemis).';
        return;
    end if;

    -- ------------------------------------------------------------- kök ----
    select id into v_kok from public.kategori where kod = 'RAD';
    if v_kok is null then
        insert into public.kategori (kod, ad, tur, aktif)
        values ('RAD', 'Radyoloji', 2, 1) returning id into v_kok;
    else
        update public.kategori set tur = 2 where id = v_kok;
    end if;

    -- --------------------------------------------------- OZELKOD seviyesi -
    for r in select distinct btrim(ozel) as ozel
               from public.stg_sonomed
              where tur = 'RAD' and coalesce(btrim(ozel), '') <> ''
              order by 1
    loop
        select id into v_ozel from public.kategori where kod = 'RAD-' || r.ozel;
        if v_ozel is null then
            insert into public.kategori (kod, ad, ust_id, tur, aktif)
            values ('RAD-' || r.ozel, r.ozel, v_kok, 2, 1);
        else
            update public.kategori set ust_id = v_kok, tur = 2 where id = v_ozel;
        end if;
    end loop;

    -- --------------------------------------------------- MUHKODU seviyesi -
    for r in select distinct btrim(ozel) as ozel, btrim(muh) as muh
               from public.stg_sonomed
              where tur = 'RAD'
                and coalesce(btrim(ozel), '') <> '' and coalesce(btrim(muh), '') <> ''
              order by 1, 2
    loop
        select id into v_ozel from public.kategori where kod = 'RAD-' || r.ozel;
        select id into v_muh  from public.kategori where kod = 'RAD-' || r.ozel || '-' || r.muh;
        if v_muh is null then
            insert into public.kategori (kod, ad, ust_id, tur, aktif)
            values ('RAD-' || r.ozel || '-' || r.muh, r.muh, v_ozel, 2, 1);
        else
            update public.kategori set ust_id = v_ozel, tur = 2 where id = v_muh;
        end if;
    end loop;

    -- ------------------------------------------- hizmetin kategorisi ------
    -- EN DAR seviye kazanır: MUHKODU varsa o, yoksa OZELKOD, o da yoksa kök.
    update public.hizmet h
       set kategori = k.id
      from public.stg_sonomed s
      join public.kategori k
        on k.kod = case
                     when coalesce(btrim(s.ozel), '') = '' then 'RAD'
                     when coalesce(btrim(s.muh), '') = ''  then 'RAD-' || btrim(s.ozel)
                     else 'RAD-' || btrim(s.ozel) || '-' || btrim(s.muh)
                   end
     where s.tur = 'RAD' and h.kod = s.kod
       and h.kategori is distinct from k.id;

    get diagnostics v_adet = row_count;
    raise notice '347: % hizmetin kategorisi guncellendi.', v_adet;
end $$;

do $$
declare r record;
begin
    for r in select k.kod, k.ad,
                    (select count(*) from public.hizmet h where h.kategori = k.id) hizmet
               from public.kategori k
              where k.kod = 'RAD' or k.kod like 'RAD-%'
              order by k.kod loop
        raise notice '347: % (%) -> % hizmet', r.kod, r.ad, r.hizmet;
    end loop;
    raise notice '347 tamam: RAD > OZELKOD > MUHKODU agaci ve hizmet baglama.';
end $$;
