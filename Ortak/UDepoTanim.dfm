object DepoTanimDlg: TDepoTanimDlg
  Left = 170
  Top = 215
  BorderIcons = [biSystemMenu]
  Caption = 'Depo Tan'#305'mlama'
  ClientHeight = 413
  ClientWidth = 846
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 846
    Height = 41
    Align = alTop
    TabOrder = 0
    object BtnKapat: TSpeedButton
      Left = 760
      Top = 8
      Width = 84
      Height = 22
      Caption = 'Kapat'
      Flat = True
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000220B0000220B000000010000000100000031DE000031
        E7000031EF000031F700FF00FF000031FF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00040404040404
        0404040404040404000004000004040404040404040404000004040000000404
        0404040404040000040404000000000404040404040000040404040402000000
        0404040400000404040404040404000000040000000404040404040404040400
        0101010004040404040404040404040401010204040404040404040404040400
        0201020304040404040404040404030201040403030404040404040404050203
        0404040405030404040404040303050404040404040303040404040303030404
        0404040404040403040403030304040404040404040404040404030304040404
        0404040404040404040404040404040404040404040404040404}
      OnClick = BtnKapatClick
    end
    object NavigatorDepolar: TDBNavigator
      Left = 6
      Top = 8
      Width = 88
      Height = 25
      DataSource = DtsDepolar
      VisibleButtons = [nbInsert, nbDelete]
      Flat = True
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 846
    Height = 372
    Align = alClient
    TabOrder = 1
    object cxGridDepolar: TcxGrid
      Left = 1
      Top = 1
      Width = 844
      Height = 370
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      object TableViewDepolar: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = DtsDepolar
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.GoToNextCellOnEnter = True
        OptionsView.GroupByBox = False
        object TableViewDepolarDBColumn1: TcxGridDBColumn
          Caption = 'Kod'
          DataBinding.FieldName = 'DEPOKODU'
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 40
        end
        object TableViewDepolarDBColumn2: TcxGridDBColumn
          Caption = 'Depo Ad'#305
          DataBinding.FieldName = 'DEPOADI'
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 168
        end
        object TableViewDepolarDBColumn3: TcxGridDBColumn
          Caption = 'Stok Giri'#351
          DataBinding.FieldName = 'STOKGIRIS'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.NullStyle = nssUnchecked
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 50
        end
        object TableViewDepolarDBColumn4: TcxGridDBColumn
          Caption = 'Stok '#199#305'k'#305#351
          DataBinding.FieldName = 'STOKCIKIS'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.NullStyle = nssUnchecked
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 51
        end
        object TableViewDepolarDBColumn5: TcxGridDBColumn
          Caption = 'TMYS Giri'#351
          DataBinding.FieldName = 'TMYSGIRIS'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.NullStyle = nssUnchecked
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 55
        end
        object TableViewDepolarDBColumn6: TcxGridDBColumn
          Caption = 'TMYS '#199#305'k'#305#351
          DataBinding.FieldName = 'TMYSCIKIS'
          PropertiesClassName = 'TcxCheckBoxProperties'
          Properties.NullStyle = nssUnchecked
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 55
        end
        object TableViewDepolarDBColumn7: TcxGridDBColumn
          Caption = 'MKYS Depo Kay'#305't No'
          DataBinding.FieldName = 'MKYSDEPOKAYITNO'
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 106
        end
        object TableViewDepolarDBColumn9: TcxGridDBColumn
          Caption = 'Ekleyen'
          DataBinding.FieldName = 'EKLEYEN'
          Options.Editing = False
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 45
        end
        object TableViewDepolarDBColumn10: TcxGridDBColumn
          Caption = 'Ekleme Tarihi'
          DataBinding.FieldName = 'EKLEMETARIHI'
          Options.Editing = False
          Options.Filtering = False
          Options.Grouping = False
          Options.Moving = False
          Width = 138
        end
      end
      object cxGridDepolarLevel1: TcxGridLevel
        GridView = TableViewDepolar
      end
    end
  end
  object TabDepolar: TADOQuery
    Connection = Tablo.cnn
    CursorType = ctStatic
    BeforePost = TabDepolarBeforePost
    AfterPost = TabDepolarAfterPost
    BeforeDelete = TabDepolarBeforeDelete
    OnNewRecord = TabDepolarNewRecord
    OnPostError = TabDepolarPostError
    Parameters = <>
    SQL.Strings = (
      'SELECT '
      '    *'
      'FROM'
      '  DEPOLAR'
      ''
      'ORDER BY DEPOADI')
    Left = 480
    Top = 248
  end
  object DtsDepolar: TDataSource
    DataSet = TabDepolar
    OnStateChange = DtsDepolarStateChange
    Left = 440
    Top = 248
  end
end
