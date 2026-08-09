object DemirbasHareketDlg: TDemirbasHareketDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Demirba'#351' Tutanak Ekran'#305
  ClientHeight = 526
  ClientWidth = 701
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object JvPanel1: TJvPanel
    Left = 0
    Top = 35
    Width = 701
    Height = 214
    Align = alTop
    Color = 16634072
    ParentBackground = False
    TabOrder = 0
    object DateTutanakTarih: TcxDBDateEdit
      Left = 439
      Top = 34
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = dtsTutanak
      TabOrder = 0
      Width = 133
    end
    object editBelgeNo: TcxDBTextEdit
      Left = 120
      Top = 34
      DataBinding.DataField = 'BELGENO'
      DataBinding.DataSource = dtsTutanak
      Enabled = False
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 1
      Width = 177
    end
    object memoNotlar: TcxDBMemo
      Left = 120
      Top = 152
      DataBinding.DataField = 'NOTLAR'
      DataBinding.DataSource = dtsTutanak
      TabOrder = 2
      Height = 55
      Width = 452
    end
    object cbDurum: TcxDBImageComboBox
      Left = 439
      Top = 63
      DataBinding.DataField = 'TIP'
      DataBinding.DataSource = dtsTutanak
      Properties.Items = <
        item
          Description = 'Zimmet'
          ImageIndex = 2
          Value = 1
        end
        item
          Description = #304'ade'
          ImageIndex = 4
          Value = 9
        end
        item
          Description = 'Kay'#305'p'
          ImageIndex = 9
          Value = 2
        end
        item
          Description = 'Hurda'
          ImageIndex = 14
          Value = 3
        end
        item
          Description = 'Transfer'
          Value = 5
        end
        item
          Description = 'Serviste'
          Value = 6
        end>
      Properties.ReadOnly = True
      TabOrder = 3
      Width = 133
    end
    object cbZimmetVeren: TcxButtonEdit
      Left = 120
      Top = 64
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cbZimmetVerenPropertiesButtonClick
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 4
      Width = 177
    end
    object cbZimmetAlan: TcxButtonEdit
      Left = 120
      Top = 93
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cbZimmetAlanPropertiesButtonClick
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 5
      Width = 177
    end
    object cbDuzenleyen: TcxButtonEdit
      Left = 439
      Top = 93
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = cbDuzenleyenPropertiesButtonClick
      TabOrder = 6
      Width = 133
    end
    object BELokasyon: TcxButtonEdit
      Left = 120
      Top = 122
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = BELokasyonPropertiesButtonClick
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBackground
      TabOrder = 7
      Width = 177
    end
    object lblZimmeteVeren: TcxLabel
      Left = 4
      Top = 65
      Caption = 'Zimmet Veren'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object Tarih: TcxLabel
      Left = 4
      Top = 35
      Caption = 'Belge No'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblZimmetAlan: TcxLabel
      Left = 4
      Top = 94
      Caption = 'Zimmet Alan'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lbLokasyon: TcxLabel
      Left = 4
      Top = 123
      Caption = 'Lokasyon'
      FocusControl = BELokasyon
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
      Left = 4
      Top = 153
      Caption = 'Notlar'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LblTutanakID: TcxDBLabel
      Left = 120
      Top = 6
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = dtsTutanak
      Transparent = True
      Height = 21
      Width = 72
    end
    object cxLabel1: TcxLabel
      Left = 332
      Top = 35
      Caption = 'Tarih'
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
      Left = 332
      Top = 65
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
    object Label3: TcxLabel
      Left = 332
      Top = 94
      Caption = 'D'#252'zenleyen'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel2: TcxDBLabel
      Left = 332
      Top = 124
      DataBinding.DataField = 'EKLEYEN'
      DataBinding.DataSource = dtsTutanak
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clGray
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
      Height = 21
      Width = 64
    end
    object cxDBLabel3: TcxDBLabel
      Left = 440
      Top = 124
      DataBinding.DataField = 'EKLEMETARIHI'
      DataBinding.DataSource = dtsTutanak
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clGray
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
      Visible = False
      Height = 21
      Width = 132
    end
  end
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 695
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
    TabOrder = 1
    Transparent = True
    object btnKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = btnKaydetClick
    end
    object btnSil1: TToolButton
      Left = 69
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      OnClick = btnSil1Click
    end
    object YaziciYaz: TToolButton
      Left = 138
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
    end
    object ToolButton1: TToolButton
      Left = 207
      Top = 0
      Width = 257
      Caption = 'ToolButton1'
      ImageIndex = 18
      Style = tbsSeparator
    end
    object btnkapat: TToolButton
      Left = 464
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      OnClick = btnkapatClick
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 249
    Width = 701
    Height = 277
    Align = alClient
    Caption = 'PanelGrid'
    TabOrder = 2
    object ToolBarDetay: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 693
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
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object btnYeni: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 0
        Visible = False
        OnClick = btnYeniClick
      end
      object btnSil: TToolButton
        Left = 48
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        Visible = False
        OnClick = btnSilClick
      end
    end
    object gridTutanakDetay: TcxGrid
      Left = 1
      Top = 28
      Width = 699
      Height = 248
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfOffice11
      object tvTutanakDetay: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = dtsTutanakDetay
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.GroupByBox = False
        object clmId: TcxGridDBColumn
          Caption = 'Id'
          DataBinding.FieldName = 'ID'
          Visible = False
          Width = 41
        end
        object clmDemirbasId: TcxGridDBColumn
          Caption = 'Demirba'#351'Id'
          DataBinding.FieldName = 'DEMIRBASID'
          Visible = False
          Width = 74
        end
        object clmStokKodu: TcxGridDBColumn
          Caption = 'No'
          DataBinding.FieldName = 'DEMIRBASNO'
        end
        object clmDemirbasAdi: TcxGridDBColumn
          Caption = 'Ad'#305
          DataBinding.FieldName = 'DEMIRBASADI'
          Width = 102
        end
        object clmSerino: TcxGridDBColumn
          Caption = 'Seri No'
          DataBinding.FieldName = 'SERINO'
        end
        object clmAlimTarihi: TcxGridDBColumn
          Caption = 'Al'#305'm Tarihi'
          DataBinding.FieldName = 'ALIMTARIHI'
        end
        object tvTutanakDetayDURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
          RepositoryItem = Tablo.repDemirbasDurum
        end
        object tvTutanakDetayLOKASYONADI: TcxGridDBColumn
          Caption = 'Lokasyon'
          DataBinding.FieldName = 'LOKASYONADI'
        end
      end
      object gridTutanakDetayLevel1: TcxGridLevel
        GridView = tvTutanakDetay
      end
    end
  end
  object TabTutanak: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabTutanakBeforePost
    OnNewRecord = TabTutanakNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM DEMIRBAS_TUTANAK'
      'WHERE ID = :PID')
    Left = 48
    Top = 352
  end
  object dtsTutanak: TDataSource
    DataSet = TabTutanak
    OnStateChange = dtsTutanakStateChange
    Left = 112
    Top = 336
  end
  object dtsTutanakDetay: TDataSource
    DataSet = TabTutanakDetay
    Left = 928
    Top = 200
  end
  object TabTutanakDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT '
      
        '    DTD.ID, DTD.DEMIRBASID, D.DEMIRBASNO,D.DEMIRBASADI,  D.SERIN' +
        'O, D.ALIMTARIHI,'
      
        #9'D.DURUM,D.LOKASYONID,L.ACIKLAMA  As LOKASYONADI, D.ZIMMETLIPERS' +
        'ONELID'
      'FROM'
      '    DEMIRBAS_TUTANAK_DETAY DTD '
      '    INNER JOIN DEMIRBAS D ON DTD.DEMIRBASID = D.ID'
      #9'LEFT OUTER JOIN LOKASYON AS L ON L.ID=D.LOKASYONID  '
      'WHERE'
      '    DTD.TUTANAKID = :PTUTANAKID')
    Left = 96
    Top = 416
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 230
    Top = 8
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
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxReport1: TfrxReport
    Version = '4.13.1'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 40646.402858726850000000
    ReportOptions.LastChange = 40646.402858726850000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 312
    Top = 328
    Datasets = <>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
    end
  end
  object frxTutanakDetay: TfrxDBDataset
    UserName = 'DEMIRBAS_TUTANAK_DETAY'
    CloseDataSource = False
    DataSet = TabTutanakDetay
    BCDToCurrency = False
    Left = 928
    Top = 136
  end
  object frxTutanakBas: TfrxDBDataset
    UserName = 'DEMIRBAS_TUTANAK'
    CloseDataSource = False
    FieldAliases.Strings = (
      'ID=ID'
      'TARIH=TARIH'
      'BELGENO=BELGENO'
      'TIP=TIP'
      'TUTANAK=TUTANAK'
      'LOKASYONID=LOKASYONID'
      'LOKASYON=LOKASYON'
      'DUZENLEYENID=DUZENLEYENID'
      'DUZENLEYEN=DUZENLEYEN'
      'ZIMMETALAN=ZIMMETALAN'
      'ZIMMETALANID=ZIMMETALANID'
      'ZIMMETVEREN=ZIMMETVEREN'
      'ZIMMETVERENID=ZIMMETVERENID'
      'DEMIRBASID=DEMIRBASID')
    DataSet = TabTutanakYaz
    BCDToCurrency = False
    Left = 208
    Top = 304
  end
  object TabTutanakYaz: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'SELECT     DT.ID, DT.TARIH,DT.BELGENO, DT.TIP, DI.ANAHTAR AS TUT' +
        'ANAK, DT.LOKASYONID, L.ACIKLAMA AS LOKASYON, DT.DUZENLEYENID, R3' +
        '.FIRMA AS DUZENLEYEN, '
      
        '                      R1.FIRMA AS ZIMMETALAN, DT.ZIMMETALANID, R' +
        '2.FIRMA AS ZIMMETVEREN, DT.ZIMMETVERENID'
      'FROM       DEMIRBAS_TUTANAK AS DT '
      
        '                   LEFT OUTER JOIN   REHBER AS R1 ON DT.ZIMMETAL' +
        'ANID = R1.ID '
      
        '                   LEFT OUTER JOIN   REHBER AS R2 ON DT.ZIMMETVE' +
        'RENID = R2.ID '
      
        '                   LEFT OUTER JOIN   REHBER AS R3 ON DT.DUZENLEY' +
        'ENID = R3.ID '
      
        '                   LEFT OUTER JOIN       (SELECT     BOLUM, ANAH' +
        'TAR, DEGER'
      '                            FROM          GENINI'
      
        '                            WHERE      (BOLUM = -2803)) AS DI ON' +
        ' DI.DEGER = DT.TIP LEFT OUTER JOIN'
      '                        LOKASYON as L on L.ID=DT.LOKASYONID'
      ''
      'WHERE DT.ID=:pt1')
    Left = 184
    Top = 384
  end
end
