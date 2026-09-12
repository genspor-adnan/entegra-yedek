-- =====================================================================
--  596_tss_provizyon_farki_hastaya.sql
--  TSS: SİGORTANIN ONAYLAMADIĞI FARK HASTAYA KALIR.
--
--  Kullanıcı: "sigorta olduğu zaman her zaman provizyona gidiyor. ÖSS olduğu
--  zaman provizyondan kurumun ve hastanın ödeyeceği rakamlar dönüyor, ama TSS
--  ve karma olduğu zaman sadece kurumun ödeyeceği rakam dönüyor."
--
--  Yani TSS/Karma'da HASTANIN PAYI TÜRETİLİR: tarife bedelinden sigortanın
--  onayladığı tutar düşülür, kalan hastanındır.
--
--  Karma (rota 4) bunu zaten yapıyordu. TSS (rota 3) YAPMIYORDU: satırın
--  tutarını SGK + sigorta + ek katkı olarak YENİDEN KURUYORDU. Sigorta tarife
--  bedelinden azını onaylarsa (1.000 TL tarifeye 500 TL provizyon) aradaki
--  500 TL hiçbir kovaya düşmüyor, satırın tutarı kendiliğinden küçülüyordu -
--  hastadan istenmesi gereken fark sessizce siliniyordu.
--
--  Yeni davranış (rota 3):
--    · sigorta provizyonu YOKSA eskisi gibi: sigorta tarifenin tamamını öder.
--    · provizyon VARSA, tarife bedelini AŞAMAZ ve eksik kalan kısım
--      `hasta_provizyon` kovasına yazılır - satırın tutarı tarife + ek katkı
--      olarak korunur.
--  Ek katkı (hastane farkı) ve SGK katılım payı bundan ayrıdır, aynen durur.
-- =====================================================================
create or replace function public.fn_belge_satir_dagit(
    p_rota smallint,
    p_tutar numeric,
    p_sgk_liste numeric default 0,
    p_huv_liste numeric default 0,
    p_ek_katki numeric default 0,
    p_sgk_katilim numeric default 0,
    p_sgk_prov numeric default null,
    p_oss_prov numeric default null,
    p_varsayilan_karsilama numeric default 0)
returns table (tutar numeric, sgk numeric, oss numeric, hasta_provizyon numeric,
               hasta_ek_katki numeric, sgk_katilim_payi numeric)
language plpgsql immutable as $$
declare
    v_tutar   numeric := round(coalesce(p_tutar, 0), 2);
    v_sgkl    numeric := round(coalesce(p_sgk_liste, 0), 2);
    v_huv     numeric := round(coalesce(p_huv_liste, 0), 2);
    v_ek      numeric := round(coalesce(p_ek_katki, 0), 2);
    v_katilim numeric := round(coalesce(p_sgk_katilim, 0), 2);
    v_sgk     numeric := 0;
    v_oss     numeric := 0;
    v_hasta   numeric := 0;
    v_taban   numeric;
begin
    if p_rota = 1 then
        -- ÖZEL: hastanın kendi ödediği iş. Tamamı ek katkı kovasında.
        return query select v_tutar, 0::numeric, 0::numeric, 0::numeric, v_tutar, 0::numeric;

    elsif p_rota = 2 then
        -- ÖSS: liste fiyatı ana; sigorta karşılama oranı kadarını öder,
        --   kalanı hastanın provizyon payıdır. (Provizyon iki rakamı da
        --   döndürür: kurumun ödeyeceği ve hastanın ödeyeceği.)
        v_oss := round(coalesce(p_oss_prov,
                                v_tutar * coalesce(p_varsayilan_karsilama, 0) / 100), 2);
        v_oss := least(greatest(v_oss, 0), v_tutar);
        v_hasta := v_tutar - v_oss;
        return query select v_tutar, 0::numeric, v_oss, v_hasta, 0::numeric, 0::numeric;

    elsif p_rota = 3 then
        -- TSS: SGK SUT'u öder, tamamlayıcı sigorta TTB farkını üstlenir,
        --   hastane ek katkısı hastaya kalır.
        --
        --   PROVİZYON YALNIZ KURUMUN RAKAMINI DÖNDÜRÜR (596, kullanıcı):
        --   sigorta tarifenin tamamını onaylamazsa fark HASTANINDIR. Satırın
        --   tutarı tarife + ek katkı olarak korunur; eksik onay satırı
        --   küçültmez, hasta provizyon kovasına düşer.
        v_sgk := round(coalesce(p_sgk_prov, v_sgkl), 2);
        if p_oss_prov is null then
            v_oss   := v_huv;
            v_hasta := 0;
        else
            v_oss   := least(greatest(round(p_oss_prov, 2), 0), v_huv);
            v_hasta := v_huv - v_oss;
        end if;
        v_tutar := round(v_sgk + v_huv + v_ek, 2);
        return query select v_tutar, v_sgk, v_oss, v_hasta, v_ek, v_katilim;

    elsif p_rota = 4 then
        -- KARMA: TTB ana tutar. SGK SUT kadarını öder; tamamlayıcı poliçe
        --   kalanın onayladığı kadarını, artan hastaya kalır.
        v_tutar := case when v_huv > 0 then v_huv else v_tutar end;
        v_sgk := least(round(coalesce(p_sgk_prov, v_sgkl), 2), v_tutar);
        v_taban := v_tutar - v_sgk;
        v_oss := least(round(coalesce(p_oss_prov, v_taban), 2), v_taban);
        v_hasta := v_tutar - v_sgk - v_oss;
        return query select v_tutar, v_sgk, v_oss, v_hasta, 0::numeric, v_katilim;

    else
        -- SGK: SUT bedeli + hastane ek katkısı. Satır tutarı ikisinin toplamı.
        v_sgk := round(coalesce(p_sgk_prov, v_sgkl), 2);
        v_tutar := round(v_sgk + v_ek, 2);
        return query select v_tutar, v_sgk, 0::numeric, 0::numeric, v_ek, v_katilim;
    end if;
end $$;
