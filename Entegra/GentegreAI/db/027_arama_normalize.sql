-- ============================================================================
--  Gentegre AI — Turkce arama normalizasyonu
--  027_arama_normalize.sql
--
--  SORUN (olculdu 19.08.2026): veritabani ICU 'tr-TR' locale ile kurulu oldugu
--    icin buyuk/kucuk harf katlamasi TURKCE kurallarla yapiliyor:
--        lower('GRANIT')                 -> 'granıt'   (noktasiz i!)
--        'GRANIT BILGISAYAR' ilike '%granit%' -> FALSE
--    Yani kullanici kucuk harfle arayinca HICBIR SEY BULAMIYORDU. Sozlesme §2.2
--    "icerir/baslar buyuk-kucuk harf duyarsiz calisir" diyor; ILIKE bu vaadi
--    Turkce locale'de karsilamiyor.
--
--  COZUM: aramaya ozel normalizasyon. Turkce harfler ASCII karsiligina cevrilir,
--    sonra "C" collation ile kucultulur:
--        'GRANIT'   -> 'granit'
--        'İLETIŞIM' -> 'iletisim'
--        'iletişim' -> 'iletisim'      (kullanici nasil yazarsa yazsin bulur)
--
--    Bu, Turk ERP kullanicisinin bekledigi davranistir: "istanbul", "İSTANBUL",
--    "Istanbul" ayni sonucu vermeli. Siralama HALA ICU tr-TR ile dogru yapilir -
--    normalizasyon yalniz ARAMA icin kullanilir.
--
--  NOT: LIKE/ILIKE non-deterministic collation'i desteklemedigi icin
--    "tr-TR-u-ks-level2" gibi bir case-insensitive collation cozum degildir.
-- ============================================================================
\set ON_ERROR_STOP on

create extension if not exists pg_trgm;

-- IMMUTABLE olmali: ifade uzerine indeks kurulacak.
create or replace function public.fn_ara_metin(p_metin text)
returns text
language sql immutable parallel safe as $$
    select lower(translate(coalesce(p_metin, ''),
                           'ÇĞİIÖŞÜçğıiöşü',
                           'CGIIOSUcgiiosu') collate "C")
$$;

comment on function public.fn_ara_metin(text) is
  'Arama normalizasyonu: Turkce harfleri ASCII''ye cevirip "C" collation ile kucultur. ICU tr-TR''de lower(''I'') = ''ı'' oldugu icin ILIKE tek basina yetmiyor.';

-- ----------------------------------------------------- arama indeksleri ----
-- Eski lower(...) tabanli trigram indeksleri artik kullanilmiyor (sorgu
--   fn_ara_metin uzerinden gidiyor); yenileri ayni kolonlar icin kurulur.
create index if not exists ix_taraf_unvan_ara
    on public.taraf using gin (public.fn_ara_metin(unvan) gin_trgm_ops);
create index if not exists ix_taraf_fatura_unvan_ara
    on public.taraf using gin (public.fn_ara_metin(fatura_unvan) gin_trgm_ops);
create index if not exists ix_taraf_kod_ara
    on public.taraf using gin (public.fn_ara_metin(kod) gin_trgm_ops);
create index if not exists ix_taraf_vkno_ara
    on public.taraf using gin (public.fn_ara_metin(vkno) gin_trgm_ops);

create index if not exists ix_stok_ad_ara
    on public.stok using gin (public.fn_ara_metin(ad) gin_trgm_ops);
create index if not exists ix_stok_kod_ara
    on public.stok using gin (public.fn_ara_metin(kod) gin_trgm_ops);

create index if not exists ix_hizmet_ad_ara
    on public.hizmet using gin (public.fn_ara_metin(ad) gin_trgm_ops);
create index if not exists ix_masraf_ad_ara
    on public.masraf using gin (public.fn_ara_metin(ad) gin_trgm_ops);

create index if not exists ix_belge_no_ara
    on public.belge using gin (public.fn_ara_metin(belge_no) gin_trgm_ops);
create index if not exists ix_belge_taraf_unvan_ara
    on public.belge using gin (public.fn_ara_metin(taraf_unvan) gin_trgm_ops);

create index if not exists ix_stok_barkod_ara
    on public.stok_barkod using gin (public.fn_ara_metin(barkod) gin_trgm_ops);

-- --------------------------------------------------------------- dogrulama ----
do $$
declare
    v_kucuk integer;
    v_buyuk integer;
    v_karisik integer;
begin
    select count(*) into v_kucuk   from public.taraf
     where public.fn_ara_metin(unvan) like '%' || public.fn_ara_metin('granit') || '%';
    select count(*) into v_buyuk   from public.taraf
     where public.fn_ara_metin(unvan) like '%' || public.fn_ara_metin('GRANIT') || '%';
    select count(*) into v_karisik from public.taraf
     where public.fn_ara_metin(unvan) like '%' || public.fn_ara_metin('İletişim') || '%';

    raise notice '027 tamam: "granit" % kayit, "GRANIT" % kayit (esit olmali), "İletişim" % kayit',
                 v_kucuk, v_buyuk, v_karisik;
end $$;
