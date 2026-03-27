$connectionString = "Server=DESKTOP-HL3J3AS\SQLEXPRESS;Database=Henmed;Integrated Security=True;Encrypt=False"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()
    
    # Query 2 (Modified to find duplicates)
    $query2 = @"
DECLARE @ILGILIARAMA INT
SET @ILGILIARAMA = 0

select R.ID, COUNT(*) as TekrarSayisi from 
    REHBER R 
          left outer join REHBER P on R.ID = P.BAGID and  
          1 = CASE WHEN  @ILGILIARAMA = 1 THEN 1
				   WHEN  @ILGILIARAMA = 0 AND isnull (P.STATU,1) = 1 THEN 1 
		       ELSE 0 END 

 left outer join REHBER R2 on R2.ID=R.TEMSILCI  
 left outer join (Select R1.ID,RB.BILGI from REHBER R1 
 left outer join REHBERILETISIM RI on R1.ID=RI.REHBERID and RI.VARSAYILAN=1 
 Left outer join REHBERBILGI RB on RB.YER_ID=RI.ID  
 left outer join REHBERAYAR RA on RA.SIRA=RB.SIRA AND RA.YERI=1 Where RI.VARSAYILAN=1 and RB.YERI=1 and RA.VARSAYILAN=8) X on X.ID=R.ID   
LEFT OUTER JOIN (SELECT YER_ID,RB.BILGI FROM REHBERBILGI RB 
INNER JOIN REHBERAYAR RA ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10) X1 ON X1.YER_ID = R.ID	 
inner join KULLANICI_REHBER K on K.REHBERID=R.ID and K.KULID=2  where R.GRUP<>334 and R.GRUP<>335 and R.ID > 1 
 and R.GRUP > 1 
 and R.GRUP<>334 
 GROUP BY R.ID
 HAVING COUNT(*) > 1
"@
    
    $cmd2 = $conn.CreateCommand()
    $cmd2.CommandText = $query2
    
    $reader = $cmd2.ExecuteReader()
    $dt = New-Object System.Data.DataTable
    $dt.Load($reader)
    
    Write-Host "TEKRARLAYAN_KAYIT_SAYISI:$($dt.Rows.Count)"
    
    if ($dt.Rows.Count -gt 0) {
        Write-Host "TEKRAR_EDEN_KAYITLAR:"
        $dt | Format-Table -AutoSize
    }
    
    $conn.Close()
}
catch {
    Write-Host "Error: $_"
}
