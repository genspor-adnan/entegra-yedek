-- =====================================================================
-- 463 - VİTAL: BOY + KİLO GİRİLİNCE BKİ HESAPLANIR
--
-- BKİ elle giriliyordu; hekim boy ve kiloyu yazıp BKİ kutusunu boş
-- bırakınca obezite değerlendirmesi ve ilaç dozu için gereken sayı
-- kayıtta hiç oluşmuyordu.
--
-- KURAL VERİTABANINDA: ölçüm üç yoldan girilebiliyor (muayene kartı, vital
-- ekranı, cihaz aktarımı). Formülü ekranlara yazmak, birinde güncellenip
-- ötekinde eski kalan üç ayrı kural demekti.
--
-- ELLE GİRİLEN DEĞER KORUNUR: hekim BKİ'yi kendisi yazdıysa (ya da düzeltti)
-- üzerine yazılmaz - yalnız BOŞ olan hesaplanır. Boy/kilo sonradan
-- DEĞİŞİRSE hesap yenilenir: eski boy/kiloya ait BKİ yanıltıcı olurdu.
-- =====================================================================

create or replace function public.tg_muayene_vital_bki()
returns trigger language plpgsql as $$
declare
    v_boy numeric;
begin
    v_boy := coalesce(new.boy_cm, 0);
    if v_boy <= 0 or coalesce(new.kilo_kg, 0) <= 0 then
        return new;
    end if;

    -- BOY METREYE: 100 cm altı ölçüm (bebek) da geçerli - alt sınır koymak
    --   pediatride kaydı bozardı.
    if coalesce(new.bki, 0) = 0
       or (tg_op = 'UPDATE' and (coalesce(old.boy_cm, 0) is distinct from v_boy
                                 or coalesce(old.kilo_kg, 0) is distinct from new.kilo_kg)
           and coalesce(old.bki, 0) = coalesce(new.bki, 0))
    then
        new.bki := round(new.kilo_kg / ((v_boy / 100.0) ^ 2), 1);
    end if;
    return new;
end $$;

drop trigger if exists tg_muayene_vital_bki on public.muayene_vital;
create trigger tg_muayene_vital_bki
    before insert or update of boy_cm, kilo_kg, bki on public.muayene_vital
    for each row execute function public.tg_muayene_vital_bki();

comment on function public.tg_muayene_vital_bki() is
    'Boy+kilo girilince BKI hesaplar; elle yazilan BKI korunur (463).';
