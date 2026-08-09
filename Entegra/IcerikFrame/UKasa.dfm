object KasaDlg: TKasaDlg
  Left = 0
  Top = 0
  Width = 930
  Height = 454
  Align = alClient
  Font.Charset = TURKISH_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentFont = False
  PopupMenu = PopupMenu1
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 0
    Top = 287
    Width = 930
    Height = 0
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 424
    ExplicitWidth = 1047
  end
  object Label7: TLabel
    Left = 88
    Top = 16
    Width = 6
    Height = 16
    Caption = '$'
  end
  object Label8: TLabel
    Left = 88
    Top = 28
    Width = 6
    Height = 16
    Caption = '$'
  end
  object PanelToplam: TPanel
    Left = 0
    Top = 295
    Width = 930
    Height = 159
    Align = alBottom
    Caption = 'PanelToplam'
    TabOrder = 7
    Visible = False
    object GridToplam: TcxGrid
      Left = 1
      Top = 1
      Width = 928
      Height = 138
      Align = alClient
      PopupMenu = PopupMenu1
      TabOrder = 0
      LookAndFeel.Kind = lfOffice11
      LookAndFeel.NativeStyle = True
      LookAndFeel.ScrollbarMode = sbmClassic
      object GridToplamDBTableView1: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = GridToplamDBTableView1CanFocusRecord
        DataController.DataSource = DtsToplam
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsBehavior.FocusCellOnTab = True
        OptionsSelection.CellSelect = False
        OptionsSelection.HideSelection = True
        OptionsView.GroupByBox = False
        OptionsView.Indicator = True
        Styles.Content = cxStyle1
        Styles.OnGetContentStyle = GridToplamDBTableView1StylesGetContentStyle
        Styles.Header = cxStyle2
        Styles.Indicator = cxStyle2
        object GridToplamDBTableView1HESAPKODU: TcxGridDBColumn
          Caption = 'Hesap Kodu'
          DataBinding.FieldName = 'HESAPKODU'
          DataBinding.IsNullValueType = True
          Width = 87
        end
        object GridToplamDBTableView1HESAPADI: TcxGridDBColumn
          Caption = 'Hesap Ad'#305
          DataBinding.FieldName = 'HESAPADI'
          DataBinding.IsNullValueType = True
          Width = 199
        end
        object GridToplamDBTableView1DEVIR: TcxGridDBColumn
          Caption = 'Devir'
          DataBinding.FieldName = 'DEVIR'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(-,0.00)'
          Width = 100
        end
        object GridToplamDBTableView1GIREN: TcxGridDBColumn
          Caption = 'Bor'#231
          DataBinding.FieldName = 'BORC'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(-,0.00)'
          Width = 100
        end
        object GridToplamDBTableView1CIKAN: TcxGridDBColumn
          Caption = 'Alacak'
          DataBinding.FieldName = 'ALACAK'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(-,0.00)'
          Width = 100
        end
        object GridToplamDBTableView1KALAN: TcxGridDBColumn
          Caption = 'Kalan'
          DataBinding.FieldName = 'KALAN'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;(-,0.00)'
          Width = 100
        end
        object GridToplamDBTableView1KUR: TcxGridDBColumn
          Caption = 'Kur'
          DataBinding.FieldName = 'KUR'
          DataBinding.IsNullValueType = True
        end
      end
      object GridToplamLevel1: TcxGridLevel
        GridView = GridToplamDBTableView1
      end
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 139
      Width = 928
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
    Width = 924
    Height = 40
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 38
    ButtonWidth = 82
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
      DropdownMenu = PopupMenuYeni
      ImageIndex = 7
      ImageName = 'PngImage6'
      Style = tbsDropDown
      OnClick = YeniTusClick
    end
    object SilTus: TToolButton
      Left = 97
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      ImageName = 'PngImage7'
      OnClick = SilTusClick
    end
    object GorTus: TToolButton
      Left = 179
      Top = 0
      Caption = 'G'#246'r'
      ImageIndex = 9
      ImageName = 'PngImage8'
      OnClick = GorTusClick
    end
    object ToolButton1: TToolButton
      Left = 261
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      ImageName = 'PngImage8'
      Style = tbsSeparator
    end
    object YaziciYaz: TToolButton
      Left = 269
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
      ImageName = 'PngImage15'
    end
    object ToolButton3: TToolButton
      Left = 351
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 23
      ImageName = 'PngImage23'
      Style = tbsSeparator
    end
    object VarliklarTus: TToolButton
      Left = 359
      Top = 0
      Caption = 'Varl'#305'klar'
      ImageIndex = 22
      ImageName = 'PngImage22'
      OnClick = VarliklarTusClick
    end
    object ToolButton2: TToolButton
      Left = 441
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 23
      ImageName = 'PngImage23'
      Style = tbsSeparator
    end
    object CbGroupAcKapa: TcxCheckBox
      Left = 449
      Top = 0
      Caption = 'A'#231#305'k'
      ParentBackground = False
      ParentColor = False
      Properties.ImmediatePost = True
      TabOrder = 0
      OnClick = CbGroupAcKapaClick
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 43
    Width = 930
    Height = 244
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 1
    LookAndFeel.Kind = lfOffice11
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmClassic
    object KasaGrid: TcxGridDBTableView
      OnDblClick = GorTusClick
      OnMouseUp = KasaGridMouseUp
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCanFocusRecord = KasaGridCanFocusRecord
      DataController.DataSource = DtsKasa
      DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = '###,###,###,##0.00'
          Kind = skSum
          Position = spFooter
          FieldName = 'ALACAK'
          Column = KasaGridALACAK
        end
        item
          Format = '###,###,###,##0.00'
          Kind = skSum
          Position = spFooter
          FieldName = 'BORC'
          Column = KasaGridBORC
        end
        item
          Format = '###,###,###,##0.00'
          Kind = skSum
          Position = spFooter
        end
        item
          Kind = skCount
          Position = spFooter
          FieldName = 'AKSIYONTARIH'
          Column = KasaGridAKSIYONTARIH
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skSum
          FieldName = 'BORC'
          Column = KasaGridBORC
        end
        item
          Kind = skSum
          FieldName = 'ALACAK'
          Column = KasaGridALACAK
        end
        item
          Kind = skSum
        end
        item
          Kind = skCount
          FieldName = 'AKSIYONTARIH'
          Column = KasaGridAKSIYONTARIH
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
      OptionsView.FooterMultiSummaries = True
      OptionsView.GroupFooterMultiSummaries = True
      OptionsView.GroupFooters = gfAlwaysVisible
      OptionsView.Indicator = True
      Styles.OnGetContentStyle = KasaGridStylesGetContentStyle
      object KasaGridTUR: TcxGridDBColumn
        Caption = 'T'#252'r'
        DataBinding.FieldName = 'TUR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepKasaTurleri
        Visible = False
        GroupIndex = 0
      end
      object KasaGridDURUM: TcxGridDBColumn
        Caption = 'Durum'
        DataBinding.FieldName = 'DURUM'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxTextEditProperties'
        Width = 47
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
      object KasaGridBORC: TcxGridDBColumn
        Caption = 'Bor'#231
        DataBinding.FieldName = 'BORC'
        DataBinding.IsNullValueType = True
      end
      object KasaGridALACAK: TcxGridDBColumn
        Caption = 'Alacak'
        DataBinding.FieldName = 'ALACAK'
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
        Caption = 'P.Birimi'
        DataBinding.FieldName = 'KUR'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxComboBoxProperties'
        Width = 66
      end
      object KasaGridSUBEID: TcxGridDBColumn
        Caption = #350'ube'
        DataBinding.FieldName = 'SUBEID'
        DataBinding.IsNullValueType = True
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Items = <>
        RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
      end
      object KasaGridOZELKOD: TcxGridDBColumn
        Caption = #214'zel Kod'
        DataBinding.FieldName = 'OZELKOD'
        DataBinding.IsNullValueType = True
      end
    end
    object cxGrid1Level1: TcxGridLevel
      Caption = 'Kasa'
      GridView = KasaGrid
    end
  end
  object SQLKasa: TcxMemo
    Left = 201
    Top = 190
    Lines.Strings = (
      
        'Select K.ID, ISLEMTARIHI AS KAYITTARIH, PLANTARIHI AS AKSIYONTAR' +
        'IH, K.TUR,BELGENO=cast(BELGENO as nvarchar(20)), REHBERID,'
      'CARIKOD=R.KOD, '
      'CARIAD=R.FIRMA, K.ACIKLAMA, HESAPID, '
      '     HESAPKODU=case HESAPTURU '
      
        '         when '#39'B'#39' then (select HESAPKODU from BANKAHESAPLAR BH w' +
        'here BH.ID=K.HESAPID) '
      
        '         when '#39'K'#39' then (select KASAKODU from KASALAR K2 where K2' +
        '.ID=K.HESAPID)'
      
        '         when '#39'H'#39' then (select KASAKODU from KASALAR K2 where K2' +
        '.ID=K.HESAPID)+isnull('#39' ('#39'+ (select ADI from PARA_KUPON PK where' +
        ' PK.ID=K.CEKSENETID)+'#39')'#39','#39#39')'
      
        '         when '#39'P'#39' then (select HESAPKODU = KODU from POS P where' +
        ' P.ID=K.HESAPID) '
      
        '         when '#39'V'#39' then (select HESAPKODU = KODU from KREDIKARTI ' +
        'KK where KK.ID=K.HESAPID)'
      
        '         when '#39'R'#39' then (select HESAPKODU = KREDIKODU from KREDIL' +
        'ER KR where KR.ID=K.HESAPID)'
      
        '         when '#39'M'#39' then (select HESAPKODU = KOD  from MASRAFGELIR' +
        ' M where M.ID=K.HESAPID)'
      '     end,'
      '     HESAPADI=case HESAPTURU'
      
        '         when '#39'B'#39' then (select HESAPADI from BANKAHESAPLAR BH wh' +
        'ere BH.ID=K.HESAPID)'
      
        '         when '#39'K'#39' then (select HESAPADI = KASAADI from KASALAR K' +
        '2 where K2.ID=K.HESAPID)'
      
        '         when '#39'H'#39' then (select HESAPADI = KASAADI from KASALAR K' +
        '2 where K2.ID=K.HESAPID)+isnull('#39' ('#39'+ (select ADI from PARA_KUPO' +
        'N PK where PK.ID=K.CEKSENETID)+'#39')'#39','#39#39')'
      
        '         when '#39'P'#39' then (select HESAPADI = ADI from POS P where P' +
        '.ID=K.HESAPID)'
      
        '         when '#39'V'#39' then (select HESAPADI = ADI from KREDIKARTI KK' +
        ' where KK.ID=K.HESAPID)'
      
        '         when '#39'R'#39' then (select HESAPADI = ADI from KREDILER KR w' +
        'here KR.ID=K.HESAPID)'
      
        '         when '#39'M'#39' then (select HESAPADI = AD from MASRAFGELIR M ' +
        'where M.ID=K.HESAPID)'
      ''
      '     end,'
      
        '     BORC = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,5' +
        '1,52,53,54,58,59) and isnull(HESAPTURU,'#39#39')<>'#39#39' then ALACAK'
      'else'
      'BORC'
      'end,'
      
        '     ALACAK = case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48' +
        ',51,52,53,54,58,59) and  isnull(HESAPTURU,'#39#39')<>'#39#39' then BORC else'
      'ALACAK '
      'end,'
      ' DOVIZ_TUTARI, KASA, ONAY, K.EKLEYEN, '
      '       MASRAFKOD=MG.KOD, MASRAFAD=MG.AD, '
      '       K.KUR, GERIDONUSID, DURUM=null, FATURAID, '
      'CEKSENETID,KREDIID ,'
      'K.YERI, K.YERID,OZELKOD='#39#39',K.SUBEID'
      'FROM KASA K (NOLOCK)'
      '     left outer join REHBER R on R.ID=K.REHBERID'
      '     left outer join MASRAFGELIR MG on MG.ID=K.MASRAFID')
    Properties.WordWrap = False
    Style.Color = 8453888
    TabOrder = 2
    Visible = False
    Height = 41
    Width = 634
  end
  object SQLPersonel: TcxMemo
    Left = 206
    Top = 214
    Lines.Strings = (
      'union all'
      
        'Select P.ID, TARIH AS KAYITTARIH, TARIH AS AKSIYONTARIH, TUR=5, ' +
        'BELGENO=null, P.REHBERID,'
      
        'CARIKOD=R.KOD, CARIAD=R.FIRMA, ACIKLAMA='#39'Personel '#220'cret'#39', HESAPI' +
        'D=null, '
      '     HESAPKODU=null,HESAPADI=null,'
      
        '     BORC=0, ALACAK=SUM(P.TUTAR), DOVIZ_TUTARI=0, KASA=null, ONA' +
        'Y=null, P.EKLEYEN, '
      '       MASRAFKOD=null, MASRAFAD=null, '
      '       --MASRAFKOD=MG.KOD, MASRAFAD=MG.AD, '
      
        '       P.KUR, GERIDONUSID=null, DURUM=null, FATURAID=null, CEKSE' +
        'NETID=null,KREDIID=null '
      ',YERI=NULL, YERID=NULL,OZELKOD='#39#39',P.SUBEID'
      '     FROM PLANMAAS P (NOLOCK) '
      '     inner join REHBER R on R.ID=P.REHBERID')
    Properties.WordWrap = False
    Style.Color = 8421631
    TabOrder = 3
    Visible = False
    Height = 41
    Width = 634
  end
  object SQLFatura: TcxMemo
    Left = 230
    Top = 261
    Lines.Strings = (
      'UNION ALL'
      ''
      'SELECT'
      
        #9'SIRANO= F.ID,FATURATARIH as KAYITTARIH, FATURATARIH as AKSIYONT' +
        'ARIH,   F.TUR,'
      
        'FATURANO as BELGENO, REHBERID,CARIKOD=R.KOD,CARIAD=R.FIRMA, F.AC' +
        'IKLAMA,'
      #9'HESAPID  = case when YERI=3 then abs(REHBERID) else null end,'
      
        #9'HESAPKODU= case when YERI=3 then (select KASAKODU from KASALAR ' +
        'where ID=abs(F.REHBERID)) else null end,'
      
        #9'HESAPADI = case when YERI=3 then (select KASAADI  from KASALAR ' +
        'where ID=abs(F.REHBERID)) else null end,'
      
        #9'BORC=case when F.TUR in (15,16,17,110) then FATURA_TUTARI else ' +
        '0.0 end,'
      
        #9'ALACAK=case when F.TUR in (8, 11,12,13) then FATURA_TUTARI else' +
        ' 0.0 end,'
      #9'DOVIZ_TUTARI,KASA=0,ONAY=NULL,'
      #9'F.EKLEYEN ,'#9'MASRAFKOD = MG.KOD,'#9'MASRAFAD=MG.AD,'
      #9'F.KUR,GERIDONUSID=NULL, DURUM=null,'
      #9'FATURAID=F.ID, CEKSENETID=NULL,KREDIID=null'
      ',YERI=CASE WHEN KASATAKIPID IS NOT NULL THEN 401 ELSE NULL END ,'
      'YERID= F.KASATAKIPID,F.OZELKOD,F.SUBEID'
      'FROM'
      #9'FATBASLIK F (NOLOCK)'
      #9'left outer join REHBER R on R.ID = F.REHBERID'
      #9'left outer join MASRAFGELIR MG on MG.ID=F.MASRAFID')
    Properties.WordWrap = False
    Style.Color = 8454143
    TabOrder = 4
    Visible = False
    Height = 48
    Width = 634
  end
  object SQLCek: TcxMemo
    Left = 230
    Top = 277
    Lines.Strings = (
      '--'#231'ek'
      'union all'
      'SELECT '
      #9'CH.ID,CH.TARIH as KAYITTARIH,AKSIYONTARIH=C.VADE,'
      
        #9'TUR=case when CH.ISLEM between 130 and 139 and CEKSENET=101 the' +
        'n 23 '
      #9'when CH.ISLEM between 140 and 149 and CEKSENET=103 then 33 '
      #9'when CH.ISLEM between 130 and 139 and CEKSENET=121 then 24 '
      #9'when CH.ISLEM between 140 and 149 and CEKSENET=321 then 34 '
      #9'else 0 end,'
      
        #9'BELGENO=cast(CH.BELGENO as nvarchar(20)),CH.REHBERID,CARIKOD=R.' +
        'KOD,CARIAD= R.FIRMA, '
      #9'ACIKLAMA=G.ANAHTAR+'#39' '#39'+isnull(CH.ACIKLAMA,'#39#39'),'
      
        #9'HESAPID=null,HESAPKODU=C.KOD,HESAPADI=(select HESAPADI from HES' +
        'APPLANI where HESAPKODU=C.KOD),'
      
        #9'BORC = case when CH.ISLEM in(131,132,133,134,135,136,137,138,14' +
        '0) then  C.TUTAR else 0    end,'
      
        #9'ALACAK = case when CH.ISLEM in(130,141) then C.TUTAR else 0  en' +
        'd,'
      #9'DOVIZ_TUTARI=0,KASA=0,ONAY=NULL, '
      #9'C.EKLEYEN ,MASRAFKOD = M.KOD,'#9'MASRAFAD=M.AD,'
      #9'C.KUR,GERIDONUSID=NULL, DURUM=null,FATURAID, '
      
        #9'CEKSENETID=C.ID,KREDIID=null ,YERI=NULL, YERID=NULL,C.OZELKOD,C' +
        '.SUBEID'
      'FROM '
      #9'CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID'
      
        #9'inner join GENINI G on G.BOLUM=-1005 and G.DIL=-1 and G.DEGER=C' +
        'H.ISLEM'
      #9'left outer join REHBER R on R.ID=CH.REHBERID'
      #9'left outer JOIN BANKAHESAPLAR BH ON BH.ID = CH.BANKAHESAPLARID'
      #9'left outer join MASRAFGELIR M on M.ID=C.MASRAFID'
      '')
    Properties.WordWrap = False
    Style.Color = 12962164
    TabOrder = 5
    Visible = False
    Height = 50
    Width = 634
  end
  object SQLSenet: TcxMemo
    Left = 237
    Top = 302
    Lines.Strings = (
      '---senet'
      'UNION ALL'
      'SELECT '
      #9' C.ID,C.TARIH as KAYITTARIH,C.VADE as AKSIYONTARIH,   C.TUR, '#9
      #9'MAKBUZNO as BELGENO,REHBERID, CARIKOD=R.KOD, CARIAD=R.FIRMA, '
      #9'C.ACIKLAMA,'
      #9'HESAPID=null,HESAPKODU=C.KOD,HESAPADI=null,'
      #9'BORC = case when C.TUR=34 then  C.TUTAR else 0    end,'
      #9'ALACAK = case when C.TUR=24 then  C.TUTAR else 0    end,'
      #9'DOVIZ_TUTARI=0,KASA=0,ONAY=NULL, '
      #9'C.EKLEYEN, MASRAFKOD = MG.KOD,'#9'MASRAFAD=MG.AD,'
      #9'C.KUR,GERIDONUSID=NULL, DURUM=null,FATURAID, '
      #9'CEKSENETID=NULL,KREDIID=null '
      ',YERI=NULL, YERID=NULL,C.OZELKOD,C.SUBEID'
      'FROM '
      #9'SENETLER C'
      #9'inner join REHBER R on R.ID=C.REHBERID'
      #9'left outer join MASRAFGELIR MG on MG.ID=C.MASRAFID')
    Properties.WordWrap = False
    Style.Color = 16744703
    TabOrder = 6
    Visible = False
    Height = 50
    Width = 634
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 287
    Width = 930
    Height = 8
    HotZoneClassName = 'TcxMediaPlayer8Style'
    AlignSplitter = salBottom
    Control = PanelToplam
    ExplicitWidth = 8
  end
  object DtsKasa: TDataSource
    DataSet = KASA
    Left = 169
    Top = 278
  end
  object KASA: TFDQuery
    AfterOpen = KASAAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT TOP 1 K.*, OZELKOD='#39#39' FROM KASA K')
    Left = 114
    Top = 279
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OnPopup = PopupMenu1Popup
    Left = 23
    Top = 156
    object EkleMenu: TMenuItem
      Caption = 'Ekle'
      ImageIndex = 0
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
    object N5: TMenuItem
      Caption = '-'
    end
    object TahsilMenu2: TMenuItem
      Caption = 'Tahsil Et'
      ImageIndex = 34
      object Nakit3: TMenuItem
        Tag = 21
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object HavaleEFT3: TMenuItem
        Tag = 22
        Caption = 'Havale/EFT'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object POS1: TMenuItem
        Tag = 25
        Caption = 'POS'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object CekTahsilMenu: TMenuItem
        Tag = 101
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object Senet3: TMenuItem
        Tag = 121
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object Iadeceki2: TMenuItem
        Tag = 29
        Caption = #304'ade '#199'eki'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object Hediyeceki1: TMenuItem
        Tag = 28
        Caption = 'Hediye '#199'eki'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object Kupon1: TMenuItem
        Tag = 26
        Caption = 'Kupon'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
    end
    object OdemeMenu2: TMenuItem
      Caption = #214'deme yap'
      ImageIndex = 34
      object NakitOdemeMenu2: TMenuItem
        Tag = 31
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object HavaleEFTOdemeMenu2: TMenuItem
        Tag = 32
        Caption = 'Havale/EFT'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object MenuItem72: TMenuItem
        Tag = 35
        Caption = 'Kredi Kart'#305
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object CekOdemeMenu2: TMenuItem
        Tag = 103
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object SenetOdemeMenu2: TMenuItem
        Tag = 321
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object IadeCekiOdemeMenu2: TMenuItem
        Tag = 39
        Caption = #304'ade '#199'eki'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object HediyeCeki2: TMenuItem
        Tag = 38
        Caption = 'Hediye '#199'eki'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
      object Kupon2: TMenuItem
        Tag = 36
        Caption = 'Kupon'
        ImageIndex = 34
        OnClick = NakitOdemeMenu2Click
      end
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object EkstreMenu: TMenuItem
      Caption = 'Ekstre'
      ImageIndex = 15
    end
    object Varlklar1: TMenuItem
      Caption = 'Varl'#305'klar'
      ImageIndex = 15
      OnClick = VarliklarTusClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Kopyala1: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = Kopyala1Click
    end
  end
  object DtsToplam: TDataSource
    AutoEdit = False
    DataSet = TabToplam
    Left = 164
    Top = 387
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <>
    StorageName = 'cxPropertiesStore1'
    StorageType = stRegistry
    Left = 267
    Top = 300
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 261
    Top = 355
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11776947
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
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
    Left = 26
    Top = 104
  end
  object TabToplam: TFDQuery
    AfterOpen = TabToplamAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE '
      '@TARIH0 DATETIME,'
      '@TARIH1 DATETIME'
      ''
      '--SET @TARIH0 = '#39'2012-06-01 00:00'#39
      '--SET @TARIH1 = '#39'2012-06-20 23:59'#39
      'SET @TARIH0 = :PTarih0'
      'SET @TARIH1 = :PTarih1'
      ''
      '--POS'
      'SELECT --select * from POS'
      #9'ID,'
      #9'KODU as HESAPKODU,'
      #9'ADI as HESAPADI, '
      
        #9'DEVIR=ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from ' +
        'KASA K2 (NOLOCK) where P1.ID=K2.HESAPID AND year(ISLEMTARIHI)=ye' +
        'ar(@TARIH1) and ISLEMTARIHI < @TARIH0 and K2.TUR not between 60 ' +
        'and 79 and K2.HESAPTURU='#39'P'#39' ),0.00),'
      
        #9'BORC=ISNULL((select SUM(ISNULL(ALACAK,0)) from KASA K2 (NOLOCK)' +
        ' where  P1.ID=K2.HESAPID  and ISLEMTARIHI between @TARIH0 and @T' +
        'ARIH1 and K2.TUR not between 60 and 79 and K2.HESAPTURU='#39'P'#39' ) , ' +
        '0.00), '
      
        #9'ALACAK=ISNULL((select SUM(ISNULL(BORC,0)) from KASA K2 (NOLOCK)' +
        ' where P1.ID=K2.HESAPID and ISLEMTARIHI between @TARIH0 and @TAR' +
        'IH1 and K2.TUR not between 60 and 79 and K2.HESAPTURU='#39'P'#39' ) , 0.' +
        '00), '
      
        #9'KALAN=ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from ' +
        'KASA K2 (NOLOCK) where P1.ID=K2.HESAPID AND year(ISLEMTARIHI)=ye' +
        'ar(@TARIH1) and ISLEMTARIHI <= @TARIH1 and K2.TUR not between 60' +
        ' and 79 and K2.HESAPTURU='#39'P'#39' ),0.00), '
      #9'--B'#220'T'#220'N KALAN - BUG'#220'N VE SONRASI'
      #9'KUR  '
      'FROM POS P1 (NOLOCK)   '
      'GROUP BY ID,KODU,ADI,KUR '
      
        'HAVING ISNULL((select SUM(ISNULL(BORC,0)-ISNULL(ALACAK,0)) from ' +
        'KASA K2 (NOLOCK) where P1.ID=K2.HESAPID AND year(ISLEMTARIHI)=ye' +
        'ar(@TARIH1) and ISLEMTARIHI < @TARIH0),0)+(select SUM(ISNULL(BOR' +
        'C,0)-ISNULL(ALACAK,0)) from KASA K2 (NOLOCK) where P1.ID=K2.HESA' +
        'PID and year(ISLEMTARIHI)=year(@TARIH1) and ISLEMTARIHI < @TARIH' +
        '1)<>0'
      'union all'
      '--KASA'
      'SELECT '
      #9'ID,'
      #9'KASAKODU as HESAPKODU,'
      #9'KASAADI as HESAPADI, '
      
        #9'DEVIR=ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from ' +
        'KASA K2 (NOLOCK) where K1.ID=K2.HESAPID AND year(ISLEMTARIHI)=ye' +
        'ar(@TARIH1) and ISLEMTARIHI < @TARIH0 and K2.TUR not between 60 ' +
        'and 79 and K2.HESAPTURU='#39'K'#39' ),0.00),'
      
        #9'BORC=ISNULL((select SUM(ISNULL(ALACAK,0)) from KASA K2 (NOLOCK)' +
        ' where  K1.ID=K2.HESAPID  and ISLEMTARIHI between @TARIH0 and @T' +
        'ARIH1 and K2.TUR not between 60 and 79 and K2.HESAPTURU='#39'K'#39' ) , ' +
        '0.00), '
      
        #9'ALACAK=ISNULL((select SUM(ISNULL(BORC,0)) from KASA K2 (NOLOCK)' +
        ' where K1.ID=K2.HESAPID and ISLEMTARIHI between @TARIH0 and @TAR' +
        'IH1 and K2.TUR not between 60 and 79 and K2.HESAPTURU='#39'K'#39' ) , 0.' +
        '00), '
      
        #9'KALAN=ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from ' +
        'KASA K2 (NOLOCK) where K1.ID=K2.HESAPID AND year(ISLEMTARIHI)=ye' +
        'ar(@TARIH1) and ISLEMTARIHI <= @TARIH1 and K2.TUR not between 60' +
        ' and 79 and K2.HESAPTURU='#39'K'#39' ),0.00), '
      #9'--B'#220'T'#220'N KALAN - BUG'#220'N VE SONRASI'
      #9'KUR  '
      'FROM KASALAR K1 (NOLOCK)  '
      'WHERE GUNLUKAKSIYONDAGOSTER=1 '
      'GROUP BY ID,KASAKODU,KASAADI,KUR '
      
        'HAVING ISNULL((select SUM(ISNULL(BORC,0)-ISNULL(ALACAK,0)) from ' +
        'KASA K2 (NOLOCK) where K2.TUR not between 60 and 79 and K1.ID=K2' +
        '.HESAPID AND year(ISLEMTARIHI)=year(@TARIH1) and ISLEMTARIHI < @' +
        'TARIH0),0)+(select SUM(ISNULL(BORC,0)-ISNULL(ALACAK,0)) from KAS' +
        'A K2 (NOLOCK) where K1.ID=K2.HESAPID and year(ISLEMTARIHI)=year(' +
        '@TARIH1) and ISLEMTARIHI < @TARIH1)<>0'
      ''
      '--BANKA  '
      '  union all '
      'select * from ('
      'SELECT '
      #9'ID,'
      #9'HESAPKODU,'
      #9'HESAPADI, '
      
        #9'DEVIR=ISNULL((select isnull(SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)' +
        '),0) from KASA K2 (NOLOCK) '
      
        #9'              where K1.ID=K2.HESAPID AND year(ISLEMTARIHI)=year' +
        '(@TARIH1) and ISLEMTARIHI < @TARIH0 and K2.TUR not between 60 an' +
        'd 79 and K2.HESAPTURU='#39'B'#39' ),0.00),'
      
        #9'BORC=ISNULL((select ISNULL(SUM(isnull(ALACAK,0)),0) from KASA K' +
        '2 (NOLOCK) '
      
        #9'              where  K1.ID=K2.HESAPID and ISLEMTARIHI between @' +
        'TARIH0 and @TARIH1 and  K2.TUR not between 60 and 79 and K2.HESA' +
        'PTURU='#39'B'#39' ) , 0.00), '
      
        #9'ALACAK=ISNULL((select ISNULL(SUM(isnull(BORC,0)),0) from KASA K' +
        '2 (NOLOCK) '
      
        #9'              where K1.ID=K2.HESAPID and ISLEMTARIHI between @T' +
        'ARIH0 and @TARIH1 and  K2.TUR not between 60 and 79 and K2.HESAP' +
        'TURU='#39'B'#39' ) , 0.00), '
      
        #9'KALAN=ISNULL((select isnull(SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)' +
        '),0) from KASA K2 (NOLOCK) '
      
        #9'              where K1.ID=K2.HESAPID and year(ISLEMTARIHI)=year' +
        '(@TARIH1) and ISLEMTARIHI <= @TARIH1 and K2.TUR not between 60 a' +
        'nd 79 and K2.HESAPTURU='#39'B'#39' ),0.00), '
      #9'KUR   '
      'FROM BANKAHESAPLAR K1 (NOLOCK)  '
      'WHERE GUNLUKAKSIYONDAGOSTER=1  '
      'GROUP BY ID, HESAPKODU,HESAPADI,KUR '
      ')as x'
      'where DEVIR<>0 or BORC<>0 or ALACAK<>0'
      '--ALINAN '#199'EKLER'
      '  union all '
      'SELECT top 1'
      #9'H.ID, '
      #9'H.HESAPKODU,'
      #9'H.HESAPADI, '
      
        #9'DEVIR=(select ISNULL(SUM(C2.TUTAR),0) from CEKLER C2 (NOLOCK) w' +
        'here DURUM not in (3,12) and  TUR=130  and isnull(CIROLU,0)<>1 A' +
        'ND C2.KUR=C.KUR AND C2.KOD=H.HESAPKODU  and C2.TARIH < @TARIH0)'
      
        #9'       - (select ISNULL(SUM(K.ALACAK),0) from KASA K (NOLOCK) w' +
        'here K.ISLEMTARIHI < @TARIH0 and TUR=51),     '
      
        #9'BORC= (select ISNULL(SUM(C2.TUTAR),0) from CEKLER C2 (NOLOCK) w' +
        'here DURUM not in (3,12) and TUR=130 and isnull(CIROLU,0)<>1 AND' +
        ' C2.TARIH between @TARIH0 and @TARIH1 ),     '
      
        #9'ALACAK=(select ISNULL(SUM(K.ALACAK),0) from KASA K (NOLOCK) whe' +
        're K.ISLEMTARIHI between @TARIH0 and @TARIH1 and TUR=51), '
      
        #9'KALAN=(select ISNULL(SUM(C2.TUTAR),0) from CEKLER C2 (NOLOCK) w' +
        'here DURUM not in (3,12) and  TUR=130 and isnull(CIROLU,0)<>1 AN' +
        'D C2.KUR=C.KUR AND C2.KOD=H.HESAPKODU  and C2.TARIH < @TARIH1)'
      
        #9'       - (select ISNULL(SUM(K.ALACAK),0) from KASA K (NOLOCK) w' +
        'here K.ISLEMTARIHI < @TARIH1 and TUR=51),'
      #9'C.KUR  '
      'FROM CEKLER C'
      
        '     INNER JOIN HESAPPLANI H ON SubString(C.KOD,1,Case when  cha' +
        'rindex('#39'.'#39',C.KOD) > 0 then charindex('#39'.'#39',C.KOD) -1 else 5 end)=H' +
        '.HESAPKODU '
      'WHERE  C.TUR = 130 '
      'GROUP BY H.ID, HESAPKODU,HESAPADI,C.KUR,C.KOD, C.TUTAR'
      ''
      '--VER'#304'LEN '#199'EKLER'
      '  union all '
      'SELECT  top 1'
      #9'H.ID, '
      #9'H.HESAPKODU,'
      
        '               HESAPADI=(case when ((C.DURUM=1 and C.TUR=33) or ' +
        '(C.DURUM=4 and C.TUR=130 and C.CIROLU=1)) then (Select HESAPADI ' +
        'from HESAPPLANI Where HESAPKODU = '#39'103'#39') end ), '
      
        #9'DEVIR=(select ISNULL(SUM(C2.TUTAR),0) from CEKLER C2 (NOLOCK) w' +
        'here (DURUM=1 and TUR=33) or (DURUM=4 and TUR=130 and CIROLU=1) ' +
        'AND C2.KUR=C.KUR AND C2.KOD=H.HESAPKODU  and C2.TARIH < @TARIH0)'
      
        #9'       - (select ISNULL(SUM(K.BORC),0) from KASA K (NOLOCK) whe' +
        're K.ISLEMTARIHI < @TARIH0 and TUR=53),     '
      
        #9'BORC= (select ISNULL(SUM(K.BORC),0) from KASA K (NOLOCK) where ' +
        'K.ISLEMTARIHI between @TARIH0 and @TARIH1 and TUR=53),'
      
        #9'ALACAK= (select ISNULL(SUM(C2.TUTAR),0) from CEKLER C2 (NOLOCK)' +
        ' where  (DURUM=1 and TUR=33) or (DURUM=4 and TUR=130 and CIROLU=' +
        '1) AND C2.TARIH between @TARIH0 and @TARIH1 ),     '
      
        #9'KALAN=(select ISNULL(SUM(C2.TUTAR),0) from CEKLER C2 (NOLOCK) w' +
        'here (DURUM=1 and TUR=33) or (DURUM=4 and TUR=130 and CIROLU=1) ' +
        'AND C2.KUR=C.KUR AND C2.KOD=H.HESAPKODU  and C2.TARIH < @TARIH1)'
      
        #9'       - (select ISNULL(SUM(K.BORC),0) from KASA K (NOLOCK) whe' +
        're K.ISLEMTARIHI < @TARIH1 and TUR=53),'
      #9'C.KUR   '
      'FROM CEKLER C'
      
        '     INNER JOIN HESAPPLANI H ON SubString(C.KOD,1,Case when  cha' +
        'rindex('#39'.'#39',C.KOD) > 0 then charindex('#39'.'#39',C.KOD) -1 else 5 end)=H' +
        '.HESAPKODU '
      'WHERE   ( C.TUR=33) or (C.DURUM=4 and C.TUR=130 and C.CIROLU=1)'
      
        'GROUP BY H.ID, HESAPKODU,HESAPADI,C.KUR,C.KOD, C.TUTAR,C.DURUM,C' +
        '.TUR,C.CIROLU'
      '--SENETLER '
      '  union all '
      'SELECT '
      #9'H.ID,'
      #9'H.HESAPKODU,'
      #9'HESAPADI=H.HESAPADI, '
      
        #9'DEVIR=ISNULL((select SUM(ISNULL(C2.TUTAR,0)) from SENETLER C2 (' +
        'NOLOCK) where TUR=24 AND C2.KUR=C1.KUR AND C2.KOD=H.HESAPKODU AN' +
        'D C2.TARIH < @TARIH0),0.00)-ISNULL((select SUM(ISNULL(C2.TUTAR,0' +
        ')) from SENETLER C2 (NOLOCK) where TUR=34 AND C2.KUR=C1.KUR AND ' +
        'C2.KOD=H.HESAPKODU AND year(TARIH)=year(@TARIH1) and C2.TARIH < ' +
        '@TARIH0),0.00),'
      
        #9'BORC=ISNULL((select SUM(ISNULL(C2.TUTAR,0)) from SENETLER C2 (N' +
        'OLOCK) where TUR=24 AND C2.KUR=C1.KUR AND C2.KOD=H.HESAPKODU and' +
        ' C2.TARIH between @TARIH0 and @TARIH1) , 0.00), '
      
        #9'ALACAK=ISNULL((select SUM(ISNULL(C2.TUTAR,0)) from SENETLER C2 ' +
        '(NOLOCK) where TUR=34 AND C2.KUR=C1.KUR AND C2.KOD=H.HESAPKODU a' +
        'nd C2.TARIH between @TARIH0 and @TARIH1) , 0.00), '
      
        #9'KALAN=ISNULL((select SUM(ISNULL(C2.TUTAR,0)) from SENETLER C2 (' +
        'NOLOCK) where TUR=24 AND C2.KUR=C1.KUR AND C2.KOD=H.HESAPKODU an' +
        'd C2.TARIH <= @TARIH1),0.00)-ISNULL((select SUM(ISNULL(C2.TUTAR,' +
        '0)) from SENETLER C2 (NOLOCK) where TUR=34 AND C2.KUR=C1.KUR AND' +
        ' C2.KOD=H.HESAPKODU and year(TARIH)=year(@TARIH1) and C2.TARIH <' +
        '= @TARIH1),0.00), '
      #9'C1.KUR   '
      
        'FROM SENETLER C1 (NOLOCK) INNER JOIN HESAPPLANI H ON C1.KOD=H.HE' +
        'SAPKODU '
      'WHERE C1.DURUM=1  '
      'GROUP BY H.ID, HESAPKODU,HESAPADI,C1.KUR,C1.KOD '
      'ORDER BY 2')
    Left = 101
    Top = 388
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
  end
  object PopupMenuYeni: TPopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    Left = 379
    Top = 74
    object GelenBelge1: TMenuItem
      Caption = 'Al'#305#351' Belgesi'
      ImageIndex = 19
      object Fatura1: TMenuItem
        Tag = 11
        Caption = 'Fatura'
        ImageIndex = 19
        OnClick = Fatura1Click
      end
      object Fi1: TMenuItem
        Tag = 12
        Caption = 'Fi'#351
        ImageIndex = 19
        OnClick = Fatura1Click
      end
      object rsaliye1: TMenuItem
        Tag = 10
        Caption = #304'rsaliye'
        ImageIndex = 19
        OnClick = Fatura1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object AlacakTahakkuku: TMenuItem
        Tag = 13
        Caption = 'Alacak Tahakkuku'
        ImageIndex = 19
        OnClick = Fatura1Click
      end
    end
    object Satbelgesi1: TMenuItem
      Caption = 'Sat'#305#351' belgesi'
      ImageIndex = 19
      object Fatura2: TMenuItem
        Tag = 15
        Caption = 'Fatura'
        ImageIndex = 19
        OnClick = Fatura1Click
      end
      object Fi2: TMenuItem
        Tag = 16
        Caption = 'Fi'#351
        ImageIndex = 19
        OnClick = Fatura1Click
      end
      object rsaliye2: TMenuItem
        Tag = 14
        Caption = #304'rsaliye'
        ImageIndex = 19
        OnClick = Fatura1Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object BorTahakkuku1: TMenuItem
        Tag = 17
        Caption = 'Bor'#231' Tahakkuku'
        ImageIndex = 19
        OnClick = Fatura1Click
      end
    end
    object MenuItem4: TMenuItem
      Caption = '-'
    end
    object ahsilat1: TMenuItem
      Caption = 'Cari Tahsilat'
      ImageIndex = 35
      object Nakit1: TMenuItem
        Tag = 21
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object HavaleEFT1: TMenuItem
        Tag = 22
        Caption = 'Havale / EFT'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object ek1: TMenuItem
        Tag = 25
        Caption = 'POS'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object CekOde2: TMenuItem
        Tag = 101
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object Senet1: TMenuItem
        Tag = 121
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
    end
    object mnOdeme: TMenuItem
      Caption = 'Cari '#214'deme'
      ImageIndex = 35
      object Nakit2: TMenuItem
        Tag = 31
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object HavaleEFT2: TMenuItem
        Tag = 32
        Caption = 'Havale / EFT'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object KrediKart1: TMenuItem
        Tag = 35
        Caption = 'Kredi Kart'#305
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object CekOde: TMenuItem
        Tag = 103
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object Senet2: TMenuItem
        Tag = 321
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
      object adeeki1: TMenuItem
        Tag = 39
        Caption = #304'ade '#199'eki'
        ImageIndex = 34
        OnClick = Fatura1Click
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Masrafdeme1: TMenuItem
      Caption = 'Masraf '#214'deme'
      ImageIndex = 34
      object MasrafNakitMenu: TMenuItem
        Tag = 31
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = MasrafNakitMenuClick
      end
      object MasrafHavaleEFTMenu: TMenuItem
        Tag = 32
        Caption = 'Havale / EFT'
        ImageIndex = 34
        OnClick = MasrafNakitMenuClick
      end
      object MasrafKrediKartiMenu: TMenuItem
        Tag = 35
        Caption = 'Kredi Kart'#305
        ImageIndex = 34
        OnClick = MasrafNakitMenuClick
      end
    end
    object GelirTahsilat1: TMenuItem
      Caption = 'Gelir Tahsilat'
      ImageIndex = 34
      object Nakit4: TMenuItem
        Tag = 21
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = MasrafNakitMenuClick
      end
      object HavaleEFT4: TMenuItem
        Tag = 22
        Caption = 'Havale / EFT'
        ImageIndex = 34
        OnClick = MasrafNakitMenuClick
      end
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object GelirPlan1: TMenuItem
      Tag = 61
      Caption = 'Tahsilat Plan'#305
      ImageIndex = 34
      OnClick = Fatura1Click
    end
    object demePlan1: TMenuItem
      Tag = 71
      Caption = #214'deme Plan'#305
      ImageIndex = 34
      OnClick = Fatura1Click
    end
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 471
    Top = 37
    object BaskiOnizlemeMenu: TMenuItem
      Caption = 'Bask'#305' '#214'nizleme'
      ImageIndex = 0
      OnClick = BaskiOnizlemeMenuClick
    end
    object YazcyaYazdr1: TMenuItem
      Tag = 1
      Caption = 'Yaz'#305'c'#305'ya Yazd'#305'r'
      ImageIndex = 1
      OnClick = BaskiOnizlemeMenuClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object Gnder1: TMenuItem
      Caption = 'G'#246'nder'
      ImageIndex = 15
      object PDF1: TMenuItem
        Tag = 2
        Caption = 'PDF'
        ImageIndex = 2
        OnClick = BaskiOnizlemeMenuClick
      end
      object Word1: TMenuItem
        Tag = 3
        Caption = 'Word'
        ImageIndex = 3
        OnClick = BaskiOnizlemeMenuClick
      end
      object Excel2: TMenuItem
        Tag = 4
        Caption = 'Excel'
        ImageIndex = 4
        OnClick = BaskiOnizlemeMenuClick
      end
      object CSV1: TMenuItem
        Tag = 5
        Caption = 'CSV'
        ImageIndex = 5
        OnClick = BaskiOnizlemeMenuClick
      end
      object ext1: TMenuItem
        Tag = 6
        Caption = 'Text'
        ImageIndex = 6
        OnClick = BaskiOnizlemeMenuClick
      end
      object HTML2: TMenuItem
        Tag = 7
        Caption = 'HTML'
        ImageIndex = 7
        OnClick = BaskiOnizlemeMenuClick
      end
      object JPG1: TMenuItem
        Tag = 8
        Caption = 'JPG'
        ImageIndex = 8
        OnClick = BaskiOnizlemeMenuClick
      end
      object MenuItem2: TMenuItem
        Caption = '-'
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
      end
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
  end
  object frxKasa: TfrxDBDataset
    UserName = 'KASA'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 634
    Top = 21
  end
end
