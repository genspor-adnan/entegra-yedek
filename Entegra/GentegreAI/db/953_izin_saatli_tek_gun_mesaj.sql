-- =====================================================================
--  953_izin_saatli_tek_gun_mesaj.sql
--  Saatli İK izni TEK GÜNLÜKTÜR (950 ck_personel_izin_saat). Kontrol ihlali
--  kullanıcıya "check constraint" diye düşüyordu; gün tetiği önce anlaşılır
--  mesajla durdurur. Saatlerden yalnız biri girilmişse de aynı.
--  Idempotent.
-- =====================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_personel_izin_gun()
returns trigger
language plpgsql
as $$
declare
    v_dk integer;
begin
    if new.baslangic_tarihi is null or new.bitis_tarihi is null then return new; end if;
    if (nullif(new.saat_bas, '') is null) <> (nullif(new.saat_bit, '') is null) then
        raise exception 'Saatli izin için başlangıç ve bitiş saati birlikte girilmeli; gün boyu izin için ikisini de boş bırakın.'
            using errcode = 'GK422';
    end if;
    if nullif(new.saat_bas, '') is not null then
        if new.baslangic_tarihi <> new.bitis_tarihi then
            raise exception 'Saatli izin tek günlüktür - başlangıç ve bitiş tarihi aynı olmalı. Birden çok gün için saatleri boş bırakın.'
                using errcode = 'GK422';
        end if;
        if new.saat_bas >= new.saat_bit then
            raise exception 'İzin bitiş saati başlangıçtan sonra olmalı.' using errcode = 'GK422';
        end if;
        v_dk := (extract(epoch from (new.saat_bit::time - new.saat_bas::time)) / 60)::int;
        new.gun := case when v_dk <= 270 then 0.5 else 1 end;
    else
        new.gun := public.fn_izin_gun(new.baslangic_tarihi, new.bitis_tarihi,
                                      coalesce(new.is_gunu, 0)::smallint, new.sube_id);
    end if;
    return new;
end $$;

do $$
begin
    raise notice '953 tamam: saatli izin kuralları anlaşılır mesajla.';
end $$;
