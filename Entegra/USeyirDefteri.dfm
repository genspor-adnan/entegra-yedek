object SeyirDefteriDlg: TSeyirDefteriDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Seyir Defteri'
  ClientHeight = 533
  ClientWidth = 923
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
  object ToolBar3: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 917
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 63
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
    TabOrder = 0
    Transparent = True
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 841
      Caption = 'ToolButton1'
      ImageIndex = 18
      Style = tbsSeparator
    end
    object btnkapat: TToolButton
      Left = 841
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      OnClick = btnkapatClick
    end
  end
  object PanelUst: TPanel
    Left = 0
    Top = 35
    Width = 923
    Height = 46
    Align = alTop
    TabOrder = 1
    object DateTarihBas: TcxDateEdit
      Left = 4
      Top = 19
      Properties.SaveTime = False
      Properties.OnCloseUp = DateTarihBasPropertiesCloseUp
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBtnText
      TabOrder = 0
      Width = 90
    end
    object cxLabel1: TcxLabel
      Left = 235
      Top = 2
      Caption = 'Kullan'#305'c'#305
      Transparent = True
    end
    object cxLabel2: TcxLabel
      Left = 341
      Top = 2
      Caption = 'Tablo'
      ParentFont = False
      Transparent = True
    end
    object CheckSilme: TcxCheckBox
      Left = 791
      Top = 3
      Caption = 'Silme'
      ParentFont = False
      TabOrder = 3
      Transparent = True
      OnClick = CheckSilmeClick
      Width = 121
    end
    object CheckDegistirme: TcxCheckBox
      Left = 791
      Top = 23
      Caption = 'De'#287'i'#351'tirme'
      ParentFont = False
      TabOrder = 4
      Transparent = True
      OnClick = CheckDegistirmeClick
      Width = 121
    end
    object txtTablo: TcxButtonEdit
      Left = 341
      Top = 19
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = txtTabloPropertiesButtonClick
      TabOrder = 2
      OnKeyUp = txtTabloKeyUp
      Width = 124
    end
    object Kullanici: TcxButtonEdit
      Left = 235
      Top = 19
      Properties.Alignment.Horz = taLeftJustify
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = False
      Properties.OnButtonClick = ComboKabuledenPropertiesButtonClick
      TabOrder = 1
      OnKeyUp = KullaniciKeyUp
      Width = 98
    end
    object txtAlan: TcxButtonEdit
      Left = 511
      Top = 19
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = txtAlanPropertiesButtonClick
      TabOrder = 7
      OnKeyUp = txtTabloKeyUp
      Width = 114
    end
    object cxLabel4: TcxLabel
      Left = 511
      Top = 2
      Caption = 'Alan'
      ParentFont = False
      Transparent = True
    end
    object cxLabel5: TcxLabel
      Left = 631
      Top = 1
      Caption = 'Arama T'#252'r'#252
      ParentFont = False
      Transparent = True
    end
    object ComboAramaTuru: TcxImageComboBox
      Left = 631
      Top = 18
      EditValue = '%%'
      Properties.Items = <
        item
          Description = '=>'
          ImageIndex = 0
          Value = '>='
        end
        item
          Description = '<='
          Value = '<='
        end
        item
          Description = 'Ba'#351'layan'
          Value = '%'
        end
        item
          Description = #304#231'inde Ge'#231'en'
          Value = '%%'
        end>
      Properties.OnEditValueChanged = ComboAramaTuruPropertiesEditValueChanged
      TabOrder = 10
      Width = 121
    end
    object cxLabel3: TcxLabel
      Left = 4
      Top = 2
      Caption = 'Ba'#351'lama'
      Transparent = True
    end
    object cxLabel6: TcxLabel
      Left = 96
      Top = 2
      Caption = 'Biti'#351
      Transparent = True
    end
    object DateTarihBit: TcxDateEdit
      Left = 96
      Top = 19
      Properties.SaveTime = False
      Properties.OnCloseUp = DateTarihBitPropertiesCloseUp
      StyleDisabled.Color = clWhite
      StyleDisabled.TextColor = clBtnText
      TabOrder = 13
      Width = 90
    end
  end
  object DBGrid1: TcxGrid
    Left = 0
    Top = 81
    Width = 537
    Height = 452
    Align = alLeft
    TabOrder = 2
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    object DBGrid1DBTableView1: TcxGridDBTableView
      OnDblClick = DBGrid1DBTableView1DblClick
      Navigator.Buttons.CustomButtons = <>
      OnFocusedRecordChanged = DBGrid1DBTableView1FocusedRecordChanged
      DataController.DataSource = DsTabLog
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsData.Editing = False
      OptionsSelection.CellSelect = False
      OptionsSelection.HideSelection = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.Indicator = True
      object DBGrid1DBTableView1SATIRID: TcxGridDBColumn
        Caption = 'ID'
        DataBinding.FieldName = 'SATIRID'
        HeaderAlignmentHorz = taCenter
        Width = 57
      end
      object DBGrid1DBTableView1TARIH: TcxGridDBColumn
        Caption = 'Tarih'
        DataBinding.FieldName = 'TARIH'
        HeaderAlignmentHorz = taCenter
        Width = 93
      end
      object DBGrid1DBTableView1PCADI: TcxGridDBColumn
        Caption = 'Bilgisayar'
        DataBinding.FieldName = 'PCADI'
        Width = 73
      end
      object DBGrid1DBTableView1FIRMA: TcxGridDBColumn
        Caption = 'Kullan'#305'c'#305
        DataBinding.FieldName = 'FIRMA'
        HeaderAlignmentHorz = taCenter
        Width = 107
      end
      object DBGrid1DBTableView1TABLO: TcxGridDBColumn
        Caption = 'Tablo'
        DataBinding.FieldName = 'ANAHTAR'
        HeaderAlignmentHorz = taCenter
        Width = 90
      end
      object DBGrid1DBTableView1ISLEM: TcxGridDBColumn
        Caption = #304#351'lem'
        DataBinding.FieldName = 'ISLEM'
        HeaderAlignmentHorz = taCenter
        Width = 59
      end
    end
    object DBGrid1Level1: TcxGridLevel
      GridView = DBGrid1DBTableView1
    end
  end
  object SQLMemo: TMemo
    Left = 59
    Top = 287
    Width = 416
    Height = 81
    Lines.Strings = (
      'SELECT  '
      #9
      
        'L.ID,SATIRID,TARIH,TABLOID,R.FIRMA,T.ANAHTAR,L.TUR,L.PCADI,T.DEG' +
        'ER,'
      #9'ISLEM = CASE '
      #9#9'WHEN L.TUR=5 then '#39'Silme'#39' '
      #9#9'WHEN L.TUR=4 then '#39'De'#287'i'#351'me'#39' '
      #9#9'WHEN L.TUR=3 THEN '#39'Ekleme'#39
      #9#9'WHEN L.TUR=2 THEN '#39#199#305'k'#305#351#39
      #9#9'WHEN L.TUR=1 THEN '#39'Giri'#351#39
      #9'END'
      'FROM LOG AS L '
      #9'LEFT OUTER JOIN REHBER AS R on R.ID=L.EKLEYEN '
      #9'LEFT OUTER JOIN (Select ANAHTAR,DEGER from GENINI Where '
      'BOLUM=-1012  AND DIL=-1 ) AS T ON T.DEGER=L.TABLOID')
    TabOrder = 3
    Visible = False
  end
  object SqlLogHareket: TMemo
    Left = 59
    Top = 145
    Width = 416
    Height = 49
    Lines.Strings = (
      'Select * from LOGHAR'
      'Where LOGID=:logid'
      'AND TABLOALANADI NOT IN '
      '('#39'EKLEYEN'#39','#39'EKLEMETARIHI'#39','#39'DEGISTIREN'#39','#39'DEGISTIRMETARIHI'#39')')
    TabOrder = 4
    Visible = False
  end
  object PanelSag: TPanel
    Left = 537
    Top = 81
    Width = 386
    Height = 452
    Align = alClient
    TabOrder = 5
    object cxGrid1: TcxGrid
      Left = 1
      Top = 1
      Width = 384
      Height = 450
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object cxGridDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DsTabLogHareket
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.AlwaysShowEditor = True
        OptionsBehavior.FocusCellOnTab = True
        OptionsData.Editing = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideSelection = True
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object cxGridDBTableView1LOGID: TcxGridDBColumn
          DataBinding.FieldName = 'LOGID'
          Visible = False
        end
        object cxGridDBTableView1TABLOALANADI: TcxGridDBColumn
          Caption = 'Alan'
          DataBinding.FieldName = 'TABLOALANADI'
          HeaderAlignmentHorz = taCenter
          Width = 121
        end
        object cxGridDBTableView1ESKIALANDEGERI: TcxGridDBColumn
          Caption = 'Eski'
          DataBinding.FieldName = 'ESKIALANDEGERI'
          HeaderAlignmentHorz = taCenter
          Width = 146
        end
        object cxGridDBTableView1YENIALANDEGERI: TcxGridDBColumn
          Caption = 'Yeni'
          DataBinding.FieldName = 'YENIALANDEGERI'
          HeaderAlignmentHorz = taCenter
          Width = 157
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = cxGridDBTableView1
      end
    end
  end
  object SQLMemoEkleme: TMemo
    Left = 59
    Top = 200
    Width = 416
    Height = 81
    Lines.Strings = (
      'SELECT  '
      #9'ID=0,SATIRID=0,TARIH='#39'@@TARIH'#39' '
      ',TABLOID=0,R.FIRMA,ANAHTAR='#39'0'#39',TUR=0,PCADI=null,DEGER=0,'
      #9'ISLEM =  '#39'Ekleme'#39
      'FROM REHBER AS R  '
      'where R.ID=@@EKLEYEN'
      'union all')
    TabOrder = 6
    Visible = False
  end
  object TabLog: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabLogAfterScroll
    ParamData = <>
    SQL.Strings = (
      'SELECT  '
      #9'L.ID, '
      #9'SATIRID,'
      #9'TARIH,'
      #9'TABLOID,'
      #9'R.FIRMA,'
      #9'T.ANAHTAR,'
      #9'L.TUR,'
      '                L.PCADI,'
      #9'T.DEGER,'
      #9#39'SILME'#39' = CASE '
      #9#9'WHEN L.TUR=5 then '#39'Silme'#39' '
      #9#9'WHEN L.TUR=4 then '#39'De'#287'i'#351'me'#39' '
      #9#9'WHEN L.TUR=3 THEN '#39'Ekleme'#39
      #9#9'WHEN L.TUR=2 THEN '#39#199#305'k'#305#351#39
      #9#9'WHEN L.TUR=1 THEN '#39'Giri'#351#39
      #9'END'
      'FROM'
      #9'LOG AS L LEFT OUTER JOIN'
      #9'REHBER AS R on R.ID=L.EKLEYEN LEFT OUTER JOIN'
      
        #9'(Select ANAHTAR,DEGER from GENINI Where BOLUM=-1012 ) AS T ON T' +
        '.DEGER=L.TABLOID')
    Left = 488
    Top = 65520
  end
  object TabLogHareket: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'Select * from LOGHAR'
      'Where LOGID=:logid'
      
        'and  TABLOALANADI NOT IN ('#39'EKLEYEN'#39','#39'EKLEMETARIHI'#39','#39'DEGISTIREN'#39',' +
        #39'DEGISTIRMETARIHI'#39')')
    Left = 608
    Top = 65528
  end
  object DsTabLogHareket: TDataSource
    DataSet = TabLogHareket
    Left = 688
    Top = 65528
  end
  object DsTabLog: TDataSource
    DataSet = TabLog
    Left = 552
    Top = 65520
  end
end
