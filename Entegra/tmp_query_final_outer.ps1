$connectionString = "Server=DESKTOP-HL3J3AS\SQLEXPRESS;Database=Henmed;Integrated Security=True;Encrypt=False"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    
    $testQuery = @"
DECLARE @ILGILIARAMA INT = 0;

SELECT 
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
    DEGISTIRMETARIHI = K.DEGISTIRMETARIHI
FROM REHBER R WITH (NOLOCK)

LEFT OUTER JOIN REHBER R2 WITH (NOLOCK) 
    ON R2.ID = R.TEMSILCI  

-- Ana tablodaki kayıtları çoğaltmaması için P tablosunu sadece varlık kontrolü gibi TOP 1 ile çekiyoruz
OUTER APPLY (
    SELECT TOP (1) 1 as VarMi
    FROM REHBER P WITH (NOLOCK)
    WHERE R.ID = P.BAGID AND ((@ILGILIARAMA = 1) OR (@ILGILIARAMA = 0 AND ISNULL(P.STATU, 1) = 1))
) P_Filter

-- KULLANICI_REHBER bağını CROSS APPLY ile bağlıyoruz (INNER JOIN ile aynı şekilde filtreler ama ÇOĞALTMAZ)
CROSS APPLY (
    SELECT TOP (1) K_Inner.DEGISTIRMETARIHI
    FROM KULLANICI_REHBER K_Inner WITH (NOLOCK)
    WHERE K_Inner.REHBERID = R.ID AND K_Inner.KULID = 2
    ORDER BY K_Inner.DEGISTIRMETARIHI DESC
) K

-- X1 bağlantısı
OUTER APPLY (
    SELECT TOP (1) RB.BILGI 
    FROM REHBERBILGI RB WITH (NOLOCK)
    INNER JOIN REHBERAYAR RA WITH (NOLOCK) ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10
    WHERE RB.YER_ID = R.ID
) X1

WHERE 
    R.ID > 1 AND R.GRUP > 1 AND R.GRUP NOT IN (334, 335) 
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
