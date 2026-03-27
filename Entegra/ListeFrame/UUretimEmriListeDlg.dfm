object UretimEmriListeDlg: TUretimEmriListeDlg
  Left = 0
  Top = 0
  Width = 1391
  Height = 637
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1385
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 59
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
    ExplicitHeight = 29
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 59
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 118
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object GorTus: TToolButton
      Left = 126
      Top = 0
      Caption = 'G'#246'r'
      ImageIndex = 9
      ImageName = 'PngImage8'
      OnClick = GorTusClick
    end
  end
  object GridUretimEmri: TcxGrid
    Left = 0
    Top = 35
    Width = 1391
    Height = 394
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridUretimEmriView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridUretimEmriViewCanFocusRecord
      OnCellDblClick = GridUretimEmriViewCellDblClick
      DataController.DataSource = DtsUretimEmri
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
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
      OptionsView.GroupFooters = gfAlwaysVisible
      object GridUretimEmriViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Width = 38
      end
      object GridUretimEmriViewKOCANNO: TcxGridDBColumn
        Caption = 'Seri No'
        DataBinding.FieldName = 'SERINO'
        DataBinding.IsNullValueType = True
      end
      object GridUretimEmriViewEMIRNO: TcxGridDBColumn
        Caption = 'Emir No'
        DataBinding.FieldName = 'EMIRNO'
        DataBinding.IsNullValueType = True
      end
      object GridUretimEmriViewTALEPTARIHI: TcxGridDBColumn
        Caption = 'Talep Tarihi'
        DataBinding.FieldName = 'TALEPTARIHI'
        DataBinding.IsNullValueType = True
      end
      object GridUretimEmriViewEKLEMETARIHI: TcxGridDBColumn
        Caption = 'Ekleme Tarihi'
        DataBinding.FieldName = 'EKLEMETARIHI'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 129
      end
      object GridUretimEmriViewBASTAR: TcxGridDBColumn
        Caption = 'Ba'#351'lama'
        DataBinding.FieldName = 'BASTAR'
        DataBinding.IsNullValueType = True
        Width = 123
      end
      object GridUretimEmriViewBITTAR: TcxGridDBColumn
        Caption = 'Biti'#351
        DataBinding.FieldName = 'BITTAR'
        DataBinding.IsNullValueType = True
        Width = 120
      end
      object GridUretimEmriViewTERMINTARIHI: TcxGridDBColumn
        Caption = 'Termin Tarihi'
        DataBinding.FieldName = 'TERMINTARIHI'
        DataBinding.IsNullValueType = True
      end
      object GridUretimEmriViewURUNNO: TcxGridDBColumn
        Caption = #220'r'#252'n No'
        DataBinding.FieldName = 'URUNNO'
        DataBinding.IsNullValueType = True
        Width = 87
      end
      object GridUretimEmriViewSTOKKODU: TcxGridDBColumn
        Caption = 'Stok Kodu'
        DataBinding.FieldName = 'STOKKODU'
        DataBinding.IsNullValueType = True
        Width = 70
      end
      object GridUretimEmriViewSTOKADI: TcxGridDBColumn
        Caption = 'Stok Ad'#305
        DataBinding.FieldName = 'STOKADI'
        DataBinding.IsNullValueType = True
        Width = 167
      end
      object GridUretimEmriViewDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepAktifPasif
      end
      object GridUretimEmriViewEMIRTURU: TcxGridDBColumn
        Caption = 'Emir T'#252'r'#252
        DataBinding.FieldName = 'EMIRTURU'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repUretimEmirTuru
      end
      object GridUretimEmriViewANAKAYNAK: TcxGridDBColumn
        Caption = 'Ana Kaynak'
        DataBinding.FieldName = 'ANAKAYNAKAD'
        DataBinding.IsNullValueType = True
      end
      object GridUretimEmriViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridUretimEmriViewONAYLAYACAK: TcxGridDBColumn
        Caption = 'Onaylayacak'
        DataBinding.FieldName = 'ONAYLAYACAK'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repGenelPersonelListesi
        Width = 71
      end
      object GridUretimEmriViewONAY: TcxGridDBColumn
        Caption = 'Onay'
        DataBinding.FieldName = 'ONAY'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repOnayliOnaysiz
        Width = 70
      end
      object GridUretimEmriViewONAYLAYAN: TcxGridDBColumn
        Caption = 'Onaylayan'
        DataBinding.FieldName = 'ONAYLAYAN'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repGenelPersonelListesi
        Width = 98
      end
      object GridUretimEmriViewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridUretimEmriViewYETKIKODU: TcxGridDBColumn
        Caption = 'Yetki Kodu'
        DataBinding.FieldName = 'YETKIKODU'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridUretimEmriViewADET: TcxGridDBColumn
        Caption = 'Adet'
        DataBinding.FieldName = 'ADET'
        DataBinding.IsNullValueType = True
      end
      object GridUretimEmriViewBIRIM: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'BIRIM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.repStokAnaBirim
      end
      object GridUretimEmriViewACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        Width = 233
      end
      object GridUretimEmriViewColumn1: TcxGridDBColumn
        Caption = 'Proje Kodu'
        DataBinding.FieldName = 'PROJEKODU'
        DataBinding.IsNullValueType = True
      end
    end
    object GridUretimEmriLevel1: TcxGridLevel
      Caption = 'Kasa'
      GridView = GridUretimEmriView
    end
  end
  object PageAlt: TcxPageControl
    Left = 0
    Top = 436
    Width = 1391
    Height = 201
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = SheetDetay
    Properties.CustomButtons.Buttons = <>
    OnPageChanging = PageAltPageChanging
    ClientRectBottom = 197
    ClientRectLeft = 4
    ClientRectRight = 1387
    ClientRectTop = 26
    object SheetDetay: TcxTabSheet
      Caption = #220'retim A'#287'ac'#305
      ImageIndex = 0
      object TreeUretimAgaci: TcxDBTreeList
        Left = 0
        Top = 0
        Width = 1383
        Height = 171
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsUretimAgaci
        DataController.ParentField = 'USTID'
        DataController.KeyField = 'ID'
        LookAndFeel.ScrollbarMode = sbmClassic
        Navigator.Buttons.CustomButtons = <>
        OptionsData.Editing = False
        OptionsData.Deleting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRect = False
        OptionsSelection.InvertSelect = False
        OptionsView.Footer = True
        OptionsView.Indicator = True
        RootValue = -1
        ScrollbarAnnotations.CustomAnnotations = <>
        TabOrder = 0
        OnCustomDrawDataCell = TreeUretimAgaciCustomDrawDataCell
        object TreeUretimAgacicxDBTreeListID: TcxDBTreeListColumn
          Visible = False
          DataBinding.FieldName = 'ID'
          Width = 100
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListGereksinim: TcxDBTreeListColumn
          Caption.Text = #304'stenen'
          DataBinding.FieldName = 'MIKTAR'
          Width = 59
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListBirim: TcxDBTreeListColumn
          RepositoryItem = Tablo.repStokAnaBirim
          Visible = False
          Caption.Text = 'Birim'
          DataBinding.FieldName = 'BIRIM'
          Width = 100
          Position.ColIndex = 8
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListURUNNO: TcxDBTreeListColumn
          Caption.Text = #220'r'#252'n No'
          DataBinding.FieldName = 'URUNNO'
          Position.ColIndex = 15
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListAd: TcxDBTreeListColumn
          Caption.Text = 'Ad'
          DataBinding.FieldName = 'AD'
          Width = 100
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListKod: TcxDBTreeListColumn
          Caption.Text = 'Kod'
          DataBinding.FieldName = 'KOD'
          Width = 100
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListUretilecek: TcxDBTreeListColumn
          Caption.Text = #220'retilecek(Op.)'
          DataBinding.FieldName = 'URETILECEK'
          Width = 80
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListYuzde: TcxDBTreeListColumn
          PropertiesClassName = 'TcxProgressBarProperties'
          Properties.OverloadValue = 100.000000000000000000
          Properties.ShowPeak = True
          Visible = False
          Caption.Text = 'Y'#252'zde'
          DataBinding.FieldName = 'YuzdeHesap'
          Width = 87
          Position.ColIndex = 10
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListTuketilen: TcxDBTreeListColumn
          Caption.Text = 'T'#252'ketilen(Fi'#351')'
          DataBinding.FieldName = 'TUKETILEN'
          Width = 73
          Position.ColIndex = 6
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListUretilen: TcxDBTreeListColumn
          Caption.Text = #220'retilen(Fi'#351')'
          DataBinding.FieldName = 'URETILEN'
          Width = 69
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListDepo: TcxDBTreeListColumn
          Caption.Text = 'Depo Durumu'
          DataBinding.FieldName = 'DEPODURUMU'
          Width = 75
          Position.ColIndex = 7
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListBirimMaliyet: TcxDBTreeListColumn
          RepositoryItem = Tablo.RepCurrencyBF
          Caption.Text = 'Birim Maliyet'
          DataBinding.FieldName = 'BIRIMMALIYET'
          Options.Editing = False
          Width = 91
          Position.ColIndex = 11
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListToplamMaliyet: TcxDBTreeListColumn
          RepositoryItem = Tablo.RepCurrencyGenel
          Caption.Text = 'Toplam Maliyet'
          DataBinding.FieldName = 'TOPLAMMALIYET'
          Options.Editing = False
          Width = 100
          Position.ColIndex = 13
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <
            item
              AlignHorz = taLeftJustify
              Kind = skSum
            end>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListKur: TcxDBTreeListColumn
          Caption.Text = 'P. Birimi'
          DataBinding.FieldName = 'KUR'
          Options.Editing = False
          Width = 54
          Position.ColIndex = 14
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListBIRIMURETIMMALIYETI: TcxDBTreeListColumn
          RepositoryItem = Tablo.RepCurrencyBF
          Caption.Text = 'Birim '#220'retim Maliyeti'
          DataBinding.FieldName = 'BIRIMURETIMMALIYETI'
          Options.Editing = False
          Width = 105
          Position.ColIndex = 12
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <
            item
              AlignHorz = taLeftJustify
              Kind = skSum
            end>
          Summary.GroupFooterSummaryItems = <>
        end
        object TreeUretimAgacicxDBTreeListDEPOGEREKSINIM: TcxDBTreeListColumn
          Caption.Text = 'Depo Gereksinimi'
          DataBinding.FieldName = 'DEPOGEREKSINIM'
          Width = 89
          Position.ColIndex = 9
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
    object cxTabSheet1: TcxTabSheet
      Caption = 'Operasyonlar'
      ImageIndex = 1
      object GridUrtOperasyon: TcxGrid
        Left = 0
        Top = 0
        Width = 1383
        Height = 171
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridUrtOperasyonDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsUretimOperasyon
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.CellSelect = False
          OptionsSelection.HideFocusRectOnExit = False
          OptionsSelection.InvertSelect = False
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.GroupByBox = False
          object GridUrtOperasyonDBTableView1URUNNO: TcxGridDBColumn
            Caption = #220'r'#252'n No'
            DataBinding.FieldName = 'URUNNO'
            DataBinding.IsNullValueType = True
          end
          object GridUrtOperasyonDBTableView1STOKADI: TcxGridDBColumn
            Caption = #220'retilecek Stok'
            DataBinding.FieldName = 'STOKADI'
            DataBinding.IsNullValueType = True
            Width = 89
          end
          object GridUrtOperasyonDBTableView1PERSONEL: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'PERSONEL'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repGenelPersonelListesi
          end
          object GridUrtOperasyonDBTableView1BASTAR: TcxGridDBColumn
            Caption = 'Ba'#351'lama(Plan)'
            DataBinding.FieldName = 'BASTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.DateButtons = [btnClear, btnNow, btnToday]
            Properties.ImmediatePost = True
            Properties.Kind = ckDateTime
            Width = 115
          end
          object GridUrtOperasyonDBTableView1BITTAR: TcxGridDBColumn
            Caption = 'Biti'#351'(Plan)'
            DataBinding.FieldName = 'BITTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.DateButtons = [btnClear, btnNow, btnToday]
            Properties.ImmediatePost = True
            Properties.Kind = ckDateTime
            Width = 115
          end
          object GridUrtOperasyonDBTableView1LOKASYON: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'LOKASYONADI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = True
            Width = 75
          end
          object GridUrtOperasyonDBTableView1ISMERKEZI: TcxGridDBColumn
            Caption = #304'stasyon'
            DataBinding.FieldName = 'ISMERKEZIADI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.ReadOnly = True
            Width = 71
          end
          object GridUrtOperasyonDBTableView1GIRISDEPO: TcxGridDBColumn
            Caption = 'Giri'#351' Depo'
            DataBinding.FieldName = 'GIRISDEPO'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepStokDepolarTumu
          end
          object GridUrtOperasyonDBTableView1CIKISDEPO: TcxGridDBColumn
            Caption = #199#305'k'#305#351' Depo'
            DataBinding.FieldName = 'CIKISDEPO'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepStokDepolarTumu
          end
          object GridUrtOperasyonDBTableView1ADET: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
          end
          object GridUrtOperasyonDBTableView1BIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repStokAnaBirim
            Options.Editing = False
            Options.Focusing = False
          end
          object GridUrtOperasyonDBTableView1GERCEKLESEN: TcxGridDBColumn
            Caption = 'Ger'#231'ekle'#351'en'
            DataBinding.FieldName = 'GERCEKLESEN'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Width = 78
          end
          object GridUrtOperasyonDBTableView1GBASTAR: TcxGridDBColumn
            Caption = 'Ba'#351'lama(Ger'#231'ekle'#351'en)'
            DataBinding.FieldName = 'GBASTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ImmediatePost = True
            Properties.Kind = ckDateTime
            Options.Editing = False
            Options.Focusing = False
            Width = 115
          end
          object GridUrtOperasyonDBTableView1GBITTAR: TcxGridDBColumn
            Caption = 'Biti'#351'(Ger'#231'ekle'#351'en)'
            DataBinding.FieldName = 'GBITTAR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ImmediatePost = True
            Properties.Kind = ckDateTime
            Options.Editing = False
            Options.Focusing = False
            Width = 115
          end
          object GridUrtOperasyonDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 274
          end
          object GridUrtOperasyonDBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
            Options.Editing = False
            Options.Focusing = False
          end
        end
        object GridUrtOperasyonLevel1: TcxGridLevel
          GridView = GridUrtOperasyonDBTableView1
        end
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'Maliyet'
      ImageIndex = 2
      object cxGrid1: TcxGrid
        Left = 0
        Top = 0
        Width = 1383
        Height = 171
        Align = alClient
        TabOrder = 0
        LookAndFeel.ScrollbarMode = sbmClassic
        object cxGridDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsUrToplamMaliyet
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Kind = skSum
              Position = spFooter
              Column = cxGridDBTableView1TUTAR
            end
            item
              Kind = skSum
              Position = spFooter
              Column = cxGridDBTableView1BIRIMMALIYET
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Kind = skSum
              Column = cxGridDBTableView1TUTAR
            end
            item
              Kind = skSum
              Column = cxGridDBTableView1BIRIMMALIYET
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsSelection.CellSelect = False
          OptionsSelection.HideFocusRectOnExit = False
          OptionsSelection.InvertSelect = False
          OptionsSelection.UnselectFocusedRecordOnExit = False
          OptionsView.Footer = True
          OptionsView.FooterAutoHeight = True
          OptionsView.FooterMultiSummaries = True
          OptionsView.GroupByBox = False
          OptionsView.GroupFooterMultiSummaries = True
          OptionsView.GroupFooters = gfVisibleWhenExpanded
          object cxGridDBTableView1TIP: TcxGridDBColumn
            Caption = 'Tip'
            DataBinding.FieldName = 'TIP'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Hizmet'
                ImageIndex = 0
                Value = '2'
              end
              item
                Description = 'Hammadde'
                Value = '1'
              end>
          end
          object cxGridDBTableView1KOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
          end
          object cxGridDBTableView1AD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Width = 164
          end
          object cxGridDBTableView1BIRIMMALIYET: TcxGridDBColumn
            Caption = 'Birim Maliyet'
            DataBinding.FieldName = 'BIRIMMALIYET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 84
          end
          object cxGridDBTableView1TUTAR: TcxGridDBColumn
            Caption = 'Maliyet'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 94
          end
          object cxGridDBTableView1KUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
          end
          object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 422
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = cxGridDBTableView1
        end
      end
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 429
    Width = 1391
    Height = 7
    AlignSplitter = salBottom
    Control = PageAlt
  end
  object DtsUretimEmri: TDataSource
    DataSet = TabUretimEmri
    Left = 255
    Top = 82
  end
  object TabUretimEmri: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabUretimEmriAfterScroll
    BeforeClose = TabUretimEmriBeforeClose
    AfterScroll = TabUretimEmriAfterScroll
    ParamData = <>
    SQL.Strings = (
      'select U.*, '
      ' STOKKODU=(select KOD from STOKLAR where ID=U.STOKID), '
      
        ' S.STOKADI,  URUNNO =  (SELECT URUNNO FROM STOKLAR S WHERE ID = ' +
        'U.STOKID),'
      
        ' PROJEKODU=(select PROJEKODU from PROJELER P where P.ID=U.PROJEI' +
        'D),  '
      
        ' ANAKAYNAKAD = (SELECT ACIKLAMA FROM LOKASYON WHERE ID=U.ANAKAYN' +
        'AK),  '
      ' FIRMAAD=  (SELECT FIRMA FROM REHBER WHERE ID=U.REHBERID)  '
      ' from URETIMEMRI U left join STOKLAR S on S.ID=U.STOKID '
      ' where 1=1 '
      ' and U.BASTAR >='#39'2023-09-01 00:00'#39
      ' and U.BASTAR <='#39'2023-12-30 23:59'#39
      ' and U.DURUM > 0 '
      'Order By U.BASTAR ')
    Left = 46
    Top = 203
  end
  object TabUretimOperasyon: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PUrtEmrID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'declare @UEID int'
      'set @UEID=:PUrtEmrID'
      ''
      'select UO.*,ASD.GBASTAR,ASD.GBITTAR,ASD.GERCEKLESEN ,'
      'STOKADI=S.STOKADI,'
      'S.URUNNO,'
      'LOKASYONADI=L1.ACIKLAMA,'
      'ISMERKEZIADI=L2.ACIKLAMA'
      'from '
      #9'URETIMOPERASYON UO left outer join'
      #9'('#9'select '
      
        #9#9#9'UOID=UO1.ID,GBASTAR=min(FB.TARIH),GBITTAR=max(FB.FATURATARIH)' +
        ',GERCEKLESEN=SUM(F.MIKTAR) '
      #9#9'from '
      #9#9#9'URETIMOPERASYON UO1 inner join '
      #9#9#9'FATURA F on F.YERI=142 and F.YERID=UO1.ID inner join'
      #9#9#9'FATBASLIK FB on F.FATBASID=FB.ID'
      #9#9'where UO1.URETIMEMRIID=@UEID'
      #9#9'group by UO1.ID'
      #9') as ASD on'
      #9'UO.ID=ASD.UOID'
      'left outer join LOKASYON L1 on UO.LOKASYON=L1.ID'
      'left outer join LOKASYON L2 on UO.ISMERKEZI=L2.ID'
      'left outer join STOKLAR S on UO.STOKID=S.ID'
      'where UO.URETIMEMRIID=@UEID'
      '')
    Left = 156
    Top = 221
  end
  object DtsUretimOperasyon: TDataSource
    DataSet = TabUretimOperasyon
    Left = 264
    Top = 228
  end
  object TabUretimAgaci: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PUrtEmrID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'select'
      ' UD.* ,'
      
        '               GRP = case when MIKTAR>0 then '#39#220'r'#252'n'#39' else '#39'Bile'#351'e' +
        'n'#39' end,'
      
        '               AD =  CASE WHEN UD.TUR =1 THEN (SELECT STOKADI FR' +
        'OM STOKLAR WHERE ID = UD.URUNID ) ELSE  (SELECT AD FROM MASRAFGE' +
        'LIR WHERE ID = UD.URUNID)  END,'
      
        '               KOD =  CASE WHEN UD.TUR =1 THEN (SELECT KOD FROM ' +
        'STOKLAR WHERE ID =UD.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR' +
        ' WHERE ID= UD.URUNID )  END,'
      
        #9'URUNNO =  CASE WHEN UD.TUR =1 THEN (SELECT URUNNO FROM STOKLAR ' +
        'WHERE ID = UD.URUNID ) ELSE  '#39#39'  END,'#9
      
        #9'URETILECEK = isnull((select sum(UO.MIKTAR) from URETIMOPERASYON' +
        ' UO where UO.URETIMEMRIID=UD.URETIMEMRIID and UO.URETIMEMRIDETAY' +
        'ID=UD.ID and UO.STOKID=UD.URUNID ),0),'
      
        #9'URETILEN = isnull((select SUM(F.MIKTAR) from FATURA F where MIK' +
        'TAR>0 and YERI=141 and YERID= UD.ID ),0),'
      
        #9'TUKETILEN =- isnull((select SUM(F.MIKTAR) from FATURA F where M' +
        'IKTAR<0 and YERI=141 and YERID= UD.ID ),0),'
      
        #9'DEPODURUMU=case when UD.TUR=1 then isnull((select SUM(KALAN) fr' +
        'om STOKDURUM where STOKID=UD.URUNID),0) else 999999.0 end,'
      
        #9'DEPOGEREKSINIM=case when (UD.MIKTAR-(case when UD.TUR=1 then is' +
        'null((select SUM(KALAN) from STOKDURUM where STOKID=UD.URUNID),0' +
        ') else 999999.0 end))<=0 then 0 else'
      
        #9#9#9#9' (UD.MIKTAR-(case when UD.TUR=1 then isnull((select SUM(KALA' +
        'N) from STOKDURUM where STOKID=UD.URUNID),0) else 999999.0 end))' +
        ' end  '
      ''
      'from URETIMEMRIDETAY UD where '
      '--UD.MIKTAR>0 and '
      'URETIMEMRIID=:PUrtEmrID'
      '')
    Left = 157
    Top = 153
  end
  object DtsUretimAgaci: TDataSource
    DataSet = TabUretimAgaci
    Left = 257
    Top = 152
  end
  object TabUrToplamMaliyet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'PUrtOpID'
        DataType = ftWideString
        Size = 1
        Value = '1'
      end>
    SQL.Strings = (
      'declare @UEID int'
      'set @UEID=:PUrtOpID'
      ''
      
        'select TIP=2,MG.KOD,MG.AD,UOM.TUTAR,UOM.KUR,UOM.ACIKLAMA,BIRIMMA' +
        'LIYET= UOM.TUTAR/UE.ADET'
      'from '
      #9'URETIMOPERASYONMALIYET UOM inner join '
      #9'MASRAFGELIR MG on UOM.MASRAFID=MG.ID inner join '
      #9'URETIMEMRI UE on UOM.URETIMEMRIID=UE.ID'
      'where UOM.URETIMEMRIID=@UEID'
      ''
      'union all'
      ''
      'select '
      
        #9'TIP=1,S.KOD,S.STOKADI,UED.TOPLAMMALIYET,UED.KUR,UED.ACIKLAMA,BI' +
        'RIMMALIYET= UED.TOPLAMMALIYET/UE.ADET'
      'from '
      #9'URETIMEMRIDETAY UED  inner join'
      #9'STOKLAR S on UED.URUNID=S.ID and UED.TUR=1 inner join '
      #9'URETIMEMRI UE on UED.URETIMEMRIID=UE.ID'
      'where UED.TOPLAMMALIYET>0 and UED.URETIMEMRIID=@UEID'
      '')
    Left = 370
    Top = 80
  end
  object DtsUrToplamMaliyet: TDataSource
    DataSet = TabUrToplamMaliyet
    Left = 371
    Top = 157
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = GridUretimEmri
    PopupMenus = <>
    Left = 504
    Top = 152
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 479
    Top = 244
  end
end

