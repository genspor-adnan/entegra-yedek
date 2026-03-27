object DuzenliOdeme: TDuzenliOdeme
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Color = clWhite
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object ToolBar2: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 29
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 69
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
    Images = AnaForm.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 69
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton4: TToolButton
      Left = 138
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      Style = tbsSeparator
    end
    object KaydetTus: TToolButton
      Left = 146
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 215
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton1: TToolButton
      Left = 284
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 292
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 32
    Width = 451
    Height = 272
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 449
      Height = 120
      Align = alTop
      TabOrder = 0
      object Label7: TLabel
        Left = 494
        Top = 8
        Width = 35
        Height = 18
        Caption = 'Durum'
      end
      object Label2: TLabel
        Left = 135
        Top = 34
        Width = 32
        Height = 18
        Caption = 'Kodu '
      end
      object Label4: TLabel
        Left = 234
        Top = 32
        Width = 17
        Height = 18
        Caption = 'Ad'#305
      end
      object Label5: TLabel
        Left = 133
        Top = 61
        Width = 34
        Height = 18
        Caption = 'Grubu'
      end
      object Label6: TLabel
        Left = 10
        Top = 5
        Width = 217
        Height = 22
        Caption = 'D'#252'zenli '#214'deme Kart'#305' Bilgileri'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label9: TLabel
        Left = 122
        Top = 91
        Width = 47
        Height = 18
        Caption = 'A'#231#305'klama'
      end
      object ComboDURUM: TcxDBImageComboBox
        Left = 538
        Top = 6
        TabStop = False
        DataBinding.DataField = 'DURUM'
        DataBinding.DataSource = DtsDuzenliOdeme
        Properties.Items = <
          item
            Description = 'Aktif'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Pasif'
            Value = 0
          end>
        TabOrder = 3
        Width = 77
      end
      object cxDBTextEdit1: TcxDBTextEdit
        Left = 172
        Top = 32
        DataBinding.DataField = 'KODU'
        DataBinding.DataSource = DtsDuzenliOdeme
        TabOrder = 0
        Width = 57
      end
      object cxDBTextEdit2: TcxDBTextEdit
        Left = 257
        Top = 32
        DataBinding.DataField = 'ADI'
        DataBinding.DataSource = DtsDuzenliOdeme
        TabOrder = 1
        Width = 169
      end
      object cxDBLabel1: TcxDBLabel
        Left = 274
        Top = 6
        DataBinding.DataField = 'ID'
        DataBinding.DataSource = DtsDuzenliOdeme
        Style.TransparentBorder = True
        Transparent = True
        Height = 21
        Width = 121
      end
      object cxDBTextEdit3: TcxDBTextEdit
        Left = 172
        Top = 60
        DataBinding.DataField = 'GRUBU'
        DataBinding.DataSource = DtsDuzenliOdeme
        TabOrder = 2
        Width = 254
      end
      object cxDBTextEdit4: TcxDBTextEdit
        Left = 172
        Top = 89
        DataBinding.DataField = 'ACIKLAMA'
        DataBinding.DataSource = DtsDuzenliOdeme
        TabOrder = 5
        Width = 254
      end
    end
    object GridDO: TcxGrid
      Left = 1
      Top = 298
      Width = 449
      Height = 55
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridDODBTableView1: TcxGridDBTableView
        NavigatorButtons.ConfirmDelete = False
        DataController.DataSource = DtsDetay
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnTab = True
        OptionsSelection.HideSelection = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        object GridDODBTableView1ID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          Visible = False
        end
        object GridDODBTableView1DUZID: TcxGridDBColumn
          DataBinding.FieldName = 'DUZID'
          Visible = False
        end
        object GridDODBTableView1REHBERID: TcxGridDBColumn
          DataBinding.FieldName = 'REHBERID'
          Visible = False
        end
        object GridDODBTableView1Column1: TcxGridDBColumn
          Caption = 'Cari Kod'
          DataBinding.FieldName = 'FIRMAKOD'
          Width = 86
        end
        object GridDODBTableView1Column2: TcxGridDBColumn
          Caption = 'Cari '#220'nvan'#305
          DataBinding.FieldName = 'FIRMAAD'
        end
        object GridDODBTableView1BASLAMA_TARIHI: TcxGridDBColumn
          Caption = 'Ba'#351'lama Tarihi'
          DataBinding.FieldName = 'BASLAMA_TARIHI'
        end
        object GridDODBTableView1BITIS_TARIHI: TcxGridDBColumn
          Caption = 'Biti'#351' Tarihi'
          DataBinding.FieldName = 'BITIS_TARIHI'
        end
        object GridDODBTableView1DURUM: TcxGridDBColumn
          Caption = 'Durum'
          DataBinding.FieldName = 'DURUM'
        end
        object GridDODBTableView1ACIKLAMA: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
        end
      end
      object GridDOLevel1: TcxGridLevel
        GridView = GridDODBTableView1
      end
    end
    object PanelAlt: TPanel
      Left = 1
      Top = 121
      Width = 449
      Height = 177
      Align = alTop
      TabOrder = 2
      object Label3: TLabel
        Left = 115
        Top = 139
        Width = 47
        Height = 18
        Caption = 'A'#231#305'klama'
      end
      object Label18: TLabel
        Left = 92
        Top = 88
        Width = 77
        Height = 18
        Caption = 'Ba'#351'lama Tarihi'
      end
      object Label17: TLabel
        Left = 79
        Top = 61
        Width = 90
        Height = 18
        Caption = 'Cari Hesap Kodu'
      end
      object Label1: TLabel
        Left = 269
        Top = 87
        Width = 58
        Height = 18
        Caption = 'Biti'#351' Tarihi'
      end
      object Label8: TLabel
        Left = 9
        Top = 31
        Width = 133
        Height = 22
        Caption = 'S'#246'zle'#351'me Bilgileri'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Trebuchet MS'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LabelUyariGun: TLabel
        Left = 301
        Top = 118
        Width = 73
        Height = 18
        Caption = 'g'#252'n '#246'nceden'
      end
      object LabelBORCLUUNVAN: TLabel
        Left = 267
        Top = 63
        Width = 12
        Height = 18
        Caption = '---'
      end
      object EditNOTLAR: TcxDBTextEdit
        Left = 172
        Top = 138
        DataBinding.DataField = 'ACIKLAMA'
        DataBinding.DataSource = DtsDetay
        TabOrder = 0
        Width = 290
      end
      object DateSOZLESME_TARIHI: TcxDBDateEdit
        Left = 172
        Top = 84
        DataBinding.DataField = 'BASLAMA_TARIHI'
        DataBinding.DataSource = DtsDetay
        TabOrder = 1
        Width = 84
      end
      object EditBORCLUKOD: TcxButtonEdit
        Left = 172
        Top = 58
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = EditBORCLUKODPropertiesButtonClick
        TabOrder = 2
        Width = 84
      end
      object SOZLESMEREHBERID: TcxDBTextEdit
        Left = 623
        Top = 59
        DataBinding.DataField = 'REHBERID'
        DataBinding.DataSource = DtsDetay
        ParentColor = True
        TabOrder = 3
        Visible = False
        Width = 25
      end
      object DateBITIS_TARIHI: TcxDBDateEdit
        Left = 331
        Top = 85
        DataBinding.DataField = 'BITIS_TARIHI'
        DataBinding.DataSource = DtsDetay
        TabOrder = 4
        Width = 84
      end
      object PlanTus: TcxButton
        Left = 467
        Top = 137
        Width = 88
        Height = 25
        Caption = #214'deme Planla'
        TabOrder = 5
        OnClick = PlanTusClick
      end
      object CheckBitisUyar: TcxDBCheckBox
        Left = 172
        Top = 112
        Caption = 'Uyar'#305' ver'
        DataBinding.DataField = 'UYAR'
        DataBinding.DataSource = DtsDetay
        TabOrder = 6
        Transparent = True
        Width = 70
      end
      object SpinUYARIGUN: TcxDBSpinEdit
        Left = 252
        Top = 111
        DataBinding.DataField = 'UYARIGUN'
        DataBinding.DataSource = DtsDetay
        Properties.MinValue = 1.000000000000000000
        TabOrder = 7
        Width = 42
      end
      object ToolBar4: TToolBar
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 441
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
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
        Images = AnaForm.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 8
        Transparent = True
        ExplicitWidth = 433
        object SozEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = SozEkleTusClick
        end
        object SozSilTus: TToolButton
          Left = 61
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SozSilTusClick
        end
        object SozKaydetTus: TToolButton
          Left = 122
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Style = tbsTextButton
          Visible = False
          OnClick = SozKaydetTusClick
        end
        object SozIptalTus: TToolButton
          Left = 183
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Style = tbsTextButton
          Visible = False
          OnClick = SozIptalTusClick
        end
        object ToolButton3: TToolButton
          Left = 244
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 4
          Style = tbsSeparator
        end
        object EkstreTus: TToolButton
          Left = 252
          Top = 0
          Caption = 'Ekstre'
          ImageIndex = 6
          OnClick = EkstreTusClick
        end
      end
    end
  end
  object TabDuzenliOdeme: TFDQuery
    Connection = Tablo.FDCnn
    AfterPost = TabDuzenliOdemeAfterPost
    AfterCancel = TabDuzenliOdemeAfterCancel
    BeforeDelete = TabDuzenliOdemeBeforeDelete
    AfterScroll = TabDuzenliOdemeAfterScroll
    OnNewRecord = TabDuzenliOdemeNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from DUZENLIODEME where ADI = :PRM1')
    Left = 33
    Top = 60
  end
  object DtsDuzenliOdeme: TDataSource
    DataSet = TabDuzenliOdeme
    OnStateChange = DtsDuzenliOdemeStateChange
    Left = 32
    Top = 104
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    OnStateChange = DtsDetayStateChange
    Left = 64
    Top = 233
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabDetayBeforePost
    AfterPost = TabDuzenliOdemeAfterPost
    AfterScroll = TabDetayAfterScroll
    OnCalcFields = TabDetayCalcFields
    OnNewRecord = TabDetayNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from DUZENLIODEMEDETAY where DUZID = :PRM1'
      'order by BASLAMA_TARIHI desc')
    Left = 15
    Top = 231
    object TabDetayID: TSmallintField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabDetayDUZID: TSmallintField
      FieldName = 'DUZID'
    end
    object TabDetayREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabDetayFIRMAKOD: TStringField
      FieldKind = fkCalculated
      FieldName = 'FIRMAKOD'
      Size = 0
      Calculated = True
    end
    object TabDetayFIRMAAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'FIRMAAD'
      Calculated = True
    end
    object TabDetayBASLAMA_TARIHI: TDateTimeField
      FieldName = 'BASLAMA_TARIHI'
    end
    object TabDetayBITIS_TARIHI: TDateTimeField
      FieldName = 'BITIS_TARIHI'
    end
    object TabDetayDURUM: TSmallintField
      FieldName = 'DURUM'
    end
    object TabDetayUYAR: TBooleanField
      FieldName = 'UYAR'
    end
    object TabDetayUYARIGUN: TSmallintField
      FieldName = 'UYARIGUN'
    end
    object TabDetayACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 200
    end
    object TabDetayEKLEYEN: TWideStringField
      FieldName = 'EKLEYEN'
      Size = 5
    end
    object TabDetayEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
      ReadOnly = True
    end
    object TabDetayDEGISTIREN: TWideStringField
      FieldName = 'DEGISTIREN'
      Size = 5
    end
    object TabDetayDEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
  end
end
