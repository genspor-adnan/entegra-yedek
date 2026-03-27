object SiparisMalSatisDlg: TSiparisMalSatisDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Sipari'#351'ler'
  ClientHeight = 501
  ClientWidth = 1051
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
    Width = 1051
    Height = 41
    Align = alTop
    TabOrder = 0
    Visible = False
  end
  object Panel2: TPanel
    Left = 0
    Top = 460
    Width = 1051
    Height = 41
    Align = alBottom
    TabOrder = 1
    Visible = False
  end
  object Panel3: TPanel
    Left = 1010
    Top = 41
    Width = 41
    Height = 419
    Align = alRight
    TabOrder = 2
    Visible = False
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 41
    Width = 1010
    Height = 419
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BevelWidth = 2
    BorderStyle = cxcbsNone
    TabOrder = 3
    LookAndFeel.Kind = lfUltraFlat
    object cxGrid1DBCardView1: TcxGridDBCardView
      NavigatorButtons.ConfirmDelete = False
      FilterBox.CustomizeDialog = False
      FilterBox.Visible = fvNever
      OnCellDblClick = cxGrid1DBCardView1CellDblClick
      DataController.DataSource = DtsSiparis
      DataController.KeyFieldNames = 'SIPARISID'
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      Filtering.MRUItemsList = False
      Filtering.RowMRUItemsList = False
      OptionsCustomize.CardSizing = False
      OptionsCustomize.RowExpanding = False
      OptionsCustomize.RowFiltering = False
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.InvertSelect = False
      OptionsSelection.UnselectFocusedRecordOnExit = False
      OptionsView.CellEndEllipsis = True
      OptionsView.FocusRect = False
      OptionsView.CardBorderWidth = 5
      OptionsView.CardIndent = 10
      OptionsView.CardWidth = 300
      OptionsView.CategorySeparatorWidth = 3
      OptionsView.CellAutoHeight = True
      OptionsView.CellTextMaxLineCount = 500
      OptionsView.EmptyRows = False
      OptionsView.LayerSeparatorWidth = 1
      OptionsView.SeparatorWidth = 3
      Styles.StyleSheet = cxGridCardViewStyleSheet1
      object cxGrid1DBCardView1TARIH: TcxGridDBCardViewRow
        DataBinding.FieldName = 'TARIH'
        Position.BeginsLayer = True
        Styles.Content = cxStyle17
        Styles.Caption = cxStyle16
      end
      object cxGrid1DBCardView1BELGENO: TcxGridDBCardViewRow
        DataBinding.FieldName = 'BELGENO'
        Position.BeginsLayer = True
        Styles.Content = cxStyle17
        Styles.Caption = cxStyle16
      end
      object cxGrid1DBCardView1FIRMA: TcxGridDBCardViewRow
        DataBinding.FieldName = 'FIRMA'
        Position.BeginsLayer = True
        Styles.Content = cxStyle17
        Styles.Caption = cxStyle16
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBCardView1
    end
  end
  object DtsSiparis: TDataSource
    DataSet = TabSiparis
    Left = 968
    Top = 72
  end
  object TabSiparis: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      
        'SELECT SB.ID AS SIPARISID,SB.TARIH,SB.REHBERID,SB.SIPARISNO AS B' +
        'ELGENO,R.FIRMA,'
      'RI.ANAHTAR AS BELGETIPI,SB.TUR,CIKISDEPO AS GIRISDEPO , '
      
        '(SELECT SUM(ADET) FROM SIPARISDETAY WHERE SIPARISID=SB.ID ) AS A' +
        'DET'
      ' FROM  SIPARIS SB'
      '     INNER JOIN REHBER R ON R.ID = SB.REHBERID'
      '    INNER JOIN GENINI RI ON RI.BOLUM =-1005 AND RI.DEGER=SB.TUR'
      '   WHERE (SB.TUR = 19) AND ISNULL(ACIK_KAPALI,0) = 0'
      'order by SB.ID')
    Left = 968
    Top = 8
    object TabSiparisTARIH: TDateTimeField
      FieldName = 'TARIH'
    end
    object TabSiparisBELGENO: TWideStringField
      FieldName = 'BELGENO'
      Size = 10
    end
    object TabSiparisFIRMA: TWideStringField
      FieldName = 'FIRMA'
      Size = 120
    end
    object TabSiparisBELGETIPI: TWideStringField
      FieldName = 'BELGETIPI'
      Size = 40
    end
    object TabSiparisTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabSiparisGIRISDEPO: TSmallintField
      FieldName = 'GIRISDEPO'
    end
    object TabSiparisREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabSiparisSIPARISID: TAutoIncField
      FieldName = 'SIPARISID'
      ReadOnly = True
    end
    object TabSiparisADET: TFloatField
      FieldName = 'ADET'
      ReadOnly = True
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 872
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor]
      Color = clWhite
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor]
      Color = 33023
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor]
      Color = 12615680
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor]
      Color = 4227200
    end
    object cxStyle6: TcxStyle
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor]
      Color = clYellow
    end
    object cxStyle8: TcxStyle
    end
    object cxStyle9: TcxStyle
    end
    object cxStyle10: TcxStyle
    end
    object cxStyle11: TcxStyle
    end
    object cxStyle12: TcxStyle
    end
    object cxStyle13: TcxStyle
    end
    object cxStyle14: TcxStyle
    end
    object cxStyle15: TcxStyle
      AssignedValues = [svBitmap, svColor]
      Color = 33023
    end
    object cxStyle16: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clSilver
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      TextColor = clBlack
    end
    object cxStyle17: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
    end
    object cxStyle18: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clRed
    end
    object cxStyle19: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
    end
    object cxStyle20: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Verdana'
      Font.Style = []
    end
    object cxGridCardViewStyleSheet1: TcxGridCardViewStyleSheet
      Styles.Background = cxStyle2
      Styles.Content = cxStyle7
      Styles.ContentEven = cxStyle8
      Styles.ContentOdd = cxStyle9
      Styles.FilterBox = cxStyle10
      Styles.Inactive = cxStyle11
      Styles.IncSearch = cxStyle12
      Styles.Selection = cxStyle15
      Styles.CaptionRow = cxStyle3
      Styles.CardBorder = cxStyle4
      Styles.CategoryRow = cxStyle5
      Styles.CategorySeparator = cxStyle6
      Styles.LayerSeparator = cxStyle13
      Styles.RowCaption = cxStyle14
      BuiltIn = True
    end
  end
  object SiparisListeleTimer: TTimer
    Interval = 100000
    OnTimer = SiparisListeleTimerTimer
    Left = 968
    Top = 128
  end
end
