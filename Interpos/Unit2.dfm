object HareketAktarForm: THareketAktarForm
  Left = 0
  Top = 0
  Caption = 'HareketAktarForm'
  ClientHeight = 363
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 0
    Top = 0
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 0
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 48
    Width = 794
    Height = 315
    Align = alBottom
    TabOrder = 1
    object cxGrid1DBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      object cxGrid1DBTableViewBARKOD: TcxGridDBColumn
        DataBinding.FieldName = 'BARKOD'
        Width = 85
      end
      object cxGrid1DBTableViewMIKTAR: TcxGridDBColumn
        DataBinding.FieldName = 'MIKTAR'
        Width = 85
      end
      object cxGrid1DBTableViewBIRIM: TcxGridDBColumn
        DataBinding.FieldName = 'BIRIM'
        Width = 85
      end
      object cxGrid1DBTableViewISKONTO: TcxGridDBColumn
        DataBinding.FieldName = 'iskonto'
        Width = 38
      end
      object cxGrid1DBTableViewKDV: TcxGridDBColumn
        DataBinding.FieldName = 'KDV'
        Width = 85
      end
      object cxGrid1DBTableViewFATTOPLAM: TcxGridDBColumn
        DataBinding.FieldName = 'FATTOPLAM'
        Width = 85
      end
      object cxGrid1DBTableViewTARIH: TcxGridDBColumn
        DataBinding.FieldName = 'TARIH'
        Width = 85
      end
      object cxGrid1DBTableViewFISFATNO: TcxGridDBColumn
        DataBinding.FieldName = 'FISFATNO'
        Width = 85
      end
      object cxGrid1DBTableViewTUR: TcxGridDBColumn
        DataBinding.FieldName = 'TUR'
        Width = 85
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object BarkodList: TcxListBox
    Left = 681
    Top = 83
    Width = 105
    Height = 158
    ItemHeight = 13
    Style.Shadow = False
    TabOrder = 2
    Visible = False
  end
  object cxButton2: TcxButton
    Left = 665
    Top = 1
    Width = 121
    Height = 41
    Caption = 'Aktar'
    TabOrder = 3
    OnClick = cxButton2Click
  end
  object Button1: TButton
    Left = 0
    Top = 24
    Width = 121
    Height = 21
    Caption = 'Se'#231
    TabOrder = 4
    OnClick = Button1Click
  end
  object ADOQuerySORGU: TADOQuery
    Connection = AnaForm.ADOConnection1
    Parameters = <>
    Left = 56
    Top = 232
  end
  object ADOQueryGOSTER: TADOQuery
    Connection = AnaForm.ADOConnection1
    Parameters = <>
    Left = 56
    Top = 288
  end
  object DataSource1: TDataSource
    DataSet = ADOQueryGOSTER
    Left = 152
    Top = 192
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 40
    Top = 168
  end
end
