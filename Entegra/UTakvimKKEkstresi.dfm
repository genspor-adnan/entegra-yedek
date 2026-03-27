object TakvimKKEkstresiDlg: TTakvimKKEkstresiDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Ekstre Bilgileri'
  ClientHeight = 479
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 85
    Width = 379
    Height = 394
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 377
    ExplicitHeight = 331
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DtsDetay
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsSelection.InvertSelect = False
      OptionsSelection.UnselectFocusedRecordOnExit = False
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1TAKSITDURUM: TcxGridDBColumn
        Caption = 'Taksit'
        DataBinding.FieldName = 'TAKSITDURUM'
        Width = 94
      end
      object cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        Width = 187
      end
      object cxGrid1DBTableView1TUTAR: TcxGridDBColumn
        Caption = 'Tutar'
        DataBinding.FieldName = 'TUTAR'
        Width = 66
      end
      object cxGrid1DBTableView1KUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        Width = 27
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object JvDBImage1: TJvDBImage
    Left = 8
    Top = 8
    Width = 123
    Height = 71
    BorderStyle = bsNone
    DataField = 'BANKALOGO'
    DataSource = DtsBanka
    TabOrder = 1
    Transparent = True
  end
  object cxDBLabel1: TcxDBLabel
    Left = 134
    Top = 7
    DataBinding.DataField = 'BANKAADI'
    DataBinding.DataSource = DtsBanka
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 21
    Width = 229
  end
  object cxDBLabel2: TcxDBLabel
    Left = 134
    Top = 24
    DataBinding.DataField = 'KKKODU'
    DataBinding.DataSource = DtsBanka
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 21
    Width = 229
  end
  object cxDBLabel3: TcxDBLabel
    Left = 134
    Top = 41
    DataBinding.DataField = 'KKADI'
    DataBinding.DataSource = DtsBanka
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 21
    Width = 229
  end
  object cxDBLabel4: TcxDBLabel
    Left = 134
    Top = 59
    DataBinding.DataField = 'KKTANIMLIKISI'
    DataBinding.DataSource = DtsBanka
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Trebuchet MS'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    Transparent = True
    Height = 21
    Width = 229
  end
  object TabBanka: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select '
      '    BANKAADI=B.BANKAADI,'
      '    BANKALOGO=B.LOGO,'
      #9'KKADI=kk.ADI,'
      #9'KKKODU=kk.KODU,'
      #9'KKHAMILI=kk.HAMILI,'
      #9'KKTANIMLIKISI=kk.TANIMLI_KISI'
      'from '
      ''
      ''
      #9'KREDIKARTI kk  left outer join'
      #9'BANKAHESAPLAR bh on'
      #9'  bh.ID=kk.BANKAHESAPID left outer join'
      #9'BANKASUBELER bs on'
      #9'  bh.BANKASUBELERID=bs.ID left outer join'
      #9'BANKALAR b on'
      #9'  b.BANKAKODU=bs.BANKAKODU'
      'WHERE'
      '                  KK.ID=:pKKID')
    Left = 64
    Top = 201
  end
  object DtsBanka: TDataSource
    DataSet = TabBanka
    Left = 63
    Top = 245
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select '
      
        'TAKSITDURUM=case when TAKSITSAY = 1 then '#39'Tek '#199'ekim'#39' else '#39'Taksi' +
        't: '#39'+CONVERT(varchar(3),TAKSITNO)+'#39'/'#39'+CONVERT(varchar(3),TAKSITS' +
        'AY) end,'
      'TUTAR,KUR,ACIKLAMA'
      ''
      ''
      'from PLANKREDIKARTI'
      ''
      'where '
      #9'KKID=:PID and'
      #9'YEAR(TARIH)=:PYIL and'
      #9'MONTH(TARIH)=:PAY')
    Left = 120
    Top = 197
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    Left = 118
    Top = 244
  end
end


