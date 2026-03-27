object BildirilmisPaketlerDlg: TBildirilmisPaketlerDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Bildirilmi'#351' Paketler'
  ClientHeight = 500
  ClientWidth = 984
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
    Width = 984
    Height = 41
    Align = alTop
    Color = clSilver
    ParentBackground = False
    TabOrder = 0
    object ToolBar2: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 976
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 103
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
      HotImages = Tablo.PNGImageList1
      HotTrackColor = 65408
      Images = Tablo.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object BtnGuncelle: TToolButton
        Left = 0
        Top = 0
        Caption = 'G'#252'ncelle'
        ImageIndex = 12
        OnClick = BtnGuncelleClick
      end
      object BtnPaketAl: TToolButton
        Left = 103
        Top = 0
        Caption = '    Paket Al      '
        ImageIndex = 17
        OnClick = BtnPaketAlClick
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 459
    Width = 984
    Height = 41
    Align = alBottom
    TabOrder = 1
  end
  object Panel7: TPanel
    Left = 0
    Top = 41
    Width = 201
    Height = 418
    Align = alLeft
    TabOrder = 2
    object BtnGonderilenPaketler: TJvNavPanelButton
      Left = 1
      Top = 1
      Width = 199
      Height = 52
      Align = alTop
      Caption = 'G'#246'nderilen Paketler'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 7
      Images = Tablo.PngMenu
      OnClick = BtnGonderilenPaketlerClick
      ExplicitLeft = -4
      ExplicitTop = -5
      ExplicitWidth = 247
    end
    object BtnAlınanPaketler: TJvNavPanelButton
      Tag = 1
      Left = 1
      Top = 53
      Width = 199
      Height = 52
      Align = alTop
      Caption = 'Al'#305'nan Paketler'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 1
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = 15395562
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 11633796
      Colors.ButtonHotColorTo = 9530476
      Colors.ButtonSelectedColorFrom = 11633796
      Colors.ButtonSelectedColorTo = 9530476
      ParentStyleManager = False
      ImageIndex = 10
      Images = Tablo.PngMenu
      OnClick = BtnAlınanPaketlerClick
      ExplicitTop = 59
    end
  end
  object Panel3: TPanel
    Left = 201
    Top = 41
    Width = 783
    Height = 418
    Align = alClient
    Caption = 'Panel3'
    TabOrder = 3
    object PgPaketler: TcxPageControl
      Left = 1
      Top = 9
      Width = 781
      Height = 408
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = TsAlınanPaketler
      Properties.CustomButtons.Buttons = <>
      ClientRectBottom = 404
      ClientRectLeft = 4
      ClientRectRight = 777
      ClientRectTop = 24
      object TsGonderilmisPaketler: TcxTabSheet
        Caption = 'TsGonderilmisPaketler'
        ImageIndex = 0
        object GridBildirilmisPaketler: TcxGrid
          Left = 0
          Top = 0
          Width = 773
          Height = 380
          Align = alClient
          TabOrder = 0
          object TvBildirilmisPaketler: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsBildirilmisPaketler
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object TvBildirilmisPaketlerPAKETGONDERILENFIRMA: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'PAKETGONDERILENFIRMA'
              Width = 319
            end
            object TvBildirilmisPaketlerTRANSFERID: TcxGridDBColumn
              Caption = 'Transfer Id'
              DataBinding.FieldName = 'TRANSFERID'
              Width = 90
            end
            object TvBildirilmisPaketlerTRANSFERDATE: TcxGridDBColumn
              Caption = 'Transfer Tarih'
              DataBinding.FieldName = 'TRANSFERDATE'
              Width = 162
            end
            object TvBildirilmisPaketlerALIMTARIH: TcxGridDBColumn
              Caption = 'Al'#305'm Tarih'
              DataBinding.FieldName = 'ALIMTARIH'
              Width = 162
            end
            object TvBildirilmisPaketlerDURUM: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              Width = 48
            end
            object TvBildirilmisPaketlerID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              Visible = False
            end
          end
          object GlBildirilmisPaketler: TcxGridLevel
            GridView = TvBildirilmisPaketler
          end
        end
      end
      object TsAlınanPaketler: TcxTabSheet
        Caption = 'TsAl'#305'nanPaketler'
        ImageIndex = 1
        object cxGrid1: TcxGrid
          Left = 0
          Top = 0
          Width = 773
          Height = 380
          Align = alClient
          TabOrder = 0
          object cxGridDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataModeController.SmartRefresh = True
            DataController.DataSource = DtsAlinanPaketler
            DataController.KeyFieldNames = 'ID'
            DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object cxGridDBTableView1PAKETGONDERENFIRMA: TcxGridDBColumn
              Caption = 'Firma'
              DataBinding.FieldName = 'PAKETGONDERENFIRMA'
              Width = 326
            end
            object cxGridDBTableView1TRANSFERID: TcxGridDBColumn
              Caption = 'Transfer Id'
              DataBinding.FieldName = 'TRANSFERID'
              Width = 89
            end
            object cxGridDBTableView1TRANSFERDATE: TcxGridDBColumn
              Caption = 'Transfer Tarih'
              DataBinding.FieldName = 'TRANSFERDATE'
              Width = 159
            end
            object cxGridDBTableView1ALIMTARIH: TcxGridDBColumn
              Caption = 'Al'#305'm Tarih'
              DataBinding.FieldName = 'ALIMTARIH'
              Width = 160
            end
            object cxGridDBTableView1DURUM: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              Width = 47
            end
            object cxGridDBTableView1ID: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              Visible = False
            end
          end
          object cxGridLevel1: TcxGridLevel
            GridView = cxGridDBTableView1
          end
        end
      end
    end
    object JvNavPanelHeader1: TJvNavPanelHeader
      Left = 1
      Top = 1
      Width = 781
      Height = 8
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ColorFrom = clBtnFace
      ColorTo = clSilver
      ImageIndex = 0
    end
  end
  object TabBildirilmisPaketler: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'SELECT DISTINCT IP.KAYNAKGLN AS PAKETGONDERILENGLN'
      
        ',(select TOP 1 ISNULL(R.FIRMA,IP.KAYNAKGLN)  from REHBERBILGI RB' +
        ' INNER JOIN REHBER R ON R.ID=RB.YER_ID where SIRA = 180 AND BILG' +
        'I =IP.KAYNAKGLN )'
      'AS PAKETGONDERILENFIRMA'
      ',IP.*'
      'FROM ITS_BILDIRILMIS_PAKETLER IP'
      
        'INNER JOIN REHBERBILGI RB ON RB.SIRA=180 AND RB.BILGI=IP.KAYNAKG' +
        'LN'
      'INNER JOIN REHBER R ON R.ID=RB.YER_ID AND R.ID<>-1'
      'ORDER BY TRANSFERDATE DESC')
    Left = 648
    Top = 120
    object TabBildirilmisPaketlerPAKETGONDERILENGLN: TStringField
      FieldName = 'PAKETGONDERILENGLN'
      Size = 50
    end
    object TabBildirilmisPaketlerPAKETGONDERILENFIRMA: TWideStringField
      FieldName = 'PAKETGONDERILENFIRMA'
      ReadOnly = True
      Size = 120
    end
    object TabBildirilmisPaketlerID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabBildirilmisPaketlerKAYNAKGLN: TStringField
      FieldName = 'KAYNAKGLN'
      Size = 50
    end
    object TabBildirilmisPaketlerHEDEFGLN: TStringField
      FieldName = 'HEDEFGLN'
      Size = 50
    end
    object TabBildirilmisPaketlerTRANSFERID: TIntegerField
      FieldName = 'TRANSFERID'
    end
    object TabBildirilmisPaketlerTRANSFERDATE: TDateTimeField
      FieldName = 'TRANSFERDATE'
    end
    object TabBildirilmisPaketlerALIMTARIH: TDateTimeField
      FieldName = 'ALIMTARIH'
    end
    object TabBildirilmisPaketlerDURUM: TBooleanField
      FieldName = 'DURUM'
    end
  end
  object DtsBildirilmisPaketler: TDataSource
    DataSet = TabBildirilmisPaketler
    Left = 760
    Top = 136
  end
  object TabAlinanPaketler: TADOQuery
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
    Left = 648
    Top = 232
    object TabAlinanPaketlerPAKETGONDERENGLN: TStringField
      FieldName = 'PAKETGONDERENGLN'
      Size = 50
    end
    object TabAlinanPaketlerPAKETGONDERENFIRMA: TWideStringField
      FieldName = 'PAKETGONDERENFIRMA'
      ReadOnly = True
      Size = 120
    end
    object TabAlinanPaketlerID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabAlinanPaketlerKAYNAKGLN: TStringField
      FieldName = 'KAYNAKGLN'
      Size = 50
    end
    object TabAlinanPaketlerHEDEFGLN: TStringField
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
  object DtsAlinanPaketler: TDataSource
    DataSet = TabAlinanPaketler
    Left = 752
    Top = 232
  end
end
