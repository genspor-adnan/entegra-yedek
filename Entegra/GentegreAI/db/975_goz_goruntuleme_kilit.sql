-- 975 GÖZ GÖRÜNTÜLEME KİLİTLERİ (974'ün sunucu tarafı; kart / cihaz / uç hangi yoldan gelirse gelsin)
--   * Ödenmemiş (serbest=0) istem çekilemez: durum 2+ / çekim zamanı / ölçüm satırı yazılamaz.
--   * Değerlendirilmiş (3) kaydın sonucu / yorumu / önerisi / ölçümleri değişmez.

create or replace function public.tg_goz_goruntuleme_kilit()
returns trigger language plpgsql as $fn$
begin
    if new.serbest = 0 and (new.durum >= 2 or new.cekim_zamani is not null) then
        raise exception 'İstem ödeme bekliyor: bankoda ücretlendirilip başvuru kaydedilmeden çekim yapılamaz.';
    end if;
    if tg_op = 'UPDATE' and old.durum = 3 and new.durum = 3
       and (new.sonuc is distinct from old.sonuc or new.degerlendirme is distinct from old.degerlendirme
            or new.oneri is distinct from old.oneri) then
        raise exception 'Değerlendirilmiş görüntüleme değiştirilemez.';
    end if;
    return new;
end $fn$;

drop trigger if exists trg_goz_goruntuleme_kilit on public.goz_goruntuleme;
create trigger trg_goz_goruntuleme_kilit before insert or update on public.goz_goruntuleme
    for each row execute function public.tg_goz_goruntuleme_kilit();

create or replace function public.tg_goz_goruntuleme_olcum_kilit()
returns trigger language plpgsql as $fn$
declare v_durum smallint; v_serbest smallint;
begin
    select durum, serbest into v_durum, v_serbest from public.goz_goruntuleme
     where id = coalesce(new.goruntuleme_id, old.goruntuleme_id);
    if v_serbest = 0 then
        raise exception 'İstem ödeme bekliyor: ölçüm girilemez.';
    end if;
    if v_durum = 3 then
        raise exception 'Değerlendirilmiş görüntülemenin ölçümleri değiştirilemez.';
    end if;
    return coalesce(new, old);
end $fn$;

drop trigger if exists trg_goz_goruntuleme_olcum_kilit on public.goz_goruntuleme_olcum;
create trigger trg_goz_goruntuleme_olcum_kilit before insert or update or delete on public.goz_goruntuleme_olcum
    for each row execute function public.tg_goz_goruntuleme_olcum_kilit();
