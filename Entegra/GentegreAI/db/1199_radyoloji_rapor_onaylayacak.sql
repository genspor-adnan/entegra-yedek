-- ============================================================================
--  1199 — Radyoloji raporu: ONAYLAYACAK uzman + uzmana gönderilme zamanı
--
--  Kullanıcı 28.10.2026: "bazı doktorlar kendi yazıyor ve onaylıyor.. bazı
--  doktorların da asistanı yazıyor uzman onaylıyor" + "onaylayacak kişiyi de
--  görmek lazım.. Onaylayacak sonra da onaylayan" (mockup
--  Ekranlar/Radyoloji/radyoloji_rapor_yazan_onaylayan.html, seçenek C).
--
--  onaylayacak_id : "Uzmana Gönder"de SEÇİLEN uzman (ön rapor). Onay başka bir
--                   radyologdan gelebilir (izin / nöbet) - o durumda
--                   onaylayan_id farklıdır ve bantta "(X yerine)" yazar.
--  onaya_gonderme : ön rapora geçiş anı - bantta "bekliyor 25 dk".
--
--  Yalnız EKLEYİCİ: eski raporlarda iki kolon boş kalır (kendi onaylayan akış).
-- ============================================================================
begin;

alter table public.radyoloji_rapor
    add column if not exists onaylayacak_id integer references public.taraf (id),
    add column if not exists onaya_gonderme timestamptz;

comment on column public.radyoloji_rapor.onaylayacak_id is
  '1199: Uzmana Gönder''de seçilen onaylayacak uzman (taraf). Onaylayan farklı olabilir (vekâlet).';
comment on column public.radyoloji_rapor.onaya_gonderme is
  '1199: ön rapora (uzman onayına) gönderilme anı.';

-- Uzmanın onay kuyruğu: "bana gelen, onay bekleyen" raporlar.
create index if not exists ix_radyoloji_rapor_onaylayacak
    on public.radyoloji_rapor (onaylayacak_id) where durum = 2;

commit;
