object StokHizmetAraDlg: TStokHizmetAraDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #220'r'#252'n Arama'
  ClientHeight = 588
  ClientWidth = 1111
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object PanelDetayliArama: TPanel
    Left = 0
    Top = 40
    Width = 1111
    Height = 41
    Align = alTop
    TabOrder = 1
    Visible = False
    object Label3: TLabel
      Left = 316
      Top = -1
      Width = 33
      Height = 16
      Caption = 'Grubu'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label5: TLabel
      Left = 438
      Top = -1
      Width = 37
      Height = 16
      Caption = #214'zellik'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label6: TLabel
      Left = 560
      Top = -1
      Width = 32
      Height = 16
      Caption = 'Marka'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label7: TLabel
      Left = 684
      Top = -1
      Width = 32
      Height = 16
      Caption = 'Model'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label8: TLabel
      Left = 193
      Top = -1
      Width = 32
      Height = 16
      Caption = #304#231'erik'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelSerino: TLabel
      Left = 806
      Top = -1
      Width = 35
      Height = 16
      Caption = 'Serino'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Panel6: TPanel
      Left = 1108
      Top = 1
      Width = 2
      Height = 39
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
    end
    object ComboGRUBU: TcxImageComboBox
      Left = 315
      Top = 15
      RepositoryItem = Tablo.repStokGrubu
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboGRUBUPropertiesEditValueChanged
      TabOrder = 2
      Width = 121
    end
    object ComboOZELLIK: TcxImageComboBox
      Left = 438
      Top = 15
      RepositoryItem = Tablo.repStokOzellik
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboGRUBUPropertiesEditValueChanged
      TabOrder = 3
      Width = 120
    end
    object ComboMARKA: TcxImageComboBox
      Left = 560
      Top = 15
      Cursor = crHandPoint
      RepositoryItem = Tablo.repStokMarka
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboMARKAPropertiesEditValueChanged
      TabOrder = 4
      Width = 121
    end
    object ComboMODEL: TcxImageComboBox
      Left = 683
      Top = 15
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboGRUBUPropertiesEditValueChanged
      TabOrder = 5
      Width = 120
    end
    object ComboIcerik: TcxImageComboBox
      Left = 192
      Top = 15
      RepositoryItem = Tablo.RepStokIcerik
      Properties.Items = <>
      Properties.OnEditValueChanged = ComboGRUBUPropertiesEditValueChanged
      TabOrder = 1
      Width = 121
    end
    object EditSerino: TcxTextEdit
      Left = 806
      Top = 16
      TabOrder = 6
      OnKeyUp = EditAdetKeyUp
      Width = 159
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1111
    Height = 40
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 192
      Top = 0
      Width = 75
      Height = 16
      Caption = 'Kodu/'#220'r'#252'n No'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelAdi: TLabel
      Left = 300
      Top = 1
      Width = 18
      Height = 16
      Caption = 'Ad'#305
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object LabelBarkod: TLabel
      Left = 434
      Top = 0
      Width = 46
      Height = 16
      Caption = 'Barkodu'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object BtnKapat: TJvNavPanelButton
      Left = 1016
      Top = 1
      Width = 94
      Height = 38
      Align = alRight
      AllowAllUp = True
      Caption = 'Kapat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 18
      Images = Tablo.PNGImageList1
      OnClick = BtnKapatClick
      ExplicitLeft = 1048
    end
    object BtnSec: TJvNavPanelButton
      Left = 922
      Top = 1
      Width = 94
      Height = 38
      Align = alRight
      AllowAllUp = True
      Caption = 'Se'#231
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 1
      Images = Tablo.PNGImageList1
      OnClick = BtnSecClick
      ExplicitLeft = 933
      ExplicitTop = -4
    end
    object JvNavPanelButton1: TJvNavPanelButton
      Left = 1
      Top = 1
      Width = 107
      Height = 38
      Align = alLeft
      AllowAllUp = True
      Caption = 'Yeni Stok'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 7
      Images = Tablo.PNGImageList1
      OnClick = JvNavPanelButton1Click
    end
    object Label9: TLabel
      Left = 630
      Top = 0
      Width = 60
      Height = 16
      Caption = 'Kay'#305't Say'#305's'#305
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object EditKodu: TcxTextEdit
      Left = 192
      Top = 16
      TabOrder = 1
      OnKeyUp = EditAdetKeyUp
      Width = 105
    end
    object EditAdi: TcxTextEdit
      Left = 298
      Top = 16
      TabOrder = 2
      OnKeyUp = EditAdetKeyUp
      Width = 135
    end
    object EditBarkodu: TcxTextEdit
      Left = 434
      Top = 16
      TabOrder = 3
      OnKeyUp = EditAdetKeyUp
      Width = 128
    end
    object Panel3: TPanel
      Left = 920
      Top = 1
      Width = 2
      Height = 38
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
    end
    object LabelDetayliArama: TcxLabel
      Left = 844
      Top = 17
      Cursor = crHandPoint
      Caption = 'Detayl'#305' Arama...'
      ParentColor = False
      Style.Color = clBtnFace
      Style.TextColor = clNavy
      Transparent = True
      OnClick = LabelDetayliAramaClick
    end
    object SpinKayitSayisi: TcxSpinEdit
      Left = 630
      Top = 16
      Properties.ImmediatePost = True
      Properties.MinValue = 1.000000000000000000
      Properties.ValueType = vtInt
      Properties.OnEditValueChanged = SpinKayitSayisiPropertiesEditValueChanged
      Style.Color = clBtnFace
      TabOrder = 4
      Value = 200
      OnKeyUp = SpinKayitSayisiKeyUp
      Width = 62
    end
    object ComboSube: TcxImageComboBox
      Left = 698
      Top = 15
      RepositoryItem = Tablo.RepSubeler
      Enabled = False
      Properties.Items = <>
      Properties.ReadOnly = True
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 6
      Width = 100
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 81
    Width = 1111
    Height = 507
    Align = alClient
    TabOrder = 2
    object PageControl1: TcxPageControl
      Left = 1
      Top = 1
      Width = 724
      Height = 505
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = SheetStok
      Properties.CustomButtons.Buttons = <>
      Properties.Images = Tablo.PNGImageList2
      OnChange = PageControl1Change
      OnPageChanging = PageControl1PageChanging
      ClientRectBottom = 501
      ClientRectLeft = 4
      ClientRectRight = 720
      ClientRectTop = 25
      object SheetStok: TcxTabSheet
        Tag = 1
        Caption = 'Stoklar'
        ImageIndex = 4
        object Label2: TLabel
          Left = 720
          Top = 107
          Width = 31
          Height = 13
          Caption = 'Label2'
        end
        object TreeListKategori: TcxDBTreeList
          Left = 0
          Top = 0
          Width = 187
          Height = 476
          Align = alLeft
          Bands = <
            item
              Caption.Text = 'Hesap Plan'#305
            end>
          DataController.DataSource = DtsKategori
          DataController.ParentField = 'ROOTKOD'
          DataController.KeyField = 'KOD'
          DefaultRowHeight = 20
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          LookAndFeel.SkinName = 'LondonLiquidSky'
          Navigator.Buttons.CustomButtons = <>
          OptionsBehavior.IncSearch = True
          OptionsData.Appending = True
          OptionsData.Inserting = True
          OptionsData.CheckHasChildren = False
          OptionsData.SmartRefresh = True
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          RootValue = -1
          ScrollbarAnnotations.CustomAnnotations = <>
          Styles.ContentEven = Tablo.cxStyle12
          TabOrder = 0
          OnClick = TreeListKategoriClick
          object TreeListKOD: TcxDBTreeListColumn
            Visible = False
            Caption.Text = 'Kod'
            DataBinding.FieldName = 'KOD'
            Width = 53
            Position.ColIndex = 0
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListAD: TcxDBTreeListColumn
            Caption.Text = 'Kategori'
            DataBinding.FieldName = 'AD'
            Width = 188
            Position.ColIndex = 1
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object TreeListID: TcxDBTreeListColumn
            Visible = False
            DataBinding.FieldName = 'ID'
            Width = 100
            Position.ColIndex = 2
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
        end
        object GridStok: TcxGrid
          Left = 187
          Top = 0
          Width = 529
          Height = 476
          Align = alClient
          PopupMenu = PmKopyala
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridStokView: TcxGridDBTableView
            OnDblClick = GridStokViewDblClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridStokViewCanFocusRecord
            DataController.DataSource = DtsStokListe
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skCount
                Column = GridStokViewColumnAd
              end>
            DataController.Summary.SummaryGroups = <>
            FilterRow.ApplyChanges = fracImmediately
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.MultiSelect = True
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.Indicator = True
            Styles.ContentEven = Tablo.cxStyle1
            Styles.Indicator = Tablo.cxStSerinoCikilmis
            object GridStokViewColumnID: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 44
            end
            object GridStokViewColumnKod: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Width = 87
            end
            object GridStokViewURUNNO: TcxGridDBColumn
              Caption = #220'r'#252'n No'
              DataBinding.FieldName = 'URUNNO'
              DataBinding.IsNullValueType = True
            end
            object GridStokViewColumnAd: TcxGridDBColumn
              Caption = 'Ad'
              DataBinding.FieldName = 'AD'
              DataBinding.IsNullValueType = True
              Width = 192
            end
            object GridStokViewColumnTur: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              Width = 37
            end
            object GridStokViewColumnKalan: TcxGridDBColumn
              Caption = 'Kalan'
              DataBinding.FieldName = 'KALAN'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyAdetGenel
              Width = 39
            end
            object GridStokViewColumnFiyat: TcxGridDBColumn
              Caption = 'Fiyat'
              DataBinding.FieldName = 'FIYAT'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepCurrencyBF
              Width = 53
            end
            object GridStokViewColumnKur: TcxGridDBColumn
              Caption = 'Kur'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Width = 24
            end
            object GridStokViewColumnMarka: TcxGridDBColumn
              Caption = 'Marka'
              DataBinding.FieldName = 'STOKMARKA'
              DataBinding.IsNullValueType = True
              Width = 54
            end
            object GridStokViewColumnModel: TcxGridDBColumn
              Caption = 'Model'
              DataBinding.FieldName = 'STOKMODEL'
              DataBinding.IsNullValueType = True
              Width = 47
            end
            object GridStokViewColumnKDV: TcxGridDBColumn
              DataBinding.FieldName = 'KDV'
              DataBinding.IsNullValueType = True
              Width = 28
            end
            object GridStokViewColumnKDVDurum: TcxGridDBColumn
              Caption = 'KDV Durum'
              DataBinding.FieldName = 'KDVDURUM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.RepKDVDurum
              Width = 57
            end
            object GridStokViewColumnBirim: TcxGridDBColumn
              Caption = 'Birim'
              DataBinding.FieldName = 'BIRIM'
              DataBinding.IsNullValueType = True
              RepositoryItem = Tablo.repStokAnaBirim
              Width = 42
            end
            object GridStokViewColumnGRUBU: TcxGridDBColumn
              Caption = 'Grup'
              DataBinding.FieldName = 'STOKGRUBU'
              DataBinding.IsNullValueType = True
              Width = 45
            end
            object GridStokViewColumnIZLEME: TcxGridDBColumn
              Caption = #304'zleme'
              DataBinding.FieldName = 'IZLEME'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <
                item
                  Description = 'Yok'
                  ImageIndex = 0
                  Value = '0'
                end>
              RepositoryItem = Tablo.RepStokIzleme
              Width = 38
            end
            object GridStokViewColumnOZELKOD: TcxGridDBColumn
              Caption = #214'zel Kod'
              DataBinding.FieldName = 'OZELKOD'
              DataBinding.IsNullValueType = True
              Width = 49
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = GridStokView
          end
        end
      end
      object SheetHizmet: TcxTabSheet
        Caption = 'Hizmetler'
        ImageIndex = 4
        object cxDBTreeList1: TcxDBTreeList
          Left = 0
          Top = 0
          Width = 716
          Height = 476
          Align = alClient
          Bands = <
            item
            end>
          DataController.DataSource = DtsHizmetListe
          DataController.ParentField = 'ROOTKOD'
          DataController.KeyField = 'KOD'
          Navigator.Buttons.CustomButtons = <>
          OptionsData.Editing = False
          OptionsData.Deleting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.HideFocusRect = False
          OptionsSelection.InvertSelect = False
          OptionsView.CellEndEllipsis = True
          OptionsView.Indicator = True
          PopupMenu = PmKopyala
          RootValue = -1
          ScrollbarAnnotations.CustomAnnotations = <>
          TabOrder = 0
          OnDblClick = cxDBTreeList1DblClick
          object cxDBTreeList1cxDBTreeListColumnID: TcxDBTreeListColumn
            Visible = False
            Caption.Glyph.SourceDPI = 96
            Caption.Glyph.Data = {
              424D360400000000000036000000280000001000000010000000010020000000
              000000000000C40E0000C40E00000000000000000000FF00FF00FFFFFFFFFFFF
              FFFFFFFFFFFF00FFFFFFFF00FF00FFFFFFFFFF00FF00FFFFFFFFFF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF
              FFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFFF00FF007B7B7BFF7B7B
              7BFFFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000FF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7B7B7BFF7B7B7BFF000000FF7B7B
              7BFF7B7B7BFFFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFFFFFF00
              FF00FFFFFFFFFFFFFFFFFFFFFFFFFF00FF00FFFFFFFFFFFFFFFF7B7B7BFF0000
              00FF7B7B7BFFFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF
              FFFFFFFFFFFFFFFFFFFFFF00FF00FFFFFFFFFFFFFFFF00FFFFFFFF00FF000000
              00FF7B7B7BFF7B7B7BFFFF00FF00FF00FF00FF00FF00FF00FF00FFFFFFFFFF00
              FF0000FFFFFF7B7B7BFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7B7B7BFF0000
              00FF7B7B7BFF7B7B7BFFFF00FF00FF00FF00FF00FF00FFFFFFFFFF00FF00FFFF
              FFFFFF00FF007B7B7BFFFFFFFFFF00FFFFFFFFFFFFFFFF00FF00000000FF7B7B
              7BFF000000FF7B7B7BFFFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00000000FF7B7B7BFFFF00FF007B7B7BFF000000FFFF00FF007B7B
              7BFF000000FF7B7B7BFF7B7B7BFFFF00FF00FF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00000000FF000000FF000000FFFFFFFFFFFF00FF000000
              00FF7B7B7BFF000000FF7B7B7BFF7B7B7BFFFF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000FF000000FFFFFF
              FFFFFF00FF007B7B7BFF000000FF7B7B7BFF7B7B7BFFFF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
              00FFFFFFFFFFFF00FF007B7B7BFF000000FF7B7B7BFFFF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
              FF00000000FFFFFFFFFFFF00FF007B7B7BFF000000FFFF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00000000FFFFFFFFFFFF00FF007B7B7BFFFF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00000000FFFFFFFFFFFF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00000000FF000000FFFF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
              FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
            Caption.Text = 'Kur'
            DataBinding.FieldName = 'ID'
            Width = 44
            Position.ColIndex = 0
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnKod: TcxDBTreeListColumn
            Caption.Text = 'Kod'
            DataBinding.FieldName = 'KOD'
            Width = 112
            Position.ColIndex = 1
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnAd: TcxDBTreeListColumn
            Caption.Text = 'Ad'
            DataBinding.FieldName = 'AD'
            Width = 192
            Position.ColIndex = 2
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnTur: TcxDBTreeListColumn
            Caption.Text = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            Width = 37
            Position.ColIndex = 3
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnKalan: TcxDBTreeListColumn
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Caption.Text = 'Kalan'
            DataBinding.FieldName = 'KALAN'
            Width = 39
            Position.ColIndex = 7
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnFiyat: TcxDBTreeListColumn
            RepositoryItem = Tablo.RepCurrencyBF
            Caption.Text = 'Fiyat'
            DataBinding.FieldName = 'FIYAT'
            Width = 53
            Position.ColIndex = 9
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnKur: TcxDBTreeListColumn
            Caption.Text = 'Kur'
            DataBinding.FieldName = 'KUR'
            Width = 24
            Position.ColIndex = 10
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnMarka: TcxDBTreeListColumn
            Caption.Text = 'Marka'
            DataBinding.FieldName = 'STOKMARKA'
            Width = 54
            Position.ColIndex = 4
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnModel: TcxDBTreeListColumn
            Caption.Text = 'Model'
            DataBinding.FieldName = 'STOKMODEL'
            Width = 47
            Position.ColIndex = 5
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnKDV: TcxDBTreeListColumn
            DataBinding.FieldName = 'KDV'
            Width = 28
            Position.ColIndex = 11
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnKDVDurum: TcxDBTreeListColumn
            RepositoryItem = Tablo.RepKDVDurum
            Caption.Text = 'KDV Durum'
            DataBinding.FieldName = 'KDVDURUM'
            Width = 57
            Position.ColIndex = 12
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnBirim: TcxDBTreeListColumn
            RepositoryItem = Tablo.repStokAnaBirim
            Caption.Text = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            Width = 42
            Position.ColIndex = 8
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnGRUBU: TcxDBTreeListColumn
            Caption.Text = 'Grup'
            DataBinding.FieldName = 'STOKGRUBU'
            Width = 45
            Position.ColIndex = 6
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListIZLEME: TcxDBTreeListColumn
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                Description = 'Yok'
                ImageIndex = 0
                Value = '0'
              end>
            RepositoryItem = Tablo.RepStokIzleme
            Caption.Text = #304'zleme'
            DataBinding.FieldName = 'IZLEME'
            Width = 38
            Position.ColIndex = 13
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
          object cxDBTreeList1cxDBTreeListColumnOZELKOD: TcxDBTreeListColumn
            Caption.Text = #214'zel Kod'
            DataBinding.FieldName = 'OZELKOD'
            Width = 49
            Position.ColIndex = 14
            Position.RowIndex = 0
            Position.BandIndex = 0
            Summary.FooterSummaryItems = <>
            Summary.GroupFooterSummaryItems = <>
          end
        end
      end
      object SheetDagitim: TcxTabSheet
        Caption = 'Da'#287#305't'#305'm'
        ImageIndex = 4
        object GridDagitim: TcxGrid
          Left = 0
          Top = 0
          Width = 716
          Height = 476
          Align = alClient
          TabOrder = 0
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridDagitimView: TcxGridDBTableView
            OnDblClick = BtnSecClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsTabDagitim
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                Position = spFooter
                FieldName = 'TEKLIF_TUTARI'
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                Position = spFooter
              end
              item
                Format = ',0.00;-,0.00'
                Kind = skSum
                Position = spFooter
              end
              item
                Format = 'Say'#305' :  ######'
                Kind = skCount
                Position = spFooter
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'TEKLIF_MATRAHI'
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'KDV_TUTARI'
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'TEKLIF_TUTARI'
              end
              item
                Format = 'Say'#305' :  ######'
                Kind = skCount
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsData.Deleting = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.MultiSelect = True
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.Indicator = True
            object GridDagitimKOD: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Width = 92
            end
            object GridDagitimAD: TcxGridDBColumn
              Caption = 'Ad'
              DataBinding.FieldName = 'AD'
              DataBinding.IsNullValueType = True
              Width = 141
            end
            object GridDagitimBASLAMATARIHI: TcxGridDBColumn
              Caption = 'Ba'#351'lama Tarihi'
              DataBinding.FieldName = 'BASLAMATARIHI'
              DataBinding.IsNullValueType = True
              Width = 96
            end
          end
          object GridDagitimLevel1: TcxGridLevel
            GridView = GridDagitimView
          end
        end
      end
    end
    object cbStokDepo: TcxImageComboBox
      Left = 487
      Top = 1
      RepositoryItem = Tablo.RepStokDepolarTumu
      Enabled = False
      Properties.ImmediatePost = True
      Properties.Items = <>
      Properties.OnEditValueChanged = cbFiyatAdiPropertiesEditValueChanged
      TabOrder = 4
      Width = 98
    end
    object LabelYer: TcxLabel
      Left = 452
      Top = 3
      Caption = 'Depo'
      Transparent = True
    end
    object cbFiyatAdi: TcxImageComboBox
      Left = 358
      Top = 1
      RepositoryItem = Tablo.RepFiyatAdlari
      Properties.ImmediatePost = True
      Properties.Items = <>
      Properties.OnEditValueChanged = cbFiyatAdiPropertiesEditValueChanged
      TabOrder = 2
      Width = 91
    end
    object lbFiyatAdi: TcxLabel
      Left = 324
      Top = 3
      Caption = 'Fiyat'
      Transparent = True
    end
    object PanelSag: TPanel
      Left = 733
      Top = 1
      Width = 377
      Height = 505
      Align = alRight
      Caption = 'PanelSag'
      TabOrder = 1
      object LogoResim: TcxImage
        Left = 1
        Top = 383
        Align = alBottom
        Properties.GraphicClassName = 'TdxSmartImage'
        Style.BorderColor = clBtnFace
        Style.Color = clBtnFace
        Style.Edges = []
        StyleDisabled.BorderStyle = ebsNone
        StyleFocused.BorderStyle = ebsNone
        TabOrder = 2
        Height = 121
        Width = 375
      end
      object Panel4: TPanel
        Left = 1
        Top = 1
        Width = 375
        Height = 63
        Align = alTop
        TabOrder = 0
        object LabelSonEklenen: TcxLabel
          Left = 1
          Top = 1
          Align = alTop
          AutoSize = False
          Properties.WordWrap = True
          Transparent = True
          Height = 39
          Width = 373
        end
        object rdMusteri: TcxRadioButton
          Left = 1
          Top = 45
          Width = 85
          Height = 17
          Caption = 'Bu Cari'
          TabOrder = 1
          OnClick = rdMusteriClick
          Transparent = True
        end
        object rdTumu: TcxRadioButton
          Left = 93
          Top = 45
          Width = 85
          Height = 17
          Caption = 'T'#252'm'#252
          Checked = True
          TabOrder = 2
          TabStop = True
          OnClick = rdMusteriClick
          Transparent = True
        end
      end
      object cxGrid1: TcxGrid
        Left = 1
        Top = 64
        Width = 375
        Height = 319
        Align = alClient
        TabOrder = 1
        LevelTabs.CaptionAlignment = taLeftJustify
        LookAndFeel.ScrollbarMode = sbmClassic
        RootLevelOptions.DetailTabsPosition = dtpTop
        OnActiveTabChanged = cxGrid1ActiveTabChanged
        object cxGrid1DBTableViewDurum: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsStokDurumDetay
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          Styles.OnGetContentStyle = cxGrid1DBTableViewDurumStylesGetContentStyle
          Styles.Inactive = Tablo.cxstSecili
          object cxGrid1DBTableViewDurumTIP: TcxGridDBColumn
            Caption = 'Tip'
            DataBinding.FieldName = 'TIP'
            DataBinding.IsNullValueType = True
            Width = 106
          end
          object cxGrid1DBTableViewDurumADET: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
            Width = 69
          end
          object cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repStokAnaBirim
            Width = 63
          end
        end
        object cxGrid1DBCardViewAlislar: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSonAlislar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.CellSelect = False
          OptionsSelection.CardBorderSelection = False
          OptionsSelection.HideSelection = True
          OptionsSelection.InvertSelect = False
          OptionsView.CellEndEllipsis = True
          OptionsView.NavigatorOffset = 10
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 1
          OptionsView.CardWidth = 300
          OptionsView.SeparatorWidth = 0
          object cxGrid1DBCardViewAlislarBASLIK: TcxGridDBCardViewRow
            Caption = 'Cari'
            DataBinding.FieldName = 'BASLIK'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
          object cxGrid1DBCardViewAlislarBELGETIPI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'BELGETIPI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 45
            IsCaptionAssigned = True
          end
          object cxGrid1DBCardViewAlislarFATURATARIH: TcxGridDBCardViewRow
            Caption = 'Tarih'
            DataBinding.FieldName = 'FATURATARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 40
          end
          object cxGrid1DBCardViewAlislarMIKTAR: TcxGridDBCardViewRow
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Filtering = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewAlislarBIRIMTUTAR: TcxGridDBCardViewRow
            Caption = 'Tutar'
            DataBinding.FieldName = 'BIRIMTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewAlislarKUR: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewAlislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow
            Caption = 'D'#246'viz'
            DataBinding.FieldName = 'BIRIMTUTARDOVIZ'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewAlislarDOVIZ_KURU: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'DOVIZ_KURU'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
        end
        object cxGrid1DBCardViewSatislar: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSonSatislar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsSelection.CellSelect = False
          OptionsSelection.CardBorderSelection = False
          OptionsSelection.HideSelection = True
          OptionsSelection.InvertSelect = False
          OptionsView.CellEndEllipsis = True
          OptionsView.NavigatorOffset = 10
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 1
          OptionsView.CardWidth = 300
          OptionsView.SeparatorWidth = 0
          object cxGrid1DBCardViewSatislarBASLIK: TcxGridDBCardViewRow
            Caption = 'Cari'
            DataBinding.FieldName = 'BASLIK'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
          end
          object cxGrid1DBCardViewSatislarBELGETIPI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'BELGETIPI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 45
            IsCaptionAssigned = True
          end
          object cxGrid1DBCardViewSatislarFATURATARIH: TcxGridDBCardViewRow
            Caption = 'Tarih'
            DataBinding.FieldName = 'FATURATARIH'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.ShowTime = False
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 40
          end
          object cxGrid1DBCardViewSatislarMIKTAR: TcxGridDBCardViewRow
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Filtering = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewSatislarBIRIMTUTAR: TcxGridDBCardViewRow
            Caption = 'Tutar'
            DataBinding.FieldName = 'BIRIMTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewSatislarKUR: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
          object cxGrid1DBCardViewSatislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow
            Caption = 'D'#246'viz'
            DataBinding.FieldName = 'BIRIMTUTARDOVIZ'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 40
          end
          object cxGrid1DBCardViewSatislarDOVIZ_KURU: TcxGridDBCardViewRow
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'DOVIZ_KURU'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 20
          end
        end
        object cxGrid1DBTableViewMaliyetler: TcxGridDBTableView
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
          DataController.DataSource = DtsMaliyetler
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
          object cxGrid1DBTableViewMaliyetlerTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            DataBinding.IsNullValueType = True
            Width = 111
          end
          object cxGrid1DBTableViewMaliyetlerMALIYET: TcxGridDBColumn
            Caption = 'Maliyet'
            DataBinding.FieldName = 'MALIYET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            Width = 95
          end
          object cxGrid1DBTableViewMaliyetlerKUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 52
          end
        end
        object cxGrid1DBTableViewUretim: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsUretim
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGrid1DBTableViewUretimKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Width = 59
          end
          object cxGrid1DBTableViewUretimSTOKADI: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'STOKADI'
            DataBinding.IsNullValueType = True
            Width = 166
          end
          object cxGrid1DBTableViewUretimMIKTAR: TcxGridDBColumn
            Caption = 'Gereken'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
          end
          object cxGrid1DBTableViewUretimKALAN: TcxGridDBColumn
            Caption = 'Kalan'
            DataBinding.FieldName = 'KALAN'
            DataBinding.IsNullValueType = True
          end
        end
        object cxGrid1DBTableViewTeklif: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsSonTeklifler
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGrid1DBTableViewTeklifColumnBASLIK: TcxGridDBColumn
            Caption = 'Cari'
            DataBinding.FieldName = 'BASLIK'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 100
            Width = 100
          end
          object cxGrid1DBTableViewTeklifColumnTARIH: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'TARIH'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 64
          end
          object cxGrid1DBTableViewTeklifColumnMIKTAR: TcxGridDBColumn
            Caption = 'Miktar'
            DataBinding.FieldName = 'MIKTAR'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 30
            Width = 30
          end
          object cxGrid1DBTableViewTeklifColumnBIRIMTUTAR: TcxGridDBColumn
            Caption = 'Birim Tutar'
            DataBinding.FieldName = 'BIRIMTUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            BestFitMaxWidth = 60
            Width = 60
          end
          object cxGrid1DBTableViewTeklifColumnKUR: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 30
            Width = 30
          end
          object cxGrid1DBTableViewTeklifColumnBIRIMTUTARDOVIZ: TcxGridDBColumn
            Caption = 'Doviz Birim Tutar'
            DataBinding.FieldName = 'BIRIMTUTARDOVIZ'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyBF
            BestFitMaxWidth = 60
            Width = 60
          end
          object cxGrid1DBTableViewTeklifColumnDOVIZ_KURU: TcxGridDBColumn
            Caption = 'Doviz Kur'
            DataBinding.FieldName = 'DOVIZ_KURU'
            DataBinding.IsNullValueType = True
            BestFitMaxWidth = 30
            Width = 30
          end
        end
        object cxGrid1LevelDepoDurumu: TcxGridLevel
          Caption = 'Depo Durumu'
          GridView = cxGrid1DBTableViewDurum
        end
        object cxGrid1LevelSonAlislar: TcxGridLevel
          Caption = 'Son Al'#305#351'lar'
          GridView = cxGrid1DBCardViewAlislar
        end
        object cxGrid1LevelSonSatislar: TcxGridLevel
          Caption = 'Son Sat'#305#351'lar'
          GridView = cxGrid1DBCardViewSatislar
        end
        object cxGrid1LevelMaliyetler: TcxGridLevel
          Caption = 'Maliyetler'
          GridView = cxGrid1DBTableViewMaliyetler
        end
        object cxGrid1LevelUretim: TcxGridLevel
          Caption = #220'retim'
          GridView = cxGrid1DBTableViewUretim
        end
        object cxGrid1LevelTeklif: TcxGridLevel
          Caption = 'Teklifler'
          GridView = cxGrid1DBTableViewTeklif
        end
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 725
      Top = 1
      Width = 8
      Height = 505
      HotZoneClassName = 'TcxMediaPlayer8Style'
      AlignSplitter = salRight
      Control = PanelSag
      OnAfterOpen = cxSplitter1AfterOpen
      Color = clGreen
      ParentColor = False
    end
    object cbBuFirma: TcxCheckBox
      Left = 758
      Top = 1
      Caption = 'Sadece bu firma '#252'r'#252'nleri'
      TabOrder = 6
      Transparent = True
    end
    object cbOlmayanlar: TcxCheckBox
      Left = 604
      Top = 0
      Caption = 'Kalmayanlar'#305' da g'#246'ster'
      TabOrder = 5
      Transparent = True
    end
  end
  object TabStokListe: TFDQuery
    AfterScroll = TabStokListeAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @RehberID int'
      'set @RehberID=48'
      ''
      'select '
      #9'ID='#39'P'#39'+CONVERT(varchar(10),ID),'
      #9'ROOTID='#39'-'#39','
      #9'TUR='#39'Paket'#39','
      #9'BIRIM='#39'Paket'#39','
      #9'ADET=1,'
      #9'MIKTAR=1,'
      
        #9'ACIKLAMA='#39'Transfer ID:'#39'+convert(varchar(20),isnull(TRANSFERID,0' +
        ')) '
      'from ITS_PAKET WHERE REHBERID=@RehberID'
      'union all'
      'select '
      #9'ID='#39'T'#39'+CONVERT(varchar(10),ID),'
      
        #9'ROOTID=case when ID=USTID then '#39'P'#39'+CONVERT(varchar(10),PAKETID)' +
        ' else '#39'T'#39'+CONVERT(varchar(10),USTID)end,'
      
        #9'TUR=case TASIMA_BIRIMI when'#39'P'#39'then'#39'Palet'#39'when'#39'C'#39'then'#39'Koli'#39'when'#39 +
        'S'#39'then'#39'Ba'#287#39'when'#39'B'#39'then'#39'Koli '#304#231'i Kutu'#39'when'#39'E'#39'then'#39'K'#252#231#252'k Ba'#287#39'end,'
      
        #9'BIRIM=case TASIMA_BIRIMI when'#39'P'#39'then'#39'Palet'#39'when'#39'C'#39'then'#39'Koli'#39'whe' +
        'n'#39'S'#39'then'#39'Ba'#287#39'when'#39'B'#39'then'#39'Koli '#304#231'i Kutu'#39'when'#39'E'#39'then'#39'K'#252#231#252'k Ba'#287#39'end' +
        ','
      #9'ADET=1,'
      
        #9'MIKTAR=(select count(*) from STOKID SI where SI.TASIMA_BIRIMI_I' +
        'D=ITB.ID),'
      #9'ACIKLAMA='#39'SSCC:'#39'+SSCC '
      'from ITS_TASIMA_BIRIMI ITB'
      'WHERE PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID )'
      'union all'
      ''
      'SELECT '
      
        #9'ID='#39'S'#39'+CONVERT(varchar(10),S.ID)+'#39'T'#39'+CONVERT(varchar(10),SI.TAS' +
        'IMA_BIRIMI_ID),'
      #9'ROOTID='#39'T'#39'+CONVERT(varchar(10),SI.TASIMA_BIRIMI_ID),'
      #9'TUR='#39'Stok'#39','
      
        #9'BIRIM=(select ANAHTAR from GENINI where BOLUM=-2702 and DEGER=c' +
        'onvert(varchar(5),S.ANABIRIM)),'
      #9'ADET=COUNT(distinct SI.TASIMA_BIRIMI_ID),'
      #9'MIKTAR=COUNT(*),'
      #9'ACIKLAMA='#39'Stok:'#39'+S.STOKADI  '
      'FROM STOKID SI inner join STOKLAR S on SI.STOKID=S.ID'
      'WHERE TASIMA_BIRIMI_ID IN'
      '(select ID from ITS_TASIMA_BIRIMI WHERE PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID ))'
      'AND PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID )'
      'GROUP BY S.ID,SI.TASIMA_BIRIMI_ID,S.ANABIRIM,S.STOKADI'
      'union all'
      ''
      '--select * from STOKID'
      'SELECT '
      #9'ID='#39'I'#39'+CONVERT(varchar(10),SI.ID),'
      
        #9'ROOTID='#39'S'#39'+CONVERT(varchar(10),S.ID)+'#39'T'#39'+CONVERT(varchar(10),SI' +
        '.TASIMA_BIRIMI_ID),'
      #9'TUR='#39'S'#305'rano'#39','
      
        #9'BIRIM=(select ANAHTAR from GENINI where BOLUM=-2702  and DEGER=' +
        'convert(varchar(5),S.ANABIRIM)),'
      #9'ADET=1,'
      #9'MIKTAR=1,'
      #9'ACIKLAMA='#39'S'#305'rano:'#39'+SI.SIRANO  '
      'FROM STOKID SI inner join STOKLAR S on SI.STOKID=S.ID'
      'WHERE TASIMA_BIRIMI_ID IN'
      '(select ID from ITS_TASIMA_BIRIMI WHERE PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID ))'
      'AND PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID )'
      '')
    Left = 413
    Top = 280
  end
  object TabPaket: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @PaketID int'
      'declare @FiyatAdi int'
      'declare @DepoID int'
      'declare @AdetID int'
      'set @PaketID = :P1'
      'set @FiyatAdi = :P2'
      'set @DepoID = :P3'
      
        'select @AdetID=CONVERT(int,DEGER) from GENINI where BOLUM=-2702 ' +
        'and ANAHTAR='#39'Adet'#39
      'select '
      #9'ID=isnull(S.ID,0),'
      #9'S.KOD,'
      #9'AD=S.STOKADI,'
      #9'FIYAT=isnull(SF.FIYAT,-1),'
      #9'SF.KUR,'
      #9'S.KDV,'
      #9'SF.KDVDURUM,'
      #9'S.IZLEME,'
      
        #9'KALAN=isnull((select SUM(SD.KALAN) from STOKDURUM SD where SD.S' +
        'TOKID=S.ID and SD.DEPOID=@DepoID),0),'
      #9'SF.BIRIM,'
      #9'PD.STOK,'
      #9'PD.ADET'
      'from '
      #9'PAKETDETAY PD left outer join '
      #9'STOKLAR S on PD.URUNID=S.ID left outer join '
      #9'STOKFIYAT SF on  SF.STOKID=S.ID and SF.BIRIM=PD.BIRIM '
      '      --SF.PAKETID=@PaketID and'
      #9
      'where PD.PAKETID=@PaketID '
      'and PD.STOK=1'
      'and SF.FIYATADI=@FiyatAdi'
      ''
      'union all'
      ''
      'select '
      #9'ID=isnull(M.ID,0),'
      #9'M.KOD,'
      #9'AD=M.AD,'
      #9'FIYAT=isnull(F.FIYAT,-1),'
      #9'F.KUR,'
      #9'isnull(M.KDV,0),'
      #9'F.KDVDURUM,'
      #9'IZLEME=0,'
      #9'KALAN=999999,'
      #9'BIRIM=@AdetID,'
      #9'PD.STOK,'
      #9'PD.ADET'
      'from '
      #9'PAKETDETAY PD left outer join '
      #9'MASRAFGELIR M on PD.URUNID=M.ID left outer join '
      #9'FIYATLAR F on F.FIYATADI=@FiyatAdi and F.HIZMETID=M.ID'
      #9
      'where PD.PAKETID=@PaketID '
      'and PD.STOK=0'
      'and F.FIYATADI=@FiyatAdi'
      '')
    Left = 540
    Top = 232
  end
  object DtsStokListe: TDataSource
    DataSet = TabStokListe
    Left = 412
    Top = 324
  end
  object PmKopyala: TPopupMenu
    Left = 592
    Top = 192
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      OnClick = Kopyala1Click
    end
  end
  object DtsStokDurumDetay: TDataSource
    DataSet = TabStokDurumDetay
    Left = 201
    Top = 183
  end
  object TabStokDurumDetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from fn_StokDurumDetay(:PStokID,:PDepoID)')
    Left = 201
    Top = 136
  end
  object TabSonSatislar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      '--sat'#305#351
      'declare @URUNID int, @URUNTUR int, @RehberID int'
      'set @URUNID = :PUrunID'
      'set @URUNTUR = :PUrunTur'
      'set @REHBERID = :PRehberID'
      ''
      'select * from ('
      'select top 10 FB.FATURATARIH,'
      'BELGETIPI= case when FB.TUR = 16 '
      '    then '#39'Fi'#351#39' else '#39'Fatura'#39' end,'
      'BASLIK=R.FIRMA, '
      'BIRIMTUTAR=F.TUTAR/F.MIKTAR,F.KUR,'
      'BIRIMTUTARDOVIZ=F.DOVIZ_TUTARI/F.MIKTAR,F.DOVIZ_KURU,'
      'F.MIKTAR,'
      'FB.TARIH,FB.TUR,FB.ID'
      'from FATBASLIK FB '
      'inner join FATURA F on FB.ID=F.FATBASID'
      'inner join REHBER R on R.ID=FB.REHBERID'
      'where '
      #9'(FB.TUR = 15 or  FB.TUR = 16) and'
      #9'F.TUR = @URUNTUR and '
      #9'F.MIKTAR > 0 and'
      #9'F.URUNID = @URUNID and '
      #9'1 = case when @RehberID=0 then 1'
      #9#9#9'when @RehberID=FB.REHBERID then 1 '
      #9#9#9'else 0 end'
      'order by FB.FATURATARIH desc) as dd')
    Left = 112
    Top = 134
  end
  object DtsSonSatislar: TDataSource
    DataSet = TabSonSatislar
    Left = 111
    Top = 180
  end
  object TabSonAlislar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      '--al'#305#351
      'declare @URUNID int, @URUNTUR int, @RehberID int'
      'set @URUNID = :PUrunID'
      'set @URUNTUR = :PUrunTur'
      'set @REHBERID = :PRehberID'
      'select * from ('
      'select top 10 FB.FATURATARIH,'
      'BELGETIPI= case when FB.TUR = 12 then '#39'Fi'#351#39' else '#39'Fatura'#39' end,'
      'BASLIK=R.FIRMA, '
      'BIRIMTUTAR=F.TUTAR/F.MIKTAR,F.KUR,'
      'BIRIMTUTARDOVIZ=F.DOVIZ_TUTARI/F.MIKTAR,F.DOVIZ_KURU,'
      'F.MIKTAR,'
      'FB.TARIH,FB.TUR,FB.ID'
      'from FATBASLIK FB '
      'inner join FATURA F on FB.ID=F.FATBASID'
      'inner join REHBER R on R.ID=FB.REHBERID'
      'where'
      #9'(FB.TUR = 11 or FB.TUR = 12) and'
      #9'F.TUR = @URUNTUR and'
      #9'F.MIKTAR > 0 and'
      #9'F.URUNID = @URUNID'
      #9'and 1 = case when @RehberID=0 then 1'
      #9#9#9'when @RehberID=FB.REHBERID then 1'
      #9#9#9'else 0 end'
      'order by FB.FATURATARIH desc) as dd')
    Left = 32
    Top = 137
  end
  object DtsSonAlislar: TDataSource
    DataSet = TabSonAlislar
    Left = 32
    Top = 181
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 681
    Top = 192
  end
  object tabMaliyetler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      '--select * from STOKMALIYET where STOKID = PStokID'
      ''
      'Select distinct ID=STOKID,FIYATADI,'
      
        'TUR=(select top 1 case when DEGER=-2 then ANAHTAR +'#39' (Son'#39'+cast(' +
        'PAKETID as varchar(5))+'#39')'#39' '
      
        'else ANAHTAR end from GENINI where BOLUM=-1008 and DEGER=FIYATAD' +
        'I),'
      'MALIYET=FIYAT,KUR,KDVDURUM from STOKFIYAT Where STOKID=:PrmId '
      'and SATIS=0 and FIYATADI < 0 '
      ''
      '')
    Left = 296
    Top = 134
  end
  object DtsMaliyetler: TDataSource
    DataSet = tabMaliyetler
    Left = 295
    Top = 188
  end
  object TabDagitim: TFDQuery
    Connection = Tablo.FDCnn
    Left = 376
    Top = 136
  end
  object DtsTabDagitim: TDataSource
    DataSet = TabDagitim
    Left = 375
    Top = 188
  end
  object DtsKategori: TDataSource
    DataSet = TabKategori
    Left = 229
    Top = 269
  end
  object TabKategori: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        ' select ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX('#39'.'#39',RE' +
        'VERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX('#39'.'#39',REVERSE(KOD),1)-1))), '
      '   ID,KOD,AD,DURUM from KATEGORI')
    Left = 269
    Top = 327
  end
  object TabHizmetListe: TFDQuery
    AfterScroll = TabStokListeAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @RehberID int'
      'set @RehberID=48'
      ''
      'select '
      #9'ID='#39'P'#39'+CONVERT(varchar(10),ID),'
      #9'ROOTID='#39'-'#39','
      #9'TUR='#39'Paket'#39','
      #9'BIRIM='#39'Paket'#39','
      #9'ADET=1,'
      #9'MIKTAR=1,'
      
        #9'ACIKLAMA='#39'Transfer ID:'#39'+convert(varchar(20),isnull(TRANSFERID,0' +
        ')) '
      'from ITS_PAKET WHERE REHBERID=@RehberID'
      'union all'
      'select '
      #9'ID='#39'T'#39'+CONVERT(varchar(10),ID),'
      
        #9'ROOTID=case when ID=USTID then '#39'P'#39'+CONVERT(varchar(10),PAKETID)' +
        ' else '#39'T'#39'+CONVERT(varchar(10),USTID)end,'
      
        #9'TUR=case TASIMA_BIRIMI when'#39'P'#39'then'#39'Palet'#39'when'#39'C'#39'then'#39'Koli'#39'when'#39 +
        'S'#39'then'#39'Ba'#287#39'when'#39'B'#39'then'#39'Koli '#304#231'i Kutu'#39'when'#39'E'#39'then'#39'K'#252#231#252'k Ba'#287#39'end,'
      
        #9'BIRIM=case TASIMA_BIRIMI when'#39'P'#39'then'#39'Palet'#39'when'#39'C'#39'then'#39'Koli'#39'whe' +
        'n'#39'S'#39'then'#39'Ba'#287#39'when'#39'B'#39'then'#39'Koli '#304#231'i Kutu'#39'when'#39'E'#39'then'#39'K'#252#231#252'k Ba'#287#39'end' +
        ','
      #9'ADET=1,'
      
        #9'MIKTAR=(select count(*) from STOKID SI where SI.TASIMA_BIRIMI_I' +
        'D=ITB.ID),'
      #9'ACIKLAMA='#39'SSCC:'#39'+SSCC '
      'from ITS_TASIMA_BIRIMI ITB'
      'WHERE PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID )'
      'union all'
      ''
      'SELECT '
      
        #9'ID='#39'S'#39'+CONVERT(varchar(10),S.ID)+'#39'T'#39'+CONVERT(varchar(10),SI.TAS' +
        'IMA_BIRIMI_ID),'
      #9'ROOTID='#39'T'#39'+CONVERT(varchar(10),SI.TASIMA_BIRIMI_ID),'
      #9'TUR='#39'Stok'#39','
      
        #9'BIRIM=(select ANAHTAR from GENINI where BOLUM=-2702 and DEGER=c' +
        'onvert(varchar(5),S.ANABIRIM)),'
      #9'ADET=COUNT(distinct SI.TASIMA_BIRIMI_ID),'
      #9'MIKTAR=COUNT(*),'
      #9'ACIKLAMA='#39'Stok:'#39'+S.STOKADI  '
      'FROM STOKID SI inner join STOKLAR S on SI.STOKID=S.ID'
      'WHERE TASIMA_BIRIMI_ID IN'
      '(select ID from ITS_TASIMA_BIRIMI WHERE PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID ))'
      'AND PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID )'
      'GROUP BY S.ID,SI.TASIMA_BIRIMI_ID,S.ANABIRIM,S.STOKADI'
      'union all'
      ''
      '--select * from STOKID'
      'SELECT '
      #9'ID='#39'I'#39'+CONVERT(varchar(10),SI.ID),'
      
        #9'ROOTID='#39'S'#39'+CONVERT(varchar(10),S.ID)+'#39'T'#39'+CONVERT(varchar(10),SI' +
        '.TASIMA_BIRIMI_ID),'
      #9'TUR='#39'S'#305'rano'#39','
      
        #9'BIRIM=(select ANAHTAR from GENINI where BOLUM=-2702  and DEGER=' +
        'convert(varchar(5),S.ANABIRIM)),'
      #9'ADET=1,'
      #9'MIKTAR=1,'
      #9'ACIKLAMA='#39'S'#305'rano:'#39'+SI.SIRANO  '
      'FROM STOKID SI inner join STOKLAR S on SI.STOKID=S.ID'
      'WHERE TASIMA_BIRIMI_ID IN'
      '(select ID from ITS_TASIMA_BIRIMI WHERE PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID ))'
      'AND PAKETID IN '
      '(select ID from ITS_PAKET WHERE REHBERID=@RehberID )'
      '')
    Left = 493
    Top = 288
  end
  object DtsHizmetListe: TDataSource
    DataSet = TabHizmetListe
    Left = 492
    Top = 332
  end
  object TabUretim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select S.KOD,S.STOKADI,URD.MIKTAR,KALAN=sum(SD.KALAN) '
      'from '
      #9'URETIMRECETE UR inner join '
      #9'URETIMRECETEDETAY URD on UR.ID=URD.URETIMRECETEID inner join '
      #9'STOKLAR S on S.ID=URD.URUNID inner join '
      #9'STOKDURUM SD on S.ID=SD.STOKID'
      'where URD.MIKTAR<0.0 and UR.STOKID=:PStokID '
      'group by S.KOD,S.STOKADI,URD.MIKTAR')
    Left = 438
    Top = 135
  end
  object DtsUretim: TDataSource
    DataSet = TabUretim
    Left = 437
    Top = 189
  end
  object TabSonTeklifler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @URUNID int, @URUNTUR int, @RehberID int'
      'set @URUNID = :PUrunID'
      'set @URUNTUR = :PUrunTur'
      'set @REHBERID = :PRehberID'
      'select * from ('
      'select top 10 FB.TARIH,'
      'BASLIK=(select R.FIRMA from REHBER R where R.ID=FB.REHBERID),'
      'BIRIMTUTAR=F.TUTAR/F.MIKTAR,F.KUR,'
      'BIRIMTUTARDOVIZ=F.DOVIZ_TUTARI/F.MIKTAR,F.DOVIZ_KURU,'
      'F.MIKTAR,FB.ID'
      'from TEKLIF FB inner join TEKLIFDETAY F on FB.ID=F.TEKLIFID'
      'where'
      #9'F.TUR = @URUNTUR and'
      #9'F.MIKTAR > 0 and'
      #9'F.URUNID = @URUNID'
      #9'and 1 = case when @RehberID=0 then 1'
      #9#9#9'when @RehberID=FB.REHBERID then 1'
      #9#9#9'else 0 end'
      'order by FB.TARIH desc) as dd')
    Left = 496
    Top = 137
  end
  object DtsSonTeklifler: TDataSource
    DataSet = TabSonTeklifler
    Left = 496
    Top = 181
  end
end
