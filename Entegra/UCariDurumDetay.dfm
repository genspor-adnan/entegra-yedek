object CariDurumDetayDlg: TCariDurumDetayDlg
  Left = 0
  Top = 0
  Caption = 'Cari Bilgiler'
  ClientHeight = 577
  ClientWidth = 1004
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel3: TPanel
    Left = 0
    Top = 38
    Width = 1004
    Height = 539
    Align = alClient
    TabOrder = 0
    ExplicitTop = 49
    ExplicitHeight = 528
    object cxPageControl2: TcxPageControl
      Left = 1
      Top = 1
      Width = 1002
      Height = 537
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = SheetCariKart
      Properties.CustomButtons.Buttons = <>
      ExplicitHeight = 526
      ClientRectBottom = 533
      ClientRectLeft = 4
      ClientRectRight = 998
      ClientRectTop = 24
      object SheetCariKart: TcxTabSheet
        Caption = 'Cari Kart Bilgileri'
        ImageIndex = 0
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 498
        object PCCariKart: TcxPageControl
          Left = 0
          Top = 0
          Width = 994
          Height = 509
          Align = alClient
          TabOrder = 0
          Properties.ActivePage = SheetIletisim
          Properties.CustomButtons.Buttons = <>
          ExplicitHeight = 498
          ClientRectBottom = 505
          ClientRectLeft = 4
          ClientRectRight = 990
          ClientRectTop = 24
          object SheetIletisim: TcxTabSheet
            Caption = #304'leti'#351'im Bilgileri'
            ImageIndex = 0
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object GridKurIlet: TcxGrid
              Left = 167
              Top = 0
              Width = 819
              Height = 481
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              ExplicitHeight = 470
              object GridKurIletView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsKurIlet
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsView.GroupByBox = False
                Styles.Content = AnaForm.cxStyle1
                object cxGridDBColumn3: TcxGridDBColumn
                  Caption = 'Etiketi'
                  DataBinding.FieldName = 'ETIKET'
                  MinWidth = 150
                  Options.Editing = False
                  Options.Filtering = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Width = 150
                end
                object cxGridDBColumn4: TcxGridDBColumn
                  Caption = 'Bilgisi'
                  DataBinding.FieldName = 'BILGI'
                  MinWidth = 400
                  Options.Filtering = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Styles.Content = Tablo.cxStyle1
                  Width = 400
                end
                object GridKurIletViewColumn1: TcxGridDBColumn
                  DataBinding.FieldName = 'ORJINAL'
                  Visible = False
                  MinWidth = 64
                  Options.Editing = False
                  Options.Filtering = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Options.ShowCaption = False
                end
                object GridKurIletViewColumnsec: TcxGridDBColumn
                  Caption = 'Zorunlu'
                  DataBinding.FieldName = 'ZORUNLU'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Visible = False
                end
              end
              object cxGridLevel2: TcxGridLevel
                GridView = GridKurIletView
              end
            end
            object cxGrid1: TcxGrid
              Left = 0
              Top = 0
              Width = 167
              Height = 481
              Align = alLeft
              TabOrder = 1
              LookAndFeel.Kind = lfStandard
              LookAndFeel.NativeStyle = True
              ExplicitHeight = 470
              object GridAdresAdView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsRehberIlet
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.DeletingConfirmation = False
                OptionsSelection.CellSelect = False
                OptionsSelection.MultiSelect = True
                OptionsView.GroupByBox = False
                Styles.Selection = Tablo.cxstSecili
                object cxGridDBColumn10: TcxGridDBColumn
                  Caption = 'Ad'#305' '
                  DataBinding.FieldName = 'AD'
                  Options.Editing = False
                  Width = 131
                end
                object cxGridDBColumn11: TcxGridDBColumn
                  DataBinding.FieldName = 'AKTIF'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Images = Tablo.PNGImageList2
                  Properties.Items = <
                    item
                      Description = 'Kurumda'
                      Value = '1'
                    end
                    item
                      Description = 'Ta'#351#305'nd'#305
                      ImageIndex = 12
                      Value = '2'
                    end
                    item
                      Description = 'Ayr'#305'ld'#305
                      ImageIndex = 10
                      Value = '3'
                    end>
                  Properties.ShowDescriptions = False
                  Width = 31
                  IsCaptionAssigned = True
                end
                object cxGridDBColumn12: TcxGridDBColumn
                  Caption = 'Var.'
                  DataBinding.FieldName = 'VARSAYILAN'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ReadOnly = True
                  Visible = False
                  Options.Editing = False
                  Width = 30
                end
              end
              object cxGridLevel7: TcxGridLevel
                GridView = GridAdresAdView
              end
            end
          end
          object SheetTicariBilg: TcxTabSheet
            Caption = 'Ticari Bilgiler'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object GridTicari: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 481
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              ExplicitHeight = 470
              object GridTicariView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsTicari
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsView.GroupByBox = False
                Styles.Content = AnaForm.cxStyle1
                object cxGridDBColumn5: TcxGridDBColumn
                  Caption = 'Etiketi'
                  DataBinding.FieldName = 'ETIKET'
                  MinWidth = 150
                  Options.Editing = False
                  Options.Filtering = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Width = 150
                end
                object cxGridDBColumn6: TcxGridDBColumn
                  Caption = 'Bilgisi'
                  DataBinding.FieldName = 'BILGI'
                  MinWidth = 400
                  Options.Filtering = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Width = 400
                end
                object GridTicariViewColumn1: TcxGridDBColumn
                  DataBinding.FieldName = 'ORJINAL'
                  Visible = False
                end
                object GridTicariViewColumn2: TcxGridDBColumn
                  DataBinding.FieldName = 'ZORUNLU'
                  Visible = False
                end
              end
              object cxGridLevel4: TcxGridLevel
                GridView = GridTicariView
              end
            end
          end
          object SheetIlgililer: TcxTabSheet
            Caption = #304'lgili Ki'#351'iler'
            ImageIndex = 2
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object cxGrid2: TcxGrid
              Left = 0
              Top = 0
              Width = 167
              Height = 481
              Align = alLeft
              TabOrder = 0
              LookAndFeel.Kind = lfStandard
              LookAndFeel.NativeStyle = True
              ExplicitHeight = 470
              object GridPersonellerView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsIlgili
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.DeletingConfirmation = False
                OptionsSelection.CellSelect = False
                OptionsSelection.MultiSelect = True
                OptionsView.GroupByBox = False
                Styles.Selection = Tablo.cxstSecili
                object PersonelAdi: TcxGridDBColumn
                  Caption = 'Ad'#305' Soyad'#305
                  DataBinding.FieldName = 'ADSOYAD'
                  Options.Editing = False
                  Width = 131
                end
                object PersonelNEREDE: TcxGridDBColumn
                  DataBinding.FieldName = 'NEREDE'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Images = Tablo.PNGImageList2
                  Properties.Items = <
                    item
                      Description = 'Kurumda'
                      Value = '1'
                    end
                    item
                      Description = 'Ta'#351#305'nd'#305
                      ImageIndex = 12
                      Value = '2'
                    end
                    item
                      Description = 'Ayr'#305'ld'#305
                      ImageIndex = 10
                      Value = '3'
                    end>
                  Properties.ShowDescriptions = False
                  Width = 31
                  IsCaptionAssigned = True
                end
                object PersonelVARSAYILAN: TcxGridDBColumn
                  Caption = 'Var.'
                  DataBinding.FieldName = 'VARSAYILAN'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ReadOnly = True
                  Visible = False
                  Options.Editing = False
                  Width = 30
                end
              end
              object GridPersoneller: TcxGridLevel
                GridView = GridPersonellerView
              end
            end
            object GridIlet: TcxGrid
              Left = 167
              Top = 0
              Width = 819
              Height = 481
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 1
              LookAndFeel.Kind = lfStandard
              LookAndFeel.NativeStyle = True
              ExplicitHeight = 470
              object GridIletView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsPerIlet
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsView.GroupByBox = False
                Styles.Content = AnaForm.cxStyle1
                object GridIletViewColumn1: TcxGridDBColumn
                  Caption = 'Etiketi'
                  DataBinding.FieldName = 'ETIKET'
                  MinWidth = 150
                  Options.Editing = False
                  Options.Filtering = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Width = 150
                end
                object GridIletViewColumn3: TcxGridDBColumn
                  DataBinding.FieldName = 'ORJINAL'
                  Visible = False
                end
                object GridIletViewColumn4: TcxGridDBColumn
                  DataBinding.FieldName = 'ZORUNLU'
                  Visible = False
                end
                object GridIletViewColumnBilgi: TcxGridDBColumn
                  Caption = 'Bilgisi'
                  DataBinding.FieldName = 'BILGI'
                  MinWidth = 311
                  Options.Filtering = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Width = 311
                end
              end
              object cxGridLevel3: TcxGridLevel
                GridView = GridIletView
              end
            end
          end
        end
      end
      object SheetTicariBilgiler: TcxTabSheet
        Caption = 'Ticari Hareketler'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 498
        object PCTicari: TcxPageControl
          Left = 0
          Top = 0
          Width = 994
          Height = 509
          Align = alClient
          TabOrder = 0
          Properties.ActivePage = SheetTeklif
          Properties.CustomButtons.Buttons = <>
          ExplicitHeight = 498
          ClientRectBottom = 505
          ClientRectLeft = 4
          ClientRectRight = 990
          ClientRectTop = 24
          object SheetTeklif: TcxTabSheet
            Caption = 'Teklifler'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object cxGrid3: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 225
              Align = alTop
              BevelInner = bvNone
              BevelOuter = bvNone
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object cxGridDBTableView1: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsTeklifler
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsView.GroupByBox = False
                Styles.Content = AnaForm.cxStyle1
                object cxGridDBTableView1TARIH: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'TARIH'
                  Width = 70
                end
                object cxGridDBTableView1TEKLIFNO: TcxGridDBColumn
                  Caption = 'No'
                  DataBinding.FieldName = 'TEKLIFNO'
                  Width = 60
                end
                object cxGridDBTableView1KONUSU: TcxGridDBColumn
                  Caption = 'Konu'
                  DataBinding.FieldName = 'KONUSU'
                  Width = 61
                end
                object cxGridDBTableView1DURUM: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'DURUM'
                  RepositoryItem = Tablo.repTeklifDurumu
                  Width = 55
                end
                object cxGridDBTableView1ODEME: TcxGridDBColumn
                  Caption = #214'deme'
                  DataBinding.FieldName = 'ODEME'
                  RepositoryItem = Tablo.repTeklifOdeme
                  Width = 47
                end
                object cxGridDBTableView1TESLIM_SEKLI: TcxGridDBColumn
                  Caption = 'Teslimat'
                  DataBinding.FieldName = 'TESLIM_SEKLI'
                  RepositoryItem = Tablo.repTeklifTeslimSekli
                  Width = 54
                end
                object cxGridDBTableView1TEKLIF_TUTARI: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'TEKLIF_TUTARI'
                  Width = 64
                end
                object cxGridDBTableView1KUR: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                end
                object cxGridDBTableView1HAZIRLAYAN: TcxGridDBColumn
                  DataBinding.FieldName = 'Haz'#305'rlayan'
                  RepositoryItem = Tablo.repGenelPersonelListesi
                end
                object cxGridDBTableView1ONAYLAYAN: TcxGridDBColumn
                  Caption = 'Onaylayan'
                  DataBinding.FieldName = 'ONAYLAYAN'
                  RepositoryItem = Tablo.repGenelPersonelListesi
                end
                object cxGridDBTableView1SUBEID: TcxGridDBColumn
                  Caption = #350'ube'
                  DataBinding.FieldName = 'SUBEID'
                  RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
                end
                object cxGridDBTableView1ACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 311
                end
              end
              object cxGridLevel1: TcxGridLevel
                GridView = cxGridDBTableView1
              end
            end
            object cxGrid4: TcxGrid
              Left = 0
              Top = 225
              Width = 986
              Height = 256
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              LookAndFeel.SkinName = 'LondonLiquidSky'
              ExplicitHeight = 245
              object GridDetayView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsTeklifDetay
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.AlwaysShowEditor = True
                OptionsBehavior.FocusCellOnTab = True
                OptionsSelection.CellSelect = False
                OptionsSelection.HideSelection = True
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                Styles.Header = AnaForm.cxStyle1
                Styles.Indicator = AnaForm.cxStyle1
                object GridTeklifViewKOD1: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  PropertiesClassName = 'TcxButtonEditProperties'
                  Properties.Alignment.Horz = taLeftJustify
                  Properties.Buttons = <
                    item
                      Default = True
                      Kind = bkEllipsis
                    end>
                  Properties.ReadOnly = False
                  Width = 62
                end
                object GridDetayViewAD: TcxGridDBColumn
                  Caption = 'Ad'
                  DataBinding.FieldName = 'AD'
                  Width = 202
                end
                object GridTeklifViewADET1: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  RepositoryItem = Tablo.RepCurrencyAdetGenel
                  Width = 35
                end
                object GridTeklifViewBIRIM1: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  RepositoryItem = Tablo.repStokAnaBirim
                  Width = 42
                end
                object GridTeklifViewBIRIMFIYAT1: TcxGridDBColumn
                  Caption = 'Birim Fiyat'
                  DataBinding.FieldName = 'BIRIMFIYAT'
                  RepositoryItem = Tablo.RepCurrencyBF
                  Width = 84
                end
                object GridTeklifViewISKONTO1: TcxGridDBColumn
                  Caption = #304'sk1'
                  DataBinding.FieldName = 'ISKONTO'
                  RepositoryItem = Tablo.RepCurrencyAdetGenel
                  Width = 41
                end
                object GridTeklifViewISKONTO2: TcxGridDBColumn
                  Caption = #304'sk2'
                  DataBinding.FieldName = 'ISKONTO2'
                  RepositoryItem = Tablo.RepCurrencyAdetGenel
                  Width = 41
                end
                object GridTeklifViewTUTAR1: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'TUTAR'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  HeaderAlignmentHorz = taCenter
                  Width = 97
                end
                object GridDetayViewKUR: TcxGridDBColumn
                  Caption = 'P.Birimi'
                  DataBinding.FieldName = 'KUR'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 58
                end
                object GridTeklifViewACIKLAMA1: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 296
                end
              end
              object GridDetay: TcxGridLevel
                GridView = GridDetayView
              end
            end
          end
          object SheetSiparis: TcxTabSheet
            Caption = 'Sipari'#351'ler'
            ImageIndex = 2
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object cxGrid5: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 225
              Align = alTop
              BevelInner = bvNone
              BevelOuter = bvNone
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object cxGridDBTableView3: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsSiparisler
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsView.GroupByBox = False
                Styles.Content = AnaForm.cxStyle1
                object cxGridDBTableView3SIPARISTARIH: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'SIPARISTARIH'
                  Width = 75
                end
                object cxGridDBTableView3SIPARISNO: TcxGridDBColumn
                  Caption = 'No'
                  DataBinding.FieldName = 'SIPARISNO'
                  Width = 69
                end
                object cxGridDBTableView3DURUM: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'DURUM'
                  RepositoryItem = Tablo.repSiparisDurum
                end
                object cxGridDBTableView3ISEMRIDURUM: TcxGridDBColumn
                  Caption = #304#351' Emri'
                  DataBinding.FieldName = 'ISEMRIDURUM'
                  RepositoryItem = Tablo.RepIsEmriDurum
                end
                object cxGridDBTableView3ODEME: TcxGridDBColumn
                  Caption = #214'deme'
                  DataBinding.FieldName = 'ODEME'
                  RepositoryItem = Tablo.repTeklifOdeme
                  Width = 48
                end
                object cxGridDBTableView3TESLIM_SEKLI: TcxGridDBColumn
                  Caption = 'Teslimat'
                  DataBinding.FieldName = 'TESLIM_SEKLI'
                  RepositoryItem = Tablo.repTeklifTeslimSekli
                  Width = 54
                end
                object cxGridDBTableView3SIPARIS_TUTARI: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'SIPARIS_TUTARI'
                  Width = 73
                end
                object cxGridDBTableView3KUR: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                end
                object cxGridDBTableView3SATICIKODU: TcxGridDBColumn
                  Caption = 'Sat'#305'c'#305
                  DataBinding.FieldName = 'SATICIKODU'
                  RepositoryItem = Tablo.repGenelPersonelListesi
                end
                object cxGridDBTableView3ONAYLAYAN: TcxGridDBColumn
                  Caption = 'Onaylayan'
                  DataBinding.FieldName = 'ONAYLAYAN'
                  RepositoryItem = Tablo.repGenelPersonelListesi
                end
                object cxGridDBTableView3SUBEID: TcxGridDBColumn
                  Caption = #350'ube'
                  DataBinding.FieldName = 'SUBEID'
                  RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
                end
                object cxGridDBTableView3ACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 279
                end
              end
              object cxGridLevel6: TcxGridLevel
                GridView = cxGridDBTableView3
              end
            end
            object GridFat: TcxGrid
              Left = 0
              Top = 225
              Width = 986
              Height = 256
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              LookAndFeel.SkinName = 'LondonLiquidSky'
              ExplicitHeight = 245
              object GridFatDBTableView1: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsSiparisDetay
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.AlwaysShowEditor = True
                OptionsBehavior.FocusCellOnTab = True
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsSelection.HideSelection = True
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                Styles.Header = AnaForm.cxStyle1
                Styles.Indicator = AnaForm.cxStyle1
                object GridFatDBTableView1KOD: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  Width = 61
                end
                object GridFatDBTableView1AD: TcxGridDBColumn
                  Caption = 'Ad'
                  DataBinding.FieldName = 'AD'
                  Width = 141
                end
                object GridFatDBTableView1ADET: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  Width = 37
                end
                object GridFatDBTableView1BIRIM: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  Width = 44
                end
                object GridFatDBTableView1BIRIMFIYAT: TcxGridDBColumn
                  Caption = 'Birim Fiyat'
                  DataBinding.FieldName = 'BIRIMFIYAT'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;-,0.00'
                  Width = 92
                end
                object GridFatDBTableView1TUTAR: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'TUTAR'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;-,0.00'
                  Width = 79
                end
                object GridFatDBTableView1ISKONTO: TcxGridDBColumn
                  Caption = #304'sk1'
                  DataBinding.FieldName = 'ISKONTO'
                  Width = 28
                end
                object GridFatDBTableView1ISKONTO2: TcxGridDBColumn
                  Caption = #304'sk2'
                  DataBinding.FieldName = 'ISKONTO2'
                  Width = 28
                end
                object GridFatDBTableView1KUR: TcxGridDBColumn
                  DataBinding.FieldName = 'KUR'
                end
                object GridFatDBTableView1ACIKLAMA: TcxGridDBColumn
                  Caption = 'Notlar'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 102
                end
              end
              object GridFatLevel1: TcxGridLevel
                GridView = GridFatDBTableView1
              end
            end
          end
          object cxTabSheet1: TcxTabSheet
            Caption = 'Fatura/'#304'rsaliyeler'
            ImageIndex = 3
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object cxGrid7: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 225
              Align = alTop
              BevelInner = bvNone
              BevelOuter = bvNone
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              object cxGridDBTableView2: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsFatura
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsView.GroupByBox = False
                Styles.Content = AnaForm.cxStyle1
                object cxGridDBColumn1: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'FATURATARIH'
                  Width = 75
                end
                object cxGridDBColumn2: TcxGridDBColumn
                  Caption = 'No'
                  DataBinding.FieldName = 'FATURANO'
                  Width = 69
                end
                object cxGridDBColumn7: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'DURUM'
                  RepositoryItem = Tablo.repSiparisDurum
                end
                object cxGridDBColumn13: TcxGridDBColumn
                  Caption = 'Teslimat'
                  DataBinding.FieldName = 'TESLIM_SEKLI'
                  RepositoryItem = Tablo.repTeklifTeslimSekli
                  Width = 54
                end
                object cxGridDBColumn14: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'FATURA_TUTARI'
                  Width = 73
                end
                object cxGridDBColumn15: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                end
                object cxGridDBColumn16: TcxGridDBColumn
                  Caption = 'Sat'#305'c'#305
                  DataBinding.FieldName = 'SATICIKODU'
                  RepositoryItem = Tablo.repGenelPersonelListesi
                end
                object cxGridDBColumn18: TcxGridDBColumn
                  Caption = #350'ube'
                  DataBinding.FieldName = 'SUBEID'
                  RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
                end
                object cxGridDBColumn19: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 279
                end
              end
              object cxGridLevel5: TcxGridLevel
                GridView = cxGridDBTableView2
              end
            end
            object cxGrid8: TcxGrid
              Left = 0
              Top = 225
              Width = 986
              Height = 256
              Align = alClient
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              LookAndFeel.SkinName = 'LondonLiquidSky'
              ExplicitHeight = 245
              object cxGridDBTableView4: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataSource = DtsFatDetay
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.AlwaysShowEditor = True
                OptionsBehavior.FocusCellOnTab = True
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsSelection.HideSelection = True
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                Styles.Header = AnaForm.cxStyle1
                Styles.Indicator = AnaForm.cxStyle1
                object cxGridDBColumn20: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  Width = 61
                end
                object cxGridDBColumn21: TcxGridDBColumn
                  Caption = 'Ad'
                  DataBinding.FieldName = 'AD'
                  Width = 141
                end
                object cxGridDBColumn22: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  Width = 37
                end
                object cxGridDBColumn23: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  Width = 44
                end
                object cxGridDBColumn24: TcxGridDBColumn
                  Caption = 'Birim Fiyat'
                  DataBinding.FieldName = 'BIRIMFIYAT'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;-,0.00'
                  Width = 92
                end
                object cxGridDBColumn25: TcxGridDBColumn
                  Caption = 'Tutar'
                  DataBinding.FieldName = 'TUTAR'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;-,0.00'
                  Width = 79
                end
                object cxGridDBColumn26: TcxGridDBColumn
                  Caption = #304'sk1'
                  DataBinding.FieldName = 'ISKONTO'
                  Width = 28
                end
                object cxGridDBColumn27: TcxGridDBColumn
                  Caption = #304'sk2'
                  DataBinding.FieldName = 'ISKONTO2'
                  Width = 28
                end
                object cxGridDBColumn28: TcxGridDBColumn
                  DataBinding.FieldName = 'KUR'
                end
                object cxGridDBColumn29: TcxGridDBColumn
                  Caption = 'Notlar'
                  DataBinding.FieldName = 'ACIKLAMA'
                  Width = 102
                end
              end
              object cxGridLevel9: TcxGridLevel
                GridView = cxGridDBTableView4
              end
            end
          end
          object SheetEkstre: TcxTabSheet
            Caption = 'Ekstre'
            ImageIndex = 3
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object cxGrid6: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 481
              Align = alClient
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              ExplicitHeight = 470
              object cxGridHareketler: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsEkstre
                DataController.Options = [dcoGroupsAlwaysExpanded]
                DataController.Summary.DefaultGroupSummaryItems = <
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    Position = spFooter
                    Column = cxGridHareketlerBORC
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    Position = spFooter
                    Column = cxGridHareketlerALACAK
                  end>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    FieldName = 'BORC'
                    Column = cxGridHareketlerBORC
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    FieldName = 'ALACAK'
                    Column = cxGridHareketlerALACAK
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Column = cxGridHareketlerBORCBAKIYE
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Column = cxGridHareketlerALACAKBAKIYE
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.FocusCellOnCycle = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsSelection.MultiSelect = True
                OptionsView.GroupByBox = False
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.Indicator = True
                object cxGridHareketlerTARIH: TcxGridDBColumn
                  Caption = 'Kay'#305't Tarihi'
                  DataBinding.FieldName = 'TARIH'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.InputKind = ikRegExpr
                  Properties.Kind = ckDateTime
                  Width = 68
                end
                object cxGridHareketlerVADE: TcxGridDBColumn
                  Caption = 'Vade Tarihi'
                  DataBinding.FieldName = 'VADETARIHI'
                  Width = 67
                end
                object cxGridHareketlerTUR: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  RepositoryItem = Tablo.RepKasaTurleri
                  Width = 86
                end
                object cxGridHareketlerNO: TcxGridDBColumn
                  Caption = 'No'
                  DataBinding.FieldName = 'NO'
                  Width = 75
                end
                object cxGridHareketlerKOD: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  Visible = False
                  Width = 77
                end
                object cxGridHareketlerAD: TcxGridDBColumn
                  Caption = #220'nvan'
                  DataBinding.FieldName = 'AD'
                  Visible = False
                  Width = 90
                end
                object cxGridHareketlerBORC: TcxGridDBColumn
                  Caption = 'Bor'#231
                  DataBinding.FieldName = 'BORC'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;(,0.00)'
                  Width = 56
                end
                object cxGridHareketlerALACAK: TcxGridDBColumn
                  Caption = 'Alacak'
                  DataBinding.FieldName = 'ALACAK'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;(,0.00)'
                  Width = 67
                end
                object cxGridHareketlerBORCBAKIYE: TcxGridDBColumn
                  Caption = 'B.Bakiye'
                  DataBinding.FieldName = 'BORCBAKIYE'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;(,0.00)'
                  Width = 54
                end
                object cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn
                  Caption = 'A.Bakiye'
                  DataBinding.FieldName = 'ALACAKBAKIYE'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;(,0.00)'
                  Width = 56
                end
                object cxGridHareketlerKUR: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                  GroupIndex = 0
                  Width = 35
                end
                object cxGridHareketlerColumn1: TcxGridDBColumn
                  Caption = #350'ube'
                  DataBinding.FieldName = 'SUBEID'
                  RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
                end
                object cxGridHareketlerACIKLAMA: TcxGridDBColumn
                  Caption = 'Notlar'
                  DataBinding.FieldName = 'ACIKLAMA'
                  BestFitMaxWidth = 80
                  Width = 252
                end
              end
              object cxGrid1DBTableView1: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DetailKeyFieldNames = 'CEKID'
                DataController.MasterKeyFieldNames = 'CEKID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsView.GroupByBox = False
                Styles.ContentOdd = AnaForm.cxStyle1
                Styles.GroupByBox = AnaForm.cxStyle1
                Styles.Header = AnaForm.cxStyle1
                object cxGrid1DBTableView1DURUM: TcxGridDBColumn
                  DataBinding.FieldName = 'DURUM'
                  FooterAlignmentHorz = taRightJustify
                  GroupSummaryAlignment = taRightJustify
                  Width = 74
                end
                object cxGrid1DBTableView1VADE: TcxGridDBColumn
                  DataBinding.FieldName = 'VADE'
                  Width = 130
                end
                object cxGrid1DBTableView1SERINO: TcxGridDBColumn
                  DataBinding.FieldName = 'SERINO'
                  FooterAlignmentHorz = taRightJustify
                  GroupSummaryAlignment = taRightJustify
                  Width = 109
                end
                object cxGrid1DBTableView1HESAPADI: TcxGridDBColumn
                  DataBinding.FieldName = 'HESAPADI'
                  Width = 354
                end
                object cxGrid1DBTableView1Column1: TcxGridDBColumn
                  DataBinding.FieldName = 'CEKID'
                end
              end
              object cxGrid1Level1: TcxGridLevel
                GridView = cxGridHareketler
              end
            end
          end
          object cxTabSheet2: TcxTabSheet
            Caption = 'Ekstre(Detayl'#305')'
            ImageIndex = 4
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object cxGrid9: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 481
              Align = alClient
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              ExplicitHeight = 470
              object cxGridDBTableView5: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsEktreDetay
                DataController.Options = [dcoGroupsAlwaysExpanded]
                DataController.Summary.DefaultGroupSummaryItems = <
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    Position = spFooter
                    Column = cxGridDBColumn33
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    Position = spFooter
                    Column = cxGridDBColumn34
                  end>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    FieldName = 'BORC'
                    Column = cxGridDBColumn33
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    FieldName = 'ALACAK'
                    Column = cxGridDBColumn34
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Column = cxGridDBColumn35
                  end
                  item
                    Format = ',0.00;(,0.00)'
                    Column = cxGridDBColumn36
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsBehavior.FocusCellOnCycle = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsSelection.MultiSelect = True
                OptionsView.GroupByBox = False
                OptionsView.GroupFooters = gfAlwaysVisible
                OptionsView.Indicator = True
                object cxGridDBColumn8: TcxGridDBColumn
                  Caption = 'Kay'#305't Tarihi'
                  DataBinding.FieldName = 'TARIH'
                  PropertiesClassName = 'TcxDateEditProperties'
                  Properties.InputKind = ikRegExpr
                  Properties.Kind = ckDateTime
                  Width = 68
                end
                object cxGridDBColumn9: TcxGridDBColumn
                  Caption = 'Vade Tarihi'
                  DataBinding.FieldName = 'VADETARIHI'
                  Width = 67
                end
                object cxGridDBColumn17: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  RepositoryItem = Tablo.RepKasaTurleri
                  Width = 86
                end
                object cxGridDBColumn30: TcxGridDBColumn
                  Caption = 'No'
                  DataBinding.FieldName = 'NO'
                  Width = 48
                end
                object cxGridDBColumn31: TcxGridDBColumn
                  Caption = 'Kod'
                  DataBinding.FieldName = 'KOD'
                  Visible = False
                  Width = 77
                end
                object cxGridDBColumn32: TcxGridDBColumn
                  Caption = #220'nvan'
                  DataBinding.FieldName = 'AD'
                  Visible = False
                  Width = 90
                end
                object cxGridDBTableView5HESAPKODU: TcxGridDBColumn
                  Caption = 'HesapHodu'
                  DataBinding.FieldName = 'HESAPKODU'
                  Width = 69
                end
                object cxGridDBTableView5HESAPADI: TcxGridDBColumn
                  Caption = 'Hesap Ad'#305
                  DataBinding.FieldName = 'HESAPADI'
                  Width = 150
                end
                object cxGridDBTableView5ADET: TcxGridDBColumn
                  Caption = 'Adet'
                  DataBinding.FieldName = 'ADET'
                  RepositoryItem = Tablo.RepCurrencyAdetGenel
                  Width = 41
                end
                object cxGridDBTableView5BIRIM: TcxGridDBColumn
                  Caption = 'Birim'
                  DataBinding.FieldName = 'BIRIM'
                  Width = 41
                end
                object cxGridDBTableView5BIRIMFIYAT: TcxGridDBColumn
                  Caption = 'Birimfiyat'
                  DataBinding.FieldName = 'BIRIMFIYAT'
                  RepositoryItem = Tablo.RepCurrencyBF
                  Width = 65
                end
                object cxGridDBColumn33: TcxGridDBColumn
                  Caption = 'Bor'#231
                  DataBinding.FieldName = 'BORC'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Width = 56
                end
                object cxGridDBColumn34: TcxGridDBColumn
                  Caption = 'Alacak'
                  DataBinding.FieldName = 'ALACAK'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Width = 67
                end
                object cxGridDBColumn35: TcxGridDBColumn
                  Caption = 'B.Bakiye'
                  DataBinding.FieldName = 'BORCBAKIYE'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Width = 54
                end
                object cxGridDBColumn36: TcxGridDBColumn
                  Caption = 'A.Bakiye'
                  DataBinding.FieldName = 'ALACAKBAKIYE'
                  RepositoryItem = Tablo.RepCurrencyGenel
                  Width = 56
                end
                object cxGridDBColumn37: TcxGridDBColumn
                  Caption = 'Kur'
                  DataBinding.FieldName = 'KUR'
                  GroupIndex = 0
                  Width = 35
                end
                object cxGridDBColumn38: TcxGridDBColumn
                  Caption = #350'ube'
                  DataBinding.FieldName = 'SUBEID'
                  RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
                end
                object cxGridDBColumn39: TcxGridDBColumn
                  Caption = 'Notlar'
                  DataBinding.FieldName = 'ACIKLAMA'
                  BestFitMaxWidth = 80
                  Width = 252
                end
              end
              object cxGridDBTableView6: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DetailKeyFieldNames = 'CEKID'
                DataController.MasterKeyFieldNames = 'CEKID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsView.GroupByBox = False
                Styles.ContentOdd = AnaForm.cxStyle1
                Styles.GroupByBox = AnaForm.cxStyle1
                Styles.Header = AnaForm.cxStyle1
                object cxGridDBColumn40: TcxGridDBColumn
                  DataBinding.FieldName = 'DURUM'
                  FooterAlignmentHorz = taRightJustify
                  GroupSummaryAlignment = taRightJustify
                  Width = 74
                end
                object cxGridDBColumn41: TcxGridDBColumn
                  DataBinding.FieldName = 'VADE'
                  Width = 130
                end
                object cxGridDBColumn42: TcxGridDBColumn
                  DataBinding.FieldName = 'SERINO'
                  FooterAlignmentHorz = taRightJustify
                  GroupSummaryAlignment = taRightJustify
                  Width = 109
                end
                object cxGridDBColumn43: TcxGridDBColumn
                  DataBinding.FieldName = 'HESAPADI'
                  Width = 354
                end
                object cxGridDBColumn44: TcxGridDBColumn
                  DataBinding.FieldName = 'CEKID'
                end
              end
              object cxGridLevel11: TcxGridLevel
                GridView = cxGridDBTableView5
              end
            end
          end
        end
      end
      object SheetDokuman: TcxTabSheet
        Caption = 'D'#246'k'#252'manlar'
        ImageIndex = 3
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 498
        object GridDokuman: TcxGrid
          Left = 0
          Top = 0
          Width = 994
          Height = 509
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = False
          RootLevelOptions.DetailTabsPosition = dtpTop
          ExplicitHeight = 498
          object DokumanTview: TcxGridDBTableView
            DragMode = dmAutomatic
            Navigator.Buttons.CustomButtons = <>
            DataController.DataSource = DtsDokuman
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
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.HideFocusRectOnExit = False
            OptionsSelection.MultiSelect = True
            OptionsView.CellAutoHeight = True
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.FooterMultiSummaries = True
            OptionsView.Indicator = True
            object DokumanTviewTip: TcxGridDBColumn
              Caption = 'Tip'
              DataBinding.FieldName = 'TIP'
              RepositoryItem = Tablo.repDokumanTip
            end
            object DokumanTviewEXT: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'EXT'
              PropertiesClassName = 'TcxHyperLinkEditProperties'
              RepositoryItem = Tablo.repFileExtensionList
              Width = 52
            end
            object DokumanTviewID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              Visible = False
            end
            object DokumanTviewTARIH: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
            end
            object DokumanTviewBELGENO: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'BELGENO'
            end
            object DokumanTviewDURUM: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepAktifPasif
              Width = 61
            end
            object DokumanTviewYON: TcxGridDBColumn
              Caption = 'Y'#246'n'
              DataBinding.FieldName = 'YON'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepDokumanYonu
            end
            object DokumanTviewKATEGORI: TcxGridDBColumn
              Caption = 'Kategori'
              DataBinding.FieldName = 'KATEGORI'
              PropertiesClassName = 'TcxComboBoxProperties'
              RepositoryItem = Tablo.RepDokumanKategori
            end
            object DokumanTviewAD: TcxGridDBColumn
              Caption = 'D'#246'k'#252'man Ad'#305
              DataBinding.FieldName = 'AD'
              Width = 124
            end
            object DokumanTviewSURUM: TcxGridDBColumn
              Caption = 'S'#252'r'#252'm'
              DataBinding.FieldName = 'SURUM'
            end
            object DokumanTviewKONU: TcxGridDBColumn
              Caption = 'Konusu'
              DataBinding.FieldName = 'KONU'
              Width = 119
            end
            object DokumanTviewTUR: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TUR'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepBelge_Turu
            end
            object DokumanTviewBOLUM: TcxGridDBColumn
              Caption = 'B'#246'l'#252'm'
              DataBinding.FieldName = 'BOLUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepDokumanBolumu
              Width = 119
            end
            object DokumanTviewKURUM: TcxGridDBColumn
              Caption = 'Kurum'
              DataBinding.FieldName = 'KURUM'
              Width = 200
            end
            object DokumanTviewILGILI: TcxGridDBColumn
              Caption = #304'lgili'
              DataBinding.FieldName = 'ILGILI'
              Width = 88
            end
            object DokumanTviewSORUMLUAD: TcxGridDBColumn
              Caption = 'Sorumlu'
              DataBinding.FieldName = 'SORUMLUAD'
            end
            object DokumanTviewBOYUT: TcxGridDBColumn
              Caption = 'Boyut'
              DataBinding.FieldName = 'BOYUT'
            end
            object DokumanTviewLOKASYONAD: TcxGridDBColumn
              Caption = 'Lokasyon'
              DataBinding.FieldName = 'LOKASYONAD'
            end
            object DokumanTviewGECERLILIK_TARIHI: TcxGridDBColumn
              Caption = 'Ge'#231'erlilik Tarihi'
              DataBinding.FieldName = 'GECERLILIK_TARIHI'
            end
            object DokumanTviewKLASOR: TcxGridDBColumn
              Caption = 'Klas'#246'r'
              DataBinding.FieldName = 'KLASOR'
              RepositoryItem = Tablo.repDokumanKlasor
            end
          end
          object GridDokumanDBCardView1: TcxGridDBCardView
            DragMode = dmAutomatic
            Navigator.Buttons.CustomButtons = <>
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
              RepositoryItem = Tablo.repFileExtensionList
              Options.Editing = False
              Options.ShowCaption = False
              Position.BeginsLayer = True
              Position.LineCount = 2
            end
            object GridDokumanDBCardView1AD: TcxGridDBCardViewRow
              DataBinding.FieldName = 'AD'
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
      object SheetCRM: TcxTabSheet
        Caption = 'CRM Bilgileri'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 498
        object PCCRM: TcxPageControl
          Left = 0
          Top = 0
          Width = 994
          Height = 509
          Align = alClient
          TabOrder = 0
          Properties.ActivePage = SheetProjeler
          Properties.CustomButtons.Buttons = <>
          ExplicitHeight = 498
          ClientRectBottom = 505
          ClientRectLeft = 4
          ClientRectRight = 990
          ClientRectTop = 24
          object SheetProjeler: TcxTabSheet
            Caption = 'Projeler'
            ImageIndex = 0
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object GridCariProjeler: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 481
              Align = alClient
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              ExplicitHeight = 470
              object GridCariProjelerView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DetailKeyFieldNames = 'ID'
                DataController.KeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsView.ExpandButtonsForEmptyDetails = False
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridCariProjelerViewBASTARIHI: TcxGridDBColumn
                  Caption = 'Ba'#351'lama'
                  DataBinding.FieldName = 'BASLAMATARIHI'
                  Width = 89
                end
                object GridCariProjelerViewBITTARIHI: TcxGridDBColumn
                  Caption = 'Biti'#351' Tarihi'
                  DataBinding.FieldName = 'BITISTARIHI'
                end
                object GridCariProjelerViewPROJEKODU: TcxGridDBColumn
                  Caption = 'Proje Kodu'
                  DataBinding.FieldName = 'PROJEKODU'
                  Width = 126
                end
                object GridCariProjelerViewKONUSU: TcxGridDBColumn
                  Caption = 'Konusu'
                  DataBinding.FieldName = 'KONUSU'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 86
                end
                object GridCariProjelerViewTURU: TcxGridDBColumn
                  Caption = 'T'#252'r'#252
                  DataBinding.FieldName = 'PROJETURU'
                  Width = 79
                end
                object GridCariProjelerViewDURUM: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'PROJEDURUM'
                end
                object GridCariProjelerViewASAMA: TcxGridDBColumn
                  Caption = 'A'#351'ama'
                  DataBinding.FieldName = 'PROJEASAMA'
                end
                object GridCariProjelerViewLISTEFIYATI: TcxGridDBColumn
                  Caption = 'Liste Fiyat'#305
                  DataBinding.FieldName = 'LISTEFIYATI'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;(,0.00)'
                end
                object GridCariProjelerViewLISTEKUR: TcxGridDBColumn
                  Caption = 'Liste P.Birimi'
                  DataBinding.FieldName = 'LISTEKUR'
                  PropertiesClassName = 'TcxComboBoxProperties'
                end
                object GridCariProjelerViewSATISFIYATI: TcxGridDBColumn
                  Caption = 'Sat'#305#351' Fiyat'#305
                  DataBinding.FieldName = 'SATISFIYATI'
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;(,0.00)'
                  Width = 77
                end
                object GridCariProjelerViewSATISKUR: TcxGridDBColumn
                  Caption = 'Sat'#305#351' P.Birimi'
                  DataBinding.FieldName = 'SATISKUR'
                  PropertiesClassName = 'TcxComboBoxProperties'
                end
                object GridCariProjelerViewNOTLAR: TcxGridDBColumn
                  Caption = 'Notlar'
                  DataBinding.FieldName = 'NOTLAR'
                end
              end
              object GridCariProjelerDBTableView1: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.GridMode = True
                DataController.DataModeController.SmartRefresh = True
                DataController.DetailKeyFieldNames = 'SOZID'
                DataController.MasterKeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsView.GroupByBox = False
                object GridCariProjelerDBTableView1TUR: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                end
                object GridCariProjelerDBTableView1BELGEADI: TcxGridDBColumn
                  Caption = 'Belge Ad'#305
                  DataBinding.FieldName = 'BELGEADI'
                end
              end
              object GridCariProjelerLevel1: TcxGridLevel
                GridView = GridCariProjelerView
              end
            end
          end
          object SheetAktiviteler: TcxTabSheet
            Caption = 'Aktiviteler'
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 470
            object GridCariAktiviteler: TcxGrid
              Left = 0
              Top = 0
              Width = 986
              Height = 481
              Align = alClient
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = False
              ExplicitHeight = 470
              object GridCariAktivitelerView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridCariAktivitelerViewBITTARIHI: TcxGridDBColumn
                  Caption = 'Tarih/Saat'
                  DataBinding.FieldName = 'BITISTARIHI'
                  Width = 73
                end
                object GridCariAktivitelerViewPROJEKODU: TcxGridDBColumn
                  Caption = 'Proje'
                  DataBinding.FieldName = 'PROJEKODU'
                  Width = 76
                end
                object GridCariAktivitelerViewTURU: TcxGridDBColumn
                  Caption = 'T'#252'r'#252
                  DataBinding.FieldName = 'TURU'
                  RepositoryItem = Tablo.repAktiviteTuru
                  Width = 69
                end
                object GridCariAktivitelerViewTIPI: TcxGridDBColumn
                  Caption = 'Tipi'
                  DataBinding.FieldName = 'TIPI'
                  RepositoryItem = Tablo.repAktiviteTipi
                end
                object GridCariAktivitelerViewKONU: TcxGridDBColumn
                  Caption = 'Konu'
                  DataBinding.FieldName = 'KONUSU'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 109
                end
                object GridCariAktivitelerViewKONUM: TcxGridDBColumn
                  Caption = 'Konum'
                  DataBinding.FieldName = 'KONUM'
                  RepositoryItem = Tablo.repAktiviteKonum
                  Width = 95
                end
                object GridCariAktivitelerViewSORUMLU: TcxGridDBColumn
                  Caption = 'Sorumlu'
                  DataBinding.FieldName = 'SORUMLUAD'
                  Width = 55
                end
                object GridCariAktivitelerViewILGILI1: TcxGridDBColumn
                  Caption = #304'lgili1'
                  DataBinding.FieldName = 'ILGILI1AD'
                  Width = 79
                end
                object GridCariAktivitelerViewDURUM: TcxGridDBColumn
                  Caption = 'Durum'
                  DataBinding.FieldName = 'DURUM'
                  RepositoryItem = Tablo.repAktiviteDurum
                  Width = 51
                end
                object GridCariAktivitelerViewNOTLAR: TcxGridDBColumn
                  Caption = 'Notlar'
                  DataBinding.FieldName = 'NOTLAR'
                  Width = 163
                end
              end
              object cxGridLevel8: TcxGridLevel
                GridView = GridCariAktivitelerView
              end
            end
          end
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1004
    Height = 38
    Align = alTop
    TabOrder = 1
    object cxDBTextEdit1: TcxDBTextEdit
      Left = 68
      Top = 8
      DataBinding.DataField = 'KOD'
      DataBinding.DataSource = DtsRehber
      Enabled = False
      TabOrder = 0
      Width = 125
    end
    object cxDBTextEdit2: TcxDBTextEdit
      Left = 199
      Top = 8
      DataBinding.DataField = 'FIRMA'
      DataBinding.DataSource = DtsRehber
      Enabled = False
      TabOrder = 1
      Width = 241
    end
    object cxDBImageComboBox1: TcxDBImageComboBox
      Left = 544
      Top = 8
      RepositoryItem = Tablo.RepCariGrup
      DataBinding.DataField = 'GRUP'
      DataBinding.DataSource = DtsRehber
      Enabled = False
      Properties.Items = <>
      TabOrder = 2
      Width = 92
    end
    object cxDBImageComboBox2: TcxDBImageComboBox
      Left = 672
      Top = 8
      RepositoryItem = Tablo.RepCariSinif
      DataBinding.DataField = 'SINIF'
      DataBinding.DataSource = DtsRehber
      Enabled = False
      Properties.Items = <>
      TabOrder = 3
      Width = 97
    end
    object cxLabel1: TcxLabel
      Left = 5
      Top = 10
      Caption = 'Kod/'#220'nvan'
      Enabled = False
    end
    object cxLabel3: TcxLabel
      Left = 511
      Top = 10
      Caption = 'Grup'
      Enabled = False
    end
    object cxLabel4: TcxLabel
      Left = 642
      Top = 10
      Caption = 'S'#305'n'#305'f'
      Enabled = False
    end
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 930
      Top = 4
      Width = 70
      Height = 33
      Margins.Bottom = 0
      Align = alRight
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 68
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
      Images = AnaForm.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 7
      Transparent = True
      ExplicitLeft = 808
      ExplicitHeight = 40
      object YaziciYaz: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yazd'#305'r'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 16
        Style = tbsTextButton
      end
    end
  end
  object TabRehberIlet: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabRehberIletAfterScroll
    ParamData = <>
    SQL.Strings = (
      ''
      'select *'
      'from REHBERILETISIM'
      'where REHBERID=:PID '
      'Order by VARSAYILAN  desc')
    Left = 499
    Top = 140
  end
  object DtsKurIlet: TDataSource
    DataSet = TabKurIlet
    Left = 437
    Top = 190
  end
  object TabKurIlet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      
        'select distinct RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA' +
        '.ZORUNLU '
      
        'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.ETIKET=RA.ETI' +
        'KET'
      'where RB.YERI=1  and RB.YER_ID= :Yeri_Id   '
      'order by  1'
      '')
    Left = 435
    Top = 140
  end
  object DtsRehberIlet: TDataSource
    DataSet = TabRehberIlet
    Left = 500
    Top = 191
  end
  object TabTicari: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      
        'select distinct  RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,R' +
        'A.ZORUNLU  '
      
        'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.ETIKET=RA.ETI' +
        'KET'
      'where RB.YERI= 2  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 563
    Top = 140
  end
  object DtsTicari: TDataSource
    DataSet = TabTicari
    Left = 566
    Top = 192
  end
  object TabIlgili: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabIlgiliAfterScroll
    ParamData = <>
    SQL.Strings = (
      ''
      'select *'
      'from REHBERPERSONEL'
      'where REHBERID=:PID '
      'Order by VARSAYILAN  desc')
    Left = 665
    Top = 142
  end
  object DtsIlgili: TDataSource
    DataSet = TabIlgili
    Left = 666
    Top = 192
  end
  object TabPerIlet: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select distinct  RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK ,' +
        'RA.ZORUNLU '
      
        'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.ETIKET=RA.ETI' +
        'KET'
      'where RB.YERI=4  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 615
    Top = 142
  end
  object DtsPerIlet: TDataSource
    DataSet = TabPerIlet
    Left = 616
    Top = 193
  end
  object TabDokuman: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT DISTINCT D.*,TIP=1,'
      
        'EXT='#39'.'#39'+REVERSE( SUBSTRING(REVERSE(isnull((select Top 1 AD from ' +
        'DOKUMAN I where  I.ID=D.ID order '
      
        'by I.ID desc),'#39'.'#39')),1,CHARINDEX('#39'.'#39',REVERSE(isnull((select Top 1' +
        ' AD from DOKUMAN I where  I.ID=D.ID '
      'order by I.ID desc),'#39'.'#39')),1)-1))'
      '  FROM  DOKUMAN  D INNER JOIN DOKUMANYETKI DY  ON D.ID=DY.YERID '
      'WHERE'
      'D.REHBERID= :PRehberID AND'
      'D.KLASOR>0')
    Left = 786
    Top = 188
  end
  object DtsDokuman: TDataSource
    DataSet = TabDokuman
    Left = 785
    Top = 235
  end
  object TabRehber: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'select * from REHBER where ID=:PRehID')
    Left = 56
    Top = 208
  end
  object DtsRehber: TDataSource
    DataSet = TabRehber
    Left = 56
    Top = 256
  end
  object tabTeklifler: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = tabTekliflerAfterScroll
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'select * from TEKLIF where REHBERID=:PRehID'
      'order by TARIH')
    Left = 112
    Top = 209
  end
  object DtsTeklifler: TDataSource
    DataSet = tabTeklifler
    Left = 112
    Top = 257
  end
  object tabSiparisler: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = tabSiparislerAfterScroll
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'select S.*,'
      
        'ISEMRIDURUM=isnull((select I.DURUM from ISEMRI I where I.YERI=S.' +
        'TUR and I.YERID=S.ID),-1),'
      
        'ONAYLAYAN=(select I.EKLEYEN from ISEMRI I where I.YERI=S.TUR and' +
        ' I.YERID=S.ID)'
      ' from SIPARIS S where S.REHBERID=:PRehID'
      'order by S.TARIH')
    Left = 176
    Top = 210
  end
  object DtsSiparisler: TDataSource
    DataSet = tabSiparisler
    Left = 176
    Top = 258
  end
  object tabEkstre: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      
        'select * from dbo.fn_Cari_Ekstre (:PRehID,:PBasTar,:PBitTar) ord' +
        'er by TARIH')
    Left = 290
    Top = 211
  end
  object DtsEkstre: TDataSource
    DataSet = tabEkstre
    Left = 290
    Top = 259
  end
  object TabProjeler: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select P.ID,P.REHBERID,P.PROJEKODU,Firma.FIRMA, BASLAMATARIHI,TU' +
        'RU,KONUSU,ASAMA,LISTEFIYATI,LISTEKUR,SATISFIYATI,SATISKUR, '
      
        'PRJ_SORUMLUSU_ID,PRJ_ASAMA_SORUMLUSU_ID,ProjeSorumlu.FIRMA as PR' +
        'J_SORUMLUAD, AsamaSorumlu.FIRMA as PRJ_ASAMASORUMLUAD, '
      'RehberIlgili.ADSOYAD, P.DURUM,P.NOTLAR , BITISTARIHI ,'
      
        'ProjeTuru.ANAHTAR PROJETURU, ProjeAsama.ANAHTAR PROJEASAMA, Proj' +
        'eDurum.ANAHTAR PROJEDURUM'
      'from PROJELER P '
      #9'INNER JOIN REHBER Firma on Firma.ID = P.REHBERID'
      
        #9'INNER JOIN REHBER ProjeSorumlu on ProjeSorumlu.ID = P.PRJ_SORUM' +
        'LUSU_ID'
      
        #9'LEFT OUTER JOIN REHBER AsamaSorumlu on AsamaSorumlu.ID=P.PRJ_AS' +
        'AMA_SORUMLUSU_ID'
      
        #9'LEFT OUTER JOIN REHBERPERSONEL RehberIlgili on RehberIlgili.ID=' +
        'P.ILGILI'
      
        #9'LEFT OUTER JOIN REHBERINI ProjeTuru ON ProjeTuru.DEGER = P.TURU' +
        ' AND ProjeTuru.BOLUM ='#39'Proje_T'#252'r'#252#39
      
        #9'LEFT OUTER JOIN REHBERINI ProjeAsama ON ProjeAsama.DEGER = P.AS' +
        'AMA AND ProjeAsama.BOLUM ='#39'Proje_A'#351'ama'#39
      
        #9'LEFT OUTER JOIN REHBERINI ProjeDurum ON ProjeDurum.DEGER = P.DU' +
        'RUM AND ProjeDurum.BOLUM ='#39'Proje_Durum'#39
      'WHERE '
      'P.REHBERID = :PID'
      'AND P.DURUM = 1'#9
      'ORDER BY BITISTARIHI DESC')
    Left = 857
    Top = 178
  end
  object DtsProjeler: TDataSource
    DataSet = TabProjeler
    Left = 857
    Top = 228
  end
  object TabAktiviteler: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'select'
      ' A.ID, PR.PROJEKODU,'
      #9'A.MUSTERIID,'
      #9'Musteri.FIRMA MUSTERI,'
      #9'A.TURU,A.TIPI,'
      #9'A.BASLAMATARIHI,A.BITISTARIHI,A.KONUSU,'
      #9'A.KONUM,'
      ' isnull(A.SORUMLU,'#39#39') SORUMLU ,'
      #9'isnull(SorumluPers.FIRMA,'#39#39') as SORUMLUAD,'
      #9'ILGILI1AD=MusteriIlgi1.ADSOYAD,'
      #9'ILGILI2AD=MusteriIlgi2.ADSOYAD,'
      #9'A.SONUC,'
      #9'A.DURUM,'
      #9'A.NOTLAR,'
      #9'A.ILGILI1,'
      #9'A.ILGILI2,'
      #9'A.ATAYAN,'
      #9'ATAYANAD=AtayanPers.FIRMA,'
      #9'BILGIAD=BilgiPers.FIRMA,'
      #9'TAKIPCIAD=TakipciPers.FIRMA,'
      
        ' ANIMSATICI = CASE WHEN (A.ANIMSAT >0 AND ISNULL(ANIMSATMATARIHI' +
        ','#39'1900-01-01'#39')>'#39'1900-01-01'#39') THEN 1 ELSE 0 END,'
      
        ' DOSYAVAR = CASE WHEN (SELECT TOP 1 COUNT(ID) FROM IMAJ WHERE YE' +
        'RI = 51 AND YER_ID = A.ID ) = 1 THEN 1 ELSE 0 END,'
      ' BAGLANTI'
      'from '
      #9'AKTIVITELER A'
      #9#9#9#9' left outer join REHBER Musteri on Musteri.ID=A.MUSTERIID'
      #9#9' inner join REHBER SorumluPers on SorumluPers.ID=A.SORUMLU'
      
        #9#9' left outer join REHBERPERSONEL MusteriIlgi1 on MusteriIlgi1.I' +
        'D=A.ILGILI1'
      
        #9#9' left outer join REHBERPERSONEL MusteriIlgi2 on MusteriIlgi2.I' +
        'D=A.ILGILI2'
      #9#9
      #9#9' left outer join REHBER AtayanPers on AtayanPers.ID=A.ATAYAN'
      
        #9#9#9#9' left outer join REHBER BilgiPers on BilgiPers.ID=A.BILGILEN' +
        'DIRILECEK'
      
        #9#9#9#9' left outer join REHBER TakipciPers on TakipciPers.ID=A.TAKI' +
        'PCI'
      #9#9' left outer join PROJELER PR on PR.ID=A.PROJEID'
      'where'
      #9#9'A.MUSTERIID = :PREHBERID'
      
        ' AND A.BITISTARIHI <= convert(datetime, convert(varchar(10), :PB' +
        'ITTAR,103)+'#39' 23:59:59'#39',103)'
      ' AND A.DURUM <> 4 /* iptal */')
    Left = 917
    Top = 179
  end
  object DtsAktiviteler: TDataSource
    DataSet = TabAktiviteler
    Left = 917
    Top = 229
  end
  object TabTeklifDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'Select T.* , '
      
        'AD =  CASE WHEN T.TUR IN( 1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = T.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ' +
        'ID = T.URUNID)  END,'
      
        'KOD =  CASE WHEN T.TUR IN (1,11)  THEN (SELECT KOD FROM STOKLAR ' +
        'WHERE ID = T.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE I' +
        'D= T.URUNID )  END'
      'from TEKLIFDETAY T '
      'Where TEKLIFID =:PTid '
      '')
    Left = 112
    Top = 300
  end
  object DtsTeklifDetay: TDataSource
    DataSet = TabTeklifDetay
    Left = 112
    Top = 345
  end
  object DtsSiparisDetay: TDataSource
    DataSet = TabSiparisDetay
    Left = 176
    Top = 345
  end
  object TabSiparisDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      ''
      'Select '
      #9'F.*,'
      
        '               AD =  CASE WHEN F.TUR IN( 1,11) THEN (SELECT STOK' +
        'ADI FROM STOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT AD FROM MAS' +
        'RAFGELIR WHERE ID = F.URUNID)  END,'
      
        '               KOD =  CASE WHEN F.TUR IN (1,11)  THEN (SELECT KO' +
        'D FROM STOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT KOD FROM MASR' +
        'AFGELIR WHERE ID= F.URUNID )  END'
      'from '
      #9'SIPARISDETAY F                         '
      'Where '
      #9'F.SIPARISID = :Par'
      '')
    Left = 175
    Top = 300
  end
  object tabFatura: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = tabFaturaAfterScroll
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      'select F.*'
      ' from FATBASLIK F '
      'where F.REHBERID=:PRehID'
      'order by F.FATURATARIH')
    Left = 242
    Top = 211
  end
  object DtsFatura: TDataSource
    DataSet = tabFatura
    Left = 242
    Top = 259
  end
  object tabFatDetay: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'Select '
      #9'F.*,'
      
        '               AD =  CASE WHEN F.TUR IN( 1,11) THEN (SELECT STOK' +
        'ADI FROM STOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT AD FROM MAS' +
        'RAFGELIR WHERE ID = F.URUNID)  END,'
      
        '               KOD =  CASE WHEN F.TUR IN (1,11)  THEN (SELECT KO' +
        'D FROM STOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT KOD FROM MASR' +
        'AFGELIR WHERE ID= F.URUNID )  END'
      'from '
      #9'FATURA F                         '
      'Where '
      #9'F.FATBASID = :Par'
      ''
      ''
      '')
    Left = 239
    Top = 308
  end
  object DtsFatDetay: TDataSource
    DataSet = tabFatDetay
    Left = 240
    Top = 353
  end
  object tabEkstreDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Prepared = True
    SQL.Strings = (
      
        'select * from dbo.fn_Cari_Detayli_Ekstre(:PRehID,:PBasTar,:PBitT' +
        'ar) order by TARIH')
    Left = 346
    Top = 211
  end
  object DtsEktreDetay: TDataSource
    DataSet = tabEkstreDetay
    Left = 346
    Top = 259
  end
  object PopupMenuYaz: TPopupMenu
    Left = 53
    Top = 418
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxRehber: TfrxDBDataset
    UserName = 'Rehber'
    CloseDataSource = False
    DataSet = TabRehber
    BCDToCurrency = False
    Left = 56
    Top = 168
  end
  object frxPerIlet: TfrxDBDataset
    UserName = 'PerIlet'
    CloseDataSource = False
    DataSet = TabPerIlet
    BCDToCurrency = False
    Left = 616
    Top = 240
  end
  object frxTicari: TfrxDBDataset
    UserName = 'Ticari'
    CloseDataSource = False
    DataSet = TabTicari
    BCDToCurrency = False
    Left = 560
    Top = 240
  end
  object frxRehberIlet: TfrxDBDataset
    UserName = 'RehberIlet'
    CloseDataSource = False
    DataSet = TabRehberIlet
    BCDToCurrency = False
    Left = 496
    Top = 240
  end
  object frxKurIlet: TfrxDBDataset
    UserName = 'KurIlet'
    CloseDataSource = False
    DataSet = TabKurIlet
    BCDToCurrency = False
    Left = 432
    Top = 232
  end
  object frxTeklifler: TfrxDBDataset
    UserName = 'Teklifler'
    CloseDataSource = False
    DataSet = tabTeklifler
    BCDToCurrency = False
    Left = 112
    Top = 128
  end
  object frxTeklifDetay: TfrxDBDataset
    UserName = 'TeklifDetay'
    CloseDataSource = False
    DataSet = TabTeklifDetay
    BCDToCurrency = False
    Left = 112
    Top = 168
  end
  object frxSiparisDetay: TfrxDBDataset
    UserName = 'SiparisDetay'
    CloseDataSource = False
    DataSet = TabSiparisDetay
    BCDToCurrency = False
    Left = 176
    Top = 128
  end
  object frxFatDetay: TfrxDBDataset
    UserName = 'FatDetay'
    CloseDataSource = False
    DataSet = tabFatDetay
    BCDToCurrency = False
    Left = 240
    Top = 128
  end
  object frxSiparisler: TfrxDBDataset
    UserName = 'Siparisler'
    CloseDataSource = False
    DataSet = tabSiparisler
    BCDToCurrency = False
    Left = 176
    Top = 168
  end
  object frxFatura: TfrxDBDataset
    UserName = 'Fatura'
    CloseDataSource = False
    DataSet = tabFatura
    BCDToCurrency = False
    Left = 240
    Top = 176
  end
  object frxEkstre: TfrxDBDataset
    UserName = 'Ekstre'
    CloseDataSource = False
    DataSet = tabEkstre
    BCDToCurrency = False
    Left = 288
    Top = 176
  end
  object frxEkstreDetay: TfrxDBDataset
    UserName = 'EkstreDetay'
    CloseDataSource = False
    DataSet = tabEkstreDetay
    BCDToCurrency = False
    Left = 344
    Top = 168
  end
  object frxDokuman: TfrxDBDataset
    UserName = 'Dokuman'
    CloseDataSource = False
    DataSet = TabDokuman
    BCDToCurrency = False
    Left = 784
    Top = 136
  end
  object frxAktiviteler: TfrxDBDataset
    UserName = 'Aktiviteler'
    CloseDataSource = False
    DataSet = TabAktiviteler
    BCDToCurrency = False
    Left = 920
    Top = 136
  end
  object frxProjeler: TfrxDBDataset
    UserName = 'Projeler'
    CloseDataSource = False
    DataSet = TabProjeler
    BCDToCurrency = False
    Left = 864
    Top = 136
  end
  object frxIlgili: TfrxDBDataset
    UserName = 'Ilgili'
    CloseDataSource = False
    DataSet = TabIlgili
    BCDToCurrency = False
    Left = 664
    Top = 240
  end
end
