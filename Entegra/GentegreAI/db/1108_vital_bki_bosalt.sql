-- ============================================================================
--  1108_vital_bki_bosalt.sql
--  BOY YA DA KİLO SİLİNİNCE VKİ DE SİLİNİR (kullanıcı 15.10.2026: "vital bulgulardan
--  boy kilo silinince vki de silinsin").
--
--  463'teki tetik boy ya da kilo yoksa satıra dokunmuyordu: boy/kilo silinen ölçümde
--  eski VKİ kalıyor, ekranda ve e-Nabız'da geçersiz bir değer görünüyordu. VKİ girilen
--  bir değer değil (kartta yazılamaz), boy ve kilodan hesaplanır - ikisinden biri yoksa
--  VKİ de yoktur.
--
--  Yalnız tetik değişir. Mevcut satırlara dokunulmaz: boy/kilosu olmayan ama VKİ'si olan
--  eski kayıt (aktarım vb.) bilerek girilmiş olabilir; satır bir sonraki değişiklikte
--  tetikten geçince düzelir. Tekrar çalıştırılabilir.
-- ============================================================================

create or replace function public.tg_muayene_vital_bki()
returns trigger language plpgsql as $$
declare
    v_boy numeric;
begin
    v_boy := coalesce(new.boy_cm, 0);
    if v_boy <= 0 or coalesce(new.kilo_kg, 0) <= 0 then
        -- 1108: boy ya da kilo SİLİNDİYSE (güncellemede önceden vardı) VKİ de silinir.
        if tg_op = 'UPDATE'
           and (coalesce(old.boy_cm, 0) > 0 and v_boy <= 0
                or coalesce(old.kilo_kg, 0) > 0 and coalesce(new.kilo_kg, 0) <= 0) then
            new.bki := null;
        end if;
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

comment on function public.tg_muayene_vital_bki() is
  '463 + 1108: BKI boy ve kilodan hesaplanir; guncellemede boy ya da kilo silinirse BKI de silinir.';
