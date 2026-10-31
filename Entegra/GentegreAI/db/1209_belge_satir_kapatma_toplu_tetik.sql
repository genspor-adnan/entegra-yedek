\set ON_ERROR_STOP on
-- ============================================================================
--  1209 — K47: belge_satir kapanma tetiği satır yerine İFADE düzeyinde
--
--  Kod inceleme 30.10.2026 K47 (ölçüm: 500 satırlık tek INSERT'te 18 tetiğin
--  toplam 347 ms'sinin 160 ms'si trg_belge_satir_kapatma_i; DELETE'te 46 ms).
--  fn_belge_satir_kapatma her satırda fn_belge_kapanma_tazele(belge_id)'yi
--  çağırıyor, o da belgenin TÜM satırlarını topluyordu: n satırlık aktarım
--  n² iş. Aynı belge / aynı kaynak satır için bir kez hesaplamak yeter.
--
--  Üç satır tetiği kaldırılır; yerine geçiş tablolu (REFERENCING) üç ifade
--  tetiği gelir: etkilenen belge_id ve kaynak satır kümesi DISTINCT alınır,
--  tazeleme fonksiyonları (191 / 478, DEĞİŞMEDİ) küme başına bir kez çağrılır.
--  Davranış aynı: kaynak zinciri (kaynak_tur 30) + belgenin kendi kapanma
--  durumu; 191'in UPDATE sütun listesi fonksiyon içinde satır süzgeci olarak uygulanır.
--  Eski fn_belge_satir_kapatma() yerinde kalır (başka tetik bağlı değil).
-- ============================================================================
begin;

create or replace function public.fn_belge_satir_kapatma_toplu()
returns trigger language plpgsql as $$
declare
    r record;
begin
    -- Geçiş tablosu sütun listesiyle birleşemez: UPDATE'te 191'in sütun listesi
    --   (miktar, kaynak_id, kaynak_tur, kapatilan_miktar) burada satır bazında
    --   süzülür - başka sütun değişen satır (açıklama, fiyat…) iş üretmez.
    if tg_op = 'INSERT' then
        for r in select distinct kaynak_id from yeni
                  where kaynak_tur = 30 and coalesce(kaynak_id, 0) > 0
        loop perform public.fn_belge_satir_kapatma_tazele(r.kaynak_id); end loop;
        for r in select distinct belge_id from yeni
        loop perform public.fn_belge_kapanma_tazele(r.belge_id); end loop;

    elsif tg_op = 'DELETE' then
        for r in select distinct kaynak_id from eski
                  where kaynak_tur = 30 and coalesce(kaynak_id, 0) > 0
        loop perform public.fn_belge_satir_kapatma_tazele(r.kaynak_id); end loop;
        for r in select distinct belge_id from eski
        loop perform public.fn_belge_kapanma_tazele(r.belge_id); end loop;

    else
        for r in
            with d as (
                select y.belge_id as yb, e.belge_id as eb,
                       y.kaynak_id as yk, y.kaynak_tur as ykt, e.kaynak_id as ek, e.kaynak_tur as ekt
                  from yeni y join eski e on e.id = y.id
                 where y.miktar is distinct from e.miktar
                    or y.kaynak_id is distinct from e.kaynak_id
                    or y.kaynak_tur is distinct from e.kaynak_tur
                    or y.kapatilan_miktar is distinct from e.kapatilan_miktar
            )
            select distinct k from (
                select ek as k from d where ekt = 30 and coalesce(ek, 0) > 0
                union all
                select yk from d where ykt = 30 and coalesce(yk, 0) > 0
            ) x
        loop perform public.fn_belge_satir_kapatma_tazele(r.k); end loop;

        for r in
            select distinct b from (
                select y.belge_id as b from yeni y join eski e on e.id = y.id
                 where y.miktar is distinct from e.miktar or y.kaynak_id is distinct from e.kaynak_id
                    or y.kaynak_tur is distinct from e.kaynak_tur or y.kapatilan_miktar is distinct from e.kapatilan_miktar
                union all
                select e.belge_id from yeni y join eski e on e.id = y.id
                 where y.miktar is distinct from e.miktar or y.kaynak_id is distinct from e.kaynak_id
                    or y.kaynak_tur is distinct from e.kaynak_tur or y.kapatilan_miktar is distinct from e.kapatilan_miktar
            ) x
        loop perform public.fn_belge_kapanma_tazele(r.b); end loop;
    end if;
    return null;
end $$;

drop trigger if exists trg_belge_satir_kapatma_i on public.belge_satir;
drop trigger if exists trg_belge_satir_kapatma_u on public.belge_satir;
drop trigger if exists trg_belge_satir_kapatma_d on public.belge_satir;

create trigger trg_belge_satir_kapatma_i
    after insert on public.belge_satir
    referencing new table as yeni
    for each statement execute function public.fn_belge_satir_kapatma_toplu();

create trigger trg_belge_satir_kapatma_u
    after update on public.belge_satir
    referencing old table as eski new table as yeni
    for each statement execute function public.fn_belge_satir_kapatma_toplu();

create trigger trg_belge_satir_kapatma_d
    after delete on public.belge_satir
    referencing old table as eski
    for each statement execute function public.fn_belge_satir_kapatma_toplu();

commit;
