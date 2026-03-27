object DegerAraDlg: TDegerAraDlg
  Left = 354
  Top = 169
  Caption = 'Arama'
  ClientHeight = 442
  ClientWidth = 880
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 73
    Width = 880
    Height = 369
    Align = alClient
    TabOrder = 0
    object DBGrid1: TDBGrid
      Left = 1
      Top = 1
      Width = 878
      Height = 367
      Align = alClient
      DataSource = DataSource1
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = TURKISH_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Trebuchet MS'
      TitleFont.Style = []
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 880
    Height = 73
    Align = alTop
    TabOrder = 1
    object Edit1: TEdit
      Left = 137
      Top = 29
      Width = 248
      Height = 24
      TabOrder = 0
      OnChange = Edit1Change
    end
    object cxLabel1: TcxLabel
      Left = 1
      Top = 30
      Caption = 'Arama Anahtar'#305
    end
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 376
    Top = 16
  end
  object ADOQuery1: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 448
    Top = 16
  end
end


