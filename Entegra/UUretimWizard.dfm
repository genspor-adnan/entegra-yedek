object UretimWizardDlg: TUretimWizardDlg
  Left = 0
  Top = 0
  ActiveControl = PageControlUst
  Caption = #220'retim Sihirbaz'#305
  ClientHeight = 700
  ClientWidth = 1296
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 1210
    Height = 700
    ActivePage = JvWizardInteriorPage1
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Back'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&Next >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = 'Son'
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
      1210
      700)
    object JvWizardInteriorPage1: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = #220'retim Fi'#351'i Bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkFinish, bkCancel]
      Caption = 'JvWizardInteriorPage1'
      DesignSize = (
        1210
        658)
      object PanelUst: TPanel
        Left = 0
        Top = 70
        Width = 1210
        Height = 145
        Align = alTop
        BevelOuter = bvNone
        Color = 11776947
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object btnKapat: TSpeedButton
          Left = 1050
          Top = 7
          Width = 64
          Height = 23
          Caption = 'Kapat'
          Flat = True
          Glyph.Data = {
            66010000424D6601000000000000760000002800000013000000140000000100
            040000000000F000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7777777600007777777777777777777000007777777777777777777000007777
            777777777777777000007777777777777770F77C0000777770F7777777777776
            00007777000F7777770F777000007777000F777770F77770000077777000F777
            00F7777E0000777777000F700F7777700000777777700000F777777F00007777
            7777000F777777760000777777700000F77777700000777777000F70F7777770
            000077770000F77700F7777000007770000F7777700F7770000077700F777777
            7700F77400007777777777777777777600007777777777777777777000007777
            77777777777777700000}
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1204
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 73
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
          object KaydetTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Kaydet'
            ImageIndex = 10
            ImageName = 'PngImage9'
            Style = tbsTextButton
            Visible = False
            OnClick = KaydetTusClick
          end
          object IptalTus: TToolButton
            Left = 73
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Style = tbsTextButton
            Visible = False
            OnClick = IptalTusClick
          end
          object ToolButton2: TToolButton
            Left = 146
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 18
            ImageName = 'PngImage17'
            Style = tbsSeparator
          end
          object ReceteTus: TToolButton
            Left = 154
            Top = 0
            Caption = 'Re'#231'ete'
            EnableDropdown = True
            ImageIndex = 35
            ImageName = 'PngImage35'
            Indeterminate = True
            OnClick = ReceteTusClick
          end
          object ToolButton8: TToolButton
            Left = 227
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 9
            ImageName = 'PngImage8'
            Style = tbsSeparator
          end
          object YaziciYaz: TToolButton
            Left = 235
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
          object HesaplaTus: TToolButton
            Left = 308
            Top = 0
            Caption = 'Hesapla'
            ImageIndex = 47
            ImageName = 'PngImage46'
            OnClick = HesaplaTusClick
          end
          object ToolButton1: TToolButton
            Left = 381
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 48
            ImageName = 'PngImage48'
            Style = tbsSeparator
          end
          object DetayTus: TToolButton
            Left = 389
            Top = 0
            Caption = 'Detay'
            ImageIndex = 48
            ImageName = 'PngImage48'
          end
        end
        object PageControlUst: TcxPageControl
          Left = 0
          Top = 35
          Width = 1210
          Height = 110
          Align = alClient
          TabOrder = 1
          Properties.ActivePage = cxTabSheet1
          Properties.CustomButtons.Buttons = <>
          OnChange = PageControlUstChange
          ClientRectBottom = 106
          ClientRectLeft = 4
          ClientRectRight = 1206
          ClientRectTop = 27
          object cxTabSheet1: TcxTabSheet
            Caption = 'Bilgi'
            Color = clWhite
            ImageIndex = 0
            ParentColor = False
            object Label19: TcxLabel
              Left = 529
              Top = 2
              Caption = 'Ba'#351'lama/Biti'#351
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object LabelFatNo: TcxLabel
              Left = 529
              Top = 30
              Caption = #220'retim No'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object Label1: TcxLabel
              Left = 271
              Top = 2
              Caption = #199#305'k'#305#351' Deposu'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object Label2: TcxLabel
              Left = 271
              Top = 29
              Caption = 'Giri'#351' Deposu'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object EditFatTarih: TcxDBDateEdit
              Left = 748
              Top = 0
              DataBinding.DataField = 'FATURATARIH'
              DataBinding.DataSource = DtsUretim
              Properties.ImmediatePost = True
              Properties.Kind = ckDateTime
              TabOrder = 8
              Width = 133
            end
            object EditFatNo: TcxDBTextEdit
              Left = 615
              Top = 27
              DataBinding.DataField = 'FATURANO'
              DataBinding.DataSource = DtsUretim
              TabOrder = 9
              Width = 133
            end
            object ComboCikisDepo: TcxDBImageComboBox
              Left = 347
              Top = 0
              RepositoryItem = Tablo.RepStokUretimDepolar
              DataBinding.DataField = 'CIKISDEPO'
              DataBinding.DataSource = DtsUretim
              Properties.Items = <
                item
                  Description = 'Yap'#305'lmad'#305
                  ImageIndex = 0
                  Value = 0
                end
                item
                  Description = 'K'#305'smi'
                  Value = 1
                end
                item
                  Description = #304'ptal'
                  Value = 6
                end
                item
                  Description = 'Tamamland'#305
                  Value = 9
                end>
              TabOrder = 4
              Width = 153
            end
            object ComboGirisDepo: TcxDBImageComboBox
              Left = 347
              Top = 27
              RepositoryItem = Tablo.RepStokUretimDepolar
              DataBinding.DataField = 'GIRISDEPO'
              DataBinding.DataSource = DtsUretim
              Properties.Items = <
                item
                  Description = 'Yap'#305'lmad'#305
                  ImageIndex = 0
                  Value = 0
                end
                item
                  Description = 'K'#305'smi'
                  Value = 1
                end
                item
                  Description = #304'ptal'
                  Value = 6
                end
                item
                  Description = 'Tamamland'#305
                  Value = 9
                end>
              TabOrder = 5
              Width = 153
            end
            object cxLabel2: TcxLabel
              Left = 4
              Top = 2
              Caption = #220'retim Sorumlusu'
            end
            object cxLabel6: TcxLabel
              Left = 271
              Top = 55
              Caption = 'Lokasyon'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object cxLabel4: TcxLabel
              Left = 4
              Top = 55
              Caption = #304'stasyon'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object BEditIsMerkezi: TcxDBButtonEdit
              Left = 99
              Top = 54
              DataBinding.DataField = 'ISTASYON'
              DataBinding.DataSource = DtsUretim
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = BEditIsMerkeziPropertiesButtonClick
              TabOrder = 3
              Width = 147
            end
            object BeditLokasyon: TcxDBButtonEdit
              Left = 347
              Top = 54
              DataBinding.DataField = 'LOKASYONADI'
              DataBinding.DataSource = DtsUretim
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = BeditLokasyonPropertiesButtonClick
              TabOrder = 6
              Width = 153
            end
            object ComboUretici: TcxDBButtonEdit
              Left = 99
              Top = 0
              DataBinding.DataField = 'SORUMLUADI'
              DataBinding.DataSource = DtsUretim
              Properties.Buttons = <
                item
                  Default = True
                  Kind = bkEllipsis
                end>
              Properties.OnButtonClick = ComboUreticiPropertiesButtonClick
              TabOrder = 1
              Width = 147
            end
            object EditTarih: TcxDBDateEdit
              Left = 615
              Top = 0
              DataBinding.DataField = 'TARIH'
              DataBinding.DataSource = DtsUretim
              Properties.ImmediatePost = True
              Properties.Kind = ckDateTime
              TabOrder = 7
              Width = 133
            end
            object ComboSENARYO: TcxDBImageComboBox
              Left = 748
              Top = 27
              DataBinding.DataField = 'SENARYO'
              DataBinding.DataSource = DtsUretim
              Properties.Items = <
                item
                  Description = 'Par'#231'adan B'#252't'#252'ne'
                  ImageIndex = 0
                  Value = 1
                end
                item
                  Description = 'B'#252't'#252'nden Par'#231'aya'
                  Value = 2
                end>
              TabOrder = 10
              Width = 133
            end
            object cxLabel7: TcxLabel
              Left = 4
              Top = 28
              Caption = #220'retim T'#252'r'#252
              FocusControl = cbUretimTuru
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
              OnClick = cxLabel7Click
            end
            object cbUretimTuru: TcxDBImageComboBox
              Left = 99
              Top = 27
              RepositoryItem = Tablo.RepUretimTuru
              DataBinding.DataField = 'BOLUM'
              DataBinding.DataSource = DtsUretim
              Properties.Items = <
                item
                  Description = 'Yap'#305'lmad'#305
                  ImageIndex = 0
                  Value = 0
                end
                item
                  Description = 'K'#305'smi'
                  Value = 1
                end
                item
                  Description = #304'ptal'
                  Value = 6
                end
                item
                  Description = 'Tamamland'#305
                  Value = 9
                end>
              TabOrder = 2
              Width = 147
            end
            object cxLabel8: TcxLabel
              Left = 529
              Top = 60
              Caption = 'Ana '#220'r'#252'n'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object LabelUrunAd: TcxLabel
              Left = 615
              Top = 60
              Caption = '---------------'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object cxLabel9: TcxLabel
              Left = 897
              Top = 3
              Caption = #214'zel Kod'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object EditOZELKOD: TcxDBTextEdit
              Left = 983
              Top = 0
              DataBinding.DataField = 'OZELKOD'
              DataBinding.DataSource = DtsUretim
              TabOrder = 11
              Width = 133
            end
            object cxLabel10: TcxLabel
              Left = 897
              Top = 30
              Caption = #214'zel Kod 2'
              ParentFont = False
              Style.Font.Charset = TURKISH_CHARSET
              Style.Font.Color = clWindowText
              Style.Font.Height = -11
              Style.Font.Name = 'Trebuchet MS'
              Style.Font.Style = [fsBold]
              Style.IsFontAssigned = True
            end
            object EditOZELKOD2: TcxDBTextEdit
              Left = 983
              Top = 27
              DataBinding.DataField = 'OZELKOD2'
              DataBinding.DataSource = DtsUretim
              TabOrder = 12
              Width = 133
            end
            object CheckOtomatikHesapla: TcxCheckBox
              Left = 982
              Top = 54
              Caption = 'Otomatik Hesapla'
              State = cbsChecked
              TabOrder = 24
            end
          end
          object EkAlanlarEkr: TcxTabSheet
            Caption = 'Ek Alanlar'
            ImageIndex = 1
          end
        end
      end
      object GridUretim: TcxGrid
        Left = 0
        Top = 239
        Width = 1210
        Height = 247
        Align = alClient
        TabOrder = 1
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridUretimDBTableView1: TcxGridDBTableView
          PopupMenu = PopupGenel
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridUretimDBTableView1CanFocusRecord
          DataController.DataSource = DtsUretimDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsView.GroupByBox = False
          object GridUretimDBTableView1GRP: TcxGridDBColumn
            DataBinding.FieldName = 'GRP'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repUretimFisiGRP
            Visible = False
            GroupIndex = 0
            Options.Editing = False
            Options.Focusing = False
          end
          object GridUretimDBTableView1URUNNO: TcxGridDBColumn
            Caption = #220'r'#252'n No'
            DataBinding.FieldName = 'URUNNO'
            DataBinding.IsNullValueType = True
          end
          object GridUretimDBTableView1KOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Width = 97
          end
          object GridUretimDBTableView1AD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Width = 233
          end
          object GridUretimDBTableView1ADET: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
          end
          object GridUretimDBTableView1BIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repStokAnaBirim
            Options.Editing = False
          end
          object GridUretimDBTableView1STOKDURUM: TcxGridDBColumn
            Caption = 'Stok Durum'
            DataBinding.FieldName = 'STOKDURUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCurrencyEditProperties'
            Properties.DisplayFormat = ',0.00;-,0.00'
            Width = 66
          end
          object GridUretimDBTableView1SIRA: TcxGridDBColumn
            Caption = 'S'#305'ra'
            DataBinding.FieldName = 'SIRA'
            DataBinding.IsNullValueType = True
            Width = 32
          end
          object GridUretimDBTableView1BIRIMFIYAT: TcxGridDBColumn
            Caption = 'Brm.Mlyt Son'
            DataBinding.FieldName = 'BIRIMFIYAT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
          end
          object GridUretimDBTableView1SON_TPLM_MLYT: TcxGridDBColumn
            Caption = 'Tpl. Mlyt Son'
            DataBinding.FieldName = 'SON_TPLM_MLYT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 90
          end
          object GridUretimDBTableView1TUTAR: TcxGridDBColumn
            Caption = 'Brm.Mlyt Ort.'
            DataBinding.FieldName = 'TUTAR'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 78
          end
          object GridUretimDBTableView1ORT_TPLM_MLYT: TcxGridDBColumn
            Caption = 'Tpl. Mlyt Ort.'
            DataBinding.FieldName = 'ORT_TPLM_MLYT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
          end
          object GridUretimDBTableView1KUR: TcxGridDBColumn
            Caption = 'P.Birimi'
            DataBinding.FieldName = 'KUR'
            DataBinding.IsNullValueType = True
            Width = 43
          end
          object GridUretimDBTableView1DOVIZKURDEGERI: TcxGridDBColumn
            Caption = 'Kur'
            DataBinding.FieldName = 'DOVIZKURDEGERI'
            DataBinding.IsNullValueType = True
            Width = 47
          end
          object GridUretimDBTableView1DOVIZ_BIRIMFIYAT: TcxGridDBColumn
            Caption = 'D'#246'viz Son.Maliyet'
            DataBinding.FieldName = 'DOVIZ_BIRIMFIYAT'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 78
          end
          object GridUretimDBTableView1DOVIZ_TUTARI: TcxGridDBColumn
            Caption = 'D'#246'viz Ort.Maliyet'
            DataBinding.FieldName = 'DOVIZ_TUTARI'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyGenel
            Width = 84
          end
          object GridUretimDBTableView1DOVIZ_KURU: TcxGridDBColumn
            Caption = 'D'#246'viz'
            DataBinding.FieldName = 'DOVIZ_KURU'
            DataBinding.IsNullValueType = True
            Width = 42
          end
          object GridUretimDBTableView1ACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 280
          end
          object GridUretimDBTableView1FIRMA: TcxGridDBColumn
            Caption = 'Firma'
            DataBinding.FieldName = 'FIRMA'
            DataBinding.IsNullValueType = True
          end
          object GridUretimDBTableViewEKLEYEN: TcxGridDBColumn
            Caption = 'Ekleyen'
            DataBinding.FieldName = 'EKLEYENAD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxSpinEditProperties'
            Properties.ReadOnly = True
          end
          object GridUretimDBTableViewEKLEMETARIHI: TcxGridDBColumn
            Caption = 'Ekleme Zaman'#305
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.Kind = ckDateTime
            Properties.ReadOnly = True
          end
          object GridUretimDBTableView1OZELKOD: TcxGridDBColumn
            Caption = #214'zel Kod'
            DataBinding.FieldName = 'OZELKOD'
            DataBinding.IsNullValueType = True
          end
          object GridUretimDBTableView1OZELKOD2: TcxGridDBColumn
            Caption = #214'zel Kod2'
            DataBinding.FieldName = 'OZELKOD2'
            DataBinding.IsNullValueType = True
          end
        end
        object GridUretimLevel1: TcxGridLevel
          GridView = GridUretimDBTableView1
        end
      end
      object ToolBar5: TToolBar
        Left = 0
        Top = 215
        Width = 1210
        Height = 24
        Margins.Bottom = 0
        ButtonWidth = 73
        Caption = 'AletCubugu'
        DrawingStyle = dsGradient
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esLowered
        EdgeOuter = esNone
        GradientEndColor = 11776947
        GradientStartColor = 14540253
        HotTrackColor = 65408
        Images = Tablo.PNGImageList2
        List = True
        ShowCaptions = True
        TabOrder = 2
        Transparent = True
        object BilesenEkle: TToolButton
          Tag = 1
          Left = 0
          Top = 0
          Caption = 'Yeni Sarf'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = BilesenEkleClick
        end
        object UrunEkle: TToolButton
          Tag = 2
          Left = 73
          Top = 0
          Caption = 'Yeni '#220'r'#252'n'
          ImageIndex = 0
          ImageName = 'PngImage0'
          OnClick = UrunEkleClick
        end
        object SatirSil: TToolButton
          Left = 146
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          ImageName = 'PngImage1'
          OnClick = SatirSilClick
        end
        object SatirKaydet: TToolButton
          Left = 219
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          ImageName = 'PngImage2'
          Visible = False
          OnClick = SatirKaydetClick
        end
        object SatirIptal: TToolButton
          Left = 292
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          ImageName = 'PngImage3'
          Visible = False
          OnClick = SatirIptalClick
        end
        object BtnDonustur: TToolButton
          Left = 365
          Top = 0
          Caption = 'D'#246'n'#252#351't'#252'r'
          DropdownMenu = PopupMenuDonustur
          ImageIndex = 7
          ImageName = 'PngImage7'
          PopupMenu = PopupMenuDonustur
          OnClick = BtnDonusturClick
        end
      end
      object cxLabel5: TcxLabel
        Left = 1068
        Top = 4
        Anchors = [akTop, akRight]
        Caption = 'ID'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object cxDBLabel1: TcxDBLabel
        Left = 1087
        Top = 5
        Anchors = [akTop, akRight]
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsUretim
        Transparent = True
        Height = 17
        Width = 47
      end
      object LabelKod: TcxLabel
        Left = 3
        Top = 36
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'Kodu'
        DragCursor = crDefault
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -15
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
        Height = 28
        Width = 103
      end
      object LabelAd: TcxLabel
        Left = 112
        Top = 36
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'Ad'
        DragCursor = crDefault
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 21
        Width = 485
      end
      object PageControlAlt: TcxPageControl
        Left = 0
        Top = 486
        Width = 1210
        Height = 172
        Align = alBottom
        TabOrder = 7
        Properties.ActivePage = TabSheetGenel
        Properties.CustomButtons.Buttons = <>
        OnChange = PageControlAltChange
        ClientRectBottom = 168
        ClientRectLeft = 4
        ClientRectRight = 1206
        ClientRectTop = 24
        object TabSheetGenel: TcxTabSheet
          Caption = 'Genel'
          ImageIndex = 0
          object LabelProje: TcxLabel
            Left = 7
            Top = 7
            Caption = 'Proje Kodu'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel1: TcxLabel
            Left = 6
            Top = 38
            Caption = #220'retim Fi'#351'i Notu'
            ParentFont = False
            Transparent = True
          end
          object memoACIKLAMA: TcxDBMemo
            Left = 89
            Top = 36
            Align = alCustom
            Anchors = [akLeft, akTop, akRight]
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsUretim
            TabOrder = 2
            Height = 56
            Width = 1117
          end
          object BeditProje: TcxButtonEdit
            Left = 89
            Top = 7
            ParentShowHint = False
            Properties.Buttons = <
              item
                Caption = '++'
                Default = True
                Hint = 'Ekle'
                Kind = bkText
              end
              item
                Caption = '+'
                Hint = 'Sil'
                Kind = bkText
              end
              item
                Caption = '-'
                Kind = bkText
              end>
            Properties.ReadOnly = True
            Properties.OnButtonClick = BeditProjePropertiesButtonClick
            ShowHint = True
            Style.BorderStyle = ebsOffice11
            Style.LookAndFeel.Kind = lfStandard
            Style.LookAndFeel.NativeStyle = False
            StyleDisabled.LookAndFeel.Kind = lfStandard
            StyleDisabled.LookAndFeel.NativeStyle = False
            StyleFocused.LookAndFeel.Kind = lfStandard
            StyleFocused.LookAndFeel.NativeStyle = False
            StyleHot.LookAndFeel.Kind = lfStandard
            StyleHot.LookAndFeel.NativeStyle = False
            StyleReadOnly.LookAndFeel.Kind = lfStandard
            StyleReadOnly.LookAndFeel.NativeStyle = False
            TabOrder = 3
            OnDblClick = BeditProjeDblClick
            Width = 281
          end
          object cxLabel3: TcxLabel
            Left = 448
            Top = 8
            Caption = 'Onaylayan'
            ParentFont = False
            Transparent = True
          end
          object ComboOnaylayan: TcxDBButtonEdit
            Left = 510
            Top = 7
            DataBinding.DataField = 'ONAYLAYANADI'
            DataBinding.DataSource = DtsUretim
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = ComboOnaylayanPropertiesButtonClick
            TabOrder = 5
            Width = 203
          end
          object cxLabel11: TcxLabel
            Left = 896
            Top = 12
            Caption = #220'retim Emir No'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
          end
          object EditDETAYBOLUMU: TcxDBTextEdit
            Left = 982
            Top = 11
            DataBinding.DataField = 'DETAYBOLUMU'
            DataBinding.DataSource = DtsUretim
            Enabled = False
            Style.ReadOnly = True
            TabOrder = 7
            Width = 133
          end
        end
        object TabIsVeZaman: TcxTabSheet
          Caption = #304#351' Zaman'
          ImageIndex = 1
          object Panel9: TPanel
            Left = 0
            Top = 0
            Width = 1202
            Height = 23
            Align = alTop
            Caption = 'Panel9'
            TabOrder = 0
            object JvNavPanelHeader5: TJvNavPanelHeader
              Left = 201
              Top = 1
              Width = 1000
              Height = 21
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
              object CheckTamamlananlar: TcxCheckBox
                Left = 6
                Top = 0
                Caption = 'Tamamlananlar'#305' da G'#246'ster'
                ParentFont = False
                Properties.ImmediatePost = True
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWhite
                Style.Font.Height = -13
                Style.Font.Name = 'Arial'
                Style.Font.Style = [fsBold]
                Style.TextStyle = []
                Style.TransparentBorder = True
                Style.IsFontAssigned = True
                TabOrder = 0
                Transparent = True
                OnClick = CheckTamamlananlarClick
              end
            end
            object ToolBar4: TToolBar
              Left = 1
              Top = 1
              Width = 200
              Height = 21
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
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
              object IsZamanYeni: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = IsZamanYeniClick
              end
              object IsZamanSil: TToolButton
                Left = 66
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = IsZamanSilClick
              end
              object IsZamanDuzenle: TToolButton
                Left = 132
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = IsZamanDuzenleClick
              end
            end
          end
          object GridIsZaman: TcxGrid
            Left = 0
            Top = 23
            Width = 1202
            Height = 121
            Align = alClient
            TabOrder = 1
            object GridIsZamanView: TcxGridDBTableView
              PopupMenu = PopupIsZamanPer
              OnDblClick = IsZamanDuzenleClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsIsZaman
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object cxGridDBTARIH: TcxGridDBColumn
                Caption = 'Tarih'
                DataBinding.FieldName = 'BASLAMA'
                PropertiesClassName = 'TcxDateEditProperties'
                Properties.DateButtons = [btnClear, btnToday]
                Options.Editing = False
                Width = 68
              end
              object cxGridDBKONUSU: TcxGridDBColumn
                Caption = 'Konusu'
                DataBinding.FieldName = 'KONUSU'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Options.Editing = False
                Width = 191
              end
              object cxGridDBColumn2: TcxGridDBColumn
                Caption = 'Sorumlu'
                DataBinding.FieldName = 'SORUMLUADI'
                Options.Editing = False
                Width = 125
              end
              object cxGridDBBASLAMA: TcxGridDBColumn
                Caption = 'Ba'#351'lama'
                DataBinding.FieldName = 'BASLAMA'
                PropertiesClassName = 'TcxTimeEditProperties'
                Properties.SpinButtons.Visible = False
                Properties.TimeFormat = tfHourMin
                Options.Editing = False
                Width = 52
              end
              object cxGridDBBITIS: TcxGridDBColumn
                Caption = 'Biti'#351
                DataBinding.FieldName = 'BITIS'
                PropertiesClassName = 'TcxTimeEditProperties'
                Properties.SpinButtons.Visible = False
                Properties.TimeFormat = tfHourMin
                Options.Editing = False
                Width = 48
              end
              object GridIsZamanViewMOLA: TcxGridDBColumn
                Caption = 'Mola'
                DataBinding.FieldName = 'MOLA'
                PropertiesClassName = 'TcxTimeEditProperties'
                Properties.SpinButtons.Visible = False
                Properties.TimeFormat = tfHourMin
                Options.Editing = False
                Width = 48
              end
              object GridIsZamanViewSURE: TcxGridDBColumn
                Caption = 'S'#252're'
                DataBinding.FieldName = 'SURE'
                PropertiesClassName = 'TcxTimeEditProperties'
                Properties.SpinButtons.Visible = False
                Properties.TimeFormat = tfHourMin
                Options.Editing = False
              end
              object cxGridDBColumn5: TcxGridDBColumn
                Caption = 'Lokasyon'
                DataBinding.FieldName = 'LOKASYONADI'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 75
              end
              object cxGridDBColumn6: TcxGridDBColumn
                Caption = 'Kaynak'
                DataBinding.FieldName = 'KAYNAKADI'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 71
              end
              object cxGridDBColumn9: TcxGridDBColumn
                Caption = 'Adet'
                DataBinding.FieldName = 'ADET'
                Options.Editing = False
              end
              object cxGridDBColumn10: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                RepositoryItem = Tablo.repStokAnaBirim
                Options.Editing = False
                Options.Focusing = False
              end
              object cxGridDBColumn15: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Visible = False
                Options.Editing = False
                Options.Focusing = False
              end
              object GridIsZamanViewDURUM: TcxGridDBColumn
                Caption = 'Durum'
                DataBinding.FieldName = 'DURUM'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Bekliyor'
                    ImageIndex = 0
                    Value = 0
                  end
                  item
                    Description = #199'al'#305#351#305'l'#305'yor'
                    Value = 1
                  end
                  item
                    Description = 'Tamamland'#305
                    Value = 9
                  end>
                Options.Editing = False
              end
              object GridIsZamanViewACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Width = 195
              end
            end
            object cxGridLevel2: TcxGridLevel
              GridView = GridIsZamanView
            end
          end
        end
      end
      object LabelSevk: TcxLabel
        Left = 705
        Top = 48
        AutoSize = False
        Caption = 'Sevk'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        OnClick = LabelSevkClick
        Height = 18
        Width = 331
      end
      object lblMusteriAdres: TcxLabel
        Left = 703
        Top = 31
        AutoSize = False
        Caption = 'Adres'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Height = 18
        Width = 331
      end
      object lblMusteriEposta: TcxLabel
        Left = 704
        Top = 15
        Caption = 'Eposta'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lblMusteriTel: TcxLabel
        Left = 703
        Top = 1
        Caption = 'Tel'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object UretimDetayPage: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Detay'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      Caption = 'UretimDetayPage'
      OnPage = UretimDetayPagePage
      OnExitPage = UretimDetayPageExitPage
      object LabelSablon: TcxLabel
        Left = 6
        Top = 38
        Cursor = crHandPoint
        Caption = #350'ablon Se'#231'iniz.'
        Style.TextColor = clMaroon
        Transparent = True
        OnClick = LabelSablonClick
      end
      object ComboBolum: TcxDBComboBox
        Left = 83
        Top = 37
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsUretim
        Properties.ImmediatePost = True
        Properties.MaxLength = 0
        Properties.OnEditValueChanged = ComboBolumPropertiesEditValueChanged
        Properties.OnInitPopup = ComboBolumPropertiesInitPopup
        TabOrder = 1
        Width = 153
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 1204
        Height = 26
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 24
        ButtonWidth = 48
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
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 2
        Transparent = True
        object ToolBar2: TToolBar
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 912
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 48
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
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 0
          Transparent = True
        end
      end
      object GridProjeDetay: TcxGrid
        Left = 0
        Top = 99
        Width = 1210
        Height = 559
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnEditChanged = GridDetayViewEditChanged
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.DeletingConfirmation = False
          OptionsView.GroupByBox = False
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'Etiketi'
            DataBinding.FieldName = 'ETIKET'
            DataBinding.IsNullValueType = True
            MinWidth = 150
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Width = 150
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'BILGI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            MinWidth = 400
            Options.Filtering = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Styles.Content = Tablo.cxStyle1
            Width = 400
          end
          object GridDetayViewColumn1: TcxGridDBColumn
            DataBinding.FieldName = 'ORJINAL'
            DataBinding.IsNullValueType = True
            Visible = False
            MinWidth = 64
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Options.ShowCaption = False
          end
          object GridDetayViewColumnsec: TcxGridDBColumn
            Caption = 'Zorunlu'
            DataBinding.FieldName = 'ZORUNLU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxCheckBoxProperties'
            Visible = False
          end
        end
        object cxGridDetay: TcxGridLevel
          GridView = GridDetayView
        end
      end
      object SQLDetay: TcxMemo
        Left = 36
        Top = 141
        Lines.Strings = (
          'declare @yeri int'
          'declare @yerid int'
          'declare @bolum nvarchar(20)'
          'set @yeri = :Yeri'
          'set @yerid = :Yerid'
          'set @bolum = :Bolum'
          ''
          'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE '
          'name LIKE '
          #39'#DETAY_:SPID_%'#39')'
          'DROP TABLE #DETAY_:SPID_'
          ''
          'CREATE TABLE #DETAY_:SPID_('
          #9'[SIRA] [smallint] NULL,'
          #9'[ETIKET] [nvarchar](100) NULL,'
          #9'[BILGI] [nvarchar](1000) NULL,'
          #9'[ORJINAL] [nvarchar](1000) NULL,'
          #9'[GIRIS] [nvarchar](50) NULL,'
          #9'[KAYNAK] [nvarchar](255) NULL,'
          '                [ZORUNLU] [bit] NULL'
          ')'
          'INSERT INTO #DETAY_:SPID_'
          'select '
          'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU  '
          'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
          'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
          'where RB.YERI= @yeri and YER_ID= @yerid '
          'and isnull(RA.BOLUM,'#39#39')=@bolum '
          ''
          'union all'
          ''
          
            'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
            '  '
          ' from REHBERAYAR  '
          'where  YERI=@yeri '
          'and isnull(BOLUM,'#39#39')=@Bolum  '
          'and ETIKET not in (select ETIKET from REHBERBILGI where  '
          'YERI=@yeri  and YER_ID= @yerid )'
          ''
          'order by 1'
          ''
          'select * from #DETAY_:SPID_'
          'order by SIRA')
        TabOrder = 4
        Visible = False
        Height = 264
        Width = 387
      end
    end
    object DokumanEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Yorum / Medya'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Tahoma'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Tahoma'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      Caption = 'YorumMedyaPage'
      OnEnterPage = DokumanEkrEnterPage
      object Panel6: TPanel
        Left = 0
        Top = 617
        Width = 1210
        Height = 41
        Align = alBottom
        TabOrder = 0
        object MemoChat: TcxRichEdit
          Left = 1
          Top = 1
          Align = alClient
          Properties.ScrollBars = ssVertical
          TabOrder = 1
          Height = 39
          Width = 1062
        end
        object BtnMesajGonder: TcxButton
          Left = 1063
          Top = 1
          Width = 85
          Height = 39
          Align = alRight
          OptionsImage.ImageIndex = 39
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 0
          OnClick = BtnMesajGonderClick
        end
        object BtnDosyaGonder: TcxButton
          Left = 1148
          Top = 1
          Width = 61
          Height = 39
          Align = alRight
          DropDownMenu = YorumAtacMenu
          Kind = cxbkDropDown
          OptionsImage.ImageIndex = 38
          OptionsImage.Images = Tablo.cxImageList1
          TabOrder = 2
        end
      end
      object labelFileName: TcxLabel
        Left = 0
        Top = 597
        ParentCustomHint = False
        Align = alBottom
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        Style.Edges = [bLeft, bRight]
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.Shadow = False
        Style.IsFontAssigned = True
        Properties.Alignment.Horz = taRightJustify
        Transparent = True
        Visible = False
        AnchorX = 1210
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 1210
        Height = 527
        Align = alClient
        PopupMenu = PopupYorumlar
        TabOrder = 2
        object GridYorumDBCardView1: TcxGridDBCardView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellDblClick = GridYorumDBCardView1CellDblClick
          DataController.DataSource = DtsYorum
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          LayoutDirection = ldVertical
          OptionsView.CardBorderWidth = 1
          OptionsView.CardIndent = 2
          OptionsView.CardWidth = 900
          OptionsView.CategoryIndent = 1
          OptionsView.CategorySeparatorWidth = 1
          OptionsView.CellAutoHeight = True
          OptionsView.CellTextMaxLineCount = 5
          Styles.Content = Tablo.cxStyle6
          Styles.CardBorder = Tablo.cxStyle19
          object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Position.Width = 120
          end
          object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YAZAN'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
          end
          object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
            DataBinding.FieldName = 'ATAC'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repFileExtensionList
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 25
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
            DataBinding.FieldName = 'DOKUMANAD'
            DataBinding.IsNullValueType = True
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = False
            Position.Width = 300
            IsCaptionAssigned = True
          end
          object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
            DataBinding.FieldName = 'YORUM'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxMemoProperties'
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.ScrollBars = ssVertical
            Options.Editing = False
            Options.Focusing = False
            Options.ShowCaption = False
            Position.BeginsLayer = True
            Styles.Content = Tablo.cxStyle12
            Styles.CategoryRow = Tablo.cxStyle4
          end
        end
        object GridYorumLevel1: TcxGridLevel
          GridView = GridYorumDBCardView1
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 700
    Align = alLeft
    TabOrder = 1
    object btnFis: TcxButton
      Left = 0
      Top = 79
      Width = 84
      Height = 29
      Caption = #220'retim Fi'#351'i'
      TabOrder = 0
      OnClick = btnFisClick
    end
    object btnDetay: TcxButton
      Tag = 1
      Left = 0
      Top = 143
      Width = 84
      Height = 29
      Caption = 'Detay'
      TabOrder = 2
      OnClick = btnFisClick
    end
    object btnAsama: TcxButton
      Tag = 2
      Left = 0
      Top = 178
      Width = 84
      Height = 29
      Caption = 'Yorum / Medya'
      TabOrder = 1
      OnClick = btnFisClick
    end
  end
  object TabUretim: TFDQuery
    AfterOpen = TabUretimAfterOpen
    BeforeEdit = TabUretimBeforeEdit
    BeforePost = TabUretimBeforePost
    AfterPost = TabUretimAfterPost
    BeforeDelete = TabUretimBeforeDelete
    AfterScroll = TabUretimAfterScroll
    OnNewRecord = TabUretimNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select FB.*,'
      
        'ISTASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.ISYERI' +
        '), '
      
        'LOKASYON,LOKASYONADI=(select L.ACIKLAMA from LOKASYON L where L.' +
        'ID=FB.LOKASYON),'
      
        'SATICIKODU,SORUMLUADI=(select R.FIRMA from REHBER R where R.ID=F' +
        'B.SATICIKODU),'
      
        'ONAYLAYANADI=(select R.FIRMA from REHBER R where R.ID=FB.ONAYLAY' +
        'AN)'
      'from FATBASLIK FB  where FB. ID=:PID and FB.TUR=6')
    Left = 156
    Top = 234
  end
  object DtsUretim: TDataSource
    DataSet = TabUretim
    OnStateChange = DtsUretimStateChange
    Left = 181
    Top = 286
  end
  object TabUretimDetay: TFDQuery
    AfterOpen = TabUretimDetayAfterOpen
    AfterInsert = TabUretimDetayAfterInsert
    BeforeEdit = TabUretimDetayBeforeEdit
    BeforePost = TabUretimDetayBeforePost
    AfterPost = TabUretimDetayAfterPost
    AfterCancel = TabUretimDetayAfterCancel
    BeforeDelete = TabUretimDetayBeforeDelete
    AfterDelete = TabUretimDetayAfterDelete
    AfterScroll = TabUretimDetayAfterScroll
    OnNewRecord = TabUretimDetayNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      'F.*,'
      '  KOD = (select S.KOD from STOKLAR S where S.ID=F.URUNID),'
      '  AD  =  (select S.STOKADI from STOKLAR S where S.ID=F.URUNID),'
      
        '  URUNNO =  CASE WHEN F.TUR =1 THEN (SELECT URUNNO FROM STOKLAR ' +
        'WHERE ID = F.URUNID ) ELSE  '#39#39'  END,'
      
        '  BIRIMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2702 an' +
        'd DEGER=F.BIRIM AND DIL=-1),'
      'FIRMA=(select R.FIRMA from REHBER R where R.ID=F.REHBERID),'
      
        'SON_TPLM_MLYT=ABS(ADET*BIRIMFIYAT), ORT_TPLM_MLYT=ABS(ADET*TUTAR' +
        '),'
      ''
      ' GRP = case when MIKTAR>0 then 1 else 0 end,'
      
        ' STOKDURUM =  [dbo].[fn_Prg_StokEskiDurum] (F.URUNID,(SELECT CIK' +
        'ISDEPO FROM FATBASLIK FB WHERE FB.ID=F.FATBASID),(SELECT FATURAT' +
        'ARIH FROM FATBASLIK FB WHERE FB.ID=F.FATBASID)),'
      
        '  BARKOD=(Select top 1 BARKOD from STOKBARKOD where VARSAYILAN=1' +
        ' and STOKID=F.URUNID),'
      '  EKLEYENAD=(select FIRMA from REHBER where ID = F.EKLEYEN)'
      'from FATURA F '
      ''
      'where FATBASID= :PFatbasID')
    Left = 477
    Top = 241
  end
  object DtsUretimDetay: TDataSource
    DataSet = TabUretimDetay
    OnStateChange = DtsUretimDetayStateChange
    Left = 478
    Top = 285
  end
  object PopupMenuYaz: TPopupMenu
    Left = 307
    Top = 224
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
  object frxUretimDetay: TfrxDBDataset
    UserName = 'UretimDetay'
    CloseDataSource = False
    DataSet = URETIMDETAY
    BCDToCurrency = False
    DataSetOptions = []
    Left = 475
    Top = 331
  end
  object frxUretim: TfrxDBDataset
    UserName = 'Uretim'
    CloseDataSource = False
    DataSet = URETIM
    BCDToCurrency = False
    DataSetOptions = []
    Left = 180
    Top = 340
  end
  object PopupRecete: TPopupMenu
    Left = 281
    Top = 274
    object Reeteler1: TMenuItem
      Caption = 'Re'#231'eteleri D'#252'zenle'
      OnClick = Reeteler1Click
    end
    object ReeteOlarakKaydet1: TMenuItem
      Caption = 'Re'#231'ete Olarak Kaydet'
      OnClick = ReeteOlarakKaydet1Click
    end
    object ReetedenGetir1: TMenuItem
      Caption = 'Re'#231'eteden Getir'
      OnClick = ReetedenGetir1Click
    end
    object ReeteyeGreMiktarAyarla1: TMenuItem
      Caption = 'Re'#231'eteye G'#246're Miktar Ayarla'
      OnClick = ReeteyeGreMiktarAyarla1Click
    end
  end
  object URETIM: TFDQuery
    AfterOpen = TabUretimAfterOpen
    AfterPost = TabUretimAfterPost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select ID,TUR,CIKISDEPO,CIKISDEPOAD=(select D.DEPOADI from DEPOL' +
        'AR D where D.ID=CIKISDEPO),'
      
        'GIRISDEPO,GIRISDEPOAD=(select D.DEPOADI from DEPOLAR D where D.I' +
        'D=GIRISDEPO),'
      
        'BASLAMA_TARIHI=TARIH,BITIS_TARIHI=FATURATARIH,URETIMNO=FATURANO,' +
        'ACIKLAMA,'
      
        'ISTASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.ISYERI' +
        '), '
      
        'LOKASYON,LOKASYONADI=(select L.ACIKLAMA from LOKASYON L where L.' +
        'ID=FB.LOKASYON),'
      
        'SATICIKODU,SORUMLUADI=(select R.FIRMA from REHBER R where R.ID=F' +
        'B.SATICIKODU),'
      
        'ONAYLAYAN,ONAYLAYANADI=(select R.FIRMA from REHBER R where R.ID=' +
        'FB.ONAYLAYAN),'
      'REHBERID,ISYERI, FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI,KUR,'
      
        'STOKID=AKTIVITEID,MIKTAR=STOKISK, LISTE_FIYATI=EKVERGI,MALIYETSO' +
        'N=KDV_TUTARI, MALIYETORT=DOVIZ_TUTARI,'
      'BIRIM=SAYFA,YERI,YERID, DOVIZKUR, DOVIZ_CINSI, DOVIZ_TUTARI'
      'from FATBASLIK FB  where FB. ID=:PID and FB.TUR=6')
    Left = 236
    Top = 242
  end
  object URETIMDETAY: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      
        '  KOD =  CASE WHEN F.TUR =1 THEN (SELECT KOD FROM STOKLAR WHERE ' +
        'ID = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID= F.U' +
        'RUNID )  END,'
      
        '  AD =  CASE WHEN F.TUR =1 THEN (SELECT STOKADI FROM STOKLAR WHE' +
        'RE ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ID = ' +
        'F.URUNID)  END,'
      
        '  BIRIMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2702 an' +
        'd DEGER=F.BIRIM AND DIL=-1),'
      
        '  SONMALIYET= BIRIMFIYAT, ORTMALIYET=TUTAR,PARABIRIMI=KUR,DOVIZK' +
        'URDEGERI,DOVIZ_SONMALIYET=DOVIZ_BIRIMFIYAT,DOVIZ_ORTMALIYET=DOVI' +
        'Z_TUTARI,'
      '  DOVIZ=DOVIZ_KURU,'
      '  ANAURUN=VADE,'
      '  GRP = case when MIKTAR>0 then 1 else 0 end,'
      
        '  STOKDURUM = [dbo].[fn_Prg_StokEskiDurum] (F.URUNID,(select top' +
        ' 1 CIKISDEPO from FATBASLIK where ID=F.FATBASID),(select top 1 F' +
        'ATURATARIH from FATBASLIK where ID=F.FATBASID)),'
      
        '  GEREKSINIM = [dbo].[fn_Prg_StokEskiDurum] (F.URUNID,(select to' +
        'p 1 CIKISDEPO from FATBASLIK where ID=F.FATBASID),(select top 1 ' +
        'FATURATARIH from FATBASLIK where ID=F.FATBASID)),'
      
        '  BARKOD=(Select top 1 BARKOD from STOKBARKOD where VARSAYILAN=1' +
        ' and STOKID=F.URUNID),'
      '  EKLEYENAD=(select FIRMA from REHBER where ID = F.EKLEYEN), F.*'
      'from FATURA F where FATBASID=:PFatbasID')
    Left = 613
    Top = 233
  end
  object PopupMenuDonustur: TPopupMenu
    Left = 280
    Top = 336
    object rnOlarak1: TMenuItem
      Tag = 415
      Caption = #220'r'#252'n Olarak'
      OnClick = BtnDonusturClick
    end
    object SarfOlarak1: TMenuItem
      Tag = 420
      Caption = 'Sarf Olarak'
      OnClick = BtnDonusturClick
    end
  end
  object PopupGenel: TPopupMenu
    OnPopup = PopupGenelPopup
    Left = 58
    Top = 328
    object IzlemBilgileriGorDegistirMenu: TMenuItem
      Caption = #304'zlem Bilgileri G'#246'r/De'#287'i'#351'tir'
      OnClick = IzlemBilgileriGorDegistirMenuClick
    end
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 759
    Top = 317
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU,' +
        'RA.BOLUM '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id '
      'and RA.BOLUM=:Bolum  '
      'order by  1')
    Left = 688
    Top = 283
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 767
    Top = 405
  end
  object ADOQuery1: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      
        'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU,' +
        'RA.BOLUM '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id '
      'and RA.BOLUM=:Bolum  '
      'order by  1')
    Left = 696
    Top = 371
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 809
    Top = 273
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 827
    Top = 340
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 848
    Top = 184
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      OnClick = DkmanSil1Click
    end
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    appearance.Gradient1Start = 15722724
    appearance.Gradient1End = 14599608
    appearance.Gradient2Start = 14203563
    appearance.Gradient2End = 15722724
    appearance.MarginX = 4
    appearance.MarginY = 2
    appearance.SeparatorLeading = 6
    appearance.GutterWidth = 26
    appearance.SeparatorBackgroundColor = 15656925
    appearance.SeparatorLineColor = 12961221
    appearance.GutterColor = 15658729
    appearance.ItemBackgroundColor = 16448250
    appearance.ItemSelectedColor = 15128011
    appearance.FontColor = 7214336
    appearance.FontDisabledColor = 14599640
    style = msDefault
    Left = 456
    Top = 444
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      ImageName = 'PngImage0'
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      ImageName = 'PngImage16'
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object Query20: TFDQuery
    Connection = Tablo.FDCnn
    Left = 34
    Top = 243
  end
  object TabIsZaman: TFDQuery
    AfterOpen = TabIsZamanAfterOpen
    OnCalcFields = TabIsZamanCalcFields
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      'UO.*,'
      '----SURE=[dbo].[fn_TarihFarkiFormatli]( BASLAMA, BITIS ),'
      
        'SORUMLUADI=(select r.FIRMA from REHBER R where UO.PERSONEL=R.ID)' +
        ','
      
        'LOKASYONADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.LOKASY' +
        'ON=L1.ID),'
      
        'KAYNAKADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.KAYNAK=L' +
        '1.ID)'
      'from URETIMOPERASYONPERSONEL UO '
      'where UO.OPERASYONID=:PRM1'
      'and YER=2'
      'and  UO.DURUM<=:PRM2')
    Left = 917
    Top = 304
    object TabIsZamanID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabIsZamanOPERASYONID: TIntegerField
      FieldName = 'OPERASYONID'
    end
    object TabIsZamanTARIH: TSQLTimeStampField
      FieldName = 'TARIH'
    end
    object TabIsZamanPERSONEL: TIntegerField
      FieldName = 'PERSONEL'
    end
    object TabIsZamanLOKASYON: TIntegerField
      FieldName = 'LOKASYON'
    end
    object TabIsZamanKAYNAK: TIntegerField
      FieldName = 'KAYNAK'
    end
    object TabIsZamanBASLAMA: TSQLTimeStampField
      FieldName = 'BASLAMA'
    end
    object TabIsZamanBITIS: TSQLTimeStampField
      FieldName = 'BITIS'
    end
    object TabIsZamanMOLA: TSQLTimeStampField
      FieldName = 'MOLA'
    end
    object TabIsZamanSURE: TTimeField
      FieldKind = fkCalculated
      FieldName = 'SURE'
      Calculated = True
    end
    object TabIsZamanADET: TFloatField
      FieldName = 'ADET'
    end
    object TabIsZamanBIRIM: TIntegerField
      FieldName = 'BIRIM'
    end
    object TabIsZamanMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object TabIsZamanKONUSU: TWideStringField
      FieldName = 'KONUSU'
      Size = 100
    end
    object TabIsZamanDURUM: TWordField
      FieldName = 'DURUM'
    end
    object TabIsZamanEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabIsZamanEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabIsZamanDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabIsZamanDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabIsZamanLOKASYONADI: TWideStringField
      FieldName = 'LOKASYONADI'
      ReadOnly = True
      Size = 100
    end
    object TabIsZamanKAYNAKADI: TWideStringField
      FieldName = 'KAYNAKADI'
      ReadOnly = True
      Size = 100
    end
    object TabIsZamanSORUMLUADI: TWideStringField
      FieldName = 'SORUMLUADI'
      ReadOnly = True
      Size = 120
    end
    object TabIsZamanACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 150
    end
    object TabIsZamanYER: TSmallintField
      FieldName = 'YER'
    end
  end
  object DtsIsZaman: TDataSource
    DataSet = TabIsZaman
    Left = 933
    Top = 412
  end
  object frxIsZaman: TfrxDBDataset
    UserName = 'UrOperasyonPersonel'
    CloseDataSource = False
    DataSet = TabIsZaman
    BCDToCurrency = False
    DataSetOptions = []
    Left = 504
    Top = 395
  end
  object PopupMenuIsZaman: TPopupMenu
    OnPopup = PopupGenelPopup
    Left = 282
    Top = 472
    object MenuKopyala: TMenuItem
      Caption = 'Sat'#305'r'#305' kopyala'
      OnClick = MenuKopyalaClick
    end
  end
  object PopupIsZamanPer: TPopupMenu
    Left = 109
    Top = 568
    object MenuTumKonular: TMenuItem
      Caption = 'T'#252'm '#304#351' Emri Konular'#305'n'#305' Ekle'
      OnClick = MenuTumKonularClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object RecetedenKonularEkleMenu: TMenuItem
      Caption = 'Re'#231'eteden Konular'#305' Ekle'
      OnClick = RecetedenKonularEkleMenuClick
    end
  end
end
