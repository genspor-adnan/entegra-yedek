object KategoriDlg: TKategoriDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Kategori Listesi'
  ClientHeight = 377
  ClientWidth = 817
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object ToolBarUst: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 811
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 70
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
    ExplicitHeight = 29
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 70
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object KaydetTus: TToolButton
      Left = 140
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      Visible = False
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 210
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      Visible = False
      OnClick = IptalTusClick
    end
    object ToolButton1: TToolButton
      Left = 280
      Top = 0
      Width = 213
      Caption = 'ToolButton1'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 493
      Top = 0
      Caption = 'Se'#231
      ImageIndex = 11
      OnClick = ToolButton2Click
    end
    object KapatTus: TToolButton
      Left = 563
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      OnClick = KapatTusClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 35
    Width = 461
    Height = 342
    Align = alClient
    BevelInner = bvLowered
    BorderWidth = 4
    Caption = 'Panel2'
    TabOrder = 1
    object Panel1: TPanel
      Left = 6
      Top = 6
      Width = 449
      Height = 27
      Align = alTop
      TabOrder = 0
      object Label1: TcxLabel
        Left = 5
        Top = 3
        Caption = 'Ara'
        Transparent = True
      end
      object ToolBar1: TToolBar
        Left = 394
        Top = 12
        Width = 90
        Height = 26
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 83
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        EdgeInner = esNone
        EdgeOuter = esNone
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
        ShowCaptions = True
        TabOrder = 2
      end
      object AraKod: TcxTextEdit
        Left = 51
        Top = 2
        TabOrder = 0
        OnKeyUp = AraKodKeyUp
        Width = 143
      end
    end
    object cxDBTreeList1: TcxDBTreeList
      Left = 6
      Top = 33
      Width = 449
      Height = 303
      Align = alClient
      Bands = <
        item
          Caption.Text = 'Hesap Plan'#305
        end>
      DataController.DataSource = DtsKategoriListe
      DataController.ParentField = 'ROOTKOD'
      DataController.KeyField = 'KOD'
      DefaultRowHeight = 20
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = False
      LookAndFeel.SkinName = 'LondonLiquidSky'
      Navigator.Buttons.CustomButtons = <>
      OptionsBehavior.IncSearch = True
      OptionsData.Appending = True
      OptionsData.Inserting = True
      OptionsData.CheckHasChildren = False
      OptionsData.SmartRefresh = True
      OptionsSelection.MultiSelect = True
      PopupMenu = PopupMenu1
      RootValue = -1
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 1
      OnClick = cxDBTreeList1Click
      OnDblClick = cxDBTreeList1DblClick
      OnSelectionChanged = cxDBTreeList1SelectionChanged
      object TreeListKOD: TcxDBTreeListColumn
        Caption.Text = 'Kod'
        DataBinding.FieldName = 'KOD'
        Options.Editing = False
        Width = 124
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object TreeListAD: TcxDBTreeListColumn
        Caption.Text = 'Ad'
        DataBinding.FieldName = 'AD'
        Options.Editing = False
        Width = 157
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
      object cxDBTreeList1cxDBTreeListSEC: TcxDBTreeListColumn
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.NullStyle = nssInactive
        Properties.ValueChecked = 'True'
        Properties.ValueUnchecked = 'False'
        Properties.OnChange = cxDBTreeList1cxDBTreeListSECPropertiesChange
        Visible = False
        Caption.Text = 'Se'#231
        DataBinding.FieldName = 'SEC'
        Width = 70
        Position.ColIndex = 3
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
  end
  object PageKontrolSag: TcxPageControl
    Left = 461
    Top = 35
    Width = 356
    Height = 342
    Align = alRight
    TabOrder = 2
    Properties.ActivePage = TabPageGenel
    Properties.CustomButtons.Buttons = <>
    OnChange = PageKontrolSagChange
    ClientRectBottom = 338
    ClientRectLeft = 4
    ClientRectRight = 352
    ClientRectTop = 24
    object TabPageGenel: TcxTabSheet
      Caption = 'Genel'
      ImageIndex = 0
      object DBText1: TcxDBLabel
        Left = 75
        Top = 131
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsKategori
        Height = 21
        Width = 65
      end
      object Label2: TcxLabel
        Left = 5
        Top = 154
        Caption = 'Kod'
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
        Left = 5
        Top = 178
        Caption = 'Ad'
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
        Left = 5
        Top = 202
        Caption = 'A'#231#305'klama'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label7: TcxLabel
        Left = 193
        Top = 102
        Caption = 'Durum'
        FocusControl = ComboDURUM
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label13: TcxLabel
        Left = 5
        Top = 130
        Caption = 'ID'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object EditKOD: TcxDBTextEdit
        Left = 75
        Top = 154
        DataBinding.DataField = 'KOD'
        DataBinding.DataSource = DtsKategori
        TabOrder = 5
        Width = 116
      end
      object EditAD: TcxDBTextEdit
        Left = 75
        Top = 178
        DataBinding.DataField = 'AD'
        DataBinding.DataSource = DtsKategori
        TabOrder = 6
        Width = 225
      end
      object EditACIKLAMA: TcxDBTextEdit
        Left = 75
        Top = 202
        DataBinding.DataField = 'ACIKLAMA'
        DataBinding.DataSource = DtsKategori
        TabOrder = 7
        Width = 225
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 236
        Top = 101
        RepositoryItem = Tablo.RepAktifPasif
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsKategori
        Properties.ClearKey = 46
        Properties.Items = <>
        Style.BorderStyle = ebs3D
        TabOrder = 8
        Width = 60
      end
      object LogoResim: TcxDBImage
        Left = 3
        Top = 25
        DataBinding.DataField = 'RESIM'
        DataBinding.DataSource = DtsKategori
        Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
        Properties.FitMode = ifmProportionalStretch
        Properties.GraphicClassName = 'TdxSmartImage'
        TabOrder = 9
        Height = 97
        Width = 128
      end
      object cxDBCheckBox1: TcxDBCheckBox
        Left = 27
        Top = 294
        Caption = 'Rest/Cafe Sat'#305#351
        TabOrder = 11
        Visible = False
      end
      object CheckTRANSFER: TcxDBCheckBox
        Left = 144
        Top = 288
        Caption = 'Transfer'
        TabOrder = 12
        Visible = False
      end
      object cxDBCheckBox2: TcxDBCheckBox
        Left = 207
        Top = 155
        Caption = #304'nternet Sat'#305#351'l'#305
        DataBinding.DataField = 'INTERNET_SATIS'
        DataBinding.DataSource = DtsKategori
        Properties.ImmediatePost = True
        TabOrder = 13
        Transparent = True
      end
    end
    object TabPageMuhasebe: TcxTabSheet
      Caption = 'Muhasebe Kodu'
      ImageIndex = 1
      TabVisible = False
      object GridMuhasebeKod: TcxGrid
        Left = 0
        Top = 0
        Width = 348
        Height = 314
        Align = alClient
        TabOrder = 0
        object GridMuhasebeKodView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsMuhasebeKod
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.GroupByBox = False
          object GridMuhasebeKodViewDEGER: TcxGridDBColumn
            DataBinding.FieldName = 'DEGER'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewYER: TcxGridDBColumn
            DataBinding.FieldName = 'YER'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewYER_ID: TcxGridDBColumn
            DataBinding.FieldName = 'YER_ID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewMUHASEBEID: TcxGridDBColumn
            DataBinding.FieldName = 'MUHASEBEID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewHESAPID: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewMASRAFID: TcxGridDBColumn
            DataBinding.FieldName = 'MASRAFID'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewEKLEYEN: TcxGridDBColumn
            DataBinding.FieldName = 'EKLEYEN'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewEKLEMETARIHI: TcxGridDBColumn
            DataBinding.FieldName = 'EKLEMETARIHI'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewDEGISTIREN: TcxGridDBColumn
            DataBinding.FieldName = 'DEGISTIREN'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewDEGISTIRMETARIHI: TcxGridDBColumn
            DataBinding.FieldName = 'DEGISTIRMETARIHI'
            DataBinding.IsNullValueType = True
            Visible = False
          end
          object GridMuhasebeKodViewTURADI: TcxGridDBColumn
            DataBinding.FieldName = 'TURADI'
            DataBinding.IsNullValueType = True
            Width = 63
          end
          object GridMuhasebeKodViewHESAPKODU: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPKODU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = GridMuhasebeKodViewHESAPKODUPropertiesButtonClick
            Width = 65
          end
          object GridMuhasebeKodViewHESAPADI: TcxGridDBColumn
            DataBinding.FieldName = 'HESAPADI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = GridMuhasebeKodViewHESAPKODUPropertiesButtonClick
            Width = 64
          end
          object GridMuhasebeKodViewMASRAFKODU: TcxGridDBColumn
            DataBinding.FieldName = 'MASRAFKODU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = GridMuhasebeKodViewMASRAFKODUPropertiesButtonClick
            Width = 70
          end
          object GridMuhasebeKodViewMASRAFADI: TcxGridDBColumn
            DataBinding.FieldName = 'MASRAFADI'
            DataBinding.IsNullValueType = True
            Width = 72
          end
        end
        object GridMuhasebeKodLevel1: TcxGridLevel
          GridView = GridMuhasebeKodView
        end
      end
    end
  end
  object DtsKategoriListe: TDataSource
    DataSet = KATEGORI
    Left = 157
    Top = 93
  end
  object KATEGORI: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        ' select ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX('#39'.'#39',RE' +
        'VERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX('#39'.'#39',REVERSE(KOD),1)-1))), '
      '   ID,KOD,AD,DURUM,SEC=1 from KATEGORI')
    Left = 165
    Top = 151
  end
  object TabMuhasebeKod: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT G.DEGER, SM.*,HP.HESAPKODU,HP.HESAPADI,MASRAFKODU=MG.KOD,' +
        'MASRAFADI=MG.AD,TURADI=G.ANAHTAR'
      
        'FROM MUHASEBEKOD SM LEFT OUTER JOIN dbo.GENINI G ON SM.MUHASEBEI' +
        'D=G.DEGER AND G.BOLUM=-2755'
      #9'LEFT OUTER JOIN dbo.HESAPPLANI HP ON SM.HESAPID=HP.ID'
      #9'LEFT OUTER JOIN dbo.MASRAFGELIR MG ON SM.MASRAFID=MG.ID'
      'WHERE YER=355 AND SM.YER_ID=:prm1')
    Left = 688
    Top = 64
  end
  object DtsMuhasebeKod: TDataSource
    DataSet = TabMuhasebeKod
    Left = 664
    Top = 88
  end
  object TabKategori: TFDQuery
    BeforePost = TabKategoriBeforePost
    OnNewRecord = TabKategoriNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from KATEGORI where ID = :PID')
    Left = 427
    Top = 53
  end
  object DtsKategori: TDataSource
    DataSet = TabKategori
    OnStateChange = DtsKategoriStateChange
    Left = 377
    Top = 127
  end
  object PopupMenu1: TPopupMenu
    Left = 216
    Top = 224
    object HepsiniSecMenu: TMenuItem
      Caption = 'Hepsini Se'#231
      OnClick = HepsiniSecMenuClick
    end
    object HepsiniBrakMenu: TMenuItem
      Caption = 'Hepsini B'#305'rak'
      OnClick = HepsiniBrakMenuClick
    end
    object TersCevirMenu: TMenuItem
      Caption = 'Ters '#199'evir'
      OnClick = TersCevirMenuClick
    end
  end
end
