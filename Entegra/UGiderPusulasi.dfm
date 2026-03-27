object GiderPusulasiDlg: TGiderPusulasiDlg
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Gider Pusulas'#305
  ClientHeight = 621
  ClientWidth = 1094
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1094
    Height = 621
    Align = alClient
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 0
    object PanelUp: TPanel
      Left = 2
      Top = 2
      Width = 1086
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 1086
        Height = 40
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 38
        ButtonWidth = 112
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
        Images = Tablo.cxImageList1
        List = True
        ParentColor = False
        ParentFont = False
        ShowCaptions = True
        TabOrder = 0
        Transparent = True
        object ToolButton7: TToolButton
          Left = 0
          Top = 0
          Width = 5
          Caption = 'ToolButton7'
          ImageIndex = 35
          Style = tbsSeparator
        end
        object cxLabel1: TcxLabel
          Left = 5
          Top = 9
          Caption = ' Tarih:'
          Transparent = True
        end
        object deTarih: TcxDateEdit
          Left = 41
          Top = 0
          AutoSize = False
          ParentFont = False
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -19
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          TabOrder = 0
          Height = 38
          Width = 126
        end
        object ToolButton3: TToolButton
          Left = 167
          Top = 0
          Width = 5
          Caption = 'ToolButton3'
          ImageIndex = 35
          Style = tbsSeparator
        end
        object LabelBelgeNo: TcxLabel
          Left = 172
          Top = 9
          Caption = 'Belge No:'
          Transparent = True
        end
        object EditAra: TcxTextEdit
          Left = 222
          Top = 0
          AutoSize = False
          ParentFont = False
          Style.Color = clInfoBk
          Style.Font.Charset = DEFAULT_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -19
          Style.Font.Name = 'Tahoma'
          Style.Font.Style = []
          Style.IsFontAssigned = True
          StyleDisabled.Color = clInfoBk
          TabOrder = 1
          Height = 38
          Width = 129
        end
        object ToolButton4: TToolButton
          Left = 351
          Top = 0
          Width = 5
          Caption = 'ToolButton4'
          ImageIndex = 35
          Style = tbsSeparator
        end
        object BtnAra: TToolButton
          Left = 356
          Top = 0
          Caption = '    Listele        '
          ImageIndex = 20
          OnClick = BtnAraClick
        end
        object ToolButton1: TToolButton
          Left = 468
          Top = 0
          Width = 236
          Caption = 'ToolButton1'
          ImageIndex = 35
          Style = tbsDivider
        end
        object YaziciYaz: TToolButton
          Left = 704
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 33
          Indeterminate = True
        end
        object ToolButton2: TToolButton
          Left = 816
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 34
          Style = tbsSeparator
        end
        object KapatTus: TButton
          Left = 824
          Top = 0
          Width = 42
          Height = 38
          Align = alRight
          Caption = 'X'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Trebuchet MS'
          Font.Style = [fsBold]
          ModalResult = 2
          ParentFont = False
          TabOrder = 2
          TabStop = False
          OnClick = KapatTusClick
        end
      end
    end
    object Panel2: TPanel
      Left = 2
      Top = 42
      Width = 1086
      Height = 347
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object cxGridFisler: TcxGrid
        Left = 0
        Top = 0
        Width = 1086
        Height = 172
        Align = alTop
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TabStop = False
        object tvFisler: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DtsFisler
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          Styles.OnGetContentStyle = tvFislerStylesGetContentStyle
          object clmFatNo: TcxGridDBColumn
            Caption = 'Belge No'
            DataBinding.FieldName = 'FATURANO'
            Width = 100
          end
          object clmFatTarih: TcxGridDBColumn
            Caption = 'Tarih'
            DataBinding.FieldName = 'FATURATARIH'
          end
          object clmFatTutar: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'FATURA_TUTARI'
            PropertiesClassName = 'TcxCalcEditProperties'
            Properties.DisplayFormat = '###,###,##0.00'
            Styles.Content = cxStyle1
          end
          object clmBelgeTur: TcxGridDBColumn
            Caption = 'T'#252'r'
            DataBinding.FieldName = 'TUR'
            RepositoryItem = Tablo.RepKasaTurleri
          end
          object clmOdemeSekli: TcxGridDBColumn
            Caption = #214'deme '#350'ekli'
            DataBinding.FieldName = 'TAHSILATSEKLI'
            Width = 110
          end
          object clmSatici: TcxGridDBColumn
            Caption = 'Sat'#305'c'#305
            DataBinding.FieldName = 'SATICIKODU'
            RepositoryItem = Tablo.repGenelPersonelListesi
          end
          object clmFatBaslik: TcxGridDBColumn
            Caption = 'Ba'#351'l'#305'k'
            DataBinding.FieldName = 'BASLIK'
          end
          object clmKalanMiktar: TcxGridDBColumn
            DataBinding.FieldName = 'IADEADET'
            Visible = False
          end
          object clmSatisAdet: TcxGridDBColumn
            DataBinding.FieldName = 'SATISADET'
          end
        end
        object cxGridFislerLevel1: TcxGridLevel
          GridView = tvFisler
        end
      end
      object cxGridFisDetaylar: TcxGrid
        Left = 0
        Top = 179
        Width = 1086
        Height = 168
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        TabStop = False
        object tvFisDetaylar: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          OnCellClick = tvFisDetaylarCellClick
          DataController.DataSource = DtsFisDetay
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object clmFaturaUrunAdi: TcxGridDBColumn
            Caption = #220'r'#252'n Ad'#305
            DataBinding.FieldName = 'AD'
            Width = 170
          end
          object clmFaturaAdet: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
          end
          object clmFaturaBirimFiyat: TcxGridDBColumn
            Caption = 'Birim Fiyat'
            DataBinding.FieldName = 'BIRIMFIYAT'
            PropertiesClassName = 'TcxCalcEditProperties'
            Properties.DisplayFormat = '###,###,##0.00'
            Styles.Content = cxStyle1
            Width = 88
          end
          object clmFaturaIsk: TcxGridDBColumn
            Caption = #304'sk.%'
            DataBinding.FieldName = 'ISKONTO'
          end
          object clmFaturaTutar: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
            PropertiesClassName = 'TcxCalcEditProperties'
            Properties.DisplayFormat = '###,###,##0.00'
          end
          object clmFaturaIadeMiktar: TcxGridDBColumn
            Caption = #304'ade Edilmi'#351' Miktar'
            DataBinding.FieldName = 'IADEADET'
            Width = 160
          end
        end
        object cxGridLevel1: TcxGridLevel
          GridView = tvFisDetaylar
        end
      end
      object Memo1: TMemo
        Left = 78
        Top = 223
        Width = 537
        Height = 102
        Lines.Strings = (
          'BEGIN TRY'
          
            ' IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE' +
            ' '#39'##IADEFATURATEMP_SPID_%'#39')'
          'CREATE TABLE ##IADEFATURATEMP_SPID_ ('
          #9'ID int IDENTITY(1,1) NOT NULL,'
          #9'FATBASID int NOT NULL,'
          #9'REHBERID int NOT NULL,'
          #9'SEC nvarchar(1) NULL,'
          #9'TUR smallint NULL,'
          #9'URUNID int NULL,'
          #9'KOD nvarchar(15) NULL,'
          #9'ACIKLAMA nvarchar(100) NULL,'
          #9'ADET float NULL,'
          #9'BIRIM smallint NULL,'
          #9'MIKTAR float NULL,'
          #9'BIRIMFIYAT numeric(18, 6) NULL,'
          #9'TUTAR money NULL,'
          #9'ISKONTO float NULL,'
          #9'KDV smallint NULL,'
          #9'MASRAFID smallint NULL,'
          #9'OZELKOD nvarchar(10) NULL,'
          #9'MUHKODU nvarchar(10) NULL,'
          #9'KASA smallint NULL,'
          #9'ONAY nvarchar(1) NULL,'
          #9'EKLEYEN smallint NULL,'
          #9'EKLEMETARIHI smalldatetime NULL,'
          #9'DEGISTIREN smallint NULL,'
          #9'DEGISTIRMETARIHI smalldatetime NULL,'
          #9'KUR nvarchar(5) NULL,'
          #9'IZLEMEKODU nvarchar(15) NULL,'
          #9'AD nvarchar(150) NULL,'
          #9'DOVIZ_TUTARI money NULL,'
          #9'DOVIZ_KURU nvarchar(5) NULL,'
          #9'ISKONTO2 float NULL,'
          #9'IZLEME smallint NULL,'
          #9'IADEADET float NULL,'
          #9'IADEFATURAID int NULL,'
          ')'
          
            '  INSERT INTO ##IADEFATURATEMP_SPID_ (FATBASID, SEC, TUR, URUNID' +
            ', KOD, ACIKLAMA, ADET, BIRIM, '
          'MIKTAR, '
          'BIRIMFIYAT, TUTAR, ISKONTO,'
          
            '                               KDV, MASRAFID,  OZELKOD, MUHKODU,' +
            ' KASA, ONAY, EKLEYEN, EKLEMETARIHI, '
          'DEGISTIREN, DEGISTIRMETARIHI,'
          
            '                               KUR, IZLEMEKODU, AD, DOVIZ_TUTARI' +
            ', DOVIZ_KURU, ISKONTO2, IZLEME, IADEADET , '
          'IADEFATURAID'
          '                              )'
          '  SELECT '
          
            '  FATBASID, SEC, TUR, URUNID, KOD, ACIKLAMA, ADET, BIRIM, MIKTAR' +
            ', BIRIMFIYAT, TUTAR, ISKONTO,'
          
            '                               KDV, MASRAFID, OZELKOD, MUHKODU, ' +
            'KASA, ONAY, EKLEYEN, EKLEMETARIHI, '
          'DEGISTIREN, DEGISTIRMETARIHI,'
          
            '                               KUR, IZLEMEKODU, AD, DOVIZ_TUTARI' +
            ', DOVIZ_KURU, ISKONTO2, IZLEME, IADEADET, '
          'IADEFATURAID '
          '  FROM FATURA'
          '  WHERE FATBASID = -99 --:PFATBASID'
          ''
          'END TRY'
          ''
          ''
          'BEGIN CATCH'
          ''
          '  SELECT * FROM ##IADEFATURATEMP_SPID_   '
          ''
          'END CATCH'
          ' '
          '')
        TabOrder = 3
        Visible = False
      end
      object cxSplitter1: TcxSplitter
        Left = 0
        Top = 172
        Width = 1086
        Height = 7
        AlignSplitter = salTop
        Control = cxGridFisler
      end
    end
    object Panel3: TPanel
      Left = 2
      Top = 389
      Width = 1086
      Height = 226
      Align = alClient
      Caption = 'Panel2'
      TabOrder = 2
      object Panel4: TPanel
        Left = 1
        Top = 1
        Width = 1084
        Height = 45
        Align = alTop
        TabOrder = 0
        object SecilileriIadeAlTus: TJvNavPanelButton
          Left = 934
          Top = 1
          Width = 149
          Height = 43
          Align = alRight
          AllowAllUp = True
          Caption = 'Se'#231'ilileri '#304'ade Al'
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
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 29
          OnClick = SecilileriIadeAlTusClick
          ExplicitLeft = 849
          ExplicitTop = -4
        end
        object btnTumunuIadeAl: TJvNavPanelButton
          Left = 1
          Top = 1
          Width = 149
          Height = 43
          Align = alLeft
          AllowAllUp = True
          Caption = 'T'#252'm'#252'n'#252' '#304'ade Al'
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
          Colors.ButtonColorFrom = 15395562
          Colors.ButtonColorTo = 12566463
          Colors.ButtonHotColorFrom = 14256961
          Colors.ButtonHotColorTo = 11694645
          Colors.ButtonSelectedColorFrom = 14256961
          Colors.ButtonSelectedColorTo = 11694645
          ParentStyleManager = False
          ImageIndex = 28
          OnClick = btnTumunuIadeAlClick
          ExplicitLeft = 0
          ExplicitTop = 5
        end
      end
      object gridIadeListesi: TcxGrid
        Left = 1
        Top = 46
        Width = 1084
        Height = 179
        Align = alClient
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        TabStop = False
        object tvIadeListesi: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          OnCellClick = tvIadeListesiCellClick
          DataController.DataModeController.SmartRefresh = True
          DataController.DataSource = DtsIadeFisDetay
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsView.GroupByBox = False
          object clmIadeUrunAdi: TcxGridDBColumn
            Caption = #220'r'#252'n Ad'#305
            DataBinding.FieldName = 'AD'
            Width = 170
          end
          object clmIadeAdet: TcxGridDBColumn
            Caption = 'Adet'
            DataBinding.FieldName = 'ADET'
          end
          object clmIadeBirimFiyat: TcxGridDBColumn
            Caption = 'Birim Fiyat'
            DataBinding.FieldName = 'BIRIMFIYAT'
            Styles.Content = cxStyle1
            Width = 88
          end
          object clmIadeIsk: TcxGridDBColumn
            Caption = #304'sk.%'
            DataBinding.FieldName = 'ISKONTO'
          end
          object clmIadeTutar: TcxGridDBColumn
            Caption = 'Tutar'
            DataBinding.FieldName = 'TUTAR'
          end
        end
        object cxGridLevel2: TcxGridLevel
          GridView = tvIadeListesi
        end
      end
      object memoIadeFis: TMemo
        Left = 69
        Top = 128
        Width = 537
        Height = 45
        Lines.Strings = (
          'BEGIN TRY'
          
            ' IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE' +
            ' '#39'##IADETEMP_SPID_%'#39') '
          'CREATE TABLE ##IADETEMP_SPID_ ('
          #9'ID int IDENTITY(1,1) NOT NULL,'
          #9'FATBASID int NOT NULL,'
          #9'REHBERID int NOT NULL,'
          #9'SEC nvarchar(1) NULL,'
          #9'TUR smallint NULL,'
          #9'URUNID int NULL,'
          #9'KOD nvarchar(25) NULL,'
          #9'ACIKLAMA nvarchar(150) NULL,'
          #9'ADET float NULL,'
          #9'BIRIM smallint NULL,'
          #9'MIKTAR float NULL,'
          #9'BIRIMFIYAT numeric(18, 6) NULL,'
          #9'TUTAR money NULL,'
          #9'ISKONTO float NULL,'
          #9'KDV smallint NULL,'
          #9'MASRAFID smallint NULL,'
          #9'OZELKOD nvarchar(20) NULL,'
          #9'MUHKODU nvarchar(20) NULL,'
          #9'KASA smallint NULL,'
          #9'ONAY nvarchar(1) NULL,'
          #9'EKLEYEN smallint NULL,'
          #9'EKLEMETARIHI smalldatetime NULL,'
          #9'DEGISTIREN smallint NULL,'
          #9'DEGISTIRMETARIHI smalldatetime NULL,'
          #9'KUR nvarchar(5) NULL,'
          #9'IZLEMEKODU nvarchar(25) NULL,'
          #9'AD nvarchar(200) NULL,'
          #9'DOVIZ_TUTARI money NULL,'
          #9'DOVIZ_KURU nvarchar(5) NULL,'
          #9'ISKONTO2 float NULL,'
          #9'IZLEME smallint NULL,'
          #9'IADEADET float NULL,'
          #9'IADEFATURAID int NULL,'
          '                IADETEMPSATIRID int NULL'
          ')'
          ''
          '  SELECT * FROM ##IADETEMP_SPID_   '
          ''
          'END TRY'
          ''
          ''
          'BEGIN CATCH'
          '  TRUNCATE TABLE ##IADETEMP_SPID_'
          ''
          '  SELECT * FROM ##IADETEMP_SPID_   '
          ''
          'END CATCH'
          ' '
          '')
        TabOrder = 2
        Visible = False
      end
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 105
    Top = 96
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = TURKISH_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Trebuchet MS'
      Font.Style = []
    end
  end
  object tabFisler: TFDQuery
    Connection = Tablo.FDCnn
    BeforeOpen = tabFislerBeforeOpen
    AfterOpen = tabFislerAfterOpen
    AfterScroll = tabFislerAfterScroll
    ParamData = <>
    SQL.Strings = (
      
        'select FB.ID, FATURATARIH, FB.TUR, FB.CIKISDEPO,VD, VNO, KDVDURU' +
        'M, KDV_TUTARI, FATURA_TUTARI, FATURANO, BASLIK ,FB.SATICIKODU ,'
      
        'TAHSILATSEKLI = (SELECT top 1 TAH=(SELECT ANAHTAR FROM GENINI WH' +
        'ERE BOLUM=-1005 AND DIL=:PDIL AND DEGER=K.TUR)'
      #9#9#9#9#9#9#9#9#9#9' FROM KASA K WHERE K.FATURAID = FB.ID order by K.TUR),'
      'SATISADET = SUM(ADET),'
      'IADEADET = SUM(ISNULL(IADEADET,0))'#9#9'   '
      'from FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      ''
      'FATURATARIH BETWEEN :PBASTAR AND :PBITTAR'
      'AND FATURANO LIKE :PFATURANO'
      'AND FB.TUR IN (15,16)'
      
        'GROUP BY FB.ID,  FATURATARIH, FB.TUR, FB.CIKISDEPO,VD, VNO, KDVD' +
        'URUM, KDV_TUTARI, FATURA_TUTARI, FATURANO, BASLIK ,FB.SATICIKODU' +
        ' , FB.TARIH'
      'ORDER BY FATURATARIH DESC')
    Left = 225
    Top = 75
  end
  object DtsFisler: TDataSource
    DataSet = tabFisler
    Left = 225
    Top = 117
  end
  object DtsFisDetay: TDataSource
    DataSet = TabFisDetay
    Left = 361
    Top = 117
  end
  object TabFisDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'BEGIN TRY'
      ' TRUNCATE TABLE ##FaturaIadeTemp_SPID_'
      'END TRY'
      'BEGIN CATCH'
      '  '
      'END CATCH'
      ''
      'select MAXIADEMIKTAR = ADET-ISNULL(IADEADET,0), F.*,'
      'AD = CASE WHEN F.TUR = 1 THEN S.STOKADI ELSE M.AD END,'
      'KOD = CASE WHEN F.TUR = 1 THEN S.KOD ELSE M.KOD END'
      
        'INTO ##FaturaIadeTemp_SPID_  FROM FATURA F LEFT OUTER JOIN STOKL' +
        'AR S ON F.URUNID = S.ID '
      
        ' '#9#9'                                     LEFT OUTER JOIN MASRAFGE' +
        'LIR M ON F.URUNID = M.ID'
      ''
      'WHERE FATBASID = :PFATBASID'
      ''
      'ORDER BY ID DESC'
      ''
      'select * from ##FaturaIadeTemp_SPID_ '
      ''
      'drop table ##FaturaIadeTemp_SPID_ '
      ''
      '')
    Left = 361
    Top = 73
  end
  object DtsIadeFisDetay: TDataSource
    DataSet = tabIadeFisDetay
    Left = 288
    Top = 117
  end
  object tabIadeFisDetay: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'SELECT * FROM ##IADETEMP_SPID_'
      '--WHERE FATBASID = :PFATBASID')
    Left = 289
    Top = 74
  end
  object FATBASLIK: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    OnNewRecord = FATBASLIKNewRecord
    ParamData = <>
    SQL.Strings = (
      
        'SELECT *, YAZIYLATOPLAM=( dbo.fn_MoneyToText(FATURA_TUTARI,KUR,0' +
        '))'
      'FROM FATBASLIK WHERE ID = :Par')
    Left = 472
    Top = 73
  end
  object FATURA: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'Select * ,'
      
        'BIRIMAD=(select ANAHTAR from GENINI where DIL=:PDil and BOLUM=-2' +
        '702  and DEGER=convert(varchar(10),BIRIM)),'
      
        'AD =  CASE WHEN F.TUR =1 THEN (SELECT STOKADI FROM STOKLAR WHERE' +
        ' ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ID = F.' +
        'URUNID)  END,'
      
        'KOD =  CASE WHEN F.TUR =1 THEN (SELECT KOD FROM STOKLAR WHERE ID' +
        ' = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID= F.URU' +
        'NID )  END,'
      
        'BARKOD=(select top 1 BARKOD from STOKBARKOD SB where SB.STOKID=F' +
        '.URUNID and SB.VARSAYILAN=1)'
      'from FATURA F Where FATBASID = :Par order by ID')
    Left = 419
    Top = 73
    object FATURAID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object FATURAFATBASID: TIntegerField
      FieldName = 'FATBASID'
    end
    object FATURAREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object FATURASEC: TWideStringField
      FieldName = 'SEC'
      Size = 1
    end
    object FATURATUR: TSmallintField
      FieldName = 'TUR'
    end
    object FATURAURUNID: TIntegerField
      FieldName = 'URUNID'
    end
    object FATURAACIKLAMA: TWideMemoField
      FieldName = 'ACIKLAMA'
      BlobType = ftWideMemo
    end
    object FATURAADET: TFloatField
      FieldName = 'ADET'
    end
    object FATURAMF: TFloatField
      FieldName = 'MF'
    end
    object FATURABIRIM: TSmallintField
      FieldName = 'BIRIM'
    end
    object FATURAMIKTAR: TFloatField
      FieldName = 'MIKTAR'
    end
    object FATURABIRIMFIYAT: TFMTBCDField
      FieldName = 'BIRIMFIYAT'
      Precision = 18
    end
    object FATURATUTAR: TFMTBCDField
      FieldName = 'TUTAR'
      Precision = 18
    end
    object FATURAKUR: TWideStringField
      FieldName = 'KUR'
      Size = 5
    end
    object FATURAISKONTO: TFloatField
      FieldName = 'ISKONTO'
    end
    object FATURAKDV: TSmallintField
      FieldName = 'KDV'
    end
    object FATURAMASRAFID: TSmallintField
      FieldName = 'MASRAFID'
    end
    object FATURAIZLEMEKODU: TWideStringField
      FieldName = 'IZLEMEKODU'
      Size = 15
    end
    object FATURAOZELKOD: TWideStringField
      FieldName = 'OZELKOD'
      Size = 25
    end
    object FATURAMUHKODU: TWideStringField
      FieldName = 'MUHKODU'
      Size = 25
    end
    object FATURAKASA: TSmallintField
      FieldName = 'KASA'
    end
    object FATURAONAY: TWideStringField
      FieldName = 'ONAY'
      Size = 1
    end
    object FATURADOVIZ_TUTARI: TFMTBCDField
      FieldName = 'DOVIZ_TUTARI'
      Precision = 18
    end
    object FATURADOVIZ_KURU: TWideStringField
      FieldName = 'DOVIZ_KURU'
      Size = 5
    end
    object FATURAISKONTO2: TFloatField
      FieldName = 'ISKONTO2'
    end
    object FATURAIZLEME: TSmallintField
      FieldName = 'IZLEME'
    end
    object FATURAIADEADET: TFloatField
      FieldName = 'IADEADET'
    end
    object FATURAIADEFATURAID: TIntegerField
      FieldName = 'IADEFATURAID'
    end
    object FATURAYERI: TIntegerField
      FieldName = 'YERI'
    end
    object FATURAYERID: TIntegerField
      FieldName = 'YERID'
    end
    object FATURAEKLEYEN: TIntegerField
      FieldName = 'EKLEYEN'
    end
    object FATURAEKLEMETARIHI: TDateTimeField
      FieldName = 'EKLEMETARIHI'
    end
    object FATURADEGISTIREN: TIntegerField
      FieldName = 'DEGISTIREN'
    end
    object FATURADEGISTIRMETARIHI: TDateTimeField
      FieldName = 'DEGISTIRMETARIHI'
    end
    object FATURADOVIZ_BIRIMFIYAT: TFMTBCDField
      FieldName = 'DOVIZ_BIRIMFIYAT'
      Precision = 18
    end
    object FATURADOVIZKURDEGERI: TBCDField
      FieldName = 'DOVIZKURDEGERI'
      Precision = 19
    end
    object FATURAPROJEID: TIntegerField
      FieldName = 'PROJEID'
    end
    object FATURAKAMPANYAID: TIntegerField
      FieldName = 'KAMPANYAID'
    end
    object FATURAVADE: TWordField
      FieldName = 'VADE'
    end
    object FATURASTOKDURUMDEGIS: TBooleanField
      FieldName = 'STOKDURUMDEGIS'
    end
    object FATURASUBEID: TSmallintField
      FieldName = 'SUBEID'
    end
    object FATURAKDVMUHAFIYETI: TSmallintField
      FieldName = 'KDVMUHAFIYETI'
    end
    object FATURAEKMALIYET: TBCDField
      FieldName = 'EKMALIYET'
      Precision = 19
    end
    object FATURABIRIMAD: TWideStringField
      FieldName = 'BIRIMAD'
      ReadOnly = True
      Size = 100
    end
    object FATURAAD: TWideStringField
      FieldName = 'AD'
      ReadOnly = True
      Size = 200
    end
    object FATURAKOD: TWideStringField
      FieldName = 'KOD'
      ReadOnly = True
      Size = 50
    end
    object FATURABARKOD: TWideStringField
      FieldName = 'BARKOD'
      ReadOnly = True
      Size = 50
    end
  end
  object DtsFatura: TDataSource
    DataSet = FATURA
    Left = 417
    Top = 118
  end
  object frxFisler: TfrxDBDataset
    UserName = 'frxFisler'
    CloseDataSource = False
    DataSet = tabFisler
    BCDToCurrency = False
    Left = 224
    Top = 161
  end
  object PopupMenuYaz: TPopupMenu
    Left = 102
    Top = 140
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
    object N1: TMenuItem
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
      object N2: TMenuItem
        Caption = '-'
        OnClick = BaskiOnizlemeMenuClick
      end
      object EMail1: TMenuItem
        Tag = 9
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object frxFATBASLIK: TfrxDBDataset
    UserName = 'FATBASLIK'
    CloseDataSource = False
    DataSet = FATBASLIK
    BCDToCurrency = False
    Left = 426
    Top = 337
  end
  object frxFATURA: TfrxDBDataset
    UserName = 'FATURA'
    CloseDataSource = False
    DataSet = FATURA
    BCDToCurrency = False
    Left = 355
    Top = 338
  end
  object TOPLAMLAR: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'DECLARE @FATBASID INT'
      'SET @FATBASID = :PFATBASID'
      ''
      ''
      'SELECT '
      #39'Toplam'#39' AS ACIKLAMA, '
      
        'DEGER = CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN SUM((BIRIMFIYAT*ADET)*(' +
        '100.0/(100.0+KDV))) ELSE SUM(BIRIMFIYAT*ADET) END,'
      
        'DOVIZDEGER = (CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN SUM((BIRIMFIYAT*A' +
        'DET)*(100.0/(100.0+KDV))) ELSE SUM(BIRIMFIYAT*ADET) END)/FB.DOVI' +
        'ZKUR,'
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      #9'FB.ID = @FATBASID'
      'GROUP BY FB.KUR, KDVDURUM, FB.DOVIZ_CINSI,FB.DOVIZKUR'
      'UNION ALL'
      'SELECT'
      
        'ACIKLAMA = '#39#304'skonto(%'#39'+case when SUM(BIRIMFIYAT*ADET)= SUM(F.TUT' +
        'AR) then '#39'0'#39' '
      
        #9#9#9#9#9#9'else Convert(varchar(5),(round((SUM((BIRIMFIYAT*ADET)- F.T' +
        'UTAR)*100/(FATURA_MATRAHI+(SUM((BIRIMFIYAT*ADET)- F.TUTAR)))),0,' +
        '0))) end+'#39')'#39' ,'
      
        'DEGER = CASE WHEN KDVDURUM='#39'Dahil'#39' THEN  SUM( (BIRIMFIYAT*ADET)/' +
        '(1+(KDV/100.0)) *ISKONTO)/100.0 ELSE SUM(((BIRIMFIYAT*ADET)- TUT' +
        'AR)) END,'
      
        'DOVIZDEGER = (CASE WHEN KDVDURUM='#39'Dahil'#39' THEN  SUM( (BIRIMFIYAT*' +
        'ADET)/(1+(KDV/100.0)) *ISKONTO)/100.0 ELSE SUM(((BIRIMFIYAT*ADET' +
        ')- TUTAR)) END)/FB.DOVIZKUR,'
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      #9'FB.ID = @FATBASID  '
      
        'GROUP BY FB.KUR'#9',KDVDURUM, FB.DOVIZ_CINSI,FB.FATURA_TUTARI,FATUR' +
        'A_MATRAHI,FB.DOVIZKUR'
      
        'HAVING ( CASE WHEN KDVDURUM='#39'Dahil'#39' THEN  SUM( (BIRIMFIYAT*ADET)' +
        '/(1+(KDV/100.0)) *ISKONTO)/100.0 ELSE SUM(((BIRIMFIYAT*ADET)- TU' +
        'TAR)) END ) > 0.01'
      'UNION ALL'
      'SELECT'
      'ACIKLAMA = '#39'Ara Toplam'#39' ,'
      
        'DEGER = (CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN SUM((BIRIMFIYAT*ADET)*' +
        '(100.0/(100.0+KDV))) ELSE SUM(BIRIMFIYAT*ADET) END)'
      
        '-(CASE WHEN KDVDURUM='#39'Dahil'#39' THEN  SUM( (BIRIMFIYAT*ADET)/(1+(KD' +
        'V/100.0)) *ISKONTO)/100.0 ELSE SUM(((BIRIMFIYAT*ADET)- TUTAR)) E' +
        'ND),'
      
        'DOVIZDEGER = ((CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN SUM((BIRIMFIYAT*' +
        'ADET)*(100.0/(100.0+KDV))) ELSE SUM(BIRIMFIYAT*ADET) END)/FB.DOV' +
        'IZKUR)'
      
        '-((CASE WHEN KDVDURUM='#39'Dahil'#39' THEN  SUM( (BIRIMFIYAT*ADET)/(1+(K' +
        'DV/100.0)) *ISKONTO)/100.0 ELSE SUM(((BIRIMFIYAT*ADET)- TUTAR)) ' +
        'END)/FB.DOVIZKUR),'
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      #9'FB.ID = @FATBASID  '
      
        'GROUP BY FB.KUR'#9',KDVDURUM, FB.DOVIZ_CINSI,FB.FATURA_TUTARI,FATUR' +
        'A_MATRAHI,FB.DOVIZKUR'
      
        'HAVING ( CASE WHEN KDVDURUM='#39'Dahil'#39' THEN  SUM( (BIRIMFIYAT*ADET)' +
        '/(1+(KDV/100.0)) *ISKONTO)/100.0 ELSE SUM(((BIRIMFIYAT*ADET)- TU' +
        'TAR)) END ) > 0.01'
      ''
      'UNION ALL'
      ''
      'SELECT'
      'ACIKLAMA = '#39'KDV%'#39'+CONVERT(VARCHAR(5),KDV),'
      
        'DEGER = SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*(100.0' +
        '/(100.0+KDV))) ELSE (KDV*(TUTAR/100.0))  END),'
      
        'DOVIZDEGER = (SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*' +
        '(100.0/(100.0+KDV))) ELSE (KDV*(TUTAR/100.0))  END)/FB.DOVIZKUR)' +
        ','
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      #9'FB.ID = @FATBASID '
      
        'GROUP BY FB.KUR'#9',KDV , FB.KDVDURUM, FB.DOVIZ_CINSI,FB.DOVIZKUR,i' +
        'snull(KDVMUHAFIYETI,0)'
      
        '--HAVING SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*(100.' +
        '0/(100.0+KDV))) ELSE (KDV*(TUTAR/100.0))  END) > 0.0'
      'UNION ALL'
      ''
      'SELECT'
      
        'ACIKLAMA = CASE WHEN isnull(KDVMUHAFIYETI,0)=0 THEN '#39'KDV%'#39'+CONVE' +
        'RT(VARCHAR(5),KDV) ELSE '#39'KDV%'#39'+CONVERT(VARCHAR(5),KDV)+'#39' Beyan%'#39 +
        '+CONVERT(VARCHAR(5),100-isnull(KDVMUHAFIYETI,0)) end,'
      
        'DEGER = SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*(100.0' +
        '/(100.0+((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0))))) ELSE ((' +
        'KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))  END),'
      
        'DOVIZDEGER = (SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*' +
        '(100.0/(100.0+((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0))))) E' +
        'LSE ((KDV*(100-isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))  E' +
        'ND)/FB.DOVIZKUR),'
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      #9'FB.ID = @FATBASID and isnull(KDVMUHAFIYETI,0)>0'
      
        'GROUP BY FB.KUR'#9',KDV , FB.KDVDURUM, FB.DOVIZ_CINSI,FB.DOVIZKUR,i' +
        'snull(KDVMUHAFIYETI,0)'
      
        'HAVING SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*(100.0/' +
        '(100.0+((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0))))) ELSE ((K' +
        'DV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))  END) >' +
        ' 0.0'
      ''
      'UNION ALL'
      ''
      'SELECT'
      
        'ACIKLAMA = CASE WHEN isnull(KDVMUHAFIYETI,0)=0 THEN '#39'KDV%'#39'+CONVE' +
        'RT(VARCHAR(5),KDV) ELSE '#39'KDV%'#39'+CONVERT(VARCHAR(5),KDV)+'#39' Tevkifa' +
        't%'#39'+CONVERT(VARCHAR(5),isnull(KDVMUHAFIYETI,0)) end,'
      
        'DEGER = SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*(100.0' +
        '/(100.0+((KDV*(isnull(KDVMUHAFIYETI,0))/100.0))))) ELSE ((KDV*(i' +
        'snull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))  END),'
      
        'DOVIZDEGER = (SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*' +
        '(100.0/(100.0+((KDV*(isnull(KDVMUHAFIYETI,0))/100.0))))) ELSE ((' +
        'KDV*(isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))  END)/FB.DOV' +
        'IZKUR),'
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      #9'FB.ID = @FATBASID and isnull(KDVMUHAFIYETI,0)>0'
      
        'GROUP BY FB.KUR'#9',KDV , FB.KDVDURUM, FB.DOVIZ_CINSI,FB.DOVIZKUR,i' +
        'snull(KDVMUHAFIYETI,0)'
      
        'HAVING SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*(100.0/' +
        '(100.0+((KDV*(isnull(KDVMUHAFIYETI,0))/100.0))))) ELSE ((KDV*(is' +
        'null(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))  END) > 0.0'
      'UNION ALL'
      ''
      'SELECT'
      #39'Ek Vergi'#39' AS ACIKLAMA, '
      'DEGER = EKVERGI ,'
      'DOVIZDEGER = (EKVERGI/FB.DOVIZKUR),'
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB '
      'WHERE'
      #9'FB.ID = @FATBASID'
      #9'AND ISNULL(EKVERGI,0)>0'
      'UNION ALL'#9
      'SELECT '
      #39'Genel Toplam'#39' AS ACIKLAMA, '
      
        'DEGER = ISNULL(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN SUM(TUTAR) ELSE ' +
        'SUM(TUTAR*(1+((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0))/100.0' +
        ')) END,0.0)+ ISNULL(EKVERGI,0.0) ,'
      
        'DOVIZDEGER = ((ISNULL(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN SUM(TUTAR' +
        ') ELSE SUM(TUTAR*(1+((KDV*(100.0-isnull(KDVMUHAFIYETI,0)))/100.0' +
        ')/100.0)) END,0.0)+ ISNULL(EKVERGI,0.0))/FB.DOVIZKUR),'
      'FB.KUR,'
      'FB.DOVIZ_CINSI'
      'FROM '
      #9'FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID'
      'WHERE'
      #9'FB.ID = @FATBASID'
      ''
      
        'GROUP BY KDVDURUM, FB.KUR, FB.DOVIZ_CINSI, ISNULL(EKVERGI,0),FB.' +
        'DOVIZKUR'
      
        '--HAVING SUM(CASE WHEN KDVDURUM ='#39'Dahil'#39' THEN TUTAR-(TUTAR*(100.' +
        '0/(100.0+KDV))) ELSE (KDV*(TUTAR/100.0))  END) > 0.0'
      ''
      ''
      ''
      ''
      ''
      ''
      ''
      '')
    Left = 625
    Top = 313
    object TOPLAMLARACIKLAMA: TStringField
      FieldName = 'ACIKLAMA'
      ReadOnly = True
      Size = 12
    end
    object TOPLAMLARDEGER: TFloatField
      FieldName = 'DEGER'
      ReadOnly = True
    end
    object TOPLAMLARKUR: TWideStringField
      FieldName = 'KUR'
      ReadOnly = True
      Size = 5
    end
    object TOPLAMLARDOVIZTUTARI: TCurrencyField
      FieldKind = fkCalculated
      FieldName = 'DOVIZTUTARI'
      Calculated = True
    end
    object TOPLAMLARDOVIZ_CINSI: TWideStringField
      FieldName = 'DOVIZ_CINSI'
      ReadOnly = True
      Size = 6
    end
    object TOPLAMLARSECILENDOVIZCINSI: TStringField
      FieldKind = fkCalculated
      FieldName = 'SECILENDOVIZCINSI'
      Calculated = True
    end
  end
  object dtsTOPLAMLAR: TDataSource
    DataSet = TOPLAMLAR
    Left = 630
    Top = 364
  end
  object frxTOPLAMLAR: TfrxDBDataset
    UserName = 'TOPLAMLAR'
    CloseDataSource = False
    DataSet = TOPLAMLAR
    BCDToCurrency = False
    Left = 633
    Top = 411
  end
  object TabKaynaklar: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select distinct    '
      '   KAYNAKTUR = case   '
      '   '#9#9#9#9'when YERI in (406,407) then 9   '
      '   '#9#9#9#9'when YERI = 408 then 10         '
      '   '#9#9#9#9'when YERI in (409,410) then 19  '
      '   '#9#9#9#9'when YERI = 411 then 14         '
      '   '#9#9#9#9'when YERI in (412,413) then -99 '
      #9#9#9'   end, '
      '   KAYNAKBELGENO=case '
      
        '   '#9#9#9#9#9'when YERI in (406,407,409,410) then (select SIPARISNO fr' +
        'om SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ID' +
        '=F.YERID)) '
      
        '   '#9#9#9#9#9'when YERI in (408,411) then (select FATURANO from FATBAS' +
        'LIK where ID=(select FATBASID from FATURA where ID=F.YERID))    ' +
        '           '
      
        '   '#9#9#9#9#9'when YERI in (412,413) then (select TEKLIFNO from TEKLIF' +
        ' where ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))  ' +
        '           '
      #9#9#9#9'   end, '
      '   KAYNAKID=case      '
      
        #9#9#9'when YERI in (406,407,409,410) then (select SIPARISID from SI' +
        'PARISDETAY where ID=F.YERID ) '
      
        #9#9#9'when YERI in (408,411) then (select FATBASID from FATURA wher' +
        'e ID=F.YERID )                '
      
        #9#9#9'when YERI in (412,413) then (SELECT TEKLIFID FROM TEKLIFDETAY' +
        ' where ID=F.YERID )           '
      #9#9#9'end, '
      '   KAYNAKTARIH=case      '
      
        '   '#9#9#9#9'when YERI in (406,407,409,410) then (select SIPARISTARIH ' +
        'from SIPARIS where ID=(select SIPARISID from SIPARISDETAY where ' +
        'ID=F.YERID)) '
      
        '   '#9#9#9#9'when YERI in (408,411) then (select FATURATARIH from FATB' +
        'ASLIK where ID=(select FATBASID from FATURA where ID=F.YERID))  ' +
        '             '
      
        '   '#9#9#9#9'when YERI in (412,413) then (select TARIH from TEKLIF whe' +
        're ID=(SELECT TEKLIFID FROM TEKLIFDETAY where ID=F.YERID))      ' +
        '     '
      #9#9#9'   end  '
      'from FATURA F  '
      'where FATBASID=:PID and YERI between 406 and 414 ')
    Left = 838
    Top = 182
  end
  object DtsKaynaklar: TDataSource
    DataSet = TabKaynaklar
    Left = 841
    Top = 231
  end
  object DtsHesapOzeti: TDataSource
    DataSet = TabHesapOzeti
    Left = 583
    Top = 220
  end
  object TabHesapOzeti: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      
        'SELECT * from [dbo].[fn_CARIHESAPOZETI] (:PRehID,:PKur,:PFaturaT' +
        'utar) ')
    Left = 584
    Top = 169
  end
  object frxHesapOzeti: TfrxDBDataset
    UserName = 'Hesap '#214'zeti'
    CloseDataSource = False
    DataSet = TabHesapOzeti
    BCDToCurrency = False
    Left = 577
    Top = 272
  end
  object frxIzleme: TfrxDBDataset
    UserName = 'Izleme'
    CloseDataSource = False
    DataSet = tabIzleme
    BCDToCurrency = False
    Left = 275
    Top = 274
  end
  object tsIzleme: TDataSource
    DataSet = tabIzleme
    Left = 269
    Top = 220
  end
  object tabIzleme: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      'select '
      
        'AD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT STOKADI FROM STOKLA' +
        'R WHERE ID = F.URUNID ) ELSE  (SELECT AD FROM MASRAFGELIR WHERE ' +
        'ID = F.URUNID)  END,'
      
        'KOD =  CASE WHEN F.TUR IN (1,11) THEN (SELECT KOD FROM STOKLAR W' +
        'HERE ID = F.URUNID ) ELSE  (SELECT KOD FROM MASRAFGELIR WHERE ID' +
        '= F.URUNID )  END,'
      'F.* ,' +
        'PROJEKODU=(Select P.PROJEKODU from PROJELER P Where P.ID=F.PROJE' +
        'ID),' +
        'KAMPANYAADI=(select K.ADI from KAMPANYA K where K.ID=F.KAMPANYAI' +
        'D ),' +
      'ECZANEBIRIMFIYAT=convert(decimal(18,2),0),' +
      'IMALATCIBIRIMFIYAT=convert(decimal(18,2),0),' +
      'DEPOCUBIRIMFIYAT=convert(decimal(18,2),0),' +
        'BIRIMAD= (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM =-2702 an' +
        'd DEGER = convert(varchar(10),F.BIRIM) ),' +
      'SI.IZLEM,LOT=SI.ACIKLAMA, IZLEMMIKTAR=SI.MIKTAR ' +
      'from ' +
      #9'FATURA F left outer join ' +
      #9'STOKIZLEME SI on ' +
      #9#9'F.FATBASID=SI.BASLIKID and ' +
      #9#9'F.ID=SI.SATIRID ' +
      'where ' +
      #9'F.FATBASID= :PFatBasID AND ' +
      #9'SI.BELGETUR= :PBelgeTur '
      ''
      ''
      ''
      ''
      ''
      #9#9
      #9#9
      #9#9' ')
    Left = 269
    Top = 172
  end
  object frxKaynaklar: TfrxDBDataset
    UserName = 'Kaynaklar'
    CloseDataSource = False
    DataSet = TabKaynaklar
    BCDToCurrency = False
    Left = 593
    Top = 395
  end
  object DETAY: TFDQuery
    Connection = Tablo.FDCnn
    ParamData = <>
    SQL.Strings = (
      ''
      'select RB.SIRA,RB.ETIKET,RB.BILGI,RA.GIRIS,RA.KAYNAK,RA.ZORUNLU '
      'from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA'
      'where RB.YERI= :Yeri  and RB.YER_ID= :Yeri_Id   '
      'order by  1')
    Left = 704
    Top = 241
  end
  object DtsDetay: TDataSource
    DataSet = DETAY
    Left = 711
    Top = 284
  end
  object frxDETAY: TfrxDBDataset
    UserName = 'DETAY'
    CloseDataSource = False
    DataSet = DETAY
    BCDToCurrency = False
    Left = 705
    Top = 336
  end
end
