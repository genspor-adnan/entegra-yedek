-- ============================================================================
--  Gentegre AI — KAPANMA DURUMU: BELGENIN KENDI SATIRI DEGISINCE DE TAZELE
--  191_kapanma_tazele.sql
--
--  Kullanici: "sipariş listesinde 1 satır vardı, dönüştürdüm, kapandı; tekrar
--  açıp yeni satır ekleyemedim. Eklersem 1 kapalı 1 açık olduğu için KISMİ
--  görünmeli."
--
--  Iki ayri eksik vardi:
--    1) Duzenleme KILIDI: kapanma_durum > 0 olan belge hic acilmiyordu.
--       (Sunucu tarafinda cozuldu: siparis duzenlenebilir, DONUSMUS satirlar
--        korunur - hedef belge onlara bagli.)
--    2) Bu dosya: kapanma_durum yalnizca HEDEF satir eklenince (kaynak_tur=30)
--       tazeleniyordu. Belgenin KENDI satiri eklenince/silinince durum eski
--       kaliyordu - kapali siparise yeni satir girilse bile "Kapandı" gorunurdu.
-- ============================================================================
\set ON_ERROR_STOP on

-- Belgenin kapanma durumunu satirlarindan yeniden hesapla.
create or replace function public.fn_belge_kapanma_tazele(p_belge_id integer)
returns void language plpgsql as $$
begin
    if coalesce(p_belge_id, 0) = 0 then return; end if;

    update public.belge b
       set kapanma_durum = x.durum
      from (select case
                     when count(*) = 0                                            then 0
                     when sum(case when s.kalan_miktar > 0 then 1 else 0 end) = 0 then 2
                     when sum(s.kapatilan_miktar) > 0                             then 1
                     else 0
                   end as durum
              from public.belge_satir s where s.belge_id = p_belge_id) x
     where b.id = p_belge_id
       and b.kapanma_durum is distinct from x.durum;
end $$;

comment on function public.fn_belge_kapanma_tazele(integer) is
  'Belgenin kapanma durumunu (0 acik / 1 kismi / 2 kapandi) satirlarindan yeniden hesaplar (191).';

-- Tetikleyici: hem KAYNAK satirin sayacini hem BELGENIN KENDI durumunu tazeler.
create or replace function public.fn_belge_satir_kapatma()
returns trigger language plpgsql as $$
begin
    -- 1) Hedef satir zinciri: kaynagin kapatilan_miktar'i.
    if tg_op in ('UPDATE', 'DELETE') and old.kaynak_tur = 30 then
        perform public.fn_belge_satir_kapatma_tazele(old.kaynak_id);
    end if;
    if tg_op in ('INSERT', 'UPDATE') and new.kaynak_tur = 30 then
        perform public.fn_belge_satir_kapatma_tazele(new.kaynak_id);
    end if;

    -- 2) BELGENIN KENDI durumu: satir eklendi/silindi/miktari degisti (191).
    --    Kapali siparise yeni satir girilince belge KISMI'ye donmeli.
    if tg_op in ('INSERT', 'UPDATE') then
        perform public.fn_belge_kapanma_tazele(new.belge_id);
    end if;
    if tg_op in ('UPDATE', 'DELETE') then
        perform public.fn_belge_kapanma_tazele(old.belge_id);
    end if;

    return null;
end $$;

-- INSERT/DELETE tetikleyicileri zaten var; UPDATE'i miktar disinda
--   kapatilan_miktar degisiminde de calistir (kalan_miktar ondan turuyor).
drop trigger if exists trg_belge_satir_kapatma_u on public.belge_satir;
create trigger trg_belge_satir_kapatma_u
    after update of miktar, kaynak_id, kaynak_tur, kapatilan_miktar
    on public.belge_satir
    for each row execute function public.fn_belge_satir_kapatma();

-- Mevcut veriyi bir kez hizala (yanlis "kapandi" kalmis belgeler icin).
do $$
declare v_degisen integer;
begin
    with x as (
        select s.belge_id,
               case when sum(case when s.kalan_miktar > 0 then 1 else 0 end) = 0 then 2
                    when sum(coalesce(s.kapatilan_miktar, 0)) > 0                then 1
                    else 0 end as durum
          from public.belge_satir s group by s.belge_id)
    update public.belge b set kapanma_durum = x.durum
      from x where x.belge_id = b.id and b.kapanma_durum is distinct from x.durum;
    get diagnostics v_degisen = row_count;
    raise notice '191 tamam: kapanma durumu belgenin kendi satirinda da tazeleniyor; % belge duzeltildi.', v_degisen;
end $$;
