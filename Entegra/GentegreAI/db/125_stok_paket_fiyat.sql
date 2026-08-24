-- ============================================================================
--  Gentegre AI — PAKET ICERIGINDE BIRIM FIYAT
--  125_stok_paket_fiyat.sql
--
--  Paket icerigi (124) yalniz "hangi urunden kac adet" tutuyordu. Kullanici
--  satir basina birim fiyat ve para birimi de gormek istiyor: paketin toplam
--  bedelinin icerige nasil dagildigi (maliyet/indirim analizi) kart uzerinde
--  okunabilsin.
--
--  BELGEDE KULLANIMI (bugunku hali): belgeye paket eklenince icerik satirlari
--  FIYATSIZ gider - tutar paket satirinda durur. Buradaki fiyat SIMDILIK
--  bilgi amaclidir; "icerik fiyatlari belgeye tasinsin, paket satiri fiyatsiz
--  olsun" istenirse tek yerde (BelgeKarti paket acilimi) degistirilir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.stok_paket
    add column if not exists birim_fiyat numeric(19,4) not null default 0,
    add column if not exists doviz_cinsi varchar(6)    not null default 'TL';

comment on column public.stok_paket.birim_fiyat is
  'Icerik satirinin birim fiyati (125). Bilgi amacli - belgeye paket eklenirken kullanilmaz.';
comment on column public.stok_paket.doviz_cinsi is
  'Birim fiyatin para birimi (125). Varsayilan yerel para.';

do $$
declare v_satir integer;
begin
    select count(*) into v_satir from public.stok_paket;
    raise notice '125 tamam: stok_paket % satir, birim fiyat kolonlari hazir', v_satir;
end $$;
