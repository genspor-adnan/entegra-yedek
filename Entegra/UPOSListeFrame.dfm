object POSListeFrame: TPOSListeFrame
  Left = 0
  Top = 0
  Width = 1221
  Height = 482
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object BeniDegistir: TPanel
    Left = 0
    Top = 0
    Width = 1221
    Height = 482
    Align = alClient
    TabOrder = 0
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1213
      Height = 29
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 74
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
      object YeniTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 7
        ImageName = 'PngImage6'
        OnClick = YeniTusClick
      end
      object SilTus: TToolButton
        Left = 74
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        ImageName = 'PngImage7'
        OnClick = SilTusClick
      end
      object ToolButton1: TToolButton
        Left = 148
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 10
        ImageName = 'PngImage9'
        Style = tbsSeparator
      end
      object DegisTus: TToolButton
        Left = 156
        Top = 0
        Caption = 'D'#252'zenle'
        ImageIndex = 9
        ImageName = 'PngImage8'
        Style = tbsTextButton
        OnClick = DegisTusClick
      end
    end
    object cxGrid: TcxGrid
      Left = 1
      Top = 33
      Width = 1219
      Height = 133
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      PopupMenu = PosListeMenu
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      ExplicitTop = 36
      ExplicitHeight = 130
      object GridTview: TcxGridDBTableView
        PopupMenu = PosListeMenu
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = GridTviewCanFocusRecord
        OnCellDblClick = GridTviewCellDblClick
        OnSelectionChanged = GridTviewSelectionChanged
        DataController.DataSource = DtsPOS
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <
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
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
          end>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
          end
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
          end
          item
            Format = ',0.00;(,0.00)'
            Kind = skSum
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.CellAutoHeight = True
        OptionsView.Footer = True
        OptionsView.GroupFooters = gfAlwaysVisible
        OptionsView.Indicator = True
        object GridTviewKODU: TcxGridDBColumn
          Caption = 'Kodu'
          DataBinding.FieldName = 'KODU'
          DataBinding.IsNullValueType = True
        end
        object GridTviewADI: TcxGridDBColumn
          Caption = 'Ad'#305
          DataBinding.FieldName = 'ADI'
          DataBinding.IsNullValueType = True
          Width = 142
        end
        object GridTviewLOGO: TcxGridDBColumn
          DataBinding.FieldName = 'LOGO'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageProperties'
          Properties.GraphicClassName = 'TdxPNGImage'
          IsCaptionAssigned = True
        end
        object GridTviewBANKAADI: TcxGridDBColumn
          Caption = 'Banka'
          DataBinding.FieldName = 'BANKAADI'
          DataBinding.IsNullValueType = True
          Width = 133
        end
        object GridTviewID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          DataBinding.IsNullValueType = True
          Visible = False
        end
        object GridTviewNOSU: TcxGridDBColumn
          Caption = 'No'
          DataBinding.FieldName = 'NOSU'
          DataBinding.IsNullValueType = True
          Width = 118
        end
        object GridTviewDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          DataBinding.IsNullValueType = True
        end
        object GridTviewSUBEID: TcxGridDBColumn
          Caption = #350'ube'
          DataBinding.FieldName = 'SUBEID'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <>
          RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = GridTview
      end
    end
    object PageControlSekme: TcxPageControl
      Left = 1
      Top = 174
      Width = 1219
      Height = 307
      Align = alBottom
      TabOrder = 2
      Properties.ActivePage = TabSheetEkstre
      Properties.CustomButtons.Buttons = <>
      OnChange = PageControlSekmeChange
      ClientRectBottom = 303
      ClientRectLeft = 4
      ClientRectRight = 1215
      ClientRectTop = 26
      object TabSheetIlet: TcxTabSheet
        Caption = 'Toplamlar'
        ImageIndex = 7
        PopupMenu = PopupMenuBakiye
        object cxLabel1: TcxLabel
          Left = 48
          Top = 23
          Caption = 'Devir'
        end
        object cxDBCurrencyEdit1: TcxDBCurrencyEdit
          Left = 146
          Top = 23
          DataBinding.DataField = 'DEVIR'
          DataBinding.DataSource = DtsTOPLAMLAR
          Properties.DisplayFormat = ',0.00;-,0.00'
          Style.Color = clScrollBar
          TabOrder = 1
          Width = 121
        end
        object cxDBCurrencyEdit2: TcxDBCurrencyEdit
          Left = 146
          Top = 53
          DataBinding.DataField = 'BORC'
          DataBinding.DataSource = DtsTOPLAMLAR
          Properties.DisplayFormat = ',0.00;-,0.00'
          Style.Color = clMoneyGreen
          TabOrder = 2
          Width = 121
        end
        object cxLabel4: TcxLabel
          Left = 48
          Top = 53
          Caption = 'Toplam Bor'#231
        end
        object cxDBCurrencyEdit3: TcxDBCurrencyEdit
          Left = 146
          Top = 83
          DataBinding.DataField = 'ALACAK'
          DataBinding.DataSource = DtsTOPLAMLAR
          Properties.DisplayFormat = ',0.00;-,0.00'
          Style.Color = 11184895
          TabOrder = 4
          Width = 121
        end
        object cxLabel6: TcxLabel
          Left = 48
          Top = 83
          Caption = 'Toplam Alacak'
        end
        object cxDBCurrencyEdit4: TcxDBCurrencyEdit
          Left = 146
          Top = 113
          DataBinding.DataField = 'BAKIYE'
          DataBinding.DataSource = DtsTOPLAMLAR
          Properties.DisplayFormat = ',0.00;-,0.00'
          Style.Color = clSkyBlue
          TabOrder = 6
          Width = 121
        end
        object cxLabel8: TcxLabel
          Left = 48
          Top = 113
          Caption = 'Bakiye'
        end
      end
      object cxTabSheet2: TcxTabSheet
        Caption = 'Komisyon'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object ToolBar2: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1205
          Height = 29
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 69
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
          object PosOranYeni: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yeni'
            ImageIndex = 7
            ImageName = 'PngImage6'
            OnClick = PosOranYeniClick
          end
          object PosOranSil: TToolButton
            Left = 69
            Top = 0
            Caption = 'Sil'
            ImageIndex = 8
            ImageName = 'PngImage7'
            OnClick = PosOranSilClick
          end
          object PosOranKaydet: TToolButton
            Left = 138
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 10
            ImageName = 'PngImage9'
            OnClick = PosOranKaydetClick
          end
          object PosOranIptal: TToolButton
            Left = 207
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 17
            ImageName = 'PngImage16'
            OnClick = PosOranIptalClick
          end
        end
        object GridPosOran: TcxGrid
          Left = 0
          Top = 35
          Width = 1211
          Height = 242
          Align = alClient
          TabOrder = 1
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridPosOranDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = dtsPosOran
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsView.GroupByBox = False
            OptionsView.Indicator = True
            object GridPosOranDBTableView1ID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridPosOranDBTableView1POSID: TcxGridDBColumn
              DataBinding.FieldName = 'POSID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridPosOranDBTableView1AY: TcxGridDBColumn
              DataBinding.FieldName = 'AY'
              DataBinding.IsNullValueType = True
            end
            object GridPosOranDBTableView1KOMISYON: TcxGridDBColumn
              DataBinding.FieldName = 'KOMISYON'
              DataBinding.IsNullValueType = True
            end
            object GridPosOranDBTableView1EKLEYEN: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEYEN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridPosOranDBTableView1EKLEMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'EKLEMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridPosOranDBTableView1DEGISTIREN: TcxGridDBColumn
              DataBinding.FieldName = 'DEGISTIREN'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object GridPosOranDBTableView1DEGISTIRMETARIHI: TcxGridDBColumn
              DataBinding.FieldName = 'DEGISTIRMETARIHI'
              DataBinding.IsNullValueType = True
              Visible = False
            end
          end
          object GridPosOranLevel1: TcxGridLevel
            GridView = GridPosOranDBTableView1
          end
        end
      end
      object TabSheetEkstre: TcxTabSheet
        Caption = 'Ekstre'
        ImageIndex = 6
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object GridPOS: TcxGrid
          Left = 0
          Top = 44
          Width = 1211
          Height = 233
          Align = alClient
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Verdana'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          LookAndFeel.Kind = lfStandard
          LookAndFeel.NativeStyle = True
          LookAndFeel.ScrollbarMode = sbmClassic
          object GridPOSView: TcxGridDBTableView
            OnDblClick = GridPOSViewDblClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridPOSViewCanFocusRecord
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsCariListe
            DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
                Column = GridPOSViewBORC
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Position = spFooter
                Column = GridPOSViewALACAK
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'BORC'
                Column = GridPOSViewBORC
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                FieldName = 'ALACAK'
                Column = GridPOSViewALACAK
              end
              item
                Format = ',0.00;(,0.00)'
                Column = GridPOSViewBORCBAKIYE
              end
              item
                Format = ',0.00;(,0.00)'
                Column = GridPOSViewALACAKBAKIYE
              end>
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
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.Indicator = True
            Styles.ContentEven = AnaForm.cxStyle1
            Styles.GroupByBox = AnaForm.cxStyle1
            Styles.Header = AnaForm.cxStyle1
            object GridPOSViewTARIH: TcxGridDBColumn
              Caption = 'Kay'#305't'
              DataBinding.FieldName = 'TARIH'
              DataBinding.IsNullValueType = True
              Width = 68
            end
            object GridPOSViewAKSIYONTARIH: TcxGridDBColumn
              Caption = 'Aksiyon/Vade'
              DataBinding.FieldName = 'AKSIYONTARIH'
              DataBinding.IsNullValueType = True
              Width = 79
            end
            object GridPOSViewNO: TcxGridDBColumn
              Caption = 'No'
              DataBinding.FieldName = 'NO'
              DataBinding.IsNullValueType = True
              Width = 75
            end
            object GridPOSViewTUR: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <
                item
                  Description = 'A'#231#305'l'#305#351' Fi'#351'i'
                  ImageIndex = 0
                  Value = 1
                end
                item
                  Description = 'Devir'
                  Value = 2
                end
                item
                  Description = 'Al'#305#351' Faturas'#305
                  ImageIndex = 0
                  Value = 11
                end
                item
                  Description = 'Al'#305#351' Fi'#351'i'
                  Value = 12
                end
                item
                  Description = 'Sat'#305#351' Faturas'#305
                  Value = 15
                end
                item
                  Description = 'Sat'#305#351' Fi'#351'i'
                  Value = 16
                end
                item
                  Description = 'Kasa Tahsilat'
                  Value = 21
                end
                item
                  Description = 'Banka Tahsilat'
                  Value = 22
                end
                item
                  Description = #199'ekle Tahsilat'
                  Value = 23
                end
                item
                  Description = 'Senetle Tahsilat'
                  Value = 24
                end
                item
                  Description = 'Kredi Kart'#305'yla Tahsilat'
                  Value = 25
                end
                item
                  Description = 'Kasa '#214'deme'
                  Value = 31
                end
                item
                  Description = 'Banka '#214'deme'
                  Value = 32
                end
                item
                  Description = #199'ekle '#214'deme'
                  Value = 33
                end
                item
                  Description = 'Senetle '#214'deme'
                  Value = 34
                end
                item
                  Description = 'Kredi Kart'#305'yla '#214'deme'
                  Value = 35
                end
                item
                  Description = 'Bankaya Yatan'
                  Value = 41
                end
                item
                  Description = 'Bankadan '#199'ekilen'
                  Value = 42
                end
                item
                  Description = 'Virman'
                  Value = 43
                end
                item
                  Description = 'D'#246'viz Al'#305#351
                  Value = 45
                end
                item
                  Description = 'D'#246'viz Sat'#305#351
                  Value = 46
                end
                item
                  Description = 'D'#246'viz Al'#305#351
                  Value = 47
                end
                item
                  Description = 'D'#246'viz Sat'#305#351
                  Value = 48
                end
                item
                  Description = #199'ek Bozduruldu'
                  Value = 51
                end
                item
                  Description = 'Senet Bozduruldu'
                  Value = 52
                end
                item
                  Description = #199'ek Bozduruldu'
                  Value = 53
                end
                item
                  Description = 'Senet Bozduruldu'
                  Value = 54
                end
                item
                  Description = 'Tahsilat Plan'#305
                  Value = 61
                end
                item
                  Description = 'D'#252'zenli Gelir'
                  Value = 62
                end
                item
                  Description = 'Avans Tahsilat Plan'#305
                  Value = 63
                end
                item
                  Description = #214'deme Plan'#305
                  Value = 71
                end
                item
                  Description = 'D'#252'zenli '#214'deme'
                  Value = 72
                end
                item
                  Description = 'Kredi '#214'deme'
                  Value = 75
                end
                item
                  Description = 'Tahakkuk'
                  Value = 81
                end
                item
                  Description = 'POS Giri'#351'i'
                  Value = 121
                end
                item
                  Description = 'Nakit Giri'#351'i'
                  Value = 122
                end>
            end
            object GridPOSViewKOD: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 77
            end
            object GridPOSViewAD: TcxGridDBColumn
              Caption = #220'nvan'
              DataBinding.FieldName = 'AD'
              DataBinding.IsNullValueType = True
              Visible = False
              Width = 90
            end
            object GridPOSViewACIKLAMA: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              Width = 128
            end
            object GridPOSViewHESAPKODU: TcxGridDBColumn
              Caption = 'Hesap Kodu'
              DataBinding.FieldName = 'HESAPKODU'
              DataBinding.IsNullValueType = True
              Width = 91
            end
            object GridPOSViewHESAPADI: TcxGridDBColumn
              Caption = 'Hesap Ad'#305
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Width = 82
            end
            object GridPOSViewBORC: TcxGridDBColumn
              Caption = 'Bor'#231
              DataBinding.FieldName = 'BORC'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 56
            end
            object GridPOSViewALACAK: TcxGridDBColumn
              Caption = 'Alacak'
              DataBinding.FieldName = 'ALACAK'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 67
            end
            object GridPOSViewBORCBAKIYE: TcxGridDBColumn
              Caption = 'B.Bakiye'
              DataBinding.FieldName = 'BORCBAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 54
            end
            object GridPOSViewALACAKBAKIYE: TcxGridDBColumn
              Caption = 'A.Bakiye'
              DataBinding.FieldName = 'ALACAKBAKIYE'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Width = 56
            end
            object GridPOSViewKUR: TcxGridDBColumn
              Caption = 'Para Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Visible = False
              GroupIndex = 0
              Width = 76
            end
            object GridPOSViewYERELKUR: TcxGridDBColumn
              Caption = 'Y.Kur'
              DataBinding.FieldName = 'YERELKUR'
              DataBinding.IsNullValueType = True
            end
            object GridPOSViewYERELTUTAR: TcxGridDBColumn
              Caption = 'Y.Tutar'
              DataBinding.FieldName = 'YERELTUTAR'
              DataBinding.IsNullValueType = True
            end
            object GridPOSViewYERELBAKIYE: TcxGridDBColumn
              Caption = 'Y.Bakiye'
              DataBinding.FieldName = 'YERELBAKIYE'
              DataBinding.IsNullValueType = True
            end
          end
          object GridPOSDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
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
            object GridPOSDBTableView1DURUM: TcxGridDBColumn
              DataBinding.FieldName = 'DURUM'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 74
            end
            object GridPOSDBTableView1VADE: TcxGridDBColumn
              DataBinding.FieldName = 'VADE'
              DataBinding.IsNullValueType = True
              Width = 130
            end
            object GridPOSDBTableView1SERINO: TcxGridDBColumn
              DataBinding.FieldName = 'SERINO'
              DataBinding.IsNullValueType = True
              FooterAlignmentHorz = taRightJustify
              GroupSummaryAlignment = taRightJustify
              Width = 109
            end
            object GridPOSDBTableView1HESAPADI: TcxGridDBColumn
              DataBinding.FieldName = 'HESAPADI'
              DataBinding.IsNullValueType = True
              Width = 354
            end
            object GridPOSDBTableView1Column1: TcxGridDBColumn
              DataBinding.FieldName = 'CEKID'
              DataBinding.IsNullValueType = True
            end
          end
          object GridPOSLevel1: TcxGridLevel
            GridView = GridPOSView
          end
        end
        object PanelPlan: TPanel
          Left = 0
          Top = 0
          Width = 1211
          Height = 44
          Align = alTop
          BevelOuter = bvNone
          Font.Charset = TURKISH_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          object JvNavPanelHeader2: TJvNavPanelHeader
            Left = 102
            Top = 0
            Width = 1109
            Height = 44
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
            object Label2: TLabel
              Left = 213
              Top = 12
              Width = 26
              Height = 18
              Caption = 'Biti'#351
              Font.Charset = TURKISH_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
            end
            object Label1: TLabel
              Left = 5
              Top = 12
              Width = 48
              Height = 18
              Caption = 'Ba'#351'lama'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              ParentFont = False
            end
            object CalendarEkstreBit: TcxDateEdit
              Left = 243
              Top = 9
              EditValue = 40941d
              ParentFont = False
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.TextColor = clBlack
              Style.IsFontAssigned = True
              TabOrder = 0
              Width = 121
            end
            object CalendarEkstreBas: TcxDateEdit
              Left = 59
              Top = 9
              EditValue = 40909d
              ParentFont = False
              Properties.ImmediatePost = True
              Properties.OnEditValueChanged = CalendarEkstreBasPropertiesEditValueChanged
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clBlack
              Style.Font.Height = -13
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = []
              Style.TextColor = clBlack
              Style.IsFontAssigned = True
              TabOrder = 1
              Width = 121
            end
          end
          object ToolBar11: TToolBar
            Left = 0
            Top = 0
            Width = 102
            Height = 44
            Margins.Bottom = 0
            Align = alLeft
            ButtonHeight = 47
            ButtonWidth = 39
            Caption = 'AletCubugu'
            DockSite = True
            DrawingStyle = dsGradient
            EdgeInner = esNone
            EdgeOuter = esNone
            Font.Charset = TURKISH_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            GradientEndColor = 11776947
            GradientStartColor = 14540253
            Images = Tablo.PNGImageList1
            ParentFont = False
            ShowCaptions = True
            TabOrder = 1
            object YaziciYaz: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yazd'#305'r'
              DropdownMenu = PopupMenuYaz
              ImageIndex = 16
              ImageName = 'PngImage15'
              Style = tbsTextButton
            end
          end
        end
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 1
      Top = 166
      Width = 1219
      Height = 8
      HotZoneClassName = 'TcxMediaPlayer8Style'
      AlignSplitter = salBottom
      Control = PageControlSekme
      ExplicitWidth = 8
    end
    object SqlMemo: TMemo
      Left = 209
      Top = 391
      Width = 630
      Height = 65
      Lines.Strings = (
        'select P.*,B.LOGO,B.BANKAADI,BS.SUBEADI  from POS P'
        'inner join BANKAHESAPLAR BH ON  BH.ID = P.BANKAHESAPID'
        'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
        'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU ')
      TabOrder = 4
      Visible = False
    end
  end
  object DtsPOS: TDataSource
    DataSet = POSLAR
    Left = 207
    Top = 136
  end
  object POSLAR: TFDQuery
    AfterScroll = POSLARAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select P.*,B.LOGO,B.BANKAADI,BS.SUBEADI  from POS P'
      'inner join BANKAHESAPLAR BH ON  BH.ID = P.BANKAHESAPID'
      'inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID'
      'inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU '
      '')
    Left = 145
    Top = 96
  end
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = TabCariListe
    BCDToCurrency = False
    DataSetOptions = []
    Left = 574
    Top = 206
  end
  object frxPOS: TfrxDBDataset
    UserName = 'POS'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 634
    Top = 144
  end
  object PopupMenuYaz: TPopupMenu
    Left = 86
    Top = 128
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
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object DtsCariListe: TDataSource
    DataSet = TabCariListe
    Left = 766
    Top = 242
  end
  object TabCariListe: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'Select CEKID=ID,TARIH,TUR, REHBERID,  CARIKOD AS KOD, CARIUNVAN ' +
        'AS AD, ACIKLAMA=NOTLAR, HESAPID, HESAPKODU, HESAPADI,DURUM, '
      
        '   BORC = case when TUR in(33,34) then cast(TUTAR as money) else' +
        ' 0 end, '
      
        '    ALACAK= case when TUR in(23,24) then cast(TUTAR as money) el' +
        'se 0 end,KUR From CEKLER (NOLOCK) ')
    Left = 691
    Top = 242
  end
  object TabPosOran: TFDQuery
    BeforePost = TabPosOranBeforePost
    OnNewRecord = TabPosOranNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT * FROM POSORAN WHERE POSID=:POSID')
    Left = 536
    Top = 208
  end
  object dtsPosOran: TDataSource
    DataSet = TabPosOran
    OnStateChange = dtsPosOranStateChange
    Left = 464
    Top = 240
  end
  object PosListeMenu: TPopupMenu
    Left = 297
    Top = 105
    object AcilisKaydiMenu: TMenuItem
      Tag = 1
      Caption = 'A'#231#305'l'#305#351' Fi'#351'i Gir'
      OnClick = AcilisKaydiMenuClick
    end
    object DevirFiiGir1: TMenuItem
      Tag = 2
      Caption = 'Devir Fi'#351'i Gir'
      Visible = False
      OnClick = AcilisKaydiMenuClick
    end
  end
  object TOPLAMLAR: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT SUM(DEVIR) AS DEVIR,SUM(ALACAK) AS BORC,SUM(BORC) AS ALAC' +
        'AK, BAKIYE=SUM(ALACAK)-SUM(BORC)  FROM ('
      'SELECT'
      'DEVIR = 0,'
      'BORC=SUM(K.BORC),ALACAK=SUM(K.ALACAK)'
      'FROM KASA K'
      
        'WHERE HESAPID=:Prm1 AND ISLEMTARIHI BETWEEN cast(year(getdate())' +
        ' as varchar(4))+'#39'-01-01 00:00'#39
      'AND cast(year(getdate()) as varchar(4))+'#39'-12-31 23:59'#39
      'and HESAPTURU='#39'P'#39
      'UNION ALL'
      'SELECT'
      'DEVIR = SUM(BORC-ALACAK),'
      'BORC=0,ALACAK=0'
      'FROM KASA K'
      
        'WHERE HESAPID=:Prm2 AND ISLEMTARIHI >=cast(year(getdate()) as va' +
        'rchar(4))+'#39'-01-01 00:00'#39' AND TUR<=2'
      'and HESAPTURU='#39'P'#39
      ') AS X')
    Left = 551
    Top = 321
  end
  object DtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 457
    Top = 392
  end
  object PopupMenuBakiye: TPopupMenu
    Left = 369
    Top = 297
    object MenuItem1: TMenuItem
      Caption = 'Bakiyeyi '#252'st tarafa kaydet'
      OnClick = MenuItem1Click
    end
  end
end
