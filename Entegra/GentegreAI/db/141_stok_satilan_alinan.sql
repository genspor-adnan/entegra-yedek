-- ============================================================================
--  Gentegre AI — STOKTA SATILIR / ALINIR / YENIDEN KULLANILABILIR
--  141_stok_satilan_alinan.sql
--
--  Her stok her belgede aranmamali (kullanici):
--
--    satilan   1 -> SATIS belgelerinin (siparis / irsaliye / fatura / fis)
--                   stok aramasinda cikar. Yalniz alinan hammadde, ambalaj ya
--                   da sarf malzemesi satis faturasinda listelenmesin.
--    alinan    1 -> ALIS belgelerinde cikar. Kendi urettigimiz mamul satin
--                   alma siparisinde gorunmesin.
--
--  Ikisi de VARSAYILAN 1: mevcut stoklar bugune kadar her iki tarafta da
--  goruluyordu; 0 ile baslatmak butun arama ekranlarini bosaltirdi. Kullanici
--  istisnalari kartta isaretler.
--
--    yeniden_kullanilir 1 -> kiralik/demirbas gibi geri donup TEKRAR cikabilen
--                   kiymet. Satista stoktan duser, iade/geri alimda yeniden
--                   satilabilir hale gelir; sarf malzemesinden farki budur.
--                   Varsayilan 0 - normal ticari mal tuketilir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.stok
    add column if not exists satilan            smallint not null default 1,
    add column if not exists alinan             smallint not null default 1,
    add column if not exists yeniden_kullanilir smallint not null default 0;

comment on column public.stok.satilan is
  'Satis belgelerinin stok aramasinda cikar mi (141). 1 varsayilan.';
comment on column public.stok.alinan is
  'Alis belgelerinin stok aramasinda cikar mi (141). 1 varsayilan.';
comment on column public.stok.yeniden_kullanilir is
  'Geri donup tekrar satilabilen kiymet mi - kiralik/demirbas (141). 0 varsayilan.';

-- Arama sorgusu bu iki bayrakla suzuluyor; kismi indeks yalniz ISTISNALARI
--   (0 olanlari) tutar - tabloda cogunluk 1 olacak.
create index if not exists ix_stok_satilmaz on public.stok (id) where satilan = 0;
create index if not exists ix_stok_alinmaz  on public.stok (id) where alinan  = 0;

do $$
declare v_satilmaz integer; v_alinmaz integer;
begin
    select count(*) into v_satilmaz from public.stok where satilan = 0;
    select count(*) into v_alinmaz  from public.stok where alinan  = 0;
    raise notice '141 tamam: satilmayan %, alinmayan % (hepsi varsayilan 1 ile basladi)',
                 v_satilmaz, v_alinmaz;
end $$;
