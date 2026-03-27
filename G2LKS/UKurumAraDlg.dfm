object KurumAraDlg: TKurumAraDlg
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Kurum Arama'
  ClientHeight = 498
  ClientWidth = 858
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
    Width = 858
    Height = 41
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 48
      Height = 13
      Caption = 'Kurum Ad'#305
    end
    object lbSube: TLabel
      Left = 384
      Top = 18
      Width = 24
      Height = 13
      Caption = #350'ube'
      Visible = False
    end
    object cbSube: TcxImageComboBox
      Left = 414
      Top = 15
      Properties.Items = <>
      Properties.OnChange = cbSubePropertiesChange
      TabOrder = 0
      Visible = False
      Width = 147
    end
    object editKurumAra: TcxTextEdit
      Left = 70
      Top = 14
      TabOrder = 1
      OnKeyUp = editKurumAraKeyUp
      Width = 275
    end
    object btnEkle: TButton
      Left = 752
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Ekle'
      ModalResult = 1
      TabOrder = 2
      OnClick = btnEkleClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 858
    Height = 457
    Align = alClient
    TabOrder = 1
    object cxGrid1: TcxGrid
      Left = 1
      Top = 1
      Width = 856
      Height = 455
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      object tvKurumAra: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = dtsKurumAra
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.GroupByBox = False
        object clmKurumAdi: TcxGridDBColumn
          Caption = 'Kurum Ad'#305
          DataBinding.FieldName = 'KURUM'
          Width = 296
        end
        object clmKurumGrubu: TcxGridDBColumn
          Caption = 'Grubu'
          DataBinding.FieldName = 'GRUBU'
          Width = 202
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = tvKurumAra
      end
    end
  end
  object tabKurumAra: TADOQuery
    Connection = Tablo.cnn
    Parameters = <>
    Left = 296
    Top = 136
  end
  object dtsKurumAra: TDataSource
    DataSet = tabKurumAra
    Left = 256
    Top = 136
  end
end
