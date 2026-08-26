-- ============================================================================
--  Gentegre AI — Numaralama tur gorunumleri: id INTEGER olmali
--  153_numara_turu_gorunum_tip.sql
--
--  BULGU: "Satış Belgeleri > Yeni" 500 veriyordu ("Beklenmeyen bir hata").
--
--  Sebep: kart metasi secim listesini
--      select id, ad from <tablo> where aktif = 1 order by ad
--    ile okur ve ilk kolonu `GetInt32` ile alir (KartDeposu.Okuma). 152'deki
--    gorunumler `kasa_islem_turu.kod` kolonunu OLDUGU GIBI (smallint) donuyordu;
--    Npgsql smallint'i GetInt32 ile vermez ve okuma InvalidCastException ile
--    patliyordu - istemciye 500 olarak yansiyordu.
--
--  Duzeltme: gorunumler id'yi INTEGER'a cevirerek donsun. Beyaz listedeki diger
--    lookup gorunumleri de integer id donuyor - desen boylece tek kaliyor.
--
--  NOT: 152 zaten dagitildi, o dosya DEGISTIRILMEDI (kural: her degisiklik yeni
--    numarali dosya). Bu dosya yalnizca dort gorunumu yeniden yaratir.
-- ============================================================================
\set ON_ERROR_STOP on

-- Kolon TIPI degistigi icin `create view` yetmez ("cannot change
--   data type of view column"); gorunumler once DUSURULUR. Baska nesne bunlara
--   bagli degil (yalnizca kart metasi okuyor).
drop view if exists public.v_numara_turu_satis;
drop view if exists public.v_numara_turu_alis;
drop view if exists public.v_numara_turu_tahsilat;
drop view if exists public.v_numara_turu_odeme;

create view public.v_numara_turu_satis as
    select kod::int as id, ad, aktif from public.kasa_islem_turu
     where kod in (13, 14, 15, 16, 19, 119);      -- tahakkuk/irsaliye/fatura/fis/siparis/konsinye

create view public.v_numara_turu_alis as
    select kod::int as id, ad, aktif from public.kasa_islem_turu
     where kod in (8, 9, 10, 11, 12, 17, 109);    -- gider pusulasi + alis belgeleri

create view public.v_numara_turu_tahsilat as
    select kod::int as id, ad, aktif from public.kasa_islem_turu
     where kod in (21, 22, 23, 24, 25, 26);       -- nakit/banka/cek/senet/POS/kupon

create view public.v_numara_turu_odeme as
    select kod::int as id, ad, aktif from public.kasa_islem_turu
     where kod in (31, 32, 33, 34, 35, 36, 87);

do $$
declare v_tip text;
begin
    select data_type into v_tip from information_schema.columns
     where table_name = 'v_numara_turu_satis' and column_name = 'id';
    if v_tip <> 'integer' then
        raise exception '153 basarisiz: v_numara_turu_satis.id = % (integer olmaliydi)', v_tip;
    end if;
    raise notice '153 tamam: dort tur gorunumu integer id donuyor';
end $$;
