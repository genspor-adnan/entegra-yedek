object HesapPlaniDlg: THesapPlaniDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Hesap Plan'#305
  ClientHeight = 603
  ClientWidth = 1139
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 48
    Top = 16
    Width = 65
    Height = 65
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 1139
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 0
    Transparent = True
    Visible = False
    object KaydetTus: TToolButton
      Left = 0
      Top = 0
      Caption = 'Kaydet'
      ImageIndex = 10
      Style = tbsTextButton
      OnClick = KaydetTusClick
    end
    object IptalTus: TToolButton
      Left = 69
      Top = 0
      Caption = #304'ptal'
      ImageIndex = 17
      Style = tbsTextButton
      OnClick = IptalTusClick
    end
    object ToolButton1: TToolButton
      AlignWithMargins = True
      Left = 138
      Top = 0
      Width = 487
      AllowAllUp = True
      Caption = 'ToolButton1'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object btnKapat: TToolButton
      Left = 625
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object cxDBTreeList1: TcxDBTreeList
    Left = 0
    Top = 64
    Width = 1139
    Height = 532
    Align = alClient
    Bands = <
      item
        Caption.Text = 'Hesap Plan'#305
      end>
    DataController.DataSource = DtsPlan
    DataController.ParentField = 'ROOTKOD'
    DataController.KeyField = 'HESAPKODU'
    DefaultRowHeight = 19
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Orientation = 1
    Font.Style = []
    LookAndFeel.SkinName = 'LondonLiquidSky'
    Navigator.Buttons.CustomButtons = <>
    OptionsBehavior.IncSearch = True
    OptionsBehavior.IncSearchItem = cxDBTreeList1cxDBTreeListColumn2
    OptionsData.CancelOnExit = False
    OptionsData.Inserting = True
    OptionsData.CheckHasChildren = False
    OptionsData.SmartRefresh = True
    OptionsSelection.HideFocusRect = False
    OptionsSelection.InvertSelect = False
    ParentFont = False
    PopupMenu = PopupMenu1
    RootValue = 0
    TabOrder = 2
    ExplicitTop = 61
    ExplicitHeight = 535
    object cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn
      PropertiesClassName = 'TcxTextEditProperties'
      Caption.Text = 'Hesap Kodu'
      DataBinding.FieldName = 'HESAPKODU'
      Width = 124
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn
      Caption.Text = 'Hesap Ad'#305
      DataBinding.FieldName = 'HESAPADI'
      Width = 163
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn
      Caption.Text = 'A'#231#305'klama'
      DataBinding.FieldName = 'ACIKLAMA'
      Width = 232
      Position.ColIndex = 2
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn8: TcxDBTreeListColumn
      Caption.Text = 'P.Birimi'
      DataBinding.FieldName = 'KUR'
      Width = 45
      Position.ColIndex = 6
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn7: TcxDBTreeListColumn
      Caption.Text = 'Durum'
      DataBinding.FieldName = 'DURUM'
      Width = 47
      Position.ColIndex = 4
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn5: TcxDBTreeListColumn
      PropertiesClassName = 'TcxSpinEditProperties'
      Properties.MaxValue = 10.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Caption.Text = 'Digit'
      DataBinding.FieldName = 'DIGITSAY'
      Width = 69
      Position.ColIndex = 5
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn3: TcxDBTreeListColumn
      PropertiesClassName = 'TcxImageComboBoxProperties'
      Properties.Items = <
        item
          Value = 0
        end
        item
          Description = 'CRM'
          Value = 10
        end
        item
          Description = 'Kasa'
          Value = 100
        end
        item
          Description = 'Al'#305'nan '#199'ekler'
          Value = 101
        end
        item
          Description = 'Banka'
          Value = 102
        end
        item
          Description = 'Verilen '#199'ekler'
          Value = 103
        end
        item
          Description = 'POS'
          Value = 108
        end
        item
          Description = 'Cari Al'#305'c'#305'lar'
          Value = 120
        end
        item
          Description = 'Al'#305'nan Senetler'
          Value = 121
        end
        item
          Description = 'Stoklar'
          ImageIndex = 0
          Value = 150
        end
        item
          Description = 'Demirba'#351
          Value = 253
        end
        item
          Description = 'Kredi Kart'#305
          Value = 300
        end
        item
          Description = 'Cari Sat'#305'c'#305'lar'
          Value = 320
        end
        item
          Description = 'Di'#287'er Cariler'
          Value = 950
        end
        item
          Description = 'Verilen Senetler'
          Value = 321
        end
        item
          Description = 'Ortaklar'
          Value = 331
        end
        item
          Description = 'Personel'
          Value = 335
        end
        item
          Description = 'Kredi'
          Value = 400
        end
        item
          Description = 'Gelirler'
          Value = 600
        end
        item
          Description = 'Masraflar'
          Value = 700
        end
        item
          Description = 'Fiyat Fark'#305' Gelir'
          Value = 574
        end
        item
          Description = 'Fiyat Fark'#305' Gider'
          Value = 575
        end>
      Caption.Text = 'Varsay'#305'lan'
      DataBinding.FieldName = 'VARSAYILAN'
      Width = 82
      Position.ColIndex = 3
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object cxDBTreeList1cxDBTreeListColumn6: TcxDBTreeListColumn
      Caption.Text = 'Muh'
      DataBinding.FieldName = 'MUHASEBE'
      Width = 100
      Position.ColIndex = 7
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object MemoHesapPlani: TMemo
    Left = 8
    Top = 289
    Width = 320
    Height = 33
    Lines.Strings = (
      'Select'
      
        'ROOTKOD=REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX('#39'.'#39',REVE' +
        'RSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX('#39'.'#39',REVERSE(HESAPK' +
        'ODU),1)-1))),'
      
        ' HESAPKODU,HESAPADI,KUR,ACIKLAMA,GIRIS,DIGITSAY=ISNULL(DIGITSAY,' +
        '0),DURUM'
      'from HESAPPLANI'
      'where HESAPKODU LIKE '#39'%'#39)
    TabOrder = 13
    Visible = False
    WordWrap = False
  end
  object MemoBankalar: TMemo
    Left = 8
    Top = 99
    Width = 320
    Height = 33
    Lines.Strings = (
      'union all'
      'select '
      
        'ROOTKOD=REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX('#39'.'#39',REVE' +
        'RSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX('#39'.'#39',REVERSE(HESAPK' +
        'ODU),1)-1))),'
      
        'HESAPKODU,HESAPADI,KUR,ACIKLAMA=HESAPACIKLAMA,GIRIS=0,DIGITSAY=0' +
        ',DURUM'
      'from BANKAHESAPLAR where REHBERID = -1')
    TabOrder = 4
    Visible = False
    WordWrap = False
  end
  object MemoKasalar: TMemo
    Left = 8
    Top = 137
    Width = 320
    Height = 32
    Lines.Strings = (
      'union all'
      'select '
      
        'ROOTKOD=REVERSE( SUBSTRING(REVERSE(KASAKODU),CHARINDEX('#39'.'#39',REVER' +
        'SE(KASAKODU),1)+1,LEN(KASAKODU)-(CHARINDEX('#39'.'#39',REVERSE(KASAKODU)' +
        ',1)-1))),'
      
        'HESAPKODU=KASAKODU,HESAPADI=KASAADI,KUR,ACIKLAMA=HESAPACIKLAMA,G' +
        'IRIS=0,DIGITSAY=0,DURUM'
      'from KASALAR'
      'where KASAKODU LIKE '#39'%'#39)
    TabOrder = 6
    Visible = False
    WordWrap = False
  end
  object MemoCari: TMemo
    Left = 8
    Top = 175
    Width = 320
    Height = 32
    Lines.Strings = (
      'union all'
      'select '
      
        'ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX('#39'.'#39',REVERSE(KO' +
        'D),1)+1,LEN(KOD)-(CHARINDEX('#39'.'#39',REVERSE(KOD),1)-1))),'
      
        'HESAPKODU=KOD,HESAPADI=FIRMA,KUR='#39#39',ACIKLAMA=FIRMA,GIRIS=0,DIGIT' +
        'SAY=0,DURUM'
      'from REHBER '
      'WHERE KOD LIKE '#39'%'#39)
    TabOrder = 7
    Visible = False
    WordWrap = False
  end
  object MemoGelir: TMemo
    Left = 8
    Top = 213
    Width = 320
    Height = 32
    Lines.Strings = (
      'union all'
      'select '
      
        'ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX('#39'.'#39',REVERSE(KO' +
        'D),1)+1,LEN(KOD)-(CHARINDEX('#39'.'#39',REVERSE(KOD),1)-1))),'
      
        'HESAPKODU=KOD,HESAPADI=AD,KUR='#39#39',ACIKLAMA,GIRIS=0,DIGITSAY=0,DUR' +
        'UM'
      'from MASRAFGELIR'
      'WHERE TUR = '#39'True'#39)
    TabOrder = 9
    Visible = False
    WordWrap = False
  end
  object MemoMasraf: TMemo
    Left = 8
    Top = 251
    Width = 320
    Height = 32
    Lines.Strings = (
      'union all'
      'select '
      
        'ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX('#39'.'#39',REVERSE(KO' +
        'D),1)+1,LEN(KOD)-(CHARINDEX('#39'.'#39',REVERSE(KOD),1)-1))),'
      
        'HESAPKODU=KOD,HESAPADI=AD,KUR='#39#39',ACIKLAMA,GIRIS=0,DIGITSAY=0,DUR' +
        'UM'
      'from MASRAFGELIR'
      'WHERE TUR = '#39'False'#39)
    TabOrder = 11
    Visible = False
    WordWrap = False
  end
  object ToolBar2: TToolBar
    Left = 0
    Top = 32
    Width = 1139
    Margins.Bottom = 0
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 63
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
    Images = Tablo.PNGImageList1
    List = True
    ParentColor = False
    ParentFont = False
    ShowCaptions = True
    TabOrder = 1
    Transparent = True
    object ToolButton2: TToolButton
      Left = 0
      Top = 0
      Caption = 'Yeni'
      ImageIndex = 7
      OnClick = EkleTusClick
    end
    object PlanSil: TToolButton
      Left = 63
      Top = 0
      Caption = 'Sil'
      ImageIndex = 8
      OnClick = PlanSilClick
    end
    object ToolButton6: TToolButton
      AlignWithMargins = True
      Left = 126
      Top = 0
      Width = 505
      AllowAllUp = True
      Caption = 'ToolButton1'
      ImageIndex = 19
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 631
      Top = 0
      Caption = 'Kapat'
      ImageIndex = 18
      Style = tbsTextButton
      OnClick = btnKapatClick
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 0
    Top = 596
    Width = 1139
    Height = 7
    AlignSplitter = salBottom
  end
  object MemoSQLBas: TMemo
    Left = 142
    Top = 93
    Width = 553
    Height = 38
    Lines.Strings = (
      
        'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'#FI' +
        'S_SPID_%'#39')'
      'DROP TABLE #FIS_SPID_'
      ''
      'CREATE TABLE #FIS_SPID_('
      #9'[ID] [int] IDENTITY(1,1) NOT NULL,'
      #9'[KID] [int]NULL,'
      #9'[REHBERID] [int]NULL,'
      #9'[KOD] [nvarchar](20) NULL,'
      #9'[AD] [nvarchar](200) NULL,'
      #9'[TARIH] [smalldatetime] NULL,'
      #9'[TUR] [SMALLINT],'#9
      #9'[ACIKLAMA] [nvarchar](100) NULL,'
      #9'[BORC] [money] NULL,'
      #9'[ALACAK] [money] NULL,'
      #9'[KUR] [nvarchar](5) NULL,'
      #9'[ORJTARIH] [smalldatetime] NULL,'
      #9'[ORJTUR] [SMALLINT],'#9
      #9'[ORJACIKLAMA] [nvarchar](100) NULL,'#9
      #9'[ORJBORC] [money] NULL,'
      #9'[ORJALACAK] [money] NULL,'
      #9'[ORJKUR] [nvarchar](5) NULL,'
      #9'[ISLEM] [nvarchar](10) NULL,'
      #9'[HESAPID] [int]NULL,'
      #9'[HESAPTURU] [nvarchar](1) NULL'
      ')'
      'INSERT INTO #FIS_SPID_')
    TabOrder = 3
    Visible = False
  end
  object MemoSQL320: TMemo
    Left = 142
    Top = 136
    Width = 553
    Height = 38
    Lines.Strings = (
      'select * from('
      'select  '
      
        '  KID=isnull(K.ID,-1) ,REHBERID=R.ID,R.KOD,AD=R.FIRMA,TARIH=isnu' +
        'll(ISLEMTARIHI,'#39'2010-01-01 00:00'#39'),'
      '  isnull(K.TUR,-1) as TUR,isnull(K.ACIKLAMA,'#39#39') as ACIKLAMA,'
      
        '  BORC=isnull(BORC,0), ALACAK=isnull(ALACAK,0), isnull(K.KUR,'#39#39')' +
        ' as KUR,'
      '  isnull(ISLEMTARIHI, '#39'2010-01-01 00:00'#39') as ORJTARIH,'
      '  isnull(K.TUR,-1) as ORJTUR, ORJACIKLAMA=isnull(K.ACIKLAMA,'#39#39'),'
      
        '  ORJBORC=isnull(BORC,0), ORJALACAK=isnull(ALACAK,0),isnull(K.KU' +
        'R,'#39#39') as ORJKUR, ISLEM='#39#39', HESAPID=-1, '
      'HESAPTURU='#39#39
      'from REHBER R'
      'left outer join KASA K  on R.ID = K.REHBERID'
      #9')as ttt'
      #9'where TARIH >= '#39'2010-01-01 00:00'#39' '
      #9'and TARIH <= '#39'2010-12-31 23:59'#39
      #9'and TUR between -1 and 2'
      #9'and KOD like :P1'
      'ORDER BY 4 desc'
      ' ')
    TabOrder = 5
    Visible = False
  end
  object MemoSQL100: TMemo
    Left = 138
    Top = 180
    Width = 553
    Height = 38
    Lines.Strings = (
      'select    '
      '  KID=K.ID,REHBERID=-99, KOD=KH.KASAKODU, AD=KH.KASAADI,'
      '  TARIH=ISLEMTARIHI,K.TUR, K.ACIKLAMA,'
      
        '  BORC=isnull(ALACAK,0), ALACAK=isnull(BORC,0), isnull(K.KUR,'#39#39')' +
        ' as KUR,'
      '  ORJTARIH=ISLEMTARIHI,ORJTUR=K.TUR,ORJACIKLAMA=K.ACIKLAMA,'
      
        'ORJBORC=isnull(ALACAK,0),ORJALACAK=isnull(BORC,0),ORJKUR=isnull(' +
        'K.KUR,'#39#39'),'
      '  ISLEM='#39#39', HESAPID=KH.ID, HESAPTURU='#39'K'#39
      'from KASALAR KH inner join KASA K  on KH.ID = K.HESAPID '
      'where K.HESAPTURU='#39'K'#39' and TUR between -1 and 2'
      'and  ISLEMTARIHI between '#39'2010-01-01'#39' and '#39'2010-12-31 23:59'#39' '
      'and KASAKODU like :P1'
      'union all'
      'select    '
      '  KID=-1,REHBERID=-99, KOD=KH.KASAKODU, AD=KH.KASAADI,'
      
        '  TARIH='#39'2010-01-01 00:00'#39' ,TUR=-1, ACIKLAMA='#39#39',BORC=0, ALACAK=0' +
        ', KUR='#39#39','
      
        '  ORJTARIH='#39'2010-01-01 00:00'#39' ,ORJTUR=-1,ORJACIKLAMA='#39#39',ORJBORC=' +
        '0,ORJALACAK=0,ORJKUR='#39#39','
      '  ISLEM='#39#39', HESAPID=KH.ID, HESAPTURU='#39'K'#39
      'from KASALAR KH '
      
        'where KH.ID not in (select HESAPID from KASA K where K.HESAPID=K' +
        'H.ID'
      'and K.HESAPTURU='#39'K'#39' and TUR between 1 and 2'
      'and  ISLEMTARIHI between '#39'2010-01-01'#39' and '#39'2010-12-31 23:59'#39'   )'
      'and KASAKODU like :P2'
      'order by 3')
    TabOrder = 8
    Visible = False
  end
  object MemoSQL102: TMemo
    Left = 138
    Top = 223
    Width = 553
    Height = 38
    Lines.Strings = (
      'select    '
      '  KID=K.ID,REHBERID=-99, KOD=BH.HESAPKODU, AD=BH.HESAPADI,'
      '  TARIH=ISLEMTARIHI,K.TUR, K.ACIKLAMA,'
      
        '  BORC=isnull(ALACAK,0), ALACAK=isnull(BORC,0), isnull(K.KUR,'#39#39')' +
        ' as KUR,'
      
        '  ORJTARIH=ISLEMTARIHI,ORJTUR=K.TUR,ORJACIKLAMA=K.ACIKLAMA,ORJBO' +
        'RC=isnull'
      '(ALACAK,0),ORJALACAK=isnull(BORC,0),ORJKUR=isnull(K.KUR,'#39#39'),'
      '  ISLEM='#39#39',HESAPID=BH.ID, HESAPTURU='#39'B'#39
      'from BANKAHESAPLAR BH inner join KASA K  on BH.ID = K.HESAPID '
      
        'where BH.REHBERID=-1 and K.HESAPTURU='#39'B'#39' and TUR between -1 and ' +
        '2'
      'and  ISLEMTARIHI between '#39'2010-01-01'#39' and '#39'2010-12-31 23:59'#39' '
      'and HESAPKODU like :P1'
      'union all'
      'select    '
      '  KID=-1,REHBERID=-99, KOD=BH.HESAPKODU, AD=BH.HESAPADI,'
      
        '  TARIH='#39'2010-01-01 00:00'#39' ,TUR=-1, ACIKLAMA='#39#39',BORC=0, ALACAK=0' +
        ', KUR='#39#39','
      
        '  ORJTARIH='#39'2010-01-01 00:00'#39' ,ORJTUR=-1,ORJACIKLAMA='#39#39',ORJBORC=' +
        '0,ORJALACAK=0,ORJKUR='#39#39','
      '  ISLEM='#39#39',HESAPID=BH.ID, HESAPTURU='#39'B'#39
      'from BANKAHESAPLAR BH '
      
        'where BH.REHBERID=-1 and BH.ID not in (select HESAPID from KASA ' +
        'K where '
      ' K.HESAPID=BH.ID and '
      'K.HESAPTURU='#39'B'#39' and TUR between 1 and 2'
      'and  ISLEMTARIHI between '#39'2010-01-01'#39' and '#39'2010-12-31 23:59'#39'   )'
      'and HESAPKODU like :P2'
      'order by 3'
      ''
      ' ')
    TabOrder = 10
    Visible = False
  end
  object DtsPlan: TDataSource
    DataSet = TabPlan
    OnStateChange = DtsPlanStateChange
    Left = 549
    Top = 109
  end
  object TabPlan: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    BeforeEdit = TabPlanBeforeEdit
    BeforePost = TabPlanBeforePost
    AfterPost = TabPlanAfterPost
    OnNewRecord = TabPlanNewRecord
    ParamData = <>
    SQL.Strings = (
      'Select'
      
        'ROOTKOD=REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX('#39'.'#39',REVE' +
        'RSE(HESAPKODU),1)+1,'
      'LEN(HESAPKODU)-(CHARINDEX('#39'.'#39',REVERSE(HESAPKODU),1)-1))),'
      '*'
      'from HESAPPLANI'
      ''
      'where 1=1'
      ''
      'order by HESAPKODU')
    Left = 511
    Top = 137
  end
  object PopupMenu1: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupMenu1Popup
    Left = 581
    Top = 239
    object PasifleriGster1: TMenuItem
      Caption = 'G'#246'r'#252'n'#252'm'
      ImageIndex = 12
      object Pasifler1: TMenuItem
        Caption = 'Pasifler'
        ImageIndex = 15
        Checked = True
        OnClick = Pasifler1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Kasalar1: TMenuItem
        Caption = 'Kasalar'
        ImageIndex = 15
        OnClick = Kasalar1Click
      end
      object BankaHesaplar1: TMenuItem
        Caption = 'Banka Hesaplar'#305
        ImageIndex = 34
        OnClick = BankaHesaplar1Click
      end
      object Gelir1: TMenuItem
        Caption = 'Gelir M.'
        ImageIndex = 34
        OnClick = Gelir1Click
      end
      object Masraf1: TMenuItem
        Caption = 'Masraf M.'
        ImageIndex = 34
        OnClick = Masraf1Click
      end
      object CariKartlar1: TMenuItem
        Caption = 'Cari Kartlar'
        ImageIndex = 35
        OnClick = CariKartlar1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Hepsi1: TMenuItem
        Caption = 'Hepsi'
        ImageIndex = 15
        OnClick = Hepsi1Click
      end
      object SadecePlan1: TMenuItem
        Caption = 'Sadece Plan'
        ImageIndex = 21
        OnClick = SadecePlan1Click
      end
    end
    object VarlklarGster1: TMenuItem
      Caption = 'Olu'#351'tur'
      ImageIndex = 0
      object Ekle1: TMenuItem
        Caption = 'Yeni'
        ImageIndex = 0
        OnClick = EkleTusClick
      end
      object SeiliyiKopyala1: TMenuItem
        Caption = 'Se'#231'iliyi Kopyala'
        ImageIndex = 10
        Enabled = False
      end
    end
    object Sil1: TMenuItem
      Caption = 'Sil'
      ImageIndex = 1
      object SeiliyiSil1: TMenuItem
        Caption = 'Se'#231'iliyi Sil'
        ImageIndex = 1
      end
      object SeiliveTmAltKategorilerinisil1: TMenuItem
        Caption = 'Alt Kategorilerini sil'
        ImageIndex = 1
        Enabled = False
      end
    end
    object ResimGirMenu: TMenuItem
      Caption = 'Resim Gir'
      ImageIndex = 30
      OnClick = ResimGirMenuClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object ExceldenBilgiekle1: TMenuItem
      Caption = 'Excelden Bilgi Al '
      ImageIndex = 32
      OnClick = ExceldenBilgiekle1Click
    end
    object ExceleGnder1: TMenuItem
      Caption = 'Excele G'#246'nder'
      ImageIndex = 32
      OnClick = ExceleGnder1Click
    end
  end
  object TabKartlar: TFDQuery
    Connection = Tablo.FDCnn
    BeforeInsert = TabKartlarBeforeEdit
    BeforeEdit = TabKartlarBeforeEdit
    BeforePost = TabKartlarBeforeEdit
    BeforeDelete = TabKartlarBeforeEdit
    ParamData = <>
    Left = 510
    Top = 186
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 138
    Top = 76
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = 52479
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
    end
  end
end
