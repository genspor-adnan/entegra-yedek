-- =============================================================================
--  1184  CARİ e-BELGE AYARI: "E-Posta gitmesin" (taraf.earsiv_eposta_yok)
--
--  Kullanıcı (25.10.2026): "e-Belge Ayarları'na check ekle: E-Posta gitmesin. İşaretli ise ve e-Arşiv
--  fatura ise mail adresi sorulmayacak ve izibiz'e KAĞIT fatura tipinde gidecek".
--  1 ise e-Arşiv hazırlamada e-posta sorusu atlanır, e_belge.alici_alias boş kalır -> gönderim şekli
--  (SendingType) KAGIT (IzibizGovde / UblUretici: e-posta yoksa KAGIT). e-Fatura alıcısında etkisi yok.
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

alter table public.taraf add column if not exists earsiv_eposta_yok smallint not null default 0;

comment on column public.taraf.earsiv_eposta_yok is
  '1184: 1 = e-Arsiv faturada e-posta sorulmaz/gonderilmez, gonderim sekli KAGIT.';

commit;
