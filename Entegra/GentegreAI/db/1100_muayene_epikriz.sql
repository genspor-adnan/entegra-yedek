-- =============================================================================
--  1100  MUAYENE EPİKRİZİ - yatan hastanın epikriz tablosu muayeneye de bağlanır
--
--  Mockup Ekranlar/Muayene/muayene_karti_v7.html; kullanıcı kararları 14.10.2026:
--    - epikriz AYRI KAYIT olarak tutulur (imzalanan metin muayene sonradan
--      değişse de aynı kalır; hastaya / sevk kurumuna giden budur),
--    - sekmeli kartta Epikriz sekmesi YALNIZ İSTENİNCE açılır.
--
--  İKİNCİ TABLO AÇILMADI: 695'teki public.epikriz yatış başına tek satırdı;
--  aynı tablo bir muayeneye ya da bir yatışa bağlanır (ikisinden YALNIZ biri).
--  İki ayrı epikriz tablosu, "hastanın epikrizleri" sorusunu iki yerden
--  sorulur hâle getirirdi.
--
--  TANI KOLONU: yatış epikrizinde tanı yatış kaydından okunuyordu; muayene
--  epikrizinde hekim tanı cümlesini düzeltebilmeli (kodlu tanı muayenede kalır).
-- =============================================================================

alter table public.epikriz alter column yatis_id drop not null;

alter table public.epikriz
    add column if not exists muayene_id integer references public.muayene (id) on delete cascade,
    add column if not exists tani text not null default '';

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'ck_epikriz_tek_baglanti') then
        alter table public.epikriz
            add constraint ck_epikriz_tek_baglanti
            check ((yatis_id is null) <> (muayene_id is null));
    end if;
end $$;

-- Muayene başına TEK epikriz (yatıştaki kuralın aynısı: iki epikriz, iki çıkış özeti).
create unique index if not exists ux_epikriz_muayene on public.epikriz (muayene_id) where muayene_id is not null;

comment on column public.epikriz.muayene_id is
    'Muayene epikrizi (1100). yatis_id ile ikisinden yalnız biri dolu.';
comment on column public.epikriz.tani is
    'Epikrizdeki tanı metni (1100, muayene epikrizi) - kodlu tanı muayenenin tani satırlarında.';
