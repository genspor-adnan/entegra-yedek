-- 1364 - KVKK onay kodu deneme sınırı (kod inceleme 17.11.2026).
--   SORUN: 6 haneli SMS kodu sınırsız denenebiliyor ve hiç eskimiyordu - hasta olmadan "SMS ile onay alındı" üretilebilirdi.
--   ÇÖZÜM: başvuru başına hatalı deneme sayacı; uç (BasvuruKvkkUclari kvkk-kod) 5 hatada ve SMS'ten 30 dakika sonra kodu
--   reddeder - yeni SMS gerekir. SMS gönderimi sayacı sıfırlar. Tekrar çalıştırılabilir.
alter table public.belge_basvuru add column if not exists kvkk_kod_hata smallint not null default 0;
comment on column public.belge_basvuru.kvkk_kod_hata is
  '1364: KVKK SMS onay kodunun hatalı deneme sayısı - 5''te kod kilitlenir, yeni SMS sıfırlar';
