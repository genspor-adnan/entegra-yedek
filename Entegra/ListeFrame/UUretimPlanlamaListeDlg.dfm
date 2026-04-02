object UretimPlanlamaListeDlg: TUretimPlanlamaListeDlg
  Left = 0
  Top = 0
  Width = 1014
  Height = 514
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 1014
    Height = 29
    Margins.Bottom = 0
    ButtonHeight = 30
    ButtonWidth = 71
    Caption = 'AletCubugu'
    Color = clTeal
    DockSite = True
    DrawingStyle = dsGradient
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esLowered
    EdgeOuter = esNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    GradientEndColor = 11776947
    GradientStartColor = 14540253
    HotTrackColor = 65408
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object YeniPlan: TToolButton
      Left = 0
      Top = 0
      AutoSize = True
      Caption = #304#351'lemler'
      DropdownMenu = PopupYeniIslemler
      EnableDropdown = True
      ImageIndex = 9
      ImageName = 'PngImage8'
      Indeterminate = True
    end
  end
  object GridUretimPlan: TcxGrid
    Left = 0
    Top = 29
    Width = 1014
    Height = 195
    Align = alClient
    PopupMenu = PopupYeniIslemler
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridUretimPlanView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridUretimPlanViewCanFocusRecord
      OnCellDblClick = GridUretimPlanViewCellDblClick
      DataController.DataSource = DtsUretimPlanlama
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Kind = skSum
          Position = spFooter
        end
        item
          Kind = skSum
          Position = spFooter
        end
        item
          Kind = skSum
          Position = spFooter
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skSum
        end
        item
          Kind = skSum
        end
        item
          Kind = skSum
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
      object GridUretimPlanViewKOD: TcxGridDBColumn
        Caption = 'Stok Kodu'
        DataBinding.FieldName = 'KOD'
        DataBinding.IsNullValueType = True
        Width = 92
      end
      object GridUretimPlanViewSTOKADI: TcxGridDBColumn
        Caption = 'Stok Ad'#305
        DataBinding.FieldName = 'STOKADI'
        DataBinding.IsNullValueType = True
        Width = 183
      end
      object GridUretimPlanViewGUNCELDEPO: TcxGridDBColumn
        Caption = 'G'#252'ncel Depo Durumu'
        DataBinding.FieldName = 'GUNCELDEPO'
        DataBinding.IsNullValueType = True
        Width = 68
      end
      object GridUretimPlanViewDEPODURUMU: TcxGridDBColumn
        Caption = 'Plan Depo Durumu'
        DataBinding.FieldName = 'DEPODURUMU'
        DataBinding.IsNullValueType = True
        Width = 56
      end
      object GridUretimPlanViewMINIMUMSTOK: TcxGridDBColumn
        Caption = 'Minimum Seviye'
        DataBinding.FieldName = 'MINIMUMSTOK'
        DataBinding.IsNullValueType = True
        Width = 92
      end
      object GridUretimPlanViewALINANSIPARIS: TcxGridDBColumn
        Caption = 'Al'#305'nan Sipari'#351
        DataBinding.FieldName = 'ALINANSIPARIS'
        DataBinding.IsNullValueType = True
        Width = 79
      end
      object GridUretimPlanViewVERILENSIPARIS: TcxGridDBColumn
        Caption = 'Verilen Sipari'#351
        DataBinding.FieldName = 'VERILENSIPARIS'
        DataBinding.IsNullValueType = True
        Width = 75
      end
      object GridUretimPlanViewURETIMEMRI: TcxGridDBColumn
        Caption = #220'r. Emri Miktar'
        DataBinding.FieldName = 'URETIMEMRI'
        DataBinding.IsNullValueType = True
        Width = 77
      end
      object GridUretimPlanViewURETIMOPERASYON: TcxGridDBColumn
        Caption = #220'r. Op. Miktar'
        DataBinding.FieldName = 'URETIMOPERASYON'
        DataBinding.IsNullValueType = True
        Width = 78
      end
      object GridUretimPlanViewURETIMFISI: TcxGridDBColumn
        Caption = #220'r. Fi'#351'i Miktar'
        DataBinding.FieldName = 'URETIMFISI'
        DataBinding.IsNullValueType = True
        Width = 78
      end
      object GridUretimPlanViewPLANDANKALAN: TcxGridDBColumn
        Caption = #220'r. Plan'#305' Kalan'
        DataBinding.FieldName = 'PLANDANKALAN'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridUretimPlanViewKALAN: TcxGridDBColumn
        Caption = #220'r. Emri Kalan'
        DataBinding.FieldName = 'EMIRDENKALAN'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 77
      end
      object GridUretimPlanViewOPDANKALAN: TcxGridDBColumn
        Caption = #220'r. Op. Kalan'
        DataBinding.FieldName = 'OPDANKALAN'
        DataBinding.IsNullValueType = True
        Visible = False
      end
    end
    object GridUretimPlanLevel1: TcxGridLevel
      Caption = 'Kasa'
      GridView = GridUretimPlanView
    end
  end
  object PageAlt: TcxPageControl
    Left = 0
    Top = 231
    Width = 1014
    Height = 283
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = SheetDepoDurumu
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 279
    ClientRectLeft = 4
    ClientRectRight = 1010
    ClientRectTop = 26
    object SheetDepoDurumu: TcxTabSheet
      Caption = 'Depo Durumu'
      ImageIndex = 0
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 1006
        Height = 253
        Align = alClient
        Caption = 'Panel2'
        TabOrder = 0
        object GridStokDurum: TcxGrid
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 727
          Height = 249
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridStokDurumView: TcxGridDBTableView
            OnDblClick = GridStokDurumViewDblClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = dtsStokDurum
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = '0;'
                Kind = skSum
                FieldName = 'GIREN'
                Column = clmDurumGiren
                DisplayText = '0;'
              end
              item
                Format = '0;'
                Kind = skSum
                FieldName = 'CIKAN'
                Column = clmDurumCikan
                DisplayText = '0;'
              end
              item
                Format = '0;'
                Kind = skSum
                FieldName = 'KALAN'
                Column = clmDurumKalan
                DisplayText = '0;'
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.HideSelection = True
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object clmDurumDepoAdi: TcxGridDBColumn
              Caption = 'Depo Ad'#305
              DataBinding.FieldName = 'DEPOADI'
              DataBinding.IsNullValueType = True
              Width = 156
            end
            object clmDurumSKT: TcxGridDBColumn
              DataBinding.FieldName = 'SKT'
              DataBinding.IsNullValueType = True
              Width = 86
            end
            object clmDurumGiren: TcxGridDBColumn
              Caption = 'Giren'
              DataBinding.FieldName = 'GIREN'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
            end
            object clmDurumCikan: TcxGridDBColumn
              Caption = #199#305'kan'
              DataBinding.FieldName = 'CIKAN'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
            end
            object clmDurumKalan: TcxGridDBColumn
              Caption = 'Kalan'
              DataBinding.FieldName = 'KALAN'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
              Width = 59
            end
            object clmKritikSeviye: TcxGridDBColumn
              Caption = 'Kritik Seviye'
              DataBinding.FieldName = 'KSEVIYE'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
              Width = 71
            end
            object GridStokDurumViewSUBEID: TcxGridDBColumn
              Caption = #350'ube'
              DataBinding.FieldName = 'SUBEID'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
              Options.Editing = False
            end
          end
          object GridStokDurumLevel1: TcxGridLevel
            GridView = GridStokDurumView
          end
        end
        object cxGrid1: TcxGrid
          AlignWithMargins = True
          Left = 731
          Top = 2
          Width = 273
          Height = 249
          Margins.Left = 1
          Margins.Top = 1
          Margins.Right = 1
          Margins.Bottom = 1
          Align = alRight
          TabOrder = 1
          LevelTabs.CaptionAlignment = taLeftJustify
          LookAndFeel.ScrollbarMode = sbmClassic
          object cxGrid1DBTableViewDurum: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsStokDurumDetay
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsView.GroupByBox = False
            object cxGrid1DBTableViewDurumTIP: TcxGridDBColumn
              Caption = 'Tip'
              DataBinding.FieldName = 'TIP'
              DataBinding.IsNullValueType = True
              Width = 99
            end
            object cxGrid1DBTableViewDurumADET: TcxGridDBColumn
              Caption = 'Miktar'
              DataBinding.FieldName = 'ADET'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
              Width = 82
            end
            object cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
              Width = 42
            end
          end
          object cxGrid1Level2: TcxGridLevel
            Caption = 'Depo Durumu'
            GridView = cxGrid1DBTableViewDurum
          end
        end
      end
    end
    object SheetAlinanSiparis: TcxTabSheet
      Caption = 'Al'#305'nan Sipari'#351'ler'
      ImageIndex = 1
      object cxGrid2: TcxGrid
        Left = 0
        Top = 0
        Width = 1006
        Height = 253
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView1: TcxGridDBTableView
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
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsAlinanSiparis
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsCustomize.ColumnsQuickCustomization = True
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
          object cxGridDBTableView1SIPARISID: TcxGridDBColumn
            Caption = 'ID'
            DataBinding.FieldName = 'SIPARISID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridDBTableView1SIPARISNO: TcxGridDBColumn
            Caption = 'Sipari'#351' No'
            DataBinding.FieldName = 'SIPARISNO'
            DataBinding.IsNullValueType = True
            Width = 59
          end
          object cxGridDBTableView1FIRMA: TcxGridDBColumn
            Caption = 'Cari '#220'nvan'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 172
          end
          object cxGridDBTableView1SIPARISTARIH: TcxGridDBColumn
            Caption = 'Sipari'#351' Tarihi'
            DataBinding.FieldName = 'SIPARISTARIH'
            DataBinding.IsNullValueType = True
            Width = 109
          end
          object cxGridDBTableView1TESLIMTARIHI: TcxGridDBColumn
            Caption = 'Teslim Tarihi'
            DataBinding.FieldName = 'TESLIMTARIHI'
            DataBinding.IsNullValueType = True
            Width = 102
          end
          object cxGridDBTableView1MIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            Width = 47
          end
          object cxGridDBTableView1SIPARISACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama1'
            DataBinding.FieldName = 'SIPARISACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 254
          end
          object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama2'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 253
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
    object SheetVerilenSiparis: TcxTabSheet
      Caption = 'Verilen Sipari'#351'ler'
      ImageIndex = 2
      object cxGrid3: TcxGrid
        Left = 0
        Top = 0
        Width = 1006
        Height = 253
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView2: TcxGridDBTableView
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
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsVerilenSiparis
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsCustomize.ColumnsQuickCustomization = True
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
          object cxGridDBColumn1: TcxGridDBColumn
            Caption = 'ID'
            DataBinding.FieldName = 'SIPARISID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Sipari'#351' No'
            DataBinding.FieldName = 'SIPARISNO'
            DataBinding.IsNullValueType = True
            Width = 57
          end
          object cxGridDBTableView2FIRMA: TcxGridDBColumn
            Caption = 'Cari '#220'nvan'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Width = 180
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Sipari'#351' Tarihi'
            DataBinding.FieldName = 'SIPARISTARIH'
            DataBinding.IsNullValueType = True
            Width = 88
          end
          object cxGridDBTableView2TESLIMTARIHI: TcxGridDBColumn
            Caption = 'Teslim Tarihi'
            DataBinding.FieldName = 'TESLIMTARIHI'
            DataBinding.IsNullValueType = True
            Width = 89
          end
          object cxGridDBColumn5: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            Width = 52
          end
          object cxGridDBColumn6: TcxGridDBColumn
            Caption = 'A'#231#305'klama1'
            DataBinding.FieldName = 'SIPARISACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 267
          end
          object cxGridDBColumn7: TcxGridDBColumn
            Caption = 'A'#231#305'klama2'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 263
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = cxGridDBTableView2
        end
      end
    end
    object SheetUretimEmri: TcxTabSheet
      Caption = #220'retim Emri'
      ImageIndex = 3
      object cxGrid4: TcxGrid
        Left = 0
        Top = 0
        Width = 1006
        Height = 253
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView3: TcxGridDBTableView
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
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsUretimEmri
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsCustomize.ColumnsQuickCustomization = True
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
          object cxGridDBTableView3EKLEYEN: TcxGridDBColumn
            Caption = 'Ekleyen'
            DataBinding.FieldName = 'EKLEYEN'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesi
            Width = 83
          end
          object cxGridDBTableView3BASTAR: TcxGridDBColumn
            Caption = 'Ba'#351'lama'
            DataBinding.FieldName = 'BASTAR'
            DataBinding.IsNullValueType = True
            Width = 98
          end
          object cxGridDBTableView3BITTAR: TcxGridDBColumn
            Caption = 'Biti'#351
            DataBinding.FieldName = 'BITTAR'
            DataBinding.IsNullValueType = True
            Width = 102
          end
          object cxGridDBTableView3ONAYLAYAN: TcxGridDBColumn
            Caption = 'Onaylayan'
            DataBinding.FieldName = 'ONAYLAYAN'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesi
            Width = 85
          end
          object cxGridDBTableView3URETIMEMRIMIKTAR: TcxGridDBColumn
            Caption = #220'r. Emri Miktar'
            DataBinding.FieldName = 'URETIMEMRIMIKTAR'
            DataBinding.IsNullValueType = True
            Width = 83
          end
          object cxGridDBTableView3URETIMOPMIKTAR: TcxGridDBColumn
            Caption = #220'r. Op. Miktar'
            DataBinding.FieldName = 'URETIMOPMIKTAR'
            DataBinding.IsNullValueType = True
            Width = 81
          end
          object cxGridDBTableView3URETIMFISMIKTAR: TcxGridDBColumn
            Caption = #220'r. Fi'#351'i Miktar'
            DataBinding.FieldName = 'URETIMFISMIKTAR'
            DataBinding.IsNullValueType = True
            Width = 78
          end
          object cxGridDBTableView3ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.cxEditRepository1Label1
            Width = 386
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = cxGridDBTableView3
        end
      end
    end
    object SheetUretimOp: TcxTabSheet
      Caption = #220'retim Operasyonu'
      ImageIndex = 5
      object cxGrid5: TcxGrid
        Left = 0
        Top = 0
        Width = 1006
        Height = 253
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView4: TcxGridDBTableView
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
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsUretimOperasyon
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsCustomize.ColumnsQuickCustomization = True
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
          object cxGridDBColumn8: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'LOKASYONADI'
            DataBinding.IsNullValueType = True
            Width = 216
          end
          object cxGridDBColumn9: TcxGridDBColumn
            Caption = #304#351' Merkezi'
            DataBinding.FieldName = 'ISMERKEZIADI'
            DataBinding.IsNullValueType = True
            Width = 330
          end
          object cxGridDBColumn10: TcxGridDBColumn
            Caption = 'Personel'
            DataBinding.FieldName = 'PERSONEL'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesi
            Width = 162
          end
          object cxGridDBColumn12: TcxGridDBColumn
            Caption = #220'r. Op Miktar'
            DataBinding.FieldName = 'URETIMOPMIKTAR'
            DataBinding.IsNullValueType = True
            Width = 162
          end
          object cxGridDBColumn13: TcxGridDBColumn
            Caption = #220'r Fi'#351'i Miktar'
            DataBinding.FieldName = 'URETIMFISMIKTAR'
            DataBinding.IsNullValueType = True
            Width = 160
          end
        end
        object cxGridLevel4: TcxGridLevel
          GridView = cxGridDBTableView4
        end
      end
    end
    object SheetUretimFisi: TcxTabSheet
      Caption = #220'retim Fi'#351'i'
      ImageIndex = 4
      object cxGrid6: TcxGrid
        Left = 0
        Top = 0
        Width = 1006
        Height = 253
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView5: TcxGridDBTableView
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
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsUretimFis
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnCycle = True
          OptionsCustomize.ColumnsQuickCustomization = True
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
          object cxGridDBTableView5URETIMTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'URETIMTARIH'
            DataBinding.IsNullValueType = True
            Width = 122
          end
          object cxGridDBTableView5ISTASYON: TcxGridDBColumn
            Caption = #304'stasyon'
            DataBinding.FieldName = 'ISTASYON'
            DataBinding.IsNullValueType = True
            Width = 154
          end
          object cxGridDBTableView5LOKASYONADI: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'LOKASYONADI'
            DataBinding.IsNullValueType = True
            Width = 155
          end
          object cxGridDBTableView5SORUMLUADI: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'SORUMLUADI'
            DataBinding.IsNullValueType = True
            Width = 161
          end
          object cxGridDBTableView5ONAYLAYANADI: TcxGridDBColumn
            Caption = 'Onaylayan'
            DataBinding.FieldName = 'ONAYLAYANADI'
            DataBinding.IsNullValueType = True
            Width = 227
          end
          object cxGridDBTableView5URETIMFISMIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'URETIMFISMIKTAR'
            DataBinding.IsNullValueType = True
            Width = 245
          end
        end
        object cxGridLevel5: TcxGridLevel
          GridView = cxGridDBTableView5
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 224
    Width = 1014
    Height = 7
    AlignSplitter = salBottom
    Control = PageAlt
  end
  object MemoSiparisAra: TMemo
    Left = 416
    Top = 64
    Width = 185
    Height = 89
    Lines.Strings = (
      
        'select SD.ID,SIPARISTARIH,SIPARISSERI,SIPARISNO,S.SUBEID,R.FIRMA' +
        ',ST.KOD,ST.STOKADI,ST.OZELLIK,ST.TIPI,SD.MIKTAR,'
      'RECETE=case when UR.ID is null then '#39'Yok'#39' else '#39'Var'#39' end'
      'from SIPARIS S inner join '
      'REHBER R on S.REHBERID=R.ID inner join '
      'SIPARISDETAY SD on SD.SIPARISID=S.ID inner join '
      'STOKLAR ST on SD.TUR=1 and SD.URUNID=ST.ID left outer join'
      'URETIMRECETE UR on UR.STOKID=ST.ID'
      'where isnull(SD.URETIMPLANDETAYID,0) = 0 ')
    TabOrder = 4
    Visible = False
    WordWrap = False
  end
  object DtsUretimPlanlama: TDataSource
    DataSet = TabUretimPlanlama
    Left = 63
    Top = 130
  end
  object TabUretimPlanlama: TFDQuery
    AfterScroll = TabUretimPlanlamaAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      #9'*, '
      
        #9'GUNCELDEPO=(select KALAN from STOKDURUM where STOKID=ads.STOKID' +
        ' and DEPOID=ads.DEPOID),'
      #9'PLANDANKALAN=GEREKLIURETIM-URETIMFISI,'
      #9'EMIRDENKALAN=URETIMEMRI-URETIMFISI,'
      #9'OPDANKALAN=URETIMOPERASYON-URETIMFISI'
      'from '
      #9'('
      #9'select '
      #9#9'S.KOD,S.STOKADI,S.IZLEME,UPD.*,UP.DEPOID,'
      
        #9#9'URETIMEMRI=isnull((select sum(MIKTAR) from URETIMEMRI where UR' +
        'ETIMPLANDETAYID=UPD.ID),0.0),'
      
        #9#9'URETIMOPERASYON=isnull((select sum(UO.MIKTAR) from URETIMOPERA' +
        'SYON UO where UO.URETIMPLANDETAYID=UPD.ID and UO.STOKID=UPD.STOK' +
        'ID),0.0),'
      
        #9#9'URETIMFISI=isnull((select sum(F.MIKTAR) from FATURA F where F.' +
        'URETIMPLANDETAYID=UPD.ID and F.TUR=1 and F.URUNID=UPD.STOKID),0.' +
        '0)'
      #9'from '
      #9#9'URETIMPLANLAMADETAY UPD inner join '
      #9#9'STOKLAR S on UPD.STOKID=S.ID inner join '
      #9#9'URETIMPLANLAMA UP on UP.ID=UPD.URETIMPLANLAMAID'
      #9'where UPD.URETIMPLANLAMAID=:PID'
      #9')as ads'
      'where '
      #9
      
        #9'((URETIMEMRI<>0.0)or(URETIMOPERASYON<>0.0)or(URETIMFISI<>0.0)or' +
        '(DEPODURUMU<>0.0)or(ALINANSIPARIS<>0.0)or(VERILENSIPARIS<>0.0))'
      'order by 2')
    Left = 62
    Top = 75
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object TabAlinanSiparis: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select SD.SIPARISID,SI.SIPARISSERI,SI.SIPARISNO,SI.SIPARISTARIH,' +
        'SD.ADET,SD.BIRIM,SD.MIKTAR,SD.MF,SD.ACIKLAMA,SIPARISACIKLAMA=SI.' +
        'ACIKLAMA,SD.TESLIMTARIHI,R.FIRMA'
      
        'from SIPARISDETAY SD inner join SIPARIS SI on SD.SIPARISID=SI.ID' +
        ' inner join REHBER R on SI.REHBERID=R.ID '
      
        'where SI.TUR=19 and SD.TUR=1 and SD.URUNID=:PUrunID and SD.URETI' +
        'MPLANID=:UPID and SD.URETIMPLANDETAYID=:UPDID'
      #9#9#9#9#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9#9#9#9)
    Left = 260
    Top = 109
    ParamData = <
      item
        Name = 'PUrunID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end
      item
        Name = 'UPID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end
      item
        Name = 'UPDID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 1
      end>
  end
  object DtsAlinanSiparis: TDataSource
    DataSet = TabAlinanSiparis
    Left = 256
    Top = 156
  end
  object DtsVerilenSiparis: TDataSource
    DataSet = TabVerilenSiparis
    Left = 320
    Top = 140
  end
  object TabVerilenSiparis: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select SD.SIPARISID,SI.SIPARISSERI,SI.SIPARISNO,SI.SIPARISTARIH,' +
        'SD.ADET,SD.BIRIM,SD.MIKTAR,SD.MF,SD.ACIKLAMA,SIPARISACIKLAMA=SI.' +
        'ACIKLAMA,SD.TESLIMTARIHI,R.FIRMA'
      
        'from SIPARISDETAY SD inner join SIPARIS SI on SD.SIPARISID=SI.ID' +
        ' inner join REHBER R on SI.REHBERID=R.ID  '
      
        'where SI.TUR=9 and SD.TUR=1 and SD.URUNID=:PUrunID and SD.URETIM' +
        'PLANID=:UPID and SD.URETIMPLANDETAYID=:UPDID'#9#9#9#9#9#9#9#9#9#9#9#9
      #9#9#9#9#9#9#9#9#9#9#9)
    Left = 324
    Top = 93
    ParamData = <
      item
        Name = 'PUrunID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'UPID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'UPDID'#9#9#9#9#9#9#9#9#9#9#9#9
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsUretimEmri: TDataSource
    DataSet = TabUretimEmri
    Left = 368
    Top = 284
  end
  object TabUretimEmri: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select UE.ID,'
      #9'UE.EKLEYEN,'
      #9'UE.ONAYLAYAN,'
      #9'URETIMEMRIMIKTAR=UE.MIKTAR,'
      
        #9'URETIMOPMIKTAR=(select SUM(MIKTAR) from URETIMOPERASYON UO wher' +
        'e UO.URETIMEMRIID=UE.ID and UO.STOKID=UE.STOKID),'
      
        #9'URETIMFISMIKTAR=(select SUM(MIKTAR) from FATURA F inner join FA' +
        'TBASLIK FB on F.FATBASID=FB.ID where F.TUR=1 and F.URUNID=UE.STO' +
        'KID and FB.YERI=142 and FB.YERID in (select UO.ID from URETIMOPE' +
        'RASYON UO where UO.URETIMEMRIID=UE.ID and UO.STOKID=UE.STOKID)),'
      'BASTAR,BITTAR,UE.ACIKLAMA,UE.URETIMPLANID,UE.URETIMPLANDETAYID'
      ''
      'from URETIMEMRI UE '
      ''
      ''
      
        'where UE.STOKID=:PUrunID and UE.URETIMPLANID=:UPID and UE.URETIM' +
        'PLANDETAYID=:UPDID')
    Left = 364
    Top = 229
    ParamData = <
      item
        Name = 'PUrunID'
        DataType = ftWideString
        Size = 2
        Value = '40'
      end
      item
        Name = 'UPID'
        DataType = ftWideString
        Size = 1
        Value = '4'
      end
      item
        Name = 'UPDID'
        DataType = ftWideString
        Size = 1
        Value = '9'
      end>
  end
  object dtsStokDurum: TDataSource
    DataSet = tabStokDurum
    Left = 123
    Top = 144
  end
  object tabStokDurum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT     STOKID=S.ID, DEPOID=D.ID, D.DEPOADI, SD.GIREN, SD.CIK' +
        'AN, SD.KALAN,  S.MINSTOK,D.SUBEID'
      'FROM uv_Stok_StokDurum SD INNER JOIN'
      '     DEPOLAR D ON SD.STOKDEPOID = D.ID INNER JOIN'
      '     STOKLAR S ON SD.URUNID = S.ID'
      'WHERE'
      '    S.ID = :PSTOKID'
      '    AND D.DURUM = 1    ')
    Left = 122
    Top = 93
    ParamData = <
      item
        Name = 'PSTOKID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object TabStokDurumDetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @StokID int, @DepoID int,@StokAnabirim int'
      'set @StokID=:PStokID'
      'set @DepoID=:PDepoID'
      'select @StokAnabirim=ANABIRIM from STOKLAR where ID=@StokID'
      
        'select TIP='#39'Sipari'#351' Girecek'#39',ADET=sum(isnull(SD.MIKTAR,0)),BIRIM' +
        '=@StokAnabirim'
      'from SIPARIS S inner join SIPARISDETAY SD on S.ID=SD.SIPARISID'
      'where '
      
        #9'1=(case when @DepoID<=0 then 1 when S.GIRISDEPO=@DepoID then 1 ' +
        'else 0 end) and '
      #9'SD.URUNID=@StokID and '
      #9'SD.TUR=1 and '
      #9'S.TUR=9 and'
      #9'S.DURUM <> 6 and '
      
        #9'SD.ID not in (select F.YERID from FATURA F where F.YERI between' +
        ' 400 and 420)'
      'union all'
      
        'select TIP='#39'Sipari'#351' '#199#305'kacak'#39',ADET=-sum(isnull(SD.MIKTAR,0)),BIRI' +
        'M=@StokAnabirim'
      'from SIPARIS S inner join SIPARISDETAY SD on S.ID=SD.SIPARISID'
      'where '
      
        #9'1=(case when @DepoID<=0 then 1 when S.CIKISDEPO=@DepoID then 1 ' +
        'else 0 end) and '
      #9'SD.URUNID=@StokID and '
      #9'SD.TUR=1 and '
      #9'S.TUR=19 and'
      #9'S.DURUM <> 6 and '
      
        #9'SD.ID not in (select F.YERID from FATURA F where F.YERI between' +
        ' 400 and 420)'
      'union all'
      
        'select TIP='#39'Sipari'#351' Toplam'#39',ADET=sum(case when S.TUR=9 then SD.M' +
        'IKTAR when S.TUR=19 then -SD.MIKTAR else 0 end),BIRIM=@StokAnabi' +
        'rim'
      'from SIPARIS S inner join SIPARISDETAY SD on S.ID=SD.SIPARISID'
      'where '
      
        #9'1=(case when @DepoID<=0 then 1 when S.CIKISDEPO=@DepoID then 1 ' +
        'when S.GIRISDEPO=@DepoID then 1 else 0 end)and'
      #9'SD.URUNID=@StokID and '
      #9'SD.TUR=1 and '
      #9'S.DURUM <> 6 and '
      
        #9'SD.ID not in (select F.YERID from FATURA F where F.YERI between' +
        ' 400 and 420)'
      'union all '
      'select '#39'Depoya Giren'#39',ADET=sum(GIREN),BIRIM=@StokAnabirim '
      'from STOKDURUM D'
      'where '
      
        #9'1=(case when @DepoID<=0 then 1 when D.DEPOID=@DepoID then 1 els' +
        'e 0 end) and '
      #9'D.STOKID=@StokID  '
      'union all '
      'select '#39'Depodan '#199#305'kan'#39',ADET=sum(CIKAN),BIRIM=@StokAnabirim'
      'from STOKDURUM D'
      'where '
      
        #9'1=(case when @DepoID<=0 then 1 when D.DEPOID=@DepoID then 1 els' +
        'e 0 end) and '
      #9'D.STOKID=@StokID '
      'union all '
      
        'select '#39'Depo Toplam'#39',ADET=sum(GIREN)-sum(CIKAN),BIRIM=@StokAnabi' +
        'rim '
      'from STOKDURUM D'
      'where '
      
        #9'1=(case when @DepoID<=0 then 1 when D.DEPOID=@DepoID then 1 els' +
        'e 0 end) and '
      #9'D.STOKID=@StokID  ')
    Left = 211
    Top = 61
    ParamData = <
      item
        Name = 'PStokID'
        DataType = ftWideString
        Size = 4
        Value = '1407'
      end
      item
        Name = 'PDepoID'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
  end
  object DtsStokDurumDetay: TDataSource
    DataSet = TabStokDurumDetay
    Left = 188
    Top = 134
  end
  object PopupYeniIslemler: TPopupMenu
    Left = 472
    Top = 160
    object Plan1: TMenuItem
      Caption = #220'retim Plan'#305
      object Yeni1: TMenuItem
        Caption = 'Yeni '#220'retim Plan'#305
        OnClick = YeniPlanClick
      end
      object Sil1: TMenuItem
        Caption = #220'retim Plan'#305'n'#305' Sil'
        OnClick = Sil1Click
      end
      object PlanaSipariEkle1: TMenuItem
        Caption = 'Plana Sipari'#351' Ekle'
        OnClick = PlanaSipariEkle1Click
      end
      object SeiliSatrPlandankart1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'r'#305' Plandan '#199#305'kart'
        OnClick = SeiliSatrPlandankart1Click
      end
    end
    object retimEmri1: TMenuItem
      Caption = #220'retim Emri'
      object SeiliSatrinretimEmriOlutur1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'r '#304#231'in '#220'retim Emri Olu'#351'tur'
        OnClick = SeiliSatrinretimEmriOlutur1Click
      end
      object SeiliSatraBalretimEmirlerini1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'ra Ba'#287'l'#305' '#220'retim Emirlerini Sil '
        OnClick = SeiliSatraBalretimEmirlerini1Click
      end
      object Yeni2: TMenuItem
        Caption = #304'lgili T'#252'm '#220'retim Emirlerini Olu'#351'tur'
        OnClick = YeniUretimEmriClick
      end
      object Sil2: TMenuItem
        Caption = #304'lgili T'#252'm Emirleri Sil'
        OnClick = Sil2Click
      end
    end
    object retimOperasyonu1: TMenuItem
      Caption = #220'retim Operasyonu'
      object SeiliSatrinretimOperasyonuOlutur1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'r '#304#231'in '#220'retim Operasyonu Olu'#351'tur'
        OnClick = SeiliSatrinretimOperasyonuOlutur1Click
      end
      object SeiliSatraBalretimEmirleriniSil1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'ra Ba'#287'l'#305' '#220'retim Operasyonlar'#305'n'#305' Sil '
        OnClick = SeiliSatraBalretimEmirleriniSil1Click
      end
      object Yeni3: TMenuItem
        Caption = #304'lgili T'#252'm '#220'retim Operasyonlar'#305'n'#305' Olu'#351'tur'
        OnClick = YeniOperasyonClick
      end
      object Sil3: TMenuItem
        Caption = #304'lgili T'#252'm Operasyonlar'#305' Sil'
        OnClick = Sil3Click
      end
    end
    object retimFii1: TMenuItem
      Caption = #220'retim Fi'#351'i'
      object SeiliSatrinretimFiiOlutur1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'r '#304#231'in '#220'retim Fi'#351'i Olu'#351'tur'
        OnClick = SeiliSatrinretimFiiOlutur1Click
      end
      object SeiliSatraBalretimFileriniSil1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'ra Ba'#287'l'#305' '#220'retim Fi'#351'lerini Sil '
        OnClick = SeiliSatraBalretimFileriniSil1Click
      end
      object YeniFis: TMenuItem
        Caption = #304'lgili T'#252'm '#220'retim Fi'#351'lerini Olu'#351'tur'
        OnClick = YeniFisClick
      end
      object SilFis: TMenuItem
        Caption = #304'lgili T'#252'm Fi'#351'leri Sil'
        OnClick = SilFisClick
      end
    end
  end
  object TabUretimOperasyon: TFDQuery
    AfterScroll = TabUretimOperasyonAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      #9'LOKASYONADI=L1.ACIKLAMA,'
      #9'ISMERKEZIADI=L2.ACIKLAMA,'
      #9'UO.PERSONEL,'
      #9'URETIMOPMIKTAR=UO.MIKTAR,'
      
        #9'URETIMFISMIKTAR=(select SUM(MIKTAR) from FATURA F inner join FA' +
        'TBASLIK FB on F.FATBASID=FB.ID where F.TUR=1 and F.URUNID=UO.STO' +
        'KID and FB.YERI=142 and FB.YERID=UO.ID),'
      'UO.RECETEID,UO.RECETEDETAYID,UO.URETIMEMRIDETAYID'
      
        'from URETIMEMRI UE inner join URETIMOPERASYON UO on UE.ID=UO.URE' +
        'TIMEMRIID'
      ''
      'left outer join LOKASYON L1 on UO.LOKASYON=L1.ID'
      'left outer join LOKASYON L2 on UO.ISMERKEZI=L2.ID'
      ''
      
        'where UO.STOKID=:PUrunID and UO.URETIMPLANID=:UPID and UO.URETIM' +
        'PLANDETAYID=:UPDID'#9)
    Left = 436
    Top = 221
    ParamData = <
      item
        Name = 'PUrunID'
        DataType = ftWideString
        Size = 2
        Value = '40'
      end
      item
        Name = 'UPID'
        DataType = ftWideString
        Size = 1
        Value = '4'
      end
      item
        Name = 'UPDID'#9
        DataType = ftWideString
        Size = 1
        Value = '9'
      end>
  end
  object DtsUretimOperasyon: TDataSource
    DataSet = TabUretimOperasyon
    Left = 440
    Top = 276
  end
  object TabUretimFis: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      #9'URETIMTARIH=FB.FATURATARIH,'
      
        #9'ISTASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.ISYER' +
        'I), '
      
        #9'LOKASYONADI=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.LO' +
        'KASYON),'
      
        #9'SORUMLUADI=(select R.FIRMA from REHBER R where R.ID=FB.SATICIKO' +
        'DU),'
      
        #9'ONAYLAYANADI=(select R.FIRMA from REHBER R where R.ID=FB.ONAYLA' +
        'YAN),'
      #9'URETIMFISMIKTAR=F.MIKTAR'
      'from URETIMEMRI UE '
      'inner join URETIMOPERASYON UO on UE.ID=UO.URETIMEMRIID'
      'inner join  FATBASLIK FB on FB.YERI=142 and FB.YERID=UO.ID'
      
        'inner join FATURA F on F.FATBASID=FB.ID and F.TUR=1 and F.URUNID' +
        '=UO.STOKID'
      ''
      
        'where UO.STOKID=:PUrunID and UO.URETIMPLANID=:UPID and UO.URETIM' +
        'PLANDETAYID=:UPDID'#9)
    Left = 500
    Top = 237
    ParamData = <
      item
        Name = 'PUrunID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 40
      end
      item
        Name = 'UPID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 4
      end
      item
        Name = 'UPDID'#9
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 9
      end>
  end
  object DtsUretimFis: TDataSource
    DataSet = TabUretimFis
    Left = 504
    Top = 292
  end
  object TabUretimEmriDetay: TFDQuery
    Connection = Tablo.FDCnn
    Left = 592
    Top = 224
  end
end
