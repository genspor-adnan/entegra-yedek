$connectionString = "Server=DESKTOP-HL3J3AS\SQLEXPRESS;Database=Henmed;Integrated Security=True;Encrypt=False"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    
    $testQuery = @"
DECLARE @ILGILIARAMA INT;
SET @ILGILIARAMA = 0;

SELECT 
    R.ID as R_ID, 
    P.ID as P_ID, 
    P.BAGID as P_BAGID, 
    R2.ID as R2_ID, 
    K.REHBERID as K_REHBERID, 
    K.KULID,
    K.DEGISTIRMETARIHI
FROM REHBER R WITH (NOLOCK)
LEFT OUTER JOIN REHBER P WITH (NOLOCK) 
    ON R.ID = P.BAGID AND ((@ILGILIARAMA = 1) OR (@ILGILIARAMA = 0 AND ISNULL(P.STATU, 1) = 1))
LEFT OUTER JOIN REHBER R2 WITH (NOLOCK) 
    ON R2.ID = R.TEMSILCI  
INNER JOIN KULLANICI_REHBER K WITH (NOLOCK) 
    ON K.REHBERID = R.ID AND K.KULID = 2  
WHERE R.ID = 1081
"@

    $cmdTest = $conn.CreateCommand()
    $cmdTest.CommandText = $testQuery
    $reader = $cmdTest.ExecuteReader()
    $dt = New-Object System.Data.DataTable
    $dt.Load($reader)
    
    $dt | Format-Table -AutoSize
    
    $conn.Close()
} catch {
    Write-Host "HATA: $_"
}
