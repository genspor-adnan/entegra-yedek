-- ============================================================================
-- KONSOLIDE UPDATE 09 - DIGER   #pg   (PostgreSQL)
-- ============================================================================
-- Kaynak: _Konsolide_66_169\09_Diger.sql  (MSSQL)
-- 2 nesne. 00'dan SONRA, 99'dan ONCE calistir.
--
-- MSSQL -> PG donusum notlari (bu dosyaya ozel):
--   dbo.                      -> public.  (varsayilan search_path)
--   CREATE OR ALTER FUNCTION  -> CREATE OR REPLACE FUNCTION
--   sysname                   -> text
--   AYRI VERITABANI (GENDEPO) -> AYRI SEMA (depo)   [PG cross-database yapamaz]
--   AFTER INSERT/UPDATE trg   -> trigger fonksiyonu + CREATE TRIGGER (AFTER ... FOR EACH ROW)
--   inserted sanal tablosu    -> NEW kaydi (FOR EACH ROW)
--   UPDATE(<kolon>)           -> (TG_OP='UPDATE' AND NEW.x IS DISTINCT FROM OLD.x)
--   DATEADD(YEAR, 5, x)       -> x + interval '5 year'
--
-- Tablo/kolon adlari tirnaksiz YAZILIR -> PG kucuk harfe katlar; PG semasindaki
-- kucuk harfli adlarla eslesir (pg/schema/ dosyalariyla ayni kural).
-- ============================================================================


-- ---- FUNCTION: fn_api_depodbadi  (kaynak: GenDepoUpdate71) ----
-- MSSQL: depo AYRI bir veritabanidir  ->  DB_NAME() + '_GENDEPO', yoksa 'GENDEPO'.
-- PG   : cross-database sorgu YOK; depo AYNI veritabaninda 'depo' SEMASIDIR
--        (bkz. pg/schema/01_depo.sql). Fonksiyon geriye SEMA ADI dondurur;
--        cagiranlar 'depo' || '.log2026' seklinde nitelendirir.
-- Sema yoksa 'public' doner: boylece depo semasi kurulmamis bir kurulumda
--        cagiranlar hata yerine ana semaya duser (MSSQL'deki 'GENDEPO' fallback'i).
DROP FUNCTION IF EXISTS public.fn_api_depodbadi();
CREATE OR REPLACE FUNCTION public.fn_api_depodbadi()
RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'depo')
                THEN 'depo' ELSE 'public' END;
$$;


-- ---- TRIGGER: trg_uretimemriuser_skt_guncelle  (kaynak: GenDepoUpdate87) ----
-- URETIMEMRI_USER.URT (uretim tarihi) yazildiginda, stok KATEGORI=7 ise
-- SKT = URT + 5 yil; degilse NULL.
--
-- MSSQL'de bu bir AFTER INSERT,UPDATE toplu (set-based) trigger'di ve kendi
-- tablosunu UPDATE ediyordu. PG'de ayni tabloyu AFTER icinde guncellemek
-- gereksiz ikinci bir yazma turu ve tekrar tetiklenme riski demektir; PG'de
-- doogru kalip BEFORE + NEW ATAMASI'dir -> tek yazma, ozyineleme yok,
-- "SKT'nin kendisi degisti mi" korumasina da gerek kalmaz.
CREATE OR REPLACE FUNCTION public.trg_uretimemriuser_skt_guncelle()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_kategori integer;
BEGIN
    -- URT yoksa dokunma (MSSQL: WHERE I.URT IS NOT NULL)
    IF NEW.URT IS NULL THEN
        RETURN NEW;
    END IF;

    -- URT degismediyse is yok (MSSQL: IF UPDATE(SKT) AND NOT UPDATE(URT) RETURN)
    IF TG_OP = 'UPDATE' AND NEW.URT IS NOT DISTINCT FROM OLD.URT THEN
        RETURN NEW;
    END IF;

    SELECT S.KATEGORI INTO v_kategori
    FROM URETIMEMRI U
        INNER JOIN STOKLAR S ON S.ID = U.STOKID
    WHERE U.ID = NEW.ID;

    NEW.SKT := CASE WHEN v_kategori = 7 THEN NEW.URT + interval '5 year' ELSE NULL END;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_uretimemriuser_skt_guncelle ON URETIMEMRI_USER;
CREATE TRIGGER trg_uretimemriuser_skt_guncelle
    BEFORE INSERT OR UPDATE ON URETIMEMRI_USER
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_uretimemriuser_skt_guncelle();
