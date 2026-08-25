-- ============================================================================
--  Gentegre AI — FATURA TIPI
--  130_fatura_tipi.sql
--
--  `belge.tipi` bugune kadar yalniz stok fisinde (giris/cikis fis sebebi) ve
--  iadede (tipi = 2) kullaniliyordu. Fatura kartinda ust baslikta secilebilen
--  bir FATURA TIPI gerekiyor (kullanici): normal alis/satis disindaki fatura
--  cesitleri (fiyat farki, kur farki, tevkifatli, ihracat...) hem muhasebe
--  fisini hem e-Belge senaryosunu belirler.
--
--  Kodlar GIB / muhasebe alisilmis numaralariyla birebir - bosluklar (10-21,
--  23) bilerek bos: yeni tip cikarsa kendi numarasiyla eklenir.
-- ============================================================================
\set ON_ERROR_STOP on

-- kod_liste'de kod uzerinde benzersiz kisit yok: varligi elle kontrol edilir.
insert into public.kod_liste (kod, ad)
select 'belge.fatura_tipi', 'Fatura Tipi'
 where not exists (select 1 from public.kod_liste where kod = 'belge.fatura_tipi');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, d.deger, d.ad, d.sira, 1
  from public.kod_liste l
  join (values
          ( 1, 'Alış / Satış',          10),
          ( 2, 'İade',                  20),
          ( 3, 'Fiyat Farkı',           30),
          ( 4, 'S. Meslek Makbuzu',     40),
          ( 5, 'Kur Farkı',             50),
          ( 6, 'İthalat',               60),
          ( 7, 'Kira',                  70),
          ( 8, 'Gider Pusulası',        80),
          ( 9, 'İhraç Kayıtlı',         90),
          (22, 'Tevkifatlı',           100),
          (24, 'KDV İstisna',          110),
          (25, 'SGK',                  120),
          (26, 'İhracat',              130)
       ) as d(deger, ad, sira) on true
 where l.kod = 'belge.fatura_tipi'
   and not exists (select 1 from public.kod_deger k
                    where k.liste_id = l.id and k.deger = d.deger);

do $$
declare v_adet integer;
begin
    select count(*) into v_adet
      from public.kod_deger k join public.kod_liste l on l.id = k.liste_id
     where l.kod = 'belge.fatura_tipi';
    raise notice '130 tamam: belge.fatura_tipi % deger', v_adet;
end $$;
