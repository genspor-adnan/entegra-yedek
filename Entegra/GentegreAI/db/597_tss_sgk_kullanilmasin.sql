-- =====================================================================
--  597_tss_sgk_kullanilmasin.sql
--  TSS'DE DE "SGK KULLANILMASIN" HAKKI.
--
--  Kullanıcı: "hasta SGK kullanılmasın deme hakkına sahip… TSS'de SGK
--  kullanılmasın check'i ekle."
--
--  Bu hak POLİÇENİN değil BAŞVURUNUN özelliğidir (aynı hasta ertesi hafta
--  SGK'yı kullanmak isteyebilir, poliçesi değişmez) - bu yüzden alt kurum kod
--  listesi ikiye bölünmedi, başvurudaki `sgk_kullan` işareti kullanılıyor.
--  İşaret şimdiye kadar yalnız KARMA poliçede (203) dikkate alınıyordu; TSS'de
--  (202) hastanın "SGK'ya yazdırmayın" demesinin ekranda karşılığı yoktu.
--
--  Yeni kural: TSS'de de işaret kalkarsa rota 2'ye (ÖSS) düşer - SGK payı
--  doğmaz, tarife bedelinin tamamı sigorta/hasta arasında bölünür. Varsayılan
--  DEĞİŞMEZ (`sgk_kullan` 1): işaret konmadıkça TSS eskisi gibi çalışır.
-- =====================================================================
create or replace function public.fn_dagilim_rota(
    p_tur smallint,
    p_alt_kurum smallint default 0,
    p_sgk_kullan smallint default 1)
returns smallint language sql immutable as $$
    select case
        when coalesce(p_tur, 1) = 1 then 1::smallint      -- Özel / hasta öder
        when p_tur = 3 then 5::smallint                   -- SGK
        when p_tur = 2 then case coalesce(p_alt_kurum, 201)
                                 -- TSS ve KARMA: hasta SGK'yı kullanmak
                                 --   istemezse iş ÖSS gibi yürür (597).
                                 when 202 then case when coalesce(p_sgk_kullan, 1) = 1
                                                    then 3::smallint else 2::smallint end
                                 when 203 then case when coalesce(p_sgk_kullan, 1) = 1
                                                    then 4::smallint else 2::smallint end
                                 else 2::smallint end     -- ÖSS
        else 1::smallint end;
$$;
