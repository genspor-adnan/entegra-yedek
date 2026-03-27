object Tablo: TTablo
  OldCreateOrder = False
  Left = 371
  Top = 208
  Height = 342
  Width = 467
  object Database1: TDatabase
    DatabaseName = 'GENOTIP'
    DriverName = 'MSSQL'
    KeepConnection = False
    LoginPrompt = False
    Params.Strings = (
      'DATABASE NAME=master'
      'SERVER NAME=.'
      'USER NAME=sa'
      'OPEN MODE=READ/WRITE'
      'SCHEMA CACHE SIZE=8'
      'BLOB EDIT LOGGING='
      'LANGDRIVER=Ascii ANSI'
      'SQLQRYMODE='
      'SQLPASSTHRU MODE=NOT SHARED'
      'DATE MODE=0'
      'SCHEMA CACHE TIME=-1'
      'MAX QUERY TIME=300'
      'MAX ROWS=-1'
      'BATCH COUNT=200'
      'ENABLE SCHEMA CACHE=FALSE'
      'SCHEMA CACHE DIR='
      'HOST NAME='
      'APPLICATION NAME='
      'NATIONAL LANG NAME='
      'ENABLE BCD=FALSE'
      'TDS PACKET SIZE=4096'
      'BLOBS TO CACHE=64'
      'BLOB SIZE=32'
      'PASSWORD=')
    SessionName = 'Default'
    Left = 17
  end
  object Query1: TQuery
    DatabaseName = 'GENOTIP'
    Left = 24
    Top = 88
  end
  object Query2: TQuery
    DatabaseName = 'SONOMED'
    SQL.Strings = (
      'insert into XXC values ('#39'sss'#39')')
    Left = 88
    Top = 88
  end
end
