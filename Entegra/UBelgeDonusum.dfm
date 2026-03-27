object BelgeDonusumDlg: TBelgeDonusumDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Belge D'#246'n'#252#351#252'm Bilgileri'
  ClientHeight = 566
  ClientWidth = 1366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object PanelKaynak: TPanel
    Left = 129
    Top = 65
    Width = 1237
    Height = 501
    Align = alClient
    TabOrder = 0
    object cxGridKaynak: TcxGrid
      Left = 1
      Top = 1
      Width = 965
      Height = 499
      Align = alClient
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      LookAndFeel.SkinName = 'LondonLiquidSky'
      object cxGridKaynakDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = cxGridKaynakDBTableView1CanFocusRecord
        OnCellDblClick = cxGridKaynakDBTableView1CellDblClick
        DataController.DataSource = DtsKaynak
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsData.CancelOnExit = False
        OptionsData.Deleting = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Editing = False
        OptionsData.Inserting = False
        OptionsSelection.CellSelect = False
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        Styles.ContentEven = Tablo.cxStyle1
        object cxGridKaynakDBTableView1FIRMA: TcxGridDBColumn
          Caption = 'Firma'
          DataBinding.FieldName = 'FIRMA'
          DataBinding.IsNullValueType = True
          Width = 125
        end
        object cxGridKaynakDBTableView1TARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
          DataBinding.IsNullValueType = True
          Width = 63
        end
        object cxGridKaynakDBTableView1BELGENO: TcxGridDBColumn
          Caption = 'Belgeno'
          DataBinding.FieldName = 'BELGENO'
          DataBinding.IsNullValueType = True
        end
        object cxGridKaynakDBTableView1KOD: TcxGridDBColumn
          Caption = 'Stok Kodu'
          DataBinding.FieldName = 'KOD'
          DataBinding.IsNullValueType = True
          Width = 76
        end
        object cxGridKaynakDBTableView1STOKADI: TcxGridDBColumn
          Caption = 'Stok Ad'#305
          DataBinding.FieldName = 'STOKADI'
          DataBinding.IsNullValueType = True
          Width = 154
        end
        object cxGridKaynakDBTableView1BIRIMFIYAT: TcxGridDBColumn
          Caption = 'Birim Fiyat'
          DataBinding.FieldName = 'BIRIMFIYAT'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 75
        end
        object cxGridKaynakDBTableView1ADET: TcxGridDBColumn
          Caption = 'Adet'
          DataBinding.FieldName = 'ADET'
          DataBinding.IsNullValueType = True
          Width = 58
        end
        object cxGridKaynakDBTableView1DONUSEN: TcxGridDBColumn
          Caption = 'D'#246'n'#252#351'en'
          DataBinding.FieldName = 'DONUSEN'
          DataBinding.IsNullValueType = True
          Width = 50
        end
        object cxGridKaynakDBTableView1IADE: TcxGridDBColumn
          Caption = #304'ade'
          DataBinding.FieldName = 'IADE'
          DataBinding.IsNullValueType = True
        end
        object cxGridKaynakDBTableView1KALAN: TcxGridDBColumn
          Caption = 'Kalan'
          DataBinding.FieldName = 'KALAN'
          DataBinding.IsNullValueType = True
          Width = 56
        end
        object cxGridKaynakDBTableView1BIRIM: TcxGridDBColumn
          Caption = 'Birim'
          DataBinding.FieldName = 'BIRIM'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.repStokAnaBirim
          Width = 53
        end
        object cxGridKaynakDBTableView1ISKONTO: TcxGridDBColumn
          Caption = #304'sk1'
          DataBinding.FieldName = 'ISKONTO'
          DataBinding.IsNullValueType = True
          Width = 29
        end
        object cxGridKaynakDBTableView1ISKONTO2: TcxGridDBColumn
          Caption = #304'sk2'
          DataBinding.FieldName = 'ISKONTO2'
          DataBinding.IsNullValueType = True
          Width = 30
        end
        object cxGridKaynakDBTableView1TUTAR: TcxGridDBColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'TUTAR'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.RepCurrencyGenel
          Width = 50
        end
        object cxGridKaynakDBTableView1KUR: TcxGridDBColumn
          Caption = 'P.Birimi'
          DataBinding.FieldName = 'KUR'
          DataBinding.IsNullValueType = True
        end
        object cxGridKaynakDBTableView1SEVK: TcxGridDBColumn
          Caption = 'Sevk'
          DataBinding.FieldName = 'SEVK'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxTextEditProperties'
        end
        object cxGridKaynakDBTableView1PROJEKODU: TcxGridDBColumn
          Caption = 'Proje'
          DataBinding.FieldName = 'PROJEKODU'
          DataBinding.IsNullValueType = True
          BestFitMaxWidth = 80
          Width = 80
        end
        object cxGridKaynakDBTableView1SATICI: TcxGridDBColumn
          Caption = 'Kullan'#305'c'#305
          DataBinding.FieldName = 'SATICI'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.repGenelPersonelListesi
        end
        object cxGridKaynakDBTableView1TESLIMTARIHI: TcxGridDBColumn
          Caption = 'Teslim Tarihi'
          DataBinding.FieldName = 'TESLIMTARIHI'
          DataBinding.IsNullValueType = True
        end
        object cxGridKaynakDBTableView1GIZLE: TcxGridDBColumn
          Caption = 'Gizli'
          DataBinding.FieldName = 'GIZLE'
          DataBinding.IsNullValueType = True
          RepositoryItem = Tablo.cxEditRepository1CheckBoxItem2
          Width = 29
        end
        object cxGridKaynakDBTableView1URUNNO: TcxGridDBColumn
          Caption = #220'r'#252'n No'
          DataBinding.FieldName = 'URUNNO'
          DataBinding.IsNullValueType = True
        end
        object cxGridKaynakDBTableView1OZELKOD: TcxGridDBColumn
          Caption = 'Stok '#214'zel Kod'
          DataBinding.FieldName = 'OZELKOD'
          DataBinding.IsNullValueType = True
          Width = 50
        end
        object cxGridKaynakDBTableView1OZELKOD2: TcxGridDBColumn
          Caption = 'Stok '#214'zel Kod2'
          DataBinding.FieldName = 'OZELKOD2'
          DataBinding.IsNullValueType = True
          Width = 50
        end
        object cxGridKaynakDBTableView1DETAY_OZELKOD: TcxGridDBColumn
          Caption = 'Detay '#214'zel Kod'
          DataBinding.FieldName = 'DETAY_OZELKOD'
          DataBinding.IsNullValueType = True
          Width = 50
        end
        object cxGridKaynakDBTableView1DETAY_OZELKOD2: TcxGridDBColumn
          Caption = 'Detay '#214'zel Kod2'
          DataBinding.FieldName = 'DETAY_OZELKOD2'
          DataBinding.IsNullValueType = True
          Width = 50
        end
        object cxGridKaynakDBTableView1POZNO: TcxGridDBColumn
          Caption = 'Poz No'
          DataBinding.FieldName = 'POZNO'
          DataBinding.IsNullValueType = True
        end
        object cxGridKaynakDBTableView1ACIKLAMA: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
          DataBinding.IsNullValueType = True
        end
      end
      object cxGridKaynakLevel1: TcxGridLevel
        GridView = cxGridKaynakDBTableView1
      end
    end
    object PageHareketSeriLot: TcxPageControl
      Left = 966
      Top = 1
      Width = 270
      Height = 499
      Align = alRight
      TabOrder = 1
      Visible = False
      Properties.ActivePage = cxTabSheet4
      Properties.CustomButtons.Buttons = <>
      ClientRectBottom = 495
      ClientRectLeft = 4
      ClientRectRight = 266
      ClientRectTop = 24
      object cxTabSheet4: TcxTabSheet
        Caption = 'Seri / Lot'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object GridSeriLotHareket: TcxGrid
          Left = 0
          Top = 0
          Width = 262
          Height = 471
          Align = alClient
          TabOrder = 0
          LevelTabs.CaptionAlignment = taLeftJustify
          object GridSeriLotHareketView: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            DataController.DataSource = DtsSeriLotHareket
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <
              item
                Kind = skSum
                FieldName = 'ADET'
                Column = cxGridDBColumn9
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsView.Footer = True
            OptionsView.GroupByBox = False
            object cxGridDBColumn4: TcxGridDBColumn
              DataBinding.FieldName = 'STOKID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object cxGridDBColumn5: TcxGridDBColumn
              DataBinding.FieldName = 'DEPOID'
              DataBinding.IsNullValueType = True
              Visible = False
            end
            object cxGridDBColumn6: TcxGridDBColumn
              Caption = 'Seri No'
              DataBinding.FieldName = 'SERINO'
              DataBinding.IsNullValueType = True
              Width = 70
            end
            object cxGridDBColumn7: TcxGridDBColumn
              Caption = 'Lot No'
              DataBinding.FieldName = 'LOTNO'
              DataBinding.IsNullValueType = True
              Width = 70
            end
            object GridSeriLotHareketViewColumn1: TcxGridDBColumn
              Caption = 'Depo'
              DataBinding.FieldName = 'DEPOADI'
              DataBinding.IsNullValueType = True
            end
            object cxGridDBColumn9: TcxGridDBColumn
              Caption = 'Adet'
              DataBinding.FieldName = 'ADET'
              DataBinding.IsNullValueType = True
              Width = 70
            end
          end
          object cxGridLevel4: TcxGridLevel
            Caption = 'Depo Durumu'
            GridView = GridSeriLotHareketView
          end
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1366
    Height = 65
    Align = alTop
    TabOrder = 1
    object BtnSec: TJvNavPanelButton
      Left = 1269
      Top = 1
      Width = 94
      Height = 63
      Align = alRight
      AllowAllUp = True
      Caption = 'Se'#231
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      GroupIndex = 2
      HotTrack = False
      HotTrackFont.Charset = TURKISH_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -13
      HotTrackFont.Name = 'Trebuchet MS'
      HotTrackFont.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      Colors.ButtonColorFrom = clBtnFace
      Colors.ButtonColorTo = 12566463
      Colors.ButtonHotColorFrom = 14256961
      Colors.ButtonHotColorTo = 11694645
      Colors.ButtonSelectedColorFrom = 14256961
      Colors.ButtonSelectedColorTo = 11694645
      ParentStyleManager = False
      ImageIndex = 1
      Images = Tablo.PNGImageList1
      OnClick = BtnSecClick
      ExplicitLeft = 1263
      ExplicitTop = -3
    end
    object Panel3: TPanel
      Left = 1363
      Top = 1
      Width = 2
      Height = 63
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
    end
    object cxGroupBox1: TcxGroupBox
      Left = 337
      Top = 1
      Align = alLeft
      Caption = 'Stok'
      TabOrder = 1
      Height = 63
      Width = 344
      object edStokAd: TcxTextEdit
        Left = 218
        Top = 13
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 0
        OnKeyUp = edBarkodKeyUp
        Width = 121
      end
      object cxLabel6: TcxLabel
        Left = 173
        Top = 15
        Caption = 'Stok Ad'
      end
      object edStokKod: TcxTextEdit
        Left = 50
        Top = 13
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 2
        OnKeyUp = edBarkodKeyUp
        Width = 121
      end
      object cxLabel5: TcxLabel
        Left = 2
        Top = 15
        Caption = 'Stok Kod'
      end
      object edBarkod: TcxTextEdit
        Left = 50
        Top = 35
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 4
        OnKeyUp = edBarkodKeyUp
        Width = 121
      end
      object cxLabel7: TcxLabel
        Left = 11
        Top = 37
        Caption = 'Barkod'
      end
      object cxLabel8: TcxLabel
        Left = 173
        Top = 38
        Caption = #220'r'#252'n No'
      end
      object edUrunNo: TcxTextEdit
        Left = 218
        Top = 36
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 7
        OnKeyUp = edBarkodKeyUp
        Width = 121
      end
    end
    object cxGroupBox2: TcxGroupBox
      Left = 1
      Top = 1
      Align = alLeft
      Caption = 'Belge'
      TabOrder = 2
      Height = 63
      Width = 336
      object cxLabel1: TcxLabel
        Left = 24
        Top = 15
        Caption = 'T'#252'r'
      end
      object cbTur: TcxImageComboBox
        Left = 44
        Top = 13
        Properties.ImmediatePost = True
        Properties.Items = <>
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 1
        Width = 121
      end
      object cxLabel4: TcxLabel
        Left = 1
        Top = 37
        Caption = 'BelgeNo'
      end
      object EdBelgeNo: TcxTextEdit
        Left = 44
        Top = 35
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 3
        OnKeyUp = edBarkodKeyUp
        Width = 121
      end
      object DtBas: TcxDateEdit
        Left = 210
        Top = 13
        Properties.ImmediatePost = True
        Properties.SaveTime = False
        Properties.ShowTime = False
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 4
        Width = 121
      end
      object cxLabel2: TcxLabel
        Left = 166
        Top = 15
        Caption = 'Ba'#351'lama'
      end
      object cxLabel3: TcxLabel
        Left = 186
        Top = 37
        Caption = 'Biti'#351
      end
      object DtBit: TcxDateEdit
        Left = 210
        Top = 35
        Properties.ImmediatePost = True
        Properties.SaveTime = False
        Properties.ShowTime = False
        Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
        TabOrder = 7
        Width = 121
      end
    end
    object lbDetayliArama: TcxLabel
      Left = 687
      Top = 43
      Cursor = crHandPoint
      Caption = 'Detayl'#305' Arama...'
      ParentColor = False
      Style.TextColor = clBlue
      Properties.ShadowedColor = clBlue
      Transparent = True
      OnClick = lbDetayliAramaClick
    end
    object checkKalmayanGoster: TcxCheckBox
      Left = 687
      Top = 4
      Caption = 'Kalmayanlar'#305' da g'#246'ster.'
      Properties.ImmediatePost = True
      Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
      TabOrder = 4
    end
    object checkGizlenenGoster: TcxCheckBox
      Left = 687
      Top = 22
      Caption = 'Gizlenenleri de g'#246'ster.'
      Properties.ImmediatePost = True
      Properties.OnEditValueChanged = edStokAdPropertiesEditValueChanged
      TabOrder = 5
    end
  end
  object PanelDetayliAra: TPanel
    Left = 0
    Top = 65
    Width = 129
    Height = 501
    Align = alLeft
    TabOrder = 2
    Visible = False
    object Panel4: TPanel
      Left = 126
      Top = 378
      Width = 2
      Height = 122
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
    end
    object GrpBoyut: TcxGroupBox
      Left = 1
      Top = 256
      Align = alTop
      Caption = 'Boyut'
      TabOrder = 1
      Visible = False
      Height = 122
      Width = 127
      object cbBoyutKombinasyon: TcxImageComboBox
        Left = 3
        Top = 17
        RepositoryItem = Tablo.repStokBoyutKombinasyonlar
        Properties.ClearKey = 46
        Properties.ImmediatePost = True
        Properties.Items = <>
        Properties.OnEditValueChanged = cbBoyutKombinasyonPropertiesEditValueChanged
        TabOrder = 0
        Width = 121
      end
      object cbBoyut1: TcxImageComboBox
        Left = 3
        Top = 42
        Properties.ClearKey = 46
        Properties.ImmediatePost = True
        Properties.Items = <>
        Properties.OnEditValueChanged = EditSerinoPropertiesEditValueChanged
        TabOrder = 1
        Width = 121
      end
      object cbBoyut2: TcxImageComboBox
        Left = 3
        Top = 67
        Properties.ClearKey = 46
        Properties.ImmediatePost = True
        Properties.Items = <>
        Properties.OnEditValueChanged = EditSerinoPropertiesEditValueChanged
        TabOrder = 2
        Width = 121
      end
      object cbBoyut3: TcxImageComboBox
        Left = 3
        Top = 92
        Properties.ClearKey = 46
        Properties.ImmediatePost = True
        Properties.Items = <>
        Properties.OnEditValueChanged = EditSerinoPropertiesEditValueChanged
        TabOrder = 3
        Width = 121
      end
    end
    object GrpSKT: TcxGroupBox
      Left = 1
      Top = 185
      Align = alTop
      Caption = 'SKT'
      TabOrder = 2
      Visible = False
      Height = 71
      Width = 127
      object EditAciklama: TcxTextEdit
        Left = 3
        Top = 41
        Properties.OnEditValueChanged = EditSerinoPropertiesEditValueChanged
        TabOrder = 0
        OnKeyUp = EditAciklamaKeyUp
        Width = 121
      end
      object DateSKT: TcxDateEdit
        Left = 3
        Top = 16
        Properties.ClearKey = 46
        Properties.ImmediatePost = True
        Properties.OnEditValueChanged = EditSerinoPropertiesEditValueChanged
        TabOrder = 1
        Width = 121
      end
    end
    object GrpKarekod: TcxGroupBox
      Left = 1
      Top = 137
      Align = alTop
      Caption = 'Karekod'
      TabOrder = 3
      Visible = False
      Height = 48
      Width = 127
      object EditKarekod: TcxTextEdit
        Left = 3
        Top = 18
        Properties.OnEditValueChanged = EditSerinoPropertiesEditValueChanged
        TabOrder = 0
        OnKeyUp = EditKarekodKeyUp
        Width = 121
      end
    end
    object GrpSerino: TcxGroupBox
      Left = 1
      Top = 89
      Align = alTop
      Caption = 'Serino'
      TabOrder = 4
      Height = 48
      Width = 127
      object EditSerino: TcxTextEdit
        Left = 3
        Top = 18
        Properties.OnEditValueChanged = EditSerinoPropertiesEditValueChanged
        TabOrder = 0
        OnKeyUp = EditSerinoKeyUp
        Width = 121
      end
    end
    object rgIzlemTuru: TcxRadioGroup
      Left = 1
      Top = 1
      Align = alTop
      Caption = #304'zleme T'#252'r'#252
      Properties.DefaultValue = '0'
      Properties.ImmediatePost = True
      Properties.Items = <
        item
          Caption = 'Serino'
          Tag = 1
        end
        item
          Caption = 'Karekod'
          Tag = 3
        end
        item
          Caption = 'SKT'
          Tag = 2
        end
        item
          Caption = 'Boyut'
          Tag = 4
        end>
      Properties.OnEditValueChanged = rgIzlemTuruPropertiesEditValueChanged
      ItemIndex = 0
      TabOrder = 5
      Height = 88
      Width = 127
    end
  end
  object TabKaynak: TFDQuery
    AfterScroll = TabKaynakAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select '
      ''
      
        #9'BASLIKID=FB.ID,SATIRID=F.ID,STOKID=ST.ID,R.FIRMA,TARIH=FB.FATUR' +
        'ATARIH,BELGENO=FB.FATURANO,ST.KOD,ST.STOKADI,ST.ANABIRIM,'
      
        #9'F.ACIKLAMA,ST.IZLEME,ST.OZELKOD,ST.MUHKODU,F.KDV,F.KUR,F.DOVIZ_' +
        'KURU,'
      
        #9'F.ADET,F.MIKTAR,F.BIRIM,F.BIRIMFIYAT,F.ISKONTO,F.ISKONTO2,F.TUT' +
        'AR,F.DOVIZ_BIRIMFIYAT,F.DOVIZ_KURU,F.DOVIZKURDEGERI,F.DOVIZ_TUTA' +
        'RI,F.MASRAFID,F.MERKEZID,F.KAMPANYAID,'
      
        #9'DONUSEN=isnull((select sum(F1.ADET) from FATURA F1 where F1.YER' +
        'I=411 and F1.YERID=F.ID ),0.0),'
      
        #9'ALAN=ADET-isnull((select sum(F1.ADET) from FATURA F1 where F1.Y' +
        'ERI=411 and F1.YERID=F.ID ),0.0)'
      #9',TESLIMTARIHI=FB.FATURATARIH,'
      
        '    SEVK = (SELECT AD FROM  REHBERILETISIM WHERE ID=FB.REHBERILE' +
        'TID),'
      ' '
      
        #9',GIZLI= convert(bit,case when exists(select ID from DONUSUMBILG' +
        'ISIGIZLE where KAYNAKTUR=FB.TUR and HEDEFTUR=15 and KAYNAKID=F.I' +
        'D) then 1 else 0 end),'
      ' '#9'F.OZELKOD, F.OZELKOD2'
      
        'from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID inner ' +
        'join STOKLAR ST on F.TUR=1 and F.URUNID=ST.ID inner join REHBER ' +
        'R on R.ID=FB.REHBERID'
      
        'where FB.FATURATARIH>='#39'2016-10-25 00:00'#39'  and FB.FATURATARIH<='#39'2' +
        '016-11-24 23:59'#39'  and FB.TUR=14 and '
      
        'ADET > isnull((select sum(F1.ADET) from FATURA F1 where F1.YERI=' +
        '411 and F1.YERID=F.ID ),0.0)')
    Left = 512
    Top = 232
  end
  object DtsKaynak: TDataSource
    DataSet = TabKaynak
    OnStateChange = DtsKaynakStateChange
    Left = 496
    Top = 312
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 448
    Top = 200
  end
  object PopupGrid: TPopupMenu
    Left = 376
    Top = 216
    object Gizle1: TMenuItem
      Caption = 'Gizle'
      OnClick = Gizle1Click
    end
    object GizlemeyiKaldr1: TMenuItem
      Caption = 'Gizlemeyi Kald'#305'r'
      OnClick = GizlemeyiKaldr1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object StokDetay1: TMenuItem
      Caption = 'Stok Detay'#305
      OnClick = StokDetay1Click
    end
    object zlemeDetay1: TMenuItem
      Caption = #304'zleme Detay'#305
      OnClick = zlemeDetay1Click
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = cxGridKaynak
    PopupMenus = <
      item
        GridView = cxGridKaynakDBTableView1
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupGrid
      end>
    AlwaysFireOnPopup = True
    Left = 528
    Top = 120
  end
  object TabSeriLotHareket: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select SI.ID,SSL.SERINO,SSL.LOTNO,SSL.SKT,SSL.URT,SD.DEPOID,D.DE' +
        'POADI, SD.ADET from STOKIZLEME SI'
      'LEFT JOIN STOKIZLEMEDEPO SD  ON SD.IZLEMID=SI.ID'
      'LEFT JOIN [STOKSERILOT] SSL ON SI.SERILOTID=SSL.ID'
      'LEFT JOIN DEPOLAR D ON D.ID=SD.DEPOID'
      'where SI.STOKID=:PStokID'
      'and SI.SATIRID=:PSatirID')
    Left = 707
    Top = 277
  end
  object DtsSeriLotHareket: TDataSource
    DataSet = TabSeriLotHareket
    Left = 708
    Top = 326
  end
end
