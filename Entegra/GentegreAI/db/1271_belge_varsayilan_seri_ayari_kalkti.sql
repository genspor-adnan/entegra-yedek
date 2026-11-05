-- =============================================================================
--  1271 - ÖLÜ AYAR: belge.satis.varsayilan_seri / belge.alis.varsayilan_seri kaldırıldı
--
--  Kullanıcı (05.11.2026, Fatura Ayarları incelemesi): Satış / Alış Belgeleri ayarındaki "Varsayılan seri"
--  sunucuda hiçbir yerde okunmuyordu (155'te açıldı, hiç bağlanmadı). Seri gerçekte iki yerden gelir:
--    · belge kaydında boşsa şubenin serisi (sube.ebelge_seri, Fatura Ayarları › Genel › Varsayılan Seri),
--    · e-Belge hazırlanırken GİB serisi (ebelge_seri kuralları, Seri Bilgileri sekmesi).
--  Ayar satırı ve yardım metni silinir; beyaz liste / ekran kodu eşlemesi koddan çıktı. İdempotent.
-- =============================================================================

begin;

delete from public.help where anahtar in ('ayar.belge.satis.varsayilan_seri', 'ayar.belge.alis.varsayilan_seri');
delete from public.referans where anahtar in ('belge.satis.varsayilan_seri', 'belge.alis.varsayilan_seri');

do $$ begin
  raise notice '1271: varsayilan_seri ayarlari kaldirildi (kalan: %)',
    (select count(*) from public.referans where anahtar like 'belge.%.varsayilan_seri');
end $$;

commit;
