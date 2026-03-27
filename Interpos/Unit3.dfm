object UrunAktarForm: TUrunAktarForm
  Left = 0
  Top = 0
  Caption = 'UrunAktarForm'
  ClientHeight = 469
  ClientWidth = 683
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 369
    Width = 683
    Height = 100
    Align = alBottom
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object cxTextEdit1: TcxTextEdit
    Left = 0
    Top = 8
    Enabled = False
    TabOrder = 1
    Text = 'C:\POS'
    Width = 121
  end
  object cxButton2: TcxButton
    Left = 0
    Top = 28
    Width = 121
    Height = 55
    Caption = 'Interpos Aktar'#305'm Yolu'
    SpeedButtonOptions.Transparent = True
    TabOrder = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    OnClick = cxButton2Click
  end
  object cxButton3: TcxButton
    Left = 512
    Top = 8
    Width = 169
    Height = 74
    Caption = 'POS Aktar'
    TabOrder = 3
    OnClick = cxButton3Click
  end
  object cxGrid2: TcxGrid
    Left = 0
    Top = 88
    Width = 385
    Height = 305
    TabOrder = 4
    object cxGrid2DBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DataSourceInterposUrun
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object cxGrid2Level1: TcxGridLevel
      GridView = cxGrid2DBTableView1
    end
  end
  object cxGrid3: TcxGrid
    Left = 391
    Top = 88
    Width = 178
    Height = 305
    TabOrder = 5
    object cxGrid3DBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DataSourceInterposBarkod
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object cxGrid3Level1: TcxGridLevel
      GridView = cxGrid3DBTableView1
    end
  end
  object cxGrid4: TcxGrid
    Left = 575
    Top = 88
    Width = 105
    Height = 305
    TabOrder = 6
    object cxGrid4DBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DataSourcePLU
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object cxGrid4Level1: TcxGridLevel
      GridView = cxGrid4DBTableView1
    end
  end
  object ADOQueryGOSTER: TADOQuery
    Connection = AnaForm.ADOConnection1
    Parameters = <>
    Left = 56
    Top = 328
  end
  object cxShellBrowserDialog1: TcxShellBrowserDialog
    Left = 200
    Top = 320
  end
  object DataSource1: TDataSource
    DataSet = ADOQueryGOSTER
    Left = 8
    Top = 336
  end
  object ADOQueryAKTAR: TADOQuery
    Connection = AnaForm.ADOConnection1
    Parameters = <>
    Left = 136
    Top = 320
  end
  object DataSourceInterposUrun: TDataSource
    DataSet = ADOQueryAKTAR
    Left = 40
    Top = 144
  end
  object DataSourceInterposBarkod: TDataSource
    DataSet = ADOQueryInterposBarkod
    Left = 424
    Top = 152
  end
  object ADOQueryInterposBarkod: TADOQuery
    Connection = AnaForm.ADOConnection1
    Parameters = <>
    Left = 488
    Top = 152
  end
  object DataSourcePLU: TDataSource
    DataSet = ADOQueryPLU
    Left = 607
    Top = 136
  end
  object ADOQueryPLU: TADOQuery
    Connection = AnaForm.ADOConnection1
    Parameters = <>
    Left = 647
    Top = 152
  end
end
