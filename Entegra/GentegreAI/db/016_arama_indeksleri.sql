-- ============================================================================
--  Gentegre AI — Faz 1 / F0-01 destegi
--  016_arama_indeksleri.sql  —  "icerir" / "baslar" aramalari icin trigram indeksleri
--
--  NEDEN: Liste sozlesmesi (dokuman/01_API_SOZLESMELERI.md §2.2) "icerir" ve
--    "baslar" operatorlerini sabit listeye koyuyor; performans butcesi 25.000
--    kayitta < 1,2 sn. Duz btree indeksi bu islerde CALISMAZ:
--      * lower(x) like '%aranan%'  -> btree hicbir sekilde kullanamaz
--      * lower(x) like 'aranan%'   -> ancak text_pattern_ops ile, o da ICU
--        collation'li kolonlarda ek kosul ister
--    Olculdu: 2.715 satirlik taraf tablosunda bile plan "Seq Scan" idi.
--    pg_trgm + GIN her iki kalibi da (ic ice ve onek) indeksli hale getirir.
--
--  Ayrica: 'icerir' aramasi Turkce buyuk/kucuk harf duyarsiz olmali; indeks
--    lower() ifadesi uzerine kurulur, sorgu da lower() ile gelir.
-- ============================================================================
\set ON_ERROR_STOP on

create extension if not exists pg_trgm;

-- taraf: unvan + fatura_unvan + kod
create index if not exists ix_taraf_unvan_trgm
    on public.taraf using gin (lower(unvan) gin_trgm_ops);
create index if not exists ix_taraf_fatura_unvan_trgm
    on public.taraf using gin (lower(fatura_unvan) gin_trgm_ops)
    where fatura_unvan is not null;
create index if not exists ix_taraf_kod_trgm
    on public.taraf using gin (lower(kod) gin_trgm_ops);

-- stok: ad + kod + urun_no
create index if not exists ix_stok_ad_trgm  on public.stok using gin (lower(ad) gin_trgm_ops);
create index if not exists ix_stok_kod_trgm on public.stok using gin (lower(kod) gin_trgm_ops);

-- hizmet / masraf
create index if not exists ix_hizmet_ad_trgm on public.hizmet using gin (lower(ad) gin_trgm_ops);
create index if not exists ix_masraf_ad_trgm on public.masraf using gin (lower(ad) gin_trgm_ops);

-- belge: belge no ve belgeye yazilan unvan (liste ekraninda en cok aranan iki alan)
create index if not exists ix_belge_no_trgm
    on public.belge using gin (lower(belge_no) gin_trgm_ops) where belge_no <> '';
create index if not exists ix_belge_taraf_unvan_trgm
    on public.belge using gin (lower(taraf_unvan) gin_trgm_ops) where taraf_unvan <> '';

-- barkod tam eslesme zaten ux_stok_barkod ile hizli; onek aramasi icin trigram
create index if not exists ix_stok_barkod_trgm
    on public.stok_barkod using gin (lower(barkod) gin_trgm_ops);

analyze public.taraf;
analyze public.stok;
analyze public.belge;
