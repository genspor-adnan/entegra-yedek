-- ============================================================================
--  Gentegre AI — BELGE SILME: stok geri-alma guard'i duzeltildi
--  217_belge_sil_stok_guard.sql
--
--  BUG (teklif ekran testinde yakalandi, 216): fn_belge_sil HER belge turunde
--  "function public.fn_stok_durum_geri_al(integer) does not exist" ile
--  patliyordu. Guard'in bicimi yanlisti:
--
--      perform public.fn_stok_durum_geri_al(p_belge_id)
--        where exists (select 1 from pg_proc ... 'fn_stok_durum_geri_al');
--
--  WHERE satirlari suzer ama fonksiyon adi sorgu PLANLANIRKEN cozulur -
--  fonksiyon hic olmadigi icin exists'e sira gelmeden hata firlar. Niyet
--  ("varsa cagir, yoksa atla") DINAMIK EXECUTE ile gerceklesir: metin sorgu
--  ancak calistirilinca cozulur, if bloguna girilmezse hic cozulmez.
--
--  fn_stok_durum_geri_al bu kurulumda HIC yok - belge silindiginde stok
--  bakiyesi geri alinmiyor(du); stok hareketi uretmis belgelerin silinmesi
--  zaten fn_belge_silinebilir tarafindan engellendigi surece zararsiz.
--  Fonksiyon eklendiginde ayni guard onu otomatik cagiracak.
-- ============================================================================

create or replace function public.fn_belge_sil(p_belge_id integer, p_kullanici integer)
returns text language plpgsql
as $$
declare
    v_sebep  text;
    v_no     text;
    v_satir  integer;
begin
    v_sebep := public.fn_belge_silinebilir(p_belge_id);
    if v_sebep <> '' then
        raise exception '%', v_sebep;
    end if;

    select coalesce(nullif(btrim(belge_no), ''), '#' || p_belge_id::text)
      into v_no from public.belge where id = p_belge_id;

    -- Stok bakiyesi: satirlarin dustugu/yukseldigi miktar geri alinir (fonksiyon
    --   kuruluysa). Statik cagri + WHERE exists calismiyordu - plan zamani
    --   cozulup "does not exist" veriyordu (217); dinamik EXECUTE gec cozulur.
    if exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                where n.nspname = 'public' and p.proname = 'fn_stok_durum_geri_al') then
        execute 'select public.fn_stok_durum_geri_al($1)' using p_belge_id;
    end if;

    delete from public.mali_hareket where belge_id = p_belge_id;
    get diagnostics v_satir = row_count;

    delete from public.e_belge where belge_id = p_belge_id;
    delete from public.belge where id = p_belge_id;

    return format('"%s" silindi (%s cari hareketi kaldırıldı).', v_no, v_satir);
end $$;

do $$ begin
    raise notice '217 tamam: fn_belge_sil stok geri-alma guard''i dinamik EXECUTE oldu.';
end $$;
