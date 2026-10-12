-- =============================================================================
--  1073  KURUMSAL KALİTE - "YGG & Kararlar" MENÜSÜ "Toplantı & Kararlar"
--
--  Kullanıcı (12.10.2026): "toplantı listesi yok". Toplantılar 1064'ten beri
--  "YGG & Kararlar" sayfasının sekmesi; menü adında "toplantı" geçmediği için
--  bulunmuyordu. Menü adı sayfa başlığıyla aynı yapıldı; yardım rehberi de.
--  İdempotent.
-- =============================================================================

begin;

update public.ai_rehber_ekran set menu_ad = 'Toplantı & Kararlar', yol = 'Kalite › Toplantı & Kararlar'
 where rota = '/kys-toplantilar' and menu_ad <> 'Toplantı & Kararlar';

commit;
