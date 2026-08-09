object OpsiyonBankaDlg: TOpsiyonBankaDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Banka Opsiyonlar'
  ClientHeight = 547
  ClientWidth = 767
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Pagectrl: TPageControl
    Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 767
    Height = 521
    ActivePage = TabSheetBanka
    Align = alClient
    TabOrder = 0
    OnChange = PagectrlChange
    object TabSheetBanka: TTabSheet
      Caption = 'Banka'
      ImageIndex = 34
      object BankaGroup: TcxGroupBox
        Left = 3
        Top = 3
        Caption = 'Banka Bilgileri'
        TabOrder = 0
        Height = 158
        Width = 137
        object BankaList: TcxListBox
          Left = 3
          Top = 19
          Width = 131
          Height = 131
          Align = alClient
          ItemHeight = 16
          TabOrder = 0
        end
      end
      object GroupBox1: TGroupBox
        Left = 146
        Top = 0
        Width = 319
        Height = 89
        Caption = 'Bankadan Havale/EFT Oldu'#287'unda'
        TabOrder = 1
        object cxLabel6: TcxLabel
          Left = 4
          Top = 25
          Caption = 'Masraf Tutar'
          Transparent = True
        end
        object cxLabel7: TcxLabel
          Left = 4
          Top = 51
          Caption = 'Masraf Kalemi'
          Transparent = True
        end
        object txtMasrafTutar: TcxCurrencyEdit
          Left = 123
          Top = 24
          Properties.DisplayFormat = ',0.00;-,0.00'
          TabOrder = 2
          Width = 105
        end
        object BeMasrafMerkezi: TcxButtonEdit
          Left = 123
          Top = 50
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = False
          Properties.OnButtonClick = BeMasrafMerkeziPropertiesButtonClick
          TabOrder = 3
          Width = 192
        end
        object cbDovizKur: TcxComboBox
          Left = 233
          Top = 23
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          TabOrder = 4
          Visible = False
          Width = 83
        end
      end
      object cxLabel8: TcxLabel
        Left = 150
        Top = 100
        Caption = 'G'#246'r'#252'necek '#350'ubeler'
        Transparent = True
      end
      object CbSubeler: TcxImageComboBox
        Left = 269
        Top = 95
        Properties.ImmediatePost = True
        Properties.Items = <
          item
            Description = 'Sadece Ortak'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Sadece Kendi '#350'ubesi'
            Value = 1
          end
          item
            Description = 'Ortak + Kendi '#350'ubesi'
            Value = 2
          end
          item
            Description = 'Ortak + T'#252'm '#350'ubeler'
            Value = 3
          end>
        TabOrder = 3
        Width = 193
      end
    end
    object TabSheetPOS: TTabSheet
      Caption = 'POS'
      ImageIndex = 34
      object cxGroupBox2: TcxGroupBox
        Left = 323
        Top = 131
        Caption = 'Pos Bilgileri'
        TabOrder = 0
        Height = 70
        Width = 78
        object ListBoxPOS: TcxListBox
          Left = 3
          Top = 19
          Width = 72
          Height = 43
          Align = alClient
          ItemHeight = 16
          Items.Strings = (
            'T'#252'r'#252
            'Stat'#252's'#252)
          TabOrder = 0
        end
      end
      object GBGidFatListe: TcxGroupBox
        Left = 3
        Top = 15
        Caption = 'Pos Bilgileri'
        TabOrder = 1
        Height = 226
        Width = 143
        object GridListeDuzenle: TcxGrid
          Left = 3
          Top = 19
          Width = 137
          Height = 199
          Align = alClient
          TabOrder = 0
          object GridListeDuzenleDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataSource = DtsListeDuzenle
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsData.CancelOnExit = False
            OptionsData.Deleting = False
            OptionsData.DeletingConfirmation = False
            OptionsData.Editing = False
            OptionsData.Inserting = False
            OptionsSelection.CellSelect = False
            OptionsSelection.InvertSelect = False
            OptionsView.GroupByBox = False
            object GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn
              Caption = 'B'#246'l'#252'm'
              DataBinding.FieldName = 'ANAHTAR'
              Width = 130
            end
            object GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn
              DataBinding.FieldName = 'DEGER'
              Visible = False
            end
          end
          object GridListeDuzenleLevel1: TcxGridLevel
            GridView = GridListeDuzenleDBTableView1
          end
        end
      end
    end
    object TabSheetKrediler: TTabSheet
      Caption = 'Kredi Kart'#305
      ImageIndex = 34
      OnEnter = TabSheetKredilerEnter
      object cxPageControl1: TcxPageControl
        Left = 0
        Top = 0
        Width = 759
        Height = 490
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = cxTabSheet1
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 488
        ClientRectLeft = 2
        ClientRectRight = 757
        ClientRectTop = 28
        object cxTabSheet1: TcxTabSheet
          Caption = 'Bilgiler'
          ImageIndex = 22
          object cxGroupBox4: TcxGroupBox
            Left = 3
            Top = 3
            Caption = 'Kredi Bilgileri'
            TabOrder = 0
            Height = 286
            Width = 137
            object ListBoxKK: TcxListBox
              Left = 3
              Top = 19
              Width = 131
              Height = 259
              Align = alClient
              ItemHeight = 16
              TabOrder = 0
            end
          end
          object cxLabel9: TcxLabel
            Left = 157
            Top = 3
            Caption = 'Bilgilendirme E-Posta'
          end
          object ComboBilgiEposta: TcxImageComboBox
            Left = 297
            Top = 2
            RepositoryItem = Tablo.RepBilgilendirme
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            TabOrder = 2
            Width = 121
          end
          object comboBilgiSms: TcxImageComboBox
            Left = 297
            Top = 30
            RepositoryItem = Tablo.RepBilgilendirme
            EditValue = 0
            Properties.ImmediatePost = True
            Properties.ImmediateUpdateText = True
            Properties.Items = <>
            TabOrder = 3
            Width = 121
          end
          object cxLabel10: TcxLabel
            Left = 159
            Top = 31
            Caption = 'Bilgilendirme Sms'
          end
        end
        object cxTabSheet2: TcxTabSheet
          Caption = 'Kart T'#252'rleri'
          ImageIndex = 19
          object cxGrid1: TcxGrid
            Left = 0
            Top = 24
            Width = 180
            Height = 436
            Align = alLeft
            TabOrder = 0
            object cxGrid1DBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              DataController.DataSource = DtsKrediKartiTipi
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              object cxGrid1DBTableView1Column1: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Width = 26
              end
              object cxGrid1DBTableView1Column2: TcxGridDBColumn
                Caption = 'Ad'#305
                DataBinding.FieldName = 'KARTADI'
                Width = 152
              end
            end
            object cxGrid1Level1: TcxGridLevel
              GridView = cxGrid1DBTableView1
            end
          end
          object ToolBar5: TToolBar
            Left = 0
            Top = 0
            Width = 755
            Height = 24
            Margins.Bottom = 0
            AutoSize = True
            ButtonWidth = 47
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
            List = True
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 1
            Transparent = True
            object BarkodEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              OnClick = BarkodEkleTusClick
            end
            object BarkodSilTus: TToolButton
              Left = 47
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              OnClick = BarkodSilTusClick
            end
            object BarkodKaydetTus: TToolButton
              Left = 94
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              Style = tbsTextButton
              Visible = False
              OnClick = BarkodKaydetTusClick
            end
            object BarkodIptalTus: TToolButton
              Left = 141
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              Style = tbsTextButton
              Visible = False
              OnClick = BarkodIptalTusClick
            end
          end
          object Panel1: TPanel
            Left = 180
            Top = 24
            Width = 575
            Height = 436
            Align = alClient
            TabOrder = 2
            DesignSize = (
              575
              436)
            object LabelKartTipiID: TcxDBLabel
              Left = 95
              Top = 125
              DataBinding.DataField = 'ID'
              DataBinding.DataSource = DtsKrediKartiTipi
              Height = 21
              Width = 167
            end
            object EditKartTipiAdi: TcxDBTextEdit
              Left = 95
              Top = 149
              DataBinding.DataField = 'KARTADI'
              DataBinding.DataSource = DtsKrediKartiTipi
              TabOrder = 1
              Width = 167
            end
            object EditKartTipiAciklama: TcxDBTextEdit
              Left = 95
              Top = 232
              Anchors = [akLeft, akTop, akRight, akBottom]
              AutoSize = False
              DataBinding.DataField = 'ACIKLAMA'
              DataBinding.DataSource = DtsKrediKartiTipi
              TabOrder = 2
              Height = 198
              Width = 473
            end
            object ComboKartTipiDurum: TcxDBImageComboBox
              Left = 95
              Top = 177
              DataBinding.DataField = 'DURUM'
              DataBinding.DataSource = DtsKrediKartiTipi
              Properties.Items = <>
              TabOrder = 3
              Width = 167
            end
            object ComboKartTipiBanka: TcxDBImageComboBox
              Left = 95
              Top = 204
              DataBinding.DataField = 'BANKAKODU'
              DataBinding.DataSource = DtsKrediKartiTipi
              Properties.Items = <>
              TabOrder = 4
              Width = 167
            end
            object cxLabel1: TcxLabel
              Left = 8
              Top = 125
              Caption = 'ID'
            end
            object cxLabel2: TcxLabel
              Left = 8
              Top = 150
              Caption = 'Ad'#305
            end
            object cxLabel3: TcxLabel
              Left = 8
              Top = 179
              Caption = 'Durum'
            end
            object cxLabel4: TcxLabel
              Left = 8
              Top = 206
              Caption = 'Banka'
            end
            object cxLabel5: TcxLabel
              Left = 8
              Top = 235
              Caption = 'A'#231#305'klama'
            end
            object cxDBImage1: TcxDBImage
              Left = 1
              Top = 1
              Align = alTop
              DataBinding.DataField = 'LOGO'
              DataBinding.DataSource = DtsKrediKartiTipi
              Properties.GraphicClassName = 'TJPEGImage'
              TabOrder = 10
              Height = 100
              Width = 573
            end
          end
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Kredi'
      ImageIndex = 34
      object cxGroupBox1: TcxGroupBox
        Left = 3
        Top = 3
        Caption = 'Listeleri Ayarlama'
        TabOrder = 0
        Height = 286
        Width = 137
        object ListBoxKrediler: TcxListBox
          Left = 3
          Top = 19
          Width = 131
          Height = 259
          Align = alClient
          ItemHeight = 16
          TabOrder = 0
        end
      end
      object cxLabel11: TcxLabel
        Left = 157
        Top = 25
        Caption = 'Bilgilendirme E-Posta'
      end
      object ComboBilgiEpostaKredi: TcxImageComboBox
        Left = 299
        Top = 23
        RepositoryItem = Tablo.RepBilgilendirme
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 2
        Width = 121
      end
      object ComboBilgiSmsKredi: TcxImageComboBox
        Left = 299
        Top = 50
        RepositoryItem = Tablo.RepBilgilendirme
        EditValue = 0
        Properties.ImmediatePost = True
        Properties.ImmediateUpdateText = True
        Properties.Items = <>
        TabOrder = 3
        Width = 121
      end
      object cxLabel12: TcxLabel
        Left = 157
        Top = 52
        Caption = 'Bilgilendirme Sms'
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 521
    Width = 767
    Height = 26
    Align = alBottom
    Alignment = taLeftJustify
    TabOrder = 1
    object CancelBtn: TBitBtn
      Left = 348
      Top = 0
      Width = 72
      Height = 24
      Cancel = True
      Caption = 'Ka&pat'
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
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
      Margin = 2
      ModalResult = 2
      ParentFont = False
      Spacing = -1
      TabOrder = 0
      IsControl = True
    end
    object KaydetTus: TBitBtn
      Left = 269
      Top = 0
      Width = 73
      Height = 24
      Caption = '&Kaydet'
      Default = True
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
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
      Margin = 2
      ModalResult = 1
      ParentFont = False
      Spacing = -1
      TabOrder = 1
      OnClick = KaydetTusClick
      IsControl = True
    end
  end
  object TabKrediKartiTipi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from KREDIKARTITURLERI where DURUM=1')
    Left = 333
    Top = 125
  end
  object DtsKrediKartiTipi: TDataSource
    DataSet = TabKrediKartiTipi
    OnStateChange = DtsKrediKartiTipiStateChange
    Left = 216
    Top = 148
  end
  object TabListeDuzenle: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from GENINI where BOLUM=0 and ANAHTAR like '#39'%POS_%'#39)
    Left = 33
    Top = 334
  end
  object DtsListeDuzenle: TDataSource
    DataSet = TabListeDuzenle
    Left = 115
    Top = 333
  end
end
