object SatinAlmaWizard: TSatinAlmaWizard
  Left = 0
  Top = 0
  ActiveControl = ComboSube
  BorderIcons = [biSystemMenu]
  Caption = 'Sat'#305'nalma'
  ClientHeight = 592
  ClientWidth = 1022
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 936
    Height = 592
    ActivePage = TalepEkr
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Geri'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&'#304'leri >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Son'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = #304'ptal'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Help'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    OnCancelButtonClick = WizardKontrolCancelButtonClick
    DesignSize = (
      936
      592)
    object TalepEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Sat'#305'nalma Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      EnabledButtons = [bkBack, bkNext, bkFinish, bkCancel]
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      object Panel2: TPanel
        Left = 0
        Top = 70
        Width = 936
        Height = 480
        Align = alClient
        TabOrder = 0
        object Panel3: TPanel
          Left = 1
          Top = 1
          Width = 934
          Height = 96
          Align = alTop
          TabOrder = 0
          object cxDBLabel1: TcxDBLabel
            Left = 294
            Top = 4
            DataBinding.DataField = 'ID'
            DataBinding.DataSource = DtsTabSatinAlma
            ParentFont = False
            Style.Font.Charset = DEFAULT_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
            Height = 17
            Width = 66
          end
          object DateTalepTarihi: TcxDBDateEdit
            Left = 140
            Top = 20
            DataBinding.DataField = 'TALEPTARIHI'
            DataBinding.DataSource = DtsTabSatinAlma
            Properties.ImmediatePost = True
            Properties.SaveTime = False
            TabOrder = 2
            Width = 143
          end
          object ComboDurum: TcxDBImageComboBox
            Left = 621
            Top = 20
            RepositoryItem = Tablo.RepAktifPasif
            DataBinding.DataField = 'DURUM'
            DataBinding.DataSource = DtsTabSatinAlma
            Properties.Items = <>
            TabOrder = 3
            Width = 88
          end
          object cxLabel27: TcxLabel
            Tag = -2114
            Left = 558
            Top = 21
            Cursor = crHandPoint
            Hint = 'Proje_Durum'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.DURUM'
            Caption = 'Durum'
            FocusControl = ComboDurum
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel1: TcxLabel
            Left = 5
            Top = 45
            Cursor = crHandPoint
            Caption = 'Talep Eden'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel2: TcxLabel
            Tag = -2115
            Left = 5
            Top = 71
            Cursor = crHandPoint
            Hint = 'Proje_Sonu'#231
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.SONUC'
            Caption = 'B'#246'l'#252'm'
            FocusControl = ComboBolum
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object ComboBolum: TcxDBImageComboBox
            Left = 90
            Top = 70
            RepositoryItem = Tablo.RepCariBolum
            DataBinding.DataField = 'TALEPEDENBOLUM'
            DataBinding.DataSource = DtsTabSatinAlma
            Properties.Items = <>
            TabOrder = 4
            Width = 193
          end
          object EditTalepNo: TcxDBTextEdit
            Left = 90
            Top = 20
            DataBinding.DataField = 'TALEPNO'
            DataBinding.DataSource = DtsTabSatinAlma
            TabOrder = 5
            Width = 47
          end
          object cxLabel9: TcxLabel
            Left = 5
            Top = 20
            Cursor = crHandPoint
            Caption = 'Talep No/Tarih'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object ComboSube: TcxDBImageComboBox
            Left = 383
            Top = 44
            RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
            DataBinding.DataField = 'SUBEID'
            DataBinding.DataSource = DtsTabSatinAlma
            Properties.ImmediatePost = True
            Properties.Items = <>
            TabOrder = 0
            Width = 108
          end
          object LblSube: TcxLabel
            Left = 342
            Top = 44
            Caption = #350'ube'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object BETalepEden: TcxButtonEdit
            Left = 90
            Top = 45
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end
              item
                Caption = '-'
                Hint = 'Temizle'
                Kind = bkText
              end>
            Properties.OnButtonClick = BETalepEdenPropertiesButtonClick
            TabOrder = 11
            OnKeyDown = BETalepEdenKeyDown
            Width = 193
          end
          object ComboAsama: TcxDBImageComboBox
            Left = 621
            Top = 44
            HelpType = htKeyword
            RepositoryItem = Tablo.RepSatinalmaAsama
            DataBinding.DataField = 'ASAMA'
            DataBinding.DataSource = DtsTabSatinAlma
            Properties.Items = <>
            TabOrder = 12
            Width = 88
          end
          object cxLabel3: TcxLabel
            Tag = -2114
            Left = 558
            Top = 47
            Cursor = crHandPoint
            Hint = 'Proje_Durum'
            HelpType = htKeyword
            HelpKeyword = 'PROJELER.DURUM'
            Caption = 'A'#351'ama'
            FocusControl = ComboAsama
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxDBImageComboBox1: TcxDBImageComboBox
            Left = 383
            Top = 20
            RepositoryItem = Tablo.RepStokDepolarTumu
            DataBinding.DataField = 'DEPO'
            DataBinding.DataSource = DtsTabSatinAlma
            Properties.ImmediatePost = True
            Properties.Items = <>
            TabOrder = 14
            Width = 108
          end
          object cxLabel4: TcxLabel
            Left = 342
            Top = 20
            Caption = 'Depo'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
        end
        object Panel4: TPanel
          Left = 1
          Top = 97
          Width = 934
          Height = 382
          Align = alClient
          TabOrder = 1
          object GridSADetay: TcxGrid
            Left = 1
            Top = 25
            Width = 932
            Height = 356
            Align = alClient
            TabOrder = 0
            object GridSADetayView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsTabSatinAlmaDetay
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsView.GroupByBox = False
              object GridSADetayViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 24
              end
              object GridSADetayViewKOD: TcxGridDBColumn
                Caption = 'Kod'
                DataBinding.FieldName = 'KOD'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 126
              end
              object GridSADetayViewACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'STOKADI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 198
              end
              object GridSADetayViewBIRIM: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.repStokAnaBirim
                Options.Editing = False
                Width = 53
              end
              object GridSADetayViewADET: TcxGridDBColumn
                Caption = 'Adet'
                DataBinding.FieldName = 'ADET'
                DataBinding.IsNullValueType = True
                Width = 107
              end
              object GridSADetayViewONAY: TcxGridDBColumn
                Caption = 'Onay'
                DataBinding.FieldName = 'ONAY'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
              end
              object GridSADetayViewONAYADET: TcxGridDBColumn
                Caption = 'Onaylanan Adet'
                DataBinding.FieldName = 'ONAYADET'
                DataBinding.IsNullValueType = True
                Width = 87
              end
              object GridSADetayViewPROJEID: TcxGridDBColumn
                Caption = 'Proje'
                DataBinding.FieldName = 'PROJEKODU'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Caption = '++'
                    Default = True
                    Kind = bkText
                  end
                  item
                    Caption = '+'
                    Kind = bkText
                  end
                  item
                    Caption = '-'
                    Kind = bkText
                  end>
                Properties.OnButtonClick = GridSADetayViewPROJEIDPropertiesButtonClick
                Width = 147
              end
              object GridSADetayViewTESLIMTARIHI: TcxGridDBColumn
                Caption = 'Teslim Tarihi'
                DataBinding.FieldName = 'TESLIMTARIHI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxDateEditProperties'
                Properties.ImmediatePost = True
                Width = 97
              end
            end
            object cxGridLevel2: TcxGridLevel
              GridView = GridSADetayView
            end
          end
          object ToolBar6: TToolBar
            Left = 1
            Top = 1
            Width = 932
            Height = 24
            Margins.Bottom = 0
            ButtonWidth = 62
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
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            GradientEndColor = 11776947
            GradientStartColor = 14540253
            HotTrackColor = 65408
            Images = Tablo.PNGImageList2
            List = True
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 1
            Transparent = True
            object SatirEkle: TToolButton
              Left = 0
              Top = 0
              Caption = 'Ekle'
              ImageIndex = 0
              ImageName = 'PngImage0'
              Style = tbsTextButton
              Visible = False
              OnClick = SatirEkleClick
            end
            object SatirSil: TToolButton
              Left = 62
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              Style = tbsTextButton
              Visible = False
              OnClick = SatirSilClick
            end
            object SatirKaydet: TToolButton
              Left = 124
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = SatirKaydetClick
            end
          end
        end
      end
    end
    object TeklifEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Al'#305'nan Teklifler'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'TeklifEkr'
      OnEnterPage = TeklifEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PngSpeedButton1: TPngSpeedButton
        Left = 480
        Top = 368
        Width = 23
        Height = 22
      end
      object GridTeklifler: TcxGrid
        Left = 0
        Top = 94
        Width = 936
        Height = 456
        Align = alClient
        TabOrder = 0
        object GridTekliflerView: TcxGridDBTableView
          OnDblClick = btnTeklifDuzenleClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsTabTeklifler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.ShowEditButtons = gsebAlways
          OptionsView.ColumnAutoWidth = True
          OptionsView.GroupByBox = False
          object GridTekliflerViewEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 137
          end
          object GridTekliflerViewFIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 329
          end
          object GridTekliflerViewTEKLIF_MATRAHI: TcxGridDBColumn
            Caption = 'Toplam'
            DataBinding.FieldName = 'TEKLIF_MATRAHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;'
            RepositoryItem = Tablo.RepCurrencyBF
            Options.Editing = False
            Width = 92
          end
          object GridTekliflerViewKDV_TUTARI: TcxGridDBColumn
            Caption = 'KDV'
            DataBinding.FieldName = 'KDV_TUTARI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;'
            RepositoryItem = Tablo.RepCurrencyBF
            Options.Editing = False
            Width = 69
          end
          object GridTekliflerViewDOVIZ_TUTARI: TcxGridDBColumn
            Caption = 'Genel Toplam'
            DataBinding.FieldName = 'DOVIZ_TUTARI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;'
            RepositoryItem = Tablo.RepCurrencyBF
            Options.Editing = False
            Width = 92
          end
          object GridTekliflerViewEPOSTA_GONDER: TcxGridDBColumn
            Caption = 'E-Posta G'#246'nder'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repEpostaGonder
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = GridTekliflerView
        end
      end
      object ToolBar1: TToolBar
        Left = 0
        Top = 70
        Width = 936
        Height = 24
        Margins.Bottom = 0
        ButtonWidth = 66
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
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        GradientEndColor = 11776947
        GradientStartColor = 14540253
        HotTrackColor = 65408
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
        object btnTeklifEkle: TToolButton
          Tag = 2
          Left = 0
          Top = 0
          Caption = 'Ekle'
          ImageIndex = 0
          ImageName = 'PngImage0'
          Style = tbsTextButton
          OnClick = btnTeklifEkleClick
        end
        object btnTeklifSil: TToolButton
          Left = 66
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          Style = tbsTextButton
          OnClick = btnTeklifSilClick
        end
        object ToolButton1: TToolButton
          Left = 132
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsSeparator
        end
        object btnTeklifDuzenle: TToolButton
          Left = 140
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = btnTeklifDuzenleClick
        end
      end
    end
    object DegerlendirmeEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'De'#287'erlendirme'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      Caption = 'DegerlendirmeEkr'
      OnEnterPage = DegerlendirmeEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PGDegerlendirme: TcxDBPivotGrid
        Left = 0
        Top = 70
        Width = 936
        Height = 480
        Align = alClient
        DataSource = DtsTabDegerlendirme
        Groups = <>
        LookAndFeel.NativeStyle = True
        OptionsSelection.MultiSelect = True
        OptionsView.ColumnFields = False
        OptionsView.ColumnGrandTotals = False
        OptionsView.ColumnTotals = False
        OptionsView.DataFields = False
        OptionsView.FilterFields = False
        OptionsView.RowFields = False
        OptionsView.RowGrandTotals = False
        OptionsView.RowGrandTotalWidth = 620
        OptionsView.RowTotals = False
        PopupMenu = PmSagClick
        TabOrder = 0
        object PGSTOKADI: TcxDBPivotGridField
          Area = faRow
          AreaIndex = 0
          IsCaptionAssigned = True
          Caption = 'Stok Ad'#305
          DataBinding.FieldName = 'STOKADI'
          DataVisibility = dvCrossAndTotalCells
          Visible = True
          UniqueName = 'Stok Ad'#305
        end
        object PGFIRMA: TcxDBPivotGridField
          Area = faColumn
          AreaIndex = 0
          IsCaptionAssigned = True
          Caption = 'Firma'
          DataBinding.FieldName = 'FIRMA'
          Visible = True
          UniqueName = 'Firma'
        end
        object PGTDID: TcxDBPivotGridField
          Area = faData
          AreaIndex = 0
          IsCaptionAssigned = True
          Caption = 'ID'
          DataBinding.FieldName = 'TDID'
          MinWidth = 1
          Visible = True
          Width = 1
          UniqueName = 'ID'
        end
        object PGTEKLIFONAY: TcxDBPivotGridField
          Area = faData
          AreaIndex = 1
          IsCaptionAssigned = True
          Caption = 'Onay'
          DataBinding.FieldName = 'TEKLIFONAY'
          Visible = True
          Width = 36
          UniqueName = 'Se'#231
        end
        object PGBIRIMFIYAT: TcxDBPivotGridField
          Area = faData
          AreaIndex = 2
          IsCaptionAssigned = True
          Caption = 'Birim Fiyat'
          DataBinding.FieldName = 'BIRIMFIYAT'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;'
          RepositoryItem = Tablo.RepCurrencyBF
          Visible = True
          UniqueName = 'Birim Fiyat'
        end
        object PGTUTAR: TcxDBPivotGridField
          Area = faData
          AreaIndex = 3
          IsCaptionAssigned = True
          Caption = 'Tutar'
          DataBinding.FieldName = 'TUTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;'
          RepositoryItem = Tablo.RepCurrencyBF
          Visible = True
          UniqueName = 'Tutar'
        end
      end
    end
    object SiparisEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Sipari'#351'ler'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = DEFAULT_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = DEFAULT_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      Caption = 'Sipari'#351'ler'
      OnEnterPage = SiparisEkrEnterPage
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridSiparisler: TcxGrid
        Left = 0
        Top = 94
        Width = 936
        Height = 456
        Align = alClient
        TabOrder = 0
        object GridSiparislerView: TcxGridDBTableView
          OnDblClick = btnSiparisDuzenleClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsTabSiparisler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.GroupByBox = False
          object GridSiparislerViewEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 157
          end
          object GridSiparislerViewFIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Width = 306
          end
        end
        object cxGridLevel3: TcxGridLevel
          GridView = GridSiparislerView
        end
      end
      object ToolBar3: TToolBar
        Left = 0
        Top = 70
        Width = 936
        Height = 24
        Margins.Bottom = 0
        ButtonWidth = 66
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
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        GradientEndColor = 11776947
        GradientStartColor = 14540253
        HotTrackColor = 65408
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 1
        Transparent = True
        object btnSiparisEkle: TToolButton
          Tag = 3
          Left = 0
          Top = 0
          Caption = 'Ekle'
          ImageIndex = 0
          ImageName = 'PngImage0'
          Style = tbsTextButton
          OnClick = btnSiparisEkleClick
        end
        object btnSiparisSil: TToolButton
          Left = 66
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          Style = tbsTextButton
          OnClick = btnSiparisSilClick
        end
        object ToolButton5: TToolButton
          Left = 132
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Style = tbsSeparator
        end
        object btnSiparisDuzenle: TToolButton
          Left = 140
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          OnClick = btnSiparisDuzenleClick
        end
      end
    end
    object DokumanEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Dok'#252'man bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkBack, bkNext, bkFinish, bkCancel]
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 930
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 95
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
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        GradientEndColor = 11776947
        GradientStartColor = 14540253
        HotTrackColor = 65408
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object BelgeEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Belge Ekle'
          ImageIndex = 4
          ImageName = 'PngImage4'
          Style = tbsTextButton
        end
        object BelgeSilTus: TToolButton
          Left = 95
          Top = 0
          Caption = 'Belge Sil'
          ImageIndex = 5
          ImageName = 'PngImage5'
          Style = tbsTextButton
        end
        object BelgeDuzenleTus: TToolButton
          Left = 190
          Top = 0
          Caption = 'Belge D'#252'zenle'
          ImageIndex = 7
          ImageName = 'PngImage7'
          Style = tbsTextButton
        end
        object BelgeGorTus: TToolButton
          Left = 285
          Top = 0
          Caption = 'Belge G'#246'r'
          ImageIndex = 6
          ImageName = 'PngImage6'
        end
        object VerTus: TToolButton
          Left = 380
          Top = 0
          Caption = 'Ver'
          ImageIndex = 19
          ImageName = 'PngImage19'
        end
        object EPostaTus: TToolButton
          Left = 475
          Top = 0
          Caption = 'E-Posta'
          ImageIndex = 18
          ImageName = 'PngImage18'
        end
        object ToolButton2: TToolButton
          Left = 570
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 8
          ImageName = 'PngImage15'
          Style = tbsSeparator
        end
      end
      object GridDokuman: TcxGrid
        Left = 0
        Top = 97
        Width = 936
        Height = 453
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = False
        RootLevelOptions.DetailTabsPosition = dtpTop
        object DokumanTview: TcxGridDBTableView
          DragMode = dmAutomatic
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Kind = skCount
              Position = spFooter
              FieldName = 'AD'
            end
            item
              Kind = skSum
              Position = spFooter
              FieldName = 'BOYUT'
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = 'Say'#305' :  ######'
              Kind = skCount
              FieldName = 'AD'
              DisplayText = 'Kay'#305't Say'#305's'#305
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              FieldName = 'BOYUT'
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsSelection.HideFocusRectOnExit = False
          OptionsView.CellAutoHeight = True
          OptionsView.Footer = True
          OptionsView.FooterAutoHeight = True
          OptionsView.FooterMultiSummaries = True
          OptionsView.Indicator = True
          object DokumanTviewTip: TcxGridDBColumn
            Caption = 'Tip'
            DataBinding.FieldName = 'TIP'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repDokumanTip
          end
          object DokumanTviewEXT: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'EXT'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxHyperLinkEditProperties'
            RepositoryItem = Tablo.repFileExtensionList
            Width = 52
          end
          object DokumanTviewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object DokumanTviewTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
          end
          object DokumanTviewBELGENO: TcxGridDBColumn
            Caption = 'Belge No'
            DataBinding.FieldName = 'BELGENO'
            DataBinding.IsNullValueType = True
          end
          object DokumanTviewDURUM: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepAktifPasif
          end
          object DokumanTviewYON: TcxGridDBColumn
            Caption = 'Y'#246'n'
            DataBinding.FieldName = 'YON'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepDokumanYonu
          end
          object DokumanTviewMODUL: TcxGridDBColumn
            Caption = 'Mod'#252'l'
            DataBinding.FieldName = 'MODUL'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepDokumanModul
          end
          object DokumanTviewKATEGORI: TcxGridDBColumn
            Caption = 'Kategori'
            DataBinding.FieldName = 'KATEGORI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxComboBoxProperties'
          end
          object DokumanTviewAD: TcxGridDBColumn
            Caption = 'D'#246'k'#252'man Ad'#305
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Width = 124
          end
          object DokumanTviewSURUM: TcxGridDBColumn
            Caption = 'S'#252'r'#252'm'
            DataBinding.FieldName = 'SURUM'
            DataBinding.IsNullValueType = True
          end
          object DokumanTviewKONU: TcxGridDBColumn
            Caption = 'Konusu'
            DataBinding.FieldName = 'KONU'
            DataBinding.IsNullValueType = True
            Width = 119
          end
          object DokumanTviewTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            RepositoryItem = Tablo.RepBelge_Turu
          end
          object DokumanTviewBOLUM: TcxGridDBColumn
            Caption = 'B'#246'l'#252'm'
            DataBinding.FieldName = 'BOLUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <>
            Width = 119
          end
          object DokumanTviewKURUM: TcxGridDBColumn
            Caption = 'Kurum'
            DataBinding.FieldName = 'KURUM'
            DataBinding.IsNullValueType = True
            Width = 200
          end
          object DokumanTviewILGILI: TcxGridDBColumn
            Caption = #304'lgili'
            DataBinding.FieldName = 'ILGILI'
            DataBinding.IsNullValueType = True
            Width = 88
          end
          object DokumanTviewSORUMLUAD: TcxGridDBColumn
            Caption = 'Sorumlu'
            DataBinding.FieldName = 'SORUMLUAD'
            DataBinding.IsNullValueType = True
          end
          object DokumanTviewBOYUT: TcxGridDBColumn
            Caption = 'Boyut'
            DataBinding.FieldName = 'BOYUT'
            DataBinding.IsNullValueType = True
          end
          object DokumanTviewLOKASYONAD: TcxGridDBColumn
            Caption = 'Lokasyon'
            DataBinding.FieldName = 'LOKASYONAD'
            DataBinding.IsNullValueType = True
          end
          object DokumanTviewGECERLILIK_TARIHI: TcxGridDBColumn
            Caption = 'Ge'#231'erlilik Tarihi'
            DataBinding.FieldName = 'GECERLILIK_TARIHI'
            DataBinding.IsNullValueType = True
          end
          object DokumanTviewKLASOR: TcxGridDBColumn
            Caption = 'Klas'#246'r'
            DataBinding.FieldName = 'KLASOR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repDokumanKlasor
            Width = 74
          end
        end
        object GridDokumanDBCardView1: TcxGridDBCardView
          DragMode = dmAutomatic
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.MultiSelect = True
          OptionsView.CardAutoWidth = True
          OptionsView.CardIndent = 7
          OptionsView.CardWidth = 69
          OptionsView.CellAutoHeight = True
          OptionsView.RowCaptionAutoHeight = True
          object GridDokumanDBCardView1EXT: TcxGridDBCardViewRow
            DataBinding.FieldName = 'EXT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repFileExtensionList
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.LineCount = 2
          end
          object GridDokumanDBCardView1AD: TcxGridDBCardViewRow
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.LineCount = 3
          end
        end
        object cxGridLevel10: TcxGridLevel
          Caption = 'Liste'
          GridView = DokumanTview
        end
        object GridDokumanLevel1: TcxGridLevel
          Caption = 'Simge'
          GridView = GridDokumanDBCardView1
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 592
    Align = alLeft
    TabOrder = 1
    object btnTalep: TcxButton
      Left = 0
      Top = 93
      Width = 84
      Height = 29
      Caption = 'Talep'
      TabOrder = 0
      OnClick = btnTalepClick
    end
    object btnAlinanTeklifler: TcxButton
      Tag = 1
      Left = 0
      Top = 124
      Width = 84
      Height = 29
      Caption = 'Al'#305'nan Teklifler'
      TabOrder = 1
      OnClick = btnTalepClick
    end
    object btnSiparis: TcxButton
      Tag = 3
      Left = 0
      Top = 192
      Width = 84
      Height = 29
      Caption = 'Sipari'#351
      TabOrder = 3
      OnClick = btnTalepClick
    end
    object btnDegerlendirme: TcxButton
      Tag = 2
      Left = 0
      Top = 158
      Width = 84
      Height = 29
      Caption = 'De'#287'erlendirme'
      TabOrder = 2
      OnClick = btnTalepClick
    end
  end
  object DtsTabSatinAlma: TDataSource
    DataSet = TabSatinAlma
    Left = 24
    Top = 288
  end
  object TabSatinAlma: TFDQuery
    BeforeEdit = TabSatinAlmaBeforeEdit
    BeforePost = TabSatinAlmaBeforePost
    AfterPost = TabSatinAlmaAfterPost
    OnNewRecord = TabSatinAlmaNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select *,R.FIRMA from SATINALMA SA left outer join REHBER R on R' +
        '.ID=SA.TALEPEDEN ')
    Left = 23
    Top = 240
  end
  object DtsTabSatinAlmaDetay: TDataSource
    DataSet = TabSatinAlmaDetay
    OnStateChange = DtsTabSatinAlmaDetayStateChange
    Left = 288
    Top = 16
  end
  object TabSatinAlmaDetay: TFDQuery
    BeforeEdit = TabSatinAlmaDetayBeforeEdit
    BeforePost = TabSatinAlmaDetayBeforePost
    OnNewRecord = TabSatinAlmaDetayNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select *,'
      
        'STOKADI = (select S.STOKADI from STOKLAR S where S.ID=SAD.STOKID' +
        '),'
      'KOD= (select S.KOD from STOKLAR S where S.ID=SAD.STOKID),'
      
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=SAD.PRO' +
        'JEID) '
      'from SATINALMADETAY SAD '
      'Where  SATINALMAID=:Par1')
    Left = 255
  end
  object DtsTabTeklifler: TDataSource
    DataSet = TabTeklifler
    Left = 408
    Top = 16
  end
  object TabTeklifler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select T.ID,T.REHBERID,CARIKOD=R.KOD, R.FIRMA,T.EKLEMETARIHI,T.T' +
        'EKLIF_MATRAHI,T.KDV_TUTARI,T.DOVIZ_TUTARI  from TEKLIFDETAY TD'
      'inner join REHBER R on TD.REHBERID=R.ID'
      'inner join TEKLIF T on TD.TEKLIFID=T.ID'
      'Where TD.YERI=463 and TD.YERID=:Par1'
      
        'Group by T.ID,T.REHBERID,R.FIRMA ,T.EKLEMETARIHI,T.TEKLIF_MATRAH' +
        'I,T.KDV_TUTARI,T.DOVIZ_TUTARI,R.KOD')
    Left = 375
  end
  object DtsTabSiparisler: TDataSource
    DataSet = TabSiparisler
    Left = 520
    Top = 16
  end
  object TabSiparisler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select S.ID,S.REHBERID,R.FIRMA,S.EKLEMETARIHI from SIPARISDETAY ' +
        'SD '
      'inner join REHBER R on SD.REHBERID=R.ID'
      'inner join SIPARIS S on SD.SIPARISID=S.ID'
      'Where SD.YERI=463 and SD.YERID=:Par1 '
      'Group by S.ID,S.REHBERID,R.FIRMA ,S.EKLEMETARIHI ')
    Left = 487
  end
  object DtsTabDegerlendirme: TDataSource
    DataSet = TabDegerlendirme
    Left = 640
    Top = 16
  end
  object TabDegerlendirme: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'Select TDID=TD.ID,T.ID,TD.TEKLIFONAY,TD.URUNID,S.STOKADI,T.REHBE' +
        'RID,R.FIRMA,T.EKLEMETARIHI,TD.BIRIMFIYAT,T.TEKLIF_MATRAHI,T.KDV_' +
        'TUTARI,TD.TUTAR,TD.ONAY  from TEKLIFDETAY TD '
      'join REHBER R on TD.REHBERID=R.ID'
      'join TEKLIF T on TD.TEKLIFID=T.ID'
      'join STOKLAR S on S.ID=TD.URUNID'
      'Where TD.YERI=463 and TD.YERID=:Par1 ')
    Left = 607
  end
  object PmSagClick: TPopupMenu
    OnPopup = PmSagClickPopup
    Left = 384
    Top = 224
    object PmOnayla: TMenuItem
      Caption = 'Onayla'
      OnClick = PmOnaylaClick
    end
    object PmOnaylama: TMenuItem
      Caption = 'Onaylama'
      OnClick = PmOnaylaClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object utarendkolanlaronayla1: TMenuItem
      Caption = 'Tutar'#305' en d'#252#351#252'k olanlar'#305' onayla'
      OnClick = utarendkolanlaronayla1Click
    end
  end
end
