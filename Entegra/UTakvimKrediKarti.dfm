object TakvimKrediKartiDlg: TTakvimKrediKartiDlg
  Left = 0
  Top = 0
  Caption = 'TakvimKrediKartiDlg'
  ClientHeight = 421
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 189
    Width = 414
    Height = 232
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 380
    object cxGrid1DBTableView1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = DtsPlanKrediKarti
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.CellSelect = False
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1ODENMIS: TcxGridDBColumn
        DataBinding.FieldName = 'ODENMIS'
        Width = 53
      end
      object cxGrid1DBTableView1TAKSITNO: TcxGridDBColumn
        DataBinding.FieldName = 'TAKSITNO'
        Width = 55
      end
      object cxGrid1DBTableView1TARIH: TcxGridDBColumn
        DataBinding.FieldName = 'TARIH'
        Width = 64
      end
      object cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn
        DataBinding.FieldName = 'ACIKLAMA'
        Width = 65
      end
      object cxGrid1DBTableView1TUTAR: TcxGridDBColumn
        DataBinding.FieldName = 'TUTAR'
        Width = 38
      end
      object cxGrid1DBTableView1KUR: TcxGridDBColumn
        DataBinding.FieldName = 'KUR'
        Width = 29
      end
      object cxGrid1DBTableView1EKLEYEN: TcxGridDBColumn
        DataBinding.FieldName = 'EKLEYEN'
        Width = 49
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object cxDBLabel1: TcxDBLabel
    Left = 8
    Top = 75
    DataBinding.DataField = 'ADI'
    DataBinding.DataSource = DtsKrediKarti
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 21
    Width = 140
  end
  object cxDBImage1: TcxDBImage
    Left = 8
    Top = 8
    DataBinding.DataField = 'LOGO'
    DataBinding.DataSource = DtsKrediKarti
    Properties.Stretch = True
    TabOrder = 2
    Height = 61
    Width = 122
  end
  object cxDBLabel3: TcxDBLabel
    Left = 8
    Top = 160
    DataBinding.DataField = 'HAMILI'
    DataBinding.DataSource = DtsKrediKarti
    ParentFont = False
    Properties.Alignment.Horz = taLeftJustify
    Properties.Alignment.Vert = taVCenter
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 20
    Width = 174
    AnchorY = 170
  end
  object cxDBImage2: TcxDBImage
    Left = 250
    Top = 8
    DataBinding.DataField = 'TURLOGO'
    DataBinding.DataSource = DtsKrediKarti
    Properties.Stretch = True
    Style.TransparentBorder = True
    TabOrder = 4
    Height = 61
    Width = 122
  end
  object cxDBLabel4: TcxDBLabel
    Left = 8
    Top = 104
    DataBinding.DataField = 'NOSU'
    DataBinding.DataSource = DtsKrediKarti
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -15
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 20
    Width = 352
  end
  object cxDBLabel5: TcxDBLabel
    Left = 8
    Top = 132
    DataBinding.DataField = 'SKT'
    DataBinding.DataSource = DtsKrediKarti
    ParentFont = False
    Properties.Alignment.Horz = taLeftJustify
    Properties.Alignment.Vert = taVCenter
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 20
    Width = 174
    AnchorY = 142
  end
  object DtsPlanKrediKarti: TDataSource
    DataSet = TabPlanKrediKarti
    Left = 205
    Top = 3
  end
  object TabPlanKrediKarti: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM PLANKREDIKARTI '
      'where KASAID = :PKASAID')
    Left = 135
    Top = 4
  end
  object TabKrediKarti: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT'
      '    KK.*,'
      '    B.LOGO,'
      '    B.BANKAADI,'
      
        '    TURLOGO= CASE WHEN TURU=1 THEN (SELECT BELGE FROM IMAJ WHERE' +
        ' YERI=132 AND BELGEADI='#39'Visa'#39')'
      
        '                  WHEN TURU=2 THEN (SELECT BELGE FROM IMAJ WHERE' +
        ' YERI=132 AND BELGEADI='#39'MasterCard'#39')'
      
        '                  WHEN TURU=3 THEN (SELECT BELGE FROM IMAJ WHERE' +
        ' YERI=132 AND BELGEADI='#39'AmericanEx'#39')'
      
        '                  WHEN TURU=4 THEN (SELECT BELGE FROM IMAJ WHERE' +
        ' YERI=132 AND BELGEADI='#39'DiscoverNet'#39')'
      '             END     '
      'FROM '
      #9'KREDIKARTI KK left outer join'
      #9'BANKAHESAPLAR BH ON '
      #9#9'KK.BANKAHESAPID = BH.ID left outer join '
      #9'BANKASUBELER BS ON '
      #9#9'BH.BANKASUBELERID=BS.ID left outer join'
      #9'BANKALAR B ON '
      #9#9'BS.BANKAKODU=B.BANKAKODU'#9
      ''
      'where KK.ID=:pKASAHESAPID'
      '')
    Left = 133
    Top = 46
  end
  object DtsKrediKarti: TDataSource
    DataSet = TabKrediKarti
    Left = 205
    Top = 46
  end
end

