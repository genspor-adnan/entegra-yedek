-- ============================================================================
--  Gentegre AI — IZLEM SATIRINA DEPO
--  115_izlem_depo.sql
--
--  Lot hareketleri hangi DEPODA oldugunu tutmuyordu (goc semasi da tutmuyordu).
--  Sonuclari:
--    - Cikis belgesinde lot listesi stok GENELINDEN geliyordu: Ankara deposundan
--      satarken Merkez'deki lot da secilebiliyordu.
--    - Stok kartinda "her depoda o urunun izlemleri" gosterilemiyordu.
--
--  depo_id eklenir ve MEVCUT satirlar belgesinden geri doldurulur:
--    giris hareketi  -> belge satirinin GIRIS deposu
--    cikis hareketi  -> belge satirinin CIKIS deposu
--    transfer        -> donus_id dolu satir malin VARDIGI (giris) deposunda,
--                       digeri ciktigi depoda
--  Satirin deposu bossa belgenin basligindaki depo kullanilir.
--
--  Belgesi olmayan (elle acilmis / kaynagi kayip) satirlar NULL kalir: uydurma
--  depo yazmak, olmayan yerde stok gostermekten kotudur. Cikis lot listesi
--  depo suzgecinde NULL'lari da gosterir - aksi halde gocmus mal secilemez
--  hale gelir; kullanici lotu secince hareket dogru depoya yazilir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.stok_izleme
    add column if not exists depo_id integer references public.depo(id);

comment on column public.stok_izleme.depo_id is
  'Hareketin gerceklestigi depo (115). Gocmus/kaynagi olmayan satirlarda NULL.';

do $$
declare v_dolu integer; v_bos integer;
begin
    update public.stok_izleme i
       set depo_id = case
               when i.belge_tur = 20 and i.donus_id <> 0
                    then coalesce(s.giris_depo_id, b.giris_depo_id)
               when i.belge_tur in (14, 15, 16, 119, 4, 29, 105, 133, 20)
                    then coalesce(s.cikis_depo_id, b.cikis_depo_id)
               else coalesce(s.giris_depo_id, b.giris_depo_id)
           end
      from public.belge_satir s
      join public.belge b on b.id = s.belge_id
     where s.id = i.belge_satir_id
       and i.depo_id is null;

    get diagnostics v_dolu = row_count;
    select count(*) into v_bos from public.stok_izleme where depo_id is null;
    raise notice '115: % izlem satirina depo yazildi, % satir depo bilgisiz kaldi',
                 v_dolu, v_bos;
end $$;

-- Cikis lot listesi (stok + depo + kalani olanlar) ve stok kartindaki depo
--   bazli lot dokumu bu index'i kullanir.
create index if not exists ix_stok_izleme_stok_depo
    on public.stok_izleme (stok_id, depo_id) where kalan > 0;

-- Gorunume depo eklenir (114'te olusmustu; kolon SONA eklenir - create or
--   replace mevcut kolon sirasini degistirmeye izin vermez).
create or replace view public.v_belge_satir_izlem as
select i.id,
       i.belge_id,
       i.belge_satir_id,
       i.stok_id,
       i.seri_lot_id,
       l.lot_no,
       l.seri_no,
       case when l.uretim_tarihi in (timestamp '1899-12-31 00:00', timestamp '1990-01-01 00:00')
            then null else l.uretim_tarihi end as uretim_tarihi,
       case when l.son_kullanma_tarihi in (timestamp '1899-12-31 00:00', timestamp '1990-01-01 00:00')
            then null else l.son_kullanma_tarihi end as son_kullanma_tarihi,
       i.izlem_tur,
       i.belge_tur,
       i.durum,
       i.adet,
       i.kalan,
       i.depo_id
  from public.stok_izleme i
  join public.stok_seri_lot l on l.id = i.seri_lot_id;

do $$
declare v_depo integer;
begin
    select count(distinct depo_id) into v_depo from public.stok_izleme where depo_id is not null;
    raise notice '115 tamam: % farkli depoda izlem hareketi var', v_depo;
end $$;
