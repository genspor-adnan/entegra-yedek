CREATE OR REPLACE VIEW public.uv_stok_stokliste AS
SELECT
    s.id, s.kod, s.stokadi, s.tipi, s.marka, s.model, s.grubu, s.ozellik, s.icerik, s.ozelkod, s.subeid,
    s.muhkodu, s.anabirim, s.birim2, s.birim2miktar, s.minstok, s.kdv, s.durum,
    s.izleme, s.notlar,
    stokmodel.anahtar AS stokmodel,
    COALESCE(SUM(sd.giren), 0) AS sdgiren,
    COALESCE(SUM(sd.cikan), 0) AS sdcikan,
    COALESCE(SUM(sd.kalan), 0) AS sdkalan,
    (SELECT CASE
                WHEN (SUM(CASE WHEN fb.tur IN (14, 15, 16) THEN miktar ELSE 0 END)
                      - COALESCE((SELECT SUM(COALESCE(kalan, 0)) FROM stokdurum WHERE stokid = s.id), 0)) > 0
                THEN ((SUM(CASE WHEN fb.tur IN (14, 15, 16) THEN miktar ELSE 0 END)
                      - COALESCE((SELECT SUM(COALESCE(kalan, 0)) FROM stokdurum WHERE stokid = s.id), 0)) / 1)
                ELSE 0
            END
     FROM fatbaslik fb
     INNER JOIN fatura f ON fb.id = f.fatbasid
     WHERE f.tur = 1 AND f.urunid = s.id AND fb.tur IN (14, 15, 16)) AS siparistop
FROM stoklar s
    LEFT OUTER JOIN genini stokmodel
        ON stokmodel.deger = s.model
        AND stokmodel.bolum = CAST('-2701' || CAST(s.marka AS varchar(10)) AS int)
    LEFT OUTER JOIN stokdurum sd ON s.id = sd.stokid
    LEFT OUTER JOIN depolar d ON d.id = sd.depoid AND d.subeid = -1
    LEFT OUTER JOIN stokbarkod stokbarkod ON s.id = stokbarkod.stokid AND stokbarkod.varsayilan = 1
WHERE 1 = 1 AND s.durum = 1 AND s.subeid IN (0, -5, -4, -3, -2, -1)
GROUP BY s.id, s.kod, s.stokadi, s.icerik, s.tipi, s.marka, s.model, s.grubu, s.ozellik, s.ozelkod, s.muhkodu,
    s.anabirim, s.birim2, s.birim2miktar, s.minstok, s.kdv, s.durum, s.izleme, s.notlar,
    stokmodel.anahtar, s.subeid
LIMIT 20;
