-- =============================================================================
--  1011 - YARDIM KATALOĞU: FORMLAR GRUBU
--
--  Kullanıcı (10.10.2026): "Formlar menüsünü de Platform'dan önceye taşı".
--  Yönetim › Formlar alt başlığı Yönetim bölgesinde kendi grubu oldu; asistan
--  ekranları eski yolla tarif etmesin. Yalnız kurumun elle değiştirmediği
--  (menü grubu hâlâ Yönetim olan) satırlar.
-- =============================================================================

update public.ai_rehber_ekran
   set menu_grup = 'Formlar',
       yol = replace(yol, 'Yönetim › Formlar › ', 'Formlar › ')
 where kaynak in ('form-sablon', 'form-kutuphane', 'form-istek', 'form-kural')
   and menu_grup = 'Yönetim';
