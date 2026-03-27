object StokDlg: TStokDlg
  Left = 0
  Top = 0
  Width = 700
  Height = 451
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  ExplicitWidth = 451
  ExplicitHeight = 304
  object Label19: TLabel
    Left = 440
    Top = 264
    Width = 6
    Height = 23
    Font.Charset = TURKISH_CHARSET
    Font.Color = clNavy
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 694
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
    HotTrackColor = clNone
    Images = AnaForm.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    ExplicitWidth = 445
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
    end
    object KaydetTus: TToolButton
      Left = 138
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
    end
    object IptalTus: TToolButton
      Left = 207
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
    end
    object ToolButton1: TToolButton
      Left = 276
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 9
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 284
      Top = 0
      Caption = 'Yazd'#305'r'
      ImageIndex = 16
      Style = tbsTextButton
    end
    object ToolButton4: TToolButton
      Left = 353
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Enabled = False
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 361
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 700
    Height = 416
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    ExplicitWidth = 451
    ExplicitHeight = 269
    object PanelDetayPage: TPanel
      Left = 1
      Top = 248
      Width = 698
      Height = 167
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 449
      ExplicitHeight = 20
      object PageControl1: TPageControl
        Left = 1
        Top = 1
        Width = 696
        Height = 165
        ActivePage = tshFiyatlar
        Align = alClient
        MultiLine = True
        TabOrder = 0
        object tshFiyatlar: TTabSheet
          Caption = 'Fiyatland'#305'rma'
          object GridFiyat: TcxGrid
            Left = 0
            Top = 27
            Width = 688
            Height = 110
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfStandard
            LookAndFeel.NativeStyle = True
            object GridFiyatView: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsSelection.HideSelection = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
            end
            object GridFiyatLevel1: TcxGridLevel
              GridView = GridFiyatView
            end
          end
          object ToolBar3: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 682
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
            TabOrder = 1
            Transparent = True
            object BankaEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
            end
            object BankaSilTus: TToolButton
              Left = 61
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
            end
            object BankaKaydetTus: TToolButton
              Left = 122
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              Style = tbsTextButton
              Visible = False
            end
            object BankaIptalTus: TToolButton
              Left = 183
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              Style = tbsTextButton
              Visible = False
            end
          end
        end
        object tshStokDurum: TTabSheet
          Caption = 'Stok Durum'
          ImageIndex = -1
          object Panel4: TPanel
            Left = 0
            Top = 108
            Width = 688
            Height = 29
            Align = alBottom
            Color = 8454143
            TabOrder = 0
            object Label18: TLabel
              Left = 8
              Top = 8
              Width = 81
              Height = 16
              Caption = 'Genel Durum'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object lbGiren: TLabel
              Left = 256
              Top = 8
              Width = 97
              Height = 13
              AutoSize = False
              Caption = 'Adetler'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object lbCikan: TLabel
              Left = 360
              Top = 8
              Width = 81
              Height = 13
              AutoSize = False
              Caption = 'Adetler'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object lbKalan: TLabel
              Left = 456
              Top = 8
              Width = 65
              Height = 13
              AutoSize = False
              Caption = 'Adetler'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
          end
          object Panel8: TPanel
            Left = 0
            Top = 0
            Width = 688
            Height = 25
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object DurumExceleAktarBtn: TSpeedButton
              Left = 616
              Top = 0
              Width = 129
              Height = 20
              Caption = 'Excele Aktar'
              Flat = True
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              Glyph.Data = {
                36040000424D3604000000000000360000002800000010000000100000000100
                200000000000000400000000000000000000000000000000000039724BFF3972
                4BFF39724BFF326C46FF326C46FF326C46FF2B6541FF2B6541FF2B6541FF255C
                37FF255C37FF255C37FF1D5230FF1D5230FF1D5230FF194C29FF39724BFF6BA6
                7BFF65A076FF65A076FF5E9B71FF5E9B71FF57966AFF57966AFF48935EFF4893
                5EFF48935EFF3C8C56FF3C8C56FF348C4EFF348C4EFF194C29FF407A56FF6BA6
                7BFFEBF3EBFFE8F1E8FFE6F0E6FFE4EFE4FFE2EEE3FFDFECDFFFDEEBDEFFDCEA
                DDFFDCEADBFFD9E8D9FFD8E7D8FFD8E7D8FF348C4EFF194C29FF407A56FF70AA
                80FFEDF5EDFFEBF3EBFFEAF1E9FFE6F0E6FFE4EFE4FFE2EEE3FFDFECDFFFDEEB
                DEFFDCEADBFFDCEADBFFDAE9DAFFD8E7D8FF3C8C56FF1D5230FF46805CFF75AF
                85FFEFF6EFFFEDF5EDFFEBF3EBFFE9F2E9FFE8F1E8FFE4EFE4FF81AA8DFF2B51
                2FFF2B512FFF2B512FFF2B512FFFDAE9DAFF3C8C56FF1D5230FF4C8761FF7BB5
                8AFFF3F8F3FF54A459FF2B512FFF2B512FFF2B512FFF2B512FFF1C771DFF6CB6
                74FF48935EFF4A964CFF255C37FFDCEADBFF48935EFF255C37FF548E66FF81BC
                90FFF4F9F4FFF1F7F1FF54A459FF62B275FF54A459FF1C771DFF7BC185FF4893
                5EFF4A964CFF255C37FF81AA8DFFDCEADDFF48935EFF255C37FF57966AFF8AB7
                95FFF6FAF6FFF5F9F5FFF3F8F3FF54A459FF318734FF81BC90FF48935EFF4A96
                4CFF255C37FF609963FF609963FFDFECDFFF48935EFF255C37FF5E9B71FF94C7
                9CFFF9FBFAFFF6FAF6FFF5F9F5FF318734FF94C79CFF5BAA64FF54A459FF326C
                46FF036803FFE6F0E6FFE2EEE3FFE1EDE1FF57966AFF2B6541FF65A076FF94C7
                9CFFFCFDFBFFF9FBFAFF3F9346FF9DD0A7FF6CB674FF5BAA64FF418748FF54A4
                59FF318734FF036803FFE6F0E6FFE4EFE4FF57966AFF2B6541FF6BA67BFF9DD0
                A7FFFCFDFCFF4A964CFFAAD6B2FF72BB7BFF72BB7BFF48935EFF568259FF67B0
                6EFF54A459FF318734FF036803FFE6F0E6FF5E9B71FF326C46FF70AA80FF9DD0
                A7FFFEFEFEFF67B06EFF63AC68FF63AC68FF569A5DFFF6F9F6FFF3F8F3FF5682
                59FF568259FF568259FF568259FFE9F2E9FF5E9B71FF326C46FF75AF85FFAAD6
                B2FFFEFEFEFFFDFEFDFFFDFEFDFFFCFDFBFFF9FBFAFFF8FAF8FFF6F9F6FFF4F9
                F4FFF1F7F1FFEFF6EFFFEDF5EDFFEBF3EBFF65A076FF39724BFF7BB58AFFAAD6
                B2FFFFFFFFFFFFFFFFFFFEFFFEFFFDFEFDFFFCFDFBFFF9FBFAFFF8FAF8FFF6FA
                F6FFF4F9F4FFF1F7F1FFEFF6EFFFEDF5EDFF65A076FF39724BFF7BB58AFFAAD6
                B2FFAAD6B2FF9DD0A7FF9DD0A7FF94C79CFF94C79CFF94C79CFF8AB795FF81BC
                90FF7BB58AFF75AF85FF70AA80FF70AA80FF6BA67BFF39724BFF81BC90FF7BB5
                8AFF75AF85FF70AA80FF6BA67BFF65A076FF5E9B71FF57966AFF548E66FF4C87
                61FF4C8761FF46805CFF407A56FF407A56FF39724BFF39724BFF}
              ParentFont = False
            end
            object cxProgressBar1: TcxProgressBar
              Left = 1
              Top = 1
              Properties.BarStyle = cxbsGradient
              Properties.BeginColor = 8454143
              Properties.PeakColor = 8454143
              Properties.ShowPeak = True
              TabOrder = 0
              Visible = False
              Width = 216
            end
            object cbSKTsizGrupla: TCheckBox
              Left = 443
              Top = 2
              Width = 147
              Height = 17
              Caption = 'SKTsiz Grupla'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 1
            end
            object cbSifirKalanGoster: TCheckBox
              Left = 295
              Top = 2
              Width = 142
              Height = 17
              Caption = 'S'#305'f'#305'r(0) Kalan G'#246'ster'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 2
            end
          end
          object GridStokDurum: TcxGrid
            Left = 0
            Top = 25
            Width = 688
            Height = 83
            Align = alClient
            TabOrder = 2
            LookAndFeel.Kind = lfStandard
            LookAndFeel.NativeStyle = True
            object GridStokDurumView: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsSelection.HideSelection = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
            end
            object GridStokDurumLevel1: TcxGridLevel
              GridView = GridStokDurumView
            end
          end
        end
        object tshGiris: TTabSheet
          Caption = 'Giri'#351'ler'
          ImageIndex = 2
          object cxgrdStokGirisKart: TcxGrid
            Left = 0
            Top = 22
            Width = 688
            Height = 115
            Align = alClient
            TabOrder = 0
            object cxgrdStokGirisKartDBTableView1: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              object cxgrdStokGirisKartDBTableView1YIL: TcxGridDBColumn
                DataBinding.FieldName = 'YIL'
                Width = 50
              end
              object cxgrdStokGirisKartDBTableView1DBColumn3: TcxGridDBColumn
                DataBinding.FieldName = 'T'#220'R'#220
              end
              object cxgrdStokGirisKartDBTableView1DBGIRNO: TcxGridDBColumn
                DataBinding.FieldName = 'G'#304'R'#304#350' NO'
                Options.Editing = False
              end
              object cxgrdStokGirisKartDBTableView1ALINANFRMA: TcxGridDBColumn
                DataBinding.FieldName = 'ALINAN F'#304'RMA'
              end
              object cxgrdStokGirisKartDBTableView1BELGETARH: TcxGridDBColumn
                DataBinding.FieldName = 'BELGE TAR'#304'H'#304
              end
              object cxgrdStokGirisKartDBTableView1DBBELGENO: TcxGridDBColumn
                DataBinding.FieldName = 'BELGE NO'
                Options.Editing = False
              end
              object cxgrdStokGirisKartDBTableView1ADET: TcxGridDBColumn
                DataBinding.FieldName = 'ADET'
              end
              object cxgrdStokGirisKartDBTableView1BRM: TcxGridDBColumn
                DataBinding.FieldName = 'B'#304'R'#304'M'
              end
              object cxgrdStokGirisKartDBTableView1BRMFYAT: TcxGridDBColumn
                DataBinding.FieldName = 'B'#304'R'#304'M F'#304'YAT'
              end
              object cxgrdStokGirisKartDBTableView1SKONTO1: TcxGridDBColumn
                DataBinding.FieldName = #304'SKONTO 1'
              end
              object cxgrdStokGirisKartDBTableView1SKONTO2: TcxGridDBColumn
                DataBinding.FieldName = #304'SKONTO 2'
              end
              object cxgrdStokGirisKartDBTableView1TUTAR: TcxGridDBColumn
                DataBinding.FieldName = 'TUTAR'
              end
              object cxgrdStokGirisKartDBTableView1SONKULLANMATARH: TcxGridDBColumn
                DataBinding.FieldName = 'SON KULLANMA TAR'#304'H'#304
              end
              object cxgrdStokGirisKartDBTableView1DBColumn1: TcxGridDBColumn
                DataBinding.FieldName = 'DEPO'
                Options.Editing = False
              end
              object cxgrdStokGirisKartDBTableView1DBColumn2: TcxGridDBColumn
                Caption = #304'SK. B.F'#304'YAT'
                DataBinding.FieldName = #304'SK TUTAR'
              end
            end
            object cxgrdStokGirisKartLevel1: TcxGridLevel
            end
          end
          object Panel6: TPanel
            Left = 0
            Top = 0
            Width = 688
            Height = 22
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object LabelGirisUyari: TLabel
              Left = 237
              Top = 2
              Width = 297
              Height = 13
              Caption = 'Listedeki stok giri'#351'leri say'#305'm sonras'#305'na ait giri'#351'lerdir.'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              Visible = False
            end
            object GirisExceleAktarBtn: TSpeedButton
              Left = 616
              Top = 0
              Width = 129
              Height = 20
              Caption = 'Excele Aktar'
              Flat = True
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              Glyph.Data = {
                36040000424D3604000000000000360000002800000010000000100000000100
                200000000000000400000000000000000000000000000000000039724BFF3972
                4BFF39724BFF326C46FF326C46FF326C46FF2B6541FF2B6541FF2B6541FF255C
                37FF255C37FF255C37FF1D5230FF1D5230FF1D5230FF194C29FF39724BFF6BA6
                7BFF65A076FF65A076FF5E9B71FF5E9B71FF57966AFF57966AFF48935EFF4893
                5EFF48935EFF3C8C56FF3C8C56FF348C4EFF348C4EFF194C29FF407A56FF6BA6
                7BFFEBF3EBFFE8F1E8FFE6F0E6FFE4EFE4FFE2EEE3FFDFECDFFFDEEBDEFFDCEA
                DDFFDCEADBFFD9E8D9FFD8E7D8FFD8E7D8FF348C4EFF194C29FF407A56FF70AA
                80FFEDF5EDFFEBF3EBFFEAF1E9FFE6F0E6FFE4EFE4FFE2EEE3FFDFECDFFFDEEB
                DEFFDCEADBFFDCEADBFFDAE9DAFFD8E7D8FF3C8C56FF1D5230FF46805CFF75AF
                85FFEFF6EFFFEDF5EDFFEBF3EBFFE9F2E9FFE8F1E8FFE4EFE4FF81AA8DFF2B51
                2FFF2B512FFF2B512FFF2B512FFFDAE9DAFF3C8C56FF1D5230FF4C8761FF7BB5
                8AFFF3F8F3FF54A459FF2B512FFF2B512FFF2B512FFF2B512FFF1C771DFF6CB6
                74FF48935EFF4A964CFF255C37FFDCEADBFF48935EFF255C37FF548E66FF81BC
                90FFF4F9F4FFF1F7F1FF54A459FF62B275FF54A459FF1C771DFF7BC185FF4893
                5EFF4A964CFF255C37FF81AA8DFFDCEADDFF48935EFF255C37FF57966AFF8AB7
                95FFF6FAF6FFF5F9F5FFF3F8F3FF54A459FF318734FF81BC90FF48935EFF4A96
                4CFF255C37FF609963FF609963FFDFECDFFF48935EFF255C37FF5E9B71FF94C7
                9CFFF9FBFAFFF6FAF6FFF5F9F5FF318734FF94C79CFF5BAA64FF54A459FF326C
                46FF036803FFE6F0E6FFE2EEE3FFE1EDE1FF57966AFF2B6541FF65A076FF94C7
                9CFFFCFDFBFFF9FBFAFF3F9346FF9DD0A7FF6CB674FF5BAA64FF418748FF54A4
                59FF318734FF036803FFE6F0E6FFE4EFE4FF57966AFF2B6541FF6BA67BFF9DD0
                A7FFFCFDFCFF4A964CFFAAD6B2FF72BB7BFF72BB7BFF48935EFF568259FF67B0
                6EFF54A459FF318734FF036803FFE6F0E6FF5E9B71FF326C46FF70AA80FF9DD0
                A7FFFEFEFEFF67B06EFF63AC68FF63AC68FF569A5DFFF6F9F6FFF3F8F3FF5682
                59FF568259FF568259FF568259FFE9F2E9FF5E9B71FF326C46FF75AF85FFAAD6
                B2FFFEFEFEFFFDFEFDFFFDFEFDFFFCFDFBFFF9FBFAFFF8FAF8FFF6F9F6FFF4F9
                F4FFF1F7F1FFEFF6EFFFEDF5EDFFEBF3EBFF65A076FF39724BFF7BB58AFFAAD6
                B2FFFFFFFFFFFFFFFFFFFEFFFEFFFDFEFDFFFCFDFBFFF9FBFAFFF8FAF8FFF6FA
                F6FFF4F9F4FFF1F7F1FFEFF6EFFFEDF5EDFF65A076FF39724BFF7BB58AFFAAD6
                B2FFAAD6B2FF9DD0A7FF9DD0A7FF94C79CFF94C79CFF94C79CFF8AB795FF81BC
                90FF7BB58AFF75AF85FF70AA80FF70AA80FF6BA67BFF39724BFF81BC90FF7BB5
                8AFF75AF85FF70AA80FF6BA67BFF65A076FF5E9B71FF57966AFF548E66FF4C87
                61FF4C8761FF46805CFF407A56FF407A56FF39724BFF39724BFF}
              ParentFont = False
            end
            object CheckGirisUyari: TCheckBox
              Left = 4
              Top = 0
              Width = 217
              Height = 17
              Caption = 'Say'#305'mlar'#305' kontrol etsin'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
            end
          end
        end
        object tshCikis: TTabSheet
          Caption = #199#305'k'#305#351'lar'
          ImageIndex = 4
          object cxGridStokCikislar: TcxGrid
            Left = 0
            Top = 22
            Width = 688
            Height = 115
            Align = alClient
            TabOrder = 0
            object cxGridStokCikislari: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              object cxGridStokCikislariYIL: TcxGridDBColumn
                DataBinding.FieldName = 'YIL'
                Width = 55
              end
              object CikisTuru: TcxGridDBColumn
                Caption = #199'IKI'#350' T'#220'R'#220
                DataBinding.FieldName = 'ACIKLAMA'
              end
              object CikisTarih: TcxGridDBColumn
                Caption = 'TAR'#304'H'
                DataBinding.FieldName = 'TARIH'
                Width = 76
              end
              object CikisNo: TcxGridDBColumn
                Caption = #199'IKI'#350' NO'
                DataBinding.FieldName = 'CIKNO'
                Width = 68
              end
              object CikisYeri: TcxGridDBColumn
                Caption = #199'IKI'#350' YER'#304
                DataBinding.FieldName = 'CIKISDEPO'
                Width = 105
              end
              object CikisHedef: TcxGridDBColumn
                Caption = 'HEDEF'
                DataBinding.FieldName = 'SERVIS'
                Width = 95
              end
              object CikisAdet: TcxGridDBColumn
                DataBinding.FieldName = 'ADET'
              end
              object CikisBirim: TcxGridDBColumn
                Caption = 'B'#304'R'#304'M'
                DataBinding.FieldName = 'BIRIM'
              end
              object CikisMiktar: TcxGridDBColumn
                Caption = 'M'#304'KTAR'
                DataBinding.FieldName = 'MIKTAR'
              end
              object CikisPersonel: TcxGridDBColumn
                DataBinding.FieldName = 'PERSONEL'
                Width = 100
              end
              object CikisSkt: TcxGridDBColumn
                DataBinding.FieldName = 'SKT'
              end
            end
            object cxGridStokCikislarLevel1: TcxGridLevel
            end
          end
          object Panel7: TPanel
            Left = 0
            Top = 0
            Width = 688
            Height = 22
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object LabelCikisUyari: TLabel
              Left = 237
              Top = 2
              Width = 299
              Height = 13
              Caption = 'Listedeki stok '#231#305'k'#305#351'lar'#305' say'#305'm sonras'#305'na ait '#231#305'k'#305#351'lard'#305'r.'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              Visible = False
            end
            object CikisExceleAktarBtn: TSpeedButton
              Left = 616
              Top = 0
              Width = 129
              Height = 20
              Caption = 'Excele Aktar'
              Flat = True
              Font.Charset = TURKISH_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = []
              Glyph.Data = {
                36040000424D3604000000000000360000002800000010000000100000000100
                200000000000000400000000000000000000000000000000000039724BFF3972
                4BFF39724BFF326C46FF326C46FF326C46FF2B6541FF2B6541FF2B6541FF255C
                37FF255C37FF255C37FF1D5230FF1D5230FF1D5230FF194C29FF39724BFF6BA6
                7BFF65A076FF65A076FF5E9B71FF5E9B71FF57966AFF57966AFF48935EFF4893
                5EFF48935EFF3C8C56FF3C8C56FF348C4EFF348C4EFF194C29FF407A56FF6BA6
                7BFFEBF3EBFFE8F1E8FFE6F0E6FFE4EFE4FFE2EEE3FFDFECDFFFDEEBDEFFDCEA
                DDFFDCEADBFFD9E8D9FFD8E7D8FFD8E7D8FF348C4EFF194C29FF407A56FF70AA
                80FFEDF5EDFFEBF3EBFFEAF1E9FFE6F0E6FFE4EFE4FFE2EEE3FFDFECDFFFDEEB
                DEFFDCEADBFFDCEADBFFDAE9DAFFD8E7D8FF3C8C56FF1D5230FF46805CFF75AF
                85FFEFF6EFFFEDF5EDFFEBF3EBFFE9F2E9FFE8F1E8FFE4EFE4FF81AA8DFF2B51
                2FFF2B512FFF2B512FFF2B512FFFDAE9DAFF3C8C56FF1D5230FF4C8761FF7BB5
                8AFFF3F8F3FF54A459FF2B512FFF2B512FFF2B512FFF2B512FFF1C771DFF6CB6
                74FF48935EFF4A964CFF255C37FFDCEADBFF48935EFF255C37FF548E66FF81BC
                90FFF4F9F4FFF1F7F1FF54A459FF62B275FF54A459FF1C771DFF7BC185FF4893
                5EFF4A964CFF255C37FF81AA8DFFDCEADDFF48935EFF255C37FF57966AFF8AB7
                95FFF6FAF6FFF5F9F5FFF3F8F3FF54A459FF318734FF81BC90FF48935EFF4A96
                4CFF255C37FF609963FF609963FFDFECDFFF48935EFF255C37FF5E9B71FF94C7
                9CFFF9FBFAFFF6FAF6FFF5F9F5FF318734FF94C79CFF5BAA64FF54A459FF326C
                46FF036803FFE6F0E6FFE2EEE3FFE1EDE1FF57966AFF2B6541FF65A076FF94C7
                9CFFFCFDFBFFF9FBFAFF3F9346FF9DD0A7FF6CB674FF5BAA64FF418748FF54A4
                59FF318734FF036803FFE6F0E6FFE4EFE4FF57966AFF2B6541FF6BA67BFF9DD0
                A7FFFCFDFCFF4A964CFFAAD6B2FF72BB7BFF72BB7BFF48935EFF568259FF67B0
                6EFF54A459FF318734FF036803FFE6F0E6FF5E9B71FF326C46FF70AA80FF9DD0
                A7FFFEFEFEFF67B06EFF63AC68FF63AC68FF569A5DFFF6F9F6FFF3F8F3FF5682
                59FF568259FF568259FF568259FFE9F2E9FF5E9B71FF326C46FF75AF85FFAAD6
                B2FFFEFEFEFFFDFEFDFFFDFEFDFFFCFDFBFFF9FBFAFFF8FAF8FFF6F9F6FFF4F9
                F4FFF1F7F1FFEFF6EFFFEDF5EDFFEBF3EBFF65A076FF39724BFF7BB58AFFAAD6
                B2FFFFFFFFFFFFFFFFFFFEFFFEFFFDFEFDFFFCFDFBFFF9FBFAFFF8FAF8FFF6FA
                F6FFF4F9F4FFF1F7F1FFEFF6EFFFEDF5EDFF65A076FF39724BFF7BB58AFFAAD6
                B2FFAAD6B2FF9DD0A7FF9DD0A7FF94C79CFF94C79CFF94C79CFF8AB795FF81BC
                90FF7BB58AFF75AF85FF70AA80FF70AA80FF6BA67BFF39724BFF81BC90FF7BB5
                8AFF75AF85FF70AA80FF6BA67BFF65A076FF5E9B71FF57966AFF548E66FF4C87
                61FF4C8761FF46805CFF407A56FF407A56FF39724BFF39724BFF}
              ParentFont = False
            end
            object CheckCikisUyari: TCheckBox
              Left = 4
              Top = 0
              Width = 217
              Height = 17
              Caption = 'Say'#305'mlar'#305' kontrol etsin'
              Font.Charset = TURKISH_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
            end
          end
        end
        object tshTeknikSartname: TTabSheet
          Caption = 'Teknik '#350'artname'
          ImageIndex = 5
          object DBMemo1: TDBMemo
            Left = 0
            Top = 0
            Width = 688
            Height = 137
            Align = alClient
            DataField = 'TEKNIKSARTNAME'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            ScrollBars = ssVertical
            TabOrder = 0
          end
        end
        object tshStokPanel: TTabSheet
          Caption = 'Panel Bilgileri'
          ImageIndex = 6
          object Panel10: TPanel
            Left = 0
            Top = 0
            Width = 688
            Height = 41
            Align = alTop
            TabOrder = 0
            object SpeedButton3: TSpeedButton
              Left = 5
              Top = 10
              Width = 66
              Height = 22
              Caption = 'Ekle'
              Flat = True
              Glyph.Data = {
                36050000424D3605000000000000360400002800000010000000100000000100
                08000000000000010000E30E0000E30E0000000100000001000031319C003131
                A5003131AD003131B5003131BD003131C6003131CE003131D6003131DE003131
                E7003131EF003131F700FF00FF003131FF003139FF003939FF003942FF00424A
                FF004A4AFF005252FF006363FF006B6BFF006B73FF007B84FF00848CFF009C9C
                FF00C6CEFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000C1B1B1B1B1B
                1B1B1B1B1B1B1B1B1B0C1B16030404040505040403030201141B1B05080A0B0B
                0A0B0A0A0A090805001B1B070A0E0E0E0E0E0E0E0E0E0906021B1B090E0E0E0E
                0E1B180E0E0E0B08031B1B0A0E0E0E0E0E1B180E0E0E0E09041B1B0E0E0E0E0E
                0E1B180E0E0E0E0A051B1B0E0E181818181B181818180B0A061B1B0E0E1B1B1B
                1B1B1B1B1B1B0A0A061B1B0E10100E0E0E1B180E0E0B0A0A061B1B0E1313100E
                0E1B180E0E0B0A0A061B1B1015141110101B180E0E0E0B0B061B1B1318151312
                111B180E0E0E0E0B061B1B1419181514131211100E0E0E0B041B1B1A1412100E
                0E0E0E0E0E0E0B08171B0C1B1B1B1B1B1B1B1B1B1B1B1B1B1B0C}
            end
            object SpeedButton4: TSpeedButton
              Left = 71
              Top = 10
              Width = 66
              Height = 22
              Caption = 'Sil'
              Flat = True
              Glyph.Data = {
                36050000424D3605000000000000360400002800000010000000100000000100
                08000000000000010000E30E0000E30E0000000100000001000031319C003131
                A5003131AD003131B5003131BD003131C6003131CE003131D6003131DE003131
                E7003131EF003131F700FF00FF003131FF003139FF003939FF003942FF00424A
                FF004A4AFF005252FF006363FF006B6BFF006B73FF007B84FF00848CFF009C9C
                FF00C6CEFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
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
                FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000C1B1B1B1B1B
                1B1B1B1B1B1B1B1B1B0C1B16030404040505040403030201141B1B05080A0B0B
                0A0B0A0A0A090805001B1B070A0E0E0E0E0E0E0E0E0E0906021B1B090E0E0E0E
                0E0E0E0E0E0E0B08031B1B0A0E0E0E0E0E0E0E0E0E0E0E09041B1B0E0E0E0E0E
                0E0E0E0E0E0E0E0A051B1B0E0E1818181818181818180B0A061B1B0E0E1B1B1B
                1B1B1B1B1B1B0A0A061B1B0E10100E0E0E0E0E0E0E0B0A0A061B1B0E1313100E
                0E0E0E0E0E0B0A0A061B1B1015141110100E0E0E0E0E0B0B061B1B1318151312
                11110E0E0E0E0E0B061B1B1419181514131211100E0E0E0B041B1B1A1412100E
                0E0E0E0E0E0E0B08171B0C1B1B1B1B1B1B1B1B1B1B1B1B1B1B0C}
            end
          end
          object GridStokPanel: TDBGrid
            Left = 0
            Top = 41
            Width = 688
            Height = 96
            Align = alClient
            TabOrder = 1
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            Columns = <
              item
                Expanded = False
                FieldName = 'STOKKOD'
                Title.Caption = 'Kod'
                Width = 110
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'STOKADI'
                Title.Caption = 'Stok Ad'#305
                Width = 245
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'BIRIM'
                Title.Caption = 'Birim'
                Width = 73
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'MIKTAR'
                Title.Caption = 'Miktar'
                Width = 76
                Visible = True
              end>
          end
        end
        object tsKritikSeviye: TTabSheet
          Caption = 'Kritik Seviye'
          ImageIndex = 7
          object Panel9: TPanel
            Left = 0
            Top = 0
            Width = 688
            Height = 28
            Align = alTop
            TabOrder = 0
            object GenNgKritikSeviye: TGenDBNavigator
              Left = 15
              Top = 2
              Width = 120
              Height = 25
              VisibleButtons = [nbInsert, nbDelete]
              Flat = True
              ConfirmDelete = False
              TabOrder = 0
            end
          end
          object cxGridKritikSeviye: TcxGrid
            Left = 0
            Top = 28
            Width = 688
            Height = 109
            Align = alClient
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            object TableViewKritikSeviye: TcxGridDBTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.GoToNextCellOnEnter = True
              OptionsView.GroupByBox = False
              object TableViewKritikSeviyeDEPOADI: TcxGridDBColumn
                Caption = 'Depo Ad'#305
                DataBinding.FieldName = 'DEPOADI'
                PropertiesClassName = 'TcxComboBoxProperties'
                Properties.DropDownListStyle = lsFixedList
                Options.Filtering = False
                Options.Grouping = False
                Options.Moving = False
                Width = 168
              end
              object TableViewKritikSeviyeKRITIKSEVIYE: TcxGridDBColumn
                Caption = 'Kritik Seviye'
                DataBinding.FieldName = 'KRITIKSEVIYE'
                PropertiesClassName = 'TcxTextEditProperties'
                Options.Filtering = False
                Options.Grouping = False
                Options.Moving = False
                Width = 78
              end
            end
            object cxGridKritikSeviyeWiew: TcxGridLevel
            end
          end
        end
      end
    end
    object PanelKartBilgi: TPanel
      Left = 1
      Top = 1
      Width = 698
      Height = 247
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitWidth = 449
      object Panel2: TPanel
        Left = 5
        Top = 24
        Width = 400
        Height = 286
        BevelOuter = bvLowered
        Font.Charset = TURKISH_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object Label1: TLabel
          Left = 20
          Top = 31
          Width = 57
          Height = 13
          Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
          Caption = 'Stok Kodu'
          ParentShowHint = False
          ShowHint = True
        end
        object Label2: TLabel
          Left = 31
          Top = 56
          Width = 47
          Height = 13
          Alignment = taRightJustify
          Caption = 'Stok Ad'#305
        end
        object Label3: TLabel
          Left = 45
          Top = 83
          Width = 34
          Height = 13
          Alignment = taRightJustify
          Caption = 'Grubu'
        end
        object Label4: TLabel
          Left = 42
          Top = 109
          Width = 37
          Height = 13
          Alignment = taRightJustify
          Caption = #214'zellik'
        end
        object Label5: TLabel
          Left = 26
          Top = 134
          Width = 54
          Height = 13
          Alignment = taRightJustify
          Caption = 'Ana Birim'
        end
        object Label6: TLabel
          Left = 35
          Top = 162
          Width = 45
          Height = 13
          Alignment = taRightJustify
          Caption = '2. Birim '
        end
        object Label8: TLabel
          Left = 163
          Top = 162
          Width = 9
          Height = 13
          Alignment = taRightJustify
          Caption = '='
        end
        object Label10: TLabel
          Left = 208
          Top = 31
          Width = 40
          Height = 13
          Caption = 'Barkod'
        end
        object DBText1: TcxDBTextEdit
          Left = 237
          Top = 229
          DataBinding.DataField = 'ANABIRIM'
          TabOrder = 9
          Width = 65
        end
        object DBEdit1: TcxDBTextEdit
          Left = 80
          Top = 27
          Hint = 'Stok kodunu de'#287'i'#351'tirmek i'#231'in sa'#287' tu'#351'a t'#305'klay'#305'n'#305'z'
          DataBinding.DataField = 'KOD'
          DataBinding.DataSource = DtsStok
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          Width = 105
        end
        object DBEdit2: TcxDBTextEdit
          Left = 80
          Top = 52
          DataBinding.DataField = 'STOKADI'
          DataBinding.DataSource = DtsStok
          TabOrder = 1
          Width = 313
        end
        object ComboGRUBU: TcxDBImageComboBox
          Left = 81
          Top = 79
          DataBinding.DataField = 'GRUBU'
          DataBinding.DataSource = DtsStok
          Properties.Items = <>
          TabOrder = 2
          Width = 161
        end
        object ComboOZELLIK: TcxDBImageComboBox
          Left = 81
          Top = 105
          DataBinding.DataField = 'OZELLIK'
          DataBinding.DataSource = DtsStok
          Properties.Items = <>
          TabOrder = 3
          Width = 161
        end
        object ComboANABIRIM: TcxDBImageComboBox
          Left = 82
          Top = 130
          DataBinding.DataField = 'ANABIRIM'
          DataBinding.DataSource = DtsStok
          Properties.Items = <>
          TabOrder = 4
          Width = 77
        end
        object ComboBIRIM2: TcxDBImageComboBox
          Left = 82
          Top = 158
          DataBinding.DataField = 'BIRIM2'
          DataBinding.DataSource = DtsStok
          Properties.Items = <>
          TabOrder = 5
          Width = 77
        end
        object EditBirim2Miktar: TcxDBTextEdit
          Left = 178
          Top = 158
          DataBinding.DataField = 'BIRIM2MIKTAR'
          DataBinding.DataSource = DtsStok
          TabOrder = 6
          Width = 57
        end
        object EditBarkod: TcxDBTextEdit
          Left = 256
          Top = 27
          DataBinding.DataField = 'BARKOD'
          DataBinding.DataSource = DtsStok
          TabOrder = 7
          Width = 137
        end
        object cxButton1: TcxButton
          Left = 187
          Top = 27
          Width = 17
          Height = 20
          Hint = 'Kod a'#287'ac'#305'ndan yeni stok kodu belirle'
          Glyph.Data = {
            9A000000424D9A000000000000003E0000002800000013000000170000000100
            0100000000005C000000CE0E0000D80E0000020000000000000000000000FFFF
            FF00FFFFE000FFFFE000FFFFE000FFFFE000FFFFE000FFFFE000FFFFE000FFFF
            E000FFFBE000E0FBE000E1FDE000E3FDE000E5FDE000EE7BE000FF87E000FFFF
            E000FFFFE000FFFFE000FFFFE000FFFFE000FFFFE000FFFFE000FFFFE000}
          ParentShowHint = False
          ShowHint = True
          TabOrder = 8
        end
      end
      object Panel12: TPanel
        Left = 416
        Top = 24
        Width = 417
        Height = 286
        BevelOuter = bvLowered
        TabOrder = 1
        object Label11: TLabel
          Left = 49
          Top = 178
          Width = 30
          Height = 13
          Caption = #220'retici'
        end
        object Label13: TLabel
          Left = 24
          Top = 55
          Width = 43
          Height = 26
          Alignment = taRightJustify
          Caption = 'Minimum Stok'
          WordWrap = True
        end
        object SpeedButton1: TSpeedButton
          Left = 89
          Top = 175
          Width = 27
          Height = 24
          Flat = True
          Glyph.Data = {
            46050000424D460500000000000036040000280000000F000000110000000100
            08000000000010010000D30E0000D30E00000001000000010000DE7B1000E784
            1000BD6B18006331210084522100BD7321007B4A2900C6842900B56B4200B573
            4A0094735200635A5A0094735A007363630094736300AD8C63007B736B008473
            6B008C736B00947B6B00A5846B00946B73009C6B73009C737300847B73008C7B
            7300D6947300A5847B00BD948400BD9C8400E7BD84008C8C8C00948C8C00A58C
            8C00B59C9400BDAD9400EFC694009C9C9C00D6BD9C00EFCE9C00F7D69C00A5A5
            A500ADADA500D6BDA500D6C6A500E7C6A500DECEA500EFCEA500EFD6A500B5AD
            AD00D6BDAD00DEC6AD00DECEAD00DED6AD00E7D6AD00EFDEAD006394B500A5AD
            B500B5B5B500BDB5B500F7EFB500BDB5BD00C6B5BD00BDBDBD00CEBDBD00C6C6
            BD00D6C6BD00DEDEBD00E7DEBD00E7E7BD00EFE7BD00FFEFBD009CB5C600DECE
            C600DEE7C600F7F7C6006B84CE00C6C6CE00DEE7CE00F7F7CE00FFFFCE007384
            D6008CBDD600ADC6D600C6C6D600C6CED600CECED600EFF7D6006B8CDE007B94
            DE00BDD6DE00C6D6DE00C6DEDE00CEDEDE00DEE7DE00EFF7DE00C6D6E700CED6
            E700CEDEE700CEE7E700E7E7E700CEE7EF00FFFFEF00D6EFF700DEF7F700EFF7
            F700FF00FF0029B5FF0042B5FF0039BDFF00A5E7FF00CEEFFF00D6EFFF00D6F7
            FF00DEF7FF00E7F7FF00DEFFFF00E7FFFF00F7FFFF00FFFFFF00FFFFFF00FFFF
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
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF006A6A6A6A6A6A
            6A6A6A6A6A6A6A6A6A003A102A6A6A6A6A6A6A6A6A6A6A6A6A00535916256A6A
            6A6A6A6A6A6A6A6A6A006E6C5117296A6A6A6A6A6A6A6A6A6A006A6E6D58153F
            6A6A6A6A6A6A6A6A6A005656386B4C0B2011190D1F3F3A3A6A0009090852481C
            476677771B031A066A0027757568402F4B4F5F76771871136A001E6F5B552B36
            2E4A5E64662339126A001E6F5B55322E2C434A4E5726390E6A001E6F5B5B3245
            34354344501D5B0E6A001E705D5D41496944303C2721760C6A001E6F5B5B5B3B
            4236302D225B770C6A001E70616262654D313D4D6772770C6A00247165656767
            677271706768770C6A0002050505050505050507070714046A00000101010101
            010101010101010F6A00}
        end
        object SpeedButton2: TSpeedButton
          Left = 90
          Top = 192
          Width = 27
          Height = 24
          Flat = True
          Glyph.Data = {
            46050000424D460500000000000036040000280000000F000000110000000100
            08000000000010010000D30E0000D30E00000001000000010000DE7B1000E784
            1000BD6B18006331210084522100BD7321007B4A2900C6842900B56B4200B573
            4A0094735200635A5A0094735A007363630094736300AD8C63007B736B008473
            6B008C736B00947B6B00A5846B00946B73009C6B73009C737300847B73008C7B
            7300D6947300A5847B00BD948400BD9C8400E7BD84008C8C8C00948C8C00A58C
            8C00B59C9400BDAD9400EFC694009C9C9C00D6BD9C00EFCE9C00F7D69C00A5A5
            A500ADADA500D6BDA500D6C6A500E7C6A500DECEA500EFCEA500EFD6A500B5AD
            AD00D6BDAD00DEC6AD00DECEAD00DED6AD00E7D6AD00EFDEAD006394B500A5AD
            B500B5B5B500BDB5B500F7EFB500BDB5BD00C6B5BD00BDBDBD00CEBDBD00C6C6
            BD00D6C6BD00DEDEBD00E7DEBD00E7E7BD00EFE7BD00FFEFBD009CB5C600DECE
            C600DEE7C600F7F7C6006B84CE00C6C6CE00DEE7CE00F7F7CE00FFFFCE007384
            D6008CBDD600ADC6D600C6C6D600C6CED600CECED600EFF7D6006B8CDE007B94
            DE00BDD6DE00C6D6DE00C6DEDE00CEDEDE00DEE7DE00EFF7DE00C6D6E700CED6
            E700CEDEE700CEE7E700E7E7E700CEE7EF00FFFFEF00D6EFF700DEF7F700EFF7
            F700FF00FF0029B5FF0042B5FF0039BDFF00A5E7FF00CEEFFF00D6EFFF00D6F7
            FF00DEF7FF00E7F7FF00DEFFFF00E7FFFF00F7FFFF00FFFFFF00FFFFFF00FFFF
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
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF006A6A6A6A6A6A
            6A6A6A6A6A6A6A6A6A003A102A6A6A6A6A6A6A6A6A6A6A6A6A00535916256A6A
            6A6A6A6A6A6A6A6A6A006E6C5117296A6A6A6A6A6A6A6A6A6A006A6E6D58153F
            6A6A6A6A6A6A6A6A6A005656386B4C0B2011190D1F3F3A3A6A0009090852481C
            476677771B031A066A0027757568402F4B4F5F76771871136A001E6F5B552B36
            2E4A5E64662339126A001E6F5B55322E2C434A4E5726390E6A001E6F5B5B3245
            34354344501D5B0E6A001E705D5D41496944303C2721760C6A001E6F5B5B5B3B
            4236302D225B770C6A001E70616262654D313D4D6772770C6A00247165656767
            677271706768770C6A0002050505050505050507070714046A00000101010101
            010101010101010F6A00}
        end
        object Label12: TLabel
          Left = 50
          Top = 194
          Width = 25
          Height = 13
          Alignment = taRightJustify
          Caption = 'Sat'#305'c'#305
        end
        object Label17: TLabel
          Left = 190
          Top = 61
          Width = 33
          Height = 13
          Alignment = taRightJustify
          Caption = 'KDV %'
        end
        object Label16: TLabel
          Left = 18
          Top = 119
          Width = 42
          Height = 13
          Alignment = taRightJustify
          Caption = #214'zel Kod'
        end
        object Label20: TLabel
          Left = 13
          Top = 142
          Width = 47
          Height = 13
          Alignment = taRightJustify
          Caption = 'Muh Kodu'
        end
        object Label7: TLabel
          Left = 33
          Top = 16
          Width = 31
          Height = 13
          Alignment = taRightJustify
          Caption = 'Durum'
        end
        object DBEdit10: TcxDBTextEdit
          Left = 72
          Top = 57
          DataBinding.DataField = 'MINSTOK'
          DataBinding.DataSource = DtsStok
          TabOrder = 0
          Width = 57
        end
        object EditKDV: TcxDBTextEdit
          Left = 233
          Top = 57
          DataBinding.DataField = 'KDV'
          DataBinding.DataSource = DtsStok
          TabOrder = 1
          Width = 57
        end
        object SKTCheckBox: TcxDBCheckBox
          Left = 4
          Top = 91
          Caption = 'Son Kullanma Tarihi'
          DataBinding.DataField = 'SKT_VAR'
          DataBinding.DataSource = DtsStok
          TabOrder = 2
          Width = 128
        end
        object ReuseCheckBox: TcxDBCheckBox
          Left = 146
          Top = 90
          Caption = 'Yeniden Kullan'#305'labilir (Reuse)'
          DataBinding.DataField = 'REUSE'
          DataBinding.DataSource = DtsStok
          TabOrder = 3
          Width = 186
        end
        object EditOZELKOD: TcxDBTextEdit
          Left = 69
          Top = 115
          DataBinding.DataField = 'OZELKOD'
          DataBinding.DataSource = DtsStok
          TabOrder = 4
          Width = 129
        end
        object EditMUHKODU: TcxDBTextEdit
          Left = 69
          Top = 139
          DataBinding.DataField = 'MUHKODU'
          DataBinding.DataSource = DtsStok
          TabOrder = 5
          Width = 129
        end
        object dbchbSeri: TcxDBCheckBox
          Left = 334
          Top = 90
          Caption = 'Seri Takibi'
          DataBinding.DataField = 'SERITAKIP'
          DataBinding.DataSource = DtsStok
          TabOrder = 6
          Width = 80
        end
        object ComboDURUM: TcxDBImageComboBox
          Left = 66
          Top = 12
          DataBinding.DataField = 'DURUM'
          DataBinding.DataSource = DtsStok
          Properties.Items = <>
          TabOrder = 7
          Width = 75
        end
      end
      object CheckPasifKartlar: TCheckBox
        Left = 5
        Top = 4
        Width = 161
        Height = 17
        Caption = 'Pasif Kartlar G'#246'r'#252'ns'#252'n'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
      end
    end
  end
  object PopupMenu1: TPopupMenu
    OwnerDraw = True
    Left = 380
    Top = 208
    object BukartnGiriklarnGncelle1: TMenuItem
      Caption = 'Bu kart'#305'n Giri'#351'/'#199#305'k'#305#351'lar'#305'n'#305' G'#252'ncelle'
      ImageIndex = 12
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object TmkartlarnGiriklarnGncelle1: TMenuItem
      Caption = 'B'#252't'#252'n kartlar'#305'n Giri'#351'/'#199#305'k'#305#351'lar'#305'n'#305' G'#252'ncelle'
      ImageIndex = 11
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 284
    Top = 309
  end
  object PopupMenu2: TPopupMenu
    OwnerDraw = True
    Left = 313
    Top = 311
    object YeniFiyatOlutur1: TMenuItem
      Caption = 'Yeni Fiyat Olu'#351'tur'
      ImageIndex = 2
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object FiyatKopyala: TMenuItem
      Caption = 'Fiyat'#305'n'#305' Kopyala'
      ImageIndex = 3
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object FiyatAdiniDegistir: TMenuItem
      Caption = 'Fiyat'#305'n'#305'n Ad'#305'n'#305' De'#287'i'#351'tir'
      ImageIndex = 4
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object FiyatSil: TMenuItem
      Caption = 'Fiyat'#305'n'#305' Sil'
      ImageIndex = 9
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object YuzdeArtma: TMenuItem
      Caption = 'Katsay'#305'/Fiyat'#305' % x Art'#305'r'
      Hint = 'Artma'
      ImageIndex = 5
    end
    object YuzdeAzaltma: TMenuItem
      Caption = 'Katsay'#305'/Fiyat'#305' % x Azalt'
      Hint = 'Azaltma'
      ImageIndex = 6
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object YeniFiyatBilgileriniAl: TMenuItem
      Caption = 'Yeni Fiyat Bilgilerini Al'
      ImageIndex = 8
    end
  end
  object PopupMenu3: TPopupMenu
    OwnerDraw = True
    Left = 316
    Top = 209
    object MenuItem1: TMenuItem
      Caption = 'Bu Kart'#305'n Kodunu De'#287'i'#351'tir'
      ImageIndex = 10
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object AnaBirimDeitir1: TMenuItem
      Caption = 'AnaBirim De'#287'i'#351'tir'
    end
    object N2BirimDeitir1: TMenuItem
      Caption = '2.Birim De'#287'i'#351'tir'
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object KartKopyala1: TMenuItem
      Caption = 'Kart'#305' Kopyala'
    end
  end
  object XPMenu1: TXPMenu
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Color = clBtnFace
    IconBackColor = clBtnFace
    MenuBarColor = clBtnFace
    SelectColor = clHighlight
    SelectBorderColor = clHighlight
    SelectFontColor = clMenuText
    DisabledColor = clInactiveCaption
    SeparatorColor = clBtnFace
    CheckedColor = clHighlight
    IconWidth = 24
    DrawSelect = True
    UseSystemColors = True
    OverrideOwnerDraw = False
    Gradient = False
    FlatMenu = False
    AutoDetect = False
    Active = True
    Left = 624
    Top = 168
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    PopupMenus = <>
    Left = 56
    Top = 528
  end
  object cxGridPopupMenu2: TcxGridPopupMenu
    PopupMenus = <>
    Left = 120
    Top = 536
  end
  object TabStok: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <
      item
        Name = 'pID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
    SQL.Strings = (
      'select '
      #9'* '
      'from '
      #9'STOKLAR'
      'where '
      #9'ID = :pID')
    Left = 543
    Top = 32
  end
  object DtsStok: TDataSource
    DataSet = TabStok
    Left = 617
    Top = 32
  end
end

