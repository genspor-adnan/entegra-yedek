object GunlukTakvimDlg: TGunlukTakvimDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'G'#252'nl'#252'k Varl'#305'klar ve Giderler Tablosu'
  ClientHeight = 493
  ClientWidth = 1087
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object ToolBar1: TToolBar
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1081
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
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
    ExplicitHeight = 29
    object DateTimePicker: TcxDateEdit
      Left = 0
      Top = 4
      Properties.SaveTime = False
      Properties.ShowTime = False
      Properties.OnChange = cxDateEdit1PropertiesChange
      TabOrder = 0
      Width = 121
    end
    object YaziciYaz: TToolButton
      Left = 121
      Top = 0
      Caption = 'Yazd'#305'r'
      DropdownMenu = PopupMenuYaz
      ImageIndex = 16
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 457
    Height = 458
    Align = alLeft
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 455
      Height = 41
      Align = alTop
      Color = 5878528
      ParentBackground = False
      TabOrder = 0
      object cxLabel2: TcxLabel
        Left = 107
        Top = 6
        Caption = 'Varl'#305'klar'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -21
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold, fsItalic]
        Style.TextColor = clWhite
        Style.IsFontAssigned = True
      end
    end
    object GridKasa: TcxGrid
      Left = 1
      Top = 42
      Width = 455
      Height = 415
      Align = alClient
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object KasaView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = KasaViewCanFocusRecord
        DataController.DataSource = DtsToplam
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
        DataController.Summary.DefaultGroupSummaryItems = <
          item
            Kind = skSum
            Position = spFooter
            FieldName = 'KALAN'
            Column = KasaViewKALAN
          end>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Column = KasaViewTLKALAN
          end>
        DataController.Summary.SummaryGroups = <>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsSelection.CellSelect = False
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        object KasaViewHESAPADI: TcxGridDBColumn
          Caption = 'Hesap'
          DataBinding.FieldName = 'HESAPADI'
          DataBinding.IsNullValueType = True
          Width = 120
        end
        object KasaViewKALAN: TcxGridDBColumn
          Caption = 'Doviz Tutar'
          DataBinding.FieldName = 'KALAN'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Width = 76
        end
        object KasaViewKUR: TcxGridDBColumn
          Caption = 'P. Birimi'
          DataBinding.FieldName = 'KUR'
          DataBinding.IsNullValueType = True
          Width = 49
        end
        object KasaViewTLKALAN: TcxGridDBColumn
          Caption = 'TL Tutar'
          DataBinding.FieldName = 'TLKALAN'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
        end
        object KasaViewTLKUR: TcxGridDBColumn
          Caption = 'P. Birimi'
          DataBinding.FieldName = 'TLKUR'
          DataBinding.IsNullValueType = True
          Width = 45
        end
      end
      object cxGridLevel1: TcxGridLevel
        GridView = KasaView
      end
    end
  end
  object Panel3: TPanel
    Left = 457
    Top = 35
    Width = 630
    Height = 458
    Align = alClient
    TabOrder = 2
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 628
      Height = 41
      Align = alTop
      Color = 5592575
      ParentBackground = False
      TabOrder = 0
      object cxLabel1: TcxLabel
        Left = 315
        Top = 5
        Caption = 'Giderler'
        ParentFont = False
        Style.Font.Charset = TURKISH_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -21
        Style.Font.Name = 'Trebuchet MS'
        Style.Font.Style = [fsBold, fsItalic]
        Style.TextColor = clWhite
        Style.IsFontAssigned = True
      end
    end
    object GridAkis: TcxGrid
      Left = 1
      Top = 42
      Width = 628
      Height = 415
      Align = alClient
      PopupMenu = PopupMenu1
      TabOrder = 1
      LookAndFeel.Kind = lfStandard
      LookAndFeel.NativeStyle = True
      object AkisView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        ScrollbarAnnotations.CustomAnnotations = <>
        OnCanFocusRecord = AkisViewCanFocusRecord
        DataController.DataSource = DtsAkis
        DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoGroupsAlwaysExpanded]
        DataController.Summary.DefaultGroupSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
            FieldName = 'ALACAK'
          end
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            Position = spFooter
            FieldName = 'ALACAK'
            Column = AkisViewCIKAN
          end>
        DataController.Summary.FooterSummaryItems = <
          item
            Format = ',0.00;-,0.00'
            Kind = skSum
            FieldName = 'ALACAK'
            Column = AkisViewCIKAN
          end>
        DataController.Summary.SummaryGroups = <
          item
            Links = <>
            SummaryItems = <
              item
                Column = AkisViewCIKAN
              end
              item
              end>
          end
          item
            Links = <>
            SummaryItems = <>
          end>
        OptionsCustomize.ColumnsQuickCustomization = True
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.Footer = True
        OptionsView.GroupByBox = False
        OptionsView.GroupFooters = gfAlwaysVisible
        object AkisViewID: TcxGridDBColumn
          DataBinding.FieldName = 'ID'
          DataBinding.IsNullValueType = True
          Visible = False
        end
        object AkisViewCariKod: TcxGridDBColumn
          Caption = 'Cari Kod'
          DataBinding.FieldName = 'KOD'
          DataBinding.IsNullValueType = True
          Width = 97
        end
        object AkisViewTARIH: TcxGridDBColumn
          Caption = 'Tarih'
          DataBinding.FieldName = 'TARIH'
          DataBinding.IsNullValueType = True
          Visible = False
          Width = 63
        end
        object AkisViewODEMEYERI: TcxGridDBColumn
          Caption = #214'deme Yeri'
          DataBinding.FieldName = 'ODEMEYERI'
          DataBinding.IsNullValueType = True
          Visible = False
          GroupIndex = 0
          Width = 140
        end
        object AkisViewGRUP: TcxGridDBColumn
          Caption = 'Grup'
          DataBinding.FieldName = 'GRUP'
          DataBinding.IsNullValueType = True
          Visible = False
          GroupIndex = 1
        end
        object AkisViewCARIAD: TcxGridDBColumn
          Caption = 'Cari Ad'
          DataBinding.FieldName = 'CARIAD'
          DataBinding.IsNullValueType = True
          Width = 168
        end
        object AkisViewCIKAN: TcxGridDBColumn
          Caption = 'Tutar'
          DataBinding.FieldName = 'ALACAK'
          DataBinding.IsNullValueType = True
          PropertiesClassName = 'TcxCurrencyEditProperties'
          Properties.DisplayFormat = ',0.00;-,0.00'
          Width = 77
        end
        object AkisViewKUR: TcxGridDBColumn
          Caption = 'Kur'
          DataBinding.FieldName = 'KUR'
          DataBinding.IsNullValueType = True
          Width = 29
        end
        object AkisViewACIKLAMA: TcxGridDBColumn
          Caption = 'A'#231#305'klama'
          DataBinding.FieldName = 'ACIKLAMA'
          DataBinding.IsNullValueType = True
          Width = 260
        end
        object AkisViewHESAP: TcxGridDBColumn
          Caption = 'Hesap'
          DataBinding.FieldName = 'HESAP'
          DataBinding.IsNullValueType = True
          Visible = False
          GroupIndex = 2
          Width = 182
        end
      end
      object cxGridLevel2: TcxGridLevel
        GridView = AkisView
      end
    end
  end
  object DtsToplam: TDataSource
    AutoEdit = False
    DataSet = Toplam
    Left = 95
    Top = 224
  end
  object Toplam: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE '
      '@TARIHYIL DATETIME,'
      '@TARIH1 DATETIME'
      ''
      '--SET @TARIHYIL = '#39'2011-01-01 00:00'#39
      '--SET @TARIH1 = '#39'2011-02-22 23:59'#39
      'SET @TARIHYIL = :PTarihYil'
      'SET @TARIH1 = :PTarih1'
      ''
      ''
      '--select * from KASA'
      'SELECT '
      #9'ID,'
      #9'KASAKODU as HESAPKODU,--and TUR in (1,2)'
      #9'KASAADI as HESAPADI, '
      
        #9'KALAN=ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from ' +
        'KASA K2 (NOLOCK) '
      
        #9'              where K2.HESAPTURU='#39'K'#39' and K1.ID=K2.HESAPID AND I' +
        'SLEMTARIHI>=@TARIHYIL and ISLEMTARIHI <= @TARIH1),0.00),'
      #9'TLKALAN='
      #9'case When KUR='#39'TL'#39' then '
      
        #9'(ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from KASA ' +
        'K2 (NOLOCK) '
      
        #9'              where K2.HESAPTURU='#39'K'#39' and K1.ID=K2.HESAPID AND I' +
        'SLEMTARIHI>=@TARIHYIL and ISLEMTARIHI <= @TARIH1),0.00))'
      ' else'
      
        '('#9'ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from KASA ' +
        'K2 (NOLOCK) '
      
        #9'              where K2.HESAPTURU='#39'K'#39' and K1.ID=K2.HESAPID AND I' +
        'SLEMTARIHI>=@TARIHYIL and ISLEMTARIHI <= @TARIH1),0.00) )*('
      #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
      #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
      #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
      #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
      #9#9#9#9#9') '
      #9#9#9#9#9'end, '
      #9'KUR,TLKUR='#39'TL'#39'  '
      'FROM KASALAR K1 (NOLOCK)  '
      'WHERE GUNLUKAKSIYONDAGOSTER=1 '
      'GROUP BY ID,KASAKODU,KASAADI,KUR '
      
        'HAVING (select SUM(ISNULL(BORC,0)-ISNULL(ALACAK,0)) from KASA K2' +
        ' (NOLOCK) '
      
        '                 where K2.HESAPTURU='#39'K'#39' and K1.ID=K2.HESAPID and' +
        ' ISLEMTARIHI>=@TARIHYIL and ISLEMTARIHI < @TARIH1)<>0'
      ''
      '--BANKA  '
      '  union all '
      'select * from ('
      'SELECT '
      #9'ID,'
      #9'HESAPKODU,'
      #9'HESAPADI, '
      
        #9'KALAN=ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from ' +
        'KASA K2 (NOLOCK) '
      
        #9'              where K2.HESAPTURU='#39'B'#39' and K1.ID=K2.HESAPID AND I' +
        'SLEMTARIHI>=@TARIHYIL and ISLEMTARIHI <= @TARIH1),0.00),'
      #9'TLKALAN='
      ' case When KUR='#39'TL'#39' then '
      
        #9'(ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from KASA ' +
        'K2 (NOLOCK) '
      
        #9'              where K2.HESAPTURU='#39'B'#39' and K1.ID=K2.HESAPID AND I' +
        'SLEMTARIHI>=@TARIHYIL and ISLEMTARIHI <= @TARIH1),0.00))'
      ' else'
      
        '('#9'ISNULL((select SUM(ISNULL(ALACAK,0)-ISNULL(BORC,0)) from KASA ' +
        'K2 (NOLOCK) '
      
        #9'              where K2.HESAPTURU='#39'B'#39' and K1.ID=K2.HESAPID AND I' +
        'SLEMTARIHI>=@TARIHYIL and ISLEMTARIHI <= @TARIH1),0.00) )*('
      #9#9#9#9#9'Select SATIS from DOVIZ D Where  '
      #9#9#9#9#9#9#9'Year(D.TARIH) =YEAR(GETDATE()) and '
      #9#9#9#9#9#9#9'MONTH(D.TARIH)=MONTH(GETDATE()) and '
      #9#9#9#9#9'DAY(D.TARIH)=DAY(GETDATE()) and D.CINSI=KUR'
      #9#9#9#9#9') '
      #9#9#9#9#9'end,'
      #9'KUR ,TLKUR='#39'TL'#39'  '
      'FROM BANKAHESAPLAR K1 (NOLOCK)  '
      'WHERE GUNLUKAKSIYONDAGOSTER=1  '
      'GROUP BY ID, HESAPKODU,HESAPADI,KUR '
      ')as x'
      'where KALAN <>0.0'
      'order by 2')
    Left = 24
    Top = 224
  end
  object DtsAkis: TDataSource
    AutoEdit = False
    DataSet = TabAkis
    Left = 471
    Top = 137
  end
  object TabAkis: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      ''
      'declare '
      '@tarihbas datetime,'
      '@tarihbit datetime'
      '--set @tarihbas = '#39'2010-02-24 00:00'#39' '
      '--set @tarihbit = '#39'2012-02-24 23:59'#39
      'set @tarihbas = :PBas '
      'set @tarihbit = :PBit'
      ''
      'select '
      #9'K.ID,'
      #9'R.KOD,'
      #9'PLANTARIHI as TARIH,'
      #9'ODEMEYERI=case when isnull(HESAPTURU,'#39#39') = '#39'B'#39' then '#39'Banka'#39' '
      #9#9#9#9'   when isnull(HESAPTURU,'#39#39') = '#39'K'#39' then '#39'Kasa'#39' '
      #9#9#9#9'   Else '#39'Belirsiz'#39' end,'
      #9'TUR, '
      #9'GRUP=case when HESAPTURU = '#39'K'#39' then KUR '
      #9#9#9'  when HESAPTURU = '#39'B'#39' then '#39'Havale'#39' '
      #9#9#9'  else '#39'Belirsiz'#39' end,  '
      #9'BORC, '
      #9'ALACAK, '
      #9'KUR,'
      #9'CARIAD=FIRMA,'
      #9'isnull(ACIKLAMA,'#39#39') as ACIKLAMA, '
      '    HESAP=case '
      
        '         when HESAPTURU ='#39'B'#39' then isnull((select isnull(HESAPADI' +
        ','#39'Belirsiz Banka!'#39') from BANKAHESAPLAR BH where BH.ID=K.HESAPID)' +
        ','#39'Belirsiz Banka!'#39') '
      
        '         when HESAPTURU ='#39'K'#39' then isnull((select isnull(KASAADI,' +
        #39'Belirsiz Kasa!'#39') from KASALAR K2 where K2.ID=K.HESAPID),'#39'Belirs' +
        'iz Kasa!'#39')'
      
        '         when exists (select 1 from BANKAHESAPLAR BH2 where BH2.' +
        'ID= K.HESAPID) then '
      
        '         (select HESAPADI from BANKAHESAPLAR BH2 where BH2.ID= K' +
        '.HESAPID )'
      
        '         when exists (select 1 from KASALAR K3 where K3.ID=K.HES' +
        'APID) then '
      
        '         (select KASAADI from KASALAR K4 where K4.ID=K.HESAPID )' +
        '         '
      '         Else '#39'Belirsiz Kasa!'#39' end '
      
        ' from KASA K left outer join REHBER R on R.ID = K.REHBERID      ' +
        '                         '
      
        ' where  PLANTARIHI between @tarihbas and @tarihbit and  TUR in (' +
        '71,72)'
      ' '
      
        ' union all                                                      ' +
        ' '
      
        ' select C.ID,R.KOD, TARIH=VADE,ODEMEYERI='#39'Banka'#39',TUR, GRUP=  '#39#199'e' +
        'k'#39',  '
      ' BORC = 0 , ALACAK = TUTAR ,  '
      
        ' C.KUR,CARIAD=R.FIRMA,ACIKLAMA=CKR.KREDIADI+'#39' (Seri No:'#39'+convert' +
        '(varchar(20),C.SERINO,1)+'#39') '#39'+isnull(NOTLAR,'#39#39')'
      
        ' ,HESAP=isnull(convert(varchar(20),B.BANKAADI),'#39#39')+'#39' '#39'+isnull(C.' +
        'HESAPNO,'#39#39') '#9#9#9
      ' from CEKLER C inner join REHBER R on R.ID=C.REHBERID '
      
        ' left outer join CEKKOCAN CK on C.SERINO between CK.BASSERINO an' +
        'd CK.BITSERINO'
      ' left outer join CEKKREDI CKR on CK.KREDIID=CKR.ID '
      ' left outer join BANKAHESAPLAR BH on BH.ID=CKR.HESAPID '
      ' left outer join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID'
      ' left outer join BANKALAR B on B.BANKAKODU=BS.BANKAKODU'
      '  where TUR in (33,34) and '
      '  VADE between @tarihbas and @tarihbit  '
      ''
      
        ' union all                                                      ' +
        ' '
      
        ' select C.ID,R.KOD, TARIH=VADE,ODEMEYERI='#39'Banka'#39',TUR, GRUP=  '#39#199'e' +
        'k'#39',  '
      ' BORC = 0 , ALACAK = TUTAR ,  '
      ' KUR,CARIAD=R.FIRMA,ACIKLAMA=NOTLAR,HESAP=NULL   '
      ' from SENETLER C inner join REHBER R on R.ID=C.REHBERID '
      '  where TUR in (33,34) and '
      '  VADE between @tarihbas and @tarihbit  '
      ''
      ' union all  '
      
        ' select KO.ID,KOD=K.KREDIKODU,TARIH,ODEMEYERI='#39'Banka'#39',TUR=111, G' +
        'RUP='#39'Kredi'#39',BORC=0, ALACAK=KO.TAKSIT,isnull(BH.KUR,'#39'TL'#39'),CARIAD=' +
        'KREDIKODU,ACIKLAMA=K.ADI+'#39' '#39'+ACIKLAMA, '
      ' HESAP=BH.HESAPADI'
      ' from KREDILER K inner join PLANKREDI KO on K.ID=KO.KREDIID  '
      
        '      left outer join BANKAHESAPLAR BH on K.BANKATICARIHESAPID=B' +
        'H.ID'
      ' where TARIH between @tarihbas and @tarihbit '
      ' order by ODEMEYERI, GRUP, HESAP'
      ''
      '')
    Left = 431
    Top = 137
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    Left = 592
    Top = 177
    object BilgileriDegisMenu: TMenuItem
      Caption = 'Bilgilerini g'#246'r / de'#287'i'#351'tir'
      ImageIndex = 22
    end
    object FaturageldiMenu: TMenuItem
      Caption = 'Fatura geldi'
      ImageIndex = 19
      Visible = False
    end
    object TahsilMenu: TMenuItem
      Caption = #214'deme yap'
      ImageIndex = 34
      Visible = False
      object NakitOdemeMenu: TMenuItem
        Tag = 1
        Caption = 'Nakit'
        ImageIndex = 34
      end
      object HavaleEFTOdemeMenu: TMenuItem
        Tag = 2
        Caption = 'Havale/EFT'
        ImageIndex = 34
      end
      object CekOdemeMenu: TMenuItem
        Tag = 3
        Caption = #199'ek'
        ImageIndex = 34
      end
      object SenetOdemeMenu: TMenuItem
        Caption = 'Senet'
        ImageIndex = 34
      end
    end
    object TahsilatiptaletMenu: TMenuItem
      Caption = 'Tahsilat'#305' iptal et'
      ImageIndex = 3
      Visible = False
    end
    object IsaretleMenu: TMenuItem
      Caption = #304#351'aretle'
      ImageIndex = 15
      Visible = False
      object KarlYok1: TMenuItem
        Caption = 'Kar'#351#305'l'#305#287#305' yok'
        ImageIndex = 15
      end
      object ahsiledilemiyor1: TMenuItem
        Caption = 'Tahsil edilemiyor'
        ImageIndex = 34
      end
    end
    object N3: TMenuItem
      Caption = '-'
      Visible = False
    end
    object Butariheplanekle1: TMenuItem
      Caption = 'Bu tarihe plan ekle'
      ImageIndex = 21
      Visible = False
      object TahsilatPlanMenu: TMenuItem
        Tag = 61
        Caption = 'Tahsilat'
        ImageIndex = 34
      end
      object OdemePlanMenu: TMenuItem
        Tag = 71
        Caption = #214'deme'
        ImageIndex = 34
      end
    end
    object Butarihefaturaekle1: TMenuItem
      Caption = 'Bu tarihe fatura ekle'
      ImageIndex = 21
      Visible = False
      object GelenFaturaMenu: TMenuItem
        Caption = 'Gelen Fatura'
        ImageIndex = 19
      end
      object GidenFaturaMenu: TMenuItem
        Caption = 'Giden Fatura'
        ImageIndex = 19
      end
    end
    object N4: TMenuItem
      Caption = '-'
      Visible = False
    end
    object BuguneaksiyonekleMenu: TMenuItem
      Caption = 'Bu tarihe aksiyon ekle'
      ImageIndex = 21
      Visible = False
    end
    object N1: TMenuItem
      Caption = '-'
      Visible = False
    end
    object GnderilecekbankahesabnsecMenu: TMenuItem
      Caption = #304#351'aretlilerin banka hesab'#305'n'#305' se'#231'/de'#287'i'#351'tir'
      ImageIndex = 30
      OnClick = GnderilecekbankahesabnsecMenuClick
    end
  end
  object frxToplam: TfrxDBDataset
    UserName = 'Toplam'
    CloseDataSource = False
    DataSet = Toplam
    BCDToCurrency = False
    DataSetOptions = []
    Left = 28
    Top = 281
  end
  object frxAkis: TfrxDBDataset
    UserName = 'Akis'
    CloseDataSource = False
    DataSet = TabAkis
    BCDToCurrency = False
    DataSetOptions = []
    Left = 402
    Top = 183
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 325
    Top = 234
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
end
