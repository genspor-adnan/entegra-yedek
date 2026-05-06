object SiparisWizardDlg: TSiparisWizardDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Belge Sihirbaz'#305
  ClientHeight = 658
  ClientWidth = 1366
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 86
    Height = 658
    Align = alLeft
    TabOrder = 0
    object FaturaTus: TcxButton
      Left = 3
      Top = 80
      Width = 80
      Height = 29
      Caption = 'Sipari'#351
      Enabled = False
      TabOrder = 0
      OnClick = FaturaTusClick
    end
    object DetayTus: TcxButton
      Tag = 1
      Left = 3
      Top = 109
      Width = 80
      Height = 29
      Caption = 'Detay'
      Enabled = False
      TabOrder = 1
      OnClick = FaturaTusClick
    end
    object DokumanTus: TcxButton
      Tag = 3
      Left = 3
      Top = 167
      Width = 80
      Height = 29
      Caption = 'Yorum/Medya'
      Enabled = False
      TabOrder = 2
      OnClick = FaturaTusClick
    end
  end
  object WizardKontrol: TJvWizard
    Left = 86
    Top = 0
    Width = 1280
    Height = 658
    ActivePage = SiparisEkr
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
      1280
      658)
    object SiparisEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Sipari'#351' bilgileri'
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
      EnabledButtons = [bkLast, bkNext, bkFinish, bkCancel, bkHelp]
      VisibleButtons = [bkNext, bkFinish, bkCancel]
      OnEnterPage = SiparisEkrEnterPage
      OnPage = SiparisEkrPage
      OnNextButtonClick = SiparisEkrNextButtonClick
      object LabelAd: TcxLabel
        Left = 178
        Top = 37
        Cursor = crHandPoint
        ParentCustomHint = False
        AutoSize = False
        Caption = 'Ad'#305
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        Style.BorderStyle = ebsNone
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.Shadow = False
        Style.TransparentBorder = True
        Style.IsFontAssigned = True
        Properties.LabelEffect = cxleCool
        Properties.LabelStyle = cxlsRaised
        Properties.WordWrap = True
        Transparent = True
        OnClick = LabelAdClick
        Height = 28
        Width = 584
      end
      object LabelKod: TcxLabel
        Left = 178
        Top = 3
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'Kodu'
        DragCursor = crDefault
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -16
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabelKodClick
        Height = 28
        Width = 176
      end
      object lblMusteriAdres: TcxLabel
        Left = 768
        Top = 34
        AutoSize = False
        Caption = 'Adres'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clGray
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        Height = 30
        Width = 402
      end
      object lblMusteriTel: TcxLabel
        Left = 768
        Top = 3
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
      object lblMusteriEposta: TcxLabel
        Left = 768
        Top = 19
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
      object Panel3: TPanel
        Left = 0
        Top = 70
        Width = 1280
        Height = 380
        Align = alClient
        Caption = 'Panel3'
        TabOrder = 5
        object Panel2: TPanel
          Left = 1
          Top = 218
          Width = 1278
          Height = 161
          Align = alClient
          TabOrder = 0
          object GridFatura: TcxGrid
            AlignWithMargins = True
            Left = 4
            Top = 31
            Width = 1270
            Height = 126
            Align = alClient
            PopupMenu = PopupMenuFatura
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            LookAndFeel.SkinName = 'LondonLiquidSky'
            object GridFaturaView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridFaturaViewCanFocusRecord
              OnCellDblClick = GridFaturaViewCellDblClick
              DataController.DataSource = DtsTabSiparisDetay
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <
                item
                  Kind = skSum
                  FieldName = 'ISKTUTAR'
                  Column = ColumnIskTutari
                  VisibleForCustomization = False
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skCount
                  Column = GridFaturaViewAD
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Column = GridFaturaViewADET1
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Column = GridFaturaViewTUTAR1
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Column = GridFaturaViewDOVIZ_TUTARI
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.AlwaysShowEditor = True
              OptionsBehavior.FocusCellOnTab = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsSelection.MultiSelect = True
              OptionsSelection.HideFocusRectOnExit = False
              OptionsView.Footer = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              object GridFaturaViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Options.Editing = False
              end
              object GridFaturaViewPOZNO: TcxGridDBColumn
                Caption = 'Poz No'
                DataBinding.FieldName = 'POZNO'
              end
              object GridFaturaViewTUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepFatDetayTur
                Options.Editing = False
                Width = 76
              end
              object GridFaturaViewTESLIMTARIHI: TcxGridDBColumn
                Caption = 'Teslim Tarihi'
                DataBinding.FieldName = 'TESLIMTARIHI'
                Visible = False
                Options.Editing = False
                Width = 78
              end
              object GridFaturaViewURUNNO: TcxGridDBColumn
                Caption = #220'r'#252'n No'
                DataBinding.FieldName = 'URUNNO'
                Width = 80
              end
              object GridFaturaViewEN: TcxGridDBColumn
                Caption = 'En'
                DataBinding.FieldName = 'EN'
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 60
              end
              object GridFaturaViewBOY: TcxGridDBColumn
                Caption = 'Boy'
                DataBinding.FieldName = 'BOY'
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 60
              end
              object GridFaturaViewYUZEY: TcxGridDBColumn
                Caption = 'Yuzey'
                DataBinding.FieldName = 'YUZEY'
                RepositoryItem = Tablo.RepCurrencyGenel
                Options.Editing = False
                Width = 70
              end
              object GridFaturaViewSAYI: TcxGridDBColumn
                Caption = 'Sayi'
                DataBinding.FieldName = 'SAYI'
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 55
              end
              object GridFaturaViewKOD1: TcxGridDBColumn
                Caption = 'Kod'
                DataBinding.FieldName = 'KOD'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Alignment.Horz = taLeftJustify
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 53
              end
              object GridFaturaViewAD: TcxGridDBColumn
                Caption = 'Ad'
                DataBinding.FieldName = 'AD'
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Options.Editing = False
                Width = 87
              end
              object GridFaturaViewRESIM: TcxGridDBColumn
                Caption = 'Resim'
                DataBinding.FieldName = 'RESIM'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.DropDownRows = 1
                Properties.Images = Tablo.imgScheduler
                Properties.Items = <
                  item
                    Value = 0
                  end
                  item
                    ImageIndex = 19
                    Value = 1
                  end>
                Properties.OnButtonClick = GridFaturaViewRESIMPropertiesButtonClick
              end
              object GridFaturaViewDOKUMAN: TcxGridDBColumn
                Caption = 'Dok'#252'man'
                DataBinding.FieldName = 'DOKUMAN'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.DropDownRows = 1
                Properties.Images = Tablo.imgScheduler
                Properties.Items = <
                  item
                    Value = 0
                  end
                  item
                    ImageIndex = 15
                    Value = 1
                  end>
                Properties.OnButtonClick = GridFaturaViewDOKUMANPropertiesButtonClick
              end
              object GridFaturaViewACIKLAMA1: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridFaturaViewACIKLAMA1PropertiesButtonClick
                Options.Editing = False
                Width = 91
              end
              object GridFaturaViewADET1: TcxGridDBColumn
                Caption = 'Adet'
                DataBinding.FieldName = 'ADET'
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.Alignment.Horz = taRightJustify
                Properties.ReadOnly = False
                Options.Editing = False
                Width = 29
              end
              object GridFaturaViewBIRIM1: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                Options.Editing = False
                Width = 42
              end
              object GridFaturaViewBIRIMFIYAT1: TcxGridDBColumn
                Caption = 'Birim Fiyat'
                DataBinding.FieldName = 'BIRIMFIYAT'
                RepositoryItem = Tablo.RepCurrencyBF
                Options.Editing = False
                Width = 84
              end
              object GridFaturaViewISKONTO1: TcxGridDBColumn
                Caption = #304'sk1%'
                DataBinding.FieldName = 'ISKONTO'
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = '0.00;(-0.00)'
                Properties.MaxValue = 100.000000000000000000
                Properties.Nullable = False
                Properties.Nullstring = '0'
                Options.Editing = False
                Width = 34
              end
              object GridFaturaViewISKONTO2: TcxGridDBColumn
                Caption = #304'sk2%'
                DataBinding.FieldName = 'ISKONTO2'
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = '0.00;(-0.00)'
                Properties.MaxValue = 100.000000000000000000
                Properties.Nullable = False
                Properties.Nullstring = '0'
                Options.Editing = False
                Width = 35
              end
              object GridFaturaViewKDV1: TcxGridDBColumn
                DataBinding.FieldName = 'KDV'
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.Alignment.Horz = taRightJustify
                Properties.ReadOnly = False
                Options.Editing = False
                Width = 41
              end
              object GridFaturaViewOTVMIKTAR: TcxGridDBColumn
                Caption = #214'TV'
                DataBinding.FieldName = 'OTVMIKTAR'
                RepositoryItem = Tablo.RepCurrencyGenel
                Options.Editing = False
              end
              object GridFaturaViewURETIMPLANINDAGOSTER: TcxGridDBColumn
                Caption = #220'retim Plan'#305'nda G'#246'z'#252'ks'#252'n'
                DataBinding.FieldName = 'URETIMPLANINDAGOSTER'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.Alignment = taRightJustify
                Properties.AllowGrayed = True
                Properties.ValueChecked = '1'
                Properties.ValueUnchecked = '0'
                Options.Editing = False
                Width = 51
              end
              object GridFaturaViewTUTAR1: TcxGridDBColumn
                Caption = 'Tutar'
                DataBinding.FieldName = 'TUTAR'
                RepositoryItem = Tablo.RepCurrencyGenel
                HeaderAlignmentHorz = taCenter
                Options.Editing = False
                Width = 91
              end
              object ColumnIskTutari: TcxGridDBColumn
                DataBinding.FieldName = 'ISKTUTAR'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Visible = False
                Options.Editing = False
                VisibleForCustomization = False
              end
              object GridFaturaViewMASRAFKOD: TcxGridDBColumn
                Caption = 'Masraf Kodu'
                DataBinding.FieldName = 'MASRAFKOD'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Visible = False
                Options.Editing = False
                Width = 77
              end
              object GridFaturaViewKUR: TcxGridDBColumn
                Caption = 'P.Birimi'
                DataBinding.FieldName = 'KUR'
                RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
                Options.Editing = False
                Width = 47
              end
              object GridFaturaViewMASRAFAD: TcxGridDBColumn
                Caption = 'Masraf Ad'#305
                DataBinding.FieldName = 'MASRAFID'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridFaturaViewMASRAFADPropertiesButtonClick
                Visible = False
                OnGetDisplayText = GridFaturaViewMASRAFADGetDisplayText
                Options.Editing = False
                Width = 130
              end
              object GridFaturaViewIZLEME: TcxGridDBColumn
                Caption = #304'zleme'
                DataBinding.FieldName = 'IZLEME'
                RepositoryItem = Tablo.RepStokIzleme
                Visible = False
                Options.Editing = False
                Width = 59
              end
              object GridFaturaViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn
                Caption = 'D'#246'viz Birim Fiyat'
                DataBinding.FieldName = 'DOVIZ_BIRIMFIYAT'
                RepositoryItem = Tablo.RepCurrencyBF
                Options.Editing = False
              end
              object GridFaturaViewDOVIZ_KURU: TcxGridDBColumn
                Caption = 'D'#246'viz Cinsi'
                DataBinding.FieldName = 'DOVIZ_KURU'
                RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
                Options.Editing = False
                Width = 61
              end
              object GridFaturaViewDOVIZ_TUTARI: TcxGridDBColumn
                Caption = 'D'#246'viz Tutar'#305
                DataBinding.FieldName = 'DOVIZ_TUTARI'
                RepositoryItem = Tablo.RepCurrencyGenel
                Options.Editing = False
                Width = 68
              end
              object GridFaturaViewDOVIZKURDEGERI: TcxGridDBColumn
                Caption = 'D'#246'viz Kuru'
                DataBinding.FieldName = 'DOVIZKURDEGERI'
                RepositoryItem = Tablo.RepCurrencyDovizKuru
                Options.Editing = False
                Width = 80
              end
              object GridFaturaViewPROJEKODU: TcxGridDBColumn
                Caption = 'Proje Kodu'
                DataBinding.FieldName = 'PROJEKODU'
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
                Properties.OnButtonClick = GridFaturaViewPROJEKODUPropertiesButtonClick
                Visible = False
                Options.Editing = False
                Width = 210
              end
              object GridFaturaViewOZELKOD: TcxGridDBColumn
                Caption = #214'zel Kod'
                DataBinding.FieldName = 'OZELKOD'
                PropertiesClassName = 'TcxTextEditProperties'
                Visible = False
              end
              object GridFaturaViewOZELKOD2: TcxGridDBColumn
                Caption = #214'zel Kod2'
                DataBinding.FieldName = 'OZELKOD2'
                PropertiesClassName = 'TcxTextEditProperties'
                Visible = False
              end
              object GridFaturaViewSTOKDURUM: TcxGridDBColumn
                Caption = 'Stok Durum'
                DataBinding.FieldName = 'STOKDURUM'
                Visible = False
                Options.Editing = False
              end
              object GridFaturaViewEKIPMAN: TcxGridDBColumn
                Caption = 'Ekipman'
                DataBinding.FieldName = 'EKIPMAN'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridFaturaViewEKIPMANIDPropertiesButtonClick
                Visible = False
                Options.Editing = False
                Width = 300
              end
              object GridFaturaViewSERINO: TcxGridDBColumn
                Caption = 'Serino'
                DataBinding.FieldName = 'SERINO'
                Visible = False
                Options.Editing = False
              end
              object GridFaturaViewMF: TcxGridDBColumn
                DataBinding.FieldName = 'MF'
                Visible = False
                Options.Editing = False
              end
              object GridFaturaViewVADE: TcxGridDBColumn
                Caption = 'Vade'
                DataBinding.FieldName = 'VADE'
                Visible = False
                Options.Editing = False
              end
              object GridFaturaViewISKONTOLUBRMFIYAT: TcxGridDBColumn
                Caption = #304'skontolu Birim Fiyat'
                DataBinding.FieldName = 'ISKONTOLUBRMFIYAT'
                RepositoryItem = Tablo.RepCurrencyGenel
                Visible = False
                Options.Editing = False
                Width = 79
              end
              object GridFaturaViewKDVDAHILFIYAT: TcxGridDBColumn
                Caption = 'KDV Dahil Tutar'
                DataBinding.FieldName = 'KDVDAHILFIYAT'
                RepositoryItem = Tablo.RepCurrencyGenel
                Visible = False
                Options.Editing = False
                Width = 100
              end
              object GridFaturaViewMIKTAR: TcxGridDBColumn
                Caption = 'Miktar'
                DataBinding.FieldName = 'MIKTAR'
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
                Visible = False
                Options.Editing = False
                Width = 48
              end
              object GridFaturaViewBIRIM2MIKTAR: TcxGridDBColumn
                Caption = 'Birim2 Miktar'
                DataBinding.FieldName = 'BIRIM2MIKTAR'
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
                Visible = False
                Options.Editing = False
                Width = 73
              end
              object GridFaturaViewBIRIM2AD: TcxGridDBColumn
                Caption = 'Birim2 Ad'
                DataBinding.FieldName = 'BIRIM2AD'
                PropertiesClassName = 'TcxLabelProperties'
                Visible = False
                Options.Editing = False
                Width = 58
              end
              object GridFaturaViewSATICIADI: TcxGridDBColumn
                Caption = 'Personel'
                DataBinding.FieldName = 'SATICIADI'
                Options.Editing = False
                Width = 143
              end
            end
            object GridFaturaLevel1: TcxGridLevel
              GridView = GridFaturaView
            end
          end
          object ToolBar5: TToolBar
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 1270
            Height = 24
            Margins.Bottom = 0
            AutoSize = True
            ButtonWidth = 81
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
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = SatirEkleClick
            end
            object SatirSil: TToolButton
              Left = 81
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = SatirSilClick
            end
            object ToolButton1: TToolButton
              Left = 162
              Top = 0
              Width = 8
              Caption = 'ToolButton4'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Style = tbsSeparator
            end
            object ToolButton9: TToolButton
              Left = 170
              Top = 0
              Caption = 'Alta'
              ImageIndex = 3
              ImageName = 'PngImage3'
            end
            object ToolButton13: TToolButton
              Left = 251
              Top = 0
              Caption = #220'ste'
              ImageIndex = 3
              ImageName = 'PngImage3'
            end
            object TamEkranTus: TToolButton
              Left = 332
              Top = 0
              Caption = 'Tam Ekran'
              ImageIndex = 6
              ImageName = 'PngImage6'
              OnClick = TamEkranTusClick
            end
            object ToolButton4: TToolButton
              Left = 413
              Top = 0
              Width = 8
              Caption = 'ToolButton4'
              ImageIndex = 7
              ImageName = 'PngImage7'
              Style = tbsSeparator
            end
            object BtnDonustur: TToolButton
              Left = 421
              Top = 0
              Caption = 'D'#246'n'#252#351't'#252'r'
              ImageIndex = 7
              ImageName = 'PngImage7'
              OnClick = BtnDonusturClick
            end
            object BtnDovizKuru: TToolButton
              Left = 502
              Top = 0
              Caption = 'D'#246'viz Kuru'
              ImageIndex = 9
              ImageName = 'PngImage9'
              OnClick = BtnDovizKuruClick
            end
            object ToolButton3: TToolButton
              Left = 583
              Top = 0
              Width = 8
              Caption = 'ToolButton3'
              ImageIndex = 8
              ImageName = 'PngImage15'
              Style = tbsSeparator
            end
          end
        end
        object PageUst: TcxPageControl
          Left = 1
          Top = 36
          Width = 1278
          Height = 182
          Align = alTop
          TabOrder = 1
          Properties.ActivePage = TabSheetGenelBilgiler
          Properties.CustomButtons.Buttons = <>
          OnChange = PageUstChange
          ClientRectBottom = 178
          ClientRectLeft = 4
          ClientRectRight = 1274
          ClientRectTop = 27
          object TabSheetGenelBilgiler: TcxTabSheet
            Caption = 'Genel Bilgiler'
            ImageIndex = 0
            PopupMenu = PopupMenuFatura
            object PanelUst2: TPanel
              Left = 0
              Top = 0
              Width = 1270
              Height = 151
              Align = alClient
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
              object Bevel2: TBevel
                Left = 673
                Top = 2
                Width = 347
                Height = 160
              end
              object LabelMasrafMerkezi: TcxLabel
                Left = 334
                Top = 52
                Caption = 'Masraf Merkezi'
                Transparent = True
              end
              object Label11: TcxLabel
                Left = 676
                Top = 26
                Caption = 'Durum'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object LabelFaturaTarihi: TcxLabel
                Left = 676
                Top = 73
                Caption = 'Sipari'#351' Tarihi'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object LabelFatNo: TcxLabel
                Left = 676
                Top = 99
                Caption = 'Sipari'#351' Seri/No'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label5: TcxLabel
                Left = 676
                Top = 50
                Caption = 'KDV'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object Label6: TcxLabel
                Left = 676
                Top = 5
                Caption = 'ID'
                ParentFont = False
                Transparent = True
              end
              object ComboSiparisDURUM: TcxDBImageComboBox
                Left = 783
                Top = 24
                RepositoryItem = Tablo.repSiparisDurumAlinan
                DataBinding.DataField = 'DURUM'
                DataBinding.DataSource = DtsTabSiparis
                Properties.ImmediatePost = True
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
                Width = 100
              end
              object EditFatTarih: TcxDBDateEdit
                Left = 783
                Top = 72
                DataBinding.DataField = 'SIPARISTARIH'
                DataBinding.DataSource = DtsTabSiparis
                Properties.ShowTime = False
                TabOrder = 13
                Width = 147
              end
              object EditFatNo: TcxDBTextEdit
                Left = 832
                Top = 98
                DataBinding.DataField = 'SIPARISNO'
                DataBinding.DataSource = DtsTabSiparis
                TabOrder = 20
                Width = 99
              end
              object cbKdvDurum: TcxDBComboBox
                Left = 783
                Top = 48
                DataBinding.DataField = 'KDVDURUM'
                DataBinding.DataSource = DtsTabSiparis
                Properties.DropDownListStyle = lsFixedList
                Properties.Items.Strings = (
                  'Hari'#231
                  'Dahil'
                  'Muaf')
                Properties.MaxLength = 0
                Properties.OnCloseUp = cbKdvDurumPropertiesCloseUp
                Style.LookAndFeel.NativeStyle = False
                Style.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleDisabled.LookAndFeel.NativeStyle = False
                StyleDisabled.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleFocused.LookAndFeel.NativeStyle = False
                StyleFocused.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleHot.LookAndFeel.NativeStyle = False
                StyleHot.LookAndFeel.SkinName = 'LondonLiquidSky'
                StyleReadOnly.LookAndFeel.NativeStyle = False
                StyleReadOnly.LookAndFeel.SkinName = 'LondonLiquidSky'
                TabOrder = 11
                Width = 216
              end
              object cbFaturaTur: TcxDBImageComboBox
                Left = 452
                Top = 2
                RepositoryItem = Tablo.RepKasaTurleriReadOnly
                DataBinding.DataField = 'TUR'
                DataBinding.DataSource = DtsTabSiparis
                Enabled = False
                Properties.ImageAlign = iaRight
                Properties.Items = <>
                Style.Color = clWhite
                TabOrder = 2
                Width = 218
              end
              object cbStokDepo: TcxDBImageComboBox
                Left = 452
                Top = 27
                DataBinding.DataSource = DtsTabSiparis
                Enabled = False
                Properties.ImageAlign = iaRight
                Properties.Items = <>
                TabOrder = 9
                Width = 218
              end
              object EditFaturaSaat: TcxDBTimeEdit
                Left = 932
                Top = 98
                DataBinding.DataField = 'SIPARISTARIH'
                DataBinding.DataSource = DtsTabSiparis
                TabOrder = 14
                Width = 67
              end
              object cxDBLabel1: TcxDBLabel
                Left = 783
                Top = 4
                DataBinding.DataField = 'ID'
                DataBinding.DataSource = DtsTabSiparis
                Transparent = True
                Height = 21
                Width = 74
              end
              object BaslikPaneli: TPanel
                Left = 11
                Top = 2
                Width = 316
                Height = 147
                BevelEdges = []
                BevelOuter = bvNone
                Color = 11776947
                ParentBackground = False
                TabOrder = 0
                object Label22: TcxLabel
                  Left = 1
                  Top = 3
                  Caption = 'Ba'#351'l'#305'k'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object Label24: TcxLabel
                  Left = 1
                  Top = 31
                  Caption = 'Adres'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object Label2: TcxLabel
                  Left = 1
                  Top = 74
                  Caption = #304'l'#231'e'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object Label25: TcxLabel
                  Left = 1
                  Top = 98
                  Caption = 'VD'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object Label3: TcxLabel
                  Left = 169
                  Top = 75
                  Caption = #304'l'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object Label26: TcxLabel
                  Left = 169
                  Top = 100
                  Caption = 'VNo'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object EditBASLIK: TcxDBTextEdit
                  Left = 70
                  Top = 2
                  DataBinding.DataField = 'BASLIK'
                  DataBinding.DataSource = DtsTabSiparis
                  TabOrder = 0
                  Width = 241
                end
                object MemoFatAdres: TcxDBMemo
                  Left = 70
                  Top = 27
                  DataBinding.DataField = 'ADRES'
                  DataBinding.DataSource = DtsTabSiparis
                  TabOrder = 2
                  Height = 44
                  Width = 241
                end
                object EditILCE: TcxDBTextEdit
                  Left = 70
                  Top = 72
                  DataBinding.DataField = 'ILCE'
                  DataBinding.DataSource = DtsTabSiparis
                  TabOrder = 4
                  Width = 100
                end
                object EditVD: TcxDBTextEdit
                  Left = 70
                  Top = 97
                  DataBinding.DataField = 'VD'
                  DataBinding.DataSource = DtsTabSiparis
                  TabOrder = 8
                  Width = 100
                end
                object EditVNo: TcxDBTextEdit
                  Left = 198
                  Top = 97
                  DataBinding.DataField = 'VNO'
                  DataBinding.DataSource = DtsTabSiparis
                  TabOrder = 9
                  Width = 113
                end
                object EditIL: TcxDBComboBox
                  Left = 198
                  Top = 72
                  DataBinding.DataField = 'IL'
                  DataBinding.DataSource = DtsTabSiparis
                  TabOrder = 5
                  Width = 113
                end
                object lblSevkAdresi: TcxLabel
                  Left = 1
                  Top = 123
                  Caption = 'Sevk Adresi'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clWindowText
                  Style.Font.Height = -11
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = []
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object btnSevkAdresi: TcxButtonEdit
                  Left = 70
                  Top = 122
                  ParentShowHint = False
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
                  Properties.OnButtonClick = btnSevkAdresiPropertiesButtonClick
                  ShowHint = True
                  TabOrder = 12
                  TextHint = 'REHBERILETID'
                  Width = 241
                end
              end
              object EditFATURASERI: TcxDBTextEdit
                Left = 783
                Top = 98
                DataBinding.DataField = 'SIPARISSERI'
                DataBinding.DataSource = DtsTabSiparis
                TabOrder = 17
                Width = 48
              end
              object EditMM: TcxButtonEdit
                Left = 452
                Top = 52
                ParentShowHint = False
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
                Properties.OnButtonClick = EditMMPropertiesButtonClick
                ShowHint = True
                TabOrder = 12
                Width = 218
              end
              object lblTeklifNo: TcxLabel
                Left = 676
                Top = 124
                Caption = 'Teklif no'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object editTeklifNo: TcxDBTextEdit
                Left = 783
                Top = 123
                DataBinding.DataField = 'KAYNAKBELGENO'
                DataBinding.DataSource = DtsTabSiparis
                Properties.ReadOnly = True
                TabOrder = 26
                Width = 216
              end
              object ComboFIYAT_LISTESI: TcxDBImageComboBox
                Left = 452
                Top = 76
                RepositoryItem = Tablo.RepFiyatAdlari
                DataBinding.DataField = 'FIYAT_LISTESI'
                DataBinding.DataSource = DtsTabSiparis
                Properties.ImmediatePost = True
                Properties.Items = <>
                Properties.OnCloseUp = ComboFIYAT_LISTESIPropertiesCloseUp
                TabOrder = 15
                Width = 109
              end
              object cxLabel2: TcxLabel
                Left = 334
                Top = 77
                Caption = 'Fiyat / Vade'
                Transparent = True
              end
              object cxLabel3: TcxLabel
                Left = 334
                Top = 29
                Caption = 'Depo'
                Transparent = True
              end
              object cxLabel4: TcxLabel
                Left = 333
                Top = 4
                Caption = 'Belge T'#252'r'#252
                Transparent = True
              end
              object EditVade: TcxDBTextEdit
                Left = 561
                Top = 76
                DataBinding.DataField = 'VADE'
                DataBinding.DataSource = DtsTabSiparis
                TabOrder = 16
                Width = 109
              end
              object cxLabel12: TcxLabel
                Left = 334
                Top = 103
                Hint = 'Teklif_Teslim_Sekli'
                HelpType = htKeyword
                HelpKeyword = 'TEKLIF.TESLIM_SEKLI'
                Caption = 'Teslimat / '#214'deme'
                FocusControl = ComboTeslimSekli
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.LookAndFeel.NativeStyle = True
                Style.Shadow = False
                Style.TransparentBorder = True
                Style.IsFontAssigned = True
                StyleDisabled.LookAndFeel.NativeStyle = True
                StyleFocused.LookAndFeel.NativeStyle = True
                StyleHot.LookAndFeel.NativeStyle = True
                Transparent = True
              end
              object ComboTeslimSekli: TcxDBImageComboBox
                Left = 452
                Top = 101
                RepositoryItem = Tablo.repTeklifTeslimSekli
                DataBinding.DataField = 'TESLIM_SEKLI'
                DataBinding.DataSource = DtsTabSiparis
                Properties.Items = <
                  item
                  end>
                TabOrder = 21
                Width = 109
              end
              object ComboODEME: TcxDBImageComboBox
                Left = 561
                Top = 101
                RepositoryItem = Tablo.repTeklifOdeme
                DataBinding.DataField = 'ODEME'
                DataBinding.DataSource = DtsTabSiparis
                Properties.Items = <>
                TabOrder = 28
                Width = 109
              end
              object cxLabel14: TcxLabel
                Left = 334
                Top = 128
                Hint = 'Teklif_'#214'deme'
                HelpType = htKeyword
                HelpKeyword = 'TEKLIF.ODEME'
                Caption = #214'zel Kod / '#214'zel Kod2'
                FocusControl = ComboODEME
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
                Left = 882
                Top = 24
                RepositoryItem = Tablo.RepSubelerKendiSubesi
                DataBinding.DataField = 'SUBEID'
                DataBinding.DataSource = DtsTabSiparis
                Properties.ImmediatePost = True
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
                TabOrder = 6
                Width = 115
              end
              object LblSube: TcxLabel
                Left = 721
                Top = 26
                Caption = '/ '#350'ube'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clWindowText
                Style.Font.Height = -11
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object EditOZELKOD: TcxDBTextEdit
                Left = 452
                Top = 126
                DataBinding.DataField = 'OZELKOD'
                DataBinding.DataSource = DtsTabSiparis
                TabOrder = 30
                Width = 109
              end
              object EditOZELKOD2: TcxDBTextEdit
                Left = 562
                Top = 126
                DataBinding.DataField = 'OZELKOD2'
                DataBinding.DataSource = DtsTabSiparis
                TabOrder = 31
                Width = 109
              end
            end
          end
          object SheetGenotip: TcxTabSheet
            Caption = 'Hasta Bilgileri'
            ImageIndex = 2
            object cxGroupBox1: TcxGroupBox
              Left = 15
              Top = 0
              Caption = 'Hasta Bilgisi'
              TabOrder = 0
              Height = 142
              Width = 388
              object cxLabel9: TcxLabel
                Left = 16
                Top = 24
                Caption = 'Ad'#305' Soyad'#305' '
                Transparent = True
              end
              object EditAd: TcxTextEdit
                Left = 95
                Top = 22
                TabOrder = 1
                Width = 249
              end
              object cxLabel10: TcxLabel
                Left = 16
                Top = 50
                Caption = 'TCKN'
                Transparent = True
              end
              object EditTCKN: TcxTextEdit
                Left = 95
                Top = 48
                TabOrder = 3
                Width = 249
              end
              object cxLabel11: TcxLabel
                Left = 16
                Top = 76
                Caption = 'Kimlik ID'
                Transparent = True
              end
              object EditKimlikId: TcxTextEdit
                Left = 95
                Top = 74
                TabOrder = 5
                Width = 249
              end
              object cxLabel13: TcxLabel
                Left = 16
                Top = 102
                Caption = 'Sorumlu'
                Transparent = True
              end
              object EditSorumlu: TcxTextEdit
                Left = 95
                Top = 100
                TabOrder = 7
                Width = 249
              end
            end
            object cxGroupBox2: TcxGroupBox
              Left = 431
              Top = 0
              Caption = 'Geli'#351' Bilgisi'
              TabOrder = 1
              Height = 142
              Width = 388
              object cxLabel15: TcxLabel
                Left = 16
                Top = 17
                Caption = 'Kurumu'
                Transparent = True
              end
              object EditKurumu: TcxTextEdit
                Left = 95
                Top = 15
                TabOrder = 1
                Width = 249
              end
              object cxLabel16: TcxLabel
                Left = 16
                Top = 42
                Cursor = crHandPoint
                Caption = 'Poliklinik'
                Transparent = True
                OnClick = cxLabel16Click
              end
              object EditPoliklinik: TcxTextEdit
                Left = 95
                Top = 40
                TabOrder = 3
                Width = 249
              end
              object cxLabel18: TcxLabel
                Left = 16
                Top = 67
                Caption = 'Doktor'
                Transparent = True
              end
              object EditDoktor: TcxTextEdit
                Left = 95
                Top = 65
                TabOrder = 5
                Width = 249
              end
              object cxLabel19: TcxLabel
                Left = 16
                Top = 92
                Cursor = crHandPoint
                Caption = 'Referans'
                Transparent = True
                OnClick = cxLabel19Click
              end
              object EditReferans: TcxTextEdit
                Left = 95
                Top = 90
                TabOrder = 7
                Width = 249
              end
              object cxLabel20: TcxLabel
                Left = 17
                Top = 117
                Caption = 'G'#246'nderen'
                Transparent = True
              end
              object EditGonderen: TcxTextEdit
                Left = 96
                Top = 115
                TabOrder = 9
                Width = 249
              end
            end
          end
          object TabSheetEkAlanlar: TcxTabSheet
            Caption = 'Ek Alanlar'
            ImageIndex = 1
            object PanelAlt: TPanel
              Left = 0
              Top = -92
              Width = 1270
              Height = 243
              Align = alBottom
              BevelOuter = bvNone
              TabOrder = 0
            end
            object PanelUst: TPanel
              Left = 0
              Top = 0
              Width = 1270
              Height = 117
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 1
            end
          end
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 1272
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 72
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
            Left = 72
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Style = tbsTextButton
            Visible = False
          end
          object ToolButton8: TToolButton
            Left = 144
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 9
            ImageName = 'PngImage8'
            Style = tbsSeparator
          end
          object YaziciYaz: TToolButton
            Left = 152
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
          object ToolButton2: TToolButton
            Left = 224
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Style = tbsSeparator
          end
          object btnEPosta: TToolButton
            Left = 232
            Top = 0
            Caption = 'E-Posta'
            ImageIndex = 41
            ImageName = 'PngImage41'
            OnClick = BaskiOnizlemeMenuClick
          end
        end
      end
      object PageControlAlt: TcxPageControl
        Left = 0
        Top = 450
        Width = 1280
        Height = 166
        Align = alBottom
        TabOrder = 6
        Properties.ActivePage = cxTabSheet1
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 162
        ClientRectLeft = 4
        ClientRectRight = 1276
        ClientRectTop = 27
        object cxTabSheet1: TcxTabSheet
          Caption = 'Genel'
          ImageIndex = 0
          object gridFatToplam: TcxGrid
            Left = 963
            Top = 0
            Width = 309
            Height = 135
            Align = alRight
            BorderStyle = cxcbsNone
            Enabled = False
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = False
            object tvFatToplamlar: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = dtsTOPLAMLAR
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.Deleting = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsSelection.HideSelection = True
              OptionsView.GridLineColor = 11776947
              OptionsView.GridLines = glNone
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              OptionsView.RowSeparatorColor = 11776947
              Styles.Background = Tablo.cxStyle19
              Styles.Content = Tablo.cxStyle19
              object tvFatToplamlarTUR: TcxGridDBColumn
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object tvFatToplamlarACIKLAMA: TcxGridDBColumn
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Width = 130
              end
              object tvFatToplamlarDEGER: TcxGridDBColumn
                DataBinding.FieldName = 'DEGER'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 60
              end
              object tvFatToplamlarKUR: TcxGridDBColumn
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
                Width = 25
              end
              object tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn
                DataBinding.FieldName = 'DOVIZTUTARI'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 60
              end
              object tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn
                DataBinding.FieldName = 'DOVIZ_KURU'
                DataBinding.IsNullValueType = True
                Width = 25
              end
            end
            object gridFatToplamLevel1: TcxGridLevel
              GridView = tvFatToplamlar
              Options.DetailFrameColor = 11776947
            end
          end
          object MemoNOTLAR: TcxDBMemo
            Left = 312
            Top = 54
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsTabSiparis
            Properties.ScrollBars = ssVertical
            TabOrder = 1
            Height = 80
            Width = 205
          end
          object cxLabel17: TcxLabel
            Left = 271
            Top = 55
            Caption = 'Notlar'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object LabelAktivite: TcxLabel
            Left = -1
            Top = 29
            Caption = 'Ba'#287'l'#305' Akt.'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object LabelProje: TcxLabel
            Left = -1
            Top = 6
            Caption = 'Ba'#287'l'#305' Proje'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object BeditBagliGorev: TcxButtonEdit
            Left = 57
            Top = 28
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Hint = 'Ekle'
                Kind = bkEllipsis
              end
              item
                Caption = '-'
                Hint = 'Sil'
                Kind = bkText
              end>
            Properties.ReadOnly = True
            Properties.OnButtonClick = BeditBagliGorevPropertiesButtonClick
            ShowHint = True
            TabOrder = 5
            Width = 208
          end
          object EditEkVergi: TcxDBCurrencyEdit
            Left = 589
            Top = 56
            DataBinding.DataField = 'EKVERGI'
            DataBinding.DataSource = DtsTabSiparis
            ParentFont = False
            Properties.DisplayFormat = ',0.00;(,0.00)'
            Properties.ReadOnly = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clRed
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            TabOrder = 6
            Width = 65
          end
          object cxDBLabel3: TcxDBLabel
            Left = 656
            Top = 59
            DataBinding.DataField = 'KUR'
            Height = 21
            Width = 29
          end
          object cxLabel1: TcxLabel
            Left = 520
            Top = 59
            Caption = 'Ek Vergi'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cbDovizCinsi: TcxDBComboBox
            Left = 589
            Top = 29
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            DataBinding.DataField = 'DOVIZ_CINSI'
            DataBinding.DataSource = DtsTabSiparis
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            TabOrder = 9
            Width = 65
          end
          object lbDoviz: TcxLabel
            Left = 520
            Top = 31
            Caption = 'Sipari'#351' D'#246'vizi'
          end
          object lbSatici: TcxLabel
            Left = -1
            Top = 80
            Caption = 'Sat'#305'c'#305
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object cxLabel5: TcxLabel
            Left = -1
            Top = 106
            Caption = #304'lgili'
          end
          object BeditProje: TcxButtonEdit
            Left = 57
            Top = 4
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
            Properties.ReadOnly = False
            Properties.OnButtonClick = BeditProjePropertiesButtonClick
            ShowHint = True
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
            TabOrder = 13
            OnDblClick = BeditProjeDblClick
            Width = 208
          end
          object cbSatici: TcxButtonEdit
            Left = 57
            Top = 78
            ParentShowHint = False
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
            Properties.ReadOnly = True
            Properties.OnButtonClick = cbSaticiPropertiesButtonClick
            ShowHint = True
            TabOrder = 14
            Width = 208
          end
          object EditOnaylayan: TcxButtonEdit
            Left = 344
            Top = 28
            Properties.Buttons = <
              item
                Default = True
                Glyph.SourceDPI = 96
                Glyph.Data = {
                  424D360400000000000036000000280000001000000010000000010020000000
                  000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00EFF7EFFF4AA54AFF189418FFA5D6A5FFFFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00EFF7EFFF39A539FF10AD29FF18B529FF089410FFA5D6A5FFFFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FF
                  F7FF39AD39FF18AD31FF18B531FF10AD29FF10B529FF089410FFADDEADFFFFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FFF7FF42B5
                  42FF18B531FF18B539FF18B531FF31BD4AFF18AD31FF10AD29FF089410FFADDE
                  ADFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0052BD5AFF21B5
                  42FF21BD42FF21B542FF10A521FF189418FF63C673FF18B531FF10B529FF0894
                  10FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0039BD4AFF42C6
                  63FF21BD4AFF18B529FF63C663FFEFF7EFFF39AD39FF63C673FF18B531FF10B5
                  29FF109410FFB5DEB5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF009CE7A5FF42C6
                  5AFF39BD4AFF63CE6BFFFFFFFF00FFFFFF00EFF7EFFF31A531FF63CE73FF18B5
                  31FF10B529FF109410FFB5E7B5FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00D6F7
                  D6FFB5EFBDFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00EFF7EFFF31A531FF63CE
                  73FF18B531FF10B529FF109410FFBDDEBDFFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7E7FF29A5
                  29FF63CE73FF18B531FF18B531FF189418FFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7
                  E7FF29A529FF63CE7BFF29BD4AFF299C31FFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00E7F7E7FF31AD31FF31A531FFCEE7CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                Kind = bkGlyph
              end
              item
                Glyph.SourceDPI = 96
                Glyph.Data = {
                  424D360400000000000036000000280000001000000010000000010020000000
                  000000000000C40E0000C40E00000000000000000000FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFEFF7FF3939
                  BDFF2129B5FF8484D6FFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007B7B
                  CEFF7373C6FFD6D6EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF007373CEFF1842
                  F7FF184AF7FF1031D6FF3131BDFFDEDEF7FFFFFFFF00FFFFFF006B6BD6FF0829
                  D6FF0831D6FF0010B5FF7373CEFFFFFFFF00FFFFFF00FFFFFF003131BDFF2152
                  F7FF2152FFFF2152FFFF1842E7FF1821B5FFC6C6EFFF6B6BCEFF1031DEFF1042
                  F7FF1039F7FF0839EFFF0018BDFFA5A5DEFFFFFFFF00FFFFFF00BDBDE7FF1831
                  DEFF295AFFFF2152FFFF2152FFFF184AEFFF0810B5FF1031DEFF184AFFFF1042
                  F7FF1042F7FF1042F7FF0839EFFF4242B5FFFFFFFF00FFFFFF00ADADE7FF2139
                  DEFF396BFFFF295AFFFF295AFFFF295AFFFF2152FFFF1852FFFF184AFFFF184A
                  F7FF1042F7FF1039EFFF1821B5FFBDBDE7FFFFFFFF00FFFFFF00FFFFFF009C9C
                  E7FF2129CEFF396BFFFF316BFFFF295AFFFF295AFFFF2152FFFF214AFFFF184A
                  FFFF1039EFFF3139BDFFE7E7F7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00E7E7F7FF4242CEFF314AE7FF396BFFFF315AFFFF295AFFFF2152FFFF1839
                  E7FF4242BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00B5B5EFFF2142DEFF396BFFFF3163FFFF315AFFFF295AFFFF184A
                  E7FF3131BDFFF7F7FFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF004242D6FF4A7BFFFF4273FFFF396BFFFF396BFFFF295AFFFF215A
                  FFFF1039D6FF6B6BD6FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00D6D6F7FF2939DEFF5284FFFF4273FFFF3963F7FF1018C6FF396BFFFF295A
                  FFFF2152FFFF1021C6FFB5B5EFFFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF007373E7FF527BF7FF5284FFFF4A7BFFFF2129CEFFBDBDEFFF2129CEFF396B
                  FFFF2152FFFF184AEFFF2121BDFFEFEFFFFFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF003139DEFF6B9CFFFF5A8CFFFF294AE7FFA5A5EFFFFFFFFF00CECEF7FF1829
                  CEFF3163FFFF2152FFFF1039DEFF6363CEFFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF006B6BEFFF3952E7FF5A84FFFF4242DEFFFFFFFF00FFFFFF00FFFFFF00B5B5
                  EFFF1829D6FF295AFFFF1031E7FF3131C6FFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00C6C6F7FF5A5AD6FFCECEF7FFFFFFFF00FFFFFF00FFFFFF00FFFF
                  FF009C9CE7FF4242CEFFB5B5E7FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
                  FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
                Kind = bkGlyph
              end>
            Properties.ReadOnly = True
            Properties.OnButtonClick = EditOnaylayanPropertiesButtonClick
            TabOrder = 15
            Width = 173
          end
          object cxLabel6: TcxLabel
            Left = 271
            Top = 29
            Caption = 'Onaylayan'
          end
          object cxLabel21: TcxLabel
            Left = 520
            Top = 87
            Caption = 'D'#246'n'#252#351#252'm'
            Transparent = True
          end
          object cxDBImageComboBox1: TcxDBImageComboBox
            Left = 589
            Top = 83
            RepositoryItem = Tablo.repStokAnaBirim
            DataBinding.DataField = 'DONUSUMTURU'
            DataBinding.DataSource = DtsTabSiparis
            Properties.Items = <>
            TabOrder = 18
            Width = 65
          end
          object editDovizKuru: TcxDBCurrencyEdit
            Left = 655
            Top = 2
            DataBinding.DataField = 'DOVIZKUR'
            DataBinding.DataSource = DtsTabSiparis
            Enabled = False
            ParentFont = False
            Properties.DecimalPlaces = 4
            Properties.DisplayFormat = ',0.0000;(,0.0000)'
            Properties.EditFormat = ',0.0000;(,0.0000)'
            Properties.ReadOnly = False
            Properties.UseDisplayFormatWhenEditing = True
            Style.Color = 11776947
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clRed
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = [fsBold]
            Style.IsFontAssigned = True
            TabOrder = 19
            Width = 51
          end
          object cxLabel7: TcxLabel
            Left = 270
            Top = 6
            Caption = 'Onaylayacak'
          end
          object cbOnaylayacak: TcxDBImageComboBox
            Left = 344
            Top = 4
            DataBinding.DataField = 'ONAYLAYACAK'
            DataBinding.DataSource = DtsTabSiparis
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            TabOrder = 21
            Width = 173
          end
          object BeditServis: TcxButtonEdit
            Left = 57
            Top = 53
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
            Properties.ReadOnly = True
            Properties.OnButtonClick = BeditServisPropertiesButtonClick
            TabOrder = 22
            Width = 208
          end
          object cxLabel8: TcxLabel
            Left = 0
            Top = 57
            Caption = 'Servis'
            ParentFont = False
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clBlack
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.IsFontAssigned = True
            Transparent = True
          end
          object ComboRaporDovizi: TcxDBComboBox
            Left = 589
            Top = 2
            RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
            DataBinding.DataField = 'RAPORDOVIZ'
            DataBinding.DataSource = DtsTabSiparis
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            TabOrder = 24
            Width = 65
          end
          object LabelRaporDovizi: TcxLabel
            Left = 521
            Top = 4
            Caption = 'Rapor D'#246'vizi'
          end
          object BeditMusIlgili: TcxButtonEdit
            Tag = 1
            Left = 57
            Top = 104
            ParentShowHint = False
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
            Properties.ReadOnly = True
            Properties.OnButtonClick = BeditMusIlgiliPropertiesButtonClick
            ShowHint = True
            TabOrder = 26
            TextHint = 'MUS_ILGILI'
            Width = 208
          end
        end
        object cxTabSheet2: TcxTabSheet
          Caption = 'Yorum / Medya'
          ImageIndex = 1
          object labelDetayFileName: TcxLabel
            Left = 0
            Top = 115
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
            AnchorX = 1272
          end
          object Panel5: TPanel
            Left = 0
            Top = 74
            Width = 1272
            Height = 41
            Align = alBottom
            TabOrder = 1
            object MemoDetayChat: TcxRichEdit
              Left = 1
              Top = 1
              Align = alClient
              Properties.ScrollBars = ssVertical
              TabOrder = 1
              Height = 39
              Width = 1124
            end
            object BtnMesajGonderDetay: TcxButton
              Left = 1125
              Top = 1
              Width = 85
              Height = 39
              Align = alRight
              OptionsImage.ImageIndex = 39
              OptionsImage.Images = Tablo.cxImageList1
              TabOrder = 0
              OnClick = BtnMesajGonderDetayClick
            end
            object cxButton2: TcxButton
              Left = 1210
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
          object GridYorumDetay: TcxGrid
            Left = 0
            Top = 0
            Width = 1272
            Height = 74
            Align = alClient
            TabOrder = 2
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridYorumDetayView: TcxGridDBCardView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCellDblClick = GridYorumDetayViewCellDblClick
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
              object cxGridDBCardViewRow1: TcxGridDBCardViewRow
                DataBinding.FieldName = 'EKLEMETARIHI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = True
                Position.Width = 120
              end
              object cxGridDBCardViewRow2: TcxGridDBCardViewRow
                DataBinding.FieldName = 'YAZAN'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = False
              end
              object cxGridDBCardViewRow3: TcxGridDBCardViewRow
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
              object cxGridDBCardViewRow4: TcxGridDBCardViewRow
                DataBinding.FieldName = 'DOKUMANAD'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = False
                Position.Width = 300
                IsCaptionAssigned = True
              end
              object cxGridDBCardViewRow5: TcxGridDBCardViewRow
                DataBinding.FieldName = 'YORUM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxRichEditProperties'
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = True
                Styles.Content = Tablo.cxStyle12
                Styles.CategoryRow = Tablo.cxStyle4
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = GridYorumDetayView
            end
          end
        end
      end
      object cxLabel22: TcxLabel
        Left = 6
        Top = 45
        Caption = 'ID'
        ParentFont = False
        Transparent = True
      end
      object cxDBLabel2: TcxDBLabel
        Left = 19
        Top = 45
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsTabSiparis
        Transparent = True
        Height = 21
        Width = 58
      end
    end
    object DetayEkr: TJvWizardInteriorPage
      Tag = 1
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Detay bilgiler'
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
      OnEnterPage = DetayEkrEnterPage
      OnPage = DetayEkrPage
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 1274
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
        TabOrder = 1
        Transparent = True
      end
      object GridKurIlet: TcxGrid
        Left = 0
        Top = 97
        Width = 1280
        Height = 519
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
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCellClick = GridDetayViewCellClick
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
            OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
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
      object lbDetaySablon: TcxLabel
        Left = 6
        Top = 38
        Caption = #350'ablon Se'#231'iniz.'
        Style.TextColor = clMaroon
        Properties.WordWrap = True
        Transparent = True
        OnClick = lbDetaySablonClick
        Width = 77
      end
      object ComboBolum: TcxDBComboBox
        Left = 83
        Top = 37
        DataBinding.DataField = 'DETAYBOLUMU'
        DataBinding.DataSource = DtsTabSiparis
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.OnEditValueChanged = ComboBolumPropertiesEditValueChanged
        Properties.OnInitPopup = ComboBolumPropertiesInitPopup
        TabOrder = 0
        Width = 153
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
          'RB.SIRA,RB.ETIKET,NULLIF(RB.BILGI,'#39#39'),ORJINAL=RB.BILGI,RA.GIRIS,'
          'RA.KAYNAK,RA.ZORUNLU  '
          'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON '
          'RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI'
          'where RB.YERI= @yeri and YER_ID= @yerid '
          'and isnull(RA.BOLUM,'#39#39')=@bolum '
          ''
          'union all'
          ''
          
            'select  SIRA, ETIKET, BILGI=cast(null as nvarchar(1000)), ORJINA' +
            'L='#39#39' '
          ',GIRIS,KAYNAK,ZORUNLU  '
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
      Caption = 'DokumanEkr'
      OnEnterPage = DokumanEkrEnterPage
      object Panel4: TPanel
        Left = 0
        Top = 575
        Width = 1280
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
          Width = 1132
        end
        object BtnMesajGonder: TcxButton
          Left = 1133
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
          Left = 1218
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
        Top = 555
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
        AnchorX = 1280
      end
      object GridYorum: TcxGrid
        Left = 0
        Top = 70
        Width = 1280
        Height = 485
        Align = alClient
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
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 8
      Width = 121
    end
  end
  object dsAra: TDataSource
    AutoEdit = False
    Left = 337
    Top = 25
  end
  object OpenDialog1: TOpenDialog
    Left = 906
    Top = 342
  end
  object PopupMenuFatura: TPopupMenu
    Left = 26
    Top = 228
    object utarDvzHesapla1: TMenuItem
      Caption = 'Tutar / D'#246'viz Hesapla'
      OnClick = TutarDvzHesapla1Click
    end
    object Miktarskontosu1: TMenuItem
      Caption = 'Miktar '#304'skontosu Gir'
      object KDVHaricTutargir1: TMenuItem
        Caption = 'KDV Hari'#231' Tutar'#305' Gir'
        OnClick = KDVHaricTutargir1Click
      end
      object KDVDahilTutargir1: TMenuItem
        Tag = 1
        Caption = 'KDV Dahil Tutar'#305' Gir'
        OnClick = KDVHaricTutargir1Click
      end
    end
    object Yzdeskontosu1: TMenuItem
      Caption = 'Y'#252'zde '#304'skontosu Gir'
      object skonto11: TMenuItem
        Caption = #304'skonto1'
        object N52: TMenuItem
          Caption = '% 0'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N53: TMenuItem
          Tag = 5
          Caption = '% 5'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N102: TMenuItem
          Tag = 10
          Caption = '% 10'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N152: TMenuItem
          Tag = 15
          Caption = '% 15'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N202: TMenuItem
          Tag = 20
          Caption = '% 20'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N252: TMenuItem
          Tag = 25
          Caption = '% 25'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N302: TMenuItem
          Tag = 30
          Caption = '% 30'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N402: TMenuItem
          Tag = 40
          Caption = '% 40'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N502: TMenuItem
          Tag = 50
          Caption = '% 50'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object N1001: TMenuItem
          Tag = 100
          Caption = '% 100'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
        object zel3: TMenuItem
          Tag = -1
          Caption = #214'zel'
          Hint = #304'skonto1'
          OnClick = N52Click
        end
      end
      object skonto21: TMenuItem
        Caption = #304'skonto2'
        object N01: TMenuItem
          Caption = '% 0'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N51: TMenuItem
          Tag = 5
          Caption = '% 5'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N101: TMenuItem
          Tag = 10
          Caption = '% 10'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N151: TMenuItem
          Tag = 15
          Caption = '% 15'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N201: TMenuItem
          Tag = 20
          Caption = '% 20'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N251: TMenuItem
          Tag = 25
          Caption = '% 25'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N301: TMenuItem
          Tag = 30
          Caption = '% 30'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N401: TMenuItem
          Tag = 40
          Caption = '% 40'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N501: TMenuItem
          Tag = 50
          Caption = '% 50'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object N1002: TMenuItem
          Tag = 100
          Caption = '% 100'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
        object zel1: TMenuItem
          Tag = -1
          Caption = #214'zel'
          Hint = #304'skonto2'
          OnClick = N52Click
        end
      end
    end
    object KDVOranGir1: TMenuItem
      Caption = 'KDV Oran'#305' Gir'
      object SeiliSatra1: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'ra'
      end
      object Tumune1: TMenuItem
        Caption = 'T'#252'm'#252'ne'
      end
    end
    object TeslimTarihiGirMenu: TMenuItem
      Caption = 'Teslim Tarihi Gir'
      object TeslimTarihiSeciliSatiraMenu: TMenuItem
        Caption = 'Se'#231'ili Sat'#305'rlara'
        OnClick = TeslimTarihiSeciliSatiraMenuClick
      end
      object TeslimTarihiTumuneMenu: TMenuItem
        Caption = 'T'#252'm'#252'ne'
        OnClick = TeslimTarihiTumuneMenuClick
      end
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object FaturaIptalIsaretle: TMenuItem
      Caption = 'Bu Sipari'#351'i '#304'ptal et'
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object SipariKoanAyarlar1: TMenuItem
      Caption = 'Sipari'#351' Ko'#231'an Ayarlar'#305
      OnClick = SipariKoanAyarlar1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object BirSatrAdetiKadarSatrlaraBolMenu: TMenuItem
      Caption = 'Bir Sat'#305'r'#305' Adeti Kadar Sat'#305'rlara B'#246'l'
      OnClick = BirSatrAdetiKadarSatrlaraBolMenuClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object retimPlanndaGsterme1: TMenuItem
      Caption = #220'retim Planlan'#305'nda'
      object GsterSeiliSatr1: TMenuItem
        Tag = 1
        Caption = 'G'#246'ster (Se'#231'ili Sat'#305'r)'
        OnClick = GsterSeiliSatr1Click
      end
      object GsterTm1: TMenuItem
        Tag = 2
        Caption = 'G'#246'ster (T'#252'm'#252')'
        OnClick = GsterSeiliSatr1Click
      end
      object GstermeSeiliSatr1: TMenuItem
        Tag = 3
        Caption = 'G'#246'sterme (Se'#231'ili Sat'#305'r)'
        OnClick = GsterSeiliSatr1Click
      end
      object GstermeTm1: TMenuItem
        Tag = 4
        Caption = 'G'#246'sterme (T'#252'm'#252')'
        OnClick = GsterSeiliSatr1Click
      end
    end
  end
  object DtsTabSiparisDetay: TDataSource
    DataSet = TabSiparisDetay
    OnStateChange = DtsSIPARISDETAYStateChange
    Left = 615
    Top = 220
  end
  object DtsTabSiparis: TDataSource
    DataSet = TabSiparis
    OnStateChange = DtsSIPARISStateChange
    Left = 512
    Top = 261
  end
  object PopupMenuYaz: TPopupMenu
    Left = 181
    Top = 353
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
  object TabRehber: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select ID,KOD,FIRMA'
      '   from REHBER'
      'where ID = :PID')
    Left = 427
    Top = 315
    ParamData = <
      item
        Name = 'PID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 100
      end>
  end
  object DtsRehber: TDataSource
    DataSet = TabRehber
    Left = 427
    Top = 304
  end
  object TabSiparisDetay: TFDQuery
    AutoCalcFields = False
    BeforeOpen = TabSiparisDetayBeforeOpen
    AfterOpen = TabSiparisDetayAfterOpen
    BeforePost = TabSiparisDetayBeforePost
    AfterPost = TabSiparisDetayAfterPost
    AfterDelete = TabSiparisDetayAfterDelete
    AfterScroll = TabSiparisDetayAfterScroll
    OnCalcFields = TabSiparisDetayCalcFields
    OnNewRecord = TabSiparisDetayNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select '
      
        'AD = CASE WHEN F.TUR =0 THEN  (select MG.AD from MASRAFGELIR MG ' +
        'where MG.ID=F.URUNID) ELSE (select S.STOKADI from STOKLAR S wher' +
        'e S.ID=F.URUNID) END,'
      
        'KOD= CASE WHEN F.TUR =0 THEN  (select MG.KOD from MASRAFGELIR MG' +
        ' where MG.ID=F.URUNID) ELSE (select S.KOD from STOKLAR S where S' +
        '.ID=F.URUNID) END,'
      
        'URUNNO= CASE WHEN F.TUR =0 THEN  '#39#39' ELSE (select S.URUNNO from S' +
        'TOKLAR S where S.ID=F.URUNID) END,'
      
        'RESIM=CASE WHEN F.TUR =0 THEN 0 ELSE (select case when S.RESIM i' +
        's null then 0 else 1 end from STOKLAR S where S.ID=F.URUNID) END' +
        ','
      
        'DOKUMAN=CASE WHEN exists(select GY.ID from GOREVYORUM GY inner j' +
        'oin DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID where GY.TUR=88' +
        ' and GOREVID=F.URUNID) then 1 else 0 end,'
      'F.* '
      ''
      'from SIPARISDETAY F'
      'Where SIPARISID = :Par ')
    Left = 32
    Top = 96
    ParamData = <
      item
        Name = 'Par'
        DataType = ftLargeint
        Precision = 19
        ParamType = ptInput
        Size = 8
        Value = 0
      end>
    object TabSiparisDetayAD: TWideStringField
      FieldName = 'AD'
      ReadOnly = True
      Size = 200
    end
    object TabSiparisDetayKOD: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
      Size = 25
    end
    object TabSiparisDetayURUNNO: TWideStringField
      FieldName = 'URUNNO'
      ReadOnly = True
    end
    object TabSiparisDetayRESIM: TIntegerField
      FieldName = 'RESIM'
      ReadOnly = True
    end
    object TabSiparisDetayDOKUMAN: TIntegerField
      FieldName = 'DOKUMAN'
      ReadOnly = True
    end
    object TabSiparisDetayBIRIMAD: TWideStringField
      FieldName = 'BIRIMAD'
      ReadOnly = True
      Size = 2000
    end
    object TabSiparisDetayBIRIM2MIKTAR: TFloatField
      FieldName = 'BIRIM2MIKTAR'
      ReadOnly = True
    end
    object TabSiparisDetayBIRIM2AD: TWideStringField
      FieldName = 'BIRIM2AD'
      ReadOnly = True
      Size = 2000
    end
    object TabSiparisDetayPROJEKODU: TWideStringField
      FieldName = 'PROJEKODU'
      ReadOnly = True
      Size = 100
    end
    object TabSiparisDetaySATICIADI: TWideStringField
      FieldName = 'SATICIADI'
      ReadOnly = True
      Size = 120
    end
    object TabSiparisDetayDONUSENMIKTAR: TFMTBCDField
      FieldName = 'DONUSENMIKTAR'
      ReadOnly = True
      Precision = 38
      Size = 6
    end
    object TabSiparisDetayURETIMPLANINDAGOSTER: TIntegerField
      FieldName = 'URETIMPLANINDAGOSTER'
      ReadOnly = True
    end
    object TabSiparisDetayEKIPMAN: TWideStringField
      FieldName = 'EKIPMAN'
      ReadOnly = True
      Size = 100
    end
    object TabSiparisDetaySERINO: TWideStringField
      FieldName = 'SERINO'
      ReadOnly = True
      Size = 50
    end
    object TabSiparisDetayID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabSiparisDetaySIPARISID: TIntegerField
      FieldName = 'SIPARISID'
    end
    object TabSiparisDetayREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabSiparisDetaySEC: TWideStringField
      FieldName = 'SEC'
      Size = 1
    end
    object TabSiparisDetayTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabSiparisDetayURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object TabSiparisDetayACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
    end
    object TabSiparisDetayADET: TFMTBCDField
      FieldName = 'ADET'
      Precision = 24
      Size = 6
    end
    object TabSiparisDetayEN: TFMTBCDField
      FieldName = 'EN'
      OnChange = TabSiparisDetayENChange
      Precision = 12
      Size = 6
    end
    object TabSiparisDetayBOY: TFMTBCDField
      FieldName = 'BOY'
      OnChange = TabSiparisDetayENChange
      Precision = 12
      Size = 6
    end
    object TabSiparisDetayYUZEY: TFMTBCDField
      FieldName = 'YUZEY'
      Precision = 24
      Size = 6
    end
    object TabSiparisDetaySAYI: TFMTBCDField
      FieldName = 'SAYI'
      OnChange = TabSiparisDetayENChange
      Precision = 12
      Size = 6
    end
    object TabSiparisDetayBIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object TabSiparisDetayMIKTAR: TFMTBCDField
      FieldName = 'MIKTAR'
      Precision = 24
      Size = 6
    end
    object TabSiparisDetayBIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object TabSiparisDetayTUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 24
      Size = 2
    end
    object TabSiparisDetayISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object TabSiparisDetayKDV: TSmallintField
      FieldName = 'KDV'
    end
    object TabSiparisDetayMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object TabSiparisDetayMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 25
    end
    object TabSiparisDetayKASA: TSmallintField
      FieldName = 'KASA'
    end
    object TabSiparisDetayONAY: TWideStringField
      FieldName = 'ONAY'
      Size = 1
    end
    object TabSiparisDetayKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object TabSiparisDetayIZLEMEKODU: TWideStringField
      FieldName = 'IZLEMEKODU'
      Size = 15
    end
    object TabSiparisDetayDOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 24
      Size = 2
    end
    object TabSiparisDetayDOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object TabSiparisDetayISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object TabSiparisDetayIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object TabSiparisDetayMF: TFMTBCDField
      FieldName = 'MF'
      Precision = 24
      Size = 6
    end
    object TabSiparisDetayIADEADET: TFloatField
      FieldName = 'IADEADET'
    end
    object TabSiparisDetayIADESIPARISDETAYID: TIntegerField
      FieldName = 'IADESIPARISDETAYID'
    end
    object TabSiparisDetayYERI: TIntegerField
      FieldName = 'YERI'
    end
    object TabSiparisDetayYERID: TIntegerField
      FieldName = 'YERID'
    end
    object TabSiparisDetayDOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object TabSiparisDetayDOVIZKURDEGERI: TCurrencyField
      FieldName = 'DOVIZKURDEGERI'
    end
    object TabSiparisDetayEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabSiparisDetayEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabSiparisDetayDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabSiparisDetayDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabSiparisDetayKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object TabSiparisDetayVADE: TWordField
      FieldName = 'VADE'
    end
    object TabSiparisDetayPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object TabSiparisDetayTESLIMTARIHI: TSQLTimeStampField
      FieldName = 'TESLIMTARIHI'
    end
    object TabSiparisDetaySUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object TabSiparisDetayURETIMPLANID: TIntegerField
      FieldName = 'URETIMPLANID'
    end
    object TabSiparisDetayURETIMPLANDETAYID: TIntegerField
      FieldName = 'URETIMPLANDETAYID'
    end
    object TabSiparisDetayMERKEZID: TIntegerField
      FieldName = 'MERKEZID'
    end
    object TabSiparisDetaySTOKDURUM: TFloatField
      FieldName = 'STOKDURUM'
    end
    object TabSiparisDetayEKIPMANID: TIntegerField
      FieldName = 'EKIPMANID'
    end
    object TabSiparisDetayGIRISKAYNAK: TWordField
      FieldName = 'GIRISKAYNAK'
    end
    object TabSiparisDetayOTVYUZDE: TBooleanField
      FieldName = 'OTVYUZDE'
    end
    object TabSiparisDetayOTVMIKTAR: TBCDField
      FieldName = 'OTVMIKTAR'
      Precision = 6
      Size = 2
    end
    object TabSiparisDetaySATICIKODU: TIntegerField
      FieldName = 'SATICIKODU'
    end
    object TabSiparisDetayISKONTOLUBRMFIYAT: TFloatField
      FieldName = 'ISKONTOLUBRMFIYAT'
      ReadOnly = True
    end
    object TabSiparisDetayKDVDAHILBRMFIYAT: TFMTBCDField
      FieldName = 'KDVDAHILBRMFIYAT'
      ReadOnly = True
      Precision = 38
      Size = 9
    end
    object TabSiparisDetayKDVDAHILFIYAT: TFloatField
      FieldName = 'KDVDAHILFIYAT'
      ReadOnly = True
    end
    object TabSiparisDetayOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
    end
    object TabSiparisDetayOZELKOD2: TWideStringField
      FieldName = 'OZELKOD2'
    end
    object TabSiparisDetayPOZNO: TIntegerField
      FieldName = 'POZNO'
    end
  end
  object TabSiparis: TFDQuery
    AutoCalcFields = False
    AfterOpen = TabSiparisAfterOpen
    BeforeEdit = TabSiparisBeforeEdit
    BeforePost = TabSiparisBeforePost
    AfterPost = TabSiparisAfterPost
    AfterScroll = TabSiparisAfterScroll
    OnNewRecord = TabSiparisNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  *'
      'FROM SIPARIS S '
      'WHERE ID = :Par')
    Left = 515
    Top = 26
    ParamData = <
      item
        Name = 'Par'
        DataType = ftLargeint
        Precision = 19
        ParamType = ptInput
        Size = 8
        Value = 0
      end>
  end
  object frxTabSiparisDetay: TfrxDBDataset
    UserName = 'SIPARISDETAY'
    CloseDataSource = False
    DataSet = TabSiparisDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 605
    Top = 371
  end
  object frxTabSiparis: TfrxDBDataset
    UserName = 'SIPARIS'
    CloseDataSource = False
    DataSet = TabSiparis
    BCDToCurrency = False
    DataSetOptions = []
    Left = 526
    Top = 369
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    UpdateOptions.UpdateTableName = 'REHBERBILGI'
    SQL.Strings = (
      ''
      'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 366
    Top = 320
    ParamData = <
      item
        Name = 'Yeri'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'Yeri_Id'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 365
    Top = 275
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 43
    Top = 201
  end
  object dtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 725
    Top = 222
  end
  object TOPLAMLAR: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'EXEC SP_PRG_Siparis_DipToplami @SIPARISID=:SIPARISID')
    Left = 696
    Top = 328
    ParamData = <
      item
        Name = 'SIPARISID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 111
      end>
  end
  object frxTOPLAMLAR: TfrxDBDataset
    UserName = 'TOPLAMLAR'
    CloseDataSource = False
    FieldAliases.Strings = (
      'TUR=TUR'
      'ACIKLAMA=ACIKLAMA'
      'DEGER=DEGER'
      'KUR=KUR'
      'DOVIZTUTARI=DOVIZTUTARI'
      'DOVIZ_KURU=DOVIZ_KURU')
    DataSet = TOPLAMLAR
    BCDToCurrency = False
    DataSetOptions = []
    Left = 697
    Top = 379
  end
  object frxDETAY: TfrxDBDataset
    UserName = 'DETAY'
    CloseDataSource = False
    DataSet = TabDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 369
    Top = 376
  end
  object DtsHesapOzeti: TDataSource
    DataSet = TabHesapOzeti
    Left = 263
    Top = 324
  end
  object TabHesapOzeti: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT * from [dbo].[fn_CARIHESAPOZETI] (:PRehID,:PBirim,:FatTut' +
        'ari) ')
    Left = 264
    Top = 273
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end
      item
        Name = 'PBirim'
        Size = -1
        Value = Null
      end
      item
        Name = 'FatTutari'
        Size = -1
        Value = Null
      end>
  end
  object frxHesapOzeti: TfrxDBDataset
    UserName = 'Hesap '#214'zeti'
    CloseDataSource = False
    DataSet = TabHesapOzeti
    BCDToCurrency = False
    DataSetOptions = []
    Left = 257
    Top = 376
  end
  object DtsStokDetay: TDataSource
    DataSet = tabStokDetay
    OnStateChange = DtsSIPARISStateChange
    Left = 792
    Top = 277
  end
  object tabStokDetay: TFDQuery
    AutoCalcFields = False
    AfterOpen = TabSiparisAfterOpen
    BeforeEdit = TabSiparisBeforeEdit
    BeforePost = TabSiparisBeforePost
    AfterPost = TabSiparisAfterPost
    AfterScroll = TabSiparisAfterScroll
    OnNewRecord = TabSiparisNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select SD.* , ST.*,'
      
        'BIRIMAD = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-2702 and DIL=' +
        '-1 and DEGER = SD.BIRIM),'
      
        'BIRIM2AD=  (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM =-2702 ' +
        'and DEGER = ST.BIRIM2 ),'
      
        'KATEGORIADI=(select K.AD from KATEGORI K where K.ID=ST.KATEGORI)' +
        ','
      'MARKAADI=StokMarka.ANAHTAR,'
      'MODELADI=StokModel.ANAHTAR,'
      
        'GRUBUADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2704 and' +
        ' DEGER = ST.GRUBU and DIL=-1),'
      
        'OZELLIKADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2705 a' +
        'nd DEGER = ST.GRUBU and DIL=-1),'
      
        'ICERIKADI=(select top 1 ANAHTAR from GENINI where BOLUM=-2718 an' +
        'd DEGER = ST.GRUBU and DIL=-1)'
      ''
      ''
      'FROM '
      #9'SIPARISDETAY SD   left outer join '
      #9'STOKLAR ST on SD.TUR=1 and SD.URUNID=ST.ID left outer join'
      
        #9'GENINI StokMarka ON StokMarka.DEGER = ST.MARKA AND StokMarka.BO' +
        'LUM=-2701 and StokMarka.DIL=-1 left outer join'
      
        #9'GENINI StokModel ON StokModel.DEGER = ST.MODEL and StokModel.DI' +
        'L=-1 AND StokModel.BOLUM=convert(int,'#39'-2701'#39'+convert(varchar(10)' +
        ',ST.MARKA))'
      ''
      'WHERE SD.SIPARISID = :Par')
    Left = 787
    Top = 330
    ParamData = <
      item
        Name = 'Par'
        DataType = ftLargeint
        Precision = 19
        ParamType = ptInput
        Size = 8
        Value = 0
      end>
  end
  object frxStokDetay: TfrxDBDataset
    UserName = 'STOKDETAY'
    CloseDataSource = False
    DataSet = tabStokDetay
    BCDToCurrency = False
    DataSetOptions = []
    Left = 790
    Top = 377
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
    Left = 577
    Top = 353
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 587
    Top = 428
  end
  object PopupYorumlar: TPopupMenu
    OnPopup = PopupYorumlarPopup
    Left = 16
    Top = 8
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
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
  object cxGridPopupYorumlar: TcxGridPopupMenu
    Grid = GridYorum
    PopupMenus = <
      item
        GridView = GridYorumDBCardView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 776
    Top = 440
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
    Left = 440
    Top = 364
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
  object ADOQuery1: TFDQuery
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
    Left = 971
    Top = 481
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 988
    Top = 540
  end
  object OfficePopupMenu1: TOfficePopupMenu
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
    Left = 671
    Top = 428
    object MenuItem2: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      ImageName = 'PngImage0'
      OnClick = MenuKlasordenEkleClick
    end
    object MenuItem3: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      ImageName = 'PngImage16'
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object PopupYorumDetayMenu: TPopupMenu
    OnPopup = PopupYorumDetayMenuPopup
    Left = 808
    Top = 544
    object MenuItem4: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      OnClick = MenuItem4Click
    end
    object MenuItem5: TMenuItem
      Caption = 'Yorum Sil'
      OnClick = MenuItem5Click
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object MenuDokGoster: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      OnClick = MenuDokGosterClick
    end
    object MenuDokFormuAc: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      OnClick = MenuDokFormuAcClick
    end
    object MenuDokSil: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      OnClick = MenuDokSilClick
    end
  end
  object cxGridPopupYorumlarDetay: TcxGridPopupMenu
    Grid = GridYorumDetay
    PopupMenus = <
      item
        GridView = GridYorumDetayView
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumDetayMenu
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 936
    Top = 432
  end
  object SIPARIS: TFDQuery
    AutoCalcFields = False
    OnNewRecord = TabSiparisNewRecord
    Connection = Tablo.FDCnn
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'SELECT *,'
      'YAZIYLATOPLAM=( dbo.fn_MoneyToText(SIPARIS_TUTARI,KUR,0)),'
      
        'YAZIYLATOPLAM_DOVIZ=( dbo.fn_MoneyToText(DOVIZ_TUTARI, DOVIZ_CIN' +
        'SI,0)),'
      
        'ILGILIADI=(select FIRMA from REHBER RP where RP.ID=S.MUS_ILGILI)' +
        ','
      
        'PERSONELADI=(select R.FIRMA from REHBER R where R.ID=S.SATICIKOD' +
        'U) ,'
      
        'SEVKADRES=(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 2 Order by 1 )' +
        ','
      
        'SEVKILCE =(SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHB' +
        'ERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_I' +
        'D=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 6 Order by 1),'
      
        'SEVKIL = (SELECT Top 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBE' +
        'RBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID' +
        '=S.REHBERILETID AND RB.YERI=1 and RA.VARSAYILAN= 8 Order by 1 ),'
      'ONAYLAYANADI=(select FIRMA from REHBER where ID=ONAYLAYAN),'
      
        'KAYNAKBELGENO=dbo.fn_KaynakBelgeNolariStrOlarakGetir(S.TUR,S.ID)' +
        ','
      
        'TESLIMAD=(select ANAHTAR from GENINI where BOLUM=-2903 and DEGER' +
        '=S.TESLIM_SEKLI),'
      
        'ODEMEAD=(select ANAHTAR from GENINI where BOLUM=-2904 and DEGER=' +
        'S.ODEME)'
      ''
      'FROM SIPARIS S WHERE ID = :Par')
    Left = 515
    Top = 82
    ParamData = <
      item
        Name = 'Par'
        DataType = ftLargeint
        Precision = 19
        ParamType = ptInput
        Size = 8
        Value = 0
      end>
  end
  object SIPARISDETAY: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    SQL.Strings = (
      'Select '
      
        'AD = CASE WHEN F.TUR =0 THEN  (select MG.AD from MASRAFGELIR MG ' +
        'where MG.ID=F.URUNID) '
      
        #9' ELSE (select S.STOKADI from STOKLAR S where S.ID=F.URUNID) END' +
        ','
      
        'KOD= CASE WHEN F.TUR =0 THEN  (select MG.KOD from MASRAFGELIR MG' +
        ' where MG.ID=F.URUNID) '
      #9' ELSE (select S.KOD from STOKLAR S where S.ID=F.URUNID) END,'
      'URUNNO= CASE WHEN F.TUR =0 THEN  '#39#39' '
      #9' ELSE (select S.URUNNO from STOKLAR S where S.ID=F.URUNID) END,'
      
        'RESIM=(select case when S.RESIM is null then 0 else 1 end from S' +
        'TOKLAR S where S.ID = F.URUNID ),'
      
        'DOKUMAN=(select case when exists(select GY.ID, STOKID=GY.GOREVID' +
        ', DOKUMANID=D.ID, DOKUMANAD=D.AD'
      
        #9'from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MO' +
        'DULID=GY.ID '
      
        #9'where GY.TUR=88 and GOREVID=S.ID) then 1 else 0 end   from STOK' +
        'LAR S where S.ID = F.URUNID), '
      
        'BIRIMAD = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-2702 and DIL=' +
        '-1 and DEGER = F.BIRIM),'
      
        'BIRIM2MIKTAR=CASE WHEN F.TUR=0 THEN F.MIKTAR ELSE F.MIKTAR/(sele' +
        'ct S.BIRIM2MIKTAR from STOKLAR S where S.ID=F.URUNID) END,'
      
        'BIRIM2AD= CASE WHEN F.TUR =0 THEN  (SELECT TOP 1 ANAHTAR FROM GE' +
        'NINI WHERE BOLUM =-2702 and DEGER = convert(varchar(10),F.BIRIM)' +
        ' )  ELSE (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM =-2702 an' +
        'd DEGER = convert(varchar(10),(select S.BIRIM2 from STOKLAR S wh' +
        'ere S.ID=F.URUNID)) ) END,'
      
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=F.PROJE' +
        'ID),'
      
        'SATICIADI=(select R.FIRMA from REHBER R where R.ID=F.SATICIKODU)' +
        ','
      
        'DONUSENMIKTAR=isnull((select top 1 F.MIKTAR*(SC.ADET2/SC.ADET1) ' +
        'from STOKCEVRIM SC where SC.STOKID=F.URUNID and F.TUR=1 and F.BI' +
        'RIM=SC.BIRIM1 and SC.BIRIM2=(select S.DONUSUMTURU from SIPARIS S' +
        ' where S.ID=F.SIPARISID) ),0.0),'
      
        'URETIMPLANINDAGOSTER=case when isnull(URETIMPLANDETAYID,0)<0 the' +
        'n 0 when isnull(URETIMPLANDETAYID,0)=0 then 1 else null end,'
      
        'EKIPMAN=(select E1.AD from EKIPMANLAR E1 inner join EKIPMANREHBE' +
        'R ER1 on E1.ID=ER1.EKIPMANID where ER1.ID=F.EKIPMANID),'
      
        'SERINO=(select ER2.SERINO from EKIPMANREHBER ER2  where ER2.ID=F' +
        '.EKIPMANID),'
      'F.* '
      ''
      'from SIPARISDETAY F'
      'Where SIPARISID = :Par '
      'order by 2')
    Left = 610
    Top = 80
    ParamData = <
      item
        Name = 'Par'
        DataType = ftLargeint
        Precision = 19
        ParamType = ptInput
        Size = 8
        Value = 0
      end>
    object WideStringField1: TWideStringField
      FieldName = 'AD'
      ReadOnly = True
      Size = 200
    end
    object WideStringField2: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
      Size = 25
    end
    object WideStringField3: TWideStringField
      FieldName = 'URUNNO'
      ReadOnly = True
    end
    object IntegerField1: TIntegerField
      FieldName = 'RESIM'
      ReadOnly = True
    end
    object IntegerField2: TIntegerField
      FieldName = 'DOKUMAN'
      ReadOnly = True
    end
    object WideStringField4: TWideStringField
      FieldName = 'BIRIMAD'
      ReadOnly = True
      Size = 2000
    end
    object FloatField1: TFloatField
      FieldName = 'BIRIM2MIKTAR'
      ReadOnly = True
    end
    object WideStringField5: TWideStringField
      FieldName = 'BIRIM2AD'
      ReadOnly = True
      Size = 2000
    end
    object WideStringField6: TWideStringField
      FieldName = 'PROJEKODU'
      ReadOnly = True
      Size = 100
    end
    object WideStringField7: TWideStringField
      FieldName = 'SATICIADI'
      ReadOnly = True
      Size = 120
    end
    object FMTBCDField1: TFMTBCDField
      FieldName = 'DONUSENMIKTAR'
      ReadOnly = True
      Precision = 38
      Size = 6
    end
    object IntegerField3: TIntegerField
      FieldName = 'URETIMPLANINDAGOSTER'
      ReadOnly = True
    end
    object WideStringField8: TWideStringField
      FieldName = 'EKIPMAN'
      ReadOnly = True
      Size = 100
    end
    object WideStringField9: TWideStringField
      FieldName = 'SERINO'
      ReadOnly = True
      Size = 50
    end
    object AutoIncField1: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object IntegerField4: TIntegerField
      FieldName = 'SIPARISID'
    end
    object IntegerField5: TIntegerField
      FieldName = 'REHBERID'
    end
    object WideStringField10: TWideStringField
      FieldName = 'SEC'
      Size = 1
    end
    object SmallintField1: TSmallintField
      FieldName = 'TUR'
    end
    object IntegerField6: TIntegerField
      FieldName = 'URUNID'
    end
    object WideMemoField1: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
    end
    object FMTBCDField2: TFMTBCDField
      FieldName = 'ADET'
      Precision = 24
      Size = 6
    end
    object SmallintField2: TSmallintField
      FieldName = 'BIRIM'
    end
    object FMTBCDField3: TFMTBCDField
      FieldName = 'MIKTAR'
      Precision = 24
      Size = 6
    end
    object FMTBCDField4: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object FMTBCDField5: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 24
      Size = 2
    end
    object FloatField2: TFloatField
      FieldName = 'ISKONTO'
    end
    object SmallintField3: TSmallintField
      FieldName = 'KDV'
    end
    object SmallintField4: TSmallintField
      FieldName = 'MASRAFID'
    end
    object WideStringField11: TWideStringField
      FieldName = 'MUHKODU'
      Size = 25
    end
    object SmallintField5: TSmallintField
      FieldName = 'KASA'
    end
    object WideStringField12: TWideStringField
      FieldName = 'ONAY'
      Size = 1
    end
    object WideStringField13: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object WideStringField14: TWideStringField
      FieldName = 'IZLEMEKODU'
      Size = 15
    end
    object FMTBCDField6: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 24
      Size = 2
    end
    object WideStringField15: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object FloatField3: TFloatField
      FieldName = 'ISKONTO2'
    end
    object SmallintField6: TSmallintField
      FieldName = 'IZLEME'
    end
    object FMTBCDField7: TFMTBCDField
      FieldName = 'MF'
      Precision = 24
      Size = 6
    end
    object FloatField4: TFloatField
      FieldName = 'IADEADET'
    end
    object IntegerField7: TIntegerField
      FieldName = 'IADESIPARISDETAYID'
    end
    object IntegerField8: TIntegerField
      FieldName = 'YERI'
    end
    object IntegerField9: TIntegerField
      FieldName = 'YERID'
    end
    object FMTBCDField8: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 24
      Size = 6
    end
    object BCDField1: TCurrencyField
      FieldName = 'DOVIZKURDEGERI'
    end
    object IntegerField10: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object DateTimeField1: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object IntegerField11: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object DateTimeField2: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object IntegerField12: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object WordField1: TWordField
      FieldName = 'VADE'
    end
    object IntegerField13: TIntegerField
      FieldName = 'PROJEID'
    end
    object DateTimeField3: TSQLTimeStampField
      FieldName = 'TESLIMTARIHI'
    end
    object SmallintField7: TSmallintField
      FieldName = 'SUBEID'
    end
    object IntegerField14: TIntegerField
      FieldName = 'URETIMPLANID'
    end
    object IntegerField15: TIntegerField
      FieldName = 'URETIMPLANDETAYID'
    end
    object IntegerField16: TIntegerField
      FieldName = 'MERKEZID'
    end
    object FloatField5: TFloatField
      FieldName = 'STOKDURUM'
    end
    object IntegerField17: TIntegerField
      FieldName = 'EKIPMANID'
    end
    object WordField2: TWordField
      FieldName = 'GIRISKAYNAK'
    end
    object BooleanField1: TBooleanField
      FieldName = 'OTVYUZDE'
    end
    object BCDField2: TBCDField
      FieldName = 'OTVMIKTAR'
      Precision = 6
      Size = 2
    end
    object IntegerField18: TIntegerField
      FieldName = 'SATICIKODU'
    end
    object FloatField6: TFloatField
      FieldName = 'ISKONTOLUBRMFIYAT'
      ReadOnly = True
    end
    object FMTBCDField9: TFMTBCDField
      FieldName = 'KDVDAHILBRMFIYAT'
      ReadOnly = True
      Precision = 38
      Size = 9
    end
    object FloatField7: TFloatField
      FieldName = 'KDVDAHILFIYAT'
      ReadOnly = True
    end
    object WideStringField16: TWideStringField
      FieldName = 'OZELKOD'
    end
    object WideStringField17: TWideStringField
      FieldName = 'OZELKOD2'
    end
    object IntegerField19: TIntegerField
      FieldName = 'POZNO'
    end
    object SIPARISDETAYEN: TFMTBCDField
      FieldName = 'EN'
      Precision = 12
      Size = 6
    end
    object SIPARISDETAYBOY: TFMTBCDField
      FieldName = 'BOY'
      Precision = 12
      Size = 6
    end
    object SIPARISDETAYYUZEY: TFMTBCDField
      FieldName = 'YUZEY'
      Precision = 24
      Size = 6
    end
    object SIPARISDETAYSAYI: TFMTBCDField
      FieldName = 'SAYI'
      Precision = 12
      Size = 6
    end
  end
end
