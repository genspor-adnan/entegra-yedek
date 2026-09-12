-- =====================================================================
--  599_provizyon_tutari_belirler.sql
--  TSS ve KARMA: TUTARI PROVİZYON BELİRLER, FARK HASTAYA YAZILMAZ.
--
--  Kullanıcı: "sigortanın ödeyeceği rakam her zaman provizyona gider ve
--  tutarı o belirler. ÖSS'de tutarı ikiye böleriz; TSS ve Karma'da
--  provizyondan gelen tutarı güncelleriz." Ve: "Karma'da hasta SGK
--  kullanılsın dediyse sadece 100 TL SGK katılım öder, onun dışında katkı
--  ödemez."
--
--  İKİ FARKLI İŞ:
--    · ÖSS (rota 2): provizyon HEM kurumun HEM hastanın rakamını döndürür -
--      satırın tutarı sabittir, ikiye BÖLÜNÜR (kurum + hasta).
--    · TSS (3) / KARMA (4): provizyon YALNIZ kurumun rakamını döndürür ve
--      satırın tutarını O BELİRLER - tarife bedeli yerine onaylanan tutar
--      geçer. Aradaki fark HASTAYA YAZILMAZ; hastanın payı yalnız SGK
--      katılım payıdır (ve TSS'de hastane ek katkısı).
--
--  596 TSS'de farkı hasta provizyon kovasına yazıyordu - bu dosya onu geri
--  alır ve aynı kuralı Karma'ya da taşır: Karma'da sigorta tarifenin
--  tamamını onaylamazsa satır küçülür, hastaya fark çıkmaz.
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
begin
    if p_rota = 1 then
        -- ÖZEL: hastanın kendi ödediği iş. Tamamı ek katkı kovasında.
        return query select v_tutar, 0::numeric, 0::numeric, 0::numeric, v_tutar, 0::numeric;

    elsif p_rota = 2 then
        -- ÖSS: TUTAR İKİYE BÖLÜNÜR. Provizyon kurumun ve hastanın rakamını
        --   birlikte döndürür; sigorta karşılama oranı kadarını öder, kalan
        --   hastanın provizyon payıdır. Satırın tutarı DEĞİŞMEZ.
        v_oss := round(coalesce(p_oss_prov,
                                v_tutar * coalesce(p_varsayilan_karsilama, 0) / 100), 2);
        v_oss := least(greatest(v_oss, 0), v_tutar);
        v_hasta := v_tutar - v_oss;
        return query select v_tutar, 0::numeric, v_oss, v_hasta, 0::numeric, 0::numeric;

    elsif p_rota = 3 then
        -- TSS: SGK SUT'u öder, tamamlayıcı sigorta tarife farkını üstlenir,
        --   hastane ek katkısı hastaya kalır.
        --
        --   TUTARI PROVİZYON BELİRLER (599): sigorta tarifeden azını
        --   onaylarsa satırın tutarı o kadar yazılır - fark HASTAYA GEÇMEZ.
        --   Hastanın payı yalnız ek katkı ve SGK katılım payıdır.
        v_sgk := round(coalesce(p_sgk_prov, v_sgkl), 2);
        v_oss := greatest(round(coalesce(p_oss_prov, v_huv), 2), 0);
        v_tutar := round(v_sgk + v_oss + v_ek, 2);
        return query select v_tutar, v_sgk, v_oss, 0::numeric, v_ek, v_katilim;

    elsif p_rota = 4 then
        -- KARMA: SGK SUT kadarını öder, tamamlayıcı poliçe kalanı üstlenir.
        --
        --   TUTARI PROVİZYON BELİRLER (599, kullanıcı: "Karma'da hasta sadece
        --   100 TL SGK katılım öder, onun dışında katkı ödemez"): provizyon
        --   yoksa sigorta tarifeden SGK payı düşülmüş kalanı öder; provizyon
        --   varsa satırın tutarı onaylanan rakama göre yazılır. Hastaya fark
        --   çıkmaz - tek ödediği SGK katılım payıdır (ciro dışı emanet).
        v_sgk := round(coalesce(p_sgk_prov, v_sgkl), 2);
        v_oss := greatest(round(coalesce(p_oss_prov, v_huv - v_sgk), 2), 0);
        v_tutar := round(v_sgk + v_oss, 2);
        return query select v_tutar, v_sgk, v_oss, 0::numeric, 0::numeric, v_katilim;

    else
        -- SGK: SUT bedeli + hastane ek katkısı. Satır tutarı ikisinin toplamı.
        v_sgk := round(coalesce(p_sgk_prov, v_sgkl), 2);
        v_tutar := round(v_sgk + v_ek, 2);
        return query select v_tutar, v_sgk, 0::numeric, 0::numeric, v_ek, v_katilim;
    end if;
end $$;
