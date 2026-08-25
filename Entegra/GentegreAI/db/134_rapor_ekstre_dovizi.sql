-- ============================================================================
--  Gentegre AI — RAPOR VE EKSTRE DOVIZI
--  134_rapor_ekstre_dovizi.sql
--
--  Belgede IKI ayri doviz sorusu var (kullanici):
--
--    RAPOR DOVIZI  - belge hangi para biriminde duzenlendi (tutarlar bu
--                    birimde okunur). Kolon zaten vardi (`rapor_dovizi`) ama
--                    gocten SEMBOL geliyordu ('$', '€') ve kart uzerinden
--                    degistirilemiyordu. ISO koda cevrilir.
--    EKSTRE DOVIZI - cari hesaba HANGI dovizde islenecek. Cogu belgede rapor
--                    doviziyle aynidir; ama doviz kesilip yerel parada takip
--                    edilen (ya da tersi) musteriler icin ayri tutulmali -
--                    yoksa ekstre iki para birimine bolunur ve mutabakat
--                    yapilamaz. Secenekler: rapor dovizi + yerel para.
--
--  Kur belgede zaten var (`doviz_kuru`): rapor dovizinden yerel paraya cevrim.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge
    add column if not exists ekstre_dovizi varchar(6) not null default '';

comment on column public.belge.rapor_dovizi is
  'Belgenin duzenlendigi para birimi (134, ISO kod). Tutarlar bu birimde.';
comment on column public.belge.ekstre_dovizi is
  'Cari hesaba hangi dovizde islenecegi (134). Bos ise rapor dovizi kullanilir.';

-- Gocten gelen semboller ISO koda: '$' -> USD, '€' -> EUR, bos -> belge dovizi.
update public.belge
   set rapor_dovizi = case
         when btrim(coalesce(rapor_dovizi, '')) in ('$', 'USD') then 'USD'
         when btrim(coalesce(rapor_dovizi, '')) in ('€', 'EUR') then 'EUR'
         when btrim(coalesce(rapor_dovizi, '')) = ''            then
              coalesce(nullif(btrim(belge_dovizi), ''), public.fn_yerel_para())
         else btrim(rapor_dovizi)
       end
 where btrim(coalesce(rapor_dovizi, '')) not in ('TL', 'USD', 'EUR', 'GBP');

-- Ekstre dovizi bos olan eski kayitlar: rapor doviziyle ayni sayilir (bos
--   birakmak da ayni anlama gelir, yine de acik yazmak raporu kolaylastirir).
update public.belge
   set ekstre_dovizi = rapor_dovizi
 where btrim(coalesce(ekstre_dovizi, '')) = ''
   and btrim(coalesce(rapor_dovizi, '')) <> '';

do $$
declare v_rapor text; v_bos integer;
begin
    select string_agg(distinct rapor_dovizi, ', ') into v_rapor from public.belge;
    select count(*) into v_bos from public.belge where btrim(coalesce(ekstre_dovizi, '')) = '';
    raise notice '134 tamam: rapor dovizleri [%], ekstre dovizi bos %', v_rapor, v_bos;
end $$;
