object TrumpfAktarimDlg: TTrumpfAktarimDlg
  Left = 0
  Top = 0
  Caption = 'Trumpf Servis Aktarim'
  ClientHeight = 493
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  TextHeight = 13
  object LblKlasorKonumu: TLabel
    Left = 147
    Top = 23
    Width = 70
    Height = 13
    Caption = 'Klas'#246'r Konumu'
  end
  object BaslatButton: TButton
    Left = 16
    Top = 49
    Width = 125
    Height = 25
    Caption = 'Ba'#351'lat'
    TabOrder = 0
    OnClick = BaslatButtonClick
  end
  object KlasorAc: TButton
    Left = 16
    Top = 18
    Width = 125
    Height = 25
    Caption = 'Dosya Se'#231
    TabOrder = 1
    OnClick = KlasorAcClick
  end
  object MemoLog: TMemo
    Left = 0
    Top = 112
    Width = 418
    Height = 381
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
    ExplicitWidth = 414
    ExplicitHeight = 380
  end
  object Button1: TButton
    Left = 16
    Top = 80
    Width = 125
    Height = 25
    Caption = 'Log Temizle'
    TabOrder = 3
    OnClick = Button1Click
  end
  object cnn: TADOConnection
    CommandTimeout = 0
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=1;Persist Security Info=True;User I' +
      'D=sa;Initial Catalog=KOZMAKINA;Data Source=SERKANPC\SQLEXPRESS'
    ConnectionTimeout = 60
    CursorLocation = clUseServer
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 16
    Top = 135
  end
  object TabServisler: TADOQuery
    Connection = cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from SERVIS')
    Left = 64
    Top = 136
  end
  object Query1: TADOQuery
    Connection = cnn
    Parameters = <>
    Left = 272
    Top = 176
  end
  object Servis: TADOQuery
    Connection = cnn
    Parameters = <
      item
        Name = 'PServisID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'Select * from SERVIS where ID=:PServisID')
    Left = 56
    Top = 232
  end
  object ServisHareket: TADOQuery
    Connection = cnn
    Parameters = <
      item
        Name = 'PServisID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'Select * from SERVISHAREKET where SERVISID=:PServisID')
    Left = 56
    Top = 280
  end
  object ServisBilgi: TADOQuery
    Connection = cnn
    Parameters = <
      item
        Name = 'PServisID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'Select * from SERVISBILGI where SERVISID=:PServisID')
    Left = 56
    Top = 328
  end
end
