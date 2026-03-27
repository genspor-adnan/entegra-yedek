object Tablo: TTablo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 480
  Width = 696
  object cnn2: TADOConnection
    CommandTimeout = 5
    ConnectionTimeout = 5
    KeepConnection = False
    LoginPrompt = False
    Left = 180
    Top = 24
  end
  object ADOQuery1: TADOQuery
    Connection = cnn2
    Parameters = <>
    Left = 58
    Top = 23
  end
end
