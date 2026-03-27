object KYEgitimWizardDlg: TKYEgitimWizardDlg
  Left = 0
  Top = 0
  ActiveControl = editKALITENO
  BorderIcons = [biSystemMenu]
  Caption = 'E'#287'itim Olu'#351'turma Sihirbaz'#305
  ClientHeight = 498
  ClientWidth = 916
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
  object WizardKontrol: TJvWizard
    Left = 85
    Top = 0
    Width = 831
    Height = 498
    ActivePage = PageDOF
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
    ButtonFinish.Caption = '&Kaydet'
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
      831
      498)
    object PageDOF: TJvWizardInteriorPage
      Header.Title.Color = clNone
      Header.Title.Text = 'E'#287'itim Bilgileri'
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
      VisibleButtons = [bkFinish, bkCancel]
      OnExitPage = PageDOFExitPage
      object ComboFaaliyet: TcxDBImageComboBox
        Left = 120
        Top = 137
        DataBinding.DataField = 'EGITIMTURU'
        DataBinding.DataSource = DtsEgitim
        Properties.Items = <
          item
            Description = #350'irket '#304#231'i'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = #350'irket D'#305#351#305
            Value = 1
          end>
        Properties.OnCloseUp = ComboFaaliyetPropertiesCloseUp
        TabOrder = 3
        Width = 177
      end
      object cxLabel1: TcxLabel
        Left = 6
        Top = 92
        Caption = 'E'#287'itim Konusu'
        Style.TextColor = clRed
        Transparent = True
      end
      object cxLabel2: TcxLabel
        Left = 409
        Top = 138
        Caption = 'Durum'
        Style.TextColor = clRed
        Transparent = True
      end
      object cxLabel4: TcxLabel
        Left = 409
        Top = 92
        Caption = 'E'#287'itim Ba'#351'lang'#305#231' Tarih'
        Style.TextColor = clRed
        Transparent = True
      end
      object LblBirim: TcxLabel
        Left = 6
        Top = 161
        Caption = 'Birim'
        Transparent = True
        Visible = False
      end
      object lblMusteri: TcxLabel
        Left = 6
        Top = 161
        Caption = 'M'#252#351'teri'
        Style.TextColor = clRed
        Transparent = True
        Visible = False
      end
      object cxLabel8: TcxLabel
        Left = 6
        Top = 115
        Caption = 'E'#287'itim A'#231'an'
        Style.TextColor = clRed
        Transparent = True
      end
      object cxLabel11: TcxLabel
        Left = 409
        Top = 161
        Caption = 'E'#287'itim Sorumlusu'
        Style.TextColor = clRed
        Transparent = True
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 517
        Top = 137
        RepositoryItem = Tablo.RepKaliteToplantiDurum
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsEgitim
        Properties.ImmediatePost = True
        Properties.Items = <>
        StyleDisabled.Color = clWindow
        StyleDisabled.TextColor = clWindowText
        TabOrder = 7
        Width = 147
      end
      object ComboMusteri: TcxButtonEdit
        Left = 120
        Top = 160
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.MaxLength = 0
        Properties.ReadOnly = True
        Properties.OnButtonClick = ComboMusteriPropertiesButtonClick
        Style.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        TabOrder = 16
        Visible = False
        Width = 177
      end
      object ComboBolum: TcxDBImageComboBox
        Left = 120
        Top = 160
        RepositoryItem = Tablo.RepCariBolum
        DataBinding.DataField = 'BIRIM'
        DataBinding.DataSource = DtsEgitim
        Properties.Items = <>
        TabOrder = 4
        Visible = False
        Width = 177
      end
      object EditEgitimAcan: TcxButtonEdit
        Left = 120
        Top = 114
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.MaxLength = 0
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditDOFAcanPropertiesButtonClick
        Style.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        TabOrder = 2
        Width = 177
      end
      object EditEgitimSorumlu: TcxButtonEdit
        Left = 517
        Top = 160
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.MaxLength = 0
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditDOFSorumluPropertiesButtonClick
        Style.LookAndFeel.NativeStyle = False
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
        TabOrder = 8
        Width = 147
      end
      object DateTarihBaslangic: TcxDBDateEdit
        Left = 517
        Top = 91
        DataBinding.DataField = 'EGITIMBASLAMATARIHI'
        DataBinding.DataSource = DtsEgitim
        Properties.Kind = ckDateTime
        TabOrder = 5
        Width = 147
      end
      object cxLabel3: TcxLabel
        Left = 6
        Top = 138
        Caption = 'E'#287'itim T'#252'r'#252
        Style.TextColor = clRed
        Transparent = True
      end
      object Panel6: TPanel
        Left = 0
        Top = 181
        Width = 831
        Height = 275
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 18
        object Panel7: TPanel
          Left = 0
          Top = 0
          Width = 831
          Height = 24
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object cxLabel10: TcxLabel
            Left = 3
            Top = 4
            Caption = 'E'#287'itim A'#231#305'klama'
            Transparent = True
          end
        end
        object MemDofNeden: TcxDBMemo
          Left = 0
          Top = 24
          Align = alLeft
          DataBinding.DataField = 'EGITIMACIKLAMA'
          DataBinding.DataSource = DtsEgitim
          Properties.ScrollBars = ssVertical
          TabOrder = 0
          Height = 251
          Width = 385
        end
        object Panel2: TPanel
          Left = 385
          Top = 24
          Width = 321
          Height = 251
          Align = alLeft
          Caption = 'Panel2'
          TabOrder = 2
          object cxGrid2: TcxGrid
            Left = 1
            Top = 28
            Width = 319
            Height = 222
            Align = alClient
            TabOrder = 0
            object cxGridDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsToplantiKullanici
              DataController.KeyFieldNames = 'ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              object cxGridDBColumn1: TcxGridDBColumn
                Caption = 'Se'#231
                DataBinding.FieldName = 'SEC'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
                Visible = False
                Width = 23
              end
              object cxGridDBColumn2: TcxGridDBColumn
                Caption = 'Kat'#305'l'#305'mc'#305
                DataBinding.FieldName = 'REHID'
                RepositoryItem = Tablo.repGenelPersonelListesi
                Options.Editing = False
                Width = 158
              end
              object cxGridDBTableView1Column1: TcxGridDBColumn
                Caption = 'Kat'#305'ld'#305
                DataBinding.FieldName = 'KATILDI'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Width = 64
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = cxGridDBTableView1
            end
          end
          object ToolBar1: TToolBar
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 313
            Height = 24
            Margins.Bottom = 0
            AutoSize = True
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
              Caption = 'Yeni'
              ImageIndex = 0
              OnClick = SatirEkleClick
            end
            object KatilimKaydet: TToolButton
              Left = 62
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              Visible = False
              OnClick = KatilimKaydetClick
            end
            object KatilimciSil: TToolButton
              Left = 124
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              OnClick = KatilimciSilClick
            end
            object KatilimIptal: TToolButton
              Left = 186
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              Visible = False
              OnClick = KatilimIptalClick
            end
          end
        end
      end
      object EditEgitimKonusu: TcxDBTextEdit
        Left = 120
        Top = 91
        DataBinding.DataField = 'EGITIMKONUSU'
        DataBinding.DataSource = DtsEgitim
        TabOrder = 1
        Width = 177
      end
      object cxLabel5: TcxLabel
        Left = 409
        Top = 117
        Caption = 'E'#287'itim Biti'#351' Tarih'
        Style.TextColor = clRed
        Transparent = True
      end
      object DateTarihBitis: TcxDBDateEdit
        Left = 517
        Top = 114
        DataBinding.DataField = 'EGITIMBITISTARIHI'
        DataBinding.DataSource = DtsEgitim
        Properties.Kind = ckDateTime
        TabOrder = 6
        Width = 147
      end
      object cxLabel6: TcxLabel
        Left = 6
        Top = 69
        Caption = 'E'#287'itim No'
        Style.TextColor = clRed
        Transparent = True
      end
      object editKALITENO: TcxDBTextEdit
        Left = 121
        Top = 69
        DataBinding.DataField = 'EGITIMNO'
        DataBinding.DataSource = DtsEgitim
        TabOrder = 0
        Width = 88
      end
    end
    object PageBelge: TJvWizardInteriorPage
      Header.Title.Color = clNone
      Header.Title.Text = 'D'#246'k'#252'man Bilgileri'
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
      VisibleButtons = [bkBack, bkFinish, bkCancel]
      Caption = 'PageBelge'
      object ToolBar2: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 825
        Height = 22
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 20
        ButtonWidth = 61
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
        object BelgeEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Belge Ekle'
          ImageIndex = 4
          Style = tbsTextButton
          OnClick = BelgeEkleTusClick
        end
        object BelgeSilTus: TToolButton
          Left = 61
          Top = 0
          Caption = 'Belge Sil'
          ImageIndex = 5
          Style = tbsTextButton
          OnClick = BelgeSilTusClick
        end
        object BelgeGorTus: TToolButton
          Left = 122
          Top = 0
          Caption = 'Belge G'#246'r'
          ImageIndex = 6
          Style = tbsTextButton
          OnClick = BelgeGorTusClick
        end
        object ToolButton2: TToolButton
          Left = 183
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 7
          Style = tbsSeparator
        end
        object KaydetTus: TToolButton
          Left = 191
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Visible = False
          OnClick = KaydetTusClick
        end
        object IptalTus: TToolButton
          Left = 252
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Visible = False
          OnClick = IptalTusClick
        end
      end
      object GridBelge: TcxGrid
        Left = 0
        Top = 95
        Width = 831
        Height = 361
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = False
        object GridBelgeDBTableViewImaj: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object GridBelgeDBTableViewImajBELGEADI: TcxGridDBColumn
            Caption = 'Belge Ad'#305
            DataBinding.FieldName = 'BELGEADI'
            Width = 95
          end
          object GridBelgeDBTableViewImajTUR: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            Width = 79
          end
          object GridBelgeDBTableViewImajACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            Width = 363
          end
          object GridBelgeDBTableViewImajBELGE: TcxGridDBColumn
            Caption = 'Belge'
            DataBinding.FieldName = 'BELGE'
            Width = 38
          end
        end
        object GridBelgeLevel1: TcxGridLevel
          GridView = GridBelgeDBTableViewImaj
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 85
    Height = 498
    Align = alLeft
    TabOrder = 0
    Visible = False
    object btnDOF: TcxButton
      Left = 9
      Top = 80
      Width = 65
      Height = 29
      Caption = 'E'#287'itim'
      TabOrder = 0
      OnClick = btnDOFClick
    end
    object BtnDokuman: TcxButton
      Tag = 3
      Left = 9
      Top = 117
      Width = 65
      Height = 29
      Caption = 'Dok'#252'man'
      TabOrder = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      ParentFont = False
      OnClick = BtnDokumanClick
    end
  end
  object TabEgitim: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabEgitimAfterOpen
    BeforePost = TabEgitimBeforePost
    AfterPost = TabEgitimAfterPost
    OnNewRecord = TabEgitimNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select * from KALITEEGITIM'
      'Where ID=:ID')
    Left = 437
    Top = 14
  end
  object DtsEgitim: TDataSource
    DataSet = TabEgitim
    Left = 479
    Top = 22
  end
  object TabBelge: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabEgitimBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT  *  FROM  [IMAJ]'
      'WHERE'
      'YERI = :PYeri and'
      'YER_ID = :PYerID')
    Left = 687
    Top = 10
  end
  object DtsBelge: TDataSource
    DataSet = TabBelge
    OnDataChange = DtsBelgeDataChange
    Left = 736
    Top = 9
  end
  object OpenDialog1: TOpenDialog
    Left = 828
    Top = 20
  end
  object TabEgitimKullanici: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select  KATILIM=(SELECT FIRMA FROM REHBER WHERE ID=KALITEKULLANI' +
        'CI.REHID ),*'
      'from '
      #9'KALITEKULLANICI'
      'where '
      #9'YER= 2 AND'
      '                YERID=:PToplantiId AND'
      #9'PERID IS NULL'
      '                ')
    Left = 526
    Top = 279
  end
  object DtsToplantiKullanici: TDataSource
    DataSet = TabEgitimKullanici
    OnStateChange = DtsToplantiKullaniciStateChange
    Left = 638
    Top = 279
  end
end
