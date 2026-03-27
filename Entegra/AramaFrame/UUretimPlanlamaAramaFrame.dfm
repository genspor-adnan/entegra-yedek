object UretimPlanlamaAramaFrame: TUretimPlanlamaAramaFrame
  Left = 0
  Top = 0
  Width = 258
  Height = 444
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  ExplicitWidth = 451
  ExplicitHeight = 304
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 258
    Height = 33
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 451
    object cbDepo: TcxImageComboBox
      Left = 66
      Top = 5
      RepositoryItem = Tablo.RepStokTumDepolar
      Properties.ImmediatePost = True
      Properties.ImmediateUpdateText = True
      Properties.Items = <>
      Properties.OnEditValueChanged = cbDepoPropertiesEditValueChanged
      TabOrder = 0
      Width = 100
    end
    object cxLabel1: TcxLabel
      Left = 3
      Top = 7
      Caption = 'Depo'
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 33
    Width = 258
    Height = 411
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 451
    ExplicitHeight = 271
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.First.Visible = True
      Navigator.Buttons.PriorPage.Visible = True
      Navigator.Buttons.Prior.Visible = True
      Navigator.Buttons.Next.Visible = True
      Navigator.Buttons.NextPage.Visible = True
      Navigator.Buttons.Last.Visible = True
      Navigator.Buttons.Insert.Visible = True
      Navigator.Buttons.Append.Visible = False
      Navigator.Buttons.Delete.Visible = True
      Navigator.Buttons.Edit.Visible = True
      Navigator.Buttons.Post.Visible = True
      Navigator.Buttons.Cancel.Visible = True
      Navigator.Buttons.Refresh.Visible = True
      Navigator.Buttons.SaveBookmark.Visible = True
      Navigator.Buttons.GotoBookmark.Visible = True
      Navigator.Buttons.Filter.Visible = True
      DataController.DataSource = DtsPlanlar
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.FocusCellOnCycle = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.MultiSelect = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      object cxGrid1DBTableView1TARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object TabPlanlar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PDepoID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
    SQL.Strings = (
      
        'select * from URETIMPLANLAMA where DURUM=1 and DEPOID=:PDepoID o' +
        'rder by TARIH desc')
    Left = 56
    Top = 88
  end
  object DtsPlanlar: TDataSource
    DataSet = TabPlanlar
    Left = 128
    Top = 112
  end
end

