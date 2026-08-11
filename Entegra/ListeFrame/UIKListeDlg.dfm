object IKListeDlg: TIKListeDlg
  Left = 0
  Top = 0
  Width = 970
  Height = 558
  Align = alClient
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object cxPageControl1: TcxPageControl
    Properties.Images = Tablo.PNGImageList2
    Left = 0
    Top = 0
    Width = 970
    Height = 558
    Align = alClient
    TabOrder = 0
    Properties.ActivePage = TabSheetTek
    Properties.CustomButtons.Buttons = <>
    OnChange = cxPageControl1Change
    ClientRectBottom = 554
    ClientRectLeft = 4
    ClientRectRight = 966
    ClientRectTop = 27
    object TabSheetTek: TcxTabSheet
      Caption = 'Tek'
      ImageIndex = 35
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object IKGrid: TcxGrid
        Left = 0
        Top = 32
        Width = 962
        Height = 228
        Align = alClient
        PopupMenu = PopupMenuYeni
        TabOrder = 0
        LookAndFeel.Kind = lfOffice11
        LookAndFeel.NativeStyle = True
        LookAndFeel.ScrollbarMode = sbmClassic
        object IKGridView: TcxGridDBTableView
          OnDblClick = IKGridViewDblClick
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnCanFocusRecord = IKGridViewCanFocusRecord
          OnSelectionChanged = IKGridViewSelectionChanged
          DataController.DataSource = DtsRehber
          DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
          DataController.Summary.DefaultGroupSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
              Position = spFooter
              VisibleForCustomization = False
            end>
          DataController.Summary.FooterSummaryItems = <
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
            end
            item
              Format = ',0.00;-,0.00'
              Kind = skSum
            end
            item
              Format = 'Say'#305' :  ######'
              Kind = skCount
              Column = IKGridViewFIRMA1
            end>
          DataController.Summary.SummaryGroups = <>
          OptionsBehavior.CellHints = True
          OptionsBehavior.FocusCellOnTab = True
          OptionsCustomize.ColumnsQuickCustomization = True
          OptionsData.CancelOnExit = False
          OptionsData.Editing = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.Footer = True
          OptionsView.GridLines = glNone
          OptionsView.GroupFooters = gfAlwaysVisible
          OptionsView.Indicator = True
          Styles.Content = cxStyle1
          Styles.OnGetContentStyle = IKGridViewStylesGetContentStyle
          Styles.Header = cxStyle2
          Styles.Indicator = cxStyle2
          object IKGridViewID: TcxGridDBColumn
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewKOD1: TcxGridDBColumn
            Caption = 'Kod'
            DataBinding.FieldName = 'KOD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.ReadOnly = True
            Styles.Header = cxStyle3
            Width = 68
          end
          object IKGridViewVKNO: TcxGridDBColumn
            Caption = 'T.C.No'
            DataBinding.FieldName = 'VKNO'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewFIRMA1: TcxGridDBColumn
            Caption = 'Ad Soyad'
            DataBinding.FieldName = 'ADSOYAD'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Properties.Alignment.Horz = taLeftJustify
            Properties.ReadOnly = True
            Styles.Header = cxStyle4
            Width = 145
          end
          object IKGridViewCINSIYET: TcxGridDBColumn
            Caption = 'Cinsiyet'
            DataBinding.FieldName = 'CINSIYET'
            DataBinding.IsNullValueType = True
            Width = 109
          end
          object IKGridViewDYERI: TcxGridDBColumn
            Caption = 'Do'#287'um Yeri'
            DataBinding.FieldName = 'DYERI'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewUYRUGU: TcxGridDBColumn
            Caption = 'Uyru'#287'u'
            DataBinding.FieldName = 'UYRUGU'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewDTARIHI: TcxGridDBColumn
            Caption = 'Do'#287'um Tarihi'
            DataBinding.FieldName = 'DTARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.SaveTime = False
            Properties.ShowTime = False
            Width = 79
          end
          object IKGridViewOGRENIM: TcxGridDBColumn
            Caption = #214#287'r.Durumu'
            DataBinding.FieldName = 'OGRENIM'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewSEKTOR: TcxGridDBColumn
            Caption = 'Sekt'#246'r'
            DataBinding.FieldName = 'SEKTOR'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewDepartman: TcxGridDBColumn
            Caption = 'Departman'
            DataBinding.FieldName = 'DEPARTMAN'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 90
          end
          object IKGridViewGOREVI: TcxGridDBColumn
            Caption = 'G'#246'revi'
            DataBinding.FieldName = 'GOREVI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxTextEditProperties'
            Width = 91
          end
          object IKGridViewGIRISTARIHI: TcxGridDBColumn
            Caption = 'Giri'#351' Tarihi'
            DataBinding.FieldName = 'GIRISTARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.SaveTime = False
            Properties.ShowTime = False
          end
          object IKGridViewCIKISTARIHI: TcxGridDBColumn
            Caption = #199#305'k'#305#351' Tarihi'
            DataBinding.FieldName = 'CIKISTARIHI'
            DataBinding.IsNullValueType = True
            PropertiesClassName = 'TcxDateEditProperties'
            Properties.SaveTime = False
            Properties.ShowTime = False
          end
          object IKGridViewILCE: TcxGridDBColumn
            Caption = #304'l'#231'e'
            DataBinding.FieldName = 'ILCEAD'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewIL: TcxGridDBColumn
            Caption = #304'l'
            DataBinding.FieldName = 'ILAD'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewSUBEID: TcxGridDBColumn
            Caption = #350'ube'
            DataBinding.FieldName = 'SUBE'
            DataBinding.IsNullValueType = True
            Width = 100
          end
          object IKGridViewDURUMAD: TcxGridDBColumn
            Caption = 'Durum'
            DataBinding.FieldName = 'DURUMAD'
            DataBinding.IsNullValueType = True
            Visible = False
            Width = 47
          end
          object IKGridViewOZELKOD: TcxGridDBColumn
            Caption = #214'zel Kod'
            DataBinding.FieldName = 'OZELKOD'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewNOTLAR: TcxGridDBColumn
            Caption = 'Notlar'
            DataBinding.FieldName = 'NOTLAR'
            DataBinding.IsNullValueType = True
          end
          object IKGridViewBAGID: TcxGridDBColumn
            Caption = 'Statu'
            DataBinding.FieldName = 'BAGID'
            DataBinding.IsNullValueType = True
            RepositoryItem = Tablo.RepIKStatu
          end
        end
        object IKGridLevel1: TcxGridLevel
          GridView = IKGridView
        end
      end
      object SQL_IK_Memo: TcxMemo
        Left = -8
        Top = 50
        Lines.Strings = (
          'declare @ILGILIARAMA INT'
          'SET @ILGILIARAMA = :P1'
          ''
          
            'select R.ID,R.KOD,VKNO=(select BILGI from REHBERBILGI where YERI' +
            '=3 AND YER_ID=R.ID  AND SIRA=22)'
          ',ADSOYAD=R.FIRMA,'
          
            'CINSIYET=(select top 1 ANAHTAR from GENINI where BOLUM=-23355 an' +
            'd DEGER=R.STATU and DIL=-1),'
          
            '--DYERI= (select top 1 case when ILCENO<500 then ILADI else ILCE' +
            'ADI end from ILILCE where ILCENO=R.BOLGE),'
          'DYERI= (select top 1 ILADI from ILILCE where ILCENO=R.BOLGE),'
          'UYRUGU= (select top 1 ILADI from ILLER where ILNO=R.ALTBOLGE),'
          'DTARIHI=R.DTARIH,'
          'SEKTOR='#39#39','
          
            'DEPARTMAN=(select top 1 ANAHTAR from GENINI where BOLUM=-2251 an' +
            'd DEGER=ROL.DEPARTMAN and DIL=-1),'
          
            'GOREVI=(SELECT top 1 ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND D' +
            'EGER = ROL.GOREVID AND DIL=-1 ),'
          
            'OGRENIM=(SELECT top 1 ANAHTAR FROM GENINI WHERE BOLUM=-2255 AND ' +
            'DEGER = R.KATEGORI AND DIL=-1 ),'
          
            'GIRISTARIHI=(select top 1 TARIH from PERS_HAREKET where REHBERID' +
            '=R.ID  and TUR=1 ),'
          
            'CIKISTARIHI=(select top 1 TARIH from PERS_HAREKET where REHBERID' +
            '=R.ID  and TUR=99),'
          'ILCEAD=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) '
          
            #9'INNER JOIN REHBERILETISIM RI (nolock) ON RI.REHBERID=R.ID and R' +
            'I.VARSAYILAN=1 '
          
            #9'INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.S' +
            'IRA '
          #9'AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=6),'
          'ILAD=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) '
          
            #9'INNER JOIN REHBERILETISIM RI (nolock) ON RI.REHBERID=R.ID and R' +
            'I.VARSAYILAN=1 '
          
            #9'INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.S' +
            'IRA '#9
          #9'AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=8),'
          'R.SUBEID, SUBE = (select FIRMA from REHBER where ID=R.SUBEID),'
          'R.SUBEID, SUBE = (select FIRMA from REHBER where ID=R.SUBEID),'
          
            'NOTLAR=(Select top 1 GY.YORUM from GOREVYORUM GY where R.ID=GY.G' +
            'OREVID and GY.TUR=11 order by GY.TARIH desc),'
          'R.DURUM,'
          
            'DURUMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2201 and ' +
            'DEGER=R.DURUM and DIL=-1),'
          'R.OZELKOD,R.BAGID'
          'from '
          '    REHBER R '
          '         left outer join ROLLER ROL on R.SINIF=ROL.ID'
          
            '         left outer join REHBER P on R.ID = P.BAGID and P.GRUP=3' +
            '34 and '
          '          1 = CASE WHEN  @ILGILIARAMA = 1 THEN 1'
          #9#9#9#9'   WHEN  @ILGILIARAMA = 0 AND isnull (P.STATU,1) = 1 THEN 1 '
          #9#9'       ELSE 0 END '
          'where '
          'R.ID >0 and R.GRUP=335 '
          ' ')
        Properties.WordWrap = False
        TabOrder = 1
        Visible = False
        Height = 59
        Width = 556
      end
      object SQL_IK_Aday: TcxMemo
        Left = -8
        Top = 99
        Lines.Strings = (
          'declare @ILGILIARAMA INT'
          'SET @ILGILIARAMA = :P1'
          ''
          
            'select distinct R.ID,R.KOD,VKNO=(select BILGI from REHBERBILGI w' +
            'here YERI=3 AND YER_ID=R.ID  AND SIRA=22)'
          ',ADSOYAD=R.FIRMA,'
          
            'CINSIYET=(select top 1 ANAHTAR from GENINI where BOLUM=-23355 an' +
            'd DEGER=R.STATU and DIL=-1),'
          
            '--DYERI= (select top 1 case when ILCENO<500 then ILADI else ILCE' +
            'ADI end from ILILCE where ILCENO=R.BOLGE),'
          'DYERI= (select top 1 ILADI from ILILCE where ILCENO=R.BOLGE),'
          'UYRUGU= (select top 1 ILADI from ILLER where ILNO=R.ALTBOLGE),'
          'DTARIHI=R.DTARIH,'
          
            'SEKTOR=(select top 1 ANAHTAR from GENINI G inner join PERS_DENEY' +
            'IM PD on G.DEGER=PD.SEKTOR and TUR=0  '
          
            '   where PD.REHBERID=R.ID and G.BOLUM=-2204 and G.DIL=-1 order b' +
            'y PD.BASVURUTARIHI desc),'
          
            'DEPARTMAN=(select top 1 ANAHTAR from GENINI G inner join PERS_DE' +
            'NEYIM PD on G.DEGER=PD.DEPARTMAN and TUR=0  '
          
            '   where PD.REHBERID=R.ID and G.BOLUM=-2206 and G.DIL=-1 order b' +
            'y PD.BASVURUTARIHI desc),'
          
            'GOREVI=(SELECT top 1 ANAHTAR FROM GENINI G inner join PERS_DENEY' +
            'IM PD on G.DEGER=PD.GOREV and TUR=0 '
          
            '   where PD.REHBERID=R.ID and G.BOLUM=-2205 AND G.DIL=-1 order b' +
            'y PD.BASVURUTARIHI desc),'
          
            'OGRENIM=(SELECT top 1 ANAHTAR FROM GENINI WHERE BOLUM=-2255 AND ' +
            'DEGER = R.KATEGORI AND DIL=-1 ),'
          
            'GIRISTARIHI=(select top 1 BASVURUTARIHI from PERS_DENEYIM where ' +
            'REHBERID=R.ID  and TUR=0 order by BASVURUTARIHI desc),'
          
            'CIKISTARIHI=(select top 1 BASLAMATARIHI from PERS_DENEYIM where ' +
            'REHBERID=R.ID  and TUR=0 order by BASVURUTARIHI desc),'
          
            'ILCEAD=(select top 1 ILCEADI from PERS_DENEYIM PD inner join ILI' +
            'LCE II on PD.IL=II.ILNO and PD.ILCE=II.ILCENO where REHBERID=R.I' +
            'D  and TUR=0 order by BASVURUTARIHI desc),'
          
            'ILAD=(select top 1 ILADI from PERS_DENEYIM PD inner join ILILCE ' +
            'II on PD.IL=II.ILNO and PD.ILCE=II.ILCENO where REHBERID=R.ID  a' +
            'nd TUR=0 order by BASVURUTARIHI desc),'
          'R.SUBEID, SUBE = (select FIRMA from REHBER where ID=R.SUBEID),'
          
            'NOTLAR=(Select top 1 GY.YORUM from GOREVYORUM GY where R.ID=GY.G' +
            'OREVID and GY.TUR=11 order by GY.TARIH desc),'
          'R.DURUM,'
          
            'DURUMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2201 and ' +
            'DEGER=R.DURUM and DIL=-1),'
          'R.OZELKOD,R.BAGID'
          'from '
          '    REHBER R '
          '         left outer join ROLLER ROL on R.SINIF=ROL.ID'
          
            '         left outer join REHBER P on R.ID = P.BAGID and P.GRUP=3' +
            '34 and '
          ''
          '          1 = CASE WHEN  @ILGILIARAMA = 1 THEN 1'
          #9#9#9#9'   WHEN  @ILGILIARAMA = 0 AND isnull (P.STATU,1) = 1 THEN 1 '
          #9#9'       ELSE 0 END '
          
            '            left outer join PERS_DENEYIM PD on R.ID = PD.REHBERI' +
            'D   '
          'where '
          'R.ID >0 and R.GRUP=5')
        Properties.WordWrap = False
        TabOrder = 2
        Visible = False
        Height = 59
        Width = 556
      end
      object PageControlSekme: TcxPageControl
        Left = 0
        Top = 268
        Width = 962
        Height = 259
        Align = alBottom
        TabOrder = 3
        Properties.Images = Tablo.PNGImageList2
        Properties.ActivePage = TabSheetIlet
        Properties.CustomButtons.Buttons = <>
        OnChange = PageControlSekmeChange
        ClientRectBottom = 255
        ClientRectLeft = 4
        ClientRectRight = 958
        ClientRectTop = 27
        object TabSheetIlet: TcxTabSheet
          Caption = #304'leti'#351'im'
          ImageIndex = 33
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object ToolBar10: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 948
            Height = 41
            Margins.Bottom = 0
            AutoSize = True
            ButtonHeight = 39
            ButtonWidth = 46
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
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 0
            Transparent = True
            object iletisimEkle: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = iletisimEkleClick
            end
            object iletisimSil: TToolButton
              Left = 46
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = iletisimSilClick
            end
            object ToolButton14: TToolButton
              Left = 92
              Top = 0
              Width = 8
              Caption = 'ToolButton14'
              ImageIndex = 10
              ImageName = 'PngImage10'
              Style = tbsSeparator
            end
            object iletisimDuzenle: TToolButton
              Left = 100
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              OnClick = iletisimDuzenleClick
            end
          end
          object cxGrid7: TcxGrid
            Left = 160
            Top = 44
            Width = 609
            Height = 184
            Align = alClient
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            TabOrder = 2
            LookAndFeel.Kind = lfStandard
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object cxGridDBTableView5: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsFirIletisim
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.GridLines = glNone
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              Styles.Background = cxStyle2
              Styles.Content = cxStyle2
              Styles.Header = cxStyle2
              Styles.Inactive = cxStyle2
              object cxGridDBColumn10: TcxGridDBColumn
                Caption = 'T'#252'r'#252
                DataBinding.FieldName = 'ETIKET'
                DataBinding.IsNullValueType = True
                MinWidth = 100
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Options.Sorting = False
                Width = 100
              end
              object cxGridDBColumn11: TcxGridDBColumn
                Caption = 'Bilgisi'
                DataBinding.FieldName = 'BILGI'
                DataBinding.IsNullValueType = True
                MinWidth = 470
                Options.Editing = False
                Options.Filtering = False
                Options.Focusing = False
                Options.IgnoreTimeForFiltering = False
                Options.IncSearch = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.ShowCaption = False
                Options.Sorting = False
                Width = 470
              end
            end
            object cxGridLevel12: TcxGridLevel
              GridView = cxGridDBTableView5
            end
          end
          object GridRehberIletisim: TcxGrid
            Left = 0
            Top = 44
            Width = 160
            Height = 184
            Align = alLeft
            PopupMenu = PopupIletisim
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridRehberIletisimView: TcxGridDBTableView
              OnDblClick = iletisimDuzenleClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnSelectionChanged = GridRehberIletisimViewSelectionChanged
              DataController.DataSource = DtsRehberIletisim
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsSelection.MultiSelect = True
              OptionsView.GroupByBox = False
              Styles.Background = cxStyle2
              Styles.Content = cxStyle2
              Styles.Inactive = cxStyle2
              object cxGridDBColumn1: TcxGridDBColumn
                Caption = 'Var.'
                DataBinding.FieldName = 'VARSAYILAN'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ReadOnly = True
                Visible = False
                Options.Editing = False
                Width = 30
              end
              object cxGridDBColumn2: TcxGridDBColumn
                Caption = 'Ad'#305
                DataBinding.FieldName = 'AD'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 119
              end
              object cxGridDBColumn12: TcxGridDBColumn
                DataBinding.FieldName = 'AKTIF'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Kurumda'
                    Value = '1'
                  end
                  item
                    Description = 'Ta'#351#305'nd'#305
                    ImageIndex = 12
                    Value = '2'
                  end
                  item
                    Description = 'Ayr'#305'ld'#305
                    ImageIndex = 10
                    Value = '3'
                  end>
                Properties.ShowDescriptions = False
                Width = 32
                IsCaptionAssigned = True
              end
            end
            object cxGridLevel13: TcxGridLevel
              GridView = GridRehberIletisimView
            end
          end
          object PanelFiyatAltSag: TPanel
            Left = 769
            Top = 44
            Width = 185
            Height = 184
            Align = alRight
            Caption = 'PanelFiyatAltSag'
            TabOrder = 3
            object ToolBar7: TToolBar
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 177
              Height = 24
              Margins.Bottom = 0
              AutoSize = True
              ButtonWidth = 75
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
              object ResimYapistirTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yap'#305#351't'#305'r'
                ImageIndex = 10
                ImageName = 'PngImage10'
                OnClick = ResimYapistirTusClick
              end
              object ToolButton3: TToolButton
                Left = 75
                Top = 0
                Width = 8
                Caption = 'ToolButton6'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Style = tbsSeparator
              end
              object ResimDosyadanTus: TToolButton
                Left = 83
                Top = 0
                Caption = 'Dosyadan'
                ImageIndex = 4
                ImageName = 'PngImage4'
                OnClick = ResimDosyadanTusClick
              end
            end
            object LogoResim: TcxDBImage
              Left = 1
              Top = 28
              HelpType = htKeyword
              Align = alClient
              DataBinding.DataField = 'RESIM'
              DataBinding.DataSource = DtsResim
              Properties.Caption = 'Resim s'#252'r'#252'kleyip buraya b'#305'rak'#305'n'
              Properties.GraphicClassName = 'TdxSmartImage'
              Style.BorderColor = clBtnFace
              Style.Color = clBtnFace
              Style.Edges = []
              StyleDisabled.BorderStyle = ebsNone
              StyleFocused.BorderStyle = ebsNone
              TabOrder = 1
              OnClick = LogoResimClick
              Height = 155
              Width = 183
            end
          end
        end
        object TabSheetIlgili: TcxTabSheet
          Caption = #304'lgililer'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Trebuchet MS'
          Font.Style = []
          ImageIndex = 35
          ParentFont = False
          object cxGrid2: TcxGrid
            Left = 0
            Top = 41
            Width = 234
            Height = 187
            Align = alLeft
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object cxGridPersoneller: TcxGridDBTableView
              OnDblClick = IlgiliDuzenleTusClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnSelectionChanged = cxGridPersonellerSelectionChanged
              DataController.DataSource = DtsRehberIlgili
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsSelection.MultiSelect = True
              OptionsView.GroupByBox = False
              Styles.Background = cxStyle2
              Styles.Content = cxStyle2
              Styles.Inactive = cxStyle2
              object PersonelVARSAYILAN: TcxGridDBColumn
                Caption = 'Var.'
                DataBinding.FieldName = 'VARSAYILAN'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxCheckBoxProperties'
                Properties.ReadOnly = True
                Visible = False
                Options.Editing = False
                Width = 30
              end
              object PersonelAdi: TcxGridDBColumn
                Caption = 'Ad'#305' Soyad'#305
                DataBinding.FieldName = 'FIRMA'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Width = 166
              end
              object PersonelNEREDE: TcxGridDBColumn
                DataBinding.FieldName = 'NEREDE'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Kurumda'
                    Value = '1'
                  end
                  item
                    Description = 'Ta'#351#305'nd'#305
                    ImageIndex = 12
                    Value = '2'
                  end
                  item
                    Description = 'Ayr'#305'ld'#305
                    ImageIndex = 10
                    Value = '3'
                  end>
                Properties.ShowDescriptions = False
                Width = 32
                IsCaptionAssigned = True
              end
            end
            object cxGridLevel1: TcxGridLevel
              GridView = cxGridPersoneller
            end
          end
          object Panel2: TPanel
            Left = 234
            Top = 41
            Width = 720
            Height = 187
            Align = alClient
            TabOrder = 1
            object GridPerIlet: TcxGrid
              Left = 1
              Top = 25
              Width = 352
              Height = 161
              Align = alLeft
              BevelEdges = []
              BevelInner = bvNone
              BevelOuter = bvNone
              TabOrder = 1
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridPerIletView: TcxGridDBTableView
                OnDblClick = IlgiliDuzenleTusClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsPerIletisim
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsView.ColumnAutoWidth = True
                OptionsView.GridLines = glNone
                OptionsView.GroupByBox = False
                OptionsView.Header = False
                Styles.Background = cxStyle2
                Styles.Content = cxStyle2
                Styles.Header = cxStyle2
                Styles.Inactive = cxStyle2
                object GridPerIletViewTUR: TcxGridDBColumn
                  Caption = 'T'#252'r'#252
                  DataBinding.FieldName = 'ETIKET'
                  DataBinding.IsNullValueType = True
                  MinWidth = 75
                  Options.Editing = False
                  Options.Filtering = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Options.ShowCaption = False
                  Options.Sorting = False
                  Width = 75
                end
                object GridPerIletViewBILGI: TcxGridDBColumn
                  Caption = 'Bilgisi'
                  DataBinding.FieldName = 'BILGI'
                  DataBinding.IsNullValueType = True
                  MinWidth = 250
                  Options.Editing = False
                  Options.Filtering = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Options.ShowCaption = False
                  Options.Sorting = False
                  Width = 250
                end
              end
              object cxGridLevel3: TcxGridLevel
                GridView = GridPerIletView
              end
            end
            object Panel3: TPanel
              Left = 1
              Top = 1
              Width = 718
              Height = 24
              Align = alTop
              TabOrder = 0
              object cxLabel5: TcxLabel
                Left = 3
                Top = 1
                Caption = #304'leti'#351'im Bilgileri'
                Transparent = True
              end
              object cxLabel1: TcxLabel
                Left = 350
                Top = 1
                Caption = 'Resimleri'
                Transparent = True
              end
              object ResimDuzenleTus: TcxButton
                Left = 410
                Top = 0
                Width = 75
                Height = 22
                Caption = 'D'#252'zenle'
                TabOrder = 0
                OnClick = ResimDuzenleTusClick
              end
            end
            object Resim: TcxImage
              Left = 353
              Top = 25
              Align = alClient
              Properties.Caption = 'Resim i'#231'in t'#305'klay'#305'n'
              Properties.Center = False
              Properties.ReadOnly = True
              Style.Color = clBtnFace
              Style.Edges = []
              TabOrder = 2
              Height = 161
              Width = 366
            end
          end
          object Panel9: TPanel
            Left = 0
            Top = 0
            Width = 954
            Height = 41
            Align = alTop
            Caption = 'Panel9'
            TabOrder = 2
            object ToolBar2: TToolBar
              Left = 1
              Top = 1
              Width = 146
              Height = 39
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 46
              Caption = 'AletCubugu'
              Color = clTeal
              Ctl3D = False
              DockSite = True
              DrawingStyle = dsGradient
              EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
              EdgeInner = esNone
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
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object IlgiliEkleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = IlgiliEkleTusClick
              end
              object IlgiliSilTus: TToolButton
                Left = 46
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = IlgiliSilTusClick
              end
              object ToolButton6: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton6'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Style = tbsSeparator
              end
              object IlgiliDuzenleTus: TToolButton
                Left = 100
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = IlgiliDuzenleTusClick
              end
            end
            object JvNavPanelHeader5: TJvNavPanelHeader
              Left = 147
              Top = 1
              Width = 806
              Height = 39
              Align = alClient
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -16
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
              ColorFrom = 14540253
              ColorTo = 11776947
              ImageIndex = 0
            end
          end
        end
        object TabYorumMedya: TcxTabSheet
          Caption = 'Yorum/Medya'
          ImageIndex = 38
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Panel7: TPanel
            Left = 0
            Top = 187
            Width = 954
            Height = 41
            Align = alBottom
            TabOrder = 0
            object MemoChat: TcxRichEdit
              Left = 1
              Top = 1
              Align = alClient
              Properties.ScrollBars = ssVertical
              TabOrder = 2
              Height = 39
              Width = 806
            end
            object BtnMesajGonder: TcxButton
              Left = 807
              Top = 1
              Width = 85
              Height = 39
              Align = alRight
              OptionsImage.ImageIndex = 39
              OptionsImage.Images = Tablo.cxImageList1
              TabOrder = 0
              OnClick = BtnMesajGonderClick
            end
            object BtnDosyaGonder: TcxButton
              Left = 892
              Top = 1
              Width = 61
              Height = 39
              Align = alRight
              DropDownMenu = YorumAtacMenu
              Kind = cxbkDropDown
              OptionsImage.ImageIndex = 38
              OptionsImage.Images = Tablo.cxImageList1
              TabOrder = 1
            end
          end
          object labelFileName: TcxLabel
            Left = 0
            Top = 167
            ParentCustomHint = False
            Align = alBottom
            ParentColor = False
            ParentFont = False
            ParentShowHint = False
            ShowHint = False
            Style.Edges = [bLeft, bRight]
            Style.Font.Charset = TURKISH_CHARSET
            Style.Font.Color = clWindowText
            Style.Font.Height = -11
            Style.Font.Name = 'Trebuchet MS'
            Style.Font.Style = []
            Style.Shadow = False
            Style.IsFontAssigned = True
            Properties.Alignment.Horz = taRightJustify
            Transparent = True
            Visible = False
            ExplicitTop = 166
            AnchorX = 954
          end
          object GridYorum: TcxGrid
            Left = 0
            Top = 0
            Width = 954
            Height = 167
            Align = alClient
            TabOrder = 2
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridYorumDBCardView1: TcxGridDBCardView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCellDblClick = GridYorumDBCardView1CellDblClick
              DataController.DataSource = DtsYorum
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              LayoutDirection = ldVertical
              OptionsView.CardBorderWidth = 1
              OptionsView.CardIndent = 2
              OptionsView.CardWidth = 900
              OptionsView.CategoryIndent = 1
              OptionsView.CategorySeparatorWidth = 1
              OptionsView.CellAutoHeight = True
              OptionsView.CellTextMaxLineCount = 5
              Styles.Content = Tablo.cxStyle6
              Styles.CardBorder = Tablo.cxStyle19
              object GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow
                DataBinding.FieldName = 'EKLEMETARIHI'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = True
                Position.Width = 120
              end
              object GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow
                DataBinding.FieldName = 'YAZAN'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = False
              end
              object GridYorumDBCardViewATAC: TcxGridDBCardViewRow
                DataBinding.FieldName = 'ATAC'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.repFileExtensionList
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = False
                Position.Width = 25
                IsCaptionAssigned = True
              end
              object GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow
                DataBinding.FieldName = 'DOKUMANAD'
                DataBinding.IsNullValueType = True
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = False
                Position.Width = 300
                IsCaptionAssigned = True
              end
              object GridYorumDBCardView1YORUM: TcxGridDBCardViewRow
                DataBinding.FieldName = 'YORUM'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxRichEditProperties'
                Options.Editing = False
                Options.Focusing = False
                Options.ShowCaption = False
                Position.BeginsLayer = True
                Styles.Content = Tablo.cxStyle12
                Styles.CategoryRow = Tablo.cxStyle4
              end
            end
            object GridYorumLevel1: TcxGridLevel
              GridView = GridYorumDBCardView1
            end
          end
        end
        object TabSheetGorev: TcxTabSheet
          Caption = #304#351' Listesi'
          ImageIndex = 54
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object SQLGorevMemo: TcxMemo
            Left = 75
            Top = 46
            Lines.Strings = (
              
                'select   G.*,GL.ID, LISTEADI=GL.ADI,CARIAD=(SELECT FIRMA FROM RE' +
                'HBER R WHERE R.ID=G.REHBERID),'
              
                'ATANAN1=(SELECT FIRMA FROM REHBER R WHERE R.ID = (SELECT TOP 1 R' +
                'EHBERID FROM GOREVKULLANICI GK WHERE '
              'GK.LISTGOREVID=G.ID AND GK.TUR=11))'
              'from GOREVLER G'
              'inner join GOREVLISTE GL on GL.ID=G.LISTEID')
            TabOrder = 0
            Visible = False
            Height = 43
            Width = 705
          end
          object TreeListGorev: TcxDBTreeList
            Left = 0
            Top = 41
            Width = 954
            Height = 187
            Align = alClient
            Bands = <
              item
              end>
            DataController.DataSource = DtsGorevler
            DataController.ParentField = 'BAGIDUST'
            DataController.KeyField = 'ID'
            DragMode = dmAutomatic
            Images = Tablo.KlasorResimleri
            LookAndFeel.ScrollbarMode = sbmClassic
            Navigator.Buttons.CustomButtons = <>
            OptionsCustomizing.ColumnsQuickCustomization = True
            OptionsData.Editing = False
            OptionsData.Deleting = False
            OptionsSelection.MultiSelect = True
            OptionsView.GridLines = tlglBoth
            OptionsView.Indicator = True
            OptionsView.TreeLineStyle = tllsNone
            PopupMenu = GorevlerMenu
            PopupMenus.ColumnHeaderMenu.PopupMenu = AnaForm.PopupMenuTree
            RootValue = -1
            ScrollbarAnnotations.CustomAnnotations = <>
            TabOrder = 1
            OnClick = TreeListGorevClick
            OnDblClick = TreeListGorevDblClick
            object TreeListEkipmancxDBTreeListID: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'ID'
              Width = 100
              Position.ColIndex = 8
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListACKAPA: TcxDBTreeListColumn
              Tag = 1
              PropertiesClassName = 'TcxCheckBoxProperties'
              Caption.Glyph.SourceDPI = 96
              Caption.Glyph.Data = {
                424D360400000000000036000000280000001000000010000000010020000000
                000000000000C40E0000C40E0000000000000000000000000000000000000000
                000000000002000000070000000C0000001000000012000000110000000E0000
                0008000000020000000000000000000000000000000000000000000000010000
                0004000101120D2A1D79184E36C6216B4BFF216B4BFF216C4BFF1A533AD20F2F
                218400010115000000050000000100000000000000000000000000000005050F
                0A351C5B40DC24805CFF29AC7EFF2CC592FF2DC894FF2DC693FF2AAE80FF2585
                60FF1A563DD405110C3D00000007000000010000000000000003040E0A312065
                48ED299D74FF2FC896FF2EC996FF56D4ACFF68DAB5FF3BCD9DFF30C996FF32CA
                99FF2BA479FF227050F805110C3D00000005000000000000000A1A573DD02EA5
                7CFF33CA99FF2EC896FF4CD2A8FF20835CFF00673BFF45BE96FF31CB99FF31CB
                98FF34CC9CFF31AD83FF1B5C41D300010113000000020B23185E2E8A66FF3BCD
                9EFF30CA97FF4BD3A9FF349571FF87AF9DFFB1CFC1FF238A60FF45D3A8FF36CF
                9FFF33CD9BFF3ED0A3FF319470FF0F32237F00000007184D37B63DB38CFF39CD
                9FFF4BD5A9FF43A382FF699782FFF8F1EEFFF9F3EEFF357F5DFF56C4A1FF43D5
                A8FF3ED3A4FF3CD1A4FF41BC95FF1B5C43CD0000000B1C6446DF4BCAA4FF44D2
                A8FF4FB392FF4E826AFFF0E9E6FFC0C3B5FFEFE3DDFFCEDDD4FF1B754FFF60DC
                B8FF48D8ACFF47D6AAFF51D4ACFF247A58F80000000E217050F266D9B8FF46D3
                A8FF0B6741FFD2D2CBFF6A8F77FF116B43FF73967EFFF1E8E3FF72A28BFF46A6
                85FF5EDFBAFF4CD9AFFF6BE2C2FF278460FF020604191E684ADC78D9BEFF52DA
                B1FF3DBA92FF096941FF2F9C76FF57DEB8FF2D9973FF73967EFFF0EAE7FF4F88
                6CFF5ABB9AFF5BDEB9FF7FE2C7FF27835FF80000000C19523BAB77C8B0FF62E0
                BCFF56DDB7FF59DFBAFF5CE1BDFF5EE2BEFF5FE4C1FF288C67FF698E76FFE6E1
                DCFF176B47FF5FD8B4FF83D5BDFF1E674CC60000000909201747439C7BFF95EC
                D6FF5ADFBAFF5EE2BDFF61E4BFFF64E6C1FF67E6C5FF67E8C7FF39A17EFF1F6D
                4AFF288B64FF98EFD9FF4DAC8CFF1036286D00000004000000041C5F46B578C6
                ADFF9AEED9FF65E5C0FF64E7C3FF69E7C6FF6BE8C8FF6CE9C9FF6BEAC9FF5ED6
                B6FF97EDD7FF86D3BBFF237759D20102010C0000000100000001030A0718247B
                5BDA70C1A8FFB5F2E3FF98F0DAFF85EDD4FF75EBCEFF88EFD6FF9CF2DDFFBAF4
                E7FF78CDB3FF2A906DEA0615102E00000002000000000000000000000001030A
                07171E694FB844AB87FF85D2BBFFA8E6D6FFC5F4EBFFABE9D8FF89D8C1FF4BB6
                92FF237F60CB05130E2700000003000000000000000000000000000000000000
                0001000000030A241B411B60489D258464CF2C9D77EE258867CF1F7156B00E32
                26560000000600000002000000000000000000000000}
              Caption.ShowEndEllipsis = False
              Caption.Text = '*'
              DataBinding.FieldName = 'ACKAPA'
              Options.Editing = False
              Width = 61
              Position.ColIndex = 0
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListLISTEADI: TcxDBTreeListColumn
              Caption.Text = 'L'#304'STE'
              DataBinding.FieldName = 'LISTEADI'
              Options.Editing = False
              Width = 62
              Position.ColIndex = 1
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListKONUSU: TcxDBTreeListColumn
              DataBinding.FieldName = 'KONUSU'
              Options.Editing = False
              Width = 139
              Position.ColIndex = 2
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListTURU: TcxDBTreeListColumn
              Caption.Text = 'T'#220'R'#220
              DataBinding.FieldName = 'TURU'
              Options.Editing = False
              Width = 65
              Position.ColIndex = 3
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListCARIAD: TcxDBTreeListColumn
              Caption.Text = 'CAR'#304' AD'
              DataBinding.FieldName = 'CARIAD'
              Options.Editing = False
              Width = 100
              Position.ColIndex = 4
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListATANAN1: TcxDBTreeListColumn
              Caption.Text = 'ATANAN'
              DataBinding.FieldName = 'ATANAN1'
              Options.Editing = False
              Width = 100
              Position.ColIndex = 5
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListTARIH: TcxDBTreeListColumn
              PropertiesClassName = 'TcxDateEditProperties'
              Caption.Text = 'TAR'#304'H'
              DataBinding.FieldName = 'BITISTARIHI'
              Options.Editing = False
              Width = 100
              Position.ColIndex = 6
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListNOTLAR_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 27
                  Value = True
                end>
              Caption.Glyph.SourceDPI = 96
              Caption.Glyph.Data = {
                424D360400000000000036000000280000001000000010000000010020000000
                000000000000C40E0000C40E0000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000200000
                002100000023000000240000002600000027000000290000002A0000002C0000
                002D0000002F0000003100000032000000340000000000000000000000140000
                00150000001600000017000000190000001A0000001B0000001D0000001E0000
                0020000000210000002300000024000000260000000000000000000000090000
                000A0000000B0000000C0000000E0000000F0000001000000011000000120000
                0014000000150000001600000017000000190000000000000000000000000000
                000000000000000000040000000F000000110000000B00000004000000010000
                0000000000000000000000000000000000000000000000000000402A1FFF402A
                1FFF3E291FFF0000000E421C11FF31140CE1190A0698030407420000000C0000
                0002000000000000000000000000000000000000000000000000422B20FF0000
                0000000000000000000D663C2BDCB9C7D2FF7889A2FF244182FF051033960000
                000F000000020000000000000000000000000000000000000000442D22FF0000
                0000000000000000000841261B91879AB2FFC8E3F5FF1F66B6FF2B6BA8FF0512
                36950000000E0000000200000000000000000000000000000000452E23FF0000
                000000000000000000031113163E488BC3FFDEFEFDFF51B4E3FF1F68B7FF3173
                AEFF061538940000000D00000002000000000000000000000000483022FF0000
                00000000000000000001000000081D44618D479FD2FFDEFEFDFF59BFE9FF216B
                B9FF367BB3FF07173A920000000C000000020000000000000000493224FF0000
                0000000000000000000000000001000000091D44618C4BA5D5FFDEFEFDFF61CA
                EFFF246FBCFF3B83B9FF08193D900000000A00000002000000004A3225FF0000
                000000000000000000000000000000000001000000081D44618A4EAAD7FFDEFE
                FDFF68D4F4FF2875BEFF3F8BBEFF091B3F8E00000006000000004C3426FF4B33
                26FF4B3225FF4A3225FF493225FF483124FF483124FF000000071C44618951AE
                DAFFDEFEFDFF6EDDF8FF2C7BC2FF18448BFF0000000800000000000000000000
                0000000000000000000000000000000000000000000000000001000000061D44
                618754B1DCFFDEFEFDFF4FA6D4FF112B4E880000000400000000000000000000
                0000000000000000000000000000000000000000000000000000000000010000
                00051D456185357FBCFF173A5986000000050000000100000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00010000000200000004000000030000000100000000}
              Caption.Text = 'N'
              DataBinding.FieldName = 'NOTLAR_BIT'
              Width = 22
              Position.ColIndex = 7
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListYORUM_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 26
                  Value = True
                end>
              Caption.Text = 'Y'
              DataBinding.FieldName = 'YORUM_BIT'
              Width = 22
              Position.ColIndex = 9
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListTEKRAR_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 20
                  Value = True
                end>
              Caption.Text = 'T'
              DataBinding.FieldName = 'TEKRAR_BIT'
              Width = 22
              Position.ColIndex = 10
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListANIMSAT_BIT: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 23
                  Value = True
                end>
              Caption.Text = 'A'
              DataBinding.FieldName = 'ANIMSAT_BIT'
              Width = 22
              Position.ColIndex = 11
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListBAYRAK: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Images = Tablo.KlasorResimleri
              Properties.Items = <
                item
                  Value = False
                end
                item
                  ImageIndex = 21
                  Value = True
                end>
              Caption.Text = 'B'
              DataBinding.FieldName = 'BAYRAK'
              Width = 22
              Position.ColIndex = 12
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListDURUM: TcxDBTreeListColumn
              PropertiesClassName = 'TcxImageComboBoxProperties'
              Properties.Items = <>
              RepositoryItem = Tablo.RepGorevDurum
              DataBinding.FieldName = 'DURUM'
              Width = 100
              Position.ColIndex = 13
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListPROJEKODU: TcxDBTreeListColumn
              DataBinding.FieldName = 'PROJEKODU'
              Width = 100
              Position.ColIndex = 14
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListEKLEYENAD: TcxDBTreeListColumn
              DataBinding.FieldName = 'EKLEYENAD'
              Width = 100
              Position.ColIndex = 15
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListEkipmancxDBTreeListEKLEMETARIHI: TcxDBTreeListColumn
              PropertiesClassName = 'TcxDateEditProperties'
              DataBinding.FieldName = 'EKLEMETARIHI'
              Width = 100
              Position.ColIndex = 16
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListGorevcxDBTreeListEKLEYEN: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'EKLEYEN'
              Position.ColIndex = 17
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
            object TreeListGorevcxDBTreeListLISTEID: TcxDBTreeListColumn
              Visible = False
              DataBinding.FieldName = 'LISTEID'
              Position.ColIndex = 18
              Position.RowIndex = 0
              Position.BandIndex = 0
              Summary.FooterSummaryItems = <>
              Summary.GroupFooterSummaryItems = <>
            end
          end
          object Panel11: TPanel
            Left = 0
            Top = 0
            Width = 954
            Height = 41
            Align = alTop
            Caption = 'Panel9'
            TabOrder = 2
            object ToolBar12: TToolBar
              Left = 1
              Top = 1
              Width = 146
              Height = 39
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 46
              Caption = 'AletCubugu'
              Color = clTeal
              Ctl3D = False
              DockSite = True
              DrawingStyle = dsGradient
              EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
              EdgeInner = esNone
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
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object GorevEkleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                ImageIndex = 0
                ImageName = 'PngImage0'
                OnClick = GorevEkleTusClick
              end
              object GorevSilTus: TToolButton
                Left = 46
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = GorevSilTusClick
              end
              object ToolButton19: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton6'
                ImageIndex = 2
                ImageName = 'PngImage2'
                Style = tbsSeparator
              end
              object GorevDuzenleTus: TToolButton
                Left = 100
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = TreeListGorevDblClick
              end
            end
            object JvNavPanelHeader6: TJvNavPanelHeader
              Left = 147
              Top = 1
              Width = 806
              Height = 39
              Align = alClient
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -16
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
              ColorFrom = 14540253
              ColorTo = 11776947
              ImageIndex = 0
              object CheckTamamlanan: TcxCheckBox
                Left = 47
                Top = 12
                Caption = 'Tamamlananlar'#305' da g'#246'ster'
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 0
                Transparent = True
                OnClick = CheckTamamlananClick
              end
              object ComboTamamlanan: TcxImageComboBox
                Left = 229
                Top = 12
                RepositoryItem = Tablo.RepGorevSonKac
                Properties.Items = <>
                Properties.OnEditValueChanged = CheckTamamlananClick
                Style.Color = clSilver
                TabOrder = 1
                Visible = False
                Width = 115
              end
            end
          end
        end
        object TabSheetOzluk: TcxTabSheet
          Caption = #214'zl'#252'k Bilgileri'
          ImageIndex = 19
          object PanelOzluk: TPanel
            Left = 0
            Top = 0
            Width = 401
            Height = 228
            Align = alLeft
            Caption = 'PanelOzluk'
            TabOrder = 0
            object GridPerTemel: TcxGrid
              Left = 1
              Top = 45
              Width = 399
              Height = 182
              Align = alClient
              BevelEdges = []
              BevelInner = bvNone
              BevelOuter = bvNone
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridPerTemelView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCanFocusRecord = GridPerTemelViewCanFocusRecord
                DataController.DataSource = DtsPerTemel
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
                OptionsView.ColumnAutoWidth = True
                OptionsView.GridLines = glNone
                OptionsView.GroupByBox = False
                OptionsView.Header = False
                OptionsView.Indicator = True
                Styles.Background = cxStyle2
                Styles.Content = cxStyle2
                Styles.OnGetContentStyle = GridPerTemelViewStylesGetContentStyle
                Styles.Header = cxStyle2
                Styles.Inactive = cxStyle2
                object cxGridDBColumn5: TcxGridDBColumn
                  Caption = 'T'#252'r'#252
                  DataBinding.FieldName = 'ETIKET'
                  DataBinding.IsNullValueType = True
                  MinWidth = 75
                  Options.Editing = False
                  Options.Filtering = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Options.ShowCaption = False
                  Options.Sorting = False
                  Width = 75
                end
                object cxGridDBColumn6: TcxGridDBColumn
                  Caption = 'Bilgisi'
                  DataBinding.FieldName = 'BILGI'
                  DataBinding.IsNullValueType = True
                  MinWidth = 250
                  Options.Editing = False
                  Options.Filtering = False
                  Options.Focusing = False
                  Options.IgnoreTimeForFiltering = False
                  Options.IncSearch = False
                  Options.FilteringFilteredItemsList = False
                  Options.FilteringMRUItemsList = False
                  Options.FilteringPopup = False
                  Options.FilteringPopupMultiSelect = False
                  Options.GroupFooters = False
                  Options.Grouping = False
                  Options.HorzSizing = False
                  Options.Moving = False
                  Options.ShowCaption = False
                  Options.Sorting = False
                  Width = 250
                end
              end
              object cxGridLevel6: TcxGridLevel
                GridView = GridPerTemelView
              end
            end
            object ToolBar6: TToolBar
              AlignWithMargins = True
              Left = 4
              Top = 4
              Width = 393
              Height = 41
              Margins.Bottom = 0
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 79
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
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 1
              Transparent = True
              object OzlukDuzenleTus: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni / D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = OzlukDuzenleTusClick
              end
              object cxLabel3: TcxLabel
                Left = 79
                Top = 0
                Align = alClient
                AutoSize = False
                Caption = '     '#214'zl'#252'k Bilgileri'
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clNavy
                Style.Font.Height = -16
                Style.Font.Name = 'Arial Black'
                Style.Font.Style = [fsBold, fsItalic]
                Style.TextColor = clRed
                Style.IsFontAssigned = True
                Transparent = True
                Height = 39
                Width = 309
              end
            end
          end
          object Panel4: TPanel
            Left = 401
            Top = 0
            Width = 553
            Height = 228
            Align = alClient
            Caption = 'PanelKesinti'
            TabOrder = 1
            object Panel6: TPanel
              Left = 1
              Top = 1
              Width = 551
              Height = 35
              Align = alTop
              Caption = 'Panel6'
              TabOrder = 0
              object ToolBar5: TToolBar
                Left = 1
                Top = 1
                Width = 176
                Height = 33
                Margins.Bottom = 0
                Align = alLeft
                AutoSize = True
                ButtonHeight = 39
                ButtonWidth = 42
                Caption = 'AletCubugu'
                Color = clTeal
                Ctl3D = False
                DockSite = True
                DrawingStyle = dsGradient
                EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
                EdgeInner = esNone
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
                ParentColor = False
                ParentFont = False
                ShowCaptions = True
                TabOrder = 0
                Transparent = True
                object DilEkleTus: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'Yeni'
                  ImageIndex = 0
                  ImageName = 'PngImage0'
                  OnClick = DilEkleTusClick
                end
                object DilSilTus: TToolButton
                  Left = 42
                  Top = 0
                  Caption = 'Sil'
                  ImageIndex = 1
                  ImageName = 'PngImage1'
                  OnClick = DilSilTusClick
                end
                object ToolButton17: TToolButton
                  Left = 84
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton7'
                  ImageIndex = 8
                  ImageName = 'PngImage15'
                  Style = tbsSeparator
                end
                object DilKaydetTus: TToolButton
                  Left = 92
                  Top = 0
                  Caption = 'Kaydet'
                  ImageIndex = 2
                  ImageName = 'PngImage2'
                  Visible = False
                  OnClick = DilKaydetTusClick
                end
                object DilIptalTus: TToolButton
                  Left = 134
                  Top = 0
                  Caption = #304'ptal'
                  ImageIndex = 3
                  ImageName = 'PngImage3'
                  Visible = False
                  OnClick = DilIptalTusClick
                end
              end
              object JvNavPanelHeader3: TJvNavPanelHeader
                Left = 177
                Top = 1
                Width = 373
                Height = 33
                Align = alClient
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWhite
                Font.Height = -16
                Font.Name = 'Arial'
                Font.Style = [fsBold]
                ParentFont = False
                ColorFrom = 14540253
                ColorTo = 11776947
                ImageIndex = 0
              end
            end
            object cxLabel11: TcxLabel
              Left = 391
              Top = 7
              AutoSize = False
              Caption = 'Yabanc'#305' Dilleri'
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clNavy
              Style.Font.Height = -16
              Style.Font.Name = 'Arial Black'
              Style.Font.Style = [fsBold, fsItalic]
              Style.TextColor = clRed
              Style.IsFontAssigned = True
              Transparent = True
              Height = 27
              Width = 194
            end
            object GridDil: TcxGrid
              Left = 1
              Top = 36
              Width = 551
              Height = 191
              Align = alClient
              TabOrder = 2
              LookAndFeel.NativeStyle = True
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridDilView: TcxGridDBTableView
                OnDblClick = GridKesintiViewDblClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataSource = DtsDil
                DataController.KeyFieldNames = 'ID'
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsSelection.MultiSelect = True
                OptionsView.ColumnAutoWidth = True
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridDilViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridDilViewREHBERID: TcxGridDBColumn
                  DataBinding.FieldName = 'REHBERID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridDilViewDIL: TcxGridDBColumn
                  Caption = 'Dil'
                  DataBinding.FieldName = 'DIL'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxImageComboBoxProperties'
                  Properties.Items = <>
                  RepositoryItem = Tablo.RepIKDiller
                  Width = 165
                end
                object GridDilViewOKUMA: TcxGridDBColumn
                  DataBinding.FieldName = 'OKUMA'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridDilViewYAZMA: TcxGridDBColumn
                  DataBinding.FieldName = 'YAZMA'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridDilViewKONUSMA: TcxGridDBColumn
                  DataBinding.FieldName = 'KONUSMA'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridDilViewSINAV: TcxGridDBColumn
                  DataBinding.FieldName = 'SINAV'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridDilViewPUAN: TcxGridDBColumn
                  DataBinding.FieldName = 'PUAN'
                  DataBinding.IsNullValueType = True
                  Visible = False
                end
                object GridDilViewACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                  Width = 612
                end
              end
              object cxGridLevel2: TcxGridLevel
                GridView = GridDilView
              end
            end
          end
        end
        object TabSheetIsDeneyimi: TcxTabSheet
          Caption = #304#351' Deneyimi'
          ImageIndex = 19
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object GridIKDeneyim: TcxGrid
            Left = 0
            Top = 44
            Width = 954
            Height = 184
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridIKDeneyimView: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridIKDeneyimViewCanFocusRecord
              DataController.DataSource = DtsIsDeneyimi
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Inserting = False
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              Styles.Content = cxStyle1
              Styles.OnGetContentStyle = GridBankaDBTableView1StylesGetContentStyle
              Styles.Header = cxStyle2
              Styles.Indicator = cxStyle2
              object GridIKDeneyimViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                Visible = False
              end
              object GridIKDeneyimViewTUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <
                  item
                    Description = 'Tercih'
                    ImageIndex = 0
                    Value = 0
                  end
                  item
                    Description = 'Deneyim'
                    Value = 1
                  end
                  item
                    Description = 'Bizde'
                    Value = 2
                  end>
              end
              object GridIKDeneyimViewBASVURUTARIHI: TcxGridDBColumn
                Caption = 'Tarih'
                DataBinding.FieldName = 'BASVURUTARIHI'
              end
              object GridIKDeneyimViewBASLAMATARIHI: TcxGridDBColumn
                Caption = 'Ba'#351'lama'
                DataBinding.FieldName = 'BASLAMATARIHI'
              end
              object GridIKDeneyimViewBITISTARIHI: TcxGridDBColumn
                Caption = 'Biti'#351
                DataBinding.FieldName = 'BITISTARIHI'
              end
              object GridIKDeneyimViewSEKTOR: TcxGridDBColumn
                Caption = 'Sekt'#246'r'
                DataBinding.FieldName = 'SEKTOR'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepCariSektor
              end
              object GridIKDeneyimViewDEPARTMAN: TcxGridDBColumn
                Caption = 'Departman'
                DataBinding.FieldName = 'DEPARTMAN'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepCariBolum
              end
              object GridIKDeneyimViewGOREV: TcxGridDBColumn
                Caption = 'G'#246'rev'
                DataBinding.FieldName = 'GOREV'
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepCariGorev
              end
              object GridIKDeneyimViewFIRMA: TcxGridDBColumn
                Caption = 'Kurum'
                DataBinding.FieldName = 'KURUM'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridIKDeneyimViewFIRMAPropertiesButtonClick
                Width = 112
              end
              object GridIKDeneyimViewILCE: TcxGridDBColumn
                Caption = #304'l'#231'e'
                DataBinding.FieldName = 'ILCEAD'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Properties.OnButtonClick = GridIKDeneyimViewILCEPropertiesButtonClick
                Width = 133
              end
              object GridIKDeneyimViewIL: TcxGridDBColumn
                Caption = #304'l'
                DataBinding.FieldName = 'ILAD'
                PropertiesClassName = 'TcxButtonEditProperties'
                Properties.Buttons = <
                  item
                    Default = True
                    Kind = bkEllipsis
                  end>
                Width = 96
              end
              object GridIKDeneyimViewUCRET_ALT: TcxGridDBColumn
                Caption = #220'cret Alt'
                DataBinding.FieldName = 'UCRET_ALT'
                PropertiesClassName = 'TcxCurrencyEditProperties'
                Properties.DisplayFormat = ',0.00;-,0.00'
              end
              object GridIKDeneyimViewACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                Width = 150
              end
            end
            object GridIKDeneyimLevel1: TcxGridLevel
              GridView = GridIKDeneyimView
            end
          end
          object ToolBar3: TToolBar
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 948
            Height = 41
            Margins.Bottom = 0
            AutoSize = True
            ButtonHeight = 39
            ButtonWidth = 42
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
            ParentColor = False
            ParentFont = False
            ShowCaptions = True
            TabOrder = 1
            Transparent = True
            object DeneyimEkleTus: TToolButton
              Left = 0
              Top = 0
              Caption = 'Yeni'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = DeneyimEkleTusClick
            end
            object DeneyimSilTus: TToolButton
              Left = 42
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = DeneyimSilTusClick
            end
            object ToolButton10: TToolButton
              Left = 84
              Top = 0
              Width = 8
              Caption = 'ToolButton10'
              ImageIndex = 4
              ImageName = 'PngImage4'
              Style = tbsSeparator
            end
            object DeneyimKaydet: TToolButton
              Left = 92
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              Visible = False
              OnClick = DeneyimKaydetClick
            end
            object DeneyimIptal: TToolButton
              Left = 134
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              Visible = False
              OnClick = DeneyimIptalClick
            end
          end
        end
        object TabSheetMaas: TcxTabSheet
          Caption = #220'cret Bilgileri'
          ImageIndex = 34
          object Panel10: TPanel
            Left = 0
            Top = 0
            Width = 457
            Height = 228
            Align = alLeft
            TabOrder = 0
            object GridUcret: TcxGrid
              Left = 1
              Top = 36
              Width = 455
              Height = 191
              Align = alClient
              TabOrder = 0
              LookAndFeel.Kind = lfOffice11
              LookAndFeel.NativeStyle = True
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridUcretView: TcxGridDBTableView
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                OnCanFocusRecord = GridUcretViewCanFocusRecord
                DataController.DataSource = DtsUcret
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <
                  item
                    Format = ',0.00;(,0.00)'
                    Kind = skSum
                    FieldName = 'TUTAR'
                    Column = cxGridDBColumn16
                  end>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CellSelect = False
                OptionsView.ColumnAutoWidth = True
                OptionsView.Footer = True
                OptionsView.GroupByBox = False
                OptionsView.Header = False
                OptionsView.Indicator = True
                Styles.Background = cxStyle2
                Styles.Content = cxStyle2
                Styles.ContentEven = Tablo.cxStFaturaKontrol
                Styles.OnGetContentStyle = GridUcretViewStylesGetContentStyle
                Styles.Inactive = cxStyle2
                object cxGridDBColumn15: TcxGridDBColumn
                  Caption = 'Var.'
                  DataBinding.FieldName = 'ETIKET'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxTextEditProperties'
                  Options.Editing = False
                  Width = 144
                end
                object cxGridDBColumn16: TcxGridDBColumn
                  Caption = 'Ad'#305' Soyad'#305
                  DataBinding.FieldName = 'TUTAR'
                  DataBinding.IsNullValueType = True
                  PropertiesClassName = 'TcxCurrencyEditProperties'
                  Properties.DisplayFormat = ',0.00;(,0.00)'
                  Options.Editing = False
                  Width = 79
                end
                object GridUcretViewColumn1: TcxGridDBColumn
                  DataBinding.FieldName = 'KUR'
                  DataBinding.IsNullValueType = True
                  Width = 40
                end
              end
              object cxGridLevel8: TcxGridLevel
                GridView = GridUcretView
              end
            end
            object Panel1: TPanel
              Left = 1
              Top = 1
              Width = 455
              Height = 35
              Align = alTop
              Caption = 'Panel6'
              TabOrder = 1
              object ToolBar4: TToolBar
                Left = 1
                Top = 1
                Width = 200
                Height = 33
                Margins.Bottom = 0
                Align = alLeft
                AutoSize = True
                ButtonHeight = 39
                ButtonWidth = 46
                Caption = 'AletCubugu'
                Color = clTeal
                Ctl3D = False
                DockSite = True
                DrawingStyle = dsGradient
                EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
                EdgeInner = esNone
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
                ParentColor = False
                ParentFont = False
                ShowCaptions = True
                TabOrder = 0
                Transparent = True
                object TahakkukYeniTus: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'Yeni'
                  ImageIndex = 0
                  ImageName = 'PngImage0'
                  OnClick = TahakkukYeniTusClick
                end
                object ToolButton12: TToolButton
                  Left = 46
                  Top = 0
                  Caption = 'D'#252'zenle'
                  ImageIndex = 7
                  ImageName = 'PngImage7'
                  OnClick = TahakkukYeniTusClick
                end
                object ToolButton16: TToolButton
                  Left = 92
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton18'
                  ImageIndex = 8
                  ImageName = 'PngImage15'
                  Style = tbsSeparator
                end
                object BankaTus: TToolButton
                  Left = 100
                  Top = 0
                  Caption = 'Banka'
                  ImageIndex = 22
                  ImageName = 'PngImage22'
                  OnClick = BankaTusClick
                end
                object ToolButton8: TToolButton
                  Left = 146
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton7'
                  ImageIndex = 8
                  ImageName = 'PngImage15'
                  Style = tbsSeparator
                end
                object BtnPirim: TToolButton
                  Left = 154
                  Top = 0
                  Caption = 'Pirim'
                  ImageIndex = 28
                  ImageName = 'PngImage28'
                  OnClick = BtnPirimClick
                end
              end
              object JvNavPanelHeader2: TJvNavPanelHeader
                Left = 201
                Top = 1
                Width = 253
                Height = 33
                Align = alClient
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWhite
                Font.Height = -16
                Font.Name = 'Arial'
                Font.Style = [fsBold]
                ParentFont = False
                ColorFrom = 14540253
                ColorTo = 11776947
                ImageIndex = 0
                object LabelBankadanOdeme: TcxLabel
                  Left = 112
                  Top = 8
                  Cursor = crHandPoint
                  Caption = '---'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clBlack
                  Style.Font.Height = -12
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = [fsBold]
                  Style.IsFontAssigned = True
                  Transparent = True
                  OnClick = LabelBankadanOdemeDblClick
                end
                object cxLabel8: TcxLabel
                  Left = 10
                  Top = 7
                  Caption = 'Bankadan Maa'#351' :'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clGreen
                  Style.Font.Height = -12
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = [fsBold]
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object cxLabel4: TcxLabel
                  Left = 181
                  Top = 5
                  AutoSize = False
                  Caption = 'Tahakkuk'
                  ParentFont = False
                  Style.Font.Charset = DEFAULT_CHARSET
                  Style.Font.Color = clNavy
                  Style.Font.Height = -16
                  Style.Font.Name = 'Arial Black'
                  Style.Font.Style = [fsBold, fsItalic]
                  Style.TextColor = clGreen
                  Style.IsFontAssigned = True
                  Transparent = True
                  OnClick = cxLabel4Click
                  Height = 27
                  Width = 95
                end
              end
            end
          end
          object PanelKesinti: TPanel
            Left = 457
            Top = 0
            Width = 497
            Height = 228
            Align = alClient
            Caption = 'PanelKesinti'
            TabOrder = 1
            object Panel12: TPanel
              Left = 1
              Top = 1
              Width = 495
              Height = 35
              Align = alTop
              Caption = 'Panel6'
              TabOrder = 0
              object ToolBar8: TToolBar
                Left = 1
                Top = 1
                Width = 154
                Height = 33
                Margins.Bottom = 0
                Align = alLeft
                AutoSize = True
                ButtonHeight = 39
                ButtonWidth = 46
                Caption = 'AletCubugu'
                Color = clTeal
                Ctl3D = False
                DockSite = True
                DrawingStyle = dsGradient
                EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
                EdgeInner = esNone
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
                ParentColor = False
                ParentFont = False
                ShowCaptions = True
                TabOrder = 0
                Transparent = True
                object KesintiEkleTus: TToolButton
                  Left = 0
                  Top = 0
                  Caption = 'Yeni'
                  ImageIndex = 0
                  ImageName = 'PngImage0'
                  OnClick = KesintiEkleTusClick
                end
                object KesintiSilTus: TToolButton
                  Left = 46
                  Top = 0
                  Caption = 'Sil'
                  ImageIndex = 1
                  ImageName = 'PngImage1'
                  OnClick = KesintiSilTusClick
                end
                object ToolButton20: TToolButton
                  Left = 92
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton7'
                  ImageIndex = 8
                  ImageName = 'PngImage15'
                  Style = tbsSeparator
                end
                object KesintiDuzenleTus: TToolButton
                  Left = 100
                  Top = 0
                  Caption = 'D'#252'zenle'
                  ImageIndex = 7
                  ImageName = 'PngImage7'
                  OnClick = KesintiDuzenleTusClick
                end
                object ToolButton18: TToolButton
                  Left = 146
                  Top = 0
                  Width = 8
                  Caption = 'ToolButton18'
                  ImageIndex = 8
                  ImageName = 'PngImage15'
                  Style = tbsSeparator
                end
              end
              object JvNavPanelHeader7: TJvNavPanelHeader
                Left = 155
                Top = 1
                Width = 339
                Height = 33
                Align = alClient
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWhite
                Font.Height = -16
                Font.Name = 'Arial'
                Font.Style = [fsBold]
                ParentFont = False
                ColorFrom = 14540253
                ColorTo = 11776947
                ImageIndex = 0
                object cxLabel9: TcxLabel
                  Left = 6
                  Top = 8
                  Caption = 'Standart Avans :'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clGreen
                  Style.Font.Height = -12
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = [fsBold]
                  Style.IsFontAssigned = True
                  Transparent = True
                end
                object LabelStandartAvans: TcxLabel
                  Left = 106
                  Top = 8
                  Cursor = crHandPoint
                  Caption = '---'
                  ParentFont = False
                  Style.Font.Charset = TURKISH_CHARSET
                  Style.Font.Color = clBlack
                  Style.Font.Height = -12
                  Style.Font.Name = 'Trebuchet MS'
                  Style.Font.Style = [fsBold]
                  Style.IsFontAssigned = True
                  Transparent = True
                  OnClick = LabelStandartAvansDblClick
                end
              end
            end
            object cxLabel7: TcxLabel
              Left = 391
              Top = 7
              AutoSize = False
              Caption = 'Kesinti  '
              ParentFont = False
              Style.Font.Charset = DEFAULT_CHARSET
              Style.Font.Color = clNavy
              Style.Font.Height = -16
              Style.Font.Name = 'Arial Black'
              Style.Font.Style = [fsBold, fsItalic]
              Style.TextColor = clRed
              Style.IsFontAssigned = True
              Transparent = True
              Height = 27
              Width = 95
            end
            object GridKesinti: TcxGrid
              Left = 1
              Top = 36
              Width = 495
              Height = 191
              Align = alClient
              TabOrder = 2
              LookAndFeel.NativeStyle = True
              LookAndFeel.ScrollbarMode = sbmClassic
              object GridKesintiView: TcxGridDBTableView
                OnDblClick = GridKesintiViewDblClick
                Navigator.Buttons.CustomButtons = <>
                ScrollbarAnnotations.CustomAnnotations = <>
                DataController.DataModeController.SmartRefresh = True
                DataController.DataSource = DtsKesinti
                DataController.KeyFieldNames = 'ID'
                DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
                DataController.Summary.DefaultGroupSummaryItems = <>
                DataController.Summary.FooterSummaryItems = <>
                DataController.Summary.SummaryGroups = <>
                OptionsCustomize.ColumnsQuickCustomization = True
                OptionsData.CancelOnExit = False
                OptionsData.Deleting = False
                OptionsData.DeletingConfirmation = False
                OptionsData.Inserting = False
                OptionsSelection.MultiSelect = True
                OptionsView.ColumnAutoWidth = True
                OptionsView.GroupByBox = False
                OptionsView.Indicator = True
                object GridKesintiViewSEC: TcxGridDBColumn
                  Caption = 'SE'#199
                  DataBinding.ValueType = 'Boolean'
                  PropertiesClassName = 'TcxCheckBoxProperties'
                  Properties.ImmediatePost = True
                  Properties.NullStyle = nssUnchecked
                  Visible = False
                  Width = 48
                end
                object GridKesintiViewID: TcxGridDBColumn
                  DataBinding.FieldName = 'ID'
                  DataBinding.IsNullValueType = True
                  Visible = False
                  Options.Editing = False
                end
                object GridKesintiViewTARIH: TcxGridDBColumn
                  Caption = 'Tarih'
                  DataBinding.FieldName = 'TARIH'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 70
                end
                object GridKesintiViewTUR: TcxGridDBColumn
                  Caption = 'T'#252'r'
                  DataBinding.FieldName = 'TUR'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                end
                object GridKesintiViewETIKET: TcxGridDBColumn
                  Caption = 'Kesinti'
                  DataBinding.FieldName = 'ETIKET'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 82
                end
                object GridKesintiViewTUTAR: TcxGridDBColumn
                  Caption = 'Ayl'#305'k Tutar'
                  DataBinding.FieldName = 'TUTAR'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 65
                end
                object GridKesintiViewKUR: TcxGridDBColumn
                  Caption = 'P.Birimi'
                  DataBinding.FieldName = 'KUR'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 46
                end
                object GridKesintiViewSIRA: TcxGridDBColumn
                  DataBinding.FieldName = 'SIRA'
                  DataBinding.IsNullValueType = True
                  Visible = False
                  Options.Editing = False
                end
                object GridKesintiViewACIKLAMA: TcxGridDBColumn
                  Caption = 'A'#231#305'klama'
                  DataBinding.FieldName = 'ACIKLAMA'
                  DataBinding.IsNullValueType = True
                  Options.Editing = False
                  Width = 91
                end
              end
              object GridKesintiLevel: TcxGridLevel
                GridView = GridKesintiView
              end
            end
          end
        end
        object TabSheetDemirbas: TcxTabSheet
          Caption = 'Demirba'#351' Bilgileri'
          ImageIndex = 12
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object GridDemirbas: TcxGrid
            Left = 0
            Top = 0
            Width = 954
            Height = 228
            Align = alClient
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridDemirbasView: TcxGridDBTableView
              OnDblClick = DegisTusClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = GridDemirbasViewCanFocusRecord
              DataController.DataSource = DtsDemirbasBilgi
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoImmediatePost]
              DataController.Summary.DefaultGroupSummaryItems = <
                item
                  Format = 'Say'#305' : ######'
                  Kind = skCount
                  Position = spFooter
                  FieldName = 'DEMIRBASADI'
                  Column = GridDemirbasViewDEMIRBASADI
                end>
              DataController.Summary.FooterSummaryItems = <
                item
                  Format = 'Say'#305' : ######'
                  Kind = skCount
                  FieldName = 'DEMIRBASADI'
                  Column = GridDemirbasViewDEMIRBASADI
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnTab = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.CancelOnExit = False
              OptionsData.Editing = False
              OptionsSelection.CellSelect = False
              OptionsSelection.MultiSelect = True
              OptionsSelection.HideFocusRectOnExit = False
              OptionsSelection.UnselectFocusedRecordOnExit = False
              OptionsView.Footer = True
              OptionsView.GroupFooters = gfAlwaysVisible
              OptionsView.Indicator = True
              Preview.Visible = True
              Styles.OnGetContentStyle = GridDemirbasViewStylesGetContentStyle
              object GridDemirbasViewID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridDemirbasViewDEMIRBASNO: TcxGridDBColumn
                Caption = 'Demirba'#351' No'
                DataBinding.FieldName = 'DEMIRBASNO'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle8
                Width = 88
              end
              object GridDemirbasViewDEMIRBASADI: TcxGridDBColumn
                Caption = 'Demirba'#351' Ad'#305
                DataBinding.FieldName = 'DEMIRBASADI'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle8
                Width = 179
              end
              object GridDemirbasViewDURUM: TcxGridDBColumn
                Caption = 'Durum'
                DataBinding.FieldName = 'DURUM'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepDemirbas_Durum
                HeaderAlignmentHorz = taCenter
                Options.Editing = False
                Styles.Header = cxStyle8
                Width = 87
              end
              object GridDemirbasViewLOKASYONADI: TcxGridDBColumn
                Caption = 'Lokasyon'
                DataBinding.FieldName = 'LOKASYONADI'
                DataBinding.IsNullValueType = True
                HeaderAlignmentHorz = taCenter
                Options.Editing = False
                Styles.Header = cxStyle8
                Width = 94
              end
              object GridDemirbasViewKATEGORIADI: TcxGridDBColumn
                Caption = 'Kategori'
                DataBinding.FieldName = 'KATEGORIADI'
                DataBinding.IsNullValueType = True
                HeaderAlignmentHorz = taCenter
                Options.Editing = False
                Styles.Header = cxStyle8
                Width = 144
              end
              object GridDemirbasViewMARKA: TcxGridDBColumn
                Caption = 'Marka'
                DataBinding.FieldName = 'MARKA'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.Demirbas_Marka
                Styles.Header = cxStyle8
                Width = 107
              end
              object GridDemirbasViewMODEL: TcxGridDBColumn
                Caption = 'Model'
                DataBinding.FieldName = 'MODELAD'
                DataBinding.IsNullValueType = True
                Styles.Header = cxStyle8
                Width = 90
              end
              object GridDemirbasViewLOKASYONID: TcxGridDBColumn
                Caption = 'LokasyonId'
                DataBinding.FieldName = 'LOKASYONID'
                DataBinding.IsNullValueType = True
                Visible = False
                Styles.Header = cxStyle8
                VisibleForCustomization = False
              end
              object GridDemirbasViewREHBERID: TcxGridDBColumn
                Caption = 'Zimmet.Per.Id'
                DataBinding.FieldName = 'REHBERID'
                DataBinding.IsNullValueType = True
                Visible = False
                Styles.Header = cxStyle8
                VisibleForCustomization = False
              end
            end
            object GridDemirbasLevel3: TcxGridLevel
              GridView = GridDemirbasView
            end
          end
        end
        object TabSheetIzinBilgileri: TcxTabSheet
          Caption = #304'zin Bilgileri'
          ImageIndex = 21
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 954
            Height = 41
            Align = alTop
            Caption = 'Panel5'
            TabOrder = 0
            object ToolBar9: TToolBar
              Left = 1
              Top = 1
              Width = 138
              Height = 39
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 46
              Caption = 'AletCubugu'
              Color = clBtnFace
              Ctl3D = False
              DoubleBuffered = False
              DockSite = True
              DrawingStyle = dsGradient
              EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
              EdgeInner = esNone
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
              ParentColor = False
              ParentDoubleBuffered = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
              Transparent = True
              object BtnYeniPerizin: TToolButton
                Left = 0
                Top = 0
                Caption = 'Yeni'
                DropdownMenu = PmIzinTurleri
                ImageIndex = 0
                ImageName = 'PngImage0'
              end
              object BtnSilPerizin: TToolButton
                Left = 46
                Top = 0
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                OnClick = BtnSilPerizinClick
              end
              object BtnDuzenlePerizin: TToolButton
                Left = 92
                Top = 0
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                OnClick = BtnDuzenlePerizinClick
              end
            end
            object JvNavPanelHeader1: TJvNavPanelHeader
              Left = 139
              Top = 1
              Width = 814
              Height = 39
              Align = alClient
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -16
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
              ColorFrom = 14540253
              ColorTo = 11776947
              ImageIndex = 0
              object SETarihBit: TcxSpinEdit
                Left = 191
                Top = 6
                ParentFont = False
                Properties.OnChange = SETarihBasPropertiesChange
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 1
                Value = 2013
                Width = 55
              end
              object SETarihBas: TcxSpinEdit
                Left = 134
                Top = 6
                ParentFont = False
                Properties.OnChange = SETarihBasPropertiesChange
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 0
                Value = 2013
                Width = 55
              end
              object cxLabel6: TcxLabel
                Left = 22
                Top = 8
                Caption = '  Ba'#351'lama/Biti'#351'   '
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
            end
          end
          object GridIzinListe: TcxGrid
            Left = 0
            Top = 41
            Width = 954
            Height = 187
            Align = alClient
            TabOrder = 1
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object GridIzinListeDBTableView1: TcxGridDBTableView
              OnDblClick = BtnDuzenlePerizinClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsPersonelIzin
              DataController.Options = [dcoAnsiSort, dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding]
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <
                item
                  Kind = skSum
                  FieldName = 'HAK'
                end
                item
                  Kind = skSum
                  FieldName = 'IZINLIGUNSAYISI'
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsView.ColumnAutoWidth = True
              OptionsView.Footer = True
              OptionsView.GroupByBox = False
              OptionsView.Indicator = True
              Styles.OnGetContentStyle = cxGrid3DBTableView1StylesGetContentStyle
              object GridIzinListeDBTableView1ID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridIzinListeDBTableView1REHBERID: TcxGridDBColumn
                DataBinding.FieldName = 'REHBERID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object GridIzinListeDBTableView1DONEM: TcxGridDBColumn
                Caption = 'D'#246'nem'
                DataBinding.FieldName = 'DONEM'
                DataBinding.IsNullValueType = True
                Width = 80
              end
              object GridIzinListeDBTableView1BASLAMA: TcxGridDBColumn
                Caption = 'Ba'#351'lama'
                DataBinding.FieldName = 'BASLAMA'
                DataBinding.IsNullValueType = True
                Width = 64
              end
              object GridIzinListeDBTableView1IZINBITIS: TcxGridDBColumn
                Caption = 'Biti'#351
                DataBinding.FieldName = 'IZINBITIS'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 67
              end
              object GridIzinListeDBTableView1TUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                Width = 164
              end
              object GridIzinListeDBTableView1HAKEDILEN: TcxGridDBColumn
                Caption = 'Hakedilen'
                DataBinding.FieldName = 'HAKEDILEN'
                DataBinding.IsNullValueType = True
                Width = 116
              end
              object GridIzinListeDBTableView1KULLANILAN: TcxGridDBColumn
                Caption = 'Kullan'#305'lan'
                DataBinding.FieldName = 'KULLANILAN'
                DataBinding.IsNullValueType = True
                Width = 90
              end
              object GridIzinListeDBTableView1KALAN: TcxGridDBColumn
                Caption = 'Kalan'
                DataBinding.FieldName = 'KALAN'
                DataBinding.IsNullValueType = True
                Width = 79
              end
              object GridIzinListeDBTableView1BIRIM: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepIzinTurleriBirim
                Width = 121
              end
              object GridIzinListeDBTableView1ACIKLAMA: TcxGridDBColumn
                Caption = 'A'#231#305'klama'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Width = 301
              end
              object GridIzinListeDBTableView1VEKIL: TcxGridDBColumn
                DataBinding.FieldName = 'VEKIL'
                DataBinding.IsNullValueType = True
                Visible = False
              end
            end
            object cxGridLevel9: TcxGridLevel
              GridView = GridIzinListeDBTableView1
            end
          end
        end
        object TabSheetPDKS: TcxTabSheet
          Caption = 'PDKS'
          ImageIndex = 21
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Panel13: TPanel
            Left = 0
            Top = 0
            Width = 954
            Height = 41
            Align = alTop
            BevelOuter = bvNone
            Caption = 'Panel13'
            TabOrder = 0
            object JvNavPanelHeader8: TJvNavPanelHeader
              Left = 0
              Top = 0
              Width = 187
              Height = 41
              Align = alLeft
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -16
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
              ColorFrom = 14540253
              ColorTo = 11776947
              ImageIndex = 0
              object CheckPDKSTakibi: TcxCheckBox
                Left = 0
                Top = 0
                Align = alLeft
                Caption = 'PDKS Takibi yap'
                ParentFont = False
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 0
                Transparent = True
                OnClick = CheckPDKSTakibiClick
              end
            end
            object ToolBar14: TToolBar
              Left = 187
              Top = 0
              Width = 767
              Height = 41
              Margins.Bottom = 0
              Align = alClient
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 71
              Caption = 'AletCubugu'
              Color = clTeal
              DockSite = True
              DrawingStyle = dsGradient
              EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
              EdgeInner = esNone
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
              ParentColor = False
              ParentFont = False
              ShowCaptions = True
              TabOrder = 1
              Transparent = True
              object ButtonVardiyalar: TToolButton
                Left = 0
                Top = 0
                Caption = 'Vardiyalar'
                ImageIndex = 11
                ImageName = 'PngImage11'
                OnClick = ButtonVardiyalarClick
              end
              object ButtonVardiyaTuru: TToolButton
                Left = 71
                Top = 0
                Caption = 'Vardiya T'#252'r'#252
                ImageIndex = 4
                ImageName = 'PngImage4'
                OnClick = ButtonVardiyaTuruClick
              end
              object ButtonKartNo: TToolButton
                Left = 142
                Top = 0
                Caption = 'Kart No'
                ImageIndex = 20
                ImageName = 'PngImage20'
                OnClick = ButtonKartNoClick
              end
            end
          end
        end
        object TabSheetHareketler: TcxTabSheet
          Caption = 'Hareketler'
          ImageIndex = 32
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object ToolBar15: TToolBar
            Left = 0
            Top = 0
            Width = 954
            Height = 41
            ButtonHeight = 39
            ButtonWidth = 46
            Caption = 'ToolBar15'
            DrawingStyle = dsGradient
            GradientEndColor = 11776947
            GradientStartColor = 14540253
            Images = Tablo.PNGImageList2
            ShowCaptions = True
            TabOrder = 0
            object TBtnHareketlerEkle: TToolButton
              Left = 0
              Top = 0
              Caption = 'Ekle'
              ImageIndex = 0
              ImageName = 'PngImage0'
              OnClick = TBtnHareketlerEkleClick
            end
            object TBtnHareketlerSil: TToolButton
              Left = 46
              Top = 0
              Caption = 'Sil'
              ImageIndex = 1
              ImageName = 'PngImage1'
              OnClick = TBtnHareketlerSilClick
            end
            object TBtnHareketDuzenle: TToolButton
              Left = 92
              Top = 0
              Caption = 'D'#252'zenle'
              ImageIndex = 7
              ImageName = 'PngImage7'
              OnClick = TBtnHareketDuzenleClick
            end
            object TBtnHareketKaydet: TToolButton
              Left = 138
              Top = 0
              Caption = 'Kaydet'
              ImageIndex = 2
              ImageName = 'PngImage2'
              OnClick = TBtnHareketKaydetClick
            end
            object TBtnHareketIptal: TToolButton
              Left = 184
              Top = 0
              Caption = #304'ptal'
              ImageIndex = 3
              ImageName = 'PngImage3'
              OnClick = TBtnHareketIptalClick
            end
          end
          object gridPersonelHareketler: TcxGrid
            Left = 0
            Top = 41
            Width = 954
            Height = 187
            Align = alClient
            TabOrder = 1
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object gridPersonelHareketlerDBTableView1: TcxGridDBTableView
              OnDblClick = TBtnHareketDuzenleClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataSource = DtsHareketler
              DataController.DetailKeyFieldNames = 'ID'
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
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              object gridPersonelHareketlerDBTableView1ID: TcxGridDBColumn
                DataBinding.FieldName = 'ID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object gridPersonelHareketlerDBTableView1REHBERID: TcxGridDBColumn
                DataBinding.FieldName = 'REHBERID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
              object gridPersonelHareketlerDBTableView1TARIH: TcxGridDBColumn
                Caption = 'TAR'#304'H'
                DataBinding.FieldName = 'TARIH'
                DataBinding.IsNullValueType = True
                Width = 105
              end
              object gridPersonelHareketlerDBTableView1TUR: TcxGridDBColumn
                Caption = 'T'#220'R'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCariHareketTur
                Width = 122
              end
              object gridPersonelHareketlerDBTableView1SUBE: TcxGridDBColumn
                Caption = #350'UBE'
                DataBinding.FieldName = 'SUBE'
                DataBinding.IsNullValueType = True
                Width = 77
              end
              object gridPersonelHareketlerDBTableView1DEPARTMAN: TcxGridDBColumn
                Caption = 'DEPARTMAN'
                DataBinding.FieldName = 'DEPARTMANAD'
                DataBinding.IsNullValueType = True
                Width = 75
              end
              object gridPersonelHareketlerDBTableView1GOREV: TcxGridDBColumn
                Caption = 'G'#214'REV'
                DataBinding.FieldName = 'GOREV'
                DataBinding.IsNullValueType = True
                Width = 77
              end
              object gridPersonelHareketlerDBTableView1ACIKLAMA: TcxGridDBColumn
                Caption = 'A'#199'IKLAMA'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                Width = 448
              end
            end
            object gridPersonelHareketlerLevel1: TcxGridLevel
              GridView = gridPersonelHareketlerDBTableView1
            end
          end
        end
        object TabSheetEkstre: TcxTabSheet
          Caption = 'Ekstre'
          ImageIndex = 32
          object cxGrid1: TcxGrid
            Left = 0
            Top = 41
            Width = 954
            Height = 187
            Align = alClient
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Trebuchet MS'
            Font.Style = []
            ParentFont = False
            PopupMenu = PMAksiyonlarMenu
            TabOrder = 0
            LookAndFeel.Kind = lfOffice11
            LookAndFeel.NativeStyle = True
            LookAndFeel.ScrollbarMode = sbmClassic
            object cxGridHareketler: TcxGridDBTableView
              OnDblClick = AksiyonBilgisiniGorMenuClick
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              OnCanFocusRecord = cxGridHareketlerCanFocusRecord
              DataController.DataModeController.SmartRefresh = True
              DataController.DataSource = DtsCariListe
              DataController.Options = [dcoAnsiSort, dcoGroupsAlwaysExpanded]
              DataController.Summary.DefaultGroupSummaryItems = <
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Position = spFooter
                  Column = cxGridHareketlerBORC
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  Position = spFooter
                  Column = cxGridHareketlerALACAK
                end>
              DataController.Summary.FooterSummaryItems = <
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  FieldName = 'BORC'
                  Column = cxGridHareketlerBORC
                end
                item
                  Format = ',0.00;(,0.00)'
                  Kind = skSum
                  FieldName = 'ALACAK'
                  Column = cxGridHareketlerALACAK
                end
                item
                  Format = ',0.00;(,0.00)'
                  Column = cxGridHareketlerBORCBAKIYE
                end
                item
                  Format = ',0.00;(,0.00)'
                  Column = cxGridHareketlerALACAKBAKIYE
                end>
              DataController.Summary.SummaryGroups = <>
              OptionsBehavior.FocusCellOnCycle = True
              OptionsCustomize.ColumnsQuickCustomization = True
              OptionsData.CancelOnExit = False
              OptionsData.Deleting = False
              OptionsData.DeletingConfirmation = False
              OptionsData.Editing = False
              OptionsData.Inserting = False
              OptionsSelection.CellSelect = False
              OptionsSelection.MultiSelect = True
              OptionsView.GroupByBox = False
              OptionsView.GroupFooters = gfAlwaysVisible
              OptionsView.Indicator = True
              Styles.OnGetContentStyle = cxGridHareketlerStylesGetContentStyle
              object cxGridHareketlerTARIH: TcxGridDBColumn
                Caption = 'Kay'#305't'
                DataBinding.FieldName = 'TARIH'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxDateEditProperties'
                Properties.InputKind = ikRegExpr
                Properties.Kind = ckDateTime
                Width = 68
              end
              object cxGridHareketlerAKSIYONTARIH: TcxGridDBColumn
                Caption = 'Aksiyon/Vade'
                DataBinding.FieldName = 'AKSIYONTARIH'
                DataBinding.IsNullValueType = True
                Width = 79
              end
              object cxGridHareketlerNO: TcxGridDBColumn
                Caption = 'No'
                DataBinding.FieldName = 'NO'
                DataBinding.IsNullValueType = True
                Width = 49
              end
              object cxGridHareketlerTUR: TcxGridDBColumn
                Caption = 'T'#252'r'
                DataBinding.FieldName = 'TUR'
                DataBinding.IsNullValueType = True
                PropertiesClassName = 'TcxImageComboBoxProperties'
                Properties.Items = <>
                RepositoryItem = Tablo.RepKasaTurleri
                Width = 53
              end
              object cxGridHareketlerKOD: TcxGridDBColumn
                Caption = 'Kod'
                DataBinding.FieldName = 'KOD'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 77
              end
              object cxGridHareketlerBASLIK: TcxGridDBColumn
                Caption = 'Ba'#351'l'#305'k'
                DataBinding.FieldName = 'BASLIK'
                DataBinding.IsNullValueType = True
                Width = 90
              end
              object cxGridHareketlerAD: TcxGridDBColumn
                Caption = #220'nvan'
                DataBinding.FieldName = 'AD'
                DataBinding.IsNullValueType = True
                Visible = False
                Width = 90
              end
              object cxGridHareketlerACIKLAMA: TcxGridDBColumn
                Caption = 'Notlar'
                DataBinding.FieldName = 'ACIKLAMA'
                DataBinding.IsNullValueType = True
                BestFitMaxWidth = 80
                Width = 128
              end
              object cxGridHareketlerHESAPKODU: TcxGridDBColumn
                Caption = 'Hesap Kodu'
                DataBinding.FieldName = 'HESAPKODU'
                DataBinding.IsNullValueType = True
                Width = 64
              end
              object cxGridHareketlerHESAPADI: TcxGridDBColumn
                Caption = 'Hesap Ad'#305
                DataBinding.FieldName = 'HESAPADI'
                DataBinding.IsNullValueType = True
                Width = 82
              end
              object cxGridHareketlerADET: TcxGridDBColumn
                Caption = 'Adet'
                DataBinding.FieldName = 'ADET'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyAdetGenel
                Width = 32
              end
              object cxGridHareketlerBIRIM: TcxGridDBColumn
                Caption = 'Birim'
                DataBinding.FieldName = 'BIRIM'
                DataBinding.IsNullValueType = True
                Width = 47
              end
              object cxGridHareketlerBIRIMFIYAT: TcxGridDBColumn
                Caption = 'Birim Fiyat'
                DataBinding.FieldName = 'BIRIMFIYAT'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyBF
                Width = 63
              end
              object cxGridHareketlerBORC: TcxGridDBColumn
                Caption = 'Bor'#231
                DataBinding.FieldName = 'BORC'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 56
              end
              object cxGridHareketlerALACAK: TcxGridDBColumn
                Caption = 'Alacak'
                DataBinding.FieldName = 'ALACAK'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 67
              end
              object cxGridHareketlerBORCBAKIYE: TcxGridDBColumn
                Caption = 'B.Bakiye'
                DataBinding.FieldName = 'BORCBAKIYE'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 54
              end
              object cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn
                Caption = 'A.Bakiye'
                DataBinding.FieldName = 'ALACAKBAKIYE'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepCurrencyGenel
                Width = 56
              end
              object cxGridHareketlerKUR: TcxGridDBColumn
                Caption = 'Para Birimi'
                DataBinding.FieldName = 'KUR'
                DataBinding.IsNullValueType = True
                GroupIndex = 0
                Width = 76
              end
              object cxGridHareketlerMASRAFKOD: TcxGridDBColumn
                Caption = 'Masraf Kod'
                DataBinding.FieldName = 'MASRAFKOD'
                DataBinding.IsNullValueType = True
                Width = 83
              end
              object cxGridHareketlerMASRAFAD: TcxGridDBColumn
                Caption = 'Masraf Ad'
                DataBinding.FieldName = 'MASRAFAD'
                DataBinding.IsNullValueType = True
                Width = 120
              end
              object cxGridHareketlerColumn1: TcxGridDBColumn
                Caption = #350'ube'
                DataBinding.FieldName = 'SUBEID'
                DataBinding.IsNullValueType = True
                RepositoryItem = Tablo.RepSubelerOrtakTumSubeler
              end
              object cxGridHareketlerColumn2: TcxGridDBColumn
                Caption = 'Vade Tarihi'
                DataBinding.FieldName = 'VADETARIHI'
                DataBinding.IsNullValueType = True
                Width = 67
              end
              object cxGridHareketlerCEKID: TcxGridDBColumn
                DataBinding.FieldName = 'CEKID'
                DataBinding.IsNullValueType = True
                Visible = False
              end
            end
            object cxGrid1DBTableView1: TcxGridDBTableView
              Navigator.Buttons.CustomButtons = <>
              ScrollbarAnnotations.CustomAnnotations = <>
              DataController.DataModeController.SmartRefresh = True
              DataController.DetailKeyFieldNames = 'CEKID'
              DataController.MasterKeyFieldNames = 'CEKID'
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.GroupByBox = False
              object cxGrid1DBTableView1DURUM: TcxGridDBColumn
                DataBinding.FieldName = 'DURUM'
                DataBinding.IsNullValueType = True
                FooterAlignmentHorz = taRightJustify
                GroupSummaryAlignment = taRightJustify
                Width = 74
              end
              object cxGrid1DBTableView1VADE: TcxGridDBColumn
                DataBinding.FieldName = 'VADE'
                DataBinding.IsNullValueType = True
                Width = 130
              end
              object cxGrid1DBTableView1SERINO: TcxGridDBColumn
                DataBinding.FieldName = 'SERINO'
                DataBinding.IsNullValueType = True
                FooterAlignmentHorz = taRightJustify
                GroupSummaryAlignment = taRightJustify
                Width = 109
              end
              object cxGrid1DBTableView1HESAPADI: TcxGridDBColumn
                DataBinding.FieldName = 'HESAPADI'
                DataBinding.IsNullValueType = True
                Width = 354
              end
              object cxGrid1DBTableView1Column1: TcxGridDBColumn
                DataBinding.FieldName = 'CEKID'
                DataBinding.IsNullValueType = True
              end
            end
            object cxGrid1Level1: TcxGridLevel
              GridView = cxGridHareketler
            end
          end
          object Panel8: TPanel
            Left = 0
            Top = 0
            Width = 954
            Height = 41
            Align = alTop
            Caption = 'Panel8'
            TabOrder = 1
            object ToolBar11: TToolBar
              Left = 1
              Top = 1
              Width = 100
              Height = 39
              Margins.Bottom = 0
              Align = alLeft
              AutoSize = True
              ButtonHeight = 39
              ButtonWidth = 46
              Caption = 'AletCubugu'
              DockSite = True
              DrawingStyle = dsGradient
              EdgeInner = esNone
              EdgeOuter = esNone
              Font.Charset = TURKISH_CHARSET
              Font.Color = clBlack
              Font.Height = -11
              Font.Name = 'Trebuchet MS'
              Font.Style = []
              GradientEndColor = 11776947
              GradientStartColor = 14540253
              Images = Tablo.PNGImageList2
              ParentFont = False
              ShowCaptions = True
              TabOrder = 0
              object EkstreSilTus: TToolButton
                Left = 0
                Top = 0
                Hint = 'Aksiyon Sil'
                Caption = 'Sil'
                ImageIndex = 1
                ImageName = 'PngImage1'
                ParentShowHint = False
                ShowHint = True
                OnClick = Sil1Click
              end
              object EkstreDegisTus: TToolButton
                Left = 46
                Top = 0
                Hint = 'Aksiyon D'#252'zenle'
                Caption = 'D'#252'zenle'
                ImageIndex = 7
                ImageName = 'PngImage7'
                ParentShowHint = False
                ShowHint = True
                OnClick = AksiyonBilgisiniGorMenuClick
              end
              object ToolButton1: TToolButton
                Left = 92
                Top = 0
                Width = 8
                Caption = 'ToolButton1'
                ImageIndex = 17
                ImageName = 'PngImage17'
                Style = tbsSeparator
              end
            end
            object JvNavPanelHeader4: TJvNavPanelHeader
              Left = 101
              Top = 1
              Width = 852
              Height = 39
              Align = alClient
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -16
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
              ColorFrom = 14540253
              ColorTo = 11776947
              ImageIndex = 0
              object Label1: TcxLabel
                Left = 3
                Top = 8
                Caption = 'Ba'#351'lama'
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object CalendarEkstreBas: TcxDateEdit
                Left = 60
                Top = 6
                ParentFont = False
                Properties.ImmediatePost = True
                Properties.OnChange = CalendarEkstreBasPropertiesChange
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 1
                Width = 121
              end
              object Label2: TcxLabel
                Left = 187
                Top = 8
                Caption = 'Biti'#351
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object CalendarEkstreBit: TcxDateEdit
                Left = 222
                Top = 6
                ParentFont = False
                Properties.ImmediatePost = True
                Properties.OnChange = CalendarEkstreBasPropertiesChange
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                TabOrder = 3
                Width = 121
              end
              object CheckDetayli: TcxCheckBox
                Left = 351
                Top = 6
                Caption = 'Detayl'#305' Ekstre G'#246'ster'
                ParentFont = False
                Properties.ImmediatePost = True
                Properties.OnEditValueChanged = CheckDetayliPropertiesEditValueChanged
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.Shadow = False
                Style.TransparentBorder = True
                Style.IsFontAssigned = True
                TabOrder = 4
                Transparent = True
                OnClick = CalendarEkstreBasPropertiesChange
              end
              object LabelMaasAvansi: TcxLabel
                Left = 507
                Top = 8
                Caption = 'Maa'#351' Avans'#305
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object EditMaasAvansi: TcxCurrencyEdit
                Left = 584
                Top = 7
                ParentFont = False
                Properties.ReadOnly = True
                Style.Color = clScrollBar
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWhite
                Style.Font.Height = -13
                Style.Font.Name = 'Arial'
                Style.Font.Style = [fsBold]
                Style.TextColor = clRed
                Style.IsFontAssigned = True
                TabOrder = 6
                Width = 72
              end
              object EditIsAvansi: TcxCurrencyEdit
                Left = 719
                Top = 7
                ParentFont = False
                Properties.ReadOnly = True
                Style.Color = clScrollBar
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWhite
                Style.Font.Height = -13
                Style.Font.Name = 'Arial'
                Style.Font.Style = [fsBold]
                Style.TextColor = clRed
                Style.IsFontAssigned = True
                TabOrder = 7
                Width = 72
              end
              object LabelIsAvansi: TcxLabel
                Left = 659
                Top = 8
                Caption = #304#351' Avans'#305
                ParentFont = False
                Style.Font.Charset = TURKISH_CHARSET
                Style.Font.Color = clBlack
                Style.Font.Height = -13
                Style.Font.Name = 'Trebuchet MS'
                Style.Font.Style = []
                Style.IsFontAssigned = True
                Transparent = True
              end
              object cbPerExtreTuru: TcxImageComboBox
                Left = 818
                Top = 6
                EditValue = 1
                ParentFont = False
                Properties.ImmediatePost = True
                Properties.ImmediateUpdateText = True
                Properties.Items = <
                  item
                    Description = 'Maa'#351
                    ImageIndex = 0
                    Value = 1
                  end
                  item
                    Description = #304#351' Avans'#305
                    Value = 2
                  end
                  item
                    Description = 'Maa'#351' Avans'#305
                    Value = 3
                  end>
                Properties.OnEditValueChanged = cbPerExtreTuruPropertiesEditValueChanged
                Style.BorderStyle = ebsOffice11
                Style.Color = clWindow
                Style.Font.Charset = DEFAULT_CHARSET
                Style.Font.Color = clWhite
                Style.Font.Height = -13
                Style.Font.Name = 'Arial'
                Style.Font.Style = [fsBold]
                Style.TextColor = clBlack
                Style.TextStyle = []
                Style.IsFontAssigned = True
                TabOrder = 9
                Width = 121
              end
            end
          end
        end
      end
      object cxSplitter1: TcxSplitter
        Left = 0
        Top = 260
        Width = 962
        Height = 8
        HotZoneClassName = 'TcxMediaPlayer8Style'
        AlignSplitter = salBottom
        Control = PageControlSekme
        Color = clAqua
        ParentColor = False
        ExplicitWidth = 8
      end
      object ToolBar1: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 956
        Height = 29
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
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
        TabOrder = 5
        Transparent = True
        Wrapable = False
        object YeniTus: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 7
          ImageName = 'PngImage6'
          OnClick = YeniTusClick
        end
        object SilTus: TToolButton
          Left = 82
          Top = 0
          Caption = 'Sil'
          ImageIndex = 8
          ImageName = 'PngImage7'
          OnClick = SilTusClick
        end
        object ToolButton7: TToolButton
          Left = 164
          Top = 0
          Width = 8
          Caption = 'ToolButton7'
          ImageIndex = 2
          ImageName = 'PngImage3'
          Style = tbsSeparator
        end
        object DegisTus: TToolButton
          Left = 172
          Top = 0
          Caption = 'D'#252'zenle'
          ImageIndex = 9
          ImageName = 'PngImage8'
          Style = tbsTextButton
          Visible = False
          OnClick = DegisTusClick
        end
        object ToolButton2: TToolButton
          Left = 254
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 2
          ImageName = 'PngImage3'
          Style = tbsSeparator
        end
        object YaziciYaz: TToolButton
          Left = 262
          Top = 0
          Caption = 'Yazd'#305'r'
          DropdownMenu = PopupMenuYaz
          ImageIndex = 16
          ImageName = 'PngImage15'
        end
        object ToolButton4: TToolButton
          Left = 344
          Top = 0
          Width = 7
          Caption = 'ToolButton4'
          ImageIndex = 2
          ImageName = 'PngImage3'
          Style = tbsSeparator
        end
        object AksiyonEkleTus: TToolButton
          Left = 351
          Top = 0
          Caption = 'Aksiyon   '
          DropdownMenu = PopupMenuYeni
          ImageIndex = 1
          ImageName = 'PngImage0'
        end
        object ToolButton9: TToolButton
          Left = 433
          Top = 0
          Width = 8
          Caption = 'ToolButton9'
          ImageIndex = 17
          ImageName = 'PngImage16'
          Style = tbsSeparator
        end
      end
    end
    object TabSheetGrup: TcxTabSheet
      Caption = 'Grup'
      ImageIndex = 53
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ToolBar13: TToolBar
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 956
        Height = 29
        Margins.Bottom = 0
        AutoSize = True
        ButtonHeight = 30
        ButtonWidth = 59
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
        Wrapable = False
        object YeniGrup: TToolButton
          Left = 0
          Top = 0
          Caption = 'Yeni'
          ImageIndex = 7
          ImageName = 'PngImage6'
          OnClick = YeniGrupClick
        end
        object SilGrup: TToolButton
          Left = 59
          Top = 0
          Caption = 'Sil'
          ImageIndex = 8
          ImageName = 'PngImage7'
          OnClick = SilGrupClick
        end
        object ToolButton11: TToolButton
          Left = 118
          Top = 0
          Width = 8
          Caption = 'ToolButton9'
          ImageIndex = 2
          ImageName = 'PngImage3'
          Style = tbsSeparator
        end
      end
      object Panel14: TPanel
        Left = 468
        Top = 32
        Width = 494
        Height = 495
        Align = alRight
        Caption = 'PanelFiyatAltSag'
        TabOrder = 1
        ExplicitTop = 35
        ExplicitHeight = 492
        object ToolBar16: TToolBar
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 486
          Height = 24
          Margins.Bottom = 0
          AutoSize = True
          ButtonWidth = 54
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
          object BtnGrupKisiEkle: TToolButton
            Left = 0
            Top = 0
            Caption = 'Ekle'
            ImageIndex = 0
            ImageName = 'PngImage0'
            OnClick = BtnGrupKisiEkleClick
          end
          object ToolButton21: TToolButton
            Left = 54
            Top = 0
            Width = 8
            Caption = 'ToolButton6'
            ImageIndex = 2
            ImageName = 'PngImage2'
            Style = tbsSeparator
          end
          object BtnGrupKisiSil: TToolButton
            Left = 62
            Top = 0
            Caption = #199#305'kar'
            ImageIndex = 1
            ImageName = 'PngImage1'
            OnClick = BtnGrupKisiSilClick
          end
        end
        object StringGrid1: TStringGrid
          Left = 1
          Top = 28
          Width = 492
          Height = 463
          Align = alClient
          ColCount = 2
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          TabOrder = 1
          ColWidths = (
            105
            307)
        end
      end
      object GridGrup: TcxGrid
        Left = 0
        Top = 32
        Width = 468
        Height = 495
        Align = alClient
        BevelEdges = []
        BevelInner = bvNone
        BevelOuter = bvNone
        TabOrder = 2
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = True
        ExplicitTop = 35
        ExplicitHeight = 492
        object GridGrupView: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          ScrollbarAnnotations.CustomAnnotations = <>
          OnSelectionChanged = GridGrupViewSelectionChanged
          DataController.DataSource = DtsGrup
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsData.CancelOnExit = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsSelection.MultiSelect = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.GridLines = glNone
          OptionsView.GroupByBox = False
          OptionsView.Header = False
          Styles.Background = cxStyle2
          Styles.Content = cxStyle2
          Styles.Header = cxStyle2
          Styles.Inactive = cxStyle2
          object cxGridDBColumn3: TcxGridDBColumn
            Caption = 'T'#252'r'#252
            DataBinding.FieldName = 'ID'
            DataBinding.IsNullValueType = True
            MinWidth = 100
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Options.ShowCaption = False
            Options.Sorting = False
            Width = 100
          end
          object cxGridDBColumn4: TcxGridDBColumn
            Caption = 'Bilgisi'
            DataBinding.FieldName = 'GRUPADI'
            DataBinding.IsNullValueType = True
            MinWidth = 470
            Options.Editing = False
            Options.Filtering = False
            Options.Focusing = False
            Options.IgnoreTimeForFiltering = False
            Options.IncSearch = False
            Options.FilteringFilteredItemsList = False
            Options.FilteringMRUItemsList = False
            Options.FilteringPopup = False
            Options.FilteringPopupMultiSelect = False
            Options.GroupFooters = False
            Options.Grouping = False
            Options.HorzSizing = False
            Options.Moving = False
            Options.ShowCaption = False
            Options.Sorting = False
            Width = 470
          end
        end
        object cxGridLevel4: TcxGridLevel
          GridView = GridGrupView
        end
      end
      object SQLKullan: TMemo
        Left = 109
        Top = 236
        Width = 480
        Height = 33
        Color = 13426846
        Lines.Strings = (
          'select ID='#39'1'#39'+convert(varchar(8),R.ID),Ad=R.FIRMA,'
          
            'G'#246'rev=(select top 1 ANAHTAR from GENINI where BOLUM=-2252 and DE' +
            'GER = '
          'ROL.GOREVID and DIL=-1), '
          
            'Departman=(select top 1 ANAHTAR from GENINI where BOLUM=-2251 an' +
            'd DEGER = '
          'ROL.DEPARTMAN and DIL=-1),'
          #350'ube=(SELECT FIRMA FROM REHBER WHERE ID=R.SUBEID),'
          'Kategori='#39'Personel'#39',T'#252'r=1'
          'from REHBER R '
          'inner join KULLANICI K on R.ID=K.REHBERID '
          'left outer join ROLLER ROL on ROL.ID=R.SINIF'
          'where '
          'R.GRUP=335 and R.DURUM>0 and K.DURUM>0 '
          'order by 2'
          '')
        TabOrder = 3
        Visible = False
      end
    end
  end
  object REHBER: TFDQuery
    BeforeOpen = REHBERBeforeOpen
    AfterOpen = REHBERAfterOpen
    AfterScroll = REHBERAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @ILGILIARAMA INT'
      ''
      'SET @ILGILIARAMA = 1'
      ''
      'select R.ID,R.KOD,ADSOYAD=R.FIRMA,'
      
        'CINSIYET=(select top 1 ANAHTAR from GENINI where BOLUM=-23355 an' +
        'd DEGER=R.STATU and DIL=-1),'
      'DYERI= (select ILADI from ILLER where ILNO=R.BOLGE),'
      'DTARIHI=TARIH,'
      
        'DEPARTMAN=(select top 1 ANAHTAR from GENINI where BOLUM=-2206 an' +
        'd DEGER=R.SINIF and DIL=-1),'
      'GOREVI=(SELECT ROL FROM ROLLER RL WHERE RL.ID = R.KATEGORI),'
      'GIRISTARIHI,CIKISTARIHI,'
      'SUBE = (select FIRMA from REHBER where ID=R.SUBEID),'
      'R.DURUM,'
      
        'DURUMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-1001 and ' +
        'DEGER=R.DURUM and DIL=-1),'
      'R.OZELKOD,'
      'R.BAGID'
      'from '
      '    REHBER R '
      '         left outer join ROLLER ROL on R.KATEGORI=ROL.ID'
      
        '         left outer join REHBERPERSONEL P on R.ID = P.REHBERID a' +
        'nd  '
      '          1 = CASE WHEN  @ILGILIARAMA = 1 THEN 1'
      
        #9#9#9#9'   WHEN  @ILGILIARAMA = 0 AND isnull (P.VARSAYILAN,1) = 1 TH' +
        'EN 1 '
      #9#9'       ELSE 0 END '
      'where GRUP=335'
      'order by 3')
    Left = 154
    Top = 73
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 138
    Top = 141
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clWindow
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle2: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle4: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle5: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle6: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle7: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle8: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
    object cxStyle9: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = clBtnFace
      Font.Charset = TURKISH_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      TextColor = clBlack
    end
  end
  object DtsTicari: TDataSource
    Left = 207
    Top = 191
  end
  object TabFirIletisim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SIRA,ETIKET,BILGI from REHBERBILGI'
      'where YERI= 1  and YER_ID= :UstId   '
      'order by 1   ')
    Left = 424
    Top = 133
    ParamData = <
      item
        Name = 'UstId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabRehberIlgili: TFDQuery
    AfterOpen = TabRehberIlgiliAfterOpen
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'declare @RehID int, @String nvarchar(50)'
      'set @RehID= :REHBERID '
      'SELECT '
      'top 200 '
      
        'ID,BAGID,FIRMA,STATU,NOTLAR,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGI' +
        'STIRMETARIHI,DURUM,SUBEID'
      
        #9'--GOREV = (select top 1 BILGI from REHBERBILGI RB INNER JOIN RE' +
        'HBERAYAR RA ON RA.SIRA=RB.SIRA'
      '-- AND RA.VARSAYILAN=175  where RB.YERI=4 AND RB.YER_ID=RP.ID),'
      
        #9'--LOKASYON = (select top 1 BILGI from REHBERBILGI RB inner join' +
        '  REHBERAYAR RA on RB.ETIKET=RA.ETIKET and RB.YERI=RA.YERI '
      
        '-- and RB.SIRA=RA.SIRA and RA.VARSAYILAN=88 and RB.YER_ID=RP.ID ' +
        '),'
      #9
      'FROM '
      #9'REHBER RP'
      'WHERE  '
      'GRUP=334'
      'and  BAGID = @RehID'
      ' Order by STATU  desc')
    Left = 484
    Top = 108
    ParamData = <
      item
        Name = 'REHBERID'
        Size = -1
        Value = Null
      end>
  end
  object TabRehberOdeme: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select * from REHBERODEME where REHBERID = :REHBERID')
    Left = 548
    Top = 128
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabPerIletisim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SIRA,ETIKET,BILGI from REHBERBILGI'
      
        'where YERI= 1  and YER_ID=(select ID from REHBERILETISIM where R' +
        'EHBERID =  :UstId)   '
      'order by 1   ')
    Left = 283
    Top = 139
    ParamData = <
      item
        Name = 'UstId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabIsDeneyimi: TFDQuery
    AfterOpen = TabIsDeneyimiAfterOpen
    OnCalcFields = TabIsDeneyimiCalcFields
    OnNewRecord = TabIsDeneyimiNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      '*'
      'FROM '
      #9'PERS_DENEYIM'
      'WHERE '
      #9'REHBERID  = :REHBERID'
      ''
      'order by BASLAMATARIHI')
    Left = 1048
    Top = 140
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 4702
      end>
    object TabIsDeneyimiID: TAutoIncField
      FieldName = 'ID'
      ReadOnly = True
    end
    object TabIsDeneyimiREHBERID: TIntegerField
      FieldName = 'REHBERID'
    end
    object TabIsDeneyimiTUR: TSmallintField
      FieldName = 'TUR'
    end
    object TabIsDeneyimiBASVURUTARIHI: TSQLTimeStampField
      FieldName = 'BASVURUTARIHI'
    end
    object TabIsDeneyimiBASLAMATARIHI: TSQLTimeStampField
      FieldName = 'BASLAMATARIHI'
    end
    object TabIsDeneyimiBITISTARIHI: TSQLTimeStampField
      FieldName = 'BITISTARIHI'
    end
    object TabIsDeneyimiSEKTOR: TSmallintField
      FieldName = 'SEKTOR'
    end
    object TabIsDeneyimiDEPARTMAN: TSmallintField
      FieldName = 'DEPARTMAN'
    end
    object TabIsDeneyimiGOREV: TSmallintField
      FieldName = 'GOREV'
    end
    object TabIsDeneyimiILCE: TSmallintField
      FieldName = 'ILCE'
    end
    object TabIsDeneyimiIL: TSmallintField
      FieldName = 'IL'
    end
    object TabIsDeneyimiKURUM: TWideStringField
      FieldName = 'KURUM'
      Size = 100
    end
    object TabIsDeneyimiUCRET_ALT: TCurrencyField
      FieldName = 'UCRET_ALT'
    end
    object TabIsDeneyimiUCRET_UST: TCurrencyField
      FieldName = 'UCRET_UST'
    end
    object TabIsDeneyimiACIKLAMA: TWideStringField
      FieldName = 'ACIKLAMA'
      Size = 100
    end
    object TabIsDeneyimiILCEAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'ILCEAD'
      Size = 50
      Calculated = True
    end
    object TabIsDeneyimiILAD: TStringField
      FieldKind = fkCalculated
      FieldName = 'ILAD'
      Size = 50
      Calculated = True
    end
  end
  object DtsRehberIlgili: TDataSource
    DataSet = TabRehberIlgili
    Left = 503
    Top = 172
  end
  object DtsIsDeneyimi: TDataSource
    DataSet = TabIsDeneyimi
    OnStateChange = DtsIsDeneyimiStateChange
    Left = 1048
    Top = 203
  end
  object DtsPerIletisim: TDataSource
    DataSet = TabPerIletisim
    Left = 303
    Top = 192
  end
  object DtsRehberOdeme: TDataSource
    DataSet = TabRehberOdeme
    Left = 867
    Top = 20
  end
  object DtsRehber: TDataSource
    DataSet = REHBER
    Left = 171
    Top = 131
  end
  object frxSozlesme: TfrxDBDataset
    UserName = 'SOZLESME'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 666
    Top = 14
  end
  object frxGorusme: TfrxDBDataset
    UserName = 'GORUSME'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 608
    Top = 14
  end
  object frxIlgili: TfrxDBDataset
    UserName = 'ILGILI'
    CloseDataSource = False
    DataSet = TabRehberIlgili
    BCDToCurrency = False
    DataSetOptions = []
    Left = 563
    Top = 126
  end
  object frxREHBER: TfrxDBDataset
    UserName = 'REHBER'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 538
    Top = 134
  end
  object frxBanka: TfrxDBDataset
    UserName = 'BANKA'
    CloseDataSource = False
    DataSet = TabIsDeneyimi
    BCDToCurrency = False
    DataSetOptions = []
    Left = 439
    Top = 73
  end
  object frxSozBelge: TfrxDBDataset
    UserName = 'SOZBELGE'
    CloseDataSource = False
    DataSet = TabPerIletisim
    BCDToCurrency = False
    DataSetOptions = []
    Left = 384
    Top = 95
  end
  object TabUcret: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select ETIKET,TUTAR,KUR, SIRA  from PLANMAAS where '
      'YER=0 and YERID=:REHID  order by SIRA')
    Left = 341
    Top = 132
    ParamData = <
      item
        Name = 'REHID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsUcret: TDataSource
    DataSet = TabUcret
    Left = 343
    Top = 186
  end
  object TabPerTemel: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select SIRA,ETIKET,BILGI from REHBERBILGI'
      'where YERI= 3  and YER_ID= :UstId   '
      'order by 1   ')
    Left = 229
    Top = 238
    ParamData = <
      item
        Name = 'UstId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsFirIletisim: TDataSource
    DataSet = TabFirIletisim
    Left = 424
    Top = 174
  end
  object DtsPerTemel: TDataSource
    DataSet = TabPerTemel
    Left = 264
    Top = 193
  end
  object PopupMenuYaz: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 29
    Top = 245
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
  object frxEkstre: TfrxDBDataset
    UserName = 'EKSTRE'
    CloseDataSource = False
    DataSet = TabCariListe
    BCDToCurrency = False
    DataSetOptions = []
    Left = 508
    Top = 242
  end
  object cxGridPopupMenu1: TcxGridPopupMenu
    PopupMenus = <>
    Left = 757
    Top = 100
  end
  object TabCariListe: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'select * from dbo.fn_Cari_Detayli_Ekstre(1,getdate()-100.0,getda' +
        'te())')
    Left = 860
    Top = 111
  end
  object DtsCariListe: TDataSource
    DataSet = TabCariListe
    Left = 709
    Top = 214
  end
  object PopupMenuYeni: TPopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OnPopup = PopupMenuYeniPopup
    Left = 67
    Top = 118
    object info1: TMenuItem
      Caption = 'info'
      ImageIndex = 22
      OnClick = info1Click
    end
    object KartiKopyalaMenu: TMenuItem
      Caption = 'Kart'#305' Kopyala'
      ImageIndex = 4
      OnClick = KartiKopyalaMenuClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object GelenTahakkuk1: TMenuItem
      Tag = 13
      Caption = 'Alacak Tahakkuku'
      ImageIndex = 19
      OnClick = GelenTahakkuk1Click
    end
    object GidenTahakkuk1: TMenuItem
      Tag = 17
      Caption = 'Bor'#231' Tahakkuku'
      ImageIndex = 19
      OnClick = GelenTahakkuk1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Tahsilat1: TMenuItem
      Caption = 'Tahsilat'
      ImageIndex = 34
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
        Visible = False
        OnClick = Fatura1Click
      end
      object ek2: TMenuItem
        Tag = 130
        Caption = #199'ek'
        ImageIndex = 34
        Visible = False
        OnClick = Fatura1Click
      end
      object Senet1: TMenuItem
        Tag = 24
        Caption = 'Senet'
        ImageIndex = 34
        Visible = False
        OnClick = Fatura1Click
      end
      object Dier1: TMenuItem
        Caption = 'Di'#287'er'
        ImageIndex = 15
        Visible = False
        object Hediyeeki1: TMenuItem
          Tag = 28
          Caption = 'Hediye '#199'eki'
          ImageIndex = 34
          OnClick = Fatura1Click
        end
        object adeeki1: TMenuItem
          Tag = 29
          Caption = #304'ade '#199'eki'
          ImageIndex = 34
          OnClick = Fatura1Click
        end
        object Kupon1: TMenuItem
          Tag = 26
          Caption = 'Kupon'
          ImageIndex = 34
          OnClick = Fatura1Click
        end
      end
    end
    object Odeme1: TMenuItem
      Caption = #214'deme'
      ImageIndex = 34
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
        Visible = False
        OnClick = Fatura1Click
      end
      object ek3: TMenuItem
        Tag = 140
        Caption = #199'ek'
        ImageIndex = 34
        Visible = False
        OnClick = Fatura1Click
      end
      object Senet2: TMenuItem
        Tag = 34
        Caption = 'Senet'
        ImageIndex = 34
        Visible = False
        OnClick = Fatura1Click
      end
      object Dier2: TMenuItem
        Caption = 'Di'#287'er'
        ImageIndex = 15
        Visible = False
        object Hediyeeki2: TMenuItem
          Tag = 38
          Caption = 'Hediye '#199'eki'
          ImageIndex = 34
          OnClick = Fatura1Click
        end
        object adeeki2: TMenuItem
          Tag = 39
          Caption = #304'ade '#199'eki'
          ImageIndex = 34
          OnClick = Fatura1Click
        end
        object Kupon2: TMenuItem
          Tag = 36
          Caption = 'Kupon'
          ImageIndex = 34
          OnClick = Fatura1Click
        end
      end
      object N17: TMenuItem
        Caption = '-'
      end
      object MaasAvansKapamaMenu: TMenuItem
        Tag = 31
        Caption = 'Maa'#351' Avans'#305'n'#305' Kapama'
        ImageIndex = 6
      end
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object PozisyonDegisimiMenu: TMenuItem
      Caption = 'Pozisyon De'#287'i'#351'imi'
      ImageIndex = 19
      OnClick = PozisyonDegisimiMenuClick
    end
    object SSKBalama1: TMenuItem
      Caption = 'SSK Ba'#351'lama'
      ImageIndex = 6
      OnClick = SSKBalama1Click
    end
    object IstenCikisMenu: TMenuItem
      Caption = #304#351'ten '#199#305'k'#305#351
      ImageIndex = 24
      OnClick = IstenCikisMenuClick
    end
    object IstenCikisIptalMenu: TMenuItem
      Caption = #304#351'ten '#199#305'k'#305#351' '#304'ptal'
      ImageIndex = 3
      OnClick = IstenCikisIptalMenuClick
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object Aktarm1: TMenuItem
      Caption = #304#351' Aktar'#305'm'#305
      ImageIndex = 15
      object ProjeAktarm1: TMenuItem
        Tag = 1
        Caption = 'Proje Aktar'#305'm'#305
        ImageIndex = 15
        OnClick = ProjeAktarm1Click
      end
      object ListesiAktarm1: TMenuItem
        Tag = 2
        Caption = #304#351' Listesi Aktar'#305'm'#305
        ImageIndex = 32
        OnClick = ProjeAktarm1Click
      end
      object eklifAktarm1: TMenuItem
        Tag = 3
        Caption = 'Teklif Aktar'#305'm'#305
        ImageIndex = 4
        OnClick = ProjeAktarm1Click
      end
      object ServisAktarm1: TMenuItem
        Tag = 4
        Caption = 'Servis Aktar'#305'm'#305
        ImageIndex = 15
        OnClick = ProjeAktarm1Click
      end
      object N16: TMenuItem
        Caption = '-'
      end
      object HereyiAktar1: TMenuItem
        Tag = 99
        Caption = 'Her'#351'eyi Aktar'
        ImageIndex = 15
        OnClick = ProjeAktarm1Click
      end
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object ExceldenVeriAlMenu: TMenuItem
      Caption = 'Excelden Veri Al'
      ImageIndex = 32
      OnClick = ExceldenVeriAlMenuClick
    end
  end
  object TabDemirbasBilgi: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT    D.*, '
      'ZIMMETLIADI = R.FIRMA,'
      'LOKASYONADI=L.ACIKLAMA,'
      'KATEGORIADI = DU.AD,'
      'StokModel.ANAHTAR AS MODELAD,'#9
      
        'KALBITTARIH =  (SELECT MAX(GECERLILIKTARIHI)  FROM KALIBRASYON K' +
        ' WHERE K.DEMIRBASID=D.ID)  '
      'FROM DEMIRBAS D '
      ' LEFT OUTER JOIN DEMIRBAS_KATEGORI AS DU ON DU.ID=D.KATEGORIID  '
      
        ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = D.MODEL A' +
        'ND StokModel.BOLUM=convert(int,'#39'-2804'#39'+convert(varchar(10),D.MAR' +
        'KA))  '
      ' LEFT OUTER JOIN REHBER AS R ON R.ID = D.REHBERID'
      
        ' LEFT OUTER JOIN LOKASYON AS L  ON L.ID = (select top 1 LOKASYON' +
        'ID from DEMIRBAS_TUTANAK DT inner join DEMIRBAS_TUTANAK_DETAY DT' +
        'D on DT.ID=DTD.TUTANAKID and DTD.DEMIRBASID=D.ID  ORDER  BY ID D' +
        'ESC)'
      'where D.REHBERID= :P1')
    Left = 581
    Top = 251
    ParamData = <
      item
        Name = 'P1'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsDemirbasBilgi: TDataSource
    DataSet = TabDemirbasBilgi
    Left = 631
    Top = 307
  end
  object PERSONELIZIN: TFDQuery
    AfterPost = PERSONELIZINAfterPost
    OnNewRecord = PERSONELIZINNewRecord
    Connection = Tablo.FDCnn
    Left = 352
    Top = 255
  end
  object DtsPersonelIzin: TDataSource
    DataSet = PERSONELIZIN
    OnStateChange = DtsPersonelIzinStateChange
    Left = 389
    Top = 174
  end
  object PMAksiyonlarMenu: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PMAksiyonlarMenuPopup
    Left = 75
    Top = 196
    object Ekle1: TMenuItem
      Caption = 'Aksiyon Ekle'
      ImageIndex = 19
    end
    object Sil1: TMenuItem
      Caption = 'Aksiyon Sil'
      ImageIndex = 1
      OnClick = Sil1Click
    end
    object AksiyonBilgisiniGorMenu: TMenuItem
      Caption = 'Aksiyon Bilgisini G'#246'r'
      ImageIndex = 22
      OnClick = AksiyonBilgisiniGorMenuClick
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object ExceldenAksiyonAktar1: TMenuItem
      Caption = 'Excelden Aksiyon Aktar'
      ImageIndex = 32
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object TahsilMenu2: TMenuItem
      Caption = 'Tahsil Et'
      ImageIndex = 34
      object Nakit3: TMenuItem
        Tag = 21
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object HavaleEFT3: TMenuItem
        Tag = 22
        Caption = 'Havale/EFT'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object POS1: TMenuItem
        Tag = 25
        Caption = 'POS'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object ek4: TMenuItem
        Tag = 23
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object Senet3: TMenuItem
        Tag = 24
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
    end
    object OdemeMenu2: TMenuItem
      Caption = #214'deme yap'
      ImageIndex = 34
      object NakitOdemeMenu2: TMenuItem
        Tag = 31
        Caption = 'Nakit'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object HavaleEFTOdemeMenu2: TMenuItem
        Tag = 32
        Caption = 'Havale/EFT'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object MenuItem72: TMenuItem
        Tag = 35
        Caption = 'Kredi Kart'#305
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object CekOdemeMenu2: TMenuItem
        Tag = 33
        Caption = #199'ek'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
      object SenetOdemeMenu2: TMenuItem
        Tag = 34
        Caption = 'Senet'
        ImageIndex = 34
        OnClick = Nakit3Click
      end
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object Kopyala2: TMenuItem
      Caption = 'Kopyala'
      ImageIndex = 10
      OnClick = Kopyala2Click
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object iadeAl: TMenuItem
      Caption = #304'ade Al'
      ImageIndex = 15
      object Faturaile1: TMenuItem
        Tag = 2
        Caption = 'Fatura ile'
        ImageIndex = 19
        OnClick = Faturaile1Click
      end
      object GiderPusulasile1: TMenuItem
        Tag = 5
        Caption = 'Gider Pusulas'#305' ile'
        ImageIndex = 34
        OnClick = Faturaile1Click
      end
    end
  end
  object TabImaj: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        'SELECT  ID, YERI, YER_ID,DURUM,ICDIS, BELGENO, BELGEADI, TUR, AC' +
        'IKLAMA  FROM  [IMAJ]'
      'WHERE'
      'DURUM>0 AND'
      'REHBERID=:PRehberID')
    Left = 628
    Top = 354
    ParamData = <
      item
        Name = 'PRehberID'
        Size = -1
        Value = Null
      end>
  end
  object DtsImaj: TDataSource
    DataSet = TabImaj
    OnStateChange = DtsImajStateChange
    Left = 800
    Top = 193
  end
  object OpenDialog1: TOpenDialog
    Left = 647
    Top = 128
  end
  object JvDragDrop1: TJvDragDrop
    DropTarget = Owner
    OnDrop = JvDragDrop1Drop
    Left = 695
    Top = 139
  end
  object TabEkipmanlar: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'Select *,'
      'KOD=(Select KOD FROM EKIPMANLAR E where E.ID=ER.EKIPMANID), '
      'AD=(Select AD FROM EKIPMANLAR E where E.ID=ER.EKIPMANID), '
      
        'DETAYBOLUMU=(Select DETAYBOLUMU FROM EKIPMANLAR E where E.ID=ER.' +
        'EKIPMANID)  ,'
      
        'ILGILI=(select RP.ADSOYAD from REHBERPERSONEL RP where RP.ID=ER.' +
        'MUS_ILGILI ),'
      
        'LOKASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=ER.LOKASY' +
        'ONID)'
      'from EKIPMANREHBER ER '
      'Where REHBERID=:PRehId')
    Left = 790
    Top = 267
    ParamData = <
      item
        Name = 'PRehId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end>
  end
  object DtsEkipmanlar: TDataSource
    DataSet = TabEkipmanlar
    Left = 761
    Top = 182
  end
  object REHBERILETISIM: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9' *'
      'FROM '
      #9'REHBERILETISIM'
      'WHERE  '
      #9'REHBERID = :REHBERID '
      ' Order by VARSAYILAN  desc')
    Left = 577
    Top = 144
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsRehberIletisim: TDataSource
    DataSet = REHBERILETISIM
    Left = 666
    Top = 173
  end
  object PopupIletisim: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 227
    Top = 288
    object letiimaddeitir1: TMenuItem
      Caption = #304'leti'#351'im ad'#305' de'#287'i'#351'tir'
      ImageIndex = 19
      OnClick = letiimaddeitir1Click
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object VarsaylanYap1: TMenuItem
      Caption = 'Varsay'#305'lan Yap'
      ImageIndex = 23
      OnClick = VarsaylanYap1Click
    end
  end
  object TabDokuman: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT *,TIP=1'
      
        '--,EXT='#39'.'#39'+REVERSE( SUBSTRING(REVERSE(isnull((select Top 1 AD fr' +
        'om DOKUMAN I where  I.ID=D.ID order'
      
        '--by I.ID desc),'#39'.'#39')),1,CHARINDEX('#39'.'#39',REVERSE(isnull((select Top' +
        ' 1 AD from DOKUMAN I where  I.ID=D.ID'
      '--order by I.ID desc),'#39'.'#39')),1)-1))'
      '  FROM  DOKUMAN  D'
      'WHERE'
      ' D.REHBERID= :PRehberID AND'
      '--D.MODUL=  PYeri AND  --YERI'
      '--D.MODULID = PYer_ID AND --YER_ID'
      'D.KLASOR>0 ')
    Left = 402
    Top = 302
    ParamData = <
      item
        Name = 'PRehberID'
        Size = -1
        Value = Null
      end>
  end
  object DtsDokuman: TDataSource
    DataSet = TabDokuman
    Left = 409
    Top = 315
  end
  object DtsSmsEPosta: TDataSource
    DataSet = TabSmsEPosta
    Left = 1032
    Top = 304
  end
  object TabSmsEPosta: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'DECLARE @REHID int'
      'SET @REHID= :PRehID'
      ''
      
        'SELECT TIP='#39'E-Posta'#39',EXT=1,GONDERIMTARIHI,BELGENO='#39#39',DURUM='#39#39' ,Y' +
        'ON='#39'Giden'#39',MODUL= CASE WHEN YER='#39'12'#39' THEN '#39'Aktivite'#39' WHEN YER='#39'8' +
        '3'#39' THEN '#39'Servis'#39' END,KATEGORI='#39#39',DOKUMANADI=GIDENADRES,SURUM='#39#39',' +
        'KONUSU=MESAJKONUSU,TUR='#39#39',BOLUM='#39#39',KURUM='#39#39',ILGILI='#39#39',SORUMLU='#39#39 +
        ',BOYUT='#39#39',LOKASYON='#39#39',GECERLILIK_TARIHI='#39#39',KLASOR='#39#39',KAYNAK=EPOS' +
        'TA,ANAHTAR,YER  FROM EPOSTALAR'
      'WHERE'
      'REHID=@REHID'
      'UNION ALL'
      
        'SELECT TIP='#39'Sms'#39',EXT=2,GONDERIMTARIHI,BELGENO='#39#39',DURUM='#39#39' ,YON='#39 +
        'Giden'#39',MODUL= CASE WHEN YER='#39'12'#39' THEN '#39'Aktivite'#39' WHEN YER='#39'83'#39' T' +
        'HEN '#39'Servis'#39' END,KATEGORI='#39#39',DOKUMANADI=GSMNO,SURUM='#39#39',KONUSU=ME' +
        'SAJMETNI,TUR='#39#39',BOLUM='#39#39',KURUM='#39#39',ILGILI='#39#39',SORUMLU='#39#39',BOYUT='#39#39',' +
        'LOKASYON='#39#39',GECERLILIK_TARIHI='#39#39',KLASOR='#39#39',KAYNAK='#39#39' ,ANAHTAR,YE' +
        'R  FROM SMSLER'
      'WHERE'
      'REHID=@REHID')
    Left = 1032
    Top = 256
    ParamData = <
      item
        Name = 'PRehID'
        Size = -1
        Value = Null
      end>
  end
  object JvTimer1: TJvTimer
    Enabled = False
    Threaded = False
    OnTimer = JvTimer1Timer
    Left = 472
    Top = 168
  end
  object frxPersonelIzin: TfrxDBDataset
    UserName = 'IZIN'
    CloseDataSource = False
    DataSet = PERSONELIZIN
    BCDToCurrency = False
    DataSetOptions = []
    Left = 604
    Top = 170
  end
  object DtsHareketler: TDataSource
    DataSet = TabHareketler
    Left = 816
    Top = 336
  end
  object TabHareketler: TFDQuery
    AfterScroll = TabHareketlerAfterScroll
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT *,'
      'SUBE=(select FIRMA from REHBER where ID=ROL.SUBEID),'
      
        'DEPARTMANAD=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2251 ' +
        'AND DEGER = ROL.DEPARTMAN AND DIL=-1 ),'
      
        'GOREV=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DE' +
        'GER = ROL.GOREVID AND DIL=-1 ) '
      'FROM PERS_HAREKET PH '
      'inner join ROLLER ROL on ROL.ID=PH.ROLID'
      'WHERE REHBERID= :REHBERID '
      'ORDER BY TARIH ')
    Left = 736
    Top = 328
    ParamData = <
      item
        Name = 'REHBERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object TabKesinti: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'ID,'
      #9'ETIKET,'
      #9'TUTAR,'
      #9'KUR, '
      '                SIRA,'
      #9'TARIH,'
      #9'ACIKLAMA,'
      
        #9'TUR = CASE PM.TUR WHEN '#39'B'#39' THEN '#39'Banka'#39' WHEN '#39'K'#39' THEN '#39'Kasa'#39' EN' +
        'D'
      'FROM'
      #9'PLANMAAS PM'
      'WHERE'
      #9'YER=1 AND PM.YERID=:YERID AND CONVERT(DATETIME,TARIH) >'
      
        ' CONVERT(VARCHAR,DATEPART(YEAR,GETDATE()))+'#39'-'#39'+CONVERT(VARCHAR,D' +
        'ATEPART(MONTH,dateadd(month,-1,GETDATE())))+'#39'-01'#39
      'ORDER BY '
      #9'TARIH')
    Left = 925
    Top = 140
    ParamData = <
      item
        Name = 'YERID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsKesinti: TDataSource
    DataSet = TabKesinti
    Left = 927
    Top = 194
  end
  object PmIzinTurleri: TPopupMenu
    Images = Tablo.PNGImageList2
    Left = 149
    Top = 317
  end
  object TabGorevler: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      
        ' SELECT * FROM [dbo].[fn_prg_IsListesiBanaAtananlar] ( :RehberId' +
        ', :AcKapa , :GunSay )')
    Left = 469
    Top = 333
    ParamData = <
      item
        Name = 'RehberId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 4322
      end
      item
        Name = 'AcKapa'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 0
      end
      item
        Name = 'GunSay'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = 9999
      end>
  end
  object DtsGorevler: TDataSource
    DataSet = TabGorevler
    Left = 467
    Top = 376
  end
  object GorevlerMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 336
    Top = 364
    object DuzenleMenu: TMenuItem
      Caption = 'D'#252'zenle'
      ImageIndex = 7
      OnClick = DuzenleMenuClick
    end
    object TamamlandiIsaretleMenu: TMenuItem
      Caption = #304#351'aretliler Tamamland'#305' / Tamamlanmad'#305
      ImageIndex = 23
      OnClick = TamamlandiIsaretleMenuClick
    end
    object Bayraklaretle1: TMenuItem
      Caption = #304#351'aretliler  Bayrakl'#305' / Bayraks'#305'z'
      ImageIndex = 31
      OnClick = Bayraklaretle1Click
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object TarihBugunMenu: TMenuItem
      Caption = #304#351'aretlilerin Tarihi Bug'#252'n'
      ImageIndex = 21
    end
    object arihYarn1: TMenuItem
      Tag = 1
      Caption = #304#351'aretlilerin Tarihi Yar'#305'n'
      ImageIndex = 21
    end
    object TarihiKaldirMenu: TMenuItem
      Tag = -1
      Caption = #304#351'aretlilerin Tarihini Kald'#305'r'
      ImageIndex = 24
    end
    object MenuItem5: TMenuItem
      Caption = '-'
    end
    object MteriSe1: TMenuItem
      Caption = #304#351'aretlilere M'#252#351'teri Se'#231
      ImageIndex = 35
    end
    object MenuItem7: TMenuItem
      Caption = '-'
    end
    object BuiiEPostaGnder1: TMenuItem
      Caption = 'Bu i'#351'i E-Posta G'#246'nder'
      ImageIndex = 17
    end
    object BuiYazdr1: TMenuItem
      Caption = 'Bu '#304#351'i Yazd'#305'r'
      ImageIndex = 8
    end
    object MenuItem9: TMenuItem
      Caption = '-'
    end
    object IsiKopyalaMenu: TMenuItem
      Caption = #304#351'i Kopyala'
      ImageIndex = 10
      OnClick = IsiKopyalaMenuClick
    end
    object IsiSilMenu: TMenuItem
      Caption = #304#351'i Sil'
      ImageIndex = 1
      OnClick = IsiSilMenuClick
    end
  end
  object TabDil: TFDQuery
    OnNewRecord = TabDilNewRecord
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT '
      #9'*'
      'FROM'
      #9'PERS_DIL'
      'WHERE'
      #9'REHBERID=:Prm1'
      'order by ID')
    Left = 981
    Top = 148
    ParamData = <
      item
        Name = 'Prm1'
        DataType = ftWideString
        Size = 1
        Value = '0'
      end>
  end
  object DtsDil: TDataSource
    DataSet = TabDil
    OnStateChange = DtsDilStateChange
    Left = 983
    Top = 202
  end
  object DtsYorum: TDataSource
    DataSet = TabYorum
    Left = 930
    Top = 396
  end
  object PopupYorumlar: TPopupMenu
    Images = Tablo.PNGImageList2
    OnPopup = PopupYorumlarPopup
    Left = 536
    Top = 336
    object YorumDzenle1: TMenuItem
      Caption = 'Yorum D'#252'zenle'
      ImageIndex = 7
      OnClick = YorumDzenle1Click
    end
    object PopupYorumuSil: TMenuItem
      Caption = 'Yorum Sil'
      ImageIndex = 1
      OnClick = PopupYorumuSilClick
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object DkmanGster1: TMenuItem
      Caption = 'D'#246'k'#252'man G'#246'ster'
      ImageIndex = 37
      OnClick = DkmanGster1Click
    end
    object DokumanFormunuA1: TMenuItem
      Caption = 'Dokuman Formunu A'#231
      ImageIndex = 43
      OnClick = DokumanFormunuA1Click
    end
    object DkmanSil1: TMenuItem
      Caption = 'D'#246'k'#252'man Sil'
      ImageIndex = 1
      OnClick = DkmanSil1Click
    end
  end
  object TabYorum: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select GY.ID,GY.GOREVID,  GY.EKLEMETARIHI, GY.EKLEYEN,'
      'TARIH=CONVERT(varchar(20),GY.EKLEMETARIHI,113),'
      'YAZAN=R.FIRMA,'
      'GY.YORUM,'
      
        'ATAC=reverse(left(reverse(D.AD),charindex('#39'.'#39',reverse(D.AD)))),D' +
        'OKUMANID=D.ID,DOKUMANAD=D.AD'
      'from'#9
      #9'GOREVYORUM GY '
      #9'left outer join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '
      #9'left outer join REHBER R on R.ID=GY.EKLEYEN '
      'where '
      ' GY.TUR=:PYer'
      'and GOREVID=:PYerId '
      'order by 2 DESC')
    Left = 930
    Top = 345
    ParamData = <
      item
        Name = 'PYer'
        DataType = ftWord
        Precision = 3
        Size = 1
        Value = Null
      end
      item
        Name = 'PYerId'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object YorumAtacMenu: TOfficePopupMenu
    Images = Tablo.PNGImageList2
    OwnerDraw = True
    OfficeDesign = True
    Appearance.Gradient1Start = 15722724
    Appearance.Gradient1End = 14599608
    Appearance.Gradient2Start = 14203563
    Appearance.Gradient2End = 15722724
    Appearance.MarginX = 4
    Appearance.MarginY = 2
    Appearance.SeparatorLeading = 6
    Appearance.GutterWidth = 26
    Appearance.SeparatorBackgroundColor = 15656925
    Appearance.SeparatorLineColor = 12961221
    Appearance.GutterColor = 15658729
    Appearance.ItemBackgroundColor = 16448250
    Appearance.ItemSelectedColor = 15128011
    Appearance.FontColor = 7214336
    Appearance.FontDisabledColor = 14599640
    Style = msDefault
    Left = 448
    Top = 228
    object MenuKlasordenEkle: TMenuItem
      Caption = 'Klas'#246'rden'
      ImageIndex = 0
      OnClick = MenuKlasordenEkleClick
    end
    object MenuTarayacidanEkle: TMenuItem
      Caption = 'Taray'#305'c'#305'dan'
      ImageIndex = 16
      OnClick = MenuTarayacidanEkleClick
    end
  end
  object cxGridPopupYorumlar: TcxGridPopupMenu
    PopupMenus = <
      item
        HitTypes = [gvhtCell, gvhtRecord]
        Index = 0
        PopupMenu = PopupYorumlar
      end>
    UseBuiltInPopupMenus = False
    AlwaysFireOnPopup = True
    Left = 808
    Top = 392
  end
  object TabResim: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'SELECT  TOP 1 ID, RESIM'
      'FROM         REHBER'
      'WHERE ID=:PRID')
    Left = 787
    Top = 359
    ParamData = <
      item
        Name = 'PRID'
        DataType = ftInteger
        Precision = 10
        Size = 4
        Value = Null
      end>
  end
  object DtsResim: TDataSource
    DataSet = TabResim
    Left = 889
    Top = 246
  end
  object TabGrup: TFDQuery
    Connection = Tablo.FDCnn
    SQL.Strings = (
      'select R.ID, GRUPADI=R.FIRMA, NOTLAR'
      'from '
      '    REHBER R '
      'where GRUP=336'
      'order by 2')
    Left = 242
    Top = 73
  end
  object DtsGrup: TDataSource
    DataSet = TabGrup
    Left = 303
    Top = 79
  end
end
