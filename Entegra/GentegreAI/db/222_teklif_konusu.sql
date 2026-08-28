-- ============================================================================
--  Gentegre AI — TEKLIF KONUSU
--  222_teklif_konusu.sql
--
--  Teklif kartinda Cikis Deposu hucresi kalkti (kullanici) - teklif stok
--  cikisi yapmaz; yerine 2. sira: TEKLIF KONUSU (yazilabilir combo) |
--  TESLIM SEKLI (salt combo) | Gecerlilik Suresi (vade alani, etiket
--  degisir). Iki combo da kod listesinden (belge.teklif_konusu /
--  belge.teslim_sekli); etikete tiklaninca jenerik KodListesiModali.
-- ============================================================================

alter table public.belge
    add column if not exists teklif_konusu varchar(100) not null default '';

alter table public.belge
    add column if not exists teklif_teslim varchar(100) not null default '';

comment on column public.belge.teklif_teslim is
  'Teklif teslim sekli (222, yalniz tur 18) - belge.teslim_sekli kod listesinden.';

comment on column public.belge.teklif_konusu is
  'Teklif konusu (222, yalniz tur 18) - serbest metin, belge.teklif_konusu '
  'kod listesinden onerilir.';

-- Konu combosunun kod listesi TANIMI (degerler kod_deger'e kullanicidan
-- girilir; belge.teslim_sekli tanimi 219'dan beri zaten var).
insert into public.kod_liste (kod, ad)
select 'belge.teklif_konusu', 'Teklif Konusu'
where not exists (select 1 from public.kod_liste where kod = 'belge.teklif_konusu');

do $$ begin
    raise notice '222 tamam: belge.teklif_konusu kolonu + kod listesi.';
end $$;
