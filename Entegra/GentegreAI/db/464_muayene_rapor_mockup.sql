-- =====================================================================
-- 464 - MUAYENE RAPORU: ALT TÜR · İMZA · BİTİŞ HESABI
--
-- Mockup `muayene_karti.html` "Rapor" paneli: Tür · ALT TÜR · Başlangıç ·
-- Süre · Tanı · Açıklama · İMZA · Durum.
--
-- ALT TÜR neden ayrı: "İstirahat" raporunun SGK karşılığı iş göremezlik mi,
-- refakat mi, doğum öncesi/sonrası mı - tür tek başına Medula'ya yetmiyor.
--
-- İMZA raporun kilidi: imzalanan rapor değişmez (SGK'ya giden metin odur).
-- İmza zamanı ve imzalayan saklanır - "kim, ne zaman" sorusunun cevabı
-- rapor kâğıdının kendisinde olmalı.
--
-- BİTİŞ HESAPLANIR: hekim başlangıç + gün yazar; bitişi ayrıca istemek
-- (10 gün yazıp bitişi yanlış güne koymak) rapor süresini bozardı. Elle
-- girilen bitiş korunur - hafta sonu/tatil kuralı kuruma göre değişir.
-- =====================================================================

alter table public.muayene_rapor
    add column if not exists alt_tur     smallint  not null default 0,
    add column if not exists imza_zamani timestamp,
    add column if not exists imzalayan   integer   not null default 0;

comment on column public.muayene_rapor.alt_tur is
    'SGK alt turu: 1 is goremezlik, 2 refakat, 3 dogum oncesi, 4 dogum sonrasi, 5 diger (464).';

create or replace function public.tg_muayene_rapor_bitis()
returns trigger language plpgsql as $$
begin
    -- BASLANGIC + GUN -> BITIS. Gun 1 ise bitis = baslangic (o gun dahil).
    if new.baslangic is not null and coalesce(new.gun, 0) > 0
       and (new.bitis is null
            or (tg_op = 'UPDATE'
                and (old.baslangic is distinct from new.baslangic
                     or coalesce(old.gun, 0) is distinct from coalesce(new.gun, 0))
                and old.bitis is not distinct from new.bitis))
    then
        new.bitis := new.baslangic + (new.gun - 1);
    end if;

    -- Gun bos ama iki tarih varsa gun sayisini tamamla (dis kaynaktan gelen
    --   kayitlarda gun bos gelebiliyor).
    if coalesce(new.gun, 0) = 0 and new.baslangic is not null and new.bitis is not null then
        new.gun := (new.bitis - new.baslangic) + 1;
    end if;
    return new;
end $$;

drop trigger if exists tg_muayene_rapor_bitis on public.muayene_rapor;
create trigger tg_muayene_rapor_bitis
    before insert or update of baslangic, bitis, gun on public.muayene_rapor
    for each row execute function public.tg_muayene_rapor_bitis();
