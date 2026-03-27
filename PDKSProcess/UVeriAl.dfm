object FrmVeriAktarım: TFrmVeriAktarım
  Left = 0
  Top = 0
  Caption = 'Veri Aktar'#305'm Formu'
  ClientHeight = 520
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 447
    Height = 49
    Align = alTop
    TabOrder = 0
    object dtp1: TDateTimePicker
      Left = 8
      Top = 16
      Width = 97
      Height = 21
      Date = 40456.492204513890000000
      Time = 40456.492204513890000000
      TabOrder = 0
      OnChange = dtp1Change
    end
    object dtp2: TDateTimePicker
      Left = 111
      Top = 16
      Width = 97
      Height = 21
      Date = 40456.492204513890000000
      Time = 40456.492204513890000000
      TabOrder = 1
      OnChange = dtp2Change
    end
    object btn1: TButton
      Left = 214
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Verileri Getir'
      TabOrder = 2
      OnClick = btn1Click
    end
    object btn2: TButton
      Left = 295
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Verileri Aktar'
      TabOrder = 3
      OnClick = btn2Click
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 49
    Width = 447
    Height = 471
    Align = alClient
    TabOrder = 1
    object CihazTV: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = ds1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      object CihazTVFIRMA: TcxGridDBColumn
        Caption = 'Ad Soyad'
        DataBinding.FieldName = 'FIRMA'
        Width = 167
      end
      object CihazTVKARTNO: TcxGridDBColumn
        Caption = 'Kart No'
        DataBinding.FieldName = 'KARTNO'
        Width = 80
      end
      object CihazTVTARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        Width = 127
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = CihazTV
    end
  end
  object ds1: TDataSource
    DataSet = qry1
    Left = 360
    Top = 120
  end
  object qry1: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'TARIH1'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = Null
      end
      item
        Name = 'TARIH2'
        Attributes = [paNullable]
        DataType = ftDateTime
        NumericScale = 3
        Precision = 23
        Size = 16
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT R.FIRMA,PC.ID,RB.BILGI as KARTNO,PC.TARIH,PC.KAYITTARIH F' +
        'ROM REHBERBILGI RB (nolock) '
      
        'INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=3 and RA.SIRA=RB.SI' +
        'RA AND RA.YERI=RB.YERI'
      'left outer join REHBER R (nolock) ON R.ID=RB.YER_ID'
      
        'left outer join PERS_CIHAZ_ALINAN PC (nolock) ON PC.KARTNO=RB.BI' +
        'LGI'
      
        'WHERE RA.VARSAYILAN=90  and PC.TARIH BETWEEN CONVERT(DATETIME,:T' +
        'ARIH1,120) AND CONVERT(DATETIME,:TARIH2,120) '
      'ORDER BY PC.TARIH')
    Left = 400
    Top = 120
  end
end
