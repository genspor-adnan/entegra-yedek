-- =============================================================================
--  1179  VEZNE İCMALİ menüde Kayıt Kabul › İcmaller alt başlığında
--
--  Kullanıcı (25.10.2026): "Vezne İcmali'ni İcmaller altına al" - modül menüsünün sonu
--  İcmaller · Dökümler · Ayarlar kuralına (69dd4e5) uysun. Yalnız asistan kataloğundaki menü yolu
--  (yol eski metindeyse); ekran kodu ve haklar değişmez. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

update public.ai_rehber_ekran
   set yol = 'Kayıt Kabul › İcmaller › Vezne İcmali'
 where kaynak = 'vezne-icmali' and yol = 'Kayıt Kabul › Vezne İcmali';
