object FrmSQL2PG: TFrmSQL2PG
  Left = 0
  Top = 0
  Caption = 'SQL2PG'
  ClientHeight = 640
  ClientWidth = 860
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    860
    640)
  TextHeight = 13
  object LabelIni: TLabel
    Left = 16
    Top = 16
    Width = 48
    Height = 13
    Caption = 'INI Dosya'
  end
  object LabelTables: TLabel
    Left = 16
    Top = 72
    Width = 38
    Height = 13
    Caption = 'Tablolar'
  end
  object EditIni: TEdit
    Left = 16
    Top = 32
    Width = 720
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    TabOrder = 0
  end
  object BtnIniSec: TButton
    Left = 744
    Top = 30
    Width = 96
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Se'#231
    TabOrder = 1
    OnClick = BtnIniSecClick
  end
  object MemoTables: TMemo
    Left = 16
    Top = 320
    Width = 224
    Height = 120
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object BtnInstall: TButton
    Left = 256
    Top = 320
    Width = 120
    Height = 32
    Caption = 'Kurulum'
    TabOrder = 3
    OnClick = BtnInstallClick
  end
  object BtnMigrate: TButton
    Left = 256
    Top = 360
    Width = 120
    Height = 32
    Caption = 'Migrate'
    TabOrder = 4
    OnClick = BtnMigrateClick
  end
  object BtnAll: TButton
    Left = 256
    Top = 400
    Width = 120
    Height = 32
    Caption = 'Kurulum + Migrate'
    TabOrder = 5
    OnClick = BtnAllClick
  end
  object MemoLog: TMemo
    Left = 16
    Top = 456
    Width = 824
    Height = 168
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 6
  end
  object GroupMSSQL: TGroupBox
    Left = 16
    Top = 88
    Width = 400
    Height = 184
    Caption = 'MSSQL'
    TabOrder = 7
    object LabelMSSQLServer: TLabel
      Left = 16
      Top = 28
      Width = 32
      Height = 13
      Caption = 'Server'
    end
    object LabelMSSQLDB: TLabel
      Left = 16
      Top = 60
      Width = 46
      Height = 13
      Caption = 'Database'
    end
    object LabelMSSQLUser: TLabel
      Left = 16
      Top = 92
      Width = 63
      Height = 13
      Caption = 'Kullan'#196#177'c'#196#177
    end
    object LabelMSSQLPass: TLabel
      Left = 16
      Top = 124
      Width = 23
      Height = 13
      Caption = #197#158'ifre'
    end
    object EditMSSQLServer: TEdit
      Left = 96
      Top = 24
      Width = 280
      Height = 21
      TabOrder = 0
    end
    object EditMSSQLDB: TEdit
      Left = 96
      Top = 56
      Width = 280
      Height = 21
      TabOrder = 1
    end
    object EditMSSQLUser: TEdit
      Left = 96
      Top = 88
      Width = 280
      Height = 21
      TabOrder = 2
    end
    object EditMSSQLPass: TEdit
      Left = 96
      Top = 120
      Width = 280
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  object GroupPG: TGroupBox
    Left = 432
    Top = 88
    Width = 408
    Height = 216
    Caption = 'PostgreSQL'
    TabOrder = 8
    object LabelPGServer: TLabel
      Left = 16
      Top = 28
      Width = 32
      Height = 13
      Caption = 'Server'
    end
    object LabelPGPort: TLabel
      Left = 16
      Top = 60
      Width = 20
      Height = 13
      Caption = 'Port'
    end
    object LabelPGDB: TLabel
      Left = 16
      Top = 92
      Width = 46
      Height = 13
      Caption = 'Database'
    end
    object LabelPGUser: TLabel
      Left = 16
      Top = 124
      Width = 63
      Height = 13
      Caption = 'Kullan'#196#177'c'#196#177
    end
    object LabelPGPass: TLabel
      Left = 16
      Top = 156
      Width = 23
      Height = 13
      Caption = #197#158'ifre'
    end
    object LabelPGVendorLib: TLabel
      Left = 16
      Top = 188
      Width = 36
      Height = 13
      Caption = 'libpq.dll'
    end
    object EditPGServer: TEdit
      Left = 96
      Top = 24
      Width = 288
      Height = 21
      TabOrder = 0
    end
    object EditPGPort: TEdit
      Left = 96
      Top = 56
      Width = 288
      Height = 21
      TabOrder = 1
    end
    object EditPGDB: TEdit
      Left = 96
      Top = 88
      Width = 288
      Height = 21
      TabOrder = 2
    end
    object EditPGUser: TEdit
      Left = 96
      Top = 120
      Width = 288
      Height = 21
      TabOrder = 3
    end
    object EditPGPass: TEdit
      Left = 96
      Top = 152
      Width = 288
      Height = 21
      PasswordChar = '*'
      TabOrder = 4
    end
    object EditPGVendorLib: TEdit
      Left = 96
      Top = 184
      Width = 240
      Height = 21
      TabOrder = 5
    end
    object BtnPGVendorLib: TButton
      Left = 344
      Top = 182
      Width = 40
      Height = 25
      Caption = '...'
      TabOrder = 6
      OnClick = BtnPGVendorLibClick
    end
  end
  object BtnTest: TButton
    Left = 392
    Top = 320
    Width = 120
    Height = 32
    Caption = 'Test Ba'#196#376'lant'#196#177
    TabOrder = 9
    OnClick = BtnTestClick
  end
  object OpenDialog: TOpenDialog
    Filter = 'INI|*.ini|T'#195#188'm dosyalar|*.*'
    Left = 408
    Top = 72
  end
end
