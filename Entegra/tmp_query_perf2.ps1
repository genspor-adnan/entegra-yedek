$connectionString = "Server=DESKTOP-HL3J3AS\SQLEXPRESS;Database=Henmed;Integrated Security=True;Encrypt=False"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $conn.Open()

    $indexQuery = @"
SELECT top 5
  migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure, 
  'CREATE INDEX [idx_missing_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle) 
  + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
  + ' ON ' + mid.statement 
  + ' (' + ISNULL (mid.equality_columns,'') 
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
    + ISNULL (mid.inequality_columns, '')
  + ')' 
  + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID()
ORDER BY improvement_measure DESC
"@

    $cmdIndex = $conn.CreateCommand()
    $cmdIndex.CommandText = $indexQuery
    $reader = $cmdIndex.ExecuteReader()
    $dtIndex = New-Object System.Data.DataTable
    $dtIndex.Load($reader)

    if ($dtIndex.Rows.Count -gt 0) {
        Write-Host "Onerilen_Indexler:"
        $dtIndex | Select-Object create_index_statement, improvement_measure | Format-Table -AutoSize
    } else {
        Write-Host "Eksik_Index_Onerisi_Bulunamadi"
    }

    $conn.Close()
} catch {
    Write-Host "HATA: $_"
}
