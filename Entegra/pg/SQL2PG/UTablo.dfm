object Tablo: TTablo
  OldCreateOrder = False
  Height = 180
  Width = 300
  object MSSQL: TFDConnection
    LoginPrompt = False
    Left = 48
    Top = 32
  end
  object PG: TFDConnection
    LoginPrompt = False
    Left = 128
    Top = 32
  end
  object QueryMSSQL: TFDQuery
    Connection = MSSQL
    Left = 48
    Top = 96
  end
  object QueryPG: TFDQuery
    Connection = PG
    Left = 128
    Top = 96
  end
  object PGDriverLink: TFDPhysPgDriverLink
    Left = 224
    Top = 32
  end
  object WaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 224
    Top = 96
  end
end
