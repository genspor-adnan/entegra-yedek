-- =============================================================================
--  1152  MÜŞTERİ KARTI "SATIŞ & RİSK" - mockup Ekranlar/musteri_karti_ver3.html
--
--  Kullanıcı 23.10.2026: "kartta satış & risk sekmesini karşılaştır ve mockup gibi yap".
--  Sekmede yalnız risk limiti / vade / iskonto vardı. Mockup'ın Satış Koşulları ve Risk /
--  Limit kutularındaki eksik alanlar taraf_musteri (1:1 uzantı) kolonu olur:
--    odeme_sekli · doviz_cinsi · sevk_sekli · kdv_durumu · tevkifat   (Satış Koşulları)
--    risk_asim · teminat                                              (Risk / Limit)
--  Kodların anlamı kart kataloğunda (KartKatalogu.Cari, SabitKodlar). Hepsi BOŞ başlar -
--  "bilinmiyor" ile "Normal / Yok" ayrı kalsın; mevcut satırlara değer YAZILMAZ.
--  Tekrar çalıştırmak güvenli.
-- =============================================================================

begin;

alter table public.taraf_musteri
    add column if not exists odeme_sekli smallint,
    add column if not exists doviz_cinsi varchar(3),
    add column if not exists sevk_sekli  smallint,
    add column if not exists kdv_durumu  smallint,
    add column if not exists tevkifat    smallint,
    add column if not exists risk_asim   smallint,
    add column if not exists teminat     varchar(200);

comment on column public.taraf_musteri.odeme_sekli is 'Ödeme şekli: 1 Nakit · 2 Havale/EFT · 3 Çek · 4 Senet · 5 Kredi kartı · 6 Çek / Havale';
comment on column public.taraf_musteri.doviz_cinsi is 'Çalışılan para birimi (boş = yerel para)';
comment on column public.taraf_musteri.sevk_sekli  is 'Sevk şekli: 1 Kendi aracımız · 2 Kargo · 3 Ambar / nakliye · 4 Müşteri teslim alır';
comment on column public.taraf_musteri.kdv_durumu  is 'KDV durumu: 1 Normal · 2 KDV istisnalı · 3 İhraç kayıtlı · 4 Tam muaf';
comment on column public.taraf_musteri.tevkifat    is 'KDV tevkifatı: 0 Yok · 2 2/10 · 3 3/10 · 4 4/10 · 5 5/10 · 7 7/10 · 9 9/10 · 10 Tam';
comment on column public.taraf_musteri.risk_asim   is 'Risk limiti aşımında: 1 Yalnız uyar · 2 Sevkiyat onaya düşer · 3 Satış engellenir';
comment on column public.taraf_musteri.teminat     is 'Teminat (serbest metin: tür, tutar, bitiş)';

commit;
