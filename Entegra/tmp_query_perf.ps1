$connectionString = "Server=DESKTOP-HL3J3AS\SQLEXPRESS;Database=Henmed;Integrated Security=True;Encrypt=False"

$queryToAnalyze = @"
DECLARE @ILGILIARAMA INT
SET @ILGILIARAMA = 0

select DISTINCT R.ID, R.KOD, R.FIRMA, ADSOYAD=R2.FIRMA, FATBASLIK=X1.BILGI, R.GRUP, R.TEMAS, R.SEKTOR, R.KATEGORI, R.SINIF, R.DURUM, R.OZELKOD, TEMSILCIAD=R2.FIRMA   from 
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
 and R.GRUP<>334 order by K.DEGISTIRMETARIHI desc
"@

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()

    # Get Missing Indexes info
    $indexQuery = @"
SELECT 
  migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure, 
  'CREATE INDEX [missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle) 
  + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
  + ' ON ' + mid.statement 
  + ' (' + ISNULL (mid.equality_columns,'') 
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
    + ISNULL (mid.inequality_columns, '')
  + ')' 
  + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement, 
  migs.*, mid.database_id, mid.[object_id]
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC
"@

    $cmdAnalyzer = $conn.CreateCommand()
    $cmdAnalyzer.CommandText = "SET STATISTICS TIME ON; SET STATISTICS IO ON;"
    $cmdAnalyzer.ExecuteNonQuery() | Out-Null
    
    # Executing the full query again to generate plan/stats
    $cmdAnalyzeQuery = $conn.CreateCommand()
    $cmdAnalyzeQuery.CommandText = $queryToAnalyze
    $cmdAnalyzeQuery.ExecuteNonQuery() | Out-Null
    
    $cmdIndex = $conn.CreateCommand()
    $cmdIndex.CommandText = $indexQuery
    $reader = $cmdIndex.ExecuteReader()
    $dtIndex = New-Object System.Data.DataTable
    $dtIndex.Load($reader)

    if ($dtIndex.Rows.Count -gt 0) {
        Write-Host "Onerilen_Indexler:"
        $dtIndex | Select-Object create_index_statement | Format-Table -AutoSize
    } else {
        Write-Host "Eksik_Index_Onerisi_Bulunamadi"
    }

    $conn.Close()
} catch {
    Write-Host "HATA: $_"
}
