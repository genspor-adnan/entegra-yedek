-- ============================================================================
--  Gentegre AI — TEKLIF DURUMU
--  218_teklif_durum.sql
--
--  Teklif kartinda tarih saginda "Durumu" combosu (kullanici):
--  1 Hazırlanıyor / 2 Sunuldu / 3 Kabul / 4 Red / 5 İptal (Revize kaldirildi). Yalniz tur 18'de
--  anlamli; kod uzayi istemci sabitinde (belgeSabitleri.TEKLIF_DURUMLARI),
--  belge.durum'a (Kesin/Taslak/İptal) dokunulmaz - o silme/kesinlik
--  kurallarini tasiyor.
-- ============================================================================

alter table public.belge
    add column if not exists teklif_durum smallint not null default 1;

comment on column public.belge.teklif_durum is
  'Teklif akis durumu (218, yalniz tur 18): 1 Hazirlaniyor, 2 Sunuldu, '
  '3 Kabul, 4 Red, 5 Iptal.';

do $$ begin
    raise notice '218 tamam: belge.teklif_durum kolonu.';
end $$;
