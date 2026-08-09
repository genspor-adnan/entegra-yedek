object OpsiyonTeklifDlg: TOpsiyonTeklifDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Teklif Opsiyonlar'
  ClientHeight = 552
  ClientWidth = 683
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
  object PageControlTeklifListe: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 683
    Height = 511
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = TabSheetTeklif
    Properties.CustomButtons.Buttons = <>
    ExplicitWidth = 549
    ExplicitHeight = 452
    ClientRectBottom = 507
    ClientRectLeft = 4
    ClientRectRight = 679
    ClientRectTop = 27
    object TabSheetTeklif: TcxTabSheet
      Caption = 'Teklif'
      ImageIndex = 4
      ExplicitLeft = 2
      ExplicitTop = 28
      ExplicitWidth = 679
      ExplicitHeight = 481
      object cxGroupBox1: TcxGroupBox
        Left = 39
        Top = 268
        Caption = 'Teklif No'
        TabOrder = 1
        Height = 111
        Width = 137
        object cxLabel1: TcxLabel
          Left = 4
          Top = 21
          Caption = 'Dijit Say'#305's'#305
          Transparent = True
        end
        object EditDijit: TcxSpinEdit
          Left = 92
          Top = 20
          Properties.MaxValue = 10.000000000000000000
          Properties.MinValue = -1.000000000000000000
          TabOrder = 1
          Width = 40
        end
        object CheckSifirla: TcxCheckBox
          Left = 6
          Top = 50
          Caption = 'Y'#305'll'#305'k s'#305'f'#305'rla'
          Properties.Alignment = taRightJustify
          TabOrder = 2
          Transparent = True
        end
      end
      object GBGidFatListe: TcxGroupBox
        Left = 427
        Top = 35
        Caption = 'Teklif Listeleri Ayarlama'
        TabOrder = 0
        Height = 186
        Width = 143
        object GridListeDuzenle: TcxGrid
          Left = 2
          Top = 21
          Width = 139
          Height = 163
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 3
          ExplicitTop = 19
          ExplicitWidth = 137
          ExplicitHeight = 159
          object GridListeDuzenleDBTableView1: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = GridListeDuzenleDBTableView1CellDblClick
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
      object cxButton1: TcxButton
        Left = 430
        Top = 293
        Width = 141
        Height = 25
        Caption = 'Mail '#350'ablonu'
        TabOrder = 2
        OnClick = cxButton1Click
      end
      object cxGroupBox3: TcxGroupBox
        Left = 39
        Top = 35
        Caption = 'Varsay'#305'lan Durumlar'
        TabOrder = 3
        Height = 183
        Width = 281
        object Label5: TLabel
          Left = 5
          Top = 96
          Width = 81
          Height = 16
          Caption = 'Onay Bekleniyor'
        end
        object Label6: TLabel
          Left = 5
          Top = 123
          Width = 49
          Height = 16
          Caption = 'Onayland'#305
        end
        object Label1: TLabel
          Left = 5
          Top = 28
          Width = 84
          Height = 16
          Caption = 'Dok'#252'man Klasor'#252
        end
        object Label2: TLabel
          Left = 5
          Top = 52
          Width = 53
          Height = 16
          Caption = 'Para Birimi'
        end
        object ComboOnayBekleniyor: TcxImageComboBox
          Left = 110
          Top = 92
          RepositoryItem = Tablo.repTeklifDurumu
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 0
          Width = 121
        end
        object ComboOnaylandi: TcxImageComboBox
          Left = 110
          Top = 119
          RepositoryItem = Tablo.repTeklifDurumu
          EditValue = 0
          Properties.ImmediatePost = True
          Properties.ImmediateUpdateText = True
          Properties.Items = <>
          TabOrder = 1
          Width = 121
        end
        object VarsayilanKlasor: TcxButtonEdit
          Left = 110
          Top = 24
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = VarsayilanKlasorPropertiesButtonClick
          TabOrder = 2
          Text = 'VarsayilanKlasor'
          Width = 160
        end
        object ComboTekVarsKur: TcxComboBox
          Left = 110
          Top = 49
          RepositoryItem = Tablo.cxEditRepository1ComboBoxItemKurlar
          TabOrder = 3
          Text = 'TL'
          Width = 57
        end
      end
      object TeklifDurum: TcxButton
        Left = 430
        Top = 324
        Width = 141
        Height = 25
        Caption = 'Teklif Durumlar'#305
        TabOrder = 4
        OnClick = TeklifDurumClick
      end
    end
    object TabSheetSablonlar: TcxTabSheet
      Caption = #350'ablonlar'
      ImageIndex = 19
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 545
      ExplicitHeight = 422
      object ToolBar5: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 669
        Height = 24
        Margins.Bottom = 0
        AutoSize = True
        ButtonWidth = 66
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
        ExplicitWidth = 539
        object SatirEkle: TToolButton
          Tag = 1
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 0
          OnClick = SatirEkleClick
        end
        object SatirSil: TToolButton
          Tag = 2
          Left = 66
          Top = 0
          Caption = 'Sil'
          ImageIndex = 1
          OnClick = SatirEkleClick
        end
        object ToolButton4: TToolButton
          Left = 132
          Top = 0
          Width = 8
          Caption = 'ToolButton4'
          ImageIndex = 2
          Style = tbsSeparator
          Visible = False
        end
        object SatirDuzenle: TToolButton
          Tag = 3
          Left = 140
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 7
          Visible = False
          OnClick = SatirEkleClick
        end
      end
      object RichSablonDetay: TcxDBRichEdit
        Left = 0
        Top = 73
        Align = alClient
        DataBinding.DataField = 'ACIKLAMA'
        DataBinding.DataSource = DsTabSablon
        Properties.ScrollBars = ssBoth
        TabOrder = 1
        ExplicitWidth = 679
        ExplicitHeight = 408
        Height = 407
        Width = 675
      end
      object Panel1: TPanel
        Left = 0
        Top = 27
        Width = 675
        Height = 46
        Align = alTop
        TabOrder = 2
        ExplicitWidth = 679
        object cxLabel2: TcxLabel
          Left = 7
          Top = 18
          Caption = #350'ablon'
        end
        object ComboBilgiSablonu: TcxImageComboBox
          Left = 69
          Top = 16
          RepositoryItem = Tablo.RepTeklifBilgiSablonu
          Properties.Items = <>
          Properties.OnCloseUp = ComboBilgiSablonuPropertiesCloseUp
          TabOrder = 1
          Width = 219
        end
      end
    end
    object SheetSatinAlma: TcxTabSheet
      Caption = 'Sat'#305'n Alma'
      ImageIndex = 19
      ExplicitLeft = 2
      ExplicitTop = 28
      ExplicitWidth = 679
      ExplicitHeight = 481
      object editTeklifAdres: TcxTextEdit
        Left = 133
        Top = 3
        TabOrder = 0
        Width = 318
      end
      object cxLabel3: TcxLabel
        Left = 5
        Top = 4
        AutoSize = False
        Caption = 'Teklif Adres:'
        Properties.Alignment.Horz = taRightJustify
        Transparent = True
        Height = 20
        Width = 105
        AnchorX = 110
      end
    end
    object SheetDurumBaglanti: TcxTabSheet
      Caption = 'Durum Ba'#287'lant'#305'lar'#305
      ImageIndex = 19
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 545
      ExplicitHeight = 422
      object GridDurumBaglanti: TcxGrid
        Left = 0
        Top = 0
        Width = 679
        Height = 481
        Align = alClient
        PopupMenu = PopupDurumBglanti
        TabOrder = 0
        ExplicitWidth = 545
        ExplicitHeight = 422
        object GridDurumBaglantiDBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsDurumBaglanti
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object GridDurumBaglantiDBTableView1ID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            Visible = False
          end
          object GridDurumBaglantiDBTableView1AKTIF: TcxGridDBColumn
            Caption = 'Aktif'
            DataBinding.FieldName = 'AKTIF'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 32
          end
          object GridDurumBaglantiDBTableView1KAYNAKDURUM: TcxGridDBColumn
            Caption = 'Kaynak'
            DataBinding.FieldName = 'KAYNAKDURUM'
            RepositoryItem = Tablo.repTeklifDurumu
            Options.Editing = False
            Options.Focusing = False
            Width = 66
          end
          object GridDurumBaglantiDBTableView1HEDEFDURUM: TcxGridDBColumn
            Caption = 'Hedef'
            DataBinding.FieldName = 'HEDEFDURUM'
            RepositoryItem = Tablo.repTeklifDurumu
            Options.Editing = False
            Options.Focusing = False
            Width = 72
          end
          object GridDurumBaglantiDBTableView1UYARITURU: TcxGridDBColumn
            Caption = 'Bildirim (i'#231')'
            DataBinding.FieldName = 'UYARITURU'
            RepositoryItem = Tablo.repUyariTurleri
            Width = 67
          end
          object GridDurumBaglantiDBTableView1DISUYARITURU: TcxGridDBColumn
            Caption = 'Bildirim (d'#305#351')'
            DataBinding.FieldName = 'DISUYARITURU'
            RepositoryItem = Tablo.repUyariTurleri
            Width = 82
          end
          object GridDurumBaglantiDBTableView1ACILIS: TcxGridDBColumn
            Caption = 'A'#231#305'l'#305#351
            DataBinding.FieldName = 'ACILIS'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 73
          end
          object GridDurumBaglantiDBTableView1KAPANIS: TcxGridDBColumn
            Caption = 'Kapan'#305#351
            DataBinding.FieldName = 'KAPANIS'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 58
          end
          object GridDurumBaglantiDBTableView1OTOKAPAT: TcxGridDBColumn
            Caption = 'Kaynak Kapat'
            DataBinding.FieldName = 'OTOKAPAT'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 84
          end
          object GridDurumBaglantiDBTableView1TARIHIDESOR: TcxGridDBColumn
            Caption = 'Tarihe Zorla'
            DataBinding.FieldName = 'TARIHIDESOR'
            RepositoryItem = Tablo.cxEditRepository1CheckBoxItem1
            Width = 94
          end
        end
        object GridDurumBaglantiLevel1: TcxGridLevel
          GridView = GridDurumBaglantiDBTableView1
        end
      end
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 511
    Width = 683
    Height = 41
    Align = alBottom
    BevelKind = bkSoft
    ParentBackground = False
    TabOrder = 1
    ExplicitTop = 452
    ExplicitWidth = 549
    object btn1: TBitBtn
      Left = 296
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Kaydet'
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
      OnClick = btn1Click
    end
    object btn4: TBitBtn
      Left = 377
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Kapat'
      Kind = bkClose
      NumGlyphs = 2
      TabOrder = 1
      OnClick = btn1Click
    end
  end
  object TabListeDuzenle: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from GENINI where BOLUM=0 and ANAHTAR like '#39'%Teklif_%'#39)
    Left = 209
    Top = 398
  end
  object DtsListeDuzenle: TDataSource
    DataSet = TabListeDuzenle
    Left = 283
    Top = 397
  end
  object TabSablon: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select * from TEKLIFHAREKET Where TEKLIFID=:Param')
    Left = 361
    Top = 398
  end
  object DsTabSablon: TDataSource
    DataSet = TabSablon
    Left = 419
    Top = 397
  end
  object TabDurumBaglanti: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'select * from DURUMBAGLANTI where YERI = :PYeri and BOLUM= :PBol' +
        'um'
      'order by ACILIS DESC, KAYNAKDURUM,HEDEFDURUM')
    Left = 336
    Top = 128
  end
  object DtsDurumBaglanti: TDataSource
    DataSet = TabDurumBaglanti
    Left = 336
    Top = 176
  end
  object PopupDurumBglanti: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 328
    Top = 232
    object TeklifDurumlarnDzenle1: TMenuItem
      Caption = 'Teklif Durumlar'#305'n'#305' D'#252'zenle'
      ImageIndex = 7
      OnClick = TeklifDurumlarnDzenle1Click
    end
    object BalantlarOlutur1: TMenuItem
      Caption = 'Eksik Ba'#287'lant'#305'lar'#305' Olu'#351'tur'
      ImageIndex = 13
      OnClick = BalantlarOlutur1Click
    end
    object KopmuBalantlarTemizle1: TMenuItem
      Caption = 'Kopmu'#351' Ba'#287'lant'#305'lar'#305' Temizle'
      ImageIndex = 9
      OnClick = KopmuBalantlarTemizle1Click
    end
  end
end

