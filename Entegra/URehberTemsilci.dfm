object RehberTemsilciDlg: TRehberTemsilciDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Temsilci Ge'#231'mi'#351'i'
  ClientHeight = 441
  ClientWidth = 805
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object pnlAnimsat: TPanel
    Left = 0
    Top = 0
    Width = 805
    Height = 441
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 620
    ExplicitHeight = 440
    DesignSize = (
      805
      441)
    object Image1: TImage
      Left = 1
      Top = 2
      Width = 53
      Height = 54
      Picture.Data = {
        0D546478536D617274496D6167653C3F786D6C2076657273696F6E3D22312E30
        2220656E636F64696E673D225554462D38223F3E0D0A3C737667207665727369
        6F6E3D22312E31222069643D224C61796572312220786D6C6E733D2268747470
        3A2F2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C
        696E6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E
        6B2220783D223070782220793D22307078222076696577426F783D2230203020
        333220333222207374796C653D22656E61626C652D6261636B67726F756E643A
        6E6577203020302033322033323B2220786D6C3A73706163653D227072657365
        727665223E262331333B262331303B20203C7374796C6520747970653D227465
        78742F6373732220786D6C3A73706163653D227072657365727665223E2E426C
        61636B262331333B262331303B202020207B262331333B262331303B20202020
        202066696C6C3A233732373237323B262331333B262331303B20202020202066
        6F6E742D66616D696C793A2661706F733B64782D666F6E742D69636F6E732661
        706F733B3B262331333B262331303B202020202020666F6E742D73697A653A33
        3270783B262331333B262331303B202020207D262331333B262331303B20203C
        2F7374796C653E0D0A3C7465787420783D22302220793D2233322220636C6173
        733D22426C61636B223EEEA09C3C2F746578743E0D0A3C2F7376673E0D0A}
      Stretch = True
      Transparent = True
    end
    object GridTemsilci: TcxGrid
      Left = -2
      Top = 60
      Width = 803
      Height = 301
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      LookAndFeel.NativeStyle = True
      ExplicitWidth = 618
      ExplicitHeight = 300
      object GridTemsilciView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsTemsilci
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.ColumnHeaderHints = False
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.InvertSelect = False
        OptionsView.NoDataToDisplayInfoText = 'Veri Yok'
        OptionsView.ScrollBars = ssVertical
        OptionsView.GridLines = glNone
        OptionsView.GroupByBox = False
        Styles.ContentEven = Tablo.cxStDogruBildirim
        object GridTemsilciViewTEMSILCIAD: TcxGridDBColumn
          Caption = 'Temsilci'
          DataBinding.FieldName = 'TEMSILCIAD'
          Width = 166
        end
        object GridTemsilciViewBASLAMA: TcxGridDBColumn
          Caption = 'Ba'#351'lama'
          DataBinding.FieldName = 'BASLAMA'
          PropertiesClassName = 'TcxDateEditProperties'
          Width = 71
        end
        object GridTemsilciViewBITIS: TcxGridDBColumn
          Caption = 'Biti'#351
          DataBinding.FieldName = 'BITIS'
          PropertiesClassName = 'TcxDateEditProperties'
          Width = 73
        end
        object GridTemsilciViewACIKLAMA: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
          Width = 203
        end
        object GridTemsilciViewEKLEYENAD: TcxGridDBColumn
          Caption = 'Ekleyen'
          DataBinding.FieldName = 'EKLEYENAD'
          Width = 167
        end
      end
      object GridTemsilciLevel1: TcxGridLevel
        GridView = GridTemsilciView
      end
    end
    object cxButton2: TcxButton
      Left = 623
      Top = 407
      Width = 178
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Kapat'
      ModalResult = 8
      TabOrder = 1
      ExplicitLeft = 438
      ExplicitTop = 406
    end
    object cxLabel1: TcxLabel
      Left = 59
      Top = 17
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Style.TextColor = clRed
      Transparent = True
      ExplicitWidth = 557
      Height = 17
      Width = 742
    end
    object cxLabel2: TcxLabel
      Left = 80
      Top = 10
      Caption = 'LabelTemsilci'
    end
    object cxLabel3: TcxLabel
      Left = 80
      Top = 35
      Caption = 'Aktif Temsilci  : '
    end
    object cxLabel4: TcxLabel
      Left = 167
      Top = 35
      Caption = 'LabelTemsilci'
    end
  end
  object DtsTemsilci: TDataSource
    DataSet = TabTemsilci
    Left = 276
    Top = 6
  end
  object TabTemsilci: TFDQuery
    Connection = Tablo.FDCnn
    OnCalcFields = TabTemsilciCalcFields
    ParamData = <>
    SQL.Strings = (
      'select * from REHBERTEMSILCI'
      ' order by BASLAMA desc')
    Left = 372
    Top = 3
    object TabTemsilciID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabTemsilciREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabTemsilciTEMSILCIID: TIntegerField
      FieldName = 'TEMSILCIID'
    end
    object TabTemsilciTEMSILCIAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'TEMSILCIAD'
      Size = 100
      Calculated = True
    end
    object TabTemsilciBASLAMA: TSQLTimeStampField
      FieldName = 'BASLAMA'
    end
    object TabTemsilciBITIS: TSQLTimeStampField
      FieldName = 'BITIS'
    end
    object TabTemsilciACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object TabTemsilciEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabTemsilciEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object TabTemsilciDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabTemsilciDEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object TabTemsilciEKLEYENAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'EKLEYENAD'
      Size = 100
      Calculated = True
    end
  end
end



