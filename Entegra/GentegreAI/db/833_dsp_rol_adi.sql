-- ============================================================================
--  Gentegre AI — "Diğer Sağlık Personeli (DSP)" → "Sağlık Personeli"
--  833_dsp_rol_adi.sql
--
--  Kullanıcı: *"Diğer Sağlık Personeli (DSP) (dsp) rename Sağlık Personeli"*.
--
--  KOD DEĞİŞMEZ (`dsp`): şablon eşlemesi, modül haritası ve atanmış hesaplar
--  koda bakıyor. 790'daki "Hekim → Doktor" değişikliğinin aynısı - orada da
--  yalnız görünen ad değişmişti.
--
--  Kurumun kendi değiştirdiği adı EZMEZ: yalnız eski varsayılan addaki satır
--  güncellenir.
-- ============================================================================
\set ON_ERROR_STOP on

update public.rol
   set ad = 'Sağlık Personeli', degistirme_tarihi = now()
 where kod = 'dsp'
   and ad in ('Diğer Sağlık Personeli (DSP)', 'Diger Saglik Personeli (DSP)');

do $$
declare v_ad varchar;
begin
    select ad into v_ad from public.rol where kod = 'dsp';
    raise notice '833 tamam: dsp rolunun adi "%".', coalesce(v_ad, '(rol kurulu degil)');
end $$;
