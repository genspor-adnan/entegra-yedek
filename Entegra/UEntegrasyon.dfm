object EntegrasyonDlg: TEntegrasyonDlg
  Left = 0
  Top = 0
  Caption = 'Entegra Entegrasyon Arac'#305
  ClientHeight = 430
  ClientWidth = 798
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    798
    430)
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 0
    Width = 604
    Height = 430
    Align = alLeft
    PopupMenu = PopupMenu1
    TabOrder = 0
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataModeController.SmartRefresh = True
      DataController.DataSource = DtsAktarilacak
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsSelection.HideFocusRectOnExit = False
      OptionsSelection.MultiSelect = True
      OptionsView.GroupByBox = False
      object cxGrid1DBTableView1NAME: TcxGridDBColumn
        Caption = 'Se'#231
        DataBinding.ValueType = 'Boolean'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ImmediatePost = True
        Properties.NullStyle = nssUnchecked
        MinWidth = 10
        Options.Sorting = False
        Width = 23
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object cxGroupBox1: TcxGroupBox
    Left = 604
    Top = 0
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Ba'#287'lant'#305
    TabOrder = 1
    DesignSize = (
      193
      76)
    Height = 76
    Width = 193
    object cxButton1: TcxButton
      Left = 6
      Top = 17
      Width = 181
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Yeni Ba'#287'lant'#305' Olu'#351'tur'
      TabOrder = 0
      OnClick = cxButton1Click
    end
    object LabelBaglanti: TcxLabel
      Left = 54
      Top = 48
      Anchors = [akLeft, akTop, akRight]
      Caption = '...'
    end
  end
  object cxGroupBox3: TcxGroupBox
    Left = 604
    Top = 75
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Aktar'#305'm Tipi'
    Enabled = False
    TabOrder = 2
    Height = 59
    Width = 193
    object cxImageComboBox1: TcxImageComboBox
      Left = 6
      Top = 26
      Properties.Items = <
        item
          Description = 'Genot'#305'pdan Rehber Al'
          ImageIndex = 0
          Value = 'Genot'#305'pdan Rehber Al'
        end
        item
          Description = 'Genot'#305'pa Rehber Ver'
          Value = 'Genot'#305'pa Rehber Ver'
        end>
      Properties.OnEditValueChanged = cxImageComboBox1PropertiesEditValueChanged
      TabOrder = 0
      Width = 182
    end
  end
  object cxGroupBox4: TcxGroupBox
    Left = 604
    Top = 133
    Anchors = [akLeft, akTop, akRight]
    Caption = 'A'#231#305'klama'
    TabOrder = 3
    Height = 268
    Width = 193
    object cxRichEdit1: TcxRichEdit
      Left = 2
      Top = 18
      Align = alClient
      Lines.Strings = (
        'Rehber entegrasyonunda '#39'KOD'#39' ve '
        #39'FIRMA'#39' alanlar'#305' zorunlu alanlard'#305'r. '
        'di'#287'er t'#252'm alanlar opsiyoneldir. '
        'Aktar'#305'mda zorunlu alanlardan '
        'birinin bo'#351' kalmas'#305' durumunda o '
        'kay'#305't atlanacak ve bir sonraki '
        'kay'#305'ttan devam edilecektir..')
      TabOrder = 0
      Height = 248
      Width = 189
    end
  end
  object cxButton2: TcxButton
    Left = 630
    Top = 403
    Width = 141
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Aktar'#305'm'#305' Ba'#351'lat'
    Enabled = False
    TabOrder = 4
    OnClick = cxButton2Click
  end
  object TabAktarilacak: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      '')
    Left = 477
    Top = 98
  end
  object DtsAktarilacak: TDataSource
    DataSet = TabAktarilacak
    Left = 477
    Top = 142
  end
  object CNNAktarilacak: TFDConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=GENOTIP;Persist Security Info=True;' +
      'User ID=sa;Initial Catalog=GEN2005;Data Source=.'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 476
    Top = 58
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 45
    Top = 47
    object mnSe1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Se'#231
      ImageIndex = 23
      OnClick = mnSe1Click
    end
    object mnTemizle1: TMenuItem
      Caption = 'T'#252'm'#252'n'#252' Temizle'
      ImageIndex = 9
      OnClick = mnTemizle1Click
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = cxGrid1
    PopupMenus = <
      item
        GridView = cxGrid1DBTableView1
        HitTypes = []
        Index = 0
        PopupMenu = PopupMenu1
      end>
    Left = 45
    Top = 2
  end
  object ADOQuery1: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    Left = 551
    Top = 100
  end
  object DataSource1: TDataSource
    DataSet = TabAktarilacak
    Left = 553
    Top = 143
  end
end

