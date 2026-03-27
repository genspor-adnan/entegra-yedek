object ITSBildirimDlg: TITSBildirimDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #304'ts '#304#351'lemleri '
  ClientHeight = 650
  ClientWidth = 1177
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 1358
    Top = 61
    Width = 644
    Height = 480
    TabOrder = 0
    object PnlAra: TPanel
      Left = 1
      Top = 36
      Width = 642
      Height = 45
      Align = alTop
      Color = 14540253
      ParentBackground = False
      TabOrder = 0
      object TxtUrunKodu: TcxTextEdit
        Left = 5
        Top = 21
        TabOrder = 0
        Width = 121
      end
      object TxtUrunSeriNo: TcxTextEdit
        Left = 132
        Top = 21
        TabOrder = 1
        Width = 121
      end
      object cxLabel1: TcxLabel
        Left = 5
        Top = 3
        Caption = #220'r'#252'n Kodu'
      end
      object cxLabel2: TcxLabel
        Left = 132
        Top = 4
        Caption = #220'r'#252'n Seri no'
      end
      object cxButton1: TcxButton
        Left = 259
        Top = 5
        Width = 75
        Height = 36
        Caption = 'Ara'
        TabOrder = 4
        OnClick = cxButton1Click
      end
    end
    object PcBildirim: TcxPageControl
      Left = 1
      Top = 81
      Width = 642
      Height = 398
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      TabOrder = 1
      Properties.ActivePage = TsGecmis
      Properties.CustomButtons.Buttons = <>
      Properties.Style = 8
      OnContextPopup = PcBildirimContextPopup
      ClientRectBottom = 398
      ClientRectRight = 642
      ClientRectTop = 24
      object TsDogrulamaBildirim: TcxTabSheet
        Caption = 'Do'#287'rulama Bildirim'
        ImageIndex = 0
        object GridDogrulaBildirim: TcxGrid
          Left = 0
          Top = 0
          Width = 642
          Height = 374
          Align = alClient
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvDogrulamabildirim: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object ColSecDogrulama: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Width = 20
            end
            object cxGridDBColumn2: TcxGridDBColumn
              Caption = 'Fatura Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              Visible = False
              GroupIndex = 0
              Width = 80
            end
            object cxGridDBColumn3: TcxGridDBColumn
              Caption = 'Fatura Ba'#351'l'#305#287#305
              DataBinding.FieldName = 'BASLIK'
              Visible = False
              GroupIndex = 1
              Width = 100
            end
            object cxGridDBColumn4: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNBARKOD'
              Visible = False
              GroupIndex = 2
              Width = 100
            end
            object cxGridDBColumn5: TcxGridDBColumn
              Caption = 'S'#305'ra No'
              DataBinding.FieldName = 'SIRANO'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn6: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              Options.Editing = False
              Width = 75
            end
            object cxGridDBColumn7: TcxGridDBColumn
              Caption = 'Son Kullan'#305'm Tarihi'
              DataBinding.FieldName = 'SONKULLANIM'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn8: TcxGridDBColumn
              Caption = 'Do'#287'rulama Durum'
              DataBinding.FieldName = 'DOGRULAMA_DURUM'
              Options.Editing = False
              Width = 350
            end
            object cxGridDBColumn10: TcxGridDBColumn
              Caption = 'Do'#287'rulama Tarih'
              DataBinding.FieldName = 'DOGRULAMA_TARIH'
              Options.Editing = False
              Width = 100
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = TvDogrulamabildirim
          end
        end
      end
      object TsMalAlim: TcxTabSheet
        Caption = 'Mal - Al'#305'm Bildirimi '
        ImageIndex = 1
        object Label1: TLabel
          Left = 200
          Top = 176
          Width = 71
          Height = 13
          Caption = 'FATURATARIH'
        end
        object GridMalAlimBildirim: TcxGrid
          Left = 0
          Top = 0
          Width = 642
          Height = 374
          Align = alClient
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvMalAlimListe: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object ColSecMalAlim: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Width = 20
            end
            object TvMalAlimListeFATURATARIH: TcxGridDBColumn
              Caption = 'Fatura Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              Visible = False
              GroupIndex = 0
              Width = 80
            end
            object TvMalAlimListeBASLIK: TcxGridDBColumn
              Caption = 'Fatura Ba'#351'l'#305#287#305
              DataBinding.FieldName = 'BASLIK'
              Visible = False
              GroupIndex = 1
              Width = 200
            end
            object TvMalAlimListeURUNKOD: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNBARKOD'
              Visible = False
              GroupIndex = 2
              Width = 100
            end
            object TvMalAlimListeSERINO: TcxGridDBColumn
              Caption = 'S'#305'ra No'
              DataBinding.FieldName = 'SIRANO'
              Options.Editing = False
              Width = 100
            end
            object TvMalAlimListeLOTNO: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              Options.Editing = False
              Width = 75
            end
            object TvMalAlimListeSONKULLANIM: TcxGridDBColumn
              Caption = 'Son Kullan'#305'm Tarihi'
              DataBinding.FieldName = 'SONKULLANIM'
              Options.Editing = False
              Width = 100
            end
            object TvMalAlimListeALIM_DURUM: TcxGridDBColumn
              Caption = 'Al'#305'm Durum'
              DataBinding.FieldName = 'ALIM_DURUM'
              Options.Editing = False
              Width = 350
            end
            object TvMalAlimListeDOGRULAMA_DURUM: TcxGridDBColumn
              Caption = 'Al'#305'm Bildirim Tarih'
              DataBinding.FieldName = 'ALIM_BILDIRIM_TARIH'
              Options.Editing = False
              Width = 100
            end
          end
          object GridMalAlimBildirimLevel1: TcxGridLevel
            GridView = TvMalAlimListe
          end
        end
      end
      object TsMalIade: TcxTabSheet
        Caption = 'Mal - '#304'ade Bildirimi'
        ImageIndex = 2
        object GridMalIade: TcxGrid
          Left = 0
          Top = 0
          Width = 642
          Height = 374
          Align = alClient
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvMalIade: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object ColSecMalIade: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Width = 20
            end
            object cxGridDBColumn11: TcxGridDBColumn
              Caption = 'Fatura Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              Visible = False
              GroupIndex = 0
              Width = 80
            end
            object cxGridDBColumn12: TcxGridDBColumn
              Caption = 'Fatura Ba'#351'l'#305#287#305
              DataBinding.FieldName = 'BASLIK'
              Visible = False
              GroupIndex = 1
              Width = 200
            end
            object cxGridDBColumn13: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNBARKOD'
              Visible = False
              GroupIndex = 2
              Width = 100
            end
            object cxGridDBColumn14: TcxGridDBColumn
              Caption = 'S'#305'ra No'
              DataBinding.FieldName = 'SIRANO'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn15: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              Options.Editing = False
              Width = 75
            end
            object cxGridDBColumn16: TcxGridDBColumn
              Caption = 'Son Kullan'#305'm Tarihi'
              DataBinding.FieldName = 'SONKULLANIM'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn20: TcxGridDBColumn
              Caption = 'Al'#305'm '#304'ade Bildirim Durum'
              DataBinding.FieldName = 'ALIM_IADE_DURUM'
              Options.Editing = False
              Width = 350
            end
            object cxGridDBColumn19: TcxGridDBColumn
              Caption = 'Al'#305'm - '#304'ade Bildirim Tarih'
              DataBinding.FieldName = 'ALIM_IADE_BILDIRIM_TARIH'
              Options.Editing = False
              Width = 100
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = TvMalIade
          end
        end
      end
      object TsSatisBildirim: TcxTabSheet
        Caption = 'Sat'#305#351' Bildirim'
        ImageIndex = 3
        object GridSatis: TcxGrid
          Left = 0
          Top = 0
          Width = 642
          Height = 374
          Align = alClient
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvSatis: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skCount
                FieldName = 'SIRANO'
                Column = ColSecSatis
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.FooterMultiSummaries = True
            OptionsView.GroupByBox = False
            object ColSecSatis: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Width = 20
            end
            object cxGridDBColumn9: TcxGridDBColumn
              Caption = 'Fatura Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              Visible = False
              GroupIndex = 0
              Width = 80
            end
            object cxGridDBColumn17: TcxGridDBColumn
              Caption = 'Fatura Ba'#351'l'#305#287#305
              DataBinding.FieldName = 'BASLIK'
              Visible = False
              GroupIndex = 1
              Width = 100
            end
            object cxGridDBColumn18: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNBARKOD'
              Visible = False
              GroupIndex = 2
              Width = 100
            end
            object cxGridDBColumn21: TcxGridDBColumn
              Caption = 'S'#305'ra No'
              DataBinding.FieldName = 'SIRANO'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn22: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              Options.Editing = False
              Width = 75
            end
            object cxGridDBColumn23: TcxGridDBColumn
              Caption = 'Son Kullan'#305'm Tarihi'
              DataBinding.FieldName = 'SONKULLANIM'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn28: TcxGridDBColumn
              Caption = 'Sat'#305#351' Durum'
              DataBinding.FieldName = 'SATIS_DURUM'
              Options.Editing = False
              Width = 350
            end
            object cxGridDBColumn29: TcxGridDBColumn
              Caption = 'Sat'#305#351' Bildirim Tarih'
              DataBinding.FieldName = 'SATIS_BILDIRIM_TARIH'
              Options.Editing = False
              Width = 100
            end
          end
          object cxGridLevel3: TcxGridLevel
            GridView = TvSatis
          end
        end
      end
      object TsSatisIptalBil: TcxTabSheet
        Caption = 'Sat'#305#351' - '#304'ptal Bildirim'
        ImageIndex = 4
      end
      object TsDeAktivasyon: TcxTabSheet
        Caption = 'DeAktivasyon'
        ImageIndex = 5
        object GridDeAktivasyon: TcxGrid
          Left = 0
          Top = 0
          Width = 642
          Height = 374
          Align = alClient
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvDeaktivasyon: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object ColSecDeAktivasyon: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Width = 20
            end
            object cxGridDBColumn24: TcxGridDBColumn
              Caption = 'Fatura Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              Visible = False
              GroupIndex = 0
              Width = 80
            end
            object cxGridDBColumn35: TcxGridDBColumn
              Caption = 'Fatura Ba'#351'l'#305#287#305
              DataBinding.FieldName = 'BASLIK'
              Visible = False
              GroupIndex = 1
              Width = 100
            end
            object cxGridDBColumn36: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNBARKOD'
              Visible = False
              GroupIndex = 2
              Width = 100
            end
            object cxGridDBColumn37: TcxGridDBColumn
              Caption = 'S'#305'ra No'
              DataBinding.FieldName = 'SIRANO'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn38: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              Options.Editing = False
              Width = 75
            end
            object cxGridDBColumn39: TcxGridDBColumn
              Caption = 'Son Kullan'#305'm Tarihi'
              DataBinding.FieldName = 'SONKULLANIM'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn40: TcxGridDBColumn
              Caption = 'DeAktivasyon Durum'
              DataBinding.FieldName = 'DEAKTIVASYON_DURUM'
              Options.Editing = False
              Width = 350
            end
            object cxGridDBColumn41: TcxGridDBColumn
              Caption = 'DeAktivasyon Bildirim Tarih'
              DataBinding.FieldName = 'DEAKTIVASYON_BILDIRIM_TARIH'
              Options.Editing = False
              Width = 100
            end
          end
          object cxGridLevel5: TcxGridLevel
            GridView = TvDeaktivasyon
          end
        end
      end
      object TsGecmis: TcxTabSheet
        Caption = 'Ge'#231'mi'#351
        ImageIndex = 7
        object GridGecmis: TcxGrid
          Left = 456
          Top = 274
          Width = 104
          Height = 104
          TabOrder = 0
          object TvGecmis: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object TvGecmisURUN_DURUM: TcxGridDBColumn
              Caption = 'Durumu'
              DataBinding.FieldName = 'URUN_DURUM'
              GroupSummaryAlignment = taCenter
              HeaderAlignmentHorz = taCenter
              HeaderGlyphAlignmentHorz = taCenter
              Width = 120
            end
            object TvGecmisURUN_BARKOD_NO: TcxGridDBColumn
              Caption = 'Barkod'
              DataBinding.FieldName = 'URUN_BARKOD_NO'
              Visible = False
              GroupIndex = 0
              GroupSummaryAlignment = taCenter
              HeaderAlignmentHorz = taCenter
              HeaderGlyphAlignmentHorz = taCenter
              Width = 100
            end
            object TvGecmisURUN_SIRA_NO: TcxGridDBColumn
              Caption = 'S'#305'ra'
              DataBinding.FieldName = 'URUN_SIRA_NO'
              Visible = False
              GroupIndex = 1
              GroupSummaryAlignment = taCenter
              HeaderAlignmentHorz = taCenter
              HeaderGlyphAlignmentHorz = taCenter
              Width = 50
            end
            object TvGecmisBILDIRIM_TARIH: TcxGridDBColumn
              Caption = 'Bildirim Tarihi'
              DataBinding.FieldName = 'BILDIRIM_TARIH'
              GroupSummaryAlignment = taCenter
              HeaderAlignmentHorz = taCenter
              HeaderGlyphAlignmentHorz = taCenter
              Width = 100
            end
            object TvGecmisHATA_KODU: TcxGridDBColumn
              Caption = 'Hata Kodu'
              DataBinding.FieldName = 'HATA_KODU'
              GroupSummaryAlignment = taCenter
              HeaderAlignmentHorz = taCenter
              HeaderGlyphAlignmentHorz = taCenter
              Width = 70
            end
            object TvGecmisHATA_ACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'HATA_ACIKLAMA'
              FooterAlignmentHorz = taCenter
              GroupSummaryAlignment = taCenter
              HeaderAlignmentHorz = taCenter
              HeaderGlyphAlignmentHorz = taCenter
              Width = 450
            end
          end
          object cxGridLevel6: TcxGridLevel
            GridView = TvGecmis
          end
        end
        object BtnSendPackage: TButton
          Left = 19
          Top = 32
          Width = 176
          Height = 41
          Caption = 'SendPackage'
          TabOrder = 1
        end
        object cxTextEdit1: TcxTextEdit
          Left = 19
          Top = 5
          TabOrder = 2
          Text = 'cxTextEdit1'
          Width = 121
        end
        object BtnReceiverPackage: TButton
          Left = 19
          Top = 79
          Width = 176
          Height = 41
          Caption = 'ReceiverPackage'
          TabOrder = 3
          OnClick = BtnReceiverPackageClick
        end
        object BtnCreateXML: TButton
          Left = 19
          Top = 126
          Width = 176
          Height = 41
          Caption = 'CreateXML'
          TabOrder = 4
          OnClick = BtnReceiverPackageClick
        end
      end
      object TsUretim: TcxTabSheet
        Caption = #220'retim Bildirimi'
        ImageIndex = 8
        object UretimAletCubugu: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 636
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 111
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
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object TbKarekodYaz: TToolButton
            Left = 0
            Top = 0
            Caption = 'Karekod Yazd'#305'r'
            ImageIndex = 16
            Style = tbsTextButton
            OnClick = TbKarekodYazClick
          end
        end
      end
    end
    object TBItsAracCubugu: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 636
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 117
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
      Images = Tablo.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 2
      Transparent = True
      object BildirTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Web Servis Bildir'
        ImageIndex = 12
        Style = tbsTextButton
        OnClick = BildirTusClick
      end
    end
  end
  object BarBildirim: TdxNavBar
    Left = 727
    Top = 360
    Width = 217
    Height = 205
    ActiveGroupIndex = 0
    TabOrder = 1
    View = 17
    ViewStyle.ColorSchemeName = 'Blue'
    OptionsBehavior.Common.AllowSelectLinks = True
    OptionsBehavior.Common.EachGroupHasSelectedLink = True
    OptionsBehavior.Common.ShowGroupsHint = True
    OptionsBehavior.Common.ShowLinksHint = True
    OptionsView.ExplorerBar.ShowSpecialGroup = True
    OnActiveGroupChanged = BarBildirimActiveGroupChanged
    OnLinkClick = BarBildirimLinkClick
    object GroupBilYap: TdxNavBarGroup
      Caption = 'Bildirimi Yap'#305'lm'#305#351
      SelectedLinkIndex = -1
      TopVisibleLinkIndex = 0
      Links = <
        item
          Item = BarBildirimItem1
        end
        item
          Item = ItemMalAlim
        end
        item
          Item = BarBildirimItem2
        end
        item
          Item = ItemSatis
        end
        item
          Item = BarBildirimItem3
        end
        item
          Item = ItemDeAktivasyon
        end
        item
          Item = ItemGecmis
        end
        item
          Item = ItemUretim
        end>
    end
    object GroupBilYapilmamis: TdxNavBarGroup
      Caption = 'Bildirimi Hatal'#305' veya Yap'#305'lmam'#305#351
      SelectedLinkIndex = -1
      TopVisibleLinkIndex = 0
      Links = <
        item
          Item = ItemDogrulama
        end
        item
          Item = ItemMalAlim
        end
        item
          Item = ItemMalAlimIade
        end
        item
          Item = ItemSatis
        end
        item
          Item = ItemSatisIptal
        end
        item
          Item = ItemDeAktivasyon
        end
        item
          Item = BarBildirimItem2
        end
        item
          Item = ItemUretim
        end>
    end
    object ItemDogrulama: TdxNavBarItem
      Caption = 'Do'#287'rulama'
      Hint = 
        '|'#220'r'#252'n'#252'n sistemde bulunup bulunmad'#305#287#305', karekod bilgilerinin tutar' +
        'l'#305' olup olmad'#305#287#305', '#252'r'#252'n'#252'n daha '#246'nceden sat'#305'l'#305'p'#13#10'sat'#305'lmad'#305#287#305' gibi ' +
        'kontrolleri yapabilecekleri bir bildirimdir.'#13#10'Kontrol i'#351'lemi '#252'r'#252 +
        'nler i'#231'in tek tek yap'#305'labilece'#287'i gibi toplu halde de yap'#305'labilir' +
        '.'#13#10'Ancak do'#287'rulama i'#351'lemini toplu halde yapmak hem sunucular'#305'm'#305'z' +
        #305'n hem de istemci uygulaman'#305'n'#13#10'performans'#305'n'#305' art'#305'racak ve zamand' +
        'an b'#252'y'#252'k tasarruf sa'#287'layacakt'#305'r.'#13#10'Depolar do'#287'rulama sonucu oluml' +
        'u olmayan '#252'r'#252'nleri sat'#305'n almamal'#305'd'#305'rlar.'
    end
    object ItemMalAlim: TdxNavBarItem
      Tag = 1
      Caption = 'Mal Alim'
    end
    object ItemMalAlimIade: TdxNavBarItem
      Tag = 2
      Caption = 'Mal Al'#305'm '#304'ade'
    end
    object ItemSatis: TdxNavBarItem
      Tag = 3
      Caption = 'Sat'#305#351
    end
    object ItemSatisIptal: TdxNavBarItem
      Tag = 4
      Caption = 'Sat'#305#351' '#304'ptal'
    end
    object ItemDeAktivasyon: TdxNavBarItem
      Tag = 5
      Caption = 'DeAktivasyon'
    end
    object BarBildirimItem1: TdxNavBarItem
      Caption = 'BarBildirimItem1'
      Visible = False
    end
    object BarBildirimItem2: TdxNavBarItem
      Caption = 'BarBildirimItem2'
      Visible = False
    end
    object BarBildirimItem3: TdxNavBarItem
      Caption = 'ItemGecmis'
      Visible = False
    end
    object ItemGecmis: TdxNavBarItem
      Tag = 6
      Caption = 'Ge'#231'mi'#351
    end
    object ItemUretim: TdxNavBarItem
      Tag = 7
      Caption = #220'retim Bildirimi'
    end
  end
  object JvNavPanelHeader1: TJvNavPanelHeader
    Left = 0
    Top = 0
    Width = 1177
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ColorFrom = clBtnFace
    ColorTo = clSilver
    ImageIndex = 0
  end
  object Panel1: TPanel
    Left = 1359
    Top = 258
    Width = 217
    Height = 193
    TabOrder = 3
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 215
      Height = 74
      Align = alTop
      TabOrder = 0
      object cxLabel3: TcxLabel
        Left = 5
        Top = 5
        Caption = 'Fatura Tarih'
      end
      object DtpTarih1: TcxDateEdit
        Left = 5
        Top = 22
        Properties.ShowTime = False
        TabOrder = 1
        Width = 173
      end
      object DtpTarih2: TcxDateEdit
        Left = 5
        Top = 43
        Properties.ShowTime = False
        TabOrder = 2
        Width = 173
      end
      object BtnGetir: TcxButton
        Left = 182
        Top = 23
        Width = 75
        Height = 40
        Caption = 'Getir'
        TabOrder = 3
        OnClick = BtnGetirClick
      end
    end
    object Panel4: TPanel
      Left = 123
      Top = 116
      Width = 215
      Height = 117
      TabOrder = 1
      object GridFaturalar: TcxGrid
        Left = 88
        Top = 93
        Width = 261
        Height = 348
        TabOrder = 0
        object cxGridDBTableView2: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          OnCellDblClick = cxGridDBTableView2CellDblClick
          DataController.DataModeController.SmartRefresh = True
          DataController.KeyFieldNames = 'ID'
          DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object cxGridDBTableView2TARIH: TcxGridDBColumn
            DataBinding.FieldName = 'TARIH'
            Visible = False
            GroupIndex = 0
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
          end
          object cxGridDBTableView2STOKADI: TcxGridDBColumn
            DataBinding.FieldName = 'STOKADI'
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
          object cxGridDBTableView2ADET: TcxGridDBColumn
            DataBinding.FieldName = 'ADET'
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
          end
          object cxGridDBTableView2FIRMA: TcxGridDBColumn
            DataBinding.FieldName = 'FIRMA'
            Visible = False
            GroupIndex = 1
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
          end
        end
        object cxGridLevel8: TcxGridLevel
          GridView = cxGridDBTableView2
        end
      end
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 27
    Width = 281
    Height = 623
    Align = alLeft
    TabOrder = 4
    object BtnUretimBildirimi: TJvNavPanelButton
      Left = 1
      Top = 1
      Width = 279
      Height = 52
      Align = alTop
      Caption = #220'retim Bildirimi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 17
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitLeft = -4
      ExplicitTop = -5
      ExplicitWidth = 247
    end
    object BtnUrunListe: TJvNavPanelButton
      Tag = 10
      Left = 1
      Top = 469
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Gln Listeler'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 15
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitTop = 319
      ExplicitWidth = 256
    end
    object BtnSatinAlma: TJvNavPanelButton
      Tag = 1
      Left = 1
      Top = 53
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Sat'#305'nalma Bildirimi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 3
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitTop = 47
      ExplicitWidth = 247
    end
    object BtnPaketleme1: TJvNavPanelButton
      Tag = 9
      Left = 1
      Top = 157
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Bildirilmi'#351' Paketler'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 27
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitLeft = -7
      ExplicitTop = 99
      ExplicitWidth = 247
    end
    object BtnSatis: TJvNavPanelButton
      Tag = 3
      Left = 1
      Top = 209
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Sat'#305#351' Bildirimi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 7
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitLeft = -4
      ExplicitTop = 163
      ExplicitWidth = 247
    end
    object BtnDeAktivasyon: TJvNavPanelButton
      Tag = 4
      Left = 1
      Top = 261
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'DeAktivasyon Bildirimi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 6
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitLeft = -3
      ExplicitTop = 267
    end
    object BtnSatisIptal: TJvNavPanelButton
      Tag = 5
      Left = 1
      Top = 313
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Sat'#305#351' '#304'ptal / '#304'ade Bildirimi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 5
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitLeft = 17
      ExplicitTop = 163
      ExplicitWidth = 256
    end
    object BtnAlisIptal: TJvNavPanelButton
      Tag = 6
      Left = 1
      Top = 365
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Al'#305#351' '#304'ptal / '#304'ade Bildirimi'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 10
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitTop = 319
      ExplicitWidth = 256
    end
    object BtnHizliSatis: TJvNavPanelButton
      Tag = 7
      Left = 1
      Top = 417
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'H'#305'zl'#305' Paketleme'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 31
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitTop = 319
      ExplicitWidth = 256
    end
    object BtnPaketleme: TJvNavPanelButton
      Tag = 2
      Left = 1
      Top = 105
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Paket Olu'#351'tur'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 24
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitLeft = -3
      ExplicitTop = 99
    end
    object BtnListeler: TJvNavPanelButton
      Tag = 8
      Left = 1
      Top = 521
      Width = 279
      Height = 52
      Align = alTop
      Caption = 'Listeler'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 32
      Images = Tablo.PngMenu
      OnClick = BtnUretimBildirimiClick
      ExplicitLeft = -39
      ExplicitTop = 613
    end
  end
  object PcListeler: TcxPageControl
    Left = 281
    Top = 27
    Width = 896
    Height = 623
    Align = alClient
    TabOrder = 5
    Properties.ActivePage = TsPaketlemeListesi
    Properties.CustomButtons.Buttons = <>
    Properties.Rotate = True
    Properties.TabPosition = tpLeft
    OnPageChanging = PcListelerPageChanging
    ClientRectBottom = 619
    ClientRectLeft = 124
    ClientRectRight = 892
    ClientRectTop = 4
    object TsUretimListesi: TcxTabSheet
      Caption = 'TsUretimListesi'
      ImageIndex = 0
      object PnlUretimListesi: TPanel
        Left = 0
        Top = 0
        Width = 768
        Height = 615
        Align = alClient
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
        object ToolBar1: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 760
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 93
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
          HotImages = Tablo.PNGImageList1
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object YeniTusUretim: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni '#220'retim'
            ImageIndex = 7
            OnClick = YeniTusUretimClick
          end
          object ToolButton2: TToolButton
            Left = 93
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
        end
        object Panel6: TPanel
          Left = 1
          Top = 36
          Width = 766
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object DateUretimBaslangic: TDateTimePicker
            Left = 4
            Top = 11
            Width = 89
            Height = 24
            Date = 39613.025735856490000000
            Time = 39613.025735856490000000
            TabOrder = 0
            OnChange = DateUretimBaslangicChange
          end
          object DateUretimBitis: TDateTimePicker
            Left = 99
            Top = 11
            Width = 89
            Height = 24
            Date = 40887.025872754630000000
            Time = 40887.025872754630000000
            TabOrder = 1
            OnChange = DateUretimBitisChange
          end
        end
        object GridUretimListesi: TcxGrid
          Left = 1
          Top = 77
          Width = 766
          Height = 537
          Align = alClient
          TabOrder = 2
          OnContextPopup = GridUretimListesiContextPopup
          object TvUretimListesi: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = TvUretimListesiCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsUretimListesi
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object ColUretimListesiSec: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Visible = False
              Width = 24
            end
            object vUretimListesiColumn1: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Options.Moving = False
              Width = 54
            end
            object vUretimListesiColumn2: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'BELGENO'
              Options.Editing = False
              Options.Moving = False
              Width = 77
            end
            object vUretimListesiColumn3: TcxGridDBColumn
              Caption = 'Belge'
              DataBinding.FieldName = 'BELGE'
              Options.Editing = False
              Options.Moving = False
              Width = 61
            end
            object vUretimListesiColumn4: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              Options.Editing = False
              Options.Moving = False
              Width = 174
            end
            object vUretimListesiColumn5: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'STOKADI'
              Options.Editing = False
              Options.Moving = False
              Width = 142
            end
            object vUretimListesiColumn6: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'URETIMADET'
              Options.Editing = False
              Options.Moving = False
              Width = 42
            end
            object vUretimListesiColumn7: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderimde'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Value = 4
                end
                item
                  Description = 'Onayland'#305
                  ImageIndex = 11
                  Value = 9
                end>
              Options.Editing = False
            end
            object vUretimListesiColumn8: TcxGridDBColumn
              DataBinding.FieldName = 'BELGEDETAYID'
              Visible = False
            end
          end
          object GlUretimListesi: TcxGridLevel
            GridView = TvUretimListesi
          end
        end
      end
    end
    object TsSatinAlmaListesi: TcxTabSheet
      Tag = 1
      Caption = 'TsSatinAlmaListesi'
      ImageIndex = 1
      object PnlSatinAlma: TPanel
        Left = 0
        Top = 0
        Width = 768
        Height = 615
        Align = alClient
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
        object TbSatinAlma: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 760
          Margins.Bottom = 0
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
          HotImages = Tablo.PNGImageList1
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object ToolButton4: TToolButton
            Left = 0
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object YazdirTusSatinAlma: TToolButton
            Left = 8
            Top = 0
            Caption = 'Yazd'#305'r'
            ImageIndex = 16
          end
          object BildirTusSatinAlma: TToolButton
            Left = 76
            Top = 0
            Caption = 'Bildir'
            ImageIndex = 12
            Visible = False
            OnClick = BildirTusSatinAlmaClick
          end
          object ListeleTusSatinAlma: TToolButton
            Left = 144
            Top = 0
            Caption = 'Listele'
            ImageIndex = 21
            Visible = False
            OnClick = ListeleTusSatinAlmaClick
          end
        end
        object Panel8: TPanel
          Left = 1
          Top = 36
          Width = 766
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object DateSatinAlmaBaslangic: TDateTimePicker
            Left = 4
            Top = 11
            Width = 89
            Height = 24
            Date = 39613.025735856490000000
            Time = 39613.025735856490000000
            TabOrder = 0
            OnChange = DateSatinAlmaBaslangicChange
          end
          object DateSatinAlmaBitis: TDateTimePicker
            Left = 99
            Top = 11
            Width = 89
            Height = 24
            Date = 40887.025872754630000000
            Time = 40887.025872754630000000
            TabOrder = 1
            OnChange = DateSatinAlmaBitisChange
          end
        end
        object GridAlim: TcxGrid
          Left = 1
          Top = 77
          Width = 766
          Height = 537
          Align = alClient
          PopupMenu = PopSAtinAlmaDogruBildirim
          TabOrder = 2
          OnContextPopup = GridUretimListesiContextPopup
          object TvAlim: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = TvAlimCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsSatinAlmaListesi
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn25: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Options.Moving = False
              Width = 54
            end
            object cxGridDBColumn26: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'BELGENO'
              Options.Editing = False
              Options.Moving = False
              Width = 77
            end
            object cxGridDBColumn27: TcxGridDBColumn
              Caption = 'Belge'
              DataBinding.FieldName = 'BELGETIPI'
              Options.Editing = False
              Options.Moving = False
              Width = 61
            end
            object cxGridDBColumn30: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              Options.Editing = False
              Options.Moving = False
              Width = 174
            end
            object cxGridDBColumn31: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'STOKADI'
              Options.Editing = False
              Options.Moving = False
              Width = 142
            end
            object cxGridDBColumn32: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              Options.Editing = False
              Options.Moving = False
              Width = 42
            end
            object cxGridDBColumn33: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderiliyor'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Value = 4
                end
                item
                  Description = 'Tamamland'#305
                  ImageIndex = 11
                  Value = 9
                end>
              Options.Editing = False
            end
          end
          object GlAlim: TcxGridLevel
            GridView = TvAlim
          end
        end
      end
    end
    object TsPaketlemeListesi: TcxTabSheet
      Tag = 2
      Caption = 'TsPaketlemeListesi'
      ImageIndex = 2
      object PnlPaketlemeListesi: TPanel
        Left = 0
        Top = 0
        Width = 768
        Height = 615
        Align = alClient
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
        object ToolBar2: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 760
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 111
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
          HotImages = Tablo.PNGImageList1
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object YeniTusPaketleme: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 7
            OnClick = YeniTusPaketlemeClick
          end
          object SilTusPaketleme: TToolButton
            Left = 111
            Top = 0
            Caption = 'Sil'
            ImageIndex = 8
            OnClick = SilTusPaketlemeClick
          end
          object ToolButton5: TToolButton
            Left = 222
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object YaziciYazPaketleme: TToolButton
            Left = 230
            Top = 0
            Caption = 'Karekod Yazd'#305'r'
            ImageIndex = 16
            Visible = False
          end
          object BildirTusPaketleme: TToolButton
            Left = 341
            Top = 0
            Caption = 'Bildir'
            ImageIndex = 12
            Visible = False
          end
          object ListeleTusPaketleme: TToolButton
            Left = 452
            Top = 0
            Caption = 'Listele'
            ImageIndex = 21
            Visible = False
            OnClick = ListeleTusPaketlemeClick
          end
        end
        object Panel9: TPanel
          Left = 1
          Top = 36
          Width = 766
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object DatePaketlemeBaslangic: TDateTimePicker
            Left = 4
            Top = 11
            Width = 89
            Height = 24
            Date = 39613.025735856490000000
            Time = 39613.025735856490000000
            TabOrder = 0
            OnChange = DatePaketlemeBaslangicChange
          end
          object DatePaketlemeBitis: TDateTimePicker
            Left = 99
            Top = 11
            Width = 89
            Height = 24
            Date = 40887.025872754630000000
            Time = 40887.025872754630000000
            TabOrder = 1
            OnChange = DatePaketlemeBitisChange
          end
        end
        object GridPaketleme: TcxGrid
          Left = 1
          Top = 77
          Width = 766
          Height = 537
          Align = alClient
          PopupMenu = PopPaketleme
          TabOrder = 2
          OnContextPopup = GridUretimListesiContextPopup
          object DbTvPaketleme: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = DbTvPaketlemeCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsPaketlemeListesi
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn34: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Visible = False
              Width = 24
            end
            object cxGridDBColumn42: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Options.Moving = False
              Width = 54
            end
            object cxGridDBColumn43: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'BELGENO'
              Options.Editing = False
              Options.Moving = False
              Width = 77
            end
            object cxGridDBColumn44: TcxGridDBColumn
              Caption = 'Belge'
              DataBinding.FieldName = 'BELGE'
              Options.Editing = False
              Options.Moving = False
              Width = 61
            end
            object cxGridDBColumn45: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              Options.Editing = False
              Options.Moving = False
              Width = 174
            end
            object cxGridDBColumn47: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'URETIMADET'
              Options.Editing = False
              Options.Moving = False
              Width = 42
            end
            object cxGridDBColumn48: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderiliyor'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Value = 4
                end
                item
                  Description = 'Tamamland'#305
                  ImageIndex = 11
                  Value = 9
                end>
              Options.Editing = False
            end
          end
          object GlPaketleme: TcxGridLevel
            GridView = DbTvPaketleme
          end
        end
      end
    end
    object TsSatisListesi: TcxTabSheet
      Tag = 3
      Caption = 'TsSatisListesi'
      ImageIndex = 3
      object PnlSatis: TPanel
        Left = 0
        Top = 0
        Width = 768
        Height = 615
        Align = alClient
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 760
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 67
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
          HotImages = Tablo.PNGImageList1
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object ToolButton1: TToolButton
            Left = 0
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object BtnSatisYazdir: TToolButton
            Left = 8
            Top = 0
            Caption = 'Yazd'#305'r'
            ImageIndex = 16
          end
          object BtnSatisBildir: TToolButton
            Left = 75
            Top = 0
            Caption = 'Bildir'
            ImageIndex = 12
            Visible = False
          end
        end
        object Panel10: TPanel
          Left = 1
          Top = 36
          Width = 766
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object DateSatisBaslangic: TDateTimePicker
            Left = 4
            Top = 11
            Width = 89
            Height = 24
            Date = 40878.025735856490000000
            Time = 40878.025735856490000000
            TabOrder = 0
            OnChange = DateSatisBaslangicChange
          end
          object DateSatisBitis: TDateTimePicker
            Left = 99
            Top = 11
            Width = 89
            Height = 24
            Date = 40887.025872754630000000
            Time = 40887.025872754630000000
            TabOrder = 1
            OnChange = DateSatisBitisChange
          end
        end
        object GridSatisListesi: TcxGrid
          Left = 1
          Top = 77
          Width = 766
          Height = 537
          Align = alClient
          PopupMenu = PopSatisDogruBildirim
          TabOrder = 2
          OnContextPopup = GridUretimListesiContextPopup
          object TvSatisListesi: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = TvSatisListesiCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsSatisListesi
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn49: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Visible = False
              Width = 24
            end
            object cxGridDBColumn50: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Options.Moving = False
              Width = 54
            end
            object cxGridDBColumn51: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'FATURANO'
              Options.Editing = False
              Options.Moving = False
              Width = 50
            end
            object cxGridDBColumn52: TcxGridDBColumn
              Caption = 'Belge'
              DataBinding.FieldName = 'BELGETIPI'
              Options.Editing = False
              Options.Moving = False
              Width = 61
            end
            object cxGridDBColumn53: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              Options.Editing = False
              Options.Moving = False
              Width = 174
            end
            object cxGridDBColumn54: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'STOKADI'
              Options.Editing = False
              Options.Moving = False
              Width = 70
            end
            object cxGridDBColumn55: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              Options.Editing = False
              Options.Moving = False
              Width = 42
            end
            object cxGridDBColumn56: TcxGridDBColumn
              Caption = 'Satis Durum'
              DataBinding.FieldName = 'SATISDURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderimde'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Value = 4
                end
                item
                  Description = 'Tamamland'#305
                  ImageIndex = 11
                  Value = 9
                end>
              Options.Editing = False
            end
            object vSatisListesiColumn1: TcxGridDBColumn
              Caption = 'Paket Durum'
              DataBinding.FieldName = 'PAKETDURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderimde'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Description = 'Tamamland'#305
                  ImageIndex = 11
                  Value = 9
                end>
            end
          end
          object GlSatisListesi: TcxGridLevel
            GridView = TvSatisListesi
          end
        end
      end
    end
    object TsDeAktivasyonListesi: TcxTabSheet
      Tag = 4
      Caption = 'TsDeAktivasyonListesi'
      ImageIndex = 4
      object Panel7: TPanel
        Left = 0
        Top = 0
        Width = 768
        Height = 615
        Align = alClient
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
        object ToolBar4: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 760
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 67
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
          HotImages = Tablo.PNGImageList1
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object ToolButton3: TToolButton
            Left = 0
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object ToolButton6: TToolButton
            Left = 8
            Top = 0
            Caption = 'Yazd'#305'r'
            ImageIndex = 16
          end
          object ToolButton7: TToolButton
            Left = 75
            Top = 0
            Caption = 'Bildir'
            ImageIndex = 12
            Visible = False
          end
        end
        object Panel11: TPanel
          Left = 1
          Top = 36
          Width = 766
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object DateDeAktivasyonBaslangic: TDateTimePicker
            Left = 4
            Top = 11
            Width = 89
            Height = 24
            Date = 39613.025735856490000000
            Time = 39613.025735856490000000
            TabOrder = 0
            OnChange = DateDeAktivasyonBaslangicChange
          end
          object DateDeAktivasyonBitis: TDateTimePicker
            Left = 99
            Top = 11
            Width = 89
            Height = 24
            Date = 40887.025872754630000000
            Time = 40887.025872754630000000
            TabOrder = 1
            OnChange = DateSatisBitisChange
          end
        end
        object GridDeAktivasyonGetir: TcxGrid
          Left = 1
          Top = 77
          Width = 766
          Height = 537
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 2
          OnContextPopup = GridUretimListesiContextPopup
          object TvDeAktivasyonGetir: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = TvDeAktivasyonGetirCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsDeAktivasyon
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn57: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Visible = False
              Width = 24
            end
            object cxGridDBColumn58: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Options.Moving = False
              Width = 54
            end
            object cxGridDBColumn59: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'FATURANO'
              Options.Editing = False
              Options.Moving = False
              Width = 77
            end
            object cxGridDBColumn60: TcxGridDBColumn
              Caption = 'Belge'
              DataBinding.FieldName = 'BELGETIPI'
              Options.Editing = False
              Options.Moving = False
              Width = 61
            end
            object cxGridDBColumn61: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              Options.Editing = False
              Options.Moving = False
              Width = 174
            end
            object cxGridDBColumn62: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'STOKADI'
              Options.Editing = False
              Options.Moving = False
              Width = 142
            end
            object cxGridDBColumn63: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              Options.Editing = False
              Options.Moving = False
              Width = 42
            end
            object cxGridDBColumn64: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DEAKTIVASYONDURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderiliyor'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Value = 4
                end
                item
                  Description = 'Tamamland'#305
                  ImageIndex = 11
                  Value = 9
                end>
              Options.Editing = False
            end
          end
          object GlDeAktivasyon: TcxGridLevel
            GridView = TvDeAktivasyonGetir
          end
        end
      end
    end
    object TsSatisIptalListesi: TcxTabSheet
      Tag = 5
      Caption = 'TsSatisIptal'
      ImageIndex = 5
      object Panel12: TPanel
        Left = 0
        Top = 0
        Width = 768
        Height = 615
        Align = alClient
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 760
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 67
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
          HotImages = Tablo.PNGImageList1
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object ToolButton8: TToolButton
            Left = 0
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object ToolButton9: TToolButton
            Left = 8
            Top = 0
            Caption = 'Yazd'#305'r'
            ImageIndex = 16
          end
          object BtnBildir: TToolButton
            Left = 75
            Top = 0
            Caption = 'Bildir'
            ImageIndex = 12
            Visible = False
          end
        end
        object Panel13: TPanel
          Left = 1
          Top = 36
          Width = 766
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object DateSatisIptalBaslangic: TDateTimePicker
            Left = 4
            Top = 11
            Width = 89
            Height = 24
            Date = 39613.025735856490000000
            Time = 39613.025735856490000000
            TabOrder = 0
            OnChange = DateSatisIptalBaslangicChange
          end
          object DateSatisIptalBitis: TDateTimePicker
            Left = 99
            Top = 11
            Width = 89
            Height = 24
            Date = 40887.025872754630000000
            Time = 40887.025872754630000000
            TabOrder = 1
            OnChange = DateSatisIptalBitisChange
          end
        end
        object GridSatisIptal: TcxGrid
          Left = 1
          Top = 77
          Width = 766
          Height = 537
          Align = alClient
          PopupMenu = PopSatisIptalDogruBildirim
          TabOrder = 2
          OnContextPopup = GridUretimListesiContextPopup
          object ViewSatisIptal: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = ViewSatisIptalCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsSatisIptalListesi
            DataController.KeyFieldNames = 'BELGEDETAYID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn66: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Options.Moving = False
              Width = 54
            end
            object cxGridDBColumn67: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'BELGENO'
              Options.Editing = False
              Options.Moving = False
              Width = 77
            end
            object cxGridDBColumn68: TcxGridDBColumn
              Caption = 'Belge'
              DataBinding.FieldName = 'BELGETIPI'
              Options.Editing = False
              Options.Moving = False
              Width = 61
            end
            object cxGridDBColumn69: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              Options.Editing = False
              Options.Moving = False
              Width = 174
            end
            object cxGridDBColumn70: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'STOKADI'
              Options.Editing = False
              Options.Moving = False
              Width = 142
            end
            object cxGridDBColumn71: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              Options.Editing = False
              Options.Moving = False
              Width = 42
            end
            object cxGridDBColumn72: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderiliyor'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Value = 4
                end
                item
                  Description = 'Tamamland'#305
                  ImageIndex = 11
                  Value = 9
                end>
              Options.Editing = False
            end
          end
          object LvlSatisIptal: TcxGridLevel
            GridView = ViewSatisIptal
          end
        end
      end
    end
    object TsAlimIptalListesi: TcxTabSheet
      Tag = 6
      Caption = 'TsAlimIptalListesi'
      ImageIndex = 6
      object Panel14: TPanel
        Left = 0
        Top = 0
        Width = 768
        Height = 615
        Align = alClient
        Color = 11776947
        ParentBackground = False
        TabOrder = 0
        object ToolBar6: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 760
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 67
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
          HotImages = Tablo.PNGImageList1
          HotTrackColor = 65408
          Images = Tablo.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
          object ToolButton11: TToolButton
            Left = 0
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 10
            Style = tbsSeparator
          end
          object ToolButton12: TToolButton
            Left = 8
            Top = 0
            Caption = 'Yazd'#305'r'
            ImageIndex = 16
          end
          object ToolButton13: TToolButton
            Left = 75
            Top = 0
            Caption = 'Bildir'
            ImageIndex = 12
            Visible = False
          end
        end
        object Panel15: TPanel
          Left = 1
          Top = 36
          Width = 766
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          Color = 11776947
          ParentBackground = False
          TabOrder = 1
          object DateAlimIptalBaslangic: TDateTimePicker
            Left = 4
            Top = 11
            Width = 89
            Height = 24
            Date = 39613.025735856490000000
            Time = 39613.025735856490000000
            TabOrder = 0
          end
          object DateAlimIptalBitis: TDateTimePicker
            Left = 99
            Top = 11
            Width = 89
            Height = 24
            Date = 40887.025872754630000000
            Time = 40887.025872754630000000
            TabOrder = 1
            OnChange = DateSatisBitisChange
          end
        end
        object cxGrid4: TcxGrid
          Left = 1
          Top = 77
          Width = 766
          Height = 537
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 2
          OnContextPopup = GridUretimListesiContextPopup
          object cxGridDBTableView5: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = TvDeAktivasyonGetirCellDblClick
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsSatisListesi
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn73: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Visible = False
              Width = 24
            end
            object cxGridDBColumn74: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              Options.Editing = False
              Options.Moving = False
              Width = 54
            end
            object cxGridDBColumn75: TcxGridDBColumn
              Caption = 'Belge No'
              DataBinding.FieldName = 'BELGENO'
              Options.Editing = False
              Options.Moving = False
              Width = 77
            end
            object cxGridDBColumn76: TcxGridDBColumn
              Caption = 'Belge'
              DataBinding.FieldName = 'BELGETIPI'
              Options.Editing = False
              Options.Moving = False
              Width = 61
            end
            object cxGridDBColumn77: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'FIRMA'
              Options.Editing = False
              Options.Moving = False
              Width = 174
            end
            object cxGridDBColumn78: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'STOKADI'
              Options.Editing = False
              Options.Moving = False
              Width = 142
            end
            object cxGridDBColumn79: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              Options.Editing = False
              Options.Moving = False
              Width = 42
            end
            object cxGridDBColumn80: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList1
              Properties.Items = <
                item
                  Description = 'Yeni'
                  ImageIndex = 7
                  Value = 1
                end
                item
                  Description = 'G'#246'nderiliyor'
                  ImageIndex = 1
                  Value = 2
                end
                item
                  Description = 'Hatal'#305
                  ImageIndex = 31
                  Value = 3
                end
                item
                  Value = 4
                end
                item
                  Description = 'Tamamland'#305
                  ImageIndex = 11
                  Value = 9
                end>
              Options.Editing = False
            end
          end
          object cxGridLevel10: TcxGridLevel
            GridView = cxGridDBTableView5
          end
        end
      end
    end
    object TsBosListe: TcxTabSheet
      Tag = 7
      Caption = 'TsBosListe'
      ImageIndex = 7
      object Label4: TLabel
        Left = 76
        Top = 73
        Width = 462
        Height = 22
        Caption = 
          'Sol taraftaki gezinme panelini kullanarak i'#351'lemleri ger'#231'ekle'#351'tir' +
          'in.'
        Font.Charset = TURKISH_CHARSET
        Font.Color = 16744448
        Font.Height = -16
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Shape1: TShape
        Left = 23
        Top = 66
        Width = 379
        Height = 1
      end
      object Label3: TLabel
        Left = 45
        Top = 18
        Width = 40
        Height = 16
        Caption = 'GenoTIP'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsItalic]
        ParentFont = False
        Transparent = True
      end
      object Label2: TLabel
        Left = 42
        Top = 33
        Width = 105
        Height = 29
        Caption = 'ENTEGRA'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 618
    Top = 122
    object pmHepsiSec: TMenuItem
      Tag = 1
      Caption = 'Hepsini Se'#231
      OnClick = pmHepsiSecClick
    end
    object pmTumunuKaldir: TMenuItem
      Tag = 2
      Caption = 'T'#252'm'#252'n'#252' Kald'#305'r'
      OnClick = pmHepsiSecClick
    end
    object pmSecimiTersCevir: TMenuItem
      Tag = 3
      Caption = 'Se'#231'imi Ters '#199'evir'
      OnClick = pmHepsiSecClick
    end
  end
  object TabUretimListesi: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        ' SELECT IU.*,RI.ANAHTAR AS BELGE,R.FIRMA,S.STOKADI,B.BARKOD,IB.D' +
        'URUM,IU.DEPOID  '
      #9'FROM ITS_URETIM IU'
      
        ' '#9#9'INNER JOIN REHBERINI RI ON RI.BOLUM = '#39'Kasa T'#252'rleri'#39' AND RI.D' +
        'EGER=IU.BELGETURU '
      ' '#9#9'INNER JOIN REHBER R ON R.ID = IU.REHBERID  '
      ' '#9#9'INNER JOIN STOKLAR S ON S.ID = IU.URUNID   '
      '        INNER JOIN STOKBARKOD B ON B.ID = IU.BARKODID  '
      
        '        INNER JOIN ITS_BILDIRIM IB ON IB.YERI=1 AND IB.YERID=IU.' +
        'ID')
    Left = 1067
    Top = 96
    object TabUretimListesiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabUretimListesiTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabUretimListesiBELGENO: TStringField
      FieldName = 'BELGENO'
      Size = 50
    end
    object TabUretimListesiBELGEBASID: TIntegerField
      FieldName = 'BELGEBASID'
    end
    object TabUretimListesiBELGEDETAYID: TIntegerField
      FieldName = 'BELGEDETAYID'
    end
    object TabUretimListesiBELGETURU: TIntegerField
      FieldName = 'BELGETURU'
    end
    object TabUretimListesiURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabUretimListesiREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabUretimListesiURETIMADET: TIntegerField
      FieldName = 'URETIMADET'
    end
    object TabUretimListesiBELGE: TWideStringField
      FieldName = 'BELGE'
      Size = 40
    end
    object TabUretimListesiFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabUretimListesiSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabUretimListesiBARKODID: TIntegerField
      FieldName = 'BARKODID'
    end
    object TabUretimListesiBARKOD: TWideStringField
      FieldName = 'BARKOD'
      Size = 50
    end
    object TabUretimListesiDURUM: TIntegerField
      FieldName = 'DURUM'
    end
    object TabUretimListesiDEPOID: TIntegerField
      FieldName = 'DEPOID'
    end
  end
  object DtsUretimListesi: TDataSource
    DataSet = TabUretimListesi
    OnStateChange = DtsUretimListesiStateChange
    Left = 950
    Top = 72
  end
  object TabSatinAlmaListesi: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT F.ID AS BELGEDETAYID ,FB.TARIH,FB.FATURANO AS BELGENO,F.I' +
        'D AS BELGEDETAYID,FB.ID AS BELGEBASID,FB.REHBERID,R.FIRMA,RI.ANA' +
        'HTAR AS BELGETIPI,F.AD AS STOKADI,F.ADET,FB.TUR,F.URUNID,B.BARKO' +
        'D,B.ID AS BARKODID '
      
        '                          ,ISNULL(IB.DURUM,1) AS DURUM  FROM  FA' +
        'TBASLIK FB  '
      
        ' '#9#9#9'                      INNER JOIN FATURA F ON F.FATBASID=FB.I' +
        'D AND F.IZLEME = 3 '
      
        '                            INNER JOIN REHBER R ON R.ID = F.REHB' +
        'ERID           '
      
        '                            LEFT OUTER JOIN ITS_BILDIRIM IB ON I' +
        'B.YERI = 3 AND IB.YERID = FB.ID '
      
        '                            INNER JOIN REHBERINI RI ON RI.BOLUM ' +
        '= '#39'Kasa T'#252'rleri'#39' AND RI.DEGER=FB.TUR '
      
        '                            INNER JOIN STOKBARKOD B ON B.STOKID ' +
        '= F.URUNID AND B.VARSAYILAN=1           '
      '                            WHERE (FB.TUR = 10 OR FB.TUR = 11) ')
    Left = 1107
    Top = 200
    object TabSatinAlmaListesiTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabSatinAlmaListesiBELGENO: TWideStringField
      FieldName = 'BELGENO'
      Size = 10
    end
    object TabSatinAlmaListesiBELGEDETAYID: TAutoIncField
      FieldName = 'BELGEDETAYID'
      ReadOnly = True
    end
    object TabSatinAlmaListesiBELGEBASID: TAutoIncField
      FieldName = 'BELGEBASID'
      ReadOnly = True
    end
    object TabSatinAlmaListesiREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabSatinAlmaListesiFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabSatinAlmaListesiBELGETIPI: TWideStringField
      FieldName = 'BELGETIPI'
      Size = 40
    end
    object TabSatinAlmaListesiSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabSatinAlmaListesiADET: TFloatField
      FieldName = 'ADET'
    end
    object TabSatinAlmaListesiTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabSatinAlmaListesiURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabSatinAlmaListesiBARKOD: TWideStringField
      FieldName = 'BARKOD'
      Size = 50
    end
    object TabSatinAlmaListesiBARKODID: TAutoIncField
      FieldName = 'BARKODID'
      ReadOnly = True
    end
    object TabSatinAlmaListesiDURUM: TIntegerField
      FieldName = 'DURUM'
      ReadOnly = True
    end
  end
  object DtsSatinAlmaListesi: TDataSource
    DataSet = TabSatinAlmaListesi
    Left = 958
    Top = 184
  end
  object TabPaketlemeListesi: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT IU.*,RI.ANAHTAR AS BELGE,R.FIRMA,ISNULL(IB.DURUM,1) AS DU' +
        'RUM  FROM ITS_PAKET IU '
      
        '                          INNER JOIN REHBERINI RI ON RI.BOLUM = ' +
        #39'Kasa T'#252'rleri'#39' AND RI.DEGER=IU.BELGETURU '
      
        '                          INNER JOIN REHBER R ON R.ID = IU.REHBE' +
        'RID  '
      
        '                          LEFT OUTER JOIN ITS_BILDIRIM IB ON IB.' +
        'YERI=2 AND IB.YERID=IU.FATBASID ')
    Left = 1083
    Top = 144
    object TabPaketlemeListesiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabPaketlemeListesiTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabPaketlemeListesiBELGENO: TStringField
      FieldName = 'BELGENO'
      Size = 50
    end
    object TabPaketlemeListesiBELGETURU: TIntegerField
      FieldName = 'BELGETURU'
    end
    object TabPaketlemeListesiREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabPaketlemeListesiURETIMADET: TIntegerField
      FieldName = 'URETIMADET'
    end
    object TabPaketlemeListesiTRANSFERID: TLargeintField
      FieldName = 'TRANSFERID'
    end
    object TabPaketlemeListesiSIPARISID: TIntegerField
      FieldName = 'SIPARISID'
    end
    object TabPaketlemeListesiSIPARISDETAYID: TIntegerField
      FieldName = 'SIPARISDETAYID'
    end
    object TabPaketlemeListesiFATBASID: TIntegerField
      FieldName = 'FATBASID'
    end
    object TabPaketlemeListesiDEPOID: TIntegerField
      FieldName = 'DEPOID'
    end
    object TabPaketlemeListesiBELGE: TWideStringField
      FieldName = 'BELGE'
      Size = 40
    end
    object TabPaketlemeListesiFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabPaketlemeListesiDURUM: TIntegerField
      FieldName = 'DURUM'
      ReadOnly = True
    end
  end
  object DtsPaketlemeListesi: TDataSource
    DataSet = TabPaketlemeListesi
    Left = 958
    Top = 144
  end
  object TabSatisListesi: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'TARIH1'
        Size = -1
        Value = Null
      end
      item
        Name = 'TARIH2'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT * FROM (SELECT FB.ID,FB.TARIH,FB.FATURANO,RI.ANAHTAR AS B' +
        'ELGETIPI,R.FIRMA, ISNULL(IB.DURUM,1) AS SATISDURUM,R.ID AS REHBE' +
        'RID'
      
        ',(SELECT SUM(MIKTAR) FROM FATURA F INNER JOIN STOKLAR S ON F.URU' +
        'NID=S.ID AND S.IZLEME=3 '
      
        'WHERE F.FATBASID=FB.ID) AS ADET , (SELECT TOP 1 ISNULL(IB2.DURUM' +
        ',1) FROM ITS_BILDIRIM IB2'
      ' WHERE IB2.YERI = 2 AND IB2.YERID = FB.ID ORDER BY TARIH DESC)'
      ' AS PAKETDURUM'
      'FROM FATBASLIK FB '
      ' INNER JOIN REHBER R ON R.ID = FB.REHBERID           '
      
        ' LEFT OUTER JOIN ITS_BILDIRIM IB ON IB.YERI = 3 AND IB.YERID = F' +
        'B.ID'
      
        ' INNER JOIN REHBERINI RI ON RI.BOLUM = '#39'Kasa T'#252'rleri'#39' AND RI.DEG' +
        'ER=FB.TUR     '
      
        'WHERE (FB.TUR = 14 OR FB.TUR = 15) AND CONVERT(DATE,FB.TARIH,112' +
        ') BETWEEN :TARIH1  AND :TARIH2 '
      ' ) AS DD'
      'WHERE ISNULL(DD.ADET,0)<>0'
      'ORDER BY FATURANO DESC')
    Left = 1107
    Top = 248
    object TabSatisListesiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabSatisListesiTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabSatisListesiFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabSatisListesiBELGETIPI: TWideStringField
      FieldName = 'BELGETIPI'
      Size = 40
    end
    object TabSatisListesiFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabSatisListesiADET: TFloatField
      FieldName = 'ADET'
      ReadOnly = True
    end
    object TabSatisListesiREHBERID: TAutoIncField
      FieldName = 'REHBERID'
      ReadOnly = True
    end
    object TabSatisListesiSATISDURUM: TIntegerField
      FieldName = 'SATISDURUM'
      ReadOnly = True
    end
    object TabSatisListesiPAKETDURUM: TIntegerField
      FieldName = 'PAKETDURUM'
      ReadOnly = True
    end
  end
  object DtsSatisListesi: TDataSource
    DataSet = TabSatisListesi
    Left = 966
    Top = 240
  end
  object HTTPRIO1: THTTPRIO
    HTTPWebNode.UserName = 'genyazilim001'
    HTTPWebNode.Password = 'genyazilim001'
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    HTTPWebNode.OnBeforePost = HTTPRIO1HTTPWebNode1BeforePost
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 608
    Top = 48
  end
  object HTTPReqResp1: THTTPReqResp
    UserName = 'genyazilim001'
    Password = 'genyazilim001'
    UseUTF8InHeader = True
    InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    WebNodeOptions = []
    Left = 688
    Top = 56
  end
  object TabDeAktivasyon: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'TARIH1'
        Size = -1
        Value = Null
      end
      item
        Name = 'TARIH2'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT * FROM (SELECT FB.ID,FB.TARIH as FATURATARIH,FB.FATURANO,' +
        'RI.ANAHTAR AS BELGETIPI,R.FIRMA, ISNULL(IB.DURUM,1) AS DEAKTIVAS' +
        'YONDURUM,R.ID AS REHBERID'
      
        ',(SELECT SUM(MIKTAR) FROM FATURA F INNER JOIN STOKLAR S ON F.URU' +
        'NID=S.ID AND S.IZLEME=3 '
      
        'WHERE F.FATBASID=FB.ID) AS ADET , (SELECT TOP 1 ISNULL(IB2.DURUM' +
        ',1) FROM ITS_BILDIRIM IB2'
      ' WHERE IB2.YERI = 2 AND IB2.YERID = FB.ID ORDER BY TARIH DESC)'
      ' AS PAKETDURUM'
      'FROM FATBASLIK FB '
      ' INNER JOIN REHBER R ON R.ID = FB.REHBERID           '
      
        ' LEFT OUTER JOIN ITS_BILDIRIM IB ON IB.YERI = 5 AND IB.YERID = F' +
        'B.ID'
      
        ' INNER JOIN REHBERINI RI ON RI.BOLUM = '#39'Kasa T'#252'rleri'#39' AND RI.DEG' +
        'ER=FB.TUR     '
      
        'WHERE (FB.TUR = 14 OR FB.TUR = 15) AND CONVERT(DATE,FB.TARIH,112' +
        ') BETWEEN :TARIH1  AND :TARIH2 '
      ' ) AS DD'
      'WHERE ISNULL(DD.ADET,0)<>0'
      'ORDER BY FATURANO DESC')
    Left = 1107
    Top = 296
  end
  object DtsDeAktivasyon: TDataSource
    DataSet = TabDeAktivasyon
    Left = 958
    Top = 296
  end
  object TabSatisIptalListesi: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT F.ID AS BELGEDETAYID,FB.TARIH,FB.FATURANO AS BELGENO,FB.I' +
        'D AS BELGEBASID,'
      
        'FB.REHBERID,R.FIRMA,RI.ANAHTAR AS BELGETIPI,S.STOKADI,F.ADET,FB.' +
        'TUR,F.URUNID,B.BARKOD,B.ID AS BARKODID '
      '                            ,ISNULL(IB.DURUM,1) AS DURUM '
      '                        '
      '                            FROM  FATBASLIK FB  '
      
        ' '#9#9#9'                INNER JOIN FATURA F ON F.FATBASID=FB.ID AND ' +
        'F.IZLEME = 3 '
      
        '                            INNER JOIN REHBER R ON R.ID = F.REHB' +
        'ERID           '
      
        '                            LEFT OUTER JOIN ITS_BILDIRIM IB ON I' +
        'B.YERI = 3 AND IB.YERID = FB.ID '
      
        '                            INNER JOIN REHBERINI RI ON RI.BOLUM ' +
        '= '#39'Kasa T'#252'rleri'#39' AND RI.DEGER=FB.TUR '
      
        '                            INNER JOIN STOKBARKOD B ON B.STOKID ' +
        '= F.URUNID AND B.VARSAYILAN=1           '
      
        '                            INNER JOIN STOKLAR S ON S.ID = F.URU' +
        'NID '
      
        '                            WHERE (FB.TUR = 11 OR FB.TUR = 12) A' +
        'ND R.GRUP =320')
    Left = 1107
    Top = 368
    object TabSatisIptalListesiBELGEDETAYID: TAutoIncField
      FieldName = 'BELGEDETAYID'
      ReadOnly = True
    end
    object TabSatisIptalListesiTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabSatisIptalListesiBELGENO: TWideStringField
      FieldName = 'BELGENO'
      Size = 10
    end
    object TabSatisIptalListesiBELGEBASID: TAutoIncField
      FieldName = 'BELGEBASID'
      ReadOnly = True
    end
    object TabSatisIptalListesiREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabSatisIptalListesiFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabSatisIptalListesiBELGETIPI: TWideStringField
      FieldName = 'BELGETIPI'
      Size = 40
    end
    object TabSatisIptalListesiSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabSatisIptalListesiADET: TFloatField
      FieldName = 'ADET'
    end
    object TabSatisIptalListesiTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabSatisIptalListesiURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabSatisIptalListesiBARKOD: TWideStringField
      FieldName = 'BARKOD'
      Size = 50
    end
    object TabSatisIptalListesiBARKODID: TAutoIncField
      FieldName = 'BARKODID'
      ReadOnly = True
    end
    object TabSatisIptalListesiDURUM: TIntegerField
      FieldName = 'DURUM'
      ReadOnly = True
    end
  end
  object DtsSatisIptalListesi: TDataSource
    DataSet = TabSatisIptalListesi
    Left = 990
    Top = 368
  end
  object PaketTimer: TTimer
    OnTimer = PaketTimerTimer
    Left = 864
    Top = 72
  end
  object ListeleriGuncelleTimer: TTimer
    Interval = 5000
    OnTimer = ListeleriGuncelleTimerTimer
    Left = 864
    Top = 168
  end
  object PopSatisIptalDogruBildirim: TPopupMenu
    Left = 778
    Top = 218
    object DoruBildirimeevir1: TMenuItem
      Caption = 'Do'#287'ru Bildirime '#199'evir'
      OnClick = DoruBildirimeevir1Click
    end
  end
  object PopSAtinAlmaDogruBildirim: TPopupMenu
    Left = 778
    Top = 274
    object DogruBildirimCevir: TMenuItem
      Caption = 'Do'#287'ru Bildirime '#199'evir'
      OnClick = DogruBildirimCevirClick
    end
  end
  object PopSatisDogruBildirim: TPopupMenu
    Left = 778
    Top = 162
    object DogruBildirim: TMenuItem
      Caption = 'Do'#287'ru Bildirime '#199'evir'
      OnClick = DogruBildirimClick
    end
  end
  object PopPaketleme: TPopupMenu
    Left = 778
    Top = 338
    object PaketDogruBildirim: TMenuItem
      Caption = 'Do'#287'ru Bildirime '#199'evir'
      OnClick = PaketDogruBildirimClick
    end
  end
end
