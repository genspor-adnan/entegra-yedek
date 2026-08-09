object IsEmriPersonelZamanDlg: TIsEmriPersonelZamanDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #304#351' Emri Zaman Personel'
  ClientHeight = 511
  ClientWidth = 957
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object ServisHarPanelAlt: TPanel
    Left = 0
    Top = 475
    Width = 957
    Height = 36
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      957
      36)
    object KaydetTus: TBitBtn
      Left = 730
      Top = 6
      Width = 72
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Uygula'
      Default = True
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000D30E0000D30E00000001000000010000008C00000094
        0000009C000000A5000000940800009C100000AD100000AD180000AD210000B5
        210000BD210018B5290000C62900319C310000CE310029AD390031B5420018C6
        420000D6420052A54A0029AD4A0029CE5A006BB5630000FF63008CBD7B00A5C6
        94005AE7A500FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF001B1B1B1B1B13
        04161B1B1B1B1B1B1B1B1B1B1B1B1B0B0A01181B1B1B1B1B1B1B1B1B1B1B160A
        0C030D1B1B1B1B1B1B1B1B1B1B1B050E0C0601191B1B1B1B1B1B1B1B1B130E0C
        170E02001B1B1B1B1B1B1B1B1B0B1517170A0C01181B1B1B1B1B1B1B1B111717
        13130C030D1B1B1B1B1B1B1B1B1B08081B1B070C01191B1B1B1B1B1B1B1B1B1B
        1B1B100C02001B1B1B1B1B1B1B1B1B1B1B1B1B090C01181B1B1B1B1B1B1B1B1B
        1B1B1B130C0F101B1B1B1B1B1B1B1B1B1B1B1B1B141A0F181B1B1B1B1B1B1B1B
        1B1B1B1B1012181B1B1B1B1B1B1B1B1B1B1B1B1B1B191B1B1B1B1B1B1B1B1B1B
        1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B1B}
      TabOrder = 0
      OnClick = KaydetTusClick
    end
    object IptalTus: TBitBtn
      Left = 808
      Top = 6
      Width = 62
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Kapa&t'
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
      ModalResult = 2
      TabOrder = 1
      OnClick = IptalTusClick
    end
  end
  object PageControlUst: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 957
    Height = 475
    Align = alClient
    TabOrder = 1
    Properties.ActivePage = TabSheetCalisma
    Properties.CustomButtons.Buttons = <>
    OnChange = PageControlUstChange
    ClientRectBottom = 471
    ClientRectLeft = 4
    ClientRectRight = 953
    ClientRectTop = 24
    object TabSheetCalisma: TcxTabSheet
      Caption = #199'al'#305#351'ma'
      ImageIndex = 19
      object GroupDetay: TcxGroupBox
        Left = 169
        Top = 0
        Align = alClient
        Caption = 'Detay'
        TabOrder = 0
        Height = 447
        Width = 780
        object Panel2: TPanel
          Left = 2
          Top = 18
          Width = 776
          Height = 171
          Align = alTop
          BevelEdges = []
          BevelOuter = bvNone
          TabOrder = 0
          DesignSize = (
            776
            171)
          object cxLabel1: TcxLabel
            Left = 4
            Top = 31
            Caption = 'Konusu'
          end
          object cxLabel3: TcxLabel
            Left = 4
            Top = 54
            Caption = 'Sorumlu'
          end
          object EditKonusu: TcxDBButtonEdit
            Left = 58
            Top = 29
            Anchors = [akLeft, akTop, akRight]
            DataBinding.DataField = 'KONUSU'
            DataBinding.DataSource = DtsUretimOperasyonPersonel
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = EditKonusuPropertiesButtonClick
            TabOrder = 2
            Width = 718
          end
          object EditPersonel: TcxButtonEdit
            Left = 58
            Top = 53
            Anchors = [akLeft, akTop, akRight]
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = EditPersonelPropertiesButtonClick
            ShowHint = True
            TabOrder = 3
            TextHint = 'KABUL_EDEN'
            Width = 718
          end
          object EditLokasyon: TcxButtonEdit
            Left = 58
            Top = 77
            Anchors = [akLeft, akTop, akRight]
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = cxButtonEdit1PropertiesButtonClick
            ShowHint = True
            TabOrder = 4
            TextHint = 'KABUL_EDEN'
            Width = 718
          end
          object cxLabel5: TcxLabel
            Left = 4
            Top = 78
            Caption = 'Lokasyon'
          end
          object EditKaynak: TcxButtonEdit
            Left = 58
            Top = 101
            Anchors = [akLeft, akTop, akRight]
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = cxButtonEdit2PropertiesButtonClick
            ShowHint = True
            TabOrder = 6
            TextHint = 'KABUL_EDEN'
            Width = 718
          end
          object cxLabel7: TcxLabel
            Left = 4
            Top = 102
            Caption = 'Kaynak'
          end
          object cxLabel9: TcxLabel
            Left = 4
            Top = 8
            Caption = 'Durum'
          end
          object cxDBImageComboBox1: TcxDBImageComboBox
            Left = 58
            Top = 5
            DataBinding.DataField = 'DURUM'
            DataBinding.DataSource = DtsUretimOperasyonPersonel
            Properties.Items = <
              item
                Description = 'Bekliyor'
                ImageIndex = 0
                Value = 0
              end
              item
                Description = #199'al'#305#351#305'l'#305'yor'
                Value = 1
              end
              item
                Description = 'Tamamland'#305
                Value = 9
              end>
            TabOrder = 9
            Width = 142
          end
          object cxLabel10: TcxLabel
            Left = 4
            Top = 125
            Caption = 'A'#231#305'klama'
          end
          object EditACIKLAMA: TcxDBMemo
            Left = 58
            Top = 126
            Anchors = [akLeft, akTop, akRight]
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsUretimOperasyonPersonel
            Properties.Alignment = taLeftJustify
            Properties.ScrollBars = ssVertical
            TabOrder = 11
            Height = 42
            Width = 719
          end
        end
        object EkAlanlarCalisma: TPanel
          Left = 2
          Top = 189
          Width = 776
          Height = 256
          Align = alClient
          BevelEdges = []
          BevelOuter = bvNone
          TabOrder = 1
        end
      end
      object GrpBaslama: TcxGroupBox
        Left = 0
        Top = 0
        Align = alLeft
        Caption = 'Zaman'
        TabOrder = 1
        Height = 447
        Width = 169
        object cxLabel2: TcxLabel
          Left = 8
          Top = 35
          Caption = 'Ba'#351'lama   -->'
        end
        object TimeBASLA: TcxDBTimeEdit
          Left = 95
          Top = 54
          DataBinding.DataField = 'BASLAMA'
          DataBinding.DataSource = DtsUretimOperasyonPersonel
          Properties.TimeFormat = tfHourMin
          TabOrder = 1
          Width = 70
        end
        object TimeBITIS: TcxDBTimeEdit
          Left = 95
          Top = 100
          DataBinding.DataField = 'BITIS'
          DataBinding.DataSource = DtsUretimOperasyonPersonel
          Properties.TimeFormat = tfHourMin
          TabOrder = 2
          Width = 70
        end
        object cxLabel6: TcxLabel
          Left = 8
          Top = 81
          Caption = 'Biti'#351'     X'
        end
        object cxLabel4: TcxLabel
          Left = 8
          Top = 127
          Caption = 'Mola'
        end
        object TimeMOLA: TcxDBTimeEdit
          Left = 8
          Top = 145
          DataBinding.DataField = 'MOLA'
          DataBinding.DataSource = DtsUretimOperasyonPersonel
          Properties.TimeFormat = tfHourMin
          TabOrder = 5
          Width = 80
        end
        object DateBASLA: TcxDBDateEdit
          Left = 8
          Top = 54
          DataBinding.DataField = 'BASLAMA'
          DataBinding.DataSource = DtsUretimOperasyonPersonel
          TabOrder = 6
          Width = 80
        end
        object DateBITIS: TcxDBDateEdit
          Left = 8
          Top = 100
          DataBinding.DataField = 'BITIS'
          DataBinding.DataSource = DtsUretimOperasyonPersonel
          TabOrder = 7
          Width = 80
        end
      end
    end
    object TabSheetOlcum: TcxTabSheet
      Caption = #214'l'#231#252'm'
      ImageIndex = 19
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 337
        Height = 447
        Align = alLeft
        TabOrder = 0
        object PanelBaslik: TPanel
          Left = 1
          Top = 1
          Width = 335
          Height = 18
          Align = alTop
          Caption = #214'l'#231#252'len Zamanlar'
          TabOrder = 0
        end
        object cxGrid1: TcxGrid
          Left = 1
          Top = 19
          Width = 335
          Height = 427
          Align = alClient
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          LookAndFeel.ScrollbarMode = sbmClassic
          object cxGridDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsOlcum
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsView.GroupByBox = False
            Styles.ContentEven = Tablo.cxstSecili
            Styles.ContentOdd = Tablo.cxStyle1
            object cxGridDBColumn1: TcxGridDBColumn
              DataBinding.FieldName = 'ID'
              Visible = False
            end
            object cxGridDBTableViewTARIH: TcxGridDBColumn
              Caption = 'Tarih'
              DataBinding.FieldName = 'TARIH'
              PropertiesClassName = 'TcxDateEditProperties'
              Properties.Kind = ckDateTime
              Width = 105
            end
            object cxGridDBTableView1DURUM: TcxGridDBColumn
              Caption = 'Durum'
              DataBinding.FieldName = 'DURUM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList2
              Properties.Items = <
                item
                  ImageIndex = 26
                  Value = 0
                end
                item
                  ImageIndex = 15
                  Value = 1
                end
                item
                  ImageIndex = 25
                  Value = 9
                end>
              Width = 42
            end
            object cxGridDBTableView1ALARM: TcxGridDBColumn
              Caption = 'Alarm'
              DataBinding.FieldName = 'ALARM'
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.PNGImageList2
              Properties.Items = <
                item
                  ImageIndex = 27
                  Value = 0
                end
                item
                  ImageIndex = 23
                  Value = 1
                end
                item
                  ImageIndex = 24
                  Value = 2
                end>
              Width = 40
            end
            object cxGridDBTableView1KONUSU: TcxGridDBColumn
              Caption = 'Konusu'
              DataBinding.FieldName = 'KONUSU'
            end
          end
          object cxGridLevel2: TcxGridLevel
            GridView = cxGridDBTableView1
          end
        end
      end
      object cxGroupBox1: TcxGroupBox
        Left = 337
        Top = 0
        Align = alClient
        Caption = 'Bilgiler'
        TabOrder = 1
        Height = 447
        Width = 612
        object Panel3: TPanel
          Left = 2
          Top = 249
          Width = 608
          Height = 196
          Align = alClient
          TabOrder = 0
          object GridOlcumDetay: TcxGrid
            Left = 1
            Top = 28
            Width = 606
            Height = 167
            Align = alClient
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            PopupMenu = PopupMenuOlcum
            TabOrder = 0
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridOlcumDetayView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridOlcumDetayViewCanFocusRecord
              DataController.DataSource = DtsOlcumDetay
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsView.GroupByBox = False
              object GridOlcumDetayViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
                Options.Editing = False
              end
              object GridOlcumDetayViewKALITESABLONID: TcxGridDBColumn
                DataBinding.FieldName = 'KALITESABLONID'
                DataBinding.IsNullValueType = True
                Visible = False
                Options.Editing = False
                Width = 99
              end
              object GridOlcumDetayViewADI: TcxGridDBColumn
                Caption = 'Test'
                DataBinding.FieldName = 'ADI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Options.Editing = False
                Width = 106
              end
              object GridOlcumDetayViewNOMINAL: TcxGridDBColumn
                Caption = 'Nominal'
                DataBinding.FieldName = 'NOMINAL'
                DataBinding.IsNullValueType = True
                Options.Editing = False
              end
              object GridOlcumDetayViewLIMITYAZI: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'LIMITYAZI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Width = 76
              end
              object GridOlcumDetayViewDEGERI: TcxGridDBColumn
                Caption = #214'l'#231#252'len'
                DataBinding.FieldName = 'DEGERI'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.cxEditRepo_GenParasal
                OnGetPropertiesForEdit = GridOlcumDetayViewDEGERIGetPropertiesForEdit
                Width = 59
              end
              object GridOlcumDetayViewSAPMA: TcxGridDBColumn
                Caption = 'Sapma'
                DataBinding.FieldName = 'SAPMA'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.cxEditRepo_GenParasal
                OnGetPropertiesForEdit = GridOlcumDetayViewSAPMAGetPropertiesForEdit
                Width = 64
              end
              object GridOlcumDetayViewTOLERANSDEGERI: TcxGridDBColumn
                Caption = 'Tolerans'
                DataBinding.FieldName = 'TOLERANS'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 76
              end
              object GridOlcumDetayViewBIRIM: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.repStokAnaBirim
                Options.Editing = False
              end
              object GridOlcumDetayViewOLCUALETI: TcxGridDBColumn
                Caption = #214'l'#231#252' Aleti'
                DataBinding.FieldName = 'OLCUALETI'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepKaliteOlcuAleti
                Width = 68
              end
              object GridOlcumDetayViewTESTID: TcxGridDBColumn
                DataBinding.FieldName = 'TESTID'
                DataBinding.IsNullValueType = True
                Visible = False
                Options.Editing = False
              end
              object GridOlcumDetayViewALARM: TcxGridDBColumn
                Caption = 'Alarm'
                DataBinding.FieldName = 'ALARM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Images = Tablo.PNGImageList2
                Properties.Items = <
                  item
                    ImageIndex = 24
                    Value = 2
                  end
                  item
                    ImageIndex = 23
                    Value = 1
                  end
                  item
                    Value = 0
                  end>
                Properties.ReadOnly = True
                Options.Editing = False
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = GridOlcumDetayView
            end
          end
          object ToolBar1: TToolBar
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 600
            Height = 24
            Margins.Bottom = 0
            Anchors = [akLeft]
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
            TabOrder = 1
            Transparent = True
            object OlcumDetayYeni: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              Visible = False
            end
            object OlcumDetaySil: TToolButton
              Left = 61
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              Visible = False
            end
            object OlcumDetayKaydet: TToolButton
              Left = 122
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
            end
            object OlcumDetayIptal: TToolButton
              Left = 183
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
            end
          end
        end
        object Panel4: TPanel
          Left = 2
          Top = 18
          Width = 608
          Height = 231
          Align = alTop
          Caption = #214'l'#231#252'len Zamanlar'
          TabOrder = 1
          DesignSize = (
            608
            231)
          object ToolBarSol: TToolBar
            Left = 1
            Top = 1
            Width = 606
            Height = 22
            Margins.Bottom = 0
            AutoSize = True
            ButtonWidth = 62
            Caption = 'AletCubugu'
            Color = clTeal
            Ctl3D = False
            DockSite = True
            DrawingStyle = dsGradient
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
            object OlcumEkleBtn: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = OlcumEkleBtnClick
            end
            object OlcumSilBtn: TToolButton
              Left = 62
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = OlcumSilBtnClick
            end
            object OlcumKaydetBtn: TToolButton
              Left = 124
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              OnClick = OlcumKaydetBtnClick
            end
            object OlcumIptalBtn: TToolButton
              Left = 186
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              OnClick = OlcumIptalBtnClick
            end
          end
          object cxLabel12: TcxLabel
            Left = 3
            Top = 53
            Caption = 'Konusu'
          end
          object cxLabel13: TcxLabel
            Left = 3
            Top = 76
            Caption = #214'l'#231#252'm Sorumlu'
          end
          object EditOlcumKonusu: TcxDBButtonEdit
            Left = 95
            Top = 51
            Anchors = [akLeft, akTop, akRight]
            DataBinding.DataField = 'KONUSU'
            DataBinding.DataSource = DtsOlcum
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.OnButtonClick = EditOlcumKonusuPropertiesButtonClick
            TabOrder = 3
            Width = 505
          end
          object EditOlcumSorumlu: TcxButtonEdit
            Left = 95
            Top = 75
            Anchors = [akLeft, akTop, akRight]
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = EditOlcumSorumluPropertiesButtonClick
            ShowHint = True
            TabOrder = 4
            TextHint = 'KABUL_EDEN'
            Width = 505
          end
          object EditOlcumLokasyon: TcxButtonEdit
            Left = 95
            Top = 100
            Anchors = [akLeft, akTop, akRight]
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = EditOlcumLokasyonPropertiesButtonClick
            ShowHint = True
            TabOrder = 5
            TextHint = 'KABUL_EDEN'
            Width = 505
          end
          object cxLabel14: TcxLabel
            Left = 3
            Top = 103
            Caption = 'Lokasyon'
          end
          object EditOlcumKaynak: TcxButtonEdit
            Left = 95
            Top = 126
            Anchors = [akLeft, akTop, akRight]
            ParentShowHint = False
            Properties.Buttons = <
              item
                Default = True
                Kind = bkEllipsis
              end>
            Properties.MaxLength = 0
            Properties.ReadOnly = True
            Properties.OnButtonClick = EditOlcumKaynakPropertiesButtonClick
            ShowHint = True
            TabOrder = 7
            TextHint = 'KABUL_EDEN'
            Width = 505
          end
          object cxLabel15: TcxLabel
            Left = 3
            Top = 127
            Caption = 'Kaynak'
          end
          object cxLabel16: TcxLabel
            Left = 3
            Top = 154
            Caption = 'Miktar'
          end
          object EditADET: TcxDBTextEdit
            Left = 96
            Top = 153
            DataBinding.DataField = 'ADET'
            DataBinding.DataSource = DtsOlcum
            TabOrder = 10
            Width = 70
          end
          object ComboBIRIM: TcxDBImageComboBox
            Left = 172
            Top = 153
            RepositoryItem = Tablo.repStokAnaBirim
            DataBinding.DataField = 'BIRIM'
            DataBinding.DataSource = DtsOlcum
            Properties.Items = <>
            TabOrder = 11
            Width = 71
          end
          object cxLabel18: TcxLabel
            Left = 3
            Top = 181
            Caption = 'A'#231#305'klama'
          end
          object cxDBTextEdit3: TcxDBTextEdit
            Left = 96
            Top = 180
            DataBinding.DataField = 'ACIKLAMA'
            DataBinding.DataSource = DtsOlcum
            TabOrder = 13
            Width = 538
          end
          object cxLabel17: TcxLabel
            Left = 2
            Top = 30
            Caption = 'Zaman'#305
          end
          object cxDBDateEdit1: TcxDBDateEdit
            Left = 95
            Top = 26
            DataBinding.DataField = 'TARIH'
            DataBinding.DataSource = DtsOlcum
            Properties.SaveTime = False
            Properties.ShowTime = False
            TabOrder = 15
            Width = 80
          end
          object cxDBTimeEdit1: TcxDBTimeEdit
            Left = 182
            Top = 26
            DataBinding.DataField = 'TARIH'
            DataBinding.DataSource = DtsOlcum
            Properties.TimeFormat = tfHourMin
            TabOrder = 16
            Width = 70
          end
          object ComboDURUM: TcxDBImageComboBox
            Left = 526
            Top = 26
            DataBinding.DataField = 'DURUM'
            DataBinding.DataSource = DtsOlcum
            Properties.Images = Tablo.PNGImageList2
            Properties.Items = <
              item
                Description = 'Bekliyor'
                ImageIndex = 26
                Value = 0
              end
              item
                Description = #199'al'#305#351#305'l'#305'yor'
                ImageIndex = 15
                Value = 1
              end
              item
                Description = 'Tamamland'#305
                ImageIndex = 25
                Value = 9
              end>
            TabOrder = 17
            Width = 113
          end
          object cxLabel11: TcxLabel
            Left = 487
            Top = 27
            Caption = 'Durum'
          end
        end
      end
    end
    object TabSheetEkAlan111: TcxTabSheet
      Caption = 'Ek Alan1'
      ImageIndex = 19
      object TabSheetEkAlan1: TPanel
        Left = 0
        Top = 0
        Width = 949
        Height = 447
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
      end
    end
    object TabSheetEkAlan222: TcxTabSheet
      Caption = 'Ek Alan 2'
      ImageIndex = 19
      object TabSheetEkAlan2: TPanel
        Left = 0
        Top = 0
        Width = 949
        Height = 447
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
      end
    end
  end
  object DtsUretimOperasyonPersonel: TDataSource
    DataSet = TabUretimOperasyonPersonel
    Left = 461
    Top = 333
  end
  object TabUretimOperasyonPersonel: TFDQuery
    BeforeEdit = TabUretimOperasyonPersonelBeforeEdit
    BeforePost = TabUretimOperasyonPersonelBeforePost
    OnNewRecord = TabUretimOperasyonPersonelNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      'UO.*,'
      '----SURE=[dbo].[fn_TarihFarkiFormatli]( BASLAMA, BITIS ),'
      
        'SORUMLUADI=(select R.FIRMA from REHBER R where UO.PERSONEL=R.ID)' +
        ','
      
        'LOKASYONADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.LOKASY' +
        'ON=L1.ID),'
      
        'KAYNAKADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.KAYNAK=L' +
        '1.ID)'
      'from URETIMOPERASYONPERSONEL UO '
      'where UO.ID=:PRM1'
      '')
    Left = 405
    Top = 45
  end
  object TabOlcum: TFDQuery
    AfterPost = TabOlcumAfterPost
    BeforeDelete = TabOlcumBeforeDelete
    AfterScroll = TabOlcumAfterScroll
    OnNewRecord = TabOlcumNewRecord
    Connection = Tablo.FDCnn
    UpdateOptions.UpdateTableName = 'URETIMOLCUM'
    UpdateOptions.KeyFields = 'ID'
    UpdateOptions.AutoIncFields = 'ID'
    SQL.Strings = (
      'select '
      'ALARM = (select'
      
        'case when exists (select ALARM from URETIMOLCUMDETAY UOD where U' +
        'RETIMOLCUMID=UO.ID and isnull(ALARM,0)=0 )  then 0'
      
        ' when exists (select ALARM from URETIMOLCUMDETAY UOD where URETI' +
        'MOLCUMID=UO.ID and ALARM=2 )  then 2'
      'else 1 end),'
      'UO.*,'
      
        'SORUMLUADI=(select R.FIRMA from REHBER R where UO.PERSONEL=R.ID)' +
        ','
      
        'LOKASYONADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.LOKASY' +
        'ON=L1.ID),'
      
        'KAYNAKADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.KAYNAK=L' +
        '1.ID)'
      'from URETIMOLCUM UO '
      'where UO.OPERASYONPERSONELID = :PRM1'
      'order by UO.TARIH')
    Left = 629
    Top = 117
    object TabOlcumID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabOlcumOPERASYONID: TIntegerField
      FieldName = 'OPERASYONID'
    end
    object TabOlcumOPERASYONPERSONELID: TIntegerField
      FieldName = 'OPERASYONPERSONELID'
    end
    object TabOlcumTARIH: TSQLTimeStampField
      FieldName = 'TARIH'
    end
    object TabOlcumKONUSU: TWideStringField
      FieldName = 'KONUSU'
      Size = 100
    end
    object TabOlcumPERSONEL: TIntegerField
      FieldName = 'PERSONEL'
    end
    object TabOlcumLOKASYON: TIntegerField
      FieldName = 'LOKASYON'
    end
    object TabOlcumKAYNAK: TIntegerField
      FieldName = 'KAYNAK'
    end
    object TabOlcumADET: TFloatField
      FieldName = 'ADET'
    end
    object TabOlcumBIRIM: TIntegerField
      FieldName = 'BIRIM'
    end
    object TabOlcumACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 120
    end
    object TabOlcumEKLEYEN: TSmallintField
      FieldName = 'EKLEYEN'
    end
    object TabOlcumEKLEMETARIHI: TSQLTimeStampField
      FieldName = 'EKLEMETARIHI'
    end
    object TabOlcumDEGISTIREN: TSmallintField
      FieldName = 'DEGISTIREN'
    end
    object TabOlcumDEGISTIRMETARIHI: TSQLTimeStampField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object TabOlcumSORUMLUADI: TWideStringField
      FieldName = 'SORUMLUADI'
      ProviderFlags = []
      ReadOnly = True
      Size = 120
    end
    object TabOlcumLOKASYONADI: TWideStringField
      FieldName = 'LOKASYONADI'
      ProviderFlags = []
      ReadOnly = True
      Size = 100
    end
    object TabOlcumKAYNAKADI: TWideStringField
      FieldName = 'KAYNAKADI'
      ProviderFlags = []
      ReadOnly = True
      Size = 100
    end
    object TabOlcumDURUM: TWordField
      FieldName = 'DURUM'
    end
    object TabOlcumALARM: TSmallintField
      FieldName = 'ALARM'
      ProviderFlags = []
      ReadOnly = True
    end
  end
  object DtsOlcum: TDataSource
    DataSet = TabOlcum
    OnStateChange = DtsOlcumStateChange
    Left = 677
    Top = 341
  end
  object TabOlcumDetay: TFDQuery
    BeforePost = TabOlcumDetayBeforePost
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select UOD.ID,UOD.URETIMOLCUMID, UOD.KALITESABLONDETAYID, KT.ADI' +
        ',UOD.DEGERI, UOD.OLCUALETI,UOD.SAPMA, KSD.BIRIM,'
      
        'KSD.TOLERANSTIPI, KSD.TOLERANSDEGERI,KSD.NOMINAL,KSD.LIMITALT,KS' +
        'D.LIMITUST, KSD.LIMITYAZI,'
      'TOLERANS =case when isnull(GIRIS,2)=13 THEN '
      
        '           case when CAST(KSD.LIMITALT as float)>=0.0 then '#39'-'#39'+c' +
        'ast(KSD.LIMITALT as varchar(20)) else '#39#39' end + '#39' '#39'+'
      
        '           case when CAST(KSD.LIMITALT as float)>=0.0 then '#39'+'#39'+c' +
        'ast(KSD.LIMITUST as varchar(20)) else '#39#39' end    '
      #9' ELSE '#39#39' END,UOD.ALARM, KSD.GIRIS, KSD.KAYNAK'
      'from URETIMOLCUMDETAY UOD '
      
        'inner join KALITESABLONDETAY KSD on KSD.ID=UOD.KALITESABLONDETAY' +
        'ID'
      'inner join KALITETEST KT on KT.ID = KSD.TESTID'
      'where UOD.URETIMOLCUMID=:PRM1')
    Left = 677
    Top = 45
  end
  object DtsOlcumDetay: TDataSource
    DataSet = TabOlcumDetay
    OnStateChange = DtsOlcumDetayStateChange
    Left = 765
    Top = 285
  end
  object PopupMenuOlcum: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 261
    Top = 225
    object Nominal2OlculenMenu: TMenuItem
      Caption = 'Nominal de'#287'erleri -> '#214'l'#231#252'len de'#287'erlere ta'#351#305
      ImageIndex = 0
      OnClick = Nominal2OlculenMenuClick
    end
  end
end
