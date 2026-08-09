object UretimListeDlg: TUretimListeDlg
  Left = 0
  Top = 0
  Width = 1027
  Height = 472
  Align = alClient
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1021
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 110
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    object YeniTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      ImageName = 'PngImage6'
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 110
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 220
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object GorTus: TToolButton
      Left = 228
      Top = 0
      Caption = 'D'#252'zenle'
      ImageIndex = 9
      ImageName = 'PngImage8'
      OnClick = GorTusClick
    end
    object btnDonusum: TToolButton
      Left = 338
      Top = 0
      Caption = 'D'#246'n'#252#351#252'm Bilgisi'
      ImageIndex = 39
      ImageName = 'PngImage39'
      OnClick = btnDonusumClick
    end
  end
  object GridUretim: TcxGrid
    Left = 0
    Top = 35
    Width = 1027
    Height = 258
    Align = alClient
    TabOrder = 1
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object GridUretimView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = GridUretimViewCanFocusRecord
      OnCellDblClick = GridUretimViewCellDblClick
      DataController.DataSource = DtsUretimListe
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'TPLMALIYETSON'
          Column = GridUretimViewTPLMALIYETSON
        end
        item
          Format = ',0.00;-,0.00'
          Kind = skSum
          FieldName = 'TPLMALIYETORT'
          Column = GridUretimViewTPLMALIYETORT
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsView.Footer = True
      OptionsView.GroupFooters = gfAlwaysVisible
      Styles.ContentEven = Tablo.cxStyle1
      Styles.ContentOdd = Tablo.cxstSecili
      object GridUretimViewID: TcxGridDBColumn
        DataBinding.FieldName = 'ID'
        DataBinding.IsNullValueType = True
        Visible = False
      end
      object GridUretimViewFATURANO: TcxGridDBColumn
        Caption = #220'retim No'
        DataBinding.FieldName = 'FATURANO'
        DataBinding.IsNullValueType = True
        Width = 56
      end
      object GridUretimViewBOLUM: TcxGridDBColumn
        Caption = #220'retim T'#252'r'#252
        DataBinding.FieldName = 'BOLUM'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepUretimTuru
        Width = 75
      end
      object GridUretimViewTARIH: TcxGridDBColumn
        Caption = 'Ba'#351'lama'
        DataBinding.FieldName = 'TARIH'
        DataBinding.IsNullValueType = True
        Width = 122
      end
      object GridUretimViewFATURATARIH: TcxGridDBColumn
        Caption = 'Biti'#351
        DataBinding.FieldName = 'FATURATARIH'
        DataBinding.IsNullValueType = True
        Width = 107
      end
      object GridUretimViewURETIMEMIRNO: TcxGridDBColumn
        Caption = #220'retim Emir No'
        DataBinding.FieldName = 'DETAYBOLUMU'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewCARIKOD: TcxGridDBColumn
        Caption = 'Cari Kod'
        DataBinding.FieldName = 'CARIKOD'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewCARIAD: TcxGridDBColumn
        Caption = 'Cari Ad'
        DataBinding.FieldName = 'CARIAD'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewSURE: TcxGridDBColumn
        Caption = 'S'#252're'
        DataBinding.FieldName = 'SURE'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewURUNNO: TcxGridDBColumn
        Caption = #220'r'#252'n No'
        DataBinding.FieldName = 'URUNNO'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewKOD: TcxGridDBColumn
        Caption = 'Stok Kod'
        DataBinding.FieldName = 'KOD'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewSTOKADI: TcxGridDBColumn
        Caption = 'Stok Ad'#305
        DataBinding.FieldName = 'STOKADI'
        DataBinding.IsNullValueType = True
        Width = 172
      end
      object GridUretimViewADET: TcxGridDBColumn
        Caption = 'Miktar'
        DataBinding.FieldName = 'STOKISK'
        DataBinding.IsNullValueType = True
        Width = 36
      end
      object GridUretimViewBIRIM: TcxGridDBColumn
        Caption = 'Birim'
        DataBinding.FieldName = 'SAYFA'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.repStokAnaBirim
      end
      object GridUretimViewMALIYETSON: TcxGridDBColumn
        Caption = 'Br.Son.Maliyet'
        DataBinding.FieldName = 'FATURA_MATRAHI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        Width = 64
      end
      object GridUretimViewTPLMALIYETSON: TcxGridDBColumn
        Caption = 'Tpl.Son Maliyet '
        DataBinding.FieldName = 'TPLMALIYETSON'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
      end
      object GridUretimViewMALIYETORT: TcxGridDBColumn
        Caption = 'Br.Ort.Maliyet'
        DataBinding.FieldName = 'FATURA_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        Width = 79
      end
      object GridUretimViewTPLMALIYETORT: TcxGridDBColumn
        Caption = 'Tpl.Ort.Maliyet'
        DataBinding.FieldName = 'TPLMALIYETORT'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
      end
      object GridUretimViewColumn1: TcxGridDBColumn
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        Width = 42
      end
      object GridUretimViewDOVIZKUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'DOVIZKUR'
        DataBinding.IsNullValueType = True
        Width = 46
      end
      object GridUretimViewMALIYETSONDOVIZ: TcxGridDBColumn
        Caption = 'D'#246'viz Son.Maliyet'
        DataBinding.FieldName = 'KDV_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        Width = 83
      end
      object GridUretimViewMALIYETORTDOVIZ: TcxGridDBColumn
        Caption = 'D'#246'viz Ort Maliyet'
        DataBinding.FieldName = 'DOVIZ_TUTARI'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
        Width = 80
      end
      object GridUretimViewDOVIZ_CINSI: TcxGridDBColumn
        Caption = 'D'#246'viz'
        DataBinding.FieldName = 'DOVIZ_CINSI'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewSATIS: TcxGridDBColumn
        Caption = 'Liste Fiyat'#305
        DataBinding.FieldName = 'SATIS'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
      end
      object GridUretimViewKAR: TcxGridDBColumn
        Caption = 'Kar %'
        DataBinding.FieldName = 'KAR'
        DataBinding.IsNullValueType = True
        RepositoryItem = Tablo.RepCurrencyGenel
      end
      object GridUretimViewGIRISDEPO: TcxGridDBColumn
        Caption = 'Giri'#351' Depo'
        DataBinding.FieldName = 'GIRISDEPOAD'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewCIKISDEPO: TcxGridDBColumn
        Caption = #199#305'k'#305#351' Depo'
        DataBinding.FieldName = 'CIKISDEPOAD'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewLOKASYONADI: TcxGridDBColumn
        Caption = 'Lokasyon'
        DataBinding.FieldName = 'LOKASYONADI'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 87
      end
      object GridUretimViewISTASYONADI: TcxGridDBColumn
        Caption = #304'stasyon'
        DataBinding.FieldName = 'ISTASYONADI'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 94
      end
      object GridUretimViewSORUMLUADI: TcxGridDBColumn
        Caption = 'Sorumlu'
        DataBinding.FieldName = 'SORUMLUADI'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 86
      end
      object GridUretimViewONAYLAYANADI: TcxGridDBColumn
        Caption = 'Onaylayan'
        DataBinding.FieldName = 'ONAYLAYANADI'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 92
      end
      object GridUretimViewDURUMNEREDEN: TcxGridDBColumn
        Caption = 'Kaynak'
        DataBinding.FieldName = 'DURUMNEREDEN'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewDURUMNEREYE: TcxGridDBColumn
        Caption = 'Hedef'
        DataBinding.FieldName = 'DURUMNEREYE'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      end
      object GridUretimViewACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        Width = 357
      end
      object GridUretimViewBASLAMA_YIL: TcxGridDBColumn
        Caption = 'Ba'#351'.Y'#305'l'
        DataBinding.FieldName = 'BASLAMA_YIL'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewBASLAMA_AY: TcxGridDBColumn
        Caption = 'Ba'#351'.Ay'
        DataBinding.FieldName = 'BASLAMA_AY'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewBITIS_YIL: TcxGridDBColumn
        Caption = 'Bit.Y'#305'l'
        DataBinding.FieldName = 'BITIS_YIL'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewBITIS_AY: TcxGridDBColumn
        Caption = 'Bit.Ay'
        DataBinding.FieldName = 'BITIS_AY'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewPROJEKODU: TcxGridDBColumn
        Caption = 'Proje Kodu'
        DataBinding.FieldName = 'PROJEKODU'
        DataBinding.IsNullValueType = True
        Width = 66
      end
      object GridUretimViewOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
      end
      object GridUretimViewOZELKOD2: TcxGridDBColumn
        Caption = #214'zel Kod2'
        DataBinding.FieldName = 'OZELKOD2'
        DataBinding.IsNullValueType = True
      end
    end
    object GridUretimLevel1: TcxGridLevel
      Caption = 'Kasa'
      GridView = GridUretimView
    end
  end
  object PageAlt: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 293
    Width = 1027
    Height = 179
    Align = alBottom
    TabOrder = 2
    Properties.ActivePage = SheetDetay
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 175
    ClientRectLeft = 4
    ClientRectRight = 1023
    ClientRectTop = 26
    object SheetDetay: TcxTabSheet
      Caption = 'Detay'
      ImageIndex = 22
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GridUretimDetay: TcxGrid
        Left = 0
        Top = 0
        Width = 1019
        Height = 149
        Align = alClient
        TabOrder = 0
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object GridUretimDetayView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = GridUretimDetayViewCanFocusRecord
          OnCellDblClick = GridUretimViewCellDblClick
          DataController.DataSource = DtsUretimDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.AlwaysShowEditor = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.GroupByBox = False
          object GridUretimDetayViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 38
          end
          object GridUretimDetayViewURUNNO: TcxGridDBColumn
            Caption = #220'r'#252'n No'
            DataBinding.FieldName = 'URUNNO'
            DataBinding.IsNullValueType = True
          end
          object GridUretimDetayViewKOD: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            Width = 95
          end
          object GridUretimDetayViewAD: TcxGridDBColumn
            Caption = 'Ad'
            DataBinding.FieldName = 'AD'
            DataBinding.IsNullValueType = True
            Width = 205
          end
          object GridUretimDetayViewADET: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepCurrencyAdetGenel
          end
          object GridUretimDetayViewBIRIM: TcxGridDBColumn
            Caption = 'Birim'
            DataBinding.FieldName = 'BIRIM'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repStokAnaBirim
          end
          object GridUretimDetayViewACIKLAMA: TcxGridDBColumn
            Caption = 'A'#231#305'klama'
            DataBinding.FieldName = 'ACIKLAMA'
            DataBinding.IsNullValueType = True
            Width = 432
          end
          object GridUretimDetayViewGRP: TcxGridDBColumn
            DataBinding.FieldName = 'GRP'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.repUretimFisiGRP
            Visible = False
            GroupIndex = 0
          end
        end
        object cxGridLevel1: TcxGridLevel
          Caption = 'Kasa'
          GridView = GridUretimDetayView
        end
      end
    end
  end
  object SQLMemo: TcxMemo
    Left = 296
    Top = 136
    Lines.Strings = (
      
        'select FB.ID,FB.TUR,[TARIH],[FATURATARIH],[FATURANO],FB.REHBERID' +
        ',[SAYFA],[STOKISK],FATURA_MATRAHI,[FATURA_TUTARI],FB.KUR,'
      'FB.OZELKOD, FB.OZELKOD2, FB.DETAYBOLUMU,'
      
        'TPLMALIYETSON=FATURA_MATRAHI*STOKISK,TPLMALIYETORT=FATURA_TUTARI' +
        '*STOKISK,DOVIZ_CINSI,'
      
        'SATIS=FB.EKVERGI, KAR=((FB.EKVERGI-FATURA_TUTARI)/nullif(FATURA_' +
        'TUTARI,0))*100.0,'
      'DOVIZKUR,KDV_TUTARI,DOVIZ_TUTARI,'
      'GIRISDEPO,CIKISDEPO,'
      
        'GIRISDEPOAD = (SELECT DEPOADI FROM DEPOLAR D WHERE D.ID=FB.GIRIS' +
        'DEPO),'
      
        'CIKISDEPOAD = (SELECT DEPOADI FROM DEPOLAR D WHERE D.ID=FB.CIKIS' +
        'DEPO),'
      'FB.SUBEID,ACIKLAMA,'
      'S.STOKADI,S.KOD,S.URUNNO, FB.BOLUM, P.PROJEKODU,'
      'SURE=dbo.fn_TarihFarkiFormatli(FB.TARIH, FB.FATURATARIH),'
      'BASLAMA_YIL=YEAR(TARIH),'
      'BASLAMA_AY=MONTH(TARIH),'
      'BITIS_YIL=YEAR(FATURATARIH),'
      'BITIS_AY=MONTH(FATURATARIH),'
      'CARIKOD=(select R.KOD from REHBER R where R.ID=FB.REHBERID),'
      'CARIAD=(select R.FIRMA from REHBER R where R.ID=FB.REHBERID),'
      
        ' ISTASYONADI=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.IS' +
        'YERI),'
      
        ' LOKASYONADI=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.LO' +
        'KASYON),'
      
        ' SORUMLUADI=(select R.FIRMA from REHBER R where R.ID=FB.SATICIKO' +
        'DU),'
      
        ' ONAYLAYANADI=(select R.FIRMA from REHBER R where R.ID=FB.ONAYLA' +
        'YAN),'
      
        'DURUMNEREDEN = case when (415 in (select YERI from FATURA where ' +
        'FATBASID=FB.ID)) then '#39'Sipari'#351'ten'#39' '
      
        'when (420 in (select YERI from FATURA where FATBASID=FB.ID)) the' +
        'n '#39'Sipari'#351'ten'#39' else '#39#39' end,  '
      
        'DURUMNEREYE = case when (426 in (select YERI from FATURA where Y' +
        'ERID in (select ID from FATURA where FATBASID=FB.ID))) then '#39'Fat' +
        'uraya'#39' '
      
        #9#9#9#9'when (425 in (select YERI from FATURA where YERID in (select' +
        ' ID from FATURA where FATBASID=FB.ID))) then '#39#304'rsaliyeye'#39' else '#39 +
        #39' end'
      'from FATBASLIK FB '
      ' left join STOKLAR S on S.ID=FB.AKTIVITEID'
      ' left outer join PROJELER P on P.ID=FB.PROJEID'
      'where FB.TUR=6'
      ''
      '')
    Properties.WordWrap = False
    TabOrder = 3
    Visible = False
    Height = 41
    Width = 588
  end
  object DtsUretimListe: TDataSource
    DataSet = TabUretimListe
    Left = 259
    Top = 130
  end
  object TabUretimListe: TFDQuery
    AfterOpen = TabUretimListeAfterOpen
    AfterClose = TabUretimListeAfterClose
    AfterScroll = TabUretimListeAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select FB.ID,FB.TUR,[TARIH],[FATURATARIH],[FATURANO],FB.REHBERID' +
        ',[SAYFA],[STOKISK],FATURA_MATRAHI,[FATURA_TUTARI],FB.KUR, '
      'FB.OZELKOD,FBOZELKOD2,'
      
        'TPLMALIYETSON=FATURA_MATRAHI*STOKISK,TPLMALIYETORT=FATURA_TUTARI' +
        '*STOKISK,DOVIZ_CINSI,'
      
        'SATIS=FB.EKVERGI, KAR=((FB.EKVERGI-FATURA_TUTARI)/nullif(FATURA_' +
        'TUTARI,0))*100.0,'
      
        'DOVIZKUR,KDV_TUTARI,DOVIZ_TUTARI,GIRISDEPO,CIKISDEPO,FB.SUBEID,A' +
        'CIKLAMA,'
      'S.STOKADI,S.KOD,S.URUNNO, FB.BOLUM, P.PROJEKODU,'
      'SURE=dbo.fn_TarihFarkiFormatli(FB.TARIH, FB.FATURATARIH),'
      'BASLAMA_YIL=YEAR(TARIH),'
      'BASLAMA_AY=MONTH(TARIH),'
      'BITIS_YIL=YEAR(FATURATARIH),'
      'BITIS_AY=MONTH(FATURATARIH),'
      'CARIKOD=(select R.KOD from REHBER R where R.ID=FB.REHBERID),'
      'CARIAD=(select R.FIRMA from REHBER R where R.ID=FB.REHBERID),'
      
        ' ISTASYONADI=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.IS' +
        'YERI),'
      
        ' LOKASYONADI=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.LO' +
        'KASYON),'
      
        ' SORUMLUADI=(select R.FIRMA from REHBER R where R.ID=FB.SATICIKO' +
        'DU),'
      
        ' ONAYLAYANADI=(select R.FIRMA from REHBER R where R.ID=FB.ONAYLA' +
        'YAN),'
      
        'DURUMNEREDEN = case when (415 in (select YERI from FATURA where ' +
        'FATBASID=FB.ID)) then '#39'Sipari'#351'ten'#39' '
      
        'when (420 in (select YERI from FATURA where FATBASID=FB.ID)) the' +
        'n '#39'Sipari'#351'ten'#39' else '#39#39' end,  '
      
        'DURUMNEREYE = case when (426 in (select YERI from FATURA where Y' +
        'ERID in (select ID from FATURA where FATBASID=FB.ID))) then '#39'Fat' +
        'uraya'#39' '
      
        #9#9#9#9'when (425 in (select YERI from FATURA where YERID in (select' +
        ' ID from FATURA where FATBASID=FB.ID))) then '#39#304'rsaliyeye'#39' else '#39 +
        #39' end'
      'from FATBASLIK FB '
      ' left join STOKLAR S on S.ID=FB.AKTIVITEID'
      ' left outer join PROJELER P on P.ID=FB.PROJEID'
      'where FB.TUR=6'
      ''
      ''
      ''
      '')
    Left = 165
    Top = 126
  end
  object TabUretimDetay: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select'
      ' * ,'
      '               GRP = case when MIKTAR>0 then 1 else 0 end,'
      
        '               AD =  CASE WHEN F.TUR =1 THEN (SELECT STOKADI FRO' +
        'M STOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELI' +
        'R WHERE ID = F.URUNID)  END,'
      
        '               URUNNO =  CASE WHEN F.TUR =1 THEN (SELECT URUNNO ' +
        'FROM STOKLAR WHERE ID = F.URUNID ) ELSE  '#39#39'  END,'
      
        '               KOD =  CASE WHEN F.TUR =1 THEN (SELECT KOD FROM S' +
        'TOKLAR WHERE ID = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR ' +
        'WHERE ID= F.URUNID )  END'
      'from FATURA F where FATBASID=:PFatbasID'
      '')
    Left = 148
    Top = 177
    ParamData = <
      item
        Name = 'PFatbasID'
        DataType = ftWideString
        Size = 4
        Value = '1183'
      end>
  end
  object DtsUretimDetay: TDataSource
    DataSet = TabUretimDetay
    Left = 256
    Top = 179
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 479
    Top = 172
  end
  object PopupMenuUretim: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 70
    Top = 117
    object UretimFisInfoMenu: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = UretimFisInfoMenuClick
    end
    object rsaliyeOlutur1: TMenuItem
      Tag = 14
      Caption = #304'rsaliye Olu'#351'tur'
      ImageIndex = 19
      OnClick = FaturaOlutur1Click
    end
    object FaturaOlutur1: TMenuItem
      Tag = 15
      Caption = 'Fatura Olu'#351'tur'
      ImageIndex = 19
      OnClick = FaturaOlutur1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MenuUretim: TMenuItem
      Caption = 'Belgeyi A'#231
      ImageIndex = 0
      OnClick = GorTusClick
    end
    object KaynakBelgeyiAcMenu: TMenuItem
      Caption = 'Kaynak Belgeyi A'#231
      ImageIndex = 19
      OnClick = KaynakBelgeyiAcMenuClick
    end
    object HedefBelgeyiA1: TMenuItem
      Caption = 'Hedef Belgeyi A'#231
      ImageIndex = 19
      OnClick = HedefBelgeyiA1Click
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    Grid = GridUretim
    PopupMenus = <
      item
        GridView = GridUretimView
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupMenuUretim
      end>
    AlwaysFireOnPopup = True
    Left = 384
    Top = 248
  end
end
