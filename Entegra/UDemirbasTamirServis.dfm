object DemirbasTamirServisDLG: TDemirbasTamirServisDLG
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Demirba'#351' Tamir/Servis Ekran'#305
  ClientHeight = 436
  ClientWidth = 742
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 742
    Height = 436
    Align = alClient
    Alignment = taLeftJustify
    ParentBackground = False
    TabOrder = 0
    object DBText1: TDBText
      Left = 109
      Top = 42
      Width = 65
      Height = 17
      DataField = 'ID'
      DataSource = DtsServis
      Transparent = True
      Visible = False
    end
    object GbServisiadeAl: TGroupBox
      Left = 379
      Top = 90
      Width = 344
      Height = 265
      Caption = 'Servis '#304'ade Al'
      TabOrder = 0
      DesignSize = (
        344
        265)
      object Label20: TcxLabel
        Left = 8
        Top = 52
        Caption = 'Teslim Alan'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label21: TcxLabel
        Left = 8
        Top = 80
        Caption = 'Teslim Alma Tarihi'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label16: TcxLabel
        Left = 8
        Top = 108
        Caption = 'Onar'#305'm A'#231#305'klamas'#305
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Width = 93
      end
      object Label18: TcxLabel
        Left = 8
        Top = 186
        Caption = 'Maliyet'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object dateDonusTarihi: TcxDBDateEdit
        Left = 124
        Top = 81
        DataBinding.DataField = 'TESLIM_TARIHI'
        DataBinding.DataSource = DtsServis
        TabOrder = 0
        Width = 144
      end
      object cbTeslimAlanPersonel: TcxButtonEdit
        Left = 124
        Top = 51
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cbTeslimAlanPersonelPropertiesButtonClick
        TabOrder = 1
        Width = 144
      end
      object memoOnarimNotu: TcxDBMemo
        Left = 124
        Top = 106
        DataBinding.DataField = 'COZUM'
        DataBinding.DataSource = DtsGenel
        TabOrder = 2
        Height = 73
        Width = 217
      end
      object editMaliyet: TcxDBCurrencyEdit
        Left = 124
        Top = 185
        Properties.DisplayFormat = ',0.00;'
        Properties.EditFormat = ',0.00;'
        StyleDisabled.BorderColor = clBtnShadow
        StyleDisabled.Color = clWhite
        StyleDisabled.TextColor = clBtnShadow
        TabOrder = 3
        Width = 98
      end
      object cbKUR: TcxDBComboBox
        Left = 245
        Top = 184
        RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
        Anchors = [akTop, akRight]
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        TabOrder = 8
        Width = 47
      end
    end
    object GbServiseGonder: TGroupBox
      Left = 2
      Top = 89
      Width = 371
      Height = 267
      Caption = 'Servise G'#246'nder'
      TabOrder = 1
      object Label5: TcxLabel
        Left = 10
        Top = 25
        Caption = 'Tarih'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label13: TcxLabel
        Left = 10
        Top = 243
        Caption = 'Servise G'#246'nderen'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label14: TcxLabel
        Left = 10
        Top = 107
        Caption = 'A'#231#305'klama'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabelGonderilenFirma: TcxLabel
        Left = 10
        Top = 178
        Caption = 'G'#246'nderilen Firma'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object Label17: TcxLabel
        Left = 10
        Top = 51
        Caption = 'Servis Form No'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
      object LabeFirmaPersoneli: TcxLabel
        Left = 10
        Top = 211
        Cursor = crHandPoint
        Caption = 'Firma Personeli'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
        OnClick = LabeFirmaPersoneliClick
      end
      object dateServisTarih: TcxDBDateEdit
        Left = 144
        Top = 22
        DataBinding.DataField = 'TARIH'
        DataBinding.DataSource = DtsServis
        TabOrder = 0
        Width = 144
      end
      object memoServiseGonderimNedeni: TcxDBMemo
        Left = 143
        Top = 103
        DataBinding.DataField = 'ACIKLAMA'
        DataBinding.DataSource = DtsGenel
        Enabled = False
        TabOrder = 1
        Height = 69
        Width = 218
      end
      object editServisFormNo: TcxDBTextEdit
        Left = 144
        Top = 49
        DataBinding.DataField = 'SERVISNO'
        DataBinding.DataSource = DtsServis
        StyleDisabled.BorderColor = clBtnShadow
        StyleDisabled.Color = clWhite
        StyleDisabled.TextColor = clBackground
        TabOrder = 2
        Width = 144
      end
      object cbServiseGonderen: TcxButtonEdit
        Left = 143
        Top = 237
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cbServiseGonderenPropertiesButtonClick
        TabOrder = 3
        Width = 216
      end
      object cbGonderilenFirma: TcxButtonEdit
        Left = 143
        Top = 177
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cbGonderilenFirmaPropertiesButtonClick
        TabOrder = 4
        Width = 216
      end
      object cbFirmaPersoneli: TcxButtonEdit
        Left = 143
        Top = 207
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cbKabulEdenPersonelPropertiesButtonClick
        TabOrder = 5
        Width = 216
      end
      object EditProblem: TcxButtonEdit
        Left = 144
        Top = 76
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
        TabOrder = 12
        Width = 217
      end
      object cxLabel1: TcxLabel
        Left = 10
        Top = 77
        Caption = 'Problem'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object ToolBar3: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 734
      Height = 29
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 71
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
      Font.Name = 'Trebuchet MS'
      Font.Style = []
      GradientEndColor = 11776947
      GradientStartColor = 14540253
      HotTrackColor = 65408
      Images = Tablo.PNGImageList1
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 2
      Transparent = True
      object btnKaydet: TToolButton
        Left = 0
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 10
        Style = tbsTextButton
        OnClick = btnKaydetClick
      end
      object ToolButton1: TToolButton
        Left = 71
        Top = 0
        Width = 571
        Caption = 'ToolButton1'
        ImageIndex = 18
        Style = tbsSeparator
      end
      object btnkapat: TToolButton
        Left = 642
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 18
        OnClick = btnkapatClick
      end
    end
    object SQLGenelServis: TcxMemo
      Left = 343
      Top = 50
      Lines.Strings = (
        'SELECT *'
        ''
        
          '--GONDERENADI = (SELECT R1.FIRMA FROM REHBER R1 WHERE S.MUS_ILGI' +
          'LI = R1.ID), '
        
          '--GERIALANADSOYAD = (SELECT R2.FIRMA FROM REHBER R2 WHERE S.KABU' +
          'L_EDEN = R2.ID) '
        'FROM SERVIS S '
        ''
        'where ID=:Prm1')
      Properties.WordWrap = False
      TabOrder = 3
      Visible = False
      Height = 45
      Width = 588
    end
  end
  object DtsServis: TDataSource
    DataSet = TabServis
    OnStateChange = DtsServisStateChange
    Left = 422
    Top = 98
  end
  object TabServis: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    OnNewRecord = TabServisNewRecord
    ParamData = <>
    SQL.Strings = (
      'SELECT *'
      ''
      'FROM SERVIS S '
      ''
      'where ID=:Prm1')
    Left = 297
    Top = 2
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 86
    Top = 96
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxReport1: TfrxReport
    Version = '4.13.1'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 40646.402858726850000000
    ReportOptions.LastChange = 40646.402858726850000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 576
    Top = 40
    Datasets = <>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
    end
  end
  object frxTamirServis: TfrxDBDataset
    UserName = 'TabDemirbasServis'
    CloseDataSource = False
    DataSet = TabServis
    BCDToCurrency = False
    Left = 640
    Top = 40
  end
  object TabGenel: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    AfterOpen = TabGenelAfterOpen
    ParamData = <>
    SQL.Strings = (
      'select top 1 '
      'SB.ID,SERVISID,SB.SERVISLISTEID, '
      
        'KOD = cast(SB.SERVISTUR as varchar(5))+'#39'.'#39'+(select KOD from SERV' +
        'ISLISTE SL where SL.ID=SB.SERVISLISTEID),'
      
        'GRUP=(select top 1 ANAHTAR from GENINI G WHERE BOLUM=-30020 and ' +
        'DEGER=SB.SERVISTUR),'
      
        'AD=(select AD from SERVISLISTE SL where SL.ID=SB.SERVISLISTEID),' +
        ' '
      'SB.ACIKLAMA, SB.COZUM '
      ''
      'from SERVISBILGI SB'
      'where'
      'SB.SERVISTUR = 210'
      'and'
      'SERVISID=:PRM1')
    Left = 381
    Top = 199
  end
  object DtsGenel: TDataSource
    DataSet = TabGenel
    OnStateChange = DtsServisStateChange
    Left = 445
    Top = 208
  end
end


