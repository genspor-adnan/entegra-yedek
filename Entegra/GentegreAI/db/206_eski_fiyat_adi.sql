-- ============================================================================
--  Gentegre AI — ESKI "fiyat_listesi" KOLONLARI ADLANDIRILDI
--  206_eski_fiyat_adi.sql
--
--  205 ile `belge.fiyat_listesi_id` gelince tabloda BIRBIRINE COK BENZEYEN iki
--  kolon yan yana kaldi:
--
--    belge.fiyat_listesi      smallint   <- ESKI (MSSQL FATBASLIK.FIYATLISTESI)
--    belge.fiyat_listesi_id   integer    <- YENI (fiyat_listesi tablosuna FK)
--
--  Ikisi AYNI SEY DEGIL. Eski kolon bir liste kimligi degil, `stok_fiyat`
--  uzerindeki `fiyat_adi` kodudur - olculdu: 299 alis belgesinin hepsinde 10
--  ("Alış"), 114 satis belgesinin hepsinde 36 ("Satış"). Yani belgenin YONUNU
--  tekrar ediyor, gercek bir liste secimi tasimiyor; tasinacak bilgi yok.
--
--  `taraf_musteri.fiyat_listesi` de ayni kod uzayindan ve 2.331 musterinin
--  HEPSINDE 0 - hic kullanilmamis.
--
--  Kolonlar SILINMIYOR (goc izi, `eski_tip` / `eski_bolum` gibi) ama adlari
--  `eski_fiyat_adi` yapiliyor: yeni kodu okuyan birinin yanlis kolonu secmesi
--  sessiz ve pahali bir hata olurdu.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'belge'
                  and column_name = 'fiyat_listesi') then
        alter table public.belge rename column fiyat_listesi to eski_fiyat_adi;
    end if;

    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'taraf_musteri'
                  and column_name = 'fiyat_listesi') then
        alter table public.taraf_musteri rename column fiyat_listesi to eski_fiyat_adi;
    end if;
end $$;

comment on column public.belge.eski_fiyat_adi is
  'GOC IZI (206): eski FATBASLIK.FIYATLISTESI - stok_fiyat.fiyat_adi kodu, belgenin yonunu tekrar eder. Yururlukteki liste `fiyat_listesi_id`dir.';
comment on column public.taraf_musteri.eski_fiyat_adi is
  'GOC IZI (206): eski musteri fiyat listesi kodu (hepsi 0 - kullanilmamis). Yururlukteki alanlar taraf.satis_fiyat_listesi_id / alis_fiyat_listesi_id.';

do $$
declare v integer;
begin
    select count(*) into v from information_schema.columns
     where table_schema = 'public' and column_name = 'eski_fiyat_adi';
    raise notice '206 tamam: % kolon eski_fiyat_adi olarak adlandirildi (belge, taraf_musteri).', v;
end $$;
