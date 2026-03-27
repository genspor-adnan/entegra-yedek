object RehberBilgiDuzenleDlg: TRehberBilgiDuzenleDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Bilgi d'#252'zenleme ekran'#305
  ClientHeight = 482
  ClientWidth = 622
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 622
    Height = 24
    Margins.Bottom = 0
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
    Images = Tablo.PNGImageList2
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object ToolButton3: TToolButton
      Left = 0
      Top = 0
      Width = 436
      Caption = 'ToolButton3'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 436
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 2
      OnClick = ToolButton1Click
    end
    object ToolButton2: TToolButton
      Left = 497
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 3
      OnClick = ToolButton2Click
    end
  end
  object GridKurIlet: TcxGrid
    Left = 0
    Top = 24
    Width = 622
    Height = 458
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    object GridDetayView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      OnCellClick = GridDetayViewCellClick
      OnEditChanged = GridDetayViewEditChanged
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsDetay
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.DeletingConfirmation = False
      OptionsView.GroupByBox = False
      Styles.Content = AnaForm.cxStyle1
      object cxGridDBColumn3: TcxGridDBColumn
        Caption = 'Etiketi'
        DataBinding.FieldName = 'ETIKET'
        MinWidth = 150
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
        Width = 150
      end
      object cxGridDBColumn4: TcxGridDBColumn
        Caption = 'Bilgisi'
        DataBinding.FieldName = 'BILGI'
        PropertiesClassName = 'TcxTextEditProperties'
        OnGetPropertiesForEdit = cxGridDBColumn4GetPropertiesForEdit
        MinWidth = 400
        Options.Filtering = False
        Options.FilteringFilteredItemsList = False
        Options.FilteringMRUItemsList = False
        Options.FilteringPopup = False
        Options.FilteringPopupMultiSelect = False
        Options.IgnoreTimeForFiltering = False
        Options.IncSearch = False
        Options.GroupFooters = False
        Options.Grouping = False
        Options.HorzSizing = False
        Options.Moving = False
        Styles.Content = Tablo.cxStyle1
        Width = 400
      end
      object GridDetayViewColumn1: TcxGridDBColumn
        DataBinding.FieldName = 'ORJINAL'
        Visible = False
        MinWidth = 64
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
        Options.ShowCaption = False
      end
      object GridDetayViewColumnsec: TcxGridDBColumn
        Caption = 'Zorunlu'
        DataBinding.FieldName = 'ZORUNLU'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Visible = False
      end
    end
    object cxGridDetay: TcxGridLevel
      GridView = GridDetayView
    end
  end
  object SQLDetay: TcxMemo
    Left = 21
    Top = 98
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
      #9'[ETIKET] [nvarchar](50) NULL,'
      #9'[BILGI] [nvarchar](100) NULL,'
      #9'[ORJINAL] [nvarchar](100) NULL,'
      #9'[GIRIS] [nvarchar](50) NULL,'
      #9'[KAYNAK] [nvarchar](255) NULL,'
      '                [ZORUNLU] [bit] NULL'
      ')'
      'INSERT INTO #DETAY_:SPID_'
      'select '
      'RB.SIRA,RB.ETIKET,RB.BILGI,ORJINAL=RB.BILGI,RA.GIRIS,'
      'RA.KAYNAK,RA.ZORUNLU  '
      'from REHBERBILGI RB '
      
        'INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA AND RA.YERI=88 --RB.' +
        'YERI'
      'where RB.YERI= @yeri and YER_ID= @yerid '
      'and isnull(RA.BOLUM,'#39#39')=@bolum '
      ''
      'union all'
      ''
      
        'select  SIRA, ETIKET, BILGI='#39#39', ORJINAL='#39#39' ,GIRIS,KAYNAK,ZORUNLU' +
        '  '
      ' from REHBERAYAR  '
      'where  YERI=88--@yeri '
      'and isnull(BOLUM,'#39#39')=@Bolum  '
      'and ETIKET not in (select ETIKET from REHBERBILGI where  '
      'YERI=@yeri  and YER_ID= @yerid )'
      ''
      'order by 1'
      ''
      'select * from #DETAY_:SPID_'
      'order by SIRA')
    Properties.WordWrap = False
    TabOrder = 2
    Visible = False
    Height = 127
    Width = 387
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 495
    Top = 82
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 499
    Top = 129
  end
end

