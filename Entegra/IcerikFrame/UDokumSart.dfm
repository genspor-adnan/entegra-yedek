object DokumSartDlg: TDokumSartDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'D'#246'k'#252'm Detaylar'#305
  ClientHeight = 523
  ClientWidth = 1251
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1251
    Height = 98
    Align = alTop
    Font.Charset = TURKISH_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnResize = Panel1Resize
    object Label6: TLabel
      Left = 6
      Top = 45
      Width = 52
      Height = 16
      Alignment = taRightJustify
      Caption = 'Rapor Ad'#305
      FocusControl = EditRAPORADI
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 336
      Top = 43
      Width = 49
      Height = 16
      Alignment = taRightJustify
      Caption = 'A'#231#305'klama'
      FocusControl = EditACIKLAMA
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = Label7Click
    end
    object Label1: TLabel
      Left = 5
      Top = 70
      Width = 36
      Height = 16
      Alignment = taRightJustify
      Caption = 'Grubu '
      FocusControl = EditGRUBU
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 853
      Top = 43
      Width = 22
      Height = 16
      Alignment = taRightJustify
      Caption = 'Ver.'
      FocusControl = EditRAPORKODU
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 337
      Top = 70
      Width = 32
      Height = 16
      Alignment = taRightJustify
      Caption = 'Yaz'#305'c'#305
      FocusControl = EditACIKLAMA
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 737
      Top = 70
      Width = 34
      Height = 16
      Alignment = taRightJustify
      Caption = 'Kopya'
      FocusControl = EditACIKLAMA
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelKopya: TLabel
      Left = 793
      Top = 70
      Width = 6
      Height = 16
      Alignment = taRightJustify
      Caption = '1'
      FocusControl = EditACIKLAMA
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelSektor: TLabel
      Left = 816
      Top = 76
      Width = 87
      Height = 16
      Alignment = taRightJustify
      Caption = 'Sekt'#246'rler Listesi'
      FocusControl = EditSektor
      Font.Charset = TURKISH_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
      OnClick = LabelSektorClick
    end
    object EditRAPORADI: TcxDBTextEdit
      Left = 79
      Top = 40
      DataBinding.DataField = 'RAPORADI'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 2
      Width = 219
    end
    object EditACIKLAMA: TcxDBTextEdit
      Left = 416
      Top = 40
      DataBinding.DataField = 'ACIKLAMA'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 4
      Width = 309
    end
    object EditGRUBU: TcxDBTextEdit
      Left = 79
      Top = 67
      DataBinding.DataField = 'GRUBU'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 3
      Width = 219
    end
    object ToolBar1: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 1243
      Height = 24
      Margins.Bottom = 0
      AutoSize = True
      ButtonWidth = 62
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
      Images = Tablo.PNGImageList2
      List = True
      ParentColor = False
      ParentFont = False
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      object KaydetTus: TToolButton
        Left = 0
        Top = 0
        Caption = 'Kaydet'
        ImageIndex = 2
        Style = tbsTextButton
        OnClick = KaydetTusClick
      end
      object IptalTus: TToolButton
        Left = 62
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 3
        Style = tbsTextButton
        OnClick = IptalTusClick
      end
      object ToolButton6: TToolButton
        Left = 124
        Top = 0
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 19
        Style = tbsSeparator
      end
      object btnKapat: TToolButton
        Left = 132
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 5
        Style = tbsTextButton
        OnClick = btnKapatClick
      end
      object ToolButton2: TToolButton
        Left = 194
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 9
        Style = tbsSeparator
      end
    end
    object EditRAPORKODU: TcxDBTextEdit
      Left = 733
      Top = 40
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 1
      Visible = False
      Width = 73
    end
    object EditYazici: TcxButtonEdit
      Left = 416
      Top = 67
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditYaziciPropertiesButtonClick
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 5
      Text = 'EditYazici'
      Width = 308
    end
    object EditSektor: TcxDBTextEdit
      Left = 903
      Top = 68
      DataBinding.DataField = 'SEKTOR'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 6
      Visible = False
      Width = 309
    end
    object cxDBLabel2: TcxDBLabel
      Left = 903
      Top = 38
      DataBinding.DataField = 'VERSIYON'
      DataBinding.DataSource = DtsDokumler
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Font.Charset = TURKISH_CHARSET
      Style.Font.Color = clNavy
      Style.Font.Height = -13
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      Height = 25
      Width = 51
    end
  end
  object PageControl1: TPageControl
    Images = Tablo.PNGImageList2
    Left = 0
    Top = 98
    Width = 1251
    Height = 425
    ActivePage = TabSheet4
    Align = alClient
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Trebuchet MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object TabSheet4: TTabSheet
      Caption = 'SQL Komutu'
      ImageIndex = 19
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 1243
        Height = 394
        Align = alClient
        Caption = 'SQL Komutu'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object SQLMemo: TDBSynEdit
          Left = 2
          Top = 41
          Width = 1239
          Height = 332
          Cursor = crIBeam
          DataField = 'SQL'
          DataSource = DtsDokumler
          Align = alClient
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          Font.Quality = fqClearTypeNatural
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          Gutter.Font.Charset = TURKISH_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Courier New'
          Gutter.Font.Style = []
          Gutter.Font.Quality = fqClearTypeNatural
          Gutter.ShowLineNumbers = True
          Gutter.Bands = <
            item
              Kind = gbkMarks
              Width = 13
            end
            item
              Kind = gbkLineNumbers
            end
            item
              Kind = gbkFold
            end
            item
              Kind = gbkTrackChanges
            end
            item
              Kind = gbkMargin
              Width = 3
            end>
          Highlighter = SynSQLSyn1
          SelectedColor.Alpha = 0.400000005960464500
          WantTabs = True
        end
        object tbMain: TToolBar
          Left = 2
          Top = 15
          Width = 1239
          Height = 26
          AutoSize = True
          BorderWidth = 1
          Caption = 'Standard'
          Images = ImageList1
          TabOrder = 0
          object tbtnFileOpen: TToolButton
            Left = 0
            Top = 0
            Hint = 'Dosya A'#231
            ImageIndex = 8
            Visible = False
            OnClick = tbtnFileOpenClick
          end
          object tbtnSep1: TToolButton
            Left = 23
            Top = 0
            Width = 8
            ImageIndex = 1
            Style = tbsSeparator
          end
          object tbtnSearch: TToolButton
            Left = 31
            Top = 0
            Hint = 'Bul'
            ImageIndex = 3
            ParentShowHint = False
            ShowHint = True
            OnClick = tbtnSearchClick
          end
          object tbtnSearchReplace: TToolButton
            Left = 54
            Top = 0
            Hint = 'Sonraki'
            ImageIndex = 10
            ParentShowHint = False
            ShowHint = True
            OnClick = tbtnSearchReplaceClick
          end
          object ToolButton7: TToolButton
            Left = 77
            Top = 0
            Hint = #214'nceki'
            ImageIndex = 9
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButton7Click
          end
          object tbtnSep2: TToolButton
            Left = 100
            Top = 0
            Width = 8
            Caption = 'tbtnSep2'
            ImageIndex = 4
            Style = tbsSeparator
          end
          object ToolButton8: TToolButton
            Left = 108
            Top = 0
            Hint = 'Bul De'#287'i'#351'tir'
            ImageIndex = 0
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButton8Click
          end
        end
        object StatusBar: TStatusBar
          Left = 2
          Top = 373
          Width = 1239
          Height = 19
          Panels = <>
        end
      end
    end
    object TabSheetKosullar: TTabSheet
      Caption = 'Ko'#351'ullar'
      ImageIndex = 19
      object ToolBar3: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1237
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
        Images = Tablo.PNGImageList2
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object KosulEkleTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = KosulEkleTusClick
        end
        object KosulSilTus: TToolButton
          Left = 61
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = KosulSilTusClick
        end
        object KosulKaydetTus: TToolButton
          Left = 122
          Top = 0
          Caption = 'Kaydet'
          ImageIndex = 2
          Style = tbsTextButton
          Visible = False
          OnClick = KosulKaydetTusClick
        end
        object KosulIptalTus: TToolButton
          Left = 183
          Top = 0
          Caption = #304'ptal'
          ImageIndex = 3
          Style = tbsTextButton
          Visible = False
          OnClick = KosulIptalTusClick
        end
      end
      object GridKosul: TcxGrid
        Left = 0
        Top = 27
        Width = 1243
        Height = 367
        Align = alClient
        TabOrder = 1
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        object GridKosulDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          DataController.DataSource = DtsKosul
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsSelection.HideSelection = True
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          Styles.Content = cxStyle1
          Styles.Header = cxStyle2
          Styles.Indicator = cxStyle2
          object GridKosulDBTableView1BAGLAC1: TcxGridDBColumn
            DataBinding.FieldName = 'BAGLAC'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxComboBoxProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.DropDownRows = 7
            Properties.Items.Strings = (
              '--'
              'VE'
              'VEYA')
            Properties.ReadOnly = False
            HeaderAlignmentHorz = taCenter
            Styles.Content = cxStyle3
          end
          object GridKosulDBTableView1TABLO1: TcxGridDBColumn
            DataBinding.FieldName = 'TABLO'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Styles.Content = cxStyle4
            Width = 78
          end
          object GridKosulDBTableView1ALAN1: TcxGridDBColumn
            DataBinding.FieldName = 'ALAN'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Styles.Content = cxStyle5
            Width = 84
          end
          object GridKosulDBTableView1KOD_ADI1: TcxGridDBColumn
            DataBinding.FieldName = 'KOD_ADI'
            DataBinding.IsNullValueType = True
            Styles.Content = cxStyle6
            Width = 93
          end
          object GridKosulDBTableView1ACIKLAMA1: TcxGridDBColumn
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Styles.Content = cxStyle7
            Width = 147
          end
          object GridKosulDBTableView1ESITLIK1: TcxGridDBColumn
            DataBinding.FieldName = 'ESITLIK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxComboBoxProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.DropDownRows = 10
            Properties.Items.Strings = (
              'Ba'#351'layan'
              #304#231'inde ge'#231'en'
              '='
              '>'
              '<'
              '<>'
              '>='
              '<='
              'G'#252'n/Ay')
            Properties.ReadOnly = False
            HeaderAlignmentHorz = taCenter
            Styles.Content = cxStyle8
            Width = 66
          end
          object GridKosulDBTableView1DEGER1: TcxGridDBColumn
            DataBinding.FieldName = 'DEGER'
            DataBinding.IsNullValueType = True
            HeaderAlignmentHorz = taCenter
            Styles.Content = cxStyle9
            Width = 180
          end
          object GridKosulDBTableView1ICERIKTURU: TcxGridDBColumn
            Caption = #304#199'ER'#304'K T'#220'R'#220
            DataBinding.FieldName = 'ICERIKTURU'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxImageComboBoxProperties'
            Properties.DropDownRows = 20
            Properties.Items = <
              item
                Description = 'Yaz'#305
                ImageIndex = 0
                Value = 1
              end
              item
                Description = 'Tam Say'#305
                Value = 2
              end
              item
                Description = 'Kesirli Say'#305
                Value = 3
              end
              item
                Description = 'Para'
                Value = 4
              end
              item
                Description = 'Tarih'
                Value = 5
              end
              item
                Description = 'Saat'
                Value = 6
              end
              item
                Description = 'Sabit Liste'
                Value = 7
              end
              item
                Description = 'Sorgu Liste'
                Value = 8
              end
              item
                Description = 'TarihSaat'
                Value = 9
              end
              item
                Description = 'Sabit Liste (img)'
                Value = 10
              end>
            Width = 93
          end
          object GridKosulDBTableView1COMBOICERIK1: TcxGridDBColumn
            DataBinding.FieldName = 'COMBOICERIK'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = GridKosulDBTableView1COMBOICERIK1PropertiesButtonClick
            HeaderAlignmentHorz = taCenter
            Styles.Content = cxStyle10
            Width = 264
          end
        end
        object GridKosulLevel1: TcxGridLevel
          GridView = GridKosulDBTableView1
        end
      end
    end
  end
  object TabAraSQL: TFDQuery
    Connection = Tablo.FDCnn
    Left = 236
    Top = 173
  end
  object ActionList1: TActionList
    Left = 660
    Top = 189
    object SearchFind1: TSearchFind
      Category = 'Search'
      Caption = 'SearchFind1'
      Hint = 'Bul'
      ImageIndex = 34
      ShortCut = 16454
    end
    object SearchFindNext1: TSearchFindNext
      Category = 'Search'
      Caption = 'SearchFindNext1'
      Hint = 'Sonrakini Bul'
      ImageIndex = 33
      ShortCut = 114
    end
    object SearchReplace1: TSearchReplace
      Category = 'Search'
      Caption = 'SearchReplace1'
      Hint = 'De'#287'i'#351'tir'
      ImageIndex = 32
    end
    object SearchFindFirst1: TSearchFindFirst
      Category = 'Search'
      Caption = 'SearchFindFirst1'
      Hint = #214'ncekini Bul'
    end
  end
  object ImageList1: TImageList
    Left = 580
    Top = 474
    Bitmap = {
      494C01010B000D00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD60031B5DE0021AD
      D600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD6009CDEEF0084EF
      FF004AC6E70021ADD60018A5C60018A5C60018A5C60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD60052BDE7009CFF
      FF0094FFFF0073DEF70073DEF70073DEF70073DEF7004AC6E70021ADD60018A5
      C600000000000000000000000000000000000000000000000000000000000000
      0000006B08000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000046F
      0A00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD60052BDE700ADFF
      FF008CF7FF008CEFFF008CEFFF008CEFFF0073DEF70073DEF70073DEF7004AC6
      EF0021ADD600000000000000000000000000000000000000000000000000006B
      0800006B08000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000046F
      0A00046F0A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD60029ADD600ADDE
      EF0094F7FF0094F7FF008CEFFF008CEFFF008CEFFF008CEFFF0073DEF70073DE
      F7004AC6EF000000000000000000000000000000000000000000006B0800089C
      1800006B08000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000046F
      0A000C9A1800046F0A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD60073DEF70029AD
      D6009CFFFF008CF7FF008CF7FF008CF7FF008CEFFF008CEFFF008CEFFF0073DE
      F70073DEF70018A5C600000000000000000000000000006B080018B53100089C
      1800006B0800006B0800006B0800006B0800006B0800006B0800006B08000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000046F0A00046F0A00046F0A00046F0A00046F0A00046F0A00046F
      0A000C9A18001CB03500046F0A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD60094F7FF0029AD
      D600ADDEEF00A5EFF700A5EFF700A5F7FF008CEFFF008CEFFF008CEFFF0073DE
      F7000073080018A5C6000000000000000000006B080042E7730029C6520018B5
      3100089C1800089C1800008C0800008C0800008C0800008C0800006B0800CE63
      0000CE630000CE630000CE630000CE630000CE630000CE630000CE630000CE63
      0000CE630000046F0A0005890C0005890C0005890C0005890C000C9A18000C9A
      18001CB033002DC5510041E07300046F0A000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD6009CFFFF0073DE
      F70029ADD60018A5C60018A5C60018A5C600ADDEEF008CF7FF0084EFFF000073
      08005AE78C000073080018A5C6000000000000000000006B080031CE5A00089C
      1800006B0800006B0800006B0800006B0800006B0800006B0800006B0800FFF7
      E700FFE7C600FFD6AD00FFD6AD00CE630000CE630000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00046F0A00046F0A00046F0A00046F0A00046F0A00046F0A00046F
      0A000C9A180036CB5F00046F0A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD6009CFFFF0094F7
      FF0073DEF70073DEF70073DEF7006BDEF70029ADD600ADDEEF000073080052D6
      7B0042D66B0031C64A0000730800000000000000000000000000006B0800089C
      1800006B08000000000000000000CE630000FFFFFF00FFC68400FFC68400FFC6
      8400FFC68400FFC68400FFD6AD00CE630000CE630000FFFFFF00FFC68400FFC6
      8400FFC68400FFC68400FFC68400FFFFFF00CE6300000000000000000000046F
      0A000C9A1800046F0A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD6009CFFFF0094F7
      FF0094F7FF0094F7FF0094F7FF0073DEF70073DEF70029ADD60018A5C600108C
      210031C64A00109C210018A5C60000000000000000000000000000000000006B
      0800006B08000000000000000000CE630000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFF7E700FFEFD600FFE7C600CE630000CE630000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CE6300000000000000000000046F
      0A00046F0A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000029ADD600C6FFFF0094FF
      FF009CFFFF00D6FFFF00D6FFFF008CEFFF0094EFFF0073DEF70073DEF7000884
      100018AD29000884100000000000000000000000000000000000000000000000
      0000006B08000000000000000000CE630000FFFFFF00FFC68400FFC68400FFC6
      8400FFC68400FFC68400FFEFD600CE630000CE630000FFFFFF00FFC68400FFC6
      8400FFC68400FFC68400FFC68400FFFFFF00CE6300000000000000000000046F
      0A00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021ADD6009CDEEF00C6FF
      FF00C6FFFF009CDEEF0018ADD60018A5C60018A5C60018A5C60018A5C600088C
      100008A518000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CE630000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFF7E700CE630000CE630000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CE63000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000031B5DE0029AD
      D60018A5C60018A5C60000000000000000000000000000000000088C100008A5
      1800088410000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000CE630000CE630000CE630000CE630000CE63
      0000CE630000CE630000CE630000CE630000CE630000CE630000CE630000CE63
      0000CE630000CE630000CE630000CE630000CE63000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000730800087B0800088C1000088C1000087B
      0800000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CE630000CE630000CE630000CE63
      0000CE630000CE630000CE6300000000000000000000CE630000CE630000CE63
      0000CE630000CE630000CE630000CE6300000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000031DE000031DE00000000004A637B00BD9494000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000004A637B00BD9494000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000031DE000031DE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000031DE000031DE00000000006B9CC600188CE7004A7BA500C694
      9400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006B9CC600188CE7004A7BA500C694
      9400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000424242004242420042424200424242000000000000000000000000000000
      000000000000000000000000000000000000000000000031DE000031DE000031
      DE00000000000000000000000000000000000000000000000000000000000000
      00000031DE000031DE0000000000000000004AB5FF0052B5FF00218CEF004A7B
      A500C69494000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000004AB5FF0052B5FF00218CEF004A7B
      A500C69494000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008C636300424242004242
      42008C4A390094521800B55A0000424242008C6363008C6363008C6363008C63
      63008C6363008C6363000000000000000000000000000031DE000031DE000031
      DE000031DE000000000000000000000000000000000000000000000000000031
      DE000031DE000000000000000000000000000000000052B5FF0052B5FF001884
      E7004A7BA500C694940000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000052B5FF0052B5FF001884
      E7004A7BA500C694940000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008C636300B55A0000B55A
      0000AD5A1000B55A0000C65A00004242420008A5180000840000008400000084
      000008A518008C636300000000000000000000000000000000000031EF000031
      DE000031DE000031DE00000000000000000000000000000000000031DE000031
      DE0000000000000000000000000000000000000000000000000052B5FF004AB5
      FF00188CE7004A7BA500BD949400000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000052B5FF004AB5
      FF00188CE7004A7BA500BD949400000000000000000000000000000000000000
      000000000000000000000000000000000000000000008C636300C65A0000C65A
      0000C65A0000C65A0000CE6300004242420031C64A0010AD180010AD180010AD
      1800009C00008C63630000000000000000000000000000000000000000000000
      00000031DE000031DE000031DE00000000000031DE000031DE000031DE000000
      00000000000000000000000000000000000000000000000000000000000052B5
      FF004AB5FF002184DE005A6B730000000000AD7B7300C6A59C00D6B5A500CEA5
      9C000000000000000000000000000000000000000000000000000000000052B5
      FF004AB5FF002184DE005A6B730000000000AD7B7300C6A59C00D6B5A500CEA5
      9C0000000000000000000000000000000000000000008C636300C65A0000CE63
      0000CE630000CE630000CE6300004242420031C64A0021BD310021BD310029C6
      4A0042D66B008C63630000000000000000000000000000000000000000000000
      0000000000000031DE000031E7000031E7000031E7000031DE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000052BDFF00B5D6EF00A5948C00B59C8C00F7E7CE00FFFFD600FFFFD600FFFF
      D600E7DEBD00CEADA50000000000000000000000000000000000000000000000
      000052BDFF00B5D6EF00A5948C00B59C8C00F7E7CE00FFFFD600FFFFD600FFFF
      D600E7DEBD00CEADA5000000000000000000000000008C636300CE630000CE6B
      0000CE6B0000CE6B0000D6730000424242000084000021AD310029BD390031C6
      4A0042D66B008C63630000000000000000000000000000000000000000000000
      000000000000000000000031E7000031E7000031EF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000CEB5B500D6B5A500FFEFC600FFFFD600FFFFD600FFFFD600FFFF
      DE00FFFFEF00F7F7EF00B58C8C00000000000000000000000000000000000000
      000000000000CEB5B500D6B5A500FFEFC600FFFFD600FFFFD600FFFFD600FFFF
      DE00FFFFEF00F7F7EF00B58C8C0000000000000000008C636300CE6B0000CE6B
      0000DE841800FFF7DE00D673000042424200008400000084000000840000009C
      0000009C00008C63630000000000000000000000000000000000000000000000
      0000000000000031DE000031EF000031E7000031EF000031F700000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6948C00F7DEB500F7D6A500FFF7CE00FFFFD600B55A1800FFFF
      EF00FFFFF700FFFFFF00DED6BD00000000000000000000000000000000000000
      000000000000C6948C00F7DEB500F7D6A500FFF7CE00FFFFD600FFFFDE00FFFF
      EF00FFFFF700FFFFFF00DED6BD0000000000000000008C636300D6730000D673
      0000DE7B0800D6730000D673000042424200FFE7C600FFE7C600FFE7C600FFE7
      C600FFE7C6008C63630000000000000000000000000000000000000000000000
      00000031F7000031EF000031E70000000000000000000031F7000031F7000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000DEBDA500FFE7AD00F7CE9400FFF7CE00E7D6C600B55A1800E7D6
      C600E7D6C600FFFFEF00F7EFD600C69C94000000000000000000000000000000
      000000000000DEBDA500FFE7AD00F7CE9400E7D6C600E7D6C600E7D6C600E7D6
      C600E7D6C600FFFFEF00F7EFD600C69C9400000000008C636300D6730000D673
      0000DE7B0000DE7B0000DE7B000042424200FFEFD600FFEFD600FFEFD600FFEF
      D600FFEFD6008C63630000000000000000000000000000000000000000000031
      FF000031EF000031F700000000000000000000000000000000000031FF000031
      F700000000000000000000000000000000000000000000000000000000000000
      000000000000E7C6AD00FFDEAD00EFBD8400B55A1800B55A1800B55A1800B55A
      1800B55A1800FFFFDE00F7F7D600C6AD9C000000000000000000000000000000
      000000000000E7C6AD00FFDEAD00EFBD8400B55A1800B55A1800B55A1800B55A
      1800B55A1800FFFFDE00F7F7D600C6AD9C00000000008C636300DE7B0000E77B
      0000E77B0000E77B0000EF7B000042424200FFF7D600FFF7DE00FFF7DE00FFF7
      DE00FFF7DE008C636300000000000000000000000000000000000031F7000031
      F7000031FF000000000000000000000000000000000000000000000000000031
      F7000031F7000000000000000000000000000000000000000000000000000000
      000000000000DEBDAD00FFE7B500EFBD8400F7CE9400FFEFC600B55A1800FFEF
      C600FFFFDE00FFFFDE00F7EFD600C6A59C000000000000000000000000000000
      000000000000DEBDAD00FFE7B500EFBD8400F7CE9400FFEFC600FFFFDE00FFFF
      DE00FFFFDE00FFFFDE00F7EFD600C6A59C00000000008C636300FF840000F784
      0000EF7B0000EF7B0000EF7B000042424200FFF7D600FFF7D600FFF7D600FFF7
      D600FFF7D6008C6363000000000000000000000000000031F7000031F7000031
      F700000000000000000000000000000000000000000000000000000000000000
      0000000000000031F70000000000000000000000000000000000000000000000
      000000000000C69C9400FFEFC600FFEFC600F7D6A500F7CE9C00B55A1800FFF7
      CE00FFF7D600FFFFD600E7DEBD00000000000000000000000000000000000000
      000000000000C69C9400FFEFC600FFEFC600F7D6A500F7CE9C00F7E7B500FFF7
      CE00FFF7D600FFFFD600E7DEBD0000000000000000008C636300FF840000FF84
      0000F7840800F7840000FF84000042424200FFF7D600FFF7D600FFF7D600FFF7
      D600FFF7D6008C63630000000000000000000031F7000031F7000031F7000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000DEC6AD00FFFFFF00FFF7EF00F7CE9400EFBD8400F7CE
      9C00FFE7B500FFF7C600BD9C8C00000000000000000000000000000000000000
      00000000000000000000DEC6AD00FFFFFF00FFF7EF00F7CE9400EFBD8400F7CE
      9C00FFE7B500FFF7C600BD9C8C000000000000000000000000008C6363008C63
      6300DE732900E77B1800FF840000424242008484840084848400848484008484
      8400848484008484840000000000000000000031F7000031F700000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D6BDBD00F7EFD600FFEFC600FFE7AD00FFE7
      B500F7DEB500CEAD9C0000000000000000000000000000000000000000000000
      0000000000000000000000000000D6BDBD00F7EFD600FFEFC600FFE7AD00FFE7
      B500F7DEB500CEAD9C0000000000000000000000000000000000000000000000
      00008C6363008C6363008C636300424242000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CEAD9400CEAD9C00DEBDA500DEBD
      A500000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CEAD9400CEAD9C00DEBDA500DEBD
      A500000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000004A637B00BD9494000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000001094100039AD390000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000039AD39001094100000000000000000000000
      000000000000000000000000000000000000000000004A637B00BD9494000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006B9CC600188CE7004A7BA500C694
      9400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000AD0000218C180039AD3900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000039AD3900218C180000AD000000000000000000000000
      0000000000000000000000000000000000006B9CC600188CE7004A7BA500C694
      9400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000004AB5FF0052B5FF00218CEF004A7B
      A500C69494000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000009C0000219C18001884180039AD39000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000039AD390018841800219C1800009C000000000000000000000000
      0000000000000000000000000000000000004AB5FF0052B5FF00218CEF004A7B
      A500C69494000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000052B5FF0052B5FF001884
      E7004A7BA500C694940000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000009C0000088C000008840000088C100039AD
      3900000000000000000000000000000000000000000000000000000000000000
      000039AD3900088C100008840000088C0000009C000000000000000000000000
      0000000000000000000000000000000000000000000052B5FF0052B5FF001884
      E7004A7BA500C694940000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000052B5FF004AB5
      FF00188CE7004A7BA500BD949400000000000000000000000000000000000000
      00000000000000000000000000000000000000AD00006BDE6B0052E7520042DE
      420018C6180000B5080000B50000088C0800008C00002194210063AD6300107B
      100039AD390000000000000000000000000000000000000000000000000039AD
      3900107B100063AD630021942100008C0000088C080000B5000000B5080018C6
      180042DE420052E752006BDE6B0000AD0000000000000000000052B5FF004AB5
      FF00188CE7004A7BA500BD949400000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000052B5
      FF004AB5FF002184DE005A6B7300004A0000004A0000004A0000005A0000004A
      000000000000000000000000000000000000009C080063E7630018D6180008C6
      000000BD000000B5000000A50000008C0000008C080000840000218C180063AD
      6300187B180039AD39000000000000000000000000000000000039AD3900187B
      180063AD6300218C180000840000008C0800008C000000A5000000B5000000BD
      000008C6000018D6180063E76300009C080000000000000000000000000052B5
      FF004AB5FF002184DE005A6B730000000000AD7B7300C6A59C00D6B5A500CEA5
      9C00000000000000000000000000000000000000000000000000000000000000
      000052BDFF00B5D6EF00185A210042632900315A1800295A1000087310000873
      100021521000CEADA50000000000000000001094080063E7630000CE000000C6
      000000BD000000B5000000AD0000009C0000008C080000840000007B0000187B
      210063AD6300187B180039AD3900000000000000000039AD3900187B180063AD
      6300187B2100007B000000840000008C0800009C000000AD000000B5000000BD
      000000C6000000CE000063E76300109408000000000000000000000000000000
      000052BDFF00B5D6EF00A5948C00B59C8C00F7E7CE00FFFFD600FFFFD600FFFF
      D600E7DEBD00CEADA50000000000000000000000000000000000000000000000
      000000000000CEB5B500D6B5A500FFEFC600FFFFD600FFFFD6001863100018BD
      4A00006B080073734200B58C8C000000000000A5000063E76B0000CE000008C6
      000000BD000000B5000000AD000000940000008C08000084000000840000007B
      0000298C310063AD6300187B210039AD390039AD3900187B210063AD6300298C
      3100007B00000084000000840000008C08000094000000AD000000B5000000BD
      000008C6000000CE000063E76B0000A500000000000000000000000000000000
      000000000000CEB5B500D6B5A500FFEFC600FFFFD600FFFFD600FFFFD600FFFF
      DE00FFFFEF00F7F7EF00B58C8C0000000000000000000000000000000000004A
      0000004A0000C6948C00F7DEB500F7D6A500FFF7CE00FFFFD600639C5A0018AD
      390018AD390052733100DED6BD0000000000089C00006BE76B0000CE000008C6
      000000BD000000B5000000AD000000940800008C080000840000007B00000073
      0000398C310063AD63001873290039AD390039AD39001873290063AD6300398C
      310000730000007B000000840000008C08000094080000AD000000B5000000BD
      000008C6000000CE00006BE76B00089C00000000000000000000000000000000
      000000000000C6948C00F7DEB500F7D6A500FFF7CE00FFFFD600FFFFDE00FFFF
      EF00FFFFF700FFFFFF00DED6BD00000000000000000000000000004A0000186B
      1800005A080039632100FFE7AD00F7CE9400004A0000004A0000006B080029C6
      520029CE5A0008731000004A0000004A0000009C000063E7630000CE000008C6
      000000BD000000B5000000A50000009400000094000000840000087B08002984
      180063AD6300187B210039AD3900000000000000000039AD3900187B210063AD
      630029841800087B080000840000009400000094000000A5000000B5000000BD
      000008C6000000CE000063E76300009C00000000000000000000000000000000
      000000000000DEBDA500FFE7AD00F7CE9400FFF7CE00FFFFDE00FFFFE700FFFF
      F700FFFFF700FFFFEF00F7EFD600C69C940000000000000000000052080021B5
      420021B5420010631800528C3900EFBD8400528C3900218C42001094290042EF
      730031E76B001084210039632100C6AD9C00009408006BEF630018D6180008C6
      000000BD000000B5000000AD080008940000008C000000840000108C180063AD
      6300107B180039AD39000000000000000000000000000000000039AD3900107B
      180063AD6300108C180000840000008C00000894000000AD080000B5000000BD
      000008C6000018D618006BEF6300009408000000000000000000000000000000
      000000000000E7C6AD00FFDEAD00EFBD8400F7E7B500FFFFD600FFFFDE00FFFF
      E700FFFFE700FFFFDE00F7F7D600C6AD9C0000000000004A00001084210031E7
      6B0042EF730010942900218C4200528C3900F7CE9400529442001063180021B5
      420021B54200186B2900F7EFD600C6A59C0000AD00007BDE7B005AE75A0042DE
      420018C6180000B5080000AD000000940000009400001894210063AD6300107B
      100039AD390000000000000000000000000000000000000000000000000039AD
      3900107B100063AD630018942100009400000094000000AD000000B5080018C6
      180042DE42005AE75A007BDE7B0000AD00000000000000000000000000000000
      000000000000DEBDAD00FFE7B500EFBD8400F7CE9400FFEFC600FFFFDE00FFFF
      DE00FFFFDE00FFFFDE00F7EFD600C6A59C00004A0000004A00000873100029CE
      5A0029C65200006B0800004A0000004A0000F7D6A500F7CE9C00528C3900005A
      0800186B18004A7B3100E7DEBD00000000000000000000000000000000000000
      0000000000000000000000000000009C0000008C000008840000088C100039AD
      3900000000000000000000000000000000000000000000000000000000000000
      000039AD3900088C100008840000008C0000009C000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C69C9400FFEFC600FFEFC600F7D6A500F7CE9C00F7E7B500FFF7
      CE00FFF7D600FFFFD600E7DEBD00000000000000000000000000004A000018AD
      390018AD3900295A1800DEC6AD00FFFFFF00FFF7EF00F7CE9400EFBD84006394
      4200639C4A00FFF7C600BD9C8C00000000000000000000000000000000000000
      00000000000000000000000000001094080018941800188C180039AD39000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000039AD3900188C1800189418001094080000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000DEC6AD00FFFFFF00FFF7EF00F7CE9400EFBD8400F7CE
      9C00FFE7B500FFF7C600BD9C8C00000000000000000000000000004A0000006B
      080018BD4A00004A000000000000D6BDBD00F7EFD600FFEFC600FFE7AD00FFE7
      B500F7DEB500CEAD9C0000000000000000000000000000000000000000000000
      0000000000000000000000000000009C00001894180039AD3900000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000039AD390018941800009C000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D6BDBD00F7EFD600FFEFC600FFE7AD00FFE7
      B500F7DEB500CEAD9C000000000000000000000000000000000000000000004A
      00000873100008731000004A0000185208004A63290039632100DEBDA500DEBD
      A500000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000002194210039AD390000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000039AD39002194210000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CEAD9400CEAD9C00DEBDA500DEBD
      A50000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFFFFF00008FFFFFFFFFFF0000
      807FFFFFFFFF0000800FF7FFFFEF00008007E7FFFFE700008007C7FFFFE30000
      8003801FF8010000800300000000000080018000000100008001C60000630000
      8001E600006700008003F600006F00008007FE00007F0000C3C7FE00007F0000
      FE0FFF0180FF0000FFFFFFFFFFFF0000FFFC9FFF9FFFFFFF9FF90FFF0FFFF0FF
      8FF307FF07FF800387E783FF83FF8003C3CFC1FFC1FF8003F11FE10FE10F8003
      F83FF003F0038003FC7FF801F8018003F83FF801F8018003F19FF800F8008003
      E3CFF800F8008003C7E7F800F80080038FFBF801F80180031FFFFC01FC01C003
      3FFFFE03FE03F0FFFFFFFF0FFF0FFFFF9FFFFE7FFE7F9FFF0FFFFE3FFC7F0FFF
      07FFFE1FF87F07FF83FFFE0FF07F83FFC1FF0007E000C1FFE00F0003C000E10F
      F00300018000F003F80100000000F801E00100000000F801C00000018000F800
      C0000003C000F80080000007E000F8000001FE0FF07FF801C001FE1FF87FFC01
      C203FE3FFC7FFE03E00FFE7FFE7FFF0F00000000000000000000000000000000
      000000000000}
  end
  object SynSQLSyn1: TSynSQLSyn
    KeyAttri.Foreground = clBlue
    StringAttri.Foreground = clRed
    TableNameAttri.Foreground = clPurple
    SQLDialect = sqlMSSQL2K
    Left = 34
    Top = 208
  end
  object dlgFileOpen: TOpenDialog
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 364
    Top = 240
  end
  object SynEditSearch: TSynEditSearch
    Left = 25
    Top = 261
  end
  object SynEditRegexSearch: TSynEditRegexSearch
    Left = 28
    Top = 318
  end
  object DtsKosul: TDataSource
    OnStateChange = DtsKosulStateChange
    Left = 292
    Top = 266
  end
  object DtsDokumler: TDataSource
    OnStateChange = DtsDokumlerStateChange
    Left = 290
    Top = 206
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 67
    Top = 152
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWindow
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWhite
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clWindowText
    end
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <>
    StorageName = 'cxPropertiesStore1'
    Left = 536
    Top = 204
  end
end
