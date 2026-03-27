object ITSEzcaDepoDlg: TITSEzcaDepoDlg
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #304'ts '#304#351'lemleri '
  ClientHeight = 513
  ClientWidth = 1284
  Color = clBtnFace
  DefaultMonitor = dmMainForm
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
    Left = 481
    Top = 27
    Width = 803
    Height = 486
    Align = alClient
    TabOrder = 0
    object PnlAra: TPanel
      Left = 1
      Top = 36
      Width = 801
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
        Top = 4
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
      Width = 801
      Height = 404
      ActivePage = TsGecmis
      Align = alClient
      ParentShowHint = False
      ShowHint = False
      Style = 8
      TabOrder = 1
      OnContextPopup = PcBildirimContextPopup
      ClientRectBottom = 404
      ClientRectRight = 801
      ClientRectTop = 24
      object TsDogrulamaBildirim: TcxTabSheet
        Caption = 'Do'#287'rulama Bildirim'
        ImageIndex = 0
        object GridDogrulaBildirim: TcxGrid
          Left = 0
          Top = 0
          Width = 801
          Height = 380
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvDogrulamabildirim: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsDogrulama
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
          Width = 801
          Height = 380
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvMalAlimListe: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsMalAlim
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
          Width = 801
          Height = 380
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvMalIade: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsMalIade
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
          Width = 801
          Height = 380
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvSatis: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsSatis
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
      object TsSatisIptal: TcxTabSheet
        Caption = 'Sat'#305#351' - '#304'ptal Bildirim'
        ImageIndex = 4
        object GridSatisIade: TcxGrid
          Left = 0
          Top = 0
          Width = 801
          Height = 380
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvSatisIade: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsSatisIptal
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            object ColSecsatisIptal: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Width = 20
            end
            object cxGridDBColumn25: TcxGridDBColumn
              Caption = 'Fatura Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              Visible = False
              GroupIndex = 0
              Width = 80
            end
            object cxGridDBColumn26: TcxGridDBColumn
              Caption = 'Fatura Ba'#351'l'#305#287#305
              DataBinding.FieldName = 'BASLIK'
              Visible = False
              GroupIndex = 1
              Width = 100
            end
            object cxGridDBColumn27: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNBARKOD'
              Visible = False
              GroupIndex = 2
              Width = 100
            end
            object cxGridDBColumn30: TcxGridDBColumn
              Caption = 'S'#305'ra No'
              DataBinding.FieldName = 'SIRANO'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn31: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              Options.Editing = False
              Width = 75
            end
            object cxGridDBColumn32: TcxGridDBColumn
              Caption = 'Son Kullan'#305'm Tarihi'
              DataBinding.FieldName = 'SONKULLANIM'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn33: TcxGridDBColumn
              Caption = 'Sat'#305#351' Durum'
              DataBinding.FieldName = 'SATIS_IPTAL_DURUM'
              Options.Editing = False
              Width = 350
            end
            object cxGridDBColumn34: TcxGridDBColumn
              Caption = 'Sat'#305#351' Bildirim Tarih'
              DataBinding.FieldName = 'SATIS_IPTAL_BILDIRIM_TARIH'
              Options.Editing = False
              Width = 100
            end
          end
          object cxGridLevel4: TcxGridLevel
            GridView = TvSatisIade
          end
        end
      end
      object TsDeAktivasyon: TcxTabSheet
        Caption = 'DeAktivasyon'
        ImageIndex = 5
        object GridDeAktivasyon: TcxGrid
          Left = 0
          Top = 0
          Width = 801
          Height = 380
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object TvDeaktivasyon: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsDeAktivasyon
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
      object TsBos: TcxTabSheet
        Caption = 'TsBos'
        ImageIndex = 6
        object Label4: TLabel
          Left = 69
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
          Left = 42
          Top = 66
          Width = 379
          Height = 1
        end
        object Label2: TLabel
          Left = 42
          Top = 33
          Width = 215
          Height = 29
          Caption = #304'LA'#199' TAK'#304'P S'#304'STEM'#304
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -24
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
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
        object Memo1: TMemo
          Left = 399
          Top = 3
          Width = 402
          Height = 333
          Lines.Strings = (
            '<soapenv:Envelope '
            'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '
            'xmlns:depo="http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo">'
            '<soapenv:Header/>'
            '<soapenv:Body>'
            '<depo:DepoMalAlim>'
            '<DT>A</DT>'
            '<FR>8680007200010</FR>'
            '<TO>8680052900019</TO>'
            '<BELGE>'
            '<DD>?</DD>'
            '<DN>3123</DN>'
            '</BELGE>'
            '<URUNLER>'
            '<URUN>'
            '<GTIN>08680007201260</GTIN>'
            '<BN>BN01</BN>'
            '<SN>ZA021</SN>'
            '<XD>2014-05-22</XD>'
            '</URUN>'
            '</URUNLER>'
            '</depo:DepoMalAlim>'
            '</soapenv:Body>'
            '</soapenv:Envelope>')
          TabOrder = 0
          Visible = False
        end
        object Button1: TButton
          Left = 383
          Top = 3
          Width = 75
          Height = 25
          Caption = 'Button1'
          TabOrder = 1
          Visible = False
          OnClick = Button1Click
        end
        object Memo2: TMemo
          Left = 5
          Top = 5
          Width = 388
          Height = 347
          Lines.Strings = (
            'Memo2')
          TabOrder = 2
          Visible = False
        end
        object Button2: TButton
          Left = 464
          Top = 3
          Width = 75
          Height = 25
          Caption = 'pts iste'
          TabOrder = 3
          Visible = False
          OnClick = Button1Click
        end
        object Button3: TButton
          Left = 568
          Top = 3
          Width = 75
          Height = 25
          Caption = 'pts istek'
          TabOrder = 4
          Visible = False
          OnClick = Button3Click
        end
      end
      object TsGecmis: TcxTabSheet
        Caption = 'Ge'#231'mi'#351
        ImageIndex = 7
        ExplicitLeft = 3
        object GridGecmis: TcxGrid
          Left = 304
          Top = 96
          Width = 801
          Height = 380
          TabOrder = 0
          object TvGecmis: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsGecmis
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsView.GroupByBox = False
            Styles.OnGetContentStyle = cxGridDBTableView1StylesGetContentStyle
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
              HeaderAlignmentVert = vaCenter
              HeaderGlyphAlignmentHorz = taCenter
              Width = 450
            end
          end
          object cxGridLevel6: TcxGridLevel
            GridView = TvGecmis
          end
        end
        object Button4: TButton
          Left = 19
          Top = 32
          Width = 176
          Height = 41
          Caption = 'SendPackage'
          TabOrder = 1
          OnClick = Button4Click
        end
        object cxTextEdit1: TcxTextEdit
          Left = 19
          Top = 5
          TabOrder = 2
          Text = 'cxTextEdit1'
          Width = 121
        end
      end
      object TsUretim: TcxTabSheet
        Caption = #220'retim Bildirimi'
        ImageIndex = 8
        object cxGrid1: TcxGrid
          Left = 0
          Top = 35
          Width = 801
          Height = 345
          Align = alClient
          PopupMenu = PopupMenu1
          TabOrder = 0
          OnContextPopup = GridDogrulaBildirimContextPopup
          object cxGridDBTableView1: TcxGridDBTableView
            NavigatorButtons.ConfirmDelete = False
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsUretim
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skCount
                FieldName = 'SIRANO'
                Column = ColSecUretim
                VisibleForCustomization = False
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Inserting = False
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.FooterMultiSummaries = True
            OptionsView.GroupByBox = False
            object ColSecUretim: TcxGridDBColumn
              Caption = 'Se'#231
              DataBinding.ValueType = 'Boolean'
              PropertiesClassName = 'TcxCheckBoxProperties'
              Properties.ImmediatePost = True
              Properties.NullStyle = nssUnchecked
              Width = 20
            end
            object cxGridDBColumn42: TcxGridDBColumn
              Caption = 'Fatura Tarihi'
              DataBinding.FieldName = 'FATURATARIH'
              Visible = False
              GroupIndex = 0
              Width = 80
            end
            object cxGridDBColumn43: TcxGridDBColumn
              Caption = 'Fatura Ba'#351'l'#305#287#305
              DataBinding.FieldName = 'BASLIK'
              Visible = False
              GroupIndex = 1
              Width = 200
            end
            object cxGridDBColumn44: TcxGridDBColumn
              Caption = #220'r'#252'n Kodu'
              DataBinding.FieldName = 'URUNBARKOD'
              Visible = False
              GroupIndex = 2
              Width = 100
            end
            object cxGridDBColumn45: TcxGridDBColumn
              Caption = 'S'#305'ra No'
              DataBinding.FieldName = 'SIRANO'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn46: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              Options.Editing = False
              Width = 75
            end
            object cxGridDBColumn47: TcxGridDBColumn
              Caption = 'Son Kullan'#305'm Tarihi'
              DataBinding.FieldName = 'SONKULLANIM'
              Options.Editing = False
              Width = 100
            end
            object cxGridDBColumn48: TcxGridDBColumn
              Caption = #220'retim Durum'
              DataBinding.FieldName = 'URETIM_DURUM'
              Options.Editing = False
              Width = 350
            end
            object cxGridDBColumn49: TcxGridDBColumn
              Caption = #220'retim Bildirim Tarih'
              DataBinding.FieldName = 'URETIM_BILDIRIM_TARIH'
              Options.Editing = False
              Width = 100
            end
          end
          object cxGridLevel7: TcxGridLevel
            GridView = cxGridDBTableView1
          end
        end
        object UretimAletCubugu: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 795
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 112
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
          TabOrder = 1
          Transparent = True
          object TbKarekodYaz: TToolButton
            Left = 0
            Top = 0
            Caption = 'Karekod Yazd'#305'r'
            ImageIndex = 16
            Style = tbsTextButton
          end
        end
      end
    end
    object TBItsAracCubugu: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 795
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 118
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
    Left = 0
    Top = 27
    Width = 217
    Height = 486
    Align = alLeft
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
    Width = 1284
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
    Left = 217
    Top = 27
    Width = 264
    Height = 486
    Align = alLeft
    TabOrder = 3
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 262
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
      Left = 1
      Top = 75
      Width = 262
      Height = 410
      Align = alClient
      TabOrder = 1
      object GridFaturalar: TcxGrid
        Left = 1
        Top = 1
        Width = 260
        Height = 408
        Align = alClient
        PopupMenu = PopupMenu1
        TabOrder = 0
        object cxGridDBTableView2: TcxGridDBTableView
          NavigatorButtons.ConfirmDelete = False
          OnCellDblClick = cxGridDBTableView2CellDblClick
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsFaturalar
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
            MinWidth = 112
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
            MinWidth = 724
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
  object TabMalAlim: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT FB.TARIH as FATURATARIH ,FB.BASLIK,FB.FATURANO,K.*,SI.URU' +
        'NBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM'
      ' FROM KAREKOD K,FATBASLIK FB , STOKID SI'
      
        ' WHERE (ALIM_DURUM IS NULL) OR (ALIM_DURUM ='#39#39') AND SI.GIRFATBAS' +
        'ID = FB.ID AND SI.ID=K.STOKIDID')
    Left = 960
    Top = 16
    object TabMalAlimFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object TabMalAlimBASLIK: TWideStringField
      FieldName = 'BASLIK'
      Size = 100
    end
    object TabMalAlimFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabMalAlimID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabMalAlimALIM_DURUM: TStringField
      FieldName = 'ALIM_DURUM'
      Size = 250
    end
    object TabMalAlimALIM_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'ALIM_BILDIRIM_TARIH'
    end
    object TabMalAlimMALALINANGLN: TStringField
      FieldName = 'MALALINANGLN'
    end
    object TabMalAlimMALSATILANGLN: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabMalAlimTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabMalAlimURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabMalAlimSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabMalAlimLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabMalAlimSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object DtsMalAlim: TDataSource
    DataSet = TabMalAlim
    Left = 872
    Top = 24
  end
  object DtsDogrulama: TDataSource
    DataSet = TabDogrulama
    Left = 912
    Top = 72
  end
  object TabDogrulama: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT FB.TARIH as FATURATARIH ,FB.BASLIK,FB.FATURANO,K.*,SI.URU' +
        'NBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM'
      ' FROM KAREKOD K,FATBASLIK FB , STOKID SI'
      
        ' WHERE (ALIM_DURUM IS NULL) OR (ALIM_DURUM ='#39#39') AND SI.GIRFATBAS' +
        'ID = FB.ID AND SI.ID=K.STOKIDID')
    Left = 960
    Top = 72
    object TabDogrulamaFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object TabDogrulamaBASLIK: TWideStringField
      FieldName = 'BASLIK'
      Size = 100
    end
    object TabDogrulamaFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabDogrulamaID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabDogrulamaDOGRULAMA_DURUM: TStringField
      FieldName = 'DOGRULAMA_DURUM'
      Size = 250
    end
    object TabDogrulamaDOGRULAMA_TARIH: TDateTimeField
      FieldName = 'DOGRULAMA_TARIH'
    end
    object TabDogrulamaMALALINANGLN: TStringField
      FieldName = 'MALALINANGLN'
    end
    object TabDogrulamaMALSATILANGLN: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabDogrulamaTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabDogrulamaURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabDogrulamaSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabDogrulamaLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabDogrulamaSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object DtsMalIade: TDataSource
    DataSet = TabMalIade
    Left = 880
    Top = 136
  end
  object TabMalIade: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT FB.TARIH as FATURATARIH ,FB.BASLIK,FB.FATURANO,K.*,SI.URU' +
        'NBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM'
      ' FROM KAREKOD K,FATBASLIK FB , STOKID SI'
      
        ' WHERE (ALIM_DURUM IS NULL) OR (ALIM_DURUM ='#39#39') AND SI.GIRFATBAS' +
        'ID = FB.ID AND SI.ID=K.STOKIDID')
    Left = 960
    Top = 136
    object TabMalIadeFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object TabMalIadeBASLIK: TWideStringField
      FieldName = 'BASLIK'
      Size = 100
    end
    object TabMalIadeFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabMalIadeID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabMalIadeALIM_IADE_DURUM: TStringField
      FieldName = 'ALIM_IADE_DURUM'
      Size = 250
    end
    object TabMalIadeALIM_IADE_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'ALIM_IADE_BILDIRIM_TARIH'
    end
    object TabMalIadeMALALINANGLN: TStringField
      FieldName = 'MALALINANGLN'
    end
    object TabMalIadeMALSATILANGLN: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabMalIadeTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabMalIadeURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabMalIadeSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabMalIadeLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabMalIadeSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object DtsSatis: TDataSource
    DataSet = TabSatis
    Left = 912
    Top = 192
  end
  object TabSatis: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT FB.TARIH as FATURATARIH ,FB.BASLIK,FB.FATURANO,K.*,SI.URU' +
        'NBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM'
      ' FROM KAREKOD K,FATBASLIK FB , STOKID SI'
      
        ' WHERE (ALIM_DURUM IS NULL) OR (ALIM_DURUM ='#39#39') AND SI.GIRFATBAS' +
        'ID = FB.ID AND SI.ID=K.STOKIDID'
      '')
    Left = 960
    Top = 192
    object TabSatisFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object TabSatisBASLIK: TWideStringField
      FieldName = 'BASLIK'
      Size = 100
    end
    object TabSatisFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabSatisID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabSatisSATIS_DURUM: TStringField
      FieldName = 'SATIS_DURUM'
      Size = 250
    end
    object TabSatisSATIS_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'SATIS_BILDIRIM_TARIH'
    end
    object TabSatisMALALINANGLN: TStringField
      FieldName = 'MALALINANGLN'
    end
    object TabSatisMALSATILANGLN: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabSatisTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabSatisURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabSatisSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabSatisLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabSatisSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object DtsSatisIptal: TDataSource
    DataSet = TabSatisIptal
    Left = 912
    Top = 248
  end
  object TabSatisIptal: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT FB.TARIH as FATURATARIH ,FB.BASLIK,FB.FATURANO,K.*,SI.URU' +
        'NBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM'
      ' FROM KAREKOD K,FATBASLIK FB , STOKID SI'
      
        ' WHERE (ALIM_DURUM IS NULL) OR (ALIM_DURUM ='#39#39') AND SI.GIRFATBAS' +
        'ID = FB.ID AND SI.ID=K.STOKIDID')
    Left = 960
    Top = 248
    object TabSatisIptalFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object TabSatisIptalBASLIK: TWideStringField
      FieldName = 'BASLIK'
      Size = 100
    end
    object TabSatisIptalFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabSatisIptalID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabSatisIptalSATIS_IPTAL_DURUM: TStringField
      FieldName = 'SATIS_IPTAL_DURUM'
      Size = 250
    end
    object TabSatisIptalSATIS_IPTAL_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'SATIS_IPTAL_BILDIRIM_TARIH'
    end
    object TabSatisIptalMALALINANGLN: TStringField
      FieldName = 'MALALINANGLN'
    end
    object TabSatisIptalMALSATILANGLN: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabSatisIptalTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabSatisIptalURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabSatisIptalSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabSatisIptalLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabSatisIptalSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object DtsDeAktivasyon: TDataSource
    DataSet = TabDeAktivasyon
    Left = 904
    Top = 296
  end
  object TabDeAktivasyon: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT FB.TARIH as FATURATARIH ,FB.BASLIK,FB.FATURANO,K.*,SI.URU' +
        'NBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM'
      ' FROM KAREKOD K,FATBASLIK FB , STOKID SI'
      
        ' WHERE (ALIM_DURUM IS NULL) OR (ALIM_DURUM ='#39#39') AND SI.GIRFATBAS' +
        'ID = FB.ID AND SI.ID=K.STOKIDID')
    Left = 960
    Top = 296
    object TabDeAktivasyonFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object TabDeAktivasyonBASLIK: TWideStringField
      FieldName = 'BASLIK'
      Size = 100
    end
    object TabDeAktivasyonFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabDeAktivasyonID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabDeAktivasyonDEAKTIVASYON_DURUM: TStringField
      FieldName = 'DEAKTIVASYON_DURUM'
      Size = 250
    end
    object TabDeAktivasyonDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField
      FieldName = 'DEAKTIVASYON_BILDIRIM_TARIH'
    end
    object TabDeAktivasyonMALALINANGLN: TStringField
      FieldName = 'MALALINANGLN'
    end
    object TabDeAktivasyonMALSATILANGLN: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object TabDeAktivasyonTRANSFERID: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object TabDeAktivasyonURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabDeAktivasyonSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabDeAktivasyonLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabDeAktivasyonSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object TabGecmis: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from ITS_URUNLER')
    Left = 960
    Top = 344
  end
  object DtsGecmis: TDataSource
    AutoEdit = False
    DataSet = TabGecmis
    Left = 912
    Top = 344
  end
  object PopupMenu1: TPopupMenu
    Left = 688
    Top = 168
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
  object TabFaturalar: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'TARIH1'
        Attributes = [paNullable]
        DataType = ftDateTime
        Precision = 16
        Size = 16
        Value = Null
      end
      item
        Name = 'TARIH2'
        Attributes = [paNullable]
        DataType = ftDateTime
        Precision = 16
        Size = 16
        Value = Null
      end>
    SQL.Strings = (
      'SELECT FB.TARIH,F.ID,ADET ,R.FIRMA ,S.STOKADI FROM FATURA F'
      #9'INNER JOIN REHBER R ON R.ID=F.REHBERID'
      #9'INNER JOIN FATBASLIK FB ON FB.ID=F.FATBASID'
      #9'INNER JOIN STOKLAR S ON S.ID =F.URUNID'
      'WHERE F.IZLEME='#39'3'#39' AND FB.TARIH BETWEEN :TARIH1 AND :TARIH2'
      '')
    Left = 256
    Top = 320
    object TabFaturalarTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabFaturalarID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabFaturalarADET: TFloatField
      FieldName = 'ADET'
    end
    object TabFaturalarFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabFaturalarSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
  end
  object DtsFaturalar: TDataSource
    AutoEdit = False
    DataSet = TabFaturalar
    Left = 320
    Top = 320
  end
  object TabUretim: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT  FB.TARIH as FATURATARIH,FB.FATURANO,SI.URUNBARKOD,SI.SIR' +
        'ANO,SI.LOTNO,SI.SONKULLANIM,K.URETIM_DURUM,K.URETIM_BILDIRIM_TAR' +
        'IH'
      
        ',K.MALALINANGLN,K.MALSATILANGLN,K.TRANSFERID,SI.URETIMTIPI,SI.UR' +
        'UNCINSI,SI.URETIMTARIHI'
      ' FROM STOKID SI'
      ' INNER JOIN FATBASLIK FB ON SI.GIRFATBASID = FB.ID'
      ' INNER JOIN KAREKOD K ON K.STOKIDID=SI.ID'
      ' WHERE 1=2')
    Left = 968
    Top = 400
    object AutoIncField1: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object StringField1: TStringField
      FieldName = 'URETIM_DURUM'
      Size = 250
    end
    object DateTimeField2: TDateTimeField
      FieldName = 'URETIM_BILDIRIM_TARIH'
    end
    object StringField2: TStringField
      FieldName = 'MALALINANGLN'
    end
    object StringField3: TStringField
      FieldName = 'MALSATILANGLN'
    end
    object StringField4: TStringField
      FieldName = 'TRANSFERID'
      Size = 25
    end
    object StringField5: TStringField
      FieldName = 'URUNBARKOD'
    end
    object StringField6: TStringField
      FieldName = 'SIRANO'
    end
    object StringField7: TStringField
      FieldName = 'LOTNO'
    end
    object DateTimeField3: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object TabUretimFATURATARIH: TDateTimeField
      FieldName = 'FATURATARIH'
    end
    object TabUretimFATURANO: TWideStringField
      FieldName = 'FATURANO'
      Size = 10
    end
    object TabUretimURETIMTIPI: TStringField
      FieldName = 'URETIMTIPI'
      Size = 5
    end
    object TabUretimURUNCINSI: TStringField
      FieldName = 'URUNCINSI'
      Size = 5
    end
    object TabUretimURETIMTARIHI: TDateTimeField
      FieldName = 'URETIMTARIHI'
    end
  end
  object DtsUretim: TDataSource
    DataSet = TabUretim
    Left = 872
    Top = 400
  end
  object HTTPReqResp1: THTTPReqResp
    UseUTF8InHeader = True
    InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    WebNodeOptions = []
    Left = 824
    Top = 120
  end
  object HTTPRIO1: THTTPRIO
    HTTPWebNode.UseUTF8InHeader = True
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    HTTPWebNode.OnBeforePost = HTTPRIO1HTTPWebNode1BeforePost
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 752
    Top = 120
  end
  object OPToSoapDomConvert1: TOPToSoapDomConvert
    Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 200
    Top = 112
  end
end
