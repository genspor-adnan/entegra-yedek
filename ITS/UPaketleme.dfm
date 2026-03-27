object PaketlemeDlg: TPaketlemeDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Paketleme'
  ClientHeight = 501
  ClientWidth = 770
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TbAletCubugu: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 764
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 107
    Caption = 'TbAletCubugu'
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
    object btnKaydet: TToolButton
      Left = 0
      Top = 0
      Caption = #304#351'lemi Tamamla'
      ImageIndex = 11
      Style = tbsTextButton
      OnClick = btnKaydetClick
    end
    object ToolButton10: TToolButton
      Left = 107
      Top = 0
      Width = 8
      Caption = 'ToolButton10'
      ImageIndex = 20
      Style = tbsSeparator
    end
    object btnIptal: TToolButton
      Left = 115
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Visible = False
    end
    object BtnKapat: TToolButton
      Left = 222
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Visible = False
    end
    object ToolButton3: TToolButton
      Left = 329
      Top = 0
      Caption = 'XML Olu'#351'tur'
      ImageIndex = 19
    end
  end
  object pnlFaturaBilgiler: TPanel
    Left = 0
    Top = 35
    Width = 770
    Height = 54
    Align = alTop
    TabOrder = 1
    object lblHataMesaj: TcxLabel
      Left = 4
      Top = 39
      AutoSize = False
      Style.TextColor = clRed
      Properties.WordWrap = True
      Transparent = True
      Height = 38
      Width = 375
    end
    object cxDBLabel1: TcxDBLabel
      Left = 606
      Top = 3
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = ITSBildirimDlg.DtsPaketlemeListesi
      Transparent = True
      Height = 21
      Width = 121
    end
    object cxLabel1: TcxLabel
      Left = 565
      Top = 3
      Caption = 'Tarih :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 11
      Top = 3
      Caption = 'Id :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LblPaketId: TcxDBLabel
      Left = 38
      Top = 3
      DataBinding.DataField = 'ID'
      DataBinding.DataSource = ITSBildirimDlg.DtsPaketlemeListesi
      Transparent = True
      Height = 21
      Width = 35
    end
    object cxLabel9: TcxLabel
      Left = 11
      Top = 26
      Caption = 'Firma :'
      ParentColor = False
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.Color = clBtnFace
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clHighlight
      Style.Font.Height = -11
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBLabel3: TcxDBLabel
      Left = 54
      Top = 26
      DataBinding.DataField = 'FIRMA'
      DataBinding.DataSource = ITSBildirimDlg.DtsPaketlemeListesi
      Transparent = True
      Height = 21
      Width = 190
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 89
    Width = 770
    Height = 54
    Align = alTop
    TabOrder = 2
    object cxLabel5: TcxLabel
      Left = 4
      Top = 11
      Caption = 'S'#305'ra Numaras'#305
    end
    object EdtEkleSıraNo: TcxTextEdit
      Left = 4
      Top = 27
      TabOrder = 1
      OnKeyDown = EdtEkleSıraNoKeyDown
      Width = 150
    end
    object EdtGerekli: TcxDBTextEdit
      Left = 171
      Top = 27
      DataBinding.DataField = 'URETIMADET'
      Enabled = False
      TabOrder = 2
      Width = 59
    end
    object cxLabel3: TcxLabel
      Left = 171
      Top = 11
      Caption = 'Gerekli Adet'
    end
    object cxLabel4: TcxLabel
      Left = 251
      Top = 11
      Caption = 'Toplam Adet'
    end
    object cbStokDepo: TcxImageComboBox
      Left = 321
      Top = 29
      RepositoryItem = Tablo.RepStokDepolar
      Enabled = False
      Properties.ImmediatePost = True
      Properties.Items = <>
      TabOrder = 5
      Width = 99
    end
    object LblToplamAdet: TcxLabel
      Left = 251
      Top = 30
      ParentColor = False
      Style.Color = clBtnShadow
      Style.TextColor = clRed
      Style.TransparentBorder = True
      Transparent = True
    end
    object GroupBox1: TGroupBox
      Left = 464
      Top = 6
      Width = 177
      Height = 42
      Caption = 'Otomatik Yazdir'
      TabOrder = 7
      object cxLabel6: TcxLabel
        Left = 3
        Top = 18
        Caption = 'Koli '#304#231'i Adet :'
      end
      object ChkAktif: TcxCheckBox
        Left = 127
        Top = 18
        Caption = 'Aktif'
        State = cbsChecked
        TabOrder = 1
        Width = 49
      end
    end
    object EdtYazdirAdet: TcxSpinEdit
      Left = 540
      Top = 23
      TabOrder = 8
      Value = 12
      Width = 45
    end
  end
  object Panel2: TPanel
    Left = 273
    Top = 143
    Width = 497
    Height = 358
    Align = alClient
    TabOrder = 3
    object ToolBar5: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 489
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
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
      HotTrackColor = 65408
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object KarekodEkleTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 0
        Visible = False
      end
      object KarekodSilTus: TToolButton
        Left = 93
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = KarekodSilTusClick
      end
      object KarekodKaydetTus: TToolButton
        Left = 186
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Style = tbsTextButton
        Visible = False
      end
      object KarekodIptalTus: TToolButton
        Left = 279
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Style = tbsTextButton
        Visible = False
      end
      object ToolButton4: TToolButton
        Left = 372
        Top = 0
        Caption = 'Listeden Ekle'
        ImageIndex = 4
        OnClick = ToolButton4Click
      end
    end
    object GridPaketleme: TcxGrid
      Left = 1
      Top = 28
      Width = 495
      Height = 329
      Align = alClient
      TabOrder = 1
      object DbTvPaketleme: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsPaketleme
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
          Width = 24
        end
        object DbTvPaketlemeURUNBARKOD: TcxGridDBColumn
          DataBinding.FieldName = 'URUNBARKOD'
          Options.Editing = False
        end
        object DbTvPaketlemeSIRANO: TcxGridDBColumn
          DataBinding.FieldName = 'SIRANO'
          Options.Editing = False
        end
        object DbTvPaketlemeSONKULLANIM: TcxGridDBColumn
          DataBinding.FieldName = 'SONKULLANIM'
          Options.Editing = False
        end
        object DbTvPaketlemeLOTNO: TcxGridDBColumn
          DataBinding.FieldName = 'LOTNO'
          Options.Editing = False
        end
      end
      object GlPaketleme: TcxGridLevel
        GridView = DbTvPaketleme
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 143
    Width = 273
    Height = 358
    Align = alLeft
    TabOrder = 4
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 265
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 58
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
      TabOrder = 0
      Transparent = True
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Caption = 'Yeni'
        ImageIndex = 0
        OnClick = ToolButton1Click
      end
      object ToolButton2: TToolButton
        Left = 58
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = ToolButton2Click
      end
      object YaziciYaz: TToolButton
        Left = 116
        Top = 0
        Caption = 'Etiket'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 8
        OnClick = YaziciYazClick
      end
    end
    object TreeListTasimaBirimleri: TcxDBTreeList
      Left = 1
      Top = 28
      Width = 271
      Height = 329
      Hint = ''
      Align = alClient
      Bands = <
        item
        end>
      DataController.DataSource = DtsTasimaBirimi
      DataController.ParentField = 'USTID'
      DataController.KeyField = 'ID'
      Navigator.Buttons.CustomButtons = <>
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRect = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.Indicator = True
      RootValue = -1
      TabOrder = 1
      object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Palet'
            ImageIndex = 0
            Value = 'P'
          end
          item
            Description = 'Koli'
            Value = 'C'
          end
          item
            Description = 'Ba'#287
            Value = 'S'
          end
          item
            Description = 'Koli '#304#231'i Kutu'
            Value = 'B'
          end
          item
            Description = 'K'#252#231#252'k Ba'#287
            Value = 'E'
          end>
        Caption.Text = 'Ta'#351#305'ma Birimi'
        DataBinding.FieldName = 'TASIMA_BIRIMI'
        Options.Editing = False
        Width = 86
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn
        Caption.Text = 'SSCC Etiketi'
        DataBinding.FieldName = 'SSCC'
        Options.Editing = False
        Width = 131
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
  end
  object TabPaketleme: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    AfterScroll = TabPaketlemeAfterScroll
    Parameters = <
      item
        Name = 'PAKETID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end
      item
        Name = 'TASIMA_BIRIM_ID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT *  FROM STOKID WHERE PAKETID =:PAKETID AND TASIMA_BIRIMI_' +
        'ID =:TASIMA_BIRIM_ID ')
    Left = 637
    Top = 35
    object TabPaketlemeID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabPaketlemeGIRISTURU: TWordField
      FieldName = 'GIRISTURU'
    end
    object TabPaketlemeSTOKID: TIntegerField
      FieldName = 'STOKID'
    end
    object TabPaketlemeGIRFATBASID: TIntegerField
      FieldName = 'GIRFATBASID'
    end
    object TabPaketlemeGIRFATURAID: TIntegerField
      FieldName = 'GIRFATURAID'
    end
    object TabPaketlemeURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabPaketlemeSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabPaketlemeSERINO: TStringField
      FieldName = 'SERINO'
    end
    object TabPaketlemeCIKISTURU: TWordField
      FieldName = 'CIKISTURU'
    end
    object TabPaketlemeCIKFATBASID: TIntegerField
      FieldName = 'CIKFATBASID'
    end
    object TabPaketlemeCIKFATURAID: TIntegerField
      FieldName = 'CIKFATURAID'
    end
    object TabPaketlemeGARANTIBITIS: TDateTimeField
      FieldName = 'GARANTIBITIS'
    end
    object TabPaketlemeIZLEMTURU: TWordField
      FieldName = 'IZLEMTURU'
    end
    object TabPaketlemeONAY: TBooleanField
      FieldName = 'ONAY'
    end
    object TabPaketlemeSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object TabPaketlemeLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabPaketlemeURUNCINSI: TStringField
      FieldName = 'URUNCINSI'
      Size = 5
    end
    object TabPaketlemeURETIMTARIHI: TDateTimeField
      FieldName = 'URETIMTARIHI'
    end
    object TabPaketlemeURETIMTIPI: TStringField
      FieldName = 'URETIMTIPI'
      Size = 5
    end
    object TabPaketlemePAKETID: TIntegerField
      FieldName = 'PAKETID'
    end
    object TabPaketlemeTASIMA_BIRIMI_ID: TIntegerField
      FieldName = 'TASIMA_BIRIMI_ID'
    end
  end
  object DtsPaketleme: TDataSource
    DataSet = TabPaketleme
    Left = 684
    Top = 74
  end
  object TabPaketler: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'PAKETID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT  *  FROM STOKID WHERE PAKETID =:PAKETID')
    Left = 685
    Top = 139
    object AutoIncField1: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object WordField1: TWordField
      FieldName = 'GIRISTURU'
    end
    object IntegerField1: TIntegerField
      FieldName = 'STOKID'
    end
    object IntegerField2: TIntegerField
      FieldName = 'GIRFATBASID'
    end
    object IntegerField3: TIntegerField
      FieldName = 'GIRFATURAID'
    end
    object StringField1: TStringField
      FieldName = 'URUNBARKOD'
    end
    object StringField2: TStringField
      FieldName = 'SIRANO'
    end
    object StringField3: TStringField
      FieldName = 'SERINO'
    end
    object WordField2: TWordField
      FieldName = 'CIKISTURU'
    end
    object IntegerField4: TIntegerField
      FieldName = 'CIKFATBASID'
    end
    object IntegerField5: TIntegerField
      FieldName = 'CIKFATURAID'
    end
    object DateTimeField1: TDateTimeField
      FieldName = 'GARANTIBITIS'
    end
    object WordField3: TWordField
      FieldName = 'IZLEMTURU'
    end
    object BooleanField1: TBooleanField
      FieldName = 'ONAY'
    end
    object DateTimeField2: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object StringField4: TStringField
      FieldName = 'LOTNO'
    end
    object StringField5: TStringField
      FieldName = 'URUNCINSI'
      Size = 5
    end
    object DateTimeField3: TDateTimeField
      FieldName = 'URETIMTARIHI'
    end
    object StringField6: TStringField
      FieldName = 'URETIMTIPI'
      Size = 5
    end
  end
  object DtsPaketler: TDataSource
    DataSet = TabPaketleme
    Left = 572
    Top = 74
  end
  object TabTasimaBirimi: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    AfterScroll = TabTasimaBirimiAfterScroll
    Parameters = <
      item
        Name = 'PAKETID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT  *'
      
        '--(SELECT COUNT(*) FROM dbo.fn_ITS_TasimaBirimleri_Recursive(tb.' +
        'ID) INNER JOIN STOKID SI ON SI.TASIMA_BIRIMI_ID=TsimaBirimiID ) ' +
        'AS ADET2'
      ' FROM ITS_TASIMA_BIRIMI TB WHERE PAKETID =:PAKETID')
    Left = 501
    Top = 43
    object TabTasimaBirimiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabTasimaBirimiUSTID: TIntegerField
      FieldName = 'USTID'
    end
    object TabTasimaBirimiSSCC: TStringField
      FieldName = 'SSCC'
      Size = 50
    end
    object TabTasimaBirimiPAKETID: TIntegerField
      FieldName = 'PAKETID'
    end
    object TabTasimaBirimiTASIMA_BIRIMI: TStringField
      FieldName = 'TASIMA_BIRIMI'
      Size = 2
    end
  end
  object DtsTasimaBirimi: TDataSource
    DataSet = TabTasimaBirimi
    Left = 356
    Top = 66
  end
  object PopupMenuYaz: TPopupMenu
    Left = 361
    Top = 217
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
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object TabTasimaEtiket: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'ID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT  *,(select COUNT(ID) from STOKID WHERE TASIMA_BIRIMI_ID=t' +
        'b.ID) AS ADET ,'
      
        '(SELECT COUNT(*) FROM dbo.fn_ITS_TasimaBirimleri_Recursive(tb.ID' +
        ') INNER JOIN STOKID SI ON SI.TASIMA_BIRIMI_ID=TsimaBirimiID ) AS' +
        ' ADET2,'
      
        '--(SELECT COUNT(ID) FROM STOKID WHERE TASIMA_BIRIMI_ID=TB.ID) AS' +
        ' KOLIICI,'
      '(CASE WHEN TASIMA_BIRIMI='#39'P'#39'  THEN '#39'Palet '#39' '
      'else  '
      'CASE WHEN TASIMA_BIRIMI='#39'C'#39' THEN '#39'Koli '#39' '
      'else'
      'CASE WHEN TASIMA_BIRIMI='#39'B'#39' THEN '#39'Koli '#304#231'i Kutu '#39' '
      'end'
      'end'
      'end ) as TASIMABIRIM,'
      '(SELECT TOP 1 S.STOKADI FROM STOKID SI '
      'INNER JOIN STOKLAR S ON S.ID=SI.STOKID'
      'WHERE SI.TASIMA_BIRIMI_ID = TB.ID) AS URUNADI,'
      
        '(SELECT TOP 1 CONVERT(VARCHAR(10),SI.SONKULLANIM,120) FROM STOKI' +
        'D SI WHERE SI.TASIMA_BIRIMI_ID=TB.ID)AS SONKULLANIM'
      'FROM ITS_TASIMA_BIRIMI TB  '
      'WHERE ID=:ID')
    Left = 461
    Top = 219
    object TabTasimaEtiketTASIMA_BIRIMI: TStringField
      FieldName = 'TASIMA_BIRIMI'
      Size = 2
    end
    object TabTasimaEtiketSSCC: TStringField
      FieldName = 'SSCC'
      Size = 50
    end
    object TabTasimaEtiketPAKETID: TIntegerField
      FieldName = 'PAKETID'
    end
    object TabTasimaEtiketADET: TIntegerField
      FieldName = 'ADET'
      ReadOnly = True
    end
    object TabTasimaEtiketTASIMABIRIM: TStringField
      FieldName = 'TASIMABIRIM'
      ReadOnly = True
      Size = 14
    end
    object TabTasimaEtiketURUNADI: TWideStringField
      FieldName = 'URUNADI'
      ReadOnly = True
      Size = 100
    end
    object TabTasimaEtiketID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabTasimaEtiketUSTID: TIntegerField
      FieldName = 'USTID'
    end
    object TabTasimaEtiketSONKULLANIM: TStringField
      FieldName = 'SONKULLANIM'
      ReadOnly = True
      Size = 10
    end
    object TabTasimaEtiketADET2: TIntegerField
      FieldName = 'ADET2'
      ReadOnly = True
    end
  end
  object DtsTasimaBirimiEtiket: TDataSource
    DataSet = TabTasimaEtiket
    Left = 420
    Top = 66
  end
  object frxTasimaBirimiEtiket: TfrxDBDataset
    UserName = 'ETIKETPAKET'
    CloseDataSource = False
    FieldAliases.Strings = (
      'TASIMA_BIRIMI=TASIMA_BIRIMI'
      'SSCC=SSCC'
      'PAKETID=PAKETID'
      'ADET=ADET'
      'KOLIICI=KOLIICI'
      'TASIMABIRIM=TASIMABIRIM'
      'URUNADI=URUNADI'
      'ID=ID'
      'USTID=USTID'
      'ADET2=ADET2'
      'SONKULLANIM=SONKULLANIM')
    DataSource = DtsTasimaBirimiEtiket
    BCDToCurrency = False
    Left = 560
    Top = 216
  end
end
