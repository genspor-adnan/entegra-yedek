-- 281: TAHAKKUK DA MUHASEBE FİŞİ ÜRETMEZ (kullanıcı: "tahakkuka muhasebe fişi
-- istemiyorum").
--
-- 280'de tahakkuk (13/17) hariç tutulmuştu; karar değişti. Tahakkuk da
-- faturaya dönüşen bir ara belgedir - fişi faturada kesilir, ikisi birden
-- fişlenirse aynı tutar mizana iki kez girer.
--
-- Ayrıca tür listesi 280'de İKİ fonksiyonda ayrı ayrı yazılıydı; biri
-- güncellenip öteki unutulursa kayıt yolu ile toplu fişleme ayrışırdı. Liste
-- artık YALNIZ fn_belge_fis_turu_uygun'da; fn_belge_fis_uretilsin onu çağırır.

create or replace function public.fn_belge_fis_turu_uygun(p_tur integer)
returns boolean
language sql immutable as $$
    -- Fişlenmeyen (mali sonuç faturada doğan) belgeler:
    --   9/19 sipariş · 18 teklif · 105 talep · 10/14 irsaliye ·
    --   109/119 konsinye · 20 transfer · 13/17 tahakkuk · 30 eski başvuru.
    select coalesce(p_tur, 0)
           not in (9, 10, 13, 14, 17, 18, 19, 20, 30, 105, 109, 119);
$$;

comment on function public.fn_belge_fis_turu_uygun(integer) is
  'Tür muhasebe fişi üretir mi (280/281). Fişlenen türler: fatura, fiş, gider pusulası, üretim, stok giriş/çıkış fişi.';

-- Tür listesi TEK YERDE: fişleme kararının iki kopyası ayrışmasın.
create or replace function public.fn_belge_fis_uretilsin(
    p_sube_id integer,
    p_tur     integer default null)
returns boolean
language sql stable as $$
    select public.fn_belge_fis_turu_uygun(p_tur)
       and coalesce((select ma.muhasebe_entegrasyon = 1 and ma.fis_uretim = 1
                       from public.fn_sube_mali(p_sube_id) ma), true)
       and coalesce((select deger from public.referans
                      where anahtar = 'muhasebe.otomatik_fis'), '1') <> '0'
$$;

-- ------------------------------------------------- geçmişte kesilmiş fişler --
create table if not exists public.belge_fis_yedek_281 as
select b.id as belge_id, b.tur, b.belge_no, b.muhasebe_fis_id
  from public.belge b
 where coalesce(b.muhasebe_fis_id, 0) <> 0
   and not public.fn_belge_fis_turu_uygun(b.tur);

do $$
declare
  v_fis integer := 0;
begin
  create temporary table _fis_281 on commit drop as
  select distinct b.muhasebe_fis_id as id
    from public.belge b
   where coalesce(b.muhasebe_fis_id, 0) <> 0
     and not public.fn_belge_fis_turu_uygun(b.tur);

  update public.belge set muhasebe_fis_id = null
   where coalesce(muhasebe_fis_id, 0) <> 0
     and not public.fn_belge_fis_turu_uygun(tur);

  delete from public.muhasebe_fis_satir where fis_id in (select id from _fis_281);
  delete from public.muhasebe_fis      where id     in (select id from _fis_281);
  get diagnostics v_fis = row_count;

  raise notice '281: fislenmemesi gereken belgelerin % fisi silindi (yedek: belge_fis_yedek_281).', v_fis;
end $$;
