$connectionString = "Server=DESKTOP-HL3J3AS\SQLEXPRESS;Database=Henmed;Integrated Security=True;Encrypt=False"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()

    $testQuery = @"
DECLARE @ILGILIARAMA INT
SET @ILGILIARAMA = 0

SELECT DISTINCT 
    R.ID, 
    R.KOD, 
    R.FIRMA, 
    ADSOYAD = R2.FIRMA, 
    FATBASLIK = X1.BILGI, 
    R.GRUP, 
    R.TEMAS, 
    R.SEKTOR, 
    R.KATEGORI, 
    R.SINIF, 
    R.DURUM, 
    R.OZELKOD, 
    TEMSILCIAD = R2.FIRMA,
    DEGISTIRMETARIHI = K.DEGISTIRMETARIHI -- <- HATA IÇIN EKLENDI
FROM REHBER R WITH (NOLOCK)

LEFT OUTER JOIN REHBER P WITH (NOLOCK) 
    ON R.ID = P.BAGID 
    AND (
        (@ILGILIARAMA = 1) 
        OR (@ILGILIARAMA = 0 AND ISNULL(P.STATU, 1) = 1)
    )

LEFT OUTER JOIN REHBER R2 WITH (NOLOCK) 
    ON R2.ID = R.TEMSILCI  

LEFT OUTER JOIN REHBERILETISIM RI WITH (NOLOCK) 
    ON R.ID = RI.REHBERID AND RI.VARSAYILAN = 1 
LEFT OUTER JOIN REHBERBILGI RB WITH (NOLOCK) 
    ON RB.YER_ID = RI.ID AND RB.YERI = 1 
LEFT OUTER JOIN REHBERAYAR RA WITH (NOLOCK) 
    ON RA.SIRA = RB.SIRA AND RA.YERI = 1 AND RA.VARSAYILAN = 8

LEFT OUTER JOIN REHBERBILGI X1 WITH (NOLOCK) 
    ON X1.YER_ID = R.ID 
LEFT OUTER JOIN REHBERAYAR RA2 WITH (NOLOCK) 
    ON RA2.YERI = 2 AND RA2.SIRA = X1.SIRA AND RA2.YERI = X1.YERI AND RA2.VARSAYILAN = 10

INNER JOIN KULLANICI_REHBER K WITH (NOLOCK) 
    ON K.REHBERID = R.ID AND K.KULID = 2  

WHERE 
    R.ID > 1 
    AND R.GRUP > 1 
    AND R.GRUP NOT IN (334, 335) 

ORDER BY 
    K.DEGISTIRMETARIHI DESC
"@

    $cmdTest = $conn.CreateCommand()
    $cmdTest.CommandText = $testQuery
    
    $reader = $cmdTest.ExecuteReader()
    $dt = New-Object System.Data.DataTable
    $dt.Load($reader)
    
    Write-Host "KAYIT_SAYISI:$($dt.Rows.Count)"
    
    $conn.Close()
} catch {
    Write-Host "HATA: $_"
}
