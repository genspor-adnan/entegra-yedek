object EFaturaFirmaAra: TEFaturaFirmaAra
  Left = 0
  Top = 0
  Caption = 'Firma Ara'
  ClientHeight = 390
  ClientWidth = 765
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object grdFirmalar: TcxGrid
    Left = 0
    Top = 29
    Width = 765
    Height = 361
    Align = alClient
    TabOrder = 0
    object tblViewFirmalar: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = memTableDataSource
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object tblViewFirmalarRecId: TcxGridDBColumn
        DataBinding.FieldName = 'RecId'
        Visible = False
      end
      object tblViewFirmalarVERGINO: TcxGridDBColumn
        Caption = 'Vergi No'
        DataBinding.FieldName = 'VERGINO'
      end
      object tblViewFirmalarEPOSTA: TcxGridDBColumn
        Caption = 'EPosta'
        DataBinding.FieldName = 'EPOSTA'
      end
      object tblViewFirmalarUNVAN: TcxGridDBColumn
        Caption = #220'nvan'
        DataBinding.FieldName = 'UNVAN'
      end
      object tblViewFirmalarTYPE: TcxGridDBColumn
        Caption = 'Tip'
        DataBinding.FieldName = 'TYPE'
      end
      object tblViewFirmalarKAYITTARIHI: TcxGridDBColumn
        Caption = 'Kay'#305't Tarihi'
        DataBinding.FieldName = 'KAYITTARIHI'
      end
      object tblViewFirmalarBIRIM: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'BIRIM'
      end
    end
    object grdFirmalarLevel1: TcxGridLevel
      GridView = tblViewFirmalar
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 765
    Height = 29
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 4
      Top = 8
      Width = 44
      Height = 13
      Caption = 'Vergi No:'
    end
    object Label2: TLabel
      Left = 181
      Top = 8
      Width = 35
      Height = 13
      Caption = #220'nvan:'
    end
    object btnAra: TcxButton
      Left = 349
      Top = 5
      Width = 75
      Height = 22
      Caption = 'Ara'
      TabOrder = 0
      OnClick = btnAraClick
    end
    object txtVergiNo: TcxTextEdit
      Left = 54
      Top = 5
      TabOrder = 1
      Width = 121
    end
    object txtUnvan: TcxTextEdit
      Left = 222
      Top = 5
      TabOrder = 2
      Width = 121
    end
  end
  object memTable: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 408
    Top = 128
    object memTableVERGINO: TStringField
      FieldName = 'VERGINO'
    end
    object memTableEPOSTA: TStringField
      FieldName = 'EPOSTA'
    end
    object memTableUNVAN: TStringField
      FieldName = 'UNVAN'
    end
    object memTableTYPE: TStringField
      FieldName = 'TYPE'
    end
    object memTableKAYITTARIHI: TStringField
      FieldName = 'KAYITTARIHI'
    end
    object memTableBIRIM: TStringField
      FieldName = 'BIRIM'
    end
  end
  object memTableDataSource: TDataSource
    DataSet = memTable
    Left = 592
    Top = 144
  end
  object HTTPRIOEfat: THTTPRIO
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 184
    Top = 144
  end
end
