-- ============================================================================
--  Gentegre AI — "Göz Hekimi" → "Göz Doktoru"
--  837_goz_doktoru_adi.sql
--
--  Kullanıcı: *"Göz Hekimi rename Göz Doktoru"*.
--
--  KOD `goz_hekimi` DEĞİŞMEZ: şablon eşlemesi, modül haritası ve atanmış
--  hesaplar koda bakıyor (790 "Hekim → Doktor", 833 "DSP → Sağlık Personeli",
--  835 "Doktor → Uzman Doktor" ile aynı yol).
--
--  Kurumun kendi verdiği adı EZMEZ: yalnız eski varsayılan addaki satır.
-- ============================================================================
\set ON_ERROR_STOP on

update public.rol
   set ad = 'Göz Doktoru', degistirme_tarihi = now()
 where kod = 'goz_hekimi' and ad in ('Göz Hekimi', 'Goz Hekimi');

do $$
declare v_ad varchar;
begin
    select ad into v_ad from public.rol where kod = 'goz_hekimi';
    raise notice '837 tamam: goz_hekimi rolunun adi "%".',
                 coalesce(v_ad, '(rol kurulu degil)');
end $$;
