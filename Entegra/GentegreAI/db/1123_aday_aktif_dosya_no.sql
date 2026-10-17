-- ============================================================================
--  1123_aday_aktif_dosya_no.sql
--  ADAY HASTA AKTİFE GEÇERKEN DOSYA NO (kullanıcı 17.10.2026: "randevudan başvuru aç dediğimde hasta
--  adaysa kimlik kaydı yaparken dosya no'yu da düzelt").
--
--  Aday hasta (266) hızlı açılır, dosya no'su CEP NUMARASIDIR (kartGovdesi kod = cep). Aday aday
--  olmaktan çıkınca (durum 2 -> başka) kodu hâlâ cep numarasıysa normal hasta dosya numarası verilir
--  (fn_hasta_dosya_no - ilk kayıttaki tetikle aynı kaynak). Elle değiştirilmiş kod korunur: yalnız
--  rakamları cep telefonununkiyle AYNI ve 10+ haneli kod değişir. Hangi uçtan aktif olursa olsun
--  (randevudan başvuru, hasta kartı) aynı kural.
--  Mevcut kayıtlara dokunulmaz (geriye dönük onarım yok). Tekrar çalıştırılabilir.
-- ============================================================================

create or replace function public.tg_taraf_aday_aktif_dosya_no()
returns trigger language plpgsql as $$
declare
    v_kod text := regexp_replace(coalesce(new.kod, ''), '[^0-9]', '', 'g');
begin
    if coalesce(new.grup, 0) <> 101 then return new; end if;
    if old.durum is distinct from 2 or new.durum = 2 then return new; end if;
    if new.kod is distinct from old.kod then return new; end if;      -- bu güncellemede elle verildi
    if length(v_kod) < 10
       or v_kod <> regexp_replace(coalesce(new.cep_tel, old.cep_tel, ''), '[^0-9]', '', 'g') then
        return new;                                                    -- kod cep numarası değil
    end if;
    new.kod := public.fn_hasta_dosya_no(coalesce(new.sube_id, 0));
    return new;
end $$;

drop trigger if exists tr_taraf_aday_aktif_dosya_no on public.taraf;
create trigger tr_taraf_aday_aktif_dosya_no before update of durum on public.taraf
    for each row execute function public.tg_taraf_aday_aktif_dosya_no();
