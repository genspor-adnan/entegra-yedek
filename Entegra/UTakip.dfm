object TakipDlg: TTakipDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Takip '
  ClientHeight = 553
  ClientWidth = 898
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Pgizlem: TcxPageControl
    Left = 0
    Top = 81
    Width = 898
    Height = 472
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = TsKarekod
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 470
    ClientRectLeft = 2
    ClientRectRight = 896
    ClientRectTop = 25
    object TsKarekod: TcxTabSheet
      Caption = 'Karekod'
      ImageIndex = 0
      object pgKareKod: TcxPageControl
        Left = 0
        Top = 0
        Width = 894
        Height = 445
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = shtKareKodGiris
        Properties.CustomButtons.Buttons = <>
        ClientRectBottom = 443
        ClientRectLeft = 2
        ClientRectRight = 892
        ClientRectTop = 25
        object shtKareKodGiris: TcxTabSheet
          Caption = 'Sat'#305'n Alma'
          ImageIndex = 0
          object Panel2: TPanel
            Left = 0
            Top = 35
            Width = 384
            Height = 383
            Align = alLeft
            TabOrder = 0
            object memoKareKodlar: TcxMemo
              Left = 1
              Top = 18
              Align = alClient
              Properties.ScrollBars = ssVertical
              Properties.WordWrap = False
              TabOrder = 0
              OnKeyPress = memoKareKodlarKeyPress
              Height = 364
              Width = 382
            end
            object cxLabel1: TcxLabel
              Left = 1
              Top = 1
              Align = alTop
              Caption = '**KareKodlar'#305' sat'#305'r sat'#305'r olacak '#351'ekilde giriniz.'
              Properties.WordWrap = True
              Transparent = True
              Width = 382
            end
          end
          object Panel4: TPanel
            Left = 384
            Top = 35
            Width = 506
            Height = 383
            Align = alClient
            Caption = 'Panel4'
            TabOrder = 1
            object TreeListKareKod: TcxTreeList
              Left = 1
              Top = 1
              Width = 504
              Height = 381
              Align = alClient
              Bands = <
                item
                end>
              Navigator.Buttons.CustomButtons = <>
              TabOrder = 0
              OnDataChanged = TreeListKareKodDataChanged
              object TlcUrunAdi: TcxTreeListColumn
                PropertiesClassName = 'TcxLabelProperties'
                Caption.Text = #220'r'#252'n Kodu'
                DataBinding.ValueType = 'String'
                Width = 124
                Position.ColIndex = 0
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object cxTreeList1Column2: TcxTreeListColumn
                Caption.Text = 'S'#305'ra Numaras'#305
                DataBinding.ValueType = 'String'
                Width = 108
                Position.ColIndex = 1
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object cxTreeList1Column3: TcxTreeListColumn
                Caption.Text = 'LotNo'
                DataBinding.ValueType = 'String'
                Width = 105
                Position.ColIndex = 2
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object cxTreeList1Column4: TcxTreeListColumn
                Caption.Text = 'Son Kullanma Tarihi'
                DataBinding.ValueType = 'String'
                Width = 100
                Position.ColIndex = 3
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object cxTreeList1Column5: TcxTreeListColumn
                Visible = False
                DataBinding.ValueType = 'String'
                Position.ColIndex = 4
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
              object cxTreeList1Column6: TcxTreeListColumn
                Visible = False
                DataBinding.ValueType = 'String'
                Position.ColIndex = 5
                Position.RowIndex = 0
                Position.BandIndex = 0
                Summary.FooterSummaryItems = <>
                Summary.GroupFooterSummaryItems = <>
              end
            end
          end
          object Panel6: TPanel
            Left = 0
            Top = 0
            Width = 890
            Height = 35
            Align = alTop
            TabOrder = 2
            object cxLabel10: TcxLabel
              Left = 5
              Top = 10
              Caption = 'Firma Ad'#305
            end
            object txtGln: TcxTextEdit
              Left = 244
              Top = 9
              Enabled = False
              Properties.OnChange = txtGlnPropertiesChange
              TabOrder = 1
              Width = 102
            end
            object TxtFirma: TcxTextEdit
              Left = 59
              Top = 9
              Enabled = False
              TabOrder = 2
              Width = 160
            end
            object cxButton1: TcxButton
              Left = 347
              Top = 10
              Width = 37
              Height = 19
              Caption = 'Se'#231
              TabOrder = 3
              OnClick = cxButton1Click
            end
            object cxLabel11: TcxLabel
              Left = 220
              Top = 12
              Caption = 'GLN'
            end
            object cxLabel9: TcxLabel
              Left = 518
              Top = 12
              Caption = 'Transfer No (SSCS)'
            end
            object TxtTransferNo: TcxTextEdit
              Left = 627
              Top = 9
              TabOrder = 6
              Width = 150
            end
            object BtnUrunGetir: TcxButton
              Left = 783
              Top = 5
              Width = 98
              Height = 25
              Caption = #220'r'#252'nleri Getir'
              TabOrder = 7
              OnClick = BtnUrunGetirClick
            end
            object cxButton2: TcxButton
              Left = 395
              Top = 4
              Width = 117
              Height = 25
              Caption = 'Gelen Paketten Getir'
              TabOrder = 8
              OnClick = cxButton2Click
            end
          end
        end
        object shtKareKodDuzeltSil: TcxTabSheet
          Caption = 'D'#252'zeltme - Silme'
          ImageIndex = 1
          object Panel1: TPanel
            Left = 0
            Top = 0
            Width = 890
            Height = 36
            Align = alTop
            TabOrder = 0
            object editKareKod: TcxTextEdit
              Left = 80
              Top = 10
              TabOrder = 0
              OnKeyPress = editKareKodKeyPress
              Width = 121
            end
            object cxLabel2: TcxLabel
              Left = 5
              Top = 12
              Caption = 'S'#305'raNo Arama'
              Transparent = True
            end
            object MemoTempOlustur: TMemo
              Left = 351
              Top = -42
              Width = 386
              Height = 89
              Lines.Strings = (
                'IF EXISTS (select * from '
                'sys.objects where type ='#39'U'#39' AND '
                'name '
                '='#39'GECICI_EKLENECEK_KAREKOD'#39')'
                'BEGIN'
                '    DROP TABLE '
                'GECICI_EKLENECEK_KAREKOD'
                'END'
                'CREATE TABLE '
                'GECICI_EKLENECEK_KAREKOD'
                '('
                '   STOKIDID INT,'
                '   UYARI VARCHAR(50)'
                ')')
              TabOrder = 2
              Visible = False
            end
          end
          object Panel10: TPanel
            Left = 0
            Top = 36
            Width = 393
            Height = 382
            Align = alLeft
            TabOrder = 1
            object gridKareKodListesi: TcxGrid
              Left = 1
              Top = 1
              Width = 391
              Height = 380
              Align = alClient
              TabOrder = 0
              object tvKarekodListesi: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = dtsKareKodListesi
                DataController.KeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.Inserting = False
                OptionsView.GroupByBox = False
                Styles.OnGetContentStyle = tvKarekodListesiStylesGetContentStyle
                object clmKareKodSec: TcxGridDBColumn
                  Caption = 'Se'#231
                  DataBinding.ValueType = 'Boolean'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ImmediatePost = True
                  Properties.NullStyle = nssUnchecked
                  Properties.OnChange = clmKareKodSecPropertiesChange
                  Properties.OnEditValueChanged = clmKareKodSecPropertiesEditValueChanged
                  Width = 40
                end
                object clmSiraNo: TcxGridDBColumn
                  Caption = 'S'#305'ra No'
                  DataBinding.FieldName = 'SIRANO'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Width = 110
                end
                object clmLotno: TcxGridDBColumn
                  Caption = 'Lot No'
                  DataBinding.FieldName = 'LOTNO'
                  Width = 94
                end
                object clmSonKullanma: TcxGridDBColumn
                  Caption = 'Son Kullanma S'#252'resi'
                  DataBinding.FieldName = 'SONKULLANIM'
                  Width = 138
                end
              end
              object gridKareKodListesiLevel1: TcxGridLevel
                GridView = tvKarekodListesi
              end
            end
          end
          object Panel11: TPanel
            Left = 393
            Top = 36
            Width = 497
            Height = 382
            Align = alClient
            TabOrder = 2
          end
        end
        object TsUretimEkle: TcxTabSheet
          Caption = #220'retim Ekle'
          ImageIndex = 2
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 890
            Height = 132
            Align = alTop
            TabOrder = 0
            object cxLabel4: TcxLabel
              Left = 287
              Top = 90
              Caption = 'S'#305'ra Numaras'#305' Ba'#351'lang'#305#231
            end
            object EdtUrunSiraNoBaslangic: TcxTextEdit
              Left = 287
              Top = 105
              TabOrder = 1
              Text = '1030237'
              Width = 150
            end
            object cxLabel5: TcxLabel
              Left = 218
              Top = 4
              Caption = 'Lot Numaras'#305
            end
            object EdtUrunLotNo: TcxTextEdit
              Left = 216
              Top = 22
              TabOrder = 3
              Width = 150
            end
            object cxLabel6: TcxLabel
              Left = 372
              Top = 4
              Caption = 'Son Kullanma Tarihi'
            end
            object DtUrunSonKullanim: TcxDateEdit
              Left = 372
              Top = 22
              TabOrder = 5
              Width = 152
            end
            object EdtUrunAdet: TcxTextEdit
              Left = 168
              Top = 22
              TabOrder = 6
              Width = 42
            end
            object cxLabel7: TcxLabel
              Left = 168
              Top = 4
              Caption = 'Adet'
            end
            object BtnUrunEkle: TcxButton
              Left = 533
              Top = 101
              Width = 75
              Height = 25
              Caption = #220'ret'
              TabOrder = 8
              OnClick = BtnUrunEkleClick
            end
            object EdtUrunBarkodNumarasi: TcxTextEdit
              Left = 11
              Top = 22
              TabOrder = 9
              Width = 150
            end
            object cxLabel8: TcxLabel
              Left = 11
              Top = 6
              Caption = 'Barkod Numaras'#305' (GTIN)'
            end
            object cxLabel12: TcxLabel
              Left = 11
              Top = 42
              Caption = #220'retim Tipi'
            end
            object cxLabel13: TcxLabel
              Left = 167
              Top = 42
              Caption = #220'r'#252'n Cinsi'
            end
            object CmbUrunUrunCinsi: TcxImageComboBox
              Left = 167
              Top = 57
              EditValue = 'PP'
              Properties.DefaultImageIndex = 0
              Properties.Items = <
                item
                  Description = #304'la'#231
                  ImageIndex = 0
                  Value = 'PP'
                end
                item
                  Description = 'Ara '#220'r'#252'n'
                  Value = 'BP'
                end
                item
                  Description = 'Besleme '#220'r'#252'n'
                  Value = 'FP'
                end>
              TabOrder = 13
              Width = 150
            end
            object CmbUrunUretimTipi: TcxImageComboBox
              Left = 11
              Top = 57
              EditValue = 'M'
              Properties.DefaultImageIndex = 0
              Properties.Items = <
                item
                  Description = #220'retim'
                  ImageIndex = 0
                  Value = 'M'
                end
                item
                  Description = #304'thalat'
                  Value = #304
                end>
              TabOrder = 14
              Width = 150
            end
            object DtUrunUretimTarihi: TcxDateEdit
              Left = 323
              Top = 57
              TabOrder = 15
              Width = 152
            end
            object cxLabel14: TcxLabel
              Left = 323
              Top = 42
              Caption = #220'retim Tarihi Tarihi'
            end
            object cxLabel19: TcxLabel
              Left = 172
              Top = 90
              Caption = 'Sabit'
            end
            object cxLabel20: TcxLabel
              Left = 226
              Top = 90
              Caption = 'Hane'
            end
            object EdtUrunSabit: TcxTextEdit
              Left = 172
              Top = 105
              TabOrder = 19
              Text = '90'
              Width = 48
            end
            object CmbUrunHane: TcxComboBox
              Left = 226
              Top = 105
              Properties.DropDownListStyle = lsFixedList
              Properties.Items.Strings = (
                '5'
                '6'
                '7'
                '8'
                '9'
                '10'
                '11'
                '12'
                '13'
                '14'
                '15'
                '16'
                '18'
                '19'
                '20')
              TabOrder = 20
              Text = '9'
              Width = 58
            end
            object cxLabel21: TcxLabel
              Left = 11
              Top = 89
              Caption = 'En son S'#305'ra Numaras'#305
            end
            object LblEnSonSira: TcxLabel
              Left = 11
              Top = 105
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clNavy
              Style.Font.Height = -13
              Style.Font.Name = 'Tahoma'
              Style.Font.Style = []
              Style.IsFontAssigned = True
            end
          end
          object Panel7: TPanel
            Left = 0
            Top = 132
            Width = 890
            Height = 36
            Align = alTop
            TabOrder = 1
            object TxtUrunAraSiraNo: TcxTextEdit
              Left = 86
              Top = 8
              TabOrder = 0
              Width = 150
            end
            object cxLabel17: TcxLabel
              Left = 11
              Top = 7
              Caption = 'S'#305'ra Numaras'#305
            end
            object BtnUrunArama: TcxButton
              Left = 242
              Top = 4
              Width = 75
              Height = 25
              Caption = 'Ara'
              TabOrder = 2
            end
          end
          object Panel8: TPanel
            Left = 0
            Top = 168
            Width = 201
            Height = 250
            Align = alLeft
            TabOrder = 2
            object Panel9: TPanel
              Left = 1
              Top = 1
              Width = 199
              Height = 16
              Align = alTop
              TabOrder = 0
              object cxLabel18: TcxLabel
                Left = 3
                Top = -2
                Caption = 'Daha '#246'nceden verilmi'#351' s'#305'ra numaralar'#305
              end
            end
            object GridAyniKayit: TDBGrid
              Left = 1
              Top = 17
              Width = 199
              Height = 232
              Align = alClient
              BorderStyle = bsNone
              DataSource = DtsAyniKayit
              Options = [dgTitles, dgColLines, dgRowLines, dgTabs]
              ReadOnly = True
              TabOrder = 1
              TitleFont.Charset = TURKISH_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              Columns = <
                item
                  Expanded = False
                  FieldName = 'URUNBARKOD'
                  Visible = True
                end
                item
                  Expanded = False
                  FieldName = 'SIRANO'
                  Visible = True
                end>
            end
          end
          object GridUretimCx: TcxGrid
            Left = 458
            Top = 175
            Width = 389
            Height = 199
            TabOrder = 3
            object GridUretimCxDBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              object GridUretimCxDBTableView1URUNBARKOD: TcxGridDBColumn
                DataBinding.FieldName = 'URUNBARKOD'
              end
              object GridUretimCxDBTableView1SIRANO: TcxGridDBColumn
                DataBinding.FieldName = 'SIRANO'
              end
              object GridUretimCxDBTableView1LOTNO: TcxGridDBColumn
                DataBinding.FieldName = 'LOTNO'
              end
              object GridUretimCxDBTableView1SONKULLANIM: TcxGridDBColumn
                DataBinding.FieldName = 'SONKULLANIM'
              end
            end
            object GridUretimCxLevel1: TcxGridLevel
              GridView = GridUretimCxDBTableView1
            end
          end
          object Memo1: TMemo
            Left = 600
            Top = 174
            Width = 261
            Height = 27
            Lines.Strings = (
              'DECLARE @BARKOD VARCHAR(14)'
              ''
              'DECLARE @SIRABASLA INT'
              'DECLARE @ADET INT'
              'DECLARE @SIRAEK VARCHAR(20)'
              'DECLARE @ARTIR INT'
              'DECLARE @SIRANO VARCHAR(20)'
              ''
              'SET @BARKOD =:BARKOD'
              ''
              'SET @SIRABASLA =:SIRABASLA'
              'SET @ADET=:ADET'
              'SET @SIRAEK =:SIRAEK'
              'SET @ARTIR  = 1'
              ''
              'DECLARE CRS_PERSONEL CURSOR FOR SELECT  '
              '@BARKOD,@SIRABASLA,@ADET,@SIRAEK,@ARTI'
              'R'
              ''
              'OPEN CRS_PERSONEL'
              ''
              'FETCH NEXT FROM CRS_PERSONEL INTO '
              '@BARKOD,@SIRABASLA,@ADET,@SIRAEK,@ARTI'
              'R'
              '    WHILE @@FETCH_STATUS = 0'
              #9'BEGIN'
              #9#9'WHILE @SIRABASLA + '
              '@ARTIR  <= '
              '@ADET +@SIRABASLA '
              #9#9'BEGIN'
              #9#9#9'SET @SIRANO = '
              '@SIRAEK'
              '+CONVERT(VARCHAR'
              '(20),@SIRABASLA + @ARTIR)'
              #9#9#9'if not exists(select * '
              'from '
              'STOKID C1 where '
              'SIRANO=@SIRANO AND '
              'URUNBARKOD=@BARKOD)'
              #9#9#9'begin'
              #9#9#9#9'INSERT '
              'INTO '
              'GECICI_KAREKOD '
              '(SIRANO,BARKOD)VALUES (@SIRANO,@BARKOD)'
              #9#9#9'end'
              #9#9#9'SET @ARTIR = '
              '@ARTIR + 1'
              #9#9'END'
              #9#9
              #9'FETCH NEXT FROM CRS_PERSONEL INTO '
              '@BARKOD,@SIRABASLA,@ADET,@SIRAEK,@ARTI'
              'R'
              #9'END'
              ''
              'CLOSE CRS_PERSONEL'
              ''
              'DEALLOCATE CRS_PERSONEL'
              ''
              'SELECT * FROM STOKID WHERE '
              'GIRFATID=999999'
              ''
              '')
            TabOrder = 4
            Visible = False
          end
          object MemoCreate: TMemo
            Left = 287
            Top = 27
            Width = 509
            Height = 51
            Lines.Strings = (
              'IF EXISTS (select * from '
              'sys.objects '
              'where type ='#39'U'#39' AND name '
              '='#39'GECICI_KAREKOD'#39')'
              'BEGIN'
              '    DROP TABLE GECICI_KAREKOD'
              'END'
              'CREATE TABLE GECICI_KAREKOD'
              '('
              '   BARKOD VARCHAR(14),'
              '   SIRANO VARCHAR(20)'
              ')')
            TabOrder = 5
            Visible = False
          end
          object GridUretimStandart: TDBGrid
            Left = 201
            Top = 168
            Width = 689
            Height = 250
            Align = alClient
            BorderStyle = bsNone
            DataSource = DtsUretim
            Options = [dgTitles, dgColLines, dgRowLines, dgTabs]
            ReadOnly = True
            TabOrder = 6
            TitleFont.Charset = TURKISH_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            Columns = <
              item
                Expanded = False
                FieldName = 'URUNBARKOD'
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'SIRANO'
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'LOTNO'
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'SONKULLANIM'
                Visible = True
              end>
          end
        end
        object TsUretimDuzenleCikis: TcxTabSheet
          Caption = #199#305'k'#305#351' '
          ImageIndex = 3
          object Panel12: TPanel
            Left = 0
            Top = 0
            Width = 890
            Height = 41
            Align = alTop
            TabOrder = 0
            object cxLabel22: TcxLabel
              Left = 3
              Top = 11
              Caption = 'S'#305'raNo Ekleme'
              Transparent = True
            end
            object EdtSiraNoEkleme: TcxTextEdit
              Left = 80
              Top = 11
              TabOrder = 1
              OnKeyPress = EdtSiraNoEklemeKeyPress
              Width = 165
            end
            object cxLabel24: TcxLabel
              Left = 249
              Top = 13
              Caption = 'Etiketen Getir'
              Transparent = True
              Visible = False
            end
            object EdtSSCC: TcxTextEdit
              Left = 322
              Top = 11
              TabOrder = 3
              Visible = False
              OnKeyPress = EdtSSCCKeyPress
              Width = 175
            end
          end
          object Panel13: TPanel
            Left = 0
            Top = 41
            Width = 890
            Height = 377
            Align = alClient
            TabOrder = 1
            object GridUretimSatis: TcxGrid
              Left = 1
              Top = 28
              Width = 888
              Height = 348
              Align = alClient
              TabOrder = 0
              object TvUretimSAtis: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsUretimSatis
                DataController.KeyFieldNames = 'ID'
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.Deleting = False
                OptionsData.Inserting = False
                OptionsView.GroupByBox = False
                Styles.OnGetContentStyle = tvSeriNoListesiStylesGetContentStyle
                object vUretimSAtisColumn1: TcxGridDBColumn
                  DataBinding.FieldName = 'SSCC'
                  Options.Editing = False
                end
                object cxGridDBColumn7: TcxGridDBColumn
                  Caption = 'Barkod'
                  DataBinding.FieldName = 'URUNBARKOD'
                  Options.Editing = False
                  Width = 83
                end
                object cxGridDBColumn8: TcxGridDBColumn
                  Caption = 'S'#305'ra No'
                  DataBinding.FieldName = 'SIRANO'
                  PropertiesClassName = 'TcxTextEditProperties'
                  Options.Editing = False
                  Width = 71
                end
                object cxGridDBColumn9: TcxGridDBColumn
                  Caption = 'LotNo'
                  DataBinding.FieldName = 'LOTNO'
                  Options.Editing = False
                  Width = 76
                end
                object cxGridDBColumn10: TcxGridDBColumn
                  Caption = 'Son Kullan'#305'm'
                  DataBinding.FieldName = 'SONKULLANIM'
                  Options.Editing = False
                  Width = 82
                end
                object cxGridDBColumn11: TcxGridDBColumn
                  DataBinding.FieldName = 'SONKULLANIM'
                  Visible = False
                  Options.Editing = False
                end
                object cxGridDBColumn12: TcxGridDBColumn
                  Caption = #220'retim Tarihi'
                  DataBinding.FieldName = 'URETIMTARIHI'
                  Options.Editing = False
                end
              end
              object GlUretimSatis: TcxGridLevel
                GridView = TvUretimSAtis
              end
            end
            object ToolBar1: TToolBar
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 882
              Height = 24
              Margins.Bottom = 0
              AutoSize = True
              ButtonWidth = 85
              Caption = 'TbAletCubugu'
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
              object BtnCikar: TToolButton
                Left = 0
                Top = 0
                Caption = 'Listeden '#199#305'kar'
                ImageIndex = 17
                Style = tbsTextButton
                OnClick = BtnCikarClick
              end
              object ToolButton2: TToolButton
                Left = 85
                Top = 0
                Width = 8
                Caption = 'ToolButton10'
                ImageIndex = 20
                Style = tbsSeparator
              end
            end
          end
        end
      end
    end
    object TsSeriNo: TcxTabSheet
      Caption = 'Seri No'
      ImageIndex = 1
      object pgSeriNo: TcxPageControl
        Left = 0
        Top = 0
        Width = 894
        Height = 445
        Align = alClient
        TabOrder = 0
        Properties.ActivePage = shtSeriNoGiris
        Properties.CustomButtons.Buttons = <>
        OnChange = pgSeriNoChange
        ClientRectBottom = 443
        ClientRectLeft = 2
        ClientRectRight = 892
        ClientRectTop = 25
        object shtSeriNoGiris: TcxTabSheet
          Caption = 'Seri No Giri'#351
          ImageIndex = 0
          object memoSeriNolar: TcxMemo
            Left = 3
            Top = 24
            Properties.ScrollBars = ssVertical
            Properties.WordWrap = False
            Properties.OnChange = memoSeriNolarPropertiesChange
            Properties.OnEditValueChanged = memoSeriNolarPropertiesEditValueChanged
            TabOrder = 0
            Height = 328
            Width = 246
          end
          object cxLabel15: TcxLabel
            Left = 11
            Top = 1
            Caption = '**Seri Numaralar'#305'n'#305' sat'#305'r sat'#305'r olacak '#351'ekilde giriniz.'
            Properties.WordWrap = True
            Transparent = True
            Width = 246
          end
          object memoHataliSeriNo: TcxMemo
            Left = 282
            Top = 19
            Properties.ScrollBars = ssVertical
            Properties.WordWrap = False
            Style.Color = 8421631
            TabOrder = 2
            Visible = False
            Height = 328
            Width = 246
          end
          object lblHataliSeriNo: TcxLabel
            Left = 283
            Top = 1
            Caption = 'Hatal'#305' Seri Numaralar'#305
          end
        end
        object shtSeriNoDuzeltSil: TcxTabSheet
          Caption = 'Seri No D'#252'zeltme-Silme'
          ImageIndex = 1
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 890
            Height = 36
            Align = alTop
            TabOrder = 0
            object editSeriNo: TcxTextEdit
              Left = 120
              Top = 9
              TabOrder = 0
              OnKeyUp = editSeriNoKeyUp
              Width = 121
            end
            object cxLabel16: TcxLabel
              Left = 77
              Top = 11
              Caption = 'Seri No'
              Transparent = True
            end
          end
          object gridSeriNoListesi: TcxGrid
            Left = 0
            Top = 36
            Width = 890
            Height = 382
            Align = alClient
            TabOrder = 1
            object tvSeriNoListesi: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = dtsSeriNoListesi
              DataController.KeyFieldNames = 'ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              Styles.OnGetContentStyle = tvSeriNoListesiStylesGetContentStyle
              object clmSeriNoSec: TcxGridDBColumn
                Caption = 'Se'#231
                DataBinding.ValueType = 'Boolean'
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ImmediatePost = True
                Properties.NullStyle = nssUnchecked
                Properties.OnChange = clmSeriNoSecPropertiesChange
                Properties.OnEditValueChanged = clmSeriNoSecPropertiesEditValueChanged
                Width = 40
              end
              object clmSeriNo: TcxGridDBColumn
                Caption = 'Seri No'
                DataBinding.FieldName = 'SERINO'
                PropertiesClassName = 'TcxTextEditProperties'
                Width = 110
              end
              object clmGarantiBitis: TcxGridDBColumn
                Caption = 'Garanti Biti'#351
                DataBinding.FieldName = 'GARANTIBITIS'
                Width = 82
              end
              object cxGridDBColumn1: TcxGridDBColumn
                DataBinding.FieldName = 'CIKFATURAID'
                Visible = False
                Options.Editing = False
              end
            end
            object gridSeriNoListesiLevel1: TcxGridLevel
              GridView = tvSeriNoListesi
            end
          end
        end
      end
      object edGarantiSure: TcxSpinEdit
        Left = 373
        Top = 0
        TabOrder = 1
        Width = 53
      end
      object lblGarantiSure: TcxLabel
        Left = 328
        Top = 1
        Caption = 'Garanti                     Ay'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.WordWrap = True
        Transparent = True
        Width = 116
      end
    end
  end
  object pnlAlt: TPanel
    Left = 0
    Top = 0
    Width = 898
    Height = 81
    Align = alTop
    TabOrder = 1
    object Lbl1: TcxLabel
      Left = 395
      Top = 59
      Caption = 'Se'#231'ilen Kay'#305't Say'#305's'#305
      Transparent = True
    end
    object lblKayitSayisi: TcxLabel
      Left = 503
      Top = 60
      Caption = '0'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lblHataMesaj: TcxLabel
      Left = 4
      Top = 39
      AutoSize = False
      Caption = 'lblHataMesaj'
      Style.TextColor = clRed
      Properties.WordWrap = True
      Transparent = True
      Height = 38
      Width = 375
    end
    object cxLabel3: TcxLabel
      Left = 395
      Top = 42
      Caption = 'Gerekli Kay'#305't Say'#305's'#305
      Transparent = True
    end
    object lblGerekliSayi: TcxLabel
      Left = 503
      Top = 43
      Caption = '0'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -11
      Style.Font.Name = 'Trebuchet MS'
      Style.Font.Style = []
      Style.TextColor = clRed
      Style.IsFontAssigned = True
      Transparent = True
    end
    object TbAletCubugu: TToolBar
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 890
      Margins.Bottom = 0
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 107
      Caption = 'TbAletCubugu'
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
      TabOrder = 5
      Transparent = True
      object btnKaydet: TToolButton
        Left = 0
        Top = 0
        Caption = #304#351'lemi Tamamla'
        ImageIndex = 11
        Style = tbsTextButton
        OnClick = btnKaydetClick
      end
      object ToolButton10: TToolButton
        Left = 107
        Top = 0
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 20
        Style = tbsSeparator
      end
      object btnIptal: TToolButton
        Left = 115
        Top = 0
        Caption = #304'ptal'
        ImageIndex = 17
      end
      object BtnKapat: TToolButton
        Left = 222
        Top = 0
        Caption = 'Kapat'
        ImageIndex = 18
        OnClick = BtnKapatClick
      end
      object BtnUretim: TToolButton
        Left = 329
        Top = 0
        Caption = #220'retim'
        ImageIndex = 19
        OnClick = BtnUretimClick
      end
      object BtnPaket: TToolButton
        Left = 436
        Top = 0
        Caption = 'Paket'
        ImageIndex = 20
        OnClick = BtnUretimClick
      end
    end
  end
  object dtsKareKodListesi: TDataSource
    DataSet = tabKareKodListesi
    OnStateChange = dtsKareKodListesiStateChange
    Left = 530
    Top = 212
  end
  object tabKareKodListesi: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = tabKareKodListesiBeforeEdit
    BeforePost = tabKareKodListesiBeforePost
    AfterPost = tabKareKodListesiAfterPost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KAREKOD K,STOKID SI WHERE SI.ID=K.STOKIDID')
    Left = 526
    Top = 170
  end
  object DtsKareKodGoster: TDataSource
    DataSet = QryKareKodGoster
    Left = 593
    Top = 199
  end
  object QryKareKodGoster: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KAREKOD')
    Left = 589
    Top = 156
  end
  object dtsSeriNoListesi: TDataSource
    DataSet = tabSeriNoListesi
    OnStateChange = dtsSeriNoListesiStateChange
    Left = 463
    Top = 202
  end
  object tabSeriNoListesi: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = tabSeriNoListesiBeforeEdit
    BeforePost = tabSeriNoListesiBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM STOKID')
    Left = 459
    Top = 159
    object tabSeriNoListesiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object tabSeriNoListesiGIRISTURU: TWordField
      FieldName = 'GIRISTURU'
    end
    object tabSeriNoListesiSTOKID: TIntegerField
      FieldName = 'STOKID'
    end
    object tabSeriNoListesiGIRFATBASID: TIntegerField
      FieldName = 'GIRFATBASID'
    end
    object tabSeriNoListesiGIRFATURAID: TIntegerField
      FieldName = 'GIRFATURAID'
    end
    object tabSeriNoListesiURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object tabSeriNoListesiSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object tabSeriNoListesiSERINO: TStringField
      FieldName = 'SERINO'
    end
    object tabSeriNoListesiCIKISTURU: TWordField
      FieldName = 'CIKISTURU'
    end
    object tabSeriNoListesiCIKFATBASID: TIntegerField
      FieldName = 'CIKFATBASID'
    end
    object tabSeriNoListesiCIKFATURAID: TIntegerField
      FieldName = 'CIKFATURAID'
    end
    object tabSeriNoListesiGARANTIBITIS: TDateTimeField
      FieldName = 'GARANTIBITIS'
    end
    object tabSeriNoListesiIZLEMTURU: TWordField
      FieldName = 'IZLEMTURU'
    end
    object tabSeriNoListesiONAY: TBooleanField
      FieldName = 'ONAY'
    end
    object tabSeriNoListesiSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object tabSeriNoListesiLOTNO: TStringField
      FieldName = 'LOTNO'
    end
  end
  object TabUretim: TFDQuery
    Connection = Tablo.FDCnn
    AfterScroll = TabUretimAfterScroll
    ParamData = <>
    SQL.Strings = (
      
        'INSERT INTO STOKID (GIRISTURU,STOKID,GIRFATBASID,GIRFATURAID,URU' +
        'NBARKOD,SIRANO,GARANTIBITIS,IZLEMTURU,ONAY,SONKULLANIM,LOTNO,URE' +
        'TIMTIPI,URUNCINSI,URETIMTARIHI)'
      
        'SELECT :GIRISTURU,:STOKID,99999,99999,BARKOD,SIRANO,GETDATE(),3,' +
        '1,:SONKULLANIM,:LOTNO,:URETIMTIPI,:URUNCINSI,:URETIMTARIHI FROM ' +
        'GECICI_KAREKOD '
      ''
      'INSERT INTO KAREKOD (STOKIDID,STOKID,MALALINANGLN) '
      'SELECT ID,STOKID,:GLN FROM STOKID WHERE GIRFATBASID=99999'
      ''
      
        'SELECT URUNBARKOD,SIRANO,LOTNO,SONKULLANIM FROM STOKID WHERE GIR' +
        'FATBASID=99999 ')
    Left = 403
    Top = 172
    object TabUretimURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabUretimSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabUretimLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabUretimSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
  end
  object DtsUretim: TDataSource
    DataSet = TabUretim
    OnStateChange = dtsSeriNoListesiStateChange
    Left = 406
    Top = 218
  end
  object TabAyniKayit: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'IF EXISTS (select * from sys.objects where type ='#39'U'#39' AND name ='#39 +
        'GECICI_KAREKOD'#39')'
      'BEGIN'
      '    DROP TABLE GECICI_KAREKOD'
      'END'
      'CREATE TABLE GECICI_KAREKOD'
      '('
      '   BARKOD VARCHAR(14),'
      '   SIRANO VARCHAR(20)'
      ')'
      ''
      'DECLARE @BARKOD VARCHAR(14)'
      ''
      'DECLARE @SIRABASLA INT'
      'DECLARE @ADET INT'
      'DECLARE @SIRAEK VARCHAR(20)'
      'DECLARE @ARTIR INT'
      'DECLARE @SIRANO VARCHAR(20)'
      'DECLARE @OLANSIRANOLAR VARCHAR(500)'
      ''
      ''
      ''
      ''
      'SET @SIRABASLA =:SIRABASLA'
      'SET @ADET =:ADET'
      'SET @SIRAEK =:SIRAEK'
      'SET @ARTIR  = 1'
      'SET @BARKOD = :BARKOD'
      ''
      
        '--'#304'LK OLARAK EKLENECEK KAREKODLAR B'#304'R TEMP TABLOYA ATILIYOR VE K' +
        'ONTROL EDILMAK ICIN'
      
        'DECLARE CRS_PERSONEL CURSOR FOR SELECT  @BARKOD,@SIRABASLA,@ADET' +
        ',@SIRAEK,@ARTIR'
      'OPEN CRS_PERSONEL'
      
        'FETCH NEXT FROM CRS_PERSONEL INTO @BARKOD,@SIRABASLA,@ADET,@SIRA' +
        'EK,@ARTIR'
      '    WHILE @@FETCH_STATUS = 0'
      #9'BEGIN'
      #9#9'WHILE @SIRABASLA + @ARTIR  <= @SIRABASLA + @ADET '
      #9#9'BEGIN'
      
        #9#9#9'SET @SIRANO = @SIRAEK+CONVERT(VARCHAR(20),@SIRABASLA + @ARTIR' +
        ')'
      
        #9#9#9'INSERT INTO GECICI_KAREKOD (BARKOD,SIRANO)VALUES (@BARKOD,@SI' +
        'RANO)'
      #9#9#9
      
        '                                                  SET @ARTIR = @' +
        'ARTIR + 1'
      #9#9#9'--SET @OLANSIRANOLAR =  @OLANSIRANOLAR +'#39','#39'+@SIRANO'
      #9#9'END'
      
        #9'FETCH NEXT FROM CRS_PERSONEL INTO @BARKOD,@SIRABASLA,@ADET,@SIR' +
        'AEK,@ARTIR'
      #9'END'#9#9#9
      'CLOSE CRS_PERSONEL'
      'DEALLOCATE CRS_PERSONEL'
      
        '----------------------------------------------------------------' +
        '--------------------'#9
      
        '-----Olan Kay'#305'tlar getiriiyor-----------------------------------' +
        '--------------------'#9#9
      '--SELECT SI.URUNBARKOD,SI.SERINO FROM STOKID SI '
      '--WHERE EXISTS('
      '--SELECT * FROM GECICI_KAREKOD GK '
      '--where GK.BARKOD = SI.URUNBARKOD '
      '--AND GK.SIRANO=SI.SIRANO)'#9#9#9
      'SELECT * FROM STOKID WHERE 1=2'
      
        '----------------------------------------------------------------' +
        '--------------------'#9)
    Left = 760
    Top = 169
  end
  object DtsAyniKayit: TDataSource
    DataSet = TabAyniKayit
    OnStateChange = dtsSeriNoListesiStateChange
    Left = 764
    Top = 212
  end
  object TabUretimSatis: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'SELECT  S.ID,S.URUNBARKOD,S.SIRANO,S.LOTNO,S.SONKULLANIM,S.URETI' +
        'MTARIHI,GK.UYARI,S.PAKETID  FROM  GECICI_EKLENECEK_KAREKOD GK'
      '                         INNER JOIN STOKID S ON S.ID=GK.STOKIDID'
      
        '                         INNER JOIN KAREKOD K ON K.STOKIDID = GK' +
        '.STOKIDID'
      ''
      ''
      ''
      '')
    Left = 707
    Top = 155
    object TabUretimSatisURUNBARKOD: TStringField
      FieldName = 'URUNBARKOD'
    end
    object TabUretimSatisSIRANO: TStringField
      FieldName = 'SIRANO'
    end
    object TabUretimSatisLOTNO: TStringField
      FieldName = 'LOTNO'
    end
    object TabUretimSatisSONKULLANIM: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object TabUretimSatisURETIMTARIHI: TDateTimeField
      FieldName = 'URETIMTARIHI'
    end
    object TabUretimSatisUYARI: TStringField
      FieldName = 'UYARI'
      Size = 50
    end
    object TabUretimSatisID: TIntegerField
      FieldName = 'ID'
    end
  end
  object DtsUretimSatis: TDataSource
    DataSet = TabUretimSatis
    OnDataChange = DtsUretimSatisDataChange
    Left = 710
    Top = 200
  end
  object TabSatisEkle: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'INSERT INTO GECICI_EKLENECEK_KAREKOD(STOKIDID,UYARI)'
      
        'SELECT SI.ID,'#39#220'retim Durum : '#39'+ K.URETIM_DURUM + '#39' Sat'#305#351' Durum :' +
        ' '#39' +ISNULL(K.SATIS_DURUM,'#39#39')  AS DURUM'
      ' FROM STOKID SI'
      #9#9'INNER JOIN KAREKOD K ON K.STOKIDID =SI.ID'
      
        #9#9'WHERE SI.SIRANO =:SIRANO AND (SI.URUNBARKOD =:BARKOD OR SI.STO' +
        'KID=:STOKID)'
      
        #9#9'AND (SUBSTRING(K.URETIM_DURUM,1,6) ='#39'00000'#39' OR SUBSTRING(K.ALI' +
        'M_DURUM,1,6) ='#39'00000'#39')'
      
        '                                AND ISNULL(SI.CIKFATURAID,0)=0  ' +
        'AND  SI.ID  NOT IN (SELECT GEK.STOKIDID FROM GECICI_EKLENECEK_KA' +
        'REKOD GEK )   '
      ''
      '                                '
      '')
    Left = 650
    Top = 172
  end
  object TabKarekodSatilacakListesi: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'SELECT SI.ID,SIRANO,URUNBARKOD,SI.URETIMTARIHI,SI.LOTNO,SI.SONKU' +
        'LLANIM,'#39#220'retim Durum : '#39'+ ISNULL(K.URETIM_DURUM,'#39#39') + '#39' Sat'#305#351' Du' +
        'rum : '#39' +ISNULL(K.SATIS_DURUM,'#39#39') '
      ' FROM STOKID SI'
      #9#9'INNER JOIN KAREKOD K ON K.STOKIDID =SI.ID'
      #9#9'WHERE SI.STOKID=:STOKID AND '
      
        #9#9'ISNULL(SUBSTRING(K.URETIM_DURUM,1,6) ,'#39#39')= '#39'00000'#39' AND ISNULL(' +
        ' SUBSTRING(K.SATIS_DURUM,1,6),'#39#39') <> '#39'00000'#39)
    Left = 460
    Top = 259
    object AutoIncField1: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object StringField1: TStringField
      FieldName = 'URUNBARKOD'
    end
    object StringField2: TStringField
      FieldName = 'SIRANO'
    end
    object DateTimeField2: TDateTimeField
      FieldName = 'SONKULLANIM'
    end
    object StringField4: TStringField
      FieldName = 'LOTNO'
    end
    object TabKarekodSatilacakListesiURETIMTARIHI: TDateField
      FieldName = 'URETIMTARIHI'
    end
  end
  object DtsKarekodSatilacakListesi: TDataSource
    DataSet = TabKarekodSatilacakListesi
    OnStateChange = dtsSeriNoListesiStateChange
    Left = 461
    Top = 303
  end
end

