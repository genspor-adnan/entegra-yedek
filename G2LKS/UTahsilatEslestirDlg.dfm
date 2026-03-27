object TahsilatEslestirDlg: TTahsilatEslestirDlg
  Left = 0
  Top = 0
  Caption = 'Tahsilat T'#252'rleri E'#351'le'#351'tirme'
  ClientHeight = 328
  ClientWidth = 802
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
    Width = 802
    Height = 41
    Align = alTop
    TabOrder = 0
    object nvTahsilatEslestir: TDBNavigator
      Left = 8
      Top = 10
      Width = 88
      Height = 25
      DataSource = dtsTahsilatEslestir
      VisibleButtons = [nbInsert, nbDelete]
      Flat = True
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 802
    Height = 287
    Align = alClient
    TabOrder = 1
    object gridKurumEslestir: TcxGrid
      Left = 1
      Top = 1
      Width = 800
      Height = 285
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      object tvTahsilatEslestir: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = dtsTahsilatEslestir
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
        object clmTahsilatTuru: TcxGridDBColumn
          Caption = 'Tahsilat T'#252'r'#252
          DataBinding.FieldName = 'TAHSILATTURU'
          PropertiesClassName = 'TcxComboBoxProperties'
          Properties.DropDownListStyle = lsEditFixedList
          Properties.ImmediatePost = True
        end
        object clmKasaHesapKodu: TcxGridDBColumn
          Caption = 'Kasa Hesap Kodu'
          DataBinding.FieldName = 'KASAHESAPKODU'
        end
        object clmMuhasebeKodu: TcxGridDBColumn
          Caption = 'Muhasebe Kodu'
          DataBinding.FieldName = 'MUHASEBEKODU'
        end
        object clmKomisyonKodu: TcxGridDBColumn
          Caption = 'Komisyon Hesap Kodu'
          DataBinding.FieldName = 'KOMISYONKODU'
        end
        object clmBSMVKodu: TcxGridDBColumn
          Caption = 'BSMV Hesap Kodu'
          DataBinding.FieldName = 'BSMVKODU'
        end
        object clmBankaHesapKodu: TcxGridDBColumn
          Caption = 'Logo Banka Hesap Kodu'
          DataBinding.FieldName = 'BANKAHESAPKODU'
        end
      end
      object gridKurumEslestirLevel1: TcxGridLevel
        GridView = tvTahsilatEslestir
      end
    end
  end
  object TabTahsilatEslestir: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    OnNewRecord = TabTahsilatEslestirNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from G2MUHTAHSILATESLESME'
      'ORDER BY SUBEID, TAHSILATTURU')
    Left = 416
    Top = 144
  end
  object dtsTahsilatEslestir: TDataSource
    DataSet = TabTahsilatEslestir
    OnStateChange = dtsTahsilatEslestirStateChange
    Left = 328
    Top = 136
  end
end
