object BankaHareketlerDlg: TBankaHareketlerDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Banka Hareketleri Giri'#351'i'
  ClientHeight = 557
  ClientWidth = 1370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object PanelSol: TPanel
    Left = 0
    Top = 0
    Width = 273
    Height = 557
    Align = alLeft
    Alignment = taLeftJustify
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 271
      Height = 35
      Align = alTop
      Alignment = taLeftJustify
      Caption = '---'
      TabOrder = 0
    end
    object GridImport: TcxGrid
      Left = 1
      Top = 71
      Width = 271
      Height = 485
      Align = alClient
      TabOrder = 1
      ExplicitTop = 68
      ExplicitHeight = 488
      object GridImportView: TcxGridDBTableView
        PopupMenu = Menu1
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsImport
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
          end>
        DataController.Summary.SummaryGroups = <>
        Filtering.ColumnAddValueItems = False
        Filtering.ColumnMRUItemsList = False
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        object GridImportViewEKLEMETARIHI: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'EKLEMETARIHI'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxDateEditProperties'
          Properties.DisplayFormat = 'DD/MM/YYYY HH:NN'
          Properties.ImmediateDropDownWhenActivated = True
          Properties.ReadOnly = True
          Width = 82
        end
        object GridImportViewBANKAKODU: TcxGridDBColumn
          Caption = 'Hesap Ad'#305
          DataBinding.FieldName = 'HESAPADI'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxTextEditProperties'
          Width = 71
        end
        object GridImportViewKUR: TcxGridDBColumn
          Caption = 'P.Birim'
          DataBinding.FieldName = 'KUR'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = False
          Width = 37
        end
        object GridImportViewTOPSAY: TcxGridDBColumn
          Caption = 'Top.'
          DataBinding.FieldName = 'TOPLAMSAY'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Width = 30
        end
        object GridImportViewKALANSAY: TcxGridDBColumn
          Caption = 'Kalan'
          DataBinding.FieldName = 'KALANSAY'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Width = 33
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = GridImportView
      end
    end
    object ToolBar2: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 39
      Width = 265
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 85
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
      Wrapable = False
      ExplicitHeight = 29
      object ToolButton3: TToolButton
        Left = 0
        Top = 0
        Width = 8
        Caption = 'ToolButton9'
        ImageIndex = 2
        Style = tbsSeparator
      end
      object YeniExcelTus: TToolButton
        Left = 8
        Top = 0
        Caption = 'Yeni Excel'
        ImageIndex = 7
        OnClick = YeniExcelTusClick
      end
      object SilTus: TToolButton
        Left = 93
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        OnClick = SilTusClick
      end
    end
  end
  object PanelSag: TPanel
    Left = 281
    Top = 0
    Width = 811
    Height = 557
    Align = alClient
    Alignment = taLeftJustify
    TabOrder = 1
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 809
      Height = 35
      Align = alTop
      Alignment = taLeftJustify
      Caption = '---'
      TabOrder = 0
    end
    object GridHareket: TcxGrid
      Left = 1
      Top = 71
      Width = 809
      Height = 485
      Align = alClient
      PopupMenu = Menu1
      TabOrder = 1
      object GridHareketView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = GridHareketViewCanFocusRecord
        DataController.DataSource = DtsHareket
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            Column = GridHareketViewTarih
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Inserting = False
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        Styles.OnGetContentStyle = GridHareketViewStylesGetContentStyle
        object GridHareketViewDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
              Description = 'Tan'#305'ms'#305'z'
              ImageIndex = 0
              Value = 0
            end
            item
              Description = 'Eksik'
              Value = 1
            end
            item
              Description = 'Haz'#305'r'
              Value = 2
            end
            item
              Description = 'Kay'#305'tl'#305
              Value = 9
            end>
          Properties.ReadOnly = True
          Width = 72
        end
        object GridHareketViewSec: TcxGridDBColumn
          Caption = 'Se'#231
          DataBinding.FieldName = 'SEC'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Width = 32
        end
        object GridHareketViewRecId: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
        object GridHareketViewTarih: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
          PropertiesClassName = 'TcxDateEditProperties'
          Properties.ReadOnly = True
          Width = 90
        end
        object GridHareketViewNo: TcxGridDBColumn
          Caption = 'No'
          DataBinding.FieldName = 'NO'
          PropertiesClassName = 'TcxTextEditProperties'
          Properties.ReadOnly = True
          Width = 83
        end
        object GridHareketViewGELENISLEMTIPI: TcxGridDBColumn
          Caption = 'Banka '#304#351'lem Tipi'
          DataBinding.FieldName = 'GELENISLEMTIPI'
          PropertiesClassName = 'TcxButtonEditProperties'
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = GridHareketViewAciklamaPropertiesButtonClick
          Width = 167
        end
        object GridHareketViewAciklama: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
          PropertiesClassName = 'TcxButtonEditProperties'
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = GridHareketViewAciklamaPropertiesButtonClick
          Width = 304
        end
        object GridHareketViewTutar: TcxGridDBColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'TUTAR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Properties.ReadOnly = True
          Width = 82
        end
        object GridHareketViewMasrafId: TcxGridDBColumn
          DataBinding.FieldName = 'MasrafId'
          Visible = False
        end
        object GridHareketViewProjeId: TcxGridDBColumn
          DataBinding.FieldName = 'ProjeId'
          Visible = False
        end
        object GridHareketViewPRGISLEMTIPI: TcxGridDBColumn
          Caption = 'Prg. '#304#351'lem Tipi'
          DataBinding.FieldName = 'PRGISLEMTIPI'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          Properties.ReadOnly = True
          RepositoryItem = Tablo.RepBankaHareketTipi
          Width = 75
        end
      end
      object GridHareketLevel1: TcxGridLevel
        GridView = GridHareketView
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 36
      Width = 809
      Height = 35
      Align = alTop
      Alignment = taLeftJustify
      Caption = '---'
      TabOrder = 2
      object ToolBar1: TToolBar
        Left = 1
        Top = 1
        Width = 350
        Height = 33
        Margins.Bottom = 0
        Align = alLeft
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 114
        Caption = 'AletCubugu'
        Color = clTeal
        DockSite = True
        DrawingStyle = dsGradient
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esNone
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
        Wrapable = False
        object KuralListesiTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Kural Listesi'
          ImageIndex = 47
          OnClick = KuralListesiniAcMenuClick
        end
        object SilTus2: TToolButton
          Left = 114
          Top = 0
          Caption = 'Kural Olu'#351'tur'
          DropdownMenu = PopupMenuKural
          ImageIndex = 1
        end
        object ToolButton9: TToolButton
          Left = 228
          Top = 0
          Width = 8
          Caption = 'ToolButton9'
          ImageIndex = 2
          Style = tbsSeparator
        end
        object KaydetTus: TToolButton
          Left = 236
          Top = 0
          Caption = 'Se'#231'ilileri Kaydet'
          ImageIndex = 10
          OnClick = KaydetTusClick
        end
      end
      object JvNavPanelHeader2: TJvNavPanelHeader
        Left = 351
        Top = 1
        Width = 457
        Height = 33
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ColorFrom = 14540253
        ColorTo = 11776947
        ImageIndex = 0
        object checkTanimsiz: TcxCheckBox
          Left = 27
          Top = 8
          Caption = 'Tan'#305'ms'#305'z'
          ParentFont = False
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Properties.OnChange = checkTanimsizPropertiesChange
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -13
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          Transparent = True
        end
        object CheckEksik: TcxCheckBox
          Tag = 1
          Left = 111
          Top = 9
          Caption = 'Eksik'
          ParentFont = False
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Properties.OnChange = checkTanimsizPropertiesChange
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -13
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.TextColor = clRed
          Style.IsFontAssigned = True
          TabOrder = 1
          Transparent = True
        end
        object CheckHazir: TcxCheckBox
          Tag = 2
          Left = 179
          Top = 9
          Caption = 'Haz'#305'r'
          ParentFont = False
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Properties.OnChange = checkTanimsizPropertiesChange
          State = cbsChecked
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -13
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.TextColor = clHotLight
          Style.IsFontAssigned = True
          TabOrder = 2
          Transparent = True
        end
        object CheckKayitli: TcxCheckBox
          Tag = 9
          Left = 243
          Top = 9
          Caption = 'Kay'#305'tl'#305
          ParentFont = False
          Properties.ImmediatePost = True
          Properties.NullStyle = nssUnchecked
          Properties.OnChange = checkTanimsizPropertiesChange
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clBlack
          Style.Font.Height = -13
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = []
          Style.TextColor = clGreen
          Style.IsFontAssigned = True
          TabOrder = 3
          Transparent = True
        end
      end
    end
    object SQLMemo: TcxMemo
      Left = 248
      Top = 256
      Lines.Strings = (
        'select * from '
        'BANKAIMPORTHAREKET'
        'where'
        'BANKAIMPORTID = :prm1'
        '-----'
        'order by ID')
      TabOrder = 3
      Visible = False
      Height = 89
      Width = 185
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 273
    Top = 0
    Width = 8
    Height = 557
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = PanelSol
  end
  object Panel4: TPanel
    Left = 1092
    Top = 0
    Width = 278
    Height = 557
    Align = alRight
    Alignment = taLeftJustify
    TabOrder = 3
    object PanelKur: TPanel
      Left = 1
      Top = 314
      Width = 276
      Height = 69
      Align = alTop
      Alignment = taLeftJustify
      TabOrder = 0
      object ComboDovKur: TcxDBComboBox
        Left = 72
        Top = 16
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        DataBinding.DataField = 'KUR'
        DataBinding.DataSource = DtsHareket
        Properties.DropDownListStyle = lsFixedList
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.ReadOnly = False
        TabOrder = 0
        Width = 60
      end
      object EditKulKur: TcxDBCurrencyEdit
        Left = 72
        Top = 40
        TabStop = False
        RepositoryItem = Tablo.RepCurrencyDovizKuru
        DataBinding.DataField = 'KURDEGERI'
        DataBinding.DataSource = DtsHareket
        Properties.DecimalPlaces = 4
        Properties.DisplayFormat = ',0.0000;(,0.0000)'
        Properties.EditFormat = ',0.0000;(,0.0000)'
        TabOrder = 1
        Width = 60
      end
      object cxLabel1: TcxLabel
        Left = 1
        Top = 15
        Caption = 'Para Birimi'
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
        Left = 1
        Top = 39
        Caption = 'Kur'
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
    object PanelMasraf: TPanel
      Left = 1
      Top = 175
      Width = 276
      Height = 69
      Align = alTop
      Alignment = taLeftJustify
      TabOrder = 1
      object LabelMasrafMerkezi: TcxLabel
        Left = 1
        Top = 15
        Caption = 'Masraf Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditMasrafKodu: TcxButtonEdit
        Left = 70
        Top = 14
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
        Properties.OnButtonClick = EditMasrafKoduPropertiesButtonClick
        TabOrder = 1
        Width = 200
      end
      object cxLabel6: TcxLabel
        Left = 1
        Top = 38
        Caption = 'Masraf Ad'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditMasrafAd: TcxTextEdit
        Left = 70
        Top = 38
        TabOrder = 3
        Width = 200
      end
    end
    object PanelOdemeTipi: TPanel
      Left = 1
      Top = 279
      Width = 276
      Height = 35
      Align = alTop
      Alignment = taLeftJustify
      TabOrder = 2
      object LabelOdemeTipi: TcxLabel
        Left = 1
        Top = 6
        Caption = #214'deme Tipi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboOdemeTipi: TcxDBImageComboBox
        Left = 70
        Top = 6
        DataBinding.DataField = 'ODEMETIPI'
        DataBinding.DataSource = DtsHareket
        Properties.Items = <
          item
            Description = 'Maa'#351
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Prim'
            Value = 11
          end
          item
            Description = 'Yemek Paras'#305
            Value = 5
          end
          item
            Description = 'Yol Paras'#305
            Value = 7
          end
          item
            Description = #304'zin Paras'#305
            Value = 9
          end
          item
            Description = 'Maa'#351' Avans'#305
            Value = 196
          end
          item
            Description = #304#351' Avans'#305
            Value = 195
          end
          item
            Description = 'Avsns Geri '#214'demesi'
            Value = 231
          end>
        TabOrder = 1
        Width = 115
      end
    end
    object Panel8: TPanel
      Left = 1
      Top = 1
      Width = 276
      Height = 70
      Align = alTop
      Alignment = taLeftJustify
      Caption = ' Programa Kaydedilecek'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 3
    end
    object PanelHesap: TPanel
      Left = 1
      Top = 106
      Width = 276
      Height = 69
      Align = alTop
      Alignment = taLeftJustify
      TabOrder = 4
      object cxLabel3: TcxLabel
        Left = 1
        Top = 38
        Caption = 'Hesap Ad'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditHesapAd: TcxTextEdit
        Left = 70
        Top = 38
        TabOrder = 1
        Width = 200
      end
      object cxLabel4: TcxLabel
        Left = 1
        Top = 14
        Caption = 'Hesap Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditHesapKod: TcxButtonEdit
        Left = 70
        Top = 14
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
        Properties.OnButtonClick = EditHesapKodPropertiesButtonClick
        TabOrder = 3
        Width = 200
      end
    end
    object Panel5: TPanel
      Left = 1
      Top = 71
      Width = 276
      Height = 35
      Align = alTop
      Alignment = taLeftJustify
      TabOrder = 5
      object cxLabel5: TcxLabel
        Left = 1
        Top = 8
        Caption = 'Prg.'#304#351'lem Tipi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object ComboPRGISLEMTIPI: TcxDBImageComboBox
        Left = 70
        Top = 8
        RepositoryItem = Tablo.RepBankaHareketTipi
        DataBinding.DataField = 'PRGISLEMTIPI'
        DataBinding.DataSource = DtsHareket
        Properties.Items = <
          item
            Description = 'Maa'#351
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Prim'
            Value = 11
          end
          item
            Description = 'Yemek Paras'#305
            Value = 5
          end
          item
            Description = 'Yol Paras'#305
            Value = 7
          end
          item
            Description = #304'zin Paras'#305
            Value = 9
          end
          item
            Description = 'Maa'#351' Avans'#305
            Value = 196
          end
          item
            Description = #304#351' Avans'#305
            Value = 195
          end
          item
            Description = 'Avsns Geri '#214'demesi'
            Value = 231
          end>
        Properties.OnChange = cxDBImageComboBox1PropertiesChange
        TabOrder = 1
        Width = 200
      end
    end
    object PanelProje: TPanel
      Left = 1
      Top = 244
      Width = 276
      Height = 35
      Align = alTop
      Alignment = taLeftJustify
      TabOrder = 6
      object LabelProjeKodu: TcxLabel
        Left = 1
        Top = 11
        Caption = 'Proje Kodu'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditProje: TcxButtonEdit
        Left = 70
        Top = 7
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
        Properties.OnButtonClick = EditProjePropertiesButtonClick
        TabOrder = 1
        Width = 200
      end
    end
  end
  object DtsHareket: TDataSource
    DataSet = TabHareket
    Left = 400
    Top = 288
  end
  object Menu1: TPopupMenu
    Left = 542
    Top = 137
    object KuralListesiniAcMenu: TMenuItem
      Caption = 'Kural Listesini A'#231
      OnClick = KuralListesiniAcMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object KurallarUygulaMenu: TMenuItem
      Caption = 'T'#252'm Se'#231'ililere Kurallar'#305' Uygula'
      OnClick = KurallarUygulaMenuClick
    end
    object BuSatirdaKuralTestEtMenu: TMenuItem
      Caption = 'Bu Sat'#305'rda Kural Test Et'
      OnClick = BuSatirdaKuralTestEtMenuClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object TumunuSecMenu: TMenuItem
      Tag = 1
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      OnClick = TumunuSecMenuClick
    end
    object anmszveEksikleriSe1: TMenuItem
      Tag = 3
      Caption = '"Tan'#305'ms'#305'z" ve "Eksikleri" Se'#231
      OnClick = TumunuSecMenuClick
    end
    object HazrlarSe1: TMenuItem
      Tag = 4
      Caption = '"Haz'#305'r" lar'#305' Se'#231
      OnClick = TumunuSecMenuClick
    end
    object mnBrak1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' B'#305'rak'
      OnClick = TumunuSecMenuClick
    end
    object SeilileriTersevir1: TMenuItem
      Tag = 2
      Caption = 'Se'#231'ilileri Ters '#199'evir'
      OnClick = TumunuSecMenuClick
    end
  end
  object PopupMenuKural: TPopupMenu
    Left = 414
    Top = 105
    object IslemTipineGoreMenu: TMenuItem
      Tag = 1
      Caption = #304#351'lem Tipine G'#246're '
      Hint = 'GELENISLEMTIPI'
      OnClick = IslemTipineGoreMenuClick
    end
    object AciklamayaGoreMenu: TMenuItem
      Tag = 2
      Caption = 'A'#231#305'klamaya G'#246're '
      Hint = 'ACIKLAMA'
      OnClick = IslemTipineGoreMenuClick
    end
  end
  object TabImport: TFDQuery
    AfterScroll = TabImportAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT BI.*, '
      
        'HESAPADI=(select HESAPADI from BANKAHESAPLAR BH where BH.ID=BI.B' +
        'ANKAHESAPID )'
      'FROM BANKAIMPORT BI'
      'order by BI.ID DESC')
    Left = 83
    Top = 196
  end
  object DtsImport: TDataSource
    DataSet = TabImport
    Left = 155
    Top = 197
  end
  object TabHareket: TFDQuery
    BeforePost = TabHareketBeforePost
    AfterScroll = TabHareketAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from '
      'BANKAIMPORTHAREKET'
      'where'
      'BANKAIMPORTID = 0')
    Left = 352
    Top = 216
    object TabHareketID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabHareketBANKAIMPORTID: TIntegerField
      FieldName = 'BANKAIMPORTID'
    end
    object TabHareketDURUM: TWordField
      FieldName = 'DURUM'
    end
    object TabHareketSEC: TBooleanField
      FieldName = 'SEC'
    end
    object TabHareketTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabHareketNO: TWideStringField
      FieldName = 'NO'
      Size = 50
    end
    object TabHareketGELENISLEMTIPI: TWideStringField
      DisplayWidth = 150
      FieldName = 'GELENISLEMTIPI'
      Size = 100
    end
    object TabHareketACIKLAMA: TWideStringField
      DisplayWidth = 100
      FieldName = 'ACIKLAMA'
      Size = 500
    end
    object TabHareketEKLEME: TSmallintField
      FieldName = 'EKLEME'
    end
    object TabHareketTUTAR: TBCDField
      FieldName = 'TUTAR'
      Precision = 19
    end
    object TabHareketKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabHareketKURDEGERI: TCurrencyField
      FieldName = 'KURDEGERI'
    end
    object TabHareketPRGISLEMTIPI: TSmallintField
      FieldName = 'PRGISLEMTIPI'
    end
    object TabHareketHESAPID: TIntegerField
      FieldName = 'HESAPID'
    end
    object TabHareketMASRAFID: TIntegerField
      FieldName = 'MASRAFID'
    end
    object TabHareketPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabHareketDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabHareketDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabHareketODEMETIPI: TIntegerField
      FieldName = 'ODEMETIPI'
    end
  end
end
