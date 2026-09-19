-- ============================================================================
--  Gentegre AI — "Teleradyoloji Hekimi (dış)" → "Teleradyoloji Doktoru (dış)"
--  838_teleradyoloji_doktoru_adi.sql
--
--  Kullanıcı: *"Teleradyoloji çevir"* (837'deki "Göz Hekimi → Göz Doktoru"
--  sorusunun devamı).
--
--  KOD `teleradyoloji_hekim` DEĞİŞMEZ: şablon eşlemesi, modül haritası
--  (`teleradyoloji`) ve atanmış hesaplar koda bakıyor - 790/833/835/837 ile
--  aynı yol. "(dış)" eki KALIYOR: bu rol kurum dışından okuyan radyoloğu
--  anlatıyor, ayrımın kendisi bilgi.
--
--  Kurumun kendi verdiği adı EZMEZ.
-- ============================================================================
\set ON_ERROR_STOP on

update public.rol
   set ad = 'Teleradyoloji Doktoru (dış)', degistirme_tarihi = now()
 where kod = 'teleradyoloji_hekim'
   and ad in ('Teleradyoloji Hekimi (dış)', 'Teleradyoloji Hekimi (dis)',
              'Teleradyoloji Hekimi');

do $$
declare v_ad varchar;
begin
    select ad into v_ad from public.rol where kod = 'teleradyoloji_hekim';
    raise notice '838 tamam: teleradyoloji_hekim rolunun adi "%".',
                 coalesce(v_ad, '(rol kurulu degil)');
end $$;
