-- ============================================================
-- fn_prog_stokhizmetara_paket — MSSQL sp_Prog_StokHizmetAra_Paket PG portu
-- ------------------------------------------------------------
-- UStokHizmetAra: secilen PAKET'in icerdigi stok + hizmet kalemlerini doner.
-- Cagri (PgExecCevir positional): fn(@PaketID, @FiyatAdi, @DepoID).
--
-- MSSQL -> PG notlari:
--   * bit -> smallint (STOK/KDVDURUM). Uygulama .AsBoolean okur; 0/1 smallint yeterli.
--   * MSSQL'de iki dalin tipleri union'da otomatik uyusuyordu; PG'de RETURNS TABLE
--     tiplerine ACIK cast sart (ozellikle hizmet dalinda sabitler: 0 / 999999).
--   * ID/KDV: MASRAFGELIR.ID ve KDV smallint -> ortak tip integer'a cast.
--   * KALAN: STOKDURUM.KALAN double precision; ortak tip numeric.
--   * GENINI 'Adet' degeri metin -> ::int (MSSQL CONVERT(int,DEGER) karsiligi),
--     MAX ile tek satira indirilir (MSSQL'deki 'son satir kazanir' ile ayni sonuc).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_stokhizmetara_paket(int, int, int);
CREATE FUNCTION public.fn_prog_stokhizmetara_paket(
    p_paketid int, p_fiyatadi int, p_depoid int DEFAULT 0)
RETURNS TABLE(
    id integer, kod varchar, ad varchar, fiyat numeric, kur varchar,
    kdv integer, kdvdurum smallint, izleme integer, kalan numeric,
    birim integer, stok smallint, adet numeric
)
LANGUAGE sql STABLE AS $$
    -- 1) Paketin STOK kalemleri
    SELECT
        COALESCE(s.id, 0)::integer,
        s.kod::varchar,
        s.stokadi::varchar,
        COALESCE(sf.fiyat, -1)::numeric,
        sf.kur::varchar,
        s.kdv::integer,
        sf.kdvdurum::smallint,
        s.izleme::integer,
        COALESCE((SELECT SUM(sd.kalan) FROM stokdurum sd
                   WHERE sd.stokid = s.id AND sd.depoid = p_depoid), 0)::numeric,
        sf.birim::integer,
        pd.stok::smallint,
        pd.adet::numeric
    FROM paketdetay pd
         LEFT OUTER JOIN stoklar s    ON pd.urunid = s.id
         LEFT OUTER JOIN stokfiyat sf ON sf.stokid = s.id AND sf.birim = pd.birim
    WHERE pd.paketid = p_paketid
      AND pd.stok = 1
      AND sf.fiyatadi = p_fiyatadi

    UNION ALL

    -- 2) Paketin HIZMET kalemleri (stok takibi yok: kalan sinirsiz kabul)
    SELECT
        COALESCE(m.id, 0)::integer,
        m.kod::varchar,
        m.ad::varchar,
        COALESCE(f.fiyat, -1)::numeric,
        f.kur::varchar,
        COALESCE(m.kdv, 0)::integer,
        f.kdvdurum::smallint,
        0::integer,
        999999::numeric,
        (SELECT MAX(g.deger::int) FROM genini g
          WHERE g.bolum = -2702 AND g.anahtar = 'Adet')::integer,
        pd.stok::smallint,
        pd.adet::numeric
    FROM paketdetay pd
         LEFT OUTER JOIN masrafgelir m ON pd.urunid = m.id
         LEFT OUTER JOIN fiyatlar f    ON f.fiyatadi = p_fiyatadi AND f.hizmetid = m.id
    WHERE pd.paketid = p_paketid
      AND pd.stok = 0
      AND f.fiyatadi = p_fiyatadi;
$$;
