-- =============================================================================
--  1079  ZAMANLI İŞ SAATİ = KURUMUN DUVAR SAATİ
--
--  Kullanıcı (13.10.2026): "zamanlı iş saatlerini düzelt".
--
--  Sonraki çalışma zamanı UTC'de hesaplanıyordu (`now()` UTC döner): ekranda
--  "Günlük 07:30" yazan iş İstanbul'da 10:30'da çalışıyordu; bütün günlük /
--  haftalık / aylık işler 3 saat geç (gece 01:00 işleri sabah 04:00'te),
--  haftalık işlerde gün de kayabiliyordu. Hesap artık kuruluş diliminde
--  (ZamanlamaHesabi.SonrakiAn, Kurulus:SaatDilimi - varsayılan Europe/Istanbul).
--
--  Bu betik:
--    1. Saatlik olmayan aktif işlerin `sonraki`sini BİR KEZ boşaltır; işçi
--       yeni kurala göre yeniden hesaplar. Boş `sonraki` işi HEMEN çalıştırmaz,
--       bir sonraki normal saatine koyar.
--    2. Tetik: kartta periyot / gün / saat / dakika / aktif değişince
--       `sonraki` boşalır - yeni saat hemen geçerli olsun (önceden iş bir kez
--       eski saatte çalıştıktan sonra geçerli oluyordu).
--
--  İdempotent; 1. adım yeniden çalışırsa yalnız yeniden hesaplatır (zararsız).
-- =============================================================================

begin;

update public.zamanli_is
   set sonraki = null
 where aktif = 1 and periyot <> 1 and calisiyor = 0;

create or replace function public.trg_zamanli_is_plan_degisti()
returns trigger language plpgsql as $$
begin
    if (new.periyot, new.gun, new.saat, new.dakika, new.aktif)
       is distinct from (old.periyot, old.gun, old.saat, old.dakika, old.aktif) then
        new.sonraki := null;
    end if;
    return new;
end $$;

drop trigger if exists trg_zamanli_is_plan_degisti on public.zamanli_is;
create trigger trg_zamanli_is_plan_degisti
    before update on public.zamanli_is
    for each row execute function public.trg_zamanli_is_plan_degisti();

commit;
