object MailSablonDuzenleDlg: TMailSablonDuzenleDlg
  Left = 0
  Top = 0
  Caption = 'E-Posta '#350'ablon D'#252'zenleyicisi'
  ClientHeight = 591
  ClientWidth = 1103
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
  object PanelOrta: TPanel
    Left = 209
    Top = 0
    Width = 894
    Height = 591
    Align = alClient
    TabOrder = 0
    object SynMemo1: TSynMemo
      Left = 1
      Top = 49
      Width = 892
      Height = 239
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = True
      TabOrder = 0
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      Highlighter = SynHTMLSyn1
    end
    object WebBrowser1: TWebBrowser
      Left = 1
      Top = 328
      Width = 892
      Height = 262
      Align = alBottom
      TabOrder = 1
      ExplicitTop = 326
      ExplicitWidth = 876
      ControlData = {
        4C000000315C0000141B00000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126204000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
    object PanelUst: TPanel
      Left = 1
      Top = 1
      Width = 892
      Height = 48
      Align = alTop
      TabOrder = 2
      DesignSize = (
        892
        48)
      object cbModul: TcxDBImageComboBox
        Left = 45
        Top = 1
        DataBinding.DataField = 'MODULID'
        DataBinding.DataSource = DtsSablon
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <
          item
            Description = 'Servis'
            ImageIndex = 0
            Value = 83
          end>
        TabOrder = 0
        Width = 121
      end
      object cxLabel1: TcxLabel
        Left = 9
        Top = 2
        Caption = 'Mod'#252'l'
      end
      object cxLabel2: TcxLabel
        Left = 193
        Top = 2
        Caption = 'Ad'
      end
      object EditAd: TcxDBTextEdit
        Left = 216
        Top = 1
        Anchors = [akLeft, akTop, akRight]
        DataBinding.DataField = 'SABLONADI'
        DataBinding.DataSource = DtsSablon
        TabOrder = 3
        Width = 665
      end
      object EditBaslik: TcxDBTextEdit
        Left = 45
        Top = 24
        Anchors = [akLeft, akTop, akRight]
        DataBinding.DataField = 'KONU'
        DataBinding.DataSource = DtsSablon
        TabOrder = 4
        Width = 836
      end
      object cxLabel3: TcxLabel
        Left = 11
        Top = 25
        Caption = 'Ba'#351'l'#305'k'
      end
    end
    object Panelalt: TPanel
      Left = 1
      Top = 288
      Width = 892
      Height = 32
      Align = alBottom
      TabOrder = 3
      DesignSize = (
        892
        32)
      object btnOnIzle: TcxButton
        Left = 786
        Top = 4
        Width = 100
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #214'n '#304'zleme'
        TabOrder = 0
        OnClick = btnOnIzleClick
      end
    end
    object cxSplitter1: TcxSplitter
      Left = 1
      Top = 320
      Width = 892
      Height = 8
      AlignSplitter = salBottom
      Control = WebBrowser1
    end
  end
  object PanelSol: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 591
    Align = alLeft
    Alignment = taLeftJustify
    Caption = 'PanelSol'
    TabOrder = 1
    object ToolBar15: TToolBar
      Left = 1
      Top = 1
      Width = 207
      Height = 41
      ButtonHeight = 36
      ButtonWidth = 41
      Caption = 'ToolBar15'
      DrawingStyle = dsGradient
      GradientEndColor = 11776947
      GradientStartColor = 14540253
      Images = Tablo.PNGImageList2
      ShowCaptions = True
      TabOrder = 0
      object TBtnHareketlerEkle: TToolButton
        Left = 0
        Top = 0
        Caption = 'Ekle'
        ImageIndex = 0
        OnClick = TBtnHareketlerEkleClick
      end
      object TBtnHareketlerSil: TToolButton
        Left = 41
        Top = 0
        Caption = 'Sil'
        ImageIndex = 1
        OnClick = TBtnHareketlerSilClick
      end
      object TBtnHareketKaydet: TToolButton
        Left = 82
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Visible = False
        OnClick = TBtnHareketKaydetClick
      end
      object TBtnHareketIptal: TToolButton
        Left = 123
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Visible = False
        OnClick = TBtnHareketIptalClick
      end
    end
    object GridMailSablon: TcxGrid
      Left = 1
      Top = 42
      Width = 207
      Height = 548
      Align = alClient
      TabOrder = 1
      object GridMailSablonTableView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = DtsSablon
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsView.GroupByBox = False
        object GridMailSablonTableViewMODULID: TcxGridDBColumn
          Caption = 'Mod'#252'l'
          DataBinding.FieldName = 'MODULID'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.ImmediateDropDownWhenKeyPressed = False
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <
            item
              Description = 'Servis'
              ImageIndex = 0
              Value = 83
            end
            item
              Description = 'Rehber Personel'
              Value = 77
            end>
          Width = 79
        end
        object GridMailSablonTableViewSABLONADI: TcxGridDBColumn
          Caption = 'Ad'
          DataBinding.FieldName = 'SABLONADI'
          Width = 144
        end
      end
      object GridMailSablonLevel1: TcxGridLevel
        GridView = GridMailSablonTableView
      end
    end
  end
  object TabSablon: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    BeforePost = TabSablonBeforePost
    AfterScroll = TabSablonAfterScroll
    OnNewRecord = TabSablonNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT '
      #9'*'
      'FROM '
      #9'MAILSABLON')
    Left = 116
    Top = 212
  end
  object DtsSablon: TDataSource
    DataSet = TabSablon
    OnStateChange = DtsSablonStateChange
    Left = 124
    Top = 280
  end
  object SynHTMLSyn1: TSynHTMLSyn
    Left = 352
    Top = 176
  end
end
