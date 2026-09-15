-- 702: GÖZ ÜNİTE AKIŞINA ÇAĞRI BİLGİSİ.
--
-- "Sıradakini Çağır" düğmesinin bir yere yazması gerekiyor: hasta çağrıldı mı,
-- ne zaman ve kim çağırdı. Bu bilgi olmadan pano iki soruya cevap veremiyor:
--   * Hasta çağrıldı da mı gelmedi, yoksa kimse çağırmadı mı? İkisi aynı
--     görünürse tekniker "ben çağırmıştım" der, sıra kimsede kalmaz.
--   * Bekleme süresi neyin süresi? Çağrıdan sonra geçen süre HASTAYI,
--     çağrıdan önceki süre ÜNİTEYİ ölçer; ikisini ayıramayan pano darboğazı
--     yanlış yere koyar.
--
-- ÇAĞRI İSTASYON SATIRINDA, ayrı bir "çağrı" tablosunda değil: çağrı hep bir
-- istasyon için yapılır ve o satır kapanınca anlamını yitirir. Ayrı tablo,
-- kapanmış istasyonların çağrılarını temizlemek gibi bir iş çıkarırdı.

alter table public.goz_ziyaret_istasyon
  add column if not exists cagri_zamani timestamptz,
  add column if not exists cagiran_id   integer references public.taraf(id);

comment on column public.goz_ziyaret_istasyon.cagri_zamani is
  'Hasta bu istasyona çağrıldığı an (702). Boşsa henüz çağrılmadı - "çağrıldı '
  'ama gelmedi" ile "kimse çağırmadı" ayrımı buradan okunur.';

-- Panoda "çağrılmamış en uzun bekleyen" sorgusu her yenilemede çalışıyor.
create index if not exists ix_goz_istasyon_cagri
  on public.goz_ziyaret_istasyon (giris)
  where cikis is null and cagri_zamani is null;
