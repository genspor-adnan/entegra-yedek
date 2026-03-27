object kurumEslemeForm: TkurumEslemeForm
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object cxGrid1: TcxGrid
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    TabOrder = 0
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    RootLevelOptions.DetailFrameColor = clBlack
    RootLevelOptions.DetailTabsPosition = dtpTop
    object kdvEslemeView: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
      NavigatorButtons.First.Visible = False
      NavigatorButtons.PriorPage.Visible = False
      NavigatorButtons.Prior.Visible = False
      NavigatorButtons.Next.Visible = False
      NavigatorButtons.NextPage.Visible = False
      NavigatorButtons.Last.Visible = False
      NavigatorButtons.Refresh.Visible = False
      NavigatorButtons.SaveBookmark.Visible = False
      NavigatorButtons.GotoBookmark.Visible = False
      NavigatorButtons.Filter.Enabled = False
      NavigatorButtons.Filter.Visible = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.Navigator = True
      OptionsView.GroupByBox = False
      object kdvEslemeViewColumn1: TcxGridColumn
        Caption = 'Oran'
        Width = 71
      end
      object kdvEslemeViewColumn2: TcxGridColumn
        Caption = 'Muhasebe Kodu'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = kdvEslemeViewColumn2PropertiesButtonClick
        Width = 127
      end
    end
    object hastaEslemeView: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = kimlikTableDataSource
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.IncSearch = True
      OptionsBehavior.IncSearchItem = hastaEslemeViewColumn2
      OptionsCustomize.ColumnGrouping = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object hastaEslemeViewColumn1: TcxGridDBColumn
        Caption = 'Dosya No'
        DataBinding.FieldName = 'DOSYANO'
        Options.Editing = False
      end
      object hastaEslemeViewColumn2: TcxGridDBColumn
        Caption = 'Ad'#305
        DataBinding.FieldName = 'AD'
        Options.Editing = False
      end
      object hastaEslemeViewColumn3: TcxGridDBColumn
        Caption = 'Soyad'#305
        DataBinding.FieldName = 'SOYAD'
        Options.Editing = False
      end
      object hastaEslemeViewColumn4: TcxGridDBColumn
        Caption = 'Kar'#351#305' Kod'
        DataBinding.FieldName = 'CARIKODU'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = hastaEslemeViewColumn4PropertiesButtonClick
        Width = 124
      end
      object hastaEslemeViewColumn5: TcxGridDBColumn
        Caption = 'Kar'#351#305' Muhasebe Kodu'
        DataBinding.FieldName = 'MUHASEBEKODU'
        Width = 136
      end
    end
    object referansEslemeView: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = ReferansQueryDataSource
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.IncSearch = True
      OptionsBehavior.IncSearchItem = referansEslemeViewColumn2
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object referansEslemeViewColumn1: TcxGridDBColumn
        Caption = 'Referans Kod'
        DataBinding.FieldName = 'KOD'
        Options.Editing = False
        Width = 95
      end
      object referansEslemeViewColumn2: TcxGridDBColumn
        Caption = 'Firma'
        DataBinding.FieldName = 'FIRMA'
        Options.Editing = False
        Width = 135
      end
      object referansEslemeViewColumn3: TcxGridDBColumn
        Caption = 'Kar'#351#305' Kod'
        DataBinding.FieldName = 'CARIKODU'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = referansEslemeViewColumn3PropertiesButtonClick
        Width = 98
      end
      object referansEslemeViewColumn4: TcxGridDBColumn
        Caption = 'Kar'#351#305' Muhasebe Kod'
        DataBinding.FieldName = 'MUHKODU'
        Width = 114
      end
    end
    object kurumView: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = kurumQueryDataSource
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.IncSearch = True
      OptionsBehavior.IncSearchItem = kurumViewColumn1
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object kurumViewColumn1: TcxGridDBColumn
        Caption = 'Kurum'
        DataBinding.FieldName = 'KURUM'
        Options.Editing = False
        Width = 125
      end
      object kurumViewColumn2: TcxGridDBColumn
        Caption = 'Kar'#351#305' Kod'
        DataBinding.FieldName = 'CARIKODU'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = kurumViewColumn2PropertiesButtonClick
        Width = 108
      end
      object kurumViewColumn3: TcxGridDBColumn
        Caption = 'Kar'#351#305' Muhasebe Kod'
        DataBinding.FieldName = 'MUHASEBEKODU'
        Width = 117
      end
    end
    object hizmetEslemeView: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = HizmetlerQueryDataSource
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.IncSearch = True
      OptionsBehavior.IncSearchItem = hizmetEslemeViewColumn2
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object hizmetEslemeViewColumn1: TcxGridDBColumn
        Caption = 'Kod'
        DataBinding.FieldName = 'KOD'
        Options.Editing = False
        Width = 94
      end
      object hizmetEslemeViewColumn2: TcxGridDBColumn
        Caption = 'Ad'#305
        DataBinding.FieldName = 'ISLEMADI'
        Options.Editing = False
        Width = 132
      end
      object hizmetEslemeViewColumn3: TcxGridDBColumn
        Caption = 'Kar'#351#305' Kod'
        DataBinding.FieldName = 'OZELKOD'
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = hizmetEslemeViewColumn2PropertiesButtonClick
        Width = 131
      end
      object hizmetEslemeViewColumn4: TcxGridDBColumn
        Caption = 'Kar'#351#305' Muhasebe Kod'
        DataBinding.FieldName = 'MUHKODU'
        Width = 150
      end
    end
    object cxGrid1Level1: TcxGridLevel
      Caption = 'Hasta'
      GridView = hastaEslemeView
    end
    object cxGrid1Level3: TcxGridLevel
      Caption = 'Kurum'
      GridView = kurumView
    end
    object cxGrid1Level4: TcxGridLevel
      Caption = 'Hizmet'
      GridView = hizmetEslemeView
    end
    object cxGrid1Level2: TcxGridLevel
      Caption = 'Referans'
      GridView = referansEslemeView
    end
    object cxGrid1Level5: TcxGridLevel
      Caption = 'KDV'
      GridView = kdvEslemeView
    end
  end
  object kimlikTable: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT DOSYANO,AD,SOYAD,CARIKODU,MUHASEBEKODU FROM KIMLIK WITH (' +
        'NOLOCK)')
    Left = 32
    Top = 88
  end
  object kimlikTableDataSource: TDataSource
    DataSet = kimlikTable
    Left = 64
    Top = 88
  end
  object ReferansQuery: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT KOD,FIRMA,CARIKODU,MUHKODU FROM REHBER')
    Left = 32
    Top = 120
  end
  object ReferansQueryDataSource: TDataSource
    DataSet = ReferansQuery
    Left = 64
    Top = 120
  end
  object hizmetlerQuery: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT KOD,ISLEMADI,OZELKOD,MUHKODU FROM ISLEMLER')
    Left = 32
    Top = 152
  end
  object HizmetlerQueryDataSource: TDataSource
    DataSet = hizmetlerQuery
    Left = 64
    Top = 152
  end
  object kurumQuery: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT KURUM,CARIKODU,MUHASEBEKODU FROM KURUM')
    Left = 32
    Top = 184
  end
  object kurumQueryDataSource: TDataSource
    DataSet = kurumQuery
    Left = 64
    Top = 184
  end
end
