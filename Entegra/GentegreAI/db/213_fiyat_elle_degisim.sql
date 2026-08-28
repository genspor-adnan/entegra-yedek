-- ============================================================================
--  Gentegre AI — FIYAT ELLE DEGISINCE MANUEL + CARPAN GERI HESABI
--  213_fiyat_elle_degisim.sql
--
--  Kullanici kurali: "fiyat ekranina girip direkt fiyati degistim - yazim
--  Manuel olmali ve carpan ona gore hesaplanmalidir."
--
--  Tetik v3: 212'deki iki dalin yanina fiyat dali eklendi.
--   - CARPAN degisti  -> Manuel, fiyat = taban_fiyat x carpan (212).
--   - FIYAT  degisti  -> Manuel; ZINCIRLI satirda (taban_liste_id dolu,
--     taban_fiyat > 0) carpan = fiyat / taban_fiyat (6 hane). Koksuz/manuel
--     listede carpan anlamsiz - dokunulmaz. Ikisi birden degistiyse carpan
--     dali oncelikli (web zaten tutarli cift gonderir).
--   - Yazim MANUEL -> HESAP -> kuraldan tam tazeleme (212).
--  Ayni kurallar ekranda GenForm.fiyatSatirKurali'nda; log icin fiyat/yazim/
--  carpan birlikte gider, tetik son otorite.
-- ============================================================================

create or replace function public.fn_sls_carpan_manuel()
returns trigger language plpgsql
as $$
declare
    v record;
begin
    if new.uretim_tarihi is distinct from old.uretim_tarihi then
        return new;   -- uretimin yazisi, kullanici duzenlemesi degil
    end if;

    -- 1) MANUEL -> HESAP: fiyat basligin kuralindan yeniden cozulur (taban
    --    listedeki GUNCEL fiyat), izler tazelenir. p_ezme = false: satirin
    --    eski manuel carpani kural sayilmasin.
    if old.yazim = 1 and new.yazim = 2 then
        select * into v from public.fn_fiyat_listesi_fiyat(
            new.liste_id, new.stok_id, new.hizmet_id, 0, false, false);
        if v.fiyat is not null and v.fiyat > 0 then
            new.fiyat          := v.fiyat;
            new.taban_fiyat    := coalesce(v.taban, v.fiyat);
            new.carpan         := v.carpan_kullanilan;
            new.taban_satir_id := v.kaynak_satir_id;
            new.taban_liste_id := (select fl.taban_liste_id
                                     from public.fiyat_listesi fl
                                    where fl.id = new.liste_id);
        end if;
        return new;
    end if;

    -- 2) CARPAN degisti: satir MANUEL olur, fiyat = taban_fiyat x yeni carpan
    --    (taban_fiyat DEGISMEZ; yuvarlama satirdan, bossa basliktan).
    if new.carpan is distinct from old.carpan then
        new.yazim := 1;
        if new.carpan is not null and new.carpan > 0
           and coalesce(new.taban_fiyat, 0) > 0 then
            select public.fn_fiyat_yuvarla(new.taban_fiyat * new.carpan,
                       coalesce(new.yuvarlama, fl.yuvarlama),
                       coalesce(new.yuvarlama_birim, fl.yuvarlama_birim))
              into new.fiyat
              from public.fiyat_listesi fl
             where fl.id = new.liste_id;
        end if;
        return new;
    end if;

    -- 3) FIYAT elle degisti (213): satir MANUEL olur; zincirli satirda carpan
    --    fiyattan GERIYE hesaplanir, taban_fiyat degismez.
    if new.fiyat is distinct from old.fiyat then
        new.yazim := 1;
        if new.taban_liste_id is not null
           and coalesce(new.taban_fiyat, 0) > 0 and coalesce(new.fiyat, 0) > 0 then
            new.carpan := round(new.fiyat / new.taban_fiyat, 6);
        end if;
    end if;
    return new;
end $$;

do $$ begin
    raise notice '213 tamam: tetik v3 - fiyat elle degisince Manuel + carpan geri hesabi.';
end $$;
