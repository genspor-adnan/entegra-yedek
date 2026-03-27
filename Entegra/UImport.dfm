object ImportDlg: TImportDlg
  Left = 195
  Top = 108
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Veri Alma Ekran'#305
  ClientHeight = 463
  ClientWidth = 830
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  PopupMenu = PmSagClick
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 830
    Height = 145
    Align = alTop
    BevelOuter = bvLowered
    Color = 11776947
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 67
      Width = 71
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ad'#305' '
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 327
      Top = 44
      Width = 68
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Dosya T'#252'r'#252
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label3: TLabel
      Left = 39
      Top = 89
      Width = 44
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tipi '
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 306
      Top = 67
      Width = 88
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ba'#351'lama sat'#305'r'#305
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label5: TLabel
      Left = 418
      Top = 66
      Width = 71
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Biti'#351
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label6: TLabel
      Left = 315
      Top = 89
      Width = 78
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Dosya Ad'#305
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label7: TLabel
      Left = 40
      Top = 41
      Width = 44
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Mod'#252'l'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label8: TLabel
      Left = 351
      Top = 117
      Width = 44
      Height = 14
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kural '
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label9: TLabel
      Left = 684
      Top = 89
      Width = 49
      Height = 13
      Alignment = taRightJustify
      Caption = 'Sayfa No'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 822
      Height = 22
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 20
      ButtonWidth = 46
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
        Left = 46
        Top = 0
        Caption = 'Sil'
        ImageIndex = 8
        OnClick = SilTusClick
      end
      object ToolButton2: TToolButton
        Left = 92
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        Enabled = False
        ImageIndex = 9
        Style = tbsSeparator
      end
      object KaydetTus: TToolButton
        Left = 100
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 10
        OnClick = KaydetTusClick
      end
      object IptalTus: TToolButton
        Left = 146
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 17
        OnClick = IptalTusClick
      end
      object ToolButton6: TToolButton
        Left = 192
        Top = 0
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 19
        Style = tbsSeparator
      end
      object DokumTus: TToolButton
        Left = 200
        Top = 0
        Caption = 'Ba'#351'lat'
        ImageIndex = 1
        OnClick = DokumTusClick
      end
      object cxTabControl1: TcxTabControl
        Left = 246
        Top = 0
        Width = 2
        Height = 20
        TabOrder = 0
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 18
        ClientRectLeft = 2
        ClientRectRight = 2
        ClientRectTop = 2
      end
      object ToolButton5: TToolButton
        Left = 248
        Top = 0
        Width = 8
        Caption = 'ToolButton5'
        ImageIndex = 19
        Style = tbsSeparator
      end
      object btnKapat: TToolButton
        Left = 256
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 18
        Style = tbsTextButton
        OnClick = btnKapatClick
      end
      object ToolButton4: TToolButton
        Left = 302
        Top = 0
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 19
        Style = tbsSeparator
      end
    end
    object cxDBTextEdit1: TcxDBTextEdit
      Left = 92
      Top = 64
      DataBinding.DataField = 'ADI'
      DataBinding.DataSource = DtsImport
      TabOrder = 3
      Width = 141
    end
    object cxDBSpinEdit1: TcxDBSpinEdit
      Left = 403
      Top = 64
      DataBinding.DataField = 'BASLA'
      DataBinding.DataSource = DtsImport
      TabOrder = 4
      Width = 53
    end
    object cxDBSpinEdit2: TcxDBSpinEdit
      Left = 494
      Top = 65
      DataBinding.DataField = 'BITIS'
      DataBinding.DataSource = DtsImport
      TabOrder = 5
      Width = 49
    end
    object cxDBImageComboBox1: TcxDBImageComboBox
      Left = 92
      Top = 88
      DataBinding.DataField = 'IMPORT'
      DataBinding.DataSource = DtsImport
      Properties.Items = <
        item
          Description = 'Veri Al (Import)'
          ImageIndex = 0
          Value = True
        end
        item
          Description = 'Veri Ver (Export)'
          Value = False
        end>
      TabOrder = 8
      Width = 140
    end
    object cxDBImageComboBox2: TcxDBImageComboBox
      Left = 402
      Top = 43
      DataBinding.DataField = 'DOSYATURU'
      DataBinding.DataSource = DtsImport
      Properties.Items = <
        item
          Description = 'Excel'
          ImageIndex = 0
          Value = 1
        end>
      TabOrder = 2
      Width = 140
    end
    object ComboMODUL: TcxDBComboBox
      Left = 92
      Top = 40
      DataBinding.DataField = 'MODUL'
      DataBinding.DataSource = DtsImport
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'Cari'
        'Cari Personel Temel'
        'Fatura Giri'#351
        'Fatura '#199#305'k'#305#351
        'Stok Kart'
        'Stok '#199'evrim'
        'Stok Fiyat'
        #199'ek Giri'#351
        #199'ek '#199#305'k'#305#351
        'PDKS Giri'#351
        'PDKS '#199#305'k'#305#351)
      TabOrder = 1
      Width = 142
    end
    object cxDBButtonEdit1: TcxDBButtonEdit
      Left = 403
      Top = 85
      DataBinding.DataField = 'DOSYAADI'
      DataBinding.DataSource = DtsImport
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 6
      OnClick = cxDBButtonEdit1Click
      Width = 277
    end
    object cxDBImageComboBox3: TcxDBImageComboBox
      Left = 403
      Top = 116
      DataBinding.DataField = 'KURAL'
      DataBinding.DataSource = DtsImport
      Properties.Items = <
        item
          Description = 'Ayn'#305' kodlu veride dokunmadan ge'#231'sin'
          ImageIndex = 0
          Value = 1
        end
        item
          Description = 'Ayn'#305' kodlu veride; bo'#351'luk varsa eklesin; doluysa de'#287'i'#351'tirmesin'
          Value = 2
        end
        item
          Description = 'Ayn'#305' kodlu veride; yeni veriyi baz als'#305'n ve de'#287'i'#351'tirsin'
          Value = 3
        end>
      TabOrder = 9
      Width = 385
    end
    object cxDBSpinEdit3: TcxDBSpinEdit
      Left = 738
      Top = 87
      DataBinding.DataField = 'SAYFA'
      DataBinding.DataSource = DtsImport
      Properties.MaxValue = 100.000000000000000000
      Properties.MinValue = 1.000000000000000000
      TabOrder = 7
      Width = 53
    end
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 145
    Width = 830
    Height = 318
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = cxTabSheet1
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 316
    ClientRectLeft = 2
    ClientRectRight = 828
    ClientRectTop = 25
    object cxTabSheet1: TcxTabSheet
      Caption = 'Alanlar'
      ImageIndex = 0
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 820
        Height = 22
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 20
        ButtonWidth = 46
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
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object DetayEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = DetayEkleTusClick
        end
        object DetaySilTus: TToolButton
          Left = 46
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = DetaySilTusClick
        end
        object DetayKaydetTus: TToolButton
          Left = 92
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          OnClick = DetayKaydetTusClick
        end
        object DetayIptalTus: TToolButton
          Left = 138
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          OnClick = DetayIptalTusClick
        end
      end
      object GridBanka: TcxGrid
        Left = 0
        Top = 25
        Width = 826
        Height = 266
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridBankaDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsDetay
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.FocusCellOnTab = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          object GridBankaDBTableView1ALAN: TcxGridDBColumn
            DataBinding.FieldName = 'ALAN'
            Width = 114
          end
          object GridBankaDBTableView1TUR: TcxGridDBColumn
            DataBinding.FieldName = 'TUR'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                ImageIndex = 0
              end
              item
                Description = 'Tarih'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Yaz'#305
                ImageIndex = 0
                Value = 2
              end
              item
                Description = 'Tamsay'#305
                Value = 3
              end
              item
                Description = 'Kesirli Say'#305
                Value = 4
              end
              item
                Description = 'Para'
                Value = 5
              end
              item
                Description = 'Liste (ini)'
                Value = 11
              end
              item
                Description = 'Rehberden ID Getir'
                Value = 15
              end>
            Width = 87
          end
          object GridBankaDBTableView1ZORUNLU: TcxGridDBColumn
            DataBinding.FieldName = 'ZORUNLU'
          end
          object GridBankaDBTableView1KOLON: TcxGridDBColumn
            DataBinding.FieldName = 'KOLON'
            PropertiesClassName = 'TcxSpinEditProperties'
            Width = 40
          end
          object GridBankaDBTableView1KURAL: TcxGridDBColumn
            DataBinding.FieldName = 'KURAL'
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.Items = <
              item
                ImageIndex = 0
              end
              item
                Description = 'Veri yoksa "Varsay'#305'lan" de'#287'eri kullan'
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Veri yoksa bo'#351' kals'#305'n'
                Value = 2
              end
              item
                Description = 'Veri yoksa ekrandan sorsun'
                Value = 3
              end
              item
                Description = 'Veri yoksa aktar'#305'm dursun'
                Value = 4
              end
              item
                Description = 'Stok Listeden Getir'
                Value = 5
              end>
            Width = 136
          end
          object GridBankaDBTableView1VARSAYILAN: TcxGridDBColumn
            DataBinding.FieldName = 'VARSAYILAN'
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = GridBankaDBTableView1VARSAYILANPropertiesButtonClick
            Width = 148
          end
          object GridBankaDBTableView1ISLEM: TcxGridDBColumn
            DataBinding.FieldName = 'ISLEM'
            Width = 141
          end
        end
        object GridBankaLevel1: TcxGridLevel
          GridView = GridBankaDBTableView1
        end
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'Mesaj'
      ImageIndex = 1
      object Memo1: TcxMemo
        Left = 0
        Top = 0
        Align = alClient
        TabOrder = 0
        Height = 291
        Width = 826
      end
    end
  end
  object DtsImport: TDataSource
    DataSet = TabImport
    OnStateChange = DtsImportStateChange
    Left = 169
    Top = 237
  end
  object TabDetay: TFDQuery
    Connection = Tablo.FDCnn
    OnNewRecord = TabDetayNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from IMPORTDETAY'
      'where IMPORTID = :PID'
      'order by ID')
    Left = 99
    Top = 289
  end
  object DtsDetay: TDataSource
    DataSet = TabDetay
    OnStateChange = DtsDetayStateChange
    Left = 166
    Top = 292
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'xls'
    Left = 606
    Top = 42
  end
  object PmSagClick: TPopupMenu
    Left = 560
    Top = 120
    object lgilieklemekiinExcel1: TMenuItem
      Tag = 4
      Caption = #304'lgili i'#231'in Excel olu'#351'tur'
      OnClick = lgilieklemekiinExcel1Click
    end
    object lgiliyiExcelden1: TMenuItem
      Tag = 4
      Caption = 'Excelden ilgili aktar '
      OnClick = lgiliyiExcelden1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object letiimiinExcelolutur1: TMenuItem
      Tag = 1
      Caption = #304'leti'#351'im i'#231'in Excel olu'#351'tur.'
      OnClick = lgilieklemekiinExcel1Click
    end
    object Exceldeniletiimaktar1: TMenuItem
      Tag = 1
      Caption = 'Excelden ileti'#351'im aktar'
      OnClick = lgiliyiExcelden1Click
    end
    object N2: TMenuItem
      Caption = '-'
      Visible = False
    end
    object Geniniyeekle1: TMenuItem
      Tag = 5
      Caption = 'Geniniye ekle'
      Visible = False
    end
  end
  object TabImport: TFDQuery
    Connection = Tablo.FDCnn
    BeforePost = TabImportBeforePost
    AfterScroll = TabImportAfterScroll
    OnNewRecord = TabImportNewRecord
    ParamData = <>
    SQL.Strings = (
      'select * from IMPORT where ID = :PID')
    Left = 108
    Top = 238
  end
end
