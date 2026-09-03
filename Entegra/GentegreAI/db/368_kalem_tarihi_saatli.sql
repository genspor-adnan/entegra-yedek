-- ============================================================================
--  368 - KALEM TARIHI SAATLI (kullanici)
--
--  "ücretlendirmede + ile işlem seçtiğimde fiyat ekranı geliyor.. orada Teslim
--   Tarihi rename Tarih olmalı ve şu anki tarih saat burada olmalıdır.. boş olmaz"
--
--  `belge_satir.teslim_tarihi` DATE idi (140 - siparis termini gun bazliydi).
--  HBYS'de ayni alan "islem ne zaman yapildi" demek: ayni basvuruda sabah
--  alinan kan ile ogleden sonraki tetkik AYNI GUN ama farkli saattedir; prim
--  ve calisma listesi sirasi saate bakar. Kolon TIMESTAMP'e cevrilir - gun
--  bazli eski degerler 00:00 olarak kalir (kayip yok).
-- ============================================================================

alter table public.belge_satir
  alter column teslim_tarihi type timestamp without time zone
  using teslim_tarihi::timestamp;

comment on column public.belge_satir.teslim_tarihi is
  'Kalem tarihi/saati (140/368): siparişte TERMİN (ne zaman teslim edilecek), '
  'başvuruda İŞLEM ZAMANI (ne zaman yapıldı). Boş bırakılabilir; kart yeni '
  'satırda o anki zamanı yazar.';
