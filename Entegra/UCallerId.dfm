object CallerIdDlg: TCallerIdDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #199'a'#287'r'#305' ve Arama Ekran'#305
  ClientHeight = 523
  ClientWidth = 966
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 966
    Height = 89
    Align = alTop
    BevelOuter = bvNone
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object LabelTarih: TcxLabel
      Left = 13
      Top = 39
      Caption = '20/12/2014'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelSaat: TcxLabel
      Left = 13
      Top = 59
      Caption = '16:53'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      Transparent = True
    end
    object LabelTelAd: TcxLabel
      Left = 165
      Top = 6
      Caption = 'Yeni'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -19
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      Transparent = True
    end
    object cxDBImage1: TcxDBImage
      Left = 853
      Top = 0
      Align = alRight
      TabOrder = 3
      Height = 89
      Width = 113
    end
    object LabelNumara: TcxLabel
      Left = 165
      Top = 40
      Caption = 'Sipari'#351
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -24
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      Transparent = True
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 89
    Width = 966
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Color = clSilver
    ParentBackground = False
    TabOrder = 1
    object JvNavPanelButton1: TJvNavPanelButton
      Left = 289
      Top = 14
      Width = 40
      Height = 35
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Colors.ButtonColorFrom = clSilver
      Colors.ButtonColorTo = clSilver
      Colors.ToolPanelColorFrom = clHighlight
      ImageIndex = 36
      Images = Tablo.cxImageList1
      OnClick = JvNavPanelButton1Click
    end
    object cxLabel3: TcxLabel
      Left = 4
      Top = 10
      Caption = 'Ara'
      ParentFont = False
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = [fsBold]
      Style.TextColor = clNavy
      Style.IsFontAssigned = True
      Transparent = True
    end
    object TextAra: TcxTextEdit
      Left = 41
      Top = 12
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -16
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 1
      OnKeyUp = TextAraKeyUp
      Width = 242
    end
    object DuzenleTus: TcxButton
      Left = 459
      Top = 12
      Width = 98
      Height = 30
      Caption = 'D'#252'zenle'
      OptionsImage.ImageIndex = 18
      OptionsImage.Images = Tablo.imgScheduler
      TabOrder = 2
    end
    object NumaraEkleTus: TcxButton
      Left = 557
      Top = 12
      Width = 103
      Height = 30
      Caption = 'Numaray'#305' Ekle'
      OptionsImage.ImageIndex = 6
      OptionsImage.Images = Tablo.imgScheduler
      TabOrder = 3
      Visible = False
      OnClick = NumaraEkleTusClick
    end
    object YeniKartTus: TcxButton
      Left = 361
      Top = 12
      Width = 98
      Height = 30
      Caption = 'Yeni Kart'
      OptionsImage.ImageIndex = 7
      OptionsImage.Images = Tablo.imgScheduler
      TabOrder = 4
      OnClick = cxButton1Click
    end
    object SecTus: TcxButton
      Left = 713
      Top = 12
      Width = 246
      Height = 30
      Caption = '    Se'#231
      OptionsImage.ImageIndex = 21
      OptionsImage.Images = Tablo.imgScheduler
      TabOrder = 5
      OnClick = SecTusClick
    end
  end
  object gridCari: TcxGrid
    Left = 0
    Top = 137
    Width = 551
    Height = 367
    Align = alLeft
    TabOrder = 2
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    LookAndFeel.SkinName = ''
    object tvCari: TcxGridDBTableView
      OnDblClick = SecTusClick
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsCari
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.UnselectFocusedRecordOnExit = False
      OptionsView.DataRowHeight = 40
      OptionsView.GroupByBox = False
      object tvCariFIRMA: TcxGridDBColumn
        Caption = 'M'#252#351'teri'
        DataBinding.FieldName = 'FIRMA'
        Width = 115
      end
      object tvCariCEP: TcxGridDBColumn
        Caption = 'GSM'
        DataBinding.FieldName = 'CEP'
        Width = 60
      end
      object tvCariISTEL: TcxGridDBColumn
        Caption = #304#351
        DataBinding.FieldName = 'ISTEL'
        Width = 60
      end
      object tvCariEVTEL: TcxGridDBColumn
        Caption = 'Ev'
        DataBinding.FieldName = 'EVTEL'
        Width = 60
      end
      object tvCariNOTLAR: TcxGridDBColumn
        Caption = 'Notlar'
        DataBinding.FieldName = 'NOTLAR'
        Width = 121
      end
    end
    object gridCariLevel1: TcxGridLevel
      GridView = tvCari
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 504
    Width = 966
    Height = 19
    Align = alBottom
    BevelOuter = bvNone
    Color = clSilver
    ParentBackground = False
    TabOrder = 3
  end
  object SQLListe: TcxMemo
    Left = 148
    Top = 207
    Lines.Strings = (
      'select * from (    '
      #9'select'
      '    '#9'R.ID, ILETID=RI.ID,R.FIRMA,'
      '    '#9'CEP=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER '
      
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' '
      'RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=42),'
      
        '    '#9'ISTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R '
      
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' '
      'RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=40),'
      
        '    '#9'EVTEL=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNE' +
        'R '
      
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' '
      'RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=44),'
      '    '#9'ADRES1=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) '
      'INNER '
      
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' '
      'RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=2),'
      '    '#9'ADRES2=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) '
      'INNER '
      
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' '
      'RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=102),'
      '    '#9'ADRES3=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) '
      'INNER '
      
        'JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND' +
        ' '
      'RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=112),'
      '    '#9
      '    '#9'R.NOTLAR,'
      #9#9'LOGO= (SELECT  TOP 1 BELGE FROM IMAJ I WHERE '
      'VARSAYILAN=1 AND YERI=11 AND YER_ID=-1 )'
      '      from'
      
        '      '#9'REHBER R inner join REHBERILETISIM RI on R.ID=RI.REHBERID' +
        ' '
      #9'and R.DURUM = 1 and R.GRUP <> 335'
      ') as Liste    ')
    TabOrder = 4
    Visible = False
    Height = 100
    Width = 387
  end
  object cxSplitter1: TcxSplitter
    Left = 551
    Top = 137
    Width = 8
    Height = 367
    HotZoneClassName = 'TcxMediaPlayer8Style'
    Control = gridCari
  end
  object Panel4: TPanel
    Left = 559
    Top = 137
    Width = 407
    Height = 367
    Align = alClient
    BevelOuter = bvNone
    Color = clSilver
    ParentBackground = False
    TabOrder = 6
    ExplicitLeft = 32
    ExplicitTop = 193
    ExplicitWidth = 966
    ExplicitHeight = 48
    object cxGrid1: TcxGrid
      Left = 0
      Top = 0
      Width = 407
      Height = 337
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      LookAndFeel.SkinName = ''
      ExplicitHeight = 331
      object cxGridDBTableView1: TcxGridDBTableView
        OnDblClick = SecTusClick
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsAdres
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.DataRowHeight = 40
        OptionsView.GroupByBox = False
        object cxGridDBColumn1: TcxGridDBColumn
          Caption = 'Adres '
          DataBinding.FieldName = 'ADRES'
          Width = 317
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = cxGridDBTableView1
      end
    end
    object AdresEkleTus: TcxButton
      Left = 0
      Top = 337
      Width = 407
      Height = 30
      Align = alBottom
      Caption = 'Adres Ekle'
      OptionsImage.ImageIndex = 45
      OptionsImage.Images = Tablo.imgScheduler
      TabOrder = 1
      OnClick = AdresEkleTusClick
      ExplicitLeft = 757
      ExplicitTop = 452
      ExplicitWidth = 103
    end
  end
  object DtsCari: TDataSource
    DataSet = TabCari
    Left = 89
    Top = 318
  end
  object TabCari: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabCariAfterOpen
    AfterScroll = TabCariAfterScroll
    ParamData = <>
    Left = 169
    Top = 318
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 77
    Top = 164
  end
  object DtsAdres: TDataSource
    DataSet = TabAdres
    Left = 705
    Top = 246
  end
  object TabAdres: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabCariAfterOpen
    ParamData = <>
    SQL.Strings = (
      ''
      
        'SELECT  RB.SIRA,RA.VARSAYILAN  ,ADRES=BILGI FROM REHBERBILGI RB ' +
        '(nolock) '
      
        'left JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIR' +
        'A '
      'AND RA.YERI=RB.YERI '
      'WHERE RB.YER_ID=:PILETID  AND RA.VARSAYILAN in (2,102,112)')
    Left = 785
    Top = 246
  end
end
