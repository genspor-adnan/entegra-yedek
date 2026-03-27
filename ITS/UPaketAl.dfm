object PaketAlDlg: TPaketAlDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Paket Al'
  ClientHeight = 565
  ClientWidth = 1063
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1063
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object ToolBar2: TToolBar
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 1057
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 92
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
      Images = Tablo.PngImageList3
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object BtnGuncelle: TToolButton
        Left = 0
        Top = 0
        Caption = 'Paket Getir'
        ImageIndex = 17
        OnClick = BtnGuncelleClick
      end
      object BtnXmlAl: TToolButton
        Left = 92
        Top = 0
        Caption = 'XML Al'
        ImageIndex = 19
        OnClick = BtnXmlAlClick
      end
    end
  end
  object Panel2: TPanel
    Left = 217
    Top = 35
    Width = 846
    Height = 497
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object GridAlinanPaketler: TcxGrid
      Left = 0
      Top = 0
      Width = 846
      Height = 65
      Align = alTop
      TabOrder = 0
      object TvAlinanPaketler: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsAlinanPaketler
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            FieldName = 'SIRANO'
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.AlwaysShowEditor = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.FooterAutoHeight = True
        OptionsView.FooterMultiSummaries = True
        OptionsView.GroupByBox = False
        object TvAlinanPaketlerKAYNAKGLN: TcxGridDBColumn
          Caption = 'G'#246'nderen Firma'
          DataBinding.FieldName = 'KAYNAKGLN'
        end
        object TvAlinanPaketlerHEDEFGLN: TcxGridDBColumn
          Caption = 'Alan Firma'
          DataBinding.FieldName = 'HEDEFGLN'
        end
        object TvAlinanPaketlerTRANSFERTIPI: TcxGridDBColumn
          Caption = 'Tip'
          DataBinding.FieldName = 'TRANSFERTIPI'
        end
        object TvAlinanPaketlerSEVKNEREYE: TcxGridDBColumn
          Caption = #350'ube'
          DataBinding.FieldName = 'SEVKNEREYE'
        end
        object TvAlinanPaketlerBELGENUMARASI: TcxGridDBColumn
          Caption = 'Belge Numaras'#305
          DataBinding.FieldName = 'BELGENUMARASI'
        end
        object TvAlinanPaketlerBELGETARIHI: TcxGridDBColumn
          Caption = 'Belge Tarihi'
          DataBinding.FieldName = 'BELGETARIHI'
        end
        object TvAlinanPaketlerTRANSFERNOT: TcxGridDBColumn
          Caption = 'Not'
          DataBinding.FieldName = 'TRANSFERNOT'
        end
        object TvAlinanPaketlerVERSIYON: TcxGridDBColumn
          Caption = 'Versiyon'
          DataBinding.FieldName = 'VERSIYON'
        end
        object vAlinanPaketlerColumn1: TcxGridDBColumn
          Caption = 'Adet'
          DataBinding.FieldName = 'ADET'
        end
      end
      object GlAlinanPaketler: TcxGridLevel
        GridView = TvAlinanPaketler
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 65
      Width = 225
      Height = 432
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object TreeListTasimaBirimleri: TcxDBTreeList
        Left = 0
        Top = 0
        Width = 225
        Height = 432
        Hint = ''
        Align = alClient
        Bands = <
          item
          end>
        DataController.DataSource = DtsAlinanTasimaBirimleri
        DataController.ParentField = 'USTID'
        DataController.KeyField = 'ID'
        Navigator.Buttons.CustomButtons = <>
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRect = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.Indicator = True
        RootValue = -1
        TabOrder = 0
        OnClick = TreeListTasimaBirimleriClick
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
          DataBinding.FieldName = 'TIP'
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
          DataBinding.FieldName = 'ETIKET'
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
    object GridAlinanUrun: TcxGrid
      Left = 225
      Top = 65
      Width = 621
      Height = 432
      Align = alClient
      TabOrder = 2
      object TvAlinanUrun: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsAlinanUrun
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <
          item
            Kind = skCount
            FieldName = 'ID'
            Column = TvAlinanUrunGTIN
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.AlwaysShowEditor = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.Footer = True
        OptionsView.FooterAutoHeight = True
        OptionsView.FooterMultiSummaries = True
        OptionsView.GroupByBox = False
        object TvAlinanUrunGTIN: TcxGridDBColumn
          Caption = 'Gtin'
          DataBinding.FieldName = 'GTIN'
        end
        object TvAlinanUrunLOTNUMARASI: TcxGridDBColumn
          Caption = 'Lot Numaras'#305
          DataBinding.FieldName = 'LOTNUMARASI'
        end
        object TvAlinanUrunSIRANO: TcxGridDBColumn
          Caption = 'SiraNo'
          DataBinding.FieldName = 'SIRANO'
        end
        object TvAlinanUrunURETIMTARIHI: TcxGridDBColumn
          Caption = #220'retim Tarihi'
          DataBinding.FieldName = 'URETIMTARIHI'
        end
        object TvAlinanUrunSONKULLANIMTARIHI: TcxGridDBColumn
          Caption = 'Son Kullanma Tarihi'
          DataBinding.FieldName = 'SONKULLANIMTARIHI'
        end
        object TvAlinanUrunPOSAYISI: TcxGridDBColumn
          Caption = 'Po Say'#305's'#305
          DataBinding.FieldName = 'POSAYISI'
        end
      end
      object GlAlinanUrun: TcxGridLevel
        GridView = TvAlinanUrun
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 35
    Width = 217
    Height = 497
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
    object GridPaketler: TcxGrid
      Left = 0
      Top = 0
      Width = 217
      Height = 497
      Align = alClient
      TabOrder = 0
      object TvPaketler: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        OnCellClick = TvPaketlerCellClick
        DataController.DataModeController.SmartRefresh = True
        DataController.DataSource = DtsPaketler
        DataController.KeyFieldNames = 'ID'
        DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.Appending = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Inserting = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object TvPaketlerPAKETGONDERENFIRMA: TcxGridDBColumn
          Caption = 'Firma'
          DataBinding.FieldName = 'PAKETGONDERENFIRMA'
          Options.Editing = False
          Width = 121
        end
        object TvPaketlerTRANSFERID: TcxGridDBColumn
          Caption = 'Transfer No'
          DataBinding.FieldName = 'TRANSFERID'
          Options.Editing = False
          Width = 77
        end
        object TvPaketlerTRANSFERDATE: TcxGridDBColumn
          DataBinding.FieldName = 'TRANSFERDATE'
          Visible = False
        end
        object TvPaketlerALIMTARIH: TcxGridDBColumn
          DataBinding.FieldName = 'ALIMTARIH'
          Visible = False
        end
        object TvPaketlerDURUM: TcxGridDBColumn
          Caption = 'D'
          DataBinding.FieldName = 'DURUM'
          MinWidth = 10
          Width = 17
        end
        object TvPaketlerID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
      end
      object GlPaketler: TcxGridLevel
        GridView = TvPaketler
      end
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 532
    Width = 1063
    Height = 33
    Align = alBottom
    TabOrder = 3
  end
  object TabAlinanPaketler: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    AfterScroll = TabAlinanPaketlerAfterScroll
    Parameters = <
      item
        Name = 'TRANSFERID'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT * , (SELECT COUNT(U.ID) FROM ITS_PTS_GELEN_URUN U WHERE U' +
        '.PTS_GELEN_PAKET_ID =P.ID ) AS ADET'
      ''
      'FROM  ITS_PTS_GELEN_PAKET P'
      ''
      'WHERE TRANSFERID = :TRANSFERID')
    Left = 605
    Top = 59
    object TabAlinanPaketlerID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabAlinanPaketlerKAYNAKGLN: TStringField
      FieldName = 'KAYNAKGLN'
    end
    object TabAlinanPaketlerHEDEFGLN: TStringField
      FieldName = 'HEDEFGLN'
    end
    object TabAlinanPaketlerTRANSFERTIPI: TStringField
      FieldName = 'TRANSFERTIPI'
    end
    object TabAlinanPaketlerSEVKNEREYE: TStringField
      FieldName = 'SEVKNEREYE'
    end
    object TabAlinanPaketlerBELGENUMARASI: TStringField
      FieldName = 'BELGENUMARASI'
    end
    object TabAlinanPaketlerBELGETARIHI: TStringField
      FieldName = 'BELGETARIHI'
    end
    object TabAlinanPaketlerTRANSFERNOT: TStringField
      FieldName = 'TRANSFERNOT'
    end
    object TabAlinanPaketlerVERSIYON: TStringField
      FieldName = 'VERSIYON'
    end
    object TabAlinanPaketlerADET: TIntegerField
      FieldName = 'ADET'
      ReadOnly = True
    end
  end
  object DtsAlinanPaketler: TDataSource
    DataSet = TabAlinanPaketler
    Left = 716
    Top = 58
  end
  object TabAlinanTasimabirimleri: TADOQuery
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
      
        'SELECT * FROM ITS_PTS_GELEN_TASIMA_BIRIMI  WHERE  ITS_PTS_PAKET_' +
        'ID = :PAKETID')
    Left = 693
    Top = 115
    object TabAlinanTasimabirimleriID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabAlinanTasimabirimleriUSTID: TIntegerField
      FieldName = 'USTID'
    end
    object TabAlinanTasimabirimleriETIKET: TStringField
      FieldName = 'ETIKET'
    end
    object TabAlinanTasimabirimleriTIP: TStringField
      FieldName = 'TIP'
    end
    object TabAlinanTasimabirimleriADET: TIntegerField
      FieldName = 'ADET'
    end
    object TabAlinanTasimabirimleriITS_PTS_PAKET_ID: TIntegerField
      FieldName = 'ITS_PTS_PAKET_ID'
    end
  end
  object DtsAlinanTasimaBirimleri: TDataSource
    DataSet = TabAlinanTasimabirimleri
    Left = 780
    Top = 106
  end
  object TabAlinanUrun: TADOQuery
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
      end
      item
        Name = 'TASIMABIRIMID'
        Attributes = [paSigned, paNullable]
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      
        'SELECT * FROM ITS_PTS_GELEN_URUN  WHERE  PTS_GELEN_PAKET_ID=:PAK' +
        'ETID AND PTS_GELEN_TASIMA_BIRIMI_ID =:TASIMABIRIMID')
    Left = 661
    Top = 171
    object TabAlinanUrunID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabAlinanUrunGTIN: TStringField
      FieldName = 'GTIN'
    end
    object TabAlinanUrunLOTNUMARASI: TStringField
      FieldName = 'LOTNUMARASI'
    end
    object TabAlinanUrunURETIMTARIHI: TStringField
      FieldName = 'URETIMTARIHI'
    end
    object TabAlinanUrunSONKULLANIMTARIHI: TStringField
      FieldName = 'SONKULLANIMTARIHI'
    end
    object TabAlinanUrunPOSAYISI: TStringField
      FieldName = 'POSAYISI'
    end
    object TabAlinanUrunSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabAlinanUrunPTS_GELEN_TASIMA_BIRIMI_ID: TIntegerField
      FieldName = 'PTS_GELEN_TASIMA_BIRIMI_ID'
    end
    object TabAlinanUrunPTS_GELEN_PAKET_ID: TIntegerField
      FieldName = 'PTS_GELEN_PAKET_ID'
    end
  end
  object DtsAlinanUrun: TDataSource
    DataSet = TabAlinanUrun
    Left = 764
    Top = 162
  end
  object DtsPaketler: TDataSource
    DataSet = TabPaketler
    Left = 136
    Top = 216
  end
  object TabPaketler: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT IP.HEDEFGLN AS PAKETGONDERENGLN'
      
        ',(select TOP 1 ISNULL(R.FIRMA,IP.HEDEFGLN)  from REHBERBILGI RB ' +
        'INNER JOIN REHBER R ON R.ID=RB.YER_ID where SIRA = 180 AND BILGI' +
        ' =IP.HEDEFGLN )'
      'AS PAKETGONDERENFIRMA'
      ',IP.*'
      'FROM ITS_BILDIRILMIS_PAKETLER IP'
      
        'INNER JOIN REHBERBILGI RB ON RB.SIRA=180 AND RB.BILGI=IP.KAYNAKG' +
        'LN'
      'INNER JOIN REHBER R ON R.ID=RB.YER_ID AND R.ID=-1'
      'ORDER BY TRANSFERDATE DESC')
    Left = 80
    Top = 200
    object TabAlinanPaketlerPAKETGONDERENGLN: TStringField
      FieldName = 'PAKETGONDERENGLN'
      Size = 50
    end
    object TabAlinanPaketlerPAKETGONDERENFIRMA: TWideStringField
      FieldName = 'PAKETGONDERENFIRMA'
      ReadOnly = True
      Size = 120
    end
    object AutoIncField1: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object StringField1: TStringField
      FieldName = 'KAYNAKGLN'
      Size = 50
    end
    object StringField2: TStringField
      FieldName = 'HEDEFGLN'
      Size = 50
    end
    object TabAlinanPaketlerTRANSFERID: TIntegerField
      FieldName = 'TRANSFERID'
    end
    object TabAlinanPaketlerTRANSFERDATE: TDateTimeField
      FieldName = 'TRANSFERDATE'
    end
    object TabAlinanPaketlerALIMTARIH: TDateTimeField
      FieldName = 'ALIMTARIH'
    end
    object TabAlinanPaketlerDURUM: TBooleanField
      FieldName = 'DURUM'
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 328
    Top = 160
  end
end
