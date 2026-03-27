object KurumEslestirDlg: TKurumEslestirDlg
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Kurum E'#351'le'#351'tirme'
  ClientHeight = 521
  ClientWidth = 691
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 691
    Height = 41
    Align = alTop
    TabOrder = 0
    object nvKurumEslestir: TDBNavigator
      Left = 8
      Top = 10
      Width = 88
      Height = 25
      DataSource = dtsKurumEslestir
      VisibleButtons = [nbInsert, nbDelete]
      Flat = True
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 691
    Height = 480
    Align = alClient
    TabOrder = 1
    object gridKurumEslestir: TcxGrid
      Left = 1
      Top = 1
      Width = 689
      Height = 478
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      object tvKurumEslestir: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = dtsKurumEslestir
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        object clmSube: TcxGridDBColumn
          Caption = #350'ube'
          DataBinding.FieldName = 'SUBEID'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.ImmediatePost = True
          Properties.Items = <>
        end
        object clmKurum: TcxGridDBColumn
          Caption = 'Kurum'
          DataBinding.FieldName = 'KURUM'
          Options.Editing = False
        end
        object clmMuhasebeKodu: TcxGridDBColumn
          Caption = 'Muhasebe Kodu'
          DataBinding.FieldName = 'MUHASEBEKODU'
        end
        object clmCariKodu: TcxGridDBColumn
          Caption = 'Cari Kodu'
          DataBinding.FieldName = 'CARIKODU'
        end
      end
      object gridKurumEslestirLevel1: TcxGridLevel
        GridView = tvKurumEslestir
      end
    end
  end
  object TabKurumEslestir: TADOQuery
    Connection = Tablo.cnn
    OnNewRecord = TabKurumEslestirNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from KURUMMUHASEBEKODLARI'
      'ORDER BY SUBEID, KURUM')
    Left = 416
    Top = 144
  end
  object dtsKurumEslestir: TDataSource
    DataSet = TabKurumEslestir
    OnStateChange = dtsKurumEslestirStateChange
    Left = 376
    Top = 144
  end
end
