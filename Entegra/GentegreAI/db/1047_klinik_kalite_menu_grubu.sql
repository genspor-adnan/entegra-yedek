-- =============================================================================
--  1047  ANA MENÜ "Kalite" -> "Klinik Kalite"
--
--  Kullanıcı (12.10.2026): "ana menüdeki kalite adını rename Klinik Kalite".
--
--  Yetki matrisi menüyle birebir (aynı grup adı): menü grubu web'de
--  (listeTanimlari.KlinikKalite.ts) değişti, yetki.grup da aynı ada çekilir.
--  Yardım kataloğundaki menü yolu / grubu da güncellenir. İdempotent.
-- =============================================================================

begin;

update public.yetki
   set grup = 'Klinik Kalite',
       ad   = replace(ad, '(Kalite)', '(Klinik Kalite)')
 where grup = 'Kalite';

update public.ai_rehber_ekran
   set menu_grup = 'Klinik Kalite',
       yol = regexp_replace(yol, '^(Yönetim › )?Kalite › ', 'Klinik Kalite › ')
 where menu_grup = 'Kalite' or yol like 'Kalite › %' or yol like 'Yönetim › Kalite › %';

commit;
