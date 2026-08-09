object KasaDlg: TKasaDlg
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  ParentFont = False
  PopupMenu = PopupMenu1
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 0
    Top = 145
    Width = 451
    Height = 0
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 424
    ExplicitWidth = 1047
  end
  object Label7: TLabel
    Left = 88
    Top = 16
    Width = 7
    Height = 13
    Caption = '$'
  end
  object Label8: TLabel
    Left = 88
    Top = 28
    Width = 7
    Height = 13
    Caption = '$'
  end
  object PanelToplam: TPanel
    Left = 0
    Top = 145
    Width = 451
    Height = 159
    Align = alBottom
    Caption = 'PanelToplam'
    TabOrder = 0
    Visible = False
    object GridToplam: TcxGrid
      Left = 1
      Top = 1
      Width = 449
      Height = 138
      Align = alClient
      PopupMenu = PopupMenu1
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object GridToplamDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        DataController.DataSource = DtsToplam
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnTab = True
        OptionsSelection.HideSelection = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        Styles.Content = cxStyle1
        Styles.Header = cxStyle2
        Styles.Indicator = cxStyle2
        object GridToplamDBTableView1HESAPKODU: TcxGridDBColumn
          DataBinding.FieldName = 'HESAPKODU'
          Width = 87
        end
        object GridToplamDBTableView1HESAPADI: TcxGridDBColumn
          DataBinding.FieldName = 'HESAPADI'
          Width = 199
        end
        object GridToplamDBTableView1DEVIR: TcxGridDBColumn
          DataBinding.FieldName = 'DEVIR'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(,0.00)'
          Width = 103
        end
        object GridToplamDBTableView1GIREN: TcxGridDBColumn
          DataBinding.FieldName = 'GIREN'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(,0.00)'
          Width = 102
        end
        object GridToplamDBTableView1CIKAN: TcxGridDBColumn
          DataBinding.FieldName = 'CIKAN'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(,0.00)'
          Width = 95
        end
        object GridToplamDBTableView1KALAN: TcxGridDBColumn
          DataBinding.FieldName = 'KALAN'
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(,0.00)'
        end
        object GridToplamDBTableView1KUR: TcxGridDBColumn
          DataBinding.FieldName = 'KUR'
        end
      end
      object GridToplamLevel1: TcxGridLevel
        GridView = GridToplamDBTableView1
      end
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 139
      Width = 449
      Height = 19
      Color = clSilver
      Panels = <
        item
          Bevel = pbRaised
          Width = 300
        end>
      Visible = False
    end
  end
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 22
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 20
    ButtonWidth = 50
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
    TabOrder = 1
    Transparent = True
    object EkleTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object SilTus: TToolButton
      Left = 50
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = SilTusClick
    end
    object ToolButton1: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object GorTus: TToolButton
      Left = 108
      Top = 0
      Caption = 'G'#246'r'
      ImageIndex = 9
      OnClick = GorTusClick
    end
    object ToolButton3: TToolButton
      Left = 158
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 23
      Style = tbsSeparator
    end
    object VarliklarTus: TToolButton
      Left = 166
      Top = 0
      Caption = 'Varl'#305'klar'
      ImageIndex = 22
      OnClick = VarliklarTusClick
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 25
    Width = 451
    Height = 120
    Align = alClient
    TabOrder = 2
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    object KasaGrid: TcxGridDBTableView
      PopupMenu = PopupMenu1
      OnDblClick = GorTusClick
      OnMouseUp = KasaGridMouseUp
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = DtsKasa
      DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys]
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsBehavior.AlwaysShowEditor = True
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsView.GroupByBox = False
      object KasaGridTUR: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TUR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'A'#231#305'l'#305#351' Fi'#351'i'
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Devir'
            Value = 2
          end
          item
            Description = 'Al'#305#351' Faturas'#305
            ImageIndex = 0
            Value = 11
          end
          item
            Description = 'Al'#305#351' Fi'#351'i'
            Value = 12
          end
          item
            Description = 'Sat'#305#351' Faturas'#305
            Value = 15
          end
          item
            Description = 'Sat'#305#351' Fi'#351'i'
            Value = 16
          end
          item
            Description = 'Kasa Tahsilat'
            Value = 21
          end
          item
            Description = 'Banka Tahsilat'
            Value = 22
          end
          item
            Description = #199'ekle Tahsilat'
            Value = 23
          end
          item
            Description = 'Senetle Tahsilat'
            Value = 24
          end
          item
            Description = 'Kredi Kart'#305'yla Tahsilat'
            Value = 25
          end
          item
            Description = 'Kasa '#214'deme'
            Value = 31
          end
          item
            Description = 'Banka '#214'deme'
            Value = 32
          end
          item
            Description = #199'ekle '#214'deme'
            Value = 33
          end
          item
            Description = 'Senetle '#214'deme'
            Value = 34
          end
          item
            Description = 'Kredi Kart'#305'yla '#214'deme'
            Value = 35
          end
          item
            Description = 'Bankaya Yatan'
            Value = 41
          end
          item
            Description = 'Bankadan '#199'ekilen'
            Value = 42
          end
          item
            Description = 'Virman'
            Value = 43
          end
          item
            Description = 'D'#246'viz Al'#305#351
            Value = 45
          end
          item
            Description = 'D'#246'viz Sat'#305#351
            Value = 46
          end
          item
            Description = 'D'#246'viz Al'#305#351
            Value = 47
          end
          item
            Description = 'D'#246'viz Sat'#305#351
            Value = 48
          end
          item
            Description = #199'ek Bozduruldu'
            Value = 51
          end
          item
            Description = 'Senet Bozduruldu'
            Value = 52
          end
          item
            Description = #199'ek Bozduruldu'
            Value = 53
          end
          item
            Description = 'Senet Bozduruldu'
            Value = 54
          end
          item
            Description = 'Tahsilat Plan'#305
            Value = 61
          end
          item
            Description = #214'deme Plan'#305
            Value = 71
          end
          item
            Description = 'Kredi '#214'deme'
            Value = 75
          end
          item
            Description = 'Tahakkuk'
            Value = 81
          end
          item
            Description = 'POS Giri'#351'i'
            Value = 121
          end
          item
            Description = 'Nakit Giri'#351'i'
            Value = 122
          end>
      end
      object KasaGridDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <
          item
            Description = 'Tahmin'
            ImageIndex = 0
            Value = 0
          end
          item
            Description = 'Fatural'#305
            ImageIndex = 0
            Value = 1
          end
          item
            Description = 'Tamamland'#305
            ImageIndex = 0
            Value = 2
          end>
        Width = 47
      end
      object KasaGridKAYITTARIH: TcxGridDBColumn
        Caption = 'Kay'#305't'
        DataBinding.FieldName = 'KAYITTARIH'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxDateEditProperties'
      end
      object KasaGridAKSIYONTARIH: TcxGridDBColumn
        Caption = 'Aksiyon/Vade'
        DataBinding.FieldName = 'AKSIYONTARIH'
        DataBinding.IsNullValueType = True
        Width = 88
      end
      object KasaGridBELGENO: TcxGridDBColumn
        Caption = 'Belge No'
        DataBinding.FieldName = 'BELGENO'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Width = 58
      end
      object KasaGridCARIKOD: TcxGridDBColumn
        Caption = 'Cari Kod'
        DataBinding.FieldName = 'CARIKOD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = KasaGridCARIKODPropertiesButtonClick
        Width = 97
      end
      object KasaGridCARIAD: TcxGridDBColumn
        Caption = 'Cari Ad'
        DataBinding.FieldName = 'CARIAD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = KasaGridCARIADPropertiesButtonClick
        Width = 106
      end
      object KasaGridACIKLAMA: TcxGridDBColumn
        Caption = 'A'#231#305'klama'
        DataBinding.FieldName = 'ACIKLAMA'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxComboBoxProperties'
        Width = 122
      end
      object KasaGridHESAPKODU: TcxGridDBColumn
        Caption = 'Hesap Kodu'
        DataBinding.FieldName = 'HESAPKODU'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Width = 91
      end
      object KasaGridHESAPADI: TcxGridDBColumn
        Caption = 'Hesap Ad'#305
        DataBinding.FieldName = 'HESAPADI'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Width = 128
      end
      object KasaGridGIREN: TcxGridDBColumn
        Caption = 'Giren'
        DataBinding.FieldName = 'GIREN'
        DataBinding.IsNullValueType = True
      end
      object KasaGridCIKAN: TcxGridDBColumn
        Caption = #199#305'kan'
        DataBinding.FieldName = 'CIKAN'
        DataBinding.IsNullValueType = True
      end
      object KasaGridKASA: TcxGridDBColumn
        Caption = 'Kasa'
        DataBinding.FieldName = 'KASA'
        DataBinding.IsNullValueType = True
        Width = 96
      end
      object KasaGridONAY: TcxGridDBColumn
        Caption = 'Onay'
        DataBinding.FieldName = 'ONAY'
        DataBinding.IsNullValueType = True
        Visible = False
        Width = 64
      end
      object KasaGridKULLANICI: TcxGridDBColumn
        Caption = 'Kullan'#305'c'#305
        DataBinding.FieldName = 'KULLANICI'
        DataBinding.IsNullValueType = True
        Width = 87
      end
      object KasaGridMASRAFKOD: TcxGridDBColumn
        Caption = 'Masraf Kodu'
        DataBinding.FieldName = 'MASRAFKOD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = KasaGridMASRAFKODPropertiesButtonClick
        Width = 99
      end
      object KasaGridMASRAFAD: TcxGridDBColumn
        Caption = 'Masraf Ad'#305
        DataBinding.FieldName = 'MASRAFAD'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxComboBoxProperties'
        Width = 132
      end
      object KasaGridKUR: TcxGridDBColumn
        Caption = 'Kur'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxComboBoxProperties'
        Width = 66
      end
    end
    object cxGrid1Level1: TcxGridLevel
      Caption = 'Kasa'
      GridView = KasaGrid
    end
  end
  object SQLKasa: TcxMemo
    Left = 31
    Top = 56
    Lines.Strings = (
      
        'Select K.ID, ISLEMTARIHI AS KAYITTARIH, ISLEMTARIHI AS AKSIYONTA' +
        'RIH, K.TUR,BELGENO, REHBERID,'
      'CARIKOD=R.KOD, '
      'CARIAD=R.FIRMA, K.ACIKLAMA, HESAPID, '
      '     HESAPKODU=case HESAPTURU '
      
        '         when '#39'B'#39' then (select HESAPKODU from BANKAHESAPLAR BH w' +
        'here BH.ID=K.HESAPID) '
      
        '         when '#39'K'#39' then (select KASAKODU from KASALAR K2 where K2' +
        '.ID=K.HESAPID)'
      
        '         when '#39'P'#39' then (select HESAPKODU = KODU from POS P where' +
        ' P.ID=K.HESAPID) '
      
        '         when '#39'V'#39' then (select HESAPKODU = KODU from KREDIKARTI ' +
        'KK where KK.ID=K.HESAPID) '
      '     end,'
      '     HESAPADI=case HESAPTURU '
      
        '         when '#39'B'#39' then (select HESAPADI from BANKAHESAPLAR BH wh' +
        'ere BH.ID=K.HESAPID) '
      
        '         when '#39'K'#39' then (select KASAADI from KASALAR K2 where K2.' +
        'ID=K.HESAPID)'
      
        '         when '#39'P'#39' then (select ADI from POS P where P.ID=K.HESAP' +
        'ID) '
      
        '         when '#39'V'#39' then (select ADI from KREDIKARTI KK where KK.I' +
        'D=K.HESAPID) '
      '     end,'
      '     GIREN, CIKAN, DOVIZ, KASA, ONAY, K.EKLEYEN, '
      '       MASRAFKOD=MG.KOD, MASRAFAD=MG.AD, '
      
        '       K.KUR, GERIDONUSID, K.DURUM, FATURAID, CEKSENETID,KREDIID' +
        ' '
      '     FROM KASA K (NOLOCK)'
      '     left outer join REHBER R on R.ID=K.REHBERID'
      '     left outer join MASRAFGELIR MG on MG.ID=K.MASRAFID'
      '')
    TabOrder = 3
    Visible = False
    Height = 41
    Width = 634
  end
  object SQLFatura: TcxMemo
    Left = 23
    Top = 135
    Lines.Strings = (
      'UNION ALL'
      ''
      'SELECT '
      
        #9'SIRANO= F.ID,TARIH as KAYITTARIH, FATURATARIH as AKSIYONTARIH, ' +
        '  TUR,'
      'FATURANO as BELGENO, REHBERID,'
      'CARIKOD=R.KOD,CARIAD=R.FIRMA, '
      #9'ACIKLAMA,HESAPKODU= null,'#9'HESAPADI= null,'
      #9'HESAPID=null,'
      #9'GIREN=case when TUR in (11,12) then FATURA_TUTARI else 0.0 end,'
      #9'CIKAN=case when TUR in (15,16) then FATURA_TUTARI else 0.0 end,'
      #9'DOVIZ=0,KASA=0,ONAY=NULL, '
      #9'F.EKLEYEN ,'#9'MASRAFKOD = '#39#39#39#39','#9'MASRAFAD='#39#39#39#39','#9
      #9'KUR,GERIDONUSID=NULL, DURUM=NULL,'
      #9'FATURAID=NULL, CEKSENETID=NULL,KREDIID=null '
      'FROM '
      #9'FATBASLIK F (NOLOCK)'
      #9'inner join REHBER R on R.ID = F.REHBERID')
    TabOrder = 4
    Visible = False
    Height = 48
    Width = 634
  end
  object SQLCekSenet: TcxMemo
    Left = 31
    Top = 182
    Lines.Strings = (
      'UNION ALL'
      'SELECT '
      #9' C.ID,C.TARIH as KAYITTARIH,C.VADE as AKSIYONTARIH,   C.TUR, '#9
      #9'SERINO as BELGENO,REHBERID, CARIKOD=R.KOD, CARIAD=R.FIRMA, '
      #9'C.ACIKLAMA,'
      #9'HESAPID=BANKASUBELERID,HESAPKODU=HESAPNO,HESAPADI=RTRIM'
      '(B.BANKAADI)+'#39'/'#39'+BS.SUBEADI,'
      #9'GIREN = case when TUR=23 or TUR=24 then  TUTAR else 0    end,'
      #9'CIKAN = case when TUR=33 or TUR=34 then  TUTAR else 0    end,'
      #9'DOVIZ=0,KASA=0,ONAY=NULL, '
      #9'C.EKLEYEN ,MASRAFKOD = '#39#39','#9'MASRAFAD='#39#39','
      #9'KUR,GERIDONUSID=NULL, DURUM=NULL,FATURAID=NULL, '
      #9'CEKSENETID=NULL,KREDIID=null '
      'FROM '
      #9'CEKSENETLER C'
      #9'inner join REHBER R on R.ID=C.REHBERID'
      #9'INNER JOIN BANKASUBELER BS ON BS.ID = C.BANKASUBELERID'
      #9'INNER JOIN BANKALAR B ON B.BANKAKODU = BS.BANKAKODU')
    TabOrder = 5
    Visible = False
    Height = 50
    Width = 634
  end
  object SQLStokGiris: TcxMemo
    Left = 23
    Top = 231
    Lines.Strings = (
      'UNION ALL'
      
        'SELECT ID= 0,  TARIH as KAYITTARIH, TARIH as AKSIYONTARIH,  TUR=' +
        'null, '
      'BELGENO=null,REHBERID=NULL,'#9
      'CARIKOD=FIRMAKODU, CARIAD=FIRMAADI, '
      
        'ACIKLAMA = '#39' **** ('#39'+CONVERT(VARCHAR(10),ISNULL(GIRNO,0)) +'#39')  S' +
        'TOK G'#304'R'#304#350' '#39'+ISNULL(BELGENO,'#39#39'),'
      
        'HESAPKODU= '#39#39','#9'HESAPADI= '#39#39#39#39',HESAPID=null,GIREN=0 ,CIKAN=TUTAR,' +
        'DOVIZ=0,KASA=0,ONAY=NULL, '
      ' EKLEYEN = KULLANICI,'#9'MASRAFKOD = '#39#39','#9'MASRAFAD='#39#39','
      
        'KUR = '#39'TL'#39', GERIDONUSID=NULL, DURUM=NULL,FATURAID=NULL, CEKSENET' +
        'ID=NULL,KREDIID=null '
      'FROM STOKGIRIS')
    TabOrder = 6
    Visible = False
    Height = 41
    Width = 634
  end
  object SQLPersonel: TcxMemo
    Left = 31
    Top = 94
    Lines.Strings = (
      'union all'
      
        'Select P.ID, TARIH AS KAYITTARIH, TARIH AS AKSIYONTARIH, TUR=5, ' +
        'BELGENO=null, P.REHBERID,'
      
        'CARIKOD=R.KOD, CARIAD=R.FIRMA, ACIKLAMA='#39'Personel '#220'cret'#39', HESAPI' +
        'D=null, '
      '     HESAPKODU=null,HESAPADI=null,'
      
        '     GIREN=sum(TUTAR), CIKAN=0, DOVIZ=null, KASA=null, ONAY=null' +
        ', P.EKLEYEN, '
      '       MASRAFKOD=null, MASRAFAD=null, '
      '       --MASRAFKOD=MG.KOD, MASRAFAD=MG.AD, '
      
        '       P.KUR, GERIDONUSID=null, P.DURUM, FATURAID=null, CEKSENET' +
        'ID=null,KREDIID=null '
      '     FROM PLANMAAS P (NOLOCK) '
      '     inner join REHBER R on R.ID=P.REHBERID')
    TabOrder = 7
    Visible = False
    Height = 41
    Width = 634
  end
  object DtsKasa: TDataSource
    DataSet = TabKasa
    OnStateChange = DtsKasaStateChange
    Left = 169
    Top = 278
  end
  object TabKasa: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = TabKasaAfterOpen
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM KASA')
    Left = 168
    Top = 321
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    Left = 117
    Top = 109
    object EkleMenu: TMenuItem
      Caption = 'Ekle'
      ImageIndex = 0
      OnClick = EkleTusClick
    end
    object SilMenu: TMenuItem
      Caption = 'Sil'
      ImageIndex = 1
      OnClick = SilTusClick
    end
    object GorMenu: TMenuItem
      Caption = 'G'#246'r'
      ImageIndex = 37
      OnClick = GorTusClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Ekstre1: TMenuItem
      Caption = 'Ekstre'
      ImageIndex = 15
      OnClick = Ekstre1Click
    end
    object Varlklar1: TMenuItem
      Caption = 'Varl'#305'klar'
      ImageIndex = 15
      OnClick = VarliklarTusClick
    end
  end
  object Toplam: TFDQuery
    Connection = Tablo.FDCnn
    AfterOpen = ToplamAfterOpen
    ParamData = <
      item
        Name = 'PTarih0'
        Size = -1
        Value = Null
      end
      item
        Name = 'PTarih1'
        Size = -1
        Value = Null
      end>
    SQL.Strings = (
      'DECLARE '
      '@TARIH0 DATETIME,'
      '@TARIH1 DATETIME'
      ''
      '--SET @TARIH0 = '#39'2010-07-16 00:00'#39
      '--SET @TARIH1 = '#39'2010-07-16 23:59'#39
      'SET @TARIH0 = :PTarih0'
      'SET @TARIH1 = :PTarih1'
      'SELECT '
      #9'ID,'
      #9'KASAKODU as HESAPKODU,'
      #9'KASAADI as HESAPADI, '
      
        #9'DEVIR=ISNULL((select SUM(ISNULL(GIREN,0)-ISNULL(CIKAN,0)) from ' +
        'KASA K2 (NOLOCK) where K2.HESAPTURU='#39'K'#39' AND K1.ID=K2.HESAPID AND' +
        ' ISLEMTARIHI < @TARIH0),0),'
      
        #9'GIREN=ISNULL((select SUM(ISNULL(GIREN,0)) from KASA K2 (NOLOCK)' +
        ' where  K2.HESAPTURU='#39'K'#39' AND K1.ID=K2.HESAPID and ISLEMTARIHI be' +
        'tween @TARIH0 and @TARIH1) , 0), '
      
        #9'CIKAN=ISNULL((select SUM(ISNULL(CIKAN,0)) from KASA K2 (NOLOCK)' +
        ' where K2.HESAPTURU='#39'K'#39' AND K1.ID=K2.HESAPID and ISLEMTARIHI bet' +
        'ween @TARIH0 and @TARIH1) , 0), '
      
        #9'KALAN=ISNULL((select SUM(ISNULL(GIREN,0)-ISNULL(CIKAN,0)) from ' +
        'KASA K2 (NOLOCK) where K2.HESAPTURU='#39'K'#39' AND K1.ID=K2.HESAPID and' +
        ' ISLEMTARIHI <= @TARIH1),0), '
      #9'--B'#220'T'#220'N KALAN - BUG'#220'N VE SONRASI'
      #9'KUR  '
      'FROM KASALAR K1 (NOLOCK)  '
      'WHERE GUNLUKAKSIYONDAGOSTER=1 '
      'GROUP BY ID,KASAKODU,KASAADI,KUR '
      
        'HAVING (select SUM(ISNULL(GIREN,0)-ISNULL(CIKAN,0)) from KASA K2' +
        ' (NOLOCK) where K1.ID=K2.HESAPID and ISLEMTARIHI < @TARIH1)>0'
      ' '
      '  union all  '
      'SELECT '
      #9'ID,'
      #9'HESAPKODU,'
      #9'HESAPADI, '
      
        #9'DEVIR=ISNULL((select SUM(ISNULL(GIREN,0)-ISNULL(CIKAN,0)) from ' +
        'KASA K2 (NOLOCK) where K2.HESAPTURU='#39'B'#39' AND K1.ID=K2.HESAPID AND' +
        ' ISLEMTARIHI < @TARIH0),0),'
      
        #9'GIREN=ISNULL((select SUM(ISNULL(GIREN,0)) from KASA K2 (NOLOCK)' +
        ' where  K2.HESAPTURU='#39'B'#39' AND K1.ID=K2.HESAPID and ISLEMTARIHI be' +
        'tween @TARIH0 and @TARIH1) , 0), '
      
        #9'CIKAN=ISNULL((select SUM(ISNULL(CIKAN,0)) from KASA K2 (NOLOCK)' +
        ' where K2.HESAPTURU='#39'B'#39' AND K1.ID=K2.HESAPID and ISLEMTARIHI bet' +
        'ween @TARIH0 and @TARIH1) , 0), '
      
        #9'KALAN=ISNULL((select SUM(ISNULL(GIREN,0)-ISNULL(CIKAN,0)) from ' +
        'KASA K2 (NOLOCK) where K2.HESAPTURU='#39'B'#39' AND K1.ID=K2.HESAPID and' +
        ' ISLEMTARIHI <= @TARIH1),0), '
      #9'KUR   '
      'FROM BANKAHESAPLAR K1 (NOLOCK)  '
      'WHERE GUNLUKAKSIYONDAGOSTER=1  '
      'GROUP BY ID, HESAPKODU,HESAPADI,KUR '
      
        'HAVING (select SUM(ISNULL(GIREN,0)-ISNULL(CIKAN,0))from KASA K2 ' +
        '(NOLOCK) where K1.ID=K2.HESAPID and ISLEMTARIHI < @TARIH1 )>0'
      ' '
      'ORDER BY 2')
    Left = 97
    Top = 321
    object ToplamHESAPKODU: TStringField
      FieldName = 'HESAPKODU'
      Origin = 'GENOTIP.KASA.HESAPKODU'
      FixedChar = True
    end
    object ToplamHESAPADI: TStringField
      FieldName = 'HESAPADI'
      Origin = 'GENOTIP.KASA.HESAPADI'
      FixedChar = True
      Size = 50
    end
    object ToplamDEVIR: TBCDField
      FieldName = 'DEVIR'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object ToplamGIREN: TBCDField
      FieldName = 'GIREN'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object ToplamTOPLAMGIREN: TBCDField
      FieldKind = fkCalculated
      FieldName = 'TOPLAMGIREN'
      DisplayFormat = '###,###,###,##0.00'
      Calculated = True
    end
    object ToplamCIKAN: TBCDField
      FieldName = 'CIKAN'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object ToplamKALAN: TBCDField
      DisplayWidth = 20
      FieldName = 'KALAN'
      DisplayFormat = '###,###,###,##0.00'
      currency = True
      Precision = 19
    end
    object ToplamKUR: TStringField
      FieldName = 'KUR'
      Origin = 'GENOTIP.KASA.KUR'
      FixedChar = True
      Size = 6
    end
  end
  object DtsToplam: TDataSource
    AutoEdit = False
    DataSet = Toplam
    Left = 98
    Top = 281
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <>
    StorageName = 'cxPropertiesStore1'
    StorageType = stRegistry
    Left = 24
    Top = 88
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 17
    Top = 57
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = []
      TextColor = clBlack
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    PopupMenus = <
      item
        GridView = KasaGrid
        HitTypes = [gvhtCell]
        Index = 0
        PopupMenu = PopupMenu1
      end>
    Left = 172
    Top = 111
  end
end

