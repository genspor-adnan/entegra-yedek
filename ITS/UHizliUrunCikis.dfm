object HizliUrunCikisDlg: THizliUrunCikisDlg
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = #220'r'#252'n C'#305'k'#305#351
  ClientHeight = 544
  ClientWidth = 998
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 998
    Height = 65
    Align = alTop
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object cxDBLabel1: TcxDBLabel
      Left = 298
      Top = 16
      DataBinding.DataField = 'FIRMA'
      DataBinding.DataSource = dtsUrunler
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -24
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsBold]
      Style.TextColor = 8404992
      Style.IsFontAssigned = True
      Height = 43
      Width = 976
    end
    object cxDBLabel2: TcxDBLabel
      Left = 16
      Top = 16
      DataBinding.DataField = 'TARIH'
      DataBinding.DataSource = dtsUrunler
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clMaroon
      Style.Font.Height = -24
      Style.Font.Name = 'Verdana'
      Style.Font.Style = [fsBold]
      Style.TextColor = 8404992
      Style.IsFontAssigned = True
      Height = 43
      Width = 276
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 65
    Width = 998
    Height = 64
    Align = alTop
    TabOrder = 1
    object EdtEkleSıraNo: TcxTextEdit
      Left = 15
      Top = 16
      ParentFont = False
      Style.BorderStyle = ebsSingle
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = 'Verdana'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 0
      OnKeyPress = EdtEkleSıraNoKeyPress
      Width = 882
    end
    object ChkCikar: TcxCheckBox
      Left = 903
      Top = 14
      Caption = #199#305'kar'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -21
      Style.Font.Name = 'Verdana'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 1
      Width = 88
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 424
    Width = 998
    Height = 120
    Align = alBottom
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object ToolBar1: TToolBar
      Left = 1
      Top = 1
      Width = 996
      Height = 51
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 49
      ButtonWidth = 154
      Caption = 'AletCubugu'
      Color = clTeal
      DockSite = True
      DrawingStyle = dsGradient
      EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
      EdgeInner = esLowered
      EdgeOuter = esNone
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -35
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      GradientEndColor = 11776947
      GradientStartColor = 14540253
      HotTrackColor = 65408
      List = True
      GradientDirection = gdHorizontal
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object ToolButton2: TToolButton
        Left = 0
        Top = 0
        Caption = #199#305'k'
        ImageIndex = 1
        OnClick = ToolButton2Click
      end
      object YaziciYaz: TToolButton
        Left = 154
        Top = 0
        Caption = 'Etiket'
        DropdownMenu = PopupMenuYaz
        ImageIndex = 8
      end
      object ToolButton1: TToolButton
        Left = 308
        Top = 0
        Caption = 'Tamamla'
        ImageIndex = 9
        OnClick = ToolButton1Click
      end
    end
  end
  object GridUrunler: TcxGrid
    Left = 0
    Top = 129
    Width = 998
    Height = 295
    Align = alClient
    TabOrder = 3
    object TvUrunler: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      NavigatorButtons.First.Visible = True
      NavigatorButtons.PriorPage.Visible = True
      NavigatorButtons.Prior.Visible = True
      NavigatorButtons.Next.Visible = True
      NavigatorButtons.NextPage.Visible = True
      NavigatorButtons.Last.Visible = True
      NavigatorButtons.Insert.Visible = True
      NavigatorButtons.Append.Visible = False
      NavigatorButtons.Delete.Visible = True
      NavigatorButtons.Edit.Visible = True
      NavigatorButtons.Post.Visible = True
      NavigatorButtons.Cancel.Visible = True
      NavigatorButtons.Refresh.Visible = True
      NavigatorButtons.SaveBookmark.Visible = True
      NavigatorButtons.GotoBookmark.Visible = True
      NavigatorButtons.Filter.Visible = True
      OnCellDblClick = TvUrunlerCellDblClick
      DataController.DataSource = dtsUrunler
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsView.CellAutoHeight = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      Styles.OnGetContentStyle = cxGrid1DBTableView1StylesGetContentStyle
      object TvUrunlerSTOKADI: TcxGridDBColumn
        DataBinding.FieldName = 'STOKADI'
        MinWidth = 550
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
        Styles.Header = cxStyle1
        Width = 550
      end
      object TvUrunlerColumn1: TcxGridDBColumn
        DataBinding.FieldName = 'RAF'
        Styles.Header = cxStyle1
        Width = 150
      end
      object TvUrunlerADET: TcxGridDBColumn
        DataBinding.FieldName = 'ADET'
        MinWidth = 110
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
        Styles.Header = cxStyle1
        Width = 110
      end
      object TvUrunlerOKUTULAN: TcxGridDBColumn
        DataBinding.FieldName = 'OKUTULAN'
        MinWidth = 110
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
        Styles.Header = cxStyle1
        Width = 110
      end
      object TvUrunlerColumn2: TcxGridDBColumn
        Caption = 'TA'#350'IMA B'#304'R'#304'M'#304
        DataBinding.FieldName = 'TASIMA_BIRIMI'
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'PALET'
            ImageIndex = 0
            Value = 'P'
          end
          item
            Description = 'KOL'#304
            Value = 'C'
          end
          item
            Description = 'BA'#286
            Value = 'S'
          end
          item
            Description = 'KOL'#304' '#304#199#304' KUTU'
            Value = 'B'
          end
          item
            Description = 'K'#220#199#220'K BA'#286
            Value = 'E'
          end>
        Styles.Header = cxStyle1
        Width = 146
      end
      object TvUrunlerColumn3: TcxGridDBColumn
        DataBinding.FieldName = 'SSCC'
        Styles.Header = cxStyle1
        Width = 300
      end
      object TvUrunlerColumn4: TcxGridDBColumn
        DataBinding.FieldName = 'IZLEME'
        Visible = False
      end
    end
    object TvLokasyon: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      NavigatorButtons.First.Visible = True
      NavigatorButtons.PriorPage.Visible = True
      NavigatorButtons.Prior.Visible = True
      NavigatorButtons.Next.Visible = True
      NavigatorButtons.NextPage.Visible = True
      NavigatorButtons.Last.Visible = True
      NavigatorButtons.Insert.Visible = True
      NavigatorButtons.Append.Visible = False
      NavigatorButtons.Delete.Visible = True
      NavigatorButtons.Edit.Visible = True
      NavigatorButtons.Post.Visible = True
      NavigatorButtons.Cancel.Visible = True
      NavigatorButtons.Refresh.Visible = True
      NavigatorButtons.SaveBookmark.Visible = True
      NavigatorButtons.GotoBookmark.Visible = True
      NavigatorButtons.Filter.Visible = True
      DataController.DataSource = DtsLokasyon
      DataController.DetailKeyFieldNames = 'STOKID'
      DataController.KeyFieldNames = 'SIPARISID'
      DataController.MasterKeyFieldNames = 'STOKID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsView.ScrollBars = ssNone
      OptionsView.CellAutoHeight = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.Header = False
      Styles.Content = Tablo.cxStyle20
      object vLokasyonColumn4: TcxGridDBColumn
        DataBinding.FieldName = 'STOKADI'
        Width = 300
      end
      object vLokasyonColumn1: TcxGridDBColumn
        DataBinding.FieldName = 'LOKASYON'
        SortIndex = 0
        SortOrder = soAscending
        Width = 150
      end
      object vLokasyonColumn2: TcxGridDBColumn
        DataBinding.FieldName = 'SONKULLANIM'
        Width = 80
      end
      object vLokasyonColumn3: TcxGridDBColumn
        DataBinding.FieldName = 'KALAN'
        Width = 110
      end
    end
    object LvlUrunler: TcxGridLevel
      GridView = TvUrunler
      object LvlLokasyon: TcxGridLevel
        GridView = TvLokasyon
      end
    end
  end
  object ADOQuery1: TADOQuery
    Connection = Tablo.cnn
    Parameters = <>
    Left = 712
    Top = 16
  end
  object Taburunler: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    AfterOpen = TaburunlerAfterOpen
    Parameters = <
      item
        Name = 'SIPARISID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'SELECT S.STOKADI,SD.ADET,SD.IZLEME,L.ACIKLAMA AS RAF,'
      '        ISNULL(  (CASE WHEN  S.IZLEME=3 THEN '
      
        #9#9#9#9'(SELECT COUNT(ID) FROM STOKID WHERE CIKFATBASID =SP.ID AND C' +
        'IKFATURAID = SD.ID)'
      #9#9#9#9#9#9#9#9' ELSE  SD.FATURA_MIKTAR   END )  ,0)    '
      
        #9#9'AS OKUTULAN ,SD.ID AS SIPARISDETAYID,SP.ID AS SIPARISID,FIRMA,' +
        'SP.TARIH'
      
        '        ,P.ID AS PAKETID, T.ID AS TASIMABIRIMIID ,T.TASIMA_BIRIM' +
        'I ,T.SSCC,S.ID AS STOKID'
      '      FROM SIPARISDETAY SD'
      '      INNER JOIN SIPARIS SP ON SP.ID=SD.SIPARISID'
      '      INNER JOIN STOKLAR S ON  S.ID=SD.URUNID'
      '      INNER JOIN REHBER R ON R.ID = SP.REHBERID'
      '      LEFT OUTER JOIN ITS_PAKET P ON  P.SIPARISID=SP.ID '
      '      LEFT OUTER JOIN ITS_TASIMA_BIRIMI T ON T.PAKETID = P.ID '
      '      LEFT OUTER JOIN LOKASYON L ON L.ID = S.LOKASYONID'
      '      WHERE SP.ID = :SIPARISID')
    Left = 800
    Top = 16
    object TaburunlerSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TaburunlerADET: TFloatField
      FieldName = 'ADET'
    end
    object TaburunlerIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object TaburunlerRAF: TWideStringField
      FieldName = 'RAF'
      Size = 100
    end
    object TaburunlerOKUTULAN: TIntegerField
      FieldName = 'OKUTULAN'
      ReadOnly = True
    end
    object TaburunlerSIPARISDETAYID: TAutoIncField
      FieldName = 'SIPARISDETAYID'
      ReadOnly = True
    end
    object TaburunlerSIPARISID: TAutoIncField
      FieldName = 'SIPARISID'
      ReadOnly = True
    end
    object TaburunlerFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TaburunlerTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TaburunlerPAKETID: TAutoIncField
      FieldName = 'PAKETID'
      ReadOnly = True
    end
    object TaburunlerTASIMABIRIMIID: TAutoIncField
      FieldName = 'TASIMABIRIMIID'
      ReadOnly = True
    end
    object TaburunlerTASIMA_BIRIMI: TStringField
      FieldName = 'TASIMA_BIRIMI'
      Size = 2
    end
    object TaburunlerSSCC: TStringField
      FieldName = 'SSCC'
      Size = 50
    end
    object TaburunlerSTOKID: TAutoIncField
      FieldName = 'STOKID'
      ReadOnly = True
    end
  end
  object dtsUrunler: TDataSource
    DataSet = Taburunler
    Left = 744
    Top = 80
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
    Left = 741
    Top = 139
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
    Left = 640
    Top = 112
  end
  object DtsTasimaBirimiEtiket: TDataSource
    DataSet = TabTasimaEtiket
    Left = 820
    Top = 106
  end
  object PopupMenuYaz: TPopupMenu
    Left = 857
    Top = 153
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
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
  object cxStyleRepository1: TcxStyleRepository
    Left = 512
    Top = 16
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clActiveBorder
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clSilver
      Font.Charset = ANSI_CHARSET
      Font.Color = 16236663
      Font.Height = -16
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      TextColor = clBlack
    end
  end
  object TabLokasyon: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'SIPARISID'
        Attributes = [paSigned]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT S.ID AS SIPARISID,SD.ID AS SIPARISDETAYID,ST.ID AS STOKID' +
        ','
      
        #9'ST.STOKADI,ISNULL(L.ACIKLAMA,'#39'Lokasyon Girilmemi'#351#39') AS LOKASYON' +
        ' ,'
      
        #9'SI.SONKULLANIM,CASE WHEN ST.IZLEME=3  THEN COUNT(SI.ID)  ELSE S' +
        'DURUM.KALAN END AS KALAN '
      #9'FROM SIPARIS S'
      #9'INNER JOIN SIPARISDETAY SD ON S.ID=SD.SIPARISID'
      #9'INNER JOIN STOKLAR ST ON ST.ID=SD.URUNID'
      #9'LEFT OUTER JOIN LOKASYON L ON L.ID=ST.LOKASYONID'
      
        #9'LEFT OUTER JOIN STOKID SI ON SI.STOKID=ST.ID AND ISNULL(CIKFATB' +
        'ASID,0)=0'
      #9'LEFT OUTER JOIN STOKDURUM SDURUM ON SDURUM.STOKID = ST.ID  '
      
        #9'AND KALAN = (SELECT TOP 1 KALAN FROM STOKDURUM WHERE STOKID = S' +
        'T.ID ORDER BY SKT ASC)'
      #9#9'WHERE S.ID=:SIPARISID'
      
        #9'GROUP BY S.ID,SD.ID,ST.ID,ST.STOKADI,L.ACIKLAMA  ,SI.SONKULLANI' +
        'M,CASE WHEN ST.IZLEME=3  THEN 0 ELSE SDURUM.KALAN END,'
      #9#9'ST.IZLEME,SDURUM.KALAN')
    Left = 624
    Top = 16
    object TabLokasyonSIPARISID: TAutoIncField
      FieldName = 'SIPARISID'
      ReadOnly = True
    end
    object TabLokasyonSIPARISDETAYID: TAutoIncField
      FieldName = 'SIPARISDETAYID'
      ReadOnly = True
    end
    object TabLokasyonSTOKID: TAutoIncField
      FieldName = 'STOKID'
      ReadOnly = True
    end
    object TabLokasyonSTOKADI: TWideStringField
      FieldName = 'STOKADI'
      Size = 100
    end
    object TabLokasyonLOKASYON: TWideStringField
      FieldName = 'LOKASYON'
      ReadOnly = True
      Size = 100
    end
    object TabLokasyonSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object TabLokasyonKALAN: TFloatField
      FieldName = 'KALAN'
      ReadOnly = True
    end
  end
  object DtsLokasyon: TDataSource
    DataSet = TabLokasyon
    Left = 824
    Top = 56
  end
end
