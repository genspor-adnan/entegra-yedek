object MakbuzWizardDlg: TMakbuzWizardDlg
  Left = 0
  Top = 0
  ActiveControl = editMakbuzno
  BorderIcons = [biSystemMenu]
  Caption = 'Makbuz Sihirbaz'#305
  ClientHeight = 553
  ClientWidth = 884
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 16
  object WizardKontrol: TJvWizard
    Left = 0
    Top = 0
    Width = 884
    Height = 553
    ActivePage = MakbuzEkr
    ButtonBarHeight = 42
    ButtonStart.Caption = 'To &Start Page'
    ButtonStart.NumGlyphs = 1
    ButtonStart.Width = 85
    ButtonLast.Caption = 'To &Last Page'
    ButtonLast.NumGlyphs = 1
    ButtonLast.Width = 85
    ButtonBack.Caption = '< &Geri'
    ButtonBack.NumGlyphs = 1
    ButtonBack.Width = 75
    ButtonNext.Caption = '&'#304'leri >'
    ButtonNext.NumGlyphs = 1
    ButtonNext.Width = 75
    ButtonFinish.Caption = '&Son'
    ButtonFinish.NumGlyphs = 1
    ButtonFinish.Width = 75
    ButtonCancel.Caption = #304'ptal'
    ButtonCancel.NumGlyphs = 1
    ButtonCancel.ModalResult = 2
    ButtonCancel.Width = 75
    ButtonHelp.Caption = '&Help'
    ButtonHelp.NumGlyphs = 1
    ButtonHelp.Width = 75
    ShowRouteMap = False
    OnFinishButtonClick = WizardKontrolFinishButtonClick
    OnCancelButtonClick = WizardKontrolCancelButtonClick
    DesignSize = (
      884
      553)
    object MakbuzEkr: TJvWizardInteriorPage
      Header.ParentFont = False
      Header.Title.Color = clNone
      Header.Title.Text = 'Makbuz bilgileri'
      Header.Title.Anchors = [akLeft, akTop, akRight]
      Header.Title.Font.Charset = TURKISH_CHARSET
      Header.Title.Font.Color = clWindowText
      Header.Title.Font.Height = -16
      Header.Title.Font.Name = 'Trebuchet MS'
      Header.Title.Font.Style = [fsBold]
      Header.Subtitle.Color = clNone
      Header.Subtitle.Anchors = [akLeft, akTop, akRight, akBottom]
      Header.Subtitle.Font.Charset = TURKISH_CHARSET
      Header.Subtitle.Font.Color = clWindowText
      Header.Subtitle.Font.Height = -11
      Header.Subtitle.Font.Name = 'Trebuchet MS'
      Header.Subtitle.Font.Style = []
      Header.Subtitle.Text = ''
      VisibleButtons = [bkFinish, bkCancel]
      OnNextButtonClick = MakbuzEkrNextButtonClick
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PanelUst: TPanel
        Left = 0
        Top = 70
        Width = 884
        Height = 124
        Align = alTop
        BevelOuter = bvNone
        Color = 11776947
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Trebuchet MS'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        object btnKapat: TSpeedButton
          Left = 1050
          Top = 7
          Width = 64
          Height = 23
          Caption = 'Kapat'
          Flat = True
          Glyph.Data = {
            66010000424D6601000000000000760000002800000013000000140000000100
            040000000000F000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            7777777600007777777777777777777000007777777777777777777000007777
            777777777777777000007777777777777770F77C0000777770F7777777777776
            00007777000F7777770F777000007777000F777770F77770000077777000F777
            00F7777E0000777777000F700F7777700000777777700000F777777F00007777
            7777000F777777760000777777700000F77777700000777777000F70F7777770
            000077770000F77700F7777000007770000F7777700F7770000077700F777777
            7700F77400007777777777777777777600007777777777777777777000007777
            77777777777777700000}
        end
        object LabelMakbuzTarihi: TcxLabel
          Left = 398
          Top = 35
          AutoSize = False
          Caption = 'Makbuz Tarihi'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
          Height = 20
          Width = 137
        end
        object LabelFatNo: TcxLabel
          Left = 398
          Top = 81
          AutoSize = False
          Caption = 'Makbuz No'
          ParentFont = False
          Style.Font.Charset = TURKISH_CHARSET
          Style.Font.Color = clWindowText
          Style.Font.Height = -11
          Style.Font.Name = 'Trebuchet MS'
          Style.Font.Style = [fsBold]
          Style.IsFontAssigned = True
          Transparent = True
          Height = 20
          Width = 136
        end
        object ToolBar3: TToolBar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 878
          Margins.Bottom = 0
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 86
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
          object YaziciYaz: TToolButton
            Left = 0
            Top = 0
            Caption = 'Yazd'#305'r'
            DropdownMenu = PopupMenuYaz
            ImageIndex = 16
            ImageName = 'PngImage15'
            Style = tbsTextButton
          end
          object ToolButton3: TToolButton
            Left = 86
            Top = 0
            Width = 8
            Caption = 'ToolButton3'
            ImageIndex = 17
            ImageName = 'PngImage16'
            Style = tbsSeparator
          end
          object AksiyonlarTus: TToolButton
            Left = 94
            Top = 0
            Caption = 'Aksiyonlar'
            DropdownMenu = PmSagClick
            ImageIndex = 1
            ImageName = 'PngImage0'
          end
        end
        object EditFatTarih: TcxDateEdit
          Left = 398
          Top = 56
          Enabled = False
          Properties.Kind = ckDateTime
          TabOrder = 2
          Width = 136
        end
        object cxLabel5: TcxLabel
          Left = 7
          Top = 35
          AutoSize = False
          Caption = 'M'#252#351'teri Kodu'
          Transparent = True
          Height = 20
          Width = 130
        end
        object LabelAd: TcxLabel
          Left = 12
          Top = 102
          Cursor = crHandPoint
          Caption = '------'
          OnClick = LabelAdClick
        end
        object EditCARIKOD: TcxButtonEdit
          Left = 7
          Top = 56
          Enabled = False
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.OnButtonClick = EditCARIKODPropertiesButtonClick
          TabOrder = 1
          Width = 126
        end
        object cxLabel1: TcxLabel
          Left = 7
          Top = 81
          AutoSize = False
          Caption = #220'nvan'#305
          Transparent = True
          Height = 20
          Width = 126
        end
        object lbYerId: TcxLabel
          Left = 541
          Top = 102
          Caption = 'lbYerId'
        end
        object editMakbuzno: TcxButtonEdit
          Left = 398
          Top = 98
          Properties.Buttons = <
            item
              Default = True
              Kind = bkEllipsis
            end>
          Properties.ReadOnly = True
          Properties.OnButtonClick = editMakbuznoPropertiesButtonClick
          TabOrder = 9
          Text = 'editMakbuzno'
          Width = 137
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 194
        Width = 884
        Height = 317
        Align = alClient
        Caption = 'Panel3'
        TabOrder = 1
        object GridMakbuz: TcxGrid
          Left = 1
          Top = 28
          Width = 882
          Height = 288
          Align = alClient
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ParentFont = False
          PopupMenu = PmSagClick
          TabOrder = 1
          LookAndFeel.Kind = lfOffice11
          LookAndFeel.NativeStyle = False
          LookAndFeel.SkinName = 'LondonLiquidSky'
          object GridMakbuzView: TcxGridDBTableView
            OnDblClick = DuzenleTusClick
            Navigator.Buttons.CustomButtons = <>
            ScrollbarAnnotations.CustomAnnotations = <>
            OnCanFocusRecord = GridMakbuzViewCanFocusRecord
            DataController.DataSource = DtsMakbuz
            DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
            DataController.Summary.DefaultGroupSummaryItems = <
              item
                Kind = skSum
                Position = spFooter
                Column = GridMakbuzViewDOVIZ_TUTARI
              end
              item
                Kind = skSum
                Position = spFooter
                Column = GridMakbuzViewTUTAR1
              end>
            DataController.Summary.FooterSummaryItems = <
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridMakbuzViewDOVIZ_TUTARI
              end
              item
                Format = ',0.00;(,0.00)'
                Kind = skSum
                Column = GridMakbuzViewTUTAR1
              end>
            DataController.Summary.SummaryGroups = <>
            OptionsBehavior.AlwaysShowEditor = True
            OptionsBehavior.FocusCellOnTab = True
            OptionsCustomize.ColumnsQuickCustomization = True
            OptionsSelection.CellSelect = False
            OptionsSelection.HideSelection = True
            OptionsView.Footer = True
            OptionsView.FooterAutoHeight = True
            OptionsView.GroupFooters = gfAlwaysVisible
            OptionsView.Indicator = True
            object GridMakbuzViewTUR: TcxGridDBColumn
              Caption = 'T'#252'r'
              DataBinding.FieldName = 'TUR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              Styles.Header = cxStyle8
            end
            object GridMakbuzViewKOD1: TcxGridDBColumn
              Caption = 'Kod'
              DataBinding.FieldName = 'KOD'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxTextEditProperties'
              Styles.Header = cxStyle8
              Width = 53
            end
            object GridMakbuzViewHESAP1: TcxGridDBColumn
              Caption = 'Hesap'
              DataBinding.FieldName = 'HESAP'
              DataBinding.IsNullValueType = True
              Styles.Content = cxStyle14
              Styles.Header = cxStyle8
              Width = 88
            end
            object GridMakbuzViewACIKLAMA1: TcxGridDBColumn
              Caption = 'A'#231#305'klama'
              DataBinding.FieldName = 'ACIKLAMA'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxTextEditProperties'
              Styles.Header = cxStyle8
              Width = 253
            end
            object GridMakbuzViewTUTAR1: TcxGridDBColumn
              Caption = 'Tutar'
              DataBinding.FieldName = 'TUTAR'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              HeaderAlignmentHorz = taCenter
              Styles.Content = cxStyle14
              Styles.Header = cxStyle8
              Width = 102
            end
            object GridMakbuzViewKUR1: TcxGridDBColumn
              Caption = 'P.Birimi'
              DataBinding.FieldName = 'KUR'
              DataBinding.IsNullValueType = True
              Styles.Content = cxStyle14
              Styles.Header = cxStyle8
              Width = 49
            end
            object GridMakbuzViewDOVIZ_TUTARI: TcxGridDBColumn
              Caption = 'Ekstre D'#246'vizi'
              DataBinding.FieldName = 'DOVIZ_TUTARI'
              DataBinding.IsNullValueType = True
              PropertiesClassName = 'TcxCurrencyEditProperties'
              Properties.DisplayFormat = ',0.00;(,0.00)'
              Styles.Content = cxStyle14
              Styles.Header = cxStyle8
              Width = 84
            end
            object GridMakbuzViewDOVIZ_KURU: TcxGridDBColumn
              Caption = 'D.Birimi'
              DataBinding.FieldName = 'DOVIZ_KURU'
              DataBinding.IsNullValueType = True
              Styles.Content = cxStyle14
              Styles.Header = cxStyle8
              Width = 47
            end
          end
          object GridMakbuzLevel1: TcxGridLevel
            GridView = GridMakbuzView
          end
        end
        object ToolBar5: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 876
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
          object NakitTus: TToolButton
            Left = 0
            Top = 0
            Caption = 'Nakit'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = NakitTusClick
          end
          object HavaleTus: TToolButton
            Left = 66
            Top = 0
            Caption = 'Havale'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = HavaleTusClick
          end
          object KKTus: TToolButton
            Left = 132
            Top = 0
            Caption = 'KK'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = KKTusClick
          end
          object CekTus: TToolButton
            Left = 198
            Top = 0
            Caption = #199'ek'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = CekTusClick
          end
          object SenetTus: TToolButton
            Left = 264
            Top = 0
            Caption = 'Senet'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = CekTusClick
          end
          object DigerTus: TToolButton
            Left = 330
            Top = 0
            Caption = 'Di'#287'er'
            DropdownMenu = pmDigerTurler
            EnableDropdown = True
            ImageIndex = 0
            ImageName = 'PngImage0'
            Indeterminate = True
          end
          object ToolButton1: TToolButton
            Left = 396
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object SatirSil: TToolButton
            Left = 404
            Top = 0
            Caption = 'Sil'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = SatirSilClick
          end
          object ToolButton10: TToolButton
            Left = 470
            Top = 0
            Width = 8
            Caption = 'ToolButton10'
            ImageIndex = 8
            ImageName = 'PngImage15'
            Style = tbsSeparator
          end
          object DuzenleTus: TToolButton
            Left = 478
            Top = 0
            Caption = 'D'#252'zenle'
            ImageIndex = 7
            ImageName = 'PngImage7'
            OnClick = DuzenleTusClick
          end
          object ToolButton11: TToolButton
            Left = 544
            Top = 0
            Width = 4
            Caption = 'ToolButton11'
            ImageIndex = 8
            ImageName = 'PngImage15'
            Style = tbsSeparator
          end
        end
        object SQLCek: TcxMemo
          Left = 7
          Top = 82
          Lines.Strings = (
            
              'IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE '#39'##M' +
              'AKBUZ_SPID_%'#39')'
            'DROP TABLE ##MAKBUZ_SPID_'
            ''
            'CREATE TABLE ##MAKBUZ_SPID_('
            #9'[ID] [smallint] IDENTITY(1,1) NOT NULL,'
            #9'[ID_GELEN] [int]   NULL,'
            #9'[TUR] [smallint] NULL,'
            #9'[TARIH] [datetime]  NULL,'
            #9'[VADETARIH] [datetime]  NULL,'
            #9'[BELGENO] [nvarchar](40) NULL,'
            #9'[KOD] [nvarchar](20) NULL,'
            #9'[HESAP] [nvarchar](250) NULL,'
            #9'[ACIKLAMA] [nvarchar](250) NULL,'
            #9'[ACIKLAMA2] [nvarchar](250) NULL,'
            #9'[TUTAR] [money] NULL,'
            #9'[DOVIZ_TUTARI] [money] NULL,'
            #9'[KUR] [nvarchar](5) NULL,'
            #9'[DOVIZ_KURU] [nvarchar](5) NULL,'
            #9'[HESAPID] [int] NULL,'
            #9'[YERI] [int] NULL,'
            #9'[YERID] [int] NULL,'
            #9'[FATURAID] [int] NULL,'
            #9'[HESAPTURU] [nvarchar](1) NULL,'
            #9'[BASLIK] [nvarchar](250) NULL,'
            #9'[CARI] [nvarchar](250) NULL,'
            #9'[SERINO] [nvarchar](50) NULL,'
            #9'[BANKA] [nvarchar](250) NULL,'
            #9'[SUBENO] [nvarchar](50) NULL,'
            #9'[SUBEADI] [nvarchar](50) NULL,'#9
            #9'[HESAPNO] [nvarchar](50) NULL,'#9
            #9'[IBAN] [nvarchar](50) NULL'
            ')'
            ''
            'INSERT INTO ##MAKBUZ_SPID_'
            '--select * from KASALAR'
            'SELECT '
            
              #9'ID_GELEN= K.ID, K.TUR, K.ISLEMTARIHI as TARIH,VADETARIH=K.PLANT' +
              'ARIHI, BELGENO, KOD= KS.KASAKODU, HESAP = KS.KASAADI,'
            #9'ACIKLAMA = LTRIM(RTRIM(isnull(K.ACIKLAMA,'#39#39'))), ACIKLAMA2 = '#39#39','
            #9'TUTAR=case when K.BORC>0.0 then BORC else ALACAK end, '
            #9'K.DOVIZ_TUTARI,K.KUR,K.DOVIZ_KURU ,K.HESAPID, K.YERI, K.YERID,'
            #9'FATURAID = K.FATURAID, HESAPTURU, BASLIK='#39#39','
            
              #9'CARI='#39#39', SERINO='#39#39', BANKA='#39#39',SUBENO='#39#39',SUBEADI='#39#39',HESAPNO='#39#39',IB' +
              'AN='#39#39
            'FROM '
            #9'KASA K'
            #9#9'LEFT JOIN KASALAR KS ON KS.ID = K.HESAPID'
            'where '
            #9'K.HESAPTURU IN ('#39'-'#39', '#39'K'#39', '#39'H'#39') and '
            #9'K.ISLEMTARIHI = '#39':TARIH'#39'  and '
            #9'K.BELGENO =  '#39':MAKBUZNO'#39
            #9'and K.REHBERID=&RehID'
            ''
            ''
            'UNION ALL'
            ''
            'SELECT '
            
              #9'ID_GELEN= K.ID, K.TUR, K.ISLEMTARIHI as TARIH,VADETARIH=K.PLANT' +
              'ARIHI, BELGENO, KOD= BH.HESAPKODU, '
            
              #9'HESAP = BH.HESAPADI+'#39' '#39'+BH.HESAPNO, ACIKLAMA = LTRIM(RTRIM(isnu' +
              'll(K.ACIKLAMA,'#39#39'))), ACIKLAMA2 = '#39#39','
            #9'TUTAR=case when K.BORC>0.0 then BORC else ALACAK end, '
            #9'K.DOVIZ_TUTARI,K.KUR,K.DOVIZ_KURU , K.HESAPID, K.YERI, K.YERID,'
            #9'FATURAID = K.FATURAID, HESAPTURU, BASLIK='#39#39','
            
              #9'CARI='#39#39', SERINO='#39#39', BANKA=B.BANKAADI,SUBENO=convert(varchar(20)' +
              ',BS.SUBEKODU),SUBEADI=BS.SUBEADI,HESAPNO=BH.HESAPNO,IBAN=BH.IBAN'
            'FROM '
            #9'KASA K INNER JOIN '
            #9'BANKAHESAPLAR BH ON BH.ID = K.HESAPID left outer join'
            #9'BANKASUBELER BS on BH.BANKASUBELERID=BS.ID left outer join'
            #9'BANKALAR B on BS.BANKAKODU=B.BANKAKODU '
            'where '
            #9'K.HESAPTURU='#39'B'#39'  and'
            #9'K.ISLEMTARIHI = '#39':TARIH'#39'  and '
            #9'K.BELGENO =  '#39':MAKBUZNO'#39
            #9'and K.REHBERID=&RehID'
            '---POS'
            'UNION ALL'
            'SELECT '
            
              #9'ID_GELEN= K.ID, K.TUR, K.ISLEMTARIHI as TARIH,VADETARIH=K.PLANT' +
              'ARIHI, BELGENO, KOD= P.KODU, HESAP = P.ADI,'
            #9'ACIKLAMA = LTRIM(RTRIM(isnull(K.ACIKLAMA,'#39#39'))), ACIKLAMA2 = '#39#39','
            #9'TUTAR=case when K.BORC>0.0 then BORC else ALACAK end, '
            #9'K.DOVIZ_TUTARI,K.KUR,K.DOVIZ_KURU , K.HESAPID, K.YERI, K.YERID'
            #9',FATURAID = K.FATURAID, HESAPTURU, BASLIK='#39#39','
            #9'CARI='#39#39', SERINO=P.NOSU, BANKA=B.BANKAADI,SUBENO=convert(varchar'
            
              '(20),BS.SUBEKODU),SUBEADI=BS.SUBEADI,HESAPNO=BH.HESAPNO,IBAN=BH.' +
              'IBAN'
            'FROM '
            #9'KASA K INNER JOIN '
            #9'POS P ON P.ID = K.HESAPID LEFT OUTER JOIN '
            #9'BANKAHESAPLAR BH ON BH.ID = P.BANKAHESAPID left outer join'
            #9'BANKASUBELER BS on BH.BANKASUBELERID=BS.ID left outer join'
            #9'BANKALAR B on BS.BANKAKODU=B.BANKAKODU '
            'where'
            #9'K.HESAPTURU='#39'P'#39' '
            #9'and K.ISLEMTARIHI = '#39':TARIH'#39'   '
            #9'and K.BELGENO = '#39':MAKBUZNO'#39
            #9'--and K.REHBERID=&RehID'
            ''
            '---Kredi Kart'#305
            'UNION ALL'
            'SELECT '
            
              #9'ID_GELEN= K.ID, K.TUR, K.ISLEMTARIHI as TARIH,VADETARIH=K.PLANT' +
              'ARIHI, BELGENO, KOD= KK.KODU, HESAP = KK.ADI,'
            #9'ACIKLAMA = LTRIM(RTRIM(isnull(K.ACIKLAMA,'#39#39'))), ACIKLAMA2 = '#39#39','
            #9'TUTAR=case when K.BORC>0.0 then BORC else ALACAK end, '
            #9'K.DOVIZ_TUTARI,K.KUR,K.DOVIZ_KURU , K.HESAPID, K.YERI, K.YERID'
            #9',FATURAID = K.FATURAID, HESAPTURU,BASLIK='#39#39','
            
              #9'CARI=KK.HAMILI, SERINO=convert(varchar(4),KK.NOSU)+'#39' ..... ...'#39 +
              ', BANKA=B.BANKAADI,SUBENO=convert(varchar'
            
              '(20),BS.SUBEKODU),SUBEADI=BS.SUBEADI,HESAPNO=BH.HESAPNO,IBAN=BH.' +
              'IBAN'
            'FROM '
            #9'KASA K'
            
              #9'INNER JOIN dbo.KREDIKARTI KK ON KK.ID = K.HESAPID  and K.HESAPT' +
              'URU='#39'V'#39
            
              #9'LEFT OUTER JOIN BANKAHESAPLAR BH ON BH.ID = KK.BANKAHESAPID lef' +
              't outer join'
            #9'BANKASUBELER BS on BH.BANKASUBELERID=BS.ID left outer join'
            #9'BANKALAR B on BS.BANKAKODU=B.BANKAKODU '
            'where '
            #9'K.ISLEMTARIHI = '#39':TARIH'#39'  '
            #9'and K.BELGENO = '#39':MAKBUZNO'#39
            #9'and K.REHBERID=&RehID'
            ''
            '---'#231'ek'
            'UNION ALL'
            'SELECT'
            
              #9'ID_GELEN= CH.ID, TUR=CH.ISLEM,CH.TARIH,VADETARIH=C.VADE,CH.BELG' +
              'ENO,  KOD = C.KOD,'
            
              #9'HESAP = (select isnull(HESAPADI,'#39#39') from HESAPPLANI where HESAP' +
              'KODU=C.KOD ),'
            
              #9'ACIKLAMA = C.ACIKLAMA, ACIKLAMA2 =(Select FIRMA from REHBER R w' +
              'here R.ID=C.REHBERID), '
            'C.TUTAR, '
            
              'DOVIZ_TUTARI=case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else C.' +
              'TUTAR end,'
            'C.KUR,'
            
              'DOVIZ_KURU=case when CH.EKSTREDEKULLAN=1 then CH.KUR else C.KUR ' +
              'end, '
            'HESAPID = -1, YERI = NULL, YERID = NULL,'
            #9'FATURAID = CH.ID,HESAPTURU = '#39#39',BASLIK = C.BORCLU,'
            
              #9'CARI=isnull((select HESAPADI from BANKAHESAPLAR BH where BH.ID=' +
              'CH.BANKAHESAPLARID),(Select FIRMA from REHBER R where '
            'R.ID=CH.REHBERID)), '
            #9'SERINO=convert(varchar(50),C.SERINO), '
            
              #9'BANKA=B.BANKAADI,SUBENO=convert(varchar(20),BS.SUBEKODU),SUBEAD' +
              'I=BS.SUBEADI,C.HESAPNO,C.IBAN'
            #9' '
            'FROM'
            #9'CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID'
            #9'left outer JOIN BANKASUBELER BS ON BS.ID = C.BANKASUBELERID'
            #9'left outer JOIN BANKALAR B ON B.BANKAKODU = BS.BANKAKODU'
            'where'
            #9'CH.TARIH = '#39':TARIH'#39'  '
            '--and C.MAKBUZNO = '#39':MAKBUZNO'#39
            'and CH.REHBERID=&RehID'
            ''
            ''
            '---Senet'
            'UNION ALL'
            'SELECT '
            
              #9'ID_GELEN= S.ID, S.TUR,S.VADE as TARIH,VADETARIH=S.VADE, MAKBUZN' +
              'O as BELGENO,  KOD=S.KOD, '
            
              #9'HESAP = (select isnull(HESAPADI,'#39#39') from HESAPPLANI where HESAP' +
              'KODU=substring(S.KOD,1,3) ),'
            #9'ACIKLAMA='#39#39', ACIKLAMA2 = '#39#39','
            
              #9'S.TUTAR, S.DOVIZ_TUTARI,S.KUR,S.DOVIZ_KURU, HESAPID = -1, YERI ' +
              '=NULL, YERID=NULL,'
            #9'FATURAID = NULL,HESAPTURU='#39#39',BASLIK=S.BORCLU,'
            
              #9'CARI='#39#39', SERINO='#39#39', BANKA='#39#39',SUBENO='#39#39',SUBEADI='#39#39',HESAPNO='#39#39',IB' +
              'AN='#39#39
            'FROM '
            #9'SENETLER S'
            'where '
            #9'S.TARIH = '#39':TARIH'#39'  '
            'and S.MAKBUZNO = '#39':MAKBUZNO'#39
            'and S.REHBERID=&RehID'
            ''
            '---Senet cirola'
            'UNION ALL'
            'SELECT '
            
              #9'ID_GELEN= S.ID, S.TUR,S.VADE as TARIH,VADETARIH=S.VADE, S.CIROM' +
              'AKBUZNO as BELGENO,  KOD=S.KOD, '
            
              #9'HESAP = (select isnull(HESAPADI,'#39#39') from HESAPPLANI where HESAP' +
              'KODU=substring(S.KOD,1,3) ),'
            #9'ACIKLAMA='#39#39', ACIKLAMA2 = '#39#39','
            #9'S.TUTAR, S.DOVIZ_TUTARI,S.KUR,S.DOVIZ_KURU, HESAPID = -1'
            #9',YERI =NULL'
            #9',YERID=NULL'
            #9',FATURAID = NULL,HESAPTURU='#39#39',BASLIK=S.BORCLU,'
            
              #9'CARI='#39#39', SERINO='#39#39', BANKA='#39#39',SUBENO='#39#39',SUBEADI='#39#39',HESAPNO='#39#39',IB' +
              'AN='#39#39
            'FROM '
            #9'SENETLER S'
            'where '
            #9'S.CIROTARIH = '#39':TARIH'#39'  '
            'and S.CIROMAKBUZNO = '#39':MAKBUZNO'#39
            'and S.CIROREHBERID=&RehID'
            ''
            'SELECT * FROM ##MAKBUZ_SPID_')
          TabOrder = 2
          Visible = False
          Height = 69
          Width = 784
        end
      end
    end
    object cxImageComboBox1: TcxImageComboBox
      Left = 128
      Top = 277
      Properties.Items = <>
      TabOrder = 5
      Width = 121
    end
  end
  object MemoMakbuznoUpdate: TcxMemo
    Left = 8
    Top = 351
    Lines.Strings = (
      
        'declare @Tarih datetime, @Eskibelgeno nvarchar(40),@Yenibelgeno ' +
        'nvarchar(20)'
      'set @Tarih = &Tarih1'
      'Set @Eskibelgeno = &EskiBelgeNo1'
      'Set @Yenibelgeno = &Yenibelgeno1'
      ''
      #9'update KASA set BELGENO = @Yenibelgeno'
      
        #9'where convert(datetime,convert(varchar(11),ISLEMTARIHI,113)) =c' +
        'onvert(datetime,convert(varchar(11),@Tarih,113)) '
      #9'and BELGENO = @Eskibelgeno'
      #9
      #9'update CEKHAREKET set BELGENO = @Yenibelgeno'
      
        #9'where convert(datetime,convert(varchar(11),TARIH,113)) = conver' +
        't(datetime,convert(varchar(11),@Tarih,113)) '
      #9'and BELGENO = @Eskibelgeno'
      ''
      #9'update SENETLER set MAKBUZNO = @Yenibelgeno'
      
        #9'where convert(datetime,convert(varchar(11),TARIH,113)) =convert' +
        '(datetime,convert(varchar(11),@Tarih,113)) '
      #9'and MAKBUZNO = @Eskibelgeno'#9#9
      ''
      #9'update SENETLER set CIROMAKBUZNO = @Yenibelgeno'
      
        #9'where convert(datetime,convert(varchar(11),TARIH,113)) =convert' +
        '(datetime,convert(varchar(11),@Tarih,113)) '
      #9'and CIROMAKBUZNO = @Eskibelgeno'#9#9)
    TabOrder = 1
    Visible = False
    Height = 42
    Width = 784
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  *  FROM  [IMAJ]'
      'WHERE'
      'YERI = :PYeri AND'
      'YER_ID=:PYer_ID')
    Left = 295
    Top = 344
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    Left = 344
    Top = 342
  end
  object OpenDialog1: TOpenDialog
    Left = 236
    Top = 287
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 305
    Top = 278
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 11796479
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle10: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle11: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle12: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle13: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle14: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clSilver
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle15: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
    object cxStyle16: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clPurple
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clPurple
    end
  end
  object DtsMakbuz: TDataSource
    DataSet = TabMakbuz
    Left = 505
    Top = 292
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 21
    Top = 218
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
      end
      object EMail1: TMenuItem
        Tag = 99
        Caption = 'E-Mail'
        ImageIndex = 9
        OnClick = BaskiOnizlemeMenuClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
  end
  object TabMakbuz: TFDQuery
    AutoCalcFields = False
    AfterOpen = TabMakbuzAfterOpen
    Connection = Tablo.FDCnn
    Left = 420
    Top = 292
  end
  object frxMakbuz: TfrxDBDataset
    UserName = 'Makbuz'
    CloseDataSource = False
    DataSet = TabMakbuzYaz
    BCDToCurrency = False
    DataSetOptions = []
    Left = 558
    Top = 281
  end
  object TabMakbuzYaz: TFDQuery
    AutoCalcFields = False
    BeforeOpen = TabMakbuzYazBeforeOpen
    AfterOpen = TabMakbuzAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT M.*,'
      
        'YAZIYLATUTAR=( dbo.fn_ParaTextOlarakTumDiller(M.TUTAR,D1.BUYUKBI' +
        'RIMADI,D1.KUCUKBIRIMADI,0,-1)),'
      
        'YAZIYLADOVIZTUTAR=( dbo.fn_ParaTextOlarakTumDiller(M.DOVIZ_TUTAR' +
        'I,D1.BUYUKBIRIMADI,D1.KUCUKBIRIMADI,0,-1)),'
      
        'YAZIYLATOPLAM=( dbo.fn_ParaTextOlarakTumDiller((select SUM(M2.TU' +
        'TAR)from ##MAKBUZ_SPID_ M2),D1.BUYUKBIRIMADI,D1.KUCUKBIRIMADI,0,' +
        '-1)),'
      
        'TURADI=(select ANAHTAR from GENINI where DEGER=M.TUR and DIL=-1 ' +
        'and BOLUM=-1005)'
      'FROM ##MAKBUZ_SPID_  M'
      'Left outer join DOVIZCINSLERI D1 on  '
      
        'D1.DIL=-1 and M.KUR collate Turkish_CI_AS = D1.DOVIZ collate Tur' +
        'kish_CI_AS '
      '')
    Left = 637
    Top = 281
  end
  object pmDigerTurler: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 335
    Top = 107
    object mnIadeCeki: TMenuItem
      Tag = 39
      Caption = #304'ade '#199'eki'
      ImageIndex = 34
      Hint = '29'
      OnClick = NakitTusClick
    end
    object Hediyeeki1: TMenuItem
      Tag = 38
      Caption = 'Hediye '#199'eki'
      ImageIndex = 34
      Hint = '28'
      OnClick = NakitTusClick
    end
    object Kupon1: TMenuItem
      Tag = 36
      Caption = 'Kupon'
      ImageIndex = 34
      Hint = '26'
      OnClick = NakitTusClick
    end
  end
  object PmSagClick: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PmSagClickPopup
    Left = 240
    Top = 104
    object PmItemCekKopyala: TMenuItem
      Caption = #199'ek Kopyala'
      ImageIndex = 10
      Visible = False
      OnClick = PmItemCekKopyalaClick
    end
    object PmItemSenetKopyala: TMenuItem
      Caption = 'Senet Kopyala'
      ImageIndex = 10
      Visible = False
      OnClick = PmItemCekKopyalaClick
    end
  end
  object tabMakbuzToplam: TFDQuery
    AutoCalcFields = False
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select KUR,TUTAR= SUM(TUTAR),DOVIZ_KURU,DOVIZ_TUTARI=SUM(DOVIZ_T' +
        'UTARI) ,'
      
        'YAZIYLATOPLAM=( dbo.fn_ParaTextOlarakTumDiller(SUM(TUTAR),'#39'TL'#39','#39 +
        'Kr'#39',0,-1)),'
      
        'YAZIYLATOPLAMDOVIZ=( dbo.fn_ParaTextOlarakTumDiller(SUM(DOVIZ_TU' +
        'TARI),'
      
        '(select D.BUYUKBIRIMADI from DOVIZCINSLERI D where D.DIL=-1 and ' +
        'D.DOVIZ collate TURKISH_CI_AI =DOVIZ_KURU collate TURKISH_CI_AI)' +
        ','
      
        '(select D.KUCUKBIRIMADI from DOVIZCINSLERI D where D.DIL=-1 and ' +
        'D.DOVIZ collate TURKISH_CI_AI =DOVIZ_KURU collate TURKISH_CI_AI ' +
        '),'
      '0,-1))'
      'from ##MAKBUZ_SPID_ '
      'group by KUR,DOVIZ_KURU')
    Left = 372
    Top = 404
  end
  object dtsMakbuzToplam: TDataSource
    DataSet = tabMakbuzToplam
    Left = 497
    Top = 412
  end
  object frxMakbuzToplam: TfrxDBDataset
    UserName = 'MakbuzToplam'
    CloseDataSource = False
    DataSet = tabMakbuzToplam
    BCDToCurrency = False
    DataSetOptions = []
    Left = 550
    Top = 425
  end
end
