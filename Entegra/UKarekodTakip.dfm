object KareKodDlg: TKareKodDlg
  Left = 0
  Top = 0
  Caption = 'KareKod Takip '#304#351'lemleri'
  ClientHeight = 464
  ClientWidth = 835
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Pgizlem: TcxPageControl
    Left = 0
    Top = 0
    Width = 835
    Height = 464
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = TsKarekod
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 464
    ClientRectRight = 835
    ClientRectTop = 24
    object TsKarekod: TcxTabSheet
      Caption = 'Karekod'
      ImageIndex = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object pnlAlt: TPanel
        Left = 0
        Top = 0
        Width = 835
        Height = 88
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 831
        object lbKayitSay: TcxLabel
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
          Left = 6
          Top = 43
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
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 827
          Height = 29
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 108
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
          Images = AnaForm.PNGImageList1
          List = True
          ParentColor = False
          ParentFont = False
          ShowCaptions = True
          TabOrder = 5
          Transparent = True
          ExplicitWidth = 823
          object btnKaydet: TToolButton
            Left = 0
            Top = 0
            Caption = #304#351'lemi Tamamla'
            ImageIndex = 11
            Style = tbsTextButton
            OnClick = btnKaydetClick
          end
          object ToolButton10: TToolButton
            Left = 108
            Top = 0
            Width = 8
            Caption = 'ToolButton10'
            ImageIndex = 20
            Style = tbsSeparator
          end
          object btnIptal: TToolButton
            Left = 116
            Top = 0
            Caption = #304'ptal'
            ImageIndex = 17
          end
          object ToolButton1: TToolButton
            Left = 224
            Top = 0
            Caption = 'Kapat'
            ImageIndex = 18
            OnClick = ToolButton1Click
          end
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 88
        Width = 835
        Height = 85
        Align = alTop
        TabOrder = 1
        ExplicitWidth = 831
        object cxLabel4: TcxLabel
          Left = 167
          Top = 4
          Caption = 'S'#305'ra Numaras'#305
        end
        object EdtSiraNo1: TcxTextEdit
          Left = 167
          Top = 22
          TabOrder = 1
          Width = 150
        end
        object cxLabel5: TcxLabel
          Left = 373
          Top = 4
          Caption = 'Lot Numaras'#305
        end
        object EdtLotNo: TcxTextEdit
          Left = 371
          Top = 22
          TabOrder = 3
          Width = 150
        end
        object cxLabel6: TcxLabel
          Left = 527
          Top = 4
          Caption = 'Son Kullanma Tarihi'
        end
        object DtSonKullanim: TcxDateEdit
          Left = 527
          Top = 22
          TabOrder = 5
          Width = 152
        end
        object EdtAdet: TcxTextEdit
          Left = 323
          Top = 22
          TabOrder = 6
          Width = 42
        end
        object cxLabel7: TcxLabel
          Left = 323
          Top = 4
          Caption = 'Adet'
        end
        object BtnEkle: TcxButton
          Left = 685
          Top = 18
          Width = 75
          Height = 25
          Caption = 'Ekle'
          TabOrder = 8
          OnClick = BtnEkleClick
        end
        object EdtBarkodNumarasi: TcxTextEdit
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
        object TxtTransferNo: TcxTextEdit
          Left = 11
          Top = 58
          TabOrder = 11
          Width = 150
        end
        object cxLabel9: TcxLabel
          Left = 11
          Top = 42
          Caption = 'Transfer No (SSCS)'
        end
        object cxButton1: TcxButton
          Left = 167
          Top = 52
          Width = 98
          Height = 25
          Caption = #220'r'#252'nleri Getir'
          TabOrder = 13
          OnClick = cxButton1Click
        end
      end
      object pgKareKod: TcxPageControl
        Left = 0
        Top = 173
        Width = 835
        Height = 267
        Align = alClient
        TabOrder = 2
        Properties.ActivePage = shtKareKodGiris
        Properties.CustomButtons.Buttons = <>
        OnChange = pgKareKodChange
        ExplicitWidth = 831
        ExplicitHeight = 264
        ClientRectBottom = 267
        ClientRectRight = 835
        ClientRectTop = 24
        object shtKareKodGiris: TcxTabSheet
          Caption = 'KareKod Giri'#351
          ImageIndex = 0
          ExplicitLeft = 2
          ExplicitTop = 25
          ExplicitWidth = 827
          ExplicitHeight = 237
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 384
            Height = 243
            Align = alLeft
            TabOrder = 0
            ExplicitHeight = 237
            object memoKareKodlar: TcxMemo
              Left = 1
              Top = 18
              Align = alClient
              Properties.ScrollBars = ssVertical
              Properties.WordWrap = False
              Properties.OnChange = memoKareKodlarPropertiesChange
              Properties.OnEditValueChanged = memoKareKodlarPropertiesEditValueChanged
              TabOrder = 0
              ExplicitTop = 16
              ExplicitHeight = 220
              Height = 224
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
          object TreeListKareKod: TcxTreeList
            Left = 388
            Top = 0
            Width = 447
            Height = 243
            Hint = ''
            Align = alRight
            Bands = <
              item
              end>
            Navigator.Buttons.CustomButtons = <>
            TabOrder = 1
            OnDataChanged = TreeListKareKodDataChanged
            ExplicitLeft = 380
            ExplicitHeight = 237
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
        object shtKareKodDuzeltSil: TcxTabSheet
          Caption = 'KareKod '#199#305'k'#305#351' - D'#252'zeltme - Silme'
          ImageIndex = 1
          ExplicitLeft = 2
          ExplicitTop = 25
          ExplicitWidth = 827
          ExplicitHeight = 237
          object gridKareKodListesi: TcxGrid
            Left = 0
            Top = 36
            Width = 835
            Height = 207
            Align = alClient
            TabOrder = 0
            object tvSeriNoListesi: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = dtsKareKodListesi
              DataController.KeyFieldNames = 'ID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.Deleting = False
              OptionsData.Inserting = False
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
              object clmLotno: TcxGridDBColumn
                Caption = 'Lot No'
                DataBinding.FieldName = 'LOTNO'
                Width = 94
              end
              object clmSeriNoCikFaturaId: TcxGridDBColumn
                DataBinding.FieldName = 'CIKFATURAID'
                Visible = False
                Options.Editing = False
              end
              object tvSonKullanma: TcxGridDBColumn
                Caption = 'Son Kullanma S'#252'resi'
                DataBinding.FieldName = 'SONKULLANIM'
                Width = 138
              end
            end
            object gridKareKodListesiLevel1: TcxGridLevel
              GridView = tvSeriNoListesi
            end
          end
          object Panel1: TPanel
            Left = 0
            Top = 0
            Width = 835
            Height = 36
            Align = alTop
            TabOrder = 1
            ExplicitWidth = 827
            object editKareKod: TcxTextEdit
              Left = 120
              Top = 9
              TabOrder = 0
              OnKeyUp = editKareKodKeyUp
              Width = 121
            end
            object cxLabel2: TcxLabel
              Left = 77
              Top = 11
              Caption = 'Seri No'
              Transparent = True
            end
          end
        end
      end
    end
    object TsSeriNo: TcxTabSheet
      Caption = 'Seri No'
      ImageIndex = 1
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
  object tabKareKodListesi: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = tabKareKodListesiBeforeEdit
    BeforePost = tabKareKodListesiBeforePost
    AfterPost = tabKareKodListesiAfterPost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KAREKOD')
    Left = 789
    Top = 10
  end
  object dtsKareKodListesi: TDataSource
    DataSet = tabKareKodListesi
    OnStateChange = dtsKareKodListesiStateChange
    Left = 740
    Top = 16
  end
  object DtsKareKodGoster: TDataSource
    DataSet = QryKareKodGoster
    OnStateChange = dtsKareKodListesiStateChange
    Left = 788
    Top = 64
  end
  object QryKareKodGoster: TFDQuery
    Connection = Tablo.FDCnn
    BeforeEdit = tabKareKodListesiBeforeEdit
    BeforePost = tabKareKodListesiBeforePost
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KAREKOD')
    Left = 733
    Top = 58
  end
end

