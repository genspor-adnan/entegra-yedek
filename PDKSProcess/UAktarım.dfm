object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Offline Kay'#305't Aktar'#305'm'
  ClientHeight = 320
  ClientWidth = 477
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 477
    Height = 169
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 653
    object cxdtnvgtr1: TcxDateNavigator
      Left = 0
      Top = 32
      Width = 147
      Height = 129
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      TabOrder = 0
    end
    object cxdtnvgtr2: TcxDateNavigator
      Left = 153
      Top = 32
      Width = 147
      Height = 129
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      TabOrder = 1
    end
    object btnVerileriGetir: TcxButton
      Left = 320
      Top = 105
      Width = 137
      Height = 25
      Caption = 'Verileri Getir'
      TabOrder = 2
      OnClick = btnVerileriGetirClick
    end
    object btnAktar: TcxButton
      Left = 320
      Top = 136
      Width = 137
      Height = 25
      Caption = 'Aktar'
      TabOrder = 3
    end
    object cxlbl1: TcxLabel
      Left = 40
      Top = 9
      Caption = 'Ba'#351'lang'#305#231' Tarih'
    end
    object cxlbl2: TcxLabel
      Left = 200
      Top = 9
      Caption = 'Biti'#351' Tarih'
    end
  end
  object CxGridAlınan: TcxGrid
    Left = 8
    Top = 167
    Width = 449
    Height = 200
    TabOrder = 1
    object CxTVAlınan: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object CxGridLevelAlınan: TcxGridLevel
      GridView = CxTVAlınan
    end
  end
  object qry1: TADOQuery
    Parameters = <>
    SQL.Strings = (
      'select * from PERS_PDKS_ALINAN')
    Left = 312
    Top = 32
  end
  object ds1: TDataSource
    Left = 352
    Top = 32
  end
end
