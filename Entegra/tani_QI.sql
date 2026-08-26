SET NOCOUNT ON;
/* ============================================================
   QI tani #3 - XEvent ile PATLAYAN IFADEYI yakala (error 1934)
   AKIS:
     1) Bu betigi calistir  -> yakalayici kurulur/baslar
     2) Excel import'u dene  -> hata versin
     3) Bu betigi TEKRAR calistir -> yakalanan SQL metni asagida cikar
   ============================================================ */

/* ---- 1) Varsa yakalanan olaylari YAZDIR ---- */
IF EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name = 'cap_qi')
BEGIN
    PRINT '===== YAKALANAN 1934 HATALARI (patlayan ifadeler) =====';

    ;WITH x AS (
        SELECT CAST(t.target_data AS xml) AS xd
        FROM sys.dm_xe_sessions s
        JOIN sys.dm_xe_session_targets t ON t.event_session_address = s.address
        WHERE s.name = 'cap_qi' AND t.target_name = 'ring_buffer'
    )
    SELECT
        zaman       = e.value('(@timestamp)[1]','datetime2'),
        hata_no     = e.value('(data[@name="error_number"]/value)[1]','int'),
        mesaj       = e.value('(data[@name="message"]/value)[1]','nvarchar(400)'),
        uygulama    = e.value('(action[@name="client_app_name"]/value)[1]','nvarchar(200)'),
        veritabani  = e.value('(action[@name="database_name"]/value)[1]','nvarchar(128)'),
        PATLAYAN_SQL= e.value('(action[@name="sql_text"]/value)[1]','nvarchar(max)'),
        tsql_stack  = e.value('(action[@name="tsql_stack"]/value)[1]','nvarchar(max)')
    FROM x
    CROSS APPLY x.xd.nodes('//RingBufferTarget/event') AS q(e)
    ORDER BY zaman DESC;

    IF NOT EXISTS (
        SELECT 1 FROM sys.dm_xe_sessions s
        JOIN sys.dm_xe_session_targets t ON t.event_session_address=s.address
        WHERE s.name='cap_qi' AND t.target_name='ring_buffer'
          AND CAST(t.target_data AS xml).exist('//event')=1)
        PRINT '(Henuz olay yok. Once Excel import''u deneyip HATA aldiktan SONRA bu betigi tekrar calistir.)';
END

/* ---- 2) Yakalayici yoksa kur + baslat ---- */
IF NOT EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'cap_qi')
BEGIN
    CREATE EVENT SESSION cap_qi ON SERVER
      ADD EVENT sqlserver.error_reported
      ( ACTION ( sqlserver.sql_text, sqlserver.tsql_stack,
                 sqlserver.client_app_name, sqlserver.database_name )
        WHERE ([error_number] = 1934) )
      ADD TARGET package0.ring_buffer (SET max_events_limit = 20)
      WITH (MAX_DISPATCH_LATENCY = 3 SECONDS, STARTUP_STATE = OFF);
    ALTER EVENT SESSION cap_qi ON SERVER STATE = START;
    PRINT '>>> Yakalayici KURULDU ve basladi. Simdi Excel import''u dene, sonra bu betigi TEKRAR calistir.';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name='cap_qi')
    BEGIN
        ALTER EVENT SESSION cap_qi ON SERVER STATE = START;
        PRINT '>>> Yakalayici yeniden baslatildi.';
    END
END
PRINT '===== BITTI =====';
