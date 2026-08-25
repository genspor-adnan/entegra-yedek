-- ============================================================================
--  Gentegre AI — stok_barkod TABLOSU KALDIRILIYOR
--  145_stok_barkod_sil.sql
--
--  144'te barkodlar `stok_birim.barkod` alanina tasindi ve kart "Birim/Barkod"
--  sekmesi kalkti; tablo yalnizca veri olarak duruyordu. Kullanici silinmesini
--  istedi.
--
--  ONCE DOGRULAMA, SONRA SILME: tabloyu dusurmeden once HER barkodun birim
--  tarafinda karsiligi oldugu kontrol edilir. Bir tanesi bile eksikse goc
--  HATA VERIR ve tablo yerinde kalir - "sildim ama veri gitmisti" durumu
--  olusamaz. (144 iki kez calistirilmis, yarim kalmis ya da arada elle kayit
--  eklenmis olabilir; guvence buradan gelir.)
--
--  YEDEK: silmeden once tam kopya `stok_barkod_yedek_145` tablosuna alinir.
--  Geri donmek gerekirse veri oradadir; yedek tablo istenirse elle silinir.
-- ============================================================================
\set ON_ERROR_STOP on

begin;

-- 1) Yedek (tam kopya - id dahil).
create table if not exists public.stok_barkod_yedek_145 as
select * from public.stok_barkod;

-- 2) DOGRULAMA: birim tarafinda karsiligi olmayan barkod var mi?
do $$
declare v_eksik integer;
begin
    select count(*) into v_eksik
      from public.stok_barkod b
     where btrim(coalesce(b.barkod, '')) <> ''
       and not exists (
             select 1 from public.stok_birim sb
              where sb.stok_id = b.stok_id
                and btrim(sb.barkod) = btrim(b.barkod));
    if v_eksik > 0 then
        raise exception
            '145 DURDU: % barkodun ambalaj birimi tarafinda karsiligi yok. Once 144 gocunu calistirin.',
            v_eksik;
    end if;
end $$;

-- 3) Silme. Tabloya baglanan indeksler/FK'ler birlikte duser.
drop table if exists public.stok_barkod;

commit;

do $$
declare v_yedek integer; v_birim integer;
begin
    select count(*) into v_yedek from public.stok_barkod_yedek_145;
    select count(*) into v_birim from public.stok_birim where btrim(barkod) <> '';
    raise notice '145 tamam: stok_barkod dusuruldu (% satir yedekte), birimde % barkod duruyor.',
                 v_yedek, v_birim;
end $$;
