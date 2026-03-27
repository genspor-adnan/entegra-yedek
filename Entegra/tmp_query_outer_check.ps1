$connectionString = "Server=DESKTOP-HL3J3AS\SQLEXPRESS;Database=Henmed;Integrated Security=True;Encrypt=False"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    
    $testQuery = @"
DECLARE @ILGILIARAMA INT;
SET @ILGILIARAMA = 0;

-- Hangi kayıttan kaç tane geldiğini GROUP BY ile bulalım
;WITH CTE AS (
    SELECT 
        R.ID, 
        R.KOD, 
        R.FIRMA, 
        ADSOYAD = R2.FIRMA, 
        FATBASLIK = X1.BILGI, 
        R.GRUP, 
        TEMSILCIAD = R2.FIRMA,
        DEGISTIRMETARIHI = K.DEGISTIRMETARIHI
    FROM REHBER R WITH (NOLOCK)

    LEFT OUTER JOIN REHBER P WITH (NOLOCK) 
        ON R.ID = P.BAGID AND ((@ILGILIARAMA = 1) OR (@ILGILIARAMA = 0 AND ISNULL(P.STATU, 1) = 1))

    LEFT OUTER JOIN REHBER R2 WITH (NOLOCK) 
        ON R2.ID = R.TEMSILCI  

    -- İletişim Bilgileri Bağlantısı (Tekrarı Önlemek İçin Sadece İlkini Seçeriz)
    OUTER APPLY (
        SELECT TOP (1) RB.YER_ID 
        FROM REHBERILETISIM RI WITH (NOLOCK)
        INNER JOIN REHBERBILGI RB WITH (NOLOCK) ON RB.YER_ID = RI.ID AND RB.YERI = 1
        INNER JOIN REHBERAYAR RA WITH (NOLOCK) ON RA.SIRA = RB.SIRA AND RA.YERI = 1 AND RA.VARSAYILAN = 8
        WHERE RI.REHBERID = R.ID AND RI.VARSAYILAN = 1
    ) IletisimBilgisi

    -- FATBASLIK (X1) Bağlantısı
    OUTER APPLY (
        SELECT TOP (1) RB.BILGI 
        FROM REHBERBILGI RB WITH (NOLOCK)
        INNER JOIN REHBERAYAR RA WITH (NOLOCK) ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10
        WHERE RB.YER_ID = R.ID
    ) X1

    INNER JOIN KULLANICI_REHBER K WITH (NOLOCK) 
        ON K.REHBERID = R.ID AND K.KULID = 2  

    WHERE 
        R.ID > 1 AND R.GRUP > 1 AND R.GRUP NOT IN (334, 335) 
)
SELECT ID, FIRMA, COUNT(*) as TekrarSayisi
FROM CTE
GROUP BY ID, FIRMA
HAVING COUNT(*) > 1
ORDER BY TekrarSayisi DESC
"@

    $cmdTest = $conn.CreateCommand()
    $cmdTest.CommandText = $testQuery
    $reader = $cmdTest.ExecuteReader()
    $dt = New-Object System.Data.DataTable
    $dt.Load($reader)
    
    if ($dt.Rows.Count -gt 0) {
        Write-Host "TEKRAR EDEN KAYITLAR BULUNDU: $($dt.Rows.Count) adet ID"
        $dt | Select-Object -First 5 | Format-Table -AutoSize
    } else {
        Write-Host "HICBIR TEKRAR EDEN KAYIT YOK."
    }
    
    $conn.Close()
} catch {
    Write-Host "HATA: $_"
}
